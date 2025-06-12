// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme
// lib/components/rows/fixed_title_expanded_alt_text.dart

import 'package:flutter/material.dart';

/// A row component displaying a fixed-width title on the left, a small space,
/// and an alternative text on the right that expands to fill available space.
/// The alternative text content itself is left-aligned within its expanded area.
class FixedTitleExpandedAltText extends StatelessWidget {
  /// The title text displayed on the left (fixed width).
  final String title;

  /// The alternative text displayed on the right (expands).
  final String altText;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor2 (0xFF666699).
  final Color? titleColor;

  /// Optional custom text style for the title.
  final TextStyle? titleStyle;

  /// Optional custom color for the alternative text.
  /// Defaults to AppTheme.elementColor2 (0xFF666699), but with different weight.
  final Color? altTextColor;

  /// Optional custom text style for the alternative text.
  final TextStyle? altTextStyle;

  /// Optional padding for the main container.
  /// Defaults to EdgeInsets.symmetric(horizontal: 16).
  final EdgeInsetsGeometry? padding;

  /// Optional height for the container.
  /// Defaults to 21.0.
  final double? height;

  /// Optional spacing between the title and the alternative text.
  /// Defaults to 4.0.
  final double? spacing;

  const FixedTitleExpandedAltText({
    super.key,
    required this.title,
    required this.altText,
    this.titleColor,
    this.titleStyle,
    this.altTextColor,
    this.altTextStyle,
    this.padding,
    this.height,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final Color effectiveAltTextColor = altTextColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 16); // AppTheme.paddingMedium
    final double effectiveHeight = height ?? 21.0; // AppTheme.rowItemHeightSmall
    final double effectiveSpacing = spacing ?? 4.0; // AppTheme.tinyGap

    // Default styles based on snippet
    final TextStyle defaultTitleStyle = TextStyle(
      color: effectiveTitleColor,
      fontSize: 17, // AppTheme.fontSizeMedium
      fontFamily: 'Outfit', // AppTheme.fontFamilyPrimary
      fontWeight: FontWeight.w500, // AppTheme.fontWeightMedium
    );
    final TextStyle defaultAltTextStyle = TextStyle(
      color: effectiveAltTextColor,
      fontSize: 17, // AppTheme.fontSizeMedium
      fontFamily: 'Outfit', // AppTheme.fontFamilyPrimary
      fontWeight: FontWeight.w600, // AppTheme.fontWeightSemiBold
    );

    final TextStyle finalTitleStyle = titleStyle ?? defaultTitleStyle;
    final TextStyle finalAltTextStyle = altTextStyle ?? defaultAltTextStyle;

    return Container(
      width: double.infinity,
      height: effectiveHeight,
      padding: effectivePadding,
      child: Row(
        // mainAxisSize: MainAxisSize.min, // Row will expand due to Expanded child
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title part (not expanded)
          // Original: Container > Row > Text. Simplified.
          Text(
            title,
            style: finalTitleStyle,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(width: effectiveSpacing), // Implements original Row's spacing: 4
          // AltText part (expanded)
          Expanded(
            // Original: Container > Row > Text. Simplified.
            // The inner Row had mainAxisAlignment.start, which is default for Text in Expanded.
            child: Text(
              altText,
              style: finalAltTextStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
