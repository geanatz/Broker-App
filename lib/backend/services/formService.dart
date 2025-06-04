import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:broker_app/frontend/common/services/client_service.dart';
import 'firebaseService.dart';

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

/// Extensii pentru afișarea tipurilor de credite
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

/// Extensii pentru afișarea tipurilor de venituri
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

  /// Verifică dacă formularul are informații minime
  bool hasMinimumInfo() {
    return bank != 'Selecteaza' && bank != 'Selecteaza banca' && 
           creditType != 'Selecteaza' && creditType != 'Selecteaza tipul';
  }

  /// Verifică dacă formularul este gol
  bool get isEmpty => !hasMinimumInfo();

  /// Actualizează din alt model
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

  /// Convertește la Map pentru salvare
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

  /// Creează din Map
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

  /// Migrează valorile placeholder vechi la noile valori
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

  /// Verifică dacă formularul are informații minime
  bool hasMinimumInfo() {
    return bank != 'Selecteaza' && bank != 'Selecteaza banca' && 
           incomeType != 'Selecteaza' && incomeType != 'Selecteaza tipul';
  }

  /// Verifică dacă formularul este gol
  bool get isEmpty => !hasMinimumInfo();

  /// Actualizează din alt model
  void updateFrom(IncomeFormModel other) {
    bank = other.bank;
    incomeType = other.incomeType;
    incomeAmount = other.incomeAmount;
    vechime = other.vechime;
    isNew = other.isNew;
  }

  /// Convertește la Map pentru salvare
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

  /// Creează din Map
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
  final ClientService _clientService = ClientService();
  final FirebaseFormService _firebaseFormService = FirebaseFormService();

  // Form data storage per client
  final Map<String, List<CreditFormModel>> _clientCreditForms = HashMap();
  final Map<String, List<CreditFormModel>> _coborrowerCreditForms = HashMap();
  final Map<String, List<IncomeFormModel>> _clientIncomeForms = HashMap();
  final Map<String, List<IncomeFormModel>> _coborrowerIncomeForms = HashMap();

  // UI state
  final Map<String, bool> _showingClientLoanForm = HashMap();
  final Map<String, bool> _showingClientIncomeForm = HashMap();

  // Constants
  static const List<String> banks = [
    'Alpha Bank',
    'Raiffeisen Bank',
    'BRD',
    'BCR',
    'ING Bank',
    'Banca Transilvania',
    'CEC Bank',
    'OTP Bank',
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
  ];

  // Getters
  List<String> get availableBanks => banks;
  List<String> get availableCreditTypes => creditTypes;
  List<String> get availableRateTypes => rateTypes;
  List<String> get availableIncomeTypes => incomeTypes;

  /// Inițializează service-ul
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

  /// Gestionează schimbarea clientului
  void _onClientChanged() {
    notifyListeners();
  }

  /// Obține formularele de credit pentru client
  List<CreditFormModel> getClientCreditForms(String clientId) {
    if (!_clientCreditForms.containsKey(clientId)) {
      _clientCreditForms[clientId] = [CreditFormModel()];
    }
    return _clientCreditForms[clientId]!;
  }

  /// Obține formularele de credit pentru codebitor
  List<CreditFormModel> getCoborrowerCreditForms(String clientId) {
    if (!_coborrowerCreditForms.containsKey(clientId)) {
      // Create separate empty form for coborrower, not sharing client data
      _coborrowerCreditForms[clientId] = [CreditFormModel()];
    }
    return _coborrowerCreditForms[clientId]!;
  }

  /// Obține formularele de venit pentru client
  List<IncomeFormModel> getClientIncomeForms(String clientId) {
    if (!_clientIncomeForms.containsKey(clientId)) {
      _clientIncomeForms[clientId] = [IncomeFormModel()];
    }
    return _clientIncomeForms[clientId]!;
  }

  /// Obține formularele de venit pentru codebitor
  List<IncomeFormModel> getCoborrowerIncomeForms(String clientId) {
    if (!_coborrowerIncomeForms.containsKey(clientId)) {
      // Create separate empty form for coborrower, not sharing client data
      _coborrowerIncomeForms[clientId] = [IncomeFormModel()];
    }
    return _coborrowerIncomeForms[clientId]!;
  }

  /// Verifică dacă se afișează formularul clientului pentru credite
  bool isShowingClientLoanForm(String clientId) {
    return _showingClientLoanForm[clientId] ?? true;
  }

  /// Verifică dacă se afișează formularul clientului pentru venituri
  bool isShowingClientIncomeForm(String clientId) {
    return _showingClientIncomeForm[clientId] ?? true;
  }

  /// Comută între client și codebitor pentru credite
  void toggleLoanFormType(String clientId) {
    _showingClientLoanForm[clientId] = !isShowingClientLoanForm(clientId);
    notifyListeners();
    
    // Automatically save UI state to Firebase
    _autoSaveToFirebaseForClient(clientId);
  }

  /// Comută între client și codebitor pentru venituri
  void toggleIncomeFormType(String clientId) {
    _showingClientIncomeForm[clientId] = !isShowingClientIncomeForm(clientId);
    notifyListeners();
    
    // Automatically save UI state to Firebase
    _autoSaveToFirebaseForClient(clientId);
  }

  /// Actualizează un formular de credit
  void updateCreditForm(String clientId, int index, CreditFormModel updatedForm, {bool isClient = true}) {
    final forms = isClient ? getClientCreditForms(clientId) : getCoborrowerCreditForms(clientId);
    
    if (index < forms.length) {
      forms[index].updateFrom(updatedForm);
      
      // Adaugă un formular nou dacă ultimul nu mai este gol
      if (index == forms.length - 1 && !forms[index].isEmpty) {
        forms.add(CreditFormModel());
      }
      
      notifyListeners();
      
      // Automatically save to Firebase after updating form
      _autoSaveToFirebaseForClient(clientId);
    }
  }

  /// Actualizează un formular de venit
  void updateIncomeForm(String clientId, int index, IncomeFormModel updatedForm, {bool isClient = true}) {
    final forms = isClient ? getClientIncomeForms(clientId) : getCoborrowerIncomeForms(clientId);
    
    if (index < forms.length) {
      forms[index].updateFrom(updatedForm);
      
      // Adaugă un formular nou dacă ultimul nu mai este gol
      if (index == forms.length - 1 && !forms[index].isEmpty) {
        forms.add(IncomeFormModel());
      }
      
      notifyListeners();
      
      // Automatically save to Firebase after updating form
      _autoSaveToFirebaseForClient(clientId);
    }
  }

  /// Șterge un formular de credit
  void removeCreditForm(String clientId, int index, {bool isClient = true}) {
    final forms = isClient ? getClientCreditForms(clientId) : getCoborrowerCreditForms(clientId);
    
    // Nu permite ștergerea ultimului formular dacă este singurul și este gol
    if (forms.length == 1 && forms[0].isEmpty) {
      return;
    }
    
    if (index < forms.length) {
      forms.removeAt(index);
      
      // Asigură-te că există întotdeauna un formular gol la sfârșit
      if (forms.isEmpty || !forms.last.isEmpty) {
        forms.add(CreditFormModel());
      }
      
      notifyListeners();
      
      // Automatically save to Firebase after removing form
      _autoSaveToFirebaseForClient(clientId);
    }
  }

  /// Șterge un formular de venit
  void removeIncomeForm(String clientId, int index, {bool isClient = true}) {
    final forms = isClient ? getClientIncomeForms(clientId) : getCoborrowerIncomeForms(clientId);
    
    // Nu permite ștergerea ultimului formular dacă este singurul și este gol
    if (forms.length == 1 && forms[0].isEmpty) {
      return;
    }
    
    if (index < forms.length) {
      forms.removeAt(index);
      
      // Asigură-te că există întotdeauna un formular gol la sfârșit
      if (forms.isEmpty || !forms.last.isEmpty) {
        forms.add(IncomeFormModel());
      }
      
      notifyListeners();
      
      // Automatically save to Firebase after removing form
      _autoSaveToFirebaseForClient(clientId);
    }
  }

  /// Automatically saves form data to Firebase for a client by phone number
  Future<void> _autoSaveToFirebaseForClient(String clientPhoneNumber) async {
    try {
      debugPrint('FormService: Auto-saving data for client: $clientPhoneNumber');
      
      // Find client name - for now use phone number as fallback
      String clientName = clientPhoneNumber;
      
      final success = await saveFormDataForClient(
        clientPhoneNumber,
        clientPhoneNumber,
        clientName,
      );
      
      if (!success) {
        debugPrint('❌ FormService: Failed to auto-save form data to Firebase for client: $clientPhoneNumber');
      } else {
        debugPrint('✅ FormService: Successfully auto-saved form data to Firebase for client: $clientPhoneNumber');
      }
    } catch (e) {
      debugPrint('❌ FormService: Error auto-saving form data to Firebase: $e');
    }
  }

  /// Încarcă datele formularului pentru un client
  Future<void> loadFormDataForClient(String clientId, String phoneNumber) async {
    try {
      final formData = await _firebaseFormService.loadAllFormData(phoneNumber);
      
      if (formData != null) {
        // Încarcă datele de credit
        final creditForms = formData['creditForms'];
        if (creditForms != null) {
          final clientCreditData = creditForms['client'] as List?;
          if (clientCreditData != null) {
            _clientCreditForms[clientId] = clientCreditData
                .map((data) => CreditFormModel.fromMap(data))
                .toList();
            // Asigură-te că există întotdeauna un formular gol la sfârșit
            if (_clientCreditForms[clientId]!.isEmpty || !_clientCreditForms[clientId]!.last.isEmpty) {
              _clientCreditForms[clientId]!.add(CreditFormModel());
            }
          }
          
          final coborrowerCreditData = creditForms['coborrower'] as List?;
          if (coborrowerCreditData != null) {
            _coborrowerCreditForms[clientId] = coborrowerCreditData
                .map((data) => CreditFormModel.fromMap(data))
                .toList();
            // Asigură-te că există întotdeauna un formular gol la sfârșit
            if (_coborrowerCreditForms[clientId]!.isEmpty || !_coborrowerCreditForms[clientId]!.last.isEmpty) {
              _coborrowerCreditForms[clientId]!.add(CreditFormModel());
            }
          }
        }
        
        // Încarcă datele de venit
        final incomeForms = formData['incomeForms'];
        if (incomeForms != null) {
          final clientIncomeData = incomeForms['client'] as List?;
          if (clientIncomeData != null) {
            _clientIncomeForms[clientId] = clientIncomeData
                .map((data) => IncomeFormModel.fromMap(data))
                .toList();
            // Asigură-te că există întotdeauna un formular gol la sfârșit
            if (_clientIncomeForms[clientId]!.isEmpty || !_clientIncomeForms[clientId]!.last.isEmpty) {
              _clientIncomeForms[clientId]!.add(IncomeFormModel());
            }
          }
          
          final coborrowerIncomeData = incomeForms['coborrower'] as List?;
          if (coborrowerIncomeData != null) {
            _coborrowerIncomeForms[clientId] = coborrowerIncomeData
                .map((data) => IncomeFormModel.fromMap(data))
                .toList();
            // Asigură-te că există întotdeauna un formular gol la sfârșit
            if (_coborrowerIncomeForms[clientId]!.isEmpty || !_coborrowerIncomeForms[clientId]!.last.isEmpty) {
              _coborrowerIncomeForms[clientId]!.add(IncomeFormModel());
            }
          }
        }
        
        // Încarcă starea UI
        _showingClientLoanForm[clientId] = formData['showingClientLoanForm'] ?? true;
        _showingClientIncomeForm[clientId] = formData['showingClientIncomeForm'] ?? true;
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading form data for client $clientId: $e');
    }
  }

  /// Salvează datele formularului pentru un client
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

  /// Curăță datele pentru un client
  void clearFormDataForClient(String clientId) {
    _clientCreditForms[clientId] = [CreditFormModel()];
    _coborrowerCreditForms[clientId] = [CreditFormModel()];
    _clientIncomeForms[clientId] = [IncomeFormModel()];
    _coborrowerIncomeForms[clientId] = [IncomeFormModel()];
    _showingClientLoanForm[clientId] = true;
    _showingClientIncomeForm[clientId] = true;
    notifyListeners();
  }

  /// Pregătește datele pentru export
  Map<String, dynamic> prepareDataForExport() {
    final result = <String, dynamic>{};
    
    // Iterează prin toți clienții cu date
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
}

