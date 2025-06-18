import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:broker_app/app_theme.dart';
import 'package:broker_app/backend/services/splash_service.dart';
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
  
  // Splash service instance
  final SplashService _splashService = SplashService();

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
      
      // Start preloading
      final success = await _splashService.startPreloading();
      
      if (success) {
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateToMainScreen();
      } else {
        // In case of error, still navigate to main screen
        debugPrint('⚠️ SPLASH_SCREEN: Preloading had errors, but continuing to main screen');
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateToMainScreen();
      }
      
    } catch (e) {
      debugPrint('❌ SPLASH_SCREEN: Error during preloading: $e');
      // In case of error, still navigate to main screen
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToMainScreen();
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

  void _navigateToMainScreen() {
    debugPrint('🚀 SPLASH_SCREEN: Navigating to MainScreen');
    debugPrint('🚀 SPLASH_SCREEN: Consultant name: ${widget.consultantData['name']}');
    debugPrint('🚀 SPLASH_SCREEN: Team name: ${widget.consultantData['team']}');
    
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
                  if (!_splashService.isComplete)
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
                  
                  if (_splashService.isComplete)
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