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
  apeluri,
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
  MobileClientCategory _currentCategory = MobileClientCategory.apeluri;
  
  // Real-time synchronization
  StreamSubscription<List<Map<String, dynamic>>>? _clientsStreamSubscription;
  StreamSubscription<Map<String, dynamic>>? _operationsStreamSubscription;
  Timer? _syncTimer;
  String? _selectedClientId; // Track which client is the "Next Client"

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 MOBILE: initState called');
    
    // Ascunde status bar-ul
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    // Foloseste serviciul pre-incarcat din splash
    _clientService = SplashService().clientUIService;
    _splashService = SplashService();
    _firebaseService = NewFirebaseService();
    
    // FIX: Asculta la schimbarile din SplashService pentru refresh automat
    _splashService.addListener(_onSplashServiceChanged);
    
    // Initializeaza datele demo daca nu exista clienti
    _initializeClients();
    _clientService.addListener(_onClientServiceChanged);
    
    // OPTIMIZARE: Incarca imediat din cache pentru loading instant
    _loadFromCacheInstantly();
    
    // OPTIMIZARE: Pornește sincronizarea în timp real
    _startRealTimeSync();
  }

  @override
  void dispose() {
    // Restoreaza status bar-ul la iesire
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _clientService.removeListener(_onClientServiceChanged);
    _splashService.removeListener(_onSplashServiceChanged);
    
    // Cleanup real-time sync
    _clientsStreamSubscription?.cancel();
    _operationsStreamSubscription?.cancel();
    _syncTimer?.cancel();
    
    super.dispose();
  }

  /// OPTIMIZARE: Pornește sincronizarea în timp real cu Firebase
  Future<void> _startRealTimeSync() async {
    try {
      debugPrint('🔄 MOBILE: Starting comprehensive real-time sync');
      
      // 1. Stream pentru toți clienții
      _clientsStreamSubscription = _firebaseService.getClientsRealTimeStream().listen(
        (List<Map<String, dynamic>> clientsData) {
          debugPrint('🔄 MOBILE: Real-time clients update received with ${clientsData.length} clients');
          _handleClientsRealTimeUpdate(clientsData);
        },
        onError: (error) {
          debugPrint('❌ MOBILE: Real-time clients stream error: $error');
        },
      );

      // 2. Stream pentru operațiuni (create, update, delete)
      _operationsStreamSubscription = _firebaseService.getClientsOperationsRealTimeStream().listen(
        (Map<String, dynamic> operations) {
          debugPrint('🔄 MOBILE: Real-time operations update received');
          _handleOperationsRealTimeUpdate(operations);
        },
        onError: (error) {
          debugPrint('❌ MOBILE: Real-time operations stream error: $error');
        },
      );

      // 3. Timer pentru refresh periodic ca backup
      _syncTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
        _forceRefreshClients();
      });

      debugPrint('✅ MOBILE: Comprehensive real-time sync started');
    } catch (e) {
      debugPrint('❌ MOBILE: Error starting real-time sync: $e');
    }
  }

  /// OPTIMIZARE: Gestionează actualizările în timp real pentru clienți
  Future<void> _handleClientsRealTimeUpdate(List<Map<String, dynamic>> clientsData) async {
    try {
      final List<ClientModel> updatedClients = [];
      
      for (final clientData in clientsData) {
        try {
          final client = ClientModel.fromMap(clientData);
          updatedClients.add(client);
        } catch (e) {
          debugPrint('⚠️ MOBILE: Error parsing client data: $e');
        }
      }

      if (mounted) {
        setState(() {
          _clients = updatedClients;
        });
        
        // OPTIMIZARE: Actualizează și cache-ul din SplashService
        await _splashService.invalidateClientsCacheAndRefresh();
        
        debugPrint('✅ MOBILE: Updated ${_clients.length} clients from real-time sync');
      }
    } catch (e) {
      debugPrint('❌ MOBILE: Error handling clients real-time update: $e');
    }
  }

  /// OPTIMIZARE: Gestionează actualizările în timp real pentru operațiuni
  Future<void> _handleOperationsRealTimeUpdate(Map<String, dynamic> operations) async {
    try {
      final List<Map<String, dynamic>> changes = operations['changes'] ?? [];
      
      for (final change in changes) {
        final String type = change['type'] ?? '';
        final String clientId = change['clientId'] ?? '';
        final Map<String, dynamic> clientData = change['clientData'] ?? {};
        
        debugPrint('🔄 MOBILE: Operation detected - Type: $type, Client: $clientId');
        
        switch (type) {
          case 'added':
            debugPrint('➕ MOBILE: Client added - ${clientData['name']}');
            break;
          case 'modified':
            debugPrint('✏️ MOBILE: Client modified - ${clientData['name']}');
            break;
          case 'removed':
            debugPrint('🗑️ MOBILE: Client removed - $clientId');
            break;
        }
      }
      
      // Refresh clients after operations
      await _forceRefreshClients();
      
    } catch (e) {
      debugPrint('❌ MOBILE: Error handling operations real-time update: $e');
    }
  }

  /// OPTIMIZARE: Incarca imediat din cache pentru loading instant
  Future<void> _loadFromCacheInstantly() async {
    try {
      // Incarca clientii din cache instant
      final cachedClients = await _splashService.getCachedClients();
      
      // FIX: Cleanup focus state when loading from cache
      _clientService.cleanupFocusStateFromCache(cachedClients);
      
      if (mounted) {
        setState(() {
          _clients = cachedClients;
        });
      }
      
      debugPrint('✅ MOBILE: Loaded ${_clients.length} clients from cache');
    } catch (e) {
      debugPrint('❌ MOBILE: Error loading from cache: $e');
      // Fallback to normal loading
      _initializeClients();
    }
  }

  /// OPTIMIZAT: Force refresh pentru a sincroniza cu starea reala
  Future<void> _forceRefreshClients() async {
    try {
      // FIX: Forteaza reincarcarea din Firebase pentru a sincroniza cu starea reala
      await _clientService.loadClientsFromFirebase();
      
      // Incarca din cache actualizat
      final cachedClients = await _splashService.getCachedClients();
      
      if (mounted) {
        setState(() {
          _clients = cachedClients;
        });
      }
      
      debugPrint('🔄 MOBILE: Refreshed ${_clients.length} clients');
    } catch (e) {
      debugPrint('❌ MOBILE: Error refreshing clients: $e');
    }
  }

  void _onSplashServiceChanged() {
    if (mounted) {
      setState(() {
        _clients = _clientService.clients;
      });
    }
  }

  void _onClientServiceChanged() {
    if (mounted) {
      setState(() {
        _clients = _clientService.clients;
      });
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

  // Helper to get clients by category
  List<ClientModel> _getClientsByCategory(MobileClientCategory category) {
    switch (category) {
      case MobileClientCategory.apeluri:
        return _clients.where((client) => client.category == ClientCategory.apeluri).toList();
      case MobileClientCategory.reveniri:
        return _clients.where((client) => client.category == ClientCategory.reveniri).toList();
      case MobileClientCategory.recente:
        return _clients.where((client) => client.category == ClientCategory.recente).toList();
    }
  }

  List<ClientModel> _getClientsForCategory() {
    final clients = _getClientsByCategory(_currentCategory);
    
    // If no client is selected as "Next Client", use the first client
    if (_selectedClientId == null && clients.isNotEmpty) {
      _selectedClientId = clients.first.id;
    }
    
    return clients;
  }

  // Helper to get clients for the main list (excluding the selected "Next Client")
  List<ClientModel> _getMainClients() {
    final allClients = _getClientsForCategory();
    if (_selectedClientId == null || allClients.isEmpty) {
      return allClients;
    }
    
    // Return all clients except the selected one
    return allClients.where((client) => client.id != _selectedClientId).toList();
  }

  // Helper to get the current "Next Client"
  ClientModel? _getNextClient() {
    final allClients = _getClientsForCategory();
    if (_selectedClientId == null || allClients.isEmpty) {
      return allClients.isNotEmpty ? allClients.first : null;
    }
    
    try {
      return allClients.firstWhere((client) => client.id == _selectedClientId);
    } catch (e) {
      // If selected client is not found, return the first client or null
      return allClients.isNotEmpty ? allClients.first : null;
    }
  }

  // Handle client selection - make tapped client the "Next Client"
  void _selectClientAsNext(ClientModel client) {
    setState(() {
      _selectedClientId = client.id;
    });
  }

  String _getCategoryTitle() {
    switch (_currentCategory) {
      case MobileClientCategory.apeluri:
        return 'Apeluri';
      case MobileClientCategory.reveniri:
        return 'Reveniri';
      case MobileClientCategory.recente:
        return 'Recente';
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

  // Refactored: Next Client and regular client have different layouts, both as single rows
  Widget _buildClientCard(ClientModel client, {bool isNext = false}) {
    final initials = _getInitials(client.name);
    if (isNext) {
      // NEXT CLIENT: single row: avatar (left), name+phone (column), call icon (right)
      return GestureDetector(
        onTap: () => _selectClientAsNext(client),
        child: Container(
          width: 312,
          alignment: Alignment.center,
          height: 72,
          // Remove margin at the bottom to avoid overflow
          margin: EdgeInsets.zero,
          padding: EdgeInsets.only(left: 8, right: 24),
          decoration: ShapeDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.00, 0.00),
              end: Alignment(1.00, 1.03),
              colors: [Color(0xFFE0D0D9), Color(0xFFE2CED9), Color(0xFFE0D1D9)],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar (56x56, centered)
              Container(
                width: 56,
                height: 56,
                decoration: ShapeDecoration(
                  color: Color(0xFFC17099),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
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
              // Name and phone (column, exactly 56px high, no extra padding)
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
              // Call button (56x56, centered, no extra margin)
              SizedBox(
                width: 56,
                height: 56,
                child: GestureDetector(
                  onTap: () => _callClient(client.phoneNumber1),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/callIcon.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        Color(0xFFC17099),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // REGULAR CLIENT: single row: avatar (left), name (left column), phone (right column)
      return GestureDetector(
        onTap: () => _selectClientAsNext(client), // Make this client the "Next Client"
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
  }


  /// Initializeaza clientii async
  Future<void> _initializeClients() async {
    if (_clientService.clients.isEmpty) {
      await _clientService.initializeDemoData();
    }
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
        'active': _currentCategory == MobileClientCategory.apeluri,
        'onTap': () {
          setState(() {
            _currentCategory = MobileClientCategory.apeluri;
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

    // Background container (restored and overflow fixed)
    return Center(
      child: Container(
        width: 200,
        height: 72,
        padding: EdgeInsets.all(8),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Color(0xFFE0D1D8),
          borderRadius: BorderRadius.circular(48),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth; // should be 184
            final itemWidth = totalWidth / navItems.length;
            final indicatorWidth = 56.0;
            final selectedIndex = navItems.indexWhere((item) => item['active'] as bool);
            // Clamp indicatorLeft so it never exceeds bounds
            double indicatorLeft = itemWidth * selectedIndex + (itemWidth - indicatorWidth) / 2;
            if (indicatorLeft < 0) indicatorLeft = 0;
            if (indicatorLeft + indicatorWidth > totalWidth) indicatorLeft = totalWidth - indicatorWidth;
            // Debug log
            debugPrint('🔧 [NAVBAR] Target X: ${indicatorLeft.toStringAsFixed(1)}px | itemWidth: ${itemWidth.toStringAsFixed(1)}px | totalWidth: ${totalWidth.toStringAsFixed(1)}px | selectedIndex: $selectedIndex');
            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: totalWidth,
                  height: 56,
                ),
                AnimatedPositioned(
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  left: indicatorLeft,
                  top: 0,
                  child: Container(
                    width: indicatorWidth,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Color(0xFFC17099),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(navItems.length, (index) {
                    final item = navItems[index];
                    return GestureDetector(
                      onTap: item['onTap'] as void Function(),
                      child: Container(
                        width: 56,
                        height: 56,
                        // Add 2px margin for first and last icons
                        margin: EdgeInsets.only(
                          left: index == 0 ? 2 : 0,
                          right: index == navItems.length - 1 ? 2 : 0,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            item['icon'] as String,
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              item['active'] as bool ? Colors.white : Color(0xFFC17099),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainClients = _getMainClients();
    final nextClient = _getNextClient();
    
    return Scaffold(
      backgroundColor: Color(0xFFE8E3E6),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 24),
          child: Column(
            children: [
              // Header
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              // Client list (bottom-up stacking)
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Main clients list (bottom-up)
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: mainClients.reversed.map((client) => 
                            _buildClientCard(client, isNext: false)
                          ).toList(),
                        ),
                      ),
                      // Next client (always at bottom)
                      if (nextClient != null) ...[
                        SizedBox(height: 8),
                        _buildClientCard(nextClient, isNext: true),
                      ],
                    ],
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