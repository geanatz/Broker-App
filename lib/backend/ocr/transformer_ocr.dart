import 'package:flutter/foundation.dart';

/// Service pentru transformarea si curatarea textului OCR
class TransformerOCR {
  static final TransformerOCR _instance = TransformerOCR._internal();
  factory TransformerOCR() => _instance;
  TransformerOCR._internal();

  /// Transforma textul OCR brut intr-un format curat si structurat
  Future<TransformResult> transformText(String rawText) async {
    try {
      debugPrint('🔄 TRANSFORMER_OCR: Incepe transformarea textului (${rawText.length} caractere)');
      
      if (rawText.isEmpty) {
        return TransformResult(
          originalText: rawText,
          cleanedText: '',
          confidence: 0.0,
          improvements: [],
        );
      }
      
      var transformedText = rawText;
      final improvements = <String>[];
      
      // 1. Curatarea caracterelor OCR gresite
      final characterResult = _fixOCRCharacters(transformedText);
      transformedText = characterResult.text;
      improvements.addAll(characterResult.improvements);
      
      // 2. Corectarea numerelor de telefon
      final phoneResult = _fixPhoneNumbers(transformedText);
      transformedText = phoneResult.text;
      improvements.addAll(phoneResult.improvements);
      
      // 3. Standardizarea spatiilor si formatarii
      final spacingResult = _standardizeSpacing(transformedText);
      transformedText = spacingResult.text;
      improvements.addAll(spacingResult.improvements);
      
      // 4. Corectarea CNP-urilor
      final cnpResult = _fixCNPs(transformedText);
      transformedText = cnpResult.text;
      improvements.addAll(cnpResult.improvements);
      
      // 5. Imbunatatirea numelor proprii
      final nameResult = _fixProperNames(transformedText);
      transformedText = nameResult.text;
      improvements.addAll(nameResult.improvements);
      
      // 6. Curatarea finala
      transformedText = _finalCleanup(transformedText);
      
      // Calculeaza confidence score
      final confidence = _calculateConfidence(rawText, transformedText, improvements);
      
      debugPrint('✅ TRANSFORMER_OCR: Text transformat cu ${improvements.length} imbunatatiri');
      debugPrint('📊 TRANSFORMER_OCR: Confidence score: ${(confidence * 100).toStringAsFixed(1)}%');
      
      return TransformResult(
        originalText: rawText,
        cleanedText: transformedText,
        confidence: confidence,
        improvements: improvements,
      );

      } catch (e) {
      debugPrint('❌ TRANSFORMER_OCR: Eroare la transformarea textului: $e');
      return TransformResult(
        originalText: rawText,
        cleanedText: rawText,
        confidence: 0.0,
        improvements: ['Eroare la procesare: $e'],
      );
    }
  }

  /// Corecteaza caracterele OCR comune gresite
  TransformStep _fixOCRCharacters(String text) {
    var fixed = text;
    final improvements = <String>[];
    
    // Mapa de caractere OCR comune gresite
    final characterMap = {
      // Cifre comune gresite
      'O': '0', 'o': '0', '°': '0',
      'I': '1', 'l': '1', '|': '1',
      'S': '5', '§': '5',
      'G': '6', 'g': '6',
      'T': '7', 't': '7',
      'B': '8',
      
      // Litere comune gresite
      '0': 'O', '1': 'I', '5': 'S', '6': 'G', '7': 'T', '8': 'B',
      
      // Caractere speciale romanesti
      'ã': 'a', 'a': 'a', 'a': 'a',
      'i': 'i', 'ï': 'i',
      'ş': 's', 's': 's',
      'ţ': 't', 't': 't',
    };
    
    int changes = 0;
    
    // Aplica corectarile in context
    for (final entry in characterMap.entries) {
      final before = fixed;
      
      // Pentru numere de telefon si CNP-uri
      if (RegExp(r'\d').hasMatch(entry.value)) {
        // Inlocuieste doar in contexte numerice
        fixed = fixed.replaceAllMapped(
          RegExp('${RegExp.escape(entry.key)}(?=\\d)|(?<=\\d)${RegExp.escape(entry.key)}'),
          (match) => entry.value,
        );
      } else {
        // Pentru text normal
        fixed = fixed.replaceAllMapped(
          RegExp('\\b${RegExp.escape(entry.key)}(?=[a-zA-Z])|(?<=[a-zA-Z])${RegExp.escape(entry.key)}\\b'),
          (match) => entry.value,
        );
      }
      
      if (before != fixed) {
        changes++;
      }
    }
    
    if (changes > 0) {
      improvements.add('Corectate $changes caractere OCR gresite');
    }
    
    return TransformStep(text: fixed, improvements: improvements);
  }

