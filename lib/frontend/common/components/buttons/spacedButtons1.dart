// lib/components/buttons/spaced_button_single.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:broker_app/frontend/common/appTheme.dart';

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

    final TextStyle defaultTextStyle = GoogleFonts.outfit(
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
    final Color effectiveBackgroundColor = backgroundColor ?? AppTheme.containerColor1;
    final Color effectiveTextColor = textColor ?? AppTheme.elementColor2;
    final Color effectiveIconColor = iconColor ?? AppTheme.elementColor2;
    final double effectiveBorderRadius = borderRadius ?? AppTheme.borderRadiusMedium;
    final double effectiveButtonHeight = buttonHeight ?? AppTheme.navButtonHeight;
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap);
    final double effectiveIconSize = iconSize ?? AppTheme.iconSizeMedium;
    final double effectiveInternalSpacing = internalSpacing ?? AppTheme.mediumGap;
    
    final TextStyle defaultTextStyle = GoogleFonts.outfit(
      color: effectiveTextColor,
      fontSize: AppTheme.fontSizeMedium,
      fontWeight: AppTheme.fontWeightMedium,
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
    return SizedBox(
      width: double.infinity,
      height: buttonHeight ?? AppTheme.navButtonHeight,
      child: Row(
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
              buttonHeight: buttonHeight ?? AppTheme.navButtonHeight,
              padding: padding ?? const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap),
              textStyle: textStyle,
              iconSize: iconSize,
              mainAxisAlignment: MainAxisAlignment.start,
              internalSpacing: internalSpacing ?? AppTheme.mediumGap,
            ),
          ),
        ],
      ),
    );
  }
}