import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/content/content_store.dart';
import '../../core/content/dataset_registry.dart';
import '../../core/i18n/locale_scope.dart';
import '../../core/i18n/localized_content.dart';
import '../../core/i18n/strings.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import 'water_check_page.dart';

/// SDG 6 — Clean Water.
///
/// What this module deliberately does not try to be: a water testing device,
/// a map of safe sources, or anything that reports on water quality itself.
/// It has no way to measure water, and a reassuring screen built on no
/// measurement is worse than no screen.
///
/// What it does instead is fix the one piece of advice that is both
/// universal in India and wrong for the people most at risk — "boil it" —
/// and then route the user to the free village test that can actually
/// answer the question.
class WaterHomePage extends StatelessWidget {
  const WaterHomePage({super.key});

  static const _jjmPortal = 'https://jaljeevanmission.gov.in/';
  static const _wqmis = 'https://ejalshakti.gov.in/WQMIS/';
  static const _cpgrams = 'https://pgportal.gov.in/';

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final pad = context.pagePadding;
    final accent = SdgColors.of(6);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('sdg6_title')),
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
            Card(
              color: accent.withValues(alpha: 0.12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hi
                          ? 'उबालना हर समस्या का हल नहीं है'
                          : 'Boiling is not the answer to every problem',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hi
                          ? 'कीटाणुओं के लिए उबालना सही है। आर्सेनिक और '
                              'फ़्लोराइड के लिए इसका कोई असर नहीं — और वह '
                              'पानी देखने में बिल्कुल साफ़ लगता है। छह सवालों '
                              'में पता करें कि आपके मामले में क्या चाहिए।'
                          : 'For germs, boiling is right. For arsenic and '
                              'fluoride it does nothing at all — and that '
                              'water looks perfectly clean. Six questions to '
                              'find out which one you are dealing with.',
                      style: const TextStyle(fontSize: 14, height: 1.55),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        localeScopedRoute(const WaterCheckPage()),
                      ),
                      icon: const Icon(Icons.water_drop_outlined),
                      label: Text(hi
                          ? 'क्या मेरा पानी सुरक्षित है?'
                          : 'Is my water safe?'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            _SectionLabel(hi ? 'जाँच कराएँ' : 'Get it tested'),
            _Row(
              icon: Icons.science_outlined,
              title: hi
                  ? 'गाँव में मुफ़्त जाँच कैसे कराएँ'
                  : 'The free village test, and how to ask for it',
              subtitle: hi
                  ? 'हर गाँव में पाँच प्रशिक्षित महिलाएँ, कोई शुल्क नहीं'
                  : 'Five trained women in every village, no charge',
              onTap: () => Navigator.of(context).push(
                localeScopedRoute(const _GuidesPage(category: 'testing')),
              ),
            ),
            _Row(
              icon: Icons.public,
              title: hi
                  ? 'अपने गाँव के नतीजे देखें'
                  : 'Look up your village results',
              subtitle: 'WQMIS · ejalshakti.gov.in',
              onTap: () => _open(context, _wqmis),
            ),

            const SizedBox(height: 22),
            _SectionLabel(hi ? 'पानी का उपचार' : 'Treating water'),
            _Row(
              icon: Icons.local_fire_department_outlined,
              title: hi
                  ? 'कौन सा तरीक़ा क्या हटाता है'
                  : 'What each method removes, and what it does not',
              subtitle: hi
                  ? 'उबालना, क्लोरीन, कपड़ा, कैंडल फ़िल्टर, भंडारण'
                  : 'Boiling, chlorine, cloth, candle filters, storage',
              onTap: () => Navigator.of(context).push(
                localeScopedRoute(const _GuidesPage(category: 'treatment')),
              ),
            ),
            _Row(
              icon: Icons.warning_amber_rounded,
              title: hi
                  ? 'आर्सेनिक, फ़्लोराइड और लोहा'
                  : 'Arsenic, fluoride and iron',
              subtitle: hi
                  ? 'जो दिखते नहीं, और उबालने से नहीं जाते'
                  : 'What you cannot see, and boiling cannot fix',
              onTap: () => Navigator.of(context).push(
                localeScopedRoute(const _GuidesPage(category: 'chemical')),
              ),
            ),
            _Row(
              icon: Icons.shield_outlined,
              title: hi ? 'स्रोत और भंडारण सुरक्षित रखें' : 'Protect the source and the store',
              subtitle: hi
                  ? 'चबूतरा, निकासी, ढका बर्तन'
                  : 'Platform, drainage, covered container',
              onTap: () => Navigator.of(context).push(
                localeScopedRoute(const _GuidesPage(category: 'protect')),
              ),
            ),

            const SizedBox(height: 22),
            _SectionLabel(hi ? 'आपका हक़ और शिकायत' : 'Your entitlement, and complaints'),
            _Row(
              icon: Icons.water_damage_outlined,
              title: hi
                  ? 'जल जीवन मिशन से क्या मिलना चाहिए'
                  : 'What Jal Jeevan Mission owes your household',
              subtitle: hi
                  ? 'प्रति व्यक्ति 55 लीटर रोज़, पानी समिति की भूमिका'
                  : '55 litres per person per day, and the Pani Samiti',
              onTap: () => Navigator.of(context).push(
                localeScopedRoute(const _GuidesPage(category: 'entitlement')),
              ),
            ),
            _Row(
              icon: Icons.report_outlined,
              title: hi
                  ? 'ख़राब हैंडपंप या दूषित स्रोत की शिकायत'
                  : 'Report a broken handpump or a bad source',
              subtitle: hi
                  ? 'पंचायत से सीपीग्राम्स तक, क्रम से'
                  : 'Panchayat to CPGRAMS, in order',
              onTap: () => Navigator.of(context).push(
                localeScopedRoute(const _GuidesPage(category: 'complaint')),
              ),
            ),
            _Row(
              icon: Icons.open_in_new,
              title: hi ? 'सीपीग्राम्स पर शिकायत दर्ज करें' : 'File on CPGRAMS',
              subtitle: 'pgportal.gov.in',
              onTap: () => _open(context, _cpgrams),
            ),
            _Row(
              icon: Icons.open_in_new,
              title: hi ? 'जल जीवन मिशन पोर्टल' : 'Jal Jeevan Mission portal',
              subtitle: 'jaljeevanmission.gov.in',
              onTap: () => _open(context, _jjmPortal),
            ),

            const SizedBox(height: 24),
            _NotMeasuredNote(hi: hi),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
      if (!ok) {
        messenger.showSnackBar(SnackBar(content: Text('Could not open $url')));
      }
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text('Could not open $url')));
    }
  }
}

