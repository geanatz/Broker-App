import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/frontend/common/components/items/lightItem7.dart';
import 'package:broker_app/frontend/common/components/items/darkItem7.dart';
import 'package:broker_app/backend/services/meetingService.dart';
import '../../backend/services/unified_client_service.dart';
import '../../backend/models/unified_client_model.dart';

/// Widget pentru panoul de intâlniri
/// 
/// Aceasta este o componentă care afișează lista întâlnirilor viitoare ale utilizatorului,
/// folosind componentele lightItem7 și darkItem7 pentru afișare.
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
  final MeetingService _meetingService = MeetingService();
  final UnifiedClientService _unifiedService = UnifiedClientService();
  
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
    _initializeFormatters();
    _startPeriodicRefresh();
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
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

  /// Public method to refresh meetings data when needed
  void refreshMeetings() {
    _loadUpcomingMeetings();
  }

  /// Încarcă întâlnirile viitoare din noua structură unificată
  Future<void> _loadUpcomingMeetings() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      debugPrint("User not authenticated");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint("Loading upcoming meetings from unified structure for consultant: $currentUserId");
      
      // Obține toate întâlnirile din noua structură unificată
      final allMeetings = await _unifiedService.getAllMeetings();
      final now = DateTime.now();
      
      // Filtrează doar întâlnirile viitoare
      final futureAppointments = allMeetings.where((meeting) {
        return meeting.dateTime.isAfter(now);
      }).toList();

      // Sortează după dată
      futureAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      debugPrint("Found ${allMeetings.length} total meetings, ${futureAppointments.length} future meetings");

      if (mounted) {
        setState(() {
          _allAppointments = futureAppointments;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading upcoming meetings from unified structure: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Verifică dacă două map-uri sunt egale
  bool _areMapsEqual(Map<String, dynamic>? map1, Map<String, dynamic>? map2) {
    if (map1 == null || map2 == null) return map1 == map2;
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) {
        return false;
      }
    }
    return true;
  }
  
  // Calculează timpul rămas până la întâlnire în format text
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
      return 'in $hours ${hours == 1 ? 'oră' : 'ore'}';
    } else if (minutes > 0) {
      return 'in $minutes ${minutes == 1 ? 'minut' : 'minute'}';
    } else {
      return 'acum';
    }
  }
  
  // Verifică dacă întâlnirea este în următoarele 30 de minute
  bool _isWithin30Minutes(DateTime meetingDateTime) {
    final now = DateTime.now();
    final difference = meetingDateTime.difference(now);
    return difference.inMinutes <= 30 && difference.inMinutes >= 0;
  }
  
  // Navighează la întâlnirea din calendar
  void _navigateToCalendarMeeting(String meetingId) {
    if (widget.onNavigateToMeeting != null) {
      widget.onNavigateToMeeting!(meetingId);
    } else {
      debugPrint('Navigate to calendar meeting: $meetingId');
    }
  }
  
  // Marchează întâlnirea ca terminată (placeholder)
  void _markMeetingAsDone(String meetingId) {
    debugPrint('Mark meeting as done: $meetingId');
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
          
          // Lista întâlnirilor
          Expanded(
            child: _buildMeetingsList(),
          ),
        ],
      ),
    );
  }
  
  /// Construiește lista de întâlniri folosind noua structură unificată
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
        final clientName = meeting.additionalData?['clientName'] ?? 'Client necunoscut';
        final clientPhone = meeting.additionalData?['phoneNumber'] ?? '';
        final meetingId = meeting.id ?? '';
        
        // Calculează timpul rămas
        final timeUntil = _getTimeUntilMeeting(dateTime);
        final isUrgent = _isWithin30Minutes(dateTime);
        
        // Formatează data și ora
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
