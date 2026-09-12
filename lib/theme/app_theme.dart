import 'package:flutter/material.dart';

/// شناسه‌ی تم‌های رنگی برنامه
enum ManaThemeId { royalPurple, oceanBlue, emerald, rose, midnight, sand }

/// یک بسته‌ی کامل از توکن‌های رنگی برای هر تم.
/// ساختار UI برای همه‌ی تم‌ها ثابت می‌مونه؛ فقط این مقادیر عوض میشن.
class ManaColors {
  final ManaThemeId id;
  final String label;
  final Color accent1; // رنگ اصلی (بنفش در تم پیش‌فرض)
  final Color accent2; // رنگ ثانویه (طلایی در تم پیش‌فرض)
  final Color bgDeep;
  final Color bgDeep2;
  final Color textHi;
  final Color textLo;

  const ManaColors({
    required this.id,
    required this.label,
    required this.accent1,
    required this.accent2,
    required this.bgDeep,
    required this.bgDeep2,
    required this.textHi,
    required this.textLo,
  });

  LinearGradient get bgGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [bgDeep, bgDeep2],
      );

  LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [accent1, accent2],
      );

  Color get accent1Soft => accent1.withOpacity(0.30);
  Color get accent2Soft => accent2.withOpacity(0.28);
}

/// لیست همه‌ی تم‌های موجود در برنامه (بند ۲۵ سند مشخصات)
const List<ManaColors> manaThemes = [
  ManaColors(
    id: ManaThemeId.royalPurple,
    label: 'بنفش سلطنتی',
    accent1: Color(0xFF7C3AED),
    accent2: Color(0xFFFBBF24),
    bgDeep: Color(0xFF0D0A1A),
    bgDeep2: Color(0xFF150C26),
    textHi: Color(0xFFF5F2FF),
    textLo: Color(0xFFA99FC9),
  ),
  ManaColors(
    id: ManaThemeId.oceanBlue,
    label: 'اقیانوسی',
    accent1: Color(0xFF0EA5E9),
    accent2: Color(0xFF67E8F9),
    bgDeep: Color(0xFF020C14),
    bgDeep2: Color(0xFF082033),
    textHi: Color(0xFFF0FAFF),
    textLo: Color(0xFF8FB4C6),
  ),
  ManaColors(
    id: ManaThemeId.emerald,
    label: 'زمردی',
    accent1: Color(0xFF059669),
    accent2: Color(0xFFFDE68A),
    bgDeep: Color(0xFF04140F),
    bgDeep2: Color(0xFF0A2B20),
    textHi: Color(0xFFF1FFF7),
    textLo: Color(0xFF8FC2A9),
  ),
  ManaColors(
    id: ManaThemeId.rose,
    label: 'رز',
    accent1: Color(0xFFE11D48),
    accent2: Color(0xFFFCA5A5),
    bgDeep: Color(0xFF180508),
    bgDeep2: Color(0xFF2C0A12),
    textHi: Color(0xFFFFF1F2),
    textLo: Color(0xFFC98F98),
  ),
  ManaColors(
    id: ManaThemeId.midnight,
    label: 'میدنایت',
    accent1: Color(0xFF334155),
    accent2: Color(0xFF94A3B8),
    bgDeep: Color(0xFF03050A),
    bgDeep2: Color(0xFF0B111D),
    textHi: Color(0xFFF1F5F9),
    textLo: Color(0xFF8291A6),
  ),
  ManaColors(
    id: ManaThemeId.sand,
    label: 'شنی گرم',
    accent1: Color(0xFFD97706),
    accent2: Color(0xFFFDE68A),
    bgDeep: Color(0xFF160F04),
    bgDeep2: Color(0xFF2C1E08),
    textHi: Color(0xFFFFF8ED),
    textLo: Color(0xFFC7AD82),
  ),
];

ManaColors themeById(ManaThemeId id) =>
    manaThemes.firstWhere((t) => t.id == id, orElse: () => manaThemes.first);
