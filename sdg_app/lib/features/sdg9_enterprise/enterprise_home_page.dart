import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/content/content_store.dart';
import '../../core/content/dataset_registry.dart';
import '../../core/i18n/locale_scope.dart';
import '../../core/i18n/localized_content.dart';
import '../../core/i18n/strings.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import 'scheme_match_page.dart';

/// SDG 9 — Industry, Innovation and Infrastructure, read as: the small
/// business that already exists on the main road of a small town.
///
/// The gap this module fills is not information, it is navigation. Four
/// central schemes overlap, and the distinctions that decide everything are
/// buried in guideline PDFs: PMEGP pays a subsidy but refuses existing
/// units, Mudra takes existing units but stops at ten lakh, Stand-Up India
/// starts above that for SC, ST and women founders only, SVANidhi is street
/// vendors alone. Somebody can walk past a 25 per cent grant they qualified
/// for because nobody told them the word for it.
///
/// The second thing it does is name the fraud. Charging for a free Udyam
/// registration and promising a guaranteed Mudra sanction for an advance
/// fee are both widespread, and both are defeated by one fact: no agent has
/// the power to sanction anything, and the registration costs nothing.
class EnterpriseHomePage extends StatelessWidget {
  const EnterpriseHomePage({super.key});

  static const _udyam = 'https://www.udyamregistration.gov.in/';
  static const _janSamarth = 'https://www.jansamarth.in/';

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final pad = context.pagePadding;
    final accent = SdgColors.of(9);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('sdg9_title')),
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
              color: accent.withValues(alpha: 0.14),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hi
                          ? 'चार योजनाएँ, और फ़र्क़ जो कोई नहीं बताता'
                          : 'Four schemes, and the differences nobody mentions',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hi
                          ? 'पीएमईजीपी सब्सिडी देती है पर चल रही इकाई को नहीं। '
                              'मुद्रा चल रही इकाई को लेती है पर दस लाख तक। '
                              'स्टैंड-अप इंडिया उसके ऊपर, पर सीमित श्रेणियों '
                              'के लिए। स्वनिधि सिर्फ़ रेहड़ी वालों के लिए। '
                              'पाँच सवालों में पता करें कि आप पर क्या लागू है।'
                          : 'PMEGP pays a subsidy but refuses a running unit. '
                              'Mudra takes a running unit but stops at ten '
                              'lakh. Stand-Up India starts above that, for '
                              'limited categories. SVANidhi is vendors only. '
                              'Five questions to find which applies to you.',
                      style: const TextStyle(fontSize: 14, height: 1.55),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        localeScopedRoute(const SchemeMatchPage()),
                      ),
                      icon: const Icon(Icons.account_balance_outlined),
                      label: Text(hi
                          ? 'कौन सी योजना पूछें?'
                          : 'Which scheme to ask about?'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            _SectionLabel(hi ? 'पहले यह करें' : 'Do this first'),
            _Row(
              icon: Icons.badge_outlined,
              title: hi
                  ? 'उद्यम पंजीकरण — मुफ़्त है'
                  : 'Udyam registration — it is free',
              subtitle: hi
                  ? 'क्या मिलता है, और नक़ली वेबसाइटें'
                  : 'What it unlocks, and the look-alike websites',
              onTap: () => Navigator.of(context).push(
                localeScopedRoute(const _GuidesPage(category: 'udyam')),
              ),
            ),
            _Row(
              icon: Icons.open_in_new,
              title: hi
                  ? 'आधिकारिक उद्यम पोर्टल'
                  : 'The official Udyam portal',
              subtitle: 'udyamregistration.gov.in',
              onTap: () => _open(context, _udyam),
            ),

            const SizedBox(height: 22),
            _SectionLabel(hi ? 'कर्ज़ और सब्सिडी' : 'Credit and subsidy'),
            _Row(
              icon: Icons.account_balance_wallet_outlined,
              title: hi
                  ? 'चारों योजनाएँ, सीधे शब्दों में'
                  : 'The four schemes, in plain terms',
              subtitle: hi
                  ? 'मुद्रा, पीएमईजीपी, स्वनिधि, स्टैंड-अप इंडिया'
                  : 'Mudra, PMEGP, SVANidhi, Stand-Up India',
              onTap: () => Navigator.of(context).push(
                localeScopedRoute(const _GuidesPage(category: 'loans')),
              ),
            ),
            _Row(
              icon: Icons.description_outlined,
              title: hi
                  ? 'बैंक असल में क्या देखता है'
                  : 'What a bank is actually looking at',
              subtitle: hi
                  ? 'खाते, स्टेटमेंट, और ख़ुद लिखी परियोजना रिपोर्ट'
                  : 'Accounts, statements, and writing your own report',
              onTap: () => Navigator.of(context).push(
                localeScopedRoute(const _GuidesPage(category: 'records')),
              ),
            ),
            _Row(
              icon: Icons.open_in_new,
              title: hi ? 'जन समर्थ — एक खिड़की' : 'Jan Samarth — one window',
              subtitle: 'jansamarth.in',
              onTap: () => _open(context, _janSamarth),
            ),

            const SizedBox(height: 22),
            _SectionLabel(hi ? 'ठगी से बचाव' : 'Avoiding the fraud'),
            _Row(
              icon: Icons.gpp_maybe_outlined,
              title: hi
                  ? 'कोई ऋण की गारंटी नहीं दे सकता'
                  : 'Nobody can guarantee you a loan',
              subtitle: hi
                  ? 'पहले ली गई फ़ीस, नक़ली स्वीकृति पत्र, नक़ली साइटें'
                  : 'Advance fees, forged sanction letters, fake sites',
              onTap: () => Navigator.of(context).push(
                localeScopedRoute(const _GuidesPage(category: 'fraud')),
              ),
            ),

            const SizedBox(height: 22),
            _SectionLabel(hi ? 'ऑनलाइन जाना' : 'Getting online'),
            _Row(
              icon: Icons.qr_code_2_outlined,
              title: hi
                  ? 'यूपीआई और ऑनलाइन बेचना'
                  : 'UPI, and selling beyond your street',
              subtitle: hi
                  ? 'क्यूआर, शुल्क का सवाल, ओएनडीसी'
                  : 'QR codes, the charges question, ONDC',
              onTap: () => Navigator.of(context).push(
                localeScopedRoute(const _GuidesPage(category: 'digital')),
              ),
            ),

            const SizedBox(height: 24),
            _ScopeNote(hi: hi),
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

class _ScopeNote extends StatelessWidget {
  final bool hi;
  const _ScopeNote({required this.hi});

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
            hi
                ? 'यह ऐप न ऋण देता है, न सलाह'
                : 'This app neither lends nor advises',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, height: 1.3),
          ),
          const SizedBox(height: 6),
          Text(
            hi
                ? 'यहाँ कोई आवेदन नहीं होता और कोई काग़ज़ कहीं नहीं जाता। यह '
                    'बताता है कि कौन सी योजना किस पर लागू है और कहाँ पूछना '
                    'है। उधार लेना चाहिए या नहीं, यह फ़ैसला आपका है — और '
                    'किस्त चुकाने की गुंजाइश अपने ही हिसाब में देख लेना '
                    'सबसे ज़रूरी क़दम है। सब्सिडी की दरें और परियोजना लागत '
                    'की सीमाएँ बदलती रहती हैं, इसलिए रक़म की पुष्टि पोर्टल '
                    'पर करें।'
                : 'Nothing is applied for here and no paper goes anywhere. '
                    'It tells you which scheme applies to whom and where to '
                    'ask. Whether to borrow at all is your decision, and '
                    'checking that the instalment fits in your own figures '
                    'is the step that matters most. Subsidy rates and '
                    'project cost ceilings are revised, so confirm amounts '
                    'on the portal.',
            style: TextStyle(
                fontSize: 12.5, height: 1.5, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _GuidesPage extends StatelessWidget {
  final String category;
  const _GuidesPage({required this.category});

  static const _titles = {
    'udyam': ('Udyam registration', 'उद्यम पंजीकरण'),
    'loans': ('The schemes', 'योजनाएँ'),
    'fraud': ('Avoiding fraud', 'ठगी से बचाव'),
    'records': ('Papers and records', 'काग़ज़ और हिसाब'),
    'digital': ('Getting online', 'ऑनलाइन जाना'),
  };

  @override
  Widget build(BuildContext context) {
    final lang = LocaleScope.languageOf(context);
    final hi = lang == 'hi';
    final pad = context.pagePadding;
    final ds =
        kDatasets.firstWhere((d) => d.collection == 'enterpriseguides');
    final t = _titles[category] ?? ('Enterprise', 'उद्यम');

    return Scaffold(
      appBar: AppBar(
        title: Text(hi ? t.$2 : t.$1),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(9)),
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
                return _GuideCard(row: rows[index - 1]);
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
