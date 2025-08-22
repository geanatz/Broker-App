import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:mat_finance/backend/services/clients_service.dart';
import 'package:mat_finance/backend/services/form_service.dart';
import 'package:mat_finance/backend/services/splash_service.dart';
import 'package:mat_finance/backend/services/firebase_service.dart';

/// Service pentru generarea de mesaje personalizate pentru clienti
class MessageService {
  static final MessageService _instance = MessageService._internal();
  factory MessageService() => _instance;
  MessageService._internal() {
    // Listen to form data changes to invalidate message cache
    _formService.addListener(_onFormDataChanged);
  }

  final FormService _formService = FormService();
  final SplashService _splashService = SplashService();
  final NewFirebaseService _firebaseService = NewFirebaseService();
  
  // URGENT FIX: Eliminated ALL message caching for guaranteed fresh data
  // Cache disabled completely to ensure instant updates

  /// Listener pentru schimbarile din FormService
  void _onFormDataChanged() {
    // URGENT FIX: No cache to clear since caching is completely disabled
    // This ensures instant responsiveness to form changes
  }

  /// Dispose pentru a elimina listener-ul
  void dispose() {
    _formService.removeListener(_onFormDataChanged);
  }

  /// Forteaza refresh-ul datelor pentru un client specific
  Future<void> forceRefreshForClient(String phoneNumber) async {
    // URGENT FIX: No cache to remove since caching is completely disabled
    
    // Forteaza refresh-ul datelor din FormService
    await _formService.forceRefreshFormData(phoneNumber, phoneNumber);
  }

  /// Invalideaza cache-ul pentru un client specific
  void invalidateCacheForClient(String phoneNumber) {
    // URGENT FIX: No cache to invalidate since caching is completely disabled
    // This ensures every message generation uses fresh data
  }

  /// Genereaza un mesaj personalizat pentru client
  Future<String> generatePersonalizedMessage(ClientModel client) async {
    try {
      debugPrint('🚨 MESSAGE_SERVICE: STARTING message generation for ${client.name} (${client.phoneNumber1})');
      
      // CROSS-PLATFORM FIX: Clear ALL Firebase caches to force server fetch
      debugPrint('🚨 MESSAGE_SERVICE: Clearing ALL Firebase caches to force fresh server data');
      _firebaseService.clearAllCaches();
      _firebaseService.clearClientCache();
      _firebaseService.clearFormCache();
      
      // FIXED: Simplified cache management - let appointment method handle synchronization  
      debugPrint('🚨 MESSAGE_SERVICE: Starting message generation with optimized cache sync');
      
      // Clear form caches to ensure fresh data
      _firebaseService.clearAllCaches();
      _firebaseService.clearClientCache();
      _firebaseService.clearFormCache();
      
      // SIMPLIFIED: Let _getNextAppointmentInfo handle meetings cache synchronization
      debugPrint('🚨 MESSAGE_SERVICE: Form caches cleared, proceeding with appointment lookup');
      
      // Get appointment info (this method now handles proper cache synchronization)
      final appointmentInfo = await _getNextAppointmentInfo(client);
      debugPrint('🚨 MESSAGE_SERVICE: Appointment info: $appointmentInfo');
      
      // Obtine informatiile despre venituri (pensie) - FRESH din server
      final hasRetirement = _checkIfClientHasRetirement(client);
      debugPrint('🚨 MESSAGE_SERVICE: Has retirement: $hasRetirement');
      
      // Obtine informatiile despre credite existente - FRESH din server
      final creditInfo = _getClientCreditInfo(client);
      debugPrint('🚨 MESSAGE_SERVICE: Credit info: $creditInfo');
      
      // Construieste mesajul cu datele ULTRA-FRESH
      final message = _buildMessage(
        appointmentInfo: appointmentInfo,
        hasRetirement: hasRetirement,
        creditInfo: creditInfo,
      );
      
      debugPrint('🚨 MESSAGE_SERVICE: Message generated successfully with FRESH SERVER data');
      
      // URGENT FIX: NO CACHING - Return fresh message immediately
      return message;
    } catch (e) {
      debugPrint('🚨 MESSAGE_SERVICE: Error generating message: $e');
      // In caz de eroare, returneaza un mesaj generic (fara cache pentru erori)
      return _getGenericMessage();
    }
  }

