import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'clients_service.dart';

class ExcelExportService {
static final ExcelExportService _instance = ExcelExportService._internal();
factory ExcelExportService() => _instance;
ExcelExportService._internal();

final ClientsFirebaseService _clientsService = ClientsFirebaseService();

/// Salvează un singur client în fișierul "clienti.xlsx"
 /// Dacă fișierul există, îl editează. Dacă nu există, îl creează.
 Future<String?> saveClientToXlsx(UnifiedClientModel client) async {
try {
debugPrint('📊 ExcelExportService: Salvez clientul ${client.basicInfo.name}...');

// Obține calea către fișierul "clienti.xlsx"
final directory = await getApplicationDocumentsDirectory();
final filePath = '${directory.path}/clienti.xlsx';
final file = File(filePath);

Excel excel;

// Verifică dacă fișierul există
if (await file.exists()) {
debugPrint('📊 Fișierul clienti.xlsx există, îl editez...');
// Încarcă fișierul existent
final bytes = await file.readAsBytes();
excel = Excel.decodeBytes(bytes);

// Șterge Sheet1 dacă încă există
if (excel.sheets.containsKey('Sheet1')) {
excel.delete('Sheet1');
}
} else {
debugPrint('📊 Fișierul clienti.xlsx nu există, îl creez...');
        // Creează un fișier nou
        // Creează un fișier nou fără Sheet1
excel = Excel.createExcel();
        // Șterge sheet-ul implicit
        excel.delete('Sheet1');
        // Șterge sheet-ul implicit și toate sheet-urile existente
        final sheetsToDelete = List<String>.from(excel.sheets.keys);
        for (final sheetName in sheetsToDelete) {
          excel.delete(sheetName);
        }
}

// Determină luna pentru client
@@ -65,11 +68,11 @@
final existingRowIndex = _findClientRowInSheet(sheet, client);

if (existingRowIndex != -1) {
        debugPrint('📊 Clientul există deja, actualizez linia $existingRowIndex');
        debugPrint('📊 ACTUALIZARE: Clientul ${client.basicInfo.name} există deja pe linia $existingRowIndex - se actualizează datele');
// Actualizează linia existentă
_addClientRow(sheet, client, existingRowIndex);
} else {
        debugPrint('📊 Client nou, îl adaug la sfârșitul listei');
        debugPrint('📊 CLIENT NOU: ${client.basicInfo.name} va fi adăugat pe un rând nou');
// Adaugă la sfârșitul listei
final nextRowIndex = _getNextAvailableRow(sheet);
_addClientRow(sheet, client, nextRowIndex);
@@ -105,15 +108,19 @@

// Verifică dacă numele și telefonul se potrivesc
if (nameCell.value != null && phoneCell.value != null) {
        final cellName = nameCell.value.toString();
        final cellPhone = phoneCell.value.toString();
        final cellName = nameCell.value.toString().trim();
        final cellPhone = phoneCell.value.toString().trim();

        if (cellName == client.basicInfo.name && cellPhone == client.basicInfo.phoneNumber1) {
        // Potrivire bazată pe telefon (criteriul principal) și nume
        if (cellPhone == client.basicInfo.phoneNumber1.trim() && 
            cellName == client.basicInfo.name.trim()) {
          debugPrint('📊 Găsit client existent: $cellName ($cellPhone) pe rândul $row');
return row;
}
}
}

    debugPrint('📊 Client nou, nu există în sheet: ${client.basicInfo.name} (${client.basicInfo.phoneNumber1})');
return -1; // Nu s-a găsit
}

@@ -143,11 +150,14 @@
return null;
}

      // Creează un fișier Excel nou
      // Creează un fișier Excel nou fără Sheet1
var excel = Excel.createExcel();

      // Șterge sheet-ul implicit
      excel.delete('Sheet1');
      // Șterge toate sheet-urile implicite
      final sheetsToDelete = List<String>.from(excel.sheets.keys);
      for (final sheetName in sheetsToDelete) {
        excel.delete(sheetName);
      }

// Grupează clienții pe luni în funcție de data actualizării
final clientsByMonth = <String, List<UnifiedClientModel>>{};
@@ -217,8 +227,16 @@
}
}

  /// Adaugă datele unui client pe o linie
  /// Adaugă datele unui client pe o linie (sau actualizează datele existente)
 void _addClientRow(Sheet sheet, UnifiedClientModel client, int rowIndex) {
    debugPrint('📊 Actualizez/adaug client pe rândul $rowIndex: ${client.basicInfo.name}');
    
    // Curăță celulele existente pentru a evita date vechi parțiale
    for (int col = 0; col < 6; col++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex));
      cell.value = null; // Curăță celula
    }
    
