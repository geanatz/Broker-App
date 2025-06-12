import 'dart:math';
import 'package:broker_app/backend/services/form_service.dart';
import 'package:broker_app/backend/services/clients_service.dart';

/// Serviciul pentru calculare credite
/// 
/// Acest serviciu oferă funcționalitatea de calcul pentru credite și 
/// generarea graficului de amortizare
class CalculatorService {
  static final FormService _formService = FormService();
  static final ClientUIService _clientService = ClientUIService();

  /// Calculează rata lunară pentru un credit
  /// 
  /// [principal] - suma împrumutată (principal)
  /// [interestRate] - rata dobânzii anuală (în procente, ex: 5.5 pentru 5.5%)
  /// [loanTermMonths] - durata creditului în luni
  /// 
  /// Returnează rata lunară calculată
  static double calculateMonthlyPayment({
    required double principal,
    required double interestRate,
    required int loanTermMonths,
  }) {
    // Convertim rata dobânzii anuale în rată lunară (și din procente în zecimală)
    final double monthlyRate = interestRate / 100 / 12;
    
    // Dacă rata dobânzii este 0, returnăm simpla împărțire a principalului la numărul de luni
    if (monthlyRate == 0) {
      return principal / loanTermMonths;
    }
    
    // Folosim formula standard pentru calculul ratei lunare
    // M = P * [r(1+r)^n] / [(1+r)^n - 1]
    // unde M = plata lunară, P = principal, r = rata lunară, n = numărul de luni
    final double numerator = monthlyRate * pow(1 + monthlyRate, loanTermMonths);
    final double denominator = pow(1 + monthlyRate, loanTermMonths) - 1;
    
    return principal * (numerator / denominator);
  }
  
  /// Calculează costul total al creditului
  /// 
  /// [principal] - suma împrumutată
  /// [monthlyPayment] - rata lunară calculată
  /// [loanTermMonths] - durata creditului în luni
  /// 
  /// Returnează costul total (suma tuturor plăților)
  static double calculateTotalCost({
    required double monthlyPayment,
    required int loanTermMonths,
  }) {
    return monthlyPayment * loanTermMonths;
  }
  
  /// Calculează dobânda totală plătită
  /// 
  /// [totalCost] - costul total al creditului
  /// [principal] - suma împrumutată inițial
  /// 
  /// Returnează dobânda totală plătită
  static double calculateTotalInterest({
    required double totalCost,
    required double principal,
  }) {
    return totalCost - principal;
  }

  /// Calculează 40% din totalul veniturilor pentru clientul activ
  /// 
  /// Returnează 40% din suma tuturor veniturilor (client + codebitor)
  static double calculateIncomePercentage() {
    final currentClient = _clientService.focusedClient;
    if (currentClient == null) {
      return 0;
    }
    
    double totalIncome = 0;
    
    // Obține veniturile clientului
    final clientIncomeForms = _formService.getClientIncomeForms(currentClient.phoneNumber);
    for (final form in clientIncomeForms) {
      if (form.incomeAmount.isNotEmpty && !form.isEmpty) {
        final amount = double.tryParse(form.incomeAmount.replaceAll(',', '')) ?? 0;
        totalIncome += amount;
      }
    }
    
    // Obține veniturile codebitorului
    final coborrowerIncomeForms = _formService.getCoborrowerIncomeForms(currentClient.phoneNumber);
    for (final form in coborrowerIncomeForms) {
      if (form.incomeAmount.isNotEmpty && !form.isEmpty) {
        final amount = double.tryParse(form.incomeAmount.replaceAll(',', '')) ?? 0;
        totalIncome += amount;
      }
    }
    
    // Calculează 40% din total
    return totalIncome * 0.4;
  }
  
  /// Generează graficul de amortizare pentru un credit
  /// 
  /// [principal] - suma împrumutată
  /// [interestRate] - rata dobânzii anuală (în procente)
  /// [loanTermMonths] - durata creditului în luni
  /// 
  /// Returnează o listă de intrări pentru graficul de amortizare, fiecare intrare conținând:
  /// - numărul ratei
  /// - suma plătită (rata lunară)
  /// - dobânda plătită în acea lună
  /// - principalul plătit în acea lună
  /// - soldul rămas după plată
  static List<AmortizationEntry> generateAmortizationSchedule({
    required double principal,
    required double interestRate,
    required int loanTermMonths,
  }) {
    List<AmortizationEntry> schedule = [];
    double balance = principal;
    double monthlyRate = interestRate / 100 / 12;
    double monthlyPayment = calculateMonthlyPayment(
      principal: principal,
      interestRate: interestRate,
      loanTermMonths: loanTermMonths,
    );
    
    for (int i = 1; i <= loanTermMonths; i++) {
      // Calculează dobânda pentru luna curentă (sold * rata lunară)
      double interestPayment = balance * monthlyRate;
      
      // Calculează cât din rată merge către principal (rata lunară - dobânda lunară)
      double principalPayment = monthlyPayment - interestPayment;
      
      // Actualizează soldul
      balance -= principalPayment;
      
      // Ne asigurăm că la ultima rată soldul ajunge la 0 (pentru a evita diferențe minime datorate rotunjirii)
      if (i == loanTermMonths) {
        principalPayment += balance;
        balance = 0;
      }
      
      // Adaugă intrarea în graficul de amortizare
      schedule.add(AmortizationEntry(
        paymentNumber: i,
        payment: monthlyPayment,
        interestPayment: interestPayment,
        principalPayment: principalPayment,
        remainingBalance: balance,
      ));
    }
    
    return schedule;
  }
}

/// Clasa pentru o intrare în graficul de amortizare
class AmortizationEntry {
  final int paymentNumber;      // Numărul ratei
  final double payment;         // Rata lunară
  final double interestPayment; // Porțiunea din rată care reprezintă dobânda
  final double principalPayment; // Porțiunea din rată care reduce principalul
  final double remainingBalance; // Soldul rămas după plată
  
  const AmortizationEntry({
    required this.paymentNumber,
    required this.payment,
    required this.interestPayment,
    required this.principalPayment,
    required this.remainingBalance,
  });
}
