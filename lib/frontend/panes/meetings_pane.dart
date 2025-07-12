import 'package:broker_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:broker_app/frontend/components/items/light_item7.dart';
import 'package:broker_app/frontend/components/items/dark_item7.dart';

import '../../backend/services/clients_service.dart';
import '../../backend/services/splash_service.dart';
import '../../backend/services/firebase_service.dart';

/// Widget pentru panoul de intalniri
/// OPTIMIZAT: Implementare avansată cu cache inteligent și loading instant
class MeetingsPane extends StatefulWidget {
  final Function? onClose;
  final Function(String)? onNavigateToMeeting;

  const MeetingsPane({
    super.key,
    this.onClose,
    this.onNavigateToMeeting,
  });

  @override
  State<MeetingsPane> createState() => MeetingsPaneState();
}

class MeetingsPaneState extends State<MeetingsPane> {
  // Firebase reference
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // FIX: Adăugat SplashService pentru listener automat
  final SplashService _splashService = SplashService();
  
  // Formatter pentru date
  DateFormat? dateFormatter;
  DateFormat? timeFormatter;
  bool _isInitializing = true;
  
  // OPTIMIZARE: Data cache for meetings cu timestamp
  List<ClientActivity> _allAppointments = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  
  // OPTIMIZARE: Debouncing îmbunătățit pentru load meetings
  Timer? _loadDebounceTimer;
  bool _isLoadingMeetings = false;
  DateTime? _lastLoadTime;
  
  @override
  void initState() {
    super.initState();
    // FIX: Adaugă listener pentru actualizare automată când se modifică datele în SplashService
    _splashService.addListener(_onSplashServiceChanged);
    
    // Foloseste serviciul pre-incarcat din splash - accesez firebaseService din ClientUIService
    _initializeFormatters();
    
    // OPTIMIZARE: Încarcă imediat din cache pentru loading instant și sincronizare completă
    _loadFromCacheInstantly();
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    _loadDebounceTimer?.cancel();
    // FIX: Cleanup listener pentru a evita memory leaks
    _splashService.removeListener(_onSplashServiceChanged);
    super.dispose();
  }

  /// OPTIMIZARE: Încarcă imediat din cache pentru loading instant și sincronizare completă
  Future<void> _loadFromCacheInstantly() async {
    try {
      // Încarcă întâlnirile din cache instant
      final allMeetings = await _splashService.getCachedMeetings();
      final now = DateTime.now();
      
      // Filtrează întâlnirile viitoare ale consultantului curent  
      final List<ClientActivity> futureAppointments = [];
      final currentConsultantToken = await _getCurrentConsultantToken();
      
      for (final meeting in allMeetings) {
        // Verifică dacă întâlnirea este în viitor
        if (!meeting.dateTime.isAfter(now)) {
          continue;
        }
        
        // Verifică dacă întâlnirea aparține consultantului curent
        final meetingConsultantId = meeting.additionalData?['consultantId'] as String?;
        
        // FIX: Pentru întâlnirile noi, folosește consultantId
        if (meetingConsultantId != null) {
          if (meetingConsultantId != _auth.currentUser?.uid) {
            continue;
          }
        } else {
          // FIX: Pentru întâlnirile existente (fără consultantId), folosește consultantToken
          final meetingConsultantToken = meeting.additionalData?['consultantToken'] as String?;
          if (meetingConsultantToken == null) {
            continue;
          }
          
          if (meetingConsultantToken != currentConsultantToken) {
            continue;
          }
        }
        
        futureAppointments.add(meeting);
      }

      // Sortează după data
      futureAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      if (mounted) {
        setState(() {
          _allAppointments = futureAppointments;
          _isLoading = false;
          _lastLoadTime = DateTime.now();
        });
      }
      
      // OPTIMIZARE: Log redus pentru performanță
      // debugPrint('✅ MEETINGS_PANE: Loaded ${_allAppointments.length} upcoming meetings instantly from cache');
    } catch (e) {
      debugPrint('❌ MEETINGS_PANE: Error loading from cache: $e');
      // Fallback to normal loading
      await _loadUpcomingMeetings();
    }
  }

  /// FIX: Callback pentru refresh automat când se schimbă datele în SplashService
  void _onSplashServiceChanged() {
    if (mounted) {
      debugPrint('📋 MEETINGS_PANE: SplashService changed, refreshing meetings automatically');
      _loadUpcomingMeetings();
    }
  }
  
  void _initializeFormatters() async {
    try {
      dateFormatter = DateFormat('dd MMM yyyy', 'ro_RO');
      timeFormatter = DateFormat('HH:mm', 'ro_RO');
      
      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      debugPrint("Error initializing formatters: $e");
      setState(() {
        _isInitializing = false;
      });
    }
  }
  


