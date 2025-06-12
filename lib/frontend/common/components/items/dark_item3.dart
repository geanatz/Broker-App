// lib/components/items/dark_item3.dart

import 'package:flutter/material.dart';
import 'package:broker_app/frontend/common/utils/safe_google_fonts.dart';
import '../../app_theme.dart';

/// A customizable item component with a primary title on the left
/// and a secondary description text on the right.
///
/// The item has a pill shape, and the description text is aligned to the right
/// within a container of a predefined width.
class DarkItem3 extends StatelessWidget {
  /// The primary title text displayed on the left.
  final String title;

  /// The secondary description text displayed on the right.
  final String description;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  /// Optional custom background color for the container.
  /// Defaults to AppTheme.containerColor2 if not provided.
  final Color? backgroundColor;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor3 if not provided.
  final Color? titleColor;

  /// Optional custom color for the description text.
  /// Defaults to AppTheme.elementColor2 if not provided.
  final Color? descriptionColor;

  /// Optional custom border radius for the container.
  /// Defaults to AppTheme.borderRadiusMedium if not provided.
  final double? borderRadius;

  /// Optional width for the container holding the description text.
  /// Defaults to 104.0.
  final double? descriptionContainerWidth;


  const DarkItem3({
    super.key,
    required this.title,
    required this.description,
    this.onTap,
    this.backgroundColor,
    this.titleColor,
    this.descriptionColor,
    this.borderRadius,
    this.descriptionContainerWidth,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBackgroundColor = backgroundColor ?? AppTheme.containerColor2;
    final Color effectiveTitleColor = titleColor ?? AppTheme.elementColor3;
    final Color effectiveDescriptionColor = descriptionColor ?? AppTheme.elementColor2;
    final double effectiveBorderRadius = borderRadius ?? AppTheme.borderRadiusMedium;
    final double itemHeight = 48.0;
    final double horizontalPadding = AppTheme.mediumGap;
    final double effectiveDescriptionContainerWidth = descriptionContainerWidth ?? 104.0;
    final double internalSpacing = AppTheme.mediumGap;

    // Text Styles
    final TextStyle titleStyle = SafeGoogleFonts.outfit(
      color: effectiveTitleColor,
      fontSize: AppTheme.fontSizeMedium,
      fontWeight: FontWeight.w500,
    );
    final TextStyle descriptionStyle = SafeGoogleFonts.outfit(
      color: effectiveDescriptionColor,
      fontSize: AppTheme.fontSizeSmall,
      fontWeight: FontWeight.w500,
    );

    Widget content = Container(
      width: double.infinity,
      height: itemHeight,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: ShapeDecoration(
        color: effectiveBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: titleStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: internalSpacing),
          SizedBox(
            width: effectiveDescriptionContainerWidth,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  description,
                  textAlign: TextAlign.right,
                  style: descriptionStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          child: content,
        ),
      );
    }
    return content;
  }
}

