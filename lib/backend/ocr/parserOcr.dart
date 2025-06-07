import 'package:flutter/foundation.dart';
import '../services/clientsService.dart';

/// Service pentru parsarea contactelor din textul extras prin OCR
/// Detectează nume și numere de telefon românești cu algoritmi robusti
class ParserOcr {
  /// Singleton instance
  static final ParserOcr _instance = ParserOcr._internal();
  factory ParserOcr() => _instance;
  ParserOcr._internal();

  /// Extrage contactele din textul filtrat
  Future<List<UnifiedClientModel>> parseContactsFromText(String text, String sourcePath) async {
    debugPrint('📝 [ParserOcr] Începe parsarea contactelor...');
    debugPrint('📝 [ParserOcr] Text de analizat: ${text.length} caractere');

    try {
      // 1. Împarte textul în linii pentru analiză
      final lines = text.split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      debugPrint('📄 [ParserOcr] Linii de analizat: ${lines.length}');

      // 2. Detectează toate numerele de telefon
      final phones = _detectPhoneNumbers(lines);
      debugPrint('📞 [ParserOcr] Telefoane detectate: ${phones.length}');

      // 3. Detectează toate numele
      final names = _detectNames(lines);
      debugPrint('👤 [ParserOcr] Nume detectate: ${names.length}');

      // 4. Asociază numele cu telefoanele
      final contacts = _associateNamesWithPhones(names, phones, lines);
      debugPrint('🔗 [ParserOcr] Contacte create: ${contacts.length}');

      // 5. Convertește la UnifiedClientModel
      final unifiedContacts = _convertToUnifiedModels(contacts, sourcePath);
      
      debugPrint('✅ [ParserOcr] Parsare finalizată: ${unifiedContacts.length} clienți');
      
      return unifiedContacts;

    } catch (e) {
      debugPrint('❌ [ParserOcr] Eroare la parsare: $e');
      return [];
    }
  }

  /// Detectează numerele de telefon în text
  List<PhoneDetection> _detectPhoneNumbers(List<String> lines) {
    final phones = <PhoneDetection>[];
    
    // Regex-uri pentru diferite formate de telefon românesc
    final phonePatterns = [
      // Format: +40 XXX XXX XXX
      RegExp(r'\+40\s*[0-9]\s*[0-9]{2}\s*[0-9]{3}\s*[0-9]{3}'),
      // Format: 0XXX XXX XXX sau 0XXX.XXX.XXX
      RegExp(r'0[0-9]\s*[0-9]{2}[\s\.]?[0-9]{3}[\s\.]?[0-9]{3}'),
      // Format: XXX XXX XXX (fără prefix)
      RegExp(r'[0-9]{3}[\s\.]?[0-9]{3}[\s\.]?[0-9]{3}'),
      // Format compact: 0XXXXXXXXX
      RegExp(r'0[0-9]{9}'),
    ];

    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      
      for (final pattern in phonePatterns) {
        final matches = pattern.allMatches(line);
        
        for (final match in matches) {
          final rawPhone = match.group(0)!;
          final cleanPhone = _cleanPhoneNumber(rawPhone);
          
          // Validează că e un număr de telefon valid
          if (_isValidPhoneNumber(cleanPhone)) {
            phones.add(PhoneDetection(
              number: cleanPhone,
              lineIndex: lineIndex,
              position: match.start,
              raw: rawPhone,
            ));
            
            debugPrint('📞 [ParserOcr] Telefon găsit: $cleanPhone (linia $lineIndex)');
          }
        }
      }
    }