  /// Corecteaza si standardizeaza numerele de telefon
  TransformStep _fixPhoneNumbers(String text) {
    var fixed = text;
    final improvements = <String>[];
    
    // Regex pentru identificarea numerelor de telefon posibile
    final phonePatterns = [
      RegExp(r'(\+?4?0?[7][0-9O][0-9O][0-9O][0-9O][0-9O][0-9O][0-9O][0-9O])'),
      RegExp(r'(\+?4?0?[2-6][0-9O][0-9O][0-9O][0-9O][0-9O][0-9O][0-9O][0-9O])'),
    ];
    
    int fixes = 0;
    
    for (final pattern in phonePatterns) {
      fixed = fixed.replaceAllMapped(pattern, (match) {
        var phone = match.group(0)!;
        
        // Curata caracterele non-numerice (pastreaza +)
        var cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
        
        // Corecteaza caracterele OCR in numere
        cleaned = cleaned
            .replaceAll('O', '0')
            .replaceAll('o', '0')
            .replaceAll('I', '1')
            .replaceAll('l', '1')
            .replaceAll('|', '1')
            .replaceAll('S', '5')
            .replaceAll('§', '5');
        
        // Standardizeaza formatul
        if (cleaned.startsWith('+407')) {
          cleaned = '07${cleaned.substring(4)}';
        } else if (cleaned.startsWith('+40') && cleaned.length == 12) {
          cleaned = '0${cleaned.substring(3)}';
        } else if (cleaned.startsWith('407')) {
          cleaned = '07${cleaned.substring(3)}';
        } else if (cleaned.startsWith('40') && cleaned.length == 11) {
          cleaned = '0${cleaned.substring(2)}';
        }
        
        // Valideaza lungimea
        if (cleaned.length == 10 && cleaned.startsWith('07')) {
          fixes++;
          return cleaned;
        } else if (cleaned.length == 10 && RegExp(r'^0[2-6]').hasMatch(cleaned)) {
          fixes++;
          return cleaned;
        }
        
        return phone; // Returneaza originalul daca nu poate fi corectat
      });
    }
    
    if (fixes > 0) {
      improvements.add('Corectate si standardizate $fixes numere de telefon');
    }
    
    return TransformStep(text: fixed, improvements: improvements);
  }

  /// Standardizeaza spatiile si formatarea
  TransformStep _standardizeSpacing(String text) {
    var fixed = text;
    final improvements = <String>[];
    
    // Inlocuieste multiple spatii cu unul singur
    final beforeSpaces = fixed;
    fixed = fixed.replaceAll(RegExp(r'\s+'), ' ');
    if (beforeSpaces != fixed) {
      improvements.add('Standardizate spatiile multiple');
    }
    
    // Curata spatiile de la inceput si sfarsit
    final beforeTrim = fixed;
    fixed = fixed.trim();
    if (beforeTrim != fixed) {
      improvements.add('Eliminate spatiile de la capete');
    }
    
    // Standardizeaza separatorii de linie
    final beforeLines = fixed;
    fixed = fixed.replaceAll(RegExp(r'\r\n|\r'), '\n');
    if (beforeLines != fixed) {
      improvements.add('Standardizate separatorii de linie');
    }
    
    // Elimina liniile goale multiple
    final beforeEmptyLines = fixed;
    fixed = fixed.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');
    if (beforeEmptyLines != fixed) {
      improvements.add('Eliminate liniile goale multiple');
    }
    
    return TransformStep(text: fixed, improvements: improvements);
  }

  /// Corecteaza CNP-urile
  TransformStep _fixCNPs(String text) {
    var fixed = text;
    final improvements = <String>[];
    
    // Regex pentru identificarea CNP-urilor posibile
    final cnpPattern = RegExp(r'\b[1-8O][0-9O]{12}\b');
    
    int fixes = 0;
    
    fixed = fixed.replaceAllMapped(cnpPattern, (match) {
      var cnp = match.group(0)!;
      
      // Corecteaza caracterele OCR
      cnp = cnp
          .replaceAll('O', '0')
          .replaceAll('o', '0')
          .replaceAll('I', '1')
          .replaceAll('l', '1')
          .replaceAll('|', '1')
          .replaceAll('S', '5')
          .replaceAll('§', '5');
      
      // Valideaza prima cifra (gen)
      if (RegExp(r'^[1-8]').hasMatch(cnp) && cnp.length == 13) {
        fixes++;
        return cnp;
      }
      
      return match.group(0)!; // Returneaza originalul
    });
    
    if (fixes > 0) {
      improvements.add('Corectate $fixes CNP-uri');
    }
    
    return TransformStep(text: fixed, improvements: improvements);
  }

