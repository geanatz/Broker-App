// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme
// lib/components/rows/dynamic_text_data_row.dart

import 'package:flutter/material.dart';
import '../texts/text1.dart';

/// A data row component that displays a list of text values, equally spaced.
///
/// Typically used for table data rows. Has a background color and rounded corners by default.
class DynamicTextDataRow extends StatelessWidget {
  /// A list of strings to display as data values.
  /// The number of values determines the number of columns.
  final List<String> values;

  /// Optional custom text style for the data values.
  /// If null, a default style will be used.
  final TextStyle? valueStyle;

  /// Optional custom color for the text values.
  /// Overrides color in `valueStyle` if both are provided.
  /// Defaults to AppTheme.elementColor2 (0xFF666699).
  final Color? textColor;

  /// Optional padding for the entire data row container.
  /// Defaults to EdgeInsets.symmetric(horizontal: 16, vertical: 8).
  final EdgeInsetsGeometry? rowPadding;

  /// Optional height for the data row container.
  /// Defaults to 40.0.
  final double? rowHeight;

  /// Optional decoration for the data row container.
  /// Defaults to a ShapeDecoration with AppTheme.backgroundColor3 fill and rounded corners.
  final ShapeDecoration? decoration;

  /// Optional background color for the row. Overrides decoration's color if provided.
  final Color? rowBackgroundColor;
  
  /// Optional border radius for the row. Overrides decoration's shape if provided.
  final double? rowBorderRadius;

  /// Optional spacing between the text columns (Expanded widgets).
  /// Defaults to 16.0.
  final double? columnSpacing;

  /// Optional padding for each individual value cell.
  /// Defaults to EdgeInsets.symmetric(horizontal: 8).
  final EdgeInsetsGeometry? cellPadding;

  /// Optional height for each individual value cell's container.
  /// Defaults to 21.0 (from inner container in snippet).
  final double? cellHeight;
  
  /// Optional alignment for text within each cell. Defaults to TextAlign.start.
  final TextAlign? textAlign;
  
  /// Optional callback when the row is tapped.
  final VoidCallback? onTap;

  const DynamicTextDataRow({
    super.key,
    required this.values,
    this.valueStyle,
    this.textColor,
    this.rowPadding,
    this.rowHeight,
    this.decoration,
    this.rowBackgroundColor,
    this.rowBorderRadius,
    this.columnSpacing,
    this.cellPadding,
    this.cellHeight,
    this.textAlign,
    this.onTap,
  }) : assert(values.length > 0, 'Values list cannot be empty');

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveTextColor = textColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final EdgeInsetsGeometry effectiveRowPadding = rowPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8); // AppTheme.paddingMediumWithVerticalSmall
    final double effectiveRowHeight = rowHeight ?? 40.0; // AppTheme.tableDataRowHeight
    final double effectiveColumnSpacing = columnSpacing ?? 16.0; // AppTheme.mediumGap
    final EdgeInsetsGeometry effectiveCellPadding = cellPadding ?? const EdgeInsets.symmetric(horizontal: 8); // AppTheme.smallPadding
    final double effectiveCellHeight = cellHeight ?? 21.0; // From snippet inner container
    final TextAlign effectiveTextAlign = textAlign ?? TextAlign.start;

    final Color effectiveRowBackgroundColor = rowBackgroundColor ?? const Color(0xFFACACD2); // AppTheme.backgroundColor3
    final double effectiveRowBorderRadius = rowBorderRadius ?? 16.0; // AppTheme.borderRadiusMedium


    final ShapeDecoration defaultDecoration = ShapeDecoration(
      color: effectiveRowBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(effectiveRowBorderRadius),
      ),
    );
    final ShapeDecoration effectiveDecoration = decoration ?? defaultDecoration;

    List<Widget> rowChildren = [];
    for (int i = 0; i < values.length; i++) {
      rowChildren.add(
        Expanded(
          child: Container(
            height: effectiveCellHeight,
            padding: effectiveCellPadding,
            alignment: effectiveTextAlign == TextAlign.start ? Alignment.centerLeft :
                       effectiveTextAlign == TextAlign.center ? Alignment.center :
                       Alignment.centerRight,
            child: Text1(
              text: values[i],
              color: effectiveTextColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
      if (i < values.length - 1) {
        rowChildren.add(SizedBox(width: effectiveColumnSpacing));
      }
    }

    Widget rowContent = Container(
      width: double.infinity,
      height: effectiveRowHeight,
      padding: effectiveRowPadding,
      decoration: effectiveDecoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: rowChildren,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(effectiveRowBorderRadius), // Match shape for splash
        child: rowContent,
      );
    }
    return rowContent;
  }
}

