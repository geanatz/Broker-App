// lib/components/headers/widget_header4.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A widget header displaying a title and a description stacked vertically.
/// Both texts are individually centered within their rows, and the rows
/// are aligned according to the `alignment` parameter.
class WidgetHeader4 extends StatelessWidget {
  /// The main title text.
  final String title;

  /// The description text displayed below the title.
  final String description;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor2 (0xFF666699).
  final Color? titleColor;

  /// Optional custom text style for the title.
  final TextStyle? titleStyle;

  /// Optional custom color for the description text.
  /// Defaults to AppTheme.elementColor1 (0xFF8A8AA8).
  final Color? descriptionColor;

  /// Optional custom text style for the description.
  final TextStyle? descriptionStyle;

  /// Optional padding for the header container.
  /// Defaults to EdgeInsets.symmetric(horizontal: 16).
  final EdgeInsetsGeometry? padding;

  /// Optional vertical spacing between the title and description.
  /// Defaults to 0.0, relies on inherent text line heights.
  final double? spacingBetweenTexts;

  /// Alignment for the column of text. Defaults to CrossAxisAlignment.start.
  final CrossAxisAlignment? columnAlignment;


  const WidgetHeader4({
    Key? key,
    required this.title,
    required this.description,
    this.titleColor,
    this.titleStyle,
    this.descriptionColor,
    this.descriptionStyle,
    this.padding,
    this.spacingBetweenTexts,
    this.columnAlignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final Color effectiveDescriptionColor = descriptionColor ?? const Color(0xFF8A8AA8); // AppTheme.elementColor1
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 16); // AppTheme.paddingMedium
    final double effectiveSpacing = spacingBetweenTexts ?? 0.0; // AppTheme.smallGap or tinyGap if preferred
    final CrossAxisAlignment effectiveColumnAlignment = columnAlignment ?? CrossAxisAlignment.start;


    final TextStyle defaultTitleStyle = TextStyle(
      color: effectiveTitleColor,
      fontSize: 19, fontWeight: FontWeight.w500, fontFamily: GoogleFonts.outfit().fontFamily,
    );
    final TextStyle defaultDescriptionStyle = TextStyle(
      color: effectiveDescriptionColor,
      fontSize: 17, fontWeight: FontWeight.w500, fontFamily: GoogleFonts.outfit().fontFamily,
    );

    final TextStyle finalTitleStyle = titleStyle ?? defaultTitleStyle;
    final TextStyle finalDescriptionStyle = descriptionStyle ?? defaultDescriptionStyle;
    
    // The original snippet uses: Column (mainAxisSize: min, mainAxisAlignment: center, crossAxisAlignment: start, spacing: 16)
    // > Container (width: double.infinity, clipBehavior, decoration)
    //   > Column (mainAxisSize: min, mainAxisAlignment: center, crossAxisAlignment: start)
    //     > Row (mainAxisSize: min, mainAxisAlignment: center, crossAxisAlignment: center) > Text (title)
    //     > Row (mainAxisSize: min, mainAxisAlignment: center, crossAxisAlignment: center) > Text (description)
    // The outer Column's spacing:16 is between its children. Here, there's only one child Container.
    // The inner Column's crossAxisAlignment:start means the Rows are left-aligned.
    // The Rows mainAxisAlignment:center is for the Text within them, but since Text is the only child and Row is min size, it's left aligned.
    // So effectively, text is left aligned.
    // I will simplify the structure to a single Column with CrossAxisAlignment.start by default.

    return Container(
      width: double.infinity,
      padding: effectivePadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.center, // From original outer column
        crossAxisAlignment: effectiveColumnAlignment, // Make this configurable
        children: [
          Text(
            title,
            style: finalTitleStyle,
            textAlign: effectiveColumnAlignment == CrossAxisAlignment.center ? TextAlign.center : TextAlign.start,
          ),
          if (description.isNotEmpty) ...[
            SizedBox(height: effectiveSpacing),
            Text(
              description,
              style: finalDescriptionStyle,
              textAlign: effectiveColumnAlignment == CrossAxisAlignment.center ? TextAlign.center : TextAlign.start,
            ),
          ]
        ],
      ),
    );
  }
}