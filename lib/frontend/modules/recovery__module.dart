import 'package:mat_finance/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mat_finance/frontend/modules/login_module.dart';

class ResetPasswordPopup extends StatefulWidget {
  final Function(String currentPassword, String newPassword, String confirmPassword) onResetPasswordAttempt;
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
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _resetError;
  
  // Adaugare stari pentru validare
  bool _isCurrentPasswordInvalid = false;
  bool _isNewPasswordInvalid = false;
  bool _isConfirmPasswordInvalid = false;

  void _attemptResetPassword() {
    // Resetam starile de validare
    setState(() {
      _isCurrentPasswordInvalid = false;
      _isNewPasswordInvalid = false;
      _isConfirmPasswordInvalid = false;
      _resetError = null;
    });
    
    // Validare manuala
    bool isValid = true;
    
    // Validare parola actuala
    if (_currentPasswordController.text.isEmpty) {
      setState(() {
        _isCurrentPasswordInvalid = true;
        isValid = false;
      });
    }
    
    // Validare parola noua
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
    
    // Validare confirmare parola
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
    
    // Daca totul e valid, trimitem datele
    if (isValid) {
      widget.onResetPasswordAttempt(
        _currentPasswordController.text,
        _newPasswordController.text,
        _confirmPasswordController.text,
      );
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double popupWidth = 360.0;
    const double popupHeight = 408.0; // Increased height for current password field

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: popupWidth,
        height: popupHeight,
        padding: const EdgeInsets.all(AppTheme.smallGap),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor1,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          // Removed shadow as requested
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
                  style: AppTheme.tinyTextStyle.copyWith(color: AppTheme.elementColor2),
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
                      color: AppTheme.elementColor2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: 21,
                  child: Text(
                    "Una calumea, nu ziua de nastere.",
                    style: AppTheme.subHeaderStyle.copyWith(
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.elementColor1,
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
              'assets/logo.svg',
              colorFilter: ColorFilter.mode(AppTheme.elementColor2, BlendMode.srcATop),
              fit: BoxFit.contain,
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
        color: AppTheme.backgroundColor2,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildPasswordField(
              controller: _currentPasswordController,
              title: "Parola actuala",
              hintText: "Introdu parola actuala",
              obscureText: _obscureCurrentPassword,
              onToggleObscure: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Introdu parola actuala';
                return null;
              },
              isInvalid: _isCurrentPasswordInvalid,
            ),
            SizedBox(height: AppTheme.smallGap),
            _buildPasswordField(
              controller: _newPasswordController,
              title: "Parola noua",
              hintText: "Introdu parola noua",
              obscureText: _obscureNewPassword,
              onToggleObscure: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Introdu noua parola';
                if (value.length < 6) return 'Parola trebuie sa aiba minim 6 caractere';
                return null;
              },
              isInvalid: _isNewPasswordInvalid,
            ),
            SizedBox(height: AppTheme.smallGap),
            _buildPasswordField(
              controller: _confirmPasswordController,
              title: "Confirma parola noua",
              hintText: "Introdu parola noua din nou",
              obscureText: _obscureConfirmPassword,
              onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Confirma noua parola';
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
            child: Text(title, style: AppTheme.primaryTitleStyle.copyWith(fontSize: AppTheme.fontSizeMedium, fontWeight: FontWeight.w600, color: AppTheme.elementColor2)),
          )
        ),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor3,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            border: isInvalid 
                ? Border.all(color: AppTheme.elementColor2, width: 2.0)
                : null,
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: AppTheme.smallTextStyle.copyWith(color: AppTheme.elementColor3, fontSize: AppTheme.fontSizeMedium, fontWeight: FontWeight.w500),
            textAlignVertical: TextAlignVertical.center,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTheme.smallTextStyle.copyWith(color: AppTheme.elementColor3, fontSize: AppTheme.fontSizeMedium, fontWeight: FontWeight.w500),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap, vertical: 15.0),
              suffixIcon: suffixIcon,
            ),
            validator: null, // Eliminam validatorul standard
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
            obscureText ? 'assets/view_outlined.svg' : 'assets/hide_outlined.svg',
            width: AppTheme.iconSizeMedium, 
            height: AppTheme.iconSizeMedium,
            colorFilter: ColorFilter.mode(AppTheme.elementColor3, BlendMode.srcIn),
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
            style: AppTheme.smallTextStyle.copyWith(color: AppTheme.elementColor2, fontWeight: FontWeight.w500, fontSize: AppTheme.fontSizeMedium),
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
                color: AppTheme.elementColor2, 
                fontWeight: FontWeight.w600,
                fontSize: AppTheme.fontSizeMedium,
                decoration: TextDecoration.underline,
                decorationColor: AppTheme.elementColor2,
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

