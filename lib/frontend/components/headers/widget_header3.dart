import 'package:broker_app/app_theme.dart';
// lib/components/headers/widget_header3.dart

import 'package:flutter/material.dart';

/// A widget header displaying a title on the left and a trailing icon on the right.
class WidgetHeader3 extends StatelessWidget {
  /// The main title text.
  final String title;

  /// The icon to display on the right.
  final IconData? trailingIcon;

  /// Optional callback when the trailing icon is tapped.
  final VoidCallback? onTrailingIconTap;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor1.
  final Color? titleColor;

  /// Optional custom text style for the title.
  final TextStyle? titleStyle;

  /// Optional custom color for the icon.
  /// Defaults to AppTheme.elementColor1.
  final Color? iconColor;

  /// Optional padding for the header container.
  /// Defaults to EdgeInsets.symmetric(horizontal: AppTheme.mediumGap).
  final EdgeInsetsGeometry? padding;

  /// Optional spacing between the title and the icon.
  /// Defaults to AppTheme.mediumGap.
  final double? spacing;

  /// Optional height for the container holding the title text.
  /// Defaults to 24.0.
  final double? titleContainerHeight;

  /// Optional size for the icon.
  /// Defaults to AppTheme.iconSizeMedium.
  final double? iconSize;

  const WidgetHeader3({
    super.key,
    required this.title,
    this.trailingIcon,
    this.onTrailingIconTap,
    this.titleColor,
    this.titleStyle,
    this.iconColor,
    this.padding,
    this.spacing,
    this.titleContainerHeight,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    // Use AppTheme colors and dimensions instead of hardcoded values
    final Color effectiveTitleColor = titleColor ?? AppTheme.elementColor1;
    final Color effectiveIconColor = iconColor ?? AppTheme.elementColor1;
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap);
    final double effectiveSpacing = spacing ?? AppTheme.mediumGap;
    final double effectiveTitleContainerHeight = titleContainerHeight ?? 24.0;
    final double effectiveIconSize = iconSize ?? AppTheme.iconSizeMedium;

    final TextStyle defaultTitleStyle = AppTheme.safeOutfit(
      color: effectiveTitleColor,
      fontSize: AppTheme.fontSizeLarge,
      fontWeight: FontWeight.w600,
    );
    final TextStyle effectiveTitleStyle = titleStyle ?? defaultTitleStyle;

    Widget? iconWidget;
    if (trailingIcon != null) {
      iconWidget = Icon(
        trailingIcon,
        color: effectiveIconColor,
        size: effectiveIconSize,
      );
      if (onTrailingIconTap != null) {
        iconWidget = InkResponse(
          onTap: onTrailingIconTap,
          radius: effectiveIconSize, // Or a bit larger for easier tap
          child: Container( // Container helps with tap area sizing
            width: effectiveIconSize,
            height: effectiveIconSize,
            alignment: Alignment.center,
            child: iconWidget,
          ),
        );
      } else {
         iconWidget = Container( // Ensure consistent sizing even if not tappable
            width: effectiveIconSize,
            height: effectiveIconSize,
            alignment: Alignment.center,
            child: iconWidget,
          );
      }
    }


    Widget content = Container(
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
                    style: effectiveTitleStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          if (iconWidget != null) ...[
            SizedBox(width: effectiveSpacing),
            iconWidget,
          ],
        ],
      ),
    );

    if (onTrailingIconTap != null) {
      return InkWell(
        onTap: onTrailingIconTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        child: content,
      );
    } else {
      return content;
    }
  }
}

