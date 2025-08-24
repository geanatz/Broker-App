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

  /// Seteaza culoarea aleasa de consultantul curent (1-10)
  Future<bool> setCurrentConsultantColor(int colorIndex) async {
    final user = currentUser;
    if (user == null || colorIndex < 1 || colorIndex > 10) return false;

    try {
      await _threadHandler.executeOnPlatformThread(
        () => _firestore.collection(_collectionName).doc(user.uid).update({
          'colorIndex': colorIndex,
          'updatedAt': FieldValue.serverTimestamp(),
        })
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtine culoarea aleasa de consultantul curent (1-10, null daca nu a ales)
  Future<int?> getCurrentConsultantColor() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final consultantDoc = await _threadHandler.executeOnPlatformThread(
        () => _firestore.collection(_collectionName).doc(user.uid).get()
      );

      if (consultantDoc.exists) {
        final data = consultantDoc.data();
        return data?['colorIndex'] as int?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtine culoarea aleasa de un consultant specific (1-10, null daca nu a ales)
  Future<int?> getConsultantColor(String consultantId) async {
    if (consultantId.isEmpty) return null;

    try {
      final consultantDoc = await _threadHandler.executeOnPlatformThread(
        () => _firestore.collection(_collectionName).doc(consultantId).get()
      );

      if (consultantDoc.exists) {
        final data = consultantDoc.data();
        return data?['colorIndex'] as int?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtine culoarea aleasa pentru consultantii din echipa curenta
  Future<Map<String, int?>> getTeamConsultantColors() async {
    final currentConsultant = await getCurrentConsultantData();
    if (currentConsultant == null) return {};

    final currentTeam = currentConsultant['team'] as String?;
    if (currentTeam == null || currentTeam.isEmpty) return {};

    try {
      final consultantsSnapshot = await _threadHandler.executeOnPlatformThread(
        () => _firestore
            .collection(_collectionName)
            .where('team', isEqualTo: currentTeam)
            .get()
      );

      final colors = <String, int?>{};
      for (final doc in consultantsSnapshot.docs) {
        final data = doc.data();
        final consultantId = doc.id;
        final colorIndex = data['colorIndex'] as int?;
        colors[consultantId] = colorIndex;
      }

      return colors;
    } catch (e) {
      return {};
    }
  }

  /// Obtine culoarea aleasa pentru consultantii din echipa curenta dupa nume
  Future<Map<String, int?>> getTeamConsultantColorsByName() async {
    final currentConsultant = await getCurrentConsultantData();
    if (currentConsultant == null) return {};

    final currentTeam = currentConsultant['team'] as String?;
    if (currentTeam == null || currentTeam.isEmpty) return {};

    try {
      final consultantsSnapshot = await _threadHandler.executeOnPlatformThread(
        () => _firestore
            .collection(_collectionName)
            .where('team', isEqualTo: currentTeam)
            .get()
      );

      final colors = <String, int?>{};
      for (final doc in consultantsSnapshot.docs) {
        final data = doc.data();
        final consultantName = data['name'] as String?;
        final colorIndex = data['colorIndex'] as int?;
        if (consultantName != null && consultantName.isNotEmpty) {
          colors[consultantName] = colorIndex;
        }
      }

      return colors;
    } catch (e) {
      return {};
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

