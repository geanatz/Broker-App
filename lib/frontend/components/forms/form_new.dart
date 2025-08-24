import 'package:mat_finance/app_theme.dart'; // Import AppTheme instead of placeholder
// lib/components/forms/form_container_new.dart

import 'package:flutter/material.dart';
import '../fields/dropdown_field1.dart';

/// A simple form container displaying a single row with two dropdown fields.
/// This is the default form used for adding new credit or income entries.
class FormNew extends StatelessWidget {
  /// Title for the first dropdown field (Bank)
  final String titleF1;
  
  /// Currently selected value for the first dropdown field
  final String? valueF1;
  
  /// List of dropdown items for the first field
  final List<DropdownMenuItem<String>> itemsF1;
  
  /// Callback when the first dropdown value changes
  final ValueChanged<String?>? onChangedF1;
  
  /// Hint text for the first dropdown field
  final String? hintTextF1;
  
  /// Title for the second dropdown field (Credit/Income Type)
  final String titleF2;
  
  /// Currently selected value for the second dropdown field
  final String? valueF2;
  
  /// List of dropdown items for the second field
  final List<DropdownMenuItem<String>> itemsF2;
  
  /// Callback when the second dropdown value changes
  final ValueChanged<String?>? onChangedF2;
  
  /// Hint text for the second dropdown field
  final String? hintTextF2;
  
  /// Optional background color for the outer container
  final Color? containerColor;
  
  /// Optional border radius for the outer container
  final double? borderRadius;
  
  /// Optional padding for the outer container
  final EdgeInsetsGeometry? padding;
  
  /// Optional spacing between the two dropdown fields
  final double? fieldSpacing;

  const FormNew({
    super.key,
    this.titleF1 = 'Banca',
    this.valueF1,
    required this.itemsF1,
    this.onChangedF1,
    this.hintTextF1 = 'Selecteaza',
    this.titleF2 = 'Tip credit',
    this.valueF2,
    required this.itemsF2,
    this.onChangedF2,
    this.hintTextF2 = 'Selecteaza',
    this.containerColor,
    this.borderRadius,
    this.padding,
    this.fieldSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveContainerColor = containerColor ?? AppTheme.backgroundColor2;
    final double effectiveBorderRadius = borderRadius ?? AppTheme.borderRadiusSmall;
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.all(8.0);
    final double effectiveFieldSpacing = fieldSpacing ?? AppTheme.smallGap;

    return Container(
      width: double.infinity,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: effectiveContainerColor,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownField1<String>(
              title: titleF1,
              value: valueF1,
              items: itemsF1,
              onChanged: onChangedF1,
              hintText: hintTextF1,
            ),
          ),
          SizedBox(width: effectiveFieldSpacing),
          Expanded(
            child: DropdownField1<String>(
              title: titleF2,
              value: valueF2,
              items: itemsF2,
              onChanged: onChangedF2,
              hintText: hintTextF2,
            ),
          ),
        ],
      ),
    );
  }
}

