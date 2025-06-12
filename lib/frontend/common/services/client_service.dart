import 'package:flutter/material.dart';
import '../../../backend/services/clients_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service pentru gestionarea stării clienților în UI și sincronizarea datelor formularelor
/// între clientsPane și formArea. Acest service se ocupă doar de UI state management.
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
          focusClient(_clients.first.phoneNumber); // Folosește phoneNumber ca ID
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
  void focusClient(String clientPhoneNumber) {
    // Defocusează clientul anterior
    if (_focusedClient != null) {
      final oldClientIndex = _clients.indexWhere((client) => client.phoneNumber == _focusedClient!.phoneNumber);
      if (oldClientIndex != -1) {
        _clients[oldClientIndex] = _clients[oldClientIndex].copyWith(status: ClientStatus.normal);
      }
    }
    
    // Focusează noul client
    final newClientIndex = _clients.indexWhere((client) => client.phoneNumber == clientPhoneNumber);
    if (newClientIndex != -1) {
      _clients[newClientIndex] = _clients[newClientIndex].copyWith(status: ClientStatus.focused);
      _focusedClient = _clients[newClientIndex];
      notifyListeners();
    }
  }
  
  /// Defocusează clientul curent
  void defocusCurrentClient() {
    if (_focusedClient != null) {
      final clientIndex = _clients.indexWhere((client) => client.phoneNumber == _focusedClient!.phoneNumber);
      if (clientIndex != -1) {
        _clients[clientIndex] = _clients[clientIndex].copyWith(status: ClientStatus.normal);
      }
      _focusedClient = null;
      notifyListeners();
    }
  }
  
  /// Actualizează datele formularului pentru clientul focusat
  void updateFocusedClientFormData(String key, dynamic value) {
    if (_focusedClient != null) {
      _focusedClient!.updateFormData(key, value);
      
      // Actualizează și în lista principală
      final clientIndex = _clients.indexWhere((client) => client.phoneNumber == _focusedClient!.phoneNumber);
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
      final clientIndex = _clients.indexWhere((client) => client.phoneNumber == _focusedClient!.phoneNumber);
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
  /// Folosește numărul de telefon ca ID unic
  Future<void> addClient(ClientModel client) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Creează un client cu phoneNumber ca ID
        final clientWithPhoneId = client.copyWith(id: client.phoneNumber);
        
        // Salvează în Firebase
        await _firebaseService.saveClientForConsultant(currentUser.uid, clientWithPhoneId);
        
        // Adaugă în lista locală
        _clients.add(clientWithPhoneId);
        
        // Focusează primul client dacă este primul client adăugat
        if (_clients.length == 1) {
          _focusedClient = _clients.first;
          focusClient(_clients.first.phoneNumber);
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding client: $e');
      // Poți adăuga aici o notificare de eroare pentru utilizator
    }
  }
  
  /// Șterge un client și îl elimină din Firebase
  /// Folosește phoneNumber pentru identificare
  Future<void> removeClient(String clientPhoneNumber) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Șterge din Firebase folosind phoneNumber ca ID
        await _firebaseService.deleteClientForConsultant(currentUser.uid, clientPhoneNumber);
        
        // Șterge din lista locală
        _clients.removeWhere((client) => client.phoneNumber == clientPhoneNumber);
        
        // Dacă clientul șters era focusat, focusează primul client disponibil
        if (_focusedClient?.phoneNumber == clientPhoneNumber) {
          _focusedClient = _clients.isNotEmpty ? _clients.first : null;
          if (_focusedClient != null) {
            focusClient(_focusedClient!.phoneNumber);
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
        // Asigură-te că ID-ul este phoneNumber
        final clientWithPhoneId = updatedClient.copyWith(id: updatedClient.phoneNumber);
        
        // Actualizează în Firebase
        await _firebaseService.updateClientForConsultant(currentUser.uid, clientWithPhoneId);
        
        // Actualizează în lista locală
        final clientIndex = _clients.indexWhere((client) => client.phoneNumber == updatedClient.phoneNumber);
        if (clientIndex != -1) {
          _clients[clientIndex] = clientWithPhoneId;
          
          // Dacă clientul actualizat este cel focusat, actualizează și referința
          if (_focusedClient?.phoneNumber == updatedClient.phoneNumber) {
            _focusedClient = clientWithPhoneId;
          }
          
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error updating client: $e');
    }
  }
  
  /// Mută un client în categoria "Recente" cu statusul "Acceptat"
  Future<void> moveClientToRecente(String clientPhoneNumber, {
    String? additionalInfo,
  }) async {
    final clientIndex = _clients.indexWhere((client) => client.phoneNumber == clientPhoneNumber);
    if (clientIndex != -1) {
      final updatedClient = _clients[clientIndex].copyWith(
        category: ClientCategory.recente,
        status: ClientStatus.normal, // Nu mai este focusat
        discussionStatus: 'Acceptat',
        additionalInfo: additionalInfo,
      );
      
      await updateClient(updatedClient);
      
      // Dacă clientul mutat era focusat, focusează primul client disponibil din "Apeluri"
      if (_focusedClient?.phoneNumber == clientPhoneNumber) {
        final apeluri = getClientsByCategory(ClientCategory.apeluri);
        if (apeluri.isNotEmpty) {
          focusClient(apeluri.first.phoneNumber);
        } else {
          _focusedClient = null;
          notifyListeners();
        }
      }
      
      debugPrint('✅ Client mutat în Recente (Acceptat): ${updatedClient.name}');
    }
  }

  /// Mută un client în categoria "Reveniri" cu statusul "Amânat"
  Future<void> moveClientToReveniri(String clientPhoneNumber, {
    required DateTime scheduledDateTime,
    String? additionalInfo,
  }) async {
    final clientIndex = _clients.indexWhere((client) => client.phoneNumber == clientPhoneNumber);
    if (clientIndex != -1) {
      final updatedClient = _clients[clientIndex].copyWith(
        category: ClientCategory.reveniri,
        status: ClientStatus.normal, // Nu mai este focusat
        discussionStatus: 'Amanat',
        scheduledDateTime: scheduledDateTime,
        additionalInfo: additionalInfo,
      );
      
      await updateClient(updatedClient);
      
      // Dacă clientul mutat era focusat, focusează primul client disponibil din "Apeluri"
      if (_focusedClient?.phoneNumber == clientPhoneNumber) {
        final apeluri = getClientsByCategory(ClientCategory.apeluri);
        if (apeluri.isNotEmpty) {
          focusClient(apeluri.first.phoneNumber);
        } else {
          _focusedClient = null;
          notifyListeners();
        }
      }
      
      debugPrint('✅ Client mutat în Reveniri (Amânat): ${updatedClient.name}');
    }
  }

  /// Mută un client în categoria "Recente" cu statusul "Refuzat"
  Future<void> moveClientToRecenteRefuzat(String clientPhoneNumber, {
    String? additionalInfo,
  }) async {
    final clientIndex = _clients.indexWhere((client) => client.phoneNumber == clientPhoneNumber);
    if (clientIndex != -1) {
      final updatedClient = _clients[clientIndex].copyWith(
        category: ClientCategory.recente,
        status: ClientStatus.normal, // Nu mai este focusat
        discussionStatus: 'Refuzat',
        additionalInfo: additionalInfo,
      );
      
      await updateClient(updatedClient);
      
      // Dacă clientul mutat era focusat, focusează primul client disponibil din "Apeluri"
      if (_focusedClient?.phoneNumber == clientPhoneNumber) {
        final apeluri = getClientsByCategory(ClientCategory.apeluri);
        if (apeluri.isNotEmpty) {
          focusClient(apeluri.first.phoneNumber);
        } else {
          _focusedClient = null;
          notifyListeners();
        }
      }
      
      debugPrint('✅ Client mutat în Recente (Refuzat): ${updatedClient.name}');
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