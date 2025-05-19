import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:broker_app/frontend/common/appTheme.dart';

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

  /// Construiește antetul popup-ului
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
      child: SizedBox(
        height: 24,
        child: Text(
          "Detalii cont",
          style: GoogleFonts.outfit(
            fontSize: AppTheme.fontSizeLarge, // 19px
            fontWeight: FontWeight.w600, // large
            color: AppTheme.elementColor1,
          ),
        ),
      ),
    );
  }

  /// Construiește formularul cu detaliile consultantului
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

  /// Construiește un câmp de detalii (titlu și valoare)
  Widget _buildDetailField({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: AppTheme.fontSizeMedium, // 17px
            fontWeight: FontWeight.w600, // large
            color: AppTheme.elementColor2, // #886699
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
            style: GoogleFonts.outfit(
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

  /// Construiește butonul de deconectare
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextButton(
        onPressed: () => _signOut(context),
        style: TextButton.styleFrom(
          backgroundColor: AppTheme.containerColor1, // #CFC4D4
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
          style: GoogleFonts.outfit(
            fontSize: AppTheme.fontSizeMedium, // 17px
            fontWeight: FontWeight.w500, // medium
            color: AppTheme.elementColor2, // #886699
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
} 