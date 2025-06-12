import 'package:broker_app/app_theme.dart';
// lib/components/headers/field_header1.dart

import 'package:flutter/material.dart';

/// A simple header component displaying a single title, typically used for field labels.
///
/// Consists of a single line of text, left-aligned.
class FieldHeader1 extends StatelessWidget {
  /// The title text to display.
  final String title;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor2.
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
    super.key,
    required this.title,
    this.titleColor,
    this.titleStyle,
    this.padding,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveTitleColor = titleColor ?? AppTheme.elementColor2;
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: AppTheme.smallGap);
    final double effectiveHeight = height ?? 21.0;

    final TextStyle defaultStyle = AppTheme.safeOutfit(
      color: effectiveTitleColor,
      fontSize: AppTheme.fontSizeMedium,
      fontWeight: FontWeight.w600,
    );

    final TextStyle effectiveStyle = titleStyle ?? defaultStyle;

    return Container(
      width: double.infinity,
      height: effectiveHeight,
      padding: effectivePadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: effectiveStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

