import 'package:flutter/material.dart';
import 'package:broker_app/backend/services/clients_service.dart';
import 'package:broker_app/backend/services/splash_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  List<ClientModel> _clients = [];
  bool _isLoading = true;
  MobileClientCategory _currentCategory = MobileClientCategory.apeluri;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 MOBILE: initState called');
    
    // Foloseste serviciul pre-incarcat din splash
    _clientService = SplashService().clientUIService;
    _splashService = SplashService();
    
    // FIX: Ascultă la schimbări în SplashService pentru refresh automat
    _splashService.addListener(_onSplashServiceChanged);
    
    // Initializeaza datele demo daca nu exista clienti
    _initializeClients();
    _clientService.addListener(_onClientServiceChanged);
    
    // OPTIMIZARE: Încarcă imediat din cache pentru loading instant
    _loadFromCacheInstantly();
  }

  /// OPTIMIZARE: Încarcă imediat din cache pentru loading instant
  Future<void> _loadFromCacheInstantly() async {
    try {
      // Încarcă clienții din cache instant
      final cachedClients = await _splashService.getCachedClients();
      
      // FIX: Cleanup focus state when loading from cache
      _clientService.cleanupFocusStateFromCache(cachedClients);
      
      if (mounted) {
        setState(() {
          _clients = cachedClients;
          _isLoading = false;
        });
      }
      
      debugPrint('✅ MOBILE: Loaded ${_clients.length} clients from cache');
    } catch (e) {
      debugPrint('❌ MOBILE: Error loading from cache: $e');
      // Fallback to normal loading
      _initializeClients();
    }
  }

  /// OPTIMIZAT: Force refresh pentru a sincroniza cu starea reală
  Future<void> _forceRefreshClients() async {
    try {
      // FIX: Forțează reîncărcarea din Firebase pentru a sincroniza cu starea reală
      await _clientService.loadClientsFromFirebase();
      
      // Încarcă din cache actualizat
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

  @override
  void dispose() {
    _clientService.removeListener(_onClientServiceChanged);
    _splashService.removeListener(_onSplashServiceChanged);
    super.dispose();
  }


  Future<void> _callClient(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      _showSnackBar('Numarul de telefon este gol');
      return;
    }

    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        debugPrint('🟢 MOBILE: Calling $phoneNumber');
      } else {
        _showSnackBar('Nu se poate efectua apelul');
      }
    } catch (e) {
      debugPrint('🔴 MOBILE: Error making call: $e');
      _showSnackBar('Eroare la efectuarea apelului');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
      ),
    );
  }

  List<ClientModel> _getClientsForCategory() {
    switch (_currentCategory) {
      case MobileClientCategory.apeluri:
        return _clients.where((client) => client.category == ClientCategory.apeluri).toList();
      case MobileClientCategory.reveniri:
        return _clients.where((client) => client.category == ClientCategory.reveniri).toList();
      case MobileClientCategory.recente:
        return _clients.where((client) => client.category == ClientCategory.recente).toList();
    }
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

  Widget _buildClientCard(ClientModel client) {
    return Container(
      width: double.infinity,
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  client.phoneNumber1,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _callClient(client.phoneNumber1),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.phone,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(MobileClientCategory category, String iconPath, String label) {
    final isActive = _currentCategory == category;
    
    return GestureDetector(
      onTap: () => setState(() => _currentCategory = category),
      child: Container(
        width: 80,
        height: 48,
                 decoration: BoxDecoration(
           color: isActive ? const Color(0xFF1976D2) : const Color(0xFFEEEEEE),
           borderRadius: BorderRadius.circular(8),
         ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(iconPath, isActive),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String iconPath, bool isActive) {
    try {
      return SvgPicture.asset(
        iconPath,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(
          isActive ? Colors.white : const Color(0xFF757575),
          BlendMode.srcIn,
        ),
      );
    } catch (e) {
      debugPrint('🔴 MOBILE: Error loading icon: $e');
      IconData iconData;
      switch (iconPath) {
        case 'assets/callIcon.svg':
          iconData = Icons.phone;
          break;
        case 'assets/returnIcon.svg':
          iconData = Icons.replay;
          break;
        case 'assets/historyIcon.svg':
          iconData = Icons.history;
          break;
        default:
          iconData = Icons.phone;
      }
      
      return Icon(
        iconData,
        size: 20,
        color: isActive ? Colors.white : const Color(0xFF757575),
      );
    }
  }

  /// Initializeaza clientii async
  Future<void> _initializeClients() async {
    if (_clientService.clients.isEmpty) {
      await _clientService.initializeDemoData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final clients = _getClientsForCategory();
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header negru cu logo și nume
            Container(
              width: double.infinity,
              height: 80,
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Logo placeholder
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'M.A.T Finance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Container principal gri
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Titlu categorie
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _getCategoryTitle(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    
                    // Lista de clienți
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : clients.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        size: 64,
                                        color: const Color(0xFFBDBDBD),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Nu exista clienti',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: const Color(0xFF757575),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _forceRefreshClients,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    itemCount: clients.length,
                                    itemBuilder: (context, index) {
                                      return _buildClientCard(clients[index]);
                                    },
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bara de navigare de jos
            Container(
              width: double.infinity,
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavigationButton(
                    MobileClientCategory.apeluri,
                    'assets/callIcon.svg',
                    'Apeluri',
                  ),
                  _buildNavigationButton(
                    MobileClientCategory.reveniri,
                    'assets/returnIcon.svg',
                    'Reveniri',
                  ),
                  _buildNavigationButton(
                    MobileClientCategory.recente,
                    'assets/historyIcon.svg',
                    'Recente',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 