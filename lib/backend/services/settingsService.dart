import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:broker_app/frontend/common/appTheme.dart';

/// Service pentru gestionarea setărilor aplicației
/// Folosește SharedPreferences pentru persistența datelor și ChangeNotifier pentru actualizări în timp real
class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  // Chei pentru SharedPreferences
  static const String _themeModeKey = 'theme_mode';
  static const String _themeColorKey = 'theme_color';

  // Stări interne
  late AppThemeMode _currentThemeMode;
  late AppThemeColor _currentThemeColor;
  bool _isInitialized = false;

  /// Getteri pentru starea curentă
  AppThemeMode get currentThemeMode => _currentThemeMode;
  AppThemeColor get currentThemeColor => _currentThemeColor;
  bool get isInitialized => _isInitialized;

  /// Inițializarea service-ului - se apelează la pornirea aplicației
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Încarcă tema (light/dark/auto)
      final themeModeIndex = prefs.getInt(_themeModeKey);
      if (themeModeIndex != null && themeModeIndex < AppThemeMode.values.length) {
        _currentThemeMode = AppThemeMode.values[themeModeIndex];
      } else {
        _currentThemeMode = AppThemeMode.light; // valoare implicită
      }

      // Încarcă culoarea temei
      final themeColorIndex = prefs.getInt(_themeColorKey);
      if (themeColorIndex != null && themeColorIndex < AppThemeColor.values.length) {
        _currentThemeColor = AppThemeColor.values[themeColorIndex];
      } else {
        _currentThemeColor = AppThemeColor.blue; // valoare implicită
      }

      // Aplicăm setările în AppTheme
      AppTheme.setThemeMode(_currentThemeMode);
      AppTheme.setThemeColor(_currentThemeColor);

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // În cazul unei erori, folosim valorile implicite
      _currentThemeMode = AppThemeMode.light;
      _currentThemeColor = AppThemeColor.blue;
      AppTheme.setThemeMode(_currentThemeMode);
      AppTheme.setThemeColor(_currentThemeColor);
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Schimbă modul temei (light/dark)
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_currentThemeMode == mode) return;

    _currentThemeMode = mode;
    AppTheme.setThemeMode(mode);

    // Salvează în SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
    } catch (e) {
      // Eroare la salvare, dar continuăm cu schimbarea în memorie
      debugPrint('Error saving theme mode: $e');
    }

    notifyListeners();
  }

  /// Alternează între light și dark
  Future<void> toggleThemeMode() async {
    final newMode = _currentThemeMode == AppThemeMode.light 
        ? AppThemeMode.dark 
        : AppThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Schimbă culoarea temei
  Future<void> setThemeColor(AppThemeColor color) async {
    if (_currentThemeColor == color) return;

    _currentThemeColor = color;
    AppTheme.setThemeColor(color);

    // Salvează în SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeColorKey, color.index);
    } catch (e) {
      // Eroare la salvare, dar continuăm cu schimbarea în memorie
      debugPrint('Error saving theme color: $e');
    }

    notifyListeners();
  }

  /// Reset la setările implicite
  Future<void> resetToDefaults() async {
    await setThemeMode(AppThemeMode.light);
    await setThemeColor(AppThemeColor.blue);
  }

  /// Obține numele afișat pentru un mod de temă
  String getThemeModeDisplayName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Mod luminos';
      case AppThemeMode.dark:
        return 'Mod intunecat';
      case AppThemeMode.auto:
        return 'Mod automat';
    }
  }

  /// Obține numele afișat pentru o culoare de temă
  String getThemeColorDisplayName(AppThemeColor color) {
    switch (color) {
      case AppThemeColor.red:
        return 'Roșu';
      case AppThemeColor.yellow:
        return 'Galben';
      case AppThemeColor.green:
        return 'Verde';
      case AppThemeColor.cyan:
        return 'Cyan';
      case AppThemeColor.blue:
        return 'Albastru';
      case AppThemeColor.pink:
        return 'Roz';
    }
  }

  /// Obține lista tuturor modurilor de temă disponibile
  List<AppThemeMode> getAllThemeModes() {
    return AppThemeMode.values;
  }

  /// Obține lista tuturor culorilor de temă disponibile
  List<AppThemeColor> getAllThemeColors() {
    return AppThemeColor.values;
  }

  /// Verifică dacă un mod de temă este selectat
  bool isThemeModeSelected(AppThemeMode mode) {
    return _currentThemeMode == mode;
  }

  /// Verifică dacă o culoare de temă este selectată
  bool isThemeColorSelected(AppThemeColor color) {
    return _currentThemeColor == color;
  }
}
