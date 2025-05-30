import 'package:flutter/material.dart';
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/old/widgets/common/panel_container.dart';
import 'package:broker_app/backend/services/settingsService.dart';
import 'package:broker_app/frontend/common/components/headers/widgetHeader1.dart';
import 'package:broker_app/frontend/common/components/headers/fieldHeader1.dart';
import 'package:broker_app/frontend/common/components/items/outlinedItem6.dart';
import 'package:broker_app/frontend/common/components/items/darkItem6.dart';

/// Area pentru setări care urmează exact design-ul specificat
/// Permite schimbarea modului light/dark și a culorii temei cu actualizări în timp real
class SettingsArea extends StatefulWidget {
  const SettingsArea({super.key});

  @override
  State<SettingsArea> createState() => _SettingsAreaState();
}

class _SettingsAreaState extends State<SettingsArea> {
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    // Ascultă schimbările de la SettingsService pentru actualizări în timp real
    _settingsService.addListener(_onSettingsChanged);
    // Asigură-te că service-ul este inițializat
    _initializeSettings();
  }

  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    super.dispose();
  }

  /// Inițializează SettingsService dacă nu este deja inițializat
  Future<void> _initializeSettings() async {
    if (!_settingsService.isInitialized) {
      await _settingsService.initialize();
    }
  }

  /// Callback pentru schimbările din SettingsService
  void _onSettingsChanged() {
    if (mounted) {
      setState(() {
        // UI-ul se va actualiza automat datorită setState
      });
    }
  }

  /// Schimbă modul temei
  void _changeThemeMode(AppThemeMode mode) {
    _settingsService.setThemeMode(mode);
  }

  /// Schimbă culoarea temei
  void _changeThemeColor(AppThemeColor color) {
    _settingsService.setThemeColor(color);
  }

  @override
  Widget build(BuildContext context) {
    return PanelContainer(
      isExpanded: false,
      child: _buildSettingsContent(),
    );
  }

  /// Construiește conținutul setărilor conform design-ului specificat
  Widget _buildSettingsContent() {
    return Container(
      width: double.infinity,
      height: 1032,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: ShapeDecoration(
        color: AppTheme.widgetBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Widget Header
          WidgetHeader1(title: 'Setări'),
          
          const SizedBox(height: AppTheme.smallGap),
          
          // Secțiunea pentru modul temei (Light/Dark/Auto)
          _buildThemeModeSection(),
          
          const SizedBox(height: AppTheme.smallGap),
          
          // Secțiunea pentru culoarea temei
          _buildThemeColorSection(),
        ],
      ),
    );
  }

  /// Construiește secțiunea pentru selectarea modului temei (Light/Dark/Auto)
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
          
          // Row cu opțiunile de temă
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
                        )
                      : OutlinedItem6(
                          title: _settingsService.getThemeModeDisplayName(AppThemeMode.light),
                          svgAsset: 'assets/lightIcon.svg',
                          onTap: () => _changeThemeMode(AppThemeMode.light),
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
                        )
                      : OutlinedItem6(
                          title: _settingsService.getThemeModeDisplayName(AppThemeMode.dark),
                          svgAsset: 'assets/darkIcon.svg',
                          onTap: () => _changeThemeMode(AppThemeMode.dark),
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
                        )
                      : OutlinedItem6(
                          title: _settingsService.getThemeModeDisplayName(AppThemeMode.auto),
                          svgAsset: 'assets/systemIcon.svg',
                          onTap: () => _changeThemeMode(AppThemeMode.auto),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construiește secțiunea pentru selectarea culorii temei
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
                        )
                      : OutlinedItem6(
                          title: _settingsService.getThemeColorDisplayName(AppThemeColor.red),
                          svgAsset: 'assets/colorIcon.svg',
                          iconColor: AppTheme.elementColor2,
                          onTap: () => _changeThemeColor(AppThemeColor.red),
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
                        )
                      : OutlinedItem6(
                          title: _settingsService.getThemeColorDisplayName(AppThemeColor.yellow),
                          svgAsset: 'assets/colorIcon.svg',
                          iconColor: AppTheme.elementColor2,
                          onTap: () => _changeThemeColor(AppThemeColor.yellow),
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
                        )
                      : OutlinedItem6(
                          title: _settingsService.getThemeColorDisplayName(AppThemeColor.green),
                          svgAsset: 'assets/colorIcon.svg',
                          iconColor: AppTheme.elementColor2,
                          onTap: () => _changeThemeColor(AppThemeColor.green),
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
                        )
                      : OutlinedItem6(
                          title: _settingsService.getThemeColorDisplayName(AppThemeColor.cyan),
                          svgAsset: 'assets/colorIcon.svg',
                          iconColor: AppTheme.elementColor2,
                          onTap: () => _changeThemeColor(AppThemeColor.cyan),
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
                        )
                      : OutlinedItem6(
                          title: _settingsService.getThemeColorDisplayName(AppThemeColor.blue),
                          svgAsset: 'assets/colorIcon.svg',
                          iconColor: AppTheme.elementColor2,
                          onTap: () => _changeThemeColor(AppThemeColor.blue),
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
                        )
                      : OutlinedItem6(
                          title: _settingsService.getThemeColorDisplayName(AppThemeColor.pink),
                          svgAsset: 'assets/colorIcon.svg',
                          iconColor: AppTheme.elementColor2,
                          onTap: () => _changeThemeColor(AppThemeColor.pink),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
