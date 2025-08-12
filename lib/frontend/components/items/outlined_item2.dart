// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme
// lib/components/items/outlined_item2.dart

import 'package:flutter/material.dart';

/// A customizable outlined item component with a pill shape, larger height,
/// and a single, vertically centered title.
///
/// The item has a prominent border and a transparent background by default.
class OutlinedItem2 extends StatelessWidget {
  /// The text label to display inside the item.
  final String title;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  /// Optional custom background color for the container (inside the border).
  /// Defaults to transparent.
  final Color? backgroundColor;

  /// Optional custom color for the border.
  /// Defaults to AppTheme.containerColor2 (0xFFACACD2).
  final Color? borderColor;

  /// Optional custom width for the border.
  /// Defaults to 4.0.
  final double? borderWidth;

  /// Optional custom color for the text label.
  /// Defaults to AppTheme.elementColor2 (0xFF666699).
  final Color? titleColor;

  /// Optional custom border radius for the container.
  /// Defaults to 24.0.
  final double? borderRadius;

  /// Optional custom height for the container.
  /// Defaults to 64.0.
  final double? itemHeight;

  const OutlinedItem2({
    super.key,
    required this.title,
    this.onTap,
    this.backgroundColor, // Defaults to transparent
    this.borderColor,
    this.borderWidth,
    this.titleColor,
    this.borderRadius,
    this.itemHeight,
  });

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveBackgroundColor = backgroundColor ?? Colors.transparent;
    final Color effectiveBorderColor = borderColor ?? const Color(0xFFACACD2); // AppTheme.containerColor2
    final double effectiveBorderWidth = borderWidth ?? 4.0; // AppTheme.borderWidthThick
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final double effectiveBorderRadius = borderRadius ?? 24.0; // AppTheme.borderRadiusLarge
    final double effectiveItemHeight = itemHeight ?? 64.0; // AppTheme.itemHeightLarge

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
        color: effectiveBackgroundColor, // For background inside the border
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: effectiveBorderWidth,
            color: effectiveBorderColor,
          ),
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
        color: Colors.transparent, // InkWell splash should be contained by border
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(effectiveBorderRadius), // Match shape
          customBorder: RoundedRectangleBorder( // Ensure splash respects border
             borderRadius: BorderRadius.circular(effectiveBorderRadius),
          ),
          child: content,
        ),
      );
    }
    return content;
  }
}

