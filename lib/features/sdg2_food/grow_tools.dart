import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Four screens for the family that grows some of its own food, or sells
/// it.
///
/// Grain lost in storage is the quietest hunger there is: it has already
/// been grown, weeded, harvested and carried home, and then a quarter of
/// it goes to damp and weevils in a sack on a mud floor. Nothing about
/// fixing that needs money.
///
/// The selling screen deliberately carries no prices. A minimum support
/// price changes every season and a stale number in an app is worse than
/// none - a farmer who quotes last year's figure at a mandi loses the
/// argument and the trust. So it does the arithmetic and sends them to the
/// official figure.

const _agmarknetUrl = 'https://agmarknet.gov.in/';
const _mspUrl = 'https://dfpd.gov.in/';
const _enamUrl = 'https://www.enam.gov.in/';
const _kccUrl =
    'https://static.pib.gov.in/WriteReadData/specificdocs/documents/2026/mar/doc2026311819801.pdf';
const _kvkUrl = 'https://kvk.icar.gov.in/';

// --- Storing grain ----------------------------------------------------

/// What is being stored. Pulses are the ones that go first, and paddy held
/// too wet is the one that goes invisibly.
enum StoredGrain { wheat, paddy, pulses, oilseeds, maize }

/// Safe storage moisture, in per cent, and roughly how long it keeps when
/// stored dry, clean and airtight.
({String moisture, String keeps}) grainKeeping(StoredGrain g, bool hi) =>
    switch (g) {
      StoredGrain.wheat => (
          moisture: '10-12%',
          keeps: hi ? 'एक साल से ज़्यादा' : 'More than a year'
        ),
      StoredGrain.paddy => (
          moisture: '12-14%',
          keeps: hi ? 'एक साल तक' : 'Up to a year'
        ),
      StoredGrain.pulses => (
          moisture: '9-10%',
          keeps: hi ? '6 से 8 महीने — सबसे जल्दी कीड़ा लगता है' : '6 to 8 months - the first to get weevils'
        ),
      StoredGrain.oilseeds => (
          moisture: '7-8%',
          keeps: hi ? '4 से 6 महीने, फिर तेल ख़राब होने लगता है' : '4 to 6 months, after which the oil turns'
        ),
      StoredGrain.maize => (
          moisture: '10-12%',
          keeps: hi ? '8 से 10 महीने' : '8 to 10 months'
        ),
    };

class GrainStoragePage extends StatefulWidget {
  const GrainStoragePage({super.key});

  @override
  State<GrainStoragePage> createState() => _GrainStoragePageState();
}

class _GrainStoragePageState extends State<GrainStoragePage> {
  StoredGrain? _grain;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final keep = _grain == null ? null : grainKeeping(_grain!, hi);

    Widget pick(StoredGrain g, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _grain == g,
          onTap: () => setState(() => _grain = g),
        );

