import 'package:flutter/material.dart';

/// Mixin care oferă o metodă sigură pentru setState
/// Previne eroarea "This widget has been unmounted" prin verificarea mounted
mixin SafeStateMixin<T extends StatefulWidget> on State<T> {
  /// setState sigur care verifică dacă widget-ul este încă mounted
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    } else {
      debugPrint('⚠️ Attempted setState on unmounted widget: ${T.toString()}');
    }
  }
  
  /// Versiune async pentru operații care necesită setState după await
  Future<void> safeSetStateAsync(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (e) {
      debugPrint('❌ Error in async operation: $e');
      if (mounted) {
        // Poți adăuga logica de error handling aici
        rethrow;
      }
    }
  }
  
  /// Helper pentru loading states
  void safeSetLoading(bool isLoading) {
    safeSetState(() {
      // Presupunând că majoritatea claselor au o variabilă _isLoading
      // Această metodă trebuie overridată în clasele care nu au această variabilă
    });
  }
}

/// Extensie pentru context-ul ScaffoldMessenger care verifică mounted
extension SafeScaffoldMessenger on BuildContext {
  /// Afișează SnackBar doar dacă context-ul este valid
  void showSafeSnackBar(SnackBar snackBar) {
    try {
      ScaffoldMessenger.of(this).showSnackBar(snackBar);
    } catch (e) {
      debugPrint('⚠️ Could not show SnackBar, context might be invalid: $e');
    }
  }
  
  /// Afișează mesaj de eroare sigur
  void showSafeError(String message) {
    showSafeSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  /// Afișează mesaj de succes sigur
  void showSafeSuccess(String message) {
    showSafeSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
} 