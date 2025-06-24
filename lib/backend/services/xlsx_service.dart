import 'package:flutter/material.dart';
import 'package:broker_app/backend/services/sheets_service.dart';

class ExcelExportService {
  static final ExcelExportService _instance = ExcelExportService._internal();
  factory ExcelExportService() => _instance;
  ExcelExportService._internal();

  final GoogleDriveService _googleDriveService = GoogleDriveService();


  /// Salveaza un singur client in Google Sheets
  /// Foloseste Google Drive daca este conectat, altfel afiseaza eroare
  Future<String?> saveClientToXlsx(dynamic client) async {
    try {
      if (!_googleDriveService.isAuthenticated) {
        debugPrint('⚠️ XLSX_SERVICE: Nu este conectat la Google Drive');
        return 'Pentru a salva datele în Excel, conectați-vă la Google Drive din Setări';
      }
      
      if (_googleDriveService.assignedSheetId == null) {
        debugPrint('⚠️ XLSX_SERVICE: Nu este setat Google Sheet-ul în Google Drive');
        return 'Nu aveți un Google Sheet assignat. Mergeți la Setări > Google Drive pentru a seta sheet-ul';
      }
      
      // Pregătește datele clientului pentru salvare
      final clientData = _prepareClientData(client);
      debugPrint('🔍 XLSX_SERVICE: Original client data: $client');
      debugPrint('🔍 XLSX_SERVICE: Prepared client data: $clientData');
      
      // Salvează în Google Sheets
      final success = await _googleDriveService.saveClientToSheet(clientData);
      
      if (success) {
        debugPrint('✅ XLSX_SERVICE: Client salvat cu succes în Google Sheets');
        return null; // Success
      } else {
        final error = _googleDriveService.lastError ?? 'Eroare necunoscută';
        debugPrint('❌ XLSX_SERVICE: Eroare la salvarea în Google Sheets: $error');
        return 'Eroare la salvarea în Google Sheets: $error';
      }
      
    } catch (e) {
      debugPrint('❌ XLSX_SERVICE: Eroare la salvarea clientului: $e');
      return 'Eroare la salvarea clientului: ${e.toString()}';
    }
  }

  /// Pregătește datele clientului în formatul potrivit pentru Google Sheets
  Map<String, dynamic> _prepareClientData(dynamic client) {
    debugPrint('🔍 XLSX_SERVICE: Preparing client data for type: ${client.runtimeType}');
    
    // Verifică tipul clientului și extrage datele corespunzătoare
    if (client is Map<String, dynamic>) {
      // Dacă e deja Map, mapează cheile la formatul așteptat
      return {
        'nume': client['name'] ?? client['nume'] ?? '',
        'telefon': client['phoneNumber'] ?? client['phoneNumber1'] ?? client['telefon'] ?? '',
        'cnp': client['cnp'] ?? '', // ClientModel nu are CNP
        'email': client['email'] ?? '', // ClientModel nu are email
        'adresa': client['adresa'] ?? '', // ClientModel nu are adresa
        'status': client['discussionStatus'] ?? client['status'] ?? '',
        'dataContact': client['dataContact'] ?? DateTime.now().toIso8601String(),
        'consultant': client['consultantName'] ?? client['consultant'] ?? 'Consultant',
        'observatii': client['additionalInfo'] ?? client['observatii'] ?? '',
        'tipCredit': client['tipCredit'] ?? '',
        'sumasolicitata': client['sumasolicitata'] ?? '',
        'venitLunar': client['venitLunar'] ?? '',
        'bancaRecomandata': client['bancaRecomandata'] ?? '',
      };
    }
    
    // Dacă este un obiect ClientModel, convertește-l în Map cu cheile corecte
    // Încearcă să extragă date din formData dacă există
    String tipCredit = '';
    String sumasolicitata = '';
    String venitLunar = '';
    String bancaRecomandata = '';
    
    // Extrage informații din formData dacă ClientModel are aceste date
    if (client.formData != null && client.formData.isNotEmpty) {
      // Caută primul credit din formData pentru tipCredit și suma
      for (String key in client.formData.keys) {
        if (key.contains('_client_credit_') && key.endsWith('_creditType')) {
          tipCredit = client.formData[key]?.toString() ?? '';
          break;
        }
      }
      
      // Caută suma solicitată
      for (String key in client.formData.keys) {
        if (key.contains('_client_credit_') && key.endsWith('_sold')) {
          sumasolicitata = client.formData[key]?.toString() ?? '';
          break;
        }
      }
      
      // Caută venitul lunar
      for (String key in client.formData.keys) {
        if (key.contains('_client_income_') && key.endsWith('_incomeAmount')) {
          venitLunar = client.formData[key]?.toString() ?? '';
          break;
        }
      }
    }
    
    return {
      'nume': client.name ?? '',
      'telefon': client.phoneNumber1 ?? '',
      'cnp': '', // ClientModel nu are CNP
      'email': '', // ClientModel nu are email
      'adresa': '', // ClientModel nu are adresa
      'status': client.discussionStatus ?? '',
      'dataContact': DateTime.now().toIso8601String(),
      'consultant': 'Consultant',
      'observatii': client.additionalInfo ?? '',
      'tipCredit': tipCredit,
      'sumasolicitata': sumasolicitata,
      'venitLunar': venitLunar,
      'bancaRecomandata': bancaRecomandata,
    };
  }



  /// Exporta toate datele clientilor in format XLSX
  Future<String?> exportAllClientsToXlsx() async {
    try {
      debugPrint('📊 ExcelExportService: Exportul tuturor clienților temporar dezactivat');
      debugPrint('⚠️ Necesită refactorizare pentru noua structură');
      return null;
    } catch (e) {
      debugPrint('❌ Eroare la exportul XLSX: $e');
      return null;
    }
  }



















  /// Obtine lista de luni disponibile pentru export
  Future<List<String>> getAvailableMonths() async {
    try {
      debugPrint('⚠️ getAvailableMonths temporar dezactivat - necesită refactorizare');
      return [];
    } catch (e) {
      debugPrint('❌ Eroare la obtinerea lunilor disponibile: $e');
      return [];
    }
  }

  /// Exporta doar clientii dintr-o luna specifica
  Future<String?> exportClientsForMonth(String monthName) async {
    try {
      debugPrint('⚠️ exportClientsForMonth temporar dezactivat - necesită refactorizare');
      return null;
    } catch (e) {
      debugPrint('❌ Eroare la exportul pentru luna $monthName: $e');
      return null;
    }
  }

} 
