// lib/components/items/dark_item7.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A customizable item component with a primary title, a secondary description
/// below it, and an optional icon on the right housed within a padded container.
///
/// The item has a specific padding and a height of 64. The text content is
/// vertically centered. The icon container has its own padding and rounded corners.
class DarkItem7 extends StatelessWidget {
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
  /// Defaults to AppTheme.containerColor2 (0xFFACACD2) if not provided.
  final Color? backgroundColor;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor3 (0xFF4D4D80) if not provided.
  final Color? titleColor;

  /// Optional custom color for the description text.
  /// Defaults to AppTheme.elementColor2 (0xFF666699) if not provided.
  final Color? descriptionColor;

  /// Optional custom color for the icon.
  /// Defaults to AppTheme.elementColor3 (0xFF4D4D80) if not provided.
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

  const DarkItem7({
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
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveBackgroundColor = backgroundColor ?? const Color(0xFFACACD2); // AppTheme.containerColor2
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF4D4D80); // AppTheme.elementColor3
    final Color effectiveDescriptionColor = descriptionColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final Color effectiveIconColor = iconColor ?? const Color(0xFF4D4D80); // AppTheme.elementColor3 (or dedicated icon color)
    final Color effectiveIconContainerColor = iconContainerColor ?? Colors.transparent;
    final double effectiveMainBorderRadius = mainBorderRadius ?? 24.0; // AppTheme.borderRadiusLarge
    final double effectiveIconContainerBorderRadius = iconContainerBorderRadius ?? 16.0; // AppTheme.borderRadiusMedium
    final double itemHeight = 64.0; // Increased from 64.0 to fix overflow
    final double effectiveIconSize = iconSize ?? 24.0; // AppTheme.iconSizeSmall
    final double textColumnSpacing = 3.0; // AppTheme.tinyGap
    final double internalRowSpacing = 16.0; // AppTheme.mediumGap (original spacing: 16 on Row)
    final double iconContainerSize = 48.0;

    // Specific padding for the main container from snippet
    final EdgeInsetsGeometry mainPadding = const EdgeInsets.only(top: 8, left: 16, right: 8, bottom: 8);

    // Text Styles (Consider moving to AppTheme)
    final TextStyle titleStyle = GoogleFonts.outfit(
      color: effectiveTitleColor,
      fontSize: 17, // AppTheme.fontSizeMedium
      fontWeight: FontWeight.w600, // AppTheme.fontWeightSemiBold
    );
    final TextStyle descriptionStyle = GoogleFonts.outfit(
      color: effectiveDescriptionColor,
      fontSize: 15, // AppTheme.fontSizeSmall
      fontWeight: FontWeight.w500, // AppTheme.fontWeightMedium
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
          ),
          if (hasIcon) ...[
            SizedBox(width: internalRowSpacing), // Original spacing: 16
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(effectiveIconContainerBorderRadius),
                child: Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: ShapeDecoration(
                    color: effectiveIconContainerColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(effectiveIconContainerBorderRadius),
                    ),
                  ),
                  child: Center(
                    child: svgAsset != null
                      ? SvgPicture.asset(
                          svgAsset!,
                          width: effectiveIconSize,
                          height: effectiveIconSize,
                          colorFilter: ColorFilter.mode(
                            effectiveIconColor,
                            BlendMode.srcIn,
                          ),
                        )
                      : Icon(
                          icon,
                          size: effectiveIconSize,
                          color: effectiveIconColor,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return content;
  }
}