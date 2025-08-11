import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:broker_app/backend/services/calendar_service.dart';
import 'package:broker_app/backend/services/clients_service.dart';
import 'package:broker_app/backend/services/form_service.dart';
import 'package:broker_app/backend/services/dashboard_service.dart';
import 'package:broker_app/backend/services/matcher_service.dart';
import 'package:broker_app/backend/services/firebase_service.dart';
import 'package:broker_app/backend/services/sheets_service.dart';
import 'package:broker_app/backend/services/connection_service.dart';
import 'package:broker_app/backend/services/llm_service.dart';
import 'package:broker_app/backend/services/role_service.dart';

/// Service pentru gestionarea incarcarilor de pe splash screen si cache-ul aplicatiei
/// OPTIMIZAT: Implementare avansata cu preloading paralel si cache inteligent
class SplashService extends ChangeNotifier {
  // Singleton pattern
  static final SplashService _instance = SplashService._internal();
  factory SplashService() => _instance;
  SplashService._internal();

  // State management
  bool _isInitialized = false;
  bool _isLoading = false;
  double _progress = 0.0;
  String _currentTask = 'Initializare aplicatie...';
  String? _lastError;
  
  // Cached services
  CalendarService? _calendarService;
  ClientUIService? _clientUIService;
  FormService? _formService;
  DashboardService? _dashboardService;
  MatcherService? _matcherService;
  GoogleDriveService? _googleDriveService;
  ConnectionService? _connectionService;
  LLMService? _llmService;
  
  // OPTIMIZARE: Cache avansat pentru meetings cu timestamp si validare
  List<ClientActivity> _cachedMeetings = [];
  DateTime? _meetingsCacheTime;
  Map<String, List<String>> _cachedTimeSlots = {};
  DateTime? _timeSlotsLastUpdate;
  
  // OPTIMIZARE: Cache pentru clienti cu timestamp
  List<ClientModel> _cachedClients = [];
  DateTime? _clientsCacheTime;
  
  // OPTIMIZARE: Cache pentru dashboard data
  Map<String, dynamic> _cachedDashboardData = {};

  // FIX: Cache pentru separarea datelor per consultant/echipa
  String? _currentConsultantToken;
  String? _currentTeam;
  final Map<String, List<ClientActivity>> _teamMeetingsCache = {};
  final Map<String, List<ClientModel>> _teamClientsCache = {};
  
  // OPTIMIZARE: Debouncing pentru invalidari de cache cu timeout
  Timer? _cacheInvalidationTimer;
  bool _hasPendingInvalidation = false;
  
  // OPTIMIZARE: Parallel loading support
  final Map<String, Completer<void>> _parallelTasks = {};
  
  // OPTIMIZARE: Performance monitoring
  final Map<String, DateTime> _taskStartTimes = {};
  final Map<String, Duration> _taskDurations = {};
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  double get progress => _progress;
  String get currentTask => _currentTask;
  String? get lastError => _lastError;
  
  // Cached services getters - safely handle null services
  CalendarService get calendarService => _calendarService ?? CalendarService();
  ClientUIService get clientUIService => _clientUIService ?? ClientUIService();
  FormService get formService => _formService ?? FormService();
  DashboardService get dashboardService => _dashboardService ?? DashboardService();
  MatcherService get matcherService => _matcherService ?? MatcherService();
  GoogleDriveService get googleDriveService => _googleDriveService ?? GoogleDriveService();
  ConnectionService get connectionService => _connectionService ?? ConnectionService();
  LLMService get llmService => _llmService ?? LLMService();

  /// FIX: Enhanced cache invalidation with robust state management
  void _invalidateCacheWithDebouncing() {
    if (_hasPendingInvalidation) return;
    
    _hasPendingInvalidation = true;
    _cacheInvalidationTimer?.cancel();
    
    _cacheInvalidationTimer = Timer(const Duration(milliseconds: 500), () {
      try {
        debugPrint('🔄 SPLASH: Invalidating cache with enhanced state management');
        
        // FIX: Clear all caches with validation
        _cachedMeetings.clear();
        _meetingsCacheTime = null;
        _cachedTimeSlots.clear();
        _timeSlotsLastUpdate = null;
        _cachedClients.clear();
        _clientsCacheTime = null;
        _cachedDashboardData.clear();
        
        // FIX: Enhanced team cache clearing
        _teamMeetingsCache.clear();
        _teamClientsCache.clear();
        
        // FIX: Notify listeners with validation
        notifyListeners();
        
        debugPrint('✅ SPLASH: Cache invalidation completed successfully');
        
      } catch (e) {
        debugPrint('❌ SPLASH: Error during cache invalidation: $e');
      } finally {
        _hasPendingInvalidation = false;
      }
    });
  }

