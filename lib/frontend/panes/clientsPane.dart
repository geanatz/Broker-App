import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../common/appTheme.dart';
import '../common/components/headers/widgetHeader2.dart';
import '../common/components/headers/widgetHeader3.dart';
import '../common/components/items/darkItem7.dart';
import '../common/components/items/lightItem7.dart';
import '../../backend/models/client_model.dart';
import '../common/services/client_service.dart';
import '../popups/statusPopup.dart';

/// ClientsPane - Interfața pentru gestionarea apelurilor clienților
/// 
/// Această interfață este împărțită în 3 secțiuni:
/// 1. Apeluri - toate apelurile active (FILL - nu se poate collapse)
/// 2. Reveniri - apelurile care sună ocupat sau sunt amânate (HUG - se poate collapse)
/// 3. Recente - apelurile respinse sau finalizate cu succes (HUG - se poate collapse)
/// 
/// Logica de focus:
/// - LightItem7: starea normală (viewIcon)
/// - DarkItem7: starea focusată (doneIcon)
class ClientsPane extends StatefulWidget {
  /// Callback pentru deschiderea popup-ului de clienți
  final VoidCallback? onClientsPopupRequested;

  const ClientsPane({
    super.key,
    this.onClientsPopupRequested,
  });

  @override
  State<ClientsPane> createState() => _ClientsPaneState();
}

class _ClientsPaneState extends State<ClientsPane> {
  final ClientService _clientService = ClientService();
  
  // Stări pentru collapse/expand secțiuni (doar pentru Reveniri și Recente)
  bool _isReveniriCollapsed = false;
  bool _isRecenteCollapsed = false;

  @override
  void initState() {
    super.initState();
    // Inițializează datele demo dacă nu există clienți
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

  /// Construiește lista de clienți pentru o anumită categorie
  Widget _buildClientsList(ClientCategory category) {
    final clients = _clientService.getClientsByCategory(category);
    
    if (clients.isEmpty) {
      return SizedBox(
        height: 60, // Înălțime fixă pentru mesajul de empty state
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

    // Pentru secțiunea Apeluri (care e Expanded), folosim ListView normal
    // Pentru Reveniri și Recente (care sunt HUG), folosim ListView cu shrinkWrap
    final bool isApeluri = category == ClientCategory.apeluri;
    
    if (isApeluri) {
      return ListView.separated(
        itemCount: clients.length,
        separatorBuilder: (context, index) => SizedBox(height: AppTheme.smallGap),
        itemBuilder: (context, index) => _buildClientItem(clients[index]),
      );
    } else {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: clients.length,
        separatorBuilder: (context, index) => SizedBox(height: AppTheme.smallGap),
        itemBuilder: (context, index) => _buildClientItem(clients[index]),
      );
    }
  }

  /// Construiește un item pentru un client
  Widget _buildClientItem(ClientModel client) {
    final bool isFocused = client.status == ClientStatus.focused;
    
    // Determină ce să afișeze ca descriere
    String description;
    if (client.category == ClientCategory.reveniri && client.scheduledDateTime != null) {
      // Pentru clienții amânați, afișează data și ora
      description = DateFormat('dd/MM/yy HH:mm').format(client.scheduledDateTime!);
    } else {
      // Pentru ceilalți clienți, afișează numărul de telefon
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

  /// Afișează popup-ul pentru salvarea statusului clientului
  void _showClientSavePopup(ClientModel client) {
    showDialog(
      context: context,
      builder: (context) => ClientSavePopup(
        client: client,
        onSaved: () {
          // Refresh UI sau alte acțiuni după salvare
          setState(() {});
        },
      ),
    );
  }

  /// Construiește o secțiune (Apeluri, Reveniri, Recente)
  Widget _buildSection(String title, ClientCategory category, {bool canCollapse = true}) {
    // Determină starea de collapse pentru această secțiune
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
    
    // Pentru secțiunea Apeluri (care e Expanded), folosim o structură special adaptată
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
          ? Column(
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
                
                // Lista de clienți expandabilă pentru Apeluri
                Expanded(child: _buildClientsList(category)),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header pentru Reveniri și Recente
                WidgetHeader3(
                  title: title,
                  trailingIcon: isCollapsed ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  onTrailingIconTap: toggleCallback,
                ),
                
                if (!isCollapsed) ...[
                  SizedBox(height: AppTheme.smallGap),
                  
                  // Lista de clienți pentru Reveniri și Recente
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
          // Secțiunea Apeluri - FILL (expandează să ocupe tot spațiul disponibil)
          Expanded(
            child: _buildSection('Apeluri', ClientCategory.apeluri, canCollapse: false),
          ),
          
          SizedBox(height: AppTheme.mediumGap),
          
          // Secțiunea Reveniri - HUG (doar cât îi trebuie)
          _buildSection('Reveniri', ClientCategory.reveniri),
          
          SizedBox(height: AppTheme.mediumGap),
          
          // Secțiunea Recente - HUG (doar cât îi trebuie)
          _buildSection('Recente', ClientCategory.recente),
        ],
      ),
    );
  }

  /// Inițializează clienții async
  Future<void> _initializeClients() async {
    if (_clientService.clients.isEmpty) {
      await _clientService.initializeDemoData();
    }
  }
}
