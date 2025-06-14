import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'clients_service.dart';
import 'dashboard_service.dart';

/// Tipul de întâlnire
enum MeetingType {
  meeting,      // Întâlnire cu clientul
  bureauDelete  // Ștergere birou de credit
}

/// Model pentru datele unei întâlniri
class MeetingData {
  final String? id;
  final String clientName;
  final String phoneNumber;
  final DateTime dateTime;
  final MeetingType type;
  final String consultantId;
  final String consultantName;

  MeetingData({
    this.id,
    required this.clientName,
    required this.phoneNumber,
    required this.dateTime,
    required this.type,
    required this.consultantId,
    required this.consultantName,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'clientName': clientName,
      'phoneNumber': phoneNumber,
      'dateTime': Timestamp.fromDate(dateTime),
      'type': type == MeetingType.meeting ? 'meeting' : 'bureauDelete',
      'consultantId': consultantId,
      'consultantName': consultantName,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory MeetingData.fromFirestore(Map<String, dynamic> data, String id) {
    return MeetingData(
      id: id,
      clientName: data['clientName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      type: data['type'] == 'bureauDelete' ? MeetingType.bureauDelete : MeetingType.meeting,
      consultantId: data['consultantId'] ?? '',
      consultantName: data['consultantName'] ?? '',
    );
  }
}

/// Service pentru gestionarea întâlnirilor folosind noua structură unificată
class MeetingService {
  static final MeetingService _instance = MeetingService._internal();
  factory MeetingService() => _instance;
  MeetingService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ClientsFirebaseService _clientService = ClientsFirebaseService();

  User? get currentUser => _auth.currentUser;

  /// Creează o nouă întâlnire în noua structură
  Future<Map<String, dynamic>> createMeeting(MeetingData meetingData) async {
    final user = currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Utilizator neautentificat'};
    }

    try {
      // Verifică dacă slotul este disponibil
      final isAvailable = await _isTimeSlotAvailable(meetingData.dateTime);
      if (!isAvailable) {
        return {'success': false, 'message': 'Slotul de timp nu este disponibil'};
      }

      // Obține datele consultantului
      final consultantData = await _getConsultantData(user.uid);
      if (consultantData == null) {
        return {'success': false, 'message': 'Date consultant negăsite'};
      }

      // Verifică dacă clientul există, dacă nu îl creează
          final existingClient = await _clientService.getClient(meetingData.phoneNumber);
    if (existingClient == null) {
      await _clientService.createClient(
          phoneNumber: meetingData.phoneNumber,
          name: meetingData.clientName,
          source: 'meeting_service',
        );
      }

      // Programează întâlnirea în noua structură
      final success = await _clientService.scheduleMeeting(
        meetingData.phoneNumber,
        meetingData.dateTime,
        description: meetingData.type == MeetingType.bureauDelete 
            ? 'Ștergere birou credit' 
            : 'Întâlnire programată',
        type: meetingData.type == MeetingType.meeting ? 'meeting' : 'bureauDelete',
        additionalData: {
          'consultantId': user.uid,
          'consultantName': consultantData['name'] ?? 'Necunoscut',
        },
      );

      if (success) {
        debugPrint("✅ Meeting created successfully in unified structure for: ${meetingData.clientName}");
        
        // Notifică dashboard-ul că s-a programat o întâlnire
        _notifyDashboardMeetingScheduled();
        
        return {'success': true, 'message': 'Întâlnire creată cu succes'};
      } else {
        return {'success': false, 'message': 'Eroare la salvarea întâlnirii în noua structură'};
      }
    } catch (e) {
      debugPrint("❌ Error createMeeting: $e");
      return {'success': false, 'message': 'Eroare la crearea întâlnirii: $e'};
    }
  }

  /// Notifică dashboard-ul că s-a programat o întâlnire
  void _notifyDashboardMeetingScheduled() {
    try {
      final dashboardService = DashboardService();
      dashboardService.onMeetingScheduled();
    } catch (e) {
      debugPrint('Error notifying dashboard about scheduled meeting: $e');
    }
  }

  /// Actualizează o întâlnire existentă în noua structură
  Future<Map<String, dynamic>> updateMeeting(String meetingId, MeetingData meetingData) async {
    final user = currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Utilizator neautentificat'};
    }

    try {
      // Verifică dacă noul slot este disponibil
      final isAvailable = await _isTimeSlotAvailable(meetingData.dateTime, excludePhoneNumber: meetingData.phoneNumber);
      if (!isAvailable) {
        return {'success': false, 'message': 'Noul slot de timp nu este disponibil'};
      }

      // Actualizează întâlnirea în noua structură
      final success = await _clientService.updateMeeting(
        meetingData.phoneNumber,
        meetingId,
        dateTime: meetingData.dateTime,
        description: meetingData.type == MeetingType.bureauDelete 
            ? 'Ștergere birou credit' 
            : 'Întâlnire programată',
        type: meetingData.type == MeetingType.meeting ? 'meeting' : 'bureauDelete',
      );

      if (success) {
        return {'success': true, 'message': 'Întâlnire actualizată cu succes'};
      } else {
        return {'success': false, 'message': 'Eroare la actualizarea întâlnirii în noua structură'};
      }
    } catch (e) {
      debugPrint("❌ Error updateMeeting: $e");
      return {'success': false, 'message': 'Eroare la actualizarea întâlnirii: $e'};
    }
  }

  /// Șterge o întâlnire din noua structură
  Future<Map<String, dynamic>> deleteMeeting(String meetingId) async {
    final user = currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Utilizator neautentificat'};
    }

    try {
      // Găsește întâlnirea în toate clientele consultantului
      final allMeetings = await _clientService.getAllMeetings();
      final targetMeeting = allMeetings.firstWhere(
        (meeting) => meeting.id == meetingId,
        orElse: () => throw Exception('Meeting not found'),
      );

      // Extrage phoneNumber din additionalData
      final phoneNumber = targetMeeting.additionalData?['phoneNumber'] as String?;
      if (phoneNumber == null) {
        return {'success': false, 'message': 'Nu s-a putut identifica clientul pentru această întâlnire'};
      }

      // Șterge întâlnirea din noua structură
      final success = await _clientService.deleteMeeting(phoneNumber, meetingId);

      if (success) {
        return {'success': true, 'message': 'Întâlnire ștearsă cu succes'};
      } else {
        return {'success': false, 'message': 'Eroare la ștergerea întâlnirii din noua structură'};
      }
    } catch (e) {
      debugPrint("❌ Error deleteMeeting: $e");
      return {'success': false, 'message': 'Eroare la ștergerea întâlnirii: $e'};
    }
  }

