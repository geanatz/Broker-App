import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/frontend/popups/consultantPopup.dart';
import 'package:broker_app/old/sidebar/sidebar_service.dart';

/// Widget care implementează sidebar-ul conform noului design
/// Conține secțiuni pentru informatii consultant, funcții rapide, 
/// navigare între area-uri și pane-uri
class SidebarWidget extends StatefulWidget {
  final String consultantName;
  final String teamName;
  final AreaType currentArea;
  final PaneType? currentPane;
  final AreaChangeCallback onAreaChanged;
  final PaneChangeCallback onPaneChanged;
  final PopupCallback? onClientsPopupRequested;

  const SidebarWidget({
    Key? key,
    required this.consultantName,
    required this.teamName,
    required this.currentArea,
    this.currentPane,
    required this.onAreaChanged,
    required this.onPaneChanged,
    this.onClientsPopupRequested,
  }) : super(key: key);

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  late final SidebarService _sidebarService;
  bool _isAreaSectionCollapsed = false;
  bool _isPaneSectionCollapsed = false;

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
          // Consultant Section
          _buildConsultantSection(),
          const SizedBox(height: AppTheme.mediumGap),
          
          // Function Section
          _buildFunctionSection(),
          const SizedBox(height: AppTheme.mediumGap),
          
          // Area Section
          _buildSectionHeader(
            'Areas', 
            isCollapsed: _isAreaSectionCollapsed,
            onToggle: () {
              setState(() {
                _isAreaSectionCollapsed = !_isAreaSectionCollapsed;
              });
            },
          ),
          const SizedBox(height: AppTheme.smallGap),
          _buildAreaButtons(),
          const SizedBox(height: AppTheme.mediumGap),
          
          // Pane Section
          _buildSectionHeader(
            'Panes', 
            isCollapsed: _isPaneSectionCollapsed,
            onToggle: () {
              setState(() {
                _isPaneSectionCollapsed = !_isPaneSectionCollapsed;
              });
            },
          ),
          const SizedBox(height: AppTheme.smallGap),
          _buildPaneButtons(),
        ],
      ),
    );
  }

  // Construiește secțiunea cu informațiile consultantului
  Widget _buildConsultantSection() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.backgroundLightPurple,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Deschide popup-ul cu informații despre consultant
            showDialog(
              context: context,
              builder: (context) => ConsultantPopup(
                consultantName: widget.consultantName,
                teamName: widget.teamName,
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.mediumGap, 
              AppTheme.smallGap, 
              AppTheme.smallGap, 
              AppTheme.smallGap
            ),
            child: Row(
              children: [
                // Informații consultant
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
                const SizedBox(width: AppTheme.mediumGap),
                // Buton consultant
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDarkPurple,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/userIcon.svg',
                      width: AppTheme.iconSizeMedium,
                      height: AppTheme.iconSizeMedium,
                      colorFilter: const ColorFilter.mode(
                        AppTheme.fontMediumPurple,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Construiește secțiunea pentru butonul de funcție rapidă
  Widget _buildFunctionSection() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.backgroundLightPurple,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onClientsPopupRequested, // Deschide popup-ul clientsPopup
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12, 
              horizontal: AppTheme.mediumGap,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                  child: Text(
                    'Clienti Noi',
                    style: AppTheme.navigationButtonTextStyle.copyWith(
                      color: AppTheme.fontMediumPurple,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                  child: SvgPicture.asset(
                    'assets/clientsIcon.svg',
                    width: AppTheme.iconSizeMedium,
                    height: AppTheme.iconSizeMedium,
                    colorFilter: const ColorFilter.mode(
                      AppTheme.fontMediumPurple,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Construiește header-ul pentru secțiuni (Area, Pane)
  Widget _buildSectionHeader(String title, {required bool isCollapsed, required VoidCallback onToggle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
            child: Text(
              title,
              style: AppTheme.navigationHeaderStyle,
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onToggle,
              child: Transform.rotate(
                angle: isCollapsed ? 3.14159 : 0, // 180 degrees when collapsed
                child: SvgPicture.asset(
                  'assets/expandIcon.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppTheme.fontLightPurple,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Construiește butoanele pentru secțiunea Area
  Widget _buildAreaButtons() {
    final buttons = _sidebarService.areaButtons;
    
    if (_isAreaSectionCollapsed) {
      // Când secțiunea e colapsată, arată doar butonul activ
      final activeButton = buttons.firstWhere(
        (button) => button.targetArea == widget.currentArea,
        orElse: () => buttons.first,
      );
      return _buildNavigationButton(activeButton);
    }
    
    return Column(
      children: buttons.map((button) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.smallGap),
          child: _buildNavigationButton(button),
        );
      }).toList(),
    );
  }

  // Construiește butoanele pentru secțiunea Pane
  Widget _buildPaneButtons() {
    final buttons = _sidebarService.paneButtons;
    
    if (_isPaneSectionCollapsed) {
      // Când secțiunea e colapsată, arată doar butonul activ
      final activeButton = buttons.firstWhere(
        (button) => button.targetPane == widget.currentPane,
        orElse: () => buttons.first,
      );
      return _buildNavigationButton(activeButton);
    }
    
    return Column(
      children: buttons.map((button) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.smallGap),
          child: _buildNavigationButton(button),
        );
      }).toList(),
    );
  }

  // Construiește un buton de navigare generic
  Widget _buildNavigationButton(ButtonConfig button) {
    bool isActive = false;
    
    // Determină dacă butonul este activ
    if (button.actionType == ActionType.navigateToArea && button.targetArea != null) {
      isActive = widget.currentArea == button.targetArea;
    } else if (button.actionType == ActionType.openPane && button.targetPane != null) {
      isActive = widget.currentPane == button.targetPane;
    }
    
    final decoration = isActive
        ? AppTheme.activeNavButtonDecoration
        : AppTheme.inactiveNavButtonDecoration;
    
    final Color iconColor = isActive ? AppTheme.fontDarkPurple : AppTheme.fontMediumPurple;
    final Color textColor = isActive ? AppTheme.fontDarkPurple : AppTheme.fontMediumPurple;
    
    return Container(
      height: AppTheme.navButtonHeight,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _sidebarService.handleButtonClick(button),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
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
                    button.title,
                    style: AppTheme.navigationButtonTextStyle.copyWith(color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                  child: SvgPicture.asset(
                    button.iconPath,
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

/// A compatibility wrapper for SidebarWidget that accepts old navigation parameters
/// and converts them to the new format
class SidebarWidgetAdapter extends StatelessWidget {
  final String consultantName;
  final String teamName;
  final NavigationScreen currentScreen;
  final SecondaryPanelType? activeSecondaryPanel;
  final ScreenChangeCallback onScreenChanged;
  final PanelChangeCallback? onPanelChanged;

  const SidebarWidgetAdapter({
    Key? key,
    required this.consultantName,
    required this.teamName,
    required this.currentScreen,
    this.activeSecondaryPanel,
    required this.onScreenChanged,
    this.onPanelChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert old navigation parameters to new ones
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
      onPaneChanged: paneChangedCallback ?? (_) {}, // Provide empty callback if none exists
      onClientsPopupRequested: () {
        // Simple implementation that doesn't do anything
        // This could be expanded later if needed
      },
    );
  }
} 