import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Service pentru imbunatatirea imaginilor pentru OCR optim
/// Pre-proceseaza imaginile pentru a imbunatati acuratetea extragerii textului
class EnhanceOcr {
  /// Singleton instance
  static final EnhanceOcr _instance = EnhanceOcr._internal();
  factory EnhanceOcr() => _instance;
  EnhanceOcr._internal();

  /// Imbunatateste o imagine pentru OCR optim
  /// Aplica filtru grayscale si imbunatateste contrastul pentru claritate maxima
  Future<EnhanceResult> enhanceImageForOcr(File originalImageFile) async {
    try {
      debugPrint('🔧 [EnhanceOcr] Incepe imbunatatirea imaginii: ${originalImageFile.path}');
      
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
        debugPrint('❌ [EnhanceOcr] Imaginea este prea mare: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB > 10MB');
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

      debugPrint('📊 [EnhanceOcr] Marimea imaginii: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB');
      debugPrint('✅ [EnhanceOcr] Imagine validata cu succes');

      // Incarca imaginea pentru procesare
      final imageBytes = await originalImageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);
      
      if (originalImage == null) {
        return EnhanceResult(
          success: false,
          error: 'Nu s-a putut decodifica imaginea pentru procesare',
          originalPath: originalImageFile.path,
        );
      }
      
      debugPrint('🔧 [EnhanceOcr] Imagine decodificata: ${originalImage.width}x${originalImage.height}');
      
      // Aplica filtru grayscale pentru claritate
      debugPrint('🎨 [EnhanceOcr] Aplica filtru grayscale...');
      var processedImage = img.grayscale(originalImage);
      debugPrint('✅ [EnhanceOcr] Filtru grayscale aplicat cu succes');
      
      // Ajusteaza contrastul cu 150% pentru text mai clar
      debugPrint('🔆 [EnhanceOcr] Imbunatateste contrastul cu 150%...');
      processedImage = img.adjustColor(processedImage, contrast: 1.5);
      debugPrint('✅ [EnhanceOcr] Contrast imbunatatit cu succes');
      
      // Salveaza imaginea procesata intr-un fisier temporar
      final tempDir = Directory.systemTemp;
      final fileName = _getFileName(originalImageFile);
      final tempFile = File('${tempDir.path}/${fileName}_enhanced.png');
      
      final enhancedBytes = img.encodePng(processedImage);
      await tempFile.writeAsBytes(enhancedBytes);
      
      debugPrint('✅ [EnhanceOcr] Imagine imbunatatita salvata: ${tempFile.path}');
      debugPrint('📊 [EnhanceOcr] Marime noua: ${(enhancedBytes.length / 1024 / 1024).toStringAsFixed(2)}MB');
      
      return EnhanceResult(
        success: true,
        originalPath: originalImageFile.path,
        enhancedFile: tempFile,
        improvementDetails: 'Aplicat filtru grayscale si imbunatatit contrastul cu 150% pentru claritate optima OCR.',
      );

    } catch (e) {
      debugPrint('❌ [EnhanceOcr] Eroare la pregatirea imaginii: $e');
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
    const validExtensions = ['.png', '.jpg', '.jpeg', '.bmp', '.gif'];
    
    return validExtensions.any((ext) => fileName.endsWith(ext));
  }

  /// Extrage numele fisierului fara extensie
  String _getFileName(File file) {
    final fileName = file.path.split('/').last.split('\\').last;
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex > 0 ? fileName.substring(0, dotIndex) : fileName;
  }

  /// Proceseaza multiple imagini secvential
  Future<List<EnhanceResult>> enhanceMultipleImages(List<File> imageFiles) async {
    debugPrint('🔧 [EnhanceOcr] Incepe imbunatatirea pentru ${imageFiles.length} imagini');
    
    final results = <EnhanceResult>[];
    
    for (int i = 0; i < imageFiles.length; i++) {
      debugPrint('🔄 [EnhanceOcr] Proceseaza imaginea ${i + 1}/${imageFiles.length}');
      final result = await enhanceImageForOcr(imageFiles[i]);
      results.add(result);
      
      // Adauga delay scurt pentru a nu supraincarca sistemul
      if (i < imageFiles.length - 1) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    
    debugPrint('✅ [EnhanceOcr] Imbunatatire finalizata pentru toate imaginile');
    return results;
  }

  /// Curata fisierele temporare create (daca exista)
  Future<void> cleanupTemporaryFiles(List<EnhanceResult> results) async {
    for (final result in results) {
      if (result.success && result.enhancedFile != null) {
        try {
          if (await result.enhancedFile!.exists()) {
            await result.enhancedFile!.delete();
            debugPrint('🗑️ [EnhanceOcr] Sters fisier temporar: ${result.enhancedFile!.path}');
          }
        } catch (e) {
          debugPrint('⚠️ [EnhanceOcr] Nu s-a putut sterge fisierul temporar: $e');
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
      debugPrint('❌ [EnhanceOcr] Eroare la obtinerea informatiilor despre imagine: $e');
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
}

/// Rezultatul procesului de pregatire imaginii
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

  @override
  String toString() {
    return 'EnhanceResult(success: $success, originalPath: $originalPath, enhancedFile: ${enhancedFile?.path}, error: $error)';
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

  @override
  String toString() {
    return 'ImageInfo(fileName: $fileName, fileSizeMB: ${fileSizeMB.toStringAsFixed(2)}, isValid: $isValid)';
  }
}
