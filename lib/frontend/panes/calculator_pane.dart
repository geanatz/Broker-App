import 'package:broker_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../backend/services/calculator_service.dart';
import '../../backend/services/form_service.dart';
import '../popups/amortization_popup.dart';
// Import components
import '../components/headers/widget_header1.dart';
import '../components/items/light_item3.dart';
import '../components/buttons/flex_buttons2.dart';
import '../components/fields/input_field1.dart';

/// Widget pentru panoul de calculator de credit
/// 
/// Aceasta este o componenta modala care ofera utilizatorului posibilitatea
/// de a introduce datele unui credit si de a calcula rata lunara, costul total
/// si dobanda totala. De asemenea, permite afisarea unui grafic de amortizare.
class CalculatorPane extends StatefulWidget {
  final Function? onClose;

  const CalculatorPane({
    super.key,
    this.onClose,
  });

  @override
  State<CalculatorPane> createState() => _CalculatorPaneState();
}

class _CalculatorPaneState extends State<CalculatorPane> {
  // Controlere pentru input-uri
  final TextEditingController _principalController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _loanYearsController = TextEditingController();
  final TextEditingController _loanMonthsController = TextEditingController();
  
  // Services - only keep FormService for listening to changes
  final FormService _formService = FormService();
  
  // Valori calculate
  double _monthlyPayment = 0;
  double _totalCost = 0;
  double _totalInterest = 0;
  double _incomePercentage = 0;
  
  // Flag pentru a verifica daca calculul poate fi efectuat
  bool get _canCalculate {
    return _principalController.text.isNotEmpty && 
           _interestRateController.text.isNotEmpty;
  }
  
