import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:broker_app/old/theme/app_theme.dart';
import 'package:broker_app/old/popups/consultant_popup.dart';
import 'package:broker_app/old/sidebar/navigation_config.dart';

/// Widget care integrează informațiile despre consultant și toate butoanele de navigare
/// într-un singur widget vertical conform noului design pentru formScreen.
class SidebarWidget extends StatefulWidget {
  final String consultantName;
  final String teamName;
  final NavigationScreen currentScreen;
  final SecondaryPanelType? activeSecondaryPanel;
  final ScreenChangeCallback onScreenChanged;
  final PanelChangeCallback? onPanelChanged;

  const SidebarWidget({
    Key? key,
    required this.consultantName,
    required this.teamName,
    required this.currentScreen,
    this.activeSecondaryPanel,
    required this.onScreenChanged,
    this.onPanelChanged,
  }) : super(key: key);

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  bool _isMainNavCollapsed = false;
  bool _isSecondaryNavCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 224,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: AppTheme.widgetDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top sections
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Section
              _buildConsultantInfo(),
              const SizedBox(height: AppTheme.mediumGap),
              
              // Function Section (quick action buttons)
              _buildQuickActionButtons(),
              const SizedBox(height: AppTheme.mediumGap),
              
              // Navigation Section
              _buildPanelHeader(
                'Navigare',
                isCollapsed: _isMainNavCollapsed,
                onToggle: () {
                  setState(() {
                    _isMainNavCollapsed = !_isMainNavCollapsed;
                  });
                },
              ),
              const SizedBox(height: AppTheme.smallGap),
              ..._buildMainNavigationButtons(),
              
