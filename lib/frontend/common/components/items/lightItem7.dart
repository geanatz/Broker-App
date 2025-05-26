// lib/components/items/light_item7.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../appTheme.dart';

/// A customizable light-themed item with title, description, and an
/// optional icon in a styled trailing container.
class LightItem7 extends StatelessWidget {
  /// The primary title text.
  final String title;

  /// The secondary description text displayed below the title.
  final String description;

  /// Optional icon data to display on the right.
  final IconData? icon;

  /// Optional SVG asset path to display on the right (takes precedence over icon).
  final String? svgAsset;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  /// Optional custom background color for the main container.
  /// Defaults to AppTheme.containerColor1.
  final Color? backgroundColor;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor2.
  final Color? titleColor;

  /// Optional custom color for the description text.
  /// Defaults to AppTheme.elementColor1.
  final Color? descriptionColor;

  /// Optional custom color for the icon.
  /// Defaults to AppTheme.elementColor3 for contrast.
  final Color? iconColor;

  /// Optional custom background color for the icon's immediate container.
  /// Defaults to AppTheme.containerColor2.
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

  const LightItem7({
    Key? key,
    required this.title,
    required this.description,
    this.icon,
    this.svgAsset,
    this.onTap,
    this.backgroundColor,
    this.titleColor,
    this.descriptionColor,
    this.iconColor,
    this.iconContainerColor,
    this.mainBorderRadius,
    this.iconContainerBorderRadius,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color effectiveBackgroundColor = backgroundColor ?? AppTheme.containerColor1;
    final Color effectiveTitleColor = titleColor ?? AppTheme.elementColor2;
    final Color effectiveDescriptionColor = descriptionColor ?? AppTheme.elementColor1;
    final Color effectiveIconContainerColor = iconContainerColor ?? AppTheme.containerColor2;
    final Color effectiveIconColor = iconColor ?? AppTheme.elementColor3;

    final double effectiveMainBorderRadius = mainBorderRadius ?? AppTheme.borderRadiusMedium;
    final double effectiveIconContainerBorderRadius = iconContainerBorderRadius ?? AppTheme.borderRadiusSmall;
    final double itemHeight = 64.0;
    final double effectiveIconSize = iconSize ?? 24.0;
    final double textColumnSpacing = AppTheme.tinyGap-1;
    final double internalRowSpacing = AppTheme.mediumGap;
    final double iconContainerSize = 48.0;

    final EdgeInsetsGeometry mainPadding = const EdgeInsets.only(top: 8, left: 16, right: 8, bottom: 8);

    final TextStyle titleStyle = GoogleFonts.outfit(
      color: effectiveTitleColor,
      fontSize: AppTheme.fontSizeMedium,
      fontWeight: FontWeight.w600,
    );
    final TextStyle descriptionStyle = GoogleFonts.outfit(
      color: effectiveDescriptionColor,
      fontSize: AppTheme.fontSizeSmall,
      fontWeight: FontWeight.w500,
    );

    // Determine if we should show an icon (either SVG or IconData)
    final bool hasIcon = svgAsset != null || icon != null;

    Widget iconButton = hasIcon ? InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(effectiveIconContainerBorderRadius),
      child: Container(
        width: iconContainerSize,
        height: iconContainerSize,
        padding: const EdgeInsets.all(12),
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
    ) : Container();

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
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: titleStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: textColumnSpacing),
                Text(
                  description,
                  style: descriptionStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          if (hasIcon) SizedBox(width: internalRowSpacing),
          if (hasIcon) iconButton,
        ],
      ),
    );

    return content;
  }
}