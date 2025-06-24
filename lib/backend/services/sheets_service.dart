import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:broker_app/backend/services/firebase_service.dart';

/// Service pentru integrarea cu Google Drive și Google Sheets pentru salvarea datelor clienților
class GoogleDriveService extends ChangeNotifier {
  static final GoogleDriveService _instance = GoogleDriveService._internal();
  factory GoogleDriveService() => _instance;
  GoogleDriveService._internal();

  // Google Sign In configuration (pentru mobile/web)
  GoogleSignIn? _googleSignIn;
  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;
  sheets.SheetsApi? _sheetsApi;
  
  // OAuth2 configuration (pentru desktop)
  oauth2.Client? _oauth2Client;
  String? _userEmail;
  String? _userName;
  
  // Google OAuth2 credentials (ar trebui să fie în env variabile în producție)
  static const String _clientId = '417121374106-nonicnnfp0etvvn52fb43naiksvvjva8.apps.googleusercontent.com';
  static const String _clientSecret = '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';
  static const String _redirectUrl = 'http://localhost:8080/auth/callback';
  
  // Authentication state
  bool _isAuthenticated = false;
  bool _isConnecting = false;
  String? _lastError;
  
  // Sheets management
  String? _assignedSheetId; // ID-ul Google Sheet-ului assignat de șef
  String? _sheetName; // Numele Google Sheet-ului
  
  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isConnecting => _isConnecting;
  String? get lastError => _lastError;
  GoogleSignInAccount? get currentUser => _currentUser;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get assignedSheetId => _assignedSheetId;
  String? get sheetName => _sheetName;

  /// Inițializează serviciul Google Drive și Sheets
  Future<void> initialize() async {
    try {
      if (_isPlatformSupported()) {
        // Platforma mobilă/web - folosește Google Sign In
        _googleSignIn = GoogleSignIn(
          scopes: [
            'email',
            'https://www.googleapis.com/auth/drive.file',
            'https://www.googleapis.com/auth/drive.readonly',
            'https://www.googleapis.com/auth/spreadsheets',
          ],
        );
        
        // Verifică dacă există o sesiune salvată
        await _checkSavedAuthentication();
        
      } else if (_isDesktopPlatform()) {
        // Platforma desktop - folosește OAuth2 manual
        debugPrint('🖥️ GOOGLE_DRIVE_SERVICE: Desktop platform detected, using OAuth2 flow');
        
        // Verifică dacă există un token salvat
        await _checkSavedOAuth2Token();
        
      } else {
        _lastError = 'Google Drive nu este suportat pe această platformă';
        return;
      }
      
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Initialized successfully');
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error initializing: $e');
      if (e.toString().contains('MissingPluginException')) {
        _lastError = 'Google Sign In nu este suportat pe această platformă';
      } else {
        _lastError = 'Eroare la inițializarea serviciului Google Drive: ${e.toString()}';
      }
    }
  }

