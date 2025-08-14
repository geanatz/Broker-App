import 'package:mat_finance/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:mat_finance/backend/services/sidebar_service.dart';
import 'package:mat_finance/frontend/popups/consultant_popup.dart';
import 'package:mat_finance/frontend/components/headers/widget_header3.dart';
import 'package:mat_finance/frontend/components/buttons/spaced_buttons1.dart';
import 'package:mat_finance/frontend/components/items/light_item7.dart';
import 'package:mat_finance/frontend/areas/dashboard_area.dart';
import 'package:mat_finance/frontend/areas/form_area.dart';
import 'package:mat_finance/frontend/areas/calendar_area.dart';
import 'package:mat_finance/frontend/areas/settings_area.dart';
import 'package:mat_finance/frontend/panes/meetings_pane.dart';
import 'package:mat_finance/frontend/panes/calculator_pane.dart';
import 'package:mat_finance/frontend/panes/clients_pane.dart';
import 'package:mat_finance/frontend/panes/matcher_pane.dart';
import 'package:mat_finance/frontend/popups/clients_popup.dart';
import 'package:mat_finance/backend/services/clients_service.dart';
import 'package:mat_finance/backend/services/splash_service.dart';
import 'package:mat_finance/backend/services/update_service.dart';
import 'package:mat_finance/backend/services/app_logger.dart';
import 'package:mat_finance/frontend/components/update_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import removed
import 'package:google_fonts/google_fonts.dart';
import 'package:mat_finance/frontend/screens/mobile_clients_screen.dart';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';

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
  final GlobalKey<MeetingsPaneState> _meetingsPaneKey = GlobalKey<MeetingsPaneState>();
  final GlobalKey<MatcherPaneState> _matcherPaneKey = GlobalKey<MatcherPaneState>();
  
  // Splash service pentru servicii pre-incarcate
  final SplashService _splashService = SplashService();
  
  // Client service pentru gestionarea popup-urilor (foloseste cache-ul din splash)
  late final ClientUIService _clientService;
  

  
  // Update service pentru notificari de update-uri
  final UpdateService _updateService = UpdateService();
  
  // Sidebar service pentru navigare
  late final SidebarService _sidebarService;
  
  // UI state pentru sidebar - sectiuni colapsabile
  bool _isAreaSectionCollapsed = false;
  bool _isPaneSectionCollapsed = false;
  
  // Performance monitoring
  int _buildCount = 0;
  bool _whatsNewChecked = false;
  

  
  // State pentru popup-uri
  List<Client> _popupClients = [];
  Client? _selectedPopupClient;
  bool _isShowingClientListPopup = false;
  
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
        await showDialog(
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
      backgroundColor: AppTheme.widgetBackground,
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
    PaneType.meetings: MeetingsPane(
      key: _meetingsPaneKey,
      onNavigateToMeeting: _navigateToMeeting,
    ),
    PaneType.calculator: CalculatorPane(),
    PaneType.matches: MatcherPane(
      key: _matcherPaneKey,
    ),
  };
  
  /// Navigates to a specific meeting in the calendar
  void _navigateToMeeting(String meetingId) {
    // Switch to calendar area if not already there
    if (_currentArea != AreaType.calendar) {
      // Use the SidebarService to change area to keep states in sync
      _sidebarService.changeArea(AreaType.calendar);
    }
    
    // Navigate to the meeting in calendar with highlight
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calendarKey.currentState?.navigateToMeeting(meetingId);
    });
  }
  
  /// Refreshes meetings pane when meetings are saved
  void _refreshMeetingsPane() {
    _meetingsPaneKey.currentState?.refreshMeetings();
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
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.appBackground,
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
          padding: const EdgeInsets.all(AppTheme.mediumGap),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Conditionally render pane column only if current area is not dashboard (Acasa)
              ...(_currentArea != AreaType.dashboard ? [
                // Pane Column (stanga) - latime fixa 312
                SizedBox(
                  width: 296,
                  child: _paneWidgets[_currentPane]!,
                ),
                // Spacing
                const SizedBox(width: AppTheme.mediumGap),
              ] : []),
              
              // Area Column (centru) - latime flexibila
              Expanded(
                child: _areaWidgets[_currentArea]!,
              ),
              
              // Spacing intre area si sidebar
              const SizedBox(width: AppTheme.mediumGap),
              
              // Sidebar Column (dreapta) - latime fixa 224
              _buildSidebar(),
            ],
              ),
            ),
            
                         // Client Popups overlay
            if (_isShowingClientListPopup)
              _buildDualPopupOverlay(),
          ],
        ),
        ),
      ),
    );
  }
  
  
  /// Builds dual popup overlay with both popups side by side
  Widget _buildDualPopupOverlay() {
    return GestureDetector(
      onTap: _closeAllPopups, // Inchide popup-ul la click pe background
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Previne inchiderea cand se face click pe popup
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
    
    // Refresh meetings when switching to meetings pane
    if (pane == PaneType.meetings) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _meetingsPaneKey.currentState?.refreshMeetings();
      });
    }
    
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
    return Container(
      width: 224,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: AppTheme.widgetDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Consultant information section
          _buildConsultantSection(),
          const SizedBox(height: AppTheme.mediumGap),
          
          // Areas navigation section
          _buildAreasSection(),
          // Afiseaza sectiunea de pane doar daca area curent nu este Acasa (dashboard)
          if (_currentArea != AreaType.dashboard) ...[
            const SizedBox(height: AppTheme.mediumGap),
            _buildPanesSection(),
          ],
          
          // Special functions section (doar daca exista butoane)
          if (_sidebarService.specialButtons.isNotEmpty) ...[
            const SizedBox(height: AppTheme.mediumGap),
            _buildSpecialSection(),
          ],
        ],
      ),
    );
  }

  /// Builds the consultant information section using LightItem7
  Widget _buildConsultantSection() {
    return LightItem7(
      title: _consultantName,
      description: _teamName,
      svgAsset: 'assets/userIcon.svg',
      onTap: _showConsultantPopup,
    );
  }



  /// Builds the areas navigation section with collapsible header
  Widget _buildAreasSection() {
    return Column(
      children: [
        WidgetHeader3(
          title: 'Principal',
          isExpanded: !_isAreaSectionCollapsed, // animatie
          onTrailingIconTap: () {
            setState(() {
              _isAreaSectionCollapsed = !_isAreaSectionCollapsed;
            });
          },
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
        ),
        const SizedBox(height: AppTheme.smallGap),
        _buildAreaButtons(),
      ],
    );
  }

  /// Builds the panes navigation section with collapsible header
  Widget _buildPanesSection() {
    return Column(
      children: [
        WidgetHeader3(
          title: 'Secundar',
          isExpanded: !_isPaneSectionCollapsed, // animatie
          onTrailingIconTap: () {
            setState(() {
              _isPaneSectionCollapsed = !_isPaneSectionCollapsed;
            });
          },
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
        ),
        const SizedBox(height: AppTheme.smallGap),
        _buildPaneButtons(),
      ],
    );
  }

  /// Builds the special functions section
  Widget _buildSpecialSection() {
    final buttons = _sidebarService.specialButtons;
    
    if (buttons.isEmpty) {
      return const SizedBox.shrink(); // Nu afisa sectiunea daca nu sunt butoane
    }
    
    return Column(
      children: [
        WidgetHeader3(
          title: 'Functii',
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
        ),
        const SizedBox(height: AppTheme.smallGap),
        _buildSpecialButtons(),
      ],
    );
  }

  /// Builds the special function buttons
  Widget _buildSpecialButtons() {
    final buttons = _sidebarService.specialButtons;
    
    if (buttons.isEmpty) {
      return const SizedBox.shrink(); // Nu afisa nimic daca nu sunt butoane
    }
    
    return Column(
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          _buildSpecialNavigationButton(buttons[i]),
          if (i < buttons.length - 1) const SizedBox(height: AppTheme.smallGap),
        ],
      ],
    );
  }

  /// Builds the area navigation buttons with collapse behavior
  Widget _buildAreaButtons() {
    final buttons = _sidebarService.areaButtons;
    
    if (_isAreaSectionCollapsed) {
      // When collapsed, show only the active button
      final activeButton = buttons.firstWhere(
        (button) => button.targetArea == _currentArea,
        orElse: () => buttons.first,
      );
      return _buildNavigationButton(activeButton);
    }
    
    // When expanded, show all buttons with proper gap spacing
    return Column(
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          _buildNavigationButton(buttons[i]),
          if (i < buttons.length - 1) const SizedBox(height: AppTheme.smallGap),
        ],
      ],
    );
  }

  /// Builds the pane navigation buttons with collapse behavior
  Widget _buildPaneButtons() {
    final buttons = _sidebarService.paneButtons;
    
    if (_isPaneSectionCollapsed) {
      // When collapsed, show only the active button
      final activeButton = buttons.firstWhere(
        (button) => button.targetPane == _currentPane,
        orElse: () => buttons.first,
      );
      return _buildNavigationButton(activeButton);
    }
    
    // When expanded, show all buttons with proper gap spacing
    return Column(
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          _buildNavigationButton(buttons[i]),
          if (i < buttons.length - 1) const SizedBox(height: AppTheme.smallGap),
        ],
      ],
    );
  }

  /// Builds a single navigation button with active state styling
  Widget _buildNavigationButton(ButtonConfig button) {
    bool isActive = _isButtonActive(button);
    
    if (isActive) {
      // For active buttons, set explicit colors
      return SpacedButtonSingleSvg(
        text: button.title,
        iconPath: button.iconPath,
        onTap: () => _sidebarService.handleButtonClick(button),
        backgroundColor: AppTheme.containerColor2,
        textColor: AppTheme.elementColor3,
        iconColor: AppTheme.elementColor3,
        borderRadius: AppTheme.borderRadiusMedium,
        buttonHeight: AppTheme.navButtonHeight,
      );
    } else {
      // For inactive buttons, let the component handle hover states
      return SpacedButtonSingleSvg(
        text: button.title,
        iconPath: button.iconPath,
        onTap: () => _sidebarService.handleButtonClick(button),
        borderRadius: AppTheme.borderRadiusMedium,
        buttonHeight: AppTheme.navButtonHeight,
      );
    }
  }

  /// Builds a special function button 
  Widget _buildSpecialNavigationButton(ButtonConfig button) {
    return SpacedButtonSingleSvg(
      text: button.title,
      iconPath: button.iconPath,
      onTap: () => _handleSpecialButtonClick(button),
      borderRadius: AppTheme.borderRadiusMedium,
      buttonHeight: AppTheme.navButtonHeight,
    );
  }

  /// Handles special button clicks (like export)
  void _handleSpecialButtonClick(ButtonConfig button) {
    _sidebarService.handleButtonClick(button);
  }

  /// Determines if a button should appear as active
  bool _isButtonActive(ButtonConfig button) {
    if (button.actionType == ActionType.navigateToArea && button.targetArea != null) {
      return _sidebarService.currentArea == button.targetArea;
    } else if (button.actionType == ActionType.openPane && button.targetPane != null) {
      return _sidebarService.currentPane == button.targetPane;
    }
    return false;
  }

  /// Shows the consultant details popup
  void _showConsultantPopup() {
    if (!mounted) return;
    
    showDialog(
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

