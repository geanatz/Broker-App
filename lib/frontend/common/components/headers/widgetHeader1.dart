// lib/components/headers/widget_header1.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../appTheme.dart';

/// A simple widget header displaying a single title.
///
/// This header is typically used for section titles and consists of a single
/// line of text, left-aligned within a padded container.
class WidgetHeader1 extends StatelessWidget {
  /// The title text to display.
  final String title;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor1.
  final Color? titleColor;

  /// Optional custom text style for the title.
  /// If null, a default style with AppTheme.elementColor1, fontSize 19,
  /// and fontWeight w600 will be used.
  final TextStyle? titleStyle;

  /// Optional padding for the header container.
  /// Defaults to EdgeInsets.symmetric(horizontal: 16).
  final EdgeInsetsGeometry? padding;

  /// Optional height for the container holding the title text.
  /// Defaults to 24.0.
  final double? titleContainerHeight;

  const WidgetHeader1({
    super.key,
    required this.title,
    this.titleColor,
    this.titleStyle,
    this.padding,
    this.titleContainerHeight,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveTitleColor = titleColor ?? AppTheme.elementColor1;
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap);
    final double effectiveTitleContainerHeight = titleContainerHeight ?? 24.0;

    final TextStyle defaultTitleStyle = GoogleFonts.outfit(
      color: effectiveTitleColor,
      fontSize: AppTheme.fontSizeLarge,
      fontWeight: FontWeight.w600,
    );

    final TextStyle effectiveTitleStyle = titleStyle ?? defaultTitleStyle;

    return Container(
      width: double.infinity,
      padding: effectivePadding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: effectiveTitleContainerHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: effectiveTitleStyle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}