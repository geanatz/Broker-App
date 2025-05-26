// lib/components/forms/form_container2.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:broker_app/frontend/common/appTheme.dart'; // Import AppTheme instead of placeholder

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
    final Color effectiveHeaderTextColor = headerTextColor ?? AppTheme.elementColor1; 
    final Color effectiveValueTextColor = fieldValueTextColor ?? AppTheme.elementColor2; 
    final Color effectiveIconColor = iconColor ?? AppTheme.elementColor2; 
    final Color effectiveContentContainerColor = contentContainerColor ?? AppTheme.containerColor2; 
    final double effectiveContentBorderRadius = contentBorderRadius ?? 16.0; 


    final TextStyle titleStyle = GoogleFonts.outfit(
      color: effectiveHeaderTextColor,
      fontSize: 17,
      fontWeight: FontWeight.w600,
    );
    final TextStyle valueStyle = GoogleFonts.outfit(
      color: effectiveValueTextColor,
      fontSize: 17,
      fontWeight: FontWeight.w500,
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

/// A form container with two rows of fields.
class FormContainer2 extends StatelessWidget {
  // ... (rest of the parameters as before) ...
  final String titleR1F1;
  final String optionR1F1;
  final IconData? iconR1F1;
  final VoidCallback? onTapR1F1;
  final String titleR1F2;
  final String optionR1F2;
  final IconData? iconR1F2;
  final VoidCallback? onTapR1F2;
  final String titleR2F1;
  final String textR2F1;
  final VoidCallback? onTapR2F1;
  final String titleR2F2;
  final String textR2F2;
  final VoidCallback? onTapR2F2;
  final String titleR2F3;
  final String textR2F3;
  final VoidCallback? onTapR2F3;
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
  
  // Child widget parameters
  final Widget? child1R1F1; // Child widget for R1F1 dropdown field
  final Widget? child1R1F2; // Child widget for R1F2 dropdown field
  final Widget? child1; // Child widget for R2F1 field
  final Widget? child2; // Child widget for R2F2 field
  final Widget? child3; // Child widget for R2F3 field

  const FormContainer2({
    super.key, // Corrected
    this.titleR1F1 = 'Titlu', this.optionR1F1 = 'Optiune', this.iconR1F1 = Icons.expand_more, this.onTapR1F1,
    this.titleR1F2 = 'Titlu', this.optionR1F2 = 'Optiune', this.iconR1F2 = Icons.expand_more, this.onTapR1F2,
    this.titleR2F1 = 'Titlu', this.textR2F1 = 'Text', this.onTapR2F1,
    this.titleR2F2 = 'Titlu', this.textR2F2 = 'Text', this.onTapR2F2,
    this.titleR2F3 = 'Titlu', this.textR2F3 = 'Text', this.onTapR2F3,
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
    this.child1,
    this.child2,
    this.child3,
    this.child1R1F1,
    this.child1R1F2,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveOuterContainerColor = outerContainerColor ?? AppTheme.containerColor1;
    final double effectiveOuterBorderRadius = outerBorderRadius ?? 24.0;
    final EdgeInsetsGeometry effectiveOuterPadding = outerPadding ?? const EdgeInsets.all(8);
    final double effectiveRowSpacing = rowSpacing ?? 8.0;
    final double effectiveColumnSpacing = columnSpacing ?? 8.0;
    
    // Helper function to create a custom input field
    Widget _buildCustomField(String title, String defaultText, Widget? child, VoidCallback? onTap, {IconData? icon}) {
      if (child != null) {
        // We have a custom child widget to use instead of the standard field
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 21.0, // Standard header height
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  color: fieldHeaderTextColor ?? AppTheme.elementColor1,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4), // Standard spacing
            Container(
              width: double.infinity,
              height: 48.0, // Standard content height
              decoration: ShapeDecoration(
                color: fieldContentContainerColor ?? AppTheme.containerColor2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(fieldContentBorderRadius ?? 16.0),
                ),
              ),
              child: child,
            ),
          ],
        );
      } else {
        // Use the standard field
        return _FormFieldContainer(
          title: title,
          mainText: defaultText,
          icon: icon,
          onTap: onTap,
          headerTextColor: fieldHeaderTextColor,
          fieldValueTextColor: fieldValueTextColor,
          iconColor: fieldIconColor,
          contentContainerColor: fieldContentContainerColor,
          contentBorderRadius: fieldContentBorderRadius,
        );
      }
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
          Row(
            children: [
              Expanded(
                child: child1R1F1 != null 
                  ? _buildCustomField(
                      titleR1F1, 
                      optionR1F1, 
                      child1R1F1, 
                      onTapR1F1,
                      icon: iconR1F1,
                    )
                  : _FormFieldContainer(
                      title: titleR1F1, mainText: optionR1F1, icon: iconR1F1, onTap: onTapR1F1,
                      headerTextColor: fieldHeaderTextColor, fieldValueTextColor: fieldValueTextColor, iconColor: fieldIconColor,
                      contentContainerColor: fieldContentContainerColor, contentBorderRadius: fieldContentBorderRadius,
                    ),
              ),
              SizedBox(width: effectiveColumnSpacing),
              Expanded(
                child: child1R1F2 != null 
                  ? _buildCustomField(
                      titleR1F2, 
                      optionR1F2, 
                      child1R1F2, 
                      onTapR1F2,
                      icon: iconR1F2,
                    )
                  : _FormFieldContainer(
                      title: titleR1F2, mainText: optionR1F2, icon: iconR1F2, onTap: onTapR1F2,
                      headerTextColor: fieldHeaderTextColor, fieldValueTextColor: fieldValueTextColor, iconColor: fieldIconColor,
                      contentContainerColor: fieldContentContainerColor, contentBorderRadius: fieldContentBorderRadius,
                    ),
              ),
            ],
          ),
          SizedBox(height: effectiveRowSpacing),
          Row(
            children: [
              Expanded(
                child: _buildCustomField(
                  titleR2F1, 
                  textR2F1, 
                  child1, 
                  onTapR2F1,
                ),
              ),
              SizedBox(width: effectiveColumnSpacing),
              Expanded(
                child: _buildCustomField(
                  titleR2F2, 
                  textR2F2, 
                  child2, 
                  onTapR2F2,
                ),
              ),
              SizedBox(width: effectiveColumnSpacing),
              Expanded(
                child: _buildCustomField(
                  titleR2F3, 
                  textR2F3, 
                  child3, 
                  onTapR2F3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}