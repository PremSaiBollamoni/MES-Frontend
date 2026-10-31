import 'package:flutter/material.dart';
import '../components/app_button.dart' show AppPrimaryButton;
import '../components/app_text_field.dart';
import '../components/custom_toast.dart';
import '../services/support_api_service.dart';
import '../utils/theme_tokens.dart';

class _ChatMessage {
  final String role; // "user" or "assistant"
  final String content;
  const _ChatMessage(this.role, this.content);
}

class SupportChatScreen extends StatefulWidget {
  /// True for the Login screen's entry point - no one's authenticated yet, so the
  /// chat uses the unauthenticated endpoints and Raise Ticket asks for a username
  /// (there's no JWT to read an identity from).
  final bool isPublic;

  const SupportChatScreen({super.key, this.isPublic = false});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final SupportApiService _apiService = SupportApiService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      "assistant",
      "Hi! I'm the SMO help assistant. Ask me anything about using the app - "
          "attendance, production entry, stock, payroll, reports. If I can't "
          "sort it out, just describe the problem and tap Raise Ticket above - "
          "I'll draft the ticket for you from what we talked about.",
    ),
  ];
  bool _isSending = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _messages.add(_ChatMessage("user", text));
      _isSending = true;
      _inputController.clear();
    });
    _scrollToBottom();

    try {
      final history = _messages.map((m) => {"role": m.role, "content": m.content}).toList();
      final reply = widget.isPublic
          ? await _apiService.sendPublicChatMessage(history)
          : await _apiService.sendChatMessage(history);
      setState(() => _messages.add(_ChatMessage("assistant", reply)));
    } catch (e) {
      setState(() => _messages.add(const _ChatMessage(
            "assistant",
            "Sorry, I couldn't reach the support assistant right now. Try Raise Ticket instead.",
          )));
    } finally {
      setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _showDraftingDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeTokens.surfaceSolid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge)),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: ThemeTokens.primary),
            ),
            const SizedBox(width: 16),
            Text("Drafting your ticket...", style: ThemeTokens.bodyMedium),
          ],
        ),
      ),
    );
  }

  Future<void> _raiseTicket() async {
    final usernameController = TextEditingController();
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();

    // Let the AI draft the subject/description from the conversation so far, so the
    // employee reviews and edits instead of writing it up from scratch. Only worth
    // doing once there's an actual conversation beyond the opening greeting.
    if (_messages.length > 1) {
      final history = _messages.map((m) => {"role": m.role, "content": m.content}).toList();
      _showDraftingDialog();
      try {
        final draft = await _apiService.draftTicket(history, isPublic: widget.isPublic);
        subjectController.text = draft.subject;
        descriptionController.text = draft.description;
      } catch (e) {
        // AI drafting failed - fall back to the raw transcript so nothing's lost;
        // the employee can still clean it up before submitting.
        descriptionController.text = _messages
            .map((m) => "${m.role == 'user' ? 'Me' : 'Assistant'}: ${m.content}")
            .join("\n\n");
      } finally {
        if (mounted) Navigator.of(context).pop(); // close the drafting dialog
      }
    }

    if (!mounted) return;
    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeTokens.surfaceSolid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: ThemeTokens.primaryGradient,
                borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.confirmation_number_rounded, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text("Raise Ticket", style: ThemeTokens.headingMedium),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isPublic) ...[
                AppTextField(controller: usernameController, label: "Username"),
                const SizedBox(height: 14),
              ],
              AppTextField(controller: subjectController, label: "Subject"),
              const SizedBox(height: 14),
              AppTextField(controller: descriptionController, label: "Description", maxLines: 5),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel")),
          AppPrimaryButton(label: "Submit", onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );

    if (submitted != true) return;
    if (subjectController.text.trim().isEmpty || descriptionController.text.trim().isEmpty) {
      if (mounted) CustomToast.show(context, "Subject and description are required");
      return;
    }
    if (widget.isPublic && usernameController.text.trim().isEmpty) {
      if (mounted) CustomToast.show(context, "Username is required");
      return;
    }

    try {
      if (widget.isPublic) {
        await _apiService.raisePublicTicket(
          usernameController.text.trim(),
          subjectController.text.trim(),
          descriptionController.text.trim(),
        );
      } else {
        await _apiService.raiseTicket(subjectController.text.trim(), descriptionController.text.trim());
      }
      if (mounted) CustomToast.show(context, "Ticket raised - the admin team will follow up");
    } catch (e) {
      if (mounted) CustomToast.show(context, "Couldn't raise ticket: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.surfaceSunken,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              itemCount: _messages.length + (_isSending ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _messages.length) {
                  return _buildBubble(const _ChatMessage("assistant", ""), isTyping: true);
                }
                return _buildBubble(_messages[index]);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ThemeTokens.surfaceSolid,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(gradient: ThemeTokens.primaryGradient, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("AI Assistant", style: ThemeTokens.bodyLarge.copyWith(fontSize: 14.5)),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(color: ThemeTokens.primary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text("Online", style: ThemeTokens.caption),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Material(
            color: ThemeTokens.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
            child: InkWell(
              borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
              onTap: _raiseTicket,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.confirmation_number_outlined, color: ThemeTokens.primaryDark, size: 16),
                    const SizedBox(width: 6),
                    Text("Raise Ticket", style: ThemeTokens.caption.copyWith(color: ThemeTokens.primaryDark, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: ThemeTokens.surfaceSolid,
        boxShadow: [BoxShadow(color: ThemeTokens.ink.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ThemeTokens.surfaceSunken,
                borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                border: Border.all(color: ThemeTokens.hairline),
              ),
              child: TextField(
                controller: _inputController,
                style: ThemeTokens.inputText,
                decoration: InputDecoration(
                  hintText: "Ask a question...",
                  hintStyle: ThemeTokens.hintText,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                ),
                onSubmitted: (_) => _send(),
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: Ink(
              decoration: BoxDecoration(
                gradient: _isSending ? null : ThemeTokens.primaryGradient,
                color: _isSending ? ThemeTokens.textMuted : null,
                shape: BoxShape.circle,
                boxShadow: _isSending ? null : ThemeTokens.glowShadow,
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _isSending ? null : _send,
                child: const Padding(
                  padding: EdgeInsets.all(13),
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(_ChatMessage message, {bool isTyping = false}) {
    final isUser = message.role == "user";
    final avatar = Container(
      width: 30,
      height: 30,
      margin: EdgeInsets.only(right: isUser ? 0 : 8, left: isUser ? 8 : 0),
      decoration: BoxDecoration(
        gradient: isUser ? null : ThemeTokens.primaryGradient,
        color: isUser ? ThemeTokens.inkSoft : null,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        isUser ? Icons.person_rounded : Icons.support_agent_rounded,
        color: Colors.white,
        size: 16,
      ),
    );

    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUser ? ThemeTokens.primary : ThemeTokens.surfaceSolid,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(ThemeTokens.radiusMedium),
          topRight: const Radius.circular(ThemeTokens.radiusMedium),
          bottomLeft: Radius.circular(isUser ? ThemeTokens.radiusMedium : 4),
          bottomRight: Radius.circular(isUser ? 4 : ThemeTokens.radiusMedium),
        ),
        boxShadow: ThemeTokens.cardShadow,
      ),
      child: isTyping
          ? const _TypingDots()
          : Text(
              message.content,
              style: ThemeTokens.bodyMedium.copyWith(
                color: isUser ? Colors.white : ThemeTokens.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: isUser
            ? [Flexible(child: bubble), avatar]
            : [avatar, Flexible(child: bubble)],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 14,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) {
              final t = ((_controller.value + (i * 0.2)) % 1.0);
              final scale = 0.5 + 0.5 * (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
              return Transform.scale(
                scale: 0.6 + 0.4 * scale,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: ThemeTokens.textLight, shape: BoxShape.circle),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
