import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/unified_client_model.dart';
import 'consultantService.dart';

/// Serviciu unificat pentru gestionarea bazei de date conform structurii:
/// consultants/{token}/clients/{phoneNumber}/form/{loan|income} și meetings/{meetingId}
class UnifiedClientService {
  static final UnifiedClientService _instance = UnifiedClientService._internal();
  factory UnifiedClientService() => _instance;
  UnifiedClientService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ConsultantService _consultantService = ConsultantService();
  
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
    ClientStatus? status,
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
        'currentStatus': (status ?? ClientStatus(
          category: ClientCategory.apeluri,
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
          phoneNumber: clientData['phoneNumber'] ?? phoneNumber,
          coDebitorName: clientData['coDebitorName'],
          coDebitorPhone: clientData['coDebitorPhone'],
          email: clientData['email'],
          address: clientData['address'],
        ),
        formData: formData,
        activities: activities,
        currentStatus: ClientStatus.fromMap(clientData['currentStatus'] ?? {}),
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
    if (collection == null) return [];

    try {
      final snapshot = await collection
          .orderBy('metadata.updatedAt', descending: true)
          .get();
      
      final List<UnifiedClientModel> clients = [];
      for (final doc in snapshot.docs) {
        final client = await getClient(doc.id);
        if (client != null) {
          clients.add(client);
        }
      }
      
      return clients;
    } catch (e) {
      debugPrint('❌ Error getting all clients: $e');
      return [];
    }
  }

  /// Obține clienții dintr-o anumită categorie pentru consultantul curent
  Future<List<UnifiedClientModel>> getClientsByCategory(ClientCategory category) async {
    final collection = _clientsCollection;
    if (collection == null) return [];

    try {
      final snapshot = await collection
          .where('currentStatus.category', isEqualTo: category.name)
          .orderBy('metadata.updatedAt', descending: true)
          .get();
      
      final List<UnifiedClientModel> clients = [];
      for (final doc in snapshot.docs) {
        final client = await getClient(doc.id);
        if (client != null) {
          clients.add(client);
        }
      }
      
      return clients;
    } catch (e) {
      debugPrint('❌ Error getting clients by category: $e');
      return [];
    }
  }

