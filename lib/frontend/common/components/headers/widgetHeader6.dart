// lib/components/headers/widget_header6.dart

import 'package:flutter/material.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A widget header with a title on the left and a date navigation-like
/// element (previous icon, date text, next icon) on the right.
class WidgetHeader6 extends StatelessWidget {
  /// The main title text.
  final String title;

  /// The text to display for the date/period.
  final String dateText;

  /// Icon for the "previous" action in the date navigator.
  /// Defaults to `Icons.chevron_left`.
  final IconData? prevDateIcon;

  /// Icon for the "next" action in the date navigator.
  /// Defaults to `Icons.chevron_right`.
  final IconData? nextDateIcon;

  /// Callback when the "previous" date icon is tapped.
  final VoidCallback? onPrevDateTap;

  /// Callback when the "next" date icon is tapped.
  final VoidCallback? onNextDateTap;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor1 (0xFF8A8AA8).
  final Color? titleColor;
  final TextStyle? titleStyle;

  /// Optional custom color for the date text.
  /// Defaults to AppTheme.elementColor1 (0xFF8A8AA8).
  final Color? dateTextColor;
  final TextStyle? dateTextStyle;

  /// Optional custom color for the date navigation icons.
  /// Defaults to AppTheme.elementColor1 (0xFF8A8AA8).
  final Color? dateNavIconColor;

  /// Optional padding for the header container.
  /// Defaults to EdgeInsets.symmetric(horizontal: 16).
  final EdgeInsetsGeometry? padding;
  
  /// Optional height for the container holding the title text.
  /// Defaults to 24.0.
  final double? titleContainerHeight;

  /// Optional width for the date text container.
  /// Defaults to 128.0.
  final double? dateTextContainerWidth;

  /// Optional size for the date navigation icons.
  /// Defaults to 24.0.
  final double? dateNavIconSize;

  const WidgetHeader6({
    Key? key,
    required this.title,
    required this.dateText,
    this.prevDateIcon,
    this.nextDateIcon,
    this.onPrevDateTap,
    this.onNextDateTap,
    this.titleColor,
    this.titleStyle,
    this.dateTextColor,
    this.dateTextStyle,
    this.dateNavIconColor,
    this.padding,
    this.titleContainerHeight,
    this.dateTextContainerWidth,
    this.dateNavIconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF8A8AA8); // AppTheme.elementColor1
    final Color effectiveDateTextColor = dateTextColor ?? const Color(0xFF8A8AA8); // AppTheme.elementColor1
    final Color effectiveDateNavIconColor = dateNavIconColor ?? const Color(0xFF8A8AA8); // AppTheme.elementColor1
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 16); // AppTheme.paddingMedium
    final double effectiveTitleContainerHeight = titleContainerHeight ?? 24.0; // AppTheme.headerTitleHeight
    final double effectiveDateTextContainerWidth = dateTextContainerWidth ?? 128.0;
    final double effectiveDateNavIconSize = dateNavIconSize ?? 24.0; // AppTheme.iconSizeSmall
    final IconData finalPrevDateIcon = prevDateIcon ?? Icons.chevron_left;
    final IconData finalNextDateIcon = nextDateIcon ?? Icons.chevron_right;

    final TextStyle defaultTitleStyle = TextStyle(
      color: effectiveTitleColor,
      fontSize: 19, fontWeight: FontWeight.w600, fontFamily: 'Outfit',
    );
    final TextStyle defaultDateTextStyle = TextStyle(
      color: effectiveDateTextColor,
      fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Outfit',
    );

    final TextStyle finalTitleStyle = titleStyle ?? defaultTitleStyle;
    final TextStyle finalDateTextStyle = dateTextStyle ?? defaultDateTextStyle;
    
    final EdgeInsets iconButtonPadding = const EdgeInsets.symmetric(horizontal: 8); // From snippet

    Widget _buildNavIcon(IconData iconData, VoidCallback? onTap) {
      return InkWell(
        onTap: onTap,
        customBorder: CircleBorder(),
        child: Padding( // Original had Container > Padding > Row > Container > Icon
          padding: iconButtonPadding,
          child: SizedBox( // This container is 24x24 from snippet
            width: effectiveDateNavIconSize,
            height: effectiveDateNavIconSize,
            child: Icon(
              iconData,
              color: effectiveDateNavIconColor,
              size: effectiveDateNavIconSize,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: effectivePadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: effectiveTitleContainerHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: finalTitleStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          // No SizedBox for spacing here, as the original snippet didn't have
          // an explicit `spacing` on the main Row. Spacing is managed by Expanded.
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavIcon(finalPrevDateIcon, onPrevDateTap),
              Container(
                width: effectiveDateTextContainerWidth,
                height: effectiveTitleContainerHeight, // Match title height usually
                alignment: Alignment.center,
                child: Text(
                  dateText,
                  textAlign: TextAlign.center,
                  style: finalDateTextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildNavIcon(finalNextDateIcon, onNextDateTap),
            ],
          ),
        ],
      ),
    );
  }
}