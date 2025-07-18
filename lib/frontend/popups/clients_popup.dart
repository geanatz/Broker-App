import '../../app_theme.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../components/headers/widget_header1.dart';
import '../components/items/light_item3.dart';
import '../components/items/dark_item3.dart';
import '../components/items/light_item7.dart';
import '../components/items/dark_item7.dart';
import '../components/buttons/flex_buttons3.dart';
import '../components/buttons/flex_buttons2.dart';
import '../components/buttons/flex_buttons1.dart';
import '../components/fields/input_field1.dart';
import '../../backend/services/ocr_service.dart';
import '../../backend/services/clients_service.dart';
import '../../backend/services/splash_service.dart';
import '../../backend/ocr/scanner_ocr.dart';
import 'package:image/image.dart' as img;

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
  /// List of clients to display
  final List<Client> clients;

  /// Callback when "Add Client" button is tapped
  final VoidCallback? onAddClient;

  /// Callback when "Extract Clients" button is tapped
  final VoidCallback? onExtractClients;

  /// Callback when "Delete All Clients" button is tapped
  final VoidCallback? onDeleteAllClients;

  /// Callback when "Delete OCR Clients" from selected image is tapped  
  final VoidCallback? onDeleteOcrClients;

  /// Callback when a client is selected
  final Function(Client)? onClientSelected;

  /// Callback when a client is double-tapped for editing
  final Function(Client)? onEditClient;

  /// Callback when a client is saved
  final Function(Client)? onSaveClient;

  /// Callback when a client is deleted
  final VoidCallback? onDeleteClient;

  /// Currently selected client
  final Client? selectedClient;

  const ClientsPopup({
    super.key,
    required this.clients,
    this.onAddClient,
    this.onExtractClients,
    this.onDeleteAllClients,
    this.onDeleteOcrClients,
    this.onClientSelected,
    this.onEditClient,
    this.onSaveClient,
    this.onDeleteClient,
    this.selectedClient,
  });

  @override
  State<ClientsPopup> createState() => _ClientsPopupState();
}

class _ClientsPopupState extends State<ClientsPopup> {
  PopupState _currentState = PopupState.clientsOnly;
  List<File> _selectedImages = [];
  List<PlatformFile>? _webFiles; // Pentru fișierele selectate pe web
  Map<String, OcrResult>? _ocrResults;
  String? _selectedOcrImagePath;
  bool _isOcrProcessing = false;
  String _ocrMessage = 'Se pregateste extragerea...';
  double _ocrProgress = 0.0;
  String? _ocrError;
  Client? _editingClient;

  /// Incepe procesul de creare client cu client temporar
  void _startClientCreation() {
    
    // Creeaza clientul temporar in service
    final clientService = SplashService().clientUIService;
    clientService.createTemporaryClient();
    
    // Deschide formularul de editare pentru clientul temporar
    _openEditClient(null); // null pentru client nou
  }

