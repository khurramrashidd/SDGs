import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Making water safe to drink, and knowing when it is not.
///
/// A note on the chlorine screen, because it is built against the obvious
/// design. It does not carry a dose. Tablets sold in India run from 3.5 mg
/// to several grams and treat anywhere from one litre to a tank, so a
/// number printed in an app would be wrong for most packets somebody holds,
/// and wrong in the direction that matters: too little chlorine looks
/// exactly like enough. What the screen does instead is read the packet's
/// own figure back as arithmetic for the container in front of them.

const _cpcbUrl = 'https://cpcb.nic.in/';
const _jjmWqUrl = 'https://ejalshakti.gov.in/WQMIS/';
const _jjmUrl = 'https://jaljeevanmission.gov.in/';

/// What the household is treating water in.
enum WaterVessel { pot, bucket, drum, tank, custom }

/// Litres, for the common vessels.
int vesselLitres(WaterVessel v) => switch (v) {
      WaterVessel.pot => 15,
      WaterVessel.bucket => 20,
      WaterVessel.drum => 200,
      WaterVessel.tank => 1000,
      WaterVessel.custom => 0,
    };

/// What they are dosing with.
enum ChlorineForm { tablet, solution, bleachingPowder }

class ChlorineDosePage extends StatefulWidget {
  const ChlorineDosePage({super.key});

  @override
  State<ChlorineDosePage> createState() => _ChlorineDosePageState();
}

class _ChlorineDosePageState extends State<ChlorineDosePage> {
  WaterVessel _vessel = WaterVessel.bucket;
  final _customLitres = TextEditingController();
  ChlorineForm _form = ChlorineForm.tablet;
  final _packetLitres = TextEditingController();

