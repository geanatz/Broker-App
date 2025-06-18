import '../../app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/headers/widget_header2.dart';
import '../components/headers/widget_header3.dart';
import '../components/items/dark_item7.dart';
import '../components/items/light_item7.dart';
import '../../backend/services/clients_service.dart';
import '../../backend/services/splash_service.dart';

import '../popups/status_popup.dart';

/// ClientsPane - Interfata pentru gestionarea apelurilor clientilor
/// 
/// Aceasta interfata este impartita in 3 sectiuni:
/// 1. Apeluri - toate apelurile active (FILL - nu se poate collapse)
/// 2. Reveniri - apelurile care suna ocupat sau sunt amanate (HUG - se poate collapse)
/// 3. Recente - apelurile respinse sau finalizate cu succes (HUG - se poate collapse)
/// 
/// Logica de focus:
/// - LightItem7: starea normala (viewIcon)
/// - DarkItem7: starea focusata (doneIcon)
class ClientsPane extends StatefulWidget {
  /// Callback pentru deschiderea popup-ului de clienti
  final VoidCallback? onClientsPopupRequested;

  const ClientsPane({
    super.key,
    this.onClientsPopupRequested,
  });

  @override
  State<ClientsPane> createState() => _ClientsPaneState();
}

class _ClientsPaneState extends State<ClientsPane> {
  late final ClientUIService _clientService;
  
  // Stari pentru collapse/expand sectiuni (doar pentru Reveniri si Recente)
  bool _isReveniriCollapsed = false;
  bool _isRecenteCollapsed = false;

  @override
  void initState() {
    super.initState();
    // Foloseste serviciul pre-incarcat din splash
    _clientService = SplashService().clientUIService;
    
    // Initializeaza datele demo daca nu exista clienti
    _initializeClients();
    _clientService.addListener(_onClientServiceChanged);
  }

  @override
  void dispose() {
    _clientService.removeListener(_onClientServiceChanged);
    super.dispose();
  }

  void _onClientServiceChanged() {
    // Defer setState until after the current frame to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  /// Construieste lista de clienti pentru o anumita categorie
  Widget _buildClientsList(ClientCategory category) {
    final clients = _clientService.getClientsByCategory(category);
    
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
      // Pentru sectiunea Apeluri (care e Expanded), folosim ListView normal
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
    
    // Determina ce sa afiseze ca descriere
    String description;
    if (client.category == ClientCategory.reveniri && client.scheduledDateTime != null) {
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
        svgAsset: 'assets/doneIcon.svg',
        onTap: () => _showClientSavePopup(client),
        onIconTap: () => _showClientSavePopup(client),
      );
    } else {
      return LightItem7(
        title: client.name,
        description: description,
        svgAsset: 'assets/viewIcon.svg',
        onTap: () => _clientService.focusClient(client.id),
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

  /// Construieste o sectiune (Apeluri, Reveniri, Recente)
  Widget _buildSection(String title, ClientCategory category, {bool canCollapse = true}) {
    // Determina starea de collapse pentru aceasta sectiune
    bool isCollapsed = false;
    VoidCallback? toggleCallback;
    
    if (canCollapse) {
      switch (category) {
        case ClientCategory.reveniri:
          isCollapsed = _isReveniriCollapsed;
          toggleCallback = () => setState(() => _isReveniriCollapsed = !_isReveniriCollapsed);
          break;
        case ClientCategory.recente:
          isCollapsed = _isRecenteCollapsed;
          toggleCallback = () => setState(() => _isRecenteCollapsed = !_isRecenteCollapsed);
          break;
        case ClientCategory.apeluri:
          // Apeluri nu se poate collapse
          break;
      }
    }
    
    // Pentru sectiunea Apeluri (care e Expanded), folosim o structura special adaptata
    final bool isApeluri = category == ClientCategory.apeluri;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppTheme.widgetBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        shadows: [AppTheme.widgetShadow],
      ),
      child: isApeluri 
          ? Expanded(
            child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header pentru Apeluri
                  WidgetHeader2(
                    title: title,
                    altText: 'Editeaza',
                    onAltTextTap: widget.onClientsPopupRequested,
                  ),
                  
                  SizedBox(height: AppTheme.smallGap),
                  
                  // Lista de clienti expandabila pentru Apeluri
                  Expanded(child: _buildClientsList(category)),
                ],
              ),
          )
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header pentru Reveniri si Recente
                WidgetHeader3(
                  title: title,
                  trailingIcon: isCollapsed ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  onTrailingIconTap: toggleCallback,
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
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sectiunea Apeluri - FILL (expandeaza sa ocupe tot spatiul disponibil)
          Expanded(
            child: _buildSection('Apeluri', ClientCategory.apeluri, canCollapse: false),
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
}
