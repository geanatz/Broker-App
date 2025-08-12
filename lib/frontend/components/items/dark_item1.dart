import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DarkItem1 extends StatelessWidget {
  /// The text label to display inside the item.
  final String title;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  /// Optional custom background color for the container.
  /// Defaults to AppTheme.containerColor2 (0xFFACACD2) if not provided.
  final Color? backgroundColor;

  /// Optional custom color for the text label.
  /// Defaults to AppTheme.elementColor3 (0xFF4D4D80) if not provided.
  final Color? textColor;

  /// Optional custom border radius for the container.
  /// Defaults to 24.0 if not provided.
  final double? borderRadius;

  const DarkItem1({
    super.key,
    required this.title,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    // These colors are based on your snippet's comments.
    // Replace with actual AppTheme values like AppTheme.containerColor2 etc. when AppTheme is available.
    final Color effectiveBackgroundColor = backgroundColor ?? const Color(0xFFACACD2); // AppTheme.containerColor2
    final Color effectiveTextColor = textColor ?? const Color(0xFF4D4D80); // AppTheme.elementColor3

    // These dimensions and styling are directly from your snippet.
    // Consider replacing with AppTheme constants (e.g., AppTheme.itemHeightMedium, AppTheme.paddingMedium, AppTheme.fontSizeMedium, AppTheme.fontFamilyPrimary, AppTheme.fontWeightMedium) when AppTheme is available.
    final double effectiveBorderRadius = borderRadius ?? 24.0;
    final double itemHeight = 48.0;
    final double horizontalPadding = 16.0;
    final double fontSize = 17;
    final FontWeight fontWeight = FontWeight.w500;
    // The original snippet had 'spacing: 16' and 'spacing: 10' on Rows, but they were ineffective
    // as there was only one child in each Row that would consume the space (the Expanded widget).
    // These unused spacing properties have been omitted.

    Widget content = Container(
      // width: double.infinity is often controlled by the parent, e.g., Expanded, Column, Row.
      // Keeping it as in original, but be mindful of parent constraints.
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
        // mainAxisSize: MainAxisSize.min, // Redundant when width is infinity or constrained
        mainAxisAlignment: MainAxisAlignment.start, // Align content to the start
        crossAxisAlignment: CrossAxisAlignment.center, // Vertically center content
        children: [
          Expanded(
            // Original had a Container wrapper here with empty decoration and clipBehavior, which is redundant.
            child: Row(
              mainAxisSize: MainAxisSize.min, // Fine, but not strictly needed inside Expanded
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: effectiveTextColor,
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                  ),
                  // Consider adding overflow: TextOverflow.ellipsis if text might exceed width
                ),
              ],
            ),
          ),
          // Add other potential widgets here if the component were more complex (e.g., icon, button)
          // SizedBox(width: AppTheme.mediumGap), // Example: Add spacing if there were widgets after the text
        ],
      ),
    );

    // Wrap with InkWell if onTap is provided to make it tappable
    if (onTap != null) {
      // Using Material widget as a standard practice to ensure InkWell visuals work correctly,
      // especially if the parent widget is not Material. Making it transparent.
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          // Apply the same border radius to the InkWell splash effect
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          child: content,
        ),
      );
    }

    return content;
  }
}

