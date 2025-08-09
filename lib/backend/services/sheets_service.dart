import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart'; // Pentru getCurrentConsultantToken

/// Service pentru integrarea cu Google Drive si Google Sheets pentru salvarea datelor clientilor
class GoogleDriveService extends ChangeNotifier {
  static final GoogleDriveService _instance = GoogleDriveService._internal();
  factory GoogleDriveService() => _instance;
  GoogleDriveService._internal();

  // Instanta Firebase pentru a obtine consultantToken
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
  
  // Background refresh timer
  Timer? _backgroundRefreshTimer;
  
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
  
  // Cache telefoane per (spreadsheetId|sheetTitle) pentru O(1) duplicate check
  final Map<String, Set<String>> _sheetPhonesCache = <String, Set<String>>{};
  final Map<String, DateTime> _sheetPhonesCacheTime = <String, DateTime>{};
  static const Duration _sheetPhonesTtl = Duration(days: 31);
  /// WATCHDOG: logs periodically while a long-running async step is pending
  Timer _startWatch(String stepLabel, {Duration interval = const Duration(seconds: 2)}) {
    int seconds = 0;
    return Timer.periodic(interval, (t) {
      seconds += interval.inSeconds;
      debugPrint('GD_WATCH: waiting on $stepLabel for ${seconds}s...');
    });
  }

  /// Verifica daca platforma este suportata pentru Google Sign In
  bool _isPlatformSupported() {
    return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  }

  /// Verifica daca este platforma desktop
  bool _isDesktopPlatform() {
    return !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  }

  /// Genereaza cheia pentru SharedPreferences pe baza consultantToken
  String _getTokenKey(String consultantToken, String suffix) {
    return 'google_${suffix}_$consultantToken';
  }

