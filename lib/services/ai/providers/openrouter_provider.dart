import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ai_provider.dart';
import '../chat_message.dart';

/// OpenRouter — دروازه‌ای به ده‌ها مدل مختلف، شامل چندتا مدل کاملاً رایگان
/// (با پسوند :free در اسم مدل). کلید رایگان از openrouter.ai قابل دریافته.
class OpenRouterProvider implements AiProvider {
  @override
  String get id => 'openrouter';
  @override
  String get label => 'OpenRouter (چند مدل رایگان)';
  @override
  bool get isFree => true;
  @override
  bool get requiresApiKey => true;
  @override
  String get description => 'کلید رایگان از OpenRouter بگیر — دسترسی به چندین مدل رایگان با پسوند :free.';
  @override
  String get apiKeyUrl => 'https://openrouter.ai/keys';
  @override
  String get defaultModel => 'meta-llama/llama-3.1-8b-instruct:free';

  @override
  Future<String> send({
    required List<ChatMessage> messages,
    required String apiKey,
    String? model,
    String? baseUrl,
  }) async {
    final uri = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    final res = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
            'X-Title': 'Mana Dastyar',
          },
          body: jsonEncode({
            'model': model ?? defaultModel,
            'messages': messages.map((m) => {'role': m.role, 'content': m.content}).toList(),
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (res.statusCode != 200) {
      throw AiProviderException('OpenRouter خطا داد (${res.statusCode}): ${res.body}');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    try {
      return data['choices'][0]['message']['content'] as String;
    } catch (_) {
      throw AiProviderException('پاسخ OpenRouter قابل‌خوندن نبود.');
    }
  }
}
