import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_instructions.dart';
import 'clients_service.dart';
import 'dashboard_service.dart';
import 'firebase_service.dart'; // pentru NewFirebaseService
import 'consultant_service.dart'; // pentru ConsultantService
import 'package:cloud_firestore/cloud_firestore.dart'; // pentru Timestamp

/// Model pentru un mesaj în conversația cu chatbot-ul
class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['content'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// Serviciu pentru gestionarea comunicării cu LLM-ul
class LLMService extends ChangeNotifier {
  // Singleton pattern
  static final LLMService _instance = LLMService._internal();
  factory LLMService() => _instance;
  LLMService._internal();

  // State variables
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // API Key hardcodat pentru toți consultanții
  static const String _apiKey = 'AIzaSyDCDWgHEEoqj85vRMO84-oJ37KyNR-72FI'; // Înlocuiește cu cheia ta reală

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasApiKey => _apiKey.isNotEmpty;

  void initState() {
    // Nu mai este nevoie să încărcăm API key-ul din SharedPreferences
    notifyListeners();
  }


  /// Nu mai este necesar - API key-ul este hardcodat
  Future<void> setApiKey(String apiKey) async {
    // Metoda păstrată pentru compatibilitate, dar nu face nimic
    debugPrint('⚠️ LLM_SERVICE: API key is now hardcoded, this method is deprecated');
  }

  /// Adaugă un mesaj de la utilizator
  void addUserMessage(String content) {
    if (content.trim().isEmpty) return;
    
    final message = ChatMessage(
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    _messages.add(message);
    _errorMessage = null;
    notifyListeners();
    
    // Trimite mesajul către LLM
    _sendMessageToLLM(content.trim());
  }

  /// Trimite mesajul către Google Gemini API
  Future<void> _sendMessageToLLM(String userMessage) async {
    if (!hasApiKey) {
      _errorMessage = 'Cheia API nu este configurata';
      notifyListeners();
      return;
    }

    debugPrint('🤖 AI_DEBUG: Incepe procesarea intrebarii: "$userMessage"');
    _setLoading(true);
    _errorMessage = null;

    try {
      // OPTIMIZARE: Construieste promptul extins cu context live din Firestore
      debugPrint('🤖 AI_DEBUG: Construire prompt cu context...');
      final extendedPrompt = await buildPromptWithContext(userMessage);
      
      // Construiește contextul pentru LLM
      final systemPrompt = _buildSystemPrompt();
      final conversationHistory = _buildConversationHistory();
      
      debugPrint('🤖 AI_DEBUG: Istoric conversatie: ${conversationHistory.length} mesaje');
      
      // Construiește mesajele pentru Gemini API
      final messages = <Map<String, dynamic>>[];
      
      // Adaugă prompt-ul de sistem ca primul mesaj
      messages.add({
        'role': 'user',
        'parts': [{'text': systemPrompt}],
      });
      
      // Adaugă istoricul conversației
      for (final msg in conversationHistory) {
        messages.add({
          'role': msg['role'] == 'user' ? 'user' : 'model',
          'parts': [{'text': msg['content']}],
        });
      }
      
      // Adaugă mesajul curent al utilizatorului cu context live
      messages.add({
        'role': 'user',
        'parts': [{'text': extendedPrompt}],
      });
      
      debugPrint('🤖 AI_DEBUG: Trimite cerere la Gemini API (${messages.length} mesaje)...');
      
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': messages,
          'generationConfig': AIInstructions.generationConfig,
        }),
      );

      debugPrint('🤖 AI_DEBUG: Raspuns API status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assistantMessage = data['candidates'][0]['content']['parts'][0]['text'];
        
        debugPrint('🤖 AI_DEBUG: Raspuns AI generat: "${assistantMessage.substring(0, assistantMessage.length > 100 ? 100 : assistantMessage.length)}..."');
        
        final message = ChatMessage(
          content: assistantMessage,
          isUser: false,
          timestamp: DateTime.now(),
        );
        
        _messages.add(message);
        debugPrint('🤖 AI_DEBUG: Raspuns adaugat cu succes');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMsg = 'Eroare API: ${errorData['error']['message'] ?? 'Eroare necunoscuta'}';
        debugPrint('❌ AI_DEBUG: Eroare API: $errorMsg');
        _errorMessage = errorMsg;
      }
    } catch (e) {
      debugPrint('❌ AI_DEBUG: Eroare procesare: $e');
      _errorMessage = 'Eroare de conexiune: $e';
    } finally {
      _setLoading(false);
      debugPrint('🤖 AI_DEBUG: Procesare finalizata');
    }
  }

  /// Construiește prompt-ul de sistem pentru LLM
  String _buildSystemPrompt() {
    return AIInstructions.systemPrompt;
  }

  /// Obține mesajul de bun venit
  String getWelcomeMessage() {
    return AIInstructions.welcomeMessage;
  }

  /// Obține mesajul de eroare personalizat
  String getErrorMessage(String errorType) {
    return AIInstructions.errorMessages[errorType] ?? 'Eroare necunoscuta';
  }

  /// Construiește istoricul conversației pentru context
  List<Map<String, String>> _buildConversationHistory() {
    return _messages
        .take(_messages.length - 1) // Exclude ultimul mesaj (cel care tocmai a fost adăugat)
        .map((message) => {
              'role': message.isUser ? 'user' : 'assistant',
              'content': message.content,
            })
        .toList();
  }

  /// Șterge toate mesajele
  void clearMessages() {
    _messages.clear();
    _errorMessage = null;
    notifyListeners();
  }

  /// Șterge ultimul mesaj
  void removeLastMessage() {
    if (_messages.isNotEmpty) {
      _messages.removeLast();
      notifyListeners();
    }
  }

  /// Retrimite ultimul mesaj al utilizatorului fără să-l adauge din nou
  void retryLastUserMessage() {
    if (_messages.isNotEmpty) {
      // Găsește ultimul mesaj al utilizatorului
      for (int i = _messages.length - 1; i >= 0; i--) {
        if (_messages[i].isUser) {
          // Trimite din nou mesajul către AI fără să-l adauge în listă
          _sendMessageToLLM(_messages[i].content);
          break;
        }
      }
    }
  }

  /// Setează starea de loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Salvează conversația în SharedPreferences
  Future<void> saveConversation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = _messages.map((msg) => msg.toJson()).toList();
      await prefs.setString('gemini_chatbot_conversation', jsonEncode(messagesJson));
    } catch (e) {
      debugPrint('❌ LLM_SERVICE: Error saving conversation: $e');
    }
  }

  /// Încarcă conversația din SharedPreferences
  Future<void> loadConversation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationJson = prefs.getString('gemini_chatbot_conversation');
      
      if (conversationJson != null) {
        final messagesList = jsonDecode(conversationJson) as List;
        _messages = messagesList
            .map((json) => ChatMessage.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ LLM_SERVICE: Error loading conversation: $e');
    }
  }

  /// Extrage contextul complet pentru consultantul activ (date live din Firestore)
  Future<Map<String, dynamic>> getConsultantContextData() async {
    debugPrint('🤖 AI_DEBUG: Extragere context consultant...');
    
    // 1. Extrage toti clientii (live)
    final clients = await ClientsService().getAllClients();
    debugPrint('🤖 AI_DEBUG: Clienti extrasi: ${clients.length}');
    
    // Log detaliat pentru a vedea structura formData (doar primii 3 clienti pentru a nu aglomera logurile)
    for (int i = 0; i < clients.length && i < 3; i++) {
      final client = clients[i];
      final formData = client.formData;
      debugPrint('🤖 AI_DEBUG: Client ${i + 1} - ${client.name}:');
      debugPrint('  - clientCredits: ${formData['clientCredits']}');
      debugPrint('  - coDebitorCredits: ${formData['coDebitorCredits']}');
      debugPrint('  - clientIncomes: ${formData['clientIncomes']}');
      debugPrint('  - coDebitorIncomes: ${formData['coDebitorIncomes']}');
    }

    // 2. Extrage toate intalnirile (live)
    final meetingsRaw = await NewFirebaseService().getAllMeetings();
    debugPrint('🤖 AI_DEBUG: Intalniri extrase: ${meetingsRaw.length}');
    
    // Cast explicit la Map<String, dynamic> daca e nevoie
    final meetings = meetingsRaw.map((m) => m).toList();

    // 3. Extrage statisticile consultantului (live)
    final consultantData = await ConsultantService().getCurrentConsultantData();
    final consultantToken = consultantData?['token'] ?? '';
    final consultantName = consultantData?['name'] ?? 'Necunoscut';
    final stats = await DashboardService().calculateConsultantStatsOptimized(consultantToken);
    debugPrint('🤖 AI_DEBUG: Statistici calculate pentru consultant: $consultantName');

    // 4. Extrage agentul de serviciu
    final dashboardService = DashboardService();
    final dutyAgent = dashboardService.dutyAgent ?? 'Necunoscut'; // Foloseste cache-ul existent
    debugPrint('🤖 AI_DEBUG: Agent serviciu: $dutyAgent');

    debugPrint('🤖 AI_DEBUG: Context extras cu succes');
    return {
      'consultantToken': consultantToken,
      'consultantName': consultantName,
      'dutyAgent': dutyAgent,
      'clients': clients.map((c) => c.toMap()).toList(),
      'meetings': meetings,
      'stats': stats,
    };
  }

  /// Construieste promptul extins cu context live pentru AI
  Future<String> buildPromptWithContext(String userMessage) async {
    final contextData = await getConsultantContextData();
    final consultantToken = contextData['consultantToken'] ?? '';
    final consultantName = contextData['consultantName'] ?? 'Necunoscut';
    final dutyAgent = contextData['dutyAgent'] ?? 'Necunoscut';
    final clients = contextData['clients'] ?? [];
    final meetings = contextData['meetings'] ?? [];
    final stats = contextData['stats'] ?? {};

    debugPrint('🤖 AI_DEBUG: Procesare intrebare: "$userMessage"');
    debugPrint('🤖 AI_DEBUG: Consultant: $consultantName ($consultantToken)');
    debugPrint('🤖 AI_DEBUG: Total clienti: ${clients.length}');
    debugPrint('🤖 AI_DEBUG: Total intalniri: ${meetings.length}');

    // Rezumat structurat pentru AI (include toate intalnirile - viitoare si din trecut)
    final clientsSummary = clients.take(20).map((c) => c.toString()).join('\n');
    final now = DateTime.now();
    final currentDate = '${now.day}/${now.month}/${now.year}';
    final currentMonth = now.month;
    final currentYear = now.year;
    
    // Calculează luna trecută pentru ghidarea AI-ului
    final lastMonth = now.month == 1 ? 12 : now.month - 1;
    final lastMonthYear = now.month == 1 ? now.year - 1 : now.year;
    final lastMonthName = _getMonthName(lastMonth);
    
    // Calculează săptămâna curentă și viitoare
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final nextWeekStart = currentWeekStart.add(const Duration(days: 7));
    
    debugPrint('🤖 AI_DEBUG: Data curenta: $currentDate');
    debugPrint('🤖 AI_DEBUG: Luna trecuta: $lastMonthName $lastMonthYear');
    debugPrint('🤖 AI_DEBUG: Saptamana curenta: ${currentWeekStart.day}/${currentWeekStart.month} - ${currentWeekStart.add(const Duration(days: 6)).day}/${currentWeekStart.add(const Duration(days: 6)).month}');
    debugPrint('🤖 AI_DEBUG: Saptamana viitoare: ${nextWeekStart.day}/${nextWeekStart.month} - ${nextWeekStart.add(const Duration(days: 6)).day}/${nextWeekStart.add(const Duration(days: 6)).month}');
    
    String meetingsSummary = '';
    String pastMeetingsSummary = '';
    String detailedMeetingsInfo = '';
    
    try {
      final allMeetings = (meetings as List<Map<String, dynamic>>);
      debugPrint('🤖 AI_DEBUG: Procesare ${allMeetings.length} intalniri');
      
      // Proceseaza toate intalnirile si le separa in viitoare si din trecut
      final futureMeetings = <Map<String, dynamic>>[];
      final pastMeetings = <Map<String, dynamic>>[];
      
      for (final m in allMeetings) {
        final dt = m['dateTime'];
        int ms = 0;
        if (dt is Timestamp) {
          ms = dt.toDate().millisecondsSinceEpoch;
        } else if (dt is DateTime) {
          ms = dt.millisecondsSinceEpoch;
        } else if (dt is int) {
          ms = dt;
        }
        
        if (ms >= now.millisecondsSinceEpoch) {
          futureMeetings.add(m);
        } else {
          pastMeetings.add(m);
        }
      }
      
      debugPrint('🤖 AI_DEBUG: Intalniri viitoare: ${futureMeetings.length}');
      debugPrint('🤖 AI_DEBUG: Intalniri din trecut: ${pastMeetings.length}');
      
      // Formateaza intalnirile viitoare
      meetingsSummary = futureMeetings
          .take(15) // Mărit de la 10 la 15 pentru mai multe date
          .map((m) {
            final dt = m['dateTime'];
            DateTime meetingDate;
            if (dt is Timestamp) {
              meetingDate = dt.toDate();
            } else if (dt is DateTime) {
              meetingDate = dt;
            } else {
              meetingDate = DateTime.fromMillisecondsSinceEpoch(dt as int);
            }
            final formattedDate = '${meetingDate.day} ${_getMonthName(meetingDate.month)} ${meetingDate.year} ${meetingDate.hour}:${meetingDate.minute.toString().padLeft(2, '0')}';
            return '${m['clientName']} - $formattedDate (VIITOARE)';
          })
          .join('\n');
      
      // Formateaza intalnirile din trecut
      pastMeetingsSummary = pastMeetings
          .take(15) // Mărit de la 10 la 15 pentru mai multe date
          .map((m) {
            final dt = m['dateTime'];
            DateTime meetingDate;
            if (dt is Timestamp) {
              meetingDate = dt.toDate();
            } else if (dt is DateTime) {
              meetingDate = dt;
            } else {
              meetingDate = DateTime.fromMillisecondsSinceEpoch(dt as int);
            }
            final formattedDate = '${meetingDate.day} ${_getMonthName(meetingDate.month)} ${meetingDate.year} ${meetingDate.hour}:${meetingDate.minute.toString().padLeft(2, '0')}';
            return '${m['clientName']} - $formattedDate (TRE cut)';
          })
          .join('\n');
      
      // Informații detaliate pentru analiză
      detailedMeetingsInfo = '''
INFORMATII DETALIATE PENTRU ANALIZA:
- Total intalniri: ${allMeetings.length}
- Intalniri viitoare: ${futureMeetings.length}
- Intalniri din trecut: ${pastMeetings.length}
- Urmatoarele 3 intalniri viitoare: ${futureMeetings.take(3).map((m) {
        final dt = m['dateTime'];
        DateTime meetingDate;
        if (dt is Timestamp) {
          meetingDate = dt.toDate();
        } else if (dt is DateTime) {
          meetingDate = dt;
        } else {
          meetingDate = DateTime.fromMillisecondsSinceEpoch(dt as int);
        }
        return '${m['clientName']} - ${meetingDate.day} ${_getMonthName(meetingDate.month)} ${meetingDate.year}';
      }).join(', ')}
- Ultimele 3 intalniri din trecut: ${pastMeetings.take(3).map((m) {
        final dt = m['dateTime'];
        DateTime meetingDate;
        if (dt is Timestamp) {
          meetingDate = dt.toDate();
        } else if (dt is DateTime) {
          meetingDate = dt;
        } else {
          meetingDate = DateTime.fromMillisecondsSinceEpoch(dt as int);
        }
        return '${m['clientName']} - ${meetingDate.day} ${_getMonthName(meetingDate.month)} ${meetingDate.year}';
      }).join(', ')}
''';
          
      debugPrint('🤖 AI_DEBUG: Intalniri viitoare formatate: ${meetingsSummary.split('\n').length}');
      debugPrint('🤖 AI_DEBUG: Intalniri din trecut formatate: ${pastMeetingsSummary.split('\n').length}');
          
    } catch (e, st) {
      debugPrint('❌ AI_DEBUG: Eroare procesare intalniri: $e\n$st');
      meetingsSummary = 'Eroare la procesarea intalnirilor: $e';
      pastMeetingsSummary = 'Eroare la procesarea intalnirilor din trecut: $e';
      detailedMeetingsInfo = 'Eroare la procesarea informatiilor detaliate: $e';
    }
    
    final statsSummary = stats.toString();
    debugPrint('🤖 AI_DEBUG: Statistici: $statsSummary');

    final prompt = '''
INFORMATII DESPRE PERIOADE:
- Data curenta: ${now.day} ${_getMonthName(now.month)} ${now.year}
- Luna curenta: ${_getMonthName(currentMonth)} $currentYear
- Luna trecuta: $lastMonthName $lastMonthYear
- Saptamana curenta: ${currentWeekStart.day} ${_getMonthName(currentWeekStart.month)} - ${currentWeekStart.add(const Duration(days: 6)).day} ${_getMonthName(currentWeekStart.add(const Duration(days: 6)).month)}
- Saptamana viitoare: ${nextWeekStart.day} ${_getMonthName(nextWeekStart.month)} - ${nextWeekStart.add(const Duration(days: 6)).day} ${_getMonthName(nextWeekStart.add(const Duration(days: 6)).month)}

$detailedMeetingsInfo

Consultantul activ: $consultantName ($consultantToken)
Agent de serviciu: $dutyAgent
Statistici: $statsSummary
Clienti (ultimii 20):\n$clientsSummary
Intalniri viitoare (max 15):\n$meetingsSummary
Intalniri din trecut (max 15):\n$pastMeetingsSummary
---
Intrebare utilizator: $userMessage
''';

    debugPrint('🤖 AI_DEBUG: Prompt generat cu succes (${prompt.length} caractere)');
    return prompt;
  }

  /// Helper pentru a obține numele lunii
  String _getMonthName(int month) {
    const monthNames = [
      'Ianuarie', 'Februarie', 'Martie', 'Aprilie', 'Mai', 'Iunie',
      'Iulie', 'August', 'Septembrie', 'Octombrie', 'Noiembrie', 'Decembrie'
    ];
    return monthNames[month - 1];
  }
} 