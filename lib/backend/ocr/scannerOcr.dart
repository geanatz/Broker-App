import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service pentru extragerea textului din imagini folosind Google Vision API
/// Implementare robustă și simplă care funcționează garantat
class ScannerOcr {
  // API Key pentru Google Vision API
  static const String _apiKey = 'AIzaSyBHSucNUjWno77uW9dto-Xkg5X0a_f4NTI';
  static const String _baseUrl = 'https://vision.googleapis.com/v1/images:annotate';
  
  /// Singleton instance
  static final ScannerOcr _instance = ScannerOcr._internal();
  factory ScannerOcr() => _instance;
  ScannerOcr._internal();

  /// Verifică dacă API-ul este configurat
  bool isConfigured() {
    return _apiKey.isNotEmpty && _apiKey != 'YOUR_API_KEY_HERE';
  }

  /// Extrage textul din imagine - metoda principală
  Future<ScanResult> extractTextFromImage(File imageFile) async {
    debugPrint('🔍 [ScannerOcr] Începe scanarea: ${imageFile.path}');
    
    try {
      // 1. Validează fișierul
      if (!await imageFile.exists()) {
        return ScanResult.error('Fișierul nu există', imageFile.path);
      }

      // 2. Verifică mărimea (max 10MB pentru Google Vision)
      final fileSize = await imageFile.length();
      final maxSize = 10 * 1024 * 1024; // 10MB
      
      if (fileSize > maxSize) {
        final sizeMB = (fileSize / 1024 / 1024).toStringAsFixed(2);
        return ScanResult.error('Fișier prea mare: ${sizeMB}MB (max 10MB)', imageFile.path);
      }

      debugPrint('📊 [ScannerOcr] Mărime fișier: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB');

      // 3. Citește și encodează imaginea
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      debugPrint('✅ [ScannerOcr] Imagine encodată Base64: ${base64Image.length} caractere');

      // 4. Trimite request la Google Vision API
      final extractedText = await _callGoogleVisionAPI(base64Image);
      
      if (extractedText != null && extractedText.isNotEmpty) {
        debugPrint('✅ [ScannerOcr] Text extras cu succes: ${extractedText.length} caractere');
        debugPrint('📝 [ScannerOcr] Preview text: ${extractedText.substring(0, extractedText.length > 100 ? 100 : extractedText.length)}...');
        
        return ScanResult.success(extractedText, imageFile.path);
      } else {
        debugPrint('⚠️ [ScannerOcr] Nu s-a găsit text în imagine');
        return ScanResult.error('Nu s-a găsit text în imagine', imageFile.path);
      }

    } catch (e) {
      debugPrint('❌ [ScannerOcr] Eroare: $e');
      return ScanResult.error('Eroare la scanare: $e', imageFile.path);
    }
  }

