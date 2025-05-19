import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:broker_app/frontend/common/appTheme.dart';
// Removed UserWidget import as it's no longer part of this widget
import 'package:broker_app/old/sidebar/navigation_config.dart'; // Import the renamed configuration

/// Widget responsible for displaying navigation buttons based on configuration.
/// It should be placed alongside UserWidget in the parent screen's layout.
class NavigationWidget extends StatefulWidget {
  // Removed user-related properties (consultantName, teamName)
  final NavigationScreen currentScreen; // To know which main screen is active
  final SecondaryPanelType? activeSecondaryPanel; // To highlight the active secondary panel
  final ScreenChangeCallback onScreenChanged;
  final PanelChangeCallback? onPanelChanged; // Optional: only needed if secondary panels exist

  const NavigationWidget({
    Key? key,
    required this.currentScreen,
    this.activeSecondaryPanel,
    required this.onScreenChanged,
    this.onPanelChanged,
  }) : super(key: key);

  @override
  State<NavigationWidget> createState() => _NavigationWidgetState();
}

class _NavigationWidgetState extends State<NavigationWidget> {
  bool _isMainNavCollapsed = false;
  bool _isSecondaryNavCollapsed = false;

  @override
  Widget build(BuildContext context) {
    // Extract Settings Button Config
    final settingsButtonConfig = sidebarButtons.firstWhere(
      (button) => button.id == 'settings',
      orElse: () => throw Exception('Settings button configuration not found'),
    );

    // Filter Main and Secondary Buttons (excluding settings)
    final mainButtons = sidebarButtons
        .where((button) => button.visibleOnScreen == null && button.id != 'settings')
        .toList();
    final secondaryButtons = sidebarButtons
        .where((button) => button.visibleOnScreen == widget.currentScreen)
        .toList();

    // Find the active main button
    final activeMainButton = mainButtons.firstWhere(
      (button) => button.targetScreen == widget.currentScreen,
      orElse: () => mainButtons.first, // Default to first if not found
    );

    // Find the active secondary button
    final activeSecondaryButton = secondaryButtons.isNotEmpty 
        ? secondaryButtons.firstWhere(
            (button) => button.targetPanel == widget.activeSecondaryPanel,
            orElse: () => secondaryButtons.first, // Default to first if not found
          ) 
        : null;

    return Container(
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: AppTheme.widgetDecoration,
      // Use Column to separate scrollable buttons and settings button
      child: Column(
        children: [
          // Scrollable Area for Main/Secondary Buttons
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main Navigation Panel
                  if (mainButtons.isNotEmpty) ...[
                    _buildPanelHeader('Navigatie', isCollapsed: _isMainNavCollapsed, onToggle: () {
                      setState(() {
                        _isMainNavCollapsed = !_isMainNavCollapsed;
                      });
                    }),
                    const SizedBox(height: AppTheme.smallGap),
                    ..._buildMainNavigationButtons(
                      _isMainNavCollapsed ? [activeMainButton] : mainButtons,
                    ),
                  ],
                  
                  // Secondary Panel (Conditional)
                  if (secondaryButtons.isNotEmpty) ...[
                    // Add gap between sections
                    if (mainButtons.isNotEmpty) 
                      const SizedBox(height: AppTheme.smallGap), 
                    _buildPanelHeader('Panouri', isCollapsed: _isSecondaryNavCollapsed, onToggle: () {
                      setState(() {
                        _isSecondaryNavCollapsed = !_isSecondaryNavCollapsed;
                      });
                    }),
                    const SizedBox(height: AppTheme.smallGap),
                    ..._buildSecondaryNavigationButtons(
                      _isSecondaryNavCollapsed && activeSecondaryButton != null 
                          ? [activeSecondaryButton] 
                          : secondaryButtons,
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Settings Button Area (at the bottom)
          const SizedBox(height: AppTheme.smallGap), 
          _buildNavButton(
            context,
            config: settingsButtonConfig,
            isActive: widget.currentScreen == settingsButtonConfig.targetScreen,
            isLast: true,
          ),
        ],
      ),
    );
  }

  // Helper to build panel headers with proper padding and toggle functionality
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
              // Additional padding for the text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                child: Text(
                  title,
                  style: AppTheme.navigationHeaderStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // SVG icon for dropdown with rotation based on collapse state
              Transform.rotate(
                angle: isCollapsed ? 3.14159 : 0, // 180 degrees rotation when collapsed
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

  // Helper method to build main navigation buttons
  List<Widget> _buildMainNavigationButtons(List<SidebarButtonConfig> buttons) {
    final List<Widget> buttonWidgets = [];
    
    for (int i = 0; i < buttons.length; i++) {
      final isLast = i == buttons.length - 1;
      buttonWidgets.add(
        _buildNavButton(
          context,
          config: buttons[i],
          isActive: widget.currentScreen == buttons[i].targetScreen,
          isLast: isLast,
        ),
      );
    }
    
    return buttonWidgets;
  }

  // Helper method to build secondary navigation buttons
  List<Widget> _buildSecondaryNavigationButtons(List<SidebarButtonConfig> buttons) {
    final List<Widget> buttonWidgets = [];
    
    for (int i = 0; i < buttons.length; i++) {
      final isLast = i == buttons.length - 1;
      buttonWidgets.add(
        _buildNavButton(
          context,
          config: buttons[i],
          isActive: widget.activeSecondaryPanel == buttons[i].targetPanel,
          isLast: isLast,
        ),
      );
    }
    
    return buttonWidgets;
  }

  // Helper to build a navigation button according to the Figma design
  Widget _buildNavButton(
    BuildContext context,
    {
      required SidebarButtonConfig config,
      required bool isActive,
      bool isLast = false,
    }
  ) {
    // Use decorations from AppTheme
    final BoxDecoration decoration = isActive
        ? AppTheme.activeNavButtonDecoration
        : AppTheme.inactiveNavButtonDecoration;
        
    // Determine colors based on active state
    final Color iconColor = isActive ? AppTheme.fontDarkPurple : AppTheme.fontMediumPurple;
    final Color textColor = isActive ? AppTheme.fontDarkPurple : AppTheme.fontMediumPurple;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppTheme.smallGap), // Gap 8px between buttons
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
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
          child: Container(
            // Padding 12px vertical, 16px horizontal from Figma
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.mediumGap,
              vertical: 12, 
            ),
            decoration: decoration,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text with 8px padding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                  child: Text(
                    config.title,
                    style: AppTheme.navigationButtonTextStyle.copyWith(color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Icon with 8px padding
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
    );
  }
} 