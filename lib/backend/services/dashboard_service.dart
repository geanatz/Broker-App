import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'clients_service.dart';
import 'firebase_service.dart';
import 'consultant_service.dart';
import 'package:intl/intl.dart';
import 'role_service.dart';

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
  final int score; // Punctaj total calculat ca suma punctajelor consultantilor

  TeamRanking({
    required this.id,
    required this.teamName,
    required this.memberCount,
    required this.formsCompleted,
    required this.meetingsHeld,
    required this.score,
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
  final int meetingsScheduledToday;
  final DateTime lastUpdated;

  ConsultantStats({
    required this.formsCompletedToday,
    required this.dailyFormsTarget,
    required this.formsCompletedThisMonth,
    required this.totalMeetingsScheduled,
    required this.meetingsScheduledToday,
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
  final FirebaseThreadHandler _threadHandler = FirebaseThreadHandler.instance;
  static const int _counterShards = 20; // configurable

  // State variables
  List<ConsultantRanking> _consultantsRanking = [];
  List<TeamRanking> _teamsRanking = [];
  List<UpcomingMeeting> _upcomingMeetings = [];
  ConsultantStats? _consultantStats;
  String? _dutyAgent;
  bool _isLoading = false;
  String? _errorMessage;
  // Debounce refresh to coalesce bursts of updates
  Timer? _refreshDebounce;

  // Navigare luni - unificata pentru clasamentul combinat
  DateTime _selectedMonth = DateTime.now();

  // FIX: Cache pentru separarea datelor per consultant
  String? _currentConsultantToken;
  final Map<String, List<ConsultantRanking>> _consultantsRankingCache = {};
  final Map<String, List<TeamRanking>> _teamsRankingCache = {};
  final Map<String, List<UpcomingMeeting>> _upcomingMeetingsCache = {};
  final Map<String, ConsultantStats?> _consultantStatsCache = {};
  final Map<String, String?> _dutyAgentCache = {};

  // Fast month caches (key = yyyy-MM). Store computed rankings to avoid refetching when navigating months
  final Map<String, List<ConsultantRanking>> _consultantsRankingMonthCache = {};
  final Map<String, List<TeamRanking>> _teamsRankingMonthCache = {};

  // Cache for monthly counters snapshot: yyyy-MM -> token -> {forms, meetings}
  final Map<String, Map<String, Map<String, int>>> _monthlyCountersCache = {};

  // Short-lived consultants list cache to avoid duplicate reads across loaders
  List<Map<String, dynamic>>? _consultantsListCache;
  DateTime? _consultantsListCacheTime;
  static const Duration _consultantsListTtl = Duration(seconds: 60);

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
      final role = await RoleService().refreshRole();
      final isSupervisor = role == UserRole.supervisor;
      // Load selected month, then prefetch adjacent months in background
      await Future.wait([
        _loadConsultantsRanking(isSupervisor: isSupervisor),
        _loadTeamsRanking(isSupervisor: isSupervisor),
      ]);

      // Fire-and-forget prefetch for previous and next months to make subsequent nav instant
      _prefetchAdjacentMonths(isSupervisor: isSupervisor);
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
    // Coalescing: evita incarcari simultane
    if (_isLoading) {
      return;
    }
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
      final isSupervisor = (await RoleService().refreshRole()) == UserRole.supervisor;
      final futures = <Future<void>>[
        _loadConsultantStats(),
        _loadUpcomingMeetings(),
        _loadConsultantsRanking(isSupervisor: isSupervisor),
        _loadTeamsRanking(isSupervisor: isSupervisor),
        _loadDutyAgent(),
      ];

      // Asteapta toate task-urile sa se termine
      await Future.wait(futures);

      // Warm caches around the current month without blocking UI
      _prefetchAdjacentMonths(isSupervisor: isSupervisor);
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error loading data: $e');
      _errorMessage = 'Eroare la incarcarea datelor: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizeaza datele dashboard-ului
  Future<void> refreshData() async {
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(milliseconds: 200), () async {
      await loadDashboardData();
    });
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
  Future<void> _loadConsultantsRanking({bool isSupervisor = false}) async {
    try {
      debugPrint('📊 DASHBOARD_SERVICE: Loading consultants ranking | isSupervisor: $isSupervisor');
      
      final yearMonth = DateFormat('yyyy-MM').format(_selectedMonth);

      // Fast path: use month cache if available
      final cachedMonthConsultants = _consultantsRankingMonthCache[yearMonth];
      if (cachedMonthConsultants != null && cachedMonthConsultants.isNotEmpty) {
        _consultantsRanking = cachedMonthConsultants;
        return;
      }

      // Get consultants list with short-lived cache
      final consultants = await _getAllConsultantsFast();
      if (consultants.isEmpty) {
        _consultantsRanking = [];
        return;
      }

      // Read all monthly totals in a single query, fallback per-token only if fields are missing
      final monthlyTotals = await _readAllMonthlyCountersForMonth(yearMonth);

      final List<ConsultantRanking> rankings = [];
      for (final data in consultants) {
        final consultantToken = data['token'] as String?;
        if (consultantToken == null || consultantToken.isEmpty) continue;

        Map<String, int>? counters = monthlyTotals[consultantToken];
        // Fallback only if fields are absent in monthly doc
        counters ??= await _readMonthlyCountersForToken(yearMonth, consultantToken);

        final forms = counters['forms'] ?? 0;
        final meetings = counters['meetings'] ?? 0;
        final score = (forms * 5) + (meetings * 10);
        rankings.add(ConsultantRanking(
          id: data['id'] as String? ?? '',
          name: data['name'] as String? ?? 'Necunoscut',
          team: data['team'] as String? ?? '',
          score: score,
          formsCompleted: forms,
          callsMade: 0,
          meetingsScheduled: meetings,
        ));
      }

      rankings.sort((a, b) => b.score.compareTo(a.score));
      _consultantsRanking = rankings;
      _consultantsRankingMonthCache[yearMonth] = rankings;
      debugPrint('📊 DASHBOARD_SERVICE: Loaded ${rankings.length} consultants | isSupervisor: $isSupervisor | Teams excluded: ${rankings.where((r) => r.team.isEmpty).length}');
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error loading consultants: $e');
      _consultantsRanking = [];
    }
  }

  /// Incarca clasamentul echipelor din Firebase (FIX: foloseste consultantToken pentru stats)
  Future<void> _loadTeamsRanking({bool isSupervisor = false}) async {
    try {
      debugPrint('📊 DASHBOARD_SERVICE: Loading teams ranking | isSupervisor: $isSupervisor');
      
      final yearMonth = DateFormat('yyyy-MM').format(_selectedMonth);
      // Fast path: use month cache if available
      final cachedMonthTeams = _teamsRankingMonthCache[yearMonth];
      if (cachedMonthTeams != null && cachedMonthTeams.isNotEmpty) {
        _teamsRanking = cachedMonthTeams;
        debugPrint('📊 DASHBOARD_SERVICE: Loaded ${cachedMonthTeams.length} teams from cache | isSupervisor: $isSupervisor');
        return;
      }

      // Get consultants list with short-lived cache
      final consultants = await _getAllConsultantsFast();
      final Map<String, Map<String, int>> teamStats = {};

      // Read all monthly totals once
      final monthlyTotals = await _readAllMonthlyCountersForMonth(yearMonth);

      for (final data in consultants) {
        final consultantToken = data['token'] as String?;
        final teamId = data['team'] as String? ?? '';
        if (consultantToken == null || (teamId).isEmpty) continue;

        final counters = monthlyTotals[consultantToken] ?? await _readMonthlyCountersForToken(yearMonth, consultantToken);
        final forms = counters['forms'] ?? 0;
        final meetings = counters['meetings'] ?? 0;
        final consultantScore = (forms * 5) + (meetings * 10);

        teamStats.putIfAbsent(teamId, () => {'forms': 0, 'meetings': 0, 'members': 0, 'score': 0});
        teamStats[teamId]!['forms'] = teamStats[teamId]!['forms']! + forms;
        teamStats[teamId]!['meetings'] = teamStats[teamId]!['meetings']! + meetings;
        teamStats[teamId]!['members'] = teamStats[teamId]!['members']! + 1;
        teamStats[teamId]!['score'] = teamStats[teamId]!['score']! + consultantScore;
      }
      
      final teamNames = await _consultantService.getAllTeams();
      // Include always the 3 predefined teams even if there are no consultants
      final Set<String> baseTeams = {
        'Echipa Andreea',
        'Echipa Cristina',
        'Echipa Scarlat',
      };
      final Set<String> allTeamNames = {...baseTeams, ...teamNames};
      debugPrint('📊 DASHBOARD_SERVICE: Found teams (with base): ${allTeamNames.toList()}');
      final teamRankings = allTeamNames.where((teamName) => teamName != 'Supervisor').map((teamName) {
        final stats = teamStats[teamName] ?? {'forms': 0, 'meetings': 0, 'members': 0, 'score': 0};
        
        return TeamRanking(
          id: teamName,
          teamName: teamName,
          memberCount: stats['members']!,
          formsCompleted: stats['forms']!,
          meetingsHeld: stats['meetings']!,
          score: stats['score']!,
        );
      }).toList();

      teamRankings.sort((a, b) => b.score.compareTo(a.score));
      _teamsRanking = teamRankings;
      _teamsRankingMonthCache[yearMonth] = teamRankings;
      debugPrint('📊 DASHBOARD_SERVICE: Loaded ${teamRankings.length} teams | isSupervisor: $isSupervisor');
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
      final dailyFormsToday = await _readDailyFormsCompletedToday(consultantToken);
      final dailyMeetingsToday = await _readDailyMeetingsScheduledToday(consultantToken);
      
      _consultantStats = ConsultantStats(
        formsCompletedToday: dailyFormsToday,
        dailyFormsTarget: 10, // Placeholder
        formsCompletedThisMonth: stats['formsCompleted'] ?? 0,
        totalMeetingsScheduled: stats['meetingsScheduled'] ?? 0,
        meetingsScheduledToday: dailyMeetingsToday,
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
      // Prefer new system: sharded counters under data/stats/monthly/{ym}/consultants/{token}/counters/*
      final parentDoc = _firestore
          .collection('data')
          .doc('stats')
          .collection('monthly')
          .doc(yearMonth)
          .collection('consultants')
          .doc(consultantToken);

      final formsFromShards = await _getShardedCounterTotal(
        parentDoc: parentDoc,
        counterGroup: 'forms',
      );
      final meetingsFromShards = await _getShardedCounterTotal(
        parentDoc: parentDoc,
        counterGroup: 'meetings',
      );

      if (formsFromShards > 0 || meetingsFromShards > 0 || await _hasAnyShards(parentDoc)) {
        return {
          'formsCompleted': formsFromShards,
          'meetingsScheduled': meetingsFromShards,
        };
      }

      // Fallback to old fields on the monthly doc
      final monthlyDoc = await _threadHandler.executeOnPlatformThread(
        () => parentDoc.get(),
      );
      if (monthlyDoc.exists) {
        final data = monthlyDoc.data();
        final formsCompleted = (data?['formsCompleted'] ?? 0) as num;
        final meetingsHeld = (data?['meetingsHeld'] ?? 0) as num;
        return {
          'formsCompleted': formsCompleted.toInt(),
          'meetingsScheduled': meetingsHeld.toInt(),
        };
      }
      return {'formsCompleted': 0, 'meetingsScheduled': 0};
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
    _consultantsRankingMonthCache.clear();
    _teamsRankingMonthCache.clear();
    _monthlyCountersCache.clear();
    _consultantsListCache = null;
    _consultantsListCacheTime = null;
    super.dispose();
    debugPrint('🗑️ DASHBOARD_SERVICE: Disposed with cache cleanup');
  }

  /// Returns total value of a sharded counter under parentDoc/counters/{counterGroup}/shards/*
  Future<int> _getShardedCounterTotal({
    required DocumentReference<Map<String, dynamic>> parentDoc,
    required String counterGroup,
  }) async {
    try {
      final shardsSnap = await parentDoc
          .collection('counters')
          .doc(counterGroup)
          .collection('shards')
          .get();

      if (shardsSnap.docs.isEmpty) return 0;

      int total = 0;
      for (final doc in shardsSnap.docs) {
        final data = doc.data();
        final count = (data['count'] ?? 0) as num;
        total += count.toInt();
      }
      return total;
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error reading sharded counter $counterGroup: $e');
      return 0;
    }
  }

  /// Checks if there is any shard present for either forms or meetings
  Future<bool> _hasAnyShards(DocumentReference<Map<String, dynamic>> parentDoc) async {
    try {
      final forms = await _threadHandler.executeOnPlatformThread(
        () => parentDoc
            .collection('counters')
            .doc('forms')
            .collection('shards')
            .limit(1)
            .get(),
      );
      if (forms.docs.isNotEmpty) return true;
      final meetings = await _threadHandler.executeOnPlatformThread(
        () => parentDoc
            .collection('counters')
            .doc('meetings')
            .collection('shards')
            .limit(1)
            .get(),
      );
      return meetings.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Reads daily forms completed today from sharded counters (fallback to old field)
  Future<int> _readDailyFormsCompletedToday(String consultantToken) async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final dailyParent = _firestore
          .collection('data')
          .doc('stats')
          .collection('daily')
          .doc(today)
          .collection('consultants')
          .doc(consultantToken);

      final fromShards = await _getShardedCounterTotal(
        parentDoc: dailyParent,
        counterGroup: 'forms',
      );
      if (fromShards > 0 || await _hasAnyShards(dailyParent)) {
        return fromShards;
      }

      final dailyDoc = await _threadHandler.executeOnPlatformThread(
        () => dailyParent.get(),
      );
      if (dailyDoc.exists) {
        final data = dailyDoc.data();
        final val = (data?['formsCompleted'] ?? 0) as num;
        return val.toInt();
      }
      return 0;
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error reading daily forms today: $e');
      return 0;
    }
  }

  /// Reads daily meetings scheduled today from sharded counters (fallback to old field)
  Future<int> _readDailyMeetingsScheduledToday(String consultantToken) async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final dailyParent = _firestore
          .collection('data')
          .doc('stats')
          .collection('daily')
          .doc(today)
          .collection('consultants')
          .doc(consultantToken);

      final fromShards = await _getShardedCounterTotal(
        parentDoc: dailyParent,
        counterGroup: 'meetings',
      );
      if (fromShards > 0 || await _hasAnyShards(dailyParent)) {
        return fromShards;
      }

      final dailyDoc = await _threadHandler.executeOnPlatformThread(
        () => dailyParent.get(),
      );
      if (dailyDoc.exists) {
        final data = dailyDoc.data();
        final val = (data?['meetingsHeld'] ?? 0) as num;
        return val.toInt();
      }
      return 0;
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error reading daily meetings today: $e');
      return 0;
    }
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
      final consultantsSnapshot = await _threadHandler.executeOnPlatformThread(
        () => _firestore.collection('consultants').get(),
      );
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

      // Refs
      final monthlyDocRef = _firestore
          .collection('data')
          .doc('stats')
          .collection('monthly')
          .doc(yearMonth)
          .collection('consultants')
          .doc(consultantToken);
      final monthlyCountedRef = monthlyDocRef.collection('countedMeetings').doc(clientPhoneNumber);

      final dailyDocRef = _firestore
          .collection('data')
          .doc('stats')
          .collection('daily')
          .doc(today)
          .collection('consultants')
          .doc(consultantToken);
      final dailyCountedRef = dailyDocRef.collection('countedMeetings').doc(clientPhoneNumber);

      // Atomic dedup + increments via transaction
      // On desktop platforms avoid Firestore transactions due to plugin instability; use safe fallback
      final useFallback = !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
      if (useFallback) {
        debugPrint('DASHBOARD_SERVICE: desktop detected → using non-transactional path for meetings');
        await _recordMeetingWithoutTransaction(consultantToken, clientPhoneNumber, yearMonth, today, now);
      } else {
        try {
          debugPrint('DASHBOARD_SERVICE: starting transaction for meetings');
          await _threadHandler.executeTransaction((transaction) async {
          debugPrint('DASHBOARD_SERVICE: txn read monthlyCountedRef');
        final monthlyCountedSnap = await transaction.get(monthlyCountedRef);
        if (!monthlyCountedSnap.exists) {
            debugPrint('DASHBOARD_SERVICE: txn write monthly increments');
          transaction.set(monthlyCountedRef, {'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
          transaction.set(monthlyDocRef, {
            'meetingsHeld': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          // Increment sharded counter (monthly)
          final shardId = (DateTime.now().microsecondsSinceEpoch % DashboardService._counterShards).toString();
          final monthlyShardRef = monthlyDocRef
              .collection('counters')
              .doc('meetings')
              .collection('shards')
              .doc(shardId);
          transaction.set(monthlyShardRef, {'count': FieldValue.increment(1)}, SetOptions(merge: true));
        }

          debugPrint('DASHBOARD_SERVICE: txn read dailyCountedRef');
          final dailyCountedSnap = await transaction.get(dailyCountedRef);
        if (!dailyCountedSnap.exists) {
            debugPrint('DASHBOARD_SERVICE: txn write daily increments');
          transaction.set(dailyCountedRef, {'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
          transaction.set(dailyDocRef, {
            'meetingsHeld': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
            'expireAt': Timestamp.fromDate(now.add(const Duration(days: 32))),
          }, SetOptions(merge: true));
          // Increment sharded counter (daily)
          final shardId2 = (DateTime.now().microsecondsSinceEpoch % DashboardService._counterShards).toString();
          final dailyShardRef = dailyDocRef
              .collection('counters')
              .doc('meetings')
              .collection('shards')
              .doc(shardId2);
          transaction.set(dailyShardRef, {'count': FieldValue.increment(1)}, SetOptions(merge: true));
        }
        return null;
          });
          debugPrint('DASHBOARD_SERVICE: transaction for meetings completed');
        } catch (e) {
          debugPrint('⚠️ DASHBOARD_SERVICE: Transaction failed for meetings, attempting non-transactional fallback: $e');
          await _recordMeetingWithoutTransaction(consultantToken, clientPhoneNumber, yearMonth, today, now);
        }
      }

      debugPrint('✅ DASHBOARD_SERVICE: Successfully incremented meetings for consultant in $yearMonth');

      // Invalidate caches and refresh
      _consultantsRankingCache.remove(consultantToken);
      _teamsRankingCache.remove(consultantToken);
      _consultantStatsCache.remove(consultantToken);

      _refreshDebounce?.cancel();
      _refreshDebounce = Timer(const Duration(milliseconds: 200), () async {
        try {
          await _refreshConsultantsRankingForSelectedMonth();
          await _loadConsultantStats();
          Future.microtask(() {
            notifyListeners();
          });
        } catch (e) {
          debugPrint('❌ DASHBOARD_SERVICE: Error in async refresh after meeting creation: $e');
        }
      });
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error in onMeetingCreated: $e');
    }
  }

  Future<void> _recordMeetingWithoutTransaction(
    String consultantToken,
    String clientPhoneNumber,
    String yearMonth,
    String today,
    DateTime now,
  ) async {
    try {
      final monthlyDocRef = _firestore
          .collection('data')
          .doc('stats')
          .collection('monthly')
          .doc(yearMonth)
          .collection('consultants')
          .doc(consultantToken);
      final monthlyCountedRef = monthlyDocRef.collection('countedMeetings').doc(clientPhoneNumber);

      final dailyDocRef = _firestore
          .collection('data')
          .doc('stats')
          .collection('daily')
          .doc(today)
          .collection('consultants')
          .doc(consultantToken);
      final dailyCountedRef = dailyDocRef.collection('countedMeetings').doc(clientPhoneNumber);

      final monthlyCounted = await _threadHandler.executeOnPlatformThread(() => monthlyCountedRef.get());
      if (!monthlyCounted.exists) {
        await _threadHandler.executeOnPlatformThread(() => monthlyCountedRef.set({'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true)));
        await _threadHandler.executeOnPlatformThread(() => monthlyDocRef.set({
              'meetingsHeld': FieldValue.increment(1),
              'lastUpdated': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true)));
        final shardId = (DateTime.now().microsecondsSinceEpoch % DashboardService._counterShards).toString();
        final monthlyShardRef = monthlyDocRef
            .collection('counters')
            .doc('meetings')
            .collection('shards')
            .doc(shardId);
        await _threadHandler.executeOnPlatformThread(() => monthlyShardRef.set({'count': FieldValue.increment(1)}, SetOptions(merge: true)));
      }

      final dailyCounted = await _threadHandler.executeOnPlatformThread(() => dailyCountedRef.get());
      if (!dailyCounted.exists) {
        await _threadHandler.executeOnPlatformThread(() => dailyCountedRef.set({'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true)));
        await _threadHandler.executeOnPlatformThread(() => dailyDocRef.set({
              'meetingsHeld': FieldValue.increment(1),
              'lastUpdated': FieldValue.serverTimestamp(),
              'expireAt': Timestamp.fromDate(now.add(const Duration(days: 32))),
            }, SetOptions(merge: true)));
        final shardId2 = (DateTime.now().microsecondsSinceEpoch % DashboardService._counterShards).toString();
        final dailyShardRef = dailyDocRef
            .collection('counters')
            .doc('meetings')
            .collection('shards')
            .doc(shardId2);
        await _threadHandler.executeOnPlatformThread(() => dailyShardRef.set({'count': FieldValue.increment(1)}, SetOptions(merge: true)));
      }
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Fallback record meeting failed: $e');
    }
  }
  
  /// Notifica serviciul ca un formular a fost finalizat (FIX: robust cu tracking clienti contorizati)
  Future<void> onFormCompleted(String consultantToken, String clientPhoneNumber) async {
    try {
      final now = DateTime.now();
      final yearMonth = DateFormat('yyyy-MM').format(now);
      final today = DateFormat('yyyy-MM-dd').format(now);

      debugPrint('📈 DASHBOARD_SERVICE: Recording form completion for consultant ${consultantToken.substring(0, 8)}... in $yearMonth for client $clientPhoneNumber');

      final monthlyDocRef = _firestore
          .collection('data')
          .doc('stats')
          .collection('monthly')
          .doc(yearMonth)
          .collection('consultants')
          .doc(consultantToken);
      final monthlyCountedRef = monthlyDocRef.collection('countedForms').doc(clientPhoneNumber);

      final dailyDocRef = _firestore
          .collection('data')
          .doc('stats')
          .collection('daily')
          .doc(today)
          .collection('consultants')
          .doc(consultantToken);
      final dailyCountedRef = dailyDocRef.collection('countedForms').doc(clientPhoneNumber);

      // Atomic dedup + increments via transaction
      final useFallbackForms = !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
      if (useFallbackForms) {
        debugPrint('DASHBOARD_SERVICE: desktop detected → using non-transactional path for forms');
        await _recordFormWithoutTransaction(consultantToken, clientPhoneNumber, yearMonth, today, now);
      } else {
        try {
          debugPrint('DASHBOARD_SERVICE: starting transaction for forms');
          await _threadHandler.executeTransaction((transaction) async {
          debugPrint('DASHBOARD_SERVICE: txn read monthlyCountedRef (forms)');
        final monthlyCountedSnap = await transaction.get(monthlyCountedRef);
        if (!monthlyCountedSnap.exists) {
            debugPrint('DASHBOARD_SERVICE: txn write monthly increments (forms)');
          transaction.set(monthlyCountedRef, {'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
          transaction.set(monthlyDocRef, {
            'formsCompleted': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          // Increment sharded counter (monthly)
          final shardId = (DateTime.now().microsecondsSinceEpoch % DashboardService._counterShards).toString();
          final monthlyShardRef = monthlyDocRef
              .collection('counters')
              .doc('forms')
              .collection('shards')
              .doc(shardId);
          transaction.set(monthlyShardRef, {'count': FieldValue.increment(1)}, SetOptions(merge: true));
        }

          debugPrint('DASHBOARD_SERVICE: txn read dailyCountedRef (forms)');
          final dailyCountedSnap = await transaction.get(dailyCountedRef);
        if (!dailyCountedSnap.exists) {
            debugPrint('DASHBOARD_SERVICE: txn write daily increments (forms)');
          transaction.set(dailyCountedRef, {'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
          transaction.set(dailyDocRef, {
            'formsCompleted': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
            'expireAt': Timestamp.fromDate(now.add(const Duration(days: 32))),
          }, SetOptions(merge: true));
          // Increment sharded counter (daily)
          final shardId2 = (DateTime.now().microsecondsSinceEpoch % DashboardService._counterShards).toString();
          final dailyShardRef = dailyDocRef
              .collection('counters')
              .doc('forms')
              .collection('shards')
              .doc(shardId2);
          transaction.set(dailyShardRef, {'count': FieldValue.increment(1)}, SetOptions(merge: true));
        }
        return null;
          });
          debugPrint('DASHBOARD_SERVICE: transaction for forms completed');
        } catch (e) {
          debugPrint('⚠️ DASHBOARD_SERVICE: Transaction failed for forms, attempting non-transactional fallback: $e');
          await _recordFormWithoutTransaction(consultantToken, clientPhoneNumber, yearMonth, today, now);
        }
      }

      debugPrint('✅ DASHBOARD_SERVICE: Successfully incremented forms for consultant in $yearMonth');

      _consultantsRankingCache.remove(consultantToken);
      _teamsRankingCache.remove(consultantToken);
      _consultantStatsCache.remove(consultantToken);

      _refreshDebounce?.cancel();
      _refreshDebounce = Timer(const Duration(milliseconds: 200), () async {
        try {
          await _refreshConsultantsRankingForSelectedMonth();
          await _loadConsultantStats();
          Future.microtask(() {
            notifyListeners();
          });
        } catch (e) {
          debugPrint('❌ DASHBOARD_SERVICE: Error in async refresh after form completion: $e');
        }
      });
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error in onFormCompleted: $e');
    }
  }

  Future<void> _recordFormWithoutTransaction(
    String consultantToken,
    String clientPhoneNumber,
    String yearMonth,
    String today,
    DateTime now,
  ) async {
    try {
      final monthlyDocRef = _firestore
          .collection('data')
          .doc('stats')
          .collection('monthly')
          .doc(yearMonth)
          .collection('consultants')
          .doc(consultantToken);
      final monthlyCountedRef = monthlyDocRef.collection('countedForms').doc(clientPhoneNumber);

      final dailyDocRef = _firestore
          .collection('data')
          .doc('stats')
          .collection('daily')
          .doc(today)
          .collection('consultants')
          .doc(consultantToken);
      final dailyCountedRef = dailyDocRef.collection('countedForms').doc(clientPhoneNumber);

      final monthlyCounted = await monthlyCountedRef.get();
      if (!monthlyCounted.exists) {
        await monthlyCountedRef.set({'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
        await monthlyDocRef.set({
          'formsCompleted': FieldValue.increment(1),
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        final shardId = (DateTime.now().microsecondsSinceEpoch % DashboardService._counterShards).toString();
        await monthlyDocRef
            .collection('counters')
            .doc('forms')
            .collection('shards')
            .doc(shardId)
            .set({'count': FieldValue.increment(1)}, SetOptions(merge: true));
      }

      final dailyCounted = await dailyCountedRef.get();
      if (!dailyCounted.exists) {
        await dailyCountedRef.set({'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
        await dailyDocRef.set({
          'formsCompleted': FieldValue.increment(1),
          'lastUpdated': FieldValue.serverTimestamp(),
          'expireAt': Timestamp.fromDate(now.add(const Duration(days: 32))),
        }, SetOptions(merge: true));
        final shardId2 = (DateTime.now().microsecondsSinceEpoch % DashboardService._counterShards).toString();
        await dailyDocRef
            .collection('counters')
            .doc('forms')
            .collection('shards')
            .doc(shardId2)
            .set({'count': FieldValue.increment(1)}, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Fallback record form failed: $e');
    }
  }
}

extension _ShardedCounters on DashboardService {
  /// Helper: reads monthly counters for a consultant token via shards with fallback
  Future<Map<String, int>> _readMonthlyCountersForToken(String yearMonth, String consultantToken) async {
    try {
      final parentDoc = _firestore
          .collection('data')
          .doc('stats')
          .collection('monthly')
          .doc(yearMonth)
          .collection('consultants')
          .doc(consultantToken);

      final forms = await _getShardedCounterTotal(parentDoc: parentDoc, counterGroup: 'forms');
      final meetings = await _getShardedCounterTotal(parentDoc: parentDoc, counterGroup: 'meetings');
      if (forms > 0 || meetings > 0 || await _hasAnyShards(parentDoc)) {
        return {'forms': forms, 'meetings': meetings};
      }

      final doc = await parentDoc.get();
      if (doc.exists) {
        final data = doc.data();
        return {
          'forms': ((data?['formsCompleted'] ?? 0) as num).toInt(),
          'meetings': ((data?['meetingsHeld'] ?? 0) as num).toInt(),
        };
      }
      return {'forms': 0, 'meetings': 0};
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error reading monthly counters for token: $e');
      return {'forms': 0, 'meetings': 0};
    }
  }

  /// Reads all monthly counters for the given month with a single collection get
  /// Returns: token -> {forms, meetings}. Uses cached snapshot when possible.
  Future<Map<String, Map<String, int>>> _readAllMonthlyCountersForMonth(String yearMonth) async {
    // Return cached if present
    final cached = _monthlyCountersCache[yearMonth];
    if (cached != null) return cached;

    try {
      final parentCollection = _firestore
          .collection('data')
          .doc('stats')
          .collection('monthly')
          .doc(yearMonth)
          .collection('consultants');

      final snap = await _threadHandler.executeOnPlatformThread(
        () => parentCollection.get(),
      );

      final Map<String, Map<String, int>> result = {};
      for (final doc in snap.docs) {
        final data = doc.data();
        final formsCompleted = (data['formsCompleted'] ?? 0) as num;
        final meetingsHeld = (data['meetingsHeld'] ?? 0) as num;
        // Only add if fields exist or non-zero to indicate presence; zeros are valid
        if (data.containsKey('formsCompleted') || data.containsKey('meetingsHeld')) {
          result[doc.id] = {
            'forms': formsCompleted.toInt(),
            'meetings': meetingsHeld.toInt(),
          };
        }
      }

      _monthlyCountersCache[yearMonth] = result;
      return result;
    } catch (e) {
      debugPrint('❌ DASHBOARD_SERVICE: Error reading all monthly counters for $yearMonth: $e');
      return {};
    }
  }

  /// Returns all consultants with minimal fields using a short-lived in-memory cache
  Future<List<Map<String, dynamic>>> _getAllConsultantsFast() async {
    final now = DateTime.now();
    if (_consultantsListCache != null && _consultantsListCacheTime != null &&
        now.difference(_consultantsListCacheTime!) < DashboardService._consultantsListTtl) {
      return _consultantsListCache!;
    }

    final consultantsSnapshot = await _threadHandler.executeOnPlatformThread(
      () => _firestore.collection('consultants').get(),
    );
    final list = consultantsSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] as String? ?? 'Necunoscut',
        'team': data['team'] as String? ?? '',
        'token': data['token'] as String? ?? '',
      };
    }).toList();

    _consultantsListCache = list;
    _consultantsListCacheTime = now;
    return list;
  }

  /// Prefetch previous and next months into caches without updating UI
  void _prefetchAdjacentMonths({required bool isSupervisor}) {
    final current = _selectedMonth;
    final prev = DateTime(current.year, current.month - 1, 1);
    final next = DateTime(current.year, current.month + 1, 1);

    Future<void> warm(String ym) async {
      // Short-circuit if both caches already have this month
      final hasConsultants = _consultantsRankingMonthCache.containsKey(ym);
      final hasTeams = _teamsRankingMonthCache.containsKey(ym);
      if (hasConsultants && hasTeams) return;

      try {
        final consultants = await _getAllConsultantsFast();
        final totals = await _readAllMonthlyCountersForMonth(ym);

        if (!hasConsultants) {
          final List<ConsultantRanking> rankings = [];
          for (final data in consultants) {
            final token = data['token'] as String?;
            if (token == null || token.isEmpty) continue;
            final counters = totals[token] ?? {'forms': 0, 'meetings': 0};
            final forms = counters['forms'] ?? 0;
            final meetings = counters['meetings'] ?? 0;
            final score = (forms * 5) + (meetings * 10);
            rankings.add(ConsultantRanking(
              id: data['id'] as String? ?? '',
              name: data['name'] as String? ?? 'Necunoscut',
              team: data['team'] as String? ?? '',
              score: score,
              formsCompleted: forms,
              callsMade: 0,
              meetingsScheduled: meetings,
            ));
          }
          rankings.sort((a, b) => b.score.compareTo(a.score));
          _consultantsRankingMonthCache[ym] = rankings;
        }

        if (!hasTeams) {
          final Map<String, Map<String, int>> teamStats = {};
          for (final data in consultants) {
            final token = data['token'] as String?;
            final teamId = data['team'] as String? ?? '';
            if (token == null || teamId.isEmpty) continue;
            final counters = totals[token] ?? {'forms': 0, 'meetings': 0};
            final forms = counters['forms'] ?? 0;
            final meetings = counters['meetings'] ?? 0;
            final score = (forms * 5) + (meetings * 10);
            teamStats.putIfAbsent(teamId, () => {'forms': 0, 'meetings': 0, 'members': 0, 'score': 0});
            teamStats[teamId]!['forms'] = teamStats[teamId]!['forms']! + forms;
            teamStats[teamId]!['meetings'] = teamStats[teamId]!['meetings']! + meetings;
            teamStats[teamId]!['members'] = teamStats[teamId]!['members']! + 1;
            teamStats[teamId]!['score'] = teamStats[teamId]!['score']! + score;
          }

          final teamNames = await _consultantService.getAllTeams();
          final Set<String> baseTeams = {'Echipa Andreea', 'Echipa Cristina', 'Echipa Scarlat'};
          final Set<String> allTeamNames = {...baseTeams, ...teamNames};
          final teamRankings = allTeamNames.where((t) => t != 'Supervisor').map((teamName) {
            final stats = teamStats[teamName] ?? {'forms': 0, 'meetings': 0, 'members': 0, 'score': 0};
            return TeamRanking(
              id: teamName,
              teamName: teamName,
              memberCount: stats['members']!,
              formsCompleted: stats['forms']!,
              meetingsHeld: stats['meetings']!,
              score: stats['score']!,
            );
          }).toList()
            ..sort((a, b) => b.score.compareTo(a.score));

          _teamsRankingMonthCache[ym] = teamRankings;
        }
      } catch (_) {
        // Silent prefetch errors
      }
    }

    final ymPrev = DateFormat('yyyy-MM').format(prev);
    final ymNext = DateFormat('yyyy-MM').format(next);
    // Run in background
    // ignore: discarded_futures
    Future.microtask(() => warm(ymPrev));
    // ignore: discarded_futures
    Future.microtask(() => warm(ymNext));
  }
}