  /// Actualizeaza lista de intalniri din cache (apelat dupa salvari/editari)
  void refreshMeetings() {
    if (mounted) {
      _loadUpcomingMeetings();
    }
  }

  /// OPTIMIZAT: Incarca intalnirile viitoare cu debouncing îmbunătățit
  Future<void> _loadUpcomingMeetings() async {
    // OPTIMIZARE: Verifică dacă cache-ul este recent (sub 3 secunde - redus de la 5)
    if (_lastLoadTime != null && 
        DateTime.now().difference(_lastLoadTime!).inSeconds < 3) {
      // OPTIMIZARE: Log redus pentru performanță
      // debugPrint('⏭️ MEETINGS_PANE: Skipping load - cache is recent');
      return;
    }
    
    // Anulează loading-ul anterior dacă există unul pending
    _loadDebounceTimer?.cancel();
    
    // Dacă deja se încarcă, nu mai face alt request
    if (_isLoadingMeetings) return;
    
    // OPTIMIZARE: Debouncing redus la 50ms pentru răspuns mai rapid (redus de la 100ms)
    _loadDebounceTimer = Timer(const Duration(milliseconds: 50), () async {
      await _performLoadUpcomingMeetings();
    });
  }

  /// OPTIMIZAT: Execută încărcarea efectivă a întâlnirilor
  Future<void> _performLoadUpcomingMeetings() async {
    if (_isLoadingMeetings) return;
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      debugPrint("❌ MEETINGS_PANE: User not authenticated");
      return;
    }

    // OPTIMIZARE: Set loading state only once
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      _isLoadingMeetings = true;
      
      // OPTIMIZARE: Folosește cache-ul din SplashService pentru performanță și sincronizare
      final allMeetings = await _splashService.getCachedMeetings();
      final now = DateTime.now();
      
      // Filtrează întâlnirile viitoare ale consultantului curent  
      final List<ClientActivity> futureAppointments = [];
      final currentConsultantToken = await _getCurrentConsultantToken();
      
      for (final meeting in allMeetings) {
        // Verifică dacă întâlnirea este în viitor
        if (!meeting.dateTime.isAfter(now)) {
          continue;
        }
        
        // Verifică dacă întâlnirea aparține consultantului curent
        final meetingConsultantId = meeting.additionalData?['consultantId'] as String?;
        
        // FIX: Pentru întâlnirile noi, folosește consultantId
        if (meetingConsultantId != null) {
          if (meetingConsultantId != currentUserId) {
            continue;
          }
        } else {
          // FIX: Pentru întâlnirile existente (fără consultantId), folosește consultantToken
          final meetingConsultantToken = meeting.additionalData?['consultantToken'] as String?;
          if (meetingConsultantToken == null) {
            continue;
          }
          
          if (meetingConsultantToken != currentConsultantToken) {
            continue;
          }
        }
        
        futureAppointments.add(meeting);
      }

      // Sortează după data
      futureAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      // OPTIMIZARE: Single state update with all data
      if (mounted) {
        setState(() {
          _allAppointments = futureAppointments;
          _isLoading = false;
          _lastLoadTime = DateTime.now();
        });
      }
      
