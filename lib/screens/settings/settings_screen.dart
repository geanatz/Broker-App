import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
// import '../../widgets/navigation/sidebar_widget.dart'; // Removed old import
// import '../../widgets/navigation/navigation_widget.dart'; // Removed old import
import '../../sidebar/navigation_config.dart'; // Added config import
import '../../sidebar/user_widget.dart';      // Added user widget import
import '../../sidebar/navigation_widget.dart'; // Added navigation widget import
import '../../sidebar/user_config.dart'; // Added user config import
import '../../widgets/common/panel_container.dart';

/// Ecranul pentru setările aplicației
class SettingsScreen extends StatelessWidget {
  /// Numele consultantului
  final String consultantName;
  
  /// Numele echipei
  final String teamName;
  
  /// Callback pentru schimbarea ecranului
  final Function(NavigationScreen) onScreenChanged;

  const SettingsScreen({
    Key? key,
    required this.consultantName,
    required this.teamName,
    required this.onScreenChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 1200;
    final mainContentHeight = screenSize.height - 48;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.appBackgroundGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.largeGap),
          child: isSmallScreen
            ? _buildSmallScreenLayout()
            : _buildLargeScreenLayout(mainContentHeight),
        ),
      ),
    );
  }

  /// Construiește layout-ul pentru ecrane mici (< 1200px)
  Widget _buildSmallScreenLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PanelContainer(
            width: double.infinity,
            child: _buildSettingsContent(),
          ),
          const SizedBox(height: AppTheme.largeGap),
          // Replace SidebarWidget with Column[UserWidget, SizedBox, NavigationWidget]
           Container(
            width: 224, // Maintain sidebar width
            child: Column(
              children: [
                UserWidget(
                  consultantName: consultantName,
                  teamName: teamName,
                  progress: 0.0, // Add placeholder progress
                  callCount: 0,  // Add placeholder count
                ),
                const SizedBox(height: AppTheme.mediumGap),
                NavigationWidget(
                  currentScreen: NavigationScreen.settings,
                  onScreenChanged: onScreenChanged,
                  // No secondary panels on settings
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construiește layout-ul pentru ecrane mari (>= 1200px)
  Widget _buildLargeScreenLayout(double contentHeight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PanelContainer(
          // width: 1376, // Let Expanded handle width
          height: contentHeight,
          isExpanded: true,
          child: _buildSettingsContent(),
        ),
        const SizedBox(width: AppTheme.largeGap),
         // Replace SidebarWidget with Column[UserWidget, SizedBox, Expanded(NavigationWidget)]
        SizedBox(
           width: 224, // Fixed width for the sidebar area
           height: contentHeight, // Use the calculated height
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.stretch,
             children: [
                UserWidget(
                  consultantName: consultantName,
                  teamName: teamName,
                  progress: 0.0, // Add placeholder progress
                  callCount: 0,  // Add placeholder count
                ),
                const SizedBox(height: AppTheme.mediumGap),
                Expanded(
                  child: NavigationWidget(
                    currentScreen: NavigationScreen.settings,
                    onScreenChanged: onScreenChanged,
                     // No secondary panels on settings
                  ),
                ),
             ],
           ),
        ),
      ],
    );
  }

  /// Construiește conținutul setărilor
  Widget _buildSettingsContent() {
    // Assuming AppTheme.headerTitleStyle, secondaryTitleStyle exist
    // If not, define inline styles using AppTheme constants
    final TextStyle headerStyle = const TextStyle(
      fontSize: AppTheme.fontSizeLarge, // Use a relevant size
      fontWeight: FontWeight.bold,
      color: AppTheme.fontDarkPurple
    );
    final TextStyle secondaryStyle = const TextStyle(
      fontSize: AppTheme.fontSizeMedium,
      color: AppTheme.fontMediumPurple
    );

    // Placeholdere pentru momentul în care se vor implementa setările
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.settings_outlined,
            size: 64,
            color: AppTheme.fontMediumPurple,
          ),
          const SizedBox(height: AppTheme.mediumGap),
          Text(
            'Setări aplicație',
            style: headerStyle.copyWith(fontSize: 24), // Adjust size if needed
          ),
          const SizedBox(height: AppTheme.smallGap),
          Text(
            'Setările aplicației vor fi implementate aici.',
            style: secondaryStyle, // Use defined style
          ),
        ],
      ),
    );
  }
} 