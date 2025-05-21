// lib/components/headers/field_header1.dart

import 'package:flutter/material.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A simple header component displaying a single title, typically used for field labels.
///
/// Consists of a single line of text, left-aligned.
class FieldHeader1 extends StatelessWidget {
  /// The title text to display.
  final String title;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor2 (0xFF666699).
  final Color? titleColor;

  /// Optional custom text style for the title.
  /// If null, a default style with AppTheme.elementColor2, fontSize 17,
  /// and fontWeight w600 will be used.
  final TextStyle? titleStyle;

  /// Optional padding for the header container.
  /// Defaults to EdgeInsets.symmetric(horizontal: 8).
  final EdgeInsetsGeometry? padding;

  /// Optional height for the header container.
  /// Defaults to 21.0.
  final double? height;

  const FieldHeader1({
    Key? key,
    required this.title,
    this.titleColor,
    this.titleStyle,
    this.padding,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 8); // AppTheme.smallPadding
    final double effectiveHeight = height ?? 21.0; // AppTheme.fieldLabelHeight

    final TextStyle defaultStyle = TextStyle(
      color: effectiveTitleColor,
      fontSize: 17, // AppTheme.fontSizeMedium
      fontFamily: 'Outfit', // AppTheme.fontFamilyPrimary
      fontWeight: FontWeight.w600, // AppTheme.fontWeightSemiBold
    );

    final TextStyle effectiveStyle = titleStyle ?? defaultStyle;

    return Container(
      width: double.infinity,
      height: effectiveHeight,
      padding: effectivePadding,
      child: Row(
        // mainAxisSize: MainAxisSize.min, // Not needed with Expanded
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        // spacing: 8, // Ineffective, only one Expanded child in this outer Row
        children: [
          Expanded(
            // The inner Container with clipBehavior and BoxDecoration() and its Row
            // with spacing: 10 were simplified as they didn't contribute to the final layout
            // for a single Text element within an Expanded widget.
            child: Text(
              title,
              style: effectiveStyle,
              overflow: TextOverflow.ellipsis, // Good practice
            ),
          ),
        ],
      ),
    );
  }
}