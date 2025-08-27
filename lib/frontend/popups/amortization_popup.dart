import 'package:mat_finance/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../backend/services/calculator_service.dart';

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
      child: Builder(
        builder: (context) {
          // Calculeaza inaltimea disponibila pentru a evita overflow
          final screenHeight = MediaQuery.of(context).size.height;
          final availableHeight = screenHeight * 0.7; // 70% din inaltimea ecranului
          final maxHeight = availableHeight.clamp(300.0, 500.0); // Intre 300-500 pixeli

          return ConstrainedBox(
            constraints: BoxConstraints(minWidth: 520, minHeight: maxHeight),
            child: Container(
              width: 520,
              height: maxHeight,
              padding: const EdgeInsets.all(8),
              decoration: ShapeDecoration(
                color: AppTheme.backgroundColor1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                shadows: AppTheme.popupShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section - table column headers
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

                  // Table section
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


