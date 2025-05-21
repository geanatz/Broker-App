import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Enumerări pentru teme și culori - definite în afara clasei pentru a fi accesibile din alte părți
enum AppThemeMode { light, dark }
enum AppThemeColor { red, yellow, green, cyan, blue, pink }

/// Clasa AppTheme conține toate culorile, dimensiunile, stilurile și variabilele de design
/// folosite în întreaga aplicație, pentru a asigura consistența designului.
/// 
/// Suportă schimbarea temei între light/dark și 6 culori diferite:
/// - red, yellow, green, cyan, blue, pink

class AppTheme {
  AppTheme._(); // Constructor privat pentru a preveni instanțierea

  // Tema și culoarea curentă (valori implicite)
  static AppThemeMode currentThemeMode = AppThemeMode.light;
  static AppThemeColor currentThemeColor = AppThemeColor.blue;

  // ======== DIMENSIUNI ========
  
  // Dimensiuni pentru text
  static const double fontSizeTiny = 13.0;    // Număr de apeluri
  static const double fontSizeSmall = 15.0;   // Ora/Data întâlnirii
  static const double fontSizeMedium = 17.0;  // Descrierea întâlnirii, Etichetele din calendar, Titlurile din navigație, Echipa
  static const double fontSizeLarge = 19.0;   // Titlurile widget-urilor, Titlul întâlnirii, Consultant, Numele utilizatorului
  static const double fontSizeHuge = 21.0;    // Pentru titluri mai mari (dacă e nevoie)

  // Border radius
  static const double borderRadiusTiny = 8.0;      // Bara de încărcare
  static const double borderRadiusSmall = 16.0;    // Slot-uri calendar, butoane navigație
  static const double borderRadiusMedium = 24.0;   // Container calendar, câmpuri întâlniri
  static const double borderRadiusLarge = 32.0;    // Widget-uri (Upcoming, Calendar, User, Nav), Avatar
  static const double borderRadiusHuge = 40.0;     // (Nefolosit, dar disponibil)

  // Dimensiuni pentru icon-uri
  static const double iconSizeSmall = 20.0;     // Icon schimbare calendar
  static const double iconSizeMedium = 24.0;    // Icon-uri user/navigație

  // Spațieri
  static const double tinyGap = 4.0;
  static const double smallGap = 8.0;
  static const double mediumGap = 16.0;
  static const double largeGap = 24.0;
  static const double hugeGap = 32.0;
  
  // Alte dimensiuni
  static const double slotBorderThickness = 4.0;  // Grosimea border-ului slot-ului disponibil
  static const double iconBorderThickness = 2.0;  // Grosimea border-ului icon-urilor
  static const double navButtonHeight = 48.0;     // Înălțimea butoanelor de navigare

  // ======== CULORI GENERALE ========

  static Color get widgetBackground => currentThemeMode == AppThemeMode.light 
      ? const Color(0xFFD9D9D9) 
      : const Color(0xFF262626);
      
  static Color get popupBackground => currentThemeMode == AppThemeMode.light 
      ? const Color(0xFFD9D9D9) 
      : const Color(0xFF262626);

  // ======== CULORI TEMATICE ========
  
  // Culori pentru background gradient
  static Color get backgroundStart {
    if (currentThemeMode == AppThemeMode.light) {
      switch (currentThemeColor) {
        case AppThemeColor.red:
          return const Color(0xFFC2A4C2);
        case AppThemeColor.yellow:
          return const Color(0xFFC2A4A4);
        case AppThemeColor.green:
          return const Color(0xFFC2C2A4);
        case AppThemeColor.cyan:
          return const Color(0xFFA4C2A4);
        case AppThemeColor.blue:
          return const Color(0xFFA4C2C2);
        case AppThemeColor.pink:
          return const Color(0xFFA4A4C2);
      }
    } else {
      switch (currentThemeColor) {
        case AppThemeColor.red:
          return const Color(0xFF5C3D5C);
        case AppThemeColor.yellow:
          return const Color(0xFF5C3D3D);
        case AppThemeColor.green:
          return const Color(0xFF5C5C3D);
        case AppThemeColor.cyan:
          return const Color(0xFF3D5C3D);
        case AppThemeColor.blue:
          return const Color(0xFF3D5C5C);
        case AppThemeColor.pink:
          return const Color(0xFF3D3D5C);
      }
    }
  }

