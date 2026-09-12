/// یک پیام ساده در مکالمه — برای همه‌ی پرووایدرهای AI مشترکه
class ChatMessage {
  final String role; // 'system' | 'user' | 'assistant'
  final String content;
  const ChatMessage({required this.role, required this.content});

  factory ChatMessage.system(String content) => ChatMessage(role: 'system', content: content);
  factory ChatMessage.user(String content) => ChatMessage(role: 'user', content: content);
  factory ChatMessage.assistant(String content) => ChatMessage(role: 'assistant', content: content);
}
