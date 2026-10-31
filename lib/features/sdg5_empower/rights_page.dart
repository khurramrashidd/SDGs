import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n/localized_content.dart';
import '../../core/i18n/locale_scope.dart';
import '../../core/content/content_store.dart';
import '../../core/content/dataset_registry.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import 'safety_exit.dart';

class LegalRight {
  final int id;
  final String title;
  final String titleHi;
  final String law;
  final String summary;
  final String summaryHi;
  final List<String> steps;
  final String source;
  final String category;
  final bool verified;

  final Map<String, dynamic> raw;

  const LegalRight({
    required this.id,
    required this.title,
    required this.titleHi,
    required this.law,
    required this.summary,
    required this.summaryHi,
    required this.steps,
    required this.source,
    required this.category,
    required this.verified,
    required this.raw,
  });

  factory LegalRight.fromJson(Map<String, dynamic> j) => LegalRight(
        id: j['id'] as int,
        title: (j['title'] ?? '').toString(),
        titleHi: (j['titleHi'] ?? '').toString(),
        law: (j['law'] ?? '').toString(),
        summary: (j['summary'] ?? '').toString(),
        summaryHi: (j['summaryHi'] ?? '').toString(),
        steps: (j['steps'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        source: (j['source'] ?? '').toString(),
        category: (j['category'] ?? '').toString(),
        verified: j['verified'] == true,
        raw: j,
      );

  String titleText(String lang) => pickLocalized(raw, 'title', lang);
  String summaryText(String lang) => pickLocalized(raw, 'summary', lang);
}

class RightsPage extends StatelessWidget {
  const RightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final pad = context.pagePadding;

    return Scaffold(
      appBar: AppBar(
        title: Text(hi ? 'आपके अधिकार' : 'Know your rights'),
        actions: const [
          SectionLanguageButton(),
          QuickExitButton(),
          SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(5)),
        ),
      ),
      body: ContentShell(
        maxWidth: 700,
        child: FutureBuilder<List<LegalRight>>(
          future: _load(),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final rights = snap.data ?? const <LegalRight>[];
            return ListView(
              padding: EdgeInsets.fromLTRB(pad, 14, pad, 32),
              children: [
                _NotAdviceNote(hi: hi),
                const SizedBox(height: 16),
                ...rights.map((r) => _RightCard(right: r, hi: hi)),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Via ContentStore so admin corrections apply. Memoised there.
  Future<List<LegalRight>> _load() async {
    final ds = kDatasets.firstWhere((d) => d.collection == 'rights');
    final rows = await ContentStore.instance.rows(ds);
    return rows.map(LegalRight.fromJson).toList();
  }
}

/// Stated once, at the top, rather than repeated on every card. This is
/// information about what the law says, not advice about a particular
/// situation - and the difference matters when someone is about to act on it.
class _NotAdviceNote extends StatelessWidget {
  final bool hi;
  const _NotAdviceNote({required this.hi});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.balance_outlined,
              size: 19, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hi
                  ? 'यह सामान्य जानकारी है, किसी मामले की कानूनी सलाह नहीं। '
                      'कानून बदलते हैं और हर स्थिति अलग होती है। हर महिला को '
                      'भारत में निःशुल्क वकील का अधिकार है — NALSA हेल्पलाइन 15100।'
                  : 'This is general information, not legal advice about your '
                      'situation. Laws change and every case differs. Every '
                      'woman in India is entitled to a free lawyer — call the '
                      'NALSA helpline on 15100.',
              style: TextStyle(
                  fontSize: 13, height: 1.45, color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _RightCard extends StatelessWidget {
  final LegalRight right;
  final bool hi;
  const _RightCard({required this.right, required this.hi});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lang = LocaleScope.languageOf(context);
    final title = right.titleText(lang);
    final body = right.summaryText(lang);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        // ExpansionTile draws its own divider lines; remove them so the card
        // border is the only edge.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            title,
            style: const TextStyle(
                fontSize: 15.5, fontWeight: FontWeight.w700, height: 1.3),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              right.law,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(body,
                  style: const TextStyle(fontSize: 14, height: 1.55)),
            ),
            if (right.steps.isNotEmpty) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  hi ? 'क्या करें' : 'What you can do',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              ...right.steps.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6, right: 10),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: SdgColors.of(5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(s,
                            style: const TextStyle(
                                fontSize: 13.5, height: 1.45)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (right.source.isNotEmpty) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => launchUrl(Uri.parse(right.source),
                      mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(
                    hi ? 'आधिकारिक स्रोत' : 'Official source',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
