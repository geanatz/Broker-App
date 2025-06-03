// lib/components/items/dark_item6.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../appTheme.dart';

/// A customizable item component with a primary title on the left
/// and an optional icon on the right, housed within a padded square container.
///
/// The item has a specific padding and a height of 64.
/// The icon container has its own padding and rounded corners.
class DarkItem6 extends StatelessWidget {
  /// The primary title text.
  final String title;

  /// Optional icon data to display on the right.
  final IconData? icon;

  /// Optional SVG asset path to display on the right (takes precedence over icon).
  final String? svgAsset;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  /// Optional custom background color for the main container.
  /// Defaults to AppTheme.containerColor2 if not provided.
  final Color? backgroundColor;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor3 if not provided.
  final Color? titleColor;

  /// Optional custom color for the icon.
  /// Defaults to AppTheme.elementColor3 if not provided.
  final Color? iconColor;

  /// Optional custom background color for the icon's immediate container.
  /// Defaults to transparent.
  final Color? iconContainerColor;

  /// Optional custom border radius for the main container.
  /// Defaults to 24.0.
  final double? mainBorderRadius;

  /// Optional custom border radius for the icon's container.
  /// Defaults to 16.0.
  final double? iconContainerBorderRadius;

  /// Optional size for the icon itself.
  /// Defaults to 24.0.
  final double? iconSize;

  const DarkItem6({
    super.key,
    required this.title,
    this.icon,
    this.svgAsset,
    this.onTap,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
    this.iconContainerColor,
    this.mainBorderRadius,
    this.iconContainerBorderRadius,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBackgroundColor = backgroundColor ?? AppTheme.containerColor2;
    final Color effectiveTitleColor = titleColor ?? AppTheme.elementColor3;
    final Color effectiveIconColor = iconColor ?? AppTheme.elementColor3;
    final Color effectiveIconContainerColor = iconContainerColor ?? Colors.transparent;
    final double effectiveMainBorderRadius = mainBorderRadius ?? AppTheme.borderRadiusMedium;
    final double effectiveIconContainerBorderRadius = iconContainerBorderRadius ?? AppTheme.borderRadiusSmall;
    final double itemHeight = 64.0;
    final double internalSpacing = AppTheme.mediumGap;

    final EdgeInsetsGeometry mainPadding = const EdgeInsets.only(
      top: AppTheme.smallGap, 
      left: AppTheme.mediumGap, 
      right: AppTheme.smallGap, 
      bottom: AppTheme.smallGap
    );

    final double iconContainerSize = 48.0;

    final TextStyle titleStyle = GoogleFonts.outfit(
      color: effectiveTitleColor,
      fontSize: AppTheme.fontSizeMedium,
      fontWeight: FontWeight.w600,
    );

    // Determine if we should show an icon (either SVG or IconData)
    final bool hasIcon = svgAsset != null || icon != null;

    Widget content = Container(
      width: double.infinity,
      height: itemHeight,
      padding: mainPadding,
      decoration: ShapeDecoration(
        color: effectiveBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveMainBorderRadius),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: titleStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          if (hasIcon) ...[
            SizedBox(width: internalSpacing),
            Container(
              width: iconContainerSize,
              height: iconContainerSize,
              decoration: ShapeDecoration(
                color: effectiveIconContainerColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(effectiveIconContainerBorderRadius),
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: svgAsset != null
                      ? SvgPicture.asset(
                          svgAsset!,
                          width: 24.0,
                          height: 24.0,
                          colorFilter: ColorFilter.mode(effectiveIconColor, BlendMode.srcIn),
                          fit: BoxFit.contain,
                        )
                      : icon != null
                          ? Icon(
                              icon,
                              size: 24.0,
                              color: effectiveIconColor,
                            )
                          : Container(),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(effectiveMainBorderRadius),
          child: content,
        ),
      );
    }
    return content;
  }
}