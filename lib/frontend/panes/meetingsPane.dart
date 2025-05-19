import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/old/screens/calendar/calendar_widgets.dart';

/// Widget pentru panoul de intâlniri
/// 
/// Aceasta este o componentă care afișează lista întâlnirilor viitoare ale utilizatorului,
/// extrasă din componenta CalendarArea și transformată într-un panou distinct.
class MeetingsPane extends StatefulWidget {
  final Function? onClose;

  const MeetingsPane({
    Key? key,
    this.onClose,
  }) : super(key: key);

  @override
  State<MeetingsPane> createState() => _MeetingsPaneState();
}

class _MeetingsPaneState extends State<MeetingsPane> {
  // Firebase reference
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Formatter pentru date
  DateFormat? dateFormatter;
  bool _isInitializing = true;
  
  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
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
      print('Error initializing date formatting: $e');
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
  
  /// Construiește lista de întâlniri
  Widget _buildMeetingsList() {
    final TextStyle secondaryStyle = TextStyle(
      fontSize: AppTheme.fontSizeMedium, 
      color: AppTheme.elementColor2
    );

    final currentUserId = _auth.currentUser?.uid;

    return currentUserId == null
        ? Center(child: Text("Utilizator neconectat", style: secondaryStyle))
        : UpcomingAppointmentsList(
            userId: currentUserId, 
            dateFormatter: dateFormatter!,
          );
  }
}
