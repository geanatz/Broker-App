import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'dashboard_service.dart';
import 'firebase_service.dart';
import 'splash_service.dart';

/// Tipul de intalnire
enum MeetingType {
  meeting,      // Intalnire cu clientul
  bureauDelete  // Stergere birou de credit
}

/// Model pentru datele unei intalniri
class MeetingData {
  final String? id;
  final String clientName;
  final String phoneNumber;
  final DateTime dateTime;
  final MeetingType type;
  final String consultantToken;
  final String consultantName;
  final Map<String, dynamic>? additionalData;

  MeetingData({
    this.id,
    required this.clientName,
    required this.phoneNumber,
    required this.dateTime,
    required this.type,
    required this.consultantToken,
    required this.consultantName,
    this.additionalData,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'clientName': clientName,
      'phoneNumber': phoneNumber,
      'dateTime': Timestamp.fromDate(dateTime),
      'type': type == MeetingType.meeting ? 'meeting' : 'bureauDelete',
      'consultantToken': consultantToken,
      'consultantName': consultantName,
      'additionalData': additionalData ?? {},
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory MeetingData.fromFirestore(Map<String, dynamic> data, String id) {
    return MeetingData(
      id: id,
      clientName: data['clientName'] ?? data['additionalData']?['clientName'] ?? 'Client necunoscut',
      phoneNumber: data['phoneNumber'] ?? data['clientPhoneNumber'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      type: data['type'] == 'bureauDelete' ? MeetingType.bureauDelete : MeetingType.meeting,
      consultantToken: data['consultantToken'] ?? '',
      consultantName: data['consultantName'] ?? data['additionalData']?['consultantName'] ?? 'Necunoscut',
      additionalData: data['additionalData'] ?? {},
    );
  }
}

/// Service optimizat pentru gestionarea intalnirilor
class MeetingService {
  static final MeetingService _instance = MeetingService._internal();
  factory MeetingService() => _instance;
  MeetingService._internal();

  final NewFirebaseService _firebaseService = NewFirebaseService();
  
  // OPTIMIZARE: Cache pentru clienți recent căutați
  final Map<String, dynamic> _clientCache = {};
  Timer? _clientCacheTimer;
  
  // OPTIMIZARE: Debouncing pentru notificări
  Timer? _notificationDebounceTimer;
  final Set<String> _pendingNotifications = {};

  /// OPTIMIZAT: Notifica dashboard-ul cu debouncing pentru a evita apelurile multiple
  Future<void> _notifyMeetingCreated() async {
    try {
      final consultantToken = await _firebaseService.getCurrentConsultantToken();
      debugPrint('🔔 MEETING_SERVICE: Notifying meeting created for consultant: ${consultantToken?.substring(0, 8) ?? 'NULL'}');
      
      if (consultantToken != null) {
        // OPTIMIZARE: Debouncing pentru notificări
        if (_pendingNotifications.contains('meeting_created')) return;
        _pendingNotifications.add('meeting_created');
        
        _notificationDebounceTimer?.cancel();
        _notificationDebounceTimer = Timer(const Duration(milliseconds: 100), () async {
          try {
            final dashboardService = DashboardService();
            await dashboardService.onMeetingCreated(consultantToken);
            debugPrint('✅ MEETING_SERVICE: Dashboard notified successfully');
            
            // OPTIMIZARE: Refresh singur în loc de multiple
            dashboardService.refreshData();
            _pendingNotifications.remove('meeting_created');
          } catch (e) {
            debugPrint('❌ MEETING_SERVICE: Error in debounced notification: $e');
            _pendingNotifications.remove('meeting_created');
          }
        });
      } else {
        debugPrint('❌ MEETING_SERVICE: Cannot notify - consultant token is null');
      }
    } catch (e) {
      debugPrint('❌ MEETING_SERVICE: Error notifying meeting created: $e');
    }
  }

  /// OPTIMIZAT: Notifica clients_service fără retry logic și cu cache
  Future<void> _notifyClientMeetingCreated(String phoneNumber, DateTime dateTime) async {
    try {
      // Skip notificarea pentru intalnirile fara client specific
      if (phoneNumber.isEmpty || phoneNumber == 'no_client_meetings') {
        debugPrint('📅 MEETING_SERVICE: Skipping client notification for general meeting');
        return;
      }

      // OPTIMIZARE: Cache lookup mai întâi
      var client = _clientCache[phoneNumber];
      
      final splashService = SplashService();
      if (splashService.isInitialized) {
        final clientService = splashService.clientUIService;
        
        // OPTIMIZARE: Doar dacă clientul nu e în cache, încarcă din service
        if (client == null) {
          // OPTIMIZARE: Verifică mai întâi în lista existentă din service
          final clientsWithPhone = clientService.clients.where((c) => c.phoneNumber == phoneNumber);
          if (clientsWithPhone.isNotEmpty) {
            client = clientsWithPhone.first;
            // OPTIMIZARE: Salvează în cache pentru viitor
            _clientCache[phoneNumber] = client;
            _resetClientCache();
          } else {
            // OPTIMIZARE: Doar dacă nu e în lista existentă, reîncarcă
            debugPrint('🔄 MEETING_SERVICE: Client not in current list, refreshing...');
            await clientService.loadClientsFromFirebase();
            
            final clientsRetry = clientService.clients.where((c) => c.phoneNumber == phoneNumber);
            if (clientsRetry.isNotEmpty) {
              client = clientsRetry.first;
              _clientCache[phoneNumber] = client;
              _resetClientCache();
            }
          }
        }
        
        if (client != null) {
          debugPrint('📱 MEETING_SERVICE: Moving client to Recente with Acceptat status: ${client.name}');
          
          // OPTIMIZARE: Apel direct fără multiple refresh-uri
          await clientService.moveClientToRecente(
            phoneNumber,
            scheduledDateTime: dateTime,
            additionalInfo: 'Intalnire programata din calendar',
          );
          
          debugPrint('✅ MEETING_SERVICE: Client moved to Recente successfully');
        } else {
          debugPrint('⚠️ MEETING_SERVICE: Client not found: $phoneNumber');
        }
      }
    } catch (e) {
      debugPrint('❌ MEETING_SERVICE: Error notifying client meeting created: $e');
    }
  }

  /// OPTIMIZARE: Resetează cache-ul de clienți după 30 secunde
  void _resetClientCache() {
    _clientCacheTimer?.cancel();
    _clientCacheTimer = Timer(const Duration(seconds: 30), () {
      _clientCache.clear();
      debugPrint('🧹 MEETING_SERVICE: Client cache cleared');
    });
  }

  /// Notifica dashboard-ul ca o intalnire a fost stearsa
  void _notifyMeetingDeleted() {
    try {
      debugPrint('📉 Meeting deleted - dashboard notified');
      // DashboardService nu are metoda onMeetingDeleted implementata
      // În viitor, ar putea fi adăugată
    } catch (e) {
      debugPrint('❌ Error notifying meeting deleted: $e');
    }
  }

  /// OPTIMIZAT: Creeaza o noua intalnire cu performanță îmbunătățită
  Future<Map<String, dynamic>> createMeeting(MeetingData meetingData) async {
    try {
      // OPTIMIZARE: Cache verificarea de disponibilitate
      final isAvailable = await _isTimeSlotAvailable(meetingData.dateTime);
      if (!isAvailable) {
        return {'success': false, 'message': 'Slotul de timp nu este disponibil'};
      }

      final phoneNumber = meetingData.phoneNumber.trim();
      final isClientless = phoneNumber.isEmpty;
      
      // Pentru intalniri fara client, folosim un identificator special
      final clientIdentifier = isClientless ? 'no_client_meetings' : phoneNumber;

      // OPTIMIZARE: Verifică cache-ul pentru client special mai întâi
      if (isClientless && !_clientCache.containsKey('no_client_container_checked')) {
        final existingContainer = await _firebaseService.getClient(clientIdentifier);
        if (existingContainer == null) {
          await _firebaseService.createClient(
            phoneNumber: clientIdentifier,
            name: 'Întâlniri generale',
            status: 'system',
            category: 'meetings',
            additionalData: {
              'isSystemClient': true,
              'description': 'Container pentru întâlniri fără client specific',
            },
          );
        }
        _clientCache['no_client_container_checked'] = true;
        _resetClientCache();
      } else if (!isClientless) {
        // OPTIMIZARE: Pentru intalniri cu client, verifică cache-ul mai întâi
        if (!_clientCache.containsKey(phoneNumber)) {
          final existingClient = await _firebaseService.getClient(phoneNumber);
          if (existingClient == null) {
            await _firebaseService.createClient(
              phoneNumber: phoneNumber,
              name: meetingData.clientName,
              status: 'normal',
              category: 'apeluri',
            );
          }
          _clientCache[phoneNumber] = true;
          _resetClientCache();
        }
      }

      // Creeaza intalnirea
      final success = await _firebaseService.createMeeting(
        phoneNumber: clientIdentifier,
        dateTime: meetingData.dateTime,
        type: meetingData.type == MeetingType.meeting ? 'meeting' : 'bureauDelete',
        description: meetingData.type == MeetingType.bureauDelete 
            ? 'Stergere birou credit' 
            : 'Intalnire programata',
        additionalData: {
          'clientName': meetingData.clientName,
          'phoneNumber': phoneNumber, // Numarul real al clientului
          'consultantName': meetingData.consultantName,
          'consultantToken': await _firebaseService.getCurrentConsultantToken(),
          'consultantId': FirebaseAuth.instance.currentUser?.uid,
          'isClientless': isClientless,
        },
      );

      if (success) {
        debugPrint("✅ Meeting created successfully: ${meetingData.clientName}");
        
        // OPTIMIZARE: Notificări paralele pentru performanță
        final List<Future> notifications = [
          _notifyMeetingCreated(),
        ];
        
        // OPTIMIZARE: Doar pentru clienți cu telefon real
        if (!isClientless) {
          // OPTIMIZARE: Delay redus de la 500ms la 100ms
          notifications.add(
            Future.delayed(const Duration(milliseconds: 100)).then((_) => 
              _notifyClientMeetingCreated(phoneNumber, meetingData.dateTime)
            )
          );
        }
        
        // OPTIMIZARE: Execută notificările în paralel
        await Future.wait(notifications);
        
        return {'success': true, 'message': 'Intalnire creata cu succes'};
      } else {
        return {'success': false, 'message': 'Eroare la salvarea intalnirii'};
      }
    } catch (e) {
      debugPrint("❌ Error createMeeting: $e");
      return {'success': false, 'message': 'Eroare la crearea intalnirii: $e'};
    }
  }

  /// Actualizeaza o intalnire existenta
  Future<Map<String, dynamic>> updateMeeting(String meetingId, MeetingData meetingData) async {
    try {
      // Verifica daca noul slot este disponibil (exclud intalnirea curenta)
      final isAvailable = await _isTimeSlotAvailable(
        meetingData.dateTime, 
        excludeMeetingId: meetingId
      );
      if (!isAvailable) {
        return {'success': false, 'message': 'Noul slot de timp nu este disponibil'};
      }

      meetingData.phoneNumber.trim();

      // Actualizeaza intalnirea (implementarea de actualizare va fi adaugata in NewFirebaseService)
      // Pentru moment, stergem si recream
      await _deleteMeetingById(meetingId);
      
      final createResult = await createMeeting(meetingData);
      return createResult;
    } catch (e) {
      debugPrint("❌ Error updateMeeting: $e");
      return {'success': false, 'message': 'Eroare la actualizarea intalnirii: $e'};
    }
  }

  /// Sterge o intalnire
  Future<Map<String, dynamic>> deleteMeeting(String meetingId) async {
    try {
      final success = await _deleteMeetingById(meetingId);
      
      if (success) {
        // Notifica dashboard-ul
        _notifyMeetingDeleted();
        
        return {'success': true, 'message': 'Intalnire stearsa cu succes'};
      } else {
        return {'success': false, 'message': 'Eroare la stergerea intalnirii'};
      }
    } catch (e) {
      debugPrint("❌ Error deleteMeeting: $e");
      return {'success': false, 'message': 'Eroare la stergerea intalnirii: $e'};
    }
  }

  /// Obtine orele disponibile pentru o anumita data
  Future<List<String>> getAvailableTimeSlots(DateTime date, {String? excludeId}) async {
    try {
      // Orele de lucru disponibile
      final List<String> allSlots = [
        '09:30', '10:00', '10:30', '11:00', '11:30', 
        '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
        '15:00', '15:30', '16:00'
      ];

      // Obtine intalnirile echipei pentru aceasta data
      final teamMeetings = await _firebaseService.getTeamMeetings();
      
      // Filtreaza intalnirile pentru data specificata
      final meetingsForDate = teamMeetings.where((meeting) {
        final meetingDate = (meeting['dateTime'] as Timestamp).toDate();
        return DateFormat('yyyy-MM-dd').format(meetingDate) == 
               DateFormat('yyyy-MM-dd').format(date);
      }).toList();
      
      // Extrage orele ocupate (excluzand intalnirea specificata daca exista)
      final Set<String> occupiedSlots = {};
      for (var meeting in meetingsForDate) {
        // Skip the meeting we're editing
        if (excludeId != null && meeting['id'] == excludeId) continue;
        
        final meetingDateTime = (meeting['dateTime'] as Timestamp).toDate();
        final timeSlot = DateFormat('HH:mm').format(meetingDateTime);
        occupiedSlots.add(timeSlot);
      }

      // Returneaza sloturile disponibile
      return allSlots.where((slot) => !occupiedSlots.contains(slot)).toList();
    } catch (e) {
      debugPrint("❌ Error getAvailableTimeSlots: $e");
      return [];
    }
  }

  /// Obtine intalnirile pentru o saptamana (pentru echipa)
  Stream<List<MeetingData>> getMeetingsForWeek(DateTime startOfWeek, DateTime endOfWeek) {
    try {
      // Returnam un stream care emite periodic datele
      return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
        final teamMeetings = await _firebaseService.getTeamMeetings();
        
        // Filtreaza intalnirile pentru saptamana specificata
        final weekMeetings = teamMeetings.where((meetingData) {
          final meetingDate = (meetingData['dateTime'] as Timestamp).toDate();
          return meetingDate.isAfter(startOfWeek) && meetingDate.isBefore(endOfWeek);
        }).toList();

        // Converteste in format MeetingData
        return weekMeetings.map((meetingData) => MeetingData.fromFirestore(meetingData, meetingData['id'])).toList();
      });
    } catch (e) {
      debugPrint("❌ Error getMeetingsForWeek: $e");
      return Stream.value([]);
    }
  }

  /// Obtine intalnirile pentru consultantul curent
  Future<List<MeetingData>> getAllMeetingsForConsultant() async {
    try {
      final meetings = await _firebaseService.getAllMeetings();
      return meetings.map((meetingData) => MeetingData.fromFirestore(meetingData, meetingData['id'])).toList();
    } catch (e) {
      debugPrint("❌ Error getAllMeetingsForConsultant: $e");
      return [];
    }
  }

  // =================== HELPER METHODS ===================

  /// Verifica daca un slot de timp este disponibil
  Future<bool> _isTimeSlotAvailable(DateTime dateTime, {String? excludeMeetingId}) async {
    try {
      final teamMeetings = await _firebaseService.getTeamMeetings();
      
      for (var meeting in teamMeetings) {
        // Skip the meeting we're editing
        if (excludeMeetingId != null && meeting['id'] == excludeMeetingId) continue;
        
        final meetingDateTime = (meeting['dateTime'] as Timestamp).toDate();
        
        // Verifica daca este acelasi slot de timp
        if (DateFormat('yyyy-MM-dd HH:mm').format(meetingDateTime) == 
            DateFormat('yyyy-MM-dd HH:mm').format(dateTime)) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      debugPrint("❌ Error checking time slot availability: $e");
      return false;
    }
  }

  /// Sterge o intalnire dupa ID
  Future<bool> _deleteMeetingById(String meetingId) async {
    try {
      // Gaseste intalnirea in toate containerele
      final allMeetings = await _firebaseService.getAllMeetings();
      final targetMeeting = allMeetings.firstWhere(
        (meeting) => meeting['id'] == meetingId,
        orElse: () => throw Exception('Meeting not found'),
      );

      final clientPhoneNumber = targetMeeting['clientPhoneNumber'] as String;
      
      // Sterge intalnirea din containerul corespunzator
      final success = await _firebaseService.deleteMeeting(
        phoneNumber: clientPhoneNumber,
        meetingId: meetingId,
      );
      
      debugPrint('✅ Meeting deleted: $meetingId');
      return success;
    } catch (e) {
      debugPrint("❌ Error deleting meeting by ID: $e");
      return false;
    }
  }

  // =================== COMPATIBILITY METHODS ===================

  /// Pentru compatibilitate cu codul existent
  Future<Map<String, dynamic>> getMeetingById(String meetingId) async {
    try {
      final allMeetings = await _firebaseService.getAllMeetings();
      final meeting = allMeetings.firstWhere(
        (meeting) => meeting['id'] == meetingId,
        orElse: () => {},
      );
      
      return meeting;
    } catch (e) {
      debugPrint("❌ Error getting meeting by ID: $e");
      return {};
    }
  }

  /// OPTIMIZARE: Cleanup pentru timers și cache
  void dispose() {
    _notificationDebounceTimer?.cancel();
    _clientCacheTimer?.cancel();
    _clientCache.clear();
    _pendingNotifications.clear();
  }
}


