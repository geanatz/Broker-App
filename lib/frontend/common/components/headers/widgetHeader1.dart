// lib/components/headers/widget_header1.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A simple widget header displaying a single title.
///
/// This header is typically used for section titles and consists of a single
/// line of text, left-aligned within a padded container.
class WidgetHeader1 extends StatelessWidget {
  /// The title text to display.
  final String title;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor1 (0xFF8A8AA8).
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
    Key? key,
    required this.title,
    this.titleColor,
    this.titleStyle,
    this.padding,
    this.titleContainerHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF8A8AA8); // AppTheme.elementColor1
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 16); // AppTheme.paddingMedium
    final double effectiveTitleContainerHeight = titleContainerHeight ?? 24.0; // AppTheme.headerTitleHeight

    final TextStyle defaultTitleStyle = GoogleFonts.outfit(
      color: effectiveTitleColor,
      fontSize: 19,
      fontWeight: FontWeight.w600,
    );

    final TextStyle effectiveTitleStyle = titleStyle ?? defaultTitleStyle;

    return Container(
      width: double.infinity,
      padding: effectivePadding,
      child: Row(
        // mainAxisSize: MainAxisSize.min, // Not needed with Expanded child
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: effectiveTitleContainerHeight,
              // clipBehavior: Clip.antiAlias, // Not needed for simple text
              // decoration: BoxDecoration(), // Not needed
              child: Row(
                // mainAxisSize: MainAxisSize.min, // Not needed in Expanded
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                // spacing: 10, // Ineffective for single Text child
                children: [
                  Text(
                    title,
                    style: effectiveTitleStyle,
                    overflow: TextOverflow.ellipsis,
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