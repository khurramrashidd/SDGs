/// Data types for SDG 3.
///
/// Note what is NOT here: there is no symptom model, no diagnosis, no
/// "what illness do I have" anywhere in this module. That was a deliberate
/// decision. An app that names a probable illness either sends someone to a
/// clinic they did not need, or reassures someone who should have gone - and
/// Play Store treats diagnosis features as a medical device claim.
///
/// What this module does instead is correct specific false beliefs that cause
/// real harm, and put the right phone number in front of someone fast.
library;

import '../../core/i18n/localized_content.dart';

class MythCard {
  final int id;
  final String category;
  final String myth;
  final String fact;
  final String why;
  final String source;
  final bool verified;

  /// The record as loaded, kept so text can be resolved in any language.
  ///
  /// The `titleHi`-style columns only ever described two languages. Holding
  /// the source map instead means a translation added from the admin screen
  /// shows up here without this class gaining a field per language.
  final Map<String, dynamic> raw;

  const MythCard({
    required this.id,
    required this.category,
    required this.myth,
    required this.fact,
    required this.why,
    required this.source,
    required this.verified,
    required this.raw,
  });

  factory MythCard.fromJson(Map<String, dynamic> j) => MythCard(
        id: j['id'] as int,
        category: (j['category'] ?? '').toString(),
        myth: (j['myth'] ?? '').toString(),
        fact: (j['fact'] ?? '').toString(),
        why: (j['why'] ?? '').toString(),
        source: (j['source'] ?? '').toString(),
        verified: j['verified'] == true,
        raw: j,
      );

  String mythText(String lang) => pickLocalized(raw, 'myth', lang);
  String factText(String lang) => pickLocalized(raw, 'fact', lang);
  String whyText(String lang) => pickLocalized(raw, 'why', lang);

  /// Plain text for pasting into WhatsApp.
  ///
  /// Sharing is the whole point of this module - the person who most needs
  /// to read a card is usually not the person holding the phone.
  ///
  /// The card text follows [lang]; the three labels are Hindi or English
  /// only. A Marathi fact under an English "What is true:" label still reads
  /// correctly, and inventing label translations in a model with no
  /// BuildContext would mean a second, parallel string table.
  String shareText(String lang) => lang == 'hi'
      ? 'सुना हुआ: ${mythText(lang)}\n\n'
          'सच: ${factText(lang)}\n\n'
          'क्यों ज़रूरी: ${whyText(lang)}\n\n'
          'स्रोत: $source'
      : 'What people say: ${mythText(lang)}\n\n'
          'What is true: ${factText(lang)}\n\n'
          'Why it matters: ${whyText(lang)}\n\n'
          'Source: $source';
}

class VaccineStage {
  final int id;
  final String age;
  final List<String> vaccines;
  final String note;
  final Map<String, dynamic> raw;

  const VaccineStage({
    required this.id,
    required this.age,
    required this.vaccines,
    required this.note,
    required this.raw,
  });

  factory VaccineStage.fromJson(Map<String, dynamic> j) => VaccineStage(
        id: j['id'] as int,
        age: (j['age'] ?? '').toString(),
        vaccines: _list(j['vaccines']),
        note: (j['note'] ?? '').toString(),
        raw: j,
      );

  static List<String> _list(dynamic v) =>
      v is List ? v.map((e) => e.toString()).toList() : const [];

  String ageText(String lang) => pickLocalized(raw, 'age', lang);
  String noteText(String lang) => pickLocalized(raw, 'note', lang);

  /// The vaccine names are a list, not a string, so they do not go through
  /// pickLocalized. Resolution order matches it: a translated list, then the
  /// legacy Hindi list, then English.
  List<String> vaccineList(String lang) {
    if (lang != 'en') {
      final i18n = raw['i18n'];
      if (i18n is Map && i18n[lang] is Map) {
        final v = (i18n[lang] as Map)['vaccines'];
        if (v is List && v.isNotEmpty) return _list(v);
      }
      if (lang == 'hi') {
        final legacy = _list(raw['vaccinesHi']);
        if (legacy.isNotEmpty) return legacy;
      }
    }
    return vaccines;
  }
}

/// Categories, in the order they appear in the filter row.
const Map<String, (String, String)> kMythCategories = {
  'vaccines': ('Vaccines', 'टीके'),
  'child': ('Child health', 'बाल स्वास्थ्य'),
  'menstruation': ('Periods', 'माहवारी'),
  'pregnancy': ('Pregnancy', 'गर्भावस्था'),
  'tb': ('TB', 'टीबी'),
  'mental': ('Mind', 'मानसिक स्वास्थ्य'),
  'emergency': ('Emergency', 'आपातकाल'),
};
