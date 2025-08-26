import 'package:mat_finance/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';


import 'package:mat_finance/frontend/popups/meeting_popup.dart';
import 'package:mat_finance/backend/services/calendar_service.dart';
import 'package:mat_finance/backend/services/clients_service.dart';
import 'package:mat_finance/backend/services/splash_service.dart';

import 'package:mat_finance/backend/services/firebase_service.dart';
import 'package:mat_finance/backend/services/consultant_service.dart';

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

  /// STATIC METHOD: Pre-load calendar data for instant access from splash screen
  static Future<void> preLoadCalendarData() async {
    debugPrint('🚀 CALENDAR_STATIC: Starting static pre-loading for splash screen');

    try {
      // Create a temporary state instance for pre-loading
      final tempState = CalendarAreaState();
      tempState._preLoadedFromSplash = true;

      // Initialize minimal state for pre-loading
      tempState._calendarService = CalendarService();
      tempState._splashService = SplashService();
      tempState._consultantService = ConsultantService();

      // Perform the pre-loading
      await tempState._preLoadAllDataForInstantAccess();

      debugPrint('✅ CALENDAR_STATIC: Static pre-loading completed successfully');
    } catch (e) {
      debugPrint('❌ CALENDAR_STATIC: Static pre-loading failed: $e');
    }
  }
}

class CalendarAreaState extends State<CalendarArea> with SingleTickerProviderStateMixin {
  // Services
  late final CalendarService _calendarService;
  late final SplashService _splashService;
  late final ConsultantService _consultantService;
  
  // Firebase references
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Calendar state
  int _currentWeekOffset = 0;
  final ValueNotifier<int> _currentWeekOffsetNotifier = ValueNotifier<int>(0);

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

  // OPTIMIZARE CRITICĂ: Cache persistent pentru rezultatele de filtrare - elimină refiltrarea repetitivă
  final Map<String, Map<int, List<ClientActivity>>> _persistentFilterCache = {};
  String _lastFilterKey = '';

  // Performance tracking
  int _rebuildCount = 0;
  int _cacheHits = 0;
  int _cacheMisses = 0;

  // OPTIMIZATION: Timer for monitoring (if needed)
  Timer? _coalesceTimer;

  // CRITICAL FIX: Cache monitoring and auto-recovery
  Timer? _cacheMonitorTimer;
  bool _isMonitoringCache = false;

  // Track if pre-loaded from splash screen
  bool _preLoadedFromSplash = false;

  // Consultant colors cache
  Map<String, int?> _consultantColorsCache = {};
  bool _isLoadingConsultantColors = false;

