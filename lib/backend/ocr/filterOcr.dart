import 'package:flutter/foundation.dart';

/// Service pentru filtrarea și curățarea textului extras prin OCR
/// Elimină cuvintele nedorite și păstrează doar informațiile relevante pentru contacte
class FilterOcr {
  /// Singleton instance
  static final FilterOcr _instance = FilterOcr._internal();
  factory FilterOcr() => _instance;
  FilterOcr._internal();

  /// Filtrează textul OCR pentru a păstra doar informațiile relevante
  String filterOcrText(String rawText) {
    debugPrint('🧹 [FilterOcr] Începe filtrarea textului...');
    debugPrint('📝 [FilterOcr] Text original: ${rawText.length} caractere');

    try {
      // 1. Curățare de bază
      String cleaned = _basicCleaning(rawText);
      
      // 2. Filtrare cuvinte comune
      cleaned = _removeCommonWords(cleaned);
      
      // 3. Filtrare linii nedorite
      cleaned = _removeUnwantedLines(cleaned);
      
      // 4. Curățare finală
      cleaned = _finalCleaning(cleaned);
      
      debugPrint('✅ [FilterOcr] Text filtrat: ${cleaned.length} caractere');
      debugPrint('📄 [FilterOcr] Preview: ${cleaned.substring(0, cleaned.length > 200 ? 200 : cleaned.length)}...');
      
      return cleaned;

    } catch (e) {
      debugPrint('❌ [FilterOcr] Eroare la filtrare: $e');
      return rawText; // Returnează textul original dacă filtrarea eșuează
    }
  }

  /// Curățarea de bază a textului
  String _basicCleaning(String text) {
    String cleaned = text;
    
    // Elimină caracterele speciale problematice
    cleaned = cleaned.replaceAll(RegExp(r'[•◦▪▫►‣⁃]'), ''); // Bullet points
    cleaned = cleaned.replaceAll(RegExp(r'[|║│┃]'), ''); // Linii verticale
    cleaned = cleaned.replaceAll(RegExp(r'[─━═−‒–—]'), ' '); // Linii orizontale
    cleaned = cleaned.replaceAll(RegExp(r'[┌┐└┘├┤┬┴┼]'), ''); // Caractere box drawing
    
    // Normalizează spațiile
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\n\s*\n'), '\n');
    
    return cleaned.trim();
  }

  /// Elimină cuvintele comune care nu sunt utile
  String _removeCommonWords(String text) {
    final lines = text.split('\n');
    final filteredLines = <String>[];
    
    // Lista de cuvinte/fraze de eliminat
    final unwantedPatterns = [
      // Cuvinte Office/Excel
      r'\b(Excel|Word|PowerPoint|Outlook|Microsoft|Office)\b',
      r'\b(Sheet|Worksheet|Workbook|Cell|Column|Row)\b',
      r'\b(File|Edit|View|Insert|Format|Tools|Data|Window|Help)\b',
      r'\b(Copy|Paste|Cut|Undo|Redo|Save|Print|Delete)\b',
      
      // UI Elements
      r'\b(Button|Menu|Dialog|Window|Tab|Panel|Toolbar)\b',
      r'\b(Click|Double|Right|Left|Mouse|Keyboard)\b',
      r'\b(OK|Cancel|Yes|No|Apply|Close|Exit)\b',
      
      // Cuvinte tehnice comune
      r'\b(Page|Document|Text|Font|Size|Style|Color)\b',
      r'\b(Format|Align|Bold|Italic|Underline)\b',
      r'\b(Sort|Filter|Search|Find|Replace)\b',
      
      // Cuvinte în alte limbi decât română
      r'\b(the|and|or|but|is|are|was|were|have|has|had)\b',
      r'\b(this|that|these|those|here|there|where|when|why|how)\b',
      
      // Headers/Labels generice
      r'\b(NUME|NAME|TELEFON|PHONE|CONTACT|CLIENT|ADRESA|ADDRESS)\b',
      r'\b(EMAIL|MAIL|FAX|WEBSITE|SITE|WWW|HTTP|HTTPS)\b',
    ];
    
    for (final line in lines) {
      String cleanLine = line.trim();
      
      if (cleanLine.isEmpty) continue;
      
      // Verifică dacă linia conține pattern-uri nedorite
      bool shouldRemove = false;
      for (final pattern in unwantedPatterns) {
        if (RegExp(pattern, caseSensitive: false).hasMatch(cleanLine)) {
          shouldRemove = true;
          break;
        }
      }
      
      if (!shouldRemove) {
        filteredLines.add(cleanLine);
      }
    }
    
    return filteredLines.join('\n');
  }

