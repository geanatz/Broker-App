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

    _setLoading(true);
    _errorMessage = null;

    try {
      // OPTIMIZARE: Construieste promptul extins cu context live din Firestore
      final extendedPrompt = await buildPromptWithContext(userMessage);
      
      // Construiește contextul pentru LLM
      final systemPrompt = _buildSystemPrompt();
      final conversationHistory = _buildConversationHistory();
      
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assistantMessage = data['candidates'][0]['content']['parts'][0]['text'];
        
        final message = ChatMessage(
          content: assistantMessage,
          isUser: false,
          timestamp: DateTime.now(),
        );
        
        _messages.add(message);
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = 'Eroare API: ${errorData['error']['message'] ?? 'Eroare necunoscuta'}';
      }
    } catch (e) {
      debugPrint('❌ LLM_SERVICE: Error sending message: $e');
      _errorMessage = 'Eroare de conexiune: $e';
    } finally {
      _setLoading(false);
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
    // 1. Extrage toti clientii (live)
    final clients = await ClientsService().getAllClients();
    debugPrint('LLM_DEBUG: clients extrasi: ${clients.length}');
    // Log detaliat pentru a vedea structura formData
    for (int i = 0; i < clients.length; i++) {
      final client = clients[i];
      final formData = client.formData;
      debugPrint('LLM_DEBUG: Client ${i + 1} - ${client.name}:');
      debugPrint('  - clientCredits: ${formData['clientCredits']}');
      debugPrint('  - coDebitorCredits: ${formData['coDebitorCredits']}');
      debugPrint('  - clientIncomes: ${formData['clientIncomes']}');
      debugPrint('  - coDebitorIncomes: ${formData['coDebitorIncomes']}');
      debugPrint('  - formData keys: ${formData.keys.toList()}');
    }

    // 2. Extrage toate intalnirile (live)
    final meetingsRaw = await NewFirebaseService().getAllMeetings();
    debugPrint('LLM_DEBUG: meetingsRaw type: [33m${meetingsRaw.runtimeType}[0m, len: ${meetingsRaw.length}');
    if (meetingsRaw.isNotEmpty) {
      debugPrint('LLM_DEBUG: meetingsRaw[0] type: ${meetingsRaw[0].runtimeType}, keys: ${(meetingsRaw[0]).keys}');
    }
    // Cast explicit la Map<String, dynamic> daca e nevoie
    final meetings = meetingsRaw.map((m) => m).toList();
    debugPrint('LLM_DEBUG: meetings dupa cast: ${meetings.length}');

    // 3. Extrage statisticile consultantului (live)
    final consultantData = await ConsultantService().getCurrentConsultantData();
    final consultantToken = consultantData?['token'] ?? '';
    final consultantName = consultantData?['name'] ?? 'Necunoscut';
    final stats = await DashboardService().calculateConsultantStatsOptimized(consultantToken);
    debugPrint('LLM_DEBUG: stats: $stats');

    // 4. Extrage agentul de serviciu
    final dashboardService = DashboardService();
    final dutyAgent = dashboardService.dutyAgent ?? 'Necunoscut'; // Foloseste cache-ul existent
    debugPrint('LLM_DEBUG: consultantName: $consultantName, dutyAgent: $dutyAgent');

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

    debugPrint('LLM_DEBUG: buildPromptWithContext meetings type:  [33m${meetings.runtimeType} [0m, len: ${meetings.length}');
    if (meetings.isNotEmpty) {
      debugPrint('LLM_DEBUG: buildPromptWithContext meetings[0] type: ${meetings[0].runtimeType}, keys: ${(meetings[0] as Map<String, dynamic>).keys}');
    }

    // Rezumat structurat pentru AI (limiteaza la ultimele 20 de formulare si toate intalnirile viitoare)
    final clientsSummary = clients.take(20).map((c) => c.toString()).join('\n');
    final now = DateTime.now().millisecondsSinceEpoch;
    debugPrint('LLM_DEBUG: now ms: $now');
    String meetingsSummary = '';
    try {
      final filteredMeetings = (meetings as List<Map<String, dynamic>>)
          .where((m) {
            final dt = m['dateTime'];
            int ms = 0;
            if (dt is Timestamp) {
              ms = dt.toDate().millisecondsSinceEpoch;
            } else if (dt is DateTime) {
              ms = dt.millisecondsSinceEpoch;
            } else if (dt is int) {
              ms = dt;
            }
            debugPrint('LLM_DEBUG: meeting dateTime ms: $ms');
            return ms >= now; // Toate intalnirile viitoare
          })
          .toList();
      debugPrint('LLM_DEBUG: filteredMeetings count: ${filteredMeetings.length}');
      meetingsSummary = filteredMeetings
          .take(20) // Limiteaza la 20 intalniri pentru a nu depasi contextul
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
            final formattedDate = '${meetingDate.day}/${meetingDate.month}/${meetingDate.year} ${meetingDate.hour}:${meetingDate.minute.toString().padLeft(2, '0')}';
            return '${m['clientName']} - $formattedDate';
          })
          .join('\n');
    } catch (e, st) {
      debugPrint('LLM_DEBUG: meetingsSummary ERROR: $e\n$st');
      meetingsSummary = 'Eroare la procesarea intalnirilor: $e';
    }
    final statsSummary = stats.toString();

    return '''
Consultantul activ: $consultantName ($consultantToken)
Agent de serviciu: $dutyAgent
Statistici: $statsSummary
Clienti (ultimii 20):\n$clientsSummary
Intalniri viitoare (max 10):\n$meetingsSummary
---
Intrebare utilizator: $userMessage
''';
  }
} 