    return ToolScaffold(
      goal: 2,
      title: hi ? 'घर में अनाज रखना' : 'Storing grain at home',
      children: [
        ToolNote(hi
            ? 'जो अनाज घर आ चुका है, उसका एक हिस्सा हर साल नमी और घुन में चला जाता '
                'है। यह सबसे चुपचाप होने वाला नुक़सान है — मेहनत, पानी, खाद, कटाई सब '
                'हो चुकी होती है। इसे रोकने में पैसा नहीं लगता, तरीक़ा लगता है। और '
                'तरीक़े में सबसे बड़ी बात एक ही है: सुखाना।'
            : 'A share of the grain already in the house goes every year to '
                'damp and weevils. It is the quietest loss there is - the '
                'work, the water, the fertiliser and the harvest have all '
                'already happened. Stopping it costs no money, only method. '
                'And the method comes down mostly to one thing: drying.'),
        ToolQuestion(hi ? 'क्या रखना है' : 'What are you storing'),
        pick(StoredGrain.wheat, 'Wheat', 'गेहूँ'),
        pick(StoredGrain.paddy, 'Paddy or rice', 'धान या चावल'),
        pick(StoredGrain.pulses, 'Pulses - dal, gram, arhar', 'दाल — चना, अरहर'),
        pick(StoredGrain.oilseeds, 'Oilseeds - mustard, groundnut',
            'तिलहन — सरसों, मूँगफली'),
        pick(StoredGrain.maize, 'Maize', 'मक्का'),
        if (keep != null) ...[
          ToolAnswer(
            headline: hi
                ? 'नमी ${keep.moisture} से नीचे रखें'
                : 'Keep the moisture below ${keep.moisture}',
            detail: hi
                ? 'इतना सूखा होने पर यह ${keep.keeps} ठीक रहता है। नमी नापने की मशीन '
                    'न हो तो पुरानी परख: दाँत से दबाने पर दाना टूटे, दबे नहीं; मुट्ठी में '
                    'भरकर छोड़ने पर दाने चिपके नहीं; और उन्हें डालने से पहले दो-तीन दिन '
                    'तेज़ धूप में फैलाकर सुखा लें।'
                : 'That dry, it keeps ${keep.keeps}. With no moisture meter, '
                    'the old tests: a grain should snap between the teeth, '
                    'not squash; a fistful should fall apart rather than '
                    'cling; and spread it in strong sun for two or three days '
                    'before it goes in.',
            tone: ToolTone.good,
            icon: Icons.wb_sunny_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'भरने से पहले' : 'Before you fill the container',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const ToolChecklist(
            storageKey: 'grain_store_v1',
            items: [
              CheckItem('dry', 'Dry it in the sun until it snaps, not '
                  'squashes', 'धूप में इतना सुखाएँ कि दाना टूटे, दबे नहीं'),
              CheckItem('clean', 'Clean the bin or drum and dry it fully - '
                  'last year\'s eggs are in the corners',
                  'कोठी या ड्रम साफ़ करके पूरा सुखाएँ — पिछले साल के अंडे कोनों में '
                      'रह जाते हैं'),
              CheckItem('raise', 'Keep it off the floor - on a wooden pallet, '
                  'bricks or a platform',
                  'ज़मीन से ऊपर रखें — लकड़ी के पटरे, ईंटों या चबूतरे पर',
                  noteEn: 'A sack on a mud floor draws damp up into the grain '
                      'all season.',
                  noteHi: 'कच्चे फ़र्श पर रखी बोरी पूरे मौसम नीचे से नमी खींचती रहती '
                      'है।'),
              CheckItem('wall', 'Leave a gap from the wall too, not just the '
                  'floor', 'दीवार से भी थोड़ा हटाकर रखें, सिर्फ़ ज़मीन से नहीं'),
              CheckItem('airtight', 'Close it airtight - weevils need air; a '
                  'sealed drum kills them off',
                  'हवाबंद करें — घुन को हवा चाहिए; बंद ड्रम में वह ख़त्म हो जाता है'),
              CheckItem('neem', 'Dried neem leaves layered through it, for '
                  'grain you will eat',
                  'सूखी नीम की पत्तियाँ बीच-बीच में डालें, खाने वाले अनाज के लिए'),
              CheckItem('check', 'Open and check once a month - a small '
                  'problem caught early stays small',
                  'महीने में एक बार खोलकर देखें — शुरू में पकड़ी गड़बड़ छोटी रह जाती है'),
            ],
          ),
          ToolDonts(
            heading: hi ? 'यह न करें' : 'Do not do these',
            items: hi
                ? const [
                    'गीला या अधपका सूखा अनाज न भरें। यही एक ग़लती बाक़ी सब मेहनत '
                        'बेकार कर देती है — अंदर गर्मी और फ़ंगस पैदा होती है, और ऊपर से '
                        'कुछ पता नहीं चलता।',
                    'खाने वाले अनाज में कोई भी कीटनाशक गोली या पाउडर अपने मन से न '
                        'मिलाएँ। बीज के लिए रखे अनाज और खाने के अनाज का तरीक़ा अलग '
                        'होता है — कृषि विज्ञान केंद्र (KVK) से पूछकर ही कुछ डालें।',
                    'नई फ़सल पुरानी के ऊपर न डालें। पहले कोठी ख़ाली और साफ़ करें।',
                    'बोरियाँ सीधे दीवार से सटाकर या छत के टपकने वाले हिस्से के नीचे न '
                        'रखें।',
                  ]
                : const [
                    'Do not store it damp or half-dried. That one mistake '
                        'undoes all the rest - heat and fungus build inside, '
                        'and nothing shows from the outside.',
                    'Do not mix any insecticide tablet or powder into grain '
                        'you will eat, on your own judgement. Grain kept for '
                        'seed and grain kept for eating are handled '
                        'differently - ask the Krishi Vigyan Kendra before '
                        'putting anything in.',
                    'Do not pour a new harvest on top of an old one. Empty '
                        'and clean the bin first.',
                    'Do not stand the sacks against a wall or under the part '
                        'of the roof that leaks.',
                  ],
          ),
          const SourceNote(
              text: 'Your nearest Krishi Vigyan Kendra, for what suits your '
                  'district',
              url: _kvkUrl),
        ],
      ],
    );
  }
}

// --- Kitchen garden ---------------------------------------------------

/// Where the household is, roughly. India's sowing calendar differs more
/// by this than by anything else, and a single national list would be
/// wrong for most people reading it.
enum GardenZone { plains, hills, southCoastal }

