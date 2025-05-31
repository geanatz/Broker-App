import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client_model.dart';

/// Firebase service pentru gestionarea datelor clienților
/// Acesta va fi integrat cu ClientService pentru persistența datelor
class ClientsFirebaseService {
  static final ClientsFirebaseService _instance = ClientsFirebaseService._internal();
  factory ClientsFirebaseService() => _instance;
  ClientsFirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _consultantsCollection = 'consultants';
  final String _clientsSubcollection = 'clients';

  /// Salvează un client în Firebase pentru un consultant specific
  Future<void> saveClientForConsultant(String consultantId, ClientModel client) async {
    try {
      await _firestore
          .collection(_consultantsCollection)
          .doc(consultantId)
          .collection(_clientsSubcollection)
          .doc(client.id)
          .set(client.toMap());
    } catch (e) {
      throw Exception('Eroare la salvarea clientului: $e');
    }
  }

  /// Obține toți clienții pentru un consultant specific
  Future<List<ClientModel>> getAllClientsForConsultant(String consultantId) async {
    try {
      final snapshot = await _firestore
          .collection(_consultantsCollection)
          .doc(consultantId)
          .collection(_clientsSubcollection)
          .get();
      return snapshot.docs.map((doc) => ClientModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Eroare la încărcarea clienților: $e');
    }
  }

  /// Șterge un client din Firebase pentru un consultant specific
  Future<void> deleteClientForConsultant(String consultantId, String clientId) async {
    try {
      await _firestore
          .collection(_consultantsCollection)
          .doc(consultantId)
          .collection(_clientsSubcollection)
          .doc(clientId)
          .delete();
    } catch (e) {
      throw Exception('Eroare la ștergerea clientului: $e');
    }
  }

  /// Actualizează un client în Firebase pentru un consultant specific
  Future<void> updateClientForConsultant(String consultantId, ClientModel client) async {
    try {
      await _firestore
          .collection(_consultantsCollection)
          .doc(consultantId)
          .collection(_clientsSubcollection)
          .doc(client.id)
          .update(client.toMap());
    } catch (e) {
      throw Exception('Eroare la actualizarea clientului: $e');
    }
  }

  /// Șterge toți clienții pentru un consultant specific
  Future<void> deleteAllClientsForConsultant(String consultantId) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection(_consultantsCollection)
          .doc(consultantId)
          .collection(_clientsSubcollection)
          .get();
      
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Eroare la ștergerea tuturor clienților: $e');
    }
  }

  /// Stream pentru ascultarea modificărilor în timp real pentru un consultant specific
  Stream<List<ClientModel>> getClientsStreamForConsultant(String consultantId) {
    return _firestore
        .collection(_consultantsCollection)
        .doc(consultantId)
        .collection(_clientsSubcollection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => ClientModel.fromMap(doc.data())).toList(),
        );
  }

  // Legacy methods for backward compatibility (deprecated)
  @deprecated
  Future<void> saveClient(ClientModel client) async {
    throw UnimplementedError('Use saveClientForConsultant instead');
  }

  @deprecated
  Future<List<ClientModel>> getAllClients() async {
    throw UnimplementedError('Use getAllClientsForConsultant instead');
  }

  @deprecated
  Future<void> deleteClient(String clientId) async {
    throw UnimplementedError('Use deleteClientForConsultant instead');
  }

  @deprecated
  Future<void> updateClient(ClientModel client) async {
    throw UnimplementedError('Use updateClientForConsultant instead');
  }

  @deprecated
  Future<void> deleteAllClients() async {
    throw UnimplementedError('Use deleteAllClientsForConsultant instead');
  }

  @deprecated
  Stream<List<ClientModel>> getClientsStream() {
    throw UnimplementedError('Use getClientsStreamForConsultant instead');
  }
}
