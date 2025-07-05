import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart'; // Pentru getCurrentConsultantToken

/// Service pentru integrarea cu Google Drive și Google Sheets pentru salvarea datelor clienților
class GoogleDriveService extends ChangeNotifier {
  static final GoogleDriveService _instance = GoogleDriveService._internal();
  factory GoogleDriveService() => _instance;
  GoogleDriveService._internal();

  // Instanță Firebase pentru a obține consultantToken
  final NewFirebaseService _firebaseService = NewFirebaseService();

  // Google Sign In configuration (pentru mobile)
  GoogleSignIn? _googleSignIn;
  GoogleSignInAccount? _currentUser;
  
  // Desktop webview auth
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiration;
  String? _userEmail;
  String? _userName;
  String? _currentConsultantToken; // Token-ul consultantului curent
  
  // API clients
  drive.DriveApi? _driveApi;
  sheets.SheetsApi? _sheetsApi;
  
  // Google OAuth2 credentials (Web client ID for desktop webview auth)
  static const String _clientId = '417121374106-54bs43o4e6o2k95n5dp3oa30aepciooi.apps.googleusercontent.com';
  static const String _clientSecret = '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';
  
  // Authentication state
  bool _isAuthenticated = false;
  bool _isConnecting = false;
  String? _lastError;
  
  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isConnecting => _isConnecting;
  String? get lastError => _lastError;
  GoogleSignInAccount? get currentUser => _currentUser;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get sheetName => 'clienti'; // Numele fix al spreadsheet-ului

  /// Verifică dacă platforma este suportată pentru Google Sign In
  bool _isPlatformSupported() {
    return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  }

  /// Verifică dacă este platformă desktop
  bool _isDesktopPlatform() {
    return !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  }

  /// Generează cheia pentru SharedPreferences pe baza consultantToken
  String _getTokenKey(String consultantToken, String suffix) {
    return 'google_${suffix}_$consultantToken';
  }

