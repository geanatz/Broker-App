import 'package:flutter/material.dart';
import 'package:broker_app/theme/app_theme.dart'; // Asigură-te că această cale e corectă
import 'authService.dart';
import 'loginPopup.dart';
import 'registerPopup.dart';
import 'tokenPopup.dart';
import 'resetpasswordPopup.dart';

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

  void _navigateTo(AuthStep step) {
    setState(() {
      _currentStep = step;
      _errorMessage = null; // Resetează erorile la navigare
      _successMessage = null; // Resetează mesajele de succes la navigare
    });
  }

  Future<void> _handleLoginAttempt(String consultantName, String password) async {
    final result = await _authService.loginConsultant(
      consultantName: consultantName,
      password: password,
    );
    if (mounted) {
      if (result['success']) {
        // Navigarea către ecranul principal se face prin AuthWrapper din main.dart
        // Aici putem afișa un mesaj sau pur și simplu lăsăm AuthWrapper să preia controlul
        setState(() {
          _successMessage = result['message'];
          _errorMessage = null;
        });
        // Nu e nevoie să navigăm explicit aici, AuthWrapper va detecta schimbarea stării de autentificare
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
    final result = await _authService.registerConsultant(
      consultantName: consultantName,
      password: password,
      confirmPassword: confirmPassword,
      team: team,
    );
    if (mounted) {
      if (result['success']) {
        setState(() {
          _successMessage = "${result['message']}. Folosește token-ul: ${result['token']} pentru a-ți seta parola inițială sau la resetare.";
          _errorMessage = null;
          // După înregistrare cu succes, ar trebui să ghidăm utilizatorul să-și seteze parola folosind token-ul.
          // Poate direct la token entry sau înapoi la login cu un mesaj clar.
          // Deocamdată, afișăm mesajul și lăsăm utilizatorul să navigheze.
          _navigateTo(AuthStep.tokenEntry); // Trimite la token pentru a continua fluxul.
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
          _successMessage = null;
        });
      }
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
    Widget? popupToShow;
    switch (_currentStep) {
      case AuthStep.login:
        popupToShow = LoginPopup(
          onLoginAttempt: _handleLoginAttempt,
          onGoToRegister: () => _navigateTo(AuthStep.registration),
          onForgotPassword: () => _navigateTo(AuthStep.tokenEntry), // Duce la introducerea tokenului
        );
        break;
      case AuthStep.registration:
        popupToShow = RegisterPopup(
          onRegisterAttempt: _handleRegisterAttempt,
          onGoToLogin: () => _navigateTo(AuthStep.login),
        );
        break;
      case AuthStep.tokenEntry:
        popupToShow = TokenPopup(
          onTokenSubmit: _handleTokenSubmit,
          onGoToLogin: () => _navigateTo(AuthStep.login),
        );
        break;
      case AuthStep.passwordReset:
        popupToShow = ResetPasswordPopup(
          onResetPasswordAttempt: _handleResetPasswordAttempt,
          onGoToLogin: () => _navigateTo(AuthStep.login),
        );
        break;
      case AuthStep.initial: // Fallback sau stare inițială, ar trebui să ajungă la login
      default:
        _navigateTo(AuthStep.login);
        // Returnează un placeholder sau un loading cât timp se face redirectarea în setState
        return const Center(child: CircularProgressIndicator()); 
    }

    // Afișează popup-ul ca un dialog centrat
    // Sau direct în corpul ecranului dacă preferi o abordare non-dialog
    // Pentru a se potrivi descrierii "Absolută, centrată pe ecran", Dialog este potrivit.
    return popupToShow;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Folosim un Stack pentru a putea afișa popup-urile peste un fundal comun
      // Fundalul este gradientul definit în AppTheme
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.appBackgroundGradient,
        ),
        child: Center( // Centrează dialogul/popup-ul în Stack
          child: SingleChildScrollView( // Permite scroll dacă popup-ul e prea înalt (deși au înălțimi fixe)
             padding: const EdgeInsets.all(AppTheme.mediumGap), // O spațiere generală
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_successMessage != null && _currentStep != AuthStep.passwordReset && _currentStep != AuthStep.tokenEntry) // Nu afișa la succes de token/resetare aici, ci în popup-ul următor
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.mediumGap),
                    child: Text(
                      _successMessage!,
                      style: AppTheme.smallTextStyle.copyWith(color: AppTheme.fontMediumBlue), // O culoare pentru succes
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
