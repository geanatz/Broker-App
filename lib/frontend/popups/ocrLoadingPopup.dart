import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../common/components/headers/widgetHeader1.dart';
import '../common/components/buttons/flexButtons1.dart';
import '../common/components/texts/text2.dart';
import '../common/appTheme.dart';
import '../../backend/ocr/ocrService.dart';

/// Popup pentru loading OCR conform designului clientsPopup3
class OcrLoadingPopup extends StatefulWidget {
  final List<File> selectedImages;
  final VoidCallback? onCancel;
  final Function(Map<String, OcrImageResult>)? onCompleted;

  const OcrLoadingPopup({
    super.key,
    required this.selectedImages,
    this.onCancel,
    this.onCompleted,
  });

  @override
  State<OcrLoadingPopup> createState() => _OcrLoadingPopupState();
}

class _OcrLoadingPopupState extends State<OcrLoadingPopup> {
  final OcrService _ocrService = OcrService();
  bool _isProcessing = true;
  String _currentMessage = 'Initializare...';
  double _progress = 0.0;
  Map<String, OcrImageResult>? _results;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Întârzie inițializarea OCR pentru a permite UI-ului să se randeseze
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startOcrProcess();
    });
  }

  Future<void> _startOcrProcess() async {
    try {
      setState(() {
        _isProcessing = true;
        _currentMessage = 'Initializare procesare OCR...';
        _progress = 0.0;
      });

      // Adaugă delay pentru a permite UI-ului să se randeseze
      await Future.delayed(const Duration(milliseconds: 100));

      // Execută procesarea OCR pe un compute isolate pentru a nu bloca UI-ul
      final results = await _ocrService.processImages(
        widget.selectedImages,
        (progress) {
          // Folosește scheduleMicrotask pentru a programa update-urile UI
          if (mounted) {
            scheduleMicrotask(() {
              if (mounted) {
                setState(() {
                  _currentMessage = progress.progressMessage;
                  _progress = progress.progress;
                });
              }
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _results = results;
        });
        
        // Adaugă delay mic înainte de a notifica completion
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Notifică callback-ul cu rezultatele
        if (mounted) {
          widget.onCompleted?.call(results);
        }
      }
    } catch (e) {
      debugPrint('❌ Eroare în procesul OCR: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _error = 'Eroare la procesarea imaginilor: ${e.toString()}';
        });
      }
    }
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
                    const WidgetHeader1(title: "Extragere contacte"),
                    
                    const SizedBox(height: 8),
                    
                    // Loading/Results container
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 104),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: ShapeDecoration(
                            color: AppTheme.containerColor1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _buildLoadingContent(),
                              ),
                            ],
                          ),
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

  /// Construiește conținutul de loading
  Widget _buildLoadingContent() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: AppTheme.elementColor2,
            ),
            const SizedBox(height: 16),
                         Text2(
               text: 'Eroare: $_error',
               color: AppTheme.elementColor2,
               fontSize: 15,
               fontWeight: FontWeight.w500,
             ),
          ],
        ),
      );
    }

    if (_isProcessing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Loading indicator
          Container(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: _progress > 0 ? _progress : null,
              strokeWidth: 8,
              color: AppTheme.elementColor1,
              backgroundColor: AppTheme.containerColor1,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Progress message
          Container(
            width: double.infinity,
            height: 21,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                                     child: Text2(
                     text: _currentMessage,
                     color: AppTheme.elementColor2,
                     fontSize: 15,
                     fontWeight: FontWeight.w500,
                   ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Procesarea s-a terminat - afișează mesaj de succes
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 40,
            color: AppTheme.elementColor1,
          ),
          const SizedBox(height: 16),
          Text2(
            text: 'Extragere finalizată!',
            color: AppTheme.elementColor2,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
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
                    for (int i = 0; i < widget.selectedImages.length; i++) ...[
                      _buildImageThumbnail(widget.selectedImages[i]),
                      if (i < widget.selectedImages.length - 1)
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
  Widget _buildImageThumbnail(File imageFile) {
    return Container(
      width: 56,
      height: 56,
      decoration: ShapeDecoration(
        color: AppTheme.containerColor2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: FutureBuilder<bool>(
          future: imageFile.exists(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data == true) {
              return Image.file(
                imageFile,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                cacheWidth: 112, // Optimizare cache pentru thumbnail
                cacheHeight: 112,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_not_supported,
                    color: AppTheme.elementColor2,
                    size: 24,
                  );
                },
              );
            } else {
              return Icon(
                Icons.image,
                color: AppTheme.elementColor2,
                size: 24,
              );
            }
          },
        ),
      ),
    );
  }

  /// Construiește butonul de jos
  Widget _buildBottomButton() {
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
              text: _isProcessing ? "Anuleaza" : "Inchide",
              iconPath: _isProcessing ? "assets/closeIcon.svg" : "assets/checkIcon.svg",
              onTap: () {
                if (_isProcessing) {
                  // Anulează procesarea
                  widget.onCancel?.call();
                } else {
                  // Închide popup-ul
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