import 'package:mat_finance/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mat_finance/backend/services/matcher_service.dart';
import 'package:mat_finance/backend/services/splash_service.dart';
import 'package:mat_finance/backend/services/llm_service.dart';
import 'package:mat_finance/frontend/components/headers/widget_header1.dart';
import 'package:mat_finance/backend/services/role_service.dart';

/// Area pentru setari care urmeaza exact design-ul specificat
/// Permite gestionarea Google Drive si alte setari
class SettingsArea extends StatefulWidget {
  const SettingsArea({super.key});

  @override
  State<SettingsArea> createState() => _SettingsAreaState();
}

class _SettingsAreaState extends State<SettingsArea> {
  late final MatcherService _matcherService;
  late final LLMService _llmService;

  @override
  void initState() {
    super.initState();
    // Foloseste serviciile pre-incarcate din splash
    _matcherService = SplashService().matcherService;
    _llmService = SplashService().llmService;
    
    // Asculta schimbarile de la servicii pentru actualizari in timp real
    _matcherService.addListener(_onMatcherServiceChanged);
    _llmService.addListener(_onLLMServiceChanged);
    
    // Incarca cheia API existenta
    _loadApiKey();
  }

  @override
  void dispose() {
    _matcherService.removeListener(_onMatcherServiceChanged);
    _llmService.removeListener(_onLLMServiceChanged);
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

  /// Callback pentru schimbarile din LLMService
  void _onLLMServiceChanged() {
    if (mounted) {
      setState(() {
        // UI-ul se va actualiza automat datorita setState
      });
    }
  }

  /// Incarca cheia API din serviciu
  Future<void> _loadApiKey() async {
    // Cheia API se incarca automat in LLMService
    setState(() {
      // UI-ul se va actualiza automat
    });
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
    final isSupervisor = RoleService().isSupervisor;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Widget Header
        WidgetHeader1(title: 'Setari'),
        
        const SizedBox(height: AppTheme.smallGap),

        // Indicator pentru supervisor
        if (isSupervisor)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.smallGap),
            margin: const EdgeInsets.only(bottom: AppTheme.smallGap),
            decoration: ShapeDecoration(
              color: AppTheme.elementColor3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'SUPERVISOR MODE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        // Placeholder pentru setari
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/settings_outlined.svg',
                  width: 64,
                  height: 64,
                  colorFilter: ColorFilter.mode(
                    AppTheme.elementColor2,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: AppTheme.mediumGap),
                Text(
                  'Setari in dezvoltare',
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeLarge,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.elementColor2,
                  ),
                ),
                const SizedBox(height: AppTheme.smallGap),
                Text(
                  'Setarile vor fi adaugate pe parcurs pentru a permite configurari avansate ale aplicatiei.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppTheme.fontSizeMedium,
                    color: AppTheme.elementColor1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