  /// Obtine informatiile despre urmatoarea programare
  Future<Map<String, dynamic>?> _getNextAppointmentInfo(ClientModel client) async {
    try {
      // FIXED: Proper synchronous cache refresh to avoid race condition
      debugPrint('🚨 MESSAGE_SERVICE: Starting synchronized meetings cache refresh for appointment sync');
      
      // Step 1: Clear ALL meetings caches completely
      _splashService.invalidateMeetingsCache();
      
      // Step 2: Force immediate cache refresh and WAIT for completion
      debugPrint('🚨 MESSAGE_SERVICE: Forcing immediate cache refresh with synchronous wait');
      
      // CRITICAL FIX: Use getCachedMeetings() which automatically refreshes if stale
      // This ensures we wait for the actual refresh to complete before proceeding
      final meetings = await _splashService.getCachedMeetings();
      debugPrint('🚨 MESSAGE_SERVICE: Retrieved ${meetings.length} meetings after synchronized refresh');
      
      // Step 3: If we got 0 meetings, force one more refresh attempt
      if (meetings.isEmpty) {
        debugPrint('🚨 MESSAGE_SERVICE: Got 0 meetings, forcing additional refresh attempt');
        await Future.delayed(Duration(milliseconds: 500)); // Wait for any pending Firebase operations
        final retriedMeetings = await _splashService.getCachedMeetings();
        debugPrint('🚨 MESSAGE_SERVICE: Retry retrieved ${retriedMeetings.length} meetings');
        
        if (retriedMeetings.isNotEmpty) {
          final finalMeetings = retriedMeetings;
          debugPrint('🚨 MESSAGE_SERVICE: Using ${finalMeetings.length} meetings from retry attempt');
          return _processAppointmentMatching(client, finalMeetings);
        }
      }
      
      return _processAppointmentMatching(client, meetings);
    } catch (e) {
      debugPrint('❌ MESSAGE_SERVICE: Error getting appointment info: $e');
      debugPrint('❌ MESSAGE_SERVICE: Stack trace: ${StackTrace.current}');
    }
    return null;
  }

