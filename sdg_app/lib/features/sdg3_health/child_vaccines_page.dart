import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

import '../../core/i18n/locale_scope.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import 'child_vaccines.dart';
import 'health_models.dart';

class ChildVaccinesPage extends StatefulWidget {
  const ChildVaccinesPage({super.key});

  @override
  State<ChildVaccinesPage> createState() => _ChildVaccinesPageState();
}

class _ChildVaccinesPageState extends State<ChildVaccinesPage> {
  List<VaccineStage>? _stages;
  List<ChildRecord> _children = [];
  bool _loading = true;

  bool get _hi => Localizations.localeOf(context).languageCode == 'hi';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw =
        await rootBundle.loadString('assets/data/vaccination_schedule.json');
    final all = (jsonDecode(raw) as List<dynamic>)
        .map((e) => VaccineStage.fromJson(e as Map<String, dynamic>))
        .toList();
    final kids = await ChildVaccineStore.load();
    if (!mounted) return;
    setState(() {
      _stages = childStages(all);
      _children = kids;
      _loading = false;
    });
  }

  Future<void> _persist() => ChildVaccineStore.save(_children);

  Future<void> _addChild() async {
    final result = await showModalBottomSheet<ChildRecord>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _AddChildSheet(hi: _hi),
    );
    if (result == null || !mounted) return;
    setState(() => _children = [..._children, result]);
    await _persist();
  }

  Future<void> _toggle(ChildRecord child, int stageId, bool done) async {
    final next = {...child.done};
    done ? next.add(stageId) : next.remove(stageId);
    setState(() {
      _children = [
        for (final c in _children)
          c.id == child.id ? c.copyWith(done: next) : c,
      ];
    });
    await _persist();
  }

  Future<void> _remove(ChildRecord child) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_hi ? 'हटाएँ?' : 'Remove?'),
        content: Text(_hi
            ? '${child.name} का रिकॉर्ड इस फ़ोन से हट जाएगा। यह वापस नहीं आएगा।'
            : '${child.name}’s record will be removed from this phone. '
                'It cannot be brought back.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(_hi ? 'रद्द करें' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(_hi ? 'हटाएँ' : 'Remove'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _children = _children.where((c) => c.id != child.id).toList());
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;

    return Scaffold(
      appBar: AppBar(
        title: Text(_hi ? 'मेरे बच्चे के टीके' : 'My child’s vaccines'),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(3)),
        ),
      ),
      floatingActionButton: _loading
          ? null
          : FloatingActionButton.extended(
              onPressed: _addChild,
              icon: const Icon(Icons.person_add_alt_1),
              label: Text(_hi ? 'बच्चा जोड़ें' : 'Add a child'),
            ),
      body: ContentShell(
        maxWidth: 680,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.fromLTRB(pad, 16, pad, 96),
                children: [
                  _PrivacyNote(hi: _hi),
                  const SizedBox(height: 14),
                  if (_children.isEmpty)
                    _Empty(hi: _hi)
                  else
                    for (final c in _children)
                      _ChildCard(
                        child: c,
                        stages: _stages!,
                        hi: _hi,
                        onToggle: (id, v) => _toggle(c, id, v),
                        onRemove: () => _remove(c),
                      ),
                  const SizedBox(height: 10),
                  _NeverTooLate(hi: _hi),
                ],
              ),
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  final bool hi;
  const _PrivacyNote({required this.hi});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            hi
                ? 'नाम और जन्मतिथि सिर्फ़ इस फ़ोन पर रहती है, कहीं भेजी नहीं जाती। '
                    'असली रिकॉर्ड आपका एमसीपी कार्ड है — यह सिर्फ़ याद दिलाने के लिए है।'
                : 'The name and date of birth stay on this phone and are never '
                    'sent anywhere. The real record is your MCP card — this is '
                    'only a reminder of what comes next.',
            style: TextStyle(
                fontSize: 12.5, height: 1.45, color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  final bool hi;
  const _Empty({required this.hi});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.child_care,
                size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              hi
                  ? 'बच्चे का नाम और जन्मतिथि डालें, और हम बताएँगे कि कौन से टीके '
                      'कब लगने हैं।'
                  : 'Add your child’s name and date of birth, and this will '
                      'show which vaccines are due and when.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      );
}

class _ChildCard extends StatelessWidget {
  final ChildRecord child;
  final List<VaccineStage> stages;
  final bool hi;
  final void Function(int stageId, bool done) onToggle;
  final VoidCallback onRemove;

