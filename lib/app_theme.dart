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

  // Font family - folosim GoogleFonts.outfit() direct
  // static const String fontFamily = 'Outfit';

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
        fontFamily: 'Outfit', // Fallback font family
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

  // Culori pentru statusuri
  static const Color statusFinalizat = Color(0xFFC9EFC7);
  static const Color statusProgramat = Color(0xFFC7E9EF);
  static const Color statusAmanat = Color(0xFFEFE5C7);
  static const Color statusNuRaspunde = Color(0xFFEFCDC7);

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

  // Decoratiune pentru widget-uri fara umbra
  static BoxDecoration get widgetDecorationWithoutShadow => BoxDecoration(
    color: backgroundColor1,
    borderRadius: BorderRadius.circular(borderRadiusMedium),
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

  // ======== PRIMARY AND SECONDARY COLORS ========
  // Primary and secondary color palette - 10 colors with fill and stroke variants
  static const Color primaryColor1 = Color(0xFFEFE5C7);
  static const Color secondaryColor1 = Color(0xFFE8DAB0);

  // Color names and descriptions
  static const Map<int, Map<String, String>> colorInfo = {
    1: {'name': 'Auriu', 'description': 'Lumina calda'},
    2: {'name': 'Lime', 'description': 'Prospetime naturala'},
    3: {'name': 'Verde', 'description': 'Padurea tropicala'},
    4: {'name': 'Turcoaz', 'description': 'Ocean linistit'},
    5: {'name': 'Albastru', 'description': 'Cer senin'},
    6: {'name': 'Indigo', 'description': 'Noapte profunda'},
    7: {'name': 'Violet', 'description': 'Lavanda de vara'},
    8: {'name': 'Magenta', 'description': 'Floare exotica'},
    9: {'name': 'Roz', 'description': 'Apus romantic'},
    10: {'name': 'Coral', 'description': 'Zorile diminetii'},
  };

  static const Color primaryColor2 = Color(0xFFE1EFC7);
  static const Color secondaryColor2 = Color(0xFFD5E9AF);

  static const Color primaryColor3 = Color(0xFFC9EFC7);
  static const Color secondaryColor3 = Color(0xFFB2E9AF);

  static const Color primaryColor4 = Color(0xFFC7EFDD);
  static const Color secondaryColor4 = Color(0xFFAFE9CF);

  static const Color primaryColor5 = Color(0xFFC7E9EF);
  static const Color secondaryColor5 = Color(0xFFAFE0E9);

  static const Color primaryColor6 = Color(0xFFC7D1EF);
  static const Color secondaryColor6 = Color(0xFFAFBDE9);

  static const Color primaryColor7 = Color(0xFFD5C7EF);
  static const Color secondaryColor7 = Color(0xFFC3AFE9);

  static const Color primaryColor8 = Color(0xFFEDC7EF);
  static const Color secondaryColor8 = Color(0xFFE6AFE9);

  static const Color primaryColor9 = Color(0xFFEFC7D9);
  static const Color secondaryColor9 = Color(0xFFE9AFC9);

  static const Color primaryColor10 = Color(0xFFEFCDC7);
  static const Color secondaryColor10 = Color(0xFFE9B8AF);

  // Helper method to get primary color by index (1-10)
  static Color getPrimaryColor(int index) {
    // Log pentru monitorizarea accesului la culori
    if (index < 1 || index > 10) {
      return primaryColor1; // fallback
    }
    
    switch (index) {
      case 1: return primaryColor1;
      case 2: return primaryColor2;
      case 3: return primaryColor3;
      case 4: return primaryColor4;
      case 5: return primaryColor5;
      case 6: return primaryColor6;
      case 7: return primaryColor7;
      case 8: return primaryColor8;
      case 9: return primaryColor9;
      case 10: return primaryColor10;
      default: return primaryColor1; // fallback
    }
  }

  // Helper method to get secondary color by index (1-10)
  static Color getSecondaryColor(int index) {
    // Log pentru monitorizarea accesului la culori
    if (index < 1 || index > 10) {
      return secondaryColor1; // fallback
    }

    switch (index) {
      case 1: return secondaryColor1;
      case 2: return secondaryColor2;
      case 3: return secondaryColor3;
      case 4: return secondaryColor4;
      case 5: return secondaryColor5;
      case 6: return secondaryColor6;
      case 7: return secondaryColor7;
      case 8: return secondaryColor8;
      case 9: return secondaryColor9;
      case 10: return secondaryColor10;
      default: return secondaryColor1; // fallback
    }
  }

  // Helper method to get color name by index (1-10)
  static String getColorName(int index) {
    if (index < 1 || index > 10) {
      return colorInfo[1]!['name']!;
    }

    return colorInfo[index]!['name']!;
  }

  // Helper method to get color description by index (1-10)
  static String getColorDescription(int index) {
    if (index < 1 || index > 10) {
      return colorInfo[1]!['description']!;
    }

    return colorInfo[index]!['description']!;
  }

  // ======== CONSULTANT COLORS (DEPRECATED - USE PRIMARY/SECONDARY COLORS INSTEAD) ========
  // These are kept for backward compatibility but should be replaced with primary/secondary colors
  @Deprecated('Use primaryColor1 instead')
  static const Color consultantColor1 = primaryColor1;
  @Deprecated('Use secondaryColor1 instead')
  static const Color consultantStrokeColor1 = secondaryColor1;

  @Deprecated('Use primaryColor2 instead')
  static const Color consultantColor2 = primaryColor2;
  @Deprecated('Use secondaryColor2 instead')
  static const Color consultantStrokeColor2 = secondaryColor2;

  @Deprecated('Use primaryColor3 instead')
  static const Color consultantColor3 = primaryColor3;
  @Deprecated('Use secondaryColor3 instead')
  static const Color consultantStrokeColor3 = secondaryColor3;

  @Deprecated('Use primaryColor4 instead')
  static const Color consultantColor4 = primaryColor4;
  @Deprecated('Use secondaryColor4 instead')
  static const Color consultantStrokeColor4 = secondaryColor4;

  @Deprecated('Use primaryColor5 instead')
  static const Color consultantColor5 = primaryColor5;
  @Deprecated('Use secondaryColor5 instead')
  static const Color consultantStrokeColor5 = secondaryColor5;

  @Deprecated('Use primaryColor6 instead')
  static const Color consultantColor6 = primaryColor6;
  @Deprecated('Use secondaryColor6 instead')
  static const Color consultantStrokeColor6 = secondaryColor6;

  @Deprecated('Use primaryColor7 instead')
  static const Color consultantColor7 = primaryColor7;
  @Deprecated('Use secondaryColor7 instead')
  static const Color consultantStrokeColor7 = secondaryColor7;

  @Deprecated('Use primaryColor8 instead')
  static const Color consultantColor8 = primaryColor8;
  @Deprecated('Use secondaryColor8 instead')
  static const Color consultantStrokeColor8 = secondaryColor8;

  @Deprecated('Use primaryColor9 instead')
  static const Color consultantColor9 = primaryColor9;
  @Deprecated('Use secondaryColor9 instead')
  static const Color consultantStrokeColor9 = secondaryColor9;

  @Deprecated('Use primaryColor10 instead')
  static const Color consultantColor10 = primaryColor10;
  @Deprecated('Use secondaryColor10 instead')
  static const Color consultantStrokeColor10 = secondaryColor10;

  @Deprecated('Use getPrimaryColor instead')
  static Color getConsultantColor(int index) => getPrimaryColor(index);

  @Deprecated('Use getSecondaryColor instead')
  static Color getConsultantStrokeColor(int index) => getSecondaryColor(index);

  @Deprecated('Use getColorName instead')
  static String getConsultantColorName(int index) => getColorName(index);

  @Deprecated('Use getColorDescription instead')
  static String getConsultantColorDescription(int index) => getColorDescription(index);
} 

