import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Which social-security pension a person can claim, and how much of it is
/// the Centre's share.
///
/// The three pensions under the National Social Assistance Programme are
/// paid as a central amount plus a state top-up, and the state's share is
/// usually the larger part of it - in many states the total comes to around
/// a thousand rupees a month. People are told a figure at the block office
/// and have no way to tell whether it is right, so this screen does the one
/// thing that can be done honestly from a phone: it names the scheme the
/// person qualifies for, states the central amount exactly, and says
/// plainly that the state adds to it and only the state can tell you how
/// much.
///
/// Central amounts, from the Ministry of Rural Development:
///   old age (IGNOAPS)    60-79: Rs 200   80+: Rs 500
///   widow  (IGNWPS)      40-79: Rs 300   80+: Rs 500
///   disability (IGNDPS)  18-79: Rs 300   80+: Rs 500
/// All three require the household to be below the poverty line, on the
/// state's BPL list. A severe or multiple disability means 80 per cent or
/// more in the disability certificate.
enum PensionKind { oldAge, widow, disability }

/// Central share per month, in rupees. Returns null if the age is outside
/// the scheme's range.
int? centralPension(PensionKind kind, int age) {
  if (age >= 80) {
    // Above 80 every one of the three pays the same central amount, and
    // the lower age bound no longer matters: an 80-year-old is past it.
    return 500;
  }
  return switch (kind) {
    PensionKind.oldAge => age >= 60 ? 200 : null,
    PensionKind.widow => age >= 40 ? 300 : null,
    PensionKind.disability => age >= 18 ? 300 : null,
  };
}

const _nsapUrl = 'https://nsap.nic.in/';
const _umangUrl = 'https://web.umang.gov.in/';

class PensionCheckPage extends StatefulWidget {
  const PensionCheckPage({super.key});

  @override
  State<PensionCheckPage> createState() => _PensionCheckPageState();
}

class _PensionCheckPageState extends State<PensionCheckPage> {
  final _age = TextEditingController();
  final Set<PensionKind> _applies = {};
  bool? _bpl;

  @override
  void dispose() {
    _age.dispose();
    super.dispose();
  }

  String _name(PensionKind k, bool hi) => switch (k) {
        PensionKind.oldAge =>
          hi ? 'वृद्धावस्था पेंशन (IGNOAPS)' : 'Old age pension (IGNOAPS)',
        PensionKind.widow =>
          hi ? 'विधवा पेंशन (IGNWPS)' : 'Widow pension (IGNWPS)',
        PensionKind.disability => hi
            ? 'दिव्यांग पेंशन (IGNDPS)'
            : 'Disability pension (IGNDPS)',
      };

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final age = int.tryParse(_age.text.trim());

    // What the person qualifies for: ticked, and inside the age range.
    final eligible = <PensionKind, int>{};
    final tooYoung = <PensionKind>[];
    if (age != null && age > 0) {
      for (final k in _applies) {
        final amount = centralPension(k, age);
        if (amount == null) {
          tooYoung.add(k);
        } else {
          eligible[k] = amount;
        }
      }
    }

    Widget tick(PensionKind k, String en, String h, String sub, String subHi) =>
        SelectionTile(
          label: hi ? h : en,
          subtitle: hi ? subHi : sub,
          selected: _applies.contains(k),
          onTap: () => setState(() {
            if (!_applies.remove(k)) _applies.add(k);
          }),
        );

