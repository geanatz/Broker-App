// lib/components/texts/text1.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A simple text component with customizable styling.
/// 
/// This component provides a consistent way to display text throughout the app
/// with predefined styling that follows the design system.
class Text1 extends StatelessWidget {
  /// The text content to display.
  final String text;

  /// Optional custom text color.
  /// Defaults to AppTheme.elementColor2 (0xFF666699).
  final Color? color;

  /// Optional custom font size.
  /// Defaults to 17.0 (AppTheme.fontSizeMedium).
  final double? fontSize;

  /// Optional custom font weight.
  /// Defaults to FontWeight.w500 (AppTheme.fontWeightMedium).
  final FontWeight? fontWeight;

  /// Optional text alignment.
  /// Defaults to TextAlign.left.
  final TextAlign? textAlign;

  /// Optional maximum number of lines.
  /// If null, text can wrap to unlimited lines.
  final int? maxLines;

  /// Optional text overflow behavior.
  /// Defaults to TextOverflow.visible.
  final TextOverflow? overflow;

  const Text1({
    Key? key,
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Default values based on AppTheme
    final Color effectiveColor = color ?? const Color(0xFF666699); // AppTheme.elementColor2
    final double effectiveFontSize = fontSize ?? 17.0; // AppTheme.fontSizeMedium
    final FontWeight effectiveFontWeight = fontWeight ?? FontWeight.w500; // AppTheme.fontWeightMedium

    return Text(
      text,
      style: GoogleFonts.outfit(
        color: effectiveColor,
        fontSize: effectiveFontSize,
        fontWeight: effectiveFontWeight,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}