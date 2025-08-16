import 'package:mat_finance/app_theme.dart';
// lib/components/fields/dropdown_field1.dart

import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mat_finance/frontend/components/headers/widget_header3.dart';

/// A real dropdown field component with a title and DropdownButtonFormField.
///
/// This component shows a title label above a styled DropdownButtonFormField
/// that allows real selection from a list of items.
class DropdownField1<T> extends StatefulWidget {
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
  State<DropdownField1<T>> createState() => _DropdownField1State<T>();
}

class _DropdownField1State<T> extends State<DropdownField1<T>> {
  bool _isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    final Color effectiveTitleColor = widget.titleColor ?? AppTheme.elementColor2;
    final Color effectiveSelectedOptionColor = widget.selectedOptionColor ?? AppTheme.elementColor3;
    final Color effectiveIconColor = widget.iconColor ?? AppTheme.elementColor3;
    final Color effectiveDropdownContainerColor = widget.dropdownContainerColor ?? AppTheme.containerColor2;

    final double effectiveHeight = widget.fieldHeight ?? 72.0;
    final double labelAreaHeight = 21.0;
    final double dropdownAreaHeight = 48.0;
    final double effectiveDropdownBorderRadius = widget.dropdownBorderRadius ?? AppTheme.borderRadiusTiny;
    final double effectiveIconSize = widget.iconSize ?? 24.0;

    final TextStyle titleStyle = AppTheme.safeOutfit(
      color: effectiveTitleColor,
      fontSize: AppTheme.fontSizeMedium,
      fontWeight: FontWeight.w600,
    );
    
    final TextStyle selectedOptionStyle = AppTheme.safeOutfit(
      color: effectiveSelectedOptionColor,
      fontSize: AppTheme.fontSizeMedium,
      fontWeight: FontWeight.w500,
    );

    final EdgeInsets labelPadding = const EdgeInsets.symmetric(horizontal: 8);

    // Border radius logic
    BorderRadius buttonRadius = _isDropdownOpen
        ? BorderRadius.only(
            topLeft: Radius.circular(effectiveDropdownBorderRadius),
            topRight: Radius.circular(effectiveDropdownBorderRadius),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          )
        : BorderRadius.circular(effectiveDropdownBorderRadius);
    BorderRadius dropdownRadius = BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(0),
      bottomLeft: Radius.circular(effectiveDropdownBorderRadius),
      bottomRight: Radius.circular(effectiveDropdownBorderRadius),
    );

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
              height: dropdownAreaHeight,
              decoration: BoxDecoration(
                color: effectiveDropdownContainerColor,
                borderRadius: buttonRadius,
                // Fara shadow pe buton, doar pe lista
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<T>(
                  value: widget.value,
                  items: widget.items,
                  onChanged: widget.enabled ? widget.onChanged : null,
                  hint: widget.hintText != null
                      ? Text(
                          widget.hintText!,
                          style: selectedOptionStyle,
                        )
                      : null,
                  isExpanded: true,
                  buttonStyleData: ButtonStyleData(
                    height: dropdownAreaHeight,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap),
                    decoration: BoxDecoration(
                      color: effectiveDropdownContainerColor,
                      borderRadius: buttonRadius,
                      // Fara shadow pe buton
                    ),
                  ),
                  iconStyleData: IconStyleData(
                    icon: ExpandIconSvg(
                      isExpanded: _isDropdownOpen,
                      size: effectiveIconSize,
                      color: effectiveIconColor,
                    ),
                    iconSize: effectiveIconSize,
                    iconEnabledColor: effectiveIconColor,
                    iconDisabledColor: effectiveIconColor.withAlpha(50),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 480,
                    decoration: BoxDecoration(
                      color: effectiveDropdownContainerColor,
                      borderRadius: dropdownRadius,
                      // Removed shadow as requested
                    ),
                  ),
                  style: selectedOptionStyle,
                  selectedItemBuilder: (BuildContext context) {
                    return widget.items.map<Widget>((DropdownMenuItem<T> item) {
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
                  disabledHint: widget.value != null
                      ? Text(
                          widget.items.firstWhere((item) => item.value == widget.value, orElse: () => DropdownMenuItem<T>(value: widget.value, child: Text(widget.value.toString()))).child is Text
                              ? (widget.items.firstWhere((item) => item.value == widget.value).child as Text).data ?? ''
                              : widget.value.toString(),
                          style: selectedOptionStyle,
                        )
                      : (widget.hintText != null
                          ? Text(
                              widget.hintText!,
                              style: selectedOptionStyle,
                            )
                          : null),
                  onMenuStateChange: (isOpen) {
                    setState(() {
                      _isDropdownOpen = isOpen;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


