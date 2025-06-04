import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A safe wrapper around GoogleFonts that provides error handling
/// and fallback fonts in case GoogleFonts fails to load.
class SafeGoogleFonts {
  /// The font family name for the primary font
  static const String fontFamily = 'Outfit';

  /// Creates a TextStyle using the Outfit font with the given parameters.
  /// Falls back to the system default font if GoogleFonts fails to load.
  static TextStyle outfit({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    try {
      return GoogleFonts.outfit(
        textStyle: textStyle,
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        locale: locale,
        foreground: foreground,
        background: background,
        shadows: shadows,
        fontFeatures: fontFeatures,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
      );
    } catch (e) {
      // Fallback to default TextStyle if GoogleFonts fails
      return TextStyle(
        fontFamily: fontFamily,
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        locale: locale,
        foreground: foreground,
        background: background,
        shadows: shadows,
        fontFeatures: fontFeatures,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
      );
    }
  }

  /// Creates a TextTheme using the Outfit font.
  /// Falls back to the default TextTheme if GoogleFonts fails to load.
  static TextTheme outfitTextTheme([TextTheme? textTheme]) {
    try {
      return GoogleFonts.outfitTextTheme(textTheme);
    } catch (e) {
      // Fallback to default TextTheme if GoogleFonts fails
      return textTheme ?? const TextTheme();
    }
  }
}

/// A safe wrapper that provides access to the font family name
/// Used for legacy compatibility with existing code
class SafeSafeGoogleFonts {
  /// The font family name for the primary font
  static const String fontFamily = SafeGoogleFonts.fontFamily;
} 