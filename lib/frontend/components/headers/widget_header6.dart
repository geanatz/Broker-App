import 'package:mat_finance/app_theme.dart';
// lib/components/headers/widget_header6.dart

import 'package:flutter/material.dart';

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

  /// Callback when the date text is tapped (e.g., to go to current week).
  final VoidCallback? onDateTextTap;

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
    super.key,
    required this.title,
    required this.dateText,
    this.prevDateIcon,
    this.nextDateIcon,
    this.onPrevDateTap,
    this.onNextDateTap,
    this.onDateTextTap,
    this.titleColor,
    this.titleStyle,
    this.dateTextColor,
    this.dateTextStyle,
    this.dateNavIconColor,
    this.padding,
    this.titleContainerHeight,
    this.dateTextContainerWidth,
    this.dateNavIconSize,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveTitleColor = titleColor ?? AppTheme.elementColor1;
    final Color effectiveDateTextColor = dateTextColor ?? AppTheme.elementColor1;
    final Color effectiveDateNavIconColor = dateNavIconColor ?? AppTheme.elementColor1;
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap);
    final double effectiveTitleContainerHeight = titleContainerHeight ?? 24.0;
    final double effectiveDateTextContainerWidth = dateTextContainerWidth ?? 80.0;
    final double effectiveDateNavIconSize = dateNavIconSize ?? AppTheme.iconSizeMedium;
    final IconData finalPrevDateIcon = prevDateIcon ?? Icons.chevron_left;
    final IconData finalNextDateIcon = nextDateIcon ?? Icons.chevron_right;

    final TextStyle defaultTitleStyle = AppTheme.safeOutfit(
      color: effectiveTitleColor,
      fontSize: AppTheme.fontSizeLarge, 
      fontWeight: FontWeight.w600,
    );
    final TextStyle defaultDateTextStyle = AppTheme.safeOutfit(
      color: effectiveDateTextColor,
      fontSize: AppTheme.fontSizeSmall, 
      fontWeight: FontWeight.w500,
    );

    final TextStyle finalTitleStyle = titleStyle ?? defaultTitleStyle;
    final TextStyle finalDateTextStyle = dateTextStyle ?? defaultDateTextStyle;
    
    final EdgeInsets iconButtonPadding = const EdgeInsets.symmetric(horizontal: 8); // From snippet

    Widget buildNavIcon(IconData iconData, VoidCallback? onTap) {
      return MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: InkWell(
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
              buildNavIcon(finalPrevDateIcon, onPrevDateTap),
              MouseRegion(
                cursor: onDateTextTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
                child: InkWell(
                  onTap: onDateTextTap,
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Container(
                    width: effectiveDateTextContainerWidth,
                    height: effectiveTitleContainerHeight, // Match title height usually
                    alignment: Alignment.center,
                    child: Text(
                      dateText,
                      textAlign: TextAlign.center,
                      style: finalDateTextStyle, // Removed underline decoration
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              buildNavIcon(finalNextDateIcon, onNextDateTap),
            ],
          ),
        ],
      ),
    );
  }
}