  @override
  void dispose() {
    _customLitres.dispose();
    _packetLitres.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final litres = _vessel == WaterVessel.custom
        ? (double.tryParse(_customLitres.text.trim()) ?? 0)
        : vesselLitres(_vessel).toDouble();
    final perUnit = double.tryParse(_packetLitres.text.trim()) ?? 0;
    final units = (litres > 0 && perUnit > 0) ? litres / perUnit : null;

    Widget vessel(WaterVessel v, String en, String h, String sub) =>
        SelectionTile(
          label: hi ? h : en,
          subtitle: sub,
          selected: _vessel == v,
          onTap: () => setState(() => _vessel = v),
        );

    return ToolScaffold(
      goal: 6,
      title: hi ? 'पानी में क्लोरीन कितना डालें' : 'How much chlorine for my container',
      children: [
        ToolNote(hi
            ? 'यहाँ कोई तय मात्रा नहीं लिखी है, और जानबूझकर नहीं लिखी है। बाज़ार में '
                'मिलने वाली गोलियाँ अलग-अलग ताक़त की होती हैं — कोई एक लीटर के लिए, '
                'कोई बीस लीटर के लिए, कोई पूरे टैंक के लिए। इसलिए यह स्क्रीन आपके '
                'पैकेट पर लिखी मात्रा लेकर आपके बर्तन का हिसाब कर देती है। कम क्लोरीन '
                'डालना सबसे ख़तरनाक है, क्योंकि देखने में वह पूरा जैसा ही लगता है।'
            : 'There is no fixed dose on this screen, deliberately. Tablets '
                'sold here come in different strengths - some for one litre, '
                'some for twenty, some for a whole tank. So this screen takes '
                'the figure printed on your packet and works out your '
                'container. Under-dosing is the dangerous mistake, because '
                'too little chlorine looks exactly like enough.'),
        ToolQuestion(hi ? 'किसमें डालना है' : 'What are you treating'),
        vessel(WaterVessel.pot, 'A matka or pot', 'मटका या घड़ा', '~15 L'),
        vessel(WaterVessel.bucket, 'A bucket', 'बाल्टी', '~20 L'),
        vessel(WaterVessel.drum, 'A drum', 'ड्रम', '~200 L'),
        vessel(WaterVessel.tank, 'An overhead tank', 'छत की टंकी', '~1000 L'),
        vessel(WaterVessel.custom, 'Some other size', 'कोई और माप', ''),
        if (_vessel == WaterVessel.custom)
          ToolNumber(
            controller: _customLitres,
            label: hi ? 'कितने लीटर' : 'How many litres',
            decimal: true,
            maxDigits: 6,
            icon: Icons.water_drop_outlined,
            onChanged: (_) => setState(() {}),
          ),
        ToolQuestion(hi ? 'आपके पास क्या है' : 'What do you have'),
        SelectionTile(
          label: hi ? 'क्लोरीन की गोली' : 'A chlorine tablet',
          selected: _form == ChlorineForm.tablet,
          onTap: () => setState(() => _form = ChlorineForm.tablet),
        ),
        SelectionTile(
          label: hi ? 'क्लोरीन का घोल (बोतल)' : 'Chlorine solution (a bottle)',
          selected: _form == ChlorineForm.solution,
          onTap: () => setState(() => _form = ChlorineForm.solution),
        ),
        SelectionTile(
          label: hi ? 'ब्लीचिंग पाउडर' : 'Bleaching powder',
          selected: _form == ChlorineForm.bleachingPowder,
          onTap: () => setState(() => _form = ChlorineForm.bleachingPowder),
        ),
        if (_form == ChlorineForm.bleachingPowder)
          ToolAnswer(
            headline: hi
                ? 'ब्लीचिंग पाउडर का हिसाब घर पर न लगाएँ'
                : 'Do not work out bleaching powder at home',
            detail: hi
                ? 'ब्लीचिंग पाउडर की ताक़त खुली हवा में रखते-रखते घटती जाती है, और '
                    'कितनी घटी यह देखकर पता नहीं चलता — इसलिए घर पर चम्मच से मात्रा '
                    'तय करना भरोसे लायक़ नहीं है। यह कुएँ और सार्वजनिक टंकी के लिए है, '
                    'और वहाँ जल जाँच कर्मचारी या ग्राम पंचायत का कर्मचारी ही डालता है। '
                    'घर के पीने के पानी के लिए गोली या घोल लें, या पानी उबाल लें।'
                : 'Bleaching powder loses strength as it sits in the open, '
                    'and how much it has lost does not show, so measuring it '
                    'by spoon at home is not reliable. It is for wells and '
                    'public tanks, where the water quality worker or the '
                    'panchayat does the dosing. For drinking water at home, '
                    'use a tablet or a solution, or boil it.',
            tone: ToolTone.warn,
            icon: Icons.science_outlined,
          )
        else ...[
          ToolQuestion(_form == ChlorineForm.tablet
              ? (hi
                  ? 'पैकेट पर लिखा है: एक गोली कितने लीटर के लिए?'
                  : 'The packet says: one tablet treats how many litres?')
              : (hi
                  ? 'बोतल पर लिखा है: एक ढक्कन या एक ml कितने लीटर के लिए?'
                  : 'The bottle says: one cap or one ml treats how many litres?')),
          ToolNumber(
            controller: _packetLitres,
            label: hi ? 'लीटर' : 'Litres',
            decimal: true,
            maxDigits: 6,
            icon: Icons.local_pharmacy_outlined,
            onChanged: (_) => setState(() {}),
          ),
          ToolNote(hi
              ? 'यह संख्या पैकेट या बोतल पर छपी होती है। न मिले तो दुकानदार से '
                  'पूछें या दूसरा पैकेट लें — अंदाज़े से न डालें।'
              : 'This number is printed on the packet or the bottle. If you '
                  'cannot find it, ask the shopkeeper or get another packet - '
                  'do not guess it.'),
          if (units != null)
            ToolAnswer(
              headline: _form == ChlorineForm.tablet
                  ? (hi
                      ? '${units % 1 == 0 ? units.round() : units.toStringAsFixed(1)} गोली'
                      : '${units % 1 == 0 ? units.round() : units.toStringAsFixed(1)} tablet(s)')
                  : (hi
                      ? '${units % 1 == 0 ? units.round() : units.toStringAsFixed(1)} ढक्कन या ml'
                      : '${units % 1 == 0 ? units.round() : units.toStringAsFixed(1)} caps or ml'),
              detail: hi
                  ? '${litres.round()} लीटर पानी के लिए। डालकर अच्छी तरह हिलाएँ और कम '
                      'से कम 30 मिनट रखा रहने दें — उससे पहले न पिएँ। हल्की क्लोरीन की '
                      'गंध आना ठीक है; उसका मतलब है कि असर बचा हुआ है।'
                  : 'for ${litres.round()} litres. Add it, stir well, and '
                      'leave it at least 30 minutes before drinking. A faint '
                      'chlorine smell afterwards is right - it means some is '
                      'still working.',
              tone: ToolTone.good,
              icon: Icons.check_circle_outline,
            ),
        ],
        const SizedBox(height: 14),
        Text(hi ? 'डालने से पहले' : 'Before you add it',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'पानी गंदला हो तो पहले साफ़ करें — कपड़े से छानकर या कुछ घंटे रखकर '
                      'ऊपर का साफ़ पानी अलग कर लें। गंदले पानी में क्लोरीन ठीक से काम '
                      'नहीं करता।',
                  'बर्तन साफ़ और ढक्कन वाला हो।',
                  'डालकर हिलाएँ, फिर ढककर 30 मिनट रखें।',
                  'निकालने के लिए डुबोकर भरने के बजाय टोंटी या करछुल इस्तेमाल करें — '
                      'हाथ डालने से पानी दोबारा गंदा हो जाता है।',
                ]
              : const [
                  'If the water is cloudy, clear it first - strain it '
                      'through cloth, or let it stand a few hours and pour '
                      'off the clear water. Chlorine does not work properly '
                      'in cloudy water.',
                  'Use a clean container with a lid.',
                  'Add, stir, cover, and leave 30 minutes.',
                  'Take water out with a tap or a ladle rather than dipping - '
                      'a hand in the pot puts the dirt back.',
                ],
        ),
        ToolDonts(
          heading: hi
              ? 'क्लोरीन इनसे नहीं बचाता'
              : 'What chlorine does not deal with',
          items: hi
              ? const [
                  'फ़्लोराइड, आर्सेनिक, लोहा, खारापन — रसायन क्लोरीन से नहीं जाते। '
                      'इनके लिए जाँच और अलग इलाज चाहिए।',
                  'गंदलापन — क्लोरीन पानी को साफ़ नहीं करता, सिर्फ़ कीटाणु मारता है',
                  'कुछ परजीवी और कीड़ों के अंडे क्लोरीन से नहीं मरते; शक हो तो उबालें',
                  'दवा से ज़्यादा डालना भी ठीक नहीं — मात्रा दोगुनी करने से सुरक्षा '
                      'दोगुनी नहीं होती',
                ]
              : const [
                  'Fluoride, arsenic, iron, salinity - chemicals do not go '
                      'with chlorine. Those need testing and separate '
                      'treatment.',
                  'Cloudiness - chlorine kills germs, it does not clean the '
                      'water',
                  'Some parasites and worm eggs survive chlorine; if in '
                      'doubt, boil',
                  'More is not better - doubling the dose does not double '
                      'the safety',
                ],
        ),
        ToolNote(hi
            ? 'उबालना हमेशा चलता है: पानी में तेज़ उबाल आने के बाद एक मिनट और उबलने '
                'दें, फिर ढककर ठंडा करें। क्लोरीन न हो या भरोसा न हो तो यही करें।'
            : 'Boiling always works: once it comes to a rolling boil, keep it '
                'there one more minute, then cover and cool. If there is no '
                'chlorine, or any doubt, do this.'),
        const SourceNote(
            text: 'Jal Jeevan Mission - water quality', url: _jjmWqUrl),
      ],
    );
  }
}

