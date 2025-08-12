import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'firebase_service.dart';

/// Model pentru un consultant
class Consultant {
  final String id;
  final String name;
  final String team;

  Consultant({required this.id, required this.name, required this.team});
}

/// Service pentru gestionarea datelor consultantilor
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

  /// Obtine datele consultantului curent
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
      return null;
    }
  }

  /// Obtine datele consultantului specificat
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
      return null;
    }
  }

  /// Obtine toti consultantii din aceeasi echipa cu consultantul curent
  Future<List<Map<String, dynamic>>> getTeamConsultants() async {
    final currentConsultant = await getCurrentConsultantData();
    if (currentConsultant == null) return [];

    final currentTeam = currentConsultant['team'] as String?;
    if (currentTeam == null || currentTeam.isEmpty) return [];

    return await getConsultantsByTeam(currentTeam);
  }

  /// Obtine toti consultantii dintr-o echipa specificata
  Future<List<Map<String, dynamic>>> getConsultantsByTeam(String teamName) async {
    try {
      final consultantsSnapshot = await _threadHandler.executeOnPlatformThread(
        () => _firestore
            .collection(_collectionName)
            .where('team', isEqualTo: teamName)
            .get()
      );

      return consultantsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID for reference
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtine toate echipele disponibile
  Future<List<String>> getAllTeams() async {
    try {
      final consultantsSnapshot = await _threadHandler.executeOnPlatformThread(
        () => _firestore.collection(_collectionName).get()
      );

      final teams = <String>{};
      for (final doc in consultantsSnapshot.docs) {
        final team = doc.data()['team'] as String?;
        if (team != null && team.isNotEmpty) {
          teams.add(team);
        }
      }

      return teams.toList()..sort();
    } catch (e) {
      return [];
    }
  }

  /// Obtine toti consultantii
  Future<List<Consultant>> getAllConsultants() async {
    try {
      final consultantsSnapshot = await _threadHandler.executeOnPlatformThread(
        () => _firestore.collection(_collectionName).get()
      );

      return consultantsSnapshot.docs.map((doc) {
        final data = doc.data();
        return Consultant(
          id: doc.id,
          name: data['name'] ?? 'Necunoscut',
          team: data['team'] ?? '',
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
} 

