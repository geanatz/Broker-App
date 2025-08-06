import 'package:flutter/material.dart';
import 'package:broker_app/app_theme.dart';
import 'package:broker_app/backend/services/llm_service.dart';
import 'package:broker_app/backend/services/splash_service.dart';
import 'headers/widget_header1.dart';

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
          height: 300,
          padding: const EdgeInsets.all(AppTheme.smallGap),
          decoration: AppTheme.widgetDecoration,
                      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 8),
                
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
    return Column(
      children: [
        WidgetHeader1(title: 'Asistent AI'),
        if (!_llmService.hasApiKey)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Configurare necesara',
              style: AppTheme.safeOutfit(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  /// Construiește zona de mesaje
  Widget _buildMessagesArea() {
    if (_llmService.messages.isEmpty) {
      return _buildWelcomeMessage();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: AppTheme.containerColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _llmService.messages.length,
        itemBuilder: (context, index) {
          final message = _llmService.messages[index];
          return _buildMessageBubble(message);
        },
      ),
    );
  }

  /// Construiește mesajul de bun venit
  Widget _buildWelcomeMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: AppTheme.containerColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 32,
            color: AppTheme.elementColor2,
          ),
          const SizedBox(height: 8),
          Text(
            _llmService.getWelcomeMessage(),
            style: AppTheme.safeOutfit(
              color: AppTheme.elementColor2,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Construiește o bule de mesaj
  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 12,
              backgroundColor: AppTheme.elementColor2,
              child: Icon(
                Icons.smart_toy,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.elementColor2 : AppTheme.containerColor2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.content,
                style: AppTheme.safeOutfit(
                  color: isUser ? Colors.white : AppTheme.elementColor2,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 12,
              backgroundColor: AppTheme.elementColor1,
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
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
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: AppTheme.safeOutfit(
                color: AppTheme.elementColor2,
                fontSize: 13,
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
            IconButton(
              onPressed: _llmService.hasApiKey ? _sendMessage : null,
              icon: Icon(
                Icons.send,
                size: 20,
                color: _llmService.hasApiKey 
                    ? AppTheme.elementColor2 
                    : AppTheme.elementColor3,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
        ],
      ),
    );
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