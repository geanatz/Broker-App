import 'package:flutter/material.dart';
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/frontend/common/sidebar.dart';
import 'package:broker_app/backend/services/sidebarService.dart';
import 'package:broker_app/frontend/areas/dashboardArea.dart';
import 'package:broker_app/frontend/areas/formArea.dart';
import 'package:broker_app/frontend/areas/calendarArea.dart';
import 'package:broker_app/frontend/areas/settingsArea.dart';
import 'package:broker_app/frontend/panes/meetingsPane.dart';
import 'package:broker_app/frontend/panes/calculatorPane.dart';
import 'package:broker_app/frontend/panes/clientsPane.dart';
import 'package:broker_app/frontend/popups/clientsPopup.dart';
import 'package:broker_app/frontend/common/services/client_service.dart';
import 'package:broker_app/backend/models/client_model.dart';
import 'package:broker_app/backend/services/settingsService.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ecranul principal al aplicației care conține cele 3 coloane:
/// - pane (stânga, lățime 312)
/// - area (centru, lățime flexibilă)
/// - sidebar (dreapta, lățime 224)
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
  // Starea actuală de navigare
  AreaType _currentArea = AreaType.form;
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
  
  // Client service pentru gestionarea popup-urilor
  final ClientService _clientService = ClientService();
  
  // Settings service pentru actualizări în timp real ale temei
  final SettingsService _settingsService = SettingsService();
  
  // Unified service for migration
  
  // State pentru popup-uri
  List<Client> _popupClients = [];
  Client? _selectedPopupClient;
  bool _isShowingClientListPopup = false;
  
  @override
  void initState() {
    super.initState();
    _consultantName = widget.consultantName ?? 'Consultant';
    _teamName = widget.teamName ?? 'Echipa';
    
    // Restore navigation state from SharedPreferences
    _restoreNavigationState();
    
    // Sincronizează popup-ul cu datele din service
    _syncPopupWithService();
    
    // Ascultă schimbările din ClientService
    _clientService.addListener(_onClientServiceChanged);
    
    // Ascultă schimbările din SettingsService pentru actualizări în timp real ale temei
    _settingsService.addListener(_onSettingsChanged);
    
    // Inițializează SettingsService
    _initializeSettings();
    
    // Ascultă schimbările de brightness pentru modul auto
    WidgetsBinding.instance.addObserver(this);
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
    // Actualizează UI-ul când se schimbă brightness-ul sistemului (pentru modul auto)
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
  
  /// Sincronizează datele popup-ului cu cele din ClientService
  void _syncPopupWithService() {
    _popupClients = _clientService.clients.map((clientModel) {
      return Client(
        name: clientModel.name,
        phoneNumber1: clientModel.phoneNumber1,
        phoneNumber2: clientModel.phoneNumber2,
        coDebitorName: clientModel.coDebitorName,
      );
    }).toList();
    
    // Păstrează selecția curentă dacă există
    if (_selectedPopupClient != null) {
      _selectedPopupClient = _popupClients.firstWhere(
        (client) => client.name == _selectedPopupClient!.name && 
                   client.phoneNumber1 == _selectedPopupClient!.phoneNumber1,
        orElse: () => _popupClients.isNotEmpty ? _popupClients.first : _selectedPopupClient!,
      );
    }
  }
  
  /// Inițializează SettingsService
  Future<void> _initializeSettings() async {
    if (!_settingsService.isInitialized) {
      await _settingsService.initialize();
    }
  }
  
  /// Callback pentru schimbările din SettingsService
  void _onSettingsChanged() {
    if (mounted) {
      setState(() {
        // Actualizează întreaga interfață când se schimbă tema
      });
    }
  }
  
  /// Restores navigation state from SharedPreferences
  Future<void> _restoreNavigationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final areaIndex = prefs.getInt(_currentAreaKey);
      final paneIndex = prefs.getInt(_currentPaneKey);
      
      if (areaIndex != null && areaIndex < AreaType.values.length) {
        _currentArea = AreaType.values[areaIndex];
      }
      
      if (paneIndex != null && paneIndex < PaneType.values.length) {
        _currentPane = PaneType.values[paneIndex];
      }
      
      // Update UI if needed
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error restoring navigation state: $e');
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
    PaneType.matches: const PlaceholderWidget('Matches Pane', Colors.pink),
  };
  
  /// Navigates to a specific meeting in the calendar
  void _navigateToMeeting(String meetingId) {
    // Switch to calendar area if not already there
    if (_currentArea != AreaType.calendar) {
      setState(() {
        _currentArea = AreaType.calendar;
      });
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
    return Scaffold(
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
              // Pane Column (stânga) - lățime fixă 312
              SizedBox(
                width: 312,
                child: _paneWidgets[_currentPane]!,
              ),
              
              // Spacing
              const SizedBox(width: AppTheme.largeGap),
              
              // Area Column (centru) - lățime flexibilă
              Expanded(
                child: _areaWidgets[_currentArea]!,
              ),
              
              // Spacing
              const SizedBox(width: AppTheme.largeGap),
              
              // Sidebar Column (dreapta) - lățime fixă 224
              SidebarWidget(
                consultantName: _consultantName,
                teamName: _teamName,
                currentArea: _currentArea,
                currentPane: _currentPane,
                onAreaChanged: _handleAreaChanged,
                onPaneChanged: _handlePaneChanged,
                onClientsPopupRequested: _handleClientsPopupRequested,
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
  
  
  /// Builds dual popup overlay with both popups side by side
  Widget _buildDualPopupOverlay() {
    return GestureDetector(
      onTap: _closeAllPopups, // Închide popup-ul la click pe background
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Previne închiderea când se face click pe popup
            child: Material(
              color: Colors.transparent,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Client List Popup (întotdeauna vizibil când e deschis)
                  if (_isShowingClientListPopup)
                    ClientsPopup(
                      clients: _popupClients,
                      selectedClient: _selectedPopupClient,
                      onClientSelected: _handleClientSelected,
                      onEditClient: _handleEditClient,
                      onSaveClient: _handleSaveClient,
                      onDeleteClient: () => _handleDeleteClient(_selectedPopupClient!),
                      onDeleteAllClients: _handleDeleteAllClients,
                    ),
                  
                  // Form-ul de editare e acum integrat în ClientsPopup
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _handleAreaChanged(AreaType area) {
    setState(() {
      _currentArea = area;
    });
    // Save navigation state
    _saveNavigationState();
  }
  
  void _handlePaneChanged(PaneType pane) {
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
  }
  
  /// Handles the clients popup request from sidebar
  void _handleClientsPopupRequested() {
    setState(() {
      _syncPopupWithService();
      _isShowingClientListPopup = true;
      // Setează primul client ca selectat implicit
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
    
    // Nu mai focusăm clientul în ClientService pentru a nu afecta clientsPane
    // Focus-ul din clientsPane rămâne independent de selecția din popup
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
    // Șterge toți clienții din ClientService
    await _clientService.deleteAllClients();
    
    // Închide popup-ul
    _closeAllPopups();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Toti clientii au fost stersi din lista'),
        duration: Duration(seconds: 2),
      ),
    );
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
