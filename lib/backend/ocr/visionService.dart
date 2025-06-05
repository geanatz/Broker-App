import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service pentru integrarea cu Google Vision API
class VisionService {
  static const String _apiKey = 'AIzaSyBHSucNUjWno77uW9dto-Xkg5X0a_f4NTI';
  static const String _baseUrl = 'https://vision.googleapis.com/v1/images:annotate';
  
  /// Singleton instance
  static final VisionService _instance = VisionService._internal();
  factory VisionService() => _instance;
  VisionService._internal();

  /// Extrage textul din imagine folosind Google Vision API
  Future<VisionResult> extractTextFromImage(File imageFile) async {
    try {
      debugPrint('🔍 Începe extragerea textului din imagine: ${imageFile.path}');
      
      // Verifică mărimea fișierului (max 10MB pentru Google Vision API)
      final fileSize = await imageFile.length();
      const maxFileSize = 10 * 1024 * 1024; // 10MB
      
      if (fileSize > maxFileSize) {
        debugPrint('❌ Imaginea este prea mare: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB > 10MB');
        return VisionResult(
          success: false,
          error: 'Imaginea este prea mare (${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB). Mărimea maximă este 10MB.',
          imagePath: imageFile.path,
        );
      }
      
      // Citește imaginea ca bytes
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      
      debugPrint('📊 Mărimea imaginii: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB');
      
      // Pregătește request-ul pentru Google Vision API
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
          }
        ]
      };

      // Trimite request-ul la Google Vision API
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final textAnnotations = responseData['responses'][0]['textAnnotations'];
        
        if (textAnnotations != null && textAnnotations.isNotEmpty) {
          final extractedText = textAnnotations[0]['description'] as String;
          debugPrint('✅ Text extras cu succes: ${extractedText.substring(0, math.min(100, extractedText.length))}...');
          
          return VisionResult(
            success: true,
            extractedText: extractedText,
            imagePath: imageFile.path,
          );
        } else {
          debugPrint('⚠️ Nu s-a găsit text în imagine');
          return VisionResult(
            success: false,
            error: 'Nu s-a găsit text în imagine',
            imagePath: imageFile.path,
          );
        }
      } else {
        debugPrint('❌ Eroare API Google Vision: ${response.statusCode} - ${response.body}');
        return VisionResult(
          success: false,
          error: 'Eroare API: ${response.statusCode}',
          imagePath: imageFile.path,
        );
      }
    } catch (e) {
      debugPrint('❌ Eroare la extragerea textului: $e');
      return VisionResult(
        success: false,
        error: 'Eroare: $e',
        imagePath: imageFile.path,
      );
    }
  }

  /// Validează dacă API key-ul este configurat
  bool isConfigured() {
    return _apiKey != 'YOUR_GOOGLE_VISION_API_KEY' && _apiKey.isNotEmpty;
  }
}

/// Rezultatul extragerii textului din imagine
class VisionResult {
  final bool success;
  final String? extractedText;
  final String? error;
  final String imagePath;

  VisionResult({
    required this.success,
    this.extractedText,
    this.error,
    required this.imagePath,
  });
} 