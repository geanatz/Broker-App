import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'unified_client_service.dart';
import '../models/unified_client_model.dart';

/// A utility class to handle Firebase operations in a thread-safe manner.
/// This ensures all Firebase operations run on the platform thread (main UI thread)
/// to prevent "Sending messages to native from a non-platform thread" errors.
class FirebaseThreadHandler {
  /// Private constructor for singleton pattern
  FirebaseThreadHandler._();
  
  /// The singleton instance
  static final FirebaseThreadHandler instance = FirebaseThreadHandler._();
  
  /// Executes a Firebase operation safely on the platform thread.
  /// 
  /// This method ensures the operation runs on the main UI thread, which is required
  /// for Firebase operations to avoid thread-related errors and data loss.
  /// 
  /// Example usage:
  /// ```dart
  /// final docSnapshot = await FirebaseThreadHandler.instance.executeOnPlatformThread(
  ///   () => FirebaseFirestore.instance.collection('users').doc('123').get()
  /// );
  /// ```
  Future<T> executeOnPlatformThread<T>(Future<T> Function() operation) async {
    final completer = Completer<T>();
    
    void runOperation() async {
      try {
        final result = await operation();
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      } catch (e) {
        debugPrint('Error in Firebase operation: $e');
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      }
    }
    
    // Detect if we're already on the platform thread
    if (WidgetsBinding.instance.rootElement == null) {
      // Not on platform thread, schedule the operation for the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) => runOperation());
    } else {
      // Already on platform thread, execute immediately
      runOperation();
    }
    
    return completer.future;
  }
  
  /// Creates a thread-safe stream for Firestore queries.
  /// 
  /// This method wraps a Firestore query stream to ensure all operations are on the 
  /// platform thread and properly managed.
  /// 
  /// Example usage:
  /// ```dart
  /// final stream = FirebaseThreadHandler.instance.createSafeQueryStream(
  ///   () => FirebaseFirestore.instance.collection('users').snapshots()
  /// );
  /// ```
  Stream<QuerySnapshot> createSafeQueryStream(Stream<QuerySnapshot> Function() queryStream) {
    // Create a stream controller that will be responsible for the stream management
    final controller = StreamController<QuerySnapshot>.broadcast();
    
    // Set up proper cancellation handler
    StreamSubscription? subscription;
    controller.onCancel = () {
      subscription?.cancel();
      controller.close();
    };
    
    // Execute on platform thread
    executeOnPlatformThread<void>(() async {
      try {
        // Start the query
        subscription = queryStream().listen(
          (snapshot) {
            if (!controller.isClosed) {
              controller.add(snapshot);
            }
          },
          onError: (error) {
            debugPrint("Error in Firestore query: $error");
            if (!controller.isClosed) {
              controller.addError(error);
            }
          },
          onDone: () {
            if (!controller.isClosed) {
              controller.close();
            }
          },
        );
      } catch (e) {
        debugPrint("Error setting up Firestore query: $e");
        if (!controller.isClosed) {
          controller.addError(e);
          controller.close();
        }
      }
    });
    
    return controller.stream;
  }
  
  /// Execute a Firestore transaction safely on the platform thread.
  /// 
  /// Example usage:
  /// ```dart
  /// final result = await FirebaseThreadHandler.instance.executeTransaction((transaction) async {
  ///   final docSnapshot = await transaction.get(docRef);
  ///   // Perform transaction operations
  ///   return 'success';
  /// });
  /// ```
  Future<T> executeTransaction<T>(
    Future<T> Function(Transaction transaction) transactionFunction
  ) async {
    return executeOnPlatformThread(() {
      return FirebaseFirestore.instance.runTransaction(transactionFunction);
    });
  }
  
  /// Execute a Firestore batch write safely on the platform thread.
  /// 
  /// Example usage:
  /// ```dart
  /// await FirebaseThreadHandler.instance.executeBatch((batch) {
  ///   batch.set(doc1Ref, data1);
  ///   batch.update(doc2Ref, data2);
  ///   batch.delete(doc3Ref);
  /// });
  /// ```
  Future<void> executeBatch(void Function(WriteBatch batch) batchFunction) async {
    return executeOnPlatformThread(() async {
      final batch = FirebaseFirestore.instance.batch();
      batchFunction(batch);
      return batch.commit();
    });
  }
}

/// Serviciu pentru gestionarea formularelor în Firebase Firestore
/// Acum folosește noua structură unificată în loc de colecția globală 'forms'
class FirebaseFormService {
  static final FirebaseFormService _instance = FirebaseFormService._internal();
  factory FirebaseFormService() => _instance;
  FirebaseFormService._internal();

