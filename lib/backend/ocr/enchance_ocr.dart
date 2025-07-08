import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Service pentru îmbunătățirea imaginilor înainte de procesarea OCR
class EnhanceOCR {
  static final EnhanceOCR _instance = EnhanceOCR._internal();
  factory EnhanceOCR() => _instance;
  EnhanceOCR._internal();

  /// Îmbunătățește o imagine pentru OCR optim
  Future<Uint8List> enhanceImage(Uint8List imageBytes, {
    EnhancementLevel level = EnhancementLevel.medium,
  }) async {
    try {
      debugPrint('🎨 ENHANCE_OCR: Începe îmbunătățirea imaginii (${imageBytes.length} bytes)');
      
      var image = img.decodeImage(imageBytes);
      if (image == null) {
        throw EnhancementException('Nu se poate decoda imaginea');
      }
      
      debugPrint('📐 ENHANCE_OCR: Dimensiuni originale: ${image.width}x${image.height}');
      
      // 1. Redimensionare optimă pentru OCR
      image = _resizeForOCR(image);
      
      // 2. Convertire la grayscale pentru procesare mai bună
      image = img.grayscale(image);
      
      // 3. Îmbunătățirea contrastului
      image = _enhanceContrast(image, level);
      
      // 4. Sharpening pentru text
      image = _sharpenText(image, level);
      
      // Convertire finală la bytes
      final enhancedBytes = Uint8List.fromList(img.encodeJpg(image, quality: 95));
      
      debugPrint('✅ ENHANCE_OCR: Imagine îmbunătățită: ${enhancedBytes.length} bytes');
      debugPrint('📊 ENHANCE_OCR: Dimensiuni finale: ${image.width}x${image.height}');
      
      return enhancedBytes;
      
    } catch (e) {
      debugPrint('❌ ENHANCE_OCR: Eroare la îmbunătățirea imaginii: $e');
      return imageBytes; // Returnează imaginea originală
    }
  }

  /// Redimensionează imaginea pentru OCR optim
  img.Image _resizeForOCR(img.Image image) {
    const minHeight = 600;
    const maxHeight = 2400;
    const maxWidth = 3200;
    
    int newWidth = image.width;
    int newHeight = image.height;
    
    // Asigură dimensiune minimă pentru text lizibil
    if (newHeight < minHeight) {
      final ratio = minHeight / newHeight;
      newHeight = minHeight;
      newWidth = (newWidth * ratio).round();
    }
    
    // Limitează dimensiunea maximă pentru performanță
    if (newHeight > maxHeight) {
      final ratio = maxHeight / newHeight;
      newHeight = maxHeight;
      newWidth = (newWidth * ratio).round();
    }
    
    if (newWidth > maxWidth) {
      final ratio = maxWidth / newWidth;
      newWidth = maxWidth;
      newHeight = (newHeight * ratio).round();
    }
    
    if (newWidth != image.width || newHeight != image.height) {
      debugPrint('📐 ENHANCE_OCR: Redimensionare de la ${image.width}x${image.height} la ${newWidth}x$newHeight');
      return img.copyResize(image, width: newWidth, height: newHeight, interpolation: img.Interpolation.cubic);
    }
    
    return image;
  }

  /// Îmbunătățește contrastul imaginii
  img.Image _enhanceContrast(img.Image image, EnhancementLevel level) {
    switch (level) {
      case EnhancementLevel.low:
        return img.contrast(image, contrast: 105);
      
      case EnhancementLevel.medium:
        return img.contrast(image, contrast: 115);
      
      case EnhancementLevel.high:
        return img.contrast(image, contrast: 125);
    }
  }

  /// Aplică sharpening pentru text
  img.Image _sharpenText(img.Image image, EnhancementLevel level) {
    List<num> kernel;
    
    switch (level) {
      case EnhancementLevel.low:
        kernel = [
          0, -0.5, 0,
          -0.5, 3, -0.5,
          0, -0.5, 0
        ];
        break;
      
      case EnhancementLevel.medium:
        kernel = [
          0, -1, 0,
          -1, 5, -1,
          0, -1, 0
        ];
        break;
      
      case EnhancementLevel.high:
        kernel = [
          -1, -1, -1,
          -1, 9, -1,
          -1, -1, -1
        ];
        break;
    }
    
    return img.convolution(image, filter: kernel);
  }

  /// Îmbunătățire rapidă pentru processing în timp real
  Future<Uint8List> quickEnhance(Uint8List imageBytes) async {
    try {
      var image = img.decodeImage(imageBytes);
      if (image == null) return imageBytes;
      
      // Îmbunătățiri rapide
      image = img.grayscale(image);
      image = img.contrast(image, contrast: 110);
      image = img.convolution(image, filter: [
        0, -1, 0,
        -1, 5, -1,
        0, -1, 0
      ]);
      
      return Uint8List.fromList(img.encodeJpg(image, quality: 90));
    } catch (e) {
      debugPrint('❌ ENHANCE_OCR: Eroare la quick enhance: $e');
      return imageBytes;
    }
  }
}

/// Niveluri de îmbunătățire
enum EnhancementLevel {
  low,    // Îmbunătățiri minime, procesare rapidă
  medium, // Îmbunătățiri moderate, balans calitate/viteză
  high,   // Îmbunătățiri maxime, procesare lentă
}

/// Excepție pentru erori de îmbunătățire
class EnhancementException implements Exception {
  final String message;
  
  const EnhancementException(this.message);
  
  @override
  String toString() => 'EnhancementException: $message';
}
