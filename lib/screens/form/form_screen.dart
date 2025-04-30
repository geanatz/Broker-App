import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/navigation/sidebar_widget.dart';
import '../../widgets/navigation/navigation_widget.dart';
import '../../widgets/common/panel_container.dart';

/// Ecranul pentru formularul de clienți
class FormScreen extends StatelessWidget {
  /// Numele consultantului
  final String consultantName;
  
  /// Numele echipei
  final String teamName;
  
  /// Callback pentru schimbarea ecranului
  final Function(NavigationScreen) onScreenChanged;

  const FormScreen({
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
            child: _buildFormContent(),
          ),
          const SizedBox(height: AppTheme.largeGap),
          SidebarWidget(
            currentScreen: NavigationScreen.form,
            onScreenChanged: onScreenChanged,
            consultantName: consultantName,
            teamName: teamName,
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
          width: 1376, // Lățimea panoului principal
          height: contentHeight,
          isExpanded: true,
          child: _buildFormContent(),
        ),
        const SizedBox(width: AppTheme.largeGap),
        SidebarWidget(
          currentScreen: NavigationScreen.form,
          onScreenChanged: onScreenChanged,
          consultantName: consultantName,
          teamName: teamName,
          height: contentHeight,
        ),
      ],
    );
  }

  /// Construiește conținutul formularului
  Widget _buildFormContent() {
    // Placeholdere pentru momentul în care se va implementa formularul
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.description_outlined,
            size: 64,
            color: AppTheme.fontMediumPurple,
          ),
          const SizedBox(height: AppTheme.mediumGap),
          Text(
            'Formular clienți',
            style: AppTheme.headerTitleStyle.copyWith(
              fontSize: 24,
            ),
          ),
          const SizedBox(height: AppTheme.defaultGap),
          Text(
            'Formularul pentru clienți va fi implementat aici.',
            style: AppTheme.secondaryTitleStyle,
          ),
        ],
      ),
    );
  }
} 