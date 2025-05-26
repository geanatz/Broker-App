import 'package:flutter/material.dart';
import '../common/appTheme.dart';
import '../common/components/headers/widgetHeader1.dart';
import '../common/components/items/darkItem7.dart';
import '../common/components/items/lightItem7.dart';
import '../common/models/client_model.dart';
import '../common/services/client_service.dart';

/// ClientsPane - Interfața pentru gestionarea apelurilor clienților
/// 
/// Această interfață este împărțită în 3 secțiuni:
/// 1. Apeluri - toate apelurile active
/// 2. Reveniri - apelurile care sună ocupat sau sunt amânate
/// 3. Recente - apelurile respinse sau finalizate cu succes
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
      return Expanded(
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

    return Expanded(
      child: Container(
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
  Widget _buildSection(String title, ClientCategory category) {
    return Expanded(
      child: Container(
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
            WidgetHeader1(title: title),
            
            SizedBox(height: AppTheme.smallGap),
            
            // Lista de clienți pentru această categorie
            _buildClientsList(category),
          ],
        ),
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
          // Secțiunea Apeluri
          _buildSection('Apeluri', ClientCategory.apeluri),
          
          SizedBox(height: AppTheme.mediumGap),
          
          // Secțiunea Reveniri
          _buildSection('Reveniri', ClientCategory.reveniri),
          
          SizedBox(height: AppTheme.mediumGap),
          
          // Secțiunea Recente
          _buildSection('Recente', ClientCategory.recente),
        ],
      ),
    );
  }
}
