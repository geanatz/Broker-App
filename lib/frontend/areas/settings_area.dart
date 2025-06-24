import 'package:broker_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:broker_app/backend/services/settings_service.dart';
import 'package:broker_app/backend/services/matcher_service.dart';
import 'package:broker_app/backend/services/splash_service.dart';
import 'package:broker_app/backend/services/sheets_service.dart';
import 'package:broker_app/frontend/popups/google_drive_popup.dart';
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
      // Pentru mobile/web folosește currentUser
      if (_googleDriveService.currentUser != null) {
        return 'Conectat: ${_googleDriveService.currentUser!.displayName ?? _googleDriveService.currentUser!.email}';
      }
      // Pentru desktop folosește userName/userEmail
      else if (_googleDriveService.userName != null || _googleDriveService.userEmail != null) {
        return 'Conectat: ${_googleDriveService.userName ?? _googleDriveService.userEmail ?? 'Utilizator necunoscut'}';
      }
      
      return 'Conectat: Utilizator necunoscut';
    }
    
    return 'Nu sunteți conectat la Google Drive';
  }

  /// Afișează popup-ul pentru gestionarea Google Drive
  void _showGoogleDrivePopup() {
    showDialog(
      context: context,
      builder: (context) => const GoogleDrivePopup(),
    );
  }
}


