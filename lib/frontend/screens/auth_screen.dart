import 'package:broker_app/app_theme.dart'; // Asigură-te că această cale e corectă
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
  AuthStep _currentStep = AuthStep.login; // Starea inițială este login
  final AuthService _authService = AuthService();
  String? _errorMessage;
  String? _successMessage;
  String? _tempConsultantIdForPasswordReset; // Stochează ID-ul consultantului după verificarea tokenului
  String? _registrationToken; // Stochează token-ul generat la înregistrare
  
  // Settings service pentru detectarea schimbărilor de temă
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    // Inițializează SettingsService
    _initializeSettings();
    
    // Ascultă schimbările din SettingsService pentru actualizări în timp real ale temei
    _settingsService.addListener(_onSettingsChanged);
    
    // Ascultă schimbările din AppTheme pentru actualizări automate ale UI-ului
    AppTheme().addListener(_onAppThemeChanged);
  }

  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    AppTheme().removeListener(_onAppThemeChanged);
    super.dispose();
  }

  /// Inițializează SettingsService
  Future<void> _initializeSettings() async {
    if (!_settingsService.isInitialized) {
      await _settingsService.initialize();
    }
  }

  /// Callback pentru schimbările din SettingsService
  void _onSettingsChanged() {
    if (mounted) {
      debugPrint('🎨 AUTH_SCREEN: Settings changed, updating UI');
      setState(() {
        // Actualizează întreaga interfață când se schimbă tema
      });
    }
  }

  /// Callback pentru schimbările din AppTheme
  void _onAppThemeChanged() {
    if (mounted) {
      debugPrint('🎨 AUTH_SCREEN: AppTheme changed, updating UI');
      setState(() {
        // Actualizează întreaga interfață când se schimbă AppTheme
      });
    }
  }

  void _navigateTo(AuthStep step) {
    debugPrint('🟦 AUTH_SCREEN: Navigating to step: $step');
    setState(() {
      _currentStep = step;
      _errorMessage = null; // Resetează erorile la navigare
      _successMessage = null; // Resetează mesajele de succes la navigare
    });
    debugPrint('🟦 AUTH_SCREEN: Navigation completed to: $_currentStep');
  }

  Future<void> _handleLoginAttempt(String consultantName, String password) async {
    final result = await _authService.loginConsultant(
      consultantName: consultantName,
      password: password,
    );
    if (mounted) {
      if (result['success']) {
        // Navigarea către ecranul principal se face automat prin AuthWrapper din main.dart
        // Nu afișăm mesaj de succes deoarece utilizatorul va fi redirecționat imediat
        // AuthWrapper va detecta schimbarea stării de autentificare și va naviga la MainScreen
      } else {
        setState(() {
          _errorMessage = result['message'];
          _successMessage = null;
          if (result['resetEnabled'] == true) {
            // Oferă opțiunea de a merge la token entry
            // Poate adăuga un buton sau un mesaj specific
            // Pentru moment, doar afișăm eroarea.
            // _navigateTo(AuthStep.tokenEntry); // Sau afișează un dialog
          }
        });
      }
    }
  }

  Future<void> _handleRegisterAttempt(String consultantName, String password, String confirmPassword, String team) async {
    debugPrint('🔵 AUTH_SCREEN: Starting registration attempt for: $consultantName');
    
    final result = await _authService.registerConsultant(
      consultantName: consultantName,
      password: password,
      confirmPassword: confirmPassword,
      team: team,
    );
    
    debugPrint('🔵 AUTH_SCREEN: Registration result: ${result['success']}');
    if (result['token'] != null) {
      debugPrint('🔵 AUTH_SCREEN: Token received: ${result['token'].substring(0, 8)}...');
    }
    
    if (mounted) {
      if (result['success']) {
        debugPrint('🟡 AUTH_SCREEN: Registration successful, navigating to AccountCreated');
        
        setState(() {
          _successMessage = result['message'];
          _errorMessage = null;
          _registrationToken = result['token']; // Salvăm token-ul pentru afișare în popup
          debugPrint('🔵 AUTH_SCREEN: Setting _registrationToken: ${_registrationToken?.substring(0, 8)}...');
          _navigateTo(AuthStep.accountCreated); // Navigăm la popup-ul de confirmare cont creat
        });
        
        debugPrint('🟢 AUTH_SCREEN: Navigation to AccountCreated completed');
      } else {
        debugPrint('🔴 AUTH_SCREEN: Registration failed: ${result['message']}');
        setState(() {
          _errorMessage = result['message'];
          _successMessage = null;
        });
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
          _successMessage = 'Token valid. Acum poți reseta parola.';
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
        _errorMessage = "ID consultant lipsă. Reia procesul de la introducerea token-ului.";
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
          // Chiar dacă AuthService nu resetează parola în Firebase, șterge token-ul.
          // Mesajul din AuthService e important.
          _successMessage = result['message'] + " Te rugăm să te autentifici cu noua parolă dacă procesul backend ar fi complet.";
          _errorMessage = null;
          _tempConsultantIdForPasswordReset = null; // Resetează ID-ul temporar
          _navigateTo(AuthStep.login); // Trimite la login după "resetare"
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
        popupToShow = AccountCreatedPopup(
          token: _registrationToken ?? 'Token indisponibil',
          onContinue: () => _navigateTo(AuthStep.login),
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
      case AuthStep.initial: // Fallback sau stare inițială, ar trebui să ajungă la login
        debugPrint('🟪 AUTH_SCREEN: Initial step, navigating to login');
        _navigateTo(AuthStep.login);
        // Returnează un placeholder sau un loading cât timp se face redirectarea în setState
        return const Center(child: CircularProgressIndicator()); 
    }

    return popupToShow;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Folosim un Stack pentru a putea afișa popup-urile peste un fundal comun
      // Fundalul este gradientul definit în AppTheme
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.appBackground,
        ),
        child: Center( // Centrează dialogul/popup-ul în Stack
          child: SingleChildScrollView( // Permite scroll dacă popup-ul e prea înalt (deși au înălțimi fixe)
             padding: const EdgeInsets.all(AppTheme.mediumGap), // O spațiere generală
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_successMessage != null && _currentStep != AuthStep.passwordReset && _currentStep != AuthStep.tokenEntry && _currentStep != AuthStep.accountCreated) // Nu afișa la succes de token/resetare aici, ci în popup-ul următor
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
