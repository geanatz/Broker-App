import 'package:flutter/foundation.dart';
import '../services/clients_service.dart';
import 'ocr_logger.dart';
import 'parser_ocr.dart';

/// Service pentru transformarea contactelor detectate in modele client
/// Converteste simplu ContactDetection -> UnifiedClientModel
class TransformerOcr {
  /// Singleton instance
  static final TransformerOcr _instance = TransformerOcr._internal();
  factory TransformerOcr() => _instance;
  TransformerOcr._internal();

  final _logger = OcrDebugLogger();

  /// Transforma lista de contacte detectate in clienti unificati
  Future<List<UnifiedClientModel>> transformContactsToClients(
    List<ContactDetection> detectedContacts,
  ) async {
    _logger.addTransformationStep('--- Inceput Transformare ---');
    _logger.addTransformationStep('Input: ${detectedContacts.length} contacte detectate.');

    final clients = <UnifiedClientModel>[];

    for (int i = 0; i < detectedContacts.length; i++) {
      final contact = detectedContacts[i];
      
      try {
        // Valideaza contactul
        if (!_isValidContact(contact)) {
          _logger.addTransformationStep('⚠️ Contact invalid ignorat: Nume="${contact.name}", Tel1="${contact.phone1}", Tel2="${contact.phone2 ?? 'N/A'}"');
          continue;
        }

        // Creeaza client
        final client = _createClient(contact, i);
        clients.add(client);

        _logger.addTransformationStep('✅ Client creat: ${client.basicInfo.name} (${client.basicInfo.phoneNumber1})');

      } catch (e) {
        _logger.addTransformationStep('❌ Eroare la transformarea contactului ${contact.name}: $e');
      }
    }

    _logger.addTransformationStep('Output: ${clients.length} clienti creati.');
    _logger.addTransformationStep('--- Sfarsit Transformare ---');
    return clients;
  }

  /// Valideaza daca contactul este valid pentru conversie
  bool _isValidContact(ContactDetection contact) {
    // Nume valid (minim 2 caractere)
    if (contact.name.trim().length < 2) return false;
    
    // Telefon valid (exact 10 cifre, incepe cu 0)
    if (contact.phone1.length != 10 || !contact.phone1.startsWith('0')) return false;
    
    // Al doilea telefon (optional) trebuie sa fie valid daca exista
    if (contact.phone2 != null) {
      if (contact.phone2!.length != 10 || !contact.phone2!.startsWith('0')) return false;
    }

    return true;
  }

  /// Creeaza un client din contactul detectat
  UnifiedClientModel _createClient(ContactDetection contact, int index) {
    final now = DateTime.now();
    final formattedName = _formatName(contact.name);
    final phone1 = _formatPhone(contact.phone1);
    final phone2 = contact.phone2 != null ? _formatPhone(contact.phone2!) : null;
    final clientId = 'ocr_${now.millisecondsSinceEpoch}_$index';

    return UnifiedClientModel(
      id: clientId,
      consultantId: 'current_consultant', // Placeholder
      basicInfo: ClientBasicInfo(
        name: formattedName,
        phoneNumber1: phone1,
        phoneNumber2: phone2,
      ),
      formData: const ClientFormData(
        clientCredits: [],
        coDebitorCredits: [],
        clientIncomes: [],
        coDebitorIncomes: [],
        additionalData: {},
      ),
      activities: [
        ClientActivity(
          id: 'ocr_activity_${now.millisecondsSinceEpoch}_$index',
          type: ClientActivityType.other,
          dateTime: now,
          description: 'Client extras automat prin OCR (confidence: ${(contact.confidence * 100).toStringAsFixed(1)}%)',
          createdAt: now,
          additionalData: {
            'confidence': contact.confidence.toString(),
            'extraction_method': 'enhanced_ocr',
            'source': 'better_ocr_engine',
          },
        ),
      ],
      currentStatus: const UnifiedClientStatus(
        category: UnifiedClientCategory.apeluri,
        isFocused: false,
        additionalInfo: 'Extras prin OCR - necesita verificare',
      ),
      metadata: ClientMetadata(
        createdAt: now,
        updatedAt: now,
        createdBy: 'ocr_system',
        source: 'enhanced_ocr_extraction',
        version: 1,
      ),
    );
  }

  /// Formateaza numele (majuscula la inceput)
  String _formatName(String name) {
    return name.split(' ')
        .map((word) => word.isEmpty ? '' : 
             '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ')
        .trim();
  }

  /// Formateaza telefonul (pastreaza exact cum e)
  String _formatPhone(String phone) {
    return phone.trim();
  }
}

/// Statistici despre procesul de transformare
class TransformationStats {
  final int originalContacts;
  final int validContacts;
  final int createdClients;
  final int highConfidenceCount;
  final int mediumConfidenceCount;
  final int lowConfidenceCount;
  final int contactsWithTwoPhones;
  final double rejectionRate;

  const TransformationStats({
    required this.originalContacts,
    required this.validContacts,
    required this.createdClients,
    required this.highConfidenceCount,
    required this.mediumConfidenceCount,
    required this.lowConfidenceCount,
    required this.contactsWithTwoPhones,
    required this.rejectionRate,
  });

  @override
  String toString() {
    return 'TransformationStats(contacts: $originalContacts→$validContacts→$createdClients, '
           'confidence: H:$highConfidenceCount M:$mediumConfidenceCount L:$lowConfidenceCount, '
           'rejection: ${rejectionRate.toStringAsFixed(1)}%)';
  }
}

 