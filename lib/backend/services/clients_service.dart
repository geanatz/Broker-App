import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'dashboard_service.dart' as dashboard;
import 'firebase_service.dart';
import 'splash_service.dart';

// =================== CLIENT MODELS ===================

/// Model pentru reprezentarea unui client si starea formularului sau
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
  
  // Statusul discutiei cu clientul
  final String? discussionStatus; // 'Acceptat', 'Amanat', 'Refuzat'
  
  // Data si ora pentru amanare sau intalnire
  final DateTime? scheduledDateTime;
  
  // Informatii aditionale despre discutie
  final String? additionalInfo;
  
  // Flag pentru a marca daca formularul a fost contorizat
  final bool isCompleted;

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
    this.isCompleted = false, // Valoare default
  }) : formData = formData ?? {};

  /// Pentru compatibilitate cu codul existent
  String get phoneNumber => phoneNumber1;
  
  /// Copiaza clientul cu noi valori
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
    bool? isCompleted,
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
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
  
  /// Actualizeaza datele formularului pentru acest client
  void updateFormData(String key, dynamic value) {
    formData[key] = value;
  }
  
  /// Obtine o valoare din datele formularului
  T? getFormValue<T>(String key) {
    return formData[key] as T?;
  }
  
  /// Converteste obiectul ClientModel intr-un Map pentru Firebase
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
      'isCompleted': isCompleted,
    };
  }

  /// Creeaza un ClientModel dintr-un Map din Firebase (din noua structura)
  static ClientModel fromMap(Map<String, dynamic> map) {
    // Creating ClientModel from Firebase data
    
    return ClientModel(
      id: map['phoneNumber'] ?? map['id'] ?? '', // phoneNumber este ID-ul in noua structura
      name: map['name'] ?? '',
      phoneNumber1: map['phoneNumber'] ?? map['phoneNumber1'] ?? '',
      phoneNumber2: map['phoneNumber2'],
      coDebitorName: map['coDebitorName'],
      status: ClientStatus.values[map['status'] is String ? _parseStatus(map['status']) : (map['status'] ?? 0)],
      category: ClientCategory.values[map['category'] is String ? _parseCategory(map['category']) : (map['category'] ?? 0)],
      formData: Map<String, dynamic>.from(map['formData'] ?? {}),
      discussionStatus: map['discussionStatus'],
      scheduledDateTime: map['scheduledDateTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['scheduledDateTime'])
          : null,
      additionalInfo: map['additionalInfo'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  /// Helper pentru parsarea statusului din string
  static int _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'focused': return 1;
      case 'normal':
      default: return 0;
    }
  }

  /// Helper pentru parsarea categoriei din string
  static int _parseCategory(String category) {
    switch (category.toLowerCase()) {
      case 'reveniri': return 1;
      case 'recente': return 2;
      case 'apeluri':
      default: return 0;
    }
  }
}

/// Statusul unui client (focusat sau normal)
enum ClientStatus {
  normal,   // LightItem7
  focused,  // DarkItem7
}

/// Categoria unui client (in ce sectiune se afla)
enum ClientCategory {
  apeluri,   // Sectiunea "Apeluri"
  reveniri,  // Sectiunea "Reveniri" 
  recente,   // Sectiunea "Recente"
}

// =================== SERVICE CLASS REFACTORIZAT ===================

/// Serviciu refactorizat pentru gestionarea clientilor cu noua structura Firebase
/// Foloseste NewFirebaseService pentru separarea corecta a datelor per consultant
class ClientsService {
  static final ClientsService _instance = ClientsService._internal();
  factory ClientsService() => _instance;
  ClientsService._internal();

  final NewFirebaseService _firebaseService = NewFirebaseService();

  // =================== OPERATII CRUD CLIENTS ===================

  /// Creeaza un client nou pentru consultantul curent
  Future<bool> createClient({
    required String phoneNumber,
    required String name,
    String? coDebitorName,
    String? phoneNumber2,
    ClientStatus? status,
    ClientCategory? category,
    Map<String, dynamic>? formData,
  }) async {
    try {
      final success = await _firebaseService.createClient(
        phoneNumber: phoneNumber,
        name: name,
        coDebitorName: coDebitorName,
        status: _statusToString(status ?? ClientStatus.normal),
        category: _categoryToString(category ?? ClientCategory.apeluri),
        additionalData: {
          'phoneNumber2': phoneNumber2,
          'formData': formData ?? {},
          'isCompleted': false,
        },
      );

      if (success) {
        debugPrint('✅ Client created successfully: $name ($phoneNumber)');
        
        // Notifica dashboard-ul
        _notifyClientCreated();
      }

      return success;
    } catch (e) {
      debugPrint('❌ Error creating client: $e');
      return false;
    }
  }

  /// Obtine un client dupa numarul de telefon (doar pentru consultantul curent)
  Future<ClientModel?> getClient(String phoneNumber) async {
    try {
      final clientData = await _firebaseService.getClient(phoneNumber);
      
      if (clientData != null) {
        return ClientModel.fromMap(clientData);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting client: $e');
      return null;
    }
  }

  /// Obtine toti clientii pentru consultantul curent
  Future<List<ClientModel>> getAllClients() async {
    try {
      final clientsData = await _firebaseService.getAllClients();
      final clients = clientsData.map((data) => ClientModel.fromMap(data)).toList();
      return clients;
    } catch (e) {
      debugPrint('❌ Error getting all clients: $e');
      return [];
    }
  }

  /// Obtine clientii filtrati dupa categorie
  Future<List<ClientModel>> getClientsByCategory(ClientCategory category) async {
    try {
      final allClients = await getAllClients();
      return allClients.where((client) => client.category == category).toList();
    } catch (e) {
      debugPrint('❌ Error getting clients by category: $e');
      return [];
    }
  }

  /// Actualizeaza un client
  Future<bool> updateClient(String phoneNumber, {
    String? name,
    String? phoneNumber2,
    String? coDebitorName,
    ClientStatus? status,
    ClientCategory? category,
    Map<String, dynamic>? formData,
    String? discussionStatus,
    DateTime? scheduledDateTime,
    String? additionalInfo,
    bool? isCompleted,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (name != null) updates['name'] = name;
      if (phoneNumber2 != null) updates['phoneNumber2'] = phoneNumber2;
      if (coDebitorName != null) updates['coDebitorName'] = coDebitorName;
      if (status != null) updates['status'] = _statusToString(status);
      if (category != null) updates['category'] = _categoryToString(category);
      if (formData != null) updates['formData'] = formData;
      if (discussionStatus != null) updates['discussionStatus'] = discussionStatus;
      if (scheduledDateTime != null) updates['scheduledDateTime'] = scheduledDateTime.millisecondsSinceEpoch;
      if (additionalInfo != null) updates['additionalInfo'] = additionalInfo;
      if (isCompleted != null) updates['isCompleted'] = isCompleted;

      final success = await _firebaseService.updateClient(phoneNumber, updates);
      
      if (success) {
        debugPrint('✅ Client updated successfully: $phoneNumber');
      }

      return success;
    } catch (e) {
      debugPrint('❌ Error updating client: $e');
      return false;
    }
  }

  /// Sterge un client si toate datele asociate
  Future<bool> deleteClient(String phoneNumber) async {
    try {
      final success = await _firebaseService.deleteClient(phoneNumber);
      
      if (success) {
        // Notifica dashboard-ul
        _notifyClientDeleted();
      }

      return success;
    } catch (e) {
      debugPrint('❌ Error deleting client: $e');
      return false;
    }
  }

  // =================== FORM OPERATIONS ===================

  /// Salveaza datele formularului pentru un client
  Future<bool> saveClientForm({
    required String phoneNumber,
    required String formType, // 'loan' sau 'income'
    required Map<String, dynamic> formData,
  }) async {
    try {
      final success = await _firebaseService.saveClientForm(
        phoneNumber: phoneNumber,
        formId: formType,
        formData: formData,
      );

      if (success) {
        // Actualizeaza si datele clientului cu formData
        await updateClient(phoneNumber, formData: formData);
      }

      return success;
    } catch (e) {
      debugPrint('❌ Error saving client form: $e');
      return false;
    }
  }

  /// Obtine formularele pentru un client
  Future<List<Map<String, dynamic>>> getClientForms(String phoneNumber) async {
    try {
      return await _firebaseService.getClientForms(phoneNumber);
    } catch (e) {
      debugPrint('❌ Error getting client forms: $e');
      return [];
    }
  }

  // =================== MEETING OPERATIONS ===================

  /// Creeaza o intalnire pentru un client
  Future<bool> createMeeting({
    required String phoneNumber,
    required DateTime dateTime,
    required String meetingType, // 'meeting' sau 'bureauDelete'
    String? description,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final success = await _firebaseService.createMeeting(
        phoneNumber: phoneNumber,
        dateTime: dateTime,
        type: meetingType,
        description: description,
        additionalData: additionalData,
      );

      if (success) {
        // Notifica dashboard-ul
        await _notifyMeetingCreated();
      }

      return success;
    } catch (e) {
      debugPrint('❌ Error creating meeting: $e');
      return false;
    }
  }

  /// Obtine intalnirile pentru consultantul curent
  Future<List<Map<String, dynamic>>> getAllMeetings() async {
    try {
      return await _firebaseService.getAllMeetings();
    } catch (e) {
      debugPrint('❌ Error getting all meetings: $e');
      return [];
    }
  }

  /// Obtine intalnirile pentru echipa consultantului curent
  Future<List<Map<String, dynamic>>> getTeamMeetings() async {
    try {
      return await _firebaseService.getTeamMeetings();
    } catch (e) {
      debugPrint('❌ Error getting team meetings: $e');
      return [];
    }
  }

  // =================== HELPER METHODS ===================

  /// Converteste ClientStatus in string pentru Firebase
  String _statusToString(ClientStatus status) {
    switch (status) {
      case ClientStatus.focused:
        return 'focused';
      case ClientStatus.normal:
        return 'normal';
    }
  }

  /// Converteste ClientCategory in string pentru Firebase
  String _categoryToString(ClientCategory category) {
    switch (category) {
      case ClientCategory.reveniri:
        return 'reveniri';
      case ClientCategory.recente:
        return 'recente';
      case ClientCategory.apeluri:
        return 'apeluri';
    }
  }

  // =================== COMPATIBILITY METHODS ===================

  /// Pentru compatibilitate cu codul existent - creeaza un client simple
  Future<bool> saveClient(ClientModel client) async {
    return await createClient(
      phoneNumber: client.phoneNumber,
      name: client.name,
      coDebitorName: client.coDebitorName,
      phoneNumber2: client.phoneNumber2,
      status: client.status,
      category: client.category,
      formData: client.formData,
    );
  }



  /// Notifica dashboard-ul ca un client a fost creat
  void _notifyClientCreated() {
    try {
      // DashboardService nu are metoda onClientCreated, folosim onFormCompleted
      // În viitor, ar putea fi adăugată o metodă specifică
    } catch (e) {
      debugPrint('❌ Error notifying dashboard: $e');
    }
  }

  /// Notifica dashboard-ul ca un client a fost sters
  void _notifyClientDeleted() {
    try {
      // Client deleted notification
    } catch (e) {
      debugPrint('❌ Error notifying dashboard: $e');
    }
  }

  /// Notifica dashboard-ul ca o intalnire a fost creata
  Future<void> _notifyMeetingCreated() async {
    try {
      final consultantToken = await _firebaseService.getCurrentConsultantToken();
      if (consultantToken != null) {
        // Pentru moment, folosim token-ul ca identificator
        // În viitor, ar putea fi nevoie de o conversie token -> uid
        await dashboard.DashboardService().onMeetingCreated(consultantToken);
      }
    } catch (e) {
      debugPrint('❌ Error notifying meeting created: $e');
    }
  }




}

// =================== LEGACY COMPATIBILITY ===================

/// Pentru compatibilitate cu codul existent - aliasuri
typedef ClientsFirebaseService = ClientsService;

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

  Map<String, dynamic> toJson() => toFirestore();
}

/// Informatii de baza despre client
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
    this.address, String? cnp,
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

  Map<String, dynamic> toJson() => toMap();
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

  Map<String, dynamic> toJson() => toMap();
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

  Map<String, dynamic> toJson() => toMap();
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

  Map<String, dynamic> toJson() => toMap();
}

