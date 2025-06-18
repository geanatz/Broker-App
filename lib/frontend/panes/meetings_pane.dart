import 'package:broker_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:broker_app/frontend/components/items/light_item7.dart';
import 'package:broker_app/frontend/components/items/dark_item7.dart';

import '../../backend/services/clients_service.dart';
import '../../backend/services/splash_service.dart';

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
    // Foloseste serviciul pre-incarcat din splash - accesez firebaseService din ClientUIService
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

  /// Actualizeaza lista de intalniri din cache (apelat dupa salvari/editari)
  void refreshMeetings() {
    if (mounted) {
      _loadUpcomingMeetings();
    }
  }

  /// Incarca intalnirile viitoare din noua structura unificata
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
      debugPrint("📋 Loading upcoming meetings from cache for consultant: $currentUserId");
      
      // Obtine toate intalnirile din cache-ul din splash (instant)
      final allMeetings = await SplashService().getCachedMeetings();
      final now = DateTime.now();
      
      // Filtreaza doar intalnirile viitoare
      final futureAppointments = allMeetings.where((meeting) {
        return meeting.dateTime.isAfter(now);
      }).toList();

      // Sorteaza dupa data
      futureAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      debugPrint("✅ Found ${allMeetings.length} total meetings, ${futureAppointments.length} future meetings (from cache)");

      if (mounted) {
        setState(() {
          _allAppointments = futureAppointments;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading upcoming meetings from cache: $e");
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