  final UnifiedClientService _unifiedService = UnifiedClientService();
  final FirebaseThreadHandler _threadHandler = FirebaseThreadHandler.instance;

  /// Salvează datele formularului pentru un client în noua structură
  Future<bool> saveClientFormData({
    required String phoneNumber,
    required String clientName,
    required Map<String, dynamic> formData,
  }) async {
    try {
      debugPrint('🔥 FirebaseFormService: Saving data to unified structure for client: $clientName ($phoneNumber)');
      debugPrint('🔥 FirebaseFormService: Data structure: ${formData.keys.toList()}');
      
      await _threadHandler.executeOnPlatformThread(() async {
        // Verifică dacă clientul există, dacă nu îl creează
        final existingClient = await _unifiedService.getClient(phoneNumber);
        if (existingClient == null) {
          await _unifiedService.createClient(
            phoneNumber: phoneNumber,
            name: clientName,
            source: 'form_service',
          );
        }

        // Convertește datele formularului în noua structură
        final convertedData = _convertFormDataToUnified(formData);
        
        // Salvează datele de loan și income separat
        await _unifiedService.saveLoanData(
          phoneNumber,
          clientCredits: convertedData.clientCredits,
          coDebitorCredits: convertedData.coDebitorCredits,
          additionalData: convertedData.additionalData,
        );
        
        await _unifiedService.saveIncomeData(
          phoneNumber,
          clientIncomes: convertedData.clientIncomes,
          coDebitorIncomes: convertedData.coDebitorIncomes,
          additionalData: convertedData.additionalData,
        );
        
        debugPrint('✅ FirebaseFormService: Successfully saved data to unified structure for client: $clientName');
      });
      return true;
    } catch (e) {
      debugPrint('❌ FirebaseFormService: Error saving form data to unified structure: $e');
      return false;
    }
  }

  /// Încarcă datele formularului pentru un client din noua structură
  Future<Map<String, dynamic>?> loadClientFormData(String phoneNumber) async {
    try {
      debugPrint('🔥 FirebaseFormService: Loading data from unified structure for client: $phoneNumber');
      
      return await _threadHandler.executeOnPlatformThread(() async {
        final client = await _unifiedService.getClient(phoneNumber);
        
        if (client != null) {
          debugPrint('✅ FirebaseFormService: Successfully loaded data from unified structure for client: $phoneNumber');
          
          // Convertește datele din noua structură în formatul așteptat
          final convertedData = _convertUnifiedToFormData(client.formData);
          
          return {
            'clientName': client.basicInfo.name,
            'phoneNumber': client.basicInfo.phoneNumber,
            'lastUpdated': client.metadata.updatedAt.toIso8601String(),
            'formData': convertedData,
          };
        } else {
          debugPrint('⚠️ FirebaseFormService: No data found in unified structure for client: $phoneNumber');
        }
        return null;
      });
    } catch (e) {
      debugPrint('❌ FirebaseFormService: Error loading form data from unified structure: $e');
      return null;
    }
  }

  /// Șterge datele formularului pentru un client din noua structură
  Future<bool> deleteClientFormData(String phoneNumber) async {
    try {
      await _threadHandler.executeOnPlatformThread(() async {
        // În noua structură, ștergem doar datele de formular, nu întregul client
        await _unifiedService.saveLoanData(
          phoneNumber,
          clientCredits: [],
          coDebitorCredits: [],
        );
        
        await _unifiedService.saveIncomeData(
          phoneNumber,
          clientIncomes: [],
          coDebitorIncomes: [],
        );
      });
      return true;
    } catch (e) {
      debugPrint('Error deleting form data from unified structure: $e');
      return false;
    }
  }

  /// Salvează formularele de credit pentru un client
  Future<bool> saveCreditForms({
    required String phoneNumber,
    required String clientName,
    required List<Map<String, dynamic>> clientCreditForms,
    required List<Map<String, dynamic>> coborrowerCreditForms,
  }) async {
    final formData = {
      'creditForms': {
        'client': clientCreditForms,
        'coborrower': coborrowerCreditForms,
      }
    };

    return await saveClientFormData(
      phoneNumber: phoneNumber,
      clientName: clientName,
      formData: formData,
    );
  }

  /// Salvează formularele de venit pentru un client
  Future<bool> saveIncomeForms({
    required String phoneNumber,
    required String clientName,
    required List<Map<String, dynamic>> clientIncomeForms,
    required List<Map<String, dynamic>> coborrowerIncomeForms,
  }) async {
    final formData = {
      'incomeForms': {
        'client': clientIncomeForms,
        'coborrower': coborrowerIncomeForms,
      }
    };

    return await saveClientFormData(
      phoneNumber: phoneNumber,
      clientName: clientName,
      formData: formData,
    );
  }

