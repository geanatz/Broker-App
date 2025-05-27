import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

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

/// Service pentru gestionarea întâlnirilor (combină functionalitatea de creare și editare)
class MeetingService {
  static final MeetingService _instance = MeetingService._internal();
  factory MeetingService() => _instance;
  MeetingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collectionName = 'meetings';

  User? get currentUser => _auth.currentUser;

  /// Creează o nouă întâlnire
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

      // Creează întâlnirea cu datele consultantului
      final updatedMeetingData = MeetingData(
        clientName: meetingData.clientName,
        phoneNumber: meetingData.phoneNumber,
        dateTime: meetingData.dateTime,
        type: meetingData.type,
        consultantId: user.uid,
        consultantName: consultantData['name'] ?? 'Necunoscut',
      );

      debugPrint("Creating meeting with consultantId: ${user.uid}");
      debugPrint("Meeting dateTime: ${meetingData.dateTime}");
      debugPrint("Meeting data to save: ${updatedMeetingData.toFirestore()}");

      final docRef = await _firestore.collection(_collectionName).add(updatedMeetingData.toFirestore());
      debugPrint("Meeting created with ID: ${docRef.id}");
      
      return {'success': true, 'message': 'Întâlnire creată cu succes'};
    } catch (e) {
      debugPrint("Eroare createMeeting: $e");
      return {'success': false, 'message': 'Eroare la crearea întâlnirii: $e'};
    }
  }

  /// Actualizează o întâlnire existentă
  Future<Map<String, dynamic>> updateMeeting(String meetingId, MeetingData meetingData) async {
    final user = currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Utilizator neautentificat'};
    }

    try {
      // Verifică dacă întâlnirea există și aparține utilizatorului curent
      final doc = await _firestore.collection(_collectionName).doc(meetingId).get();
      if (!doc.exists) {
        return {'success': false, 'message': 'Întâlnirea nu a fost găsită'};
      }

      final existingData = doc.data()!;
      if (existingData['consultantId'] != user.uid) {
        return {'success': false, 'message': 'Nu aveți permisiunea să modificați această întâlnire'};
      }

      // Verifică dacă noul slot este disponibil (exclude întâlnirea curentă)
      final isAvailable = await _isTimeSlotAvailable(meetingData.dateTime, excludeId: meetingId);
      if (!isAvailable) {
        return {'success': false, 'message': 'Noul slot de timp nu este disponibil'};
      }

      // Actualizează întâlnirea
      final updateData = meetingData.toFirestore();
      updateData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection(_collectionName).doc(meetingId).update(updateData);
      
      return {'success': true, 'message': 'Întâlnire actualizată cu succes'};
    } catch (e) {
      debugPrint("Eroare updateMeeting: $e");
      return {'success': false, 'message': 'Eroare la actualizarea întâlnirii: $e'};
    }
  }

  /// Șterge o întâlnire
  Future<Map<String, dynamic>> deleteMeeting(String meetingId) async {
    final user = currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Utilizator neautentificat'};
    }

    try {
      // Verifică dacă întâlnirea există și aparține utilizatorului curent
      final doc = await _firestore.collection(_collectionName).doc(meetingId).get();
      if (!doc.exists) {
        return {'success': false, 'message': 'Întâlnirea nu a fost găsită'};
      }

      final data = doc.data()!;
      if (data['consultantId'] != user.uid) {
        return {'success': false, 'message': 'Nu aveți permisiunea să ștergeți această întâlnire'};
      }

      await _firestore.collection(_collectionName).doc(meetingId).delete();
      
      return {'success': true, 'message': 'Întâlnire ștearsă cu succes'};
    } catch (e) {
      debugPrint("Eroare deleteMeeting: $e");
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

      // Obține întâlnirile existente pentru această dată
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('dateTime', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      // Extrage orele ocupate (excluzând întâlnirea specificată dacă există)
      final Set<String> occupiedSlots = {};
      for (var doc in snapshot.docs) {
        if (excludeId != null && doc.id == excludeId) continue;
        
        final meetingDateTime = (doc.data() as Map<String, dynamic>)['dateTime'] as Timestamp;
        final meetingTime = meetingDateTime.toDate();
        final timeSlot = DateFormat('HH:mm').format(meetingTime);
        occupiedSlots.add(timeSlot);
      }

      // Returnează sloturile disponibile
      return allSlots.where((slot) => !occupiedSlots.contains(slot)).toList();
    } catch (e) {
      debugPrint("Eroare getAvailableTimeSlots: $e");
      return [];
    }
  }

  /// Obține întâlnirile pentru o săptămână (versiune simplificată fără orderBy)
  Stream<QuerySnapshot> getMeetingsForWeek(DateTime startOfWeek, DateTime endOfWeek) {
    try {
      // Simplificăm query-ul pentru a evita necesitatea unui index compus
      // Vom sorta datele în client în loc de Firestore
      return _firestore
          .collection(_collectionName)
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
          .where('dateTime', isLessThan: Timestamp.fromDate(endOfWeek))
          .snapshots()
          .handleError((error) {
            debugPrint("Error in getMeetingsForWeek stream: $error");
            return Stream<QuerySnapshot>.empty();
          });
    } catch (e) {
      debugPrint("Error creating getMeetingsForWeek stream: $e");
      return Stream<QuerySnapshot>.empty();
    }
  }

  /// Obține întâlnirile viitoare pentru consultantul curent (versiune simplificată)
  Stream<QuerySnapshot> getUpcomingMeetings({int limit = 10}) {
    final user = currentUser;
    if (user == null) {
      debugPrint("No authenticated user for getUpcomingMeetings");
      return Stream<QuerySnapshot>.empty();
    }

    try {
      // Simplificăm și acest query pentru a evita probleme de index
      return _firestore
          .collection(_collectionName)
          .where('consultantId', isEqualTo: user.uid)
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.now())
          .limit(limit)
          .snapshots()
          .handleError((error) {
            debugPrint("Error in getUpcomingMeetings stream: $error");
            return Stream<QuerySnapshot>.empty();
          });
    } catch (e) {
      debugPrint("Error creating getUpcomingMeetings stream: $e");
      return Stream<QuerySnapshot>.empty();
    }
  }

  /// Obține o întâlnire specifică
  Future<MeetingData?> getMeeting(String meetingId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(meetingId).get();
      if (doc.exists) {
        return MeetingData.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint("Eroare getMeeting: $e");
      return null;
    }
  }

  /// Helper: verifică dacă un slot de timp este disponibil
  Future<bool> _isTimeSlotAvailable(DateTime dateTime, {String? excludeId}) async {
    try {
      // Verifică dacă există deja o întâlnire la această oră exactă
      final exactTime = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute,
      );

      QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('dateTime', isEqualTo: Timestamp.fromDate(exactTime))
          .get();

      // Dacă excludeId este specificat, nu îl considera conflictual
      if (excludeId != null) {
        return snapshot.docs.every((doc) => doc.id == excludeId);
      }

      return snapshot.docs.isEmpty;
    } catch (e) {
      debugPrint("Eroare _isTimeSlotAvailable: $e");
      return false;
    }
  }

  /// Helper: obține datele consultantului
  Future<Map<String, dynamic>?> _getConsultantData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('consultants').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint("Eroare _getConsultantData: $e");
      return null;
    }
  }
}
