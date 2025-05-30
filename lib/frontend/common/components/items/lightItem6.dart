// lib/components/items/light_item6.dart

import 'package:flutter/material.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A customizable light-themed item component with a primary title on the left
/// and an optional icon on the right, housed within a differently colored padded square container.
class LightItem6 extends StatelessWidget {
  /// The primary title text.
  final String title;

  /// Optional icon data to display on the right.
  final IconData? icon;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  /// Optional custom background color for the main container.
  /// Defaults to AppTheme.containerColor1 (0xFFC4C4D4).
  final Color? backgroundColor;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor2 (0xFF666699).
  final Color? titleColor;

  /// Optional custom color for the icon.
  /// Defaults to AppTheme.elementColor3 (0xFF4D4D80) for contrast on icon container.
  final Color? iconColor;

  /// Optional custom background color for the icon's immediate container.
  /// Defaults to AppTheme.containerColor2 (0xFFACACD2).
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

  const LightItem6({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
    this.iconContainerColor,
    this.mainBorderRadius,
    this.iconContainerBorderRadius,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveBackgroundColor = backgroundColor ?? const Color(0xFFC4C4D4); // AppTheme.containerColor1
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final Color effectiveIconContainerColor = iconContainerColor ?? const Color(0xFFACACD2); // AppTheme.containerColor2
    final Color effectiveIconColor = iconColor ?? const Color(0xFF4D4D80); // AppTheme.elementColor3 (for contrast)

    final double effectiveMainBorderRadius = mainBorderRadius ?? 24.0; // AppTheme.borderRadiusLarge
    final double effectiveIconContainerBorderRadius = iconContainerBorderRadius ?? 16.0; // AppTheme.borderRadiusMedium
    final double itemHeight = 64.0; // AppTheme.itemHeightLarge
    final double effectiveIconSize = iconSize ?? 24.0; // AppTheme.iconSizeSmall
    final double internalSpacing = 16.0; // AppTheme.mediumGap
    final double iconContainerSize = 48.0;

    final EdgeInsetsGeometry mainPadding = const EdgeInsets.only(top: 8, left: 16, right: 8, bottom: 8);

    final TextStyle titleStyle = TextStyle(
      color: effectiveTitleColor,
      fontSize: 17, // AppTheme.fontSizeMedium
      fontFamily: 'Outfit', // AppTheme.fontFamilyPrimary
      fontWeight: FontWeight.w600, // AppTheme.fontWeightSemiBold
    );

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
            child: SizedBox( // Original snippet has this inner container with height: 48
              height: 48,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: titleStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          if (icon != null) ...[
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
                child: Icon(
                  icon,
                  size: effectiveIconSize,
                  color: effectiveIconColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(effectiveMainBorderRadius),
          child: content,
        ),
      );
    }
    return content;
  }
}