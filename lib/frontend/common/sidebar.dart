import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../backend/services/sidebarService.dart';
import '../common/appTheme.dart';
import '../popups/consultantPopup.dart';

/// Widget pentru sidebar-ul aplicației
/// 
/// Această componentă implementează sidebar-ul permanent al aplicației,
/// care permite navigarea între arii și panouri, precum și accesul la funcții rapide.
class Sidebar extends StatefulWidget {
  final String consultantName;
  final String teamName;
  final AreaType currentArea;
  final PaneType currentPane;
  final AreaChangeCallback onAreaChanged;
  final PaneChangeCallback onPaneChanged;
  final PopupShowCallback onPopupRequested;

  const Sidebar({
    Key? key,
    required this.consultantName,
    required this.teamName,
    required this.currentArea,
    required this.currentPane,
    required this.onAreaChanged,
    required this.onPaneChanged,
    required this.onPopupRequested,
  }) : super(key: key);

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  late SidebarService _sidebarService;

  @override
  void initState() {
    super.initState();
    _sidebarService = SidebarService();
    _sidebarService.setInitialState(
      consultantName: widget.consultantName,
      teamName: widget.teamName,
      initialArea: widget.currentArea,
      initialPane: widget.currentPane,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 224,
      height: 1032, // Înălțime fixă conform design-ului
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: BoxDecoration(
        color: AppTheme.widgetBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: [AppTheme.widgetShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Secțiunea de consultant
          _buildConsultantSection(),
          const SizedBox(height: AppTheme.mediumGap),
          
          // Secțiunea de funcții
          _buildFunctionSection(),
          const SizedBox(height: AppTheme.mediumGap),
          
          // Secțiunea de arii
          _buildNavigationSection(
            title: 'Arii',
            buttons: _sidebarService.getAreaButtons(),
            onPressed: (buttonConfig) {
              if (buttonConfig.target is AreaType) {
                final AreaType area = buttonConfig.target as AreaType;
                widget.onAreaChanged(area);
                _sidebarService.changeArea(area);
                setState(() {});
              }
            },
          ),
          const SizedBox(height: AppTheme.mediumGap),
          
          // Secțiunea de panouri
          _buildNavigationSection(
            title: 'Panouri',
            buttons: _sidebarService.getPaneButtons(),
            onPressed: (buttonConfig) {
              if (buttonConfig.target is PaneType) {
                final PaneType pane = buttonConfig.target as PaneType;
                widget.onPaneChanged(pane);
                _sidebarService.changePane(pane);
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }

  // Construiește secțiunea de consultant (Avatar + Informații)
  Widget _buildConsultantSection() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.backgroundLightPurple,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Row(
        children: [
          // Informații consultant
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.mediumGap,
                AppTheme.smallGap,
                AppTheme.smallGap,
                AppTheme.smallGap,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.consultantName,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.fontMediumPurple,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.tinyGap),
                  Text(
                    widget.teamName,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: AppTheme.fontSizeSmall,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.fontLightPurple,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          
          // Buton avatar
          GestureDetector(
            onTap: () {
              widget.onPopupRequested(PopupType.consultantPopup);
            },
            child: Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.all(AppTheme.smallGap),
              decoration: BoxDecoration(
                color: const Color(0xFFACACD3), // Culoare specifică din design
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.mediumGap / 1.5),
                child: SvgPicture.asset(
                  'assets/icons/UserIcon.svg',
                  colorFilter: ColorFilter.mode(
                    AppTheme.fontDarkPurple,
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

  // Construiește secțiunea de funcții (butoane rapide)
  Widget _buildFunctionSection() {
    final functionButtons = _sidebarService.getFunctionButtons();
    
    if (functionButtons.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Deocamdată avem doar un buton
    final buttonConfig = functionButtons.first;
    
    return Container(
      height: 48,
      width: double.infinity,
      child: _buildFunctionButton(
        title: buttonConfig.title,
        iconPath: buttonConfig.iconPath,
        onPressed: () {
          if (buttonConfig.target is PopupType) {
            widget.onPopupRequested(buttonConfig.target as PopupType);
          }
        },
      ),
    );
  }

  // Construiește secțiunea de navigare (arii sau panouri)
  Widget _buildNavigationSection({
    required String title,
    required List<SidebarButtonConfig> buttons,
    required Function(SidebarButtonConfig) onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundLightPurple,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header secțiune
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.mediumGap,
              vertical: AppTheme.smallGap,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: AppTheme.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color: AppTheme.fontLightPurple,
              ),
            ),
          ),
          
          // Butoane
          Container(
            padding: const EdgeInsets.only(bottom: AppTheme.smallGap),
            child: Column(
              children: [
                ...buttons.map((button) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.smallGap),
                  child: _buildNavigationButton(
                    title: button.title,
                    iconPath: button.iconPath,
                    isActive: _sidebarService.isButtonActive(button.target),
                    onPressed: () => onPressed(button),
                  ),
                )).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Construiește un buton de funcție
  Widget _buildFunctionButton({
    required String title,
    required String iconPath,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.backgroundLightPurple,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: AppTheme.mediumGap,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.fontMediumPurple,
                  ),
                ),
                const SizedBox(width: AppTheme.smallGap),
                SvgPicture.asset(
                  iconPath,
                  width: AppTheme.iconSizeMedium,
                  height: AppTheme.iconSizeMedium,
                  colorFilter: ColorFilter.mode(
                    AppTheme.fontMediumPurple,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Construiește un buton de navigare (arie sau panou)
  Widget _buildNavigationButton({
    required String title,
    required String iconPath,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    final backgroundColor = isActive 
        ? AppTheme.backgroundDarkPurple
        : AppTheme.backgroundLightPurple;
    
    final textColor = isActive
        ? AppTheme.fontDarkPurple
        : AppTheme.fontMediumPurple;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppTheme.mediumGap),
                SvgPicture.asset(
                  iconPath,
                  width: AppTheme.iconSizeMedium,
                  height: AppTheme.iconSizeMedium,
                  colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
