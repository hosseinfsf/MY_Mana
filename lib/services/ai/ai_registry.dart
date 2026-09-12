import 'ai_provider.dart';
import 'providers/gemini_provider.dart';
import 'providers/groq_provider.dart';
import 'providers/openrouter_provider.dart';
import 'providers/custom_paid_provider.dart';
import 'providers/offline_provider.dart';

/// همه‌ی پرووایدرهای موجود در برنامه.
/// برای اضافه‌کردن یک سرویس جدید (رایگان یا پولی)، فقط کافیه اینجا یک خط اضافه بشه.
class AiRegistry {
  static final List<AiProvider> all = [
    GeminiProvider(),
    GroqProvider(),
    OpenRouterProvider(),
    CustomPaidProvider(),
    OfflineFallbackProvider(),
  ];

  static AiProvider byId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => all.last);

  /// ترتیب پیش‌فرض زنجیره‌ی fallback: اول رایگان‌ها، بعد پولی، در آخر آفلاین
  static List<String> get defaultPriority => all.map((p) => p.id).toList();
}
