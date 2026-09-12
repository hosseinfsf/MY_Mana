import 'dart:math';
import 'package:flutter/material.dart';

/// یه پس‌زمینه‌ی ستاره‌ای خیلی ظریف، برای حس «Dark Luxury» —
/// سبک، بدون انیمیشن سنگین، فقط چندتا نقطه‌ی کوچیک نیمه‌شفاف.
class StarfieldBackground extends StatelessWidget {
  const StarfieldBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _StarfieldPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  // seed ثابت تا هر بار rebuild، ستاره‌ها جابه‌جا نشن
  static final _points = List.generate(28, (i) {
    final r = Random(i * 97 + 13);
    return Offset(r.nextDouble(), r.nextDouble());
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.35);
    for (final p in _points) {
      final dx = p.dx * size.width;
      final dy = p.dy * size.height;
      final radius = (p.dx * p.dy * 3) % 1.4 + 0.4;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
