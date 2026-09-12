import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_registry.dart';

/// وضعیت تنظیمات هوش مصنوعی — کلیدهای API، پرووایدرهای فعال، ترتیب اولویت
/// و تنظیمات endpoint سفارشی/پولی. همه‌چیز محلی و روی خود گوشی ذخیره میشه.
class AiSettings extends ChangeNotifier {
  static const _kKeysPrefix = 'ai_key_';
  static const _kModelPrefix = 'ai_model_';
  static const _kEnabledPrefix = 'ai_enabled_';
  static const _kPriority = 'ai_priority';
  static const _kCustomBaseUrl = 'ai_custom_base_url';

  final Map<String, String> _apiKeys = {};
  final Map<String, String> _models = {};
  final Map<String, bool> _enabled = {};
  List<String> _priority = AiRegistry.defaultPriority;
  String _customBaseUrl = '';
  bool _loaded = false;

  bool get isLoaded => _loaded;
  List<String> get priority => List.unmodifiable(_priority);
  String get customBaseUrl => _customBaseUrl;

  String apiKeyFor(String providerId) => _apiKeys[providerId] ?? '';
  String? modelFor(String providerId) => _models[providerId];
  bool isEnabled(String providerId) {
    final p = AiRegistry.byId(providerId);
    if (!p.requiresApiKey) return _enabled[providerId] ?? true; // آفلاین همیشه فعاله
    return _enabled[providerId] ?? false;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    for (final p in AiRegistry.all) {
      _apiKeys[p.id] = prefs.getString('$_kKeysPrefix${p.id}') ?? '';
      _models[p.id] = prefs.getString('$_kModelPrefix${p.id}') ?? p.defaultModel;
      _enabled[p.id] = prefs.getBool('$_kEnabledPrefix${p.id}') ?? !p.requiresApiKey;
    }
    _priority = prefs.getStringList(_kPriority) ?? AiRegistry.defaultPriority;
    _customBaseUrl = prefs.getString(_kCustomBaseUrl) ?? '';
    _loaded = true;
    notifyListeners();
  }

  Future<void> setApiKey(String providerId, String key) async {
    _apiKeys[providerId] = key;
    // وقتی کاربر یه کلید معتبر وارد می‌کنه، خودکار فعالش می‌کنیم
    if (key.trim().isNotEmpty) _enabled[providerId] = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_kKeysPrefix$providerId', key);
    await prefs.setBool('$_kEnabledPrefix$providerId', _enabled[providerId] ?? false);
    notifyListeners();
  }

  Future<void> setModel(String providerId, String model) async {
    _models[providerId] = model;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_kModelPrefix$providerId', model);
    notifyListeners();
  }

  Future<void> setEnabled(String providerId, bool value) async {
    _enabled[providerId] = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_kEnabledPrefix$providerId', value);
    notifyListeners();
  }

  Future<void> setCustomBaseUrl(String url) async {
    _customBaseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCustomBaseUrl, url);
    notifyListeners();
  }

  /// انتقال یک پرووایدر به بالای صف اولویت (برای اینکه ترجیح داده بشه)
  Future<void> moveToTop(String providerId) async {
    _priority.remove(providerId);
    _priority.insert(0, providerId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kPriority, _priority);
    notifyListeners();
  }

  /// لیست پرووایدرهای فعال، به ترتیب اولویت — چیزی که AiService برای fallback استفاده می‌کنه
  List<String> get activeChain =>
      _priority.where((id) => isEnabled(id)).toList();
}
