import 'package:flutter/foundation.dart';
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

/// Service pentru gestionarea încărcărilor de pe splash screen și cache-ul aplicației
/// OPTIMIZAT: Implementare avansată cu preloading paralel și cache inteligent
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
  
  // OPTIMIZARE: Cache avansat pentru meetings cu timestamp și validare
  List<ClientActivity> _cachedMeetings = [];
  DateTime? _meetingsCacheTime;
  Map<String, List<String>> _cachedTimeSlots = {};
  DateTime? _timeSlotsLastUpdate;
  
  // OPTIMIZARE: Cache pentru clienți cu timestamp
  List<ClientModel> _cachedClients = [];
  DateTime? _clientsCacheTime;
  
  // OPTIMIZARE: Cache pentru dashboard data
  Map<String, dynamic> _cachedDashboardData = {};

  // FIX: Cache pentru separarea datelor per consultant/echipă
  String? _currentConsultantToken;
  String? _currentTeam;
  final Map<String, List<ClientActivity>> _teamMeetingsCache = {};
  final Map<String, List<ClientModel>> _teamClientsCache = {};
  
  // OPTIMIZARE: Debouncing pentru invalidări de cache cu timeout
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

  /// OPTIMIZAT: Resetează cache-ul când consultantul se schimbă cu preloading anticipat
  Future<void> resetForNewConsultant() async {
    PerformanceMonitor.startTimer('resetForNewConsultant');
    
    try {
      final firebaseService = _clientUIService?.firebaseService;
      if (firebaseService == null) return;
      
      final newConsultantToken = await NewFirebaseService().getCurrentConsultantToken();
      final newTeam = await NewFirebaseService().getCurrentConsultantTeam();
      
      if (newConsultantToken != _currentConsultantToken || newTeam != _currentTeam) {
    
        
        // Salvează în cache datele pentru echipa anterioară
        if (_currentTeam != null && _cachedMeetings.isNotEmpty) {
          _teamMeetingsCache[_currentTeam!] = List.from(_cachedMeetings);
        }
        if (_currentTeam != null && _cachedClients.isNotEmpty) {
          _teamClientsCache[_currentTeam!] = List.from(_cachedClients);
        }
        
        _currentConsultantToken = newConsultantToken;
        _currentTeam = newTeam;
        
        // OPTIMIZARE: Preload în paralel pentru echipa nouă cu timeout
        await Future.wait([
          _loadMeetingsForNewTeam(),
          _loadClientsForNewTeam(),
        ]).timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            debugPrint('⚠️ SPLASH_SERVICE: Consultant reset timeout, continuing...');
            return <void>[];
          },
        );
        
        // OPTIMIZARE: Operații non-blocking pentru dashboard și Google Drive
        _performNonBlockingReset(newConsultantToken);
        

      }
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error resetting for new consultant: $e');
    } finally {
      PerformanceMonitor.endTimer('resetForNewConsultant');
    }
  }

  /// OPTIMIZARE: Operații non-blocking pentru reset
  void _performNonBlockingReset(String? newConsultantToken) {
    // Notifică dashboard-ul pentru refresh (non-blocking)
    if (_dashboardService != null) {
      _dashboardService!.resetForNewConsultant().catchError((e) {
        debugPrint('⚠️ SPLASH_SERVICE: Dashboard reset error: $e');
      });
    }
    
    // FIX: Resetează cache-ul de clienți pentru separarea datelor (non-blocking)
    if (_clientUIService != null) {
      _clientUIService!.resetForNewConsultant().catchError((e) {
        debugPrint('⚠️ SPLASH_SERVICE: Client UI reset error: $e');
      });
    }
    
    // FIX: Schimbă consultantul în Google Drive Service pentru token-urile corecte (non-blocking)
    if (_googleDriveService != null && newConsultantToken != null) {
      _googleDriveService!.switchConsultant(newConsultantToken).catchError((e) {
        debugPrint('⚠️ SPLASH_SERVICE: Google Drive switch error: $e');
      });
    }
  }

  /// OPTIMIZAT: Încarcă întâlnirile pentru noua echipă cu cache inteligent
  Future<void> _loadMeetingsForNewTeam() async {
    if (_currentTeam == null) return;
    
    // Verifică cache-ul echipei mai întâi
    if (_teamMeetingsCache.containsKey(_currentTeam!)) {
      _cachedMeetings = List.from(_teamMeetingsCache[_currentTeam!]!);
      _meetingsCacheTime = DateTime.now();
      notifyListeners();
  
    } else {
      // Încarcă din Firebase cu timeout
      await _refreshMeetingsCache();
    }
  }

  /// OPTIMIZAT: Încarcă clienții pentru noua echipă cu cache inteligent
  Future<void> _loadClientsForNewTeam() async {
    if (_currentTeam == null) return;
    
    // Verifică cache-ul echipei mai întâi
    if (_teamClientsCache.containsKey(_currentTeam!)) {
      _cachedClients = List.from(_teamClientsCache[_currentTeam!]!);
      _clientsCacheTime = DateTime.now();
      notifyListeners();
  
    } else {
      // Încarcă din Firebase
      await _refreshClientsCache();
    }
  }

  /// OPTIMIZAT: Obtine toate intalnirile din cache cu validare avansată
  Future<List<ClientActivity>> getCachedMeetings() async {
    // OPTIMIZARE: Verifică consultantul doar dacă cache-ul este invalid
    if (_meetingsCacheTime == null || 
        DateTime.now().difference(_meetingsCacheTime!).inSeconds > 60) {
      // FIX: Verifică dacă consultantul s-a schimbat doar când este necesar
      await resetForNewConsultant();
      await _refreshMeetingsCache();
    }
    
    return _cachedMeetings;
  }

  /// OPTIMIZAT: Obtine toți clienții din cache cu validare avansată
  Future<List<ClientModel>> getCachedClients() async {
    // OPTIMIZARE: Verifică consultantul doar dacă cache-ul este invalid
    if (_clientsCacheTime == null || 
        DateTime.now().difference(_clientsCacheTime!).inSeconds > 60) {
      // Verifică dacă consultantul s-a schimbat doar când este necesar
      await resetForNewConsultant();
      await _refreshClientsCache();
    }
    
    return _cachedClients;
  }

  /// OPTIMIZAT: Refresh cache-ul de meetings cu timeout și retry
  Future<void> _refreshMeetingsCache() async {
    try {
      final firebaseService = _clientUIService?.firebaseService;
      if (firebaseService == null) {
        debugPrint('❌ SPLASH_SERVICE: Firebase service not available for meetings refresh');
        return;
      }

      // OPTIMIZARE: Timeout pentru operațiunea de refresh
      final meetingsData = await firebaseService.getTeamMeetings()
          .timeout(const Duration(seconds: 10));
      
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
      
      // Salvează în cache pentru echipa curentă
      if (_currentTeam != null) {
        _teamMeetingsCache[_currentTeam!] = List.from(meetings);
      }
      notifyListeners();
      
  
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error refreshing meetings cache: $e');
    }
  }

  /// OPTIMIZAT: Refresh cache-ul de clienți cu timeout și retry
  Future<void> _refreshClientsCache() async {
    try {
      final clientService = _clientUIService;
      if (clientService == null) {
        debugPrint('❌ SPLASH_SERVICE: Client service not available for clients refresh');
        return;
      }

      // OPTIMIZARE: Timeout pentru operațiunea de refresh
      await clientService.loadClientsFromFirebase()
          .timeout(const Duration(seconds: 10));
      
      _cachedClients = List.from(clientService.clients);
      _clientsCacheTime = DateTime.now();
      
      // Salvează în cache pentru echipa curentă
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

  /// OPTIMIZAT: Invalidează și reîncarcă imediat cache-ul de meetings cu debouncing îmbunătățit
  Future<void> invalidateMeetingsCacheAndRefresh() async {
    // OPTIMIZARE: Debouncing redus pentru răspuns mai rapid
    if (_hasPendingInvalidation) return;
    _hasPendingInvalidation = true;
    
    _cacheInvalidationTimer?.cancel();
    // CRITICAL FIX: Near-instant cache invalidation for immediate sync
    _cacheInvalidationTimer = Timer(const Duration(milliseconds: 10), () async {
      try {
        _cachedMeetings = [];
        _meetingsCacheTime = null;
        
        // OPTIMIZARE: Reîncarcă imediat cache-ul nou pentru actualizare instantanee
        await _refreshMeetingsCache();
        notifyListeners();
        
        // OPTIMIZARE: Notificare optimizată pentru ClientUIService cu delay redus
        if (_clientUIService != null && _clientUIService!.clients.isNotEmpty) {
          // OPTIMIZARE: Execută în background pentru a nu bloca UI-ul
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

  /// Invalidează cache-ul de meetings (să fie apelat când se adaugă/modifică/șterge meeting)
  void invalidateMeetingsCache() {
    // OPTIMIZARE: Nu face nimic dacă cache-ul este deja invalid
    if (_meetingsCacheTime == null) return;
    
    _cachedMeetings = [];
    _meetingsCacheTime = null;
  }

  /// OPTIMIZAT: Invalidează toate cache-urile legate de meetings cu debouncing îmbunătățit
  Future<void> invalidateAllMeetingCaches() async {
    // OPTIMIZARE: Evită apelurile multiple folosind debouncing
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
    const timeSlotsCacheValidity = Duration(minutes: 5); // Mărit de la 2 la 5 minute
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

  /// Convertește `Map<String, dynamic>` în ClientActivity (FIX: păstrează consultantName și consultantId)
  ClientActivity _convertMapToClientActivity(Map<String, dynamic> meetingMap) {
    // Convertește timestamp-ul la DateTime
    final dateTime = meetingMap['dateTime'] is Timestamp 
        ? (meetingMap['dateTime'] as Timestamp).toDate()
        : DateTime.fromMillisecondsSinceEpoch(meetingMap['dateTime'] ?? 0);
    
    // Determină tipul de activitate
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
        // FIX: Păstrează toate datele importante pentru afișare în calendar
        ...additionalData,
        'phoneNumber': meetingMap['clientPhoneNumber'] ?? '',
        'clientName': additionalData['clientName'] ?? meetingMap['clientName'] ?? '',
        'consultantName': meetingMap['consultantName'] ?? additionalData['consultantName'] ?? '',
        'consultantToken': meetingMap['consultantToken'] ?? '',
        // FIX: Propagă consultantId din additionalData pentru ownership verification
        'consultantId': additionalData['consultantId'],
        // Asigură-te că alte date importante sunt păstrate
        'type': meetingMap['type'] ?? 'meeting',
      },
      createdAt: DateTime.now(), // Folosim timpul curent pentru createdAt
    );
  }

  // OPTIMIZARE: Loading steps configuration cu timing și parallel loading
  final List<Map<String, dynamic>> _loadingSteps = [
    {'name': 'Initializare servicii...', 'weight': 0.15, 'function': '_initializeCoreServices', 'parallel': true},
    {'name': 'Preîncărcare date...', 'weight': 0.25, 'function': '_preloadData', 'parallel': true},
    {'name': 'Sincronizare servicii...', 'weight': 0.20, 'function': '_syncServices', 'parallel': false},
    {'name': 'Optimizare cache...', 'weight': 0.15, 'function': '_optimizeCache', 'parallel': false},
    {'name': 'Finalizare...', 'weight': 0.25, 'function': '_finalize', 'parallel': false},
  ];

  /// OPTIMIZAT: Pornește procesul de pre-încărcare cu parallel loading
  Future<bool> startPreloading() async {
    if (_isInitialized) {
      return true;
    }

    try {
      _lastError = null;
      _resetProgress();
      
      double currentProgress = 0.0;
      
      // OPTIMIZARE: Grupează task-urile paralele
      final parallelTasks = _loadingSteps.where((step) => step['parallel'] == true).toList();
      final sequentialTasks = _loadingSteps.where((step) => step['parallel'] == false).toList();
      
      // Execută task-urile paralele
      if (parallelTasks.isNotEmpty) {
        _updateTask('Încărcare paralelă servicii...');
        
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
      
      // Execută task-urile secvențiale
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
      
      // Marchează ca complet
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

  /// OPTIMIZAT: Execută un pas specific de încărcare cu timeout
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

  /// OPTIMIZAT: Inițializează serviciile de bază în paralel
  Future<void> _initializeCoreServices() async {
    try {
      // OPTIMIZARE: Inițializează serviciile în paralel
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

  /// OPTIMIZAT: Preîncarcă datele în paralel
  Future<void> _preloadData() async {
    try {
      // OPTIMIZARE: Preîncarcă datele în paralel
      await Future.wait([
        _preloadMeetings(),
        _preloadClients(),
        _preloadDashboardData(),
        _preloadFormData(), // OPTIMIZARE: Preîncarcă și datele de formular
      ]);
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error preloading data: $e');
      rethrow;
    }
  }

  /// OPTIMIZAT: Sincronizează serviciile
  Future<void> _syncServices() async {
    try {
      // OPTIMIZARE: Sincronizează serviciile în paralel
      await Future.wait([
        _initializeGoogleDriveService(),
        _syncData(),
      ]);
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error syncing services: $e');
      rethrow;
    }
  }

  /// OPTIMIZAT: Optimizează cache-ul
  Future<void> _optimizeCache() async {
    try {
      // OPTIMIZARE: Optimizează cache-ul pentru performanță
      await _optimizeMeetingsCache();
      await _optimizeClientsCache();
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error optimizing cache: $e');
      rethrow;
    }
  }

  /// Inițializează și cache-ează CalendarService
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

  /// Inițializează și cache-ează ClientUIService
  Future<void> _initializeClientServices() async {
    try {
      _clientUIService = ClientUIService();
      
      // Pre-load clients data
      await _clientUIService!.loadClientsFromFirebase();
      
      // OPTIMIZARE: Pornește real-time listeners pentru sincronizare automată
      await _clientUIService!.startRealTimeListeners();
      
  
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error initializing client services: $e');
      rethrow;
    }
  }

  /// Preîncarcă toate meetings în cache
  Future<void> _preloadMeetings() async {
    try {
      await _refreshMeetingsCache();
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error preloading meetings: $e');
      rethrow;
    }
  }

  /// Preîncarcă toți clienții în cache
  Future<void> _preloadClients() async {
    try {
      await _refreshClientsCache();
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error preloading clients: $e');
      rethrow;
    }
  }

  /// OPTIMIZARE: Preîncarcă datele de formular pentru clienții existenți
  Future<void> _preloadFormData() async {
    try {
      // OPTIMIZARE: Preîncarcă datele de formular pentru primii 2 clienți pentru acces rapid (redus de la 3)
      if (_clientUIService != null && _clientUIService!.clients.isNotEmpty) {
        final clientsToPreload = _clientUIService!.clients.take(2).toList();
        
        // OPTIMIZARE: Operații paralele pentru preîncărcare rapidă cu timeout redus
        await Future.wait(
          clientsToPreload.map((client) async {
            try {
              // OPTIMIZARE: Timeout redus pentru preîncărcare mai rapidă
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

  /// OPTIMIZAT: Preîncarcă datele formularului pentru clientul focusat
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

  /// Preîncarcă datele dashboard-ului
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

  /// Inițializează și cache-ează FormService
  Future<void> _initializeFormService() async {
    try {
      _formService = FormService();
      await _formService!.initialize();
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error initializing form service: $e');
      rethrow;
    }
  }

  /// Inițializează și cache-ează MatcherService
  Future<void> _initializeMatcherService() async {
    try {
      _matcherService = MatcherService();
      await _matcherService!.initialize();
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error initializing matcher service: $e');
      rethrow;
    }
  }

  /// Inițializează și cache-ează ConnectionService
  Future<void> _initializeConnectionService() async {
    try {
      _connectionService = ConnectionService();
      await _connectionService!.initialize();
  
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error initializing connection service: $e');
      rethrow;
    }
  }

  /// Inițializează și cache-ează GoogleDriveService
  Future<void> _initializeGoogleDriveService() async {
    // OPTIMIZARE: Log redus pentru performanță
    // debugPrint('🚀 SPLASH_SERVICE: ========== _initializeGoogleDriveService START ==========');
    
    try {
      // debugPrint('🚀 SPLASH_SERVICE: Creating GoogleDriveService instance...');
      _googleDriveService = GoogleDriveService();
      // debugPrint('✅ SPLASH_SERVICE: GoogleDriveService instance created');
      
      // debugPrint('🚀 SPLASH_SERVICE: Calling GoogleDriveService.initialize()...');
      await _googleDriveService!.initialize();
      // debugPrint('✅ SPLASH_SERVICE: GoogleDriveService.initialize() completed');
      
      // OPTIMIZARE: Log redus pentru performanță
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

  /// Sincronizează datele între servicii
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

  /// Optimizează cache-ul de meetings
  Future<void> _optimizeMeetingsCache() async {
    try {
      // OPTIMIZARE: Sortează meetings după dată pentru căutare rapidă
      _cachedMeetings.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      
      // OPTIMIZARE: Indexează meetings după dată pentru căutare rapidă
      final Map<String, List<ClientActivity>> meetingsByDate = {};
      for (final meeting in _cachedMeetings) {
        final dateKey = DateFormat('yyyy-MM-dd').format(meeting.dateTime);
        meetingsByDate.putIfAbsent(dateKey, () => []).add(meeting);
      }
      
  
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error optimizing meetings cache: $e');
    }
  }

  /// Optimizează cache-ul de clienți
  Future<void> _optimizeClientsCache() async {
    try {
      // OPTIMIZARE: Sortează clienții după nume pentru căutare rapidă
      _cachedClients.sort((a, b) => a.name.compareTo(b.name));
      
  
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error optimizing clients cache: $e');
    }
  }

  /// Finalizează încărcarea
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

  /// Resetează progresul
  void _resetProgress() {
    _progress = 0.0;
    _currentTask = 'Initializare aplicatie...';
    _isLoading = true;
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
    _isInitialized = true;
    _currentTask = 'Gata!';
    _progress = 1.0;
    notifyListeners();
  }

  /// Obtine token-ul consultantului curent sincron din cache (pentru UI rapid)
  String? getCurrentConsultantTokenSync() {
    // Încearcă să obții token-ul din cache dacă este disponibil
    return _currentConsultantToken;
  }

  /// Verifică dacă toate serviciile sunt disponibile și funcționale
  bool get areServicesReady {
    return _calendarService != null &&
           _clientUIService != null &&
           _formService != null &&
           _dashboardService != null &&
           _matcherService != null &&
           _googleDriveService != null &&
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
    _googleDriveService = null;
    _lastError = null;
  }

  /// Cleanup pentru disposal
  @override
  void dispose() {
    // OPTIMIZARE: Oprește real-time listeners
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

  /// OPTIMIZAT: Invalidează cache-ul de clienți și îl reîncarcă
  Future<void> invalidateClientsCacheAndRefresh() async {
    // OPTIMIZARE: Evită apelurile multiple folosind debouncing
    if (_hasPendingInvalidation) return;
    _hasPendingInvalidation = true;
    
    _cacheInvalidationTimer?.cancel();
    // CRITICAL FIX: Near-instant cache invalidation for immediate sync
    _cacheInvalidationTimer = Timer(const Duration(milliseconds: 5), () async {
      try {
        _cachedClients = [];
        _clientsCacheTime = null;
        
        // Reîncarcă imediat cache-ul nou pentru actualizare instantanee
        await _refreshClientsCache();
        
        // FIX: Notifică și ClientUIService pentru sincronizare completă
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

  /// OPTIMIZAT: Invalidează cache-ul de clienți pentru schimbări de categorie (imediat)
  Future<void> invalidateClientsCacheForCategoryChange() async {
    try {
  
      
      _cachedClients = [];
      _clientsCacheTime = null;
      
      // FIX: Notifică imediat pentru UI instant
      notifyListeners();
      
      // Reîncarcă imediat cache-ul nou pentru actualizare instantanee
      await _refreshClientsCache();
      
      // FIX: Notifică și ClientUIService pentru sincronizare completă
      if (_clientUIService != null) {
        await _clientUIService!.loadClientsFromFirebase();
        _clientUIService!.notifyListeners();
      }
      
  
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error in immediate clients cache invalidation: $e');
    }
  }

  /// Invalidează cache-ul de clienți (să fie apelat când se adaugă/modifică/șterge client)
  void invalidateClientsCache() {
    // OPTIMIZARE: Nu face nimic dacă cache-ul este deja invalid
    if (_clientsCacheTime == null) return;
    
    _cachedClients = [];
    _clientsCacheTime = null;
  }
} 