  /// Salvează toate datele formularului pentru un client
  Future<bool> saveAllFormData({
    required String phoneNumber,
    required String clientName,
    required List<Map<String, dynamic>> clientCreditForms,
    required List<Map<String, dynamic>> coborrowerCreditForms,
    required List<Map<String, dynamic>> clientIncomeForms,
    required List<Map<String, dynamic>> coborrowerIncomeForms,
    required bool showingClientLoanForm,
    required bool showingClientIncomeForm,
  }) async {
    final formData = {
      'creditForms': {
        'client': clientCreditForms,
        'coborrower': coborrowerCreditForms,
      },
      'incomeForms': {
        'client': clientIncomeForms,
        'coborrower': coborrowerIncomeForms,
      },
      'showingClientLoanForm': showingClientLoanForm,
      'showingClientIncomeForm': showingClientIncomeForm,
    };

    return await saveClientFormData(
      phoneNumber: phoneNumber,
      clientName: clientName,
      formData: formData,
    );
  }

  /// Încarcă toate datele formularului pentru un client
  Future<Map<String, dynamic>?> loadAllFormData(String phoneNumber) async {
    final data = await loadClientFormData(phoneNumber);
    return data?['formData'];
  }

  /// Obține toate documentele din colecția forms (pentru debug/admin)
  /// Acum returnează datele din noua structură
  Future<List<Map<String, dynamic>>> getAllForms() async {
    try {
      return await _threadHandler.executeOnPlatformThread(() async {
        final clients = await _unifiedService.getAllClients();
        return clients.map((client) => {
          'id': client.basicInfo.phoneNumber,
          'clientName': client.basicInfo.name,
          'phoneNumber': client.basicInfo.phoneNumber,
          'lastUpdated': client.metadata.updatedAt.toIso8601String(),
          'formData': _convertUnifiedToFormData(client.formData),
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting all forms from unified structure: $e');
      return [];
    }
  }

  /// Stream pentru a asculta schimbările în timp real pentru un client
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamClientFormData(String phoneNumber) {
    // Pentru compatibilitate, returnăm un stream care emite periodic datele clientului
    return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
      final data = await loadClientFormData(phoneNumber);
      return _MockDocumentSnapshot(data);
    });
  }

  // =================== HELPER METHODS ===================

  /// Convertește datele formularului din vechiul format în noua structură
  ClientFormData _convertFormDataToUnified(Map<String, dynamic> formData) {
    final creditForms = formData['creditForms'] as Map<String, dynamic>? ?? {};
    final incomeForms = formData['incomeForms'] as Map<String, dynamic>? ?? {};
    
    // Convertește creditele client
    final clientCredits = (creditForms['client'] as List<dynamic>? ?? [])
        .map((credit) => _convertCreditToUnified(credit))
        .toList();
    
    // Convertește creditele codebitor
    final coDebitorCredits = (creditForms['coborrower'] as List<dynamic>? ?? [])
        .map((credit) => _convertCreditToUnified(credit))
        .toList();
    
    // Convertește veniturile client
    final clientIncomes = (incomeForms['client'] as List<dynamic>? ?? [])
        .map((income) => _convertIncomeToUnified(income))
        .toList();
    
    // Convertește veniturile codebitor
    final coDebitorIncomes = (incomeForms['coborrower'] as List<dynamic>? ?? [])
        .map((income) => _convertIncomeToUnified(income))
        .toList();
    
    return ClientFormData(
      clientCredits: clientCredits,
      coDebitorCredits: coDebitorCredits,
      clientIncomes: clientIncomes,
      coDebitorIncomes: coDebitorIncomes,
      additionalData: {
        'showingClientLoanForm': formData['showingClientLoanForm'] ?? true,
        'showingClientIncomeForm': formData['showingClientIncomeForm'] ?? true,
      },
    );
  }

  /// Convertește datele din noua structură în vechiul format
  Map<String, dynamic> _convertUnifiedToFormData(ClientFormData formData) {
    return {
      'creditForms': {
        'client': formData.clientCredits.map((credit) => _convertCreditFromUnified(credit)).toList(),
        'coborrower': formData.coDebitorCredits.map((credit) => _convertCreditFromUnified(credit)).toList(),
      },
      'incomeForms': {
        'client': formData.clientIncomes.map((income) => _convertIncomeFromUnified(income)).toList(),
        'coborrower': formData.coDebitorIncomes.map((income) => _convertIncomeFromUnified(income)).toList(),
      },
      'showingClientLoanForm': formData.additionalData['showingClientLoanForm'] ?? true,
      'showingClientIncomeForm': formData.additionalData['showingClientIncomeForm'] ?? true,
    };
  }

  /// Convertește un credit din vechiul format în noua structură
  CreditData _convertCreditToUnified(Map<String, dynamic> credit) {
    return CreditData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bank: credit['bank'] ?? '',
      creditType: credit['creditType'] ?? '',
      currentBalance: double.tryParse(credit['sold']?.toString().replaceAll(',', '') ?? '0'),
      consumedAmount: double.tryParse(credit['consumat']?.toString().replaceAll(',', '') ?? '0'),
      rateType: credit['rateType'] ?? '',
      monthlyPayment: double.tryParse(credit['rata']?.toString().replaceAll(',', '') ?? '0'),
      remainingMonths: _parseYearMonthFormat(credit['perioada']?.toString()),
    );
  }

  /// Convertește un credit din noua structură în vechiul format
  Map<String, dynamic> _convertCreditFromUnified(CreditData credit) {
    return {
      'bank': credit.bank,
      'creditType': credit.creditType,
      'sold': _formatAmount(credit.currentBalance),
      'consumat': _formatAmount(credit.consumedAmount),
      'rateType': credit.rateType,
      'rata': _formatAmount(credit.monthlyPayment),
      'perioada': _formatYearMonth(credit.remainingMonths),
      'isNew': false,
    };
  }

  /// Convertește un venit din vechiul format în noua structură
  IncomeData _convertIncomeToUnified(Map<String, dynamic> income) {
    return IncomeData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bank: income['bank'] ?? '',
      incomeType: income['incomeType'] ?? '',
      monthlyAmount: double.tryParse(income['incomeAmount']?.toString().replaceAll(',', '') ?? '0'),
      seniority: _parseVechime(income['vechime']?.toString()),
    );
  }

