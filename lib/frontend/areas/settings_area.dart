import 'package:mat_finance/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mat_finance/backend/services/matcher_service.dart';
import 'package:mat_finance/backend/services/splash_service.dart';
import 'package:mat_finance/backend/services/llm_service.dart';
import 'package:mat_finance/frontend/components/headers/widget_header1.dart';
import 'package:mat_finance/backend/services/role_service.dart';
import 'package:mat_finance/backend/services/consultant_service.dart';

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
  late final ConsultantService _consultantService;

  int? _selectedColorIndex;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Foloseste serviciile pre-incarcate din splash
    _matcherService = SplashService().matcherService;
    _llmService = SplashService().llmService;
    _consultantService = ConsultantService();

    // Asculta schimbarile de la servicii pentru actualizari in timp real
    _matcherService.addListener(_onMatcherServiceChanged);
    _llmService.addListener(_onLLMServiceChanged);

    // Incarca cheia API existenta
    _loadApiKey();

    // Incarca culoarea curenta a consultantului
    _loadCurrentConsultantColor();
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

  /// Incarca culoarea curenta a consultantului
  Future<void> _loadCurrentConsultantColor() async {
    try {
      final colorIndex = await _consultantService.getCurrentConsultantColor();
      if (mounted) {
        setState(() {
          _selectedColorIndex = colorIndex;
        });
      }
    } catch (e) {
      debugPrint('❌ SETTINGS: Error loading consultant color: $e');
    }
  }

  /// Salveaza culoarea selectata de consultant
  Future<void> _saveConsultantColor(int colorIndex) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _consultantService.setCurrentConsultantColor(colorIndex);
      if (success && mounted) {
        setState(() {
          _selectedColorIndex = colorIndex;
        });

        // Arata mesaj de succes
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Culoare salvata cu succes!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Arata mesaj de eroare
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la salvarea culorii'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ SETTINGS: Error saving consultant color: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eroare la salvarea culorii'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.largeGap),
      decoration: BoxDecoration(
        gradient: AppTheme.areaColor,
        borderRadius: BorderRadius.circular(16),
      ),
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

        // Sectiunea pentru selectarea culorilor consultantului
        _buildColorSelectionSection(),

        const SizedBox(height: AppTheme.mediumGap),

        // Alte setari viitoare
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
                  'Mai multe setari in dezvoltare',
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

  /// Construieste sectiunea pentru selectarea culorilor consultantului
  Widget _buildColorSelectionSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.mediumGap),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor2,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: AppTheme.standardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titlu sectiune
          Text(
            'Culoarea consultantului',
            style: TextStyle(
              fontSize: AppTheme.fontSizeMedium,
              fontWeight: FontWeight.w600,
              color: AppTheme.elementColor2,
            ),
          ),
          const SizedBox(height: AppTheme.smallGap),

          // Descriere
          Text(
            'Alege culoarea care te reprezinta in calendar si in aplicatie. Aceasta culoare va fi folosita pentru sloturile tale rezervate.',
            style: TextStyle(
              fontSize: AppTheme.fontSizeSmall,
              color: AppTheme.elementColor1,
            ),
          ),
          const SizedBox(height: AppTheme.mediumGap),

          // Grid cu cele 10 culori
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: AppTheme.smallGap,
              mainAxisSpacing: AppTheme.smallGap,
              childAspectRatio: 1.0,
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              final colorIndex = index + 1;
              final isSelected = _selectedColorIndex == colorIndex;
              final color = AppTheme.getConsultantColor(colorIndex);

              return GestureDetector(
                onTap: _isLoading ? null : () => _saveConsultantColor(colorIndex),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ] : null,
                  ),
                  child: Stack(
                    children: [
                      if (isSelected)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      if (_isLoading && isSelected)
                        Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: AppTheme.smallGap),

          // Informatie despre culoarea selectata
          if (_selectedColorIndex != null)
            Container(
              padding: const EdgeInsets.all(AppTheme.smallGap),
              decoration: BoxDecoration(
                color: AppTheme.getConsultantColor(_selectedColorIndex!).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                border: Border.all(
                  color: AppTheme.getConsultantStrokeColor(_selectedColorIndex!),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.getConsultantColor(_selectedColorIndex!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: AppTheme.smallGap),
                  Text(
                    'Culoarea $_selectedColorIndex selectata',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeSmall,
                      color: AppTheme.elementColor2,
                      fontWeight: FontWeight.w500,
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
