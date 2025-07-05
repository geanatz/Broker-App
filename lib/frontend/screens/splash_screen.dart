import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:broker_app/app_theme.dart';
import 'package:broker_app/backend/services/splash_service.dart';
import 'package:broker_app/backend/services/update_service.dart';
import 'package:broker_app/frontend/screens/main_screen.dart';

/// Splash screen care pre-încarcă toate serviciile aplicației pentru o experiență fluidă
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
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;
  
  // Service instances
  final SplashService _splashService = SplashService();
  final UpdateService _updateService = UpdateService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startPreloading();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    
    _fadeController.forward();
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
        // UI will update based on splash service state
      });
      
      // Update progress animation
      _progressController.reset();
      _progressController.forward();
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      debugPrint('🔍 Checking for updates...');
      
      final hasUpdate = await _updateService.checkForUpdates();
      
      if (hasUpdate && mounted) {
        debugPrint('✅ Update found, showing dialog...');
        
        // Show update dialog
        final shouldDownload = await _showUpdateDialog();
        
        if (shouldDownload) {
          debugPrint('📥 Starting download...');
          await _showUpdateDownloadDialog();
        }
      } else {
        debugPrint('✅ No updates available');
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
                  color: AppTheme.elementColor1.withAlpha(80),
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
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.elementColor2,
              foregroundColor: AppTheme.elementColor2,
            ),
            child: Text(
              'Descarca acum',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.elementColor2,
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
                foregroundColor: AppTheme.elementColor2,
              ),
              child: Text(
                'Instaleaza acum',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.elementColor2,
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
  
  Future<void> _showInstallDialog() async {
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
    
    try {
      await _updateService.installUpdate();
      // App will restart automatically, no need to handle success
    } catch (e) {
      debugPrint('❌ Error during installation: $e');
      if (mounted) {
        Navigator.of(context).pop(); // Close install dialog
        _showUpdateFailedDialog();
      }
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
    // FIX: Resetează cache-ul pentru noul consultant înainte de navigare
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
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.appBackground,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon area
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.elementColor2,
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(
                        color: AppTheme.elementColor2,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.account_balance,
                      size: 60,
                      color: AppTheme.elementColor2,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // App title
                  Text(
                    'Broker App',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.elementColor2,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Consultant name
                  Text(
                    'Bun venit, ${widget.consultantData['name'] ?? 'Consultant'}',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.elementColor1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Progress indicator
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.elementColor2,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _splashService.progress * _progressAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.elementColor2,
                                  AppTheme.elementColor2,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Progress text
                  Text(
                    _splashService.currentTask,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.elementColor1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Progress percentage
                  Text(
                    '${(_splashService.progress * 100).round()}%',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.elementColor1,
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Loading indicator
                  if (!_splashService.isInitialized)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.elementColor2,
                        ),
                      ),
                    ),
                  
                  if (_splashService.isInitialized)
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: AppTheme.elementColor2,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 