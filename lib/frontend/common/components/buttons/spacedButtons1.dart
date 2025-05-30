// lib/components/buttons/spaced_button_single.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

/// A row with a single, horizontally expanded button containing left-aligned text
/// and a right-aligned SVG icon from assets.
class SpacedButtonSingleSvg extends StatelessWidget {
  final String text;
  final String iconPath; // Path to SVG asset
  final VoidCallback? onTap;

  // Styling properties
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? borderRadius;
  final double? buttonHeight;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final double? iconSize;
  final double? internalSpacing; // Spacing between text and icon

  const SpacedButtonSingleSvg({
    super.key,
    required this.text,
    required this.iconPath,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.borderRadius,
    this.buttonHeight,
    this.padding,
    this.textStyle,
    this.iconSize,
    this.internalSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBackgroundColor = backgroundColor ?? const Color(0xFFC4C4D4);
    final Color effectiveTextColor = textColor ?? const Color(0xFF666699);
    final Color effectiveIconColor = iconColor ?? const Color(0xFF666699);
    final double effectiveBorderRadius = borderRadius ?? 24.0;
    final double effectiveButtonHeight = buttonHeight ?? 48.0;
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 16);
    final double effectiveIconSize = iconSize ?? 24.0;
    final double effectiveInternalSpacing = internalSpacing ?? 16.0;
    
    final TextStyle defaultTextStyle = TextStyle(
      color: effectiveTextColor, 
      fontSize: 17, 
      fontFamily: GoogleFonts.outfit().fontFamily, 
      fontWeight: FontWeight.w500
    );
    final TextStyle finalTextStyle = textStyle ?? defaultTextStyle;

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              text,
              style: finalTextStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: effectiveInternalSpacing),
          SvgPicture.asset(
            iconPath,
            width: effectiveIconSize,
            height: effectiveIconSize,
            colorFilter: ColorFilter.mode(
              effectiveIconColor,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );

    return SizedBox(
      width: double.infinity,
      height: effectiveButtonHeight,
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
                child: buttonContent,
              ),
            )
          : buttonContent,
    );
  }
}

/// A row with a single, horizontally expanded button containing left-aligned text
/// and a right-aligned icon.
class SpacedButtonSingle extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onTap;

  // Styling properties
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? borderRadius;
  final double? buttonHeight;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final double? iconSize;
  final double? internalSpacing; // Spacing between text and icon

  const SpacedButtonSingle({
    super.key,
    required this.text,
    required this.icon,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.borderRadius,
    this.buttonHeight,
    this.padding,
    this.textStyle,
    this.iconSize,
    this.internalSpacing,
  });

  @override
  Widget build(BuildContext context) {
    // The outermost Container in snippet sets width: double.infinity, height: 48.
    // The Row with spacing:16 is not relevant for a single expanded button.
    return SizedBox(
      width: double.infinity,
      height: buttonHeight ?? 48.0, // Height from outer snippet container
      child: Row( // Ensures Expanded works
        children: [
          Expanded(
            child: _TextIconButton(
              text: text,
              icon: icon,
              onTap: onTap,
              backgroundColor: backgroundColor,
              textColor: textColor,
              iconColor: iconColor,
              borderRadius: borderRadius,
              buttonHeight: buttonHeight ?? 48.0, // Pass height to inner button
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 16), // Snippet padding
              textStyle: textStyle,
              iconSize: iconSize,
              mainAxisAlignment: MainAxisAlignment.start, // Key change for this type
              internalSpacing: internalSpacing ?? 16.0, // Snippet inner button spacing
            ),
          ),
        ],
      ),
    );
  }
}