import 'package:broker_app/app_theme.dart'; // Asigura-te ca aceasta cale e corecta
import 'package:flutter/material.dart';
import 'package:broker_app/backend/services/auth_service.dart';
import 'package:broker_app/frontend/modules/login_module.dart';
import 'package:broker_app/frontend/modules/register_module.dart';
import 'package:broker_app/frontend/modules/verify_module.dart';
import 'package:broker_app/frontend/modules/recovery__module.dart';
import 'package:broker_app/frontend/modules/token_module.dart';
import 'package:broker_app/backend/services/settings_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthStep _currentStep = AuthStep.login; // Starea initiala este login
  final AuthService _authService = AuthService();
  String? _errorMessage;
  String? _successMessage;
  String? _tempConsultantIdForPasswordReset; // Stocheaza ID-ul consultantului dupa verificarea tokenului
  String? _registrationToken; // Stocheaza token-ul generat la inregistrare
  
  // Settings service pentru detectarea schimbarilor de tema
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    // Initializeaza SettingsService
    _initializeSettings();
    
    // Asculta schimbarile din SettingsService pentru actualizari in timp real ale temei
    _settingsService.addListener(_onSettingsChanged);
    
    // Asculta schimbarile din AppTheme pentru actualizari automate ale UI-ului
    AppTheme().addListener(_onAppThemeChanged);
  }

  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    AppTheme().removeListener(_onAppThemeChanged);
    super.dispose();
  }

  /// Initializeaza SettingsService
  Future<void> _initializeSettings() async {
    if (!_settingsService.isInitialized) {
      await _settingsService.initialize();
    }
  }

  /// Callback pentru schimbarile din SettingsService
  void _onSettingsChanged() {
    if (mounted) {
      debugPrint('🎨 AUTH_SCREEN: Settings changed, updating UI');
      setState(() {
        // Actualizeaza intreaga interfata cand se schimba tema
      });
    }
  }

  /// Callback pentru schimbarile din AppTheme
  void _onAppThemeChanged() {
    if (mounted) {
      debugPrint('🎨 AUTH_SCREEN: AppTheme changed, updating UI');
      setState(() {
        // Actualizeaza intreaga interfata cand se schimba AppTheme
      });
    }
  }

  void _navigateTo(AuthStep step) {
    debugPrint('🟦 AUTH_SCREEN: Navigating from $_currentStep to $step');
    debugPrint('🟦 AUTH_SCREEN: Current _registrationToken: ${_registrationToken?.substring(0, 8)}...');
    setState(() {
      _currentStep = step;
      _errorMessage = null; // Reseteaza erorile la navigare
      _successMessage = null; // Reseteaza mesajele de succes la navigare
    });
    debugPrint('🟦 AUTH_SCREEN: Navigation completed to: $_currentStep');
    debugPrint('🟦 AUTH_SCREEN: _registrationToken after navigation: ${_registrationToken?.substring(0, 8)}...');
  }

  Future<void> _handleLoginAttempt(String consultantName, String password) async {
    debugPrint('🟢 AUTH_SCREEN: Starting login attempt for: $consultantName');
    
    final result = await _authService.loginConsultant(
      consultantName: consultantName,
      password: password,
    );
    
    debugPrint('🟢 AUTH_SCREEN: Login result: ${result['success']}');
    if (result['message'] != null) {
      debugPrint('🟢 AUTH_SCREEN: Login message: ${result['message']}');
    }
    
    if (mounted) {
      if (result['success']) {
        debugPrint('🟢 AUTH_SCREEN: Login successful - AuthWrapper should detect auth state change');
        // Navigarea catre ecranul principal se face automat prin AuthWrapper din main.dart
        // Nu afisam mesaj de succes deoarece utilizatorul va fi redirectionat imediat
        // AuthWrapper va detecta schimbarea starii de autentificare si va naviga la MainScreen
      } else {
        debugPrint('🔴 AUTH_SCREEN: Login failed: ${result['message']}');
        setState(() {
          _errorMessage = result['message'];
          _successMessage = null;
          if (result['resetEnabled'] == true) {
            // Ofera optiunea de a merge la token entry
            // Poate adauga un buton sau un mesaj specific
            // Pentru moment, doar afisam eroarea.
            // _navigateTo(AuthStep.tokenEntry); // Sau afiseaza un dialog
          }
        });
      }
    } else {
      debugPrint('🔴 AUTH_SCREEN: Widget not mounted after login attempt');
    }
  }

  Future<void> _handleRegisterAttempt(String consultantName, String password, String confirmPassword, String team) async {
    debugPrint('🔵 AUTH_SCREEN: Starting registration attempt for: $consultantName');
    debugPrint('🔵 AUTH_SCREEN: Current _currentStep before registration: $_currentStep');
    debugPrint('🔵 AUTH_SCREEN: Current _registrationToken before registration: $_registrationToken');
    
    final result = await _authService.registerConsultant(
      consultantName: consultantName,
      password: password,
      confirmPassword: confirmPassword,
      team: team,
    );
    
    debugPrint('🔵 AUTH_SCREEN: Registration completed with result:');
    debugPrint('🔵 AUTH_SCREEN: - success: ${result['success']}');
    debugPrint('🔵 AUTH_SCREEN: - message: ${result['message']}');
    debugPrint('🔵 AUTH_SCREEN: - token present: ${result['token'] != null}');
    if (result['token'] != null) {
      debugPrint('🔵 AUTH_SCREEN: - token value: ${result['token'].substring(0, 8)}...');
    }
    
    if (mounted) {
      if (result['success']) {
        debugPrint('🟡 AUTH_SCREEN: Registration successful, starting state update');
        debugPrint('🟡 AUTH_SCREEN: Token from result: ${result['token']}');
        
        setState(() {
          _successMessage = result['message'];
          _errorMessage = null;
          _registrationToken = result['token']; // Salvam token-ul pentru afisare in popup
          debugPrint('🔵 AUTH_SCREEN: _registrationToken set to: ${_registrationToken?.substring(0, 8)}...');
        });
        
        debugPrint('🟢 AUTH_SCREEN: State updated, now navigating to accountCreated');
        debugPrint('🟢 AUTH_SCREEN: _registrationToken before navigation: ${_registrationToken?.substring(0, 8)}...');
        
        // Separăm navigația de setState pentru debugging mai clar
        _navigateTo(AuthStep.accountCreated);
        
        debugPrint('🟢 AUTH_SCREEN: Navigation to AccountCreated completed');
        debugPrint('🟢 AUTH_SCREEN: Current _currentStep after navigation: $_currentStep');
        debugPrint('🟢 AUTH_SCREEN: Current _registrationToken after navigation: ${_registrationToken?.substring(0, 8)}...');
      } else {
        debugPrint('🔴 AUTH_SCREEN: Registration failed: ${result['message']}');
        setState(() {
          _errorMessage = result['message'];
          _successMessage = null;
        });
        debugPrint('🔴 AUTH_SCREEN: Error state set, staying on registration step');
      }
    } else {
      debugPrint('🔴 AUTH_SCREEN: Widget not mounted after registration');
    }
  }

  Future<void> _handleTokenSubmit(String token) async {
    final result = await _authService.verifyToken(token);
    if (mounted) {
      if (result['success']) {
        setState(() {
          _tempConsultantIdForPasswordReset = result['consultantId'];
          _successMessage = 'Token valid. Acum poti reseta parola.';
          _errorMessage = null;
          _navigateTo(AuthStep.passwordReset);
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
          _successMessage = null;
        });
      }
    }
  }

  Future<void> _handleResetPasswordAttempt(String newPassword, String confirmPassword) async {
    if (_tempConsultantIdForPasswordReset == null) {
      setState(() {
        _errorMessage = "ID consultant lipsa. Reia procesul de la introducerea token-ului.";
        _navigateTo(AuthStep.tokenEntry);
      });
      return;
    }

    final result = await _authService.resetPasswordWithToken(
      consultantId: _tempConsultantIdForPasswordReset!,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    if (mounted) {
      if (result['success']) {
        setState(() {
          // Chiar daca AuthService nu reseteaza parola in Firebase, sterge token-ul.
          // Mesajul din AuthService e important.
          _successMessage = result['message'] + " Te rugam sa te autentifici cu noua parola daca procesul backend ar fi complet.";
          _errorMessage = null;
          _tempConsultantIdForPasswordReset = null; // Reseteaza ID-ul temporar
          _navigateTo(AuthStep.login); // Trimite la login dupa "resetare"
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
          _successMessage = null;
        });
      }
    }
  }
  
  Widget _buildCurrentPopup() {
    debugPrint('🟪 AUTH_SCREEN: Building popup for step: $_currentStep');
    Widget? popupToShow;
    switch (_currentStep) {
      case AuthStep.login:
        debugPrint('🟪 AUTH_SCREEN: Building LoginPopup');
        popupToShow = LoginPopup(
          onLoginAttempt: _handleLoginAttempt,
          onGoToRegister: () => _navigateTo(AuthStep.registration),
          onForgotPassword: () => _navigateTo(AuthStep.tokenEntry), // Duce la introducerea tokenului
        );
        break;
      case AuthStep.registration:
        debugPrint('🟪 AUTH_SCREEN: Building RegisterPopup');
        popupToShow = RegisterPopup(
          onRegisterAttempt: _handleRegisterAttempt,
          onGoToLogin: () => _navigateTo(AuthStep.login),
        );
        break;
      case AuthStep.accountCreated:
        debugPrint('🟪 AUTH_SCREEN: Building AccountCreatedPopup with token: ${_registrationToken?.substring(0, 8)}...');
        debugPrint('🟪 AUTH_SCREEN: Full token available: ${_registrationToken != null}');
        debugPrint('🟪 AUTH_SCREEN: Token length: ${_registrationToken?.length}');
        if (_registrationToken == null) {
          debugPrint('🔴 AUTH_SCREEN: WARNING - Token is null when building AccountCreatedPopup!');
        }
        popupToShow = AccountCreatedPopup(
          token: _registrationToken ?? 'Token indisponibil',
          onContinue: () {
            debugPrint('🟪 AUTH_SCREEN: AccountCreatedPopup onContinue called');
            debugPrint('🟪 AUTH_SCREEN: Navigating from accountCreated to login');
            _navigateTo(AuthStep.login);
          },
        );
        break;
      case AuthStep.tokenEntry:
        debugPrint('🟪 AUTH_SCREEN: Building TokenPopup');
        popupToShow = TokenPopup(
          onTokenSubmit: _handleTokenSubmit,
          onGoToLogin: () => _navigateTo(AuthStep.login),
        );
        break;
      case AuthStep.passwordReset:
        debugPrint('🟪 AUTH_SCREEN: Building ResetPasswordPopup');
        popupToShow = ResetPasswordPopup(
          onResetPasswordAttempt: _handleResetPasswordAttempt,
          onGoToLogin: () => _navigateTo(AuthStep.login),
        );
        break;
      case AuthStep.initial: // Fallback sau stare initiala, ar trebui sa ajunga la login
        debugPrint('🟪 AUTH_SCREEN: Initial step, navigating to login');
        _navigateTo(AuthStep.login);
        // Returneaza un placeholder sau un loading cat timp se face redirectarea in setState
        return const Center(child: CircularProgressIndicator()); 
    }

    return popupToShow;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Folosim un Stack pentru a putea afisa popup-urile peste un fundal comun
      // Fundalul este gradientul definit in AppTheme
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.appBackground,
        ),
        child: Center( // Centreaza dialogul/popup-ul in Stack
          child: SingleChildScrollView( // Permite scroll daca popup-ul e prea inalt (desi au inaltimi fixe)
             padding: const EdgeInsets.all(AppTheme.mediumGap), // O spatiere generala
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_successMessage != null && _currentStep != AuthStep.passwordReset && _currentStep != AuthStep.tokenEntry && _currentStep != AuthStep.accountCreated) // Nu afisa la succes de token/resetare aici, ci in popup-ul urmator
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.mediumGap),
                    child: Text(
                      _successMessage!,
                      style: AppTheme.smallTextStyle.copyWith(color: AppTheme.elementColor2), // O culoare pentru succes
                      textAlign: TextAlign.center,
                    ),
                  ),
                // ADDED: Display error message if present
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.mediumGap),
                    child: Text(
                      _errorMessage!,
                      style: AppTheme.smallTextStyle.copyWith(color: AppTheme.elementColor2), // Error color
                      textAlign: TextAlign.center,
                    ),
                  ),
                // Aici vine popup-ul efectiv
                _buildCurrentPopup(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