      // OPTIMIZARE: Single log message
      debugPrint('✅ MEETINGS_PANE: Loaded ${_allAppointments.length} upcoming meetings');
    } catch (e) {
      debugPrint('❌ MEETINGS_PANE: Error loading team meetings from cache: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Keep existing cache on error
        });
      }
    } finally {
      _isLoadingMeetings = false;
    }
  }
  
  // Verifica daca doua map-uri sunt egale
  
  // Calculeaza timpul ramas pana la intalnire in format text
  String _getTimeUntilMeeting(DateTime meetingDateTime) {
    final now = DateTime.now();
    final difference = meetingDateTime.difference(now);
    
    if (difference.isNegative) {
      return 'Trecut';
    }
    
    final days = difference.inDays;
    final hours = difference.inHours;
    final minutes = difference.inMinutes;
    
    if (days > 0) {
      return 'in $days ${days == 1 ? 'zi' : 'zile'}';
    } else if (hours > 0) {
      return 'in $hours ${hours == 1 ? 'ora' : 'ore'}';
    } else if (minutes > 0) {
      return 'in $minutes ${minutes == 1 ? 'minut' : 'minute'}';
    } else {
      return 'acum';
    }
  }
  
  // Verifica daca intalnirea este in urmatoarele 30 de minute
  bool _isWithin30Minutes(DateTime meetingDateTime) {
    final now = DateTime.now();
    final difference = meetingDateTime.difference(now);
    return difference.inMinutes <= 30 && difference.inMinutes >= 0;
  }
  
  // Navigheaza la intalnirea din calendar
  void _navigateToCalendarMeeting(String meetingId) {
    if (widget.onNavigateToMeeting != null) {
      widget.onNavigateToMeeting!(meetingId);
    } else {
      debugPrint('Navigate to calendar meeting: $meetingId');
    }
  }
  
  // Marcheaza intalnirea ca terminata (placeholder)
  void _markMeetingAsDone(String meetingId) {
    debugPrint('Mark meeting as done: $meetingId');
  }
  
  /// FIX: Obține consultantToken-ul curent pentru comparația cu întâlnirile existente
  Future<String?> _getCurrentConsultantToken() async {
    try {
      // Folosește NewFirebaseService pentru a obține consultantToken-ul curent
      final firebaseService = NewFirebaseService();
      return await firebaseService.getCurrentConsultantToken();
    } catch (e) {
      debugPrint('❌ MEETINGS_PANE: Error getting current consultant token: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing || dateFormatter == null) {
      return Container(
        width: 312,
        height: double.infinity,
        padding: const EdgeInsets.all(AppTheme.smallGap),
        decoration: BoxDecoration(
          color: AppTheme.widgetBackground,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: [AppTheme.widgetShadow],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Container(
      width: 312,
      height: double.infinity,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: BoxDecoration(
        color: AppTheme.widgetBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: [AppTheme.widgetShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(left: AppTheme.mediumGap, right: AppTheme.mediumGap, bottom: AppTheme.tinyGap),
            child: Text(
              'Intalnirile mele',
              style: AppTheme.headerTitleStyle,
            ),
          ),
          
          // Lista intalnirilor
          Expanded(
            child: _buildMeetingsList(),
          ),
        ],
      ),
    );
  }
  
  /// Construieste lista de intalniri folosind noua structura unificata
  Widget _buildMeetingsList() {
    final currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      return Center(
        child: Text(
          "Utilizator neconectat",
          style: TextStyle(
            fontSize: AppTheme.fontSizeMedium, 
            color: AppTheme.elementColor2
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allAppointments.isEmpty) {
      return Center(
        child: Text(
          'Nicio programare viitoare',
          style: AppTheme.secondaryTitleStyle,
        )
      );
    }

    // Build the list view
    return ListView.builder(
      itemCount: _allAppointments.length,
      itemBuilder: (context, index) {
        final meeting = _allAppointments[index];
        final dateTime = meeting.dateTime;
        
        // Verifica si seteaza numele clientului
        String clientName = meeting.additionalData?['clientName'] ?? '';
        if (clientName.trim().isEmpty) {
          clientName = 'Client fara nume';
        }

        final clientPhone = meeting.additionalData?['phoneNumber'] ?? '';
        final meetingId = meeting.id;
        
        // Calculeaza timpul ramas
        final timeUntil = _getTimeUntilMeeting(dateTime);
        final isUrgent = _isWithin30Minutes(dateTime);
        
        // Formateaza data si ora
        final formattedDate = dateFormatter?.format(dateTime) ?? dateTime.toString();
        final formattedTime = timeFormatter?.format(dateTime) ?? dateTime.toString();
        
        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.smallGap),
          child: isUrgent 
            ? _buildUrgentMeetingItem(
                clientName: clientName,
                clientPhone: clientPhone,
                dateTime: dateTime,
                formattedDate: formattedDate,
                formattedTime: formattedTime,
                timeUntil: timeUntil,
                meetingId: meetingId,
              )
            : _buildNormalMeetingItem(
                clientName: clientName,
                clientPhone: clientPhone,
                dateTime: dateTime,
                formattedDate: formattedDate,
                formattedTime: formattedTime,
                timeUntil: timeUntil,
                meetingId: meetingId,
              ),
        );
      },
    );
  }

  Widget _buildUrgentMeetingItem({
    required String clientName,
    required String clientPhone,
    required DateTime dateTime,
    required String formattedDate,
    required String formattedTime,
    required String timeUntil,
    required String meetingId,
  }) {
    return DarkItem7(
      title: clientName,
      description: clientPhone.isNotEmpty ? clientPhone : timeUntil,
      svgAsset: 'assets/doneIcon.svg',
      onTap: () => _markMeetingAsDone(meetingId),
    );
  }

  Widget _buildNormalMeetingItem({
    required String clientName,
    required String clientPhone,
    required DateTime dateTime,
    required String formattedDate,
    required String formattedTime,
    required String timeUntil,
    required String meetingId,
  }) {
    return LightItem7(
      title: clientName,
      description: timeUntil,
      svgAsset: 'assets/viewIcon.svg',
      onTap: () => _navigateToCalendarMeeting(meetingId),
    );
  }
}
