import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';

/// Widget care afișează informații despre utilizatorul curent
/// inclusiv progresul său.
class UserWidget extends StatelessWidget {
  /// Numele consultantului
  final String name;
  
  /// Numele echipei
  final String team;
  
  /// Valoarea progresului (0.0 - 1.0)
  final double progress;
  
  /// Numărul de apeluri completate
  final int callCount;

  const UserWidget({
    Key? key,
    required this.name,
    required this.team,
    required this.progress,
    required this.callCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.defaultGap),
      decoration: AppTheme.widgetDecoration,
      child: Column(
        children: [
          _buildUserInfoRow(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.mediumGap, 
              0, 
              AppTheme.mediumGap, 
              0
            ),
            child: _buildProgressRow(),
          ),
        ],
      ),
    );
  }

  /// Construiește rândul cu avatar și informații despre utilizator
  Widget _buildUserInfoRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.defaultGap),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(AppTheme.mediumGap),
            decoration: AppTheme.avatarDecoration,
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
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  team,
                  style: AppTheme.secondaryTitleStyle.copyWith(
                    color: AppTheme.fontLightPurple,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construiește bara de progres și numărul de apeluri
  Widget _buildProgressRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 16,
            decoration: BoxDecoration(
              color: AppTheme.backgroundLightPurple,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusTiny),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
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
        ),
        
        const SizedBox(width: AppTheme.defaultGap),
        
        SizedBox(
          width: 20,
          child: Text(
            '$callCount',
            style: AppTheme.tinyTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
} 