/// Activitati client
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
      'consultantName': additionalData?['consultantName'] ?? '',
      'clientName': additionalData?['clientName'] ?? '',
      'consultantToken': additionalData?['consultantToken'] ?? '',
      'phoneNumber': additionalData?['phoneNumber'] ?? '',
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

  Map<String, dynamic> toJson() => toMap();
}

/// Tipuri de activitati client
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

  Map<String, dynamic> toJson() => toMap();
}

/// Categorii client unificate
enum UnifiedClientCategory {
  apeluri,
  reveniri,
  recente,
}

/// Status discutie
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

  Map<String, dynamic> toJson() => toMap();
}

// =================== UI STATE MANAGEMENT SERVICE ===================

  /// Service pentru gestionarea starii clientilor in UI si sincronizarea datelor formularelor
class ClientUIService extends ChangeNotifier {
  static final ClientUIService _instance = ClientUIService._internal();
  factory ClientUIService() => _instance;
  ClientUIService._internal();

  // Timer pentru actualizarea automată
  Timer? _autoRefreshTimer;
  
  // Debouncing pentru evitarea apelurilor multiple rapide
  Timer? _loadDebounceTimer;
  bool _isLoading = false;
  DateTime? _lastLoadTime;
  static const int _cacheValidityMinutes = 2;
  
