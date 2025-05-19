import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../backend/services/calculatorService.dart';
import '../common/appTheme.dart';
import '../popups/amortizationPopup.dart';

/// Widget pentru panoul de calculator de credit
/// 
/// Aceasta este o componentă modală care oferă utilizatorului posibilitatea
/// de a introduce datele unui credit și de a calcula rata lunară, costul total
/// și dobânda totală. De asemenea, permite afișarea unui grafic de amortizare.
class CalculatorPane extends StatefulWidget {
  final Function? onClose;

  const CalculatorPane({
    Key? key,
    this.onClose,
  }) : super(key: key);

  @override
  State<CalculatorPane> createState() => _CalculatorPaneState();
}

class _CalculatorPaneState extends State<CalculatorPane> {
  // Controlere pentru input-uri
  final TextEditingController _principalController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _loanTermController = TextEditingController();
  
  // Valori calculate
  double _monthlyPayment = 0;
  double _totalCost = 0;
  double _totalInterest = 0;
  
  // Funcție pentru calcularea valorilor
  void _calculateLoan() {
    // Verifică dacă input-urile sunt valide
    if (_principalController.text.isEmpty ||
        _interestRateController.text.isEmpty ||
        _loanTermController.text.isEmpty) {
      return;
    }

    try {
      final double principal = double.parse(_principalController.text);
      final double interestRate = double.parse(_interestRateController.text);
      final int loanTerm = int.parse(_loanTermController.text);

      if (principal <= 0 || interestRate < 0 || loanTerm <= 0) {
        // Input-urile trebuie să fie pozitive
        return;
      }

      final double monthlyPayment = CalculatorService.calculateMonthlyPayment(
        principal: principal,
        interestRate: interestRate,
        loanTermMonths: loanTerm,
      );

      final double totalCost = CalculatorService.calculateTotalCost(
        monthlyPayment: monthlyPayment,
        loanTermMonths: loanTerm,
      );

      final double totalInterest = CalculatorService.calculateTotalInterest(
        totalCost: totalCost,
        principal: principal,
      );

      setState(() {
        _monthlyPayment = monthlyPayment;
        _totalCost = totalCost;
        _totalInterest = totalInterest;
      });
    } catch (e) {
      // Eroare la conversia în numere
      // În versiuni viitoare, se poate adăuga un snackbar sau un alt indicator pentru erori
    }
  }

  // Funcție pentru afișarea graficului de amortizare
  void _showAmortizationSchedule() {
    // Verifică dacă s-a calculat un credit
    if (_monthlyPayment <= 0) {
      return;
    }

    try {
      final double principal = double.parse(_principalController.text);
      final double interestRate = double.parse(_interestRateController.text);
      final int loanTerm = int.parse(_loanTermController.text);

      // Generează graficul de amortizare
      final schedule = CalculatorService.generateAmortizationSchedule(
        principal: principal,
        interestRate: interestRate,
        loanTermMonths: loanTerm,
      );

      // Afișează popup-ul cu graficul de amortizare
      showDialog(
        context: context,
        builder: (context) => AmortizationPopup(
          schedule: schedule,
        ),
      );
    } catch (e) {
      // Eroare la calcularea graficului
    }
  }

