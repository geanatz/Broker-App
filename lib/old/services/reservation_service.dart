import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'firebase_thread_handler.dart';

/// Tipul de rezervare
enum ReservationType {
  meeting,      // Intalnire cu clientul
  bureauDelete  // Stergere birou de credit
}

/// Service pentru gestionarea rezervarilor
class ReservationService {
  // Singleton pattern to ensure only one instance exists
  static final ReservationService _instance = ReservationService._internal();
  factory ReservationService() => _instance;
  ReservationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collectionName = 'reservations'; // Numele colectiei
  final FirebaseThreadHandler _threadHandler = FirebaseThreadHandler.instance;

  // Cache for stream controllers to avoid creating multiple controllers for the same stream
  final Map<String, StreamController<QuerySnapshot>> _streamControllers = {};

  // Obtine utilizatorul curent
  User? get currentUser => _auth.currentUser;

  /// Creeaza o rezervare noua
  Future<Map<String, dynamic>> createReservation({
    required DateTime dateTime,
    required String clientName,
    String phoneNumber = '',
    required ReservationType type,
  }) async {
    final user = currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Utilizator neautentificat'};
    }

    try {
      // Get consultant data on UI thread
      var consultantData = await _getConsultantData(user.uid);
      if (consultantData == null) {
        return {'success': false, 'message': 'Date consultant negasite'};
      }
      
      // Create reservation data
      final reservationData = {
        'consultantId': user.uid,
        'consultantName': consultantData['name'] ?? 'Necunoscut',
        'clientName': clientName,
        'phoneNumber': phoneNumber,
        'dateTime': Timestamp.fromDate(dateTime),
        'createdAt': FieldValue.serverTimestamp(),
        'type': type == ReservationType.meeting ? 'meeting' : 'bureauDelete',
      };
      
      // Add reservation using thread handler
      await _threadHandler.executeOnPlatformThread(() async {
        await _firestore.collection(_collectionName).add(reservationData);
      });
      
      return {'success': true, 'message': 'Rezervare creata cu succes'};
    } catch (e) {
      print("Eroare createReservation: $e");
      return {'success': false, 'message': 'Eroare la crearea rezervarii: $e'};
    }
  }

  /// Helper to get consultant data safely
  Future<Map<String, dynamic>?> _getConsultantData(String uid) async {
    try {
      DocumentSnapshot doc = await _threadHandler.executeOnPlatformThread(() {
        return _firestore.collection('consultants').doc(uid).get();
      });
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print("Error fetching consultant data: $e");
      return null;
    }
  }

  /// Obtine toate rezervarile pentru un interval de timp
  Stream<QuerySnapshot> getReservationsForWeek(DateTime startOfWeek, DateTime endOfWeek, {ReservationType? type}) {
    // Create a unique key for this query to reuse stream controllers
    String queryKey = 'week_${startOfWeek.millisecondsSinceEpoch}_${endOfWeek.millisecondsSinceEpoch}_${type?.toString() ?? "all"}';
    
    // Return existing stream if available
    if (_streamControllers.containsKey(queryKey) && !_streamControllers[queryKey]!.isClosed) {
      return _streamControllers[queryKey]!.stream;
    }
    
    // Configure the query - this part is synchronous and safe
    Query query = _firestore
        .collection(_collectionName)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
        .where('dateTime', isLessThan: Timestamp.fromDate(endOfWeek));

    if (type != null) {
      query = query.where('type', isEqualTo: type == ReservationType.meeting ? 'meeting' : 'bureauDelete');
    }
    
    // Use the thread handler to create a safe stream
    final stream = _threadHandler.createSafeQueryStream(() => query.snapshots());
    
    // Create a controller that will broadcast the events from the safe stream
    final controller = StreamController<QuerySnapshot>.broadcast(
      onCancel: () {
        _streamControllers.remove(queryKey);
      }
    );
    _streamControllers[queryKey] = controller;
    
    // Forward events from the safe stream to our controller
    stream.listen(
      (snapshot) {
        if (!controller.isClosed) {
          controller.add(snapshot);
        }
      },
      onError: (error) {
        print("Error in getReservationsForWeek: $error");
        if (!controller.isClosed) {
          controller.addError(error);
        }
      },
      onDone: () {
        if (!controller.isClosed) {
          controller.close();
        }
      },
    );
    
    return controller.stream;
  }

  /// Obtine rezervarile viitoare pentru consultantul curent
  Stream<QuerySnapshot> getUpcomingReservations() {
    final user = currentUser;
    if (user == null) return Stream<QuerySnapshot>.empty();
    
    // Create a unique key for this query
    String queryKey = 'upcoming_${user.uid}';
    
    // Return existing stream if available
    if (_streamControllers.containsKey(queryKey) && !_streamControllers[queryKey]!.isClosed) {
      return _streamControllers[queryKey]!.stream;
    }
    
    // Configure the query
    final query = _firestore
        .collection(_collectionName)
        .where('consultantId', isEqualTo: user.uid)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('dateTime')
        .limit(10);
        
    // Use the thread handler to create a safe stream
    final stream = _threadHandler.createSafeQueryStream(() => query.snapshots());
    
    // Create a controller that will broadcast the events
    final controller = StreamController<QuerySnapshot>.broadcast(
      onCancel: () {
        _streamControllers.remove(queryKey);
      }
    );
    _streamControllers[queryKey] = controller;
    
    // Forward events from the safe stream to our controller
    stream.listen(
      (snapshot) {
        if (!controller.isClosed) {
          controller.add(snapshot);
        }
      },
      onError: (error) {
        print("Error in getUpcomingReservations: $error");
        if (!controller.isClosed) {
          controller.addError(error);
        }
      },
      onDone: () {
        if (!controller.isClosed) {
          controller.close();
        }
      },
    );
    
    return controller.stream;
  }

  /// Actualizeaza o rezervare existenta
  Future<Map<String, dynamic>> updateReservation({
    required String id,
    required String clientName,
    String phoneNumber = '',
    required DateTime dateTime,
    required ReservationType type,
  }) async {
    final user = currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Utilizator neautentificat'};
    }

    try {
      // Check reservation existence and ownership
      DocumentSnapshot reservationDoc = await _threadHandler.executeOnPlatformThread(() {
        return _firestore.collection(_collectionName).doc(id).get();
      });
      
      if (!reservationDoc.exists) {
        return {'success': false, 'message': 'Rezervarea nu există'};
      }
      
      final reservationData = reservationDoc.data() as Map<String, dynamic>;
      final String? consultantId = reservationData['consultantId'] as String?;
      
      if (consultantId != user.uid) {
        return {'success': false, 'message': 'Nu aveți permisiunea de a modifica această rezervare'};
      }

      // Update reservation
      await _threadHandler.executeOnPlatformThread(() {
        return _firestore.collection(_collectionName).doc(id).update({
          'clientName': clientName,
          'phoneNumber': phoneNumber,
          'dateTime': Timestamp.fromDate(dateTime),
          'updatedAt': FieldValue.serverTimestamp(),
          'type': type == ReservationType.meeting ? 'meeting' : 'bureauDelete',
        });
      });
      
      return {'success': true, 'message': 'Rezervarea a fost actualizată cu succes'};
    } catch (e) {
      print("Eroare updateReservation: $e");
      return {'success': false, 'message': 'Eroare la actualizarea rezervării: $e'};
    }
  }

  /// Sterge o rezervare
  Future<Map<String, dynamic>> deleteReservation(String id) async {
    final user = currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Utilizator neautentificat'};
    }

    try {
      // Check reservation existence and ownership
      DocumentSnapshot reservationDoc = await _threadHandler.executeOnPlatformThread(() {
        return _firestore.collection(_collectionName).doc(id).get();
      });
      
      if (!reservationDoc.exists) {
        return {'success': false, 'message': 'Rezervarea nu există'};
      }
      
      final reservationData = reservationDoc.data() as Map<String, dynamic>;
      final String? consultantId = reservationData['consultantId'] as String?;
      
      if (consultantId != user.uid) {
        return {'success': false, 'message': 'Nu aveți permisiunea de a șterge această rezervare'};
      }

      // Delete reservation
      await _threadHandler.executeOnPlatformThread(() {
        return _firestore.collection(_collectionName).doc(id).delete();
      });
      
      return {'success': true, 'message': 'Rezervarea a fost ștearsă cu succes'};
    } catch (e) {
      print("Eroare deleteReservation: $e");
      return {'success': false, 'message': 'Eroare la ștergerea rezervării: $e'};
    }
  }

  /// Verifica daca un slot este disponibil
  Future<bool> isTimeSlotAvailable(DateTime dateTime, {String? excludeDocId}) async {
    try {
      // Check for reservations at this time
      QuerySnapshot querySnapshot = await _threadHandler.executeOnPlatformThread(() {
        return _firestore
          .collection(_collectionName)
          .where('dateTime', isEqualTo: Timestamp.fromDate(dateTime))
          .get();
      });

      if (querySnapshot.docs.isEmpty) {
        return true; // No reservations at this time
      }

      // If there's only one document and it's the one we're excluding, slot is available
      if (querySnapshot.docs.length == 1 && querySnapshot.docs.first.id == excludeDocId) {
        return true;
      }

      return false; // Slot occupied
    } catch (e) {
      print('Eroare la verificarea disponibilitatii slotului: $e');
      return false; // Consider slot occupied in case of error
    }
  }

  // Cleanup when service is no longer needed
  void dispose() {
    // Close all stream controllers
    for (var controller in _streamControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _streamControllers.clear();
  }
} 