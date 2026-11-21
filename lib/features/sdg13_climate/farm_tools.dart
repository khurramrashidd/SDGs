import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/place/place_service.dart';
import '../../core/place/weather.dart';
import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// The crop and the animals against the weather: insurance, the week to
/// sow, drought, and livestock in heat or flood.
///
/// Last dates for crop insurance enrolment are notified by each state
/// every season, so none is stated. The premium shares are national and
/// have held since 2016, so they are.

const _pmfbyUrl = 'https://pmfby.gov.in/';
const _imdAgroUrl = 'https://mausam.imd.gov.in/';
const _dahdUrl = 'https://dahd.gov.in/';
const _nregaUrl = 'https://nrega.nic.in/';

/// PMFBY farmer's share of the premium, per cent of the sum insured.
const pmfbyKharifPercent = 2.0;
const pmfbyRabiPercent = 1.5;
const pmfbyCommercialPercent = 5.0;

/// PMFBY pays up to this share of the sum insured when sowing was
/// prevented by deficient rain or adverse weather.
const pmfbyPreventedSowingPercent = 25;

const cropHelpline = '14447';
const vetHelpline = '1962';
const hectareInAcres = 2.471;

// --- Crop insurance ---------------------------------------------------

enum Season { kharif, rabi, commercial }

class CropEnrolPage extends StatefulWidget {
  const CropEnrolPage({super.key});

  @override
  State<CropEnrolPage> createState() => _CropEnrolPageState();
}

class _CropEnrolPageState extends State<CropEnrolPage> {
  Season _season = Season.kharif;
  bool _acres = true;
  bool? _loanee;
  final _area = TextEditingController();
  final _scale = TextEditingController();

