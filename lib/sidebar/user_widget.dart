import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import 'user_config.dart';
import 'dart:async';

/// Displays user information (avatar, name, team), provides access to profile,
/// and shows rotating statistics with progress bar and call count.
class UserWidget extends StatefulWidget {
  final String consultantName;
  final String teamName;
  final double progress; 
  final int callCount;   

  const UserWidget({
    Key? key,
    required this.consultantName,
    required this.teamName,
    required this.progress,
    required this.callCount,
  }) : super(key: key);

  @override
  State<UserWidget> createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  late Timer _rotationTimer;
  int _currentStatIndex = 0;
  late List<UserStatConfig> _stats;

  @override
  void initState() {
    super.initState();
    // Initialize with sample stats or fetch from a service
    _stats = getSampleUserStats();
    
    // Set up timer to rotate stats every 8 seconds
    _rotationTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (mounted) {
        setState(() {
          _currentStatIndex = (_currentStatIndex + 1) % _stats.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _rotationTimer.cancel();
    super.dispose();
  }

  // Handles the sign-out process
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    } catch (e) {
      print("Error signing out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Shows the profile dialog
  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.popupBackground,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium)),
        title: Text('Profil', style: AppTheme.primaryTitleStyle.copyWith(color: AppTheme.fontDarkPurple)),
        content: Text(
          'Utilizator: ${widget.consultantName}\nEchipa: ${widget.teamName}',
          style: AppTheme.secondaryTitleStyle.copyWith(color: AppTheme.fontMediumPurple),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Inchide', style: TextStyle(color: AppTheme.fontDarkPurple)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _signOut(context);
            },
            child: const Text('Deconectare', style: TextStyle(color: AppTheme.fontDarkRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showProfileDialog(context),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.smallGap), // Padding 8px
          decoration: AppTheme.widgetDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUserInfoRow(),
              const SizedBox(height: AppTheme.smallGap),
              _buildStatsSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the top row with avatar, name, and team
  Widget _buildUserInfoRow() {
    return Row(
      children: [
        // Avatar
        Container(
          width: 56,
          height: 56,
          decoration: AppTheme.avatarDecoration,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.mediumGap), // 16px padding for icon
             child: SvgPicture.asset(
              'assets/UserIcon.svg',
              colorFilter: const ColorFilter.mode(
                AppTheme.fontMediumPurple,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.smallGap), // Gap 8px
        // User Name and Team
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap), // Padding 8px
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.consultantName,
                  style: AppTheme.primaryTitleStyle, // 17px, w600, #886699
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4), // 4px gap from Figma
                Text(
                  widget.teamName,
                  style: AppTheme.secondaryTitleStyle, // 15px, w500, #927B9D
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Builds the rotating statistics section
  Widget _buildStatsSection() {
    // Get current stat to display
    final currentStat = _stats[_currentStatIndex];
    final hasProgressBar = currentStat.progress != null;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
      child: hasProgressBar 
          ? _buildProgressBar(currentStat.progress!)
          : _buildValueDisplay(currentStat),
    );
  }
  
  // Builds a progress bar for percentage-based stats
  Widget _buildProgressBar(double progress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // LoadingBar Container
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusTiny), // 8px
            child: Container(
              height: 16, // Height 16px from Figma
              color: AppTheme.backgroundLightPurple, // Background #CFC4D4
              child: FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundDarkPurple, // Loaded #C6ACD3
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.borderRadiusTiny),
                      bottomLeft: Radius.circular(AppTheme.borderRadiusTiny),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.smallGap), // Gap 8px between bar and count
        // Value/Percentage Text
        Container(
          height: 16, // Match progress bar height
          alignment: Alignment.center,
          child: Text(
            progress >= 0 ? '${(progress * 100).round()}%' : '0%',
            style: AppTheme.tinyTextStyle, // 13px, w500, #886699
          ),
        ),
      ],
    );
  }
  
  // Builds a horizontal stat row with title and value on the same line
  Widget _buildValueDisplay(UserStatConfig stat) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title with left padding
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
          child: Text(
            stat.label,
            style: AppTheme.smallTextStyle,
          ),
        ),
        // Value with right padding
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
          child: Text(
            stat.value,
            style: AppTheme.tinyTextStyle.copyWith(
              fontSize: AppTheme.fontSizeMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
} 