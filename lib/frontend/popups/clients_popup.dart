import '../../app_theme.dart';
import 'dart:io';
import 'package:flutter/material.dart';
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
import '../../backend/ocr/enchance_ocr.dart';
import '../../backend/services/clients_service.dart';

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
  ocrWithClients,        // OCR + Lista de clientes (de la imaginea selectată)
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
  Map<String, OcrImageResult>? _ocrResults;
  String? _selectedOcrImagePath;
  bool _isOcrProcessing = false;
  String _ocrMessage = 'Se pregătește extragerea...';
  double _ocrProgress = 0.0;
  String? _ocrError;
  Client? _editingClient;

  /// Deschide file picker pentru selecția imaginilor OCR
  Future<void> _openImagePicker() async {
    try {
      debugPrint('🔍 Deschide file picker pentru selecția imaginilor OCR...');
      
      // Verifică dacă Google Vision API este configurat
      final ocrService = EnhanceOcr();
      if (!ocrService.isConfigured()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Google Vision API nu este configurat corect'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'bmp', 'gif'],
        dialogTitle: 'Selectează imaginile pentru extragerea contactelor',
      );
      
      if (result != null && result.files.isNotEmpty) {
        final imageFiles = result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
        
        debugPrint('📁 Selectate ${imageFiles.length} imagini pentru OCR');
        
        if (mounted && imageFiles.isNotEmpty) {
          setState(() {
            _selectedImages = imageFiles;
            _currentState = PopupState.ocrOnly; // Doar OCR la început
          });
          _startOcrProcess();
        }
      } else {
        debugPrint('❌ Selecția imaginilor a fost anulată');
      }
    } catch (e) {
      debugPrint('❌ Eroare la selecția imaginilor: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la selecția imaginilor: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Începe procesul OCR
  Future<void> _startOcrProcess() async {
    setState(() {
      _isOcrProcessing = true;
      _ocrMessage = 'Se extrage textul din imaginea...';
      _ocrProgress = 0.0;
      _ocrError = null;
      _ocrResults = null;
    });

    try {
      final ocrService = EnhanceOcr();
      final results = await ocrService.processImages(
        _selectedImages,
        (progressUpdate) {
          setState(() {
            _ocrMessage = progressUpdate.progressMessage;
            _ocrProgress = progressUpdate.progress;
          });
        },
      );

      setState(() {
        _isOcrProcessing = false;
        _ocrResults = results;
        _ocrMessage = 'Extragere finalizată!';
      });

    } catch (e) {
      setState(() {
        _isOcrProcessing = false;
        _ocrError = e.toString();
        _ocrMessage = 'Eroare la extragere';
      });
    }
  }

  /// Anulează procesul OCR
  void _cancelOcrProcess() {
    setState(() {
      _selectedImages = [];
      _ocrResults = null;
      _isOcrProcessing = false;
      _ocrError = null;
      _selectedOcrImagePath = null;
      _currentState = _editingClient != null ? PopupState.clientsWithEdit : PopupState.clientsOnly;
    });
  }

  /// Salvează clienții din imaginea selectată în lista principală
  void _saveOcrClients() {
    if (_selectedOcrImagePath != null && _ocrResults != null) {
      final ocrResult = _ocrResults![_selectedOcrImagePath];
      if (ocrResult?.contacts != null && ocrResult!.contacts.isNotEmpty) {
        // Convertește UnifiedClientModel la Client și salvează
        final clientsToSave = ocrResult.contacts.map((contact) => Client(
          name: contact.basicInfo.name,
          phoneNumber1: contact.basicInfo.phoneNumber1,
          phoneNumber2: contact.basicInfo.phoneNumber2,
          coDebitorName: contact.basicInfo.coDebitorName,
        )).toList();
        
        // Notifică părintele despre salvarea clienților
        for (final client in clientsToSave) {
          widget.onSaveClient?.call(client);
        }
        
        // Afișează mesaj de confirmare
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

  /// Selectează o imagine din rezultatele OCR și afișează clienții
  void _selectOcrImage(String imagePath) {
    setState(() {
      _selectedOcrImagePath = imagePath;
      _currentState = PopupState.ocrWithClients; // Afișează OCR + lista de clienți
    });
  }


  /// Adaugă un client nou la lista de clienți extrași din imaginea selectată
  void _addClientToOcrResults(Client client) {
    if (_selectedOcrImagePath == null || _ocrResults == null) return;
    
    final ocrResult = _ocrResults![_selectedOcrImagePath];
    if (ocrResult == null) return;
    
    // Convertește Client la UnifiedClientModel pentru a-l adăuga la rezultatele OCR
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
        category: UnifiedClientCategory.apeluri,
        isFocused: false,
        additionalInfo: 'Adaugat manual in lista extrasa',
      ),
      metadata: ClientMetadata(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'user',
        source: 'manual_entry',
        version: 1,
      ),
    );
    
    setState(() {
      // Creează o nouă listă cu clientul adăugat
      final updatedContacts = List<UnifiedClientModel>.from(ocrResult.contacts)..add(unifiedClient);
      
      // Actualizează rezultatul OCR cu noua listă
      _ocrResults![_selectedOcrImagePath!] = OcrImageResult(
        success: ocrResult.success,
        error: ocrResult.error,
        imagePath: ocrResult.imagePath,
        extractedText: ocrResult.extractedText,
        contacts: updatedContacts,
      );
    });
    
    // Afișează mesaj de confirmare
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

  /// Editează un client existent din lista de clienți extrași din imaginea selectată
  void _updateClientInOcrResults(Client oldClient, Client newClient) {
    if (_selectedOcrImagePath == null || _ocrResults == null) return;
    
    final ocrResult = _ocrResults![_selectedOcrImagePath];
    if (ocrResult == null) return;
    
    setState(() {
      // Găsește și actualizează clientul în lista de contacte
      final updatedContacts = ocrResult.contacts.map((contact) {
        // Identifică clientul de actualizat pe baza numelui și telefonului
        if (contact.basicInfo.name == oldClient.name && 
            contact.basicInfo.phoneNumber1 == oldClient.phoneNumber1) {
          // Creează un nou UnifiedClientModel cu datele actualizate
          return UnifiedClientModel(
            id: contact.id, // Păstrează ID-ul original
            consultantId: contact.consultantId,
            basicInfo: ClientBasicInfo(
              name: newClient.name,
              phoneNumber1: newClient.phoneNumber1,
              phoneNumber2: newClient.phoneNumber2,
              coDebitorName: newClient.coDebitorName,
            ),
            formData: contact.formData,
            activities: contact.activities,
            currentStatus: const UnifiedClientStatus(
              category: UnifiedClientCategory.apeluri,
              isFocused: false,
              additionalInfo: 'Editat in lista extrasa',
            ),
            metadata: ClientMetadata(
              createdAt: contact.metadata.createdAt, // Păstrează data creării
              updatedAt: DateTime.now(), // Actualizează data modificării
              createdBy: contact.metadata.createdBy,
              source: contact.metadata.source,
              version: contact.metadata.version + 1, // Incrementează versiunea
            ),
          );
        }
        return contact; // Returnează contactul nemodificat
      }).toList();
      
      // Actualizează rezultatul OCR cu lista modificată
      _ocrResults![_selectedOcrImagePath!] = OcrImageResult(
        success: ocrResult.success,
        error: ocrResult.error,
        imagePath: ocrResult.imagePath,
        extractedText: ocrResult.extractedText,
        contacts: updatedContacts,
      );
    });
    
    // Afișează mesaj de confirmare
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client modificat in lista extrasa!'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Gestionează click-ul pe item-ul imaginii OCR
  void _handleOcrImageTap(String imagePath) {
    if (_selectedOcrImagePath == imagePath) {
      // Dacă imaginea e deja selectată, afișează popup de confirmare pentru salvare
      _showSaveConfirmationDialog(imagePath);
    } else {
      // Dacă imaginea nu e selectată, o selectează și afișează clienții
      _selectOcrImage(imagePath);
    }
  }

  /// Afișează popup de confirmare pentru salvarea clienților
  void _showSaveConfirmationDialog(String imagePath) {
    final result = _ocrResults![imagePath];
    final clientCount = result?.contacts.length ?? 0;
    
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

  /// Salvează clienții din imagine și șterge item-ul din galerie
  void _saveAndRemoveOcrImage(String imagePath) {
    // Salvează clienții
    final result = _ocrResults![imagePath];
    if (result?.contacts != null && result!.contacts.isNotEmpty) {
      final clientsToSave = result.contacts.map((contact) => Client(
        name: contact.basicInfo.name,
        phoneNumber1: contact.basicInfo.phoneNumber1,
        phoneNumber2: contact.basicInfo.phoneNumber2,
        coDebitorName: contact.basicInfo.coDebitorName,
      )).toList();
      
      // Notifică părintele despre salvarea clienților
      for (final client in clientsToSave) {
        widget.onSaveClient?.call(client);
      }
      
      // Afișează mesaj de confirmare
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
    
    // Șterge imaginea din rezultatele OCR și din lista de imagini selectate
    setState(() {
      _ocrResults!.remove(imagePath);
      _selectedImages.removeWhere((image) => image.path == imagePath);
      
      // Dacă era imaginea selectată, resetează selecția
      if (_selectedOcrImagePath == imagePath) {
        _selectedOcrImagePath = null;
        // Dacă mai sunt imagini, rămâne în starea OCR, altfel trece la clientsOnly
        if (_selectedImages.isEmpty) {
          _currentState = PopupState.clientsOnly;
        } else {
          _currentState = PopupState.ocrOnly;
        }
      }
    });
  }

  /// Șterge imaginea OCR selectată complet (inclusiv item-ul din galerie)
  void _deleteOcrClientsFromSelectedImage() {
    if (_selectedOcrImagePath != null && _ocrResults != null) {
      final result = _ocrResults![_selectedOcrImagePath];
      if (result?.contacts != null) {
        final clientCount = result!.contacts.length;
        final imageName = result.imageName;
        
        // Șterge complet imaginea din rezultatele OCR și din lista de imagini selectate
        setState(() {
          _ocrResults!.remove(_selectedOcrImagePath!);
          _selectedImages.removeWhere((image) => image.path == _selectedOcrImagePath);
          _selectedOcrImagePath = null;
          
          // Dacă nu mai sunt imagini, trece la starea clientsOnly
          if (_selectedImages.isEmpty) {
            _currentState = PopupState.clientsOnly;
          } else {
            _currentState = PopupState.ocrOnly;
          }
        });
        
        // Afișează mesaj de confirmare
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Imaginea "$imageName" ștearsă complet ($clientCount clienți)'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  /// Returnează lista de clienți de afișat (ori clienții din imaginea OCR selectată, ori toți clienții)
  List<Client> _getClientsToDisplay() {
    if (_selectedOcrImagePath != null && _ocrResults != null) {
      // Afișează clienții din imaginea selectată OCR
      final ocrResult = _ocrResults![_selectedOcrImagePath];
      if (ocrResult?.contacts != null) {
        // Convertește UnifiedClientModel la Client
        return ocrResult!.contacts.map((contact) => Client(
          name: contact.basicInfo.name,
          phoneNumber1: contact.basicInfo.phoneNumber1,
          phoneNumber2: contact.basicInfo.phoneNumber2,
          coDebitorName: contact.basicInfo.coDebitorName,
        )).toList();
      }
      return [];
    } else {
      // Afișează toți clienții din lista principală
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

  /// Închide widgetul de editare/creare client
  void _closeEditClient() {
    setState(() {
      _editingClient = null;
      if (_selectedImages.isNotEmpty && _selectedOcrImagePath != null) {
        _currentState = PopupState.ocrWithClients; // Înapoi la OCR + lista
      } else if (_selectedImages.isNotEmpty) {
        _currentState = PopupState.ocrOnly; // Doar OCR
      } else {
        _currentState = PopupState.clientsOnly;
      }
    });
  }

  /// Lățimi fixe pentru fiecare tip de widget conform design-urilor
  double get _ocrWidgetWidth => 296;    // clientsPopup3.md & clientsPopup4.md  
  double get _clientsWidgetWidth => 360; // clientsPopup1.md
  double get _editWidgetWidth => 296;    // clientsPopup2.md

  /// Construiește widgetul de extragere OCR
  Widget _buildOcrWidget(double width) {
    // Determină dacă acest widget este ultimul (cel mai din dreapta)
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

  /// Construiește zona de loading OCR
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

  /// Construiește rezultatele OCR cu lightItem7 și darkItem7
  Widget _buildOcrResults() {
    if (_ocrResults == null) return const SizedBox.shrink();

    final sortedResults = _ocrResults!.entries.toList()
      ..sort((a, b) => b.value.contactCount.compareTo(a.value.contactCount));

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
          
          if (isSelected) {
            return DarkItem7(
              title: 'Imaginea ${i + 1}',
              description: '${result.contactCount} clienti',
              svgAsset: 'assets/doneIcon.svg',
              onTap: () => _handleOcrImageTap(imagePath),
            );
          } else {
            return LightItem7(
              title: 'Imaginea ${i + 1}',
              description: '${result.contactCount} clienti',
              svgAsset: 'assets/viewIcon.svg',
              onTap: () => _handleOcrImageTap(imagePath),
            );
          }
        },
      ),
    );
  }

  /// Construiește galeria pentru loading
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

  /// Construiește galeria pentru rezultate
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
            for (int i = 0; i < _selectedImages.length; i++) ...[
              GestureDetector(
                onTap: () => _selectOcrImage(_selectedImages[i].path),
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
                        Image.file(
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
                        if (_selectedOcrImagePath != _selectedImages[i].path)
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

  /// Construiește butonul de anulare/salvare OCR
  Widget _buildOcrActionButton() {
    // După extragere, dacă o imagine este selectată, afișează buton de salvare
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
      // În timpul procesării sau fără imagine selectată, afișează buton de anulare
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

  /// Construiește widgetul cu lista de clienți
  Widget _buildClientsWidget(double width) {
    // Determină poziția acestui widget în layout
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

  /// Construiește widgetul de editare/creare client
  Widget _buildEditClientWidget(double width) {
    return ClientsPopup2(
        editingClient: _editingClient,
        onSaveClient: (client) {
          // Verifică dacă suntem în starea OCR cu clienți extrași
          final bool isInOcrMode = (_currentState == PopupState.ocrWithClientsAndEdit) &&
                                   _selectedOcrImagePath != null;
          
          if (isInOcrMode) {
            // Verifică dacă editează un client existent sau creează unul nou
            if (_editingClient != null) {
              // Editează clientul existent din lista OCR
              _updateClientInOcrResults(_editingClient!, client);
            } else {
              // Adaugă un client nou la lista de clienți extrași din imaginea selectată
              _addClientToOcrResults(client);
            }
          } else {
            // Salvează clientul în lista principală
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
        totalWidth = 360; // Lista clienți
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

    // Nu mai calculăm o lățime comună, fiecare widget are lățimea sa fixă

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
    // În starea OCR cu clienți extrași, afișează doar 2 butoane
    final bool isShowingOcrClients = (_currentState == PopupState.ocrWithClients || 
                                      _currentState == PopupState.ocrWithClientsAndEdit) &&
                                     _selectedOcrImagePath != null;
    
    if (isShowingOcrClients) {
      return FlexButtonWithTrailingIcon(
        primaryButtonText: "Adauga client",
        primaryButtonIconPath: "assets/addIcon.svg",
        trailingIconPath: "assets/deleteIcon.svg",
        onPrimaryButtonTap: () => _openEditClient(),
        onTrailingIconTap: () {
          // Șterge complet imaginea OCR selectată (inclusiv item-ul din galerie)
          _deleteOcrClientsFromSelectedImage();
          widget.onDeleteOcrClients?.call();
        },
        spacing: AppTheme.smallGap,
        borderRadius: AppTheme.borderRadiusMedium,
        buttonHeight: 48.0,
        primaryButtonTextStyle: AppTheme.navigationButtonTextStyle,
      );
    } else {
      // În lista de contacte reală, afișează 3 butoane
      return FlexButtonWithTwoTrailingIcons(
        primaryButtonText: "Adauga client",
        primaryButtonIconPath: "assets/addIcon.svg",
        trailingIcon1Path: "assets/imageIcon.svg",
        trailingIcon2Path: "assets/deleteIcon.svg",
        onPrimaryButtonTap: () => _openEditClient(),
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
  }

  @override
  void didUpdateWidget(ClientsPopup2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Verifică dacă clientul pentru editare s-a schimbat
    if (oldWidget.editingClient != widget.editingClient) {
      // Actualizează textul din controlleri cu noile valori
      _nameController.text = widget.editingClient?.name ?? '';
      _phoneController1.text = widget.editingClient?.phoneNumber1 ?? '';
      _phoneController2.text = widget.editingClient?.phoneNumber2 ?? '';
      _coDebitorNameController.text = widget.editingClient?.coDebitorName ?? '';
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

  void _saveClient() {
    if (_nameController.text.trim().isEmpty || _phoneController1.text.trim().isEmpty) {
      // Show error or handle validation
      return;
    }

    final client = Client(
      name: _nameController.text.trim(),
      phoneNumber1: _phoneController1.text.trim(),
      phoneNumber2: _phoneController2.text.trim().isEmpty 
          ? null 
          : _phoneController2.text.trim(),
      coDebitorName: _coDebitorNameController.text.trim().isEmpty 
          ? null 
          : _coDebitorNameController.text.trim(),
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