  /// Obține orele disponibile pentru o anumită dată
  Future<List<String>> getAvailableTimeSlots(DateTime date, {String? excludeId}) async {
    try {
      // Folosește orele de lucru definite în CalendarService
      final List<String> allSlots = [
        '09:30', '10:00', '10:30', '11:00', '11:30', 
        '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
        '15:00', '15:30', '16:00'
      ];

      // Obține întâlnirile echipei pentru această dată din noua structură
      final teamMeetingsForDate = await _clientService.getTeamMeetingsForDate(date);
      
      // Extrage orele ocupate (excluzând întâlnirea specificată dacă există)
      final Set<String> occupiedSlots = {};
      for (var meeting in teamMeetingsForDate) {
        // Skip the meeting we're editing
        if (excludeId != null && meeting.id == excludeId) continue;
        
        final meetingDateTime = meeting.dateTime;
        final timeSlot = DateFormat('HH:mm').format(meetingDateTime);
        occupiedSlots.add(timeSlot);
      }

      // Returnează sloturile disponibile
      return allSlots.where((slot) => !occupiedSlots.contains(slot)).toList();
    } catch (e) {
      debugPrint("❌ Error getAvailableTimeSlots: $e");
      return [];
    }
  }

  /// Obține întâlnirile pentru o săptămână din noua structură
  Stream<List<MeetingData>> getMeetingsForWeek(DateTime startOfWeek, DateTime endOfWeek) {
    try {
      // Returnăm un stream care emite periodic datele din noua structură
      return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
        final allMeetings = await _clientService.getAllMeetings();
        
        // Filtrează întâlnirile pentru săptămâna specificată
        final weekMeetings = allMeetings.where((meeting) {
          final meetingDate = meeting.dateTime;
          return meetingDate.isAfter(startOfWeek) && meetingDate.isBefore(endOfWeek);
        }).toList();

        // Convertește în format MeetingData
        return weekMeetings.map((meeting) => MeetingData(
          id: meeting.id,
          clientName: meeting.additionalData?['clientName'] ?? 'Client necunoscut',
          phoneNumber: meeting.additionalData?['phoneNumber'] ?? '',
          dateTime: meeting.dateTime,
          type: meeting.type == ClientActivityType.bureauDelete 
              ? MeetingType.bureauDelete 
              : MeetingType.meeting,
          consultantId: meeting.additionalData?['consultantId'] ?? '',
          consultantName: meeting.additionalData?['consultantName'] ?? '',
        )).toList();
      });
    } catch (e) {
      debugPrint("❌ Error creating getMeetingsForWeek stream: $e");
      return Stream<List<MeetingData>>.empty();
    }
  }

  /// Obține întâlnirile viitoare pentru consultantul curent din noua structură
  Stream<List<MeetingData>> getUpcomingMeetings({int limit = 10}) {
    final user = currentUser;
    if (user == null) {
      debugPrint("❌ No authenticated user for getUpcomingMeetings");
      return Stream<List<MeetingData>>.empty();
    }

    try {
      return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
        final allMeetings = await _clientService.getAllMeetings();
        final now = DateTime.now();
        
        // Filtrează întâlnirile viitoare pentru consultantul curent
        final upcomingMeetings = allMeetings
            .where((meeting) => meeting.dateTime.isAfter(now))
            .take(limit)
            .toList();

        // Sortează după dată
        upcomingMeetings.sort((a, b) => a.dateTime.compareTo(b.dateTime));

        // Convertește în format MeetingData
        return upcomingMeetings.map((meeting) => MeetingData(
          id: meeting.id,
          clientName: meeting.additionalData?['clientName'] ?? 'Client necunoscut',
          phoneNumber: meeting.additionalData?['phoneNumber'] ?? '',
          dateTime: meeting.dateTime,
          type: meeting.type == ClientActivityType.bureauDelete 
              ? MeetingType.bureauDelete 
              : MeetingType.meeting,
          consultantId: meeting.additionalData?['consultantId'] ?? '',
          consultantName: meeting.additionalData?['consultantName'] ?? '',
        )).toList();
      });
    } catch (e) {
      debugPrint("❌ Error creating getUpcomingMeetings stream: $e");
      return Stream<List<MeetingData>>.empty();
    }
  }

  /// Obține o întâlnire specifică din noua structură
  Future<MeetingData?> getMeeting(String meetingId) async {
    try {
      final allMeetings = await _clientService.getAllMeetings();
      final targetMeeting = allMeetings.firstWhere(
        (meeting) => meeting.id == meetingId,
        orElse: () => throw Exception('Meeting not found'),
      );

      // Convertește din ClientActivity în MeetingData
      return MeetingData(
        id: targetMeeting.id,
        clientName: targetMeeting.additionalData?['clientName'] ?? 'Client necunoscut',
        phoneNumber: targetMeeting.additionalData?['phoneNumber'] ?? '',
        dateTime: targetMeeting.dateTime,
        type: targetMeeting.type == ClientActivityType.bureauDelete 
            ? MeetingType.bureauDelete 
            : MeetingType.meeting,
        consultantId: targetMeeting.additionalData?['consultantId'] ?? '',
        consultantName: targetMeeting.additionalData?['consultantName'] ?? '',
      );
    } catch (e) {
      debugPrint("❌ Error getMeeting: $e");
      return null;
    }
  }

  /// Helper: verifică dacă un slot de timp este disponibil
  Future<bool> _isTimeSlotAvailable(DateTime dateTime, {String? excludePhoneNumber}) async {
    try {
      return await _clientService.isTimeSlotAvailable(dateTime, excludePhoneNumber: excludePhoneNumber);
    } catch (e) {
      debugPrint("❌ Error _isTimeSlotAvailable: $e");
      return false;
    }
  }

  /// Helper: obține datele consultantului
  Future<Map<String, dynamic>?> _getConsultantData(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('consultants').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint("❌ Error _getConsultantData: $e");
      return null;
    }
  }
}


