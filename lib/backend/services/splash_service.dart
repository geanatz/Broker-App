import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import 'package:broker_app/backend/services/calendar_service.dart';
import 'package:broker_app/backend/services/clients_service.dart';
import 'package:broker_app/backend/services/form_service.dart';
import 'package:broker_app/backend/services/dashboard_service.dart';
import 'package:broker_app/backend/services/matcher_service.dart';

/// Service pentru gestionarea încărcărilor de pe splash screen și cache-ul aplicației
class SplashService extends ChangeNotifier {
  // Singleton pattern
  static final SplashService _instance = SplashService._internal();
  factory SplashService() => _instance;
  SplashService._internal();

  // State management
  double _progress = 0.0;
  String _currentTask = 'Initializare aplicatie...';
  bool _isComplete = false;
  bool _isInitialized = false;
  
  // Cache pentru servicii
  CalendarService? _calendarService;
  ClientUIService? _clientUIService;
  FormService? _formService;
  DashboardService? _dashboardService;
  MatcherService? _matcherService;
  
  // Cache pentru meetings data
  List<ClientActivity>? _cachedMeetings;
  DateTime? _meetingsCacheTime;
  static const Duration _cacheValidity = Duration(minutes: 5); // Cache valid for 5 minutes
  
  // Cache pentru slot-urile de timp disponibile
  Map<String, List<String>>? _cachedTimeSlots; // Map<dateKey, availableSlots>
  DateTime? _timeSlotsLastUpdate;
  final Duration _timeSlotsCacheValidity = Duration(minutes: 2); // Cache mai scurt pentru slots
  
  // Error handling
  String? _lastError;
  
  // Getters
  double get progress => _progress;
  String get currentTask => _currentTask;
  bool get isComplete => _isComplete;
  bool get isInitialized => _isInitialized;
  String? get lastError => _lastError;
  
  // Cached services getters
  CalendarService get calendarService => _calendarService ?? CalendarService();
  ClientUIService get clientUIService => _clientUIService ?? ClientUIService();
  FormService get formService => _formService ?? FormService();
  DashboardService get dashboardService => _dashboardService ?? DashboardService();
  MatcherService get matcherService => _matcherService ?? MatcherService();
  
  /// Getter pentru cached meetings cu verificare validitate
  Future<List<ClientActivity>> getCachedMeetings() async {
    // Verifică dacă cache-ul este valid
    if (_cachedMeetings != null && 
        _meetingsCacheTime != null && 
        DateTime.now().difference(_meetingsCacheTime!) < _cacheValidity) {
      debugPrint('📋 SPLASH_SERVICE: Returning cached meetings (${_cachedMeetings!.length})');
      return _cachedMeetings!;
    }
    
    // Cache-ul a expirat sau nu există, reîncarcă datele
    return await _refreshMeetingsCache();
  }
  
  /// Reîncarcă cache-ul cu meetings
  Future<List<ClientActivity>> _refreshMeetingsCache() async {
    try {
      debugPrint('🔄 SPLASH_SERVICE: Refreshing meetings cache...');
      final firebaseService = _clientUIService?.firebaseService ?? ClientsFirebaseService();
      final meetings = await firebaseService.getAllMeetings();
      
      _cachedMeetings = meetings;
      _meetingsCacheTime = DateTime.now();
      
      debugPrint('✅ SPLASH_SERVICE: Meetings cache refreshed (${meetings.length} meetings)');
      return meetings;
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error refreshing meetings cache: $e');
      return _cachedMeetings ?? [];
    }
  }
  
  /// Invalidează cache-ul de meetings (să fie apelat când se adaugă/modifică/șterge meeting)
  void invalidateMeetingsCache() {
    debugPrint('🗑️ SPLASH_SERVICE: Invalidating meetings cache');
    _cachedMeetings = null;
    _meetingsCacheTime = null;
  }

  /// Obtine slot-urile de timp disponibile din cache sau refreshuie
  Future<List<String>> getAvailableTimeSlots(DateTime date, {String? excludeId}) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    
    // Verifica daca avem cache valid
    if (_cachedTimeSlots != null && 
        _timeSlotsLastUpdate != null &&
        DateTime.now().difference(_timeSlotsLastUpdate!) < _timeSlotsCacheValidity &&
        _cachedTimeSlots!.containsKey(dateKey)) {
      debugPrint('✅ Using cached time slots for $dateKey');
      return _cachedTimeSlots![dateKey]!;
    }

