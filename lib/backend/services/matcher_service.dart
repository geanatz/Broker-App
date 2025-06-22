import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'form_service.dart';
import 'clients_service.dart';
import 'settings_service.dart';

/// Enum pentru tipul de gen al clientului
enum ClientGender { male, female }

/// Model pentru criteriile de creditare ale unei banci
class BankCriteria {
  final String bankName;
  double minIncome; // venitul minim necesar
  int maxAgeMale; // varsta maxima pentru barbati
  int maxAgeFemale; // varsta maxima pentru femei
  double minFicoScore; // scorul FICO minim
  double maxLoanAmount; // suma maxima de credit care poate fi acordata (in lei)

  BankCriteria({
    required this.bankName,
    required this.minIncome,
    required this.maxAgeMale,
    required this.maxAgeFemale,
    required this.minFicoScore,
    required this.maxLoanAmount,
  });

  /// Converteste la Map pentru salvare
  Map<String, dynamic> toMap() {
    return {
      'bankName': bankName,
      'minIncome': minIncome,
      'maxAgeMale': maxAgeMale,
      'maxAgeFemale': maxAgeFemale,
      'minFicoScore': minFicoScore,
      'maxLoanAmount': maxLoanAmount,
    };
  }

  /// Creeaza din Map
  factory BankCriteria.fromMap(Map<String, dynamic> map) {
    return BankCriteria(
      bankName: map['bankName'] ?? '',
      minIncome: (map['minIncome'] ?? 0).toDouble(),
      maxAgeMale: map['maxAgeMale'] ?? 65,
      maxAgeFemale: map['maxAgeFemale'] ?? 62,
      minFicoScore: (map['minFicoScore'] ?? 0).toDouble(),
      maxLoanAmount: (map['maxLoanAmount'] ?? (map['loanMultiplier'] ?? 5.0).toDouble() * 10000).toDouble(), // Migration fallback
    );
  }

  @override
  String toString() {
    return 'BankCriteria{bankName: $bankName, minIncome: $minIncome, maxAge: $maxAgeMale/$maxAgeFemale, minFico: $minFicoScore}';
  }
}

/// Model pentru profilul unui client pentru analiza creditarii
class ClientProfile {
  final double totalIncome;
  final int age;
  final ClientGender gender;
  final double ficoScore;
  final String name;
  final String phoneNumber;

  ClientProfile({
    required this.totalIncome,
    required this.age,
    required this.gender,
    required this.ficoScore,
    required this.name,
    required this.phoneNumber,
  });

  @override
  String toString() {
    return 'ClientProfile{name: $name, income: $totalIncome, age: $age, gender: $gender, fico: $ficoScore}';
  }
}

/// Model pentru o recomandare de banca
class BankRecommendation {
  final BankCriteria bankCriteria;
  final bool isEligible;
  final List<String> failedCriteria;
  final double matchScore; // Scor de compatibilitate (0-100)

  BankRecommendation({
    required this.bankCriteria,
    required this.isEligible,
    required this.failedCriteria,
    required this.matchScore,
  });

  @override
  String toString() {
    return 'BankRecommendation{bank: ${bankCriteria.bankName}, eligible: $isEligible, score: $matchScore}';
  }
}

/// Model pentru datele din interfata
class MatcherUIData {
  final List<BankRecommendation> recommendations;
  final String? errorMessage;
  final double totalIncome;
  final bool isLoading;

  MatcherUIData({
    required this.recommendations,
    this.errorMessage,
    required this.totalIncome,
    this.isLoading = false,
  });
}

/// Service pentru gestionarea criteriilor de creditare si recomandarilor
class MatcherService extends ChangeNotifier {
  static final MatcherService _instance = MatcherService._internal();
  factory MatcherService() => _instance;
  MatcherService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FormService _formService = FormService();
  final ClientUIService _clientService = ClientUIService();
  final SettingsService _settingsService = SettingsService();
  
  // Prefixe pentru chei per consultant
  static const String _bankCriteriaPrefix = 'bank_criteria_';
  
  // Lista de criterii pentru toate bancile
  List<BankCriteria> _bankCriteriaList = [];
  
  // Controllere pentru campurile de input
  final TextEditingController ageController = TextEditingController();
  final TextEditingController ficoController = TextEditingController();
  
  // Datele pentru UI
  MatcherUIData _uiData = MatcherUIData(
    recommendations: [],
    totalIncome: 0,
    isLoading: false,
  );

  // Date client
  final ClientGender _gender = ClientGender.male;

