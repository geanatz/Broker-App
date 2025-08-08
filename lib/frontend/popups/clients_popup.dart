import '../../app_theme.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../components/headers/widget_header1.dart';
import '../components/items/light_item3.dart';
import '../components/items/dark_item3.dart';
import '../components/items/light_item7.dart';
import '../components/items/dark_item7.dart';
import '../components/buttons/flex_buttons1.dart';
import '../components/buttons/flex_buttons2.dart';
import '../components/fields/input_field1.dart';
import '../../backend/services/ocr_service.dart';
import '../../backend/services/clients_service.dart';
import '../../backend/services/splash_service.dart';

/// Client model to represent client data
class Client {
  final String name;
  final String phoneNumber1;
  final String? phoneNumber2;
  final String? coDebitorName;

  Client({
    required this.name, 
    required this.phoneNumber1,
    this.phoneNumber2,
    this.coDebitorName,
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
}

/// Estados del popup para determinar qué widgets mostrar
enum PopupState {
  clientsOnly,           // Solo lista de clientes
  clientsWithEdit,       // Lista de clientes + widget de edición/creación
  ocrOnly,               // Solo widget OCR
  ocrWithClients,        // OCR + Lista de clientes (de la imaginea selectata)
  ocrWithClientsAndEdit, // OCR + Lista + Edición (toate 3)
}

/// Main responsive clients popup widget
class ClientsPopup extends StatefulWidget {
  /// Callback when "Add Client" button is tapped
  final VoidCallback? onAddClient;

  /// Callback when "Extract Clients" button is tapped
  final VoidCallback? onExtractClients;

  /// Callback when "Delete OCR Clients" from selected image is tapped  
  final VoidCallback? onDeleteOcrClients;

  /// Callback when a client is selected
  final Function(Client)? onClientSelected;

  /// Callback when a client is double-tapped for editing
  final Function(Client)? onEditClient;

  /// Callback when a client is saved
  final Function(Client)? onSaveClient;

  /// Callback when a client is deleted
  final void Function(Client client)? onDeleteClient;

  /// Currently selected client
  final Client? selectedClient;

  const ClientsPopup({
    super.key,
    this.onAddClient,
    this.onExtractClients,
    this.onDeleteOcrClients,
    this.onClientSelected,
    this.onEditClient,
    this.onSaveClient,
    this.onDeleteClient,
    this.selectedClient, required List<Client> clients,
  });

  @override
  State<ClientsPopup> createState() => _ClientsPopupState();
}

class _ClientsPopupState extends State<ClientsPopup> {
  PopupState _currentState = PopupState.clientsOnly;
  List<File> _selectedImages = [];
  List<PlatformFile>? _webFiles; // Pentru fisierele selectate pe web
  Map<String, OcrResult>? _ocrResults;
  String? _selectedOcrImagePath;
  bool _isOcrProcessing = false;
  final String _ocrMessage = 'Se pregateste extragerea...';
  final double _ocrProgress = 0.0;
  String? _ocrError;
  Client? _editingClient;
  
  // Service pentru a asculta schimbarile
  late final ClientUIService _clientService;
  // --- FOCUS LOCAL ---
  String? _selectedClientPhoneInPopup;

  @override
  void initState() {
    super.initState();
    _clientService = SplashService().clientUIService;
    _clientService.addListener(_onClientServiceChanged);
    // Nu mai defocusam toti clientii la deschiderea popup-ului!
    // Focusul din pane ramane neatins.
  }

  @override
  void dispose() {
    _clientService.removeListener(_onClientServiceChanged);
    // Sterge clientul temporar la inchiderea popup-ului
    try {
      _clientService.cancelTemporaryClient();
    } catch (_) {}
    super.dispose();
  }

  /// Callback pentru schimbarile in servicea
  void _onClientServiceChanged() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {});
      });
    }
  }

  /// Incepe procesul de creare client cu client temporar
  void _startClientCreation() {
    // Creeaza clientul temporar in service
    final clientService = SplashService().clientUIService;
    clientService.createTemporaryClient();
    
    // Gaseste clientul temporar creat (acum focusat)
    final focusedTempClient = clientService.focusedClient;
    if (focusedTempClient == null) {
      debugPrint('POPUP: Could not focus temporary client after creation');
      return;
    }
    
    setState(() {
      _selectedClientPhoneInPopup = focusedTempClient.phoneNumber;
    });
    // Deschide formularul de editare pentru clientul nou (null = creare noua)
    _openEditClient(null);
  }



  /// Anuleaza procesul OCR
  void _cancelOcrProcess() {
    setState(() {
      _selectedImages = [];
      _webFiles = null;
      _ocrResults = null;
      _isOcrProcessing = false;
      _ocrError = null;
      _selectedOcrImagePath = null;
      _currentState = _editingClient != null ? PopupState.clientsWithEdit : PopupState.clientsOnly;
    });
  }

  /// Salveaza clientii din imaginea selectata in lista principala
  void _saveOcrClients() {
    if (_selectedOcrImagePath != null && _ocrResults != null) {
      final ocrResult = _ocrResults![_selectedOcrImagePath];
      if (ocrResult?.extractedClients != null && ocrResult!.extractedClients!.isNotEmpty) {
        // Converteste UnifiedClientModel la Client si salveaza
        final clientsToSave = ocrResult.extractedClients!.map((contact) => Client(
          name: contact.basicInfo.name,
          phoneNumber1: contact.basicInfo.phoneNumber1,
          phoneNumber2: contact.basicInfo.phoneNumber2,
          coDebitorName: contact.basicInfo.coDebitorName,
        )).toList();
        
        // Notifica parintele despre salvarea clientilor
        for (final client in clientsToSave) {
          widget.onSaveClient?.call(client);
        }
        
        // Afiseaza mesaj de confirmare
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${clientsToSave.length} clienti salvati in lista!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  /// Selecteaza o imagine din rezultatele OCR si afiseaza clientii
  void _selectOcrImage(String imagePath) {
    
            // Image selected successfully
    
    setState(() {
      _selectedOcrImagePath = imagePath;
      _currentState = PopupState.ocrWithClients; // Afiseaza OCR + lista de clienti
    });
  }


  /// Adauga un client nou la lista de clienti extrasi din imaginea selectata
  void _addClientToOcrResults(Client client) {
    if (_selectedOcrImagePath == null || _ocrResults == null) return;
    
    final ocrResult = _ocrResults![_selectedOcrImagePath];
    if (ocrResult == null) return;
    
    // Converteste Client la UnifiedClientModel pentru a-l adauga la rezultatele OCR
    final unifiedClient = UnifiedClientModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID temporar
      consultantId: 'local', // ID consultant temporar
      basicInfo: ClientBasicInfo(
        name: client.name,
        phoneNumber1: client.phoneNumber1,
        phoneNumber2: client.phoneNumber2,
        coDebitorName: client.coDebitorName,
      ),
      formData: const ClientFormData(
        clientCredits: [],
        coDebitorCredits: [],
        clientIncomes: [],
        coDebitorIncomes: [],
        additionalData: {},
      ),
      activities: [],
      currentStatus: const UnifiedClientStatus(
        category: UnifiedClientCategory.clienti,
        isFocused: false,
        additionalInfo: 'Adaugat manual in lista extrasa',
      ),
      metadata: ClientMetadata(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'user',
        source: 'manual_add_ocr',
        version: 1,
      ),
    );
    
    final updatedContacts = List<UnifiedClientModel>.from(ocrResult.extractedClients ?? [])..add(unifiedClient);
    
    setState(() {
      _ocrResults![_selectedOcrImagePath!] = ocrResult.copyWith(extractedClients: updatedContacts);
    });
    
    // Afiseaza mesaj de confirmare
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client adaugat la lista extrasa!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Actualizeaza un client existent in lista de clienti extrasi
  void _updateClientInOcrResults(Client client) {
    if (_selectedOcrImagePath == null || _ocrResults == null) return;
    
    final ocrResult = _ocrResults![_selectedOcrImagePath];
    if (ocrResult == null || ocrResult.extractedClients == null) return;
    
    // Converteste Client la UnifiedClientModel si gaseste indexul
    final unifiedClient = UnifiedClientModel(
       id: DateTime.now().millisecondsSinceEpoch.toString(), // ID temporar
      consultantId: 'local', // ID consultant temporar
      basicInfo: ClientBasicInfo(
        name: client.name,
        phoneNumber1: client.phoneNumber1,
        phoneNumber2: client.phoneNumber2,
        coDebitorName: client.coDebitorName,
      ),
      formData: const ClientFormData(
        clientCredits: [],
        coDebitorCredits: [],
        clientIncomes: [],
        coDebitorIncomes: [],
        additionalData: {},
      ),
      activities: [],
      currentStatus: const UnifiedClientStatus(
        category: UnifiedClientCategory.clienti,
        isFocused: false,
        additionalInfo: 'Modificat manual in lista extrasa',
      ),
      metadata: ClientMetadata(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'user',
        source: 'manual_edit_ocr',
        version: 1,
      ),
    );

    final index = ocrResult.extractedClients!.indexWhere((c) => c.basicInfo.phoneNumber1 == client.phoneNumber1);
    
    if (index != -1) {
      final updatedContacts = List<UnifiedClientModel>.from(ocrResult.extractedClients!);
      updatedContacts[index] = unifiedClient;
      
      setState(() {
        _ocrResults![_selectedOcrImagePath!] = ocrResult.copyWith(extractedClients: updatedContacts);
      });
    }
  }


  /// Gestioneaza click-ul pe item-ul imaginii OCR
  void _handleOcrImageTap(String imagePath) {
            // Image clicked
    
    if (_selectedOcrImagePath == imagePath) {
      // Daca imaginea e deja selectata, afiseaza popup de confirmare pentru salvare
              // Show save dialog for selected image
      _showSaveConfirmationDialog(imagePath);
    } else {
      // Daca imaginea nu e selectata, o selecteaza si afiseaza clientii
              // Select image for client display
      _selectOcrImage(imagePath);
    }
  }

  /// Afiseaza popup de confirmare pentru salvarea clientilor
  void _showSaveConfirmationDialog(String imagePath) {
    final result = _ocrResults![imagePath];
    final clientCount = result?.extractedClients?.length ?? 0;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmare salvare'),
          content: Text('Doresti sa salvezi $clientCount clienti din aceasta imagine in lista principala?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anuleaza'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveAndRemoveOcrImage(imagePath);
              },
              child: const Text('Salveaza'),
            ),
          ],
        );
      },
    );
  }

  /// Salveaza clientii din imagine si sterge item-ul din galerie
  void _saveAndRemoveOcrImage(String imagePath) {
    // Salveaza clientii
    final result = _ocrResults![imagePath];
    if (result?.extractedClients != null && result!.extractedClients!.isNotEmpty) {
      final clientsToSave = result.extractedClients!.map((contact) => Client(
        name: contact.basicInfo.name,
        phoneNumber1: contact.basicInfo.phoneNumber1,
        phoneNumber2: contact.basicInfo.phoneNumber2,
        coDebitorName: contact.basicInfo.coDebitorName,
      )).toList();
      
      // Notifica parintele despre salvarea clientilor
      for (final client in clientsToSave) {
        widget.onSaveClient?.call(client);
      }
      
      // Afiseaza mesaj de confirmare
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${clientsToSave.length} clienti salvati in lista!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
    
    // Sterge imaginea din rezultatele OCR si din lista de imagini selectate
    setState(() {
      _ocrResults!.remove(imagePath);
      _selectedImages.removeWhere((image) => image.path == imagePath);
      
      // Daca era imaginea selectata, reseteaza selectia
      if (_selectedOcrImagePath == imagePath) {
        _selectedOcrImagePath = null;
        // Daca mai sunt imagini, ramane in starea OCR, altfel trece la clientsOnly
        if (_selectedImages.isEmpty) {
          _currentState = PopupState.clientsOnly;
        } else {
          _currentState = PopupState.ocrOnly;
        }
      }
    });
  }


  /// Returneaza lista de clienti de afisat (ori clientii din imaginea OCR selectata, ori toti clientii)
  List<Client> _getClientsToDisplay() {
    if (_selectedOcrImagePath != null && _ocrResults != null) {
      // Afiseaza clientii din imaginea selectata OCR
      final ocrResult = _ocrResults![_selectedOcrImagePath];
      if (ocrResult?.extractedClients != null) {
        // Converteste UnifiedClientModel la Client
        final ocrClients = ocrResult!.extractedClients!.map((contact) => Client(
          name: contact.basicInfo.name,
          phoneNumber1: contact.basicInfo.phoneNumber1,
          phoneNumber2: contact.basicInfo.phoneNumber2,
          coDebitorName: contact.basicInfo.coDebitorName,
        )).toList();
        return ocrClients;
      }
      return [];
    } else {
      // Afiseaza toti clientii din service (inclusiv temporari pentru popup)
      final clientService = SplashService().clientUIService;
      final serviceClients = clientService.clientsWithTemporary;
      // Converteste ClientModel la Client pentru popup
      final popupClients = serviceClients.map((clientModel) => Client(
        name: clientModel.name,
        phoneNumber1: clientModel.phoneNumber1,
        phoneNumber2: clientModel.phoneNumber2,
        coDebitorName: clientModel.coDebitorName,
      )).toList();
      return popupClients;
    }
  }

  /// Deschide widgetul de editare/creare client
  void _openEditClient([Client? client]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _editingClient = client;
        if (_selectedImages.isNotEmpty) {
          _currentState = PopupState.ocrWithClientsAndEdit; // Toate 3 widget-urile
        } else {
          _currentState = PopupState.clientsWithEdit;
        }
      });
    });
  }

  /// Inchide widgetul de editare/creare client
  void _closeEditClient() {
    setState(() {
      _editingClient = null;
      if (_selectedImages.isNotEmpty && _selectedOcrImagePath != null) {
        _currentState = PopupState.ocrWithClients; // Inapoi la OCR + lista
      } else if (_selectedImages.isNotEmpty) {
        _currentState = PopupState.ocrOnly; // Doar OCR
      } else {
        _currentState = PopupState.clientsOnly;
      }
    });
  }

  /// Latimi fixe pentru fiecare tip de widget conform design-urilor
  double get _ocrWidgetWidth => 296;    // clientsPopup3.md & clientsPopup4.md  
  double get _clientsWidgetWidth => 360; // clientsPopup1.md
  double get _editWidgetWidth => 296;    // clientsPopup2.md

  /// Construieste widgetul de extragere OCR
  Widget _buildOcrWidget(double width) {
    // Determina daca acest widget este ultimul (cel mai din dreapta)
    
    return Container(
      width: width,
      height: 432,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: ShapeDecoration(
        color: AppTheme.popupBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
      ),
      child: Column(
        children: [
          // Header
          const WidgetHeader1(title: "Clienti extrasi"),
          
          const SizedBox(height: AppTheme.smallGap),
          
          // Loading/Results area
          Expanded(
            child: _ocrResults != null ? _buildOcrResults() : _buildOcrLoading(),
          ),
          
          const SizedBox(height: AppTheme.smallGap),
          
          // Image gallery
          _ocrResults != null ? _buildOcrResultsGallery() : _buildOcrLoadingGallery(),
          
          const SizedBox(height: AppTheme.smallGap),
          
          // Action button (Cancel/Save)
          _buildOcrActionButton(),
        ],
      ),
    );
  }

  /// Construieste zona de loading OCR
  Widget _buildOcrLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: AppTheme.containerColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_ocrError != null) ...[
            // Error state
            Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 8, color: Colors.red),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Eroare: $_ocrError',
              style: TextStyle(
                color: AppTheme.elementColor2,
                fontSize: 15,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ] else if (_isOcrProcessing) ...[
            // Processing state
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value: _ocrProgress > 0 ? _ocrProgress : null,
                strokeWidth: 3,
                color: AppTheme.elementColor1,
                backgroundColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _ocrMessage,
              style: TextStyle(
                color: AppTheme.elementColor2,
                fontSize: 15,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            // Ready state
            Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 8, color: AppTheme.containerColor1),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _ocrMessage,
              style: TextStyle(
                color: AppTheme.elementColor2,
                fontSize: 15,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Construieste rezultatele OCR cu lightItem7 si darkItem7
  Widget _buildOcrResults() {
    if (_ocrResults == null) return const SizedBox.shrink();

    final sortedResults = _ocrResults!.entries.toList()
      ..sort((a, b) => (b.value.extractedClients?.length ?? 0).compareTo(a.value.extractedClients?.length ?? 0));

    return SizedBox(
      width: double.infinity,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: sortedResults.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final imagePath = sortedResults[i].key;
          final result = sortedResults[i].value;
          final isSelected = _selectedOcrImagePath == imagePath;
          
          // Extracts numele real al imaginii din path
          final fileName = imagePath.split('/').last.split('\\').last;
          final displayName = fileName.length > 15 ? '${fileName.substring(0, 12)}...' : fileName;
          
          if (isSelected) {
            return DarkItem7(
              title: displayName,
              description: '${result.extractedClients?.length ?? 0} clienti',
              svgAsset: 'assets/doneIcon.svg',
              onTap: () => _handleOcrImageTap(imagePath),
            );
          } else {
            return LightItem7(
              title: displayName,
              description: '${result.extractedClients?.length ?? 0} clienti',
              svgAsset: 'assets/viewIcon.svg',
              onTap: () => _handleOcrImageTap(imagePath),
            );
          }
        },
      ),
    );
  }

  /// Construieste galeria pentru loading
  Widget _buildOcrLoadingGallery() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: AppTheme.containerColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < _selectedImages.length; i++) ...[
              Container(
                width: 56,
                height: 56,
                decoration: ShapeDecoration(
                  color: AppTheme.containerColor2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _selectedImages[i],
                    fit: BoxFit.cover,
                    width: 56,
                    height: 56,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image,
                        color: AppTheme.elementColor2,
                        size: 24,
                      );
                    },
                  ),
                ),
              ),
              if (i < _selectedImages.length - 1)
                const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  /// Construieste galeria pentru rezultate
  Widget _buildOcrResultsGallery() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: AppTheme.containerColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < (kIsWeb ? (_webFiles?.length ?? 0) : _selectedImages.length); i++) ...[
              GestureDetector(
                onTap: () => _selectOcrImage(kIsWeb ? (_webFiles![i].name) : _selectedImages[i].path),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: ShapeDecoration(
                    color: AppTheme.containerColor2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Imaginea
                        kIsWeb 
                          ? (_webFiles != null && i < _webFiles!.length && _webFiles![i].bytes != null)
                            ? Image.memory(
                                _webFiles![i].bytes!,
                                fit: BoxFit.cover,
                                width: 56,
                                height: 56,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.image,
                                    color: AppTheme.elementColor2,
                                    size: 24,
                                  );
                                },
                              )
                            : Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppTheme.containerColor1,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.image,
                                  color: AppTheme.elementColor2,
                                  size: 24,
                                ),
                              )
                          : Image.file(
                              _selectedImages[i],
                              fit: BoxFit.cover,
                              width: 56,
                              height: 56,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.image,
                                  color: AppTheme.elementColor2,
                                  size: 24,
                                );
                              },
                            ),
                        // Overlay negru pentru imaginile nefocusate
                        if (kIsWeb 
                            ? (_selectedOcrImagePath != _webFiles![i].name)
                            : (_selectedOcrImagePath != _selectedImages[i].path))
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (i < _selectedImages.length - 1)
                const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  /// Construieste butonul de anulare/salvare OCR
  Widget _buildOcrActionButton() {
    // Dupa extragere, daca o imagine este selectata, afiseaza buton de salvare
    if (_ocrResults != null && _selectedOcrImagePath != null) {
      return FlexButtonSingle(
        text: 'Salveaza clienti',
        iconPath: 'assets/saveIcon.svg',
        onTap: _saveOcrClients,
        borderRadius: AppTheme.borderRadiusMedium,
        buttonHeight: 48.0,
        textStyle: AppTheme.navigationButtonTextStyle,
      );
    } else {
      // In timpul procesarii sau fara imagine selectata, afiseaza buton de anulare
      return FlexButtonSingle(
        text: 'Anuleaza',
        iconPath: 'assets/returnIcon.svg',
        onTap: _cancelOcrProcess,
        borderRadius: AppTheme.borderRadiusMedium,
        buttonHeight: 48.0,
        textStyle: AppTheme.navigationButtonTextStyle,
      );
    }
  }

  /// Construieste widgetul cu lista de clienti
  Widget _buildClientsWidget(double width) {
    // Determina pozitia acestui widget in layout

    return Container(
      width: width,
      height: 432,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: ShapeDecoration(
        color: AppTheme.popupBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            bottomLeft: Radius.circular(32),
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (daca exista)
          const WidgetHeader1(title: "Lista clienti"),
          const SizedBox(height: AppTheme.smallGap),
          // Lista de clienti
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: _getClientsToDisplay().isEmpty
                  ? Center(
                      child: Text(
                        _selectedOcrImagePath != null 
                            ? 'Nu au fost gasiti clienti in aceasta imagine'
                            : 'Nu exista clienti in lista',
                        style: TextStyle(
                          color: AppTheme.elementColor1,
                          fontSize: AppTheme.fontSizeMedium,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _getClientsToDisplay().length,
                      separatorBuilder: (context, index) => 
                          const SizedBox(height: AppTheme.smallGap),
                      itemBuilder: (context, index) {
                        final client = _getClientsToDisplay()[index];
                        final isSelected = _selectedClientPhoneInPopup == client.phoneNumber1;
                        // Daca este client temporar (phoneNumber1 gol) si numele este gol, afiseaza placeholder
                        final isTempClient = client.phoneNumber1.isEmpty && (client.name.isEmpty);
                        final displayName = isTempClient ? 'Client nou' : client.name;
                        if (isSelected) {
                          return DarkItem3(
                            title: displayName,
                            description: client.phoneNumber,
                            onTap: () {
                              _openEditClient(client);
                            },
                          );
                        } else {
                          return LightItem3(
                            title: displayName,
                            description: client.phoneNumber,
                            onTap: () {
                              setState(() {
                                _selectedClientPhoneInPopup = client.phoneNumber1;
                              });
                              _openEditClient(client);
                            },
                          );
                        }
                      },
                    ),
            ),
          ),
          const SizedBox(height: AppTheme.smallGap),
          // Butoane de jos
          _buildBottomButtonsRow(),
        ],
      ),
    );
  }

  /// Construieste widgetul de editare/creare client
  Widget _buildEditClientWidget(double width) {
    return ClientsPopup2(
        editingClient: _editingClient,
        onSaveClient: (client) {
          // Verifica daca suntem in starea OCR cu clienti extrasi
          final bool isInOcrMode = (_currentState == PopupState.ocrWithClientsAndEdit) &&
                                   _selectedOcrImagePath != null;
          
          if (isInOcrMode) {
            // Verifica daca editeaza un client existent sau creeaza unul nou
            if (_editingClient != null) {
              // Editeaza clientul existent din lista OCR
              _updateClientInOcrResults(client);
            } else {
              // Adauga un client nou la lista de clienti extrasi din imaginea selectata
              _addClientToOcrResults(client);
            }
          } else {
            // Salveaza clientul in lista principala
            widget.onSaveClient?.call(client);
          }
          _closeEditClient();
        },
        onDeleteClient: widget.onDeleteClient,
      );
  }

  @override
  Widget build(BuildContext context) {
    // Sincronizez focusul cu backend-ul (daca este necesar)
    
    // Calculate total width based on current state  
    double totalWidth;
    switch (_currentState) {
      case PopupState.clientsOnly:
        totalWidth = 360; // Lista clienti
        break;
      case PopupState.ocrOnly:
        totalWidth = 296; // Widget OCR
        break;
      case PopupState.clientsWithEdit:
        totalWidth = 360 + 296 + 16; // Lista + Editare + gap 16px
        break;
      case PopupState.ocrWithClients:
        totalWidth = 296 + 360 + 16; // OCR + Lista + gap 16px
        break;
      case PopupState.ocrWithClientsAndEdit:
        totalWidth = 296 + 360 + 296 + 2 * 16; // OCR + Lista + Editare + 2 gaps
        break;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: totalWidth, minHeight: 432),
      child: Container(
        width: totalWidth,
        height: 432,
        color: Colors.transparent,
        child: Row(
          children: [
            if (_currentState == PopupState.ocrOnly || 
                _currentState == PopupState.ocrWithClients || 
                _currentState == PopupState.ocrWithClientsAndEdit) ...[
              _buildOcrWidget(_ocrWidgetWidth),
              if (_currentState != PopupState.ocrOnly)
                const SizedBox(width: 16),
            ],
            if (_currentState == PopupState.clientsOnly ||
                _currentState == PopupState.clientsWithEdit ||
                _currentState == PopupState.ocrWithClients ||
                _currentState == PopupState.ocrWithClientsAndEdit) ...[
              _buildClientsWidget(_clientsWidgetWidth),
            ],
            if ((_currentState == PopupState.clientsWithEdit || _currentState == PopupState.ocrWithClientsAndEdit)
                && (_editingClient != null || _clientService.temporaryClient != null)) ...[
              const SizedBox(width: 16),
              _buildEditClientWidget(_editWidgetWidth),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtonsRow() {
    // In starea OCR cu clienti extrasi, afiseaza doar 2 butoane
    final bool isShowingOcrClients = (_currentState == PopupState.ocrWithClients || 
                                      _currentState == PopupState.ocrWithClientsAndEdit) &&
                                     _selectedOcrImagePath != null;
    
    if (isShowingOcrClients) {
      return FlexButtonSingle(
        text: "Adauga client",
        iconPath: "assets/addIcon.svg",
        onTap: () => _startClientCreation(),
        borderRadius: AppTheme.borderRadiusMedium,
        buttonHeight: 48.0,
        textStyle: AppTheme.navigationButtonTextStyle,
      );
    } else {
      // In lista de contacte reala, afiseaza doar butonul de adaugare
      return FlexButtonSingle(
        text: "Adauga client",
        iconPath: "assets/addIcon.svg",
        onTap: () => _startClientCreation(),
        borderRadius: AppTheme.borderRadiusMedium,
        buttonHeight: 48.0,
        textStyle: AppTheme.navigationButtonTextStyle,
      );
    }
  }
}

/// Second popup widget for creating/editing clients
class ClientsPopup2 extends StatefulWidget {
  /// The client being edited (null if creating new)
  final Client? editingClient;

  /// Callback when "Save Client" button is tapped
  final Function(Client)? onSaveClient;

  /// Callback when "Delete Client" button is tapped
  final void Function(Client client)? onDeleteClient;

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
  late TextEditingController _phoneController1;
  late TextEditingController _phoneController2;
  late TextEditingController _coDebitorNameController;

  // Adaug un ValueNotifier pentru a notifica parintele la modificari live
  ValueNotifier<int>? _liveUpdateNotifier;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.editingClient?.name ?? '');
    _phoneController1 = TextEditingController(text: widget.editingClient?.phoneNumber1 ?? '');
    _phoneController2 = TextEditingController(text: widget.editingClient?.phoneNumber2 ?? '');
    _coDebitorNameController = TextEditingController(text: widget.editingClient?.coDebitorName ?? '');
    // Add listeners for live updates to temporary client
    _nameController.addListener(_onFormChanged);
    _phoneController1.addListener(_onFormChanged);
    _phoneController2.addListener(_onFormChanged);
    _coDebitorNameController.addListener(_onFormChanged);
    // Notificare live update
    _liveUpdateNotifier = ValueNotifier<int>(0);
  }

  @override
  void didUpdateWidget(ClientsPopup2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Verifica daca clientul pentru editare s-a schimbat
    if (oldWidget.editingClient != widget.editingClient) {
      // Actualizeaza textul din controlleri cu noile valori
      _nameController.text = widget.editingClient?.name ?? '';
      _phoneController1.text = widget.editingClient?.phoneNumber1 ?? '';
      _phoneController2.text = widget.editingClient?.phoneNumber2 ?? '';
      _coDebitorNameController.text = widget.editingClient?.coDebitorName ?? '';
    }
  }

  /// Update temporary client as user types
  void _onFormChanged() {
    // Update if we're creating a new client (editingClient is null)
    if (widget.editingClient == null) {
      final clientService = SplashService().clientUIService;
      clientService.updateTemporaryClient(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController1.text.trim(),
        phoneNumber2: _phoneController2.text.trim().isEmpty 
            ? null 
            : _phoneController2.text.trim(),
        coDebitorName: _coDebitorNameController.text.trim().isEmpty 
            ? null 
            : _coDebitorNameController.text.trim(),
      );
      // Notifica parintele ca s-a modificat formularul (pentru rebuild live)
      if (_liveUpdateNotifier != null) {
        _liveUpdateNotifier!.value++;
      }
      // DEBUG LOG
      debugPrint('[ClientsPopup2] _onFormChanged triggered, will schedule setState in parent');
      // Foloseste postFrameCallback pentru a evita blocajul
      if (mounted && context.findAncestorStateOfType<_ClientsPopupState>() != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            debugPrint('[ClientsPopup2] Executing setState in parent after frame');
            context.findAncestorStateOfType<_ClientsPopupState>()!.setState(() {});
          }
        });
      }
    } else {
    }
  }
  
  /// Cancel temporary client creation
  void _cancelClientCreation() {
    
    // Cancel the temporary client first
    final clientService = SplashService().clientUIService;
    clientService.cancelTemporaryClient();
    
    // Close the edit widget instead of trying to pop the dialog
    if (widget.editingClient != null && widget.onDeleteClient != null) {
      widget.onDeleteClient!(widget.editingClient!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController1.dispose();
    _phoneController2.dispose();
    _coDebitorNameController.dispose();
    super.dispose();
  }

  /// Helper to build a Client object from the form fields
  Client _buildClientFromForm() {
    return Client(
      name: _nameController.text.trim(),
      phoneNumber1: _phoneController1.text.trim(),
      phoneNumber2: _phoneController2.text.trim().isEmpty 
          ? null 
          : _phoneController2.text.trim(),
      coDebitorName: _coDebitorNameController.text.trim().isEmpty 
          ? null 
          : _coDebitorNameController.text.trim(),
    );
  }

  /// Salveaza clientul curent
  Future<void> _saveClient() async {
    
    try {
      final client = _buildClientFromForm();
      
      // Update the temporary client with the form data
      final clientService = SplashService().clientUIService;
      clientService.updateTemporaryClient(
        name: client.name,
        phoneNumber: client.phoneNumber1,
        phoneNumber2: client.phoneNumber2,
        coDebitorName: client.coDebitorName,
      );
      
      // Finalize the temporary client
      final success = await clientService.finalizeTemporaryClient();
      
      if (success) {
        
        if (widget.onSaveClient != null) {
          widget.onSaveClient!(client);
        }
        
        // Don't call Navigator.pop() since this is not a dialog
        // The parent will handle closing the popup
      } else {
        debugPrint('🔵 POPUP: Failed to save client');
        // Failed to save client
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Eroare la salvarea clientului'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
        } catch (e) {
      debugPrint('🔵 POPUP: Exception in _saveClient: $e');
      // Exception in _saveClient
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la salvarea clientului: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Widget _buildFormBottomButtonsRow(bool isEditing) {
    if (isEditing) {
      return FlexButtonWithTrailingIcon(
        primaryButtonText: "Salveaza client",
        primaryButtonIconPath: "assets/saveIcon.svg",
        onPrimaryButtonTap: _saveClient,
        trailingIconPath: "assets/deleteIcon.svg",
        onTrailingIconTap: widget.editingClient != null && widget.onDeleteClient != null ? () => widget.onDeleteClient!(widget.editingClient!) : null,
        spacing: AppTheme.smallGap,
        borderRadius: AppTheme.borderRadiusMedium,
        buttonHeight: 48.0,
        primaryButtonTextStyle: AppTheme.navigationButtonTextStyle,
      );
    } else {
      // For new client creation, use FlexButtonWithTrailingIcon with cancel
      return FlexButtonWithTrailingIcon(
        primaryButtonText: "Salveaza client",
        primaryButtonIconPath: "assets/saveIcon.svg",
        onPrimaryButtonTap: _saveClient,
        trailingIconPath: "assets/closeIcon.svg",
        onTrailingIconTap: _cancelClientCreation,
        spacing: AppTheme.smallGap,
        borderRadius: AppTheme.borderRadiusMedium,
        buttonHeight: 48.0,
        primaryButtonTextStyle: AppTheme.navigationButtonTextStyle,
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
            borderRadius: BorderRadius.all(Radius.circular(32)),
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
                            
                            // Client Phone 1 Field
                            InputField1(
                              title: "Telefon 1",
                              hintText: "Introdu primul numar de telefon",
                              controller: _phoneController1,
                              keyboardType: TextInputType.phone,
                              minWidth: 128,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+#]+'))],
                            ),
                            
                            const SizedBox(height: AppTheme.smallGap),
                            
                            // Client Phone 2 Field (optional)
                            InputField1(
                              title: "Telefon 2 (optional)",
                              hintText: "Introdu al doilea numar de telefon",
                              controller: _phoneController2,
                              keyboardType: TextInputType.phone,
                              minWidth: 128,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+#]+'))],
                            ),
                            
                            const SizedBox(height: AppTheme.smallGap),
                            
                            // Co-debitor Name Field
                            InputField1(
                              title: "Nume codebitor (optional)",
                              hintText: "Introdu numele codebitorului",
                              controller: _coDebitorNameController,
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
