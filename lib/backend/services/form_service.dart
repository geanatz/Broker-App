import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:broker_app/backend/services/clients_service.dart';
import 'package:broker_app/backend/services/firebase_service.dart';
import 'dart:async'; // Added for Timer

/// Enum pentru diferitele tipuri de credite
enum CreditType { 
  cardCumparaturi, 
  nevoi, 
  overdraft, 
  ipotecar, 
  primaCasa 
}

/// Enum pentru diferitele tipuri de venituri
enum IncomeType { 
  salariu, 
  pensie, 
  indemnizatie 
}

/// Extensii pentru afisarea tipurilor de credite
extension CreditTypeExtension on CreditType {
  String get displayTitle {
    switch (this) {
      case CreditType.cardCumparaturi:
        return 'Card cumparaturi';
      case CreditType.nevoi:
        return 'Nevoi personale';
      case CreditType.overdraft:
        return 'Overdraft';
      case CreditType.ipotecar:
        return 'Ipotecar';
      case CreditType.primaCasa:
        return 'Prima casa';
    }
  }
}

/// Extensii pentru afisarea tipurilor de venituri
extension IncomeTypeExtension on IncomeType {
  String get displayTitle {
    switch (this) {
      case IncomeType.salariu:
        return 'Salariu';
      case IncomeType.pensie:
        return 'Pensie';
      case IncomeType.indemnizatie:
        return 'Indemnizatie';
    }
  }
}

/// Model pentru datele de credit
class CreditFormModel {
  final String id;
  String bank;
  String creditType;
  String sold;
  String consumat;
  String rateType;
  String rata;
  String perioada;
  bool isNew;

  CreditFormModel({
    String? id,
    this.bank = 'Selecteaza',
    this.creditType = 'Selecteaza',
    this.sold = '',
    this.consumat = '',
    this.rateType = 'Selecteaza',
    this.rata = '',
    this.perioada = '',
    this.isNew = true,
  }) : id = id ?? 'credit_${DateTime.now().millisecondsSinceEpoch}_${objectRuntimeType(CreditFormModel, 'CreditFormModel')}';

  /// Verifica daca formularul are informatii minime
  bool hasMinimumInfo() {
    return bank != 'Selecteaza' && bank != 'Selecteaza banca' && 
           creditType != 'Selecteaza' && creditType != 'Selecteaza tipul';
  }

  /// Verifica daca formularul este gol
  bool get isEmpty => !hasMinimumInfo();

  /// Actualizeaza din alt model
  void updateFrom(CreditFormModel other) {
    bank = other.bank;
    creditType = other.creditType;
    sold = other.sold;
    consumat = other.consumat;
    rateType = other.rateType;
    rata = other.rata;
    perioada = other.perioada;
    isNew = other.isNew;
  }

  /// Converteste la Map pentru salvare
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bank': bank,
      'creditType': creditType,
      'sold': sold,
      'consumat': consumat,
      'rateType': rateType,
      'rata': rata,
      'perioada': perioada,
      'isNew': isNew,
    };
  }

  /// Creeaza din Map
  factory CreditFormModel.fromMap(Map<String, dynamic> map) {
    return CreditFormModel(
      id: map['id'],
      bank: _migrateOldPlaceholder(map['bank'] ?? 'Selecteaza'),
      creditType: _migrateOldPlaceholder(map['creditType'] ?? 'Selecteaza'),
      sold: map['sold'] ?? '',
      consumat: map['consumat'] ?? '',
      rateType: _migrateOldPlaceholder(map['rateType'] ?? 'Selecteaza'),
      rata: map['rata'] ?? '',
      perioada: map['perioada'] ?? '',
      isNew: map['isNew'] ?? true,
    );
  }

  /// Migreaza valorile placeholder vechi la noile valori
  static String _migrateOldPlaceholder(String value) {
    if (value == 'Selecteaza banca' || value == 'Selecteaza tipul') {
      return 'Selecteaza';
    }
    return value;
  }

  @override
  String toString() {
    return 'CreditFormModel{id: $id, bank: $bank, creditType: $creditType, isEmpty: $isEmpty}';
  }
}

