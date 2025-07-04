import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

/// Service pentru scanarea imaginilor si extragerea textului cu Google Vision
/// Implementeaza cache, retry logic si validari avansate
class ScannerOcr {
  /// Singleton instance
  static final ScannerOcr _instance = ScannerOcr._internal();
  factory ScannerOcr() => _instance;
  ScannerOcr._internal();

  static const String _apiKey = 'AIzaSyBHSucNUjWno77uW9dto-Xkg5X0a_f4NTI';
  static const String _baseUrl = 'https://vision.googleapis.com/v1/images:annotate';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);
  static const int _maxImageSize = 10 * 1024 * 1024; // 10MB

  final Map<String, ScanResult> _cache = {};
  final http.Client _httpClient = http.Client();

  /// Extrage textul dintr-o imagine folosind Google Vision API
  Future<ScanResult> extractTextFromImage(File imageFile) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      debugPrint('📸 [ScannerOcr] Incepe scanarea: ${imageFile.path}');
      
      // Validare imagine
      final validation = await _validateImage(imageFile);
      if (!validation.isValid) {
        return ScanResult(
          success: false,
          error: validation.error,
          processingTimeMs: stopwatch.elapsedMilliseconds,
        );
      }

      // Verifica cache
      final imageHash = await _calculateImageHash(imageFile);
      if (_cache.containsKey(imageHash)) {
        debugPrint('💾 [ScannerOcr] Rezultat din cache');
        final cachedResult = _cache[imageHash]!;
        return cachedResult.copyWith(processingTimeMs: stopwatch.elapsedMilliseconds);
      }

      // Encode imagine
      final base64Image = await _encodeImageToBase64(imageFile);
      
      // API call cu retry
      final apiResult = await _callApiWithRetry(base64Image);
      
      // Proceseaza raspuns
      final result = _processApiResponse(apiResult, stopwatch.elapsedMilliseconds);
      
      // Salveaza in cache daca e valid
      if (result.success) {
        _cache[imageHash] = result;
        debugPrint('💾 [ScannerOcr] Salvat in cache');
      }
      
      return result;

    } catch (e) {
      debugPrint('❌ [ScannerOcr] Eroare: $e');
      return ScanResult(
        success: false,
        error: 'Eroare neprevazuta: $e',
        processingTimeMs: stopwatch.elapsedMilliseconds,
      );
    }
  }

  /// Valideaza imaginea inainte de procesare
  Future<ValidationResult> _validateImage(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        return const ValidationResult(false, 'Fisierul nu exista');
      }

      final extension = imageFile.path.toLowerCase().split('.').last;
      const validExtensions = ['png', 'jpg', 'jpeg', 'bmp', 'gif'];
      if (!validExtensions.contains(extension)) {
        return ValidationResult(false, 'Format invalid. Foloseste: ${validExtensions.join(', ')}');
      }

      final fileSize = await imageFile.length();
      if (fileSize > _maxImageSize) {
        return const ValidationResult(false, 'Imaginea este prea mare (max 10MB)');
      }

      if (fileSize == 0) {
        return const ValidationResult(false, 'Fisierul este gol');
      }

      return const ValidationResult(true, null);
    } catch (e) {
      return ValidationResult(false, 'Eroare validare: $e');
    }
  }

  /// Calculeaza hash pentru imagine (pentru cache)
  Future<String> _calculateImageHash(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Encode imagine la base64
  Future<String> _encodeImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  /// Apeleaza API cu retry logic
  Future<Map<String, dynamic>> _callApiWithRetry(String base64Image) async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        debugPrint('🔄 [ScannerOcr] Tentativa $attempt/$_maxRetries');
        
        final response = await _httpClient.post(
          Uri.parse('$_baseUrl?key=$_apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'requests': [
              {
                'image': {'content': base64Image},
                'features': [
                  {'type': 'TEXT_DETECTION', 'maxResults': 50}
                ],
                'imageContext': {
                  'languageHints': ['ro', 'en']
                }
              }
            ]
          }),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body) as Map<String, dynamic>;
          debugPrint('✅ [ScannerOcr] API raspuns primit');
          return result;
        } else {
          debugPrint('⚠️ [ScannerOcr] API eroare ${response.statusCode}: ${response.body}');
          
          if (attempt == _maxRetries) {
            throw Exception('API eroare ${response.statusCode}: ${response.body}');
          }
        }
      } catch (e) {
        debugPrint('⚠️ [ScannerOcr] Tentativa $attempt esuata: $e');
        
        if (attempt == _maxRetries) {
          rethrow;
        }
        
        await Future.delayed(_retryDelay);
      }
    }
    
    throw Exception('Toate tentativele au esuat');
  }

  /// Proceseaza raspunsul de la API
  ScanResult _processApiResponse(Map<String, dynamic> apiResponse, int processingTimeMs) {
    try {
      final responses = apiResponse['responses'] as List<dynamic>?;
      if (responses == null || responses.isEmpty) {
        return ScanResult(
          success: false,
          error: 'Raspuns API gol',
          processingTimeMs: processingTimeMs,
        );
      }

      final response = responses[0] as Map<String, dynamic>;
      
      // Verifica erori
      if (response.containsKey('error')) {
        final error = response['error'] as Map<String, dynamic>;
        return ScanResult(
          success: false,
          error: 'API eroare: ${error['message']}',
          processingTimeMs: processingTimeMs,
        );
      }

      // Extrage text
      final fullTextAnnotation = response['fullTextAnnotation'] as Map<String, dynamic>?;
      if (fullTextAnnotation == null) {
        return ScanResult(
          success: true,
          extractedText: '',
          confidence: 0.0,
          processingTimeMs: processingTimeMs,
        );
      }

      final extractedText = fullTextAnnotation['text'] as String? ?? '';
      
      debugPrint('📝 [ScannerOcr] Text extras: ${extractedText.length} caractere');
      debugPrint('📄 [ScannerOcr] Preview text extras (primii 500 caractere):');
      if (extractedText.length > 500) {
        debugPrint('${extractedText.substring(0, 500)}...');
      } else {
        debugPrint(extractedText);
      }
      
      // Calculeaza confidence mediu
      final pages = fullTextAnnotation['pages'] as List<dynamic>? ?? [];
      double totalConfidence = 0.0;
      int wordCount = 0;
      
      for (final page in pages) {
        final blocks = page['blocks'] as List<dynamic>? ?? [];
        for (final block in blocks) {
          final paragraphs = block['paragraphs'] as List<dynamic>? ?? [];
          for (final paragraph in paragraphs) {
            final words = paragraph['words'] as List<dynamic>? ?? [];
            for (final word in words) {
              final confidence = word['confidence'] as double? ?? 0.0;
              totalConfidence += confidence;
              wordCount++;
            }
          }
        }
      }
      
      final avgConfidence = wordCount > 0 ? totalConfidence / wordCount : 0.0;
      
      debugPrint('📊 [ScannerOcr] Statistici text: ${extractedText.length} caractere, ${extractedText.split('\n').length} linii, confidence: ${(avgConfidence * 100).toStringAsFixed(1)}%');
      
      return ScanResult(
        success: true,
        extractedText: extractedText,
        confidence: avgConfidence,
        processingTimeMs: processingTimeMs,
      );

    } catch (e) {
      return ScanResult(
        success: false,
        error: 'Eroare procesare raspuns: $e',
        processingTimeMs: processingTimeMs,
      );
    }
  }

  /// Verifica daca serviciul este configurat
  bool isConfigured() {
    return _apiKey.isNotEmpty;
  }

  /// Curata cache-ul
  void clearCache() {
    _cache.clear();
    debugPrint('🗑️ [ScannerOcr] Cache curatat');
  }

  /// Dispose resurse
  void dispose() {
    _httpClient.close();
    _cache.clear();
    debugPrint('🔚 [ScannerOcr] Service inchis');
  }
}

/// Rezultatul validarii unei imagini
class ValidationResult {
  final bool isValid;
  final String? error;

  const ValidationResult(this.isValid, this.error);
}

/// Rezultatul scanarii unei imagini
class ScanResult {
  final bool success;
  final String? extractedText;
  final double? confidence;
  final String? error;
  final int processingTimeMs;

  const ScanResult({
    required this.success,
    this.extractedText,
    this.confidence,
    this.error,
    required this.processingTimeMs,
  });

  ScanResult copyWith({
    bool? success,
    String? extractedText,
    double? confidence,
    String? error,
    int? processingTimeMs,
  }) {
    return ScanResult(
      success: success ?? this.success,
      extractedText: extractedText ?? this.extractedText,
      confidence: confidence ?? this.confidence,
      error: error ?? this.error,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
    );
  }
}
