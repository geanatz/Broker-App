import 'package:flutter/material.dart';
import '../common/components/headers/widgetHeader1.dart';
import '../common/components/items/lightItem3.dart';
import '../common/components/items/darkItem3.dart';
import '../common/components/buttons/flexButtons3.dart';
import '../common/components/buttons/flexButtons2.dart';
import '../common/components/buttons/flexButtons1.dart';
import '../common/components/fields/inputField1.dart';
import '../common/appTheme.dart';

/// Client model to represent client data
class Client {
  final String name;
  final String phoneNumber;
  final String? coDebitorName;
  final String? coDebitorPhone;

  Client({
    required this.name, 
    required this.phoneNumber,
    this.coDebitorName,
    this.coDebitorPhone,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Client &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.coDebitorName == coDebitorName &&
        other.coDebitorPhone == coDebitorPhone;
  }
  
  @override
  int get hashCode {
    return Object.hash(name, phoneNumber, coDebitorName, coDebitorPhone);
  }
}

/// First popup widget for displaying the client list
class ClientsPopup1 extends StatefulWidget {
  /// List of clients to display
  final List<Client> clients;

  /// Callback when "Add Client" button is tapped
  final VoidCallback? onAddClient;

  /// Callback when "Extract Clients" button is tapped
  final VoidCallback? onExtractClients;

  /// Callback when "Delete All Clients" button is tapped
  final VoidCallback? onDeleteAllClients;

  /// Callback when a client is selected
  final Function(Client)? onClientSelected;

  /// Callback when a client is double-tapped for editing
  final Function(Client)? onEditClient;

  /// Currently selected client
  final Client? selectedClient;

  const ClientsPopup1({
    super.key,
    required this.clients,
    this.onAddClient,
    this.onExtractClients,
    this.onDeleteAllClients,
    this.onClientSelected,
    this.onEditClient,
    this.selectedClient,
  });

  @override
  State<ClientsPopup1> createState() => _ClientsPopup1State();
}

class _ClientsPopup1State extends State<ClientsPopup1> {
  
  Widget _buildBottomButtonsRow() {
    return FlexButtonWithTwoTrailingIcons(
      primaryButtonText: "Adauga client",
      primaryButtonIconPath: "assets/addIcon.svg",
      trailingIcon1Path: "assets/imageIcon.svg",
      trailingIcon2Path: "assets/deleteIcon.svg",
      onPrimaryButtonTap: widget.onAddClient,
      onTrailingIcon1Tap: widget.onExtractClients,
      onTrailingIcon2Tap: widget.onDeleteAllClients,
      spacing: AppTheme.smallGap,
      borderRadius: AppTheme.borderRadiusMedium,
      buttonHeight: 48.0,
      primaryButtonTextStyle: AppTheme.navigationButtonTextStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 360, minHeight: 432),
      child: Container(
        width: 360,
        height: 432,
        padding: const EdgeInsets.all(AppTheme.smallGap),
        decoration: ShapeDecoration(
          color: AppTheme.popupBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded content area
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const WidgetHeader1(title: "Lista clienti"),
                    
                    const SizedBox(height: AppTheme.smallGap),
                    
                    // Client list
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: widget.clients.isEmpty
                            ? Center(
                                child: Text(
                                  'Nu exista clienti in lista',
                                  style: TextStyle(
                                    color: AppTheme.elementColor1,
                                    fontSize: AppTheme.fontSizeMedium,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: widget.clients.length,
                                separatorBuilder: (context, index) => 
                                    const SizedBox(height: AppTheme.smallGap),
                                itemBuilder: (context, index) {
                                  final client = widget.clients[index];
                                  final isSelected = widget.selectedClient == client;
                                  
                                  if (isSelected) {
                                    return DarkItem3(
                                      title: client.name,
                                      description: client.phoneNumber,
                                      onTap: () => widget.onEditClient?.call(client),
                                    );
                                  } else {
                                    return LightItem3(
                                      title: client.name,
                                      description: client.phoneNumber,
                                      onTap: () {
                                        widget.onClientSelected?.call(client);
                                        // Immediately open edit popup after selection
                                        Future.microtask(() => widget.onEditClient?.call(client));
                                      },
                                    );
                                  }
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.smallGap),
            
            // Bottom buttons
            _buildBottomButtonsRow(),
          ],
        ),
      ),
    );
  }
}

/// Second popup widget for creating/editing clients
class ClientsPopup2 extends StatefulWidget {
  /// The client being edited (null if creating new)
  final Client? editingClient;

  /// Callback when "Save Client" button is tapped
  final Function(Client)? onSaveClient;

