import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'clients_service.dart';
import 'consultant_service.dart';
import 'package:intl/intl.dart';

/// Model pentru consultant in clasament
class ConsultantRanking {
  final String id;
  final String name;
  final String team;
  final int score;
  final int formsCompleted;
  final int callsMade;
  final int meetingsScheduled;

  ConsultantRanking({
    required this.id,
    required this.name,
    required this.team,
    required this.score,
    required this.formsCompleted,
    required this.callsMade,
    required this.meetingsScheduled,
  });
}

/// Model pentru echipa in clasament
class TeamRanking {
  final String id;
  final String teamName;
  final int memberCount;
  final int formsCompleted;
  final int meetingsHeld;

  TeamRanking({
    required this.id,
    required this.teamName,
    required this.memberCount,
    required this.formsCompleted,
    required this.meetingsHeld,
  });
}

/// Model pentru intalnire
class UpcomingMeeting {
  final String id;
  final String clientName;
  final String meetingType;
  final DateTime scheduledTime;
  final String location;

  UpcomingMeeting({
    required this.id,
    required this.clientName,
    required this.meetingType,
    required this.scheduledTime,
    required this.location,
  });
}

/// Model pentru statisticile consultantului curent
class ConsultantStats {
  final int formsCompletedToday;
  final int dailyFormsTarget;
  final int formsCompletedThisMonth;
  final int totalMeetingsScheduled;
  final DateTime lastUpdated;

  ConsultantStats({
    required this.formsCompletedToday,
    required this.dailyFormsTarget,
    required this.formsCompletedThisMonth,
    required this.totalMeetingsScheduled,
    required this.lastUpdated,
  });

  /// Calculeaza progresul catre obiectivul zilnic (0.0 - 1.0)
  double get dailyFormsProgress => formsCompletedToday / dailyFormsTarget;

  /// Verifica daca obiectivul zilnic a fost atins
  bool get dailyTargetReached => formsCompletedToday >= dailyFormsTarget;
}

/// Serviciu pentru gestionarea datelor dashboard-ului
/// Conectat la Firebase pentru date reale
class DashboardService extends ChangeNotifier {
  // Singleton pattern
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  // Firebase services
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ClientsFirebaseService _clientsService = ClientsFirebaseService();
  final ConsultantService _consultantService = ConsultantService();

  // State variables
  List<ConsultantRanking> _consultantsRanking = [];
  List<TeamRanking> _teamsRanking = [];
  List<UpcomingMeeting> _upcomingMeetings = [];
  ConsultantStats? _consultantStats;
  String? _dutyAgent;
  bool _isLoading = false;
  String? _errorMessage;

  // Navigare luni - unificata pentru clasamentul combinat
  DateTime _selectedMonth = DateTime.now();

  // FIX: Cache pentru separarea datelor per consultant
  String? _currentConsultantToken;
  final Map<String, List<ConsultantRanking>> _consultantsRankingCache = {};
  final Map<String, List<TeamRanking>> _teamsRankingCache = {};
  final Map<String, List<UpcomingMeeting>> _upcomingMeetingsCache = {};
  final Map<String, ConsultantStats?> _consultantStatsCache = {};
  final Map<String, String?> _dutyAgentCache = {};

  // Getters
  List<ConsultantRanking> get consultantsRanking => _consultantsRanking;
  List<TeamRanking> get teamsRanking => _teamsRanking;
  List<UpcomingMeeting> get upcomingMeetings => _upcomingMeetings;
  ConsultantStats? get consultantStats => _consultantStats;
  String? get dutyAgent => _dutyAgent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get selectedMonth => _selectedMonth;

  User? get _currentUser => _auth.currentUser;

  // Backwards compatibility - pastram pentru compatibilitate
  DateTime get selectedMonthConsultants => _selectedMonth;
  DateTime get selectedMonthTeams => _selectedMonth;


