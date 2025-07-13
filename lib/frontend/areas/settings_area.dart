import 'package:broker_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:broker_app/backend/services/matcher_service.dart';
import 'package:broker_app/backend/services/splash_service.dart';
import 'package:broker_app/backend/services/sheets_service.dart';
import 'package:broker_app/backend/services/update_service.dart';
import 'package:broker_app/frontend/components/headers/widget_header1.dart';
import 'package:broker_app/frontend/components/headers/field_header1.dart';

/// Area pentru setari care urmeaza exact design-ul specificat
/// Permite gestionarea Google Drive si alte setari
class SettingsArea extends StatefulWidget {
  const SettingsArea({super.key});

  @override
  State<SettingsArea> createState() => _SettingsAreaState();
}

class _SettingsAreaState extends State<SettingsArea> {
  late final MatcherService _matcherService;
  late final GoogleDriveService _googleDriveService;
  final UpdateService _updateService = UpdateService();

  @override
  void initState() {
    super.initState();
    // Foloseste serviciile pre-incarcate din splash
    _matcherService = SplashService().matcherService;
    _googleDriveService = SplashService().googleDriveService;
    
    // Asculta schimbarile de la servicii pentru actualizari in timp real
    _matcherService.addListener(_onMatcherServiceChanged);
    _googleDriveService.addListener(_onGoogleDriveServiceChanged);
  }

  @override
  void dispose() {
    _matcherService.removeListener(_onMatcherServiceChanged);
    _googleDriveService.removeListener(_onGoogleDriveServiceChanged);
    super.dispose();
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
          
          // Status Google Drive
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.smallGap),
            decoration: BoxDecoration(
              color: AppTheme.containerColor2,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: ${_googleDriveService.isAuthenticated ? 'Conectat' : 'Deconectat'}',
                  style: AppTheme.smallTextStyle,
                ),
                if (_googleDriveService.isAuthenticated) ...[
                  const SizedBox(height: AppTheme.tinyGap),
                  Text(
                    'Email: ${_googleDriveService.userEmail ?? 'Necunoscut'}',
                    style: AppTheme.tinyTextStyle,
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.smallGap),
          
          // Buton pentru conectare/deconectare
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_googleDriveService.isAuthenticated) {
                  _googleDriveService.disconnect();
                } else {
                  _googleDriveService.connect();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.elementColor2,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.smallGap),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
              ),
                             child: Text(
                 _googleDriveService.isAuthenticated ? 'Deconectare' : 'Conectare',
                 style: AppTheme.smallTextStyle.copyWith(color: Colors.white),
               ),
            ),
          ),
        ],
      ),
    );
  }
}


