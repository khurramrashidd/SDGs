import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Soil and crop: the fertiliser dose in bags, waiting days after a spray,
/// organic certification, and a farm pond sized to its catchment.
///
/// The fertiliser screen does no agronomy of its own. It takes the dose
/// from the soil health card or the Krishi Vigyan Kendra and turns it into
/// bags, which is the step where most of the over-use happens: the card
/// says kilos of nutrient, the shop sells bags of product.

const _shcUrl = 'https://soilhealth.dac.gov.in/';
const _jaivikUrl = 'https://jaivikkheti.in/';
const _nregaUrl = 'https://nrega.nic.in/';
const _pmksyUrl = 'https://pmksy.gov.in/';

/// Nutrient content and bag sizes of the common fertilisers.
const ureaN = 0.46;
const ureaBagKg = 45.0;
const dapN = 0.18;
const dapP = 0.46;
const sspP = 0.16;
const mopK = 0.60;
const bagKg = 50.0;
const hectareInAcres = 2.471;

const poisonHelpline = '1800 116 117';

// --- Fertiliser dose --------------------------------------------------

class FertiliserDosePage extends StatefulWidget {
  const FertiliserDosePage({super.key});

  @override
  State<FertiliserDosePage> createState() => _FertiliserDosePageState();
}

class _FertiliserDosePageState extends State<FertiliserDosePage> {
  final _n = TextEditingController();
  final _p = TextEditingController();
  final _k = TextEditingController();
  final _area = TextEditingController();
  bool _acres = true;
  bool _useSsp = false;

  @override
  void dispose() {
    for (final c in [_n, _p, _k, _area]) {
      c.dispose();
    }
    super.dispose();
  }

