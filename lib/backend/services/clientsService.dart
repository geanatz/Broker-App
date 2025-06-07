import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// =================== CLIENT MODELS ===================

/// Model pentru reprezentarea unui client și starea formularului său
class ClientModel {
  final String id;
  final String name;
  final String phoneNumber1;
  final String? phoneNumber2;
  final String? coDebitorName;
  final ClientStatus status;
  final ClientCategory category;
  
  // Datele formularului pentru acest client
  Map<String, dynamic> formData;
  
  // Statusul discuției cu clientul
  final String? discussionStatus; // 'Acceptat', 'Amanat', 'Refuzat'
  
  // Data și ora pentru amânare sau întâlnire
  final DateTime? scheduledDateTime;
  
  // Informații adiționale despre discuție
  final String? additionalInfo;
  
  ClientModel({
    required this.id,
    required this.name,
    required this.phoneNumber1,
    this.phoneNumber2,
    this.coDebitorName,
    required this.status,
    required this.category,
    Map<String, dynamic>? formData,
    this.discussionStatus,
    this.scheduledDateTime,
    this.additionalInfo,
  }) : formData = formData ?? {};

  /// Pentru compatibilitate cu codul existent
  String get phoneNumber => phoneNumber1;
  
  /// Copiază clientul cu noi valori
  ClientModel copyWith({
    String? id,
    String? name,
    String? phoneNumber1,
    String? phoneNumber2,
    String? coDebitorName,
    ClientStatus? status,
    ClientCategory? category,
    Map<String, dynamic>? formData,
    String? discussionStatus,
    DateTime? scheduledDateTime,
    String? additionalInfo,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber1: phoneNumber1 ?? this.phoneNumber1,
      phoneNumber2: phoneNumber2 ?? this.phoneNumber2,
      coDebitorName: coDebitorName ?? this.coDebitorName,
      status: status ?? this.status,
      category: category ?? this.category,
      formData: formData ?? Map<String, dynamic>.from(this.formData),
      discussionStatus: discussionStatus ?? this.discussionStatus,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
  
  /// Actualizează datele formularului pentru acest client
  void updateFormData(String key, dynamic value) {
    formData[key] = value;
  }
  
  /// Obține o valoare din datele formularului
  T? getFormValue<T>(String key) {
    return formData[key] as T?;
  }
  
  /// Convertește obiectul ClientModel într-un Map pentru Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber1': phoneNumber1,
      'phoneNumber2': phoneNumber2,
      'coDebitorName': coDebitorName,
      'status': status.index,
      'category': category.index,
      'formData': formData,
      'discussionStatus': discussionStatus,
      'scheduledDateTime': scheduledDateTime?.millisecondsSinceEpoch,
      'additionalInfo': additionalInfo,
    };
  }

  /// Creează un ClientModel dintr-un Map din Firebase
  static ClientModel fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phoneNumber1: map['phoneNumber1'] ?? map['phoneNumber'] ?? '',
      phoneNumber2: map['phoneNumber2'],
      coDebitorName: map['coDebitorName'],
      status: ClientStatus.values[map['status'] ?? 0],
      category: ClientCategory.values[map['category'] ?? 0],
      formData: Map<String, dynamic>.from(map['formData'] ?? {}),
      discussionStatus: map['discussionStatus'],
      scheduledDateTime: map['scheduledDateTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['scheduledDateTime'])
          : null,
      additionalInfo: map['additionalInfo'],
    );
  }
}

/// Statusul unui client (focusat sau normal)
enum ClientStatus {
  normal,   // LightItem7
  focused,  // DarkItem7
}

/// Categoria unui client (în ce secțiune se află)
enum ClientCategory {
  apeluri,   // Secțiunea "Apeluri"
  reveniri,  // Secțiunea "Reveniri" 
  recente,   // Secțiunea "Recente"
}

// =================== UNIFIED CLIENT MODELS ===================

/// Model unificat pentru toate datele unui client
class UnifiedClientModel {
  final String id;
  final String consultantId;
  final ClientBasicInfo basicInfo;
  final ClientFormData formData;
  final List<ClientActivity> activities;
  final UnifiedClientStatus currentStatus;
  final ClientMetadata metadata;

  const UnifiedClientModel({
    required this.id,
    required this.consultantId,
    required this.basicInfo,
    required this.formData,
    required this.activities,
    required this.currentStatus,
    required this.metadata,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'consultantId': consultantId,
      'basicInfo': basicInfo.toMap(),
      'formData': formData.toMap(),
      'activities': activities.map((activity) => activity.toMap()).toList(),
      'currentStatus': currentStatus.toMap(),
      'metadata': metadata.toMap(),
    };
  }

  factory UnifiedClientModel.fromFirestore(Map<String, dynamic> data) {
    return UnifiedClientModel(
      id: data['id'] ?? '',
      consultantId: data['consultantId'] ?? '',
      basicInfo: ClientBasicInfo.fromMap(data['basicInfo'] ?? {}),
      formData: ClientFormData.fromMap(data['formData'] ?? {}),
      activities: (data['activities'] as List<dynamic>? ?? [])
          .map((activity) => ClientActivity.fromMap(activity))
          .toList(),
      currentStatus: UnifiedClientStatus.fromMap(data['currentStatus'] ?? {}),
      metadata: ClientMetadata.fromMap(data['metadata'] ?? {}),
    );
  }

