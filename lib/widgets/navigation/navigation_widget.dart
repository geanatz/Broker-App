import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

/// Tipurile de ecrane disponibile pentru navigare
enum NavigationScreen {
  calendar,
  form,
  settings
}

/// Widget pentru navigația principală a aplicației, care permite
/// utilizatorului să navigheze între diferitele ecrane.
class NavigationWidget extends StatelessWidget {
  /// Ecranul curent activ
  final NavigationScreen currentScreen;
  
  /// Callback pentru schimbarea ecranului
  final Function(NavigationScreen) onScreenChanged;

  const NavigationWidget({
    Key? key, 
    required this.currentScreen,
    required this.onScreenChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.defaultGap),
      decoration: AppTheme.widgetDecoration,
      child: Column(
        children: [
          _buildNavigationHeader(),
          const SizedBox(height: AppTheme.defaultGap),
          _buildNavigationButton(
            'Formular clienți',
            'assets/FormIcon.svg',
            NavigationScreen.form,
            isActive: currentScreen == NavigationScreen.form,
          ),
          const SizedBox(height: AppTheme.defaultGap),
          _buildNavigationButton(
            'Calendar',
            'assets/CalendarIcon.svg',
            NavigationScreen.calendar,
            isActive: currentScreen == NavigationScreen.calendar,
          ),
          const SizedBox(height: AppTheme.defaultGap),
          _buildNavigationButton(
            'Setări',
            'assets/SettingsIcon.svg',
            NavigationScreen.settings,
            isActive: currentScreen == NavigationScreen.settings,
          ),
        ],
      ),
    );
  }

  /// Construiește header-ul secțiunii de navigație
  Widget _buildNavigationHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.mediumGap, 
        0, 
        AppTheme.mediumGap, 
        AppTheme.defaultGap
      ),
      child: SizedBox(
        height: 24,
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Navigație',
                style: AppTheme.headerTitleStyle,
              ),
            ),
            SvgPicture.asset(
              'assets/DropdownIcon.svg',
              width: AppTheme.iconSizeMedium,
              height: AppTheme.iconSizeMedium,
              colorFilter: ColorFilter.mode(
                AppTheme.fontLightPurple,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construiește un buton de navigație
  Widget _buildNavigationButton(
    String text, 
    String iconPath, 
    NavigationScreen screen, 
    {bool isActive = false}
  ) {
    final Color textColor = isActive 
        ? AppTheme.fontDarkPurple 
        : AppTheme.fontMediumPurple;
        
    final BoxDecoration decoration = isActive
        ? AppTheme.activeNavButtonDecoration
        : AppTheme.inactiveNavButtonDecoration;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isActive ? null : () => onScreenChanged(screen),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.mediumGap, 
            vertical: 12
          ),
          decoration: decoration,
          child: Row(
            children: [
              SvgPicture.asset(
                iconPath,
                width: AppTheme.iconSizeMedium,
                height: AppTheme.iconSizeMedium,
                colorFilter: ColorFilter.mode(
                  textColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: AppTheme.mediumGap),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.outfit(
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 