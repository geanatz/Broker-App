import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:broker_app/app_theme.dart';
import 'package:broker_app/backend/services/llm_service.dart';
import 'package:broker_app/backend/services/splash_service.dart';
import 'headers/widget_header2.dart';

/// Widget pentru chatbot AI integrat în dashboard
class ChatbotWidget extends StatefulWidget {
  const ChatbotWidget({super.key});

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  late final LLMService _llmService;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _llmService = SplashService().llmService;
    _llmService.loadConversation();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _llmService,
      builder: (context, _) {
        // Afișează eroarea dacă există
        if (_llmService.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showError();
          });
        }
        
        return Container(
          width: double.infinity,
          height: double.infinity, // Fill pe verticala
          padding: const EdgeInsets.all(AppTheme.smallGap),
          decoration: AppTheme.widgetDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 16),
              
              // Messages area
              Expanded(
                child: _buildMessagesArea(),
              ),
              
              const SizedBox(height: 8),
              
              // Input area
              _buildInputArea(),
            ],
          ),
        );
      },
    );
  }

  /// Construiește header-ul chatbot-ului
  Widget _buildHeader() {
    return WidgetHeader2(
      title: 'Asistent AI',
      altText: 'Conversatie noua',
      onAltTextTap: _llmService.hasApiKey ? _createNewChat : null,
    );
  }

  /// Construiește zona de mesaje
  Widget _buildMessagesArea() {
    if (_llmService.messages.isEmpty) {
      return _buildWelcomeMessage();
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _llmService.messages.length,
      itemBuilder: (context, index) {
        final message = _llmService.messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  /// Construiește mesajul de bun venit
  Widget _buildWelcomeMessage() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/chatIcon.svg',
            width: 32,
            height: 32,
            colorFilter: ColorFilter.mode(
              AppTheme.elementColor2,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _llmService.getWelcomeMessage(),
            style: AppTheme.safeOutfit(
              color: AppTheme.elementColor2,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
                      const SizedBox(height: 16),
          // Acțiuni rapide
          _buildQuickActions(),
        ],
      ),
    );
  }

  /// Construiește acțiunile rapide
  Widget _buildQuickActions() {
    final quickActions = [
      'Ce intalniri am astazi?',
      'Cati clienti am adaugat luna aceasta?',
      'Care este norma BCR pentru credite ipotecare?',
      'Ce intalniri am saptamana aceasta?',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: quickActions.map((action) => _buildQuickActionButton(action)).toList(),
    );
  }

  /// Construiește un buton pentru acțiune rapidă
  Widget _buildQuickActionButton(String text) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _sendMessage(text),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.containerColor1,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            style: AppTheme.safeOutfit(
              color: AppTheme.elementColor2,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// Construiește o bule de mesaj
  Widget _buildMessageBubble(ChatMessage message) {
    final timeString = '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
                      if (message.isUser) ...[
              // Mesaj utilizator - bule cu border radius 4 în colțul din dreapta sus
              Align(
                alignment: Alignment.centerRight,
                child: IntrinsicWidth(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.containerColor1,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(4),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      message.content,
                      style: AppTheme.safeOutfit(
                        color: AppTheme.elementColor2,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.left,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ),
                        ] else ...[
              // Mesaj AI - text cu border
              Align(
                alignment: Alignment.centerLeft,
                child: IntrinsicWidth(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.containerColor1,
                        width: 2,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      message.content.trim(),
                      style: AppTheme.safeOutfit(
                        color: AppTheme.elementColor2,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ),
            ],
          // Ora și butoane sub mesaj
          Padding(
            padding: EdgeInsets.only(
              top: 4, 
              left: message.isUser ? 0 : 12,
              right: message.isUser ? 12 : 0,
            ),
            child: Row(
              mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (message.isUser) ...[
                  // Buton retry pentru mesajele utilizatorului
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _retryMessage(message),
                      child: Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.only(right: 8),
                        child: SvgPicture.asset(
                          'assets/retryIcon.svg',
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            AppTheme.elementColor3,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                Text(
                  timeString,
                  style: AppTheme.safeOutfit(
                    color: AppTheme.elementColor3,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (!message.isUser) ...[
                  // Buton copy pentru răspunsurile AI
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _copyMessage(message),
                      child: Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.only(left: 8),
                        child: SvgPicture.asset(
                          'assets/copyIcon.svg',
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            AppTheme.elementColor3,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construiește zona de input
  Widget _buildInputArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: AppTheme.containerColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: _llmService.hasApiKey 
                    ? 'Scrie o intrebare...'
                    : 'Configureaza cheia Gemini API pentru a incepe',
                hintStyle: AppTheme.safeOutfit(
                  color: AppTheme.elementColor3,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              style: AppTheme.safeOutfit(
                color: AppTheme.elementColor2,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          if (_llmService.isLoading)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.elementColor2),
              ),
            )
          else
            GestureDetector(
              onTap: _llmService.hasApiKey ? _sendMessage : null,
              child: SizedBox(
                width: 24,
                height: 24,
                child: SvgPicture.asset(
                  'assets/sendIcon.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    _llmService.hasApiKey 
                        ? AppTheme.elementColor2 
                        : AppTheme.elementColor3,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  /// Creează un chat nou
  void _createNewChat() {
    _llmService.clearMessages();
    _messageController.clear();
    
    // Scroll la început
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Trimite mesajul
  void _sendMessage([String? message]) {
    final text = message ?? _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _llmService.addUserMessage(text);
    
    // Scroll la sfârșit după un scurt delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Retrimite mesajul utilizatorului
  void _retryMessage(ChatMessage userMessage) {
    // Șterge ultimul răspuns AI dacă există
    final messages = _llmService.messages;
    if (messages.isNotEmpty && !messages.last.isUser) {
      _llmService.removeLastMessage();
    }
    
    // Forțează AI-ul să răspundă din nou la ultimul mesaj al utilizatorului
    _llmService.retryLastUserMessage();
    
    // Scroll la sfârșit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Copiază răspunsul AI în clipboard
  void _copyMessage(ChatMessage message) {
    if (!message.isUser) {
      Clipboard.setData(ClipboardData(text: message.content));
      
      // Afișează un feedback vizual
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Raspuns copiat in clipboard'),
          backgroundColor: AppTheme.elementColor2,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Afișează eroarea dacă există
  void _showError() {
    if (_llmService.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_llmService.errorMessage!),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
} 