  /// Process appointment matching logic extracted to separate method
  Map<String, dynamic>? _processAppointmentMatching(ClientModel client, List<ClientActivity> meetings) {
    try {
      
      final now = DateTime.now();
      
      // DEBUG: Log all meetings for debugging
      debugPrint('🔍 MESSAGE_SERVICE: All meetings for debug:');
      for (int i = 0; i < meetings.length; i++) {
        final meeting = meetings[i];
        final meetingMap = meeting.toMap();
        debugPrint('🔍 Meeting $i: ${meeting.dateTime} | additionalData: ${meeting.additionalData} | meetingMap: $meetingMap');
      }
      
      // Cauta intalniri viitoare pentru acest client cu enhanced matching
      debugPrint('🔍 MESSAGE_SERVICE: Searching appointments for client: ${client.name} | phone: ${client.phoneNumber1}');
      
      final clientMeetings = meetings.where((meeting) {
        if (!meeting.dateTime.isAfter(now)) {
          debugPrint('🔍 Meeting skipped (past date): ${meeting.dateTime}');
          return false;
        }
        
        // Enhanced phone number matching with normalization
        final meetingMap = meeting.toMap();
        final phoneNumbers = <String>[
          meeting.additionalData?['phoneNumber'] ?? '',
          meeting.additionalData?['clientPhoneNumber'] ?? '',
          meetingMap['phoneNumber'] ?? '',
        ].where((phone) => phone.isNotEmpty).map((phone) => _normalizePhoneNumber(phone)).toSet().toList();
        
        // Enhanced client name matching with normalization
        final clientNames = <String>[
          meeting.additionalData?['clientName'] ?? '',
          meetingMap['clientName'] ?? '',
        ].where((name) => name.isNotEmpty).map((name) => _normalizeText(name)).toSet().toList();
        
        // Normalize client data for comparison
        final normalizedClientPhone = _normalizePhoneNumber(client.phoneNumber1);
        final normalizedClientName = _normalizeText(client.name);
        
        debugPrint('🔍 Meeting phones: $phoneNumbers');
        debugPrint('🔍 Meeting names: $clientNames');
        debugPrint('🔍 Client phone normalized: $normalizedClientPhone');
        debugPrint('🔍 Client name normalized: $normalizedClientName');
        
        // Enhanced phone matching
        final phoneMatch = phoneNumbers.any((phone) => phone == normalizedClientPhone);
        
        // Enhanced name matching (exact and partial)
        final nameMatch = clientNames.any((name) {
          // Exact match
          if (name == normalizedClientName) return true;
          
          // Partial match (contains)
          if (name.contains(normalizedClientName) || normalizedClientName.contains(name)) {
            return normalizedClientName.length >= 3 && name.length >= 3; // Minimum length for partial match
          }
          
          return false;
        });
        
        debugPrint('🔍 Phone match: $phoneMatch | Name match: $nameMatch');
        
        final matches = phoneMatch || nameMatch;
        if (matches) {
          debugPrint('✅ FOUND matching appointment: ${meeting.dateTime} | Phone: $phoneMatch | Name: $nameMatch');
        }
        
        return matches;
      }).toList();
      
      debugPrint('🔍 MESSAGE_SERVICE: Found ${clientMeetings.length} matching appointments');
      
      if (clientMeetings.isNotEmpty) {
        // Ia prima intalnire (cea mai apropiata)
        clientMeetings.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        final nextMeeting = clientMeetings.first;
        
        debugPrint('✅ MESSAGE_SERVICE: Using appointment: ${nextMeeting.dateTime}');
        
        // Formateaza data in romana
        final dayOfWeek = _getDayOfWeekInRomanian(nextMeeting.dateTime.weekday);
        final day = nextMeeting.dateTime.day;
        final month = _getMonthInRomanian(nextMeeting.dateTime.month);
        final year = nextMeeting.dateTime.year;
        final time = DateFormat('HH:mm').format(nextMeeting.dateTime);
        
        final appointmentInfo = {
          'date': '$dayOfWeek, $day $month $year',
          'time': time,
        };
        
        debugPrint('✅ MESSAGE_SERVICE: Formatted appointment: $appointmentInfo');
        
        return appointmentInfo;
      } else {
        debugPrint('❌ MESSAGE_SERVICE: No matching appointments found for client: ${client.name}');
      }
    } catch (e) {
      debugPrint('❌ MESSAGE_SERVICE: Error in appointment matching: $e');
    }
    return null;
  }

  /// Verifica daca clientul are pensie
  bool _checkIfClientHasRetirement(ClientModel client) {
    try {
      final clientIncomeForms = _formService.getClientIncomeForms(client.phoneNumber1);
      debugPrint('🚨 MESSAGE_SERVICE: Client income forms count: ${clientIncomeForms.length}');
      
      for (int i = 0; i < clientIncomeForms.length; i++) {
        final incomeForm = clientIncomeForms[i];
        debugPrint('🚨 MESSAGE_SERVICE: Client income form $i: ${incomeForm.incomeType}');
        if (incomeForm.incomeType == 'Pensie' || incomeForm.incomeType == 'Pensie MAI') {
          debugPrint('🚨 MESSAGE_SERVICE: FOUND RETIREMENT in client forms');
          return true;
        }
      }
      
      // Verifica si pentru codebitor
      final coborrowerIncomeForms = _formService.getCoborrowerIncomeForms(client.phoneNumber1);
      debugPrint('🚨 MESSAGE_SERVICE: Coborrower income forms count: ${coborrowerIncomeForms.length}');
      
      for (int i = 0; i < coborrowerIncomeForms.length; i++) {
        final incomeForm = coborrowerIncomeForms[i];
        debugPrint('🚨 MESSAGE_SERVICE: Coborrower income form $i: ${incomeForm.incomeType}');
        if (incomeForm.incomeType == 'Pensie' || incomeForm.incomeType == 'Pensie MAI') {
          debugPrint('🚨 MESSAGE_SERVICE: FOUND RETIREMENT in coborrower forms');
          return true;
        }
      }
      
      debugPrint('🚨 MESSAGE_SERVICE: NO RETIREMENT found');
    } catch (e) {
      debugPrint('🚨 MESSAGE_SERVICE: Error checking retirement: $e');
    }
    return false;
  }

