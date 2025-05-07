import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import pentru SVG
import '../../theme/app_theme.dart'; // Ajustează calea dacă e necesar
import '../auth/authService.dart'; // Pentru getConsultantNames

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
    if (_formKey.currentState!.validate()) {
      if (_selectedConsultant == null) {
        setState(() {
          _loginError = 'Te rugăm să selectezi un consultant.';
        });
        return;
      }
      setState(() {
        _loginError = null; 
      });
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
      insetPadding: EdgeInsets.zero, // Pentru a controla manual poziționarea
      child: Container(
        width: popupWidth,
        height: popupHeight,
        padding: const EdgeInsets.all(AppTheme.tinyGap), // Figma: padding: 8px (tiny)
        decoration: AppTheme.popupDecoration.copyWith(
          color: AppTheme.widgetBackground.withOpacity(0.5), // Figma: background: rgba(255, 255, 255, 0.5)
          boxShadow: [AppTheme.widgetShadow],
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: AppTheme.smallGap), // Gap între elemente: small (8px)
            _buildLoginForm(),
            SizedBox(height: AppTheme.smallGap),
            _buildGoToRegisterLink(),
            SizedBox(height: AppTheme.smallGap),
            _buildLoginButton(),
            if (_loginError != null)
              Padding(
                padding: const EdgeInsets.only(top: AppTheme.smallGap),
                child: Text(
                  _loginError!,
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
            width: 216, // Figma
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 24, // Figma
                  alignment: Alignment.centerLeft, // Figma: text aliniat la stânga în container
                  child: Text(
                    "E timpul sa facem cifre!",
                    style: AppTheme.primaryTitleStyle.copyWith(
                      fontSize: AppTheme.fontSizeLarge, 
                      fontWeight: FontWeight.w600, 
                      color: AppTheme.fontMediumPurple, 
                    ),
                    textAlign: TextAlign.center, // Figma: Text centrat în text box
                  ),
                ),
                Container(
                  height: 21, // Figma: 21px (markdown zice 24px pentru container, 21px pentru text)
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Clientii asteapta...",
                    style: AppTheme.subHeaderStyle.copyWith(
                      fontSize: AppTheme.fontSizeMedium, 
                      fontWeight: FontWeight.w500, 
                      color: const Color(0xFF927B9D), 
                      height: 21/17, // line-height (21px) / font-size (17px)
                    ),
                     textAlign: TextAlign.center, // Figma: Text centrat în text box
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48, 
            height: 48, 
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 13), // Figma
            decoration: BoxDecoration( 
            ),
            child: SvgPicture.asset(
              'assets/Logo.svg',
              width: 26.58, // Dimensiuni interne vector din Figma
              height: 22.4,
              colorFilter: const ColorFilter.mode(AppTheme.fontMediumPurple, BlendMode.srcIn), // Aplicăm culoarea specificată pentru vector dacă e necesar
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
        color: AppTheme.backgroundLightPurple, 
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
          padding: const EdgeInsets.only(left: AppTheme.smallGap, right: AppTheme.smallGap, bottom: 0),
          child: Container(
             height: 24, // Figma: Titlu Câmp height
             alignment: Alignment.centerLeft,
            child: Text(
              "Consultant",
              style: AppTheme.primaryTitleStyle.copyWith(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppTheme.fontMediumPurple,
              ),
            ),
          )
        ),
        Container(
          height: 48, // Figma: Dropdown height
          decoration: BoxDecoration(
            color: AppTheme.backgroundDarkPurple, 
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedConsultant,
            items: _isLoadingConsultants 
                ? [] 
                : _consultantNames.map((name) {
                    return DropdownMenuItem(
                      value: name,
                      child: Text(name, style: AppTheme.smallTextStyle.copyWith(color: const Color(0xFF7C568F), fontSize: AppTheme.fontSizeMedium)), 
                    );
                  }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedConsultant = value;
              });
            },
            hint: _isLoadingConsultants 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7C568F))) 
                : Text(
                    "Selecteaza consultant", 
                    style: AppTheme.smallTextStyle.copyWith(color: const Color(0xFF7C568F), fontSize: AppTheme.fontSizeMedium)
                  ),
            isExpanded: true,
            icon: Padding(
              padding: const EdgeInsets.only(right: AppTheme.smallGap), // Adăugăm padding pentru iconiță
              child: SvgPicture.asset(
                'assets/DropdownIcon.svg',
                width: AppTheme.iconSizeMedium, 
                height: AppTheme.iconSizeMedium,
                colorFilter: const ColorFilter.mode(Color(0xFF7C568F), BlendMode.srcIn),
              ),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none, 
              contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.smallGap, vertical: (48-21)/2), // Vertical padding pentru aliniere text (48 total - 21 text height / 2)
            ),
            style: AppTheme.smallTextStyle.copyWith(color: const Color(0xFF7C568F), fontSize: AppTheme.fontSizeMedium, height: 21/17),
            dropdownColor: AppTheme.backgroundDarkPurple,
            validator: (value) => value == null ? 'Selectează un consultant' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppTheme.smallGap, right: AppTheme.smallGap, bottom: 0),
          child: Container(
            height: 24, // Figma: Titlu Câmp height
            alignment: Alignment.centerLeft,
            child: Text(
              "Parola",
              style: AppTheme.primaryTitleStyle.copyWith(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppTheme.fontMediumPurple,
              ),
            ),
          )
        ),
        Container(
          height: 48, // Figma: Input height
          decoration: BoxDecoration(
            color: AppTheme.backgroundDarkPurple, 
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: true,
            style: AppTheme.smallTextStyle.copyWith(color: const Color(0xFF7C568F), fontSize: AppTheme.fontSizeMedium, height: 21/17),
            textAlignVertical: TextAlignVertical.center, // Pentru aliniere verticală mai bună
            decoration: InputDecoration(
              hintText: "Introdu parola",
              hintStyle: AppTheme.smallTextStyle.copyWith(color: const Color(0xFF7C568F), fontSize: AppTheme.fontSizeMedium, height: 21/17),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap), // Figma: padding: 0px 8px
              suffixIcon: IconButton(
                icon: SvgPicture.asset(
                  'assets/HelpIcon.svg',
                  width: AppTheme.iconSizeMedium, 
                  height: AppTheme.iconSizeMedium,
                  colorFilter: const ColorFilter.mode(Color(0xFF7C568F), BlendMode.srcIn), 
                ),
                iconSize: AppTheme.iconSizeMedium,
                onPressed: widget.onForgotPassword, 
                tooltip: "Am uitat parola",
                 padding: EdgeInsets.zero, // Elimină padding-ul default al IconButton
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Introdu parola';
              }
              return null;
            },
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
              color: AppTheme.fontMediumPurple, 
              fontWeight: FontWeight.w500,
              fontSize: AppTheme.fontSizeMedium, // 17px
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
                color: AppTheme.fontMediumPurple, 
                fontWeight: FontWeight.w600, 
                fontSize: AppTheme.fontSizeMedium, // 17px
                decoration: TextDecoration.underline,
                decorationColor: AppTheme.fontMediumPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity, 
      height: 48, 
      child: ElevatedButton(
        onPressed: _attemptLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.backgroundLightPurple, 
          foregroundColor: AppTheme.fontMediumPurple, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap), 
          elevation: 0, 
        ),
        child: Text(
          "Conectare",
          style: AppTheme.primaryTitleStyle.copyWith(
            fontSize: AppTheme.fontSizeMedium, // 17px
            fontWeight: FontWeight.w500, // Figma: medium weight (500)
            color: AppTheme.fontMediumPurple, 
          ),
        ),
      ),
    );
  }
}