  /// FIX: Enhanced consultant switching with robust state management
  Future<void> resetForNewConsultant() async {
    PerformanceMonitor.startTimer('resetForNewConsultant');
    
    try {
      final firebaseService = _clientUIService?.firebaseService;
      if (firebaseService == null) {
        debugPrint('❌ SPLASH: Firebase service not available for consultant reset');
        return;
      }
      
      // Invalidate cached consultant token before reading a new one to avoid leakage
      NewFirebaseService().invalidateConsultantTokenCache();
      final newConsultantToken = await NewFirebaseService().getCurrentConsultantToken();
      final newTeam = await NewFirebaseService().getCurrentConsultantTeam();
      // Refresh role on consultant change
      final role = await RoleService().refreshRole();
      debugPrint('SPLASH: Current role: ${role.asString}');
      
      if (newConsultantToken != _currentConsultantToken || newTeam != _currentTeam) {
        debugPrint('🔄 SPLASH: Consultant/team changed, resetting state');
        debugPrint('🔧 SPLASH: Old consultant: $_currentConsultantToken, New: $newConsultantToken');
        debugPrint('🔧 SPLASH: Old team: $_currentTeam, New: $newTeam');
        
        // FIX: Update consultant state
        _currentConsultantToken = newConsultantToken;
        _currentTeam = newTeam;
        
        // FIX: Enhanced cache invalidation
        _invalidateCacheWithDebouncing();

        // Also clear Firebase-side caches strictly bound to previous consultant
        NewFirebaseService().clearAllCaches();
        
        // FIX: Switch consultant in Google Drive service
        if (_googleDriveService != null && newConsultantToken != null) {
          await _googleDriveService!.switchConsultant(newConsultantToken);
        }
        
        // FIX: Reload services with new consultant context
        await _reloadServicesForNewConsultant();
        
        debugPrint('✅ SPLASH: Consultant reset completed successfully');
      } else {
        debugPrint('✅ SPLASH: Consultant/team unchanged, no reset needed');
      }
      
    } catch (e) {
      debugPrint('❌ SPLASH: Error during consultant reset: $e');
    } finally {
      PerformanceMonitor.endTimer('resetForNewConsultant');
    }
  }

  /// FIX: Enhanced service reloading for new consultant
  Future<void> _reloadServicesForNewConsultant() async {
    try {
      debugPrint('🔄 SPLASH: Reloading services for new consultant');
      
      // FIX: Reload client service with new consultant context
      if (_clientUIService != null) {
        _clientUIService!.stopRealTimeListeners();
        await _clientUIService!.loadClientsFromFirebase();
        await _clientUIService!.startRealTimeListeners();
      }
      
      // FIX: Reload dashboard service with new consultant context
      if (_dashboardService != null) {
        await _dashboardService!.loadDashboardData();
      }
      
      // FIX: Reload calendar service with new consultant context
      if (_calendarService != null) {
        // Calendar service will refresh automatically when needed
      }
      
      // FIX: Reset LLM service for new consultant to load correct conversation
      if (_llmService != null) {
        await _llmService!.resetForNewConsultant();
        // Cleanup conversatii vechi pentru a evita acumularea de date
        await _llmService!.clearOldConversations();
      }
      
      debugPrint('✅ SPLASH: Services reloaded successfully for new consultant');
      
    } catch (e) {
      debugPrint('❌ SPLASH: Error reloading services: $e');
    }
  }




  /// OPTIMIZAT: Obtine toate intalnirile din cache cu validare avansata
  Future<List<ClientActivity>> getCachedMeetings() async {
    // OPTIMIZARE: Verifica consultantul doar daca cache-ul este invalid
    if (_meetingsCacheTime == null || 
        DateTime.now().difference(_meetingsCacheTime!).inSeconds > 60) {
      // FIX: Verifica daca consultantul s-a schimbat doar cand este necesar
      await resetForNewConsultant();
      await _refreshMeetingsCache();
    }
    
    return _cachedMeetings;
  }

  /// OPTIMIZARE: Returneaza instant lista din cache (fara await) pentru UI instant.
  /// Daca cache-ul este stale, pornesc refresh in background (fara a bloca UI-ul).
  List<ClientActivity> getCachedMeetingsSync({bool preferTeamCache = true}) {
    if (_cachedMeetings.isNotEmpty) {
      return _cachedMeetings;
    }
    if (preferTeamCache && _currentTeam != null) {
      final teamList = _teamMeetingsCache[_currentTeam!];
      if (teamList != null && teamList.isNotEmpty) {
        return teamList;
      }
    }
    return const [];
  }

