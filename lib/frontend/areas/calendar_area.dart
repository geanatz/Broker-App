import 'package:mat_finance/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';


import 'package:mat_finance/frontend/popups/meeting_popup.dart';
import 'package:mat_finance/backend/services/calendar_service.dart';
import 'package:mat_finance/backend/services/clients_service.dart';
import 'package:mat_finance/backend/services/splash_service.dart';
import 'package:mat_finance/frontend/components/texts/text2.dart';
import 'package:mat_finance/backend/services/firebase_service.dart';

// Import the required components
import 'package:mat_finance/frontend/components/dialog_utils.dart';
import 'package:intl/intl.dart';

/// Direction for calendar week navigation animations
enum AnimationDirection {
  previous, // Slide from left to right
  next,     // Slide from right to left
  current   // No animation or custom
}

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

class CalendarAreaState extends State<CalendarArea> with SingleTickerProviderStateMixin {
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

  // Animation controller for smooth week transitions - optimized for performance
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;

  // Animation state tracking
  bool _isAnimating = false;

  // Previous and current week data for smooth transitions
  int _previousWeekOffset = 0;

  // Animation state for showing previous/current slots during transition
  final ValueNotifier<bool> _showTransition = ValueNotifier(false);

  // Animation state notifier to reduce rebuilds
  final ValueNotifier<AnimationDirection> _currentAnimationDirection = ValueNotifier(AnimationDirection.next);

  // Advanced caching system for maximum performance
  final Map<int, Widget> _weekWidgetCache = {};
  final Map<int, List<ClientActivity>> _meetingCache = {};
  final Map<int, int> _meetingCountCache = {};

  // Performance tracking
  int _rebuildCount = 0;
  int _cacheHits = 0;
  int _cacheMisses = 0;

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

