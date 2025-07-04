import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ocr_logger.dart';

/// Service pentru parsarea si filtrarea contactelor din textul extras prin OCR
/// Implementeaza logica avansata din better-ocr: stop words, corecție OCR, validare nume
class ParserOcr {
  /// Singleton instance
  static final ParserOcr _instance = ParserOcr._internal();
  factory ParserOcr() => _instance;
  ParserOcr._internal();

  static List<String> _romanianNames = [];
  final _logger = OcrDebugLogger();

  // Stop words extinse pentru filtrarea textului - am adaugat cuvintele problematice din output
  static final Set<String> _stopWords = {
    // UI & Common
    "import", "copy", "paste", "view", "open", "delete", "insert", "format", "painter",
    "clipboard", "font", "general", "alignment", "sheet1", "sheet2", "sheet3", "sheet4",
    "fara", "feedback", "status", "nume", "telefon", "data", "rezultate",
    "pagina", "inapoi", "crt", "nr", "total", "sector", "bucuresti", "ready", "close",
    "save", "print", "export", "type", "here", "accessibility", "investigate", "to", "from",
    "undo", "redo", "cut", "select", "all", "text", "cont", "contract", "cod", "persoana",
    // Months & Days
    "ianuarie", "februarie", "martie", "aprilie", "mai", "iunie", "iulie",
    "august", "septembrie", "octombrie", "noiembrie", "decembrie",
    "luni", "marti", "miercuri", "joi", "vineri", "sambata", "duminica",
    // Common places/prepositions
    "strada", "alee", "bloc", "scara", "apartament", "etaj", "judet", "oras",
    "la", "de", "din", "pe", "langa", "sub", "peste",
    // Other common words
    "scoala", "generala", "fabrica", "paine", "poate", "veni", "astazi", "ora",
    "tarziu", "inv", "search", "inceput", "ocupat", "liber", "munca", "raspunde",
    "nu", "da", "vrea", "sfarsit", "devreme", "pensie", "",
    // Noise words
    "nc", "vu", "rev", "mr", "inu", "vr", "schimbat", "maine", "mas", "una",
    "cand", "vine", "ara", "tarsio", "remai", "nev", "sunat",
    // Problematic words identified in OCR output
    "calibri", "sheets", "sheet", "ilfov", "teleorma", "calarasi", "ialomita",
    "filtreaza", "alege", "campanii", "creditul", "unitate",
    "corima", "volentino", "gatan", "bouzidi", "ene", "odette",
    "brateanu", "chiran", "ursu", "savu", "caramlau", "gradinaru",
    "neagu", "georgescu", "negoita", "dragici", "gaglighor",
    "cornelia", "surcel", "andreescu", "bratu", "chiriac", "maleika", "volha",
    "albu", "radu", "stana", "neagoe", "vlasceanu"
  };

