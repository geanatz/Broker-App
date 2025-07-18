// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme
// lib/components/items/light_item4.dart

import 'package:flutter/material.dart';

/// A customizable light-themed item component with a primary title and a
/// secondary description text displayed below it.
class LightItem4 extends StatelessWidget {
  /// The primary title text.
  final String title;

  /// The secondary description text displayed below the title.
  final String description;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  /// Optional custom background color for the container.
  /// Defaults to AppTheme.containerColor1 (0xFFC4C4D4) if not provided.
  final Color? backgroundColor;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor2 (0xFF666699) if not provided.
  final Color? titleColor;

  /// Optional custom color for the description text.
  /// Defaults to AppTheme.elementColor1 (0xFF8A8AA8) if not provided.
  final Color? descriptionColor;

  /// Optional custom border radius for the container.
  /// Defaults to 24.0 if not provided.
  final double? borderRadius;

  /// Optional custom height for the container.
  /// Defaults to 64.0 if not provided.
  final double? itemHeight;

  const LightItem4({
    super.key,
    required this.title,
    required this.description,
    this.onTap,
    this.backgroundColor,
    this.titleColor,
    this.descriptionColor,
    this.borderRadius,
    this.itemHeight,
  });

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveBackgroundColor = backgroundColor ?? const Color(0xFFC4C4D4); // AppTheme.containerColor1
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final Color effectiveDescriptionColor = descriptionColor ?? const Color(0xFF8A8AA8); // AppTheme.elementColor1
    final double effectiveBorderRadius = borderRadius ?? 24.0; // AppTheme.borderRadiusLarge
    final double effectiveItemHeight = itemHeight ?? 64.0; // AppTheme.itemHeightLarge
    final double textSpacing = 4.0; // AppTheme.tinyGap

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

    final EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    Widget content = Container(
      width: double.infinity,
      height: effectiveItemHeight,
      padding: padding,
      decoration: ShapeDecoration(
        color: effectiveBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
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
                  SizedBox(height: textSpacing),
                  Text(
                    description,
                    style: descriptionStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
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
