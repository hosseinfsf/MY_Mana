import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ai_provider.dart';
import '../chat_message.dart';

/// پرووایدر «سفارشی / پولی» — اینجا محلیه که نسخه‌ی پولی مانا وصل میشه.
/// هر endpoint سازگار با فرمت OpenAI chat/completions (که اکثر سرویس‌های
/// پولی هم همینو پشتیبانی می‌کنن، مثل OpenAI خودش یا یک بک‌اند اختصاصی)
/// از همینجا با وارد کردن baseUrl + کلید + اسم مدل قابل استفاده‌ست.
class CustomPaidProvider implements AiProvider {
  @override
  String get id => 'custom_paid';
  @override
  String get label => 'مانا پرو / سفارشی (پولی)';
  @override
  bool get isFree => false;
  @override
  bool get requiresApiKey => true;
  @override
  String get description =>
      'برای نسخه‌ی پولی مانا: آدرس API، کلید و اسم مدل رو اینجا وارد کن (سازگار با فرمت OpenAI).';
  @override
  String get apiKeyUrl => 'https://platform.openai.com/api-keys';
  @override
  String get defaultModel => 'gpt-4o-mini';

  static const defaultBaseUrl = 'https://api.openai.com/v1/chat/completions';

  @override
  Future<String> send({
    required List<ChatMessage> messages,
    required String apiKey,
    String? model,
    String? baseUrl,
  }) async {
    final uri = Uri.parse((baseUrl == null || baseUrl.isEmpty) ? defaultBaseUrl : baseUrl);
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
        .timeout(const Duration(seconds: 40));

    if (res.statusCode != 200) {
      throw AiProviderException('سرویس پولی خطا داد (${res.statusCode}): ${res.body}');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    try {
      return data['choices'][0]['message']['content'] as String;
    } catch (_) {
      throw AiProviderException('پاسخ سرویس پولی قابل‌خوندن نبود.');
    }
  }
}