// --- Water testing ----------------------------------------------------

/// What the household is worried about. Each points at a different test
/// and a different fix, and three of them cannot be seen or tasted at all.
enum WaterWorry { illness, taste, colour, teeth, area, nothing }

class WaterTestPage extends StatefulWidget {
  const WaterTestPage({super.key});

  @override
  State<WaterTestPage> createState() => _WaterTestPageState();
}

class _WaterTestPageState extends State<WaterTestPage> {
  WaterWorry? _worry;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    Widget pick(WaterWorry w, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _worry == w,
          onTap: () => setState(() => _worry = w),
        );

    return ToolScaffold(
      goal: 6,
      title: hi ? 'पानी की जाँच: कहाँ और कैसे' : 'Water testing: where and how',
      children: [
        ToolNote(hi
            ? 'हर ज़िले में सरकारी जल जाँच प्रयोगशाला है, और जल जीवन मिशन के तहत आम '
                'नागरिक वहाँ पानी की जाँच करा सकते हैं — बहुत कम शुल्क पर या मुफ़्त। '
                'गाँव में आशा, आँगनवाड़ी कार्यकर्ता या जल सहिया को फ़ील्ड टेस्ट किट भी '
                'दी जाती है।'
            : 'Every district has a government water testing laboratory, and '
                'under the Jal Jeevan Mission ordinary citizens can get water '
                'tested there - free or at a very small charge. In villages '
                'the ASHA, anganwadi worker or Jal Sahiya is also given a '
                'field test kit.'),
        ToolQuestion(hi ? 'चिंता किस बात की है' : 'What is the worry'),
        pick(WaterWorry.illness, 'People keep falling ill - loose motions, '
            'stomach trouble', 'घर में बार-बार बीमारी — दस्त, पेट की दिक़्क़त'),
        pick(WaterWorry.taste, 'The water tastes salty or bitter',
            'पानी खारा या कड़वा लगता है'),
        pick(WaterWorry.colour, 'It is yellow, red or leaves stains',
            'पीला, लाल है या दाग़ छोड़ता है'),
        pick(WaterWorry.teeth, 'Yellow or brown marks on teeth, joint pain',
            'दाँतों पर पीले-भूरे धब्बे, जोड़ों में दर्द'),
        pick(WaterWorry.area, 'We have heard this area has a problem',
            'सुना है इस इलाक़े में दिक़्क़त है'),
        pick(WaterWorry.nothing, 'Nothing wrong, just want it checked',
            'कुछ ग़लत नहीं, बस जाँच करानी है'),
        if (_worry != null) ...[
          ToolAnswer(
            headline: switch (_worry!) {
              WaterWorry.illness => hi ? 'पहले जीवाणु की जाँच' : 'Start with the bacteria test',
              WaterWorry.taste => hi ? 'खारापन और नाइट्रेट की जाँच' : 'Test for salinity and nitrate',
              WaterWorry.colour => hi ? 'लोहे की जाँच' : 'Test for iron',
              WaterWorry.teeth => hi ? 'फ़्लोराइड की जाँच — जल्दी कराएँ' : 'Fluoride test - do this soon',
              WaterWorry.area => hi ? 'पूरी रासायनिक जाँच' : 'The full chemical panel',
              WaterWorry.nothing => hi ? 'साल में दो बार कराना ठीक है' : 'Twice a year is the right habit',
            },
            detail: switch (_worry!) {
              WaterWorry.illness => hi
                  ? 'बार-बार दस्त का सबसे आम कारण पानी में मल-जीवाणु होना है, और वह '
                      'न दिखता है न स्वाद में आता है। जाँच का नाम है बैक्टीरियोलॉजिकल '
                      'टेस्ट (H2S स्ट्रिप या MPN)। नतीजा आने तक पानी उबालकर या '
                      'क्लोरीन डालकर पिएँ।'
                  : 'Repeated loose motions most often come from faecal '
                      'bacteria in the water, which neither shows nor tastes. '
                      'The test to ask for is the bacteriological test (an '
                      'H2S strip or MPN). Until the result comes, boil the '
                      'water or chlorinate it.',
              WaterWorry.taste => hi
                  ? 'खारा स्वाद आमतौर पर घुले हुए लवण (TDS) या क्लोराइड का होता है, '
                      'और कड़वापन नाइट्रेट का हो सकता है। नाइट्रेट छोटे बच्चों के लिए '
                      'ख़तरनाक है, और उबालने से वह जाता नहीं — बल्कि पानी भाप बनकर '
                      'घटता है तो नाइट्रेट और गाढ़ा हो जाता है। जाँच ज़रूरी है।'
                  : 'A salty taste is usually dissolved salts (TDS) or '
                      'chloride; bitterness can be nitrate. Nitrate is '
                      'dangerous for small children, and boiling does not '
                      'remove it - as the water boils away the nitrate gets '
                      'more concentrated. Get it tested.',
              WaterWorry.colour => hi
                  ? 'पीला-लाल रंग और कपड़ों-बर्तनों पर दाग़ आमतौर पर लोहे का होता है। '
                      'यह सेहत के लिए उतना ख़तरनाक नहीं है जितना असुविधाजनक, और इसका '
                      'इलाज है — घरेलू लोहा हटाने वाला फ़िल्टर, या हैंडपंप पर लगने वाली '
                      'यूनिट। पहले जाँच करा लें कि लोहा ही है।'
                  : 'Yellow or red water and stains on clothes and vessels '
                      'are usually iron. It is more of a nuisance than a '
                      'danger, and it is treatable - a household iron removal '
                      'filter, or a unit fitted at the handpump. Get it '
                      'tested first to confirm it is iron.',
              WaterWorry.teeth => hi
                  ? 'दाँतों पर पीले-भूरे धब्बे और जोड़ों का दर्द फ़्लोराइड की ज़्यादती '
                      'के जाने-पहचाने लक्षण हैं, और यह पानी से ही आता है। फ़्लोराइड न '
                      'दिखता है, न स्वाद में आता है, और उबालने से नहीं जाता। जाँच '
                      'तुरंत कराएँ — बच्चों के दाँत बनने की उम्र में यह सबसे ज़्यादा असर '
                      'करता है, और एक बार हो गया नुक़सान वापस नहीं होता।'
                  : 'Yellow or brown mottling on teeth and joint pain are the '
                      'known signs of too much fluoride, and it comes from '
                      'the water. Fluoride neither shows nor tastes, and '
                      'boiling does not remove it. Get this tested now - it '
                      'does the most damage while children\'s teeth are '
                      'forming, and that damage does not reverse.',
              WaterWorry.area => hi
                  ? 'कुछ इलाक़ों में भूजल में आर्सेनिक, फ़्लोराइड, लोहा, नाइट्रेट या '
                      'खारापन पहले से जाना-पहचाना है। ज़िला प्रयोगशाला को बताएँ कि '
                      'आपके ब्लॉक में क्या पाया जाता रहा है, और उसी की जाँच कराएँ। '
                      'आर्सेनिक ख़ासकर ख़तरनाक है और बिल्कुल नहीं दिखता।'
                  : 'In some areas the groundwater is known to carry '
                      'arsenic, fluoride, iron, nitrate or salinity. Tell the '
                      'district lab what has been found in your block and ask '
                      'for that panel. Arsenic in particular is dangerous and '
                      'completely invisible.',
              WaterWorry.nothing => hi
                  ? 'साल में दो बार जाँच कराना अच्छी आदत है — एक बार बारिश से पहले '
                      'और एक बार बारिश के बाद, क्योंकि बारिश में सतह का गंदा पानी '
                      'स्रोत में मिल जाता है।'
                  : 'Twice a year is a good habit - once before the rains and '
                      'once after, because the rains wash surface dirt into '
                      'the source.',
            },
            tone: _worry == WaterWorry.teeth || _worry == WaterWorry.illness
                ? ToolTone.warn
                : ToolTone.plain,
            icon: Icons.biotech_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'नमूना कैसे भेजें' : 'How to send the sample',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'ज़िला जल जाँच प्रयोगशाला का पता ग्राम पंचायत, ब्लॉक कार्यालय या '
                        'जल विभाग से मिलता है। कई राज्य ejalshakti पोर्टल पर नमूना '
                        'दर्ज करने की सुविधा भी देते हैं।',
                    'साफ़ बोतल लें — प्लास्टिक की नई बोतल ठीक है। जीवाणु जाँच के लिए '
                        'प्रयोगशाला की दी हुई बोतल ही लें।',
                    'नल को दो मिनट चलने दें, फिर बोतल भरें, ऊपर थोड़ी जगह छोड़कर।',
                    'बोतल पर नाम, गाँव, स्रोत (हैंडपंप/नल/कुआँ) और तारीख़ लिखें।',
                    'जीवाणु जाँच का नमूना उसी दिन पहुँचाना होता है, और हो सके तो ठंडा '
                        'रखकर। रासायनिक जाँच में इतनी जल्दी नहीं।',
                    'रसीद लें। नतीजे की नक़ल माँगना आपका हक़ है।',
                  ]
                : const [
                    'The district water testing laboratory\'s address comes '
                        'from the gram panchayat, block office or the water '
                        'department. Many states also let you register a '
                        'sample on the ejalshakti portal.',
                    'Use a clean bottle - a new plastic one is fine. For the '
                        'bacteria test, use the bottle the lab gives you.',
                    'Run the tap two minutes, then fill the bottle, leaving a '
                        'little air at the top.',
                    'Write your name, village, the source (handpump, tap, '
                        'well) and the date on the bottle.',
                    'A bacteria sample has to reach the lab the same day, '
                        'kept cool if you can. A chemical sample is not so '
                        'urgent.',
                    'Take the receipt. Asking for a copy of the result is '
                        'your right.',
                  ],
          ),
          ToolNote(hi
              ? 'नतीजे में हर चीज़ की एक सीमा लिखी होती है और आपका नंबर उसके आगे। '
                  'नंबर सीमा से ऊपर हो तो वही दिक़्क़त है। समझ न आए तो प्रयोगशाला के '
                  'कर्मचारी से पूछें — बताना उनका काम है, और नतीजे के साथ क्या करना है '
                  'यह भी वही बताते हैं।'
              : 'A result sheet gives a limit for each item and your number '
                  'beside it. A number above the limit is the problem. If it '
                  'does not make sense, ask the lab staff - explaining it is '
                  'their job, and so is telling you what to do about it.'),
          const SourceNote(
              text: 'Water quality management information system, Jal Shakti',
              url: _jjmWqUrl),
          const SourceNote(text: 'Central Pollution Control Board',
              url: _cpcbUrl),
        ],
      ],
    );
  }
}

