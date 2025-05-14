import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'dart:async';
import 'package:async/async.dart';

import '../../theme/app_theme.dart';
import '../../services/reservation_service.dart';

/// Widget to build a meeting field in the upcoming list
Widget buildMeetingFieldWidget(Map<String, dynamic> meetingData, DateFormat dateFormatter) {
  final dateTime = (meetingData['dateTime'] as Timestamp).toDate();
  final hourString = DateFormat('HH:mm').format(dateTime);
  final dateString = dateFormatter.format(dateTime);
  final consultantName = meetingData['consultantName'] ?? 'N/A';
  final clientName = meetingData['clientName'] ?? 'N/A';

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    decoration: BoxDecoration(
      color: AppTheme.backgroundLightPurple,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                hourString,
                style: AppTheme.smallTextStyle,
              ),
            ),
            Text(
              dateString,
              style: AppTheme.smallTextStyle,
              textAlign: TextAlign.right,
            ),
          ],
        ),
        
        const SizedBox(height: 4),
        
        Text(
          consultantName, 
          style: AppTheme.primaryTitleStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          clientName,
          style: AppTheme.secondaryTitleStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

/// StatefulWidget for the Upcoming Appointments list
class UpcomingAppointmentsList extends StatefulWidget {
  final String userId;
  final DateFormat dateFormatter;

  const UpcomingAppointmentsList({
    Key? key,
    required this.userId,
    required this.dateFormatter,
  }) : super(key: key);

  @override
  State<UpcomingAppointmentsList> createState() => _UpcomingAppointmentsListState();
}

class _UpcomingAppointmentsListState extends State<UpcomingAppointmentsList> {
  late StreamSubscription _subscription;
  final Map<String, QueryDocumentSnapshot> _allAppointments = {};
  bool _isLoading = true;
  final ReservationService _reservationService = ReservationService();

  @override
  void initState() {
    super.initState();
    _subscribeToAppointments();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _subscribeToAppointments() {
    final reservationsStream = _reservationService.getUpcomingReservations();

    _subscription = reservationsStream.listen(
      (querySnapshot) {
        if (!mounted) return;
        
        bool dataChanged = false;
        
        // Use a synchronized block inside setState to update state atomically
        setState(() {
          for (var doc in querySnapshot.docs) {
            if (!_allAppointments.containsKey(doc.id) || 
                !_areMapsEqual(_allAppointments[doc.id]?.data() as Map<String, dynamic>?, doc.data() as Map<String, dynamic>?)) {
              _allAppointments[doc.id] = doc;
              dataChanged = true;
            }
          }

          // Handle removed appointments
          final currentIds = querySnapshot.docs.map((doc) => doc.id).toSet();
          final idsToRemove = _allAppointments.keys.where((id) => !currentIds.contains(id)).toList();
          for (var id in idsToRemove) {
            _allAppointments.remove(id);
            dataChanged = true;
          }

          // Update loading state if needed
          if (dataChanged || _isLoading) {
            _isLoading = false;
          }
        });
      },
      onError: (error) {
        print("Error in appointments stream: $error");
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Get the combined list from the map
    final sortedAppointments = _allAppointments.values.toList();

    // Sort the combined list
    sortedAppointments.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>?;
      final bData = b.data() as Map<String, dynamic>?;
      if (aData == null || bData == null || aData['dateTime'] == null || bData['dateTime'] == null) return 0;
      final aTime = aData['dateTime'] as Timestamp;
      final bTime = bData['dateTime'] as Timestamp;
      return aTime.compareTo(bTime);
    });

    if (sortedAppointments.isEmpty) {
      return Center(
        child: Text(
          'Nicio programare viitoare',
          style: AppTheme.secondaryTitleStyle,
        )
      );
    }

    // Build the list view
    return ListView.builder(
      itemCount: sortedAppointments.length,
      itemBuilder: (context, index) {
        final doc = sortedAppointments[index];
        final meetingData = doc.data() as Map<String, dynamic>;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.smallGap),
          child: buildMeetingFieldWidget(meetingData, widget.dateFormatter),
        );
      },
    );
  }
} 