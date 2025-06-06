/// Model pentru reprezentarea unui client și starea formularului său
class ClientModel {
  final String id;
  final String name;
  final String phoneNumber1;
  final String? phoneNumber2;
  final String? coDebitorName;
  final ClientStatus status;
  final ClientCategory category;
  
  // Datele formularului pentru acest client
  Map<String, dynamic> formData;
  
  // Statusul discuției cu clientul
  final String? discussionStatus; // 'Acceptat', 'Amanat', 'Refuzat'
  
  // Data și ora pentru amânare sau întâlnire
  final DateTime? scheduledDateTime;
  
  // Informații adiționale despre discuție
  final String? additionalInfo;
  
  ClientModel({
    required this.id,
    required this.name,
    required this.phoneNumber1,
    this.phoneNumber2,
    this.coDebitorName,
    required this.status,
    required this.category,
    Map<String, dynamic>? formData,
    this.discussionStatus,
    this.scheduledDateTime,
    this.additionalInfo,
  }) : formData = formData ?? {};

  /// Pentru compatibilitate cu codul existent
  String get phoneNumber => phoneNumber1;
  
  /// Copiază clientul cu noi valori
  ClientModel copyWith({
    String? id,
    String? name,
    String? phoneNumber1,
    String? phoneNumber2,
    String? coDebitorName,
    ClientStatus? status,
    ClientCategory? category,
    Map<String, dynamic>? formData,
    String? discussionStatus,
    DateTime? scheduledDateTime,
    String? additionalInfo,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber1: phoneNumber1 ?? this.phoneNumber1,
      phoneNumber2: phoneNumber2 ?? this.phoneNumber2,
      coDebitorName: coDebitorName ?? this.coDebitorName,
      status: status ?? this.status,
      category: category ?? this.category,
      formData: formData ?? Map<String, dynamic>.from(this.formData),
      discussionStatus: discussionStatus ?? this.discussionStatus,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      additionalInfo: additionalInfo ?? this.additionalInfo,
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
      'phoneNumber1': phoneNumber1,
      'phoneNumber2': phoneNumber2,
      'coDebitorName': coDebitorName,
      'status': status.index,
      'category': category.index,
      'formData': formData,
      'discussionStatus': discussionStatus,
      'scheduledDateTime': scheduledDateTime?.millisecondsSinceEpoch,
      'additionalInfo': additionalInfo,
    };
  }

  /// Creează un ClientModel dintr-un Map din Firebase
  static ClientModel fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phoneNumber1: map['phoneNumber1'] ?? map['phoneNumber'] ?? '', // Fallback pentru backward compatibility
      phoneNumber2: map['phoneNumber2'],
      coDebitorName: map['coDebitorName'],
      status: ClientStatus.values[map['status'] ?? 0],
      category: ClientCategory.values[map['category'] ?? 0],
      formData: Map<String, dynamic>.from(map['formData'] ?? {}),
      discussionStatus: map['discussionStatus'],
      scheduledDateTime: map['scheduledDateTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['scheduledDateTime'])
          : null,
      additionalInfo: map['additionalInfo'],
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