import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ai_provider.dart';
import '../chat_message.dart';

/// Google Gemini — یکی از سخاوتمندترین سطح‌های رایگان بین مدل‌های AI.
/// کلید رایگان از aistudio.google.com قابل دریافته.
class GeminiProvider implements AiProvider {
  @override
  String get id => 'gemini';
  @override
  String get label => 'Google Gemini (رایگان)';
  @override
  bool get isFree => true;
  @override
  bool get requiresApiKey => true;
  @override
  String get description => 'کلید رایگان از Google AI Studio بگیر و اینجا وارد کن.';
  @override
  String get apiKeyUrl => 'https://aistudio.google.com/app/apikey';
  @override
  String get defaultModel => 'gemini-2.0-flash';

  @override
  Future<String> send({
    required List<ChatMessage> messages,
    required String apiKey,
    String? model,
    String? baseUrl,
  }) async {
    final m = model ?? defaultModel;
    final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$m:generateContent?key=$apiKey');

    // جمینای فرمت پیام‌ها رو به‌صورت contents با role user/model می‌خواد؛
    // پیام‌های system رو به ابتدای اولین پیام کاربر می‌چسبونیم.
    final systemParts = messages.where((e) => e.role == 'system').map((e) => e.content).join('\n');
    final convo = messages.where((e) => e.role != 'system').toList();

    final contents = <Map<String, dynamic>>[];
    for (var i = 0; i < convo.length; i++) {
      final msg = convo[i];
      var text = msg.content;
      if (i == 0 && systemParts.isNotEmpty && msg.role == 'user') {
        text = '$systemParts\n\n$text';
      }
      contents.add({
        'role': msg.role == 'assistant' ? 'model' : 'user',
        'parts': [
          {'text': text}
        ],
      });
    }

    final res = await http
        .post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'contents': contents}))
        .timeout(const Duration(seconds: 30));

    if (res.statusCode != 200) {
      throw AiProviderException('Gemini خطا داد (${res.statusCode}): ${res.body}');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    try {
      return data['candidates'][0]['content']['parts'][0]['text'] as String;
    } catch (_) {
      throw AiProviderException('پاسخ Gemini قابل‌خوندن نبود.');
    }
  }
}
