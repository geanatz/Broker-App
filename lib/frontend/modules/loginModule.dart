import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import pentru SVG
import 'package:broker_app/frontend/common/appTheme.dart'; // Ajustează calea dacă e necesar
import 'package:broker_app/backend/services/authService.dart'; // Pentru getConsultantNames

// Custom InkWell Button for consistent styling and hover effects
class AuthPopupButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const AuthPopupButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  State<AuthPopupButton> createState() => _AuthPopupButtonState();
}

class _AuthPopupButtonState extends State<AuthPopupButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: _isHovering ? AppTheme.containerColor2 : AppTheme.containerColor1, // Change color on hover
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: AppTheme.primaryTitleStyle.copyWith(
              fontSize: AppTheme.fontSizeMedium, // 17px
              fontWeight: FontWeight.w500, // Figma: medium weight (500)
              color: _isHovering ? AppTheme.elementColor3 : AppTheme.elementColor2, // Change text color on hover
            ),
          ),
        ),
      ),
    );
  }
}

class LoginPopup extends StatefulWidget {
  final Function(String consultantName, String password) onLoginAttempt;
  final VoidCallback onGoToRegister;
  final VoidCallback onForgotPassword; // Pentru link-ul/iconița de "am uitat parola"

  const LoginPopup({
    super.key,
    required this.onLoginAttempt,
    required this.onGoToRegister,
    required this.onForgotPassword,
  });

  @override
  State<LoginPopup> createState() => _LoginPopupState();
}

