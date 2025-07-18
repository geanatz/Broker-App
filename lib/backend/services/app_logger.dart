import 'package:flutter/foundation.dart';

/// Centralized logging system for the entire application
/// Provides structured, efficient logging with categories and levels
class AppLogger {
  static bool _isEnabled = true;
  static bool _verboseMode = false;
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
  
  /// Log lifecycle events (app start, screen transitions, etc.)
  static void lifecycle(String component, String event, [Map<String, dynamic>? data]) {
    if (!_isEnabled) return;
    final message = _formatMessage('🚀', component, event, data);
    debugPrint(message);
  }
  
  /// Log critical data changes (client added, updated, deleted)
  static void dataChange(String component, String operation, String entity, [Map<String, dynamic>? data]) {
    if (!_isEnabled) return;
    final emoji = _getEmojiForOperation(operation);
    final message = _formatMessage(emoji, component, '$operation $entity', data);
    debugPrint(message);
  }
  
  /// Log errors and exceptions
  static void error(String component, String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_isEnabled) return;
    final errorMessage = _formatMessage('❌', component, message, {'error': error?.toString()});
    debugPrint(errorMessage);
    
    if (_verboseMode && error != null) {
      debugPrint('Error details: $error');
    }
    if (_verboseMode && stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }
  
  /// Log warnings
  static void warning(String component, String message, [Map<String, dynamic>? data]) {
    if (!_isEnabled) return;
    final warningMessage = _formatMessage('⚠️', component, message, data);
    debugPrint(warningMessage);
  }
  
  /// Log success operations
  static void success(String component, String message, [Map<String, dynamic>? data]) {
    if (!_isEnabled) return;
    final successMessage = _formatMessage('✅', component, message, data);
    debugPrint(successMessage);
  }
  
  /// Log sync and stream events
  static void sync(String component, String event, [Map<String, dynamic>? data]) {
    if (!_isEnabled) return;
    final syncMessage = _formatMessage('🔄', component, event, data);
    debugPrint(syncMessage);
  }
  
  /// Log UI state transitions
  static void uiState(String component, String state, [Map<String, dynamic>? data]) {
    if (!_isEnabled) return;
    final uiMessage = _formatMessage('🔧', component, state, data);
    debugPrint(uiMessage);
  }
  
  /// Log with deduplication to prevent spam
  static void logWithDedup(String component, String message, [Map<String, dynamic>? data]) {
    if (!_isEnabled) return;
    
    final key = '$component:$message';
    final now = DateTime.now();
    
    if (_shouldLogOperation(key, now)) {
      final logMessage = _formatMessage('📝', component, message, data);
      debugPrint(logMessage);
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
    
    var logMessage = '$emoji $componentUpper: $message';
    
    if (data != null && data.isNotEmpty) {
      final dataStr = data.entries.map((e) => '${e.key}=${e.value}').join(', ');
      logMessage += ' | $dataStr';
    }
    
    return logMessage;
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