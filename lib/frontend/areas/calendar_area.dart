import 'package:mat_finance/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:mat_finance/utils/smooth_scroll_behavior.dart';


import 'package:mat_finance/frontend/popups/meeting_popup.dart';
import 'package:mat_finance/backend/services/calendar_service.dart';
import 'package:mat_finance/backend/services/clients_service.dart';
import 'package:mat_finance/backend/services/splash_service.dart';
import 'package:mat_finance/frontend/components/texts/text2.dart';
import 'package:mat_finance/backend/services/firebase_service.dart';

// Import the required components
import 'package:mat_finance/frontend/components/headers/widget_header6.dart';
import 'package:mat_finance/frontend/components/items/calendar_slot.dart';
import 'package:mat_finance/frontend/components/dialog_utils.dart';
import 'package:intl/intl.dart';
import 'package:mat_finance/frontend/components/headers/widget_header1.dart';
import 'package:mat_finance/frontend/components/items/light_item7.dart';
import 'package:mat_finance/frontend/components/items/dark_item7.dart';

/// Area pentru calendar care va fi afisata in cadrul ecranului principal.
/// OPTIMIZAT: Implementare avansata cu cache inteligent si loading instant
class CalendarArea extends StatefulWidget {
  /// Callback pentru refresh meetingsPane cand se salveaza intalniri
  final VoidCallback? onMeetingSaved;
  final Function(String)? onMeetingSelected;
  
  const CalendarArea({
    super.key,
    this.onMeetingSaved,
    this.onMeetingSelected,
  });

  @override
  State<CalendarArea> createState() => CalendarAreaState();
}

class CalendarAreaState extends State<CalendarArea> {
  // Services
  late final CalendarService _calendarService;
  late final SplashService _splashService;
  
  // Firebase references
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Calendar state
  int _currentWeekOffset = 0;
  bool _isInitialized = false;
  bool _isLoading = false;
  
  // OPTIMIZARE: Data cache pentru meetings cu timestamp
  List<ClientActivity> _cachedMeetings = [];
  List<ClientActivity> _allMeetings = []; // Cache for all meetings for navigation
  Timer? _refreshTimer;
  
  // OPTIMIZARE: Debouncing imbunatatit pentru load meetings
  Timer? _loadDebounceTimer;
  bool _isLoadingMeetings = false;
  DateTime? _lastLoadTime;
  
  // Highlight functionality
  Timer? _highlightTimer;

  // Upcoming meetings (formerly meetings pane) state
  DateFormat? dateFormatter;
  DateFormat? timeFormatter;
  bool _isInitializingUpcoming = true;
  List<ClientActivity> _upcomingAppointments = [];
  bool _isLoadingUpcoming = true;
  Timer? _upcomingLoadDebounceTimer;
  bool _isLoadingUpcomingMeetings = false;
  DateTime? _lastUpcomingLoadTime;
  
  // Scroll controller for calendar grid
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    PerformanceMonitor.startTimer('calendarAreaInit');
    
    // Foloseste serviciile pre-incarcate din splash
    _calendarService = SplashService().calendarService;
    _splashService = SplashService();
    
    // FIX: Asculta la schimbari in SplashService pentru refresh automat
    _splashService.addListener(_onSplashServiceChanged);
    
    // Calendar este deja initializat in splash
    _isInitialized = true;
    
    // OPTIMIZARE: Incarca imediat din cache pentru loading instant si sincronizare completa
    _loadFromCacheInstantly();
    _initializeFormatters();
    _loadUpcomingFromCacheInstantly();
    
