import 'package:flutter/material.dart';
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/old/widgets/common/panel_container.dart';

/// Area pentru dashboard care va fi afișată în cadrul ecranului principal.
/// Această area înlocuiește vechiul DashboardScreen, păstrând funcționalitatea
/// dar adaptând-o la noua structură a aplicației.
class DashboardArea extends StatelessWidget {
  const DashboardArea({super.key});

  @override
  Widget build(BuildContext context) {
    return PanelContainer(
      isExpanded: false,
      child: _buildDashboardContent(),
    );
  }

  /// Construiește conținutul placeholderului pentru dashboard
  Widget _buildDashboardContent() {
    // Stiluri definite pentru acest widget
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
            AppTheme.mediumGap,
            AppTheme.mediumGap,
            AppTheme.smallGap
          ),
          child: Text(
            'Dashboard',
            style: headerStyle,
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
                  style: primaryStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.smallGap),
                Text(
                  'Această secțiune va fi disponibilă în curând',
                  style: secondaryStyle,
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
