import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';

class RegisterPopup extends StatefulWidget {
  final Function(String consultantName, String password, String confirmPassword, String team) onRegisterAttempt;
  final VoidCallback onGoToLogin;

  const RegisterPopup({
    super.key,
    required this.onRegisterAttempt,
    required this.onGoToLogin,
  });

  @override
  State<RegisterPopup> createState() => _RegisterPopupState();
}

class _RegisterPopupState extends State<RegisterPopup> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedTeam;
  final List<String> _teamOptions = ['Team Alpha', 'Team Beta', 'Team Gamma'];
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _registerError;

  void _attemptRegister() {
    if (_formKey.currentState!.validate()) {
      if (_selectedTeam == null) {
        setState(() {
          _registerError = 'Te rugăm să selectezi o echipă.';
        });
        return;
      }
      setState(() {
        _registerError = null;
      });
      widget.onRegisterAttempt(
        _nameController.text,
        _passwordController.text,
        _confirmPasswordController.text,
        _selectedTeam!,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double popupWidth = 360.0;
    const double popupHeight = 488.0;

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
            _buildRegisterForm(),
            SizedBox(height: AppTheme.smallGap),
            _buildGoToLoginLink(),
            SizedBox(height: AppTheme.smallGap),
            _buildRegisterButton(),
            if (_registerError != null)
              Padding(
                padding: const EdgeInsets.only(top: AppTheme.smallGap),
                child: Text(
                  _registerError!,
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
            width: 213,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 24,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Bun venit in echipa!",
                    style: AppTheme.primaryTitleStyle.copyWith(
                      fontSize: AppTheme.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.fontMediumPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  height: 21,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Hai sa te bagam in sistem.",
                    style: AppTheme.subHeaderStyle.copyWith(
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF927B9D),
                      height: 21/17,
                    ),
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

  Widget _buildRegisterForm() {
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
            _buildTextField(
              controller: _nameController,
              title: "Cum te numesti?",
              hintText: "Introdu numele tau",
              validator: (value) => value == null || value.isEmpty ? 'Introdu numele' : null,
            ),
            SizedBox(height: AppTheme.smallGap),
            _buildPasswordField(
              controller: _passwordController,
              title: "Creaza parola",
              hintText: "Introdu parola",
              obscureText: _obscurePassword,
              onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Introdu parola';
                if (value.length < 6) return 'Parola trebuie să aibă minim 6 caractere';
                return null;
              }
            ),
            SizedBox(height: AppTheme.smallGap),
            _buildPasswordField(
              controller: _confirmPasswordController,
              title: "Repeta parola",
              hintText: "Introdu parola din nou",
              obscureText: _obscureConfirmPassword,
              onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Confirmă parola';
                if (value != _passwordController.text) return 'Parolele nu se potrivesc';
                return null;
              }
            ),
            SizedBox(height: AppTheme.smallGap),
            _buildTeamDropdown(),
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

  Widget _buildTeamDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppTheme.smallGap, right: AppTheme.smallGap, bottom: 0),
          child: Container(
            height: 24,
            alignment: Alignment.centerLeft,
            child: Text(
              "Alege echipa",
              style: AppTheme.primaryTitleStyle.copyWith(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppTheme.fontMediumPurple,
              ),
            ),
          )
        ),
        Container(
          height: 48, 
          decoration: BoxDecoration(
            color: AppTheme.backgroundDarkPurple, 
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedTeam,
            items: _teamOptions.map((team) {
                    return DropdownMenuItem(
                      value: team,
                      child: Text(team, style: AppTheme.smallTextStyle.copyWith(color: const Color(0xFF7C568F), fontSize: AppTheme.fontSizeMedium)), 
                    );
                  }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTeam = value;
              });
            },
            hint: Text(
                    "Selecteaza echipa",
                    style: AppTheme.smallTextStyle.copyWith(color: const Color(0xFF7C568F), fontSize: AppTheme.fontSizeMedium)
                  ),
            isExpanded: true,
            icon: Padding(
              padding: const EdgeInsets.only(right: AppTheme.smallGap),
              child: SvgPicture.asset(
                'assets/DropdownIcon.svg',
                width: AppTheme.iconSizeMedium, 
                height: AppTheme.iconSizeMedium,
                colorFilter: const ColorFilter.mode(Color(0xFF7C568F), BlendMode.srcIn),
              ),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none, 
              contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.smallGap, vertical: (48-21)/2), 
            ),
            style: AppTheme.smallTextStyle.copyWith(color: const Color(0xFF7C568F), fontSize: AppTheme.fontSizeMedium, height: 21/17),
            dropdownColor: AppTheme.backgroundDarkPurple,
            validator: (value) => value == null ? 'Selectează o echipă' : null,
          ),
        ),
      ],
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
            "Ai cont de consultant?",
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

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _attemptRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.backgroundLightPurple,
          foregroundColor: AppTheme.fontMediumPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium)),
          elevation: 0,
           padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap),
        ),
        child: Text(
          "Creaza cont",
          style: AppTheme.primaryTitleStyle.copyWith(fontSize: AppTheme.fontSizeMedium, fontWeight: FontWeight.w500, color: AppTheme.fontMediumPurple),
        ),
      ),
    );
  }
}