    return phones;
  }

  /// Detectează numele în text
  List<NameDetection> _detectNames(List<String> lines) {
    final names = <NameDetection>[];
    
    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      
      // Caută nume (2-3 cuvinte care încep cu majusculă)
      final namePattern = RegExp(r'\b[A-ZĂÂÎȘȚCFGHJKLMNPQRVWXYZ][a-zăâîșțcfghjklmnpqrvwxyz]+(?:\s+[A-ZĂÂÎȘȚCFGHJKLMNPQRVWXYZ][a-zăâîșțcfghjklmnpqrvwxyz]+){1,2}\b');
      final matches = namePattern.allMatches(line);
      
      for (final match in matches) {
        final name = match.group(0)!.trim();
        
        // Validează că e un nume valid
        if (_isValidName(name)) {
          names.add(NameDetection(
            name: name,
            lineIndex: lineIndex,
            position: match.start,
          ));
          
          debugPrint('👤 [ParserOcr] Nume găsit: $name (linia $lineIndex)');
        }
      }
    }

    return names;
  }

  /// Asociază numele cu telefoanele pe baza proximității
  List<ContactDetection> _associateNamesWithPhones(
    List<NameDetection> names, 
    List<PhoneDetection> phones, 
    List<String> lines
  ) {
    final contacts = <ContactDetection>[];
    final usedPhones = <PhoneDetection>{};

    // Pentru fiecare nume, caută până la 2 telefoane apropiate
    for (final name in names) {
      final nearbyPhones = <PhoneDetection>[];
      
      // Găsește toate telefoanele din proximitate
      for (final phone in phones) {
        if (usedPhones.contains(phone)) continue;

        // Calculează distanța între nume și telefon
        int distance;
        
        if (name.lineIndex == phone.lineIndex) {
          // Sunt pe aceeași linie - distanța e diferența de poziție
          distance = (name.position - phone.position).abs();
        } else {
          // Sunt pe linii diferite - distanța e diferența de linii * 1000 + poziția
          distance = (name.lineIndex - phone.lineIndex).abs() * 1000 + 
                    (name.position + phone.position);
        }

        // Adaugă telefoanele care sunt aproape (max 3 linii diferență)
        if (distance < 3000) {
          nearbyPhones.add(phone);
        }
      }

      // Sortează telefoanele după distanță și ia primele 2
      nearbyPhones.sort((a, b) {
        int distanceA, distanceB;
        
        if (name.lineIndex == a.lineIndex) {
          distanceA = (name.position - a.position).abs();
        } else {
          distanceA = (name.lineIndex - a.lineIndex).abs() * 1000 + (name.position + a.position);
        }
        
        if (name.lineIndex == b.lineIndex) {
          distanceB = (name.position - b.position).abs();
        } else {
          distanceB = (name.lineIndex - b.lineIndex).abs() * 1000 + (name.position + b.position);
        }
        
        return distanceA.compareTo(distanceB);
      });

      // Ia primele 2 telefoane (dacă există)
      final phone1 = nearbyPhones.isNotEmpty ? nearbyPhones[0] : null;
      final phone2 = nearbyPhones.length >= 2 ? nearbyPhones[1] : null;

      if (phone1 != null) {
        contacts.add(ContactDetection(
          name: name.name,
          phone1: phone1.number,
          phone2: phone2?.number,
          confidence: _calculateConfidence(0), // Recalculează dacă e nevoie
        ));
        
        usedPhones.add(phone1);
        if (phone2 != null) {
          usedPhones.add(phone2);
        }
        
        debugPrint('🔗 [ParserOcr] Asociere: ${name.name} -> ${phone1.number}${phone2 != null ? ' + ${phone2.number}' : ''}');
      }
    }

    // Adaugă telefoanele rămase fără nume (grupate câte 2)
    final unusedPhones = phones.where((phone) => !usedPhones.contains(phone)).toList();
    for (int i = 0; i < unusedPhones.length; i += 2) {
      final phone1 = unusedPhones[i];
      final phone2 = i + 1 < unusedPhones.length ? unusedPhones[i + 1] : null;
      
      contacts.add(ContactDetection(
        name: 'Contact ${phone1.number}',
        phone1: phone1.number,
        phone2: phone2?.number,
        confidence: 0.5, // Confidence mai mic pentru telefoanele fără nume
      ));
      
      debugPrint('📞 [ParserOcr] Telefon(oane) fără nume: ${phone1.number}${phone2 != null ? ' + ${phone2.number}' : ''}');
    }

    return contacts;
  }

  /// Convertește contactele la UnifiedClientModel
  List<UnifiedClientModel> _convertToUnifiedModels(
    List<ContactDetection> contacts, 
    String sourcePath
  ) {
    final models = <UnifiedClientModel>[];
    
    for (int i = 0; i < contacts.length; i++) {
      final contact = contacts[i];
      
      final model = UnifiedClientModel(
        id: 'ocr_${DateTime.now().millisecondsSinceEpoch}_$i',
        consultantId: 'local',
        basicInfo: ClientBasicInfo(
          name: contact.name,
          phoneNumber1: contact.phone1,
          phoneNumber2: contact.phone2,
        ),
        formData: const ClientFormData(
          clientCredits: [],
          coDebitorCredits: [],
          clientIncomes: [],
          coDebitorIncomes: [],
          additionalData: {},
        ),
        activities: [],
        currentStatus: const UnifiedClientStatus(
          category: UnifiedClientCategory.apeluri,
          isFocused: false,
          additionalInfo: 'Extras prin OCR',
        ),
                 metadata: ClientMetadata(
           createdAt: DateTime.now(),
           updatedAt: DateTime.now(),
           createdBy: 'ocr_system',
           source: 'ocr_extraction',
           version: 1,
         ),
      );
      
      models.add(model);
    }
    
    return models;
  }

  /// Curăță numărul de telefon
  String _cleanPhoneNumber(String rawPhone) {
    // Elimină toate spațiile, punctele și liniuțele
    String clean = rawPhone.replaceAll(RegExp(r'[\s\.\-\(\)]'), '');
    
    // Convertește +40 la 0
    if (clean.startsWith('+40')) {
      clean = '0${clean.substring(3)}';
    }
    
    // Asigură-te că începe cu 0 și are 10 cifre
    if (!clean.startsWith('0') && clean.length == 9) {
      clean = '0$clean';
    }
    
    return clean;
  }

  /// Validează dacă e un număr de telefon valid
  bool _isValidPhoneNumber(String phone) {
    // Trebuie să aibă exact 10 cifre și să înceapă cu 0
    if (phone.length != 10 || !phone.startsWith('0')) {
      return false;
    }
    
    // Al doilea digit trebuie să fie între 2-9 (prefixuri valide în România)
    if (phone.length >= 2) {
      final secondDigit = int.tryParse(phone[1]);
      if (secondDigit == null || secondDigit < 2 || secondDigit > 9) {
        return false;
      }
    }
    
    // Verifică că sunt doar cifre
    return RegExp(r'^[0-9]+$').hasMatch(phone);
  }

  /// Validează dacă e un nume valid
  bool _isValidName(String name) {
    final words = name.split(' ');
    
    // Trebuie să aibă între 2 și 3 cuvinte
    if (words.length < 2 || words.length > 3) {
      return false;
    }
    
    // Fiecare cuvânt trebuie să aibă cel puțin 2 caractere
    for (final word in words) {
      if (word.length < 2) {
        return false;
      }
    }
    
    // Nu trebuie să conțină cifre
    if (RegExp(r'[0-9]').hasMatch(name)) {
      return false;
    }
    
    // Nu trebuie să fie cuvinte comune
    final commonWords = ['CLIENT', 'NUME', 'TELEFON', 'CONTACT', 'ADRESA', 'EMAIL'];
    final upperName = name.toUpperCase();
    
    for (final word in commonWords) {
      if (upperName.contains(word)) {
        return false;
      }
    }
    
    return true;
  }

  /// Calculează încrederea pe baza distanței
  double _calculateConfidence(int distance) {
    if (distance == 0) return 1.0;
    if (distance < 50) return 0.9;
    if (distance < 100) return 0.8;
    if (distance < 200) return 0.7;
    if (distance < 500) return 0.6;
    if (distance < 1000) return 0.5;
    if (distance < 2000) return 0.4;
    return 0.3;
  }
}

/// Telefon detectat în text
class PhoneDetection {
  final String number;
  final int lineIndex;
  final int position;
  final String raw;

  const PhoneDetection({
    required this.number,
    required this.lineIndex,
    required this.position,
    required this.raw,
  });
}

/// Nume detectat în text
class NameDetection {
  final String name;
  final int lineIndex;
  final int position;

  const NameDetection({
    required this.name,
    required this.lineIndex,
    required this.position,
  });
}

/// Contact detectat (nume + până la 2 telefoane)
class ContactDetection {
  final String name;
  final String phone1;
  final String? phone2;
  final double confidence;

  const ContactDetection({
    required this.name,
    required this.phone1,
    this.phone2,
    required this.confidence,
  });

  /// Pentru compatibilitate cu codul existent
  String get phone => phone1;
}