  /// Obtine informatiile despre creditele clientului
  Map<String, dynamic> _getClientCreditInfo(ClientModel client) {
    try {
      final clientCreditForms = _formService.getClientCreditForms(client.phoneNumber1);
      final coborrowerCreditForms = _formService.getCoborrowerCreditForms(client.phoneNumber1);
      
      debugPrint('🚨 MESSAGE_SERVICE: Client credit forms count: ${clientCreditForms.length}');
      debugPrint('🚨 MESSAGE_SERVICE: Coborrower credit forms count: ${coborrowerCreditForms.length}');
      
      final List<String> banks = [];
      bool hasCredits = false;
      
      // Colecteaza bancile din formularele de credit ale clientului
      for (int i = 0; i < clientCreditForms.length; i++) {
        final creditForm = clientCreditForms[i];
        debugPrint('🚨 MESSAGE_SERVICE: Client credit form $i: bank=${creditForm.bank}, isEmpty=${creditForm.isEmpty}');
        if (!creditForm.isEmpty && creditForm.bank != 'Selecteaza') {
          hasCredits = true;
          if (!banks.contains(creditForm.bank)) {
            banks.add(creditForm.bank);
            debugPrint('🚨 MESSAGE_SERVICE: Added bank: ${creditForm.bank}');
          }
        }
      }
      
      // Colecteaza bancile din formularele de credit ale codebitorului
      for (int i = 0; i < coborrowerCreditForms.length; i++) {
        final creditForm = coborrowerCreditForms[i];
        debugPrint('🚨 MESSAGE_SERVICE: Coborrower credit form $i: bank=${creditForm.bank}, isEmpty=${creditForm.isEmpty}');
        if (!creditForm.isEmpty && creditForm.bank != 'Selecteaza') {
          hasCredits = true;
          if (!banks.contains(creditForm.bank)) {
            banks.add(creditForm.bank);
            debugPrint('🚨 MESSAGE_SERVICE: Added bank: ${creditForm.bank}');
          }
        }
      }
      
      final result = {
        'hasCredits': hasCredits,
        'banks': banks,
        'totalCredits': (clientCreditForms.where((f) => !f.isEmpty).length + 
                        coborrowerCreditForms.where((f) => !f.isEmpty).length),
      };
      
      debugPrint('🚨 MESSAGE_SERVICE: Final credit info: $result');
      return result;
    } catch (e) {
      debugPrint('🚨 MESSAGE_SERVICE: Error getting credit info: $e');
      return {
        'hasCredits': false,
        'banks': <String>[],
        'totalCredits': 0,
      };
    }
  }

  /// Construieste mesajul personalizat
  String _buildMessage({
    Map<String, dynamic>? appointmentInfo,
    required bool hasRetirement,
    required Map<String, dynamic> creditInfo,
  }) {
    final hasCredits = creditInfo['hasCredits'] as bool;
    final banks = creditInfo['banks'] as List<String>;
    
    // Incepe cu salutul
    String message = 'Bună ziua!\n';
    
    // Adauga informatiile despre programare daca exista
    if (appointmentInfo != null) {
      message += 'Conform discuției telefonice, rămâne stabilită întâlnirea de *${appointmentInfo['date']}*, ora *${appointmentInfo['time']}*. ';
    } else {
      // Mesaj generic pentru programare
      message += 'Conform discuției telefonice, rămâne stabilită întâlnirea. ';
    }
    
    // Adauga adresa biroului
    message += 'Biroul nostru se află pe *Bulevardul Iuliu Maniu, nr. 7*. Vă rog să mă sunați când ajungeți pentru a vă prelua.\n';
    
    // Determina tipul de finantare
    if (hasRetirement || hasCredits) {
      message += 'Pentru refinanțare, vă rog să aveți la dumneavoastră următoarele documente:\n';
      
      // Documente pentru pensionari
      if (hasRetirement) {
        message += 'Decizia de pensionare (în original)\n';
        message += 'Ultimul cupon de pensie\n';
      }
      
      // Documente pentru credite existente
      if (hasCredits) {
        final totalCredits = creditInfo['totalCredits'] as int;
        if (totalCredits == 1) {
          message += 'Contractul de credit (în format fizic sau electronic)\n';
        } else {
          message += 'Contractele de credit (în format fizic sau electronic)\n';
        }
        
        // Adauga adresa de refinantare pentru banci specifice
        for (final bank in banks) {
          final refinanceAddress = _getRefinanceAddress(bank);
          if (refinanceAddress.isNotEmpty) {
            message += 'Adresa de refinanțare $refinanceAddress\n';
          }
        }
      }
      
      // Cartea de identitate este mereu necesara
      message += 'Carte de identitate';
    } else {
      // Pentru finantare noua (fara pensie si fara credite)
      message += 'Pentru finanțare, vă rog să aveți la dumneavoastră următoarele documente:\n';
      message += 'Carte de identitate';
    }
    
    // Inchide mesajul
    message += '\n\nVă aștept la întâlnire. Zi frumoasă!';
    
    return message;
  }