/// Model pentru datele de venit
class IncomeFormModel {
  final String id;
  String bank;
  String incomeType;
  String incomeAmount;
  String vechime;
  bool isNew;

  IncomeFormModel({
    String? id,
    this.bank = 'Selecteaza',
    this.incomeType = 'Selecteaza',
    this.incomeAmount = '',
    this.vechime = '',
    this.isNew = true,
  }) : id = id ?? 'income_${DateTime.now().millisecondsSinceEpoch}_${objectRuntimeType(IncomeFormModel, 'IncomeFormModel')}';

  /// Verifica daca formularul are informatii minime
  bool hasMinimumInfo() {
    return bank != 'Selecteaza' && bank != 'Selecteaza banca' && 
           incomeType != 'Selecteaza' && incomeType != 'Selecteaza tipul';
  }

  /// Verifica daca formularul este gol
  bool get isEmpty => !hasMinimumInfo();

  /// Actualizeaza din alt model
  void updateFrom(IncomeFormModel other) {
    bank = other.bank;
    incomeType = other.incomeType;
    incomeAmount = other.incomeAmount;
    vechime = other.vechime;
    isNew = other.isNew;
  }

  /// Converteste la Map pentru salvare
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bank': bank,
      'incomeType': incomeType,
      'incomeAmount': incomeAmount,
      'vechime': vechime,
      'isNew': isNew,
    };
  }

  /// Creeaza din Map
  factory IncomeFormModel.fromMap(Map<String, dynamic> map) {
    return IncomeFormModel(
      id: map['id'],
      bank: CreditFormModel._migrateOldPlaceholder(map['bank'] ?? 'Selecteaza'),
      incomeType: CreditFormModel._migrateOldPlaceholder(map['incomeType'] ?? 'Selecteaza'),
      incomeAmount: map['incomeAmount'] ?? '',
      vechime: map['vechime'] ?? '',
      isNew: map['isNew'] ?? true,
    );
  }

  @override
  String toString() {
    return 'IncomeFormModel{id: $id, bank: $bank, incomeType: $incomeType, isEmpty: $isEmpty}';
  }
}

/// Service pentru gestionarea formularelor
class FormService extends ChangeNotifier {
  // Singleton pattern
  static final FormService _instance = FormService._internal();
  factory FormService() => _instance;
  FormService._internal();

  // Services
  final ClientUIService _clientService = ClientUIService();
  final FirebaseFormService _firebaseFormService = FirebaseFormService();
  
  // OPTIMIZARE: Debouncing pentru a evita multiple apeluri simultane
  // FIX: Removed debounce timer for immediate response

  // Form data storage per client
  final Map<String, List<CreditFormModel>> _clientCreditForms = HashMap();
  final Map<String, List<CreditFormModel>> _coborrowerCreditForms = HashMap();
  final Map<String, List<IncomeFormModel>> _clientIncomeForms = HashMap();
  final Map<String, List<IncomeFormModel>> _coborrowerIncomeForms = HashMap();

  // UI state
  final Map<String, bool> _showingClientLoanForm = HashMap();
  final Map<String, bool> _showingClientIncomeForm = HashMap();

  // OPTIMIZARE: Cache pentru form data
  final Map<String, Map<String, dynamic>> _formDataCache = HashMap();

  /// OPTIMIZATION: Flag to prevent redundant form data loading
  bool _isLoadingFormData = false;
  String? _currentlyLoadingClientId;

  /// OPTIMIZATION: Request deduplication to prevent multiple Firebase calls
  final Map<String, Future<void>> _pendingRequests = {};

  // Constants
  static const List<String> incomeBanks = [
    'Alpha Bank',
    'Banca Transilvania',
    'BCR',
    'BRD',
    'CEC Bank',
    'Exim Bank',
    'First Bank',
    'Garanti Bank',
    'Idea Bank',
    'ING Bank',
    'Libra Bank',
    'Patria Bank',
    'Raiffeisen Bank',
    'TBI Bank',
    'UniCredit'
  ];

