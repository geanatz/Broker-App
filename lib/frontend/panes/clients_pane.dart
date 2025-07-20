import '../../app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../components/headers/widget_header2.dart';
import '../components/headers/widget_header3.dart';
import '../components/items/dark_item7.dart';
import '../components/items/light_item7.dart';
import '../../backend/services/clients_service.dart';
import '../../backend/services/splash_service.dart';

import '../popups/status_popup.dart';
import '../../backend/services/firebase_service.dart';

/// ClientsPane - Interfata pentru gestionarea clientilor
/// OPTIMIZAT: Implementare avansată cu cache inteligent și loading instant
/// 
/// Aceasta interfata este impartita in 3 sectiuni:
/// 1. Clienti - toti clientii activi (FILL - nu se poate collapse)
/// 2. Reveniri - clientii care suna ocupat sau sunt amanati (HUG - se poate collapse)
/// 3. Recente - clientii respinsi sau finalizati cu succes (HUG - se poate collapse)
/// 
/// Logica de focus:
/// - LightItem7: starea normala (viewIcon)
/// - DarkItem7: starea focusata (doneIcon)
class ClientsPane extends StatefulWidget {
  /// Callback pentru deschiderea popup-ului de clienti
  final VoidCallback? onClientsPopupRequested;
  /// Callback pentru schimbarea zonei la formular
  final VoidCallback? onSwitchToFormArea;

  const ClientsPane({
    super.key,
    this.onClientsPopupRequested,
    this.onSwitchToFormArea,
  });

  @override
  State<ClientsPane> createState() => _ClientsPaneState();
}

class _ClientsPaneState extends State<ClientsPane> {
  late final ClientUIService _clientService;
  late final SplashService _splashService;
  
  // Stari pentru collapse/expand sectiuni (doar pentru Reveniri si Recente)
  bool _isReveniriCollapsed = false;
  bool _isRecenteCollapsed = false;
  
  // OPTIMIZARE: Cache pentru clienți cu timestamp
  List<ClientModel> _cachedClients = [];

  // OPTIMIZARE: Debouncing pentru client switching pentru a preveni UI freezing
  Timer? _clientSwitchDebounceTimer;
  bool _isSwitchingClient = false;
  
  // FIX: Debouncing pentru refresh-uri pentru a preveni infinite loop
  Timer? _refreshDebounceTimer;
  bool _isRefreshing = false;

  // Add these fields to the _ClientsPaneState class:
  bool _reveniriCollapseInitialized = false;
  bool _recenteCollapseInitialized = false;

  /// OPTIMIZATION: Track last tapped client to prevent redundant operations
  String? _lastTappedClientId;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    PerformanceMonitor.startTimer('clientsPaneInit');
    
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
    
