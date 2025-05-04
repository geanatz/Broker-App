import 'package:flutter/foundation.dart' as foundation;
// import 'package:flutter/material.dart'; // No longer needed

import '../widgets/form/credit_form_widget.dart';
import '../widgets/form/income_form_widget.dart';

/// Base class for form data
class BaseFormData {
  final String id;
  bool isEmpty;
  String? selectedBank;

  BaseFormData({
    required this.id,
    this.isEmpty = true,
    this.selectedBank,
  });
}

/// Data model for Credit Form
class CreditFormData extends BaseFormData {
  CreditType? selectedCreditType;
  String sold; // Using String to easily integrate with TextEditingController
  String consumat; // Specific to Card/Overdraft
  String rata; // Specific to Nevoi/Ipotecar/PrimaCasa
  String perioada; // Specific to Nevoi/Ipotecar/PrimaCasa
  String? selectedRateType; // Specific to Ipotecar/PrimaCasa

  CreditFormData({
    required String id,
    bool isEmpty = true,
    String? selectedBank,
    this.selectedCreditType,
    this.sold = '',
    this.consumat = '',
    this.rata = '',
    this.perioada = '',
    this.selectedRateType,
  }) : super(id: id, isEmpty: isEmpty, selectedBank: selectedBank);

  // Check if the essential fields that define a "filled" form are set
  bool isFilled() {
    return selectedBank != null && selectedCreditType != null;
  }

  // Method to update from another CreditFormData instance
  void updateFrom(CreditFormData other) {
    selectedBank = other.selectedBank;
    selectedCreditType = other.selectedCreditType;
    sold = other.sold;
    consumat = other.consumat;
    rata = other.rata;
    perioada = other.perioada;
    selectedRateType = other.selectedRateType;
    
    // Update isEmpty based on essential fields
    isEmpty = !isFilled();
  }

  @override
  String toString() {
    return 'CreditFormData{id: $id, isEmpty: $isEmpty, bank: $selectedBank, type: $selectedCreditType}';
  }

  // Factory constructor for creating an empty form data
  factory CreditFormData.empty() {
    // Use foundation.objectRuntimeType
    return CreditFormData(id: 'form_${DateTime.now().millisecondsSinceEpoch}_${foundation.objectRuntimeType(CreditFormData, 'CreditFormData')}');
  }
}

/// Data model for Income Form
class IncomeFormData extends BaseFormData {
  IncomeType? selectedIncomeType;
  String income; // Using String
  String vechime; // Using String

  IncomeFormData({
    required String id,
    bool isEmpty = true,
    String? selectedBank,
    this.selectedIncomeType,
    this.income = '',
    this.vechime = '',
  }) : super(id: id, isEmpty: isEmpty, selectedBank: selectedBank);

  // Check if essential fields are set
  bool isFilled() {
    return selectedBank != null && selectedIncomeType != null;
  }

  // Method to update from another IncomeFormData instance
  void updateFrom(IncomeFormData other) {
    selectedBank = other.selectedBank;
    selectedIncomeType = other.selectedIncomeType;
    income = other.income;
    vechime = other.vechime;
    
    // Update isEmpty based on essential fields
    isEmpty = !isFilled();
  }

  @override
  String toString() {
    return 'IncomeFormData{id: $id, isEmpty: $isEmpty, bank: $selectedBank, type: $selectedIncomeType}';
  }

  // Factory constructor for creating an empty form data
  factory IncomeFormData.empty() {
    // Use foundation.objectRuntimeType
    return IncomeFormData(id: 'form_${DateTime.now().millisecondsSinceEpoch}_${foundation.objectRuntimeType(IncomeFormData, 'IncomeFormData')}');
  }
} 