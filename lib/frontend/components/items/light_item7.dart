import 'package:mat_finance/app_theme.dart';
// lib/components/items/light_item7.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A customizable light-themed item with title, description, and an
/// optional icon in a styled trailing container.
class LightItem7 extends StatefulWidget {
  /// The primary title text.
  final String title;

  /// The secondary description text displayed below the title.
  final String description;

  /// Optional icon data to display on the right.
  final IconData? icon;

  /// Optional SVG asset path to display on the right (takes precedence over icon).
  final String? svgAsset;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  /// Optional custom background color for the main container.
  /// Defaults to AppTheme.backgroundColor2.
  final Color? backgroundColor;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor2.
  final Color? titleColor;

  /// Optional custom color for the description text.
  /// Defaults to AppTheme.elementColor1.
  final Color? descriptionColor;

  /// Optional custom color for the icon.
  /// Defaults to AppTheme.elementColor3 for contrast.
  final Color? iconColor;

  /// Optional custom border radius for the main container.
  /// Defaults to 24.0.
  final double? mainBorderRadius;

  /// Optional size for the icon itself.
  /// Defaults to 24.0.
  final double? iconSize;

  const LightItem7({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.svgAsset,
    this.onTap,
    this.backgroundColor,
    this.titleColor,
    this.descriptionColor,
    this.iconColor,
    this.mainBorderRadius,
    this.iconSize,
  });

  @override
  State<LightItem7> createState() => _LightItem7State();
}

class _LightItem7State extends State<LightItem7> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Nu mai schimb culoarea la hover, doar iconita
    final Color effectiveBackgroundColor = widget.backgroundColor ?? AppTheme.backgroundColor2;
    final Color effectiveTitleColor = widget.titleColor ?? AppTheme.elementColor2;
    final Color effectiveDescriptionColor = widget.descriptionColor ?? AppTheme.elementColor1;
    final Color effectiveIconColor = AppTheme.elementColor2;

    final double effectiveMainBorderRadius = widget.mainBorderRadius ?? AppTheme.borderRadiusSmall;
    final double itemHeight = 64.0;
    final double textColumnSpacing = AppTheme.tinyGap-1;
    final double internalRowSpacing = AppTheme.mediumGap;
    final EdgeInsetsGeometry mainPadding = const EdgeInsets.only(top: 8, left: 16, right: 8, bottom: 8);
    final TextStyle titleStyle = AppTheme.safeOutfit(
      color: effectiveTitleColor,
      fontSize: AppTheme.fontSizeMedium,
      fontWeight: FontWeight.w600,
    );
    final TextStyle descriptionStyle = AppTheme.safeOutfit(
      color: effectiveDescriptionColor,
      fontSize: AppTheme.fontSizeSmall,
      fontWeight: FontWeight.w500,
    );

    // Iconita: userIcon mereu vizibila, restul doar la hover
    final bool hasIcon = (widget.svgAsset != null || widget.icon != null) &&
        (widget.svgAsset == 'assets/userIcon.svg' || _isHovered);
    String? effectiveSvgAsset;
    if (widget.svgAsset != null) {
      effectiveSvgAsset = widget.svgAsset;
    }

    Widget iconButton = hasIcon ? Container(
      width: 48.0,
      height: 48.0,
      padding: const EdgeInsets.all(12),
      child: Center(
        child: SizedBox(
          width: 24.0,
          height: 24.0,
          child: effectiveSvgAsset != null
              ? SvgPicture.asset(
                  effectiveSvgAsset,
                  width: 24.0,
                  height: 24.0,
                  colorFilter: ColorFilter.mode(effectiveIconColor, BlendMode.srcIn),
                  fit: BoxFit.contain,
                )
              : widget.icon != null
                  ? Icon(
                      widget.icon,
                      size: 24.0,
                      color: effectiveIconColor,
                    )
                  : Container(),
        ),
      ),
    ) : Container();

    Widget content = Container(
      width: double.infinity,
      height: itemHeight,
      padding: mainPadding,
      decoration: ShapeDecoration(
        color: effectiveBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveMainBorderRadius),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: titleStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: textColumnSpacing),
                Text(
                  widget.description,
                  style: descriptionStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          if (hasIcon) SizedBox(width: internalRowSpacing),
          if (hasIcon) iconButton,
        ],
      ),
    );

    // Make the entire item clickable with hover behavior
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: widget.onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(effectiveMainBorderRadius),
                child: content,
              ),
            )
          : content,
    );
  }
}


