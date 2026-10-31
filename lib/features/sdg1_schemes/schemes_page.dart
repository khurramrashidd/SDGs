import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n/locale_scope.dart';
import '../../core/i18n/strings.dart';
import '../../core/theme/brand.dart';
import '../../core/layout/responsive.dart';
import 'subsidy_model.dart';
import 'subsidy_repository.dart';

class SchemesPage extends StatefulWidget {
  const SchemesPage({super.key});

  @override
  State<SchemesPage> createState() => _SchemesPageState();
}

class _SchemesPageState extends State<SchemesPage> {
  final _repo = SubsidyRepository();
  final _searchCtrl = TextEditingController();

  late Future<List<Subsidy>> _future;
  String _query = '';
  String _category = '';

  @override
  void initState() {
    super.initState();
    _future = _repo.load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = SdgColors.of(1);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('sdg1_title')),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: accent),
        ),
      ),
      body: ContentShell(
        child: FutureBuilder<List<Subsidy>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return _ErrorView(onRetry: () {
                setState(() {
                  _repo.invalidate();
                  _future = _repo.load();
                });
              });
            }

            final all = snap.data ?? const <Subsidy>[];
            final categories = _repo.categoriesOf(all);
            final filtered = all
                .where((s) => s.matches(_query))
                .where((s) => _category.isEmpty || s.category == _category)
                .toList();

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(context.pagePadding, 12, context.pagePadding, 8),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v.trim()),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: context.tr('search_schemes'),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return _CategoryChip(
                          label: context.tr('all'),
                          selected: _category.isEmpty,
                          onTap: () => setState(() => _category = ''),
                        );
                      }
                      final c = categories[i - 1];
                      return _CategoryChip(
                        label: c,
                        selected: _category == c,
                        onTap: () => setState(
                            () => _category = _category == c ? '' : c),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? _EmptyView(query: _query)
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(context.pagePadding, 4, context.pagePadding, 24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) =>
                              _SchemeCard(subsidy: filtered[i]),
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  final Subsidy subsidy;
  const _SchemeCard({required this.subsidy});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          localeScopedRoute(SchemeDetailPage(subsidy: subsidy)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 34,
                    decoration: BoxDecoration(
                      color: SdgColors.of(1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      subsidy.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                subsidy.eligibility,
                style: TextStyle(
                    fontSize: 14, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _Tag(text: subsidy.category),
                  if (subsidy.ministry.isNotEmpty)
                    _Tag(text: subsidy.ministry, subtle: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final bool subtle;
  const _Tag({required this.text, this.subtle = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: subtle
            ? scheme.surfaceContainerHighest
            : scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: subtle ? scheme.onSurfaceVariant : scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String query;
  const _EmptyView({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off,
                size: 56,
                color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(context.tr('no_results'),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              context.tr('no_results_hint'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            // Never leave the user at a dead end: hand them the official
            // government search instead.
            OutlinedButton.icon(
              onPressed: () => openMyScheme(query),
              icon: const Icon(Icons.open_in_new),
              label: Text(context.tr('find_on_myscheme')),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.tr('error_generic')),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: onRetry, child: Text(context.tr('retry'))),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- detail

class SchemeDetailPage extends StatelessWidget {
  final Subsidy subsidy;
  const SchemeDetailPage({super.key, required this.subsidy});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('sdg1_title'))),
      body: ContentShell(
        maxWidth: 700,
        child: ListView(
        padding: EdgeInsets.fromLTRB(context.pagePadding, 16, context.pagePadding, 32),
        children: [
          Text(
            subsidy.name,
            style:
                const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _Tag(text: subsidy.category),
              if (subsidy.ministry.isNotEmpty)
                _Tag(text: subsidy.ministry, subtle: true),
            ],
          ),
          const SizedBox(height: 24),
          Text(context.tr('eligibility'),
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(subsidy.eligibility,
              style: const TextStyle(fontSize: 16, height: 1.5)),
          const SizedBox(height: 28),
          if (!subsidy.verified)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      size: 20, color: scheme.onTertiaryContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.tr('unverified_notice'),
                      style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: scheme.onTertiaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: subsidy.officialLink.isEmpty
                ? null
                : () => _open(context, subsidy.officialLink),
            icon: const Icon(Icons.open_in_new),
            label: Text(context.tr('open_official')),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => openMyScheme(subsidy.name),
            icon: const Icon(Icons.travel_explore),
            label: Text(context.tr('find_on_myscheme')),
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('error_generic'))),
      );
    }
  }
}

/// myScheme is the Government of India's own scheme-discovery portal. It is
/// the safety net whenever a direct link is missing, stale or unverified.
Future<void> openMyScheme(String query) async {
  final q = Uri.encodeComponent(query.trim());
  final uri = Uri.parse(
    q.isEmpty
        ? 'https://www.myscheme.gov.in/'
        : 'https://www.myscheme.gov.in/search?q=$q',
  );
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
