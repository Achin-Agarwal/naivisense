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
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();

  String? _threadId;
  final List<ChatMessageModel> _messages = [];

  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final thread = await ref
        .read(chatbotRepositoryProvider)
        .getOrCreateThread();

    if (!mounted) return;

    setState(() => _threadId = thread.id);

    final msgs = await ref
        .read(chatbotRepositoryProvider)
        .getMessages(thread.id);

    if (!mounted) return;

    setState(() {
      _messages
        ..clear()
        ..addAll(msgs);
    });

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
      id: '',
      threadId: _threadId!,
      role: 'user',
      content: text,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _sending = true;
    });

    _scrollToBottom();

    try {
      final reply = await ref
          .read(chatbotRepositoryProvider)
          .sendMessage(_threadId!, text);

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
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.softCoral,
        ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive breakpoints
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
        final isDesktop = constraints.maxWidth >= 1024;

        // Responsive values
        final titleFontSize = isMobile ? 18.0 : 20.0;
        final badgeFontSize = isMobile ? 11.0 : 12.0;
        final horizontalPadding = isMobile ? 16.0 : 24.0;

        Widget chatBody = Column(
          children: [
            if (_threadId == null)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: _messages.isEmpty && !_sending
                    ? _buildWelcome(isMobile: isMobile)
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          16,
                          horizontalPadding,
                          8,
                        ),
                        itemCount: _messages.length + (_sending ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (_sending && i == _messages.length) {
                            return const _TypingBubble();
                          }

                          return _MessageBubble(message: _messages[i]);
                        },
                      ),
              ),

            _buildInput(isMobile: isMobile),
          ],
        );

        // Center content on tablet and desktop
        if (!isMobile) {
          chatBody = Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: chatBody,
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,

          // Prevent keyboard overflow
          resizeToAvoidBottomInset: true,

          appBar: AppBar(
            title: Text(
              'NaiviSense AI',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: titleFontSize,
              ),
            ),
            backgroundColor: AppColors.parentGradient.colors.last,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              Padding(
                padding: EdgeInsets.only(right: isMobile ? 12 : 16),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10 : 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'AI Chat',
                    style: TextStyle(
                      fontSize: badgeFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          body: SafeArea(child: chatBody),
        );
      },
    );
  }

  Widget _buildWelcome({required bool isMobile}) {
    final iconSize = isMobile ? 40.0 : 50.0;
    final titleSize = isMobile ? 20.0 : 24.0;
    final descSize = isMobile ? 14.0 : 15.0;
    final padding = isMobile ? 32.0 : 48.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: iconSize,
                  color: AppColors.primaryBlue,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Hello! I\'m NaiviSense AI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Ask me anything about your child\'s therapy, home activities, diet, or general guidance.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: descSize,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({required bool isMobile}) {
    final sendButtonSize = isMobile ? 44.0 : 48.0;
    final iconSize = isMobile ? 20.0 : 22.0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        8,
        isMobile ? 16 : 24,
        16,
      ),
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
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: 'Ask something...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 18,
                    vertical: isMobile ? 10 : 12,
                  ),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),

            const SizedBox(width: 8),

            GestureDetector(
              onTap: _sending ? null : _send,
              child: Container(
                width: sendButtonSize,
                height: sendButtonSize,
                decoration: BoxDecoration(
                  color: _sending
                      ? AppColors.textSecondary
                      : AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: iconSize,
                ),
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

    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive breakpoints
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    // Responsive bubble widths
    final maxBubbleWidth = isMobile
        ? screenWidth * 0.78
        : isTablet
        ? screenWidth * 0.65
        : 600.0;

    // Responsive spacing
    final horizontalPadding = isMobile ? 14.0 : 16.0;
    final verticalPadding = isMobile ? 10.0 : 12.0;
    final marginBottom = isMobile ? 12.0 : 16.0;
    final textFontSize = isMobile ? 14.0 : 15.0;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: marginBottom),

        constraints: BoxConstraints(maxWidth: maxBubbleWidth),

        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),

        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryBlue : AppColors.surface,

          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),

            bottomLeft: isUser
                ? const Radius.circular(18)
                : const Radius.circular(4),

            bottomRight: isUser
                ? const Radius.circular(4)
                : const Radius.circular(18),
          ),

          border: isUser ? null : Border.all(color: AppColors.divider),
        ),

        child: SelectableText(
          message.content,

          style: TextStyle(
            fontSize: textFontSize,
            height: 1.5,
            color: isUser ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive breakpoints
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    // Responsive sizing
    final horizontalPadding = isMobile ? 14.0 : 16.0;
    final verticalPadding = isMobile ? 12.0 : 14.0;
    final marginBottom = isMobile ? 12.0 : 16.0;
    final dotSpacing = isMobile ? 4.0 : 6.0;

    // Match message bubble width behavior
    final maxBubbleWidth = isMobile
        ? screenWidth * 0.78
        : isTablet
        ? screenWidth * 0.65
        : 600.0;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxBubbleWidth),
        child: Container(
          margin: EdgeInsets.only(bottom: marginBottom),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _Dot(delay: 0),
              SizedBox(width: dotSpacing),
              const _Dot(delay: 150),
              SizedBox(width: dotSpacing),
              const _Dot(delay: 300),
            ],
          ),
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
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _ctrl.repeat(reverse: true);
      }
    });

    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive dot size
    final dotSize = screenWidth < 600 ? 8.0 : 10.0;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Opacity(
          opacity: _anim.value,
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: const BoxDecoration(
              color: AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
