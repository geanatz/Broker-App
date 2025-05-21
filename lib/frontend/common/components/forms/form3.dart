// lib/components/forms/form_container3.dart

import 'package:flutter/material.dart';
// import 'package:your_app/theme/app_theme.dart'; // Placeholder

// --- PASTE THE CORRECTED _FormFieldContainer class definition here ---
// Helper widget to render a single field (dropdown or input type)
class _FormFieldContainer extends StatelessWidget {
  final String title;
  final String mainText; // "Optiune" or "Text"
  final IconData? icon; // Nullable for input fields
  final VoidCallback? onTap;

  final Color? headerTextColor;
  final Color? fieldValueTextColor; // Corrected parameter name
  final Color? iconColor;
  final Color? contentContainerColor;
  final double? contentBorderRadius;
  
  final double _fieldHeight = 73.0;
  final double _headerHeight = 21.0;
  final double _contentHeight = 48.0;
  final double _internalColumnSpacing = 4.0;
  final EdgeInsets _headerPadding = const EdgeInsets.symmetric(horizontal: 8);
  final EdgeInsets _contentPadding = const EdgeInsets.symmetric(horizontal: 16);
  final double _iconSize = 24.0;
  final double _contentRowSpacing = 16.0;


  const _FormFieldContainer({
    super.key, 
    required this.title,
    required this.mainText,
    this.icon,
    this.onTap,
    this.headerTextColor,
    this.fieldValueTextColor, 
    this.iconColor,
    this.contentContainerColor,
    this.contentBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveHeaderTextColor = headerTextColor ?? const Color(0xFF666699); 
    final Color effectiveValueTextColor = fieldValueTextColor ?? const Color(0xFF4D4D80); 
    final Color effectiveIconColor = iconColor ?? const Color(0xFF4D4D80); 
    final Color effectiveContentContainerColor = contentContainerColor ?? const Color(0xFFACACD2); 
    final double effectiveContentBorderRadius = contentBorderRadius ?? 16.0; 


    final TextStyle titleStyle = TextStyle(
      color: effectiveHeaderTextColor,
      fontSize: 17, fontFamily: 'Outfit', fontWeight: FontWeight.w600,
    );
    final TextStyle valueStyle = TextStyle(
      color: effectiveValueTextColor,
      fontSize: 17, fontFamily: 'Outfit', fontWeight: FontWeight.w500,
    );

    Widget fieldContentArea = Container(
      width: double.infinity,
      height: _contentHeight,
      padding: _contentPadding,
      decoration: ShapeDecoration(
        color: effectiveContentContainerColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveContentBorderRadius),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              mainText,
              style: valueStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (icon != null) ...[
            SizedBox(width: _contentRowSpacing),
            SizedBox(
              width: _iconSize,
              height: _iconSize,
              child: Icon(icon, size: _iconSize, color: effectiveIconColor),
            ),
          ],
        ],
      ),
    );
    
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 128), 
      child: SizedBox( 
        height: _fieldHeight, 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start, 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container( 
              width: double.infinity,
              height: _headerHeight,
              padding: _headerPadding,
              child: Row( 
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: titleStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: _internalColumnSpacing), 
            onTap != null 
              ? InkWell(onTap: onTap, borderRadius: BorderRadius.circular(effectiveContentBorderRadius), child: fieldContentArea) 
              : fieldContentArea,
          ],
        ),
      ),
    );
  }
}
// --- END OF _FormFieldContainer DEFINITION ---

/// A form container with three rows of fields.
class FormContainer3 extends StatelessWidget {
  // ... (rest of the parameters as before) ...
  final String titleR1F1, optionR1F1; final IconData? iconR1F1; final VoidCallback? onTapR1F1;
  final String titleR1F2, optionR1F2; final IconData? iconR1F2; final VoidCallback? onTapR1F2;
  final String titleR2F1, textR2F1; final VoidCallback? onTapR2F1;
  final String titleR2F2, textR2F2; final VoidCallback? onTapR2F2;
  final String titleR3F1, textR3F1; final VoidCallback? onTapR3F1;
  final String titleR3F2, textR3F2; final VoidCallback? onTapR3F2;
  final String titleR3F3, textR3F3; final VoidCallback? onTapR3F3;
  final String titleR3F4, textR3F4; final VoidCallback? onTapR3F4;
  final Color? outerContainerColor;
  final double? outerBorderRadius;
  final EdgeInsetsGeometry? outerPadding;
  final double? rowSpacing;
  final double? columnSpacing;
  final Color? fieldHeaderTextColor;
  final Color? fieldValueTextColor; // Public parameter
  final Color? fieldIconColor;
  final Color? fieldContentContainerColor;
  final double? fieldContentBorderRadius;