// --- Flood water ------------------------------------------------------

class FloodWaterPage extends StatelessWidget {
  const FloodWaterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;

    return ToolScaffold(
      goal: 6,
      title: hi ? 'बाढ़ में पानी सुरक्षित करना' : 'Making water safe in a flood',
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: scheme.error,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.flood_outlined, color: scheme.onError, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hi
                      ? 'बाढ़ के बाद हर स्रोत को गंदा मानकर चलें — हैंडपंप और कुआँ भी, '
                          'चाहे पानी साफ़ दिखे। सबसे ज़्यादा मौतें बाढ़ के पानी में डूबने '
                          'से नहीं, उसके बाद की बीमारी से होती हैं।'
                      : 'After a flood treat every source as contaminated - '
                          'handpumps and wells too, however clear the water '
                          'looks. More deaths come from the illness after a '
                          'flood than from the water itself.',
                  style: TextStyle(
                      fontSize: 14.5,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                      color: scheme.onError),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(hi ? 'पीने के पानी के लिए' : 'For drinking water',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'सबसे भरोसेमंद: उबालना। तेज़ उबाल आने के बाद एक मिनट और, फिर ढककर '
                      'ठंडा करें। ईंधन हो तो यही करें।',
                  'उबाल न सकें तो क्लोरीन की गोली — पैकेट पर लिखी मात्रा के हिसाब से, '
                      'और 30 मिनट रखकर। इसी लक्ष्य में "क्लोरीन कितना डालें" देखें।',
                  'पानी गंदला हो तो पहले कपड़े से छानें या कुछ घंटे बैठने दें। गंदले '
                      'पानी में क्लोरीन काम नहीं करता।',
                  'पैकेट बंद पानी मिले तो वह सबसे सुरक्षित है, जब तक सील टूटी न हो।',
                  'बर्फ़ न लें — वह किसी भी पानी से बनी हो सकती है।',
                ]
              : const [
                  'The most reliable thing is boiling. One minute after a '
                      'rolling boil, then cover and cool. If you have fuel, '
                      'do this.',
                  'If you cannot boil, a chlorine tablet - the quantity the '
                      'packet states, left 30 minutes. See "How much '
                      'chlorine" in this goal.',
                  'If the water is cloudy, strain it through cloth or let it '
                      'settle first. Chlorine does not work in cloudy water.',
                  'Sealed bottled water is the safest thing available, as '
                      'long as the seal is unbroken.',
                  'Avoid ice - it can be made from any water.',
                ],
        ),
        ToolDonts(
          heading: hi ? 'बाढ़ में यह न करें' : 'In a flood, do not',
          items: hi
              ? const [
                  'बाढ़ के पानी से बर्तन, सब्ज़ी, दाँत या हाथ न धोएँ',
                  'डूबे हुए हैंडपंप या कुएँ का पानी बिना साफ़ किए न पिएँ — पानी के उतरने '
                      'के बाद भी नहीं',
                  'जो खाना बाढ़ के पानी के संपर्क में आया हो, वह न खाएँ — पैकेट बंद भी '
                      'नहीं, अगर पैकेट भीगा हो',
                  'बाढ़ के पानी में बच्चों को खेलने न दें',
                  'कटे या छिले हाथ-पैर लेकर पानी में न उतरें; उतरना ही पड़े तो बाद में '
                      'साबुन से धोएँ और ढक लें',
                ]
              : const [
                  'Do not wash vessels, vegetables, teeth or hands in flood '
                      'water',
                  'Do not drink from a submerged handpump or well untreated - '
                      'not even after the water goes down',
                  'Do not eat food that has touched flood water - not even '
                      'packaged food, if the packet got wet',
                  'Do not let children play in flood water',
                  'Do not wade in with cuts or grazes; if you must, wash with '
                      'soap afterwards and cover them',
                ],
        ),
        const SizedBox(height: 14),
        Text(hi ? 'पानी उतरने के बाद' : 'After the water goes down',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const ToolChecklist(
          storageKey: 'flood_recovery_v1',
          items: [
            CheckItem('report', 'Tell the gram panchayat or the local body '
                'which sources went under',
                'ग्राम पंचायत या नगर निकाय को बताएँ कि कौन से स्रोत डूबे थे',
                noteEn: 'Submerged handpumps and wells are supposed to be '
                    'disinfected by the department. They cannot do it if '
                    'nobody says which ones.',
                noteHi: 'डूबे हुए हैंडपंप और कुएँ विभाग को कीटाणुरहित करने होते हैं। '
                    'कौन से डूबे, यह बताए बिना वे करेंगे कैसे।'),
            CheckItem('super', 'Ask for the well or handpump to be '
                'disinfected before it is used again',
                'दोबारा इस्तेमाल से पहले कुएँ या हैंडपंप को कीटाणुरहित कराएँ'),
            CheckItem('tank', 'Clean and disinfect the storage tank and '
                'every vessel that got wet',
                'टंकी और जो भी बर्तन भीगे, उन्हें साफ़ और कीटाणुरहित करें'),
            CheckItem('boil', 'Keep boiling or chlorinating until the '
                'department says the source has tested clean',
                'जब तक विभाग जाँच करके साफ़ न बताए, उबालना या क्लोरीन डालना जारी '
                    'रखें'),
            CheckItem('watch', 'Watch for loose motions, fever and skin '
                'infections for two weeks',
                'दो हफ़्ते तक दस्त, बुख़ार और चमड़ी के संक्रमण पर नज़र रखें',
                noteEn: 'Loose motions in a small child after a flood is a '
                    'reason to go the same day, not to wait.',
                noteHi: 'बाढ़ के बाद छोटे बच्चे को दस्त हों तो उसी दिन ले जाएँ, '
                    'इंतज़ार न करें।'),
          ],
        ),
        ToolNote(hi
            ? 'दस्त लग जाएँ तो ओआरएस तुरंत शुरू करें — लक्ष्य 3 में "दस्त: ओआरएस और '
                'कब ले जाएँ" में मात्रा दी हुई है। बाढ़ के बाद सबसे ज़्यादा जानें '
                'निर्जलीकरण से जाती हैं, और वह रोका जा सकता है।'
            : 'If loose motions start, begin ORS at once - the volumes are in '
                '"Diarrhoea: ORS and when to go" under goal 3. After a flood '
                'most of the deaths are from dehydration, and that is '
                'preventable.'),
        const SourceNote(text: 'Jal Jeevan Mission', url: _jjmUrl),
      ],
    );
  }
}
