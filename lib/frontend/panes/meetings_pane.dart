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
/// 
/// Aceasta este o componenta care afiseaza lista intalnirilor viitoare ale utilizatorului,
/// folosind componentele lightItem7 si darkItem7 pentru afisare.
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
  
  // Data cache for meetings
  List<ClientActivity> _allAppointments = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    // FIX: Adaugă listener pentru actualizare automată când se modifică datele în SplashService
    _splashService.addListener(_onSplashServiceChanged);
    
    // Foloseste serviciul pre-incarcat din splash - accesez firebaseService din ClientUIService
    _initializeFormatters();
    _startPeriodicRefresh();
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    // FIX: Cleanup listener pentru a evita memory leaks
    _splashService.removeListener(_onSplashServiceChanged);
    super.dispose();
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
      
      await _loadUpcomingMeetings();
    } catch (e) {
      debugPrint("Error initializing formatters: $e");
      setState(() {
        _isInitializing = false;
      });
    }
  }
  
  /// Start periodic refresh to keep meetings up to date (disabled - refresh only when needed)
  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    // Removed automatic refresh - will only refresh when explicitly needed
  }

  /// Actualizeaza lista de intalniri din cache (apelat dupa salvari/editari)
  void refreshMeetings() {
    if (mounted) {
      _loadUpcomingMeetings();
    }
  }

  /// Incarca intalnirile viitoare doar pentru consultantul curent (FIX: folosește cache SplashService)
  Future<void> _loadUpcomingMeetings() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      debugPrint("❌ MEETINGS_PANE: User not authenticated");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint("📋 MEETINGS_PANE: Loading upcoming meetings for current consultant: $currentUserId");
      
      // FIX: Folosește cache-ul din SplashService pentru performanță și sincronizare
      final allMeetings = await _splashService.getCachedMeetings();
      final now = DateTime.now();
      
      // Filtrează întâlnirile viitoare ale consultantului curent  
      final List<ClientActivity> futureAppointments = [];
      final currentConsultantToken = await _getCurrentConsultantToken();
      
      for (final meeting in allMeetings) {
        // FIX: Debug pentru fiecare întâlnire
        debugPrint('🔍 MEETINGS_PANE: Checking meeting: ${meeting.additionalData?['clientName']}');
        debugPrint('  - Meeting dateTime: ${meeting.dateTime}');
        debugPrint('  - Current time (now): $now');
        debugPrint('  - Is in future: ${meeting.dateTime.isAfter(now)}');
        debugPrint('  - Meeting consultantId: ${meeting.additionalData?['consultantId']}');
        debugPrint('  - Current user ID: $currentUserId');
        debugPrint('  - Current consultant token: ${currentConsultantToken?.substring(0, 8) ?? 'NULL'}');
        
        // Verifică dacă întâlnirea este în viitor
        if (!meeting.dateTime.isAfter(now)) {
          debugPrint('  - ❌ Rejected: Meeting is in the past');
          continue;
        }
        
        // Verifică dacă întâlnirea aparține consultantului curent
        final meetingConsultantId = meeting.additionalData?['consultantId'] as String?;
        
        // FIX: Pentru întâlnirile noi, folosește consultantId
        if (meetingConsultantId != null) {
          if (meetingConsultantId != currentUserId) {
            debugPrint('  - ❌ Rejected: Consultant ID does not match (using consultantId)');
            continue;
          }
        } else {
          // FIX: Pentru întâlnirile existente (fără consultantId), folosește consultantToken
          final meetingConsultantToken = meeting.additionalData?['consultantToken'] as String?;
          if (meetingConsultantToken == null) {
            debugPrint('  - ❌ Rejected: No consultant identification found');
            continue;
          }
          
          if (meetingConsultantToken != currentConsultantToken) {
            debugPrint('  - ❌ Rejected: Consultant token does not match (using consultantToken fallback)');
            continue;
          }
        }
        
        debugPrint('  - ✅ Accepted: Future meeting for current consultant');
        futureAppointments.add(meeting);
      }

      // Sortează după data
      futureAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      debugPrint("✅ MEETINGS_PANE: Found ${allMeetings.length} total meetings, ${futureAppointments.length} future meetings for current consultant");

      if (mounted) {
        setState(() {
          _allAppointments = futureAppointments;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ MEETINGS_PANE: Error loading upcoming meetings for consultant: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
