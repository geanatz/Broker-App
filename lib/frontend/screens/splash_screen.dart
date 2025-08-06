import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:broker_app/app_theme.dart';
import 'package:broker_app/backend/services/splash_service.dart';
import 'package:broker_app/backend/services/update_service.dart';
import 'package:broker_app/frontend/screens/main_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Splash screen care pre-incarca toate serviciile aplicatiei pentru o experienta fluida
/// OPTIMIZAT: Interfata imbunatatita cu loading indicators avansate
class SplashScreen extends StatefulWidget {
  final Map<String, dynamic> consultantData;
  
  const SplashScreen({
    super.key,
    required this.consultantData,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Animation controllers
  AnimationController? _fadeController;
  AnimationController? _progressController;
  AnimationController? _pulseController;
  Animation<double>? _fadeAnimation;
  Animation<double>? _progressAnimation;
  Animation<double>? _pulseAnimation;
  
  // Service instances
  final SplashService _splashService = SplashService();
  final UpdateService _updateService = UpdateService();

  // OPTIMIZARE: Loading states pentru componente specifice
  bool _calendarLoaded = false;
  bool _meetingsLoaded = false;
  bool _clientsLoaded = false;
  bool _dashboardLoaded = false;
  bool _googleDriveLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startPreloading();
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    _progressController?.dispose();
    _pulseController?.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController!, curve: Curves.easeInOut),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController!, curve: Curves.easeInOut),
    );
    
    // Start progress animation immediately
    _progressController!.forward();
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );
    
    _fadeController!.forward();
    _pulseController!.repeat(reverse: true);
  }

  Future<void> _startPreloading() async {
    try {
      // Listen to splash service changes
      _splashService.addListener(_onSplashServiceChanged);
      
      // Initialize update service
      await _updateService.initialize();
      
      // Verifica daca exista un update gata pentru instalare
      final hasReadyUpdate = await _updateService.checkForReadyUpdate();
      if (hasReadyUpdate) {
        debugPrint('📦 SPLASH_SCREEN: Found ready update, will show notification in main screen');
      }
      
      // Porneste verificarea periodica in background
      _updateService.startBackgroundUpdateCheck();
      
      // Start preloading
      final success = await _splashService.startPreloading();
      
      if (success) {
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Check for updates after preloading
        await _checkForUpdates();
        
        await _navigateToMainScreen();
      } else {
        // In case of error, still navigate to main screen
        await Future.delayed(const Duration(milliseconds: 500));
        await _navigateToMainScreen();
      }
      
    } catch (e) {
      debugPrint('❌ SPLASH_SCREEN: Error during preloading: $e');
      // In case of error, still navigate to main screen
      await Future.delayed(const Duration(milliseconds: 500));
      await _navigateToMainScreen();
    }
  }

  void _onSplashServiceChanged() {
    if (mounted) {
      setState(() {
        // Update loading states based on splash service progress
        _updateLoadingStates();
      });
      
      // OPTIMIZARE: Nu reseta progress-ul, lasa-l sa continue fluid
      // _progressController?.reset();
      // _progressController?.forward();
    }
  }

  /// OPTIMIZARE: Actualizeaza starile de loading pentru componente specifice
  void _updateLoadingStates() {
    final progress = _splashService.progress;
    
    // Calendar loaded after core services (15% + 25% = 40%)
    if (progress >= 0.4) {
      _calendarLoaded = true;
    }
    
    // Meetings loaded after data preload (40% + 20% = 60%)
    if (progress >= 0.6) {
      _meetingsLoaded = true;
    }
    
    // Clients loaded after data preload (40% + 20% = 60%)
    if (progress >= 0.6) {
      _clientsLoaded = true;
    }
    
    // Dashboard loaded after sync (60% + 15% = 75%)
    if (progress >= 0.75) {
      _dashboardLoaded = true;
    }
    
    // Google Drive loaded after sync (60% + 15% = 75%)
    if (progress >= 0.75) {
      _googleDriveLoaded = true;
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      debugPrint('🔍 Checking for updates...');
      
      final hasUpdate = await _updateService.checkForUpdates();
      
      if (hasUpdate && mounted) {
        debugPrint('✅ Update found | Current: ${_updateService.currentVersion} | Latest: ${_updateService.latestVersion}');
        
        // Show update dialog
        final shouldDownload = await _showUpdateDialog();
        
        if (shouldDownload) {
          debugPrint('📥 Starting download...');
          await _showUpdateDownloadDialog();
        }
      } else {
        debugPrint('✅ No updates available | Current: ${_updateService.currentVersion}');
      }
      
    } catch (e) {
      debugPrint('❌ SPLASH_SCREEN: Error checking for updates: $e');
    }
  }
  
  Future<bool> _showUpdateDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.widgetBackground,
        title: Text(
          'Update disponibil',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.elementColor2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _updateService.getUpdateMessage(),
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppTheme.elementColor1,
              ),
            ),
            const SizedBox(height: 16),
            if (_updateService.latestVersion != null && _updateService.currentVersion != null) ...[
              Text(
                'Versiune curenta: ${_updateService.currentVersion}',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.elementColor1.withAlpha(150),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Versiune noua: ${_updateService.latestVersion}',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.elementColor2,
                ),
              ),
            ],
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
                _getReleaseDescription(),
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.elementColor1,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
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
              Navigator.of(context).pop(true);
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }
  
  Future<void> _showUpdateDownloadDialog() async {
    double downloadProgress = 0.0;
    String statusText = 'Se descarca update-ul...';
    bool isDownloadComplete = false;
    
    // Setup callbacks
    _updateService.setDownloadProgressCallback((progress) {
      if (mounted) {
        setState(() {
          downloadProgress = progress;
        });
      }
    });
    
    _updateService.setStatusChangeCallback((status) {
      if (mounted) {
        setState(() {
          statusText = status;
        });
      }
    });
    
    _updateService.setUpdateReadyCallback((ready) {
      if (mounted && ready) {
        setState(() {
          isDownloadComplete = true;
          statusText = 'Update gata de instalare';
        });
      }
    });
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.widgetBackground,
          title: Text(
            'Se descarca update-ul',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.elementColor2,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isDownloadComplete) ...[
                LinearProgressIndicator(
                  value: downloadProgress,
                  backgroundColor: AppTheme.elementColor2.withAlpha(30),
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.elementColor2),
                ),
                const SizedBox(height: 20),
                Text(
                  '${(downloadProgress * 100).round()}%',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.elementColor2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _updateService.downloadProgressText,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.elementColor1,
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.download_done,
                  size: 48,
                  color: AppTheme.elementColor2,
                ),
                const SizedBox(height: 20),
                Text(
                  'Update descarcat cu succes!',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.elementColor2,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                statusText,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.elementColor1,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: isDownloadComplete ? [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
                _showInstallDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.elementColor2,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Instaleaza acum',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] : null,
        ),
      ),
    );
    
    try {
      final success = await _updateService.startDownload();
      
      if (!success && mounted) {
        Navigator.of(context).pop(); // Close download dialog
        _showUpdateFailedDialog();
      }
    } catch (e) {
      debugPrint('❌ Error during download: $e');
      if (mounted) {
        Navigator.of(context).pop(); // Close download dialog
        _showUpdateFailedDialog();
      }
    }
  }
  
  void _showInstallDialog() {
    // This dialog is no longer needed - the main update popup handles everything
    // Keeping empty method for compatibility
  }
  
  String _getReleaseDescription() {
    // Get release description from update service
    final updateInfo = _updateService.getUpdateInfo();
    final releaseDescription = updateInfo['releaseDescription'];
    
    if (releaseDescription != null && releaseDescription.isNotEmpty) {
      return releaseDescription;
    }
    
    // Fallback to default description
    return '• Imbunatatiri de performanta\n• Corectari de bug-uri\n• Functionalitati noi\n• Securitate imbunatatita';
  }

  void _startCompleteUpdate() async {
    // First, download the update if not already downloaded
    final updateInfo = _updateService.getUpdateInfo();
    bool hasUpdate = updateInfo['hasUpdate'] ?? false;
    
    if (!hasUpdate) {
      // Check for updates first
      hasUpdate = await _updateService.checkForUpdates();
    }
    
    if (hasUpdate) {
      // Start download if not already downloaded
      final isUpdateReady = updateInfo['isUpdateReady'] ?? false;
      if (!isUpdateReady) {
        await _updateService.startDownload();
      }
      
      // Now install the update
      await _updateService.installUpdate();
    }
  }
  
  void _showUpdateFailedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Update esuat',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.elementColor2,
          ),
        ),
        content: Text(
          'Nu s-a putut actualiza aplicatia. Va rugam incercati din nou mai tarziu.',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppTheme.elementColor1,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.elementColor2,
              foregroundColor: AppTheme.elementColor2,
            ),
            child: Text(
              'OK',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.elementColor2,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _navigateToMainScreen() async {
    // FIX: Reseteaza cache-ul pentru noul consultant inainte de navigare
    try {
      await _splashService.resetForNewConsultant();
    } catch (e) {
      debugPrint('❌ SPLASH_SCREEN: Error resetting cache: $e');
    }
    
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MainScreen(
          consultantName: widget.consultantData['name'],
          teamName: widget.consultantData['team'],
        ),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.widgetBackground,
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SVG Logo with pulse animation
                  AnimatedBuilder(
                    animation: _pulseAnimation ?? const AlwaysStoppedAnimation(1.0),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation?.value ?? 1.0,
                        child: SvgPicture.asset(
                          'assets/logoIcon.svg',
                          width: 120,
                          height: 120,
                          colorFilter: ColorFilter.mode(AppTheme.elementColor2, BlendMode.srcATop),
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Title Text
                  Text(
                    'Bun venit',
                    style: GoogleFonts.outfit(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.elementColor2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle Text
                  Text(
                    'Aplicatie de Consultanta Financiara',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.elementColor1,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // OPTIMIZARE: Loading indicators pentru componente specifice
                  _buildComponentLoadingIndicators(),
                  
                  const SizedBox(height: 32),

                  // Loading Text & Progress
                  SizedBox(
                    width: 300,
                    child: Column(
                      children: [
                        Text(
                          _splashService.currentTask,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.elementColor1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        AnimatedBuilder(
                          animation: _progressAnimation ?? const AlwaysStoppedAnimation(1.0),
                          builder: (context, child) {
                            return LinearProgressIndicator(
                              value: _splashService.progress * (_progressAnimation?.value ?? 1.0),
                              backgroundColor: AppTheme.elementColor1.withAlpha(30),
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.elementColor2),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_updateService.currentVersion != null)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                child: Text(
                  'Versiune ${_updateService.currentVersion}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: AppTheme.elementColor1.withAlpha(50),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// OPTIMIZARE: Construieste indicatorii de loading pentru componente specifice
  Widget _buildComponentLoadingIndicators() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.widgetBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.elementColor1.withAlpha(30),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Optimizare componente:',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.elementColor2,
            ),
          ),
          const SizedBox(height: 12),
          _buildLoadingIndicator('Calendar', _calendarLoaded, Icons.calendar_today),
          const SizedBox(height: 8),
          _buildLoadingIndicator('Intalniri', _meetingsLoaded, Icons.meeting_room),
          const SizedBox(height: 8),
          _buildLoadingIndicator('Clienti', _clientsLoaded, Icons.people),
          const SizedBox(height: 8),
          _buildLoadingIndicator('Dashboard', _dashboardLoaded, Icons.dashboard),
          const SizedBox(height: 8),
          _buildLoadingIndicator('Google Drive', _googleDriveLoaded, Icons.cloud),
        ],
      ),
    );
  }

  /// Construieste un indicator de loading pentru o componenta specifica
  Widget _buildLoadingIndicator(String label, bool isLoaded, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isLoaded ? AppTheme.elementColor2 : AppTheme.elementColor1.withAlpha(100),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: isLoaded ? AppTheme.elementColor2 : AppTheme.elementColor1,
            ),
          ),
        ),
        if (isLoaded)
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppTheme.elementColor2,
          )
        else
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.elementColor2),
            ),
          ),
      ],
    );
  }
} 