  // Map pentru iconitele bancilor
  final Map<String, String> bankIcons = {
    'BCR': 'assets/bcrIcon.svg',
    'BRD': 'assets/brdIcon.svg',
    'Raiffeisen': 'assets/raiffeisenIcon.svg',
    'ING': 'assets/ingIcon.svg',
    'Garanti': 'assets/garantiIcon.svg',
    'CEC': 'assets/cecIcon.svg',
    'BT': 'assets/btIcon.svg',
    'Alpha Bank': 'assets/alphaIcon.svg',
  };

  // Getters
  List<BankCriteria> get bankCriteriaList => List.unmodifiable(_bankCriteriaList);
  MatcherUIData get uiData => _uiData;
  
  /// Obtine ID-ul consultantului curent
  String? get _consultantId => _auth.currentUser?.uid;

  /// Initializeaza service-ul cu criteriile implicite
  Future<void> initialize() async {
    try {
      await _loadBankCriteria();
      await _settingsService.initialize();
      
      _formService.addListener(_onFormServiceChanged);
      _clientService.addListener(_onClientServiceChanged);
      
      await _loadClientData();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing MatcherService: $e');
      // In cazul unei erori, folosim criteriile implicite
      _setDefaultCriteria();
      notifyListeners();
    }
  }

  /// Callback pentru schimbarile din servicii
  void _onFormServiceChanged() {
    _loadClientData();
  }

  void _onClientServiceChanged() {
    _loadClientData();
  }

  /// Incarca datele de baza ale clientului
  Future<void> _loadClientData() async {
    try {
      final currentClient = _clientService.focusedClient;
      debugPrint('🔍 MATCHER_SERVICE: Loading client data for: ${currentClient?.name ?? 'null'}');
      
      if (currentClient == null) {
        debugPrint('⚠️ MATCHER_SERVICE: No focused client found');
        _updateUIData(
          totalIncome: 0,
          errorMessage: 'Nu este selectat niciun client',
          recommendations: [],
        );
        return;
      }

      // Calculeaza venitul total din formulare
      final clientIncomeForms = _formService.getClientIncomeForms(currentClient.phoneNumber);
      final coborrowerIncomeForms = _formService.getCoborrowerIncomeForms(currentClient.phoneNumber);
      
      debugPrint('📊 MATCHER_SERVICE: Found ${clientIncomeForms.length} client income forms and ${coborrowerIncomeForms.length} coborrower income forms');
      
      double totalIncome = 0;
      
      // Adauga veniturile clientului
      for (final income in clientIncomeForms) {
        if (income.incomeAmount.isNotEmpty && !income.isEmpty) {
          final amount = double.tryParse(income.incomeAmount.replaceAll(',', '')) ?? 0;
          totalIncome += amount;
          debugPrint('💰 MATCHER_SERVICE: Added client income: $amount lei');
        }
      }
      
      // Adauga veniturile coborrower-ului
      for (final income in coborrowerIncomeForms) {
        if (income.incomeAmount.isNotEmpty && !income.isEmpty) {
          final amount = double.tryParse(income.incomeAmount.replaceAll(',', '')) ?? 0;
          totalIncome += amount;
          debugPrint('💰 MATCHER_SERVICE: Added coborrower income: $amount lei');
        }
      }

      debugPrint('💵 MATCHER_SERVICE: Total income calculated: $totalIncome lei');

      _updateUIData(
        totalIncome: totalIncome,
        errorMessage: totalIncome <= 0 ? 'Nu exista date de venit pentru client' : null,
        recommendations: [],
      );

      // Actualizeaza automat recomandarile daca avem date complete
      _updateRecommendations();

    } catch (e) {
      debugPrint('❌ MATCHER_SERVICE: Error loading client data: $e');
      _updateUIData(
        totalIncome: 0,
        errorMessage: 'Eroare la incarcarea datelor clientului: $e',
        recommendations: [],
      );
    }
  }

  /// Actualizeaza recomandarile bazate pe datele introduse
  void updateRecommendations() {
    _updateRecommendations();
  }

