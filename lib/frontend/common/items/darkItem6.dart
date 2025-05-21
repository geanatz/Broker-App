// lib/components/items/dark_item6.dart

import 'package:flutter/material.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A customizable item component with a primary title on the left
/// and an optional icon on the right, housed within a padded square container.
///
/// The item has a specific padding and a height of 64.
/// The icon container has its own padding and rounded corners.
class DarkItem6 extends StatelessWidget {
  /// The primary title text.
  final String title;

  /// Optional icon data to display on the right.
  final IconData? icon;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  /// Optional custom background color for the main container.
  /// Defaults to AppTheme.containerColor2 (0xFFACACD2) if not provided.
  final Color? backgroundColor;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor3 (0xFF4D4D80) if not provided.
  final Color? titleColor;

  /// Optional custom color for the icon.
  /// Defaults to AppTheme.elementColor3 (0xFF4D4D80) if not provided.
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

  const DarkItem6({
    Key? key,
    required this.title,
    this.icon,
    this.onTap,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
    this.iconContainerColor, // Original snippet had no color here, so transparent default
    this.mainBorderRadius,
    this.iconContainerBorderRadius,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveBackgroundColor = backgroundColor ?? const Color(0xFFACACD2); // AppTheme.containerColor2
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF4D4D80); // AppTheme.elementColor3
    final Color effectiveIconColor = iconColor ?? const Color(0xFF4D4D80); // AppTheme.elementColor3 (or dedicated icon color)
    final Color effectiveIconContainerColor = iconContainerColor ?? Colors.transparent; // No color in original for this
    final double effectiveMainBorderRadius = mainBorderRadius ?? 24.0; // AppTheme.borderRadiusLarge
    final double effectiveIconContainerBorderRadius = iconContainerBorderRadius ?? 16.0; // AppTheme.borderRadiusMedium
    final double itemHeight = 64.0; // AppTheme.itemHeightLarge
    final double effectiveIconSize = iconSize ?? 24.0; // AppTheme.iconSizeSmall
    final double internalSpacing = 16.0; // AppTheme.mediumGap (original spacing: 16 on Row)

    // Specific padding for the main container from snippet
    final EdgeInsetsGeometry mainPadding = const EdgeInsets.only(top: 8, left: 16, right: 8, bottom: 8);
    // Specific padding for the icon container from snippet

    final double iconContainerSize = 48.0;


    // Text Style (Consider moving to AppTheme)
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              // height: 48, // Inner container height from original
              // clipBehavior: Clip.antiAlias, // Not needed
              // decoration: BoxDecoration(), // Not needed
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
            SizedBox(width: internalSpacing), // Original spacing: 16
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: ShapeDecoration(
                color: effectiveIconContainerColor, // Can be customized
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(effectiveIconContainerBorderRadius),
                ),
              ),
              child: Center( // To center the icon within the 48x48 area
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
      // To make the whole item tappable. If only icon should be, InkWell needs to be on icon.
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