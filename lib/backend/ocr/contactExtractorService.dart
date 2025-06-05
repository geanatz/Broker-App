import 'package:flutter/foundation.dart';
import '../models/unified_client_model.dart';

/// Service pentru extragerea contactelor din textul OCR
class ContactExtractorService {
  /// Singleton instance
  static final ContactExtractorService _instance = ContactExtractorService._internal();
  factory ContactExtractorService() => _instance;
  ContactExtractorService._internal();

  /// Extrage contactele din textul OCR
  Future<List<UnifiedClientModel>> extractContactsFromText(String ocrText, String imagePath) async {
    try {
      debugPrint('📞 Începe extragerea contactelor din text OCR...');
      
      final contacts = <UnifiedClientModel>[];
      final lines = ocrText.split('\n');
      
      String? currentName;
      String? currentPhone;
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        // Detectează numărul de telefon
        final phoneNumber = _extractPhoneNumber(line);
        if (phoneNumber != null) {
          // Caută numele înainte de numărul de telefon
          if (currentName != null) {
            // Avem deja un nume pentru acest număr
            final contact = _createContact(currentName, phoneNumber, imagePath);
            if (contact != null) {
              contacts.add(contact);
            }
            currentName = null;
          } else {
            // Caută numele în linia precedentă
            if (i > 0) {
              final previousLine = lines[i - 1].trim();
              if (_isPotentialName(previousLine)) {
                final contact = _createContact(previousLine, phoneNumber, imagePath);
                if (contact != null) {
                  contacts.add(contact);
                }
              }
            }
          }
        } else {
          // Ar putea fi un nume
          if (_isPotentialName(line)) {
            currentName = line;
          }
        }
      }
      
      debugPrint('✅ Extrase ${contacts.length} contacte din text');
      return contacts;
    } catch (e) {
      debugPrint('❌ Eroare la extragerea contactelor: $e');
      return [];
    }
  }

  /// Extrage numărul de telefon dintr-o linie de text
  String? _extractPhoneNumber(String line) {
    // Pattern pentru numărul de telefon românesc
    final phonePatterns = [
      RegExp(r'\b(\+40|0040|40)?[\s\-\.]*[0-9]{2,3}[\s\-\.]*[0-9]{3}[\s\-\.]*[0-9]{3}\b'),
      RegExp(r'\b0[0-9]{3}[\s\-\.]*[0-9]{3}[\s\-\.]*[0-9]{3}\b'),
      RegExp(r'\b(\+40|0040)[\s\-\.]*[0-9]{9}\b'),
      RegExp(r'\b[0-9]{10}\b'),
    ];
    
    for (final pattern in phonePatterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        String phone = match.group(0)!;
        // Curăță numărul de telefon
        phone = phone.replaceAll(RegExp(r'[\s\-\.]'), '');
        
        // Standardizează formatul
        if (phone.startsWith('0040')) {
          phone = '+40${phone.substring(4)}';
        } else if (phone.startsWith('40')) {
          phone = '+40${phone.substring(2)}';
        } else if (phone.startsWith('0') && phone.length == 10) {
          phone = '+40${phone.substring(1)}';
        } else if (!phone.startsWith('+40') && phone.length == 9) {
          phone = '+40$phone';
        }
        
        return phone;
      }
    }
    
    return null;
  }

  /// Verifică dacă o linie ar putea fi un nume
  bool _isPotentialName(String line) {
    // Ignoră liniile prea scurte sau prea lungi
    if (line.length < 2 || line.length > 50) return false;
    
    // Ignoră liniile care conțin doar numere
    if (RegExp(r'^[0-9\s\-\.]+$').hasMatch(line)) return false;
    
    // Ignoră liniile care conțin prea multe caractere speciale
    final specialChars = RegExp(r'[^a-zA-ZăâîșțĂÂÎȘȚ\s\-\.]').allMatches(line).length;
    if (specialChars > line.length / 3) return false;
    
    // Verifică dacă conține cel puțin o literă
    if (!RegExp(r'[a-zA-ZăâîșțĂÂÎȘȚ]').hasMatch(line)) return false;
    
    return true;
  }

  /// Creează un contact din nume și numărul de telefon
  UnifiedClientModel? _createContact(String name, String phone, String imagePath) {
    try {
      // Curăță numele
      name = name.trim();
      phone = phone.trim();
      
      if (name.isEmpty || phone.isEmpty) return null;
      
      // Creez cu toate câmpurile necesare pentru UnifiedClientModel
      return UnifiedClientModel(
        id: '', // Va fi generat la salvare
        consultantId: '', // Va fi setat la salvare
        basicInfo: ClientBasicInfo(
          name: name,
          phoneNumber: phone,
        ),
        formData: const ClientFormData(
          clientCredits: [],
          coDebitorCredits: [],
          clientIncomes: [],
          coDebitorIncomes: [],
          additionalData: {},
        ),
        activities: [],
        currentStatus: const ClientStatus(
          category: ClientCategory.apeluri,
          isFocused: false,
        ),
        metadata: ClientMetadata(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: '', // Va fi setat la salvare
          source: 'OCR', // Marchează că provine din OCR
          version: 1,
        ),
      );
    } catch (e) {
      debugPrint('❌ Eroare la crearea contactului: $e');
      return null;
    }
  }

  /// Procesează multiple imagini și extrage contactele
  Future<Map<String, List<UnifiedClientModel>>> extractContactsFromMultipleTexts(
    Map<String, String> imageTexts
  ) async {
    final results = <String, List<UnifiedClientModel>>{};
    
    for (final entry in imageTexts.entries) {
      final imagePath = entry.key;
      final ocrText = entry.value;
      
      debugPrint('🔄 Procesează imaginea: $imagePath');
      final contacts = await extractContactsFromText(ocrText, imagePath);
      results[imagePath] = contacts;
      
      // Adaugă un delay scurt pentru a nu supraîncărca procesul
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    return results;
  }
} 