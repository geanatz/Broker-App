// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme
// lib/components/items/outlined_item7.dart

import 'package:flutter/material.dart';

/// A customizable outlined item with title, description, and an optional
/// icon in a transparent, rounded trailing container.
///
/// The main item has a prominent border. The icon container is transparent
/// by default and has no border of its own.
class OutlinedItem7 extends StatelessWidget {
  /// The primary title text.
  final String title;

  /// The secondary description text displayed below the title.
  final String description;

  /// Optional icon data to display on the right.
  final IconData? icon;

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

  /// Optional custom color for the description text.
  /// Defaults to AppTheme.elementColor1 (0xFF8A8AA8).
  final Color? descriptionColor;

  /// Optional custom color for the icon.
  /// Defaults to AppTheme.elementColor2 (0xFF666699).
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

  const OutlinedItem7({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.onTap,
    this.mainBackgroundColor,
    this.mainBorderColor,
    this.mainBorderWidth,
    this.titleColor,
    this.descriptionColor,
    this.iconColor,
    this.iconContainerColor,
    this.mainBorderRadius,
    this.iconContainerBorderRadius,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveMainBackgroundColor = mainBackgroundColor ?? Colors.transparent;
    final Color effectiveMainBorderColor = mainBorderColor ?? const Color(0xFFACACD2); // AppTheme.backgroundColor3
    final double effectiveMainBorderWidth = mainBorderWidth ?? 4.0; // AppTheme.borderWidthThick
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final Color effectiveDescriptionColor = descriptionColor ?? const Color(0xFF8A8AA8); // AppTheme.elementColor1
    final Color effectiveIconColor = iconColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final Color effectiveIconContainerColor = iconContainerColor ?? Colors.transparent; // Snippet shows no color

    final double effectiveMainBorderRadius = mainBorderRadius ?? 24.0; // AppTheme.borderRadiusLarge
    final double effectiveIconContainerBorderRadius = iconContainerBorderRadius ?? 16.0; // AppTheme.borderRadiusMedium
    final double itemHeight = 64.0; // AppTheme.itemHeightLarge
    final double effectiveIconSize = iconSize ?? 24.0; // AppTheme.iconSizeSmall
    final double textColumnSpacing = 4.0; // AppTheme.tinyGap
    final double internalRowSpacing = 16.0; // AppTheme.mediumGap
    final double iconContainerSize = 48.0;

    final EdgeInsetsGeometry mainPadding = const EdgeInsets.only(top: 8, left: 16, right: 8, bottom: 8);

    final TextStyle titleStyle = TextStyle(
      color: effectiveTitleColor,
      fontSize: 17, // AppTheme.fontSizeMedium
      fontFamily: 'Outfit', // AppTheme.fontFamilyPrimary
      fontWeight: FontWeight.w600, // AppTheme.fontWeightSemiBold
    );
    final TextStyle descriptionStyle = TextStyle(
      color: effectiveDescriptionColor,
      fontSize: 15, // AppTheme.fontSizeSmall
      fontFamily: 'Outfit', // AppTheme.fontFamilyPrimary
      fontWeight: FontWeight.w500, // AppTheme.fontWeightMedium
    );

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
                    title,
                    style: titleStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: textColumnSpacing),
                  Text(
                    description,
                    style: descriptionStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          if (icon != null) ...[
            SizedBox(width: internalRowSpacing),
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: ShapeDecoration(
                color: effectiveIconContainerColor, // Transparent by default
                shape: RoundedRectangleBorder(
                  // No border for icon container as per snippet
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
          customBorder: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(effectiveMainBorderRadius),
          ),
          child: content,
        ),
      );
    }
    return content;
  }
}

