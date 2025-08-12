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

class _UpdateNotificationState extends State<UpdateNotification> {
  @override
  Widget build(BuildContext context) {
    // Completely disabled - no notification bar at all
    return const SizedBox.shrink();
  }
}

/// Widget helper pentru integrarea facila in main screen
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
    final updateInfo = widget.updateService.getUpdateInfo();
    final currentVersion = updateInfo['currentVersion'] ?? 'Necunoscuta';
    final latestVersion = updateInfo['latestVersion'] ?? 'Necunoscuta';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.system_update,
              color: AppTheme.elementColor2,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Update disponibil',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.elementColor2,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O versiune noua a aplicatiei este disponibila.',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppTheme.elementColor1,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.widgetBackground,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusTiny),
                border: Border.all(color: AppTheme.elementColor2.withAlpha(50)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Versiunea curenta: ',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.elementColor1,
                        ),
                      ),
                      Text(
                        currentVersion,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.elementColor1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Versiunea noua: ',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.elementColor1,
                        ),
                      ),
                      Text(
                        latestVersion,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.elementColor2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ce este nou in aceasta versiune:',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.elementColor1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.widgetBackground,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusTiny),
                border: Border.all(color: AppTheme.elementColor2.withAlpha(30)),
              ),
              child: Text(
                _getReleaseDescription(updateInfo),
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.elementColor1,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aplicatia se va reporni automat pentru a finaliza actualizarea.',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppTheme.elementColor1.withAlpha(150),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.updateService.cancelUpdate();
            },
            child: Text(
              'Mai tarziu',
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
              _startCompleteUpdate();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.elementColor2,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Actualizeaza',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getReleaseDescription(Map<String, dynamic> updateInfo) {
    // Get release description from update info
    final releaseDescription = updateInfo['releaseDescription'];
    
    if (releaseDescription != null && releaseDescription.isNotEmpty) {
      return releaseDescription;
    }
    
    // Fallback to default description
    return '• Imbunatatiri de performanta\n• Corectari de bug-uri\n• Functionalitati noi\n• Securitate imbunatatita';
  }

  void _startCompleteUpdate() async {
    // First, download the update if not already downloaded
    final updateInfo = widget.updateService.getUpdateInfo();
    bool hasUpdate = updateInfo['hasUpdate'] ?? false;
    
    if (!hasUpdate) {
      // Check for updates first
      hasUpdate = await widget.updateService.checkForUpdates();
    }
    
    if (hasUpdate) {
      // Start download if not already downloaded
      final isUpdateReady = updateInfo['isUpdateReady'] ?? false;
      if (!isUpdateReady) {
        await widget.updateService.startDownload();
      }
      
      // Now install the update
      await widget.updateService.installUpdate();
    }
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
