import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'form_service.dart';
import 'clients_service.dart';
import 'settings_service.dart';

/// Enum pentru tipul de gen al clientului
enum ClientGender { male, female }

/// Model pentru criteriile de creditare ale unei bănci
class BankCriteria {
  final String bankName;
  double minIncome; // venitul minim necesar
  int maxAgeMale; // vârsta maximă pentru bărbați
  int maxAgeFemale; // vârsta maximă pentru femei
  double minFicoScore; // scorul FICO minim
  double maxLoanAmount; // suma maximă de credit care poate fi acordată (în lei)

  BankCriteria({
    required this.bankName,
    required this.minIncome,
    required this.maxAgeMale,
    required this.maxAgeFemale,
    required this.minFicoScore,
    required this.maxLoanAmount,
  });

  /// Convertește la Map pentru salvare
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

  /// Creează din Map
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

/// Model pentru profilul unui client pentru analiza creditării
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

/// Model pentru o recomandare de bancă
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

/// Model pentru datele din interfață
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

/// Service pentru gestionarea criteriilor de creditare și recomandărilor
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
  
  // Lista de criterii pentru toate băncile
  List<BankCriteria> _bankCriteriaList = [];
  
  // Controllere pentru câmpurile de input
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

  // Map pentru iconițele băncilor
  final Map<String, String> bankIcons = {
    'BCR': 'assets/bcrIcon.svg',
    'BRD': 'assets/brdIcon.svg',
    'Raiffeisen': 'assets/raiffeisenIcon.svg',
    'UniCredit': 'assets/btIcon.svg', // Folosim BT pentru UniCredit temporar
    'ING': 'assets/ingIcon.svg',
    'Garanti': 'assets/garantiIcon.svg',
    'CEC': 'assets/cecIcon.svg',
    'BT': 'assets/btIcon.svg',
    'Alpha Bank': 'assets/alphaIcon.svg',
  };

  // Getters
  List<BankCriteria> get bankCriteriaList => List.unmodifiable(_bankCriteriaList);
  MatcherUIData get uiData => _uiData;
  
  /// Obține ID-ul consultantului curent
  String? get _consultantId => _auth.currentUser?.uid;