  /// Verifică dacă platforma curentă suportă Google Sign In nativ
  bool _isPlatformSupported() {
    // Google Sign In nativ suportă Android, iOS și Web
    try {
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          kIsWeb) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Verifică dacă putem folosi OAuth2 manual pentru desktop
  bool _isDesktopPlatform() {
    try {
      return defaultTargetPlatform == TargetPlatform.windows ||
             defaultTargetPlatform == TargetPlatform.macOS ||
             defaultTargetPlatform == TargetPlatform.linux;
    } catch (e) {
      return false;
    }
  }

  /// Verifică dacă există o autentificare salvată (pentru mobile/web)
  Future<void> _checkSavedAuthentication() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consultantToken = await NewFirebaseService().getCurrentConsultantToken();
      
      if (consultantToken != null) {
        final savedSheetId = prefs.getString('drive_sheet_id_$consultantToken');
        final savedSheetName = prefs.getString('drive_sheet_name_$consultantToken');
        
        if (savedSheetId != null && savedSheetName != null) {
          _assignedSheetId = savedSheetId;
          _sheetName = savedSheetName;
        }
      }
      
      // Încearcă să se conecteze silențios doar dacă _googleSignIn este inițializat
      if (_googleSignIn != null) {
        final user = await _googleSignIn!.signInSilently();
        if (user != null) {
          await _onUserSignedIn(user);
        }
      }
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error checking saved auth: $e');
    }
  }

  /// Verifică dacă există un token OAuth2 salvat (pentru desktop)
  Future<void> _checkSavedOAuth2Token() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consultantToken = await NewFirebaseService().getCurrentConsultantToken();
      
      if (consultantToken != null) {
        // Verifică sheet-ul assignat
        final savedSheetId = prefs.getString('drive_sheet_id_$consultantToken');
        final savedSheetName = prefs.getString('drive_sheet_name_$consultantToken');
        
        if (savedSheetId != null && savedSheetName != null) {
          _assignedSheetId = savedSheetId;
          _sheetName = savedSheetName;
        }
        
        // Verifică token-ul OAuth2 salvat
        final savedAccessToken = prefs.getString('oauth2_access_token_$consultantToken');
        final savedRefreshToken = prefs.getString('oauth2_refresh_token_$consultantToken');
        final savedExpiryString = prefs.getString('oauth2_expiry_$consultantToken');
        final savedUserEmail = prefs.getString('oauth2_user_email_$consultantToken');
        final savedUserName = prefs.getString('oauth2_user_name_$consultantToken');
        
        if (savedAccessToken != null && savedRefreshToken != null) {
          DateTime? expiry;
          if (savedExpiryString != null) {
            expiry = DateTime.tryParse(savedExpiryString);
          }
          
          // Recreează client-ul OAuth2
          final credentials = oauth2.Credentials(
            savedAccessToken,
            refreshToken: savedRefreshToken,
            tokenEndpoint: Uri.parse('https://oauth2.googleapis.com/token'),
            scopes: [
              'email',
              'https://www.googleapis.com/auth/drive.file',
              'https://www.googleapis.com/auth/drive.readonly',
              'https://www.googleapis.com/auth/spreadsheets',
            ],
            expiration: expiry,
          );
          
          _oauth2Client = oauth2.Client(
            credentials,
            identifier: _clientId,
            secret: _clientSecret,
          );
          
          _driveApi = drive.DriveApi(_oauth2Client!);
          _sheetsApi = sheets.SheetsApi(_oauth2Client!);
          _isAuthenticated = true;
          _userEmail = savedUserEmail;
          _userName = savedUserName;
          
          debugPrint('✅ GOOGLE_DRIVE_SERVICE: Restored OAuth2 session for desktop');
        }
      }
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error checking saved OAuth2 token: $e');
    }
  }

  /// Conectează utilizatorul la Google Drive
  Future<bool> connectToGoogleDrive() async {
    if (_isConnecting) return false;
    
    try {
      _isConnecting = true;
      _lastError = null;
      notifyListeners();
      
      if (_isPlatformSupported()) {
        // Conectare pentru mobile/web
        final user = await _googleSignIn!.signIn();
        if (user == null) {
          _lastError = 'Conectarea a fost anulată de utilizator';
          return false;
        }
        
        await _onUserSignedIn(user);
        return true;
        
      } else if (_isDesktopPlatform()) {
        // Verifică credențialele înainte de conectare
        if (_clientId.contains('TEMP_DEMO') || _clientId.contains('YOUR_CLIENT')) {
          _lastError = 'Trebuie să configurați credențialele Google OAuth2 în google_drive_service.dart. Consultați GOOGLE_OAUTH2_SETUP.md pentru instrucțiuni.';
          return false;
        }
        
        // Conectare pentru desktop folosind OAuth2 manual
        return await _connectWithOAuth2();
        
      } else {
        _lastError = 'Google Drive nu este suportat pe această platformă';
        return false;
      }
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error connecting: $e');
      if (e.toString().contains('MissingPluginException')) {
        _lastError = 'Google Sign In nu este suportat pe această platformă';
      } else {
        _lastError = 'Eroare la conectarea cu Google Drive: ${e.toString()}';
      }
      return false;
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  /// Conectare folosind OAuth2 manual pentru desktop
  Future<bool> _connectWithOAuth2() async {
    try {
      debugPrint('🌐 GOOGLE_DRIVE_SERVICE: Starting OAuth2 flow for desktop');
      
      // Configurează OAuth2 client-ul
      final grant = oauth2.AuthorizationCodeGrant(
        _clientId,
        Uri.parse('https://accounts.google.com/o/oauth2/auth'),
        Uri.parse('https://oauth2.googleapis.com/token'),
        secret: _clientSecret,
      );
      
      // Generează URL-ul de autentificare
      final authorizationUrl = grant.getAuthorizationUrl(
        Uri.parse(_redirectUrl),
        scopes: [
          'email',
          'https://www.googleapis.com/auth/drive.file',
          'https://www.googleapis.com/auth/drive.readonly',
          'https://www.googleapis.com/auth/spreadsheets',
        ],
      );
      
      debugPrint('🌐 GOOGLE_DRIVE_SERVICE: Opening browser for authentication...');
      
      // Deschide browserul pentru autentificare
      if (await canLaunchUrl(authorizationUrl)) {
        await launchUrl(authorizationUrl, mode: LaunchMode.externalApplication);
      } else {
        _lastError = 'Nu s-a putut deschide browserul pentru autentificare';
        return false;
      }
      
      // Pornește server local pentru a primi redirect-ul
      final completer = Completer<String?>();
      HttpServer? server;
      
      try {
        server = await HttpServer.bind('localhost', 8080);
        debugPrint('🌐 GOOGLE_DRIVE_SERVICE: Local server started on localhost:8080');
        
        server.listen((request) async {
          final uri = request.uri;
          
          if (uri.path == '/auth/callback') {
            final code = uri.queryParameters['code'];
            final error = uri.queryParameters['error'];
            
            // Răspunde cu o pagină de succes/eroare
            final response = request.response;
            response.headers.contentType = ContentType.html;
            
            if (error != null) {
              response.write('<html><body><h1>Eroare de autentificare</h1><p>$error</p><p>Puteți închide această fereastră.</p></body></html>');
              completer.complete(null);
            } else if (code != null) {
              response.write('<html><body><h1>Autentificare reușită!</h1><p>Puteți închide această fereastră și reveni la aplicație.</p></body></html>');
              completer.complete(code);
            } else {
              response.write('<html><body><h1>Eroare</h1><p>Cod de autorizare lipsă.</p></body></html>');
              completer.complete(null);
            }
            
            await response.close();
          }
        });
        
        // Așteaptă codul de autorizare (cu timeout de 5 minute)
        final authCode = await completer.future.timeout(
          const Duration(minutes: 5),
          onTimeout: () {
            debugPrint('⏰ GOOGLE_DRIVE_SERVICE: Authentication timeout');
            return null;
          },
        );
        
        if (authCode == null) {
          _lastError = 'Autentificare anulată sau expirată';
          return false;
        }
        
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Received authorization code');
        
        // Schimbă codul pentru access token
        final client = await grant.handleAuthorizationCode(authCode);
        
        // Obține informațiile utilizatorului
        final userInfo = await _getUserInfo(client);
        
        _oauth2Client = client;
        _driveApi = drive.DriveApi(client);
        _sheetsApi = sheets.SheetsApi(client);
        _isAuthenticated = true;
        _userEmail = userInfo['email'];
        _userName = userInfo['name'];
        
        // Salvează token-ul pentru folosire viitoare
        await _saveOAuth2Token(client.credentials);
        
        debugPrint('✅ GOOGLE_DRIVE_SERVICE: Successfully connected via OAuth2');
        return true;
        
      } finally {
        await server?.close();
      }
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error in OAuth2 flow: $e');
      _lastError = 'Eroare la autentificarea OAuth2: ${e.toString()}';
      return false;
    }
  }

  /// Obține informațiile utilizatorului de la Google
  Future<Map<String, String?>> _getUserInfo(http.Client client) async {
    try {
      final response = await client.get(
        Uri.parse('https://www.googleapis.com/oauth2/v2/userinfo'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return {
          'email': data['email'],
          'name': data['name'],
        };
      } else {
        debugPrint('❌ GOOGLE_DRIVE_SERVICE: Failed to get user info: ${response.statusCode}');
        return {'email': null, 'name': null};
      }
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error getting user info: $e');
      return {'email': null, 'name': null};
    }
  }

  /// Salvează token-ul OAuth2 pentru folosire viitoare
  Future<void> _saveOAuth2Token(oauth2.Credentials credentials) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consultantToken = await NewFirebaseService().getCurrentConsultantToken();
      
      if (consultantToken != null) {
        await prefs.setString('oauth2_access_token_$consultantToken', credentials.accessToken);
        if (credentials.refreshToken != null) {
          await prefs.setString('oauth2_refresh_token_$consultantToken', credentials.refreshToken!);
        }
        if (credentials.expiration != null) {
          await prefs.setString('oauth2_expiry_$consultantToken', credentials.expiration!.toIso8601String());
        }
        if (_userEmail != null) {
          await prefs.setString('oauth2_user_email_$consultantToken', _userEmail!);
        }
        if (_userName != null) {
          await prefs.setString('oauth2_user_name_$consultantToken', _userName!);
        }
        
        debugPrint('💾 GOOGLE_DRIVE_SERVICE: OAuth2 token saved successfully');
      }
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error saving OAuth2 token: $e');
    }
  }

  /// Handler pentru când utilizatorul s-a conectat cu succes (pentru mobile/web)
  Future<void> _onUserSignedIn(GoogleSignInAccount user) async {
    _currentUser = user;
    
    // Obține token-ul de autentificare
    final auth = await user.authentication;
    final authClient = authenticatedClient(
      http.Client(),
      AccessCredentials(
        AccessToken('Bearer', auth.accessToken!, DateTime.now().add(const Duration(hours: 1))),
        auth.accessToken,
        ['https://www.googleapis.com/auth/drive.file', 'https://www.googleapis.com/auth/drive.readonly', 'https://www.googleapis.com/auth/spreadsheets'],
      ),
    );
    
    _driveApi = drive.DriveApi(authClient);
    _sheetsApi = sheets.SheetsApi(authClient);
    _isAuthenticated = true;
    
    debugPrint('✅ GOOGLE_DRIVE_SERVICE: Successfully connected to Google Drive and Sheets');
  }

  /// Deconectează utilizatorul de la Google Drive
  Future<void> disconnectFromGoogleDrive() async {
    try {
      if (_isPlatformSupported() && _googleSignIn != null) {
        // Deconectare pentru mobile/web
        await _googleSignIn!.signOut();
        _currentUser = null;
      } else if (_isDesktopPlatform() && _oauth2Client != null) {
        // Deconectare pentru desktop
        _oauth2Client!.close();
        _oauth2Client = null;
        _userEmail = null;
        _userName = null;
      }
      
      _driveApi = null;
      _sheetsApi = null;
      _isAuthenticated = false;
      _assignedSheetId = null;
      _sheetName = null;
      
      // Șterge datele salvate
      final prefs = await SharedPreferences.getInstance();
      final consultantToken = await NewFirebaseService().getCurrentConsultantToken();
      
      if (consultantToken != null) {
        // Șterge sheet-ul assignat
        await prefs.remove('drive_sheet_id_$consultantToken');
        await prefs.remove('drive_sheet_name_$consultantToken');
        
        // Șterge și token-urile OAuth2 pentru desktop
        await prefs.remove('oauth2_access_token_$consultantToken');
        await prefs.remove('oauth2_refresh_token_$consultantToken');
        await prefs.remove('oauth2_expiry_$consultantToken');
        await prefs.remove('oauth2_user_email_$consultantToken');
        await prefs.remove('oauth2_user_name_$consultantToken');
      }
      
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Successfully disconnected from Google Drive');
      notifyListeners();
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error disconnecting: $e');
      _lastError = 'Eroare la deconectarea de la Google Drive';
      notifyListeners();
    }
  }

  /// Setează Google Sheet-ul assignat de șef
  Future<bool> setAssignedSheet({
    required String sheetId,
    required String sheetName,
  }) async {
    try {
      if (!_isAuthenticated || _sheetsApi == null) {
        _lastError = 'Nu sunteți conectat la Google Drive';
        return false;
      }
      
      // Verifică că sheet-ul există și că utilizatorul are acces
      final sheet = await _sheetsApi!.spreadsheets.get(sheetId);
      if (sheet.properties?.title == null) {
        _lastError = 'Sheet-ul nu există sau nu aveți acces la el';
        return false;
      }
      
      _assignedSheetId = sheetId;
      _sheetName = sheetName;
      
      // Salvează în SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final consultantToken = await NewFirebaseService().getCurrentConsultantToken();
      
      if (consultantToken != null) {
        await prefs.setString('drive_sheet_id_$consultantToken', sheetId);
        await prefs.setString('drive_sheet_name_$consultantToken', sheetName);
      }
      
      // Creează header-ul dacă sheet-ul este gol
      await _ensureSheetHasHeader();
      
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Sheet assigned successfully: $sheetName');
      notifyListeners();
      return true;
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error setting assigned sheet: $e');
      _lastError = 'Eroare la setarea sheet-ului: ${e.toString()}';
      return false;
    }
  }

  /// Caută Google Sheets în Google Drive
  Future<List<DriveSheetInfo>> searchGoogleSheets({String? query}) async {
    try {
      if (!_isAuthenticated || _driveApi == null) {
        throw Exception('Nu sunteți conectat la Google Drive');
      }
      
      String searchQuery = "mimeType='application/vnd.google-apps.spreadsheet'";
      if (query != null && query.isNotEmpty) {
        searchQuery += " and name contains '$query'";
      }
      
      final fileList = await _driveApi!.files.list(
        q: searchQuery,
        spaces: 'drive',
        $fields: 'files(id,name,modifiedTime,size,owners)',
      );
      
      return fileList.files?.map((file) => DriveSheetInfo(
        id: file.id ?? '',
        name: file.name ?? 'Fără nume',
        modifiedTime: file.modifiedTime,
        owners: file.owners?.map((owner) => owner.displayName ?? '').toList() ?? [],
      )).toList() ?? [];
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error searching sheets: $e');
      throw Exception('Eroare la căutarea sheet-urilor: ${e.toString()}');
    }
  }

  /// Salvează datele unui client în Google Sheet
  Future<bool> saveClientToSheet(Map<String, dynamic> clientData) async {
    try {
      if (!_isAuthenticated || _sheetsApi == null) {
        _lastError = 'Nu sunteți conectat la Google Drive';
        return false;
      }
      
      if (_assignedSheetId == null) {
        _lastError = 'Nu aveți un Google Sheet assignat';
        return false;
      }
      
      // Pregătește rândul de date pentru client
      final clientRow = _prepareClientRowData(clientData);
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Prepared client row: $clientRow');
      
      // Găsește următorul rând liber
      final nextRow = await _getNextAvailableRow();
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Next available row: $nextRow');
      
      // Salvează datele
      final range = 'Clienti!A$nextRow:${String.fromCharCode(65 + clientRow.length - 1)}$nextRow';
      debugPrint('🔍 GOOGLE_DRIVE_SERVICE: Saving to range: $range');
      
      final valueRange = sheets.ValueRange()
        ..values = [clientRow];
      
      await _sheetsApi!.spreadsheets.values.update(
        valueRange,
        _assignedSheetId!,
        range,
        valueInputOption: 'USER_ENTERED',
      );
      
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Client data saved successfully to row $nextRow');
      return true;
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error saving client: $e');
      _lastError = 'Eroare la salvarea clientului: ${e.toString()}';
      return false;
    }
  }

  /// Citește datele clienților din Google Sheet
  Future<List<Map<String, dynamic>>> readClientsFromSheet() async {
    try {
      if (!_isAuthenticated || _sheetsApi == null) {
        throw Exception('Nu sunteți conectat la Google Drive');
      }
      
      if (_assignedSheetId == null) {
        throw Exception('Nu aveți un Google Sheet assignat');
      }
      
      // Citește toate datele din sheet
      final response = await _sheetsApi!.spreadsheets.values.get(
        _assignedSheetId!,
        'Clienti!A1:Z1000', // Citește până la coloana Z și rândul 1000
      );
      
      final values = response.values;
      if (values == null || values.isEmpty) {
        return [];
      }
      
      // Prima linie este header-ul
      if (values.length < 2) {
        return []; // Nu există date, doar header
      }
      
      final headers = values.first.cast<String>();
      final clients = <Map<String, dynamic>>[];
      
      // Procesează fiecare rând de date
      for (int i = 1; i < values.length; i++) {
        final row = values[i];
        if (row.isEmpty) continue;
        
        final clientData = <String, dynamic>{};
        for (int j = 0; j < headers.length && j < row.length; j++) {
          if (row[j] != null && row[j].toString().isNotEmpty) {
            clientData[headers[j]] = row[j];
          }
        }
        
        if (clientData.isNotEmpty) {
          clients.add(clientData);
        }
      }
      
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Read ${clients.length} clients from sheet');
      return clients;
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error reading clients: $e');
      throw Exception('Eroare la citirea clienților: ${e.toString()}');
    }
  }

  /// Asigură că sheet-ul are header-ul necesar
  Future<void> _ensureSheetHasHeader() async {
    try {
      // Verifică dacă sheet-ul "Clienti" există
      final sheetMetadata = await _sheetsApi!.spreadsheets.get(_assignedSheetId!);
      final clientSheet = sheetMetadata.sheets?.firstWhere(
        (sheet) => sheet.properties?.title == 'Clienti',
        orElse: () => throw Exception('Sheet not found'),
      );
      
      if (clientSheet == null) {
        // Creează sheet-ul "Clienti"
        await _createClientsSheet();
      }
      
      // Verifică dacă are header
      final headerResponse = await _sheetsApi!.spreadsheets.values.get(
        _assignedSheetId!,
        'Clienti!A1:Z1',
      );
      
      if (headerResponse.values == null || headerResponse.values!.isEmpty) {
        // Adaugă header-ul
        await _addHeaderToSheet();
      }
      
    } catch (e) {
      // Dacă sheet-ul "Clienti" nu există, creează-l
      await _createClientsSheet();
    }
  }

  /// Creează sheet-ul "Clienti" în Google Sheets
  Future<void> _createClientsSheet() async {
    try {
      final addSheetRequest = sheets.AddSheetRequest()
        ..properties = (sheets.SheetProperties()
          ..title = 'Clienti'
          ..gridProperties = (sheets.GridProperties()
            ..rowCount = 1000
            ..columnCount = 26));
      
      final batchUpdateRequest = sheets.BatchUpdateSpreadsheetRequest()
        ..requests = [sheets.Request()..addSheet = addSheetRequest];
      
      await _sheetsApi!.spreadsheets.batchUpdate(
        batchUpdateRequest,
        _assignedSheetId!,
      );
      
      // Adaugă header-ul
      await _addHeaderToSheet();
      
      debugPrint('✅ GOOGLE_DRIVE_SERVICE: Created "Clienti" sheet with header');
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error creating clients sheet: $e');
    }
  }

  /// Adaugă header-ul în sheet
  Future<void> _addHeaderToSheet() async {
    final headers = [
      'Nume Client',
      'Telefon',
      'CNP',
      'Email',
      'Adresa',
      'Status',
      'Data Contact',
      'Consultant',
      'Observații',
      'Tip Credit',
      'Suma Solicitată',
      'Venit Lunar',
      'Bank Recomandată',
      'Data Actualizare'
    ];
    
    final valueRange = sheets.ValueRange()
      ..values = [headers];
    
    await _sheetsApi!.spreadsheets.values.update(
      valueRange,
      _assignedSheetId!,
      'Clienti!A1:N1',
      valueInputOption: 'USER_ENTERED',
    );
  }

  /// Pregătește datele clientului pentru salvarea în rând
  List<dynamic> _prepareClientRowData(Map<String, dynamic> clientData) {
    // Folosește numele consultantului din datele clientului
    String consultantName = clientData['consultant'] ?? 'Consultant';
    
    return [
      clientData['nume'] ?? '',
      clientData['telefon'] ?? '',
      clientData['cnp'] ?? '',
      clientData['email'] ?? '',
      clientData['adresa'] ?? '',
      clientData['status'] ?? '',
      clientData['dataContact'] ?? DateTime.now().toIso8601String(),
      consultantName,
      clientData['observatii'] ?? '',
      clientData['tipCredit'] ?? '',
      clientData['sumasolicitata'] ?? '',
      clientData['venitLunar'] ?? '',
      clientData['bancaRecomandata'] ?? '',
      DateTime.now().toIso8601String(),
    ];
  }

  /// Găsește următorul rând disponibil în sheet
  Future<int> _getNextAvailableRow() async {
    try {
      final response = await _sheetsApi!.spreadsheets.values.get(
        _assignedSheetId!,
        'Clienti!A:A',
      );
      
      final values = response.values;
      if (values == null || values.isEmpty) {
        return 2; // Prima linie cu date (după header)
      }
      
      return values.length + 1;
      
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error finding next row: $e');
      return 2;
    }
  }

  /// Resetează pentru un consultant nou
  Future<void> resetForNewConsultant() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consultantToken = await NewFirebaseService().getCurrentConsultantToken();
      
      if (consultantToken != null) {
        final savedSheetId = prefs.getString('drive_sheet_id_$consultantToken');
        final savedSheetName = prefs.getString('drive_sheet_name_$consultantToken');
        
        _assignedSheetId = savedSheetId;
        _sheetName = savedSheetName;
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ GOOGLE_DRIVE_SERVICE: Error resetting for new consultant: $e');
    }
  }
}

/// Informații despre un Google Sheet din Drive
class DriveSheetInfo {
  final String id;
  final String name;
  final DateTime? modifiedTime;
  final List<String> owners;

  DriveSheetInfo({
    required this.id,
    required this.name,
    this.modifiedTime,
    required this.owners,
  });
} 