  /// Elimină liniile nedorite pe baza unor criterii
  String _removeUnwantedLines(String text) {
    final lines = text.split('\n');
    final filteredLines = <String>[];
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      if (trimmedLine.isEmpty) continue;
      
      // Elimină liniile prea scurte (probabil nu sunt contacte)
      if (trimmedLine.length < 3) continue;
      
      // Elimină liniile care sunt doar cifre (probabil coduri/ID-uri)
      if (RegExp(r'^\d+$').hasMatch(trimmedLine)) continue;
      
      // Elimină liniile care sunt doar caractere speciale
      if (RegExp(r'^[^\w\s]+$').hasMatch(trimmedLine)) continue;
      
      // Elimină liniile care sunt doar o singură literă repetată
      if (RegExp(r'^(.)\1*$').hasMatch(trimmedLine)) continue;
      
      // Elimină liniile care par să fie headers/separatori
      if (RegExp(r'^[=\-_\s]+$').hasMatch(trimmedLine)) continue;
      
      // Păstrează linia dacă a trecut de toate filtrele
      filteredLines.add(trimmedLine);
    }
    
    return filteredLines.join('\n');
  }

  /// Curățarea finală a textului
  String _finalCleaning(String text) {
    String cleaned = text;
    
    // Elimină liniile care se repetă
    final lines = cleaned.split('\n');
    final uniqueLines = <String>[];
    final seenLines = <String>{};
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isNotEmpty && !seenLines.contains(trimmedLine)) {
        uniqueLines.add(trimmedLine);
        seenLines.add(trimmedLine);
      }
    }
    
    cleaned = uniqueLines.join('\n');
    
    // Normalizare finală
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\n\s*\n'), '\n');
    cleaned = cleaned.trim();
    
    return cleaned;
  }

  /// Verifică dacă textul filtrat conține potențiale contacte
  bool hasValidContent(String filteredText) {
    if (filteredText.trim().isEmpty) {
      return false;
    }
    
    final lines = filteredText.split('\n');
    
    // Verifică dacă există cel puțin o linie care ar putea fi un nume sau telefon
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // Verifică pentru nume (litere cu majusculă)
      if (RegExp(r'\b[A-ZĂÂÎȘȚ][a-zăâîșț]+\s+[A-ZĂÂÎȘȚ][a-zăâîșț]+\b').hasMatch(trimmedLine)) {
        return true;
      }
      
      // Verifică pentru telefoane
      if (RegExp(r'\b0[0-9]{9}\b|\b\+40[0-9]{9}\b').hasMatch(trimmedLine)) {
        return true;
      }
    }
    
    return false;
  }

  /// Returnează statistici despre filtrare
  FilterStats getFilterStats(String originalText, String filteredText) {
         final originalLines = originalText.split('\n').where((l) => l.trim().isNotEmpty).toList().length;
         final filteredLines = filteredText.split('\n').where((l) => l.trim().isNotEmpty).toList().length;
    
    return FilterStats(
      originalCharacters: originalText.length,
      filteredCharacters: filteredText.length,
      originalLines: originalLines,
      filteredLines: filteredLines,
      reductionPercentage: originalText.length > 0 
          ? ((originalText.length - filteredText.length) / originalText.length * 100)
          : 0.0,
    );
  }
}

/// Statistici despre procesul de filtrare
class FilterStats {
  final int originalCharacters;
  final int filteredCharacters;
  final int originalLines;
  final int filteredLines;
  final double reductionPercentage;

  const FilterStats({
    required this.originalCharacters,
    required this.filteredCharacters,
    required this.originalLines,
    required this.filteredLines,
    required this.reductionPercentage,
  });

  @override
  String toString() {
    return 'FilterStats(chars: $originalCharacters→$filteredCharacters, '
           'lines: $originalLines→$filteredLines, '
           'reduction: ${reductionPercentage.toStringAsFixed(1)}%)';
  }
}
