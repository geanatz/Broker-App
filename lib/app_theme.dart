import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Clasa AppTheme contine toate culorile, dimensiunile, stilurile si variabilele de design
/// folosite in intreaga aplicatie, pentru a asigura consistenta designului.
/// 
/// Aplicatia foloseste doar modul light cu paleta de culori albastra.

class AppTheme extends ChangeNotifier {
  static final AppTheme _instance = AppTheme._internal();
  factory AppTheme() => _instance;
  AppTheme._internal();

  // ======== DIMENSIUNI ========
  
  // Dimensiuni pentru text
  static const double fontSizeTiny = 13.0;
  static const double fontSizeSmall = 15.0;
  static const double fontSizeMedium = 17.0;
  static const double fontSizeLarge = 19.0;
  static const double fontSizeHuge = 21.0;

  // Border radius
  static const double borderRadiusTiny = 8.0; 
  static const double borderRadiusSmall = 16.0; 
  static const double borderRadiusMedium = 24.0;
  static const double borderRadiusLarge = 32.0; 
  static const double borderRadiusHuge = 40.0;

  // Dimensiuni pentru icon-uri
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;

  // Spatieri
  static const double tinyGap = 4.0;
  static const double smallGap = 8.0;
  static const double mediumGap = 16.0;
  static const double largeGap = 24.0;
  static const double hugeGap = 32.0;
  
  // Alte dimensiuni
  static const double slotBorderThickness = 4.0;
  static const double iconBorderThickness = 2.0;
  static const double navButtonHeight = 48.0;

  // Font weight
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // Font family
  static const String fontFamily = 'Outfit';

  /// Safe wrapper pentru GoogleFonts.outfit cu fallback
  static TextStyle safeOutfit({
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

  // ======== CULORI FIXE LIGHT MODE CU PALETA ALBASTRA ========

  // Culori pentru background gradient
  static const Color backgroundStart = Color(0xFFA4C2C2);
  static const Color backgroundEnd = Color(0xFFC2A4C2);

  // Culori pentru containere
  static const Color containerColor1 = Color(0xFFC4C4D4);
  static const Color containerColor2 = Color(0xFFACACD3);

  // Culori pentru elemente
  static const Color elementColor1 = Color(0xFF8A8AA8);
  static const Color elementColor2 = Color(0xFF666699);
  static const Color elementColor3 = Color(0xFF4D4D80);

  // Culori pentru widget-uri
  static const Color widgetBackground = Color(0xFFD9D9D9);
  static const Color popupBackground = Color(0xFFD9D9D9);

  // ======== UMBRELE ========
  static BoxShadow get widgetShadow => BoxShadow(
    color: Colors.black.withValues(alpha: 0.1),
    blurRadius: 15,
  );
  
  static BoxShadow get buttonShadow => BoxShadow(
    color: Colors.black.withValues(alpha: 0.2),
    blurRadius: 4,
    offset: const Offset(0, 2),
  );
  
  static BoxShadow get slotShadow => BoxShadow(
    color: Colors.black.withValues(alpha: 0.2),
    blurRadius: 4,
    offset: const Offset(0, 2),
  );

  // ======== STILURI TEXT ========
  static TextStyle get headerTitleStyle => GoogleFonts.outfit(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.w600,
    color: elementColor1,
  );

  static TextStyle get subHeaderStyle => GoogleFonts.outfit(
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.w500,
    color: elementColor1,
  );

  static TextStyle get primaryTitleStyle => GoogleFonts.outfit(
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.w600,
    color: elementColor2,
  );

  static TextStyle get secondaryTitleStyle => GoogleFonts.outfit(
    fontSize: fontSizeSmall,
    fontWeight: FontWeight.w500,
    color: elementColor1,
  );

  static TextStyle get smallTextStyle => GoogleFonts.outfit(
    fontSize: fontSizeSmall,
    fontWeight: FontWeight.w500,
    color: elementColor2,
  );

  static TextStyle get tinyTextStyle => GoogleFonts.outfit(
    fontSize: fontSizeTiny,
    fontWeight: FontWeight.w500,
    color: elementColor2,
  );

  static TextStyle get navigationHeaderStyle => GoogleFonts.outfit(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.w500,
    color: elementColor1,
  );

  static TextStyle get navigationButtonTextStyle => GoogleFonts.outfit(
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.w500,
    color: elementColor2,
  );

  // ======== DECORATIUNI ========
  
  // Background gradient pentru ecran
  static Gradient get appBackground => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundStart, backgroundEnd],
    stops: const [0.0, 1.0],
  );

  // Decoratiune pentru widget-uri
  static BoxDecoration get widgetDecoration => BoxDecoration(
    color: widgetBackground,
    borderRadius: BorderRadius.circular(borderRadiusLarge),
    boxShadow: [widgetShadow],
  );

  // Decoratiune pentru popup-uri
  static BoxDecoration get popupDecoration => BoxDecoration(
    color: popupBackground,
    borderRadius: BorderRadius.circular(borderRadiusLarge),
  );

  // Decoratiune pentru container-ul principal (de nivel 1)
  static BoxDecoration get container1Decoration => BoxDecoration(
    color: containerColor1,
    borderRadius: BorderRadius.circular(borderRadiusMedium),
  );

  // Decoratiune pentru container-ul secundar (de nivel 2) 
  static BoxDecoration get container2Decoration => BoxDecoration(
    color: containerColor2,
    borderRadius: BorderRadius.circular(borderRadiusSmall),
  );
  
  // Decoratiune pentru slot-uri rezervate in calendar
  static BoxDecoration get reservedSlotDecoration => BoxDecoration(
    color: const Color(0xFFC6ACD3),
    borderRadius: BorderRadius.circular(borderRadiusSmall),
    boxShadow: [slotShadow],
  );
} 

