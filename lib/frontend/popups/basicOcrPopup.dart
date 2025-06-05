import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../common/appTheme.dart';
import '../common/components/headers/widgetHeader1.dart';
import '../common/components/buttons/flexButtons1.dart';
import '../../backend/ocr/ocrService.dart';

/// Popup OCR conform designului clientsPopup3.md cu funcționalitate completă
class BasicOcrPopup extends StatefulWidget {
  final List<File> selectedImages;
  final VoidCallback? onClose;
  final Function(Map<String, OcrImageResult>)? onCompleted;

  const BasicOcrPopup({
    super.key,
    required this.selectedImages,
    this.onClose,
    this.onCompleted,
  });

  @override
  State<BasicOcrPopup> createState() => _BasicOcrPopupState();
}

class _BasicOcrPopupState extends State<BasicOcrPopup> {
  final OcrService _ocrService = OcrService();
  bool _isProcessing = false;
  String _currentMessage = 'Se pregateste extragerea...';
  double _progress = 0.0;
  Map<String, OcrImageResult>? _results;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Începe automat procesarea OCR după ce se construiește widget-ul
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startOcrProcess();
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
                    // Header conform designului
                    WidgetHeader1(title: _results != null ? "Contacte extrase" : "Extragere contacte"),
                    
                    const SizedBox(height: 8),
                    
                    // Loading/Results container conform clientsPopup3/4
                    Expanded(
                      child: _results != null ? _buildResultsList() : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: ShapeDecoration(
                          color: AppTheme.containerColor1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: _buildLoadingContent(),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Image gallery conform designului
                    _results != null ? _buildResultsGallery() : _buildImageGallery(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Bottom button conform designului
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  /// Construiește conținutul de loading conform clientsPopup3
  Widget _buildLoadingContent() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 8,
                    color: Colors.red,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                    child: Text(
                      'Eroare: $_error',
                      style: TextStyle(
                        color: AppTheme.elementColor2,
                        fontSize: 15,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_isProcessing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Loading circle conform designului
          Container(
            width: 40,
            height: 40,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 8,
                        color: AppTheme.containerColor1,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: CircularProgressIndicator(
                    value: _progress > 0 ? _progress : null,
                    strokeWidth: 3,
                    color: AppTheme.elementColor1,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Progress text conform designului
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
                  child: Text(
                    _currentMessage,
                    style: TextStyle(
                      color: AppTheme.elementColor2,
                      fontSize: 15,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Ready state - exact ca în clientsPopup3
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 8,
                      color: AppTheme.containerColor1,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 21,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _currentMessage,
                      style: TextStyle(
                        color: AppTheme.elementColor2,
                        fontSize: 15,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construiește gallery-ul cu imaginile conform designului
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

  /// Construiește butonul de jos conform designului
  Widget _buildBottomButton() {
    String buttonText;
    VoidCallback? onPressed;
    Widget icon;

    if (_isProcessing) {
      buttonText = 'Anuleaza';
      onPressed = _cancelProcess;
      icon = SvgPicture.asset(
        'assets/returnIcon.svg',
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(AppTheme.elementColor2, BlendMode.srcIn),
      );
    } else if (_results != null) {
      buttonText = 'Foloseste contactele';
      onPressed = _useContacts;
      icon = Icon(
        Icons.check,
        color: AppTheme.elementColor2,
        size: 24,
      );
    } else {
      buttonText = 'Se pregateste...';
      onPressed = null;
      icon = Icon(
        Icons.hourglass_empty,
        color: AppTheme.elementColor2,
        size: 24,
      );
    }

    return Container(
      width: double.infinity,
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: ShapeDecoration(
                color: AppTheme.containerColor1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: GestureDetector(
                onTap: onPressed,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      buttonText,
                      style: TextStyle(
                        color: AppTheme.elementColor2,
                        fontSize: 17,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 24,
                      height: 24,
                      child: icon,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Începe procesul OCR
  Future<void> _startOcrProcess() async {
    setState(() {
      _isProcessing = true;
      _currentMessage = 'Se extrage textul din imaginea...';
      _progress = 0.0;
      _error = null;
      _results = null;
    });

    try {
      final results = await _ocrService.processImages(
        widget.selectedImages,
        (progressUpdate) {
          setState(() {
            _currentMessage = progressUpdate.progressMessage;
            _progress = progressUpdate.progress;
          });
        },
      );

      setState(() {
        _isProcessing = false;
        _results = results;
        _currentMessage = 'Extragere finalizata!';
      });

      // Nu notifică părintele automat - se va face doar la apăsarea butonului "Folosește contactele"

    } catch (e) {
      setState(() {
        _isProcessing = false;
        _error = e.toString();
        _currentMessage = 'Eroare la extragere';
      });
    }
  }

  /// Anulează procesul
  void _cancelProcess() {
    setState(() {
      _isProcessing = false;
      _currentMessage = 'Procesare anulata';
      _progress = 0.0;
    });
    
    // Închide popup-ul după anulare
    Navigator.of(context).pop();
    widget.onClose?.call();
  }

  /// Folosește contactele extrase
  void _useContacts() {
    if (_results != null && widget.onCompleted != null) {
      widget.onCompleted!(_results!);
    }
    Navigator.of(context).pop();
    widget.onClose?.call();
  }

  /// Construiește galeria cu imaginile pentru rezultate conform clientsPopup4
  Widget _buildResultsGallery() {
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
                      GestureDetector(
                        onTap: () {
                          debugPrint('Selectată imaginea ${i + 1}');
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: ShapeDecoration(
                            color: i == 1 ? AppTheme.elementColor1 : AppTheme.containerColor2, // A doua imagine selectată
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              widget.selectedImages[i],
                              fit: BoxFit.cover,
                              width: 56,
                              height: 56,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.image,
                                  color: AppTheme.elementColor2,
                                  size: 24,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
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

  /// Construiește lista cu rezultatele conform clientsPopup4
  Widget _buildResultsList() {
    if (_results == null) return const SizedBox.shrink();

    final sortedResults = _results!.entries.toList()
      ..sort((a, b) => b.value.contactCount.compareTo(a.value.contactCount));

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedResults.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, i) => Container(
          width: double.infinity,
          height: 64,
          padding: const EdgeInsets.only(top: 8, left: 16, right: 8, bottom: 8),
          decoration: ShapeDecoration(
            color: i % 2 == 0 ? AppTheme.containerColor1 : AppTheme.containerColor2,
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
                      Text(
                        'Imaginea ${i + 1}',
                        style: TextStyle(
                          color: i % 2 == 0 ? AppTheme.elementColor2 : AppTheme.elementColor3,
                          fontSize: 17,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${sortedResults[i].value.contactCount} contacte',
                        style: TextStyle(
                          color: i % 2 == 0 ? AppTheme.elementColor1 : AppTheme.elementColor2,
                          fontSize: 15,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w500,
                        ),
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
                  Icons.people,
                  color: AppTheme.elementColor2,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construiește thumbnail cu imaginea reală
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
        child: Image.file(
          imageFile,
          fit: BoxFit.cover,
          width: 56,
          height: 56,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.image,
              color: AppTheme.elementColor2,
              size: 24,
            );
          },
        ),
      ),
    );
  }
} 