import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:broker_app/backend/services/clients_service.dart';
import 'package:broker_app/backend/services/splash_service.dart';
import 'package:broker_app/backend/services/firebase_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

enum MobileClientCategory {
  clienti,
  reveniri,
  recente,
}

class MobileClientsScreen extends StatefulWidget {
  const MobileClientsScreen({super.key});

  @override
  State<MobileClientsScreen> createState() => _MobileClientsScreenState();
}

class _MobileClientsScreenState extends State<MobileClientsScreen> {
  late final ClientUIService _clientService;
  late final SplashService _splashService;
  late final NewFirebaseService _firebaseService;
  List<ClientModel> _clients = [];
  MobileClientCategory _currentCategory = MobileClientCategory.clienti;
  
  // FIX: Simplified sync system - only one source of truth
  StreamSubscription<List<Map<String, dynamic>>>? _firebaseSubscription;
  StreamSubscription<Map<String, dynamic>>? _operationsSubscription;
  
  // FIX: Single refresh flag to prevent conflicts
  bool _isRefreshing = false;
  
  // FIX: Debounce timer for data updates
  Timer? _dataUpdateDebounceTimer;
  
  // FIX: Track last update to prevent duplicate processing

  @override
  void initState() {
    super.initState();
    
    // Ascunde status bar-ul
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    // Foloseste serviciul pre-incarcat din splash
    _clientService = SplashService().clientUIService;
    _splashService = SplashService();
    _firebaseService = NewFirebaseService();
    
    // Initializeaza datele demo daca nu exista clienti
    _initializeClients();
    
    // FIX: Load from cache first for instant display
    _loadFromCacheInstantly();
    
    // FIX: Start simplified Firebase listeners
    _startFirebaseListeners();
  }

  @override
  void dispose() {
    // Restoreaza status bar-ul la iesire
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    // FIX: Stop Firebase listeners
    _stopFirebaseListeners();
    
    _dataUpdateDebounceTimer?.cancel();
    
    super.dispose();
  }

  /// FIX: Start simplified Firebase listeners
  Future<void> _startFirebaseListeners() async {
    try {
      
      // Stop existing listeners first
      _stopFirebaseListeners();
      
      // 1. Main clients stream
      _firebaseSubscription = _firebaseService.getClientsRealTimeStream().listen(
        (List<Map<String, dynamic>> clientsData) {
          _handleFirebaseUpdate(clientsData);
        },
        onError: (error) {
          FirebaseLogger.error('❌ MOBILE: Firebase stream error: $error');
        },
        cancelOnError: false,
      );

      // 2. Operations stream
      _operationsSubscription = _firebaseService.getClientsOperationsRealTimeStream().listen(
        (Map<String, dynamic> operations) {
          _handleOperationsUpdate(operations);
        },
        onError: (error) {
          FirebaseLogger.error('❌ MOBILE: Operations stream error: $error');
        },
        cancelOnError: false,
      );

    } catch (e) {
      FirebaseLogger.error('❌ MOBILE: Error starting Firebase listeners: $e');
    }
  }

  /// FIX: Stop Firebase listeners
  void _stopFirebaseListeners() {
    _firebaseSubscription?.cancel();
    _operationsSubscription?.cancel();
    _firebaseSubscription = null;
    _operationsSubscription = null;
  }

  /// FIX: Handle Firebase updates with conflict prevention
  void _handleFirebaseUpdate(List<Map<String, dynamic>> clientsData) {
    try {
      final List<ClientModel> newClients = [];
      
      for (final clientData in clientsData) {
        try {
          final client = ClientModel.fromMap(clientData);
          newClients.add(client);
        } catch (e) {
          FirebaseLogger.error('Error parsing client data: $e');
        }
      }

      // FIX: Check if data actually changed before updating
      final hasChanged = _clients.length != newClients.length ||
          !_clients.every((client) => newClients.any((newClient) => 
              newClient.phoneNumber == client.phoneNumber &&
              newClient.category == client.category &&
              newClient.status == client.status &&
              newClient.name == client.name));

      if (hasChanged || _clients.isEmpty) {
        // Update local clients list
        _clients = newClients;
        
        // Update UI
        setState(() {});
        
        FirebaseLogger.success('Data updated successfully from firebase - ${_clients.length} clients');
      }
    } catch (e) {
      FirebaseLogger.error('Error handling Firebase update: $e');
    }
  }