  /// FIX: Reseteaza cache-ul si forteaza refresh pentru un nou consultant
  Future<void> resetForNewConsultant() async {
    try {
      final consultantData = await _consultantService.getCurrentConsultantData();
      final newConsultantToken = consultantData?['token'];
      
      if (newConsultantToken != _currentConsultantToken) {
        // Salveaza datele consultantului anterior in cache
        if (_currentConsultantToken != null) {
          _consultantsRankingCache[_currentConsultantToken!] = _consultantsRanking;
          _teamsRankingCache[_currentConsultantToken!] = _teamsRanking;
          _upcomingMeetingsCache[_currentConsultantToken!] = _upcomingMeetings;
          _consultantStatsCache[_currentConsultantToken!] = _consultantStats;
        }
        
        _currentConsultantToken = newConsultantToken;
        
        // Incarca datele pentru noul consultant din cache sau Firebase
        await _loadDataForCurrentConsultant();
      }
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error resetting for new consultant: $e');
    }
  }

  /// FIX: Incarca datele pentru consultantul curent din cache sau Firebase
  Future<void> _loadDataForCurrentConsultant() async {
    if (_currentConsultantToken == null) return;

    // Verifica cache-ul mai intai
    final cacheKey = _currentConsultantToken!;
    if (_consultantsRankingCache.containsKey(cacheKey)) {
      _consultantsRanking = _consultantsRankingCache[cacheKey]!;
      _teamsRanking = _teamsRankingCache[cacheKey] ?? [];
      _upcomingMeetings = _upcomingMeetingsCache[cacheKey] ?? [];
      _consultantStats = _consultantStatsCache[cacheKey];
      notifyListeners();
    } else {
      // Incarca din Firebase
      await loadDashboardData();
    }
  }

