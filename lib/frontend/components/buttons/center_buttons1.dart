// import 'package:your_app/theme/app_theme.dart'; // Placeholder
// lib/components/buttons/centered_buttons1.dart

import 'package:flutter/material.dart';

// Assuming _CenteredIconButton is defined in this file or imported
// (Copied definition of _CenteredIconButton from above for standalone example)
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


/// A container with a single, horizontally expanded button that has a centered icon.
class CenteredButtons1 extends StatelessWidget {
  /// The icon for the button.
  final IconData icon1;
  /// Callback when the button is tapped.
  final VoidCallback? onTap1;

  // Common styling properties for the button
  final Color? buttonBackgroundColor;
  final Color? iconColor;
  final double? buttonBorderRadius;
  final double? buttonHeight;
  final EdgeInsetsGeometry? buttonPadding;
  final double? iconSize;

  const CenteredButtons1({
    super.key,
    required this.icon1,
    this.onTap1,
    this.buttonBackgroundColor,
    this.iconColor,
    this.buttonBorderRadius,
    this.buttonHeight,
    this.buttonPadding,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    // The outer Row in the snippet with `spacing: 8` is not relevant here
    // as there's only one button that expands.
    return SizedBox(
      width: double.infinity, // As per snippet
      child: Row( // This Row ensures the Expanded child behaves correctly.
                 // Snippet: mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start
                 // Since there's only one Expanded child, these alignments don't visually change much.
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
        ],
      ),
    );
  }
}