  /// FIX: Handle operations updates
  void _handleOperationsUpdate(Map<String, dynamic> operations) {
    try {
      final List<Map<String, dynamic>> changes = operations['changes'] ?? [];
      
      for (final change in changes) {
        final String type = change['type'] ?? '';
        final String clientId = change['clientId'] ?? '';
        final Map<String, dynamic> clientData = change['clientData'] ?? {};
        
        switch (type) {
          case 'added':
            FirebaseLogger.logOperation('added', clientId: clientId, category: clientData['name']);
            break;
          case 'modified':
            if (change['isCategoryChange'] == true) {
              FirebaseLogger.logOperation('category_change', clientId: clientId, category: clientData['category']);
            }
            break;
          case 'removed':
            FirebaseLogger.logOperation('removed', clientId: clientId, category: clientData['name']);
            // Remove from local list immediately
            _clients.removeWhere((client) => client.phoneNumber == clientId);
            setState(() {});
            break;
        }
      }
    } catch (e) {
      FirebaseLogger.error('Error handling operations update: $e');
    }
  }


  /// FIX: Centralized data update with conflict prevention
  void _updateClientsData(List<ClientModel> newClients, {String source = 'unknown'}) {
    // FIX: Debounce rapid updates
    _dataUpdateDebounceTimer?.cancel();
    _dataUpdateDebounceTimer = Timer(const Duration(milliseconds: 100), () {
      _performDataUpdate(newClients, source);
    });
  }
  
  /// FIX: Perform the actual data update
  void _performDataUpdate(List<ClientModel> newClients, String source) {
    if (_isRefreshing) {
      return;
    }
    
    try {
      final currentCount = _clients.length;
      final newCount = newClients.length;
      
      // FIX: Check for significant changes
      bool hasSignificantChanges = false;
      
      if (currentCount != newCount) {
        hasSignificantChanges = true;
      } else {
        // Check for individual client changes
        for (final newClient in newClients) {
          final existingClient = _clients.firstWhere(
            (client) => client.phoneNumber == newClient.phoneNumber,
            orElse: () => ClientModel(
              id: '',
              name: '',
              phoneNumber1: '',
              category: ClientCategory.apeluri,
              status: ClientStatus.normal,
              formData: {}, // <-- required argument
            ),
          );
          
          if (existingClient.phoneNumber.isNotEmpty) {
            if (existingClient.category != newClient.category ||
                existingClient.status != newClient.status ||
                existingClient.name != newClient.name) {
              hasSignificantChanges = true;
            }
          } else {
            hasSignificantChanges = true;
          }
        }
      }
      
      if (hasSignificantChanges || _clients.isEmpty) {
        if (mounted) {
          setState(() {
            _clients = List<ClientModel>.from(newClients);
          });
        }
        
        // FIX: Show bulk deletion feedback only when appropriate
        if (_clients.isEmpty && newClients.isEmpty && source == 'firebase') {
          _showBulkDeletionFeedback();
        }
      }
    } catch (e) {
      FirebaseLogger.error('Error in data update from $source: $e');
    }
  }


