// lib/components/headers/widget_header3.dart

import 'package:flutter/material.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A widget header displaying a title on the left and a trailing icon on the right.
class WidgetHeader3 extends StatelessWidget {
  /// The main title text.
  final String title;

  /// The icon to display on the right.
  final IconData? trailingIcon;

  /// Optional callback when the trailing icon is tapped.
  final VoidCallback? onTrailingIconTap;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor1 (0xFF8A8AA8).
  final Color? titleColor;

  /// Optional custom text style for the title.
  final TextStyle? titleStyle;

  /// Optional custom color for the icon.
  /// Defaults to AppTheme.elementColor1 (0xFF8A8AA8).
  final Color? iconColor;

  /// Optional padding for the header container.
  /// Defaults to EdgeInsets.symmetric(horizontal: 16).
  final EdgeInsetsGeometry? padding;

  /// Optional spacing between the title and the icon.
  /// Defaults to 16.0.
  final double? spacing;

  /// Optional height for the container holding the title text.
  /// Defaults to 24.0.
  final double? titleContainerHeight;

  /// Optional size for the icon.
  /// Defaults to 24.0.
  final double? iconSize;

  const WidgetHeader3({
    Key? key,
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF8A8AA8); // AppTheme.elementColor1
    final Color effectiveIconColor = iconColor ?? const Color(0xFF8A8AA8); // AppTheme.elementColor1
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 16); // AppTheme.paddingMedium
    final double effectiveSpacing = spacing ?? 16.0; // AppTheme.mediumGap
    final double effectiveTitleContainerHeight = titleContainerHeight ?? 24.0; // AppTheme.headerTitleHeight
    final double effectiveIconSize = iconSize ?? 24.0; // AppTheme.iconSizeSmall

    final TextStyle defaultTitleStyle = TextStyle(
      color: effectiveTitleColor,
      fontSize: 19, fontWeight: FontWeight.w600, fontFamily: 'Outfit',
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
                    style: effectiveTitleStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          if (iconWidget != null) ...[
            SizedBox(width: effectiveSpacing), // Replaces Row's spacing: 16
            iconWidget,
          ],
        ],
      ),
    );
  }
}