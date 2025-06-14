import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'clients_service.dart';
import 'consultant_service.dart';

/// Model pentru consultant în clasament
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

/// Model pentru echipă în clasament
class TeamRanking {
  final String id;
  final String name;
  final int totalScore;
  final int memberCount;
  final double averageScore;
  final int totalForms;

  TeamRanking({
    required this.id,
    required this.name,
    required this.totalScore,
    required this.memberCount,
    required this.averageScore,
    required this.totalForms,
  });
}

/// Model pentru întâlnire
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
  final int currentClients;
  final int pendingForms;
  final DateTime lastUpdated;

  ConsultantStats({
    required this.formsCompletedToday,
    required this.dailyFormsTarget,
    required this.formsCompletedThisMonth,
    required this.totalMeetingsScheduled,
    required this.currentClients,
    required this.pendingForms,
    required this.lastUpdated,
  });

  /// Calculează progresul către obiectivul zilnic (0.0 - 1.0)
  double get dailyFormsProgress => formsCompletedToday / dailyFormsTarget;

  /// Verifică dacă obiectivul zilnic a fost atins
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
  bool _isLoading = false;
  String? _errorMessage;

  // Navigare luni
  DateTime _selectedMonth = DateTime.now();

  // Getters
  List<ConsultantRanking> get consultantsRanking => _consultantsRanking;
  List<TeamRanking> get teamsRanking => _teamsRanking;
  List<UpcomingMeeting> get upcomingMeetings => _upcomingMeetings;
  ConsultantStats? get consultantStats => _consultantStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get selectedMonth => _selectedMonth;

  User? get _currentUser => _auth.currentUser;

  /// Navighează la luna anterioară
  void goToPreviousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    notifyListeners();
    _refreshRankingsForSelectedMonth();
  }

  /// Navighează la luna următoare
  void goToNextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    notifyListeners();
    _refreshRankingsForSelectedMonth();
  }

  /// Navighează la luna curentă
  void goToCurrentMonth() {
    _selectedMonth = DateTime.now();
    notifyListeners();
    _refreshRankingsForSelectedMonth();
  }

  /// Reîncarcă clasamentele pentru luna selectată
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

  /// Încarcă toate datele dashboard-ului
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
      // Încarcă datele în paralel pentru performanță maximă
      final futures = <Future<void>>[
        _loadConsultantStats(), // Cel mai rapid - doar consultantul curent
        _loadUpcomingMeetings(), // Rapid - doar întâlnirile consultantului curent
        _loadConsultantsRanking(), // Mai lent - toți consultanții
        _loadTeamsRanking(), // Cel mai lent - toate echipele
      ];

      // Așteaptă toate task-urile să se termine
      await Future.wait(futures);

      debugPrint('✅ DASHBOARD_SERVICE: All data loaded successfully');
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error loading data: $e');
      _errorMessage = 'Eroare la incarcarea datelor: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizează datele dashboard-ului
  Future<void> refreshData() async {
    debugPrint('🔄 DASHBOARD_SERVICE: Refreshing dashboard data...');
    await loadDashboardData();
  }

  /// Încarcă clasamentul consultanților din Firebase (optimizat)
  Future<void> _loadConsultantsRanking() async {
    try {
      debugPrint('🔍 DASHBOARD_SERVICE: Loading consultants ranking...');
      
      // Obține toți consultanții din Firebase cu un singur query
      final consultantsSnapshot = await _firestore
          .collection('consultants')
          .get();

      if (consultantsSnapshot.docs.isEmpty) {
        _consultantsRanking = [];
        return;
      }

      // Procesează consultanții în paralel pentru performanță
      final consultantFutures = consultantsSnapshot.docs.map((consultantDoc) async {
        final consultantData = consultantDoc.data();
        final consultantId = consultantDoc.id;
        final consultantName = consultantData['name'] ?? 'Necunoscut';

        // Calculează statisticile pentru fiecare consultant
        final stats = await _calculateConsultantStatsOptimized(consultantId);
        
        return ConsultantRanking(
          id: consultantId,
          name: consultantName,
          score: stats['score'] ?? 0,
          formsCompleted: stats['formsCompleted'] ?? 0,
          callsMade: 0, // Nu mai folosim apeluri
          meetingsScheduled: stats['meetingsScheduled'] ?? 0,
        );
      }).toList();

      final consultants = await Future.wait(consultantFutures);

      // Sortează după scor descrescător
      consultants.sort((a, b) => b.score.compareTo(a.score));
      _consultantsRanking = consultants;
      
      debugPrint('✅ DASHBOARD_SERVICE: Loaded ${_consultantsRanking.length} consultants');
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error loading consultants: $e');
      _consultantsRanking = [];
    }
  }

  /// Încarcă clasamentul echipelor din Firebase
  Future<void> _loadTeamsRanking() async {
    try {
      debugPrint('🔍 DASHBOARD_SERVICE: Loading teams ranking...');
      
      // Obține toate echipele disponibile
      final teams = await _consultantService.getAllTeams();
      final List<TeamRanking> teamRankings = [];

      for (final teamName in teams) {
        // Obține consultanții din echipă
        final teamConsultants = await _consultantService.getConsultantsByTeam(teamName);
        
        int totalScore = 0;
        int totalForms = 0;
        
                 // Calculează statisticile echipei
         for (final consultant in teamConsultants) {
           final consultantId = consultant['id'] as String?;
           if (consultantId != null) {
             final stats = await _calculateConsultantStatsOptimized(consultantId);
             totalScore += stats['score'] ?? 0;
             totalForms += stats['formsCompleted'] ?? 0;
           }
         }

                 final memberCount = teamConsultants.length;
         final averageScore = memberCount > 0 ? (totalScore / memberCount).toDouble() : 0.0;

        teamRankings.add(TeamRanking(
          id: teamName,
          name: teamName,
          totalScore: totalScore,
          memberCount: memberCount,
          averageScore: averageScore,
          totalForms: totalForms,
        ));
      }

      // Adaugă echipele standard dacă nu există
      final standardTeams = ['Echipa 1', 'Echipa 2', 'Echipa 3'];
      for (final teamName in standardTeams) {
        if (!teamRankings.any((team) => team.name == teamName)) {
          teamRankings.add(TeamRanking(
            id: teamName,
            name: teamName,
            totalScore: 0,
            memberCount: 0,
            averageScore: 0.0,
            totalForms: 0,
          ));
        }
      }

      // Sortează după scor total descrescător
      teamRankings.sort((a, b) => b.totalScore.compareTo(a.totalScore));
      _teamsRanking = teamRankings;
      
      debugPrint('✅ DASHBOARD_SERVICE: Loaded ${_teamsRanking.length} teams');
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error loading teams: $e');
      _teamsRanking = [
        TeamRanking(id: 'Echipa 1', name: 'Echipa 1', totalScore: 0, memberCount: 0, averageScore: 0.0, totalForms: 0),
        TeamRanking(id: 'Echipa 2', name: 'Echipa 2', totalScore: 0, memberCount: 0, averageScore: 0.0, totalForms: 0),
        TeamRanking(id: 'Echipa 3', name: 'Echipa 3', totalScore: 0, memberCount: 0, averageScore: 0.0, totalForms: 0),
      ];
    }
  }

  /// Încarcă întâlnirile următoare din Firebase
  Future<void> _loadUpcomingMeetings() async {
    try {
      debugPrint('🔍 DASHBOARD_SERVICE: Loading upcoming meetings...');
      
      if (_currentUser == null) return;

      // Obține toate întâlnirile pentru consultantul curent
      final meetings = await _clientsService.getAllMeetings();
      final List<UpcomingMeeting> upcomingMeetings = [];

      final now = DateTime.now();
      
      for (final meeting in meetings) {
        // Filtrează doar întâlnirile viitoare
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

      // Sortează după data programată
      upcomingMeetings.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
      _upcomingMeetings = upcomingMeetings;
      
      debugPrint('✅ DASHBOARD_SERVICE: Loaded ${_upcomingMeetings.length} upcoming meetings');
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error loading meetings: $e');
      _upcomingMeetings = [];
    }
  }

  /// Încarcă statisticile consultantului curent din Firebase
  Future<void> _loadConsultantStats() async {
    try {
      debugPrint('🔍 DASHBOARD_SERVICE: Loading consultant stats...');
      
      if (_currentUser == null) return;

      final stats = await _calculateConsultantStatsOptimized(_currentUser!.uid);
      
      _consultantStats = ConsultantStats(
        formsCompletedToday: stats['formsCompletedToday'] ?? 0,
        dailyFormsTarget: 30, // Obiectiv fix pentru moment
        formsCompletedThisMonth: stats['formsCompletedThisMonth'] ?? 0,
        totalMeetingsScheduled: stats['meetingsScheduled'] ?? 0,
        currentClients: stats['currentClients'] ?? 0,
        pendingForms: stats['pendingForms'] ?? 0,
        lastUpdated: DateTime.now(),
      );
      
      debugPrint('✅ DASHBOARD_SERVICE: Loaded consultant stats - Today: ${_consultantStats?.formsCompletedToday}, Month: ${_consultantStats?.formsCompletedThisMonth}');
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error loading consultant stats: $e');
      _consultantStats = ConsultantStats(
        formsCompletedToday: 0,
        dailyFormsTarget: 30,
        formsCompletedThisMonth: 0,
        totalMeetingsScheduled: 0,
        currentClients: 0,
        pendingForms: 0,
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Calculează statisticile pentru un consultant specific (optimizat)
  Future<Map<String, int>> _calculateConsultantStatsOptimized(String consultantId) async {
    try {
      // Un singur query pentru toți clienții
      final clientsSnapshot = await _firestore
          .collection('consultants')
          .doc(consultantId)
          .collection('clients')
          .get();

      if (clientsSnapshot.docs.isEmpty) {
        return {
          'score': 0,
          'formsCompleted': 0,
          'formsCompletedToday': 0,
          'formsCompletedThisMonth': 0,
          'meetingsScheduled': 0,
          'currentClients': 0,
          'pendingForms': 0,
        };
      }

      int currentClients = clientsSnapshot.docs.length;
      int totalMeetings = 0;
      int formsCompletedToday = 0;
      int formsCompletedThisMonth = 0;
      int pendingForms = 0;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedMonthStart = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final selectedMonthEnd = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1).subtract(const Duration(days: 1));

      // Procesează clienții în paralel
      final clientFutures = clientsSnapshot.docs.map((clientDoc) async {
        final phoneNumber = clientDoc.id;
        
        // Verifică formulare și întâlniri în paralel
        final formFuture = _firestore
            .collection('consultants')
            .doc(consultantId)
            .collection('clients')
            .doc(phoneNumber)
            .collection('form')
            .get();

        final meetingsFuture = _firestore
            .collection('consultants')
            .doc(consultantId)
            .collection('clients')
            .doc(phoneNumber)
            .collection('meetings')
            .get();

        final results = await Future.wait([formFuture, meetingsFuture]);
        final formSnapshot = results[0] as QuerySnapshot;
        final meetingsSnapshot = results[1] as QuerySnapshot;

        // Procesează formulare
        bool hasCompletedForm = false;
        for (final formDoc in formSnapshot.docs) {
          final formData = formDoc.data() as Map<String, dynamic>;
          final updatedAt = formData['updatedAt'] as Timestamp?;
          
          if (updatedAt != null) {
            hasCompletedForm = true;
            final updateDate = updatedAt.toDate();
            
            if (updateDate.isAfter(today)) {
              formsCompletedToday++;
            }
            
            if (updateDate.isAfter(selectedMonthStart) && updateDate.isBefore(selectedMonthEnd)) {
              formsCompletedThisMonth++;
            }
          }
        }

        if (!hasCompletedForm) {
          pendingForms++;
        }

        return meetingsSnapshot.docs.length;
      }).toList();

      final meetingCounts = await Future.wait(clientFutures);
      totalMeetings = meetingCounts.fold(0, (sum, count) => sum + count);

      // Calculează scorul (formulare * 10 + întâlniri * 5)
      final score = (formsCompletedThisMonth * 10) + (totalMeetings * 5);

      return {
        'score': score,
        'formsCompleted': formsCompletedThisMonth,
        'formsCompletedToday': formsCompletedToday,
        'formsCompletedThisMonth': formsCompletedThisMonth,
        'meetingsScheduled': totalMeetings,
        'currentClients': currentClients,
        'pendingForms': pendingForms,
      };
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error calculating stats for $consultantId: $e');
      return {
        'score': 0,
        'formsCompleted': 0,
        'formsCompletedToday': 0,
        'formsCompletedThisMonth': 0,
        'meetingsScheduled': 0,
        'currentClients': 0,
        'pendingForms': 0,
      };
    }
  }

  /// Actualizează statisticile după completarea unui formular
  void onFormCompleted() {
    if (_consultantStats != null) {
      _consultantStats = ConsultantStats(
        formsCompletedToday: _consultantStats!.formsCompletedToday + 1,
        dailyFormsTarget: _consultantStats!.dailyFormsTarget,
        formsCompletedThisMonth: _consultantStats!.formsCompletedThisMonth + 1,
        totalMeetingsScheduled: _consultantStats!.totalMeetingsScheduled,
        currentClients: _consultantStats!.currentClients,
        pendingForms: _consultantStats!.pendingForms - 1,
        lastUpdated: DateTime.now(),
      );
      notifyListeners();
      
      debugPrint('📝 DASHBOARD_SERVICE: Form completed. Today: ${_consultantStats!.formsCompletedToday}, Month: ${_consultantStats!.formsCompletedThisMonth}');
      
      // Reîncarcă datele pentru a fi sigur că sunt actualizate
      Future.delayed(const Duration(seconds: 1), () => refreshData());
    }
  }

  /// Actualizează statisticile după programarea unei întâlniri
  void onMeetingScheduled() {
    if (_consultantStats != null) {
      _consultantStats = ConsultantStats(
        formsCompletedToday: _consultantStats!.formsCompletedToday,
        dailyFormsTarget: _consultantStats!.dailyFormsTarget,
        formsCompletedThisMonth: _consultantStats!.formsCompletedThisMonth,
        totalMeetingsScheduled: _consultantStats!.totalMeetingsScheduled + 1,
        currentClients: _consultantStats!.currentClients,
        pendingForms: _consultantStats!.pendingForms,
        lastUpdated: DateTime.now(),
      );
      notifyListeners();
      
      debugPrint('📅 DASHBOARD_SERVICE: Meeting scheduled. Total meetings: ${_consultantStats!.totalMeetingsScheduled}');
      
      // Reîncarcă datele pentru a fi sigur că sunt actualizate
      Future.delayed(const Duration(seconds: 1), () => refreshData());
    }
  }

  /// Actualizează statisticile după adăugarea unui client nou
  void onClientAdded() {
    if (_consultantStats != null) {
      _consultantStats = ConsultantStats(
        formsCompletedToday: _consultantStats!.formsCompletedToday,
        dailyFormsTarget: _consultantStats!.dailyFormsTarget,
        formsCompletedThisMonth: _consultantStats!.formsCompletedThisMonth,
        totalMeetingsScheduled: _consultantStats!.totalMeetingsScheduled,
        currentClients: _consultantStats!.currentClients + 1,
        pendingForms: _consultantStats!.pendingForms + 1,
        lastUpdated: DateTime.now(),
      );
      notifyListeners();
      
      debugPrint('👤 DASHBOARD_SERVICE: Client added. Total clients: ${_consultantStats!.currentClients}');
      
      // Reîncarcă datele pentru a fi sigur că sunt actualizate
      Future.delayed(const Duration(seconds: 1), () => refreshData());
    }
  }

  /// Obține consultant după ID
  ConsultantRanking? getConsultantById(String id) {
    try {
      return _consultantsRanking.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obține echipă după ID
  TeamRanking? getTeamById(String id) {
    try {
      return _teamsRanking.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obține întâlnire după ID
  UpcomingMeeting? getMeetingById(String id) {
    try {
      return _upcomingMeetings.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Setează starea de loading și notifică listeners
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
}
