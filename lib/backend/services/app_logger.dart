import 'dart:io';
import 'package:flutter/foundation.dart';

/// Centralized logging system for the entire application
/// Provides structured, efficient logging with categories and levels
class AppLogger {
  static bool _isEnabled = true;
  static bool _verboseMode = false;
  static bool _useEmojis = false; // default to no emojis per preferences
  static bool _fileLoggingEnabled = false;
  static IOSink? _logSink;
  static String? _logFilePath;
  static final Set<String> _loggedOperations = <String>{};
  static final Map<String, DateTime> _lastLogTime = <String, DateTime>{};
  
  /// Enable/disable logging
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }
  
  /// Enable/disable verbose logging
  static void setVerboseMode(bool enabled) {
    _verboseMode = enabled;
  }
  
  /// Enable/disable emoji prefix in console logs
  static void setUseEmojis(bool enabled) {
    _useEmojis = enabled;
  }

  /// Initialize file logging to given absolute path. Creates file if missing.
  /// Rotates if file exceeds ~5 MB by truncating.
  static Future<void> initFileLogging(String absoluteFilePath) async {
    try {
      final file = File(absoluteFilePath);
      if (await file.exists()) {
        final length = await file.length();
        if (length > 5 * 1024 * 1024) {
          await file.writeAsString('', mode: FileMode.write);
        }
      } else {
        await file.create(recursive: true);
      }
      _logSink = file.openWrite(mode: FileMode.append);
      _logFilePath = absoluteFilePath;
      _fileLoggingEnabled = true;
      _writeHeader();
    } catch (e) {
      _fileLoggingEnabled = false;
      debugPrint('AppLogger: failed to init file logging: $e');
    }
  }

  /// Close file logging sink
  static Future<void> closeFileLogging() async {
    try {
      await _logSink?.flush();
      await _logSink?.close();
    } catch (_) {}
    _logSink = null;
    _fileLoggingEnabled = false;
  }
  
  /// Log lifecycle events (app start, screen transitions, etc.)
  static void lifecycle(String component, String event, [Map<String, dynamic>? data]) {
    if (!_isEnabled) return;
    final message = _formatMessage(_useEmojis ? '🚀' : '', component, event, data);
    debugPrint(message);
    _writeToFile(_formatPlainMessage(component, event, data));
  }
  
  /// Log critical data changes (client added, updated, deleted)
  static void dataChange(String component, String operation, String entity, [Map<String, dynamic>? data]) {
    if (!_isEnabled) return;
    final emoji = _useEmojis ? _getEmojiForOperation(operation) : '';
    final message = _formatMessage(emoji, component, '$operation $entity', data);
    debugPrint(message);
    _writeToFile(_formatPlainMessage(component, '$operation $entity', data));
  }
  
  /// Log errors and exceptions
  static void error(String component, String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_isEnabled) return;
    final emoji = _useEmojis ? '❌' : '';
    final errorMessage = _formatMessage(emoji, component, message, {'error': error?.toString()});
    debugPrint(errorMessage);
    _writeToFile(_formatPlainMessage(component, message, {'error': error?.toString()}));
    
    if (_verboseMode && error != null) {
      debugPrint('Error details: $error');
      _writeToFile('  details: $error');
    }
    if (_verboseMode && stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
      _writeToFile('  stack: $stackTrace');
    }
  }
  
  /// Log warnings
  static void warning(String component, String message, [Map<String, dynamic>? data]) {
    if (!_isEnabled) return;
    final emoji = _useEmojis ? '⚠️' : '';
    final warningMessage = _formatMessage(emoji, component, message, data);
    debugPrint(warningMessage);
    _writeToFile(_formatPlainMessage(component, message, data));
  }
  
  /// Log success operations
  static void success(String component, String message, [Map<String, dynamic>? data]) {
    if (!_isEnabled) return;
    final emoji = _useEmojis ? '✅' : '';
    final successMessage = _formatMessage(emoji, component, message, data);
    debugPrint(successMessage);
    _writeToFile(_formatPlainMessage(component, message, data));
  }
  
  /// Log sync and stream events
  static void sync(String component, String event, [Map<String, dynamic>? data]) {
    if (!_isEnabled) return;
    final emoji = _useEmojis ? '🔄' : '';
    final syncMessage = _formatMessage(emoji, component, event, data);
    debugPrint(syncMessage);
    _writeToFile(_formatPlainMessage(component, event, data));
  }
  
  /// Log UI state transitions
  static void uiState(String component, String state, [Map<String, dynamic>? data]) {
    if (!_isEnabled) return;
    final emoji = _useEmojis ? '🔧' : '';
    final uiMessage = _formatMessage(emoji, component, state, data);
    debugPrint(uiMessage);
    _writeToFile(_formatPlainMessage(component, state, data));
  }
  
  /// Log with deduplication to prevent spam
  static void logWithDedup(String component, String message, [Map<String, dynamic>? data]) {
    if (!_isEnabled) return;
    
    final key = '$component:$message';
    final now = DateTime.now();
    
    if (_shouldLogOperation(key, now)) {
      final emoji = _useEmojis ? '📝' : '';
      final logMessage = _formatMessage(emoji, component, message, data);
      debugPrint(logMessage);
      _writeToFile(_formatPlainMessage(component, message, data));
      _loggedOperations.add(key);
      _lastLogTime[key] = now;
    }
  }
  
  /// Check if operation should be logged (prevent spam)
  static bool _shouldLogOperation(String key, DateTime now) {
    final lastTime = _lastLogTime[key];
    if (lastTime == null) return true;
    
    // Don't log the same operation more than once per 3 seconds
    return now.difference(lastTime).inMilliseconds > 3000;
  }
  
  /// Get emoji for operation type
  static String _getEmojiForOperation(String operation) {
    switch (operation.toLowerCase()) {
      case 'added': return '➕';
      case 'removed': return '🗑️';
      case 'updated': return '✏️';
      case 'modified': return '✏️';
      case 'deleted': return '🗑️';
      case 'created': return '➕';
      case 'saved': return '💾';
      case 'loaded': return '📥';
      case 'synced': return '🔄';
      case 'connected': return '🔌';
      case 'disconnected': return '🔌';
      case 'initialized': return '🚀';
      case 'completed': return '✅';
      case 'failed': return '❌';
      case 'error': return '❌';
      case 'warning': return '⚠️';
      default: return '📝';
    }
  }
  
  /// Format log message with consistent structure
  static String _formatMessage(String emoji, String component, String message, Map<String, dynamic>? data) {
    DateTime.now().toString().substring(11, 19); // HH:MM:SS
    final componentUpper = component.toUpperCase();
    
    var logMessage = emoji.isNotEmpty ? '$emoji $componentUpper: $message' : '$componentUpper: $message';
    
    if (data != null && data.isNotEmpty) {
      final dataStr = data.entries.map((e) => '${e.key}=${e.value}').join(', ');
      logMessage += ' | $dataStr';
    }
    
    return logMessage;
  }

  static String _formatPlainMessage(String component, String message, Map<String, dynamic>? data) {
    final ts = DateTime.now().toIso8601String();
    final componentUpper = component.toUpperCase();
    var logMessage = '[$ts] $componentUpper: $message';
    if (data != null && data.isNotEmpty) {
      final dataStr = data.entries.map((e) => '${e.key}=${e.value}').join(', ');
      logMessage += ' | $dataStr';
    }
    return logMessage;
  }

  static void _writeHeader() {
    if (!_fileLoggingEnabled || _logSink == null) return;
    _logSink!.writeln('');
    _logSink!.writeln('================================');
    _logSink!.writeln('[${DateTime.now().toIso8601String()}] LOG START');
    _logSink!.writeln('File: ${_logFilePath ?? ''}');
    _logSink!.writeln('================================');
  }

  static void _writeToFile(String line) {
    if (!_fileLoggingEnabled || _logSink == null) return;
    try {
      _logSink!.writeln(line);
    } catch (_) {}
  }
  
  /// Clear logged operations cache
  static void clearCache() {
    _loggedOperations.clear();
    _lastLogTime.clear();
  }
  
  /// Get logging statistics
  static Map<String, dynamic> getStats() {
    return {
      'enabled': _isEnabled,
      'verboseMode': _verboseMode,
      'loggedOperations': _loggedOperations.length,
      'lastLogTime': _lastLogTime.length,
    };
  }
}

