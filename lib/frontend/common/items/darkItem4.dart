// lib/components/items/dark_item4.dart

import 'package:flutter/material.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A customizable item component with a primary title and a secondary
/// description text displayed below it.
///
/// The item has a pill shape, a height of 64, and the text content
/// (title and description) is vertically centered within the item.
class DarkItem4 extends StatelessWidget {
  /// The primary title text.
  final String title;

  /// The secondary description text displayed below the title.
  final String description;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  /// Optional custom background color for the container.
  /// Defaults to AppTheme.containerColor2 (0xFFACACD2) if not provided.
  final Color? backgroundColor;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor3 (0xFF4D4D80) if not provided.
  final Color? titleColor;

  /// Optional custom color for the description text.
  /// Defaults to AppTheme.elementColor2 (0xFF666699) if not provided.
  final Color? descriptionColor;

  /// Optional custom border radius for the container.
  /// Defaults to 24.0 if not provided.
  final double? borderRadius;

  /// Optional custom height for the container.
  /// Defaults to 64.0 if not provided.
  final double? itemHeight;

  const DarkItem4({
    Key? key,
    required this.title,
    required this.description,
    this.onTap,
    this.backgroundColor,
    this.titleColor,
    this.descriptionColor,
    this.borderRadius,
    this.itemHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveBackgroundColor = backgroundColor ?? const Color(0xFFACACD2); // AppTheme.containerColor2
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF4D4D80); // AppTheme.elementColor3
    final Color effectiveDescriptionColor = descriptionColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final double effectiveBorderRadius = borderRadius ?? 24.0; // AppTheme.borderRadiusLarge
    final double effectiveItemHeight = itemHeight ?? 64.0; // AppTheme.itemHeightLarge
    final double textSpacing = 4.0; // AppTheme.tinyGap (original spacing: 4 in Column)

    // Text Styles (Consider moving to AppTheme)
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

    // Padding (Consider moving to AppTheme)
    final EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8); // AppTheme.paddingMediumWithVerticalSmall

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
            child: Container(
              // height: 48, // Inner container height from original, contributes to centering
              // clipBehavior: Clip.antiAlias, // Not needed
              // decoration: BoxDecoration(), // Not needed
              child: Column(
                mainAxisSize: MainAxisSize.min, // Important for centering
                mainAxisAlignment: MainAxisAlignment.center, // Vertically centers the Column content
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