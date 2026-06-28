import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/repositories/chatbot_repository.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final _controller    = TextEditingController();
  final _scrollCtrl    = ScrollController();
  String? _threadId;
  final List<ChatMessageModel> _messages = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final thread = await ref.read(chatbotRepositoryProvider).getOrCreateThread();
    if (!mounted) return;
    setState(() => _threadId = thread.id);
    final msgs = await ref.read(chatbotRepositoryProvider).getMessages(thread.id);
    if (!mounted) return;
    setState(() => _messages
      ..clear()
      ..addAll(msgs));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _threadId == null || _sending) return;
    _controller.clear();

    final userMsg = ChatMessageModel(
      id:        '',
      threadId:  _threadId!,
      role:      'user',
      content:   text,
      createdAt: DateTime.now(),
    );
    setState(() {
      _messages.add(userMsg);
      _sending = true;
    });
    _scrollToBottom();

    try {
      final reply = await ref.read(chatbotRepositoryProvider).sendMessage(_threadId!, text);
      if (!mounted) return;
      setState(() {
        _messages.add(reply);
        _sending = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.softCoral),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('NaiviSense AI',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: AppColors.parentGradient.colors.last,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('AI Chat',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_threadId == null)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: _messages.isEmpty && !_sending
                  ? _buildWelcome()
                  : ListView.builder(
                      controller:   _scrollCtrl,
                      padding:      const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      itemCount:    _messages.length + (_sending ? 1 : 0),
                      itemBuilder:  (_, i) {
                        if (_sending && i == _messages.length) {
                          return _TypingBubble();
                        }
                        return _MessageBubble(message: _messages[i]);
                      },
                    ),
            ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, size: 40, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 20),
            const Text('Hello! I\'m NaiviSense AI',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Ask me anything about your child\'s therapy, home activities, diet, or general guidance.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines:   4,
                minLines:   1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText:        'Ask something...',
                  hintStyle:       const TextStyle(color: AppColors.textSecondary),
                  filled:          true,
                  fillColor:       AppColors.background,
                  border:          OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide:   BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sending ? null : _send,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _sending ? AppColors.textSecondary : AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primaryBlue
              : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(18),
            topRight:    const Radius.circular(18),
            bottomLeft:  isUser ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
          ),
          border: isUser ? null : Border.all(color: AppColors.divider),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            fontSize: 14,
            height:   1.5,
            color:    isUser ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:  AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft:     Radius.circular(18),
            topRight:    Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft:  Radius.circular(4),
          ),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(delay: 0),
            const SizedBox(width: 4),
            _Dot(delay: 150),
            const SizedBox(width: 4),
            _Dot(delay: 300),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _anim,
        builder: (_, _) => Opacity(
          opacity: _anim.value,
          child: Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(
              color: AppColors.textSecondary, shape: BoxShape.circle,
            ),
          ),
        ),
      );
}
