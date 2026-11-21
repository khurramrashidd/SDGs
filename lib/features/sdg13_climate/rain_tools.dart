import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/place/place_service.dart';
import '../../core/place/weather.dart';
import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Rain, storm, lightning and cyclone - and what to do once the damage is
/// done.
///
/// The forecast is the app's own reading for the chosen place. It is never
/// presented as an official warning: India's warnings come from the
/// Meteorological Department and the district, and every screen here says
/// so and points to them. What the reading adds is a nudge - heavy rain
/// tomorrow, strong gusts the day after - sized to what a household can
/// actually move or tie down.

const _imdUrl = 'https://mausam.imd.gov.in/';
const _ndmaUrl = 'https://ndma.gov.in/';

/// Gust speeds, km/h, at which loose roofing and branches become a danger.
const gustStrong = 60.0;
const gustNotable = 40.0;

String _day(DateTime d, bool hi, int index) {
  if (index == 0) return hi ? 'आज' : 'Today';
  if (index == 1) return hi ? 'कल' : 'Tomorrow';
  const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const h = ['सोम', 'मंगल', 'बुध', 'गुरु', 'शुक्र', 'शनि', 'रवि'];
  return hi ? h[d.weekday - 1] : en[d.weekday - 1];
}

/// The no-reading note every weather screen shows when the app has none.
Widget _noReading(bool hi) => ToolNote(hi
    ? 'अभी मौसम की जानकारी नहीं है। जगह चुनने या इंटरनेट से जुड़ने पर यहाँ अगले '
        'दिनों का हाल दिखेगा। तब तक नीचे की बातें लागू हैं।'
    : 'No weather reading just now. Pick your place or connect to the '
        'internet and the coming days show here. Until then, what follows '
        'applies.');

Widget _officialNote(bool hi) => ToolNote(hi
    ? 'यह ऐप का अपना अनुमान है, सरकारी चेतावनी नहीं। सरकारी चेतावनी मौसम विभाग, '
        'एनडीएमए के "सचेत" ऐप और ज़िला आपदा नियंत्रण कक्ष 1077 से आती है — वे '
        'अलग कहें तो वही मानें।'
    : 'This is the app\'s own reading, not an official warning. Official '
        'warnings come from the Meteorological Department, NDMA\'s "Sachet" '
        'app and the district disaster control room on 1077 - if they say '
        'otherwise, go by them.');

// --- Rain and storm risk ----------------------------------------------

class RainRiskPage extends StatelessWidget {
  const RainRiskPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final service = context.watch<PlaceService>();
    final forecast = service.forecast;
    final days = forecast?.days.take(3).toList() ?? const <WeatherDay>[];

    final heavy = days.any((d) {
      final b = rainBand(d.rainMm);
      return b == RainBand.heavy ||
          b == RainBand.veryHeavy ||
          b == RainBand.extreme;
    });
    final gusty = days.any((d) => (d.gustKph ?? 0) >= gustStrong);
    final storm = days.any((d) => codeIsStorm(d.code));