  static Color get backgroundEnd {
    if (currentThemeMode == AppThemeMode.light) {
      switch (currentThemeColor) {
        case AppThemeColor.red:
          return const Color(0xFFC2C2A4);
        case AppThemeColor.yellow:
          return const Color(0xFFA4C2A4);
        case AppThemeColor.green:
          return const Color(0xFFA4C2C2);
        case AppThemeColor.cyan:
          return const Color(0xFFA4A4C2);
        case AppThemeColor.blue:
          return const Color(0xFFC2A4C2);
        case AppThemeColor.pink:
          return const Color(0xFFC2A4A4);
      }
    } else {
      switch (currentThemeColor) {
        case AppThemeColor.red:
          return const Color(0xFF5C5C3D);
        case AppThemeColor.yellow:
          return const Color(0xFF3D5C3D);
        case AppThemeColor.green:
          return const Color(0xFF3D5C5C);
        case AppThemeColor.cyan:
          return const Color(0xFF3D3D5C);
        case AppThemeColor.blue:
          return const Color(0xFF5C3D5C);
        case AppThemeColor.pink:
          return const Color(0xFF5C3D3D);
      }
    }
  }

  // Culori pentru containere
  static Color get containerColor1 {
    if (currentThemeMode == AppThemeMode.light) {
      switch (currentThemeColor) {
        case AppThemeColor.red:
          return const Color(0xFFD4C4C4);
        case AppThemeColor.yellow:
          return const Color(0xFFD4D4C4);
        case AppThemeColor.green:
          return const Color(0xFFC4D4C4);
        case AppThemeColor.cyan:
          return const Color(0xFFC4D4D4);
        case AppThemeColor.blue:
          return const Color(0xFFC4C4D4);
        case AppThemeColor.pink:
          return const Color(0xFFD4C4D4);
      }
    } else {
      switch (currentThemeColor) {
        case AppThemeColor.red:
          return const Color(0xFF3B2B2B);
        case AppThemeColor.yellow:
          return const Color(0xFF3B3B2B);
        case AppThemeColor.green:
          return const Color(0xFF2B3B2B);
        case AppThemeColor.cyan:
          return const Color(0xFF2B3B3B);
        case AppThemeColor.blue:
          return const Color(0xFF2B2B3B);
        case AppThemeColor.pink:
          return const Color(0xFF3B2B3B);
      }
    }
  }

  static Color get containerColor2 {
    if (currentThemeMode == AppThemeMode.light) {
      switch (currentThemeColor) {
        case AppThemeColor.red:
          return const Color(0xFFD3ACAC);
        case AppThemeColor.yellow:
          return const Color(0xFFD3D3AC);
        case AppThemeColor.green:
          return const Color(0xFFACD2AC);
        case AppThemeColor.cyan:
          return const Color(0xFFACD3D3);
        case AppThemeColor.blue:
          return const Color(0xFFACACD3);
        case AppThemeColor.pink:
          return const Color(0xFFD3ACD3);
      }
    } else {
      switch (currentThemeColor) {
        case AppThemeColor.red:
          return const Color(0xFF532D2D);
        case AppThemeColor.yellow:
          return const Color(0xFF53532D);
        case AppThemeColor.green:
          return const Color(0xFF2D532D);
        case AppThemeColor.cyan:
          return const Color(0xFF2D5353);
        case AppThemeColor.blue:
          return const Color(0xFF2D2D53);
        case AppThemeColor.pink:
          return const Color(0xFF532D53);
      }
    }
  }

  // Culori pentru elemente
  static Color get elementColor1 {
    if (currentThemeMode == AppThemeMode.light) {
      switch (currentThemeColor) {
        case AppThemeColor.red:
          return const Color(0xFFA88A8A);
        case AppThemeColor.yellow:
          return const Color(0xFFA8A88A);
        case AppThemeColor.green:
          return const Color(0xFF8AA88A);
        case AppThemeColor.cyan:
          return const Color(0xFF8AA8A8);
        case AppThemeColor.blue:
          return const Color(0xFF8A8AA8);
        case AppThemeColor.pink:
          return const Color(0xFF9D7B9D);
      }
    } else {
      switch (currentThemeColor) {
        case AppThemeColor.red:
          return const Color(0xFF755757);
        case AppThemeColor.yellow:
          return const Color(0xFF757557);
        case AppThemeColor.green:
          return const Color(0xFF577557);
        case AppThemeColor.cyan:
          return const Color(0xFF577575);
        case AppThemeColor.blue:
          return const Color(0xFF575775);
        case AppThemeColor.pink:
          return const Color(0xFF755775);
      }
    }
  }