/// Performance monitoring utility
class PerformanceMonitor {
  static final Map<String, Stopwatch> _timers = {};
  static final Map<String, List<int>> _metrics = {};
  
  static void startTimer(String operation) {
    _timers[operation] = Stopwatch()..start();
  }
  
  static void endTimer(String operation) {
    final timer = _timers[operation];
    if (timer != null) {
      timer.stop();
      final duration = timer.elapsedMilliseconds;
      _metrics.putIfAbsent(operation, () => []).add(duration);
      _timers.remove(operation);
    }
  }
  
  static void logMetric(String operation, int duration) {
    _metrics.putIfAbsent(operation, () => []).add(duration);
  }
  
  static Map<String, double> getAverageMetrics() {
    final averages = <String, double>{};
    _metrics.forEach((operation, durations) {
      if (durations.isNotEmpty) {
        averages[operation] = durations.reduce((a, b) => a + b) / durations.length;
      }
    });
    return averages;
  }
  
  static void printPerformanceReport() {
    final averages = getAverageMetrics();
    if (averages.isEmpty) return;
    
    debugPrint('[PERF] PERFORMANCE REPORT:');
    debugPrint('=====================================');
    
    // Sort by average time (slowest first)
    final sortedMetrics = averages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (final entry in sortedMetrics) {
      final operation = entry.key;
      final avgTime = entry.value;
      final emoji = avgTime > 1000 ? '🐌' : avgTime > 500 ? '⚠️' : '⚡';
      debugPrint('$emoji $operation: ${avgTime.toStringAsFixed(2)}ms avg');
    }
    
    debugPrint('=====================================');
    debugPrint('Total operations tracked: ${_metrics.length}');
    debugPrint('Active timers: ${_timers.length}');
  }
  
  static void clearMetrics() {
    _metrics.clear();
    _timers.clear();
  }
} 
