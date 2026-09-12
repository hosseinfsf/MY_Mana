import '../ai_provider.dart';
import '../chat_message.dart';

/// یک پرووایدر «آفلاین» بدون نیاز به کلید یا اینترنت —
/// وقتی هیچ پرووایدر دیگه‌ای جواب نداد (بدون کلید، بدون اینترنت، قطعی سرویس)
/// حداقل یه پاسخ رفیقانه و راهنما به کاربر نشون داده میشه، نه یه پیام خطای خشک.
class OfflineFallbackProvider implements AiProvider {
  @override
  String get id => 'offline';
  @override
  String get label => 'حالت آفلاین (بدون نیاز به کلید)';
  @override
  bool get isFree => true;
  @override
  bool get requiresApiKey => false;
  @override
  String get description => 'وقتی هیچ سرویس دیگه‌ای در دسترس نباشه، این حالت فعال میشه.';
  @override
  String get apiKeyUrl => '';
  @override
  String get defaultModel => 'offline';

  @override
  Future<String> send({
    required List<ChatMessage> messages,
    required String apiKey,
    String? model,
    String? baseUrl,
  }) async {
    return 'الان به اینترنت یا هیچ سرویس AI‌ای وصل نیستم 😅\n'
        'برای اینکه بتونم درست‌وحسابی جواب بدم، از تب «بیشتر ← هوش مصنوعی» یکی از '
        'سرویس‌های رایگان (Gemini، Groq یا OpenRouter) رو با یه کلید API رایگان وصل کن.';
  }
}
