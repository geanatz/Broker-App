import 'package:flutter/material.dart';
import '../models/client_model.dart';

/// Service pentru gestionarea stării clienților și sincronizarea datelor formularelor
/// între clientsPane și formArea
class ClientService extends ChangeNotifier {
  static final ClientService _instance = ClientService._internal();
  factory ClientService() => _instance;
  ClientService._internal();

  // Lista tuturor clienților
  List<ClientModel> _clients = [];
  
  // Clientul curent focusat (pentru care se afișează formularul)
  ClientModel? _focusedClient;
  
  // Getters
  List<ClientModel> get clients => List.unmodifiable(_clients);
  ClientModel? get focusedClient => _focusedClient;
  
  /// Obține clienții dintr-o anumită categorie
  List<ClientModel> getClientsByCategory(ClientCategory category) {
    return _clients.where((client) => client.category == category).toList();
  }
  
  /// Obține clienții din categoria "Apeluri"
  List<ClientModel> get apeluri => getClientsByCategory(ClientCategory.apeluri);
  
  /// Obține clienții din categoria "Reveniri"
  List<ClientModel> get reveniri => getClientsByCategory(ClientCategory.reveniri);
  
  /// Obține clienții din categoria "Recente"
  List<ClientModel> get recente => getClientsByCategory(ClientCategory.recente);
  
  /// Inițializează datele demo pentru clienți
  void initializeDemoData() {
    _clients = [
      // Clienți din categoria "Apeluri"
      ClientModel(
        id: '1',
        name: 'Ion Popescu',
        phoneNumber: '0721234567',
        status: ClientStatus.focused, // Primul client este focusat implicit
        category: ClientCategory.apeluri,
      ),
      ClientModel(
        id: '2',
        name: 'Maria Ionescu',
        phoneNumber: '0731234567',
        status: ClientStatus.normal,
        category: ClientCategory.apeluri,
      ),
      
      // Clienți din categoria "Reveniri"
      ClientModel(
        id: '3',
        name: 'Gheorghe Vasilescu',
        phoneNumber: '0741234567',
        status: ClientStatus.normal,
        category: ClientCategory.reveniri,
      ),
      ClientModel(
        id: '4',
        name: 'Ana Georgescu',
        phoneNumber: '0751234567',
        status: ClientStatus.normal,
        category: ClientCategory.reveniri,
      ),
      
      // Clienți din categoria "Recente"
      ClientModel(
        id: '5',
        name: 'Mihai Constantinescu',
        phoneNumber: '0761234567',
        status: ClientStatus.normal,
        category: ClientCategory.recente,
      ),
      ClientModel(
        id: '6',
        name: 'Elena Dumitrescu',
        phoneNumber: '0771234567',
        status: ClientStatus.normal,
        category: ClientCategory.recente,
      ),
    ];
    
    // Setează primul client ca fiind focusat
    _focusedClient = _clients.isNotEmpty ? _clients.first : null;
    notifyListeners();
  }
  
  /// Focusează un client (schimbă starea la focused și afișează formularul său)
  void focusClient(String clientId) {
    // Resetează starea tuturor clienților la normal
    for (int i = 0; i < _clients.length; i++) {
      if (_clients[i].status == ClientStatus.focused) {
        _clients[i] = _clients[i].copyWith(status: ClientStatus.normal);
      }
    }
    
    // Găsește și focusează clientul selectat
    final clientIndex = _clients.indexWhere((client) => client.id == clientId);
    if (clientIndex != -1) {
      _clients[clientIndex] = _clients[clientIndex].copyWith(status: ClientStatus.focused);
      _focusedClient = _clients[clientIndex];
      notifyListeners();
    }
  }
  
  /// Actualizează datele formularului pentru clientul focusat
  void updateFocusedClientFormData(String key, dynamic value) {
    if (_focusedClient != null) {
      _focusedClient!.updateFormData(key, value);
      
      // Actualizează și în lista principală
      final clientIndex = _clients.indexWhere((client) => client.id == _focusedClient!.id);
      if (clientIndex != -1) {
        _clients[clientIndex] = _focusedClient!;
      }
      
      notifyListeners();
    }
  }

  /// Actualizează datele formularului pentru clientul focusat fără notificare
  void updateFocusedClientFormDataSilent(String key, dynamic value) {
    if (_focusedClient != null) {
      _focusedClient!.updateFormData(key, value);
      
      // Actualizează și în lista principală
      final clientIndex = _clients.indexWhere((client) => client.id == _focusedClient!.id);
      if (clientIndex != -1) {
        _clients[clientIndex] = _focusedClient!;
      }
    }
  }
  
  /// Obține o valoare din formularul clientului focusat
  T? getFocusedClientFormValue<T>(String key) {
    return _focusedClient?.getFormValue<T>(key);
  }
  
  /// Adaugă un client nou
  void addClient(ClientModel client) {
    _clients.add(client);
    notifyListeners();
  }
  
  /// Șterge un client
  void removeClient(String clientId) {
    _clients.removeWhere((client) => client.id == clientId);
    
    // Dacă clientul șters era focusat, focusează primul client disponibil
    if (_focusedClient?.id == clientId) {
      _focusedClient = _clients.isNotEmpty ? _clients.first : null;
      if (_focusedClient != null) {
        focusClient(_focusedClient!.id);
      }
    }
    
    notifyListeners();
  }
  
  /// Actualizează un client existent
  void updateClient(ClientModel updatedClient) {
    final clientIndex = _clients.indexWhere((client) => client.id == updatedClient.id);
    if (clientIndex != -1) {
      _clients[clientIndex] = updatedClient;
      
      // Dacă clientul actualizat este cel focusat, actualizează și referința
      if (_focusedClient?.id == updatedClient.id) {
        _focusedClient = updatedClient;
      }
      
      notifyListeners();
    }
  }
} 