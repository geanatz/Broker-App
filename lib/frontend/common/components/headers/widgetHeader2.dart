// lib/components/headers/widget_header2.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A widget header displaying a title on the left and an alternative
/// text (e.g., an action like "See All") on the right.
class WidgetHeader2 extends StatelessWidget {
  /// The main title text.
  final String title;

  /// The alternative text displayed on the right.
  final String altText;

  /// Optional callback when the alternative text is tapped.
  final VoidCallback? onAltTextTap;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor1 (0xFF8A8AA8).
  final Color? titleColor;

  /// Optional custom text style for the title.
  final TextStyle? titleStyle;

  /// Optional custom color for the alternative text.
  /// Defaults to AppTheme.elementColor1 (0xFF8A8AA8).
  final Color? altTextColor;

  /// Optional custom text style for the alternative text.
  final TextStyle? altTextStyle;

  /// Optional padding for the header container.
  /// Defaults to EdgeInsets.symmetric(horizontal: 16).
  final EdgeInsetsGeometry? padding;

  /// Optional spacing between the title and the alternative text.
  /// Defaults to 16.0.
  final double? spacing;

  /// Optional height for the container holding the title text.
  /// Defaults to 24.0.
  final double? titleContainerHeight;

  const WidgetHeader2({
    super.key,
    required this.title,
    required this.altText,
    this.onAltTextTap,
    this.titleColor,
    this.titleStyle,
    this.altTextColor,
    this.altTextStyle,
    this.padding,
    this.spacing,
    this.titleContainerHeight,
  });

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF8A8AA8); // AppTheme.elementColor1
    final Color effectiveAltTextColor = altTextColor ?? const Color(0xFF8A8AA8); // AppTheme.elementColor1
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 16); // AppTheme.paddingMedium
    final double effectiveSpacing = spacing ?? 16.0; // AppTheme.mediumGap
    final double effectiveTitleContainerHeight = titleContainerHeight ?? 24.0; // AppTheme.headerTitleHeight

    final TextStyle defaultTitleStyle = TextStyle(
      color: effectiveTitleColor,
      fontSize: 19, fontWeight: FontWeight.w500, fontFamily: GoogleFonts.outfit().fontFamily, // AppTheme.headlineStyle
    );
    final TextStyle defaultAltTextStyle = TextStyle(
      color: effectiveAltTextColor,
      fontSize: 17, fontWeight: FontWeight.w500, fontFamily: GoogleFonts.outfit().fontFamily, // AppTheme.subheadStyle
    );

    final TextStyle effectiveTitleStyle = titleStyle ?? defaultTitleStyle;
    final TextStyle effectiveAltTextStyle = altTextStyle ?? defaultAltTextStyle;

    Widget altTextWidget = Text(
      altText,
      style: effectiveAltTextStyle,
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
      padding: effectivePadding,
      child: Row(
        // mainAxisSize: MainAxisSize.min, // Not needed due to Expanded
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: effectiveTitleContainerHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
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
          SizedBox(width: effectiveSpacing), // Replaces Row's spacing: 16
          // Original had Container > Row > Text for altText, simplified
          altTextWidget,
        ],
      ),
    );
  }
}