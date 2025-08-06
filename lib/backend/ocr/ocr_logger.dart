import 'dart:io';
import 'package:flutter/foundation.dart';

/// Logger specializat pentru operatiile OCR
class OCRLogger {
  static final OCRLogger _instance = OCRLogger._internal();
  factory OCRLogger() => _instance;
  OCRLogger._internal();

  final List<LogEntry> _logs = [];
  bool _isEnabled = true;
  LogLevel _minLevel = LogLevel.info;

  /// Activeaza/dezactiveaza logging-ul
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (enabled) {
      info('OCR_LOGGER', 'Logging activat');
    }
  }

  /// Seteaza nivelul minim de logging
  void setMinLevel(LogLevel level) {
    _minLevel = level;
    info('OCR_LOGGER', 'Nivel minim setat la: ${level.name}');
  }

  /// Log de tip DEBUG
  void debug(String category, String message, [Map<String, dynamic>? data]) {
    _log(LogLevel.debug, category, message, data);
  }

  /// Log de tip INFO
  void info(String category, String message, [Map<String, dynamic>? data]) {
    _log(LogLevel.info, category, message, data);
  }

  /// Log de tip WARNING
  void warning(String category, String message, [Map<String, dynamic>? data]) {
    _log(LogLevel.warning, category, message, data);
  }

  /// Log de tip ERROR
  void error(String category, String message, [Map<String, dynamic>? data]) {
    _log(LogLevel.error, category, message, data);
  }

  /// Log intern
  void _log(LogLevel level, String category, String message, Map<String, dynamic>? data) {
    if (!_isEnabled || level.priority < _minLevel.priority) return;

    final entry = LogEntry(
      level: level,
      category: category,
      message: message,
      timestamp: DateTime.now(),
      data: data ?? {},
    );

    _logs.add(entry);
    
    // Limiteaza numarul de log-uri (pastreaza ultimele 1000)
    if (_logs.length > 1000) {
      _logs.removeRange(0, _logs.length - 1000);
    }

    // Output in consola
    _printToConsole(entry);
  }

  /// Afiseaza log-ul in consola cu formatare colorata
  void _printToConsole(LogEntry entry) {
    final emoji = _getEmojiForLevel(entry.level);
    final timestamp = _formatTimestamp(entry.timestamp);
    final categoryFormatted = entry.category.padRight(15);
    
    var logMessage = '$emoji [$timestamp] $categoryFormatted: ${entry.message}';
    
    if (entry.data.isNotEmpty) {
      logMessage += ' | Data: ${entry.data}';
    }

    debugPrint(logMessage);
  }

  /// Emoji pentru fiecare nivel de log
  String _getEmojiForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return '📝';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }

  /// Formateaza timestamp-ul
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}:'
           '${timestamp.second.toString().padLeft(2, '0')}.'
           '${timestamp.millisecond.toString().padLeft(3, '0')}';
  }

  // Metode specifice pentru OCR

  /// Log pentru inceputul procesarii unei imagini
  void startImageProcessing(String imageName, int imageSize) {
    info('IMAGE_PROCESSING', 'Incepe procesarea imaginii: $imageName (${_formatFileSize(imageSize)})', {
      'image_name': imageName,
      'image_size_bytes': imageSize,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Log pentru finalizarea procesarii unei imagini
  void completeImageProcessing(String imageName, int duration, bool success, [String? error]) {
    if (success) {
      info('IMAGE_PROCESSING', 'Imagine procesata cu succes: $imageName in ${duration}ms', {
        'image_name': imageName,
        'duration_ms': duration,
        'success': true,
      });
    } else {
      error!;
    }
  }

  /// Log pentru extragerea textului OCR
  void logTextExtraction(String imageName, int textLength, double confidence) {
    info('TEXT_EXTRACTION', 'Text extras din $imageName: $textLength caractere (confidence: ${(confidence * 100).toStringAsFixed(1)}%)', {
      'image_name': imageName,
      'text_length': textLength,
      'confidence': confidence,
    });
  }

  /// Log pentru contactele detectate
  void logContactsDetected(String imageName, int contactCount, List<String> contactNames) {
    info('CONTACT_DETECTION', 'Detectate $contactCount contacte in $imageName: ${contactNames.join(', ')}', {
      'image_name': imageName,
      'contact_count': contactCount,
      'contact_names': contactNames,
    });
  }

  /// Log pentru imbunatatirea imaginii
  void logImageEnhancement(String imageName, String enhancements) {
    debug('IMAGE_ENHANCEMENT', 'Imagine imbunatatita: $imageName - $enhancements', {
      'image_name': imageName,
      'enhancements': enhancements,
    });
  }

  /// Log pentru transformarea textului
  void logTextTransformation(String originalLength, String cleanedLength, int improvements) {
    debug('TEXT_TRANSFORMATION', 'Text transformat: $originalLength → $cleanedLength caractere, $improvements imbunatatiri', {
      'original_length': originalLength,
      'cleaned_length': cleanedLength,
      'improvements_count': improvements,
    });
  }

  /// Log pentru performanta
  void logPerformanceMetric(String operation, int durationMs, Map<String, dynamic> metrics) {
    debug('PERFORMANCE', '$operation completata in ${durationMs}ms', {
      'operation': operation,
      'duration_ms': durationMs,
      ...metrics,
    });
  }

  /// Obtine log-urile filtrate
  List<LogEntry> getLogs({
    LogLevel? minLevel,
    String? category,
    DateTime? since,
  }) {
    return _logs.where((log) {
      if (minLevel != null && log.level.priority < minLevel.priority) return false;
      if (category != null && log.category != category) return false;
      if (since != null && log.timestamp.isBefore(since)) return false;
      return true;
    }).toList();
  }

  /// Obtine statistici de logging
  LogStatistics getStatistics() {
    final now = DateTime.now();
    final last24h = now.subtract(const Duration(hours: 24));
    
    final recentLogs = _logs.where((log) => log.timestamp.isAfter(last24h)).toList();
    
    final debugCount = recentLogs.where((log) => log.level == LogLevel.debug).length;
    final infoCount = recentLogs.where((log) => log.level == LogLevel.info).length;
    final warningCount = recentLogs.where((log) => log.level == LogLevel.warning).length;
    final errorCount = recentLogs.where((log) => log.level == LogLevel.error).length;
    
    final categories = <String, int>{};
    for (final log in recentLogs) {
      categories[log.category] = (categories[log.category] ?? 0) + 1;
    }
    
    return LogStatistics(
      totalLogs: _logs.length,
      recentLogs: recentLogs.length,
      debugCount: debugCount,
      infoCount: infoCount,
      warningCount: warningCount,
      errorCount: errorCount,
      categories: categories,
      oldestLog: _logs.isNotEmpty ? _logs.first.timestamp : null,
      newestLog: _logs.isNotEmpty ? _logs.last.timestamp : null,
    );
  }

  /// Exporta log-urile intr-un format text
  String exportLogs({
    LogLevel? minLevel,
    String? category,
    DateTime? since,
  }) {
    final logs = getLogs(minLevel: minLevel, category: category, since: since);
    final buffer = StringBuffer();
    
    buffer.writeln('=== OCR LOGS EXPORT ===');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('Total logs: ${logs.length}');
    buffer.writeln('');
    
    for (final log in logs) {
      buffer.writeln('${_formatTimestamp(log.timestamp)} [${log.level.name.toUpperCase()}] ${log.category}: ${log.message}');
      if (log.data.isNotEmpty) {
        buffer.writeln('  Data: ${log.data}');
      }
    }
    
    return buffer.toString();
  }

  /// Salveaza log-urile intr-un fisier (doar pe desktop)
  Future<bool> saveLogsToFile(String filePath) async {
    if (kIsWeb) {
      warning('FILE_EXPORT', 'Salvarea in fisier nu este suportata pe web');
      return false;
    }
    
    try {
      final file = File(filePath);
      final content = exportLogs();
      await file.writeAsString(content);
      
      info('FILE_EXPORT', 'Log-uri salvate in: $filePath');
      return true;
    } catch (e) {
      error('FILE_EXPORT', 'Eroare la salvarea log-urilor: $e');
      return false;
    }
  }

  /// Curata log-urile vechi
  void clearOldLogs([Duration? olderThan]) {
    final cutoff = DateTime.now().subtract(olderThan ?? const Duration(days: 7));
    final oldCount = _logs.length;
    
    _logs.removeWhere((log) => log.timestamp.isBefore(cutoff));
    
    final removedCount = oldCount - _logs.length;
    if (removedCount > 0) {
      info('MAINTENANCE', 'Sterse $removedCount log-uri vechi');
    }
  }

  /// Curata toate log-urile
  void clearAllLogs() {
    final count = _logs.length;
    _logs.clear();
    info('MAINTENANCE', 'Sterse toate log-urile ($count intrari)');
  }

  /// Formateaza dimensiunea fisierului
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// Nivelurile de logging
enum LogLevel {
  debug(0),
  info(1),
  warning(2),
  error(3);

  const LogLevel(this.priority);
  final int priority;
}

/// O intrare in log
class LogEntry {
  final LogLevel level;
  final String category;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  const LogEntry({
    required this.level,
    required this.category,
    required this.message,
    required this.timestamp,
    required this.data,
  });

  @override
  String toString() => '${level.name.toUpperCase()}: [$category] $message';
}

/// Statistici de logging
class LogStatistics {
  final int totalLogs;
  final int recentLogs;
  final int debugCount;
  final int infoCount;
  final int warningCount;
  final int errorCount;
  final Map<String, int> categories;
  final DateTime? oldestLog;
  final DateTime? newestLog;

  const LogStatistics({
    required this.totalLogs,
    required this.recentLogs,
    required this.debugCount,
    required this.infoCount,
    required this.warningCount,
    required this.errorCount,
    required this.categories,
    this.oldestLog,
    this.newestLog,
  });

  @override
  String toString() {
    return 'LogStatistics(total: $totalLogs, recent: $recentLogs, '
           'errors: $errorCount, warnings: $warningCount, '
           'categories: ${categories.length})';
  }
} 