              // Panel Section (if on form screen)
              if (widget.currentScreen == NavigationScreen.form) ...[
                const SizedBox(height: AppTheme.mediumGap),
                _buildPanelHeader(
                  'Functionalitati',
                  isCollapsed: _isSecondaryNavCollapsed,
                  onToggle: () {
                    setState(() {
                      _isSecondaryNavCollapsed = !_isSecondaryNavCollapsed;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.smallGap),
                ..._buildSecondaryNavigationButtons(),
              ],
            ],
          ),
          
          // Settings Section at bottom with no extra spacing
          _buildSettingsButton(),
        ],
      ),
    );
  }

  // Build consultant info section (avatar, name, team)
  Widget _buildConsultantInfo() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Show consultant popup
          showDialog(
            context: context,
            builder: (context) => ConsultantPopup(
              consultantName: widget.consultantName,
              teamName: widget.teamName,
            ),
          );
        },
        child: Container(
          height: 72,
          padding: const EdgeInsets.all(AppTheme.smallGap),
          decoration: BoxDecoration(
            color: AppTheme.backgroundLightPurple,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDarkPurple,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.mediumGap),
                  child: SvgPicture.asset(
                    'assets/UserIcon.svg',
                    width: AppTheme.iconSizeMedium,
                    height: AppTheme.iconSizeMedium,
                    colorFilter: const ColorFilter.mode(
                      AppTheme.fontMediumPurple,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.mediumGap),
              // Consultant Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.consultantName,
                      style: AppTheme.primaryTitleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.teamName,
                      style: AppTheme.secondaryTitleStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build quick action buttons row (recommendation, calculator) - icon only
  Widget _buildQuickActionButtons() {
    return Row(
      children: [
        // Recommendation Button
        Expanded(
          child: _buildQuickActionButton(
            'assets/ContactsIcon.svg',
            onTap: () {
              // Open recommendation popup or panel
              if (widget.onPanelChanged != null) {
                widget.onPanelChanged!(SecondaryPanelType.recommendation);
              }
            },
          ),
        ),
        const SizedBox(width: AppTheme.smallGap),
        // Calculator Button
        Expanded(
          child: _buildQuickActionButton(
            'assets/CalculatorIcon.svg',
            onTap: () {
              // Open calculator popup or panel
              if (widget.onPanelChanged != null) {
                widget.onPanelChanged!(SecondaryPanelType.calculator);
              }
            },
          ),
        ),
      ],
    );
  }

  // Helper to build a single quick action button (icon only)
  Widget _buildQuickActionButton(String iconPath, {required VoidCallback onTap}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.backgroundLightPurple,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          child: Center(
            child: SvgPicture.asset(
              iconPath,
              width: AppTheme.iconSizeMedium,
              height: AppTheme.iconSizeMedium,
              colorFilter: const ColorFilter.mode(
                AppTheme.fontMediumPurple,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build panel header with toggle functionality
  Widget _buildPanelHeader(String title, {required bool isCollapsed, required VoidCallback onToggle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onToggle,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                child: Text(
                  title,
                  style: AppTheme.navigationHeaderStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Transform.rotate(
                angle: isCollapsed ? 3.14159 : 0, // 180 degrees when collapsed
                child: SvgPicture.asset(
                  'assets/DropdownIcon.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    AppTheme.fontLightPurple,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build main navigation buttons (Dashboard, Formular, Calendar)
  List<Widget> _buildMainNavigationButtons() {
    final mainButtons = sidebarButtons
        .where((button) => 
            button.visibleOnScreen == null && 
            button.id != 'settings')
        .toList();
    
    if (_isMainNavCollapsed) {
      // Show just the active button when collapsed
      final activeButton = mainButtons.firstWhere(
        (button) => button.targetScreen == widget.currentScreen,
        orElse: () => mainButtons.first,
      );
      return [_buildNavButton(activeButton)];
    }
    
    return mainButtons.map(_buildNavButton).toList();
  }

  // Build secondary navigation buttons (specific to form screen)
  List<Widget> _buildSecondaryNavigationButtons() {
    final secondaryButtons = sidebarButtons
        .where((button) => button.visibleOnScreen == widget.currentScreen)
        .toList();
    
    if (_isSecondaryNavCollapsed) {
      // When collapsed, show just the active secondary button if any
      if (widget.activeSecondaryPanel != null) {
        final activeButton = secondaryButtons.firstWhere(
          (button) => button.targetPanel == widget.activeSecondaryPanel,
          orElse: () => secondaryButtons.first,
        );
        return [_buildNavButton(activeButton)];
      }
      return [_buildNavButton(secondaryButtons.first)];
    }
    
    return secondaryButtons.map(_buildNavButton).toList();
  }

  // Build settings button
  Widget _buildSettingsButton() {
    final settingsButton = sidebarButtons.firstWhere(
      (button) => button.id == 'settings',
      orElse: () => throw Exception('Settings button configuration not found'),
    );
    
    return _buildNavButton(settingsButton, isLast: true);
  }
  
  // Helper to build a navigation button
  Widget _buildNavButton(SidebarButtonConfig config, {bool isLast = false}) {
    final bool isActive;
    
    if (config.actionType == SidebarButtonActionType.navigateToScreen) {
      isActive = widget.currentScreen == config.targetScreen;
    } else if (config.actionType == SidebarButtonActionType.showSecondaryPanel) {
      isActive = widget.activeSecondaryPanel == config.targetPanel;
    } else {
      isActive = false;
    }
    
    final decoration = isActive
        ? BoxDecoration(
            color: AppTheme.backgroundDarkPurple,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          )
        : BoxDecoration(
            color: AppTheme.backgroundLightPurple,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          );
        
    final Color iconColor = isActive ? AppTheme.fontDarkPurple : AppTheme.fontMediumPurple;
    final Color textColor = isActive ? AppTheme.fontDarkPurple : AppTheme.fontMediumPurple;
    
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppTheme.smallGap),
      child: Container(
        height: AppTheme.navButtonHeight,
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            onTap: () {
              switch (config.actionType) {
                case SidebarButtonActionType.navigateToScreen:
                  if (config.targetScreen != null) {
                    widget.onScreenChanged(config.targetScreen!);
                  }
                  break;
                case SidebarButtonActionType.showSecondaryPanel:
                  if (config.targetPanel != null && widget.onPanelChanged != null) {
                    widget.onPanelChanged!(config.targetPanel!);
                  }
                  break;
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.mediumGap,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                    child: Text(
                      config.title,
                      style: AppTheme.navigationButtonTextStyle.copyWith(color: textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                    child: SvgPicture.asset(
                      config.iconPath,
                      width: AppTheme.iconSizeMedium,
                      height: AppTheme.iconSizeMedium,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 