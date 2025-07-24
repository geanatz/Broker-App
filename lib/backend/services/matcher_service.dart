import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:async';
import 'form_service.dart';
import 'clients_service.dart';
// Added for pow function

/// Enum pentru tipul de gen al clientului
enum ClientGender { male, female }

/// Model pentru criteriile de creditare ale unei banci
class BankCriteria {
  final String bankName;
  double minIncome; // venitul minim necesar
  int minAgeMale; // varsta minima pentru barbati
  int minAgeFemale; // varsta minima pentru femei
  int maxAgeMale; // varsta maxima pentru barbati
  int maxAgeFemale; // varsta maxima pentru femei
  double minFicoScore; // scorul FICO minim
  double maxLoanAmount; // suma maxima de credit care poate fi acordata (in lei)
  int minEmploymentDuration; // durata minima de angajament (in luni)

  BankCriteria({
    required this.bankName,
    required this.minIncome,
    required this.minAgeMale,
    required this.minAgeFemale,
    required this.maxAgeMale,
    required this.maxAgeFemale,
    required this.minFicoScore,
    required this.maxLoanAmount,
    required this.minEmploymentDuration,
  });

  /// Converteste la Map pentru salvare
  Map<String, dynamic> toMap() {
    return {
      'bankName': bankName,
      'minIncome': minIncome,
      'minAgeMale': minAgeMale,
      'minAgeFemale': minAgeFemale,
      'maxAgeMale': maxAgeMale,
      'maxAgeFemale': maxAgeFemale,
      'minFicoScore': minFicoScore,
      'maxLoanAmount': maxLoanAmount,
      'minEmploymentDuration': minEmploymentDuration,
    };
  }

  /// Creeaza din Map
  factory BankCriteria.fromMap(Map<String, dynamic> map) {
    return BankCriteria(
      bankName: map['bankName'] ?? '',
      minIncome: (map['minIncome'] ?? 0).toDouble(),
      minAgeMale: (map['minAgeMale'] ?? 21) as int,
      minAgeFemale: (map['minAgeFemale'] ?? 21) as int,
      maxAgeMale: (map['maxAgeMale'] ?? 65) as int,
      maxAgeFemale: (map['maxAgeFemale'] ?? 62) as int,
      minFicoScore: (map['minFicoScore'] ?? 0).toDouble(),
      maxLoanAmount: (map['maxLoanAmount'] ?? (map['loanMultiplier'] ?? 5.0).toDouble() * 10000).toDouble(), // Migration fallback
      minEmploymentDuration: (map['minEmploymentDuration'] ?? 6) as int, // Default 6 months
    );
  }

