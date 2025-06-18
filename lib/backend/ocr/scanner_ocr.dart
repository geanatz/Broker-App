import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service pentru extragerea textului din imagini folosind Google Vision API
/// Implementare robusta si simpla care functioneaza garantat
class ScannerOcr {
  // API Key pentru Google Vision API
  static const String _apiKey = 'AIzaSyBHSucNUjWno77uW9dto-Xkg5X0a_f4NTI';
  static const String _baseUrl = 'https://vision.googleapis.com/v1/images:annotate';
  
  /// Singleton instance
  static final ScannerOcr _instance = ScannerOcr._internal();
  factory ScannerOcr() => _instance;
  ScannerOcr._internal();

  /// Verifica daca API-ul este configurat
  bool isConfigured() {
    return _apiKey.isNotEmpty && _apiKey != 'YOUR_API_KEY_HERE';
  }

  /// Extrage textul din imagine - metoda principala
  Future<ScanResult> extractTextFromImage(File imageFile) async {
    debugPrint('🔍 [ScannerOcr] Incepe scanarea: ${imageFile.path}');
    
    try {
      // 1. Valideaza fisierul
      if (!await imageFile.exists()) {
        return ScanResult.error('Fisierul nu exista', imageFile.path);
      }

      // 2. Verifica marimea (max 10MB pentru Google Vision)
      final fileSize = await imageFile.length();
      final maxSize = 10 * 1024 * 1024; // 10MB
      
      if (fileSize > maxSize) {
        final sizeMB = (fileSize / 1024 / 1024).toStringAsFixed(2);
        return ScanResult.error('Fisier prea mare: ${sizeMB}MB (max 10MB)', imageFile.path);
      }

      debugPrint('📊 [ScannerOcr] Marime fisier: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB');

      // 3. Citeste si encodeaza imaginea
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      debugPrint('✅ [ScannerOcr] Imagine encodata Base64: ${base64Image.length} caractere');

      // 4. Trimite request la Google Vision API
      final extractedText = await _callGoogleVisionAPI(base64Image);
      
      if (extractedText != null && extractedText.isNotEmpty) {
        debugPrint('✅ [ScannerOcr] Text extras cu succes: ${extractedText.length} caractere');
        debugPrint('📝 [ScannerOcr] Preview text: ${extractedText.substring(0, extractedText.length > 100 ? 100 : extractedText.length)}...');
        
        return ScanResult.success(extractedText, imageFile.path);
      } else {
        debugPrint('⚠️ [ScannerOcr] Nu s-a gasit text in imagine');
        return ScanResult.error('Nu s-a gasit text in imagine', imageFile.path);
      }

    } catch (e) {
      debugPrint('❌ [ScannerOcr] Eroare: $e');
      return ScanResult.error('Eroare la scanare: $e', imageFile.path);
    }
  }

  /// Apeleaza Google Vision API pentru extragerea textului
  Future<String?> _callGoogleVisionAPI(String base64Image) async {
    try {
      debugPrint('🌐 [ScannerOcr] Trimit request la Google Vision API...');

      // Request body simplu si robust
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
              'languageHints': ['ro', 'en'], // Romana si engleza
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
        debugPrint('📦 [ScannerOcr] Raspuns primit de la API');
        
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

  /// Extrage textul din raspunsul Google Vision API
  String? _extractTextFromResponse(Map<String, dynamic> responseData) {
    try {
      debugPrint('🔍 [ScannerOcr] Procesez raspunsul API...');

      // Verifica daca exista responses
      if (!responseData.containsKey('responses')) {
        debugPrint('❌ [ScannerOcr] Nu exista responses in raspuns');
        return null;
      }

      final responses = responseData['responses'] as List;
      if (responses.isEmpty) {
        debugPrint('❌ [ScannerOcr] Lista responses este goala');
        return null;
      }

      final firstResponse = responses[0] as Map<String, dynamic>;

      // Verifica daca exista erori
      if (firstResponse.containsKey('error')) {
        debugPrint('❌ [ScannerOcr] Eroare in raspuns: ${firstResponse['error']}');
        return null;
      }

      // Incearca sa extraga textul din textAnnotations
      if (firstResponse.containsKey('textAnnotations')) {
        final textAnnotations = firstResponse['textAnnotations'] as List;
        
        if (textAnnotations.isNotEmpty) {
          final firstAnnotation = textAnnotations[0] as Map<String, dynamic>;
          
          if (firstAnnotation.containsKey('description')) {
            final text = firstAnnotation['description'] as String;
            debugPrint('✅ [ScannerOcr] Text gasit in textAnnotations: ${text.length} caractere');
            return _cleanText(text);
          }
        }
      }

      debugPrint('⚠️ [ScannerOcr] Nu s-a gasit text in raspuns');
      return null;

    } catch (e) {
      debugPrint('❌ [ScannerOcr] Eroare la procesarea raspunsului: $e');
      return null;
    }
  }

  /// Curata textul extras de caractere nedorite
  String _cleanText(String text) {
    // Inlocuieste break-uri de linie multiple cu una singura
    String cleaned = text.replaceAll(RegExp(r'\n+'), '\n');
    
    // Elimina spatiile extra
    cleaned = cleaned.replaceAll(RegExp(r' +'), ' ');
    
    // Elimina tab-urile
    cleaned = cleaned.replaceAll('\t', ' ');
    
    // Trim
    cleaned = cleaned.trim();
    
    return cleaned;
  }

  /// Proceseaza multiple imagini secvential
  Future<List<ScanResult>> scanMultipleImages(
    List<File> imageFiles,
    Function(ScanProgress)? onProgress,
  ) async {
    debugPrint('🔍 Incepe scanarea pentru ${imageFiles.length} imagini');
    
    final results = <ScanResult>[];
    
    for (int i = 0; i < imageFiles.length; i++) {
      debugPrint('🔄 Scaneaza imaginea ${i + 1}/${imageFiles.length}');
      
      // Notifica progresul
      onProgress?.call(ScanProgress(
        currentImage: i + 1,
        totalImages: imageFiles.length,
        imageName: _getImageName(imageFiles[i]),
        phase: ScanPhase.extractingText,
      ));
      
      final result = await extractTextFromImage(imageFiles[i]);
      results.add(result);
      
      // Delay intre imagini pentru a nu supraincarca API-ul
      if (i < imageFiles.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    
    debugPrint('✅ Scanare finalizata pentru toate imaginile');
    return results;
  }

  /// Obtine numele imaginii din calea completa
  String _getImageName(File imageFile) {
    return imageFile.path.split('/').last.split('\\').last;
  }
}

/// Rezultatul operatiei de scanare
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

/// Progresul scanarii
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

/// Fazele scanarii
enum ScanPhase {
  extractingText,
}
