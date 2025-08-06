import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:broker_app/backend/services/clients_service.dart';

/// Parser inteligent pentru extragerea contactelor din textul OCR
class ParserOCR {
  static final ParserOCR _instance = ParserOCR._internal();
  factory ParserOCR() => _instance;
  ParserOCR._internal();

  // Cache pentru numele romanesti
  Set<String>? _romanianNames;
  
  // Expresii regulate pentru detectarea informatiilor - DOAR numere COMPLETE (fara word boundaries pentru text concatenat)
  static final _phoneRegex = RegExp(r'(?:07[0-9]{8}|0[2-6][0-9]{8}|\+407[0-9]{8}|\+40[2-6][0-9]{8})');
  static final _cnpRegex = RegExp(r'\b[1-8]\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{6}\b');
  static final _nameRegex = RegExp(r'^[A-ZAAIST][a-zaaist]+(?:\s+[A-ZAAIST][a-zaaist]+)+$');
  
  /// Incarca baza de date cu nume romanesti
  Future<void> _loadRomanianNames() async {
    if (_romanianNames != null) return;
    
    try {
      final jsonString = await rootBundle.loadString('lib/backend/ocr/names.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;
      
      final names = <String>{};
      if (data['names'] is List) {
        names.addAll((data['names'] as List).cast<String>());
      }
      if (data['prenume'] is List) {
        names.addAll((data['prenume'] as List).cast<String>());
      }
      if (data['nume'] is List) {
        names.addAll((data['nume'] as List).cast<String>());
      }
      
      _romanianNames = names;
      debugPrint('✅ PARSER_OCR: Incarcate ${names.length} nume romanesti');
    } catch (e) {
      debugPrint('❌ PARSER_OCR: Eroare la incarcarea numelor: $e');
      _romanianNames = <String>{}; // Set gol pentru a evita incarcarea repetata
    }
  }

  /// Extrage contacte din textul OCR
  Future<List<UnifiedClientModel>> extractContacts(String text) async {
    await _loadRomanianNames();
    
    try {
      debugPrint('🔍 PARSER_OCR: Analizare text de ${text.length} caractere');
      
      // Preproceseaza textul
      final cleanText = _preprocessText(text);
      
      // Imparte textul in linii si blokuri
      final lines = cleanText.split('\n').where((line) => line.trim().isNotEmpty).toList();
      
      // Detecteaza structura documentului
      final documentType = _detectDocumentType(lines);
      debugPrint('📄 PARSER_OCR: Tip document detectat: $documentType');
      
      // Extrage contacte in functie de tipul documentului
      final contacts = await _extractContactsByType(lines, documentType);
      
      debugPrint('✅ PARSER_OCR: Extrase ${contacts.length} contacte');
      return contacts;

    } catch (e) {
      debugPrint('❌ PARSER_OCR: Eroare la extragerea contactelor: $e');
      return [];
    }
  }

  /// Preproceseaza textul pentru parsing mai bun
  String _preprocessText(String text) {
    var processed = text;
    
    debugPrint('🔧 PARSER_OCR: Text original: "${text.substring(0, text.length.clamp(0, 100))}..."');
    
    // Inlocuieste caractere speciale OCR
    processed = processed.replaceAll(RegExp(r'[|]'), 'I');
    processed = processed.replaceAll(RegExp(r'[°]'), '0');
    processed = processed.replaceAll(RegExp(r'[§]'), '5');
    
    // Standardizeaza spatiile
    processed = processed.replaceAll(RegExp(r'\s+'), ' ');
    
    // NU mai inlocuim spatiile! Pastram structura textului
    // processed = processed.replaceAll(RegExp(r'[-\s\.]+'), '');
    
    debugPrint('🔧 PARSER_OCR: Text procesat: "${processed.substring(0, processed.length.clamp(0, 100))}..."');
    return processed.trim();
  }

  /// Detecteaza tipul documentului
  DocumentType _detectDocumentType(List<String> lines) {
    final allText = lines.join(' ').toLowerCase();
    
    // Detecteaza tabel cu coloane
    final hasTableStructure = lines.any((line) {
      final parts = line.split(RegExp(r'\s{2,}'));
      return parts.length >= 3;
    });
    
    // Detecteaza lista cu bullet points
    final hasListStructure = lines.any((line) => 
      line.trimLeft().startsWith(RegExp(r'[•\-\*\d+\.]')));
    
    // Detecteaza formular structurat
    final hasFormStructure = allText.contains(RegExp(r'nume.*:.*telefon|telefon.*:.*nume'));
    
    if (hasTableStructure) return DocumentType.table;
    if (hasFormStructure) return DocumentType.form;
    if (hasListStructure) return DocumentType.list;
    
    return DocumentType.freeText;
  }

  /// Extrage contacte in functie de tipul documentului
  Future<List<UnifiedClientModel>> _extractContactsByType(List<String> lines, DocumentType type) async {
    switch (type) {
      case DocumentType.table:
        return await _extractFromTable(lines);
      case DocumentType.form:
        return await _extractFromForm(lines);
      case DocumentType.list:
        return await _extractFromList(lines);
      case DocumentType.freeText:
        return await _extractFromFreeText(lines);
    }
  }

  /// Extrage contacte din tabel
  Future<List<UnifiedClientModel>> _extractFromTable(List<String> lines) async {
    final contacts = <UnifiedClientModel>[];
    
    // Gaseste antetul tabelului
    int headerIndex = -1;
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toLowerCase();
      if (line.contains('nume') && line.contains('telefon')) {
        headerIndex = i;
        break;
      }
    }
    
    // Proceseaza randurile de date
    for (int i = headerIndex + 1; i < lines.length; i++) {
      final line = lines[i];
      final parts = line.split(RegExp(r'\s{2,}'));
      
      if (parts.length >= 2) {
        final contact = await _createContactFromParts(parts);
        if (contact != null) {
          contacts.add(contact);
        }
      }
    }
    
    return contacts;
  }