  static const List<String> creditBanks = [
    'Alpha Bank',
    'Axi IFN',
    'Banca Romaneasca',
    'BCR',
    'Best Credit',
    'BNP Paribas',
    'BRD',
    'BRD Finance',
    'Banca Transilvania',
    'BT Direct',
    'BT Leasing',
    'CAR',
    'CEC Bank',
    'Cetelem',
    'Credit Europe Bank',
    'Credit24',
    'Credex',
    'Credius',
    'Eco Finance',
    'Exim Bank',
    'First Bank',
    'Garanti Bank',
    'Happy Credit',
    'Hora Credit',
    'iCredit',
    'Idea Bank',
    'IFN',
    'ING Bank',
    'Intesa Sanpaolo',
    'Leasing IFN',
    'Libra Bank',
    'Patria Bank',
    'Pireus Bank',
    'ProCredit Bank',
    'Provident',
    'Raiffeisen Bank',
    'Raiffeisen Leasing',
    'Revolut',
    'Salt Bank',
    'Simplu Credit',
    'TBI Bank',
    'Uni Credit',
    'UniCredit Consumer Financing',
    'UniCredit Leasing',
    'Viva Credit',
    'Volksbank'
  ];

  static const List<String> creditTypes = [
    'Card cumparaturi',
    'Nevoi personale',
    'Overdraft',
    'Ipotecar',
    'Prima casa',
  ];

  static const List<String> rateTypes = [
    'Fixa',
    'Variabila',
    'Euribor',
    'IRCC',
    'ROBOR',
  ];

  static const List<String> incomeTypes = [
    'Indemnizatie',
    'Salariu',
    'Pensie',
    'Pensie MAI',
  ];

  // Getters
  @Deprecated('Use availableIncomeBanks or availableCreditBanks instead')
  List<String> get availableBanks => incomeBanks;
  List<String> get availableIncomeBanks => incomeBanks;
  List<String> get availableCreditBanks => creditBanks;
  List<String> get availableCreditTypes => creditTypes;
  List<String> get availableRateTypes => rateTypes;
  List<String> get availableIncomeTypes => incomeTypes;

  /// Initializeaza service-ul
  Future<void> initialize() async {
    // Listen to client changes
    _clientService.addListener(_onClientChanged);
  }

  /// Dispose resources
  @override
  void dispose() {
    _clientService.removeListener(_onClientChanged);
    super.dispose();
  }

  /// Gestioneaza schimbarea clientului
  void _onClientChanged() {
    // OPTIMIZARE: Folosește microtask pentru a evita notifyListeners în timpul build
    Future.microtask(() {
      notifyListeners();
    });
  }

  /// Obtine formularele de credit pentru client
  List<CreditFormModel> getClientCreditForms(String clientId) {
    if (!_clientCreditForms.containsKey(clientId)) {
      _clientCreditForms[clientId] = [CreditFormModel()];
    }
    return _clientCreditForms[clientId]!;
  }

  /// Obtine formularele de credit pentru codebitor
  List<CreditFormModel> getCoborrowerCreditForms(String clientId) {
    if (!_coborrowerCreditForms.containsKey(clientId)) {
      // Create separate empty form for coborrower, not sharing client data
      _coborrowerCreditForms[clientId] = [CreditFormModel()];
    }
    return _coborrowerCreditForms[clientId]!;
  }

  /// Obtine formularele de venit pentru client
  List<IncomeFormModel> getClientIncomeForms(String clientId) {
    if (!_clientIncomeForms.containsKey(clientId)) {
      _clientIncomeForms[clientId] = [IncomeFormModel()];
    }
    return _clientIncomeForms[clientId]!;
  }

  /// Obtine formularele de venit pentru codebitor
  List<IncomeFormModel> getCoborrowerIncomeForms(String clientId) {
    if (!_coborrowerIncomeForms.containsKey(clientId)) {
      // Create separate empty form for coborrower, not sharing client data
      _coborrowerIncomeForms[clientId] = [IncomeFormModel()];
    }
    return _coborrowerIncomeForms[clientId]!;
  }

  /// Verifica daca se afiseaza formularul clientului pentru credite
  bool isShowingClientLoanForm(String clientId) {
    return _showingClientLoanForm[clientId] ?? true;
  }

