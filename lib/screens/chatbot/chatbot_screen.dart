import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_app_bar.dart';
import '../../models/chat_message.dart';
import '../../services/gemini_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  final List<String> _quickQuestions = [
    '💪 Best chest workout?',
    '🔥 How to reduce belly fat?',
    '💊 Is creatine safe?',
    '🏋️ Full body routine?',
    '🥗 Pre-workout meal?',
  ];

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(ChatMessage(
      text:
          'Hey there! 💪 I\'m FitBot, your AI fitness coach!\n\nAsk me anything about workouts, nutrition, supplements, or fitness tips. I\'m here to help! 🏋️‍♂️',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text.trim(), isUser: true));
      _isTyping = true;
    });
    _messageController.clear();
    _scrollToBottom();

    final response = await GeminiService.chat(text.trim());

    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'FitBot AI',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.accent),
            onPressed: () {
              GeminiService.resetChat();
              setState(() {
                _messages.clear();
                _messages.add(ChatMessage(
                  text:
                      'Chat reset! 🔄 Ask me anything about fitness!\n\nI can help with workouts, diet plans, supplement advice, and more! 💪',
                  isUser: false,
                ));
              });
            },
            tooltip: 'Reset Chat',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: Column(
          children: [
            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount:
                    _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessageBubble(_messages[index], index);
                },
              ),
            ),

            // Quick questions (show only when few messages)
            if (_messages.length <= 2)
              FadeInUp(
                child: SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _quickQuestions.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => _sendMessage(_quickQuestions[index]),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Center(
                              child: Text(
                                _quickQuestions[index],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (_messages.length <= 2) const SizedBox(height: 8),

            // Input bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                border: Border(
                  top: BorderSide(
                    color: AppColors.bgCardLight.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.bgCardLight.withValues(alpha: 0.5),
                          ),
                        ),
                        child: TextField(
                          controller: _messageController,
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Ask me anything...',
                            hintStyle: GoogleFonts.poppins(
                              color: AppColors.textHint,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: _sendMessage,
                          textInputAction: TextInputAction.send,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _sendMessage(_messageController.text),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment:
              message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser) ...[
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: message.isUser ? AppColors.primaryGradient : null,
                  color: message.isUser ? null : AppColors.bgCard,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(message.isUser ? 18 : 4),
                    bottomRight: Radius.circular(message.isUser ? 4 : 18),
                  ),
                  border: message.isUser
                      ? null
                      : Border.all(
                          color: AppColors.bgCardLight.withValues(alpha: 0.5)),
                ),
                child: SelectableText(
                  message.text,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color:
                        message.isUser ? Colors.white : AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            if (message.isUser) const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return FadeIn(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(
                    color: AppColors.bgCardLight.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDot(0),
                  const SizedBox(width: 4),
                  _buildDot(200),
                  const SizedBox(width: 4),
                  _buildDot(400),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.textHint,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
