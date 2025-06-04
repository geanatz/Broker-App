// lib/frontend/common/components/forms/form3.dart

import 'package:flutter/material.dart';
import '../../appTheme.dart';
import '../fields/dropdownField1.dart';
import '../fields/inputField1.dart';

/// A form container with 2 rows:
/// - First row: 2 dropdown fields (Bank, Credit/Income Type)
/// - Second row: 4 input fields
class Form3 extends StatefulWidget {
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
  /// Title for the first input field in second row
  final String titleR2F1;
  
  /// Text controller for the first input field in second row
  final TextEditingController? controllerR2F1;
  
  /// Hint text for the first input field in second row
  final String? hintTextR2F1;
  
  /// Keyboard type for the first input field in second row
  final TextInputType? keyboardTypeR2F1;
  
  /// Title for the second input field in second row
  final String titleR2F2;
  
  /// Text controller for the second input field in second row
  final TextEditingController? controllerR2F2;
  
  /// Hint text for the second input field in second row
  final String? hintTextR2F2;
  
  /// Keyboard type for the second input field in second row
  final TextInputType? keyboardTypeR2F2;
  
  /// Title for the third input field in second row
  final String titleR2F3;
  
  /// Text controller for the third input field in second row
  final TextEditingController? controllerR2F3;
  
  /// Hint text for the third input field in second row
  final String? hintTextR2F3;
  
  /// Keyboard type for the third input field in second row
  final TextInputType? keyboardTypeR2F3;
  
  /// Optional suffix text color for the third input field (Perioada)
  final Color? suffixTextColorR2F3;
  
  /// Title for the fourth input field in second row
  final String titleR2F4;
  
  /// Currently selected value for the fourth dropdown field
  final String? valueR2F4;
  
  /// List of dropdown items for the fourth field
  final List<DropdownMenuItem<String>> itemsR2F4;
  
  /// Callback when the fourth dropdown value changes
  final ValueChanged<String?>? onChangedR2F4;
  
  /// Hint text for the fourth dropdown field
  final String? hintTextR2F4;

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

  const Form3({
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
    this.titleR2F2 = 'Rata',
    this.controllerR2F2,
    this.hintTextR2F2 = '0',
    this.keyboardTypeR2F2 = TextInputType.number,
    this.titleR2F3 = 'Perioada',
    this.controllerR2F3,
    this.hintTextR2F3 = '0',
    this.keyboardTypeR2F3 = TextInputType.number,
    this.suffixTextColorR2F3,
    this.titleR2F4 = 'Tip rata',
    this.valueR2F4,
    required this.itemsR2F4,
    this.onChangedR2F4,
    this.hintTextR2F4 = 'Selecteaza',
    this.containerColor,
    this.borderRadius,
    this.padding,
    this.rowSpacing,
    this.fieldSpacing,
    this.onClose,
  });

  @override
  State<Form3> createState() => _Form3State();
}

class _Form3State extends State<Form3> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color effectiveContainerColor = widget.containerColor ?? AppTheme.containerColor1;
    final double effectiveBorderRadius = widget.borderRadius ?? AppTheme.borderRadiusMedium;
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
                // Second row - input fields (4 fields)
                Row(
                  children: [
                    Expanded(
                      child: InputField1(
                        title: widget.titleR2F1,
                        controller: widget.controllerR2F1,
                        hintText: widget.hintTextR2F1,
                        keyboardType: widget.keyboardTypeR2F1,
                        enableCommaFormatting: true,
                        enableKTransformation: true,
                      ),
                    ),
                    SizedBox(width: effectiveFieldSpacing),
                    Expanded(
                      child: InputField1(
                        title: widget.titleR2F2,
                        controller: widget.controllerR2F2,
                        hintText: widget.hintTextR2F2,
                        keyboardType: widget.keyboardTypeR2F2,
                        enableCommaFormatting: true,
                        enableKTransformation: true,
                      ),
                    ),
                    SizedBox(width: effectiveFieldSpacing),
                    Expanded(
                      child: InputField1(
                        title: widget.titleR2F3,
                        controller: widget.controllerR2F3,
                        hintText: widget.hintTextR2F3,
                        keyboardType: widget.keyboardTypeR2F3,
                        suffixText: ' luni',
                        suffixTextColor: widget.suffixTextColorR2F3,
                        enableCommaFormatting: false,
                        enableKTransformation: false,
                      ),
                    ),
                    SizedBox(width: effectiveFieldSpacing),
                    Expanded(
                      child: DropdownField1<String>(
                        title: widget.titleR2F4,
                        value: widget.valueR2F4,
                        items: widget.itemsR2F4,
                        onChanged: widget.onChangedR2F4,
                        hintText: widget.hintTextR2F4,
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