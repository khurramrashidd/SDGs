import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/i18n/locale_scope.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import 'daily_log.dart';

/// Water, steps and active minutes, one day at a time, kept on the phone.
///
/// There are no targets on this screen and no red numbers. It is a record,
/// not a scorecard: the point is being able to look back at the week.
class DailyLogPage extends StatefulWidget {
  const DailyLogPage({super.key});

  @override
  State<DailyLogPage> createState() => _DailyLogPageState();
}

class _DailyLogPageState extends State<DailyLogPage> {
  Map<String, DayEntry> _all = {};
  bool _loading = true;
  final _steps = TextEditingController();
  final _minutes = TextEditingController();

  bool get _hi => Localizations.localeOf(context).languageCode == 'hi';
  String get _today => dayKey(DateTime.now());
  DayEntry get _entry => _all[_today] ?? const DayEntry();

  @override
  void initState() {
    super.initState();
    DailyLogStore.load().then((all) {
      if (!mounted) return;
      setState(() {
        _all = all;
        _loading = false;
        _syncFields();
      });
    });
  }

  @override
  void dispose() {
    _steps.dispose();
    _minutes.dispose();
    super.dispose();
  }

  void _syncFields() {
    final e = _entry;
    _steps.text = e.steps == 0 ? '' : '${e.steps}';
    _minutes.text = e.activeMinutes == 0 ? '' : '${e.activeMinutes}';
  }

  Future<void> _update(DayEntry e) async {
    setState(() => _all = {..._all, _today: e});
    await DailyLogStore.save(_all);
  }

  int _parse(String s) => int.tryParse(s.trim()) ?? 0;

  Future<void> _confirmClear() async {
    final hi = _hi;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(hi ? 'सारा रिकॉर्ड मिटाएँ?' : 'Delete the whole log?'),
        content: Text(hi
            ? 'यह इस फ़ोन से सभी दिनों का रिकॉर्ड हटा देगा।'
            : 'This removes every day from this phone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(hi ? 'रहने दें' : 'Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(hi ? 'मिटाएँ' : 'Delete')),
        ],
      ),
    );
    if (ok != true) return;
    await DailyLogStore.clear();
    if (!mounted) return;
    setState(() {
      _all = {};
      _syncFields();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hi = _hi;
    final pad = context.pagePadding;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(hi ? 'रोज़ का रिकॉर्ड' : 'Daily log'),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(3)),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ContentShell(
              maxWidth: 640,
              child: ListView(
                padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
                children: [
                  Text(hi ? 'आज' : 'Today',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.water_drop_outlined,
                                  color: scheme.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  hi
                                      ? 'पानी: ${_entry.water} गिलास'
                                      : 'Water: ${_entry.water} glasses',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              IconButton.outlined(
                                tooltip: hi ? 'एक कम' : 'One less',
                                onPressed: _entry.water == 0
                                    ? null
                                    : () => _update(_entry.copyWith(
                                        water: _entry.water - 1)),
                                icon: const Icon(Icons.remove),
                              ),
                              const SizedBox(width: 6),
                              IconButton.filled(
                                tooltip: hi ? 'एक गिलास और' : 'One more glass',
                                onPressed: () => _update(
                                    _entry.copyWith(water: _entry.water + 1)),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _steps,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            decoration: InputDecoration(
                              labelText: hi ? 'क़दम' : 'Steps',
                              helperText: hi
                                  ? 'फ़ोन के अपने स्टेप काउंटर से, या अंदाज़ा'
                                  : "From your phone's own step counter, or a guess",
                              prefixIcon:
                                  const Icon(Icons.directions_walk_outlined),
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (v) =>
                                _update(_entry.copyWith(steps: _parse(v))),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _minutes,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            decoration: InputDecoration(
                              labelText: hi
                                  ? 'सक्रिय मिनट'
                                  : 'Active minutes',
                              helperText: hi
                                  ? 'चलना, खेत का काम, साइकिल, खेल'
                                  : 'Walking, field work, cycling, play',
                              prefixIcon: const Icon(Icons.timer_outlined),
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (v) => _update(
                                _entry.copyWith(activeMinutes: _parse(v))),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(hi ? 'पिछले 7 दिन' : 'The last 7 days',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  ..._week(hi),
                  const SizedBox(height: 18),
                  Text(
                    hi
                        ? 'यह रिकॉर्ड सिर्फ़ इस फ़ोन पर रहता है और 60 दिन बाद अपने आप हट जाता है।'
                        : 'This log stays on this phone only, and days older '
                            'than 60 are removed automatically.',
                    style: TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _all.isEmpty ? null : _confirmClear,
                      icon: const Icon(Icons.delete_outline),
                      label: Text(hi ? 'सारा रिकॉर्ड मिटाएँ' : 'Delete the log'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  List<Widget> _week(bool hi) {
    final now = DateTime.now();
    final fmt = DateFormat('EEE d MMM');
    final out = <Widget>[];
    for (var i = 1; i <= 7; i++) {
      final d = DateTime(now.year, now.month, now.day - i);
      final e = _all[dayKey(d)] ?? const DayEntry();
      out.add(Card(
        margin: const EdgeInsets.only(bottom: 6),
        child: ListTile(
          dense: true,
          title: Text(fmt.format(d),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(e.isEmpty
              ? (hi ? 'कुछ दर्ज नहीं' : 'Nothing logged')
              : hi
                  ? 'पानी ${e.water} · क़दम ${e.steps} · ${e.activeMinutes} मिनट'
                  : 'Water ${e.water} · Steps ${e.steps} · '
                      '${e.activeMinutes} min'),
        ),
      ));
    }
    return out;
  }
}
