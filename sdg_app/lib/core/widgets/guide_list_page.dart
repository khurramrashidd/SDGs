import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../content/content_store.dart';
import '../content/dataset_registry.dart';
import '../i18n/locale_scope.dart';
import '../i18n/localized_content.dart';
import '../i18n/strings.dart';
import '../layout/responsive.dart';
import '../theme/brand.dart';

/// One screen for any category-filtered guide dataset.
///
/// SDG 6, 7 and 9 each grew their own private copy of this before it was
/// extracted. Those three are left as they are for now — they work, and
/// refactoring working screens without a compiler on hand is exactly how two
/// earlier zips broke. Everything new uses this one, and the old copies move
/// over once a build has confirmed it on a device.
///
/// A record may carry an optional `phone` field (digits only). When present
/// the card shows a call button, because for a helpline the number is the
/// whole point and making someone copy it out of a paragraph loses people.
class GuideListPage extends StatelessWidget {
  /// The `collection` of a [ContentDataset] in [kDatasets].
  final String collection;

  /// Rows whose `category` equals this. Null shows every row.
  final String? category;

  final String title;
  final String titleHi;
  final int goal;

  /// Optional line above the list, for framing the whole category.
  final String? intro;
  final String? introHi;

  const GuideListPage({
    super.key,
    required this.collection,
    required this.title,
    required this.titleHi,
    required this.goal,
    this.category,
    this.intro,
    this.introHi,
  });

  @override
  Widget build(BuildContext context) {
    final lang = LocaleScope.languageOf(context);
    final hi = lang == 'hi';
    final pad = context.pagePadding;
    final ds = kDatasets.firstWhere((d) => d.collection == collection);
    final introText = hi ? (introHi ?? intro) : intro;

    return Scaffold(
      appBar: AppBar(
        title: Text(hi ? titleHi : title),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(goal)),
        ),
      ),
      body: ContentShell(
        maxWidth: 700,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: ContentStore.instance.rows(ds),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = snap.data ?? const <Map<String, dynamic>>[];
            final rows = category == null
                ? all
                : all
                    .where((r) => '${r['category'] ?? ''}' == category)
                    .toList();

            if (rows.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(context.tr('no_results')),
                ),
              );
            }

            final lead = <Widget>[
              TranslationGapNotice(
                translated: translatedCount(rows, 'body', lang),
                total: rows.length,
              ),
              if (introText != null && introText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    introText,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ];

            return ListView.separated(
              padding: EdgeInsets.fromLTRB(pad, 16, pad, 32),
              itemCount: lead.length + rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => index < lead.length
                  ? lead[index]
                  : GuideCard(row: rows[index - lead.length]),
            );
          },
        ),
      ),
    );
  }
}

class GuideCard extends StatelessWidget {
  final Map<String, dynamic> row;
  const GuideCard({super.key, required this.row});

  Future<void> _launch(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        messenger.showSnackBar(SnackBar(content: Text('Could not open $uri')));
      }
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text('Could not open $uri')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = LocaleScope.languageOf(context);
    final hi = lang == 'hi';
    final scheme = Theme.of(context).colorScheme;
    final title = pickLocalized(row, 'title', lang);
    final body = pickLocalized(row, 'body', lang);
    final src = '${row['source'] ?? ''}';
    final phone = '${row['phone'] ?? ''}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 15.5, fontWeight: FontWeight.w700, height: 1.3)),
            const SizedBox(height: 8),
            Text(body, style: const TextStyle(fontSize: 14, height: 1.55)),
            if (phone.isNotEmpty || src.startsWith('https://')) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (phone.isNotEmpty)
                    FilledButton.tonalIcon(
                      onPressed: () =>
                          _launch(context, Uri(scheme: 'tel', path: phone)),
                      icon: const Icon(Icons.call, size: 16),
                      label: Text(hi ? 'कॉल करें $phone' : 'Call $phone'),
                    ),
                  if (src.startsWith('https://'))
                    TextButton.icon(
                      onPressed: () => _launch(context, Uri.parse(src)),
                      icon: const Icon(Icons.open_in_new, size: 15),
                      label: Text(context.tr('open_official'),
                          style: const TextStyle(fontSize: 12.5)),
                    ),
                ],
              ),
            ],
            if (row['verified'] != true) ...[
              const SizedBox(height: 4),
              Text(
                context.tr('unverified_notice'),
                style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