  const FormContainer3({
    super.key, // Corrected
    this.titleR1F1 = 'Titlu', this.optionR1F1 = 'Optiune', this.iconR1F1 = Icons.expand_more, this.onTapR1F1,
    this.titleR1F2 = 'Titlu', this.optionR1F2 = 'Optiune', this.iconR1F2 = Icons.expand_more, this.onTapR1F2,
    this.titleR2F1 = 'Titlu', this.textR2F1 = 'Text', this.onTapR2F1,
    this.titleR2F2 = 'Titlu', this.textR2F2 = 'Text', this.onTapR2F2,
    this.titleR3F1 = 'Titlu', this.textR3F1 = 'Text', this.onTapR3F1,
    this.titleR3F2 = 'Titlu', this.textR3F2 = 'Text', this.onTapR3F2,
    this.titleR3F3 = 'Titlu', this.textR3F3 = 'Text', this.onTapR3F3,
    this.titleR3F4 = 'Titlu', this.textR3F4 = 'Text', this.onTapR3F4,
    this.outerContainerColor, this.outerBorderRadius, this.outerPadding,
    this.rowSpacing, this.columnSpacing, this.fieldHeaderTextColor,
    this.fieldValueTextColor, // Public parameter
    this.fieldIconColor, this.fieldContentContainerColor,
    this.fieldContentBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveOuterContainerColor = outerContainerColor ?? const Color(0xFFC4C4D4);
    final double effectiveOuterBorderRadius = outerBorderRadius ?? 24.0;
    final EdgeInsetsGeometry effectiveOuterPadding = outerPadding ?? const EdgeInsets.all(8);
    final double effectiveRowSpacing = rowSpacing ?? 8.0;
    final double effectiveColumnSpacing = columnSpacing ?? 8.0;

    Widget buildField(String title, String mainText, {IconData? icon, VoidCallback? onTap}) {
        return _FormFieldContainer(
            title: title, mainText: mainText, icon: icon, onTap: onTap,
            headerTextColor: fieldHeaderTextColor, 
            fieldValueTextColor: fieldValueTextColor, // Pass it here
            iconColor: fieldIconColor,
            contentContainerColor: fieldContentContainerColor, 
            contentBorderRadius: fieldContentBorderRadius,
        );
    }

    return Container(
      width: double.infinity,
      padding: effectiveOuterPadding,
      decoration: ShapeDecoration(
        color: effectiveOuterContainerColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveOuterBorderRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row( // Row 1
            children: [
              Expanded(child: buildField(titleR1F1, optionR1F1, icon: iconR1F1, onTap: onTapR1F1)),
              SizedBox(width: effectiveColumnSpacing),
              Expanded(child: buildField(titleR1F2, optionR1F2, icon: iconR1F2, onTap: onTapR1F2)),
            ],
          ),
          SizedBox(height: effectiveRowSpacing),
          Row( // Row 2
            children: [
              Expanded(child: buildField(titleR2F1, textR2F1, onTap: onTapR2F1)),
              SizedBox(width: effectiveColumnSpacing),
              Expanded(child: buildField(titleR2F2, textR2F2, onTap: onTapR2F2)),
            ],
          ),
          SizedBox(height: effectiveRowSpacing),
          Row( // Row 3
            children: [
              Expanded(child: buildField(titleR3F1, textR3F1, onTap: onTapR3F1)),
              SizedBox(width: effectiveColumnSpacing),
              Expanded(child: buildField(titleR3F2, textR3F2, onTap: onTapR3F2)),
              SizedBox(width: effectiveColumnSpacing),
              Expanded(child: buildField(titleR3F3, textR3F3, onTap: onTapR3F3)),
              SizedBox(width: effectiveColumnSpacing),
              Expanded(child: buildField(titleR3F4, textR3F4, onTap: onTapR3F4)),
            ],
          ),
        ],
      ),
    );
  }
}