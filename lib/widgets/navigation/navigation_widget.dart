import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';
import '../../screens/form/form_screen.dart' show SecondaryPanelType; // Import enum

/// Tipurile de ecrane disponibile pentru navigare
enum NavigationScreen {
  dashboard,
  calendar,
  form,
  settings
}

/// Callback type for secondary panel changes
typedef SecondaryPanelCallback = void Function(SecondaryPanelType panelType);

/// Widget pentru navigația principală a aplicației, care permite
/// utilizatorului să navigheze între diferitele ecrane.
class NavigationWidget extends StatelessWidget {
  /// Ecranul curent activ
  final NavigationScreen currentScreen;
  
  /// Callback pentru schimbarea ecranului
  final Function(NavigationScreen) onScreenChanged;

  /// Tipul panoului secundar activ (doar pentru FormScreen)
  final SecondaryPanelType? activeSecondaryPanel; 

  /// Callback pentru schimbarea panoului secundar (doar pentru FormScreen)
  final SecondaryPanelCallback? onSecondaryPanelChange;

  const NavigationWidget({
    Key? key, 
    required this.currentScreen,
    required this.onScreenChanged,
    this.activeSecondaryPanel, // Optional parameter
    this.onSecondaryPanelChange, // Optional parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if secondary actions should be shown
    final bool showSecondaryActions = currentScreen == NavigationScreen.form;

    return Container(
      // This container now represents the 'NavigationBar' from Figma
      padding: const EdgeInsets.all(AppTheme.defaultGap),
      decoration: BoxDecoration(
        color: AppTheme.widgetBackground.withOpacity(0.5), // Matches Figma background
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge), // Matches Figma radius (32px equiv)
        boxShadow: [AppTheme.widgetShadow], // Matches Figma shadow
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Adjust based on whether it needs to fill space
        crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
        children: [
          // Main Panel (matches Figma 'MainPanel')
          _buildPanelHeader('Navigatie'), // Renamed back
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
            isLast: !showSecondaryActions, // No bottom padding if it's the absolute last button
          ),

          // Conditionally add Secondary Panel (matches Figma 'SecondaryPanel')
          if (showSecondaryActions) ...[
            const SizedBox(height: AppTheme.mediumGap), // Gap between panels
             _buildPanelHeader('Panouri'), // Renamed back
            const SizedBox(height: AppTheme.defaultGap),
             _buildNavButton(
               context,
               iconPath: 'assets/CallIcon.svg',
               title: 'Apeluri',
               screen: NavigationScreen.form, // Stays on form screen
               isSecondary: true,
               secondaryPanelType: SecondaryPanelType.calls, // Associate type
             ),
             _buildNavButton(
               context,
               iconPath: 'assets/ReturnIcon.svg',
               title: 'Reveniri',
               screen: NavigationScreen.form,
               isSecondary: true,
               secondaryPanelType: SecondaryPanelType.returns, // Associate type
             ),
             _buildNavButton(
               context,
               iconPath: 'assets/CalculatorIcon.svg',
               title: 'Calculator',
               screen: NavigationScreen.form,
               isSecondary: true,
               secondaryPanelType: SecondaryPanelType.calculator, // Associate type
             ),
             _buildNavButton(
               context,
               iconPath: 'assets/RecommendIcon.svg',
               title: 'Recomandare',
               screen: NavigationScreen.form,
               isSecondary: true,
               secondaryPanelType: SecondaryPanelType.recommendation, // Associate type
               isLast: true,
             ),
          ]
        ],
      ),
    );
  }

  // Helper for panel headers (matches Figma 'WidgetHeader')
  Widget _buildPanelHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.largeGap), // Matches Figma padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTheme.headerTitleStyle, // Style from Figma (color: #927B9D)
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Optional: Add Dropdown Icon here if needed later
          // SvgPicture.asset(
          //   'assets/DropdownIcon.svg',
          //   width: 24, height: 24,
          //   colorFilter: ColorFilter.mode(AppTheme.fontMutedPurple, BlendMode.srcIn),
          // ),
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
      bool isSecondary = false,
      SecondaryPanelType? secondaryPanelType, // Added parameter
      bool isLast = false,
    }
  ) {
    // Determine active state for PRIMARY navigation
    final bool isPrimaryActive = !isSecondary && currentScreen == screen;
    // Determine active state for SECONDARY navigation
    final bool isSecondaryActive = isSecondary && activeSecondaryPanel == secondaryPanelType;

    // Determine overall active state for styling
    final bool isActive = isPrimaryActive || isSecondaryActive;

    // Define colors based on active state
    final Color activeColor = AppTheme.fontDarkPurple; // #7C568F
    final Color inactiveColor = AppTheme.fontMediumPurple; // #886699
    final Color iconColor = isActive ? activeColor : inactiveColor;
    final Color textColor = isActive ? activeColor : inactiveColor;

    // Define background based on active state
    final Color activeBg = AppTheme.backgroundDarkPurple; // #C6ACD3
    final Color inactiveBg = AppTheme.backgroundLightPurple; // #CFC4D4

    // Apply the correct background color
    final BoxDecoration decoration = BoxDecoration(
      color: isActive ? activeBg : inactiveBg,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // 16px from Figma
      // Apply shadow ONLY if active (mimics Figma where only active has shadow)
      boxShadow: isActive ? [AppTheme.buttonShadow] : [],
    );

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppTheme.defaultGap),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            if (!isSecondary) {
              onScreenChanged(screen);
            } else if (secondaryPanelType != null && onSecondaryPanelChange != null) {
              // Call the callback for secondary buttons
              onSecondaryPanelChange!(secondaryPanelType);
            } else {
              // Fallback or error handling if needed
              print('Secondary Action: $title clicked but no type/callback');
            }
          },
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