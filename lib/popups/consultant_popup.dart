import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

/// Popup pentru afișarea detaliilor consultantului și opțiunii de deconectare
class ConsultantPopup extends StatelessWidget {
  /// Numele consultantului
  final String consultantName;
  
  /// Numele echipei
  final String teamName;

  const ConsultantPopup({
    Key? key,
    required this.consultantName,
    required this.teamName,
  }) : super(key: key);

  /// Funcție pentru deconectarea utilizatorului
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pop(); // Închide popup-ul
      // Nu este nevoie de navigare specifică, AuthWrapper din main.dart va redirectiona automat
    } catch (e) {
      print("Error signing out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eroare la deconectare: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dimensiuni exacte conform specificațiilor din consultantPopup.md
    const double popupWidth = 320.0;
    const double popupHeight = 272.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: popupWidth,
        height: popupHeight,
        padding: const EdgeInsets.all(AppTheme.smallGap), // 8px padding
        decoration: BoxDecoration(
          color: AppTheme.popupBackground, // #D9D9D9
          boxShadow: [AppTheme.widgetShadow],
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge), // 32px
        ),
        child: Column(
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
    );
  }

  /// Construiește antetul popup-ului
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
      child: SizedBox(
        height: 24,
        child: Text(
          "Detalii cont",
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: AppTheme.fontSizeLarge, // 19px
            fontWeight: FontWeight.w600, // large
            color: const Color(0xFF927B9D), // font_light_purple_variant
          ),
        ),
      ),
    );
  }

  /// Construiește formularul cu detaliile consultantului
  Widget _buildConsultantDetailsForm() {
    return Container(
      height: 168,
      padding: const EdgeInsets.all(AppTheme.smallGap), // 8px padding
      decoration: BoxDecoration(
        color: AppTheme.backgroundLightPurple, // #CFC4D4
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // 24px
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

  /// Construiește un câmp de detalii (titlu și valoare)
  Widget _buildDetailField({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: AppTheme.fontSizeMedium, // 17px
            fontWeight: FontWeight.w600, // large
            color: AppTheme.fontMediumPurple, // #886699
          ),
        ),
        const SizedBox(height: AppTheme.smallGap), // 8px gap
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap), // 16px
          decoration: BoxDecoration(
            color: AppTheme.backgroundDarkPurple, // #C6ACD3
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall), // 16px
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: AppTheme.fontSizeMedium, // 17px
              fontWeight: FontWeight.w500, // medium
              color: const Color(0xFF7C568F), // font_dark_purple_variant
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Construiește butonul de deconectare
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextButton(
        onPressed: () => _signOut(context),
        style: TextButton.styleFrom(
          backgroundColor: AppTheme.backgroundLightPurple, // #CFC4D4
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.mediumGap, // 16px
            vertical: 12, // Conform documentației
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // 24px
          ),
        ),
        child: Text(
          "Deconectare",
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: AppTheme.fontSizeMedium, // 17px
            fontWeight: FontWeight.w500, // medium
            color: AppTheme.fontMediumPurple, // #886699
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
} 