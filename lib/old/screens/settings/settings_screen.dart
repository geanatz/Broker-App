import 'package:flutter/material.dart';
import 'package:broker_app/frontend/common/appTheme.dart';
// import '../../widgets/navigation/sidebar_widget.dart'; // Removed old import
// import '../../widgets/navigation/navigation_widget.dart'; // Removed old import
import 'package:broker_app/old/sidebar/sidebar_service.dart'; // Added service import
// import '../../sidebar/user_widget.dart'; // Remove UserWidget import
// import '../../sidebar/navigation_widget.dart'; // Remove NavigationWidget import
import 'package:broker_app/old/sidebar/sidebar_widget.dart';
import 'package:broker_app/old/widgets/common/panel_container.dart';
import 'package:broker_app/backend/services/authService.dart'; // Import pentru AuthService

/// Ecranul pentru setările aplicației
class SettingsScreen extends StatefulWidget {
  /// Numele consultantului
  final String consultantName;
  
  /// Numele echipei
  final String teamName;
  
  /// Callback pentru schimbarea ecranului
  final Function(NavigationScreen) onScreenChanged;

  const SettingsScreen({
    Key? key,
    required this.consultantName,
    required this.teamName,
    required this.onScreenChanged,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 1200;
    final mainContentHeight = screenSize.height - 48;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.appBackground,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.largeGap),
          child: isSmallScreen
            ? _buildSmallScreenLayout()
            : _buildLargeScreenLayout(mainContentHeight),
        ),
      ),
    );
  }

  /// Construiește layout-ul pentru ecrane mici (< 1200px)
  Widget _buildSmallScreenLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PanelContainer(
            width: double.infinity,
            child: _buildSettingsContent(),
          ),
          const SizedBox(height: AppTheme.largeGap),
          Container(
            width: 224,
            child: SidebarWidgetAdapter(
              consultantName: widget.consultantName,
              teamName: widget.teamName,
              currentScreen: NavigationScreen.settings,
              onScreenChanged: widget.onScreenChanged,
            ),
          ),
        ],
      ),
    );
  }

  /// Construiește layout-ul pentru ecrane mari (>= 1200px)
  Widget _buildLargeScreenLayout(double contentHeight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PanelContainer(
          height: contentHeight,
          isExpanded: true,
          child: _buildSettingsContent(),
        ),
        const SizedBox(width: AppTheme.largeGap),
        SizedBox(
           width: 224,
           height: contentHeight,
           child: SidebarWidgetAdapter(
             consultantName: widget.consultantName,
             teamName: widget.teamName,
             currentScreen: NavigationScreen.settings,
             onScreenChanged: widget.onScreenChanged,
           ),
        ),
      ],
    );
  }

  /// Construiește conținutul setărilor
  Widget _buildSettingsContent() {
    // Assuming AppTheme.headerTitleStyle, secondaryTitleStyle exist
    // If not, define inline styles using AppTheme constants
    final TextStyle headerStyle = TextStyle(
      fontSize: AppTheme.fontSizeLarge,
      fontWeight: FontWeight.bold,
      color: AppTheme.elementColor3
    );
    final TextStyle secondaryStyle = TextStyle(
      fontSize: AppTheme.fontSizeMedium,
      color: AppTheme.elementColor2
    );

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
            
            const SizedBox(height: AppTheme.largeGap),
            // Aici se pot adăuga secțiuni suplimentare pentru alte setări
          ],
        ),
      ),
    );
  }
} 