// Coloana 1: Nume Client
final nameCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
nameCell.value = TextCellValue(client.basicInfo.name);
@@ -235,13 +253,17 @@
final statusCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex));
statusCell.value = TextCellValue(client.currentStatus.additionalInfo ?? '');

    // Coloana 5: Date Formular Client (credite + venituri)
    // Coloana 5: Date Formular Client (credite + venituri) - ACTUALIZATE
final clientDataCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex));
    clientDataCell.value = TextCellValue(_formatClientFormData(client.formData, isClient: true));
    final clientFormData = _formatClientFormData(client.formData, isClient: true);
    clientDataCell.value = TextCellValue(clientFormData);
    debugPrint('📊 Date formular client actualizate: $clientFormData');

    // Coloana 6: Date Formular Codebitor (credite + venituri)
    // Coloana 6: Date Formular Codebitor (credite + venituri) - ACTUALIZATE
final coDebitorDataCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex));
    coDebitorDataCell.value = TextCellValue(_formatClientFormData(client.formData, isClient: false));
    final coDebitorFormData = _formatClientFormData(client.formData, isClient: false);
    coDebitorDataCell.value = TextCellValue(coDebitorFormData);
    debugPrint('📊 Date formular codebitor actualizate: $coDebitorFormData');
}

/// Formatează datele formularului (credite + venituri) pentru o persoană
@@ -260,6 +282,7 @@

// Formatează venitul conform specificațiilor
final formattedIncome = _formatIncomeSpecial(income);
        // Includem și veniturile incomplete pentru debug/informare
buffer.write(formattedIncome);
}
}
@@ -278,6 +301,7 @@

// Formatează creditul conform noului format special
final formattedCredit = _formatCreditSpecial(credit);
        // Includem și creditele incomplete pentru debug/informare
buffer.write(formattedCredit);
}
}
@@ -291,6 +315,15 @@

