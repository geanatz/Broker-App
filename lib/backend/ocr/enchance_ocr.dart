import 'dart:io';
import 'package:flutter/foundation.dart';
import 'scanner_ocr.dart';
import 'filter_ocr.dart';
import 'parser_ocr.dart';
import '../services/clients_service.dart';

/// Service principal pentru procesarea OCR completa
/// Orchestreaza procesul complet: imbunatatire → scanare → filtrare → parsare
class EnhanceOcr {
  final ScannerOcr _scanner = ScannerOcr();
  final FilterOcr _filter = FilterOcr();
  final ParserOcr _parser = ParserOcr();
  
  /// Singleton instance
  static final EnhanceOcr _instance = EnhanceOcr._internal();
  factory EnhanceOcr() => _instance;
  EnhanceOcr._internal();

  /// Pregateste imaginea pentru OCR optimal
  Future<EnhanceResult> enhanceImageForOcr(File originalImageFile) async {
    try {
      debugPrint('🔧 Incepe pregatirea imaginii: ${originalImageFile.path}');
      
      // Verifica daca fisierul exista
      if (!await originalImageFile.exists()) {
        return EnhanceResult(
          success: false,
          error: 'Fisierul imagine nu exista',
          originalPath: originalImageFile.path,
        );
      }

      // Verifica marimea fisierului (max 10MB pentru Google Vision API)
      final fileSize = await originalImageFile.length();
      const maxFileSize = 10 * 1024 * 1024; // 10MB
      
      if (fileSize > maxFileSize) {
        debugPrint('❌ Imaginea este prea mare: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB > 10MB');
        return EnhanceResult(
          success: false,
          error: 'Imaginea este prea mare (${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB). Marimea maxima este 10MB.',
          originalPath: originalImageFile.path,
        );
      }

      // Verifica tipul fisierului
      if (!_isValidImageFormat(originalImageFile)) {
        return EnhanceResult(
          success: false,
          error: 'Format de imagine nesuportat. Utilizati PNG, JPG, JPEG, BMP sau GIF.',
          originalPath: originalImageFile.path,
        );
      }

      debugPrint('📊 Marimea imaginii: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB');
      debugPrint('✅ Imagine validata cu succes');

      // Pentru moment, returnam imaginea originala fara modificari
      // In viitor se poate adauga procesare avansata cu librariile necesare
      return EnhanceResult(
        success: true,
        originalPath: originalImageFile.path,
        enhancedFile: null, // Utilizam imaginea originala
        improvementDetails: 'Imagine validata si pregatita pentru OCR',
      );

    } catch (e) {
      debugPrint('❌ Eroare la pregatirea imaginii: $e');
      return EnhanceResult(
        success: false,
        error: 'Eroare la procesare: $e',
        originalPath: originalImageFile.path,
      );
    }
  }

  /// Verifica daca formatul imaginii este valid pentru Google Vision
  bool _isValidImageFormat(File imageFile) {
    final fileName = imageFile.path.toLowerCase();
    final validExtensions = ['.png', '.jpg', '.jpeg', '.bmp', '.gif'];
    
    return validExtensions.any((ext) => fileName.endsWith(ext));
  }

