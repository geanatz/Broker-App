import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'clients_service.dart';
import 'dashboard_service.dart';

/// Tipul de intalnire
enum MeetingType {
  meeting,      // Intalnire cu clientul
  bureauDelete  // Stergere birou de credit
}

/// Model pentru datele unei intalniri
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

/// Service pentru gestionarea intalnirilor folosind noua structura unificata
class MeetingService {
  static final MeetingService _instance = MeetingService._internal();
  factory MeetingService() => _instance;
  MeetingService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ClientsFirebaseService _clientService = ClientsFirebaseService();
  final String _noClientIdentifier = 'meetings_without_client';

  User? get currentUser => _auth.currentUser;

  /// Creeaza o noua intalnire in noua structura
  Future<Map<String, dynamic>> createMeeting(MeetingData meetingData) async {
    final user = currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Utilizator neautentificat'};
    }

    try {
      // Verifica daca slotul este disponibil
      final isAvailable = await _isTimeSlotAvailable(meetingData.dateTime);
      if (!isAvailable) {
        return {'success': false, 'message': 'Slotul de timp nu este disponibil'};
      }

      // Obtine datele consultantului
      final consultantData = await _getConsultantData(user.uid);
      if (consultantData == null) {
        return {'success': false, 'message': 'Date consultant negasite'};
      }

      final clientPhoneNumber = meetingData.phoneNumber.trim();
      final isClientless = clientPhoneNumber.isEmpty;
      final clientIdentifier = isClientless ? _noClientIdentifier : clientPhoneNumber;

      // Asigura-te ca exista un document "container" pentru intalnire
      final clientDoc = await _clientService.getClient(clientIdentifier);
      if (clientDoc == null) {
        await _clientService.createClient(
          phoneNumber: clientIdentifier,
          name: isClientless ? 'Întâlniri generale' : meetingData.clientName,
          source: isClientless ? 'system_internal' : 'meeting_service',
        );
      }

      // Programeaza intalnirea sub identificatorul de client determinat
      final success = await _clientService.scheduleMeeting(
        clientIdentifier,
        meetingData.dateTime,
        description: meetingData.type == MeetingType.bureauDelete 
            ? 'Stergere birou credit' 
            : 'Intalnire programata',
        type: meetingData.type == MeetingType.meeting ? 'meeting' : 'bureauDelete',
        additionalData: {
          'consultantId': user.uid,
          'consultantName': consultantData['name'] ?? 'Necunoscut',
          'clientName': meetingData.clientName, // Numele real din popup
          'phoneNumber': clientPhoneNumber, // Telefonul real din popup
        },
      );

      if (success) {
        debugPrint("✅ Meeting created successfully in unified structure for: ${meetingData.clientName}");
        
        // Notifica dashboard-ul ca s-a programat o intalnire
        DashboardService().onMeetingCreated(user.uid);
        
        return {'success': true, 'message': 'Intalnire creata cu succes'};
      } else {
        return {'success': false, 'message': 'Eroare la salvarea intalnirii in noua structura'};
      }
    } catch (e) {
      debugPrint("❌ Error createMeeting: $e");
      return {'success': false, 'message': 'Eroare la crearea intalnirii: $e'};
    }
  }

  /// Actualizeaza o intalnire existenta in noua structura
  Future<Map<String, dynamic>> updateMeeting(String meetingId, MeetingData meetingData) async {
    final user = currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Utilizator neautentificat'};
    }

    try {
      // Verifica daca noul slot este disponibil
      final isAvailable = await _isTimeSlotAvailable(meetingData.dateTime, excludePhoneNumber: meetingData.phoneNumber);
      if (!isAvailable) {
        return {'success': false, 'message': 'Noul slot de timp nu este disponibil'};
      }

      // Actualizeaza intalnirea in noua structura
      final success = await _clientService.updateMeeting(
        meetingData.phoneNumber,
        meetingId,
        dateTime: meetingData.dateTime,
        description: meetingData.type == MeetingType.bureauDelete 
            ? 'Stergere birou credit' 
            : 'Intalnire programata',
        type: meetingData.type == MeetingType.meeting ? 'meeting' : 'bureauDelete',
      );

      if (success) {
        return {'success': true, 'message': 'Intalnire actualizata cu succes'};
      } else {
        return {'success': false, 'message': 'Eroare la actualizarea intalnirii in noua structura'};
      }
    } catch (e) {
      debugPrint("❌ Error updateMeeting: $e");
      return {'success': false, 'message': 'Eroare la actualizarea intalnirii: $e'};
    }
  }

  /// Sterge o intalnire din noua structura
  Future<Map<String, dynamic>> deleteMeeting(String meetingId) async {
    final user = currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Utilizator neautentificat'};
    }

    try {
      // Gaseste intalnirea in toate clientele consultantului
      final allMeetings = await _clientService.getAllMeetings();
      final targetMeeting = allMeetings.firstWhere(
        (meeting) => meeting.id == meetingId,
        orElse: () => throw Exception('Meeting not found'),
      );

      // Extrage phoneNumber din additionalData si determina identificatorul clientului
      final phoneNumber = (targetMeeting.additionalData?['phoneNumber'] as String?)?.trim() ?? '';
      final isClientless = phoneNumber.isEmpty;
      final clientIdentifier = isClientless ? _noClientIdentifier : phoneNumber;

      // Sterge intalnirea folosind identificatorul corect
      final success = await _clientService.deleteMeeting(clientIdentifier, meetingId);

      if (success) {
        return {'success': true, 'message': 'Intalnire stearsa cu succes'};
      } else {
        return {'success': false, 'message': 'Eroare la stergerea intalnirii din noua structura'};
      }
    } catch (e) {
      debugPrint("❌ Error deleteMeeting: $e");
      return {'success': false, 'message': 'Eroare la stergerea intalnirii: $e'};
    }
  }

  /// Obtine orele disponibile pentru o anumita data
  Future<List<String>> getAvailableTimeSlots(DateTime date, {String? excludeId}) async {
    try {
      // Foloseste orele de lucru definite in CalendarService
      final List<String> allSlots = [
        '09:30', '10:00', '10:30', '11:00', '11:30', 
        '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
        '15:00', '15:30', '16:00'
      ];

      // Obtine intalnirile echipei pentru aceasta data din noua structura
      final teamMeetingsForDate = await _clientService.getTeamMeetingsForDate(date);
      
      // Extrage orele ocupate (excluzand intalnirea specificata daca exista)
      final Set<String> occupiedSlots = {};
      for (var meeting in teamMeetingsForDate) {
        // Skip the meeting we're editing
        if (excludeId != null && meeting.id == excludeId) continue;
        
        final meetingDateTime = meeting.dateTime;
        final timeSlot = DateFormat('HH:mm').format(meetingDateTime);
        occupiedSlots.add(timeSlot);
      }

      // Returneaza sloturile disponibile
      return allSlots.where((slot) => !occupiedSlots.contains(slot)).toList();
    } catch (e) {
      debugPrint("❌ Error getAvailableTimeSlots: $e");
      return [];
    }
  }

  /// Obtine intalnirile pentru o saptamana din noua structura
  Stream<List<MeetingData>> getMeetingsForWeek(DateTime startOfWeek, DateTime endOfWeek) {
    try {
      // Returnam un stream care emite periodic datele din noua structura
      return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
        final allMeetings = await _clientService.getAllMeetings();
        
        // Filtreaza intalnirile pentru saptamana specificata
        final weekMeetings = allMeetings.where((meeting) {
          final meetingDate = meeting.dateTime;
          return meetingDate.isAfter(startOfWeek) && meetingDate.isBefore(endOfWeek);
        }).toList();

        // Converteste in format MeetingData
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

  /// Obtine intalnirile viitoare pentru consultantul curent din noua structura
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
        
        // Filtreaza intalnirile viitoare pentru consultantul curent
        final upcomingMeetings = allMeetings
            .where((meeting) => meeting.dateTime.isAfter(now))
            .take(limit)
            .toList();

        // Sorteaza dupa data
        upcomingMeetings.sort((a, b) => a.dateTime.compareTo(b.dateTime));

        // Converteste in format MeetingData
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

  /// Obtine o intalnire specifica din noua structura
  Future<MeetingData?> getMeeting(String meetingId) async {
    try {
      final allMeetings = await _clientService.getAllMeetings();
      final targetMeeting = allMeetings.firstWhere(
        (meeting) => meeting.id == meetingId,
        orElse: () => throw Exception('Meeting not found'),
      );

      // Converteste din ClientActivity in MeetingData
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

  /// Helper: verifica daca un slot de timp este disponibil
  Future<bool> _isTimeSlotAvailable(DateTime dateTime, {String? excludePhoneNumber}) async {
    try {
      return await _clientService.isTimeSlotAvailable(dateTime, excludePhoneNumber: excludePhoneNumber);
    } catch (e) {
      debugPrint("❌ Error _isTimeSlotAvailable: $e");
      return false;
    }
  }

  /// Helper: obtine datele consultantului
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