  /// FIX: Show feedback for bulk deletions
  void _showBulkDeletionFeedback() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Toti clientii au fost stersi'),
          backgroundColor: Color(0xFFC17099),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }


  /// FIX: Load from cache instantly
  Future<void> _loadFromCacheInstantly() async {
    try {
      final cachedClients = await _splashService.getCachedClients();
      _updateClientsData(cachedClients, source: 'cache_load');
    } catch (e) {
      FirebaseLogger.error('Error loading from cache: $e');
      _initializeClients();
    }
  }

  /// FIX: Force refresh only when needed
  Future<void> _forceRefresh() async {
    if (_isRefreshing) return;
    
    try {
      _isRefreshing = true;
      
      await _clientService.loadClientsFromFirebase();
      final cachedClients = await _splashService.getCachedClients();
      _updateClientsData(cachedClients, source: 'force_refresh');
      
    } catch (e) {
      FirebaseLogger.error('Error force refreshing clients: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  /// Initializeaza clientii async
  Future<void> _initializeClients() async {
    if (_clientService.clients.isEmpty) {
      await _clientService.initializeDemoData();
    }
  }

  // Helper to get initials from client name (no diacritics)
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    String initials = '';
    for (var part in parts) {
      if (part.isNotEmpty) {
        initials += part[0].toUpperCase();
      }
      if (initials.length == 2) break;
    }
    return initials;
  }

  // Helper to get clients by category
  List<ClientModel> _getClientsByCategory(MobileClientCategory category) {
    switch (category) {
      case MobileClientCategory.clienti:
        return _clients.where((client) => client.category == ClientCategory.apeluri).toList();
      case MobileClientCategory.reveniri:
        return _clients.where((client) => client.category == ClientCategory.reveniri).toList();
      case MobileClientCategory.recente:
        return _clients.where((client) => client.category == ClientCategory.recente).toList();
    }
  }

  String _getCategoryTitle() {
    switch (_currentCategory) {
      case MobileClientCategory.clienti:
        return 'Clienti';
      case MobileClientCategory.reveniri:
        return 'Reveniri';
      case MobileClientCategory.recente:
        return 'Recente';
    }
  }

  // Helper to trigger a phone call
  Future<void> _callClient(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  // Helper to send a message
  Future<void> _sendMessage(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;
    final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }

  // Build client card with swipe actions
  Widget _buildClientCard(ClientModel client) {
    final initials = _getInitials(client.name);
    
    return Dismissible(
      key: Key(client.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right - call
          await _callClient(client.phoneNumber1);
          return false; // Don't dismiss the item
        } else if (direction == DismissDirection.endToStart) {
          // Swipe left - message
          await _sendMessage(client.phoneNumber1);
          return false; // Don't dismiss the item
        }
        return false;
      },
      background: Container(
        height: 64, // Match the client item height
        margin: EdgeInsets.only(bottom: 8), // Match the client item margin
        decoration: BoxDecoration(
          color: Color(0xFF4CAF50), // Green for call
          borderRadius: BorderRadius.circular(32),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
        child: Row(
          children: [
            Icon(
              Icons.call,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Call',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        height: 64, // Match the client item height
        margin: EdgeInsets.only(bottom: 8), // Match the client item margin
        decoration: BoxDecoration(
          color: Color(0xFF2196F3), // Blue for message
          borderRadius: BorderRadius.circular(32),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Message',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.message,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
      child: Container(
        width: double.infinity,
        height: 64,
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.only(left: 8, right: 24),
        decoration: ShapeDecoration(
          color: Color(0xFFE5DCE0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(
                color: Color(0xFFC17099),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.urbanist(
                    color: Color(0xFFF5D6D6),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            // Name and phone (in two columns)
            Expanded(
              child: Container(
                height: 48,
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      client.name,
                      style: GoogleFonts.urbanist(
                        color: Color(0xFFC17099),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      client.phoneNumber1,
                      style: GoogleFonts.urbanist(
                        color: Color(0xFFA88999),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    final navItems = [
      {
        'icon': 'assets/returnIcon.svg',
        'active': _currentCategory == MobileClientCategory.reveniri,
        'onTap': () {
          setState(() {
            _currentCategory = MobileClientCategory.reveniri;
          });
        },
      },
      {
        'icon': 'assets/callIcon.svg',
        'active': _currentCategory == MobileClientCategory.clienti,
        'onTap': () {
          setState(() {
            _currentCategory = MobileClientCategory.clienti;
          });
        },
      },
      {
        'icon': 'assets/historyIcon.svg',
        'active': _currentCategory == MobileClientCategory.recente,
        'onTap': () {
          setState(() {
            _currentCategory = MobileClientCategory.recente;
          });
        },
      },
    ];

    return Center(
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(8),
        decoration: ShapeDecoration(
          color: const Color(0xFFE0D1D8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(48),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(navItems.length, (index) {
            final item = navItems[index];
            return GestureDetector(
              onTap: item['onTap'] as void Function(),
              child: Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(8),
                decoration: ShapeDecoration(
                  color: item['active'] as bool ? const Color(0xFFC17099) : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      item['icon'] as String,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        item['active'] as bool ? Color(0xFFF5D6D6) : Color(0xFFC17099),
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clients = _getClientsByCategory(_currentCategory);
    
    return Scaffold(
      backgroundColor: Color(0xFFE8E3E6),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 24),
          child: Column(
            children: [
              // Header with sync indicator
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getCategoryTitle(),
                            style: GoogleFonts.urbanist(
                              color: Color(0xFFC17099),
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_isRefreshing) ...[
                            SizedBox(width: 8),
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC17099)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              // Client list with pull-to-refresh
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _forceRefresh();
                  },
                  color: Color(0xFFC17099),
                  backgroundColor: Color(0xFFE8E3E6),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: clients.reversed.map((client) => 
                        _buildClientCard(client)
                      ).toList(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              // Navbar
              _buildNavBar(context),
            ],
          ),
        ),
      ),
    );
  }
} 