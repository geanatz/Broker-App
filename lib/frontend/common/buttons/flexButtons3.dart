// lib/components/buttons/flex_button_with_two_trailing_icons.dart

import 'package:flutter/material.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder

// Assuming _TextIconButton and _IconOnlyButton are defined
// (Copied definitions for standalone example)
class _TextIconButton extends StatelessWidget { /* ... full definition ... */
  final String? text; final IconData? icon; final VoidCallback? onTap; final Color? backgroundColor;
  final Color? textColor; final Color? iconColor; final double? borderRadius; final double? buttonHeight;
  final EdgeInsetsGeometry? padding; final TextStyle? textStyle; final double? iconSize;
  final MainAxisAlignment mainAxisAlignment; final double? internalSpacing;
  const _TextIconButton({this.text, this.icon, this.onTap, this.backgroundColor, this.textColor, this.iconColor,
    this.borderRadius, this.buttonHeight, this.padding, this.textStyle, this.iconSize,
    this.mainAxisAlignment = MainAxisAlignment.center, this.internalSpacing});
  @override
  Widget build(BuildContext context) {
    final Color effectiveBackgroundColor = backgroundColor ?? const Color(0xFFC4C4D4);
    final Color effectiveTextColor = textColor ?? const Color(0xFF666699);
    final Color effectiveIconColor = iconColor ?? const Color(0xFF666699);
    final double effectiveBorderRadius = borderRadius ?? 24.0;
    final double effectiveButtonHeight = buttonHeight ?? 48.0;
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 16);
    final double effectiveIconSize = iconSize ?? 24.0;
    final double effectiveInternalSpacing = internalSpacing ?? 8.0;
    final TextStyle defaultTextStyle = TextStyle(color: effectiveTextColor, fontSize: 17, fontFamily: 'Outfit', fontWeight: FontWeight.w500);
    final TextStyle finalTextStyle = textStyle ?? defaultTextStyle;
    List<Widget> children = [];
    if (text != null && text!.isNotEmpty) {
      if (mainAxisAlignment == MainAxisAlignment.start && icon != null) {
        children.add(Expanded(child: Text(text!, style: finalTextStyle, overflow: TextOverflow.ellipsis)));
      } else {
        children.add(Text(text!, style: finalTextStyle, overflow: TextOverflow.ellipsis));
      }
      if (icon != null) { children.add(SizedBox(width: effectiveInternalSpacing)); }
    }
    if (icon != null) { children.add(Icon(icon!, size: effectiveIconSize, color: effectiveIconColor)); }
    Widget buttonContent = Container(height: effectiveButtonHeight, padding: effectivePadding,
      decoration: ShapeDecoration(color: effectiveBackgroundColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(effectiveBorderRadius))),
      child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: mainAxisAlignment, crossAxisAlignment: CrossAxisAlignment.center, children: children));
    if (onTap != null) { return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(effectiveBorderRadius), child: buttonContent); }
    return buttonContent;
  }
}
class _IconOnlyButton extends StatelessWidget { /* ... full definition ... */
  final IconData iconData; final VoidCallback? onTap; final Color? backgroundColor; final Color? iconColor;
  final double? borderRadius; final double? buttonSize; final EdgeInsetsGeometry? padding; final double? iconSize;
  const _IconOnlyButton({required this.iconData, this.onTap, this.backgroundColor, this.iconColor, this.borderRadius,
    this.buttonSize, this.padding, this.iconSize});
  @override
  Widget build(BuildContext context) {
    final Color effectiveBackgroundColor = backgroundColor ?? const Color(0xFFC4C4D4);
    final Color effectiveIconColor = iconColor ?? const Color(0xFF666699);
    final double effectiveBorderRadius = borderRadius ?? 24.0;
    final double effectiveButtonSize = buttonSize ?? 48.0;
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.all(12);
    final double effectiveIconSize = iconSize ?? 24.0;
    Widget buttonContent = Container(width: effectiveButtonSize, height: effectiveButtonSize, padding: effectivePadding,
      decoration: ShapeDecoration(color: effectiveBackgroundColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(effectiveBorderRadius))),
      child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
        children: [Icon(iconData, size: effectiveIconSize, color: effectiveIconColor)]));
    if (onTap != null) { return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(effectiveBorderRadius), child: buttonContent); }
    return buttonContent;
  }
}

/// A row with an expanded primary button (text + icon) and two fixed-width trailing icon-only buttons.
class FlexButtonWithTwoTrailingIcons extends StatelessWidget {
  // Primary expanded button
  final String primaryButtonText;
  final IconData primaryButtonIcon;
  final VoidCallback? onPrimaryButtonTap;

  // First trailing icon button
  final IconData trailingIcon1;
  final VoidCallback? onTrailingIcon1Tap;

  // Second trailing icon button
  final IconData trailingIcon2;
  final VoidCallback? onTrailingIcon2Tap;

  /// Spacing between buttons. Defaults to 8.0.
  final double? spacing;

  // Styling properties
  final Color? buttonBackgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? borderRadius;
  final double? buttonHeight;
  final double? trailingButtonSize;
  final TextStyle? primaryButtonTextStyle;

  const FlexButtonWithTwoTrailingIcons({
    Key? key,
    required this.primaryButtonText,
    required this.primaryButtonIcon,
    this.onPrimaryButtonTap,
    required this.trailingIcon1,
    this.onTrailingIcon1Tap,
    required this.trailingIcon2,
    this.onTrailingIcon2Tap,
    this.spacing,
    this.buttonBackgroundColor,
    this.textColor,
    this.iconColor,
    this.borderRadius,
    this.buttonHeight,
    this.trailingButtonSize,
    this.primaryButtonTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double effectiveSpacing = spacing ?? 8.0; // AppTheme.smallGap

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: _TextIconButton(
              text: primaryButtonText,
              icon: primaryButtonIcon,
              onTap: onPrimaryButtonTap,
              backgroundColor: buttonBackgroundColor,
              textColor: textColor,
              iconColor: iconColor,
              borderRadius: borderRadius,
              buttonHeight: buttonHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: primaryButtonTextStyle,
              mainAxisAlignment: MainAxisAlignment.center,
              internalSpacing: 8.0,
            ),
          ),
          SizedBox(width: effectiveSpacing),
          _IconOnlyButton(
            iconData: trailingIcon1,
            onTap: onTrailingIcon1Tap,
            backgroundColor: buttonBackgroundColor,
            iconColor: iconColor,
            borderRadius: borderRadius,
            buttonSize: trailingButtonSize ?? 48.0,
            padding: const EdgeInsets.all(12),
            iconSize: 24.0,
          ),
          SizedBox(width: effectiveSpacing),
          _IconOnlyButton(
            iconData: trailingIcon2,
            onTap: onTrailingIcon2Tap,
            backgroundColor: buttonBackgroundColor,
            iconColor: iconColor,
            borderRadius: borderRadius,
            buttonSize: trailingButtonSize ?? 48.0,
            padding: const EdgeInsets.all(12),
            iconSize: 24.0,
          ),
        ],
      ),
    );
  }
}