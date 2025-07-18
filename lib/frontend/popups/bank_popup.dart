import 'package:broker_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../backend/services/matcher_service.dart';
import '../components/headers/widget_header1.dart';
import '../components/fields/input_field1.dart';

/// Popup pentru vizualizarea criteriilor unei banci
/// 
/// Aceasta componenta afiseaza criteriile unei banci
/// in mod read-only (doar pentru vizualizare)
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
    
    // FIX: Initializeaza controlerele cu valorile curente formatate (read-only)
    _minIncomeController = TextEditingController(
      text: _formatWithCommas(widget.bankCriteria.minIncome.toStringAsFixed(0))
    );
    _maxAgeMaleController = TextEditingController(
      text: widget.bankCriteria.maxAgeMale.toString()
    );
    _maxAgeFemaleController = TextEditingController(
      text: widget.bankCriteria.maxAgeFemale.toString()
    );
    _minFicoController = TextEditingController(
      text: _formatWithCommas(widget.bankCriteria.minFicoScore.toStringAsFixed(0))
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

  // FIX: Eliminată metoda _saveChanges - popup-ul este doar pentru vizualizare

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
                  // Venit minim (read-only)
                  InputField1(
                    title: 'Venit minim',
                    controller: _minIncomeController,
                    hintText: 'Venit minim',
                    keyboardType: TextInputType.number,
                    enableCommaFormatting: true,
                    enabled: false, // FIX: Read-only
                  ),
                  
                  const SizedBox(height: AppTheme.smallGap),
                  
                  // Varsta maxima row (barbati si femei) - read-only
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
                          enabled: false, // FIX: Read-only
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
                          enabled: false, // FIX: Read-only
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.smallGap),
                  
                  // FICO minim (read-only)
                  InputField1(
                    title: 'FICO minim',
                    controller: _minFicoController,
                    hintText: 'FICO minim',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    enabled: false, // FIX: Read-only
                  ),
                  
                  const SizedBox(height: AppTheme.smallGap),
                  
                  // Plafon (read-only)
                  InputField1(
                    title: 'Plafon', // FIX: Schimbat din "Suma maxima credit"
                    controller: _maxLoanAmountController,
                    hintText: 'Plafon',
                    keyboardType: TextInputType.number,
                    enableCommaFormatting: true,
                    enabled: false, // FIX: Read-only
                  ),
                ],
              ),
            ),
            
            // FIX: Eliminat butonul de salvare - popup-ul este doar pentru vizualizare
          ],
        ),
      ),
    );
  }
}