  /// Verifica daca se afiseaza formularul clientului pentru venituri
  bool isShowingClientIncomeForm(String clientId) {
    return _showingClientIncomeForm[clientId] ?? true;
  }

  /// Comuta intre client si codebitor pentru credite
  void toggleLoanFormType(String clientId) {
    
    _showingClientLoanForm[clientId] = !isShowingClientLoanForm(clientId);
    
    // Automatically save UI state to Firebase
    _autoSaveToFirebaseForClient(clientId);
  }

  /// Comuta intre client si codebitor pentru venituri
  void toggleIncomeFormType(String clientId) {
    
    _showingClientIncomeForm[clientId] = !isShowingClientIncomeForm(clientId);
    
    // Automatically save UI state to Firebase
    _autoSaveToFirebaseForClient(clientId);
  }

  /// Actualizeaza un formular de credit
  void updateCreditForm(String clientId, int index, CreditFormModel updatedForm, {bool isClient = true}) {
    final forms = isClient ? getClientCreditForms(clientId) : getCoborrowerCreditForms(clientId);
    
    if (index < forms.length) {
      forms[index].updateFrom(updatedForm);
      
      // Adauga un formular nou daca ultimul nu mai este gol
      if (index == forms.length - 1 && !forms[index].isEmpty) {
        forms.add(CreditFormModel());
      }
      
      // OPTIMIZARE: Folosește microtask pentru a evita notifyListeners în timpul build
      Future.microtask(() {
        notifyListeners();
      });
      
      // Automatically save to Firebase after updating form
      _autoSaveToFirebaseForClient(clientId);
    }
  }

  /// Actualizeaza un formular de venit
  void updateIncomeForm(String clientId, int index, IncomeFormModel updatedForm, {bool isClient = true}) {
    final forms = isClient ? getClientIncomeForms(clientId) : getCoborrowerIncomeForms(clientId);
    
    if (index < forms.length) {
      forms[index].updateFrom(updatedForm);
      
      // Adauga un formular nou daca ultimul nu mai este gol
      if (index == forms.length - 1 && !forms[index].isEmpty) {
        forms.add(IncomeFormModel());
      }
      
      // OPTIMIZARE: Folosește microtask pentru a evita notifyListeners în timpul build
      Future.microtask(() {
        notifyListeners();
      });
      
      // Automatically save to Firebase after updating form
      _autoSaveToFirebaseForClient(clientId);
    }
  }

  /// sterge un formular de credit
  void removeCreditForm(String clientId, int index, {bool isClient = true}) {
    final forms = isClient ? getClientCreditForms(clientId) : getCoborrowerCreditForms(clientId);
    
    // Nu permite stergerea ultimului formular daca este singurul si este gol
    if (forms.length == 1 && forms[0].isEmpty) {
      return;
    }
    
    if (index < forms.length) {
      forms.removeAt(index);
      
      // Asigura-te ca exista intotdeauna un formular gol la sfarsit
      if (forms.isEmpty || !forms.last.isEmpty) {
        forms.add(CreditFormModel());
      }
      
      // OPTIMIZARE: Folosește microtask pentru a evita notifyListeners în timpul build
      Future.microtask(() {
        notifyListeners();
      });
      
      // Automatically save to Firebase after removing form
      _autoSaveToFirebaseForClient(clientId);
    }
  }

  /// sterge un formular de venit
  void removeIncomeForm(String clientId, int index, {bool isClient = true}) {
    final forms = isClient ? getClientIncomeForms(clientId) : getCoborrowerIncomeForms(clientId);
    
    // Nu permite stergerea ultimului formular daca este singurul si este gol
    if (forms.length == 1 && forms[0].isEmpty) {
      return;
    }
    
    if (index < forms.length) {
      forms.removeAt(index);
      
      // Asigura-te ca exista intotdeauna un formular gol la sfarsit
      if (forms.isEmpty || !forms.last.isEmpty) {
        forms.add(IncomeFormModel());
      }
      
      // OPTIMIZARE: Folosește microtask pentru a evita notifyListeners în timpul build
      Future.microtask(() {
        notifyListeners();
      });
      
      // Automatically save to Firebase after removing form
      _autoSaveToFirebaseForClient(clientId);
    }
  }

