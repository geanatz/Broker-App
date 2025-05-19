import 'package:flutter/material.dart';
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/old/widgets/common/panel_container.dart';
import 'package:broker_app/backend/services/authService.dart';

/// Area pentru setări care va fi afișată în cadrul ecranului principal.
/// Această componentă înlocuiește vechiul SettingsScreen păstrând funcționalitatea
/// dar fiind adaptată la noua structură a aplicației.
class SettingsArea extends StatefulWidget {
  const SettingsArea({Key? key}) : super(key: key);

  @override
  State<SettingsArea> createState() => _SettingsAreaState();
}

class _SettingsAreaState extends State<SettingsArea> {
  final TextEditingController _consultantNameController = TextEditingController();
  final AuthService _authService = AuthService();
  String? _resultMessage;
  bool _isSuccess = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _consultantNameController.dispose();
    super.dispose();
  }

  Future<void> _deleteConsultant() async {
    final consultantName = _consultantNameController.text.trim();
    if (consultantName.isEmpty) {
      setState(() {
        _resultMessage = 'Introduceți numele consultantului';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _resultMessage = null;
    });

    try {
      final result = await _authService.deleteConsultantByName(consultantName);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _resultMessage = result['message'] as String;
          _isSuccess = result['success'] as bool;
          if (_isSuccess) {
            _consultantNameController.clear();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _resultMessage = 'Eroare la ștergerea consultantului: $e';
          _isSuccess = false;
        });
      }
    }
  }

  /// Schimbă tema între Light și Dark
  void _toggleThemeMode() {
    setState(() {
      AppTheme.toggleThemeMode();
    });
  }

  /// Schimbă culoarea temei
  void _changeThemeColor(AppThemeColor color) {
    setState(() {
      AppTheme.setThemeColor(color);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PanelContainer(
      isExpanded: false,
      child: _buildSettingsContent(),
    );
  }

  /// Construiește conținutul setărilor
  Widget _buildSettingsContent() {
    // Folosim stilurile din noul AppTheme
    final TextStyle headerStyle = AppTheme.headerTitleStyle;
    final TextStyle secondaryStyle = AppTheme.secondaryTitleStyle;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.largeGap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Setări aplicație',
              style: headerStyle.copyWith(fontSize: 24),
            ),
            const SizedBox(height: AppTheme.largeGap),
            
            // Secțiunea setări temă
            const Divider(),
            const SizedBox(height: AppTheme.mediumGap),
            Text(
              'Personalizare temă',
              style: headerStyle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: AppTheme.mediumGap),
            
            // Panoul pentru schimbarea temei (Light/Dark)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.mediumGap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mod temă',
                      style: headerStyle.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: AppTheme.smallGap),
                    Text(
                      'Alegeți între modul light și dark pentru interfața aplicației.',
                      style: secondaryStyle,
                    ),
                    const SizedBox(height: AppTheme.mediumGap),
                    
                    // Switch pentru schimbarea între Light/Dark
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppTheme.currentThemeMode == AppThemeMode.light 
                            ? 'Mod Light' 
                            : 'Mod Dark',
                          style: secondaryStyle,
                        ),
                        Switch(
                          value: AppTheme.currentThemeMode == AppThemeMode.dark,
                          onChanged: (value) {
                            _toggleThemeMode();
                          },
                          activeColor: AppTheme.elementColor2,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.mediumGap),
            
            // Panoul pentru schimbarea culorii temei
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.mediumGap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Culoare temă',
                      style: headerStyle.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: AppTheme.smallGap),
                    Text(
                      'Alegeți o culoare pentru tema aplicației.',
                      style: secondaryStyle,
                    ),
                    const SizedBox(height: AppTheme.mediumGap),
                    
                    // Grid cu opțiuni de culori
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppTheme.smallGap,
                      crossAxisSpacing: AppTheme.smallGap,
                      children: [
                        _buildColorOption(AppThemeColor.red, 'Roșu'),
                        _buildColorOption(AppThemeColor.yellow, 'Galben'),
                        _buildColorOption(AppThemeColor.green, 'Verde'),
                        _buildColorOption(AppThemeColor.cyan, 'Cyan'),
                        _buildColorOption(AppThemeColor.blue, 'Albastru'),
                        _buildColorOption(AppThemeColor.pink, 'Roz'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.largeGap),
            
            // Secțiunea pentru ștergerea consultanților
            const Divider(),
            const SizedBox(height: AppTheme.mediumGap),
            Text(
              'Administrare consultanți',
              style: headerStyle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: AppTheme.mediumGap),
            
            // Panoul pentru ștergerea unui consultant
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.mediumGap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ștergere consultant',
                      style: headerStyle.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: AppTheme.smallGap),
                    Text(
                      'Utilizați această funcție pentru a șterge un consultant și contul său asociat.',
                      style: secondaryStyle,
                    ),
                    const SizedBox(height: AppTheme.mediumGap),
                    
                    // Câmpul de text pentru numele consultantului
                    TextField(
                      controller: _consultantNameController,
                      decoration: InputDecoration(
                        labelText: 'Nume consultant',
                        hintText: 'Introduceți numele consultantului',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: AppTheme.mediumGap),
                    
                    // Butonul de ștergere
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _deleteConsultant,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.elementColor2,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Șterge consultant',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    
                    // Mesajul rezultat
                    if (_resultMessage != null) ...[
                      const SizedBox(height: AppTheme.mediumGap),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppTheme.smallGap),
                        decoration: BoxDecoration(
                          color: _isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                          border: Border.all(
                            color: _isSuccess ? Colors.green.shade300 : Colors.red.shade300,
                          ),
                        ),
                        child: Text(
                          _resultMessage!,
                          style: TextStyle(
                            color: _isSuccess ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Construiește un buton pentru selecția culorii temei
  Widget _buildColorOption(AppThemeColor color, String label) {
    // Verificăm dacă culoarea curentă este aceeași cu cea selectată
    final bool isSelected = AppTheme.currentThemeColor == color;
    
    // Determinăm culorile pentru opțiunea de culoare
    Color mainColor;
    switch (color) {
      case AppThemeColor.red:
        mainColor = const Color(0xFF996666);
        break;
      case AppThemeColor.yellow:
        mainColor = const Color(0xFF999966);
        break;
      case AppThemeColor.green:
        mainColor = const Color(0xFF669966);
        break;
      case AppThemeColor.cyan:
        mainColor = const Color(0xFF669999);
        break;
      case AppThemeColor.blue:
        mainColor = const Color(0xFF666699);
        break;
      case AppThemeColor.pink:
        mainColor = const Color(0xFF996699);
        break;
    }
    
    return GestureDetector(
      onTap: () => _changeThemeColor(color),
      child: Container(
        decoration: BoxDecoration(
          color: mainColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          border: Border.all(
            color: isSelected ? mainColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: mainColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: mainColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isSelected 
                ? const Icon(Icons.check, color: Colors.white)
                : null,
            ),
            const SizedBox(height: AppTheme.smallGap),
            Text(
              label,
              style: TextStyle(
                fontSize: AppTheme.fontSizeSmall,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: mainColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
