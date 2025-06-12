// lib/components/headers/widget_header5.dart

import 'package:flutter/material.dart';
import 'package:broker_app/frontend/common/utils/safe_google_fonts.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder for AppTheme

/// A widget header with a stacked title and description on the left (expanded),
/// and a custom trailing widget on the right.
class WidgetHeader5 extends StatelessWidget {
  /// The main title text.
  final String title;

  /// The description text displayed below the title.
  final String description;

  /// The widget to display on the right side of the header.
  /// The original snippet had a specifically sized icon placeholder.
  final Widget? trailingWidget;

  /// Optional custom color for the title text.
  /// Defaults to AppTheme.elementColor2 (0xFF666699).
  final Color? titleColor;

  /// Optional custom text style for the title.
  final TextStyle? titleStyle;

  /// Optional custom color for the description text.
  /// Defaults to AppTheme.elementColor1 (0xFF8A8AA8).
  final Color? descriptionColor;

  /// Optional custom text style for the description.
  final TextStyle? descriptionStyle;

  /// Optional padding for the header container.
  /// Defaults to EdgeInsets.only(left: 16, right: 8).
  final EdgeInsetsGeometry? padding;

  /// Optional vertical spacing between the title and description.
  /// Defaults to 0.0.
  final double? spacingBetweenTexts;

  /// Optional horizontal spacing between the text block and the trailing widget.
  /// Defaults to 16.0.
  final double? mainRowSpacing;

  /// Alignment for the column of text. Defaults to CrossAxisAlignment.start.
  final CrossAxisAlignment? textColumnAlignment;


  const WidgetHeader5({
    super.key,
    required this.title,
    required this.description,
    this.trailingWidget,
    this.titleColor,
    this.titleStyle,
    this.descriptionColor,
    this.descriptionStyle,
    this.padding,
    this.spacingBetweenTexts,
    this.mainRowSpacing,
    this.textColumnAlignment,
  });

  @override
  Widget build(BuildContext context) {
    // --- Placeholder Values / Hardcoded Defaults ---
    final Color effectiveTitleColor = titleColor ?? const Color(0xFF666699); // AppTheme.elementColor2
    final Color effectiveDescriptionColor = descriptionColor ?? const Color(0xFF8A8AA8); // AppTheme.elementColor1
    final EdgeInsetsGeometry effectivePadding = padding ?? const EdgeInsets.only(left: 16, right: 8);
    final double effectiveTextSpacing = spacingBetweenTexts ?? 0.0; // AppTheme.tinyGap
    final double effectiveMainRowSpacing = mainRowSpacing ?? 16.0; // AppTheme.mediumGap
    final CrossAxisAlignment effectiveTextColumnAlignment = textColumnAlignment ?? CrossAxisAlignment.start;

    final TextStyle defaultTitleStyle = TextStyle(
      color: effectiveTitleColor,
      fontSize: 19, fontWeight: FontWeight.w500, fontFamily: SafeSafeGoogleFonts.fontFamily,
    );
    final TextStyle defaultDescriptionStyle = TextStyle(
      color: effectiveDescriptionColor,
      fontSize: 17, fontWeight: FontWeight.w500, fontFamily: SafeSafeGoogleFonts.fontFamily,
    );

    final TextStyle finalTitleStyle = titleStyle ?? defaultTitleStyle;
    final TextStyle finalDescriptionStyle = descriptionStyle ?? defaultDescriptionStyle;

    // Default icon placeholder from snippet if trailingWidget is null
    // This is complex and specific. Better to require a widget or make a dedicated Icon parameter.
    // For now, if trailingWidget is null, we show nothing. User can provide their own complex icon widget.
    // Widget defaultTrailingIconPlaceholder = Container(
    //   width: 48,
    //   height: 48,
    //   padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 13),
    //   child: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     children: [
    //       Container(
    //         width: 26.58,
    //         height: 22.40,
    //         child: Icon(Icons.image_outlined, color: effectiveDescriptionColor), // Placeholder icon
    //       ),
    //     ],
    //   ),
    // );

    return Container(
      width: double.infinity,
      padding: effectivePadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Vertically align text column and trailing widget
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center, // Vertically center text block if it's shorter
              crossAxisAlignment: effectiveTextColumnAlignment,
              children: [
                Text(
                  title,
                  style: finalTitleStyle,
                  textAlign: effectiveTextColumnAlignment == CrossAxisAlignment.center ? TextAlign.center : TextAlign.start,
                ),
                if (description.isNotEmpty) ...[
                  SizedBox(height: effectiveTextSpacing),
                  Text(
                    description,
                    style: finalDescriptionStyle,
                    textAlign: effectiveTextColumnAlignment == CrossAxisAlignment.center ? TextAlign.center : TextAlign.start,
                  ),
                ]
              ],
            ),
          ),
          if (trailingWidget != null) ...[
            SizedBox(width: effectiveMainRowSpacing), // Original Row spacing: 16
            // Original had Row > Container for the icon. Direct widget is simpler.
            trailingWidget!,
          ],
        ],
      ),
    );
  }
}