  @override
  void dispose() {
    _area.dispose();
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final area = double.tryParse(_area.text.trim()) ?? 0;
    final scale = double.tryParse(_scale.text.trim()) ?? 0;
    final hectares = _acres ? area / hectareInAcres : area;
    final insured = hectares * scale;
    final pct = switch (_season) {
      Season.kharif => pmfbyKharifPercent,
      Season.rabi => pmfbyRabiPercent,
      Season.commercial => pmfbyCommercialPercent,
    };
    final premium = insured * pct / 100;

    return ToolScaffold(
      goal: 13,
      title: hi ? 'फ़सल बीमा: क्या मेरा नाम है' : 'Crop insurance: am I enrolled',
      children: [
        ToolQuestion(hi ? 'क्या आपकी फ़सल पर बैंक का ऋण (केसीसी) है' : 'Is there a bank crop loan (KCC) on this crop'),
        SelectionTile(
          label: hi ? 'हाँ, केसीसी या फ़सल ऋण है' : 'Yes, a KCC or crop loan',
          selected: _loanee == true,
          onTap: () => setState(() => _loanee = true),
        ),
        SelectionTile(
          label: hi ? 'नहीं' : 'No',
          selected: _loanee == false,
          onTap: () => setState(() => _loanee = false),
        ),
        if (_loanee == true)
          ToolAnswer(
            headline: hi ? 'आम तौर पर बैंक ने ख़ुद जोड़ा होगा' : 'The bank has usually enrolled you',
            detail: hi
                ? 'ऋण वाले किसान को बैंक अपने आप प्रधानमंत्री फ़सल बीमा योजना में '
                    'जोड़ता है, जब तक किसान ने लिखित में मना न किया हो। लेकिन मान कर '
                    'न चलें — बैंक से पूछें कि इस मौसम का प्रीमियम कटा या नहीं, और '
                    'पॉलिसी या आवेदन संख्या लिखवा लें। वही संख्या दावे के समय चाहिए।'
                : 'A farmer with a crop loan is enrolled in PM Fasal Bima '
                    'Yojana by the bank automatically, unless they opted out '
                    'in writing. But do not assume - ask the bank whether this '
                    'season\'s premium was debited, and get the policy or '
                    'application number written down. That number is what a '
                    'claim needs.',
            tone: ToolTone.plain,
            icon: Icons.account_balance_outlined,
          ),
        if (_loanee == false)
          ToolAnswer(
            headline: hi ? 'आपको ख़ुद जुड़ना होगा' : 'You have to enrol yourself',
            detail: hi
                ? 'बिना ऋण वाले किसान बैंक, जन सेवा केंद्र, बीमा कंपनी के एजेंट, या '
                    'पोर्टल पर ख़ुद जुड़ सकते हैं। चाहिए: आधार, बैंक खाता, ज़मीन का '
                    'रिकॉर्ड, और बोई गई फ़सल का ब्योरा। बटाईदार और किरायेदार किसान भी '
                    'राज्य के नियम के अनुसार समझौते या प्रमाण पत्र से जुड़ सकते हैं। '
                    'हर मौसम की आख़िरी तारीख़ राज्य तय करता है — वह निकलने से पहले '
                    'जुड़ें।'
                : 'A farmer without a loan can enrol at a bank, a common '
                    'service centre, through the insurer\'s agent, or on the '
                    'portal. You need Aadhaar, a bank account, the land record '
                    'and details of the crop sown. Sharecroppers and tenant '
                    'farmers can also enrol with an agreement or certificate, '
                    'as the state allows. The last date each season is set by '
                    'the state - enrol before it passes.',
            tone: ToolTone.warn,
            icon: Icons.how_to_reg_outlined,
          ),
        if (_loanee != null) ...[
          const SizedBox(height: 10),
          Text(hi ? 'अपना नाम कैसे जाँचें' : 'How to check your own enrolment',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'pmfby.gov.in पर "आवेदन की स्थिति" में रसीद या आवेदन संख्या डालें।',
                    'संख्या न हो तो $cropHelpline (कृषि रक्षक हेल्पलाइन) पर आधार या '
                        'खाता संख्या से पूछें।',
                    'जाँचें कि फ़सल, रक़बा और गाँव सही लिखे हैं — ग़लत फ़सल लिखी होने पर '
                        'दावा अटक जाता है।',
                  ]
                : const [
                    'On pmfby.gov.in, enter the receipt or application number '
                        'under "Application Status".',
                    'Without the number, ask on $cropHelpline (the Krishi '
                        'Rakshak helpline) using Aadhaar or the account number.',
                    'Check that the crop, the area and the village are right - '
                        'a wrong crop on record holds up the claim.',
                  ],
          ),
        ],
        ToolQuestion(hi ? 'प्रीमियम कितना बनेगा' : 'What the premium comes to'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(hi ? 'ख़रीफ़' : 'Kharif'),
              selected: _season == Season.kharif,
              onSelected: (_) => setState(() => _season = Season.kharif),
            ),
            ChoiceChip(
              label: Text(hi ? 'रबी' : 'Rabi'),
              selected: _season == Season.rabi,
              onSelected: (_) => setState(() => _season = Season.rabi),
            ),
            ChoiceChip(
              label: Text(hi ? 'बाग़वानी/नक़दी' : 'Horticulture/commercial'),
              selected: _season == Season.commercial,
              onSelected: (_) => setState(() => _season = Season.commercial),
            ),
          ],
        ),
        const SizedBox(height: 10),
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
        const SizedBox(height: 10),
        ToolNumber(
          controller: _scale,
          label: hi
              ? 'प्रति हेक्टेयर बीमित राशि (₹)'
              : 'Sum insured per hectare (₹)',
          helper: hi
              ? 'ज़िले की "स्केल ऑफ़ फ़ाइनेंस" — बैंक, जन सेवा केंद्र या पोर्टल पर'
              : 'The district "scale of finance" - from the bank, CSC or portal',
          decimal: true,
          maxDigits: 7,
          icon: Icons.currency_rupee,
          onChanged: (_) => setState(() {}),
        ),
        if (premium > 0) ...[
          ToolAnswer(
            headline: hi
                ? 'आपका हिस्सा लगभग ₹${premium.round()}'
                : 'Your share is about ₹${premium.round()}',
            detail: hi
                ? 'बीमित राशि ₹${insured.round()} का ${pct.toStringAsFixed(1)}%। '
                    'बाक़ी प्रीमियम केंद्र और राज्य सरकार देती हैं।'
                : '${pct.toStringAsFixed(1)}% of a sum insured of '
                    '₹${insured.round()}. The rest of the premium is paid by '
                    'the central and state governments.',
            tone: ToolTone.good,
            icon: Icons.shield_outlined,
          ),
        ],
        const SourceNote(text: 'PM Fasal Bima Yojana', url: _pmfbyUrl),
      ],
    );
  }
}

