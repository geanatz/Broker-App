import 'package:flutter/foundation.dart';
import '../services/clients_service.dart';

/// Service pentru parsarea contactelor din textul extras prin OCR
/// Detecteaza nume si numere de telefon romanesti cu algoritmi robusti
class ParserOcr {
  /// Singleton instance
  static final ParserOcr _instance = ParserOcr._internal();
  factory ParserOcr() => _instance;
  ParserOcr._internal();

  /// Extrage contactele din textul filtrat
  Future<List<UnifiedClientModel>> parseContactsFromText(String text, String sourcePath) async {
    debugPrint('📝 [ParserOcr] Incepe parsarea contactelor...');
    debugPrint('📝 [ParserOcr] Text de analizat: ${text.length} caractere');

    try {
      // 1. Imparte textul in linii pentru analiza
      final lines = text.split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      debugPrint('📄 [ParserOcr] Linii de analizat: ${lines.length}');

      // 2. Detecteaza toate numerele de telefon
      final phones = _detectPhoneNumbers(lines);
      debugPrint('📞 [ParserOcr] Telefoane detectate: ${phones.length}');

      // 3. Detecteaza toate numele
      final names = _detectNames(lines);
      debugPrint('👤 [ParserOcr] Nume detectate: ${names.length}');

      // 4. Asociaza numele cu telefoanele
      final contacts = _associateNamesWithPhones(names, phones, lines);
      debugPrint('🔗 [ParserOcr] Contacte create: ${contacts.length}');

      // 5. Converteste la UnifiedClientModel
      final unifiedContacts = _convertToUnifiedModels(contacts, sourcePath);
      
      debugPrint('✅ [ParserOcr] Parsare finalizata: ${unifiedContacts.length} clienti');
      
      return unifiedContacts;

    } catch (e) {
      debugPrint('❌ [ParserOcr] Eroare la parsare: $e');
      return [];
    }
  }

  /// Detecteaza numerele de telefon in text
  List<PhoneDetection> _detectPhoneNumbers(List<String> lines) {
    final phones = <PhoneDetection>[];
    
    // Regex-uri pentru diferite formate de telefon romanesc
    final phonePatterns = [
      // Format: +40 XXX XXX XXX
      RegExp(r'\+40\s*[0-9]\s*[0-9]{2}\s*[0-9]{3}\s*[0-9]{3}'),
      // Format: 0XXX XXX XXX sau 0XXX.XXX.XXX (standard 10 cifre)
      RegExp(r'0[0-9]\s*[0-9]{2}[\s\.]?[0-9]{3}[\s\.]?[0-9]{3}'),
      // Format: 0XXX XXX XX (incomplet - 9 cifre)
      RegExp(r'0[0-9]\s*[0-9]{2}[\s\.]?[0-9]{3}[\s\.]?[0-9]{2}(?!\d)'),
      // Format: XXX XXX XXX (fara prefix)
      RegExp(r'[0-9]{3}[\s\.]?[0-9]{3}[\s\.]?[0-9]{3}'),
      // Format compact: 0XXXXXXXXX
      RegExp(r'0[0-9]{9}'),
      // Format compact incomplet: 0XXXXXXXX (9 cifre)
      RegExp(r'0[0-9]{8}(?!\d)'),
    ];

    debugPrint('📝 [ParserOcr] Analizez ${lines.length} linii pentru telefoane');

    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      debugPrint('📄 [ParserOcr] Linia $lineIndex: "$line"');
      
      for (int patternIndex = 0; patternIndex < phonePatterns.length; patternIndex++) {
        final pattern = phonePatterns[patternIndex];
        final matches = pattern.allMatches(line);
        
        for (final match in matches) {
          final rawPhone = match.group(0)!;
          final cleanPhone = _cleanPhoneNumber(rawPhone);
          
          debugPrint('🔍 [ParserOcr] Pattern $patternIndex gasit: "$rawPhone" -> curatat: "$cleanPhone"');
          
          // Valideaza ca e un numar de telefon valid (inclusiv incomplete)
          if (_isValidPhoneNumber(cleanPhone)) {
            // Verifica daca nu este deja in lista (evita duplicatele)
            final existingPhone = phones.where((p) => p.number == cleanPhone).firstOrNull;
            if (existingPhone == null) {
              phones.add(PhoneDetection(
                number: cleanPhone,
                lineIndex: lineIndex,
                position: match.start,
                raw: rawPhone,
              ));
              
              debugPrint('✅ [ParserOcr] Telefon valid adaugat: $cleanPhone (linia $lineIndex, pozitia ${match.start})');
            } else {
              debugPrint('⚠️ [ParserOcr] Telefon duplicat ignorat: $cleanPhone');
            }
          } else {
            debugPrint('❌ [ParserOcr] Telefon invalid ignorat: $cleanPhone (raw: $rawPhone)');
          }
        }
      }
    }