    return ToolScaffold(
      goal: 1,
      title: hi ? 'पेंशन बनती है या नहीं' : 'Which pension you can claim',
      children: [
        ToolNote(hi
            ? 'तीनों पेंशन में केंद्र का हिस्सा तय है और राज्य उसमें अपना हिस्सा जोड़ता है — '
                'कई राज्यों में कुल रक़म हज़ार रुपये के आसपास पहुँचती है। यहाँ केंद्र का '
                'हिस्सा ठीक-ठीक बताया गया है; कुल कितना बनेगा यह आपके राज्य से ही पता '
                'चलेगा।'
            : 'All three pensions are a fixed central amount plus whatever '
                'the state adds, and the state\'s share is usually the '
                'larger part - in many states the total comes to around a '
                'thousand rupees. The central share below is exact. Only '
                'your state can tell you the total.'),
        ToolQuestion(hi ? 'उम्र' : 'Age'),
        ToolNumber(
          controller: _age,
          label: hi ? 'पूरे साल' : 'Completed years',
          maxDigits: 3,
          icon: Icons.cake_outlined,
          onChanged: (_) => setState(() {}),
        ),
        ToolQuestion(hi ? 'इनमें क्या लागू होता है' : 'Which of these apply'),
        tick(PensionKind.oldAge, 'Aged 60 or more', '60 साल या उससे ऊपर',
            'Old age pension starts at 60', 'वृद्धावस्था पेंशन 60 से शुरू होती है'),
        tick(PensionKind.widow, 'A widow', 'विधवा',
            'Widow pension starts at 40', 'विधवा पेंशन 40 से शुरू होती है'),
        tick(
            PensionKind.disability,
            'Severe or multiple disability',
            'गंभीर या बहु-दिव्यांगता',
            '80% or more in the disability certificate, from 18',
            'दिव्यांगता प्रमाण पत्र में 80% या अधिक, 18 से'),
        ToolQuestion(hi ? 'बीपीएल सूची में हैं?' : 'On the BPL list?'),
        SelectionTile(
          label: hi ? 'हाँ' : 'Yes',
          selected: _bpl == true,
          onTap: () => setState(() => _bpl = true),
        ),
        SelectionTile(
          label: hi ? 'नहीं, या पता नहीं' : 'No, or I do not know',
          selected: _bpl == false,
          onTap: () => setState(() => _bpl = false),
        ),
        if (age != null && age > 0 && _applies.isNotEmpty) ...[
          if (eligible.isEmpty)
            ToolAnswer(
              headline: hi
                  ? 'इस उम्र में इनमें से कोई नहीं बनती'
                  : 'None of these starts at this age yet',
              detail: hi
                  ? 'वृद्धावस्था 60 से, विधवा 40 से, दिव्यांग 18 से। राज्य की अपनी '
                      'योजनाएँ इससे पहले भी हो सकती हैं — ब्लॉक कार्यालय में पूछें।'
                  : 'Old age starts at 60, widow at 40, disability at 18. '
                      'Your state may run its own scheme that starts '
                      'earlier - ask at the block office.',
              tone: ToolTone.warn,
              icon: Icons.schedule,
            )
          else ...[
            ToolAnswer(
              headline: eligible.length == 1
                  ? (hi ? 'एक पेंशन बनती है' : 'One pension fits')
                  : (hi
                      ? '${eligible.length} पेंशन बनती हैं — एक ही मिलेगी'
                      : '${eligible.length} fit - you will be paid one'),
              detail: hi
                  ? 'एक व्यक्ति को इनमें से एक ही पेंशन मिलती है। जिसमें कुल रक़म '
                      'ज़्यादा बनती हो, वही लें — राज्य का हिस्सा हर पेंशन में अलग होता है, '
                      'इसलिए ब्लॉक कार्यालय में तीनों की कुल रक़म पूछकर तय करें।'
                  : 'One person is paid only one of these. Take the one '
                      'whose total is larger - the state top-up differs '
                      'between them, so ask the block office for the total '
                      'of each before you choose.',
              tone: ToolTone.good,
              icon: Icons.verified_outlined,
            ),
            const SizedBox(height: 10),
            for (final e in eligible.entries)
              ToolLine(_name(e.key, hi),
                  hi ? '₹${e.value} + राज्य' : '₹${e.value} + state',
                  strong: true),
            const SizedBox(height: 6),
            ToolNote(hi
                ? 'ऊपर लिखी रक़म सिर्फ़ केंद्र का हिस्सा है, महीने की। राज्य इसमें जोड़ता '
                    'है और वही रक़म आपके खाते में आती है।'
                : 'The figures above are the central share only, per month. '
                    'The state adds to it, and the total is what reaches '
                    'your account.'),
          ],
          if (tooYoung.isNotEmpty)
            ToolNote(hi
                ? 'अभी उम्र कम है: ${tooYoung.map((k) => _name(k, true)).join(', ')}। '
                    'उम्र पूरी होने पर दोबारा देखें।'
                : 'Not yet old enough for: '
                    '${tooYoung.map((k) => _name(k, false)).join(', ')}. '
                    'Check again at that age.'),
          if (_bpl == false)
            ToolAnswer(
              headline: hi
                  ? 'पहले बीपीएल सूची देखें'
                  : 'Check the BPL list first',
              detail: hi
                  ? 'तीनों केंद्रीय पेंशन बीपीएल परिवारों के लिए हैं। सूची राज्य रखता '
                      'है और उसमें नाम होना ज़रूरी है — ग्राम पंचायत या ब्लॉक कार्यालय में '
                      'अपना नाम देखें। कई राज्यों की अपनी पेंशन योजनाएँ बीपीएल के बाहर भी '
                      'हैं, आय की सीमा पर; वह अलग से पूछें।'
                  : 'All three central pensions are for below-poverty-line '
                      'households. The list is the state\'s, and your name '
                      'has to be on it - check at the gram panchayat or '
                      'block office. Several states run their own pension '
                      'on an income limit instead, outside BPL; ask about '
                      'that separately.',
              tone: ToolTone.warn,
              icon: Icons.list_alt_outlined,
            ),
          const SizedBox(height: 14),
          Text(hi ? 'अर्ज़ी के साथ क्या लगेगा' : 'What the application needs',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const ToolChecklist(
            storageKey: 'pension_papers_v1',
            items: [
              CheckItem('age', 'Proof of age - Aadhaar, birth certificate, '
                  'school record or voter card',
                  'उम्र का सबूत — आधार, जन्म प्रमाण पत्र, स्कूल का रिकॉर्ड या मतदाता '
                      'पहचान पत्र'),
              CheckItem('bpl', 'BPL card or the ration card the state accepts',
                  'बीपीएल कार्ड या राज्य जो राशन कार्ड मानता है'),
              CheckItem('bank', 'Bank passbook in the applicant\'s own name',
                  'अर्ज़ीदार के ही नाम की बैंक पासबुक',
                  noteEn: 'Not a son\'s or husband\'s account. The pension is '
                      'paid into the pensioner\'s own account.',
                  noteHi: 'बेटे या पति का खाता नहीं। पेंशन पेंशनभोगी के अपने खाते में '
                      'आती है।'),
              CheckItem('aadhaar', 'Aadhaar, seeded to that bank account',
                  'आधार, उसी बैंक खाते से सीड किया हुआ'),
              CheckItem('widow', 'For widow pension: the husband\'s death '
                  'certificate', 'विधवा पेंशन के लिए: पति का मृत्यु प्रमाण पत्र'),
              CheckItem('disability', 'For disability pension: the disability '
                  'certificate showing 80% or more',
                  'दिव्यांग पेंशन के लिए: 80% या अधिक वाला दिव्यांगता प्रमाण पत्र'),
              CheckItem('photo', 'Two passport photographs',
                  'दो पासपोर्ट फ़ोटो'),
            ],
          ),
          ToolNote(hi
              ? 'अर्ज़ी ग्राम पंचायत, ब्लॉक कार्यालय, नगर पालिका या उमंग ऐप से दी जा '
                  'सकती है। रसीद लेना न भूलें — बाद में शिकायत करनी हो तो वही काम आती है।'
              : 'Apply at the gram panchayat, block office or municipality, '
                  'or through the UMANG app. Take the receipt - it is what '
                  'you will need if you have to complain later.'),
          const SourceNote(
            text: 'National Social Assistance Programme, Ministry of Rural '
                'Development',
            url: _nsapUrl,
          ),
          const SourceNote(text: 'Apply through UMANG', url: _umangUrl),
        ],
      ],
    );
  }
}