    return ToolScaffold(
      goal: 13,
      title: hi ? 'अगले 3 दिन बारिश और आँधी का ख़तरा' : 'Rain and storm risk for 3 days',
      children: [
        if (days.isEmpty)
          _noReading(hi)
        else ...[
          if (service.place != null)
            Text(service.place!.name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          for (var i = 0; i < days.length; i++) ...[
            ToolLine(
              '${_day(days[i].date, hi, i)} · ${weatherWord(days[i].code, hi)}',
              [
                if (days[i].rainMm != null)
                  '${days[i].rainMm!.toStringAsFixed(0)} mm'
                else
                  '${days[i].rainChance}%',
                if (days[i].gustKph != null)
                  hi
                      ? 'झोंके ${days[i].gustKph!.round()} किमी/घं'
                      : 'gusts ${days[i].gustKph!.round()} km/h',
              ].join(' · '),
              strong: codeIsStorm(days[i].code) ||
                  (days[i].gustKph ?? 0) >= gustStrong ||
                  (rainBand(days[i].rainMm)?.index ?? 0) >=
                      RainBand.heavy.index,
            ),
          ],
          if (forecast!.isStale)
            ToolNote(hi
                ? 'यह पिछली जानकारी है; ताज़ा मौसम के लिए इंटरनेट से जुड़ें।'
                : 'This is a last-known reading; connect to the internet for '
                    'the current weather.'),
          const SizedBox(height: 10),
          ToolAnswer(
            headline: heavy || gusty || storm
                ? (hi ? 'तैयारी के लायक़ मौसम आ रहा है' : 'Weather worth preparing for')
                : (hi ? 'कोई बड़ा ख़तरा नहीं दिख रहा' : 'No major risk showing'),
            detail: [
              if (heavy)
                hi
                    ? 'भारी बारिश का अनुमान है — मौसम विभाग के पैमाने पर 24 घंटे में '
                        '64.5 मिमी से ज़्यादा। निचले घरों में पानी भरने और नालों में '
                        'उफान का ख़तरा।'
                    : 'Heavy rain is forecast - over 64.5 mm in 24 hours on the '
                        'Meteorological Department\'s scale. Risk of water in '
                        'low-lying homes and of streams overflowing.',
              if (gusty)
                hi
                    ? 'तेज़ झोंके — ${gustStrong.round()} किमी/घंटा से ऊपर — जिनसे टीन की '
                        'छत उड़ सकती है और डालियाँ टूट सकती हैं।'
                    : 'Strong gusts - above ${gustStrong.round()} km/h - '
                        'enough to lift tin sheets and break branches.',
              if (storm)
                hi
                    ? 'आँधी-तूफ़ान और बिजली गिरने का अनुमान। इसी लक्ष्य में "बिजली '
                        'गिरना" वाली स्क्रीन देखें।'
                    : 'Thunderstorms and lightning are forecast. See the '
                        '"Lightning" screen in this goal.',
              if (!heavy && !gusty && !storm)
                hi
                    ? 'अगले तीन दिन में न भारी बारिश दिख रही है, न तेज़ आँधी। फिर भी '
                        'सरकारी चेतावनी देखते रहें।'
                    : 'Neither heavy rain nor strong wind shows over the next '
                        'three days. Keep an eye on the official warnings all '
                        'the same.',
            ].join('\n\n'),
            tone: heavy || gusty || storm ? ToolTone.warn : ToolTone.good,
            icon: Icons.thunderstorm_outlined,
          ),
        ],
        const SizedBox(height: 14),
        Text(hi ? 'पहले क्या हटाएँ या बाँधें' : 'What to move or tie down first',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'काग़ज़ — आधार, राशन कार्ड, ज़मीन के काग़ज़, बैंक पासबुक — दोहरी '
                      'पन्नी में, सबसे ऊँची जगह।',
                  'अनाज, बीज और खाद ज़मीन से ऊपर, ईंटों या मचान पर।',
                  'टीन की चादरें और छप्पर रस्सी या तार से बाँधें, और ऊपर ईंट या '
                      'पत्थर न रखें — आँधी में वही उड़कर चोट करते हैं।',
                  'मवेशी ऊँची जगह पर, खुले — बँधे न रहें।',
                  'फ़ोन और पावर बैंक पूरा चार्ज करें; टॉर्च और सूखा खाना तैयार रखें।',
                  'नाली और छत का पानी निकलने का रास्ता साफ़ करें।',
                ]
              : const [
                  'Papers - Aadhaar, ration card, land papers, bank passbook - '
                      'in a double plastic bag, on the highest shelf.',
                  'Grain, seed and fertiliser off the floor, on bricks or a '
                      'raised platform.',
                  'Tie tin sheets and thatch down with rope or wire, and do '
                      'not weigh them with bricks or stones - in a storm '
                      'those are what fly and hurt people.',
                  'Animals to high ground, untied.',
                  'Charge the phone and power bank fully; keep a torch and '
                      'dry food ready.',
                  'Clear the drains and the roof\'s run-off.',
                ],
        ),
        const SizedBox(height: 10),
        _officialNote(hi),
        const SourceNote(text: 'India Meteorological Department', url: _imdUrl),
      ],
    );
  }
}

// --- Lightning --------------------------------------------------------

enum WhereNow { indoors, openField, inWater, underTree, inVehicle }

class LightningPage extends StatefulWidget {
  const LightningPage({super.key});

  @override
  State<LightningPage> createState() => _LightningPageState();
}

class _LightningPageState extends State<LightningPage> {
  WhereNow? _where;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final service = context.watch<PlaceService>();
    final now = service.forecast?.now;
    final today = service.forecast?.days.isNotEmpty == true
        ? service.forecast!.days.first
        : null;
    final stormNow = now != null && codeIsStorm(now.code);
    final stormToday = today != null && codeIsStorm(today.code);

