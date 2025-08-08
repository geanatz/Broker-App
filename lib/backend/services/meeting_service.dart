import 'package:broker_app/backend/services/clients_service.dart';
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
  }) {
    debugPrint('🔍 MEETING_DATA: Constructor called');
    debugPrint('🔍 MEETING_DATA: clientName = "$clientName"');
    debugPrint('🔍 MEETING_DATA: phoneNumber = "$phoneNumber"');
    debugPrint('🔍 MEETING_DATA: consultantToken = "$consultantToken"');
    debugPrint('🔍 MEETING_DATA: consultantName = "$consultantName"');
    debugPrint('🔍 MEETING_DATA: dateTime = $dateTime');
    debugPrint('🔍 MEETING_DATA: type = $type');
    
    // Validate required fields
    if (clientName.isEmpty) {
      throw ArgumentError('clientName cannot be empty');
    }
    if (phoneNumber.isEmpty) {
      throw ArgumentError('phoneNumber cannot be empty');
    }
    if (consultantToken.isEmpty) {
      throw ArgumentError('consultantToken cannot be empty');
    }
    if (consultantName.isEmpty) {
      throw ArgumentError('consultantName cannot be empty');
    }
    
    debugPrint('✅ MEETING_DATA: Constructor completed successfully');
  }

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
/// OPTIMIZAT: Implementare avansata cu cache inteligent si operatii paralele
class MeetingService {
  static final MeetingService _instance = MeetingService._internal();
  factory MeetingService() => _instance;
  MeetingService._internal();

  final NewFirebaseService _firebaseService = NewFirebaseService();
  
  // OPTIMIZARE: Cache avansat pentru clienti recent cautati
  final Map<String, dynamic> _clientCache = {};
  Timer? _clientCacheTimer;
  
  // OPTIMIZARE: Debouncing imbunatatit pentru notificari
  Timer? _notificationDebounceTimer;
  final Set<String> _pendingNotifications = {};
  
  // OPTIMIZARE: Cache pentru verificari de disponibilitate
  final Map<String, bool> _availabilityCache = {};
  Timer? _availabilityCacheTimer;

