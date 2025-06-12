import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:broker_app/frontend/common/app_theme.dart';

/// Service pentru gestionarea setărilor aplicației per consultant
/// Folosește SharedPreferences pentru persistența datelor și ChangeNotifier pentru actualizări în timp real
class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Prefixes pentru chei per consultant
  static const String _themeModePrefix = 'theme_mode_';
  static const String _themeColorPrefix = 'theme_color_';
  
  // Chei pentru tema implicită (pentru authScreen)
  static const String _defaultThemeModeKey = 'default_theme_mode';
  static const String _defaultThemeColorKey = 'default_theme_color';

  // Stări interne
  late AppThemeMode _currentThemeMode;
  late AppThemeColor _currentThemeColor;
  bool _isInitialized = false;
  String? _currentConsultantId;

  /// Getteri pentru starea curentă
  AppThemeMode get currentThemeMode => _currentThemeMode;
  AppThemeColor get currentThemeColor => _currentThemeColor;
  bool get isInitialized => _isInitialized;

  /// Obține ID-ul consultantului curent
  String? get _consultantId => _auth.currentUser?.uid;

  /// Inițializarea service-ului - se apelează la pornirea aplicației
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final consultantId = _consultantId;
      await _loadThemeSettings(consultantId);
      
      _currentConsultantId = consultantId;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing SettingsService: $e');
      // În cazul unei erori, folosim valorile implicite
      await _setDefaultTheme();
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Reîncarcă setările când se schimbă consultantul
  Future<void> onConsultantChanged() async {
    final newConsultantId = _consultantId;
    
    // Dacă consultantul s-a schimbat, încarcă noile setări
    if (newConsultantId != _currentConsultantId) {
      _currentConsultantId = newConsultantId;
      await _loadThemeSettings(newConsultantId);
      
      // If user logged out (consultantId is null), force apply default theme
      if (newConsultantId == null) {
        // Force default theme values
        _currentThemeMode = AppThemeMode.auto;
        _currentThemeColor = AppThemeColor.blue;
        // Sync with AppTheme static variables immediately
        AppTheme.setThemeMode(_currentThemeMode);
        AppTheme.setThemeColor(_currentThemeColor);
      }
      
      notifyListeners();
    }
  }

  /// Încarcă setările pentru un consultant specific sau tema implicită
  Future<void> _loadThemeSettings(String? consultantId) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (consultantId != null) {
      // Încarcă setările specifice consultantului
      final themeModeIndex = prefs.getInt('$_themeModePrefix$consultantId');
      final themeColorIndex = prefs.getInt('$_themeColorPrefix$consultantId');
      
      if (themeModeIndex != null && themeModeIndex < AppThemeMode.values.length) {
        _currentThemeMode = AppThemeMode.values[themeModeIndex];
      } else {
        _currentThemeMode = AppThemeMode.auto; // default pentru consultant nou
      }

      if (themeColorIndex != null && themeColorIndex < AppThemeColor.values.length) {
        _currentThemeColor = AppThemeColor.values[themeColorIndex];
      } else {
        _currentThemeColor = AppThemeColor.blue; // default pentru consultant nou
      }
    } else {
      // Încarcă tema implicită pentru authScreen
      final themeModeIndex = prefs.getInt(_defaultThemeModeKey);
      final themeColorIndex = prefs.getInt(_defaultThemeColorKey);
      
      _currentThemeMode = (themeModeIndex != null && themeModeIndex < AppThemeMode.values.length) 
          ? AppThemeMode.values[themeModeIndex] 
          : AppThemeMode.auto; // default pentru authScreen

      _currentThemeColor = (themeColorIndex != null && themeColorIndex < AppThemeColor.values.length) 
          ? AppThemeColor.values[themeColorIndex] 
          : AppThemeColor.blue; // default albastru pentru authScreen
    }

    // Sync with AppTheme static variables
    AppTheme.setThemeMode(_currentThemeMode);
    AppTheme.setThemeColor(_currentThemeColor);
  }

  /// Setează tema implicită (auto + albastru)
  Future<void> _setDefaultTheme() async {
    _currentThemeMode = AppThemeMode.auto;
    _currentThemeColor = AppThemeColor.blue;
    // Sync with AppTheme static variables
    AppTheme.setThemeMode(_currentThemeMode);
    AppTheme.setThemeColor(_currentThemeColor);
  }

  /// Schimbă modul temei pentru consultantul curent
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_currentThemeMode == mode) return;

    _currentThemeMode = mode;
    // Sync with AppTheme static variables
    AppTheme.setThemeMode(mode);

    // Salvează în SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final consultantId = _consultantId;
      
      if (consultantId != null) {
        // Salvează pentru consultantul curent
        await prefs.setInt('$_themeModePrefix$consultantId', mode.index);
      } else {
        // Salvează ca temă implicită
        await prefs.setInt(_defaultThemeModeKey, mode.index);
      }
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }

    notifyListeners();
  }

  /// Schimbă culoarea temei pentru consultantul curent
  Future<void> setThemeColor(AppThemeColor color) async {
    if (_currentThemeColor == color) return;

    _currentThemeColor = color;
    // Sync with AppTheme static variables
    AppTheme.setThemeColor(color);

    // Salvează în SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final consultantId = _consultantId;
      
      if (consultantId != null) {
        // Salvează pentru consultantul curent
        await prefs.setInt('$_themeColorPrefix$consultantId', color.index);
      } else {
        // Salvează ca temă implicită
        await prefs.setInt(_defaultThemeColorKey, color.index);
      }
    } catch (e) {
      debugPrint('Error saving theme color: $e');
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

  /// Reset la setările implicite pentru consultantul curent
  Future<void> resetToDefaults() async {
    await setThemeMode(AppThemeMode.auto);
    await setThemeColor(AppThemeColor.blue);
  }

  /// Șterge setările pentru un consultant specific (folosit la ștergerea contului)
  Future<void> clearConsultantSettings(String consultantId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_themeModePrefix$consultantId');
      await prefs.remove('$_themeColorPrefix$consultantId');
    } catch (e) {
      debugPrint('Error clearing consultant settings: $e');
    }
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
        return 'Rosu';
      case AppThemeColor.yellow:
        return 'Galben';
      case AppThemeColor.green:
        return 'Verde';
      case AppThemeColor.cyan:
        return 'Turcoaz';
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
