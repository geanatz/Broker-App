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
import 'package:intl/intl.dart';

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
    _loanYearsController.text = '5';
    _loanMonthsController.text = '0';
    
    // Add listeners to all controllers to trigger automatic calculation
    _principalController.addListener(_calculateLoan);
    _interestRateController.addListener(_calculateLoan);
    _loanYearsController.addListener(_calculateLoan);
    _loanMonthsController.addListener(_calculateLoan);
    
    // Listen to form service changes to update income calculation
    _formService.addListener(_calculateIncomePercentage);
    
    // Calculate initial income percentage
    _calculateIncomePercentage();
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
      _interestRateController.clear();
      _loanYearsController.text = '5';
      _loanMonthsController.text = '0';
      _monthlyPayment = 0;
      _totalCost = 0;
      _totalInterest = 0;
    });
    
    // Recalculate income percentage after reset
    _calculateIncomePercentage();
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
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final String placeholderText = (title == 'Ani' || title == 'Luni') ? '0' : 'Introdu ${title.toLowerCase()}';
    
    // Define formatters based on field type
    final List<TextInputFormatter> formatters;
    if (title == 'Suma' || title == 'Dobanda') {
      formatters = [FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]'))];
    } else {
      formatters = inputFormatters ?? [];
    }
    
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 128),
      child: SizedBox(
        width: double.infinity,
        height: 72, // Same as InputField1 default height
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title area
            Container(
              width: double.infinity,
              height: 21,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                style: AppTheme.safeOutfit(
                  color: AppTheme.elementColor2,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // Input area
            Container(
              width: double.infinity,
              height: 48,
              decoration: ShapeDecoration(
                color: AppTheme.containerColor2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                inputFormatters: formatters,
                style: AppTheme.safeOutfit(
                  color: AppTheme.elementColor3,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15 ),
                  border: InputBorder.none,
                  hintText: placeholderText,
                  hintStyle: AppTheme.safeOutfit(
                    color: AppTheme.elementColor3,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onChanged: (value) {
                  if (title == 'Suma' || title == 'Dobanda') {
                    final numericValue = value.replaceAll(',', '');
                    if (numericValue.isEmpty) {
                      controller.value = TextEditingValue(
                        text: '',
                        selection: TextSelection.collapsed(offset: 0),
                      );
                    } else {
                      try {
                        final parts = numericValue.split('.');
                        final intPart = parts[0];
                        final decPart = parts.length > 1 ? parts[1] : '';
                        final formattedInt = NumberFormat('#,###').format(int.parse(intPart));
                        final newText = decPart.isNotEmpty ? '$formattedInt.$decPart' : formattedInt;
                        controller.value = TextEditingValue(
                          text: newText,
                          selection: TextSelection.collapsed(offset: newText.length),
                        );
                      } catch (e) {
                        // Handle parsing errors
                      }
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
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
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // Interest Rate using InputField1 component
                            _buildCustomInputField(
                              title: 'Dobanda',
                              controller: _interestRateController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                              ],
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
                                      keyboardType: TextInputType.number,
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
                                      keyboardType: TextInputType.number,
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
  
  

