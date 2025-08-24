import 'package:mat_finance/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:mat_finance/backend/services/sidebar_service.dart';
import 'package:mat_finance/frontend/popups/consultant_popup.dart';
// removed unused header/button imports after sidebar redesign
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mat_finance/frontend/areas/dashboard_area.dart';
import 'package:mat_finance/frontend/areas/form_area.dart';
import 'package:mat_finance/frontend/areas/calendar_area.dart';
import 'package:mat_finance/frontend/areas/settings_area.dart';
import 'package:mat_finance/frontend/panes/calculator_pane.dart';
import 'package:mat_finance/frontend/panes/clients_pane.dart';
import 'package:mat_finance/frontend/panes/matcher_pane.dart';
import 'package:mat_finance/frontend/popups/clients_popup.dart';
import 'package:mat_finance/backend/services/clients_service.dart';
import 'package:mat_finance/backend/services/splash_service.dart';
import 'package:mat_finance/backend/services/update_service.dart';
import 'package:mat_finance/backend/services/app_logger.dart';
import 'package:mat_finance/frontend/components/update_notification.dart';
import 'package:mat_finance/frontend/components/dialog_utils.dart';
import 'package:mat_finance/frontend/components/dialog_overlay_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import removed
import 'package:google_fonts/google_fonts.dart';
import 'package:mat_finance/frontend/screens/mobile_clients_screen.dart';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
// window_manager no longer used here; handlers moved to main.dart
import 'dart:ui';
// import 'package:flutter/scheduler.dart'; // Removed as no longer needed
import 'dart:async';

/// Ecranul principal al aplicatiei care contine cele 3 coloane:
/// - pane (stanga, latime 312)
/// - area (centru, latime flexibila)
/// - sidebar (dreapta, latime 224)
class MainScreen extends StatefulWidget {
  final String? consultantName;
  final String? teamName;
  
  const MainScreen({
    super.key, 
    this.consultantName,
    this.teamName,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  // Starea actuala de navigare
  AreaType _currentArea = AreaType.dashboard;
  PaneType _currentPane = PaneType.clients;
  
  // Keys for SharedPreferences
  static const String _currentAreaKey = 'main_screen_current_area';
  static const String _currentPaneKey = 'main_screen_current_pane';
  
  // Consultant info
  late String _consultantName;
  late String _teamName;
  
  // GlobalKeys pentru componente
  final GlobalKey<CalendarAreaState> _calendarKey = GlobalKey<CalendarAreaState>();
  final GlobalKey<MatcherPaneState> _matcherPaneKey = GlobalKey<MatcherPaneState>();
  
  // Splash service pentru servicii pre-incarcate
  final SplashService _splashService = SplashService();
  
  // Client service pentru gestionarea popup-urilor (foloseste cache-ul din splash)
  late final ClientUIService _clientService;
  

  
  // Update service pentru notificari de update-uri
  final UpdateService _updateService = UpdateService();
  
  // Sidebar service pentru navigare
  late final SidebarService _sidebarService;
  
  // UI state pentru sidebar - removed collapsible sections in new design
  
  // Performance monitoring
  int _buildCount = 0;
  bool _whatsNewChecked = false;
  

  
  // State pentru popup-uri
  List<Client> _popupClients = [];
  Client? _selectedPopupClient;
  bool _isShowingClientListPopup = false;
  
  // Transition profiling state - removed as no longer needed

  // Transition profiling methods removed as no longer needed
  
  @override
  void initState() {
    super.initState();

    PerformanceMonitor.startTimer('mainScreenInit');
    AppLogger.uiState('main_screen', 'init_state');
    
    _consultantName = widget.consultantName ?? 'Consultant';
    _teamName = widget.teamName ?? 'Echipa';
    
    // Foloseste serviciile pre-incarcate din splash
    // Verifica daca serviciile sunt disponibile
    if (_splashService.areServicesReady) {
      _clientService = _splashService.clientUIService;
    } else {
      // Initialize service directly if splash service isn't ready yet
      _clientService = ClientUIService();
    }
    
    // FIX: Reseteaza cache-ul pentru consultant curent la inceput
    _initializeForCurrentConsultant();
    
    // Initializeaza sidebar service
    _sidebarService = SidebarService(
      onAreaChanged: _handleAreaChanged,
      onPaneChanged: _handlePaneChanged,
      initialArea: _currentArea,
      initialPane: _currentPane,
    );
    
    // Restore navigation state from SharedPreferences
    _restoreNavigationState();
    
    // Sincronizeaza popup-ul cu datele din service
    _syncPopupWithService();
    
    // Asculta schimbarile din ClientService
    _clientService.addListener(_onClientServiceChanged);
    

    
    // Asculta schimbarile de brightness pentru modul auto
    WidgetsBinding.instance.addObserver(this);
    
    PerformanceMonitor.endTimer('mainScreenInit');

    // Check and show What's New after first frame to ensure UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLogger.uiState('main_screen', 'post_frame_callback');
      _checkAndShowWhatsNew();
    });
  }

