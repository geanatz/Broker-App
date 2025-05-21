// lib/components/items/light_item2.dart

import 'package:flutter/material.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A customizable light-themed item component with a pill shape, larger height,
/// and a single, vertically centered title.
class LightItem2 extends StatelessWidget {
  /// The text label to display inside the item.
  final String title;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  /// Optional custom background color for the container.
  /// Defaults to AppTheme.containerColor1 (0xFFC4C4D4) if not provided.
  final Color? backgroundColor;

  /// Optional custom color for the text label.
  /// Defaults to AppTheme.elementColor2 (0xFF666699) if not provided.
  final Color? titleColor;

  /// Optional custom border radius for the container.
  /// Defaults to 24.0 if not provided.
  final double? borderRadius;

  /// Optional custom height for the container.
  /// Defaults to 64.0 if not provided.
  final double? itemHeight;

  const LightItem2({
    Key? key,
    required this.title,
    this.onTap,
    this.backgroundColor,
    this.titleColor,
    this.borderRadius,
    this.itemHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveBackgroundColor = backgroundColor ?? const Color(0xFFC4C4D4); // AppTheme.containerColor1
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final double effectiveBorderRadius = borderRadius ?? 24.0; // AppTheme.borderRadiusLarge
    final double effectiveItemHeight = itemHeight ?? 64.0; // AppTheme.itemHeightLarge

    // Text Style (Consider moving to AppTheme)
    final TextStyle titleStyle = TextStyle(
      color: effectiveTitleColor,
      fontSize: 17, // AppTheme.fontSizeMedium
      fontFamily: 'Outfit', // AppTheme.fontFamilyPrimary
      fontWeight: FontWeight.w600, // AppTheme.fontWeightSemiBold
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
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