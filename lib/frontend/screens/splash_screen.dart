import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:mat_finance/app_theme.dart';
import 'package:mat_finance/backend/services/splash_service.dart';
import 'package:mat_finance/backend/services/update_service.dart';
import 'package:mat_finance/frontend/screens/main_screen.dart';
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
      
      // Initialize updater (no background checks; updates happen pre-launch only)
      await _updateService.initialize();

      // What's New se afiseaza in MainScreen pentru a evita dublura si pentru UI gata
      
      // Start preloading
      final success = await _splashService.startPreloading();
      
      if (success) {
        await Future.delayed(const Duration(milliseconds: 500));
        
        await _navigateToMainScreen();
      } else {
        // In case of error, still navigate to main screen
        await Future.delayed(const Duration(milliseconds: 500));
        await _navigateToMainScreen();
      }
      
    } catch (e) {
      debugPrint('SPLASH_SCREEN: Error during preloading: $e');
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

  // Removed updater dialogs; handled by pre-launch UpdaterScreen
  
  // Legacy update dialog removed (pre-launch updater handles updates)
  
  // Legacy download dialog removed (pre-launch updater handles updates)
  
  // Legacy install dialog removed
  
  // Removed release notes composition (handled pre-launch if needed)

  // Removed legacy _startCompleteUpdate to avoid double-trigger flow
  
  // Removed failed-update dialog (pre-launch updater decides UX)
  
  Future<void> _navigateToMainScreen() async {
    // FIX: Reseteaza cache-ul pentru noul consultant inainte de navigare
    try {
      await _splashService.resetForNewConsultant();
    } catch (e) {
      debugPrint('SPLASH_SCREEN: Error resetting cache: $e');
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
              backgroundColor: AppTheme.backgroundColor1,
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
                          'assets/logo.svg',
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
                    'MAT Finance',
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
        color: AppTheme.backgroundColor1,
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
