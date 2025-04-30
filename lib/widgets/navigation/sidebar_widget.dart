import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'user_widget.dart';
import 'navigation_widget.dart';

/// Widget care conține componentele de sidebar: informații despre utilizator
/// și navigație. Acest widget este folosit în toate ecranele principale.
class SidebarWidget extends StatelessWidget {
  /// Ecranul curent activ
  final NavigationScreen currentScreen;

  /// Callback pentru schimbarea ecranului
  final Function(NavigationScreen) onScreenChanged;

  /// Numele consultantului
  final String consultantName;

  /// Numele echipei
  final String teamName;

  /// Valoarea progresului (0.0 - 1.0)
  final double progress;

  /// Numărul de apeluri completate
  final int callCount;

  /// Înălțimea sidebar-ului (poate fi null pentru flexibilitate)
  final double? height;

  const SidebarWidget({
    Key? key,
    required this.currentScreen,
    required this.onScreenChanged,
    required this.consultantName,
    required this.teamName,
    this.progress = 0.0,
    this.callCount = 0,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 224,
      height: height,
      child: Column(
        children: [
          UserWidget(
            name: consultantName,
            team: teamName,
            progress: progress,
            callCount: callCount,
            onScreenChanged: onScreenChanged,
          ),
          
          const SizedBox(height: AppTheme.mediumGap),
          
          height != null
              ? Expanded(
                  child: NavigationWidget(
                    currentScreen: currentScreen,
                    onScreenChanged: onScreenChanged,
                  ),
                )
              : NavigationWidget(
                  currentScreen: currentScreen,
                  onScreenChanged: onScreenChanged,
                ),
        ],
      ),
    );
  }
} 