  /// FIX: Initializeaza aplicatia pentru consultantul curent
  Future<void> _initializeForCurrentConsultant() async {
    try {
      // Reseteaza cache-ul pentru consultant/echipa curenta
      await _splashService.resetForNewConsultant();
      

    } catch (e) {
      // Error initializing for current consultant
    }
  }
  
  @override
  void dispose() {
    _clientService.removeListener(_onClientServiceChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkAndShowWhatsNew() async {
    if (_whatsNewChecked || !mounted) return;
    _whatsNewChecked = true;
    try {
      if (Platform.isWindows) {
        AppLogger.uiState('main_screen', 'whats_new_check_start');
        final service = UpdateService();
        final info = await service.readPersistedReleaseInfo(clearAfterRead: false);
        AppLogger.uiState('main_screen', 'whats_new_info_result', {
          'is_null': info == null,
        });
        if (info == null) {
          AppLogger.uiState('main_screen', 'whats_new_missing');
          return;
        }
        final version = (info['version'] ?? '').toString();
        final desc = (info['description'] ?? '').toString();
        // Compare with current running app version to ensure update actually applied
        String currentVersion = 'unknown';
        try {
          final pkg = await PackageInfo.fromPlatform();
          currentVersion = pkg.version;
        } catch (e) {
          AppLogger.error('main_screen', 'package_info_exception', e);
        }
        if (currentVersion != version) {
          AppLogger.uiState('main_screen', 'whats_new_version_mismatch', {
            'persisted': version,
            'current': currentVersion,
          });
          return;
        }
        AppLogger.uiState('main_screen', 'whats_new_found', {
          'version': version,
          'desc_len': desc.length,
        });
        if (version.isEmpty) {
          AppLogger.uiState('main_screen', 'whats_new_empty_version');
        }
        if (!mounted) {
          AppLogger.uiState('main_screen', 'not_mounted_abort');
          return;
        }
        if (!mounted) return;
        await showBlurredDialog(
          context: context,
          barrierDismissible: true,
          builder: (ctx) => _buildWhatsNewDialog(version, desc),
        );
        // After the dialog is shown, clear the persisted info
        try {
          await UpdateService().clearPersistedReleaseInfo();
        } catch (e) {
          AppLogger.error('main_screen', 'clear_release_info_exception', e);
        }
        AppLogger.uiState('main_screen', 'whats_new_shown');
      }
    } catch (e) {
      AppLogger.error('main_screen', 'whats_new_exception', e);
    }
  }

  Widget _buildWhatsNewDialog(String version, String description) {
    return AlertDialog(
                          backgroundColor: AppTheme.backgroundColor1,
      title: Text(
        'Ce este nou in $version',
        style: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppTheme.elementColor2,
        ),
      ),
      content: SingleChildScrollView(
        child: Text(
          description.isNotEmpty
              ? description
              : '• Imbunatatiri de performanta\n• Corectari de bug-uri',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppTheme.elementColor1,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'OK',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.elementColor2,
            ),
          ),
        ),
      ],
    );
  }
  
  
  void _onClientServiceChanged() {
    // Defer setState until after the current frame to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _syncPopupWithService();
        });
        
        // If popup is open, refresh it to show temporary client
        if (_isShowingClientListPopup) {
          _syncPopupWithService();
        }
      }
    });
  }
  
  /// Sincronizeaza datele popup-ului cu cele din ClientService
  void _syncPopupWithService() {
    // Include regular clients
    _popupClients = _clientService.clients.map((clientModel) {
      return Client(
        name: clientModel.name,
        phoneNumber1: clientModel.phoneNumber1,
        phoneNumber2: clientModel.phoneNumber2,
        coDebitorName: clientModel.coDebitorName,
      );
    }).toList();
    
    // Include temporary client if it exists
    if (_clientService.temporaryClient != null) {
      final tempClient = _clientService.temporaryClient!;
      final tempClientForPopup = Client(
        name: tempClient.name,
        phoneNumber1: tempClient.phoneNumber1,
        phoneNumber2: tempClient.phoneNumber2,
        coDebitorName: tempClient.coDebitorName,
      );
      _popupClients.add(tempClientForPopup);
      
      // Focus the temporary client in the popup
      _selectedPopupClient = tempClientForPopup;
    } else {
      // Pastreaza selectia curenta daca exista
      if (_selectedPopupClient != null) {
        _selectedPopupClient = _popupClients.firstWhere(
          (client) => client.name == _selectedPopupClient!.name && 
                     client.phoneNumber1 == _selectedPopupClient!.phoneNumber1,
          orElse: () => _popupClients.isNotEmpty ? _popupClients.first : _selectedPopupClient!,
        );
      }
    }
  }
  

  
  /// Restores navigation state from SharedPreferences
  Future<void> _restoreNavigationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paneIndex = prefs.getInt(_currentPaneKey);
      
      // Not reading areaIndex anymore; area always defaults to dashboard
      _currentArea = AreaType.dashboard;
      _sidebarService.syncArea(_currentArea);
  
      
      if (paneIndex != null && paneIndex < PaneType.values.length) {
        _currentPane = PaneType.values[paneIndex];
        // Update SidebarService state to keep it in sync
        _sidebarService.syncPane(_currentPane);
    
      } else {
        // Nu exista preferinte salvate - folosim default-ul (clients)  
        _currentPane = PaneType.clients;
        _sidebarService.syncPane(_currentPane);
    
      }
      
      // Update UI if needed
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {});
          }
        });
      }
    } catch (e) {
      // Error restoring navigation state
      // In caz de eroare, folosim default-urile
      _currentArea = AreaType.dashboard;
      _currentPane = PaneType.clients;
      _sidebarService.syncArea(_currentArea);
      _sidebarService.syncPane(_currentPane);
  
    }
  }
  
  /// Saves navigation state to SharedPreferences
  Future<void> _saveNavigationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_currentAreaKey, _currentArea.index);
      await prefs.setInt(_currentPaneKey, _currentPane.index);
    } catch (e) {
      // Error saving navigation state
    }
  }
  
  // Widgets pentru area
  Map<AreaType, Widget> get _areaWidgets => {
    AreaType.dashboard: DashboardArea(),
    AreaType.form: FormArea(
      onNavigateToClients: () {
        _sidebarService.changePane(PaneType.clients);
      },
      isClientsPaneVisible: _currentPane == PaneType.clients,
    ),
    AreaType.calendar: CalendarArea(
      key: _calendarKey,
      onMeetingSaved: _refreshMeetingsPane,
    ),
    AreaType.settings: SettingsArea(),
  };
  
  Map<PaneType, Widget> get _paneWidgets => {
    PaneType.clients: ClientsPane(
      onClientsPopupRequested: _handleClientsPopupRequested,
      onSwitchToFormArea: _handleSwitchToFormArea,
    ),
    PaneType.calculator: CalculatorPane(),
    PaneType.matches: MatcherPane(
      key: _matcherPaneKey,
    ),
  };
  
  // Removed: _navigateToMeeting (meetings list embedded in calendar)
  
  /// Refreshes meetings pane when meetings are saved
  void _refreshMeetingsPane() {
    _calendarKey.currentState?.refreshCalendar();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.logWithDedup('main_screen', 'build_called');
    // Detect platform and show mobile screen for Android/iOS
    if (Platform.isAndroid || Platform.isIOS) {
      return const MobileClientsScreen();
    }
    
    // Periodically verify state consistency during builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _forceSyncStates();
      }
    });
    
    // Print performance report every 10 builds for monitoring
    _buildCount++;
    if (_buildCount % 10 == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PerformanceMonitor.printPerformanceReport();
      });
    }
    
    return UpdateNotificationWrapper(
      updateService: _updateService,
      child: Scaffold(
      body: Stack(
          children: [
            // Custom titlebar is now injected globally in MaterialApp.builder (main.dart)
            // Main content
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.smallGap, 0, AppTheme.mediumGap, AppTheme.mediumGap),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sidebar (stanga)
                  _buildSidebar(),
                  // Spatiu intre sidebar si containerul combinat
                  const SizedBox(width: AppTheme.smallGap),
                  // Area (stanga) + Pane (dreapta)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Area (stanga) + Pane (dreapta) pentru dashboard, settings si calendar
                        if (_currentArea == AreaType.dashboard || _currentArea == AreaType.settings || _currentArea == AreaType.calendar)
                          Expanded(child: RepaintBoundary(child: _areaWidgets[_currentArea]!)),
                        // Row pentru area + pane pentru celelalte tipuri
                        if (_currentArea != AreaType.dashboard && _currentArea != AreaType.settings && _currentArea != AreaType.calendar)
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Area (stanga)
                                Expanded(child: RepaintBoundary(child: _areaWidgets[_currentArea]!)),
                                // Gap 8 intre area si pane
                                const SizedBox(width: AppTheme.smallGap),
                                // Pane (dreapta)
                                SizedBox(
                                  width: 296,
                                  child: RepaintBoundary(child: _paneWidgets[_currentPane]!),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Client Popups overlay
            if (_isShowingClientListPopup)
              _buildDualPopupOverlay(),
          ],
        ),
      ),
    );
  }
  
  // Titlebar handlers and buttons moved to global builder in main.dart
  
  


  /// Builds dual popup overlay with both popups side by side
  Widget _buildDualPopupOverlay() {
    return GestureDetector(
      onTap: _closeAllPopups, // Inchide popup-ul la click pe background
      child: Stack(
        children: [
          // Blur + dim uniform sub popup (consistent cu showBlurredDialog)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withValues(alpha: 0.1)),
            ),
          ),
          // Continutul popup-ului
          Positioned.fill(
            child: Center(
              child: GestureDetector(
                onTap: () {}, // Previne inchiderea cand se face click pe popup
                behavior: HitTestBehavior.opaque,
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Client List Popup (intotdeauna vizibil cand e deschis)
                      if (_isShowingClientListPopup)
                        ClientsPopup(
                          clients: _popupClients,
                          selectedClient: _selectedPopupClient,
                          onClientSelected: _handleClientSelected,
                          onEditClient: _handleEditClient,
                          onSaveClient: _handleSaveClient,
                          onDeleteClient: (client) => _handleDeleteClient(client),
                          onDeleteOcrClients: _handleDeleteOcrClients,
                        ),
                      
                      // Form-ul de editare e acum integrat in ClientsPopup
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _handleAreaChanged(AreaType area) {
    // Area change
    
    // FIX: Track focus persistence before area change
    _trackFocusPersistence('BEFORE_AREA_CHANGE');
    
    // FIX: Preserve focus state before area change
    _clientService.preserveFocusState();
    
    setState(() {
      _currentArea = area;
    });
    // Save navigation state
    _saveNavigationState();
    
    // FIX: Restore focus state after area change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clientService.restoreFocusState();
      _trackFocusPersistence('AFTER_AREA_CHANGE');
      _forceSyncStates();
    });
  }
  
  void _handlePaneChanged(PaneType pane) {
    // Pane change
    
    // FIX: Track focus persistence before pane change
    _trackFocusPersistence('BEFORE_PANE_CHANGE');
    
    // FIX: Preserve focus state before pane change
    _clientService.preserveFocusState();
    
    setState(() {
      _currentPane = pane;
    });
    
    // Save navigation state
    _saveNavigationState();
    

    
    // Refresh matcher data when switching to matches pane
    if (pane == PaneType.matches) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _matcherPaneKey.currentState?.refreshData();
      });
    }
    
    // FIX: Restore focus state after pane change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clientService.restoreFocusState();
      _trackFocusPersistence('AFTER_PANE_CHANGE');
      _forceSyncStates();
    });
  }
  
  /// Handles the clients popup request from sidebar
  void _handleClientsPopupRequested() {
    setState(() {
      _syncPopupWithService();
      _isShowingClientListPopup = true;
      // Nu selecta niciun client implicit la deschiderea popup-ului
      _selectedPopupClient = null;
    });
    DialogOverlayController.instance.push();
  }

  /// Handles switching to form area when a client is selected
  void _handleSwitchToFormArea() {

    // Use the SidebarService to change area to keep states in sync
    _sidebarService.changeArea(AreaType.form);
  }


  
  /// Closes all popups
  void _closeAllPopups() {
    setState(() {
      _isShowingClientListPopup = false;
    });
    DialogOverlayController.instance.pop();
  }
  
  /// Handles client selection in the popup
  void _handleClientSelected(Client client) {
    setState(() {
      _selectedPopupClient = client;
    });
    
    // Nu mai focusam clientul in ClientService pentru a nu afecta clientsPane
    // Focus-ul din clientsPane ramane independent de selectia din popup
  }
  
  /// Handles edit client (double-tap on client) - now handled internally by ClientsPopup
  void _handleEditClient(Client client) {
    // The new ClientsPopup handles this internally
    // Just focus the selected client
    setState(() {
      _selectedPopupClient = client;
    });
  }
  


  /// Handles delete OCR image completely (removes item from gallery)
  void _handleDeleteOcrClients() {
    // Aceasta metoda este apelata cand se sterge complet imaginea OCR selectata
    // Logica efectiva de stergere se face in ClientsPopup prin _deleteOcrClientsFromSelectedImage()
    // Aici putem adauga logging sau alte actiuni suplimentare daca e necesar
    // OCR image completely removed from gallery
  }
  
  /// Handles saving a client (create or edit)
  void _handleSaveClient(Client client) async {
    // Check if this is a temporary client being finalized
    final clientService = SplashService().clientUIService;
    if (clientService.temporaryClient != null) {
      // This is a temporary client being finalized - let the service handle it
      final success = await clientService.finalizeTemporaryClient();
      if (success) {
        // Don't close the popup - let user continue working
        // _closeAllPopups(); // Removed automatic popup closing
        
        // silent
      }
      return;
    }
    
    // Try to find existing client by phone number
    final existingClientModel = _clientService.clients.where(
      (clientModel) => clientModel.phoneNumber1 == client.phoneNumber1,
    ).firstOrNull;

    if (existingClientModel != null) {
      // Update existing client
      final updatedClientModel = existingClientModel.copyWith(
        name: client.name,
        phoneNumber1: client.phoneNumber1,
        phoneNumber2: client.phoneNumber2,
        coDebitorName: client.coDebitorName,
      );
      
      await _clientService.updateClient(updatedClientModel);
    } else {
      // Create new client
      final newClientModel = ClientModel(
        id: client.phoneNumber1, // Use phoneNumber1 as ID
        name: client.name,
        phoneNumber1: client.phoneNumber1,
        phoneNumber2: client.phoneNumber2,
        coDebitorName: client.coDebitorName,
        status: ClientStatus.normal,
        category: ClientCategory.apeluri, // New clients go to "Clienti"
        formData: {}, // <-- required argument
      );
      
      await _clientService.addClient(newClientModel);
    }
    
    // Don't close the popup automatically
    // _closeAllPopups(); // Removed automatic popup closing
  }
  
  /// Handles deleting a client
  void _handleDeleteClient(Client? client) async {
    if (client == null) {
      // silent
      return;
    }
    // Check if this is a temporary client being cancelled
    final clientService = SplashService().clientUIService;
    if (clientService.temporaryClient != null) {
      // This is a temporary client being cancelled
      clientService.cancelTemporaryClient();
      // Close the popup after cancellation
      _closeAllPopups();
      return;
    }
    // Find the client in the list
    final clientModel = _clientService.clients.firstWhere(
      (clientModel) => clientModel.phoneNumber1 == client.phoneNumber1,
    );
    // Delete the client using phoneNumber1 as ID
    await _clientService.removeClient(clientModel.phoneNumber1);
    // Update selection after deletion
    setState(() {
      _selectedPopupClient = null;
    });
    // Popup-ul ramane deschis pentru a permite stergerea mai multor clienti
    // _closeAllPopups(); // Removed automatic popup closing
  }

  // =================== SIDEBAR METHODS ===================

  /// Builds the main sidebar widget
  Widget _buildSidebar() {
    final areaButtons = _sidebarService.areaButtons;
    final paneButtons = _sidebarService.paneButtons;

    // Configuratie layout: latime fixa 48, inaltime fill, padding vertical 8
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: AppTheme.smallGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // NAVIGATION (top)
          // Areas: home, calendar, form (ordine noua)
          _buildIconOnlyButton(
            iconPath: areaButtons[0].iconPath,
            isActive: _sidebarService.currentArea == areaButtons[0].targetArea,
            onTap: () => _sidebarService.handleButtonClick(areaButtons[0]),
          ),
          const SizedBox(height: AppTheme.smallGap),
          _buildIconOnlyButton(
            iconPath: areaButtons[2].iconPath,
            isActive: _sidebarService.currentArea == areaButtons[2].targetArea,
            onTap: () => _sidebarService.handleButtonClick(areaButtons[2]),
        ),
        const SizedBox(height: AppTheme.smallGap),
          _buildIconOnlyButton(
            iconPath: areaButtons[1].iconPath,
            isActive: _sidebarService.currentArea == areaButtons[1].targetArea,
            onTap: () => _sidebarService.handleButtonClick(areaButtons[1]),
          ),

          // Separator intre areas si panes (8px gap deasupra si dedesubt)
          if (_currentArea != AreaType.dashboard && _currentArea != AreaType.settings && _currentArea != AreaType.calendar) ...[
            const SizedBox(height: AppTheme.smallGap),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFB5BFC9),
                borderRadius: BorderRadius.circular(2),
              ),
        ),
        const SizedBox(height: AppTheme.smallGap),
          ],

          // Panes: clients, calculator, recommendation (ascunse pe home, settings si calendar)
          if (_currentArea != AreaType.dashboard && _currentArea != AreaType.settings && _currentArea != AreaType.calendar) ...[
            // Iterate panes but skip meetings to remove it from sidebar
            for (int i = 0; i < paneButtons.length; i++) ...[
              if (paneButtons[i].id != 'meetings') ...[
                _buildIconOnlyButton(
                  iconPath: paneButtons[i].iconPath,
                  isActive: _sidebarService.currentPane == paneButtons[i].targetPane,
                  onTap: () => _sidebarService.handleButtonClick(paneButtons[i]),
        ),
        const SizedBox(height: AppTheme.smallGap),
              ],
            ],
          ],

          // GAP AUTO
          const Spacer(),

          // PROFILE (bottom): settings, consultant
          _buildIconOnlyButton(
            iconPath: 'assets/settings_outlined.svg',
            onTap: () => _sidebarService.handleButtonClick(
              const ButtonConfig(
                id: 'settings',
                title: 'Setari',
                iconPath: 'assets/settings_outlined.svg',
                actionType: ActionType.navigateToArea,
                targetArea: AreaType.settings,
              ),
            ),
            isActive: _sidebarService.currentArea == AreaType.settings,
          ),
          const SizedBox(height: AppTheme.smallGap),
          _buildIconOnlyButton(
            iconPath: 'assets/user_outlined.svg',
            onTap: _showConsultantPopup,
          ),
        ],
      ),
    );
  }

  // Removed _buildConsultantSection (handled inline in sidebar layout)

  /// Icon-only square button used in the new sidebar
  Widget _buildIconOnlyButton({
    required String iconPath,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        
        // Get solid icon path by replacing _outlined with _solid
        String getSolidIconPath(String outlinedPath) {
          if (outlinedPath.contains('_outlined.svg')) {
            // List of icons that have solid versions available
            final List<String> availableSolidIcons = [
              'home', 'calendar', 'form', 'clients', 'calculator', 'settings'
            ];
            
            // Check if this icon has a solid version
            for (String iconName in availableSolidIcons) {
              if (outlinedPath.contains('${iconName}_outlined.svg')) {
                return outlinedPath.replaceAll('${iconName}_outlined.svg', '${iconName}_solid.svg');
              }
            }
          }
          // Return original path if no solid version exists
          return outlinedPath;
        }
        
        // Determine background color: transparent by default, backgroundColor2 when focused/hovered
        final Color background = isActive || isHovered ? AppTheme.backgroundColor2 : Colors.transparent;
        
        // Determine icon color: elementColor1 by default, elementColor2 when focused/hovered
        final Color iconColor = isActive || isHovered ? AppTheme.elementColor2 : AppTheme.elementColor1;
        
        // Determine icon path: solid when hovered OR active, outlined otherwise
        final String currentIconPath = (isHovered || isActive) ? getSolidIconPath(iconPath) : iconPath;

        return SizedBox(
          width: 48,
          height: 48,
          child: Material(
            color: Colors.transparent,
            child: MouseRegion(
              onEnter: (_) => setState(() => isHovered = true),
              onExit: (_) => setState(() => isHovered = false),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                child: Container(
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    boxShadow: (isActive || isHovered) ? AppTheme.standardShadow : null,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      currentIconPath,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }



  // Removed legacy sidebar sections and headers for icon-only design

  // Removed legacy text/button helpers (special buttons, area/pane buttons, navigation button)

  /// Shows the consultant details popup
  void _showConsultantPopup() {
    if (!mounted) return;
    
    showBlurredDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ConsultantPopup(
        consultantName: _consultantName,
        teamName: _teamName,
      ),
    );
  }

  /// Forces complete state synchronization between MainScreen and SidebarService with debouncing
  void _forceSyncStates() {
    // If states are out of sync, update MainScreen to match SidebarService (single source of truth)
    bool needsUpdate = false;
    if (_currentArea != _sidebarService.currentArea) {
      _currentArea = _sidebarService.currentArea;
      needsUpdate = true;
    }
    
    if (_currentPane != _sidebarService.currentPane) {
      _currentPane = _sidebarService.currentPane ?? PaneType.clients;
      needsUpdate = true;
    }
    

    
    if (needsUpdate && mounted) {
      setState(() {});
    }
  }

  /// FIX: Track focus persistence during area transitions
  void _trackFocusPersistence(String transitionType) {
    // Validate focus state consistency
    if (!_clientService.validateFocusState()) {
      _clientService.fixFocusStateInconsistencies();
    }
  }

}

/// Widget simplu pentru placeholder
class PlaceholderWidget extends StatelessWidget {
  final String text;
  final Color color;
  
  const PlaceholderWidget(this.text, this.color, {super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: Center(
        child: Text(
          text,
          style: AppTheme.headerTitleStyle,
        ),
      ),
    );
  }
}

