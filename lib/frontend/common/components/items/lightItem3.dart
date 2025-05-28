// lib/components/items/light_item3.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A customizable light-themed item component with a primary title on the left
/// and a secondary description text on the right.
class LightItem3 extends StatelessWidget {
  /// The primary title text displayed on the left.
  final String title;

  /// The secondary description text displayed on the right.
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

  /// Optional width for the container holding the description text.
  /// Defaults to 104.0.
  final double? descriptionContainerWidth;

  /// Optional custom text style for the title.
  /// If provided, this overrides the default title style.
  final TextStyle? titleStyle;

  /// Optional custom text style for the description.
  /// If provided, this overrides the default description style.
  final TextStyle? descriptionStyle;

  const LightItem3({
    Key? key,
    required this.title,
    required this.description,
    this.onTap,
    this.backgroundColor,
    this.titleColor,
    this.descriptionColor,
    this.borderRadius,
    this.descriptionContainerWidth,
    this.titleStyle,
    this.descriptionStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveBackgroundColor = backgroundColor ?? const Color(0xFFC4C4D4); // AppTheme.containerColor1
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final Color effectiveDescriptionColor = descriptionColor ?? const Color(0xFF8A8AA8); // AppTheme.elementColor1
    final double effectiveBorderRadius = borderRadius ?? 24.0; // AppTheme.borderRadiusLarge
    final double itemHeight = 48.0; // AppTheme.itemHeightMedium
    final double horizontalPadding = 16.0; // AppTheme.paddingMedium
    final double effectiveDescriptionContainerWidth = descriptionContainerWidth ?? 104.0;
    final double internalSpacing = 16.0; // AppTheme.mediumGap (original spacing: 16 on Row)

    final TextStyle defaultTitleStyle = TextStyle(
      color: effectiveTitleColor,
      fontSize: 17, // AppTheme.fontSizeMedium
      fontFamily: GoogleFonts.outfit().fontFamily, // AppTheme.fontFamilyPrimary
      fontWeight: FontWeight.w500, // AppTheme.fontWeightMedium
    );
    
    final TextStyle defaultDescriptionStyle = TextStyle(
      color: effectiveDescriptionColor,
      fontSize: 15, // AppTheme.fontSizeSmall
      fontFamily: GoogleFonts.outfit().fontFamily, // AppTheme.fontFamilyPrimary
      fontWeight: FontWeight.w500, // AppTheme.fontWeightMedium
    );

    // Use provided styles or defaults
    final TextStyle effectiveTitleStyle = titleStyle ?? defaultTitleStyle;
    final TextStyle effectiveDescriptionStyle = descriptionStyle ?? defaultDescriptionStyle;

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
                  style: effectiveTitleStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: internalSpacing),
          SizedBox(
            width: effectiveDescriptionContainerWidth,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  description,
                  textAlign: TextAlign.right,
                  style: effectiveDescriptionStyle,
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