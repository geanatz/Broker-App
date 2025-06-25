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

/// Service pentru gestionarea încărcărilor de pe splash screen și cache-ul aplicației
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
  
  // Meeting cache pentru calendar
  List<ClientActivity> _cachedMeetings = [];
  DateTime? _meetingsCacheTime;
  Map<String, List<String>> _cachedTimeSlots = {};
  DateTime? _timeSlotsLastUpdate;

  // FIX: Cache pentru separarea datelor per consultant/echipă
  String? _currentConsultantToken;
  String? _currentTeam;
  final Map<String, List<ClientActivity>> _teamMeetingsCache = {};
  
  // OPTIMIZARE: Debouncing pentru invalidări de cache
  Timer? _cacheInvalidationTimer;
  bool _hasPendingInvalidation = false;
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  double get progress => _progress;
  String get currentTask => _currentTask;
  String? get lastError => _lastError;
  
  // Cached services getters
  CalendarService get calendarService => _calendarService!;
  ClientUIService get clientUIService => _clientUIService!;
  FormService get formService => _formService!;
  DashboardService get dashboardService => _dashboardService!;
  MatcherService get matcherService => _matcherService!;
  GoogleDriveService get googleDriveService => _googleDriveService!;

  /// FIX: Resetează cache-ul când consultantul se schimbă
  Future<void> resetForNewConsultant() async {
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
        
        _currentConsultantToken = newConsultantToken;
        _currentTeam = newTeam;
        
        // Încarcă datele pentru noua echipă
        await _loadMeetingsForNewTeam();
        
        // Notifică și dashboard-ul pentru refresh
        if (_dashboardService != null) {
          await _dashboardService!.resetForNewConsultant();
        }
        
        // FIX: Resetează și cache-ul de clienți pentru separarea datelor
        if (_clientUIService != null) {
          await _clientUIService!.resetForNewConsultant();
        }
        
        // FIX: Schimbă consultantul în Google Drive Service pentru token-urile corecte
        if (_googleDriveService != null && newConsultantToken != null) {
          await _googleDriveService!.switchConsultant(newConsultantToken);
        }
      }
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error resetting for new consultant: $e');
    }
  }

  /// FIX: Încarcă întâlnirile pentru noua echipă
  Future<void> _loadMeetingsForNewTeam() async {
    if (_currentTeam == null) return;
    
    // Verifică cache-ul echipei mai întâi
    if (_teamMeetingsCache.containsKey(_currentTeam!)) {
      _cachedMeetings = List.from(_teamMeetingsCache[_currentTeam!]!);
      _meetingsCacheTime = DateTime.now();
      notifyListeners();
    } else {
      // Încarcă din Firebase
      await _refreshMeetingsCache();
    }
  }

  /// Obtine toate intalnirile din cache (FIX: verifică consultant înainte)
  Future<List<ClientActivity>> getCachedMeetings() async {
    // FIX: Verifică dacă consultantul s-a schimbat
    await resetForNewConsultant();
    
    // Verifica daca cache-ul este valid (nu mai vechi de 30 secunde)
    if (_meetingsCacheTime == null || 
        DateTime.now().difference(_meetingsCacheTime!).inSeconds > 30) {
      await _refreshMeetingsCache();
    }
    
    return _cachedMeetings;
  }

  /// Refresh cache-ul de meetings (FIX: folosește getTeamMeetings pentru echipă)
  Future<void> _refreshMeetingsCache() async {
    try {
      final firebaseService = _clientUIService?.firebaseService;
      if (firebaseService == null) {
        debugPrint('❌ SPLASH_SERVICE: Firebase service not available for meetings refresh');
        return;
      }

      final meetingsData = await firebaseService.getTeamMeetings(); // FIX: folosește getTeamMeetings pentru calendar
      
      final List<ClientActivity> meetings = [];
      for (final meetingMap in meetingsData) {
        try {
          meetings.add(_convertMapToClientActivity(meetingMap));
        } catch (e) {
          debugPrint('⚠️ SPLASH_SERVICE: Error converting meeting: $e');
        }
      }
      
      _cachedMeetings = meetings;
      _meetingsCacheTime = DateTime.now();
      
      // Salvează în cache pentru echipa curentă
      if (_currentTeam != null) {
        _teamMeetingsCache[_currentTeam!] = List.from(meetings);
      }
      notifyListeners(); // Notifică componentele că datele s-au actualizat
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error refreshing meetings cache: $e');
    }
  }

  /// Invalideaza cache-ul de time slots (cand se salveaza/editeaza meetings)
  void invalidateTimeSlotsCache() {
    _cachedTimeSlots = {};
    _timeSlotsLastUpdate = null;
  }

  /// FIX: Invalidează și reîncarcă imediat cache-ul de meetings pentru actualizare instantanee
  Future<void> invalidateMeetingsCacheAndRefresh() async {
    // OPTIMIZARE: Debouncing pentru a evita invalidările multiple
    if (_hasPendingInvalidation) return;
    _hasPendingInvalidation = true;
    
    _cacheInvalidationTimer?.cancel();
    _cacheInvalidationTimer = Timer(const Duration(milliseconds: 200), () async {
      try {
        _cachedMeetings = [];
        _meetingsCacheTime = null;
        
        // Reîncarcă imediat cache-ul nou pentru actualizare instantanee
        await _refreshMeetingsCache();
        notifyListeners(); // Notifică UI-ul că datele s-au schimbat
        
        // OPTIMIZARE: Notificare optimizată pentru ClientUIService
        if (_clientUIService != null && _clientUIService!.clients.isNotEmpty) {
          // OPTIMIZARE: Doar dacă chiar avem nevoie de refresh
          await _clientUIService!.loadClientsFromFirebase();
          _clientUIService!.notifyListeners();
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

  /// OPTIMIZAT: Invalidează toate cache-urile legate de meetings cu debouncing
  Future<void> invalidateAllMeetingCaches() async {
    // OPTIMIZARE: Evită apelurile multiple folosind debouncing
    await invalidateMeetingsCacheAndRefresh();
    
    // OPTIMIZARE: Invalidarea time slots se face lazy
    _cachedTimeSlots = {};
    _timeSlotsLastUpdate = null;
    
    debugPrint('🔄 SPLASH_SERVICE: All meeting caches invalidated and refreshed with debouncing');
  }

  /// Obtine slot-urile de timp disponibile din cache sau refreshuie
  Future<List<String>> getAvailableTimeSlots(DateTime date, {String? excludeId}) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    
    // Verifica daca avem cache valid
    const timeSlotsCacheValidity = Duration(minutes: 2);
    if (_cachedTimeSlots.isNotEmpty && 
        _timeSlotsLastUpdate != null &&
        DateTime.now().difference(_timeSlotsLastUpdate!) < timeSlotsCacheValidity &&
        _cachedTimeSlots.containsKey(dateKey)) {
      return _cachedTimeSlots[dateKey] ?? [];
    }

    // Refresh cache pentru aceasta data
    await _refreshTimeSlotsForDate(date, excludeId);
    return _cachedTimeSlots[dateKey] ?? [];
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

  // Loading steps configuration
  final List<Map<String, dynamic>> _loadingSteps = [
    {'name': 'Initializare calendar...', 'weight': 0.11, 'function': '_initializeCalendarService'},
    {'name': 'Încărcare servicii client...', 'weight': 0.16, 'function': '_initializeClientServices'},
    {'name': 'Preîncărcare întâlniri...', 'weight': 0.13, 'function': '_preloadMeetings'},
    {'name': 'Initializare formulare...', 'weight': 0.11, 'function': '_initializeFormService'},
    {'name': 'Încărcare dashboard...', 'weight': 0.16, 'function': '_initializeDashboardService'},
    {'name': 'Încărcare matcher...', 'weight': 0.09, 'function': '_initializeMatcherService'},
    {'name': 'Initializare Google Drive...', 'weight': 0.12, 'function': '_initializeGoogleDriveService'},
    {'name': 'Sincronizare date...', 'weight': 0.09, 'function': '_syncData'},
    {'name': 'Finalizare...', 'weight': 0.03, 'function': '_finalize'},
  ];

  /// Pornește procesul de pre-încărcare
  Future<bool> startPreloading() async {
    if (_isInitialized) {
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
      case 6: // Google Drive service
        await _initializeGoogleDriveService();
        break;
      case 7: // Data synchronization
        await _syncData();
        break;
      case 8: // Finalization
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

  /// Inițializează și cache-ează DashboardService
  Future<void> _initializeDashboardService() async {
    try {
      _dashboardService = DashboardService();
      // Pre-load dashboard data
      await _dashboardService!.loadDashboardData();
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
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error initializing matcher service: $e');
      rethrow;
    }
  }

  /// Inițializează și cache-ează GoogleDriveService
  Future<void> _initializeGoogleDriveService() async {
    try {
      _googleDriveService = GoogleDriveService();
      await _googleDriveService!.initialize();
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error initializing google drive service: $e');
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
    } catch (e) {
      debugPrint('❌ SPLASH_SERVICE: Error during finalization: $e');
      rethrow;
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
    _timeSlotsLastUpdate = null;
    _cachedTimeSlots.clear();
    _cachedMeetings.clear();
    _teamMeetingsCache.clear();
    // OPTIMIZARE: Cleanup pentru timers
    _cacheInvalidationTimer?.cancel();
    super.dispose();
  }
} 