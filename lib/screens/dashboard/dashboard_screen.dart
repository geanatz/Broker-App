import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/navigation/sidebar_widget.dart';
import '../../widgets/navigation/navigation_widget.dart';
import '../../widgets/common/panel_container.dart';

/// Ecranul principal de dashboard al aplicației
class DashboardScreen extends StatefulWidget {
  /// Numele consultantului
  final String consultantName;
  
  /// Numele echipei
  final String teamName;
  
  /// Callback pentru schimbarea ecranului
  final Function(NavigationScreen) onScreenChanged;

  const DashboardScreen({
    Key? key,
    required this.consultantName,
    required this.teamName,
    required this.onScreenChanged,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
            ? _buildSmallScreenLayout(mainContentHeight)
            : _buildLargeScreenLayout(mainContentHeight),
        ),
      ),
    );
  }

  /// Construiește layout-ul pentru ecrane mici (< 1200px)
  Widget _buildSmallScreenLayout(double contentHeight) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PanelContainer(
            width: double.infinity,
            height: 300,
            child: _buildDashboardContent(),
          ),
          const SizedBox(height: AppTheme.largeGap),
          SidebarWidget(
            currentScreen: NavigationScreen.dashboard,
            onScreenChanged: widget.onScreenChanged,
            consultantName: widget.consultantName,
            teamName: widget.teamName,
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
          width: 1100,
          height: contentHeight,
          isExpanded: true,
          child: _buildDashboardContent(),
        ),
        const SizedBox(width: AppTheme.largeGap),
        SidebarWidget(
          currentScreen: NavigationScreen.dashboard,
          onScreenChanged: widget.onScreenChanged,
          consultantName: widget.consultantName,
          teamName: widget.teamName,
          height: contentHeight,
        ),
      ],
    );
  }

  /// Construiește conținutul placeholderului pentru dashboard
  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.mediumGap, 
            0, 
            AppTheme.mediumGap, 
            AppTheme.defaultGap
          ),
          child: Text(
            'Dashboard',
            style: AppTheme.headerTitleStyle,
          ),
        ),
        
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.construction,
                  size: 64,
                  color: AppTheme.fontMediumPurple,
                ),
                const SizedBox(height: AppTheme.mediumGap),
                Text(
                  'Dashboard în construcție',
                  style: AppTheme.primaryTitleStyle.copyWith(
                    color: AppTheme.fontMediumPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.defaultGap),
                Text(
                  'Această secțiune va fi disponibilă în curând',
                  style: AppTheme.secondaryTitleStyle.copyWith(
                    color: AppTheme.fontLightPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 