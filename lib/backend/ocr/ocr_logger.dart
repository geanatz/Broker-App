import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../services/clients_service.dart';

// O clasa simpla pentru a reprezenta un client din fisierul de referinta
class GroundTruthClient {
  final String name;
  final List<String> phones;

  GroundTruthClient({required this.name, required this.phones});

  @override
  String toString() => '$name: ${phones.join(', ')}';
}

class OcrDebugLog {
  final String imageName;
  final String timestamp;
  String? rawOcrText;
  final List<String> parsingSteps = [];
  final List<String> transformationSteps = [];
  List<UnifiedClientModel>? finalClients;
  List<GroundTruthClient>? groundTruthClients;
  final Map<String, List<String>> comparison = {};

  OcrDebugLog({required this.imageName})
      : timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  Map<String, dynamic> toJson() {
    return {
      'imageName': imageName,
      'timestamp': timestamp,
      'rawOcrText': rawOcrText,
      'parsingSteps': parsingSteps,
      'transformationSteps': transformationSteps,
      'finalClients': finalClients?.map((c) => c.toJson()).toList(),
      'groundTruthClients': groundTruthClients?.map((c) => {'name': c.name, 'phones': c.phones}).toList(),
      'comparison': comparison,
    };
  }
}

class OcrDebugLogger {
  static final OcrDebugLogger _instance = OcrDebugLogger._internal();
  factory OcrDebugLogger() => _instance;
  OcrDebugLogger._internal();

  OcrDebugLog? _currentLog;

  void startLog(String imageName) {
    _currentLog = OcrDebugLog(imageName: imageName);
  }

  void addParsingStep(String step) {
    _currentLog?.parsingSteps.add(step);
  }

  void addTransformationStep(String step) {
    _currentLog?.transformationSteps.add(step);
  }

  void setRawOcrText(String text) {
    _currentLog?.rawOcrText = text;
  }

  void setFinalClients(List<UnifiedClientModel> clients) {
    _currentLog?.finalClients = clients;
  }
  
  void setGroundTruth(File groundTruthFile) {
    final lines = groundTruthFile.readAsLinesSync();
    _currentLog?.groundTruthClients = lines.map((line) {
      final parts = line.split(RegExp(r'\s+(?=\d)'));
      if (parts.length == 2) {
        final name = parts[0].trim();
        final phones = parts[1].split(',').map((p) => p.trim()).toList();
        return GroundTruthClient(name: name, phones: phones);
      }
      return null;
    }).where((c) => c != null).cast<GroundTruthClient>().toList();
  }

  void compareResults() {
    if (_currentLog == null || _currentLog!.finalClients == null || _currentLog!.groundTruthClients == null) {
      return;
    }

    final finalClients = _currentLog!.finalClients!;
    final groundTruthClients = _currentLog!.groundTruthClients!;
    
    final groundTruthMap = { for (var c in groundTruthClients) c.name.toLowerCase().trim() : c.phones };
    final finalClientsMap = { for (var c in finalClients) c.basicInfo.name.toLowerCase().trim() : [c.basicInfo.phoneNumber1, c.basicInfo.phoneNumber2].where((p) => p != null).cast<String>().toList() };

    final found = <String>[];
    final notFound = <String>[];
    final wrongPhones = <String>[];

    for (var truthEntry in groundTruthMap.entries) {
      if (finalClientsMap.containsKey(truthEntry.key)) {
        found.add(truthEntry.key);
        final finalPhones = finalClientsMap[truthEntry.key]!;
        final truthPhones = truthEntry.value;
        if (Set.from(finalPhones).intersection(Set.from(truthPhones)).length != truthPhones.length) {
          wrongPhones.add('${truthEntry.key} -> Expected: $truthPhones, Got: $finalPhones');
        }
      } else {
        notFound.add(truthEntry.key);
      }
    }
    
    final unexpected = finalClientsMap.keys.where((k) => !groundTruthMap.containsKey(k)).toList();
    
    _currentLog!.comparison['FOUND'] = found;
    _currentLog!.comparison['NOT_FOUND_IN_EXTRACTION'] = notFound;
    _currentLog!.comparison['PHONES_MISMATCH'] = wrongPhones;
    _currentLog!.comparison['UNEXPECTED_IN_EXTRACTION'] = unexpected;
  }

  Future<void> saveLog() async {
    if (_currentLog == null) return;
    
    compareResults();
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/ocr_logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      final logFileName = 'log_${_currentLog!.imageName.split('.').first}_${DateTime.now().millisecondsSinceEpoch}.json';
      final logFile = File('${logDir.path}/$logFileName');
      
      final jsonString = JsonEncoder.withIndent('  ').convert(_currentLog!.toJson());
      await logFile.writeAsString(jsonString);
      print('✅ [OcrDebugLogger] Log salvat: ${logFile.path}');
    } catch (e) {
      print('❌ [OcrDebugLogger] Eroare la salvarea logului: $e');
    }

    _currentLog = null;
  }
} 