// --- Sowing week ------------------------------------------------------

enum SoilState { dry, moist, soaked }

class SowingWeekPage extends StatefulWidget {
  const SowingWeekPage({super.key});

  @override
  State<SowingWeekPage> createState() => _SowingWeekPageState();
}

class _SowingWeekPageState extends State<SowingWeekPage> {
  SoilState? _soil;
  bool _irrigated = false;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final service = context.watch<PlaceService>();
    final days = service.forecast?.days.take(4).toList() ?? const <WeatherDay>[];
    final heavySoon = days.take(2).any(
        (d) => (rainBand(d.rainMm)?.index ?? 0) >= RainBand.heavy.index);
    final rainSoon = days.take(2).any((d) =>
        (d.rainMm != null && d.rainMm! >= 2.5) ||
        (d.rainMm == null && d.rainChance >= 60));
    final dryAhead = days.isNotEmpty &&
        days.every((d) =>
            (d.rainMm != null && d.rainMm! < 2.5) ||
            (d.rainMm == null && d.rainChance < 30));

    ({String head, String body, ToolTone tone})? verdict;
    if (_soil != null) {
      if (_soil == SoilState.soaked) {
        verdict = (
          head: hi ? 'पानी उतरने दें' : 'Let the water drain first',
          body: hi
              ? 'पानी भरे खेत में बोया बीज सड़ जाता है और अंकुर साँस नहीं ले पाता। '
                  'मिट्टी की ऊपरी परत में दरार या सूखापन दिखने तक रुकें — आम तौर पर '
                  'एक-दो धूप वाले दिन।'
              : 'Seed sown in a waterlogged field rots and the shoot cannot '
                  'breathe. Wait until the top layer shows a crack or begins '
                  'to dry - usually one or two sunny days.',
          tone: ToolTone.warn,
        );
      } else if (heavySoon) {
        verdict = (
          head: hi ? 'भारी बारिश से पहले न बोएँ' : 'Do not sow just before heavy rain',
          body: hi
              ? 'अगले दो दिन में भारी बारिश का अनुमान है। बोने के तुरंत बाद भारी '
                  'बारिश से बीज बह जाता है, दब जाता है, या ऊपर पपड़ी जम जाती है। '
                  'बारिश के बाद, पानी उतरने पर बोएँ।'
              : 'Heavy rain is forecast within two days. Heavy rain right '
                  'after sowing washes seed away, buries it, or forms a crust '
                  'over it. Sow after the rain, once the water has drained.',
          tone: ToolTone.warn,
        );
      } else if (_soil == SoilState.dry && !_irrigated) {
        verdict = (
          head: hi ? 'बारिश का इंतज़ार करें' : 'Wait for rain',
          body: hi
              ? 'सूखी मिट्टी में बोया बीज पहली हल्की बारिश में अंकुरित होकर फिर '
                  'सूखे में मर जाता है — और दोबारा बोना पड़ता है। बारानी फ़सल के लिए '
                  'आम सलाह है कि कुछ दिनों में कुल 50 से 75 मिमी बारिश हो जाए और '
                  'मिट्टी लगभग एक बित्ता गहराई तक नम हो, तब बोएँ।'
                  '${dryAhead ? ' अगले दिनों में बारिश नहीं दिख रही।' : ''}'
              : 'Seed in dry soil sprouts at the first light shower and then '
                  'dies in the dry spell - and has to be sown again. The usual '
                  'advice for a rainfed crop is to sow once 50 to 75 mm of '
                  'rain has fallen over a few days and the soil is moist to '
                  'about a hand\'s depth.'
                  '${dryAhead ? ' No rain shows in the coming days.' : ''}',
          tone: ToolTone.warn,
        );
      } else {
        verdict = (
          head: hi ? 'बोने के लिए ठीक समय लगता है' : 'This looks like a good time to sow',
          body: hi
              ? 'मिट्टी में नमी है और अगले दो दिन में भारी बारिश नहीं दिख रही। '
                  '${rainSoon ? 'हल्की बारिश आ सकती है — बीज के लिए अच्छी है, पर खाद या दवा का छिड़काव बारिश के बाद करें।' : ''}'
              : 'There is moisture in the soil and no heavy rain shows in the '
                  'next two days. '
                  '${rainSoon ? 'Light rain may come - good for the seed, but spread fertiliser or spray only after it.' : ''}',
          tone: ToolTone.good,
        );
      }
    }

