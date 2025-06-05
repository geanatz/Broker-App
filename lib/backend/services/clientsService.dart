import '../models/client_model.dart' as OldModel;
import 'unified_client_service.dart';
import '../models/unified_client_model.dart' as UnifiedModel;

/// Firebase service pentru gestionarea datelor clienților
/// Acum folosește noua structură unificată cu numărul de telefon ca ID
class ClientsFirebaseService {
  static final ClientsFirebaseService _instance = ClientsFirebaseService._internal();
  factory ClientsFirebaseService() => _instance;
  ClientsFirebaseService._internal();

  final UnifiedClientService _unifiedService = UnifiedClientService();

  /// Salvează un client în Firebase pentru un consultant specific
  /// Folosește numărul de telefon ca ID al documentului
  Future<void> saveClientForConsultant(String consultantId, OldModel.ClientModel client) async {
    try {
      // Convertește ClientModel în noua structură
      final success = await _unifiedService.createClient(
        phoneNumber: client.phoneNumber,
        name: client.name,
        status: _convertToUnifiedStatus(client),
        source: 'client_service',
      );
      
      if (!success) {
        throw Exception('Failed to save client in unified structure');
      }
    } catch (e) {
      throw Exception('Eroare la salvarea clientului: $e');
    }
  }

  /// Obține toți clienții pentru un consultant specific
  Future<List<OldModel.ClientModel>> getAllClientsForConsultant(String consultantId) async {
    try {
      final unifiedClients = await _unifiedService.getAllClients();
      return unifiedClients.map((unifiedClient) => _convertToClientModel(unifiedClient)).toList();
    } catch (e) {
      throw Exception('Eroare la încărcarea clienților: $e');
    }
  }

  /// Șterge un client din Firebase pentru un consultant specific
  Future<void> deleteClientForConsultant(String consultantId, String clientId) async {
    try {
      // În noua structură, clientId este de fapt phoneNumber
      final success = await _unifiedService.deleteClient(clientId);
      
      if (!success) {
        throw Exception('Failed to delete client in unified structure');
      }
    } catch (e) {
      throw Exception('Eroare la ștergerea clientului: $e');
    }
  }

  /// Actualizează un client în Firebase pentru un consultant specific
  Future<void> updateClientForConsultant(String consultantId, OldModel.ClientModel client) async {
    try {
      final success = await _unifiedService.updateClient(
        client.phoneNumber,
        name: client.name,
        currentStatus: _convertToUnifiedStatus(client),
      );
      
      if (!success) {
        throw Exception('Failed to update client in unified structure');
      }
    } catch (e) {
      throw Exception('Eroare la actualizarea clientului: $e');
    }
  }

  /// Șterge toți clienții pentru un consultant specific
  Future<void> deleteAllClientsForConsultant(String consultantId) async {
    try {
      // Folosește metoda optimizată pentru ștergerea în lot
      final success = await _unifiedService.deleteAllClients();
      
      if (!success) {
        throw Exception('Failed to delete all clients in unified structure');
      }
    } catch (e) {
      throw Exception('Eroare la ștergerea tuturor clienților: $e');
    }
  }

  /// Stream pentru ascultarea modificărilor în timp real pentru un consultant specific
  Stream<List<OldModel.ClientModel>> getClientsStreamForConsultant(String consultantId) {
    return _unifiedService.getClientsStream().map((unifiedClients) =>
        unifiedClients.map((unifiedClient) => _convertToClientModel(unifiedClient)).toList());
  }

  // =================== HELPER METHODS ===================

  /// Convertește ClientModel în ClientStatus pentru noua structură
  UnifiedModel.ClientStatus _convertToUnifiedStatus(OldModel.ClientModel client) {
    return UnifiedModel.ClientStatus(
      category: _convertToUnifiedCategory(client.category),
      isFocused: client.status == OldModel.ClientStatus.focused,
      discussionStatus: _convertDiscussionStatus(client.discussionStatus),
      scheduledDateTime: client.scheduledDateTime,
      additionalInfo: client.additionalInfo,
    );
  }

  /// Convertește ClientCategory din vechea structură în noua structură
  UnifiedModel.ClientCategory _convertToUnifiedCategory(OldModel.ClientCategory oldCategory) {
    switch (oldCategory) {
      case OldModel.ClientCategory.apeluri:
        return UnifiedModel.ClientCategory.apeluri;
      case OldModel.ClientCategory.reveniri:
        return UnifiedModel.ClientCategory.reveniri;
      case OldModel.ClientCategory.recente:
        return UnifiedModel.ClientCategory.recente;
    }
  }

  /// Convertește string discussion status în enum
  UnifiedModel.ClientDiscussionStatus? _convertDiscussionStatus(String? discussionStatus) {
    if (discussionStatus == null) return null;
    
    switch (discussionStatus.toLowerCase()) {
      case 'acceptat':
        return UnifiedModel.ClientDiscussionStatus.acceptat;
      case 'amanat':
        return UnifiedModel.ClientDiscussionStatus.amanat;
      case 'refuzat':
        return UnifiedModel.ClientDiscussionStatus.refuzat;
      default:
        return null;
    }
  }

  /// Convertește UnifiedClientModel în ClientModel pentru compatibilitate
  OldModel.ClientModel _convertToClientModel(UnifiedModel.UnifiedClientModel unifiedClient) {
    return OldModel.ClientModel(
      id: unifiedClient.basicInfo.phoneNumber, // Folosește phoneNumber ca ID
      name: unifiedClient.basicInfo.name,
      phoneNumber: unifiedClient.basicInfo.phoneNumber,
      status: unifiedClient.currentStatus.isFocused ? OldModel.ClientStatus.focused : OldModel.ClientStatus.normal,
      category: _convertFromUnifiedCategory(unifiedClient.currentStatus.category),
      formData: {}, // FormData este gestionat separat în noua structură
      discussionStatus: unifiedClient.currentStatus.discussionStatus?.name,
      scheduledDateTime: unifiedClient.currentStatus.scheduledDateTime,
      additionalInfo: unifiedClient.currentStatus.additionalInfo,
    );
  }

  /// Convertește ClientCategory din noua structură în vechea structură
  OldModel.ClientCategory _convertFromUnifiedCategory(UnifiedModel.ClientCategory unifiedCategory) {
    switch (unifiedCategory) {
      case UnifiedModel.ClientCategory.apeluri:
        return OldModel.ClientCategory.apeluri;
      case UnifiedModel.ClientCategory.reveniri:
        return OldModel.ClientCategory.reveniri;
      case UnifiedModel.ClientCategory.recente:
        return OldModel.ClientCategory.recente;
    }
  }

  // Legacy methods for backward compatibility (deprecated)
  @deprecated
  Future<void> saveClient(OldModel.ClientModel client) async {
    throw UnimplementedError('Use saveClientForConsultant instead');
  }

  @deprecated
  Future<List<OldModel.ClientModel>> getAllClients() async {
    throw UnimplementedError('Use getAllClientsForConsultant instead');
  }

  @deprecated
  Future<void> deleteClient(String clientId) async {
    throw UnimplementedError('Use deleteClientForConsultant instead');
  }

  @deprecated
  Future<void> updateClient(OldModel.ClientModel client) async {
    throw UnimplementedError('Use updateClientForConsultant instead');
  }

  @deprecated
  Future<void> deleteAllClients() async {
    throw UnimplementedError('Use deleteAllClientsForConsultant instead');
  }

  @deprecated
  Stream<List<OldModel.ClientModel>> getClientsStream() {
    throw UnimplementedError('Use getClientsStreamForConsultant instead');
  }
}
