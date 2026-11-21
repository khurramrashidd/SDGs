import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// A household's water and power, against a yardstick, and the three cuts
/// that matter most for that household.
///
/// The water yardsticks are the two the government itself plans by: 55
/// litres a person a day for a rural tap under Jal Jeevan Mission, and 135
/// for a town with sewerage under the CPHEEO manual. Neither is a target to
/// hit - they are the level a supply is designed around, which makes them
/// a fair way to say "high" or "low".

const _jjmUrl = 'https://jaljeevanmission.gov.in/';
const _beeUrl = 'https://beeindia.gov.in/';

const ruralLpcd = 55;
const urbanLpcd = 135;
const bucketLitres = 15;

enum PowerUse { ac, cooler, geyser, oldFridge, oldLights, pump }

String _useLabel(PowerUse u, bool hi) => switch (u) {
      PowerUse.ac => hi ? 'एसी' : 'Air conditioner',
      PowerUse.cooler => hi ? 'कूलर' : 'Air cooler',
      PowerUse.geyser => hi ? 'गीज़र' : 'Water heater (geyser)',
      PowerUse.oldFridge => hi ? '10 साल से पुराना फ़्रिज' : 'A fridge over 10 years old',
      PowerUse.oldLights => hi ? 'ट्यूबलाइट या पीले बल्ब' : 'Tube lights or yellow bulbs',
      PowerUse.pump => hi ? 'पानी की मोटर' : 'Water pump',
    };

String _useCut(PowerUse u, bool hi) => switch (u) {
      PowerUse.ac => hi
          ? 'एसी 24 से 26°C पर चलाएँ, पंखे के साथ — हर डिग्री कम करने पर बिजली '
              'काफ़ी बढ़ती है। टाइमर लगाएँ और फ़िल्टर हर महीने साफ़ करें।'
          : 'Run the AC at 24 to 26°C with a fan on - every degree lower costs '
              'noticeably more. Use the timer and clean the filter monthly.',
      PowerUse.cooler => hi
          ? 'कूलर की घास या पैड हर मौसम बदलें और कमरे की एक खिड़की खुली रखें — '
              'बंद कमरे में कूलर सिर्फ़ नमी बढ़ाता है।'
          : 'Change the cooler pads every season and keep one window open - in '
              'a closed room a cooler only adds damp.',
      PowerUse.geyser => hi
          ? 'गीज़र नहाने से 15-20 मिनट पहले चालू करें और फिर बंद कर दें; थर्मोस्टैट '
              'मध्यम पर रखें। दिन भर चालू गीज़र सबसे छिपा हुआ ख़र्च है।'
          : 'Switch the geyser on 15 to 20 minutes before bathing and off '
              'after; keep the thermostat at medium. A geyser left on all day '
              'is the most hidden cost there is.',
      PowerUse.oldFridge => hi
          ? 'पुराना फ़्रिज नए 5-स्टार फ़्रिज से कई गुना बिजली खा सकता है। तब तक: '
              'दरवाज़े की रबर जाँचें, दीवार से कुछ इंच दूर रखें, और गरम खाना ठंडा '
              'करके रखें।'
          : 'An old fridge can use several times what a new 5-star one does. '
              'Meanwhile: check the door seal, keep it a few inches off the '
              'wall, and let hot food cool before it goes in.',
      PowerUse.oldLights => hi
          ? 'एलईडी बल्ब और ट्यूब पर बदलें — यह सबसे सस्ता और सबसे पक्का बचत वाला '
              'बदलाव है।'
          : 'Switch to LED bulbs and tubes - the cheapest, surest saving of '
              'all.',
      PowerUse.pump => hi
          ? 'टंकी भरकर बहने न दें — ओवरफ़्लो अलार्म या टाइमर सस्ता आता है, और '
              'पानी और बिजली दोनों बचाता है।'
          : 'Do not let the tank overflow - an overflow alarm or timer is cheap '
              'and saves water and power together.',
    };

class HomeFootprintPage extends StatefulWidget {
  const HomeFootprintPage({super.key});

  @override
  State<HomeFootprintPage> createState() => _HomeFootprintPageState();
}

class _HomeFootprintPageState extends State<HomeFootprintPage> {
  final _people = TextEditingController(text: '4');
  final _buckets = TextEditingController();
  final _units = TextEditingController();
  bool _town = false;
  final _uses = <PowerUse>{};