/// Formatează un venit în formatul special cerut
 String _formatIncomeSpecial(IncomeData income) {
    // Verifică dacă banca și tipul de venit sunt valide (nu "Selectează")
    if (_isSelectValue(income.bank)) {
      return 'Venit incomplet - selectează banca';
    }
    
    if (_isSelectValue(income.incomeType)) {
      return 'Venit incomplet - selectează tipul';
    }
    
// Determină tipul de venit și îl formatează conform specificațiilor
String incomeTypeFormatted;
switch (income.incomeType.toLowerCase()) {
@@ -325,6 +358,15 @@

/// Formatează un credit în formatul special cerut
 String _formatCreditSpecial(CreditData credit) {
    // Verifică dacă banca și tipul de credit sunt valide (nu "Selectează")
    if (_isSelectValue(credit.bank)) {
      return 'Credit incomplet - selectează banca';
    }
    
    if (_isSelectValue(credit.creditType)) {
      return 'Credit incomplet - selectează tipul';
    }
    
// Formatează banca folosind aceeași logică ca la venituri
String bankFormatted = _formatBankName(credit.bank);

@@ -339,10 +381,13 @@

// Construiește formatul final: "bancă-tip: sume(detalii)"
String result = '$bankFormatted-$creditTypeFormatted: $amountsPart';
    if (detailsPart.isNotEmpty) {
    
    // Adaugă detaliile doar dacă există și nu sunt goale
    if (detailsPart.isNotEmpty && !_isSelectValue(detailsPart)) {
result += '($detailsPart)';
}

    debugPrint('📊 Credit formatat final: $result (cu detalii: "$detailsPart")');
return result;
}

@@ -420,9 +465,15 @@
 String _formatCreditDetails(CreditData credit) {
final details = <String>[];

    // Adaugă tipul ratei dacă există
    if (credit.rateType.isNotEmpty) {
    debugPrint('📊 Credit details - rateType: "${credit.rateType}", remainingMonths: ${credit.remainingMonths}');
    
    // Adaugă tipul ratei dacă există și nu este "Selectează"
    if (credit.rateType.isNotEmpty && 
        !_isSelectValue(credit.rateType)) {
details.add(credit.rateType);
      debugPrint('📊 Adăugat rateType: ${credit.rateType}');
    } else {
      debugPrint('📊 RateType ignorat - este selectează sau gol: "${credit.rateType}"');
}

// Adaugă perioada dacă există
@@ -431,7 +482,40 @@
details.add(period);
}

    return details.join(',');
    // Pentru anumite tipuri de credit, nu afișa paranteze goale
    if (details.isEmpty) {
      final creditTypeLower = credit.creditType.toLowerCase();
      debugPrint('📊 Nu există detalii pentru $creditTypeLower');
      
      // Pentru carduri, overdraft și nevoi personale, nu e nevoie de detalii suplimentare
      if (creditTypeLower.contains('card') || 
          creditTypeLower.contains('overdraft') || 
          creditTypeLower.contains('nevoi personale')) {
        debugPrint('📊 Tip de credit care nu necesită detalii - returnez gol');
        return ''; // Nu afișa paranteze pentru aceste tipuri
      }
    }
    
    final result = details.join(',');
    debugPrint('📊 Detalii credit finale: "$result"');
    
    // Verifică din nou pentru "Selectează" în rezultatul final
    if (_isSelectValue(result)) {
      debugPrint('📊 Rezultat final conține "Selectează" - returnez gol');
      return '';
    }
    
    return result;
  }

  /// Verifică dacă o valoare este "Selectează" în diverse variante
  bool _isSelectValue(String value) {
    final lowerValue = value.toLowerCase().trim();
    return lowerValue == 'selectează' || 
           lowerValue == 'selecteaza' || 
           lowerValue == 'selecteaza' ||
           lowerValue == 'select' ||
           lowerValue.isEmpty;
}

/// Formatează o sumă cu "k" pentru mii (5500 -> 5,5k)
@@ -708,33 +792,38 @@
return null;
}

      // Creează un fișier Excel nou
      // Creează un fișier Excel nou fără Sheet1
var excel = Excel.createExcel();
      excel.delete('Sheet1');
      
      // Șterge toate sheet-urile implicite
      final sheetsToDelete = List<String>.from(excel.sheets.keys);
      for (final sheetName in sheetsToDelete) {
        excel.delete(sheetName);
      }

// Creează sheet-ul pentru luna respectivă
Sheet sheet = excel[monthName];

// Adaugă header-ul
_addHeaderRow(sheet);

// Adaugă datele clienților
for (int i = 0; i < monthClients.length; i++) {
final client = monthClients[i];
_addClientRow(sheet, client, i + 2);
}

// Ajustează lățimea coloanelor
_adjustColumnWidths(sheet);

// Salvează fișierul
final filePath = await _saveExcelFileWithTimestamp(excel);
return filePath;

} catch (e) {
debugPrint('❌ Eroare la exportul pentru luna $monthName: $e');
return null;
}
}

} 