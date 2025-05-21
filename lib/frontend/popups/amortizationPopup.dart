import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../backend/services/calculatorService.dart';
import '../common/appTheme.dart';
// Import components
import '../common/components/headers/widgetHeader1.dart';
import '../common/components/rows/headerRow.dart';
import '../common/components/rows/amortizationRow.dart';
import '../common/components/texts/text1.dart';

/// Widget pentru afișarea graficului de amortizare a unui credit
/// 
/// Acest popup afișează un tabel cu informații detaliate despre fiecare rată lunară,
/// incluzând suma plătită, dobânda, principalul și soldul rămas.
class AmortizationPopup extends StatelessWidget {
  final List<AmortizationEntry> schedule;

  const AmortizationPopup({
    super.key,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 520, minHeight: 432),
        child: Container(
          width: 520,
          height: 432,
          padding: const EdgeInsets.all(AppTheme.smallGap),
          decoration: ShapeDecoration(
            color: AppTheme.popupBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              WidgetHeader1(
                title: 'Amortizare',
                titleColor: const Color(0xFF8A8AA8), // elementColor1
              ),
              SizedBox(height: AppTheme.smallGap),
              
              // Main content
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.smallGap),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFC4C4D4), // containerColor1
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      DynamicTextHeaderRow(
                        titles: ['Nr.', 'Rata', 'Dobândă', 'Principal', 'Sold'],
                        textColor: const Color(0xFF666699), // elementColor2
                        textAlign: TextAlign.left,
                        titleStyle: GoogleFonts.outfit(
                          color: Color(0xFF666699), // elementColor2
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        rowPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      
                      // Table content
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: ListView.separated(
                            itemCount: schedule.length,
                            separatorBuilder: (context, index) => 
                              const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final entry = schedule[index];
                              return DynamicTextDataRow(
                                values: [
                                  '${entry.paymentNumber}',
                                  entry.payment.toStringAsFixed(2),
                                  entry.interestPayment.toStringAsFixed(2),
                                  entry.principalPayment.toStringAsFixed(2),
                                  entry.remainingBalance.toStringAsFixed(2),
                                ],
                                rowBackgroundColor: const Color(0xFFACACD2), // containerColor2
                                rowBorderRadius: 16,
                                rowPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                textColor: const Color(0xFF4D4D80), // elementColor3
                                textAlign: TextAlign.left,
                                valueStyle: GoogleFonts.outfit(
                                  color: Color(0xFF4D4D80), // elementColor3
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
