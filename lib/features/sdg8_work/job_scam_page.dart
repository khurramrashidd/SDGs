import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n/locale_scope.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import 'job_scam_check.dart';

class JobScamPage extends StatefulWidget {
  const JobScamPage({super.key});

  @override
  State<JobScamPage> createState() => _JobScamPageState();
}

class _JobScamPageState extends State<JobScamPage> {
  final Set<String> _ticked = {};

  bool get _hi => Localizations.localeOf(context).languageCode == 'hi';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pad = context.pagePadding;
    final result = assessJob(_ticked);

    return Scaffold(
      appBar: AppBar(
        title: Text(_hi ? 'क्या यह नौकरी असली है?' : 'Is this job real?'),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(8)),
        ),
      ),
      body: ContentShell(
        maxWidth: 680,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
          children: [
            Text(
              _hi
                  ? 'जो भी आपके साथ हुआ हो, उस पर निशान लगाएँ।'
                  : 'Tick anything that has happened to you.',
              style: const TextStyle(
                  fontSize: 15.5, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                _hi
                    ? 'कुछ भी भेजा नहीं जाता। यह जाँच इसी फ़ोन में होती है।'
                    : 'Nothing is sent anywhere. This check runs on your '
                        'phone.',
                style: TextStyle(
                    fontSize: 12.5, color: scheme.onSurfaceVariant),
              ),
            ),

            ...kScamFlags.map((f) => _FlagTile(
                  flag: f,
                  hi: _hi,
                  ticked: _ticked.contains(f.id),
                  onTap: () => setState(() {
                    _ticked.contains(f.id)
                        ? _ticked.remove(f.id)
                        : _ticked.add(f.id);
                  }),
                )),

            const SizedBox(height: 22),
            _Verdict(result: result, hi: _hi),
          ],
        ),
      ),
    );
  }
}

class _FlagTile extends StatelessWidget {
  final ScamFlag flag;
  final bool hi;
  final bool ticked;
  final VoidCallback onTap;

  const _FlagTile({
    required this.flag,
    required this.hi,
    required this.ticked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final decisive = flag.weight >= 100;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: ticked
            ? (decisive ? scheme.errorContainer : scheme.tertiaryContainer)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ticked
                    ? (decisive ? scheme.error : scheme.outline)
                    : scheme.outlineVariant,
                width: ticked ? 1.6 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      ticked
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 22,
                      color: ticked
                          ? (decisive
                              ? scheme.error
                              : scheme.onTertiaryContainer)
                          : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        hi ? flag.labelHi : flag.label,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          fontWeight:
                              ticked ? FontWeight.w700 : FontWeight.w500,
                          color: ticked && decisive
                              ? scheme.onErrorContainer
                              : scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                if (ticked) ...[
                  const SizedBox(height: 9),
                  Padding(
                    padding: const EdgeInsets.only(left: 33),
                    child: Text(
                      hi ? flag.noteHi : flag.note,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.5,
                        color: decisive
                            ? scheme.onErrorContainer
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Verdict extends StatelessWidget {
  final ScamResult result;
  final bool hi;
  const _Verdict({required this.result, required this.hi});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (bg, fg, icon, head, headHi, body, bodyHi) =
        switch (result.verdict) {
      ScamVerdict.likelyScam => (
          scheme.errorContainer,
          scheme.onErrorContainer,
          Icons.gpp_bad_outlined,
          'This is almost certainly a scam',
          'यह लगभग निश्चित रूप से धोखाधड़ी है',
          'Stop replying. Do not send money and do not share any more '
              'details. If you have already paid, call your bank now and '
              'then report it on 1930.',
          'जवाब देना बंद करें। पैसे न भेजें और कोई विवरण न दें। अगर पैसे दे '
              'चुके हैं तो तुरंत बैंक को फ़ोन करें, फिर 1930 पर शिकायत करें।',
        ),
      ScamVerdict.beCareful => (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
          Icons.warning_amber_outlined,
          'Be careful — several warning signs',
          'सावधान — कई चेतावनी संकेत हैं',
          'Do not pay anything and do not share bank or Aadhaar details. '
              'Search the company name along with the word "fraud". Ask for '
              'the office address and go and see it before you commit.',
          'कुछ भी भुगतान न करें और बैंक या आधार विवरण साझा न करें। कंपनी का '
              'नाम "fraud" शब्द के साथ खोजें। दफ़्तर का पता माँगें और जाकर '
              'देखें, तभी आगे बढ़ें।',
        ),
      ScamVerdict.probablyFine => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          Icons.verified_user_outlined,
          'No major warning signs so far',
          'अभी तक कोई बड़ा चेतावनी संकेत नहीं',
          'Still check the basics: does the company exist, is the job on '
              'their own website, and does the recruiter write from a '
              'company email. And remember the rule that never changes — '
              'never pay to get a job.',
          'फिर भी बुनियादी बातें जाँचें: कंपनी मौजूद है या नहीं, नौकरी उनकी '
              'अपनी वेबसाइट पर है या नहीं, और भर्तीकर्ता कंपनी के ईमेल से '
              'लिखता है या नहीं। और वह नियम याद रखें जो कभी नहीं बदलता — '
              'नौकरी पाने के लिए कभी पैसे न दें।',
        ),
    };

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: fg, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      hi ? headHi : head,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          color: fg),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Text(
                hi ? bodyHi : body,
                style: TextStyle(fontSize: 14, height: 1.55, color: fg),
              ),
            ],
          ),
        ),
        if (result.verdict != ScamVerdict.probablyFine) ...[
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => launchUrl(Uri(scheme: 'tel', path: '1930')),
            icon: const Icon(Icons.phone),
            label: Text(hi
                ? '1930 — साइबर अपराध हेल्पलाइन'
                : '1930 — cyber crime helpline'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => launchUrl(
              Uri.parse('https://cybercrime.gov.in/'),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.open_in_new),
            label: Text(hi
                ? 'ऑनलाइन शिकायत दर्ज करें'
                : 'Report it online'),
          ),
          const SizedBox(height: 12),
          Text(
            hi
                ? 'पैसे गए हों तो जितनी जल्दी 1930 पर कॉल करेंगे, रकम रुकने '
                    'की संभावना उतनी ज़्यादा है। संदेश, ऑफ़र लेटर और भुगतान '
                    'की रसीदें संभालकर रखें।'
                : 'If money has gone, the sooner you call 1930 the better '
                    'the chance of stopping it. Keep the messages, the offer '
                    'letter and any payment receipts as evidence.',
            style: TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
