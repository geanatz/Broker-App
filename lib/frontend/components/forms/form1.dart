import 'package:mat_finance/app_theme.dart'; // Import AppTheme instead of placeholder
// lib/components/forms/form_container1.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../fields/dropdown_field1.dart';
import '../fields/input_field1.dart';

/// A form container with 2 rows:
/// - First row: 2 dropdown fields (Bank, Credit/Income Type)
/// - Second row: 2 input fields
class Form1 extends StatefulWidget {
  // First row - dropdown fields
  /// Title for the top-left dropdown field
  final String titleR1F1;
  
  /// Currently selected value for the top-left dropdown field
  final String? valueR1F1;
  
  /// List of dropdown items for the top-left field
  final List<DropdownMenuItem<String>> itemsR1F1;
  
  /// Callback when the top-left dropdown value changes
  final ValueChanged<String?>? onChangedR1F1;
  
  /// Hint text for the top-left dropdown field
  final String? hintTextR1F1;
  
  /// Title for the top-right dropdown field
  final String titleR1F2;
  
  /// Currently selected value for the top-right dropdown field
  final String? valueR1F2;
  
  /// List of dropdown items for the top-right field
  final List<DropdownMenuItem<String>> itemsR1F2;
  
  /// Callback when the top-right dropdown value changes
  final ValueChanged<String?>? onChangedR1F2;
  
  /// Hint text for the top-right dropdown field
  final String? hintTextR1F2;

  // Second row - input fields
  /// Title for the bottom-left input field
  final String titleR2F1;
  
  /// Text controller for the bottom-left input field
  final TextEditingController? controllerR2F1;
  
  /// Hint text for the bottom-left input field
  final String? hintTextR2F1;
  
  /// Keyboard type for the bottom-left input field
  final TextInputType? keyboardTypeR2F1;
  
  /// Optional suffix text for the bottom-left input field
  final String? suffixTextR2F1;
  
  /// Title for the bottom-right input field
  final String titleR2F2;
  
  /// Text controller for the bottom-right input field
  final TextEditingController? controllerR2F2;
  
  /// Hint text for the bottom-right input field
  final String? hintTextR2F2;
  
  /// Keyboard type for the bottom-right input field
  final TextInputType? keyboardTypeR2F2;
  
  /// Optional suffix text for the bottom-right input field
  final String? suffixTextR2F2;

  /// Optional suffix text color for the bottom-right input field
  final Color? suffixTextColorR2F2;

  // Container styling
  /// Optional background color for the outer container
  final Color? containerColor;
  
  /// Optional border radius for the outer container
  final double? borderRadius;
  
  /// Optional padding for the outer container
  final EdgeInsetsGeometry? padding;
  
  /// Optional spacing between rows
  final double? rowSpacing;
  
  /// Optional spacing between fields in the same row
  final double? fieldSpacing;

  // Close button
  /// Optional callback for close button
  final VoidCallback? onClose;

  const Form1({
    super.key,
    this.titleR1F1 = 'Banca',
    this.valueR1F1,
    required this.itemsR1F1,
    this.onChangedR1F1,
    this.hintTextR1F1 = 'Selecteaza',
    this.titleR1F2 = 'Tip credit',
    this.valueR1F2,
    required this.itemsR1F2,
    this.onChangedR1F2,
    this.hintTextR1F2 = 'Selecteaza',
    this.titleR2F1 = 'Sold',
    this.controllerR2F1,
    this.hintTextR2F1 = '0',
    this.keyboardTypeR2F1 = TextInputType.number,
    this.suffixTextR2F1,
    this.titleR2F2 = 'Rata',
    this.controllerR2F2,
    this.hintTextR2F2 = '0',
    this.keyboardTypeR2F2 = TextInputType.number,
    this.suffixTextR2F2,
    this.suffixTextColorR2F2,
    this.containerColor,
    this.borderRadius,
    this.padding,
    this.rowSpacing,
    this.fieldSpacing,
    this.onClose,
  });

  @override
  State<Form1> createState() => _Form1State();
}

class _Form1State extends State<Form1> {
  bool _isHovered = false;

  /// Custom input formatter for years/months format (e.g., "1/4", "2/7")
  static final TextInputFormatter _yearsMonthsFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[0-9/]'),
  );

  @override
  Widget build(BuildContext context) {
    final Color effectiveContainerColor = widget.containerColor ?? AppTheme.backgroundColor2;
    final double effectiveBorderRadius = widget.borderRadius ?? AppTheme.borderRadiusSmall;
    final EdgeInsetsGeometry effectivePadding = widget.padding ?? const EdgeInsets.all(8.0);
    final double effectiveRowSpacing = widget.rowSpacing ?? AppTheme.smallGap;
    final double effectiveFieldSpacing = widget.fieldSpacing ?? AppTheme.smallGap;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: effectivePadding,
            decoration: BoxDecoration(
              color: effectiveContainerColor,
              borderRadius: BorderRadius.circular(effectiveBorderRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // First row - dropdown fields
                Row(
                  children: [
                    Expanded(
                      child: DropdownField1<String>(
                        title: widget.titleR1F1,
                        value: widget.valueR1F1,
                        items: widget.itemsR1F1,
                        onChanged: widget.onChangedR1F1,
                        hintText: widget.hintTextR1F1,
                      ),
                    ),
                    SizedBox(width: effectiveFieldSpacing),
                    Expanded(
                      child: DropdownField1<String>(
                        title: widget.titleR1F2,
                        value: widget.valueR1F2,
                        items: widget.itemsR1F2,
                        onChanged: widget.onChangedR1F2,
                        hintText: widget.hintTextR1F2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: effectiveRowSpacing),
                // Second row - input fields
                Row(
                  children: [
                    Expanded(
                      child: InputField1(
                        title: widget.titleR2F1,
                        controller: widget.controllerR2F1,
                        hintText: widget.hintTextR2F1,
                        keyboardType: widget.keyboardTypeR2F1,
                        enableCommaFormatting: widget.suffixTextR2F1 == null,
                        enableKTransformation: widget.suffixTextR2F1 == null,
                        suffixText: widget.suffixTextR2F1,
                      ),
                    ),
                    SizedBox(width: effectiveFieldSpacing),
                    Expanded(
                      child: InputField1(
                        title: widget.titleR2F2,
                        controller: widget.controllerR2F2,
                        hintText: widget.hintTextR2F2,
                        keyboardType: widget.keyboardTypeR2F2,
                        enableCommaFormatting: widget.titleR2F2 == 'Vechime' ? false : (widget.suffixTextR2F2 == null),
                        enableKTransformation: widget.titleR2F2 == 'Vechime' ? false : (widget.suffixTextR2F2 == null),
                        inputFormatters: widget.titleR2F2 == 'Vechime' ? [_yearsMonthsFormatter] : null,
                        suffixText: widget.suffixTextR2F2,
                        suffixTextColor: widget.suffixTextColorR2F2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Close button - only visible on hover
          if (widget.onClose != null && _isHovered)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: widget.onClose,
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: AppTheme.elementColor2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

