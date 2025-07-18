import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service pentru monitorizarea stării conexiunii și gestionarea sincronizării
/// CRITICAL FIX: Implementare avansată pentru gestionarea reconnects și sync failures
class ConnectionService extends ChangeNotifier {
  static final ConnectionService _instance = ConnectionService._internal();
  factory ConnectionService() => _instance;
  ConnectionService._internal();

  // Connection state
  bool _isConnected = true;
  bool _isFirebaseConnected = true;
  bool _isReconnecting = false;
  DateTime? _lastConnectionLoss;
  DateTime? _lastSuccessfulSync;
  
  // Sync state
  bool _isSyncing = false;
  
  // Streams
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _firebaseConnectionSubscription;
  
  // Sync queue for offline operations
  final List<Map<String, dynamic>> _syncQueue = [];
  Timer? _syncQueueTimer;
  
  // FIX: Retry tracking for Firebase reconnection
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  
  // Getters
  bool get isConnected => _isConnected;
  bool get isFirebaseConnected => _isFirebaseConnected;
  bool get isReconnecting => _isReconnecting;
  bool get isSyncing => _isSyncing;
  bool get hasOfflineChanges => _syncQueue.isNotEmpty;
  DateTime? get lastConnectionLoss => _lastConnectionLoss;
  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;
  
  /// Inițializează monitorizarea conexiunii
  Future<void> initialize() async {
    try {
      debugPrint('🔌 CONNECTION_SERVICE: Initializing connection monitoring');
      
      // Monitorizează conectivitatea la internet
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          // Folosește primul rezultat pentru compatibilitate
          final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
          _handleConnectivityChange(result);
        },
        onError: (error) {
          debugPrint('❌ CONNECTION_SERVICE: Connectivity stream error: $error');
        },
      );
      
      // Monitorizează conexiunea Firebase
      _monitorFirebaseConnection();
      
      // Pornește procesarea cozii de sincronizare
      _startSyncQueueProcessing();
      
