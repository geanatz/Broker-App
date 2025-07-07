import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import '../../backend/services/update_service.dart';

class UpdateNotification extends StatefulWidget {
  final UpdateService updateService;
  final VoidCallback? onInstallTap;
  final VoidCallback? onDismiss;

  const UpdateNotification({
    super.key,
    required this.updateService,
    this.onInstallTap,
    this.onDismiss,
  });

  @override
  State<UpdateNotification> createState() => _UpdateNotificationState();
}

class _UpdateNotificationState extends State<UpdateNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _checkUpdateStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _checkUpdateStatus() {
    final updateInfo = widget.updateService.getUpdateInfo();
    final shouldShow = updateInfo['isUpdateReady'] == true;
    
    if (shouldShow && !_isVisible) {
      _showNotification();
    } else if (!shouldShow && _isVisible) {
      _hideNotification();
    }
  }

  void _showNotification() {
    if (!_isVisible) {
      setState(() {
        _isVisible = true;
      });
      _animationController.forward();
    }
  }

  void _hideNotification() {
    if (_isVisible) {
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isVisible = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Periodic check for update status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdateStatus();
    });

    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 60),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.elementColor2,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.elementColor2.withAlpha(30),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.system_update,
                  color: AppTheme.isDarkMode ? Colors.black : Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Update gata pentru instalare',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.isDarkMode ? Colors.black : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Noua versiune a fost descarcata. Reporneste pentru a finaliza.',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: (AppTheme.isDarkMode ? Colors.black : Colors.white).withAlpha(70),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    _hideNotification();
                    widget.onDismiss?.call();
                  },
                  child: Text(
                    'Mai tarziu',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: (AppTheme.isDarkMode ? Colors.black : Colors.white).withAlpha(70),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _hideNotification();
                    widget.onInstallTap?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (AppTheme.isDarkMode ? Colors.black : Colors.white).withAlpha(20),
                    foregroundColor: AppTheme.isDarkMode ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusTiny),
                    ),
                  ),
                  child: Text(
                    'Reporneste',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Widget helper pentru integrarea facilă în main screen
class UpdateNotificationWrapper extends StatefulWidget {
  final Widget child;
  final UpdateService updateService;

  const UpdateNotificationWrapper({
    super.key,
    required this.child,
    required this.updateService,
  });

  @override
  State<UpdateNotificationWrapper> createState() => _UpdateNotificationWrapperState();
}

class _UpdateNotificationWrapperState extends State<UpdateNotificationWrapper> {
  
  void _handleInstallTap() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Instalare update',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.elementColor2,
          ),
        ),
        content: Text(
          'Aplicatia se va restarta pentru a aplica update-ul. Doriti sa continuati?',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppTheme.elementColor1,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Anuleaza',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.elementColor1,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startInstallation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.elementColor2,
              foregroundColor: AppTheme.elementColor2,
            ),
            child: Text(
              'Instaleaza',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.elementColor2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startInstallation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Se instaleaza update-ul',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.elementColor2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.elementColor2),
            ),
            const SizedBox(height: 20),
            Text(
              'Aplicatia se va restarta automat...',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppTheme.elementColor1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // Start installation
    widget.updateService.installUpdate();
  }

  void _handleDismiss() {
    // Optionally cancel the update
    widget.updateService.cancelUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: UpdateNotification(
            updateService: widget.updateService,
            onInstallTap: _handleInstallTap,
            onDismiss: _handleDismiss,
          ),
        ),
      ],
    );
  }
} 