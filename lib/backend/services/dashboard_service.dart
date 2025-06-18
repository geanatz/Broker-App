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

  // Navigare luni
  DateTime _selectedMonth = DateTime.now();

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

  /// Navigheaza la luna anterioara
  void goToPreviousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    notifyListeners();
    _refreshRankingsForSelectedMonth();
  }

  /// Navigheaza la luna urmatoare
  void goToNextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    notifyListeners();
    _refreshRankingsForSelectedMonth();
  }

  /// Navigheaza la luna curenta
  void goToCurrentMonth() {
    _selectedMonth = DateTime.now();
    notifyListeners();
    _refreshRankingsForSelectedMonth();
  }

  /// Reincarca clasamentele pentru luna selectata
  Future<void> _refreshRankingsForSelectedMonth() async {
    try {
      await Future.wait([
        _loadConsultantsRanking(),
        _loadTeamsRanking(),
      ]);
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error refreshing rankings: $e');
    }
  }

  /// Incarca toate datele dashboard-ului
  Future<void> loadDashboardData() async {
    if (_currentUser == null) {
      debugPrint('❌ DASHBOARD_SERVICE: User not authenticated');
      _errorMessage = 'Utilizator neautentificat';
      notifyListeners();
      return;
    }

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
        _loadDutyAgent(), // Incarca agentul de curatenie
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

  /// Incarca clasamentul consultantilor din Firebase (optimizat)
  Future<void> _loadConsultantsRanking() async {
    try {
      debugPrint('🔍 DASHBOARD_SERVICE: Loading consultants ranking for month: ${DateFormat('yyyy-MM').format(_selectedMonth)}');
      
      final consultants = await _consultantService.getAllConsultants();
      if (consultants.isEmpty) {
        _consultantsRanking = [];
        return;
      }

      final yearMonth = DateFormat('yyyy-MM').format(_selectedMonth);
      final monthlyStatsSnapshot = await _firestore
          .collection('monthly_stats')
          .doc(yearMonth)
          .collection('consultants')
          .get();
          
      final statsMap = { for (var doc in monthlyStatsSnapshot.docs) doc.id : doc.data() };

      final rankings = consultants.map((consultant) {
        final stats = statsMap[consultant.id] ?? {};
        final forms = stats['formsCompleted'] ?? 0;
        final meetings = stats['meetingsHeld'] ?? 0;
        final score = (forms * 10) + (meetings * 5);

        return ConsultantRanking(
          id: consultant.id,
          name: consultant.name,
          score: score,
          formsCompleted: forms,
          callsMade: 0,
          meetingsScheduled: meetings,
        );
      }).toList();

      rankings.sort((a, b) => b.score.compareTo(a.score));
      _consultantsRanking = rankings;
      
      debugPrint('✅ DASHBOARD_SERVICE: Loaded ${_consultantsRanking.length} consultants ranking');
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error loading consultants: $e');
      _consultantsRanking = [];
    }
  }

  /// Incarca clasamentul echipelor din Firebase
  Future<void> _loadTeamsRanking() async {
    try {
      debugPrint('🔍 DASHBOARD_SERVICE: Loading teams ranking for month: ${DateFormat('yyyy-MM').format(_selectedMonth)}');
      
      final yearMonth = DateFormat('yyyy-MM').format(_selectedMonth);
      final monthlyStatsSnapshot = await _firestore
          .collection('monthly_stats')
          .doc(yearMonth)
          .collection('consultants')
          .get();
          
      final statsMap = { for (var doc in monthlyStatsSnapshot.docs) doc.id : doc.data() };

      final allConsultants = await _consultantService.getAllConsultants();
      final Map<String, Map<String, int>> teamStats = {};

      for (var consultant in allConsultants) {
        final stats = statsMap[consultant.id] ?? {};
        final teamId = consultant.team;
        
        teamStats.putIfAbsent(teamId, () => {'forms': 0, 'meetings': 0, 'members': 0});
        teamStats[teamId]!['forms'] = teamStats[teamId]!['forms']! + ((stats['formsCompleted'] ?? 0) as num).toInt();
        teamStats[teamId]!['meetings'] = teamStats[teamId]!['meetings']! + ((stats['meetingsHeld'] ?? 0) as num).toInt();
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
      
      debugPrint('✅ DASHBOARD_SERVICE: Loaded ${_teamsRanking.length} teams ranking');
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
        // Filtreaza doar intalnirile viitoare
        if (meeting.dateTime.isAfter(now)) {
          final phoneNumber = meeting.additionalData?['phoneNumber'] ?? '';
          upcomingMeetings.add(UpcomingMeeting(
            id: meeting.id,
            clientName: meeting.additionalData?['clientName'] ?? 'Client necunoscut',
            meetingType: meeting.type == ClientActivityType.bureauDelete 
                ? 'Stergere birou credit' 
                : 'Intalnire',
            scheduledTime: meeting.dateTime,
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

      final stats = await _calculateConsultantStatsOptimized(_currentUser!.uid);
      
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

  /// Calculeaza statisticile agregate pentru un consultant (optimizat)
  Future<Map<String, int>> _calculateConsultantStatsOptimized(String consultantId) async {
    final yearMonth = DateFormat('yyyy-MM').format(_selectedMonth);
    final doc = await _firestore.collection('monthly_stats').doc(yearMonth).collection('consultants').doc(consultantId).get();
    if (doc.exists) {
      return {
        'formsCompleted': doc.data()?['formsCompleted'] ?? 0,
        'meetingsScheduled': doc.data()?['meetingsHeld'] ?? 0,
      };
    }
    return {'formsCompleted': 0, 'meetingsScheduled': 0};
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

  /// Dispose resources
  @override
  void dispose() {
    super.dispose();
    debugPrint('🗑️ DASHBOARD_SERVICE: Disposed');
  }

  /// Incarca agentul de curatenie
  Future<void> _loadDutyAgent() async {
    // Aici va veni logica de a prelua agentul din Firebase/alt serviciu
    // Pentru moment, folosim un placeholder
    _dutyAgent = 'Popescu Ion';
  }

  /// Notifica serviciul ca o intalnire a fost creata
  Future<void> onMeetingCreated(String consultantId) async {
    try {
      final yearMonth = DateFormat('yyyy-MM').format(DateTime.now());
      final docRef = _firestore.collection('monthly_stats').doc(yearMonth).collection('consultants').doc(consultantId);
      await docRef.set({'meetingsHeld': FieldValue.increment(1)}, SetOptions(merge: true));
      debugPrint('📈 DASHBOARD_SERVICE: Incremented meetings for $consultantId in $yearMonth');
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error in onMeetingCreated: $e');
    }
  }
  
  /// Notifica serviciul ca un formular a fost finalizat
  Future<void> onFormCompleted(String consultantId) async {
    try {
      final yearMonth = DateFormat('yyyy-MM').format(DateTime.now());
      final docRef = _firestore.collection('monthly_stats').doc(yearMonth).collection('consultants').doc(consultantId);
      await docRef.set({'formsCompleted': FieldValue.increment(1)}, SetOptions(merge: true));
      debugPrint('📈 DASHBOARD_SERVICE: Incremented forms for $consultantId in $yearMonth');
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error in onFormCompleted: $e');
    }
  }
}
