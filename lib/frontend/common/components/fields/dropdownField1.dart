// lib/components/fields/dropdown_field1.dart

import 'package:flutter/material.dart';
import 'package:broker_app/frontend/common/utils/safe_google_fonts.dart';
import '../../appTheme.dart';

/// A real dropdown field component with a title and DropdownButtonFormField.
///
/// This component shows a title label above a styled DropdownButtonFormField
/// that allows real selection from a list of items.
class DropdownField1<T> extends StatelessWidget {
  /// The title label displayed above the dropdown area.
  final String title;

  /// The currently selected value.
  final T? value;

  /// List of items to show in the dropdown.
  final List<DropdownMenuItem<T>> items;

  /// Callback when a value is selected.
  final ValueChanged<T?>? onChanged;

  /// Hint text shown when no value is selected.
  final String? hintText;

  /// Whether the field is enabled.
  final bool enabled;

  /// Optional icon to display at the end of the dropdown area.
  final IconData? trailingIcon;

  /// Optional minimum width for the component. Defaults to 128.
  final double minWidth;

  /// Optional overall height for the component. Defaults to 72.
  final double? fieldHeight;

  /// Optional background color for the dropdown area.
  final Color? dropdownContainerColor;

  /// Optional text color for the title.
  final Color? titleColor;

  /// Optional text color for the selected option.
  final Color? selectedOptionColor;

  /// Optional color for the trailing icon.
  final Color? iconColor;

  /// Optional border radius for the dropdown area.
  final double? dropdownBorderRadius;

  /// Optional size for the icon.
  final double? iconSize;

  const DropdownField1({
    super.key,
    required this.title,
    this.value,
    required this.items,
    this.onChanged,
    this.hintText,
    this.enabled = true,
    this.trailingIcon,
    this.minWidth = 128.0,
    this.fieldHeight,
    this.dropdownContainerColor,
    this.titleColor,
    this.selectedOptionColor,
    this.iconColor,
    this.dropdownBorderRadius,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    // Fixed color scheme: header uses elementColor2, content uses elementColor3
    final Color effectiveTitleColor = titleColor ?? AppTheme.elementColor2;
    final Color effectiveSelectedOptionColor = selectedOptionColor ?? AppTheme.elementColor3;
    final Color effectiveIconColor = iconColor ?? AppTheme.elementColor3;
    final Color effectiveDropdownContainerColor = dropdownContainerColor ?? AppTheme.containerColor2;

    final double effectiveHeight = fieldHeight ?? 72.0;
    final double labelAreaHeight = 21.0;
    final double dropdownAreaHeight = 48.0;
    final double effectiveDropdownBorderRadius = dropdownBorderRadius ?? AppTheme.borderRadiusSmall;
    final double effectiveIconSize = iconSize ?? 24.0;

    final TextStyle titleStyle = SafeGoogleFonts.outfit(
      color: effectiveTitleColor,
      fontSize: AppTheme.fontSizeMedium,
      fontWeight: FontWeight.w600,
    );
    
    final TextStyle selectedOptionStyle = SafeGoogleFonts.outfit(
      color: effectiveSelectedOptionColor,
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
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: titleStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            Container(
              height: dropdownAreaHeight,
              decoration: BoxDecoration(
                color: effectiveDropdownContainerColor,
                borderRadius: BorderRadius.circular(effectiveDropdownBorderRadius),
              ),
              child: DropdownButtonFormField<T>(
                value: value,
                items: items,
                onChanged: enabled ? onChanged : null,
                hint: hintText != null
                    ? Text(
                        hintText!,
                        style: selectedOptionStyle,
                      )
                    : null,
                isExpanded: true,
                icon: Icon(
                  trailingIcon ?? Icons.expand_more,
                  color: effectiveIconColor,
                  size: effectiveIconSize,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.mediumGap,
                    vertical: 15.0,
                  ),
                ),
                style: selectedOptionStyle,
                dropdownColor: effectiveDropdownContainerColor,
                selectedItemBuilder: (BuildContext context) {
                  return items.map<Widget>((DropdownMenuItem<T> item) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.child is Text ? (item.child as Text).data ?? '' : item.value.toString(),
                        style: selectedOptionStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