  /// Callback when "Delete Client" button is tapped
  final VoidCallback? onDeleteClient;

  const ClientsPopup2({
    super.key,
    this.editingClient,
    this.onSaveClient,
    this.onDeleteClient,
  });

  @override
  State<ClientsPopup2> createState() => _ClientsPopup2State();
}

class _ClientsPopup2State extends State<ClientsPopup2> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _coDebitorNameController;
  late TextEditingController _coDebitorPhoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.editingClient?.name ?? '');
    _phoneController = TextEditingController(text: widget.editingClient?.phoneNumber ?? '');
    _coDebitorNameController = TextEditingController(text: widget.editingClient?.coDebitorName ?? '');
    _coDebitorPhoneController = TextEditingController(text: widget.editingClient?.coDebitorPhone ?? '');
  }

  @override
  void didUpdateWidget(ClientsPopup2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Verifică dacă clientul pentru editare s-a schimbat
    if (oldWidget.editingClient != widget.editingClient) {
      // Actualizează textul din controlleri cu noile valori
      _nameController.text = widget.editingClient?.name ?? '';
      _phoneController.text = widget.editingClient?.phoneNumber ?? '';
      _coDebitorNameController.text = widget.editingClient?.coDebitorName ?? '';
      _coDebitorPhoneController.text = widget.editingClient?.coDebitorPhone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _coDebitorNameController.dispose();
    _coDebitorPhoneController.dispose();
    super.dispose();
  }

  void _saveClient() {
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      // Show error or handle validation
      return;
    }

    final client = Client(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      coDebitorName: _coDebitorNameController.text.trim().isEmpty 
          ? null 
          : _coDebitorNameController.text.trim(),
      coDebitorPhone: _coDebitorPhoneController.text.trim().isEmpty 
          ? null 
          : _coDebitorPhoneController.text.trim(),
    );

    widget.onSaveClient?.call(client);
  }
  
  Widget _buildFormBottomButtonsRow(bool isEditing) {
    if (isEditing) {
      return FlexButtonWithTrailingIcon(
        primaryButtonText: "Salveaza client",
        primaryButtonIconPath: "assets/saveIcon.svg",
        onPrimaryButtonTap: _saveClient,
        trailingIconPath: "assets/deleteIcon.svg",
        onTrailingIconTap: widget.onDeleteClient,
        spacing: AppTheme.smallGap,
        borderRadius: AppTheme.borderRadiusMedium,
        buttonHeight: 48.0,
        primaryButtonTextStyle: AppTheme.navigationButtonTextStyle,
      );
    } else {
      // For new client creation, use FlexButtonSingle
      return FlexButtonSingle(
        text: "Salveaza client",
        iconPath: "assets/saveIcon.svg",
        onTap: _saveClient,
        borderRadius: AppTheme.borderRadiusMedium,
        buttonHeight: 48.0,
        textStyle: AppTheme.navigationButtonTextStyle,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingClient != null;
    
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 296, minHeight: 432),
      child: Container(
        width: 296,
        height: 432,
        padding: const EdgeInsets.all(AppTheme.smallGap),
        decoration: ShapeDecoration(
          color: AppTheme.popupBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded content area
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    WidgetHeader1(
                      title: isEditing ? "Editeaza client" : "Creeaza client",
                    ),
                    
                    const SizedBox(height: AppTheme.smallGap),
                    
                    // Form container
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppTheme.smallGap),
                        decoration: ShapeDecoration(
                          color: AppTheme.containerColor1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Client Name Field
                            InputField1(
                              title: "Nume client",
                              hintText: "Introdu numele clientului",
                              controller: _nameController,
                              minWidth: 128,
                            ),
                            
                            const SizedBox(height: AppTheme.smallGap),
                            
                            // Client Phone Field
                            InputField1(
                              title: "Numar client",
                              hintText: "Introdu numarul clientului",
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              minWidth: 128,
                            ),
                            
                            const SizedBox(height: AppTheme.smallGap),
                            
                            // Co-debitor Name Field
                            InputField1(
                              title: "Nume codebitor",
                              hintText: "Introdu numele codebitorului",
                              controller: _coDebitorNameController,
                              minWidth: 128,
                            ),
                            
                            const SizedBox(height: AppTheme.smallGap),
                            
                            // Co-debitor Phone Field
                            InputField1(
                              title: "Numar codebitor",
                              hintText: "Introdu numarul codebitorului",
                              controller: _coDebitorPhoneController,
                              keyboardType: TextInputType.phone,
                              minWidth: 128,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.smallGap),
            
            // Bottom buttons
            _buildFormBottomButtonsRow(isEditing),
          ],
        ),
      ),
    );
  }
}