/// Honest framing, kept at the bottom where it does not block the useful
/// part but is on the same screen as it.
class _NotMeasuredNote extends StatelessWidget {
  final bool hi;
  const _NotMeasuredNote({required this.hi});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hi ? 'यह ऐप पानी नहीं जाँच सकता' : 'This app cannot test water',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, height: 1.3),
          ),
          const SizedBox(height: 6),
          Text(
            hi
                ? 'यहाँ कोई सेंसर या माप नहीं है। यह ऐप सिर्फ़ यह बता सकता है '
                    'कि कौन सा उपाय किस समस्या पर काम करता है, और मुफ़्त '
                    'सरकारी जाँच तक कैसे पहुँचें। जो जानकारी यहाँ है वह '
                    'सरकारी स्रोतों से है और हर कार्ड पर उसका लिंक दिया है।'
                : 'There is no sensor or measurement here. The app can only '
                    'tell you which remedy works on which problem, and how '
                    'to reach the free government test that answers the '
                    'question. Everything here comes from government '
                    'sources, and each card links to its own.',
            style: TextStyle(
                fontSize: 12.5, height: 1.5, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// One list screen reused for all six categories, filtered by `category`.
class _GuidesPage extends StatelessWidget {
  final String category;
  const _GuidesPage({required this.category});

  static const _titles = {
    'testing': ('Get it tested', 'जाँच कराएँ'),
    'treatment': ('Treating water', 'पानी का उपचार'),
    'chemical': ('Arsenic, fluoride and iron', 'आर्सेनिक, फ़्लोराइड, लोहा'),
    'protect': ('Protect the source', 'स्रोत की सुरक्षा'),
    'entitlement': ('Your entitlement', 'आपका हक़'),
    'complaint': ('Complaints', 'शिकायत'),
  };

  @override
  Widget build(BuildContext context) {
    final lang = LocaleScope.languageOf(context);
    final hi = lang == 'hi';
    final pad = context.pagePadding;
    final ds = kDatasets.firstWhere((d) => d.collection == 'waterguides');
    final t = _titles[category] ?? ('Clean water', 'स्वच्छ पानी');

    return Scaffold(
      appBar: AppBar(
        title: Text(hi ? t.$2 : t.$1),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(6)),
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
            final rows = (snap.data ?? const <Map<String, dynamic>>[])
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
                final r = rows[index - 1];
                return _GuideCard(row: r);
              },
            );
          },
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final Map<String, dynamic> row;
  const _GuideCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final lang = LocaleScope.languageOf(context);
    final scheme = Theme.of(context).colorScheme;
    final title = pickLocalized(row, 'title', lang);
    final body = pickLocalized(row, 'body', lang);
    final src = '${row['source'] ?? ''}';

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
            Text(body, style: const TextStyle(fontSize: 14, height: 1.55)),
            if (src.startsWith('https://')) ...[
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await launchUrl(Uri.parse(src),
                          mode: LaunchMode.externalApplication);
                    } catch (_) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Could not open link')),
                      );
                    }
                  },
                  icon: const Icon(Icons.open_in_new, size: 15),
                  label: Text(context.tr('open_official'),
                      style: const TextStyle(fontSize: 12.5)),
                ),
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(
          text.toUpperCase(),
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
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: scheme.primary),
        title: Text(title,
            style:
                const TextStyle(fontWeight: FontWeight.w600, height: 1.25)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(subtitle,
              style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
