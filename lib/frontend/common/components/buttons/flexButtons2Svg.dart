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

/// A row with an expanded primary button (text + SVG icon) and a fixed-width trailing SVG icon-only button.
class FlexButtonWithTrailingIconSvg extends StatelessWidget {
  // Primary expanded button
  final String primaryButtonText;
  final String primaryButtonIconPath; // SVG asset path
  final VoidCallback? onPrimaryButtonTap;

  // Trailing fixed-width icon button
  final String trailingIconPath; // SVG asset path
  final VoidCallback? onTrailingIconTap;

  /// Spacing between the expanded button and the fixed-width button. Defaults to 8.0.
  final double? spacing;

  // Styling properties
  final Color? buttonBackgroundColor; // Applies to both
  final Color? textColor; // For primary button
  final Color? iconColor; // Applies to both
  final double? borderRadius; // Applies to both
  final double? buttonHeight; // Applies to primary button
  final double? trailingButtonSize; // Size for the square trailing button
  final TextStyle? primaryButtonTextStyle;

  const FlexButtonWithTrailingIconSvg({
    super.key,
    required this.primaryButtonText,
    required this.primaryButtonIconPath,
    this.onPrimaryButtonTap,
    required this.trailingIconPath,
    this.onTrailingIconTap,
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
            iconPath: trailingIconPath,
            onTap: onTrailingIconTap,
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