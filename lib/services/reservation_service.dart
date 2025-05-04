import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Tipul de rezervare
enum ReservationType {
  meeting,      // Intalnire cu clientul
  bureauDelete  // Stergere birou de credit
}

/// Service pentru gestionarea rezervarilor
class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collectionName = 'reservations'; // Numele colectiei

  // Obtine utilizatorul curent
  User? get currentUser => _auth.currentUser;

  /// Creeaza o rezervare noua
  Future<Map<String, dynamic>> createReservation({
    required DateTime dateTime,
    required String clientName,
    required ReservationType type,
  }) async {
    final user = currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Utilizator neautentificat'};
    }

    try {
      // Obtine datele consultantului
      final consultantDoc = await _firestore.collection('consultants').doc(user.uid).get();
      if (!consultantDoc.exists) {
        return {'success': false, 'message': 'Date consultant negasite'};
      }
      final consultantData = consultantDoc.data()!;
      final consultantName = consultantData['name'] ?? 'Necunoscut';

      // Creeaza documentul rezervarii
      await _firestore.collection(_collectionName).add({
        'consultantId': user.uid,
        'consultantName': consultantName,
        'clientName': clientName,
        'dateTime': Timestamp.fromDate(dateTime),
        'createdAt': FieldValue.serverTimestamp(),
        'type': type == ReservationType.meeting ? 'meeting' : 'bureauDelete',
      });
      return {'success': true, 'message': 'Rezervare creata cu succes'};
    } catch (e) {
      print("Eroare createReservation: $e");
      return {'success': false, 'message': 'Eroare la crearea rezervarii: $e'};
    }
  }

  /// Obtine toate rezervarile pentru un interval de timp
  Stream<QuerySnapshot> getReservationsForWeek(DateTime startOfWeek, DateTime endOfWeek, {ReservationType? type}) {
    Query query = _firestore
        .collection(_collectionName)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .where('dateTime', isLessThan: Timestamp.fromDate(endOfWeek));

    // Adauga filtrare dupa tip daca este specificat
    if (type != null) {
      query = query.where('type', isEqualTo: type == ReservationType.meeting ? 'meeting' : 'bureauDelete');
    }

    return query.snapshots();
  }

  /// Obtine rezervarile viitoare pentru consultantul curent
  Stream<QuerySnapshot> getUpcomingReservations() {
    final user = currentUser;
    // Returneaza un stream gol daca utilizatorul nu este autentificat
    if (user == null) return const Stream.empty();

    return _firestore
        .collection(_collectionName)
        .where('consultantId', isEqualTo: user.uid)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('dateTime')
        .limit(10) // Limit to 10 upcoming reservations
        .snapshots();
  }

  /// Actualizeaza o rezervare existenta
  Future<Map<String, dynamic>> updateReservation({
    required String id,
    required String clientName,
    required DateTime dateTime,
  }) async {
    final user = currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Utilizator neautentificat'};
    }

    try {
      final docRef = _firestore.collection(_collectionName).doc(id);
      final docSnapshot = await docRef.get();

      // Verifica daca rezervarea exista si apartine consultantului curent
      if (!docSnapshot.exists) {
        return {'success': false, 'message': 'Rezervarea nu exista'};
      }
      final data = docSnapshot.data()!;
      if (data['consultantId'] != user.uid) {
        return {'success': false, 'message': 'Nu aveti permisiunea de a modifica aceasta rezervare'};
      }

      // Construieste datele de actualizat
      final updateData = {
        'clientName': clientName,
        'dateTime': Timestamp.fromDate(dateTime),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Actualizeaza documentul
      await docRef.update(updateData);
      return {'success': true, 'message': 'Rezervare actualizata cu succes'};
    } catch (e) {
      print("Eroare updateReservation: $e");
      return {'success': false, 'message': 'Eroare la actualizarea rezervarii: $e'};
    }
  }

  /// Sterge o rezervare
  Future<Map<String, dynamic>> deleteReservation(String id) async {
    final user = currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Utilizator neautentificat'};
    }

    try {
      final docRef = _firestore.collection(_collectionName).doc(id);
      final docSnapshot = await docRef.get();

      // Verifica daca rezervarea exista si apartine consultantului curent
      if (!docSnapshot.exists) {
        return {'success': false, 'message': 'Rezervarea nu exista'};
      }
      final data = docSnapshot.data()!;
      if (data['consultantId'] != user.uid) {
        return {'success': false, 'message': 'Nu aveti permisiunea de a sterge aceasta rezervare'};
      }

      // Sterge documentul
      await docRef.delete();
      return {'success': true, 'message': 'Rezervare stearsa cu succes'};
    } catch (e) {
      print("Eroare deleteReservation: $e");
      return {'success': false, 'message': 'Eroare la stergerea rezervarii: $e'};
    }
  }

  /// Verifica daca un slot este disponibil
  Future<bool> isTimeSlotAvailable(DateTime dateTime, {String? excludeDocId}) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('dateTime', isEqualTo: Timestamp.fromDate(dateTime));

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        return true; // Nicio rezervare la aceasta ora
      }

      // Daca exista doar un document si acesta este cel exclus, slotul este disponibil
      if (querySnapshot.docs.length == 1 && querySnapshot.docs.first.id == excludeDocId) {
        return true;
      }

      return false; // Slot ocupat
    } catch (e) {
      print('Eroare la verificarea disponibilitatii slotului: $e');
      return false; // Considera slotul ocupat in caz de eroare
    }
  }
} 