    return ToolScaffold(
      goal: 13,
      title: hi ? 'बिजली गिरना: अभी सुरक्षित हैं या नहीं' : 'Lightning: safe or not right now',
      children: [
        if (stormNow || stormToday)
          ToolAnswer(
            headline: stormNow
                ? (hi ? 'अभी आँधी-तूफ़ान है' : 'A thunderstorm now')
                : (hi ? 'आज आँधी-तूफ़ान का अनुमान' : 'Thunderstorms forecast today'),
            detail: hi
                ? 'खुले में काम रोक दें और किसी पक्की इमारत या बंद गाड़ी में चले '
                    'जाएँ। "दामिनी" ऐप आपके आसपास बिजली गिरने की चेतावनी देता है — '
                    'यह भारतीय उष्णदेशीय मौसम विज्ञान संस्थान का मुफ़्त ऐप है।'
                : 'Stop work in the open and get into a solid building or a '
                    'closed vehicle. The "Damini" app warns of lightning near '
                    'you - it is a free app from the Indian Institute of '
                    'Tropical Meteorology.',
            tone: ToolTone.bad,
            icon: Icons.bolt_outlined,
          )
        else
          ToolNote(hi
              ? 'अभी ऐप के अनुमान में आँधी-तूफ़ान नहीं है। आसमान में गरज सुनाई दे तो '
                  'ऐप का इंतज़ार न करें — गरज सुनाई देने का मतलब है कि बिजली आप तक '
                  'पहुँच सकती है।'
              : 'The app\'s reading shows no thunderstorm right now. If you '
                  'hear thunder, do not wait for the app - if you can hear '
                  'it, lightning can reach you.'),
        const SizedBox(height: 10),
        ToolAnswer(
          headline: hi ? '30 सेकंड का नियम' : 'The 30-second rule',
          detail: hi
              ? 'चमक देखते ही गिनती शुरू करें। गरज 30 सेकंड के भीतर सुनाई दे तो '
                  'बिजली 10 किलोमीटर के भीतर है — तुरंत आड़ लें। आख़िरी गरज के बाद '
                  '30 मिनट तक बाहर न निकलें।'
              : 'Start counting at the flash. If the thunder comes within 30 '
                  'seconds, the lightning is within 10 km - take shelter at '
                  'once. Stay in for 30 minutes after the last thunder.',
          tone: ToolTone.plain,
          icon: Icons.timer_outlined,
        ),
        ToolQuestion(hi ? 'आप अभी कहाँ हैं' : 'Where are you right now'),
        SelectionTile(
          label: hi ? 'खुले खेत या मैदान में' : 'In an open field',
          selected: _where == WhereNow.openField,
          onTap: () => setState(() => _where = WhereNow.openField),
        ),
        SelectionTile(
          label: hi ? 'पेड़ के नीचे' : 'Under a tree',
          selected: _where == WhereNow.underTree,
          onTap: () => setState(() => _where = WhereNow.underTree),
        ),
        SelectionTile(
          label: hi ? 'पानी में — तालाब, नदी, धान का खेत' : 'In water - pond, river, paddy',
          selected: _where == WhereNow.inWater,
          onTap: () => setState(() => _where = WhereNow.inWater),
        ),
        SelectionTile(
          label: hi ? 'घर के अंदर' : 'Indoors',
          selected: _where == WhereNow.indoors,
          onTap: () => setState(() => _where = WhereNow.indoors),
        ),
        SelectionTile(
          label: hi ? 'गाड़ी में' : 'In a vehicle',
          selected: _where == WhereNow.inVehicle,
          onTap: () => setState(() => _where = WhereNow.inVehicle),
        ),
        if (_where == WhereNow.openField)
          ToolAnswer(
            headline: hi ? 'नीचे बैठें, लेटें नहीं' : 'Crouch - do not lie down',
            detail: hi
                ? 'पास में पक्की इमारत या बंद गाड़ी हो तो वहाँ जाएँ। न हो तो: पैर '
                    'आपस में सटाकर पंजों के बल नीचे बैठें, सिर घुटनों में, कान हाथों '
                    'से ढकें। ज़मीन पर लेटें नहीं — ज़मीन से करंट फैलता है। हँसिया, '
                    'छाता, फावड़ा या कोई धातु की चीज़ दूर रखें। दो लोग हों तो कुछ दूर-'
                    'दूर बैठें।'
                : 'If there is a solid building or a closed vehicle nearby, go '
                    'there. If not: crouch on the balls of your feet with your '
                    'feet together, head between the knees, hands over the '
                    'ears. Do not lie flat - current spreads through the '
                    'ground. Put down any sickle, umbrella, spade or metal '
                    'tool. If there are several of you, spread a little '
                    'apart.',
            tone: ToolTone.bad,
            icon: Icons.warning_amber_outlined,
          ),
        if (_where == WhereNow.underTree)
          ToolAnswer(
            headline: hi ? 'पेड़ से तुरंत दूर हटें' : 'Move away from the tree now',
            detail: hi
                ? 'बिजली ऊँची चीज़ पर गिरती है, और पेड़ के नीचे खड़ा व्यक्ति सबसे '
                    'ज़्यादा ख़तरे में होता है — गाँवों में बिजली से होने वाली बहुत '
                    'मौतें यहीं होती हैं। पेड़ से दूर, खुली जगह में ऊपर बताए तरीक़े से '
                    'नीचे बैठें।'
                : 'Lightning strikes tall things, and a person standing under a '
                    'tree is in the most danger of all - many rural lightning '
                    'deaths happen exactly there. Get clear of the tree and '
                    'crouch in the open as described for a field.',
            tone: ToolTone.bad,
            icon: Icons.park_outlined,
          ),
        if (_where == WhereNow.inWater)
          ToolAnswer(
            headline: hi ? 'तुरंत पानी से बाहर' : 'Out of the water now',
            detail: hi
                ? 'पानी बिजली को दूर तक ले जाता है। तालाब, नदी, धान के खेत या नाव से '
                    'तुरंत बाहर निकलें और किनारे से भी दूर हटें।'
                : 'Water carries the current a long way. Get out of the pond, '
                    'river, paddy field or boat at once, and away from the '
                    'edge too.',
            tone: ToolTone.bad,
            icon: Icons.water_outlined,
          ),
        if (_where == WhereNow.indoors)
          ToolAnswer(
            headline: hi ? 'अंदर सुरक्षित हैं — कुछ बातों के साथ' : 'Safe inside - with a few cautions',
            detail: hi
                ? 'खिड़की-दरवाज़े से दूर रहें। टीवी, फ़्रिज और कंप्यूटर का प्लग निकाल '
                    'दें। चार्ज होता फ़ोन, तार वाला फ़ोन, नल और नहाना — तूफ़ान के दौरान '
                    'इनसे बचें, क्योंकि करंट तार और पानी की पाइप से अंदर आ सकता है।'
                : 'Keep away from windows and doors. Unplug the TV, fridge and '
                    'computer. Avoid a phone on charge, a corded phone, taps '
                    'and bathing during the storm, because current can come '
                    'in along wiring and water pipes.',
            tone: ToolTone.good,
            icon: Icons.home_outlined,
          ),
        if (_where == WhereNow.inVehicle)
          ToolAnswer(
            headline: hi ? 'बंद गाड़ी सुरक्षित है' : 'A closed vehicle is safe',
            detail: hi
                ? 'धातु की छत वाली बंद गाड़ी में रहें, खिड़कियाँ बंद करें, और धातु के '
                    'हिस्से न छुएँ। मोटरसाइकिल, साइकिल, ट्रैक्टर और खुली जीप सुरक्षित '
                    'नहीं हैं — उनसे उतरकर आड़ लें।'
                : 'Stay in a closed vehicle with a metal roof, windows shut, '
                    'and do not touch metal parts. Motorcycles, bicycles, '
                    'tractors and open jeeps are not safe - get off and find '
                    'shelter.',
            tone: ToolTone.good,
            icon: Icons.directions_car_outlined,
          ),
        const SizedBox(height: 14),
        ToolAnswer(
          headline: hi ? 'किसी पर बिजली गिरे तो' : 'If someone is struck',
          detail: hi
              ? 'उसके शरीर में करंट नहीं रहता — उसे छूना सुरक्षित है, तुरंत मदद करें। '
                  '108 पर फ़ोन करें। साँस न चल रही हो और आप सीपीआर जानते हों तो शुरू '
                  'करें। बिजली गिरने से कई लोग बच जाते हैं, अगर मदद जल्दी मिले।'
              : 'There is no charge left in their body - it is safe to touch '
                  'them, so help at once. Call 108. If they are not breathing '
                  'and you know CPR, start it. Many people survive a strike '
                  'when help comes quickly.',
          tone: ToolTone.bad,
          icon: Icons.medical_services_outlined,
        ),
        const SourceNote(
            text: 'National Disaster Management Authority', url: _ndmaUrl),
      ],
    );
  }
}