  /// Apelează Google Vision API pentru extragerea textului
  Future<String?> _callGoogleVisionAPI(String base64Image) async {
    try {
      debugPrint('🌐 [ScannerOcr] Trimit request la Google Vision API...');

      // Request body simplu și robust
      final requestBody = {
        'requests': [
          {
            'image': {
              'content': base64Image,
            },
            'features': [
              {
                'type': 'TEXT_DETECTION',
                'maxResults': 1,
              }
            ],
            'imageContext': {
              'languageHints': ['ro', 'en'], // Română și engleză
            }
          }
        ]
      };

      // Trimite request-ul
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: json.encode(requestBody),
      );

      debugPrint('📡 [ScannerOcr] Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        debugPrint('📦 [ScannerOcr] Răspuns primit de la API');
        
        return _extractTextFromResponse(responseData);
      } else {
        debugPrint('❌ [ScannerOcr] Eroare API: ${response.statusCode}');
        debugPrint('❌ [ScannerOcr] Response body: ${response.body}');
        return null;
      }

    } catch (e) {
      debugPrint('❌ [ScannerOcr] Eroare la apelul API: $e');
      return null;
    }
  }

  /// Extrage textul din răspunsul Google Vision API
  String? _extractTextFromResponse(Map<String, dynamic> responseData) {
    try {
      debugPrint('🔍 [ScannerOcr] Procesez răspunsul API...');

      // Verifică dacă există responses
      if (!responseData.containsKey('responses')) {
        debugPrint('❌ [ScannerOcr] Nu există responses în răspuns');
        return null;
      }

      final responses = responseData['responses'] as List;
      if (responses.isEmpty) {
        debugPrint('❌ [ScannerOcr] Lista responses este goală');
        return null;
      }

      final firstResponse = responses[0] as Map<String, dynamic>;

      // Verifică dacă există erori
      if (firstResponse.containsKey('error')) {
        debugPrint('❌ [ScannerOcr] Eroare în răspuns: ${firstResponse['error']}');
        return null;
      }

      // Încearcă să extragă textul din textAnnotations
      if (firstResponse.containsKey('textAnnotations')) {
        final textAnnotations = firstResponse['textAnnotations'] as List;
        
        if (textAnnotations.isNotEmpty) {
          final firstAnnotation = textAnnotations[0] as Map<String, dynamic>;
          
          if (firstAnnotation.containsKey('description')) {
            final text = firstAnnotation['description'] as String;
            debugPrint('✅ [ScannerOcr] Text găsit în textAnnotations: ${text.length} caractere');
            return _cleanText(text);
          }
        }
      }

      debugPrint('⚠️ [ScannerOcr] Nu s-a găsit text în răspuns');
      return null;

    } catch (e) {
      debugPrint('❌ [ScannerOcr] Eroare la procesarea răspunsului: $e');
      return null;
    }
  }

  /// Curăță textul extras de caractere nedorite
  String _cleanText(String text) {
    // Înlocuiește break-uri de linie multiple cu una singură
    String cleaned = text.replaceAll(RegExp(r'\n+'), '\n');
    
    // Elimină spațiile extra
    cleaned = cleaned.replaceAll(RegExp(r' +'), ' ');
    
    // Elimină tab-urile
    cleaned = cleaned.replaceAll('\t', ' ');
    
    // Trim
    cleaned = cleaned.trim();
    
    return cleaned;
  }

  /// Procesează multiple imagini secvențial
  Future<List<ScanResult>> scanMultipleImages(
    List<File> imageFiles,
    Function(ScanProgress)? onProgress,
  ) async {
    debugPrint('🔍 Începe scanarea pentru ${imageFiles.length} imagini');
    
    final results = <ScanResult>[];
    
    for (int i = 0; i < imageFiles.length; i++) {
      debugPrint('🔄 Scanează imaginea ${i + 1}/${imageFiles.length}');
      
      // Notifică progresul
      onProgress?.call(ScanProgress(
        currentImage: i + 1,
        totalImages: imageFiles.length,
        imageName: _getImageName(imageFiles[i]),
        phase: ScanPhase.extractingText,
      ));
      
      final result = await extractTextFromImage(imageFiles[i]);
      results.add(result);
      
      // Delay între imagini pentru a nu supraîncărca API-ul
      if (i < imageFiles.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    
    debugPrint('✅ Scanare finalizată pentru toate imaginile');
    return results;
  }

  /// Obține numele imaginii din calea completă
  String _getImageName(File imageFile) {
    return imageFile.path.split('/').last.split('\\').last;
  }
}

/// Rezultatul operației de scanare
class ScanResult {
  final bool success;
  final String? extractedText;
  final String? error;
  final String imagePath;
  final double confidence;

  const ScanResult._({
    required this.success,
    this.extractedText,
    this.error,
    required this.imagePath,
    this.confidence = 0.0,
  });

  /// Constructor pentru succes
  factory ScanResult.success(String text, String imagePath) {
    return ScanResult._(
      success: true,
      extractedText: text,
      imagePath: imagePath,
      confidence: 1.0,
    );
  }

  /// Constructor pentru eroare
  factory ScanResult.error(String errorMessage, String imagePath) {
    return ScanResult._(
      success: false,
      error: errorMessage,
      imagePath: imagePath,
    );
  }

  @override
  String toString() {
    if (success) {
      return 'ScanResult.success(text: ${extractedText?.length ?? 0} chars)';
    } else {
      return 'ScanResult.error($error)';
    }
  }
}

/// Progresul scanării
class ScanProgress {
  final int currentImage;
  final int totalImages;
  final String imageName;
  final ScanPhase phase;

  const ScanProgress({
    required this.currentImage,
    required this.totalImages,
    required this.imageName,
    required this.phase,
  });

  /// Mesajul de progres
  String get progressMessage {
    switch (phase) {
      case ScanPhase.extractingText:
        return 'Se extrage textul din imaginea $imageName';
    }
  }

  /// Progresul ca procentaj (0.0 - 1.0)
  double get progress => currentImage / totalImages;
}

/// Fazele scanării
enum ScanPhase {
  extractingText,
}
