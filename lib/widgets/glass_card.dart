import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

/// کارت شیشه‌ای پایه — همه‌ی کارت‌های برنامه از این استفاده می‌کنن
/// تا رعایت «Dark Luxury + Glass» (بند ۲۴ سند) یکدست بمونه:
/// پس‌زمینه‌ی کلی ساده و تیره‌ست، فقط خودِ کارت‌ها شیشه‌ای/بلوردار هستن.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Gradient? overrideGradient;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 26,
    this.onTap,
    this.overrideGradient,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final c = app.colors;
    final blur = app.matte ? 22.0 : 14.0;

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: overrideGradient,
            color: overrideGradient == null
                ? Colors.white.withOpacity(app.glassOpacity)
                : null,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}
