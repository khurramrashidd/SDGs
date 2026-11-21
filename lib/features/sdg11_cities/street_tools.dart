import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Four street-level problems: the fare, the noise, the building, the
/// society.
///
/// Fares are notified by each state's transport department and revised on
/// its own schedule, so the fare screen holds no rate. It asks for the
/// two numbers printed on the official fare card - the minimum fare and
/// the rate per kilometre - and does the arithmetic, which is all a
/// passenger needs to know whether they were cheated.
///
/// The noise limits are different: they come from the Noise Pollution
/// (Regulation and Control) Rules 2000 and have stood unchanged since,
/// so they are stated.

const _cpcbUrl = 'https://cpcb.nic.in/';
const _consumerUrl = 'https://consumerhelpline.gov.in/';
const _parivahanUrl = 'https://parivahan.gov.in/';

/// Ambient noise limits, dB(A) Leq. Schedule to the Noise Pollution
/// (Regulation and Control) Rules 2000. Day is 6 am to 10 pm.
const noiseResidential = (day: 55, night: 45);
const noiseCommercial = (day: 65, night: 55);
const noiseIndustrial = (day: 75, night: 70);
const noiseSilence = (day: 50, night: 40);
const loudspeakerNightFromHour = 22;
const loudspeakerNightToHour = 6;

/// Structural defect liability of a promoter, RERA Act 2016 section 14(3).
const reraDefectYears = 5;

// --- Fare -------------------------------------------------------------

enum Ride { meteredAuto, sharedAuto, govtBus, privateBus, appCab }

class FarePage extends StatefulWidget {
  const FarePage({super.key});

  @override
  State<FarePage> createState() => _FarePageState();
}

class _FarePageState extends State<FarePage> {
  Ride? _ride;
  final _minFare = TextEditingController();
  final _minKm = TextEditingController(text: '1.5');
  final _perKm = TextEditingController();
  final _km = TextEditingController();
  final _charged = TextEditingController();
  final _nightExtra = TextEditingController(text: '0');

  @override
  void dispose() {
    for (final c in [_minFare, _minKm, _perKm, _km, _charged, _nightExtra]) {
      c.dispose();
    }
    super.dispose();
  }