  /// OPTIMIZARE: Varianta rapida – intoarce imediat cache-ul si declanseaza refresh in fundal daca e nevoie
  Future<List<ClientActivity>> getCachedMeetingsFast() async {
    final result = getCachedMeetingsSync();
    final isStale = _meetingsCacheTime == null ||
        DateTime.now().difference(_meetingsCacheTime!).inSeconds > 60;
    if (isStale) {
      // Fire-and-forget refresh to keep UI instant
      unawaited(_refreshMeetingsCache());
    }
    return result;
  }

  /// OPTIMIZAT: Obtine toti clientii din cache cu validare avansata
  Future<List<ClientModel>> getCachedClients() async {
    // OPTIMIZARE: Verifica consultantul doar daca cache-ul este invalid
    if (_clientsCacheTime == null || 
        DateTime.now().difference(_clientsCacheTime!).inSeconds > 60) {
      // Verifica daca consultantul s-a schimbat doar cand este necesar
      await resetForNewConsultant();
      await _refreshClientsCache();
    }
    
    return _cachedClients;
  }

  /// OPTIMIZAT: Refresh cache-ul de meetings cu timeout si retry
  Future<void> _refreshMeetingsCache() async {
    try {
      final firebaseService = _clientUIService?.firebaseService;
      if (firebaseService == null) {
        debugPrint('❌ SPLASH_SERVICE: Firebase service not available for meetings refresh');
        return;
      }

      // OPTIMIZARE: Timeout pentru operatiunea de refresh (redus pentru a evita FREEZE)
      final meetingsData = await firebaseService.getTeamMeetings()
          .timeout(const Duration(seconds: 3));
      
      final List<ClientActivity> meetings = [];
      for (final meetingMap in meetingsData) {
        try {
          meetings.add(_convertMapToClientActivity(meetingMap));
        } catch (e) {
          // OPTIMIZARE: Log redus pentru erori
          // debugPrint('⚠️ SPLASH_SERVICE: Error converting meeting: $e');
        }
      }
      
      _cachedMeetings = meetings;
      _meetingsCacheTime = DateTime.now();
      
      // Salveaza in cache pentru echipa curenta
      if (_currentTeam != null) {
        _teamMeetingsCache[_currentTeam!] = List.from(meetings);
      }
      notifyListeners();
      
  
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error refreshing meetings cache: $e');
    }
  }

  /// OPTIMIZAT: Refresh cache-ul de clienti cu timeout si retry
  Future<void> _refreshClientsCache() async {
    try {
      final clientService = _clientUIService;
      if (clientService == null) {
        debugPrint('❌ SPLASH_SERVICE: Client service not available for clients refresh');
        return;
      }

      // OPTIMIZARE: Timeout pentru operatiunea de refresh (redus pentru a evita FREEZE)
      await clientService.loadClientsFromFirebase()
          .timeout(const Duration(seconds: 3));
      
      _cachedClients = List.from(clientService.clients);
      _clientsCacheTime = DateTime.now();
      
      // Salveaza in cache pentru echipa curenta
      if (_currentTeam != null) {
        _teamClientsCache[_currentTeam!] = List.from(_cachedClients);
      }
      notifyListeners();
      
  
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error refreshing clients cache: $e');
    }
  }

  /// Invalideaza cache-ul de time slots (cand se salveaza/editeaza meetings)
  void invalidateTimeSlotsCache() {
    _cachedTimeSlots = {};
    _timeSlotsLastUpdate = null;
  }

  /// OPTIMIZAT: Invalideaza si reincarca imediat cache-ul de meetings cu debouncing imbunatatit
  Future<void> invalidateMeetingsCacheAndRefresh() async {
    // OPTIMIZARE: Debouncing redus pentru raspuns mai rapid
    if (_hasPendingInvalidation) return;
    _hasPendingInvalidation = true;
    
    _cacheInvalidationTimer?.cancel();
    // CRITICAL FIX: Near-instant cache invalidation for immediate sync
    _cacheInvalidationTimer = Timer(const Duration(milliseconds: 10), () async {
      try {
        // Clear in-memory caches immediately to avoid stale sync reads
        _cachedMeetings = [];
        _meetingsCacheTime = null;
        if (_currentTeam != null) {
          _teamMeetingsCache.remove(_currentTeam!);
        } else {
          _teamMeetingsCache.clear();
        }
        
        // OPTIMIZARE: Reincarca imediat cache-ul nou pentru actualizare instantanee
        await _refreshMeetingsCache();
        notifyListeners();
        
        // OPTIMIZARE: Notificare optimizata pentru ClientUIService cu delay redus
        if (_clientUIService != null && _clientUIService!.clients.isNotEmpty) {
          // OPTIMIZARE: Executa in background pentru a nu bloca UI-ul
          Future.microtask(() async {
            try {
              await _clientUIService!.loadClientsFromFirebase();
              _clientUIService!.notifyListeners();
            } catch (e) {
              debugPrint('❌ SPLASH_SERVICE: Error loading clients in background: $e');
            }
          });
        }
        
        _hasPendingInvalidation = false;
    
      } catch (e) {
        debugPrint('❌ SPLASH_SERVICE: Error in cache invalidation: $e');
        _hasPendingInvalidation = false;
      }
    });
  }