  /// Automatically saves form data to Firebase for a client by phone number
  Future<void> _autoSaveToFirebaseForClient(String clientPhoneNumber) async {
    try {

      
      // Find client name - for now use phone number as fallback
      String clientName = clientPhoneNumber;
      
      final success = await saveFormDataForClient(
        clientPhoneNumber,
        clientPhoneNumber,
        clientName,
      );
      
      if (!success) {
        debugPrint('❌ FormService: Failed to auto-save form data to Firebase for client: $clientPhoneNumber');
      }
    } catch (e) {
      debugPrint('❌ FormService: Error auto-saving form data to Firebase: $e');
    }
  }

  /// FIX: Advanced form data loading with strategic caching
  Future<void> loadFormDataForClient(String clientId, String phoneNumber) async {
    // OPTIMIZATION: Prevent redundant loading operations
    if (_isLoadingFormData && _currentlyLoadingClientId == clientId) {
      return;
    }
    
    // OPTIMIZATION: Request deduplication - if same request is pending, wait for it
    if (_pendingRequests.containsKey(clientId)) {
      await _pendingRequests[clientId];
      return;
    }
    
    PerformanceMonitor.startTimer('loadFormData');
    
    try {
      _isLoadingFormData = true;
      _currentlyLoadingClientId = clientId;
      
      final loadStartTime = DateTime.now();
      
      // OPTIMIZATION: Ultra-aggressive cache check with extended validity
      if (_formDataCache.containsKey(clientId)) {
        final cachedData = _formDataCache[clientId]!;
        final cacheTime = cachedData['cacheTime'] as DateTime?;
        
        // OPTIMIZATION: Extended cache validity to 5 minutes for ultra-fast response
        if (cacheTime != null && DateTime.now().difference(cacheTime).inMinutes < 5) {
          final cacheStartTime = DateTime.now();
          
          _clientCreditForms[clientId] = List.from(cachedData['clientCreditForms']);
          _coborrowerCreditForms[clientId] = List.from(cachedData['coborrowerCreditForms']);
          _clientIncomeForms[clientId] = List.from(cachedData['clientIncomeForms']);
          _coborrowerIncomeForms[clientId] = List.from(cachedData['coborrowerIncomeForms']);
          _showingClientLoanForm[clientId] = cachedData['showingClientLoanForm'];
          _showingClientIncomeForm[clientId] = cachedData['showingClientIncomeForm'];
          
          // OPTIMIZARE: Folosește microtask pentru a evita notifyListeners în timpul build
          Future.microtask(() {
            notifyListeners();
          });
          PerformanceMonitor.endTimer('loadFormData');
          
          final cacheTime = DateTime.now().difference(cacheStartTime).inMilliseconds;
          return;
        }
      }

      // OPTIMIZATION: Create pending request to prevent duplicates
      final requestFuture = _performFormDataLoad(clientId, phoneNumber);
      _pendingRequests[clientId] = requestFuture;
      
      // Wait for the request to complete
      await requestFuture;
      
    } catch (e) {
      debugPrint('Error loading form data for client $clientId: $e');
      PerformanceMonitor.endTimer('loadFormData');
    } finally {
      _isLoadingFormData = false;
      _currentlyLoadingClientId = null;
      _pendingRequests.remove(clientId);
    }
  }