    debugPrint('📞 [ParserOcr] Total telefoane detectate: ${phones.length}');
    for (final phone in phones) {
      debugPrint('   -> ${phone.number} (linia ${phone.lineIndex}, pozitia ${phone.position})');
    }

    return phones;
  }

  /// Detecteaza numele in text
  List<NameDetection> _detectNames(List<String> lines) {
    final names = <NameDetection>[];
    
    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      
      // Cauta nume (2-3 cuvinte care incep cu majuscula)
      final namePattern = RegExp(r'\b[A-ZAAISTCFGHJKLMNPQRVWXYZ][a-zaaistcfghjklmnpqrvwxyz]+(?:\s+[A-ZAAISTCFGHJKLMNPQRVWXYZ][a-zaaistcfghjklmnpqrvwxyz]+){1,2}\b');
      final matches = namePattern.allMatches(line);
      
      for (final match in matches) {
        final name = match.group(0)!.trim();
        
        // Valideaza ca e un nume valid
        if (_isValidName(name)) {
          names.add(NameDetection(
            name: name,
            lineIndex: lineIndex,
            position: match.start,
          ));
          
          debugPrint('👤 [ParserOcr] Nume gasit: $name (linia $lineIndex)');
        }
      }
    }

    return names;
  }

  /// Asociaza numele cu telefoanele pe baza proximitatii
  List<ContactDetection> _associateNamesWithPhones(
    List<NameDetection> names, 
    List<PhoneDetection> phones, 
    List<String> lines
  ) {
    final contacts = <ContactDetection>[];
    final usedPhones = <PhoneDetection>{};

    debugPrint('🔗 [ParserOcr] Incepe asocierea: ${names.length} nume cu ${phones.length} telefoane');

    // Pentru fiecare nume, cauta pana la 2 telefoane apropiate
    for (final name in names) {
      final nearbyPhones = <PhoneDetection>[];
      
      debugPrint('👤 [ParserOcr] Procesez numele: ${name.name} (linia ${name.lineIndex}, pozitia ${name.position})');
      
      // Gaseste toate telefoanele din proximitate
      for (final phone in phones) {
        if (usedPhones.contains(phone)) {
          debugPrint('   📞 Telefon deja folosit: ${phone.number}');
          continue;
        }

        // Calculeaza distanta intre nume si telefon
        int distance;
        
        if (name.lineIndex == phone.lineIndex) {
          // Sunt pe aceeasi linie - distanta e diferenta de pozitie
          distance = (name.position - phone.position).abs();
        } else {
          // Sunt pe linii diferite - distanta e diferenta de linii * 1000 + pozitia
          distance = (name.lineIndex - phone.lineIndex).abs() * 1000 + 
                    (name.position + phone.position);
        }

        debugPrint('   📞 Evaluez telefon: ${phone.number} (linia ${phone.lineIndex}, pozitia ${phone.position}) - distanta: $distance');

        // Adauga telefoanele care sunt aproape (max 3 linii diferenta)
        if (distance < 3000) {
          nearbyPhones.add(phone);
          debugPrint('   ✅ Telefon aproape: ${phone.number}');
        } else {
          debugPrint('   ❌ Telefon prea departe: ${phone.number}');
        }
      }

      debugPrint('   🎯 Telefoane apropiate gasite: ${nearbyPhones.length}');

      // Sorteaza telefoanele dupa distanta si ia primele 2
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

      // Ia primele 2 telefoane (daca exista) si completeaza numerele incomplete
      final phone1 = nearbyPhones.isNotEmpty ? nearbyPhones[0] : null;
      final phone2 = nearbyPhones.length >= 2 ? nearbyPhones[1] : null;

      if (phone1 != null) {
        // Completeaza numerele incomplete la 10 cifre
        String finalPhone1 = _completePhoneNumber(phone1.number);
        String? finalPhone2 = phone2 != null ? _completePhoneNumber(phone2.number) : null;

        contacts.add(ContactDetection(
          name: name.name,
          phone1: finalPhone1,
          phone2: finalPhone2,
          confidence: _calculateConfidence(0), // Recalculeaza daca e nevoie
        ));
        
        usedPhones.add(phone1);
        if (phone2 != null) {
          usedPhones.add(phone2);
        }
        
        debugPrint('✅ [ParserOcr] Asociere finalizata: ${name.name} -> $finalPhone1${finalPhone2 != null ? ' + $finalPhone2' : ''}');
      } else {
        debugPrint('❌ [ParserOcr] Nume fara telefoane: ${name.name}');
      }
    }

    // Adauga telefoanele ramase fara nume (grupate cate 2)
    final unusedPhones = phones.where((phone) => !usedPhones.contains(phone)).toList();
    for (int i = 0; i < unusedPhones.length; i += 2) {
      final phone1 = unusedPhones[i];
      final phone2 = i + 1 < unusedPhones.length ? unusedPhones[i + 1] : null;
      
      contacts.add(ContactDetection(
        name: 'Contact ${phone1.number}',
        phone1: phone1.number,
        phone2: phone2?.number,
        confidence: 0.5, // Confidence mai mic pentru telefoanele fara nume
      ));
      
      debugPrint('📞 [ParserOcr] Telefon(oane) fara nume: ${phone1.number}${phone2 != null ? ' + ${phone2.number}' : ''}');
    }

    return contacts;
  }

  /// Converteste contactele la UnifiedClientModel
  List<UnifiedClientModel> _convertToUnifiedModels(
    List<ContactDetection> contacts, 
    String sourcePath
  ) {
    final models = <UnifiedClientModel>[];
    
    debugPrint('🔄 [ParserOcr] Convertesc ${contacts.length} contacte la UnifiedClientModel');
    
    for (int i = 0; i < contacts.length; i++) {
      final contact = contacts[i];
      
      debugPrint('🔄 [ParserOcr] Contact $i: ${contact.name} -> telefon1: "${contact.phone1}", telefon2: "${contact.phone2}"');
      
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

  /// Curata numarul de telefon
  String _cleanPhoneNumber(String rawPhone) {
    // Elimina toate spatiile, punctele si liniutele
    String clean = rawPhone.replaceAll(RegExp(r'[\s\.\-\(\)]'), '');
    
    // Converteste +40 la 0
    if (clean.startsWith('+40')) {
      clean = '0${clean.substring(3)}';
    }
    
    // Asigura-te ca incepe cu 0 pentru numerele de 9 cifre
    if (!clean.startsWith('0') && clean.length == 9) {
      clean = '0$clean';
    }
    
    // Pentru numerele incomplete de 8 cifre, adauga un 0 la inceput daca nu are
    if (!clean.startsWith('0') && clean.length == 8) {
      clean = '0$clean';
    }
    
    return clean;
  }

  /// Valideaza daca e un numar de telefon valid
  bool _isValidPhoneNumber(String phone) {
    // Accepta numere cu 9 sau 10 cifre care incep cu 0
    if ((phone.length != 9 && phone.length != 10) || !phone.startsWith('0')) {
      return false;
    }
    
    // Al doilea digit trebuie sa fie intre 2-9 (prefixuri valide in Romania)
    if (phone.length >= 2) {
      final secondDigit = int.tryParse(phone[1]);
      if (secondDigit == null || secondDigit < 2 || secondDigit > 9) {
        return false;
      }
    }
    
    // Verifica ca sunt doar cifre
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      return false;
    }
    
    // Pentru numerele de 9 cifre, completeaza cu 0 la sfarsit pentru a face 10 cifre
    return true;
  }

  /// Completeaza numerele de telefon incomplete la 10 cifre
  String _completePhoneNumber(String phone) {
    // Daca numarul are doar 9 cifre, adauga un 0 la sfarsit
    if (phone.length == 9 && phone.startsWith('0')) {
      final completed = '${phone}0';
      debugPrint('📞 [ParserOcr] Completez numarul incomplet: $phone -> $completed');
      return completed;
    }
    
    // Daca numarul are deja 10 cifre, il returnez ca atare
    return phone;
  }

  /// Valideaza daca e un nume valid
  bool _isValidName(String name) {
    final words = name.split(' ');
    
    // Trebuie sa aiba intre 2 si 3 cuvinte
    if (words.length < 2 || words.length > 3) {
      return false;
    }
    
    // Fiecare cuvant trebuie sa aiba cel putin 2 caractere
    for (final word in words) {
      if (word.length < 2) {
        return false;
      }
    }
    
    // Nu trebuie sa contina cifre
    if (RegExp(r'[0-9]').hasMatch(name)) {
      return false;
    }
    
    // Nu trebuie sa fie cuvinte comune
    final commonWords = ['CLIENT', 'NUME', 'TELEFON', 'CONTACT', 'ADRESA', 'EMAIL'];
    final upperName = name.toUpperCase();
    
    for (final word in commonWords) {
      if (upperName.contains(word)) {
        return false;
      }
    }
    
    return true;
  }

  /// Calculeaza increderea pe baza distantei
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

/// Telefon detectat in text
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

/// Nume detectat in text
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

/// Contact detectat (nume + pana la 2 telefoane)
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