  void _updateRecommendations() {
    // Validare 1: Verifica daca clientul are venit
    if (_uiData.totalIncome <= 0) {
      _updateUIData(
        totalIncome: _uiData.totalIncome,
        errorMessage: 'Nu exista date de venit pentru client',
        recommendations: [],
      );
      return;
    }

    final ageText = ageController.text.trim();
    final ficoText = ficoController.text.trim();

    // Validare 2: Verifica daca varsta si fico sunt introduse
    if (ageText.isEmpty || ageText == '0') {
      _updateUIData(
        totalIncome: _uiData.totalIncome,
        errorMessage: 'Introduceti varsta clientului',
        recommendations: [],
      );
      return;
    }

    if (ficoText.isEmpty || ficoText == '0') {
      _updateUIData(
        totalIncome: _uiData.totalIncome,
        errorMessage: 'Introduceti scorul FICO al clientului',
        recommendations: [],
      );
      return;
    }

    final age = int.tryParse(ageText);
    final fico = double.tryParse(ficoText);

    if (age == null || fico == null || age <= 0 || fico <= 0) {
      _updateUIData(
        totalIncome: _uiData.totalIncome,
        errorMessage: 'Varsta si scorul FICO trebuie sa fie valori pozitive',
        recommendations: [],
      );
      return;
    }

    // Creeaza profilul clientului
    final clientProfile = ClientProfile(
      totalIncome: _uiData.totalIncome,
      age: age,
      gender: _gender,
      ficoScore: fico,
      name: _clientService.focusedClient?.name ?? 'Client',
      phoneNumber: _clientService.focusedClient?.phoneNumber ?? '',
    );

    // Genereaza recomandarile
    final recommendations = generateRecommendations(clientProfile);
    
    // Filtreaza doar bancile eligibile
    final eligibleRecommendations = recommendations.where((r) => r.isEligible).toList();
    
    // Validare 3: Verifica daca clientul indeplineste criteriile vreunei banci
    if (eligibleRecommendations.isEmpty) {
      _updateUIData(
        totalIncome: _uiData.totalIncome,
        errorMessage: 'Nu exista banci care sa indeplineasca criteriile clientului',
        recommendations: [],
      );
      return;
    }
    
    // Sorteaza dupa scor
    eligibleRecommendations.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    // Toate validarile au trecut, afiseaza recomandarile
    _updateUIData(
      totalIncome: _uiData.totalIncome,
      errorMessage: null,
      recommendations: eligibleRecommendations,
    );
  }

  /// Actualizeaza datele pentru UI
  void _updateUIData({
    required double totalIncome,
    String? errorMessage,
    required List<BankRecommendation> recommendations,
    bool isLoading = false,
  }) {
    _uiData = MatcherUIData(
      totalIncome: totalIncome,
      errorMessage: errorMessage,
      recommendations: recommendations,
      isLoading: isLoading,
    );
    notifyListeners();
  }

  /// Calculeaza suma de credit pe care o poate oferi banca
  double calculateLoanAmount(String bankName) {
    // Gaseste criteriile bancii si returneaza suma maxima configurata
    final criteria = getBankCriteria(bankName);
    if (criteria != null) {
      debugPrint('💰 MATCHER_SERVICE: calculateLoanAmount for $bankName = ${criteria.maxLoanAmount} lei');
      return criteria.maxLoanAmount;
    }
    // Fallback pentru banci necunoscute
    debugPrint('⚠️ MATCHER_SERVICE: Bank $bankName not found, using fallback amount');
    return 50000.0; // 50.000 lei fallback
  }

  /// Callback pentru schimbarea valorii din campul de varsta
  void onAgeChanged(String value) {
    _updateRecommendations();
  }

  /// Callback pentru schimbarea valorii din campul FICO
  void onFicoChanged(String value) {
    _updateRecommendations();
  }

  /// Forteaza actualizarea datelor clientului (pentru rezolvarea problemelor de sincronizare)
  Future<void> refreshClientData() async {
    debugPrint('🔄 MATCHER_SERVICE: Force refreshing client data...');
    
    // Asteapta un pic pentru ca FormService sa isi termine incarcarea
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Reincarca datele clientului
    await _loadClientData();
    
    debugPrint('✅ MATCHER_SERVICE: Client data refreshed');
  }

  @override
  void dispose() {
    ageController.dispose();
    ficoController.dispose();
    _formService.removeListener(_onFormServiceChanged);
    _clientService.removeListener(_onClientServiceChanged);
    super.dispose();
  }

