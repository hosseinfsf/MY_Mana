import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../services/ai/ai_settings.dart';
import '../services/ai/ai_registry.dart';
import '../services/ai/ai_provider.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final c = app.colors;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
      children: [
        Text('بیشتر', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: c.textHi)),
        const SizedBox(height: 16),

        // ---------------- AI SECTION ----------------
        _sectionTitle('🤖 هوش مصنوعی', c),
        Text(
          'مانا می‌تونه با چند سرویس AI رایگان کار کنه. یه کلید رایگان از یکی‌شون بگیر و اینجا وارد کن. '
          'اگه بیشتر از یکی رو فعال کنی، اگه یکی جواب نده، مانا خودکار میره سراغ بعدی.',
          style: TextStyle(fontSize: 11, color: c.textLo, height: 1.8),
        ),
        const SizedBox(height: 12),
        const _AiProvidersList(),

        _settingsSwitch(
          context,
          'حالت مات (Matte)',
          'شدت تیرگی پس‌زمینه شیشه‌ای',
          app.matte,
          (v) => app.setMatte(v),
          c,
        ),

        _sectionTitle('شفافیت شیشه‌ای', c),
        Slider(
          value: app.glassOpacity,
          min: 0.04,
          max: 0.30,
          activeColor: c.accent2,
          inactiveColor: Colors.white24,
          onChanged: (v) => app.setGlassOpacity(v),
        ),

        _sectionTitle('تم رنگی', c),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: manaThemes.map((t) {
            final active = t.id == app.themeId;
            return GestureDetector(
              onTap: () => app.setTheme(t.id),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [t.accent1, t.accent2]),
                  border: Border.all(color: active ? Colors.white : Colors.transparent, width: 2),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        Text(themeById(app.themeId).label, style: TextStyle(fontSize: 11, color: c.textLo)),

        _sectionTitle('زبان برنامه', c),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              _langBtn(context, 'فارسی', ManaLang.fa, app, c),
              _langBtn(context, 'English', ManaLang.en, app, c),
            ],
          ),
        ),

        const SizedBox(height: 10),
        _settingsSwitch(context, 'MANA Memory', 'یادگیری خودکار از سلیقه‌ی تو', true, (_) {}, c),
        _settingsSwitch(context, 'اعلان شناور', 'نوتیفیکیشن روی آیکون شناور', true, (_) {}, c),
        _settingsSwitch(context, 'ترجمه با یک کلید', 'ترجمه فوری متن صفحه', false, (_) {}, c),

        const SizedBox(height: 20),
        Center(
          child: Text('نسخه ۰.۲.۰ — پیش‌نمایش توسعه',
              style: TextStyle(fontSize: 10.5, color: c.textLo)),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text, dynamic c) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(text, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.textHi)),
      );

  Widget _settingsSwitch(BuildContext context, String label, String sub, bool value,
      ValueChanged<bool> onChanged, dynamic c) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06)))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12.5, color: c.textHi)),
                const SizedBox(height: 2),
                Text(sub, style: TextStyle(fontSize: 10.5, color: c.textLo)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: c.accent2,
            activeTrackColor: c.accent1,
          ),
        ],
      ),
    );
  }

  Widget _langBtn(BuildContext context, String label, ManaLang lang, AppState app, dynamic c) {
    final active = app.lang == lang;
    return Expanded(
      child: GestureDetector(
        onTap: () => app.setLang(lang),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            gradient: active ? c.accentGradient : null,
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: active ? Colors.white : c.textLo,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
        ),
      ),
    );
  }
}

/// لیست کارت‌های پرووایدرهای AI با امکان وارد کردن کلید، فعال/غیرفعال کردن و اولویت‌دهی
class _AiProvidersList extends StatelessWidget {
  const _AiProvidersList();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final ai = context.watch<AiSettings>();
    final c = app.colors;

    // پرووایدر آفلاین رو توی این لیست نشون نمی‌دیم چون همیشه خودکار فعاله و نیاز به تنظیم نداره
    final visible = AiRegistry.all.where((p) => p.id != 'offline').toList();

    return Column(
      children: visible.map((provider) {
        final enabled = ai.isEnabled(provider.id);
        final hasKey = ai.apiKeyFor(provider.id).trim().isNotEmpty;
        final isTop = ai.activeChain.isNotEmpty && ai.activeChain.first == provider.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isTop ? c.accent2 : Colors.white.withOpacity(0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(provider.label,
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.textHi)),
                        if (isTop) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                gradient: c.accentGradient, borderRadius: BorderRadius.circular(8)),
                            child: const Text('پیش‌فرض', style: TextStyle(fontSize: 9, color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Switch(
                    value: enabled,
                    activeColor: c.accent2,
                    activeTrackColor: c.accent1,
                    onChanged: hasKey || !provider.requiresApiKey
                        ? (v) => ai.setEnabled(provider.id, v)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(provider.description, style: TextStyle(fontSize: 10.5, color: c.textLo, height: 1.6)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _openKeyDialog(context, provider, ai),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: c.textHi,
                        side: BorderSide(color: Colors.white.withOpacity(0.16)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(hasKey ? '✏️ ویرایش کلید' : '🔑 وارد کردن کلید', style: const TextStyle(fontSize: 11.5)),
                    ),
                  ),
                  if (enabled && hasKey) ...[
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => ai.moveToTop(provider.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: c.accent2,
                        side: BorderSide(color: c.accent2.withOpacity(0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('اولویت', style: TextStyle(fontSize: 11.5)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _openKeyDialog(BuildContext context, AiProvider provider, AiSettings ai) {
    final keyCtrl = TextEditingController(text: ai.apiKeyFor(provider.id));
    final modelCtrl = TextEditingController(text: ai.modelFor(provider.id) ?? provider.defaultModel);
    final urlCtrl = TextEditingController(text: ai.customBaseUrl);
    final isCustom = provider.id == 'custom_paid';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1030),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(provider.label, style: const TextStyle(color: Colors.white, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(provider.description,
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11.5, height: 1.7)),
            const SizedBox(height: 14),
            if (isCustom) ...[
              _dialogField(urlCtrl, 'آدرس API (endpoint)'),
              const SizedBox(height: 10),
            ],
            _dialogField(keyCtrl, 'کلید API'),
            const SizedBox(height: 10),
            _dialogField(modelCtrl, 'اسم مدل'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('انصراف', style: TextStyle(color: Colors.white.withOpacity(0.6))),
          ),
          ElevatedButton(
            onPressed: () async {
              await ai.setApiKey(provider.id, keyCtrl.text.trim());
              await ai.setModel(provider.id, modelCtrl.text.trim());
              if (isCustom) await ai.setCustomBaseUrl(urlCtrl.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 12.5),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11.5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white54),
        ),
      ),
    );
  }
}
