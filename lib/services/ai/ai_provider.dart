import 'chat_message.dart';

/// نتیجه‌ی یک درخواست موفق به مدل AI
class AiReply {
  final String text;
  final String providerId;
  const AiReply(this.text, this.providerId);
}

/// خطای اختصاصی وقتی یک پرووایدر جواب نده (کلید غلط، قطعی شبکه، محدودیت و...)
/// AiService این خطا رو می‌گیره و پرووایدر بعدی توی زنجیره‌ی fallback رو امتحان می‌کنه.
class AiProviderException implements Exception {
  final String message;
  AiProviderException(this.message);
  @override
  String toString() => message;
}

/// قرارداد مشترک همه‌ی پرووایدرهای هوش مصنوعی (رایگان یا پولی).
/// برای اضافه‌کردن یک سرویس جدید (مثلاً یک API پولی اختصاصی)، کافیه
/// این کلاس رو پیاده‌سازی کنی و توی ai_registry.dart ثبتش کنی —
/// بقیه‌ی برنامه (تنظیمات، چت، fallback) بدون تغییر باهاش کار می‌کنه.
abstract class AiProvider {
  /// شناسه‌ی یکتا — برای ذخیره‌سازی کلید API و اولویت در SharedPreferences
  String get id;

  /// نام نمایشی در تنظیمات
  String get label;

  /// آیا این پرووایدر رایگانه یا نیاز به اشتراک/کلید پولی داره
  bool get isFree;

  /// آیا برای کارکردن نیاز به کلید API داره (بیشتر پرووایدرها بله؛ آفلاین نه)
  bool get requiresApiKey;

  /// توضیح کوتاه برای کاربر (مثلاً از کجا کلید رایگان بگیره)
  String get description;

  /// لینک صفحه‌ای که کاربر می‌تونه ازش کلید API رایگان/پولی بگیره
  String get apiKeyUrl;

  /// مدل پیش‌فرض (کاربر می‌تونه بعداً عوضش کنه)
  String get defaultModel;

  /// ارسال مکالمه و گرفتن پاسخ متنی
  Future<String> send({
    required List<ChatMessage> messages,
    required String apiKey,
    String? model,
    String? baseUrl, // فقط برای پرووایدر Custom/Paid کاربرد داره
  });
}