class _LoginPopupState extends State<LoginPopup> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedConsultant;
  final _passwordController = TextEditingController();
  List<String> _consultantNames = [];
  bool _isLoadingConsultants = true;
  String? _loginError;
  
  // Adăugare stări pentru validare
  bool _isConsultantInvalid = false;
  bool _isPasswordInvalid = false;

  // Serviciul de autentificare
  // Ar putea fi injectat sau accesat printr-un provider dacă preferi o arhitectură mai avansată
  // Pentru simplitate acum, îl instanțiem direct sau îl primim
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchConsultantNames();
  }

  Future<void> _fetchConsultantNames() async {
    try {
      final names = await _authService.getConsultantNames();
      if (mounted) {
        setState(() {
          _consultantNames = names;
          _isLoadingConsultants = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // _loginError = "Eroare la încărcarea consultanților: $e"; // Nu afișăm eroare de la fetch aici
          _isLoadingConsultants = false;
        });
      }
    }
  }

  void _attemptLogin() {
    // Resetăm stările de validare
    setState(() {
      _isConsultantInvalid = false;
      _isPasswordInvalid = false;
      _loginError = null;
    });

    // Validăm manual în loc să folosim formKey.currentState!.validate()
    bool isValid = true;
    
    if (_selectedConsultant == null) {
      setState(() {
        _isConsultantInvalid = true;
        isValid = false;
      });
    }
    
    if (_passwordController.text.isEmpty) {
      setState(() {
        _isPasswordInvalid = true;
        isValid = false;
      });
    }
    
    if (isValid) {
      widget.onLoginAttempt(_selectedConsultant!, _passwordController.text);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dimensiunile din Figma
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
          color: AppTheme.popupBackground,
          boxShadow: [AppTheme.widgetShadow],
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ensure column takes minimum space needed
          children: [
            _buildHeader(),
            SizedBox(height: AppTheme.smallGap), // Gap între elemente: small (8px)
            _buildLoginForm(),
            SizedBox(height: AppTheme.smallGap),
            _buildGoToRegisterLink(),
            SizedBox(height: AppTheme.smallGap),
            _buildLoginButton(), // Use new button widget
            if (_loginError != null)
              Padding(
                padding: const EdgeInsets.only(top: AppTheme.tinyGap),
                child: Text(
                  _loginError!,
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
      padding: const EdgeInsets.fromLTRB(AppTheme.mediumGap, 0, AppTheme.smallGap, 0), // 8px horizontal padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Wrap Title&Description in Expanded to push logo
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container for Title Text (ensure consistent height/alignment)
                SizedBox(
                  height: 24, // Figma height
                  child: Text(
                    "E timpul sa facem cifre!",
                    style: AppTheme.primaryTitleStyle.copyWith(
                      fontSize: AppTheme.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.elementColor2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Container for Description Text (ensure consistent height/alignment)
                SizedBox(
                  height: 24, // Figma height
                   child: Text(
                    "Clientii asteapta...",
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
          // Logo container - Ensure fixed 48x48 size
          SizedBox(
            width: 48,
            height: 48,
            child: SvgPicture.asset(
              'assets/logoIcon.svg',
              // Ensure the color is applied correctly if needed
              colorFilter: ColorFilter.mode(AppTheme.elementColor2, BlendMode.srcIn),
              // Fit might not be needed if SVG viewport is correct
              // fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
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
            _buildConsultantDropdown(),
            SizedBox(height: AppTheme.smallGap),
            _buildPasswordField(),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultantDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
          child: Container(
             height: 24, // Figma: Titlu Câmp height
             alignment: Alignment.centerLeft,
            child: Text(
              "Consultant",
              style: AppTheme.primaryTitleStyle.copyWith(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppTheme.elementColor2,
              ),
            ),
          )
        ),
        Container(
          height: 48, // Figma: Dropdown height
          decoration: BoxDecoration(
            color: AppTheme.containerColor2, 
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            border: _isConsultantInvalid 
                ? Border.all(color: AppTheme.elementColor2, width: 2.0)
                : null,
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedConsultant,
            items: _isLoadingConsultants 
                ? [] 
                : _consultantNames.map((name) {
                    return DropdownMenuItem(
                      value: name,
                      child: Text(name, style: AppTheme.smallTextStyle.copyWith(color: AppTheme.elementColor3, fontSize: AppTheme.fontSizeMedium, fontWeight: FontWeight.w600)), 
                    );
                  }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedConsultant = value;
                if (value != null) {
                  _isConsultantInvalid = false;
                }
              });
            },
            hint: _isLoadingConsultants 
                ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color:AppTheme.elementColor3)) 
                : Text(
                    "Selecteaza consultant", 
                    style: AppTheme.smallTextStyle.copyWith(color: AppTheme.elementColor3, fontSize: AppTheme.fontSizeMedium, fontWeight: FontWeight.w500)
                  ),
            isExpanded: true,
            icon: SvgPicture.asset(
              'assets/expandIcon.svg',
              width: AppTheme.iconSizeMedium, 
              height: AppTheme.iconSizeMedium,
              colorFilter: ColorFilter.mode(AppTheme.elementColor3, BlendMode.srcIn),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap, vertical: 15.0),
            ),
            style: AppTheme.smallTextStyle.copyWith(color: AppTheme.elementColor3, fontSize: AppTheme.fontSizeMedium, fontWeight: FontWeight.w600),
            dropdownColor: AppTheme.containerColor2,
            validator: null, // Eliminăm validatorul standard
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Labelul pentru câmpul de parolă (rămâne la fel) ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
          child: Container(
            height: 24, // Figma: Titlu Câmp height
            alignment: Alignment.centerLeft,
            child: Text(
              "Parola",
              style: AppTheme.primaryTitleStyle.copyWith(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppTheme.elementColor2,
              ),
            ),
          )
        ),
        // --- Câmpul de introducere a parolei (modificat) ---
        Container(
          height: 48, // Figma: Input height - păstrăm înălțimea
          decoration: BoxDecoration(
            color: AppTheme.containerColor2,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            border: _isPasswordInvalid 
                ? Border.all(color: AppTheme.elementColor2, width: 2.0)
                : null,
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: true,
            textAlignVertical: TextAlignVertical.center,
            onFieldSubmitted: (_) => _attemptLogin(), // Add Enter key functionality
            style: AppTheme.smallTextStyle.copyWith(
              color: AppTheme.elementColor3,
              fontSize: AppTheme.fontSizeMedium,
              fontWeight: FontWeight.w500,
            ),
            onChanged: (value) {
              if (_isPasswordInvalid && value.isNotEmpty) {
                setState(() {
                  _isPasswordInvalid = false;
                });
              }
            },
            decoration: InputDecoration(
              hintText: "Introdu parola",
              hintStyle: AppTheme.smallTextStyle.copyWith(
                color: AppTheme.elementColor3,
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap, vertical: 15.0),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: AppTheme.smallGap),
                child: IconButton(
                  tooltip: "Am uitat parola",
                  icon: SvgPicture.asset(
                    'assets/infoIcon.svg',
                    width: AppTheme.iconSizeMedium,
                    height: AppTheme.iconSizeMedium,
                    colorFilter: ColorFilter.mode(
                        AppTheme.elementColor3,
                        BlendMode.srcIn
                    ),
                  ),
                  iconSize: AppTheme.iconSizeMedium,
                  onPressed: widget.onForgotPassword,
                  padding: EdgeInsets.zero,
                ),
              ),
              suffixIconConstraints: const BoxConstraints(
                 minHeight: AppTheme.iconSizeMedium + 16,
                 minWidth: AppTheme.iconSizeMedium + 16,
               ),
            ),
            validator: null, // Eliminăm validatorul standard
          ),
        ),
      ],
    );
  }

  Widget _buildGoToRegisterLink() {
    return Container(
      height: 24, // Figma
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, 
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
          Text(
            "Nu ai cont de consultant?", // Text actualizat conform ultimului MD
            style: AppTheme.smallTextStyle.copyWith(
              color: AppTheme.elementColor2, 
              fontWeight: FontWeight.w500,
              fontSize: AppTheme.fontSizeMedium,
            ),
          ),
          TextButton(
            onPressed: widget.onGoToRegister,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.tinyGap), 
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.center, // Aliniere text buton
            ),
            child: Text(
              "Creaza unul!", // Text actualizat conform ultimului MD
              style: AppTheme.smallTextStyle.copyWith(
                color: AppTheme.elementColor2, 
                fontWeight: FontWeight.w600, 
                fontSize: AppTheme.fontSizeMedium, // 17px
                decoration: TextDecoration.underline,
                decorationColor: AppTheme.elementColor2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    // Use the new custom button
    return AuthPopupButton(
      onPressed: _attemptLogin,
      text: "Conectare",
    );
  }
}
