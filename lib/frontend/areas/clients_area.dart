import '../../app_theme.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// Backend services
import '../../backend/services/clients_service.dart';
import '../../backend/services/splash_service.dart';
import '../../backend/services/form_service.dart';



// Components
import '../components/headers/widget_header2.dart';
import '../components/buttons/action_button.dart';
import '../components/fields/input_field1.dart';
import '../components/dialog_utils.dart';

/// Client model to represent client data
class Client {
  final String name;
  final String phoneNumber1;
  final String? phoneNumber2;
  final String? coDebitorName;
  final String? age;
  final String? ficoScore;
  final bool hasCoDebitor;
  final bool hasReferent;
  final ClientStatusType? status;

  Client({
    required this.name,
    required this.phoneNumber1,
    this.phoneNumber2,
    this.coDebitorName,
    this.age,
    this.ficoScore,
    this.hasCoDebitor = false,
    this.hasReferent = false,
    this.status,
  });

  /// Pentru compatibilitate cu codul existent
  String get phoneNumber => phoneNumber1;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Client &&
        other.name == name &&
        other.phoneNumber1 == phoneNumber1 &&
        other.phoneNumber2 == phoneNumber2 &&
        other.coDebitorName == coDebitorName;
  }

  @override
  int get hashCode {
    return Object.hash(name, phoneNumber1, phoneNumber2, coDebitorName);
  }

  /// Factory method to create Client from ClientModel
  factory Client.fromClientModel(ClientModel model) {
    return Client(
      name: model.name,
      phoneNumber1: model.phoneNumber1,
      phoneNumber2: model.phoneNumber2,
      coDebitorName: model.coDebitorName,
      age: model.getFormValue<String>('age'),
      ficoScore: model.getFormValue<String>('ficoScore'),
      hasCoDebitor: model.getFormValue<bool>('hasCoDebitor') ?? false,
      hasReferent: model.getFormValue<bool>('hasReferent') ?? false,
      status: model.discussionStatus,
    );
  }
}

/// Estados del area para determinar qué widgets mostrar
enum ClientsAreaMode {
  table,           // Tabel principal cu clienti
  form,            // Formular complet pentru clientul selectat
  editClient,      // Editare/creare client
}