  /// OPTIMIZAT: Notifica dashboard-ul cu debouncing imbunatatit
  Future<void> _notifyMeetingCreated(String clientPhoneNumber) async {
    try {
      final consultantToken = await _firebaseService.getCurrentConsultantToken();
      debugPrint('🔔 MEETING_SERVICE: Notifying meeting created for consultant: ${consultantToken?.substring(0, 8) ?? 'NULL'} for client: $clientPhoneNumber');
      
      if (consultantToken != null) {
        // OPTIMIZARE: Debouncing imbunatatit pentru notificari
        if (_pendingNotifications.contains('meeting_created')) return;
        _pendingNotifications.add('meeting_created');
        
        _notificationDebounceTimer?.cancel();
        _notificationDebounceTimer = Timer(const Duration(milliseconds: 50), () async {
          try {
            final dashboardService = DashboardService();
            await dashboardService.onMeetingCreated(consultantToken, clientPhoneNumber);
            debugPrint('✅ MEETING_SERVICE: Dashboard notified successfully');
            
            // OPTIMIZARE: Refresh singur in loc de multiple
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

  /// OPTIMIZAT: Notifica clientul despre intalnirea creata cu performanta imbunatatita
  Future<void> _notifyClientMeetingCreated(String phoneNumber, DateTime dateTime) async {
    try {
      final clientService = SplashService().clientUIService;

      // OPTIMIZARE: Verificare rapida din cache in loc de reload complet
      var client = _clientCache[phoneNumber];
      
      if (client == null) {
        // OPTIMIZARE: Cauta in lista existenta inainte de a reincarca
        final clientsWithPhone = clientService.clients.where((c) => c.phoneNumber == phoneNumber);
        if (clientsWithPhone.isNotEmpty) {
          client = clientsWithPhone.first;
          // OPTIMIZARE: Salveaza in cache pentru viitor
          _clientCache[phoneNumber] = client;
          _resetClientCache();
        } else {
          // OPTIMIZARE: Doar daca nu e in lista existenta, reincarca
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
      
      // Verifica daca clientul a fost gasit inainte de a-l folosi
      if (client != null) {
        debugPrint('📱 MEETING_SERVICE: Moving client to Recente with Acceptat status: ${client.name}');
        
        // VERIFICARE: Nu incrementeaza statisticile daca clientul a fost deja contorizat
        if (!client.isCompleted) {
          debugPrint('📱 MEETING_SERVICE: Client not completed, proceeding with move and statistics increment');
          
          // OPTIMIZARE: Operatie paralela pentru mutarea clientului cu delay redus
          await Future.wait([
            clientService.moveClientToRecente(
              phoneNumber,
              scheduledDateTime: dateTime,
              additionalInfo: 'Intalnire programata din calendar',
            ),
            // OPTIMIZARE: Invalideaza cache-ul in paralel cu delay redus
            _invalidateCacheWithDelay(),
          ]);
          
          debugPrint('✅ MEETING_SERVICE: Client moved to Recente successfully');
        } else {
          debugPrint('⚠️ MEETING_SERVICE: Client already completed, skipping statistics increment to prevent duplicates');
          
          // Doar invalideaza cache-ul fara a incrementa statisticile
          await _invalidateCacheWithDelay();
        }
      } else {
        debugPrint('⚠️ MEETING_SERVICE: Client not found for phone: $phoneNumber');
      }
    } catch (e) {
      debugPrint('❌ MEETING_SERVICE: Error notifying client meeting created: $e');
    }
  }

  /// OPTIMIZARE: Invalidare cache cu delay redus pentru performanta
  Future<void> _invalidateCacheWithDelay() async {
    try {
      final splashService = SplashService();
      // OPTIMIZARE: Delay redus pentru raspuns mai rapid
      await Future.delayed(const Duration(milliseconds: 50));
      await splashService.invalidateMeetingsCacheAndRefresh();
    } catch (e) {
      debugPrint('❌ MEETING_SERVICE: Error invalidating cache: $e');
    }
  }

  /// OPTIMIZARE: Reseteaza cache-ul de clienti dupa 30 secunde
  void _resetClientCache() {
    _clientCacheTimer?.cancel();
    _clientCacheTimer = Timer(const Duration(seconds: 30), () {
      _clientCache.clear();
      debugPrint('🧹 MEETING_SERVICE: Client cache cleared');
    });
  }

  /// OPTIMIZARE: Reseteaza cache-ul de disponibilitate dupa 10 minute
  void _resetAvailabilityCache() {
    _availabilityCacheTimer?.cancel();
    _availabilityCacheTimer = Timer(const Duration(minutes: 10), () {
      _availabilityCache.clear();
      debugPrint('🧹 MEETING_SERVICE: Availability cache cleared');
    });
  }

  /// Notifica dashboard-ul ca o intalnire a fost stearsa
  void _notifyMeetingDeleted() {
    try {
      debugPrint('📉 Meeting deleted - dashboard notified');
      // DashboardService nu are metoda onMeetingDeleted implementata
      // In viitor, ar putea fi adaugata
    } catch (e) {
      debugPrint('❌ Error notifying meeting deleted: $e');
    }
  }

  /// OPTIMIZAT: Verifica disponibilitatea slot-ului cu cache
  Future<bool> _isTimeSlotAvailable(DateTime dateTime) async {
    final timeKey = DateFormat('yyyy-MM-dd-HH-mm').format(dateTime);
    
    // OPTIMIZARE: Verifica cache-ul mai intai
    if (_availabilityCache.containsKey(timeKey)) {
      return _availabilityCache[timeKey]!;
    }
    
    try {
      final splashService = SplashService();
      final allMeetings = await splashService.getCachedMeetings();
      
      // Verifica daca exista intalniri in acelasi slot
      final hasConflict = allMeetings.any((meeting) {
        final meetingDate = meeting.dateTime;
        return meetingDate.year == dateTime.year &&
               meetingDate.month == dateTime.month &&
               meetingDate.day == dateTime.day &&
               meetingDate.hour == dateTime.hour &&
               meetingDate.minute == dateTime.minute;
      });
      
      final isAvailable = !hasConflict;
      
      // OPTIMIZARE: Salveaza in cache
      _availabilityCache[timeKey] = isAvailable;
      _resetAvailabilityCache();
      
      return isAvailable;
    } catch (e) {
      debugPrint('❌ MEETING_SERVICE: Error checking time slot availability: $e');
      return false;
    }
  }

  /// OPTIMIZAT: Creeaza o noua intalnire cu performanta imbunatatita si feedback instant
  Future<Map<String, dynamic>> createMeeting(MeetingData meetingData) async {
    debugPrint('🔍 MEETING_SERVICE: Starting createMeeting | Client: ${meetingData.clientName} | Date: ${meetingData.dateTime} | Type: ${meetingData.type}');
    
    try {
      // OPTIMIZARE: Verificare rapida de disponibilitate din cache
      final isAvailable = await _isTimeSlotAvailable(meetingData.dateTime);
      if (!isAvailable) {
        debugPrint('❌ MEETING_SERVICE: Time slot not available');
        return {
          'success': false,
          'error': 'Slot-ul de timp nu este disponibil',
        };
      }

      debugPrint('🔍 MEETING_SERVICE: Starting optimized parallel operations');
      
      // OPTIMIZARE: Operatii paralele optimizate cu feedback instant
      final results = await Future.wait([
        // Operatia principala - crearea intalnirii
        _firebaseService.createMeeting(
          phoneNumber: meetingData.phoneNumber,
          dateTime: meetingData.dateTime,
          type: meetingData.type == MeetingType.meeting ? 'meeting' : 'bureauDelete',
          description: meetingData.type == MeetingType.meeting ? 'Intalnire programata' : 'Stergere birou credit',
          additionalData: {
            'clientName': meetingData.clientName,
            'consultantName': meetingData.consultantName,
            'consultantToken': meetingData.consultantToken,
            'consultantId': FirebaseAuth.instance.currentUser?.uid,
          },
        ),
        // OPTIMIZARE: Operatii secundare in paralel pentru performanta
        _notifyMeetingCreated(meetingData.phoneNumber),
      ]);

      final meetingCreated = results[0] as bool;
      
      if (meetingCreated) {
        debugPrint('✅ MEETING_SERVICE: Meeting created successfully | Client: ${meetingData.clientName} | Date: ${meetingData.dateTime}');
        
        // OPTIMIZARE: Notificare optimizata pentru client cu delay redus
        _notifyClientMeetingCreated(meetingData.phoneNumber, meetingData.dateTime);
        
        return {
          'success': true,
          'message': 'Intalnire creata cu succes',
        };
      } else {
        debugPrint('❌ MEETING_SERVICE: Failed to create meeting');
        return {
          'success': false,
          'error': 'Nu s-a putut crea intalnirea',
        };
      }
    } catch (e) {
      debugPrint('❌ MEETING_SERVICE: Error creating meeting: $e');
      debugPrint('❌ MEETING_SERVICE: Stack trace: ${StackTrace.current}');
      return {
        'success': false,
        'error': 'Eroare la crearea intalnirii: $e',
      };
    }
  }

  /// OPTIMIZAT: Editeaza o intalnire existenta
  Future<Map<String, dynamic>> editMeeting(String meetingId, MeetingData meetingData) async {
    try {
      // OPTIMIZARE: Verifica disponibilitatea doar daca timpul s-a schimbat
      final isAvailable = await _isTimeSlotAvailable(meetingData.dateTime);
      if (!isAvailable) {
        return {
          'success': false,
          'error': 'Slot-ul de timp nu este disponibil',
        };
      }

      // OPTIMIZARE: Operatii paralele pentru editarea intalnirii
      await Future.wait([
        _firebaseService.updateMeeting(
          phoneNumber: meetingData.phoneNumber,
          meetingId: meetingId,
          dateTime: meetingData.dateTime,
          type: meetingData.type == MeetingType.meeting ? 'meeting' : 'bureauDelete',
          description: meetingData.type == MeetingType.meeting ? 'Intalnire programata' : 'Stergere birou credit',
          additionalData: {
            'clientName': meetingData.clientName,
            'consultantName': meetingData.consultantName,
            'consultantToken': meetingData.consultantToken,
            'consultantId': FirebaseAuth.instance.currentUser?.uid,
          },
        ),
        _notifyMeetingCreated(meetingData.phoneNumber),
      ]);

      debugPrint('✅ MEETING_SERVICE: Meeting edited successfully');
      
      return {
        'success': true,
        'message': 'Intalnire editata cu succes',
      };
    } catch (e) {
      debugPrint('❌ MEETING_SERVICE: Error editing meeting: $e');
      return {
        'success': false,
        'error': 'Eroare la editarea intalnirii: $e',
      };
    }
  }

  /// Pentru compatibilitate cu codul existent - alias pentru editMeeting
  Future<Map<String, dynamic>> updateMeeting(String meetingId, MeetingData meetingData) async {
    return await editMeeting(meetingId, meetingData);
  }

  /// OPTIMIZAT: Sterge o intalnire
  Future<Map<String, dynamic>> deleteMeeting(String meetingId, String phoneNumber) async {
    try {
      await _firebaseService.deleteMeeting(
        phoneNumber: phoneNumber,
        meetingId: meetingId,
      );
      _notifyMeetingDeleted();
      
      debugPrint('✅ MEETING_SERVICE: Meeting deleted successfully');
      
      return {
        'success': true,
        'message': 'Intalnire stearsa cu succes',
      };
    } catch (e) {
      debugPrint('❌ MEETING_SERVICE: Error deleting meeting: $e');
      return {
        'success': false,
        'error': 'Eroare la stergerea intalnirii: $e',
      };
    }
  }

  /// OPTIMIZAT: Obtine slot-urile de timp disponibile pentru o data specifica
  Future<List<String>> getAvailableTimeSlots(DateTime date, {String? excludeId}) async {
    try {
      // OPTIMIZARE: Foloseste SplashService pentru cache
      final splashService = SplashService();
      return await splashService.getAvailableTimeSlots(date, excludeId: excludeId);
    } catch (e) {
      debugPrint('❌ MEETING_SERVICE: Error getting available time slots: $e');
      return [];
    }
  }

  /// OPTIMIZAT: Obtine toate intalnirile pentru o data specifica
  Future<List<MeetingData>> getMeetingsForDate(DateTime date) async {
    try {
      final splashService = SplashService();
      // Ensure caches are aligned with current consultant
      await splashService.resetForNewConsultant();
      final allMeetings = await splashService.getCachedMeetings();
      
      final List<MeetingData> meetingsForDate = [];
      
      for (final meeting in allMeetings) {
        final meetingDate = meeting.dateTime;
        if (meetingDate.year == date.year &&
            meetingDate.month == date.month &&
            meetingDate.day == date.day) {
          
          meetingsForDate.add(MeetingData(
            id: meeting.id,
            clientName: meeting.additionalData?['clientName'] ?? 'Client necunoscut',
            phoneNumber: meeting.additionalData?['phoneNumber'] ?? '',
            dateTime: meeting.dateTime,
            type: meeting.type == ClientActivityType.meeting ? MeetingType.meeting : MeetingType.bureauDelete,
            consultantToken: meeting.additionalData?['consultantToken'] ?? '',
            consultantName: meeting.additionalData?['consultantName'] ?? 'Necunoscut',
            additionalData: meeting.additionalData,
          ));
        }
      }
      
      return meetingsForDate;
    } catch (e) {
      debugPrint('❌ MEETING_SERVICE: Error getting meetings for date: $e');
      return [];
    }
  }

  /// Cleanup pentru disposal
  void dispose() {
    _clientCacheTimer?.cancel();
    _notificationDebounceTimer?.cancel();
    _availabilityCacheTimer?.cancel();
    _clientCache.clear();
    _availabilityCache.clear();
    _pendingNotifications.clear();
  }
}


