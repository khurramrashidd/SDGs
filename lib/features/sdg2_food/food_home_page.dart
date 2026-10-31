import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/content/content_store.dart';
import '../../core/content/dataset_registry.dart';
import '../../core/i18n/localized_content.dart';
import '../../core/i18n/locale_scope.dart';
import '../../core/i18n/strings.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import 'share_check_page.dart';

/// SDG 2 — Zero Hunger.
///
/// Deliberately NOT a stranger-to-stranger food marketplace. Dozens of those
/// exist, nearly all empty: no donors because no claimers, no claimers
/// because no donors. They also put food-safety liability on whoever built
/// the app, and have no way to move hot food across a city safely.
///
/// What is missing instead is discovery and compliance. Food donation in
/// India is regulated - the Recovery and Distribution of Surplus Food
/// Regulations, 2019 - and FSSAI runs a national network of registered
/// organisations that are trained and insured to collect. Most people with
/// surplus food have never heard of it.
///
/// So this module answers three questions: can this food be shared safely,
/// who near me is allowed to collect it, and how do I waste less in the
/// first place.
class FoodHomePage extends StatelessWidget {
  const FoodHomePage({super.key});

  static const _ifsaPortal = 'https://sharefood.eatrightindia.gov.in/';

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;
    final pad = context.pagePadding;
    final accent = SdgColors.of(2);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('sdg2_title')),
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
                    hi ? 'खाना बचा है?' : 'Have surplus food?',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: scheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    hi
                        ? 'पहले जाँचें कि इसे सुरक्षित रूप से बाँटा जा सकता '
                            'है या नहीं। 30 सेकंड लगेंगे।'
                        : 'Check whether it can be shared safely first. '
                            'Takes 30 seconds.',
                    style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: scheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      localeScopedRoute(const ShareCheckPage()),
                    ),
                    icon: const Icon(Icons.fact_check_outlined),
                    label: Text(hi
                        ? 'क्या यह बाँटा जा सकता है?'
                        : 'Can this be shared?'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            _SectionLabel(hi ? 'कौन ले जा सकता है' : 'Who can collect it'),
            _PartnerSection(hi: hi, portal: _ifsaPortal),

            const SizedBox(height: 24),
            _SectionLabel(hi ? 'सुरक्षित रूप से दान करें' : 'Donate safely'),
            _Row(
              icon: Icons.rule_outlined,
              title: hi ? 'भोजन सुरक्षा नियम' : 'Food safety rules',
              subtitle: hi
                  ? 'समय, तापमान, पैकिंग, लेबल और कानून'
                  : 'Time, temperature, packing, labelling and the law',
              onTap: () => Navigator.of(context).push(
                localeScopedRoute(const _ListPage(
                    titleEn: 'Food safety rules',
                    titleHi: 'भोजन सुरक्षा नियम',
                    collection: 'foodsafety',
                  )),
              ),
            ),
            _Row(
              icon: Icons.eco_outlined,
              title: hi ? 'घर में बर्बादी घटाएँ' : 'Waste less at home',
              subtitle: hi
                  ? 'भंडारण, योजना और बचे खाने के व्यावहारिक तरीक़े'
                  : 'Practical storage, planning and leftovers',
              onTap: () => Navigator.of(context).push(
                localeScopedRoute(const _ListPage(
                    titleEn: 'Waste less at home',
                    titleHi: 'घर में बर्बादी घटाएँ',
                    collection: 'foodtips',
                  )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Registered collection organisations.
///
/// The bundled list ships EMPTY, on purpose. The official IFSA partner list
/// is not published anywhere this app could read, and inventing NGO names
/// and phone numbers would send someone holding real surplus food to a
/// number that does not answer - the same failure found in the original
/// SDG 1 dataset. Admins add verified local organisations; until then this
/// points at the official portal, which is the honest answer.
class _PartnerSection extends StatelessWidget {
  final bool hi;
  final String portal;
  const _PartnerSection({required this.hi, required this.portal});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ds = kDatasets.firstWhere((d) => d.collection == 'foodpartners');

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ContentStore.instance.rows(ds),
      builder: (context, snap) {
        final rows = snap.data ?? const <Map<String, dynamic>>[];

        return Column(
          children: [
            ...rows.map((r) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: const Icon(Icons.volunteer_activism_outlined,
                        size: 26),
                    title: Text('${r['name'] ?? ''}',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      [r['city'], r['area']]
                          .where((e) =>
                              e != null && '$e'.trim().isNotEmpty)
                          .join(' · '),
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    trailing: Icon(Icons.phone, color: scheme.primary),
                    onTap: () {
                      final n = '${r['phone'] ?? ''}'.trim();
                      if (n.isNotEmpty) {
                        launchUrl(Uri(scheme: 'tel', path: n));
                      }
                    },
                  ),
                )),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rows.isEmpty
                        ? (hi
                            ? 'इस ऐप में अभी कोई स्थानीय संस्था नहीं जुड़ी है।'
                            : 'No local organisations are listed in this app yet.')
                        : (hi
                            ? 'और संस्थाएँ खोजें'
                            : 'Find more organisations'),
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    hi
                        ? 'भारत सरकार का FSSAI "सेव फ़ूड, शेयर फ़ूड" नेटवर्क '
                            'चलाता है — पंजीकृत संस्थाओं का देशव्यापी जाल जो '
                            'अधिशेष भोजन सुरक्षित रूप से इकट्ठा करने के लिए '
                            'प्रशिक्षित हैं। अपने शहर की संस्था वहीं से खोजें।'
                        : 'FSSAI, the Government of India food regulator, runs '
                            'the Save Food Share Food network — registered '
                            'organisations across India trained to collect '
                            'surplus food safely. Find the one for your city '
                            'there.',
                    style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => launchUrl(Uri.parse(portal),
                        mode: LaunchMode.externalApplication),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(hi
                        ? 'FSSAI का आधिकारिक पोर्टल खोलें'
                        : 'Open the official FSSAI portal'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Shared renderer for the two simple title/body datasets.
class _ListPage extends StatelessWidget {
  final String titleEn;
  final String titleHi;
  final String collection;

  const _ListPage({
    required this.titleEn,
    required this.titleHi,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    final lang = LocaleScope.languageOf(context);
    final hi = lang == 'hi';
    final pad = context.pagePadding;
    final ds = kDatasets.firstWhere((d) => d.collection == collection);

    return Scaffold(
      appBar: AppBar(
        title: Text(hi ? titleHi : titleEn),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(2)),
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
            final rows = snap.data ?? const <Map<String, dynamic>>[];
            // One extra leading item holds the translation notice, so the
            // list keeps a single builder rather than a Column of two.
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(pad, 16, pad, 32),
              itemCount: rows.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return TranslationGapNotice(
                    translated: translatedCount(rows, 'body', lang),
                    total: rows.length,
                  );
                }
                final i = index - 1;
                final r = rows[i];
                final title = pickLocalized(r, 'title', lang);
                final body = pickLocalized(r, 'body', lang);
                final src = '${r['source'] ?? ''}';

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                height: 1.3)),
                        const SizedBox(height: 8),
                        Text(body,
                            style: const TextStyle(
                                fontSize: 14, height: 1.55)),
                        if (src.startsWith('https://')) ...[
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => launchUrl(Uri.parse(src),
                                  mode: LaunchMode.externalApplication),
                              icon: const Icon(Icons.open_in_new, size: 15),
                              label: Text(hi ? 'स्रोत' : 'Source',
                                  style: const TextStyle(fontSize: 12.5)),
                            ),
                          ),
                        ],
                      ],
                    ),
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Row({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, size: 26),
        title: Text(title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(subtitle,
              style: const TextStyle(fontSize: 12.5, height: 1.4)),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
