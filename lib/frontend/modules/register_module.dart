import 'package:broker_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:broker_app/frontend/modules/login_module.dart';

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
  final List<String> _teamOptions = ['Echipa 1', 'Echipa 2', 'Echipa 3'];
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _registerError;

  // Adaugare stari pentru validare vizuala
  bool _isNameInvalid = false;
  bool _isPasswordInvalid = false;
  bool _isConfirmPasswordInvalid = false;
  bool _isTeamInvalid = false;

  @override
  void initState() {
    super.initState();
    
    // Asculta schimbarile din AppTheme pentru actualizari automate ale UI-ului
    AppTheme().addListener(_onAppThemeChanged);
  }

  void _attemptRegister() {
    // Resetam starile de validare
    setState(() {
      _isNameInvalid = false;
      _isPasswordInvalid = false;
      _isConfirmPasswordInvalid = false;
      _isTeamInvalid = false;
      _registerError = null;
    });

    // Validam manual
    bool isValid = true;
    
    // Validare nume
    if (_nameController.text.isEmpty) {
      setState(() {
        _isNameInvalid = true;
        isValid = false;
      });
    }
    
    // Validare parola
    if (_passwordController.text.isEmpty) {
      setState(() {
        _isPasswordInvalid = true;
        isValid = false;
      });
    } else if (_passwordController.text.length < 6) {
      setState(() {
        _isPasswordInvalid = true;
        isValid = false;
      });
    }
    
    // Validare confirmare parola
    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _isConfirmPasswordInvalid = true;
        isValid = false;
      });
    } else if (_confirmPasswordController.text != _passwordController.text) {
      setState(() {
        _isConfirmPasswordInvalid = true;
        isValid = false;
      });
    }
    
    // Validare echipa
    if (_selectedTeam == null) {
      setState(() {
        _isTeamInvalid = true;
        isValid = false;
      });
    }
    
    // Daca totul e valid, trimitem datele
    if (isValid) {
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
    AppTheme().removeListener(_onAppThemeChanged);
    super.dispose();
  }

  /// Callback pentru schimbarile din AppTheme
  void _onAppThemeChanged() {
    if (mounted) {
      debugPrint('🎨 REGISTER_POPUP: AppTheme changed, updating UI');
      setState(() {
        // Actualizeaza UI-ul cand se schimba AppTheme
      });
    }
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
        padding: const EdgeInsets.all(AppTheme.smallGap),
        decoration: AppTheme.popupDecoration.copyWith(
          color: AppTheme.popupBackground,
          boxShadow: [AppTheme.widgetShadow],
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                padding: const EdgeInsets.only(top: AppTheme.tinyGap),
                child: Text(
                  _registerError!,
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
                    "Bun venit in echipa!",
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
                    "Hai sa te bagam in sistem.",
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
              'assets/logoIcon.svg',
              colorFilter: ColorFilter.mode(AppTheme.elementColor2, BlendMode.srcIn),
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
        color: AppTheme.containerColor1,
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
              isInvalid: _isNameInvalid,
              onChanged: (value) {
                if (_isNameInvalid && value.isNotEmpty) {
                  setState(() {
                    _isNameInvalid = false;
                  });
                }
              },
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
                if (value.length < 6) return 'Parola trebuie sa aiba minim 6 caractere';
                return null;
              },
              isInvalid: _isPasswordInvalid,
            ),
            SizedBox(height: AppTheme.smallGap),
            _buildPasswordField(
              controller: _confirmPasswordController,
              title: "Repeta parola",
              hintText: "Introdu parola din nou",
              obscureText: _obscureConfirmPassword,
              onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Confirma parola';
                if (value != _passwordController.text) return 'Parolele nu se potrivesc';
                return null;
              },
              isInvalid: _isConfirmPasswordInvalid,
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
            color: AppTheme.containerColor2,
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
        if (title == "Creaza parola" && _isPasswordInvalid && value.length >= 6) {
          setState(() {
            _isPasswordInvalid = false;
          });
        } else if (title == "Repeta parola" && _isConfirmPasswordInvalid && value == _passwordController.text) {
          setState(() {
            _isConfirmPasswordInvalid = false;
          });
        }
      },
      suffixIcon: Padding(
        padding: const EdgeInsets.only(right: AppTheme.smallGap),
        child: IconButton(
          icon: SvgPicture.asset(
            obscureText ? 'assets/showIcon.svg' : 'assets/hideIcon.svg',
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
                color: AppTheme.elementColor2,
              ),
            ),
          )
        ),
        Container(
          height: 48, 
          decoration: BoxDecoration(
            color: AppTheme.containerColor2, 
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            border: _isTeamInvalid 
                ? Border.all(color: AppTheme.elementColor2, width: 2.0)
                : null,
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedTeam,
            items: _teamOptions.map((team) {
                    return DropdownMenuItem(
                      value: team,
                      child: Text(team, style: AppTheme.smallTextStyle.copyWith(color: AppTheme.elementColor3, fontSize: AppTheme.fontSizeMedium, fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTeam = value;
                if (value != null) {
                  _isTeamInvalid = false;
                }
              });
            },
            hint: Text(
                    "Selecteaza echipa",
                    style: AppTheme.smallTextStyle.copyWith(color: AppTheme.elementColor3, fontSize: AppTheme.fontSizeMedium, fontWeight: FontWeight.w500)
                  ),
            isExpanded: true,
            icon: SvgPicture.asset(
              'assets/expandIcon.svg',
              width: AppTheme.iconSizeMedium, 
              height: AppTheme.iconSizeMedium,
              colorFilter: ColorFilter.mode(AppTheme.elementColor3, BlendMode.srcIn),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none, 
              contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.mediumGap, vertical: 15.0),
            ),
            style: AppTheme.smallTextStyle.copyWith(color: AppTheme.elementColor3, fontSize: AppTheme.fontSizeMedium, fontWeight: FontWeight.w600),
            dropdownColor: AppTheme.containerColor2,
            validator: null, // Eliminam validatorul standard
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

  Widget _buildRegisterButton() {
    return AuthPopupButton(
      onPressed: _attemptRegister,
      text: "Inregistrare",
    );
  }
}