  UnifiedClientModel copyWith({
    String? id,
    String? consultantId,
    ClientBasicInfo? basicInfo,
    ClientFormData? formData,
    List<ClientActivity>? activities,
    UnifiedClientStatus? currentStatus,
    ClientMetadata? metadata,
  }) {
    return UnifiedClientModel(
      id: id ?? this.id,
      consultantId: consultantId ?? this.consultantId,
      basicInfo: basicInfo ?? this.basicInfo,
      formData: formData ?? this.formData,
      activities: activities ?? this.activities,
      currentStatus: currentStatus ?? this.currentStatus,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Informații de bază despre client
class ClientBasicInfo {
  final String name;
  final String phoneNumber1;
  final String? phoneNumber2;
  final String? coDebitorName;
  final String? email;
  final String? address;

  const ClientBasicInfo({
    required this.name,
    required this.phoneNumber1,
    this.phoneNumber2,
    this.coDebitorName,
    this.email,
    this.address,
  });

  String get phoneNumber => phoneNumber1;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber1': phoneNumber1,
      'phoneNumber2': phoneNumber2,
      'coDebitorName': coDebitorName,
      'email': email,
      'address': address,
    };
  }

  factory ClientBasicInfo.fromMap(Map<String, dynamic> map) {
    return ClientBasicInfo(
      name: map['name'] ?? '',
      phoneNumber1: map['phoneNumber1'] ?? map['phoneNumber'] ?? '',
      phoneNumber2: map['phoneNumber2'],
      coDebitorName: map['coDebitorName'],
      email: map['email'],
      address: map['address'],
    );
  }
}

/// Date formular consolidate
class ClientFormData {
  final List<CreditData> clientCredits;
  final List<CreditData> coDebitorCredits;
  final List<IncomeData> clientIncomes;
  final List<IncomeData> coDebitorIncomes;
  final Map<String, dynamic> additionalData;

  const ClientFormData({
    required this.clientCredits,
    required this.coDebitorCredits,
    required this.clientIncomes,
    required this.coDebitorIncomes,
    required this.additionalData,
  });

  Map<String, dynamic> toMap() {
    return {
      'clientCredits': clientCredits.map((credit) => credit.toMap()).toList(),
      'coDebitorCredits': coDebitorCredits.map((credit) => credit.toMap()).toList(),
      'clientIncomes': clientIncomes.map((income) => income.toMap()).toList(),
      'coDebitorIncomes': coDebitorIncomes.map((income) => income.toMap()).toList(),
      'additionalData': additionalData,
    };
  }

  factory ClientFormData.fromMap(Map<String, dynamic> map) {
    return ClientFormData(
      clientCredits: (map['clientCredits'] as List<dynamic>? ?? [])
          .map((credit) => CreditData.fromMap(credit))
          .toList(),
      coDebitorCredits: (map['coDebitorCredits'] as List<dynamic>? ?? [])
          .map((credit) => CreditData.fromMap(credit))
          .toList(),
      clientIncomes: (map['clientIncomes'] as List<dynamic>? ?? [])
          .map((income) => IncomeData.fromMap(income))
          .toList(),
      coDebitorIncomes: (map['coDebitorIncomes'] as List<dynamic>? ?? [])
          .map((income) => IncomeData.fromMap(income))
          .toList(),
      additionalData: Map<String, dynamic>.from(map['additionalData'] ?? {}),
    );
  }