    return ToolScaffold(
      goal: 13,
      title: hi ? 'क्या यह हफ़्ता बुवाई के लिए ठीक है' : 'Is this week right for sowing',
      children: [
        if (days.isEmpty) ...[
          ToolNote(hi
              ? 'अभी मौसम की जानकारी नहीं है, इसलिए यह स्क्रीन सिर्फ़ मिट्टी देखकर '
                  'बताएगी। जगह चुनें या इंटरनेट से जुड़ें तो अगले दिनों की बारिश भी '
                  'जुड़ जाएगी।'
              : 'No weather reading just now, so this screen will go by the '
                  'soil alone. Pick your place or connect to the internet to '
                  'add the coming days\' rain.'),
        ] else ...[
          for (var i = 0; i < days.length; i++)
            ToolLine(
              i == 0
                  ? (hi ? 'आज' : 'Today')
                  : i == 1
                      ? (hi ? 'कल' : 'Tomorrow')
                      : (hi ? '$i दिन बाद' : 'In $i days'),
              days[i].rainMm != null
                  ? '${days[i].rainMm!.toStringAsFixed(0)} mm · ${rainBandWord(rainBand(days[i].rainMm)!, hi)}'
                  : (hi
                      ? 'बारिश की संभावना ${days[i].rainChance}%'
                      : '${days[i].rainChance}% chance of rain'),
            ),
        ],
        ToolQuestion(hi ? 'मुट्ठी भर मिट्टी दबाकर देखें' : 'Squeeze a handful of soil'),
        SelectionTile(
          label: hi ? 'भुरभुरी, बिखर जाती है' : 'Crumbles and falls apart',
          subtitle: hi ? 'सूखी' : 'Dry',
          selected: _soil == SoilState.dry,
          onTap: () => setState(() => _soil = SoilState.dry),
        ),
        SelectionTile(
          label: hi ? 'गोला बनता है, हाथ गीला नहीं होता' : 'Holds a ball, hand stays dry',
          subtitle: hi ? 'सही नमी' : 'Right moisture',
          selected: _soil == SoilState.moist,
          onTap: () => setState(() => _soil = SoilState.moist),
        ),
        SelectionTile(
          label: hi ? 'पानी टपकता है या खेत में पानी भरा है' : 'Water drips out, or the field is standing in water',
          subtitle: hi ? 'बहुत गीली' : 'Waterlogged',
          selected: _soil == SoilState.soaked,
          onTap: () => setState(() => _soil = SoilState.soaked),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _irrigated,
          onChanged: (v) => setState(() => _irrigated = v),
          title: Text(hi ? 'सिंचाई का साधन है' : 'I can irrigate'),
        ),
        if (verdict != null)
          ToolAnswer(
            headline: verdict.head,
            detail: verdict.body,
            tone: verdict.tone,
            icon: Icons.grass_outlined,
          ),
        const SizedBox(height: 10),
        ToolNote(hi
            ? 'आपके ज़िले के लिए कृषि-मौसम सलाह हफ़्ते में दो बार निकलती है — '
                '"मेघदूत" ऐप पर, या कृषि विज्ञान केंद्र से। फ़सल और किस्म के हिसाब '
                'से बुवाई की तारीख़ वही सबसे सही बताते हैं।'
            : 'Agromet advice for your district is issued twice a week - on '
                'the "Meghdoot" app, or from the Krishi Vigyan Kendra. They '
                'give the best sowing window for your crop and variety.'),
        const SourceNote(
            text: 'India Meteorological Department - agromet', url: _imdAgroUrl),
      ],
    );
  }
}

