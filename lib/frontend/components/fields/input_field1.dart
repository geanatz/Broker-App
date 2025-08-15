import 'package:mat_finance/app_theme.dart';
// lib/components/fields/input_field1.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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

    final oldValue = widget.controller?.value;
    final oldText = oldValue?.text ?? '';
    final oldSelection = oldValue?.selection ?? const TextSelection.collapsed(offset: 0);
    final oldCursorPos = oldSelection.baseOffset;

    String processedValue = value;

    int kAdjustment = 0;
    int kStart = 0;
    int kCount = 0;
    // Detectam daca la pozitia cursorului era un k (sau mai multe)
    if (widget.enableKTransformation && oldCursorPos > 0 && oldCursorPos <= value.length) {
      // Cautam inapoi de la cursor pentru secventa de k-uri
      int i = oldCursorPos - 1;
      while (i >= 0 && (value[i] == 'k' || value[i] == 'K')) {
        kCount++;
        i--;
      }
      if (kCount > 0 && i >= 0 && RegExp(r'\d').hasMatch(value[i])) {
        // Avem secventa de k-uri dupa cifra
        kStart = i + 1;
        kAdjustment = kCount * 2; // fiecare k devine 000 (deci +2 caractere in plus fata de k)
      } else {
        kCount = 0;
        kAdjustment = 0;
      }
    }

    if (widget.enableKTransformation) {
      processedValue = _transformKToZeros(processedValue);
    }

    if (widget.enableCommaFormatting) {
      final numericValue = processedValue.replaceAll(',', '');
      if (numericValue.isNotEmpty && RegExp(r'^\d*\.?\d*').hasMatch(numericValue)) {
        processedValue = _formatWithCommas(numericValue);
      }
    }

    if (processedValue != value && widget.controller != null) {
      // Numar de caractere non-virgula inainte de cursor in vechiul text
      int nonCommaBeforeCursor = 0;
      for (int i = 0; i < oldCursorPos && i < oldText.length; i++) {
        if (oldText[i] != ',') nonCommaBeforeCursor++;
      }
      // Gasim pozitia in noul text dupa acelasi numar de caractere non-virgula
      int newCursorPos = 0;
      int nonCommaCount = 0;
      while (newCursorPos < processedValue.length && nonCommaCount < nonCommaBeforeCursor) {
        if (processedValue[newCursorPos] != ',') nonCommaCount++;
        newCursorPos++;
      }
      // Ajustam daca e nevoie
      if (kAdjustment > 0 && kStart < oldCursorPos) {
        // Daca secventa de k-uri era inainte de cursor, ajustam pozitia
        newCursorPos += kAdjustment;
      }
      if (newCursorPos > processedValue.length) newCursorPos = processedValue.length;
      if (newCursorPos < 0) newCursorPos = 0;
      widget.controller!.value = TextEditingValue(
        text: processedValue,
        selection: TextSelection.collapsed(offset: newCursorPos),
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
    final double effectiveInputBorderRadius = widget.inputBorderRadius ?? AppTheme.borderRadiusTiny;
    final double effectiveIconSize = widget.iconSize ?? 24.0;

    final TextStyle titleStyle = AppTheme.safeOutfit(
      color: effectiveTitleColor,
      fontSize: AppTheme.fontSizeMedium,
      fontWeight: FontWeight.w600,
    );
    
    final TextStyle inputTextStyle = AppTheme.safeOutfit(
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
                  hintStyle: AppTheme.safeOutfit(
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
                      ? AppTheme.safeOutfit(
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


