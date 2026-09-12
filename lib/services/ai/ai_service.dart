import 'ai_registry.dart';
import 'ai_settings.dart';
import 'chat_message.dart';

/// نتیجه‌ی نهایی یک درخواست چت — شامل اینکه بالاخره کدوم پرووایدر جواب داد
class AiChatResult {
  final String text;
  final String usedProviderId;
  final bool wasFallback; // یعنی پرووایدر اول جواب نداد و رفتیم سراغ بعدی
  const AiChatResult(this.text, this.usedProviderId, this.wasFallback);
}

/// این سرویس، پیام کاربر رو می‌گیره و به‌ترتیب اولویت (که در AiSettings مشخص شده)
/// پرووایدرها رو امتحان می‌کنه. اگه یکی به هر دلیلی (کلید غلط، قطعی شبکه، محدودیت)
/// جواب نداد، خودکار میره سراغ بعدی — دقیقاً همون «سیستم fallback» که در سند اولیه‌ی
/// پروژه خواسته شده بود. اگه هیچ‌کدوم جواب ندن، در نهایت پرووایدر آفلاین یه پاسخ راهنما میده.
class AiService {
  final AiSettings settings;
  const AiService(this.settings);

  Future<AiChatResult> chat(List<ChatMessage> messages) async {
    final chain = settings.activeChain;
    final orderedIds = chain.isNotEmpty ? chain : ['offline'];

    Object? lastError;
    for (var i = 0; i < orderedIds.length; i++) {
      final id = orderedIds[i];
      final provider = AiRegistry.byId(id);
      try {
        final key = settings.apiKeyFor(id);
        if (provider.requiresApiKey && key.trim().isEmpty) {
          continue; // بدون کلید، این یکی رو رد کن
        }
        final text = await provider.send(
          messages: messages,
          apiKey: key,
          model: settings.modelFor(id),
          baseUrl: id == 'custom_paid' ? settings.customBaseUrl : null,
        );
        return AiChatResult(text, id, i > 0);
      } catch (e) {
        lastError = e;
        continue; // برو سراغ پرووایدر بعدی توی زنجیره
      }
    }

    // اگه به اینجا رسیدیم یعنی هیچ‌کدوم جواب ندادن؛ آفلاین رو به‌عنوان آخرین راه‌حل صدا می‌زنیم
    final offline = AiRegistry.byId('offline');
    final text = await offline.send(messages: messages, apiKey: '');
    return AiChatResult(
      lastError != null ? text : text,
      'offline',
      true,
    );
  }
}
