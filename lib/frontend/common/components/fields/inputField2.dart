// lib/components/fields/input_field2.dart

import 'package:flutter/material.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A display component for an input field with a title, an optional subtitle,
/// and a text value.
///
/// Shows a title and an optional secondary label on its right. Below is a styled
/// container for the input text.
class InputField2 extends StatelessWidget {
  /// The main title label.
  final String title;

  /// Optional secondary label displayed to the right of the title.
  final String? subtitle;

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

  /// Optional text color for the subtitle.
  /// Defaults to AppTheme.elementColor1 (0xFF8A8AA8).
  final Color? subtitleColor;

  /// Optional text color for the input text.
  /// Defaults to AppTheme.elementColor3 (0xFF4D4D80).
  final Color? inputTextColor;

  /// Optional border radius for the input area.
  /// Defaults to 16.0.
  final double? inputBorderRadius;

  const InputField2({
    super.key,
    required this.title,
    this.subtitle,
    required this.inputText,
    this.onTap,
    this.minWidth = 128.0,
    this.fieldHeight,
    this.inputContainerColor,
    this.titleColor,
    this.subtitleColor,
    this.inputTextColor,
    this.inputBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final Color effectiveSubtitleColor = subtitleColor ?? const Color(0xFF8A8AA8); // AppTheme.elementColor1
    final Color effectiveInputTextColor = inputTextColor ?? const Color(0xFF4D4D80); // AppTheme.elementColor3
    final Color effectiveInputContainerColor = inputContainerColor ?? const Color(0xFFACACD2); // AppTheme.containerColor2

    final double effectiveHeight = fieldHeight ?? 72.0; // AppTheme.inputFieldHeight
    final double labelAreaHeight = 21.0; // AppTheme.inputFieldLabelHeight
    final double inputAreaHeight = 48.0; // AppTheme.inputFieldContentHeight
    final double effectiveInputBorderRadius = inputBorderRadius ?? 16.0; // AppTheme.inputFieldBorderRadius
    final double labelRowSpacing = 8.0; // AppTheme.inputFieldLabelInternalSpacing (original spacing: 8)

    // Text Styles
    final TextStyle titleStyle = TextStyle(
      color: effectiveTitleColor,
      fontSize: 17, fontWeight: FontWeight.w600, fontFamily: 'Outfit',
    );
    final TextStyle subtitleStyle = TextStyle(
      color: effectiveSubtitleColor,
      fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Outfit',
    );
    final TextStyle inputTextStyle = TextStyle(
      color: effectiveInputTextColor,
      fontSize: 17, fontWeight: FontWeight.w500, fontFamily: 'Outfit',
    );

    // Paddings
    final EdgeInsets labelPadding = const EdgeInsets.symmetric(horizontal: 8);
    final EdgeInsets inputPadding = const EdgeInsets.symmetric(horizontal: 16);

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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: labelAreaHeight,
              padding: labelPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          title,
                          style: titleStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    SizedBox(width: labelRowSpacing), // For original Row spacing: 8
                    // Original had a Container wrapper for subtitle, simplified to Text directly.
                    Text(
                      subtitle!,
                      style: subtitleStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            onTap != null
                ? InkWell(onTap: onTap, borderRadius: BorderRadius.circular(effectiveInputBorderRadius), child: inputContent)
                : inputContent,
          ],
        ),
      ),
    );
  }
}