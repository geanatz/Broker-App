import 'package:flutter/foundation.dart';

/// Service pentru transformarea și curățarea textului OCR
class TransformerOCR {
  static final TransformerOCR _instance = TransformerOCR._internal();
  factory TransformerOCR() => _instance;
  TransformerOCR._internal();

  /// Transformă textul OCR brut într-un format curat și structurat
  Future<TransformResult> transformText(String rawText) async {
    try {
      debugPrint('🔄 TRANSFORMER_OCR: Începe transformarea textului (${rawText.length} caractere)');
      
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
      
      // 1. Curățarea caracterelor OCR greșite
      final characterResult = _fixOCRCharacters(transformedText);
      transformedText = characterResult.text;
      improvements.addAll(characterResult.improvements);
      
      // 2. Corectarea numerelor de telefon
      final phoneResult = _fixPhoneNumbers(transformedText);
      transformedText = phoneResult.text;
      improvements.addAll(phoneResult.improvements);
      
      // 3. Standardizarea spațiilor și formatării
      final spacingResult = _standardizeSpacing(transformedText);
      transformedText = spacingResult.text;
      improvements.addAll(spacingResult.improvements);
      
      // 4. Corectarea CNP-urilor
      final cnpResult = _fixCNPs(transformedText);
      transformedText = cnpResult.text;
      improvements.addAll(cnpResult.improvements);
      
      // 5. Îmbunătățirea numelor proprii
      final nameResult = _fixProperNames(transformedText);
      transformedText = nameResult.text;
      improvements.addAll(nameResult.improvements);
      
      // 6. Curățarea finală
      transformedText = _finalCleanup(transformedText);
      
      // Calculează confidence score
      final confidence = _calculateConfidence(rawText, transformedText, improvements);
      
      debugPrint('✅ TRANSFORMER_OCR: Text transformat cu ${improvements.length} îmbunătățiri');
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

  /// Corectează caracterele OCR comune greșite
  TransformStep _fixOCRCharacters(String text) {
    var fixed = text;
    final improvements = <String>[];
    
    // Mapă de caractere OCR comune greșite
    final characterMap = {
      // Cifre comune greșite
      'O': '0', 'o': '0', '°': '0',
      'I': '1', 'l': '1', '|': '1',
      'S': '5', '§': '5',
      'G': '6', 'g': '6',
      'T': '7', 't': '7',
      'B': '8',
      
      // Litere comune greșite
      '0': 'O', '1': 'I', '5': 'S', '6': 'G', '7': 'T', '8': 'B',
      
      // Caractere speciale românești
      'ã': 'a', 'â': 'a', 'ă': 'a',
      'î': 'i', 'ï': 'i',
      'ş': 's', 'ș': 's',
      'ţ': 't', 'ț': 't',
    };
    
    int changes = 0;
    
    // Aplică corectările în context
    for (final entry in characterMap.entries) {
      final before = fixed;
      
      // Pentru numere de telefon și CNP-uri
      if (RegExp(r'\d').hasMatch(entry.value)) {
        // Înlocuiește doar în contexte numerice
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
      improvements.add('Corectate $changes caractere OCR greșite');
    }
    
    return TransformStep(text: fixed, improvements: improvements);
  }

  /// Corectează și standardizează numerele de telefon
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
        
        // Curăță caracterele non-numerice (păstrează +)
        var cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
        
        // Corectează caracterele OCR în numere
        cleaned = cleaned
            .replaceAll('O', '0')
            .replaceAll('o', '0')
            .replaceAll('I', '1')
            .replaceAll('l', '1')
            .replaceAll('|', '1')
            .replaceAll('S', '5')
            .replaceAll('§', '5');
        
        // Standardizează formatul
        if (cleaned.startsWith('+407')) {
          cleaned = '07${cleaned.substring(4)}';
        } else if (cleaned.startsWith('+40') && cleaned.length == 12) {
          cleaned = '0${cleaned.substring(3)}';
        } else if (cleaned.startsWith('407')) {
          cleaned = '07${cleaned.substring(3)}';
        } else if (cleaned.startsWith('40') && cleaned.length == 11) {
          cleaned = '0${cleaned.substring(2)}';
        }
        
        // Validează lungimea
        if (cleaned.length == 10 && cleaned.startsWith('07')) {
          fixes++;
          return cleaned;
        } else if (cleaned.length == 10 && RegExp(r'^0[2-6]').hasMatch(cleaned)) {
          fixes++;
          return cleaned;
        }
        
        return phone; // Returnează originalul dacă nu poate fi corectat
      });
    }
    
    if (fixes > 0) {
      improvements.add('Corectate și standardizate $fixes numere de telefon');
    }
    
