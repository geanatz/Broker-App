import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';

class ResetPasswordPopup extends StatefulWidget {
  final Function(String newPassword, String confirmPassword) onResetPasswordAttempt;
  final VoidCallback onGoToLogin;

  const ResetPasswordPopup({
    super.key,
    required this.onResetPasswordAttempt,
    required this.onGoToLogin,
  });

  @override
  State<ResetPasswordPopup> createState() => _ResetPasswordPopupState();
}

class _ResetPasswordPopupState extends State<ResetPasswordPopup> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _resetError;

  void _attemptResetPassword() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _resetError = null;
      });
      widget.onResetPasswordAttempt(
        _newPasswordController.text,
        _confirmPasswordController.text,
      );
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double popupWidth = 360.0;
    const double popupHeight = 328.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: popupWidth,
        height: popupHeight,
        padding: const EdgeInsets.all(AppTheme.tinyGap),
        decoration: AppTheme.popupDecoration.copyWith(
          color: AppTheme.widgetBackground.withOpacity(0.5),
          boxShadow: [AppTheme.widgetShadow],
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: AppTheme.smallGap),
            _buildResetForm(),
            SizedBox(height: AppTheme.smallGap),
            _buildGoToLoginLink(),
            SizedBox(height: AppTheme.smallGap),
            _buildResetButton(),
            if (_resetError != null)
              Padding(
                padding: const EdgeInsets.only(top: AppTheme.smallGap),
                child: Text(
                  _resetError!,
                  style: AppTheme.tinyTextStyle.copyWith(color: AppTheme.fontMediumRed),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
             width: 273, // Figma
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 24, // Figma
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Gandeste o parola noua",
                    style: AppTheme.primaryTitleStyle.copyWith(
                      fontSize: AppTheme.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.fontMediumPurple,
                    ),
                     overflow: TextOverflow.ellipsis,
                     textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  height: 21, // Figma
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Una calumea, nu ziua de nastere...",
                    style: AppTheme.subHeaderStyle.copyWith(
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF927B9D),
                      height: 21/17,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48, height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 13),
            child: SvgPicture.asset(
              'assets/Logo.svg',
               width: 26.58,
              height: 22.4,
              colorFilter: const ColorFilter.mode(AppTheme.fontMediumPurple, BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetForm() {
    return Container(
      // height: 168, // Determinat de conținut
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLightPurple,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildPasswordField(
              controller: _newPasswordController,
              title: "Parola noua",
              hintText: "Introdu parola",
              obscureText: _obscureNewPassword,
              onToggleObscure: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Introdu noua parolă';
                if (value.length < 6) return 'Parola trebuie să aibă minim 6 caractere';
                return null;
              }
            ),
            SizedBox(height: AppTheme.smallGap),
            _buildPasswordField(
              controller: _confirmPasswordController,
              title: "Repeta parola",
              hintText: "Introdu parola iar",
              obscureText: _obscureConfirmPassword,
              onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Confirmă noua parolă';
                if (value != _newPasswordController.text) return 'Parolele nu se potrivesc';
                return null;
              }
            ),
          ],
        ),
      ),
    );
  }

  // Refolosim metodele helper pentru consistență
  Widget _buildTextField({
    required TextEditingController controller,
    required String title,
    required String hintText,
    required String? Function(String?) validator,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppTheme.smallGap, right: AppTheme.smallGap, bottom: 0),
          child: Container(
            height: 24,
            alignment: Alignment.centerLeft,
            child: Text(title, style: AppTheme.primaryTitleStyle.copyWith(fontSize: AppTheme.fontSizeMedium, fontWeight: FontWeight.w600, color: AppTheme.fontMediumPurple)),
          )
        ),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.backgroundDarkPurple,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: AppTheme.smallTextStyle.copyWith(color: const Color(0xFF7C568F), fontSize: AppTheme.fontSizeMedium, height: 21/17),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTheme.smallTextStyle.copyWith(color: const Color(0xFF7C568F), fontSize: AppTheme.fontSizeMedium, height: 21/17),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
              suffixIcon: suffixIcon,
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String title,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleObscure,
    required String? Function(String?) validator,
  }) {
    return _buildTextField(
      controller: controller,
      title: title,
      hintText: hintText,
      obscureText: obscureText,
      validator: validator,
      suffixIcon: IconButton(
        icon: SvgPicture.asset(
           obscureText ? 'assets/ShowIcon.svg' : 'assets/HideIcon.svg',
          width: AppTheme.iconSizeMedium, 
          height: AppTheme.iconSizeMedium,
          colorFilter: const ColorFilter.mode(Color(0xFF7C568F), BlendMode.srcIn),
        ),
        iconSize: AppTheme.iconSizeMedium,
        onPressed: onToggleObscure,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildGoToLoginLink() {
    return Container(
      height: 24, // Figma
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Ti-a revenit memoria?",
            style: AppTheme.smallTextStyle.copyWith(color: AppTheme.fontMediumPurple, fontWeight: FontWeight.w500, fontSize: AppTheme.fontSizeMedium),
          ),
          TextButton(
            onPressed: widget.onGoToLogin,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.tinyGap),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.center,
            ),
            child: Text(
              "Conecteaza-te!",
              style: AppTheme.smallTextStyle.copyWith(
                color: AppTheme.fontMediumPurple, 
                fontWeight: FontWeight.w600,
                fontSize: AppTheme.fontSizeMedium,
                decoration: TextDecoration.underline,
                decorationColor: AppTheme.fontMediumPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _attemptResetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.backgroundLightPurple,
          foregroundColor: AppTheme.fontMediumPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap),
        ),
        child: Text(
          "Schimba parola", // Text actualizat conform Figma/Markdown
          style: AppTheme.primaryTitleStyle.copyWith(fontSize: AppTheme.fontSizeMedium, fontWeight: FontWeight.w500, color: AppTheme.fontMediumPurple), // Figma: medium weight (500)
        ),
      ),
    );
  }
}
