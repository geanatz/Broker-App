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
  final int score;
  final int formsCompleted;
  final int callsMade;
  final int meetingsScheduled;

  ConsultantRanking({
    required this.id,
    required this.name,
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

  // Navigare luni - separate pentru fiecare clasament
  DateTime _selectedMonthConsultants = DateTime.now();
  DateTime _selectedMonthTeams = DateTime.now();

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
  DateTime get selectedMonthConsultants => _selectedMonthConsultants;
  DateTime get selectedMonthTeams => _selectedMonthTeams;

  User? get _currentUser => _auth.currentUser;

  // Eliminam metodele vechi dar păstrăm pentru backwards compatibility
  DateTime get selectedMonth => _selectedMonthConsultants; // backwards compatibility

  void goToPreviousMonth() {
    // deprecated - kept for backwards compatibility
    goToPreviousMonthConsultants();
  }

  void goToNextMonth() {
    // deprecated - kept for backwards compatibility  
    goToNextMonthConsultants();
  }

  void goToCurrentMonth() {
    // deprecated - kept for backwards compatibility
    goToCurrentMonthConsultants();
  }


  /// FIX: Resetează cache-ul și forțează refresh pentru un nou consultant
  Future<void> resetForNewConsultant() async {
    try {
      final consultantData = await _consultantService.getCurrentConsultantData();
      final newConsultantToken = consultantData?['token'];
      
      if (newConsultantToken != _currentConsultantToken) {
        debugPrint('🔄 DASHBOARD_SERVICE: Switching consultant from ${_currentConsultantToken?.substring(0, 8) ?? 'NULL'} to ${newConsultantToken?.substring(0, 8) ?? 'NULL'}');
        
        // Salvează datele consultantului anterior în cache
        if (_currentConsultantToken != null) {
          _consultantsRankingCache[_currentConsultantToken!] = _consultantsRanking;
          _teamsRankingCache[_currentConsultantToken!] = _teamsRanking;
          _upcomingMeetingsCache[_currentConsultantToken!] = _upcomingMeetings;
          _consultantStatsCache[_currentConsultantToken!] = _consultantStats;
        }
        
        _currentConsultantToken = newConsultantToken;
        
        // Încarcă datele pentru noul consultant din cache sau Firebase
        await _loadDataForCurrentConsultant();
        
        debugPrint('✅ DASHBOARD_SERVICE: Successfully switched to new consultant');
      }
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error resetting for new consultant: $e');
    }
  }

  /// FIX: Încarcă datele pentru consultantul curent din cache sau Firebase
  Future<void> _loadDataForCurrentConsultant() async {
    if (_currentConsultantToken == null) return;

    // Verifică cache-ul mai întâi
    final cacheKey = _currentConsultantToken!;
    if (_consultantsRankingCache.containsKey(cacheKey)) {
      debugPrint('📋 DASHBOARD_SERVICE: Loading data from cache for consultant');
      _consultantsRanking = _consultantsRankingCache[cacheKey]!;
      _teamsRanking = _teamsRankingCache[cacheKey] ?? [];
      _upcomingMeetings = _upcomingMeetingsCache[cacheKey] ?? [];
      _consultantStats = _consultantStatsCache[cacheKey];
      notifyListeners();
    } else {
      // Încarcă din Firebase
      debugPrint('🔄 DASHBOARD_SERVICE: Loading fresh data from Firebase for consultant');
      await loadDashboardData();
    }
  }

  /// Navigheaza la luna anterioara pentru clasamentul consultantilor
  void goToPreviousMonthConsultants() {
    _selectedMonthConsultants = DateTime(_selectedMonthConsultants.year, _selectedMonthConsultants.month - 1, 1);
    _refreshConsultantsRankingForSelectedMonth();
  }

  /// Navigheaza la luna urmatoare pentru clasamentul consultantilor
  void goToNextMonthConsultants() {
    _selectedMonthConsultants = DateTime(_selectedMonthConsultants.year, _selectedMonthConsultants.month + 1, 1);
    _refreshConsultantsRankingForSelectedMonth();
  }

  /// Navigheaza la luna curenta pentru clasamentul consultantilor
  void goToCurrentMonthConsultants() {
    _selectedMonthConsultants = DateTime.now();
    _refreshConsultantsRankingForSelectedMonth();
  }

  /// Navigheaza la luna anterioara pentru clasamentul echipelor
  void goToPreviousMonthTeams() {
    _selectedMonthTeams = DateTime(_selectedMonthTeams.year, _selectedMonthTeams.month - 1, 1);
    _refreshTeamsRankingForSelectedMonth();
  }

  /// Navigheaza la luna urmatoare pentru clasamentul echipelor
  void goToNextMonthTeams() {
    _selectedMonthTeams = DateTime(_selectedMonthTeams.year, _selectedMonthTeams.month + 1, 1);
    _refreshTeamsRankingForSelectedMonth();
  }

  /// Navigheaza la luna curenta pentru clasamentul echipelor
  void goToCurrentMonthTeams() {
    _selectedMonthTeams = DateTime.now();
    _refreshTeamsRankingForSelectedMonth();
  }

  /// Reincarca clasamentul consultantilor pentru luna selectata
  Future<void> _refreshConsultantsRankingForSelectedMonth() async {
    try {
      await _loadConsultantsRanking();
      notifyListeners(); // Adăugat notifyListeners după încărcare
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error refreshing consultants ranking: $e');
    }
  }

  /// Reincarca clasamentul echipelor pentru luna selectata
  Future<void> _refreshTeamsRankingForSelectedMonth() async {
    try {
      await _loadTeamsRanking();
      notifyListeners(); // Adăugat notifyListeners după încărcare
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error refreshing teams ranking: $e');
    }
  }

  /// Incarca toate datele dashboard-ului (FIX: verifică consultant înainte de încărcare)
  Future<void> loadDashboardData() async {
    if (_currentUser == null) {
      debugPrint('❌ DASHBOARD_SERVICE: User not authenticated');
      _errorMessage = 'Utilizator neautentificat';
      notifyListeners();
      return;
    }

    // FIX: Verifică și resetează dacă consultantul s-a schimbat
    await resetForNewConsultant();

    debugPrint('🔄 DASHBOARD_SERVICE: Loading dashboard data...');
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

      debugPrint('✅ DASHBOARD_SERVICE: All data loaded successfully');
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

  /// Forțează reîncărcarea agentului de serviciu (pentru debug)
  Future<void> forceReloadDutyAgent() async {
    // Șterge cache-ul pentru ziua curentă
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _dutyAgentCache.remove(today);
    
    await _loadDutyAgent();
    notifyListeners();
  }

  /// Incarca clasamentul consultantilor din Firebase (FIX: folosește consultantToken pentru stats)
  Future<void> _loadConsultantsRanking() async {
    try {
      debugPrint('🔍 DASHBOARD_SERVICE: Loading consultants ranking for month: ${DateFormat('yyyy-MM').format(_selectedMonthConsultants)}');
      
      // FIX: Obține toate consultanții cu token-urile lor
      final consultantsSnapshot = await _firestore.collection('consultants').get();
      if (consultantsSnapshot.docs.isEmpty) {
        _consultantsRanking = [];
        return;
      }

      final yearMonth = DateFormat('yyyy-MM').format(_selectedMonthConsultants);
      final monthlyStatsSnapshot = await _firestore
          .collection('data')
          .doc('stats')
          .collection('monthly')
          .doc(yearMonth)
          .collection('consultants')
          .get();
          
      final statsMap = { for (var doc in monthlyStatsSnapshot.docs) doc.id : doc.data() };
      debugPrint('🔍 DASHBOARD_SERVICE: Found ${statsMap.length} stats documents in $yearMonth');

      final rankings = consultantsSnapshot.docs.map((consultantDoc) {
        final consultantData = consultantDoc.data();
        final consultantToken = consultantData['token'] as String?;
        final consultantName = consultantData['name'] as String? ?? 'Necunoscut';
        
        if (consultantToken == null) {
          debugPrint('⚠️ DASHBOARD_SERVICE: Consultant ${consultantDoc.id} has no token');
          return null;
        }

        // FIX: Folosește consultantToken pentru a găsi statisticile
        final stats = statsMap[consultantToken] ?? {};
        final forms = (stats['formsCompleted'] ?? 0) as num;
        final meetings = (stats['meetingsHeld'] ?? 0) as num;
        final score = (forms.toInt() * 10) + (meetings.toInt() * 5);

        debugPrint('📊 DASHBOARD_SERVICE: Consultant $consultantName - Forms: $forms, Meetings: $meetings, Score: $score');

        return ConsultantRanking(
          id: consultantDoc.id, // Păstrăm UID-ul pentru identificare
          name: consultantName,
          score: score,
          formsCompleted: forms.toInt(),
          callsMade: 0,
          meetingsScheduled: meetings.toInt(),
        );
      }).where((ranking) => ranking != null).cast<ConsultantRanking>().toList();

      rankings.sort((a, b) => b.score.compareTo(a.score));
      _consultantsRanking = rankings;
      
      debugPrint('✅ DASHBOARD_SERVICE: Loaded ${_consultantsRanking.length} consultants ranking');
      
      // Debug: Afișează primii 3 consultanți pentru verificare
      for (int i = 0; i < _consultantsRanking.length && i < 3; i++) {
        final consultant = _consultantsRanking[i];
        debugPrint('🏆 Rank ${i + 1}: ${consultant.name} - Forms: ${consultant.formsCompleted}, Meetings: ${consultant.meetingsScheduled}');
      }
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error loading consultants: $e');
      _consultantsRanking = [];
    }
  }

  /// Incarca clasamentul echipelor din Firebase (FIX: folosește consultantToken pentru stats)
  Future<void> _loadTeamsRanking() async {
    try {
      debugPrint('🔍 DASHBOARD_SERVICE: Loading teams ranking for month: ${DateFormat('yyyy-MM').format(_selectedMonthTeams)}');
      
      final yearMonth = DateFormat('yyyy-MM').format(_selectedMonthTeams);
      final monthlyStatsSnapshot = await _firestore
          .collection('data')
          .doc('stats')
          .collection('monthly')
          .doc(yearMonth)
          .collection('consultants')
          .get();
          
      final statsMap = { for (var doc in monthlyStatsSnapshot.docs) doc.id : doc.data() };
      debugPrint('🔍 DASHBOARD_SERVICE: Found ${statsMap.length} stats documents for teams ranking');

      // FIX: Obține toți consultanții cu token-urile lor
      final consultantsSnapshot = await _firestore.collection('consultants').get();
      final Map<String, Map<String, int>> teamStats = {};

      for (var consultantDoc in consultantsSnapshot.docs) {
        final consultantData = consultantDoc.data();
        final consultantToken = consultantData['token'] as String?;
        final teamId = consultantData['team'] as String? ?? '';
        
        if (consultantToken == null || teamId.isEmpty) {
          debugPrint('⚠️ DASHBOARD_SERVICE: Skipping consultant ${consultantDoc.id} - missing token or team');
          continue;
        }
        
        // FIX: Folosește consultantToken pentru a găsi statisticile
        final stats = statsMap[consultantToken] ?? {};
        final forms = (stats['formsCompleted'] ?? 0) as num;
        final meetings = (stats['meetingsHeld'] ?? 0) as num;
        
        teamStats.putIfAbsent(teamId, () => {'forms': 0, 'meetings': 0, 'members': 0});
        teamStats[teamId]!['forms'] = teamStats[teamId]!['forms']! + forms.toInt();
        teamStats[teamId]!['meetings'] = teamStats[teamId]!['meetings']! + meetings.toInt();
        teamStats[teamId]!['members'] = teamStats[teamId]!['members']! + 1;
        
        debugPrint('📊 DASHBOARD_SERVICE: Team $teamId - Consultant ${consultantData['name']}: Forms +${forms.toInt()}, Meetings +${meetings.toInt()}');
      }
      
      final teamNames = await _consultantService.getAllTeams();
      final teamRankings = teamNames.map((teamName) {
        final stats = teamStats[teamName] ?? {'forms': 0, 'meetings': 0, 'members': 0};
        debugPrint('🏆 DASHBOARD_SERVICE: Team $teamName - Total Forms: ${stats['forms']}, Total Meetings: ${stats['meetings']}, Members: ${stats['members']}');
        
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
      
      debugPrint('✅ DASHBOARD_SERVICE: Loaded ${_teamsRanking.length} teams ranking');
      
      // Debug: Afișează clasamentul echipelor pentru verificare
      for (int i = 0; i < _teamsRanking.length && i < 3; i++) {
        final team = _teamsRanking[i];
        debugPrint('🏆 Team Rank ${i + 1}: ${team.teamName} - Forms: ${team.formsCompleted}, Meetings: ${team.meetingsHeld}, Members: ${team.memberCount}');
      }
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error loading teams: $e');
      _teamsRanking = [];
    }
  }

  /// Incarca intalnirile urmatoare din Firebase
  Future<void> _loadUpcomingMeetings() async {
    try {
      debugPrint('🔍 DASHBOARD_SERVICE: Loading upcoming meetings...');
      
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
      
      debugPrint('✅ DASHBOARD_SERVICE: Loaded ${_upcomingMeetings.length} upcoming meetings');
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error loading meetings: $e');
      _upcomingMeetings = [];
    }
  }

  /// Incarca statisticile consultantului curent din Firebase
  Future<void> _loadConsultantStats() async {
    try {
      debugPrint('🔍 DASHBOARD_SERVICE: Loading consultant stats...');
      
      if (_currentUser == null) return;

      // Obtine token-ul consultantului curent
      final consultantData = await _consultantService.getCurrentConsultantData();
      final consultantToken = consultantData?['token'];
      if (consultantToken == null) return;

      final stats = await _calculateConsultantStatsOptimized(consultantToken);
      
      _consultantStats = ConsultantStats(
        formsCompletedToday: 0, // Placeholder
        dailyFormsTarget: 10, // Placeholder
        formsCompletedThisMonth: stats['formsCompleted'] ?? 0,
        totalMeetingsScheduled: stats['meetingsScheduled'] ?? 0,
        lastUpdated: DateTime.now(),
      );
      
      debugPrint('✅ DASHBOARD_SERVICE: Loaded consultant stats - Today: ${_consultantStats?.formsCompletedToday}, Month: ${_consultantStats?.formsCompletedThisMonth}');
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error loading consultant stats: $e');
      _consultantStats = null;
    }
  }

  /// Calculeaza statisticile agregate pentru un consultant (FIX: robust cu casting corect)
  Future<Map<String, int>> _calculateConsultantStatsOptimized(String consultantToken) async {
    try {
      final yearMonth = DateFormat('yyyy-MM').format(_selectedMonthConsultants);
      debugPrint('🔍 DASHBOARD_SERVICE: Calculating stats for consultant ${consultantToken.substring(0, 8)}... in $yearMonth');
      
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
        
        debugPrint('✅ DASHBOARD_SERVICE: Found stats - Forms: ${formsCompleted.toInt()}, Meetings: ${meetingsScheduled.toInt()}');
        
        return {
          'formsCompleted': formsCompleted.toInt(),
          'meetingsScheduled': meetingsScheduled.toInt(),
        };
      } else {
        debugPrint('⚠️ DASHBOARD_SERVICE: No stats document found for consultant in $yearMonth');
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

  /// Dispose resources (FIX: curăță cache-ul)
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

  /// Incarca agentul de serviciu din consultanții reali
  Future<void> _loadDutyAgent() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Verifică cache-ul pentru ziua curentă
      if (_dutyAgentCache.containsKey(today)) {
        _dutyAgent = _dutyAgentCache[today];
        debugPrint('📋 DASHBOARD_SERVICE: Using cached duty agent for $today: $_dutyAgent');
        return;
      }
      
      debugPrint('🔍 DASHBOARD_SERVICE: Loading duty agent from Firebase for $today...');
      
      // Obține toți consultanții din Firebase
      final consultantsSnapshot = await _firestore.collection('consultants').get();
      if (consultantsSnapshot.docs.isEmpty) {
        _dutyAgent = null;
        _dutyAgentCache[today] = null;
        debugPrint('⚠️ DASHBOARD_SERVICE: No consultants found for duty agent');
        return;
      }

      // Calculează rotația pe baza zilei curente din lună
      final dayOfMonth = DateTime.now().day;
      final consultantIndex = (dayOfMonth - 1) % consultantsSnapshot.docs.length;
      
      final selectedConsultant = consultantsSnapshot.docs[consultantIndex];
      final consultantData = selectedConsultant.data();
      _dutyAgent = consultantData['name'] as String? ?? 'Necunoscut';
      
      // Salvează în cache pentru ziua curentă
      _dutyAgentCache[today] = _dutyAgent;
      
      debugPrint('✅ DASHBOARD_SERVICE: Duty agent for day $dayOfMonth (index $consultantIndex): $_dutyAgent');
      debugPrint('📋 DASHBOARD_SERVICE: Available consultants: ${consultantsSnapshot.docs.map((doc) => doc.data()['name']).join(', ')}');
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error loading duty agent: $e');
      _dutyAgent = 'Necunoscut';
    }
  }

  /// Notifica serviciul ca o intalnire a fost creata (FIX: mai robust cu refresh automat)
  Future<void> onMeetingCreated(String consultantToken) async {
    try {
      final now = DateTime.now();
      final yearMonth = DateFormat('yyyy-MM').format(now);
      final today = DateFormat('yyyy-MM-dd').format(now);
      
      debugPrint('📈 DASHBOARD_SERVICE: Recording meeting for consultant ${consultantToken.substring(0, 8)}... in $yearMonth');
      
      // Salveaza in noua structura: data/stats/monthly/{year-month}/consultants/{consultantToken}
      final monthlyDocRef = _firestore
          .collection('data')
          .doc('stats')
          .collection('monthly')
          .doc(yearMonth)
          .collection('consultants')
          .doc(consultantToken);
          
      await monthlyDocRef.set({
        'meetingsHeld': FieldValue.increment(1),
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
          
      await dailyDocRef.set({
        'meetingsHeld': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      debugPrint('✅ DASHBOARD_SERVICE: Successfully incremented meetings for consultant in $yearMonth');
      
      // FIX: Invalidează cache-ul pentru acest consultant și refresh complet
      _consultantsRankingCache.remove(consultantToken);
      _teamsRankingCache.remove(consultantToken);  
      _consultantStatsCache.remove(consultantToken);
      
      // IMPORTANT: Reîncarcă clasamentele și notifică UI-ul pentru actualizare instantanee
      debugPrint('🔄 DASHBOARD_SERVICE: Refreshing rankings after meeting creation...');
      await _refreshConsultantsRankingForSelectedMonth();
      await _loadConsultantStats(); // Reîncarcă și statisticile consultantului
      notifyListeners(); // Notifică UI-ul să se actualizeze
      debugPrint('✅ DASHBOARD_SERVICE: Rankings refreshed and UI notified');
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error in onMeetingCreated: $e');
    }
  }
  
  /// Notifica serviciul ca un formular a fost finalizat (FIX: mai robust cu refresh automat)
  Future<void> onFormCompleted(String consultantToken) async {
    try {
      final now = DateTime.now();
      final yearMonth = DateFormat('yyyy-MM').format(now);
      final today = DateFormat('yyyy-MM-dd').format(now);
      
      debugPrint('📈 DASHBOARD_SERVICE: Recording form completion for consultant ${consultantToken.substring(0, 8)}... in $yearMonth');
      
      // Salveaza in noua structura: data/stats/monthly/{year-month}/consultants/{consultantToken}
      final monthlyDocRef = _firestore
          .collection('data')
          .doc('stats')
          .collection('monthly')
          .doc(yearMonth)
          .collection('consultants')
          .doc(consultantToken);
          
      await monthlyDocRef.set({
        'formsCompleted': FieldValue.increment(1),
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
          
      await dailyDocRef.set({
        'formsCompleted': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      debugPrint('✅ DASHBOARD_SERVICE: Successfully incremented forms for consultant in $yearMonth');
      
      // FIX: Invalidează cache-ul pentru acest consultant și refresh complet
      _consultantsRankingCache.remove(consultantToken);
      _teamsRankingCache.remove(consultantToken);
      _consultantStatsCache.remove(consultantToken);
      
      // IMPORTANT: Reîncarcă clasamentele și notifică UI-ul pentru actualizare instantanee
      debugPrint('🔄 DASHBOARD_SERVICE: Refreshing rankings after form completion...');
      await _refreshConsultantsRankingForSelectedMonth();
      await _loadConsultantStats(); // Reîncarcă și statisticile consultantului
      notifyListeners(); // Notifică UI-ul să se actualizeze
      debugPrint('✅ DASHBOARD_SERVICE: Rankings refreshed and UI notified after form completion');
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error in onFormCompleted: $e');
    }
  }
}
