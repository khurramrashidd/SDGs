import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/content/content_store.dart';
import '../../core/content/dataset_registry.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import '../../core/i18n/localized_content.dart';
import '../../core/i18n/locale_scope.dart';
import 'rti_builder_page.dart';

/// SDG 16 — Peace, Justice and Strong Institutions.
///
/// The rights here already exist and are strong on paper. What is missing
/// is that most people never use them, because the first step is a blank
/// page and an office that may turn them away. So this module is built
/// around doing, not reading: write an actual RTI, know exactly what a
/// police station may not refuse, and find the free lawyer you are already
/// entitled to.
class JusticeHomePage extends StatelessWidget {
  const JusticeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;
    final pad = context.pagePadding;
    final accent = SdgColors.of(16);

    return Scaffold(
      appBar: AppBar(
        title: Text(hi ? 'न्याय और अधिकार' : 'Justice and rights'),
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
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hi
                        ? 'सरकार से सवाल पूछें'
                        : 'Ask the government a question',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: scheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    hi
                        ? 'दस रुपये में कोई भी नागरिक किसी भी सरकारी दफ़्तर से '
                            'जानकारी माँग सकता है, और कारण बताना ज़रूरी नहीं। '
                            'यहाँ सही प्रारूप में आवेदन तैयार करें।'
                        : 'For ten rupees any citizen can demand information '
                            'from any government office, without giving a '
                            'reason. Build a correctly formatted application '
                            'here.',
                    style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: scheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      localeScopedRoute(const RtiBuilderPage()),
                    ),
                    icon: const Icon(Icons.edit_document),
                    label: Text(hi
                        ? 'आरटीआई आवेदन बनाएँ'
                        : 'Write an RTI application'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            _Section(hi ? 'जानकारी का अधिकार' : 'Right to information',
                'rti', hi),
            _Section(hi ? 'पुलिस और एफ़आईआर' : 'Police and FIR', 'police', hi),
            _Section(
                hi ? 'मुफ़्त कानूनी सहायता' : 'Free legal help', 'legal', hi),
            _Section(hi ? 'शिकायत कहाँ करें' : 'Where to complain',
                'grievance', hi),

            const SizedBox(height: 10),
            Container(
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
                          ? 'यह सामान्य जानकारी है, किसी मामले की कानूनी सलाह '
                              'नहीं। कानून और प्रक्रियाएँ बदलती रहती हैं। '
                              'निःशुल्क वकील के लिए NALSA हेल्पलाइन 15100 पर '
                              'कॉल करें।'
                          : 'This is general information, not legal advice '
                              'about your case. Laws and procedures change. '
                              'For a free lawyer, call the NALSA helpline on '
                              '15100.',
                      style: TextStyle(
                          fontSize: 12.5,
                          height: 1.5,
                          color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () =>
                  launchUrl(Uri(scheme: 'tel', path: '15100')),
              icon: const Icon(Icons.phone),
              label: Text(hi
                  ? '15100 — निःशुल्क कानूनी सहायता'
                  : '15100 — free legal aid'),
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
    final ds = kDatasets.firstWhere((d) => d.collection == 'civicrights');

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
    final scheme = Theme.of(context).colorScheme;
    // Reads the section language, not the app language, so the temporary
    // switch in the app bar reaches the guide text and not just the chrome.
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
              child:
                  Text(body, style: const TextStyle(fontSize: 14, height: 1.55)),
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
            if (!(row['verified'] == true))
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    hi
                        ? 'यह जानकारी अभी हमारी टीम द्वारा जाँची नहीं गई है।'
                        : 'Not yet checked by our team.',
                    style:
                        TextStyle(fontSize: 11.5, color: scheme.outline),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
