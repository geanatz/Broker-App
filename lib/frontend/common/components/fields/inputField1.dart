// lib/components/fields/input_field1.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A display component for a simple input field with a title and a text value.
///
/// This component shows a title label above a styled container that displays
/// the input text. It's typically used for read-only display or as a precursor
/// to an interactive input.
class InputField1 extends StatelessWidget {
  /// The title label displayed above the input area.
  final String title;

  /// The text content displayed within the input area.
  final String inputText;

  /// Optional callback when the input area is tapped.
  final VoidCallback? onTap;

  /// Optional minimum width for the component. Defaults to 128.
  final double minWidth;

  /// Optional overall height for the component. Defaults to 72.
  final double? fieldHeight;

  /// Optional background color for the input area.
  /// Defaults to AppTheme.containerColor2 (0xFFACACD2).
  final Color? inputContainerColor;

  /// Optional text color for the title.
  /// Defaults to AppTheme.elementColor2 (0xFF666699).
  final Color? titleColor;

  /// Optional text color for the input text.
  /// Defaults to AppTheme.elementColor3 (0xFF4D4D80).
  final Color? inputTextColor;

  /// Optional border radius for the input area.
  /// Defaults to 16.0.
  final double? inputBorderRadius;

  const InputField1({
    Key? key,
    required this.title,
    required this.inputText,
    this.onTap,
    this.minWidth = 128.0,
    this.fieldHeight,
    this.inputContainerColor,
    this.titleColor,
    this.inputTextColor,
    this.inputBorderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final Color effectiveInputTextColor = inputTextColor ?? const Color(0xFF4D4D80); // AppTheme.elementColor3
    final Color effectiveInputContainerColor = inputContainerColor ?? const Color(0xFFACACD2); // AppTheme.containerColor2

    final double effectiveHeight = fieldHeight ?? 72.0; // AppTheme.inputFieldHeight
    final double labelAreaHeight = 21.0; // AppTheme.inputFieldLabelHeight
    final double inputAreaHeight = 48.0; // AppTheme.inputFieldContentHeight
    final double effectiveInputBorderRadius = inputBorderRadius ?? 16.0; // AppTheme.inputFieldBorderRadius

    // Text Styles (Consider moving to AppTheme)
    final TextStyle titleStyle = GoogleFonts.outfit(
      color: effectiveTitleColor,
      fontSize: 17,
      fontWeight: FontWeight.w600,
    );
    final TextStyle inputTextStyle = GoogleFonts.outfit(
      color: effectiveInputTextColor,
      fontSize: 17,
      fontWeight: FontWeight.w500,
    );

    // Paddings (Consider moving to AppTheme)
    final EdgeInsets labelPadding = const EdgeInsets.symmetric(horizontal: 8); // AppTheme.inputFieldLabelPadding
    final EdgeInsets inputPadding = const EdgeInsets.symmetric(horizontal: 16); // AppTheme.inputFieldContentPadding

    Widget inputContent = Container(
      width: double.infinity,
      height: inputAreaHeight,
      padding: inputPadding,
      decoration: ShapeDecoration(
        color: effectiveInputContainerColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveInputBorderRadius),
        ),
      ),
      child: Row(
        // mainAxisSize: MainAxisSize.min, // Not needed due to Expanded
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            // Original had an inner Container with clipBehavior and empty BoxDecoration, removed for simplicity
            // as it doesn't seem to add value here. The Row and Text handle content.
            child: Row(
              // mainAxisSize: MainAxisSize.min, // Not strictly necessary in Expanded
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              // spacing: 10, // Ineffective for single Text child
              children: [
                Text(
                  inputText,
                  style: inputTextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth),
      child: SizedBox(
        width: double.infinity,
        height: effectiveHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distributes space with fixed height children
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: labelAreaHeight,
              padding: labelPadding,
              child: Row(
                // mainAxisSize: MainAxisSize.min, // Not needed due to Expanded
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                // spacing: 8, // Ineffective for single Expanded child
                children: [
                  Expanded(
                    // Original had an inner Container with clipBehavior and empty BoxDecoration, removed for simplicity.
                    child: Row(
                      // mainAxisSize: MainAxisSize.min, // Not strictly necessary in Expanded
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // spacing: 10, // Ineffective for single Text child
                      children: [
                        Text(
                          title,
                          style: titleStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // SizedBox(height: verticalSpacing), // Original used Column's spacing property.
                                               // With MainAxisAlignment.spaceBetween and fixed child heights,
                                               // this SizedBox might not be strictly necessary or could be adjusted
                                               // if the sum of heights + spacing != total height.
                                               // The original total height is 72, children are 21 and 48. 21+48 = 69.
                                               // The 3px difference is distributed by spaceBetween.
                                               // If fixed spacing of 4 is desired, total height should be 21+4+48 = 73.
                                               // Or, use MainAxisAlignment.start and a SizedBox(height:4).
                                               // For now, sticking to spaceBetween as per original.
            onTap != null
                ? InkWell(onTap: onTap, borderRadius: BorderRadius.circular(effectiveInputBorderRadius), child: inputContent)
                : inputContent,
          ],
        ),
      ),
    );
  }
}