  /// Deschide file picker pentru selectia imaginilor OCR
  Future<void> _openImagePicker() async {
    try {
  
      

      
      FilePickerResult? result;
      
      if (kIsWeb) {
        // Pe web folosim FileType.custom cu extensii specifice
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowMultiple: true,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'bmp', 'gif'],
          dialogTitle: 'Selecteaza imaginile pentru extragerea contactelor',
        );
      } else {
        // Pe desktop/mobile folosim FileType.image fără extensii
        result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: true,
          dialogTitle: 'Selecteaza imaginile pentru extragerea contactelor',
        );
      }
      
      if (result != null && result.files.isNotEmpty) {
    
        
        if (mounted) {
          setState(() {
            if (kIsWeb) {
              _webFiles = result!.files;
              _selectedImages = [];
            } else {
              _selectedImages = result!.files
                  .where((file) => file.path != null)
                  .map((file) => File(file.path!))
                  .toList();
              _webFiles = null;
            }
            _currentState = PopupState.ocrOnly;
          });
          _startOcrProcess();
        }
      } else {
    
      }
    } catch (e) {
      debugPrint('❌ Eroare la selectia imaginilor: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la selectia imaginilor: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Incepe procesul OCR
  Future<void> _startOcrProcess() async {

    
    setState(() {
      _isOcrProcessing = true;
      _ocrMessage = 'Se extrage textul din imaginea...';
      _ocrProgress = 0.0;
      _ocrError = null;
      _ocrResults = null;
    });

    try {
      final ocrService = OcrService();
      
      // Creează lista de imagini pentru procesare
      List<dynamic> imagesToProcess = [];
      if (kIsWeb && _webFiles != null) {
        // Pe web procesăm imaginile asincron pentru a nu bloca UI-ul
        setState(() {
          _ocrMessage = 'Se prepara imaginile pentru procesare...';
          _ocrProgress = 0.0;
        });
        
        for (int i = 0; i < _webFiles!.length; i++) {
          final file = _webFiles![i];
          if (file.bytes != null) {
            setState(() {
              _ocrMessage = 'Se prepara imaginea ${i + 1} din ${_webFiles!.length}...';
              _ocrProgress = (i + 1) / _webFiles!.length * 0.3; // 30% pentru preparare
            });
            
            // Procesează fiecare imagine asincron cu delay pentru a nu bloca UI-ul
            await Future.delayed(const Duration(milliseconds: 50));
            
            try {
              final image = img.decodeImage(file.bytes!);
              if (image != null) {
                imagesToProcess.add(ImageFile(
                  name: file.name,
                  bytes: file.bytes!,
                  size: file.size,
                  width: image.width,
                  height: image.height,
                ));
            
              } else {
                debugPrint('❌ Cannot decode image ${file.name}');
              }
            } catch (e) {
              debugPrint('❌ Error decoding image ${file.name}: $e');
            }
          }
        }
        
        setState(() {
          _ocrMessage = 'Imaginile sunt pregatite, se incepe extragerea...';
          _ocrProgress = 0.3;
        });
        
    
        
        // Pe web limitez numărul de imagini pentru a evita blocarea
        if (imagesToProcess.length > 5) {
      
          imagesToProcess = imagesToProcess.take(5).toList();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Pe web se proceseaza maxim 5 imagini simultan. Selectate ${imagesToProcess.length} imagini.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        // Pe desktop folosim fișierele direct
        imagesToProcess = _selectedImages;
    
      }
      
      final batchResult = await ocrService.processMultipleImages(
        imagesToProcess,
        onProgress: (current, total) {
          setState(() {
            _ocrMessage = 'Se proceseaza imaginea $current din $total...';
            // Pe web începem de la 30% (după preparare), pe desktop de la 0%
            final baseProgress = kIsWeb ? 0.3 : 0.0;
            final progressRange = kIsWeb ? 0.7 : 1.0;
            _ocrProgress = baseProgress + (total > 0 ? (current / total * progressRange) : 0.0);
          });
        },
      );

      // Converteste List<OcrResult> la Map<String, OcrResult>
      final resultsMap = <String, OcrResult>{};
      for (final result in batchResult.individualResults) {
        resultsMap[result.imagePath] = result;
      }

      setState(() {
        _isOcrProcessing = false;
        _ocrResults = resultsMap;
        _ocrMessage = 'Extragere finalizata!';
      });
      
  

    } catch (e) {
      debugPrint('❌ CLIENTS_POPUP: Eroare la procesul OCR: $e');
      
      setState(() {
        _isOcrProcessing = false;
        _ocrError = e.toString();
        _ocrMessage = 'Eroare la extragere';
      });
    }
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
    final fileName = imagePath.split('/').last.split('\\').last;
    final result = _ocrResults?[imagePath];
    final clientCount = result?.extractedClients?.length ?? 0;
    
    debugPrint('✅ CLIENTS_POPUP: Image selected | File: $fileName | Clients: $clientCount');
    
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
    final fileName = imagePath.split('/').last.split('\\').last;
    debugPrint('🔍 CLIENTS_POPUP: Click pe imagine: $fileName (path: $imagePath)');
    
    if (_selectedOcrImagePath == imagePath) {
      // Daca imaginea e deja selectata, afiseaza popup de confirmare pentru salvare
      debugPrint('📤 CLIENTS_POPUP: Imaginea $fileName e selectata - afisez dialog salvare');
      _showSaveConfirmationDialog(imagePath);
    } else {
      // Daca imaginea nu e selectata, o selecteaza si afiseaza clientii
      debugPrint('📋 CLIENTS_POPUP: Selectez imaginea $fileName pentru afisarea clientilor');
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

  /// Sterge imaginea OCR selectata complet (inclusiv item-ul din galerie)
  void _deleteOcrClientsFromSelectedImage() {
    if (_selectedOcrImagePath != null && _ocrResults != null) {
      final result = _ocrResults![_selectedOcrImagePath];
      if (result?.extractedClients != null) {
        final clientCount = result!.extractedClients!.length;
        final imageName = result.imagePath.split('/').last;
        
        // Sterge complet imaginea din rezultatele OCR si din lista de imagini selectate
        setState(() {
          _ocrResults!.remove(_selectedOcrImagePath!);
          _selectedImages.removeWhere((image) => image.path == _selectedOcrImagePath);
          _selectedOcrImagePath = null;
          
          // Daca nu mai sunt imagini, trece la starea clientsOnly
          if (_selectedImages.isEmpty) {
            _currentState = PopupState.clientsOnly;
          } else {
            _currentState = PopupState.ocrOnly;
          }
        });
        
        // Afiseaza mesaj de confirmare
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Imaginea "$imageName" stearsa complet ($clientCount clienti)'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  /// Returneaza lista de clienti de afisat (ori clientii din imaginea OCR selectata, ori toti clientii)
  List<Client> _getClientsToDisplay() {
    if (_selectedOcrImagePath != null && _ocrResults != null) {
      // Afiseaza clientii din imaginea selectata OCR
      final ocrResult = _ocrResults![_selectedOcrImagePath];
      if (ocrResult?.extractedClients != null) {
        // Converteste UnifiedClientModel la Client
        return ocrResult!.extractedClients!.map((contact) => Client(
          name: contact.basicInfo.name,
          phoneNumber1: contact.basicInfo.phoneNumber1,
          phoneNumber2: contact.basicInfo.phoneNumber2,
          coDebitorName: contact.basicInfo.coDebitorName,
        )).toList();
      }
      return [];
    } else {
      // Afiseaza toti clientii din lista principala
      return widget.clients;
    }
  }

  /// Deschide widgetul de editare/creare client
  void _openEditClient([Client? client]) {
    setState(() {
      _editingClient = client;
      if (_selectedImages.isNotEmpty) {
        _currentState = PopupState.ocrWithClientsAndEdit; // Toate 3 widget-urile
      } else {
        _currentState = PopupState.clientsWithEdit;
      }
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
    final bool isLast = _currentState == PopupState.ocrOnly;
    
    return Container(
      width: width,
      height: 432,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: ShapeDecoration(
        color: AppTheme.popupBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(32),
            bottomLeft: const Radius.circular(32),
            topRight: Radius.circular(isLast ? 32 : 16),
            bottomRight: Radius.circular(isLast ? 32 : 16),
          ),
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
    final bool isFirst = _currentState == PopupState.clientsOnly || _currentState == PopupState.clientsWithEdit;
    final bool isLast = _currentState == PopupState.clientsOnly || _currentState == PopupState.ocrWithClients;
    
    return Container(
      width: width,
        height: 432,
        padding: const EdgeInsets.all(AppTheme.smallGap),
        decoration: ShapeDecoration(
          color: AppTheme.popupBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isFirst ? 32 : 16),
              bottomLeft: Radius.circular(isFirst ? 32 : 16),
              topRight: Radius.circular(isLast ? 32 : 16),
              bottomRight: Radius.circular(isLast ? 32 : 16),
            ),
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
                                  final isSelected = widget.selectedClient == client;
                                  
                                  if (isSelected) {
                                    return DarkItem3(
                                      title: client.name,
                                      description: client.phoneNumber,
                                    onTap: () => _openEditClient(client),
                                    );
                                  } else {
                                    return LightItem3(
                                      title: client.name,
                                      description: client.phoneNumber,
                                      onTap: () {
                                        widget.onClientSelected?.call(client);
                                      _openEditClient(client);
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
        onDeleteClient: () {
          // Handle delete logic here
          widget.onDeleteClient?.call();
          _closeEditClient();
        },
      );
  }

  @override
  Widget build(BuildContext context) {
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
        totalWidth = 360 + 296 + 8; // Lista + Editare
        break;
      case PopupState.ocrWithClients:
        totalWidth = 296 + 360 + 8; // OCR + Lista
        break;
      case PopupState.ocrWithClientsAndEdit:
        totalWidth = 296 + 360 + 296 + 2 * 8; // OCR + Lista + Editare
        break;
    }

    // Nu mai calculam o latime comuna, fiecare widget are latimea sa fixa

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: totalWidth, minHeight: 432),
      child: Container(
        width: totalWidth,
        height: 432,
        decoration: ShapeDecoration(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Row(
          children: [
            // OCR Widget (if active)
            if (_currentState == PopupState.ocrOnly || 
                _currentState == PopupState.ocrWithClients || 
                _currentState == PopupState.ocrWithClientsAndEdit) ...[
              _buildOcrWidget(_ocrWidgetWidth),
              if (_currentState != PopupState.ocrOnly)
                const SizedBox(width: 8),
            ],
            
            // Clients List Widget (if visible)
            if (_currentState == PopupState.clientsOnly ||
                _currentState == PopupState.clientsWithEdit ||
                _currentState == PopupState.ocrWithClients ||
                _currentState == PopupState.ocrWithClientsAndEdit) ...[
              _buildClientsWidget(_clientsWidgetWidth),
            ],
            
            // Edit Client Widget (if active)
            if (_currentState == PopupState.clientsWithEdit || 
                _currentState == PopupState.ocrWithClientsAndEdit) ...[
              const SizedBox(width: 8),
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
      return FlexButtonWithTrailingIcon(
        primaryButtonText: "Adauga client",
        primaryButtonIconPath: "assets/addIcon.svg",
        trailingIconPath: "assets/deleteIcon.svg",
        onPrimaryButtonTap: () => _startClientCreation(),
        onTrailingIconTap: () {
          // Sterge complet imaginea OCR selectata (inclusiv item-ul din galerie)
          _deleteOcrClientsFromSelectedImage();
          widget.onDeleteOcrClients?.call();
        },
        spacing: AppTheme.smallGap,
        borderRadius: AppTheme.borderRadiusMedium,
        buttonHeight: 48.0,
        primaryButtonTextStyle: AppTheme.navigationButtonTextStyle,
      );
    } else {
      // In lista de contacte reala, afiseaza 3 butoane
      return FlexButtonWithTwoTrailingIcons(
        primaryButtonText: "Adauga client",
        primaryButtonIconPath: "assets/addIcon.svg",
        trailingIcon1Path: "assets/imageIcon.svg",
        trailingIcon2Path: "assets/deleteIcon.svg",
        onPrimaryButtonTap: () => _startClientCreation(),
        onTrailingIcon1Tap: _openImagePicker,
        onTrailingIcon2Tap: widget.onDeleteAllClients,
        spacing: AppTheme.smallGap,
        borderRadius: AppTheme.borderRadiusMedium,
        buttonHeight: 48.0,
        primaryButtonTextStyle: AppTheme.navigationButtonTextStyle,
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
  late TextEditingController _phoneController1;
  late TextEditingController _phoneController2;
  late TextEditingController _coDebitorNameController;

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
    // Only update if we're creating a new client (not editing existing)
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
    }
  }
  
  /// Cancel temporary client creation
  void _cancelClientCreation() {
    debugPrint('❌ POPUP: Canceling client creation');
    
    // Cancel the temporary client first
    final clientService = SplashService().clientUIService;
    clientService.cancelTemporaryClient();
    
    // Close the edit widget instead of trying to pop the dialog
    widget.onDeleteClient?.call();
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
        debugPrint('❌ POPUP: Failed to save client');
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
      debugPrint('❌ POPUP: Exception in _saveClient: $e');
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
        onTrailingIconTap: widget.onDeleteClient,
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
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
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
                            ),
                            
                            const SizedBox(height: AppTheme.smallGap),
                            
                            // Client Phone 2 Field (optional)
                            InputField1(
                              title: "Telefon 2 (optional)",
                              hintText: "Introdu al doilea numar de telefon",
                              controller: _phoneController2,
                              keyboardType: TextInputType.phone,
                              minWidth: 128,
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
