// lib/components/items/outlined_item6.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../appTheme.dart';

/// A customizable outlined item component with a primary title on the left
/// and an optional icon on the right, housed within a transparent rounded container.
///
/// The main item has a prominent border. The icon container has rounded corners
/// but is transparent by default and has no border.
class OutlinedItem6 extends StatelessWidget {
  /// The primary title text.
  final String title;

  /// Optional icon data to display on the right.
  final IconData? icon;

  /// Optional SVG asset path to display on the right (takes precedence over icon).
  final String? svgAsset;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  /// Optional custom background color for the main container (inside the border).
  /// Defaults to transparent.
  final Color? mainBackgroundColor;

  /// Optional custom color for the main border.
  /// Defaults to AppTheme.containerColor2 (0xFFACACD2).
  final Color? mainBorderColor;

  /// Optional custom width for the main border.
  /// Defaults to 4.0.
  final double? mainBorderWidth;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor2 (0xFF666699).
  final Color? titleColor;

  /// Optional custom color for the icon.
  /// Defaults to AppTheme.elementColor2 (0xFF666699).
  final Color? iconColor;

  /// Optional custom background color for the icon's immediate container.
  /// Defaults to transparent as per snippet.
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

  const OutlinedItem6({
    Key? key,
    required this.title,
    this.icon,
    this.svgAsset,
    this.onTap,
    this.mainBackgroundColor,
    this.mainBorderColor,
    this.mainBorderWidth,
    this.titleColor,
    this.iconColor,
    this.iconContainerColor,
    this.mainBorderRadius,
    this.iconContainerBorderRadius,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color effectiveMainBackgroundColor = mainBackgroundColor ?? Colors.transparent;
    final Color effectiveMainBorderColor = mainBorderColor ?? AppTheme.containerColor2;
    final double effectiveMainBorderWidth = mainBorderWidth ?? 4.0;
    final Color effectiveTitleColor = titleColor ?? AppTheme.elementColor2;
    final Color effectiveIconColor = iconColor ?? AppTheme.elementColor2;
    final Color effectiveIconContainerColor = iconContainerColor ?? Colors.transparent;

    final double effectiveMainBorderRadius = mainBorderRadius ?? AppTheme.borderRadiusMedium;
    final double effectiveIconContainerBorderRadius = iconContainerBorderRadius ?? AppTheme.borderRadiusSmall;
    final double itemHeight = 64.0;
    final double effectiveIconSize = iconSize ?? 24.0;
    final double internalSpacing = AppTheme.mediumGap;
    final double iconContainerSize = 48.0;

    final EdgeInsetsGeometry mainPadding = const EdgeInsets.only(top: AppTheme.smallGap, left: AppTheme.mediumGap, right: AppTheme.smallGap, bottom: AppTheme.smallGap);

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
        color: effectiveMainBackgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: effectiveMainBorderWidth,
            color: effectiveMainBorderColor,
          ),
          borderRadius: BorderRadius.circular(effectiveMainBorderRadius),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox( // Original snippet has this inner container with height: 48
              height: 48,
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
          customBorder: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(effectiveMainBorderRadius),
          ),
          child: content,
        ),
      );
    }
    return content;
  }
}