  /// FIX: Advanced form data loading execution with detailed profiling
  Future<void> _performFormDataLoad(String clientId, String phoneNumber) async {
    try {
      final startTime = DateTime.now();
      
      final firebaseStartTime = DateTime.now();
      final formData = await _firebaseFormService.loadAllFormData(phoneNumber);
      
      final firebaseTime = DateTime.now().difference(firebaseStartTime).inMilliseconds;
      
      if (formData != null) {
        final processStartTime = DateTime.now();
        
        // Load credit forms with enhanced error handling
        final creditForms = formData['creditForms'];
        if (creditForms != null) {
          final clientCreditData = creditForms['client'] as List?;
          if (clientCreditData != null) {
            _clientCreditForms[clientId] = clientCreditData
                .map((data) => CreditFormModel.fromMap(data))
                .toList();
            // Ensure there's always an empty form at the end
            if (_clientCreditForms[clientId]!.isEmpty || !_clientCreditForms[clientId]!.last.isEmpty) {
              _clientCreditForms[clientId]!.add(CreditFormModel());
            }
          } else {
            // FIX: Initialize with empty form if no data exists
            _clientCreditForms[clientId] = [CreditFormModel()];
          }
          
          final coborrowerCreditData = creditForms['coborrower'] as List?;
          if (coborrowerCreditData != null) {
            _coborrowerCreditForms[clientId] = coborrowerCreditData
                .map((data) => CreditFormModel.fromMap(data))
                .toList();
            if (_coborrowerCreditForms[clientId]!.isEmpty || !_coborrowerCreditForms[clientId]!.last.isEmpty) {
              _coborrowerCreditForms[clientId]!.add(CreditFormModel());
            }
          } else {
            // FIX: Initialize with empty form if no data exists
            _coborrowerCreditForms[clientId] = [CreditFormModel()];
          }
        } else {
          // FIX: Initialize with empty forms if no credit data exists
          _clientCreditForms[clientId] = [CreditFormModel()];
          _coborrowerCreditForms[clientId] = [CreditFormModel()];
        }
        
        // Load income forms with enhanced error handling
        final incomeForms = formData['incomeForms'];
        if (incomeForms != null) {
          final clientIncomeData = incomeForms['client'] as List?;
          if (clientIncomeData != null) {
            _clientIncomeForms[clientId] = clientIncomeData
                .map((data) => IncomeFormModel.fromMap(data))
                .toList();
            if (_clientIncomeForms[clientId]!.isEmpty || !_clientIncomeForms[clientId]!.last.isEmpty) {
              _clientIncomeForms[clientId]!.add(IncomeFormModel());
            }
          } else {
            // FIX: Initialize with empty form if no data exists
            _clientIncomeForms[clientId] = [IncomeFormModel()];
          }
          
          final coborrowerIncomeData = incomeForms['coborrower'] as List?;
          if (coborrowerIncomeData != null) {
            _coborrowerIncomeForms[clientId] = coborrowerIncomeData
                .map((data) => IncomeFormModel.fromMap(data))
                .toList();
            if (_coborrowerIncomeForms[clientId]!.isEmpty || !_coborrowerIncomeForms[clientId]!.last.isEmpty) {
              _coborrowerIncomeForms[clientId]!.add(IncomeFormModel());
            }
          } else {
            // FIX: Initialize with empty form if no data exists
            _coborrowerIncomeForms[clientId] = [IncomeFormModel()];
          }
        } else {
          // FIX: Initialize with empty forms if no income data exists
          _clientIncomeForms[clientId] = [IncomeFormModel()];
          _coborrowerIncomeForms[clientId] = [IncomeFormModel()];
        }
        
        // Load UI state
        _showingClientLoanForm[clientId] = formData['showingClientLoanForm'] ?? true;
        _showingClientIncomeForm[clientId] = formData['showingClientIncomeForm'] ?? true;
        
        final processTime = DateTime.now().difference(processStartTime).inMilliseconds;
        
        // Cache form data with strategic timing
        final cacheStartTime = DateTime.now();
        _formDataCache[clientId] = {
          'clientCreditForms': List.from(_clientCreditForms[clientId] ?? []),
          'coborrowerCreditForms': List.from(_coborrowerCreditForms[clientId] ?? []),
          'clientIncomeForms': List.from(_clientIncomeForms[clientId] ?? []),
          'coborrowerIncomeForms': List.from(_coborrowerIncomeForms[clientId] ?? []),
          'showingClientLoanForm': _showingClientLoanForm[clientId] ?? true,
          'showingClientIncomeForm': _showingClientIncomeForm[clientId] ?? true,
          'cacheTime': DateTime.now(),
        };
        
        final cacheTime = DateTime.now().difference(cacheStartTime).inMilliseconds;
        
        // OPTIMIZARE: Folosește microtask pentru a evita notifyListeners în timpul build
        Future.microtask(() {
          notifyListeners();
        });
        PerformanceMonitor.endTimer('loadFormData');
        
      } else {
        // FIX: Initialize with empty forms if no data exists
        final initStartTime = DateTime.now();
        
        _clientCreditForms[clientId] = [CreditFormModel()];
        _coborrowerCreditForms[clientId] = [CreditFormModel()];
        _clientIncomeForms[clientId] = [IncomeFormModel()];
        _coborrowerIncomeForms[clientId] = [IncomeFormModel()];
        _showingClientLoanForm[clientId] = true;
        _showingClientIncomeForm[clientId] = true;
        
        final initTime = DateTime.now().difference(initStartTime).inMilliseconds;
        
        // OPTIMIZARE: Folosește microtask pentru a evita notifyListeners în timpul build
        Future.microtask(() {
          notifyListeners();
        });
        PerformanceMonitor.endTimer('loadFormData');
        
      }
    } catch (e) {
      debugPrint('Error in _performFormDataLoad for client $clientId: $e');
      PerformanceMonitor.endTimer('loadFormData');
    }
  }

