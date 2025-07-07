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
          
          // Status si informații în partea stângă
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Partea stângă - Status și informații
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status indicator și text
                      Row(
                        children: [
                          // Indicator de status
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _googleDriveService.isAuthenticated 
                                  ? AppTheme.elementColor2 
                                  : AppTheme.elementColor3.withAlpha(100),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Text status
                          Text(
                            _googleDriveService.isAuthenticated 
                                ? 'Conectat' 
                                : 'Deconectat',
                            style: AppTheme.safeOutfit(
                              fontSize: AppTheme.fontSizeSmall,
                              color: _googleDriveService.isAuthenticated 
                                  ? AppTheme.elementColor2 
                                  : AppTheme.elementColor3,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      
                      // Informații utilizator (doar dacă este conectat)
                      if (_googleDriveService.isAuthenticated) ...[
                        const SizedBox(height: 4),
                        Text(
                          _getGoogleDriveUserInfo(),
                          style: AppTheme.safeOutfit(
                            fontSize: AppTheme.fontSizeTiny,
                            color: AppTheme.elementColor3,
                          ),
                        ),
                      ],
                      
                      // Mesaj pentru utilizatori neconectați
                      if (!_googleDriveService.isAuthenticated) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Conectati-va pentru a salva automat clientii',
                          style: AppTheme.safeOutfit(
                            fontSize: AppTheme.fontSizeTiny,
                            color: AppTheme.elementColor3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Buton pentru conectare/deconectare
              IntrinsicWidth(
                child: _googleDriveService.isAuthenticated
                    ? DarkItem6(
                        title: 'Deconecteaza',
                        svgAsset: 'assets/removeIcon.svg',
                        onTap: _disconnectFromGoogleDrive,
                        mainBorderRadius: AppTheme.borderRadiusSmall,
                      )
                    : OutlinedItem6(
                        title: 'Conecteaza',
                        svgAsset: 'assets/addIcon.svg',
                        onTap: _connectToGoogleDrive,
                        mainBorderRadius: AppTheme.borderRadiusSmall,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  /// Obține informațiile despre utilizatorul conectat la Google Drive
  String _getGoogleDriveUserInfo() {
    if (!_googleDriveService.isAuthenticated) {
      return '';
    }
    
    // Pentru mobile/web folosește currentUser
    if (_googleDriveService.currentUser != null) {
      final user = _googleDriveService.currentUser!;
      final name = user.displayName ?? user.email;
      return name;
    }
    
    // Pentru desktop folosește userName/userEmail
    if (_googleDriveService.userName != null) {
      return _googleDriveService.userName!;
    }
    
    if (_googleDriveService.userEmail != null) {
      return _googleDriveService.userEmail!;
    }
    
    return 'Utilizator necunoscut';
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


