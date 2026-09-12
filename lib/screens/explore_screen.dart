import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/glass_card.dart';

class _Category {
  final String id;
  final String icon;
  final String label;
  final String detailTag;
  final String detailText;
  final bool golden;
  const _Category(this.id, this.icon, this.label, this.detailTag, this.detailText,
      {this.golden = false});
}

const _golden = [
  _Category('cooking', '🍳', 'آشپزی', '🍳 آشپزی',
      'بیا امروز یه غذای درست‌وحسابی بزنیم، نه باز هم نیمرو 😂 چی داری تو یخچال؟',
      golden: true),
  _Category('news', '📰', 'اخبار', '📰 اخبار',
      'پرسپولیس دیشب با نتیجه ۲ بر ۱ به برتری رسید.',
      golden: true),
  _Category('movies', '🎬', 'فیلم و سریال', '🎬 فیلم و سریال',
      '«یک شب مه‌آلود» - دراما، ۱۱۰ دقیقه، پیشنهاد امروز مانا.',
      golden: true),
  _Category('books', '📚', 'کتاب', '📚 کتاب',
      'ملت عشق، الیف شافاک — چون رمان‌های عاطفی رو دوست داشتی.',
      golden: true),
  _Category('ai', '🤖', 'هوش مصنوعی', '🤖 هوش مصنوعی',
      'یه خبر تازه از دنیای AI، به زبون ساده.',
      golden: true),
  _Category('money', '💰', 'پول و اقتصاد', '💰 پول و اقتصاد',
      'یه نکته‌ی کوتاه برای مدیریت بهتر پول روزمره.',
      golden: true),
  _Category('facts', '🧠', 'دانستنی', '🧠 دانستنی',
      '۸۰٪ گرمای بدن از سر خارج میشه — به همین خاطر کلاه زمستونی مهمه.',
      golden: true),
  _Category('puzzle', '🧩', 'معما', '🧩 معما',
      'چه چیزی هر چقدر ازش برداری، بزرگ‌تر میشه؟',
      golden: true),
  _Category('tips', '💡', 'ترفند', '💡 ترفند',
      'برای باز کردن سریع درِ شیشه مربا، زیرش رو زیر آب گرم بگیر.',
      golden: true),
  _Category('fun', '🔮', 'سرگرمی', '🔮 سرگرمی روزانه',
      'یه تست شخصیت کوتاه امروز، امتحانش کن.',
      golden: true),
];

const _more = [
  _Category('music', '🎵', 'موسیقی', '🎵 موسیقی', 'پیشنهاد پلی‌لیست امروز، هماهنگ با حال‌وهوات.'),
  _Category('space', '🌌', 'علم و فضا', '🌌 علم و فضا', 'نور خورشید ۸ دقیقه طول می‌کشه تا به زمین برسه.'),
  _Category('home', '🏠', 'خانه', '🏠 خانه و زندگی', 'یه ایده‌ی کوچیک برای مرتب‌تر شدن آشپزخونه در ۵ دقیقه.'),
  _Category('history', '🏛️', 'تاریخ', '🏛️ تاریخ و تمدن', 'در چنین روزی، اتفاق مهمی برای تمدن ایران رخ داده.'),
  _Category('fitness', '🏋️', 'ورزش', '🏋️ ورزش و فیتنس', 'یه حرکت کششی ۲ دقیقه‌ای برای کمردرد ناشی از نشستن زیاد.'),
];

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  _Category? selected;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppState>().colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
      children: [
        Text('کاوش', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: c.textHi)),
        const SizedBox(height: 14),
        _label('⭐', 'پرطرفدارها', c),
        _grid(_golden, c),
        _label('✨', 'بیشتر', c),
        _grid(_more, c),
        if (selected != null) ...[
          const SizedBox(height: 8),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(selected!.detailTag,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.accent2)),
                const SizedBox(height: 8),
                Text(selected!.detailText, style: TextStyle(fontSize: 12.5, height: 1.85, color: c.textHi)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _label(String icon, String text, dynamic c) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10, right: 2),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: c.textHi)),
      ]),
    );
  }

  Widget _grid(List<_Category> items, dynamic c) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 9,
      crossAxisSpacing: 9,
      childAspectRatio: 1.05,
      children: items.map((cat) {
        final isSel = selected?.id == cat.id;
        return GestureDetector(
          onTap: () => setState(() => selected = cat),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: isSel
                      ? LinearGradient(colors: [c.accent1Soft, c.accent2Soft])
                      : null,
                  color: isSel ? null : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isSel ? c.accent2 : Colors.white.withOpacity(0.14)),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 6),
                    Text(cat.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10.5, color: c.textHi)),
                  ],
                ),
              ),
              if (cat.golden)
                const Positioned(top: 6, right: 6, child: Text('⭐', style: TextStyle(fontSize: 9))),
            ],
          ),
        );
      }).toList(),
    );
  }
}