  /// Salveaza datele formularului pentru un client
  Future<bool> saveFormDataForClient(String clientId, String phoneNumber, String clientName) async {
    try {
      final clientCreditData = getClientCreditForms(clientId)
          .where((form) => !form.isEmpty)
          .map((form) => form.toMap())
          .toList();
      
      final coborrowerCreditData = getCoborrowerCreditForms(clientId)
          .where((form) => !form.isEmpty)
          .map((form) => form.toMap())
          .toList();
      
      final clientIncomeData = getClientIncomeForms(clientId)
          .where((form) => !form.isEmpty)
          .map((form) => form.toMap())
          .toList();
      
      final coborrowerIncomeData = getCoborrowerIncomeForms(clientId)
          .where((form) => !form.isEmpty)
          .map((form) => form.toMap())
          .toList();

      final success = await _firebaseFormService.saveAllFormData(
        phoneNumber: phoneNumber,
        clientName: clientName,
        clientCreditForms: clientCreditData,
        coborrowerCreditForms: coborrowerCreditData,
        clientIncomeForms: clientIncomeData,
        coborrowerIncomeForms: coborrowerIncomeData,
        showingClientLoanForm: isShowingClientLoanForm(clientId),
        showingClientIncomeForm: isShowingClientIncomeForm(clientId),
      );

      return success;
    } catch (e) {
      debugPrint('Error saving form data for client $clientId: $e');
      return false;
    }
  }

  /// Curata datele pentru un client
  void clearFormDataForClient(String clientId) {
    _clientCreditForms[clientId] = [CreditFormModel()];
    _coborrowerCreditForms[clientId] = [CreditFormModel()];
    _clientIncomeForms[clientId] = [IncomeFormModel()];
    _coborrowerIncomeForms[clientId] = [IncomeFormModel()];
    _showingClientLoanForm[clientId] = true;
    _showingClientIncomeForm[clientId] = true;
    
    // OPTIMIZARE: Clear cache pentru client
    _formDataCache.remove(clientId);
    
    // OPTIMIZARE: Folosește microtask pentru a evita notifyListeners în timpul build
    Future.microtask(() {
      notifyListeners();
    });
  }

  /// OPTIMIZARE: Curata cache-ul de form data
  void clearFormDataCache() {
    _formDataCache.clear();
  }

  /// FIX: Force refresh form data for a specific client
  Future<void> forceRefreshFormData(String clientId, String phoneNumber) async {
    // Clear cache for this client
    _formDataCache.remove(clientId);
    
    // Clear loading state
    
    // Force reload form data
    await _performFormDataLoad(clientId, phoneNumber);
  }

  /// FIX: Clear form data cache for a specific client
  void clearFormDataCacheForClient(String clientId) {
    _formDataCache.remove(clientId);
    // OPTIMIZARE: Folosește microtask pentru a evita notifyListeners în timpul build
    Future.microtask(() {
      notifyListeners();
    });
  }