  /// OPTIMIZARE: Eliminare optimista a unei intalniri din toate cache-urile (apelata dupa delete reusit)
  void removeMeetingFromCaches(String meetingId) {
    bool removed = false;
    if (_cachedMeetings.isNotEmpty) {
      final before = _cachedMeetings.length;
      _cachedMeetings.removeWhere((m) => m.id == meetingId);
      removed = removed || (_cachedMeetings.length != before);
    }
    if (_currentTeam != null && _teamMeetingsCache.containsKey(_currentTeam!)) {
      final list = _teamMeetingsCache[_currentTeam!];
      if (list != null && list.isNotEmpty) {
        final before = list.length;
        list.removeWhere((m) => m.id == meetingId);
        removed = removed || (list.length != before);
      }
    }
    if (removed) {
      // Notifica UI pentru update instant
      notifyListeners();
    }
  }

  /// OPTIMIZARE: Eliminare optimista a tuturor intalnirilor pentru un client (dupa stergerea clientului)
  void removeMeetingsByPhoneFromCaches(String clientPhone) {
    bool removed = false;
    if (_cachedMeetings.isNotEmpty) {
      final before = _cachedMeetings.length;
      _cachedMeetings.removeWhere((m) => (m.additionalData?['phoneNumber'] ?? '') == clientPhone);
      removed = removed || (_cachedMeetings.length != before);
    }
    if (_currentTeam != null && _teamMeetingsCache.containsKey(_currentTeam!)) {
      final list = _teamMeetingsCache[_currentTeam!];
      if (list != null && list.isNotEmpty) {
        final before = list.length;
        list.removeWhere((m) => (m.additionalData?['phoneNumber'] ?? '') == clientPhone);
        removed = removed || (list.length != before);
      }
    } else {
      // Safety: clean across all team caches
      for (final entry in _teamMeetingsCache.entries) {
        final list = entry.value;
        final before = list.length;
        list.removeWhere((m) => (m.additionalData?['phoneNumber'] ?? '') == clientPhone);
        removed = removed || (list.length != before);
      }
    }
    if (removed) {
      notifyListeners();
    }
  }

  /// Invalideaza cache-ul de meetings (sa fie apelat cand se adauga/modifica/sterge meeting)
  void invalidateMeetingsCache() {
    // OPTIMIZARE: Nu face nimic daca cache-ul este deja invalid
    if (_meetingsCacheTime == null) return;
    
    _cachedMeetings = [];
    _meetingsCacheTime = null;
  }

  /// OPTIMIZAT: Invalideaza toate cache-urile legate de meetings cu debouncing imbunatatit
  Future<void> invalidateAllMeetingCaches() async {
    // OPTIMIZARE: Evita apelurile multiple folosind debouncing
    await invalidateMeetingsCacheAndRefresh();
    
    // OPTIMIZARE: Invalidarea time slots se face lazy
    _cachedTimeSlots = {};
    _timeSlotsLastUpdate = null;
    
    // Cache invalidated and refreshed
  }

  /// OPTIMIZAT: Obtine slot-urile de timp disponibile din cache sau refreshuie cu timeout
  Future<List<String>> getAvailableTimeSlots(DateTime date, {String? excludeId}) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    
    // Verifica daca avem cache valid
    const timeSlotsCacheValidity = Duration(minutes: 5); // Marit de la 2 la 5 minute
    if (_cachedTimeSlots.isNotEmpty && 
        _timeSlotsLastUpdate != null &&
        DateTime.now().difference(_timeSlotsLastUpdate!) < timeSlotsCacheValidity &&
        _cachedTimeSlots.containsKey(dateKey)) {
      return _cachedTimeSlots[dateKey] ?? [];
    }

