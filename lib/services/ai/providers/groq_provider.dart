import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ai_provider.dart';
import '../chat_message.dart';

/// Groq — استنتاج فوق‌سریع، سطح رایگان سخاوتمند برای مدل‌های متن‌باز (Llama و...)
/// کلید رایگان از console.groq.com قابل دریافته.
class GroqProvider implements AiProvider {
  @override
  String get id => 'groq';
  @override
  String get label => 'Groq (رایگان و سریع)';
  @override
  bool get isFree => true;
  @override
  bool get requiresApiKey => true;
  @override
  String get description => 'کلید رایگان از Groq Console بگیر — پاسخ‌ها خیلی سریعن.';
  @override
  String get apiKeyUrl => 'https://console.groq.com/keys';
  @override
  String get defaultModel => 'llama-3.1-8b-instant';

  @override
  Future<String> send({
    required List<ChatMessage> messages,
    required String apiKey,
    String? model,
    String? baseUrl,
  }) async {
    final uri = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    final res = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': model ?? defaultModel,
            'messages': messages.map((m) => {'role': m.role, 'content': m.content}).toList(),
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (res.statusCode != 200) {
      throw AiProviderException('Groq خطا داد (${res.statusCode}): ${res.body}');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    try {
      return data['choices'][0]['message']['content'] as String;
    } catch (_) {
      throw AiProviderException('پاسخ Groq قابل‌خوندن نبود.');
    }
  }
}
