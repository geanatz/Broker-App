import 'package:mat_finance/app_theme.dart';
// lib/components/texts/text2.dart

import 'package:flutter/material.dart';

/// A simple centered text component with customizable styling.
/// 
/// This component provides a consistent way to display centered text throughout the app
/// with predefined styling that follows the design system.
class Text2 extends StatelessWidget {
  /// The text content to display.
  final String text;

  /// Optional custom text color.
  /// Defaults to AppTheme.elementColor2 (0xFF666699).
  final Color? color;

  /// Optional custom font size.
  /// Defaults to 15.0 (AppTheme.fontSizeSmall).
  final double? fontSize;

  /// Optional custom font weight.
  /// Defaults to FontWeight.w500 (AppTheme.fontWeightMedium).
  final FontWeight? fontWeight;

  /// Optional maximum number of lines.
  /// If null, text can wrap to unlimited lines.
  final int? maxLines;

  /// Optional text overflow behavior.
  /// Defaults to TextOverflow.visible.
  final TextOverflow? overflow;

  const Text2({
    super.key,
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    // Default values based on AppTheme
    final Color effectiveColor = color ?? AppTheme.elementColor2;
    final double effectiveFontSize = fontSize ?? AppTheme.fontSizeSmall;
    final FontWeight effectiveFontWeight = fontWeight ?? FontWeight.w500;

    return Text(
      text,
      style: AppTheme.safeOutfit(
        color: effectiveColor,
        fontSize: effectiveFontSize,
        fontWeight: effectiveFontWeight,
      ),
      textAlign: TextAlign.center,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}