  @override
  void dispose() {
    _principalController.dispose();
    _interestRateController.dispose();
    _loanTermController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 312,
      height: 1032,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: BoxDecoration(
        color: AppTheme.popupBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: [AppTheme.widgetShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Secțiune principală (secțiunea de sus + formulare)
          Expanded(
            child: Center(
              child: Container(
                width: 296,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.mediumGap,
                        vertical: AppTheme.smallGap,
                      ),
                      child: Text(
                        'Calculator',
                        style: AppTheme.headerTitleStyle,
                      ),
                    ),
                    const SizedBox(height: AppTheme.smallGap),
                    
                    // Formular pentru suma creditului
                    _buildFormContainer([
                      _buildInputField(
                        title: 'Suma Credit',
                        altText: 'RON',
                        controller: _principalController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
                        ],
                      ),
                    ]),
                    const SizedBox(height: AppTheme.smallGap),
                    
                    // Formular pentru detalii credit
                    _buildFormContainer([
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              title: 'Dobândă',
                              altText: '%',
                              controller: _interestRateController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppTheme.smallGap),
                          Expanded(
                            child: _buildInputField(
                              title: 'Perioadă',
                              altText: 'luni',
                              controller: _loanTermController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: AppTheme.smallGap),
                    
                    // Formular pentru rezultate
                    _buildFormContainer([
                      _buildResultField(
                        title: 'Rata Lunară',
                        value: _monthlyPayment.toStringAsFixed(2),
                        altText: 'RON',
                      ),
                      const SizedBox(height: AppTheme.smallGap),
                      Row(
                        children: [
                          Expanded(
                            child: _buildResultField(
                              title: 'Cost Total',
                              value: _totalCost.toStringAsFixed(2),
                              altText: 'RON',
                            ),
                          ),
                          const SizedBox(width: AppTheme.smallGap),
                          Expanded(
                            child: _buildResultField(
                              title: 'Dobândă Totală',
                              value: _totalInterest.toStringAsFixed(2),
                              altText: 'RON',
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          
          // Butoane
          Center(
            child: Container(
              width: 296,
              child: Row(
                children: [
                  // Buton calculare
                  Expanded(
                    child: _buildActionButton(
                      title: 'Calculează',
                      icon: Icons.refresh,
                      onPressed: _calculateLoan,
                    ),
                  ),
                  const SizedBox(width: AppTheme.smallGap),
                  // Buton grafic amortizare
                  _buildIconButton(
                    icon: Icons.bar_chart,
                    onPressed: _showAmortizationSchedule,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Funcție pentru construirea unui container de formular
  Widget _buildFormContainer(List<Widget> children) {
    return Container(
      width: 296,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLightPurple,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // Funcție pentru construirea unui câmp de input
  Widget _buildInputField({
    required String title,
    String? altText,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header câmp
        Row(
          children: [
            Text(
              title,
              style: AppTheme.primaryTitleStyle,
            ),
            if (altText != null) ...[
              const SizedBox(width: AppTheme.tinyGap),
              Text(
                altText,
                style: AppTheme.secondaryTitleStyle,
              ),
            ],
          ],
        ),
        const SizedBox(height: AppTheme.tinyGap),
        // Input
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFACACD3), // Culoarea specifică din design
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: AppTheme.fontSizeMedium,
              fontWeight: FontWeight.w500,
              color: AppTheme.fontDarkPurple,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  // Funcție pentru construirea unui câmp de rezultat (read-only)
  Widget _buildResultField({
    required String title,
    required String value,
    String? altText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header câmp
        Row(
          children: [
            Text(
              title,
              style: AppTheme.primaryTitleStyle,
            ),
            if (altText != null) ...[
              const SizedBox(width: AppTheme.tinyGap),
              Text(
                altText,
                style: AppTheme.secondaryTitleStyle,
              ),
            ],
          ],
        ),
        const SizedBox(height: AppTheme.tinyGap),
        // Text rezultat (read-only)
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFACACD3), // Culoarea specifică din design
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap),
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: AppTheme.fontSizeMedium,
              fontWeight: FontWeight.w500,
              color: AppTheme.fontDarkPurple,
            ),
          ),
        ),
      ],
    );
  }

  // Funcție pentru construirea unui buton cu text și icon
  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: AppTheme.mediumGap,
        ),
        decoration: BoxDecoration(
          color: AppTheme.backgroundLightPurple,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: AppTheme.primaryTitleStyle,
            ),
            const SizedBox(width: AppTheme.smallGap),
            Icon(
              icon,
              size: AppTheme.iconSizeMedium,
              color: AppTheme.fontMediumPurple,
            ),
          ],
        ),
      ),
    );
  }

  // Funcție pentru construirea unui buton cu icon
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      child: Container(
        height: 48,
        width: 48,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.backgroundLightPurple,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        child: Icon(
          icon,
          size: AppTheme.iconSizeMedium,
          color: AppTheme.fontMediumPurple,
        ),
      ),
    );
  }
}
