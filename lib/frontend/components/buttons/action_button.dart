import 'package:broker_app/app_theme.dart';
import 'package:flutter/material.dart';

/// A button component for actions, supporting both text and icon buttons.
///
/// This component provides a standardized button with optional text and icon,
/// customizable colors, and a consistent rounded shape.
class ActionButton extends StatelessWidget {
  /// Optional text to display on the button.
  final String? text;

  /// Optional icon to display on the button.
  final IconData? icon;

  /// Callback when the button is tapped.
  final VoidCallback? onTap;

  /// Optional background color for the button.
  /// Defaults to AppTheme.containerColor1.
  final Color? backgroundColor;

  /// Optional text color.
  /// Defaults to AppTheme.elementColor2.
  final Color? textColor;

  /// Optional icon color.
  /// Defaults to AppTheme.elementColor2.
  final Color? iconColor;

  /// Optional border radius for the button.
  /// Defaults to AppTheme.borderRadiusMedium.
  final double? borderRadius;

  /// Optional custom height for the button.
  /// Defaults to 48.0.
  final double? height;

  /// Optional custom width for the button.
  /// If null and no text is provided, defaults to 48.0 (square button).
  final double? width;

  /// Optional padding for the button.
  /// Defaults to horizontal: AppTheme.mediumGap, vertical: 12.
  final EdgeInsetsGeometry? padding;

  /// Optional text style for the button text.
  final TextStyle? textStyle;

  /// Optional icon size.
  /// Defaults to AppTheme.iconSizeMedium.
  final double? iconSize;

  /// Whether the icon should appear after the text.
  /// Defaults to false (icon appears before text if both are provided).
  final bool iconAfterText;

  /// Optional spacing between icon and text.
  /// Defaults to AppTheme.smallGap.
  final double? spacing;

  const ActionButton({
    super.key,
    this.text,
    this.icon,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.borderRadius,
    this.height,
    this.width,
    this.padding,
    this.textStyle,
    this.iconSize,
    this.iconAfterText = false,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBackgroundColor = backgroundColor ?? AppTheme.containerColor1;
    final Color effectiveTextColor = textColor ?? AppTheme.elementColor2;
    final Color effectiveIconColor = iconColor ?? AppTheme.elementColor2;
    final double effectiveBorderRadius = borderRadius ?? AppTheme.borderRadiusMedium;
    final double effectiveHeight = height ?? 48.0;
    final double effectiveIconSize = iconSize ?? AppTheme.iconSizeMedium;
    final double effectiveSpacing = spacing ?? AppTheme.smallGap;

    final bool hasText = text != null && text!.isNotEmpty;
    final bool hasIcon = icon != null;
    
    // Calculate effective width
    final double? effectiveWidth = width ?? (hasText ? null : 48.0);

    // Default padding based on content
    final EdgeInsetsGeometry effectivePadding = padding ?? 
        (hasText 
          ? const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap, vertical: 12) 
          : const EdgeInsets.all(12));

    final TextStyle defaultTextStyle = TextStyle(
      color: effectiveTextColor,
      fontSize: AppTheme.fontSizeMedium,
      fontFamily: AppTheme.fontFamily,
      fontWeight: FontWeight.w500,
    );

    final TextStyle effectiveTextStyle = textStyle ?? defaultTextStyle;

    Widget buttonContent = Container(
      width: effectiveWidth,
      height: effectiveHeight,
      padding: effectivePadding,
      decoration: ShapeDecoration(
        color: effectiveBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
        ),
      ),
      child: Row(
        mainAxisSize: hasText ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (hasIcon && !iconAfterText)
            Icon(
              icon,
              size: effectiveIconSize,
              color: effectiveIconColor,
            ),
          if (hasIcon && hasText && !iconAfterText)
            SizedBox(width: effectiveSpacing),
          if (hasText)
            Text(
              text!,
              style: effectiveTextStyle,
            ),
          if (hasIcon && hasText && iconAfterText)
            SizedBox(width: effectiveSpacing),
          if (hasIcon && iconAfterText)
            Icon(
              icon,
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

