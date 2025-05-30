// lib/components/forms/form_container_new.dart

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

/// A form container displaying a single row with two dropdown-style fields.
class FormContainerNew extends StatefulWidget {
  // ... (rest of the parameters as before) ...
  final String titleF1;
  final String optionF1;
  final IconData? iconF1;
  final VoidCallback? onTapF1;
  final String titleF2;
  final String optionF2;
  final IconData? iconF2;
  final VoidCallback? onTapF2;
  final Color? outerContainerColor;
  final double? outerBorderRadius;
  final EdgeInsetsGeometry? outerPadding;
  final double? columnSpacing;
  final Color? fieldHeaderTextColor;
  final Color? fieldValueTextColor; // Public parameter
  final Color? fieldIconColor;
  final Color? fieldContentContainerColor;
  final double? fieldContentBorderRadius;

  // Child widget parameters
  final Widget? child1F1; // Child widget for F1 field
  final Widget? child1F2; // Child widget for F2 field
  
  // Close button callback
  final VoidCallback? onClose;

  const FormContainerNew({
    super.key, // Corrected
    this.titleF1 = 'Titlu', this.optionF1 = 'Optiune', this.iconF1 = Icons.expand_more, this.onTapF1,
    this.titleF2 = 'Titlu', this.optionF2 = 'Optiune', this.iconF2 = Icons.expand_more, this.onTapF2,
    this.outerContainerColor, this.outerBorderRadius, this.outerPadding,
    this.columnSpacing, this.fieldHeaderTextColor,
    this.fieldValueTextColor, // Public parameter
    this.fieldIconColor, this.fieldContentContainerColor,
    this.fieldContentBorderRadius,
    this.child1F1,
    this.child1F2,
    this.onClose, // Close button callback
  });

  @override
  State<FormContainerNew> createState() => _FormContainerNewState();
}

class _FormContainerNewState extends State<FormContainerNew> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color effectiveOuterContainerColor = widget.outerContainerColor ?? AppTheme.containerColor1;
    final double effectiveOuterBorderRadius = widget.outerBorderRadius ?? 24.0;
    final EdgeInsetsGeometry effectiveOuterPadding = widget.outerPadding ?? const EdgeInsets.all(8);
    final double effectiveColumnSpacing = widget.columnSpacing ?? 8.0;
    
    // Helper function to create a custom input field
    Widget buildCustomField(String title, String defaultText, Widget? child, VoidCallback? onTap, {IconData? icon}) {
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
                  color: widget.fieldHeaderTextColor ?? AppTheme.elementColor1,
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
                color: widget.fieldContentContainerColor ?? AppTheme.containerColor2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.fieldContentBorderRadius ?? 16.0),
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
          headerTextColor: widget.fieldHeaderTextColor,
          fieldValueTextColor: widget.fieldValueTextColor,
          iconColor: widget.fieldIconColor,
          contentContainerColor: widget.fieldContentContainerColor,
          contentBorderRadius: widget.fieldContentBorderRadius,
        );
      }
    }
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
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
                      child: widget.child1F1 != null 
                        ? buildCustomField(
                            widget.titleF1, 
                            widget.optionF1, 
                            widget.child1F1, 
                            widget.onTapF1,
                            icon: widget.iconF1,
                          )
                        : _FormFieldContainer(
                            title: widget.titleF1, mainText: widget.optionF1, icon: widget.iconF1, onTap: widget.onTapF1,
                            headerTextColor: widget.fieldHeaderTextColor, 
                            fieldValueTextColor: widget.fieldValueTextColor, // Pass it here
                            iconColor: widget.fieldIconColor,
                            contentContainerColor: widget.fieldContentContainerColor, 
                            contentBorderRadius: widget.fieldContentBorderRadius,
                          ),
                    ),
                    SizedBox(width: effectiveColumnSpacing),
                    Expanded(
                      child: widget.child1F2 != null 
                        ? buildCustomField(
                            widget.titleF2, 
                            widget.optionF2, 
                            widget.child1F2, 
                            widget.onTapF2,
                            icon: widget.iconF2,
                          )
                        : _FormFieldContainer(
                            title: widget.titleF2, mainText: widget.optionF2, icon: widget.iconF2, onTap: widget.onTapF2,
                            headerTextColor: widget.fieldHeaderTextColor, 
                            fieldValueTextColor: widget.fieldValueTextColor, // Pass it here
                            iconColor: widget.fieldIconColor,
                            contentContainerColor: widget.fieldContentContainerColor, 
                            contentBorderRadius: widget.fieldContentBorderRadius,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // FormNew doesn't have a close button as it should always be available
        ],
      ),
    );
  }
}