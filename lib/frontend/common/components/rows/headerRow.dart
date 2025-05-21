// lib/components/rows/dynamic_text_header_row.dart

import 'package:flutter/material.dart';
import '../texts/text1.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A header row component that displays a list of text labels, equally spaced.
///
/// Typically used for table headers. The row itself is transparent by default
/// but has padding and a shape definition that can be styled.
class DynamicTextHeaderRow extends StatelessWidget {
  /// A list of strings to display as header titles.
  /// The number of titles determines the number of columns.
  final List<String> titles;

  /// Optional custom text style for the header titles.
  /// If null, a default style will be used.
  final TextStyle? titleStyle;

  /// Optional custom color for the title text.
  /// Overrides color in `titleStyle` if both are provided.
  /// Defaults to AppTheme.elementColor2 (0xFF666699).
  final Color? textColor;

  /// Optional padding for the entire header row container.
  /// Defaults to EdgeInsets.symmetric(horizontal: 16).
  final EdgeInsetsGeometry? rowPadding;

  /// Optional height for the header row container.
  /// Defaults to 21.0.
  final double? rowHeight;

  /// Optional decoration for the header row container.
  /// Defaults to a ShapeDecoration with rounded corners but no fill color.
  final ShapeDecoration? decoration;

  /// Optional spacing between the text columns (Expanded widgets).
  /// Defaults to 16.0.
  final double? columnSpacing;

  /// Optional padding for each individual title cell.
  /// Defaults to EdgeInsets.symmetric(horizontal: 8).
  final EdgeInsetsGeometry? cellPadding;

  /// Optional height for each individual title cell's container.
  /// Defaults to 21.0 (matching rowHeight).
  final double? cellHeight;

  /// Optional alignment for text within each cell. Defaults to TextAlign.start.
  final TextAlign? textAlign;

  const DynamicTextHeaderRow({
    super.key,
    required this.titles,
    this.titleStyle,
    this.textColor,
    this.rowPadding,
    this.rowHeight,
    this.decoration,
    this.columnSpacing,
    this.cellPadding,
    this.cellHeight,
    this.textAlign,
  }) : assert(titles.length > 0, 'Titles list cannot be empty');

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveTextColor = textColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final EdgeInsetsGeometry effectiveRowPadding = rowPadding ?? const EdgeInsets.symmetric(horizontal: 16); // AppTheme.paddingMedium
    final double effectiveRowHeight = rowHeight ?? 21.0; // AppTheme.tableHeaderHeight
    final double effectiveColumnSpacing = columnSpacing ?? 16.0; // AppTheme.mediumGap
    final EdgeInsetsGeometry effectiveCellPadding = cellPadding ?? const EdgeInsets.symmetric(horizontal: 8); // AppTheme.smallPadding
    final double effectiveCellHeight = cellHeight ?? 21.0; // Matches row height
    final TextAlign effectiveTextAlign = textAlign ?? TextAlign.start;

    final TextStyle defaultStyle = TextStyle(
      color: effectiveTextColor,
      fontSize: 15, // AppTheme.fontSizeSmall
      fontFamily: 'Outfit', // AppTheme.fontFamilyPrimary
      fontWeight: FontWeight.w500, // AppTheme.fontWeightMedium
    );
    final TextStyle effectiveTitleStyle = titleStyle ?? defaultStyle;

    final ShapeDecoration defaultDecoration = ShapeDecoration(
      // No background color by default for header, relies on parent or can be customized
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24), // From snippet
      ),
    );
    final ShapeDecoration effectiveDecoration = decoration ?? defaultDecoration;

    List<Widget> Rchildren = [];
    for (int i = 0; i < titles.length; i++) {
      Rchildren.add(
        Expanded(
          child: Container(
            height: effectiveCellHeight, // Ensures consistent height for cells
            padding: effectiveCellPadding, // Padding for each cell's content
            // The inner nested Containers and Rows from the snippet for a single Text
            // are simplified here. The alignment and sizing are handled by Expanded,
            // Container padding/height, and Text's textAlign.
            alignment: effectiveTextAlign == TextAlign.start ? Alignment.centerLeft :
                       effectiveTextAlign == TextAlign.center ? Alignment.center :
                       Alignment.centerRight, // Align text within its cell
            child: LeftAlignedTextDisplay(
              text: titles[i],
              textStyle: effectiveTitleStyle,
              textColor: effectiveTextColor,
              padding: EdgeInsets.zero, // The container already has padding
              height: effectiveCellHeight,
            ),
          ),
        ),
      );
      if (i < titles.length - 1) {
        Rchildren.add(SizedBox(width: effectiveColumnSpacing));
      }
    }

    return Container(
      width: double.infinity,
      height: effectiveRowHeight,
      padding: effectiveRowPadding,
      decoration: effectiveDecoration,
      child: Row(
        mainAxisSize: MainAxisSize.min, // Will expand due to Expanded children
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // From snippet
        crossAxisAlignment: CrossAxisAlignment.center,
        children: Rchildren,
      ),
    );
  }
}