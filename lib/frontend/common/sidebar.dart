import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/frontend/popups/consultantPopup.dart';
import 'package:broker_app/backend/services/sidebarService.dart';
import 'package:broker_app/frontend/common/components/headers/widgetHeader3.dart';
import 'package:broker_app/frontend/common/components/buttons/spacedButtons1.dart';

/// Main sidebar widget that provides navigation and consultant information
/// 
/// This widget displays:
/// - Consultant information section with tap-to-view-details
/// - Quick function buttons (e.g., "Clienti")
/// - Collapsible Areas navigation section
/// - Collapsible Panes navigation section
/// 
/// The sidebar uses the SidebarService for all business logic and state management.
class SidebarWidget extends StatefulWidget {
  /// Consultant's name displayed in the header
  final String consultantName;
  
  /// Team name displayed under consultant name
  final String teamName;
  
  /// Currently active area type
  final AreaType currentArea;
  
  /// Currently active pane type (can be null)
  final PaneType? currentPane;
  
  /// Callback when area changes
  final AreaChangeCallback onAreaChanged;
  
  /// Callback when pane changes
  final PaneChangeCallback onPaneChanged;
  
  /// Optional callback for clients popup
  final PopupCallback? onClientsPopupRequested;

  const SidebarWidget({
    super.key,
    required this.consultantName,
    required this.teamName,
    required this.currentArea,
    this.currentPane,
    required this.onAreaChanged,
    required this.onPaneChanged,
    this.onClientsPopupRequested,
  });

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  late final SidebarService _sidebarService;
  
  // UI state for collapsible sections
  bool _isAreaSectionCollapsed = false;
  bool _isPaneSectionCollapsed = false;
  
  // UI state for consultant section hover
  bool _isConsultantSectionHovered = false;

