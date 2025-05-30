import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/old/models/contact_data.dart';
import 'package:broker_app/old/services/contact_form_service.dart';
import 'package:broker_app/frontend/common/components/forms/form1.dart';
import 'package:broker_app/frontend/common/components/forms/form2.dart';
import 'package:broker_app/frontend/common/components/forms/form3.dart';
import 'package:broker_app/frontend/common/components/forms/formNew.dart';
import 'package:broker_app/frontend/common/services/client_service.dart';
import 'package:broker_app/frontend/common/models/client_model.dart';
import 'package:broker_app/frontend/common/services/firebase_form_service.dart';
import 'package:intl/intl.dart';

/// Definirea temei de text pentru a asigura consistenta fontului Outfit in intreaga aplicatie
class TextStyles {
  static final TextStyle titleStyle = GoogleFonts.outfit(
    fontSize: AppTheme.fontSizeLarge,
    fontWeight: FontWeight.w600,
    color: AppTheme.elementColor2,
  );
  
  static final TextStyle subtitleStyle = GoogleFonts.outfit(
    fontSize: AppTheme.fontSizeMedium,
    fontWeight: FontWeight.w500,
    color: AppTheme.elementColor1,
  );

  static final TextStyle headerStyle = GoogleFonts.outfit(
    fontSize: AppTheme.fontSizeLarge,
    fontWeight: FontWeight.w600,
    color: AppTheme.elementColor2,
  );
  
  static final TextStyle toggleStyle = GoogleFonts.outfit(
    fontSize: AppTheme.fontSizeMedium,
    fontWeight: FontWeight.w500,
    color: AppTheme.elementColor2,
  );
}

/// Model pentru stocarea datelor de credit
class CreditFormModel {
  String bank;
  String creditType;
  String sold;
  String consumat;
  String rateType;
  String rata;
  String perioada;
  bool isNew; // Adaugam un flag pentru formularele noi

  CreditFormModel({
    this.bank = 'Selecteaza banca',
    this.creditType = 'Selecteaza tipul',
    this.sold = '',
    this.consumat = '',
    this.rateType = 'Selecteaza tipul',
    this.rata = '',
    this.perioada = '',
    this.isNew = true, // Implicit, un formular nou este marcat ca "nou"
  });
  
  // Verifica daca formularul are suficiente informatii pentru a nu mai fi considerat "nou"
  bool hasMinimumInfo() {
    return bank != 'Selecteaza banca' && creditType != 'Selecteaza tipul';
  }
}

/// Model pentru stocarea datelor de venit
class IncomeFormModel {
  String bank;
  String incomeType;
  String incomeAmount;
  String vechime;
  bool isNew; // Adaugam un flag pentru formularele noi

  IncomeFormModel({
    this.bank = 'Selecteaza banca',
    this.incomeType = 'Selecteaza tipul',
    this.incomeAmount = '',
    this.vechime = '',
    this.isNew = true, // Implicit, un formular nou este marcat ca "nou"
  });
  
  // Verifica daca formularul are suficiente informatii pentru a nu mai fi considerat "nou"
  bool hasMinimumInfo() {
    return bank != 'Selecteaza banca' && incomeType != 'Selecteaza tipul';
  }
}

/// Area pentru formulare care va fi afisata in cadrul ecranului principal.
/// Aceasta componenta inlocuieste vechiul FormScreen pastrand functionalitatea
/// dar fiind adaptata la noua structura a aplicatiei.
class FormArea extends StatefulWidget {
  const FormArea({super.key});

  @override
  State<FormArea> createState() => _FormAreaState();
}

class _FormAreaState extends State<FormArea> {
  // Serviciul pentru gestionarea clienților
  final ClientService _clientService = ClientService();
  
  // Serviciul Firebase pentru gestionarea formularelor
  final FirebaseFormService _firebaseFormService = FirebaseFormService();
  
  // Controleaza daca se afiseaza formularul pentru client sau pentru codebitor
  bool _showingClientLoanForm = true;
  bool _showingClientIncomeForm = true;
  
  // Serviciul pentru gestionarea contactelor si formularelor (păstrat pentru compatibilitate)
  final ContactFormService _contactService = ContactFormService();
  
  // Flag pentru a arata daca procesul de export este in desfasurare
  bool _isExporting = false;

  // Date pentru formularele clientului si codebitorului
  final List<CreditFormModel> _clientCreditForms = [CreditFormModel()];
  final List<CreditFormModel> _coborrowerCreditForms = [CreditFormModel()];
  final List<IncomeFormModel> _clientIncomeForms = [IncomeFormModel()];
  final List<IncomeFormModel> _coborrowerIncomeForms = [IncomeFormModel()];

  // Controller-e pentru input fields
  final Map<String, TextEditingController> _creditTextControllers = {};
  final Map<String, TextEditingController> _incomeTextControllers = {};

  // Optiuni pentru dropdown-uri
  final List<String> _banks = [
    'Alpha Bank',
    'Raiffeisen Bank',
    'BRD',
    'BCR',
    'ING Bank',
    'Banca Transilvania',
    'CEC Bank',
    'OTP Bank',
  ];

  final List<String> _creditTypes = [
    'Card de cumparaturi',
    'Nevoi personale',
    'Overdraft',
    'Ipotecar',
    'Prima casa',
  ];

  final List<String> _rateTypes = [
    'Fixa',
    'Variabila',
    'Euribor',
    'IRCC',
    'ROBOR',
  ];

  final List<String> _incomeTypes = [
    'Indemnizatie',
    'Salariu',
    'Pensie',
  ];

  // Store the GLOBAL tap position for the context menu
  Offset _globalTapPosition = Offset.zero;
  