  /// Proceseaza multiple imagini secvential
  Future<List<EnhanceResult>> enhanceMultipleImages(List<File> imageFiles) async {
    debugPrint('🔧 Incepe pregatirea pentru ${imageFiles.length} imagini');
    
    final results = <EnhanceResult>[];
    
    for (int i = 0; i < imageFiles.length; i++) {
      debugPrint('🔄 Proceseaza imaginea ${i + 1}/${imageFiles.length}');
      final result = await enhanceImageForOcr(imageFiles[i]);
      results.add(result);
      
      // Adauga delay scurt pentru a nu supraincarca sistemul
      if (i < imageFiles.length - 1) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    
    debugPrint('✅ Pregatire finalizata pentru toate imaginile');
    return results;
  }

  /// Curata fisierele temporare create (daca exista)
  Future<void> cleanupTemporaryFiles(List<EnhanceResult> results) async {
    for (final result in results) {
      if (result.success && result.enhancedFile != null) {
        try {
          if (await result.enhancedFile!.exists()) {
            await result.enhancedFile!.delete();
            debugPrint('🗑️ Sters fisier temporar: ${result.enhancedFile!.path}');
          }
        } catch (e) {
          debugPrint('⚠️ Nu s-a putut sterge fisierul temporar: $e');
        }
      }
    }
  }

  /// Obtine informatii despre imagine fara procesare
  Future<ImageInfo> getImageInfo(File imageFile) async {
    try {
      final fileSize = await imageFile.length();
      final fileName = imageFile.path.split('/').last.split('\\').last;
      
      return ImageInfo(
        fileName: fileName,
        filePath: imageFile.path,
        fileSize: fileSize,
        fileSizeMB: fileSize / (1024 * 1024),
        isValidFormat: _isValidImageFormat(imageFile),
        isValidSize: fileSize <= 10 * 1024 * 1024,
      );
    } catch (e) {
      debugPrint('❌ Eroare la obtinerea informatiilor despre imagine: $e');
      return ImageInfo(
        fileName: 'Necunoscut',
        filePath: imageFile.path,
        fileSize: 0,
        fileSizeMB: 0,
        isValidFormat: false,
        isValidSize: false,
      );
    }
  }

  /// Proceseaza o lista de imagini si extrage contactele (metoda principala)
  /// Returneaza un Map cu calea imaginii ca key si rezultatul ca value
  Future<Map<String, OcrImageResult>> processImages(
    List<File> imageFiles,
    Function(OcrProgressUpdate)? onProgress,
  ) async {
    final results = <String, OcrImageResult>{};
    
    try {
      debugPrint('🚀 Incepe procesarea OCR imbunatatita pentru ${imageFiles.length} imagini');
      
      // Verifica daca Google Vision API este configurat
      if (!_scanner.isConfigured()) {
        debugPrint('❌ Google Vision API nu este configurat');
        throw Exception('Google Vision API nu este configurat. Verifica API key-ul.');
      }
      
      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        final imagePath = imageFile.path;
        final imageNumber = i + 1;
        
        try {
          // FAZA 1: Imbunatatire imagine
          onProgress?.call(OcrProgressUpdate(
            phase: OcrPhase.enhancingImage,
            currentImage: imageNumber,
            totalImages: imageFiles.length,
            imageName: _getImageName(imageFile),
          ));
          
          final enhanceResult = await enhanceImageForOcr(imageFile);
          await Future.delayed(const Duration(milliseconds: 100));
          
          if (!enhanceResult.success) {
            results[imagePath] = OcrImageResult(
              success: false,
              error: enhanceResult.error ?? 'Eroare la imbunatatirea imaginii',
              imagePath: imagePath,
              contacts: [],
            );
            continue;
          }
          
          // FAZA 2: Scanare cu Google Vision
          onProgress?.call(OcrProgressUpdate(
            phase: OcrPhase.extractingText,
            currentImage: imageNumber,
            totalImages: imageFiles.length,
            imageName: _getImageName(imageFile),
          ));
          
          final imageToScan = enhanceResult.imageToUse;
          final scanResult = await _scanner.extractTextFromImage(imageToScan);
          await Future.delayed(const Duration(milliseconds: 100));
          
          if (!scanResult.success) {
            results[imagePath] = OcrImageResult(
              success: false,
              error: scanResult.error ?? 'Eroare la extragerea textului',
              imagePath: imagePath,
              contacts: [],
            );
            continue;
          }
          
          // FAZA 3: Filtrare text
          onProgress?.call(OcrProgressUpdate(
            phase: OcrPhase.filteringText,
            currentImage: imageNumber,
            totalImages: imageFiles.length,
            imageName: _getImageName(imageFile),
          ));
          
          final filteredText = _filter.filterOcrText(scanResult.extractedText!);
          await Future.delayed(const Duration(milliseconds: 100));
          
          // FAZA 4: Parsare contacte
          onProgress?.call(OcrProgressUpdate(
            phase: OcrPhase.extractingContacts,
            currentImage: imageNumber,
            totalImages: imageFiles.length,
            imageName: _getImageName(imageFile),
          ));
          
          final contacts = await _parser.parseContactsFromText(filteredText, imagePath);
          await Future.delayed(const Duration(milliseconds: 100));
          
          results[imagePath] = OcrImageResult(
            success: true,
            imagePath: imagePath,
            extractedText: scanResult.extractedText,
            filteredText: filteredText,
            contacts: contacts,
            confidence: scanResult.confidence,
            enhanceDetails: enhanceResult.improvementDetails,
          );
          
          debugPrint('✅ Finalizat ${_getImageName(imageFile)}: ${contacts.length} clienti');
          
        } catch (e) {
          debugPrint('❌ Eroare la procesarea ${_getImageName(imageFile)}: $e');
          results[imagePath] = OcrImageResult(
            success: false,
            error: 'Eroare la procesare: $e',
            imagePath: imagePath,
            contacts: [],
          );
        }
        
        // Delay mic intre imagini pentru a nu supraincarca API-ul
        if (i < imageFiles.length - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
      
      debugPrint('🎉 Procesare OCR imbunatatita finalizata pentru toate imaginile');
      
    } catch (e) {
      debugPrint('❌ Eroare generala la procesarea OCR: $e');
      rethrow;
    }
    
    return results;
  }

  /// Obtine numele imaginii din calea completa
  String _getImageName(File imageFile) {
    return imageFile.path.split('/').last.split('\\').last;
  }

  /// Verifica daca serviciul este configurat corect
  bool isConfigured() {
    return _scanner.isConfigured();
  }
}

/// Rezultatul procesului de pregatire
class EnhanceResult {
  final bool success;
  final String? error;
  final String originalPath;
  final File? enhancedFile;
  final String? improvementDetails;

  const EnhanceResult({
    required this.success,
    this.error,
    required this.originalPath,
    this.enhancedFile,
    this.improvementDetails,
  });

  /// Nume al imaginii originale
  String get originalImageName {
    return originalPath.split('/').last.split('\\').last;
  }

  /// Calea catre imaginea imbunatatita sau originala
  File get imageToUse {
    return enhancedFile ?? File(originalPath);
  }
}

/// Informatii despre o imagine
class ImageInfo {
  final String fileName;
  final String filePath;
  final int fileSize;
  final double fileSizeMB;
  final bool isValidFormat;
  final bool isValidSize;

  const ImageInfo({
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.fileSizeMB,
    required this.isValidFormat,
    required this.isValidSize,
  });

  /// Verifica daca imaginea este valida pentru OCR
  bool get isValid => isValidFormat && isValidSize;

  /// Mesaj de status pentru imagine
  String get statusMessage {
    if (!isValidFormat) return 'Format nesuportat';
    if (!isValidSize) return 'Prea mare (>${(fileSizeMB).toStringAsFixed(1)}MB)';
    return 'Gata pentru OCR';
  }
}

/// Rezultatul procesarii unei imagini
class OcrImageResult {
  final bool success;
  final String? error;
  final String imagePath;
  final String? extractedText;
  final String? filteredText;
  final List<UnifiedClientModel> contacts;
  final double confidence;
  final String? enhanceDetails;

  const OcrImageResult({
    required this.success,
    this.error,
    required this.imagePath,
    this.extractedText,
    this.filteredText,
    required this.contacts,
    this.confidence = 0.0,
    this.enhanceDetails,
  });

  /// Numarul de clienti extrasi
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
      case OcrPhase.enhancingImage:
        return 'Se imbunatateste imaginea $imageName';
      case OcrPhase.extractingText:
        return 'Se extrage textul din imaginea $imageName';
      case OcrPhase.filteringText:
        return 'Se filtreaza textul pentru imaginea $imageName';
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

/// Fazele procesarii OCR
enum OcrPhase {
  enhancingImage,
  extractingText,
  filteringText,
  extractingContacts,
}
