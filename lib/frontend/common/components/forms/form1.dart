// lib/components/forms/form_container1.dart

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


/// A form container displaying a 2x2 grid of fields.
class FormContainer1 extends StatelessWidget {
  // ... (rest of the parameters as before) ...
  final String titleTL;
  final String optionTL;
  final IconData? iconTL;
  final VoidCallback? onTapTL;
  final String titleTR;
  final String optionTR;
  final IconData? iconTR;
  final VoidCallback? onTapTR;
  final String titleBL;
  final String textBL;
  final VoidCallback? onTapBL;
  final String titleBR;
  final String textBR;
  final VoidCallback? onTapBR;
  final Color? outerContainerColor;
  final double? outerBorderRadius;
  final EdgeInsetsGeometry? outerPadding;
  final double? rowSpacing; 
  final double? columnSpacing; 
  final Color? fieldHeaderTextColor;
  final Color? fieldValueTextColor; // This is the one that will be passed to _FormFieldContainer
  final Color? fieldIconColor;
  final Color? fieldContentContainerColor;
  final double? fieldContentBorderRadius;

  const FormContainer1({
    super.key, // Corrected
    this.titleTL = 'Titlu',
    this.optionTL = 'Optiune',
    this.iconTL = Icons.expand_more,
    this.onTapTL,
    this.titleTR = 'Titlu',
    this.optionTR = 'Optiune',
    this.iconTR = Icons.expand_more,
    this.onTapTR,
    this.titleBL = 'Titlu',
    this.textBL = 'Text',
    this.onTapBL,
    this.titleBR = 'Titlu',
    this.textBR = 'Text',
    this.onTapBR,
    this.outerContainerColor,
    this.outerBorderRadius,
    this.outerPadding,
    this.rowSpacing,
    this.columnSpacing,
    this.fieldHeaderTextColor,
    this.fieldValueTextColor, // Public parameter
    this.fieldIconColor,
    this.fieldContentContainerColor,
    this.fieldContentBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveOuterContainerColor = outerContainerColor ?? const Color(0xFFC4C4D4);
    final double effectiveOuterBorderRadius = outerBorderRadius ?? 24.0;
    final EdgeInsetsGeometry effectiveOuterPadding = outerPadding ?? const EdgeInsets.all(8);
    final double effectiveRowSpacing = rowSpacing ?? 8.0;
    final double effectiveColumnSpacing = columnSpacing ?? 8.0;

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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _FormFieldContainer(
                  title: titleTL,
                  mainText: optionTL,
                  icon: iconTL,
                  onTap: onTapTL,
                  headerTextColor: fieldHeaderTextColor,
                  fieldValueTextColor: fieldValueTextColor, // Pass it here
                  iconColor: fieldIconColor,
                  contentContainerColor: fieldContentContainerColor,
                  contentBorderRadius: fieldContentBorderRadius,
                ),
              ),
              SizedBox(width: effectiveColumnSpacing),
              Expanded(
                child: _FormFieldContainer(
                  title: titleTR,
                  mainText: optionTR,
                  icon: iconTR,
                  onTap: onTapTR,
                  headerTextColor: fieldHeaderTextColor,
                  fieldValueTextColor: fieldValueTextColor, // Pass it here
                  iconColor: fieldIconColor,
                  contentContainerColor: fieldContentContainerColor,
                  contentBorderRadius: fieldContentBorderRadius,
                ),
              ),
            ],
          ),
          SizedBox(height: effectiveRowSpacing),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _FormFieldContainer(
                  title: titleBL,
                  mainText: textBL,
                  onTap: onTapBL,
                  headerTextColor: fieldHeaderTextColor,
                  fieldValueTextColor: fieldValueTextColor, // Pass it here
                  contentContainerColor: fieldContentContainerColor,
                  contentBorderRadius: fieldContentBorderRadius,
                ),
              ),
              SizedBox(width: effectiveColumnSpacing),
              Expanded(
                child: _FormFieldContainer(
                  title: titleBR,
                  mainText: textBR,
                  onTap: onTapBR,
                  headerTextColor: fieldHeaderTextColor,
                  fieldValueTextColor: fieldValueTextColor, // Pass it here
                  contentContainerColor: fieldContentContainerColor,
                  contentBorderRadius: fieldContentBorderRadius,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}