  // Lista tuturor clientilor
  List<ClientModel> _clients = [];
  
  // Clientul curent focusat (pentru care se afiseaza formularul)
  ClientModel? _focusedClient;
  
  // Client temporar pentru crearea in timp real
  ClientModel? _temporaryClient;
  
  // Firebase service pentru persistenta datelor
  final ClientsService _firebaseService = ClientsService();
  
  // Getters
  List<ClientModel> get clients => List.unmodifiable(_clients);
  ClientModel? get focusedClient => _focusedClient;
  ClientModel? get temporaryClient => _temporaryClient;
  
  /// Expune ClientsService pentru componente care au nevoie de el direct
  ClientsService get firebaseService => _firebaseService;
  
  /// Obtine clientii dintr-o anumita categorie
  List<ClientModel> getClientsByCategory(ClientCategory category) {
    return _clients.where((client) => client.category == category).toList();
  }
  
  /// Obtine clientii din categoria "Apeluri"
  List<ClientModel> get apeluri => getClientsByCategory(ClientCategory.apeluri);
  
  /// Obtine clientii din categoria "Reveniri"
  List<ClientModel> get reveniri => getClientsByCategory(ClientCategory.reveniri);
  
  /// Obtine clientii din categoria "Recente"
  List<ClientModel> get recente => getClientsByCategory(ClientCategory.recente);
  
  /// Obtine clientii inclusiv cel temporar pentru afisare
  List<ClientModel> get clientsWithTemporary {
    final allClients = List<ClientModel>.from(_clients);
    if (_temporaryClient != null) {
      allClients.add(_temporaryClient!);
    }
    return allClients;
  }
  
  /// Obtine clientii dintr-o anumita categorie inclusiv cel temporar
  List<ClientModel> getClientsByCategoryWithTemporary(ClientCategory category) {
    final categoryClients = _clients.where((client) => client.category == category).toList();
    if (_temporaryClient != null && _temporaryClient!.category == category) {
      categoryClients.add(_temporaryClient!);
    }
    return categoryClients;
  }
  
  /// Obtine clientii dintr-o anumita categorie fara cel temporar (pentru clients-pane)
  List<ClientModel> getClientsByCategoryWithoutTemporary(ClientCategory category) {
    return _clients.where((client) => client.category == category).toList();
  }
  
