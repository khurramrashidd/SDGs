/// Every language the app offers, in one place.
///
/// Two separate ideas are tracked per language, and conflating them would be
/// dishonest to the user:
///
///   * `uiReady`      — the 60-odd interface strings exist (buttons, labels).
///   * `contentReady` — the actual scheme / health / legal records exist in
///                      this language.
///
/// A language can be UI-ready without being content-ready. That is the normal
/// state for most of this list, and the app says so out loud rather than
/// showing a Tamil interface wrapped around English health text and letting
/// the user assume it failed to load.
///
/// Only language codes that `flutter_localizations` actually ships are listed.
/// Checked against kMaterialSupportedLanguages: as, bn, gu, hi, kn, ml, mr,
/// ne, or, pa, ta, te, ur are all present. Sindhi, Sanskrit, Maithili,
/// Konkani and Manipuri are NOT, and adding them would silently resolve to a
/// fallback locale for every Material widget — a date picker in the wrong
/// language is worse than an honest omission.
library;

import 'package:flutter/material.dart';

@immutable
class AppLanguage {
  /// ISO code, also the `Locale.languageCode` and the key used in the
  /// `i18n` map inside content records.
  final String code;

  /// Name in English, for the admin screens.
  final String englishName;

  /// Name in its own script. This is what the user sees — someone looking
  /// for Marathi is looking for "मराठी", not "Marathi".
  final String nativeName;

  /// Interface strings are present.
  final bool uiReady;

  /// Content records carry text in this language.
  final bool contentReady;

  const AppLanguage({
    required this.code,
    required this.englishName,
    required this.nativeName,
    this.uiReady = true,
    this.contentReady = false,
  });

  Locale get locale => Locale(code);
}

/// Ordered by number of speakers in India, English first because it is the
/// default and the only fully verified content language.
const List<AppLanguage> kAppLanguages = [
  AppLanguage(
    code: 'en',
    englishName: 'English',
    nativeName: 'English',
    contentReady: true,
  ),
  AppLanguage(
    code: 'hi',
    englishName: 'Hindi',
    nativeName: 'हिन्दी',
    contentReady: true,
  ),
  AppLanguage(code: 'bn', englishName: 'Bengali', nativeName: 'বাংলা'),
  AppLanguage(code: 'mr', englishName: 'Marathi', nativeName: 'मराठी'),
  AppLanguage(code: 'te', englishName: 'Telugu', nativeName: 'తెలుగు'),
  AppLanguage(code: 'ta', englishName: 'Tamil', nativeName: 'தமிழ்'),
  AppLanguage(code: 'gu', englishName: 'Gujarati', nativeName: 'ગુજરાતી'),
  AppLanguage(code: 'ur', englishName: 'Urdu', nativeName: 'اردو'),
  AppLanguage(code: 'kn', englishName: 'Kannada', nativeName: 'ಕನ್ನಡ'),
  AppLanguage(code: 'or', englishName: 'Odia', nativeName: 'ଓଡ଼ିଆ'),
  AppLanguage(code: 'ml', englishName: 'Malayalam', nativeName: 'മലയാളം'),
  AppLanguage(code: 'pa', englishName: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ'),
  AppLanguage(code: 'as', englishName: 'Assamese', nativeName: 'অসমীয়া'),
  AppLanguage(code: 'ne', englishName: 'Nepali', nativeName: 'नेपाली'),
];

/// Codes only — used for `supportedLocales` and delegate checks.
const List<String> kLanguageCodes = [
  'en', 'hi', 'bn', 'mr', 'te', 'ta', 'gu',
  'ur', 'kn', 'or', 'ml', 'pa', 'as', 'ne',
];

AppLanguage languageFor(String code) => kAppLanguages.firstWhere(
      (l) => l.code == code,
      orElse: () => kAppLanguages.first,
    );

/// True when the given language has real content records, not just UI.
bool hasContentIn(String code) => languageFor(code).contentReady;

/// `supportedLocales` for MaterialApp.
List<Locale> get kSupportedLocales =>
    kAppLanguages.map((l) => l.locale).toList(growable: false);
