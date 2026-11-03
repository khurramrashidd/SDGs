import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// One day's entry in the daily log.
///
/// GoodHealthHub had a fitness tracker. This keeps the useful part — a
/// record you can look back on — and leaves out calories and weight goals on
/// purpose: a number to push down every day is the shape of tracker that
/// feeds unhealthy habits, and this app has no way to know who is using it.
class DayEntry {
  final int water; // glasses
  final int steps; // typed in, from the phone's own step counter or a guess
  final int activeMinutes; // walking, field work, cycling, play

  const DayEntry({this.water = 0, this.steps = 0, this.activeMinutes = 0});

  bool get isEmpty => water == 0 && steps == 0 && activeMinutes == 0;

  DayEntry copyWith({int? water, int? steps, int? activeMinutes}) => DayEntry(
        water: water ?? this.water,
        steps: steps ?? this.steps,
        activeMinutes: activeMinutes ?? this.activeMinutes,
      );

  Map<String, dynamic> toJson() =>
      {'water': water, 'steps': steps, 'active': activeMinutes};

  static DayEntry fromJson(Object? raw) {
    if (raw is! Map) return const DayEntry();
    int n(Object? v) => v is num ? v.toInt().clamp(0, 999999) : 0;
    return DayEntry(
      water: n(raw['water']),
      steps: n(raw['steps']),
      activeMinutes: n(raw['active']),
    );
  }
}

/// Key for a calendar day in local time, e.g. 2026-11-02.
String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Stored on the phone only. Nothing here is sent anywhere.
class DailyLogStore {
  static const _key = 'daily_log_v1';

  /// Only this many days are kept, so the store cannot grow forever.
  static const keepDays = 60;

  static Future<Map<String, DayEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    try {
      final map = jsonDecode(raw);
      if (map is! Map) return {};
      return {
        for (final e in map.entries) '${e.key}': DayEntry.fromJson(e.value),
      };
    } catch (_) {
      return {};
    }
  }

  static Future<void> save(Map<String, DayEntry> all) async {
    final cutoff =
        dayKey(DateTime.now().subtract(const Duration(days: keepDays)));
    final kept = <String, dynamic>{
      for (final e in all.entries)
        if (e.key.compareTo(cutoff) >= 0 && !e.value.isEmpty)
          e.key: e.value.toJson(),
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(kept));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
