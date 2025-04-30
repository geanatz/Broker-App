import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Clasa AppTheme conține toate culorile, dimensiunile, stilurile și variabilele de design
/// folosite în întreaga aplicație, pentru a asigura consistența designului.
class AppTheme {
  AppTheme._(); // Constructor privat pentru a preveni instanțierea

  // ======== CULORI ========
  
  // Background-uri
  static const Color appBackgroundStart = Color(0xFFA4B8C2);
  static const Color appBackgroundEnd = Color(0xFFC2A4A4);
  static const Color widgetBackground = Color(0xFFFFFFFF); // Cu opacitate 0.5 când se aplică
  static const Color popupBackground = Color(0xFFFFFFFF); // Cu opacitate 0.75 când se aplică
  
  // Background-uri pentru panel-uri
  static const Color backgroundLightBlue = Color(0xFFC4CFD4);
  static const Color backgroundLightPurple = Color(0xFFCFC4D4);
  static const Color backgroundLightRed = Color(0xFFD4C4C4);
  static const Color backgroundDarkBlue = Color(0xFFACC6D3);
  static const Color backgroundDarkPurple = Color(0xFFC5B0CF);
  static const Color backgroundDarkRed = Color(0xFFD3ACAC);
  static const Color slotReservedBackground = Color(0xFFC6ACD3);

  // Culori pentru text
  static const Color fontLightBlue = Color(0xFF8A9EA8);
  static const Color fontLightPurple = Color(0xFF9E8AA8);
  static const Color fontLightRed = Color(0xFFA88A8A);
  static const Color fontMediumBlue = Color(0xFF668899);
  static const Color fontMediumPurple = Color(0xFF886699);
  static const Color fontMediumRed = Color(0xFF996666);
  static const Color fontDarkBlue = Color(0xFF4D6F80);
  static const Color fontDarkPurple = Color(0xFF6F4D80);
  static const Color fontDarkRed = Color(0xFF804D4D);

  // ======== DIMENSIUNI ========
  
  // Dimensiuni pentru text
  static const double fontSizeTiny = 13.0;    // Număr de apeluri
  static const double fontSizeSmall = 14.0;   // Ora/Data întâlnirii
  static const double fontSizeMedium = 16.0;  // Descrierea întâlnirii, Etichetele din calendar, Titlurile din navigație, Echipa
  static const double fontSizeLarge = 18.0;   // Titlurile widget-urilor, Titlul întâlnirii, Consultant, Numele utilizatorului
  static const double fontSizeHuge = 20.0;    // Pentru titluri mai mari (dacă e nevoie)

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
  static const double defaultGap = 8.0;
  static const double mediumGap = 16.0;
  static const double largeGap = 24.0;

  // Alte dimensiuni
  static const double slotColumnWidth = 240.0;    // Lățimea unei coloane de zile
  static const double hourLabelWidth = 48.0;      // Lățimea coloanei de ore
  static const double slotBorderThickness = 4.0;  // Grosimea border-ului slot-ului disponibil
  static const double iconBorderThickness = 2.0;  // Grosimea border-ului icon-urilor

  // ======== UMBRELE ========
  static final BoxShadow widgetShadow = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 15,
  );
  
  static final BoxShadow buttonShadow = BoxShadow(
    color: Colors.black.withOpacity(0.2),
    blurRadius: 4,
    offset: const Offset(0, 2),
  );
  
  static final BoxShadow slotShadow = BoxShadow(
    color: Colors.black.withOpacity(0.25),
    blurRadius: 4,
    offset: const Offset(0, 2),
  );

  // ======== STILURI TEXT ========
  static final TextStyle headerTitleStyle = GoogleFonts.outfit(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.w600,
    color: fontLightPurple,
  );

  static final TextStyle subHeaderStyle = GoogleFonts.outfit(
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.w500,
    color: fontLightPurple,
  );

  static final TextStyle primaryTitleStyle = GoogleFonts.outfit(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.w600,
    color: fontDarkPurple,
  );

  static final TextStyle secondaryTitleStyle = GoogleFonts.outfit(
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.w500,
    color: fontMediumPurple,
  );

  static final TextStyle smallTextStyle = GoogleFonts.outfit(
    fontSize: fontSizeSmall,
    fontWeight: FontWeight.w500,
    color: fontMediumPurple,
  );

  static final TextStyle tinyTextStyle = GoogleFonts.outfit(
    fontSize: fontSizeTiny,
    fontWeight: FontWeight.w600,
    color: fontMediumPurple,
  );

  // ======== DECORATIUNI ========
  
  // Background gradient pentru ecran
  static const Gradient appBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [appBackgroundStart, appBackgroundEnd],
    stops: [0.0, 1.0],
  );

  // Decorațiune pentru widget-uri
  static BoxDecoration widgetDecoration = BoxDecoration(
    color: widgetBackground.withOpacity(0.5),
    borderRadius: BorderRadius.circular(borderRadiusLarge),
    boxShadow: [widgetShadow],
  );

  // Decorațiune pentru popup-uri
  static BoxDecoration popupDecoration = BoxDecoration(
    color: popupBackground.withOpacity(0.75),
    borderRadius: BorderRadius.circular(borderRadiusLarge),
  );

  // Decorațiune pentru container calendar
  static final BoxDecoration calendarContainerDecoration = BoxDecoration(
    color: backgroundLightPurple,
    borderRadius: BorderRadius.circular(borderRadiusMedium),
  );

  // Decorațiune pentru avatar utilizator
  static final BoxDecoration avatarDecoration = BoxDecoration(
    color: backgroundLightPurple,
    borderRadius: BorderRadius.circular(borderRadiusLarge),
  );

  // Decorațiune pentru slot rezervat
  static final BoxDecoration reservedSlotDecoration = BoxDecoration(
    color: slotReservedBackground,
    borderRadius: BorderRadius.circular(borderRadiusSmall),
  );

  // Decorațiune pentru slot disponibil
  static final BoxDecoration availableSlotDecoration = BoxDecoration(
    border: Border.all(
      color: backgroundLightPurple,
      width: slotBorderThickness,
    ),
    borderRadius: BorderRadius.circular(borderRadiusSmall),
  );

  // Decorațiune pentru buton navigație activ
  static final BoxDecoration activeNavButtonDecoration = BoxDecoration(
    color: backgroundDarkPurple,
    borderRadius: BorderRadius.circular(borderRadiusSmall),
    boxShadow: [buttonShadow],
  );

  // Decorațiune pentru buton navigație inactiv
  static final BoxDecoration inactiveNavButtonDecoration = BoxDecoration(
    color: backgroundLightPurple,
    borderRadius: BorderRadius.circular(borderRadiusSmall),
  );
} 