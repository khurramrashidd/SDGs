import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Reading a child's arm-band, and knowing which colour means go now.
///
/// The mid-upper arm circumference tape is the one malnutrition test a
/// family can do themselves. Anganwadi workers carry it, and the three
/// colours are the same everywhere:
///   under 11.5 cm  severe acute malnutrition - treatment, not advice
///   11.5 to 12.5   moderate acute malnutrition
///   12.5 and over  outside both of those bands
/// It applies to children aged 6 months to 5 years. Below 6 months the
/// tape is not the measure, which is why the screen says so rather than
/// giving a reading that would be wrong.
///
/// Swelling of both feet is handled separately and deliberately overrides
/// a good tape reading: a child with nutritional oedema can measure in the
/// green band and still be severely ill.
const muacSevereMm = 115;
const muacModerateMm = 125;

enum MuacBand { tooYoung, severe, moderate, outsideBands }

MuacBand muacBand({required int months, required double cm}) {
  if (months < 6) return MuacBand.tooYoung;
  final mm = cm * 10;
  if (mm < muacSevereMm) return MuacBand.severe;
  if (mm < muacModerateMm) return MuacBand.moderate;
  return MuacBand.outsideBands;
}

class MuacPage extends StatefulWidget {
  const MuacPage({super.key});

  @override
  State<MuacPage> createState() => _MuacPageState();
}

class _MuacPageState extends State<MuacPage> {
  final _months = TextEditingController();
  final _cm = TextEditingController();
  bool? _swollenFeet;

