// lib/components/items/light_item1.dart

import 'package:flutter/material.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A customizable light-themed item component with a pill shape
/// and single text label.
///
/// This component displays a single line of text centered vertically within
/// a container that has a rounded, pill-like shape background.
class LightItem1 extends StatelessWidget {
  /// The text label to display inside the item.
  final String title;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  /// Optional custom background color for the container.
  /// Defaults to AppTheme.containerColor1 (0xFFC4C4D4) if not provided.
  final Color? backgroundColor;

  /// Optional custom color for the text label.
  /// Defaults to AppTheme.elementColor2 (0xFF666699) if not provided.
  final Color? textColor;

  /// Optional custom border radius for the container.
  /// Defaults to 24.0 if not provided.
  final double? borderRadius;

  const LightItem1({
    Key? key,
    required this.title,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveBackgroundColor = backgroundColor ?? const Color(0xFFC4C4D4); // AppTheme.containerColor1
    final Color effectiveTextColor = textColor ?? const Color(0xFF666699); // AppTheme.elementColor2

    final double effectiveBorderRadius = borderRadius ?? 24.0; // AppTheme.borderRadiusLarge
    final double itemHeight = 48.0; // AppTheme.itemHeightMedium
    final double horizontalPadding = 16.0; // AppTheme.paddingMedium

    // Text Style (Consider moving to AppTheme)
    final TextStyle titleStyle = TextStyle(
      color: effectiveTextColor,
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: titleStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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