// --- Cyclone warning stages -------------------------------------------

enum CycloneStage { watch, alert, warning, landfall }

class CyclonePage extends StatefulWidget {
  const CyclonePage({super.key});

  @override
  State<CyclonePage> createState() => _CyclonePageState();
}

class _CyclonePageState extends State<CyclonePage> {
  CycloneStage? _stage;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    final steps = switch (_stage) {
      CycloneStage.watch => hi
          ? const [
              'मछुआरे समुद्र में हों तो तट पर लौटें; नए सिरे से समुद्र में न जाएँ।',
              'रेडियो, टीवी और "सचेत" ऐप पर अगली सूचना देखते रहें।',
              'पास का चक्रवात आश्रय या पक्की इमारत कहाँ है, यह पता कर लें।',
              'राशन, पानी, दवाएँ और टॉर्च की बैटरी पूरी कर लें।',
            ]
          : const [
              'Fishers at sea should return to shore; nobody should set out.',
              'Follow the next bulletins on radio, TV and the "Sachet" app.',
              'Find out where the nearest cyclone shelter or solid building '
                  'is.',
              'Top up rations, water, medicines and torch batteries.',
            ],
      CycloneStage.alert => hi
          ? const [
              'काग़ज़ और क़ीमती सामान पन्नी में बंद करके ऊँची जगह रखें।',
              'टीन की छत और छप्पर बाँधें; छत पर रखी ढीली चीज़ें उतार लें।',
              'नाव और जाल तट से ऊपर, सुरक्षित जगह बाँधें।',
              'फ़ोन और पावर बैंक चार्ज करें; पीने का पानी भरकर रखें।',
              'बुज़ुर्ग, बीमार, गर्भवती और छोटे बच्चे — इन्हें पहले कहाँ ले जाना है, '
                  'तय कर लें।',
            ]
          : const [
              'Seal papers and valuables in plastic and put them up high.',
              'Tie down tin roofs and thatch; take loose things off the '
                  'roof.',
              'Haul boats and nets above the shore and tie them somewhere '
                  'safe.',
              'Charge phones and power banks; store drinking water.',
              'Decide in advance where the old, the sick, pregnant women '
                  'and small children go first.',
            ],
      CycloneStage.warning => hi
          ? const [
              'प्रशासन हटने को कहे तो तुरंत चक्रवात आश्रय या पक्की इमारत में जाएँ — '
                  'देर न करें, बाद में रास्ते बंद हो जाते हैं।',
              'जाते समय बिजली का मेन और गैस बंद करें।',
              'मवेशियों को खोल दें; बँधा जानवर नहीं बच पाता।',
              'कच्चे घर या समुद्र और नदी के किनारे बिल्कुल न रुकें।',
            ]
          : const [
              'If the administration tells you to leave, go at once to the '
                  'cyclone shelter or a solid building - do not wait; roads '
                  'close later.',
              'Switch off the mains and the gas as you go.',
              'Untie the animals; a tethered animal cannot survive.',
              'Do not stay in a kutcha house or near the sea or a river at '
                  'all.',
            ],
      CycloneStage.landfall => hi
          ? const [
              'अंदर रहें। अचानक हवा थम जाए तो बाहर न निकलें — वह चक्रवात की '
                  '"आँख" हो सकती है, और हवा दूसरी दिशा से फिर उतनी ही तेज़ लौटती है।',
              'प्रशासन के "ख़तरा टला" कहने के बाद ही निकलें।',
              'निकलने पर गिरे बिजली के तार, टूटी डालियाँ और भरे पानी से दूर रहें।',
              'नल या कुएँ का पानी उबालकर या गोली डालकर ही पिएँ।',
            ]
          : const [
              'Stay inside. If the wind suddenly drops, do not go out - it '
                  'may be the "eye" of the cyclone, and the wind returns from '
                  'the other side just as hard.',
              'Leave only after the administration says the danger is past.',
              'Outside, keep clear of fallen power lines, broken branches '
                  'and standing water.',
              'Drink tap or well water only after boiling it or adding a '
                  'tablet.',
            ],
      null => const <String>[],
    };

