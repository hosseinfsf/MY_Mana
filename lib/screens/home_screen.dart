import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/glass_card.dart';
import '../utils/jalali.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool movieLiked = false;
  bool movieDisliked = false;
  final askCtrl = TextEditingController();

  /// جمله‌ی خوش‌آمد با شخصیتِ زمان‌آگاه مانا (بند ۲۳ سند مشخصات)
  ({String title, String line}) _greeting(String name) {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 11) {
      return (title: 'صبح بخیر $name 👋', line: 'امروز قرار نیست همه‌چیز رو حل کنی؛ فقط یکی‌شون رو شروع کن. 😉');
    } else if (h >= 11 && h < 17) {
      return (title: 'سلام $name 👋', line: 'یه نفس بکش، وسط روزی — چند تا خبر خوب برات دارم.');
    } else if (h >= 17 && h < 23) {
      return (title: 'شب بخیر $name 🌙', line: 'امروز چطور بود؟ بیا با یه چیز خوب تمومش کنیم.');
    }
    return (title: 'هنوز بیداری $name؟ 😐😂', line: 'بیا حداقل یه چیز جالب ببینیم، بعد بگیر بخواب 😴');
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final c = app.colors;
    final name = app.profile.name.isNotEmpty ? app.profile.name : 'دوست من';
    final g = _greeting(name);
    final now = DateTime.now();
    final jalali = JalaliDate.fromDateTime(now);
    final dateStr = jalali.formatFull(now);
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final city = app.profile.city.isNotEmpty ? app.profile.city : 'تهران';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
      children: [
        // ---------- greeting header ----------
        Text(g.title,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: c.textHi)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            Text(dateStr, style: TextStyle(fontSize: 12, color: c.textLo)),
            Text('·', style: TextStyle(color: c.textLo)),
            Text(timeStr, style: TextStyle(fontSize: 12, color: c.textLo)),
            Text('·', style: TextStyle(color: c.textLo)),
            Text('🌤️ $city ۲۳°', style: TextStyle(fontSize: 12, color: c.textLo)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border(right: BorderSide(color: c.accent2, width: 2)),
          ),
          child: Text(g.line, style: TextStyle(fontSize: 12.5, height: 1.8, color: c.textHi)),
        ),

        _sectionLabel('🌟', 'امروز برای تو', c),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🎬 یک فیلم برای امشب',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.accent2)),
              const SizedBox(height: 10),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [c.accent1, c.bgDeep2],
                  ),
                ),
                alignment: Alignment.center,
                child: const Text('🎬', style: TextStyle(fontSize: 44)),
              ),
              const SizedBox(height: 12),
              Text('یک شب مه‌آلود',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: c.textHi)),
              Text('درام · ۱۱۰ دقیقه', style: TextStyle(fontSize: 11, color: c.textLo)),
              const SizedBox(height: 10),
              Text('امروز یه‌کم حال‌وهوای فرار از دنیا داری 😄 این یکی به نظرم دقیقاً به کارت میاد.',
                  style: TextStyle(fontSize: 12.5, height: 1.8, color: c.textHi)),
              const SizedBox(height: 14),
              Row(
                children: [
                  _goldChip('▶ پخش کن', c),
                  const SizedBox(width: 8),
                  _ghostChip('🔄 یکی دیگه', c),
                  const Spacer(),
                  _roundIcon('👎', movieDisliked, () => setState(() {
                        movieDisliked = !movieDisliked;
                        if (movieDisliked) movieLiked = false;
                      }), c),
                  const SizedBox(width: 8),
                  _roundIcon('❤️', movieLiked, () => setState(() {
                        movieLiked = !movieLiked;
                        if (movieLiked) movieDisliked = false;
                      }), c),
                ],
              ),
            ],
          ),
        ),

        _sectionLabel('🍳', 'اگه الان ازم بپرسی چی بپزم...', c),
        _feedCard('🍗', 'زرشک‌پلو با مرغ',
            'موادش معمولیه، دردسرش کمه و آخرش هم حسابی می‌چسبه.', 'طرز تهیه ← 🔄 یه چیز دیگه', c),

        _sectionLabel('🧠', 'یه چیز جالب که احتمالاً نمی‌دونستی', c),
        _feedCard('🤯', null,
            'قلب میگو در سرش قرار داره، نه در سینه‌اش. عجیبه ولی واقعیته!', null, c),

        _sectionLabel('📚', '۵ دقیقه مطالعه', c),
        _feedCard('📖', 'ملت عشق — الیف شافاک',
            'یه کتاب پیدا کردم که فکر کنم با حال‌وهوای این روزات جور باشه 👀 داستانی موازی از عشق و تحول.',
            'خلاصه کامل ←', c),

        _sectionLabel('🧩', 'ببین می‌تونی حلش کنی؟', c),
        _feedCard('🧩', null, 'چه چیزی هر روز میاد ولی همیشه دیروزه؟', 'جواب رو ببین ←', c),

        _sectionLabel('🔮', 'فال + شعر', c),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('فال امروز',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: c.accent2)),
                  Text('مشاهده کامل ←', style: TextStyle(fontSize: 11, color: c.accent2)),
                ],
              ),
              const SizedBox(height: 8),
              Text('امروز یک تصمیم کوچک می‌تواند مسیر یک موضوع مهم را تغییر دهد...',
                  style: TextStyle(fontSize: 12, height: 1.8, color: c.textHi)),
              const SizedBox(height: 10),
              Divider(color: Colors.white.withOpacity(0.08)),
              const SizedBox(height: 6),
              Text('«تو نیکی می‌کن و در دجله انداز...» — حافظ',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, color: c.textLo, height: 1.8)),
            ],
          ),
        ),

        const SizedBox(height: 14),
        GlassCard(
          overrideGradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [c.accent1Soft, Colors.white.withOpacity(0.04)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✨ MANA MIX — امروز',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: c.textHi)),
              Text('این میکس امروز مخصوص توئه',
                  style: TextStyle(fontSize: 11, color: c.textLo)),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.95,
                children: const [
                  _MixTile(icon: '🎬', label: 'فیلم'),
                  _MixTile(icon: '📚', label: 'کتاب'),
                  _MixTile(icon: '🍳', label: 'غذا'),
                  _MixTile(icon: '🧠', label: 'دانستنی'),
                  _MixTile(icon: '🧩', label: 'معما'),
                  _MixTile(icon: '📰', label: '۳ خبر'),
                  _MixTile(icon: '🎵', label: 'آهنگ'),
                  _MixTile(icon: '🔮', label: 'فال'),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _goldChip('❤️ خوب بود', c, fill: true)),
                  const SizedBox(width: 8),
                  _ghostChip('👎', c),
                  const SizedBox(width: 8),
                  _ghostChip('🔄 میکس جدید', c),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _askChip('🍳 چی بپزم؟', c),
              _askChip('🎬 یه فیلم خوب معرفی کن', c),
              _askChip('📰 این خبر رو خلاصه کن', c),
              _askChip('🧳 برای سفر برنامه بچین', c),
            ],
          ),
        ),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          radius: 20,
          child: Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: askCtrl,
                  style: TextStyle(fontSize: 12.5, color: c.textHi),
                  decoration: InputDecoration(
                    hintText: '✨ از مانا بپرس...',
                    hintStyle: TextStyle(color: c.textLo),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: c.accentGradient),
                alignment: Alignment.center,
                child: const Text('🎙️', style: TextStyle(fontSize: 15)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String icon, String label, dynamic c) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10, right: 2, left: 2),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: c.textHi)),
        ],
      ),
    );
  }

  Widget _feedCard(String emoji, String? title, String text, String? link, dynamic c) {
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(14)),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(title,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: c.textHi)),
                  ),
                Text(text, style: TextStyle(fontSize: 12, height: 1.8, color: c.textHi)),
                if (link != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(link, style: TextStyle(fontSize: 11, color: c.accent2)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _goldChip(String label, dynamic c, {bool fill = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(gradient: c.accentGradient, borderRadius: BorderRadius.circular(14)),
      child: Text(label, style: const TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w700)),
    );
  }

  Widget _ghostChip(String label, dynamic c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Text(label, style: TextStyle(fontSize: 11.5, color: c.textHi)),
    );
  }

  Widget _roundIcon(String emoji, bool active, VoidCallback onTap, dynamic c) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? Colors.red.withOpacity(0.22) : Colors.white.withOpacity(0.05),
          border: Border.all(color: active ? Colors.transparent : Colors.white.withOpacity(0.14)),
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _askChip(String label, dynamic c) {
    return Container(
      margin: const EdgeInsetsDirectional.only(end: 8),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: c.textHi)),
    );
  }
}

class _MixTile extends StatelessWidget {
  final String icon;
  final String label;
  const _MixTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppState>().colors;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 17)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 9.5, color: c.textHi)),
        ],
      ),
    );
  }
}