  /// Convertește un venit din noua structură în vechiul format
  Map<String, dynamic> _convertIncomeFromUnified(IncomeData income) {
    return {
      'bank': income.bank,
      'incomeType': income.incomeType,
      'incomeAmount': _formatAmount(income.monthlyAmount),
      'vechime': _formatYearMonth(income.seniority),
      'isNew': false,
    };
  }

  /// Formatează o sumă eliminând zecimalele inutile (.0)
  String _formatAmount(double? amount) {
    if (amount == null) return '';
    
    // Verifică dacă numărul este întreg
    if (amount == amount.toInt()) {
      return amount.toInt().toString();
    } else {
      return amount.toString();
    }
  }

  /// Parsează perioada din format "ani/luni" în luni totale pentru sistemul intern
  int? _parseYearMonthFormat(String? period) {
    if (period == null || period.isEmpty) return null;
    
    // Dacă contine "/", parseaza formatul ani/luni
    if (period.contains('/')) {
      final parts = period.split('/');
      if (parts.length == 2) {
        final years = int.tryParse(parts[0].trim()) ?? 0;
        final months = int.tryParse(parts[1].trim()) ?? 0;
        return years * 12 + months;
      }
    }
    
    // Dacă nu contine "/", încearcă să parseze ca număr simplu (luni)
    return int.tryParse(period.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  /// Convertește luni totale înapoi în format "ani/luni" pentru afișare
  String _formatYearMonth(int? totalMonths) {
    if (totalMonths == null || totalMonths == 0) return '';
    
    final years = totalMonths ~/ 12;
    final months = totalMonths % 12;
    
    if (years == 0) {
      return '0/$months';
    } else if (months == 0) {
      return '$years/0';
    } else {
      return '$years/$months';
    }
  }

  /// Parsează vechimea din string în luni, cu suport pentru formatul ani/luni
  int? _parseVechime(String? vechime) {
    if (vechime == null || vechime.isEmpty) return null;
    
    // Folosește noua funcție pentru a parsa formatul ani/luni
    return _parseYearMonthFormat(vechime);
  }
}

/// Mock DocumentSnapshot pentru compatibilitate cu stream-ul existent
class _MockDocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic>? _data;
  
  _MockDocumentSnapshot(this._data);
  
  @override
  Map<String, dynamic>? data() => _data;
  
  @override
  bool get exists => _data != null;
  
  @override
  String get id => _data?['phoneNumber'] ?? '';
  
  @override
  DocumentReference<Map<String, dynamic>> get reference => throw UnimplementedError();
  
  @override
  SnapshotMetadata get metadata => throw UnimplementedError();
  
  @override
  dynamic get(Object field) => _data?[field];
  
  @override
  dynamic operator [](Object field) => _data?[field];
} 