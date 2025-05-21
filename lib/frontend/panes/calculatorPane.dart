import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../backend/services/calculatorService.dart';
import '../common/appTheme.dart';
import '../popups/amortizationPopup.dart';

/// Widget pentru panoul de calculator de credit
/// 
/// Aceasta este o componenta modala care ofera utilizatorului posibilitatea
/// de a introduce datele unui credit si de a calcula rata lunara, costul total
/// si dobanda totala. De asemenea, permite afisarea unui grafic de amortizare.
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
  final TextEditingController _loanYearsController = TextEditingController();
  final TextEditingController _loanMonthsController = TextEditingController();
  
  // Validare input-uri
  bool _principalError = false;
  bool _interestRateError = false;
  bool _loanYearsError = false;
  bool _loanMonthsError = false;
  
  // Valori calculate
  double _monthlyPayment = 0;
  double _totalCost = 0;
  double _totalInterest = 0;
  
  // Functie pentru calcularea valorilor
  void _calculateLoan() {
    // Verificare erori
    setState(() {
      _principalError = _principalController.text.isEmpty;
      _interestRateError = _interestRateController.text.isEmpty;
      _loanYearsError = _loanYearsController.text.isEmpty && _loanMonthsController.text.isEmpty;
      _loanMonthsError = _loanYearsController.text.isEmpty && _loanMonthsController.text.isEmpty;
    });

    // Verifica daca input-urile sunt valide
    if (_principalError || _interestRateError || (_loanYearsError && _loanMonthsError)) {
      return;
    }

    try {
      final double principal = double.parse(_principalController.text);
      final double interestRate = double.parse(_interestRateController.text);
      
      // Calculeaza perioada totala in luni
      int loanTerm = 0;
      if (_loanYearsController.text.isNotEmpty) {
        loanTerm += int.parse(_loanYearsController.text) * 12;
      }
      if (_loanMonthsController.text.isNotEmpty) {
        loanTerm += int.parse(_loanMonthsController.text);
      }

      if (principal <= 0 || interestRate < 0 || loanTerm <= 0) {
        // Input-urile trebuie sa fie pozitive
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
        
        // Resetare stare erori
        _principalError = false;
        _interestRateError = false;
        _loanYearsError = false;
        _loanMonthsError = false;
      });
    } catch (e) {
      // Eroare la conversia in numere
      // In versiuni viitoare, se poate adauga un snackbar sau un alt indicator pentru erori
    }
  }

  // Functie pentru afisarea graficului de amortizare
  void _showAmortizationSchedule() {
    // Verifica daca s-a calculat un credit
    if (_monthlyPayment <= 0) {
      return;
    }

    try {
      final double principal = double.parse(_principalController.text);
      final double interestRate = double.parse(_interestRateController.text);
      
      // Calculeaza perioada totala in luni
      int loanTerm = 0;
      if (_loanYearsController.text.isNotEmpty) {
        loanTerm += int.parse(_loanYearsController.text) * 12;
      }
      if (_loanMonthsController.text.isNotEmpty) {
        loanTerm += int.parse(_loanMonthsController.text);
      }

      // Genereaza graficul de amortizare
      final schedule = CalculatorService.generateAmortizationSchedule(
        principal: principal,
        interestRate: interestRate,
        loanTermMonths: loanTerm,
      );

      // Afiseaza popup-ul cu graficul de amortizare
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

  // Functie pentru resetarea tuturor campurilor
  void _resetFields() {
    setState(() {
      _principalController.clear();
      _interestRateController.clear();
      _loanYearsController.clear();
      _loanMonthsController.clear();
      _monthlyPayment = 0;
      _totalCost = 0;
      _totalInterest = 0;
      
      // Resetare stare erori
      _principalError = false;
      _interestRateError = false;
      _loanYearsError = false;
      _loanMonthsError = false;
    });
  }

  @override
  void dispose() {
    _principalController.dispose();
    _interestRateController.dispose();
    _loanYearsController.dispose();
    _loanMonthsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: ShapeDecoration(
        color: AppTheme.widgetBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 15,
            offset: Offset(0, 0),
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: 24,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Calculator',
                                style: TextStyle(
                                  color: AppTheme.elementColor1,
                                  fontSize: AppTheme.fontSizeLarge,
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.smallGap),
                
                // Primul container cu input-uri (3 row-uri)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.smallGap),
                  decoration: ShapeDecoration(
                    color: AppTheme.containerColor1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Suma
                      _buildInputField(
                        title: 'Suma',
                        altText: _principalError ? 'Completeaza!' : 'RON',
                        controller: _principalController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
                        ],
                        isError: _principalError,
                      ),
                      const SizedBox(height: AppTheme.smallGap),
                      
                      // Dobanda
                      _buildInputField(
                        title: 'Dobanda',
                        altText: _interestRateError ? 'Completeaza!' : '%',
                        controller: _interestRateController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
                        ],
                        isError: _interestRateError,
                      ),
                      const SizedBox(height: AppTheme.smallGap),
                      
                      // Ani si Luni
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildInputField(
                              title: 'Ani',
                              altText: _loanYearsError ? 'Completeaza!' : null,
                              controller: _loanYearsController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              isError: _loanYearsError,
                            ),
                          ),
                          const SizedBox(width: AppTheme.smallGap),
                          Expanded(
                            child: _buildInputField(
                              title: 'Luni',
                              altText: _loanMonthsError ? 'Completeaza!' : null,
                              controller: _loanMonthsController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              isError: _loanMonthsError,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.smallGap),
                
                // Al doilea container cu rezultate (3 row-uri, fara coloane)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.smallGap),
                  decoration: ShapeDecoration(
                    color: AppTheme.containerColor1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rata lunara
                      _buildResultField(
                        title: 'Rata lunara',
                        value: _monthlyPayment.toStringAsFixed(2),
                      ),
                      const SizedBox(height: AppTheme.smallGap),
                      
                      // Dobanda totala
                      _buildResultField(
                        title: 'Dobanda totala',
                        value: _totalInterest.toStringAsFixed(2),
                      ),
                      const SizedBox(height: AppTheme.smallGap),
                      
                      // Plata totala
                      _buildResultField(
                        title: 'Plata totala',
                        value: _totalCost.toStringAsFixed(2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Butoane de actiune
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Buton reset
                Expanded(
                  child: InkWell(
                    onTap: _resetFields,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap, vertical: 12),
                      decoration: ShapeDecoration(
                        color: AppTheme.containerColor1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Reseteaza',
                            style: TextStyle(
                              color: AppTheme.elementColor2,
                              fontSize: AppTheme.fontSizeMedium,
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: AppTheme.smallGap),
                          Icon(
                            Icons.refresh,
                            size: AppTheme.iconSizeMedium,
                            color: AppTheme.elementColor2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.smallGap),
                
                // Buton calcul
                InkWell(
                  onTap: _calculateLoan,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                  child: Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(12),
                    decoration: ShapeDecoration(
                      color: AppTheme.containerColor1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                      ),
                    ),
                    child: Icon(
                      Icons.calculate,
                      size: AppTheme.iconSizeMedium,
                      color: AppTheme.elementColor2,
                    ),
                  ),
                ),
                
                // Buton amortizare
                const SizedBox(width: AppTheme.smallGap),
                InkWell(
                  onTap: _showAmortizationSchedule,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                  child: Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(12),
                    decoration: ShapeDecoration(
                      color: AppTheme.containerColor1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                      ),
                    ),
                    child: Icon(
                      Icons.bar_chart,
                      size: AppTheme.iconSizeMedium,
                      color: AppTheme.elementColor2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Functie pentru construirea unui camp de input
  Widget _buildInputField({
    required String title,
    String? altText,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool isError = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header camp
          Container(
            width: double.infinity,
            height: 21,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: AppTheme.elementColor2,
                            fontSize: AppTheme.fontSizeMedium,
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (altText != null)
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          altText,
                          style: TextStyle(
                            color: isError ? Colors.red : AppTheme.elementColor1,
                            fontSize: AppTheme.fontSizeSmall,
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.tinyGap),
          // Input
          Container(
            width: double.infinity,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap),
            decoration: ShapeDecoration(
              color: AppTheme.containerColor2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                side: isError ? BorderSide(color: Colors.red, width: 1.0) : BorderSide.none,
              ),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              style: TextStyle(
                color: AppTheme.elementColor3,
                fontSize: AppTheme.fontSizeMedium,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Functie pentru construirea unui camp de rezultat (read-only)
  Widget _buildResultField({
    required String title,
    required String value,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header camp
          Container(
            width: double.infinity,
            height: 21,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: AppTheme.elementColor2,
                            fontSize: AppTheme.fontSizeMedium,
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.tinyGap),
          // Text rezultat (read-only)
          Container(
            width: double.infinity,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap),
            decoration: ShapeDecoration(
              color: AppTheme.containerColor2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: AppTheme.elementColor3,
                fontSize: AppTheme.fontSizeMedium,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
