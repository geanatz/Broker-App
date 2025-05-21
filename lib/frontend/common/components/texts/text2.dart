// lib/components/text/centered_text_display.dart

import 'package:flutter/material.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A simple component to display a single line of text, horizontally centered.
///
/// The text is housed in a container with configurable padding and height,
/// and centered within the available width.
class CenteredTextDisplay extends StatelessWidget {
  /// The text to display.
  final String text;

  /// Optional custom color for the text.
  /// Defaults to AppTheme.elementColor2 (0xFF666699).
  final Color? textColor;

  /// Optional custom text style.
  /// If null, a default style with AppTheme.elementColor2, fontSize 15,
  /// and fontWeight w500 will be used.
  final TextStyle? textStyle;

  /// Optional padding for the container.
  /// Defaults to EdgeInsets.symmetric(horizontal: 8).
  final EdgeInsetsGeometry? padding;

  /// Optional height for the container.
  /// Defaults to 21.0.
  final double? height;

  const CenteredTextDisplay({
    Key? key,
    required this.text,
    this.textColor,
    this.textStyle,
    this.padding,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveTextColor = textColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 8); // AppTheme.smallPadding
    final double effectiveHeight = height ?? 21.0; // AppTheme.textDisplayHeightSmall

    final TextStyle defaultStyle = TextStyle(
      color: effectiveTextColor,
      fontSize: 15, // AppTheme.fontSizeSmall
      fontFamily: 'Outfit', // AppTheme.fontFamilyPrimary
      fontWeight: FontWeight.w500, // AppTheme.fontWeightMedium
    );
    final TextStyle effectiveStyle = textStyle ?? defaultStyle;

    return Container(
      width: double.infinity, // Takes full width from parent
      height: effectiveHeight,
      padding: effectivePadding,
      child: Row(
        // mainAxisSize: MainAxisSize.min, // Row will expand due to parent Container's width: double.infinity
        mainAxisAlignment: MainAxisAlignment.center, // Centers its content
        crossAxisAlignment: CrossAxisAlignment.center,
        // spacing: 8, // Ineffective
        children: [
          // Original: Container > Row > Text. Simplified to just Text.
          Text(
            text,
            style: effectiveStyle,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center, // Ensure text itself is centered if it wraps
          ),
        ],
      ),
    );
  }
}