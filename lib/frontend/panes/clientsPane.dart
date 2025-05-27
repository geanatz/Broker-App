import 'package:flutter/material.dart';
import '../common/appTheme.dart';
import '../common/components/headers/widgetHeader1.dart';
import '../common/components/headers/widgetHeader3.dart';
import '../common/components/items/darkItem7.dart';
import '../common/components/items/lightItem7.dart';
import '../common/models/client_model.dart';
import '../common/services/client_service.dart';

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
  const ClientsPane({Key? key}) : super(key: key);

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
    if (_clientService.clients.isEmpty) {
      _clientService.initializeDemoData();
    }
    _clientService.addListener(_onClientServiceChanged);
  }

  @override
  void dispose() {
    _clientService.removeListener(_onClientServiceChanged);
    super.dispose();
  }

  void _onClientServiceChanged() {
    setState(() {});
  }

  /// Construiește lista de clienți pentru o anumită categorie
  Widget _buildClientsList(ClientCategory category) {
    final clients = _clientService.getClientsByCategory(category);
    
    if (clients.isEmpty) {
      return Container(
        height: 60, // Înălțime fixă pentru mesajul de empty state
        child: Center(
          child: Text(
            'Nu există clienți',
            style: TextStyle(
              color: AppTheme.elementColor1,
              fontSize: AppTheme.fontSizeSmall,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < clients.length; i++) ...[
            _buildClientItem(clients[i]),
            if (i < clients.length - 1) SizedBox(height: AppTheme.smallGap),
          ],
        ],
      ),
    );
  }

  /// Construiește un item pentru un client
  Widget _buildClientItem(ClientModel client) {
    final bool isFocused = client.status == ClientStatus.focused;
    
    if (isFocused) {
      return DarkItem7(
        title: client.name,
        description: client.phoneNumber,
        svgAsset: 'assets/doneIcon.svg',
        // Nu facem nimic când se apasă pe darkItem7 (client deja focusat)
      );
    } else {
      return LightItem7(
        title: client.name,
        description: client.phoneNumber,
        svgAsset: 'assets/viewIcon.svg',
        onTap: () => _clientService.focusClient(client.id),
      );
    }
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header pentru secțiune
          if (category == ClientCategory.apeluri)
            // Folosim WidgetHeader1 pentru Apeluri (fără collapse)
            WidgetHeader1(title: title)
          else
            // Folosim WidgetHeader3 pentru Reveniri și Recente (cu collapse)
            WidgetHeader3(
              title: title,
              trailingIcon: isCollapsed ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              onTrailingIconTap: toggleCallback,
            ),
          
          if (!isCollapsed) ...[
            SizedBox(height: AppTheme.smallGap),
            
            // Lista de clienți pentru această categorie
            _buildClientsList(category),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
}