  /// Initializeaza serviciul Google Drive si Sheets
  Future<void> initialize() async {
    try {
      // Obtine consultantToken-ul curent
      _currentConsultantToken = await _firebaseService.getCurrentConsultantToken();
      
      if (_currentConsultantToken == null) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: No consultant token available - cannot proceed with initialization');
        _lastError = 'Nu s-a gasit consultantul curent';
        return;
      }
      
      if (_isPlatformSupported()) {
        // Mobile platforms - foloseste Google Sign In
        _googleSignIn = GoogleSignIn.instance;
        await _googleSignIn!.initialize();
        
        // Verifica daca exista o sesiune salvata pentru consultantul curent
        await _checkSavedAuthentication();
        
      } else if (_isDesktopPlatform()) {
        // Desktop platforms - verifica token salvat pentru consultantul curent
        await _checkSavedDesktopToken();
        
      } else {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Unsupported platform detected');
        _lastError = 'Google Drive nu este suportat pe aceasta platforma';
        return;
      }
      
      // Porneste timer-ul pentru refresh-ul in background (la fiecare 20 minute)
      _backgroundRefreshTimer?.cancel();
      _backgroundRefreshTimer = Timer.periodic(Duration(minutes: 20), (timer) {
        refreshTokenInBackground();
      });
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error initializing: $e');
      _lastError = 'Eroare la initializare: ${e.toString()}';
    }
  }

  /// Verifica daca exista o autentificare salvata (mobile) pentru consultantul curent
  Future<void> _checkSavedAuthentication() async {
    try {
      // Check for existing lightweight authentication
      final account = await _googleSignIn?.attemptLightweightAuthentication();
      if (account != null && _currentConsultantToken != null) {
        // Verifica daca token-ul salvat este pentru consultantul curent
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
          // Token-ul este pentru alt consultant, deconecteaza
          await _googleSignIn?.signOut();
          debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Signed out previous consultant\'s account');
        }
      }
    } catch (e) {
      debugPrint('⚠️ GOOGLE_DRIVE_SERVICE: No saved authentication found: $e');
    }
  }

  /// Verifica daca exista un token desktop salvat pentru consultantul curent
  Future<void> _checkSavedDesktopToken() async {
    try {
      if (_currentConsultantToken == null) {
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      
      // Generate keys for current consultant
      final accessTokenKey = _getTokenKey(_currentConsultantToken!, 'access_token');
      final refreshTokenKey = _getTokenKey(_currentConsultantToken!, 'refresh_token');
      final emailKey = _getTokenKey(_currentConsultantToken!, 'user_email');
      final nameKey = _getTokenKey(_currentConsultantToken!, 'user_name');
      final expirationKey = _getTokenKey(_currentConsultantToken!, 'token_expiration');
      
      // Try to load all keys
      final accessToken = prefs.getString(accessTokenKey);
      final refreshToken = prefs.getString(refreshTokenKey);
      final email = prefs.getString(emailKey);
      final name = prefs.getString(nameKey);
      final expirationString = prefs.getString(expirationKey);
      
              // Check if we have minimum required data
        if (accessToken != null && email != null) {
          _accessToken = accessToken;
          _refreshToken = refreshToken;
          _userEmail = email;
          _userName = name;
          
          // Parse expiration time
          if (expirationString != null) {
            // IMPORTANT: Parse as UTC to match Google's API requirements
            _tokenExpiration = DateTime.tryParse(expirationString)?.toUtc();
          } else {
            _tokenExpiration = null;
          }
          
          // Check if token is expired
          final now = DateTime.now().toUtc();
          final isExpired = _tokenExpiration != null && now.isAfter(_tokenExpiration!);
          
          // Verifica daca token-ul a expirat si incearca sa-l refresh
          if (isExpired) {
            if (_refreshToken != null) {
              final refreshSuccess = await _refreshAccessToken();
              
              if (!refreshSuccess) {
                debugPrint('❌ GOOGLE_DRIVE_SERVICE: Failed to refresh token, removing saved credentials');
                await _clearSavedDesktopToken();
                return;
              }
            } else {
              debugPrint('❌ GOOGLE_DRIVE_SERVICE: No refresh token available, removing saved credentials');
            await _clearSavedDesktopToken();
            return;
          }
        } else {
          debugPrint('✅ GOOGLE_DRIVE_SERVICE: Token is still valid, no refresh needed');
        }
        
        await _setupApiClientsWithToken(_accessToken!, _refreshToken, _userEmail!, _userName);
        
        _isAuthenticated = true;
        notifyListeners();
        
      } else {
        debugPrint('⚠️ GOOGLE_DRIVE_SERVICE: No saved tokens found for current consultant');
        debugPrint('⚠️ GOOGLE_DRIVE_SERVICE: Missing access token: ${accessToken == null}');
        debugPrint('⚠️ GOOGLE_DRIVE_SERVICE: Missing email: ${email == null}');
      }
      
    } catch (e, stackTrace) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error checking saved desktop token: $e');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Stack trace: $stackTrace');
      // In caz de eroare, sterge token-urile corupte
      debugPrint('🧹 GOOGLE_DRIVE_SERVICE: Clearing potentially corrupted tokens...');
      await _clearSavedDesktopToken();
    }
    
    // Token check completed
  }

  /// Refresh access token-ul folosind refresh token-ul
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: No refresh token available');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'refresh_token': _refreshToken!,
          'grant_type': 'refresh_token',
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        
        // Calculeaza noul timp de expirare
        final expiresIn = data['expires_in'] ?? 3600; // Default 1 ora
        _tokenExpiration = DateTime.now().toUtc().add(Duration(seconds: expiresIn));
        
        // Salveaza noile token-uri
        await _saveDesktopTokens(_accessToken!, _refreshToken, _userEmail!, _userName);
        
        return true;
      } else if (response.statusCode == 400) {
        // Refresh token invalid sau expirat
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Refresh token invalid or expired');
        
        // Sterge refresh token-ul invalid
        _refreshToken = null;
        await _clearSavedDesktopToken();
        
        return false;
      } else {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Failed to refresh token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error refreshing access token: $e');
      
      // Verifica daca este o eroare temporara (network, timeout)
      if (e.toString().contains('TimeoutException') || 
          e.toString().contains('SocketException') ||
          e.toString().contains('HttpException')) {
        return false; // Poate fi reincercat
      }
      
      return false;
    }
  }

  /// Sterge token-urile desktop salvate
  Future<void> _clearSavedDesktopToken() async {
    if (_currentConsultantToken == null) {
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final accessTokenKey = _getTokenKey(_currentConsultantToken!, 'access_token');
      final refreshTokenKey = _getTokenKey(_currentConsultantToken!, 'refresh_token');
      final emailKey = _getTokenKey(_currentConsultantToken!, 'user_email');
      final nameKey = _getTokenKey(_currentConsultantToken!, 'user_name');
      final expirationKey = _getTokenKey(_currentConsultantToken!, 'token_expiration');
      
      await prefs.remove(accessTokenKey);
      await prefs.remove(refreshTokenKey);
      await prefs.remove(emailKey);
      await prefs.remove(nameKey);
      await prefs.remove(expirationKey);
      
      _accessToken = null;
      _refreshToken = null;
      _tokenExpiration = null;
      _userEmail = null;
      _userName = null;
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error clearing saved tokens: $e');
    }
  }

  /// Verifica si refresh token-ul in background pentru a preveni expirarea
  Future<void> refreshTokenInBackground() async {
    if (!_isAuthenticated || _isDesktopPlatform() == false) {
      return; // Nu este necesara verificarea pentru mobile sau daca nu este autentificat
    }
    
    if (_tokenExpiration != null && DateTime.now().toUtc().isAfter(_tokenExpiration!.subtract(Duration(minutes: 30)))) {
      debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Background refresh - token expires in less than 30 minutes');
      final refreshSuccess = await _refreshAccessToken();
      if (refreshSuccess) {
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Background refresh successful');
        await _setupApiClientsWithToken(_accessToken!, _refreshToken, _userEmail!, _userName);
      } else {
        debugPrint('⚠️ GOOGLE_DRIVE_SERVICE: Background refresh failed');
      }
    }
  }

  /// Schimba consultantul si incarca token-urile corespunzatoare
  Future<void> switchConsultant(String newConsultantToken) async {
    if (_currentConsultantToken == newConsultantToken) {
      return; // Acelasi consultant
    }
    
    // Reseteaza starea curenta
    await _resetAuthenticationState();
    
    // Schimba la noul consultant
    _currentConsultantToken = newConsultantToken;
    
    // Incarca autentificarea pentru noul consultant
    if (_isPlatformSupported()) {
      await _checkSavedAuthentication();
    } else if (_isDesktopPlatform()) {
      await _checkSavedDesktopToken();
    }
    
    notifyListeners();
  }

  /// Reseteaza starea de autentificare fara a sterge token-urile salvate
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
    
    // Opreste timer-ul de background refresh
    _backgroundRefreshTimer?.cancel();
    _backgroundRefreshTimer = null;
  }

  /// Verifica si refresh token-ul inainte de utilizare
  Future<bool> _ensureValidToken() async {
    if (!_isAuthenticated) {
      debugPrint('⚠️ GOOGLE_DRIVE_SERVICE: Not authenticated');
      return false;
    }

    // Pentru mobile, token-ul este gestionat automat de Google Sign In
    if (_isPlatformSupported()) {
      return true;
    }

    // Pentru desktop, verifica daca token-ul a expirat
    if (_tokenExpiration != null && DateTime.now().toUtc().isAfter(_tokenExpiration!.subtract(Duration(minutes: 15)))) {
      debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Token expires soon, refreshing...');
      if (_refreshToken != null) {
        // Incerca refresh de 3 ori cu delay intre incercari
        bool refreshSuccess = false;
        for (int attempt = 1; attempt <= 3; attempt++) {
          debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Refresh attempt $attempt/3');
          refreshSuccess = await _refreshAccessToken();
          if (refreshSuccess) {
            break;
          }
          if (attempt < 3) {
            debugPrint('🔄 GOOGLE_DRIVE_SERVICE: Waiting 2 seconds before next attempt...');
            await Future.delayed(Duration(seconds: 2));
          }
        }
        
        if (refreshSuccess) {
          // Actualizeaza API clients cu noul token
          await _setupApiClientsWithToken(_accessToken!, _refreshToken, _userEmail!, _userName);
          return true;
        } else {
          debugPrint('❌ GOOGLE_DRIVE_SERVICE: Failed to refresh token after 3 attempts');
          // NU resetam starea complet - doar marcam ca nu este autentificat
          // Utilizatorul va fi rugat sa se reconecteze doar cand incearca sa salveze
          _isAuthenticated = false;
          _lastError = 'Token-ul a expirat. Reconectati-va la Google Drive din Setari.';
          notifyListeners();
          return false;
        }
      } else {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: No refresh token, user needs to reauthenticate');
        // NU resetam starea complet - doar marcam ca nu este autentificat
        _isAuthenticated = false;
        _lastError = 'Sesiunea a expirat. Reconectati-va la Google Drive din Setari.';
        notifyListeners();
        return false;
      }
    }

    return true;
  }

  /// Conecteaza-te la Google Drive
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
        _lastError = 'Platforma nu este suportata';
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

  /// Gestioneaza autentificarea prin Google Sign In (mobile)
  Future<void> _handleGoogleSignIn() async {
    try {
      final account = await _googleSignIn!.authenticate();
      if (_currentConsultantToken != null) {
        _currentUser = account;
        await _setupApiClients();
        _isAuthenticated = true;
        _userEmail = account.email;
        _userName = account.displayName;
        
        // Salveaza asocierea consultantului cu email-ul Google
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('mobile_consultant_${account.email}', _currentConsultantToken!);
        
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Google Sign In successful for ${account.email} (consultant: ${_currentConsultantToken?.substring(0, 8)})');
      } else {
        _lastError = 'Autentificarea a fost anulata';
      }
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Google Sign In failed: $e');
      _lastError = 'Autentificarea Google a esuat: ${e.toString()}';
    }
  }

  /// Gestioneaza autentificarea prin OAuth2 cu browser (desktop)
  Future<void> _handleDesktopWebviewAuth() async {
    try {
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Starting OAuth2 browser auth...');
      
      // OAuth2 endpoints pentru Google
      final authorizationEndpoint = Uri.parse('https://accounts.google.com/o/oauth2/v2/auth');
      final tokenEndpoint = Uri.parse('https://oauth2.googleapis.com/token');
      
      // Genereaza un redirect URI local
      final redirectUri = Uri.parse('http://localhost:8080');
      
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: OAuth2 config:');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: - clientId: $_clientId');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: - redirectUri: $redirectUri');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: - authEndpoint: $authorizationEndpoint');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: - tokenEndpoint: $tokenEndpoint');
      
      // Porneste serverul HTTP local pentru a prinde redirect-ul
      final server = await HttpServer.bind('localhost', 8080);
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Local HTTP server started on localhost:8080');
      
             // Creeaza grant-ul OAuth2
       final grant = oauth2.AuthorizationCodeGrant(
         _clientId,
         authorizationEndpoint,
         tokenEndpoint,
         secret: _clientSecret,
       );
      
      // Genereaza URL-ul de autorizare cu access_type=offline pentru refresh token
      final authorizationUrl = grant.getAuthorizationUrl(
        redirectUri,
        scopes: [
          'email',
          'profile', 
          'https://www.googleapis.com/auth/drive.file',
          'https://www.googleapis.com/auth/spreadsheets'
        ],
      );
      
      // Adauga parametri pentru offline access (refresh token)
      final authUrlWithOfflineAccess = Uri.parse('$authorizationUrl&access_type=offline&prompt=consent');
      
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Authorization URL generated with offline access');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Opening browser for authentication...');
      
      // Deschide URL-ul in browser
      if (await canLaunchUrl(authUrlWithOfflineAccess)) {
        await launchUrl(authUrlWithOfflineAccess, mode: LaunchMode.externalApplication);
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Browser opened successfully');
      } else {
        throw Exception('Nu s-a putut deschide browser-ul');
      }
      
      // Asteapta redirect-ul pe serverul local
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
      
             // Raspunde la browser ca s-a terminat cu succes
       final htmlResponse = '<html><body><h1>✅ Autentificare reusita!</h1><p>Poti inchide aceasta fereastra si sa te intorci la aplicatie.</p><script>window.close();</script></body></html>';
       request.response
         ..statusCode = 200
         ..headers.set('content-type', 'text/html; charset=utf-8')
         ..write(htmlResponse);
       await request.response.close();
       await server.close();
      
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Exchanging authorization code for access token...');
      
      // Schimba codul de autorizare cu token-ul de acces
      final client = await grant.handleAuthorizationResponse(queryParams);
      _accessToken = client.credentials.accessToken;
      _refreshToken = client.credentials.refreshToken;
      
      // Calculeaza timpul de expirare
      _tokenExpiration = client.credentials.expiration ?? DateTime.now().toUtc().add(Duration(hours: 1));
      
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Access token received');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Access token length: ${_accessToken!.length}');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Refresh token available: ${_refreshToken != null}');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Token expires at: $_tokenExpiration (UTC: ${_tokenExpiration!.isUtc})');
      
      // Configureaza API clients cu OAuth2 client
      await _setupApiClientsWithOAuth2Client(client);
      
      // Obtine informatiile utilizatorului
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Getting user info from Google...');
      final userInfo = await _getUserInfoFromGoogle(_accessToken!);
      _userEmail = userInfo['email'];
      _userName = userInfo['name'];
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: User info - email: $_userEmail, name: $_userName');
      
      // Salveaza token-urile pentru utilizare viitoare
      await _saveDesktopTokens(_accessToken!, _refreshToken, _userEmail!, _userName);
      
      _isAuthenticated = true;
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: OAuth2 authentication successful for $_userEmail');
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: OAuth2 auth failed: $e');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error type: ${e.runtimeType}');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Stack trace: ${StackTrace.current}');
      _lastError = 'Autentificarea OAuth2 a esuat: ${e.toString()}';
    }
  }

  /// Configureaza API clients cu access token
  Future<void> _setupApiClientsWithToken(String accessToken, String? refreshToken, String email, String? name) async {
    try {
      // Salveaza token-urile desktop cu refresh token
      await _saveDesktopTokens(accessToken, refreshToken, email, name);
      
      // IMPORTANT: Convert to UTC if not already UTC
      final expirationUtc = _tokenExpiration!.isUtc ? _tokenExpiration! : _tokenExpiration!.toUtc();
      
      // Setup API clients in sequence
      final accessTokenObj = auth.AccessToken('Bearer', accessToken, expirationUtc);
      final credentials = auth.AccessCredentials(
        accessTokenObj,
        null,
        [
          'https://www.googleapis.com/auth/drive.file',
          'https://www.googleapis.com/auth/spreadsheets'
        ],
      );
      final httpClient = http.Client();
      final client = auth.authenticatedClient(httpClient, credentials);
      _driveApi = drive.DriveApi(client);
      _sheetsApi = sheets.SheetsApi(client);
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Failed to setup API clients with token: $e');
      rethrow;
    }
  }

  /// Configureaza API clients cu Google Sign In
  Future<void> _setupApiClients() async {
    try {
      // Get authorization headers using the new API
      const scopes = [
        'https://www.googleapis.com/auth/drive.file',
        'https://www.googleapis.com/auth/spreadsheets',
      ];
      
      final authHeaders = await _currentUser!.authorizationClient.authorizationHeaders(scopes);
      if (authHeaders != null) {
        final authenticateClient = GoogleAuthClient(authHeaders);
        
        _driveApi = drive.DriveApi(authenticateClient);
        _sheetsApi = sheets.SheetsApi(authenticateClient);
        
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: API clients configured with Google Sign In');
      } else {
        throw Exception('Nu s-au putut obtine headerele de autorizare');
      }
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Failed to setup API clients: $e');
      rethrow;
    }
  }

  /// Configureaza API clients cu OAuth2 client
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

  /// Obtine informatiile utilizatorului de la Google
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

  /// Salveaza token-urile desktop cu refresh token
  Future<void> _saveDesktopTokens(String accessToken, String? refreshToken, String email, String? name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final accessTokenKey = _getTokenKey(_currentConsultantToken!, 'access_token');
      final refreshTokenKey = _getTokenKey(_currentConsultantToken!, 'refresh_token');
      final emailKey = _getTokenKey(_currentConsultantToken!, 'user_email');
      final nameKey = _getTokenKey(_currentConsultantToken!, 'user_name');
      final expirationKey = _getTokenKey(_currentConsultantToken!, 'token_expiration');
      
      // Save all tokens in parallel
      await Future.wait([
        prefs.setString(accessTokenKey, accessToken),
        prefs.setString(emailKey, email),
        if (refreshToken != null) prefs.setString(refreshTokenKey, refreshToken),
        if (name != null) prefs.setString(nameKey, name),
        if (_tokenExpiration != null) prefs.setString(expirationKey, _tokenExpiration!.toUtc().toIso8601String()),
      ]);
      
      // Tokens saved successfully
      
    } catch (e, stackTrace) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Failed to save desktop tokens: $e');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Stack trace: $stackTrace');
    }
  }

  /// Deconecteaza consultantul curent
  Future<void> disconnect() async {
    try {
      if (_currentConsultantToken == null) {
        debugPrint('⚠️ GOOGLE_DRIVE_SERVICE: No consultant token for disconnect');
        return;
      }

      if (_isPlatformSupported() && _googleSignIn != null) {
        // Pe mobile, sterge doar asocierea consultantului cu email-ul
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
      
      // Opreste timer-ul de background refresh
      _backgroundRefreshTimer?.cancel();
      _backgroundRefreshTimer = null;
      
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Disconnected successfully for consultant: ${_currentConsultantToken?.substring(0, 8)}');
      notifyListeners();
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error disconnecting: $e');
      _lastError = 'Eroare la deconectare: ${e.toString()}';
    }
  }


  /// Debug method to dump form data structure
  void _dumpFormDataStructure(Map<String, dynamic> formData, [String prefix = '']) {
    for (var entry in formData.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value is Map<String, dynamic>) {
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: $prefix$key: {');
        _dumpFormDataStructure(value, '$prefix  ');
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: $prefix}');
      } else if (value is List) {
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: $prefix$key: [${value.length} items]');
        for (int i = 0; i < value.length; i++) {
          if (value[i] is Map<String, dynamic>) {
            debugPrint('🔧 GOOGLE_DRIVE_SERVICE: $prefix  [$i]: {');
            _dumpFormDataStructure(value[i] as Map<String, dynamic>, '$prefix    ');
            debugPrint('🔧 GOOGLE_DRIVE_SERVICE: $prefix  }');
          } else {
            debugPrint('🔧 GOOGLE_DRIVE_SERVICE: $prefix  [$i]: ${value[i]}');
          }
        }
      } else {
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: $prefix$key: $value');
      }
    }
  }


  /// FIX: Enhanced client saving with robust error handling and validation
  Future<String?> saveClientToXlsx(dynamic client) async {
    debugPrint('🔧🔧 GOOGLE_DRIVE_SERVICE: ========== saveClientToXlsx START ==========');
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Client: ${client?['name'] ?? 'NULL'} (${client?['phoneNumber'] ?? 'NULL'})');
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Client type: ${client.runtimeType}');
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Authentication status: $_isAuthenticated');
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Drive API: ${_driveApi != null ? 'OK' : 'NULL'}');
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Sheets API: ${_sheetsApi != null ? 'OK' : 'NULL'}');
    
    try {
      // Step 0: Enhanced client data validation
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Step 0 - Enhanced client data validation...');
      if (!_validateClientDataEnhanced(client)) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Enhanced client data validation failed');
        return 'Datele clientului sunt incomplete sau invalide';
      }
      
      // Step 1: Enhanced token validation with retry
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Step 1 - Enhanced token validation...');
      final tokenValid = await _ensureValidTokenWithRetry();
      if (!tokenValid) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Enhanced token validation failed');
        return 'Token expirat. Reconectati-va la Google Drive din Setari';
      }
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Enhanced token validation successful');
      
      // Step 2: Enhanced authentication check
      if (!_isAuthenticated) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Not authenticated');
        return 'Pentru a salva datele, conectati-va la Google Drive din Setari';
      }
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Authentication check passed');
  
      // Step 3: Enhanced service readiness check
      if (!_isServiceReadyEnhanced()) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Enhanced service not ready');
        return 'Eroare: Serviciul Google Sheets nu este complet initializat. Incercati sa va reconectati din Setari.';
      }
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Enhanced service readiness check passed');
  
      // Step 4: Enhanced spreadsheet finding/creation
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Step 4 - Enhanced spreadsheet finding/creation...');
      final swFindOrCreateSpreadsheet = Stopwatch()..start();
      final spreadsheetId = await _findOrCreateSpreadsheet('clienti');
      swFindOrCreateSpreadsheet.stop();
      debugPrint('GD_TRACE: _findOrCreateSpreadsheet completed in ${swFindOrCreateSpreadsheet.elapsedMilliseconds}ms');
      if (spreadsheetId == null) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Could not find or create spreadsheet');
        return _lastError ?? 'Eroare la gasirea sau crearea fisierului Google Sheets.';
      }
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Spreadsheet ID: $spreadsheetId');
  
      // Step 5: Enhanced sheet finding/creation
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Step 5 - Enhanced sheet finding/creation...');
      final swFindOrCreateSheet = Stopwatch()..start();
      final watchdog = _startWatch('_findOrCreateSheet');
      final sheetTitle = await _findOrCreateSheet(spreadsheetId).whenComplete(() => watchdog.cancel());
      swFindOrCreateSheet.stop();
      debugPrint('GD_TRACE: _findOrCreateSheet completed in ${swFindOrCreateSheet.elapsedMilliseconds}ms');
      if (sheetTitle == null) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Could not find or create sheet');
        return _lastError ?? 'Eroare la gasirea sau crearea foii de calcul pentru luna curenta.';
      }
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Sheet title: $sheetTitle');

      // Step 5.5: Enhanced duplicate checking
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Step 5.5 - Enhanced duplicate checking...');
      final clientPhoneNumber = client['phoneNumber']?.toString() ?? client['phoneNumber1']?.toString() ?? '';
      final swDup = Stopwatch()..start();
      final clientExists = await _checkIfClientExistsInSheet(spreadsheetId, sheetTitle, clientPhoneNumber);
      swDup.stop();
      debugPrint('GD_TRACE: _checkIfClientExistsInSheet completed in ${swDup.elapsedMilliseconds}ms');
      
      if (clientExists) {
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Client already exists in sheet, skipping save to prevent duplicates');
        debugPrint('🔧🔧 GOOGLE_DRIVE_SERVICE: ========== saveClientToXlsx END (SKIPPED - ALREADY EXISTS) ==========');
        return null; // Success - client already exists, no need to save again
      }
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Client does not exist in sheet, proceeding with save');
  
      // Step 6: Enhanced client data preparation
      debugPrint('GD_VERIFY: using forms subcollection as single source of truth for form data');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Step 6 - Enhanced client data preparation...');
      final swPrep = Stopwatch()..start();
      final clientRowData = await _prepareClientRowData(client);
      swPrep.stop();
      debugPrint('GD_TRACE: _prepareClientRowData completed in ${swPrep.elapsedMilliseconds}ms');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Prepared row data: $clientRowData');
      
      // Step 7: Enhanced save with improved retry mechanism
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Step 7 - Enhanced save with improved retry...');
      
      bool success = false;
      String? lastError;
      const int maxRetries = 3;
      
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Save attempt $attempt/$maxRetries');
        
        try {
          final swAppend = Stopwatch()..start();
          success = await _appendRowToSheet(spreadsheetId, sheetTitle, clientRowData);
          swAppend.stop();
          debugPrint('GD_TRACE: _appendRowToSheet attempt $attempt took ${swAppend.elapsedMilliseconds}ms');
          
          if (success) {
            debugPrint('✅ GOOGLE_DRIVE_SERVICE: Client saved successfully to Google Sheets on attempt $attempt');
            debugPrint('🔧🔧 GOOGLE_DRIVE_SERVICE: ========== saveClientToXlsx END (SUCCESS) ==========');
            return null; // Success
          } else {
            lastError = _lastError ?? 'Eroare necunoscuta la salvarea datelor.';
            debugPrint('❌ GOOGLE_DRIVE_SERVICE: Failed to save on attempt $attempt: $lastError');
            
            if (attempt < maxRetries) {
              debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Waiting 3 seconds before retry...');
              await Future.delayed(const Duration(seconds: 3));
            }
          }
        } catch (e) {
          lastError = 'Eroare la incercarea $attempt: ${e.toString()}';
          debugPrint('❌ GOOGLE_DRIVE_SERVICE: Exception on attempt $attempt: $e');
          
          if (attempt < maxRetries) {
            debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Waiting 3 seconds before retry...');
            await Future.delayed(const Duration(seconds: 3));
          }
        }
      }
      
      // All retries failed
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: All $maxRetries attempts failed. Last error: $lastError');
      debugPrint('🔧🔧 GOOGLE_DRIVE_SERVICE: ========== saveClientToXlsx END (FAILED) ==========');
      return 'Eroare la salvarea in Google Sheets dupa $maxRetries incercari: $lastError';
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error saving client: $e');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Stack trace: ${StackTrace.current}');
      debugPrint('🔧🔧 GOOGLE_DRIVE_SERVICE: ========== saveClientToXlsx END (EXCEPTION) ==========');
      return 'Eroare la salvarea clientului: ${e.toString()}';
    }
  }

  /// FIX: Enhanced client data validation
  bool _validateClientDataEnhanced(dynamic client) {
    if (client == null) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Client is null');
      return false;
    }
    
    final name = client['name']?.toString() ?? '';
    final phoneNumber = client['phoneNumber']?.toString() ?? client['phoneNumber1']?.toString() ?? '';
    
    if (name.isEmpty || phoneNumber.isEmpty) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Missing name or phone number');
      return false;
    }
    
      // FIX: Enhanced validation for required fields
      // Nu mai presupune existenta client['formData'] in documentul clientului.
      // Datele formularului sunt stocate in subcolectia `forms` (unified form).
    
    debugPrint('✅ GOOGLE_DRIVE_SERVICE: Enhanced client data validation passed');
    return true;
  }

  /// FIX: Enhanced token validation with retry
  Future<bool> _ensureValidTokenWithRetry() async {
    const int maxRetries = 2;
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final isValid = await _ensureValidToken();
        if (isValid) return true;
        
        if (attempt < maxRetries) {
          debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Token validation failed, retrying...');
          await Future.delayed(const Duration(seconds: 1));
        }
      } catch (e) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Token validation error: $e');
        if (attempt < maxRetries) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }
    
    return false;
  }

  /// FIX: Enhanced service readiness check
  bool _isServiceReadyEnhanced() {
    final isReady = _isAuthenticated && _driveApi != null && _sheetsApi != null;
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Service readiness: $isReady (auth: $_isAuthenticated, drive: ${_driveApi != null}, sheets: ${_sheetsApi != null})');
    return isReady;
  }

  /// Verifica daca un client exista deja in sheet dupa numarul de telefon
  Future<bool> _checkIfClientExistsInSheet(String spreadsheetId, String sheetTitle, String phoneNumber) async {
    try {
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: _checkIfClientExistsInSheet - Phone: $phoneNumber');
      
      if (_sheetsApi == null) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Sheets API is null');
        return false;
      }

      if (phoneNumber.isEmpty) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Phone number is empty, cannot check for duplicates');
        return false;
      }

      // Normalizeaza numarul de telefon pentru comparare (elimina spatii, caractere speciale)
      final normalizedPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      final cacheKey = '$spreadsheetId|$sheetTitle';
      final now = DateTime.now();
      final cachedSet = _sheetPhonesCache[cacheKey];
      final cachedAt = _sheetPhonesCacheTime[cacheKey];

      if (cachedSet != null && cachedAt != null && now.difference(cachedAt) < _sheetPhonesTtl) {
        final exists = cachedSet.contains(normalizedPhone);
        debugPrint('GD_CACHE: phones membership (cached=$exists)');
        return exists;
      }

      // Incarca toate valorile o singura data si construieste setul de telefoane normalizate
      final response = await _sheetsApi!.spreadsheets.values.get(
        spreadsheetId,
        '$sheetTitle!A:Z',
      );
      final values = response.values ?? const [];
      final phones = <String>{};
      for (final row in values) {
        for (final cell in row) {
          final s = cell.toString();
          final norm = s.replaceAll(RegExp(r'[^\d]'), '');
          if (norm.isNotEmpty) phones.add(norm);
        }
      }
      _sheetPhonesCache[cacheKey] = phones;
      _sheetPhonesCacheTime[cacheKey] = now;

      final exists = phones.contains(normalizedPhone);
      debugPrint('GD_CACHE: phones membership (loaded=$exists)');
      return exists;
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error checking if client exists: $e');
      // In caz de eroare, permitem salvarea pentru a nu bloca procesul
      return false;
    }
  }

  /// Gaseste un spreadsheet dupa nume sau il creeaza daca nu exista
  Future<String?> _findOrCreateSpreadsheet(String name) async {
    try {
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: _findOrCreateSpreadsheet START - Name: $name');
      debugPrint('GD_TRACE: _findOrCreateSpreadsheet entering');
      
      if (_driveApi == null) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Drive API is null');
        _lastError = 'Drive API nu este initializat';
        return null;
      }
      
      final query = "mimeType='application/vnd.google-apps.spreadsheet' and name='$name' and trashed=false";
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Search query: $query');
      
      final swList = Stopwatch()..start();
      final wdList = _startWatch('Drive.files.list');
      final response = await _driveApi!.files.list(q: query, $fields: 'files(id, name)').whenComplete(() => wdList.cancel());
      swList.stop();
      debugPrint('GD_TRACE: Drive files.list took ${swList.elapsedMilliseconds}ms');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Search response: ${response.files?.length ?? 0} files found');
      
      if (response.files != null && response.files!.isNotEmpty) {
        final fileId = response.files!.first.id!;
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Found existing spreadsheet: $fileId');
        return fileId;
      } else {
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: No existing spreadsheet found, creating new one...');
        
        final newSheet = sheets.Spreadsheet(
          properties: sheets.SpreadsheetProperties(title: name),
        );
        
        final swCreate = Stopwatch()..start();
        final wdCreate = _startWatch('Sheets.spreadsheets.create');
        final createdSheet = await _sheetsApi!.spreadsheets.create(newSheet).whenComplete(() => wdCreate.cancel());
        swCreate.stop();
        debugPrint('GD_TRACE: Sheets.spreadsheets.create took ${swCreate.elapsedMilliseconds}ms');
        final fileId = createdSheet.spreadsheetId!;
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Created new spreadsheet: $fileId');
        return fileId;
      }
    } catch (e) {
      _lastError = 'Eroare la cautarea sau crearea fisierului: $e';
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: EROARE in _findOrCreateSpreadsheet: $_lastError');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  /// Gaseste un sheet (tab) dupa titlu sau il creeaza daca nu exista
  Future<String?> _findOrCreateSheet(String spreadsheetId) async {
    try {
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: _findOrCreateSheet START - SpreadsheetId: $spreadsheetId');
      debugPrint('GD_TRACE: _findOrCreateSheet entering');
      
      if (_sheetsApi == null) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Sheets API is null');
        _lastError = 'Sheets API nu este initializat';
        return null;
      }
      
      // Genereaza titlul pentru luna si anul curent (ex: Iul 25)
      final now = DateTime.now();
      final sheetTitle = _generateRomanianSheetTitle(now);
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Generated sheet title: $sheetTitle');

      final swGet = Stopwatch()..start();
      final wdGet = _startWatch('Sheets.spreadsheets.get');
      final spreadsheet = await _sheetsApi!.spreadsheets.get(spreadsheetId, includeGridData: false).whenComplete(() => wdGet.cancel());
      swGet.stop();
      debugPrint('GD_TRACE: Sheets.spreadsheets.get took ${swGet.elapsedMilliseconds}ms');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Retrieved spreadsheet with ${spreadsheet.sheets?.length ?? 0} sheets');

      final existingSheet = spreadsheet.sheets?.firstWhere(
        (s) => s.properties?.title == sheetTitle,
        orElse: () => sheets.Sheet(),
      );

      if (existingSheet?.properties?.title == sheetTitle) {
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Found existing sheet: $sheetTitle');
        return sheetTitle;
      } else {
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Creating new sheet: $sheetTitle');
        
        final addSheetRequest = sheets.AddSheetRequest(
          properties: sheets.SheetProperties(title: sheetTitle),
        );
        
        final swBatchUpdate = Stopwatch()..start();
        final wdBatch = _startWatch('Sheets.spreadsheets.batchUpdate(addSheet)');
        await _sheetsApi!.spreadsheets.batchUpdate(
          sheets.BatchUpdateSpreadsheetRequest(requests: [sheets.Request(addSheet: addSheetRequest)]),
          spreadsheetId,
        ).whenComplete(() => wdBatch.cancel());
        swBatchUpdate.stop();
        debugPrint('GD_TRACE: Sheets.spreadsheets.batchUpdate(addSheet) took ${swBatchUpdate.elapsedMilliseconds}ms');

        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Created new sheet: $sheetTitle');
        
        // Adauga header-ul in noul sheet
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Adding header to new sheet...');
        final swHeader = Stopwatch()..start();
        final wdHeader = _startWatch('_addHeaderToSheet');
        await _addHeaderToSheet(spreadsheetId, sheetTitle).whenComplete(() => wdHeader.cancel());
        swHeader.stop();
        debugPrint('GD_TRACE: _addHeaderToSheet took ${swHeader.elapsedMilliseconds}ms');
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Header added successfully');
        
        return sheetTitle;
      }
    } catch (e) {
      _lastError = 'Eroare la cautarea sau crearea foii de calcul: $e';
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: EROARE in _findOrCreateSheet: $_lastError');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  /// Adauga header-ul in sheet-ul specificat
  Future<void> _addHeaderToSheet(String spreadsheetId, String sheetTitle) async {
    try {
      final headers = _getHeaders();
      final valueRange = sheets.ValueRange()..values = [headers];
      final range = "'$sheetTitle'!A1";
      final swHeaderUpdate = Stopwatch()..start();
      await _sheetsApi!.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        range,
        valueInputOption: 'USER_ENTERED',
      );
      swHeaderUpdate.stop();
      debugPrint('GD_TRACE: Sheets.values.update(header) took ${swHeaderUpdate.elapsedMilliseconds}ms');
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: EROARE in _addHeaderToSheet: $e');
      rethrow; // Re-arunca eroarea pentru ca functia apelanta sa o poata gestiona
    }
  }
  
  /// Adauga un rand de date la finalul unui sheet
  Future<bool> _appendRowToSheet(String spreadsheetId, String sheetTitle, List<dynamic> rowData) async {
    try {
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: _appendRowToSheet START');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: SpreadsheetId: $spreadsheetId');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: SheetTitle: $sheetTitle');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: RowData: $rowData');
      debugPrint('GD_TRACE: _appendRowToSheet entering');
      
      if (_sheetsApi == null) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Sheets API is null');
        _lastError = 'Sheets API nu este initializat';
        return false;
      }

      // Use values.append with INSERT_ROWS to avoid extra get and manual row calculation
      final valueRange = sheets.ValueRange()
        ..majorDimension = 'ROWS'
        ..values = [rowData];

      final swAppend = Stopwatch()..start();
      final wdAppend = _startWatch('Sheets.values.append(INSERT_ROWS)');
      final appendResponse = await _sheetsApi!.spreadsheets.values.append(
        valueRange,
        spreadsheetId,
        "'$sheetTitle'!A:Z",
        valueInputOption: 'USER_ENTERED',
        insertDataOption: 'INSERT_ROWS',
      ).whenComplete(() => wdAppend.cancel());
      swAppend.stop();
      debugPrint('GD_TRACE: Sheets.values.append took ${swAppend.elapsedMilliseconds}ms');

      final updates = appendResponse.updates;
      final updatedRows = updates?.updatedRows ?? 0;
      if (updatedRows > 0) {
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Row appended successfully via INSERT_ROWS');
        return true;
      }
      _lastError = 'Google Sheets append did not update any rows';
      return false;
      
    } catch (e) {
      _lastError = 'Eroare la adaugarea randului: $e';
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: EROARE in _appendRowToSheet: $_lastError');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Stack trace: ${StackTrace.current}');
      return false;
    }
  }
  
  /// Genereaza titlul sheet-ului cu lunile in romana (ex: Iul 25)
  String _generateRomanianSheetTitle(DateTime date) {
    final Map<int, String> romanianMonths = {
      1: 'Ian',   // Ianuarie
      2: 'Feb',   // Februarie
      3: 'Mar',   // Martie
      4: 'Apr',   // Aprilie
      5: 'Mai',   // Mai
      6: 'Iun',   // Iunie
      7: 'Iul',   // Iulie
      8: 'Aug',   // August
      9: 'Sep',   // Septembrie
      10: 'Oct',  // Octombrie
      11: 'Nov',  // Noiembrie
      12: 'Dec',  // Decembrie
    };
    
    final monthAbbr = romanianMonths[date.month] ?? 'Err';
    final yearAbbr = date.year.toString().substring(2); // Ultimii 2 cifri din an
    
    return '$monthAbbr $yearAbbr';
  }

  /// Returneaza lista de headere conform noii structuri
  List<String> _getHeaders() {
    return [
      'Client',
      'Contact',
      'Codebitor',
      'Data',
      'Status',
      'Credit Client',
      'Venit Client',
      'Credit Codebitor',
      'Venit Codebitor',
    ];
  }

  /// Pregateste datele clientului conform noii structuri
  Future<List<dynamic>> _prepareClientRowData(dynamic client) async {
    try {
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: _prepareClientRowData START');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Client object: ${client.runtimeType}');
      debugPrint('GD_VERIFY: client keys: ${client is Map ? client.keys.toList() : []}');
      
      // Extrage datele de baza din Map
      final String clientName = client['name'] ?? '';
      final phoneNumber1 = client['phoneNumber'] ?? client['phoneNumber1'] ?? '';
      final phoneNumber2 = client['phoneNumber2'] ?? '';
      
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Basic data - Name: $clientName, Phone1: $phoneNumber1, Phone2: $phoneNumber2');
      
      // Formateaza numerele de telefon
      final formattedPhone1 = phoneNumber1.isNotEmpty ? phoneNumber1 : '';
      final formattedPhone2 = phoneNumber2.isNotEmpty ? phoneNumber2 : '';
      
      final String contact = ([formattedPhone1, formattedPhone2].where((p) => p.isNotEmpty).join('/'));
      final String coDebitorName = client['coDebitorName'] ?? '';
      final String ziua = DateTime.now().day.toString();
      final String status = client['additionalInfo'] ?? client['discussionStatus'] ?? '';
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: DEBUG additionalInfo: ${client['additionalInfo']}');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: DEBUG discussionStatus: ${client['discussionStatus']}');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: DEBUG status (to be saved in sheet): $status');

      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Formatted data - Contact: $contact, CoDebitor: $coDebitorName, Day: $ziua, Status: $status');

      // Extrage creditele si veniturile din noua structura (subcolectia forms)
      Map<String, dynamic> formData = {};
      try {
        final newFirebaseService = NewFirebaseService();
        final forms = await newFirebaseService.getClientForms(phoneNumber1);
        debugPrint('GD_VERIFY: forms_count=${forms.length}, first_form_id=${forms.isNotEmpty ? forms.first['id'] : 'NONE'}');
        formData = forms.isNotEmpty ? Map<String, dynamic>.from(forms.first['data'] ?? {}) : {};
      } catch (e) {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Failed to load form data from forms subcollection: $e');
        formData = {};
      }
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Form data keys: ${formData.keys.toList()}');
      // DEBUG: Dump entire form data structure (optional, pentru investigatii)
      _dumpFormDataStructure(formData);
      
      final clientCredits = _extractCredits(formData, 'client');
      final clientIncomes = _extractIncomes(formData, 'client');
      // Incearca "coborrower" primul (numele corect din Firebase)
      final coDebitorCredits = _extractCredits(formData, 'coborrower');
      final coDebitorIncomes = _extractIncomes(formData, 'coborrower');
      
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Extracted data - ClientCredits: $clientCredits, ClientIncomes: $clientIncomes');
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Extracted data - CoDebitorCredits: $coDebitorCredits, CoDebitorIncomes: $coDebitorIncomes');
      
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
      
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Final row data: $rowData');
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: _prepareClientRowData END');
      
      return rowData;
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error in _prepareClientRowData: $e');
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  /// Extrage creditele din formData pentru un tip specific (client/coborrower)
  String _extractCredits(Map<String, dynamic> formData, String type) {
    List<String> credits = [];
    
    // Cauta in structura creditForms
    if (formData.containsKey('creditForms') && formData['creditForms'] is Map<String, dynamic>) {
      final creditForms = formData['creditForms'] as Map<String, dynamic>;
      
      if (creditForms.containsKey(type) && creditForms[type] is List) {
        final creditList = creditForms[type] as List;
        
        for (var creditData in creditList) {
          if (creditData is Map<String, dynamic>) {
            final formattedCredit = _formatCreditSpecial(creditData);
            if (formattedCredit.isNotEmpty) {
              credits.add(formattedCredit);
            }
          }
        }
      }
    }
    
    // Fallback pentru structura veche
    final creditKey = '${type}Credits';
    if (credits.isEmpty && formData.containsKey(creditKey) && formData[creditKey] is List) {
      final creditList = formData[creditKey] as List;
      
      for (var creditData in creditList) {
        if (creditData is Map<String, dynamic>) {
          final formattedCredit = _formatCreditSpecial(creditData);
          if (formattedCredit.isNotEmpty) {
            credits.add(formattedCredit);
          }
        }
      }
    }
    
    return credits.join('; ');
  }

  /// Extrage veniturile din formData pentru un tip specific (client/coborrower)
  String _extractIncomes(Map<String, dynamic> formData, String type) {
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: _extractIncomes START - Type: $type');
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Form data keys: ${formData.keys.toList()}');
    
    List<String> incomes = [];
    
    // Cauta in structura incomeForms
    if (formData.containsKey('incomeForms')) {
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Found incomeForms key');
      
      if (formData['incomeForms'] is Map<String, dynamic>) {
        final incomeForms = formData['incomeForms'] as Map<String, dynamic>;
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: IncomeForms keys: ${incomeForms.keys.toList()}');
        
        if (incomeForms.containsKey(type)) {
          debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Found type key: $type');
          
          if (incomeForms[type] is List) {
            final incomeList = incomeForms[type] as List;
            debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Income list length: ${incomeList.length}');
            
            for (int i = 0; i < incomeList.length; i++) {
              var incomeData = incomeList[i];
              debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Processing income $i: $incomeData');
              
              if (incomeData is Map<String, dynamic>) {
                final formattedIncome = _formatIncomeSpecial(incomeData);
                debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Formatted income: $formattedIncome');
                
                if (formattedIncome.isNotEmpty) {
                  incomes.add(formattedIncome);
                  debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Added income: $formattedIncome');
                }
              } else {
                debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Income data is not Map: ${incomeData.runtimeType}');
              }
            }
          } else {
            debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Type data is not List: ${incomeForms[type].runtimeType}');
          }
        } else {
          debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Type key not found: $type');
        }
      } else {
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: IncomeForms is not Map: ${formData['incomeForms'].runtimeType}');
      }
    } else {
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: incomeForms key not found');
    }
    
    // Fallback pentru structura veche
    final incomeKey = '${type}Incomes';
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Checking fallback key: $incomeKey');
    
    if (incomes.isEmpty && formData.containsKey(incomeKey)) {
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Found fallback key: $incomeKey');
      
      if (formData[incomeKey] is List) {
        final incomeList = formData[incomeKey] as List;
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Fallback income list length: ${incomeList.length}');
        
        for (int i = 0; i < incomeList.length; i++) {
          var incomeData = incomeList[i];
          debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Processing fallback income $i: $incomeData');
          
          if (incomeData is Map<String, dynamic>) {
            final formattedIncome = _formatIncomeSpecial(incomeData);
            debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Formatted fallback income: $formattedIncome');
            
            if (formattedIncome.isNotEmpty) {
              incomes.add(formattedIncome);
              debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Added fallback income: $formattedIncome');
            }
          } else {
            debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Fallback income data is not Map: ${incomeData.runtimeType}');
          }
        }
      } else {
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Fallback data is not List: ${formData[incomeKey].runtimeType}');
      }
    } else {
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Fallback key not found or incomes not empty');
    }
    
    final result = incomes.join('; ');
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: _extractIncomes END - Result: $result');
    return result;
  }

  /// Formateaza un venit in formatul special cerut (conform how_to_save_data.md)
  String _formatIncomeSpecial(Map<String, dynamic> incomeData) {
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: _formatIncomeSpecial START - Data: $incomeData');
    
    final bank = incomeData['bank']?.toString() ?? '';
    final incomeType = incomeData['incomeType']?.toString() ?? '';
    
    // FIX: Use correct field names from actual data structure
    final amount = incomeData['incomeAmount']?.toString() ?? incomeData['amount']?.toString() ?? '';
    final period = incomeData['vechime']?.toString() ?? incomeData['period']?.toString() ?? '';
    
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Extracted values - Bank: $bank, Type: $incomeType, Amount: $amount, Period: $period');
    
    // Verifica daca banca si tipul de venit sunt valide (nu "Selecteaza")
    if (_isSelectValue(bank)) {
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Bank is select value - skipping');
      return '';
    }
    
    if (_isSelectValue(incomeType)) {
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Income type is select value - skipping');
      return '';
    }
    
    // Formateaza suma cu k pentru mii
    String amountFormatted = '';
    if (amount.isNotEmpty) {
      final amountNum = double.tryParse(amount);
      if (amountNum != null) {
        if (amountNum >= 1000) {
          amountFormatted = '${(amountNum / 1000).toStringAsFixed(1)}k';
        } else {
          amountFormatted = amountNum.toStringAsFixed(0);
        }
      }
    }
    
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Amount formatted: $amountFormatted');
    
    // Daca suma este goala, nu salvam venitul
    if (amountFormatted.isEmpty) {
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Amount is empty - skipping');
      return '';
    }
    
    // Formateaza banca si tipul de venit
    final bankFormatted = _formatBankName(bank);
    final incomeTypeFormatted = _formatIncomeTypeCode(incomeType);
    
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Formatted - Bank: $bankFormatted, Type: $incomeTypeFormatted');
    
    // Construieste rezultatul final
    String result = '$bankFormatted-$incomeTypeFormatted: $amountFormatted';
    
    // Adauga perioada daca exista
    if (period.isNotEmpty && period != 'Selecteaza') {
      result += '($period)';
    }
    
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: _formatIncomeSpecial END - Result: $result');
    return result;
  }

  /// Formateaza tipul de venit in cod scurt
  String _formatIncomeTypeCode(String incomeType) {
    switch (incomeType.toLowerCase()) {
      case 'salariu':
        return 'sal';
      case 'pensie':
        return 'pen';
      case 'pensie mai':
        return 'pen_mai';
      case 'indemnizatie':
        return 'ind';
      default:
        return incomeType.toLowerCase();
    }
  }

  /// Formateaza un credit in formatul special cerut (conform how_to_save_data.md)
  String _formatCreditSpecial(Map<String, dynamic> creditData) {
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: _formatCreditSpecial cu date: $creditData');
    
    final bank = creditData['bank']?.toString() ?? '';
    final creditType = creditData['creditType']?.toString() ?? '';
    final sold = creditData['sold']?.toString() ?? '';
    final consumat = creditData['consumat']?.toString() ?? '';
    final rata = creditData['rata']?.toString() ?? '';
    final rateType = creditData['rateType']?.toString() ?? '';
    final perioada = creditData['perioada']?.toString() ?? '';
    
    // Verifica daca banca si tipul de credit sunt valide (nu "Selecteaza")
    if (_isSelectValue(bank)) {
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Credit incomplet - selecteaza banca');
      return '';
    }
    
    if (_isSelectValue(creditType)) {
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Credit incomplet - selecteaza tipul');
      return '';
    }
    
    // Formateaza banca folosind aceeasi logica ca la venituri
    final bankFormatted = _formatBankName(bank);
    
    // Formateaza tipul de credit
    final creditTypeFormatted = _formatCreditType(creditType);
    
    // Formateaza sumele (sold/consumat si rata)
    final amountsPart = _formatCreditAmounts(sold, consumat, rata);
    
    // Daca nu exista nicio suma, nu salvam creditul
    if (amountsPart.isEmpty) {
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Credit fara sume - ignorat');
      return '';
    }
    
    // Formateaza detaliile (rateType si perioada)
    final detailsPart = _formatCreditDetails(rateType, perioada, creditType);
    
    // Construieste formatul final: "banca-tip: sume(detalii)"
    String result = '$bankFormatted-$creditTypeFormatted: $amountsPart';
    
    // Adauga detaliile doar daca exista si nu sunt goale
    if (detailsPart.isNotEmpty && !_isSelectValue(detailsPart)) {
      result += '($detailsPart)';
    }
    
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Credit formatat final: $result');
    return result;
  }

  /// Formateaza numele bancii (conform how_to_save_data.md)
  String _formatBankName(String bank) {
    switch (bank.toLowerCase()) {
      case 'alpha bank':
        return 'ALPHA';
      case 'axi ifn':
        return 'Axi';
      case 'banca romaneasca':
        return 'BR';
      case 'bcr':
        return 'BCR';
      case 'best credit':
        return 'BC';
      case 'bnp paribas':
        return 'BNP';
      case 'brd':
        return 'BRD';
      case 'brd finance':
        return 'BRDf';
      case 'banca transilvania':
        return 'BT';
      case 'bt direct':
        return 'BTd';
      case 'bt leasing':
        return 'BTl';
      case 'car':
        return 'CAR';
      case 'cec bank':
        return 'CEC';
      case 'cash':
        return 'CASH';
      case 'cetelem':
        return 'CTLM';
      case 'credit europe bank':
        return 'CreditEU';
      case 'credit24':
        return 'C24';
      case 'credex':
        return 'CREDEX';
      case 'credius':
        return 'CREDIUS';
      case 'eco finance':
        return 'EXOfin';
      case 'exim bank':
        return 'EXIM';
      case 'first bank':
        return 'FIRST';
      case 'garanti bank':
        return 'GRNTI';
      case 'happy credit':
        return 'HAPPY';
      case 'hora credit':
        return 'HORA';
      case 'icredit':
        return 'iCREDIT';
      case 'idea bank':
        return 'IDEA';
      case 'ifn':
        return 'IFN';
      case 'ing':
        return 'ING';
      case 'ing bank':
        return 'ING';
      case 'intesa sanpaolo':
        return 'INTESA';
      case 'leasing ifn':
        return 'leasingIFN';
      case 'libra bank':
        return 'LIBRA';
      case 'patria bank':
        return 'PATRIA';
      case 'pireus bank':
        return 'PIREUS';
      case 'procredit bank':
        return 'PROCREDIT';
      case 'provident':
        return 'PROVIDENT';
      case 'raiffeisen bank':
        return 'RF';
      case 'raiffeisen leasing':
        return 'RFl';
      case 'revolut':
        return 'REVOLUT';
      case 'salt bank':
        return 'SALT';
      case 'simplu credit':
        return 'SIMPLU';
      case 'tbi bank':
        return 'TBI';
      case 'unicredit':
        return 'UNICREDIT';
      case 'unicredit consumer financing':
        return 'UNICREDITcf';
      case 'unicredit leasing':
        return 'UNICREDITll';
      case 'viva credit':
        return 'VIVA';
      case 'volksbank':
        return 'VOLKS';
      default:
        // Pentru bancile necunoscute, returneaza primele 3-4 caractere
        return bank.length > 6 ? bank.substring(0, 6) : bank;
    }
  }

  /// Formateaza tipul de credit
  String _formatCreditType(String creditType) {
    switch (creditType.toLowerCase()) {
      case 'card cumparaturi':
      case 'card de cumparaturi':
        return 'cc';
      case 'nevoi personale':
        return 'np';
      case 'overdraft':
        return 'ovd';
      case 'ipotecar':
        return 'ip';
      case 'prima casa':
        return 'pc';
      default:
        return creditType.toLowerCase();
    }
  }

  /// Formateaza sumele creditului (sold/consumat si rata)
  String _formatCreditAmounts(String sold, String consumat, String rata) {
    final soldFormatted = _formatAmountWithK(sold);
    final consumatFormatted = _formatAmountWithK(consumat);
    final rataFormatted = _formatAmountWithK(rata);
    
    // Construieste partea cu sumele folosind cratima in loc de slash
    String amounts = '';
    if (soldFormatted.isNotEmpty || consumatFormatted.isNotEmpty) {
      // Trateaza cazurile cand una dintre sume lipseste
      if (soldFormatted.isNotEmpty && consumatFormatted.isNotEmpty) {
        amounts = '$soldFormatted-$consumatFormatted';
      } else if (soldFormatted.isNotEmpty) {
        amounts = soldFormatted;
      } else if (consumatFormatted.isNotEmpty) {
        amounts = consumatFormatted;
      }
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

  /// Formateaza detaliile creditului (rateType si perioada)
  String _formatCreditDetails(String rateType, String perioada, String creditType) {
    final details = <String>[];
    
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Credit details - rateType: "$rateType", perioada: "$perioada"');
    
    // Adauga tipul ratei daca exista si nu este "Selecteaza"
    if (rateType.isNotEmpty && !_isSelectValue(rateType)) {
      details.add(rateType);
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Adaugat rateType: $rateType');
    }
    
    // Adauga perioada daca exista
    if (perioada.isNotEmpty && !_isSelectValue(perioada)) {
      final period = _formatPeriod(perioada);
      if (period.isNotEmpty) {
        details.add(period);
      }
    }
    
    // Pentru anumite tipuri de credit, nu afisa paranteze goale
    if (details.isEmpty) {
      final creditTypeLower = creditType.toLowerCase();
      debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Nu exista detalii pentru $creditTypeLower');
      
      // Pentru carduri, overdraft si nevoi personale, nu e nevoie de detalii suplimentare
      if (creditTypeLower.contains('card') || 
          creditTypeLower.contains('overdraft') || 
          creditTypeLower.contains('nevoi personale')) {
        debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Tip de credit care nu necesita detalii');
        return '';
      }
    }
    
    final result = details.join(',');
    debugPrint('🔧 GOOGLE_DRIVE_SERVICE: Detalii credit finale: "$result"');
    
    return result;
  }

  /// Formateaza o suma cu "k" pentru mii (5500 -> 5,5k)
  String _formatAmountWithK(String amount) {
    if (amount.isEmpty || amount == '0') return '';
    
    try {
      // Elimina virgulele existente
      final cleanAmount = amount.replaceAll(',', '');
      final numericValue = double.tryParse(cleanAmount);
      
      if (numericValue != null && numericValue > 0) {
        if (numericValue >= 1000) {
          final kValue = numericValue / 1000;
          // Formateaza cu o zecimala daca nu e numar intreg
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

  /// Formateaza perioada (ani/luni format)
  String _formatPeriod(String perioada) {
    if (perioada.isEmpty) return '';
    
    // Daca perioada contine deja formatul ani/luni (ex: "2/3"), returneaza asa cum e
    if (perioada.contains('/')) {
      return perioada;
    }
    
    // Incearca sa parseze ca numarul de luni
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


  /// Verifica daca o valoare este "Selecteaza" in diverse variante
  bool _isSelectValue(String value) {
    final lowerValue = value.toLowerCase().trim();
    return lowerValue == 'selecteaza' || 
           lowerValue == 'selecteaza' || 
           lowerValue == 'selecteaza banca' ||
           lowerValue == 'selecteaza tipul' ||
           lowerValue == 'select' ||
           lowerValue.isEmpty;
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