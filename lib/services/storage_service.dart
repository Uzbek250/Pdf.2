import 'package:shared_preferences/shared_preferences.dart';

/// Ilova sozlamalarini (oxirgi tanlangan til, UI tili va h.k.) qurilmada
/// saqlaydigan va o'qiydigan xizmat.
///
/// [SharedPreferences] ustidan yupqa (thin) o'ram (wrapper) bo'lib, kalitlar
/// nomini markazlashtiradi va type-safe metodlar taqdim etadi.
class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  static const _keyLastTargetLang = 'last_target_lang';
  static const _keyUiLocale = 'ui_locale';
  static const _keyHasSeenOnboarding = 'has_seen_onboarding';

  SharedPreferences? _prefs;

  /// Ilova ishga tushganda bir marta chaqirilishi kerak (masalan
  /// `main()` ichida, `runApp()` dan oldin).
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _instance {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError(
        'StorageService.init() chaqirilmagan. main() ichida await '
        'StorageService.instance.init() ni runApp() dan oldin chaqiring.',
      );
    }
    return prefs;
  }

  // ---------------------------------------------------------------- //
  // Oxirgi tanlangan tarjima tili
  // ---------------------------------------------------------------- //

  /// Foydalanuvchi oxirgi marta tanlagan maqsad til kodini saqlaydi.
  ///
  /// Bu MAJBURIY talab: ilova har safar til so'ramasligi uchun avtomatik
  /// ravishda shu qiymatni ishlatadi.
  Future<void> saveLastTargetLang(String langCode) async {
    await _instance.setString(_keyLastTargetLang, langCode);
  }

  /// Oldin saqlangan maqsad til kodini qaytaradi. Hech narsa saqlanmagan
  /// bo'lsa `null` qaytaradi (birinchi marta ishga tushirilganda).
  String? getLastTargetLang() {
    return _instance.getString(_keyLastTargetLang);
  }

  // ---------------------------------------------------------------- //
  // UI tili (interfeys tili: uz / ru / en)
  // ---------------------------------------------------------------- //

  Future<void> saveUiLocale(String localeCode) async {
    await _instance.setString(_keyUiLocale, localeCode);
  }

  String? getUiLocale() {
    return _instance.getString(_keyUiLocale);
  }

  // ---------------------------------------------------------------- //
  // Onboarding holati
  // ---------------------------------------------------------------- //

  Future<void> setHasSeenOnboarding(bool value) async {
    await _instance.setBool(_keyHasSeenOnboarding, value);
  }

  bool getHasSeenOnboarding() {
    return _instance.getBool(_keyHasSeenOnboarding) ?? false;
  }

  /// Testlash yoki "sozlamalarni tozalash" funksiyasi uchun.
  Future<void> clearAll() async {
    await _instance.clear();
  }
}