  /// Navigheaza la luna anterioara pentru clasamentul combinat
  void goToPreviousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    _refreshRankingsForSelectedMonth();
  }

  /// Navigheaza la luna urmatoare pentru clasamentul combinat
  void goToNextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    _refreshRankingsForSelectedMonth();
  }

  /// Navigheaza la luna curenta pentru clasamentul combinat
  void goToCurrentMonth() {
    _selectedMonth = DateTime.now();
    _refreshRankingsForSelectedMonth();
  }

  // Backwards compatibility methods
  void goToPreviousMonthConsultants() => goToPreviousMonth();
  void goToNextMonthConsultants() => goToNextMonth();
  void goToCurrentMonthConsultants() => goToCurrentMonth();
  void goToPreviousMonthTeams() => goToPreviousMonth();
  void goToNextMonthTeams() => goToNextMonth();
  void goToCurrentMonthTeams() => goToCurrentMonth();

  /// Reincarca toate clasamentele pentru luna selectata
  Future<void> _refreshRankingsForSelectedMonth() async {
    try {
      await Future.wait([
        _loadConsultantsRanking(),
        _loadTeamsRanking(),
      ]);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error refreshing rankings: $e');
    }
  }

  /// Reincarca clasamentul consultantilor pentru luna selectata
  Future<void> _refreshConsultantsRankingForSelectedMonth() async {
    try {
      await _loadConsultantsRanking();
      notifyListeners(); // Adaugat notifyListeners dupa incarcare
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error refreshing consultants ranking: $e');
    }
  }


  /// Incarca toate datele dashboard-ului (FIX: verifica consultant inainte de incarcare)
  Future<void> loadDashboardData() async {
    if (_currentUser == null) {
      debugPrint('❌ DASHBOARD_SERVICE: User not authenticated');
      _errorMessage = 'Utilizator neautentificat';
      notifyListeners();
      return;
    }

    // FIX: Verifica si reseteaza daca consultantul s-a schimbat
    await resetForNewConsultant();

    _setLoading(true);
    _errorMessage = null;

    try {
      // Incarca datele in paralel pentru performanta maxima
      final futures = <Future<void>>[
        _loadConsultantStats(), // Cel mai rapid - doar consultantul curent
        _loadUpcomingMeetings(), // Rapid - doar intalnirile consultantului curent
        _loadConsultantsRanking(), // Mai lent - toti consultantii
        _loadTeamsRanking(), // Cel mai lent - toate echipele
        _loadDutyAgent(), // Incarca agentul de serviciu
      ];

      // Asteapta toate task-urile sa se termine
      await Future.wait(futures);
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error loading data: $e');
      _errorMessage = 'Eroare la incarcarea datelor: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizeaza datele dashboard-ului
  Future<void> refreshData() async {
    await loadDashboardData();
  }

  /// Forteaza reincarcarea agentului de serviciu (pentru debug)
  Future<void> forceReloadDutyAgent() async {
    // Sterge cache-ul pentru ziua curenta
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _dutyAgentCache.remove(today);
    
    await _loadDutyAgent();
    notifyListeners();
  }

  /// Incarca clasamentul consultantilor din Firebase (FIX: foloseste consultantToken pentru stats)
  Future<void> _loadConsultantsRanking() async {
    try {
      // FIX: Obtine toate consultantii cu token-urile lor
      final consultantsSnapshot = await _firestore.collection('consultants').get();
      if (consultantsSnapshot.docs.isEmpty) {
        _consultantsRanking = [];
        return;
      }

      final yearMonth = DateFormat('yyyy-MM').format(_selectedMonth);
      final monthlyStatsSnapshot = await _firestore
          .collection('data')
          .doc('stats')
          .collection('monthly')
          .doc(yearMonth)
          .collection('consultants')
          .get();
          
      final statsMap = { for (var doc in monthlyStatsSnapshot.docs) doc.id : doc.data() };

      final rankings = consultantsSnapshot.docs.map((consultantDoc) {
        final consultantData = consultantDoc.data();
        final consultantToken = consultantData['token'] as String?;
        final consultantName = consultantData['name'] as String? ?? 'Necunoscut';
        final consultantTeam = consultantData['team'] as String? ?? '';
        
        if (consultantToken == null) {
          return null;
        }

        // FIX: Foloseste consultantToken pentru a gasi statisticile
        final stats = statsMap[consultantToken] ?? {};
        final forms = (stats['formsCompleted'] ?? 0) as num;
        final meetings = (stats['meetingsHeld'] ?? 0) as num;
        final score = (forms.toInt() * 10) + (meetings.toInt() * 5);

        return ConsultantRanking(
          id: consultantDoc.id, // Pastram UID-ul pentru identificare
          name: consultantName,
          team: consultantTeam,
          score: score,
          formsCompleted: forms.toInt(),
          callsMade: 0,
          meetingsScheduled: meetings.toInt(),
        );
      }).where((ranking) => ranking != null).cast<ConsultantRanking>().toList();

      rankings.sort((a, b) => b.score.compareTo(a.score));
      _consultantsRanking = rankings;
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error loading consultants: $e');
      _consultantsRanking = [];
    }
  }

  /// Incarca clasamentul echipelor din Firebase (FIX: foloseste consultantToken pentru stats)
  Future<void> _loadTeamsRanking() async {
    try {
      final yearMonth = DateFormat('yyyy-MM').format(_selectedMonth);
      final monthlyStatsSnapshot = await _firestore
          .collection('data')
          .doc('stats')
          .collection('monthly')
          .doc(yearMonth)
          .collection('consultants')
          .get();
          
      final statsMap = { for (var doc in monthlyStatsSnapshot.docs) doc.id : doc.data() };

      // FIX: Obtine toti consultantii cu token-urile lor
      final consultantsSnapshot = await _firestore.collection('consultants').get();
      final Map<String, Map<String, int>> teamStats = {};

      for (var consultantDoc in consultantsSnapshot.docs) {
        final consultantData = consultantDoc.data();
        final consultantToken = consultantData['token'] as String?;
        final teamId = consultantData['team'] as String? ?? '';
        
        if (consultantToken == null || teamId.isEmpty) {
          continue;
        }
        
        // FIX: Foloseste consultantToken pentru a gasi statisticile
        final stats = statsMap[consultantToken] ?? {};
        final forms = (stats['formsCompleted'] ?? 0) as num;
        final meetings = (stats['meetingsHeld'] ?? 0) as num;
        
        teamStats.putIfAbsent(teamId, () => {'forms': 0, 'meetings': 0, 'members': 0});
        teamStats[teamId]!['forms'] = teamStats[teamId]!['forms']! + forms.toInt();
        teamStats[teamId]!['meetings'] = teamStats[teamId]!['meetings']! + meetings.toInt();
        teamStats[teamId]!['members'] = teamStats[teamId]!['members']! + 1;
      }
      
      final teamNames = await _consultantService.getAllTeams();
      final teamRankings = teamNames.map((teamName) {
        final stats = teamStats[teamName] ?? {'forms': 0, 'meetings': 0, 'members': 0};
        
        return TeamRanking(
          id: teamName,
          teamName: teamName,
          memberCount: stats['members']!,
          formsCompleted: stats['forms']!,
          meetingsHeld: stats['meetings']!,
        );
      }).toList();

      teamRankings.sort((a, b) => b.formsCompleted.compareTo(a.formsCompleted));
      _teamsRanking = teamRankings;
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error loading teams: $e');
      _teamsRanking = [];
    }
  }

  /// Incarca intalnirile urmatoare din Firebase
  Future<void> _loadUpcomingMeetings() async {
    try {
      if (_currentUser == null) return;

      // Obtine toate intalnirile pentru consultantul curent
      final meetings = await _clientsService.getAllMeetings();
      final List<UpcomingMeeting> upcomingMeetings = [];

      final now = DateTime.now();
      
      for (final meeting in meetings) {
        // Converteste timestamp-ul la DateTime
        final dateTime = meeting['dateTime'] is Timestamp 
            ? (meeting['dateTime'] as Timestamp).toDate()
            : DateTime.fromMillisecondsSinceEpoch(meeting['dateTime'] ?? 0);
        
        // Filtreaza doar intalnirile viitoare
        if (dateTime.isAfter(now)) {
          final additionalData = meeting['additionalData'] as Map<String, dynamic>? ?? {};
          final phoneNumber = additionalData['phoneNumber'] ?? meeting['clientPhoneNumber'] ?? '';
          final clientName = additionalData['clientName'] ?? meeting['clientName'] ?? 'Client necunoscut';
          final meetingType = meeting['type'] ?? 'meeting';
          
          upcomingMeetings.add(UpcomingMeeting(
            id: meeting['id'] ?? '',
            clientName: clientName,
            meetingType: meetingType == 'bureauDelete' 
                ? 'Stergere birou credit' 
                : 'Intalnire',
            scheduledTime: dateTime,
            location: phoneNumber.isNotEmpty ? 'Telefon: $phoneNumber' : 'Birou',
          ));
        }
      }

      // Sorteaza dupa data programata
      upcomingMeetings.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
      _upcomingMeetings = upcomingMeetings;
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error loading meetings: $e');
      _upcomingMeetings = [];
    }
  }

  /// Incarca statisticile consultantului curent din Firebase
  Future<void> _loadConsultantStats() async {
    try {
      if (_currentUser == null) return;

      // Obtine token-ul consultantului curent
      final consultantData = await _consultantService.getCurrentConsultantData();
      final consultantToken = consultantData?['token'];
      if (consultantToken == null) return;

      final stats = await calculateConsultantStatsOptimized(consultantToken);
      
      _consultantStats = ConsultantStats(
        formsCompletedToday: 0, // Placeholder
        dailyFormsTarget: 10, // Placeholder
        formsCompletedThisMonth: stats['formsCompleted'] ?? 0,
        totalMeetingsScheduled: stats['meetingsScheduled'] ?? 0,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error loading consultant stats: $e');
      _consultantStats = null;
    }
  }

  /// Calculeaza statisticile agregate pentru un consultant (FIX: robust cu casting corect)
  Future<Map<String, int>> calculateConsultantStatsOptimized(String consultantToken) async {
    try {
      final yearMonth = DateFormat('yyyy-MM').format(_selectedMonth);
      
      final doc = await _firestore
          .collection('data')
          .doc('stats')
          .collection('monthly')
          .doc(yearMonth)
          .collection('consultants')
          .doc(consultantToken)
          .get();
      
      if (doc.exists) {
        final data = doc.data();
        final formsCompleted = (data?['formsCompleted'] ?? 0) as num;
        final meetingsScheduled = (data?['meetingsHeld'] ?? 0) as num;
        
        return {
          'formsCompleted': formsCompleted.toInt(),
          'meetingsScheduled': meetingsScheduled.toInt(),
        };
      } else {
        return {'formsCompleted': 0, 'meetingsScheduled': 0};
      }
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error calculating stats: $e');
      return {'formsCompleted': 0, 'meetingsScheduled': 0};
    }
  }

  /// Obtine consultant dupa ID
  ConsultantRanking? getConsultantById(String id) {
    try {
      return _consultantsRanking.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtine echipa dupa ID
  TeamRanking? getTeamById(String id) {
    try {
      return _teamsRanking.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtine intalnire dupa ID
  UpcomingMeeting? getMeetingById(String id) {
    try {
      return _upcomingMeetings.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Seteaza starea de loading si notifica listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Dispose resources (FIX: curata cache-ul)
  @override
  void dispose() {
    _consultantsRankingCache.clear();
    _teamsRankingCache.clear();
    _upcomingMeetingsCache.clear();
    _consultantStatsCache.clear();
    _dutyAgentCache.clear();
    super.dispose();
    debugPrint('🗑️ DASHBOARD_SERVICE: Disposed with cache cleanup');
  }

  /// Incarca agentul de serviciu din consultantii reali
  Future<void> _loadDutyAgent() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Verifica cache-ul pentru ziua curenta
      if (_dutyAgentCache.containsKey(today)) {
        _dutyAgent = _dutyAgentCache[today];
        return;
      }
      
      // Obtine toti consultantii din Firebase
      final consultantsSnapshot = await _firestore.collection('consultants').get();
      if (consultantsSnapshot.docs.isEmpty) {
        _dutyAgent = null;
        _dutyAgentCache[today] = null;
        return;
      }

      // Calculeaza rotatia pe baza zilei curente din luna
      final dayOfMonth = DateTime.now().day;
      final consultantIndex = (dayOfMonth - 1) % consultantsSnapshot.docs.length;
      
      final selectedConsultant = consultantsSnapshot.docs[consultantIndex];
      final consultantData = selectedConsultant.data();
      _dutyAgent = consultantData['name'] as String? ?? 'Necunoscut';
      
      // Salveaza in cache pentru ziua curenta
      _dutyAgentCache[today] = _dutyAgent;
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error loading duty agent: $e');
      _dutyAgent = 'Necunoscut';
    }
  }

  /// Notifica serviciul ca o intalnire a fost creata (FIX: robust cu tracking clienti contorizati)
  Future<void> onMeetingCreated(String consultantToken, String clientPhoneNumber) async {
    try {
      final now = DateTime.now();
      final yearMonth = DateFormat('yyyy-MM').format(now);
      final today = DateFormat('yyyy-MM-dd').format(now);
      
      debugPrint('📈 DASHBOARD_SERVICE: Recording meeting for consultant ${consultantToken.substring(0, 8)}... in $yearMonth for client $clientPhoneNumber');
      
      // Verifica daca clientul a fost deja contorizat pentru intalniri
      final monthlyDocRef = _firestore
          .collection('data')
          .doc('stats')
          .collection('monthly')
          .doc(yearMonth)
          .collection('consultants')
          .doc(consultantToken);
          
      final monthlyDoc = await monthlyDocRef.get();
      final monthlyData = monthlyDoc.data() ?? {};
      final completedClientsForMeetings = List<String>.from(monthlyData['completedClientsForMeetings'] ?? []);
      
      if (completedClientsForMeetings.contains(clientPhoneNumber)) {
        debugPrint('⚠️ DASHBOARD_SERVICE: Client $clientPhoneNumber already counted for meetings, skipping increment');
        return;
      }
      
      // IMPORTANT: Adauga clientul la lista inainte de increment pentru a preveni race conditions
      completedClientsForMeetings.add(clientPhoneNumber);
      
      await monthlyDocRef.set({
        'meetingsHeld': FieldValue.increment(1),
        'completedClientsForMeetings': completedClientsForMeetings,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Salveaza si statistici zilnice pentru tracking detaliat
      final dailyDocRef = _firestore
          .collection('data')
          .doc('stats')
          .collection('daily')
          .doc(today)
          .collection('consultants')
          .doc(consultantToken);
          
      final dailyDoc = await dailyDocRef.get();
      final dailyData = dailyDoc.data() ?? {};
      final dailyCompletedClientsForMeetings = List<String>.from(dailyData['completedClientsForMeetings'] ?? []);
      
      if (!dailyCompletedClientsForMeetings.contains(clientPhoneNumber)) {
        dailyCompletedClientsForMeetings.add(clientPhoneNumber);
        
        await dailyDocRef.set({
          'meetingsHeld': FieldValue.increment(1),
          'completedClientsForMeetings': dailyCompletedClientsForMeetings,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      
      debugPrint('✅ DASHBOARD_SERVICE: Successfully incremented meetings for consultant in $yearMonth for client $clientPhoneNumber');
      
      // FIX: Invalideaza cache-ul pentru acest consultant si refresh complet
      _consultantsRankingCache.remove(consultantToken);
      _teamsRankingCache.remove(consultantToken);  
      _consultantStatsCache.remove(consultantToken);
      
      // IMPORTANT: Reincarca clasamentele si notifica UI-ul pentru actualizare instantanee
      debugPrint('🔄 DASHBOARD_SERVICE: Refreshing rankings after meeting creation...');
      await _refreshConsultantsRankingForSelectedMonth();
      await _loadConsultantStats(); // Reincarca si statisticile consultantului
      notifyListeners(); // Notifica UI-ul sa se actualizeze
      debugPrint('✅ DASHBOARD_SERVICE: Rankings refreshed and UI notified');
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error in onMeetingCreated: $e');
    }
  }
  
  /// Notifica serviciul ca un formular a fost finalizat (FIX: robust cu tracking clienti contorizati)
  Future<void> onFormCompleted(String consultantToken, String clientPhoneNumber) async {
    try {
      final now = DateTime.now();
      final yearMonth = DateFormat('yyyy-MM').format(now);
      final today = DateFormat('yyyy-MM-dd').format(now);
      
      debugPrint('📈 DASHBOARD_SERVICE: Recording form completion for consultant ${consultantToken.substring(0, 8)}... in $yearMonth for client $clientPhoneNumber');
      
      // Verifica daca clientul a fost deja contorizat pentru formulare
      final monthlyDocRef = _firestore
          .collection('data')
          .doc('stats')
          .collection('monthly')
          .doc(yearMonth)
          .collection('consultants')
          .doc(consultantToken);
          
      final monthlyDoc = await monthlyDocRef.get();
      final monthlyData = monthlyDoc.data() ?? {};
      final completedClientsForForms = List<String>.from(monthlyData['completedClientsForForms'] ?? []);
      
      if (completedClientsForForms.contains(clientPhoneNumber)) {
        debugPrint('⚠️ DASHBOARD_SERVICE: Client $clientPhoneNumber already counted for forms, skipping increment');
        return;
      }
      
      // IMPORTANT: Adauga clientul la lista inainte de increment pentru a preveni race conditions
      completedClientsForForms.add(clientPhoneNumber);
      
      await monthlyDocRef.set({
        'formsCompleted': FieldValue.increment(1),
        'completedClientsForForms': completedClientsForForms,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Salveaza si statistici zilnice pentru tracking detaliat
      final dailyDocRef = _firestore
          .collection('data')
          .doc('stats')
          .collection('daily')
          .doc(today)
          .collection('consultants')
          .doc(consultantToken);
          
      final dailyDoc = await dailyDocRef.get();
      final dailyData = dailyDoc.data() ?? {};
      final dailyCompletedClientsForForms = List<String>.from(dailyData['completedClientsForForms'] ?? []);
      
      if (!dailyCompletedClientsForForms.contains(clientPhoneNumber)) {
        dailyCompletedClientsForForms.add(clientPhoneNumber);
        
        await dailyDocRef.set({
          'formsCompleted': FieldValue.increment(1),
          'completedClientsForForms': dailyCompletedClientsForForms,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      
      debugPrint('✅ DASHBOARD_SERVICE: Successfully incremented forms for consultant in $yearMonth for client $clientPhoneNumber');
      
      // FIX: Invalideaza cache-ul pentru acest consultant si refresh complet
      _consultantsRankingCache.remove(consultantToken);
      _teamsRankingCache.remove(consultantToken);
      _consultantStatsCache.remove(consultantToken);
      
      // IMPORTANT: Reincarca clasamentele si notifica UI-ul pentru actualizare instantanee
      debugPrint('🔄 DASHBOARD_SERVICE: Refreshing rankings after form completion...');
      await _refreshConsultantsRankingForSelectedMonth();
      await _loadConsultantStats(); // Reincarca si statisticile consultantului
      notifyListeners(); // Notifica UI-ul sa se actualizeze
      debugPrint('✅ DASHBOARD_SERVICE: Rankings refreshed and UI notified after form completion');
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error in onFormCompleted: $e');
    }
  }
}