  @override
  void dispose() {
    _people.dispose();
    _buckets.dispose();
    _units.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final people = int.tryParse(_people.text.trim()) ?? 0;
    final buckets = double.tryParse(_buckets.text.trim()) ?? 0;
    final units = double.tryParse(_units.text.trim()) ?? 0;
    final lpcd = people > 0 ? buckets * bucketLitres / people : 0.0;
    final norm = _town ? urbanLpcd : ruralLpcd;
    // The three cuts, in the order that usually saves most.
    const order = [
      PowerUse.ac,
      PowerUse.geyser,
      PowerUse.oldFridge,
      PowerUse.cooler,
      PowerUse.pump,
      PowerUse.oldLights,
    ];
    final cuts = order.where(_uses.contains).take(3).toList();

    return ToolScaffold(
      goal: 12,
      title: hi ? 'मेरे घर का पानी और बिजली का असर' : 'My home\'s water and power footprint',
      children: [
        ToolQuestion(hi ? 'घर' : 'The household'),
        ToolNumber(
          controller: _people,
          label: hi ? 'घर में कितने लोग' : 'People in the house',
          maxDigits: 2,
          icon: Icons.people_outline,
          onChanged: (_) => setState(() {}),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _town,
          onChanged: (v) => setState(() => _town = v),
          title: Text(hi ? 'शहर में, सीवर लाइन वाला घर' : 'In a town, with a sewer line'),
        ),
        ToolQuestion(hi ? 'पानी' : 'Water'),
        ToolNumber(
          controller: _buckets,
          label: hi
              ? 'दिन भर में कितनी बाल्टी ($bucketLitres लीटर)'
              : 'Buckets a day, all uses ($bucketLitres litres)',
          helper: hi
              ? 'नहाना, शौचालय, कपड़े, बर्तन, खाना — सब मिलाकर'
              : 'Bathing, toilet, clothes, dishes, cooking - all together',
          decimal: true,
          maxDigits: 4,
          icon: Icons.water_drop_outlined,
          onChanged: (_) => setState(() {}),
        ),
        if (lpcd > 0) ...[
          ToolAnswer(
            headline: hi
                ? 'हर व्यक्ति रोज़ लगभग ${lpcd.round()} लीटर'
                : 'About ${lpcd.round()} litres a person a day',
            detail: lpcd > norm * 1.2
                ? (hi
                    ? 'सरकार ${_town ? 'शहर' : 'गाँव'} की जलापूर्ति $norm लीटर प्रति '
                        'व्यक्ति रोज़ के हिसाब से बनाती है। आपका इस्तेमाल उससे ज़्यादा है '
                        '— सबसे पहले रिसाव, फिर नहाने और शौचालय का पानी देखें।'
                    : 'Government plans a ${_town ? 'town' : 'village'} supply '
                        'around $norm litres a person a day. Yours is above '
                        'that - look first at leaks, then at bathing and toilet '
                        'water.')
                : (hi
                    ? 'सरकार ${_town ? 'शहर' : 'गाँव'} की जलापूर्ति $norm लीटर प्रति '
                        'व्यक्ति रोज़ के हिसाब से बनाती है। आपका इस्तेमाल उसके आसपास या '
                        'कम है।'
                    : 'Government plans a ${_town ? 'town' : 'village'} supply '
                        'around $norm litres a person a day. Yours is around '
                        'that or below.'),
            tone: lpcd > norm * 1.2 ? ToolTone.warn : ToolTone.good,
            icon: Icons.water_outlined,
          ),
          const SizedBox(height: 8),
          ToolSteps(
            steps: hi
                ? const [
                    'रिसाव पहले: टपकता नल या बहती टंकी दिन में कई बाल्टी बहा देती है। '
                        'लक्ष्य 6 में "टपकते नल का ख़र्च" से गिनें।',
                    'शॉवर की जगह बाल्टी — एक बाल्टी में अच्छा नहाना हो जाता है।',
                    'पुराने शौचालय की टंकी में पानी भरी एक बंद बोतल रख दें — हर बार '
                        'फ़्लश में उतना पानी बचता है।',
                  ]
                : const [
                    'Leaks first: a dripping tap or an overflowing tank loses '
                        'several buckets a day. Count it with "What a dripping '
                        'tap costs" in goal 6.',
                    'A bucket instead of a shower - one bucket is a good bath.',
                    'Put a closed bottle full of water in an old toilet '
                        'cistern - every flush saves that much.',
                  ],
          ),
        ],
        ToolQuestion(hi ? 'बिजली' : 'Power'),
        ToolNumber(
          controller: _units,
          label: hi ? 'महीने की यूनिट (बिल से)' : 'Units a month (from the bill)',
          decimal: true,
          maxDigits: 5,
          icon: Icons.bolt_outlined,
          onChanged: (_) => setState(() {}),
        ),
        if (units > 0 && people > 0)
          ToolLine(hi ? 'हर व्यक्ति पर महीने में' : 'Per person a month',
              hi ? '${(units / people).toStringAsFixed(0)} यूनिट' : '${(units / people).toStringAsFixed(0)} units',
              strong: true),
        const SizedBox(height: 8),
        Text(hi ? 'घर में इनमें से क्या है' : 'Which of these are in the house',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        for (final u in PowerUse.values)
          SelectionTile(
            label: _useLabel(u, hi),
            selected: _uses.contains(u),
            onTap: () => setState(() {
              if (!_uses.remove(u)) _uses.add(u);
            }),
          ),
        if (cuts.isNotEmpty) ...[
          const SizedBox(height: 8),
          ToolAnswer(
            headline: hi ? 'आपके घर की तीन सबसे काम की कटौती' : 'The three cuts worth making in your house',
            detail: [
              for (var i = 0; i < cuts.length; i++)
                '${i + 1}. ${_useCut(cuts[i], hi)}',
            ].join('\n\n'),
            tone: ToolTone.good,
            icon: Icons.savings_outlined,
          ),
          const SizedBox(height: 8),
          ToolNote(hi
              ? 'हर उपकरण कितनी बिजली खाता है, यह लक्ष्य 7 में "हर उपकरण का महीने '
                  'का ख़र्च" से गिना जा सकता है।'
              : 'How much each appliance uses can be worked out with "What each '
                  'appliance costs a month" in goal 7.'),
        ],
        const SourceNote(text: 'Jal Jeevan Mission', url: _jjmUrl),
        const SourceNote(text: 'Bureau of Energy Efficiency', url: _beeUrl),
      ],
    );
  }
}
