import 'package:mat_finance/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../backend/services/calculator_service.dart';
// Import components
import '../components/headers/widget_header1.dart';

/// Widget pentru afisarea graficului de amortizare a unui credit
/// 
/// Acest popup afiseaza un tabel cu informatii detaliate despre fiecare rata lunara,
/// incluzand suma platita, dobanda, principalul si soldul ramas.
class AmortizationPopup extends StatelessWidget {
  final List<AmortizationEntry> schedule;

  const AmortizationPopup({
    super.key,
    required this.schedule,
  });

  /// Formateaza un numar cu virgula la fiecare 3 cifre, fara decimale
  String _formatNumber(double value) {
    final formatter = NumberFormat('#,###');
    return formatter.format(value.round());
  }

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
            color: AppTheme.backgroundColor1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
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
                  titleColor: AppTheme.elementColor1,
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
                    color: AppTheme.backgroundColor2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row - fara container colorat conform designului
                      Container(
                        width: double.infinity,
                        height: 21,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                  style: AppTheme.safeOutfit(
                                    color: AppTheme.elementColor2,
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
                                  'Rata',
                                  style: AppTheme.safeOutfit(
                                    color: AppTheme.elementColor2,
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
                                  style: AppTheme.safeOutfit(
                                    color: AppTheme.elementColor2,
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
                                  style: AppTheme.safeOutfit(
                                    color: AppTheme.elementColor2,
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
                                  style: AppTheme.safeOutfit(
                                    color: AppTheme.elementColor2,
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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: ShapeDecoration(
                                color: AppTheme.backgroundColor3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusTiny),
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
                                        style: AppTheme.safeOutfit(
                                          color: AppTheme.elementColor3,
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
                                        _formatNumber(entry.payment),
                                        style: AppTheme.safeOutfit(
                                          color: AppTheme.elementColor3,
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
                                        _formatNumber(entry.interestPayment),
                                        style: AppTheme.safeOutfit(
                                          color: AppTheme.elementColor3,
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
                                        _formatNumber(entry.principalPayment),
                                        style: AppTheme.safeOutfit(
                                          color: AppTheme.elementColor3,
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
                                        _formatNumber(entry.remainingBalance),
                                        style: AppTheme.safeOutfit(
                                          color: AppTheme.elementColor3,
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