  /// Incarca criteriile bancilor din SharedPreferences
  Future<void> _loadBankCriteria() async {
    final prefs = await SharedPreferences.getInstance();
    final consultantId = _consultantId;
    
    if (consultantId != null) {
      final criteriaJson = prefs.getString('$_bankCriteriaPrefix$consultantId');
      
      if (criteriaJson != null) {
        try {
          final List<dynamic> criteriaList = json.decode(criteriaJson);
          final loadedCriteria = criteriaList
              .map((criteria) => BankCriteria.fromMap(criteria))
              .toList();
          
          // FIX: Verifică dacă criteriile încărcate sunt din versiunea veche (cu valori mici pentru maxLoanAmount)
          bool hasOldCriteria = false;
          for (final criteria in loadedCriteria) {
            if (criteria.maxLoanAmount < 100000) { // Dacă maxLoanAmount e sub 100.000, sunt criterii vechi
              hasOldCriteria = true;
              break;
            }
          }
          
          if (hasOldCriteria) {
            debugPrint('⚠️ MATCHER_SERVICE: Detected old criteria with small maxLoanAmount values, updating to new defaults');
            _setDefaultCriteria();
            await _saveBankCriteria(); // Salvează noile criterii
          } else {
            _bankCriteriaList = loadedCriteria;
            debugPrint('✅ MATCHER_SERVICE: Loaded ${_bankCriteriaList.length} up-to-date bank criteria');
          }
        } catch (e) {
          debugPrint('❌ MATCHER_SERVICE: Error parsing bank criteria: $e');
          _setDefaultCriteria();
        }
      } else {
        // Nu exista criterii salvate, folosim criteriile implicite
        debugPrint('ℹ️ MATCHER_SERVICE: No saved criteria found, using defaults');
        _setDefaultCriteria();
      }
    } else {
      _setDefaultCriteria();
    }
  }

  /// Seteaza criteriile implicite pentru banci
  void _setDefaultCriteria() {
    _bankCriteriaList = [
      BankCriteria(
        bankName: 'BCR',
        minIncome: 2500,
        maxAgeMale: 60,
        maxAgeFemale: 58,
        minFicoScore: 600,
        maxLoanAmount: 200000,
      ),
      BankCriteria(
        bankName: 'BRD',
        minIncome: 2000,
        maxAgeMale: 60,
        maxAgeFemale: 58,
        minFicoScore: 0,
        maxLoanAmount: 250000,
      ),
      BankCriteria(
        bankName: 'Raiffeisen',
        minIncome: 1500,
        maxAgeMale: 60,
        maxAgeFemale: 58,
        minFicoScore: 600,
        maxLoanAmount: 250000,
      ),
      BankCriteria(
        bankName: 'CEC Bank',
        minIncome: 2500,
        maxAgeMale: 62,
        maxAgeFemale: 59,
        minFicoScore: 540,
        maxLoanAmount: 200000,
      ),
      BankCriteria(
        bankName: 'ING',
        minIncome: 3000,
        maxAgeMale: 60,
        maxAgeFemale: 58,
        minFicoScore: 0,
        maxLoanAmount: 200000,
      ),
      BankCriteria(
        bankName: 'Garanti',
        minIncome: 2500,
        maxAgeMale: 63,
        maxAgeFemale: 60,
        minFicoScore: 420,
        maxLoanAmount: 200000,
      ),
    ];
    debugPrint('🏦 MATCHER_SERVICE: Set default bank criteria (${_bankCriteriaList.length} banks)');
    
    // FIX: Debug pentru a verifica valorile setate
    for (final criteria in _bankCriteriaList) {
      debugPrint('  - ${criteria.bankName}: maxLoanAmount = ${criteria.maxLoanAmount} lei');
    }
  }

  /// Salveaza criteriile bancilor in SharedPreferences
  Future<void> _saveBankCriteria() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consultantId = _consultantId;
      
