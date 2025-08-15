import 'package:mat_finance/app_theme.dart';
// lib/components/buttons/flex_button_single.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Assuming _TextIconButton is defined (copied for standalone example)
class _TextIconButton extends StatefulWidget {
  final String? text; 
  final IconData? icon; 
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
  
  const _TextIconButton({
    this.text, 
    this.icon, 
    this.iconPath, // Added SVG support
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
    this.internalSpacing
  });

  @override
  State<_TextIconButton> createState() => _TextIconButtonState();
}

class _TextIconButtonState extends State<_TextIconButton> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = _isHovered || _isFocused;
    
    // Corrected color scheme: default uses containerColor1, hover/focus uses containerColor2
    final Color effectiveBackgroundColor = widget.backgroundColor ?? 
        (isInteractive ? AppTheme.containerColor2 : AppTheme.containerColor1);
    final Color effectiveTextColor = widget.textColor ?? 
        (isInteractive ? AppTheme.elementColor3 : AppTheme.elementColor2);
    final Color effectiveIconColor = widget.iconColor ?? 
        (isInteractive ? AppTheme.elementColor3 : AppTheme.elementColor2);
    final double effectiveBorderRadius = widget.borderRadius ?? AppTheme.borderRadiusSmall;
    final double effectiveButtonHeight = widget.buttonHeight ?? 48.0;
    final EdgeInsetsGeometry effectivePadding = widget.padding ?? const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap);
    final double effectiveIconSize = widget.iconSize ?? AppTheme.iconSizeMedium;
    final double effectiveInternalSpacing = widget.internalSpacing ?? AppTheme.smallGap;
    
    final TextStyle defaultTextStyle = AppTheme.safeOutfit(
      color: effectiveTextColor, 
      fontSize: AppTheme.fontSizeMedium, 
      fontWeight: FontWeight.w500
    );
    final TextStyle finalTextStyle = widget.textStyle?.copyWith(color: effectiveTextColor) ?? defaultTextStyle;
    
    List<Widget> children = [];
    if (widget.text != null && widget.text!.isNotEmpty) {
      if (widget.mainAxisAlignment == MainAxisAlignment.start && (widget.icon != null || widget.iconPath != null)) {
        children.add(Expanded(child: Text(widget.text!, style: finalTextStyle, overflow: TextOverflow.ellipsis)));
      } else {
        children.add(Text(widget.text!, style: finalTextStyle, overflow: TextOverflow.ellipsis));
      }
      if (widget.icon != null || widget.iconPath != null) { 
        children.add(SizedBox(width: effectiveInternalSpacing)); 
      }
    }
    
    // Support both IconData and SVG
    if (widget.iconPath != null) {
      children.add(
        SvgPicture.asset(
          widget.iconPath!,
          width: effectiveIconSize,
          height: effectiveIconSize,
          colorFilter: ColorFilter.mode(effectiveIconColor, BlendMode.srcIn),
        ),
      );
    } else if (widget.icon != null) { 
      children.add(Icon(widget.icon!, size: effectiveIconSize, color: effectiveIconColor)); 
    }
    
    Widget buttonContent = Container(
      height: effectiveButtonHeight, 
      padding: effectivePadding,
      decoration: ShapeDecoration(
        color: effectiveBackgroundColor, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(effectiveBorderRadius))
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, 
        mainAxisAlignment: widget.mainAxisAlignment, 
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: children
      )
    );
    
    if (widget.onTap != null) { 
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Focus(
          onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
          child: InkWell(
            onTap: widget.onTap, 
            borderRadius: BorderRadius.circular(effectiveBorderRadius), 
            child: buttonContent
          ),
        ),
      ); 
    }
    return buttonContent;
  }
}

/// A row with a single, horizontally expanded button containing centered text and a trailing icon.
class FlexButtonSingle extends StatelessWidget {
  final String text;
  final IconData? icon; // Made optional
  final String? iconPath; // Added SVG support

  final VoidCallback? onTap;

  // Styling properties
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? borderRadius;
  final double? buttonHeight;
  final EdgeInsetsGeometry? padding; // Padding for the button's content
  final TextStyle? textStyle;
  final double? iconSize;
  final double? internalSpacing; // Spacing between text and icon

  const FlexButtonSingle({
    super.key,
    required this.text,
    this.icon, // Made optional
    this.iconPath, // Added SVG support
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
      child: Row(
        children: [
          Expanded(
            child: _TextIconButton(
              text: text,
              icon: icon,
              iconPath: iconPath, // Added SVG support
              onTap: onTap,
              backgroundColor: backgroundColor,
              textColor: textColor,
              iconColor: iconColor,
              borderRadius: borderRadius,
              buttonHeight: buttonHeight,
              padding: padding ?? const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap),
              textStyle: textStyle,
              iconSize: iconSize,
              mainAxisAlignment: MainAxisAlignment.center,
              internalSpacing: internalSpacing ?? AppTheme.smallGap,
            ),
          ),
        ],
      ),
    );
  }
}


