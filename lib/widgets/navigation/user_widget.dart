import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';
import 'navigation_widget.dart';

/// Widget care afișează informații despre utilizatorul curent
/// inclusiv progresul său. Acționează și ca buton de navigație către Dashboard.
class UserWidget extends StatelessWidget {
  /// Numele consultantului
  final String name;
  
  /// Numele echipei
  final String team;
  
  /// Valoarea progresului (0.0 - 1.0)
  final double progress;
  
  /// Numărul de apeluri completate
  final int callCount;
  
  /// Callback pentru navigare către dashboard
  final Function(NavigationScreen)? onScreenChanged;

  const UserWidget({
    Key? key,
    required this.name,
    required this.team,
    required this.progress,
    required this.callCount,
    this.onScreenChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onScreenChanged != null) {
          onScreenChanged!(NavigationScreen.dashboard);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.defaultGap),
        decoration: AppTheme.widgetDecoration,
        child: Column(
          children: [
            _buildUserInfo(),
            _buildProgressBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: AppTheme.avatarDecoration,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.mediumGap),
            child: SvgPicture.asset(
              'assets/UserIcon.svg',
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
            children: [
              Text(
                name,
                style: AppTheme.primaryTitleStyle.copyWith(
                  color: AppTheme.fontMediumPurple,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                team,
                style: AppTheme.subHeaderStyle.copyWith(
                  color: AppTheme.fontLightPurple,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.mediumGap, 
        AppTheme.defaultGap, 
        AppTheme.mediumGap, 
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: AppTheme.backgroundLightPurple,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusTiny),
              ),
              child: FractionallySizedBox(
                widthFactor: progress,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDarkPurple,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.borderRadiusTiny),
                      bottomLeft: Radius.circular(AppTheme.borderRadiusTiny),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: AppTheme.defaultGap),
          
          Text(
            '$callCount',
            style: AppTheme.tinyTextStyle,
          ),
        ],
      ),
    );
  }
} 