      if (consultantId != null) {
        final criteriaJson = json.encode(
          _bankCriteriaList.map((criteria) => criteria.toMap()).toList()
        );
        await prefs.setString('$_bankCriteriaPrefix$consultantId', criteriaJson);
        debugPrint('Saved bank criteria for consultant');
      }
    } catch (e) {
      debugPrint('Error saving bank criteria: $e');
    }
  }

  /// Actualizeaza criteriile pentru o banca specifica
  Future<void> updateBankCriteria(BankCriteria updatedCriteria) async {
    final index = _bankCriteriaList.indexWhere(
      (criteria) => criteria.bankName == updatedCriteria.bankName
    );
    
    if (index != -1) {
      _bankCriteriaList[index] = updatedCriteria;
    } else {
      _bankCriteriaList.add(updatedCriteria);
    }
    
    await _saveBankCriteria();
    notifyListeners();
    debugPrint('Updated criteria for bank: ${updatedCriteria.bankName}');
  }

  /// Obtine criteriile pentru o banca specifica
  BankCriteria? getBankCriteria(String bankName) {
    try {
      return _bankCriteriaList.firstWhere(
        (criteria) => criteria.bankName == bankName
      );
    } catch (e) {
      return null;
    }
  }

  /// Analizeaza eligibilitatea unui client pentru o banca specifica
  BankRecommendation analyzeClientEligibility(ClientProfile client, BankCriteria bankCriteria) {
    final List<String> failedCriteria = [];
    double matchScore = 100.0;

    // Verifica venitul
    if (client.totalIncome < bankCriteria.minIncome) {
      failedCriteria.add('Venit insuficient (${client.totalIncome.toStringAsFixed(0)} < ${bankCriteria.minIncome.toStringAsFixed(0)} lei)');
      matchScore -= 30;
    }

    // Verifica varsta in functie de gen
    final maxAge = client.gender == ClientGender.male 
        ? bankCriteria.maxAgeMale 
        : bankCriteria.maxAgeFemale;
    
    if (client.age > maxAge) {
      failedCriteria.add('Varsta prea mare (${client.age} > $maxAge ani)');
      matchScore -= 25;
    }

    // Verifica scorul FICO
    if (client.ficoScore < bankCriteria.minFicoScore) {
      failedCriteria.add('Scor FICO insuficient (${client.ficoScore.toStringAsFixed(0)} < ${bankCriteria.minFicoScore.toStringAsFixed(0)})');
      matchScore -= 45;
    }

    // Calculeaza bonus pentru supraindeplinirea criteriilor
    if (failedCriteria.isEmpty) {
      // Bonus pentru venit superior
      if (client.totalIncome > bankCriteria.minIncome * 1.5) {
        matchScore += 10;
      }
      
      // Bonus pentru scor FICO superior
      if (client.ficoScore > bankCriteria.minFicoScore * 1.2) {
        matchScore += 5;
      }
    }

    // Asigura ca scorul este intre 0 si 100
    matchScore = matchScore.clamp(0.0, 100.0);

    final isEligible = failedCriteria.isEmpty;

    return BankRecommendation(
      bankCriteria: bankCriteria,
      isEligible: isEligible,
      failedCriteria: failedCriteria,
      matchScore: matchScore,
    );
  }

  /// Genereaza recomandari pentru toate bancile pentru un client
  List<BankRecommendation> generateRecommendations(ClientProfile client) {
    final recommendations = _bankCriteriaList
        .map((criteria) => analyzeClientEligibility(client, criteria))
        .toList();

    // Sorteaza recomandarile: mai intai bancile eligibile (dupa scor descrescator),
    // apoi bancile neeligibile (dupa scor descrescator)
    recommendations.sort((a, b) {
      if (a.isEligible && !b.isEligible) return -1;
      if (!a.isEligible && b.isEligible) return 1;
      return b.matchScore.compareTo(a.matchScore);
    });

    debugPrint('Generated ${recommendations.length} recommendations for client: ${client.name}');
    for (final rec in recommendations) {
      debugPrint('  ${rec.bankCriteria.bankName}: ${rec.isEligible ? 'ELIGIBLE' : 'NOT ELIGIBLE'} (${rec.matchScore.toStringAsFixed(1)}%)');
    }

    return recommendations;
  }

  /// Reset la criteriile implicite
  Future<void> resetToDefaults() async {
    _setDefaultCriteria();
    await _saveBankCriteria();
    notifyListeners();
    debugPrint('🔄 MATCHER_SERVICE: Reset bank criteria to defaults');
  }
  
  /// FIX: Forțează actualizarea la criteriile noi pentru toate consultantii
  Future<void> forceUpdateToNewCriteria() async {
    debugPrint('🔧 MATCHER_SERVICE: Force updating to new criteria with higher maxLoanAmount values');
    _setDefaultCriteria();
    await _saveBankCriteria();
    notifyListeners();
    debugPrint('✅ MATCHER_SERVICE: Successfully updated to new criteria');
  }

  /// Sterge toate criteriile pentru un consultant (folosit la stergerea contului)
  Future<void> clearConsultantData(String consultantId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_bankCriteriaPrefix$consultantId');
      debugPrint('Cleared bank criteria for consultant: $consultantId');
    } catch (e) {
      debugPrint('Error clearing consultant data: $e');
    }
  }

  /// Actualizeaza datele cand se schimba consultantul
  Future<void> onConsultantChanged() async {
    await _loadBankCriteria();
    notifyListeners();
  }
}
