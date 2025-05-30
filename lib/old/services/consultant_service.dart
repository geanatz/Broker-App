import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'firebase_thread_handler.dart';

/// Service pentru gestionarea datelor consultanților
class ConsultantService {
  // Singleton pattern
  static final ConsultantService _instance = ConsultantService._internal();
  factory ConsultantService() => _instance;
  ConsultantService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collectionName = 'consultants';
  final FirebaseThreadHandler _threadHandler = FirebaseThreadHandler.instance;

  // Obtine utilizatorul curent
  User? get currentUser => _auth.currentUser;

  /// Obține datele consultantului curent
  Future<Map<String, dynamic>?> getCurrentConsultantData() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final consultantDoc = await _threadHandler.executeOnPlatformThread(
        () => _firestore.collection(_collectionName).doc(user.uid).get()
      );
      
      if (consultantDoc.exists) {
        return consultantDoc.data();
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching consultant data: $e");
      return null;
    }
  }

  /// Obține datele consultantului specificat
  Future<Map<String, dynamic>?> getConsultantData(String consultantId) async {
    try {
      final consultantDoc = await _threadHandler.executeOnPlatformThread(
        () => _firestore.collection(_collectionName).doc(consultantId).get()
      );
      
      if (consultantDoc.exists) {
        return consultantDoc.data();
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching consultant data: $e");
      return null;
    }
  }
} 