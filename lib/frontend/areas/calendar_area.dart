import 'package:mat_finance/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:mat_finance/utils/smooth_scroll_behavior.dart';
import 'package:google_fonts/google_fonts.dart';


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
  
  // Public getter pentru currentWeekOffset
  int get currentWeekOffset => _currentWeekOffset;
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
    
    // OPTIMIZARE: Refresh instant din cache pentru sincronizare completa
    final instant = _splashService.getCachedMeetingsSync();
    if (instant.isNotEmpty) {
      setState(() {
        _allMeetings = instant;
        _filterMeetingsForCurrentWeek();
      });
    }
    // Then trigger a forced background refresh to ensure latest data (fire-and-forget)
    unawaited(_loadMeetingsForCurrentWeek(force: true));
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
  
  /// Public methods pentru navigare din main_screen
  void navigateToPreviousWeek() => _navigateToPreviousWeek();
  void navigateToNextWeek() => _navigateToNextWeek();
  void navigateToCurrentWeek() => _navigateToCurrentWeek();

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
      height: double.infinity,
      padding: const EdgeInsets.only(top: AppTheme.largeGap),
      decoration: BoxDecoration(
        gradient: AppTheme.areaColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header cu zilele saptamanii
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.largeGap),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List.generate(CalendarService.daysPerWeek, (index) {
                  final List<String> weekDates = _calendarService.getWeekDates(_currentWeekOffset);
                  return Expanded(
                    child: SizedBox(
                      width: 249.60,
                      height: 24,
                      child: Text(
                        '${CalendarService.workingDays[index]} ${weekDates[index]}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: AppTheme.elementColor1,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          // Calendar grid cu sloturile
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.largeGap),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
              ),
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int dayIndex = 0; dayIndex < CalendarService.daysPerWeek; dayIndex++) ...[
                        Expanded(
                          child: Container(
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildDayColumn(dayIndex),
                            ),
                          ),
                        ),
                        if (dayIndex < CalendarService.daysPerWeek - 1) 
                          SizedBox(width: AppTheme.mediumGap),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Gap intre calendar si calendar switch
          const SizedBox(height: AppTheme.mediumGap),
          // Switch săptămâni pentru calendar
          _buildWeekSwitch(),
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
          
          // Grid-ul cu sloturile (fara coloana cu orele)
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
          // Zilele saptamanii folosind Text2 (fara spatiu pentru coloana cu orele)
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

  /// Construieste grid-ul cu sloturile (fara StreamBuilder si fara coloana cu orele)
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

  /// Construieste randurile pentru fiecare ora (fara coloana cu orele)
  List<Widget> _buildHourRows(
    Map<String, Map<String, dynamic>> meetingsMap,
    Map<String, String> meetingsDocIds,
  ) {
    
    return List.generate(CalendarService.workingHours.length, (hourIndex) {
      final hour = CalendarService.workingHours[hourIndex];
      final isLastHour = hourIndex == CalendarService.workingHours.length - 1;
      
      return Column(
        children: [
          // Randul pentru ora curenta (fara coloana cu orele)
          SizedBox(
            height: 64,
            child: Row(
              children: [
                // Sloturile pentru fiecare zi cu marime egala (fara coloana cu orele)
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

  /// Construieste o coloana pentru o zi specifica cu toate sloturile
  List<Widget> _buildDayColumn(int dayIndex) {
    return List.generate(CalendarService.workingHours.length, (hourIndex) {
      final hour = CalendarService.workingHours[hourIndex];
      final isLastHour = hourIndex == CalendarService.workingHours.length - 1;
      
      // Cauta intalnirea pentru aceasta zi si ora
      final slotKey = _calendarService.generateSlotKey(dayIndex, hourIndex);
      final meetingData = _getMeetingDataForSlot(slotKey);
      final docId = _getMeetingDocIdForSlot(slotKey);
      final isMeeting = meetingData != null;
      
      return Column(
        children: [
          // Slot pentru ora curenta
          GestureDetector(
            onTap: isMeeting 
                ? () => _showEditMeetingDialog(meetingData!, docId!)
                : () => _showCreateMeetingDialog(dayIndex, hourIndex),
            child: Container(
              width: double.infinity,
              height: 64,
              padding: isMeeting ? const EdgeInsets.symmetric(horizontal: 16, vertical: 0) : null,
              decoration: ShapeDecoration(
                color: isMeeting ? AppTheme.backgroundColor2 : const Color(0xFFE1DCD6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadows: isMeeting ? [
                  BoxShadow(
                    color: Color(0x0C503E29),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  )
                ] : null,
              ),
              child: isMeeting 
                  ? _buildMeetingSlotContent(meetingData!, docId!)
                  : _buildFreeSlotContent(hour),
            ),
          ),
          if (!isLastHour) const SizedBox(height: 16),
        ],
      );
    });
  }

  /// Obtine datele intalnirii pentru un slot specific
  Map<String, dynamic>? _getMeetingDataForSlot(String slotKey) {
    for (var meeting in _cachedMeetings) {
      try {
        final dateTime = meeting.dateTime;
        final dayIndex = _calendarService.getDayIndexForDate(dateTime, _currentWeekOffset);
        final hourIndex = _calendarService.getHourIndexForDateTime(dateTime);
        
        if (dayIndex != null && hourIndex != -1) {
          final meetingSlotKey = _calendarService.generateSlotKey(dayIndex, hourIndex);
          if (meetingSlotKey == slotKey) {
            return meeting.toMap();
          }
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  /// Obtine document ID-ul intalnirii pentru un slot specific
  String? _getMeetingDocIdForSlot(String slotKey) {
    for (var meeting in _cachedMeetings) {
      try {
        final dateTime = meeting.dateTime;
        final dayIndex = _calendarService.getDayIndexForDate(dateTime, _currentWeekOffset);
        final hourIndex = _calendarService.getHourIndexForDateTime(dateTime);
        
        if (dayIndex != null && hourIndex != -1) {
          final meetingSlotKey = _calendarService.generateSlotKey(dayIndex, hourIndex);
          if (meetingSlotKey == slotKey) {
            return meeting.id;
          }
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  /// Construieste continutul pentru un slot cu intalnire
  Widget _buildMeetingSlotContent(Map<String, dynamic> meetingData, String docId) {
    final additionalData = meetingData['additionalData'] as Map<String, dynamic>?;
    
    String consultantName = 'N/A';
    if (meetingData.containsKey('consultantName') && meetingData['consultantName'] != null && meetingData['consultantName'].toString().trim().isNotEmpty) {
      consultantName = meetingData['consultantName'].toString();
    } else if (additionalData != null && additionalData.containsKey('consultantName') && additionalData['consultantName'] != null && additionalData['consultantName'].toString().trim().isNotEmpty) {
      consultantName = additionalData['consultantName'].toString();
    }
    
    String timeText = '';
    try {
      final dynamic rawDateTime = meetingData['dateTime'];
      DateTime dateTime;
      if (rawDateTime is DateTime) {
        dateTime = rawDateTime;
      } else if (rawDateTime is int) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(rawDateTime);
      } else if (rawDateTime != null && rawDateTime.toString().contains('Timestamp')) {
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
    
    bool isOwner = false;
    if (consultantId != null && consultantId != 'null' && consultantId.isNotEmpty) {
      isOwner = currentUserId == consultantId;
    } else {
      final meetingConsultantToken = additionalData?['consultantToken'] as String?;
      if (meetingConsultantToken != null && meetingConsultantToken.isNotEmpty) {
        try {
          final currentConsultantToken = _getCurrentConsultantTokenSync();
          isOwner = currentConsultantToken == 'TEMP_ALLOW_ALL' || meetingConsultantToken == currentConsultantToken;
        } catch (e) {
          isOwner = false;
        }
      }
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            consultantName,
            style: GoogleFonts.outfit(
              color: AppTheme.elementColor2,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            timeText,
            textAlign: TextAlign.right,
            style: GoogleFonts.outfit(
              color: AppTheme.elementColor1,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  /// Construieste continutul pentru un slot liber
  Widget _buildFreeSlotContent(String hourText) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          hourText,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: const Color(0xFFCAC7C3),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Construieste switch-ul între săptămâni în partea de jos conform designului
  Widget _buildWeekSwitch() {
    final String weekRange = _calendarService.getDateInterval(_currentWeekOffset);
    
    return Container(
      width: double.infinity,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
                      Container(
              width: 480,
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: ShapeDecoration(
                color: AppTheme.backgroundColor1,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Buton pentru săptămâna anterioară
                Expanded(
                  child: GestureDetector(
                    onTap: _navigateToPreviousWeek,
                    child: Container(
                      decoration: ShapeDecoration(
                        color: AppTheme.backgroundColor2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chevron_left,
                            color: AppTheme.elementColor1,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Text cu intervalul săptămânii
                SizedBox(
                  width: 149.33,
                  height: 24,
                                        child: Text2(
                        text: weekRange,
                        color: AppTheme.elementColor2,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(width: 8),
                // Buton pentru săptămâna următoare
                Expanded(
                  child: GestureDetector(
                    onTap: _navigateToNextWeek,
                    child: Container(
                      decoration: ShapeDecoration(
                        color: AppTheme.backgroundColor2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chevron_right,
                            color: AppTheme.elementColor1,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
}

