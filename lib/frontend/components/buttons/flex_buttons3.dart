import 'package:mat_finance/app_theme.dart';
// lib/components/buttons/flex_button_with_two_trailing_icons.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Updated _TextIconButton with hover/focus states and AppTheme
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
    final double effectiveBorderRadius = widget.borderRadius ?? AppTheme.borderRadiusMedium;
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

// Updated _IconOnlyButton with hover/focus states and AppTheme
class _IconOnlyButton extends StatefulWidget {
  final IconData? iconData; 
  final String? iconPath; // SVG asset path
  final VoidCallback? onTap; 
  final Color? backgroundColor; 
  final Color? iconColor;
  final double? borderRadius; 
  final double? buttonSize; 
  final EdgeInsetsGeometry? padding; 
  final double? iconSize;
  
  const _IconOnlyButton({
    this.iconData, // Made optional
    this.iconPath, // Added SVG support
    this.onTap, 
    this.backgroundColor, 
    this.iconColor, 
    this.borderRadius,
    this.buttonSize, 
    this.padding, 
    this.iconSize
  });

  @override
  State<_IconOnlyButton> createState() => _IconOnlyButtonState();
}

class _IconOnlyButtonState extends State<_IconOnlyButton> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = _isHovered || _isFocused;
    
    // Corrected color scheme: default uses containerColor1, hover/focus uses containerColor2
    final Color effectiveBackgroundColor = widget.backgroundColor ?? 
        (isInteractive ? AppTheme.containerColor2 : AppTheme.containerColor1);
    final Color effectiveIconColor = widget.iconColor ?? 
        (isInteractive ? AppTheme.elementColor3 : AppTheme.elementColor2);
    final double effectiveBorderRadius = widget.borderRadius ?? AppTheme.borderRadiusMedium;
    final double effectiveButtonSize = widget.buttonSize ?? 48.0;
    final EdgeInsetsGeometry effectivePadding = widget.padding ?? const EdgeInsets.all(AppTheme.smallGap + 4); // 12px
    final double effectiveIconSize = widget.iconSize ?? AppTheme.iconSizeMedium;
    
    Widget iconWidget;
    if (widget.iconPath != null) {
      iconWidget = SvgPicture.asset(
        widget.iconPath!,
        width: effectiveIconSize,
        height: effectiveIconSize,
        colorFilter: ColorFilter.mode(effectiveIconColor, BlendMode.srcIn),
      );
    } else if (widget.iconData != null) {
      iconWidget = Icon(widget.iconData!, size: effectiveIconSize, color: effectiveIconColor);
    } else {
      iconWidget = const SizedBox.shrink(); // Fallback
    }
    
    Widget buttonContent = Container(
      width: effectiveButtonSize, 
      height: effectiveButtonSize, 
      padding: effectivePadding,
      decoration: ShapeDecoration(
        color: effectiveBackgroundColor, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(effectiveBorderRadius))
      ),
      child: Center(child: iconWidget)
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

/// A row with an expanded primary button (text + icon) and two fixed-width trailing icon-only buttons.
class FlexButtonWithTwoTrailingIcons extends StatelessWidget {
  // Primary expanded button
  final String primaryButtonText;
  final IconData? primaryButtonIcon; // Made optional
  final String? primaryButtonIconPath; // Added SVG support
  final VoidCallback? onPrimaryButtonTap;

  // First trailing icon button
  final IconData? trailingIcon1; // Made optional
  final String? trailingIcon1Path; // Added SVG support
  final VoidCallback? onTrailingIcon1Tap;

  // Second trailing icon button
  final IconData? trailingIcon2; // Made optional
  final String? trailingIcon2Path; // Added SVG support
  final VoidCallback? onTrailingIcon2Tap;

  /// Spacing between buttons. Defaults to AppTheme.smallGap.
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
    super.key,
    required this.primaryButtonText,
    this.primaryButtonIcon, // Made optional
    this.primaryButtonIconPath, // Added SVG support
    this.onPrimaryButtonTap,
    this.trailingIcon1, // Made optional
    this.trailingIcon1Path, // Added SVG support
    this.onTrailingIcon1Tap,
    this.trailingIcon2, // Made optional
    this.trailingIcon2Path, // Added SVG support
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
    final double effectiveSpacing = spacing ?? AppTheme.smallGap;

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: _TextIconButton(
              text: primaryButtonText,
              icon: primaryButtonIcon,
              iconPath: primaryButtonIconPath, // Added SVG support
              onTap: onPrimaryButtonTap,
              backgroundColor: buttonBackgroundColor,
              textColor: textColor,
              iconColor: iconColor,
              borderRadius: borderRadius,
              buttonHeight: buttonHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap, vertical: AppTheme.smallGap + 4), // 16, 12
              textStyle: primaryButtonTextStyle,
              mainAxisAlignment: MainAxisAlignment.center,
              internalSpacing: AppTheme.smallGap,
              iconSize: AppTheme.iconSizeMedium,
            ),
          ),
          SizedBox(width: effectiveSpacing),
          _IconOnlyButton(
            iconData: trailingIcon1,
            iconPath: trailingIcon1Path, // Added SVG support
            onTap: onTrailingIcon1Tap,
            backgroundColor: buttonBackgroundColor,
            iconColor: iconColor,
            borderRadius: borderRadius,
            buttonSize: trailingButtonSize ?? 48.0,
            padding: const EdgeInsets.all(AppTheme.smallGap + 4), // 12px
            iconSize: AppTheme.iconSizeMedium,
          ),
          SizedBox(width: effectiveSpacing),
          _IconOnlyButton(
            iconData: trailingIcon2,
            iconPath: trailingIcon2Path, // Added SVG support
            onTap: onTrailingIcon2Tap,
            backgroundColor: buttonBackgroundColor,
            iconColor: iconColor,
            borderRadius: borderRadius,
            buttonSize: trailingButtonSize ?? 48.0,
            padding: const EdgeInsets.all(AppTheme.smallGap + 4), // 12px
            iconSize: AppTheme.iconSizeMedium,
          ),
        ],
      ),
    );
  }
}


