import 'dart:convert';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// One daily medicine reminder.
///
/// GoodHealthHub had reminders that only lived on a web page, so they never
/// fired once the tab was closed. These are real phone notifications.
class MedReminder {
  /// Also the notification id, so it must fit in 32 bits.
  final int id;
  final String medicine;
  final String note; // "after food", "half tablet" - whatever the doctor said
  final int hour;
  final int minute;

  const MedReminder({
    required this.id,
    required this.medicine,
    required this.note,
    required this.hour,
    required this.minute,
  });

  String get timeLabel =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() =>
      {'id': id, 'medicine': medicine, 'note': note, 'h': hour, 'm': minute};

  static MedReminder? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'], h = raw['h'], m = raw['m'];
    if (id is! int || h is! int || m is! int) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return MedReminder(
      id: id,
      medicine: '${raw['medicine'] ?? ''}',
      note: '${raw['note'] ?? ''}',
      hour: h,
      minute: m,
    );
  }
}

/// Where reminders can actually fire. The plugin has no web version, and
/// the iOS side has not been set up in this project.
bool get remindersSupported =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// Next occurrence of [hour]:[minute] in phone-local time, as a UTC
/// instant.
///
/// Scheduling in UTC avoids a time-zone lookup package. The daily repeat
/// matches the UTC clock time, which equals the same local time every day
/// wherever the clocks do not change for summer - true for all of India.
/// Exposed for the validator and tests; the arithmetic is the risky part.
tz.TZDateTime nextFireUtc(int hour, int minute, DateTime nowLocal) {
  var local = DateTime(
      nowLocal.year, nowLocal.month, nowLocal.day, hour, minute);
  if (!local.isAfter(nowLocal)) {
    local = DateTime(
        nowLocal.year, nowLocal.month, nowLocal.day + 1, hour, minute);
  }
  return tz.TZDateTime.from(local, tz.UTC);
}

class MedReminderService {
  static const _key = 'med_reminders_v1';
  static const maxReminders = 20;

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'medicine_reminders',
      'Medicine reminders',
      channelDescription: 'Daily reminders you set for your medicines',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  static Future<void> _init() async {
    if (_ready || !remindersSupported) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ));
    _ready = true;
  }

  /// Asks for the notification permission (Android 13 and later). Returns
  /// false if the person said no, so the screen can say so plainly.
  static Future<bool> requestPermission() async {
    if (!remindersSupported) return false;
    await _init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? true;
  }

  static Future<List<MedReminder>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw);
      if (list is! List) return [];
      return list.map(MedReminder.fromJson).whereType<MedReminder>().toList()
        ..sort((a, b) => (a.hour * 60 + a.minute) - (b.hour * 60 + b.minute));
    } catch (_) {
      return [];
    }
  }

  static Future<void> _store(List<MedReminder> all) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(all.map((r) => r.toJson()).toList()));
  }

  static Future<void> add(MedReminder r) async {
    final all = await load();
    all.add(r);
    await _store(all);
    await _schedule(r);
  }

  static Future<void> remove(MedReminder r) async {
    final all = await load()
      ..removeWhere((x) => x.id == r.id);
    await _store(all);
    if (remindersSupported) {
      await _init();
      await _plugin.cancel(r.id);
    }
  }

  /// Puts every saved reminder back on the schedule. Called when the screen
  /// opens, which repairs anything a phone cleaner or an update removed.
  static Future<void> rescheduleAll() async {
    if (!remindersSupported) return;
    for (final r in await load()) {
      await _schedule(r);
    }
  }

  static Future<void> _schedule(MedReminder r) async {
    if (!remindersSupported) return;
    await _init();
    await _plugin.zonedSchedule(
      r.id,
      r.medicine,
      r.note.isEmpty ? 'Time for your medicine' : r.note,
      nextFireUtc(r.hour, r.minute, DateTime.now()),
      _details,
      // Inexact: may arrive a few minutes late, but needs no special
      // "alarms" permission, which Play Store asks apps to justify.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// A fresh id: seconds since 2026, which stays inside 32 bits for
  /// decades. Two reminders cannot be added within the same second, since
  /// each one goes through a form.
  static int newId() =>
      DateTime.now().difference(DateTime(2026)).inSeconds & 0x7fffffff;
}