/// Vegetables worth sowing in [month] (1-12) in [zone]. Deliberately short
/// lists: five things a family will actually plant beat twenty they will
/// read past.
List<String> sowThisMonth(GardenZone zone, int month, bool hi) {
  // The plains calendar: a hot summer, a monsoon, and a cool rabi season.
  const plainsEn = {
    1: ['Spinach', 'Radish', 'Coriander', 'Onion seedlings', 'Chilli (nursery)'],
    2: ['Okra', 'Bottle gourd', 'Cucumber', 'Pumpkin', 'Amaranth'],
    3: ['Okra', 'Ridge gourd', 'Bitter gourd', 'Cowpea', 'Amaranth'],
    4: ['Bottle gourd', 'Cucumber', 'Cowpea', 'Amaranth', 'Cluster bean'],
    5: ['Cowpea', 'Cluster bean', 'Okra', 'Brinjal (nursery)', 'Chilli (nursery)'],
    6: ['Brinjal', 'Chilli', 'Okra', 'Cowpea', 'Sponge gourd'],
    7: ['Cauliflower (nursery)', 'Brinjal', 'Chilli', 'Beans', 'Radish'],
    8: ['Cauliflower', 'Cabbage', 'Tomato (nursery)', 'Carrot', 'Radish'],
    9: ['Tomato', 'Cabbage', 'Cauliflower', 'Peas', 'Spinach'],
    10: ['Peas', 'Spinach', 'Fenugreek', 'Carrot', 'Coriander'],
    11: ['Spinach', 'Fenugreek', 'Coriander', 'Radish', 'Onion'],
    12: ['Spinach', 'Coriander', 'Radish', 'Onion', 'Garlic'],
  };
  const plainsHi = {
    1: ['पालक', 'मूली', 'धनिया', 'प्याज़ की पौध', 'मिर्च (नर्सरी)'],
    2: ['भिंडी', 'लौकी', 'खीरा', 'कद्दू', 'चौलाई'],
    3: ['भिंडी', 'तोरई', 'करेला', 'लोबिया', 'चौलाई'],
    4: ['लौकी', 'खीरा', 'लोबिया', 'चौलाई', 'ग्वार'],
    5: ['लोबिया', 'ग्वार', 'भिंडी', 'बैंगन (नर्सरी)', 'मिर्च (नर्सरी)'],
    6: ['बैंगन', 'मिर्च', 'भिंडी', 'लोबिया', 'नेनुआ'],
    7: ['फूलगोभी (नर्सरी)', 'बैंगन', 'मिर्च', 'सेम', 'मूली'],
    8: ['फूलगोभी', 'पत्तागोभी', 'टमाटर (नर्सरी)', 'गाजर', 'मूली'],
    9: ['टमाटर', 'पत्तागोभी', 'फूलगोभी', 'मटर', 'पालक'],
    10: ['मटर', 'पालक', 'मेथी', 'गाजर', 'धनिया'],
    11: ['पालक', 'मेथी', 'धनिया', 'मूली', 'प्याज़'],
    12: ['पालक', 'धनिया', 'मूली', 'प्याज़', 'लहसुन'],
  };
  const hillsEn = {
    1: ['Onion (nursery)', 'Spinach', 'Radish'],
    2: ['Peas', 'Spinach', 'Coriander', 'Radish'],
    3: ['Potato', 'Peas', 'Cabbage', 'Carrot', 'Beans'],
    4: ['Beans', 'Cabbage', 'Cauliflower', 'Tomato', 'Capsicum'],
    5: ['Beans', 'Cucumber', 'Tomato', 'Capsicum', 'Amaranth'],
    6: ['Beans', 'Cucumber', 'Radish', 'Spinach', 'Maize'],
    7: ['Radish', 'Spinach', 'Turnip', 'Coriander'],
    8: ['Radish', 'Turnip', 'Spinach', 'Lettuce'],
    9: ['Garlic', 'Spinach', 'Coriander', 'Onion'],
    10: ['Garlic', 'Onion', 'Spinach'],
    11: ['Spinach', 'Coriander'],
    12: ['Spinach', 'Coriander'],
  };
  const hillsHi = {
    1: ['प्याज़ (नर्सरी)', 'पालक', 'मूली'],
    2: ['मटर', 'पालक', 'धनिया', 'मूली'],
    3: ['आलू', 'मटर', 'पत्तागोभी', 'गाजर', 'सेम'],
    4: ['सेम', 'पत्तागोभी', 'फूलगोभी', 'टमाटर', 'शिमला मिर्च'],
    5: ['सेम', 'खीरा', 'टमाटर', 'शिमला मिर्च', 'चौलाई'],
    6: ['सेम', 'खीरा', 'मूली', 'पालक', 'मक्का'],
    7: ['मूली', 'पालक', 'शलजम', 'धनिया'],
    8: ['मूली', 'शलजम', 'पालक', 'सलाद पत्ता'],
    9: ['लहसुन', 'पालक', 'धनिया', 'प्याज़'],
    10: ['लहसुन', 'प्याज़', 'पालक'],
    11: ['पालक', 'धनिया'],
    12: ['पालक', 'धनिया'],
  };
  const southEn = {
    1: ['Okra', 'Brinjal', 'Chilli', 'Amaranth', 'Cluster bean'],
    2: ['Okra', 'Bitter gourd', 'Ridge gourd', 'Amaranth', 'Cowpea'],
    3: ['Amaranth', 'Cowpea', 'Cluster bean', 'Snake gourd'],
    4: ['Amaranth', 'Cowpea', 'Okra', 'Chilli (nursery)'],
    5: ['Brinjal', 'Chilli', 'Okra', 'Cucumber', 'Pumpkin'],
    6: ['Brinjal', 'Chilli', 'Beans', 'Spinach', 'Pumpkin'],
    7: ['Beans', 'Spinach', 'Radish', 'Coriander', 'Tomato'],
    8: ['Tomato', 'Beans', 'Radish', 'Coriander', 'Onion'],
    9: ['Tomato', 'Onion', 'Beans', 'Spinach', 'Carrot'],
    10: ['Onion', 'Carrot', 'Radish', 'Spinach', 'Coriander'],
    11: ['Okra', 'Brinjal', 'Spinach', 'Coriander', 'Cowpea'],
    12: ['Okra', 'Brinjal', 'Chilli', 'Amaranth', 'Cucumber'],
  };
  const southHi = {
    1: ['भिंडी', 'बैंगन', 'मिर्च', 'चौलाई', 'ग्वार'],
    2: ['भिंडी', 'करेला', 'तोरई', 'चौलाई', 'लोबिया'],
    3: ['चौलाई', 'लोबिया', 'ग्वार', 'चिचिंडा'],
    4: ['चौलाई', 'लोबिया', 'भिंडी', 'मिर्च (नर्सरी)'],
    5: ['बैंगन', 'मिर्च', 'भिंडी', 'खीरा', 'कद्दू'],
    6: ['बैंगन', 'मिर्च', 'सेम', 'पालक', 'कद्दू'],
    7: ['सेम', 'पालक', 'मूली', 'धनिया', 'टमाटर'],
    8: ['टमाटर', 'सेम', 'मूली', 'धनिया', 'प्याज़'],
    9: ['टमाटर', 'प्याज़', 'सेम', 'पालक', 'गाजर'],
    10: ['प्याज़', 'गाजर', 'मूली', 'पालक', 'धनिया'],
    11: ['भिंडी', 'बैंगन', 'पालक', 'धनिया', 'लोबिया'],
    12: ['भिंडी', 'बैंगन', 'मिर्च', 'चौलाई', 'खीरा'],
  };

  final table = switch (zone) {
    GardenZone.plains => hi ? plainsHi : plainsEn,
    GardenZone.hills => hi ? hillsHi : hillsEn,
    GardenZone.southCoastal => hi ? southHi : southEn,
  };
  return table[month] ?? const [];
}

