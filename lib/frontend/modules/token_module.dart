import 'package:broker_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountCreatedPopup extends StatefulWidget {
  final String token;
  final VoidCallback onContinue;

  const AccountCreatedPopup({
    super.key,
    required this.token,
    required this.onContinue,
  });

  @override
  State<AccountCreatedPopup> createState() => _AccountCreatedPopupState();
}

class _AccountCreatedPopupState extends State<AccountCreatedPopup> {
  late TextEditingController _tokenController;

  @override
  void initState() {
    super.initState();
    
    // Asculta schimbarile din AppTheme pentru actualizari automate ale UI-ului
    AppTheme().addListener(_onAppThemeChanged);

    _tokenController = TextEditingController(text: widget.token);
  }

  @override
  void dispose() {
    _tokenController.dispose();
    AppTheme().removeListener(_onAppThemeChanged);
    super.dispose();
  }

  /// Callback pentru schimbarile din AppTheme
  void _onAppThemeChanged() {
    if (mounted) {
      debugPrint('🎨 TOKEN_POPUP: AppTheme changed, updating UI');
      setState(() {
        // Actualizeaza UI-ul cand se schimba AppTheme
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🟫 TOKEN_MODULE: Building AccountCreatedPopup');
    debugPrint('🟫 TOKEN_MODULE: Token: ${widget.token.substring(0, 8)}...');
    
    const double popupWidth = 360.0;
    const double popupHeight = 220.0;

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHeader(),
            const SizedBox(height: AppTheme.smallGap),
            _buildTokenField(context),
            const SizedBox(height: AppTheme.smallGap),
            _buildContinueButton(),
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
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  child: Text(
                    "Contul tau a fost creat!",
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
                  height: 24,
                  child: Text(
                    "Mai jos ai cheia contului tau.",
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

  Widget _buildTokenField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: BoxDecoration(
        color: AppTheme.containerColor1,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
            child: Text(
              "Token-ul tau",
              style: AppTheme.primaryTitleStyle.copyWith(
                fontSize: AppTheme.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: AppTheme.elementColor2,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.tinyGap),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.containerColor2,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap),
                    child: Text(
                      widget.token,
                      style: AppTheme.smallTextStyle.copyWith(
                        color: AppTheme.elementColor3,
                        fontSize: AppTheme.fontSizeMedium,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/copyIcon.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(AppTheme.elementColor3, BlendMode.srcIn),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.token));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Token copiat in clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  padding: const EdgeInsets.all(0),
                  splashRadius: 24,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.containerColor1,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: TextButton(
        onPressed: () {
          debugPrint('🟫 TOKEN_MODULE: Continue button pressed, calling onContinue');
          widget.onContinue();
        },
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
        ),
        child: Text(
          "Continua",
          style: AppTheme.smallTextStyle.copyWith(
            color: AppTheme.elementColor2,
            fontSize: AppTheme.fontSizeMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
} 
