import 'package:mat_finance/app_theme.dart';
// lib/components/items/outlined_item6.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A customizable outlined item component with a primary title on the left
/// and an optional icon on the right, housed within a transparent rounded container.
///
/// The main item has a prominent border. The icon container has rounded corners
/// but is transparent by default and has no border.
/// On hover, the background changes to backgroundColor3.
class OutlinedItem6 extends StatefulWidget {
  /// The primary title text.
  final String title;

  /// Optional icon data to display on the right.
  final IconData? icon;

  /// Optional SVG asset path to display on the right (takes precedence over icon).
  final String? svgAsset;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  /// Optional custom background color for the main container (inside the border).
  /// Defaults to transparent.
  final Color? mainBackgroundColor;

  /// Optional custom color for the main border.
  /// Defaults to AppTheme.backgroundColor3 (0xFFACACD2).
  final Color? mainBorderColor;

  /// Optional custom width for the main border.
  /// Defaults to 4.0.
  final double? mainBorderWidth;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor2 (0xFF666699).
  final Color? titleColor;

  /// Optional custom color for the icon.
  /// Defaults to AppTheme.elementColor2 (0xFF666699).
  final Color? iconColor;

  /// Optional custom background color for the icon's immediate container.
  /// Defaults to transparent as per snippet.
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

  const OutlinedItem6({
    super.key,
    required this.title,
    this.icon,
    this.svgAsset,
    this.onTap,
    this.mainBackgroundColor,
    this.mainBorderColor,
    this.mainBorderWidth,
    this.titleColor,
    this.iconColor,
    this.iconContainerColor,
    this.mainBorderRadius,
    this.iconContainerBorderRadius,
    this.iconSize,
  });

  @override
  State<OutlinedItem6> createState() => _OutlinedItem6State();
}

class _OutlinedItem6State extends State<OutlinedItem6> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Use backgroundColor3 on hover, otherwise use the provided color or transparent
    final Color effectiveMainBackgroundColor = _isHovered 
        ? AppTheme.backgroundColor3 
        : (widget.mainBackgroundColor ?? Colors.transparent);
    final Color effectiveMainBorderColor = widget.mainBorderColor ?? AppTheme.backgroundColor3;
    final double effectiveMainBorderWidth = widget.mainBorderWidth ?? 4.0;
    
    // Change text and icon colors on hover: elementColor2 default, elementColor3 on hover
    final Color effectiveTitleColor = _isHovered 
        ? AppTheme.elementColor3 
        : (widget.titleColor ?? AppTheme.elementColor2);
    final Color effectiveIconColor = _isHovered 
        ? AppTheme.elementColor3 
        : (widget.iconColor ?? AppTheme.elementColor2);
        
    final Color effectiveIconContainerColor = widget.iconContainerColor ?? Colors.transparent;

    final double effectiveMainBorderRadius = widget.mainBorderRadius ?? AppTheme.borderRadiusSmall;
    final double effectiveIconContainerBorderRadius = widget.iconContainerBorderRadius ?? AppTheme.borderRadiusTiny;
    final double itemHeight = 64.0;
    final double internalSpacing = AppTheme.mediumGap;
    final double iconContainerSize = 48.0;

    final EdgeInsetsGeometry mainPadding = const EdgeInsets.only(top: AppTheme.smallGap, left: AppTheme.mediumGap, right: AppTheme.smallGap, bottom: AppTheme.smallGap);

    final TextStyle titleStyle = AppTheme.safeOutfit(
      color: effectiveTitleColor,
      fontSize: AppTheme.fontSizeMedium,
      fontWeight: FontWeight.w600,
    );

    // Determine if we should show an icon (either SVG or IconData) - ONLY on hover
    final bool hasIcon = (widget.svgAsset != null || widget.icon != null) && _isHovered;

    Widget content = Container(
      width: double.infinity,
      height: itemHeight,
      padding: mainPadding,
      decoration: ShapeDecoration(
        color: effectiveMainBackgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: effectiveMainBorderWidth,
            color: effectiveMainBorderColor,
          ),
          borderRadius: BorderRadius.circular(effectiveMainBorderRadius),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox( // Original snippet has this inner container with height: 48
              height: 48,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: titleStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          if (hasIcon) ...[
            SizedBox(width: internalSpacing),
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
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
          ],
        ],
      ),
    );

    if (widget.onTap != null) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(effectiveMainBorderRadius),
            customBorder: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(effectiveMainBorderRadius),
            ),
            child: content,
          ),
        ),
      );
    }
    return content;
  }
}