    // Initialize animation controller - optimized for speed and smoothness
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 280), // Faster animation
      vsync: this,
    );

    // Create optimized slide animation with better curve
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.fastOutSlowIn, // More responsive curve
    ));



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
    _slideAnimationController.dispose();
    _splashService.removeListener(_onSplashServiceChanged); // FIX: cleanup listener
    super.dispose();
  }

  /// FIX: Callback pentru refresh automat cand se schimba datele in SplashService
  void _onSplashServiceChanged() {
    if (!mounted) return;

    // OPTIMIZARE: Refresh instant din cache pentru sincronizare completa
    final instant = _splashService.getCachedMeetingsSync();
    if (instant.isNotEmpty) {
      // Clear cache when data changes to ensure consistency
      _clearAllCaches();
      setState(() {
        _allMeetings = instant;
        _filterMeetingsForCurrentWeek();
        // Pre-cache common weeks for smooth navigation
        _preCacheCommonWeeks();
      });
      debugPrint('CALENDAR_DATA_UPDATE: Refreshed ${instant.length} meetings, caches cleared');
    }
    // Then trigger a forced background refresh to ensure latest data (fire-and-forget)
    unawaited(_loadMeetingsForCurrentWeek(force: true));
  }



  /// Ultra-optimized filtering with advanced caching
  void _filterMeetingsForCurrentWeek() {
    final sw = Stopwatch()..start();

    // Check cache first for maximum performance
    if (_meetingCache.containsKey(_currentWeekOffset)) {
      _cachedMeetings = _meetingCache[_currentWeekOffset]!;
      _cacheHits++;
      sw.stop();
      return;
    }

    // Cache miss - perform filtering
    _cacheMisses++;
    final DateTime startOfWeek = _calendarService.getStartOfWeekToDisplay(_currentWeekOffset);
    final DateTime endOfWeek = _calendarService.getEndOfWeekToDisplay(_currentWeekOffset);

    _cachedMeetings = _allMeetings.where((meeting) {
      final meetingDateTime = meeting.dateTime;
      return meetingDateTime.isAfter(startOfWeek) && meetingDateTime.isBefore(endOfWeek);
    }).toList();

    // Cache the result for future use
    _meetingCache[_currentWeekOffset] = _cachedMeetings;
    _meetingCountCache[_currentWeekOffset] = _cachedMeetings.length;

    sw.stop();
  }

  /// Pre-cache meetings for common week offsets to eliminate future cache misses
  void _preCacheCommonWeeks() {
    final currentOffsets = [_currentWeekOffset - 1, _currentWeekOffset, _currentWeekOffset + 1];
    for (final offset in currentOffsets) {
      if (!_meetingCache.containsKey(offset)) {
        final originalOffset = _currentWeekOffset;
        _currentWeekOffset = offset;
        _filterMeetingsForCurrentWeek();
        _currentWeekOffset = originalOffset;
      }
    }
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
          // Keep existing cache on error
        });
      }
    } finally {
      _isLoadingMeetings = false;
    }
  }

  // Navigate to previous week with slide animation
  void _navigateToPreviousWeek() {
    if (_isAnimating) return;
    _startWeekTransition(_currentWeekOffset - 1, AnimationDirection.previous);
  }

  // Navigate to next week with slide animation
  void _navigateToNextWeek() {
    if (_isAnimating) return;
    _startWeekTransition(_currentWeekOffset + 1, AnimationDirection.next);
  }

  // Navigate to current week with animation
  void _navigateToCurrentWeek() {
    if (_isAnimating) return;

    _startWeekTransition(0, AnimationDirection.current);
  }

  // Start week transition animation
  void _startWeekTransition(int newOffset, AnimationDirection direction) {
    if (_isAnimating) return;

    _isAnimating = true;
    _currentAnimationDirection.value = direction;
    _previousWeekOffset = _currentWeekOffset;

    // Configure animation based on direction
    Offset startOffset, endOffset;
    switch (direction) {
      case AnimationDirection.previous:
        // Current slots slide right and out, new slots slide in from left
        startOffset = Offset.zero;      // Current slots start at center
        endOffset = const Offset(1.0, 0.0);    // Current slots slide right and out
        break;
      case AnimationDirection.next:
        // Current slots slide left and out, new slots slide in from right
        startOffset = Offset.zero;      // Current slots start at center
        endOffset = const Offset(-1.0, 0.0);   // Current slots slide left and out
        break;
      case AnimationDirection.current:
        // For current week, simple fade transition
        startOffset = Offset.zero;
        endOffset = Offset.zero;
        break;
    }

    // Update slide animation for current slots (exiting)
    _slideAnimation = Tween<Offset>(
      begin: startOffset,
      end: endOffset,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOut,
    ));

    // No fade animation - pure slide for maximum performance

    // Enable transition state with ultra-optimized caching
    _showTransition.value = true;
    _previousWeekOffset = _currentWeekOffset;
    _currentWeekOffset = newOffset;
    _filterMeetingsForCurrentWeek();

    // Pre-cache both weeks for instant animation
    _getCachedWeekWidget(_currentWeekOffset);
    _getCachedWeekWidget(_previousWeekOffset);

    // Start animation with optimized cleanup
    final animationStart = DateTime.now();
    _slideAnimationController.forward(from: 0.0).then((_) {
      if (mounted) {
        final animationDuration = DateTime.now().difference(animationStart).inMilliseconds;
        _showTransition.value = false;
        _isAnimating = false;
        // Clear previous week cache after animation completes
        _weekWidgetCache.remove(_previousWeekOffset);
        debugPrint('CALENDAR_TRANSITION: COMPLETED offset=$newOffset duration=${animationDuration}ms');
        _logPerformanceReport();
      }
    });
  }
  
  /// Public methods pentru navigare din main_screen
  void navigateToPreviousWeek() => _navigateToPreviousWeek();
  void navigateToNextWeek() => _navigateToNextWeek();
  void navigateToCurrentWeek() => _navigateToCurrentWeek();

  /// Ultra-optimized widget caching with reduced logging for performance
  Widget _getCachedWeekWidget(int weekOffset) {
    _rebuildCount++;

    // Check if widget is already cached - optimized without logging during animation
    if (_weekWidgetCache.containsKey(weekOffset)) {
      return _weekWidgetCache[weekOffset]!;
    }

    // Cache miss - create and cache the widget
    final weekWidget = Row(
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
                children: _buildDayColumnForWeek(dayIndex, weekOffset),
              ),
            ),
          ),
          if (dayIndex < CalendarService.daysPerWeek - 1)
            SizedBox(width: AppTheme.mediumGap),
        ],
      ],
    );

    // Cache the widget for future use
    _weekWidgetCache[weekOffset] = weekWidget;

    return weekWidget;
  }

  /// Clear all caches when data changes
  void _clearAllCaches() {
    final beforeSize = _weekWidgetCache.length + _meetingCache.length;
    _weekWidgetCache.clear();
    _meetingCache.clear();
    _meetingCountCache.clear();
    _cacheHits = 0;
    _cacheMisses = 0;
    _rebuildCount = 0;
    debugPrint('CALENDAR_CACHE: ALL_CACHES_CLEARED - Cleared $beforeSize items, Performance reset');
  }

  /// Performance report
  void _logPerformanceReport() {
    final hitRate = _cacheHits + _cacheMisses > 0 ? (_cacheHits / (_cacheHits + _cacheMisses)) * 100 : 0;
    debugPrint('CALENDAR_PERFORMANCE: hits=$_cacheHits misses=$_cacheMisses hitRate=${hitRate.toStringAsFixed(1)}% rebuilds=$_rebuildCount');
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
    _calendarService.getDateInterval(_currentWeekOffset);

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
                          fontSize: 15,
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
          // Calendar grid cu sloturile si tranzitii
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
                  child: RepaintBoundary(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _showTransition,
                      builder: (context, showTransition, child) {
                        // Calculate required height for calendar
                        final calendarHeight = CalendarService.workingHours.length * 80.0;

                        if (showTransition) {
                          // During transition, show both old and new slots with proper sizing
                          return RepaintBoundary(
                            child: SizedBox(
                              height: calendarHeight,
                              child: Stack(
                                children: [
                                  // New slots coming in (bottom layer) - optimized with RepaintBoundary
                                  RepaintBoundary(
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: _currentAnimationDirection.value == AnimationDirection.previous
                                            ? const Offset(-1.0, 0.0)  // Enter from left
                                            : const Offset(1.0, 0.0),   // Enter from right
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: _slideAnimationController,
                                        curve: Curves.fastOutSlowIn,
                                      )),
                                      child: _getCachedWeekWidget(_currentWeekOffset),
                                    ),
                                  ),
                                  // Old slots going out (top layer) - optimized with RepaintBoundary
                                  RepaintBoundary(
                                    child: SlideTransition(
                                      position: _slideAnimation,
                                      child: _getCachedWeekWidget(_previousWeekOffset),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          // Normal state - show only current week slots with caching
                          return _getCachedWeekWidget(_currentWeekOffset);
                        }
                      },
                    ),
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







  /// Construieste o coloana pentru o zi specifica si saptamana specifica cu toate sloturile
  List<Widget> _buildDayColumnForWeek(int dayIndex, int weekOffset) {
    return List.generate(CalendarService.workingHours.length, (hourIndex) {
      final hour = CalendarService.workingHours[hourIndex];
      final isLastHour = hourIndex == CalendarService.workingHours.length - 1;

      // Cauta intalnirea pentru aceasta zi si ora in saptamana specificata
      final slotKey = _calendarService.generateSlotKey(dayIndex, hourIndex);
      final meetingData = _getMeetingDataForSlotInWeek(slotKey, weekOffset);
      final docId = _getMeetingDocIdForSlotInWeek(slotKey, weekOffset);
      final isMeeting = meetingData != null;

      return Column(
        children: [
          // Slot pentru ora curenta
          _buildSlotWithHoverForWeek(dayIndex, hourIndex, hour, isMeeting, meetingData, docId, isLastHour, weekOffset),
          if (!isLastHour) const SizedBox(height: 16),
        ],
      );
    });
  }



  /// Construieste un slot cu hover behavior pentru saptamana specificata
  Widget _buildSlotWithHoverForWeek(
    int dayIndex,
    int hourIndex,
    String hour,
    bool isMeeting,
    Map<String, dynamic>? meetingData,
    String? docId,
    bool isLastHour,
    int weekOffset
  ) {
    return _HoverableSlot(
      dayIndex: dayIndex,
      hourIndex: hourIndex,
      hour: hour,
      isMeeting: isMeeting,
      meetingData: meetingData,
      docId: docId,
      isLastHour: isLastHour,
      weekOffset: weekOffset,
      onEditMeeting: _showEditMeetingDialog,
      onCreateMeeting: _showCreateMeetingDialogWithWeek,
    );
  }



  /// Obtine datele intalnirii pentru un slot specific in saptamana specificata
  Map<String, dynamic>? _getMeetingDataForSlotInWeek(String slotKey, int weekOffset) {
    for (var meeting in _allMeetings) {
      try {
        final dateTime = meeting.dateTime;
        final dayIndex = _calendarService.getDayIndexForDate(dateTime, weekOffset);
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



  /// Obtine document ID-ul intalnirii pentru un slot specific in saptamana specificata
  String? _getMeetingDocIdForSlotInWeek(String slotKey, int weekOffset) {
    for (var meeting in _allMeetings) {
      try {
        final dateTime = meeting.dateTime;
        final dayIndex = _calendarService.getDayIndexForDate(dateTime, weekOffset);
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
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _navigateToPreviousWeek,
                      child: Container(
                        decoration: ShapeDecoration(
                          color: AppTheme.backgroundColor2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          shadows: AppTheme.standardShadow,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chevron_left,
                              color: AppTheme.elementColor3,
                              size: 24,
                            ),
                          ],
                        ),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(width: 8),
                // Buton pentru săptămâna următoare
                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _navigateToNextWeek,
                      child: Container(
                        decoration: ShapeDecoration(
                          color: AppTheme.backgroundColor2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          shadows: AppTheme.standardShadow,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chevron_right,
                              color: AppTheme.elementColor3,
                              size: 24,
                            ),
                          ],
                        ),
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





  /// OPTIMIZAT: Afiseaza dialogul pentru crearea unei intalniri noi in saptamana specificata cu feedback instant
  void _showCreateMeetingDialogWithWeek(int dayIndex, int hourIndex, int weekOffset) {
    if (!mounted) return;

    try {
      final DateTime selectedDateTime = _calendarService.buildDateTimeFromIndices(
        weekOffset,
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
  
}

/// Widget pentru slot-uri cu hover behavior
class _HoverableSlot extends StatefulWidget {
  final int dayIndex;
  final int hourIndex;
  final String hour;
  final bool isMeeting;
  final Map<String, dynamic>? meetingData;
  final String? docId;
  final bool isLastHour;
  final int weekOffset;
  final Function(Map<String, dynamic>, String) onEditMeeting;
  final Function(int, int, int) onCreateMeeting; // dayIndex, hourIndex, weekOffset

  const _HoverableSlot({
    required this.dayIndex,
    required this.hourIndex,
    required this.hour,
    required this.isMeeting,
    required this.meetingData,
    required this.docId,
    required this.isLastHour,
    required this.weekOffset,
    required this.onEditMeeting,
    required this.onCreateMeeting,
  });

  @override
  State<_HoverableSlot> createState() => _HoverableSlotState();
}

class _HoverableSlotState extends State<_HoverableSlot> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.isMeeting 
            ? () => widget.onEditMeeting(widget.meetingData!, widget.docId!)
            : () => widget.onCreateMeeting(widget.dayIndex, widget.hourIndex, widget.weekOffset),
        child: Container(
          width: double.infinity,
          height: 64,
          padding: widget.isMeeting ? const EdgeInsets.symmetric(horizontal: 16, vertical: 0) : null,
          decoration: ShapeDecoration(
            color: widget.isMeeting ? AppTheme.backgroundColor2 : const Color(0xFFE1DCD6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadows: (widget.isMeeting || _isHovered) ? AppTheme.standardShadow : null,
          ),
          child: widget.isMeeting 
              ? _buildMeetingSlotContent(widget.meetingData!, widget.docId!)
              : _buildFreeSlotContent(widget.hour, _isHovered),
        ),
      ),
    );
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
              fontSize: 17,
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
              fontSize: 15,
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
  Widget _buildFreeSlotContent(String hourText, bool isHovered) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          hourText,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: isHovered ? AppTheme.elementColor1 : const Color(0xFFCAC7C3),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

