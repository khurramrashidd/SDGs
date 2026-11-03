import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/content/content_store.dart';
import '../../core/content/dataset_registry.dart';
import '../../core/i18n/locale_scope.dart';
import '../../core/i18n/localized_content.dart';
import '../../core/i18n/strings.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import 'bill_check_page.dart';

/// SDG 7 — Affordable and Clean Energy.
///
/// Three things a household can actually act on, rather than a page about
/// renewable capacity targets:
///
///   1. The bill. Most people cannot tell a wrong bill from an expensive
///      one, and the one error anyone can prove — units that do not match
///      the meter readings printed on the same bill — is pure subtraction.
///   2. The rooftop solar subsidy, which is real money and also the place
///      where a household can be talked into a bad deal by a vendor.
///   3. The gas subsidy, which arrives as a bank transfer rather than a
///      discount, so people often do not know whether they are getting it.
///
/// Deliberately absent: a solar payback calculator. Sizing a system and
/// predicting its payback decides a one to two lakh rupee purchase, and it
/// turns on per-kW installed cost, state tariff, net-metering rules and
/// subsidy amounts that all move. A wrong number there is expensive in a
/// way a wrong information page is not, so this module explains the scheme
/// and sends people to the portal instead of predicting their savings.
class EnergyHomePage extends StatelessWidget {
  const EnergyHomePage({super.key});