  /// Incarca baza de date cu nume romanesti din fisierul JSON
  Future<void> _loadRomanianNames() async {
    if (_romanianNames.isNotEmpty) {
      debugPrint('📚 [ParserOcr] Romanian names already loaded: ${_romanianNames.length} names');
      return;
    }

    try {
      debugPrint('📚 [ParserOcr] Incarc baza de date cu nume romanesti din assets/names.json...');
      final String jsonString = await rootBundle.loadString('assets/names.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final List<dynamic> jsonList = jsonMap['names'] as List<dynamic>;
      _romanianNames = jsonList.map((name) => (name as String).toLowerCase()).toList();
      debugPrint('✅ [ParserOcr] Loaded ${_romanianNames.length} Romanian names from JSON');
    } catch (e) {
      debugPrint('❌ [ParserOcr] Error loading Romanian names from JSON: $e');
      _romanianNames = ['ion', 'maria', 'popescu', 'ionescu', 'gheorghe', 'elena', 'vasile', 'ana'];
      debugPrint('⚠️ [ParserOcr] Using fallback with ${_romanianNames.length} names');
    }
  }

  /// Extrage contactele din textul brut OCR - filtreaza si parseaza
  Future<List<ContactDetection>> parseContactsFromText(String rawText) async {
    debugPrint('📝 [ParserOcr] Processing ${rawText.length} chars, ${rawText.split('\n').length} lines');

    try {
      await _loadRomanianNames();
      
      _logger.addParsingStep('--- Inceput Parsare ---');
      
      List<String> cleanLines = _cleanText(rawText);
      _logger.addParsingStep('1. Text curatat: ${cleanLines.length} linii\n${cleanLines.take(5).join('\n')}...');

      // Add a more aggressive filtering step as requested
      List<String> filteredLines = _filterLines(cleanLines);
      _logger.addParsingStep('2. Linii filtrate agresiv: ${filteredLines.length} linii\n${filteredLines.take(5).join('\n')}...');

      // Strategy: Run both direct and fallback detection, then merge results.
      
      // 1. Direct detection on filtered text
      List<ContactDetection> directContacts = _detectDirectContacts(filteredLines);
      _logger.addParsingStep('3. Detectie directa: ${directContacts.length} contacte gasite.');
      
      if (directContacts.isNotEmpty) {
        _logger.addParsingStep('--> Folosind detectia directa ca rezultat final.');
        return directContacts;
      }

      // 2. Fallback detection on filtered text
      _logger.addParsingStep('4. Ruleaza detectia de rezerva (fallback)...');
      List<PhoneDetection> phones = _detectPhones(filteredLines);
      _logger.addParsingStep('   - Telefoane detectate: ${phones.length}');

      List<NameDetection> names = _detectNames(filteredLines);
      _logger.addParsingStep('   - Nume detectate: ${names.length}');

      List<ContactDetection> fallbackContacts = _associateContacts(names, phones, filteredLines);
      _logger.addParsingStep('5. Asociere fallback: ${fallbackContacts.length} contacte create.');
      
      // 3. Merge results
      List<ContactDetection> allContacts = [];
      Set<String> usedPhones = {};

      // Add direct contacts first
      for (var contact in directContacts) {
        if (!usedPhones.contains(contact.phone1)) {
          allContacts.add(contact);
          usedPhones.add(contact.phone1);
          if (contact.phone2 != null) {
            usedPhones.add(contact.phone2!);
          }
        }
      }

      // Add fallback contacts if not already found
      for (var contact in fallbackContacts) {
        if (!usedPhones.contains(contact.phone1)) {
          allContacts.add(contact);
          usedPhones.add(contact.phone1);
          if (contact.phone2 != null) {
            usedPhones.add(contact.phone2!);
          }
        }
      }
      
      _logger.addParsingStep('6. Total contacte unice: ${allContacts.length}');
      _logger.addParsingStep('--- Sfarsit Parsare ---');
      return allContacts;

    } catch (e) {
      debugPrint('❌ [ParserOcr] Eroare: $e');
      _logger.addParsingStep('❌ EROARE PARSARE: $e');
      return [];
    }
  }

  /// Curata si filtreaza textul prin eliminarea diacriticelor si stop words
  List<String> _cleanText(String text) {
    debugPrint('🧹 [ParserOcr] Cleaning text...');
    
    List<String> lines = text.split('\n');
    List<String> cleanLines = [];
    int removedWords = 0;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.isEmpty) continue;

      List<String> words = line.split(RegExp(r'\s+'));
      List<String> cleanWords = [];

      for (String word in words) {
        String cleanWord = word.replaceAll(RegExp(r'[^\w\s+]'), '');
        if (cleanWord.isEmpty) continue;

        if (_stopWords.contains(cleanWord.toLowerCase()) || 
            cleanWord.length <= 2 || 
            RegExp(r'^\d{2}$').hasMatch(cleanWord)) {
          removedWords++;
          continue;
        }

        cleanWords.add(cleanWord);
      }

      if (cleanWords.isNotEmpty) {
        cleanLines.add(cleanWords.join(' '));
      }
    }

