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

import 'package:mat_finance/frontend/panes/matcher_pane.dart';
import 'package:mat_finance/frontend/areas/clients_area.dart';
import 'package:mat_finance/backend/services/clients_service.dart';
import 'package:mat_finance/backend/services/splash_service.dart';
import 'package:mat_finance/backend/services/update_service.dart';
import 'package:mat_finance/backend/services/app_logger.dart';
import 'package:mat_finance/backend/services/consultant_service.dart';
import 'package:mat_finance/frontend/components/update_notification.dart';
import 'package:mat_finance/frontend/components/dialog_utils.dart';

import 'package:shared_preferences/shared_preferences.dart';
// import removed
import 'package:google_fonts/google_fonts.dart';
import 'package:mat_finance/frontend/screens/mobile_clients_screen.dart';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
// window_manager no longer used here; handlers moved to main.dart
// import 'package:flutter/scheduler.dart'; // Removed as no longer needed
import 'dart:async';
import 'package:mat_finance/main.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  late final ConsultantService _consultantService;
  int? _consultantColorIndex;
  
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
  

  
  // State pentru popup-uri - removed, integrated into ClientsArea
  
  // Transition profiling state - removed as no longer needed

  // Transition profiling methods removed as no longer needed
  
  @override
  void initState() {
    super.initState();

    PerformanceMonitor.startTimer('mainScreenInit');
    AppLogger.uiState('main_screen', 'init_state');
    
    _consultantName = widget.consultantName ?? 'Consultant';
    _teamName = widget.teamName ?? 'Echipa';
    _consultantService = ConsultantService();

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

    // Incarca culoarea consultantului
    _loadConsultantColor();

    // Initializeaza sidebar service
    _sidebarService = SidebarService(
      onAreaChanged: _handleAreaChanged,
      onPaneChanged: _handlePaneChanged,
      initialArea: _currentArea,
      initialPane: _currentPane,
    );
    
    // Restore navigation state from SharedPreferences
    _restoreNavigationState();
    
    // Asculta schimbarile din ClientService
    _clientService.addListener(_onClientServiceChanged);
    
    // Asculta schimbarile de culori ale consultantilor
    _consultantService.addListener(_onConsultantColorsChanged);
    
    // FIX: Asculta schimbarile de autentificare pentru a reseta culoarea
    _listenToAuthChanges();

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
      // FIX: Reseteaza culoarea inainte de a reseta cache-ul
      if (mounted) {
        setState(() {
          _consultantColorIndex = null;
        });
      }
      
      // Reseteaza cache-ul pentru consultant/echipa curenta
      await _splashService.resetForNewConsultant();

      // FIX: Incarca culoarea dupa resetarea cache-ului
      await _loadConsultantColor();

    } catch (e) {
      debugPrint('❌ MAIN_SCREEN: Error initializing for current consultant: $e');
    }
  }

  /// Incarca culoarea consultantului curent
  Future<void> _loadConsultantColor() async {
    try {
      // FIX: Reseteaza culoarea inainte de a incarca una noua
      if (mounted) {
        setState(() {
          _consultantColorIndex = null;
        });
      }
      
      final colorIndex = await _consultantService.getCurrentConsultantColor();
      if (mounted) {
        setState(() {
          _consultantColorIndex = colorIndex;
        });
        debugPrint('🎨 MAIN_SCREEN: Loaded consultant color: $colorIndex');
      }
    } catch (e) {
      debugPrint('❌ MAIN_SCREEN: Error loading consultant color: $e');
    }
  }

  /// Callback pentru schimbarile de culori ale consultantilor
  void _onConsultantColorsChanged() {
    if (!mounted) return;
    
    debugPrint('🎨 MAIN_SCREEN: Consultant colors changed, updating color');
    
    // FIX: Reseteaza culoarea inainte de a o actualiza
    setState(() {
      _consultantColorIndex = null;
    });
    
    // Actualizeaza culoarea consultantului curent
    _loadConsultantColor();
  }
  
  @override
  void dispose() {
    _clientService.removeListener(_onClientServiceChanged);
    _consultantService.removeListener(_onConsultantColorsChanged);
    _authSubscription?.cancel(); // FIX: Opreste listener-ul de autentificare
    _authDebounceTimer?.cancel(); // FIX: Opreste timer-ul de debouncing
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
          // ClientsArea handles its own state updates
        });
      }
    });
  }
  

  

  
  /// Restores navigation state from SharedPreferences
  Future<void> _restoreNavigationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paneIndex = prefs.getInt(_currentPaneKey);

      // Not reading areaIndex anymore; area always defaults to dashboard
      _currentArea = AreaType.dashboard;
      _sidebarService.syncArea(_currentArea);

      // Update global state for titlebar
      GlobalState.currentAreaNotifier.value = _currentArea;

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

      // Update global state for titlebar
      GlobalState.currentAreaNotifier.value = _currentArea;
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
    PaneType.clients: ClientsArea(
      onAddClient: _handleClientsPopupRequested,
      onEditClient: _handleEditClient,
      onSaveClient: _handleSaveClient,
      onDeleteClient: _handleDeleteClient,
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
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
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
                        // Special case: ClientsArea replaces FormArea completely when clients pane is selected
                        if (_currentArea == AreaType.form && _currentPane == PaneType.clients)
                          Expanded(child: RepaintBoundary(child: _paneWidgets[PaneType.clients]!)),
                        // Row pentru area + pane pentru celelalte tipuri (except clients pane)
                        if (_currentArea != AreaType.dashboard && _currentArea != AreaType.settings && _currentArea != AreaType.calendar && !(_currentArea == AreaType.form && _currentPane == PaneType.clients))
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
            
            // Client Popups overlay - removed, integrated into ClientsArea
          ],
        ),
      ),
    );
  }
  
  // Titlebar handlers and buttons moved to global builder in main.dart
  
  



  
  void _handleAreaChanged(AreaType area) {
    // Area change

    // FIX: Track focus persistence before area change
    _trackFocusPersistence('BEFORE_AREA_CHANGE');

    // FIX: Preserve focus state before area change
    _clientService.preserveFocusState();

    setState(() {
      _currentArea = area;
    });

    // Update global state for titlebar
    GlobalState.currentAreaNotifier.value = area;

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
  
  /// Handles the clients popup request from sidebar - now used for add client in ClientsArea
  void _handleClientsPopupRequested() {
    // ClientsArea handles the add client functionality internally
    // This callback is now used to trigger add client mode in ClientsArea
  }




  

  
  /// Handles edit client - now handled internally by ClientsArea
  void _handleEditClient(Client client) {
    // ClientsArea handles this internally
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
        // ClientsArea handles popup closing internally
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
      // Close the popup after cancellation - handled by ClientsArea
      return;
    }
    // Find the client in the list
    final clientModel = _clientService.clients.firstWhere(
      (clientModel) => clientModel.phoneNumber1 == client.phoneNumber1,
    );
    // Delete the client using phoneNumber1 as ID
    await _clientService.removeClient(clientModel.phoneNumber1);
    // Update selection after deletion - handled by ClientsArea
    // ClientsArea remains open for multiple deletions
  }

  // =================== SIDEBAR METHODS ===================

  /// Builds the main sidebar widget
  Widget _buildSidebar() {
    final areaButtons = _sidebarService.areaButtons;
    final paneButtons = _sidebarService.paneButtons;

    // Configuratie layout: latime fixa 40, inaltime fill, padding vertical 8
    return Container(
      width: 40,
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
          _buildConsultantButton(),
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
          width: 40,
          height: 40,
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

  /// Obtine culoarea pentru butonul consultantului
  Color _getConsultantButtonColor() {
    if (_consultantColorIndex != null && _consultantColorIndex! >= 1 && _consultantColorIndex! <= 10) {
      return AppTheme.getPrimaryColor(_consultantColorIndex!);
    }
    return AppTheme.backgroundColor2; // Fallback la culoarea implicita
  }

  /// Obtine culoarea pentru border-ul butonului consultantului
  Color _getConsultantButtonBorderColor() {
    if (_consultantColorIndex != null && _consultantColorIndex! >= 1 && _consultantColorIndex! <= 10) {
      return AppTheme.getSecondaryColor(_consultantColorIndex!);
    }
    return AppTheme.backgroundColor3; // Fallback la culoarea implicita
  }

  /// Builds the consultant button with initials
  Widget _buildConsultantButton() {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showConsultantPopup,
          borderRadius: BorderRadius.circular(16.0), // 16px border radius
          child: Container(
            decoration: BoxDecoration(
              color: _getConsultantButtonColor(), // Culoarea consultantului sau fallback
              borderRadius: BorderRadius.circular(16.0), // 16px border radius
              border: Border.all(
                color: _getConsultantButtonBorderColor(), // strokeColor al consultantului
                width: 4.0, // 4px border width
              ),
            ),
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, 1),
                child: Text(
                  _getConsultantInitial(),
                  style: GoogleFonts.notoSansThai(
                    fontSize: 19.0, // 19px font size
                    fontWeight: FontWeight.bold, // Bold weight
                    color: AppTheme.elementColor3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Get the first initial of the consultant name
  String _getConsultantInitial() {
    if (_consultantName.isEmpty || _consultantName == 'Consultant') {
      return 'C'; // Default initial
    }
    return _consultantName[0].toUpperCase();
  }

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

  /// FIX: Asculta schimbarile de autentificare pentru a reseta culoarea
  StreamSubscription<User?>? _authSubscription;

  // FIX: Debouncing pentru schimbarile de autentificare
  Timer? _authDebounceTimer;
  User? _lastUserState;

  /// FIX: Asculta schimbarile de autentificare pentru a reseta culoarea cu debouncing inteligent
  void _listenToAuthChanges() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        debugPrint('🔐 MAIN_SCREEN: Auth state changed, user: ${user?.uid ?? 'null'}');

        // FIX: Implementeaza debouncing mai inteligent
        // Anuleaza timer-ul anterior pentru a reseta debouncing-ul
        _authDebounceTimer?.cancel();

        // FIX: Implementeaza debouncing - asteapta 1000ms de stabilitate
        _authDebounceTimer = Timer(const Duration(milliseconds: 1000), () {
          if (mounted) {
            // FIX: Verifica daca starea s-a schimbat efectiv, inclusiv pentru null
            bool hasStateChanged = false;

            if (_lastUserState == null && user != null) {
              // null → user: schimbare reala
              hasStateChanged = true;
            } else if (_lastUserState != null && user == null) {
              // user → null: schimbare reala
              hasStateChanged = true;
            } else if (_lastUserState != null && user != null && _lastUserState!.uid != user.uid) {
              // user → alt user: schimbare reala
              hasStateChanged = true;
            }
            // null → null sau user → același user: nu se consideră schimbare

            if (hasStateChanged) {
              _lastUserState = user;
              debugPrint('🔐 MAIN_SCREEN: Auth state stable, reloading consultant color');
              // Reseteaza culoarea consultantului la schimbarea autentificarii
              _loadConsultantColor();
            } else {
              debugPrint('🔐 MAIN_SCREEN: Auth state unchanged after debounce, skipping reload');
            }
          }
        });
      }
    });
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

