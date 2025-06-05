import 'dart:io';
import 'package:flutter/foundation.dart';
import 'visionService.dart';
import 'contactExtractorService.dart';
import '../models/unified_client_model.dart';

/// Service principal pentru procesarea OCR completă
class OcrService {
  final VisionService _visionService = VisionService();
  final ContactExtractorService _contactExtractor = ContactExtractorService();
  
  /// Singleton instance
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;
  OcrService._internal();

  /// Procesează o listă de imagini și extrage contactele
  /// Returnează un Map cu calea imaginii ca key și rezultatul ca value
  Future<Map<String, OcrImageResult>> processImages(
    List<File> imageFiles,
    Function(OcrProgressUpdate)? onProgress,
  ) async {
    final results = <String, OcrImageResult>{};
    
    try {
      debugPrint('🚀 Începe procesarea OCR pentru ${imageFiles.length} imagini');
      
      // Verifică dacă Google Vision API este configurat
      if (!_visionService.isConfigured()) {
        debugPrint('❌ Google Vision API nu este configurat');
        throw Exception('Google Vision API nu este configurat. Verifică API key-ul.');
      }
      
      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        final imagePath = imageFile.path;
        final imageNumber = i + 1;
        
        try {
          // Notifică progresul: începe extragerea textului
          onProgress?.call(OcrProgressUpdate(
            phase: OcrPhase.extractingText,
            currentImage: imageNumber,
            totalImages: imageFiles.length,
            imageName: _getImageName(imageFile),
          ));
          
          // Extrage textul din imagine cu delay pentru UI
          final visionResult = await _visionService.extractTextFromImage(imageFile);
          
          // Adaugă delay mic pentru a permite UI-ului să se actualizeze
          await Future.delayed(const Duration(milliseconds: 100));
          
          if (!visionResult.success) {
            results[imagePath] = OcrImageResult(
              success: false,
              error: visionResult.error ?? 'Eroare necunoscută',
              imagePath: imagePath,
              contacts: [],
            );
            continue;
          }
          
          // Notifică progresul: începe extragerea clienților
          onProgress?.call(OcrProgressUpdate(
            phase: OcrPhase.extractingContacts,
            currentImage: imageNumber,
            totalImages: imageFiles.length,
            imageName: _getImageName(imageFile),
          ));
          
          // Adaugă delay mic pentru UI
          await Future.delayed(const Duration(milliseconds: 100));
          
          // Extrage clienții din text
          final contacts = await _contactExtractor.extractContactsFromText(
            visionResult.extractedText!,
            imagePath,
          );
          
          results[imagePath] = OcrImageResult(
            success: true,
            imagePath: imagePath,
            extractedText: visionResult.extractedText,
            contacts: contacts,
          );
          
          debugPrint('✅ Finalizat ${_getImageName(imageFile)}: ${contacts.length} clienți');
          
        } catch (e) {
          debugPrint('❌ Eroare la procesarea ${_getImageName(imageFile)}: $e');
          results[imagePath] = OcrImageResult(
            success: false,
            error: 'Eroare la procesare: $e',
            imagePath: imagePath,
            contacts: [],
          );
        }
        
        // Delay mic între imagini pentru a nu supraîncărca API-ul
        if (i < imageFiles.length - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
      
      debugPrint('🎉 Procesare OCR finalizată pentru toate imaginile');
      
    } catch (e) {
      debugPrint('❌ Eroare generală la procesarea OCR: $e');
      rethrow;
    }
    
    return results;
  }

  /// Obține numele imaginii din calea completă
  String _getImageName(File imageFile) {
    return imageFile.path.split('/').last.split('\\').last;
  }

  /// Verifică dacă serviciul este configurat corect
  bool isConfigured() {
    return _visionService.isConfigured();
  }
}

/// Rezultatul procesării unei imagini
class OcrImageResult {
  final bool success;
  final String? error;
  final String imagePath;
  final String? extractedText;
  final List<UnifiedClientModel> contacts;

  const OcrImageResult({
    required this.success,
    this.error,
    required this.imagePath,
    this.extractedText,
    required this.contacts,
  });

  /// Numărul de clienți extrași
  int get contactCount => contacts.length;

  /// Numele imaginii
  String get imageName {
    return imagePath.split('/').last.split('\\').last;
  }
}

/// Update-ul progresului OCR
class OcrProgressUpdate {
  final OcrPhase phase;
  final int currentImage;
  final int totalImages;
  final String imageName;

  const OcrProgressUpdate({
    required this.phase,
    required this.currentImage,
    required this.totalImages,
    required this.imageName,
  });

  /// Mesajul de progres formatat
  String get progressMessage {
    switch (phase) {
      case OcrPhase.extractingText:
        return 'Se extrage textul din imaginea $imageName';
      case OcrPhase.extractingContacts:
        return 'Se creeaza clientii pentru imaginea $imageName';
    }
  }

  /// Progresul ca procentaj (0.0 - 1.0)
  double get progress {
    final baseProgress = (currentImage - 1) / totalImages;
    final phaseProgress = phase == OcrPhase.extractingText ? 0.0 : 0.5;
    return baseProgress + (phaseProgress / totalImages);
  }
}

/// Fazele procesării OCR
enum OcrPhase {
  extractingText,
  extractingContacts,
} 