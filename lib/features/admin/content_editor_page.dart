import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/content/content_store.dart';
import '../../core/content/dataset_registry.dart';
import '../../core/layout/responsive.dart';

/// Pick a dataset to correct.
class ContentDatasetsPage extends StatelessWidget {
  final bool Function(int goal) canEdit;
  const ContentDatasetsPage({super.key, required this.canEdit});

  @override
  Widget build(BuildContext context) {
    final allowed = kDatasets.where((d) => canEdit(d.goal)).toList();
    final pad = context.pagePadding;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit content')),
      body: ContentShell(
        maxWidth: 700,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Changes here reach every device immediately. The app ships '
                'with a built-in copy of this data, and what you save is '
                'merged on top of it.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (allowed.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'You do not have edit access to any dataset yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            ...allowed.map(
              (d) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  leading: CircleAvatar(child: Text('${d.goal}')),
                  title: Text(d.label,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => ContentListPage(dataset: d)),
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

/// Every record in a dataset, searchable, with unverified ones surfaced.
class ContentListPage extends StatefulWidget {
  final ContentDataset dataset;
  const ContentListPage({super.key, required this.dataset});

  @override
  State<ContentListPage> createState() => _ContentListPageState();
}

class _ContentListPageState extends State<ContentListPage> {
  late Future<List<Map<String, dynamic>>> _future;
  final _search = TextEditingController();
  String _query = '';
  bool _onlyUnverified = false;

  @override
  void initState() {
    super.initState();
    _future = ContentStore.instance.rows(widget.dataset);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reload() {
    ContentStore.instance.invalidate(widget.dataset);
    setState(() => _future = ContentStore.instance.rows(widget.dataset));
  }

  @override
  Widget build(BuildContext context) {
    final ds = widget.dataset;
    final pad = context.pagePadding;

    return Scaffold(
      appBar: AppBar(title: Text(ds.label)),
      body: ContentShell(
        maxWidth: 760,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = snap.data ?? const <Map<String, dynamic>>[];
            final unverified =
                all.where((r) => r['verified'] != true).length;

            final rows = all.where((r) {
              if (_onlyUnverified && r['verified'] == true) return false;
              if (_query.isEmpty) return true;
              final hay = r.values.join(' ').toLowerCase();
              return hay.contains(_query.toLowerCase());
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(pad, 12, pad, 6),
                  child: TextField(
                    controller: _search,
                    onChanged: (v) => setState(() => _query = v.trim()),
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$unverified of ${all.length} not yet verified',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: unverified > 0
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                      ),
                      FilterChip(
                        label: const Text('Unverified only'),
                        selected: _onlyUnverified,
                        onSelected: (v) =>
                            setState(() => _onlyUnverified = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(pad, 4, pad, 24),
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final r = rows[i];
                      final verified = r['verified'] == true;
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          leading: Icon(
                            verified
                                ? Icons.verified
                                : Icons.help_outline,
                            color: verified
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                          ),
                          title: Text(
                            '${r[ds.titleField] ?? '(no title)'}',
                            style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600),
                          ),
                          subtitle: ds.subtitleField == null
                              ? null
                              : Text('${r[ds.subtitleField] ?? ''}',
                                  style: const TextStyle(fontSize: 12)),
                          trailing: const Icon(Icons.edit_outlined,
                              size: 19),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ContentEditPage(
                                    dataset: ds, record: r),
                              ),
                            );
                            _reload();
                          },
                        ),
                      );
                    },
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

/// Edit one record.
class ContentEditPage extends StatefulWidget {
  final ContentDataset dataset;
  final Map<String, dynamic> record;

  const ContentEditPage(
      {super.key, required this.dataset, required this.record});

  @override
  State<ContentEditPage> createState() => _ContentEditPageState();
}

class _ContentEditPageState extends State<ContentEditPage> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _flags = {};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    for (final f in widget.dataset.fields) {
      final v = widget.record[f.key];
      if (f.kind == FieldKind.flag) {
        _flags[f.key] = v == true;
      } else {
        _controllers[f.key] =
            TextEditingController(text: v == null ? '' : '$v');
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _openLink() async {
    final key = widget.dataset.linkField;
    if (key == null) return;
    final url = _controllers[key]?.text.trim() ?? '';
    final uri = Uri.tryParse(url);
    if (uri == null || !url.startsWith('http')) {
      _toast('That is not a valid link.');
      return;
    }
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: url));
      _toast('Could not open it. Link copied instead.');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _save() async {
    final ds = widget.dataset;
    final edited = <String, dynamic>{};

    for (final f in ds.fields) {
      if (f.kind == FieldKind.flag) {
        edited[f.key] = _flags[f.key] ?? false;
      } else if (f.kind == FieldKind.number) {
        edited[f.key] =
            int.tryParse(_controllers[f.key]!.text.trim()) ?? 0;
      } else {
        edited[f.key] = _controllers[f.key]!.text.trim();
      }
    }

    // One guard worth hard-coding: a helpline number with anything but
    // digits silently fails to dial, and that is the one field in this app
    // where a silent failure could matter.
    if (ds.collection == 'helplines') {
      final n = '${edited['number'] ?? ''}';
      if (n.isEmpty || !RegExp(r'^\d+$').hasMatch(n)) {
        _toast('The number must be digits only, or it will not dial.');
        return;
      }
    }

    setState(() => _busy = true);
    try {
      await ContentStore.instance.saveOverride(
        ds,
        widget.record['id'] as int,
        edited,
        widget.record,
        FirebaseAuth.instance.currentUser?.email,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast('Could not save. $e');
    }
  }

  Future<void> _revert() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Undo your changes?'),
        content: const Text(
            'This record goes back to the values built into the app.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Revert')),
        ],
      ),
    );
    if (ok != true) return;
    await ContentStore.instance
        .clearOverride(widget.dataset, widget.record['id'] as int);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ds = widget.dataset;
    final pad = context.pagePadding;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit record'),
        actions: [
          IconButton(
            tooltip: 'Revert to built-in values',
            icon: const Icon(Icons.restore),
            onPressed: _busy ? null : _revert,
          ),
        ],
      ),
      body: ContentShell(
        maxWidth: 680,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 32),
          children: [
            for (final f in ds.fields) ...[
              if (f.kind == FieldKind.flag)
                SwitchListTile(
                  value: _flags[f.key] ?? false,
                  onChanged: (v) => setState(() => _flags[f.key] = v),
                  contentPadding: EdgeInsets.zero,
                  title: Text(f.label),
                  subtitle: f.help == null
                      ? null
                      : Text(f.help!,
                          style: const TextStyle(fontSize: 12)),
                )
              else
                TextField(
                  controller: _controllers[f.key],
                  keyboardType: f.kind == FieldKind.number
                      ? TextInputType.number
                      : f.kind == FieldKind.url
                          ? TextInputType.url
                          : TextInputType.text,
                  maxLines: f.kind == FieldKind.multiline ? 5 : 1,
                  decoration: InputDecoration(
                    labelText: f.label,
                    helperText: f.help,
                    helperMaxLines: 2,
                    alignLabelWithHint:
                        f.kind == FieldKind.multiline,
                  ),
                ),
              const SizedBox(height: 14),
            ],
            if (ds.linkField != null) ...[
              OutlinedButton.icon(
                onPressed: _openLink,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open the link and check it'),
              ),
              const SizedBox(height: 14),
            ],
            FilledButton(
              onPressed: _busy ? null : _save,
              child: _busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