  double _v(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  String _bags(double kg, double size, bool hi) {
    final b = kg / size;
    final half = (b * 2).ceil() / 2;
    final shown = half == half.roundToDouble()
        ? half.round().toString()
        : half.toStringAsFixed(1);
    return hi
        ? '${kg.round()} किलो · लगभग $shown बोरी'
        : '${kg.round()} kg · about $shown bags';
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final ha = _acres ? _v(_area) / hectareInAcres : _v(_area);
    final nNeed = _v(_n) * ha;
    final pNeed = _v(_p) * ha;
    final kNeed = _v(_k) * ha;

    final pProduct = _useSsp ? pNeed / sspP : pNeed / dapP;
    final nFromP = _useSsp ? 0.0 : pProduct * dapN;
    final urea = nNeed > nFromP ? (nNeed - nFromP) / ureaN : 0.0;
    final mop = kNeed / mopK;
    final ready = ha > 0 && (nNeed + pNeed + kNeed) > 0;

    return ToolScaffold(
      goal: 15,
      title: hi ? 'मेरे खेत के लिए खाद की मात्रा' : 'Fertiliser dose for my field',
      children: [
        ToolNote(hi
            ? 'मृदा स्वास्थ्य कार्ड या कृषि विज्ञान केंद्र खाद की सलाह "किलो पोषक तत्व '
                'प्रति हेक्टेयर" में देता है — नाइट्रोजन (N), फ़ॉस्फ़ोरस (P), पोटाश (K)। '
                'दुकान बोरी बेचती है। यह स्क्रीन दोनों को जोड़ती है। ज़्यादातर किसानों '
                'को इससे पता चलता है कि वे आदत से ज़रूरत से ज़्यादा यूरिया डाल रहे थे।'
            : 'The soil health card or the Krishi Vigyan Kendra gives its advice '
                'in "kilos of nutrient per hectare" - nitrogen (N), phosphorus '
                '(P), potash (K). The shop sells bags. This screen joins the '
                'two. Most farmers find from it that habit had them putting on '
                'more urea than the field needs.'),
        ToolQuestion(hi ? 'कार्ड की सलाह (किलो प्रति हेक्टेयर)' : 'The card\'s advice (kg per hectare)'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _n,
                label: 'N',
                decimal: true,
                maxDigits: 4,
                icon: Icons.grass_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ToolNumber(
                controller: _p,
                label: 'P₂O₅',
                decimal: true,
                maxDigits: 4,
                icon: Icons.grass_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ToolNumber(
                controller: _k,
                label: 'K₂O',
                decimal: true,
                maxDigits: 4,
                icon: Icons.grass_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        ToolQuestion(hi ? 'खेत' : 'The field'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _area,
                label: _acres
                    ? (hi ? 'रक़बा (एकड़)' : 'Area (acres)')
                    : (hi ? 'रक़बा (हेक्टेयर)' : 'Area (hectares)'),
                decimal: true,
                maxDigits: 6,
                icon: Icons.landscape_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => setState(() => _acres = !_acres),
              child: Text(_acres
                  ? (hi ? 'हेक्टेयर में' : 'Use hectares')
                  : (hi ? 'एकड़ में' : 'Use acres')),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _useSsp,
          onChanged: (v) => setState(() => _useSsp = v),
          title: Text(hi
              ? 'फ़ॉस्फ़ोरस डीएपी की जगह सिंगल सुपर फ़ॉस्फ़ेट से'
              : 'Phosphorus from single super phosphate, not DAP'),
          subtitle: Text(hi
              ? 'एसएसपी में सल्फ़र भी होता है — तिलहन और दलहन के लिए अच्छा'
              : 'SSP also carries sulphur - good for oilseeds and pulses'),
        ),
        if (ready) ...[
          const SizedBox(height: 8),
          if (pProduct > 0)
            ToolLine(_useSsp ? (hi ? 'एसएसपी' : 'SSP') : (hi ? 'डीएपी' : 'DAP'),
                _bags(pProduct, bagKg, hi), strong: true),
          if (urea > 0)
            ToolLine(hi ? 'यूरिया' : 'Urea', _bags(urea, ureaBagKg, hi),
                strong: true),
          if (mop > 0)
            ToolLine(hi ? 'पोटाश (एमओपी)' : 'Potash (MOP)', _bags(mop, bagKg, hi),
                strong: true),
          const SizedBox(height: 8),
          ToolAnswer(
            headline: hi ? 'कैसे डालें' : 'How to apply it',
            detail: hi
                ? 'डीएपी/एसएसपी और पोटाश बुवाई के समय पूरा। यूरिया एक बार में नहीं — '
                    'एक-तिहाई बुवाई पर और बाक़ी दो बार में, फ़सल के बढ़ने के समय। एक '
                    'साथ डाला यूरिया बारिश या सिंचाई में बह जाता है और पैसा भी। '
                    '${!_useSsp && pProduct > 0 ? 'डीएपी में भी नाइट्रोजन होता है, इसलिए यूरिया उतना कम गिना गया है।' : ''}'
                : 'DAP/SSP and potash all at sowing. Urea not in one go - a third '
                    'at sowing and the rest in two splits as the crop grows. '
                    'Urea put on all at once washes away with rain or '
                    'irrigation, and the money with it. '
                    '${!_useSsp && pProduct > 0 ? 'DAP carries nitrogen too, so the urea has been reduced by that much.' : ''}',
            tone: ToolTone.good,
            icon: Icons.agriculture_outlined,
          ),
        ],
        const SizedBox(height: 10),
        ToolNote(hi
            ? 'मृदा स्वास्थ्य कार्ड न हो तो मिट्टी की जाँच मुफ़्त होती है — इसी लक्ष्य '
                'में "मिट्टी की सेहत" वाली स्क्रीन देखें।'
            : 'Without a soil health card, the soil test is free - see "Soil '
                'health" in this goal.'),
        const SourceNote(text: 'Soil Health Card', url: _shcUrl),
      ],
    );
  }
}

// --- Pesticide safety and waiting days --------------------------------

class PesticideSafetyPage extends StatefulWidget {
  const PesticideSafetyPage({super.key});

  @override
  State<PesticideSafetyPage> createState() => _PesticideSafetyPageState();
}

class _PesticideSafetyPageState extends State<PesticideSafetyPage> {
  DateTime? _sprayed;
  final _phi = TextEditingController();

  @override
  void dispose() {
    _phi.dispose();
    super.dispose();
  }

  String _d(DateTime t) => '${t.day}/${t.month}/${t.year}';

  Future<void> _pick() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _sprayed ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _sprayed = picked);
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final phi = int.tryParse(_phi.text.trim());
    final sprayed = _sprayed;
    final safe = sprayed != null && phi != null
        ? sprayed.add(Duration(days: phi))
        : null;
    final today = DateTime.now();
    final daysLeft = safe == null
        ? null
        : DateTime(safe.year, safe.month, safe.day)
            .difference(DateTime(today.year, today.month, today.day))
            .inDays;

    return ToolScaffold(
      goal: 15,
      title: hi ? 'कीटनाशक: सुरक्षा और कटाई तक के दिन' : 'Pesticide safety and waiting days',
      children: [
        ToolAnswer(
          headline: hi ? 'ज़हर लगने पर' : 'If someone is poisoned',
          detail: hi
              ? 'उसे दवा वाली जगह से हटाएँ, भीगे कपड़े उतारें, त्वचा साबुन-पानी से '
                  'धोएँ, और 108 पर फ़ोन करें। दवा का डिब्बा या लेबल अस्पताल साथ ले '
                  'जाएँ — डॉक्टर को उसी से पता चलता है कि कौन सा ज़हर है। सलाह के लिए '
                  'राष्ट्रीय विष सूचना केंद्र $poisonHelpline (मुफ़्त, चौबीसों घंटे)। '
                  'अपने से उल्टी न कराएँ।'
              : 'Move them away from the chemical, take off soaked clothes, wash '
                  'the skin with soap and water, and call 108. Take the container '
                  'or label to hospital - that is how the doctor knows which '
                  'poison it is. For advice, the National Poisons Information '
                  'Centre on $poisonHelpline (free, round the clock). Do not '
                  'make them vomit on your own.',
          tone: ToolTone.bad,
          icon: Icons.emergency_outlined,
        ),
        ToolQuestion(hi ? 'कटाई कब तक नहीं' : 'When not to harvest until'),
        ToolNote(hi
            ? 'हर कीटनाशक के लेबल पर "प्रतीक्षा अवधि" (कटाई-पूर्व अंतराल) लिखी होती '
                'है — छिड़काव के बाद कितने दिन तक फ़सल नहीं काटनी या बेचनी। यह दवा '
                'और फ़सल के हिसाब से अलग है, इसलिए लेबल से पढ़कर डालें।'
            : 'Every pesticide label states a "waiting period" (pre-harvest '
                'interval) - how many days after spraying the crop must not be '
                'harvested or sold. It differs by product and crop, so read it '
                'off the label.'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pick,
                icon: const Icon(Icons.event_outlined),
                label: Text(sprayed == null
                    ? (hi ? 'छिड़काव की तारीख़' : 'Spray date')
                    : _d(sprayed)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _phi,
                label: hi ? 'लेबल पर दिन' : 'Days on the label',
                maxDigits: 3,
                icon: Icons.timer_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        if (safe != null && daysLeft != null)
          ToolAnswer(
            headline: daysLeft > 0
                ? (hi
                    ? '${_d(safe)} से पहले कटाई नहीं — $daysLeft दिन बाक़ी'
                    : 'No harvest before ${_d(safe)} - $daysLeft days to go')
                : (hi
                    ? 'प्रतीक्षा अवधि पूरी — ${_d(safe)} से'
                    : 'Waiting period over - since ${_d(safe)}'),
            detail: hi
                ? 'सब्ज़ी और फल में यह सबसे ज़्यादा मायने रखता है, क्योंकि वे सीधे खाए '
                    'जाते हैं। जल्दी तोड़ी गई फ़सल में दवा बची रहती है।'
                : 'This matters most for vegetables and fruit, which are eaten '
                    'directly. A crop picked early still carries the chemical.',
            tone: daysLeft > 0 ? ToolTone.warn : ToolTone.good,
            icon: Icons.event_available_outlined,
          ),
        const SizedBox(height: 14),
        ToolDonts(
          heading: hi ? 'छिड़काव करते समय' : 'While spraying',
          items: hi
              ? const [
                  'दस्ताने, मास्क, पूरी बाँह के कपड़े और चश्मा — बिना इनके नहीं',
                  'हवा के उल्टे रुख़ नहीं, और तेज़ हवा या दोपहर की धूप में नहीं',
                  'छिड़काव के समय खाना, पानी, बीड़ी-तंबाकू नहीं',
                  'बच्चों और गर्भवती महिलाओं से छिड़काव न कराएँ',
                  'लेबल में न लिखा हो तो दो दवाएँ आपस में न मिलाएँ',
                  'काम के बाद नहाएँ और कपड़े अलग धोएँ',
                ]
              : const [
                  'Gloves, mask, full sleeves and goggles - never without them',
                  'Not against the wind, and not in strong wind or midday sun',
                  'No eating, drinking, bidi or tobacco while spraying',
                  'Do not let children or pregnant women spray',
                  'Do not mix two products unless the label says you can',
                  'Bathe after the work and wash the clothes separately',
                ],
        ),
        ToolDonts(
          heading: hi ? 'रखते और फेंकते समय' : 'Storing and disposing',
          items: hi
              ? const [
                  'ताले में, बच्चों और खाने से दूर — कभी पानी या तेल की बोतल में नहीं',
                  'ख़ाली डिब्बे में छेद करके दबा दें; कभी पानी, दूध या अनाज रखने में नहीं',
                  'बची दवा तालाब, नहर या कुएँ के पास न फेंकें',
                ]
              : const [
                  'Locked up, away from children and food - never in a water or '
                      'oil bottle',
                  'Pierce and bury empty containers; never reuse one for water, '
                      'milk or grain',
                  'Do not throw leftovers near a pond, canal or well',
                ],
        ),
      ],
    );
  }
}

// --- Organic certification --------------------------------------------

enum Market { local, export }

class OrganicPage extends StatefulWidget {
  const OrganicPage({super.key});

  @override
  State<OrganicPage> createState() => _OrganicPageState();
}

class _OrganicPageState extends State<OrganicPage> {
  Market? _market;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 15,
      title: hi ? 'जैविक खेती: प्रमाणन और सहायता' : 'Organic farming: certification and support',
      children: [
        ToolNote(hi
            ? 'देश में जैविक प्रमाणन के दो रास्ते हैं, और कौन सा चुनें यह इस पर निर्भर '
                'है कि फ़सल कहाँ बेचनी है। दोनों में खेत को रसायन छोड़ने के बाद दो से '
                'तीन साल का "बदलाव का समय" लगता है, फ़सल के हिसाब से।'
            : 'There are two routes to organic certification in India, and '
                'which one depends on where the crop will be sold. Both need a '
                'two to three year "conversion period" after the field stops '
                'chemicals, depending on the crop.'),
        ToolQuestion(hi ? 'फ़सल कहाँ बेचनी है' : 'Where will you sell'),
        SelectionTile(
          label: hi ? 'देश में — मंडी, दुकान, सीधे ग्राहक' : 'In India - mandi, shops, direct to customers',
          selected: _market == Market.local,
          onTap: () => setState(() => _market = Market.local),
        ),
        SelectionTile(
          label: hi ? 'विदेश में निर्यात' : 'Export abroad',
          selected: _market == Market.export,
          onTap: () => setState(() => _market = Market.export),
        ),
        if (_market == Market.local)
          ToolAnswer(
            headline: hi ? 'पीजीएस-इंडिया: समूह में, सस्ता' : 'PGS-India: in a group, inexpensive',
            detail: hi
                ? 'भागीदारी गारंटी प्रणाली (पीजीएस-इंडिया) में आसपास के कम से कम पाँच '
                    'किसान मिलकर एक समूह बनाते हैं और एक-दूसरे के खेत की जाँच करते हैं। '
                    'प्रमाणन सरकारी व्यवस्था से होता है, और बदलाव के सालों में फ़सल "पीजीएस '
                    'ग्रीन" के नाम से बिकती है। परंपरागत कृषि विकास योजना में ऐसे समूहों '
                    'को तीन साल तक प्रति हेक्टेयर सहायता मिलती है, जिसका एक हिस्सा सीधे '
                    'किसान के खाते में खाद-बीज के लिए आता है। राशि के लिए कृषि विभाग से '
                    'पूछें।'
                : 'Under the Participatory Guarantee System (PGS-India), at '
                    'least five nearby farmers form a group and inspect each '
                    'other\'s fields. Certification runs through a government '
                    'system, and during the conversion years the produce sells '
                    'as "PGS Green". Under Paramparagat Krishi Vikas Yojana such '
                    'groups get per-hectare support for three years, part of it '
                    'paid straight to the farmer for inputs. Ask the agriculture '
                    'department for the amount.',
            tone: ToolTone.good,
            icon: Icons.eco_outlined,
          ),
        if (_market == Market.export)
          ToolAnswer(
            headline: hi ? 'एनपीओपी: तीसरे पक्ष का प्रमाणन' : 'NPOP: third-party certification',
            detail: hi
                ? 'निर्यात के लिए राष्ट्रीय जैविक उत्पादन कार्यक्रम (एनपीओपी) के अंतर्गत '
                    'मान्यता प्राप्त प्रमाणन संस्था से जाँच और प्रमाण पत्र चाहिए। इसका '
                    'ख़र्च अकेले किसान के लिए ज़्यादा होता है, इसलिए आम तौर पर किसान '
                    'उत्पादक संगठन (एफ़पीओ) या "ग्रोअर ग्रुप" बनाकर कराया जाता है। '
                    'एपीडा मान्यता प्राप्त संस्थाओं की सूची रखता है।'
                : 'For export, inspection and a certificate are needed from an '
                    'accredited certification body under the National Programme '
                    'for Organic Production (NPOP). The cost is high for one '
                    'farmer, so it is usually done through a farmer producer '
                    'organisation or a "grower group". APEDA keeps the list of '
                    'accredited bodies.',
            tone: ToolTone.plain,
            icon: Icons.public_outlined,
          ),
        if (_market != null) ...[
          const SizedBox(height: 12),
          Text(hi ? 'शुरुआत' : 'Getting started',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'कृषि विभाग या कृषि विज्ञान केंद्र से अपने ब्लॉक के जैविक समूह के बारे '
                        'में पूछें — कई जगह समूह पहले से बने हैं।',
                    'खेत की डायरी रखें: क्या बोया, कौन सी खाद और दवा, कब। प्रमाणन में '
                        'यही रिकॉर्ड सबसे पहले देखा जाता है।',
                    'पड़ोसी खेत से रसायन न बहे, इसके लिए किनारे पर मेड़ या पेड़ों की '
                        'पट्टी।',
                    'बेचने के लिए जैविक खेती पोर्टल (jaivikkheti.in) पर पंजीकरण।',
                  ]
                : const [
                    'Ask the agriculture department or the Krishi Vigyan Kendra '
                        'about the organic group in your block - many places '
                        'already have one.',
                    'Keep a field diary: what was sown, which manure and '
                        'sprays, when. This record is the first thing '
                        'certification looks at.',
                    'A bund or a strip of trees at the edge, so chemicals do not '
                        'drift in from a neighbour\'s field.',
                    'To sell, register on the Jaivik Kheti portal '
                        '(jaivikkheti.in).',
                  ],
          ),
          const SourceNote(text: 'Jaivik Kheti portal', url: _jaivikUrl),
        ],
      ],
    );
  }
}

// --- Farm pond --------------------------------------------------------

class FarmPondPage extends StatefulWidget {
  const FarmPondPage({super.key});

