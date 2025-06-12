// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme
// lib/components/headers/field_header2.dart

import 'package:flutter/material.dart';

/// A header component with a main title on the left and an alternative
/// text (e.g., a hint or secondary label) on the right.
class FieldHeader2 extends StatelessWidget {
  /// The main title text.
  final String title;

  /// The alternative text displayed on the right.
  final String altText;

  /// Optional callback when the alternative text is tapped.
  final VoidCallback? onAltTextTap;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor2 (0xFF666699).
  final Color? titleColor;

  /// Optional custom text style for the title.
  final TextStyle? titleStyle;

  /// Optional custom color for the alternative text.
  /// Defaults to AppTheme.elementColor1 (0xFF8A8AA8).
  final Color? altTextColor;

  /// Optional custom text style for the alternative text.
  final TextStyle? altTextStyle;

  /// Optional padding for the header container.
  /// Defaults to EdgeInsets.symmetric(horizontal: 8).
  final EdgeInsetsGeometry? padding;

  /// Optional height for the header container.
  /// Defaults to 21.0.
  final double? height;

  /// Optional spacing between the title and the alternative text.
  /// Defaults to 8.0.
  final double? spacing;

  const FieldHeader2({
    super.key,
    required this.title,
    required this.altText,
    this.onAltTextTap,
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
    final Color effectiveAltTextColor = altTextColor ?? const Color(0xFF8A8AA8); // AppTheme.elementColor1
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 8); // AppTheme.smallPadding
    final double effectiveHeight = height ?? 21.0; // AppTheme.fieldLabelHeight
    final double effectiveSpacing = spacing ?? 8.0; // AppTheme.smallGap

    final TextStyle defaultTitleStyle = TextStyle(
      color: effectiveTitleColor,
      fontSize: 17, fontWeight: FontWeight.w600, fontFamily: 'Outfit', // AppTheme.labelLargeStyle
    );
    final TextStyle defaultAltTextStyle = TextStyle(
      color: effectiveAltTextColor,
      fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Outfit', // AppTheme.labelSmallStyle
    );

    final TextStyle finalTitleStyle = titleStyle ?? defaultTitleStyle;
    final TextStyle finalAltTextStyle = altTextStyle ?? defaultAltTextStyle;

    Widget altTextWidget = Text(
      altText,
      style: finalAltTextStyle,
      overflow: TextOverflow.ellipsis,
    );

    if (onAltTextTap != null) {
      altTextWidget = InkWell(
        onTap: onAltTextTap,
        child: altTextWidget,
      );
    }

    return Container(
      width: double.infinity,
      height: effectiveHeight,
      padding: effectivePadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            // Simplified inner structure for title
            child: Text(
              title,
              style: finalTitleStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: effectiveSpacing), // Implements original Row's spacing: 8
          // Simplified inner structure for altText
          altTextWidget,
        ],
      ),
    );
  }
}