    return ToolScaffold(
      goal: 13,
      title: hi ? 'चक्रवात चेतावनी के चरण' : 'Cyclone warning stages',
      children: [
        ToolNote(hi
            ? 'मौसम विभाग चक्रवात की चेतावनी चार चरणों में देता है, और हर चरण का '
                'मतलब है कि अब कितना समय बचा है। रेडियो या टीवी पर जो चरण सुनाई दे, '
                'उसे चुनें।'
            : 'The Meteorological Department gives cyclone warnings in four '
                'stages, and each stage tells you how much time is left. Pick '
                'the stage you heard on the radio or TV.'),
        SelectionTile(
          label: hi ? 'चक्रवात-पूर्व निगरानी' : 'Pre-cyclone watch',
          subtitle: hi ? 'लगभग 72 घंटे पहले' : 'About 72 hours ahead',
          selected: _stage == CycloneStage.watch,
          onTap: () => setState(() => _stage = CycloneStage.watch),
        ),
        SelectionTile(
          label: hi ? 'चक्रवात अलर्ट (पीला)' : 'Cyclone alert (yellow)',
          subtitle: hi ? 'कम से कम 48 घंटे पहले' : 'At least 48 hours ahead',
          selected: _stage == CycloneStage.alert,
          onTap: () => setState(() => _stage = CycloneStage.alert),
        ),
        SelectionTile(
          label: hi ? 'चक्रवात चेतावनी (नारंगी)' : 'Cyclone warning (orange)',
          subtitle: hi ? 'कम से कम 24 घंटे पहले' : 'At least 24 hours ahead',
          selected: _stage == CycloneStage.warning,
          onTap: () => setState(() => _stage = CycloneStage.warning),
        ),
        SelectionTile(
          label: hi ? 'तट से टकराने के बाद का अनुमान (लाल)' : 'Post-landfall outlook (red)',
          subtitle: hi ? 'टकराने से लगभग 12 घंटे पहले' : 'About 12 hours before landfall',
          selected: _stage == CycloneStage.landfall,
          onTap: () => setState(() => _stage = CycloneStage.landfall),
        ),
        if (steps.isNotEmpty) ...[
          const SizedBox(height: 10),
          ToolSteps(steps: steps),
        ],
        const SizedBox(height: 10),
        _officialNote(hi),
        const SourceNote(text: 'India Meteorological Department', url: _imdUrl),
      ],
    );
  }
}