  double _v(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final minFare = _v(_minFare);
    final minKm = _v(_minKm);
    final perKm = _v(_perKm);
    final km = _v(_km);
    final charged = _v(_charged);
    double? fair;
    if (minFare > 0 && perKm > 0 && km > 0) {
      final extra = km > minKm ? (km - minKm) * perKm : 0.0;
      fair = (minFare + extra) * (1 + _v(_nightExtra) / 100);
    }

    return ToolScaffold(
      goal: 11,
      title: hi ? 'बस या ऑटो ने ज़्यादा किराया लिया' : 'Overcharged by bus or auto',
      children: [
        ToolQuestion(hi ? 'किस सवारी में' : 'Which kind of ride'),
        SelectionTile(
          label: hi ? 'मीटर वाला ऑटो या टैक्सी' : 'Metered auto or taxi',
          selected: _ride == Ride.meteredAuto,
          onTap: () => setState(() => _ride = Ride.meteredAuto),
        ),
        SelectionTile(
          label: hi ? 'शेयर ऑटो, जीप या टेम्पो' : 'Shared auto, jeep or tempo',
          selected: _ride == Ride.sharedAuto,
          onTap: () => setState(() => _ride = Ride.sharedAuto),
        ),
        SelectionTile(
          label: hi ? 'सरकारी बस' : 'Government bus',
          selected: _ride == Ride.govtBus,
          onTap: () => setState(() => _ride = Ride.govtBus),
        ),
        SelectionTile(
          label: hi ? 'निजी बस' : 'Private bus',
          selected: _ride == Ride.privateBus,
          onTap: () => setState(() => _ride = Ride.privateBus),
        ),
        SelectionTile(
          label: hi ? 'ऐप वाली कैब या बाइक' : 'App cab or bike taxi',
          selected: _ride == Ride.appCab,
          onTap: () => setState(() => _ride = Ride.appCab),
        ),
        if (_ride == Ride.meteredAuto) ...[
          ToolNote(hi
              ? 'मीटर वाले ऑटो-टैक्सी का किराया राज्य का परिवहन विभाग तय करता है और '
                  'उसका "किराया कार्ड" गाड़ी में रखना होता है। यह ऐप दरें नहीं रखता, '
                  'क्योंकि वे हर राज्य और हर संशोधन में बदलती हैं — कार्ड या परिवहन '
                  'विभाग की वेबसाइट से दो संख्याएँ भरिए, हिसाब यह लगा देगा।'
              : 'Metered auto and taxi fares are fixed by the state '
                  'transport department, and the "fare card" has to be kept '
                  'in the vehicle. This app carries no rates, because they '
                  'differ by state and by revision - fill two numbers from '
                  'the card or the transport department\'s site, and it does '
                  'the arithmetic.'),
          ToolQuestion(hi ? 'सरकारी किराया कार्ड से' : 'From the official fare card'),
          Row(
            children: [
              Expanded(
                child: ToolNumber(
                  controller: _minFare,
                  label: hi ? 'न्यूनतम किराया (₹)' : 'Minimum fare (₹)',
                  decimal: true,
                  maxDigits: 5,
                  icon: Icons.currency_rupee,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ToolNumber(
                  controller: _minKm,
                  label: hi ? 'न्यूनतम में कितने किमी' : 'Km in the minimum',
                  decimal: true,
                  maxDigits: 4,
                  icon: Icons.straighten,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ToolNumber(
            controller: _perKm,
            label: hi ? 'उसके बाद प्रति किमी (₹)' : 'Per km after that (₹)',
            decimal: true,
            maxDigits: 5,
            icon: Icons.add_road,
            onChanged: (_) => setState(() {}),
          ),
          ToolQuestion(hi ? 'आपकी सवारी' : 'Your ride'),
          Row(
            children: [
              Expanded(
                child: ToolNumber(
                  controller: _km,
                  label: hi ? 'कितने किमी' : 'How many km',
                  decimal: true,
                  maxDigits: 5,
                  icon: Icons.route,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ToolNumber(
                  controller: _charged,
                  label: hi ? 'कितना लिया (₹)' : 'Charged (₹)',
                  decimal: true,
                  maxDigits: 6,
                  icon: Icons.payments_outlined,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ToolNumber(
            controller: _nightExtra,
            label: hi
                ? 'रात का अतिरिक्त किराया (%), दिन में 0'
                : 'Night surcharge (%), 0 by day',
            helper: hi
                ? 'कार्ड पर लिखा प्रतिशत; राज्य-राज्य में अलग है'
                : 'The per cent on the card; it differs by state',
            decimal: true,
            maxDigits: 3,
            icon: Icons.nightlight_outlined,
            onChanged: (_) => setState(() {}),
          ),
          if (fair != null) ...[
            ToolAnswer(
              headline: hi
                  ? 'सही किराया लगभग ₹${fair.round()}'
                  : 'The right fare is about ₹${fair.round()}',
              detail: charged > 0
                  ? (charged > fair * 1.1
                      ? (hi
                          ? 'आपसे ₹${charged.round()} लिया गया — लगभग '
                              '₹${(charged - fair).round()} ज़्यादा। गाड़ी का नंबर '
                              'लिख लें; शिकायत नीचे से।'
                          : 'You were charged ₹${charged.round()} - about '
                              '₹${(charged - fair).round()} too much. Note the '
                              'vehicle number; the complaint route is below.')
                      : (hi
                          ? 'आपसे ₹${charged.round()} लिया गया, जो सही किराये के '
                              'आस-पास है।'
                          : 'You were charged ₹${charged.round()}, which is '
                              'close to the right fare.'))
                  : (hi
                      ? 'छोटा-मोटा फ़र्क़ रास्ते और इंतज़ार से आ सकता है। '
                          'दस प्रतिशत से ज़्यादा का फ़र्क़ सवाल उठाने लायक है।'
                      : 'A small difference can come from the route and '
                          'waiting time. More than ten per cent is worth '
                          'questioning.'),
              tone: charged > 0 && charged > fair * 1.1
                  ? ToolTone.bad
                  : ToolTone.plain,
              icon: Icons.receipt_outlined,
            ),
          ],
        ],
        if (_ride == Ride.sharedAuto)
          ToolAnswer(
            headline: hi ? 'रोज़ का किराया पूछ कर रखें' : 'Know the daily fare',
            detail: hi
                ? 'शेयर सवारी का किराया ज़्यादातर जगह स्थानीय संघ या परमिट से तय '
                    'होता है और कहीं छपा नहीं होता। सबसे भरोसेमंद तरीक़ा: रोज़ चलने '
                    'वाले दो-तीन सवारियों से पूछ लेना। बाहर वाले से ज़्यादा लेना आम '
                    'ठगी है। शिकायत: गाड़ी का नंबर लिखें, और ट्रैफ़िक पुलिस या ज़िला '
                    'परिवहन कार्यालय (आरटीओ) में दें — परमिट की शर्तें तोड़ना उनके '
                    'दायरे में है।'
                : 'Shared ride fares are mostly fixed locally, by the union '
                    'or the permit, and printed nowhere. The most reliable '
                    'way to know: ask two or three regular passengers. '
                    'Charging an outsider more is a common cheat. To '
                    'complain: write the vehicle number and give it to the '
                    'traffic police or the district transport office (RTO) - '
                    'breaking permit conditions is theirs to deal with.',
            tone: ToolTone.plain,
            icon: Icons.groups_outlined,
          ),
        if (_ride == Ride.govtBus)
          ToolAnswer(
            headline: hi ? 'टिकट माँगें — वही सबूत है' : 'Ask for the ticket - it is the proof',
            detail: hi
                ? 'सरकारी बस में किराया छपी सारणी से चलता है और कंडक्टर को हर पैसे '
                    'का टिकट देना होता है। टिकट पर रक़म और रूट छपा होता है, और वही '
                    'शिकायत का सबूत है। पैसा लेकर टिकट न देना अपने आप में गड़बड़ी है। '
                    'बस के अंदर या टिकट पर परिवहन निगम का शिकायत नंबर लिखा होता है; '
                    'बस नंबर, समय और रूट के साथ वहीं शिकायत दें।'
                : 'On a government bus the fare runs from a printed table, '
                    'and the conductor must give a ticket for every rupee. '
                    'The ticket shows the amount and the route, and it is the '
                    'proof for any complaint. Taking money without issuing a '
                    'ticket is itself irregular. The transport corporation\'s '
                    'complaint number is printed inside the bus or on the '
                    'ticket; complain there with the bus number, time and '
                    'route.',
            tone: ToolTone.plain,
            icon: Icons.directions_bus_outlined,
          ),
        if (_ride == Ride.privateBus)
          ToolAnswer(
            headline: hi ? 'परमिट की शर्तें उस पर भी लागू' : 'The permit binds it too',
            detail: hi
                ? 'निजी बस भी परमिट पर चलती है, और कई राज्यों में किराये की सीमा '
                    'परिवहन विभाग तय करता है — ख़ास कर साधारण (नॉन-एसी) बसों के '
                    'लिए। टिकट माँगें; टिकट न मिले तो किराये की रक़म और समय लिख लें। '
                    'शिकायत आरटीओ में, या राज्य परिवहन विभाग की हेल्पलाइन पर। '
                    'त्योहारों पर किराया दुगना-तिगुना करना कई राज्यों ने मना किया है '
                    '— अपने राज्य का आदेश परिवहन विभाग की वेबसाइट पर देखें।'
                : 'A private bus also runs on a permit, and in many states '
                    'the transport department caps the fare - especially for '
                    'ordinary non-AC buses. Ask for a ticket; if none is '
                    'given, note the amount and the time. Complain to the '
                    'RTO or the state transport department\'s helpline. Many '
                    'states have barred doubling or tripling fares at '
                    'festivals - check your state\'s order on the transport '
                    'department\'s site.',
            tone: ToolTone.plain,
            icon: Icons.directions_bus_outlined,
          ),
        if (_ride == Ride.appCab)
          ToolAnswer(
            headline: hi ? 'पहले ऐप में शिकायत, फिर ऊपर' : 'Complain in the app first, then above it',
            detail: hi
                ? 'ऐप वाली कैब पर केंद्र के एग्रीगेटर दिशानिर्देश और राज्य के नियम '
                    'लागू होते हैं, जिनमें बढ़े हुए (सर्ज) किराये की ऊपरी सीमा भी है। '
                    'ड्राइवर का नक़द में ज़्यादा माँगना, या ऐप से अलग रास्ता लेकर '
                    'ज़्यादा बिल बनाना — दोनों की शिकायत पहले ऐप में करें, यात्रा का '
                    'स्क्रीनशॉट लेकर। हल न हो तो राष्ट्रीय उपभोक्ता हेल्पलाइन 1915 '
                    'पर।'
                : 'App cabs are covered by the central aggregator guidelines '
                    'and state rules, which include a ceiling on surge '
                    'pricing. A driver demanding extra cash, or a detour that '
                    'inflates the bill - complain about either in the app '
                    'first, with a screenshot of the trip. If it is not '
                    'resolved, call the National Consumer Helpline on 1915.',
            tone: ToolTone.plain,
            icon: Icons.local_taxi_outlined,
          ),
        if (_ride != null) ...[
          const SizedBox(height: 14),
          Text(hi ? 'शिकायत जो काम करती है' : 'The complaint that works',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'गाड़ी का नंबर — यही सबसे ज़रूरी है। उतरने से पहले फ़ोटो ले लें।',
                    'तारीख़, समय, कहाँ से कहाँ, और कितना लिया।',
                    'मीटर वाले ऑटो ने मीटर चलाने या जाने से मना किया, तो वह भी लिखें — '
                        'मना करना भी नियम तोड़ना है।',
                    'शिकायत ट्रैफ़िक पुलिस की हेल्पलाइन या व्हाट्सऐप नंबर पर, या '
                        'आरटीओ में। कई शहरों की ट्रैफ़िक पुलिस फ़ोटो के साथ शिकायत लेती '
                        'है।',
                  ]
                : const [
                    'The vehicle number - this matters most. Photograph it '
                        'before getting off.',
                    'Date, time, from where to where, and how much was '
                        'charged.',
                    'If a metered auto refused to run the meter or refused '
                        'to go, write that too - refusing is itself a '
                        'breach.',
                    'Complain on the traffic police helpline or WhatsApp '
                        'number, or at the RTO. Many cities\' traffic police '
                        'take complaints with a photo.',
                  ],
          ),
          const SourceNote(text: 'Parivahan - transport services', url: _parivahanUrl),
          if (_ride == Ride.appCab)
            const SourceNote(
                text: 'National Consumer Helpline', url: _consumerUrl),
        ],
      ],
    );
  }
}

// --- Noise or smoke ---------------------------------------------------

enum Nuisance { loudspeaker, generator, construction, burning, factory }

class NoiseSmokePage extends StatefulWidget {
  const NoiseSmokePage({super.key});

  @override
  State<NoiseSmokePage> createState() => _NoiseSmokePageState();
}

class _NoiseSmokePageState extends State<NoiseSmokePage> {
  Nuisance? _kind;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 11,
      title: hi ? 'पड़ोसी से शोर या धुआँ' : 'Noise or smoke from a neighbour',
      children: [
        ToolNote(hi
            ? 'पड़ोस का झगड़ा पहले बात से सुलझाने लायक है — शिकायत रिश्ते को और '
                'कड़वा करती है। लेकिन जब बात से न बने, तो क़ानून की सीमाएँ साफ़ '
                'हैं और उन्हें लागू कराने वाला अधिकारी भी तय है।'
            : 'A neighbourhood quarrel is worth settling by talking first - '
                'a complaint sours the relationship further. But when '
                'talking fails, the legal limits are clear and so is the '
                'officer who enforces them.'),
        ToolQuestion(hi ? 'परेशानी क्या है' : 'What is the trouble'),
        SelectionTile(
          label: hi ? 'लाउडस्पीकर या डीजे' : 'Loudspeaker or DJ',
          selected: _kind == Nuisance.loudspeaker,
          onTap: () => setState(() => _kind = Nuisance.loudspeaker),
        ),
        SelectionTile(
          label: hi ? 'डीज़ल जनरेटर' : 'Diesel generator',
          selected: _kind == Nuisance.generator,
          onTap: () => setState(() => _kind = Nuisance.generator),
        ),
        SelectionTile(
          label: hi ? 'रात में निर्माण का काम' : 'Construction work at night',
          selected: _kind == Nuisance.construction,
          onTap: () => setState(() => _kind = Nuisance.construction),
        ),
        SelectionTile(
          label: hi ? 'कूड़ा या पत्ते जलाना' : 'Burning garbage or leaves',
          selected: _kind == Nuisance.burning,
          onTap: () => setState(() => _kind = Nuisance.burning),
        ),
        SelectionTile(
          label: hi ? 'कारख़ाने या भट्ठे का धुआँ' : 'Smoke from a factory or kiln',
          selected: _kind == Nuisance.factory,
          onTap: () => setState(() => _kind = Nuisance.factory),
        ),
        if (_kind == Nuisance.loudspeaker)
          ToolAnswer(
            headline: hi
                ? 'रात $loudspeakerNightFromHour बजे से सुबह $loudspeakerNightToHour बजे तक मना'
                : 'Not allowed from ${loudspeakerNightFromHour - 12} pm to $loudspeakerNightToHour am',
            detail: hi
                ? 'ध्वनि प्रदूषण नियम 2000 के अनुसार रात 10 से सुबह 6 बजे तक खुले में '
                    'लाउडस्पीकर या साउंड सिस्टम नहीं चल सकता — बंद हॉल या सभागार '
                    'अलग हैं। राज्य सरकार साल में कुछ गिने-चुने त्योहार के दिनों में '
                    'आधी रात तक छूट दे सकती है, उससे ज़्यादा नहीं। दिन में भी '
                    'लाउडस्पीकर के लिए अनुमति लगती है। शिकायत 112 पर या सीधे थाने '
                    'में — इन नियमों में पुलिस को कार्यवाही का अधिकार है।'
                : 'Under the Noise Pollution Rules 2000 no loudspeaker or '
                    'sound system may play in the open from 10 pm to 6 am - '
                    'closed halls and auditoriums are different. The state '
                    'may relax this to midnight on a limited number of '
                    'festival days a year, and no more. A loudspeaker needs '
                    'permission in the day too. Complain on 112 or at the '
                    'police station directly - the police are empowered to '
                    'act under these rules.',
            tone: ToolTone.plain,
            icon: Icons.volume_off_outlined,
          ),
        if (_kind == Nuisance.generator)
          ToolAnswer(
            headline: hi ? 'जनरेटर पर ध्वनि-रोधी बक्सा ज़रूरी' : 'A generator needs an acoustic enclosure',
            detail: hi
                ? 'केंद्रीय प्रदूषण नियंत्रण बोर्ड के मानकों में डीज़ल जनरेटर के लिए '
                    'ध्वनि-रोधी बक्सा (एकॉस्टिक एनक्लोज़र) और ऊँची चिमनी ज़रूरी है। '
                    'दुकान, होटल या दफ़्तर का खुला जनरेटर इन नियमों में नहीं चलता। '
                    'शिकायत: राज्य प्रदूषण नियंत्रण बोर्ड, या नगर पालिका का '
                    'स्वास्थ्य/पर्यावरण विभाग।'
                : 'The Central Pollution Control Board norms require a diesel '
                    'generator to have an acoustic enclosure and a tall '
                    'enough exhaust. An open generator at a shop, hotel or '
                    'office does not meet them. Complain to the state '
                    'pollution control board, or the municipality\'s health '
                    'or environment department.',
            tone: ToolTone.plain,
            icon: Icons.bolt_outlined,
          ),
        if (_kind == Nuisance.construction)
          ToolAnswer(
            headline: hi ? 'रात की सीमा निर्माण पर भी' : 'The night limit applies to building work too',
            detail: hi
                ? 'रिहायशी इलाक़े में रात का शोर ${noiseResidential.night} डेसिबल '
                    'की सीमा में रहना है, और '
                    'मशीन से होने वाला निर्माण इससे कहीं ऊपर होता है। ज़्यादातर नगर '
                    'पालिकाएँ निर्माण की अनुमति में काम के घंटे भी लिखती हैं। शिकायत '
                    'नगर पालिका के भवन विभाग में और पुलिस में; दोनों को गाड़ी के '
                    'नंबर या साइट के पते के साथ समय भी बताएँ।'
                : 'At night a residential area must stay within '
                    '${noiseResidential.night} decibels, '
                    'and machine construction runs far above that. Most '
                    'municipalities also write working hours into the '
                    'building permission. Complain to the municipality\'s '
                    'building department and to the police; tell both the '
                    'site address and the times.',
            tone: ToolTone.plain,
            icon: Icons.construction_outlined,
          ),
        if (_kind == Nuisance.burning)
          ToolAnswer(
            headline: hi ? 'खुले में कूड़ा जलाना मना है' : 'Burning waste in the open is banned',
            detail: hi
                ? 'ठोस कचरा प्रबंधन नियम 2016 में कूड़ा, पत्ते और प्लास्टिक खुले में '
                    'जलाना मना है, और राष्ट्रीय हरित अधिकरण ने इस पर जुर्माना भी तय '
                    'किया है। शिकायत नगर पालिका या पंचायत में, और राज्य प्रदूषण '
                    'नियंत्रण बोर्ड में। अक्सर असली वजह यह होती है कि कूड़ा उठता नहीं '
                    '— इसलिए साथ में कूड़ा उठाने की शिकायत भी दें; इसी लक्ष्य में '
                    '"गली की समस्या" वाली स्क्रीन से वह लिखी जा सकती है।'
                : 'The Solid Waste Management Rules 2016 ban burning garbage, '
                    'leaves and plastic in the open, and the National Green '
                    'Tribunal has fixed fines for it. Complain to the '
                    'municipality or panchayat, and to the state pollution '
                    'control board. Often the real cause is that the garbage '
                    'is never collected - so complain about collection too; '
                    'the "street problem" screen in this goal writes that '
                    'complaint.',
            tone: ToolTone.plain,
            icon: Icons.local_fire_department_outlined,
          ),
        if (_kind == Nuisance.factory)
          ToolAnswer(
            headline: hi ? 'यह प्रदूषण नियंत्रण बोर्ड का मामला है' : 'This is for the pollution control board',
            detail: hi
                ? 'कारख़ाने, ईंट-भट्ठे और ढलाई इकाइयों को चलाने के लिए राज्य प्रदूषण '
                    'नियंत्रण बोर्ड की "संचालन सहमति" लेनी होती है, और उसमें धुएँ की '
                    'शर्तें लिखी होती हैं। शिकायत बोर्ड के क्षेत्रीय कार्यालय में या '
                    'उसकी वेबसाइट पर दें, धुएँ की तारीख़ और समय के साथ फ़ोटो और '
                    'वीडियो लगाकर। सूचना का अधिकार से उस इकाई की सहमति और जाँच '
                    'रिपोर्ट भी माँगी जा सकती है।'
                : 'Factories, brick kilns and foundries need a "consent to '
                    'operate" from the state pollution control board, and it '
                    'states conditions on smoke. Complain to the board\'s '
                    'regional office or on its website, with photos and '
                    'video showing the dates and times. The unit\'s consent '
                    'and inspection reports can also be asked for under the '
                    'Right to Information.',
            tone: ToolTone.plain,
            icon: Icons.factory_outlined,
          ),
        if (_kind != null) ...[
          const SizedBox(height: 14),
          Text(hi ? 'ध्वनि की सीमा — डेसिबल' : 'Noise limits - decibels',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ToolLine(hi ? 'रिहायशी (दिन / रात)' : 'Residential (day / night)',
              '${noiseResidential.day} / ${noiseResidential.night}',
              strong: true),
          ToolLine(hi ? 'बाज़ार (दिन / रात)' : 'Commercial (day / night)',
              '${noiseCommercial.day} / ${noiseCommercial.night}'),
          ToolLine(hi ? 'औद्योगिक (दिन / रात)' : 'Industrial (day / night)',
              '${noiseIndustrial.day} / ${noiseIndustrial.night}'),
          ToolLine(
              hi ? 'शांत क्षेत्र — अस्पताल, स्कूल, अदालत' : 'Silence zone - hospital, school, court',
              '${noiseSilence.day} / ${noiseSilence.night}'),
          const SizedBox(height: 8),
          ToolNote(hi
              ? 'दिन सुबह 6 से रात 10 बजे तक, रात 10 से सुबह 6 बजे तक। अस्पताल, '
                  'स्कूल और अदालत के 100 मीटर के दायरे को शांत क्षेत्र घोषित किया जा '
                  'सकता है। फ़ोन के मुफ़्त डेसिबल-मीटर ऐप सटीक नहीं होते, लेकिन '
                  'शिकायत के साथ वीडियो और अनुमानित रीडिंग देने से बात गंभीरता से ली '
                  'जाती है।'
              : 'Day is 6 am to 10 pm, night 10 pm to 6 am. The area within '
                  '100 metres of a hospital, school or court can be declared '
                  'a silence zone. Free decibel-meter apps on a phone are not '
                  'precise, but a video and an approximate reading with the '
                  'complaint get it taken seriously.'),
          const SourceNote(
              text: 'Central Pollution Control Board', url: _cpcbUrl),
        ],
      ],
    );
  }
}

// --- Unsafe or illegal building ---------------------------------------

class UnsafeBuildingPage extends StatefulWidget {
  const UnsafeBuildingPage({super.key});

  @override
  State<UnsafeBuildingPage> createState() => _UnsafeBuildingPageState();
}

class _UnsafeBuildingPageState extends State<UnsafeBuildingPage> {
  bool? _danger;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 11,
      title: hi ? 'पास में असुरक्षित या अवैध इमारत' : 'Unsafe or illegal building nearby',
      children: [
        ToolQuestion(hi ? 'क्या अभी गिरने का ख़तरा है' : 'Is it at risk of falling right now'),
        SelectionTile(
          label: hi
              ? 'हाँ — दरारें बढ़ रही हैं, झुक रही है, टुकड़े गिर रहे हैं'
              : 'Yes - cracks widening, leaning, pieces falling',
          selected: _danger == true,
          onTap: () => setState(() => _danger = true),
        ),
        SelectionTile(
          label: hi
              ? 'नहीं — बिना अनुमति बन रही है, या नक़्शे से अलग'
              : 'No - it is being built without permission, or off the plan',
          selected: _danger == false,
          onTap: () => setState(() => _danger = false),
        ),
        if (_danger == true) ...[
          ToolAnswer(
            headline: hi ? 'पहले लोग बाहर, फिर शिकायत' : 'People out first, complaint after',
            detail: hi
                ? 'इमारत के अंदर और ठीक नीचे के लोगों को बाहर और दूर ले जाएँ। फिर '
                    '112 पर, और आग या गैस की गंध हो तो 101 पर फ़ोन करें। ज़िला आपदा '
                    'नियंत्रण कक्ष 1077 पर भी बताएँ। ऐसी हालत में नगर पालिका को '
                    'इमारत ख़ाली कराने और गिराने या सहारा देने का अधिकार है, और '
                    'बरसात से पहले जर्जर इमारतों का सर्वे करना उसका काम है।'
                : 'Get the people inside and directly below it out and well '
                    'away. Then call 112, and 101 if there is fire or a '
                    'smell of gas. Also tell the district disaster control '
                    'room on 1077. In this situation the municipality has the '
                    'power to have the building vacated and to demolish or '
                    'prop it, and surveying dilapidated buildings before the '
                    'monsoon is its job.',
            tone: ToolTone.bad,
            icon: Icons.warning_amber_outlined,
          ),
          ToolDonts(
            heading: hi ? 'न करें' : 'Do not',
            items: hi
                ? const [
                    'सामान निकालने अंदर न जाएँ — सामान दोबारा आ सकता है',
                    'झुकी दीवार के नीचे या साथ न खड़े हों, न गाड़ी खड़ी करें',
                    'बिजली का मेन स्विच बाहर से बंद हो सके तो करें; अंदर जाकर नहीं',
                    'भारी बारिश में जर्जर इमारत में रात न बिताएँ',
                  ]
                : const [
                    'Do not go back in for belongings - belongings can be '
                        'replaced',
                    'Do not stand or park beside or below a leaning wall',
                    'Switch off the mains if it can be done from outside; '
                        'not by going in',
                    'Do not spend a night in a dilapidated building in heavy '
                        'rain',
                  ],
          ),
        ],
        if (_danger == false) ...[
          ToolAnswer(
            headline: hi ? 'नक़्शा माँगिए — वही सबूत है' : 'Ask for the plan - it is the evidence',
            detail: hi
                ? 'हर पक्के निर्माण के लिए नगर पालिका या विकास प्राधिकरण से नक़्शा '
                    'पास कराना होता है, और पास नक़्शा एक सार्वजनिक रिकॉर्ड है। '
                    'सूचना का अधिकार से उस प्लॉट का पास नक़्शा और अनुमति माँगें — '
                    '₹10 में। नक़्शे से ज़्यादा मंज़िलें, सड़क या नाली पर क़ब्ज़ा, या '
                    'पड़ोस की हवा-रोशनी रोकना — ये सब अवैध निर्माण के आम रूप हैं।'
                : 'Every permanent building needs a plan passed by the '
                    'municipality or development authority, and a passed '
                    'plan is a public record. Ask under the Right to '
                    'Information for that plot\'s sanctioned plan and '
                    'permission - for ₹10. More floors than the plan, '
                    'encroaching on the road or drain, or blocking the '
                    'neighbours\' light and air - these are the common forms '
                    'of illegal construction.',
            tone: ToolTone.plain,
            icon: Icons.architecture_outlined,
          ),
          const SizedBox(height: 12),
          Text(hi ? 'शिकायत' : 'The complaint',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'नगर पालिका या विकास प्राधिकरण के भवन/प्रवर्तन विभाग में लिखित '
                        'शिकायत दें: पता, क्या बन रहा है, और तारीख़वार फ़ोटो।',
                    'काम जारी हो तो जल्दी करें — ज़्यादातर नगर पालिकाएँ अवैध काम '
                        'बनते समय रोक सकती हैं, बन जाने के बाद मामला सालों चलता है।',
                    'शिकायत की रसीद और संख्या रखें। एक महीने में जवाब न आए तो उसी '
                        'शिकायत पर हुई कार्यवाही सूचना का अधिकार से माँगें।',
                    'आपकी अपनी ज़मीन, दीवार या रास्ता दब रहा हो तो दीवानी अदालत से '
                        'निर्माण रोकने का आदेश भी माँगा जा सकता है; मुफ़्त सलाह ज़िला '
                        'विधिक सेवा प्राधिकरण से।',
                  ]
                : const [
                    'Give a written complaint to the building or enforcement '
                        'department of the municipality or development '
                        'authority: the address, what is being built, and '
                        'dated photographs.',
                    'Move quickly while work is going on - most '
                        'municipalities can stop illegal work while it is '
                        'being built; once it stands, the matter runs for '
                        'years.',
                    'Keep the receipt and the complaint number. If nothing '
                        'comes in a month, ask under the Right to Information '
                        'what action was taken on that complaint.',
                    'If your own land, wall or passage is being encroached, '
                        'a civil court can also be asked to stop the '
                        'construction; free advice from the District Legal '
                        'Services Authority.',
                  ],
          ),
        ],
      ],
    );
  }
}

// --- Housing society dispute ------------------------------------------

enum SocietyWith { committee, builder, member }

class SocietyDisputePage extends StatefulWidget {
  const SocietyDisputePage({super.key});

  @override
  State<SocietyDisputePage> createState() => _SocietyDisputePageState();
}

class _SocietyDisputePageState extends State<SocietyDisputePage> {
  SocietyWith? _with;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 11,
      title: hi ? 'हाउसिंग सोसाइटी विवाद' : 'Housing society dispute',
      children: [
        ToolNote(hi
            ? 'सोसाइटी की शिकायत कहाँ जाएगी, यह इस पर निर्भर है कि झगड़ा किससे है '
                'और सोसाइटी किस क़ानून में पंजीकृत है। ज़्यादातर सहकारी आवास '
                'सोसाइटियाँ राज्य के सहकारी समिति अधिनियम में होती हैं; कुछ आरडब्ल्यूए '
                'सोसाइटी पंजीकरण अधिनियम में। पंजीकरण प्रमाण पत्र पर यह लिखा होता है।'
            : 'Where a society complaint goes depends on who the dispute is '
                'with and which law the society is registered under. Most '
                'co-operative housing societies come under the state '
                'Co-operative Societies Act; some RWAs under the Societies '
                'Registration Act. The registration certificate says which.'),
        ToolQuestion(hi ? 'झगड़ा किससे है' : 'Who is the dispute with'),
        SelectionTile(
          label: hi ? 'सोसाइटी की समिति से' : 'The society committee',
          subtitle: hi
              ? 'रख-रखाव शुल्क, हिसाब, चुनाव, सदस्यता'
              : 'Maintenance charges, accounts, elections, membership',
          selected: _with == SocietyWith.committee,
          onTap: () => setState(() => _with = SocietyWith.committee),
        ),
        SelectionTile(
          label: hi ? 'बिल्डर से' : 'The builder',
          subtitle: hi
              ? 'दरारें, रिसाव, सुविधाएँ नहीं, सोसाइटी नहीं बनाई'
              : 'Cracks, leaks, missing amenities, society never formed',
          selected: _with == SocietyWith.builder,
          onTap: () => setState(() => _with = SocietyWith.builder),
        ),
        SelectionTile(
          label: hi ? 'किसी दूसरे सदस्य से' : 'Another member',
          subtitle: hi
              ? 'ऊपर से रिसाव, पार्किंग, पालतू, शोर'
              : 'A leak from above, parking, pets, noise',
          selected: _with == SocietyWith.member,
          onTap: () => setState(() => _with = SocietyWith.member),
        ),
        if (_with == SocietyWith.committee) ...[
          ToolAnswer(
            headline: hi ? 'हिसाब देखना हर सदस्य का हक़ है' : 'Every member may see the accounts',
            detail: hi
                ? 'सहकारी सोसाइटी के क़ानूनों में हर सदस्य को हिसाब-किताब, ऑडिट '
                    'रिपोर्ट, बैठकों के कार्यवृत्त और उपनियम देखने तथा उनकी नक़ल लेने '
                    'का हक़ है। लिखित माँग से शुरू करें। हल न हो तो सहकारी समितियों के '
                    'उप/सहायक रजिस्ट्रार के पास शिकायत जाती है, जो उस वार्ड या ज़िले '
                    'की सोसाइटियाँ देखते हैं। कुछ राज्यों में सदस्य और सोसाइटी के '
                    'झगड़े सहकारी न्यायालय सुनता है।'
                : 'The co-operative laws give every member the right to '
                    'inspect and take copies of the accounts, the audit '
                    'report, the minutes and the bye-laws. Start with a '
                    'written request. If that fails, the complaint goes to '
                    'the Deputy or Assistant Registrar of Co-operative '
                    'Societies for that ward or district. In some states '
                    'disputes between a member and the society are heard by '
                    'a co-operative court.',
            tone: ToolTone.plain,
            icon: Icons.account_balance_outlined,
          ),
          ToolDonts(
            heading: hi ? 'ध्यान रखें' : 'Keep in mind',
            items: hi
                ? const [
                    'झगड़े के दौरान भी रख-रखाव शुल्क रोकें नहीं — बकायेदार बनते ही '
                        'आपका पक्ष कमज़ोर होता है और वोट का हक़ भी जा सकता है',
                    'विवादित रक़म के बारे में लिखकर दें कि "विरोध के साथ" दे रहे हैं',
                    'समिति पानी, बिजली या लिफ़्ट रोककर बकाया वसूल नहीं कर सकती — '
                        'वसूली का क़ानूनी रास्ता रजिस्ट्रार के ज़रिये है',
                  ]
                : const [
                    'Do not withhold maintenance during the dispute - the '
                        'moment you are a defaulter your case weakens and you '
                        'can lose your vote',
                    'For a disputed amount, write that you are paying it '
                        '"under protest"',
                    'The committee may not cut water, power or the lift to '
                        'recover dues - the legal route for recovery runs '
                        'through the Registrar',
                  ],
          ),
        ],
        if (_with == SocietyWith.builder)
          ToolAnswer(
            headline: hi
                ? '$reraDefectYears साल तक ढाँचे की ख़राबी बिल्डर की'
                : 'Structural defects are the builder\'s for $reraDefectYears years',
            detail: hi
                ? 'रेरा (भू-संपदा विनियमन अधिनियम 2016) के अनुसार क़ब्ज़ा मिलने के '
                    '$reraDefectYears साल के भीतर ढाँचे की कोई ख़राबी, या काम की '
                    'गुणवत्ता की कमी सामने आए तो बिल्डर को उसे 30 दिन में मुफ़्त ठीक '
                    'करना होता है। शिकायत राज्य रेरा प्राधिकरण में ऑनलाइन होती है, '
                    'और परियोजना की रेरा संख्या आपके समझौते पर छपी होती है। सोसाइटी न '
                    'बनाना और रख-रखाव न सौंपना भी रेरा में बिल्डर की ज़िम्मेदारी है। '
                    'पुरानी परियोजना रेरा में पंजीकृत न हो तो उपभोक्ता आयोग का रास्ता '
                    'है।'
                : 'Under RERA (the Real Estate (Regulation and Development) '
                    'Act 2016), if a structural defect or a defect in '
                    'workmanship comes to light within $reraDefectYears '
                    'years of possession, the builder must fix it free '
                    'within 30 days. The complaint is filed online with the '
                    'state RERA authority, and the project\'s RERA number is '
                    'printed on your agreement. Forming the society and '
                    'handing over maintenance are also the builder\'s duties '
                    'under RERA. For an older project not registered under '
                    'RERA, the route is the consumer commission.',
            tone: ToolTone.good,
            icon: Icons.apartment_outlined,
          ),
        if (_with == SocietyWith.member)
          ToolAnswer(
            headline: hi ? 'पहले समिति, फिर बाहर' : 'The committee first, then outside',
            detail: hi
                ? 'दो सदस्यों के बीच की बात — जैसे ऊपर के फ़्लैट से रिसाव — पहले '
                    'समिति के सामने लिखित में रखें। उपनियमों में आम तौर पर लिखा होता '
                    'है कि किस मरम्मत का ख़र्च कौन उठाएगा, और समिति उसे देखने के लिए '
                    'जाँच करा सकती है। समिति कुछ न करे तो रजिस्ट्रार के पास वही '
                    'रास्ता है। पानी या दीवार से नुक़सान बड़ा हो तो दीवानी अदालत, और '
                    'छोटा हो तो लोक अदालत — मुफ़्त और आपसी सहमति से।'
                : 'A matter between two members - say a leak from the flat '
                    'above - goes to the committee in writing first. The '
                    'bye-laws usually say who bears which repair, and the '
                    'committee can have it inspected. If the committee does '
                    'nothing, the same route through the Registrar is open. '
                    'For serious damage from water or a wall, a civil court; '
                    'for a small one, a Lok Adalat - free and by agreement.',
            tone: ToolTone.plain,
            icon: Icons.people_outline,
          ),
        if (_with != null) ...[
          const SizedBox(height: 10),
          ToolNote(hi
              ? 'हर क़दम लिखित में और रसीद के साथ। सोसाइटी के व्हाट्सऐप समूह में '
                  'हुई बात शिकायत नहीं मानी जाती — वह सिर्फ़ सहायक सबूत है।'
              : 'Every step in writing, with a receipt. A conversation on '
                  'the society\'s WhatsApp group is not a complaint - only '
                  'supporting evidence.'),
          const SourceNote(
              text: 'National Consumer Helpline', url: _consumerUrl),
        ],
      ],
    );
  }
}
