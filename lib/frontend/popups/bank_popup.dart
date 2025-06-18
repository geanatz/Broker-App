import 'package:broker_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../backend/services/matcher_service.dart';
import '../components/headers/widget_header1.dart';
import '../components/buttons/flex_buttons1.dart';
import '../components/fields/input_field1.dart';

/// Popup pentru editarea criteriilor unei banci
/// 
/// Aceasta componenta permite editarea tuturor criteriilor
/// pentru o banca specifica si salvarea modificarilor
class BankPopup extends StatefulWidget {
  final BankCriteria bankCriteria;
  final MatcherService matcherService;

  const BankPopup({
    super.key,
    required this.bankCriteria,
    required this.matcherService,
  });

  @override
  State<BankPopup> createState() => _BankPopupState();
}

class _BankPopupState extends State<BankPopup> {
  late TextEditingController _minIncomeController;
  late TextEditingController _maxAgeMaleController;
  late TextEditingController _maxAgeFemaleController;
  late TextEditingController _minFicoController;
  late TextEditingController _maxLoanAmountController;

  @override
  void initState() {
    super.initState();
    
    // Initializeaza controlerele cu valorile curente
    _minIncomeController = TextEditingController(
      text: widget.bankCriteria.minIncome.toStringAsFixed(0)
    );
    _maxAgeMaleController = TextEditingController(
      text: widget.bankCriteria.maxAgeMale.toString()
    );
    _maxAgeFemaleController = TextEditingController(
      text: widget.bankCriteria.maxAgeFemale.toString()
    );
    _minFicoController = TextEditingController(
      text: widget.bankCriteria.minFicoScore.toStringAsFixed(0)
    );
    _maxLoanAmountController = TextEditingController(
      text: _formatWithCommas(widget.bankCriteria.maxLoanAmount.toStringAsFixed(0))
    );
  }

  /// Formateaza un numar cu virgule pentru afisare
  String _formatWithCommas(String value) {
    if (value.isEmpty || value == '0') return value;
    
    try {
      final numericValue = int.tryParse(value.replaceAll(',', ''));
      if (numericValue != null && numericValue > 0) {
        // Manual formatting with commas
        final valueStr = numericValue.toString();
        final reversed = valueStr.split('').reversed.toList();
        final formatted = <String>[];
        
        for (int i = 0; i < reversed.length; i++) {
          if (i > 0 && i % 3 == 0) {
            formatted.add(',');
          }
          formatted.add(reversed[i]);
        }
        
        return formatted.reversed.join();
      }
    } catch (e) {
      debugPrint('Error formatting value: $e');
    }
    
    return value;
  }

  @override
  void dispose() {
    _minIncomeController.dispose();
    _maxAgeMaleController.dispose();
    _maxAgeFemaleController.dispose();
    _minFicoController.dispose();
    _maxLoanAmountController.dispose();
    super.dispose();
  }

  /// Salveaza modificarile criteriilor
  void _saveChanges() async {
    try {
      // Valideaza si creeaza criteriile actualizate
      final updatedCriteria = BankCriteria(
        bankName: widget.bankCriteria.bankName,
        minIncome: double.parse(_minIncomeController.text.replaceAll(',', '')),
        maxAgeMale: int.parse(_maxAgeMaleController.text),
        maxAgeFemale: int.parse(_maxAgeFemaleController.text),
        minFicoScore: double.parse(_minFicoController.text),
        maxLoanAmount: double.parse(_maxLoanAmountController.text.replaceAll(',', '')),
      );
      
      // Salveaza prin MatcherService
      await widget.matcherService.updateBankCriteria(updatedCriteria);
      
      // Inchide popup-ul
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      // Afiseaza mesaj de confirmare
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Criteriile pentru ${widget.bankCriteria.bankName} au fost salvate'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Afiseaza eroare daca valorile nu sunt valide
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Valorile introduse nu sunt valide'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(AppTheme.smallGap),
        decoration: ShapeDecoration(
          color: AppTheme.popupBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          ),
          shadows: const [
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
          children: [
            // Header
            WidgetHeader1(
              title: widget.bankCriteria.bankName,
              titleColor: AppTheme.elementColor1,
            ),
            
            const SizedBox(height: AppTheme.smallGap),
            
            // Content container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.smallGap),
              decoration: ShapeDecoration(
                color: AppTheme.containerColor1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Venit minim
                  InputField1(
                    title: 'Venit minim',
                    controller: _minIncomeController,
                    hintText: 'Introduceti venitul minim',
                    keyboardType: TextInputType.number,
                    enableCommaFormatting: true,
                  ),
                  
                  const SizedBox(height: AppTheme.smallGap),
                  
                  // Varsta maxima row (barbati si femei)
                  Row(
                    children: [
                      Expanded(
                        child: InputField1(
                          title: 'Varsta barbati',
                          controller: _maxAgeMaleController,
                          hintText: 'Varsta max',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppTheme.smallGap),
                      Expanded(
                        child: InputField1(
                          title: 'Varsta femei',
                          controller: _maxAgeFemaleController,
                          hintText: 'Varsta max',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.smallGap),
                  
                  // FICO minim
                  InputField1(
                    title: 'FICO minim',
                    controller: _minFicoController,
                    hintText: 'Scorul FICO minim',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.smallGap),
                  
                  // Suma maxima de credit
                  InputField1(
                    title: 'Suma maxima credit',
                    controller: _maxLoanAmountController,
                    hintText: 'Suma maxima',
                    keyboardType: TextInputType.number,
                    enableCommaFormatting: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.smallGap),
            
            // Save button with icon
            FlexButtonSingle(
              text: 'Salveaza',
              iconPath: 'assets/saveIcon.svg',
              onTap: _saveChanges,
            ),
          ],
        ),
      ),
    );
  }
}
