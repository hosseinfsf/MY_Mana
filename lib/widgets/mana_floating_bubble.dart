import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

/// آیکون شناور دایره‌ای مانا + منوی سریع «MANA Bubble» (بند ۱۹ سند مشخصات).
/// - قابل کشیدن (draggable) روی کل صفحه
/// - با تپ ساده (بدون درگ)، بابل کوچیک با اکشن‌های سریع باز میشه
/// - از داخل بابل میشه به تب‌های اصلی برنامه پرید
class ManaFloatingBubble extends StatefulWidget {
  final void Function(int tabIndex) onOpenTab;
  const ManaFloatingBubble({super.key, required this.onOpenTab});

  @override
  State<ManaFloatingBubble> createState() => _ManaFloatingBubbleState();
}

class _ManaFloatingBubbleState extends State<ManaFloatingBubble>
    with SingleTickerProviderStateMixin {
  Offset position = const Offset(300, 120);
  bool bubbleOpen = false;
  Offset dragStart = Offset.zero;
  Offset posStart = Offset.zero;
  bool didMove = false;

  late final AnimationController _pulseCtrl;

  static const double iconSize = 60;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _closeBubble() => setState(() => bubbleOpen = false);

  void _go(int tab) {
    _closeBubble();
    widget.onOpenTab(tab);
  }

  void _showPlaceholderSheet(BuildContext context, String title, String body) {
    _closeBubble();
    final c = context.read<AppState>().colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800, color: c.textHi)),
                  const SizedBox(height: 10),
                  Text(body, style: TextStyle(fontSize: 12.5, color: c.textLo, height: 1.8)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final c = app.colors;
    final size = MediaQuery.of(context).size;

    // مطمئن می‌شویم آیکون همیشه داخل محدوده‌ی صفحه بمونه
    final clampedX = position.dx.clamp(6.0, size.width - iconSize - 6.0);
    final clampedY = position.dy.clamp(60.0, size.height - iconSize - 140.0);

    return Stack(
      children: [
        // پس‌زمینه‌ی نیمه‌شفاف برای بستن بابل با تپ بیرون
        if (bubbleOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeBubble,
              child: Container(color: Colors.black.withOpacity(0.001)),
            ),
          ),

        // خود آیکون شناور
        Positioned(
          left: clampedX,
          top: clampedY,
          child: GestureDetector(
            onPanStart: (d) {
              dragStart = d.globalPosition;
              posStart = Offset(clampedX, clampedY);
              didMove = false;
            },
            onPanUpdate: (d) {
              didMove = true;
              setState(() {
                position = posStart + (d.globalPosition - dragStart);
              });
            },
            onTap: () {
              if (!didMove) setState(() => bubbleOpen = !bubbleOpen);
            },
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (context, child) {
                final t = _pulseCtrl.value;
                final lift = -6.0 * t;
                final scale = 1.0 + 0.04 * t;
                return Transform.translate(
                  offset: Offset(0, lift),
                  child: Transform.scale(scale: scale, child: child),
                );
              },
              child: Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.4),
                    colors: [c.accent2, c.accent1],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: c.accent1Soft,
                      blurRadius: 22,
                      spreadRadius: 3,
                    ),
                    const BoxShadow(
                      color: Colors.black38,
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text('🌙', style: TextStyle(fontSize: 26)),
              ),
            ),
          ),
        ),

        // منوی سریع MANA Bubble
        if (bubbleOpen)
          Positioned(
            left: (clampedX - 170).clamp(10.0, size.width - 230.0),
            top: (clampedY + 8).clamp(10.0, size.height - 300.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.16)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Text('چیکار کنیم؟ 😎',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700, color: c.textHi)),
                      ),
                      const SizedBox(height: 4),
                      _bubbleItem('🎤', 'صحبت با مانا', () => _go(3)),
                      _bubbleItem('📝', 'یادداشت سریع', () => _go(2)),
                      _bubbleItem('📋', 'کلیپ‌بورد', () => _showPlaceholderSheet(
                          context,
                          'کلیپ‌بورد هوشمند',
                          'هر چیزی رو که کپی کنی، مانا تشخیص می‌ده و پیشنهاد اصلاح متن، پاسخ آماده یا خلاصه‌سازی می‌ده.')),
                      _bubbleItem('🔍', 'جستجو', () => _go(1)),
                      _bubbleItem('💬', 'پاسخ سریع', () => _showPlaceholderSheet(
                          context,
                          'پاسخ سریع شبکه‌های اجتماعی',
                          'یه پیام یا کامنت کپی کن تا مانا چند تا پاسخ آماده با لحن دلخواهت بهت بده.')),
                      _bubbleItem('🍳', 'چی بپزم؟', () => _go(1)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _bubbleItem(String icon, String label, VoidCallback onTap) {
    final c = context.read<AppState>().colors;
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        child: Row(
          children: [
            SizedBox(width: 22, child: Text(icon, style: const TextStyle(fontSize: 15))),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 12, color: c.textHi)),
          ],
        ),
      ),
    );
  }
}
