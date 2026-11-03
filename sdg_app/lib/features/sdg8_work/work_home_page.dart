import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/content/content_store.dart';
import '../../core/content/dataset_registry.dart';
import '../../core/i18n/localized_content.dart';
import '../../core/i18n/locale_scope.dart';
import '../../core/i18n/strings.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import 'job_scam_page.dart';

/// SDG 8 — Decent Work.
///
/// Two things are broken for this audience and neither needs a marketplace.
///
/// Job fraud takes money from people who have the least of it, and the
/// signs are learnable in two minutes. And MGNREGA entitlements — the right
/// to demand work, the unemployment allowance when it does not come, the
/// compensation for late wages — are real, written down, and almost never
/// claimed, because almost nobody is told about them.
class WorkHomePage extends StatelessWidget {
  const WorkHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;
    final pad = context.pagePadding;
    final accent = SdgColors.of(8);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('sdg8_title')),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: accent),
        ),
      ),
      body: ContentShell(
        maxWidth: 700,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hi
                        ? 'नौकरी का ऑफ़र मिला है?'
                        : 'Been offered a job?',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: scheme.onErrorContainer),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    hi
                        ? 'पैसे देने या बैंक विवरण साझा करने से पहले जाँच '
                            'लें। एक नियम जो कभी नहीं बदलता: नौकरी पाने के '
                            'लिए कभी पैसे न दें।'
                        : 'Check it before you pay anything or share bank '
                            'details. One rule never changes: never pay to '
                            'get a job.',
                    style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: scheme.onErrorContainer),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      localeScopedRoute(const JobScamPage()),
                    ),
                    icon: const Icon(Icons.policy_outlined),
                    label: Text(hi
                        ? 'क्या यह नौकरी असली है?'
                        : 'Is this job real?'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            _Section(
                hi ? 'मनरेगा — काम का अधिकार' : 'MGNREGA — the right to work',
                'mgnrega',
                hi),
            _Section(
                hi ? 'ई-श्रम पंजीकरण' : 'e-Shram registration', 'eshram', hi),
            _Section(hi ? 'मज़दूरी और कौशल' : 'Wages and skills', 'wages', hi),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hi ? 'उपयोगी नंबर' : 'Useful numbers',
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  _Dial(
                      number: '1800-111-555',
                      dial: '1800111555',
                      label: hi ? 'मनरेगा हेल्पलाइन' : 'MGNREGA helpline'),
                  _Dial(
                      number: '1930',
                      dial: '1930',
                      label: hi
                          ? 'साइबर अपराध और ऑनलाइन धोखाधड़ी'
                          : 'Cyber crime and online fraud'),
                  _Dial(
                      number: '14434',
                      dial: '14434',
                      label: hi
                          ? 'राष्ट्रीय कैरियर सेवा'
                          : 'National Career Service'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dial extends StatelessWidget {
  final String number;
  final String dial;
  final String label;
  const _Dial(
      {required this.number, required this.dial, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => launchUrl(Uri(scheme: 'tel', path: dial)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Icon(Icons.phone, size: 18, color: scheme.primary),
            const SizedBox(width: 10),
            Text(number,
                style: const TextStyle(
                    fontSize: 14.5, fontWeight: FontWeight.w700)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12.5, color: scheme.onSurfaceVariant)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String heading;
  final String category;
  final bool hi;
  const _Section(this.heading, this.category, this.hi);

  @override
  Widget build(BuildContext context) {
    final ds = kDatasets.firstWhere((d) => d.collection == 'workrights');

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ContentStore.instance.rows(ds),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        final rows = (snap.data ?? const <Map<String, dynamic>>[])
            .where((r) => r['category'] == category)
            .toList();
        if (rows.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                heading,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            // Says plainly when these guides are not in the chosen
            // language, instead of letting translated buttons imply the
            // articles were translated too.
            TranslationGapNotice(
              translated: translatedCount(rows, 'body',
                  LocaleScope.languageOf(context)),
              total: rows.length,
            ),
            ...rows.map((r) => _GuideCard(row: r)),
            const SizedBox(height: 18),
          ],
        );
      },
    );
  }
}

class _GuideCard extends StatelessWidget {
  final Map<String, dynamic> row;
  const _GuideCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final lang = LocaleScope.languageOf(context);
    final hi = lang == 'hi';
    final title = pickLocalized(row, 'title', lang);
    final body = pickLocalized(row, 'body', lang);
    final src = '${row['source'] ?? ''}';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, height: 1.3),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(body,
                  style: const TextStyle(fontSize: 14, height: 1.55)),
            ),
            if (src.startsWith('https://'))
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => launchUrl(Uri.parse(src),
                      mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.open_in_new, size: 15),
                  label: Text(hi ? 'आधिकारिक पोर्टल' : 'Official portal',
                      style: const TextStyle(fontSize: 12.5)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
