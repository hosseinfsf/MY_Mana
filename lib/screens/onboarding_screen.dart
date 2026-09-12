import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/starfield_background.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;
  final nameCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  String? ageRange;
  String? birthMonth;

  final ageOptions = ['زیر ۱۸', '۱۸–۲۵', '۲۶–۳۵', '۳۶–۵۰', 'بالای ۵۰'];
  final monthOptions = [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
  ];

  bool get canGoNext {
    switch (step) {
      case 0:
        return nameCtrl.text.trim().isNotEmpty;
      case 1:
        return ageRange != null;
      case 2:
        return birthMonth != null;
      case 3:
        return cityCtrl.text.trim().isNotEmpty;
    }
    return false;
  }

  void _next() async {
    if (step < 3) {
      setState(() => step++);
      return;
    }
    final app = context.read<AppState>();
    await app.completeOnboarding(UserProfile(
      name: nameCtrl.text.trim(),
      ageRange: ageRange ?? '',
      birthMonth: birthMonth ?? '',
      city: cityCtrl.text.trim(),
    ));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final c = app.colors;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: c.bgGradient),
        child: Stack(
          children: [
            const Positioned.fill(child: StarfieldBackground()),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                                colors: [c.accent1, c.accent2, c.accent1]),
                          ),
                          alignment: Alignment.center,
                          child: const Text('🌙', style: TextStyle(fontSize: 30)),
                        ),
                        const SizedBox(height: 16),
                        Text('با مانا آشنا شو',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: c.textHi)),
                        const SizedBox(height: 6),
                        Text('چند سوال کوچیک، تا هر روز یه چیز مخصوص خودت بهت نشون بدم',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: c.textLo)),
                        const SizedBox(height: 22),
                        _buildStep(c),
                        const SizedBox(height: 16),
                        _buildDots(c),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (step > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(() => step--),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: c.textLo,
                                    side: BorderSide(color: Colors.white.withOpacity(0.15)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: const Text('قبلی'),
                                ),
                              ),
                            if (step > 0) const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: canGoNext ? _next : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: c.accent1,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                child: Text(step == 3 ? 'شروع کن 🚀' : 'بعدی'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDots(dynamic c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final active = i == step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? c.accent2 : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildStep(dynamic c) {
    switch (step) {
      case 0:
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('اسم کوچیکت چیه؟ چی صدات کنم؟ 😊',
                  style: TextStyle(fontSize: 12, color: c.textLo)),
              const SizedBox(height: 8),
              _textField(nameCtrl, 'مثلاً: بهنام', c),
            ],
          ),
        );
      case 1:
        return _chipQuestion(
          'چند سالته حدوداً؟',
          ageOptions,
          ageRange,
          (v) => setState(() => ageRange = v),
          c,
        );
      case 2:
        return _chipQuestion(
          'ماه تولدت چیه؟ (برای فال شخصی‌تر)',
          monthOptions,
          birthMonth,
          (v) => setState(() => birthMonth = v),
          c,
        );
      case 3:
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('شهر یا استانت کجاست؟',
                  style: TextStyle(fontSize: 12, color: c.textLo)),
              const SizedBox(height: 8),
              _textField(cityCtrl, 'مثلاً: تهران', c),
            ],
          ),
        );
    }
    return const SizedBox.shrink();
  }

  Widget _textField(TextEditingController ctrl, String hint, dynamic c) {
    return TextField(
      controller: ctrl,
      onChanged: (_) => setState(() {}),
      style: TextStyle(color: c.textHi, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.textLo),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
        ),
      ),
    );
  }

  Widget _chipQuestion(String label, List<String> options, String? selected,
      ValueChanged<String> onPick, dynamic c) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: c.textLo)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final sel = opt == selected;
              return GestureDetector(
                onTap: () => onPick(opt),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: sel ? c.accentGradient : null,
                    color: sel ? null : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: sel ? Colors.transparent : Colors.white.withOpacity(0.14)),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                      color: sel ? Colors.white : c.textLo,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