// --- Drought ----------------------------------------------------------

class DroughtPage extends StatelessWidget {
  const DroughtPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 13,
      title: hi ? 'सूखा: राहत और पानी की बचत' : 'Drought: relief and water-saving',
      children: [
        ToolNote(hi
            ? 'सूखा राज्य सरकार घोषित करती है, बारिश, फ़सल और नमी के आँकड़ों से। '
                'घोषणा होने के बाद कुछ हक़ खुलते हैं — और कुछ हक़ घोषणा का इंतज़ार किए '
                'बिना भी हैं।'
            : 'Drought is declared by the state government, from rainfall, '
                'crop and moisture data. Some entitlements open once it is '
                'declared - and some apply without waiting for it.'),
        const SizedBox(height: 12),
        Text(hi ? 'जो माँगा जा सकता है' : 'What can be claimed',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'फ़सल बीमा: बारिश की कमी से बुवाई ही न हो सकी हो तो बीमित राशि का '
                      '$pmfbyPreventedSowingPercent% तक मिल सकता है। फ़सल खड़ी होकर '
                      'सूखी हो तो उपज के हिसाब से दावा बनता है',
                  'राज्य आपदा राहत: घोषित सूखे में 33% या उससे ज़्यादा फ़सल नुक़सान '
                      'पर "इनपुट सब्सिडी" मिलती है। सर्वे पटवारी या कृषि विभाग करता '
                      'है — सर्वे में नाम छूटे नहीं, इसका ध्यान रखें',
                  'मनरेगा: सूखा घोषित इलाक़ों में 100 के अलावा 50 दिन और काम मिल सकता '
                      'है, यानी 150 दिन तक',
                  'चारा: सूखे में ज़िले के चारा बैंक या पशुपालन विभाग से चारा मिल सकता '
                      'है',
                ]
              : const [
                  'Crop insurance: if sowing could not happen for lack of rain, '
                      'up to $pmfbyPreventedSowingPercent% of the sum insured '
                      'can be paid. If the crop grew and then dried, the claim '
                      'is worked out from the yield',
                  'State disaster relief: in a declared drought, a crop loss of '
                      '33% or more brings an "input subsidy". The patwari or '
                      'the agriculture department does the survey - make sure '
                      'your name is not left out',
                  'MGNREGA: in drought-declared areas, 50 more days of work '
                      'beyond the 100 can be given - up to 150',
                  'Fodder: in a drought, fodder may be available from the '
                      'district fodder bank or the animal husbandry department',
                ],
        ),
        const SizedBox(height: 14),
        Text(hi ? 'खड़ी फ़सल को बचाने के लिए' : 'To save a standing crop',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'पौधों की जड़ के पास पुआल, पत्तियों या फ़सल के अवशेष की परत (मल्च) '
                      'बिछाएँ — मिट्टी की नमी कम उड़ती है।',
                  'पानी कम हो तो पूरे खेत की बजाय सबसे नाज़ुक समय पर एक "जीवन-रक्षक" '
                      'सिंचाई दें — फूल आने और दाना भरने का समय।',
                  'बहुत घने पौधों को छाँटें; कम पौधे कम पानी में बच जाते हैं।',
                  'खरपतवार निकालें — वे उसी नमी पर पलते हैं।',
                  'बुवाई बहुत देर से हो रही हो तो कम समय वाली फ़सल — मूँग, उड़द, '
                      'बाजरा जैसी — के बारे में कृषि विज्ञान केंद्र से पूछें; हर ज़िले '
                      'की "आकस्मिक फ़सल योजना" बनी होती है।',
                  'ड्रिप और स्प्रिंकलर पर सब्सिडी के लिए कृषि विभाग से पूछें; खेत '
                      'तालाब बनाने में मनरेगा से भी मदद मिल सकती है।',
                ]
              : const [
                  'Lay a mulch of straw, leaves or crop residue around the '
                      'plants - less moisture escapes from the soil.',
                  'With little water, give one "life-saving" irrigation at the '
                      'most sensitive time rather than the whole field - '
                      'flowering and grain filling.',
                  'Thin out a very dense stand; fewer plants survive on less '
                      'water.',
                  'Pull the weeds - they live on the same moisture.',
                  'If sowing is very late, ask the Krishi Vigyan Kendra about '
                      'a short-duration crop - moong, urad, bajra and the like; '
                      'every district has a "contingency crop plan".',
                  'Ask the agriculture department about the subsidy on drip '
                      'and sprinklers; MGNREGA can also help dig a farm pond.',
                ],
        ),
        const SourceNote(text: 'PM Fasal Bima Yojana', url: _pmfbyUrl),
        const SourceNote(text: 'MGNREGA', url: _nregaUrl),
      ],
    );
  }
}