  @override
  void initState() {
    super.initState();
    
    // Initializeaza serviciile
    _calendarService = CalendarService();
    _splashService = SplashService();
    _consultantService = ConsultantService();
    
    // Adauga listener pentru schimbarile de culori
    _consultantService.addListener(_onConsultantColorsChanged);
    
    // Adauga listener pentru schimbarile din SplashService
    _splashService.addListener(_onSplashServiceChanged);
    
    // Initializeaza animatiile - OPTIMIZED for smooth feel
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200), // SMOOTH: from 80ms to 200ms for better UX
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOut,
    ));

    // CRITICAL OPTIMIZATION: Pre-load everything for instant calendar access (only if not already pre-loaded from splash)
    if (!_preLoadedFromSplash) {
      _preLoadAllDataForInstantAccess();
    } else {
      debugPrint('🚀 CALENDAR_OPTIMIZATION: Skipping pre-load - already done from splash screen');
      // Still start monitoring for any issues
      _startCacheMonitoring();
    }

    PerformanceMonitor.endTimer('calendarAreaInit');

  }

  /// Callback pentru schimbarile de culori ale consultantilor - CRITICAL FIX
  void _onConsultantColorsChanged() {
    if (!mounted) return;

    debugPrint('🎨 CALENDAR_COLORS: Consultant colors changed, updating cache');

    // Actualizeaza cache-ul local cu noile culori - IMEDIAT pentru a fi disponibil
    final newColors = _consultantService.getCachedColors();
    if (newColors.isNotEmpty) {
      // CRITICAL FIX: Update cache immediately for instant availability
      _consultantColorsCache = newColors;
      debugPrint('🎨 CALENDAR_COLORS: Cache updated IMMEDIATELY with ${newColors.length} colors: $newColors');

      // Then trigger UI update with coalesced setState
      _coalescedSetState(() {
        // Cache already updated above, just trigger rebuild
        debugPrint('🎨 CALENDAR_COLORS: UI rebuild triggered after cache update');
      });
    } else {
      debugPrint('🎨 CALENDAR_COLORS: No new colors to update');
    }
  }

  /// Incarca culorile consultantilor din echipa curenta - LAZY LOADED
  Future<void> _loadConsultantColors() async {
    if (_isLoadingConsultantColors) return;
    if (_consultantColorsCache.isNotEmpty) return; // Already loaded

    _isLoadingConsultantColors = true;

    final stopwatch = Stopwatch()..start();
    // Loading consultant colors

    try {
      final consultantColors = await _consultantService.getTeamConsultantColorsByName();
      if (mounted) {
        // CRITICAL FIX: Update cache immediately for instant availability
        _consultantColorsCache = consultantColors;

        stopwatch.stop();
        // Consultant colors loaded successfully

        // Then trigger UI update with coalesced setState
        _coalescedSetState(() {
          // Cache already updated above, just trigger rebuild
        });
      }
    } catch (e) {
      stopwatch.stop();
      debugPrint('❌ CALENDAR_COLORS: _loadConsultantColors - LAZY error: $e, timeMs=${stopwatch.elapsedMilliseconds}');
    } finally {
      _isLoadingConsultantColors = false;
    }
  }

  /// Ensure consultant colors are loaded when needed - SYNC VERSION FOR IMMEDIATE USE
  void _ensureConsultantColorsLoadedSync() {
    // If cache is empty and not loading, trigger async load but don't wait
    if (_consultantColorsCache.isEmpty && !_isLoadingConsultantColors) {
      _loadConsultantColors(); // Fire-and-forget for now
    }
  }

  /// PUBLIC: Pre-load ALL data for instant calendar access (can be called from splash screen)
  Future<void> preLoadAllDataForInstantAccess() async {
    _preLoadedFromSplash = true;
    await _preLoadAllDataForInstantAccess();
  }

  /// CRITICAL OPTIMIZATION: Pre-load ALL data for instant calendar access
  Future<void> _preLoadAllDataForInstantAccess() async {
    final totalSw = Stopwatch()..start();
    debugPrint('🚀 CALENDAR_OPTIMIZATION: Starting pre-load of all data for instant access');

    try {
      // Step 1: Load consultant colors FIRST (critical for slot rendering)
      final colorsSw = Stopwatch()..start();
      await _loadConsultantColors();
      colorsSw.stop();
      // Consultant colors loaded

      // Step 2: Load meetings data instantly from cache
      final meetingsSw = Stopwatch()..start();
      _loadFromCacheInstantly(); // Now synchronous - no await needed
      meetingsSw.stop();
      // Meetings data loaded

      // Step 3: Pre-cache ALL relevant weeks for instant navigation
      final cacheSw = Stopwatch()..start();
      _preCacheAllRelevantWeeks();
      cacheSw.stop();
      // All weeks pre-cached

      // Step 4: Ultra pre-cache for maximum instant access
      final ultraCacheSw = Stopwatch()..start();
      _ultraPreCache();
      ultraCacheSw.stop();
      // Ultra pre-cache completed

      // Step 5: Pre-build all week widgets for instant rendering
      final widgetSw = Stopwatch()..start();
      _preBuildAllWeekWidgets();
      widgetSw.stop();
      // All widgets pre-built

      // Step 6: Start cache monitoring for auto-recovery
      _startCacheMonitoring();

      // Step 7: Force immediate data verification after pre-load
      _checkAndFixDataBeforeBuild();

      totalSw.stop();
      debugPrint('✅ CALENDAR_OPTIMIZATION: Pre-load completed - Calendar ready for instant access!');

    } catch (e) {
      totalSw.stop();
      debugPrint('❌ CALENDAR_OPTIMIZATION: Pre-load failed: $e, time: ${totalSw.elapsedMilliseconds}ms');
      // Fallback: Continue with basic loading and monitoring
      _loadFromCacheInstantly(); // Now synchronous
      _startCacheMonitoring();
      _checkAndFixDataBeforeBuild();
    }
  }

  /// CRITICAL FIX: Start cache monitoring for auto-recovery
  void _startCacheMonitoring() {
    if (_isMonitoringCache) return;

    _isMonitoringCache = true;
    // Starting cache monitoring

    // Monitor every 2 seconds
    _cacheMonitorTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        _isMonitoringCache = false;
        return;
      }

      _checkAndFixCacheIssues();
    });
  }

  /// CRITICAL FIX: Check and fix cache issues automatically
  void _checkAndFixCacheIssues() {
    bool needsRebuild = false;

    // Issue 1: Check if we have data but current week shows empty
    if (_allMeetings.isNotEmpty && _cachedMeetings.isEmpty) {
      debugPrint('🔧 CALENDAR_MONITOR: Data exists but current week is empty - forcing filtering');
      _filterMeetingsForCurrentWeek();
      needsRebuild = true;
    }

    // Issue 2: Check if cache is completely empty but should have data
    if (_allMeetings.isEmpty && _meetingCache.isEmpty) {
      debugPrint('🔧 CALENDAR_MONITOR: No data in any cache - triggering refresh');
      _loadFromCacheInstantly(); // Fire and forget
      return; // Don't continue if we're refreshing
    }

    // Issue 3: Check if consultant colors are missing
    if (_consultantColorsCache.isEmpty && !_isLoadingConsultantColors) {
      debugPrint('🔧 CALENDAR_MONITOR: Consultant colors missing - reloading');
      _loadConsultantColors(); // Fire and forget
      return;
    }

    // Issue 4: Check if current week widget is missing
    if (!_weekWidgetCache.containsKey(_currentWeekOffset)) {
      debugPrint('🔧 CALENDAR_MONITOR: Current week widget missing - rebuilding');
      _getCachedWeekWidget(_currentWeekOffset);
      needsRebuild = true;
    }

    // Issue 5: Check for data inconsistencies (meetings exist but not showing)
    if (_allMeetings.isNotEmpty && _cachedMeetings.isEmpty && _meetingCache.isEmpty) {
      debugPrint('🔧 CALENDAR_MONITOR: Critical inconsistency detected - forcing complete refresh');
      _forceEmergencyDataRefresh();
      return;
    }

    // Force rebuild if we fixed something
    if (needsRebuild && mounted) {
      debugPrint('🔧 CALENDAR_MONITOR: Forcing UI rebuild after cache fix');
      _coalescedSetState(() {
        // Force rebuild to show fixed data
      });
    }

    // Issue 6: Check cache performance and clean up if needed
    _checkCachePerformance();
  }

  /// CRITICAL FIX: Force emergency data refresh for critical inconsistencies
  void _forceEmergencyDataRefresh() {
    debugPrint('🚨 CALENDAR_EMERGENCY: Starting emergency data refresh');

    // Clear all caches
    _clearAllCaches();
    _calendarService.clearAllCache();

    // Force complete data reload
    unawaited(_forceCompleteDataReload());

    // Reset internal state
    _cachedMeetings = [];
    _allMeetings = [];

    debugPrint('🚨 CALENDAR_EMERGENCY: Emergency refresh initiated');
  }

  /// CRITICAL FIX: Check cache performance and optimize
  void _checkCachePerformance() {
    // Check if persistent cache is getting too large
    if (_persistentFilterCache.length > 20) {
      debugPrint('🔧 CALENDAR_MAINTENANCE: Persistent cache too large (${_persistentFilterCache.length}) - cleaning up');
      _persistentFilterCache.clear();
      _lastFilterKey = '';
    }

    // Check cache hit rate
    final totalRequests = _cacheHits + _cacheMisses;
    if (totalRequests > 100) {
      final hitRate = (_cacheHits / totalRequests) * 100;
      if (hitRate < 50) {
        debugPrint('⚠️ CALENDAR_PERFORMANCE: Low cache hit rate: ${hitRate.toStringAsFixed(1)}% - consider cache optimization');
      } else {
        debugPrint('✅ CALENDAR_PERFORMANCE: Good cache hit rate: ${hitRate.toStringAsFixed(1)}%');
      }
    }
  }

  /// ULTRA AGGRESSIVE: Pre-cache ALL weeks for ZERO loading
  void _preCacheAllRelevantWeeks() {
    final weeks = [-6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6]; // Maximum range
    // Pre-caching weeks for instant access

    final originalOffset = _currentWeekOffset;
    final startTime = DateTime.now();

    for (final weekOffset in weeks) {
      if (!_meetingCache.containsKey(weekOffset)) {
        _currentWeekOffset = weekOffset;
        _filterMeetingsForCurrentWeek();
      }
    }

    _currentWeekOffset = originalOffset;
    final duration = DateTime.now().difference(startTime).inMilliseconds;
    debugPrint('✅ CALENDAR_INSTANT: All ${weeks.length} weeks pre-cached in ${duration}ms');
  }

  /// CRITICAL: Pre-cache even more aggressively - cache all possible future weeks
  void _ultraPreCache() {
    final futureWeeks = [7, 8, 9, 10, 11, 12]; // Future weeks user might visit
    final originalOffset = _currentWeekOffset;

    for (final weekOffset in futureWeeks) {
      if (!_meetingCache.containsKey(weekOffset)) {
        _currentWeekOffset = weekOffset;
        _filterMeetingsForCurrentWeek();
      }
    }

    _currentWeekOffset = originalOffset;
    // Future weeks pre-cached
  }

  /// Pre-build all week widgets for instant rendering
  void _preBuildAllWeekWidgets() {
    final weeks = [-2, -1, 0, 1, 2]; // Core weeks that user is likely to visit
    // Pre-building widgets for weeks

    for (final weekOffset in weeks) {
      if (!_weekWidgetCache.containsKey(weekOffset)) {
        _getCachedWeekWidget(weekOffset);
        // Widget pre-built for week $weekOffset
      }
    }
  }



  /// ULTRA FAST: Immediate setState with zero delay
  void _immediateSetState(VoidCallback callback) {
    // Cancel any pending operations
    _coalesceTimer?.cancel();

    if (mounted) {
      // Execute immediately - no timer, no delay
      setState(callback);
    }
  }

  /// LEGACY: Keep for compatibility but use immediate instead
  void _coalescedSetState(VoidCallback callback) {
    // For non-critical updates, still use immediate for instant feel
    _immediateSetState(callback);
  }

  /// CRITICAL OPTIMIZATION: Load from cache INSTANTLY - NO ASYNC, NO DELAY
  void _loadFromCacheInstantly() {
    final totalSw = Stopwatch()..start();

    try {
      // CRITICAL FIX: Only reset consultant once, not on every load
      if (!_isInitialized) {
        // Do this async but don't wait - fire and forget
        _splashService.resetForNewConsultant(); // Fire and forget
      }

      // ULTRA FAST: Get data synchronously - NO ASYNC DELAY
      final cachedMeetings = _splashService.getCachedMeetingsSync();

      // ULTRA FAST: Update state immediately
      _allMeetings = cachedMeetings;
      _filterMeetingsForCurrentWeek();
      _isInitialized = true;

      // Force immediate rebuild for instant display
      if (mounted) {
        _immediateSetState(() {
          debugPrint('⚡ CALENDAR_INSTANT: Immediate state update after cache load');
        });
      }

      totalSw.stop();
      // Cache loaded successfully

      // BACKGROUND: Trigger refresh only if needed - fire and forget
      if (cachedMeetings.isEmpty) {
        _backgroundDataRefresh(); // Fire and forget
      }

    } catch (e) {
      debugPrint('❌ CALENDAR_INSTANT: Error in instant cache load: $e');
      // Fallback: Try emergency data load
      _emergencyDataLoad();
    }
  }

  /// CRITICAL: Background data refresh - fire and forget
  Future<void> _backgroundDataRefresh() async {
    try {
      final refreshed = await _splashService.getCachedMeetingsFast();
      if (mounted && refreshed.isNotEmpty && refreshed.length != _allMeetings.length) {
        debugPrint('🔄 CALENDAR_BACKGROUND: Background refresh found new data (${refreshed.length} meetings)');
        _updateCalendarWithData(refreshed);
      }
    } catch (e) {
      debugPrint('⚠️ CALENDAR_BACKGROUND: Background refresh failed: $e');
    }
  }

  /// CRITICAL: Emergency data load for when everything fails
  void _emergencyDataLoad() {
    debugPrint('🚨 CALENDAR_EMERGENCY: Starting emergency data load');

    // Try to get any available data immediately
    final emergencyData = _splashService.getCachedMeetingsSync();
    if (emergencyData.isNotEmpty) {
      debugPrint('✅ CALENDAR_EMERGENCY: Emergency data found (${emergencyData.length} meetings)');
      _updateCalendarWithData(emergencyData);
      return;
    }

    // Last resort: Clear everything and try again
    debugPrint('🚨 CALENDAR_EMERGENCY: No data found - clearing caches and retrying');
    _clearAllCaches();
    unawaited(_forceCompleteDataReload());
  }



  @override
  void dispose() {
    _refreshTimer?.cancel();
    _highlightTimer?.cancel();
    _loadDebounceTimer?.cancel();
    _cacheMonitorTimer?.cancel(); // CRITICAL FIX: Clean up cache monitor
    _scrollController.dispose();
    _slideAnimationController.dispose();
    _currentWeekOffsetNotifier.dispose();
    _splashService.removeListener(_onSplashServiceChanged);
    _consultantService.removeListener(_onConsultantColorsChanged);
    super.dispose();
  }

  /// CRITICAL FIX: Callback pentru refresh automat cand se schimba datele in SplashService - ENHANCED
  void _onSplashServiceChanged() {
    if (!mounted) return;

    debugPrint('🔄 CALENDAR_DATA_UPDATE: SplashService data changed, refreshing calendar');

    // CRITICAL FIX: Multiple fallback strategies for data loading
    _refreshDataWithFallbacks();
  }

  /// CRITICAL FIX: Refresh data with multiple fallback strategies
  void _refreshDataWithFallbacks() {
    // Strategy 1: Try instant sync from cache
    final instant = _splashService.getCachedMeetingsSync();
    if (instant.isNotEmpty) {
      debugPrint('✅ CALENDAR_DATA_UPDATE: Strategy 1 - Instant sync successful (${instant.length} meetings)');
      _updateCalendarWithData(instant);
      return;
    }

    // Strategy 2: Force refresh from SplashService
    debugPrint('🔄 CALENDAR_DATA_UPDATE: Strategy 2 - Forcing refresh from SplashService');
    unawaited(SplashService().invalidateMeetingsCacheAndRefresh().then((_) {
      // After refresh, try to get data again
      final refreshed = SplashService().getCachedMeetingsSync();
      if (refreshed.isNotEmpty) {
        debugPrint('✅ CALENDAR_DATA_UPDATE: Strategy 2 - Refresh successful (${refreshed.length} meetings)');
        _updateCalendarWithData(refreshed);
        return;
      }

      // Strategy 3: Ultimate fallback - force reload from Firebase
      debugPrint('🔄 CALENDAR_DATA_UPDATE: Strategy 3 - Ultimate fallback - force Firebase reload');
      unawaited(_forceCompleteDataReload());
    }));
  }

  /// ULTRA FAST: Update calendar with new data - ZERO DELAY
  void _updateCalendarWithData(List<ClientActivity> data) {
    final updateSw = Stopwatch()..start();

    // CRITICAL: Only clear caches if data actually changed significantly
    final dataChanged = data.length != _allMeetings.length;
    if (dataChanged) {
      _clearAllCaches();
      _calendarService.clearAllCache();
    }

    // Update data immediately
    _allMeetings = data;

    // Force filtering for current week - this should be instant now
    _filterMeetingsForCurrentWeek();

    // Only pre-cache if data actually changed
    if (dataChanged) {
      _preCacheAllRelevantWeeks();
      _ultraPreCache();
      _backgroundPreCache();
    }

    // ULTRA FAST: Immediate UI update
    if (mounted) {
      _immediateSetState(() {
        debugPrint('⚡ CALENDAR_UPDATE: Instant UI update after data refresh');
      });
    }

    updateSw.stop();
    debugPrint('✅ CALENDAR_DATA_UPDATE: Successfully updated with ${data.length} meetings in ${updateSw.elapsedMilliseconds}ms');
  }

  /// CRITICAL FIX: Force complete data reload from Firebase as last resort
  Future<void> _forceCompleteDataReload() async {
    try {
      debugPrint('🔄 CALENDAR_DATA_UPDATE: Forcing complete data reload from Firebase');

      // Force a complete refresh
      await SplashService().invalidateMeetingsCacheAndRefresh();

      // Wait a bit for data to propagate
      await Future.delayed(const Duration(milliseconds: 500));

      // Try to get the data
      final finalData = SplashService().getCachedMeetingsSync();
      if (finalData.isNotEmpty) {
        debugPrint('✅ CALENDAR_DATA_UPDATE: Complete reload successful (${finalData.length} meetings)');
        _updateCalendarWithData(finalData);
      } else {
        debugPrint('⚠️ CALENDAR_DATA_UPDATE: Complete reload returned no data - this is unexpected');
      }
    } catch (e) {
      debugPrint('❌ CALENDAR_DATA_UPDATE: Complete reload failed: $e');
    }
  }



  /// ULTRA FAST filtering with maximum caching - SUB 1MS TARGET
  void _filterMeetingsForCurrentWeek() {
    final sw = Stopwatch()..start();

    // CRITICAL OPTIMIZATION: Early exit if no data
    if (_allMeetings.isEmpty) {
      _cachedMeetings = [];
      sw.stop();
      return;
    }

    // ULTRA FAST CACHE: Generate cache key instantly
    final currentFilterKey = '${_allMeetings.length}_${_allMeetings.hashCode}_$_currentWeekOffset';

    // LEVEL 1 CACHE: Persistent cache - FASTEST access
    if (_lastFilterKey == currentFilterKey && _persistentFilterCache.containsKey(currentFilterKey)) {
      final weekCache = _persistentFilterCache[currentFilterKey]!;
      if (weekCache.containsKey(_currentWeekOffset)) {
        _cachedMeetings = weekCache[_currentWeekOffset]!;
        _cacheHits++;
        sw.stop();
        return; // SUCCESS - Under 1ms
      }
    }

    // LEVEL 2 CACHE: Normal cache - Still very fast
    if (_meetingCache.containsKey(_currentWeekOffset)) {
      _cachedMeetings = _meetingCache[_currentWeekOffset]!;
      _cacheHits++;
      // Save to persistent cache for future
      _saveToPersistentCache(currentFilterKey, _currentWeekOffset, _cachedMeetings);
      sw.stop();
      return; // SUCCESS - Under 1ms
    }

    // LAST RESORT: Actual filtering - Only when absolutely necessary
    _cacheMisses++;
    _performActualFiltering(currentFilterKey);
    sw.stop();
  }

  /// CRITICAL: Perform actual filtering with maximum optimization
  void _performActualFiltering(String filterKey) {
    try {
      // CRITICAL OPTIMIZATION: Pre-calculate week boundaries once
      final DateTime startOfWeek = _calendarService.getStartOfWeekToDisplay(_currentWeekOffset);
      final DateTime endOfWeek = _calendarService.getEndOfWeekToDisplay(_currentWeekOffset);

      // ULTRA FAST FILTERING: Use optimized where clause
      _cachedMeetings = _allMeetings.where((meeting) {
        final meetingDateTime = meeting.dateTime;
        return meetingDateTime.isAfter(startOfWeek) && meetingDateTime.isBefore(endOfWeek);
      }).toList();

      // CRITICAL: Cache results immediately for future use
      _meetingCache[_currentWeekOffset] = _cachedMeetings;
      _meetingCountCache[_currentWeekOffset] = _cachedMeetings.length;
      _saveToPersistentCache(filterKey, _currentWeekOffset, _cachedMeetings);

      // SUCCESS: We found meetings
      if (_cachedMeetings.isNotEmpty && mounted) {
        // Force immediate rebuild - but only if we actually found data
        _immediateSetState(() {
          debugPrint('⚡ CALENDAR_FILTER: Instant rebuild after finding ${_cachedMeetings.length} meetings');
        });
      }

    } catch (e) {
      debugPrint('❌ CALENDAR_FILTER_ERROR: $e');
      _cachedMeetings = [];
    }
  }

  /// Salvează rezultatul în cache-ul persistent pentru acces ultra-rapid
  void _saveToPersistentCache(String filterKey, int weekOffset, List<ClientActivity> meetings) {
    if (!_persistentFilterCache.containsKey(filterKey)) {
      _persistentFilterCache[filterKey] = {};
    }
    _persistentFilterCache[filterKey]![weekOffset] = List.from(meetings);
    _lastFilterKey = filterKey;

    // Curățăm cache-ul persistent dacă devine prea mare (peste 50 de intrări)
    if (_persistentFilterCache.length > 50) {
      _persistentFilterCache.clear();
      debugPrint('CALENDAR_CACHE: Persistent cache cleared due to size limit');
    }
  }



  /// Advanced background pre-caching for instant navigation - FIRE AND FORGET
  void _backgroundPreCache() {
    // OPTIMIZATION: Cache additional weeks in background without blocking UI
    Future.microtask(() async {
      final backgroundOffsets = [_currentWeekOffset - 2, _currentWeekOffset + 2];
      for (final offset in backgroundOffsets) {
        if (!_meetingCache.containsKey(offset)) {
          final tempOffset = _currentWeekOffset;
          _currentWeekOffset = offset;
          _filterMeetingsForCurrentWeek();
          _getCachedWeekWidget(offset);
          _currentWeekOffset = tempOffset;
        }
      }
    });
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
    
    // CRITICAL FIX: Ultra-instant debouncing for immediate sync
    _loadDebounceTimer = Timer(const Duration(milliseconds: 1), () async {
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

    // OPTIMIZATION: Remove unnecessary setState during loading

    try {
      final totalSw = Stopwatch()..start();
      _isLoadingMeetings = true;
      
      // OPTIMIZARE: Obtine toate intalnirile din cache-ul din splash (instant si actualizat)
      final fetchSw = Stopwatch()..start();
      final allTeamMeetings = await _splashService.getCachedMeetings();
      fetchSw.stop();
      final filterSw = Stopwatch()..start();
      
      if (mounted) {
        _coalescedSetState(() {
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

    // Actualizeaza notifier-ul pentru a declansa reconstructia week switch-ului
    _currentWeekOffsetNotifier.value = newOffset;

    // Sterge cache-ul pentru saptamanile afectate
    _calendarService.clearWeekCache(newOffset);
    if (_previousWeekOffset != newOffset) {
      _calendarService.clearWeekCache(_previousWeekOffset);
    }

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

  /// Ultra-optimized widget caching with advanced performance features - CRITICAL FIX
  Widget _getCachedWeekWidget(int weekOffset) {
    _rebuildCount++;

    // Check if widget is already cached with current data signature
    if (_weekWidgetCache.containsKey(weekOffset)) {
      final cachedWidget = _weekWidgetCache[weekOffset]!;
      // OPTIMIZATION: Widget-ul este cache-uit și poate fi reutilizat
      return cachedWidget;
    }

    // Cache miss - create and cache the widget with optimized structure
    final weekWidget = RepaintBoundary(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int dayIndex = 0; dayIndex < CalendarService.daysPerWeek; dayIndex++) ...[
            Expanded(
              child: RepaintBoundary(
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
            ),
            if (dayIndex < CalendarService.daysPerWeek - 1)
              SizedBox(width: AppTheme.mediumGap),
          ],
        ],
      ),
    );

    // Cache the widget for future use
    _weekWidgetCache[weekOffset] = weekWidget;

    return weekWidget;
  }

  /// Clear all caches when data changes - ENHANCED with persistent cache
  void _clearAllCaches() {
    final beforeSize = _weekWidgetCache.length + _meetingCache.length + _persistentFilterCache.length;
    _weekWidgetCache.clear();
    _meetingCache.clear();
    _meetingCountCache.clear();
    _persistentFilterCache.clear(); // CRITICAL: Clear persistent cache too
    _lastFilterKey = ''; // Reset filter key
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
    // CRITICAL FIX: Check and fix data immediately before building
    _checkAndFixDataBeforeBuild();

    // CRITICAL OPTIMIZATION: Always show calendar instantly - NO LOADING EVER
    return _buildCalendarWidget();
  }

    /// ULTRA FAST: Check and fix data issues immediately before building UI
  void _checkAndFixDataBeforeBuild() {
    // CRITICAL OPTIMIZATION: Minimize checks for maximum speed

    // Issue 1: Data exists but current week is empty - fix immediately
    if (_allMeetings.isNotEmpty && _cachedMeetings.isEmpty) {
      // ULTRA FAST: Use direct filtering - should be instant now
      _filterMeetingsForCurrentWeek();
      return; // Success - no need for further checks
    }

    // Issue 2: No data at all - trigger emergency refresh (rare case)
    if (_allMeetings.isEmpty && _meetingCache.isEmpty) {
      _emergencyDataLoad(); // Fire and forget
      return;
    }

    // Issue 3: Complete cache failure - reset and retry (very rare)
    if (_allMeetings.isNotEmpty && _cachedMeetings.isEmpty && _meetingCache.isEmpty) {
      _clearAllCaches();
      _filterMeetingsForCurrentWeek();
      return;
    }

    // SUCCESS: No issues found - calendar should display instantly
  }

  /// Construieste header-ul calendarului cu zilele saptamanii si datele corespunzatoare
  Widget _buildCalendarHeader() {
    return Container(
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
    );
  }



  /// Construieste widget-ul principal pentru calendar conform designului Figma
  Widget _buildCalendarWidget() {
    _calendarService.getDateInterval(_currentWeekOffset);

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.areaColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Content-ul principal (calendar)
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header cu zilele saptamanii - se reconstruiește când se schimbă week offset-ul
              ValueListenableBuilder<int>(
                valueListenable: _currentWeekOffsetNotifier,
                builder: (context, weekOffset, child) {
                  return _buildCalendarHeader();
                },
              ),
              // Gap dintre header si sloturi
              const SizedBox(height: 16),
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
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                          child: Container(
                            width: double.infinity,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(),
                            padding: const EdgeInsets.only(bottom: 64),
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
              ),
            ],
          ),
          // Calendar switch ca overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: ValueListenableBuilder<int>(
                valueListenable: _currentWeekOffsetNotifier,
                builder: (context, weekOffset, child) {
                  return _buildWeekSwitch();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }







  /// Construieste o coloana pentru o zi specifica si saptamana specifica cu toate sloturile - OPTIMIZED
  List<Widget> _buildDayColumnForWeek(int dayIndex, int weekOffset) {
    // CRITICAL FIX: Ensure consultant colors are loaded synchronously for immediate use
    _ensureConsultantColorsLoadedSync();

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
          // Slot pentru ora curenta - OPTIMIZED with pre-calculated colors
          _buildSlotWithHoverForWeek(dayIndex, hourIndex, hour, isMeeting, meetingData, docId, isLastHour, weekOffset, consultantColors: _consultantColorsCache),
          if (!isLastHour) const SizedBox(height: 16),
        ],
      );
    });
  }



  /// Construieste un slot cu hover behavior pentru saptamana specificata - OPTIMIZED
  Widget _buildSlotWithHoverForWeek(
    int dayIndex,
    int hourIndex,
    String hour,
    bool isMeeting,
    Map<String, dynamic>? meetingData,
    String? docId,
    bool isLastHour,
    int weekOffset, {
    required Map<String, int?> consultantColors,
  }) {
    // CRITICAL FIX: Pre-calculăm culoarea consultantului cu logică robustă
    Color? preCalculatedColor;
    Color? preCalculatedStrokeColor;
    String? consultantName;

    if (isMeeting && meetingData != null) {
      final additionalData = meetingData['additionalData'] as Map<String, dynamic>?;

      // Extragem numele consultantului cu fallback-uri multiple
      if (meetingData.containsKey('consultantName') && meetingData['consultantName'] != null) {
        consultantName = meetingData['consultantName'].toString().trim();
      } else if (additionalData != null && additionalData.containsKey('consultantName') && additionalData['consultantName'] != null) {
        consultantName = additionalData['consultantName'].toString().trim();
      }

      // Dacă avem numele consultantului, încercăm să obținem culoarea
      if (consultantName != null && consultantName.isNotEmpty) {
        // Verificăm în cache-ul curent
        if (consultantColors.containsKey(consultantName)) {
          final colorIndex = consultantColors[consultantName];
          if (colorIndex != null && colorIndex >= 1 && colorIndex <= 10) {
            preCalculatedColor = AppTheme.getPrimaryColor(colorIndex);
            preCalculatedStrokeColor = AppTheme.getSecondaryColor(colorIndex);
          }
        } else {
          // Fallback: Verificăm în cache-ul global al consultantService
          final globalColors = _consultantService.getCachedColors();
          if (globalColors.containsKey(consultantName)) {
            final colorIndex = globalColors[consultantName];
            if (colorIndex != null && colorIndex >= 1 && colorIndex <= 10) {
              preCalculatedColor = AppTheme.getPrimaryColor(colorIndex);
              preCalculatedStrokeColor = AppTheme.getSecondaryColor(colorIndex);
            }
          }
        }
      }
    }

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
      consultantColors: consultantColors,
      // OPTIMIZATION: Pass pre-calculated colors to avoid recomputation
      preCalculatedColor: preCalculatedColor,
      preCalculatedStrokeColor: preCalculatedStrokeColor,
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
      width: 432,
      height: 48,
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: AppTheme.backgroundColor2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Buton pentru săptămâna anterioară
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _navigateToPreviousWeek,
                    child: Container(
                      width: 128,
                      height: 32,
                      decoration: ShapeDecoration(
                        color: AppTheme.backgroundColor3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        shadows: [
                          BoxShadow(
                            color: Color(0x14503E29),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/left_outlined.svg',
                            colorFilter: ColorFilter.mode(
                              AppTheme.elementColor3,
                              BlendMode.srcIn,
                            ),
                            width: 24,
                            height: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Text cu intervalul săptămânii
                Container(
                  width: 144,
                  height: 32,
                  alignment: Alignment.center,
                  child: Text(
                    weekRange,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF7C7A77), /* light-blue-text-2 */
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Buton pentru săptămâna următoare
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _navigateToNextWeek,
                    child: Container(
                      width: 128,
                      height: 32,
                      decoration: ShapeDecoration(
                        color: AppTheme.backgroundColor3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        shadows: [
                          BoxShadow(
                            color: Color(0x14503E29),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/right_outlined.svg',
                            colorFilter: ColorFilter.mode(
                              AppTheme.elementColor3,
                              BlendMode.srcIn,
                            ),
                            width: 24,
                            height: 24,
                          ),
                        ],
                      ),
                    ),
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


            // ULTRA FAST: Immediate cache invalidation
            SplashService().invalidateAllMeetingCaches();

            // Notify main_screen instantly
            widget.onMeetingSaved?.call();

            // ULTRA FAST: Refresh immediately without delay
            _refreshCalendarInstantly();
          },
        ),
      );
    } catch (e) {
      debugPrint('Eroare la crearea dialogului de intalnire: $e');
    }
  }

  /// ULTRA FAST: Refresh calendar instantly without any delay
  void _refreshCalendarInstantly() {
    // CRITICAL OPTIMIZATION: Immediate refresh for instant updates
    if (mounted) {
      // Use coalesced setState for instant UI update
      _coalescedSetState(() {
        // Just trigger a rebuild - data will be refreshed automatically
        // by the listeners and cache invalidation
      });
    }
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
        
            
            // ULTRA FAST: Immediate cache invalidation
            SplashService().invalidateAllMeetingCaches();

            // Notify main_screen instantly
            widget.onMeetingSaved?.call();

            // ULTRA FAST: Refresh immediately
            _refreshCalendarInstantly();
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
          _coalescedSetState(() {
            _currentWeekOffset = weekDifference;
            _currentWeekOffsetNotifier.value = weekDifference;
            // Sterge cache-ul pentru noua saptamana
            _calendarService.clearWeekCache(weekDifference);
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
  
  /// Highlights a meeting for 1 second - OPTIMIZED
  void _highlightMeeting(String meetingId) {
    if (mounted) {
      _immediateSetState(() {
        // Force immediate update for highlight
      });
    }

    // Remove highlight after 1 second
    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        _immediateSetState(() {
          // Force immediate update to remove highlight
        });
      }
    });
  }

  /// Public method to refresh calendar data - ULTRA FAST
  void refreshCalendar() {
    // ULTRA FAST: Immediate refresh for instant updates
    SplashService().invalidateAllMeetingCaches();

    // Trigger immediate UI update
    _refreshCalendarInstantly();
  }
  
}

  /// Widget pentru slot-uri cu hover behavior - OPTIMIZED
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
  final Map<String, int?> consultantColors;
  // OPTIMIZATION: Pre-calculated colors to avoid recomputation
  final Color? preCalculatedColor;
  final Color? preCalculatedStrokeColor;

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
    required this.consultantColors,
    this.preCalculatedColor,
    this.preCalculatedStrokeColor,
  });

  @override
  State<_HoverableSlot> createState() => _HoverableSlotState();
}

