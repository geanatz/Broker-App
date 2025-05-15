import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:broker_app/old/theme/app_theme.dart';
import 'package:broker_app/old/auth/loginPopup.dart';

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
  
  // Adăugare stări pentru validare
  bool _isNewPasswordInvalid = false;
  bool _isConfirmPasswordInvalid = false;

  void _attemptResetPassword() {
    // Resetăm stările de validare
    setState(() {
      _isNewPasswordInvalid = false;
      _isConfirmPasswordInvalid = false;
      _resetError = null;
    });
    
    // Validare manuală
    bool isValid = true;
    
    // Validare parolă nouă
    if (_newPasswordController.text.isEmpty) {
      setState(() {
        _isNewPasswordInvalid = true;
        isValid = false;
      });
    } else if (_newPasswordController.text.length < 6) {
      setState(() {
        _isNewPasswordInvalid = true;
        isValid = false;
      });
    }
    
    // Validare confirmare parolă
    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _isConfirmPasswordInvalid = true;
        isValid = false;
      });
    } else if (_confirmPasswordController.text != _newPasswordController.text) {
      setState(() {
        _isConfirmPasswordInvalid = true;
        isValid = false;
      });
    }
    
    // Dacă totul e valid, trimitem datele
    if (isValid) {
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
        padding: const EdgeInsets.all(AppTheme.smallGap),
        decoration: AppTheme.popupDecoration.copyWith(
          color: AppTheme.widgetBackground.withOpacity(0.5),
          boxShadow: [AppTheme.widgetShadow],
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                padding: const EdgeInsets.only(top: AppTheme.tinyGap),
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
      padding: const EdgeInsets.fromLTRB(AppTheme.mediumGap, 0, AppTheme.smallGap, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  child: Text(
                    "Gandeste o parola noua",
                    style: AppTheme.primaryTitleStyle.copyWith(
                      fontSize: AppTheme.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.fontMediumPurple,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: 21,
                  child: Text(
                    "Una calumea, nu ziua de nastere...",
                    style: AppTheme.subHeaderStyle.copyWith(
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF927B9D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: SvgPicture.asset(
              'assets/Logo.svg',
              colorFilter: const ColorFilter.mode(AppTheme.fontMediumPurple, BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetForm() {
    return Container(
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
              },
              isInvalid: _isNewPasswordInvalid,
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
              },
              isInvalid: _isConfirmPasswordInvalid,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String title,
    required String hintText,
    required String? Function(String?) validator,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    bool isInvalid = false,
    Function(String)? onChanged,
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
            border: isInvalid 
                ? Border.all(color: AppTheme.fontMediumRed, width: 2.0)
                : null,
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: AppTheme.smallTextStyle.copyWith(color: AppTheme.fontDarkPurple, fontSize: AppTheme.fontSizeMedium, fontWeight: FontWeight.w500),
            textAlignVertical: TextAlignVertical.center,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTheme.smallTextStyle.copyWith(color: AppTheme.fontDarkPurple, fontSize: AppTheme.fontSizeMedium, fontWeight: FontWeight.w500),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap, vertical: 15.0),
              suffixIcon: suffixIcon,
            ),
            validator: null, // Eliminăm validatorul standard
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
    bool isInvalid = false,
  }) {
    return _buildTextField(
      controller: controller,
      title: title,
      hintText: hintText,
      obscureText: obscureText,
      validator: validator,
      isInvalid: isInvalid,
      onChanged: (value) {
        if (title == "Parola noua" && _isNewPasswordInvalid && value.length >= 6) {
          setState(() {
            _isNewPasswordInvalid = false;
          });
        } else if (title == "Repeta parola" && _isConfirmPasswordInvalid && value == _newPasswordController.text) {
          setState(() {
            _isConfirmPasswordInvalid = false;
          });
        }
      },
      suffixIcon: Padding(
        padding: const EdgeInsets.only(right: AppTheme.smallGap),
        child: IconButton(
          icon: SvgPicture.asset(
            obscureText ? 'assets/ShowIcon.svg' : 'assets/HideIcon.svg',
            width: AppTheme.iconSizeMedium, 
            height: AppTheme.iconSizeMedium,
            colorFilter: const ColorFilter.mode(AppTheme.fontDarkPurple, BlendMode.srcIn),
          ),
          iconSize: AppTheme.iconSizeMedium,
          onPressed: onToggleObscure,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildGoToLoginLink() {
    return Container(
      height: 24,
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
    return AuthPopupButton(
      onPressed: _attemptResetPassword,
      text: "Reseteaza parola",
    );
  }
}
