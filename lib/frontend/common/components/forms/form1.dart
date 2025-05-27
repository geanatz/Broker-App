// lib/components/forms/form_container1.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:broker_app/frontend/common/appTheme.dart'; // Import AppTheme instead of placeholder
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


/// A form container displaying a 2x2 grid of fields.
class FormContainer1 extends StatefulWidget {
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
  
  // Child widget parameters
  final Widget? child1TL; // Child widget for top-left dropdown field
  final Widget? child1TR; // Child widget for top-right dropdown field
  final Widget? child1; // Child widget for bottom-left field
  final Widget? child2; // Child widget for bottom-right field
  
  // Close button callback
  final VoidCallback? onClose;

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
    this.child1, // Child widget for bottom-left field
    this.child2, // Child widget for bottom-right field
    this.child1TL, // Child widget for top-left dropdown field
    this.child1TR, // Child widget for top-right dropdown field
    this.onClose, // Close button callback
  });

  @override
  State<FormContainer1> createState() => _FormContainer1State();
}

class _FormContainer1State extends State<FormContainer1> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color effectiveOuterContainerColor = widget.outerContainerColor ?? AppTheme.containerColor1;
    final double effectiveOuterBorderRadius = widget.outerBorderRadius ?? 24.0;
    final EdgeInsetsGeometry effectiveOuterPadding = widget.outerPadding ?? const EdgeInsets.all(8);
    final double effectiveRowSpacing = widget.rowSpacing ?? 8.0;
    final double effectiveColumnSpacing = widget.columnSpacing ?? 8.0;
    
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: widget.child1TL != null 
                        ? _buildCustomField(
                            widget.titleTL,
                            widget.optionTL,
                            widget.child1TL,
                            widget.onTapTL,
                            icon: widget.iconTL,
                          )
                        : _FormFieldContainer(
                            title: widget.titleTL,
                            mainText: widget.optionTL,
                            icon: widget.iconTL,
                            onTap: widget.onTapTL,
                            headerTextColor: widget.fieldHeaderTextColor,
                            fieldValueTextColor: widget.fieldValueTextColor,
                            iconColor: widget.fieldIconColor,
                            contentContainerColor: widget.fieldContentContainerColor,
                            contentBorderRadius: widget.fieldContentBorderRadius,
                          ),
                    ),
                    SizedBox(width: effectiveColumnSpacing),
                    Expanded(
                      child: widget.child1TR != null 
                        ? _buildCustomField(
                            widget.titleTR,
                            widget.optionTR,
                            widget.child1TR,
                            widget.onTapTR,
                            icon: widget.iconTR,
                          )
                        : _FormFieldContainer(
                            title: widget.titleTR,
                            mainText: widget.optionTR,
                            icon: widget.iconTR,
                            onTap: widget.onTapTR,
                            headerTextColor: widget.fieldHeaderTextColor,
                            fieldValueTextColor: widget.fieldValueTextColor,
                            iconColor: widget.fieldIconColor,
                            contentContainerColor: widget.fieldContentContainerColor,
                            contentBorderRadius: widget.fieldContentBorderRadius,
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
                      child: _buildCustomField(
                        widget.titleBL,
                        widget.textBL,
                        widget.child1,
                        widget.onTapBL,
                      ),
                    ),
                    SizedBox(width: effectiveColumnSpacing),
                    Expanded(
                      child: _buildCustomField(
                        widget.titleBR,
                        widget.textBR,
                        widget.child2,
                        widget.onTapBR,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Close button positioned in top-right corner
          if (_isHovered && widget.onClose != null)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                width: 24,
                height: 24,
                decoration: ShapeDecoration(
                  color: AppTheme.elementColor2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: InkWell(
                  onTap: widget.onClose,
                  borderRadius: BorderRadius.circular(12),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}