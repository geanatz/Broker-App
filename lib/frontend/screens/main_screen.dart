import 'package:broker_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:broker_app/backend/services/sidebar_service.dart';
import 'package:broker_app/frontend/popups/consultant_popup.dart';
import 'package:broker_app/frontend/components/headers/widget_header3.dart';
import 'package:broker_app/frontend/components/buttons/spaced_buttons1.dart';
import 'package:broker_app/frontend/components/items/light_item7.dart';
import 'package:broker_app/frontend/areas/dashboard_area.dart';
import 'package:broker_app/frontend/areas/form_area.dart';
import 'package:broker_app/frontend/areas/calendar_area.dart';
import 'package:broker_app/frontend/areas/settings_area.dart';
import 'package:broker_app/frontend/panes/meetings_pane.dart';
import 'package:broker_app/frontend/panes/calculator_pane.dart';
import 'package:broker_app/frontend/panes/clients_pane.dart';
import 'package:broker_app/frontend/panes/matcher_pane.dart';
import 'package:broker_app/frontend/popups/clients_popup.dart';
import 'package:broker_app/backend/services/clients_service.dart';
import 'package:broker_app/backend/services/settings_service.dart';
import 'package:broker_app/backend/services/splash_service.dart';
import 'package:broker_app/backend/services/update_service.dart';
import 'package:broker_app/frontend/components/update_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  
  // Splash service pentru servicii pre-încărcate
  final SplashService _splashService = SplashService();
  
  // Client service pentru gestionarea popup-urilor (folosește cache-ul din splash)
  late final ClientUIService _clientService;
  
  // Settings service pentru actualizari in timp real ale temei
  final SettingsService _settingsService = SettingsService();
  
  // Update service pentru notificari de update-uri
  final UpdateService _updateService = UpdateService();
  
  // Sidebar service pentru navigare
  late final SidebarService _sidebarService;
  
  // UI state pentru sidebar - sectiuni colapsabile
  bool _isAreaSectionCollapsed = false;
  bool _isPaneSectionCollapsed = false;
  

  
  // State pentru popup-uri
  List<Client> _popupClients = [];
  Client? _selectedPopupClient;
  bool _isShowingClientListPopup = false;
  
  @override
  void initState() {
    super.initState();
    _consultantName = widget.consultantName ?? 'Consultant';
    _teamName = widget.teamName ?? 'Echipa';
    

    
    // Folosește serviciile pre-încărcate din splash
    // Verifică dacă serviciile sunt disponibile
    if (_splashService.areServicesReady) {
      _clientService = _splashService.clientUIService;
    } else {
      // Initialize service directly if splash service isn't ready yet
      _clientService = ClientUIService();
    }
    
    // FIX: Resetează cache-ul pentru consultant curent la început
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
    
    // Asculta schimbarile din SettingsService pentru actualizari in timp real ale temei
    _settingsService.addListener(_onSettingsChanged);
    
    // Initializeaza SettingsService
    _initializeSettings();
    
    // Asculta schimbarile de brightness pentru modul auto
    WidgetsBinding.instance.addObserver(this);
  }

  /// FIX: Inițializează aplicația pentru consultantul curent
  Future<void> _initializeForCurrentConsultant() async {
    try {
      // Resetează cache-ul pentru consultant/echipa curentă
      await _splashService.resetForNewConsultant();
      

    } catch (e) {
      debugPrint('❌ MAIN_SCREEN: Error initializing for current consultant: $e');
    }
  }
  
  @override
  void dispose() {
    _clientService.removeListener(_onClientServiceChanged);
    _settingsService.removeListener(_onSettingsChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // Actualizeaza UI-ul cand se schimba brightness-ul sistemului (pentru modul auto)
    if (_settingsService.currentThemeMode == AppThemeMode.auto) {
      setState(() {});
    }
  }
  
  void _onClientServiceChanged() {
    // Defer setState until after the current frame to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _syncPopupWithService();
        });
      }
    });
  }
  
  /// Sincronizeaza datele popup-ului cu cele din ClientService
  void _syncPopupWithService() {
    _popupClients = _clientService.clients.map((clientModel) {
      return Client(
        name: clientModel.name,
        phoneNumber1: clientModel.phoneNumber1,
        phoneNumber2: clientModel.phoneNumber2,
        coDebitorName: clientModel.coDebitorName,
      );
    }).toList();
    
    // Pastreaza selectia curenta daca exista
    if (_selectedPopupClient != null) {
      _selectedPopupClient = _popupClients.firstWhere(
        (client) => client.name == _selectedPopupClient!.name && 
                   client.phoneNumber1 == _selectedPopupClient!.phoneNumber1,
        orElse: () => _popupClients.isNotEmpty ? _popupClients.first : _selectedPopupClient!,
      );
    }
  }
  
  /// Initializeaza SettingsService
  Future<void> _initializeSettings() async {
    if (!_settingsService.isInitialized) {
      await _settingsService.initialize();
    }
  }
  
  /// Callback pentru schimbarile din SettingsService
  void _onSettingsChanged() {
    if (mounted) {
      setState(() {
        // Actualizeaza intreaga interfata cand se schimba tema
      });
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
      debugPrint('🔧 MAIN_SCREEN: Area set by default to Acasa (dashboard)');
      
      if (paneIndex != null && paneIndex < PaneType.values.length) {
        _currentPane = PaneType.values[paneIndex];
        // Update SidebarService state to keep it in sync
        _sidebarService.syncPane(_currentPane);
        debugPrint('🔧 MAIN_SCREEN: Restored pane from preferences: $_currentPane');
      } else {
        // Nu există preferințe salvate - folosim default-ul (clients)  
        _currentPane = PaneType.clients;
        _sidebarService.syncPane(_currentPane);
        debugPrint('🔧 MAIN_SCREEN: No saved pane preferences, using default: clients');
      }
      
      // Update UI if needed
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error restoring navigation state: $e');
      // În caz de eroare, folosim default-urile
      _currentArea = AreaType.dashboard;
      _currentPane = PaneType.clients;
      _sidebarService.syncArea(_currentArea);
      _sidebarService.syncPane(_currentPane);
      debugPrint('🔧 MAIN_SCREEN: Error fallback - using defaults: dashboard, clients');
    }
  }
  
  /// Saves navigation state to SharedPreferences
  Future<void> _saveNavigationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_currentAreaKey, _currentArea.index);
      await prefs.setInt(_currentPaneKey, _currentPane.index);
    } catch (e) {
      debugPrint('Error saving navigation state: $e');
    }
  }
  
  // Widgets pentru area
  Map<AreaType, Widget> get _areaWidgets => {
    AreaType.dashboard: DashboardArea(),
    AreaType.form: FormArea(),
    AreaType.calendar: CalendarArea(
      key: _calendarKey,
      onMeetingSaved: _refreshMeetingsPane,
    ),
    AreaType.settings: SettingsArea(),
  };
  
  Map<PaneType, Widget> get _paneWidgets => {
    PaneType.clients: ClientsPane(
      onClientsPopupRequested: _handleClientsPopupRequested,
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
    // Periodically verify state consistency during builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _forceSyncStates();
      }
    });
    
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
                      onDeleteClient: () => _handleDeleteClient(_selectedPopupClient!),
                      onDeleteAllClients: _handleDeleteAllClients,
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
    debugPrint('🔄 Area changed to: $area');
    setState(() {
      _currentArea = area;
    });
    // Save navigation state
    _saveNavigationState();
    
    // Force state sync after a short delay to handle any race conditions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forceSyncStates();
    });
  }
  
  void _handlePaneChanged(PaneType pane) {
    debugPrint('🔄 Pane changed to: $pane');
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
    
    // Force state sync after a short delay to handle any race conditions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forceSyncStates();
    });
  }
  
  /// Handles the clients popup request from sidebar
  void _handleClientsPopupRequested() {
    setState(() {
      _syncPopupWithService();
      _isShowingClientListPopup = true;
      // Seteaza primul client ca selectat implicit
      _selectedPopupClient = _popupClients.isNotEmpty ? _popupClients.first : null;
    });
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
  
  /// Handles delete all clients button press
  void _handleDeleteAllClients() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmare stergere'),
          content: const Text('Esti sigur ca vrei sa stergi toti clientii din lista?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anuleaza'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performDeleteAllClients();
              },
              child: const Text('Sterge'),
            ),
          ],
        );
      },
    );
  }
  
  /// Performs the actual deletion of all clients
  void _performDeleteAllClients() async {
    // Sterge toti clientii din ClientService
    await _clientService.deleteAllClients();
    
    // Inchide popup-ul
    _closeAllPopups();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toti clientii au fost stersi din lista'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Handles delete OCR image completely (removes item from gallery)
  void _handleDeleteOcrClients() {
    // Aceasta metoda este apelata cand se sterge complet imaginea OCR selectata
    // Logica efectiva de stergere se face in ClientsPopup prin _deleteOcrClientsFromSelectedImage()
    // Aici putem adauga logging sau alte actiuni suplimentare daca e necesar
    debugPrint('🗑️ OCR image completely removed from gallery');
  }
  
  /// Handles saving a client (create or edit)
  void _handleSaveClient(Client client) async {
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
        category: ClientCategory.apeluri, // New clients go to "Apeluri"
      );
      
      await _clientService.addClient(newClientModel);
    }
  }
  
  /// Handles deleting a client
  void _handleDeleteClient(Client client) async {
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
          trailingIcon: _isAreaSectionCollapsed 
              ? Icons.keyboard_arrow_up 
              : Icons.keyboard_arrow_down,
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
          trailingIcon: _isPaneSectionCollapsed 
              ? Icons.keyboard_arrow_up 
              : Icons.keyboard_arrow_down,
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
