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
  
  // Padding specific pentru header-uri (redus cu 8px din mediumGap)
  static const double headerPadding = 8.0;

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
  static const Color backgroundStart = Color(0xFFB0C9CF);
  static const Color backgroundEnd = Color(0xFFB0B5CF);

  // Culori pentru containere
  static const Color backgroundColor1 = Color(0xFFE7E6E4);
  static const Color backgroundColor2 = Color(0xFFEBEBEA);
  static const Color backgroundColor3 = Color(0xFFF0F0EF);

  // Culori pentru elemente
  static const Color elementColor1 = Color(0xFF938F8A);
  static const Color elementColor2 = Color(0xFF7D7B78);
  static const Color elementColor3 = Color(0xFF666666);

  // ======== UMBRELE ========
  // Umbra standard pentru elemente interactive
  static const List<BoxShadow> standardShadow = [
    BoxShadow(
      color: Color(0x14513F2A), // 8% opacity pentru 513F2A
      offset: Offset(0, 2), // Y = 2
      blurRadius: 4, // Blur = 4
      spreadRadius: 0,
    ),
  ];
  
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
  
  // Background solid (vizual) pentru ecran – implementat ca gradient cu aceeasi culoare la ambele capete
  static Gradient get backgroundColor1Gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundColor1, backgroundColor1],
    stops: const [0.0, 1.0],
  );

  // Area gradient (fostul boxColor)
  static Gradient get areaColor => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [const Color(0xFFE1DCD6), const Color(0xFFE1DCD6)],
    stops: const [0.0, 1.0],
  );

  // Decoratiune pentru widget-uri
  static BoxDecoration get widgetDecoration => BoxDecoration(
    color: backgroundColor1,
    borderRadius: BorderRadius.circular(borderRadiusMedium),
    boxShadow: standardShadow,
  );

  // Decoratiune pentru popup-uri
  static BoxDecoration get popupDecoration => BoxDecoration(
    color: backgroundColor1,
    borderRadius: BorderRadius.circular(borderRadiusMedium),
    boxShadow: standardShadow,
  );

  // Decoratiune pentru container-ul principal (de nivel 1)
  static BoxDecoration get container1Decoration => BoxDecoration(
    color: backgroundColor2,
    borderRadius: BorderRadius.circular(borderRadiusSmall),
  );

  // Decoratiune pentru container-ul secundar (de nivel 2) 
  static BoxDecoration get container2Decoration => BoxDecoration(
    color: backgroundColor3,
    borderRadius: BorderRadius.circular(borderRadiusSmall),
  );
  
  // Decoratiune pentru slot-uri rezervate in calendar
  static BoxDecoration get reservedSlotDecoration => BoxDecoration(
    color: const Color(0xFFC6ACD3),
    borderRadius: BorderRadius.circular(borderRadiusSmall),
  );

  // ======== CALENDAR SLOT THEME ========
  // Free slot base fill when not hovered (no stroke)
  static const Color calendarFreeFill = Color(0xFFE5E1DC); // E5E1DC

  // Hovered free slot stroke gradient
  static const Color calendarHoverStrokeTop = Color(0xFFCAD1D8); // CAD1D8
  static const Color calendarHoverStrokeBottom = Color(0xFFBEC7D0); // BEC7D0

  // Reserved slot stroke gradient
  static const Color calendarReservedStrokeTop = Color(0xFFA1B7CE); // A1B7CE
  static const Color calendarReservedStrokeBottom = Color(0xFF93ADC8); // 93ADC8
} 

