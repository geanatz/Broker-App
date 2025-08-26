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

/// Model pentru trade request
class TradeRequest {
  final String id;
  final String requesterId;
  final String requesterName;
  final String targetId;
  final String targetName;
  final int requestedColorIndex;
  final DateTime timestamp;

  TradeRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.targetId,
    required this.targetName,
    required this.requestedColorIndex,
    required this.timestamp,
  });
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

  // Stream pentru trade requests
  final StreamController<List<TradeRequest>> _tradeRequestsController = StreamController<List<TradeRequest>>.broadcast();
  Stream<List<TradeRequest>> get tradeRequestsStream => _tradeRequestsController.stream;

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

  /// Actualizeaza culoarea unui consultant specific
  Future<bool> updateConsultantColor(String consultantId, int colorIndex) async {
    if (consultantId.isEmpty || colorIndex < 1 || colorIndex > 10) return false;

    try {
      await _threadHandler.executeOnPlatformThread(
        () => _firestore.collection(_collectionName).doc(consultantId).update({
          'colorIndex': colorIndex,
          'updatedAt': FieldValue.serverTimestamp(),
        })
      );

      // Obtine numele consultantului pentru a actualiza cache-ul
      final consultantData = await getConsultantData(consultantId);
      if (consultantData != null) {
        final consultantName = consultantData['name'] as String?;
        if (consultantName != null && consultantName.isNotEmpty) {
          // Actualizeaza cache-ul local
          _consultantColorsCache[consultantName] = colorIndex;
          _lastCacheUpdate = DateTime.now();

          // Notifica schimbarea culorii
          _colorChangeController.add(_consultantColorsCache);
          notifyListeners();

          debugPrint('🎨 CONSULTANT_COLORS: Color updated for consultant $consultantId ($consultantName) to $colorIndex, cache updated');
        } else {
          debugPrint('🎨 CONSULTANT_COLORS: Color updated for consultant $consultantId to $colorIndex (no name found)');
        }
      }

      return true;
    } catch (e) {
      debugPrint('❌ CONSULTANT_COLORS: Error updating consultant color: $e');
      return false;
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

  /// Obtine ID-ul consultantului dupa nume (din echipa curenta)
  Future<String?> getConsultantIdByName(String consultantName) async {
    try {
      final currentConsultant = await getCurrentConsultantData();
      if (currentConsultant == null) return null;

      final currentTeam = currentConsultant['team'] as String?;
      if (currentTeam == null || currentTeam.isEmpty) return null;

      final consultantsSnapshot = await _threadHandler.executeOnPlatformThread(
        () => _firestore
            .collection(_collectionName)
            .where('team', isEqualTo: currentTeam)
            .where('name', isEqualTo: consultantName)
            .get()
      );

      if (consultantsSnapshot.docs.isNotEmpty) {
        return consultantsSnapshot.docs.first.id;
      }

      return null;
    } catch (e) {
      debugPrint('❌ CONSULTANT_COLORS: Error getting consultant ID by name: $e');
      return null;
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

  /// Verifica daca o culoare este disponibila pentru selectie
  /// Returneaza numele consultantului care foloseste deja culoarea, sau null daca este disponibila
  Future<String?> checkColorAvailability(int colorIndex) async {
    if (colorIndex < 1 || colorIndex > 10) return 'Culoare invalida';

    try {
      final teamColors = await getTeamConsultantColorsByName();

      // Cauta consultantul care foloseste aceasta culoare
      for (final entry in teamColors.entries) {
        if (entry.value == colorIndex) {
          return entry.key; // Returneaza numele consultantului
        }
      }

      return null; // Culoarea este disponibila
    } catch (e) {
      debugPrint('❌ CONSULTANT_COLORS: checkColorAvailability - error: $e');
      return null; // In caz de eroare, presupunem ca este disponibila
    }
  }

  /// Trimite un trade request catre consultantul care detine culoarea
  Future<bool> sendTradeRequest(int colorIndex, String targetConsultantId, String targetConsultantName) async {
    final user = currentUser;
    if (user == null) return false;

    if (colorIndex < 1 || colorIndex > 10) return false;

    try {
      // Obtine datele consultantului curent
      final currentConsultant = await getCurrentConsultantData();
      if (currentConsultant == null) return false;

      final requesterName = currentConsultant['name'] as String? ?? 'Necunoscut';

      // Creeaza trade request
      final tradeRequest = {
        'id': '${user.uid}_${targetConsultantId}_${colorIndex}_${DateTime.now().millisecondsSinceEpoch}',
        'requesterId': user.uid,
        'requesterName': requesterName,
        'targetId': targetConsultantId,
        'targetName': targetConsultantName,
        'requestedColorIndex': colorIndex,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, accepted, rejected
      };

      // Salveaza trade request in Firestore
      await _threadHandler.executeOnPlatformThread(
        () => _firestore.collection('tradeRequests').doc(tradeRequest['id'] as String).set(tradeRequest)
      );

      debugPrint('🎨 TRADE: Trade request sent from $requesterName to $targetConsultantName for color $colorIndex');
      return true;
    } catch (e) {
      debugPrint('❌ TRADE: Error sending trade request: $e');
      return false;
    }
  }

  /// Accepta un trade request
  Future<bool> acceptTradeRequest(String tradeRequestId) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      // Obtine trade request-ul
      final tradeDoc = await _threadHandler.executeOnPlatformThread(
        () => _firestore.collection('tradeRequests').doc(tradeRequestId).get()
      );

      if (!tradeDoc.exists) return false;

      final tradeData = tradeDoc.data();
      if (tradeData == null) return false;

      // Verifica daca user-ul curent este target-ul
      if (tradeData['targetId'] != user.uid) return false;

      final requesterId = tradeData['requesterId'] as String;
      final requestedColorIndex = tradeData['requestedColorIndex'] as int;

      // Obtine culoarea consultantului care a facut cererea (cel care da culoarea)
      final requesterColor = await getConsultantColor(requesterId);
      if (requesterColor == null) return false;

      debugPrint('🎨 TRADE: Processing trade - requester $requesterId has color $requesterColor, accepting consultant gets color $requesterColor, requester gets requested color $requestedColorIndex');

      // Schimba culorile intre consultanti
      await Future.wait([
        updateCurrentConsultantColor(requesterColor),        // Consultantul care accepta primeste culoarea celui care a cerut
        updateConsultantColor(requesterId, requestedColorIndex), // Consultantul care a cerut primeste culoarea ceruta
      ]);

      debugPrint('🎨 TRADE: Colors swapped successfully - requester gets $requestedColorIndex, acceptor gets $requesterColor');

      // Actualizeaza status-ul trade request-ului
      await _threadHandler.executeOnPlatformThread(
        () => _firestore.collection('tradeRequests').doc(tradeRequestId).update({
          'status': 'accepted',
          'completedAt': FieldValue.serverTimestamp(),
        })
      );

      debugPrint('🎨 TRADE: Trade request $tradeRequestId accepted - colors swapped');
      return true;
    } catch (e) {
      debugPrint('❌ TRADE: Error accepting trade request: $e');
      return false;
    }
  }

  /// Refuza un trade request
  Future<bool> rejectTradeRequest(String tradeRequestId) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      // Actualizeaza status-ul trade request-ului
      await _threadHandler.executeOnPlatformThread(
        () => _firestore.collection('tradeRequests').doc(tradeRequestId).update({
          'status': 'rejected',
          'completedAt': FieldValue.serverTimestamp(),
        })
      );

      debugPrint('🎨 TRADE: Trade request $tradeRequestId rejected');
      return true;
    } catch (e) {
      debugPrint('❌ TRADE: Error rejecting trade request: $e');
      return false;
    }
  }

  /// Obtine trade requests primite de consultantul curent
  Future<List<TradeRequest>> getReceivedTradeRequests() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      // Simplificam complet query-ul pentru a evita orice necesitate de indexuri
      final tradeRequestsSnapshot = await _threadHandler.executeOnPlatformThread(
        () => _firestore
            .collection('tradeRequests')
            .where('targetId', isEqualTo: user.uid)
            .get()
      );

      // Filtram manual status-ul 'pending' și sortam după timestamp
      final pendingRequests = tradeRequestsSnapshot.docs.where((doc) {
        final data = doc.data();
        return data['status'] == 'pending';
      }).toList();

      // Sortam manual după timestamp (descending)
      pendingRequests.sort((a, b) {
        final timestampA = (a.data()['timestamp'] as Timestamp?)?.toDate() ?? DateTime(2000);
        final timestampB = (b.data()['timestamp'] as Timestamp?)?.toDate() ?? DateTime(2000);
        return timestampB.compareTo(timestampA); // descending
      });

      return pendingRequests.map((doc) {
        final data = doc.data();
        return TradeRequest(
          id: doc.id,
          requesterId: data['requesterId'] as String,
          requesterName: data['requesterName'] as String,
          targetId: data['targetId'] as String,
          targetName: data['targetName'] as String,
          requestedColorIndex: data['requestedColorIndex'] as int,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ TRADE: Error getting received trade requests: $e');
      return [];
    }
  }

  /// Anuleaza un trade request trimis de consultantul curent
  Future<bool> cancelTradeRequest(String tradeRequestId) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      // Verifica daca trade request-ul apartine consultantului curent
      final tradeDoc = await _threadHandler.executeOnPlatformThread(
        () => _firestore.collection('tradeRequests').doc(tradeRequestId).get()
      );

      if (!tradeDoc.exists) return false;

      final tradeData = tradeDoc.data();
      if (tradeData == null) return false;

      // Verifica daca user-ul curent este requester-ul
      if (tradeData['requesterId'] != user.uid) return false;

      // Verifica daca status-ul este pending
      if (tradeData['status'] != 'pending') return false;

      // Actualizeaza status-ul trade request-ului la cancelled
      await _threadHandler.executeOnPlatformThread(
        () => _firestore.collection('tradeRequests').doc(tradeRequestId).update({
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
        })
      );

      debugPrint('🎨 TRADE: Trade request $tradeRequestId cancelled by requester');
      return true;
    } catch (e) {
      debugPrint('❌ TRADE: Error cancelling trade request: $e');
      return false;
    }
  }

  /// Obtine trade requests trimise de consultantul curent (pentru anulare)
  Future<List<TradeRequest>> getSentTradeRequests() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      // Simplificam complet query-ul pentru a evita orice necesitate de indexuri
      final tradeRequestsSnapshot = await _threadHandler.executeOnPlatformThread(
        () => _firestore
            .collection('tradeRequests')
            .where('requesterId', isEqualTo: user.uid)
            .get()
      );

      // Filtram manual status-ul 'pending' și sortam după timestamp
      final pendingRequests = tradeRequestsSnapshot.docs.where((doc) {
        final data = doc.data();
        return data['status'] == 'pending';
      }).toList();

      // Sortam manual după timestamp (descending)
      pendingRequests.sort((a, b) {
        final timestampA = (a.data()['timestamp'] as Timestamp?)?.toDate() ?? DateTime(2000);
        final timestampB = (b.data()['timestamp'] as Timestamp?)?.toDate() ?? DateTime(2000);
        return timestampB.compareTo(timestampA); // descending
      });

      return pendingRequests.map((doc) {
        final data = doc.data();
        return TradeRequest(
          id: doc.id,
          requesterId: data['requesterId'] as String,
          requesterName: data['requesterName'] as String,
          targetId: data['targetId'] as String,
          targetName: data['targetName'] as String,
          requestedColorIndex: data['requestedColorIndex'] as int,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ TRADE: Error getting sent trade requests: $e');
      return [];
    }
  }

  /// Obtine culorile din cache (fara a face query)
  Map<String, int?> getCachedColors() {
    return Map.from(_consultantColorsCache);
  }

  @override
  void dispose() {
    _colorChangeController.close();
    _tradeRequestsController.close();
    super.dispose();
  }
} 

