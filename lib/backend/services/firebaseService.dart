import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
/// Folosește FirebaseThreadHandler pentru operațiuni thread-safe
class FirebaseFormService {
  static final FirebaseFormService _instance = FirebaseFormService._internal();
  factory FirebaseFormService() => _instance;
  FirebaseFormService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'forms';
  final FirebaseThreadHandler _threadHandler = FirebaseThreadHandler.instance;

  /// Salvează datele formularului pentru un client în Firebase
  Future<bool> saveClientFormData({
    required String phoneNumber,
    required String clientName,
    required Map<String, dynamic> formData,
  }) async {
    try {
      debugPrint('🔥 FirebaseFormService: Saving data to Firebase for client: $clientName ($phoneNumber)');
      debugPrint('🔥 FirebaseFormService: Data structure: ${formData.keys.toList()}');
      
      await _threadHandler.executeOnPlatformThread(() async {
        final docRef = _firestore.collection(_collectionName).doc(phoneNumber);
        
        // Structura documentului
        final documentData = {
          'clientName': clientName,
          'phoneNumber': phoneNumber,
          'lastUpdated': FieldValue.serverTimestamp(),
          'formData': formData,
        };

        await docRef.set(documentData, SetOptions(merge: true));
        debugPrint('✅ FirebaseFormService: Successfully saved data to Firebase for client: $clientName');
      });
      return true;
    } catch (e) {
      debugPrint('❌ FirebaseFormService: Error saving form data to Firebase: $e');
      return false;
    }
  }

  /// Încarcă datele formularului pentru un client din Firebase
  Future<Map<String, dynamic>?> loadClientFormData(String phoneNumber) async {
    try {
      debugPrint('🔥 FirebaseFormService: Loading data from Firebase for client: $phoneNumber');
      
      return await _threadHandler.executeOnPlatformThread(() async {
        final docSnapshot = await _firestore
            .collection(_collectionName)
            .doc(phoneNumber)
            .get();

        if (docSnapshot.exists) {
          debugPrint('✅ FirebaseFormService: Successfully loaded data from Firebase for client: $phoneNumber');
          final data = docSnapshot.data();
          debugPrint('🔥 FirebaseFormService: Loaded data structure: ${data?.keys.toList()}');
          return data;
        } else {
          debugPrint('⚠️ FirebaseFormService: No data found in Firebase for client: $phoneNumber');
        }
        return null;
      });
    } catch (e) {
      debugPrint('❌ FirebaseFormService: Error loading form data from Firebase: $e');
      return null;
    }
  }

  /// Șterge datele formularului pentru un client din Firebase
  Future<bool> deleteClientFormData(String phoneNumber) async {
    try {
      await _threadHandler.executeOnPlatformThread(() async {
        await _firestore.collection(_collectionName).doc(phoneNumber).delete();
      });
      return true;
    } catch (e) {
      debugPrint('Error deleting form data from Firebase: $e');
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
  Future<List<Map<String, dynamic>>> getAllForms() async {
    try {
      return await _threadHandler.executeOnPlatformThread(() async {
        final querySnapshot = await _firestore.collection(_collectionName).get();
        return querySnapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting all forms: $e');
      return [];
    }
  }

  /// Stream pentru a asculta schimbările în timp real pentru un client
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamClientFormData(String phoneNumber) {
    return _firestore.collection(_collectionName).doc(phoneNumber).snapshots();
  }
} 