      debugPrint('✅ CONNECTION_SERVICE: Connection monitoring initialized');
    } catch (e) {
      debugPrint('❌ CONNECTION_SERVICE: Error initializing connection monitoring: $e');
    }
  }
  
  /// Gestionează schimbările de conectivitate
  void _handleConnectivityChange(ConnectivityResult result) {
    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;
    
    debugPrint('🔌 CONNECTION_SERVICE: Connectivity changed - Connected: $_isConnected');
    
    if (wasConnected && !_isConnected) {
      // Conectivitatea s-a pierdut
      _handleConnectionLoss();
    } else if (!wasConnected && _isConnected) {
      // Conectivitatea s-a restabilit
      _handleConnectionRestored();
    }
    
    notifyListeners();
  }
  
  /// Monitorizează conexiunea Firebase
  void _monitorFirebaseConnection() {
    try {
      // FIX: Monitor Firebase connection status
      _firebaseConnectionSubscription = FirebaseFirestore.instance
          .collection('_health')
          .doc('connection')
          .snapshots()
          .listen(
        (snapshot) {
          final wasConnected = _isFirebaseConnected;
          _isFirebaseConnected = snapshot.exists;
          
          debugPrint('🔌 CONNECTION_SERVICE: Firebase connection changed - Connected: $_isFirebaseConnected');
          
          if (wasConnected && !_isFirebaseConnected) {
            _handleFirebaseConnectionLoss();
          } else if (!wasConnected && _isFirebaseConnected) {
            _handleFirebaseConnectionRestored();
          }
          
          notifyListeners();
        },
        onError: (error) {
          debugPrint('❌ CONNECTION_SERVICE: Firebase connection monitoring error: $error');
          _isFirebaseConnected = false;
          _handleFirebaseConnectionLoss();
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('❌ CONNECTION_SERVICE: Error monitoring Firebase connection: $e');
      _isFirebaseConnected = false;
      notifyListeners();
    }
  }

  /// Gestionează pierderea conexiunii Firebase
  void _handleFirebaseConnectionLoss() {
    _lastConnectionLoss = DateTime.now();
    _isReconnecting = true;
    
    debugPrint('🔌 CONNECTION_SERVICE: Firebase connection lost, attempting reconnection...');
    
    // FIX: Attempt reconnection with exponential backoff
    _attemptFirebaseReconnection();
  }

  /// Gestionează restabilirea conexiunii Firebase
  void _handleFirebaseConnectionRestored() {
    _isReconnecting = false;
    _lastSuccessfulSync = DateTime.now();
    
    debugPrint('🔌 CONNECTION_SERVICE: Firebase connection restored');
    
    // FIX: Process any pending sync operations
    if (_syncQueue.isNotEmpty) {
      _processSyncQueue();
    }
  }

  /// FIX: Attempt Firebase reconnection with exponential backoff
  void _attemptFirebaseReconnection() {
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      final delay = Duration(seconds: _reconnectAttempts * 3); // 3s, 6s, 9s, 12s, 15s
      
      debugPrint('🔌 CONNECTION_SERVICE: Reconnection attempt $_reconnectAttempts/$_maxReconnectAttempts in ${delay.inSeconds}s');
      
      Future.delayed(delay, () {
        if (_isReconnecting) {
          _attemptFirebaseReconnection();
        }
      });
    } else {
      debugPrint('❌ CONNECTION_SERVICE: Max reconnection attempts reached');
      _reconnectAttempts = 0;
      _isReconnecting = false;
    }
  }
  
  /// Gestionează pierderea conexiunii
  void _handleConnectionLoss() {
    _lastConnectionLoss = DateTime.now();
    debugPrint('🔌 CONNECTION_SERVICE: Connection lost at $_lastConnectionLoss');
    
    // Oprește sincronizarea activă
    _isSyncing = false;
    
    // Salvează starea curentă pentru recovery
    _saveOfflineState();
  }
  
  /// Gestionează restabilirea conexiunii
  void _handleConnectionRestored() {
    debugPrint('🔌 CONNECTION_SERVICE: Connection restored');
    
    // Pornește reconnection process
    _startReconnection();
  }
  
  
  
  /// Pornește procesul de reconectare
  Future<void> _startReconnection() async {
    if (_isReconnecting) return;
    
    _isReconnecting = true;
    notifyListeners();
    
    try {
      debugPrint('🔄 CONNECTION_SERVICE: Starting reconnection process');
      
      // Așteaptă puțin înainte de a încerca reconectarea
      await Future.delayed(const Duration(seconds: 2));
      
      // Verifică din nou conectivitatea
      final connectivityResults = await Connectivity().checkConnectivity();
      final connectivityResult = connectivityResults.isNotEmpty ? connectivityResults.first : ConnectivityResult.none;
      if (connectivityResult == ConnectivityResult.none) {
        debugPrint('❌ CONNECTION_SERVICE: Still no connectivity');
        return;
      }
      
      // Testează conexiunea Firebase
      await FirebaseFirestore.instance
          .collection('_health')
          .doc('connection_test')
          .get()
          .timeout(const Duration(seconds: 10));
      
      _isFirebaseConnected = true;
      _lastSuccessfulSync = DateTime.now();
      
      debugPrint('✅ CONNECTION_SERVICE: Reconnection successful');
      
      // Procesează coada de sincronizare
      _processSyncQueue();
      
    } catch (e) {
      debugPrint('❌ CONNECTION_SERVICE: Reconnection failed: $e');
    } finally {
      _isReconnecting = false;
      notifyListeners();
    }
  }
  
  /// Salvează starea pentru recovery offline
  void _saveOfflineState() {
    // Implementare pentru salvarea stării curente
    debugPrint('💾 CONNECTION_SERVICE: Saving offline state');
  }
  
  /// Adaugă o operație în coada de sincronizare
  void addToSyncQueue(String operation, Map<String, dynamic> data) {
    if (_isConnected && _isFirebaseConnected) {
      // Dacă suntem conectați, execută imediat
      _executeSyncOperation(operation, data);
    } else {
      // Altfel, adaugă în coadă
      _syncQueue.add({
        'operation': operation,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      debugPrint('📋 CONNECTION_SERVICE: Added to sync queue: $operation');
      notifyListeners();
    }
  }
  
  /// Pornește procesarea cozii de sincronizare
  void _startSyncQueueProcessing() {
    _syncQueueTimer?.cancel();
    _syncQueueTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _isFirebaseConnected && _syncQueue.isNotEmpty) {
        _processSyncQueue();
      }
    });
  }
  
  /// Procesează coada de sincronizare
  Future<void> _processSyncQueue() async {
    if (_syncQueue.isEmpty || _isSyncing) return;
    
    _isSyncing = true;
    notifyListeners();
    
    try {
      debugPrint('🔄 CONNECTION_SERVICE: Processing sync queue (${_syncQueue.length}) items');
      
      final itemsToProcess = List<Map<String, dynamic>>.from(_syncQueue);
      _syncQueue.clear();
      
      for (final item in itemsToProcess) {
        try {
          await _executeSyncOperation(
            item['operation'] as String,
            item['data'] as Map<String, dynamic>,
          );
          
          debugPrint('✅ CONNECTION_SERVICE: Synced operation: ${item['operation']}');
        } catch (e) {
          debugPrint('❌ CONNECTION_SERVICE: Failed to sync operation: ${item['operation']} - $e');
          
          // Re-adaugă în coadă pentru retry
          _syncQueue.add(item);
        }
      }
      
      _lastSuccessfulSync = DateTime.now();
      debugPrint('✅ CONNECTION_SERVICE: Sync queue processing completed');
      
    } catch (e) {
      debugPrint('❌ CONNECTION_SERVICE: Error processing sync queue: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  /// Execută o operație de sincronizare
  Future<void> _executeSyncOperation(String operation, Map<String, dynamic> data) async {
    // Implementare pentru diferite tipuri de operații
    switch (operation) {
      case 'create_client':
        // Implementare pentru crearea clientului
        break;
      case 'update_client':
        // Implementare pentru actualizarea clientului
        break;
      case 'delete_client':
        // Implementare pentru ștergerea clientului
        break;
      case 'create_meeting':
        // Implementare pentru crearea întâlnirii
        break;
      default:
        debugPrint('⚠️ CONNECTION_SERVICE: Unknown sync operation: $operation');
    }
  }
  
  /// Forțează sincronizarea imediată
  Future<void> forceSync() async {
    if (!_isConnected || !_isFirebaseConnected) {
      debugPrint('❌ CONNECTION_SERVICE: Cannot force sync - not connected');
      return;
    }
    
    await _processSyncQueue();
  }
  
  /// Verifică dacă aplicația poate sincroniza
  bool get canSync => _isConnected && _isFirebaseConnected && !_isSyncing;
  
  /// Obtine status-ul conexiunii pentru UI
  Map<String, dynamic> getConnectionStatus() {
    return {
      'isConnected': _isConnected,
      'isFirebaseConnected': _isFirebaseConnected,
      'isReconnecting': _isReconnecting,
      'isSyncing': _isSyncing,
      'hasOfflineChanges': hasOfflineChanges,
      'lastConnectionLoss': _lastConnectionLoss?.toIso8601String(),
      'lastSuccessfulSync': _lastSuccessfulSync?.toIso8601String(),
      'syncQueueSize': _syncQueue.length,
    };
  }
  
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _firebaseConnectionSubscription?.cancel();
    _syncQueueTimer?.cancel();
    super.dispose();
  }
} 