  // Store GLOBAL tap position
  void _getTapPosition(TapDownDetails details) {
    setState(() {
      _globalTapPosition = details.globalPosition;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize demo data using the service
    _contactService.initializeDemoData();
    // Setează clientul inițial
    _previousClient = _clientService.focusedClient;
    // Ascultă schimbările în ClientService
    _clientService.addListener(_onClientServiceChanged);
    // Load saved form data
    _loadFormData();
  }

  @override
  void dispose() {
    // Save form data before disposing
    _saveFormData();
    // Remove listener
    _clientService.removeListener(_onClientServiceChanged);
    // Dispose all text controllers
    _creditTextControllers.forEach((_, controller) => controller.dispose());
    _incomeTextControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  // Add a variable to track the previous client to save data before switching
  ClientModel? _previousClient;

  void _onClientServiceChanged() {
    // Gestionează schimbarea clientului focusat
    _handleClientChange();
  }

  /// Gestionează schimbarea clientului focusat
  Future<void> _handleClientChange() async {
    final currentClient = _clientService.focusedClient;
    
    // Primul pas: salvează datele clientului anterior dacă există
    if (_previousClient != null && currentClient?.phoneNumber != _previousClient?.phoneNumber) {
      print('Saving data for previous client: ${_previousClient!.name} (${_previousClient!.phoneNumber})');
      await _saveDataForSpecificClient(_previousClient!);
    }
    
    // Al doilea pas: curăță formularul pentru a evita transmiterea datelor între clienți
    _clearCurrentForms();
    
    // Al treilea pas: încarcă datele formularului pentru noul client focusat
    await _loadClientFormData();
    
    // Actualizează referința clientului anterior
    _previousClient = currentClient;
    
    // Actualizează UI-ul
    setState(() {});
  }

  /// Salvează datele pentru un client specific
  Future<void> _saveDataForSpecificClient(ClientModel client) async {
    if (_clientCreditForms.isEmpty && _coborrowerCreditForms.isEmpty && 
        _clientIncomeForms.isEmpty && _coborrowerIncomeForms.isEmpty) {
      // Nu salvăm date goale
      return;
    }

    // Preparează datele pentru salvare
    final clientCreditData = _clientCreditForms.map((form) => {
      'bank': form.bank,
      'creditType': form.creditType,
      'sold': form.sold,
      'consumat': form.consumat,
      'rata': form.rata,
      'perioada': form.perioada,
      'rateType': form.rateType,
      'isNew': form.isNew,
    }).toList();
    
    final coborrowerCreditData = _coborrowerCreditForms.map((form) => {
      'bank': form.bank,
      'creditType': form.creditType,
      'sold': form.sold,
      'consumat': form.consumat,
      'rata': form.rata,
      'perioada': form.perioada,
      'rateType': form.rateType,
      'isNew': form.isNew,
    }).toList();
    
    final clientIncomeData = _clientIncomeForms.map((form) => {
      'bank': form.bank,
      'incomeType': form.incomeType,
      'incomeAmount': form.incomeAmount,
      'vechime': form.vechime,
      'isNew': form.isNew,
    }).toList();
    
    final coborrowerIncomeData = _coborrowerIncomeForms.map((form) => {
      'bank': form.bank,
      'incomeType': form.incomeType,
      'incomeAmount': form.incomeAmount,
      'vechime': form.vechime,
      'isNew': form.isNew,
    }).toList();

    // Salvează în Firebase pentru clientul specific
    final success = await _firebaseFormService.saveAllFormData(
      phoneNumber: client.phoneNumber,
      clientName: client.name,
      clientCreditForms: clientCreditData,
      coborrowerCreditForms: coborrowerCreditData,
      clientIncomeForms: clientIncomeData,
      coborrowerIncomeForms: coborrowerIncomeData,
      showingClientLoanForm: _showingClientLoanForm,
      showingClientIncomeForm: _showingClientIncomeForm,
    );

    if (!success) {
      print('Failed to save form data to Firebase for client: ${client.name}');
    } else {
      print('Successfully saved data for client: ${client.name} (${client.phoneNumber})');
    }
  }

  /// Curăță toate formularele curente pentru a evita transmiterea datelor între clienți
  void _clearCurrentForms() {
    _clientCreditForms.clear();
    _clientCreditForms.add(CreditFormModel());
    
    _coborrowerCreditForms.clear();
    _coborrowerCreditForms.add(CreditFormModel());
    
    _clientIncomeForms.clear();
    _clientIncomeForms.add(IncomeFormModel());
    
    _coborrowerIncomeForms.clear();
    _coborrowerIncomeForms.add(IncomeFormModel());
    
    // Resetează și starea UI
    _showingClientLoanForm = true;
    _showingClientIncomeForm = true;
    
    // Curăță toate controller-ele de text pentru a evita păstrarea valorilor în memorie
    _clearAllTextControllers();
  }

  /// Curăță toate controller-ele de text
  void _clearAllTextControllers() {
    // Dispose existing controllers to avoid memory leaks
    _creditTextControllers.forEach((_, controller) => controller.dispose());
    _incomeTextControllers.forEach((_, controller) => controller.dispose());
    
    // Clear the maps
    _creditTextControllers.clear();
    _incomeTextControllers.clear();
  }

  /// Încarcă datele formularului pentru clientul curent focusat din Firebase
  Future<void> _loadClientFormData() async {
    final focusedClient = _clientService.focusedClient;
    if (focusedClient != null) {
      try {
        // Încarcă datele specifice acestui client din Firebase
        final formData = await _firebaseFormService.loadAllFormData(focusedClient.phoneNumber);
        
        if (formData != null) {
          // Am găsit date salvate pentru acest client - le încărcăm
          // Încarcă datele de credit pentru client
          final creditForms = formData['creditForms'];
          if (creditForms != null) {
            final clientCreditData = creditForms['client'] as List?;
            if (clientCreditData != null) {
              _clientCreditForms.clear();
              for (var data in clientCreditData) {
                _clientCreditForms.add(CreditFormModel(
                  bank: data['bank'] ?? 'Selecteaza banca',
                  creditType: data['creditType'] ?? 'Selecteaza tipul',
                  sold: data['sold'] ?? '',
                  consumat: data['consumat'] ?? '',
                  rata: data['rata'] ?? '',
                  perioada: data['perioada'] ?? '',
                  rateType: data['rateType'] ?? 'Selecteaza tipul',
                  isNew: data['isNew'] ?? true,
                ));
              }
            }
            
            // Încarcă datele de credit pentru codebitor
            final coborrowerCreditData = creditForms['coborrower'] as List?;
            if (coborrowerCreditData != null) {
              _coborrowerCreditForms.clear();
              for (var data in coborrowerCreditData) {
                _coborrowerCreditForms.add(CreditFormModel(
                  bank: data['bank'] ?? 'Selecteaza banca',
                  creditType: data['creditType'] ?? 'Selecteaza tipul',
                  sold: data['sold'] ?? '',
                  consumat: data['consumat'] ?? '',
                  rata: data['rata'] ?? '',
                  perioada: data['perioada'] ?? '',
                  rateType: data['rateType'] ?? 'Selecteaza tipul',
                  isNew: data['isNew'] ?? true,
                ));
              }
            }
          }
          
          // Încarcă datele de venit
          final incomeForms = formData['incomeForms'];
          if (incomeForms != null) {
            final clientIncomeData = incomeForms['client'] as List?;
            if (clientIncomeData != null) {
              _clientIncomeForms.clear();
              for (var data in clientIncomeData) {
                _clientIncomeForms.add(IncomeFormModel(
                  bank: data['bank'] ?? 'Selecteaza banca',
                  incomeType: data['incomeType'] ?? 'Selecteaza tipul',
                  incomeAmount: data['incomeAmount'] ?? '',
                  vechime: data['vechime'] ?? '',
                  isNew: data['isNew'] ?? true,
                ));
              }
            }
            
            // Încarcă datele de venit pentru codebitor
            final coborrowerIncomeData = incomeForms['coborrower'] as List?;
            if (coborrowerIncomeData != null) {
              _coborrowerIncomeForms.clear();
              for (var data in coborrowerIncomeData) {
                _coborrowerIncomeForms.add(IncomeFormModel(
                  bank: data['bank'] ?? 'Selecteaza banca',
                  incomeType: data['incomeType'] ?? 'Selecteaza tipul',
                  incomeAmount: data['incomeAmount'] ?? '',
                  vechime: data['vechime'] ?? '',
                  isNew: data['isNew'] ?? true,
                ));
              }
            }
          }
          
          // Încarcă starea UI
          final uiState = formData['uiState'];
          if (uiState != null) {
            _showingClientLoanForm = uiState['showingClientLoanForm'] ?? true;
            _showingClientIncomeForm = uiState['showingClientIncomeForm'] ?? true;
          }
        } else {
          // Nu există date salvate pentru acest client - inițializează cu formulare goale
          print('No saved data found for client ${focusedClient.phoneNumber}, initializing with empty forms');
          _ensureMinimumForms();
        }
        
        // Asigură-te că există cel puțin un formular în fiecare listă
        _ensureMinimumForms();
        
        setState(() {});
        
      } catch (e) {
        print('Error loading form data from Firebase for client ${focusedClient.phoneNumber}: $e');
        // În caz de eroare, inițializează cu formulare goale specifice pentru acest client
        _initializeEmptyFormsForClient();
      }
    } else {
      // Dacă nu există client focusat, curăță formularul
      _clearCurrentForms();
    }
  }

  /// Asigură-te că există cel puțin un formular în fiecare listă
  void _ensureMinimumForms() {
    if (_clientCreditForms.isEmpty) {
      _clientCreditForms.add(CreditFormModel());
    }
    if (_coborrowerCreditForms.isEmpty) {
      _coborrowerCreditForms.add(CreditFormModel());
    }
    if (_clientIncomeForms.isEmpty) {
      _clientIncomeForms.add(IncomeFormModel());
    }
    if (_coborrowerIncomeForms.isEmpty) {
      _coborrowerIncomeForms.add(IncomeFormModel());
    }
  }

  /// Inițializează formulare goale specifice pentru clientul curent
  void _initializeEmptyFormsForClient() {
    final focusedClient = _clientService.focusedClient;
    if (focusedClient != null) {
      print('Initializing empty forms for client: ${focusedClient.name} (${focusedClient.phoneNumber})');
    }
    
    _clearCurrentForms();
    setState(() {});
  }

  /// Inițializează formulare goale
  void _initializeEmptyForms() {
    _clientCreditForms.clear();
    _clientCreditForms.add(CreditFormModel());
    
    _coborrowerCreditForms.clear();
    _coborrowerCreditForms.add(CreditFormModel());
    
    _clientIncomeForms.clear();
    _clientIncomeForms.add(IncomeFormModel());
    
    _coborrowerIncomeForms.clear();
    _coborrowerIncomeForms.add(IncomeFormModel());
    
    _showingClientLoanForm = true;
    _showingClientIncomeForm = true;
    
    setState(() {});
  }

  /// Salvează datele formularului în Firebase
  Future<void> _saveClientFormData() async {
    final focusedClient = _clientService.focusedClient;
    if (focusedClient != null) {
      // Preparează datele de credit pentru client
      final clientCreditData = _clientCreditForms.map((form) => {
        'bank': form.bank,
        'creditType': form.creditType,
        'sold': form.sold,
        'consumat': form.consumat,
        'rata': form.rata,
        'perioada': form.perioada,
        'rateType': form.rateType,
        'isNew': form.isNew,
      }).toList();
      
      // Preparează datele de credit pentru codebitor
      final coborrowerCreditData = _coborrowerCreditForms.map((form) => {
        'bank': form.bank,
        'creditType': form.creditType,
        'sold': form.sold,
        'consumat': form.consumat,
        'rata': form.rata,
        'perioada': form.perioada,
        'rateType': form.rateType,
        'isNew': form.isNew,
      }).toList();
      
      // Preparează datele de venit pentru client
      final clientIncomeData = _clientIncomeForms.map((form) => {
        'bank': form.bank,
        'incomeType': form.incomeType,
        'incomeAmount': form.incomeAmount,
        'vechime': form.vechime,
        'isNew': form.isNew,
      }).toList();
      
      // Preparează datele de venit pentru codebitor
      final coborrowerIncomeData = _coborrowerIncomeForms.map((form) => {
        'bank': form.bank,
        'incomeType': form.incomeType,
        'incomeAmount': form.incomeAmount,
        'vechime': form.vechime,
        'isNew': form.isNew,
      }).toList();

      // Salvează în Firebase
      final success = await _firebaseFormService.saveAllFormData(
        phoneNumber: focusedClient.phoneNumber,
        clientName: focusedClient.name,
        clientCreditForms: clientCreditData,
        coborrowerCreditForms: coborrowerCreditData,
        clientIncomeForms: clientIncomeData,
        coborrowerIncomeForms: coborrowerIncomeData,
        showingClientLoanForm: _showingClientLoanForm,
        showingClientIncomeForm: _showingClientIncomeForm,
      );

      if (!success) {
        print('Failed to save form data to Firebase');
      }
    }
  }

  /// Salvează datele în Firebase (înlocuiește vechea salvare cu SharedPreferences)
  Future<void> _saveFormData() async {
    // Datele sunt acum salvate în Firebase prin _saveClientFormData()
    await _saveClientFormData();
  }

  /// Încarcă datele din Firebase (înlocuiește vechea încărcare cu SharedPreferences)
  Future<void> _loadFormData() async {
    // Datele sunt acum încărcate din Firebase prin _loadClientFormData()
    // Nu mai avem nevoie să încărcăm date globale, fiecare client își are datele sale
    _initializeEmptyForms();
  }

  /// Helper function to format numbers with commas automatically
  void _formatNumberWithCommas(TextEditingController controller, String value) {
    if (value.isEmpty) {
      controller.value = TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    } else {
      try {
        // Remove existing commas and parse
        final numericValue = value.replaceAll(',', '');
        final parts = numericValue.split('.');
        final intPart = parts[0];
        final decPart = parts.length > 1 ? parts[1] : '';
        
        // Format integer part with commas
        final formattedInt = NumberFormat('#,###').format(int.parse(intPart));
        final newText = decPart.isNotEmpty ? '$formattedInt.$decPart' : formattedInt;
        
        controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      } catch (e) {
        // Handle parsing errors - keep original value
      }
    }
  }

  /// Export data to Excel
  Future<void> _exportToExcel() async {
    setState(() {
      _isExporting = true;
    });
    
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final success = await _contactService.exportToExcel();
      
      if (!mounted) return;
      
      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Date exportate cu succes!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Eroare la exportarea datelor.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Eroare: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildFormPanelContent();
  }

  /// Construieste continutul panoului de formulare
  Widget _buildFormPanelContent() {
    final focusedClient = _clientService.focusedClient;
    
    // Dacă nu există client focusat, afișează un placeholder
    if (focusedClient == null) {
      return _buildNoClientSelectedPlaceholder();
    }
    
    // Afișează formularele pentru client
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _buildLoanWidget(),
        ),
        const SizedBox(width: AppTheme.mediumGap),
        Expanded(
          flex: 1,
          child: _buildIncomeWidget(),
        ),
      ],
    );
  }