  static Color get elementColor2 {
    if (currentThemeMode == AppThemeMode.light) {
      switch (currentThemeColor) {
        case AppThemeColor.red:
          return const Color(0xFF996666);
        case AppThemeColor.yellow:
          return const Color(0xFF999966);
        case AppThemeColor.green:
          return const Color(0xFF669966);
        case AppThemeColor.cyan:
          return const Color(0xFF669999);
        case AppThemeColor.blue:
          return const Color(0xFF666699);
        case AppThemeColor.pink:
          return const Color(0xFF996699);
      }
    } else {
      // Pentru tema dark, vom folosi aceleași culori pentru elementColor2
      // deoarece sunt suficient de vizibile pe fundaluri închise
      switch (currentThemeColor) {
        case AppThemeColor.red:
          return const Color(0xFF996666);
        case AppThemeColor.yellow:
          return const Color(0xFF999966);
        case AppThemeColor.green:
          return const Color(0xFF669966);
        case AppThemeColor.cyan:
          return const Color(0xFF669999);
        case AppThemeColor.blue:
          return const Color(0xFF666699);
        case AppThemeColor.pink:
          return const Color(0xFF996699);
      }
    }
  }

  static Color get elementColor3 {
    if (currentThemeMode == AppThemeMode.light) {
      switch (currentThemeColor) {
        case AppThemeColor.red:
          return const Color(0xFF804D4D);
        case AppThemeColor.yellow:
          return const Color(0xFF80804D);
        case AppThemeColor.green:
          return const Color(0xFF4D804D);
        case AppThemeColor.cyan:
          return const Color(0xFF4D8080);
        case AppThemeColor.blue:
          return const Color(0xFF4D4D80);
        case AppThemeColor.pink:
          return const Color(0xFF8F568F);
      }
    } else {
      switch (currentThemeColor) {
        case AppThemeColor.red:
          return const Color(0xFFB28080);
        case AppThemeColor.yellow:
          return const Color(0xFFB2B280);
        case AppThemeColor.green:
          return const Color(0xFF80B280);
        case AppThemeColor.cyan:
          return const Color(0xFF80B2B2);
        case AppThemeColor.blue:
          return const Color(0xFF8080B2);
        case AppThemeColor.pink:
          return const Color(0xFFB280B2);
      }
    }
  }

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
    color: currentThemeMode == AppThemeMode.light ? elementColor2 : Colors.white70,
  );

  // ======== DECORATIUNI ========
  
  // Background gradient pentru ecran
  static Gradient get appBackground => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundStart, backgroundEnd],
    stops: const [0.0, 1.0],
  );

  // Decorațiune pentru widget-uri
  static BoxDecoration get widgetDecoration => BoxDecoration(
    color: widgetBackground,
    borderRadius: BorderRadius.circular(borderRadiusLarge),
    boxShadow: [widgetShadow],
  );

  // Decorațiune pentru popup-uri
  static BoxDecoration get popupDecoration => BoxDecoration(
    color: popupBackground,
    borderRadius: BorderRadius.circular(borderRadiusLarge),
  );

  // Decorațiune pentru container-ul principal (de nivel 1)
  static BoxDecoration get container1Decoration => BoxDecoration(
    color: containerColor1,
    borderRadius: BorderRadius.circular(borderRadiusMedium),
  );

  // Decorațiune pentru container-ul secundar (de nivel 2) 
  static BoxDecoration get container2Decoration => BoxDecoration(
    color: containerColor2,
    borderRadius: BorderRadius.circular(borderRadiusSmall),
  );
  
  // Decorațiune pentru slot-uri rezervate în calendar
  static BoxDecoration get reservedSlotDecoration => BoxDecoration(
    color: currentThemeColor == AppThemeColor.pink ? containerColor2 : 
           (currentThemeMode == AppThemeMode.light ? const Color(0xFFC6ACD3) : const Color(0xFF532D53)),
    borderRadius: BorderRadius.circular(borderRadiusSmall),
    boxShadow: [slotShadow],
  );

  // ======== METODE PENTRU SCHIMBAREA TEMEI ========
  
  /// Schimbă tema între Light și Dark
  static void toggleThemeMode() {
    currentThemeMode = currentThemeMode == AppThemeMode.light 
        ? AppThemeMode.dark 
        : AppThemeMode.light;
  }
  
  /// Setează tema specifică (Light sau Dark)
  static void setThemeMode(AppThemeMode mode) {
    currentThemeMode = mode;
  }
  
  /// Setează culoarea temei
  static void setThemeColor(AppThemeColor color) {
    currentThemeColor = color;
  }
} 