  @override
  void initState() {
    super.initState();
    _sidebarService = SidebarService(
      onAreaChanged: widget.onAreaChanged,
      onPaneChanged: widget.onPaneChanged,
      initialArea: widget.currentArea,
      initialPane: widget.currentPane,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 224,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: AppTheme.widgetDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Consultant information section
          _buildConsultantSection(),
          const SizedBox(height: AppTheme.mediumGap),
          
          // Areas navigation section
          _buildAreasSection(),
          const SizedBox(height: AppTheme.mediumGap),
          
          // Panes navigation section
          _buildPanesSection(),
        ],
      ),
    );
  }

  /// Builds the consultant information section with avatar and details
  Widget _buildConsultantSection() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isConsultantSectionHovered = true),
      onExit: (_) => setState(() => _isConsultantSectionHovered = false),
      child: GestureDetector(
        onTap: _showConsultantPopup,
        child: Container(
          height: 63,
          decoration: BoxDecoration(
            color: _isConsultantSectionHovered ? AppTheme.containerColor2 : AppTheme.containerColor1,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 7),
            child: Row(
              children: [
                // Consultant information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.consultantName,
                        style: AppTheme.primaryTitleStyle.copyWith(
                          color: _isConsultantSectionHovered ? AppTheme.elementColor3 : AppTheme.elementColor2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.teamName,
                        style: AppTheme.secondaryTitleStyle.copyWith(
                          color: _isConsultantSectionHovered ? AppTheme.elementColor2 : AppTheme.elementColor1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Consultant avatar button
                _buildConsultantAvatar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the consultant avatar container
  Widget _buildConsultantAvatar() {
    return Container(
      width: 48,
      height: 47,
      decoration: BoxDecoration(
        color: AppTheme.containerColor2,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/userIcon.svg',
          width: AppTheme.iconSizeMedium,
          height: AppTheme.iconSizeMedium,
          colorFilter: ColorFilter.mode(
            AppTheme.elementColor3,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  /// Builds the areas navigation section with collapsible header
  Widget _buildAreasSection() {
    return Column(
      children: [
        WidgetHeader3(
          title: 'Principal',
          trailingIcon: _isAreaSectionCollapsed 
              ? Icons.keyboard_arrow_up 
              : Icons.keyboard_arrow_down,
          onTrailingIconTap: () {
            setState(() {
              _isAreaSectionCollapsed = !_isAreaSectionCollapsed;
            });
          },
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
        ),
        const SizedBox(height: AppTheme.smallGap),
        _buildAreaButtons(),
      ],
    );
  }

  /// Builds the panes navigation section with collapsible header
  Widget _buildPanesSection() {
    return Column(
      children: [
        WidgetHeader3(
          title: 'Secundar',
          trailingIcon: _isPaneSectionCollapsed 
              ? Icons.keyboard_arrow_up 
              : Icons.keyboard_arrow_down,
          onTrailingIconTap: () {
            setState(() {
              _isPaneSectionCollapsed = !_isPaneSectionCollapsed;
            });
          },
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
        ),
        const SizedBox(height: AppTheme.smallGap),
        _buildPaneButtons(),
      ],
    );
  }

  /// Builds the area navigation buttons with collapse behavior
  Widget _buildAreaButtons() {
    final buttons = _sidebarService.areaButtons;
    
    if (_isAreaSectionCollapsed) {
      // When collapsed, show only the active button
      final activeButton = buttons.firstWhere(
        (button) => button.targetArea == widget.currentArea,
        orElse: () => buttons.first,
      );
      return _buildNavigationButton(activeButton);
    }
    
    // When expanded, show all buttons with proper gap spacing
    return Column(
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          _buildNavigationButton(buttons[i]),
          if (i < buttons.length - 1) const SizedBox(height: AppTheme.smallGap),
        ],
      ],
    );
  }

  /// Builds the pane navigation buttons with collapse behavior
  Widget _buildPaneButtons() {
    final buttons = _sidebarService.paneButtons;
    
    if (_isPaneSectionCollapsed) {
      // When collapsed, show only the active button
      final activeButton = buttons.firstWhere(
        (button) => button.targetPane == widget.currentPane,
        orElse: () => buttons.first,
      );
      return _buildNavigationButton(activeButton);
    }
    
    // When expanded, show all buttons with proper gap spacing
    return Column(
      children: [
        for (int i = 0; i < buttons.length; i++) ...[
          _buildNavigationButton(buttons[i]),
          if (i < buttons.length - 1) const SizedBox(height: AppTheme.smallGap),
        ],
      ],
    );
  }

  /// Builds a single navigation button with active state styling
  Widget _buildNavigationButton(ButtonConfig button) {
    bool isActive = _isButtonActive(button);
    
    if (isActive) {
      // For active buttons, set explicit colors
      return SpacedButtonSingleSvg(
        text: button.title,
        iconPath: button.iconPath,
        onTap: () => _sidebarService.handleButtonClick(button),
        backgroundColor: AppTheme.containerColor2,
        textColor: AppTheme.elementColor3,
        iconColor: AppTheme.elementColor3,
        borderRadius: AppTheme.borderRadiusMedium,
        buttonHeight: AppTheme.navButtonHeight,
      );
    } else {
      // For inactive buttons, let the component handle hover states
      return SpacedButtonSingleSvg(
        text: button.title,
        iconPath: button.iconPath,
        onTap: () => _sidebarService.handleButtonClick(button),
        borderRadius: AppTheme.borderRadiusMedium,
        buttonHeight: AppTheme.navButtonHeight,
      );
    }
  }

  /// Determines if a button should appear as active
  bool _isButtonActive(ButtonConfig button) {
    if (button.actionType == ActionType.navigateToArea && button.targetArea != null) {
      return widget.currentArea == button.targetArea;
    } else if (button.actionType == ActionType.openPane && button.targetPane != null) {
      return widget.currentPane == button.targetPane;
    }
    return false;
  }

  /// Shows the consultant details popup
  void _showConsultantPopup() {
    showDialog(
      context: context,
      builder: (context) => ConsultantPopup(
        consultantName: widget.consultantName,
        teamName: widget.teamName,
      ),
    );
  }
}

/// Compatibility wrapper that adapts old navigation parameters to new system
/// 
/// This adapter allows existing code to continue using the old navigation
/// system while benefiting from the new sidebar implementation.
class SidebarWidgetAdapter extends StatelessWidget {
  /// Consultant's name
  final String consultantName;
  
  /// Team name
  final String teamName;
  
  /// Current navigation screen (old system)
  final NavigationScreen currentScreen;
  
  /// Active secondary panel (old system)
  final SecondaryPanelType? activeSecondaryPanel;
  
  /// Screen change callback (old system)
  final ScreenChangeCallback onScreenChanged;
  
  /// Panel change callback (old system)
  final PanelChangeCallback? onPanelChanged;

  const SidebarWidgetAdapter({
    super.key,
    required this.consultantName,
    required this.teamName,
    required this.currentScreen,
    this.activeSecondaryPanel,
    required this.onScreenChanged,
    this.onPanelChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Convert old navigation parameters to new format
    final AreaType currentArea = SidebarService.mapToArea(currentScreen);
    
    // Convert old panel to new pane if it exists
    PaneType? currentPane;
    if (activeSecondaryPanel != null) {
      currentPane = SidebarService.mapToPane(activeSecondaryPanel!);
    }
    
    // Create adapters for the callbacks
    final areaChangedCallback = SidebarService.adaptScreenChangeCallback(onScreenChanged);
    
    // Create an adapter for panel change callback if it exists
    PaneChangeCallback? paneChangedCallback;
    if (onPanelChanged != null) {
      paneChangedCallback = SidebarService.adaptPanelChangeCallback(onPanelChanged!);
    }
    
    // Return new sidebar widget with converted parameters
    return SidebarWidget(
      consultantName: consultantName,
      teamName: teamName,
      currentArea: currentArea,
      currentPane: currentPane,
      onAreaChanged: areaChangedCallback,
      onPaneChanged: paneChangedCallback ?? (_) {}, // Empty callback if none exists
      onClientsPopupRequested: () {
        // Simple implementation - can be expanded later if needed
      },
    );
  }
}
