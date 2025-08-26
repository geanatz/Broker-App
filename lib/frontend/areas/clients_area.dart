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
  final ClientStatus status;

  Client({
    required this.name,
    required this.phoneNumber1,
    this.phoneNumber2,
    this.coDebitorName,
    this.age,
    this.ficoScore,
    this.hasCoDebitor = false,
    this.hasReferent = false,
    required this.status,
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
      status: model.status,
    );
  }
}

/// Estados del area para determinar qué widgets mostrar
enum ClientsAreaMode {
  table,           // Tabel principal cu clienti
  form,            // Formular complet pentru clientul selectat
  editClient,      // Editare/creare client
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

  // Filtering and sorting
  String _searchQuery = '';
  ClientStatus? _statusFilter;
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
    _filteredClients = _getFilteredClients();

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

  /// Handle search input changes with debouncing
  void _onSearchChanged() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text;
          _filteredClients = _getFilteredClients();
        });
      }
    });
  }

  /// Service change listeners
  void _onClientServiceChanged() {
    if (mounted) {
      setState(() {
        _filteredClients = _getFilteredClients();
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
      status: _editingClient?.status ?? ClientStatus.normal,
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
          status: client.status,
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
          status: client.status,
          category: ClientCategory.apeluri,
          formData: formData,
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
      padding: const EdgeInsets.symmetric(vertical: 16),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
            Expanded(
                child: Container(
                    height: 48,
                    padding: const EdgeInsets.all(8),
                    decoration: ShapeDecoration(
                        color: const Color(0xFFEBEAE9) /* light-blue-background2 */,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                        ),
                    ),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [
                            Expanded(
                                child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: ShapeDecoration(
                                        color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        shadows: [
                                            BoxShadow(
                                                color: Color(0x0C503E29),
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                                spreadRadius: 0,
                                            )
                                        ],
                                    ),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                            SizedBox(
                                                width: 280,
                                                height: 32,
                                                child: TextField(
                                                  controller: _searchController,
                                                  textAlign: TextAlign.start,
                                                  decoration: InputDecoration(
                                                    hintText: 'Cauta...',
                                                    hintStyle: GoogleFonts.outfit(
                                                      color: const Color(0xFF938F8A),
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    border: InputBorder.none,
                                                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                                    isDense: true,
                                                  ),
                                                  style: GoogleFonts.outfit(
                                                    color: const Color(0xFF938F8A),
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                            ),
                                            Container(
                                                width: 24,
                                                height: 24,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(),
                                                child: Stack(),
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
            Container(
                height: 48,
                padding: const EdgeInsets.all(8),
                decoration: ShapeDecoration(
                    color: const Color(0xFFEBEAE9) /* light-blue-background2 */,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                    ),
                ),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 8,
                    children: [
                        // Add client button
                        GestureDetector(
                          onTap: () => _switchToEditMode(),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              shadows: [
                                BoxShadow(
                                  color: Color(0x14503E29),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                  spreadRadius: 0,
                                )
                              ],
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
                                    color: const Color(0xFF938F8A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Image button (no functionality)
                        Container(
                          width: 32,
                          height: 32,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF0EFEF) /* light-blue-background3 */,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            shadows: [
                              BoxShadow(
                                color: Color(0x14503E29),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                                spreadRadius: 0,
                              )
                            ],
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
                                  'assets/image_outlined.svg',
                                  color: const Color(0xFF938F8A),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                ),
            ),
        ],
      ),
    );
  }





  /// Get display name for status
  String _getStatusDisplayName(ClientStatus status) {
    switch (status) {
      case ClientStatus.focused:
        return 'Focusat';
      case ClientStatus.normal:
        return 'Normal';
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
      height: 48,
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          // Nr.
          SizedBox(
            width: 56,
            height: 32,
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
                Container(
                  width: 24,
                  height: 24,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: SvgPicture.asset(
                    'assets/caret_outlined.svg',
                    colorFilter: ColorFilter.mode(
                      const Color(0xFF938F8A),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Nume
          Expanded(
            child: SizedBox(
              height: 32,
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
                  Container(
                    width: 24,
                    height: 24,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: SvgPicture.asset(
                      'assets/caret_outlined.svg',
                      colorFilter: ColorFilter.mode(
                        const Color(0xFF938F8A),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Numar telefon
          Expanded(
            child: SizedBox(
              height: 32,
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
          Expanded(
            child: SizedBox(
              height: 32,
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
          Expanded(
            child: SizedBox(
              height: 32,
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
                  Container(
                    width: 24,
                    height: 24,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: SvgPicture.asset(
                      'assets/caret_outlined.svg',
                      colorFilter: ColorFilter.mode(
                        const Color(0xFF938F8A),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scor FICO
          Expanded(
            child: SizedBox(
              height: 32,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    'Scor FICO',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF938F8A),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: SvgPicture.asset(
                      'assets/caret_outlined.svg',
                      colorFilter: ColorFilter.mode(
                        const Color(0xFF938F8A),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Codebitor
          Expanded(
            child: SizedBox(
              height: 32,
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

          // Referent
          Expanded(
            child: SizedBox(
              height: 32,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Referent',
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
          Expanded(
            child: SizedBox(
              height: 32,
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
                  Container(
                    width: 24,
                    height: 24,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: SvgPicture.asset(
                      'assets/caret_outlined.svg',
                      colorFilter: ColorFilter.mode(
                        const Color(0xFF938F8A),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Actiuni
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: 88), // 72 (text) + 24 - 8 = 88
            child: SizedBox(
              height: 32,
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
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: isSelected ? const Color(0xFFEBEAE9) : AppTheme.backgroundColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          // Nr.
          Container(
            width: 56,
            height: 32,
            decoration: ShapeDecoration(
              color: AppTheme.backgroundColor3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          Expanded(
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: ShapeDecoration(
                color: AppTheme.backgroundColor3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
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
          Expanded(
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: ShapeDecoration(
                color: AppTheme.backgroundColor3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.phoneNumber1,
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
          Expanded(
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: ShapeDecoration(
                color: AppTheme.backgroundColor3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.phoneNumber2 ?? '',
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
          Expanded(
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: ShapeDecoration(
                color: AppTheme.backgroundColor3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.age ?? '',
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

          // Scor FICO
          Expanded(
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: ShapeDecoration(
                color: AppTheme.backgroundColor3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.ficoScore ?? '',
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
          Expanded(
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: ShapeDecoration(
                color: AppTheme.backgroundColor3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: ShapeDecoration(
                        color: client.hasCoDebitor ? AppTheme.elementColor2 : AppTheme.backgroundColor2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Da',
                            style: GoogleFonts.outfit(
                              color: client.hasCoDebitor ? AppTheme.elementColor3 : AppTheme.elementColor1,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Nu',
                            style: GoogleFonts.outfit(
                              color: !client.hasCoDebitor ? AppTheme.elementColor2 : AppTheme.elementColor1,
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
            ),
          ),

          // Referent
          Expanded(
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: ShapeDecoration(
                color: AppTheme.backgroundColor3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: ShapeDecoration(
                        color: client.hasReferent ? AppTheme.elementColor2 : AppTheme.backgroundColor2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Da',
                            style: GoogleFonts.outfit(
                              color: client.hasReferent ? AppTheme.elementColor3 : AppTheme.elementColor1,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Nu',
                            style: GoogleFonts.outfit(
                              color: !client.hasReferent ? AppTheme.elementColor2 : AppTheme.elementColor1,
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
            ),
          ),

          // Status
          Expanded(
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: ShapeDecoration(
                color: AppTheme.backgroundColor3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 4,
                children: [
                  Expanded(
                    child: Container(
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: ShapeDecoration(
                        color: _getStatusColor(client.status),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
                ],
              ),
            ),
          ),

          // Actiuni
          SizedBox(
            height: 32,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                // Form button - deschide formularul complet
                GestureDetector(
                  onTap: () => _switchToFormMode(client),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset(
                      'assets/form_outlined.svg',
                      colorFilter: ColorFilter.mode(
                        AppTheme.elementColor2,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),

                // Edit button
                GestureDetector(
                  onTap: () => _switchToEditMode(client),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset(
                      'assets/edit_outlined.svg',
                      colorFilter: ColorFilter.mode(
                        AppTheme.elementColor1,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),

                // Delete button
                GestureDetector(
                  onTap: () => _deleteClient(client),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset(
                      'assets/delete_outlined.svg',
                      colorFilter: ColorFilter.mode(
                        AppTheme.elementColor1,
                        BlendMode.srcIn,
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

  /// Get status color
  Color _getStatusColor(ClientStatus status) {
    switch (status) {
      case ClientStatus.focused:
        return AppTheme.elementColor2; // Primary color for focused
      case ClientStatus.normal:
        return AppTheme.backgroundColor2; // Default gray
    }
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
                height: 32,
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
            padding: const EdgeInsets.all(8),
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
                    // TODO: Toggle between client and coborrower credits
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
            padding: const EdgeInsets.all(8),
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
                    // TODO: Toggle between client and coborrower income
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
    // TODO: Implement complete credits forms similar to FormArea
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
    // TODO: Implement complete income forms similar to FormArea
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