class _HoverableSlotState extends State<_HoverableSlot> {
  bool _isHovered = false;

  /// Obtine culoarea consultantului pentru acest slot - OPTIMIZED with pre-calculated colors
  Color _getConsultantColor() {
    // CRITICAL OPTIMIZATION: Use pre-calculated color if available
    if (widget.preCalculatedColor != null) {
      return widget.preCalculatedColor!;
    }

    if (widget.meetingData == null) return AppTheme.backgroundColor2;

    final additionalData = widget.meetingData!['additionalData'] as Map<String, dynamic>?;

    String consultantName = 'N/A';
    if (widget.meetingData!.containsKey('consultantName') && widget.meetingData!['consultantName'] != null && widget.meetingData!['consultantName'].toString().trim().isNotEmpty) {
      consultantName = widget.meetingData!['consultantName'].toString();
    } else if (additionalData != null && additionalData.containsKey('consultantName') && additionalData['consultantName'] != null && additionalData['consultantName'].toString().trim().isNotEmpty) {
      consultantName = additionalData['consultantName'].toString();
    }

    // Cauta culoarea consultantului in cache
    final colorIndex = widget.consultantColors[consultantName];

    // Log pentru monitorizarea accesului la culori - REDUCED for performance
    if (colorIndex != null && colorIndex >= 1 && colorIndex <= 10) {
      return AppTheme.getPrimaryColor(colorIndex);
    }

    // Fallback la culoarea implicita
    return AppTheme.backgroundColor2;
  }

