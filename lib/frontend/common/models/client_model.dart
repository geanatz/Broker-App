
/// Model pentru reprezentarea unui client și starea formularului său
class ClientModel {
  final String id;
  final String name;
  final String phoneNumber;
  final ClientStatus status;
  final ClientCategory category;
  
  // Datele formularului pentru acest client
  Map<String, dynamic> formData;
  
  ClientModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.status,
    required this.category,
    Map<String, dynamic>? formData,
  }) : formData = formData ?? {};
  
  /// Copiază clientul cu noi valori
  ClientModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    ClientStatus? status,
    ClientCategory? category,
    Map<String, dynamic>? formData,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      category: category ?? this.category,
      formData: formData ?? Map<String, dynamic>.from(this.formData),
    );
  }
  
  /// Actualizează datele formularului pentru acest client
  void updateFormData(String key, dynamic value) {
    formData[key] = value;
  }
  
  /// Obține o valoare din datele formularului
  T? getFormValue<T>(String key) {
    return formData[key] as T?;
  }
  
  /// Convertește obiectul ClientModel într-un Map pentru Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'status': status.index,
      'category': category.index,
      'formData': formData,
    };
  }
  
  /// Creează un ClientModel dintr-un Map din Firebase
  static ClientModel fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      status: ClientStatus.values[map['status'] ?? 0],
      category: ClientCategory.values[map['category'] ?? 0],
      formData: Map<String, dynamic>.from(map['formData'] ?? {}),
    );
  }
}

/// Statusul unui client (focusat sau normal)
enum ClientStatus {
  normal,   // LightItem7
  focused,  // DarkItem7
}

/// Categoria unui client (în ce secțiune se află)
enum ClientCategory {
  apeluri,   // Secțiunea "Apeluri"
  reveniri,  // Secțiunea "Reveniri" 
  recente,   // Secțiunea "Recente"
} 