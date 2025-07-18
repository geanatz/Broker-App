// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme
// lib/components/items/light_item5.dart

import 'package:flutter/material.dart';

/// A customizable light-themed item component with a primary title on the left
/// and an optional icon on the right.
class LightItem5 extends StatelessWidget {
  /// The primary title text displayed on the left.
  final String title;

  /// Optional icon data to display on the right.
  final IconData? icon;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  /// Optional custom background color for the container.
  /// Defaults to AppTheme.containerColor1 (0xFFC4C4D4) if not provided.
  final Color? backgroundColor;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor2 (0xFF666699) if not provided.
  final Color? titleColor;

  /// Optional custom color for the icon.
  /// Defaults to AppTheme.elementColor2 (0xFF666699) if not provided.
  final Color? iconColor;

  /// Optional custom border radius for the container.
  /// Defaults to 24.0 if not provided.
  final double? borderRadius;

  /// Optional size for the icon.
  /// Defaults to 24.0.
  final double? iconSize;

  const LightItem5({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
    this.borderRadius,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveBackgroundColor = backgroundColor ?? const Color(0xFFC4C4D4); // AppTheme.containerColor1
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final Color effectiveIconColor = iconColor ?? const Color(0xFF666699); // AppTheme.elementColor2 (consistent with title)
    final double effectiveBorderRadius = borderRadius ?? 24.0; // AppTheme.borderRadiusLarge
    final double itemHeight = 48.0; // AppTheme.itemHeightMedium
    final double horizontalPadding = 16.0; // AppTheme.paddingMedium
    final double effectiveIconSize = iconSize ?? 24.0; // AppTheme.iconSizeSmall
    final double internalSpacing = 16.0; // AppTheme.mediumGap

    final TextStyle titleStyle = TextStyle(
      color: effectiveTitleColor,
      fontSize: 17, // AppTheme.fontSizeMedium
      fontFamily: 'Outfit', // AppTheme.fontFamilyPrimary
      fontWeight: FontWeight.w500, // AppTheme.fontWeightMedium
    );

    Widget content = Container(
      width: double.infinity,
      height: itemHeight,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: ShapeDecoration(
        color: effectiveBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: titleStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (icon != null) ...[
            SizedBox(width: internalSpacing),
            SizedBox(
              width: effectiveIconSize,
              height: effectiveIconSize,
              child: Icon(
                icon,
                size: effectiveIconSize,
                color: effectiveIconColor,
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
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          child: content,
        ),
      );
    }
    return content;
  }
}
