import 'dart:math';
import 'package:broker_app/backend/services/form_service.dart';
import 'package:broker_app/backend/services/clients_service.dart';

/// Serviciul pentru calculare credite
/// 
/// Acest serviciu ofera functionalitatea de calcul pentru credite si 
/// generarea graficului de amortizare
class CalculatorService {
  static final FormService _formService = FormService();
  static final ClientUIService _clientService = ClientUIService();

  /// Calculeaza rata lunara pentru un credit
  /// 
  /// [principal] - suma imprumutata (principal)
  /// [interestRate] - rata dobanzii anuala (in procente, ex: 5.5 pentru 5.5%)
  /// [loanTermMonths] - durata creditului in luni
  /// 
  /// Returneaza rata lunara calculata
  static double calculateMonthlyPayment({
    required double principal,
    required double interestRate,
    required int loanTermMonths,
  }) {
    // Convertim rata dobanzii anuale in rata lunara (si din procente in zecimala)
    final double monthlyRate = interestRate / 100 / 12;
    
    // Daca rata dobanzii este 0, returnam simpla impartire a principalului la numarul de luni
    if (monthlyRate == 0) {
      return principal / loanTermMonths;
    }
    
    // Folosim formula standard pentru calculul ratei lunare
    // M = P * [r(1+r)^n] / [(1+r)^n - 1]
    // unde M = plata lunara, P = principal, r = rata lunara, n = numarul de luni
    final double numerator = monthlyRate * pow(1 + monthlyRate, loanTermMonths);
    final double denominator = pow(1 + monthlyRate, loanTermMonths) - 1;
    
    return principal * (numerator / denominator);
  }
  
  /// Calculeaza costul total al creditului
  /// 
  /// [principal] - suma imprumutata
  /// [monthlyPayment] - rata lunara calculata
  /// [loanTermMonths] - durata creditului in luni
  /// 
  /// Returneaza costul total (suma tuturor platilor)
  static double calculateTotalCost({
    required double monthlyPayment,
    required int loanTermMonths,
  }) {
    return monthlyPayment * loanTermMonths;
  }
  
  /// Calculeaza dobanda totala platita
  /// 
  /// [totalCost] - costul total al creditului
  /// [principal] - suma imprumutata initial
  /// 
  /// Returneaza dobanda totala platita
  static double calculateTotalInterest({
    required double totalCost,
    required double principal,
  }) {
    return totalCost - principal;
  }

  /// Calculeaza 40% din totalul veniturilor pentru clientul activ
  /// 
  /// Returneaza 40% din suma tuturor veniturilor (client + codebitor)
  static double calculateIncomePercentage() {
    final currentClient = _clientService.focusedClient;
    if (currentClient == null) {
      return 0;
    }
    
    double totalIncome = 0;
    
    // Obtine veniturile clientului
    final clientIncomeForms = _formService.getClientIncomeForms(currentClient.phoneNumber);
    for (final form in clientIncomeForms) {
      if (form.incomeAmount.isNotEmpty && !form.isEmpty) {
        final amount = double.tryParse(form.incomeAmount.replaceAll(',', '')) ?? 0;
        totalIncome += amount;
      }
    }
    
    // Obtine veniturile codebitorului
    final coborrowerIncomeForms = _formService.getCoborrowerIncomeForms(currentClient.phoneNumber);
    for (final form in coborrowerIncomeForms) {
      if (form.incomeAmount.isNotEmpty && !form.isEmpty) {
        final amount = double.tryParse(form.incomeAmount.replaceAll(',', '')) ?? 0;
        totalIncome += amount;
      }
    }
    
    // Calculeaza 40% din total
    return totalIncome * 0.4;
  }
  
  /// Genereaza graficul de amortizare pentru un credit
  /// 
  /// [principal] - suma imprumutata
  /// [interestRate] - rata dobanzii anuala (in procente)
  /// [loanTermMonths] - durata creditului in luni
  /// 
  /// Returneaza o lista de intrari pentru graficul de amortizare, fiecare intrare continand:
  /// - numarul ratei
  /// - suma platita (rata lunara)
  /// - dobanda platita in acea luna
  /// - principalul platit in acea luna
  /// - soldul ramas dupa plata
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
      // Calculeaza dobanda pentru luna curenta (sold * rata lunara)
      double interestPayment = balance * monthlyRate;
      
      // Calculeaza cat din rata merge catre principal (rata lunara - dobanda lunara)
      double principalPayment = monthlyPayment - interestPayment;
      
      // Actualizeaza soldul
      balance -= principalPayment;
      
      // Ne asiguram ca la ultima rata soldul ajunge la 0 (pentru a evita diferente minime datorate rotunjirii)
      if (i == loanTermMonths) {
        principalPayment += balance;
        balance = 0;
      }
      
      // Adauga intrarea in graficul de amortizare
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

/// Clasa pentru o intrare in graficul de amortizare
class AmortizationEntry {
  final int paymentNumber;      // Numarul ratei
  final double payment;         // Rata lunara
  final double interestPayment; // Portiunea din rata care reprezinta dobanda
  final double principalPayment; // Portiunea din rata care reduce principalul
  final double remainingBalance; // Soldul ramas dupa plata
  
  const AmortizationEntry({
    required this.paymentNumber,
    required this.payment,
    required this.interestPayment,
    required this.principalPayment,
    required this.remainingBalance,
  });
}
