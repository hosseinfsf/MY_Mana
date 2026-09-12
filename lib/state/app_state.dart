import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

/// زبان‌های پشتیبانی‌شده (بند ۸ سند مشخصات — فعلاً فارسی و انگلیسی)
enum ManaLang { fa, en }

class UserProfile {
  String name;
  String ageRange;
  String birthMonth;
  String city;

  UserProfile({
    this.name = '',
    this.ageRange = '',
    this.birthMonth = '',
    this.city = '',
  });

  Map<String, String> toMap() => {
        'name': name,
        'ageRange': ageRange,
        'birthMonth': birthMonth,
        'city': city,
      };

  factory UserProfile.fromMap(Map<String, String> m) => UserProfile(
        name: m['name'] ?? '',
        ageRange: m['ageRange'] ?? '',
        birthMonth: m['birthMonth'] ?? '',
        city: m['city'] ?? '',
      );
}

/// وضعیت کلی برنامه: تم، زبان، تنظیمات شیشه‌ای، آنبوردینگ و پروفایل کاربر.
/// همه‌جا از طریق Provider در دسترسه و تغییراتش خودکار ذخیره میشه.
class AppState extends ChangeNotifier {
  static const _kOnboardDone = 'onboard_done';
  static const _kThemeId = 'theme_id';
  static const _kLang = 'lang';
  static const _kGlassOpacity = 'glass_opacity';
  static const _kMatte = 'matte_mode';
  static const _kName = 'p_name';
  static const _kAge = 'p_age';
  static const _kMonth = 'p_month';
  static const _kCity = 'p_city';

  bool _onboardingDone = false;
  ManaThemeId _themeId = ManaThemeId.royalPurple;
  ManaLang _lang = ManaLang.fa;
  double _glassOpacity = 0.09; // شفافیت شیشه‌ای پیش‌فرض
  bool _matte = true; // حالت مات پیش‌فرض روشن
  UserProfile _profile = UserProfile();
  bool _loaded = false;

  bool get isLoaded => _loaded;
  bool get onboardingDone => _onboardingDone;
  ManaThemeId get themeId => _themeId;
  ManaColors get colors => themeById(_themeId);
  ManaLang get lang => _lang;
  double get glassOpacity => _glassOpacity;
  bool get matte => _matte;
  UserProfile get profile => _profile;
  TextDirection get textDirection =>
      _lang == ManaLang.fa ? TextDirection.rtl : TextDirection.ltr;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingDone = prefs.getBool(_kOnboardDone) ?? false;
    final themeIndex = prefs.getInt(_kThemeId) ?? 0;
    _themeId = ManaThemeId.values[themeIndex.clamp(0, ManaThemeId.values.length - 1)];
    _lang = (prefs.getString(_kLang) ?? 'fa') == 'fa' ? ManaLang.fa : ManaLang.en;
    _glassOpacity = prefs.getDouble(_kGlassOpacity) ?? 0.09;
    _matte = prefs.getBool(_kMatte) ?? true;
    _profile = UserProfile(
      name: prefs.getString(_kName) ?? '',
      ageRange: prefs.getString(_kAge) ?? '',
      birthMonth: prefs.getString(_kMonth) ?? '',
      city: prefs.getString(_kCity) ?? '',
    );
    _loaded = true;
    notifyListeners();
  }

  Future<void> completeOnboarding(UserProfile p) async {
    _profile = p;
    _onboardingDone = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardDone, true);
    await prefs.setString(_kName, p.name);
    await prefs.setString(_kAge, p.ageRange);
    await prefs.setString(_kMonth, p.birthMonth);
    await prefs.setString(_kCity, p.city);
    notifyListeners();
  }

  Future<void> setTheme(ManaThemeId id) async {
    _themeId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeId, id.index);
    notifyListeners();
  }

  Future<void> setLang(ManaLang l) async {
    _lang = l;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLang, l == ManaLang.fa ? 'fa' : 'en');
    notifyListeners();
  }

  Future<void> setGlassOpacity(double v) async {
    _glassOpacity = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kGlassOpacity, v);
    notifyListeners();
  }

  Future<void> setMatte(bool v) async {
    _matte = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMatte, v);
    notifyListeners();
  }
}