class KitchenGardenPage extends StatefulWidget {
  const KitchenGardenPage({super.key});

  @override
  State<KitchenGardenPage> createState() => _KitchenGardenPageState();
}

class _KitchenGardenPageState extends State<KitchenGardenPage> {
  GardenZone _zone = GardenZone.plains;
  late int _month = DateTime.now().month;

  static const _monthsEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const _monthsHi = [
    'जनवरी', 'फ़रवरी', 'मार्च', 'अप्रैल', 'मई', 'जून',
    'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर',
  ];

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final list = sowThisMonth(_zone, _month, hi);
    final monthName = (hi ? _monthsHi : _monthsEn)[_month - 1];

    return ToolScaffold(
      goal: 2,
      title: hi ? 'घर की बाड़ी: इस महीने क्या बोएँ' : 'Kitchen garden: what to sow now',
      children: [
        ToolNote(hi
            ? 'दरवाज़े के बाहर की दस फ़ुट ज़मीन या छत पर रखे कुछ डिब्बे भी साल भर '
                'सब्ज़ी दे सकते हैं, और वह सब्ज़ी ख़रीदी हुई से सस्ती और ताज़ा होती है। '
                'बोने का महीना ग़लत हो तो मेहनत बेकार जाती है, इसलिए यह सूची महीने और '
                'इलाक़े के हिसाब से है।'
            : 'Ten feet of ground outside the door, or a few tins on a roof, '
                'can give vegetables all year, cheaper and fresher than '
                'bought ones. Sowing in the wrong month wastes the work, so '
                'this list goes by the month and by where you are.'),
        ToolQuestion(hi ? 'आपका इलाक़ा' : 'Where you are'),
        SelectionTile(
          label: hi ? 'मैदानी इलाक़ा' : 'The plains',
          subtitle: hi
              ? 'उत्तर और मध्य भारत, गर्म गर्मी और ठंडी सर्दी'
              : 'North and central India, hot summer and cold winter',
          selected: _zone == GardenZone.plains,
          onTap: () => setState(() => _zone = GardenZone.plains),
        ),
        SelectionTile(
          label: hi ? 'पहाड़ी इलाक़ा' : 'The hills',
          subtitle: hi
              ? 'जहाँ सर्दी में पाला पड़ता है'
              : 'Where there is frost in winter',
          selected: _zone == GardenZone.hills,
          onTap: () => setState(() => _zone = GardenZone.hills),
        ),
        SelectionTile(
          label: hi ? 'दक्षिण या तटीय' : 'Southern or coastal',
          subtitle: hi
              ? 'जहाँ साल भर गर्मी रहती है'
              : 'Warm through the year',
          selected: _zone == GardenZone.southCoastal,
          onTap: () => setState(() => _zone = GardenZone.southCoastal),
        ),
        ToolQuestion(hi ? 'महीना' : 'Month'),
        DropdownButtonFormField<int>(
          initialValue: _month,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: hi ? 'महीना' : 'Month',
            isDense: true,
          ),
          items: [
            for (var m = 1; m <= 12; m++)
              DropdownMenuItem(
                value: m,
                child: Text((hi ? _monthsHi : _monthsEn)[m - 1]),
              ),
          ],
          onChanged: (v) => setState(() => _month = v ?? _month),
        ),
        if (list.isNotEmpty) ...[
          ToolAnswer(
            headline: hi
                ? '$monthName में यह बोएँ'
                : 'Sow these in $monthName',
            detail: hi
                ? 'इनमें से दो-तीन से शुरू करें, सब एकसाथ नहीं। पत्तेदार सब्ज़ी सबसे '
                    'जल्दी हाथ आती है — पालक और धनिया एक महीने में खाने लायक़ हो जाते '
                    'हैं।'
                : 'Start with two or three of these, not all of them. Leafy '
                    'greens come fastest - spinach and coriander are worth '
                    'eating inside a month.',
            tone: ToolTone.good,
            icon: Icons.local_florist_outlined,
          ),
          const SizedBox(height: 8),
          ToolSteps(numbered: false, steps: list),
          const SizedBox(height: 14),
          Text(hi ? 'थोड़ी जगह में ज़्यादा' : 'More from a small patch',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'रसोई का पानी (जिसमें साबुन न हो) और सब्ज़ी के छिलके बाड़ी में '
                        'डालते रहें — खाद का ख़र्च यहीं बच जाता है।',
                    'लौकी, तोरई और सेम को ऊपर चढ़ाएँ — छत, दीवार या बाँस के सहारे। '
                        'ज़मीन वही रहती है, उपज दोगुनी हो जाती है।',
                    'हर क़तार के किनारे गेंदा लगाएँ। इससे कई कीड़े दूर रहते हैं और कुछ '
                        'नहीं लगाना पड़ता।',
                    'एक ही जगह बार-बार वही सब्ज़ी न लगाएँ; अगली बार दूसरी क़तार में '
                        'लगाएँ।',
                    'बीज एक बार ख़रीदकर हर बार के लिए बचाएँ — पालक, धनिया, मेथी, '
                        'भिंडी और लौकी के बीज घर पर आसानी से बन जाते हैं।',
                  ]
                : const [
                    'Keep pouring kitchen water (without soap in it) and '
                        'vegetable peel into the patch - that is the '
                        'fertiliser bill gone.',
                    'Send bottle gourd, ridge gourd and beans upwards - over '
                        'a roof, a wall or a bamboo frame. Same ground, twice '
                        'the crop.',
                    'Plant marigold along the edge of each row. It keeps '
                        'several pests off and costs nothing else.',
                    'Do not plant the same vegetable in the same spot each '
                        'time; move it to another row.',
                    'Buy seed once and save it after that - spinach, '
                        'coriander, fenugreek, okra and bottle gourd all give '
                        'seed easily at home.',
                  ],
          ),
          ToolNote(hi
              ? 'यह सूची आम कैलेंडर है। आपके ज़िले के लिए ठीक-ठीक तारीख़ें कृषि विज्ञान '
                  'केंद्र बताता है, और वहाँ सलाह मुफ़्त मिलती है।'
              : 'This is the general calendar. For the exact dates for your '
                  'district the Krishi Vigyan Kendra is the place, and their '
                  'advice is free.'),
          const SourceNote(
              text: 'Krishi Vigyan Kendra, ICAR', url: _kvkUrl),
        ],
      ],
    );
  }
}