/// Custom switch button widget that maintains the current design
class SwitchButton extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String trueLabel;
  final String falseLabel;

  const SwitchButton({
    super.key,
    required this.value,
    required this.onChanged,
    this.trueLabel = 'Da',
    this.falseLabel = 'Nu',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      decoration: ShapeDecoration(
        color: AppTheme.backgroundColor3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // True option (Da)
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onChanged(true),
                child: Container(
                  height: 24,
                  decoration: ShapeDecoration(
                    color: value ? AppTheme.backgroundColor1 : Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Center(
                    child: Text(
                      trueLabel,
                      style: GoogleFonts.outfit(
                        color: value ? AppTheme.elementColor3 : AppTheme.elementColor1,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // False option (Nu)
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onChanged(false),
                child: Container(
                  height: 24,
                  decoration: ShapeDecoration(
                    color: !value ? AppTheme.backgroundColor1 : Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Center(
                    child: Text(
                      falseLabel,
                      style: GoogleFonts.outfit(
                        color: !value ? AppTheme.elementColor3 : AppTheme.elementColor1,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Main clients area widget that combines pane, popup and form functionality
class ClientsArea extends StatefulWidget {
  /// Callback when "Add Client" button is tapped
  final VoidCallback? onAddClient;

  /// Callback when a client is selected for editing
  final Function(Client)? onEditClient;

  /// Callback when a client is saved
  final Function(Client)? onSaveClient;

  /// Callback when a client is deleted
  final void Function(Client client)? onDeleteClient;

  const ClientsArea({
    super.key,
    this.onAddClient,
    this.onEditClient,
    this.onSaveClient,
    this.onDeleteClient,
  });

  @override
  State<ClientsArea> createState() => _ClientsAreaState();
}

class _ClientsAreaState extends State<ClientsArea> {
  // Services
  late final ClientUIService _clientService;
  late final FormService _formService;
  late final SplashService _splashService;

  // State
  ClientsAreaMode _currentMode = ClientsAreaMode.table;
  Client? _editingClient;
  Client? _selectedClient;

  // Table state
  final ScrollController _tableScrollController = ScrollController();
  bool _isLoading = false;

  // Edit form state
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController1 = TextEditingController();
  final TextEditingController _phoneController2 = TextEditingController();
  final TextEditingController _coDebitorNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _ficoScoreController = TextEditingController();
  bool _hasCoDebitor = false;
  bool _hasReferent = false;

  // Sorting state
  String? _sortColumn;
  bool _sortAscending = true;

  // Filtering and sorting
  String _searchQuery = '';
  ClientStatusType? _statusFilter;
  final TextEditingController _searchController = TextEditingController();

  // Performance optimization
  Timer? _searchDebounceTimer;
  List<Client> _filteredClients = [];

  @override
  void initState() {
    super.initState();

    // Initialize services
    _splashService = SplashService();
    _clientService = _splashService.clientUIService;
    _formService = _splashService.formService;

    // Add listeners
    _clientService.addListener(_onClientServiceChanged);
    _formService.addListener(_onFormServiceChanged);

    // Initialize filtered clients
    _filteredClients = _getFilteredAndSortedClients();

    // Setup search controller
    _searchController.addListener(_onSearchChanged);

    // Load initial data
    _loadClients();
  }

  @override
  void dispose() {
    _clientService.removeListener(_onClientServiceChanged);
    _formService.removeListener(_onFormServiceChanged);

    _tableScrollController.dispose();
    _searchController.dispose();
    _searchDebounceTimer?.cancel();

    _nameController.dispose();
    _phoneController1.dispose();
    _phoneController2.dispose();
    _coDebitorNameController.dispose();
    _ageController.dispose();
    _ficoScoreController.dispose();

    super.dispose();
  }

  /// Load clients from service
  Future<void> _loadClients() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Ensure clients are loaded
      if (_clientService.clients.isEmpty) {
        await _clientService.initializeDemoData();
      }

      _filteredClients = _getFilteredClients();
    } catch (e) {
      debugPrint('❌ CLIENTS_AREA: Error loading clients: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Get filtered clients based on search and status filter
  List<Client> _getFilteredClients() {
    List<Client> clients = _clientService.clients.map((clientModel) {
      return Client.fromClientModel(clientModel);
    }).toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      clients = clients.where((client) {
        return client.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               client.phoneNumber1.contains(_searchQuery) ||
               (client.phoneNumber2?.contains(_searchQuery) ?? false);
      }).toList();
    }

    // Apply status filter
    if (_statusFilter != null) {
      clients = clients.where((client) => client.status == _statusFilter).toList();
    }

    return clients;
  }

  /// Get filtered and sorted clients
  List<Client> _getFilteredAndSortedClients() {
    final filtered = _getFilteredClients();
    
    if (_sortColumn == null) return filtered;
    
    return _getSortedClients();
  }

  /// Handle search input changes with debouncing
  void _onSearchChanged() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text;
          _filteredClients = _getFilteredAndSortedClients();
        });
      }
    });
  }

  /// Service change listeners
  void _onClientServiceChanged() {
    if (mounted) {
      setState(() {
        _filteredClients = _getFilteredAndSortedClients();
      });
    }
  }

  void _onFormServiceChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Navigation methods
  void _switchToEditMode([Client? client]) {
    setState(() {
      _currentMode = ClientsAreaMode.editClient;
      _editingClient = client;
      _selectedClient = client;

      // Populate form fields
      _nameController.text = client?.name ?? '';
      _phoneController1.text = client?.phoneNumber1 ?? '';
      _phoneController2.text = client?.phoneNumber2 ?? '';
      _coDebitorNameController.text = client?.coDebitorName ?? '';
      _ageController.text = client?.age ?? '';
      _ficoScoreController.text = client?.ficoScore ?? '';
      _hasCoDebitor = client?.hasCoDebitor ?? false;
      _hasReferent = client?.hasReferent ?? false;
    });
  }

  void _switchToTableMode() {
    setState(() {
      _currentMode = ClientsAreaMode.table;
      _editingClient = null;
      _selectedClient = null;
    });
  }

  void _switchToFormMode(Client client) {
    setState(() {
      _currentMode = ClientsAreaMode.form;
      _selectedClient = client;
    });

    // Focus client in service for form display
    _clientService.focusClient(client.phoneNumber1);
  }







  Future<void> _saveClient() async {
    if (_nameController.text.trim().isEmpty || _phoneController1.text.trim().isEmpty) {
      return;
    }

    final client = Client(
      name: _nameController.text.trim(),
      phoneNumber1: _phoneController1.text.trim(),
      phoneNumber2: _phoneController2.text.trim().isEmpty ? null : _phoneController2.text.trim(),
      coDebitorName: _coDebitorNameController.text.trim().isEmpty ? null : _coDebitorNameController.text.trim(),
      age: _ageController.text.trim().isEmpty ? null : _ageController.text.trim(),
      ficoScore: _ficoScoreController.text.trim().isEmpty ? null : _ficoScoreController.text.trim(),
      hasCoDebitor: _hasCoDebitor,
      hasReferent: _hasReferent,
      status: _editingClient?.status ?? ClientStatusType.neapelat,
    );

    try {
      // Check if this is an existing client
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
          discussionStatus: client.status,
        );

        // Update form data for additional fields
        if (client.age != null) updatedClientModel.updateFormData('age', client.age);
        if (client.ficoScore != null) updatedClientModel.updateFormData('ficoScore', client.ficoScore);
        updatedClientModel.updateFormData('hasCoDebitor', client.hasCoDebitor);
        updatedClientModel.updateFormData('hasReferent', client.hasReferent);

        await _clientService.updateClient(updatedClientModel);
      } else {
        // Create new client
        final formData = <String, dynamic>{};
        if (client.age != null) formData['age'] = client.age;
        if (client.ficoScore != null) formData['ficoScore'] = client.ficoScore;
        formData['hasCoDebitor'] = client.hasCoDebitor;
        formData['hasReferent'] = client.hasReferent;

        final newClientModel = ClientModel(
          id: client.phoneNumber1,
          name: client.name,
          phoneNumber1: client.phoneNumber1,
          phoneNumber2: client.phoneNumber2,
          coDebitorName: client.coDebitorName,
          status: ClientStatus.normal, // Keep original ClientStatus for focus state
  
          formData: formData,
          discussionStatus: client.status,
        );

        await _clientService.addClient(newClientModel);
      }

      // Notify parent
      widget.onSaveClient?.call(client);

      // Return to table mode
      _switchToTableMode();

    } catch (e) {
      debugPrint('❌ CLIENTS_AREA: Error saving client: $e');
    }
  }

  Future<void> _deleteClient(Client client) async {
    try {
      await _clientService.removeClient(client.phoneNumber1);
      widget.onDeleteClient?.call(client);

      if (_selectedClient?.phoneNumber1 == client.phoneNumber1) {
        setState(() {
          _selectedClient = null;
        });
      }
    } catch (e) {
      debugPrint('❌ CLIENTS_AREA: Error deleting client: $e');
    }
  }

  /// Sort clients by specified column
  void _sortClients(String column) {
    setState(() {
      if (_sortColumn == column) {
        // Toggle sort direction if same column
        _sortAscending = !_sortAscending;
      } else {
        // New column, start with ascending
        _sortColumn = column;
        _sortAscending = true;
      }
      
      // Apply sorting
      _filteredClients = _getSortedClients();
    });
  }

  /// Get sorted clients based on current sort column and direction
  List<Client> _getSortedClients() {
    final clients = _getFilteredClients();
    
    if (_sortColumn == null) return clients;

    clients.sort((a, b) {
      int comparison = 0;
      
      switch (_sortColumn) {
        case 'nr':
          // Nr. is just the row number, no actual sorting needed
          return 0;
          
        case 'nume':
          comparison = a.name.compareTo(b.name);
          break;
          
        case 'varsta':
          final ageA = int.tryParse(a.age ?? '0') ?? 0;
          final ageB = int.tryParse(b.age ?? '0') ?? 0;
          comparison = ageA.compareTo(ageB);
          break;
          
        case 'ficoScore':
          final scoreA = int.tryParse(a.ficoScore ?? '0') ?? 0;
          final scoreB = int.tryParse(b.ficoScore ?? '0') ?? 0;
          comparison = scoreA.compareTo(scoreB);
          break;
          
        case 'status':
          comparison = _compareStatus(a.status, b.status);
          break;
          
        default:
          return 0;
      }
      
      return _sortAscending ? comparison : -comparison;
    });
    
    return clients;
  }

  /// Compare status values according to specified order
  int _compareStatus(ClientStatusType? statusA, ClientStatusType? statusB) {
    // Order: Neapelat -> Nu răspunde -> Amanat -> Programat -> Finalizat
    final statusOrder = {
      ClientStatusType.neapelat: 1,
      ClientStatusType.nuRaspunde: 2,
      ClientStatusType.amanat: 3,
      ClientStatusType.programat: 4,
      ClientStatusType.finalizat: 5,
    };
    
    final orderA = statusOrder[statusA] ?? 0;
    final orderB = statusOrder[statusB] ?? 0;
    
    return orderA.compareTo(orderB);
  }

  /// Get sort indicator color for a column
  Color _getSortIndicatorColor(String column) {
    if (_sortColumn != column) {
      return const Color(0xFF938F8A); // Default color
    }
    
    return _sortAscending ? AppTheme.elementColor2 : AppTheme.elementColor3;
  }





  /// Show delete client selection popup
  Future<void> _showDeleteClientSelection() async {
    if (_filteredClients.isEmpty) {
      return;
    }

    final selectedClient = await showDialog<Client>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(16),
            decoration: ShapeDecoration(
              color: AppTheme.backgroundColor1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Selecteaza clientul de sters',
                  style: GoogleFonts.outfit(
                    color: AppTheme.elementColor2,
                    fontSize: AppTheme.fontSizeLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: _filteredClients.length,
                    itemBuilder: (context, index) {
                      final client = _filteredClients[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(client),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: ShapeDecoration(
                              color: AppTheme.backgroundColor2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  client.name,
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.elementColor3,
                                    fontSize: AppTheme.fontSizeMedium,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Telefon: ${client.phoneNumber1}',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.elementColor1,
                                    fontSize: AppTheme.fontSizeSmall,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Anuleaza',
                        style: GoogleFonts.outfit(
                          color: AppTheme.elementColor1,
                          fontSize: AppTheme.fontSizeMedium,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedClient != null) {
      await _deleteClient(selectedClient);
    }
  }

  /// Show status selection popup
  Future<void> _showStatusSelectionPopup(Client client) async {
    // Get all available statuses
    final allStatuses = ClientStatusType.values;

    // Filter out the current status to show only the other 4 options
    final availableStatuses = allStatuses.where((status) => status != client.status).toList();

    final selectedStatus = await showBlurredDialog<ClientStatusType>(
      context: context,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEAE9), // light-blue-background2
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppTheme.popupShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                Text(
                  'Selecteaza statusul',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF7C7A77), // light-blue-text-2
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 8,
                  children: availableStatuses.map((status) {
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(status),
                        child: Container(
                          width: 240,
                          height: 40,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: ShapeDecoration(
                            color: _getStatusColor(status),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 4,
                                color: _getStatusStrokeColor(status),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 10,
                            children: [
                              Text(
                                _getStatusDisplayName(status),
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF666666), // light-blue-text-3
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedStatus != null) {
      await _updateClientStatus(client, selectedStatus);
    }
  }

  /// Update client's status
  Future<void> _updateClientStatus(Client client, ClientStatusType newStatus) async {
    try {
      // Find the client model in the service
      final clientModel = _clientService.clients.where(
        (model) => model.phoneNumber1 == client.phoneNumber1,
      ).firstOrNull;

      if (clientModel != null) {
        // Update the discussion status using copyWith
        final updatedClientModel = clientModel.copyWith(
          discussionStatus: newStatus,
          updatedAt: DateTime.now(),
        );

        // Update the client in the service
        await _clientService.updateClient(updatedClientModel);

        // Update local state to reflect changes
        setState(() {
          // Force refresh of filtered clients
          _filteredClients = _getFilteredAndSortedClients();
        });

        debugPrint('✅ CLIENTS_AREA: Client status updated successfully: ${client.name} - ${newStatus.name}');
      }
    } catch (e) {
      debugPrint('❌ CLIENTS_AREA: Error updating client status: $e');
    }
  }

  /// Build main widget based on current mode
  @override
  Widget build(BuildContext context) {
    switch (_currentMode) {
      case ClientsAreaMode.table:
        return _buildTableMode();
      case ClientsAreaMode.form:
        return _buildFormMode();
      case ClientsAreaMode.editClient:
        return _buildEditMode();
    }
  }

  /// Build table mode - main clients table
  Widget _buildTableMode() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: ShapeDecoration(
        color: const Color(0xFFE1DBD5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          // Table content
          Padding(
            padding: const EdgeInsets.only(bottom: 64), // Space for overlay
            child: _buildTableContent(),
          ),

          // Overlay container with search and add client button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _buildClientsOverlay(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build overlay container with search and add client button
  Widget _buildClientsOverlay() {
    return SizedBox(
      width: 432,
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: ShapeDecoration(
          color: const Color(0xFFEBEAE9) /* light-blue-background2 */,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          shadows: AppTheme.standardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [
            // Search field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: ShapeDecoration(
                  color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: double.infinity,
                        child: Center(
                          child: TextField(
                            controller: _searchController,
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                              hintText: 'Cauta...',
                              hintStyle: GoogleFonts.outfit(
                                color: AppTheme.elementColor1,
                                fontSize: 15,
                                fontWeight: AppTheme.fontWeightMedium,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            style: GoogleFonts.outfit(
                              color: AppTheme.elementColor3,
                              fontSize: 15,
                              fontWeight: AppTheme.fontWeightMedium,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Add client button
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _switchToEditMode(),
                child: Container(
                  width: 40,
                  height: double.infinity,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: SvgPicture.asset(
                          'assets/plus_outlined.svg',
                          colorFilter: ColorFilter.mode(
                            AppTheme.elementColor3,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Delete client button
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _showDeleteClientSelection(),
                child: Container(
                  width: 40,
                  height: double.infinity,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: SvgPicture.asset(
                          'assets/delete_outlined.svg',
                          colorFilter: ColorFilter.mode(
                            AppTheme.elementColor3,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }





  /// Get display name for status
  String _getStatusDisplayName(ClientStatusType? status) {
    if (status == null) return 'Neapelat';

    switch (status) {
      case ClientStatusType.finalizat:
        return 'Finalizat';
      case ClientStatusType.programat:
        return 'Programat';
      case ClientStatusType.amanat:
        return 'Amanat';
      case ClientStatusType.nuRaspunde:
        return 'Nu răspunde';
      case ClientStatusType.neapelat:
        return 'Neapelat';
    }
  }

  /// Get status color
  Color _getStatusColor(ClientStatusType? status) {
    if (status == null) return AppTheme.backgroundColor1; // Default for null status

    switch (status) {
      case ClientStatusType.finalizat:
        return AppTheme.primaryColor3;
      case ClientStatusType.programat:
        return AppTheme.primaryColor5;
      case ClientStatusType.amanat:
        return AppTheme.primaryColor1;
      case ClientStatusType.nuRaspunde:
        return AppTheme.primaryColor9;
      case ClientStatusType.neapelat:
        return AppTheme.primaryColor7;
    }
  }

  /// Get status stroke color (secondary color)
  Color _getStatusStrokeColor(ClientStatusType? status) {
    if (status == null) return AppTheme.backgroundColor2; // Default for null status

    switch (status) {
      case ClientStatusType.finalizat:
        return AppTheme.secondaryColor3;
      case ClientStatusType.programat:
        return AppTheme.secondaryColor5;
      case ClientStatusType.amanat:
        return AppTheme.secondaryColor1;
      case ClientStatusType.nuRaspunde:
        return AppTheme.secondaryColor9;
      case ClientStatusType.neapelat:
        return AppTheme.secondaryColor7;
    }
  }

  /// Build table content
  Widget _buildTableContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_filteredClients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/user_outlined.svg',
              width: 64,
              height: 64,
              colorFilter: ColorFilter.mode(
                AppTheme.elementColor2,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nu au fost gasiti clienti',
              style: TextStyle(
                color: AppTheme.elementColor1,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          // Table header row
          _buildTableHeaderRow(),

          // Table body
          Expanded(child: _buildTableBody()),
        ],
      ),
    );
  }

  /// Build table header row
  Widget _buildTableHeaderRow() {
    return Container(
      width: double.infinity,
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 4,
        children: [
          // Nr.
          SizedBox(
            width: 56,
            height: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                Text(
                  'Nr.',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF938F8A),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _sortClients('nr'),
                    child: Container(
                      width: 24,
                      height: 24,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(),
                      child: SvgPicture.asset(
                        'assets/caret_outlined.svg',
                        colorFilter: ColorFilter.mode(
                          _getSortIndicatorColor('nr'),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Nume
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 184),
              child: SizedBox(
                height: double.infinity,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      'Nume',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF938F8A),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _sortClients('nume'),
                        child: Container(
                          width: 24,
                          height: 24,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: SvgPicture.asset(
                            'assets/caret_outlined.svg',
                            colorFilter: ColorFilter.mode(
                              _getSortIndicatorColor('nume'),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Numar telefon
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 144, maxWidth: 184),
            child: SizedBox(
              height: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Numar telefon',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF938F8A),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Numar telefon 2
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 144, maxWidth: 184),
            child: SizedBox(
              height: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Numar telefon 2',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF938F8A),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Varsta
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 104, maxWidth: 144),
            child: SizedBox(
              height: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    'Varsta',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF938F8A),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _sortClients('varsta'),
                      child: Container(
                        width: 24,
                        height: 24,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: SvgPicture.asset(
                          'assets/caret_outlined.svg',
                          colorFilter: ColorFilter.mode(
                            _getSortIndicatorColor('varsta'),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),



          // Codebitor
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 144, maxWidth: 184),
            child: SizedBox(
              height: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Codebitor',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF938F8A),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),



          // Status
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 144, maxWidth: 184),
            child: SizedBox(
              height: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    'Status',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF938F8A),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _sortClients('status'),
                      child: Container(
                        width: 24,
                        height: 24,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: SvgPicture.asset(
                          'assets/caret_outlined.svg',
                          colorFilter: ColorFilter.mode(
                            _getSortIndicatorColor('status'),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Actiuni
          SizedBox(
            width: 84,
            child: SizedBox(
              height: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Actiuni',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF938F8A),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build table body with client rows
  Widget _buildTableBody() {
    return ListView.separated(
      controller: _tableScrollController,
      itemCount: _filteredClients.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final client = _filteredClients[index];
        return _buildClientRow(client, index + 1);
      },
    );
  }

  /// Build individual client row
  Widget _buildClientRow(Client client, int rowNumber) {
    final isSelected = _selectedClient?.phoneNumber1 == client.phoneNumber1;

    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: ShapeDecoration(
        color: isSelected ? const Color(0xFFEBEAE9) : AppTheme.backgroundColor2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: isSelected ? [
          BoxShadow(
            color: const Color(0x14503E29),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          )
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          // Nr.
          Container(
            width: 56,
            height: double.infinity,
            decoration: ShapeDecoration(
              color: AppTheme.backgroundColor3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                                  Text(
                    rowNumber.toString(),
                    style: GoogleFonts.outfit(
                      color: AppTheme.elementColor3,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          // Nume
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 184),
            child: Container(
              height: double.infinity,
              decoration: ShapeDecoration(
                color: AppTheme.backgroundColor3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    client.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: AppTheme.elementColor3,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Numar telefon
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 144, maxWidth: 184),
            child: Container(
              height: double.infinity,
              decoration: ShapeDecoration(
                color: AppTheme.backgroundColor3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    client.phoneNumber1,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: AppTheme.elementColor3,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Numar telefon 2
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 144, maxWidth: 184),
            child: Container(
              height: double.infinity,
              decoration: ShapeDecoration(
                color: AppTheme.backgroundColor3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    client.phoneNumber2 ?? '',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: AppTheme.elementColor3,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Varsta
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 104, maxWidth: 144),
            child: Container(
              height: double.infinity,
              decoration: ShapeDecoration(
                color: AppTheme.backgroundColor3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    client.age ?? '',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: AppTheme.elementColor3,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),



          // Codebitor
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 144, maxWidth: 184),
            child: Container(
              height: double.infinity,
              decoration: ShapeDecoration(
                color: AppTheme.backgroundColor3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    client.coDebitorName ?? '',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: AppTheme.elementColor3,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),



          // Status
          GestureDetector(
            onTap: () => _showStatusSelectionPopup(client),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 144, maxWidth: 184),
                child: Container(
                  height: double.infinity,
                  decoration: ShapeDecoration(
                    color: _getStatusColor(client.status),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 4,
                        color: _getStatusStrokeColor(client.status),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _getStatusDisplayName(client.status),
                        style: GoogleFonts.outfit(
                          color: AppTheme.elementColor3,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Actiuni
          SizedBox(
            width: 84,
            height: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 4,
              children: [
                // Form button - deschide formularul complet
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _switchToFormMode(client),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: ShapeDecoration(
                        color: AppTheme.backgroundColor3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/form_outlined.svg',
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              AppTheme.elementColor2,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Edit button
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                  onTap: () => _switchToEditMode(client),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: ShapeDecoration(
                      color: AppTheme.backgroundColor3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/edit_outlined.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            AppTheme.elementColor2,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                ),


              ],
            ),
          ),
        ],
      ),
    );
  }



  /// Build edit mode
  Widget _buildEditMode() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: AppTheme.backgroundColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          WidgetHeader2(
            title: _editingClient != null ? 'Editeaza client' : 'Adauga client',
            altText: 'Inapoi',
            onAltTextTap: _switchToTableMode,
          ),

          const SizedBox(height: 16),

          // Form content
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: AppTheme.backgroundColor2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name field
                  InputField1(
                    title: 'Nume client',
                    hintText: 'Introdu numele clientului',
                    controller: _nameController,
                    minWidth: 200,
                  ),

                  const SizedBox(height: 16),

                  // Phone 1 field
                  InputField1(
                    title: 'Numar telefon 1',
                    hintText: 'Introdu primul numar de telefon',
                    controller: _phoneController1,
                    keyboardType: TextInputType.phone,
                    minWidth: 200,
                  ),

                  const SizedBox(height: 16),

                  // Phone 2 field
                  InputField1(
                    title: 'Numar telefon 2 (optional)',
                    hintText: 'Introdu al doilea numar de telefon',
                    controller: _phoneController2,
                    keyboardType: TextInputType.phone,
                    minWidth: 200,
                  ),

                  const SizedBox(height: 16),

                  // Age field
                  InputField1(
                    title: 'Varsta (optional)',
                    hintText: 'Introdu varsta clientului',
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    minWidth: 200,
                  ),

                  const SizedBox(height: 16),

                  // FICO Score field
                  InputField1(
                    title: 'Scor FICO (optional)',
                    hintText: 'Introdu scorul FICO',
                    controller: _ficoScoreController,
                    keyboardType: TextInputType.number,
                    minWidth: 200,
                  ),

                  const SizedBox(height: 16),

                  // Co-debitor checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _hasCoDebitor,
                        onChanged: (value) => setState(() => _hasCoDebitor = value ?? false),
                      ),
                      const Text('Are codebitor'),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Referent checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _hasReferent,
                        onChanged: (value) => setState(() => _hasReferent = value ?? false),
                      ),
                      const Text('Are referent'),
                    ],
                  ),

                  const Spacer(),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ActionButton(
                        text: 'Anuleaza',
                        onTap: _switchToTableMode,
                        borderRadius: AppTheme.borderRadiusSmall,
                        height: 40,
                        textStyle: AppTheme.navigationButtonTextStyle,
                      ),

                      const SizedBox(width: 16),

                      ActionButton(
                        text: 'Salveaza',
                        onTap: _saveClient,
                        borderRadius: AppTheme.borderRadiusSmall,
                        height: 40,
                        textStyle: AppTheme.navigationButtonTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build form mode - complete form for selected client
  Widget _buildFormMode() {
    if (_selectedClient == null) {
      return _buildNoClientSelectedForForm();
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: AppTheme.backgroundColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with back button
          Row(
            children: [
              ActionButton(
                text: 'Inapoi la tabel',
                onTap: _switchToTableMode,
                borderRadius: AppTheme.borderRadiusSmall,
                height: double.infinity,
                textStyle: AppTheme.navigationButtonTextStyle.copyWith(fontSize: 14),
              ),
              const SizedBox(width: 16),
              Text(
                'Formular client: ${_selectedClient!.name}',
                style: GoogleFonts.outfit(
                  color: AppTheme.elementColor2,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Form content
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: AppTheme.backgroundColor2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _buildCompleteFormContent(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build no client selected for form
  Widget _buildNoClientSelectedForForm() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: AppTheme.backgroundColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Niciun client selectat pentru formular',
              style: TextStyle(
                color: AppTheme.elementColor1,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ActionButton(
              text: 'Inapoi la tabel',
              onTap: _switchToTableMode,
              borderRadius: AppTheme.borderRadiusSmall,
              height: 40,
              textStyle: AppTheme.navigationButtonTextStyle,
            ),
          ],
        ),
      ),
    );
  }

  /// Build complete form content with credits and income sections
  Widget _buildCompleteFormContent() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Credits section (left)
        Expanded(
          flex: 10,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: ShapeDecoration(
              color: AppTheme.backgroundColor1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Credits header
                WidgetHeader2(
                  title: 'Credite',
                  altText: 'Vezi codebitor',
                  onAltTextTap: () {
                    // Funcționalitate de toggle între client și codebitor - în dezvoltare
                  },
                ),
                const SizedBox(height: 8),
                // Credits forms list
                Expanded(
                  child: _buildCreditsFormsForFormMode(),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: AppTheme.smallGap),

        // Income section (right)
        Expanded(
          flex: 7,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: ShapeDecoration(
              color: AppTheme.backgroundColor1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Income header
                WidgetHeader2(
                  title: 'Venituri',
                  altText: 'Vezi codebitor',
                  onAltTextTap: () {
                    // Funcționalitate de toggle între client și codebitor - în dezvoltare
                  },
                ),
                const SizedBox(height: 8),
                // Income forms list
                Expanded(
                  child: _buildIncomeFormsForFormMode(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build credits forms for form mode
  Widget _buildCreditsFormsForFormMode() {
    return Center(
      child: Text(
        'Formulare credite - în dezvoltare',
        style: TextStyle(
          color: AppTheme.elementColor1,
          fontSize: 14,
        ),
      ),
    );
  }

  /// Build income forms for form mode
  Widget _buildIncomeFormsForFormMode() {
    return Center(
      child: Text(
        'Formulare venituri - în dezvoltare',
        style: TextStyle(
          color: AppTheme.elementColor1,
          fontSize: 14,
        ),
      ),
    );
  }


}