  /// Inițializează service-ul cu criteriile implicite
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
      // În cazul unei erori, folosim criteriile implicite
      _setDefaultCriteria();
      notifyListeners();
    }
  }

  /// Callback pentru schimbările din servicii
  void _onFormServiceChanged() {
    _loadClientData();
  }

  void _onClientServiceChanged() {
    _loadClientData();
  }

  /// Încarcă datele de bază ale clientului
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

      // Calculează venitul total din formulare
      final clientIncomeForms = _formService.getClientIncomeForms(currentClient.phoneNumber);
      final coborrowerIncomeForms = _formService.getCoborrowerIncomeForms(currentClient.phoneNumber);
      
      debugPrint('📊 MATCHER_SERVICE: Found ${clientIncomeForms.length} client income forms and ${coborrowerIncomeForms.length} coborrower income forms');
      
      double totalIncome = 0;
      
      // Adaugă veniturile clientului
      for (final income in clientIncomeForms) {
        if (income.incomeAmount.isNotEmpty && !income.isEmpty) {
          final amount = double.tryParse(income.incomeAmount.replaceAll(',', '')) ?? 0;
          totalIncome += amount;
          debugPrint('💰 MATCHER_SERVICE: Added client income: $amount lei');
        }
      }
      
      // Adaugă veniturile coborrower-ului
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
        errorMessage: totalIncome <= 0 ? 'Nu există date de venit pentru client' : null,
        recommendations: [],
      );

      // Actualizează automat recomandările dacă avem date complete
      _updateRecommendations();

    } catch (e) {
      debugPrint('❌ MATCHER_SERVICE: Error loading client data: $e');
      _updateUIData(
        totalIncome: 0,
        errorMessage: 'Eroare la încărcarea datelor clientului: $e',
        recommendations: [],
      );
    }
  }

  /// Actualizează recomandările bazate pe datele introduse
  void updateRecommendations() {
    _updateRecommendations();
  }

  void _updateRecommendations() {
    if (_uiData.totalIncome <= 0) {
      _updateUIData(
        totalIncome: _uiData.totalIncome,
        errorMessage: _uiData.errorMessage,
        recommendations: [],
      );
      return;
    }

    final ageText = ageController.text.trim();
    final ficoText = ficoController.text.trim();

    if (ageText.isEmpty || ficoText.isEmpty) {
      _updateUIData(
        totalIncome: _uiData.totalIncome,
        errorMessage: _uiData.errorMessage,
        recommendations: [],
      );
      return;
    }

    final age = int.tryParse(ageText);
    final fico = double.tryParse(ficoText);

    if (age == null || fico == null || age <= 0 || fico <= 0) {
      _updateUIData(
        totalIncome: _uiData.totalIncome,
        errorMessage: _uiData.errorMessage,
        recommendations: [],
      );
      return;
    }

    // Creează profilul clientului
    final clientProfile = ClientProfile(
      totalIncome: _uiData.totalIncome,
      age: age,
      gender: _gender,
      ficoScore: fico,
      name: _clientService.focusedClient?.name ?? 'Client',
      phoneNumber: _clientService.focusedClient?.phoneNumber ?? '',
    );

    // Generează recomandările
    final recommendations = generateRecommendations(clientProfile);
    
    // Filtrează doar băncile eligibile
    final eligibleRecommendations = recommendations.where((r) => r.isEligible).toList();
    
    // Sortează după scor
    eligibleRecommendations.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    _updateUIData(
      totalIncome: _uiData.totalIncome,
      errorMessage: _uiData.errorMessage,
      recommendations: eligibleRecommendations,
    );
  }

  /// Actualizează datele pentru UI
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

  /// Calculează suma de credit pe care o poate oferi banca
  double calculateLoanAmount(String bankName) {
    // Găsește criteriile băncii și returnează suma maximă configurată
    final criteria = getBankCriteria(bankName);
    if (criteria != null) {
      return criteria.maxLoanAmount;
    }
    // Fallback pentru bănci necunoscute
    return 50000.0; // 50.000 lei fallback
  }

  /// Callback pentru schimbarea valorii din câmpul de vârstă
  void onAgeChanged(String value) {
    _updateRecommendations();
  }

  /// Callback pentru schimbarea valorii din câmpul FICO
  void onFicoChanged(String value) {
    _updateRecommendations();
  }

  /// Forțează actualizarea datelor clientului (pentru rezolvarea problemelor de sincronizare)
  Future<void> refreshClientData() async {
    debugPrint('🔄 MATCHER_SERVICE: Force refreshing client data...');
    
    // Așteaptă un pic pentru ca FormService să își termine încărcarea
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Reîncarcă datele clientului
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

  /// Încarcă criteriile băncilor din SharedPreferences
  Future<void> _loadBankCriteria() async {
    final prefs = await SharedPreferences.getInstance();
    final consultantId = _consultantId;
    
    if (consultantId != null) {
      final criteriaJson = prefs.getString('$_bankCriteriaPrefix$consultantId');
      
      if (criteriaJson != null) {
        try {
          final List<dynamic> criteriaList = json.decode(criteriaJson);
          _bankCriteriaList = criteriaList
              .map((criteria) => BankCriteria.fromMap(criteria))
              .toList();
          debugPrint('Loaded ${_bankCriteriaList.length} bank criteria for consultant');
        } catch (e) {
          debugPrint('Error parsing bank criteria: $e');
          _setDefaultCriteria();
        }
      } else {
        // Nu există criterii salvate, folosim criteriile implicite
        _setDefaultCriteria();
      }
    } else {
      _setDefaultCriteria();
    }
  }

  /// Setează criteriile implicite pentru bănci
  void _setDefaultCriteria() {
    _bankCriteriaList = [
      BankCriteria(
        bankName: 'BCR',
        minIncome: 2500,
        maxAgeMale: 60,
        maxAgeFemale: 57,
        minFicoScore: 500,
        maxLoanAmount: 55000, // 55.000 lei
      ),
      BankCriteria(
        bankName: 'BRD',
        minIncome: 2000,
        maxAgeMale: 63,
        maxAgeFemale: 60,
        minFicoScore: 450,
        maxLoanAmount: 50000, // 50.000 lei
      ),
      BankCriteria(
        bankName: 'Raiffeisen',
        minIncome: 1500,
        maxAgeMale: 65,
        maxAgeFemale: 62,
        minFicoScore: 400,
        maxLoanAmount: 60000, // 60.000 lei
      ),
      BankCriteria(
        bankName: 'UniCredit',
        minIncome: 1800,
        maxAgeMale: 62,
        maxAgeFemale: 59,
        minFicoScore: 400,
        maxLoanAmount: 45000, // 45.000 lei
      ),
      BankCriteria(
        bankName: 'ING',
        minIncome: 2200,
        maxAgeMale: 64,
        maxAgeFemale: 61,
        minFicoScore: 480,
        maxLoanAmount: 52000, // 52.000 lei
      ),
      BankCriteria(
        bankName: 'Garanti',
        minIncome: 1600,
        maxAgeMale: 63,
        maxAgeFemale: 60,
        minFicoScore: 420,
        maxLoanAmount: 48000, // 48.000 lei
      ),
    ];
    debugPrint('Set default bank criteria (${_bankCriteriaList.length} banks)');
  }

  /// Salvează criteriile băncilor în SharedPreferences
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

  /// Actualizează criteriile pentru o bancă specifică
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

  /// Obține criteriile pentru o bancă specifică
  BankCriteria? getBankCriteria(String bankName) {
    try {
      return _bankCriteriaList.firstWhere(
        (criteria) => criteria.bankName == bankName
      );
    } catch (e) {
      return null;
    }
  }

  /// Analizează eligibilitatea unui client pentru o bancă specifică
  BankRecommendation analyzeClientEligibility(ClientProfile client, BankCriteria bankCriteria) {
    final List<String> failedCriteria = [];
    double matchScore = 100.0;

    // Verifică venitul
    if (client.totalIncome < bankCriteria.minIncome) {
      failedCriteria.add('Venit insuficient (${client.totalIncome.toStringAsFixed(0)} < ${bankCriteria.minIncome.toStringAsFixed(0)} lei)');
      matchScore -= 30;
    }

    // Verifică vârsta în funcție de gen
    final maxAge = client.gender == ClientGender.male 
        ? bankCriteria.maxAgeMale 
        : bankCriteria.maxAgeFemale;
    
    if (client.age > maxAge) {
      failedCriteria.add('Vârstă prea mare (${client.age} > $maxAge ani)');
      matchScore -= 25;
    }

    // Verifică scorul FICO
    if (client.ficoScore < bankCriteria.minFicoScore) {
      failedCriteria.add('Scor FICO insuficient (${client.ficoScore.toStringAsFixed(0)} < ${bankCriteria.minFicoScore.toStringAsFixed(0)})');
      matchScore -= 45;
    }

    // Calculează bonus pentru supraîndeplinirea criteriilor
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

    // Asigură că scorul este între 0 și 100
    matchScore = matchScore.clamp(0.0, 100.0);

    final isEligible = failedCriteria.isEmpty;

    return BankRecommendation(
      bankCriteria: bankCriteria,
      isEligible: isEligible,
      failedCriteria: failedCriteria,
      matchScore: matchScore,
    );
  }

  /// Generează recomandări pentru toate băncile pentru un client
  List<BankRecommendation> generateRecommendations(ClientProfile client) {
    final recommendations = _bankCriteriaList
        .map((criteria) => analyzeClientEligibility(client, criteria))
        .toList();

    // Sortează recomandările: mai întâi băncile eligibile (după scor descrescător),
    // apoi băncile neeligibile (după scor descrescător)
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
    debugPrint('Reset bank criteria to defaults');
  }

  /// Șterge toate criteriile pentru un consultant (folosit la ștergerea contului)
  Future<void> clearConsultantData(String consultantId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_bankCriteriaPrefix$consultantId');
      debugPrint('Cleared bank criteria for consultant: $consultantId');
    } catch (e) {
      debugPrint('Error clearing consultant data: $e');
    }
  }

  /// Actualizează datele când se schimbă consultantul
  Future<void> onConsultantChanged() async {
    await _loadBankCriteria();
    notifyListeners();
  }
}