// --- Selling a crop ---------------------------------------------------

/// Where the farmer is thinking of selling. The honest point of this
/// screen is that MSP only bites where there is actual procurement.
enum SellRoute { mandi, procurementCentre, villageTrader, enam }

class SellCropPage extends StatefulWidget {
  const SellCropPage({super.key});

  @override
  State<SellCropPage> createState() => _SellCropPageState();
}

class _SellCropPageState extends State<SellCropPage> {
  final _quintals = TextEditingController();
  final _rate = TextEditingController();
  SellRoute? _route;

  @override
  void dispose() {
    _quintals.dispose();
    _rate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final q = double.tryParse(_quintals.text.trim());
    final r = double.tryParse(_rate.text.trim());
    final total = (q != null && r != null && q > 0 && r > 0) ? q * r : null;

    Widget pick(SellRoute s, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _route == s,
          onTap: () => setState(() => _route = s),
        );

    return ToolScaffold(
      goal: 2,
      title: hi ? 'फ़सल बेचना: एमएसपी और मंडी' : 'Selling a crop: MSP and the mandi',
      children: [
        ToolNote(hi
            ? 'इस स्क्रीन पर कोई भाव नहीं लिखा है, और जानबूझकर नहीं लिखा है। एमएसपी '
                'हर सीज़न बदलता है, और ऐप में रखा पुराना भाव सबसे बुरी चीज़ है — मंडी में '
                'पिछले साल का भाव बोलने वाला किसान बहस भी हार जाता है और भरोसा भी। '
                'यहाँ हिसाब है, और सरकारी भाव का सीधा रास्ता।'
            : 'There is no price on this screen, and that is deliberate. MSP '
                'changes every season, and a stale price in an app is the '
                'worst thing of all - a farmer quoting last year\'s figure at '
                'a mandi loses both the argument and the credibility. What is '
                'here is the arithmetic, and the direct route to the official '
                'figure.'),
        ToolQuestion(hi ? 'हिसाब लगाएँ' : 'Work out the total'),
        ToolNumber(
          controller: _quintals,
          label: hi ? 'कितने क्विंटल' : 'How many quintals',
          decimal: true,
          maxDigits: 6,
          icon: Icons.scale_outlined,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolNumber(
          controller: _rate,
          label: hi ? 'भाव, प्रति क्विंटल' : 'Rate per quintal',
          decimal: true,
          maxDigits: 7,
          icon: Icons.currency_rupee,
          onChanged: (_) => setState(() {}),
        ),
        if (total != null) ...[
          ToolAnswer(
            headline: '₹${total.round()}',
            detail: hi
                ? 'यह कुल भाव है, कटौती से पहले। मंडी में तुलाई, हम्माली, छनाई, बोरी और '
                    'आढ़त — इनमें से कुछ कटते हैं। पर्ची पर हर कटौती अलग-अलग लिखवाएँ; '
                    'एक जोड़ में "ख़र्चा" लिखा होना ही वह जगह है जहाँ से पैसा जाता है।'
                : 'That is the gross, before deductions. At a mandi, weighing, '
                    'loading, cleaning, sacks and commission come off some of '
                    'it. Get each deduction written separately on the slip - a '
                    'single line saying "expenses" is exactly where money '
                    'goes missing.',
            tone: ToolTone.plain,
            icon: Icons.calculate_outlined,
          ),
        ],
        ToolQuestion(hi ? 'कहाँ बेचने की सोच रहे हैं' : 'Where are you thinking of selling'),
        pick(SellRoute.procurementCentre,
            'A government procurement centre', 'सरकारी ख़रीद केंद्र'),
        pick(SellRoute.mandi, 'The mandi', 'मंडी'),
        pick(SellRoute.villageTrader, 'A trader who comes to the village',
            'गाँव आने वाला व्यापारी'),
        pick(SellRoute.enam, 'Online, through eNAM', 'ऑनलाइन, eNAM से'),
        if (_route != null) ...[
          ToolAnswer(
            headline: switch (_route!) {
              SellRoute.procurementCentre =>
                hi ? 'एमएसपी यहीं मिलता है' : 'This is where MSP actually applies',
              SellRoute.mandi =>
                hi ? 'भाव बोली से तय होता है' : 'The price here comes from bidding',
              SellRoute.villageTrader =>
                hi ? 'सबसे आसान, और आमतौर पर सबसे सस्ता' : 'The easiest, and usually the cheapest',
              SellRoute.enam =>
                hi ? 'ज़्यादा ख़रीदार, एक ही जगह' : 'More buyers, from one place',
            },
            detail: switch (_route!) {
              SellRoute.procurementCentre => hi
                  ? 'न्यूनतम समर्थन मूल्य वहीं असर करता है जहाँ सरकार ख़ुद ख़रीदती है। '
                      'पंजीकरण पहले कराना होता है — ज़मीन का रिकॉर्ड, आधार, बैंक खाता '
                      'और फ़सल का रकबा। ख़रीद की तारीख़ें और केंद्र राज्य तय करता है, और '
                      'पंजीकरण की खिड़की छूट जाना सबसे आम नुक़सान है।'
                  : 'The minimum support price bites where the government '
                      'itself buys. Registration comes first - land record, '
                      'Aadhaar, bank account and the area sown. The state '
                      'fixes the dates and the centres, and missing the '
                      'registration window is the commonest loss of all.',
              SellRoute.mandi => hi
                  ? 'मंडी में भाव खुली बोली से बनता है और एमएसपी से कम भी हो सकता है। '
                      'जाने से पहले आज का भाव Agmarknet पर देख लें — यह सरकारी है और '
                      'रोज़ अपडेट होता है। तुलाई अपने सामने कराएँ और पर्ची लेकर ही '
                      'निकलें।'
                  : 'At a mandi the price is made by open bidding and can be '
                      'below MSP. Check today\'s rate on Agmarknet before you '
                      'go - it is the government\'s own and updated daily. '
                      'Watch the weighing yourself, and do not leave without '
                      'the slip.',
              SellRoute.villageTrader => hi
                  ? 'गाड़ी का ख़र्च और दिन भर की मेहनत बचती है, और उसी की क़ीमत भाव में '
                      'कटती है। एक काम ज़रूर करें: बेचने से पहले Agmarknet पर आज का '
                      'मंडी भाव देख लें। जिस किसान को आज का भाव मालूम होता है, उसे '
                      'व्यापारी भी ज़्यादा देता है।'
                  : 'It saves the cartage and a day of your own labour, and '
                      'the price is docked by exactly that. Do one thing '
                      'first: look up today\'s mandi rate on Agmarknet before '
                      'selling. A farmer who knows today\'s rate is offered '
                      'more by the same trader.',
              SellRoute.enam => hi
                  ? 'eNAM पर देश भर के ख़रीदार बोली लगा सकते हैं, इसलिए कई बार भाव '
                      'बेहतर मिलता है। इसके लिए मंडी में पंजीकरण और गुणवत्ता जाँच होती '
                      'है, और भुगतान सीधे खाते में आता है। अपनी मंडी eNAM से जुड़ी है या '
                      'नहीं, यह पहले देख लें।'
                  : 'On eNAM buyers from across the country can bid, so the '
                      'price is sometimes better. It needs registration at '
                      'the mandi and a quality check, and payment comes '
                      'straight to the bank account. Check first whether your '
                      'mandi is on eNAM at all.',
            },
            tone: _route == SellRoute.villageTrader
                ? ToolTone.warn
                : ToolTone.plain,
            icon: Icons.storefront_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'बेचने से पहले' : 'Before you sell',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const ToolChecklist(
            storageKey: 'sell_crop_v1',
            items: [
              CheckItem('msp', 'Look up this season\'s MSP for your crop, '
                  'and today\'s mandi rate',
                  'इस सीज़न का एमएसपी और आज का मंडी भाव देख लें'),
              CheckItem('register', 'If selling at a procurement centre, '
                  'register inside the window',
                  'ख़रीद केंद्र पर बेचना है तो खिड़की के भीतर पंजीकरण कराएँ'),
              CheckItem('dry', 'Dry and clean the grain - moisture and dirt '
                  'are what the deductions are taken on',
                  'अनाज सुखाकर साफ़ करें — कटौती नमी और मिट्टी पर ही लगती है'),
              CheckItem('weigh', 'Watch the weighing, and get the weight '
                  'written down', 'तुलाई अपने सामने कराएँ और वज़न लिखवाएँ'),
              CheckItem('slip', 'Take the slip with every deduction listed '
                  'separately', 'पर्ची लें जिसमें हर कटौती अलग लिखी हो'),
              CheckItem('bank', 'Payment into your own account, with the date '
                  'promised in writing',
                  'भुगतान अपने ही खाते में, और तारीख़ लिखित में'),
            ],
          ),
          const SourceNote(
              text: 'Agmarknet - daily mandi prices', url: _agmarknetUrl),
          const SourceNote(
              text: 'Department of Food and Public Distribution - MSP and '
                  'procurement',
              url: _mspUrl),
          const SourceNote(text: 'eNAM', url: _enamUrl),
        ],
      ],
    );
  }
}

// --- Kisan Credit Card ------------------------------------------------

/// KCC terms, as published. The interest numbers are the reason this
/// screen exists: a farmer paying a moneylender five rupees a hundred a
/// month is paying sixty per cent a year, against four.
const kccCollateralFreeRupees = 200000;
const kccMaxSubventionRupees = 500000;
const kccBaseInterestPercent = 7;
const kccPromptInterestPercent = 4;
const kccValidityYears = 5;

/// Who is asking. All four are eligible, and the last two do not know it.
enum KccWho { owner, tenant, sharecropper, allied }

class KccPage extends StatefulWidget {
  const KccPage({super.key});

  @override
  State<KccPage> createState() => _KccPageState();
}

class _KccPageState extends State<KccPage> {
  KccWho? _who;
  final _loan = TextEditingController();

  @override
  void dispose() {
    _loan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final loan = double.tryParse(_loan.text.trim());
    final yearlyAtFour =
        loan == null ? null : loan * kccPromptInterestPercent / 100;
    final yearlyAtMoneylender = loan == null ? null : loan * 0.60;

    Widget pick(KccWho w, String en, String h, String sub, String subHi) =>
        SelectionTile(
          label: hi ? h : en,
          subtitle: hi ? subHi : sub,
          selected: _who == w,
          onTap: () => setState(() => _who = w),
        );

    return ToolScaffold(
      goal: 2,
      title: hi ? 'किसान क्रेडिट कार्ड' : 'Kisan Credit Card',
      children: [
        ToolNote(hi
            ? 'यह स्क्रीन एक ही बात के लिए है: ब्याज का फ़र्क़। साहूकार से "सौ रुपये पर '
                'पाँच रुपये महीना" लेने वाला किसान साल का 60% ब्याज देता है। किसान '
                'क्रेडिट कार्ड पर, समय से चुकाने पर, वह 4% है।'
            : 'This screen exists for one fact: the difference in interest. A '
                'farmer borrowing from a moneylender at "five rupees a '
                'hundred a month" is paying 60% a year. On a Kisan Credit '
                'Card, repaid on time, it is 4%.'),
        ToolQuestion(hi ? 'आप कौन हैं' : 'Which of these are you'),
        pick(KccWho.owner, 'I farm land in my own name',
            'अपने नाम की ज़मीन पर खेती करता हूँ', '', ''),
        pick(KccWho.tenant, 'I farm rented land', 'किराये/बटाई की ज़मीन पर खेती',
            'Tenant farmers and oral lessees are eligible',
            'किरायेदार और मौखिक पट्टेदार भी पात्र हैं'),
        pick(KccWho.sharecropper, 'I am a sharecropper', 'मैं बटाईदार हूँ',
            'Sharecroppers are eligible, including through a group',
            'बटाईदार पात्र हैं, समूह के ज़रिये भी'),
        pick(KccWho.allied, 'Dairy, poultry, fisheries or beekeeping',
            'पशुपालन, मुर्गीपालन, मछली या मधुमक्खी',
            'Allied activities are covered too', 'ये काम भी इसमें आते हैं'),
        if (_who != null) ...[
          ToolAnswer(
            headline: hi ? 'हाँ, आप पात्र हैं' : 'Yes, you are eligible',
            detail: _who == KccWho.tenant || _who == KccWho.sharecropper
                ? (hi
                    ? 'यह वह बात है जो सबसे ज़्यादा लोग नहीं जानते: ज़मीन अपने नाम न '
                        'होने पर भी किसान क्रेडिट कार्ड बनता है। किरायेदार, मौखिक '
                        'पट्टेदार और बटाईदार — तीनों पात्र हैं, और अकेले न बने तो संयुक्त '
                        'देयता समूह (JLG) या स्वयं सहायता समूह के ज़रिये बनता है। बैंक '
                        'मना करे तो यही बात कहें और लिखित कारण माँगें।'
                    : 'This is the part most people do not know: a Kisan '
                        'Credit Card is made even when the land is not in '
                        'your name. Tenant farmers, oral lessees and '
                        'sharecroppers are all eligible, and where it will '
                        'not happen individually it happens through a Joint '
                        'Liability Group or a self-help group. If the bank '
                        'refuses, say exactly this and ask for the reason in '
                        'writing.')
                : (hi
                    ? 'कार्ड पाँच साल के लिए बनता है और घूमती सीमा (रिवॉल्विंग) की तरह '
                        'चलता है — हर साल नई अर्ज़ी नहीं देनी पड़ती। खेती के साथ पशुपालन, '
                        'मछली और मधुमक्खी जैसे काम भी इसमें आते हैं।'
                    : 'The card is made for five years and works as a '
                        'revolving limit - no fresh application every year. '
                        'Alongside crops it also covers dairy, fisheries and '
                        'beekeeping.'),
            tone: ToolTone.good,
            icon: Icons.credit_card_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'शर्तें, आज की' : 'The terms, as they stand',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ToolLine(
              hi ? 'बिना गारंटी, बिना ज़मीन गिरवी' : 'With no collateral at all',
              hi ? '₹2,00,000 तक' : 'Up to ₹2,00,000',
              strong: true),
          ToolLine(hi ? 'ब्याज में छूट वाली सीमा' : 'Limit under the subvention scheme',
              hi ? '₹5,00,000 तक' : 'Up to ₹5,00,000'),
          ToolLine(hi ? 'ब्याज दर' : 'Interest rate',
              '$kccBaseInterestPercent%'),
          ToolLine(
              hi
                  ? 'समय से चुकाने पर असली दर'
                  : 'Effective rate if repaid on time',
              '$kccPromptInterestPercent%',
              strong: true),
          ToolLine(hi ? 'कार्ड की अवधि' : 'Validity of the card',
              hi ? '$kccValidityYears साल' : '$kccValidityYears years'),
          const SizedBox(height: 8),
          ToolNote(hi
              ? 'बिना गारंटी की सीमा 1 जनवरी 2025 से ₹1.6 लाख से बढ़ाकर ₹2 लाख की गई, '
                  'और ब्याज छूट की सीमा 2025-26 में ₹3 लाख से ₹5 लाख। 4% की दर तभी '
                  'मिलती है जब समय पर चुकाया जाए — देर होने पर पूरा 7% और उससे ऊपर '
                  'लगता है। यही एक शर्त है जिस पर पूरा फ़ायदा टिका है।'
              : 'The collateral-free limit went from ₹1.6 lakh to ₹2 lakh on '
                  '1 January 2025, and the subvention limit from ₹3 lakh to '
                  '₹5 lakh in 2025-26. The 4% rate applies only if you repay '
                  'on time - late, it is the full 7% and more. That one '
                  'condition is what the whole benefit rests on.'),
          ToolQuestion(hi ? 'कितना लेने की सोच रहे हैं' : 'How much are you thinking of borrowing'),
          ToolNumber(
            controller: _loan,
            label: hi ? 'रुपये' : 'Rupees',
            maxDigits: 7,
            icon: Icons.currency_rupee,
            onChanged: (_) => setState(() {}),
          ),
          if (yearlyAtFour != null && yearlyAtMoneylender != null)
            ToolAnswer(
              headline: hi
                  ? 'साल का ब्याज: ₹${yearlyAtFour.round()}'
                  : 'Interest for the year: ₹${yearlyAtFour.round()}',
              detail: hi
                  ? 'समय से चुकाने पर, 4% की दर से। वही रक़म साहूकार से "सौ पर पाँच '
                      'रुपये महीना" पर ली जाए तो साल का ब्याज लगभग '
                      '₹${yearlyAtMoneylender.round()} बनता है — यानी '
                      '${(yearlyAtMoneylender - yearlyAtFour).round()} रुपये का फ़र्क़।'
                  : 'Repaid on time, at 4%. The same amount from a '
                      'moneylender at "five rupees a hundred a month" works '
                      'out to about ₹${yearlyAtMoneylender.round()} of '
                      'interest in a year - a difference of '
                      '₹${(yearlyAtMoneylender - yearlyAtFour).round()}.',
              tone: ToolTone.good,
              icon: Icons.trending_down,
            ),
          const SizedBox(height: 14),
          Text(hi ? 'बैंक में क्या ले जाएँ' : 'What to take to the bank',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const ToolChecklist(
            storageKey: 'kcc_papers_v1',
            introEn: 'There is no fee for the application. If one is asked '
                'for, that is the complaint.',
            introHi: 'अर्ज़ी की कोई फ़ीस नहीं है। माँगी जाए तो वही शिकायत है।',
            items: [
              CheckItem('id', 'Aadhaar, and a second photo ID',
                  'आधार, और एक और फ़ोटो पहचान पत्र'),
              CheckItem('land', 'Land records - khatauni, khasra or the '
                  'tenancy paper', 'ज़मीन के काग़ज़ — खतौनी, खसरा या बटाई का काग़ज़'),
              CheckItem('crop', 'What you grow and the area under it',
                  'क्या बोते हैं और कितने रकबे में'),
              CheckItem('bank', 'Passbook of the account it should go to',
                  'जिस खाते में चाहिए, उसकी पासबुक'),
              CheckItem('photo', 'Two passport photographs',
                  'दो पासपोर्ट फ़ोटो'),
              CheckItem('ask', 'Ask for the KCC by name, and for the '
                  'acknowledgement',
                  'किसान क्रेडिट कार्ड का नाम लेकर माँगें, और पावती लें',
                  noteEn: 'A bank cannot refuse without writing down why. If '
                      'it does, the complaint goes to the lead district '
                      'manager, and then the RBI ombudsman.',
                  noteHi: 'बैंक कारण लिखे बिना मना नहीं कर सकता। मना करे तो शिकायत '
                      'अग्रणी ज़िला प्रबंधक को, और उसके बाद आरबीआई लोकपाल को।'),
            ],
          ),
          const SourceNote(
              text: 'Kisan Credit Card terms, Press Information Bureau',
              url: _kccUrl),
        ],
      ],
    );
  }
}
