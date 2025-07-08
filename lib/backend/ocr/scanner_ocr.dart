import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;

/// Service pentru scanarea și selecția imaginilor pentru OCR
class ScannerOCR {
  static final ScannerOCR _instance = ScannerOCR._internal();
  factory ScannerOCR() => _instance;
  ScannerOCR._internal();

  /// Selectează imagini pentru procesare OCR
  /// Compatibil cu web și desktop/mobile
  Future<List<ImageFile>> selectImages() async {
    try {
      FilePickerResult? result;
      
      if (kIsWeb) {
        // Pe web folosim FileType.custom cu extensii specifice
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'bmp', 'gif', 'webp'],
          allowMultiple: true,
          dialogTitle: 'Selecteaza imaginile pentru extragerea contactelor',
          withData: true, // Pe web avem nevoie de bytes
        );
      } else {
        // Pe desktop/mobile folosim FileType.image
        result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: true,
          dialogTitle: 'Selecteaza imaginile pentru extragerea contactelor',
        );
      }
      
      if (result == null || result.files.isEmpty) {
        debugPrint('📁 SCANNER_OCR: Selectia imaginilor a fost anulata');
        return [];
      }
      
      final imageFiles = <ImageFile>[];
      
      for (final file in result.files) {
        try {
          final imageFile = await _processSelectedFile(file);
          if (imageFile != null) {
            imageFiles.add(imageFile);
          }
        } catch (e) {
          debugPrint('❌ SCANNER_OCR: Eroare la procesarea fisierului ${file.name}: $e');
        }
      }
      
      debugPrint('✅ SCANNER_OCR: Selectate ${imageFiles.length} imagini valide');
      return imageFiles;
      
    } catch (e) {
      debugPrint('❌ SCANNER_OCR: Eroare la selectia imaginilor: $e');
      throw ScannerException('Eroare la selectia imaginilor: $e');
    }
  }

  /// Procesează un fișier selectat și creează ImageFile
  Future<ImageFile?> _processSelectedFile(PlatformFile file) async {
    try {
      // Validează extensia fișierului
      if (!_isValidImageExtension(file.name)) {
        debugPrint('⚠️ SCANNER_OCR: Fisier ignorat (extensie invalida): ${file.name}');
        return null;
      }
      
      Uint8List? bytes;
      String? path;
      
      if (kIsWeb) {
        // Pe web folosim bytes
        bytes = file.bytes;
        if (bytes == null) {
          debugPrint('❌ SCANNER_OCR: Nu s-au putut obtine bytes pentru ${file.name}');
          return null;
        }
      } else {
        // Pe desktop/mobile folosim path
        path = file.path;
        if (path == null) {
          debugPrint('❌ SCANNER_OCR: Nu s-a putut obtine path pentru ${file.name}');
          return null;
        }
        bytes = await File(path).readAsBytes();
      }
      
      // Validează că imaginea poate fi decodată
      final image = img.decodeImage(bytes);
      if (image == null) {
        debugPrint('❌ SCANNER_OCR: Nu se poate decoda imaginea ${file.name}');
        return null;
      }
      
      final imageFile = ImageFile(
        name: file.name,
        path: path,
        bytes: bytes,
        size: file.size,
        width: image.width,
        height: image.height,
      );
      
      debugPrint('✅ SCANNER_OCR: Imaginea procesata: ${file.name} (${image.width}x${image.height})');
      return imageFile;
      
    } catch (e) {
      debugPrint('❌ SCANNER_OCR: Eroare la procesarea fisierului ${file.name}: $e');
      return null;
    }
  }

  /// Verifică dacă extensia fișierului este validă pentru imagini
  bool _isValidImageExtension(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    const validExtensions = ['jpg', 'jpeg', 'png', 'bmp', 'gif', 'webp'];
    return validExtensions.contains(extension);
  }

  /// Redimensionează o imagine pentru a optimiza procesarea OCR
  Future<Uint8List> resizeImageForOCR(Uint8List imageBytes, {int maxWidth = 2048, int maxHeight = 2048}) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Nu se poate decoda imaginea');
      }
      
      // Calculează dimensiunile noi păstrând aspect ratio
      int newWidth = image.width;
      int newHeight = image.height;
      
      if (newWidth > maxWidth || newHeight > maxHeight) {
        final aspectRatio = newWidth / newHeight;
        
        if (newWidth > newHeight) {
          newWidth = maxWidth;
          newHeight = (maxWidth / aspectRatio).round();
        } else {
          newHeight = maxHeight;
          newWidth = (maxHeight * aspectRatio).round();
        }
      }
      
      // Redimensionează imaginea doar dacă este necesar
      if (newWidth != image.width || newHeight != image.height) {
        final resized = img.copyResize(image, width: newWidth, height: newHeight);
        final resizedBytes = Uint8List.fromList(img.encodeJpg(resized, quality: 85));
        
        debugPrint('📐 SCANNER_OCR: Imaginea redimensionata de la ${image.width}x${image.height} la ${newWidth}x$newHeight');
        return resizedBytes;
      }
      
      return imageBytes;
      
    } catch (e) {
      debugPrint('❌ SCANNER_OCR: Eroare la redimensionarea imaginii: $e');
      return imageBytes; // Returnează imaginea originală în caz de eroare
    }
  }

  /// Îmbunătățește calitatea imaginii pentru OCR
  Future<Uint8List> enhanceImageForOCR(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Nu se poate decoda imaginea');
      }
      
      // Aplică îmbunătățiri pentru OCR
      var enhanced = image;
      
      // Crește contrastul
      enhanced = img.contrast(enhanced, contrast: 110);
      
      // Aplică sharpening
      enhanced = img.convolution(enhanced, filter: [
        0, -1, 0,
        -1, 5, -1,
        0, -1, 0
      ]);
      
      // Convertește la grayscale pentru OCR mai bun
      enhanced = img.grayscale(enhanced);
      
      final enhancedBytes = Uint8List.fromList(img.encodeJpg(enhanced, quality: 90));
      
      debugPrint('🎨 SCANNER_OCR: Imaginea imbunatatita pentru OCR');
      return enhancedBytes;
      
    } catch (e) {
      debugPrint('❌ SCANNER_OCR: Eroare la imbunatatirea imaginii: $e');
      return imageBytes; // Returnează imaginea originală în caz de eroare
    }
  }
}

/// Clasa pentru reprezentarea unui fișier imagine
class ImageFile {
  final String name;
  final String? path; // null pe web
  final Uint8List bytes;
  final int size;
  final int width;
  final int height;
  
  const ImageFile({
    required this.name,
    this.path,
    required this.bytes,
    required this.size,
    required this.width,
    required this.height,
  });
  
  @override
  String toString() => 'ImageFile(name: $name, size: $size, dimensions: ${width}x$height)';
}

/// Excepție pentru erori de scanare
class ScannerException implements Exception {
  final String message;
  
  const ScannerException(this.message);
  
  @override
  String toString() => 'ScannerException: $message';
}
