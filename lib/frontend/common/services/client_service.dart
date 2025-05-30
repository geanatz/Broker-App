import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../../../backend/services/clientsService.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  
  // Firebase service pentru persistența datelor
  final ClientsFirebaseService _firebaseService = ClientsFirebaseService();
  
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
  
  /// Inițializează serviciul și încarcă clienții din Firebase pentru consultantul curent
  Future<void> initializeDemoData() async {
    try {
      // Verifică dacă utilizatorul este autentificat
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Încarcă clienții din Firebase pentru consultantul curent
        await loadClientsFromFirebase();
      } else {
        // Dacă nu este autentificat, inițializează cu listă goală
        _clients = [];
        _focusedClient = null;
      }
    } catch (e) {
      debugPrint('Error initializing client data: $e');
      // În caz de eroare, inițializează cu listă goală
      _clients = [];
      _focusedClient = null;
    }
    notifyListeners();
  }
  
  /// Încarcă clienții din Firebase pentru consultantul curent
  Future<void> loadClientsFromFirebase() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _clients = await _firebaseService.getAllClientsForConsultant(currentUser.uid);
        
        // Focusează primul client dacă există
        if (_clients.isNotEmpty) {
          _focusedClient = _clients.first;
          focusClient(_clients.first.id);
        } else {
          _focusedClient = null;
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading clients from Firebase: $e');
    }
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
  
  /// Adaugă un client nou și îl salvează în Firebase
  Future<void> addClient(ClientModel client) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Salvează în Firebase
        await _firebaseService.saveClientForConsultant(currentUser.uid, client);
        
        // Adaugă în lista locală
        _clients.add(client);
        
        // Focusează primul client dacă este primul client adăugat
        if (_clients.length == 1) {
          _focusedClient = _clients.first;
          focusClient(_clients.first.id);
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding client: $e');
      // Poți adăuga aici o notificare de eroare pentru utilizator
    }
  }
  
  /// Șterge un client și îl elimină din Firebase
  Future<void> removeClient(String clientId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Șterge din Firebase
        await _firebaseService.deleteClientForConsultant(currentUser.uid, clientId);
        
        // Șterge din lista locală
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
    } catch (e) {
      debugPrint('Error removing client: $e');
    }
  }
  
  /// Actualizează un client existent și îl salvează în Firebase
  Future<void> updateClient(ClientModel updatedClient) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Actualizează în Firebase
        await _firebaseService.updateClientForConsultant(currentUser.uid, updatedClient);
        
        // Actualizează în lista locală
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
    } catch (e) {
      debugPrint('Error updating client: $e');
    }
  }
  
  /// Șterge toți clienții pentru consultantul curent
  Future<void> deleteAllClients() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Șterge toți clienții din Firebase
        await _firebaseService.deleteAllClientsForConsultant(currentUser.uid);
        
        // Curăță lista locală
        _clients.clear();
        _focusedClient = null;
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting all clients: $e');
    }
  }
} 