import 'package:flutter/material.dart';
import '../../backend/services/calculatorService.dart';
import '../common/appTheme.dart';

/// Widget pentru afișarea graficului de amortizare a unui credit
/// 
/// Acest popup afișează un tabel cu informații detaliate despre fiecare rată lunară,
/// incluzând suma plătită, dobânda, principalul și soldul rămas.
class AmortizationPopup extends StatelessWidget {
  final List<AmortizationEntry> schedule;

  const AmortizationPopup({
    Key? key,
    required this.schedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: 584,
        height: 608,
        padding: const EdgeInsets.all(AppTheme.smallGap),
        decoration: BoxDecoration(
          color: AppTheme.popupBackground,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: [AppTheme.widgetShadow],
        ),
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
                'Amortizare',
                style: AppTheme.headerTitleStyle,
              ),
            ),
            const SizedBox(height: AppTheme.smallGap),
            
            // Secțiunea de amortizare
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLightPurple,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                padding: const EdgeInsets.all(AppTheme.smallGap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header tabel
                    Container(
                      height: 24,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.mediumGap,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildHeaderText('Nr.', flex: 1),
                          _buildHeaderText('Suma', flex: 2),
                          _buildHeaderText('Dobândă', flex: 2),
                          _buildHeaderText('Principal', flex: 2),
                          _buildHeaderText('Sold', flex: 2),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.smallGap),
                    
                    // Lista de intrări
                    Expanded(
                      child: ListView.separated(
                        itemCount: schedule.length,
                        separatorBuilder: (context, index) => 
                          const SizedBox(height: AppTheme.smallGap),
                        itemBuilder: (context, index) {
                          final entry = schedule[index];
                          return _buildAmortizationRow(entry);
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
    );
  }

  // Construiește textul header-ului
  Widget _buildHeaderText(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTheme.smallTextStyle.copyWith(
          color: AppTheme.fontMediumPurple,
        ),
      ),
    );
  }

  // Construiește un rând din graficul de amortizare
  Widget _buildAmortizationRow(AmortizationEntry entry) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFACACD3), // Culoarea specificată în design
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.mediumGap,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildEntryText('${entry.paymentNumber}', flex: 1),
          _buildEntryText('${entry.payment.toStringAsFixed(2)}', flex: 2),
          _buildEntryText('${entry.interestPayment.toStringAsFixed(2)}', flex: 2),
          _buildEntryText('${entry.principalPayment.toStringAsFixed(2)}', flex: 2),
          _buildEntryText('${entry.remainingBalance.toStringAsFixed(2)}', flex: 2),
        ],
      ),
    );
  }

  // Construiește textul din celula unui rând
  Widget _buildEntryText(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTheme.secondaryTitleStyle.copyWith(
          color: AppTheme.fontDarkPurple,
        ),
      ),
    );
  }
}