  /// Extrage contacte din formular structurat
  Future<List<UnifiedClientModel>> _extractFromForm(List<String> lines) async {
    final contacts = <UnifiedClientModel>[];
    String? currentName;
    String? currentPhone;
    String? currentPhone2;
    String? currentCNP;
    
    for (final line in lines) {
      final cleanLine = line.trim();
      
      // Detecteaza campuri nume
      if (cleanLine.toLowerCase().contains('nume')) {
        final nameMatch = RegExp(r'nume\s*:?\s*(.+)', caseSensitive: false).firstMatch(cleanLine);
        if (nameMatch != null) {
          currentName = _cleanName(nameMatch.group(1)!);
        }
      }
      
      // Detecteaza campuri telefon
      if (cleanLine.toLowerCase().contains('telefon')) {
        final phones = _extractPhones(cleanLine);
        if (phones.isNotEmpty) {
          currentPhone = phones.first;
          if (phones.length > 1) {
            currentPhone2 = phones[1];
          }
        }
      }
      
      // Detecteaza CNP
      final cnpMatch = _cnpRegex.firstMatch(cleanLine);
      if (cnpMatch != null) {
        currentCNP = cnpMatch.group(0);
      }
      
      // Creeaza contact cand avem informatii suficiente
      if (currentName != null && currentPhone != null) {
        final contact = await _createContact(
          name: currentName,
          phone1: currentPhone,
          phone2: currentPhone2,
          cnp: currentCNP,
        );
        
        if (contact != null) {
          contacts.add(contact);
        }
        
        // Reset pentru urmatorul contact
        currentName = null;
        currentPhone = null;
        currentPhone2 = null;
        currentCNP = null;
      }
    }
    
    return contacts;
  }

  /// Extrage contacte din lista
  Future<List<UnifiedClientModel>> _extractFromList(List<String> lines) async {
    final contacts = <UnifiedClientModel>[];
    
    for (final line in lines) {
      // Inlatura bullet points
      final cleanLine = line.replaceFirst(RegExp(r'^[\s\-\*•\d+\.]+'), '').trim();
      
      if (cleanLine.isEmpty) continue;
      
      // Incearca sa extraga nume si telefon din aceeasi linie
      final phones = _extractPhones(cleanLine);
      if (phones.isNotEmpty) {
        // Inlatura numerele de telefon pentru a gasi numele
        var nameCandidate = cleanLine;
        for (final phone in phones) {
          nameCandidate = nameCandidate.replaceAll(phone, '').trim();
        }
        
        final cleanName = _cleanName(nameCandidate);
        if (await _isValidName(cleanName)) {
          final contact = await _createContact(
            name: cleanName,
            phone1: phones.first,
            phone2: phones.length > 1 ? phones[1] : null,
          );
          
          if (contact != null) {
            contacts.add(contact);
          }
        }
      }
    }
    
    return contacts;
  }

