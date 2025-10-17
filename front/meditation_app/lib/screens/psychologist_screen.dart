
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/chat_message.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_container.dart';

class PsychologistScreen extends StatefulWidget {
  const PsychologistScreen({super.key});

  @override
  State<PsychologistScreen> createState() => _PsychologistScreenState();
}

class _PsychologistScreenState extends State<PsychologistScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatHistory() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.loadChatHistory();
    _scrollToBottom();
  }

  void _scrollToBottom() {
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

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    _messageController.clear();

    final appState = Provider.of<AppState>(context, listen: false);
    await appState.sendChatMessage(message);

    setState(() {
      _isLoading = false;
    });

    _scrollToBottom();
  }

  Future<void> _clearChat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text(
          'Очистить чат',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Вы уверены, что хотите очистить всю историю разговора?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Отмена',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final appState = Provider.of<AppState>(context, listen: false);
      await appState.clearChatHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1a1a2e),
                  Color(0xFF16213e),
                  Color(0xFF0f0f23),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header (only show back button if not in main navigation)
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        if (Navigator.of(context).canPop())
                          GlassButton(
                            onPressed: () => Navigator.pop(context),
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        if (Navigator.of(context).canPop())
                          const SizedBox(width: 16),
                        const Text(
                          'Психолог',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const Spacer(),
                        GlassButton(
                          onPressed: _clearChat,
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Chat messages
                  Expanded(
                    child: appState.chatHistory.isEmpty
                        ? const Center(
                            child: Text(
                              'Начните разговор с психологом',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: appState.chatHistory.length,
                            itemBuilder: (context, index) {
                              final message = appState.chatHistory[index];
                              final isUser = message.isUser;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Align(
                                  alignment: isUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: GlassContainer(
                                    padding: const EdgeInsets.all(16),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(20),
                                      topRight: const Radius.circular(20),
                                      bottomLeft: isUser
                                          ? const Radius.circular(20)
                                          : const Radius.circular(4),
                                      bottomRight: isUser
                                          ? const Radius.circular(4)
                                          : const Radius.circular(20),
                                    ),
                                    width: MediaQuery.of(context).size.width * 0.75,
                                    child: Text(
                                      message.content,
                                      style: TextStyle(
                                        color: isUser ? Colors.white : Colors.white,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Message input
                  GlassContainer(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Напишите ваше сообщение...',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GlassButton(
                          onPressed: _isLoading ? null : _sendMessage,
                          width: 50,
                          height: 50,
                          borderRadius: BorderRadius.circular(25),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}