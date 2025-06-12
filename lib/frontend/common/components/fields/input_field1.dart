// lib/components/fields/input_field1.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:broker_app/frontend/common/utils/safe_google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app_theme.dart';

/// A real input field component with a title and TextFormField.
///
/// This component shows a title label above a styled TextFormField
/// that allows real text input.
class InputField1 extends StatefulWidget {
  /// The title label displayed above the input area.
  final String title;

  /// The text controller for the input field.
  final TextEditingController? controller;

  /// Hint text shown when the field is empty.
  final String? hintText;

  /// The keyboard type for the input field.
  final TextInputType? keyboardType;

  /// Whether the field is enabled.
  final bool enabled;

  /// Whether the field is obscured (for passwords).
  final bool obscureText;

  /// Optional icon to display at the end of the input area.
  final IconData? trailingIcon;

  /// Optional callback for trailing icon tap.
  final VoidCallback? onTrailingIconTap;

  /// Optional minimum width for the component. Defaults to 128.
  final double minWidth;

  /// Optional overall height for the component. Defaults to 72.
  final double? fieldHeight;

  /// Optional background color for the input area.
  final Color? inputContainerColor;

  /// Optional text color for the title.
  final Color? titleColor;

  /// Optional text color for the input text.
  final Color? inputTextColor;

  /// Optional color for the trailing icon.
  final Color? iconColor;

  /// Optional border radius for the input area.
  final double? inputBorderRadius;

  /// Optional size for the icon.
  final double? iconSize;

  /// Whether to enable automatic comma formatting for numbers.
  final bool enableCommaFormatting;

  /// Whether to enable "k" to "000" transformation.
  final bool enableKTransformation;

  /// Optional suffix text to display at the end of the input field.
  final String? suffixText;

  /// Optional text color for the suffix text.
  final Color? suffixTextColor;

  /// Optional list of input formatters to apply to the text field.
  final List<TextInputFormatter>? inputFormatters;

  const InputField1({
    super.key,
    required this.title,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.enabled = true,
    this.obscureText = false,
    this.trailingIcon,
    this.onTrailingIconTap,
    this.minWidth = 128.0,
    this.fieldHeight,
    this.inputContainerColor,
    this.titleColor,
    this.inputTextColor,
    this.iconColor,
    this.inputBorderRadius,
    this.iconSize,
    this.enableCommaFormatting = false,
    this.enableKTransformation = false,
    this.suffixText,
    this.suffixTextColor,
    this.inputFormatters,
  });

  @override
  State<InputField1> createState() => _InputField1State();
}

class _InputField1State extends State<InputField1> {
  
  /// Formats a number string with commas every 3 digits
  String _formatWithCommas(String value) {
    if (value.isEmpty) return '';
    
    try {
      // Handle decimal numbers
      final parts = value.split('.');
      final intPart = parts[0];
      final decPart = parts.length > 1 ? parts[1] : '';
      
      // Format the integer part with commas
      final formattedInt = NumberFormat('#,###').format(int.parse(intPart));
      
      // Return with decimal part if it exists
      return decPart.isNotEmpty ? '$formattedInt.$decPart' : formattedInt;
    } catch (e) {
      return value;
    }
  }

  /// Transforms "k" to "000" when it follows directly after a number
  String _transformKToZeros(String value) {
    if (value.isEmpty) return '';
    
    // Replace "k" with "000" only when it follows directly after a digit
    // This regex matches one or more digits followed by one or more "k"s
    return value.replaceAllMapped(RegExp(r'(\d+)(k+)', caseSensitive: false), (match) {
      final number = match.group(1)!;
      final kCount = match.group(2)!.length;
      final zeros = '000' * kCount;
      return '$number$zeros';
    });
  }

