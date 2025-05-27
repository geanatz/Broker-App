import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/frontend/common/components/items/lightItem7.dart';
import 'package:broker_app/frontend/common/components/items/darkItem7.dart';
import 'package:broker_app/backend/services/meetingService.dart';

/// Widget pentru panoul de intâlniri
/// 
/// Aceasta este o componentă care afișează lista întâlnirilor viitoare ale utilizatorului,
/// folosind componentele lightItem7 și darkItem7 pentru afișare.
class MeetingsPane extends StatefulWidget {
  final Function? onClose;
  final Function(String)? onNavigateToMeeting;

  const MeetingsPane({
    Key? key,
    this.onClose,
    this.onNavigateToMeeting,
  }) : super(key: key);

  @override
  State<MeetingsPane> createState() => MeetingsPaneState();
}

class MeetingsPaneState extends State<MeetingsPane> {
  // Firebase reference
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MeetingService _meetingService = MeetingService();
  
  // Formatter pentru date
  DateFormat? dateFormatter;
  bool _isInitializing = true;
  
  // Data cache for meetings
  List<QueryDocumentSnapshot> _allAppointments = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
    _loadUpcomingMeetings();
    _startPeriodicRefresh();
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  // Inițializăm formatarea datelor
  Future<void> _initializeDateFormatting() async {
    try {
      await initializeDateFormatting('ro', null);
      if (mounted) {
        setState(() {
          dateFormatter = DateFormat('d MMM', 'ro');
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          dateFormatter = DateFormat('d MMM');
          _isInitializing = false;
        });
      }
      debugPrint('Error initializing date formatting: $e');
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

  /// Load upcoming meetings for the current consultant
  Future<void> _loadUpcomingMeetings() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      // Use the start of today to ensure we get meetings from today onwards
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      
      debugPrint("Loading meetings for consultant: $currentUserId");
      debugPrint("Filtering meetings from: $startOfToday");
      

      
      // Use simple query with only consultantId to avoid composite index requirement
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('meetings')
          .where('consultantId', isEqualTo: currentUserId)
          .get()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('Firestore query timeout for meetings');
              throw TimeoutException('Query timeout', const Duration(seconds: 5));
            },
          );

      debugPrint("Found ${snapshot.docs.length} total meetings for consultant $currentUserId");
      
      // Filter for future meetings on client-side
      final futureAppointments = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final meetingDateTime = (data['dateTime'] as Timestamp).toDate();
        final isPastMeeting = meetingDateTime.isBefore(now);
        if (isPastMeeting) {
          debugPrint("Filtering out past meeting: ${doc.id} at $meetingDateTime");
        }
        return !isPastMeeting;
      }).toList();

      debugPrint("After filtering for future meetings: ${futureAppointments.length} remaining");

      if (mounted) {
        setState(() {
          _allAppointments = futureAppointments;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading upcoming meetings: $e");
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
      return 'în $days ${days == 1 ? 'zi' : 'zile'}';
    } else if (hours > 0) {
      return 'în $hours ${hours == 1 ? 'oră' : 'ore'}';
    } else if (minutes > 0) {
      return 'în $minutes ${minutes == 1 ? 'minut' : 'minute'}';
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
    // TODO: Implementează logica pentru marcarea întâlnirii ca terminată
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
            padding: const EdgeInsets.only(left: AppTheme.mediumGap, right: AppTheme.mediumGap, bottom: AppTheme.smallGap),
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
  
  /// Construiește lista de întâlniri folosind componentele lightItem7 și darkItem7
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

    // Sort the appointments list
    _allAppointments.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>?;
      final bData = b.data() as Map<String, dynamic>?;
      if (aData == null || bData == null || aData['dateTime'] == null || bData['dateTime'] == null) return 0;
      final aTime = aData['dateTime'] as Timestamp;
      final bTime = bData['dateTime'] as Timestamp;
      return aTime.compareTo(bTime);
    });

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
        final doc = _allAppointments[index];
        final meetingData = doc.data() as Map<String, dynamic>;
        final dateTime = (meetingData['dateTime'] as Timestamp).toDate();
        final clientName = meetingData['clientName'] ?? 'Client necunoscut';
        final clientPhone = meetingData['phoneNumber'] ?? '';
        final meetingId = doc.id;
        
        final timeUntilMeeting = _getTimeUntilMeeting(dateTime);
        final isUrgent = _isWithin30Minutes(dateTime);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.smallGap),
          child: isUrgent 
            ? DarkItem7(
                title: clientName,
                description: clientPhone.isNotEmpty ? clientPhone : timeUntilMeeting,
                svgAsset: 'assets/doneIcon.svg',
                onTap: () => _markMeetingAsDone(meetingId),
              )
            : LightItem7(
                title: clientName,
                description: timeUntilMeeting,
                svgAsset: 'assets/viewIcon.svg',
                onTap: () => _navigateToCalendarMeeting(meetingId),
              ),
        );
      },
    );
  }
}
