import 'package:broker_app/app_theme.dart';
// lib/components/items/dark_item7.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A customizable item component with a primary title, a secondary description
/// below it, and an optional icon on the right housed within a padded container.
///
/// The item has a specific padding and a height of 64. The text content is
/// vertically centered. The icon container has its own padding and rounded corners.
/// Icons are shown only on hover.
class DarkItem7 extends StatefulWidget {
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

  /// Optional callback when the icon is tapped.
  final VoidCallback? onIconTap;

  /// Optional custom background color for the main container.
  /// Defaults to AppTheme.containerColor2.
  final Color? backgroundColor;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor3.
  final Color? titleColor;

  /// Optional custom color for the description text.
  /// Defaults to AppTheme.elementColor2.
  final Color? descriptionColor;

  /// Optional custom color for the icon.
  /// Defaults to AppTheme.elementColor3.
  final Color? iconColor;

  /// Optional custom background color for the icon's immediate container.
  /// Defaults to transparent.
  final Color? iconContainerColor;

  /// Optional custom border radius for the main container.
  /// Defaults to 24.0.
  final double? mainBorderRadius;

  /// Optional custom border radius for the icon's container.
  /// Defaults to 16.0.
  final double? iconContainerBorderRadius;

  /// Optional size for the icon itself.
  /// Defaults to 24.0.
  final double? iconSize;

  const DarkItem7({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.svgAsset,
    this.onTap,
    this.onIconTap,
    this.backgroundColor,
    this.titleColor,
    this.descriptionColor,
    this.iconColor,
    this.iconContainerColor,
    this.mainBorderRadius,
    this.iconContainerBorderRadius,
    this.iconSize,
  });

  @override
  State<DarkItem7> createState() => _DarkItem7State();
}

class _DarkItem7State extends State<DarkItem7> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // DarkItem7 represents focused state - no hover color changes needed
    final Color effectiveBackgroundColor = widget.backgroundColor ?? AppTheme.containerColor2;
    final Color effectiveTitleColor = widget.titleColor ?? AppTheme.elementColor3;
    final Color effectiveDescriptionColor = widget.descriptionColor ?? AppTheme.elementColor2;
    final Color effectiveIconColor = widget.iconColor ?? AppTheme.elementColor3;
    final Color effectiveIconContainerColor = widget.iconContainerColor ?? Colors.transparent;
    final double effectiveMainBorderRadius = widget.mainBorderRadius ?? AppTheme.borderRadiusMedium;
    final double effectiveIconContainerBorderRadius = widget.iconContainerBorderRadius ?? AppTheme.borderRadiusSmall;
    final double itemHeight = 64.0;
    final double textColumnSpacing = AppTheme.tinyGap-1;
    final double internalRowSpacing = AppTheme.mediumGap;
    final double iconContainerSize = 48.0;

    // Specific padding for the main container from snippet
    final EdgeInsetsGeometry mainPadding = const EdgeInsets.only(top: 8, left: 16, right: 8, bottom: 8);

    // Text Styles
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

    // Determine if we should show an icon (either SVG or IconData) - ONLY on hover
    final bool hasIcon = (widget.svgAsset != null || widget.icon != null) && _isHovered;

    Widget iconButton = hasIcon ? GestureDetector(
      onTap: widget.onIconTap,
      child: Container(
        width: iconContainerSize,
        height: iconContainerSize,
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: effectiveIconContainerColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveIconContainerBorderRadius),
          ),
        ),
        child: Center(
            child: SizedBox(
              width: 24.0,
              height: 24.0,
              child: widget.svgAsset != null
                  ? SvgPicture.asset(
                      widget.svgAsset!,
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

