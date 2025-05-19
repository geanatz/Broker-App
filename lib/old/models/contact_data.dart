import 'package:flutter/foundation.dart' as foundation;

/// Enum pentru tipurile de contacte
enum ContactType {
  upcoming,  // Apeluri următoare
  recent     // Apeluri recente
}

/// Model de date pentru contacte în panel-ul de apeluri
class ContactData {
  /// ID unic pentru contact
  final String id;
  
  /// Numele contactului
  final String name;
  
  /// Numărul de telefon
  final String phone;
  
  /// Tipul contactului (upcoming sau recent)
  final ContactType type;
  
  /// ID-uri pentru formularele asociate acestui contact
  String? creditFormId;
  String? incomeFormId;
  
  /// Constructor
  ContactData({
    required this.id,
    required this.name,
    required this.phone,
    required this.type,
    this.creditFormId,
    this.incomeFormId,
  });
  
  /// Constructor pentru crearea unui contact gol
  factory ContactData.empty({required ContactType type}) {
    return ContactData(
      id: 'contact_${DateTime.now().millisecondsSinceEpoch}_${foundation.objectRuntimeType(ContactData, 'ContactData')}',
      name: '',
      phone: '',
      type: type,
    );
  }
  
  /// Verifică dacă contactul are formulare asociate
  bool hasAssociatedForms() {
    return creditFormId != null || incomeFormId != null;
  }
  
  /// Copiază contactul cu posibile modificări
  ContactData copyWith({
    String? name,
    String? phone,
    ContactType? type,
    String? creditFormId,
    String? incomeFormId,
  }) {
    return ContactData(
      id: this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      creditFormId: creditFormId ?? this.creditFormId,
      incomeFormId: incomeFormId ?? this.incomeFormId,
    );
  }
  
  @override
  String toString() {
    return 'ContactData{id: $id, name: $name, phone: $phone, type: $type, creditFormId: $creditFormId, incomeFormId: $incomeFormId}';
  }
} 