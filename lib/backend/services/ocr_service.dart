import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../ocr/enchance_ocr.dart';
import '../ocr/ocr_logger.dart';
import '../ocr/scanner_ocr.dart';
import '../ocr/parser_ocr.dart';
import '../ocr/transformer_ocr.dart';
import 'clients_service.dart';

/// Service principal pentru procesarea OCR
/// Pipeline: Enhance -> Scanner -> Parser -> Transformer -> ClientsService
class OcrService {
  /// Singleton instance
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;
  OcrService._internal();

  // Servicii componente
  final _enhancer = EnhanceOcr();
  final _scanner = ScannerOcr();
  final _parser = ParserOcr();
  final _transformer = TransformerOcr();
  final _logger = OcrDebugLogger();

  /// Proceseaza o imagine si extrage contactele (mod debug)
  Future<OcrResult> processImageForDebug({
    required File imageFile,
    File? groundTruthFile,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    // Pornim logger-ul doar in mod debug
    if (groundTruthFile != null) {
      _logger.startLog(p.basename(imageFile.path));
      _logger.setGroundTruth(groundTruthFile);
    }
    
    try {
      debugPrint('🚀 [OcrService] Incepe procesarea: ${imageFile.path}');
      _logger.addParsingStep('🚀 Incepe procesarea: ${imageFile.path}');

      // 1. Enhance imagine
      final enhanceResult = await _enhancer.enhanceImageForOcr(imageFile);
      if (!enhanceResult.success) {
        return OcrResult.failure(
          error: enhanceResult.error ?? 'Nu s-a putut imbunatatii imaginea',
          processingTimeMs: stopwatch.elapsedMilliseconds,
          imagePath: imageFile.path,
        );
      }
      final enhancedImageFile = enhanceResult.enhancedFile ?? imageFile;
      
      // 2. Scanare text cu Google Vision
      final scanResult = await _scanner.extractTextFromImage(enhancedImageFile);
      if (!scanResult.success || scanResult.extractedText == null) {
        return OcrResult.failure(
          error: scanResult.error ?? 'Nu s-a putut extrage text',
          processingTimeMs: stopwatch.elapsedMilliseconds,
          imagePath: imageFile.path,
        );
      }

      final rawText = scanResult.extractedText!;
      _logger.setRawOcrText(rawText);
      _logger.addParsingStep('✅ Scanare completa: ${rawText.length} caractere, confidence: ${((scanResult.confidence ?? 0.0) * 100).toStringAsFixed(1)}%');
      
      // 3. Parsare contacte
      final contacts = await _parser.parseContactsFromText(rawText);
      _logger.addParsingStep('✅ Parsare completa: ${contacts.length} contacte gasite');

      if (contacts.isEmpty) {
        return OcrResult.failure(
          error: 'Nu s-au gasit contacte valide in imagine',
          processingTimeMs: stopwatch.elapsedMilliseconds,
          imagePath: imageFile.path,
        );
      }

      // 4. Transformare in clienti
      final clients = await _transformer.transformContactsToClients(contacts);
      _logger.addTransformationStep('✅ Transformare completa: ${clients.length} clienti creati');
      _logger.setFinalClients(clients);

      // 5. Curata fisierul enhance temporary
      if (enhancedImageFile.path != imageFile.path) {
        try {
          await enhancedImageFile.delete();
        } catch (e) {
          debugPrint('⚠️ [OcrService] Nu s-a putut sterge fisierul temporar: $e');
        }
      }
      
      // Salvam log-ul daca e cazul
      if (groundTruthFile != null) {
        await _logger.saveLog();
      }

      return OcrResult.success(
        extractedClients: clients,
        extractedText: rawText,
        confidence: scanResult.confidence ?? 0.0,
        processingTimeMs: stopwatch.elapsedMilliseconds,
        imagePath: imageFile.path,
      );

    } catch (e) {
      debugPrint('❌ [OcrService] Eroare: $e');
      return OcrResult.failure(
        error: 'Eroare la procesare: $e',
        processingTimeMs: stopwatch.elapsedMilliseconds,
        imagePath: imageFile.path,
      );
    }
  }

  /// Proceseaza o imagine si extrage contactele
  Future<OcrResult> processImage(File imageFile) async {
    // Apelam metoda de debug fara fisier de referinta
    return processImageForDebug(imageFile: imageFile);
  }

  /// Proceseaza multiple imagini in batch
  Future<BatchOcrResult> processMultipleImages(
    List<File> imageFiles, {
    Function(int current, int total)? onProgress,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    debugPrint('📦 [OcrService] Incepe batch procesare: ${imageFiles.length} imagini');

    final results = <OcrResult>[];
    final allClients = <UnifiedClientModel>[];
    int successCount = 0;

    for (int i = 0; i < imageFiles.length; i++) {
      onProgress?.call(i + 1, imageFiles.length);
      
      final result = await processImage(imageFiles[i]);
      results.add(result);

      if (result.success && result.extractedClients != null) {
        allClients.addAll(result.extractedClients!);
        successCount++;
      }

      // Delay intre imagini pentru a nu suprasolicita API-ul
      if (i < imageFiles.length - 1) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    final batchResult = BatchOcrResult(
      success: successCount > 0,
      totalImages: imageFiles.length,
      successfulImages: successCount,
      failedImages: imageFiles.length - successCount,
      allClients: allClients,
      individualResults: results,
      totalProcessingTimeMs: stopwatch.elapsedMilliseconds,
    );

    debugPrint('🎯 [OcrService] Batch finalizat: ${allClients.length} clienti din $successCount/${imageFiles.length} imagini');
    return batchResult;
  }

  /// Salveaza clientii extrasi - metoda placeholder
  /// Aplicația principală se va ocupa de salvarea efectivă
  Future<bool> saveExtractedClients(List<UnifiedClientModel> clients) async {
    debugPrint('💾 [OcrService] Metoda pentru salvare: ${clients.length} clienti');
    debugPrint('📝 [OcrService] Aplicația principală se va ocupa de salvarea efectivă');
    return true;
  }

  /// Verifica daca serviciul este configurat
  bool isConfigured() {
    return _scanner.isConfigured();
  }

  /// Statistici despre procesare
  OcrStats getStats() {
    // Aici poti adauga logica pentru statistici
    return OcrStats(
      totalProcessed: 0,
      totalSuccess: 0,
      totalFailed: 0,
      avgConfidence: 0.0,
      avgProcessingTime: 0.0,
    );
  }

  /// Curata cache-urile
  void clearCaches() {
    _scanner.clearCache();
    debugPrint('🗑️ [OcrService] Cache-uri curatate');
  }

  /// Dispose resurse
  void dispose() {
    _scanner.dispose();
    debugPrint('🔚 [OcrService] Service inchis');
  }
}

/// Rezultatul procesarii unei imagini
class OcrResult {
  final bool success;
  final List<UnifiedClientModel>? extractedClients;
  final String? extractedText;
  final double confidence;
  final String? error;
  final int processingTimeMs;
  final String imagePath;

  const OcrResult._({
    required this.success,
    this.extractedClients,
    this.extractedText,
    required this.confidence,
    this.error,
    required this.processingTimeMs,
    required this.imagePath,
  });

  factory OcrResult.success({
    required List<UnifiedClientModel> extractedClients,
    required String extractedText,
    required double confidence,
    required int processingTimeMs,
    required String imagePath,
  }) {
    return OcrResult._(
      success: true,
      extractedClients: extractedClients,
      extractedText: extractedText,
      confidence: confidence,
      processingTimeMs: processingTimeMs,
      imagePath: imagePath,
    );
  }

  factory OcrResult.failure({
    required String error,
    required int processingTimeMs,
    required String imagePath,
  }) {
    return OcrResult._(
      success: false,
      error: error,
      confidence: 0.0,
      processingTimeMs: processingTimeMs,
      imagePath: imagePath,
    );
  }

  OcrResult copyWith({
    bool? success,
    List<UnifiedClientModel>? extractedClients,
    String? extractedText,
    double? confidence,
    String? error,
    int? processingTimeMs,
    String? imagePath,
  }) {
    return OcrResult._(
      success: success ?? this.success,
      extractedClients: extractedClients ?? this.extractedClients,
      extractedText: extractedText ?? this.extractedText,
      confidence: confidence ?? this.confidence,
      error: error ?? this.error,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  String get imageName => imagePath.split('/').last.split('\\').last;
}

/// Rezultatul procesarii batch
class BatchOcrResult {
  final bool success;
  final int totalImages;
  final int successfulImages;
  final int failedImages;
  final List<UnifiedClientModel> allClients;
  final List<OcrResult> individualResults;
  final int totalProcessingTimeMs;

  const BatchOcrResult({
    required this.success,
    required this.totalImages,
    required this.successfulImages,
    required this.failedImages,
    required this.allClients,
    required this.individualResults,
    required this.totalProcessingTimeMs,
  });

  double get successRate => totalImages > 0 ? successfulImages / totalImages : 0.0;
  double get avgProcessingTimePerImage => totalImages > 0 ? totalProcessingTimeMs / totalImages : 0.0;
}

/// Statistici OCR
class OcrStats {
  final int totalProcessed;
  final int totalSuccess;
  final int totalFailed;
  final double avgConfidence;
  final double avgProcessingTime;

  const OcrStats({
    required this.totalProcessed,
    required this.totalSuccess,
    required this.totalFailed,
    required this.avgConfidence,
    required this.avgProcessingTime,
  });

  double get successRate => totalProcessed > 0 ? totalSuccess / totalProcessed : 0.0;
} 