    return TransformStep(text: fixed, improvements: improvements);
  }

  /// Standardizează spațiile și formatarea
  TransformStep _standardizeSpacing(String text) {
    var fixed = text;
    final improvements = <String>[];
    
    // Înlocuiește multiple spații cu unul singur
    final beforeSpaces = fixed;
    fixed = fixed.replaceAll(RegExp(r'\s+'), ' ');
    if (beforeSpaces != fixed) {
      improvements.add('Standardizate spațiile multiple');
    }
    
    // Curăță spațiile de la început și sfârșit
    final beforeTrim = fixed;
    fixed = fixed.trim();
    if (beforeTrim != fixed) {
      improvements.add('Eliminate spațiile de la capete');
    }
    
    // Standardizează separatorii de linie
    final beforeLines = fixed;
    fixed = fixed.replaceAll(RegExp(r'\r\n|\r'), '\n');
    if (beforeLines != fixed) {
      improvements.add('Standardizate separatorii de linie');
    }
    
    // Elimină liniile goale multiple
    final beforeEmptyLines = fixed;
    fixed = fixed.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');
    if (beforeEmptyLines != fixed) {
      improvements.add('Eliminate liniile goale multiple');
    }
    
    return TransformStep(text: fixed, improvements: improvements);
  }

  /// Corectează CNP-urile
  TransformStep _fixCNPs(String text) {
    var fixed = text;
    final improvements = <String>[];
    
    // Regex pentru identificarea CNP-urilor posibile
    final cnpPattern = RegExp(r'\b[1-8O][0-9O]{12}\b');
    
    int fixes = 0;
    
    fixed = fixed.replaceAllMapped(cnpPattern, (match) {
      var cnp = match.group(0)!;
      
      // Corectează caracterele OCR
      cnp = cnp
          .replaceAll('O', '0')
          .replaceAll('o', '0')
          .replaceAll('I', '1')
          .replaceAll('l', '1')
          .replaceAll('|', '1')
          .replaceAll('S', '5')
          .replaceAll('§', '5');
      
      // Validează prima cifră (gen)
      if (RegExp(r'^[1-8]').hasMatch(cnp) && cnp.length == 13) {
        fixes++;
        return cnp;
      }
      
      return match.group(0)!; // Returnează originalul
    });
    
    if (fixes > 0) {
      improvements.add('Corectate $fixes CNP-uri');
    }
    
    return TransformStep(text: fixed, improvements: improvements);
  }

  /// Îmbunătățește numele proprii (capitalize)
  TransformStep _fixProperNames(String text) {
    var fixed = text;
    final improvements = <String>[];
    
    // Regex pentru identificarea numelor (2+ cuvinte cu prima literă mare)
    final namePattern = RegExp(r'\b[A-ZĂÂÎȘȚ][a-zăâîșț]+\s+[A-ZĂÂÎȘȚ][a-zăâîșț]+(?:\s+[A-ZĂÂÎȘȚ][a-zăâîșț]+)*\b');
    
    int fixes = 0;
    
    fixed = fixed.replaceAllMapped(namePattern, (match) {
      final name = match.group(0)!;
      final words = name.split(' ');
      
      // Capitalize fiecare cuvânt
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

  /// Curățarea finală a textului
  String _finalCleanup(String text) {
    return text
        .replaceAll(RegExp(r'[^\w\s\+\-\.\(\)\[\]\/\\:;,!?@#\$%&*=\u0100-\u017F]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Calculează confidence score bazat pe îmbunătățiri
  double _calculateConfidence(String original, String cleaned, List<String> improvements) {
    if (original.isEmpty) return 0.0;
    
    // Baza de confidence
    double confidence = 0.7; // 70% de bază
    
    // Adaugă puncte pentru fiecare îmbunătățire
    confidence += improvements.length * 0.05;
    
    // Adaugă puncte pentru lungimea textului (mai mult text = mai multă încredere)
    final lengthFactor = (cleaned.length / 1000).clamp(0.0, 0.2);
    confidence += lengthFactor;
    
    // Scade puncte pentru diferențe mari (posibile erori)
    final diffRatio = (original.length - cleaned.length).abs() / original.length;
    if (diffRatio > 0.3) {
      confidence -= 0.1;
    }
    
    return confidence.clamp(0.0, 1.0);
  }

  /// Obține statistici despre text
  TextStatistics getTextStatistics(String text) {
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).length;
    final words = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
    final characters = text.length;
    
    final phoneMatches = RegExp(r'\b0[7][0-9]{8}\b|\b0[2-6][0-9]{8}\b').allMatches(text).length;
    final cnpMatches = RegExp(r'\b[1-8][0-9]{12}\b').allMatches(text).length;
    final nameMatches = RegExp(r'\b[A-ZĂÂÎȘȚ][a-zăâîșț]+\s+[A-ZĂÂÎȘȚ][a-zăâîșț]+\b').allMatches(text).length;
    
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

/// Rezultatul transformării complete
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
      return 'Nu au fost necesare îmbunătățiri';
    }
    
    return '${improvements.length} îmbunătățiri aplicate:\n${improvements.map((i) => '• $i').join('\n')}';
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

 