  /// Extrage contacte din text liber
  Future<List<UnifiedClientModel>> _extractFromFreeText(List<String> lines) async {
    final contacts = <UnifiedClientModel>[];
    final allText = lines.join(' ');
    
    debugPrint('🔍 PARSER_OCR: Analizez text liber: "${allText.substring(0, allText.length.clamp(0, 200))}..."');
    
    // Prima strategie: incearca sa analizezi linie cu linie (pentru formate structurate)
    final lineContacts = await _extractFromStructuredLines(lines);
    if (lineContacts.isNotEmpty) {
      debugPrint('✅ PARSER_OCR: Folosesc metoda linie cu linie: ${lineContacts.length} contacte');
      return lineContacts;
    }
    
    // A doua strategie: analiza generala de text liber
    debugPrint('🔍 PARSER_OCR: Text complet pentru regex: "$allText"');
    final phoneMatches = _phoneRegex.allMatches(allText);
    final phones = phoneMatches.map((m) => m.group(0)!).toSet().toList();
    
    debugPrint('📞 PARSER_OCR: Regex pattern: ${_phoneRegex.pattern}');
    debugPrint('📞 PARSER_OCR: Gasite ${phones.length} numere de telefon: $phones');
    
    // Pentru fiecare telefon, incearca sa gasesti numele asociat
    for (final phone in phones) {
      debugPrint('🔍 PARSER_OCR: Caut nume pentru telefonul: $phone');
      final name = await _findNameNearPhone(allText, phone);
      if (name != null) {
        debugPrint('✅ PARSER_OCR: Gasit nume "$name" pentru telefonul $phone');
        final contact = await _createContact(
          name: name,
          phone1: phone,
        );
        
        if (contact != null) {
          contacts.add(contact);
          debugPrint('✅ PARSER_OCR: Contact creat cu succes: ${contact.basicInfo.name}');
        } else {
          debugPrint('❌ PARSER_OCR: Nu s-a putut crea contactul pentru "$name" - $phone');
        }
      } else {
        debugPrint('❌ PARSER_OCR: Nu s-a gasit nume pentru telefonul: $phone');
      }
    }
    
    return contacts;
  }

  /// Extrage contacte din linii structurate (nume telefon pe aceeasi linie sau linii consecutive)
  Future<List<UnifiedClientModel>> _extractFromStructuredLines(List<String> lines) async {
    final contacts = <UnifiedClientModel>[];
    
    debugPrint('🔍 PARSER_OCR: Analizez ${lines.length} linii structurate');
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmedLine = line.trim();
      debugPrint('🔍 PARSER_OCR: Linia $i: "$trimmedLine"');
      if (trimmedLine.isEmpty || trimmedLine.length < 10) continue;
      
             // Cauta toate perechile nume-telefon din linie
       // Pentru text ca: "MUNTEANU VASILE 0721234567 DUMITRU ELENA 0722345678"
       final phoneMatches = _phoneRegex.allMatches(trimmedLine);
       if (phoneMatches.isNotEmpty) {
         final phones = phoneMatches.map((m) => m.group(0)!).toList();
         
         debugPrint('🔍 PARSER_OCR: Linie: "$trimmedLine"');
         debugPrint('📱 PARSER_OCR: Gasite ${phones.length} telefoane: $phones');
         
         // Proceseaza fiecare telefon pentru a gasi numele asociat
         for (int phoneIndex = 0; phoneIndex < phones.length; phoneIndex++) {
           final phone = phones[phoneIndex];
           
           if (!_isValidPhone(phone)) {
             debugPrint('❌ PARSER_OCR: Telefon invalid ignorat: $phone');
             continue;
           }
           
           // Gaseste numele pentru acest telefon
           final name = _extractNameForPhone(trimmedLine, phone, phones);
           if (name != null && name.isNotEmpty) {
             final finalName = _cleanName(name);
             
             debugPrint('📱 PARSER_OCR: Telefon: $phone');
             debugPrint('👤 PARSER_OCR: Nume gasit: "$finalName"');
             
             // Creeaza contactul
             final contact = await _createContactRelaxed(
               name: finalName,
               phone1: phone,
             );
             
             if (contact != null) {
               contacts.add(contact);
               debugPrint('✅ PARSER_OCR: Contact creat: ${contact.basicInfo.name}');
             } else {
               debugPrint('❌ PARSER_OCR: Nu s-a putut crea contactul pentru: "$finalName"');
             }
           } else {
             debugPrint('❌ PARSER_OCR: Nu s-a gasit nume pentru telefonul: $phone');
           }
         }
       }
    }
    
