import 'dart:io';
import 'package:flutter/material.dart';
import '../common/components/headers/widgetHeader1.dart';
import '../common/components/items/lightItem3.dart';
import '../common/components/items/darkItem3.dart';
import '../common/components/buttons/flexButtons1.dart';
import '../common/components/texts/text2.dart';
import '../common/appTheme.dart';
import '../../backend/ocr/ocrService.dart';

/// Popup pentru rezultatele OCR conform designului clientsPopup4
class OcrResultsPopup extends StatefulWidget {
  final Map<String, OcrImageResult> ocrResults;
  final List<File> originalImages;
  final VoidCallback? onSaveContacts;
  final VoidCallback? onCancel;

  const OcrResultsPopup({
    super.key,
    required this.ocrResults,
    required this.originalImages,
    this.onSaveContacts,
    this.onCancel,
  });

  @override
  State<OcrResultsPopup> createState() => _OcrResultsPopupState();
}

class _OcrResultsPopupState extends State<OcrResultsPopup> {
  String? _selectedImagePath;
  OcrImageResult? _selectedResult;

  @override
  void initState() {
    super.initState();
    // Selectează primul rezultat cu succes
    for (final entry in widget.ocrResults.entries) {
      if (entry.value.success && entry.value.contacts.isNotEmpty) {
        _selectedImagePath = entry.key;
        _selectedResult = entry.value;
        break;
      }
    }
  }

  void _selectImage(String imagePath) {
    setState(() {
      _selectedImagePath = imagePath;
      _selectedResult = widget.ocrResults[imagePath];
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 296, minHeight: 432),
      child: Container(
        width: 296,
        height: 432,
        padding: const EdgeInsets.all(8),
        decoration: ShapeDecoration(
          color: AppTheme.popupBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded content area
            Expanded(
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const WidgetHeader1(title: "Contacte extrase"),
                    
                    const SizedBox(height: 8),
                    
                    // Results container
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image results list
                            ..._buildImageResultItems(),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Image gallery
                    _buildImageGallery(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Bottom button
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  /// Construiește itemele pentru fiecare imagine cu rezultate
  List<Widget> _buildImageResultItems() {
    final items = <Widget>[];
    int imageIndex = 1;
    
    for (final entry in widget.ocrResults.entries) {
      final imagePath = entry.key;
      final result = entry.value;
      final isSelected = imagePath == _selectedImagePath;
      
      if (result.success) {
        final contactCount = result.contactCount;
        final title = 'Imaginea $imageIndex';
        final description = '$contactCount ${contactCount == 1 ? 'contact' : 'contacte'}';
        
        if (isSelected) {
          items.add(
            Container(
              width: double.infinity,
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: ShapeDecoration(
                color: AppTheme.containerColor2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text2(
                            text: title,
                            color: AppTheme.elementColor3,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(height: 4),
                          Text2(
                            text: description,
                            color: AppTheme.elementColor2,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          items.add(
            Container(
              width: double.infinity,
              height: 64,
              padding: const EdgeInsets.only(top: 8, left: 16, right: 8, bottom: 8),
              decoration: ShapeDecoration(
                color: AppTheme.containerColor1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: InkWell(
                onTap: () => _selectImage(imagePath),
                borderRadius: BorderRadius.circular(24),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text2(
                              text: title,
                              color: AppTheme.elementColor2,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 4),
                            Text2(
                              text: description,
                              color: AppTheme.elementColor1,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: AppTheme.containerColor2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppTheme.elementColor2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      } else {
        // Imagine cu eroare
        items.add(
          Container(
            width: double.infinity,
            height: 64,
            padding: const EdgeInsets.only(top: 8, left: 16, right: 8, bottom: 8),
            decoration: ShapeDecoration(
              color: AppTheme.containerColor1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text2(
                          text: 'Imaginea $imageIndex',
                          color: AppTheme.elementColor2,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 4),
                        Text2(
                          text: 'Eroare procesare',
                          color: AppTheme.elementColor1,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(16),
                  decoration: ShapeDecoration(
                    color: AppTheme.containerColor2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 16,
                    color: AppTheme.elementColor2,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      
      imageIndex++;
      
      // Adaugă spațiu între iteme
      if (items.isNotEmpty && imageIndex <= widget.ocrResults.length) {
        items.add(const SizedBox(height: 8));
      }
    }
    
    return items;
  }

  /// Construiește galeria de imagini conform designului
  Widget _buildImageGallery() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppTheme.containerColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (int i = 0; i < widget.originalImages.length; i++) ...[
                      _buildImageThumbnail(widget.originalImages[i], i),
                      if (i < widget.originalImages.length - 1)
                        const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construiește thumbnail-ul unei imagini
  Widget _buildImageThumbnail(File imageFile, int index) {
    final imagePath = imageFile.path;
    final result = widget.ocrResults[imagePath];
    final isSelected = imagePath == _selectedImagePath;
    
    return Container(
      width: 56,
      height: 56,
      decoration: ShapeDecoration(
        color: isSelected 
            ? AppTheme.elementColor1
            : (result?.success == true 
                ? AppTheme.containerColor2 
                : AppTheme.containerColor2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          imageFile,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.image_not_supported,
              color: AppTheme.elementColor2,
              size: 24,
            );
          },
        ),
      ),
    );
  }

  /// Construiește butonul de jos
  Widget _buildBottomButton() {
    final totalContacts = widget.ocrResults.values
        .where((result) => result.success)
        .fold<int>(0, (sum, result) => sum + result.contactCount);
    
    return Container(
      width: double.infinity,
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: FlexButtonSingle(
              text: totalContacts > 0 
                  ? "Salveaza $totalContacts ${totalContacts == 1 ? 'contact' : 'contacte'}"
                  : "Inchide",
              iconPath: totalContacts > 0 ? "assets/saveIcon.svg" : "assets/closeIcon.svg",
              onTap: () {
                if (totalContacts > 0) {
                  widget.onSaveContacts?.call();
                } else {
                  Navigator.of(context).pop();
                }
              },
              borderRadius: 24,
              buttonHeight: 48.0,
              textStyle: TextStyle(
                color: AppTheme.elementColor2,
                fontSize: 17,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 