  static const _suryaGhar = 'https://pmsuryaghar.gov.in/';
  static const _pmuy = 'https://pmuy.gov.in/';
  static const _consumerRights =
      'https://www.pib.gov.in/PressReleasePage.aspx?PRID=1682384&reg=48&lang=2';

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final pad = context.pagePadding;
    final accent = SdgColors.of(7);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('sdg7_title')),
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
              color: accent.withValues(alpha: 0.16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hi
                          ? 'एक जाँच जो कोई भी कर सकता है'
                          : 'One check anyone can do',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hi
                          ? 'बिल पर दोनों रीडिंग छपी होती हैं। उन्हें घटाकर '
                              'लगाई गई यूनिट से मिलाइए। मेल न खाएँ तो दफ़्तर '
                              'को जवाब देना होगा — और यह बात काउंटर पर खड़े '
                              'होकर साबित की जा सकती है।'
                          : 'Both readings are printed on the bill. Subtract '
                              'them and compare with the units you were '
                              'charged for. If they do not match, the office '
                              'has to explain it — and this is the one thing '
                              'you can prove standing at the counter.',
                      style: const TextStyle(fontSize: 14, height: 1.55),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        localeScopedRoute(const BillCheckPage()),
                      ),
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: Text(
                          hi ? 'क्या मेरा बिल सही है?' : 'Is my bill right?'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            _SectionLabel(hi ? 'बिजली' : 'Electricity'),
            _Row(
              icon: Icons.gavel_outlined,
              title: hi
                  ? 'उपभोक्ता के नाते आपके अधिकार'
                  : 'What you are entitled to as a consumer',
              subtitle: hi
                  ? 'मीटर के बिना कनेक्शन नहीं, 45 दिन में शिकायत निपटारा'
                  : 'No connection without a meter, 45-day grievance limit',
              onTap: () => Navigator.of(context).push(
                localeScopedRoute(const _GuidesPage(category: 'rights')),
              ),
            ),
            _Row(
              icon: Icons.calculate_outlined,
              title: hi ? 'बिल कैसे पढ़ें' : 'How to read the bill',
              subtitle: hi
                  ? 'यूनिट, स्लैब, फ़िक्स्ड चार्ज और ड्यूटी'
                  : 'Units, slabs, fixed charges and duty',
              onTap: () => Navigator.of(context).push(
                localeScopedRoute(const _GuidesPage(category: 'bill')),
              ),
            ),
            _Row(
              icon: Icons.report_outlined,
              title: hi ? 'ग़लत बिल कहाँ ले जाएँ' : 'Where to take a wrong bill',
              subtitle: hi
                  ? 'कंपनी, फ़ोरम, लोकपाल — क्रम से'
                  : 'Company, forum, ombudsman — in order',
              onTap: () => Navigator.of(context).push(
                localeScopedRoute(const _GuidesPage(category: 'complaint')),
              ),
            ),

            const SizedBox(height: 22),
            _SectionLabel(hi ? 'छत पर सोलर' : 'Rooftop solar'),
            _Row(
              icon: Icons.solar_power_outlined,
              title: hi
                  ? 'पीएम सूर्य घर: सब्सिडी और शर्तें'
                  : 'PM Surya Ghar: the subsidy and the conditions',
              subtitle: hi
                  ? 'पैसा देने से पहले क्या लिखित में लें'
                  : 'What to get in writing before paying anyone',
              onTap: () => Navigator.of(context).push(
                localeScopedRoute(const _GuidesPage(category: 'solar')),
              ),
            ),
            _Row(
              icon: Icons.open_in_new,
              title: hi ? 'सूर्य घर पोर्टल' : 'Surya Ghar portal',
              subtitle: 'pmsuryaghar.gov.in',
              onTap: () => _open(context, _suryaGhar),
            ),

            const SizedBox(height: 22),
            _SectionLabel(hi ? 'रसोई गैस और चूल्हा' : 'Cooking gas and the stove'),
            _Row(
              icon: Icons.local_fire_department_outlined,
              title: hi
                  ? 'उज्ज्वला सब्सिडी और उसे कैसे जाँचें'
                  : 'The Ujjwala subsidy, and how to check you get it',
              subtitle: hi
                  ? 'बैंक में आती है, दुकान पर छूट नहीं मिलती'
                  : 'It arrives in your bank, not as a shop discount',
              onTap: () => Navigator.of(context).push(
                localeScopedRoute(const _GuidesPage(category: 'lpg')),
              ),
            ),
            _Row(
              icon: Icons.air_outlined,
              title: hi
                  ? 'चूल्हे का धुआँ और सिलेंडर की सुरक्षा'
                  : 'Cooking smoke, and cylinder safety',
              subtitle: hi
                  ? 'घर के भीतर की हवा, और गैस रिसाव पर क्या करें'
                  : 'Indoor air, and what to do about a gas leak',
              onTap: () => Navigator.of(context).push(
                localeScopedRoute(const _GuidesPage(category: 'indoor')),
              ),
            ),
            _Row(
              icon: Icons.open_in_new,
              title: hi ? 'उज्ज्वला पोर्टल' : 'Ujjwala portal',
              subtitle: 'pmuy.gov.in',
              onTap: () => _open(context, _pmuy),
            ),
            _Row(
              icon: Icons.open_in_new,
              title: hi
                  ? 'उपभोक्ता अधिकार नियम, 2020'
                  : 'Rights of Consumers Rules, 2020',
              subtitle: 'pib.gov.in',
              onTap: () => _open(context, _consumerRights),
            ),

            const SizedBox(height: 24),
            _NoPaybackNote(hi: hi),
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

/// Says out loud what the module will not do, and why.
class _NoPaybackNote extends StatelessWidget {
  final bool hi;
  const _NoPaybackNote({required this.hi});

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
                ? 'यहाँ सोलर का हिसाब क्यों नहीं है'
                : 'Why there is no solar payback calculator here',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, height: 1.3),
          ),
          const SizedBox(height: 6),
          Text(
            hi
                ? 'सोलर का आकार और कितने साल में पैसा वापस आएगा — यह प्रति '
                    'किलोवाट लागत, आपके राज्य की टैरिफ़ दर, नेट मीटरिंग के '
                    'नियम और सब्सिडी की रक़म पर निर्भर करता है, और ये सब '
                    'बदलते रहते हैं। एक-दो लाख रुपये के फ़ैसले पर ग़लत आँकड़ा '
                    'देने से अच्छा है कि यह ऐप योजना समझाए और आपको पोर्टल तक '
                    'पहुँचाए। कोटेशन दो वेंडरों से लें और लिखित में लें।'
                : 'System size and payback depend on the installed cost per '
                    'kW, your state tariff, net-metering rules and the '
                    'current subsidy — all of which move. On a one to two '
                    'lakh rupee decision, a confident wrong number is worse '
                    'than none, so this module explains the scheme and sends '
                    'you to the portal. Get quotations from two vendors, in '
                    'writing.',
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
    'rights': ('Your rights', 'आपके अधिकार'),
    'bill': ('Reading the bill', 'बिल पढ़ना'),
    'complaint': ('Complaints', 'शिकायत'),
    'solar': ('Rooftop solar', 'छत पर सोलर'),
    'lpg': ('Cooking gas', 'रसोई गैस'),
    'indoor': ('Smoke and safety', 'धुआँ और सुरक्षा'),
  };

  @override
  Widget build(BuildContext context) {
    final lang = LocaleScope.languageOf(context);
    final hi = lang == 'hi';
    final pad = context.pagePadding;
    final ds = kDatasets.firstWhere((d) => d.collection == 'energyguides');
    final t = _titles[category] ?? ('Energy', 'ऊर्जा');

    return Scaffold(
      appBar: AppBar(
        title: Text(hi ? t.$2 : t.$1),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(7)),
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