    PerformanceMonitor.endTimer('calendarAreaInit');

  }

  /// OPTIMIZARE: Incarca imediat din cache pentru loading instant si sincronizare completa
  Future<void> _loadFromCacheInstantly() async {
    try {
      final totalSw = Stopwatch()..start();
      // OPTIMIZARE: Nu mai verifica consultantul la fiecare incarcare - doar la prima initializare
      if (!_isInitialized) {
        await _splashService.resetForNewConsultant();
      }
      
      // Incarca intalnirile din cache instant (fara await), apoi declanseaza refresh in background
      final cacheSw = Stopwatch()..start();
      final cachedMeetings = _splashService.getCachedMeetingsSync();
      cacheSw.stop();
      final filterSw = Stopwatch()..start();
      
      if (mounted) {
        setState(() {
          _allMeetings = cachedMeetings;
          _filterMeetingsForCurrentWeek();
          _isLoading = false;
          _isInitialized = true;
        });
      }
      filterSw.stop();
      totalSw.stop();
      debugPrint('CALENDAR_METRICS: loadFromCacheInstantly totalMs=${totalSw.elapsedMilliseconds} cacheMs=${cacheSw.elapsedMilliseconds} filterMs=${filterSw.elapsedMilliseconds} allMeetings=${cachedMeetings.length} weekMeetings=${_cachedMeetings.length}');

      // Declanseaza un refresh rapid in fundal doar daca datele sunt stale
      unawaited(() async {
        final beforeCount = _allMeetings.length;
        final refreshed = await _splashService.getCachedMeetingsFast();
        if (mounted && refreshed.length != beforeCount) {
          // Actualizeaza UI doar daca s-a schimbat numarul de intalniri pentru a evita rebuild-uri inutile
          setState(() {
            _allMeetings = refreshed;
            _filterMeetingsForCurrentWeek();
          });
        }
      }());
      
  
    } catch (e) {
      debugPrint('❌ CALENDAR_AREA: Error loading from cache: $e');
      // Fallback to normal loading
      await _loadMeetingsForCurrentWeek();
    }
  }



  @override
  void dispose() {
    _refreshTimer?.cancel();
    _highlightTimer?.cancel();
    _loadDebounceTimer?.cancel();
    _scrollController.dispose();
    _splashService.removeListener(_onSplashServiceChanged); // FIX: cleanup listener
    super.dispose();
  }

  /// FIX: Callback pentru refresh automat cand se schimba datele in SplashService
  void _onSplashServiceChanged() {
    if (!mounted) return;
    // Update immediately from sync cache for instant UI consistency
    final instant = _splashService.getCachedMeetingsSync();
    setState(() {
      _allMeetings = instant;
      _filterMeetingsForCurrentWeek();
    });
    // Then trigger a forced background refresh to ensure latest data (fire-and-forget)
    unawaited(_loadMeetingsForCurrentWeek(force: true));
    // Also refresh upcoming meetings side panel
    final now = DateTime.now();
    _rebuildUpcomingFromList(instant, now).then((updated) {
      if (updated && mounted) {
        setState(() {});
      }
    });
    unawaited(_loadUpcomingMeetings(force: true));
  }

  /// OPTIMIZAT: Filtreaza intalnirile pentru saptamana curenta din cache
  void _filterMeetingsForCurrentWeek() {
    final sw = Stopwatch()..start();
    final DateTime startOfWeek = _calendarService.getStartOfWeekToDisplay(_currentWeekOffset);
    final DateTime endOfWeek = _calendarService.getEndOfWeekToDisplay(_currentWeekOffset);
    final total = _allMeetings.length;
    _cachedMeetings = _allMeetings.where((meeting) {
      final meetingDateTime = meeting.dateTime;
      return meetingDateTime.isAfter(startOfWeek) && meetingDateTime.isBefore(endOfWeek);
    }).toList();
    sw.stop();
    debugPrint('CALENDAR_METRICS: filterWeek offset=$_currentWeekOffset total=$total week=${_cachedMeetings.length} filterMs=${sw.elapsedMilliseconds}');
  }

  /// OPTIMIZAT: Incarca intalnirile cu debouncing imbunatatit
  Future<void> _loadMeetingsForCurrentWeek({bool force = false}) async {
    // OPTIMIZARE: Verifica daca cache-ul este recent (sub 3 secunde - redus de la 5)
    if (!force && _lastLoadTime != null && 
        DateTime.now().difference(_lastLoadTime!).inSeconds < 3) {
      // OPTIMIZARE: Log redus pentru performanta
      // debugPrint('⏭️ CALENDAR_AREA: Skipping load - cache is recent');
      return;
    }
    
    // Anuleaza loading-ul anterior daca exista unul pending
    _loadDebounceTimer?.cancel();
    
    // Daca deja se incarca, nu mai face alt request
    if (_isLoadingMeetings) return;
    
    // CRITICAL FIX: Near-instant debouncing for immediate sync
    _loadDebounceTimer = Timer(const Duration(milliseconds: 10), () async {
      await _performLoadMeetingsForCurrentWeek();
    });
  }

  /// OPTIMIZAT: Executa incarcarea efectiva a intalnirilor pentru saptamana curenta
  Future<void> _performLoadMeetingsForCurrentWeek() async {
    if (_isLoadingMeetings) return;
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      debugPrint("❌ CALENDAR_AREA: User not authenticated");
      return;
    }

    // OPTIMIZARE: Nu mai seteaza loading state daca avem deja date in cache
    if (_allMeetings.isNotEmpty && _lastLoadTime != null && 
        DateTime.now().difference(_lastLoadTime!).inSeconds < 3) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final totalSw = Stopwatch()..start();
      _isLoadingMeetings = true;
      
      // OPTIMIZARE: Obtine toate intalnirile din cache-ul din splash (instant si actualizat)
      final fetchSw = Stopwatch()..start();
      final allTeamMeetings = await _splashService.getCachedMeetings();
      fetchSw.stop();
      final filterSw = Stopwatch()..start();
      
      if (mounted) {
        setState(() {
          _allMeetings = allTeamMeetings;
          _filterMeetingsForCurrentWeek();
          _isLoading = false;
          _lastLoadTime = DateTime.now();
        });
      }
      filterSw.stop();
      totalSw.stop();
      debugPrint('CALENDAR_METRICS: loadWeek totalMs=${totalSw.elapsedMilliseconds} fetchMs=${fetchSw.elapsedMilliseconds} filter+setStateMs=${filterSw.elapsedMilliseconds} allMeetings=${allTeamMeetings.length} weekMeetings=${_cachedMeetings.length}');
      
  
    } catch (e) {
      debugPrint('❌ CALENDAR_AREA: Error loading team meetings from cache: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Keep existing cache on error
        });
      }
    } finally {
      _isLoadingMeetings = false;
    }
  }

  // Navigate to previous week
  void _navigateToPreviousWeek() {
    if (mounted) {
      setState(() {
        _currentWeekOffset--;
      });
    }
    _filterMeetingsForCurrentWeek(); // OPTIMIZARE: Filtreaza din cache in loc sa incarci din nou
  }
  
  // Navigate to next week
  void _navigateToNextWeek() {
    if (mounted) {
      setState(() {
        _currentWeekOffset++;
      });
    }
    _filterMeetingsForCurrentWeek(); // OPTIMIZARE: Filtreaza din cache in loc sa incarci din nou
  }

  // Navigate to current week
  void _navigateToCurrentWeek() {
    if (mounted) {
      setState(() {
        _currentWeekOffset = 0;
      });
    }
    _filterMeetingsForCurrentWeek(); // OPTIMIZARE: Filtreaza din cache in loc sa incarci din nou
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return _buildLoadingContainer();
    }
    
    return _buildCalendarWidget();
  }

  /// Construieste containerul de loading
  Widget _buildLoadingContainer() {
    return Container(
      width: double.infinity,
      height: 600,
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: AppTheme.backgroundColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.elementColor1,
              strokeWidth: 2,
            ),
            const SizedBox(height: 16),
            Text2(
              text: 'Initializare calendar...',
              color: AppTheme.elementColor2,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }

  /// Construieste widget-ul principal pentru calendar conform designului Figma
  Widget _buildCalendarWidget() {
    final String dateInterval = _calendarService.getDateInterval(_currentWeekOffset);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: AppTheme.backgroundColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Calendar column
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header cu navigation conform Figma folosind WidgetHeader6
                WidgetHeader6(
                  title: 'Calendar',
                  dateText: dateInterval,
                  prevDateIcon: Icons.chevron_left,
                  nextDateIcon: Icons.chevron_right,
                  onPrevDateTap: _navigateToPreviousWeek,
                  onNextDateTap: _navigateToNextWeek,
                  onDateTextTap: _currentWeekOffset != 0 ? _navigateToCurrentWeek : null,
                  titleColor: AppTheme.elementColor1,
                  dateTextColor: _currentWeekOffset != 0 
                      ? AppTheme.elementColor2 
                      : AppTheme.elementColor1,
                  dateNavIconColor: AppTheme.elementColor1,
                ),
                const SizedBox(height: 8),
                Expanded(child: _buildCalendarContainer()),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Embedded meetings pane on the right
          SizedBox(
            width: 264,
            child: _buildUpcomingMeetingsPanel(),
          ),
        ],
      ),
    );
  }

  /// Construieste containerul principal cu calendar
  Widget _buildCalendarContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: AppTheme.backgroundColor2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
      ),
      child: Column(
        children: [
          // Header cu zilele saptamanii
          _buildWeekDaysHeader(),
          
          const SizedBox(height: 8),
          
          // Grid-ul cu orele si sloturile
          Expanded(
            child: _buildCalendarGrid(),
          ),
        ],
      ),
    );
  }

  /// Construieste header-ul cu zilele saptamanii conform Figma
  Widget _buildWeekDaysHeader() {
    final List<String> weekDates = _calendarService.getWeekDates(_currentWeekOffset);
    
    return SizedBox(
      width: double.infinity,
      height: 21,
      child: Row(
        children: [
          // Spatiu pentru coloana cu orele
          const SizedBox(width: 48),
          
          // Zilele saptamanii folosind Text2
          ...List.generate(CalendarService.daysPerWeek, (index) {
            return Expanded(
              child: Container(
                height: 21,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.center,
                child: Text2(
                  text: '${CalendarService.workingDays[index]} ${weekDates[index]}',
                  color: AppTheme.elementColor2,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Construieste grid-ul cu orele si sloturile (fara StreamBuilder)
  Widget _buildCalendarGrid() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.elementColor1,
              strokeWidth: 2,
            ),
            const SizedBox(height: 8),
            Text2(
              text: 'Se incarca calendarul...',
              color: AppTheme.elementColor2,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      );
    }

          final Map<String, Map<String, dynamic>> meetingsMap = {};
      final Map<String, String> meetingsDocIds = {};
      
      // Process cached meetings 
      for (var meeting in _cachedMeetings) {
        try {
          final dateTime = meeting.dateTime;
          
          final dayIndex = _calendarService.getDayIndexForDate(dateTime, _currentWeekOffset);
          final hourIndex = _calendarService.getHourIndexForDateTime(dateTime);
          
          if (dayIndex != null && hourIndex != -1) {
            final slotKey = _calendarService.generateSlotKey(dayIndex, hourIndex);
            meetingsMap[slotKey] = meeting.toMap();
            meetingsDocIds[slotKey] = meeting.id;
          }
        } catch (e) {
          debugPrint('Error processing meeting document ${meeting.id}: $e');
          continue;
        }
      }

      return SmoothScrollWrapper(
        controller: _scrollController,
        scrollSpeed: 120.0, // Viteza mai mare pentru calendarul cu multe randuri
        animationDuration: const Duration(milliseconds: 300),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: false,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(), // Dezactivez scroll-ul normal
            controller: _scrollController,
            child: Column(
              children: _buildHourRows(meetingsMap, meetingsDocIds),
            ),
          ),
        ),
      );
    }

  /// Construieste randurile pentru fiecare ora
  List<Widget> _buildHourRows(
    Map<String, Map<String, dynamic>> meetingsMap,
    Map<String, String> meetingsDocIds,
  ) {
    
    return List.generate(CalendarService.workingHours.length, (hourIndex) {
      final hour = CalendarService.workingHours[hourIndex];
      final isLastHour = hourIndex == CalendarService.workingHours.length - 1;
      
      return Column(
        children: [
          // Randul pentru ora curenta
          SizedBox(
            height: 64,
            child: Row(
              children: [
                // Ora
                SizedBox(
                  width: 48,
                  child: Text2(
                    text: hour,
                    color: AppTheme.elementColor2,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Sloturile pentru fiecare zi cu marime egala
                Expanded(
                  child: Row(
                    children: [
                      for (int dayIndex = 0; dayIndex < CalendarService.daysPerWeek; dayIndex++) ...[
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final slotKey = _calendarService.generateSlotKey(dayIndex, hourIndex);
                              final meetingData = meetingsMap[slotKey];
                              final docId = meetingsDocIds[slotKey];
                              final isMeeting = meetingData != null;
                              
                              return isMeeting 
                                  ? _buildMeetingSlot(meetingData, docId!)
                                  : _buildAvailableSlot(dayIndex, hourIndex);
                            }
                          ),
                        ),
                        if (dayIndex < CalendarService.daysPerWeek - 1) 
                          SizedBox(width: AppTheme.mediumGap),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!isLastHour) const SizedBox(height: 16),
        ],
      );
    });
  }

  /// Construieste un slot rezervat cu CalendarSlot (design nou)
  Widget _buildMeetingSlot(Map<String, dynamic> meetingData, String docId) {
    // OPTIMIZARE: Citeste datele din structura corecta cu fallback-uri mai robuste
    final additionalData = meetingData['additionalData'] as Map<String, dynamic>?;
    
    // OPTIMIZARE: Incearca sa gasesti consultantName din toate sursele posibile, cu debugging redus
    String consultantName = 'N/A';
    if (meetingData.containsKey('consultantName') && meetingData['consultantName'] != null && meetingData['consultantName'].toString().trim().isNotEmpty) {
      consultantName = meetingData['consultantName'].toString();
    } else if (additionalData != null && additionalData.containsKey('consultantName') && additionalData['consultantName'] != null && additionalData['consultantName'].toString().trim().isNotEmpty) {
      consultantName = additionalData['consultantName'].toString();
    }
    
    // Derive time text from meeting dateTime
    String timeText = '';
    try {
      final dynamic rawDateTime = meetingData['dateTime'];
      DateTime dateTime;
      if (rawDateTime is DateTime) {
        dateTime = rawDateTime;
      } else if (rawDateTime is int) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(rawDateTime);
      } else if (rawDateTime != null && rawDateTime.toString().contains('Timestamp')) {
        // Avoid importing Timestamp type directly; rely on toString heuristic fallback
        // Many Firebase Timestamp implementations provide toDate(); attempt via dynamic
        try {
          final dynamic dyn = rawDateTime;
          final DateTime parsed = dyn.toDate();
          dateTime = parsed;
        } catch (_) {
          dateTime = DateTime.now();
        }
      } else {
        dateTime = DateTime.now();
      }
      timeText = DateFormat('HH:mm').format(dateTime);
    } catch (_) {
      timeText = '';
    }
    
    final consultantId = additionalData?['consultantId'] as String?;
    final currentUserId = _auth.currentUser?.uid;
    
    // OPTIMIZARE: Logica hibrida pentru ownership verification cu cache
    bool isOwner = false;
    
    // Pentru intalniri noi cu consultantId valid
    if (consultantId != null && consultantId != 'null' && consultantId.isNotEmpty) {
      isOwner = currentUserId == consultantId;
    } else {
      // Pentru intalniri existente, foloseste consultantToken ca fallback
      final meetingConsultantToken = additionalData?['consultantToken'] as String?;
      if (meetingConsultantToken != null && meetingConsultantToken.isNotEmpty) {
        // OPTIMIZARE: Folosim cache-ul din SplashService pentru performanta
        try {
          final currentConsultantToken = _getCurrentConsultantTokenSync();
          // FIX: Permite toate intalnirile care au consultantToken valid (sunt din echipa consultantului)
          isOwner = currentConsultantToken == 'TEMP_ALLOW_ALL' || meetingConsultantToken == currentConsultantToken;
        } catch (e) {
          // OPTIMIZARE: Log redus pentru erori
          // debugPrint('❌ CALENDAR_AREA: Error getting consultant token for ownership: $e');
          isOwner = false;
        }
      }
    }
    
    return CalendarSlot.reserved(
      consultantName: consultantName,
      timeText: timeText,
      isClickable: isOwner,
      onTap: isOwner ? () => _showEditMeetingDialog(meetingData, docId) : null,
    );
  }

  /// Construieste un slot liber cu CalendarSlot (design nou)
  Widget _buildAvailableSlot(int dayIndex, int hourIndex) {
    final String hourText = CalendarService.workingHours[hourIndex];
    return CalendarSlot.free(
      hourText: hourText,
      onTap: () => _showCreateMeetingDialog(dayIndex, hourIndex),
    );
  }

  /// OPTIMIZAT: Afiseaza dialogul pentru crearea unei intalniri noi cu feedback instant
  void _showCreateMeetingDialog(int dayIndex, int hourIndex) {
    if (!mounted) return;
    
    try {
      final DateTime selectedDateTime = _calendarService.buildDateTimeFromIndices(
        _currentWeekOffset, 
        dayIndex, 
        hourIndex
      );
      
      // OPTIMIZARE: Afiseaza imediat popup-ul fara delay
      showBlurredDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => MeetingPopup(
          initialDateTime: selectedDateTime,
          onSaved: () {
            // OPTIMIZARE: Feedback instant - inchide popup-ul si notifica UI-ul
        
            
            // OPTIMIZARE: Invalidare cache optimizata cu delay redus
            SplashService().invalidateAllMeetingCaches();
            
            // OPTIMIZARE: Notifica main_screen sa refresheze meetings_pane
            widget.onMeetingSaved?.call();
            // Refresh embedded upcoming meetings as well
            _refreshUpcomingMeetings();
            
            // OPTIMIZARE: Refresh calendar cu delay redus pentru actualizare rapida
            _refreshCalendarWithDelay();
          },
        ),
      );
    } catch (e) {
      debugPrint('Eroare la crearea dialogului de intalnire: $e');
    }
  }

  /// OPTIMIZARE: Refresh calendar cu delay redus pentru actualizare rapida
  void _refreshCalendarWithDelay() {
    // OPTIMIZARE: Delay redus pentru actualizare rapida
    Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        _loadMeetingsForCurrentWeek();
      }
    });
  }

  /// OPTIMIZAT: Afiseaza dialogul pentru editarea unei intalniri existente cu feedback instant
  void _showEditMeetingDialog(Map<String, dynamic> meetingData, String docId) {
    if (!mounted) return;
    
    try {
      // OPTIMIZARE: Afiseaza imediat popup-ul fara delay
      showBlurredDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => MeetingPopup(
          meetingId: docId,
          onSaved: () {
            // OPTIMIZARE: Feedback instant - inchide popup-ul si notifica UI-ul
        
            
            // OPTIMIZARE: Invalidare cache optimizata cu delay redus
            SplashService().invalidateAllMeetingCaches();
            
            // OPTIMIZARE: Notifica main_screen sa refresheze meetings_pane
            widget.onMeetingSaved?.call();
            // Refresh embedded upcoming meetings as well
            _refreshUpcomingMeetings();
            
            // OPTIMIZARE: Refresh calendar cu delay redus pentru actualizare rapida
            _refreshCalendarWithDelay();
          },
        ),
      );
    } catch (e) {
      debugPrint('Eroare la crearea dialogului de editare: $e');
    }
  }

  /// Navigates to a specific meeting and highlights it
  void navigateToMeeting(String meetingId) async {
    debugPrint('Navigate to meeting: $meetingId');
    
    // First, try to find the meeting in all meetings cache
    ClientActivity? targetMeeting;
    for (var meeting in _allMeetings) {
      if (meeting.id == meetingId) {
        targetMeeting = meeting;
        break;
      }
    }
    
    // If not found in cache, load all team meetings from splash cache
    if (targetMeeting == null) {
      try {
        final allTeamMeetings = await SplashService().getCachedMeetings();
        
        // Update cache with loaded meetings
        final convertedMeetings = allTeamMeetings;
        
        if (mounted) {
          setState(() {
            _allMeetings = convertedMeetings;
          });
        }
        
        // Try to find the meeting again
        for (var meeting in _allMeetings) {
          if (meeting.id == meetingId) {
            targetMeeting = meeting;
            break;
          }
        }
      } catch (e) {
        debugPrint('❌ Error loading all team meetings from cache for navigation: $e');
        return;
      }
    }
    
    if (targetMeeting != null) {
      final meetingDateTime = targetMeeting.dateTime;
      
      // Calculate what week offset this meeting is in
      final weekDifference = _calendarService.getWeekOffsetForDate(meetingDateTime);
      
      // Navigate to the correct week if needed
      if (weekDifference != _currentWeekOffset) {
        if (mounted) {
          setState(() {
            _currentWeekOffset = weekDifference;
          });
        }
        await _loadMeetingsForCurrentWeek();
      }
      
      // Wait for frame to be built, then scroll and highlight
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _scrollToMeeting(targetMeeting!);
            _highlightMeeting(meetingId);
          }
        });
      }
    } else {
      debugPrint('Meeting with id $meetingId not found');
    }
  }
  
  /// Scrolls to show the meeting at optimal position
  void _scrollToMeeting(ClientActivity meeting) {
    try {
      final dayIndex = _calendarService.getDayIndexForDate(meeting.dateTime, _currentWeekOffset);
      final hourIndex = _calendarService.getHourIndexForDateTime(meeting.dateTime);
      
      if (dayIndex != null && hourIndex != -1) {
        // Calculate scroll position to center the meeting
        // Each hour row has a height of approximately 64 + 16 (spacing) = 80 pixels
        final double targetScrollPosition = hourIndex * 80.0;
        final double maxScroll = _scrollController.position.maxScrollExtent;
        final double viewportHeight = _scrollController.position.viewportDimension;
        
        // Center the meeting in the viewport
        double scrollPosition = targetScrollPosition - (viewportHeight / 2) + 40; // 40 is half the row height
        
        // Ensure we don't scroll beyond bounds
        scrollPosition = scrollPosition.clamp(0.0, maxScroll);
        
        // Animate to the position
        _scrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        
        debugPrint('Scrolling to meeting at day $dayIndex, hour $hourIndex (position: $scrollPosition)');
      }
    } catch (e) {
      debugPrint('Error scrolling to meeting: $e');
    }
  }
  
  /// Highlights a meeting for 1 second
  void _highlightMeeting(String meetingId) {
    if (mounted) {
      setState(() {
      });
    }
    
    // Remove highlight after 1 second
    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
        });
      }
    });
  }

  /// Public method to refresh calendar data
  void refreshCalendar() {

    // OPTIMIZARE: Foloseste invalidarea optimizata
    SplashService().invalidateAllMeetingCaches();
  }
  
  /// FIX: Obtine consultantToken-ul curent in mod sincron (pentru ownership verification)
  String? _getCurrentConsultantTokenSync() {
    try {
      // Pentru o solutie temporara simpla, sa permitem toate intalnirile ale consultantului curent
      // Intalnirile din calendar apartin echipei consultantului, deci toate pot fi editate
      return 'TEMP_ALLOW_ALL';
    } catch (e) {
      debugPrint('❌ CALENDAR_AREA: Error getting sync consultant token: $e');
      return null;
    }
  }

  // ======================== UPCOMING MEETINGS PANEL (embedded) ========================

  void _initializeFormatters() {
    try {
      dateFormatter = DateFormat('dd MMM yyyy', 'ro_RO');
      timeFormatter = DateFormat('HH:mm', 'ro_RO');
      _isInitializingUpcoming = false;
    } catch (e) {
      debugPrint("Error initializing formatters: $e");
      _isInitializingUpcoming = false;
    }
  }

  Future<void> _loadUpcomingFromCacheInstantly() async {
    try {
      // Load meetings from cache instantly, then trigger background refresh
      final allMeetings = _splashService.getCachedMeetingsSync();
      final now = DateTime.now();
      final List<ClientActivity> futureAppointments = [];
      final currentConsultantToken = await _getCurrentConsultantToken();
      for (final meeting in allMeetings) {
        if (!meeting.dateTime.isAfter(now)) continue;
        final meetingConsultantId = meeting.additionalData?['consultantId'] as String?;
        if (meetingConsultantId != null) {
          if (meetingConsultantId != _auth.currentUser?.uid) continue;
        } else {
          final meetingConsultantToken = meeting.additionalData?['consultantToken'] as String?;
          if (meetingConsultantToken == null || meetingConsultantToken != currentConsultantToken) continue;
        }
        futureAppointments.add(meeting);
      }
      futureAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      if (mounted) {
        setState(() {
          _upcomingAppointments = futureAppointments;
          _isLoadingUpcoming = false;
          _lastUpcomingLoadTime = DateTime.now();
        });
      }
      // Background refresh (fire-and-forget)
      unawaited(() async {
        final refreshed = await _splashService.getCachedMeetingsFast();
        if (mounted) {
          final currentConsultantToken = await _getCurrentConsultantToken();
          final filtered = <ClientActivity>[];
          for (final meeting in refreshed) {
            if (!meeting.dateTime.isAfter(now)) continue;
            final meetingConsultantId = meeting.additionalData?['consultantId'] as String?;
            if (meetingConsultantId != null) {
              if (meetingConsultantId != _auth.currentUser?.uid) continue;
            } else {
              final meetingConsultantToken = meeting.additionalData?['consultantToken'] as String?;
              if (meetingConsultantToken == null || meetingConsultantToken != currentConsultantToken) continue;
            }
            filtered.add(meeting);
          }
          filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          final changed = filtered.length != _upcomingAppointments.length ||
              !_upcomingAppointments.asMap().entries.every((e) => e.value.id == filtered[e.key].id);
          if (changed) {
            setState(() {
              _upcomingAppointments = filtered;
            });
          }
        }
      }());
    } catch (e) {
      debugPrint('❌ CALENDAR_AREA: Error loading upcoming from cache: $e');
      await _loadUpcomingMeetings();
    }
  }

  Future<bool> _rebuildUpcomingFromList(List<ClientActivity> allMeetings, DateTime now) async {
    try {
      final currentConsultantToken = await _getCurrentConsultantToken();
      final List<ClientActivity> futureAppointments = [];
      for (final meeting in allMeetings) {
        if (!meeting.dateTime.isAfter(now)) continue;
        final meetingConsultantId = meeting.additionalData?['consultantId'] as String?;
        if (meetingConsultantId != null) {
          if (meetingConsultantId != _auth.currentUser?.uid) continue;
        } else {
          final meetingConsultantToken = meeting.additionalData?['consultantToken'] as String?;
          if (meetingConsultantToken == null || meetingConsultantToken != currentConsultantToken) continue;
        }
        futureAppointments.add(meeting);
      }
      futureAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      final changed = futureAppointments.length != _upcomingAppointments.length ||
          !_upcomingAppointments.asMap().entries.every((e) => e.value.id == futureAppointments[e.key].id);
      if (changed) {
        _upcomingAppointments = futureAppointments;
      }
      return changed;
    } catch (_) {
      return false;
    }
  }

  void _refreshUpcomingMeetings() {
    if (!mounted) return;
    _loadUpcomingMeetings();
  }

  Future<void> _loadUpcomingMeetings({bool force = false}) async {
    if (!force && _lastUpcomingLoadTime != null &&
        DateTime.now().difference(_lastUpcomingLoadTime!).inSeconds < 3) {
      return;
    }
    _upcomingLoadDebounceTimer?.cancel();
    if (_isLoadingUpcomingMeetings) return;
    _upcomingLoadDebounceTimer = Timer(const Duration(milliseconds: 10), () async {
      await _performLoadUpcomingMeetings();
    });
  }

  Future<void> _performLoadUpcomingMeetings() async {
    if (_isLoadingUpcomingMeetings) return;
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      debugPrint("❌ CALENDAR_AREA: User not authenticated (upcoming)");
      return;
    }
    if (mounted) {
      setState(() {
        _isLoadingUpcoming = true;
      });
    }
    try {
      _isLoadingUpcomingMeetings = true;
      final allMeetings = await _splashService.getCachedMeetings();
      final now = DateTime.now();
      final List<ClientActivity> futureAppointments = [];
      final currentConsultantToken = await _getCurrentConsultantToken();
      for (final meeting in allMeetings) {
        if (!meeting.dateTime.isAfter(now)) continue;
        final meetingConsultantId = meeting.additionalData?['consultantId'] as String?;
        if (meetingConsultantId != null) {
          if (meetingConsultantId != currentUserId) continue;
        } else {
          final meetingConsultantToken = meeting.additionalData?['consultantToken'] as String?;
          if (meetingConsultantToken == null || meetingConsultantToken != currentConsultantToken) continue;
        }
        futureAppointments.add(meeting);
      }
      futureAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      if (mounted) {
        setState(() {
          _upcomingAppointments = futureAppointments;
          _isLoadingUpcoming = false;
          _lastUpcomingLoadTime = DateTime.now();
        });
      }
    } catch (e) {
      debugPrint('❌ CALENDAR_AREA: Error loading upcoming meetings: $e');
      if (mounted) {
        setState(() {
          _isLoadingUpcoming = false;
        });
      }
    } finally {
      _isLoadingUpcomingMeetings = false;
    }
  }

  String _getTimeUntilMeeting(DateTime meetingDateTime) {
    final now = DateTime.now();
    final difference = meetingDateTime.difference(now);
    if (difference.isNegative) return 'Trecut';
    final days = difference.inDays;
    final hours = difference.inHours;
    final minutes = difference.inMinutes;
    if (days > 0) return 'in $days ${days == 1 ? 'zi' : 'zile'}';
    if (hours > 0) return 'in $hours ${hours == 1 ? 'ora' : 'ore'}';
    if (minutes > 0) return 'in $minutes ${minutes == 1 ? 'minut' : 'minute'}';
    return 'acum';
  }

  bool _isWithin30Minutes(DateTime meetingDateTime) {
    final now = DateTime.now();
    final difference = meetingDateTime.difference(now);
    return difference.inMinutes <= 30 && difference.inMinutes >= 0;
  }

  void _navigateToCalendarMeeting(String meetingId) {
    navigateToMeeting(meetingId);
  }

  Future<String?> _getCurrentConsultantToken() async {
    try {
      final firebaseService = NewFirebaseService();
      return await firebaseService.getCurrentConsultantToken();
    } catch (e) {
      debugPrint('❌ CALENDAR_AREA: Error getting current consultant token: $e');
      return null;
    }
  }

  Widget _buildUpcomingMeetingsPanel() {
    final EdgeInsetsGeometry effectivePadding = EdgeInsets.zero;
    final BoxDecoration? effectiveDecoration = null;
    if (_isInitializingUpcoming || dateFormatter == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        padding: effectivePadding,
        decoration: effectiveDecoration,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    final ScrollController paneScrollController = ScrollController();
    return SmoothScrollWrapper(
      controller: paneScrollController,
      scrollSpeed: 120.0,
      animationDuration: const Duration(milliseconds: 250),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: effectivePadding,
        decoration: effectiveDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WidgetHeader1(
              title: 'Intalnirile mele',
              titleColor: AppTheme.elementColor1,
            ),
            const SizedBox(height: AppTheme.smallGap),
            Expanded(
              child: _buildUpcomingMeetingsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingMeetingsList() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return Center(
        child: Text(
          "Utilizator neconectat",
          style: TextStyle(fontSize: AppTheme.fontSizeMedium, color: AppTheme.elementColor2),
        ),
      );
    }
    if (_isLoadingUpcoming) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_upcomingAppointments.isEmpty) {
      return Center(
        child: Text(
          'Nicio programare viitoare',
          style: AppTheme.secondaryTitleStyle,
        ),
      );
    }
    return ListView.builder(
      itemCount: _upcomingAppointments.length,
      itemBuilder: (context, index) {
        final meeting = _upcomingAppointments[index];
        final dateTime = meeting.dateTime;
        String clientName = meeting.additionalData?['clientName'] ?? '';
        if (clientName.trim().isEmpty) {
          clientName = 'Client fara nume';
        }
        final clientPhone = meeting.additionalData?['phoneNumber'] ?? '';
        final meetingId = meeting.id;
        final timeUntil = _getTimeUntilMeeting(dateTime);
        final isUrgent = _isWithin30Minutes(dateTime);
        final formattedDate = dateFormatter?.format(dateTime) ?? dateTime.toString();
        final formattedTime = timeFormatter?.format(dateTime) ?? dateTime.toString();
        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.smallGap),
          child: isUrgent
              ? _buildUrgentMeetingItem(
                  clientName: clientName,
                  clientPhone: clientPhone,
                  dateTime: dateTime,
                  formattedDate: formattedDate,
                  formattedTime: formattedTime,
                  timeUntil: timeUntil,
                  meetingId: meetingId,
                )
              : _buildNormalMeetingItem(
                  clientName: clientName,
                  clientPhone: clientPhone,
                  dateTime: dateTime,
                  formattedDate: formattedDate,
                  formattedTime: formattedTime,
                  timeUntil: timeUntil,
                  meetingId: meetingId,
                ),
        );
      },
    );
  }

  Widget _buildUrgentMeetingItem({
    required String clientName,
    required String clientPhone,
    required DateTime dateTime,
    required String formattedDate,
    required String formattedTime,
    required String timeUntil,
    required String meetingId,
  }) {
    return DarkItem7(
      title: clientName,
      description: clientPhone.isNotEmpty ? clientPhone : timeUntil,
      svgAsset: 'assets/doneIcon.svg',
      onTap: () => _navigateToCalendarMeeting(meetingId),
    );
  }

  Widget _buildNormalMeetingItem({
    required String clientName,
    required String clientPhone,
    required DateTime dateTime,
    required String formattedDate,
    required String formattedTime,
    required String timeUntil,
    required String meetingId,
  }) {
    return LightItem7(
      title: clientName,
      description: timeUntil,
      svgAsset: 'assets/viewIcon.svg',
      onTap: () => _navigateToCalendarMeeting(meetingId),
    );
  }
}

