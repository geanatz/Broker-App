// lib/components/items/dark_item3.dart

import 'package:flutter/material.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A customizable item component with a primary title on the left
/// and a secondary description text on the right.
///
/// The item has a pill shape, and the description text is aligned to the right
/// within a container of a predefined width.
class DarkItem3 extends StatelessWidget {
  /// The primary title text displayed on the left.
  final String title;

  /// The secondary description text displayed on the right.
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

  /// Optional width for the container holding the description text.
  /// Defaults to 104.0.
  final double? descriptionContainerWidth;


  const DarkItem3({
    Key? key,
    required this.title,
    required this.description,
    this.onTap,
    this.backgroundColor,
    this.titleColor,
    this.descriptionColor,
    this.borderRadius,
    this.descriptionContainerWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveBackgroundColor = backgroundColor ?? const Color(0xFFACACD2); // AppTheme.containerColor2
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF4D4D80); // AppTheme.elementColor3
    final Color effectiveDescriptionColor = descriptionColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final double effectiveBorderRadius = borderRadius ?? 24.0; // AppTheme.borderRadiusLarge
    final double itemHeight = 48.0; // AppTheme.itemHeightMedium
    final double horizontalPadding = 16.0; // AppTheme.paddingMedium
    final double effectiveDescriptionContainerWidth = descriptionContainerWidth ?? 104.0;
    final double internalSpacing = 16.0; // AppTheme.mediumGap (original spacing: 16 on Row)

    // Text Styles (Consider moving to AppTheme)
    final TextStyle titleStyle = TextStyle(
      color: effectiveTitleColor,
      fontSize: 17, // AppTheme.fontSizeMedium
      fontFamily: 'Outfit', // AppTheme.fontFamilyPrimary
      fontWeight: FontWeight.w500, // AppTheme.fontWeightMedium
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
            // clipBehavior: Clip.antiAlias, // Not needed
            // decoration: BoxDecoration(), // Not needed
            child: Row(
              mainAxisSize: MainAxisSize.min, // Allow Expanded to control width
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              // spacing: 10, // Use SizedBox for clarity if needed
              children: [
                Text(
                  title,
                  style: titleStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: internalSpacing), // Represents original spacing: 16
          SizedBox(
            width: effectiveDescriptionContainerWidth,
            // clipBehavior: Clip.antiAlias, // Not needed
            // decoration: BoxDecoration(), // Not needed
            child: Row(
              mainAxisSize: MainAxisSize.min, // To allow end alignment
              mainAxisAlignment: MainAxisAlignment.end, // Aligns text to the end
              crossAxisAlignment: CrossAxisAlignment.center,
              // spacing: 10, // Ineffective for single Text child
              children: [
                // Expanded might be better here if text can be long,
                // but original has fixed width container and right align.
                Text(
                  description,
                  textAlign: TextAlign.right,
                  style: descriptionStyle,
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