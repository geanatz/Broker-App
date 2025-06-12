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

  /// Exportă toate datele clienților în format XLSX
  Future<String?> exportAllClientsToXlsx() async {
    try {
      debugPrint('📊 ExcelExportService: Începe obținerea clienților...');
      
      // Obține toți clienții cu datele complete
      final clients = await _clientsService.getAllClients();
      
      debugPrint('📊 ExcelExportService: S-au obținut ${clients.length} clienți');
      
      if (clients.isEmpty) {
        debugPrint('❌ Nu există clienți pentru export');
        return null;
      }

      // Creează un fișier Excel nou
      var excel = Excel.createExcel();
      
      // Șterge sheet-ul implicit
      excel.delete('Sheet1');
      
      // Grupează clienții pe luni în funcție de data actualizării
      final clientsByMonth = <String, List<UnifiedClientModel>>{};
      
      for (final client in clients) {
        final updateDate = client.metadata.updatedAt;
        // Folosește formatare simplă fără locale românesc pentru a evita eroarea
        final monthKey = DateFormat('MMMM yyyy').format(updateDate);
        
        if (!clientsByMonth.containsKey(monthKey)) {
          clientsByMonth[monthKey] = [];
        }
        clientsByMonth[monthKey]!.add(client);
      }
      
      // Creează câte un sheet pentru fiecare lună
      for (final monthEntry in clientsByMonth.entries) {
        final monthName = monthEntry.key;
        final monthClients = monthEntry.value;
        
        // Creează sheet-ul pentru luna respectivă
        Sheet sheet = excel[monthName];
        
        // Adaugă header-ul (prima linie)
        _addHeaderRow(sheet);
        
        // Adaugă datele clienților
        for (int i = 0; i < monthClients.length; i++) {
          final client = monthClients[i];
          _addClientRow(sheet, client, i + 2); // +2 pentru că linia 1 e header
        }
        
        // Setează lățimea coloanelor pentru lizibilitate
        _adjustColumnWidths(sheet);
      }
      
      // Salvează fișierul
      final filePath = await _saveExcelFile(excel);
      return filePath;
      
    } catch (e) {
      debugPrint('❌ Eroare la exportul XLSX: $e');
      return null;
    }
  }

  /// Adaugă header-ul (prima linie) în sheet
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
      
      // Stilizează header-ul
      cell.cellStyle = CellStyle(
        bold: true,
        fontSize: 12,
      );
    }
  }

  /// Adaugă datele unui client pe o linie
  void _addClientRow(Sheet sheet, UnifiedClientModel client, int rowIndex) {
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
    
    // Coloana 5: Date Formular Client (credite + venituri)
    final clientDataCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex));
    clientDataCell.value = TextCellValue(_formatClientFormData(client.formData, isClient: true));
    
    // Coloana 6: Date Formular Codebitor (credite + venituri)
    final coDebitorDataCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex));
    coDebitorDataCell.value = TextCellValue(_formatClientFormData(client.formData, isClient: false));
  }

  /// Formatează datele formularului (credite + venituri) pentru o persoană
  String _formatClientFormData(ClientFormData formData, {required bool isClient}) {
    final buffer = StringBuffer();
    
    final credits = isClient ? formData.clientCredits : formData.coDebitorCredits;
    final incomes = isClient ? formData.clientIncomes : formData.coDebitorIncomes;
    
    // Adaugă veniturile cu formatarea specială
    if (incomes.isNotEmpty) {
      for (final income in incomes) {
        if (buffer.isNotEmpty) {
          buffer.write('\n');
        }
        
        // Formatează venitul conform specificațiilor
        final formattedIncome = _formatIncomeSpecial(income);
        buffer.write(formattedIncome);
      }
    }
    
    // Adaugă creditele cu noua formatare specială
    if (credits.isNotEmpty) {
      // Separă creditele de venituri dacă există ambele
      if (incomes.isNotEmpty) {
        buffer.write('\n');
      }
      
      for (final credit in credits) {
        if (buffer.isNotEmpty && !(incomes.isNotEmpty && credit == credits.first)) {
          buffer.write('\n');
        }
        
        // Formatează creditul conform noului format special
        final formattedCredit = _formatCreditSpecial(credit);
        buffer.write(formattedCredit);
      }
    }
    
    if (credits.isEmpty && incomes.isEmpty) {
      return 'Nu există date în formular';
    }
    
    return buffer.toString().trim();
  }

  /// Formatează un venit în formatul special cerut
  String _formatIncomeSpecial(IncomeData income) {
    // Determină tipul de venit și îl formatează conform specificațiilor
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
    
    // Formatează suma folosind formatul cu "k" pentru mii
    String amountFormatted = '';
    if (income.monthlyAmount != null) {
      amountFormatted = _formatAmountWithK(income.monthlyAmount!);
    }
    
    // Formatează banca (abrevieri conform exemplelor)
    String bankFormatted = _formatBankName(income.bank);
    
    // Formatează vechimea
    String seniorityFormatted = _formatSeniority(income.seniority);
    
    // Construiește formatul final: "tip suma(banca,vechime)"
    return '$incomeTypeFormatted $amountFormatted($bankFormatted,$seniorityFormatted)';
  }

  /// Formatează un credit în formatul special cerut
  String _formatCreditSpecial(CreditData credit) {
    // Formatează banca folosind aceeași logică ca la venituri
    String bankFormatted = _formatBankName(credit.bank);
    
    // Formatează tipul de credit
    String creditTypeFormatted = _formatCreditType(credit.creditType);
    
    // Determină care sume să folosească în funcție de tipul creditului
    String amountsPart = _formatCreditAmounts(credit);
    
    // Adaugă detalii suplimentare dacă există (tip rata, perioada)
    String detailsPart = _formatCreditDetails(credit);
    
    // Construiește formatul final: "bancă-tip: sume(detalii)"
    String result = '$bankFormatted-$creditTypeFormatted: $amountsPart';
    if (detailsPart.isNotEmpty) {
      result += '($detailsPart)';
    }
    
    return result;
  }

  /// Formatează tipul de credit cu abrevieri
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
      case 'prima casă':
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
        // Pentru alte tipuri, folosește primele 2-3 caractere
        if (creditType.length > 3) {
          return creditType.substring(0, 3).toLowerCase();
        }
        return creditType.toLowerCase();
    }
  }

  /// Formatează sumele creditului (sold/plafon - rata/consumat)
  String _formatCreditAmounts(CreditData credit) {
    final creditTypeLower = credit.creditType.toLowerCase();
    
    // Pentru carduri și overdraft folosim plafon-consumat
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

  /// Formatează detaliile creditului (tip rata, perioada)
  String _formatCreditDetails(CreditData credit) {
    final details = <String>[];
    
    // Adaugă tipul ratei dacă există
    if (credit.rateType.isNotEmpty) {
      details.add(credit.rateType);
    }
    
    // Adaugă perioada dacă există
    if (credit.remainingMonths != null && credit.remainingMonths! > 0) {
      final period = _formatPeriod(credit.remainingMonths!);
      details.add(period);
    }
    
    return details.join(',');
  }

  /// Formatează o sumă cu "k" pentru mii (5500 -> 5,5k)
  String _formatAmountWithK(double amount) {
    if (amount >= 1000) {
      double amountInK = amount / 1000;
      
      // Dacă este număr întreg de mii, nu afișa zecimale
      if (amountInK == amountInK.toInt()) {
        return '${amountInK.toInt()}k';
      } else {
        // Afișează cu o zecimală și folosește virgulă în loc de punct
        return '${amountInK.toStringAsFixed(1).replaceAll('.', ',')}k';
      }
    } else {
      // Pentru sume sub 1000, afișează normal
      if (amount == amount.toInt()) {
        return amount.toInt().toString();
      } else {
        return amount.toStringAsFixed(0);
      }
    }
  }

  /// Formatează perioada în ani/luni
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

  /// Formatează numele băncii conform abrevierilor din exemple
  String _formatBankName(String bankName) {
    switch (bankName.toLowerCase()) {
      // Bănci comune
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
      
      // Bănci specifice pentru venituri
      case 'exim bank':
      case 'eximbank':
        return 'exim';
      case 'libra bank':
      case 'libra internet bank':
        return 'libra';
      
      // Bănci specifice pentru credite
      case 'axi ifn':
        return 'axi';
      case 'banca românească':
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
        // Pentru alte bănci, folosește primele 3-4 caractere în lowercase
        if (bankName.length > 4) {
          return bankName.substring(0, 4).toLowerCase();
        }
        return bankName.toLowerCase();
    }
  }

  /// Formatează vechimea în formatul cerut (ani/luni)
  String _formatSeniority(int? seniorityInMonths) {
    if (seniorityInMonths == null || seniorityInMonths == 0) {
      return '0luni';
    }
    
    if (seniorityInMonths < 12) {
      // Doar luni
      return '${seniorityInMonths}luni';
    } else if (seniorityInMonths % 12 == 0) {
      // Ani întregi
      final years = seniorityInMonths ~/ 12;
      if (years == 1) {
        return '1an';  // Singular pentru 1 an
      } else {
        return '${years}ani';
      }
    } else {
      // Ani și luni - conform exemplelor, afișăm doar anii
      final years = seniorityInMonths ~/ 12;
      if (years == 1) {
        return '1an';
      } else {
        return '${years}ani';
      }
    }
  }

  /// Ajustează lățimea coloanelor pentru lizibilitate
  void _adjustColumnWidths(Sheet sheet) {
    // Setează lățimi optime pentru fiecare coloană
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

  /// Salvează fișierul Excel și returnează path-ul
  Future<String> _saveExcelFile(Excel excel) async {
    try {
      // Obține directorul pentru salvare
      final directory = await getApplicationDocumentsDirectory();
      
      // Creează numele fișierului cu timestamp
      final timestamp = DateFormat('dd-MM-yyyy_HH-mm-ss').format(DateTime.now());
      final fileName = 'export_clienti_$timestamp.xlsx';
      final filePath = '${directory.path}/$fileName';
      
      // Salvează fișierul
      final file = File(filePath);
      final bytes = excel.encode();
      
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        debugPrint('✅ Fișier Excel salvat la: $filePath');
        return filePath;
      } else {
        throw Exception('Nu s-au putut encode datele Excel');
      }
    } catch (e) {
      debugPrint('❌ Eroare la salvarea fișierului Excel: $e');
      rethrow;
    }
  }

  /// Obține lista de luni disponibile pentru export
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
        // Sortează lunile în ordine cronologică
        final dateA = DateFormat('MMMM yyyy').parse(a);
        final dateB = DateFormat('MMMM yyyy').parse(b);
        return dateB.compareTo(dateA); // Descrescător (cele mai recente primul)
      });
      
      return sortedMonths;
    } catch (e) {
      debugPrint('❌ Eroare la obținerea lunilor disponibile: $e');
      return [];
    }
  }

  /// Exportă doar clienții dintr-o lună specifică
  Future<String?> exportClientsForMonth(String monthName) async {
    try {
      final clients = await _clientsService.getAllClients();
      
      // Filtrează clienții pentru luna specificată
      final monthClients = clients.where((client) {
        final updateDate = client.metadata.updatedAt;
        final clientMonth = DateFormat('MMMM yyyy').format(updateDate);
        return clientMonth == monthName;
      }).toList();
      
      if (monthClients.isEmpty) {
        debugPrint('❌ Nu există clienți pentru luna $monthName');
        return null;
      }

      // Creează un fișier Excel nou
      var excel = Excel.createExcel();
      excel.delete('Sheet1');
      
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
      final filePath = await _saveExcelFile(excel);
      return filePath;
      
    } catch (e) {
      debugPrint('❌ Eroare la exportul pentru luna $monthName: $e');
      return null;
    }
  }

} 