  /// Imbunatateste numele proprii (capitalize)
  TransformStep _fixProperNames(String text) {
    var fixed = text;
    final improvements = <String>[];
    
    // Regex pentru identificarea numelor (2+ cuvinte cu prima litera mare)
    final namePattern = RegExp(r'\b[A-ZAAIST][a-zaaist]+\s+[A-ZAAIST][a-zaaist]+(?:\s+[A-ZAAIST][a-zaaist]+)*\b');
    
    int fixes = 0;
    
    fixed = fixed.replaceAllMapped(namePattern, (match) {
      final name = match.group(0)!;
      final words = name.split(' ');
      
      // Capitalize fiecare cuvant
      final capitalizedWords = words.map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).toList();
      
      final capitalizedName = capitalizedWords.join(' ');
      
      if (capitalizedName != name) {
        fixes++;
        return capitalizedName;
      }
      
      return name;
    });
    
    if (fixes > 0) {
      improvements.add('Corectate $fixes nume proprii');
    }
    
    return TransformStep(text: fixed, improvements: improvements);
  }

  /// Curatarea finala a textului
  String _finalCleanup(String text) {
    debugPrint('🧹 TRANSFORMER_OCR: Text inainte de curatare finala: "${text.substring(0, text.length.clamp(0, 100))}..."');
    
    final cleaned = text
        .replaceAll(RegExp(r'[^\w\s\+\-\.\(\)\[\]\/\\:;,!?@#\$%&*=\u0100-\u017F\u0102\u0103\u00C2\u00E2\u00CE\u00EE\u0218\u0219\u021A\u021B]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    
    debugPrint('🧹 TRANSFORMER_OCR: Text dupa curatare finala: "${cleaned.substring(0, cleaned.length.clamp(0, 100))}..."');
    return cleaned;
  }

  /// Calculeaza confidence score bazat pe imbunatatiri
  double _calculateConfidence(String original, String cleaned, List<String> improvements) {
    if (original.isEmpty) return 0.0;
    
    // Baza de confidence
    double confidence = 0.7; // 70% de baza
    
    // Adauga puncte pentru fiecare imbunatatire
    confidence += improvements.length * 0.05;
    
    // Adauga puncte pentru lungimea textului (mai mult text = mai multa incredere)
    final lengthFactor = (cleaned.length / 1000).clamp(0.0, 0.2);
    confidence += lengthFactor;
    
    // Scade puncte pentru diferente mari (posibile erori)
    final diffRatio = (original.length - cleaned.length).abs() / original.length;
    if (diffRatio > 0.3) {
      confidence -= 0.1;
    }
    
    return confidence.clamp(0.0, 1.0);
  }

  /// Obtine statistici despre text
  TextStatistics getTextStatistics(String text) {
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).length;
    final words = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
    final characters = text.length;
    
    final phoneMatches = RegExp(r'\b0[7][0-9]{8}\b|\b0[2-6][0-9]{8}\b').allMatches(text).length;
    final cnpMatches = RegExp(r'\b[1-8][0-9]{12}\b').allMatches(text).length;
    final nameMatches = RegExp(r'\b[A-ZAAIST][a-zaaist]+\s+[A-ZAAIST][a-zaaist]+\b').allMatches(text).length;
    
    return TextStatistics(
      lines: lines,
      words: words,
      characters: characters,
      phoneNumbers: phoneMatches,
      cnps: cnpMatches,
      names: nameMatches,
    );
  }
}

/// Rezultatul unei etape de transformare
class TransformStep {
  final String text;
  final List<String> improvements;
  
  const TransformStep({
    required this.text,
    required this.improvements,
  });
}

/// Rezultatul transformarii complete
class TransformResult {
  final String originalText;
  final String cleanedText;
  final double confidence;
  final List<String> improvements;
  
  const TransformResult({
    required this.originalText,
    required this.cleanedText,
    required this.confidence,
    required this.improvements,
  });
  
  /// Statistici comparate
  String get improvementSummary {
    if (improvements.isEmpty) {
      return 'Nu au fost necesare imbunatatiri';
    }
    
    return '${improvements.length} imbunatatiri aplicate:\n${improvements.map((i) => '• $i').join('\n')}';
  }
  
  @override
  String toString() => 'TransformResult(confidence: $confidence, improvements: ${improvements.length})';
}

/// Statistici despre text
class TextStatistics {
  final int lines;
  final int words;
  final int characters;
  final int phoneNumbers;
  final int cnps;
  final int names;
  
  const TextStatistics({
    required this.lines,
    required this.words,
    required this.characters,
    required this.phoneNumbers,
    required this.cnps,
    required this.names,
  });

  @override
  String toString() => 'TextStatistics(lines: $lines, words: $words, phones: $phoneNumbers, cnps: $cnps, names: $names)';
}

 