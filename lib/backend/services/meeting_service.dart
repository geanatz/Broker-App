import 'package:cloud_firestore/cloud_firestore.dart';

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

/// Service refactorizat pentru gestionarea intalnirilor cu noua structura Firebase
class MeetingService {
  static final MeetingService _instance = MeetingService._internal();
  factory MeetingService() => _instance;
  MeetingService._internal();

  final NewFirebaseService _firebaseService = NewFirebaseService();


  /// Notifica dashboard-ul ca o intalnire a fost creata (FIX: mai robust)
  Future<void> _notifyMeetingCreated() async {
    try {
      final consultantToken = await _firebaseService.getCurrentConsultantToken();
      debugPrint('🔔 MEETING_SERVICE: Notifying meeting created for consultant: ${consultantToken?.substring(0, 8) ?? 'NULL'}');
      
      if (consultantToken != null) {
        // Notifica dashboard-ul sa actualizeze statisticile
        final dashboardService = DashboardService();
        await dashboardService.onMeetingCreated(consultantToken);
        debugPrint('✅ MEETING_SERVICE: Dashboard notified successfully');
        
        // FIX: Trigger refresh pentru dashboard pentru actualizare UI
        dashboardService.refreshData();
      } else {
        debugPrint('❌ MEETING_SERVICE: Cannot notify - consultant token is null');
      }
    } catch (e) {
      debugPrint('❌ MEETING_SERVICE: Error notifying meeting created: $e');
    }
  }

  /// FIX: Notifica clients_service ca o intalnire a fost creata pentru un client
  Future<void> _notifyClientMeetingCreated(String phoneNumber, DateTime dateTime) async {
    try {
      // Skip notificarea pentru intalnirile fara client specific
      if (phoneNumber.isEmpty || phoneNumber == 'no_client_meetings') {
        debugPrint('📅 MEETING_SERVICE: Skipping client notification for general meeting');
        return;
      }

      // Importam SplashService pentru a accesa ClientUIService
      final splashService = SplashService();
      if (splashService.isInitialized) {
        final clientService = splashService.clientUIService;
        
        // FIX: Forțează refresh-ul ClientUIService pentru a obține cel mai recent client
        debugPrint('🔄 MEETING_SERVICE: Refreshing ClientUIService to get latest clients...');
        await clientService.loadClientsFromFirebase();
        
        // Verifica daca clientul exista in lista locala actualizata
        final clientsWithPhone = clientService.clients.where((c) => c.phoneNumber == phoneNumber);
        var client = clientsWithPhone.isNotEmpty ? clientsWithPhone.first : null;
        
        // FIX: Dacă clientul nu se găsește, încearcă din nou după o scurtă întârziere
        if (client == null) {
          debugPrint('⚠️ MEETING_SERVICE: Client not found on first try, retrying after delay...');
          await Future.delayed(const Duration(milliseconds: 1000));
          await clientService.loadClientsFromFirebase();
          
          final clientsRetry = clientService.clients.where((c) => c.phoneNumber == phoneNumber);
          client = clientsRetry.isNotEmpty ? clientsRetry.first : null;
        }
        
        if (client != null) {
          debugPrint('📱 MEETING_SERVICE: Moving client to Recente with Acceptat status: ${client.name}');
          
          // Muta clientul in categoria "Recente" cu status "Acceptat"
          await clientService.moveClientToRecente(
            phoneNumber,
            scheduledDateTime: dateTime,
            additionalInfo: 'Intalnire programata din calendar',
          );
          
          debugPrint('✅ MEETING_SERVICE: Client moved to Recente successfully');
          
          // FIX: Forțează notificare listeners pentru actualizare UI
          clientService.notifyListeners();
        } else {
          debugPrint('⚠️ MEETING_SERVICE: Client not found in ClientUIService after multiple retries: $phoneNumber');
        }
      }
    } catch (e) {
      debugPrint('❌ MEETING_SERVICE: Error notifying client meeting created: $e');
    }
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

  /// Creeaza o noua intalnire pentru un client sau fara client
  Future<Map<String, dynamic>> createMeeting(MeetingData meetingData) async {
    try {
      // Verifica daca slotul este disponibil
      final isAvailable = await _isTimeSlotAvailable(meetingData.dateTime);
      if (!isAvailable) {
        return {'success': false, 'message': 'Slotul de timp nu este disponibil'};
      }

      final phoneNumber = meetingData.phoneNumber.trim();
      final isClientless = phoneNumber.isEmpty;
      
      // Pentru intalniri fara client, folosim un identificator special
      final clientIdentifier = isClientless ? 'no_client_meetings' : phoneNumber;

      // Asigura-te ca exista un client sau containerul pentru intalniri
      if (isClientless) {
        // Creeaza un "client" special pentru intalniri fara client daca nu exista
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
      } else {
        // Pentru intalniri cu client, asigura-te ca clientul exista
        final existingClient = await _firebaseService.getClient(phoneNumber);
        if (existingClient == null) {
          await _firebaseService.createClient(
            phoneNumber: phoneNumber,
            name: meetingData.clientName,
            status: 'normal',
            category: 'apeluri',
          );
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
          'consultantToken': await _firebaseService.getCurrentConsultantToken(), // FIX: Salvăm consultantToken pentru identificare
          'isClientless': isClientless,
        },
      );

      if (success) {
        debugPrint("✅ Meeting created successfully: ${meetingData.clientName}");
        
        // Notifica dashboard-ul
        await _notifyMeetingCreated();
        
        // FIX: Așteaptă o mică întârziere pentru sincronizarea Firebase înainte de notificare
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Notifica clients_service
        await _notifyClientMeetingCreated(phoneNumber, meetingData.dateTime);
        
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
}