  /// Pregateste datele pentru export
  Map<String, dynamic> prepareDataForExport() {
    final result = <String, dynamic>{};
    
    // Itereaza prin toti clientii cu date
    final allClientIds = <String>{
      ..._clientCreditForms.keys,
      ..._coborrowerCreditForms.keys,
      ..._clientIncomeForms.keys,
      ..._coborrowerIncomeForms.keys,
    };
    
    for (final clientId in allClientIds) {
      final clientData = <String, dynamic>{
        'creditForms': {
          'client': getClientCreditForms(clientId)
              .where((form) => !form.isEmpty)
              .map((form) => form.toMap())
              .toList(),
          'coborrower': getCoborrowerCreditForms(clientId)
              .where((form) => !form.isEmpty)
              .map((form) => form.toMap())
              .toList(),
        },
        'incomeForms': {
          'client': getClientIncomeForms(clientId)
              .where((form) => !form.isEmpty)
              .map((form) => form.toMap())
              .toList(),
          'coborrower': getCoborrowerIncomeForms(clientId)
              .where((form) => !form.isEmpty)
              .map((form) => form.toMap())
              .toList(),
        },
        'showingClientLoanForm': isShowingClientLoanForm(clientId),
        'showingClientIncomeForm': isShowingClientIncomeForm(clientId),
      };
      
      result[clientId] = clientData;
    }
    
    return result;
  }

  /// OPTIMIZATION: Preload form data for clients to improve perceived performance
  Future<void> preloadFormDataForClients(List<String> clientIds) async {
    try {
      
      // Preload in parallel for better performance
      final preloadFutures = clientIds.map((clientId) async {
        try {
          // Only preload if not already cached
          if (!_formDataCache.containsKey(clientId)) {
            await _firebaseFormService.loadAllFormData(clientId);
          }
        } catch (e) {
          debugPrint('⚠️ FORM_SERVICE: Failed to preload data for client $clientId: $e');
        }
      });
      
      await Future.wait(preloadFutures);
      
    } catch (e) {
      debugPrint('❌ FORM_SERVICE: Error during preload: $e');
    }
  }

  /// OPTIMIZATION: Warm up cache for frequently accessed clients
  Future<void> warmUpCache(List<String> clientIds) async {
    try {
      
      for (final clientId in clientIds) {
        if (!_formDataCache.containsKey(clientId)) {
          await loadFormDataForClient(clientId, clientId);
        }
      }
      
    } catch (e) {
      debugPrint('❌ FORM_SERVICE: Error during cache warm-up: $e');
    }
  }

  /// OPTIMIZATION: Check if form data exists for client
  bool hasFormDataForClient(String clientId) {
    return _clientCreditForms.containsKey(clientId) ||
           _coborrowerCreditForms.containsKey(clientId) ||
           _clientIncomeForms.containsKey(clientId) ||
           _coborrowerIncomeForms.containsKey(clientId);
  }

  /// OPTIMIZATION: Check if cached data exists for client
  bool hasCachedDataForClient(String clientId) {
    if (!_formDataCache.containsKey(clientId)) {
      return false;
    }
    
    final cachedData = _formDataCache[clientId]!;
    final cacheTime = cachedData['cacheTime'] as DateTime?;
    
    // Check if cache is still valid (5 minutes)
    return cacheTime != null && DateTime.now().difference(cacheTime).inMinutes < 5;
  }

  /// OPTIMIZATION: Initialize empty forms immediately for instant UI
  void initializeEmptyFormsForClient(String clientId) {
    _clientCreditForms[clientId] = [CreditFormModel()];
    _coborrowerCreditForms[clientId] = [CreditFormModel()];
    _clientIncomeForms[clientId] = [IncomeFormModel()];
    _coborrowerIncomeForms[clientId] = [IncomeFormModel()];
    _showingClientLoanForm[clientId] = true;
    _showingClientIncomeForm[clientId] = true;
    
    // OPTIMIZARE: Folosește microtask pentru a evita notifyListeners în timpul build
    Future.microtask(() {
      notifyListeners();
    });
  }
}