  /// Construiește header-ul cu informațiile clientului focusat
  Widget _buildClientHeader(ClientModel client) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.widgetBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: [AppTheme.widgetShadow],
      ),
      child: Row(
        children: [
          // Informații client
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Client focusat',
                  style: TextStyles.subtitleStyle.copyWith(
                    color: AppTheme.elementColor1,
                    fontSize: AppTheme.fontSizeSmall,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  client.name,
                  style: TextStyles.titleStyle.copyWith(
                    color: AppTheme.elementColor2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  client.phoneNumber,
                  style: TextStyles.subtitleStyle.copyWith(
                    color: AppTheme.elementColor1,
                  ),
                ),
              ],
            ),
          ),
          
          // Categoria clientului
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.containerColor2,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Text(
              _getCategoryDisplayName(client.category),
              style: TextStyles.subtitleStyle.copyWith(
                color: AppTheme.elementColor2,
                fontSize: AppTheme.fontSizeSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construiește placeholder-ul când nu există client selectat
  Widget _buildNoClientSelectedPlaceholder() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.widgetBackground,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: [AppTheme.widgetShadow],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_outline,
              size: 64,
              color: AppTheme.elementColor1,
            ),
            const SizedBox(height: 16),
            Text(
              'Niciun client selectat',
              style: TextStyles.titleStyle.copyWith(
                color: AppTheme.elementColor2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selectați un client din panoul din stânga pentru a vedea formularul său',
              textAlign: TextAlign.center,
              style: TextStyles.subtitleStyle.copyWith(
                color: AppTheme.elementColor1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Obține numele de afișare pentru o categorie
  String _getCategoryDisplayName(ClientCategory category) {
    switch (category) {
      case ClientCategory.apeluri:
        return 'Apeluri';
      case ClientCategory.reveniri:
        return 'Reveniri';
      case ClientCategory.recente:
        return 'Recente';
    }
  }

  /// Construieste widget-ul pentru credite
  Widget _buildLoanWidget() {
    // Container styling from design (LoanWidget)
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: AppTheme.widgetDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 24,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Credite',
                        style: TextStyles.titleStyle.copyWith(
                          color: AppTheme.elementColor1,
                        ),
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showingClientLoanForm = !_showingClientLoanForm;
                          });
                        },
                        child: Text(
                          _showingClientLoanForm ? 'Vezi codebitor' : 'Vezi client',
                          style: TextStyles.toggleStyle.copyWith(
                            color: AppTheme.elementColor1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildLoansContainer(),
          ),
        ],
      ),
    );
  }

  /// Construieste containerul pentru lista de credite
  Widget _buildLoansContainer() {
    // Get the current list of forms based on whether we're showing client or co-borrower
    final formsList = _showingClientLoanForm ? _clientCreditForms : _coborrowerCreditForms;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < formsList.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTapDown: _getTapPosition,
                onLongPress: () => _showCreditFormContextMenu(context, i, formsList),
                child: _buildCreditForm(i, formsList),
              ),
            ),
        ],
      ),
    );
  }

  /// Afiseaza meniul contextual pentru un formular de credit
  void _showCreditFormContextMenu(BuildContext context, int index, List<CreditFormModel> formsList) {
    final form = formsList[index];
    
    // Nu permitem stergerea ultimului formular sau a formularelor noi (FormNew)
    if (formsList.length <= 1 || !form.hasMinimumInfo()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !form.hasMinimumInfo() 
              ? 'Nu se poate sterge un formular nou (FormNew).'
              : 'Nu se poate sterge ultimul formular.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.elementColor1,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final RenderObject? overlay = Overlay.of(context).context.findRenderObject();
    if (overlay == null) return;
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        _globalTapPosition.dx,
        _globalTapPosition.dy,
        overlay.paintBounds.size.width - _globalTapPosition.dx,
        overlay.paintBounds.size.height - _globalTapPosition.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'delete',
          child: Text(
            'Sterge credit',
            style: TextStyles.subtitleStyle.copyWith(
              color: AppTheme.elementColor3,
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'delete') {
        setState(() {
          formsList.removeAt(index);
        });
      }
    });
  }

  /// Construieste un formular de credit
  Widget _buildCreditForm(int index, List<CreditFormModel> formsList) {
    final form = formsList[index];
    final formPrefix = _showingClientLoanForm ? 'client' : 'codebitor';
    
    // Check the credit type to determine which form to show
    if (form.creditType == 'Card de cumparaturi' || form.creditType == 'Overdraft') {
      // For credit cards and overdraft, show Form1
      return FormContainer1(
        titleTL: 'Banca',
        optionTL: form.bank,
        iconTL: Icons.expand_more,
        onTapTL: null,
        child1TL: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildBankDropdown(index, formsList),
        ),
        
        titleTR: 'Tip credit',
        optionTR: form.creditType,
        iconTR: Icons.expand_more,
        onTapTR: null,
        child1TR: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildCreditTypeDropdown(index, formsList),
        ),
        
        titleBL: 'Sold',
        textBL: form.sold,
        onTapBL: null,
        child1: TextField(
          controller: _getCreditTextController(index, formPrefix, 'sold', form.sold),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
          ],
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            hintText: 'Introduceti soldul',
            hintStyle: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppTheme.elementColor3,
            ),
          ),
          onChanged: (value) {
            final controller = _getCreditTextController(index, formPrefix, 'sold', form.sold);
            _formatNumberWithCommas(controller, value);
            setState(() {
              form.sold = controller.text;
            });
          },
        ),
        
        titleBR: 'Consumat',
        textBR: form.consumat,
        onTapBR: null,
        child2: TextField(
          controller: _getCreditTextController(index, formPrefix, 'consumat', form.consumat),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
          ],
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            hintText: 'Introduceti suma consumata',
            hintStyle: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppTheme.elementColor3,
            ),
          ),
          onChanged: (value) {
            final controller = _getCreditTextController(index, formPrefix, 'consumat', form.consumat);
            _formatNumberWithCommas(controller, value);
            setState(() {
              form.consumat = controller.text;
              _checkAndAddNewCreditForm();
            });
          },
        ),
        
        fieldHeaderTextColor: AppTheme.elementColor2,
        fieldValueTextColor: AppTheme.elementColor3,
        fieldIconColor: AppTheme.elementColor1,
        fieldContentContainerColor: AppTheme.containerColor2,
        onClose: formsList.length > 1 ? () {
          setState(() {
            formsList.removeAt(index);
          });
        } : null,
      );
    } else if (form.creditType == 'Nevoi personale') {
      // For personal needs loans, show Form2
      return FormContainer2(
        titleR1F1: 'Banca',
        optionR1F1: form.bank,
        iconR1F1: Icons.expand_more,
        onTapR1F1: null,
        child1R1F1: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildBankDropdown(index, formsList),
        ),
        
        titleR1F2: 'Tip credit',
        optionR1F2: form.creditType,
        iconR1F2: Icons.expand_more,
        onTapR1F2: null,
        child1R1F2: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildCreditTypeDropdown(index, formsList),
        ),
        
        titleR2F1: 'Sold',
        textR2F1: form.sold,
        onTapR2F1: null,
        child1: TextField(
          controller: _getCreditTextController(index, formPrefix, 'sold', form.sold),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
          ],
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            hintText: 'Introduceti soldul',
            hintStyle: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppTheme.elementColor3,
            ),
          ),
          onChanged: (value) {
            final controller = _getCreditTextController(index, formPrefix, 'sold', form.sold);
            _formatNumberWithCommas(controller, value);
            setState(() {
              form.sold = controller.text;
            });
          },
        ),
        
        titleR2F2: 'Rata',
        textR2F2: form.rata,
        onTapR2F2: null,
        child2: TextField(
          controller: _getCreditTextController(index, formPrefix, 'rata', form.rata),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
          ],
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            hintText: 'Introduceti rata',
            hintStyle: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppTheme.elementColor3,
            ),
          ),
          onChanged: (value) {
            final controller = _getCreditTextController(index, formPrefix, 'rata', form.rata);
            _formatNumberWithCommas(controller, value);
            setState(() {
              form.rata = controller.text;
            });
          },
        ),
        
        titleR2F3: 'Perioada',
        textR2F3: form.perioada,
        onTapR2F3: null,
        child3: TextField(
          controller: _getCreditTextController(index, formPrefix, 'perioada', form.perioada),
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            hintText: 'Introduceti perioada',
            hintStyle: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppTheme.elementColor3,
            ),
          ),
          onChanged: (value) {
            setState(() {
              form.perioada = value;
              _checkAndAddNewCreditForm();
            });
          },
        ),
        
        fieldHeaderTextColor: AppTheme.elementColor2,
        fieldValueTextColor: AppTheme.elementColor3,
        fieldIconColor: AppTheme.elementColor1,
        fieldContentContainerColor: AppTheme.containerColor2,
        onClose: formsList.length > 1 ? () {
          setState(() {
            formsList.removeAt(index);
          });
        } : null,
      );
    } else if (form.creditType == 'Ipotecar' || form.creditType == 'Prima casa') {
      // For mortgage loans, create a custom layout that matches the Figma design
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.containerColor1,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            // First row: Bank and Credit Type
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Banca',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.elementColor2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.containerColor2,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _buildBankDropdown(index, formsList),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Tip credit',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.elementColor2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.containerColor2,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _buildCreditTypeDropdown(index, formsList),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Second row: Sold, Tip rata, Rata, Perioada
            Row(
              children: [
                // Sold field
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Sold',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.elementColor2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.containerColor2,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _getCreditTextController(index, formPrefix, 'sold', form.sold),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
                          ],
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.elementColor3,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            hintText: 'Sold',
                            hintStyle: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.elementColor3,
                            ),
                          ),
                          onChanged: (value) {
                            final controller = _getCreditTextController(index, formPrefix, 'sold', form.sold);
                            _formatNumberWithCommas(controller, value);
                            setState(() {
                              form.sold = controller.text;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Tip rata field
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Tip rata',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.elementColor2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.containerColor2,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _buildRateTypeDropdown(index, formsList),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Rata field
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Rata',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.elementColor2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.containerColor2,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _getCreditTextController(index, formPrefix, 'rata', form.rata),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
                          ],
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.elementColor3,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            hintText: 'Rata',
                            hintStyle: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.elementColor3,
                            ),
                          ),
                          onChanged: (value) {
                            final controller = _getCreditTextController(index, formPrefix, 'rata', form.rata);
                            _formatNumberWithCommas(controller, value);
                            setState(() {
                              form.rata = controller.text;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Perioada field
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Perioada',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.elementColor2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.containerColor2,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _getCreditTextController(index, formPrefix, 'perioada', form.perioada),
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.elementColor3,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            hintText: 'Perioada',
                            hintStyle: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.elementColor3,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              form.perioada = value;
                              _checkAndAddNewCreditForm();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Default form for selecting bank and credit type
      return FormContainerNew(
        titleF1: 'Banca',
        optionF1: form.bank,
        iconF1: Icons.expand_more,
        onTapF1: null,
        child1F1: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildBankDropdown(index, formsList),
        ),
        
        titleF2: 'Tip credit',
        optionF2: form.creditType,
        iconF2: Icons.expand_more,
        onTapF2: null,
        child1F2: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildCreditTypeDropdown(index, formsList),
        ),
        
        fieldHeaderTextColor: AppTheme.elementColor2,
        fieldValueTextColor: AppTheme.elementColor3,
        fieldIconColor: AppTheme.elementColor1,
        fieldContentContainerColor: AppTheme.containerColor2,
        // FormNew doesn't have close button - it should always be available
        onClose: null,
      );
    }
  }

  /// Construieste widget-ul pentru venituri
  Widget _buildIncomeWidget() {
    // Container styling from design (IncomeWidget)
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: AppTheme.widgetDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 24,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Venituri',
                        style: TextStyles.titleStyle.copyWith(
                          color: AppTheme.elementColor1,
                        ),
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showingClientIncomeForm = !_showingClientIncomeForm;
                          });
                        },
                        child: Text(
                          _showingClientIncomeForm ? 'Vezi codebitor' : 'Vezi client',
                          style: TextStyles.toggleStyle.copyWith(
                            color: AppTheme.elementColor1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildIncomeContainer(),
          ),
        ],
      ),
    );
  }

  /// Construieste containerul pentru lista de venituri
  Widget _buildIncomeContainer() {
    // Get the current list of forms based on whether we're showing client or co-borrower
    final formsList = _showingClientIncomeForm ? _clientIncomeForms : _coborrowerIncomeForms;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < formsList.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTapDown: _getTapPosition,
                onLongPress: () => _showIncomeFormContextMenu(context, i, formsList),
                child: _buildIncomeForm(i, formsList),
              ),
            ),
        ],
      ),
    );
  }

  /// Afiseaza meniul contextual pentru un formular de venit
  void _showIncomeFormContextMenu(BuildContext context, int index, List<IncomeFormModel> formsList) {
    final form = formsList[index];
    
    // Nu permitem stergerea ultimului formular sau a formularelor noi (FormNew)
    if (formsList.length <= 1 || !form.hasMinimumInfo()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !form.hasMinimumInfo() 
              ? 'Nu se poate sterge un formular nou (FormNew).'
              : 'Nu se poate sterge ultimul formular.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.elementColor1,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final RenderObject? overlay = Overlay.of(context).context.findRenderObject();
    if (overlay == null) return;
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        _globalTapPosition.dx,
        _globalTapPosition.dy,
        overlay.paintBounds.size.width - _globalTapPosition.dx,
        overlay.paintBounds.size.height - _globalTapPosition.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'delete',
          child: Text(
            'Sterge venit',
            style: TextStyles.subtitleStyle.copyWith(
              color: AppTheme.elementColor3,
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'delete') {
        setState(() {
          formsList.removeAt(index);
        });
      }
    });
  }

  /// Construieste un formular de venit
  Widget _buildIncomeForm(int index, List<IncomeFormModel> formsList) {
    final form = formsList[index];
    final formPrefix = _showingClientIncomeForm ? 'client' : 'codebitor';
    
    // Verifică dacă formularul are informații minime pentru a afișa al doilea rând
    final bool showSecondRow = form.hasMinimumInfo();
    
    if (showSecondRow) {
      // Afișează formularul complet cu ambele rânduri
      return FormContainer1(
        titleTL: 'Banca',
        optionTL: form.bank,
        iconTL: Icons.expand_more,
        onTapTL: null,
        child1TL: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildBankDropdownForIncome(index, formsList),
        ),
        
        titleTR: 'Tip venit',
        optionTR: form.incomeType,
        iconTR: Icons.expand_more,
        onTapTR: null,
        child1TR: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildIncomeTypeDropdown(index, formsList),
        ),
        
        titleBL: 'Venit',
        textBL: form.incomeAmount,
        onTapBL: null,
        child1: TextField(
          controller: _getIncomeTextController(index, formPrefix, 'amount', form.incomeAmount),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
          ],
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            hintText: 'Introduceti venitul',
            hintStyle: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppTheme.elementColor3,
            ),
          ),
          onChanged: (value) {
            final controller = _getIncomeTextController(index, formPrefix, 'amount', form.incomeAmount);
            _formatNumberWithCommas(controller, value);
            setState(() {
              form.incomeAmount = controller.text;
            });
          },
        ),
        
        titleBR: 'Vechime',
        textBR: form.vechime,
        onTapBR: null,
        child2: TextField(
          controller: _getIncomeTextController(index, formPrefix, 'vechime', form.vechime),
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            hintText: 'Introduceti vechimea',
            hintStyle: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppTheme.elementColor3,
            ),
          ),
          onChanged: (value) {
            setState(() {
              form.vechime = value;
              _checkAndAddNewIncomeForm();
            });
          },
        ),
        
        fieldHeaderTextColor: AppTheme.elementColor2,
        fieldValueTextColor: AppTheme.elementColor3,
        fieldIconColor: AppTheme.elementColor1,
        fieldContentContainerColor: AppTheme.containerColor2,
        onClose: formsList.length > 1 ? () {
          setState(() {
            formsList.removeAt(index);
          });
        } : null,
      );
    } else {
      // Afișează doar primul rând (Banca și Tip venit)
      return FormContainerNew(
        titleF1: 'Banca',
        optionF1: form.bank,
        iconF1: Icons.expand_more,
        onTapF1: null,
        child1F1: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildBankDropdownForIncome(index, formsList),
        ),
        
        titleF2: 'Tip venit',
        optionF2: form.incomeType,
        iconF2: Icons.expand_more,
        onTapF2: null,
        child1F2: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildIncomeTypeDropdown(index, formsList),
        ),
        
        fieldHeaderTextColor: AppTheme.elementColor2,
        fieldValueTextColor: AppTheme.elementColor3,
        fieldIconColor: AppTheme.elementColor1,
        fieldContentContainerColor: AppTheme.containerColor2,
        // FormNew doesn't have close button - it should always be available
        onClose: null,
      );
    }
  }

  /// Afiseaza un dialog pentru selectarea bancii
  void _showBankPicker(int index, List<CreditFormModel> formsList) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Selecteaza banca', style: TextStyles.headerStyle),
        children: _banks.map((bank) => SimpleDialogOption(
          onPressed: () {
            setState(() {
              formsList[index].bank = bank;
              _checkAndAddNewCreditForm();
            });
            Navigator.pop(context);
          },
          child: Text(bank, style: TextStyles.subtitleStyle),
        )).toList(),
      ),
    );
  }

  /// Afiseaza un dialog pentru selectarea bancii pentru venit
  void _showBankPickerForIncome(int index, List<IncomeFormModel> formsList) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Selecteaza banca', style: TextStyles.headerStyle),
        children: _banks.map((bank) => SimpleDialogOption(
          onPressed: () {
            setState(() {
              formsList[index].bank = bank;
              _checkAndAddNewIncomeForm();
            });
            Navigator.pop(context);
          },
          child: Text(bank, style: TextStyles.subtitleStyle),
        )).toList(),
      ),
    );
  }

  /// Afiseaza un dialog pentru selectarea tipului de credit
  void _showCreditTypePicker(int index, List<CreditFormModel> formsList) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Selecteaza tipul de credit', style: TextStyles.headerStyle),
        children: _creditTypes.map((type) => SimpleDialogOption(
          onPressed: () {
            setState(() {
              formsList[index].creditType = type;
              _checkAndAddNewCreditForm();
            });
            Navigator.pop(context);
          },
          child: Text(type, style: TextStyles.subtitleStyle),
        )).toList(),
      ),
    );
  }

  /// Afiseaza un dialog pentru selectarea tipului de rata
  void _showRateTypePicker(int index, List<CreditFormModel> formsList) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Selecteaza tipul de rata', style: TextStyles.headerStyle),
        children: _rateTypes.map((type) => SimpleDialogOption(
          onPressed: () {
            setState(() {
              formsList[index].rateType = type;
            });
            Navigator.pop(context);
          },
          child: Text(type, style: TextStyles.subtitleStyle),
        )).toList(),
      ),
    );
  }

  /// Afiseaza un dialog pentru selectarea tipului de venit
  void _showIncomeTypePicker(int index, List<IncomeFormModel> formsList) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Selecteaza tipul de venit', style: TextStyles.headerStyle),
        children: _incomeTypes.map((type) => SimpleDialogOption(
          onPressed: () {
            setState(() {
              formsList[index].incomeType = type;
            });
            Navigator.pop(context);
          },
          child: Text(type, style: TextStyles.subtitleStyle),
        )).toList(),
      ),
    );
  }

  /// Obtine sau creeaza un TextEditingController pentru un camp specific
  TextEditingController _getCreditTextController(int index, String formType, String fieldName, String initialValue) {
    final clientId = _clientService.focusedClient?.id ?? 'default';
    final String key = 'credit_${clientId}_${formType}_${index}_$fieldName';
    if (!_creditTextControllers.containsKey(key)) {
      _creditTextControllers[key] = TextEditingController(text: initialValue);
    } else if (_creditTextControllers[key]!.text != initialValue) {
      _creditTextControllers[key]!.text = initialValue;
    }
    return _creditTextControllers[key]!;
  }

  /// Obtine sau creeaza un TextEditingController pentru un camp de venit specific
  TextEditingController _getIncomeTextController(int index, String formType, String fieldName, String initialValue) {
    final clientId = _clientService.focusedClient?.id ?? 'default';
    final String key = 'income_${clientId}_${formType}_${index}_$fieldName';
    if (!_incomeTextControllers.containsKey(key)) {
      _incomeTextControllers[key] = TextEditingController(text: initialValue);
    } else if (_incomeTextControllers[key]!.text != initialValue) {
      _incomeTextControllers[key]!.text = initialValue;
    }
    return _incomeTextControllers[key]!;
  }

  /// Verifica si adauga un nou formular daca este necesar
  void _checkAndAddNewCreditForm() {
    final formsList = _showingClientLoanForm ? _clientCreditForms : _coborrowerCreditForms;
    
    // Verifica daca ultimul formular nu mai este considerat "nou"
    if (formsList.isNotEmpty && formsList.last.hasMinimumInfo()) {
      setState(() {
        formsList.last.isNew = false; // Marcheaza formularul ca fiind completat
        formsList.add(CreditFormModel()); // Adauga un nou formular gol
      });
    }
  }

  /// Verifica si adauga un nou formular de venit daca este necesar
  void _checkAndAddNewIncomeForm() {
    final formsList = _showingClientIncomeForm ? _clientIncomeForms : _coborrowerIncomeForms;
    
    // Verifica daca ultimul formular nu mai este considerat "nou"
    if (formsList.isNotEmpty && formsList.last.hasMinimumInfo()) {
      setState(() {
        formsList.last.isNew = false; // Marcheaza formularul ca fiind completat
        formsList.add(IncomeFormModel()); // Adauga un nou formular gol
      });
    }
  }

  // Functie pentru crearea unui dropdown pentru banca
  Widget _buildBankDropdown(int index, List<CreditFormModel> formsList) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: formsList[index].bank != 'Selecteaza banca' ? formsList[index].bank : null,
        hint: Text(
          'Selecteaza banca',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
        ),
        style: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppTheme.elementColor3,
        ),
        dropdownColor: AppTheme.containerColor2,
        icon: Icon(
          Icons.expand_more,
          color: AppTheme.elementColor3,
        ),
        items: _banks.map((String bank) {
          return DropdownMenuItem<String>(
            value: bank,
            child: Text(bank),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() {
              formsList[index].bank = value;
              _checkAndAddNewCreditForm();
            });
            _saveFormData(); // Salvează datele automat în Firebase
          }
        },
      ),
    );
  }

  // Functie pentru crearea unui dropdown pentru banca (pentru venituri)
  Widget _buildBankDropdownForIncome(int index, List<IncomeFormModel> formsList) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: formsList[index].bank != 'Selecteaza banca' ? formsList[index].bank : null,
        hint: Text(
          'Selecteaza banca',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
        ),
        style: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppTheme.elementColor3,
        ),
        dropdownColor: AppTheme.containerColor2,
        icon: Icon(
          Icons.expand_more,
          color: AppTheme.elementColor3,
        ),
        items: _banks.map((String bank) {
          return DropdownMenuItem<String>(
            value: bank,
            child: Text(bank),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() {
              formsList[index].bank = value;
              _checkAndAddNewIncomeForm();
            });
            _saveFormData(); // Salvează datele automat în Firebase
          }
        },
      ),
    );
  }

  // Functie pentru crearea unui dropdown pentru tipul de credit
  Widget _buildCreditTypeDropdown(int index, List<CreditFormModel> formsList) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: formsList[index].creditType != 'Selecteaza tipul' ? formsList[index].creditType : null,
        hint: Text(
          'Selecteaza tipul',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
        ),
        style: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppTheme.elementColor3,
        ),
        dropdownColor: AppTheme.containerColor2,
        icon: Icon(
          Icons.expand_more,
          color: AppTheme.elementColor3,
        ),
        items: _creditTypes.map((String type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() {
              formsList[index].creditType = value;
              _checkAndAddNewCreditForm();
            });
            _saveFormData(); // Salvează datele automat în Firebase
          }
        },
      ),
    );
  }

  // Functie pentru crearea unui dropdown pentru tipul de venit
  Widget _buildIncomeTypeDropdown(int index, List<IncomeFormModel> formsList) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: formsList[index].incomeType != 'Selecteaza tipul' ? formsList[index].incomeType : null,
        hint: Text(
          'Selecteaza tipul',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
        ),
        style: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppTheme.elementColor3,
        ),
        dropdownColor: AppTheme.containerColor2,
        icon: Icon(
          Icons.expand_more,
          color: AppTheme.elementColor3,
        ),
        items: _incomeTypes.map((String type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() {
              formsList[index].incomeType = value;
              _checkAndAddNewIncomeForm();
            });
            _saveFormData(); // Salvează datele automat
          }
        },
      ),
    );
  }

  // Functie pentru crearea unui dropdown pentru tipul de rata
  Widget _buildRateTypeDropdown(int index, List<CreditFormModel> formsList) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: formsList[index].rateType != 'Selecteaza tipul' ? formsList[index].rateType : null,
        hint: Text(
          'Selecteaza tipul',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
        ),
        style: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppTheme.elementColor3,
        ),
        dropdownColor: AppTheme.containerColor2,
        icon: Icon(
          Icons.expand_more,
          color: AppTheme.elementColor3,
        ),
        items: _rateTypes.map((String type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() {
              formsList[index].rateType = value;
              _checkAndAddNewCreditForm();
            });
          }
        },
      ),
    );
  }
}
