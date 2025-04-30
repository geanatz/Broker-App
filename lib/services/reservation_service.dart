import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Tipul de rezervare
enum ReservationType {
  /// Întâlnire cu clientul
  meeting,
  
  /// Ștergere birou de credit
  bureauDelete
}

/// Service pentru gestionarea rezervărilor
class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Numele colecției
  final String _reservationsCollection = 'reservations';
  
  // Obține utilizatorul curent
  User? get currentUser => _auth.currentUser;
  
  /// Creează o rezervare nouă
  Future<Map<String, dynamic>> createReservation({
    required DateTime dateTime,
    required String clientName,
    required ReservationType type,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Utilizator neautentificat',
        };
      }
      
      // Obține datele consultantului
      final consultantDoc = await _firestore
          .collection('consultants')
          .doc(user.uid)
          .get();
          
      if (!consultantDoc.exists) {
        return {
          'success': false,
          'message': 'Date consultant negăsite',
        };
      }
      
      final consultantData = consultantDoc.data() as Map<String, dynamic>;
      final consultantName = consultantData['name'] as String? ?? 'N/A';
      
      // Creează documentul rezervării
      final docRef = await _firestore.collection(_reservationsCollection).add({
        'consultantId': user.uid,
        'consultantName': consultantName,
        'clientName': clientName,
        'dateTime': Timestamp.fromDate(dateTime),
        'type': type.toString().split('.').last, // Store enum as string 'meeting' or 'bureauDelete'
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return {
        'success': true,
        'message': 'Rezervare creată cu succes',
        'id': docRef.id,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Eroare la crearea rezervării: $e',
      };
    }
  }
  
  /// Obține toate rezervările pentru un interval de timp
  Stream<QuerySnapshot> getReservationsForDateRange(DateTime start, DateTime end, {ReservationType? type}) {
    Query query = _firestore
        .collection(_reservationsCollection)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('dateTime', isLessThan: Timestamp.fromDate(end));
        
    // Adaugă filtrare după tip dacă este specificat
    if (type != null) {
      final typeStr = type.toString().split('.').last;
      query = query.where('type', isEqualTo: typeStr);
    }
    
    return query.snapshots();
  }
  
  /// Obține rezervările viitoare pentru consultantul curent
  Stream<QuerySnapshot> getUpcomingReservationsForCurrentConsultant() {
    final user = currentUser;
    if (user == null) {
      // Returnează un stream gol dacă utilizatorul nu este autentificat
      return Stream.empty();
    }
    
    final now = DateTime.now();
    
    return _firestore
        .collection(_reservationsCollection)
        .where('consultantId', isEqualTo: user.uid)
        .where('dateTime', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('dateTime')
        .snapshots();
  }
  
  /// Actualizează o rezervare existentă
  Future<Map<String, dynamic>> updateReservation({
    required String id,
    String? clientName,
    DateTime? dateTime,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Utilizator neautentificat',
        };
      }
      
      // Verifică dacă rezervarea există și aparține consultantului curent
      final reservationDoc = await _firestore
          .collection(_reservationsCollection)
          .doc(id)
          .get();
          
      if (!reservationDoc.exists) {
        return {
          'success': false,
          'message': 'Rezervarea nu există',
        };
      }
      
      final reservationData = reservationDoc.data() as Map<String, dynamic>;
      if (reservationData['consultantId'] != user.uid) {
        return {
          'success': false,
          'message': 'Nu aveți permisiunea de a modifica această rezervare',
        };
      }
      
      // Construiește datele de actualizat
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (clientName != null && clientName.isNotEmpty) {
        updateData['clientName'] = clientName;
      }
      
      if (dateTime != null) {
        updateData['dateTime'] = Timestamp.fromDate(dateTime);
      }
      
      // Actualizează documentul
      await _firestore
          .collection(_reservationsCollection)
          .doc(id)
          .update(updateData);
          
      return {
        'success': true,
        'message': 'Rezervare actualizată cu succes',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Eroare la actualizarea rezervării: $e',
      };
    }
  }
  
  /// Șterge o rezervare
  Future<Map<String, dynamic>> deleteReservation(String id) async {
    try {
      final user = currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Utilizator neautentificat',
        };
      }
      
      // Verifică dacă rezervarea există și aparține consultantului curent
      final reservationDoc = await _firestore
          .collection(_reservationsCollection)
          .doc(id)
          .get();
          
      if (!reservationDoc.exists) {
        return {
          'success': false,
          'message': 'Rezervarea nu există',
        };
      }
      
      final reservationData = reservationDoc.data() as Map<String, dynamic>;
      if (reservationData['consultantId'] != user.uid) {
        return {
          'success': false,
          'message': 'Nu aveți permisiunea de a șterge această rezervare',
        };
      }
      
      // Șterge documentul
      await _firestore.collection(_reservationsCollection).doc(id).delete();
      
      return {
        'success': true,
        'message': 'Rezervare ștearsă cu succes',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Eroare la ștergerea rezervării: $e',
      };
    }
  }
  
  /// Verifică dacă un slot este disponibil
  Future<bool> isTimeSlotAvailable(DateTime dateTime, {String? excludeDocId}) async {
    try {
      final snapshot = await _firestore
          .collection(_reservationsCollection)
          .where('dateTime', isEqualTo: Timestamp.fromDate(dateTime))
          .get();
          
      if (snapshot.docs.isEmpty) {
        return true;
      }
      
      // Dacă există doar un document și acesta este cel exclus, slotul este disponibil
      if (snapshot.docs.length == 1 && excludeDocId != null && snapshot.docs.first.id == excludeDocId) {
        return true;
      }
      
      return false;
    } catch (e) {
      print('Eroare la verificarea disponibilității slotului: $e');
      return false;
    }
  }
} 