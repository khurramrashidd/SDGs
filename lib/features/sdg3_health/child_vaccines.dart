/// "Which of my child's vaccines are due?"
///
/// Carried over from GoodHealthHub's vaccination record, which stored doses
/// on a shared server against a typed name. This keeps the useful part —
/// knowing what is due and what is done — and changes two things:
///
///   * It stays on the phone. A child's name and date of birth have no
///     reason to leave the device, so nothing here is uploaded.
///   * It works out due dates from the date of birth against the national
///     schedule, instead of the parent typing dates in by hand.
///
/// What it deliberately does not do
/// --------------------------------
/// It never says a dose is too late. Catch-up rules differ by vaccine — some
/// can be given years after the scheduled age, some have an upper age limit
/// — and that decision belongs to the ANM or the medical officer, who can
/// see the MCP card. The harm worth preventing here is a parent seeing that
/// a date has passed and concluding there is no point going. So a missed
/// stage is shown as "due now", with an instruction to go, never as
/// "missed".
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'health_models.dart';

enum StageStatus { done, dueNow, upcoming }

class ChildRecord {
  final String id;
  final String name;
  final DateTime dob;

  /// Stage ids the parent has ticked.
  final Set<int> done;

  const ChildRecord({
    required this.id,
    required this.name,
    required this.dob,
    required this.done,
  });

  ChildRecord copyWith({String? name, DateTime? dob, Set<int>? done}) =>
      ChildRecord(
        id: id,
        name: name ?? this.name,
        dob: dob ?? this.dob,
        done: done ?? this.done,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dob': dob.toIso8601String(),
        'done': done.toList()..sort(),
      };

  static ChildRecord? fromJson(Map<String, dynamic> j) {
    final dob = DateTime.tryParse('${j['dob'] ?? ''}');
    if (dob == null) return null;
    final done = (j['done'] is List)
        ? (j['done'] as List)
            .map((e) => e is int ? e : int.tryParse('$e'))
            .whereType<int>()
            .toSet()
        : <int>{};
    return ChildRecord(
      id: '${j['id'] ?? dob.millisecondsSinceEpoch}',
      name: '${j['name'] ?? ''}',
      dob: DateTime(dob.year, dob.month, dob.day),
      done: done,
    );
  }
}

/// The last valid day of a month, so that adding months to the 31st does
/// not silently roll into the month after. Dart's DateTime normalises
/// 31 April into 1 May, which would push a due date a day late.
DateTime _addMonthsClamped(DateTime d, int months) {
  final y = d.year + (d.month - 1 + months) ~/ 12;
  final m = (d.month - 1 + months) % 12 + 1;
  final lastDay = DateTime(y, m + 1, 0).day;
  return DateTime(y, m, d.day > lastDay ? lastDay : d.day);
}

/// When a stage becomes due, or null for a stage that is not a child stage
/// (the pregnancy row) or carries no usable offset.
DateTime? dueDateFor(VaccineStage stage, DateTime dob) {
  final raw = stage.raw;
  if (raw['pregnancy'] == true) return null;
  final w = raw['dueWeeks'];
  final m = raw['dueMonths'];
  final y = raw['dueYears'];
  if (w is int) return dob.add(Duration(days: 7 * w));
  if (m is int) return _addMonthsClamped(dob, m);
  if (y is int) return _addMonthsClamped(dob, 12 * y);
  return null;
}

/// Child stages only, in schedule order.
List<VaccineStage> childStages(List<VaccineStage> all) =>
    all.where((s) => s.raw['pregnancy'] != true).toList();

StageStatus statusFor(
  VaccineStage stage,
  ChildRecord child, {
  DateTime? today,
}) {
  if (child.done.contains(stage.id)) return StageStatus.done;
  final due = dueDateFor(stage, child.dob);
  final now = today ?? DateTime.now();
  final day = DateTime(now.year, now.month, now.day);
  if (due == null || !due.isAfter(day)) return StageStatus.dueNow;
  return StageStatus.upcoming;
}

/// The next stage that is not done, so the screen can lead with it.
VaccineStage? nextStage(List<VaccineStage> stages, ChildRecord child) {
  for (final s in stages) {
    if (!child.done.contains(s.id)) return s;
  }
  return null;
}

/// Device-only storage. One key, a JSON list.
class ChildVaccineStore {
  static const _key = 'child_vaccine_records_v1';

  static Future<List<ChildRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw);
      if (list is! List) return [];
      return list
          .whereType<Map>()
          .map((m) => ChildRecord.fromJson(Map<String, dynamic>.from(m)))
          .whereType<ChildRecord>()
          .toList();
    } catch (_) {
      // A corrupt value must not lock the parent out of the screen. Start
      // clean rather than crash; there is nothing on a server to restore
      // from, which is the price of keeping this private.
      return [];
    }
  }

  static Future<void> save(List<ChildRecord> children) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(children.map((c) => c.toJson()).toList()),
    );
  }
}