  /// Obtine strokeColor al consultantului pentru acest slot - OPTIMIZED with pre-calculated colors
  Color _getConsultantStrokeColor() {
    // CRITICAL OPTIMIZATION: Use pre-calculated stroke color if available
    if (widget.preCalculatedStrokeColor != null) {
      return widget.preCalculatedStrokeColor!;
    }

    if (widget.meetingData == null) return AppTheme.backgroundColor3;

    final additionalData = widget.meetingData!['additionalData'] as Map<String, dynamic>?;

    String consultantName = 'N/A';
    if (widget.meetingData!.containsKey('consultantName') && widget.meetingData!['consultantName'] != null && widget.meetingData!['consultantName'].toString().trim().isNotEmpty) {
      consultantName = widget.meetingData!['consultantName'].toString();
    } else if (additionalData != null && additionalData.containsKey('consultantName') && additionalData['consultantName'] != null && additionalData['consultantName'].toString().trim().isNotEmpty) {
      consultantName = additionalData['consultantName'].toString();
    }

    // Cauta culoarea consultantului in cache
    final colorIndex = widget.consultantColors[consultantName];

    if (colorIndex != null && colorIndex >= 1 && colorIndex <= 10) {
      return AppTheme.getSecondaryColor(colorIndex);
    }

    // Fallback la culoarea implicita
    return AppTheme.backgroundColor3;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true), // Keep immediate for hover
      onExit: (_) => setState(() => _isHovered = false), // Keep immediate for hover
      child: GestureDetector(
        onTap: widget.isMeeting 
            ? () => widget.onEditMeeting(widget.meetingData!, widget.docId!)
            : () => widget.onCreateMeeting(widget.dayIndex, widget.hourIndex, widget.weekOffset),
        child: Container(
          width: double.infinity,
          height: 64,
          padding: widget.isMeeting ? const EdgeInsets.symmetric(horizontal: 24, vertical: 0) : null,
          decoration: ShapeDecoration(
            color: widget.isMeeting
                ? _getConsultantColor()
                : (_isHovered ? AppTheme.backgroundColor1 : const Color(0xFFE5E1DC)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: widget.isMeeting ? BorderSide(
                color: _getConsultantStrokeColor(),
                width: 4.0,
              ) : BorderSide.none,
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
              fontWeight: FontWeight.w600,
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
            color: isHovered ? AppTheme.elementColor2 : const Color(0xFFCAC7C3),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