  @override
  String toString() {
    return 'BankCriteria{bankName: $bankName, minIncome: $minIncome, minAge: $minAgeMale/$minAgeFemale, maxAge: $maxAgeMale/$maxAgeFemale, minFico: $minFicoScore, minEmployment: ${minEmploymentDuration}luni}';
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
  final int employmentDuration; // durata de angajament (in luni)

  ClientProfile({
    required this.totalIncome,
    required this.age,
    required this.gender,
    required this.ficoScore,
    required this.name,
    required this.phoneNumber,
    required this.employmentDuration,
  });

  @override
  String toString() {
    return 'ClientProfile{name: $name, income: $totalIncome, age: $age, gender: $gender, fico: $ficoScore, employment: ${employmentDuration}luni}';
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
  ClientGender _gender = ClientGender.male;
  
  // Debouncing pentru refreshClientData
  Timer? _refreshDebounceTimer;
  bool _isRefreshing = false;
  
  // OPTIMIZARE: Cache pentru calculele de venituri
  final Map<String, double> _incomeCache = {};
  final Map<String, DateTime> _incomeCacheTime = {};
  Timer? _incomeCacheCleanupTimer;

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
  ClientGender get gender => _gender;
  
  /// Obtine ID-ul consultantului curent
  String? get _consultantId => _auth.currentUser?.uid;

  /// Actualizeaza genul clientului si reanalizeaza recomandarile
  void updateGender(ClientGender newGender) {
    if (_gender != newGender) {
      _gender = newGender;
      _updateRecommendations();
      notifyListeners();
    }
  }

  /// Initializeaza service-ul cu criteriile implicite
  Future<void> initialize() async {
    try {
      await _loadBankCriteria();
      
      _formService.addListener(_onFormServiceChanged);
      _clientService.addListener(_onClientServiceChanged);
      
      await _loadClientData();
      
      // OPTIMIZARE: Configurează curățarea automată a cache-ului de venituri
      _setupIncomeCacheCleanup();
      

      
      // OPTIMIZARE: Folosește microtask pentru a evita notifyListeners în timpul build
      Future.microtask(() {
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error initializing MatcherService: $e');
      // In cazul unei erori, folosim criteriile implicite
      _setDefaultCriteria();
      // OPTIMIZARE: Folosește microtask pentru a evita notifyListeners în timpul build
      Future.microtask(() {
        notifyListeners();
      });
    }
  }

  /// OPTIMIZARE: Configurează curățarea automată a cache-ului
  void _setupIncomeCacheCleanup() {
    _incomeCacheCleanupTimer?.cancel();
    _incomeCacheCleanupTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      final now = DateTime.now();
      final keysToRemove = <String>[];
      
      for (final entry in _incomeCacheTime.entries) {
        if (now.difference(entry.value).inMinutes > 5) {
          keysToRemove.add(entry.key);
        }
      }
      
      for (final key in keysToRemove) {
        _incomeCache.remove(key);
        _incomeCacheTime.remove(key);
      }
      
      if (keysToRemove.isNotEmpty) {
    
      }
    });
  }

  /// OPTIMIZAT: Callback pentru schimbarile din servicii cu debouncing
  void _onFormServiceChanged() {
    // OPTIMIZARE: Invalidează cache-ul de venituri când formularele se schimbă
    _incomeCache.clear();
    _incomeCacheTime.clear();
    // OPTIMIZARE: Folosește addPostFrameCallback pentru a evita notifyListeners în timpul build
    Future.microtask(() => _loadClientData());
  }

  void _onClientServiceChanged() {
    // OPTIMIZARE: Invalidează cache-ul când clientul se schimbă
    _incomeCache.clear();
    _incomeCacheTime.clear();
    // OPTIMIZARE: Folosește addPostFrameCallback pentru a evita notifyListeners în timpul build
    Future.microtask(() => _loadClientData());
  }

  /// OPTIMIZAT: Incarca datele de baza ale clientului cu caching
  Future<void> _loadClientData() async {
    try {
      final currentClient = _clientService.focusedClient;
      
      if (currentClient == null) {
        _updateUIData(
          totalIncome: 0,
          errorMessage: 'Nu este selectat niciun client',
          recommendations: [],
        );
        return;
      }

      // OPTIMIZARE: Verifică cache-ul pentru calculul veniturilor
      final cacheKey = currentClient.phoneNumber;
      final cachedIncome = _incomeCache[cacheKey];
      final cacheTime = _incomeCacheTime[cacheKey];
      
      // OPTIMIZARE: Folosește cache-ul dacă e valid (mai nou de 2 minute)
      if (cachedIncome != null && cacheTime != null && 
          DateTime.now().difference(cacheTime).inMinutes < 2) {
        
        _updateUIData(
          totalIncome: cachedIncome,
          errorMessage: cachedIncome <= 0 ? 'Nu exista date de venit pentru client' : null,
          recommendations: [],
        );
        
        // Actualizeaza automat recomandarile daca avem date complete
        _updateRecommendations();
        return;
      }

      // OPTIMIZARE: Calculează venitul doar dacă nu e în cache
      final clientIncomeForms = _formService.getClientIncomeForms(currentClient.phoneNumber);
      final coborrowerIncomeForms = _formService.getCoborrowerIncomeForms(currentClient.phoneNumber);
      
      // Loading income forms for calculation
      
      double totalIncome = 0;
      
      // Adauga veniturile clientului
      for (final income in clientIncomeForms) {
        if (income.incomeAmount.isNotEmpty && !income.isEmpty) {
          final amount = double.tryParse(income.incomeAmount.replaceAll(',', '')) ?? 0;
          totalIncome += amount;
        }
      }
      
      // Adauga veniturile coborrower-ului
      for (final income in coborrowerIncomeForms) {
        if (income.incomeAmount.isNotEmpty && !income.isEmpty) {
          final amount = double.tryParse(income.incomeAmount.replaceAll(',', '')) ?? 0;
          totalIncome += amount;
        }
      }

      // OPTIMIZARE: Salvează în cache
      _incomeCache[cacheKey] = totalIncome;
      _incomeCacheTime[cacheKey] = DateTime.now();

      // Total income calculated

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
      employmentDuration: extractEmploymentDuration(),
    );

    // Validare 4: Verifica daca exista date despre vechimea la locul de munca
    if (clientProfile.employmentDuration <= 0) {
      _updateUIData(
        totalIncome: _uiData.totalIncome,
        errorMessage: 'Nu exista date despre vechimea la locul de munca a clientului',
        recommendations: [],
      );
      return;
    }

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
    
    // OPTIMIZARE: Folosește microtask pentru a evita notifyListeners în timpul build
    Future.microtask(() {
      notifyListeners();
    });
  }

  /// Calculeaza suma de credit pe care o poate oferi banca
  double calculateLoanAmount(String bankName) {
    // Gaseste criteriile bancii si returneaza suma maxima configurata
    final criteria = getBankCriteria(bankName);
    if (criteria != null) {
      return criteria.maxLoanAmount;
    }
    // Fallback pentru banci necunoscute
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

  /// Forteaza actualizarea datelor clientului cu debouncing pentru evitarea apelurilor multiple
  Future<void> refreshClientData() async {
    // Anulează refresh-ul anterior dacă există unul pending
    _refreshDebounceTimer?.cancel();
    
    // Dacă deja se reîmprospătează, nu mai face alt request
    if (_isRefreshing) return;
    
    // Debouncing: așteaptă 300ms înainte de a executa
    _refreshDebounceTimer = Timer(const Duration(milliseconds: 300), () async {
      await _performRefreshClientData();
    });
  }

  /// Execută refresh-ul efectiv al datelor clientului
  Future<void> _performRefreshClientData() async {
    if (_isRefreshing) return;
    
    try {
      _isRefreshing = true;
      
      // Asteapta un pic pentru ca FormService sa isi termine incarcarea
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Reincarca datele clientului
      await _loadClientData();
      
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  void dispose() {
    ageController.dispose();
    ficoController.dispose();
    _refreshDebounceTimer?.cancel();
    _formService.removeListener(_onFormServiceChanged);
    _clientService.removeListener(_onClientServiceChanged);
    // OPTIMIZARE: Cleanup pentru income cache timer
    _incomeCacheCleanupTimer?.cancel();
    _incomeCache.clear();
    _incomeCacheTime.clear();
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
          
          // FIX: Verifică dacă criteriile încărcate sunt din versiunea veche (cu valori mici pentru maxLoanAmount sau fără minAge)
          bool hasOldCriteria = false;
          for (final criteria in loadedCriteria) {
            if (criteria.maxLoanAmount < 100000 || // Dacă maxLoanAmount e sub 100.000, sunt criterii vechi
                !_hasMinAgeFields(criteria)) { // Sau dacă nu au câmpurile minAge
              hasOldCriteria = true;
              break;
            }
          }
          
          if (hasOldCriteria) {
        
            _setDefaultCriteria();
            await _saveBankCriteria(); // Salvează noile criterii
          } else {
            _bankCriteriaList = loadedCriteria;
        
          }
        } catch (e) {
          _setDefaultCriteria();
        }
      } else {
        // Nu exista criterii salvate, folosim criteriile implicite
    
        _setDefaultCriteria();
      }
    } else {
      _setDefaultCriteria();
    }
  }

  /// Seteaza criteriile implicite pentru bancile principale
  void _setDefaultCriteria() {
    _bankCriteriaList = [
      BankCriteria(
        bankName: 'BCR',
        minIncome: 2500,
        minAgeMale: 21,
        minAgeFemale: 21,
        maxAgeMale: 60,
        maxAgeFemale: 58,
        minFicoScore: 600,
        maxLoanAmount: 200000,
        minEmploymentDuration: 6,
      ),
      BankCriteria(
        bankName: 'BRD',
        minIncome: 2000,
        minAgeMale: 21,
        minAgeFemale: 21,
        maxAgeMale: 60,
        maxAgeFemale: 58,
        minFicoScore: 0,
        maxLoanAmount: 250000,
        minEmploymentDuration: 12,
      ),
      BankCriteria(
        bankName: 'Raiffeisen',
        minIncome: 1500,
        minAgeMale: 21,
        minAgeFemale: 21,
        maxAgeMale: 60,
        maxAgeFemale: 58,
        minFicoScore: 600,
        maxLoanAmount: 250000,
        minEmploymentDuration: 6,
      ),
      BankCriteria(
        bankName: 'CEC Bank',
        minIncome: 2500,
        minAgeMale: 21,
        minAgeFemale: 21,
        maxAgeMale: 62,
        maxAgeFemale: 59,
        minFicoScore: 540,
        maxLoanAmount: 200000,
        minEmploymentDuration: 18,
      ),
      BankCriteria(
        bankName: 'ING',
        minIncome: 3000,
        minAgeMale: 21,
        minAgeFemale: 21,
        maxAgeMale: 60,
        maxAgeFemale: 58,
        minFicoScore: 0,
        maxLoanAmount: 200000,
        minEmploymentDuration: 12,
      ),
      BankCriteria(
        bankName: 'Garanti',
        minIncome: 2500,
        minAgeMale: 21,
        minAgeFemale: 21,
        maxAgeMale: 63,
        maxAgeFemale: 60,
        minFicoScore: 420,
        maxLoanAmount: 200000,
        minEmploymentDuration: 6,
      ),
    ];
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
      }
    } catch (e) {
      // Error saving bank criteria
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

  /// Verifica daca criteriile au câmpurile minAge (pentru migrarea de la versiunea veche)
  bool _hasMinAgeFields(BankCriteria criteria) {
    // Verifică dacă criteriile au câmpurile minAge setate la valori valide
    // Dacă sunt 0 sau null, înseamnă că sunt din versiunea veche
    try {
      return criteria.minAgeMale > 0 && criteria.minAgeFemale > 0;
    } catch (e) {
      return false;
    }
  }

  /// Analizeaza eligibilitatea unui client pentru o banca specifica
  BankRecommendation analyzeClientEligibility(ClientProfile client, BankCriteria bankCriteria) {
    try {
      final List<String> failedCriteria = [];
      double matchScore = 100.0;

      // Verifica venitul
      if (client.totalIncome < bankCriteria.minIncome) {
        failedCriteria.add('Venit insuficient (${client.totalIncome.toStringAsFixed(0)} < ${bankCriteria.minIncome.toStringAsFixed(0)} lei)');
        matchScore -= 30;
      }

      // Verifica varsta minima in functie de gen
      final minAge = client.gender == ClientGender.male 
          ? bankCriteria.minAgeMale 
          : bankCriteria.minAgeFemale;
      
      if (client.age < minAge) {
        failedCriteria.add('Varsta prea mica (${client.age} < $minAge ani)');
        matchScore -= 25;
      }

      // Verifica varsta maxima in functie de gen
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

      // Verifica durata de angajament
      if (client.employmentDuration < bankCriteria.minEmploymentDuration) {
        final clientYears = client.employmentDuration ~/ 12;
        final clientMonths = client.employmentDuration % 12;
        final requiredYears = bankCriteria.minEmploymentDuration ~/ 12;
        final requiredMonths = bankCriteria.minEmploymentDuration % 12;
        
        String clientTenure = '';
        String requiredTenure = '';
        
        if (clientYears > 0) {
          clientTenure = '$clientYears ani';
          if (clientMonths > 0) clientTenure += ' $clientMonths luni';
        } else {
          clientTenure = '$clientMonths luni';
        }
        
        if (requiredYears > 0) {
          requiredTenure = '$requiredYears ani';
          if (requiredMonths > 0) requiredTenure += ' $requiredMonths luni';
        } else {
          requiredTenure = '$requiredMonths luni';
        }
        
        final errorMessage = 'Vechime insuficienta ($clientTenure < $requiredTenure)';
        failedCriteria.add(errorMessage);
        matchScore -= 20;
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
        
        // Bonus pentru vechime superiora
        if (client.employmentDuration > bankCriteria.minEmploymentDuration * 1.5) {
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
    } catch (e) {
      debugPrint('Error in analyzeClientEligibility: $e');
      // Return a default recommendation in case of error
      return BankRecommendation(
        bankCriteria: bankCriteria,
        isEligible: false,
        failedCriteria: ['Eroare la analiza eligibilitatii'],
        matchScore: 0.0,
      );
    }
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



    return recommendations;
  }

  /// Reset la criteriile implicite
  Future<void> resetToDefaults() async {
    _setDefaultCriteria();
    await _saveBankCriteria();
    notifyListeners();

  }
  
  /// FIX: Forțează actualizarea la criteriile noi pentru toate consultantii
  Future<void> forceUpdateToNewCriteria() async {

    _setDefaultCriteria();
    await _saveBankCriteria();
    notifyListeners();

  }

  /// Sterge toate criteriile pentru un consultant (folosit la stergerea contului)
  Future<void> clearConsultantData(String consultantId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_bankCriteriaPrefix$consultantId');
    } catch (e) {
      // Error clearing consultant data
    }
  }

  /// Actualizeaza datele cand se schimba consultantul
  Future<void> onConsultantChanged() async {
    await _loadBankCriteria();
    notifyListeners();
  }

  /// Extrage durata de angajament din formularele de venit
  int extractEmploymentDuration() {
    try {
      final currentClient = _clientService.focusedClient;
      if (currentClient == null) {
        return 0;
      }

      final clientIncomeForms = _formService.getClientIncomeForms(currentClient.phoneNumber);
      final coborrowerIncomeForms = _formService.getCoborrowerIncomeForms(currentClient.phoneNumber);
      
      // Cauta in formularele clientului
      for (int i = 0; i < clientIncomeForms.length; i++) {
        final income = clientIncomeForms[i];
        if (income.vechime.isNotEmpty && income.incomeAmount.isNotEmpty) {
          final tenure = _parseTenure(income.vechime);
          if (tenure > 0) {
            return tenure;
          }
        }
      }
      
      // Cauta in formularele coborrower-ului
      for (int i = 0; i < coborrowerIncomeForms.length; i++) {
        final income = coborrowerIncomeForms[i];
        if (income.vechime.isNotEmpty && income.incomeAmount.isNotEmpty) {
          final tenure = _parseTenure(income.vechime);
          if (tenure > 0) {
            return tenure;
          }
        }
      }
      
      return 0; // Default daca nu gaseste
    } catch (e) {
      return 0;
    }
  }

  /// Parseaza durata de angajament din formatul "ani/luni" (ex: "2/6" = 30 luni)
  /// Suporta formate: "6/7" (6 ani 7 luni), "6" (6 ani), "0/6" (6 luni)
  int _parseTenure(String tenure) {
    try {
      if (tenure.isEmpty || tenure.trim().isEmpty) return 0;
      
      final cleanTenure = tenure.trim();
      
      // Verifica daca contine "/" pentru formatul ani/luni
      if (cleanTenure.contains('/')) {
        final parts = cleanTenure.split('/');
        
        // Validare: trebuie sa aiba exact 2 parti
        if (parts.length != 2) {
          return 0;
        }
        
        // Parseaza ani si luni
        final yearsStr = parts[0].trim();
        final monthsStr = parts[1].trim();
        
        // Validare: ambele parti trebuie sa fie numere
        if (yearsStr.isEmpty || monthsStr.isEmpty) {
          return 0;
        }
        
        final years = int.tryParse(yearsStr);
        final months = int.tryParse(monthsStr);
        
        if (years == null || months == null) {
          return 0;
        }
        
        // Validare: ani si luni trebuie sa fie pozitive
        if (years < 0 || months < 0) {
          return 0;
        }
        
        // Validare: luni trebuie sa fie intre 0-11
        if (months > 11) {
          return 0;
        }
        
        // Calculeaza totalul in luni
        final totalMonths = years * 12 + months;
        
        return totalMonths;
        
      } else {
        // Format simplu: doar un numar (presupunem ca sunt ani)
        final years = int.tryParse(cleanTenure);
        
        if (years == null) {
          return 0;
        }
        
        if (years < 0) {
          return 0;
        }
        
        // Converteste ani in luni
        final totalMonths = years * 12;
        
        return totalMonths;
      }
      
    } catch (e) {
      return 0;
    }
  }



  /// Factor de imprumut pentru 8% dobanda, 72 luni (conform documentatiei)
  static const double _LOAN_FACTOR = 50.5; // Factor fix pentru 8% dobanda, 72 luni

  /// Normalizeaza numele bancilor pentru comparare
  String _normalizeBankName(String bankName) {
    // Elimina spatiile si normalizeaza numele bancilor
    final normalized = bankName.trim().toLowerCase();
    if (normalized.contains('ing')) return 'ing';
    if (normalized.contains('bcr')) return 'bcr';
    return normalized;
  }

  /// Calculeaza bugetul disponibil pentru credite de nevoi personale
  /// Buget_disponibil = (0.4 * S) - R_ip - R_pc
  double _calculateAvailableBudget(double salary, List<Map<String, dynamic>> allLoans) {
    // 40% din salariu
    final maxBudget = salary * 0.4;
    
    // Scade ratele ipotecar si prima casa
    double ipotecarRate = 0;
    double primaCasaRate = 0;
    
    for (final loan in allLoans) {
      final type = loan['type'] as String;
      final instalment = loan['instalment'] as double;
      
      if (type == 'Ipotecar') {
        ipotecarRate += instalment;
      } else if (type == 'Prima casa') {
        primaCasaRate += instalment;
      }
    }
    
    return maxBudget - ipotecarRate - primaCasaRate;
  }

  /// Extrage toate creditele clientului si codebitorului
  List<Map<String, dynamic>> _extractAllLoans() {
    final currentClient = _clientService.focusedClient;
    if (currentClient == null) return [];

    final clientCreditForms = _formService.getClientCreditForms(currentClient.phoneNumber);
    final coborrowerCreditForms = _formService.getCoborrowerCreditForms(currentClient.phoneNumber);
    final allLoans = <Map<String, dynamic>>[];

    // Adauga creditele clientului
    for (final credit in clientCreditForms) {
      if (credit.rata.isNotEmpty && !credit.isEmpty) {
        allLoans.add({
          'bank': credit.bank,
          'type': credit.creditType,
          'balance': double.tryParse(credit.sold) ?? 0,
          'instalment': double.tryParse(credit.rata) ?? 0,
        });
      }
    }

    // Adauga creditele codebitorului
    for (final credit in coborrowerCreditForms) {
      if (credit.rata.isNotEmpty && !credit.isEmpty) {
        allLoans.add({
          'bank': credit.bank,
          'type': credit.creditType,
          'balance': double.tryParse(credit.sold) ?? 0,
          'instalment': double.tryParse(credit.rata) ?? 0,
        });
      }
    }

    return allLoans;
  }

  /// Calculeaza venitul total al clientului
  double _calculateTotalIncome() {
    final currentClient = _clientService.focusedClient;
    if (currentClient == null) return 0;

    double salary = 0;
    final clientIncomeForms = _formService.getClientIncomeForms(currentClient.phoneNumber);
    final coborrowerIncomeForms = _formService.getCoborrowerIncomeForms(currentClient.phoneNumber);

    for (final income in clientIncomeForms) {
      if (income.incomeAmount.isNotEmpty && !income.isEmpty) {
        salary += double.tryParse(income.incomeAmount.replaceAll(',', '')) ?? 0;
      }
    }
    for (final income in coborrowerIncomeForms) {
      if (income.incomeAmount.isNotEmpty && !income.isEmpty) {
        salary += double.tryParse(income.incomeAmount.replaceAll(',', '')) ?? 0;
      }
    }

    return salary;
  }

  /// Calculeaza suma acordabila pentru tipul Fresh (credit nou fara modificarea creditelor existente)
  /// Fresh = max(0, Buget_disponibil - R_total_np) * 50.5
  double calculateFreshAmount(String bankName) {
    final salary = _calculateTotalIncome();
    if (salary <= 0) return 0;

    final allLoans = _extractAllLoans();
    final availableBudget = _calculateAvailableBudget(salary, allLoans);
    
    // Calculeaza suma totala a ratelor de nevoi personale existente
    double totalNpRates = 0;
    for (final loan in allLoans) {
      final type = loan['type'] as String;
      if (type != 'Ipotecar' && type != 'Prima casa') {
        totalNpRates += loan['instalment'] as double;
      }
    }
    
    // Verifica capacitatea: Disponibil_pentru_nou = Buget_disponibil - R_total_np
    final availableForNew = availableBudget - totalNpRates;
    
    // Daca Disponibil_pentru_nou <= 0, Fresh = 0
    if (availableForNew <= 0) return 0;
    
    // Fresh = Disponibil_pentru_nou * Factor
    final result = availableForNew * _LOAN_FACTOR;
    
    // Nu depaseste suma maxima a bancii
    final criteria = getBankCriteria(bankName);
    if (criteria != null) {
      return result.clamp(0.0, criteria.maxLoanAmount);
    }
    return result;
  }

  /// Calculeaza suma acordabila pentru tipul Refinantare (unificarea creditelor de nevoi personale)
  /// Refinantare = (Buget_disponibil * 50.5) - Suma solduri_np
  double calculateRefinantareAmount(String bankName) {
    final salary = _calculateTotalIncome();
    if (salary <= 0) return 0;

    final allLoans = _extractAllLoans();
    final availableBudget = _calculateAvailableBudget(salary, allLoans);
    
    // Calculeaza total datorie de refinanțat (doar credite de nevoi personale)
    double totalNpBalance = 0;
    for (final loan in allLoans) {
      final type = loan['type'] as String;
      if (type != 'Ipotecar' && type != 'Prima casa') {
        totalNpBalance += loan['balance'] as double;
      }
    }
    
    // Calculeaza valoarea maxima refinantabila
    final maxRefin = availableBudget * _LOAN_FACTOR;
    
    // Calculeaza cashback
    final cashback = maxRefin - totalNpBalance;
    
    // Daca cashback < 0, refinanțarea nu este posibilă
    if (cashback < 0) return 0;
    
    // Nu depaseste suma maxima a bancii
    final criteria = getBankCriteria(bankName);
    if (criteria != null) {
      return cashback.clamp(0.0, criteria.maxLoanAmount);
    }
    return cashback;
  }

  /// Calculeaza suma acordabila pentru tipul Ordin de plata (OP)
  /// OP la banca X = (Buget_disponibil * 50.5) - Suma solduri_np la X
  double calculateOrdinPlataAmount(String bankName) {
    // Doar ING si BCR ofera ordin de plata
    if (bankName != 'ING' && bankName != 'BCR') return 0;

    final salary = _calculateTotalIncome();
    if (salary <= 0) return 0;

    final allLoans = _extractAllLoans();
    final availableBudget = _calculateAvailableBudget(salary, allLoans);
    
    // Verifica daca clientul are credit la banca target
    bool hasCreditAtTargetBank = false;
    double targetBankNpBalance = 0;
    
    for (final loan in allLoans) {
      final loanBank = loan['bank'] as String;
      final normalizedLoanBank = _normalizeBankName(loanBank);
      final normalizedTargetBank = _normalizeBankName(bankName);
      
      if (normalizedLoanBank == normalizedTargetBank) {
        hasCreditAtTargetBank = true;
        final type = loan['type'] as String;
        if (type != 'Ipotecar' && type != 'Prima casa') {
          targetBankNpBalance += loan['balance'] as double;
        }
      }
    }
    
    // Daca nu are credit la banca target, OP = 0
    if (!hasCreditAtTargetBank) return 0;
    
    // Calculeaza valoarea maxima OP acordabila
    final maxOp = availableBudget * _LOAN_FACTOR;
    
    // Calculeaza OP net acordabil
    final opNet = maxOp - targetBankNpBalance;
    
    // Nu depaseste suma maxima a bancii
    final criteria = getBankCriteria(bankName);
    if (criteria != null) {
      return opNet.clamp(0.0, criteria.maxLoanAmount);
    }
    return opNet;
  }


}