  ClientFormData copyWith({
    List<CreditData>? clientCredits,
    List<CreditData>? coDebitorCredits,
    List<IncomeData>? clientIncomes,
    List<IncomeData>? coDebitorIncomes,
    Map<String, dynamic>? additionalData,
  }) {
    return ClientFormData(
      clientCredits: clientCredits ?? this.clientCredits,
      coDebitorCredits: coDebitorCredits ?? this.coDebitorCredits,
      clientIncomes: clientIncomes ?? this.clientIncomes,
      coDebitorIncomes: coDebitorIncomes ?? this.coDebitorIncomes,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}

/// Date credit
class CreditData {
  final String id;
  final String bank;
  final String creditType;
  final double? currentBalance;
  final double? consumedAmount;
  final String rateType;
  final double? monthlyPayment;
  final int? remainingMonths;

  const CreditData({
    required this.id,
    required this.bank,
    required this.creditType,
    this.currentBalance,
    this.consumedAmount,
    required this.rateType,
    this.monthlyPayment,
    this.remainingMonths,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bank': bank,
      'creditType': creditType,
      'currentBalance': currentBalance,
      'consumedAmount': consumedAmount,
      'rateType': rateType,
      'monthlyPayment': monthlyPayment,
      'remainingMonths': remainingMonths,
    };
  }

  factory CreditData.fromMap(Map<String, dynamic> map) {
    return CreditData(
      id: map['id'] ?? '',
      bank: map['bank'] ?? '',
      creditType: map['creditType'] ?? '',
      currentBalance: map['currentBalance']?.toDouble(),
      consumedAmount: map['consumedAmount']?.toDouble(),
      rateType: map['rateType'] ?? '',
      monthlyPayment: map['monthlyPayment']?.toDouble(),
      remainingMonths: map['remainingMonths']?.toInt(),
    );
  }
}

/// Date venit
class IncomeData {
  final String id;
  final String bank;
  final String incomeType;
  final double? monthlyAmount;
  final int? seniority;

  const IncomeData({
    required this.id,
    required this.bank,
    required this.incomeType,
    this.monthlyAmount,
    this.seniority,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bank': bank,
      'incomeType': incomeType,
      'monthlyAmount': monthlyAmount,
      'seniority': seniority,
    };
  }

  factory IncomeData.fromMap(Map<String, dynamic> map) {
    return IncomeData(
      id: map['id'] ?? '',
      bank: map['bank'] ?? '',
      incomeType: map['incomeType'] ?? '',
      monthlyAmount: map['monthlyAmount']?.toDouble(),
      seniority: map['seniority']?.toInt(),
    );
  }
}

/// Activități client
class ClientActivity {
  final String id;
  final ClientActivityType type;
  final DateTime dateTime;
  final String? description;
  final Map<String, dynamic>? additionalData;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ClientActivity({
    required this.id,
    required this.type,
    required this.dateTime,
    this.description,
    this.additionalData,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'dateTime': Timestamp.fromDate(dateTime),
      'description': description,
      'additionalData': additionalData,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ClientActivity.fromMap(Map<String, dynamic> map) {
    return ClientActivity(
      id: map['id'] ?? '',
      type: ClientActivityType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => ClientActivityType.other,
      ),
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      description: map['description'],
      additionalData: map['additionalData'] != null 
          ? Map<String, dynamic>.from(map['additionalData'])
          : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}

/// Tipuri de activități client
enum ClientActivityType {
  meeting,
  bureauDelete,
  statusChange,
  formUpdate,
  phoneCall,
  other,
}

/// Status unificat client
class UnifiedClientStatus {
  final UnifiedClientCategory category;
  final ClientDiscussionStatus? discussionStatus;
  final DateTime? scheduledDateTime;
  final String? additionalInfo;
  final bool isFocused;

  const UnifiedClientStatus({
    required this.category,
    this.discussionStatus,
    this.scheduledDateTime,
    this.additionalInfo,
    required this.isFocused,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category.name,
      'discussionStatus': discussionStatus?.name,
      'scheduledDateTime': scheduledDateTime != null 
          ? Timestamp.fromDate(scheduledDateTime!)
          : null,
      'additionalInfo': additionalInfo,
      'isFocused': isFocused,
    };
  }

  factory UnifiedClientStatus.fromMap(Map<String, dynamic> map) {
    return UnifiedClientStatus(
      category: UnifiedClientCategory.values.firstWhere(
        (cat) => cat.name == map['category'],
        orElse: () => UnifiedClientCategory.apeluri,
      ),
      discussionStatus: map['discussionStatus'] != null
          ? ClientDiscussionStatus.values.firstWhere(
              (status) => status.name == map['discussionStatus'],
            )
          : null,
      scheduledDateTime: map['scheduledDateTime'] != null 
          ? (map['scheduledDateTime'] as Timestamp).toDate()
          : null,
      additionalInfo: map['additionalInfo'],
      isFocused: map['isFocused'] ?? false,
    );
  }
}

/// Categorii client unificate
enum UnifiedClientCategory {
  apeluri,
  reveniri,
  recente,
}

/// Status discuție
enum ClientDiscussionStatus {
  acceptat,
  amanat,
  refuzat,
}

/// Metadate client
class ClientMetadata {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? source;
  final int version;
  final Map<String, dynamic>? customData;

  const ClientMetadata({
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.source,
    required this.version,
    this.customData,
  });

  Map<String, dynamic> toMap() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'source': source,
      'version': version,
      'customData': customData,
    };
  }

  factory ClientMetadata.fromMap(Map<String, dynamic> map) {
    return ClientMetadata(
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] ?? '',
      source: map['source'],
      version: map['version'] ?? 1,
      customData: map['customData'] != null
          ? Map<String, dynamic>.from(map['customData'])
          : null,
    );
  }
}

// =================== SERVICE CLASS ===================

/// Firebase service pentru gestionarea datelor clienților
/// Serviciu unificat pentru toate operațiile cu clienții
class ClientsFirebaseService {
  static final ClientsFirebaseService _instance = ClientsFirebaseService._internal();
  factory ClientsFirebaseService() => _instance;
  ClientsFirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Constante pentru organizarea bazei de date
  static const String _consultantsCollection = 'consultants';
  static const String _clientsSubcollection = 'clients';
  static const String _formSubcollection = 'form';
  static const String _meetingsSubcollection = 'meetings';
  static const String _loanDocument = 'loan';
  static const String _incomeDocument = 'income';

  User? get _currentUser => _auth.currentUser;

  /// Obține referința către colecția clienților pentru consultantul curent
  CollectionReference<Map<String, dynamic>>? get _clientsCollection {
    final user = _currentUser;
    if (user == null) return null;
    
    return _firestore
        .collection(_consultantsCollection)
        .doc(user.uid)
        .collection(_clientsSubcollection);
  }

  /// Obține referința către subcollection form pentru un client specific
  CollectionReference<Map<String, dynamic>>? _getFormCollection(String phoneNumber) {
    return _clientsCollection?.doc(phoneNumber).collection(_formSubcollection);
  }

  /// Obține referința către subcollection meetings pentru un client specific
  CollectionReference<Map<String, dynamic>>? _getMeetingsCollection(String phoneNumber) {
    return _clientsCollection?.doc(phoneNumber).collection(_meetingsSubcollection);
  }

  // =================== OPERAȚII CRUD CLIENTS ===================

  /// Creează un client nou (documentul va fi numit cu numărul de telefon)
  Future<bool> createClient({
    required String phoneNumber,
    required String name,
    String? coDebitorName,
    String? coDebitorPhone,
    String? email,
    String? address,
    UnifiedClientStatus? status,
    String? source,
  }) async {
    final user = _currentUser;
    if (user == null) {
      debugPrint('Error: User not authenticated');
      return false;
    }

    final collection = _clientsCollection;
    if (collection == null) return false;

    try {
      final now = DateTime.now();

      final clientData = {
        'phoneNumber': phoneNumber,
        'name': name,
        'coDebitorName': coDebitorName,
        'coDebitorPhone': coDebitorPhone,
        'email': email,
        'address': address,
        'currentStatus': (status ?? UnifiedClientStatus(
          category: UnifiedClientCategory.apeluri,
          isFocused: false,
        )).toMap(),
        'metadata': {
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
          'createdBy': user.uid,
          'source': source ?? 'manual',
          'version': 1,
        },
      };

      // Folosește numărul de telefon ca ID al documentului
      await collection.doc(phoneNumber).set(clientData);
      
      debugPrint('✅ Client created successfully: $name (Phone: $phoneNumber)');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating client: $e');
      return false;
    }
  }

  /// Salvează un client în Firebase pentru un consultant specific
  /// Folosește numărul de telefon ca ID al documentului
  Future<void> saveClientForConsultant(String consultantId, ClientModel client) async {
    try {
      // Convertește ClientModel în noua structură
      final success = await createClient(
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

  /// Obține un client după numărul de telefon cu toate datele sale
  Future<UnifiedClientModel?> getClient(String phoneNumber) async {
    final collection = _clientsCollection;
    if (collection == null) return null;

    try {
      // Obține datele de bază ale clientului
      final clientDoc = await collection.doc(phoneNumber).get();
      if (!clientDoc.exists) return null;

      final clientData = clientDoc.data()!;

      // Obține datele formularului (loan și income)
      final formData = await _getClientFormData(phoneNumber);

      // Obține toate meetings-urile clientului
      final activities = await _getClientMeetings(phoneNumber);

      return UnifiedClientModel(
        id: phoneNumber, // ID-ul este numărul de telefon
        consultantId: _currentUser?.uid ?? '',
        basicInfo: ClientBasicInfo(
          name: clientData['name'] ?? '',
          phoneNumber1: clientData['phoneNumber1'] ?? clientData['phoneNumber'] ?? phoneNumber,
          phoneNumber2: clientData['phoneNumber2'],
          coDebitorName: clientData['coDebitorName'],
          email: clientData['email'],
          address: clientData['address'],
        ),
        formData: formData,
        activities: activities,
        currentStatus: UnifiedClientStatus.fromMap(clientData['currentStatus'] ?? {}),
        metadata: ClientMetadata.fromMap(clientData['metadata'] ?? {}),
      );
    } catch (e) {
      debugPrint('❌ Error getting client: $e');
      return null;
    }
  }

  /// Obține toți clienții pentru consultantul curent
  Future<List<UnifiedClientModel>> getAllClients() async {
    final collection = _clientsCollection;
    if (collection == null) {
      debugPrint('❌ ClientsFirebaseService: Collection is null (user not authenticated)');
      return [];
    }

    try {
      debugPrint('🔍 ClientsFirebaseService: Început interogare Firebase...');
      
      final snapshot = await collection
          .orderBy('metadata.updatedAt', descending: true)
          .get();
      
      debugPrint('🔍 ClientsFirebaseService: Firebase snapshot obținut cu ${snapshot.docs.length} documente');
      
      final List<UnifiedClientModel> clients = [];
      for (final doc in snapshot.docs) {
        debugPrint('🔍 ClientsFirebaseService: Procesez client: ${doc.id}');
        final client = await getClient(doc.id);
        if (client != null) {
          clients.add(client);
        }
      }
      
      debugPrint('🔍 ClientsFirebaseService: Finalizat cu ${clients.length} clienți valizi');
      return clients;
    } catch (e) {
      debugPrint('❌ Error getting all clients: $e');
      return [];
    }
  }

  /// Obține toți clienții pentru un consultant specific (compatibility method)
  Future<List<ClientModel>> getAllClientsForConsultant(String consultantId) async {
    try {
      final unifiedClients = await getAllClients();
      return unifiedClients.map((unifiedClient) => _convertToClientModel(unifiedClient)).toList();
    } catch (e) {
      throw Exception('Eroare la încărcarea clienților: $e');
    }
  }

  /// Actualizează informațiile de bază ale unui client
  Future<bool> updateClient(String phoneNumber, {
    String? name,
    String? coDebitorName,
    String? coDebitorPhone,
    String? email,
    String? address,
    UnifiedClientStatus? currentStatus,
  }) async {
    final collection = _clientsCollection;
    if (collection == null) return false;

    try {
      final updateData = <String, dynamic>{
        'metadata.updatedAt': Timestamp.fromDate(DateTime.now()),
        'metadata.version': FieldValue.increment(1),
      };

      if (name != null) updateData['name'] = name;
      if (coDebitorName != null) updateData['coDebitorName'] = coDebitorName;
      if (coDebitorPhone != null) updateData['coDebitorPhone'] = coDebitorPhone;
      if (email != null) updateData['email'] = email;
      if (address != null) updateData['address'] = address;
      if (currentStatus != null) updateData['currentStatus'] = currentStatus.toMap();

      await collection.doc(phoneNumber).update(updateData);
      
      debugPrint('✅ Client updated successfully: $phoneNumber');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating client: $e');
      return false;
    }
  }

  /// Șterge un client și toate subcollections-urile sale
  Future<bool> deleteClient(String phoneNumber) async {
    final collection = _clientsCollection;
    if (collection == null) return false;

    try {
      final batch = _firestore.batch();

      // Șterge toate meetings-urile
      final meetingsSnapshot = await _getMeetingsCollection(phoneNumber)?.get();
      if (meetingsSnapshot != null) {
        for (final doc in meetingsSnapshot.docs) {
          batch.delete(doc.reference);
        }
      }

      // Șterge documentele form (loan și income)
      final formCollection = _getFormCollection(phoneNumber);
      if (formCollection != null) {
        batch.delete(formCollection.doc(_loanDocument));
        batch.delete(formCollection.doc(_incomeDocument));
      }

      // Șterge clientul
      batch.delete(collection.doc(phoneNumber));

      await batch.commit();
      
      debugPrint('✅ Client deleted successfully: $phoneNumber');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting client: $e');
      return false;
    }
  }

  /// Șterge un client din Firebase pentru un consultant specific
  Future<void> deleteClientForConsultant(String consultantId, String clientId) async {
    try {
      // În noua structură, clientId este de fapt phoneNumber
      final success = await deleteClient(clientId);
      
      if (!success) {
        throw Exception('Failed to delete client in unified structure');
      }
    } catch (e) {
      throw Exception('Eroare la ștergerea clientului: $e');
    }
  }

  /// Actualizează un client în Firebase pentru un consultant specific
  Future<void> updateClientForConsultant(String consultantId, ClientModel client) async {
    try {
      final success = await updateClient(
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

  /// Șterge toți clienții pentru consultantul curent în mod optimizat (batch operation)
  Future<bool> deleteAllClients() async {
    final collection = _clientsCollection;
    if (collection == null) return false;

    try {
      // Obține toți clienții pentru consultantul curent
      final snapshot = await collection.get();
      
      if (snapshot.docs.isEmpty) {
        debugPrint('✅ No clients to delete');
        return true;
      }

      // Folosește batch pentru ștergerea optimizată
      final batch = _firestore.batch();
      int batchCount = 0;
      const maxBatchSize = 500; // Firestore limit pentru batch

      for (final clientDoc in snapshot.docs) {
        final phoneNumber = clientDoc.id;
        
        // Șterge meetings-urile clientului
        final meetingsSnapshot = await _getMeetingsCollection(phoneNumber)?.get();
        if (meetingsSnapshot != null) {
          for (final meetingDoc in meetingsSnapshot.docs) {
            batch.delete(meetingDoc.reference);
            batchCount++;
            
            // Commit batch dacă ajungem la limită
            if (batchCount >= maxBatchSize) {
              await batch.commit();
              batchCount = 0;
            }
          }
        }

        // Șterge documentele form (loan și income)
        final formCollection = _getFormCollection(phoneNumber);
        if (formCollection != null) {
          batch.delete(formCollection.doc(_loanDocument));
          batch.delete(formCollection.doc(_incomeDocument));
          batchCount += 2;
        }

        // Șterge clientul
        batch.delete(clientDoc.reference);
        batchCount++;

        // Commit batch dacă ajungem la limită
        if (batchCount >= maxBatchSize) {
          await batch.commit();
          batchCount = 0;
        }
      }

      // Commit ultimul batch dacă mai sunt operații rămase
      if (batchCount > 0) {
        await batch.commit();
      }

      debugPrint('✅ All clients deleted successfully (${snapshot.docs.length} clients)');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting all clients: $e');
      return false;
    }
  }

  /// Șterge toți clienții pentru un consultant specific
  Future<void> deleteAllClientsForConsultant(String consultantId) async {
    try {
      // Folosește metoda optimizată pentru ștergerea în lot
      final success = await deleteAllClients();
      
      if (!success) {
        throw Exception('Failed to delete all clients in unified structure');
      }
    } catch (e) {
      throw Exception('Eroare la ștergerea tuturor clienților: $e');
    }
  }

  /// Stream pentru toți clienții consultantului curent
  Stream<List<UnifiedClientModel>> getClientsStream() {
    final collection = _clientsCollection;
    if (collection == null) {
      return Stream.value([]);
    }

    return collection
        .orderBy('metadata.updatedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final List<UnifiedClientModel> clients = [];
          for (final doc in snapshot.docs) {
            final client = await getClient(doc.id);
            if (client != null) {
              clients.add(client);
            }
          }
          return clients;
        });
  }

  /// Stream pentru ascultarea modificărilor în timp real pentru un consultant specific
  Stream<List<ClientModel>> getClientsStreamForConsultant(String consultantId) {
    return getClientsStream().map((unifiedClients) =>
        unifiedClients.map((unifiedClient) => _convertToClientModel(unifiedClient)).toList());
  }

  // =================== HELPER METHODS ===================

  /// Obține datele formularului pentru un client
  Future<ClientFormData> _getClientFormData(String phoneNumber) async {
    try {
      final formCollection = _getFormCollection(phoneNumber);
      if (formCollection == null) {
        return _emptyFormData();
      }

      // Obține datele de loan
      final loanDoc = await formCollection.doc(_loanDocument).get();
      final loanData = loanDoc.exists ? loanDoc.data()! : <String, dynamic>{};

      // Obține datele de income
      final incomeDoc = await formCollection.doc(_incomeDocument).get();
      final incomeData = incomeDoc.exists ? incomeDoc.data()! : <String, dynamic>{};

      return ClientFormData(
        clientCredits: (loanData['clientCredits'] as List<dynamic>? ?? [])
            .map((credit) => CreditData.fromMap(credit))
            .toList(),
        coDebitorCredits: (loanData['coDebitorCredits'] as List<dynamic>? ?? [])
            .map((credit) => CreditData.fromMap(credit))
            .toList(),
        clientIncomes: (incomeData['clientIncomes'] as List<dynamic>? ?? [])
            .map((income) => IncomeData.fromMap(income))
            .toList(),
        coDebitorIncomes: (incomeData['coDebitorIncomes'] as List<dynamic>? ?? [])
            .map((income) => IncomeData.fromMap(income))
            .toList(),
        additionalData: {
          ...Map<String, dynamic>.from(loanData['additionalData'] ?? {}),
          ...Map<String, dynamic>.from(incomeData['additionalData'] ?? {}),
        },
      );
    } catch (e) {
      debugPrint('❌ Error getting client form data: $e');
      return _emptyFormData();
    }
  }

  /// Obține meetings-urile pentru un client
  Future<List<ClientActivity>> _getClientMeetings(String phoneNumber) async {
    try {
      final meetingsCollection = _getMeetingsCollection(phoneNumber);
      if (meetingsCollection == null) return [];

      final meetingsSnapshot = await meetingsCollection
          .orderBy('dateTime', descending: false)
          .get();
      
      return meetingsSnapshot.docs.map((doc) {
        final data = doc.data();
        return ClientActivity(
          id: doc.id,
          type: data['type'] == 'bureauDelete' 
              ? ClientActivityType.bureauDelete 
              : ClientActivityType.meeting,
          dateTime: (data['dateTime'] as Timestamp).toDate(),
          description: data['description'] ?? 'Întâlnire',
          additionalData: Map<String, dynamic>.from(data['additionalData'] ?? {}),
          createdAt: data['createdAt'] != null 
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          updatedAt: data['updatedAt'] != null 
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting client meetings: $e');
      return [];
    }
  }

  /// Returnează date formular goale
  ClientFormData _emptyFormData() {
    return ClientFormData(
      clientCredits: [],
      coDebitorCredits: [],
      clientIncomes: [],
      coDebitorIncomes: [],
      additionalData: {},
    );
  }

  /// Convertește ClientModel în UnifiedClientStatus pentru noua structură
  UnifiedClientStatus _convertToUnifiedStatus(ClientModel client) {
    return UnifiedClientStatus(
      category: _convertToUnifiedCategory(client.category),
      isFocused: client.status == ClientStatus.focused,
      discussionStatus: _convertDiscussionStatus(client.discussionStatus),
      scheduledDateTime: client.scheduledDateTime,
      additionalInfo: client.additionalInfo,
    );
  }

  /// Convertește ClientCategory din vechea structură în noua structură
  UnifiedClientCategory _convertToUnifiedCategory(ClientCategory oldCategory) {
    switch (oldCategory) {
      case ClientCategory.apeluri:
        return UnifiedClientCategory.apeluri;
      case ClientCategory.reveniri:
        return UnifiedClientCategory.reveniri;
      case ClientCategory.recente:
        return UnifiedClientCategory.recente;
    }
  }

  /// Convertește string discussion status în enum
  ClientDiscussionStatus? _convertDiscussionStatus(String? discussionStatus) {
    if (discussionStatus == null) return null;
    
    switch (discussionStatus.toLowerCase()) {
      case 'acceptat':
        return ClientDiscussionStatus.acceptat;
      case 'amanat':
        return ClientDiscussionStatus.amanat;
      case 'refuzat':
        return ClientDiscussionStatus.refuzat;
      default:
        return null;
    }
  }

  /// Convertește UnifiedClientModel în ClientModel pentru compatibilitate
  ClientModel _convertToClientModel(UnifiedClientModel unifiedClient) {
    return ClientModel(
      id: unifiedClient.basicInfo.phoneNumber1, // Folosește phoneNumber1 ca ID
      name: unifiedClient.basicInfo.name,
      phoneNumber1: unifiedClient.basicInfo.phoneNumber1,
      phoneNumber2: unifiedClient.basicInfo.phoneNumber2,
      coDebitorName: unifiedClient.basicInfo.coDebitorName,
      status: unifiedClient.currentStatus.isFocused ? ClientStatus.focused : ClientStatus.normal,
      category: _convertFromUnifiedCategory(unifiedClient.currentStatus.category),
      formData: {}, // FormData este gestionat separat în noua structură
      discussionStatus: unifiedClient.currentStatus.discussionStatus?.name,
      scheduledDateTime: unifiedClient.currentStatus.scheduledDateTime,
      additionalInfo: unifiedClient.currentStatus.additionalInfo,
    );
  }

  /// Convertește ClientCategory din noua structură în vechea structură
  ClientCategory _convertFromUnifiedCategory(UnifiedClientCategory unifiedCategory) {
    switch (unifiedCategory) {
      case UnifiedClientCategory.apeluri:
        return ClientCategory.apeluri;
      case UnifiedClientCategory.reveniri:
        return ClientCategory.reveniri;
      case UnifiedClientCategory.recente:
        return ClientCategory.recente;
    }
  }

  // =================== ADDITIONAL METHODS ===================
  
  /// Salvează datele de credite (loan) pentru un client
  Future<bool> saveLoanData(String phoneNumber, {
    required List<CreditData> clientCredits,
    required List<CreditData> coDebitorCredits,
    Map<String, dynamic>? additionalData,
  }) async {
    final formCollection = _getFormCollection(phoneNumber);
    if (formCollection == null) return false;

    try {
      final loanData = {
        'clientCredits': clientCredits.map((c) => c.toMap()).toList(),
        'coDebitorCredits': coDebitorCredits.map((c) => c.toMap()).toList(),
        'additionalData': additionalData ?? {},
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await formCollection.doc(_loanDocument).set(loanData, SetOptions(merge: true));

      // Actualizează timestamp-ul clientului
      await _updateClientTimestamp(phoneNumber);
      
      debugPrint('✅ Loan data saved successfully for client: $phoneNumber');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving loan data: $e');
      return false;
    }
  }

  /// Salvează datele de venituri (income) pentru un client
  Future<bool> saveIncomeData(String phoneNumber, {
    required List<IncomeData> clientIncomes,
    required List<IncomeData> coDebitorIncomes,
    Map<String, dynamic>? additionalData,
  }) async {
    final formCollection = _getFormCollection(phoneNumber);
    if (formCollection == null) return false;

    try {
      final incomeData = {
        'clientIncomes': clientIncomes.map((i) => i.toMap()).toList(),
        'coDebitorIncomes': coDebitorIncomes.map((i) => i.toMap()).toList(),
        'additionalData': additionalData ?? {},
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await formCollection.doc(_incomeDocument).set(incomeData, SetOptions(merge: true));

      // Actualizează timestamp-ul clientului
      await _updateClientTimestamp(phoneNumber);
      
      debugPrint('✅ Income data saved successfully for client: $phoneNumber');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving income data: $e');
      return false;
    }
  }

  /// Programează o întâlnire pentru un client
  Future<bool> scheduleMeeting(String phoneNumber, DateTime dateTime, {
    String? description,
    String? type,
    Map<String, dynamic>? additionalData,
  }) async {
    final meetingsCollection = _getMeetingsCollection(phoneNumber);
    if (meetingsCollection == null) return false;

    try {
      // Obține numele clientului pentru a-l include în additionalData
      final client = await getClient(phoneNumber);
      final clientName = client?.basicInfo.name ?? 'Client necunoscut';
      
      // Combină additionalData cu informațiile esențiale
      final combinedAdditionalData = <String, dynamic>{
        'phoneNumber': phoneNumber,
        'clientName': clientName,
        ...?additionalData,
      };

      final meetingData = {
        'type': type ?? 'meeting',
        'dateTime': Timestamp.fromDate(dateTime),
        'description': description ?? 'Întâlnire programată',
        'additionalData': combinedAdditionalData,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await meetingsCollection.add(meetingData);

      // Actualizează timestamp-ul clientului
      await _updateClientTimestamp(phoneNumber);
      
      debugPrint('✅ Meeting scheduled successfully for client: $phoneNumber ($clientName)');
      return true;
    } catch (e) {
      debugPrint('❌ Error scheduling meeting: $e');
      return false;
    }
  }

  /// Actualizează timestamp-ul clientului
  Future<void> _updateClientTimestamp(String phoneNumber) async {
    try {
      await updateClient(phoneNumber);
    } catch (e) {
      debugPrint('❌ Error updating client timestamp: $e');
    }
  }

  /// Obține toate meetings-urile pentru consultantul curent
  Future<List<ClientActivity>> getAllMeetings() async {
    final collection = _clientsCollection;
    if (collection == null) return [];

    try {
      final snapshot = await collection.get();
      final List<ClientActivity> allMeetings = [];

      for (final clientDoc in snapshot.docs) {
        final phoneNumber = clientDoc.id;
        final meetings = await _getClientMeetings(phoneNumber);
        allMeetings.addAll(meetings);
      }

      // Sortează toate meetings-urile după dată
      allMeetings.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      
      debugPrint('✅ Retrieved ${allMeetings.length} total meetings');
      return allMeetings;
    } catch (e) {
      debugPrint('❌ Error getting all meetings: $e');
      return [];
    }
  }

  /// Obține toate meetings-urile pentru toată echipa (alias pentru getAllMeetings)
  Future<List<ClientActivity>> getAllTeamMeetings() async {
    // Pentru moment, întoarce meetings-urile consultantului curent
    // În viitor, poate fi extins pentru a include meetings-urile de la toată echipa
    return await getAllMeetings();
  }

  /// Actualizează o întâlnire existentă
  Future<bool> updateMeeting(String phoneNumber, String meetingId, {
    DateTime? dateTime,
    String? description,
    String? type,
    Map<String, dynamic>? additionalData,
  }) async {
    final meetingsCollection = _getMeetingsCollection(phoneNumber);
    if (meetingsCollection == null) return false;

    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (dateTime != null) updateData['dateTime'] = Timestamp.fromDate(dateTime);
      if (description != null) updateData['description'] = description;
      if (type != null) updateData['type'] = type;
      if (additionalData != null) {
        updateData['additionalData'] = additionalData;
      }

      await meetingsCollection.doc(meetingId).update(updateData);

      // Actualizează timestamp-ul clientului
      await _updateClientTimestamp(phoneNumber);
      
      debugPrint('✅ Meeting updated successfully: $meetingId for $phoneNumber');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating meeting: $e');
      return false;
    }
  }

  /// Șterge o întâlnire
  Future<bool> deleteMeeting(String phoneNumber, String meetingId) async {
    final meetingsCollection = _getMeetingsCollection(phoneNumber);
    if (meetingsCollection == null) return false;

    try {
      await meetingsCollection.doc(meetingId).delete();

      // Actualizează timestamp-ul clientului
      await _updateClientTimestamp(phoneNumber);
      
      debugPrint('✅ Meeting deleted successfully: $meetingId for $phoneNumber');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting meeting: $e');
      return false;
    }
  }

  /// Obține întâlnirile pentru o dată specifică (pentru tot team-ul)
  Future<List<ClientActivity>> getTeamMeetingsForDate(DateTime date) async {
    try {
      final allMeetings = await getAllMeetings();
      
      // Filtrează întâlnirile pentru data specificată
      final meetingsForDate = allMeetings.where((meeting) {
        final meetingDate = DateTime(
          meeting.dateTime.year,
          meeting.dateTime.month,
          meeting.dateTime.day,
        );
        final targetDate = DateTime(date.year, date.month, date.day);
        return meetingDate.isAtSameMomentAs(targetDate);
      }).toList();

      debugPrint('✅ Found ${meetingsForDate.length} meetings for date: ${date.toString().split(' ')[0]}');
      return meetingsForDate;
    } catch (e) {
      debugPrint('❌ Error getting team meetings for date: $e');
      return [];
    }
  }

  /// Verifică dacă un slot de timp este disponibil
  Future<bool> isTimeSlotAvailable(DateTime dateTime, {String? excludePhoneNumber}) async {
    try {
      final allMeetings = await getAllMeetings();
      
      // Verifică dacă există conflicte în intervalul de 30 de minute
      final conflictingMeetings = allMeetings.where((meeting) {
        // Exclude meeting-ul pentru același client dacă este specificat
        if (excludePhoneNumber != null && 
            meeting.additionalData?['phoneNumber'] == excludePhoneNumber) {
          return false;
        }
        
        final timeDifference = meeting.dateTime.difference(dateTime).abs();
        return timeDifference.inMinutes < 30; // Interval de 30 minute între întâlniri
      }).toList();

      final isAvailable = conflictingMeetings.isEmpty;
      debugPrint('✅ Time slot ${dateTime.toString()} is ${isAvailable ? 'available' : 'not available'}');
      
      return isAvailable;
    } catch (e) {
      debugPrint('❌ Error checking time slot availability: $e');
      return false;
    }
  }
}