  /// Handles text changes with formatting
  void _handleTextChange(String value) {
    if (!widget.enableCommaFormatting && !widget.enableKTransformation) {
      return;
    }

    String processedValue = value;
    
    // First, handle "k" transformation if enabled
    if (widget.enableKTransformation) {
      processedValue = _transformKToZeros(processedValue);
    }
    
    // Then, handle comma formatting if enabled
    if (widget.enableCommaFormatting) {
      // Remove existing commas before processing
      final numericValue = processedValue.replaceAll(',', '');
      if (numericValue.isNotEmpty && RegExp(r'^\d*\.?\d*$').hasMatch(numericValue)) {
        processedValue = _formatWithCommas(numericValue);
      }
    }
    
    // Update the controller if the value changed
    if (processedValue != value && widget.controller != null) {
      final newSelection = TextSelection.collapsed(offset: processedValue.length);
      widget.controller!.value = TextEditingValue(
        text: processedValue,
        selection: newSelection,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fixed color scheme: header uses elementColor2, content uses elementColor3
    final Color effectiveTitleColor = widget.titleColor ?? AppTheme.elementColor2;
    final Color effectiveInputTextColor = widget.inputTextColor ?? AppTheme.elementColor3;
    final Color effectiveIconColor = widget.iconColor ?? AppTheme.elementColor3;
    final Color effectiveInputContainerColor = widget.inputContainerColor ?? AppTheme.containerColor2;

    final double effectiveHeight = widget.fieldHeight ?? 72.0;
    final double labelAreaHeight = 21.0;
    final double inputAreaHeight = 48.0;
    final double effectiveInputBorderRadius = widget.inputBorderRadius ?? AppTheme.borderRadiusSmall;
    final double effectiveIconSize = widget.iconSize ?? 24.0;

    final TextStyle titleStyle = SafeGoogleFonts.outfit(
      color: effectiveTitleColor,
      fontSize: AppTheme.fontSizeMedium,
      fontWeight: FontWeight.w600,
    );
    
    final TextStyle inputTextStyle = SafeGoogleFonts.outfit(
      color: effectiveInputTextColor,
      fontSize: AppTheme.fontSizeMedium,
      fontWeight: FontWeight.w500,
    );

    final EdgeInsets labelPadding = const EdgeInsets.symmetric(horizontal: 8);

    // Create input formatters based on enabled features
    List<TextInputFormatter> inputFormatters = [];
    if (widget.enableCommaFormatting || widget.enableKTransformation) {
      // Allow digits, commas, periods, and 'k' character
      inputFormatters.add(FilteringTextInputFormatter.allow(RegExp(r'[\d,\.kK]')));
    }
    
    // Add external input formatters if provided
    if (widget.inputFormatters != null) {
      inputFormatters.addAll(widget.inputFormatters!);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: widget.minWidth),
      child: SizedBox(
        width: double.infinity,
        height: effectiveHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: labelAreaHeight,
              padding: labelPadding,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: titleStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            Container(
              height: inputAreaHeight,
              decoration: BoxDecoration(
                color: effectiveInputContainerColor,
                borderRadius: BorderRadius.circular(effectiveInputBorderRadius),
              ),
              child: TextFormField(
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                enabled: widget.enabled,
                obscureText: widget.obscureText,
                style: inputTextStyle,
                inputFormatters: inputFormatters,
                onChanged: _handleTextChange,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: SafeGoogleFonts.outfit(
                    color: effectiveInputTextColor,
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.mediumGap,
                    vertical: 15.0,
                  ),
                  suffixText: widget.suffixText,
                  suffixStyle: widget.suffixText != null
                      ? SafeGoogleFonts.outfit(
                          color: widget.suffixTextColor ?? effectiveInputTextColor,
                          fontSize: AppTheme.fontSizeMedium,
                          fontWeight: FontWeight.w500,
                        )
                      : null,
                  suffixIcon: widget.trailingIcon != null
                      ? GestureDetector(
                          onTap: widget.onTrailingIconTap,
                          child: Icon(
                            widget.trailingIcon,
                            color: effectiveIconColor,
                            size: effectiveIconSize,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