    debugPrint('🧹 [ParserOcr] Removed $removedWords words, kept ${cleanLines.length} lines');
    return cleanLines;
  }

  /// Noua functie de filtrare agresiva
  List<String> _filterLines(List<String> lines) {
    debugPrint('🔬 [ParserOcr] Filtering ${lines.length} lines to keep only names and phones...');
    List<String> hyperFilteredLines = [];
    int removedWords = 0;
    int keptWords = 0;

    for (String line in lines) {
        List<String> words = line.split(' ');
        List<String> filteredWords = [];
        for (String word in words) {
            String cleanWord = word.replaceAll(RegExp(r'[,.;:]$'), '').toLowerCase();
            String normalizedPhone = _normalizePhone(cleanWord);

            if (_isValidRomanianPhone(normalizedPhone) || _romanianNames.contains(cleanWord)) {
                filteredWords.add(word); // Pastram capitalizarea originala
                keptWords++;
            } else {
                removedWords++;
            }
        }
        if (filteredWords.isNotEmpty) {
            hyperFilteredLines.add(filteredWords.join(' '));
        }
    }

    debugPrint('🔬 [ParserOcr] Filtering complete. Kept $keptWords words, removed $removedWords words. Result: ${hyperFilteredLines.length} lines.');
    return hyperFilteredLines;
  }

  /// Detecteaza telefoanele cu validare si corecție avansata
  List<PhoneDetection> _detectPhones(List<String> lines) {
    debugPrint('📞 [ParserOcr] Detecting phones...');
    
    List<PhoneDetection> phones = [];
    Set<String> uniquePhones = {};

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      
      // Enhanced phone patterns for different formats found in real data
      List<RegExp> phonePatterns = [
        // Standard Romanian mobile numbers
        RegExp(r'\b0[7][0-9]{8}\b'),                    // 07xxxxxxxx mobile
        RegExp(r'\b0[2-3][0-9]{8}\b'),                  // 02xxxxxxxx, 03xxxxxxxx fixed
        // International format
        RegExp(r'\+40[0-9]{9}\b'),                      // +40xxxxxxxxx
        // Multiple phones separated by comma (like in real_clients)
        RegExp(r'\b0[0-9]{9}(?:,0[0-9]{9})+\b'),       // 0xxxxxxxxx,0xxxxxxxxx
      ];

      for (RegExp pattern in phonePatterns) {
        Iterable<RegExpMatch> matches = pattern.allMatches(line);
        
        for (RegExpMatch match in matches) {
          String phoneText = match.group(0)!;
          
          // Handle multiple phones separated by comma
          if (phoneText.contains(',')) {
            List<String> multiplePhones = phoneText.split(',');
            for (String singlePhone in multiplePhones) {
              String cleanPhone = _normalizePhone(singlePhone.trim());
              if (_isValidRomanianPhone(cleanPhone) && !uniquePhones.contains(cleanPhone)) {
                phones.add(PhoneDetection(
                  number: cleanPhone,
                  lineIndex: i,
                  position: match.start + phoneText.indexOf(singlePhone),
                  raw: singlePhone.trim(),
                  confidence: 100.0,
                ));
                uniquePhones.add(cleanPhone);
              }
            }
          } else {
            String cleanPhone = _normalizePhone(phoneText);
            if (_isValidRomanianPhone(cleanPhone) && !uniquePhones.contains(cleanPhone)) {
              phones.add(PhoneDetection(
                number: cleanPhone,
                lineIndex: i,
                position: match.start,
                raw: phoneText,
                confidence: 100.0,
              ));
              uniquePhones.add(cleanPhone);
            }
          }
        }
      }
    }

    debugPrint('📞 [ParserOcr] Found ${phones.length} valid phones');
    return phones;
  }
  
  /// Normalizeaza un numar de telefon la formatul standard
  String _normalizePhone(String phone) {
    // Remove all non-digit characters
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Handle international format
    if (cleanPhone.startsWith('40') && cleanPhone.length == 11) {
      cleanPhone = '0${cleanPhone.substring(2)}';
    }
    
    return cleanPhone;
  }
  
  /// Verifica daca un telefon este valid pentru Romania
  bool _isValidRomanianPhone(String phone) {
    if (phone.length != 10) return false;
    if (!phone.startsWith('0')) return false;
    
    // Check if it's likely a CNP (Romanian personal code) instead of phone
    if (_isLikelyCNP(phone)) return false;
    
    // Valid Romanian prefixes
    String prefix = phone.substring(0, 3);
    List<String> validPrefixes = [
      // Mobile prefixes
      '070', '071', '072', '073', '074', '075', '076', '077', '078', '079',
      // Fixed line prefixes (major cities)
      '021', '022', '023', '024', '025', '026', '027', '028', '029',
      '031', '033', '034', '035', '036', '037', '038', '039'
    ];
    
    return validPrefixes.contains(prefix);
  }

  /// Verifica daca un numar este probabil un CNP (Cod Numeric Personal) sau ID
  bool _isLikelyCNP(String phone) {
    if (phone.length != 10) return false;
    
    String first = phone.substring(0, 1);
    // CNPs start with 1,2,5,6 for birth dates, but phones start with 0
    if (['1', '2', '5', '6'].contains(first)) return true;
    
    // Additional checks for ID numbers or sequential numbers
    if (_isSequentialNumber(phone)) return true;
    if (_hasRepeatingPattern(phone)) return true;
    
    return false;
  }
  
  /// Verifica daca numarul este secvential (1234567890, etc.)
  bool _isSequentialNumber(String phone) {
    for (int i = 0; i < phone.length - 1; i++) {
      int current = int.parse(phone[i]);
      int next = int.parse(phone[i + 1]);
      if (next != current + 1) return false;
    }
    return true;
  }
  
  /// Verifica daca numarul are pattern repetitiv (1111111111, 1212121212, etc.)
  bool _hasRepeatingPattern(String phone) {
    // Check for all same digits
    if (phone.split('').every((digit) => digit == phone[0])) return true;
    
    // Check for alternating pattern (1212...)
    if (phone.length >= 4) {
      String pattern = phone.substring(0, 2);
      for (int i = 0; i < phone.length - 1; i += 2) {
        if (i + 1 < phone.length && phone.substring(i, i + 2) != pattern) {
          return false;
        }
      }
      return true;
    }
    
    return false;
  }

  /// Detecteaza numele folosind baza de date romaneasca
  List<NameDetection> _detectNames(List<String> lines) {
    debugPrint('👤 [ParserOcr] Detecting names from ${lines.length} lines...');
    
    List<NameDetection> names = [];
    Set<String> uniqueNames = {};
    
    int processedLines = 0;
    int potentialNamesFound = 0;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      
      // Enhanced name detection with multiple strategies
      List<String> detectedNames = _extractNamesFromLine(line);
      potentialNamesFound += detectedNames.length;
      
      if (detectedNames.isNotEmpty) {
        debugPrint('📋 [ParserOcr] Line ${i + 1}: "${line.substring(0, line.length > 40 ? 40 : line.length)}..." -> ${detectedNames.length} potential names: ${detectedNames.join(", ")}');
      }
      
      for (String name in detectedNames) {
        if (!uniqueNames.contains(name)) {
          double confidence = _calculateNameConfidence(name);
          debugPrint('🎯 [ParserOcr] Evaluating name "$name" -> confidence: ${confidence.toStringAsFixed(1)}%');
          
          if (confidence >= 50.0) {  // Lowered threshold for better detection
            names.add(NameDetection(
              name: name,
              lineIndex: i,
              position: 0,
              confidence: confidence,
            ));
            uniqueNames.add(name);
            debugPrint('✅ [ParserOcr] Added valid name: "$name" (confidence: ${confidence.toStringAsFixed(1)}%)');
          } else {
            debugPrint('❌ [ParserOcr] Rejected name: "$name" (confidence: ${confidence.toStringAsFixed(1)}% < 50%)');
          }
        }
      }
      
      processedLines++;
    }

    debugPrint('👤 [ParserOcr] Name detection summary: $processedLines lines processed, $potentialNamesFound potential names found, ${names.length} valid names accepted');
    return names;
  }

  /// Extrage numele dintr-o linie cu pattern matching avansat
  List<String> _extractNamesFromLine(String line) {
    List<String> names = [];
    
    // Pattern 1: Tabular format with numbers "1506 LASTNAME FIRSTNAME phone"
    RegExp numberedTabular = RegExp(r'\d+\s+([a-z]+)\s+([a-z]+)(?:\s+([a-z]+))?\s+0[0-9]{9}', caseSensitive: false);
    Iterable<RegExpMatch> numberedMatches = numberedTabular.allMatches(line);
    
    for (RegExpMatch match in numberedMatches) {
      String lastname = match.group(1)!;
      String firstname = match.group(2)!;
      String? surname = match.group(3);
      
      String fullName = surname != null 
          ? '$firstname $lastname $surname'
          : '$firstname $lastname';
      
      if (_isValidRomanianName(fullName)) {
        names.add(fullName);
      }
    }
    
    // Pattern 2: Standard tabular "LASTNAME FIRSTNAME phone" 
    if (names.isEmpty) {
      RegExp tabularPattern = RegExp(r'\b([a-z]+)\s+([a-z]+)(?:\s+([a-z]+))?\s+0[0-9]{9}', caseSensitive: false);
      Iterable<RegExpMatch> tabularMatches = tabularPattern.allMatches(line);
      
      for (RegExpMatch match in tabularMatches) {
        String lastname = match.group(1)!;
        String firstname = match.group(2)!;
        String? surname = match.group(3);
        
        String fullName = surname != null 
            ? '$firstname $lastname $surname'
            : '$firstname $lastname';
        
        if (_isValidRomanianName(fullName)) {
          names.add(fullName);
        }
      }
    }
    
    // Pattern 3: Single Romanian names on individual lines (common in real data)
    if (names.isEmpty) {
      String trimmedLine = line.trim();
      
      // Check if line contains a single Romanian name
      if (_isSingleRomanianName(trimmedLine)) {
        names.add(trimmedLine);
      }
      
      // Check for multiple names on same line separated by spaces
      List<String> words = trimmedLine.split(RegExp(r'\s+'));
      if (words.length >= 2 && words.length <= 4) {
        bool allRomanianNames = true;
        for (String word in words) {
          if (!_isSingleRomanianName(word)) {
            allRomanianNames = false;
            break;
          }
        }
        if (allRomanianNames) {
          names.add(words.join(' '));
        }
      }
    }
    
    // Pattern 4: Mixed case names "Firstname Lastname" format
    if (names.isEmpty) {
      RegExp mixedCasePattern = RegExp(r'\b([a-z]+)\s+([a-z]+)(?:\s+([a-z]+))?\b', caseSensitive: false);
      Iterable<RegExpMatch> mixedMatches = mixedCasePattern.allMatches(line);
      
      for (RegExpMatch match in mixedMatches) {
        String fullName = match.group(0)!.trim();
        if (_isValidRomanianName(fullName)) {
          names.add(fullName);
        }
      }
    }

    return names;
  }

  /// Verifica daca un cuvant este nume romanesc individual
  bool _isSingleRomanianName(String word) {
    if (word.length < 3) return false;
    
    // Check basic format (starts with capital letter)
    if (!RegExp(r'^[A-Z][a-zA-Z]*$').hasMatch(word)) return false;
    
    // Check if it's in Romanian names database
    return _romanianNames.contains(word.toLowerCase());
  }

  /// Verifica daca numele este valid romanesc (more flexible)
  bool _isValidRomanianName(String name) {
    List<String> words = name.split(' ');
    if (words.isEmpty || words.length > 4) return false;
    
    // For single words, must be a Romanian name
    if (words.length == 1) {
      return _isSingleRomanianName(words[0]);
    }
    
    // For multiple words, at least one must be a Romanian name
    int romanianNameCount = 0;
    for (String word in words) {
      if (_romanianNames.contains(word.toLowerCase())) {
        romanianNameCount++;
      }
    }
    
    // Be more flexible: at least one Romanian name is enough
    return romanianNameCount >= 1;
  }

  /// Calculeaza confidence-ul pentru un nume (more flexible scoring)
  double _calculateNameConfidence(String name) {
    double confidence = 50.0;  // Higher base confidence
    List<String> words = name.split(' ');
    
    int romanianCount = 0;
    for (String word in words) {
      if (_romanianNames.contains(word.toLowerCase())) {
        romanianCount++;
        confidence += 25.0;  // Good bonus for Romanian names
      }
    }
    
    // Bonus for complete names
    if (words.length == 1) confidence += 0.0;    // Single name
    if (words.length == 2) confidence += 15.0;   // Standard firstname lastname
    if (words.length == 3) confidence += 20.0;   // Full name with surname
    if (words.length == 4) confidence += 10.0;   // Complex name
    
    // Extra bonus for multiple Romanian names
    if (romanianCount >= 2) confidence += 15.0;
    if (romanianCount >= 3) confidence += 10.0;
    
    return confidence > 100.0 ? 100.0 : confidence;
  }

  /// Asociaza numele cu telefoanele pe baza proximității (improved for tabular data)
  List<ContactDetection> _associateContacts(
    List<NameDetection> names,
    List<PhoneDetection> phones,
    List<String> lines,
  ) {
    if (names.isEmpty || phones.isEmpty) {
      debugPrint('❌ [ParserOcr] No names or phones to associate');
      return [];
    }

    List<ContactDetection> contacts = [];
    Set<String> usedPhones = {};

    for (NameDetection name in names) {
      List<PhoneDetection> associatedPhones = _findAssociatedPhones(name, phones, usedPhones);
      
      if (associatedPhones.isNotEmpty) {
        String primaryPhone = associatedPhones[0].number;
        String? secondaryPhone = associatedPhones.length > 1 ? associatedPhones[1].number : null;
        
        double confidence = _calculateAssociationConfidence(name, associatedPhones);
        
        contacts.add(ContactDetection(
          name: name.name,
          phone1: primaryPhone,
          phone2: secondaryPhone,
          confidence: confidence,
        ));
        
        // Mark phones as used
        for (PhoneDetection phone in associatedPhones) {
          usedPhones.add(phone.number);
        }
      }
    }

    // Log unused phones for debugging
    List<PhoneDetection> unusedPhones = phones.where((phone) => !usedPhones.contains(phone.number)).toList();
    if (unusedPhones.isNotEmpty) {
      debugPrint('⚠️ [ParserOcr] ${unusedPhones.length} unused phones detected:');
      for (var phone in unusedPhones) {
        debugPrint('  - ${phone.number} on line ${phone.lineIndex + 1} ("${lines[phone.lineIndex]}")');
      }
    }

    return contacts;
  }

  /// Gaseste telefoanele asociate cu un nume (improved algorithm for tabular data)
  List<PhoneDetection> _findAssociatedPhones(
    NameDetection name,
    List<PhoneDetection> phones,
    Set<String> usedPhones,
  ) {
    List<Map<String, dynamic>> scoredPhones = [];

    for (PhoneDetection phone in phones) {
      if (usedPhones.contains(phone.number)) continue;

      int distance = (phone.lineIndex - name.lineIndex).abs();
      double score = 0;

      if (distance == 0) {
        score = 100; // Highest score for same line
      } else if (distance <= 2) {
        score = 50 - (distance * 10); // High score for adjacent lines
      } else if (distance <= 5) {
        score = 20 - (distance * 2); // Lower score for nearby lines
      }

      if (score > 0) {
        scoredPhones.add({'phone': phone, 'score': score});
      }
    }

    // Sort by score (descending)
    scoredPhones.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    // Return the top 2 matches
    return scoredPhones.take(2).map((e) => e['phone'] as PhoneDetection).toList();
  }

  /// Calculeaza confidence-ul asociatiei dintre un nume si telefoane (improved)
  double _calculateAssociationConfidence(
    NameDetection name,
    List<PhoneDetection> phones,
  ) {
    double confidence = name.confidence;
    
    // Major bonus for same line association (typical in contact lists)
    int distance = (phones.first.lineIndex - name.lineIndex).abs();
    if (distance == 0) {
      confidence += 25.0;      // Same line = very high confidence
    } else if (distance == 1) confidence += 15.0; // Adjacent line = high confidence  
    else if (distance == 2) confidence += 10.0; // 2 lines away = medium confidence
    else if (distance >= 3) confidence -= 10.0; // Further away = lower confidence
    
    // Bonus for multiple phones (common in contact lists)
    if (phones.length > 1) confidence += 10.0;
    
    // Bonus if phone appears immediately after name in same line
    if (distance == 0 && phones.first.position > 0) {
      confidence += 10.0;
    }
    
    return confidence > 100.0 ? 100.0 : confidence;
  }

  /// Detecteaza contactele complete direct din linii individuale (pattern matching)
  List<ContactDetection> _detectDirectContacts(List<String> lines) {
    debugPrint('🎯 [ParserOcr] Trying direct contact detection on ${lines.length} lines');
    
    List<ContactDetection> contacts = [];
    Set<String> usedPhones = {};

    int processedLines = 0;
    for (String line in lines) {
      List<ContactDetection> lineContacts = _extractContactsFromLine(line);
      
      if (lineContacts.isNotEmpty) {
        debugPrint('📋 [ParserOcr] Line ${processedLines + 1}: "${line.substring(0, line.length > 50 ? 50 : line.length)}..." -> ${lineContacts.length} contacts');
      }
      
      for (ContactDetection contact in lineContacts) {
        // Avoid duplicate phones
        if (!usedPhones.contains(contact.phone1)) {
          contacts.add(contact);
          usedPhones.add(contact.phone1);
          if (contact.phone2 != null) {
            usedPhones.add(contact.phone2!);
          }
        }
      }
      
      processedLines++;
    }

    debugPrint('🎯 [ParserOcr] Direct detection: processed $processedLines lines, found ${contacts.length} contacts');
    return contacts;
  }

  /// Extrage contactele dintr-o singura linie folosind pattern matching
  List<ContactDetection> _extractContactsFromLine(String line) {
    List<ContactDetection> contacts = [];

    // Pattern Unificat si Imbunatatit
    // Cauta un grup de cuvinte (nume) urmat de unul sau mai multe telefoane
    // Numele poate avea 2-4 cuvinte. Telefoanele sunt separate prin virgula, cu spatii optionale.
    final RegExp mainPattern = RegExp(
      r'([A-Za-z\-]+\s+[A-Za-z\-]+(?:\s+[A-Za-z\-]+){0,2})\s+((?:0\d{9})(?:\s*,\s*0\d{9})*)',
      caseSensitive: false,
    );

    Iterable<RegExpMatch> matches = mainPattern.allMatches(line);

    for (final match in matches) {
      String name = match.group(1)!.trim();
      String phonesString = match.group(2)!.trim();
      
      // Curata numele de posibile erori
      name = name.split(' ')
          .where((w) => w.length > 2 && !_stopWords.contains(w.toLowerCase()))
          .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
          .join(' ');

      if (name.split(' ').length < 2) continue; // Daca dupa curatare numele e prea scurt

      // Extrage si valideaza telefoanele
      List<String> phones = phonesString
          .split(',')
          .map((p) => _normalizePhone(p.trim()))
          .where(_isValidRomanianPhone)
          .toList();

      if (phones.isNotEmpty) {
        _logger.addParsingStep('   -> Match direct gasit: Nume="$name", Telefoane="${phones.join(',')}"');
        contacts.add(ContactDetection(
          name: name,
          phone1: phones[0],
          phone2: phones.length > 1 ? phones[1] : null,
          confidence: 98.0, // Incredere mare pentru acest pattern
        ));
        // Oprim dupa primul match de incredere pe linie
        return contacts; 
      }
    }

    return contacts;
  }
}

/// Rezultatul validarii unui telefon
class PhoneValidationResult {
  final bool isValid;
  final String? correctedPhone;
  final double confidence;

  const PhoneValidationResult({
    required this.isValid,
    this.correctedPhone,
    required this.confidence,
  });
}

/// Telefon detectat
class PhoneDetection {
  final String number;
  final int lineIndex;
  final int position;
  final String raw;
  final double confidence;

  const PhoneDetection({
    required this.number,
    required this.lineIndex,
    required this.position,
    required this.raw,
    required this.confidence,
  });
}

/// Nume detectat
class NameDetection {
  final String name;
  final int lineIndex;
  final int position;
  final double confidence;

  const NameDetection({
    required this.name,
    required this.lineIndex,
    required this.position,
    required this.confidence,
  });
}

/// Contact detectat final
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

  /// Pentru compatibilitate
  String get phone => phone1;
}



