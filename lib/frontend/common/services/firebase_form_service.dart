import 'package:cloud_firestore/cloud_firestore.dart';

/// Serviciu pentru gestionarea formularelor în Firebase Firestore
class FirebaseFormService {
  static final FirebaseFormService _instance = FirebaseFormService._internal();
  factory FirebaseFormService() => _instance;
  FirebaseFormService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'forms';

  /// Salvează datele formularului pentru un client în Firebase
  Future<bool> saveClientFormData({
    required String phoneNumber,
    required String clientName,
    required Map<String, dynamic> formData,
  }) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc(phoneNumber);
      
      // Structura documentului
      final documentData = {
        'clientName': clientName,
        'phoneNumber': phoneNumber,
        'lastUpdated': FieldValue.serverTimestamp(),
        'formData': formData,
      };

      await docRef.set(documentData, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error saving form data to Firebase: $e');
      return false;
    }
  }

  /// Încarcă datele formularului pentru un client din Firebase
  Future<Map<String, dynamic>?> loadClientFormData(String phoneNumber) async {
    try {
      final docSnapshot = await _firestore
          .collection(_collectionName)
          .doc(phoneNumber)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      print('Error loading form data from Firebase: $e');
      return null;
    }
  }

  /// Șterge datele formularului pentru un client din Firebase
  Future<bool> deleteClientFormData(String phoneNumber) async {
    try {
      await _firestore.collection(_collectionName).doc(phoneNumber).delete();
      return true;
    } catch (e) {
      print('Error deleting form data from Firebase: $e');
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
      'uiState': {
        'showingClientLoanForm': showingClientLoanForm,
        'showingClientIncomeForm': showingClientIncomeForm,
      }
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
      final querySnapshot = await _firestore.collection(_collectionName).get();
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('Error getting all forms: $e');
      return [];
    }
  }

  /// Stream pentru a asculta schimbările în timp real pentru un client
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamClientFormData(String phoneNumber) {
    return _firestore.collection(_collectionName).doc(phoneNumber).snapshots();
  }
} 