// --- House damaged ----------------------------------------------------

class StormDamagePage extends StatelessWidget {
  const StormDamagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 13,
      title: hi ? 'बाढ़ या आँधी से घर टूटा' : 'House damaged by flood or storm',
      children: [
        ToolAnswer(
          headline: hi ? 'सफ़ाई से पहले फ़ोटो' : 'Photographs before the clean-up',
          detail: hi
              ? 'राहत का हिसाब सर्वे से बनता है, और सर्वे करने वाला वही देखता है जो '
                  'उसके आने तक बचा है। इसलिए कुछ भी हटाने, धोने या ठीक करने से '
                  'पहले फ़ोटो और वीडियो लें। फ़ोन में तारीख़ अपने आप दर्ज हो जाती है।'
              : 'Relief is worked out from the survey, and the surveyor sees '
                  'only what is left when they arrive. So before removing, '
                  'washing or repairing anything, take photos and video. The '
                  'phone records the date on its own.',
          tone: ToolTone.warn,
          icon: Icons.photo_camera_outlined,
        ),
        const SizedBox(height: 12),
        Text(hi ? 'कौन सी फ़ोटो' : 'Which photographs',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const ToolChecklist(
          storageKey: 'storm_damage_proof_v1',
          introEn: 'Tick each one as you take it.',
          introHi: 'जो फ़ोटो ले लें, उस पर निशान लगाएँ।',
          items: [
            CheckItem('front', 'The whole house from the front, with the family',
                'पूरा घर सामने से, परिवार के साथ',
                noteEn: 'It shows whose house it is.',
                noteHi: 'इससे पता चलता है कि घर किसका है।'),
            CheckItem('walls', 'Each damaged wall, close up and from a distance',
                'हर टूटी दीवार, पास से और दूर से'),
            CheckItem('roof', 'The roof, inside and out', 'छत, अंदर और बाहर से'),
            CheckItem('water', 'The water mark on the wall, with a hand for scale',
                'दीवार पर पानी का निशान, नाप के लिए हाथ रखकर'),
            CheckItem('goods', 'Damaged grain, furniture, utensils, clothes',
                'ख़राब अनाज, सामान, बर्तन, कपड़े'),
            CheckItem('animals', 'Any dead animal, with its ear tag if it has one',
                'कोई मरा जानवर, कान के टैग के साथ अगर हो'),
            CheckItem('crop', 'The field and the damaged crop', 'खेत और ख़राब फ़सल',
                noteEn: 'Insured crop: report within 72 hours - see "Crop damaged" '
                    'in this goal.',
                noteHi: 'बीमित फ़सल: 72 घंटे में सूचना दें — इसी लक्ष्य में "फ़सल '
                    'ख़राब" वाली स्क्रीन देखें।'),
          ],
        ),
        const SizedBox(height: 14),
        Text(hi ? 'राहत कैसे मिलती है' : 'How relief comes',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'पटवारी, लेखपाल या राजस्व निरीक्षक सर्वे करता है। वह न आए तो तहसील '
                      'में लिखित सूचना दें और रसीद लें; ग्राम पंचायत को भी बताएँ।',
                  'सर्वे में घर, सामान, मवेशी और फ़सल — सबका नुक़सान दर्ज कराएँ। '
                      'जो लिखा जाए वह पढ़ें, और उसकी नक़ल (पंचनामा) माँगें।',
                  'राहत राज्य आपदा राहत कोष के नियमों से तय होती है — पूरा टूटा '
                      'घर, आंशिक टूटा घर, कपड़े-बर्तन, मवेशी और फ़सल के लिए अलग-अलग। '
                      'रक़में हर कुछ साल बदलती हैं, इसलिए तहसील से अपनी श्रेणी की रक़म '
                      'पूछें।',
                  'पैसा सीधे बैंक खाते में आता है, इसलिए खाता आधार से जुड़ा और चालू '
                      'होना चाहिए।',
                  'घर का बीमा हो तो बीमा कंपनी को अलग से, उसकी तय समय सीमा में बताएँ।',
                  'घर पूरा टूट गया हो तो प्रधानमंत्री आवास योजना में नाम के लिए भी '
                      'पूछें — इसी ऐप में लक्ष्य 11 में पात्रता की जाँच है।',
                ]
              : const [
                  'The patwari, lekhpal or revenue inspector carries out the '
                      'survey. If nobody comes, give written notice at the '
                      'tehsil and take a receipt; tell the gram panchayat too.',
                  'Get every loss into the survey - house, goods, animals and '
                      'crop. Read what is written, and ask for a copy (the '
                      'panchnama).',
                  'Relief is fixed by the State Disaster Response Fund norms '
                      '- separately for a fully damaged house, a partly '
                      'damaged one, clothes and utensils, animals and crop. '
                      'The amounts change every few years, so ask the tehsil '
                      'for the figure for your category.',
                  'Money comes straight to a bank account, so the account must '
                      'be active and linked to Aadhaar.',
                  'If the house is insured, tell the insurer separately, '
                      'within its own time limit.',
                  'If the house is destroyed, ask about PM Awas Yojana too - '
                      'goal 11 in this app has the eligibility check.',
                ],
        ),
        const SizedBox(height: 12),
        ToolDonts(
          heading: hi ? 'सावधानी' : 'Careful',
          items: hi
              ? const [
                  'टूटी दीवार या लटकती छत के नीचे न जाएँ — दूसरा गिरना पहले से ज़्यादा '
                      'जान लेता है',
                  'बिजली का मेन बंद किए बिना भीगे घर में स्विच न छुएँ',
                  'सर्वे के कोरे फ़ॉर्म पर दस्तख़त न करें',
                  'राहत "दिलाने" के बदले पैसा माँगने वाले से बचें — राहत मुफ़्त है',
                ]
              : const [
                  'Do not go under a cracked wall or a sagging roof - the '
                      'second collapse kills more than the first',
                  'Touch no switch in a wet house until the mains is off',
                  'Do not sign a blank survey form',
                  'Avoid anyone asking for money to "get" the relief - relief '
                      'is free',
                ],
        ),
        const SourceNote(
            text: 'National Disaster Management Authority', url: _ndmaUrl),
      ],
    );
  }
}
