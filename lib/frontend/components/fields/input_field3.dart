import 'package:broker_app/app_theme.dart';
// lib/components/fields/input_field3.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A display component for an input field with a title, text value,
/// and an optional trailing icon.
///
/// Shows a title label above a styled container. The container displays
/// the input text and can have an icon on the right.
class InputField3 extends StatelessWidget {
  /// The title label.
  final String title;

  /// The text content displayed within the input area.
  final String inputText;

  /// Optional icon to display at the end of the input area.
  final IconData? trailingIcon;

  /// Optional SVG icon path to display at the end of the input area (takes precedence over trailingIcon).
  final String? trailingIconPath;

  /// Optional callback when the input area is tapped.
  final VoidCallback? onTap;

  /// Optional callback when the trailing icon is tapped.
  final VoidCallback? onIconTap;

  /// Optional minimum width for the component. Defaults to 128.
  final double minWidth;

  /// Optional overall height for the component. Defaults to 72.
  final double? fieldHeight;

  /// Optional background color for the input area.
  /// Defaults to AppTheme.containerColor2.
  final Color? inputContainerColor;

  /// Optional text color for the title.
  /// Defaults to AppTheme.elementColor2.
  final Color? titleColor;

  /// Optional text color for the input text.
  /// Defaults to AppTheme.elementColor3.
  final Color? inputTextColor;

  /// Optional color for the trailing icon.
  /// Defaults to AppTheme.elementColor3.
  final Color? iconColor;

  /// Optional border radius for the input area.
  /// Defaults to AppTheme.borderRadiusSmall.
  final double? inputBorderRadius;

  /// Optional size for the icon.
  /// Defaults to 24.0
  final double? iconSize;

  const InputField3({
    super.key,
    required this.title,
    required this.inputText,
    this.trailingIcon,
    this.trailingIconPath,
    this.onTap,
    this.onIconTap,
    this.minWidth = 128.0,
    this.fieldHeight,
    this.inputContainerColor,
    this.titleColor,
    this.inputTextColor,
    this.iconColor,
    this.inputBorderRadius,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    // Use AppTheme colors and styles like InputField1
    final Color effectiveTitleColor = titleColor ?? AppTheme.elementColor2;
    final Color effectiveInputTextColor = inputTextColor ?? AppTheme.elementColor3;
    final Color effectiveIconColor = iconColor ?? AppTheme.elementColor3;
    final Color effectiveInputContainerColor = inputContainerColor ?? AppTheme.containerColor2;

    final double effectiveHeight = fieldHeight ?? 72.0;
    final double labelAreaHeight = 21.0;
    final double inputAreaHeight = 48.0;
    final double effectiveInputBorderRadius = inputBorderRadius ?? AppTheme.borderRadiusSmall;
    final double effectiveIconSize = iconSize ?? 24.0;

    // Use Google Fonts Outfit like InputField1
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
          if (trailingIconPath != null || trailingIcon != null) ...[
            SizedBox(width: AppTheme.mediumGap),
            GestureDetector(
              onTap: onIconTap,
              child: SizedBox(
                width: effectiveIconSize,
                height: effectiveIconSize,
                child: trailingIconPath != null
                    ? SvgPicture.asset(
                        trailingIconPath!,
                        width: effectiveIconSize,
                        height: effectiveIconSize,
                        colorFilter: ColorFilter.mode(
                          effectiveIconColor,
                          BlendMode.srcIn,
                        ),
                      )
                    : Icon(
                        trailingIcon,
                        color: effectiveIconColor,
                        size: effectiveIconSize,
                      ),
              ),
            ),
          ],
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
                ],
              ),
            ),
            const SizedBox(height: 3),
            onTap != null && onIconTap == null // Only make main area tappable if icon doesn't have its own tap
                ? InkWell(onTap: onTap, borderRadius: BorderRadius.circular(effectiveInputBorderRadius), child: inputContent)
                : inputContent,
          ],
        ),
      ),
    );
  }
}

