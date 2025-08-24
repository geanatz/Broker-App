import 'package:mat_finance/app_theme.dart';
// lib/components/items/dark_item2.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A customizable item component with a pill shape, larger height,
/// and a single, vertically centered title.
///
/// This component displays a single line of text, which is vertically centered,
/// within a container that has a rounded, pill-like shape and a height of 64.
class DarkItem2 extends StatelessWidget {
  /// The text label to display inside the item.
  final String title;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  /// Optional custom background color for the container.
  /// Defaults to AppTheme.backgroundColor3 (0xFFACACD2) if not provided.
  final Color? backgroundColor;

  /// Optional custom color for the text label.
  /// Defaults to AppTheme.elementColor3 (0xFF4D4D80) if not provided.
  final Color? titleColor;

  /// Optional custom border radius for the container.
  /// Defaults to 24.0 if not provided.
  final double? borderRadius;

  /// Optional custom height for the container.
  /// Defaults to 64.0 if not provided.
  final double? itemHeight;

  const DarkItem2({
    super.key,
    required this.title,
    this.onTap,
    this.backgroundColor,
    this.titleColor,
    this.borderRadius,
    this.itemHeight,
  });

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveBackgroundColor = backgroundColor ?? const Color(0xFFACACD2); // AppTheme.backgroundColor3
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF4D4D80); // AppTheme.elementColor3
    final double effectiveBorderRadius = borderRadius ?? 24.0; // AppTheme.borderRadiusLarge
    final double effectiveItemHeight = itemHeight ?? 64.0; // AppTheme.itemHeightLarge

    // Text Style (Consider moving to AppTheme)
    final TextStyle titleStyle = GoogleFonts.outfit(
      color: effectiveTitleColor,
      fontSize: AppTheme.fontSizeMedium,
      fontWeight: FontWeight.w600, // AppTheme.fontWeightSemiBold
    );

    // Padding (Consider moving to AppTheme)
    final EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12); // AppTheme.paddingMediumWithVerticalSmall

    Widget content = Container(
      width: double.infinity,
      height: effectiveItemHeight,
      padding: padding,
      decoration: ShapeDecoration(
        color: effectiveBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
        ),
      ),
      child: Row(
        // mainAxisSize: MainAxisSize.min, // Row will expand due to Expanded child
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        // spacing: 16, // Ineffective with single Expanded child, use SizedBox if needed between multiple children
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Important for centering
              mainAxisAlignment: MainAxisAlignment.center, // Vertically centers the text
              crossAxisAlignment: CrossAxisAlignment.start,
              // spacing: 4, // Ineffective with single Text child
              children: [
                Text(
                  title,
                  style: titleStyle,
                  overflow: TextOverflow.ellipsis, // Good practice
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


