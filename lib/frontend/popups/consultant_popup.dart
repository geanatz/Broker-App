import 'package:broker_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/headers/widget_header1.dart';
import '../components/buttons/flex_buttons1.dart';
import 'dart:async';
import '../../main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Popup pentru afisarea detaliilor consultantului si optiunii de deconectare
class ConsultantPopup extends StatelessWidget {
  /// Numele consultantului
  final String consultantName;
  
  /// Numele echipei
  final String teamName;

  const ConsultantPopup({
    super.key,
    required this.consultantName,
    required this.teamName,
  });


  @override
  Widget build(BuildContext context) {
    // Dimensiuni exacte conform specificatiilor din consultantPopup.md
    const double popupWidth = 320.0;
    const double popupHeight = 272.0; // Ajustat pentru a evita overflow

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: popupWidth,
          height: popupHeight,
          padding: const EdgeInsets.all(AppTheme.smallGap), // 8px padding
          decoration: AppTheme.popupDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: AppTheme.smallGap), // 8px gap
              _buildConsultantDetailsForm(),
              const SizedBox(height: AppTheme.smallGap), // 8px gap
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Construieste antetul popup-ului
  Widget _buildHeader() {
    return WidgetHeader1(
      title: "Detalii cont",
      titleColor: AppTheme.elementColor1,
    );
  }

  /// Construieste formularul cu detaliile consultantului
  Widget _buildConsultantDetailsForm() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.smallGap), // 8px padding
      decoration: BoxDecoration(
        color: AppTheme.containerColor1, // #CFC4D4
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // 24px
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDetailField(
            title: "Consultant",
            value: consultantName,
          ),
          const SizedBox(height: AppTheme.smallGap), // 8px gap
          _buildDetailField(
            title: "Echipa ta",
            value: teamName,
          ),
        ],
      ),
    );
  }

  /// Construieste un camp de detalii (titlu si valoare)
  Widget _buildDetailField({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0), // 8px horizontal padding
          child: Text(
            title,
            style: AppTheme.safeOutfit(
              fontSize: AppTheme.fontSizeMedium, // 17px
              fontWeight: FontWeight.w600, // large
              color: AppTheme.elementColor2, // #886699
            ),
          ),
        ),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap), // 16px
          decoration: BoxDecoration(
            color: AppTheme.containerColor2, // #C6ACD3
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall), // 16px
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: AppTheme.safeOutfit(
              fontSize: AppTheme.fontSizeMedium, // 17px
              fontWeight: FontWeight.w500, // medium
              color: AppTheme.elementColor3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Construieste butonul de deconectare
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FlexButtonSingle(
        onTap: () async {
          debugPrint('🔴 CONSULTANT_POPUP: Logout button tapped');
          
          try {
            // Salvam referinta la navigator INAINTE de pop
            final navigator = Navigator.of(context);
            
            // Close popup first
            navigator.pop();
            
            // Sign out from Firebase
            await FirebaseAuth.instance.signOut();
            debugPrint('🔴 CONSULTANT_POPUP: Firebase signOut completed');
            
            // Abordare directă - forțăm navigația imediată către AuthScreen
            await _forceLogoutNavigation(navigator);
            
          } catch (e) {
            debugPrint('🔴 CONSULTANT_POPUP: Error during logout: $e');
            
            // In caz de eroare, incearca sa închida popup-ul oricum
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        },
        text: "Deconectare",
        iconPath: "assets/returnIcon.svg",
        textStyle: AppTheme.safeOutfit(
          fontSize: AppTheme.fontSizeMedium, // 17px
          fontWeight: FontWeight.w500, // medium
          color: AppTheme.elementColor2, // #886699
        ),
      ),
    );
  }

  /// Forțează navigația către AuthScreen după logout
  Future<void> _forceLogoutNavigation(NavigatorState navigator) async {
    debugPrint('🔴 CONSULTANT_POPUP: Forcing immediate logout navigation');
    
    // Verificam ca signOut-ul a reusit
    final currentUser = FirebaseAuth.instance.currentUser;
    debugPrint('🔴 CONSULTANT_POPUP: Current user after signOut: ${currentUser?.email ?? 'null'}');
    
    if (currentUser != null) {
      // Daca user-ul inca exista, incercam din nou
      debugPrint('🔴 CONSULTANT_POPUP: User still exists, trying signOut again');
      await FirebaseAuth.instance.signOut();
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // Ștergem preferințele de navigație pentru a forța default-urile (dashboard, clients)
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('main_screen_current_area');
      await prefs.remove('main_screen_current_pane');
      debugPrint('🔴 CONSULTANT_POPUP: Navigation preferences cleared - next login will show dashboard');
    } catch (e) {
      debugPrint('🔴 CONSULTANT_POPUP: Error clearing navigation preferences: $e');
    }
    
    // Navigare directa si imediata - eliminam toate rutele si navigam la AuthWrapper
    try {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
        (route) => false,
      );
      debugPrint('🔴 CONSULTANT_POPUP: Immediate navigation to AuthWrapper executed');
    } catch (e) {
      debugPrint('🔴 CONSULTANT_POPUP: Error in immediate navigation: $e');
      
      // Fallback - incearcam sa resetam aplicatia
      try {
        // Restart app prin navigare la root si refresh
        navigator.pushNamedAndRemoveUntil('/', (route) => false);
        debugPrint('🔴 CONSULTANT_POPUP: Fallback navigation to root executed');
      } catch (e2) {
        debugPrint('🔴 CONSULTANT_POPUP: Fallback navigation failed: $e2');
      }
    }
  }
} 