// --- Livestock in heat or flood ---------------------------------------

enum AnimalThreat { heat, flood }

class LivestockWeatherPage extends StatefulWidget {
  const LivestockWeatherPage({super.key});

  @override
  State<LivestockWeatherPage> createState() => _LivestockWeatherPageState();
}

class _LivestockWeatherPageState extends State<LivestockWeatherPage> {
  AnimalThreat? _threat;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final now = context.watch<PlaceService>().forecast?.now;
    final risk = now == null ? null : heatRisk(now.feelsLikeC);
    final hotToday = risk == HeatRisk.high || risk == HeatRisk.severe;

    return ToolScaffold(
      goal: 13,
      title: hi ? 'गर्मी या बाढ़ में पशु' : 'Livestock in heat or flood',
      children: [
        if (hotToday)
          ToolAnswer(
            headline: hi
                ? 'आज गर्मी ज़्यादा है — महसूस ${now!.feelsLikeC.round()}°C'
                : 'It is hot today - feels like ${now!.feelsLikeC.round()}°C',
            detail: hi
                ? 'दोपहर में पशुओं को छाया में रखें और पानी कभी ख़त्म न होने दें।'
                : 'Keep the animals in shade through the afternoon and never '
                    'let the water run out.',
            tone: ToolTone.warn,
            icon: Icons.thermostat_outlined,
          ),
        ToolQuestion(hi ? 'किस बात की चिंता है' : 'What is the worry'),
        SelectionTile(
          label: hi ? 'गर्मी और लू' : 'Heat and heat wave',
          selected: _threat == AnimalThreat.heat,
          onTap: () => setState(() => _threat = AnimalThreat.heat),
        ),
        SelectionTile(
          label: hi ? 'बाढ़ या भारी बारिश' : 'Flood or heavy rain',
          selected: _threat == AnimalThreat.flood,
          onTap: () => setState(() => _threat = AnimalThreat.flood),
        ),
        if (_threat == AnimalThreat.heat) ...[
          ToolSteps(
            numbered: false,
            steps: hi
                ? const [
                    'साफ़, ठंडा पानी हर समय भरा रहे — गर्मी में पशु कई गुना ज़्यादा '
                        'पानी पीते हैं',
                    'दोपहर में पेड़ की छाया या छप्पर के नीचे; टीन की छत के नीचे नहीं, '
                        'जब तक उस पर घास-फूस न बिछा हो',
                    'सबसे गर्म घंटों में शरीर पर पानी छिड़कें, या भैंस को पानी में '
                        'बैठने दें',
                    'चारा सुबह जल्दी और शाम को दें; दोपहर में चराई या काम नहीं',
                    'गर्मी में पशुओं को दूर तक न ले जाएँ, न ठसाठस गाड़ी में',
                  ]
                : const [
                    'Clean, cool water available at all times - animals drink '
                        'several times more in the heat',
                    'Shade of a tree or a thatched shed at midday; not under a '
                        'bare tin roof unless it is covered with straw',
                    'Sprinkle water on them in the hottest hours, or let '
                        'buffaloes wallow',
                    'Feed early morning and evening; no grazing or work at '
                        'midday',
                    'Do not walk animals far, or pack them into a vehicle, in '
                        'the heat',
                  ],
          ),
          ToolAnswer(
            headline: hi ? 'लू के लक्षण — पशु डॉक्टर बुलाएँ' : 'Signs of heat stress - call the vet',
            detail: hi
                ? 'मुँह खोलकर हाँफना, जीभ बाहर, लार टपकना, खाना छोड़ देना, दूध अचानक '
                    'घट जाना, या लड़खड़ाना। पशु को छाया में ले जाएँ, शरीर पर पानी '
                    'डालें, और $vetHelpline (चलती-फिरती पशु चिकित्सा सेवा) पर फ़ोन '
                    'करें।'
                : 'Open-mouthed panting, tongue out, drooling, going off feed, '
                    'a sudden drop in milk, or staggering. Move the animal to '
                    'shade, pour water over it, and call $vetHelpline (the '
                    'mobile veterinary service).',
            tone: ToolTone.bad,
            icon: Icons.pets_outlined,
          ),
        ],
        if (_threat == AnimalThreat.flood) ...[
          ToolSteps(
            steps: hi
                ? const [
                    'पानी चढ़ने से पहले पशुओं को ऊँची जगह ले जाएँ, और वहाँ भी खुला '
                        'रखें — बँधा पशु डूब जाता है।',
                    'सूखा चारा पहले से ऊँची जगह पर, पन्नी से ढककर रखें।',
                    'बाढ़ का गंदा पानी पीने न दें; साफ़ पानी अलग रखें।',
                    'बाढ़ के बाद गलघोंटू जैसी बीमारियाँ फैलती हैं — टीके के लिए '
                        'पशुपालन विभाग या $vetHelpline से पूछें, और कीड़े की दवा दें।',
                    'मरे पशु को पानी में न फेंकें; गहरा गड्ढा खोदकर चूने के साथ '
                        'दबाएँ, पानी के स्रोत से दूर।',
                  ]
                : const [
                    'Move the animals to high ground before the water rises, '
                        'and keep them untied there too - a tethered animal '
                        'drowns.',
                    'Store dry fodder up high in advance, covered with plastic.',
                    'Do not let them drink dirty flood water; keep clean water '
                        'separately.',
                    'Diseases such as haemorrhagic septicaemia spread after a '
                        'flood - ask the animal husbandry department or '
                        '$vetHelpline about vaccination, and deworm.',
                    'Do not throw a dead animal into water; bury it in a deep '
                        'pit with lime, away from any water source.',
                  ],
          ),
        ],
        if (_threat != null) ...[
          const SizedBox(height: 12),
          ToolAnswer(
            headline: hi ? 'पशु मरे तो मुआवज़ा' : 'Compensation if an animal dies',
            detail: hi
                ? 'आपदा में मरे पशु पर राज्य आपदा राहत कोष से मुआवज़ा मिलता है। '
                    'उसके लिए पशु डॉक्टर का प्रमाण पत्र या पोस्टमार्टम रिपोर्ट, और '
                    'राजस्व सर्वे में नाम ज़रूरी है — दबाने से पहले फ़ोटो लें, कान का '
                    'टैग भी दिखाते हुए। बीमित पशु हो तो बीमा कंपनी को उसकी तय समय सीमा '
                    'में बताएँ; टैग के बिना दावा आम तौर पर नहीं बनता।'
                : 'An animal lost in a disaster is compensated from the State '
                    'Disaster Response Fund. That needs a vet\'s certificate '
                    'or post-mortem report and an entry in the revenue survey - '
                    'photograph the animal before burial, showing its ear tag. '
                    'For an insured animal, inform the insurer within its time '
                    'limit; without the tag a claim usually fails.',
            tone: ToolTone.plain,
            icon: Icons.receipt_long_outlined,
          ),
          const SourceNote(
              text: 'Department of Animal Husbandry and Dairying', url: _dahdUrl),
        ],
      ],
    );
  }
}