  /// Inițializează serviciul Google Drive și Sheets
  Future<void> initialize() async {
    debugPrint('🚀 GOOGLE_DRIVE_SERVICE: ========== INITIALIZE START ==========');
    
    try {
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Step 1 - Getting current consultant token...');
      
      // Obține consultantToken-ul curent
      _currentConsultantToken = await _firebaseService.getCurrentConsultantToken();
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Current consultant token: ${_currentConsultantToken?.substring(0, 8) ?? 'NULL'}');
      
      if (_currentConsultantToken == null) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: No consultant token available - cannot proceed with initialization');
        _lastError = 'Nu s-a găsit consultantul curent';
        return;
      }
      
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Step 2 - Checking platform compatibility...');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: _isPlatformSupported() = ${_isPlatformSupported()}');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: _isDesktopPlatform() = ${_isDesktopPlatform()}');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: kIsWeb = $kIsWeb');
      if (!kIsWeb) {
        debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Platform.isAndroid = ${Platform.isAndroid}');
        debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Platform.isIOS = ${Platform.isIOS}');
        debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Platform.isWindows = ${Platform.isWindows}');
        debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Platform.isMacOS = ${Platform.isMacOS}');
        debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Platform.isLinux = ${Platform.isLinux}');
      }
      
      if (_isPlatformSupported()) {
        debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Step 3a - Mobile platform detected, initializing Google Sign In...');
        
        // Mobile platforms - folosește Google Sign In
        _googleSignIn = GoogleSignIn(
          scopes: [
            'email',
            'https://www.googleapis.com/auth/drive.file',
            'https://www.googleapis.com/auth/spreadsheets',
          ],
        );
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: GoogleSignIn configured');
        
        // Verifică dacă există o sesiune salvată pentru consultantul curent
        debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Step 3b - Checking saved mobile authentication...');
        await _checkSavedAuthentication();
        
      } else if (_isDesktopPlatform()) {
        debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Step 3a - Desktop platform detected, checking saved tokens...');
        
        // Desktop platforms - verifică token salvat pentru consultantul curent
        debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Step 3b - Checking saved desktop tokens...');
        await _checkSavedDesktopToken();
        
      } else {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Unsupported platform detected');
        _lastError = 'Google Drive nu este suportat pe această platformă';
        return;
      }
      
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Step 4 - Final state check...');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: _isAuthenticated = $_isAuthenticated');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: _userEmail = $_userEmail');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: _userName = $_userName');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: _accessToken length = ${_accessToken?.length ?? 0}');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: _refreshToken available = ${_refreshToken != null}');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: _tokenExpiration = $_tokenExpiration');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: _driveApi configured = ${_driveApi != null}');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: _sheetsApi configured = ${_sheetsApi != null}');
      
      if (_isAuthenticated) {
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Initialized successfully for consultant: ${_currentConsultantToken?.substring(0, 8)} - AUTHENTICATED');
      } else {
        debugPrint('⚠️ GOOGLE_DRIVE_SERVICE: Initialized for consultant: ${_currentConsultantToken?.substring(0, 8)} - NOT AUTHENTICATED (this is normal for first time)');
      }
      
    } catch (e, stackTrace) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error initializing: $e');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Stack trace: $stackTrace');
      _lastError = 'Eroare la inițializare: ${e.toString()}';
    }
    
    debugPrint('🚀 GOOGLE_DRIVE_SERVICE: ========== INITIALIZE END ==========');
  }

  /// Verifică dacă există o autentificare salvată (mobile) pentru consultantul curent
  Future<void> _checkSavedAuthentication() async {
    try {
      final account = await _googleSignIn?.signInSilently();
      if (account != null && _currentConsultantToken != null) {
        // Verifică dacă token-ul salvat este pentru consultantul curent
        final prefs = await SharedPreferences.getInstance();
        final savedConsultantForThisEmail = prefs.getString('mobile_consultant_${account.email}');
        
        if (savedConsultantForThisEmail == _currentConsultantToken) {
          _currentUser = account;
          await _setupApiClients();
          _isAuthenticated = true;
          _userEmail = account.email;
          _userName = account.displayName;
          debugPrint('✅ GOOGLE_DRIVE_SERVICE: Restored saved authentication for ${account.email} (consultant: ${_currentConsultantToken?.substring(0, 8)})');
          notifyListeners();
        } else {
          // Token-ul este pentru alt consultant, deconectează
          await _googleSignIn?.signOut();
          debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Signed out previous consultant\'s account');
        }
      }
    } catch (e) {
      debugPrint('⚠️ GOOGLE_DRIVE_SERVICE: No saved authentication found: $e');
    }
  }

  /// Verifică dacă există un token desktop salvat pentru consultantul curent
  Future<void> _checkSavedDesktopToken() async {
    debugPrint('🔍🔍 GOOGLE_DRIVE_SERVICE: ========== _checkSavedDesktopToken START ==========');
    
    try {
      if (_currentConsultantToken == null) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: No consultant token available for token check');
        return;
      }
      
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Loading SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: SharedPreferences loaded successfully');
      
      // Generate keys for current consultant
      final accessTokenKey = _getTokenKey(_currentConsultantToken!, 'access_token');
      final refreshTokenKey = _getTokenKey(_currentConsultantToken!, 'refresh_token');
      final emailKey = _getTokenKey(_currentConsultantToken!, 'user_email');
      final nameKey = _getTokenKey(_currentConsultantToken!, 'user_name');
      final expirationKey = _getTokenKey(_currentConsultantToken!, 'token_expiration');
      
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Looking for tokens with keys:');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: - access_token: $accessTokenKey');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: - refresh_token: $refreshTokenKey');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: - user_email: $emailKey');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: - user_name: $nameKey');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: - token_expiration: $expirationKey');
      
      // Try to load all keys
      final accessToken = prefs.getString(accessTokenKey);
      final refreshToken = prefs.getString(refreshTokenKey);
      final email = prefs.getString(emailKey);
      final name = prefs.getString(nameKey);
      final expirationString = prefs.getString(expirationKey);
      
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Values found in SharedPreferences:');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: - accessToken: ${accessToken != null ? '${accessToken.substring(0, 20)}...' : 'NULL'}');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: - refreshToken: ${refreshToken != null ? '${refreshToken.substring(0, 20)}...' : 'NULL'}');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: - email: $email');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: - name: $name');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: - expirationString: $expirationString');
      
      // Check if we have minimum required data
      if (accessToken != null && email != null) {
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Found saved tokens! Setting up authentication...');
        
        _accessToken = accessToken;
        _refreshToken = refreshToken;
        _userEmail = email;
        _userName = name;
        
        debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Parsing expiration time...');
        // Parse expiration time
        if (expirationString != null) {
          // IMPORTANT: Parse as UTC to match Google's API requirements
          _tokenExpiration = DateTime.tryParse(expirationString)?.toUtc();
          debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Parsed expiration: $_tokenExpiration');
          debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Parsed expiration isUtc: ${_tokenExpiration?.isUtc}');
        } else {
          debugPrint('⚠️ GOOGLE_DRIVE_SERVICE: No expiration string found');
          _tokenExpiration = null;
        }
        
        // Check if token is expired
        final now = DateTime.now().toUtc();
        final isExpired = _tokenExpiration != null && now.isAfter(_tokenExpiration!);
        debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Current time (UTC): $now');
        debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Token expires: $_tokenExpiration');
        debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Is token expired: $isExpired');
        
        // Verifică dacă token-ul a expirat și încearcă să-l refresh
        if (isExpired) {
          debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Token expired, attempting refresh...');
          if (_refreshToken != null) {
            debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Refresh token available, calling _refreshAccessToken()...');
            final refreshSuccess = await _refreshAccessToken();
            debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Refresh result: $refreshSuccess');
            
            if (!refreshSuccess) {
              debugPrint('❌ GOOGLE_DRIVE_SERVICE: Failed to refresh token, removing saved credentials');
              await _clearSavedDesktopToken();
              return;
            } else {
              debugPrint('✅ GOOGLE_DRIVE_SERVICE: Token refreshed successfully');
            }
          } else {
            debugPrint('❌ GOOGLE_DRIVE_SERVICE: No refresh token available, removing saved credentials');
            await _clearSavedDesktopToken();
            return;
          }
        } else {
          debugPrint('✅ GOOGLE_DRIVE_SERVICE: Token is still valid, no refresh needed');
        }
        
        debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Setting up API clients with token...');
        await _setupApiClientsWithToken(_accessToken!);
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: API clients configured successfully');
        
        _isAuthenticated = true;
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Authentication state set to true');
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Restored saved desktop token for $email (consultant: ${_currentConsultantToken?.substring(0, 8)})');
        
        debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Notifying listeners...');
        notifyListeners();
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Listeners notified');
        
      } else {
        debugPrint('⚠️ GOOGLE_DRIVE_SERVICE: No saved tokens found for current consultant');
        debugPrint('⚠️ GOOGLE_DRIVE_SERVICE: Missing access token: ${accessToken == null}');
        debugPrint('⚠️ GOOGLE_DRIVE_SERVICE: Missing email: ${email == null}');
      }
      
    } catch (e, stackTrace) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error checking saved desktop token: $e');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Stack trace: $stackTrace');
      // În caz de eroare, șterge token-urile corupte
      debugPrint('🧹 GOOGLE_DRIVE_SERVICE: Clearing potentially corrupted tokens...');
      await _clearSavedDesktopToken();
    }
    
    debugPrint('🔍🔍 GOOGLE_DRIVE_SERVICE: ========== _checkSavedDesktopToken END ==========');
  }

  /// Refresh access token-ul folosind refresh token-ul
  Future<bool> _refreshAccessToken() async {
    debugPrint('🔄🔄 GOOGLE_DRIVE_SERVICE: ========== _refreshAccessToken START ==========');
    
    if (_refreshToken == null) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: No refresh token available');
      return false;
    }

    try {
      debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Refreshing access token...');
      debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Using refresh token: ${_refreshToken!.substring(0, 20)}...');
      
      debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Making POST request to Google token endpoint...');
      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'refresh_token': _refreshToken!,
          'grant_type': 'refresh_token',
        },
      );

      debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Response status: ${response.statusCode}');
      debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Token refresh request successful');
        
        final data = json.decode(response.body);
        debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Parsed response data keys: ${data.keys}');
        
        _accessToken = data['access_token'];
        debugPrint('🔄 GOOGLE_DRIVE_SERVICE: New access token length: ${_accessToken!.length}');
        
        // Calculează noul timp de expirare
        final expiresIn = data['expires_in'] ?? 3600; // Default 1 oră
        _tokenExpiration = DateTime.now().toUtc().add(Duration(seconds: expiresIn));
        debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Token expires in: ${expiresIn}s');
        debugPrint('🔄 GOOGLE_DRIVE_SERVICE: New expiration time: $_tokenExpiration (UTC: ${_tokenExpiration!.isUtc})');
        
        // Salvează noile token-uri
        debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Saving refreshed tokens...');
        await _saveDesktopTokens(_accessToken!, _refreshToken, _userEmail!, _userName);
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Tokens saved successfully');
        
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Access token refreshed successfully');
        return true;
      } else {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Failed to refresh token: ${response.statusCode}');
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Response: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error refreshing access token: $e');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Stack trace: $stackTrace');
      return false;
    }
    
  }

  /// Șterge token-urile desktop salvate
  Future<void> _clearSavedDesktopToken() async {
    debugPrint('🧹🧹 GOOGLE_DRIVE_SERVICE: ========== _clearSavedDesktopToken START ==========');
    debugPrint('🧹 GOOGLE_DRIVE_SERVICE: Consultant token: ${_currentConsultantToken?.substring(0, 8) ?? 'NULL'}');
    
    if (_currentConsultantToken == null) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: No consultant token - cannot clear tokens');
      return;
    }
    
    try {
      debugPrint('🧹 GOOGLE_DRIVE_SERVICE: Loading SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: SharedPreferences loaded');
      
      final accessTokenKey = _getTokenKey(_currentConsultantToken!, 'access_token');
      final refreshTokenKey = _getTokenKey(_currentConsultantToken!, 'refresh_token');
      final emailKey = _getTokenKey(_currentConsultantToken!, 'user_email');
      final nameKey = _getTokenKey(_currentConsultantToken!, 'user_name');
      final expirationKey = _getTokenKey(_currentConsultantToken!, 'token_expiration');
      
      debugPrint('🧹 GOOGLE_DRIVE_SERVICE: Removing keys:');
      debugPrint('🧹 GOOGLE_DRIVE_SERVICE: - access_token: $accessTokenKey');
      debugPrint('🧹 GOOGLE_DRIVE_SERVICE: - refresh_token: $refreshTokenKey');
      debugPrint('🧹 GOOGLE_DRIVE_SERVICE: - user_email: $emailKey');
      debugPrint('🧹 GOOGLE_DRIVE_SERVICE: - user_name: $nameKey');
      debugPrint('🧹 GOOGLE_DRIVE_SERVICE: - token_expiration: $expirationKey');
      
      await prefs.remove(accessTokenKey);
      await prefs.remove(refreshTokenKey);
      await prefs.remove(emailKey);
      await prefs.remove(nameKey);
      await prefs.remove(expirationKey);
      
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: All keys removed from SharedPreferences');
      
      _accessToken = null;
      _refreshToken = null;
      _tokenExpiration = null;
      _userEmail = null;
      _userName = null;
      
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Local variables cleared');
      debugPrint('🧹 GOOGLE_DRIVE_SERVICE: Cleared saved desktop tokens');
      
    } catch (e, stackTrace) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error clearing saved tokens: $e');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Stack trace: $stackTrace');
    }
    
    debugPrint('🧹🧹 GOOGLE_DRIVE_SERVICE: ========== _clearSavedDesktopToken END ==========');
  }

  /// Schimbă consultantul și încarcă token-urile corespunzătoare
  Future<void> switchConsultant(String newConsultantToken) async {
    debugPrint('🔄🔄 GOOGLE_DRIVE_SERVICE: ========== switchConsultant START ==========');
    debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Current consultant: ${_currentConsultantToken?.substring(0, 8) ?? 'NULL'}');
    debugPrint('🔄 GOOGLE_DRIVE_SERVICE: New consultant: ${newConsultantToken.substring(0, 8)}');
    
    if (_currentConsultantToken == newConsultantToken) {
      debugPrint('ℹ️ GOOGLE_DRIVE_SERVICE: Same consultant - no action needed');
      return; // Același consultant
    }
    
    debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Switching consultant from ${_currentConsultantToken?.substring(0, 8) ?? 'NULL'} to ${newConsultantToken.substring(0, 8)}');
    
    // Resetează starea curentă
    debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Resetting current authentication state...');
    await _resetAuthenticationState();
    debugPrint('✅ GOOGLE_DRIVE_SERVICE: Authentication state reset');
    
    // Schimbă la noul consultant
    _currentConsultantToken = newConsultantToken;
    debugPrint('✅ GOOGLE_DRIVE_SERVICE: Consultant token updated');
    
    // Încarcă autentificarea pentru noul consultant
    debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Loading authentication for new consultant...');
    if (_isPlatformSupported()) {
      debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Checking mobile authentication...');
      await _checkSavedAuthentication();
    } else if (_isDesktopPlatform()) {
      debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Checking desktop authentication...');
      await _checkSavedDesktopToken();
    }
    
    debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Final state after switch:');
    debugPrint('🔄 GOOGLE_DRIVE_SERVICE: - isAuthenticated: $_isAuthenticated');
    debugPrint('🔄 GOOGLE_DRIVE_SERVICE: - userEmail: $_userEmail');
    debugPrint('🔄 GOOGLE_DRIVE_SERVICE: - userName: $_userName');
    
    debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Notifying listeners...');
    notifyListeners();
    debugPrint('✅ GOOGLE_DRIVE_SERVICE: Listeners notified');
    
    debugPrint('🔄🔄 GOOGLE_DRIVE_SERVICE: ========== switchConsultant END ==========');
  }

  /// Resetează starea de autentificare fără a șterge token-urile salvate
  Future<void> _resetAuthenticationState() async {
    _isAuthenticated = false;
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiration = null;
    _userEmail = null;
    _userName = null;
    _currentUser = null;
    _driveApi = null;
    _sheetsApi = null;
    _lastError = null;
  }

  /// Verifică și refresh token-ul înainte de utilizare
  Future<bool> _ensureValidToken() async {
    if (!_isAuthenticated) {
      debugPrint('⚠️ GOOGLE_DRIVE_SERVICE: Not authenticated');
      return false;
    }

    // Pentru mobile, token-ul este gestionat automat de Google Sign In
    if (_isPlatformSupported()) {
      return true;
    }

    // Pentru desktop, verifică dacă token-ul a expirat
    if (_tokenExpiration != null && DateTime.now().toUtc().isAfter(_tokenExpiration!.subtract(Duration(minutes: 5)))) {
      debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Token expires soon, refreshing...');
      if (_refreshToken != null) {
        final refreshSuccess = await _refreshAccessToken();
        if (refreshSuccess) {
          // Actualizează API clients cu noul token
          await _setupApiClientsWithToken(_accessToken!);
          return true;
        } else {
          debugPrint('❌ GOOGLE_DRIVE_SERVICE: Failed to refresh token, user needs to reauthenticate');
          await _resetAuthenticationState();
          notifyListeners();
          return false;
        }
      } else {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: No refresh token, user needs to reauthenticate');
        await _resetAuthenticationState();
        notifyListeners();
        return false;
      }
    }

    return true;
  }

  /// Conectează-te la Google Drive
  Future<bool> connect() async {
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: connect() called');
    _isConnecting = true;
    _lastError = null;
    notifyListeners();
    
    try {
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Checking platform support...');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: _isPlatformSupported() = ${_isPlatformSupported()}');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: _isDesktopPlatform() = ${_isDesktopPlatform()}');
      
      if (_isPlatformSupported()) {
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Using Google Sign In (mobile)');
        await _handleGoogleSignIn();
      } else if (_isDesktopPlatform()) {
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Using desktop webview auth');
        await _handleDesktopWebviewAuth();
      } else {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Platform not supported');
        _lastError = 'Platforma nu este suportată';
        return false;
      }
      
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Connection completed, authenticated: $_isAuthenticated');
      return _isAuthenticated;
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Eroare la conectare: $e');
      _lastError = 'Eroare la conectare: ${e.toString()}';
      return false;
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  /// Gestionează autentificarea prin Google Sign In (mobile)
  Future<void> _handleGoogleSignIn() async {
    try {
      final account = await _googleSignIn!.signIn();
      if (account != null && _currentConsultantToken != null) {
        _currentUser = account;
        await _setupApiClients();
        _isAuthenticated = true;
        _userEmail = account.email;
        _userName = account.displayName;
        
        // Salvează asocierea consultantului cu email-ul Google
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('mobile_consultant_${account.email}', _currentConsultantToken!);
        
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Google Sign In successful for ${account.email} (consultant: ${_currentConsultantToken?.substring(0, 8)})');
      } else {
        _lastError = 'Autentificarea a fost anulată';
      }
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Google Sign In failed: $e');
      _lastError = 'Autentificarea Google a eșuat: ${e.toString()}';
    }
  }

  /// Gestionează autentificarea prin OAuth2 cu browser (desktop)
  Future<void> _handleDesktopWebviewAuth() async {
    try {
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Starting OAuth2 browser auth...');
      
      // OAuth2 endpoints pentru Google
      final authorizationEndpoint = Uri.parse('https://accounts.google.com/o/oauth2/v2/auth');
      final tokenEndpoint = Uri.parse('https://oauth2.googleapis.com/token');
      
      // Generează un redirect URI local
      final redirectUri = Uri.parse('http://localhost:8080');
      
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: OAuth2 config:');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: - clientId: $_clientId');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: - redirectUri: $redirectUri');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: - authEndpoint: $authorizationEndpoint');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: - tokenEndpoint: $tokenEndpoint');
      
      // Pornește serverul HTTP local pentru a prinde redirect-ul
      final server = await HttpServer.bind('localhost', 8080);
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Local HTTP server started on localhost:8080');
      
             // Creează grant-ul OAuth2
       final grant = oauth2.AuthorizationCodeGrant(
         _clientId,
         authorizationEndpoint,
         tokenEndpoint,
         secret: _clientSecret,
       );
      
      // Generează URL-ul de autorizare cu access_type=offline pentru refresh token
      final authorizationUrl = grant.getAuthorizationUrl(
        redirectUri,
        scopes: [
          'email',
          'profile', 
          'https://www.googleapis.com/auth/drive.file',
          'https://www.googleapis.com/auth/spreadsheets'
        ],
      );
      
      // Adaugă parametri pentru offline access (refresh token)
      final authUrlWithOfflineAccess = Uri.parse('$authorizationUrl&access_type=offline&prompt=consent');
      
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Authorization URL generated with offline access');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Opening browser for authentication...');
      
      // Deschide URL-ul în browser
      if (await canLaunchUrl(authUrlWithOfflineAccess)) {
        await launchUrl(authUrlWithOfflineAccess, mode: LaunchMode.externalApplication);
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Browser opened successfully');
      } else {
        throw Exception('Nu s-a putut deschide browser-ul');
      }
      
      // Așteaptă redirect-ul pe serverul local
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Waiting for redirect on local server...');
      final request = await server.first;
      
      // Extrage codul de autorizare din query parameters
      final queryParams = request.uri.queryParameters;
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Received redirect with params: ${queryParams.keys}');
      
      if (queryParams.containsKey('error')) {
        throw Exception('OAuth error: ${queryParams['error']}');
      }
      
      if (!queryParams.containsKey('code')) {
        throw Exception('Nu s-a primit codul de autorizare');
      }
      
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Authorization code received');
      
             // Răspunde la browser că s-a terminat cu succes
       final htmlResponse = '<html><body><h1>✅ Autentificare reușită!</h1><p>Poți închide această fereastră și să te întorci la aplicație.</p><script>window.close();</script></body></html>';
       request.response
         ..statusCode = 200
         ..headers.set('content-type', 'text/html; charset=utf-8')
         ..write(htmlResponse);
       await request.response.close();
       await server.close();
      
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Exchanging authorization code for access token...');
      
      // Schimbă codul de autorizare cu token-ul de acces
      final client = await grant.handleAuthorizationResponse(queryParams);
      _accessToken = client.credentials.accessToken;
      _refreshToken = client.credentials.refreshToken;
      
      // Calculează timpul de expirare
      _tokenExpiration = client.credentials.expiration ?? DateTime.now().toUtc().add(Duration(hours: 1));
      
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Access token received');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Access token length: ${_accessToken!.length}');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Refresh token available: ${_refreshToken != null}');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Token expires at: $_tokenExpiration (UTC: ${_tokenExpiration!.isUtc})');
      
      // Configurează API clients cu OAuth2 client
      await _setupApiClientsWithOAuth2Client(client);
      
      // Obține informațiile utilizatorului
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Getting user info from Google...');
      final userInfo = await _getUserInfoFromGoogle(_accessToken!);
      _userEmail = userInfo['email'];
      _userName = userInfo['name'];
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: User info - email: $_userEmail, name: $_userName');
      
      // Salvează token-urile pentru utilizare viitoare
      await _saveDesktopTokens(_accessToken!, _refreshToken, _userEmail!, _userName);
      
      _isAuthenticated = true;
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: OAuth2 authentication successful for $_userEmail');
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: OAuth2 auth failed: $e');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error type: ${e.runtimeType}');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Stack trace: ${StackTrace.current}');
      _lastError = 'Autentificarea OAuth2 a eșuat: ${e.toString()}';
    }
  }

  /// Configurează API clients cu token de acces
  Future<void> _setupApiClientsWithToken(String accessToken) async {
    debugPrint('🔧🔧 GOOGLE_DRIVE_SERVICE: ========== _setupApiClientsWithToken START ==========');
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Access token length: ${accessToken.length}');
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Token starts with: ${accessToken.substring(0, 20)}...');
    
    try {
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Getting token expiration...');
      final expiration = _tokenExpiration ?? DateTime.now().add(Duration(hours: 1));
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Original expiration: $expiration');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Expiration isUtc: ${expiration.isUtc}');
      
      // IMPORTANT: Convert to UTC if not already UTC
      final expirationUtc = expiration.isUtc ? expiration : expiration.toUtc();
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: UTC expiration: $expirationUtc');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: UTC expiration isUtc: ${expirationUtc.isUtc}');
      
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Creating AccessToken object...');
      final accessTokenObj = auth.AccessToken('Bearer', accessToken, expirationUtc);
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: AccessToken object created');
      
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Creating AccessCredentials...');
      final credentials = auth.AccessCredentials(
        accessTokenObj,
        null,
        [
          'https://www.googleapis.com/auth/drive.file',
          'https://www.googleapis.com/auth/spreadsheets'
        ],
      );
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: AccessCredentials created');
      
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Creating authenticated HTTP client...');
      final httpClient = http.Client();
      final client = auth.authenticatedClient(httpClient, credentials);
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Authenticated HTTP client created');
      
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Creating DriveApi instance...');
      _driveApi = drive.DriveApi(client);
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: DriveApi created');
      
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Creating SheetsApi instance...');
      _sheetsApi = sheets.SheetsApi(client);
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: SheetsApi created');
      
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: API clients configured with access token successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Failed to setup API clients with token: $e');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Stack trace: $stackTrace');
      rethrow;
    }
    
    debugPrint('🔧🔧 GOOGLE_DRIVE_SERVICE: ========== _setupApiClientsWithToken END ==========');
  }

  /// Configurează API clients cu Google Sign In
  Future<void> _setupApiClients() async {
    try {
      final authHeaders = await _currentUser!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      
      _driveApi = drive.DriveApi(authenticateClient);
      _sheetsApi = sheets.SheetsApi(authenticateClient);
      
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: API clients configured with Google Sign In');
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Failed to setup API clients: $e');
      rethrow;
    }
  }

  /// Configurează API clients cu OAuth2 client
  Future<void> _setupApiClientsWithOAuth2Client(oauth2.Client oauthClient) async {
    try {
      _driveApi = drive.DriveApi(oauthClient);
      _sheetsApi = sheets.SheetsApi(oauthClient);
      
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: API clients configured with OAuth2 client');
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Failed to setup API clients with OAuth2 client: $e');
      rethrow;
    }
  }

  /// Obține informațiile utilizatorului de la Google
  Future<Map<String, String?>> _getUserInfoFromGoogle(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/oauth2/v2/userinfo'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'email': data['email'],
          'name': data['name'],
        };
      } else {
        throw Exception('Failed to get user info: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Failed to get user info: $e');
      return {'email': null, 'name': null};
    }
  }

  /// Salvează token-urile desktop cu refresh token
  Future<void> _saveDesktopTokens(String accessToken, String? refreshToken, String email, String? name) async {
    debugPrint('💾💾 GOOGLE_DRIVE_SERVICE: ========== _saveDesktopTokens START ==========');
    debugPrint('💾 GOOGLE_DRIVE_SERVICE: Consultant token: ${_currentConsultantToken?.substring(0, 8) ?? 'NULL'}');
    debugPrint('💾 GOOGLE_DRIVE_SERVICE: Access token length: ${accessToken.length}');
    debugPrint('💾 GOOGLE_DRIVE_SERVICE: Refresh token available: ${refreshToken != null}');
    debugPrint('💾 GOOGLE_DRIVE_SERVICE: Email: $email');
    debugPrint('💾 GOOGLE_DRIVE_SERVICE: Name: $name');
    
    try {
      debugPrint('💾 GOOGLE_DRIVE_SERVICE: Loading SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: SharedPreferences loaded');
      
      final accessTokenKey = _getTokenKey(_currentConsultantToken!, 'access_token');
      final refreshTokenKey = _getTokenKey(_currentConsultantToken!, 'refresh_token');
      final emailKey = _getTokenKey(_currentConsultantToken!, 'user_email');
      final nameKey = _getTokenKey(_currentConsultantToken!, 'user_name');
      final expirationKey = _getTokenKey(_currentConsultantToken!, 'token_expiration');
      
      debugPrint('💾 GOOGLE_DRIVE_SERVICE: Saving with keys:');
      debugPrint('💾 GOOGLE_DRIVE_SERVICE: - access_token: $accessTokenKey');
      debugPrint('💾 GOOGLE_DRIVE_SERVICE: - user_email: $emailKey');
      
      // Save access token
      await prefs.setString(accessTokenKey, accessToken);
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Access token saved');
      
      // Save email
      await prefs.setString(emailKey, email);
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Email saved');
      
      if (refreshToken != null) {
        debugPrint('💾 GOOGLE_DRIVE_SERVICE: - refresh_token: $refreshTokenKey');
        await prefs.setString(refreshTokenKey, refreshToken);
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Refresh token saved');
      }
      
      if (name != null) {
        debugPrint('💾 GOOGLE_DRIVE_SERVICE: - user_name: $nameKey');
        await prefs.setString(nameKey, name);
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Name saved');
      }
      
      if (_tokenExpiration != null) {
        // IMPORTANT: Always save as UTC for consistency with Google's API requirements
        final expirationUtc = _tokenExpiration!.isUtc ? _tokenExpiration! : _tokenExpiration!.toUtc();
        final expirationString = expirationUtc.toIso8601String();
        debugPrint('💾 GOOGLE_DRIVE_SERVICE: - token_expiration: $expirationKey');
        debugPrint('💾 GOOGLE_DRIVE_SERVICE: - expiration value: $expirationString (UTC: ${expirationUtc.isUtc})');
        await prefs.setString(expirationKey, expirationString);
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Expiration saved');
      }
      
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Desktop tokens saved with refresh token');
      
      // Verify saved tokens
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Verifying saved tokens...');
      final savedAccessToken = prefs.getString(accessTokenKey);
      final savedRefreshToken = prefs.getString(refreshTokenKey);
      final savedEmail = prefs.getString(emailKey);
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Verification - Access token: ${savedAccessToken != null ? 'SAVED' : 'MISSING'}');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Verification - Refresh token: ${savedRefreshToken != null ? 'SAVED' : 'MISSING'}');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Verification - Email: ${savedEmail != null ? 'SAVED' : 'MISSING'}');
      
    } catch (e, stackTrace) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Failed to save desktop tokens: $e');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Stack trace: $stackTrace');
    }
    
    debugPrint('💾💾 GOOGLE_DRIVE_SERVICE: ========== _saveDesktopTokens END ==========');
  }

  /// Deconectează consultantul curent
  Future<void> disconnect() async {
    try {
      if (_currentConsultantToken == null) {
        debugPrint('⚠️ GOOGLE_DRIVE_SERVICE: No consultant token for disconnect');
        return;
      }

      if (_isPlatformSupported() && _googleSignIn != null) {
        // Pe mobile, șterge doar asocierea consultantului cu email-ul
        if (_userEmail != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('mobile_consultant_$_userEmail');
        }
        await _googleSignIn!.signOut();
        _currentUser = null;
      }
      
      if (_isDesktopPlatform()) {
        await _clearSavedDesktopToken();
      }
      
      _driveApi = null;
      _sheetsApi = null;
      _isAuthenticated = false;
      _userEmail = null;
      _userName = null;
      _lastError = null;
      
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Disconnected successfully for consultant: ${_currentConsultantToken?.substring(0, 8)}');
      notifyListeners();
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error disconnecting: $e');
      _lastError = 'Eroare la deconectare: ${e.toString()}';
    }
  }

  /// Salveaza un singur client in Google Sheets cu noua logica automata
  Future<String?> saveClientToXlsx(dynamic client) async {
    debugPrint('🚀 GOOGLE_DRIVE_SERVICE: ===========================================');
    debugPrint('🚀 GOOGLE_DRIVE_SERVICE: ÎNCEPE SALVAREA CLIENTULUI ÎN GOOGLE SHEETS');
    debugPrint('🚀 GOOGLE_DRIVE_SERVICE: ===========================================');
    
    try {
      // Verifică și refresh token-ul dacă este necesar
      final tokenValid = await _ensureValidToken();
      if (!tokenValid) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Token not valid, cannot save client');
        return 'Token expirat. Reconectați-vă la Google Drive din Setări';
      }
      
      // LOG: Verifică starea de autentificare detaliată
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Verificare autentificare...');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: _isAuthenticated = $_isAuthenticated');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: _driveApi != null = ${_driveApi != null}');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: _sheetsApi != null = ${_sheetsApi != null}');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: _currentConsultantToken = ${_currentConsultantToken?.substring(0, 8) ?? 'NULL'}');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: _userEmail = $_userEmail');
      
      if (!_isAuthenticated) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Nu este conectat la Google Drive');
        return 'Pentru a salva datele, conectați-vă la Google Drive din Setări';
      }

      if (_driveApi == null || _sheetsApi == null) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: API clients nu sunt inițializați');
        return 'Eroare: API clients nu sunt inițializați';
      }

      // LOG: Informații despre client
      debugPrint('👤 GOOGLE_DRIVE_SERVICE: Informații client:');
      debugPrint('👤 GOOGLE_DRIVE_SERVICE: - Nume: ${client?.name ?? 'NULL'}');
      debugPrint('👤 GOOGLE_DRIVE_SERVICE: - Telefon: ${client?.phoneNumber ?? 'NULL'}');
      debugPrint('👤 GOOGLE_DRIVE_SERVICE: - Type: ${client.runtimeType}');

      // 1. Gaseste sau creeaza spreadsheet-ul "clienti"
      debugPrint('📊 GOOGLE_DRIVE_SERVICE: PASUL 1 - Căutare/creare spreadsheet "clienti"');
      final spreadsheetId = await _findOrCreateSpreadsheet('clienti');
      if (spreadsheetId == null) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: PASUL 1 EȘUAT - Nu s-a putut găsi/crea spreadsheet-ul');
        return _lastError ?? 'Eroare la găsirea sau crearea fișierului Google Sheets.';
      }
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: PASUL 1 REUȘIT - Spreadsheet ID: $spreadsheetId');

      // 2. Gaseste sau creeaza sheet-ul pentru luna curenta
      debugPrint('📋 GOOGLE_DRIVE_SERVICE: PASUL 2 - Căutare/creare sheet pentru luna curentă');
      final sheetTitle = await _findOrCreateSheet(spreadsheetId);
      if (sheetTitle == null) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: PASUL 2 EȘUAT - Nu s-a putut găsi/crea sheet-ul');
        return _lastError ?? 'Eroare la găsirea sau crearea foii de calcul pentru luna curentă.';
      }
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: PASUL 2 REUȘIT - Sheet title: $sheetTitle');

      // 3. Pregateste randul de date pentru client
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: PASUL 3 - Pregătire date client');
      final clientRowData = await _prepareClientRowData(client);
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Date pregătite: ${clientRowData.length} coloane');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Conținut: $clientRowData');
      
      // 4. Salveaza randul in sheet
      debugPrint('💾 GOOGLE_DRIVE_SERVICE: PASUL 4 - Salvare rând în sheet');
      final success = await _appendRowToSheet(spreadsheetId, sheetTitle, clientRowData);

      if (success) {
        debugPrint('✅✅✅ GOOGLE_DRIVE_SERVICE: CLIENT SALVAT CU SUCCES ÎN GOOGLE SHEETS ✅✅✅');
        return null; // Succes
      } else {
        final error = _lastError ?? 'Eroare necunoscută la salvarea datelor.';
        debugPrint('❌❌❌ GOOGLE_DRIVE_SERVICE: PASUL 4 EȘUAT - Eroare la salvarea în Google Sheets: $error');
        return 'Eroare la salvarea în Google Sheets: $error';
      }
      
    } catch (e, stackTrace) {
      debugPrint('💥💥💥 GOOGLE_DRIVE_SERVICE: EROARE CRITICĂ LA SALVAREA CLIENTULUI 💥💥💥');
      debugPrint('💥 Error: $e');
      debugPrint('💥 Stack trace: $stackTrace');
      return 'Eroare la salvarea clientului: ${e.toString()}';
    }
  }

  /// Gaseste un spreadsheet dupa nume sau il creeaza daca nu exista
  Future<String?> _findOrCreateSpreadsheet(String name) async {
    debugPrint('🔍 GOOGLE_DRIVE_SERVICE: _findOrCreateSpreadsheet("$name") - ÎNCEPUT');
    
    try {
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Construire query pentru căutare fișier...');
      final query = "mimeType='application/vnd.google-apps.spreadsheet' and name='$name' and trashed=false";
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Query: $query');
      
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Apelare _driveApi.files.list...');
      final response = await _driveApi!.files.list(q: query, $fields: 'files(id, name)');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Răspuns primit de la API');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: response.files = ${response.files}');
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: response.files?.length = ${response.files?.length}');
      
      if (response.files != null && response.files!.isNotEmpty) {
        final fileId = response.files!.first.id!;
        final fileName = response.files!.first.name!;
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Fișierul "$name" găsit!');
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: - ID: $fileId');
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: - Nume: $fileName');
        return fileId;
      } else {
        debugPrint('⚠️ GOOGLE_DRIVE_SERVICE: Fișierul "$name" nu a fost găsit. Creez unul nou...');
        
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Construire obiect Spreadsheet nou...');
        final newSheet = sheets.Spreadsheet(
          properties: sheets.SpreadsheetProperties(title: name),
        );
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Obiect creat, apelare _sheetsApi.spreadsheets.create...');
        
        final createdSheet = await _sheetsApi!.spreadsheets.create(newSheet);
        final fileId = createdSheet.spreadsheetId!;
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Fișierul "$name" creat cu succes!');
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: - Nou ID: $fileId');
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: - URL: https://docs.google.com/spreadsheets/d/$fileId');
        return fileId;
      }
    } catch (e, stackTrace) {
      _lastError = 'Eroare la căutarea sau crearea fișierului: $e';
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: EROARE în _findOrCreateSpreadsheet: $_lastError');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Tip eroare: ${e.runtimeType}');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Stack trace: $stackTrace');
      return null;
    }
  }

  /// Gaseste un sheet (tab) dupa titlu sau il creeaza daca nu exista
  Future<String?> _findOrCreateSheet(String spreadsheetId) async {
    debugPrint('📋 GOOGLE_DRIVE_SERVICE: _findOrCreateSheet("$spreadsheetId") - ÎNCEPUT');
    
    try {
      // Genereaza titlul pentru luna si anul curent (ex: Dec 24)
      final now = DateTime.now();
      final sheetTitle = DateFormat('MMM yy', 'en_US').format(now);
      debugPrint('📋 GOOGLE_DRIVE_SERVICE: Titlu sheet generat: "$sheetTitle"');
      debugPrint('📋 GOOGLE_DRIVE_SERVICE: Data curentă: $now');

      debugPrint('📋 GOOGLE_DRIVE_SERVICE: Apelare _sheetsApi.spreadsheets.get pentru spreadsheet...');
      final spreadsheet = await _sheetsApi!.spreadsheets.get(spreadsheetId, includeGridData: false);
      debugPrint('📋 GOOGLE_DRIVE_SERVICE: Spreadsheet obținut cu succes');
      debugPrint('📋 GOOGLE_DRIVE_SERVICE: Număr sheet-uri existente: ${spreadsheet.sheets?.length ?? 0}');
      
      if (spreadsheet.sheets != null) {
        for (int i = 0; i < spreadsheet.sheets!.length; i++) {
          final sheet = spreadsheet.sheets![i];
          debugPrint('📋 GOOGLE_DRIVE_SERVICE: Sheet $i: "${sheet.properties?.title}"');
        }
      }

      final existingSheet = spreadsheet.sheets?.firstWhere(
        (s) => s.properties?.title == sheetTitle,
        orElse: () => sheets.Sheet(),
      );

      if (existingSheet?.properties?.title == sheetTitle) {
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Foaia "$sheetTitle" există deja!');
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Sheet ID: ${existingSheet?.properties?.sheetId}');
        return sheetTitle;
      } else {
        debugPrint('⚠️ GOOGLE_DRIVE_SERVICE: Foaia "$sheetTitle" nu există. Creez una nouă...');
        
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Construire AddSheetRequest...');
        final addSheetRequest = sheets.AddSheetRequest(
          properties: sheets.SheetProperties(title: sheetTitle),
        );
        
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Apelare batchUpdate pentru adăugare sheet...');
        await _sheetsApi!.spreadsheets.batchUpdate(
          sheets.BatchUpdateSpreadsheetRequest(requests: [sheets.Request(addSheet: addSheetRequest)]),
          spreadsheetId,
        );
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Sheet adăugat cu succes');

        // Adauga header-ul in noul sheet
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Adăugare header în noul sheet...');
        await _addHeaderToSheet(spreadsheetId, sheetTitle);
        
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Foaia "$sheetTitle" a fost creată și configurată cu succes!');
        return sheetTitle;
      }
    } catch (e, stackTrace) {
      _lastError = 'Eroare la căutarea sau crearea foii de calcul: $e';
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: EROARE în _findOrCreateSheet: $_lastError');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Tip eroare: ${e.runtimeType}');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Stack trace: $stackTrace');
      return null;
    }
  }

  /// Adaugă header-ul în sheet-ul specificat
  Future<void> _addHeaderToSheet(String spreadsheetId, String sheetTitle) async {
    debugPrint('📝 GOOGLE_DRIVE_SERVICE: _addHeaderToSheet - ÎNCEPUT');
    debugPrint('📝 GOOGLE_DRIVE_SERVICE: spreadsheetId: $spreadsheetId');
    debugPrint('📝 GOOGLE_DRIVE_SERVICE: sheetTitle: $sheetTitle');
    
    try {
      final headers = _getHeaders();
      debugPrint('📝 GOOGLE_DRIVE_SERVICE: Headers: $headers');
      debugPrint('📝 GOOGLE_DRIVE_SERVICE: Număr coloane header: ${headers.length}');
      
      final valueRange = sheets.ValueRange()..values = [headers];
      debugPrint('📝 GOOGLE_DRIVE_SERVICE: ValueRange creat');
      
      final range = "'$sheetTitle'!A1";
      debugPrint('📝 GOOGLE_DRIVE_SERVICE: Range pentru header: $range');
      
      debugPrint('📝 GOOGLE_DRIVE_SERVICE: Apelare _sheetsApi.spreadsheets.values.update...');
      await _sheetsApi!.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        range,
        valueInputOption: 'USER_ENTERED',
      );
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Header adăugat cu succes!');
    } catch (e, stackTrace) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: EROARE în _addHeaderToSheet: $e');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Stack trace: $stackTrace');
      rethrow; // Re-aruncă eroarea pentru ca funcția apelantă să o poată gestiona
    }
  }
  
  /// Adauga un rand de date la finalul unui sheet
  Future<bool> _appendRowToSheet(String spreadsheetId, String sheetTitle, List<dynamic> rowData) async {
    debugPrint('💾 GOOGLE_DRIVE_SERVICE: _appendRowToSheet - ÎNCEPUT');
    debugPrint('💾 GOOGLE_DRIVE_SERVICE: spreadsheetId: $spreadsheetId');
    debugPrint('💾 GOOGLE_DRIVE_SERVICE: sheetTitle: $sheetTitle');
    debugPrint('💾 GOOGLE_DRIVE_SERVICE: rowData: $rowData');
    debugPrint('💾 GOOGLE_DRIVE_SERVICE: rowData.length: ${rowData.length}');
    
    try {
      debugPrint('💾 GOOGLE_DRIVE_SERVICE: Creare ValueRange...');
      final valueRange = sheets.ValueRange()..values = [rowData];
      debugPrint('💾 GOOGLE_DRIVE_SERVICE: ValueRange creat cu succes');
      
      final range = "'$sheetTitle'!A1";
      debugPrint('💾 GOOGLE_DRIVE_SERVICE: Range pentru append: $range');
      debugPrint('💾 GOOGLE_DRIVE_SERVICE: valueInputOption: USER_ENTERED');
      
      debugPrint('💾 GOOGLE_DRIVE_SERVICE: APELARE CRITICĂ: _sheetsApi.spreadsheets.values.append...');
      debugPrint('💾 GOOGLE_DRIVE_SERVICE: Aceasta este operația finală care salvează datele!');
      
      final response = await _sheetsApi!.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        range,
        valueInputOption: 'USER_ENTERED',
      );
      
      debugPrint('✅✅✅ GOOGLE_DRIVE_SERVICE: APPEND REUȘIT! ✅✅✅');
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Response: $response');
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Updates: ${response.updates}');
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: UpdatedCells: ${response.updates?.updatedCells}');
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: UpdatedRange: ${response.updates?.updatedRange}');
      
      return true;
    } catch (e, stackTrace) {
      _lastError = 'Eroare la adăugarea rândului: $e';
      debugPrint('❌❌❌ GOOGLE_DRIVE_SERVICE: EROARE CRITICĂ în _appendRowToSheet! ❌❌❌');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: $_lastError');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Tip eroare: ${e.runtimeType}');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Detalii eroare: $e');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Stack trace: $stackTrace');
      return false;
    }
  }
  
  /// Returneaza lista de headere conform noii structuri
  List<String> _getHeaders() {
    return [
      'Client',
      'Contact',
      'Codebitor',
      'Ziua',
      'Status',
      'Credit Client',
      'Venit Client',
      'Credit Codebitor',
      'Venit Codebitor',
    ];
  }

  /// Pregătește datele clientului conform noii structuri
  Future<List<dynamic>> _prepareClientRowData(dynamic client) async {
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: _prepareClientRowData - ÎNCEPUT');
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Client type: ${client.runtimeType}');
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Client toString: $client');
    
    try {
      // Extrage datele de baza
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Extragere date de bază...');
      final String clientName = client.name ?? '';
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: clientName: "$clientName"');
      
      final phoneNumber1 = client.phoneNumber1 ?? client.phoneNumber ?? '';
      final phoneNumber2 = client.phoneNumber2 ?? '';
      
      // Formatează numerele de telefon pentru a păstra primul 0
      final formattedPhone1 = _formatPhoneNumber(phoneNumber1);
      final formattedPhone2 = _formatPhoneNumber(phoneNumber2);
      
      final String contact = ([formattedPhone1, formattedPhone2].where((p) => p.isNotEmpty).join('/'));
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: phoneNumber1: "$phoneNumber1" -> "$formattedPhone1"');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: phoneNumber2: "$phoneNumber2" -> "$formattedPhone2"');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: contact: "$contact"');
      
      final String coDebitorName = client.coDebitorName ?? '';
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: coDebitorName: "$coDebitorName"');
      
      final String ziua = DateTime.now().day.toString();
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: ziua: "$ziua"');
      
      final String status = client.additionalInfo ?? client.discussionStatus ?? '';
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: status: "$status"');

      // Extrage creditele si veniturile din formData
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Extragere formData...');
      final formData = client.formData as Map<String, dynamic>? ?? {};
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: formData keys: ${formData.keys.toList()}');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: formData size: ${formData.length}');
      
      if (formData.isNotEmpty) {
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: formData sample:');
        formData.forEach((key, value) {
          debugPrint('🔧 GOOGLE_DRIVE_SERVICE:   $key: $value');
        });
      }
      
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Extragere credite și venituri...');
      final clientCredits = _extractCredits(formData, 'client');
      final clientIncomes = _extractIncomes(formData, 'client');
      // Încearcă "coborrower" primul (numele corect din Firebase)
      final coDebitorCredits = _extractCredits(formData, 'coborrower');
      final coDebitorIncomes = _extractIncomes(formData, 'coborrower');
      
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: clientCredits: "$clientCredits"');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: clientIncomes: "$clientIncomes"');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: coDebitorCredits: "$coDebitorCredits"');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: coDebitorIncomes: "$coDebitorIncomes"');
      
      final rowData = [
        clientName,
        contact,
        coDebitorName,
        ziua,
        status,
        clientCredits,
        clientIncomes,
        coDebitorCredits,
        coDebitorIncomes,
      ];
      
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Date client pregătite cu succes!');
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Rând final: $rowData');
      
      return rowData;
    } catch (e, stackTrace) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: EROARE în _prepareClientRowData: $e');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Extrage informatiile de credite pentru un tip specificat conform formatului special
  String _extractCredits(Map<String, dynamic> formData, String type) {
    List<String> credits = [];
    
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: _extractCredits pentru $type');
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: formData keys: ${formData.keys.toList()}');
    
    // Caută în structura creditForms
    if (formData.containsKey('creditForms') && formData['creditForms'] is Map<String, dynamic>) {
      final creditForms = formData['creditForms'] as Map<String, dynamic>;
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Găsit creditForms cu keys: ${creditForms.keys.toList()}');
      
      if (creditForms.containsKey(type) && creditForms[type] is List) {
        final creditList = creditForms[type] as List;
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Găsit lista creditForms[$type] cu ${creditList.length} elemente');
        
        for (var creditData in creditList) {
          if (creditData is Map<String, dynamic>) {
            final formattedCredit = _formatCreditSpecial(creditData);
            if (formattedCredit.isNotEmpty && !_isSelectValue(formattedCredit)) {
              credits.add(formattedCredit);
            }
          }
        }
      }
    }
    
    // Fallback - caută și în structura veche pentru compatibilitate
    final creditKey = '${type}Credits';
    if (credits.isEmpty && formData.containsKey(creditKey) && formData[creditKey] is List) {
      final creditList = formData[creditKey] as List;
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Găsit lista fallback $creditKey cu ${creditList.length} elemente');
      
      for (var creditData in creditList) {
        if (creditData is Map<String, dynamic>) {
          final formattedCredit = _formatCreditSpecial(creditData);
          if (formattedCredit.isNotEmpty && !_isSelectValue(formattedCredit)) {
            credits.add(formattedCredit);
          }
        }
      }
    }
    
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Credite formatate pentru $type: $credits');
    return credits.join('; ');
  }

  /// Extrage informatiile de venituri pentru un tip specificat conform formatului special
  String _extractIncomes(Map<String, dynamic> formData, String type) {
    List<String> incomes = [];
    
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: _extractIncomes pentru $type');
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: formData keys: ${formData.keys.toList()}');
    
    // Caută în structura incomeForms
    if (formData.containsKey('incomeForms') && formData['incomeForms'] is Map<String, dynamic>) {
      final incomeForms = formData['incomeForms'] as Map<String, dynamic>;
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Găsit incomeForms cu keys: ${incomeForms.keys.toList()}');
      
      if (incomeForms.containsKey(type) && incomeForms[type] is List) {
        final incomeList = incomeForms[type] as List;
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Găsit lista incomeForms[$type] cu ${incomeList.length} elemente');
        
        for (var incomeData in incomeList) {
          if (incomeData is Map<String, dynamic>) {
            final formattedIncome = _formatIncomeSpecial(incomeData);
            if (formattedIncome.isNotEmpty && !_isSelectValue(formattedIncome)) {
              incomes.add(formattedIncome);
            }
          }
        }
      }
    }
    
    // Fallback - caută și în structura veche pentru compatibilitate
    final incomeKey = '${type}Incomes';
    if (incomes.isEmpty && formData.containsKey(incomeKey) && formData[incomeKey] is List) {
      final incomeList = formData[incomeKey] as List;
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Găsit lista fallback $incomeKey cu ${incomeList.length} elemente');
      
      for (var incomeData in incomeList) {
        if (incomeData is Map<String, dynamic>) {
          final formattedIncome = _formatIncomeSpecial(incomeData);
          if (formattedIncome.isNotEmpty && !_isSelectValue(formattedIncome)) {
            incomes.add(formattedIncome);
          }
        }
      }
    }
    
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Venituri formatate pentru $type: $incomes');
    return incomes.join('; ');
  }

  /// Formatează un venit în formatul special cerut (conform how_to_save_data.md)
  String _formatIncomeSpecial(Map<String, dynamic> incomeData) {
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: _formatIncomeSpecial cu date: $incomeData');
    
    final bank = incomeData['bank']?.toString() ?? '';
    final incomeType = incomeData['incomeType']?.toString() ?? '';
    final incomeAmount = incomeData['incomeAmount']?.toString() ?? '';
    final vechime = incomeData['vechime']?.toString() ?? '';
    
    // Verifică dacă banca și tipul de venit sunt valide (nu "Selectează")
    if (_isSelectValue(bank)) {
      return 'Venit incomplet - selectează banca';
    }
    
    if (_isSelectValue(incomeType)) {
      return 'Venit incomplet - selectează tipul';
    }
    
    // Determină tipul de venit și îl formatează conform specificațiilor
    String incomeTypeFormatted;
    switch (incomeType.toLowerCase()) {
      case 'salariu':
        incomeTypeFormatted = 'sal';
        break;
      case 'pensie':
        incomeTypeFormatted = 'pen';
        break;
      case 'indemnizatie':
        incomeTypeFormatted = 'ind';
        break;
      default:
        incomeTypeFormatted = incomeType.toLowerCase();
    }
    
    // Formatează banca
    final bankFormatted = _formatBankName(bank);
    
    // Formatează suma cu "k" pentru mii
    final amountFormatted = _formatAmountWithK(incomeAmount);
    
    // Construiește formatul final: "bancă-tip: sumă(vechime)"
    String result = '$bankFormatted-$incomeTypeFormatted: $amountFormatted';
    if (vechime.isNotEmpty && !_isSelectValue(vechime)) {
      result += '($vechime)';
    }
    
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Venit formatat final: $result');
    return result;
  }

  /// Formatează un credit în formatul special cerut (conform how_to_save_data.md)
  String _formatCreditSpecial(Map<String, dynamic> creditData) {
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: _formatCreditSpecial cu date: $creditData');
    
    final bank = creditData['bank']?.toString() ?? '';
    final creditType = creditData['creditType']?.toString() ?? '';
    final sold = creditData['sold']?.toString() ?? '';
    final consumat = creditData['consumat']?.toString() ?? '';
    final rata = creditData['rata']?.toString() ?? '';
    final rateType = creditData['rateType']?.toString() ?? '';
    final perioada = creditData['perioada']?.toString() ?? '';
    
    // Verifică dacă banca și tipul de credit sunt valide (nu "Selectează")
    if (_isSelectValue(bank)) {
      return 'Credit incomplet - selectează banca';
    }
    
    if (_isSelectValue(creditType)) {
      return 'Credit incomplet - selectează tipul';
    }
    
    // Formatează banca folosind aceeași logică ca la venituri
    final bankFormatted = _formatBankName(bank);
    
    // Formatează tipul de credit
    final creditTypeFormatted = _formatCreditType(creditType);
    
    // Formatează sumele (sold/consumat și rata)
    final amountsPart = _formatCreditAmounts(sold, consumat, rata);
    
    // Formatează detaliile (rateType și perioada)
    final detailsPart = _formatCreditDetails(rateType, perioada, creditType);
    
    // Construiește formatul final: "bancă-tip: sume(detalii)"
    String result = '$bankFormatted-$creditTypeFormatted: $amountsPart';
    
    // Adaugă detaliile doar dacă există și nu sunt goale
    if (detailsPart.isNotEmpty && !_isSelectValue(detailsPart)) {
      result += '($detailsPart)';
    }
    
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Credit formatat final: $result');
    return result;
  }

  /// Formatează numele băncii (conform how_to_save_data.md)
  String _formatBankName(String bank) {
    switch (bank.toLowerCase()) {
      case 'alpha bank':
        return 'Alpha';
      case 'banca transilvania':
      case 'bt':
        return 'BT';
      case 'bcr':
        return 'BCR';
      case 'brd':
        return 'BRD';
      case 'cec bank':
        return 'CEC';
      case 'garanti bank':
        return 'Garanti';
      case 'ing':
      case 'ing bank':
        return 'ING';
      case 'raiffeisen bank':
        return 'Raiffeisen';
      case 'tbi bank':
        return 'TBI';
      default:
        // Pentru băncile necunoscute, returnează primele 3-4 caractere
        return bank.length > 4 ? bank.substring(0, 4) : bank;
    }
  }

  /// Formatează tipul de credit
  String _formatCreditType(String creditType) {
    switch (creditType.toLowerCase()) {
      case 'card cumparaturi':
      case 'card de cumparaturi':
        return 'card';
      case 'nevoi personale':
        return 'nev';
      case 'overdraft':
        return 'over';
      case 'ipotecar':
        return 'ipo';
      case 'prima casa':
        return 'prima';
      default:
        return creditType.toLowerCase();
    }
  }

  /// Formatează sumele creditului (sold/consumat și rata)
  String _formatCreditAmounts(String sold, String consumat, String rata) {
    final soldFormatted = _formatAmountWithK(sold);
    final consumatFormatted = _formatAmountWithK(consumat);
    final rataFormatted = _formatAmountWithK(rata);
    
    // Construiește partea cu sumele
    String amounts = '';
    if (soldFormatted.isNotEmpty || consumatFormatted.isNotEmpty) {
      amounts = '$soldFormatted/$consumatFormatted';
    }
    
    if (rataFormatted.isNotEmpty) {
      if (amounts.isNotEmpty) {
        amounts += ' $rataFormatted';
      } else {
        amounts = rataFormatted;
      }
    }
    
    return amounts;
  }

  /// Formatează detaliile creditului (rateType și perioada)
  String _formatCreditDetails(String rateType, String perioada, String creditType) {
    final details = <String>[];
    
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Credit details - rateType: "$rateType", perioada: "$perioada"');
    
    // Adaugă tipul ratei dacă există și nu este "Selectează"
    if (rateType.isNotEmpty && !_isSelectValue(rateType)) {
      details.add(rateType);
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Adăugat rateType: $rateType');
    }
    
    // Adaugă perioada dacă există
    if (perioada.isNotEmpty && !_isSelectValue(perioada)) {
      final period = _formatPeriod(perioada);
      if (period.isNotEmpty) {
        details.add(period);
      }
    }
    
    // Pentru anumite tipuri de credit, nu afișa paranteze goale
    if (details.isEmpty) {
      final creditTypeLower = creditType.toLowerCase();
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Nu există detalii pentru $creditTypeLower');
      
      // Pentru carduri, overdraft și nevoi personale, nu e nevoie de detalii suplimentare
      if (creditTypeLower.contains('card') || 
          creditTypeLower.contains('overdraft') || 
          creditTypeLower.contains('nevoi personale')) {
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Tip de credit care nu necesită detalii');
        return '';
      }
    }
    
    final result = details.join(',');
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Detalii credit finale: "$result"');
    
    return result;
  }

  /// Formatează o sumă cu "k" pentru mii (5500 -> 5,5k)
  String _formatAmountWithK(String amount) {
    if (amount.isEmpty || amount == '0') return '';
    
    try {
      // Elimină virgulele existente
      final cleanAmount = amount.replaceAll(',', '');
      final numericValue = double.tryParse(cleanAmount);
      
      if (numericValue != null && numericValue > 0) {
        if (numericValue >= 1000) {
          final kValue = numericValue / 1000;
          // Formatează cu o zecimală dacă nu e număr întreg
          if (kValue == kValue.roundToDouble()) {
            return '${kValue.round()}k';
          } else {
            return '${kValue.toStringAsFixed(1)}k';
          }
        } else {
          return numericValue.round().toString();
        }
      }
    } catch (e) {
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Eroare la formatarea sumei: $e');
    }
    
    return amount;
  }

  /// Formatează perioada (ani/luni format)
  String _formatPeriod(String perioada) {
    if (perioada.isEmpty) return '';
    
    // Dacă perioada conține deja formatul ani/luni (ex: "2/3"), returnează așa cum e
    if (perioada.contains('/')) {
      return perioada;
    }
    
    // Încearcă să parseze ca numărul de luni
    final months = int.tryParse(perioada);
    if (months != null) {
      final years = months ~/ 12;
      final remainingMonths = months % 12;
      
      if (years > 0 && remainingMonths > 0) {
        return '$years/$remainingMonths';
      } else if (years > 0) {
        return '$years/0';
      } else {
        return '0/$remainingMonths';
      }
    }
    
    return perioada;
  }

  /// Verifică dacă o valoare este "Selectează" în diverse variante
  bool _isSelectValue(String value) {
    final lowerValue = value.toLowerCase().trim();
    return lowerValue == 'selectează' || 
           lowerValue == 'selecteaza' || 
           lowerValue == 'selecteaza banca' ||
           lowerValue == 'selecteaza tipul' ||
           lowerValue == 'select' ||
           lowerValue.isEmpty;
  }

  /// Formatează numărul de telefon pentru a păstra primul 0
  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return '';
    
    // Elimină spațiile și caracterele speciale
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Dacă numărul are 9 cifre și nu începe cu 0, adaugă 0
    if (cleaned.length == 9 && !cleaned.startsWith('0')) {
      cleaned = '0$cleaned';
    }
    
    // Dacă numărul are 10 cifre și începe cu 0, e deja corect
    if (cleaned.length == 10 && cleaned.startsWith('0')) {
      return cleaned;
    }
    
    // Dacă numărul are 12 cifre și începe cu 40, înlocuiește cu 0
    if (cleaned.length == 12 && cleaned.startsWith('40')) {
      cleaned = '0${cleaned.substring(2)}';
    }
    
    return cleaned;
  }
}

/// Client HTTP customizat pentru Google Sign In
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
} 