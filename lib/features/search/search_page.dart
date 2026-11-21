import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/strings.dart';
import '../../core/issues/issue.dart';
import '../../core/issues/registry.dart';
import '../../core/layout/responsive.dart';
import '../../core/sdg/sdg_catalog.dart';
import '../../core/theme/brand.dart';

/// One box for the whole app.
///
/// Somebody with a problem knows the problem, not which of seventeen goals
/// it was filed under. Typing "ration" or "राशन" should find the ration
/// tools whether they sit in Zero Hunger or No Poverty, and it does,
/// because every goal's issues are in one list.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// A few openings for someone who does not know what to type.
  static const _suggestions = [
    ('ration', 'राशन'),
    ('pension', 'पेंशन'),
    ('scholarship', 'छात्रवृत्ति'),
    ('complaint', 'शिकायत'),
    ('water', 'पानी'),
    ('loan', 'क़र्ज़'),
    ('vaccine', 'टीका'),
    ('wages', 'मज़दूरी'),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final hi = lang == 'hi';
    final pad = context.pagePadding;
    final scheme = Theme.of(context).colorScheme;
    final results = _query.trim().isEmpty
        ? const <Issue>[]
        : searchIssues(_query);

    return Scaffold(
      appBar: AppBar(title: Text(hi ? 'खोजें' : 'Search')),
      body: ContentShell(
        maxWidth: 760,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 12, pad, 8),
              child: TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: hi
                      ? 'अपनी समस्या लिखें — जैसे "राशन" या "पेंशन"'
                      : 'Type your problem — like "ration" or "pension"',
                  border: const OutlineInputBorder(),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: _query.trim().isEmpty
                  ? _Suggestions(
                      onPick: (word) {
                        _controller.text = word;
                        setState(() => _query = word);
                      },
                      hi: hi,
                    )
                  : results.isEmpty
                      ? Padding(
                          padding: EdgeInsets.all(pad + 20),
                          child: Text(
                            hi
                                ? 'कुछ नहीं मिला। कोई दूसरा शब्द आज़माएँ, या नीचे से '
                                    'कोई लक्ष्य खोलें।'
                                : 'Nothing found. Try another word, or open a '
                                    'goal from the home screen.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        )
                      : ListView(
                          padding: EdgeInsets.fromLTRB(pad, 4, pad, 32),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                hi
                                    ? '${results.length} नतीजे'
                                    : '${results.length} results',
                                style: TextStyle(
                                    fontSize: 12.5,
                                    color: scheme.onSurfaceVariant),
                              ),
                            ),
                            for (final i in results)
                              _ResultTile(issue: i, lang: lang),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  final void Function(String) onPick;
  final bool hi;
  const _Suggestions({required this.onPick, required this.hi});

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: EdgeInsets.fromLTRB(pad, 8, pad, 32),
      children: [
        Text(
          hi
              ? 'ऐप की सभी ${kAllIssues.length} समस्याएँ एक साथ खोजी जाती हैं।'
              : 'Searches all ${kAllIssues.length} problems in the app at once.',
          style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in _SearchPageState._suggestions)
              ActionChip(
                label: Text(hi ? s.$2 : s.$1),
                onPressed: () => onPick(hi ? s.$2 : s.$1),
              ),
          ],
        ),
      ],
    );
  }
}

class _ResultTile extends StatelessWidget {
  final Issue issue;
  final String lang;
  const _ResultTile({required this.issue, required this.lang});

  @override
  Widget build(BuildContext context) {
    final hi = lang == 'hi';
    final scheme = Theme.of(context).colorScheme;
    final entry = kSdgCatalog.firstWhere((e) => e.goal == issue.goal,
        orElse: () => kSdgCatalog.first);
    final on = issue.isBuilt;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(issue.icon,
            color: on ? SdgColors.of(issue.goal) : scheme.outline),
        title: Text(issue.title(lang),
            style: TextStyle(
                fontWeight: FontWeight.w600,
                height: 1.25,
                color: on ? null : scheme.onSurfaceVariant)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            'SDG ${issue.goal} · ${context.tr(entry.titleKey)}'
            '${on ? '' : ' · ${hi ? 'बन रहा है' : 'being built'}'}',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ),
        trailing: Icon(on ? Icons.chevron_right : Icons.schedule,
            color: scheme.outline),
        // Always land inside the goal, never on a bare tool screen: the
        // person then has the goal's menu, helplines and related problems
        // around them instead of a dead end.
        onTap: () => context.push('/sdg/${issue.goal}?issue=${issue.id}'),
      ),
    );
  }
}
