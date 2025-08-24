import 'package:mat_finance/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:mat_finance/backend/services/auth_service.dart';
import 'package:mat_finance/frontend/modules/login_module.dart';
import 'package:mat_finance/frontend/modules/register_module.dart';
import 'package:mat_finance/frontend/modules/verify_module.dart';
import 'package:mat_finance/frontend/modules/recovery__module.dart';
import 'package:mat_finance/frontend/modules/token_module.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthStep _currentStep = AuthStep.login;
  final AuthService _authService = AuthService();
  String? _registrationToken;

  @override
  void initState() {
    super.initState();
    _checkPendingToken();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Verifica daca exista un token pending din o sesiune anterioara
  Future<void> _checkPendingToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingToken = prefs.getString('pending_registration_token');
      if (pendingToken != null) {
        _registrationToken = pendingToken;
        _navigateToStep(AuthStep.accountCreated);
        await prefs.remove('pending_registration_token');
      }
    } catch (e) {
      debugPrint('[ERROR][AUTH] Error checking pending token: $e');
    }
  }

  /// Navigheaza la un pas specific
  void _navigateToStep(AuthStep step) {
    setState(() {
      _currentStep = step;
    });
  }

  /// Gestioneaza inregistrarea unui consultant
  Future<void> _handleRegistration(String consultantName, String password, String confirmPassword, String team, String? supervisorPassword) async {
    if (!mounted) return;
    
    try {
      final result = await _authService.registerConsultant(
        consultantName: consultantName,
        password: password,
        confirmPassword: confirmPassword,
        team: team,
        supervisorPassword: supervisorPassword,
      );
      
      if (!mounted) return;
      
      if (result['success'] == true) {
        final token = result['token'];
        if (token != null) {
          _registrationToken = token;
          _navigateToStep(AuthStep.accountCreated);
        }
      } else {
        setState(() {
        });
      }
    } catch (e) {
      debugPrint('[ERROR][AUTH] Registration failed: $e');
    }
  }

  /// Gestioneaza login-ul unui consultant
  Future<void> _handleLogin(String consultantName, String password) async {
    if (!mounted) return;
    
    try {
      final result = await _authService.loginConsultant(
        consultantName: consultantName,
        password: password,
      );
      
      if (!mounted) return;
      
      if (result['success'] == true) {
        // Login successful - AuthWrapper will detect auth state change
      } else {
        setState(() {
        });
      }
    } catch (e) {
      debugPrint('[ERROR][AUTH] Login failed: $e');
    }
  }

  /// Gestioneaza resetarea parolei
  Future<void> _handlePasswordReset(String currentPassword, String newPassword, String confirmPassword) async {
    try {
      // This method requires consultantId, newPassword, and confirmPassword
      // For now, we'll just show an error message since we don't have the required parameters
      setState(() {
      });
    } catch (e) {
      debugPrint('[ERROR][AUTH] Password reset failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundColor1Gradient,
        ),
        child: _buildCurrentStep(),
      ),
    );
  }

  /// Construieste widget-ul pentru pasul curent
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case AuthStep.login:
        return LoginPopup(
          onLoginAttempt: _handleLogin,
          onGoToRegister: () => _navigateToStep(AuthStep.registration),
          onForgotPassword: () => _navigateToStep(AuthStep.tokenEntry),
        );
      case AuthStep.registration:
        return RegisterPopup(
          onRegisterAttempt: _handleRegistration,
          onGoToLogin: () => _navigateToStep(AuthStep.login),
        );
      case AuthStep.accountCreated:
        return AccountCreatedPopup(
          token: _registrationToken ?? 'Token indisponibil',
          onContinue: () => _navigateToStep(AuthStep.login),
        );
      case AuthStep.tokenEntry:
        return TokenPopup(
          onTokenSubmit: (token) {
            // Handle token verification
          },
          onGoToLogin: () => _navigateToStep(AuthStep.login),
        );
      case AuthStep.passwordReset:
        return ResetPasswordPopup(
          onResetPasswordAttempt: _handlePasswordReset,
          onGoToLogin: () => _navigateToStep(AuthStep.login),
        );
      default:
        return LoginPopup(
          onLoginAttempt: _handleLogin,
          onGoToRegister: () => _navigateToStep(AuthStep.registration),
          onForgotPassword: () => _navigateToStep(AuthStep.tokenEntry),
        );
    }
  }
}

