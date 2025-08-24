import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'firebase_service.dart';

/// Model pentru un consultant
class Consultant {
  final String id;
  final String name;
  final String team;

  Consultant({required this.id, required this.name, required this.team});
}

/// Service pentru gestionarea datelor consultantilor
class ConsultantService extends ChangeNotifier {
  // Singleton pattern
  static final ConsultantService _instance = ConsultantService._internal();
  factory ConsultantService() => _instance;
  ConsultantService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collectionName = 'consultants';
  final FirebaseThreadHandler _threadHandler = FirebaseThreadHandler.instance;

  // Stream pentru notificarea schimbarii culorilor
  final StreamController<Map<String, int?>> _colorChangeController = StreamController<Map<String, int?>>.broadcast();
  Stream<Map<String, int?>> get colorChangeStream => _colorChangeController.stream;

  // Cache pentru culorile consultantilor
  Map<String, int?> _consultantColorsCache = {};
  DateTime? _lastCacheUpdate;

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

  /// Actualizeaza culoarea consultantului curent
  Future<bool> updateCurrentConsultantColor(int colorIndex) async {
    final user = currentUser;
    if (user == null) return false;

    if (colorIndex < 1 || colorIndex > 10) return false;

    try {
      await _threadHandler.executeOnPlatformThread(
        () => _firestore.collection(_collectionName).doc(user.uid).update({
          'colorIndex': colorIndex,
          'updatedAt': FieldValue.serverTimestamp(),
        })
      );

      // Actualizeaza cache-ul local
      final currentData = await getCurrentConsultantData();
      if (currentData != null) {
        final consultantName = currentData['name'] as String?; // FIX: Foloseste numele consultantului
        if (consultantName != null && consultantName.isNotEmpty) {
          _consultantColorsCache[consultantName] = colorIndex;
          _lastCacheUpdate = DateTime.now();
          
          // Notifica schimbarea culorii
          _colorChangeController.add(_consultantColorsCache);
          notifyListeners();
          
          debugPrint('🎨 CONSULTANT_COLORS: Color updated for $consultantName to $colorIndex, cache updated');
        }
      }

      return true;
    } catch (e) {
      debugPrint('❌ CONSULTANT_COLORS: Error updating color: $e');
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
    final stopwatch = Stopwatch()..start();
    
    try {
      final currentConsultant = await getCurrentConsultantData();
      if (currentConsultant == null) {
        stopwatch.stop();
        debugPrint('🎨 CONSULTANT_COLORS: getTeamConsultantColors - no current consultant data, timeMs=${stopwatch.elapsedMilliseconds}');
        return {};
      }

      final currentTeam = currentConsultant['team'] as String?;
      if (currentTeam == null || currentTeam.isEmpty) {
        stopwatch.stop();
        debugPrint('🎨 CONSULTANT_COLORS: getTeamConsultantColors - no team data, timeMs=${stopwatch.elapsedMilliseconds}');
        return {};
      }

      debugPrint('🎨 CONSULTANT_COLORS: getTeamConsultantColors - querying team: $currentTeam');
      
      final consultantsSnapshot = await _threadHandler.executeOnPlatformThread(
        () => _firestore
            .collection(_collectionName)
            .where('team', isEqualTo: currentTeam)
            .get()
      );

      final colors = <String, int?>{};
      for (final doc in consultantsSnapshot.docs) {
        final data = doc.data();
        final consultantName = data['name'] as String?; // FIX: Foloseste numele in loc de ID
        final colorIndex = data['colorIndex'] as int?;
        if (consultantName != null && consultantName.isNotEmpty) {
          colors[consultantName] = colorIndex; // FIX: Key-ul este numele consultantului
        }
      }

      stopwatch.stop();
      debugPrint('🎨 CONSULTANT_COLORS: getTeamConsultantColors - completed, timeMs=${stopwatch.elapsedMilliseconds}, consultants=${colors.length}, team=$currentTeam');
      
      return colors;
    } catch (e) {
      stopwatch.stop();
      debugPrint('❌ CONSULTANT_COLORS: getTeamConsultantColors - error: $e, timeMs=${stopwatch.elapsedMilliseconds}');
      return {};
    }
  }

  /// Obtine culoarea aleasa pentru consultantii din echipa curenta dupa nume
  Future<Map<String, int?>> getTeamConsultantColorsByName() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Verifica cache-ul local inainte de a face query
      if (_consultantColorsCache.isNotEmpty && _lastCacheUpdate != null) {
        final cacheAge = DateTime.now().difference(_lastCacheUpdate!);
        if (cacheAge.inMinutes < 5) { // Cache valid pentru 5 minute
          stopwatch.stop();
          debugPrint('🎨 CONSULTANT_COLORS: getTeamConsultantColorsByName - using cache, timeMs=${stopwatch.elapsedMilliseconds}, cacheAge=${cacheAge.inSeconds}s, colors=$_consultantColorsCache');
          return Map.from(_consultantColorsCache);
        }
      }

      final currentConsultant = await getCurrentConsultantData();
      if (currentConsultant == null) {
        stopwatch.stop();
        debugPrint('🎨 CONSULTANT_COLORS: getTeamConsultantColorsByName - no current consultant data, timeMs=${stopwatch.elapsedMilliseconds}');
        return {};
      }

      final currentTeam = currentConsultant['team'] as String?;
      if (currentTeam == null || currentTeam.isEmpty) {
        stopwatch.stop();
        debugPrint('🎨 CONSULTANT_COLORS: getTeamConsultantColorsByName - no team data, timeMs=${stopwatch.elapsedMilliseconds}');
        return {};
      }

      debugPrint('🎨 CONSULTANT_COLORS: getTeamConsultantColorsByName - querying team: $currentTeam');
      
      final consultantsSnapshot = await _threadHandler.executeOnPlatformThread(
        () => _firestore
            .collection(_collectionName)
            .where('team', isEqualTo: currentTeam)
            .get()
      );

      final colors = <String, int?>{};
      for (final doc in consultantsSnapshot.docs) {
        final data = doc.data();
        final consultantName = data['name'] as String?; // FIX: Foloseste numele in loc de ID
        final colorIndex = data['colorIndex'] as int?;
        if (consultantName != null && consultantName.isNotEmpty) {
          colors[consultantName] = colorIndex; // FIX: Key-ul este numele consultantului
        }
      }

      // Actualizeaza cache-ul local
      _consultantColorsCache = Map.from(colors);
      _lastCacheUpdate = DateTime.now();

      stopwatch.stop();
      debugPrint('🎨 CONSULTANT_COLORS: getTeamConsultantColorsByName - completed, timeMs=${stopwatch.elapsedMilliseconds}, consultants=${colors.length}, team=$currentTeam, colors=$colors, cacheUpdated=true');
      
      return colors;
    } catch (e) {
      stopwatch.stop();
      debugPrint('❌ CONSULTANT_COLORS: getTeamConsultantColorsByName - error: $e, timeMs=${stopwatch.elapsedMilliseconds}');
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

  /// Invalideaza cache-ul de culori (folosit cand se schimba consultantul)
  void invalidateColorCache() {
    _consultantColorsCache.clear();
    _lastCacheUpdate = null;
    
    // FIX: Reseteaza si stream-ul pentru a evita culorile vechi
    _resetColorStream();
    
    debugPrint('🎨 CONSULTANT_COLORS: Color cache invalidated and stream reset');
  }

  /// FIX: Reseteaza stream-ul de culori pentru a evita culorile vechi
  void _resetColorStream() {
    try {
      // Emite un stream gol pentru a reseta UI-ul
      _colorChangeController.add({});
      debugPrint('🎨 CONSULTANT_COLORS: Color stream reset - emitted empty map');
    } catch (e) {
      debugPrint('❌ CONSULTANT_COLORS: Error resetting color stream: $e');
    }
  }

  /// FIX: Reseteaza complet serviciul pentru un consultant nou
  void resetForNewConsultant() {
    invalidateColorCache();
    debugPrint('🎨 CONSULTANT_COLORS: Service reset for new consultant');
  }

  /// Obtine culorile din cache (fara a face query)
  Map<String, int?> getCachedColors() {
    return Map.from(_consultantColorsCache);
  }

  @override
  void dispose() {
    _colorChangeController.close();
    super.dispose();
  }
} 