  /// Actualizează informațiile de bază ale unui client
  Future<bool> updateClient(String phoneNumber, {
    String? name,
    String? coDebitorName,
    String? coDebitorPhone,
    String? email,
    String? address,
    ClientStatus? currentStatus,
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

  // =================== OPERAȚII FORMULAR ===================

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

  /// Adaugă un credit nou pentru client
  Future<bool> addCreditToClient(String phoneNumber, CreditData credit, {bool isClient = true}) async {
    try {
      final client = await getClient(phoneNumber);
      if (client == null) return false;

      final currentFormData = client.formData;
      final updatedCredits = isClient
          ? [...currentFormData.clientCredits, credit]
          : [...currentFormData.coDebitorCredits, credit];

      return await saveLoanData(
        phoneNumber,
        clientCredits: isClient ? updatedCredits : currentFormData.clientCredits,
        coDebitorCredits: isClient ? currentFormData.coDebitorCredits : updatedCredits,
        additionalData: currentFormData.additionalData,
      );
    } catch (e) {
      debugPrint('❌ Error adding credit: $e');
      return false;
    }
  }

  /// Adaugă un venit nou pentru client
  Future<bool> addIncomeToClient(String phoneNumber, IncomeData income, {bool isClient = true}) async {
    try {
      final client = await getClient(phoneNumber);
      if (client == null) return false;

      final currentFormData = client.formData;
      final updatedIncomes = isClient
          ? [...currentFormData.clientIncomes, income]
          : [...currentFormData.coDebitorIncomes, income];

      return await saveIncomeData(
        phoneNumber,
        clientIncomes: isClient ? updatedIncomes : currentFormData.clientIncomes,
        coDebitorIncomes: isClient ? currentFormData.coDebitorIncomes : updatedIncomes,
        additionalData: currentFormData.additionalData,
      );
    } catch (e) {
      debugPrint('❌ Error adding income: $e');
      return false;
    }
  }

  // =================== OPERAȚII MEETINGS ===================

  /// Programează o întâlnire pentru un client
  Future<bool> scheduleMeeting(String phoneNumber, DateTime dateTime, {
    String? description,
    String? type,
    Map<String, dynamic>? additionalData,
  }) async {
    // Verifică dacă slotul este disponibil
    final isAvailable = await isTimeSlotAvailable(dateTime, excludePhoneNumber: phoneNumber);
    if (!isAvailable) {
      debugPrint('❌ Time slot not available: $dateTime');
      return false;
    }

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

  /// Actualizează o întâlnire existentă
  Future<bool> updateMeeting(String phoneNumber, String meetingId, DateTime newDateTime, {
    String? description,
    String? type,
    Map<String, dynamic>? additionalData,
  }) async {
    // Verifică dacă noul slot este disponibil
    final isAvailable = await isTimeSlotAvailable(newDateTime, excludePhoneNumber: phoneNumber);
    if (!isAvailable) {
      debugPrint('❌ New time slot not available: $newDateTime');
      return false;
    }

    final meetingsCollection = _getMeetingsCollection(phoneNumber);
    if (meetingsCollection == null) return false;

    try {
      // Obține numele clientului pentru a-l include în additionalData
      final client = await getClient(phoneNumber);
      final clientName = client?.basicInfo.name ?? 'Client necunoscut';
      
      final updateData = <String, dynamic>{
        'dateTime': Timestamp.fromDate(newDateTime),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (description != null) updateData['description'] = description;
      if (type != null) updateData['type'] = type;
      
      // Combină additionalData cu informațiile esențiale
      if (additionalData != null) {
        final combinedAdditionalData = <String, dynamic>{
          'phoneNumber': phoneNumber,
          'clientName': clientName,
          ...additionalData,
        };
        updateData['additionalData'] = combinedAdditionalData;
      } else {
        // Păstrează informațiile esențiale chiar dacă nu sunt furnizate additionalData noi
        updateData['additionalData.phoneNumber'] = phoneNumber;
        updateData['additionalData.clientName'] = clientName;
      }

      await meetingsCollection.doc(meetingId).update(updateData);

      // Actualizează timestamp-ul clientului
      await _updateClientTimestamp(phoneNumber);
      
      debugPrint('✅ Meeting updated successfully: $meetingId for client: $phoneNumber ($clientName)');
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
      
      debugPrint('✅ Meeting deleted successfully: $meetingId');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting meeting: $e');
      return false;
    }
  }

  // =================== OPERAȚII STATUS ===================

  /// Schimbă categoria unui client
  Future<bool> updateClientCategory(String phoneNumber, ClientCategory category, {
    ClientDiscussionStatus? discussionStatus,
    DateTime? scheduledDateTime,
    String? additionalInfo,
  }) async {
    try {
      final updatedStatus = ClientStatus(
        category: category,
        discussionStatus: discussionStatus,
        scheduledDateTime: scheduledDateTime,
        additionalInfo: additionalInfo,
        isFocused: false, // Reset focus when changing category
      );

      // Dacă este acceptat, programează întâlnirea
      if (discussionStatus == ClientDiscussionStatus.acceptat && scheduledDateTime != null) {
        await scheduleMeeting(phoneNumber, scheduledDateTime, 
            description: 'Întâlnire pentru client acceptat');
      }

      return await updateClient(phoneNumber, currentStatus: updatedStatus);
    } catch (e) {
      debugPrint('❌ Error updating client category: $e');
      return false;
    }
  }

  /// Focusează/defocusează un client (pentru UI)
  Future<bool> toggleClientFocus(String phoneNumber, bool isFocused) async {
    try {
      final client = await getClient(phoneNumber);
      if (client == null) return false;

      final updatedStatus = ClientStatus(
        category: client.currentStatus.category,
        discussionStatus: client.currentStatus.discussionStatus,
        scheduledDateTime: client.currentStatus.scheduledDateTime,
        additionalInfo: client.currentStatus.additionalInfo,
        isFocused: isFocused,
      );

      return await updateClient(phoneNumber, currentStatus: updatedStatus);
    } catch (e) {
      debugPrint('❌ Error toggling client focus: $e');
      return false;
    }
  }

  // =================== OPERAȚII CALENDAR ===================

  /// Verifică dacă un slot de timp este disponibil pentru consultantul curent
  Future<bool> isTimeSlotAvailable(DateTime dateTime, {String? excludePhoneNumber}) async {
    final collection = _clientsCollection;
    if (collection == null) return false;

    try {
      final startOfSlot = DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour, dateTime.minute);
      final endOfSlot = startOfSlot.add(const Duration(minutes: 30));

      final clientsSnapshot = await collection.get();
      
      for (final clientDoc in clientsSnapshot.docs) {
        // Exclude clientul curent dacă este specificat
        if (excludePhoneNumber != null && clientDoc.id == excludePhoneNumber) continue;
        
        // Verifică meetings-urile acestui client
        final meetingsSnapshot = await clientDoc.reference
            .collection(_meetingsSubcollection)
            .get();
        
        for (final meetingDoc in meetingsSnapshot.docs) {
          final meetingData = meetingDoc.data();
          final meetingStart = (meetingData['dateTime'] as Timestamp).toDate();
          final meetingEnd = meetingStart.add(const Duration(minutes: 30));
          
          // Verifică suprapunerea
          if ((startOfSlot.isBefore(meetingEnd) && endOfSlot.isAfter(meetingStart))) {
            return false;
          }
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('❌ Error checking time slot availability: $e');
      return false;
    }
  }

  /// Obține toate întâlnirile din calendar pentru consultantul curent
  Future<List<ClientActivity>> getAllMeetings() async {
    final collection = _clientsCollection;
    if (collection == null) return [];

    try {
      final clientsSnapshot = await collection.get();
      final List<ClientActivity> allMeetings = [];
      
      for (final clientDoc in clientsSnapshot.docs) {
        final clientData = clientDoc.data();
        final clientName = clientData['name'] ?? 'Client necunoscut';
        
        final meetingsSnapshot = await clientDoc.reference
            .collection(_meetingsSubcollection)
            .get();
        
        for (final meetingDoc in meetingsSnapshot.docs) {
          final data = meetingDoc.data();
          final activity = ClientActivity(
            id: meetingDoc.id,
            type: data['type'] == 'bureauDelete' 
                ? ClientActivityType.bureauDelete 
                : ClientActivityType.meeting,
            dateTime: (data['dateTime'] as Timestamp).toDate(),
            description: data['description'] ?? 'Întâlnire',
            additionalData: {
              ...Map<String, dynamic>.from(data['additionalData'] ?? {}),
              'phoneNumber': clientDoc.id,
              'clientName': clientName,
            },
            createdAt: data['createdAt'] != null 
                ? (data['createdAt'] as Timestamp).toDate()
                : DateTime.now(),
            updatedAt: data['updatedAt'] != null 
                ? (data['updatedAt'] as Timestamp).toDate()
                : null,
          );
          allMeetings.add(activity);
        }
      }
      
      // Sortează după dată
      allMeetings.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return allMeetings;
    } catch (e) {
      debugPrint('❌ Error getting all meetings: $e');
      return [];
    }
  }

  // =================== STREAMING ===================

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

  /// Stream pentru clienții dintr-o categorie pentru consultantul curent
  Stream<List<UnifiedClientModel>> getClientsByCategoryStream(ClientCategory category) {
    final collection = _clientsCollection;
    if (collection == null) {
      return Stream.value([]);
    }

    return collection
        .where('currentStatus.category', isEqualTo: category.name)
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

  /// Actualizează timestamp-ul clientului
  Future<void> _updateClientTimestamp(String phoneNumber) async {
    try {
      await updateClient(phoneNumber);
    } catch (e) {
      debugPrint('❌ Error updating client timestamp: $e');
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

  // =================== MIGRAȚIE ===================

  /// Migrează toate datele din structura veche în cea nouă
  /// Această metodă poate fi apelată din aplicație pentru a migra datele
  Future<bool> migrateAllDataToNewStructure() async {
    final user = _currentUser;
    if (user == null) {
      debugPrint('❌ User not authenticated for migration');
      return false;
    }

    try {
      debugPrint('🔄 Starting migration to new unified structure...');
      
      // Migrează datele din colecția globală 'forms'
      await _migrateGlobalFormsData(user.uid);
      
      // Migrează datele din colecția globală 'meetings'
      await _migrateGlobalMeetingsData(user.uid);
      
      debugPrint('✅ Migration completed successfully!');
      return true;
    } catch (e) {
      debugPrint('❌ Error during migration: $e');
      return false;
    }
  }

  /// Migrează datele din colecția globală 'forms'
  Future<void> _migrateGlobalFormsData(String consultantId) async {
    try {
      // În loc să migreze toate formularele globale, verifică dacă există deja clienți
      // pentru consultantul curent și nu migra datele globale care nu îi aparțin
      
      debugPrint('🔄 Checking existing clients for consultant: $consultantId');
      final existingClients = await getAllClients();
      
      if (existingClients.isNotEmpty) {
        debugPrint('⚠️ Consultant already has ${existingClients.length} clients. Skipping global forms migration to avoid data pollution.');
        return;
      }
      
      // Doar dacă consultantul nu are clienți, întreabă utilizatorul dacă vrea să migreze
      debugPrint('ℹ️ No existing clients found. Migration would need user confirmation for global forms.');
      
      // Pentru siguranță, nu migrăm automat datele globale
      // Acestea ar trebui migrate manual sau cu confirmarea utilizatorului
      
    } catch (e) {
      debugPrint('❌ Error checking existing clients for migration: $e');
    }
  }

  /// Migrează datele din colecția globală 'meetings'
  Future<void> _migrateGlobalMeetingsData(String consultantId) async {
    try {
      // Migrează doar meetings-urile care aparțin consultantului curent
      final meetingsSnapshot = await _firestore
          .collection('meetings')
          .where('consultantId', isEqualTo: consultantId)
          .get();
      
      debugPrint('🔄 Found ${meetingsSnapshot.docs.length} meetings to migrate for consultant: $consultantId');
      
      for (final meetingDoc in meetingsSnapshot.docs) {
        final meetingData = meetingDoc.data();
        final phoneNumber = meetingData['phoneNumber'];
        final clientName = meetingData['clientName'];
        
        if (phoneNumber == null || phoneNumber.isEmpty) {
          debugPrint('⚠️ Skipping meeting ${meetingDoc.id} - no phone number');
          continue;
        }
        
        // Verifică dacă clientul există în noua structură
        final client = await getClient(phoneNumber);
        
        if (client == null) {
          // Creează client nou
          await createClient(
            phoneNumber: phoneNumber,
            name: clientName ?? 'Client din întâlnire',
            source: 'migration_meetings',
          );
        }
        
        // Migrează meeting-ul în subcollection
        final meetingsCollection = _getMeetingsCollection(phoneNumber);
        if (meetingsCollection != null) {
          await meetingsCollection.doc(meetingDoc.id).set({
            'type': meetingData['type'] ?? 'meeting',
            'dateTime': meetingData['dateTime'],
            'description': meetingData['type'] == 'bureauDelete' 
                ? 'Ștergere birou credit' 
                : 'Întâlnire programată',
            'additionalData': {
              'phoneNumber': phoneNumber,
              'clientName': clientName ?? 'Client din întâlnire',
              'consultantId': consultantId,
              'consultantName': meetingData['consultantName'] ?? 'Consultant',
            },
            'createdAt': meetingData['createdAt'] ?? FieldValue.serverTimestamp(),
          });
          
          debugPrint('✅ Migrated meeting for: $clientName ($phoneNumber)');
        }
      }
    } catch (e) {
      debugPrint('❌ Error migrating global meetings data: $e');
    }
  }


  // =================== TEAM-BASED OPERATIONS ===================

  /// Obține toate întâlnirile pentru echipa consultantului curent
  /// Aceasta va fi folosită pentru calendarArea să afișeze întâlnirile întregii echipe
  Future<List<Map<String, dynamic>>> getAllTeamMeetings() async {
    try {
      // Obține consultanții din echipa curentă
      final teamConsultants = await _consultantService.getTeamConsultants();
      
      final List<Map<String, dynamic>> allMeetings = [];
      
      // Pentru fiecare consultant din echipă, obține toate întâlnirile
      for (final consultant in teamConsultants) {
        final consultantId = consultant['id'] as String;
        final consultantName = consultant['name'] as String? ?? 'Consultant necunoscut';
        
        final consultantMeetings = await _getConsultantMeetings(consultantId, consultantName);
        allMeetings.addAll(consultantMeetings);
      }
      
      // Sortează întâlnirile după dată
      allMeetings.sort((a, b) {
        final dateA = (a['dateTime'] as Timestamp).toDate();
        final dateB = (b['dateTime'] as Timestamp).toDate();
        return dateA.compareTo(dateB);
      });
      
      return allMeetings;
    } catch (e) {
      debugPrint('❌ Error getting team meetings: $e');
      return [];
    }
  }

  /// Obține toate întâlnirile pentru un consultant specific
  Future<List<Map<String, dynamic>>> _getConsultantMeetings(String consultantId, String consultantName) async {
    try {
      final List<Map<String, dynamic>> consultantMeetings = [];
      
      // Obține toți clienții consultantului
      final clientsSnapshot = await _firestore
          .collection(_consultantsCollection)
          .doc(consultantId)
          .collection(_clientsSubcollection)
          .get();
      
      // Pentru fiecare client, obține întâlnirile
      for (final clientDoc in clientsSnapshot.docs) {
        final phoneNumber = clientDoc.id;
        final clientData = clientDoc.data();
        final clientName = clientData['name'] as String? ?? 'Client necunoscut';
        
        final meetingsSnapshot = await _firestore
            .collection(_consultantsCollection)
            .doc(consultantId)
            .collection(_clientsSubcollection)
            .doc(phoneNumber)
            .collection(_meetingsSubcollection)
            .get();
        
        for (final meetingDoc in meetingsSnapshot.docs) {
          final meetingData = meetingDoc.data();
          
          // Adaugă informații suplimentare despre consultant și client
          final enrichedMeeting = Map<String, dynamic>.from(meetingData);
          enrichedMeeting['meetingId'] = meetingDoc.id;
          enrichedMeeting['consultantId'] = consultantId;
          enrichedMeeting['consultantName'] = consultantName;
          enrichedMeeting['clientName'] = clientName;
          enrichedMeeting['phoneNumber'] = phoneNumber;
          
          consultantMeetings.add(enrichedMeeting);
        }
      }
      
      return consultantMeetings;
    } catch (e) {
      debugPrint('❌ Error getting consultant meetings for $consultantId: $e');
      return [];
    }
  }

  /// Obține întâlnirile echipei pentru o anumită dată
  Future<List<Map<String, dynamic>>> getTeamMeetingsForDate(DateTime date) async {
    try {
      final allTeamMeetings = await getAllTeamMeetings();
      
      // Filtrează întâlnirile pentru data specificată
      return allTeamMeetings.where((meeting) {
        final meetingDate = (meeting['dateTime'] as Timestamp).toDate();
        return meetingDate.year == date.year &&
               meetingDate.month == date.month &&
               meetingDate.day == date.day;
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting team meetings for date: $e');
      return [];
    }
  }

  /// Verifică dacă un slot de timp este ocupat de întâlniri în echipă
  Future<bool> isTimeSlotOccupiedByTeam(DateTime dateTime, {String? excludeMeetingId, String? excludeConsultantId}) async {
    try {
      final teamMeetings = await getTeamMeetingsForDate(dateTime);
      
      for (final meeting in teamMeetings) {
        final meetingDateTime = (meeting['dateTime'] as Timestamp).toDate();
        final meetingId = meeting['meetingId'] as String?;
        final consultantId = meeting['consultantId'] as String?;
        
        // Exclude specific meeting or consultant if specified
        if ((excludeMeetingId != null && meetingId == excludeMeetingId) ||
            (excludeConsultantId != null && consultantId == excludeConsultantId)) {
          continue;
        }
        
        // Check if the time slots overlap (assuming 30-minute meetings)
        final meetingEnd = meetingDateTime.add(const Duration(minutes: 30));
        final slotEnd = dateTime.add(const Duration(minutes: 30));
        
        if (dateTime.isBefore(meetingEnd) && slotEnd.isAfter(meetingDateTime)) {
          return true; // Time slot is occupied
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Error checking time slot availability: $e');
      return true; // Assume occupied on error for safety
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
}

// Extension pentru ușurință în utilizare
extension ClientFormDataExtension on ClientFormData {
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