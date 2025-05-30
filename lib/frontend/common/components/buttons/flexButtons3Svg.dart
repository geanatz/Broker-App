import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class _TextIconButtonSvg extends StatelessWidget {
  final String? text;
  final String? iconPath; // SVG asset path
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

  const _TextIconButtonSvg({
    this.text,
    this.iconPath,
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
    final Color effectiveBackgroundColor = backgroundColor ?? const Color(0xFFC4C4D4);
    final Color effectiveTextColor = textColor ?? const Color(0xFF666699);
    final Color effectiveIconColor = iconColor ?? const Color(0xFF666699);
    final double effectiveBorderRadius = borderRadius ?? 24.0;
    final double effectiveButtonHeight = buttonHeight ?? 48.0;
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 16);
    final double effectiveIconSize = iconSize ?? 24.0;
    final double effectiveInternalSpacing = internalSpacing ?? 8.0;
    
    final TextStyle defaultTextStyle = TextStyle(
      color: effectiveTextColor,
      fontSize: 17,
      fontFamily: GoogleFonts.outfit().fontFamily,
      fontWeight: FontWeight.w500,
    );
    final TextStyle finalTextStyle = textStyle ?? defaultTextStyle;
    
    List<Widget> children = [];
    
    if (text != null && text!.isNotEmpty) {
      if (mainAxisAlignment == MainAxisAlignment.start && iconPath != null) {
        children.add(Expanded(child: Text(text!, style: finalTextStyle, overflow: TextOverflow.ellipsis)));
      } else {
        children.add(Text(text!, style: finalTextStyle, overflow: TextOverflow.ellipsis));
      }
      if (iconPath != null) {
        children.add(SizedBox(width: effectiveInternalSpacing));
      }
    }
    
    if (iconPath != null) {
      children.add(
        SvgPicture.asset(
          iconPath!,
          width: effectiveIconSize,
          height: effectiveIconSize,
          colorFilter: ColorFilter.mode(effectiveIconColor, BlendMode.srcIn),
        ),
      );
    }
    
    Widget buttonContent = Container(
      height: effectiveButtonHeight,
      padding: effectivePadding,
      decoration: ShapeDecoration(
        color: effectiveBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(effectiveBorderRadius)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
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

class _IconOnlyButtonSvg extends StatelessWidget {
  final String iconPath; // SVG asset path
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? borderRadius;
  final double? buttonSize;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;

  const _IconOnlyButtonSvg({
    required this.iconPath,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius,
    this.buttonSize,
    this.padding,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBackgroundColor = backgroundColor ?? const Color(0xFFC4C4D4);
    final Color effectiveIconColor = iconColor ?? const Color(0xFF666699);
    final double effectiveBorderRadius = borderRadius ?? 24.0;
    final double effectiveButtonSize = buttonSize ?? 48.0;
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.all(12);
    final double effectiveIconSize = iconSize ?? 24.0;
    
    Widget buttonContent = Container(
      width: effectiveButtonSize,
      height: effectiveButtonSize,
      padding: effectivePadding,
      decoration: ShapeDecoration(
        color: effectiveBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(effectiveBorderRadius)),
      ),
      child: Center(
        child: SvgPicture.asset(
          iconPath,
          width: effectiveIconSize,
          height: effectiveIconSize,
          colorFilter: ColorFilter.mode(effectiveIconColor, BlendMode.srcIn),
        ),
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

/// A row with an expanded primary button (text + SVG icon) and two fixed-width trailing SVG icon-only buttons.
class FlexButtonWithTwoTrailingIconsSvg extends StatelessWidget {
  // Primary expanded button
  final String primaryButtonText;
  final String primaryButtonIconPath; // SVG asset path
  final VoidCallback? onPrimaryButtonTap;

  // First trailing icon button
  final String trailingIcon1Path; // SVG asset path
  final VoidCallback? onTrailingIcon1Tap;

  // Second trailing icon button
  final String trailingIcon2Path; // SVG asset path
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

  const FlexButtonWithTwoTrailingIconsSvg({
    super.key,
    required this.primaryButtonText,
    required this.primaryButtonIconPath,
    this.onPrimaryButtonTap,
    required this.trailingIcon1Path,
    this.onTrailingIcon1Tap,
    required this.trailingIcon2Path,
    this.onTrailingIcon2Tap,
    this.spacing,
    this.buttonBackgroundColor,
    this.textColor,
    this.iconColor,
    this.borderRadius,
    this.buttonHeight,
    this.trailingButtonSize,
    this.primaryButtonTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final double effectiveSpacing = spacing ?? 8.0;

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: _TextIconButtonSvg(
              text: primaryButtonText,
              iconPath: primaryButtonIconPath,
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
              iconSize: 24.0,
            ),
          ),
          SizedBox(width: effectiveSpacing),
          _IconOnlyButtonSvg(
            iconPath: trailingIcon1Path,
            onTap: onTrailingIcon1Tap,
            backgroundColor: buttonBackgroundColor,
            iconColor: iconColor,
            borderRadius: borderRadius,
            buttonSize: trailingButtonSize ?? 48.0,
            padding: const EdgeInsets.all(12),
            iconSize: 24.0,
          ),
          SizedBox(width: effectiveSpacing),
          _IconOnlyButtonSvg(
            iconPath: trailingIcon2Path,
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