import 'dart:collection';
import 'package:flutter/material.dart';

import '../models/contact_data.dart';
import '../models/form_data.dart';

/// Service pentru gestionarea contactelor și formularelor asociate
class ContactFormService {
  // Singleton pattern
  static final ContactFormService _instance = ContactFormService._internal();
  
  factory ContactFormService() {
    return _instance;
  }
  
  ContactFormService._internal();
  
  // Storage for contacts
  final List<ContactData> _upcomingContacts = [];
  final List<ContactData> _recentContacts = [];
  
  // Maps to store form data by contact ID
  final Map<String, List<CreditFormData>> _creditForms = HashMap<String, List<CreditFormData>>();
  final Map<String, List<IncomeFormData>> _incomeForms = HashMap<String, List<IncomeFormData>>();
  
  // Getters for contacts
  List<ContactData> get upcomingContacts => List.unmodifiable(_upcomingContacts);
  List<ContactData> get recentContacts => List.unmodifiable(_recentContacts);
  
  /// Initialize contacts for demo
  void initializeDemoData() {
    // Clear existing data
    _upcomingContacts.clear();
    _recentContacts.clear();
    _creditForms.clear();
    _incomeForms.clear();
    
    // Create upcoming contacts
    for (int i = 0; i < 5; i++) {
      final contact = ContactData(
        id: 'upcoming_$i',
        name: 'Contact apel ${i + 1}',
        phone: '07${i + 1}2 345 678',
        type: ContactType.upcoming,
      );
      _upcomingContacts.add(contact);
      
      // Create an empty credit and income form for each contact
      _creditForms[contact.id] = [CreditFormData.empty()];
      _incomeForms[contact.id] = [IncomeFormData.empty()];
    }
    
    // Create recent contacts
    for (int i = 0; i < 6; i++) {
      final contact = ContactData(
        id: 'recent_$i',
        name: 'Contact recent ${i + 1}',
        phone: '07${i + 5}2 345 678',
        type: ContactType.recent,
      );
      _recentContacts.add(contact);
      
      // Create an empty credit and income form for each contact
      _creditForms[contact.id] = [CreditFormData.empty()];
      _incomeForms[contact.id] = [IncomeFormData.empty()];
    }
  }
  
  /// Get credit forms for a specific contact
  List<CreditFormData> getCreditForms(String contactId) {
    return _creditForms[contactId] ?? [CreditFormData.empty()];
  }
  
  /// Get income forms for a specific contact
  List<IncomeFormData> getIncomeForms(String contactId) {
    return _incomeForms[contactId] ?? [IncomeFormData.empty()];
  }
  
  /// Update or add a credit form
  void updateCreditForm(String contactId, CreditFormData formData) {
    if (!_creditForms.containsKey(contactId)) {
      _creditForms[contactId] = [formData];
      return;
    }
    
    // Find if form with this ID already exists
    final index = _creditForms[contactId]!.indexWhere((form) => form.id == formData.id);
    if (index >= 0) {
      _creditForms[contactId]![index] = formData;
    } else {
      _creditForms[contactId]!.add(formData);
    }
  }
  
  /// Update or add an income form
  void updateIncomeForm(String contactId, IncomeFormData formData) {
    if (!_incomeForms.containsKey(contactId)) {
      _incomeForms[contactId] = [formData];
      return;
    }
    
    // Find if form with this ID already exists
    final index = _incomeForms[contactId]!.indexWhere((form) => form.id == formData.id);
    if (index >= 0) {
      _incomeForms[contactId]![index] = formData;
    } else {
      _incomeForms[contactId]!.add(formData);
    }
  }
  
  /// Remove a credit form
  void removeCreditForm(String contactId, String formId) {
    if (!_creditForms.containsKey(contactId)) return;
    
    _creditForms[contactId]!.removeWhere((form) => form.id == formId);
    
    // Ensure there's always at least one form
    if (_creditForms[contactId]!.isEmpty) {
      _creditForms[contactId]!.add(CreditFormData.empty());
    }
  }
  
  /// Remove an income form
  void removeIncomeForm(String contactId, String formId) {
    if (!_incomeForms.containsKey(contactId)) return;
    
    _incomeForms[contactId]!.removeWhere((form) => form.id == formId);
    
    // Ensure there's always at least one form
    if (_incomeForms[contactId]!.isEmpty) {
      _incomeForms[contactId]!.add(IncomeFormData.empty());
    }
  }
  
  /// Prepare data for exporting to Excel
  Map<String, dynamic> prepareDataForExport() {
    final result = <String, dynamic>{};
    
    // Combine upcoming and recent contacts
    final allContacts = [..._upcomingContacts, ..._recentContacts];
    
    for (final contact in allContacts) {
      final contactData = <String, dynamic>{
        'name': contact.name,
        'phone': contact.phone,
        'type': contact.type.toString(),
        'credits': _creditForms[contact.id]?.where((form) => !form.isEmpty).toList() ?? [],
        'incomes': _incomeForms[contact.id]?.where((form) => !form.isEmpty).toList() ?? [],
      };
      
      result[contact.id] = contactData;
    }
    
    return result;
  }
  
  /// TODO: Implementează funcția pentru exportarea în Excel
  Future<bool> exportToExcel() async {
    // This would be implemented with a package like 'excel' to create XLSX files
    // For now, we'll just print the data
    final data = prepareDataForExport();
    debugPrint('Exportăm date pentru ${data.length} contacte:');
    
    data.forEach((contactId, contactData) {
      debugPrint('Contact: ${contactData['name']} (${contactData['phone']})');
      
      final credits = contactData['credits'] as List;
      debugPrint('  Credite: ${credits.length}');
      
      final incomes = contactData['incomes'] as List;
      debugPrint('  Venituri: ${incomes.length}');
    });
    
    return true;
  }
} 