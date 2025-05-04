import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'navigation_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  /// Înălțimea sidebar-ului (poate fi null pentru flexibilitate)
  final double? height;

  const SidebarWidget({
    Key? key,
    required this.currentScreen,
    required this.onScreenChanged,
    required this.consultantName,
    required this.teamName,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 224,
      height: height,
      child: Column(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: UserWidget(consultantName: consultantName, teamName: teamName),
          ),
          const SizedBox(height: AppTheme.mediumGap),
          Expanded(
            child: NavigationWidget(
              currentScreen: currentScreen,
              onScreenChanged: onScreenChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class UserWidget extends StatelessWidget {
  final String consultantName;
  final String teamName;

  const UserWidget({
    Key? key,
    required this.consultantName,
    required this.teamName,
  }) : super(key: key);

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    } catch (e) {
      print("Eroare la deconectare: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eroare la deconectare: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Profil'),
            content: Text('Utilizator: $consultantName\nEchipa: $teamName'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Inchide'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _signOut(context);
                },
                child: const Text('Deconectare', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.defaultGap),
        decoration: BoxDecoration(
          color: AppTheme.widgetBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: [AppTheme.widgetShadow],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: AppTheme.avatarDecoration,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/UserIcon.svg',
                      width: AppTheme.iconSizeMedium,
                      height: AppTheme.iconSizeMedium,
                      colorFilter: ColorFilter.mode(
                        AppTheme.fontMediumPurple,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.defaultGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        consultantName,
                        style: AppTheme.primaryTitleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        teamName,
                        style: AppTheme.secondaryTitleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 