  const _ChildCard({
    required this.child,
    required this.stages,
    required this.hi,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final lang = LocaleScope.languageOf(context);
    final scheme = Theme.of(context).colorScheme;
    final fmt = DateFormat('d MMM yyyy');
    final next = nextStage(stages, child);
    final dueNow = stages
        .where((s) => statusFor(s, child) == StageStatus.dueNow)
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Text(child.name,
              style:
                  const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              dueNow > 0
                  ? (hi
                      ? '$dueNow चरण अभी लगने हैं'
                      : '$dueNow stage${dueNow == 1 ? '' : 's'} due now')
                  : next == null
                      ? (hi ? 'सारे टीके दर्ज हैं' : 'Every stage ticked')
                      : (hi
                          ? 'अगला: ${fmt.format(dueDateFor(next, child.dob)!)}'
                          : 'Next: ${fmt.format(dueDateFor(next, child.dob)!)}'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: dueNow > 0 ? Colors.orange.shade800 : scheme.primary,
              ),
            ),
          ),
          trailing: IconButton(
            tooltip: hi ? 'हटाएँ' : 'Remove',
            icon: const Icon(Icons.delete_outline),
            onPressed: onRemove,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  '${hi ? 'जन्म' : 'Born'} ${fmt.format(child.dob)}',
                  style: TextStyle(
                      fontSize: 12.5, color: scheme.onSurfaceVariant),
                ),
              ),
            ),
            for (final s in stages)
              _StageRow(
                stage: s,
                status: statusFor(s, child),
                due: dueDateFor(s, child.dob),
                lang: lang,
                hi: hi,
                onChanged: (v) => onToggle(s.id, v),
              ),
          ],
        ),
      ),
    );
  }
}

class _StageRow extends StatelessWidget {
  final VaccineStage stage;
  final StageStatus status;
  final DateTime? due;
  final String lang;
  final bool hi;
  final ValueChanged<bool> onChanged;

  const _StageRow({
    required this.stage,
    required this.status,
    required this.due,
    required this.lang,
    required this.hi,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fmt = DateFormat('d MMM yyyy');

    final (Color tone, String label) = switch (status) {
      StageStatus.done => (Colors.green.shade700, hi ? 'लग गया' : 'Done'),
      StageStatus.dueNow => (
          Colors.orange.shade800,
          hi ? 'अभी लगना है' : 'Due now'
        ),
      StageStatus.upcoming => (
          scheme.onSurfaceVariant,
          due == null ? '' : fmt.format(due!)
        ),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: status == StageStatus.dueNow
            ? Colors.orange.shade800.withValues(alpha: 0.07)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CheckboxListTile(
        value: status == StageStatus.done,
        onChanged: (v) => onChanged(v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 6),
        title: Row(
          children: [
            Expanded(
              child: Text(stage.ageText(lang),
                  style: const TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.w700)),
            ),
            if (label.isNotEmpty)
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: tone)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(stage.vaccineList(lang).join(', '),
              style: const TextStyle(fontSize: 12.5, height: 1.4)),
        ),
      ),
    );
  }
}

/// The one message this screen exists to deliver for a missed stage.
class _NeverTooLate extends StatelessWidget {
  final bool hi;
  const _NeverTooLate({required this.hi});

  @override
  Widget build(BuildContext context) {
    final tone = Colors.orange.shade800;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hi ? 'तारीख़ निकल गई? फिर भी जाएँ।' : 'Date gone past? Go anyway.',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w800, color: tone),
          ),
          const SizedBox(height: 6),
          Text(
            hi
                ? 'छूटे हुए टीके अक्सर बाद में भी लग सकते हैं। एमसीपी कार्ड लेकर '
                    'एएनएम, आशा या आँगनवाड़ी के पास जाएँ और पूछें — कौन सा टीका '
                    'अब भी लगेगा, यह वही तय करते हैं। तारीख़ निकल जाने की वजह से '
                    'जाना न छोड़ें। ये सभी टीके सरकारी केंद्रों पर मुफ़्त हैं।'
                : 'Missed vaccines can often still be given later. Take the MCP '
                    'card to the ANM, the ASHA or the Anganwadi and ask — which '
                    'ones can still be given is their decision, not this '
                    'app’s. Do not skip the visit because a date has '
                    'passed. All of these vaccines are free at government '
                    'centres.',
            style: const TextStyle(fontSize: 13.5, height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _AddChildSheet extends StatefulWidget {
  final bool hi;
  const _AddChildSheet({required this.hi});

  @override
  State<_AddChildSheet> createState() => _AddChildSheetState();
}

class _AddChildSheetState extends State<_AddChildSheet> {
  final _name = TextEditingController();
  DateTime? _dob;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? now,
      // The schedule runs to 16 years.
      firstDate: DateTime(now.year - 17),
      lastDate: now,
    );
    if (picked != null && mounted) setState(() => _dob = picked);
  }

  @override
  Widget build(BuildContext context) {
    final hi = widget.hi;
    final fmt = DateFormat('d MMM yyyy');
    final ready = _name.text.trim().isNotEmpty && _dob != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(hi ? 'बच्चा जोड़ें' : 'Add a child',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          TextField(
            controller: _name,
            onChanged: (_) => setState(() {}),
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: hi ? 'नाम' : 'Name',
              hintText: hi ? 'या कोई भी पहचान' : 'Or any label you like',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickDob,
            icon: const Icon(Icons.cake_outlined),
            label: Text(_dob == null
                ? (hi ? 'जन्मतिथि चुनें' : 'Choose date of birth')
                : fmt.format(_dob!)),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: !ready
                ? null
                : () {
                    final d = _dob!;
                    Navigator.of(context).pop(ChildRecord(
                      id: '${DateTime.now().microsecondsSinceEpoch}',
                      name: _name.text.trim(),
                      dob: DateTime(d.year, d.month, d.day),
                      done: <int>{},
                    ));
                  },
            child: Text(hi ? 'जोड़ें' : 'Add'),
          ),
        ],
      ),
    );
  }
}
