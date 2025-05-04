import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';

/// Tipurile de ecrane disponibile pentru navigare
enum NavigationScreen {
  dashboard,
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
      decoration: BoxDecoration(
        color: AppTheme.widgetBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: [AppTheme.widgetShadow],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To fit content or expand
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.largeGap),
            child: Text(
              'Navigatie',
              style: AppTheme.headerTitleStyle,
            ),
          ),
          const SizedBox(height: AppTheme.defaultGap),
          _buildNavButton(
            context,
            iconPath: 'assets/DashboardIcon.svg',
            title: 'Dashboard',
            screen: NavigationScreen.dashboard,
          ),
          _buildNavButton(
            context,
            iconPath: 'assets/FormIcon.svg',
            title: 'Formular',
            screen: NavigationScreen.form,
          ),
          _buildNavButton(
            context,
            iconPath: 'assets/CalendarIcon.svg',
            title: 'Calendar',
            screen: NavigationScreen.calendar,
          ),
          _buildNavButton(
            context,
            iconPath: 'assets/SettingsIcon.svg',
            title: 'Setari',
            screen: NavigationScreen.settings,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    {
      required String iconPath,
      required String title,
      required NavigationScreen screen,
    }
  ) {
    final bool isActive = currentScreen == screen;
    final Color iconColor = isActive ? AppTheme.fontDarkPurple : AppTheme.fontMediumPurple;
    final Color textColor = isActive ? AppTheme.fontDarkPurple : AppTheme.fontMediumPurple;
    final BoxDecoration decoration = isActive 
      ? AppTheme.activeNavButtonDecoration 
      : AppTheme.inactiveNavButtonDecoration;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.defaultGap),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onScreenChanged(screen),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.mediumGap,
              vertical: 12, // Approximate height 48px
            ),
            decoration: decoration,
            child: Row(
              children: [
                SvgPicture.asset(
                  iconPath,
                  width: AppTheme.iconSizeMedium,
                  height: AppTheme.iconSizeMedium,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
                const SizedBox(width: AppTheme.mediumGap),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.secondaryTitleStyle.copyWith(color: textColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 