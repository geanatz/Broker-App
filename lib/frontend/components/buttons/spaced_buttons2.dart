import 'package:mat_finance/app_theme.dart';
// lib/components/buttons/spaced_buttons_double.dart

import 'package:flutter/material.dart';

// Assuming _TextIconButton is defined (updated to use AppTheme)
class _TextIconButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? borderRadius;
  final double? buttonHeight;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final double? iconSize;
  final MainAxisAlignment mainAxisAlignment;
  final double? internalSpacing;

  const _TextIconButton({
    this.text,
    this.icon,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.borderRadius,
    this.buttonHeight,
    this.padding,
    this.textStyle,
    this.iconSize,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.internalSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBackgroundColor = backgroundColor ?? AppTheme.containerColor1;
    final Color effectiveTextColor = textColor ?? AppTheme.elementColor2;
    final Color effectiveIconColor = iconColor ?? AppTheme.elementColor2;
    final double effectiveBorderRadius = borderRadius ?? AppTheme.borderRadiusMedium;
    final double effectiveButtonHeight = buttonHeight ?? AppTheme.navButtonHeight;
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap);
    final double effectiveIconSize = iconSize ?? AppTheme.iconSizeMedium;
    final double effectiveInternalSpacing = internalSpacing ?? AppTheme.smallGap;

    final TextStyle defaultTextStyle = AppTheme.safeOutfit(
      color: effectiveTextColor,
      fontSize: AppTheme.fontSizeMedium,
      fontWeight: AppTheme.fontWeightMedium,
    );
    final TextStyle finalTextStyle = textStyle ?? defaultTextStyle;

    List<Widget> children = [];
    if (text != null && text!.isNotEmpty) {
      if (mainAxisAlignment == MainAxisAlignment.start && icon != null) {
        children.add(Expanded(child: Text(text!, style: finalTextStyle, overflow: TextOverflow.ellipsis)));
      } else {
        children.add(Text(text!, style: finalTextStyle, overflow: TextOverflow.ellipsis));
      }
      if (icon != null) {
        children.add(SizedBox(width: effectiveInternalSpacing));
      }
    }
    if (icon != null) {
      children.add(Icon(icon!, size: effectiveIconSize, color: effectiveIconColor));
    }

    Widget buttonContent = Container(
      height: effectiveButtonHeight,
      padding: effectivePadding,
      decoration: ShapeDecoration(
        color: effectiveBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius)
        )
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children
      )
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

/// A row with two horizontally expanded buttons, each containing left-aligned
/// text and a right-aligned icon, separated by a specified spacing.
class SpacedButtonsDouble extends StatelessWidget {
  // Button 1
  final String text1;
  final IconData icon1;
  final VoidCallback? onTap1;

  // Button 2
  final String text2;
  final IconData icon2;
  final VoidCallback? onTap2;

  /// Spacing between the two buttons. Defaults to AppTheme.smallGap.
  final double? spacing;

  // Common styling properties
  final Color? buttonBackgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? borderRadius;
  final double? buttonHeight;
  final EdgeInsetsGeometry? buttonPadding;
  final TextStyle? textStyle;
  final double? iconSize;
  final double? internalButtonSpacing; // Spacing within each button (text to icon)

  const SpacedButtonsDouble({
    super.key,
    required this.text1,
    required this.icon1,
    this.onTap1,
    required this.text2,
    required this.icon2,
    this.onTap2,
    this.spacing,
    this.buttonBackgroundColor,
    this.textColor,
    this.iconColor,
    this.borderRadius,
    this.buttonHeight,
    this.buttonPadding,
    this.textStyle,
    this.iconSize,
    this.internalButtonSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final double effectiveSpacing = spacing ?? AppTheme.smallGap;

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: _TextIconButton(
              text: text1,
              icon: icon1,
              onTap: onTap1,
              backgroundColor: buttonBackgroundColor,
              textColor: textColor,
              iconColor: iconColor,
              borderRadius: borderRadius,
              buttonHeight: buttonHeight ?? AppTheme.navButtonHeight,
              padding: buttonPadding ?? const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap),
              textStyle: textStyle,
              iconSize: iconSize,
              mainAxisAlignment: MainAxisAlignment.start,
              internalSpacing: internalButtonSpacing ?? AppTheme.mediumGap,
            ),
          ),
          SizedBox(width: effectiveSpacing),
          Expanded(
            child: _TextIconButton(
              text: text2,
              icon: icon2,
              onTap: onTap2,
              backgroundColor: buttonBackgroundColor,
              textColor: textColor,
              iconColor: iconColor,
              borderRadius: borderRadius,
              buttonHeight: buttonHeight ?? AppTheme.navButtonHeight,
              padding: buttonPadding ?? const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap),
              textStyle: textStyle,
              iconSize: iconSize,
              mainAxisAlignment: MainAxisAlignment.start,
              internalSpacing: internalButtonSpacing ?? AppTheme.mediumGap,
            ),
          ),
        ],
      ),
    );
  }
}


