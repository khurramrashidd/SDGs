/// Reads a translated field out of a content record.
///
/// Why this exists rather than renaming every `titleHi` to a map:
///
/// The 13 JSON datasets already ship `title`/`titleHi`, `body`/`bodyHi` and
/// so on, and every module page reads them. Converting all of that to
/// `{"en": ..., "hi": ...}` would touch every record and every page at once
/// for no user-visible gain, and the last three times a bulk edit swept the
/// codebase it broke the build. So the legacy shape stays, and a language
/// beyond Hindi is *added* alongside it:
///
/// ```json
/// {
///   "title": "Boil water for one minute",
///   "titleHi": "पानी को एक मिनट उबालें",
///   "i18n": {
///     "mr": { "title": "पाणी एक मिनिट उकळा", "body": "..." },
///     "ta": { "title": "...", "body": "..." }
///   }
/// }
/// ```
///
/// Nothing existing changes shape, any number of languages can be added, and
/// an admin can add one from a phone without an app release.
library;

/// Resolution order for a field, first non-empty wins:
///
///   1. `i18n[lang][field]`  — the generic, unlimited-language slot
///   2. `field + 'Hi'`       — the legacy Hindi column, when lang is `hi`
///   3. `field`              — English, the original and the final fallback
///
/// Falling back to English is deliberate. The alternative — showing an empty
/// card — hides a government helpline from someone who needs it because
/// nobody has translated the label yet.
String pickLocalized(
  Map<String, dynamic> row,
  String field,
  String lang,
) {
  if (lang != 'en') {
    final i18n = row['i18n'];
    if (i18n is Map) {
      final forLang = i18n[lang];
      if (forLang is Map) {
        final v = forLang[field];
        if (v is String && v.trim().isNotEmpty) return v;
      }
    }

    if (lang == 'hi') {
      final legacy = row['${field}Hi'];
      if (legacy is String && legacy.trim().isNotEmpty) return legacy;
    }
  }

  final base = row[field];
  return base is String ? base : '';
}

/// True when this record actually carries [field] in [lang], as opposed to
/// falling through to English. Used to decide whether to show the
/// "not translated yet" note, so the note is accurate per screen rather
/// than guessed from the language alone.
bool isTranslated(Map<String, dynamic> row, String field, String lang) {
  if (lang == 'en') return true;

  final i18n = row['i18n'];
  if (i18n is Map) {
    final forLang = i18n[lang];
    if (forLang is Map) {
      final v = forLang[field];
      if (v is String && v.trim().isNotEmpty) return true;
    }
  }

  if (lang == 'hi') {
    final legacy = row['${field}Hi'];
    if (legacy is String && legacy.trim().isNotEmpty) return true;
  }

  return false;
}

/// How many of [rows] carry [field] in [lang]. Drives the honest banner:
/// "3 of 16 translated" beats implying the whole screen is ready.
int translatedCount(
  List<Map<String, dynamic>> rows,
  String field,
  String lang,
) =>
    rows.where((r) => isTranslated(r, field, lang)).length;

/// Every language code that appears in a record's `i18n` map, plus `hi` if
/// the legacy columns are filled. Admin screens use this to show what a
/// record already has.
Set<String> languagesPresent(Map<String, dynamic> row) {
  final out = <String>{'en'};

  final i18n = row['i18n'];
  if (i18n is Map) {
    for (final entry in i18n.entries) {
      final k = entry.key;
      final v = entry.value;
      if (k is String && v is Map && v.values.any(
            (x) => x is String && x.trim().isNotEmpty,
          )) {
        out.add(k);
      }
    }
  }

  for (final k in row.keys) {
    if (k.endsWith('Hi') && k.length > 2) {
      final v = row[k];
      if (v is String && v.trim().isNotEmpty) {
        out.add('hi');
        break;
      }
    }
  }

  return out;
}

/// Writes a translation into a record's `i18n` map and returns the patch to
/// save. Returns only the `i18n` key so `ContentStore.saveOverride` still
/// writes a minimal patch rather than the whole record.
Map<String, dynamic> translationPatch({
  required Map<String, dynamic> row,
  required String lang,
  required Map<String, String> values,
}) {
  final existing = row['i18n'];
  final merged = <String, dynamic>{};

  if (existing is Map) {
    for (final e in existing.entries) {
      if (e.key is String && e.value is Map) {
        merged[e.key as String] =
            Map<String, dynamic>.from(e.value as Map);
      }
    }
  }

  final forLang = Map<String, dynamic>.from(
    (merged[lang] as Map<String, dynamic>?) ?? const {},
  );

  values.forEach((k, v) {
    if (v.trim().isEmpty) {
      forLang.remove(k);
    } else {
      forLang[k] = v.trim();
    }
  });

  if (forLang.isEmpty) {
    merged.remove(lang);
  } else {
    merged[lang] = forLang;
  }

  return {'i18n': merged};
}
