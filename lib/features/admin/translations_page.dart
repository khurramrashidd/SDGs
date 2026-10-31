import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/content/content_store.dart';
import '../../core/content/dataset_registry.dart';
import '../../core/i18n/app_languages.dart';
import '../../core/i18n/localized_content.dart';
import '../../core/layout/responsive.dart';

/// Translating the content, as opposed to the interface.
///
/// The interface strings ship machine-translated into 14 languages, because
/// a clumsy button label costs a moment of confusion. The content does not,
/// and that is a deliberate decision rather than unfinished work:
///
/// These datasets are health facts, legal rights, food-safety thresholds and
/// helpline numbers. A mistranslated food-safety rule gives someone food
/// poisoning. A mistranslated legal right sends someone into a police
/// station believing something untrue. Machine-translating 295 such strings
/// into languages that nobody on this project reads would mean shipping
/// claims we cannot check, in a module whose entire purpose is to be more
/// reliable than rumour.
///
/// So the translations come from people, through this screen, one record at
/// a time, and each one goes live on every device without an app release.
/// A language is marked content-ready in app_languages.dart only once its
/// records are actually filled in.
class TranslationsPage extends StatelessWidget {
  const TranslationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;

    // English is the source, and Hindi has its own dedicated columns in
    // every dataset, edited through Admin -> Edit content. Neither belongs
    // in this list.
    final targets =
        kAppLanguages.where((l) => l.code != 'en' && l.code != 'hi').toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Translate content')),
      body: ContentShell(
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
          children: [
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why this is done by hand',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'These records are health, legal and food-safety '
                      'information. A machine translation nobody can read '
                      'back would put wrong medical and legal claims in '
                      'front of people who trust them. Anything entered '
                      'here reaches every phone without an app update, so '
                      'add a language as a speaker checks it, not before.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Pick a language',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Hindi is edited in Admin → Edit content, alongside the '
              'English text.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            ...targets.map(
              (l) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(l.nativeName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(l.contentReady
                      ? '${l.englishName} · marked ready'
                      : '${l.englishName} · interface only so far'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _DatasetsForLanguage(language: l),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatasetsForLanguage extends StatefulWidget {
  final AppLanguage language;
  const _DatasetsForLanguage({required this.language});

  @override
  State<_DatasetsForLanguage> createState() => _DatasetsForLanguageState();
}

class _DatasetsForLanguageState extends State<_DatasetsForLanguage> {
  late Future<List<_Coverage>> _future;

  @override
  void initState() {
    super.initState();
    _future = _measure();
  }

  Future<List<_Coverage>> _measure() async {
    final out = <_Coverage>[];
    for (final ds in kDatasets) {
      final rows = await ContentStore.instance.rows(ds);
      final fields = ds.translatableFields;
      if (fields.isEmpty || rows.isEmpty) {
        out.add(_Coverage(ds, rows.length, 0));
        continue;
      }
      // A record counts as translated only when every translatable field is
      // filled. A half-filled record shows a mix of two languages in one
      // card, which reads as a bug.
      final done = rows
          .where((r) => fields
              .every((f) => isTranslated(r, f.key, widget.language.code)))
          .length;
      out.add(_Coverage(ds, rows.length, done));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;

    return Scaffold(
      appBar: AppBar(title: Text('Translate · ${widget.language.nativeName}')),
      body: ContentShell(
        child: FutureBuilder<List<_Coverage>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snap.data ?? const <_Coverage>[];
            final total = data.fold<int>(0, (a, c) => a + c.total);
            final done = data.fold<int>(0, (a, c) => a + c.done);

            return ListView(
              padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$done of $total records',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: total == 0 ? 0 : done / total,
                            minHeight: 7,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          done == total && total > 0
                              ? 'Complete. Set contentReady: true for '
                                  '${widget.language.code} in '
                                  'app_languages.dart so the app stops '
                                  'warning readers that this language is '
                                  'interface-only.'
                              : 'Until this is complete, a reader who picks '
                                  '${widget.language.nativeName} is told '
                                  'which parts are still English rather '
                                  'than being left to guess.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ...data.map(
                  (c) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${c.dataset.goal}')),
                      title: Text(c.dataset.label,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(c.dataset.translatableFields.isEmpty
                          ? 'Nothing to translate in this dataset'
                          : '${c.done} of ${c.total} done'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: c.dataset.translatableFields.isEmpty
                          ? null
                          : () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => _RecordsForDataset(
                                    language: widget.language,
                                    dataset: c.dataset,
                                  ),
                                ),
                              );
                              if (mounted) {
                                setState(() => _future = _measure());
                              }
                            },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Coverage {
  final ContentDataset dataset;
  final int total;
  final int done;
  const _Coverage(this.dataset, this.total, this.done);
}

class _RecordsForDataset extends StatefulWidget {
  final AppLanguage language;
  final ContentDataset dataset;

  const _RecordsForDataset({required this.language, required this.dataset});

  @override
  State<_RecordsForDataset> createState() => _RecordsForDatasetState();
}

class _RecordsForDatasetState extends State<_RecordsForDataset> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = ContentStore.instance.rows(widget.dataset);
  }

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;
    final fields = widget.dataset.translatableFields;

    return Scaffold(
      appBar: AppBar(title: Text(widget.language.nativeName)),
      body: ContentShell(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final rows = snap.data ?? const <Map<String, dynamic>>[];
            if (rows.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('This dataset has no records yet.'),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.fromLTRB(pad, 12, pad, 36),
              itemCount: rows.length,
              itemBuilder: (context, i) {
                final r = rows[i];
                final filled = fields
                    .where((f) =>
                        isTranslated(r, f.key, widget.language.code))
                    .length;
                final complete = filled == fields.length;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      complete
                          ? Icons.check_circle
                          : filled > 0
                              ? Icons.incomplete_circle
                              : Icons.circle_outlined,
                      color: complete
                          ? Colors.green.shade600
                          : Theme.of(context).colorScheme.outline,
                    ),
                    title: Text(
                      '${r[widget.dataset.titleField] ?? 'Untitled'}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('$filled of ${fields.length} fields'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _TranslateRecordPage(
                            language: widget.language,
                            dataset: widget.dataset,
                            record: r,
                          ),
                        ),
                      );
                      if (mounted) setState(_reload);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _TranslateRecordPage extends StatefulWidget {
  final AppLanguage language;
  final ContentDataset dataset;
  final Map<String, dynamic> record;

  const _TranslateRecordPage({
    required this.language,
    required this.dataset,
    required this.record,
  });

  @override
  State<_TranslateRecordPage> createState() => _TranslateRecordPageState();
}

class _TranslateRecordPageState extends State<_TranslateRecordPage> {
  final Map<String, TextEditingController> _controllers = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final f in widget.dataset.translatableFields) {
      _controllers[f.key] = TextEditingController(
        text: isTranslated(widget.record, f.key, widget.language.code)
            ? pickLocalized(widget.record, f.key, widget.language.code)
            : '',
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final id = widget.record['id'];
    final recordId = id is int ? id : int.tryParse('$id') ?? -1;

    if (recordId < 0) {
      _toast('This record has no id, so it cannot be saved.');
      setState(() => _saving = false);
      return;
    }

    final patch = translationPatch(
      row: widget.record,
      lang: widget.language.code,
      values: {
        for (final e in _controllers.entries) e.key: e.value.text,
      },
    );

    try {
      await ContentStore.instance.saveOverride(
        widget.dataset,
        recordId,
        patch,
        // An empty original forces the i18n map into the patch. The map is
        // rebuilt from the record each time, so this is a full replacement
        // of that one field and not a blind overwrite of the record.
        const {},
        FirebaseAuth.instance.currentUser?.email,
      );
      if (!mounted) return;
      _toast('Saved. It is live on every device.');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _toast('Could not save: $e');
      setState(() => _saving = false);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;
    final scheme = Theme.of(context).colorScheme;
    final fields = widget.dataset.translatableFields;

    return Scaffold(
      appBar: AppBar(
        title: Text('Into ${widget.language.nativeName}'),
      ),
      body: ContentShell(
        maxWidth: 720,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
          children: [
            for (final f in fields) ...[
              Text(
                f.label,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              // The English original, shown read-only above the input.
              // A translator working from a record id alone would have to
              // guess what they are translating.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pickLocalized(widget.record, f.key, 'en').isEmpty
                      ? '(empty in English)'
                      : pickLocalized(widget.record, f.key, 'en'),
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controllers[f.key],
                maxLines: f.kind == FieldKind.multiline ? null : 1,
                minLines: f.kind == FieldKind.multiline ? 3 : 1,
                keyboardType: f.kind == FieldKind.multiline
                    ? TextInputType.multiline
                    : TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'In ${widget.language.nativeName}',
                  border: const OutlineInputBorder(),
                  helperText: f.help,
                  helperMaxLines: 3,
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              'Leave a box empty and that field keeps showing English, '
              'which is better than showing a guess.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving…' : 'Save translation'),
            ),
          ],
        ),
      ),
    );
  }
}