  @override
  void initState() {
    super.initState();
    // Seteaza valorile implicite inainte de a adauga listener-ele
    _loanYearsController.text = '5';
    _loanMonthsController.text = '0';
    _interestRateController.text = '10';

    // Abia acum adauga listener-ele
    _principalController.addListener(_calculateLoan);
    _interestRateController.addListener(_calculateLoan);
    _loanYearsController.addListener(_calculateLoan);
    _loanMonthsController.addListener(_calculateLoan);
    
    _formService.addListener(_calculateIncomePercentage);
    
    // Folosește addPostFrameCallback pentru a evita setState în timpul build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateIncomePercentage();
    });
  }
  
  // Functie pentru calcularea valorilor
  void _calculateLoan() {
    // Verifica daca input-urile sunt valide
    if (!_canCalculate) {
      setState(() {
        _monthlyPayment = 0;
        _totalCost = 0;
        _totalInterest = 0;
      });
      return;
    }

    try {
      final double principal = double.parse(_principalController.text.replaceAll(',', ''));
      final double interestRate = double.parse(_interestRateController.text.replaceAll(',', ''));
      
      // Calculeaza perioada totala in luni
      int years = 0;
      if (_loanYearsController.text.isNotEmpty) {
        years = int.tryParse(_loanYearsController.text) ?? 5;
      } else {
        years = 5; // Default to 5 years if empty
      }
      
      int months = 0;
      if (_loanMonthsController.text.isNotEmpty) {
        months = int.tryParse(_loanMonthsController.text) ?? 0;
      } else {
        months = 0; // Default to 0 months if empty
      }
      
      int loanTerm = (years * 12) + months;

      if (principal <= 0 || interestRate < 0 || loanTerm <= 0) {
        // Input-urile trebuie sa fie pozitive
        setState(() {
          _monthlyPayment = 0;
          _totalCost = 0;
          _totalInterest = 0;
        });
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
      // Eroare la conversia in numere
      setState(() {
        _monthlyPayment = 0;
        _totalCost = 0;
        _totalInterest = 0;
      });
    }
  }

  // Functie pentru afisarea graficului de amortizare
  void _showAmortizationSchedule() {
    // Verifica daca s-a calculat un credit
    if (_monthlyPayment <= 0 || !_canCalculate) {
      return;
    }

    try {
      final double principal = double.parse(_principalController.text.replaceAll(',', ''));
      final double interestRate = double.parse(_interestRateController.text.replaceAll(',', ''));
      
      // Calculeaza perioada totala in luni
      int years = 0;
      if (_loanYearsController.text.isNotEmpty) {
        years = int.tryParse(_loanYearsController.text) ?? 5;
      } else {
        years = 5; // Default to 5 years if empty
      }
      
      int months = 0;
      if (_loanMonthsController.text.isNotEmpty) {
        months = int.tryParse(_loanMonthsController.text) ?? 0;
      } else {
        months = 0; // Default to 0 months if empty
      }
      
      int loanTerm = (years * 12) + months;

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
      _interestRateController.text = '10';
      _loanYearsController.text = '5';
      _loanMonthsController.text = '0';
      _monthlyPayment = 0;
      _totalCost = 0;
      _totalInterest = 0;
    });
    
    // Recalculate income percentage after reset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateIncomePercentage();
    });
  }

  @override
  void dispose() {
    // Remove listeners before disposing controllers
    _principalController.removeListener(_calculateLoan);
    _interestRateController.removeListener(_calculateLoan);
    _loanYearsController.removeListener(_calculateLoan);
    _loanMonthsController.removeListener(_calculateLoan);
    
    // Remove form service listener
    _formService.removeListener(_calculateIncomePercentage);
    
    // Dispose controllers
    _principalController.dispose();
    _interestRateController.dispose();
    _loanYearsController.dispose();
    _loanMonthsController.dispose();
    super.dispose();
  }

  // Build a custom input field with TextField directly
  Widget _buildCustomInputField({
    required String title,
    required TextEditingController controller,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final String placeholderText = (title == 'Ani' || title == 'Luni' || title == 'Dobanda') ? '0' : 'Introdu ${title.toLowerCase()}';

    if (title == 'Suma' || title == 'Dobanda') {
      return InputField1(
        title: title,
        controller: controller,
        hintText: placeholderText,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        enableCommaFormatting: true,
        enableKTransformation: false,
        suffixText: title == 'Dobanda' ? '%' : null,
        suffixTextColor: title == 'Dobanda' ? AppTheme.elementColor3 : null,
      );
    } else {
      return InputField1(
        title: title,
        controller: controller,
        hintText: placeholderText,
        keyboardType: TextInputType.number,
        enableCommaFormatting: false,
        enableKTransformation: false,
        inputFormatters: inputFormatters,
      );
    }
  }

  /// Calculeaza 40% din totalul veniturilor pentru clientul activ
  void _calculateIncomePercentage() {
    final percentage = CalculatorService.calculateIncomePercentage();
    
    setState(() {
      _incomePercentage = percentage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: ShapeDecoration(
        color: AppTheme.popupBackground,
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
            width: 296,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header using WidgetHeader1 component
                WidgetHeader1(
                  title: 'Calculator',
                  titleColor: AppTheme.elementColor1,
                ),
                const SizedBox(height: AppTheme.smallGap),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Input Container
                      Container(
                        width: 296,
                        padding: const EdgeInsets.all(8),
                        decoration: ShapeDecoration(
                          color: AppTheme.containerColor1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Principal Amount using InputField1 component
                            _buildCustomInputField(
                              title: 'Suma',
                              controller: _principalController,
                            ),
                            const SizedBox(height: 8),
                            
                            // Interest Rate using InputField1 component
                            _buildCustomInputField(
                              title: 'Dobanda',
                              controller: _interestRateController,
                            ),
                            const SizedBox(height: 8),
                            
                            // Years and Months using InputField1 components
                            SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Years
                                  Expanded(
                                    child: _buildCustomInputField(
                                      title: 'Ani',
                                      controller: _loanYearsController,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),
                                  ),
                                  
                                  SizedBox(width: 8),
                                  
                                  // Months
                                  Expanded(
                                    child: _buildCustomInputField(
                                      title: 'Luni',
                                      controller: _loanMonthsController,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Results Container
                      Container(
                        width: double.infinity,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Monthly Payment
                            LightItem3(
                              title: 'Rata lunara',
                              description: _monthlyPayment > 0 ? _monthlyPayment.toStringAsFixed(1) : '0.0',
                              backgroundColor: AppTheme.containerColor1,
                              titleColor: AppTheme.elementColor2,
                              descriptionColor: AppTheme.elementColor1,
                              titleStyle: AppTheme.safeOutfit(
                                color: AppTheme.elementColor2,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                              descriptionStyle: AppTheme.safeOutfit(
                                color: AppTheme.elementColor1,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            
                            SizedBox(height: 8),
                            
                            // Total Interest
                            LightItem3(
                              title: 'Dobanda totala',
                              description: _totalInterest > 0 ? _totalInterest.toStringAsFixed(1) : '0.0',
                              backgroundColor: AppTheme.containerColor1,
                              titleColor: AppTheme.elementColor2,
                              descriptionColor: AppTheme.elementColor1,
                              titleStyle: AppTheme.safeOutfit(
                                color: AppTheme.elementColor2,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                              descriptionStyle: AppTheme.safeOutfit(
                                color: AppTheme.elementColor1,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            
                            SizedBox(height: 8),
                            
                            // Total Payment
                            LightItem3(
                              title: 'Plata totala',
                              description: _totalCost > 0 ? _totalCost.toStringAsFixed(1) : '0.0',
                              backgroundColor: AppTheme.containerColor1,
                              titleColor: AppTheme.elementColor2,
                              descriptionColor: AppTheme.elementColor1,
                              titleStyle: AppTheme.safeOutfit(
                                color: AppTheme.elementColor2,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                              descriptionStyle: AppTheme.safeOutfit(
                                color: AppTheme.elementColor1,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            
                            SizedBox(height: 8),
                            
                            // 40% of Total Income
                            LightItem3(
                              title: '40% din venituri',
                              description: _incomePercentage > 0 ? _incomePercentage.toStringAsFixed(1) : '0.0',
                              backgroundColor: AppTheme.containerColor1,
                              titleColor: AppTheme.elementColor2,
                              descriptionColor: AppTheme.elementColor1,
                              titleStyle: AppTheme.safeOutfit(
                                color: AppTheme.elementColor2,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                              descriptionStyle: AppTheme.safeOutfit(
                                color: AppTheme.elementColor1,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Buttons
          FlexButtonWithTrailingIcon(
            primaryButtonText: 'Amortizare',
            primaryButtonIconPath: 'assets/viewIcon.svg',
            onPrimaryButtonTap: _showAmortizationSchedule,
            trailingIconPath: 'assets/returnIcon.svg',
            onTrailingIconTap: _resetFields,
            spacing: AppTheme.smallGap,
            borderRadius: AppTheme.borderRadiusMedium,
            buttonHeight: 48.0,
            primaryButtonTextStyle: AppTheme.safeOutfit(
              fontSize: AppTheme.fontSizeMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
  
  