    PerformanceMonitor.endTimer('clientsPaneInit');
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
          _cachedClients = cachedClients;
        });
      }
      
      // OPTIMIZATION: Preload form data after cache load
      await _preloadFormDataForVisibleClients();
      
    } catch (e) {
      debugPrint('❌ CLIENTS: Error loading from cache: $e');
      // Fallback to normal loading
      _initializeClients();
    }
  }

  /// OPTIMIZATION: Ultra-fast preloading for most likely clients
  Future<void> _preloadFormDataForVisibleClients() async {
    try {
      // OPTIMIZATION: Only preload for the most likely client (first from each category)
      final clientsToPreload = <String>[];
      
      // Add first client from each category only
      for (final category in ClientCategory.values) {
        final categoryClients = _clientService.getClientsByCategoryWithoutTemporary(category);
        if (categoryClients.isNotEmpty) {
          clientsToPreload.add(categoryClients.first.phoneNumber);
        }
      }
      
      // Limit to first 3 clients total for ultra-fast preloading
      final limitedClients = clientsToPreload.take(3).toList();
      
      if (limitedClients.isNotEmpty) {
        debugPrint('⚡ CLIENTS: Preloading form data for ${limitedClients.length} clients');
        final formService = SplashService().formService;
        await formService.preloadFormDataForClients(limitedClients);
      }
      
    } catch (e) {
      debugPrint('❌ CLIENTS: Error preloading form data: $e');
    }
  }

  /// OPTIMIZATION: Force refresh clients with preloading
  Future<void> _forceRefreshClients() async {
    if (_isRefreshing) return;
    
    try {
      _isRefreshing = true;
      
      // FIX: Forțează reîncărcarea din Firebase pentru a sincroniza cu starea reală
      await _clientService.loadClientsFromFirebase();
      
      // Încarcă din cache actualizat
      final cachedClients = await _splashService.getCachedClients();
      
      if (mounted) {
        setState(() {
          _cachedClients = cachedClients;
        });
      }
      
      // OPTIMIZATION: Preload form data after refresh
      await _preloadFormDataForVisibleClients();
      
    } catch (e) {
      debugPrint('❌ CLIENTS: Error refreshing clients: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  void dispose() {
    _clientSwitchDebounceTimer?.cancel();
    _refreshDebounceTimer?.cancel();
    _clientService.removeListener(_onClientServiceChanged);
    _splashService.removeListener(_onSplashServiceChanged);
    super.dispose();
  }

  /// OPTIMIZAT: Callback pentru refresh automat când se schimbă datele în SplashService
  void _onSplashServiceChanged() {
    if (mounted && !_isRefreshing) {
      // FIX: Force refresh to ensure we get the latest data
      _forceRefreshClients();
    }
  }

  void _onClientServiceChanged() {
    // FIX: Previne infinite loop cu debouncing
    if (_isRefreshing) return;
    
    // OPTIMIZARE: Defer setState until after the current frame to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isRefreshing) {
        // FIX: Check if data actually changed before updating UI
        final newClients = _clientService.clients;
        final hasChanged = _cachedClients.length != newClients.length ||
            !_cachedClients.every((client) => newClients.any((newClient) => 
                newClient.phoneNumber == client.phoneNumber &&
                newClient.category == client.category &&
                newClient.status == client.status &&
                newClient.name == client.name));

        if (hasChanged || _cachedClients.isEmpty) {
          setState(() {
            _cachedClients = newClients;
          });
        }
      }
    });
  }

  /// FIX: Advanced client switching with detailed performance profiling
  Future<void> _handleClientTap(ClientModel client) async {
    // OPTIMIZATION: Minimal protection for ultra-fast response
    final now = DateTime.now();
    if (_isSwitchingClient || 
        (_lastTappedClientId == client.phoneNumber && 
         _lastTapTime != null && 
         now.difference(_lastTapTime!).inMilliseconds < 50)) {

      return;
    }
    
    try {
      _isSwitchingClient = true;
      _lastTappedClientId = client.phoneNumber;
      _lastTapTime = now;
      
      // FIX: Log focus state before client tap
      _clientService.logFocusState('CLIENTS_BEFORE_TAP');

    
      // OPTIMIZATION: Strategic area switching with timing
      if (widget.onSwitchToFormArea != null) {

        widget.onSwitchToFormArea!();
      }
      
      
      // FIX: Advanced client focusing with detailed timing
      
      await _clientService.focusClient(client.phoneNumber);
      
      
      // FIX: Log focus state after focus operation
      _clientService.logFocusState('CLIENTS_AFTER_FOCUS');
      
      // FIX: Force immediate UI update with timing
      if (mounted) {
        setState(() {});
      }
      
      
      
      
      // FIX: Log final focus state
      _clientService.logFocusState('CLIENTS_TAP_COMPLETE');
      
    } catch (e) {
      debugPrint('❌ CLIENTS: Error switching client: $e');
    } finally {
      _isSwitchingClient = false;
    }
  }

  /// OPTIMIZAT: Construieste lista de clienti pentru o anumita categorie cu cache
  Widget _buildClientsList(ClientCategory category) {
    // Foloseste intotdeauna lista live din service pentru a reflecta focusul corect
    // FARA clientul temporar pentru clients-pane (temporarul apare doar in popup)
    List<ClientModel> clients = _clientService.getClientsByCategoryWithoutTemporary(category);
    
    if (clients.isEmpty) {
      return SizedBox(
        height: 60, // Inaltime fixa pentru mesajul de empty state
        child: Center(
          child: Text(
            'Nu exista clienti',
            style: TextStyle(
              color: AppTheme.elementColor1,
              fontSize: AppTheme.fontSizeSmall,
            ),
          ),
        ),
      );
    }

    final bool isApeluri = category == ClientCategory.apeluri;
    
    if (isApeluri) {
              // Pentru sectiunea Clienti (care e Expanded), folosim ListView normal
      return ListView.separated(
        itemCount: clients.length,
        separatorBuilder: (context, index) => SizedBox(height: AppTheme.smallGap),
        itemBuilder: (context, index) => _buildClientItem(clients[index]),
      );
    } else {
      // Pentru Reveniri si Recente, limitez la maxim 3 clienti vizibili
      const int maxVisibleClients = 3;
      const double itemHeight = 64.0; // Inaltime ajustata pentru LightItem7/DarkItem7 (56px + padding)
      final double gapHeight = AppTheme.smallGap; // Folosesc valoarea exacta din tema
      
      // Calculez inaltimea necesara pentru maximum 3 clienti
      final int itemsToShow = clients.length > maxVisibleClients ? maxVisibleClients : clients.length;
      final double totalHeight = itemsToShow > 0 
          ? (itemHeight * itemsToShow) + (gapHeight * (itemsToShow - 1))
          : 60.0; // Fallback pentru empty state
      
      return SizedBox(
        height: totalHeight,
        child: ListView.separated(
          itemCount: clients.length,
          separatorBuilder: (context, index) => SizedBox(height: AppTheme.smallGap),
          itemBuilder: (context, index) => _buildClientItem(clients[index]),
        ),
      );
    }
  }

  /// Construieste un item pentru un client
  Widget _buildClientItem(ClientModel client) {
    final bool isFocused = client.status == ClientStatus.focused;
    final bool hasDiscussionStatus = client.discussionStatus != null && client.discussionStatus!.isNotEmpty;
    
    // Determina ce sa afiseze ca descriere
    String description;
    if (hasDiscussionStatus) {
      // Daca are status salvat, afiseaza statusul
      description = client.discussionStatus!;
    } else if (client.category == ClientCategory.reveniri && client.scheduledDateTime != null) {
      // Pentru clientii amanati, afiseaza data si ora
      description = DateFormat('dd/MM/yy HH:mm').format(client.scheduledDateTime!);
    } else {
      // Pentru ceilalti clienti, afiseaza numarul de telefon
      description = client.phoneNumber;
    }
    
    if (isFocused) {
      return DarkItem7(
        title: client.name,
        description: description,
        svgAsset: 'assets/editIcon.svg', // Întotdeauna editIcon pentru client focusat
        onTap: () => _showClientSavePopup(client),
        onIconTap: () => _showClientSavePopup(client),
      );
    } else {
      return LightItem7(
        title: client.name,
        description: description,
        svgAsset: 'assets/viewIcon.svg', // Întotdeauna viewIcon pentru client nefocusat
        onTap: () {
          // OPTIMIZARE: Folosește mecanismul debounced pentru switching
          _handleClientTap(client);
        },
      );
    }
  }

  /// Afiseaza popup-ul pentru salvarea statusului clientului
  void _showClientSavePopup(ClientModel client) {
    showDialog(
      context: context,
      builder: (context) => ClientSavePopup(
        client: client,
        onSaved: () {
          // Refresh UI sau alte actiuni dupa salvare
          setState(() {});
        },
      ),
    );
  }

  /// Construieste o sectiune (Clienti, Reveniri, Recente)
  Widget _buildSection(String title, ClientCategory category, {bool canCollapse = true}) {
    // Determina starea de collapse pentru aceasta sectiune
    bool isCollapsed = false;
    VoidCallback? toggleCallback;
    // Verifica daca categoria are clienti
    List<ClientModel> categoryClients = _clientService.getClientsByCategoryWithoutTemporary(category);
    bool hasClients = categoryClients.isNotEmpty;
    if (canCollapse) {
      switch (category) {
        case ClientCategory.reveniri:
          if (!_reveniriCollapseInitialized) {
            if (!hasClients) _isReveniriCollapsed = true;
            _reveniriCollapseInitialized = true;
          }
          isCollapsed = _isReveniriCollapsed;
          toggleCallback = () => setState(() => _isReveniriCollapsed = !_isReveniriCollapsed);
          break;
        case ClientCategory.recente:
          if (!_recenteCollapseInitialized) {
            if (!hasClients) _isRecenteCollapsed = true;
            _recenteCollapseInitialized = true;
          }
          isCollapsed = _isRecenteCollapsed;
          toggleCallback = () => setState(() => _isRecenteCollapsed = !_isRecenteCollapsed);
          break;
        case ClientCategory.apeluri:
          // Clienti nu se poate collapse
          break;
      }
    }
    final bool isApeluri = category == ClientCategory.apeluri;
    // Padding logic: collapsed = 8 vertical/horizontal, expanded = all 8
    final EdgeInsets sectionPadding = isCollapsed && !isApeluri
        ? const EdgeInsets.symmetric(vertical: 8, horizontal: 8)
        : const EdgeInsets.all(8);
    final EdgeInsets headerPadding = isCollapsed && !isApeluri
        ? const EdgeInsets.symmetric(vertical: 8, horizontal: 16)
        : const EdgeInsets.symmetric(horizontal: 16);
    final double headerHeight = isCollapsed && !isApeluri ? 32.0 : 24.0;
    return Container(
      width: double.infinity,
      padding: sectionPadding,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppTheme.widgetBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        shadows: [AppTheme.widgetShadow],
      ),
      child: isApeluri 
          ? Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header pentru Clienti
                  WidgetHeader2(
                    title: title,
                    altText: 'Editeaza',
                    onAltTextTap: widget.onClientsPopupRequested,
                  ),
                  SizedBox(height: AppTheme.smallGap),
                  // Lista de clienti expandabila pentru Clienti
                  Expanded(child: _buildClientsList(category)),
                ],
              )
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header pentru Reveniri si Recente
                WidgetHeader3(
                  title: title,
                  trailingIcon: isCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                  onTrailingIconTap: toggleCallback,
                  padding: headerPadding,
                  titleContainerHeight: headerHeight,
                ),
                if (!isCollapsed) ...[
                  SizedBox(height: AppTheme.smallGap),
                  // Lista de clienti pentru Reveniri si Recente
                  _buildClientsList(category),
                ],
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Log focus state during build
    _clientService.logFocusState('CLIENTS_BUILD');
    
    // FIX: Ensure focus consistency when pane is shown
    _ensureFocusStateConsistency();
    
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sectiunea Clienti - FILL (expandeaza sa ocupe tot spatiul disponibil)
          Expanded(
            child: _buildSection('Clienti', ClientCategory.apeluri, canCollapse: false),
          ),
          
          SizedBox(height: AppTheme.mediumGap),
          
          // Sectiunea Reveniri - HUG (doar cat ii trebuie)
          _buildSection('Reveniri', ClientCategory.reveniri),
          
          SizedBox(height: AppTheme.mediumGap),
          
          // Sectiunea Recente - HUG (doar cat ii trebuie)
          _buildSection('Recente', ClientCategory.recente),
        ],
      ),
    );
  }

  /// Initializeaza clientii async
  Future<void> _initializeClients() async {
    if (_clientService.clients.isEmpty) {
      await _clientService.initializeDemoData();
    }
  }

  /// FIX: Ensure clients pane reflects current focus state
  void _ensureFocusStateConsistency() {
    final currentFocusedClient = _clientService.focusedClient;
    
    
    if (currentFocusedClient != null) {
      // Validate that the focused client is properly set in the list
      final focusedInList = _clientService.clients.any((client) => 
          client.phoneNumber == currentFocusedClient.phoneNumber && 
          client.status == ClientStatus.focused);
      
      if (!focusedInList) {

        _clientService.fixFocusStateInconsistencies();
      }
    }
    
    
  }
}
