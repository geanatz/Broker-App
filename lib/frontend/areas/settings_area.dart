import 'package:broker_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:broker_app/backend/services/settings_service.dart';
import 'package:broker_app/backend/services/matcher_service.dart';
import 'package:broker_app/backend/services/splash_service.dart';
import 'package:broker_app/backend/services/sheets_service.dart';
import 'package:broker_app/backend/services/update_service.dart';
// import 'package:broker_app/frontend/popups/drive_popup.dart'; // Removed - no longer needed
import 'package:broker_app/frontend/components/headers/widget_header1.dart';
import 'package:broker_app/frontend/components/headers/field_header1.dart';
import 'package:broker_app/frontend/components/items/outlined_item6.dart';
import 'package:broker_app/frontend/components/items/dark_item6.dart';

/// Area pentru setari care urmeaza exact design-ul specificat
/// Permite schimbarea modului light/dark si a culorii temei cu actualizari in timp real
class SettingsArea extends StatefulWidget {
  const SettingsArea({super.key});

  @override
  State<SettingsArea> createState() => _SettingsAreaState();
}

class _SettingsAreaState extends State<SettingsArea> {
  late final SettingsService _settingsService;
  late final MatcherService _matcherService;
  late final GoogleDriveService _googleDriveService;
  final UpdateService _updateService = UpdateService();

