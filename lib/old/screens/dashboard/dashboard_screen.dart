import 'package:flutter/material.dart';
import 'package:broker_app/frontend/common/appTheme.dart';
// import '../../widgets/navigation/sidebar_widget.dart'; // Removed old import
// import '../../widgets/navigation/navigation_widget.dart'; // Removed old import
// import '../../sidebar/user_widget.dart'; // Remove UserWidget import
// import '../../sidebar/navigation_widget.dart'; // Remove NavigationWidget import
// import 'package:broker_app/old/sidebar/sidebar_widget.dart'; // Add SidebarWidget import
import 'package:broker_app/old/widgets/common/panel_container.dart';
import 'package:broker_app/old/sidebar/sidebar_service.dart';
import 'package:broker_app/old/sidebar/sidebar_widget.dart';

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
        decoration: BoxDecoration(
          gradient: AppTheme.appBackground,
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
    // Note: height for PanelContainer might need adjustment
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PanelContainer(
            width: double.infinity,
            // height: 300, // Consider removing fixed height or making it flexible
            child: _buildDashboardContent(),
          ),
          const SizedBox(height: AppTheme.largeGap),
          SizedBox(
            width: 224,
            child: SidebarWidgetAdapter(
              consultantName: widget.consultantName,
              teamName: widget.teamName,
              currentScreen: NavigationScreen.dashboard,
              onScreenChanged: widget.onScreenChanged,
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
          // width: 1100, // This might be too specific, Expanded handles width better
          height: contentHeight,
          isExpanded: true,
          child: _buildDashboardContent(),
        ),
        const SizedBox(width: AppTheme.largeGap),
        SizedBox(
           width: 224,
           height: contentHeight,
           child: SidebarWidgetAdapter(
             consultantName: widget.consultantName,
             teamName: widget.teamName,
             currentScreen: NavigationScreen.dashboard,
             onScreenChanged: widget.onScreenChanged,
           ),
        ),
      ],
    );
  }

  /// Construiește conținutul placeholderului pentru dashboard
  Widget _buildDashboardContent() {
    // Assuming AppTheme.headerTitleStyle, primaryTitleStyle, secondaryTitleStyle exist
    // If not, define inline styles using AppTheme constants
    final TextStyle headerStyle = TextStyle(
      fontSize: AppTheme.fontSizeLarge, 
      fontWeight: FontWeight.bold, 
      color: AppTheme.elementColor3
    );
    final TextStyle primaryStyle = TextStyle(
      fontSize: AppTheme.fontSizeLarge, 
      color: AppTheme.elementColor2
    );
     final TextStyle secondaryStyle = TextStyle(
      fontSize: AppTheme.fontSizeMedium, 
      color: AppTheme.elementColor1
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.mediumGap,
            AppTheme.mediumGap, // Add top padding
            AppTheme.mediumGap,
            AppTheme.smallGap
          ),
          child: Text(
            'Dashboard',
            style: headerStyle, // Use defined style
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
                  color: AppTheme.elementColor2,
                ),
                const SizedBox(height: AppTheme.mediumGap),
                Text(
                  'Dashboard în construcție',
                  style: primaryStyle, // Use defined style
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.smallGap),
                Text(
                  'Această secțiune va fi disponibilă în curând',
                  style: secondaryStyle, // Use defined style
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