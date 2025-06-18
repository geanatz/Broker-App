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

  /// Salveaza un singur client in fisierul "clienti.xlsx"
  /// Daca fisierul exista, il editeaza. Daca nu exista, il creeaza.
  Future<String?> saveClientToXlsx(UnifiedClientModel client) async {
    try {
      debugPrint('📊 ExcelExportService: Salvez clientul ${client.basicInfo.name}...');
      
      // Obtine calea catre fisierul "clienti.xlsx"
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/clienti.xlsx';
      final file = File(filePath);
      
      Excel excel;
      
      // Verifica daca fisierul exista
      if (await file.exists()) {
        debugPrint('📊 Fisierul clienti.xlsx exista, il editez...');
        // Incarca fisierul existent
        final bytes = await file.readAsBytes();
        excel = Excel.decodeBytes(bytes);
        
        // Sterge Sheet1 daca inca exista
        if (excel.sheets.containsKey('Sheet1')) {
          excel.delete('Sheet1');
        }
      } else {
        debugPrint('📊 Fisierul clienti.xlsx nu exista, il creez...');
        // Creeaza un fisier nou fara Sheet1
        excel = Excel.createExcel();
        // Sterge sheet-ul implicit si toate sheet-urile existente
        final sheetsToDelete = List<String>.from(excel.sheets.keys);
        for (final sheetName in sheetsToDelete) {
          excel.delete(sheetName);
        }
      }
      
      // Determina luna pentru client
      final updateDate = client.metadata.updatedAt;
      final monthKey = DateFormat('MMMM yyyy').format(updateDate);
      
      debugPrint('📊 Adaug clientul in luna: $monthKey');
      
      // Obtine sau creeaza sheet-ul pentru luna respectiva
      Sheet sheet;
      if (excel.sheets.containsKey(monthKey)) {
        sheet = excel.sheets[monthKey]!;
      } else {
        // Creeaza sheet nou pentru aceasta luna
        sheet = excel[monthKey];
        // Adauga header-ul doar pentru sheet-uri noi
        _addHeaderRow(sheet);
      }
      
      // Verifica daca clientul exista deja in sheet
      final existingRowIndex = _findClientRowInSheet(sheet, client);
      
      if (existingRowIndex != -1) {
        debugPrint('📊 ACTUALIZARE: Clientul ${client.basicInfo.name} exista deja pe linia $existingRowIndex - se actualizeaza datele');
        // Actualizeaza linia existenta
        _addClientRow(sheet, client, existingRowIndex);
      } else {
        debugPrint('📊 CLIENT NOU: ${client.basicInfo.name} va fi adaugat pe un rand nou');
        // Adauga la sfarsitul listei
        final nextRowIndex = _getNextAvailableRow(sheet);
        _addClientRow(sheet, client, nextRowIndex);
      }
      
      // Ajusteaza latimea coloanelor
      _adjustColumnWidths(sheet);
      
      // Salveaza fisierul
      final bytes = excel.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        debugPrint('✅ Clientul ${client.basicInfo.name} salvat in clienti.xlsx la: $filePath');
        return filePath;
      } else {
        throw Exception('Nu s-au putut encode datele Excel');
      }
      
    } catch (e) {
      debugPrint('❌ Eroare la salvarea clientului in XLSX: $e');
      return null;
    }
  }

  /// Gaseste randul unui client existent in sheet
  /// Returneaza indexul randului sau -1 daca nu exista
  int _findClientRowInSheet(Sheet sheet, UnifiedClientModel client) {
    final maxRows = sheet.maxRows;
    
    for (int row = 1; row < maxRows; row++) { // Start from row 1 (skip header)
      final nameCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
      final phoneCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row));
      
      // Verifica daca numele si telefonul se potrivesc
      if (nameCell.value != null && phoneCell.value != null) {
        final cellName = nameCell.value.toString().trim();
        final cellPhone = phoneCell.value.toString().trim();
        
        // Potrivire bazata pe telefon (criteriul principal) si nume
        if (cellPhone == client.basicInfo.phoneNumber1.trim() && 
            cellName == client.basicInfo.name.trim()) {
          debugPrint('📊 Gasit client existent: $cellName ($cellPhone) pe randul $row');
          return row;
        }
      }
    }
    
    debugPrint('📊 Client nou, nu exista in sheet: ${client.basicInfo.name} (${client.basicInfo.phoneNumber1})');
    return -1; // Nu s-a gasit
  }

  /// Gaseste urmatorul rand disponibil intr-un sheet
  int _getNextAvailableRow(Sheet sheet) {
    // Cauta primul rand gol dupa header
    for (int row = 1; ; row++) {
      final nameCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
      if (nameCell.value == null || nameCell.value.toString().isEmpty) {
        return row;
      }
    }
  }

  /// Exporta toate datele clientilor in format XLSX
  Future<String?> exportAllClientsToXlsx() async {
    try {
      debugPrint('📊 ExcelExportService: Incepe obtinerea clientilor...');
      
      // Obtine toti clientii cu datele complete
      final clients = await _clientsService.getAllClients();
      
      debugPrint('📊 ExcelExportService: S-au obtinut ${clients.length} clienti');
      
      if (clients.isEmpty) {
        debugPrint('❌ Nu exista clienti pentru export');
        return null;
      }

      // Creeaza un fisier Excel nou fara Sheet1
      var excel = Excel.createExcel();
      
      // Sterge toate sheet-urile implicite
      final sheetsToDelete = List<String>.from(excel.sheets.keys);
      for (final sheetName in sheetsToDelete) {
        excel.delete(sheetName);
      }
      
      // Grupeaza clientii pe luni in functie de data actualizarii
      final clientsByMonth = <String, List<UnifiedClientModel>>{};
      
      for (final client in clients) {
        final updateDate = client.metadata.updatedAt;
        // Foloseste formatare simpla fara locale romanesc pentru a evita eroarea
        final monthKey = DateFormat('MMMM yyyy').format(updateDate);
        
        if (!clientsByMonth.containsKey(monthKey)) {
          clientsByMonth[monthKey] = [];
        }
        clientsByMonth[monthKey]!.add(client);
      }
      
      // Creeaza cate un sheet pentru fiecare luna
      for (final monthEntry in clientsByMonth.entries) {
        final monthName = monthEntry.key;
        final monthClients = monthEntry.value;
        
        // Creeaza sheet-ul pentru luna respectiva
        Sheet sheet = excel[monthName];
        
        // Adauga header-ul (prima linie)
        _addHeaderRow(sheet);
        
        // Adauga datele clientilor
        for (int i = 0; i < monthClients.length; i++) {
          final client = monthClients[i];
          _addClientRow(sheet, client, i + 2); // +2 pentru ca linia 1 e header
        }
        
        // Seteaza latimea coloanelor pentru lizibilitate
        _adjustColumnWidths(sheet);
      }
      
      // Salveaza fisierul
      final filePath = await _saveExcelFileWithTimestamp(excel);
      return filePath;
      
    } catch (e) {
      debugPrint('❌ Eroare la exportul XLSX: $e');
      return null;
    }
  }

  /// Adauga header-ul (prima linie) in sheet
  void _addHeaderRow(Sheet sheet) {
    final headers = [
      'Nume Client',
      'Telefon Client', 
      'Nume Codebitor',
      'Status/Informatii',
      'Date Formular Client',
      'Date Formular Codebitor'
    ];
    
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      
      // Stilizeaza header-ul
      cell.cellStyle = CellStyle(
        bold: true,
        fontSize: 12,
      );
    }
  }

  /// Adauga datele unui client pe o linie (sau actualizeaza datele existente)
  void _addClientRow(Sheet sheet, UnifiedClientModel client, int rowIndex) {
    debugPrint('📊 Actualizez/adaug client pe randul $rowIndex: ${client.basicInfo.name}');
    
    // Curata celulele existente pentru a evita date vechi partiale
    for (int col = 0; col < 6; col++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex));
      cell.value = null; // Curata celula
    }
    
    // Coloana 1: Nume Client
    final nameCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
    nameCell.value = TextCellValue(client.basicInfo.name);
    
    // Coloana 2: Telefon Client  
    final phoneCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex));
    phoneCell.value = TextCellValue(client.basicInfo.phoneNumber1);
    
    // Coloana 3: Nume Codebitor
    final coDebitorCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex));
    coDebitorCell.value = TextCellValue(client.basicInfo.coDebitorName ?? '');
    
    // Coloana 4: Status/Informatii
    final statusCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex));
    statusCell.value = TextCellValue(client.currentStatus.additionalInfo ?? '');
    
    // Coloana 5: Date Formular Client (credite + venituri) - ACTUALIZATE
    final clientDataCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex));
    final clientFormData = _formatClientFormData(client.formData, isClient: true);
    clientDataCell.value = TextCellValue(clientFormData);
    debugPrint('📊 Date formular client actualizate: $clientFormData');
    
    // Coloana 6: Date Formular Codebitor (credite + venituri) - ACTUALIZATE
    final coDebitorDataCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex));
    final coDebitorFormData = _formatClientFormData(client.formData, isClient: false);
    coDebitorDataCell.value = TextCellValue(coDebitorFormData);
    debugPrint('📊 Date formular codebitor actualizate: $coDebitorFormData');
  }

  /// Formateaza datele formularului (credite + venituri) pentru o persoana
  String _formatClientFormData(ClientFormData formData, {required bool isClient}) {
    final buffer = StringBuffer();
    
    final credits = isClient ? formData.clientCredits : formData.coDebitorCredits;
    final incomes = isClient ? formData.clientIncomes : formData.coDebitorIncomes;
    
    // Adauga veniturile cu formatarea speciala
    if (incomes.isNotEmpty) {
      for (final income in incomes) {
        if (buffer.isNotEmpty) {
          buffer.write('\n');
        }
        
        // Formateaza venitul conform specificatiilor
        final formattedIncome = _formatIncomeSpecial(income);
        // Includem si veniturile incomplete pentru debug/informare
        buffer.write(formattedIncome);
      }
    }
    
    // Adauga creditele cu noua formatare speciala
    if (credits.isNotEmpty) {
      // Separa creditele de venituri daca exista ambele
      if (incomes.isNotEmpty) {
        buffer.write('\n');
      }
      
      for (final credit in credits) {
        if (buffer.isNotEmpty && !(incomes.isNotEmpty && credit == credits.first)) {
          buffer.write('\n');
        }
        
        // Formateaza creditul conform noului format special
        final formattedCredit = _formatCreditSpecial(credit);
        // Includem si creditele incomplete pentru debug/informare
        buffer.write(formattedCredit);
      }
    }
    
    if (credits.isEmpty && incomes.isEmpty) {
      return 'Nu exista date in formular';
    }
    
    return buffer.toString().trim();
  }

  /// Formateaza un venit in formatul special cerut
  String _formatIncomeSpecial(IncomeData income) {
    // Verifica daca banca si tipul de venit sunt valide (nu "Selecteaza")
    if (_isSelectValue(income.bank)) {
      return 'Venit incomplet - selecteaza banca';
    }
    
    if (_isSelectValue(income.incomeType)) {
      return 'Venit incomplet - selecteaza tipul';
    }
    
    // Determina tipul de venit si il formateaza conform specificatiilor
    String incomeTypeFormatted;
    switch (income.incomeType.toLowerCase()) {
      case 'salariu':
        incomeTypeFormatted = 'salariu';
        break;
      case 'pensie':
        incomeTypeFormatted = 'pensie';
        break;
      case 'indemnizatie':
        incomeTypeFormatted = 'indemn.';
        break;
      default:
        incomeTypeFormatted = income.incomeType.toLowerCase();
    }
    
    // Formateaza suma folosind formatul cu "k" pentru mii
    String amountFormatted = '';
    if (income.monthlyAmount != null) {
      amountFormatted = _formatAmountWithK(income.monthlyAmount!);
    }
    
    // Formateaza banca (abrevieri conform exemplelor)
    String bankFormatted = _formatBankName(income.bank);
    
    // Formateaza vechimea
    String seniorityFormatted = _formatSeniority(income.seniority);
    
    // Construieste formatul final: "tip suma(banca,vechime)"
    return '$incomeTypeFormatted $amountFormatted($bankFormatted,$seniorityFormatted)';
  }

  /// Formateaza un credit in formatul special cerut
  String _formatCreditSpecial(CreditData credit) {
    // Verifica daca banca si tipul de credit sunt valide (nu "Selecteaza")
    if (_isSelectValue(credit.bank)) {
      return 'Credit incomplet - selecteaza banca';
    }
    
    if (_isSelectValue(credit.creditType)) {
      return 'Credit incomplet - selecteaza tipul';
    }
    
    // Formateaza banca folosind aceeasi logica ca la venituri
    String bankFormatted = _formatBankName(credit.bank);
    
    // Formateaza tipul de credit
    String creditTypeFormatted = _formatCreditType(credit.creditType);
    
    // Determina care sume sa foloseasca in functie de tipul creditului
    String amountsPart = _formatCreditAmounts(credit);
    
    // Adauga detalii suplimentare daca exista (tip rata, perioada)
    String detailsPart = _formatCreditDetails(credit);
    
    // Construieste formatul final: "banca-tip: sume(detalii)"
    String result = '$bankFormatted-$creditTypeFormatted: $amountsPart';
    
    // Adauga detaliile doar daca exista si nu sunt goale
    if (detailsPart.isNotEmpty && !_isSelectValue(detailsPart)) {
      result += '($detailsPart)';
    }
    
    debugPrint('📊 Credit formatat final: $result (cu detalii: "$detailsPart")');
    return result;
  }

  /// Formateaza tipul de credit cu abrevieri
  String _formatCreditType(String creditType) {
    switch (creditType.toLowerCase()) {
      case 'card cumparaturi':
      case 'card de cumparaturi':
        return 'cc';
      case 'nevoi personale':
        return 'np';
      case 'ipotecar':
      case 'credit ipotecar':
        return 'ip';
      case 'overdraft':
        return 'ovd';
      case 'prima casa':
      return 'pc';
      case 'auto':
      case 'leasing auto':
        return 'auto';
      case 'imobiliar':
        return 'imob';
      case 'refinantare':
        return 'ref';
      case 'credit de consum':
        return 'cons';
      case 'credit rapid':
        return 'rapid';
      default:
        // Pentru alte tipuri, foloseste primele 2-3 caractere
        if (creditType.length > 3) {
          return creditType.substring(0, 3).toLowerCase();
        }
        return creditType.toLowerCase();
    }
  }

  /// Formateaza sumele creditului (sold/plafon - rata/consumat)
  String _formatCreditAmounts(CreditData credit) {
    final creditTypeLower = credit.creditType.toLowerCase();
    
    // Pentru carduri si overdraft folosim plafon-consumat
    if (creditTypeLower.contains('card') || creditTypeLower.contains('overdraft')) {
      String plafon = '';
      String consumat = '';
      
      // Pentru carduri, currentBalance poate fi plafon, consumedAmount este consumat
      if (credit.currentBalance != null) {
        plafon = _formatAmountWithK(credit.currentBalance!);
      }
      if (credit.consumedAmount != null) {
        consumat = _formatAmountWithK(credit.consumedAmount!);
      }
      
      return '$plafon-$consumat';
    } else {
      // Pentru credite normale folosim sold-rata
      String sold = '';
      String rata = '';
      
      if (credit.currentBalance != null) {
        sold = _formatAmountWithK(credit.currentBalance!);
      }
      if (credit.monthlyPayment != null) {
        rata = _formatAmountWithK(credit.monthlyPayment!);
      }
      
      return '$sold-$rata';
    }
  }

  /// Formateaza detaliile creditului (tip rata, perioada)
  String _formatCreditDetails(CreditData credit) {
    final details = <String>[];
    
    debugPrint('📊 Credit details - rateType: "${credit.rateType}", remainingMonths: ${credit.remainingMonths}');
    
    // Adauga tipul ratei daca exista si nu este "Selecteaza"
    if (credit.rateType.isNotEmpty && 
        !_isSelectValue(credit.rateType)) {
      details.add(credit.rateType);
      debugPrint('📊 Adaugat rateType: ${credit.rateType}');
    } else {
      debugPrint('📊 RateType ignorat - este selecteaza sau gol: "${credit.rateType}"');
    }
    
    // Adauga perioada daca exista
    if (credit.remainingMonths != null && credit.remainingMonths! > 0) {
      final period = _formatPeriod(credit.remainingMonths!);
      details.add(period);
    }
    
    // Pentru anumite tipuri de credit, nu afisa paranteze goale
    if (details.isEmpty) {
      final creditTypeLower = credit.creditType.toLowerCase();
      debugPrint('📊 Nu exista detalii pentru $creditTypeLower');
      
      // Pentru carduri, overdraft si nevoi personale, nu e nevoie de detalii suplimentare
      if (creditTypeLower.contains('card') || 
          creditTypeLower.contains('overdraft') || 
          creditTypeLower.contains('nevoi personale')) {
        debugPrint('📊 Tip de credit care nu necesita detalii - returnez gol');
        return ''; // Nu afisa paranteze pentru aceste tipuri
      }
    }
    
    final result = details.join(',');
    debugPrint('📊 Detalii credit finale: "$result"');
    
    // Verifica din nou pentru "Selecteaza" in rezultatul final
    if (_isSelectValue(result)) {
      debugPrint('📊 Rezultat final contine "Selecteaza" - returnez gol');
      return '';
    }
    
    return result;
  }

  /// Verifica daca o valoare este "Selecteaza" in diverse variante
  bool _isSelectValue(String value) {
    final lowerValue = value.toLowerCase().trim();
    return lowerValue == 'selecteaza' || 
           lowerValue == 'selecteaza' || 
           lowerValue == 'selecteaza' ||
           lowerValue == 'select' ||
           lowerValue.isEmpty;
  }

  /// Formateaza o suma cu "k" pentru mii (5500 -> 5,5k)
  String _formatAmountWithK(double amount) {
    if (amount >= 1000) {
      double amountInK = amount / 1000;
      
      // Daca este numar intreg de mii, nu afisa zecimale
      if (amountInK == amountInK.toInt()) {
        return '${amountInK.toInt()}k';
      } else {
        // Afiseaza cu o zecimala si foloseste virgula in loc de punct
        return '${amountInK.toStringAsFixed(1).replaceAll('.', ',')}k';
      }
    } else {
      // Pentru sume sub 1000, afiseaza normal
      if (amount == amount.toInt()) {
        return amount.toInt().toString();
      } else {
        return amount.toStringAsFixed(0);
      }
    }
  }

  /// Formateaza perioada in ani/luni
  String _formatPeriod(int totalMonths) {
    if (totalMonths < 12) {
      return '${totalMonths}luni';
    } else if (totalMonths % 12 == 0) {
      final years = totalMonths ~/ 12;
      return '${years}ani';
    } else {
      final years = totalMonths ~/ 12;
      final months = totalMonths % 12;
      return '${years}ani${months}luni';
    }
  }

  /// Formateaza numele bancii conform abrevierilor din exemple
  String _formatBankName(String bankName) {
    switch (bankName.toLowerCase()) {
      // Banci comune
      case 'alpha bank':
        return 'alpha';
      case 'banca transilvania':
      case 'bt':
        return 'bt';
      case 'bcr':
        return 'bcr';
      case 'brd':
        return 'brd';
      case 'cec bank':
        return 'cec';
      case 'first bank':
        return 'first';
      case 'garanti bank':
        return 'garanti';
      case 'idea bank':
        return 'idea';
      case 'ing':
      case 'ing bank':
        return 'ing';
      case 'otp bank':
        return 'otp';
      case 'patria bank':
        return 'patria';
      case 'raiffeisen bank':
        return 'raiffeisen';
      case 'tbi bank':
        return 'tbi';
      case 'unicredit':
      case 'unicredit bank':
        return 'unicredit';
      
      // Banci specifice pentru venituri
      case 'exim bank':
      case 'eximbank':
        return 'exim';
      case 'libra bank':
      case 'libra internet bank':
        return 'libra';
      
      // Banci specifice pentru credite
      case 'axi ifn':
        return 'axi';
      case 'banca romaneasca':
        return 'br';
      case 'best credit':
        return 'best';
      case 'bnp paribas personal finance':
        return 'bnp';
      case 'brd finance':
        return 'brdf';
      case 'bt direct':
        return 'btd';
      case 'bt leasing':
        return 'btl';
      case 'car':
        return 'car';
      case 'cetelem':
        return 'cetelem';
      case 'credit europe bank':
        return 'ceb';
      case 'credit24':
        return 'c24';
      case 'credex':
        return 'credex';
      case 'credius':
        return 'credius';
      case 'eco finance':
        return 'eco';
      case 'ferratum bank':
        return 'ferratum';
      case 'happy credit':
        return 'happy';
      case 'hora credit':
        return 'hora';
      case 'icredit':
        return 'icredit';
      case 'ifn':
        return 'ifn';
      case 'intesa sanpaolo':
        return 'intesa';
      case 'leasing ifn':
        return 'lifn';
      case 'otp leasing':
        return 'otpl';
      case 'pireus bank':
        return 'pireus';
      case 'procredit bank':
        return 'procredit';
      case 'provident':
        return 'provident';
      case 'raiffeisen leasing':
        return 'raiffl';
      case 'revolut':
        return 'revolut';
      case 'salt bank':
        return 'salt';
      case 'simplu credit':
        return 'simplu';
      case 'unicredit consumer financing':
        return 'unicf';
      case 'unicredit leasing':
        return 'unicl';
      case 'viva credit':
        return 'viva';
      case 'volksbank':
        return 'volks';
      
      default:
        // Pentru alte banci, foloseste primele 3-4 caractere in lowercase
        if (bankName.length > 4) {
          return bankName.substring(0, 4).toLowerCase();
        }
        return bankName.toLowerCase();
    }
  }

  /// Formateaza vechimea in formatul cerut (ani/luni)
  String _formatSeniority(int? seniorityInMonths) {
    if (seniorityInMonths == null || seniorityInMonths == 0) {
      return '0luni';
    }
    
    if (seniorityInMonths < 12) {
      // Doar luni
      return '${seniorityInMonths}luni';
    } else if (seniorityInMonths % 12 == 0) {
      // Ani intregi
      final years = seniorityInMonths ~/ 12;
      if (years == 1) {
        return '1an';  // Singular pentru 1 an
      } else {
        return '${years}ani';
      }
    } else {
      // Ani si luni - conform exemplelor, afisam doar anii
      final years = seniorityInMonths ~/ 12;
      if (years == 1) {
        return '1an';
      } else {
        return '${years}ani';
      }
    }
  }

  /// Ajusteaza latimea coloanelor pentru lizibilitate
  void _adjustColumnWidths(Sheet sheet) {
    // Seteaza latimi optime pentru fiecare coloana
    final columnWidths = [
      20.0, // Nume Client
      15.0, // Telefon Client
      20.0, // Nume Codebitor  
      25.0, // Status/Informatii
      40.0, // Date Formular Client
      40.0, // Date Formular Codebitor
    ];
    
    for (int i = 0; i < columnWidths.length; i++) {
      sheet.setColumnWidth(i, columnWidths[i]);
    }
  }

  /// Salveaza fisierul Excel cu timestamp (pentru export complet)
  Future<String> _saveExcelFileWithTimestamp(Excel excel) async {
    try {
      // Obtine directorul pentru salvare
      final directory = await getApplicationDocumentsDirectory();
      
      // Creeaza numele fisierului cu timestamp
      final timestamp = DateFormat('dd-MM-yyyy_HH-mm-ss').format(DateTime.now());
      final fileName = 'export_clienti_$timestamp.xlsx';
      final filePath = '${directory.path}/$fileName';
      
      // Salveaza fisierul
      final file = File(filePath);
      final bytes = excel.encode();
      
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        debugPrint('✅ Fisier Excel salvat la: $filePath');
        return filePath;
      } else {
        throw Exception('Nu s-au putut encode datele Excel');
      }
    } catch (e) {
      debugPrint('❌ Eroare la salvarea fisierului Excel: $e');
      rethrow;
    }
  }

  /// Obtine lista de luni disponibile pentru export
  Future<List<String>> getAvailableMonths() async {
    try {
      final clients = await _clientsService.getAllClients();
      final months = <String>{};
      
      for (final client in clients) {
        final updateDate = client.metadata.updatedAt;
        final monthKey = DateFormat('MMMM yyyy').format(updateDate);
        months.add(monthKey);
      }
      
      final sortedMonths = months.toList();
      sortedMonths.sort((a, b) {
        // Sorteaza lunile in ordine cronologica
        final dateA = DateFormat('MMMM yyyy').parse(a);
        final dateB = DateFormat('MMMM yyyy').parse(b);
        return dateB.compareTo(dateA); // Descrescator (cele mai recente primul)
      });
      
      return sortedMonths;
    } catch (e) {
      debugPrint('❌ Eroare la obtinerea lunilor disponibile: $e');
      return [];
    }
  }

  /// Exporta doar clientii dintr-o luna specifica
  Future<String?> exportClientsForMonth(String monthName) async {
    try {
      final clients = await _clientsService.getAllClients();
      
      // Filtreaza clientii pentru luna specificata
      final monthClients = clients.where((client) {
        final updateDate = client.metadata.updatedAt;
        final clientMonth = DateFormat('MMMM yyyy').format(updateDate);
        return clientMonth == monthName;
      }).toList();
      
      if (monthClients.isEmpty) {
        debugPrint('❌ Nu exista clienti pentru luna $monthName');
        return null;
      }

      // Creeaza un fisier Excel nou fara Sheet1
      var excel = Excel.createExcel();
      
      // Sterge toate sheet-urile implicite
      final sheetsToDelete = List<String>.from(excel.sheets.keys);
      for (final sheetName in sheetsToDelete) {
        excel.delete(sheetName);
      }
      
      // Creeaza sheet-ul pentru luna respectiva
      Sheet sheet = excel[monthName];
      
      // Adauga header-ul
      _addHeaderRow(sheet);
      
      // Adauga datele clientilor
      for (int i = 0; i < monthClients.length; i++) {
        final client = monthClients[i];
        _addClientRow(sheet, client, i + 2);
      }
      
      // Ajusteaza latimea coloanelor
      _adjustColumnWidths(sheet);
      
      // Salveaza fisierul
      final filePath = await _saveExcelFileWithTimestamp(excel);
      return filePath;
      
    } catch (e) {
      debugPrint('❌ Eroare la exportul pentru luna $monthName: $e');
      return null;
    }
  }

} 
