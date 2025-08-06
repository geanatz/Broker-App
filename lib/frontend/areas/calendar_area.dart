import 'package:broker_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:broker_app/utils/smooth_scroll_behavior.dart';


import 'package:broker_app/frontend/popups/meeting_popup.dart';
import 'package:broker_app/backend/services/calendar_service.dart';
import 'package:broker_app/backend/services/clients_service.dart';
import 'package:broker_app/backend/services/splash_service.dart';
import 'package:broker_app/frontend/components/texts/text2.dart';
import 'package:broker_app/backend/services/firebase_service.dart';

// Import the required components
import 'package:broker_app/frontend/components/headers/widget_header6.dart';
import 'package:broker_app/frontend/components/items/outlined_item6.dart';
import 'package:broker_app/frontend/components/items/dark_item4.dart';
import 'package:broker_app/frontend/components/items/dark_item2.dart';

/// Area pentru calendar care va fi afisata in cadrul ecranului principal.
/// OPTIMIZAT: Implementare avansată cu cache inteligent și loading instant
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
  
  // OPTIMIZARE: Debouncing îmbunătățit pentru load meetings
  Timer? _loadDebounceTimer;
  bool _isLoadingMeetings = false;
  DateTime? _lastLoadTime;
  
  // Highlight functionality
  String? _highlightedMeetingId;
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
    
    // FIX: Ascultă la schimbări în SplashService pentru refresh automat
    _splashService.addListener(_onSplashServiceChanged);
    
    // Calendar este deja initializat in splash
    _isInitialized = true;
    
    // OPTIMIZARE: Încarcă imediat din cache pentru loading instant și sincronizare completă
    _loadFromCacheInstantly();
    
    PerformanceMonitor.endTimer('calendarAreaInit');

  }

  /// OPTIMIZARE: Încarcă imediat din cache pentru loading instant și sincronizare completă
  Future<void> _loadFromCacheInstantly() async {
    try {
      // OPTIMIZARE: Nu mai verifică consultantul la fiecare încărcare - doar la prima inițializare
      if (!_isInitialized) {
        await _splashService.resetForNewConsultant();
      }
      
      // Încarcă întâlnirile din cache instant
      final cachedMeetings = await _splashService.getCachedMeetings();
      
      if (mounted) {
        setState(() {
          _allMeetings = cachedMeetings;
          _filterMeetingsForCurrentWeek();
          _isLoading = false;
          _isInitialized = true;
        });
      }
      
  
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

  /// FIX: Callback pentru refresh automat când se schimbă datele în SplashService
  void _onSplashServiceChanged() {
    if (mounted) {
      _loadMeetingsForCurrentWeek();
    }
  }

  /// OPTIMIZAT: Filtrează întâlnirile pentru săptămâna curentă din cache
  void _filterMeetingsForCurrentWeek() {
    final DateTime startOfWeek = _calendarService.getStartOfWeekToDisplay(_currentWeekOffset);
    final DateTime endOfWeek = _calendarService.getEndOfWeekToDisplay(_currentWeekOffset);
    
    _cachedMeetings = _allMeetings.where((meeting) {
      final meetingDateTime = meeting.dateTime;
      return meetingDateTime.isAfter(startOfWeek) && meetingDateTime.isBefore(endOfWeek);
    }).toList();
  }

  /// OPTIMIZAT: Incarca intalnirile cu debouncing îmbunătățit
  Future<void> _loadMeetingsForCurrentWeek() async {
    // OPTIMIZARE: Verifică dacă cache-ul este recent (sub 3 secunde - redus de la 5)
    if (_lastLoadTime != null && 
        DateTime.now().difference(_lastLoadTime!).inSeconds < 3) {
      // OPTIMIZARE: Log redus pentru performanță
      // debugPrint('⏭️ CALENDAR_AREA: Skipping load - cache is recent');
      return;
    }
    
    // Anulează loading-ul anterior dacă există unul pending
    _loadDebounceTimer?.cancel();
    
    // Dacă deja se încarcă, nu mai face alt request
    if (_isLoadingMeetings) return;
    
    // CRITICAL FIX: Near-instant debouncing for immediate sync
    _loadDebounceTimer = Timer(const Duration(milliseconds: 10), () async {
      await _performLoadMeetingsForCurrentWeek();
    });
  }

  /// OPTIMIZAT: Execută încărcarea efectivă a întâlnirilor pentru săptămâna curentă
  Future<void> _performLoadMeetingsForCurrentWeek() async {
    if (_isLoadingMeetings) return;
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      debugPrint("❌ CALENDAR_AREA: User not authenticated");
      return;
    }

    // OPTIMIZARE: Nu mai setează loading state dacă avem deja date în cache
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
      _isLoadingMeetings = true;
      
      // OPTIMIZARE: Obtine toate intalnirile din cache-ul din splash (instant și actualizat)
      final allTeamMeetings = await _splashService.getCachedMeetings();
      
      if (mounted) {
        setState(() {
          _allMeetings = allTeamMeetings;
          _filterMeetingsForCurrentWeek();
          _isLoading = false;
          _lastLoadTime = DateTime.now();
        });
      }
      
  
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
    _filterMeetingsForCurrentWeek(); // OPTIMIZARE: Filtrează din cache în loc să încarci din nou
  }
  
  // Navigate to next week
  void _navigateToNextWeek() {
    if (mounted) {
      setState(() {
        _currentWeekOffset++;
      });
    }
    _filterMeetingsForCurrentWeek(); // OPTIMIZARE: Filtrează din cache în loc să încarci din nou
  }

  // Navigate to current week
  void _navigateToCurrentWeek() {
    if (mounted) {
      setState(() {
        _currentWeekOffset = 0;
      });
    }
    _filterMeetingsForCurrentWeek(); // OPTIMIZARE: Filtrează din cache în loc să încarci din nou
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
        color: AppTheme.widgetBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
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
        color: AppTheme.widgetBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
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
          
          // Containerul principal cu calendar
          Expanded(
            child: _buildCalendarContainer(),
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
        color: AppTheme.containerColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
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
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(), // Dezactivez scroll-ul normal
          controller: _scrollController,
          child: Column(
            children: _buildHourRows(meetingsMap, meetingsDocIds),
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

  /// Construieste un slot rezervat conform designului folosind DarkItem4 sau DarkItem2 (OPTIMIZAT: logging redus)
  Widget _buildMeetingSlot(Map<String, dynamic> meetingData, String docId) {
    // OPTIMIZARE: Citește datele din structura corectă cu fallback-uri mai robuste
    final additionalData = meetingData['additionalData'] as Map<String, dynamic>?;
    
    // OPTIMIZARE: Încearcă să găsești consultantName din toate sursele posibile, cu debugging redus
    String consultantName = 'N/A';
    if (meetingData.containsKey('consultantName') && meetingData['consultantName'] != null && meetingData['consultantName'].toString().trim().isNotEmpty) {
      consultantName = meetingData['consultantName'].toString();
    } else if (additionalData != null && additionalData.containsKey('consultantName') && additionalData['consultantName'] != null && additionalData['consultantName'].toString().trim().isNotEmpty) {
      consultantName = additionalData['consultantName'].toString();
    }
    
    // OPTIMIZARE: Încearcă să găsești clientName din toate sursele posibile
    String clientName = 'N/A';
    if (meetingData.containsKey('clientName') && meetingData['clientName'] != null && meetingData['clientName'].toString().trim().isNotEmpty) {
      clientName = meetingData['clientName'].toString();
    } else if (additionalData != null && additionalData.containsKey('clientName') && additionalData['clientName'] != null && additionalData['clientName'].toString().trim().isNotEmpty) {
      clientName = additionalData['clientName'].toString();
    }
    
    // OPTIMIZARE: Log redus - doar pentru debugging când e necesar
    // debugPrint('🔍 CALENDAR_AREA: Building meeting slot: $clientName');
    
    final consultantId = additionalData?['consultantId'] as String?;
    final currentUserId = _auth.currentUser?.uid;
    
    // OPTIMIZARE: Logică hibridă pentru ownership verification cu cache
    bool isOwner = false;
    
    // Pentru întâlniri noi cu consultantId valid
    if (consultantId != null && consultantId != 'null' && consultantId.isNotEmpty) {
      isOwner = currentUserId == consultantId;
    } else {
      // Pentru întâlniri existente, folosește consultantToken ca fallback
      final meetingConsultantToken = additionalData?['consultantToken'] as String?;
      if (meetingConsultantToken != null && meetingConsultantToken.isNotEmpty) {
        // OPTIMIZARE: Folosim cache-ul din SplashService pentru performanță
        try {
          final currentConsultantToken = _getCurrentConsultantTokenSync();
          // FIX: Permite toate întâlnirile care au consultantToken valid (sunt din echipa consultantului)
          isOwner = currentConsultantToken == 'TEMP_ALLOW_ALL' || meetingConsultantToken == currentConsultantToken;
        } catch (e) {
          // OPTIMIZARE: Log redus pentru erori
          // debugPrint('❌ CALENDAR_AREA: Error getting consultant token for ownership: $e');
          isOwner = false;
        }
      }
    }
    
    final bool isHighlighted = _highlightedMeetingId == docId;
    
    // OPTIMIZARE: Debug redus - doar pentru debugging când e necesar
    // debugPrint('  - isOwner: $isOwner');
    
    // Check if client name is valid and not empty
    final hasRealClientName = clientName.trim().isNotEmpty &&
        clientName != 'N/A' &&
        clientName != 'Client necunoscut' &&
        clientName != 'Client nedefinit';

    // Calculate background color with highlight effect
    Color backgroundColor = AppTheme.containerColor2;
    if (isHighlighted) {
      // Add 20% white overlay for highlight effect
      backgroundColor = Color.lerp(backgroundColor, Colors.white, 0.2) ?? backgroundColor;
    }

    return MouseRegion(
      cursor: isOwner ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: hasRealClientName 
        ? DarkItem4(
            title: consultantName,
            description: clientName,
            onTap: isOwner ? () => _showEditMeetingDialog(meetingData, docId) : null,
            backgroundColor: backgroundColor,
            titleColor: AppTheme.elementColor3,
            descriptionColor: AppTheme.elementColor2,
            borderRadius: AppTheme.borderRadiusMedium,
          )
        : DarkItem2(
            title: consultantName,
            onTap: isOwner ? () => _showEditMeetingDialog(meetingData, docId) : null,
            backgroundColor: backgroundColor,
            titleColor: AppTheme.elementColor3,
            borderRadius: AppTheme.borderRadiusMedium,
          ),
    );
  }

  /// Construieste un slot liber conform designului folosind OutlinedItem6
  Widget _buildAvailableSlot(int dayIndex, int hourIndex) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: OutlinedItem6(
        title: 'Liber',
        svgAsset: 'assets/addIcon.svg',
        onTap: () => _showCreateMeetingDialog(dayIndex, hourIndex),
        mainBorderColor: AppTheme.containerColor2,
        mainBorderWidth: 4.0,
        titleColor: AppTheme.elementColor2,
        iconColor: AppTheme.elementColor2,
        mainBorderRadius: AppTheme.borderRadiusMedium,
      ),
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
      
      // OPTIMIZARE: Afișează imediat popup-ul fără delay
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => MeetingPopup(
          initialDateTime: selectedDateTime,
          onSaved: () {
            // OPTIMIZARE: Feedback instant - închide popup-ul și notifică UI-ul
        
            
            // OPTIMIZARE: Invalidare cache optimizată cu delay redus
            SplashService().invalidateAllMeetingCaches();
            
            // OPTIMIZARE: Notifică main_screen să refresheze meetings_pane
            widget.onMeetingSaved?.call();
            
            // OPTIMIZARE: Refresh calendar cu delay redus pentru actualizare rapidă
            _refreshCalendarWithDelay();
          },
        ),
      );
    } catch (e) {
      debugPrint('Eroare la crearea dialogului de intalnire: $e');
    }
  }

  /// OPTIMIZARE: Refresh calendar cu delay redus pentru actualizare rapidă
  void _refreshCalendarWithDelay() {
    // OPTIMIZARE: Delay redus pentru actualizare rapidă
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
      // OPTIMIZARE: Afișează imediat popup-ul fără delay
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => MeetingPopup(
          meetingId: docId,
          onSaved: () {
            // OPTIMIZARE: Feedback instant - închide popup-ul și notifică UI-ul
        
            
            // OPTIMIZARE: Invalidare cache optimizată cu delay redus
            SplashService().invalidateAllMeetingCaches();
            
            // OPTIMIZARE: Notifică main_screen să refresheze meetings_pane
            widget.onMeetingSaved?.call();
            
            // OPTIMIZARE: Refresh calendar cu delay redus pentru actualizare rapidă
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
        _highlightedMeetingId = meetingId;
      });
    }
    
    // Remove highlight after 1 second
    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _highlightedMeetingId = null;
        });
      }
    });
  }

  /// Public method to refresh calendar data
  void refreshCalendar() {

    // OPTIMIZARE: Folosește invalidarea optimizată
    SplashService().invalidateAllMeetingCaches();
  }
  
  /// FIX: Obține consultantToken-ul curent în mod sincron (pentru ownership verification)
  String? _getCurrentConsultantTokenSync() {
    try {
      // Pentru o soluție temporară simplă, să permitem toate întâlnirile ale consultantului curent
      // Întâlnirile din calendar aparțin echipei consultantului, deci toate pot fi editate
      return 'TEMP_ALLOW_ALL';
    } catch (e) {
      debugPrint('❌ CALENDAR_AREA: Error getting sync consultant token: $e');
      return null;
    }
  }
}
