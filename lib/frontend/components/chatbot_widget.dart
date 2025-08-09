import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:broker_app/app_theme.dart';
import 'package:broker_app/backend/services/llm_service.dart';
import 'package:broker_app/backend/services/consultant_service.dart';
import 'package:broker_app/backend/services/splash_service.dart';
import 'headers/widget_header2.dart';

/// Widget pentru chatbot AI integrat in dashboard
class ChatbotWidget extends StatefulWidget {
  const ChatbotWidget({super.key});

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  late final LLMService _llmService;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _quickActionsController = ScrollController();
  Timer? _quickActionsTimer;
  static const int _quickActionsRepeats = 200; // repeat list to emulate infinite loop

  String? _consultantName;

  final List<String> _quickActions = const [
    'Ce intalniri am astazi?',
    'Care este urmatoarea intalnire?',
    'Ce intalniri am saptamana aceasta?',
  ];

  @override
  void initState() {
    super.initState();
    _llmService = SplashService().llmService;
    _llmService.loadConversation();
    _loadConsultantName();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startQuickActionsAutoScroll();
    });
  }

  Future<void> _loadConsultantName() async {
    try {
      final data = await ConsultantService().getCurrentConsultantData();
      final name = data?['name'] as String?;
      if (name != null && name.trim().isNotEmpty && mounted) {
        setState(() => _consultantName = name.trim());
      }
    } catch (_) {
      // ignore
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _quickActionsTimer?.cancel();
    _quickActionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _llmService,
      builder: (context, _) {
        // Afiseaza eroarea daca exista
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
          _buildQuickActionsCarousel(),
          const SizedBox(height: 8),
              
              // Input area
              _buildInputArea(),
            ],
          ),
        );
      },
    );
  }

  /// Construieste header-ul chatbot-ului
  Widget _buildHeader() {
    return WidgetHeader2(
      title: 'Asistent AI',
      altText: 'Conversatie noua',
      onAltTextTap: _llmService.hasApiKey ? _createNewChat : null,
    );
  }

  /// Construieste zona de mesaje
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

  /// Construieste mesajul de bun venit
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
            _consultantName != null && _consultantName!.isNotEmpty
                ? 'Buna, ${_consultantName!}! Cu ce te pot ajuta?'
                : _llmService.getWelcomeMessage(),
            style: AppTheme.safeOutfit(
              color: AppTheme.elementColor2,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Quick actions au fost mutate jos, deasupra inputului
        ],
      ),
    );
  }

  /// Carusel infinit si lent cu actiuni rapide, plasat deasupra inputului
  Widget _buildQuickActionsCarousel() {
    return SizedBox(
      height: 44,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.builder(
          controller: _quickActionsController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _quickActions.isEmpty ? 0 : _quickActions.length * _quickActionsRepeats,
          itemBuilder: (context, index) {
            if (_quickActions.isEmpty) return const SizedBox.shrink();
            final text = _quickActions[index % _quickActions.length];
            return Padding(
              padding: EdgeInsets.only(right: index == _quickActions.length * _quickActionsRepeats - 1 ? 0 : 8),
              child: _buildQuickActionButton(text),
            );
          },
        ),
      ),
    );
  }

  /// Construieste un buton pentru actiune rapida
  Widget _buildQuickActionButton(String text) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _sendMessage(text),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.containerColor1,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
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
      ),
    );
  }

  /// Construieste o bule de mesaj
  Widget _buildMessageBubble(ChatMessage message) {
    final timeString = '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
                      if (message.isUser) ...[
              // Mesaj utilizator - bule cu border radius 4 in coltul din dreapta sus
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
          // Ora si butoane sub mesaj
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
                  // Buton copy pentru raspunsurile AI
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

  /// Construieste zona de input
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

  /// Creeaza un chat nou
  void _createNewChat() {
    _llmService.clearMessages();
    _messageController.clear();
    
    // Scroll la inceput
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
    
    // Scroll la sfarsit dupa un scurt delay
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
    // Sterge ultimul raspuns AI daca exista
    final messages = _llmService.messages;
    if (messages.isNotEmpty && !messages.last.isUser) {
      _llmService.removeLastMessage();
    }
    
    // Forteaza AI-ul sa raspunda din nou la ultimul mesaj al utilizatorului
    _llmService.retryLastUserMessage();
    
    // Scroll la sfarsit
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

  /// Copiaza raspunsul AI in clipboard
  void _copyMessage(ChatMessage message) {
    if (!message.isUser) {
      Clipboard.setData(ClipboardData(text: message.content));
      
      // Afiseaza un feedback vizual
      // silent
    }
  }

  /// Afiseaza eroarea daca exista
  void _showError() {
    if (_llmService.errorMessage != null) {
      // silent
    }
  }

  /// Auto-scroll smooth for quick actions carousel, infinite loop
  void _startQuickActionsAutoScroll() {
    _quickActionsTimer?.cancel();
    if (_quickActions.isEmpty) return;

    // Tune speed and interval for a slightly faster, smoother animation
    const Duration interval = Duration(milliseconds: 16); // ~60 FPS
    const double stepPx = 0.8; // faster but still smooth

    _quickActionsTimer = Timer.periodic(interval, (timer) {
      if (!_quickActionsController.hasClients) return;
      final max = _quickActionsController.position.maxScrollExtent;
      final current = _quickActionsController.offset;

      if (current + stepPx >= max) {
        _quickActionsController.jumpTo(0);
      } else {
        _quickActionsController.jumpTo(current + stepPx);
      }
    });
  }
} 