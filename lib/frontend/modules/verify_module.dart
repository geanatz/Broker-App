import 'package:broker_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:broker_app/frontend/modules/login_module.dart';

class TokenPopup extends StatefulWidget {
  final Function(String token) onTokenSubmit;
  final VoidCallback onGoToLogin;

  const TokenPopup({
    super.key,
    required this.onTokenSubmit,
    required this.onGoToLogin,
  });

  @override
  State<TokenPopup> createState() => _TokenPopupState();
}

class _TokenPopupState extends State<TokenPopup> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  String? _tokenError;
  
  // Adaugare stare pentru validare
  bool _isTokenInvalid = false;

  void _submitToken() {
    // Resetam starea de validare
    setState(() {
      _isTokenInvalid = false;
      _tokenError = null;
    });
    
    // Validare manuala
    if (_tokenController.text.isEmpty) {
      setState(() {
        _isTokenInvalid = true;
      });
      return;
    }
    
    // Daca token-ul e valid, continuam
    widget.onTokenSubmit(_tokenController.text);
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double popupWidth = 360.0;
    const double popupHeight = 248.0;

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
            _buildTokenForm(),
            SizedBox(height: AppTheme.smallGap),
            _buildGoToLoginLink(),
            SizedBox(height: AppTheme.smallGap),
            _buildSubmitButton(),
            if (_tokenError != null)
              Padding(
                padding: const EdgeInsets.only(top: AppTheme.tinyGap),
                child: Text(
                  _tokenError!,
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
                    "Ai uitat parola?",
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
                    "Intai, dovedeste ca esti tu!",
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

  Widget _buildTokenForm() {
    return Container(
      height: 88,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: BoxDecoration(
        color: AppTheme.containerColor1,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: AppTheme.smallGap, right: AppTheme.smallGap, bottom: 0),
              child: Container(
                height: 24,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Token secret (permanent)",
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
                border: _isTokenInvalid 
                    ? Border.all(color: AppTheme.elementColor2, width: 2.0)
                    : null,
              ),
              child: TextFormField(
                controller: _tokenController,
                style: AppTheme.smallTextStyle.copyWith(color: AppTheme.elementColor3, fontSize: AppTheme.fontSizeMedium, fontWeight: FontWeight.w500),
                textAlignVertical: TextAlignVertical.center,
                onChanged: (value) {
                  if (_isTokenInvalid && value.isNotEmpty) {
                    setState(() {
                      _isTokenInvalid = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: "Introdu token-ul tau permanent",
                  hintStyle: AppTheme.smallTextStyle.copyWith(color: AppTheme.elementColor3, fontSize: AppTheme.fontSizeMedium, fontWeight: FontWeight.w500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap, vertical: 15.0),
                ),
                validator: null, // Eliminam validatorul standard
              ),
            ),
          ],
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

  Widget _buildSubmitButton() {
    return AuthPopupButton(
      onPressed: _submitToken,
      text: "Verifica token",
    );
  }
}
