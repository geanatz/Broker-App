// lib/components/buttons/spaced_buttons_double.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder

// Assuming _TextIconButton is defined (copied for standalone example)
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
    final TextStyle defaultTextStyle = TextStyle(color: effectiveTextColor, fontSize: 17, fontFamily: GoogleFonts.outfit().fontFamily, fontWeight: FontWeight.w500);
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

  /// Spacing between the two buttons. Defaults to 8.0.
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
    Key? key,
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double effectiveSpacing = spacing ?? 8.0; // AppTheme.smallGap (spacing between buttons)

    return SizedBox(
      width: double.infinity,
      // height: buttonHeight ?? 48.0, // Not explicitly on outer container in snippet, but implied by children
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
              buttonHeight: buttonHeight ?? 48.0,
              padding: buttonPadding ?? const EdgeInsets.symmetric(horizontal: 16),
              textStyle: textStyle,
              iconSize: iconSize,
              mainAxisAlignment: MainAxisAlignment.start,
              internalSpacing: internalButtonSpacing ?? 16.0, // Snippet inner button spacing
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
              buttonHeight: buttonHeight ?? 48.0,
              padding: buttonPadding ?? const EdgeInsets.symmetric(horizontal: 16),
              textStyle: textStyle,
              iconSize: iconSize,
              mainAxisAlignment: MainAxisAlignment.start,
              internalSpacing: internalButtonSpacing ?? 16.0, // Snippet inner button spacing
            ),
          ),
        ],
      ),
    );
  }
}