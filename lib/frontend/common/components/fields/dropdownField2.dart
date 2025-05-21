// lib/components/fields/dropdown_field2.dart

import 'package:flutter/material.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A display component for a dropdown field with a title, an optional subtitle,
/// selected option, and a trailing icon.
///
/// Shows a title and an optional secondary label. Below is a styled container
/// for the selected option and a trailing icon.
class DropdownField2 extends StatelessWidget {
  /// The main title label.
  final String title;

  /// Optional secondary label displayed to the right of the title.
  final String? subtitle;

  /// The text of the currently selected option.
  final String selectedOption;

  /// Optional icon to display at the end of the dropdown area.
  /// Defaults to `Icons.expand_more`.
  final IconData? trailingIcon;

  /// Callback when the dropdown area is tapped.
  final VoidCallback? onTap;

  /// Optional minimum width for the component. Defaults to 128.
  final double minWidth;

  /// Optional overall height for the component. Defaults to 72.
  final double? fieldHeight;

  /// Optional background color for the dropdown area.
  /// Defaults to AppTheme.containerColor2 (0xFFACACD2).
  final Color? dropdownContainerColor;

  /// Optional text color for the title.
  /// Defaults to AppTheme.elementColor2 (0xFF666699).
  final Color? titleColor;

  /// Optional text color for the subtitle.
  /// Defaults to AppTheme.elementColor1 (0xFF8A8AA8).
  final Color? subtitleColor;

  /// Optional text color for the selected option.
  /// Defaults to AppTheme.elementColor3 (0xFF4D4D80).
  final Color? selectedOptionColor;

  /// Optional color for the trailing icon.
  /// Defaults to AppTheme.elementColor3 (0xFF4D4D80).
  final Color? iconColor;

  /// Optional border radius for the dropdown area.
  /// Defaults to 16.0.
  final double? dropdownBorderRadius;

  /// Optional size for the icon.
  /// Defaults to 24.0.
  final double? iconSize;

  const DropdownField2({
    Key? key,
    required this.title,
    this.subtitle,
    required this.selectedOption,
    this.trailingIcon,
    this.onTap,
    this.minWidth = 128.0,
    this.fieldHeight,
    this.dropdownContainerColor,
    this.titleColor,
    this.subtitleColor,
    this.selectedOptionColor,
    this.iconColor,
    this.dropdownBorderRadius,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final Color effectiveSubtitleColor = subtitleColor ?? const Color(0xFF8A8AA8); // AppTheme.elementColor1
    final Color effectiveSelectedOptionColor = selectedOptionColor ?? const Color(0xFF4D4D80); // AppTheme.elementColor3
    final Color effectiveIconColor = iconColor ?? const Color(0xFF4D4D80); // AppTheme.elementColor3
    final Color effectiveDropdownContainerColor = dropdownContainerColor ?? const Color(0xFFACACD2); // AppTheme.containerColor2

    final double effectiveHeight = fieldHeight ?? 72.0; // AppTheme.inputFieldHeight
    final double labelAreaHeight = 21.0; // AppTheme.inputFieldLabelHeight
    final double dropdownAreaHeight = 48.0; // AppTheme.inputFieldContentHeight
    final double effectiveDropdownBorderRadius = dropdownBorderRadius ?? 16.0; // AppTheme.inputFieldBorderRadius
    final double labelRowSpacing = 8.0; // AppTheme.inputFieldLabelInternalSpacing (original spacing: 8)
    final double dropdownRowSpacing = 16.0; // AppTheme.inputFieldContentInternalSpacing (original spacing: 16)
    final double effectiveIconSize = iconSize ?? 24.0; // AppTheme.iconSizeSmall
    final IconData effectiveTrailingIcon = trailingIcon ?? Icons.expand_more; // Default icon

    // Text Styles
    final TextStyle titleStyle = TextStyle(
      color: effectiveTitleColor,
      fontSize: 17, fontWeight: FontWeight.w600, fontFamily: 'Outfit',
    );
    final TextStyle subtitleStyle = TextStyle(
      color: effectiveSubtitleColor,
      fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Outfit',
    );
    final TextStyle selectedOptionStyle = TextStyle(
      color: effectiveSelectedOptionColor,
      fontSize: 17, fontWeight: FontWeight.w500, fontFamily: 'Outfit',
    );

    // Paddings
    final EdgeInsets labelPadding = const EdgeInsets.symmetric(horizontal: 8);
    final EdgeInsets dropdownPadding = const EdgeInsets.symmetric(horizontal: 16);

    Widget dropdownContent = Container(
      width: double.infinity,
      height: dropdownAreaHeight,
      padding: dropdownPadding,
      decoration: ShapeDecoration(
        color: effectiveDropdownContainerColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveDropdownBorderRadius),
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
                  selectedOption,
                  style: selectedOptionStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: dropdownRowSpacing),
          SizedBox(
            width: effectiveIconSize,
            height: effectiveIconSize,
            child: Icon(
              effectiveTrailingIcon,
              color: effectiveIconColor,
              size: effectiveIconSize,
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
                ? InkWell(onTap: onTap, borderRadius: BorderRadius.circular(effectiveDropdownBorderRadius), child: dropdownContent)
                : dropdownContent,
          ],
        ),
      ),
    );
  }
}