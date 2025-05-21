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
          padding: const EdgeInsets.all(8),
          decoration: ShapeDecoration(
            color: AppTheme.popupBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: WidgetHeader1(
                  title: 'Amortizare',
                  titleColor: const Color(0xFF8A8AA8), // elementColor1
                  padding: EdgeInsets.zero,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Main content
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
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
                      // Header row - using a custom row that matches the Figma design
                      Container(
                        width: double.infinity,
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFACACD2), // containerColor2 - lighter purple for header
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                height: 21,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Luna',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF666699), // elementColor2
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 21,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Suma',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF666699), // elementColor2
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 21,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Dobanda',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF666699), // elementColor2
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 21,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Principal',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF666699), // elementColor2
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 21,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Sold',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF666699), // elementColor2
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Table content
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: schedule.length,
                          separatorBuilder: (context, index) => 
                            const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final entry = schedule[index];
                            return Container(
                              width: double.infinity,
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFACACD2), // containerColor2
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 21,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '${entry.paymentNumber}',
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFF4D4D80), // elementColor3
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 21,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        entry.payment.toStringAsFixed(2),
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFF4D4D80), // elementColor3
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 21,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        entry.interestPayment.toStringAsFixed(2),
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFF4D4D80), // elementColor3
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 21,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        entry.principalPayment.toStringAsFixed(2),
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFF4D4D80), // elementColor3
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 21,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        entry.remainingBalance.toStringAsFixed(2),
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFF4D4D80), // elementColor3
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
