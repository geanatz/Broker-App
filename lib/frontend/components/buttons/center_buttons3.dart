// import 'package:your_app/theme/app_theme.dart'; // Placeholder
// lib/components/buttons/centered_buttons3.dart

import 'package:flutter/material.dart';

// Assuming _CenteredIconButton is defined (copied from CenteredButtons1 for standalone example)
class _CenteredIconButton extends StatelessWidget {
  final IconData iconData;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? borderRadius;
  final double? buttonHeight;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;

  const _CenteredIconButton({
    required this.iconData,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius,
    this.buttonHeight,
    this.padding,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBackgroundColor = backgroundColor ?? const Color(0xFFC4C4D4);
    final Color effectiveIconColor = iconColor ?? const Color(0xFF666699);
    final double effectiveBorderRadius = borderRadius ?? 24.0;
    final double effectiveButtonHeight = buttonHeight ?? 48.0;
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    final double effectiveIconSize = iconSize ?? 24.0;

    Widget buttonContent = Container(
      height: effectiveButtonHeight,
      padding: effectivePadding,
      decoration: ShapeDecoration(
        color: effectiveBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: effectiveIconSize,
            color: effectiveIconColor,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        child: buttonContent,
      );
    }
    return buttonContent;
  }
}

/// A container with three horizontally expanded buttons, each with a centered icon,
/// separated by a specified spacing.
class CenteredButtons3 extends StatelessWidget {
  /// Icon for the first button.
  final IconData icon1;
  /// Callback for the first button.
  final VoidCallback? onTap1;

  /// Icon for the second button.
  final IconData icon2;
  /// Callback for the second button.
  final VoidCallback? onTap2;

  /// Icon for the third button.
  final IconData icon3;
  /// Callback for the third button.
  final VoidCallback? onTap3;

  /// Spacing between the buttons. Defaults to 8.0.
  final double? spacing;

  // Common styling properties for the buttons
  final Color? buttonBackgroundColor;
  final Color? iconColor;
  final double? buttonBorderRadius;
  final double? buttonHeight;
  final EdgeInsetsGeometry? buttonPadding;
  final double? iconSize;

  const CenteredButtons3({
    super.key,
    required this.icon1,
    this.onTap1,
    required this.icon2,
    this.onTap2,
    required this.icon3,
    this.onTap3,
    this.spacing,
    this.buttonBackgroundColor,
    this.iconColor,
    this.buttonBorderRadius,
    this.buttonHeight,
    this.buttonPadding,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final double effectiveSpacing = spacing ?? 8.0; // AppTheme.smallGap

    return SizedBox(
      width: double.infinity, // As per snippet
      child: Row(
        children: [
          Expanded(
            child: _CenteredIconButton(
              iconData: icon1,
              onTap: onTap1,
              backgroundColor: buttonBackgroundColor,
              iconColor: iconColor,
              borderRadius: buttonBorderRadius,
              buttonHeight: buttonHeight,
              padding: buttonPadding,
              iconSize: iconSize,
            ),
          ),
          SizedBox(width: effectiveSpacing),
          Expanded(
            child: _CenteredIconButton(
              iconData: icon2,
              onTap: onTap2,
              backgroundColor: buttonBackgroundColor,
              iconColor: iconColor,
              borderRadius: buttonBorderRadius,
              buttonHeight: buttonHeight,
              padding: buttonPadding,
              iconSize: iconSize,
            ),
          ),
          SizedBox(width: effectiveSpacing),
          Expanded(
            child: _CenteredIconButton(
              iconData: icon3,
              onTap: onTap3,
              backgroundColor: buttonBackgroundColor,
              iconColor: iconColor,
              borderRadius: buttonBorderRadius,
              buttonHeight: buttonHeight,
              padding: buttonPadding,
              iconSize: iconSize,
            ),
          ),
        ],
      ),
    );
  }
}

