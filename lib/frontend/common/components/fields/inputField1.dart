// lib/components/fields/input_field1.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../appTheme.dart';

/// A real input field component with a title and TextFormField.
///
/// This component shows a title label above a styled TextFormField that allows
/// real text input. It can be used with a controller for form handling.
class InputField1 extends StatelessWidget {
  /// The title label displayed above the input area.
  final String title;

  /// Optional subtitle or additional text shown next to the title.
  final String? subtitle;

  /// The controller for the text field.
  final TextEditingController? controller;

  /// Placeholder text shown when the field is empty.
  final String? hintText;

  /// Keyboard type for the input.
  final TextInputType? keyboardType;

  /// Whether the field is enabled.
  final bool enabled;

  /// Optional callback when the field value changes.
  final ValueChanged<String>? onChanged;

  /// Optional callback when the field is tapped (useful for date pickers, etc.).
  final VoidCallback? onTap;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Optional minimum width for the component. Defaults to 128.
  final double minWidth;

  /// Optional overall height for the component. Defaults to 72.
  final double? fieldHeight;

  /// Optional background color for the input area.
  final Color? inputContainerColor;

  /// Optional text color for the title.
  final Color? titleColor;

  /// Optional text color for the subtitle.
  final Color? subtitleColor;

  /// Optional text color for the input text.
  final Color? inputTextColor;

  /// Optional border radius for the input area.
  final double? inputBorderRadius;

  const InputField1({
    Key? key,
    required this.title,
    this.subtitle,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.enabled = true,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.minWidth = 128.0,
    this.fieldHeight,
    this.inputContainerColor,
    this.titleColor,
    this.subtitleColor,
    this.inputTextColor,
    this.inputBorderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color effectiveTitleColor = titleColor ?? AppTheme.elementColor2;
    final Color effectiveSubtitleColor = subtitleColor ?? AppTheme.elementColor1;
    final Color effectiveInputTextColor = inputTextColor ?? AppTheme.elementColor3;
    final Color effectiveInputContainerColor = inputContainerColor ?? AppTheme.containerColor2;

    final double effectiveHeight = fieldHeight ?? 72.0;
    final double labelAreaHeight = 21.0;
    final double inputAreaHeight = 48.0;
    final double effectiveInputBorderRadius = inputBorderRadius ?? AppTheme.borderRadiusSmall;

    final TextStyle titleStyle = GoogleFonts.outfit(
      color: effectiveTitleColor,
      fontSize: AppTheme.fontSizeMedium,
      fontWeight: FontWeight.w600,
    );
    
    final TextStyle subtitleStyle = GoogleFonts.outfit(
      color: effectiveSubtitleColor,
      fontSize: AppTheme.fontSizeSmall,
      fontWeight: FontWeight.w500,
    );

    final TextStyle inputTextStyle = GoogleFonts.outfit(
      color: effectiveInputTextColor,
      fontSize: AppTheme.fontSizeMedium,
      fontWeight: FontWeight.w500,
    );

    final EdgeInsets labelPadding = const EdgeInsets.symmetric(horizontal: 8);

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth),
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: titleStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(width: AppTheme.smallGap),
                    Text(
                      subtitle!,
                      style: subtitleStyle,
                    ),
                  ],
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
              child: MouseRegion(
                cursor: readOnly && onTap != null ? SystemMouseCursors.click : SystemMouseCursors.text,
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  enabled: enabled,
                  readOnly: readOnly,
                  onTap: onTap,
                  onChanged: onChanged,
                  textAlignVertical: TextAlignVertical.center,
                  style: inputTextStyle,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: inputTextStyle,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.mediumGap,
                      vertical: 15.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}