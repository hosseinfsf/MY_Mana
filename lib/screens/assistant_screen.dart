import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../services/ai/ai_settings.dart';
import '../services/ai/ai_service.dart';
import '../services/ai/chat_message.dart';
import '../services/ai/ai_registry.dart';
import 'more_screen.dart';

class DisplayMsg {
  final String text;
  final bool fromUser;
  final bool isError;
  DisplayMsg(this.text, this.fromUser, {this.isError = false});
}

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final ctrl = TextEditingController();
  final scrollCtrl = ScrollController();
  bool sending = false;

  final List<DisplayMsg> messages = [
    DisplayMsg('سلام 🌙 من مانام. هر چی لازم داری بپرس — از پیشنهاد غذا و فیلم بگیر تا خلاصه‌ی یه خبر یا کمک با یه متن.', false),
  ];

  static const String _systemPrompt =
      'تو «مانا» هستی؛ یک دستیار هوش مصنوعی فارسی‌زبان با لحن رفیقانه، گرم و کمی شوخ. '
      'همیشه محاوره‌ای و صمیمی جواب بده، نه رسمی و خشک. جواب‌ها رو کوتاه و مفید نگه دار.';

  Future<void> _send([String? preset]) async {
    final text = (preset ?? ctrl.text).trim();
    if (text.isEmpty || sending) return;

    final aiSettings = context.read<AiSettings>();
    final service = AiService(aiSettings);

    setState(() {
      messages.add(DisplayMsg(text, true));
      ctrl.clear();
      sending = true;
    });
    _scrollToBottom();

    try {
      final history = <ChatMessage>[
        ChatMessage.system(_systemPrompt),
        ...messages.map((m) => m.fromUser ? ChatMessage.user(m.text) : ChatMessage.assistant(m.text)),
      ];
      final result = await service.chat(history);
      setState(() {
        messages.add(DisplayMsg(result.text, false));
        sending = false;
      });
    } catch (e) {
      setState(() {
        messages.add(DisplayMsg('یه مشکلی پیش اومد: $e', false, isError: true));
        sending = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollCtrl.hasClients) {
        scrollCtrl.animateTo(scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppState>().colors;
    final aiSettings = context.watch<AiSettings>();
    final hasActiveProvider = aiSettings.activeChain.any((id) => id != 'offline');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text('دستیار مانا',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: c.textHi)),
              ),
              if (!hasActiveProvider)
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MoreScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('⚠️ بدون AI فعال', style: TextStyle(fontSize: 10.5, color: Colors.orange)),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: c.accent1Soft, borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    AiRegistry.byId(aiSettings.activeChain.first).label,
                    style: TextStyle(fontSize: 10, color: c.textHi),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _quickChip('🍳 چی بپزم؟', c),
                _quickChip('🎬 فیلم خوب معرفی کن', c),
                _quickChip('📰 این خبر رو خلاصه کن', c),
                _quickChip('📚 این کتاب ارزش خوندن داره؟', c),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              itemCount: messages.length + (sending ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == messages.length && sending) {
                  return Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration:
                          BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(16)),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: c.accent2),
                      ),
                    ),
                  );
                }
                final m = messages[i];
                return Align(
                  alignment:
                      m.fromUser ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      gradient: m.fromUser ? c.accentGradient : null,
                      color: m.fromUser
                          ? null
                          : (m.isError ? Colors.red.withOpacity(0.12) : Colors.white.withOpacity(0.06)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(
                          fontSize: 12.5, height: 1.8, color: m.fromUser ? Colors.white : c.textHi),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.14)),
                  ),
                  child: TextField(
                    controller: ctrl,
                    style: TextStyle(fontSize: 12.5, color: c.textHi),
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'پیامت رو بنویس...',
                      hintStyle: TextStyle(color: c.textLo),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: sending ? null : () => _send(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: c.accentGradient,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickChip(String label, dynamic c) {
    return GestureDetector(
      onTap: () => _send(label.replaceAll(RegExp(r'^[^\s]+\s'), '')),
      child: Container(
        margin: const EdgeInsetsDirectional.only(end: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withOpacity(0.14)),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(fontSize: 11, color: c.textHi)),
      ),
    );
  }
}