  @override
  void initState() {
    super.initState();
    // Foloseste serviciile pre-incarcate din splash
    _settingsService = SettingsService();
    _matcherService = SplashService().matcherService;
    _googleDriveService = SplashService().googleDriveService;
    
    // Asculta schimbarile de la SettingsService pentru actualizari in timp real
    _settingsService.addListener(_onSettingsChanged);
    _matcherService.addListener(_onMatcherServiceChanged);
    _googleDriveService.addListener(_onGoogleDriveServiceChanged);
  }

  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    _matcherService.removeListener(_onMatcherServiceChanged);
    _googleDriveService.removeListener(_onGoogleDriveServiceChanged);
    super.dispose();
  }

  /// Callback pentru schimbarile din SettingsService
  void _onSettingsChanged() {
    if (mounted) {
      setState(() {
        // UI-ul se va actualiza automat datorita setState
      });
    }
  }

  /// Callback pentru schimbarile din MatcherService
  void _onMatcherServiceChanged() {
    if (mounted) {
      setState(() {
        // UI-ul se va actualiza automat datorita setState
      });
    }
  }

  /// Callback pentru schimbarile din GoogleDriveService
  void _onGoogleDriveServiceChanged() {
    if (mounted) {
      setState(() {
        // UI-ul se va actualiza automat datorita setState
      });
    }
  }

  /// Schimba modul temei
  void _changeThemeMode(AppThemeMode mode) {
    _settingsService.setThemeMode(mode);
  }

  /// Schimba culoarea temei
  void _changeThemeColor(AppThemeColor color) {
    _settingsService.setThemeColor(color);
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: AppTheme.widgetDecoration,
      child: _buildSettingsContent(),
    );
  }

  /// Construieste continutul setarilor conform design-ului specificat
  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Widget Header
          WidgetHeader1(title: 'Setari'),
          
          const SizedBox(height: AppTheme.smallGap),
          
          // Sectiunea pentru modul temei (Light/Dark/Auto)
          _buildThemeModeSection(),
          
          const SizedBox(height: AppTheme.smallGap),
          
          // Sectiunea pentru culoarea temei
          _buildThemeColorSection(),
          
          const SizedBox(height: AppTheme.smallGap),
          
          // Sectiunea pentru Google Drive
          _buildGoogleDriveSection(),

          const SizedBox(height: AppTheme.largeGap),
          
          if (_updateService.currentVersion != null)
            Text(
              'Versiune: ${_updateService.currentVersion}',
              style: TextStyle(
                color: AppTheme.elementColor1.withAlpha(50),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  /// Construieste sectiunea pentru selectarea modului temei (Light/Dark/Auto)
  Widget _buildThemeModeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppTheme.containerColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field Header pentru tema
          FieldHeader1(title: 'Tema'),
          
          const SizedBox(height: AppTheme.smallGap),
          
          // Row cu optiunile de tema
          SizedBox(
            width: double.infinity,
            height: 64,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Light Theme Option
                Expanded(
                  child: _settingsService.isThemeModeSelected(AppThemeMode.light)
                      ? DarkItem6(
                          title: _settingsService.getThemeModeDisplayName(AppThemeMode.light),
                          svgAsset: 'assets/lightIcon.svg',
                          onTap: () => _changeThemeMode(AppThemeMode.light),
                          mainBorderRadius: AppTheme.borderRadiusSmall,
                        )
                      : OutlinedItem6(
                          title: _settingsService.getThemeModeDisplayName(AppThemeMode.light),
                          svgAsset: 'assets/lightIcon.svg',
                          onTap: () => _changeThemeMode(AppThemeMode.light),
                          mainBorderRadius: AppTheme.borderRadiusSmall,
                        ),
                ),
                
                const SizedBox(width: 10),
                
                // Dark Theme Option
                Expanded(
                  child: _settingsService.isThemeModeSelected(AppThemeMode.dark)
                      ? DarkItem6(
                          title: _settingsService.getThemeModeDisplayName(AppThemeMode.dark),
                          svgAsset: 'assets/darkIcon.svg',
                          onTap: () => _changeThemeMode(AppThemeMode.dark),
                          mainBorderRadius: AppTheme.borderRadiusSmall,
                        )
                      : OutlinedItem6(
                          title: _settingsService.getThemeModeDisplayName(AppThemeMode.dark),
                          svgAsset: 'assets/darkIcon.svg',
                          onTap: () => _changeThemeMode(AppThemeMode.dark),
                          mainBorderRadius: AppTheme.borderRadiusSmall,
                        ),
                ),
                
                const SizedBox(width: 10),
                
                // Auto Theme Option
                Expanded(
                  child: _settingsService.isThemeModeSelected(AppThemeMode.auto)
                      ? DarkItem6(
                          title: _settingsService.getThemeModeDisplayName(AppThemeMode.auto),
                          svgAsset: 'assets/systemIcon.svg',
                          onTap: () => _changeThemeMode(AppThemeMode.auto),
                          mainBorderRadius: AppTheme.borderRadiusSmall,
                        )
                      : OutlinedItem6(
                          title: _settingsService.getThemeModeDisplayName(AppThemeMode.auto),
                          svgAsset: 'assets/systemIcon.svg',
                          onTap: () => _changeThemeMode(AppThemeMode.auto),
                          mainBorderRadius: AppTheme.borderRadiusSmall,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construieste sectiunea pentru selectarea culorii temei
  Widget _buildThemeColorSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppTheme.containerColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field Header pentru culoarea temei
          FieldHeader1(title: 'Culoare tema'),
          
          const SizedBox(height: AppTheme.smallGap),
          
          // Prima linie cu 3 culori
          SizedBox(
            width: double.infinity,
            height: 64,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Red
                Expanded(
                  child: _settingsService.isThemeColorSelected(AppThemeColor.red)
                      ? DarkItem6(
                          title: _settingsService.getThemeColorDisplayName(AppThemeColor.red),
                          svgAsset: 'assets/colorIcon.svg',
                          onTap: () => _changeThemeColor(AppThemeColor.red),
                          mainBorderRadius: AppTheme.borderRadiusSmall,
                        )
                      : OutlinedItem6(
                          title: _settingsService.getThemeColorDisplayName(AppThemeColor.red),
                          svgAsset: 'assets/colorIcon.svg',
                          iconColor: AppTheme.elementColor2,
                          onTap: () => _changeThemeColor(AppThemeColor.red),
                          mainBorderRadius: AppTheme.borderRadiusSmall,
                        ),
                ),
                
                const SizedBox(width: 10),
                
                // Yellow
                Expanded(
                  child: _settingsService.isThemeColorSelected(AppThemeColor.yellow)
                      ? DarkItem6(
                          title: _settingsService.getThemeColorDisplayName(AppThemeColor.yellow),
                          svgAsset: 'assets/colorIcon.svg',
                          onTap: () => _changeThemeColor(AppThemeColor.yellow),
                          mainBorderRadius: AppTheme.borderRadiusSmall,
                        )
                      : OutlinedItem6(
                          title: _settingsService.getThemeColorDisplayName(AppThemeColor.yellow),
                          svgAsset: 'assets/colorIcon.svg',
                          iconColor: AppTheme.elementColor2,
                          onTap: () => _changeThemeColor(AppThemeColor.yellow),
                          mainBorderRadius: AppTheme.borderRadiusSmall,
                        ),
                ),
                
                const SizedBox(width: 10),
                
                // Green
                Expanded(
                  child: _settingsService.isThemeColorSelected(AppThemeColor.green)
                      ? DarkItem6(
                          title: _settingsService.getThemeColorDisplayName(AppThemeColor.green),
                          svgAsset: 'assets/colorIcon.svg',
                          onTap: () => _changeThemeColor(AppThemeColor.green),
                          mainBorderRadius: AppTheme.borderRadiusSmall,
                        )
                      : OutlinedItem6(
                          title: _settingsService.getThemeColorDisplayName(AppThemeColor.green),
                          svgAsset: 'assets/colorIcon.svg',
                          iconColor: AppTheme.elementColor2,
                          onTap: () => _changeThemeColor(AppThemeColor.green),
                          mainBorderRadius: AppTheme.borderRadiusSmall,
                        ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.smallGap),
          
          // A doua linie cu 3 culori
          SizedBox(
            width: double.infinity,
            height: 64,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cyan
                Expanded(
                  child: _settingsService.isThemeColorSelected(AppThemeColor.cyan)
                      ? DarkItem6(
                          title: _settingsService.getThemeColorDisplayName(AppThemeColor.cyan),
                          svgAsset: 'assets/colorIcon.svg',
                          onTap: () => _changeThemeColor(AppThemeColor.cyan),
                          mainBorderRadius: AppTheme.borderRadiusSmall,
                        )
                      : OutlinedItem6(
                          title: _settingsService.getThemeColorDisplayName(AppThemeColor.cyan),
                          svgAsset: 'assets/colorIcon.svg',
                          iconColor: AppTheme.elementColor2,
                          onTap: () => _changeThemeColor(AppThemeColor.cyan),
                          mainBorderRadius: AppTheme.borderRadiusSmall,
                        ),
                ),
                
                const SizedBox(width: 10),
                
                // Blue
                Expanded(
                  child: _settingsService.isThemeColorSelected(AppThemeColor.blue)
                      ? DarkItem6(
                          title: _settingsService.getThemeColorDisplayName(AppThemeColor.blue),
                          svgAsset: 'assets/colorIcon.svg',
                          onTap: () => _changeThemeColor(AppThemeColor.blue),
                          mainBorderRadius: AppTheme.borderRadiusSmall,
                        )
                      : OutlinedItem6(
                          title: _settingsService.getThemeColorDisplayName(AppThemeColor.blue),
                          svgAsset: 'assets/colorIcon.svg',
                          iconColor: AppTheme.elementColor2,
                          onTap: () => _changeThemeColor(AppThemeColor.blue),
                          mainBorderRadius: AppTheme.borderRadiusSmall,
                        ),
                ),
                
                const SizedBox(width: 10),
                
                // Pink
                Expanded(
                  child: _settingsService.isThemeColorSelected(AppThemeColor.pink)
                      ? DarkItem6(
                          title: _settingsService.getThemeColorDisplayName(AppThemeColor.pink),
                          svgAsset: 'assets/colorIcon.svg',
                          onTap: () => _changeThemeColor(AppThemeColor.pink),
                          mainBorderRadius: AppTheme.borderRadiusSmall,
                        )
                      : OutlinedItem6(
                          title: _settingsService.getThemeColorDisplayName(AppThemeColor.pink),
                          svgAsset: 'assets/colorIcon.svg',
                          iconColor: AppTheme.elementColor2,
                          onTap: () => _changeThemeColor(AppThemeColor.pink),
                          mainBorderRadius: AppTheme.borderRadiusSmall,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construiește secțiunea pentru Google Drive
  Widget _buildGoogleDriveSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppTheme.containerColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field Header pentru Google Drive
          FieldHeader1(title: 'Google Drive'),
          
          const SizedBox(height: AppTheme.smallGap),
          
          // Status și buton pentru Google Drive
          Row(
            children: [
              // Status info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                                         Text(
                       _getGoogleDriveStatusText(),
                       style: AppTheme.safeOutfit(
                         fontSize: AppTheme.fontSizeSmall,
                         color: AppTheme.elementColor3,
                       ),
                     ),
                    
                                        if (_googleDriveService.sheetName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Google Sheet: ${_googleDriveService.sheetName}',
                         style: AppTheme.safeOutfit(
                           fontSize: AppTheme.fontSizeSmall,
                           color: AppTheme.elementColor3,
                         ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Butonul pentru deschiderea popup-ului
              SizedBox(
                width: 140,
                child: _googleDriveService.isAuthenticated
                    ? DarkItem6(
                        title: 'Gestionează',
                        svgAsset: 'assets/settingsIcon.svg',
                        onTap: _showGoogleDrivePopup,
                        mainBorderRadius: AppTheme.borderRadiusSmall,
                      )
                    : OutlinedItem6(
                        title: 'Conectează',
                        svgAsset: 'assets/addIcon.svg',
                        onTap: _showGoogleDrivePopup,
                        mainBorderRadius: AppTheme.borderRadiusSmall,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Obține textul pentru statusul Google Drive
  String _getGoogleDriveStatusText() {
    if (_googleDriveService.lastError != null) {
      return _googleDriveService.lastError!;
    }
    
    if (_googleDriveService.isAuthenticated) {
      String userInfo;
      // Pentru mobile/web folosește currentUser
      if (_googleDriveService.currentUser != null) {
        userInfo = _googleDriveService.currentUser!.displayName ?? _googleDriveService.currentUser!.email;
      }
      // Pentru desktop folosește userName/userEmail
      else if (_googleDriveService.userName != null || _googleDriveService.userEmail != null) {
        userInfo = _googleDriveService.userName ?? _googleDriveService.userEmail ?? 'Utilizator necunoscut';
      } else {
        userInfo = 'Utilizator necunoscut';
      }
      
      return 'Conectat: $userInfo\n(pentru consultantul curent)';
    }
    
    return 'Nu sunteți conectat la Google Drive\n(fiecare consultant poate avea propriul cont)';
  }

  /// Afișează popup pentru gestionarea Google Drive
  void _showGoogleDrivePopup() {
    if (_googleDriveService.isAuthenticated) {
      // Dacă este conectat, afișează opțiuni de gestionare
      _showManageGoogleDriveDialog();
    } else {
      // Dacă nu este conectat, afișează opțiuni de conectare
      _showConnectGoogleDriveDialog();
    }
  }

  /// Dialog pentru conectarea la Google Drive
  void _showConnectGoogleDriveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Conectare Google Drive'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fiecare consultant poate avea propriul cont Google.'),
            SizedBox(height: 12),
            Text('Sistemul automatic va:'),
            SizedBox(height: 8),
            Text('• Găsi/crea automat fișierul "clienti"'),
            Text('• Crea foi lunare automat (ex: "Dec 24")'),
            Text('• Salva cu structura nouă de 9 coloane'),
            SizedBox(height: 16),
            Text('Doriți să conectați acest consultant la Google Drive?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Anulează'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _connectToGoogleDrive();
            },
            child: Text('Conectează'),
          ),
        ],
      ),
    );
  }

  /// Dialog pentru gestionarea Google Drive când este conectat
  void _showManageGoogleDriveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Google Drive - Conectat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Conectat pentru consultantul curent.'),
            SizedBox(height: 8),
            Text('Cont: ${_googleDriveService.userName ?? _googleDriveService.userEmail ?? 'Necunoscut'}'),
            if (_googleDriveService.sheetName != null) ...[
              SizedBox(height: 8),
              Text('Sheet: ${_googleDriveService.sheetName}'),
            ],
            SizedBox(height: 16),
            Text('Sistemul salvează automat în fișierul "clienti" cu structura nouă de 9 coloane.'),
            SizedBox(height: 12),
            Text('Notă: Dacă schimbați consultantul, se va conecta automat la contul Google asociat cu acel consultant.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _disconnectFromGoogleDrive();
            },
            child: Text('Deconectează consultantul'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Conectează la Google Drive
  Future<void> _connectToGoogleDrive() async {
    try {
      debugPrint('🔧 SETTINGS_AREA: Starting Google Drive connection...');
      final success = await _googleDriveService.connect();
      debugPrint('🔧 SETTINGS_AREA: Connection result: $success');
      
      if (success) {
        debugPrint('✅ SETTINGS_AREA: Connection successful');
        _showSuccessSnackBar('Conectat cu succes la Google Drive!');
      } else {
        final error = _googleDriveService.lastError ?? 'Eroare la conectare';
        debugPrint('❌ SETTINGS_AREA: Connection failed: $error');
        _showErrorSnackBar(error);
      }
    } catch (e) {
      debugPrint('💥 SETTINGS_AREA: Exception during connection: $e');
      _showErrorSnackBar('Eroare la conectare: ${e.toString()}');
    }
  }

  /// Deconectează de la Google Drive
  Future<void> _disconnectFromGoogleDrive() async {
    try {
      await _googleDriveService.disconnect();
      _showSuccessSnackBar('Deconectat de la Google Drive');
    } catch (e) {
      _showErrorSnackBar('Eroare la deconectare: ${e.toString()}');
    }
  }

  /// Afișează mesaj de succes
  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Afișează mesaj de eroare
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}