         return contacts;
   }

  /// Extrage numele asociat cu un telefon specific din text
  String? _extractNameForPhone(String text, String targetPhone, List<String> allPhones) {
    final phoneIndex = text.indexOf(targetPhone);
    if (phoneIndex == -1) return null;
    
    // Determina limitele pentru cautarea numelui
    int startIndex = 0;
    int endIndex = phoneIndex;
    
    // Gaseste telefonul anterior pentru a limita cautarea
    for (final phone in allPhones) {
      if (phone == targetPhone) continue;
      
      final otherPhoneIndex = text.indexOf(phone);
      if (otherPhoneIndex != -1 && otherPhoneIndex < phoneIndex) {
        // Exista un telefon anterior - incepe cautarea dupa el
        startIndex = otherPhoneIndex + phone.length;
      }
    }
    
    // Extrage textul dintre limitele stabilite
    final nameSection = text.substring(startIndex, endIndex).trim();
    
    debugPrint('🔍 PARSER_OCR: Cautare nume pentru $targetPhone in: "$nameSection"');
    
    // Curata textul pentru a extrage doar numele
    final cleanedName = nameSection
        .replaceAll(RegExp(r'[^A-ZAAISTa-zaaist\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    
    // Verifica daca avem cel putin 2 cuvinte pentru nume + prenume
    final words = cleanedName.split(' ');
    if (words.length >= 2 && words.every((word) => word.length >= 2)) {
      // Ia ultimele 2-3 cuvinte (numele cel mai probabil)
      final nameWords = words.length >= 3 
          ? words.sublist(words.length - 3) 
          : words.sublist(words.length - 2);
      
      final result = nameWords.join(' ');
      debugPrint('✅ PARSER_OCR: Nume extras: "$result"');
      return result;
    }
    
    debugPrint('❌ PARSER_OCR: Nume invalid in sectiunea: "$cleanedName"');
    return null;
  }

  /// Creeaza contact din parti separate
  Future<UnifiedClientModel?> _createContactFromParts(List<String> parts) async {
    String? name;
    String? phone1;
    String? phone2;
    
    for (final part in parts) {
      final trimmed = part.trim();
      
      if (await _isValidName(trimmed)) {
        name = trimmed;
      } else if (_isValidPhone(trimmed)) {
        if (phone1 == null) {
          phone1 = trimmed;
        } else {
          phone2 = trimmed;
        }
      }
    }
    
    if (name != null && phone1 != null) {
      return await _createContact(
        name: name,
        phone1: phone1,
        phone2: phone2,
      );
    }
    
    return null;
  }

  /// Creeaza un contact valid
  Future<UnifiedClientModel?> _createContact({
    required String name,
    required String phone1,
    String? phone2,
    String? cnp,
  }) async {
    try {
      final cleanName = _cleanName(name);
      final cleanPhone1 = _cleanPhone(phone1);
      final cleanPhone2 = phone2 != null ? _cleanPhone(phone2) : null;
      
      if (!await _isValidName(cleanName) || !_isValidPhone(cleanPhone1)) {
        return null;
      }
      
      return UnifiedClientModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        consultantId: 'ocr',
        basicInfo: ClientBasicInfo(
          name: cleanName,
          phoneNumber1: cleanPhone1,
          phoneNumber2: cleanPhone2,
          cnp: cnp,
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
          category: UnifiedClientCategory.clienti,
          isFocused: false,
          additionalInfo: 'Extras din OCR',
        ),
        metadata: ClientMetadata(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'ocr',
          source: 'ocr_extraction',
          version: 1,
        ),
      );
    } catch (e) {
      debugPrint('❌ PARSER_OCR: Eroare la crearea contactului: $e');
      return null;
    }
  }

  /// Creeaza un contact cu validare mai relaxata (pentru OCR)
  Future<UnifiedClientModel?> _createContactRelaxed({
    required String name,
    required String phone1,
    String? phone2,
    String? cnp,
  }) async {
    try {
      final cleanName = _cleanName(name);
      final cleanPhone1 = _cleanPhone(phone1);
      final cleanPhone2 = phone2 != null ? _cleanPhone(phone2) : null;
      
      // Validare doar pentru telefon - numele acceptate mai relaxat pentru OCR
      if (!_isValidPhone(cleanPhone1)) {
        debugPrint('❌ PARSER_OCR: Telefon invalid: $cleanPhone1');
        return null;
      }
      
      // Validare minima pentru nume - cel putin 2 cuvinte de cel putin 2 litere
      final nameParts = cleanName.split(' ');
      if (nameParts.length < 2 || nameParts.any((part) => part.length < 2)) {
        debugPrint('❌ PARSER_OCR: Nume invalid: $cleanName');
        return null;
      }
      
      return UnifiedClientModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        consultantId: 'ocr',
        basicInfo: ClientBasicInfo(
          name: cleanName,
          phoneNumber1: cleanPhone1,
          phoneNumber2: cleanPhone2,
          cnp: cnp,
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
          category: UnifiedClientCategory.clienti,
          isFocused: false,
          additionalInfo: 'Extras din OCR',
        ),
        metadata: ClientMetadata(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'ocr',
          source: 'ocr_extraction',
          version: 1,
        ),
      );
    } catch (e) {
      debugPrint('❌ PARSER_OCR: Eroare la crearea contactului relaxat: $e');
      return null;
    }
  }

  /// Gaseste numele din apropierea unui telefon
  Future<String?> _findNameNearPhone(String text, String phone) async {
    final phoneIndex = text.indexOf(phone);
    if (phoneIndex == -1) return null;
    
    // Cauta in 100 de caractere inainte si dupa telefon
    final start = (phoneIndex - 100).clamp(0, text.length);
    final end = (phoneIndex + phone.length + 100).clamp(0, text.length);
    final context = text.substring(start, end);
    
    debugPrint('🔍 PARSER_OCR: Context pentru $phone: "${context.substring(0, context.length.clamp(0, 100))}..."');
    
    // Incearca sa gaseasca nume in text lipit (fara spatii)
    final nameFromConcatenated = await _extractNameFromConcatenatedText(context, phone);
    if (nameFromConcatenated != null) {
      debugPrint('✅ PARSER_OCR: Nume gasit din text lipit: "$nameFromConcatenated"');
      return nameFromConcatenated;
    }
    
    // Imparte in cuvinte si cauta numele (pentru texte normale cu spatii)
    final words = context.split(RegExp(r'\s+'));
    
    debugPrint('🔍 PARSER_OCR: Cuvinte gasite: ${words.take(10).toList()}');
    
    for (int i = 0; i < words.length - 1; i++) {
      final candidate = '${words[i]} ${words[i + 1]}';
      debugPrint('🔍 PARSER_OCR: Verific candidat: "$candidate"');
      if (await _isValidName(candidate)) {
        final cleaned = _cleanName(candidate);
        debugPrint('✅ PARSER_OCR: Nume valid gasit: "$cleaned"');
        return cleaned;
      }
    }
    
    debugPrint('❌ PARSER_OCR: Nu s-a gasit nume valid in contextul pentru $phone');
    return null;
  }

  /// Extrage nume din text concatenat (fara spatii)
  Future<String?> _extractNameFromConcatenatedText(String context, String phone) async {
    final phoneIndex = context.indexOf(phone);
    if (phoneIndex == -1) return null;
    
    // Cauta inainte de telefon pentru nume
    final beforePhone = context.substring(0, phoneIndex);
    
    debugPrint('🔍 PARSER_OCR: Text inainte de telefon: "${beforePhone.substring((beforePhone.length - 50).clamp(0, beforePhone.length))}"');
    
    // Incearca sa separe numele din textul lipit
    // Cauta ultimele 30-50 de caractere inainte de telefon
    final searchLength = 50.clamp(0, beforePhone.length);
    final searchText = beforePhone.substring(beforePhone.length - searchLength);
    
         // Incearca sa gaseasca nume cu diferite lungimi
     for (int nameLength = 15; nameLength <= 30; nameLength++) {
       if (nameLength > searchText.length) continue;
       
       final candidateName = searchText.substring(searchText.length - nameLength);
       
       // Curata numele candidat
       final cleanCandidate = _cleanConcatenatedName(candidateName);
       if (cleanCandidate != null) {
         debugPrint('🔍 PARSER_OCR: Testez nume candidat: "$cleanCandidate"');
         
         // Verifica daca contine cel putin doua nume romanesti
         if (await _isValidConcatenatedName(cleanCandidate)) {
           return cleanCandidate;
         }
       }
     }
     
     // Abordare alternativa: incearca sa extraga nume chiar si fara validare stricta
     final fallbackName = _extractNameFallback(beforePhone, phone);
     if (fallbackName != null) {
       debugPrint('🔍 PARSER_OCR: Folosesc nume fallback: "$fallbackName"');
       return fallbackName;
     }
    
    return null;
  }

  /// Curata un nume din text concatenat
  String? _cleanConcatenatedName(String concatenated) {
    // Inlatura caractere nevalide
    final cleaned = concatenated.replaceAll(RegExp(r'[^A-ZAAISTa-zaaist]'), '');
    
    if (cleaned.length < 10 || cleaned.length > 40) return null;
    
    // Incearca sa separe numele folosind baza de date
    return _separateNames(cleaned);
  }

  /// Separa numele dintr-un string concatenat
  String? _separateNames(String concatenated) {
    // Incearca sa gaseasca doua nume consecutive in baza de date
    for (int i = 3; i < concatenated.length - 3; i++) {
      final firstPart = concatenated.substring(0, i);
      final remaining = concatenated.substring(i);
      
      // Incearca sa gaseasca un al doilea nume in restul stringului
      for (int j = 3; j < remaining.length && j <= 15; j++) {
        final secondPart = remaining.substring(0, j);
        final thirdPart = remaining.length > j ? remaining.substring(j) : '';
        
        // Verifica daca avem 2-3 nume valide
        if (_isRomanianName(firstPart) && _isRomanianName(secondPart)) {
          if (thirdPart.isEmpty || thirdPart.length < 3) {
            // Doar 2 nume
            return '${_capitalizeWord(firstPart)} ${_capitalizeWord(secondPart)}';
          } else if (thirdPart.length >= 3 && thirdPart.length <= 15 && _isRomanianName(thirdPart)) {
            // 3 nume
            return '${_capitalizeWord(firstPart)} ${_capitalizeWord(secondPart)} ${_capitalizeWord(thirdPart)}';
          }
        }
      }
    }
    
    return null;
  }

  /// Verifica daca un string este un nume romanesc din baza de date
  bool _isRomanianName(String name) {
    return _romanianNames?.contains(name.toUpperCase()) ?? false;
  }

  /// Capitalizeaza prima litera a unui cuvant
  String _capitalizeWord(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  /// Verifica daca un nume concatenat este valid
  Future<bool> _isValidConcatenatedName(String name) async {
    await _loadRomanianNames();
    
    if (name.length < 6 || name.length > 50) return false;
    
    // Verifica daca contine cel putin 2 cuvinte
    final words = name.split(' ');
    if (words.length < 2) return false;
    
    // Verifica daca cel putin jumatate din cuvinte sunt nume romanesti
    int validWords = 0;
    for (final word in words) {
      if (_romanianNames?.contains(word.toUpperCase()) ?? false) {
        validWords++;
      }
    }
    
         return validWords >= (words.length * 0.5).ceil();
   }

   /// Extrage nume folosind abordare fallback (mai putin stricta)
   String? _extractNameFallback(String beforePhone, String phone) {
     // Cauta ultimele 20-40 caractere inainte de telefon
     final searchLength = 40.clamp(0, beforePhone.length);
     if (searchLength < 10) return null;
     
     final searchText = beforePhone.substring(beforePhone.length - searchLength);
     
     // Inlatura caractere nevalide si pastreaza doar litere
     final lettersOnly = searchText.replaceAll(RegExp(r'[^A-ZAAISTa-zaaist]'), '');
     
     if (lettersOnly.length < 10 || lettersOnly.length > 40) return null;
     
     // Incearca sa imparta in 2-3 nume de lungimi rezonabile
     final result = _splitIntoNames(lettersOnly);
     if (result != null && result.split(' ').length >= 2) {
       debugPrint('🔍 PARSER_OCR: Nume fallback gasit: "$result"');
       return result;
     }
     
     return null;
   }

   /// Imparte un string in nume de lungimi rezonabile
   String? _splitIntoNames(String text) {
     // Incearca diferite combinatii de impartire
     final patterns = [
       [5, 7, 8], // prenume scurt, nume mediu, nume mediu
       [6, 8, 6], // prenume mediu, nume lung, nume scurt
       [7, 7, 6], // prenume lung, nume mediu, nume scurt
       [8, 8],    // doar 2 nume, ambele lungi
       [6, 10],   // prenume scurt, nume lung
       [10, 8],   // prenume lung, nume mediu
     ];
     
     for (final pattern in patterns) {
       if (pattern.reduce((a, b) => a + b) <= text.length && 
           pattern.reduce((a, b) => a + b) >= text.length - 2) {
         
         final names = <String>[];
         int start = 0;
         
         for (int i = 0; i < pattern.length; i++) {
           final length = pattern[i];
           if (start + length <= text.length) {
             final name = text.substring(start, start + length);
             names.add(_capitalizeWord(name));
             start += length;
           }
         }
         
         if (names.length >= 2) {
           final result = names.join(' ');
           debugPrint('🔍 PARSER_OCR: Incercare impartire: "$result" (pattern: $pattern)');
           return result;
         }
       }
     }
     
     return null;
   }

   /// Extrage numerele de telefon dintr-un text
  List<String> _extractPhones(String text) {
    final matches = _phoneRegex.allMatches(text);
    return matches.map((m) => _cleanPhone(m.group(0)!)).toList();
  }

  /// Verifica daca un string este un nume valid
  Future<bool> _isValidName(String candidate) async {
    await _loadRomanianNames();
    
    if (candidate.length < 3 || candidate.length > 50) return false;
    
    // Verifica format
    if (!_nameRegex.hasMatch(candidate)) return false;
    
    // Verifica in baza de date de nume
    final parts = candidate.split(' ');
    if (parts.length < 2) return false;
    
    final firstName = parts.first;
    final lastName = parts.last;
    
    // Daca baza de date e goala sau nu s-a incarcat, foloseste validare mai permisiva
    if (_romanianNames == null || _romanianNames!.isEmpty) {
      debugPrint('⚠️ PARSER_OCR: Baza de nume nu e disponibila, folosesc validare permisiva pentru: $candidate');
      // Verifica ca sunt doar litere si spatii, si ca fiecare cuvant incepe cu majuscula
      return parts.every((part) => RegExp(r'^[A-ZAAIST][a-zaaist]+$').hasMatch(part));
    }
    
    return _romanianNames!.contains(firstName) || _romanianNames!.contains(lastName);
  }

  /// Verifica daca un string este un telefon valid - DOAR numere COMPLETE de 10 cifre
  bool _isValidPhone(String candidate) {
    final clean = _cleanPhone(candidate);
    // Trebuie sa aiba EXACT 10 cifre pentru numerele romanesti fara prefix
    if (clean.startsWith('+40')) {
      return clean.length == 13 && _phoneRegex.hasMatch(clean);
    } else {
      return clean.length == 10 && _phoneRegex.hasMatch(clean);
    }
  }

  /// Curata un nume
  String _cleanName(String name) {
    return name
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Curata un numar de telefon
  String _cleanPhone(String phone) {
    // Inlatura toate caracterele non-numerice si + pentru international
    var clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Standardizeaza format pentru Romania
    if (clean.startsWith('+407')) {
      clean = '07${clean.substring(4)}';
    } else if (clean.startsWith('+402') || clean.startsWith('+403') || 
               clean.startsWith('+404') || clean.startsWith('+405') || 
               clean.startsWith('+406')) {
      clean = '0${clean.substring(3)}';
    }
    
    return clean;
  }
}

/// Tipuri de documente recunoscute
enum DocumentType {
  table,    // Tabel structurat cu coloane
  form,     // Formular cu campuri etichetate
  list,     // Lista cu bullet points
  freeText, // Text liber
}

/// Rezultatul parsarii
class ParseResult {
  final List<UnifiedClientModel> contacts;
  final DocumentType documentType;
  final double confidence;
  final String originalText;
  
  const ParseResult({
    required this.contacts,
    required this.documentType,
    required this.confidence,
    required this.originalText,
  });

  @override
  String toString() => 'ParseResult(contacts: ${contacts.length}, type: $documentType, confidence: $confidence)';
}