    // Refresh cache pentru aceasta data
    await _refreshTimeSlotsForDate(date, excludeId);
    return _cachedTimeSlots?[dateKey] ?? [];
  }

  /// Refresh cache pentru o data specifica
  Future<void> _refreshTimeSlotsForDate(DateTime date, String? excludeId) async {
    try {
      final clientService = _clientUIService?.firebaseService;
      if (clientService == null) return;

      // Orele de lucru standard
      final List<String> allSlots = [
        '09:30', '10:00', '10:30', '11:00', '11:30', 
        '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
        '15:00', '15:30', '16:00'
      ];

      // Obtine intalnirile pentru aceasta data din cache
      final cachedMeetings = await getCachedMeetings();
      final meetingsForDate = cachedMeetings.where((meeting) {
        final meetingDate = DateTime(
          meeting.dateTime.year,
          meeting.dateTime.month,
          meeting.dateTime.day,
        );
        final targetDate = DateTime(date.year, date.month, date.day);
        return meetingDate.isAtSameMomentAs(targetDate);
      }).toList();
      
      // Extrage orele ocupate (excluzand intalnirea specificata daca exista)
      final Set<String> occupiedSlots = {};
      for (var meeting in meetingsForDate) {
        // Skip the meeting we're editing
        if (excludeId != null && meeting.id == excludeId) continue;
        
        final timeSlot = DateFormat('HH:mm').format(meeting.dateTime);
        occupiedSlots.add(timeSlot);
      }

      // Calculeaza sloturile disponibile
      final availableSlots = allSlots.where((slot) => !occupiedSlots.contains(slot)).toList();
      
      // Update cache
      _cachedTimeSlots ??= {};
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      _cachedTimeSlots![dateKey] = availableSlots;
      _timeSlotsLastUpdate = DateTime.now();
      
      debugPrint('✅ Refreshed time slots cache for $dateKey: ${availableSlots.length} available');
    } catch (e) {
      debugPrint('❌ Error refreshing time slots cache: $e');
    }
  }

  /// Invalideaza cache-ul de time slots (cand se salveaza/editeaza meetings)
  void invalidateTimeSlotsCache() {
    _cachedTimeSlots = null;
    _timeSlotsLastUpdate = null;
    debugPrint('🔄 Time slots cache invalidated');
  }

  // Loading steps configuration
  final List<Map<String, dynamic>> _loadingSteps = [
    {'name': 'Initializare calendar...', 'weight': 0.12, 'function': '_initializeCalendarService'},
    {'name': 'Încărcare servicii client...', 'weight': 0.18, 'function': '_initializeClientServices'},
    {'name': 'Preîncărcare întâlniri...', 'weight': 0.15, 'function': '_preloadMeetings'},
    {'name': 'Initializare formulare...', 'weight': 0.12, 'function': '_initializeFormService'},
    {'name': 'Încărcare dashboard...', 'weight': 0.18, 'function': '_initializeDashboardService'},
    {'name': 'Încărcare matcher...', 'weight': 0.10, 'function': '_initializeMatcherService'},
    {'name': 'Sincronizare date...', 'weight': 0.10, 'function': '_syncData'},
    {'name': 'Finalizare...', 'weight': 0.05, 'function': '_finalize'},
  ];

  /// Pornește procesul de pre-încărcare
  Future<bool> startPreloading() async {
    if (_isInitialized) {
      debugPrint('🚀 SPLASH_SERVICE: Already initialized, skipping preload');
      return true;
    }

    try {
      _lastError = null;
      _resetProgress();
      
      double currentProgress = 0.0;
      
      for (int i = 0; i < _loadingSteps.length; i++) {
        final step = _loadingSteps[i];
        _updateTask(step['name']);
        
        // Execute loading step
        await _executeLoadingStep(i);
        
        // Update progress
        currentProgress += step['weight'] as double;
        _updateProgress(currentProgress);
        
        // Small delay for visual feedback
        await Future.delayed(const Duration(milliseconds: 150));
      }
      
      // Mark as complete
      _markComplete();
      _isInitialized = true;
      
      debugPrint('✅ SPLASH_SERVICE: All services pre-loaded successfully');
      return true;
      
    } catch (e) {
      _lastError = e.toString();
      debugPrint('❌ SPLASH_SERVICE: Error during preloading: $e');
      // Still mark as complete to allow app to continue
      _markComplete();
      return false;
    }
  }

  /// Execută un pas specific de încărcare
  Future<void> _executeLoadingStep(int stepIndex) async {
    switch (stepIndex) {
      case 0: // Calendar service
        await _initializeCalendarService();
        break;
      case 1: // Client services
        await _initializeClientServices();
        break;
      case 2: // Preload meetings
        await _preloadMeetings();
        break;
      case 3: // Form service
        await _initializeFormService();
        break;
      case 4: // Dashboard service
        await _initializeDashboardService();
        break;
      case 5: // Matcher service
        await _initializeMatcherService();
        break;
      case 6: // Data synchronization
        await _syncData();
        break;
      case 7: // Finalization
        await _finalize();
        break;
    }
  }

  /// Inițializează și cache-ează CalendarService
  Future<void> _initializeCalendarService() async {
    try {
      _calendarService = CalendarService();
      if (!_calendarService!.isInitialized) {
        await _calendarService!.initialize();
      }
      debugPrint('✅ SPLASH_SERVICE: Calendar service cached');
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error initializing calendar service: $e');
      rethrow;
    }
  }

  /// Inițializează și cache-ează ClientUIService
  Future<void> _initializeClientServices() async {
    try {
      _clientUIService = ClientUIService();
      
      // Pre-load clients data
      await _clientUIService!.loadClientsFromFirebase();
      debugPrint('✅ SPLASH_SERVICE: Client services cached');
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error initializing client services: $e');
      rethrow;
    }
  }

  /// Preîncarcă toate meetings în cache
  Future<void> _preloadMeetings() async {
    try {
      await _refreshMeetingsCache();
      debugPrint('✅ SPLASH_SERVICE: Meetings preloaded');
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error preloading meetings: $e');
      rethrow;
    }
  }

  /// Inițializează și cache-ează FormService
  Future<void> _initializeFormService() async {
    try {
      _formService = FormService();
      await _formService!.initialize();
      debugPrint('✅ SPLASH_SERVICE: Form service cached');
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error initializing form service: $e');
      rethrow;
    }
  }

  /// Inițializează și cache-ează DashboardService
  Future<void> _initializeDashboardService() async {
    try {
      _dashboardService = DashboardService();
      // Pre-load dashboard data
      await _dashboardService!.loadDashboardData();
      debugPrint('✅ SPLASH_SERVICE: Dashboard service cached');
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error initializing dashboard service: $e');
      rethrow;
    }
  }

  /// Inițializează și cache-ează MatcherService
  Future<void> _initializeMatcherService() async {
    try {
      _matcherService = MatcherService();
      await _matcherService!.initialize();
      debugPrint('✅ SPLASH_SERVICE: Matcher service cached');
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error initializing matcher service: $e');
      rethrow;
    }
  }

  /// Sincronizează datele între servicii
  Future<void> _syncData() async {
    try {
      // Pre-load focused client data if any
      if (_clientUIService != null && _clientUIService!.clients.isNotEmpty) {
        // Set first client as focused to pre-load form data
        final firstClient = _clientUIService!.clients.first;
        _clientUIService!.focusClient(firstClient.phoneNumber1);
        debugPrint('✅ SPLASH_SERVICE: Data synchronization complete');
      }
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error during data sync: $e');
      rethrow;
    }
  }

  /// Finalizează încărcarea
  Future<void> _finalize() async {
    try {
      // Orice finalizări suplimentare
      debugPrint('✅ SPLASH_SERVICE: Splash screen finalization complete');
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error during finalization: $e');
      rethrow;
    }
  }

  /// Resetează progresul
  void _resetProgress() {
    _progress = 0.0;
    _currentTask = 'Initializare aplicatie...';
    _isComplete = false;
    notifyListeners();
  }

  /// Actualizează task-ul curent
  void _updateTask(String task) {
    _currentTask = task;
    notifyListeners();
  }

  /// Actualizează progresul
  void _updateProgress(double progress) {
    _progress = progress;
    notifyListeners();
  }

  /// Marchează încărcarea ca fiind completă
  void _markComplete() {
    _isComplete = true;
    _currentTask = 'Gata!';
    _progress = 1.0;
    notifyListeners();
  }

  /// Verifică dacă toate serviciile sunt disponibile și funcționale
  bool get areServicesReady {
    return _calendarService != null &&
           _clientUIService != null &&
           _formService != null &&
           _dashboardService != null &&
           _matcherService != null &&
           _isInitialized;
  }

  /// Forțează re-inițializarea (pentru debug sau refresh)
  void forceReinitialize() {
    _isInitialized = false;
    _calendarService = null;
    _clientUIService = null;
    _formService = null;
    _dashboardService = null;
    _matcherService = null;
    _lastError = null;
    debugPrint('🔄 SPLASH_SERVICE: Force reinitialization requested');
  }

  /// Cleanup pentru disposal
  @override
  void dispose() {
    _calendarService = null;
    _clientUIService = null;
    _formService = null;
    _dashboardService = null;
    _matcherService = null;
    super.dispose();
  }
} 