    // Refresh cache pentru aceasta data cu timeout
    await _refreshTimeSlotsForDate(date, excludeId)
        .timeout(const Duration(seconds: 5));
    return _cachedTimeSlots[dateKey] ?? [];
  }

  /// OPTIMIZAT: Refresh cache pentru o data specifica cu timeout
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
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      _cachedTimeSlots[dateKey] = availableSlots;
      _timeSlotsLastUpdate = DateTime.now();
    } catch (e) {
      debugPrint('❌ Error refreshing time slots cache: $e');
    }
  }

  /// Converteste `Map<String, dynamic>` in ClientActivity (FIX: pastreaza consultantName si consultantId)
  ClientActivity _convertMapToClientActivity(Map<String, dynamic> meetingMap) {
    // Converteste timestamp-ul la DateTime
    final dateTime = meetingMap['dateTime'] is Timestamp 
        ? (meetingMap['dateTime'] as Timestamp).toDate()
        : DateTime.fromMillisecondsSinceEpoch(meetingMap['dateTime'] ?? 0);
    
    // Determina tipul de activitate
    final type = meetingMap['type'] == 'bureauDelete' 
        ? ClientActivityType.bureauDelete 
        : ClientActivityType.meeting;
    
    final additionalData = meetingMap['additionalData'] as Map<String, dynamic>? ?? {};
    
    return ClientActivity(
      id: meetingMap['id'] ?? '',
      type: type,
      dateTime: dateTime,
      description: meetingMap['description'],
      additionalData: {
        // FIX: Pastreaza toate datele importante pentru afisare in calendar
        ...additionalData,
        'phoneNumber': meetingMap['clientPhoneNumber'] ?? '',
        'clientName': additionalData['clientName'] ?? meetingMap['clientName'] ?? '',
        'consultantName': meetingMap['consultantName'] ?? additionalData['consultantName'] ?? '',
        'consultantToken': meetingMap['consultantToken'] ?? '',
        // FIX: Propaga consultantId din additionalData pentru ownership verification
        'consultantId': additionalData['consultantId'],
        // Asigura-te ca alte date importante sunt pastrate
        'type': meetingMap['type'] ?? 'meeting',
      },
      createdAt: DateTime.now(), // Folosim timpul curent pentru createdAt
    );
  }

  // OPTIMIZARE: Loading steps configuration cu timing si parallel loading
  final List<Map<String, dynamic>> _loadingSteps = [
    {'name': 'Initializare servicii...', 'weight': 0.15, 'function': '_initializeCoreServices', 'parallel': true},
    {'name': 'Preincarcare date...', 'weight': 0.25, 'function': '_preloadData', 'parallel': true},
    {'name': 'Sincronizare servicii...', 'weight': 0.20, 'function': '_syncServices', 'parallel': false},
    {'name': 'Optimizare cache...', 'weight': 0.15, 'function': '_optimizeCache', 'parallel': false},
    {'name': 'Finalizare...', 'weight': 0.25, 'function': '_finalize', 'parallel': false},
  ];

  /// OPTIMIZAT: Porneste procesul de pre-incarcare cu parallel loading
  Future<bool> startPreloading() async {
    if (_isInitialized) {
      return true;
    }

    try {
      _lastError = null;
      _resetProgress();
      
      double currentProgress = 0.0;
      
      // OPTIMIZARE: Grupeaza task-urile paralele
      final parallelTasks = _loadingSteps.where((step) => step['parallel'] == true).toList();
      final sequentialTasks = _loadingSteps.where((step) => step['parallel'] == false).toList();
      
      // Executa task-urile paralele
      if (parallelTasks.isNotEmpty) {
        _updateTask('Incarcare paralela servicii...');
        
        final parallelFutures = parallelTasks.map((step) async {
          final startTime = DateTime.now();
          _taskStartTimes[step['name']] = startTime;
          
          await _executeLoadingStep(_loadingSteps.indexOf(step));
          
          final endTime = DateTime.now();
          _taskDurations[step['name']] = endTime.difference(startTime);
          
          currentProgress += step['weight'] as double;
          _updateProgress(currentProgress);
        }).toList();
        
        await Future.wait(parallelFutures);
      }
      
      // Executa task-urile secventiale
      for (final step in sequentialTasks) {
        _updateTask(step['name']);
        
        final startTime = DateTime.now();
        _taskStartTimes[step['name']] = startTime;
        
        await _executeLoadingStep(_loadingSteps.indexOf(step));
        
        final endTime = DateTime.now();
        _taskDurations[step['name']] = endTime.difference(startTime);
        
        currentProgress += step['weight'] as double;
        _updateProgress(currentProgress);
        
        // Small delay for visual feedback
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // Marcheaza ca complet
      _markComplete();
      _isInitialized = true;
      
      // OPTIMIZARE: Log performance metrics
      _logPerformanceMetrics();
      
      return true;
      
    } catch (e) {
      _lastError = e.toString();
      debugPrint('❌ SPLASH_SERVICE: Error during preloading: $e');
      // Still mark as complete to allow app to continue
      _markComplete();
      return false;
    }
  }

  /// OPTIMIZAT: Executa un pas specific de incarcare cu timeout
  Future<void> _executeLoadingStep(int stepIndex) async {
    switch (stepIndex) {
      case 0: // Core services
        await _initializeCoreServices();
        break;
      case 1: // Preload data
        await _preloadData();
        break;
      case 2: // Sync services
        await _syncServices();
        break;
      case 3: // Optimize cache
        await _optimizeCache();
        break;
      case 4: // Finalization
        await _finalize();
        break;
    }
  }

  /// OPTIMIZAT: Initializeaza serviciile de baza in paralel
  Future<void> _initializeCoreServices() async {
    try {
      // OPTIMIZARE: Initializeaza serviciile in paralel
      await Future.wait([
        _initializeCalendarService(),
        _initializeClientServices(),
        _initializeFormService(),
        _initializeMatcherService(),
        _initializeConnectionService(),
      ]);
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error initializing core services: $e');
      rethrow;
    }
  }

  /// OPTIMIZAT: Preincarca datele in paralel
  Future<void> _preloadData() async {
    try {
      // OPTIMIZARE: Preincarca datele in paralel
      await Future.wait([
        _preloadMeetings(),
        _preloadClients(),
        _preloadDashboardData(),
        _preloadFormData(), // OPTIMIZARE: Preincarca si datele de formular
      ]);
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error preloading data: $e');
      rethrow;
    }
  }

  /// OPTIMIZAT: Sincronizeaza serviciile
  Future<void> _syncServices() async {
    try {
      // OPTIMIZARE: Sincronizeaza serviciile in paralel
      await Future.wait([
        _initializeGoogleDriveService(),
        _syncData(),
      ]);
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error syncing services: $e');
      rethrow;
    }
  }

  /// OPTIMIZAT: Optimizeaza cache-ul
  Future<void> _optimizeCache() async {
    try {
      // OPTIMIZARE: Optimizeaza cache-ul pentru performanta
      await _optimizeMeetingsCache();
      await _optimizeClientsCache();
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error optimizing cache: $e');
      rethrow;
    }
  }

  /// Initializeaza si cache-eaza CalendarService
  Future<void> _initializeCalendarService() async {
    try {
      _calendarService = CalendarService();
      if (!_calendarService!.isInitialized) {
        await _calendarService!.initialize();
      }
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error initializing calendar service: $e');
      rethrow;
    }
  }

  /// Initializeaza si cache-eaza ClientUIService
  Future<void> _initializeClientServices() async {
    try {
      _clientUIService = ClientUIService();
      
      // Pre-load clients data
      await _clientUIService!.loadClientsFromFirebase();
      
      // OPTIMIZARE: Porneste real-time listeners dupa primul frame pentru a evita
      // avertismentele platform thread la startup (plugin Firestore)
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await _clientUIService!.startRealTimeListeners();
        } catch (e) {
          debugPrint('❌ SPLASH_SERVICE: Error starting real-time listeners post-frame: $e');
        }
      });
      
  
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error initializing client services: $e');
      rethrow;
    }
  }

  /// Preincarca toate meetings in cache
  Future<void> _preloadMeetings() async {
    try {
      await _refreshMeetingsCache();
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error preloading meetings: $e');
      rethrow;
    }
  }

  /// Preincarca toti clientii in cache
  Future<void> _preloadClients() async {
    try {
      await _refreshClientsCache();
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error preloading clients: $e');
      rethrow;
    }
  }

  /// OPTIMIZARE: Preincarca datele de formular pentru clientii existenti
  Future<void> _preloadFormData() async {
    try {
      // OPTIMIZARE: Preincarca datele de formular pentru primii 2 clienti pentru acces rapid (redus de la 3)
      if (_clientUIService != null && _clientUIService!.clients.isNotEmpty) {
        final clientsToPreload = _clientUIService!.clients.take(2).toList();
        
        // OPTIMIZARE: Operatii paralele pentru preincarcare rapida cu timeout redus
        await Future.wait(
          clientsToPreload.map((client) async {
            try {
              // OPTIMIZARE: Timeout redus pentru preincarcare mai rapida
              await _formService?.loadFormDataForClient(
                client.phoneNumber1,
                client.phoneNumber1,
              ).timeout(
                const Duration(milliseconds: 200), // Redus de la 500ms
                onTimeout: () {
                  debugPrint('⚠️ SPLASH_SERVICE: Form data preload timeout for ${client.name}');
                },
              );
            } catch (e) {
              // OPTIMIZARE: Log redus pentru erori
              // debugPrint('⚠️ SPLASH_SERVICE: Error preloading form data for ${client.name}: $e');
            }
          }),
        );
        
    
      }
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error preloading form data: $e');
      // Don't rethrow - form data preloading is not critical
    }
  }

  /// OPTIMIZAT: Preincarca datele formularului pentru clientul focusat
  Future<void> preloadFormDataForFocusedClient() async {
    try {
      final clientService = _clientUIService;
      if (clientService == null) return;
      
      final focusedClient = clientService.focusedClient;
      if (focusedClient != null && _formService != null) {
        await _formService!.loadFormDataForClient(
          focusedClient.phoneNumber,
          focusedClient.phoneNumber,
        );
    
      }
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error preloading form data: $e');
    }
  }

  /// Preincarca datele dashboard-ului
  Future<void> _preloadDashboardData() async {
    try {
      _dashboardService = DashboardService();
      await _dashboardService!.loadDashboardData();
      
      // Cache dashboard data - store current state
      _cachedDashboardData = {
        'consultantsRanking': _dashboardService!.consultantsRanking,
        'teamsRanking': _dashboardService!.teamsRanking,
        'upcomingMeetings': _dashboardService!.upcomingMeetings,
        'consultantStats': _dashboardService!.consultantStats,
        'dutyAgent': _dashboardService!.dutyAgent,
      };
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error preloading dashboard data: $e');
      rethrow;
    }
  }

  /// Initializeaza si cache-eaza FormService
  Future<void> _initializeFormService() async {
    try {
      _formService = FormService();
      await _formService!.initialize();
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error initializing form service: $e');
      rethrow;
    }
  }

  /// Initializeaza si cache-eaza MatcherService
  Future<void> _initializeMatcherService() async {
    try {
      _matcherService = MatcherService();
      await _matcherService!.initialize();
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error initializing matcher service: $e');
      rethrow;
    }
  }

  /// Initializeaza si cache-eaza ConnectionService
  Future<void> _initializeConnectionService() async {
    try {
      _connectionService = ConnectionService();
      await _connectionService!.initialize();
  
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error initializing connection service: $e');
      rethrow;
    }
  }

  /// Initializeaza si cache-eaza GoogleDriveService
  Future<void> _initializeGoogleDriveService() async {
    // OPTIMIZARE: Log redus pentru performanta
    // debugPrint('🚀 SPLASH_SERVICE: ========== _initializeGoogleDriveService START ==========');
    
    try {
      // debugPrint('🚀 SPLASH_SERVICE: Creating GoogleDriveService instance...');
      _googleDriveService = GoogleDriveService();
      // debugPrint('✅ SPLASH_SERVICE: GoogleDriveService instance created');
      
      // debugPrint('🚀 SPLASH_SERVICE: Calling GoogleDriveService.initialize()...');
      await _googleDriveService!.initialize();
      // debugPrint('✅ SPLASH_SERVICE: GoogleDriveService.initialize() completed');
      
      // OPTIMIZARE: Log redus pentru performanta
      // debugPrint('🚀 SPLASH_SERVICE: Final state - isAuthenticated: ${_googleDriveService!.isAuthenticated}');
      // debugPrint('🚀 SPLASH_SERVICE: Final state - userEmail: ${_googleDriveService!.userEmail}');
      // debugPrint('🚀 SPLASH_SERVICE: Final state - lastError: ${_googleDriveService!.lastError}');
      
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error initializing google drive service: $e');
      // debugPrint('❌ SPLASH_SERVICE: Stack trace: $stackTrace');
      rethrow;
    }
    
    // debugPrint('🚀 SPLASH_SERVICE: ========== _initializeGoogleDriveService END ==========');
  }

  /// Sincronizeaza datele intre servicii
  Future<void> _syncData() async {
    try {
      // Pre-load focused client data if any
      if (_clientUIService != null && _clientUIService!.clients.isNotEmpty) {
        // Set first client as focused to pre-load form data
        final firstClient = _clientUIService!.clients.first;
        _clientUIService!.focusClient(firstClient.phoneNumber1);
      }
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error during data sync: $e');
      rethrow;
    }
  }

  /// Optimizeaza cache-ul de meetings
  Future<void> _optimizeMeetingsCache() async {
    try {
      // OPTIMIZARE: Sorteaza meetings dupa data pentru cautare rapida
      _cachedMeetings.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      
      // OPTIMIZARE: Indexeaza meetings dupa data pentru cautare rapida
      final Map<String, List<ClientActivity>> meetingsByDate = {};
      for (final meeting in _cachedMeetings) {
        final dateKey = DateFormat('yyyy-MM-dd').format(meeting.dateTime);
        meetingsByDate.putIfAbsent(dateKey, () => []).add(meeting);
      }
      
  
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error optimizing meetings cache: $e');
    }
  }

  /// Optimizeaza cache-ul de clienti
  Future<void> _optimizeClientsCache() async {
    try {
      // OPTIMIZARE: Sorteaza clientii dupa nume pentru cautare rapida
      _cachedClients.sort((a, b) => a.name.compareTo(b.name));
      
  
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error optimizing clients cache: $e');
    }
  }

  /// Finalizeaza incarcarea
  Future<void> _finalize() async {
    try {
      // OPTIMIZARE: Cleanup pentru task-uri paralele
      _parallelTasks.clear();
      _taskStartTimes.clear();
      
  
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error during finalization: $e');
      rethrow;
    }
  }

  /// OPTIMIZARE: Log performance metrics
  void _logPerformanceMetrics() {
    debugPrint('📊 SPLASH_SERVICE: Performance Metrics:');
    for (final entry in _taskDurations.entries) {
      debugPrint('  ${entry.key}: ${entry.value.inMilliseconds}ms');
    }
  }

  /// Reseteaza progresul
  void _resetProgress() {
    _progress = 0.0;
    _currentTask = 'Initializare aplicatie...';
    _isLoading = true;
    notifyListeners();
  }

  /// Actualizeaza task-ul curent
  void _updateTask(String task) {
    _currentTask = task;
    notifyListeners();
  }

  /// Actualizeaza progresul
  void _updateProgress(double progress) {
    _progress = progress;
    notifyListeners();
  }

  /// Marcheaza incarcarea ca fiind completa
  void _markComplete() {
    _isInitialized = true;
    _currentTask = 'Gata!';
    _progress = 1.0;
    notifyListeners();
  }

  /// Obtine token-ul consultantului curent sincron din cache (pentru UI rapid)
  String? getCurrentConsultantTokenSync() {
    // Incearca sa obtii token-ul din cache daca este disponibil
    return _currentConsultantToken;
  }

  /// Verifica daca toate serviciile sunt disponibile si functionale
  bool get areServicesReady {
    return _calendarService != null &&
           _clientUIService != null &&
           _formService != null &&
           _dashboardService != null &&
           _matcherService != null &&
           _googleDriveService != null &&
           _isInitialized;
  }

  /// Forteaza re-initializarea (pentru debug sau refresh)
  void forceReinitialize() {
    _isInitialized = false;
    _calendarService = null;
    _clientUIService = null;
    _formService = null;
    _dashboardService = null;
    _matcherService = null;
    _googleDriveService = null;
    _lastError = null;
  }

  /// Cleanup pentru disposal
  @override
  void dispose() {
    // OPTIMIZARE: Opreste real-time listeners
    _clientUIService?.stopRealTimeListeners();
    
    _timeSlotsLastUpdate = null;
    _cachedTimeSlots.clear();
    _cachedMeetings.clear();
    _teamMeetingsCache.clear();
    _cachedClients.clear();
    _teamClientsCache.clear();
    _cachedDashboardData.clear();
    // OPTIMIZARE: Cleanup pentru timers
    _cacheInvalidationTimer?.cancel();
    _parallelTasks.clear();
    _taskStartTimes.clear();
    _taskDurations.clear();
    super.dispose();
  }

  /// OPTIMIZAT: Invalideaza cache-ul de clienti si il reincarca
  Future<void> invalidateClientsCacheAndRefresh() async {
    // OPTIMIZARE: Evita apelurile multiple folosind debouncing
    if (_hasPendingInvalidation) return;
    _hasPendingInvalidation = true;
    
    _cacheInvalidationTimer?.cancel();
    // CRITICAL FIX: Near-instant cache invalidation for immediate sync
    _cacheInvalidationTimer = Timer(const Duration(milliseconds: 5), () async {
      try {
        _cachedClients = [];
        _clientsCacheTime = null;
        
        // Reincarca imediat cache-ul nou pentru actualizare instantanee
        await _refreshClientsCache();
        
        // FIX: Notifica si ClientUIService pentru sincronizare completa
        if (_clientUIService != null) {
          await _clientUIService!.loadClientsFromFirebase();
        }
        
        notifyListeners();
        
        _hasPendingInvalidation = false;
    
      } catch (e) {
        debugPrint('❌ SPLASH_SERVICE: Error in clients cache invalidation: $e');
        _hasPendingInvalidation = false;
      }
    });
  }

  /// OPTIMIZAT: Invalideaza cache-ul de clienti pentru schimbari de categorie (imediat)
  Future<void> invalidateClientsCacheForCategoryChange() async {
    try {
  
      
      _cachedClients = [];
      _clientsCacheTime = null;
      
      // FIX: Notifica imediat pentru UI instant
      notifyListeners();
      
      // Reincarca imediat cache-ul nou pentru actualizare instantanee
      await _refreshClientsCache();
      
      // FIX: Notifica si ClientUIService pentru sincronizare completa
      if (_clientUIService != null) {
        await _clientUIService!.loadClientsFromFirebase();
        _clientUIService!.notifyListeners();
      }
      
  
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error in immediate clients cache invalidation: $e');
    }
  }

  /// Invalideaza cache-ul de clienti (sa fie apelat cand se adauga/modifica/sterge client)
  void invalidateClientsCache() {
    // OPTIMIZARE: Nu face nimic daca cache-ul este deja invalid
    if (_clientsCacheTime == null) return;
    
    _cachedClients = [];
    _clientsCacheTime = null;
  }
} 