  @override
  void dispose() {
    _months.dispose();
    _cm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final months = int.tryParse(_months.text.trim()) ?? -1;
    final cm = double.tryParse(_cm.text.trim()) ?? 0;
    final band = (months >= 0 && cm > 0)
        ? muacBand(months: months, cm: cm)
        : null;

    return ToolScaffold(
      goal: 2,
      title: hi ? 'बच्चे की बाँह की जाँच' : "A child's arm check",
      children: [
        ToolNote(hi
            ? 'यह वही फ़ीते वाली जाँच है जो आंगनवाड़ी कार्यकर्ता करती हैं। बाएँ हाथ की '
                'ऊपरी बाँह के बीचों-बीच फ़ीता लपेटें — न कसकर, न ढीला। 6 महीने से 5 साल '
                'के बच्चों के लिए।'
            : 'This is the tape measure an anganwadi worker uses. Wrap it '
                'around the middle of the upper left arm — not tight, not '
                'loose. For children from 6 months to 5 years.'),
        ToolQuestion(hi ? 'बच्चे की उम्र' : "The child's age"),
        ToolNumber(
          controller: _months,
          label: hi ? 'महीनों में' : 'In months',
          maxDigits: 3,
          icon: Icons.child_care_outlined,
          onChanged: (_) => setState(() {}),
        ),
        ToolQuestion(hi ? 'फ़ीते पर क्या नाप आया?' : 'What did the tape read?'),
        ToolNumber(
          controller: _cm,
          label: hi ? 'बाँह की गोलाई' : 'Arm measurement',
          suffix: 'cm',
          decimal: true,
          maxDigits: 5,
          helper: hi
              ? 'अगर फ़ीता मिलीमीटर में है तो 10 से भाग दें — 124 मिमी यानी 12.4 सेमी।'
              : 'If the tape is in millimetres, divide by 10 — 124 mm is '
                  '12.4 cm.',
          onChanged: (_) => setState(() {}),
        ),
        ToolQuestion(hi
            ? 'क्या बच्चे के दोनों पैरों में सूजन है?'
            : "Are both of the child's feet swollen?"),
        ToolNote(hi
            ? 'दबाने पर गड्ढा बने जो धीरे-धीरे भरे — यह अलग से ख़तरे का संकेत है।'
                ' दोनों पैर, एक नहीं।'
            : 'Press for a few seconds: a dent that fills in slowly. Both '
                'feet, not one. This is a danger sign on its own.'),
        SelectionTile(
          label: hi ? 'हाँ, दोनों में सूजन है' : 'Yes, both are swollen',
          selected: _swollenFeet == true,
          onTap: () => setState(() => _swollenFeet = true),
        ),
        SelectionTile(
          label: hi ? 'नहीं' : 'No',
          selected: _swollenFeet == false,
          onTap: () => setState(() => _swollenFeet = false),
        ),
        if (_swollenFeet == true)
          ToolAnswer(
            headline: hi
                ? 'आज ही बच्चे को दिखाएँ'
                : 'Have the child seen today',
            detail: hi
                ? 'दोनों पैरों की सूजन कुपोषण का गंभीर रूप हो सकती है, चाहे फ़ीते का नाप '
                    'ठीक आए। आंगनवाड़ी या स्वास्थ्य केंद्र ले जाएँ — इंतज़ार न करें।'
                : 'Swelling in both feet can be a severe form of '
                    'malnutrition even when the tape reads fine. Take the '
                    'child to the anganwadi or health centre — do not wait.',
            tone: ToolTone.bad,
            icon: Icons.warning_amber_outlined,
          ),
        if (band == MuacBand.tooYoung)
          ToolAnswer(
            headline: hi
                ? 'इस उम्र में फ़ीता सही पैमाना नहीं'
                : 'The tape is not the measure at this age',
            detail: hi
                ? '6 महीने से छोटे बच्चे का वज़न और बढ़त देखी जाती है, बाँह नहीं। '
                    'वज़न कराने और माँ-बच्चा कार्ड पर बढ़त दर्ज कराने के लिए आंगनवाड़ी '
                    'या स्वास्थ्य केंद्र जाएँ।'
                : 'Under 6 months, weight and growth are what get watched, '
                    'not the arm. Go to the anganwadi or health centre to '
                    'have the baby weighed and the growth marked on the '
                    'mother and child card.',
            tone: ToolTone.plain,
            icon: Icons.info_outline,
          ),
        if (band == MuacBand.severe)
          ToolAnswer(
            headline: hi
                ? 'लाल पट्टी — आज ही इलाज चाहिए'
                : 'Red band — treatment is needed today',
            detail: hi
                ? '11.5 सेमी से कम का मतलब है गंभीर तीव्र कुपोषण। यह सलाह से ठीक नहीं '
                    'होता, इसका इलाज होता है। आज ही आंगनवाड़ी या स्वास्थ्य केंद्र जाएँ '
                    'और पोषण पुनर्वास केंद्र के बारे में पूछें — वहाँ भर्ती और इलाज '
                    'मुफ़्त है। घर पर ज़्यादा खिलाने भर से यह ठीक नहीं होगा।'
                : 'Under 11.5 cm means severe acute malnutrition. That is '
                    'not fixed with advice, it is treated. Go to the '
                    'anganwadi or health centre today and ask about a '
                    'Nutrition Rehabilitation Centre — admission and '
                    'treatment there are free. Feeding more at home will not '
                    'by itself turn this around.',
            tone: ToolTone.bad,
            icon: Icons.emergency_outlined,
          ),
        if (band == MuacBand.moderate)
          ToolAnswer(
            headline: hi
                ? 'पीली पट्टी — इसी हफ़्ते दिखाएँ'
                : 'Yellow band — have the child seen this week',
            detail: hi
                ? '11.5 से 12.5 सेमी के बीच का मतलब है मध्यम तीव्र कुपोषण। आंगनवाड़ी में '
                    'नाम दर्ज कराएँ, घर ले जाने वाला पोषण आहार लें, और हर हफ़्ते नाप '
                    'कराएँ। अभी ध्यान देने से यह लाल पट्टी तक नहीं पहुँचता।'
                : 'Between 11.5 and 12.5 cm means moderate acute '
                    'malnutrition. Get the child on the anganwadi register, '
                    'take the take-home ration, and have the arm measured '
                    'every week. Acting now is what stops it reaching the '
                    'red band.',
            tone: ToolTone.warn,
            icon: Icons.priority_high,
          ),
        if (band == MuacBand.outsideBands)
          ToolAnswer(
            headline: hi
                ? 'हरी पट्टी — इस नाप के हिसाब से ठीक'
                : 'Green band — fine on this measure',
            detail: hi
                ? 'फिर भी हर महीने आंगनवाड़ी में वज़न कराते रहें। एक बार की नाप एक दिन '
                    'की बात बताती है; बढ़त का चार्ट पूरी कहानी बताता है।'
                : 'Still have the child weighed at the anganwadi every '
                    'month. One measurement tells you about one day; the '
                    'growth chart tells the whole story.',
            tone: ToolTone.good,
            icon: Icons.check_circle_outline,
          ),
        if (band != null && band != MuacBand.tooYoung)
          const SourceNote(
            text: 'Bands for children 6-59 months: under 115 mm severe, '
                '115 to under 125 mm moderate (WHO reference tables).',
            url: 'https://www.cdc.gov/immigrant-refugee-health/media/pdfs/'
                '2025/06/MUAC-reference-tables_WHO-508.pdf',
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

/// What to feed a baby, by age, and how often.
///
/// Built around the two things that go wrong most: starting other food
/// before six months, and giving food after six months that is too thin to
/// be worth eating. Quantities are deliberately described rather than
/// weighed, because nobody has scales and "as thick as it can be and still
/// be swallowed" is the useful instruction.
class BabyFeedingPage extends StatefulWidget {
  const BabyFeedingPage({super.key});

  @override
  State<BabyFeedingPage> createState() => _BabyFeedingPageState();
}

class _BabyFeedingPageState extends State<BabyFeedingPage> {
  int? _months;

  static const _ages = [
    (0, '0 to 6 months', '0 से 6 महीने'),
    (6, '6 to 8 months', '6 से 8 महीने'),
    (9, '9 to 11 months', '9 से 11 महीने'),
    (12, '12 to 23 months', '12 से 23 महीने'),
  ];

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 2,
      title: hi ? 'शिशु का आहार' : 'Feeding a baby',
      children: [
        ToolQuestion(hi ? 'बच्चे की उम्र' : "The baby's age"),
        for (final a in _ages)
          SelectionTile(
            label: hi ? a.$3 : a.$2,
            selected: _months == a.$1,
            onTap: () => setState(() => _months = a.$1),
          ),
        if (_months == 0) ...[
          ToolAnswer(
            headline: hi
                ? 'सिर्फ़ माँ का दूध — पानी भी नहीं'
                : "Only mother's milk — not even water",
            detail: hi
                ? 'छह महीने तक सिर्फ़ स्तनपान। गर्मी में भी पानी की ज़रूरत नहीं होती, '
                    'दूध में ही काफ़ी पानी है। घुट्टी, शहद, ऊपर का दूध या दलिया इस उम्र में '
                    'फ़ायदे से ज़्यादा नुक़सान करते हैं।'
                : 'Breastfeeding only, for six months. Even in hot weather '
                    'no water is needed — the milk has enough. Gripe water, '
                    'honey, cow or tinned milk and porridge do more harm '
                    'than good at this age.',
            tone: ToolTone.good,
            icon: Icons.child_care_outlined,
          ),
          const SizedBox(height: 8),
          ToolNote(hi
              ? 'जितनी बार बच्चा माँगे, दिन और रात। जन्म के पहले घंटे में पहला दूध '
                  '(पीला गाढ़ा) ज़रूर दें — उसे फेंकें नहीं।'
              : 'As often as the baby asks, day and night. Give the first '
                  'milk — the thick yellow colostrum — within the first hour '
                  'after birth. Do not throw it away.'),
        ],
        if (_months != null && _months! >= 6) ...[
          ToolAnswer(
            headline: switch (_months) {
              6 => hi
                  ? 'दिन में 2 से 3 बार, साथ में स्तनपान'
                  : '2 to 3 times a day, plus breastfeeding',
              9 => hi
                  ? 'दिन में 3 से 4 बार, साथ में स्तनपान'
                  : '3 to 4 times a day, plus breastfeeding',
              _ => hi
                  ? 'दिन में 3 से 4 बार और 1-2 बार नाश्ता'
                  : '3 to 4 meals a day, plus 1 to 2 snacks',
            },
            detail: hi
                ? 'स्तनपान दो साल या उससे आगे तक चलता रहे। ऊपर का खाना उसकी जगह नहीं '
                    'लेता, उसके साथ चलता है।'
                : 'Breastfeeding carries on to two years or beyond. Other '
                    'food goes alongside it, not instead of it.',
            tone: ToolTone.good,
            icon: Icons.restaurant_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'कैसा खाना' : 'What the food should be like',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ToolNote(switch (_months) {
            6 => hi
                ? 'मसला हुआ, गाढ़ा — इतना गाढ़ा कि चम्मच से टपके नहीं। पतली दाल का पानी '
                    'या पतला दलिया पेट भर देता है पर ताक़त नहीं देता। थोड़े से शुरू करें और '
                    'धीरे-धीरे बढ़ाएँ।'
                : 'Mashed and thick — thick enough not to run off a spoon. '
                    'Thin dal water or watery porridge fills the stomach '
                    'without feeding the child. Start with a little and '
                    'build up.',
            9 => hi
                ? 'बारीक कटा या मसला हुआ, और हाथ से पकड़कर खाने लायक टुकड़े। इस उम्र में '
                    'ज़्यादातर बच्चे ख़ुद उठाकर खाने लगते हैं।'
                : 'Finely chopped or mashed, with pieces the baby can pick '
                    'up. Most babies start feeding themselves around now.',
            _ => hi
                ? 'घर का वही खाना जो सब खाते हैं, बस कम मिर्च और थोड़ा नरम।'
                : 'The same food the family eats, with less chilli and a '
                    'little softer.',
          }),
          const SizedBox(height: 10),
          const ToolChecklist(
            storageKey: 'baby_feeding_v1',
            introEn: 'Try to get these into the week, not every meal.',
            introHi: 'ये हफ़्ते भर में आ जाएँ, हर बार ज़रूरी नहीं।',
            items: [
              CheckItem('egg', 'Egg, fish, meat or chicken, as often as you '
                  'can', 'अंडा, मछली, मांस या चिकन, जितनी बार हो सके'),
              CheckItem('dal', 'Dal, beans or groundnut',
                  'दाल, राजमा-चना या मूँगफली'),
              CheckItem('green', 'Dark green leaves and orange vegetables',
                  'गहरी हरी पत्तियाँ और नारंगी सब्ज़ियाँ'),
              CheckItem('milk', 'Milk, curd or paneer', 'दूध, दही या पनीर'),
              CheckItem('oil', 'A little oil or ghee in the food',
                  'खाने में थोड़ा तेल या घी',
                  noteEn: 'It makes a small quantity worth more.',
                  noteHi: 'इससे थोड़ी मात्रा में भी ज़्यादा ताक़त आती है।'),
              CheckItem('iron', 'The iron syrup or tablets from the '
                  'anganwadi', 'आंगनवाड़ी से मिलने वाला आयरन सिरप या गोली'),
            ],
          ),
          const SizedBox(height: 10),
          ToolNote(hi
              ? 'बोतल से दूध न पिलाएँ — उसे साफ़ रखना मुश्किल है, कटोरी-चम्मच बेहतर है। '
                  'बीमारी के दौरान और बाद में खाना बढ़ाएँ, घटाएँ नहीं।'
              : 'Avoid feeding bottles — they are hard to keep clean, and a '
                  'cup and spoon work better. During and after an illness, '
                  'feed more, not less.'),
          const SourceNote(
            text: 'Ages and meal frequency: World Health Organization, '
                'recommended food for the very early years.',
            url: 'https://www.who.int/news-room/questions-and-answers/item/'
                'child-health-recommended-food-for-the-very-early-years',
          ),
        ],
      ],
    );
  }
}