  /// Initializeaza serviciul si incarca clientii din Firebase pentru consultantul curent
  Future<void> initializeDemoData() async {
    try {
      // Verifica daca utilizatorul este autentificat
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Incarca clientii din Firebase pentru consultantul curent
        await loadClientsFromFirebase();
        // Pornește actualizarea automată
        _startAutoRefresh();
      } else {
        // Daca nu este autentificat, initializeaza cu lista goala
        _clients = [];
        _focusedClient = null;
      }
    } catch (e) {
      debugPrint('Error initializing client data: $e');
      // In caz de eroare, initializeaza cu lista goala
      _clients = [];
      _focusedClient = null;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Pornește actualizarea automată a clientilor din Firebase cu delay pentru evitarea apelurilor redundante
  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (_clients.isEmpty) return;
      loadClientsFromFirebase();
    });
  }

  /// Oprește actualizarea automată
  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
  
  /// FIX: Cleanup focus state when clients are loaded from cache
  void cleanupFocusStateFromCache(List<ClientModel> cachedClients) {
    debugPrint('🧹 CLIENT_UI_SERVICE: _cleanupFocusStateFromCache called with ${cachedClients.length} clients');
    
    // Replace the clients list with cached clients
    _clients = List.from(cachedClients);
    
    // Run the same cleanup logic
    _cleanupFocusStateOnStartup();
    
    debugPrint('🧹 CLIENT_UI_SERVICE: Cache cleanup completed');
  }

  /// FIX: Cleanup focus state on startup to ensure only one client is focused
  void _cleanupFocusStateOnStartup() {
    int focusedCount = 0;
    ClientModel? firstFocusedClient;
    
    // Count focused clients and find the first one
    for (int i = 0; i < _clients.length; i++) {
      if (_clients[i].status == ClientStatus.focused) {
        focusedCount++;
        firstFocusedClient ??= _clients[i];
      }
    }
    
    // If multiple clients are focused, keep only the first one
    if (focusedCount > 1) {
      for (int i = 0; i < _clients.length; i++) {
        if (_clients[i].status == ClientStatus.focused) {
          if (_clients[i].phoneNumber == firstFocusedClient?.phoneNumber) {
            // Keep this one focused
          } else {
            // Defocus this one
            _clients[i] = _clients[i].copyWith(status: ClientStatus.normal);
          }
        }
      }
      
      // Update focused client reference
      _focusedClient = firstFocusedClient;
      
      debugPrint('🧹 CLIENT_UI_SERVICE: Cleanup completed | Found: $focusedCount focused | Kept: ${firstFocusedClient?.phoneNumber}');
    } else if (focusedCount == 1) {
      // Only one client is focused, update reference
      _focusedClient = firstFocusedClient;
      debugPrint('🧹 CLIENT_UI_SERVICE: Single focused client: ${_focusedClient?.phoneNumber}');
    } else {
      // No focused clients, focus the first one if available
      if (_clients.isNotEmpty) {
        _clients[0] = _clients[0].copyWith(status: ClientStatus.focused);
        _focusedClient = _clients[0];
        debugPrint('🧹 CLIENT_UI_SERVICE: No focused clients, focusing first: ${_focusedClient?.phoneNumber}');
      } else {
        _focusedClient = null;
        debugPrint('🧹 CLIENT_UI_SERVICE: No clients available');
      }
    }
  }

  /// OPTIMIZAT: Incarca clientii din Firebase pentru consultantul curent cu caching și debouncing
  Future<void> loadClientsFromFirebase() async {
    // OPTIMIZARE: Verifică cache-ul mai întâi
    if (_lastLoadTime != null && 
        DateTime.now().difference(_lastLoadTime!).inMinutes < _cacheValidityMinutes &&
        _clients.isNotEmpty) {
      debugPrint('🚀 CLIENT_UI_SERVICE: Using cached clients (${_clients.length} clients)');
      return;
    }
    
    // Anulează request-ul anterior dacă există unul pending
    _loadDebounceTimer?.cancel();
    
    // Dacă deja se încarcă, nu mai face alt request
    if (_isLoading) return;
    
    // OPTIMIZARE: Debouncing redus de la 300ms la 150ms
    _loadDebounceTimer = Timer(const Duration(milliseconds: 150), () async {
      await _performLoadClients();
    });
  }

  /// OPTIMIZAT: Execută încărcarea efectivă a clienților cu caching
  Future<void> _performLoadClients() async {
    if (_isLoading) return;
    
    try {
      _isLoading = true;
      
      // Pastreaza clientul focusat curent pentru a nu pierde focus-ul din cauza auto-refresh-ului
      final currentFocusedPhoneNumber = _focusedClient?.phoneNumber;
      
      // OPTIMIZARE: Foloseste cache-ul din NewFirebaseService
      final newClients = await _firebaseService.getAllClients();
      
      // OPTIMIZARE: Verifică dacă datele s-au schimbat cu adevărat
      final hasChanged = _clients.length != newClients.length ||
          !_clients.every((client) => newClients.any((newClient) => 
              newClient.phoneNumber == client.phoneNumber &&
              newClient.name == client.name));
      
      if (hasChanged || _clients.isEmpty) {
        // Actualizeaza lista de clienti doar dacă s-au schimbat
        _clients = newClients;
        _lastLoadTime = DateTime.now();
        
        // FIX: Cleanup focus state on startup
        _cleanupFocusStateOnStartup();
        
        // Incearca sa pastreze clientul focusat daca inca exista
        if (currentFocusedPhoneNumber != null) {
          final stillExists = _clients.any((client) => client.phoneNumber == currentFocusedPhoneNumber);
          if (stillExists) {
            // Clientul focusat inca exista, pastreza focus-ul
            focusClient(currentFocusedPhoneNumber);
          } else {
            // Clientul focusat nu mai exista, focuseaza primul disponibil
            if (_clients.isNotEmpty) {
              _focusedClient = _clients.first;
              focusClient(_clients.first.phoneNumber);
            } else {
              _focusedClient = null;
            }
          }
        } else {
          // Nu avea client focusat, focuseaza primul daca exista
          if (_clients.isNotEmpty) {
            _focusedClient = _clients.first;
            focusClient(_clients.first.phoneNumber);
          } else {
            _focusedClient = null;
          }
        }
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      } else {
        debugPrint('🚀 CLIENT_UI_SERVICE: No changes detected, skipping UI update');
      }
    } catch (e) {
      debugPrint('❌ CLIENT_UI_SERVICE: Error loading clients from Firebase: $e');
    } finally {
      _isLoading = false;
    }
  }
  
  // OPTIMIZARE: Debouncing pentru focus client pentru a preveni UI freezing

  bool _isFocusingClient = false;

  /// Focusa un client specific
  void focusClient(String phoneNumber) {
    if (_isFocusingClient) return;
    
    _isFocusingClient = true;
    
    try {
      // Verifica daca clientul exista
      final clientIndex = _clients.indexWhere((c) => c.phoneNumber == phoneNumber);
      if (clientIndex != -1) {
        // Defocuseaza toti clientii
        for (int i = 0; i < _clients.length; i++) {
          if (_clients[i].status == ClientStatus.focused) {
            _clients[i] = _clients[i].copyWith(status: ClientStatus.normal);
          }
        }
        
        // Focusa clientul specificat
        _clients[clientIndex] = _clients[clientIndex].copyWith(status: ClientStatus.focused);
        _focusedClient = _clients[clientIndex];
        
        // Notifica listenerii
        notifyListeners();
      }
    } finally {
      _isFocusingClient = false;
    }
  }

  /// Defocuseaza un client specific
  void defocusClient(String phoneNumber) {
    final clientIndex = _clients.indexWhere((c) => c.phoneNumber == phoneNumber);
    if (clientIndex != -1) {
      _clients[clientIndex] = _clients[clientIndex].copyWith(status: ClientStatus.normal);
      if (_focusedClient?.phoneNumber == phoneNumber) {
        _focusedClient = null;
      }
      notifyListeners();
    }
  }

  /// Asigura ca doar un client este focusat
  void _ensureSingleFocus() {
    final focusedClients = _clients.where((c) => c.status == ClientStatus.focused).toList();
    
    if (focusedClients.length > 1) {
      // Daca sunt mai multi clienti focusati, pastreaza doar primul
      for (int i = 1; i < focusedClients.length; i++) {
        final clientIndex = _clients.indexWhere((c) => c.phoneNumber == focusedClients[i].phoneNumber);
        if (clientIndex != -1) {
          _clients[clientIndex] = _clients[clientIndex].copyWith(status: ClientStatus.normal);
        }
      }
      _focusedClient = focusedClients.first;
      notifyListeners();
    } else if (focusedClients.length == 1) {
      _focusedClient = focusedClients.first;
    } else {
      _focusedClient = null;
    }
  }


  
  /// Creeaza un client temporar pentru crearea in timp real
  void createTemporaryClient() {
    debugPrint('🆕 CLIENT: Creating temporary client');
    
    // FIX: Defocuseaza TOȚI clienții înainte de a crea clientul temporar
    for (int i = 0; i < _clients.length; i++) {
      if (_clients[i].status == ClientStatus.focused) {
        _clients[i] = _clients[i].copyWith(status: ClientStatus.normal);
        debugPrint('🔚 CLIENT_UI_SERVICE: Defocused client: ${_clients[i].phoneNumber}');
      }
    }
    
    // Creeaza un client temporar cu ID unic
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    _temporaryClient = ClientModel(
      id: tempId,
      name: 'Client nou',
      phoneNumber1: '', // Empty phone number initially
      status: ClientStatus.focused,
      category: ClientCategory.apeluri,
      formData: {},
    );
    
    // Focuseaza clientul temporar
    _focusedClient = _temporaryClient;
    
    debugPrint('✅ CLIENT: Temporary client created');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureSingleFocus(); // FIX: Asigură consistența focus-ului
      notifyListeners();
    });
  }
  
  /// Actualizeaza clientul temporar cu datele introduse
  void updateTemporaryClient({
    String? name,
    String? phoneNumber,
    String? phoneNumber2,
    String? coDebitorName,
  }) {
    if (_temporaryClient == null) return;
    
    // Only update name if user actually typed something (not empty)
    final newName = name?.trim();
    final shouldUpdateName = newName != null && newName.isNotEmpty;
    
    _temporaryClient = _temporaryClient!.copyWith(
      name: shouldUpdateName ? newName : _temporaryClient!.name,
      phoneNumber1: phoneNumber?.trim() ?? _temporaryClient!.phoneNumber1,
      phoneNumber2: phoneNumber2?.trim().isEmpty == true ? null : phoneNumber2?.trim(),
      coDebitorName: coDebitorName?.trim().isEmpty == true ? null : coDebitorName?.trim(),
    );
    
    // Update focused client if it's the same
    if (_focusedClient?.id == _temporaryClient!.id) {
      _focusedClient = _temporaryClient;
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
  
  /// Finalizeaza clientul temporar si il salveaza in Firebase
  Future<bool> finalizeTemporaryClient() async {
    if (_temporaryClient == null) return false;
    
    try {
      // Valideaza datele
      if (_temporaryClient!.name.trim().isEmpty || 
          _temporaryClient!.phoneNumber1.trim().isEmpty) {
        debugPrint('❌ CLIENT: Invalid temporary client data');
        return false;
      }
      
      // Creeaza clientul real in Firebase
      final success = await _firebaseService.createClient(
        phoneNumber: _temporaryClient!.phoneNumber1.trim(),
        name: _temporaryClient!.name.trim(),
        coDebitorName: _temporaryClient!.coDebitorName,
        phoneNumber2: _temporaryClient!.phoneNumber2,
        status: _temporaryClient!.status,
        category: _temporaryClient!.category,
        formData: _temporaryClient!.formData,
      );
      
      if (success) {
        // FIX: Defocuseaza TOȚI clienții înainte de a adăuga noul client
        for (int i = 0; i < _clients.length; i++) {
          if (_clients[i].status == ClientStatus.focused) {
            _clients[i] = _clients[i].copyWith(status: ClientStatus.normal);
            debugPrint('🔚 CLIENT_UI_SERVICE: Defocused client: ${_clients[i].phoneNumber}');
          }
        }
        
        // Adauga in lista locala
        final realClient = _temporaryClient!.copyWith(
          id: _temporaryClient!.phoneNumber1.trim(),
          status: ClientStatus.focused, // Focuseaza noul client real
        );
        _clients.add(realClient);
        
        // Focuseaza clientul real
        _focusedClient = realClient;
        _temporaryClient = null;
        
        debugPrint('✅ CLIENT: Temporary client finalized');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return true;
      } else {
        debugPrint('❌ CLIENT: Failed to save temporary client');
        return false;
      }
    } catch (e) {
      debugPrint('❌ CLIENT: Error finalizing temporary client: $e');
      return false;
    }
  }
  
  /// Anuleaza clientul temporar
  void cancelTemporaryClient() {
    if (_temporaryClient == null) return;
    
    debugPrint('❌ CLIENT: Canceling temporary client');
    
    // FIX: Defocuseaza TOȚI clienții înainte de a anula clientul temporar
    for (int i = 0; i < _clients.length; i++) {
      if (_clients[i].status == ClientStatus.focused) {
        _clients[i] = _clients[i].copyWith(status: ClientStatus.normal);
        debugPrint('🔚 CLIENT_UI_SERVICE: Defocused client: ${_clients[i].phoneNumber}');
      }
    }
    
    // Focuseaza primul client real daca exista
    if (_clients.isNotEmpty) {
      _focusedClient = _clients.first;
      // FIX: Nu apele focusClient pentru a evita recursiunea
      _clients[0] = _clients[0].copyWith(status: ClientStatus.focused);
    } else {
      _focusedClient = null;
    }
    
    _temporaryClient = null;
    
    // FIX: Notificare simplă fără cache refresh pentru a evita infinite loop
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureSingleFocus();
      notifyListeners();
    });
  }
  
  /// Actualizeaza datele formularului pentru clientul focusat
  void updateFocusedClientFormData(String key, dynamic value) {
    if (_focusedClient != null) {
      _focusedClient!.updateFormData(key, value);
      
      // Actualizeaza si in lista principala
      final clientIndex = _clients.indexWhere((client) => client.phoneNumber == _focusedClient!.phoneNumber);
      if (clientIndex != -1) {
        _clients[clientIndex] = _focusedClient!;
      }
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
  
  /// Actualizeaza datele formularului pentru clientul focusat fara notificare
  void updateFocusedClientFormDataSilent(String key, dynamic value) {
    if (_focusedClient != null) {
      _focusedClient!.updateFormData(key, value);
      
      // Actualizeaza si in lista principala
      final clientIndex = _clients.indexWhere((client) => client.phoneNumber == _focusedClient!.phoneNumber);
      if (clientIndex != -1) {
        _clients[clientIndex] = _focusedClient!;
      }
    }
  }
  
  /// Obtine o valoare din formularul clientului focusat
  T? getFocusedClientFormValue<T>(String key) {
    return _focusedClient?.getFormValue<T>(key);
  }
  
  /// Adauga un client nou si il salveaza in Firebase
  /// Foloseste numarul de telefon ca ID unic
  Future<void> addClient(ClientModel client) async {
    try {
      // Creeaza un client cu phoneNumber ca ID
      final clientWithPhoneId = client.copyWith(id: client.phoneNumber);
      
      // Salveaza in Firebase folosind noua structura
      final success = await _firebaseService.createClient(
        phoneNumber: clientWithPhoneId.phoneNumber,
        name: clientWithPhoneId.name,
        coDebitorName: clientWithPhoneId.coDebitorName,
        status: clientWithPhoneId.status,
        category: clientWithPhoneId.category,
        formData: clientWithPhoneId.formData,
      );
      
      if (success) {
        // Adauga in lista locala
        _clients.add(clientWithPhoneId);
        
        // Focuseaza primul client daca este primul client adaugat
        if (_clients.length == 1) {
          _focusedClient = _clients.first;
          focusClient(_clients.first.phoneNumber);
        }
        
        // FIX: Invalideaza cache-ul din SplashService pentru sincronizare UI
        final splashService = SplashService();
        await splashService.invalidateClientsCacheAndRefresh();
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    } catch (e) {
      debugPrint('Error adding client: $e');
      // Poti adauga aici o notificare de eroare pentru utilizator
    }
  }
  
  /// Sterge un client si il elimina din Firebase
  /// Foloseste phoneNumber pentru identificare
  Future<void> removeClient(String clientPhoneNumber) async {
    try {
      // 1. Remove from backend first
      final success = await _firebaseService.deleteClient(clientPhoneNumber);

      if (success) {
        // 2. Remove from local list
        _clients.removeWhere((client) => client.phoneNumber == clientPhoneNumber);

        // 3. Update focus if needed
        if (_focusedClient?.phoneNumber == clientPhoneNumber) {
          _focusedClient = _clients.isNotEmpty ? _clients.first : null;
          if (_focusedClient != null) {
            _clients[0] = _clients[0].copyWith(status: ClientStatus.focused);
          }
        }

        // 4. Invalidate and refresh cache
        final splashService = SplashService();
        await splashService.invalidateClientsCacheAndRefresh();

        // 5. Notify listeners
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _ensureSingleFocus();
          notifyListeners();
        });
      } else {
        debugPrint('❌ Failed to delete client from Firebase: $clientPhoneNumber');
        // Optionally: show error to user
      }
    } catch (e) {
      debugPrint('Error removing client: $e');
      // Optionally: show error to user
    }
  }

  /// Sterge mai multi clienti dintr-o data (batch delete, atomic UI update)
  Future<void> removeClients(List<String> clientPhoneNumbers) async {
    try {
      // 1. Remove from backend first (in parallel)
      final results = await Future.wait(
        clientPhoneNumbers.map((phone) => _firebaseService.deleteClient(phone))
      );

      // 2. Only proceed if all succeeded
      if (results.every((r) => r)) {
        // 3. Remove from local list
        _clients.removeWhere((client) => clientPhoneNumbers.contains(client.phoneNumber));

        // 4. Update focus if needed
        if (_focusedClient != null && clientPhoneNumbers.contains(_focusedClient!.phoneNumber)) {
          _focusedClient = _clients.isNotEmpty ? _clients.first : null;
          if (_focusedClient != null) {
            _clients[0] = _clients[0].copyWith(status: ClientStatus.focused);
          }
        }

        // 5. Invalidate and refresh cache
        final splashService = SplashService();
        await splashService.invalidateClientsCacheAndRefresh();

        // 6. Notify listeners
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _ensureSingleFocus();
          notifyListeners();
        });
      } else {
        debugPrint('❌ Failed to delete one or more clients from Firebase');
        // Optionally: show error to user
      }
    } catch (e) {
      debugPrint('Error removing clients: $e');
      // Optionally: show error to user
    }
  }
  
  /// Actualizeaza un client existent si il salveaza in Firebase
  Future<void> updateClient(ClientModel updatedClient) async {
    try {
      // Asigura-te ca ID-ul este phoneNumber
      final clientWithPhoneId = updatedClient.copyWith(id: updatedClient.phoneNumber);
      
      // Actualizeaza in Firebase folosind noua structura
      final success = await _firebaseService.updateClient(
        clientWithPhoneId.phoneNumber,
        name: clientWithPhoneId.name,
        coDebitorName: clientWithPhoneId.coDebitorName,
        status: clientWithPhoneId.status,
        category: clientWithPhoneId.category,
        formData: clientWithPhoneId.formData,
        discussionStatus: clientWithPhoneId.discussionStatus,
        scheduledDateTime: clientWithPhoneId.scheduledDateTime,
        additionalInfo: clientWithPhoneId.additionalInfo,
        isCompleted: clientWithPhoneId.isCompleted,
      );
      
      if (success) {
        // Actualizeaza in lista locala
        final clientIndex = _clients.indexWhere((client) => client.phoneNumber == updatedClient.phoneNumber);
        if (clientIndex != -1) {
          _clients[clientIndex] = clientWithPhoneId;
          
          // Daca clientul actualizat este cel focusat, actualizeaza si referinta
          if (_focusedClient?.phoneNumber == updatedClient.phoneNumber) {
            _focusedClient = clientWithPhoneId;
          }
          
          // FIX: Invalideaza cache-ul din SplashService pentru sincronizare UI
          final splashService = SplashService();
          await splashService.invalidateClientsCacheAndRefresh();
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        }
      }
    } catch (e) {
      debugPrint('Error updating client: $e');
    }
  }
  
  /// Muta un client in categoria "Recente" cu statusul "Acceptat"
  Future<void> moveClientToRecente(String clientPhoneNumber, {
    String? additionalInfo,
    DateTime? scheduledDateTime,
  }) async {
    final clientIndex = _clients.indexWhere((client) => client.phoneNumber == clientPhoneNumber);
    if (clientIndex != -1) {
      final client = _clients[clientIndex];
      
      // Notifica DashboardService doar daca formularul nu a fost deja contorizat
      if (!client.isCompleted) {
        final firebaseService = NewFirebaseService();
        final consultantToken = await firebaseService.getCurrentConsultantToken();
        if (consultantToken != null) {
          final dashboardService = dashboard.DashboardService();
          await dashboardService.onFormCompleted(consultantToken);
          dashboardService.refreshData();
        }
      }

      final updatedClient = client.copyWith(
        category: ClientCategory.recente,
        status: ClientStatus.normal, // Nu mai este focusat
        discussionStatus: 'Acceptat',
        scheduledDateTime: scheduledDateTime, // IMPORTANT: Salvează data și ora întâlnirii
        additionalInfo: additionalInfo,
        isCompleted: true, // Marcheaza ca si contorizat
      );
      
      await updateClient(updatedClient);
      
      // Daca clientul mutat era focusat, focuseaza primul client disponibil din "Apeluri"
      if (_focusedClient?.phoneNumber == clientPhoneNumber) {
        final apeluri = getClientsByCategory(ClientCategory.apeluri);
        if (apeluri.isNotEmpty) {
          focusClient(apeluri.first.phoneNumber);
        } else {
          _focusedClient = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        }
      }
      
      // FIX: Invalideaza cache-ul din SplashService pentru sincronizare UI
      final splashService = SplashService();
      await splashService.invalidateClientsCacheAndRefresh();
      
      debugPrint('✅ Client mutat in Recente (Acceptat): ${updatedClient.name}');
    }
  }

  /// Muta un client in categoria "Reveniri" cu statusul "Amanat"
  Future<void> moveClientToReveniri(String clientPhoneNumber, {
    required DateTime scheduledDateTime,
    String? additionalInfo,
  }) async {
    final clientIndex = _clients.indexWhere((client) => client.phoneNumber == clientPhoneNumber);
    if (clientIndex != -1) {
      final client = _clients[clientIndex];

      // Notifica DashboardService doar daca formularul nu a fost deja contorizat
      if (!client.isCompleted) {
        final firebaseService = NewFirebaseService();
        final consultantToken = await firebaseService.getCurrentConsultantToken();
        if (consultantToken != null) {
          final dashboardService = dashboard.DashboardService();
          await dashboardService.onFormCompleted(consultantToken);
          dashboardService.refreshData();
        }
      }

      final updatedClient = client.copyWith(
        category: ClientCategory.reveniri,
        status: ClientStatus.normal, // Nu mai este focusat
        discussionStatus: 'Amanat',
        scheduledDateTime: scheduledDateTime,
        additionalInfo: additionalInfo,
        isCompleted: true, // Marcheaza ca si contorizat
      );
      
      await updateClient(updatedClient);
      
      // Daca clientul mutat era focusat, focuseaza primul client disponibil din "Apeluri"
      if (_focusedClient?.phoneNumber == clientPhoneNumber) {
        final apeluri = getClientsByCategory(ClientCategory.apeluri);
        if (apeluri.isNotEmpty) {
          focusClient(apeluri.first.phoneNumber);
        } else {
          _focusedClient = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        }
      }
      
      // FIX: Invalideaza cache-ul din SplashService pentru sincronizare UI
      final splashService = SplashService();
      await splashService.invalidateClientsCacheAndRefresh();
      
      debugPrint('✅ Client mutat in Reveniri (Amanat): ${updatedClient.name}');
    }
  }

  /// Muta un client in categoria "Recente" cu statusul "Refuzat"
  Future<void> moveClientToRecenteRefuzat(String clientPhoneNumber, {
    String? additionalInfo,
  }) async {
    final clientIndex = _clients.indexWhere((client) => client.phoneNumber == clientPhoneNumber);
    if (clientIndex != -1) {
      final client = _clients[clientIndex];

      // Notifica DashboardService doar daca formularul nu a fost deja contorizat
      if (!client.isCompleted) {
        final firebaseService = NewFirebaseService();
        final consultantToken = await firebaseService.getCurrentConsultantToken();
        if (consultantToken != null) {
          final dashboardService = dashboard.DashboardService();
          await dashboardService.onFormCompleted(consultantToken);
          dashboardService.refreshData();
        }
      }

      final updatedClient = client.copyWith(
        category: ClientCategory.recente,
        status: ClientStatus.normal, // Nu mai este focusat
        discussionStatus: 'Refuzat',
        additionalInfo: additionalInfo,
        isCompleted: true, // Marcheaza ca si contorizat
      );
      
      await updateClient(updatedClient);
      
      // Daca clientul mutat era focusat, focuseaza primul client disponibil din "Apeluri"
      if (_focusedClient?.phoneNumber == clientPhoneNumber) {
        final apeluri = getClientsByCategory(ClientCategory.apeluri);
        if (apeluri.isNotEmpty) {
          focusClient(apeluri.first.phoneNumber);
        } else {
          _focusedClient = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        }
      }
      
      // FIX: Invalideaza cache-ul din SplashService pentru sincronizare UI
      final splashService = SplashService();
      await splashService.invalidateClientsCacheAndRefresh();
      
      debugPrint('✅ Client mutat in Recente (Refuzat): ${updatedClient.name}');
    }
  }

  /// Sterge toti clientii pentru consultantul curent
  Future<void> deleteAllClients() async {
    try {
      // Obtine toti clientii pentru consultantul curent
      final allClients = await _firebaseService.getAllClients();
      
      // Sterge fiecare client individual
      for (final client in allClients) {
        await _firebaseService.deleteClient(client.phoneNumber);
      }
      
      // Curata lista locala
      _clients.clear();
      _focusedClient = null;
      
      // FIX: Invalideaza cache-ul din SplashService pentru sincronizare UI
      final splashService = SplashService();
      await splashService.invalidateClientsCacheAndRefresh();
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      debugPrint('✅ All clients deleted for current consultant');
    } catch (e) {
      debugPrint('❌ Error deleting all clients: $e');
    }
  }

  /// FIX: Resetează serviciul pentru un consultant nou (separarea datelor per consultant)
  Future<void> resetForNewConsultant() async {
    try {
      // Oprește actualizarea automată
      _stopAutoRefresh();
      
      // Șterge cache-ul local
      _clients.clear();
      _focusedClient = null;
      
      // Încarcă datele pentru noul consultant (fără auto-refresh pentru a evita apelurile multiple)
      await loadClientsFromFirebase();
      
      // Pornește auto-refresh cu delay pentru a evita conflictele
      Timer(const Duration(seconds: 5), () {
        _startAutoRefresh();
      });
      
    } catch (e) {
      debugPrint('❌ CLIENT_UI_SERVICE: Error resetting for new consultant: $e');
    }
  }

}

// =================== BACKWARD COMPATIBILITY ALIAS ===================

/// Alias pentru compatibilitate cu codul existent
/// @deprecated Foloseste ClientUIService() in schimb
@Deprecated('Use ClientUIService() instead')
typedef ClientService = ClientUIService;
