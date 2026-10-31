import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../i18n/app_languages.dart';
import 'brand.dart';

/// Holds every user-chosen display preference: light/dark, accent colour,
/// text size and language. Persisted locally so it survives restarts and
/// works with no network and no login.
class SettingsController extends ChangeNotifier {
  static const _kThemeMode = 'pref_theme_mode';
  static const _kAccent = 'pref_accent';
  static const _kTextScale = 'pref_text_scale';
  static const _kLocale = 'pref_locale';

  SharedPreferences? _prefs;

  ThemeMode _themeMode = ThemeMode.light; // light is the default, per plan
  String _accentId = 'brand';
  String _textScaleId = 'normal';
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  String get accentId => _accentId;
  String get textScaleId => _textScaleId;
  Locale get locale => _locale;

  Color get accentColor => kAccentOptions
      .firstWhere((a) => a.id == _accentId,
          orElse: () => kAccentOptions.first)
      .color;

  double get textScale => kTextScaleOptions
      .firstWhere((t) => t.id == _textScaleId,
          orElse: () => kTextScaleOptions[1])
      .scale;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final mode = _prefs?.getString(_kThemeMode);
    _themeMode = switch (mode) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
    _accentId = _prefs?.getString(_kAccent) ?? 'brand';
    _textScaleId = _prefs?.getString(_kTextScale) ?? 'normal';
    _locale = Locale(_safeCode(_prefs?.getString(_kLocale)));
    notifyListeners();
  }

  /// A stored code that is no longer offered — a language dropped from the
  /// build, or a corrupt pref — would otherwise reach `Localizations` as an
  /// unsupported locale and resolve to something arbitrary. Fall back to
  /// English instead of to whatever happens to be first.
  String _safeCode(String? code) =>
      (code != null && kLanguageCodes.contains(code)) ? code : 'en';

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _prefs?.setString(_kThemeMode, mode.name);
  }

  Future<void> setAccent(String id) async {
    _accentId = id;
    notifyListeners();
    await _prefs?.setString(_kAccent, id);
  }

  Future<void> setTextScale(String id) async {
    _textScaleId = id;
    notifyListeners();
    await _prefs?.setString(_kTextScale, id);
  }

  Future<void> setLocale(String code) async {
    final safe = _safeCode(code);
    _locale = Locale(safe);
    notifyListeners();
    await _prefs?.setString(_kLocale, safe);
  }

  /// The language the user picked, as a full record rather than a bare code.
  AppLanguage get language => languageFor(_locale.languageCode);
}
