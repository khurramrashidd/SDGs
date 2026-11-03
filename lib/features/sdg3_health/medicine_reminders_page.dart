import 'package:flutter/material.dart';

import '../../core/i18n/locale_scope.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import 'medicine_reminders.dart';

/// Daily medicine reminders, as phone notifications.
///
/// The app never suggests a medicine, a dose or a time. The person types in
/// what their doctor told them; the app only reminds.
class MedicineRemindersPage extends StatefulWidget {
  const MedicineRemindersPage({super.key});

  @override
  State<MedicineRemindersPage> createState() => _MedicineRemindersPageState();
}

class _MedicineRemindersPageState extends State<MedicineRemindersPage> {
  List<MedReminder> _list = [];
  bool _loading = true;
  bool _denied = false;

  bool get _hi => Localizations.localeOf(context).languageCode == 'hi';

  @override
  void initState() {
    super.initState();
    _reload();
    MedReminderService.rescheduleAll();
  }

  Future<void> _reload() async {
    final list = await MedReminderService.load();
    if (!mounted) return;
    setState(() {
      _list = list;
      _loading = false;
    });
  }

  Future<void> _add() async {
    final hi = _hi;
    final granted = await MedReminderService.requestPermission();
    if (!mounted) return;
    setState(() => _denied = !granted);
    if (!granted) return;

    final result = await showModalBottomSheet<MedReminder>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AddSheet(hi: hi),
    );
    if (result == null) return;
    await MedReminderService.add(result);
    await _reload();
  }

  Future<void> _remove(MedReminder r) async {
    final hi = _hi;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(hi ? 'रिमाइंडर हटाएँ?' : 'Remove this reminder?'),
        content: Text('${r.medicine} · ${r.timeLabel}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(hi ? 'रहने दें' : 'Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(hi ? 'हटाएँ' : 'Remove')),
        ],
      ),
    );
    if (ok != true) return;
    await MedReminderService.remove(r);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final hi = _hi;
    final pad = context.pagePadding;
    final scheme = Theme.of(context).colorScheme;
    final full = _list.length >= MedReminderService.maxReminders;

    return Scaffold(
      appBar: AppBar(
        title: Text(hi ? 'दवा रिमाइंडर' : 'Medicine reminders'),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(3)),
        ),
      ),
      floatingActionButton: remindersSupported && !full
          ? FloatingActionButton.extended(
              onPressed: _add,
              icon: const Icon(Icons.add_alarm),
              label: Text(hi ? 'रिमाइंडर जोड़ें' : 'Add reminder'),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ContentShell(
              maxWidth: 640,
              child: ListView(
                padding: EdgeInsets.fromLTRB(pad, 16, pad, 96),
                children: [
                  Text(
                    hi
                        ? 'वही दवा, वही समय डालें जो डॉक्टर ने बताया। ऐप कोई दवा या '
                            'ख़ुराक नहीं सुझाता — सिर्फ़ याद दिलाता है। हर दिन उसी '
                            'समय सूचना आएगी, कुछ मिनट देर से भी आ सकती है।'
                        : 'Enter the medicine and time your doctor told you. '
                            'The app never suggests a medicine or a dose — it '
                            'only reminds. A notification comes at that time '
                            'every day; it can arrive a few minutes late.',
                    style: TextStyle(
                        fontSize: 13.5,
                        height: 1.5,
                        color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 14),
                  if (!remindersSupported)
                    _Notice(
                      text: hi
                          ? 'रिमाइंडर एंड्रॉइड ऐप में काम करते हैं। इस वेबसाइट पर नहीं।'
                          : 'Reminders work in the Android app, not on this '
                              'website.',
                    ),
                  if (_denied)
                    _Notice(
                      text: hi
                          ? 'सूचनाओं की अनुमति नहीं मिली, इसलिए रिमाइंडर नहीं आएँगे। '
                              'फ़ोन की सेटिंग → ऐप्स → यह ऐप → सूचनाएँ में जाकर चालू करें।'
                          : 'Notifications are turned off for this app, so no '
                              'reminder can come. Turn them on in the phone\'s '
                              'Settings → Apps → this app → Notifications.',
                    ),
                  if (full)
                    _Notice(
                      text: hi
                          ? 'अधिकतम ${MedReminderService.maxReminders} रिमाइंडर। '
                              'नया जोड़ने के लिए कोई पुराना हटाएँ।'
                          : 'You have the maximum of '
                              '${MedReminderService.maxReminders}. Remove one '
                              'to add another.',
                    ),
                  if (_list.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(Icons.alarm_outlined,
                              size: 48, color: scheme.outline),
                          const SizedBox(height: 10),
                          Text(
                              hi
                                  ? 'अभी कोई रिमाइंडर नहीं'
                                  : 'No reminders yet',
                              style: TextStyle(color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  for (final r in _list)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: scheme.primaryContainer,
                          child: Icon(Icons.medication_outlined,
                              color: scheme.onPrimaryContainer),
                        ),
                        title: Text(r.medicine,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(r.note.isEmpty
                            ? (hi ? 'रोज़ ${r.timeLabel}' : 'Every day, ${r.timeLabel}')
                            : (hi
                                ? 'रोज़ ${r.timeLabel} · ${r.note}'
                                : 'Every day, ${r.timeLabel} · ${r.note}')),
                        trailing: IconButton(
                          tooltip: hi ? 'हटाएँ' : 'Remove',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _remove(r),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    hi
                        ? 'रिमाइंडर सिर्फ़ इस फ़ोन पर रहते हैं। कुछ फ़ोन बैटरी बचाने के लिए '
                            'सूचनाएँ रोक देते हैं — रिमाइंडर न आए तो बैटरी सेटिंग में इस ऐप '
                            'को "प्रतिबंधित नहीं" करें।'
                        : 'Reminders are kept on this phone only. Some phones '
                            'stop notifications to save battery — if one does '
                            'not arrive, set this app to "unrestricted" in the '
                            'battery settings.',
                    style: TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;
  const _Notice({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 13, height: 1.45, color: scheme.onTertiaryContainer)),
    );
  }
}

class _AddSheet extends StatefulWidget {
  final bool hi;
  const _AddSheet({required this.hi});

  @override
  State<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<_AddSheet> {
  final _name = TextEditingController();
  final _note = TextEditingController();
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = widget.hi;
    final ready = _name.text.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(hi ? 'नया रिमाइंडर' : 'New reminder',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          TextField(
            controller: _name,
            maxLength: 60,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: hi ? 'दवा का नाम' : 'Medicine name',
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _note,
            maxLength: 80,
            decoration: InputDecoration(
              labelText: hi
                  ? 'डॉक्टर ने क्या कहा (वैकल्पिक)'
                  : 'What the doctor said (optional)',
              hintText: hi ? 'जैसे: खाने के बाद, एक गोली' : 'e.g. after food, one tablet',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: () async {
              final t =
                  await showTimePicker(context: context, initialTime: _time);
              if (t != null) setState(() => _time = t);
            },
            icon: const Icon(Icons.schedule),
            label: Text(hi
                ? 'समय: ${_time.format(context)}'
                : 'Time: ${_time.format(context)}'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: !ready
                ? null
                : () => Navigator.pop(
                      context,
                      MedReminder(
                        id: MedReminderService.newId(),
                        medicine: _name.text.trim(),
                        note: _note.text.trim(),
                        hour: _time.hour,
                        minute: _time.minute,
                      ),
                    ),
            child: Text(hi ? 'सहेजें' : 'Save'),
          ),
        ],
      ),
    );
  }
}