  @override
  State<FarmPondPage> createState() => _FarmPondPageState();
}

class _FarmPondPageState extends State<FarmPondPage> {
  final _area = TextEditingController();
  final _rain = TextEditingController();
  final _depth = TextEditingController(text: '3');
  bool _acres = true;
  double _runoff = 0.2;

  @override
  void dispose() {
    _area.dispose();
    _rain.dispose();
    _depth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final area = double.tryParse(_area.text.trim()) ?? 0;
    final sqm = _acres ? area * 4046.8564 : area * 10000;
    final rain = double.tryParse(_rain.text.trim()) ?? 0;
    final depth = double.tryParse(_depth.text.trim()) ?? 0;
    final volume = sqm * rain / 1000 * _runoff;
    final surface = depth > 0 ? volume / depth : 0.0;
    final side = surface > 0 ? math.sqrt(surface) : 0.0;

    return ToolScaffold(
      goal: 15,
      title: hi ? 'खेत में वर्षा जल संचय' : 'Water harvesting on farmland',
      children: [
        ToolNote(hi
            ? 'खेत तालाब बारिश के बहते पानी को रोकता है, और सूखे के दिनों में एक-दो '
                '"जीवन-रक्षक" सिंचाई दे देता है। आकार इस पर निर्भर है कि उसमें कितनी '
                'ज़मीन का पानी आएगा और कितनी बारिश होती है।'
            : 'A farm pond holds back rain run-off and gives one or two '
                '"life-saving" irrigations in a dry spell. Its size depends on '
                'how much land drains into it and how much rain falls.'),
        ToolQuestion(hi ? 'कितनी ज़मीन का पानी तालाब में आएगा' : 'How much land drains into the pond'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _area,
                label: _acres
                    ? (hi ? 'जलग्रहण (एकड़)' : 'Catchment (acres)')
                    : (hi ? 'जलग्रहण (हेक्टेयर)' : 'Catchment (hectares)'),
                decimal: true,
                maxDigits: 6,
                icon: Icons.landscape_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => setState(() => _acres = !_acres),
              child: Text(_acres
                  ? (hi ? 'हेक्टेयर में' : 'Use hectares')
                  : (hi ? 'एकड़ में' : 'Use acres')),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ToolNumber(
          controller: _rain,
          label: hi ? 'मौसम की कुल बारिश (मिमी)' : 'Season\'s total rain (mm)',
          helper: hi
              ? 'अपने ज़िले का सामान्य — मौसम विभाग या कृषि विज्ञान केंद्र से'
              : 'Your district\'s normal - from IMD or the Krishi Vigyan Kendra',
          decimal: true,
          maxDigits: 5,
          icon: Icons.water_drop_outlined,
          onChanged: (_) => setState(() {}),
        ),
        ToolQuestion(hi ? 'ज़मीन कैसी है' : 'What the land is like'),
        SelectionTile(
          label: hi ? 'समतल, रेतीली — पानी ज़्यादा सोखती है' : 'Flat and sandy - soaks most of it up',
          selected: _runoff == 0.1,
          onTap: () => setState(() => _runoff = 0.1),
        ),
        SelectionTile(
          label: hi ? 'आम खेत' : 'Ordinary farmland',
          selected: _runoff == 0.2,
          onTap: () => setState(() => _runoff = 0.2),
        ),
        SelectionTile(
          label: hi ? 'ढलान वाली या कड़ी मिट्टी' : 'Sloping or hard soil',
          selected: _runoff == 0.3,
          onTap: () => setState(() => _runoff = 0.3),
        ),
        const SizedBox(height: 10),
        ToolNumber(
          controller: _depth,
          label: hi ? 'तालाब की गहराई (मीटर)' : 'Pond depth (m)',
          decimal: true,
          maxDigits: 3,
          icon: Icons.height,
          onChanged: (_) => setState(() {}),
        ),
        if (volume > 0) ...[
          ToolAnswer(
            headline: hi
                ? 'लगभग ${volume.round()} घन मीटर पानी'
                : 'About ${volume.round()} cubic metres of water',
            detail: hi
                ? 'यानी लगभग ${(volume * 1000 / 100000).toStringAsFixed(1)} लाख लीटर। '
                    '${depth.toStringAsFixed(1)} मीटर गहरे तालाब के लिए लगभग '
                    '${surface.round()} वर्ग मीटर — क़रीब ${side.round()} × ${side.round()} '
                    'मीटर। यह मोटा अनुमान है; पूरा पानी एक बार में नहीं आता और कुछ सूखता '
                    'है, इसलिए तालाब इससे थोड़ा छोटा भी काम कर जाता है।'
                : 'That is about ${(volume * 1000 / 100000).toStringAsFixed(1)} '
                    'lakh litres. For a pond ${depth.toStringAsFixed(1)} m deep, '
                    'about ${surface.round()} square metres - roughly '
                    '${side.round()} × ${side.round()} m. This is a rough '
                    'estimate; the water does not all arrive at once and some '
                    'evaporates, so a slightly smaller pond can still do the '
                    'job.',
            tone: ToolTone.good,
            icon: Icons.water_outlined,
          ),
        ],
        const SizedBox(height: 12),
        Text(hi ? 'कौन पैसा देता है' : 'Who pays for it',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'मनरेगा: अनुसूचित जाति/जनजाति, छोटे और सीमांत किसानों के खेत में तालाब '
                      'व्यक्तिगत काम के रूप में बन सकता है — ग्राम सभा में प्रस्ताव दें',
                  'प्रधानमंत्री कृषि सिंचाई योजना: वाटरशेड और खेत तालाब के काम, कृषि '
                      'विभाग से',
                  'कई राज्यों की अपनी खेत तालाब योजनाएँ हैं, लाइनिंग की सहायता के साथ',
                  'रेतीली मिट्टी में पानी रिस जाता है — वहाँ प्लास्टिक लाइनिंग के बारे में '
                      'पूछें',
                ]
              : const [
                  'MGNREGA: a pond on the land of SC/ST, small and marginal '
                      'farmers can be built as an individual work - propose it '
                      'in the gram sabha',
                  'PM Krishi Sinchayee Yojana: watershed and farm pond works, '
                      'through the agriculture department',
                  'Many states run their own farm pond schemes, with help for '
                      'lining',
                  'In sandy soil the water seeps away - ask about a plastic '
                      'lining there',
                ],
        ),
        const SourceNote(text: 'MGNREGA', url: _nregaUrl),
        const SourceNote(text: 'PM Krishi Sinchayee Yojana', url: _pmksyUrl),
      ],
    );
  }
}