  /// Obtine adresa de refinantare pentru o banca specifica
  String _getRefinanceAddress(String bank) {
    switch (bank.toLowerCase()) {
      case 'tbi bank':
      case 'tbi':
        return 'TBI';
      case 'bcr':
        return 'BCR';
      case 'brd':
        return 'BRD';
      case 'bt':
      case 'banca transilvania':
        return 'BT';
      case 'ing bank':
      case 'ing':
        return 'ING';
      case 'raiffeisen bank':
      case 'raiffeisen':
        return 'Raiffeisen';
      case 'unicredit':
      case 'uni credit':
        return 'UniCredit';
      case 'cec bank':
      case 'cec':
        return 'CEC';
      case 'alpha bank':
      case 'alpha':
        return 'Alpha Bank';
      default:
        return bank; // Returneaza numele bancii daca nu e in lista
    }
  }

  /// Obtine luna in romana
  String _getMonthInRomanian(int month) {
    switch (month) {
      case 1:
        return 'ianuarie';
      case 2:
        return 'februarie';
      case 3:
        return 'martie';
      case 4:
        return 'aprilie';
      case 5:
        return 'mai';
      case 6:
        return 'iunie';
      case 7:
        return 'iulie';
      case 8:
        return 'august';
      case 9:
        return 'septembrie';
      case 10:
        return 'octombrie';
      case 11:
        return 'noiembrie';
      case 12:
        return 'decembrie';
      default:
        return '';
    }
  }

  /// Obtine ziua saptamanii in romana
  String _getDayOfWeekInRomanian(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Luni';
      case DateTime.tuesday:
        return 'Marți';
      case DateTime.wednesday:
        return 'Miercuri';
      case DateTime.thursday:
        return 'Joi';
      case DateTime.friday:
        return 'Vineri';
      case DateTime.saturday:
        return 'Sâmbătă';
      case DateTime.sunday:
        return 'Duminică';
      default:
        return '';
    }
  }

  /// Normalizeaza un numar de telefon pentru comparare
  String _normalizePhoneNumber(String phone) {
    if (phone.isEmpty) return '';
    
    // Remove all non-digit characters
    String normalized = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Remove leading country codes (Romania: +40 or 0040)
    if (normalized.startsWith('40') && normalized.length >= 10) {
      normalized = normalized.substring(2);
    }
    
    // Remove leading 0 if present
    if (normalized.startsWith('0') && normalized.length > 9) {
      normalized = normalized.substring(1);
    }
    
    // Ensure we have at least 9 digits for Romanian mobile numbers
    if (normalized.length >= 9) {
      return normalized;
    }
    
    return phone; // Return original if normalization fails
  }
  
  /// Normalizeaza text pentru comparare (lowercase, trim, remove diacritics)
  String _normalizeText(String text) {
    if (text.isEmpty) return '';
    
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ') // Replace multiple spaces with single space
        .replaceAll('ă', 'a')
        .replaceAll('â', 'a')
        .replaceAll('î', 'i')
        .replaceAll('ș', 's')
        .replaceAll('ț', 't')
        .replaceAll('ş', 's')
        .replaceAll('ţ', 't');
  }

  /// Returneaza un mesaj generic in caz de eroare
  String _getGenericMessage() {
    return '''Bună ziua!
Conform discuției telefonice, rămâne stabilită întâlnirea. Biroul nostru se află pe *Bulevardul Iuliu Maniu, nr. 7*. Vă rog să mă sunați când ajungeți pentru a vă prelua.
Pentru finanțare, vă rog să aveți la dumneavoastră următoarele documente:
Carte de identitate

Vă aștept la întâlnire. Zi frumoasă!''';
  }
}