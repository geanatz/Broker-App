import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';

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

  void _submitToken() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _tokenError = null;
      });
      widget.onTokenSubmit(_tokenController.text);
    }
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
            _buildTokenForm(),
            SizedBox(height: AppTheme.smallGap),
            _buildGoToLoginLink(),
            SizedBox(height: AppTheme.smallGap),
            _buildContinueButton(),
            if (_tokenError != null)
              Padding(
                padding: const EdgeInsets.only(top: AppTheme.smallGap),
                child: Text(
                  _tokenError!,
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
            width: 211, // Figma
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 24, // Figma
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Ai uitat parola?",
                    style: AppTheme.primaryTitleStyle.copyWith(
                      fontSize: AppTheme.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.fontMediumPurple,
                    ),
                     textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  height: 21, // Figma
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Intai, dovedeste ca esti tu!",
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

  Widget _buildTokenForm() {
    return Container(
      height: 88,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLightPurple,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start, // Aliniere la început
          children: [
             Padding(
              padding: const EdgeInsets.only(left: AppTheme.smallGap, right: AppTheme.smallGap, bottom: 0),
              child: Container(
                height: 24, // Figma title height
                alignment: Alignment.centerLeft,
                child: Text(
                  "Token secret",
                  style: AppTheme.primaryTitleStyle.copyWith(
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.fontMediumPurple,
                  ),
                ),
              )
            ),
            // Fără SizedBox între titlu și input
            Container(
              height: 48, // Figma input height
              decoration: BoxDecoration(
                color: AppTheme.backgroundDarkPurple,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: TextFormField(
                controller: _tokenController,
                style: AppTheme.smallTextStyle.copyWith(color: const Color(0xFF7C568F), fontSize: AppTheme.fontSizeMedium, height: 21/17),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: "Introdu token-ul tau",
                  hintStyle: AppTheme.smallTextStyle.copyWith(color: const Color(0xFF7C568F), fontSize: AppTheme.fontSizeMedium, height: 21/17),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap), // Doar padding orizontal
                ),
                validator: (value) => value == null || value.isEmpty ? 'Introdu token-ul' : null,
              ),
            ),
          ],
        ),
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

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _submitToken,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.backgroundLightPurple,
          foregroundColor: AppTheme.fontMediumPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap),
        ),
        child: Text(
          "Continua",
          style: AppTheme.primaryTitleStyle.copyWith(
            fontSize: 18.0, // Figma specifică 18px aici
            fontWeight: FontWeight.w500, // Figma: medium (500)
            color: AppTheme.fontMediumPurple,
            height: 23/18, // Figma: line-height 23px
          ),
        ),
      ),
    );
  }
}
