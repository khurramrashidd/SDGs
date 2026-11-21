import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Four screens that turn an electricity bill into something a household
/// can act on.
///
/// None of these carries a tariff. Rates differ by state, by slab and by
/// category, and they change every year, so every screen here asks the
/// household for the rate printed on its own bill and does the arithmetic
/// from that. A figure the reader supplies cannot go stale.

const _beeUrl = 'https://www.beeindia.gov.in/';
const _ujalaUrl = 'https://www.eeslindia.org/';

/// A household appliance, with the wattage it typically draws. These are
/// ordinary ratings, not a standard, and the screen says so - a fifteen
/// year old fan draws considerably more than a new one.
class Appliance {
  final String en;
  final String hi;
  final int watts;

  /// A fridge runs on a thermostat rather than continuously, so hours of
  /// use mean nothing for it. For those, units a month is given directly.
  final int? unitsAMonth;
  const Appliance(this.en, this.hi, this.watts, {this.unitsAMonth});
}

const appliances = [
  Appliance('Ceiling fan', 'पंखा', 70),
  Appliance('LED bulb', 'एलईडी बल्ब', 9),
  Appliance('Tube light', 'ट्यूबलाइट', 40),
  Appliance('Old filament bulb', 'पुराना पीला बल्ब', 60),
  Appliance('Television', 'टीवी', 100),
  Appliance('Refrigerator', 'फ़्रिज', 150, unitsAMonth: 40),
  Appliance('Air cooler', 'कूलर', 200),
  Appliance('Washing machine', 'वॉशिंग मशीन', 500),
  Appliance('Mixer grinder', 'मिक्सी', 500),
  Appliance('Electric iron', 'इस्तरी', 1000),
  Appliance('Water pump, 1 HP', 'पानी की मोटर, 1 एचपी', 750),
  Appliance('Geyser', 'गीज़र', 2000),
  Appliance('Air conditioner, 1.5 ton', 'एसी, 1.5 टन', 1500),
];

/// Units (kWh) a month for a load of [watts] run [hoursADay] hours a day.
double unitsAMonth(int watts, double hoursADay) =>
    watts * hoursADay * 30 / 1000;

class AppliancePage extends StatefulWidget {
  const AppliancePage({super.key});

  @override
  State<AppliancePage> createState() => _AppliancePageState();
}

class _AppliancePageState extends State<AppliancePage> {
  Appliance? _appliance;
  final _hours = TextEditingController(text: '6');
  final _count = TextEditingController(text: '1');
  final _rate = TextEditingController();

  @override
  void dispose() {
    _hours.dispose();
    _count.dispose();
    _rate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final hours = double.tryParse(_hours.text.trim()) ?? 0;
    final count = int.tryParse(_count.text.trim()) ?? 1;
    final rate = double.tryParse(_rate.text.trim());
    final a = _appliance;
    final units = a == null
        ? null
        : (a.unitsAMonth != null
            ? a.unitsAMonth! * count.toDouble()
            : unitsAMonth(a.watts, hours) * count);
    final cost = (units != null && rate != null && rate > 0)
        ? units * rate
        : null;

    return ToolScaffold(
      goal: 7,
      title: hi ? 'कौन सी चीज़ कितना बिल बनाती है' : 'What each appliance costs a month',
      children: [
        ToolNote(hi
            ? 'बिजली का बिल यूनिट में बनता है, और एक यूनिट का मतलब है 1000 वाट एक '
                'घंटे तक। यहाँ दर नहीं लिखी है — अपने बिल पर छपी दर डालिए, क्योंकि '
                'वह राज्य, स्लैब और श्रेणी के हिसाब से अलग होती है।'
            : 'An electricity bill is made of units, and one unit is 1000 '
                'watts for one hour. There is no tariff on this screen - put '
                'in the rate printed on your own bill, because it differs by '
                'state, by slab and by category.'),
        ToolQuestion(hi ? 'कौन सी चीज़' : 'Which appliance'),
        for (final item in appliances)
          SelectionTile(
            label: hi ? item.hi : item.en,
            subtitle: '${item.watts} W',
            selected: _appliance?.en == item.en,
            onTap: () => setState(() => _appliance = item),
          ),
        if (a != null) ...[
          ToolQuestion(hi ? 'कितने और कितनी देर' : 'How many, and how long'),
          Row(
            children: [
              Expanded(
                child: ToolNumber(
                  controller: _count,
                  label: hi ? 'कितने' : 'How many',
                  maxDigits: 2,
                  icon: Icons.tag,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              if (a.unitsAMonth == null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ToolNumber(
                    controller: _hours,
                    label: hi ? 'घंटे रोज़' : 'Hours a day',
                    decimal: true,
                    maxDigits: 4,
                    icon: Icons.schedule,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ],
          ),
          if (a.unitsAMonth != null)
            ToolNote(hi
                ? 'फ़्रिज थर्मोस्टैट से चलता है — वह चौबीसों घंटे लगा रहता है लेकिन '
                    'मोटर रुक-रुककर चलती है। इसलिए इसमें घंटे नहीं पूछे जाते; महीने की '
                    'खपत सीधे दी गई है।'
                : 'A fridge runs on a thermostat - it is on all day but the '
                    'motor cycles. So hours mean nothing for it, and the '
                    'monthly consumption is given directly.'),
          ToolQuestion(hi ? 'बिल पर छपी दर' : 'The rate on your bill'),
          ToolNumber(
            controller: _rate,
            label: hi ? '₹ प्रति यूनिट' : '₹ per unit',
            decimal: true,
            maxDigits: 5,
            icon: Icons.currency_rupee,
            onChanged: (_) => setState(() {}),
          ),
          if (units != null && units > 0)
            ToolAnswer(
              headline: cost != null
                  ? (hi
                      ? 'महीने के लगभग ₹${cost.round()}'
                      : 'About ₹${cost.round()} a month')
                  : (hi
                      ? 'महीने में ${units.toStringAsFixed(1)} यूनिट'
                      : '${units.toStringAsFixed(1)} units a month'),
              detail: hi
                  ? 'महीने में ${units.toStringAsFixed(1)} यूनिट'
                      '${cost != null ? ', और साल के लगभग ₹${(cost * 12).round()}' : ''}'
                      '। ये वाट आम रेटिंग हैं — पुरानी चीज़ें इससे ज़्यादा खींचती हैं, '
                      'और चीज़ पर लगी प्लेट पर उसका असली वाट लिखा होता है।'
                  : '${units.toStringAsFixed(1)} units a month'
                      '${cost != null ? ', and about ₹${(cost * 12).round()} a year' : ''}'
                      '. These wattages are ordinary ratings - an old '
                      'appliance draws more, and the plate on the appliance '
                      'gives its real figure.',
              tone: ToolTone.plain,
              icon: Icons.bolt_outlined,
            ),
          const SizedBox(height: 14),
          Text(hi ? 'बिल कहाँ से बनता है' : 'Where the bill comes from',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          if (rate != null && rate > 0)
            for (final item in appliances.take(8))
              ToolLine(
                  hi ? item.hi : item.en,
                  item.unitsAMonth != null
                      ? '₹${(item.unitsAMonth! * rate).round()}'
                      : '₹${(unitsAMonth(item.watts, 6) * rate).round()}',
                  strong: item.en == a.en)
          else
            ToolNote(hi
                ? 'ऊपर दर डालिए तो यहाँ हर चीज़ का महीने का ख़र्च दिख जाएगा, छह घंटे '
                    'रोज़ के हिसाब से।'
                : 'Put the rate in above and this shows the monthly cost of '
                    'each, reckoned at six hours a day.'),
          const SizedBox(height: 8),
          ToolNote(hi
              ? 'गीज़र, इस्तरी और एसी — बिल में सबसे बड़ा हिस्सा आमतौर पर इन्हीं का '
                  'होता है, भले ही ये थोड़ी देर चलते हों। पंखे और बल्ब देर तक चलते हैं '
                  'लेकिन कम खींचते हैं।'
              : 'Geyser, iron and air conditioner usually make the largest '
                  'part of a bill even though they run briefly. Fans and '
                  'bulbs run for hours but draw little.'),
          const SourceNote(
              text: 'Bureau of Energy Efficiency', url: _beeUrl),
        ],
      ],
    );
  }
}

// --- Meter running fast -----------------------------------------------

class MeterTestPage extends StatefulWidget {
  const MeterTestPage({super.key});

  @override
  State<MeterTestPage> createState() => _MeterTestPageState();
}

class _MeterTestPageState extends State<MeterTestPage> {
  final _thisMonth = TextEditingController();
  final _usual = TextEditingController();
  bool _changedAnything = false;

  @override
  void dispose() {
    _thisMonth.dispose();
    _usual.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final now = double.tryParse(_thisMonth.text.trim());
    final usual = double.tryParse(_usual.text.trim());
    final times =
        (now != null && usual != null && usual > 0) ? now / usual : null;

    return ToolScaffold(
      goal: 7,
      title: hi ? 'मीटर तेज़ चल रहा है' : 'The meter is running fast',
      children: [
        ToolNote(hi
            ? 'मीटर की जाँच कराना आपका हक़ है और इसकी व्यवस्था हर राज्य के बिजली '
                'नियामक आयोग ने बना रखी है। लेकिन जाँच से पहले एक घंटा अपने घर में '
                'लगाइए — ज़्यादातर मामलों में वजह मीटर नहीं, कुछ और निकलती है, और '
                'जाँच का शुल्क भी बच जाता है।'
            : 'Getting the meter tested is your right, and every state '
                'electricity regulator provides for it. But spend an hour in '
                'your own house first - in most cases the cause turns out not '
                'to be the meter, and you save the testing fee as well.'),
        ToolQuestion(hi ? 'यूनिट की तुलना' : 'Compare the units'),
        ToolNumber(
          controller: _thisMonth,
          label: hi ? 'इस बार की यूनिट' : 'Units this time',
          decimal: true,
          maxDigits: 6,
          icon: Icons.bolt_outlined,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolNumber(
          controller: _usual,
          label: hi ? 'आमतौर पर कितनी यूनिट' : 'Units usually',
          decimal: true,
          maxDigits: 6,
          icon: Icons.history,
          onChanged: (_) => setState(() {}),
        ),
        SwitchListTile(
          value: _changedAnything,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'घर में कुछ नया आया या मौसम बदला'
              : 'Something new in the house, or the season changed'),
          subtitle: Text(
            hi
                ? 'नया फ़्रिज, कूलर, मोटर, या मेहमान रुके'
                : 'A new fridge, cooler, motor, or guests staying',
            style: const TextStyle(fontSize: 12),
          ),
          onChanged: (v) => setState(() => _changedAnything = v),
        ),
        if (times != null) ...[
          ToolAnswer(
            headline: hi
                ? 'आम खपत से ${times.toStringAsFixed(1)} गुना'
                : '${times.toStringAsFixed(1)} times the usual',
            detail: _changedAnything
                ? (hi
                    ? 'घर में कुछ बदला है, इसलिए पहले यह देखिए कि नई चीज़ कितनी यूनिट '
                        'खींचती है — इसी लक्ष्य में "कौन सी चीज़ कितना बिल बनाती है" '
                        'में हिसाब लगा लीजिए। कूलर या मोटर अकेले बिल दोगुना कर सकते '
                        'हैं, और वह मीटर की ख़राबी नहीं है।'
                    : 'Something has changed in the house, so first work out '
                        'what the new thing draws - use "What each appliance '
                        'costs" in this goal. A cooler or a motor alone can '
                        'double a bill, and that is not a faulty meter.')
                : (hi
                    ? 'कुछ बदला नहीं और खपत इतनी बढ़ी है, तो नीचे की जाँच एक-एक करके '
                        'कीजिए। आख़िरी क़दम मीटर की जाँच है।'
                    : 'With nothing changed and consumption up this much, '
                        'work down the checks below. Testing the meter is the '
                        'last step.'),
            tone: times >= 1.5 ? ToolTone.warn : ToolTone.plain,
            icon: Icons.speed_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'पहले यह देखें' : 'Check these first',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const ToolChecklist(
            storageKey: 'meter_check_v1',
            items: [
              CheckItem('off', 'Switch off everything in the house at the '
                  'mains, then watch the meter for ten minutes',
                  'घर की मेन स्विच बंद करके दस मिनट मीटर देखें',
                  noteEn: 'If it still counts up with everything off, that is '
                      'the strongest evidence there is - note the reading '
                      'before and after, with the time.',
                  noteHi: 'सब बंद होने पर भी गिनती बढ़े तो यही सबसे मज़बूत सबूत है — '
                      'पहले और बाद की रीडिंग समय के साथ लिख लें।'),
              CheckItem('tap', 'Check the water motor - a motor left running '
                  'or a leaking foot valve is the commonest hidden load',
                  'पानी की मोटर देखें — चालू छूट जाना या फ़ुट वाल्व का रिसाव सबसे '
                      'आम छिपा हुआ ख़र्च है'),
              CheckItem('geyser', 'Check the geyser - left on, it runs all '
                  'day', 'गीज़र देखें — चालू छूट जाए तो दिन भर चलता रहता है'),
              CheckItem('theft', 'Check whether anyone has taken a line from '
                  'your meter or your pole',
                  'देखें कि आपके मीटर या खंभे से किसी ने लाइन तो नहीं ली है'),
              CheckItem('reading', 'Compare the reading on the bill with the '
                  'meter right now', 'बिल की रीडिंग अभी मीटर से मिलाएँ'),
              CheckItem('estimated', 'Check whether the bill says estimated '
                  'or average', 'देखें कि बिल "अनुमानित" या "औसत" तो नहीं है'),
              CheckItem('arrears', 'Check whether old arrears are included',
                  'देखें कि पुरानी बकाया रक़म जुड़ी तो नहीं'),
            ],
          ),
          ToolAnswer(
            headline: hi ? 'मीटर की जाँच कराना' : 'Getting the meter tested',
            detail: hi
                ? 'बिजली कंपनी के उपखंड कार्यालय में लिखित अर्ज़ी दें और पावती लें। '
                    'जाँच का शुल्क लगता है, लेकिन मीटर ख़राब निकला तो आमतौर पर शुल्क '
                    'लौटाया जाता है और बिल भी सुधारा जाता है। शुल्क और समय-सीमा आपके '
                    'राज्य के विद्युत नियामक आयोग ने तय कर रखी है — अर्ज़ी देते समय '
                    '"स्टैंडर्ड्स ऑफ़ परफ़ॉर्मेंस" का हवाला देकर पूछिए कि कितने दिन में '
                    'जाँच होगी।'
                : 'Give a written application at the electricity company\'s '
                    'sub-division office and take the acknowledgement. There '
                    'is a testing fee, but if the meter is found faulty the '
                    'fee is usually returned and the bill corrected. The fee '
                    'and the time limit are fixed by your state electricity '
                    'regulator - when you apply, cite the "standards of '
                    'performance" and ask within how many days the test is '
                    'due.',
            tone: ToolTone.plain,
            icon: Icons.fact_check_outlined,
          ),
          ToolNote(hi
              ? 'विवाद चलने तक बिना विवाद वाली रक़म जमा करते रहें — इससे कनेक्शन कटने '
                  'का ख़तरा नहीं रहता, और शिकायत कमज़ोर भी नहीं पड़ती।'
              : 'While the dispute runs, keep paying the undisputed part - it '
                  'keeps the connection from being cut, and it does not '
                  'weaken the complaint.'),
        ],
      ],
    );
  }
}

// --- Star rating ------------------------------------------------------

class StarRatingPage extends StatefulWidget {
  const StarRatingPage({super.key});

  @override
  State<StarRatingPage> createState() => _StarRatingPageState();
}

class _StarRatingPageState extends State<StarRatingPage> {
  final _cheapPrice = TextEditingController();
  final _starPrice = TextEditingController();
  final _cheapWatts = TextEditingController();
  final _starWatts = TextEditingController();
  final _hours = TextEditingController(text: '8');
  final _rate = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _cheapPrice,
      _starPrice,
      _cheapWatts,
      _starWatts,
      _hours,
      _rate
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final pc = double.tryParse(_cheapPrice.text.trim()) ?? 0;
    final ps = double.tryParse(_starPrice.text.trim()) ?? 0;
    final wc = double.tryParse(_cheapWatts.text.trim()) ?? 0;
    final ws = double.tryParse(_starWatts.text.trim()) ?? 0;
    final hours = double.tryParse(_hours.text.trim()) ?? 0;
    final rate = double.tryParse(_rate.text.trim()) ?? 0;

    final extra = ps - pc;
    final savedUnitsAMonth = (wc - ws) * hours * 30 / 1000;
    final savedRupeesAMonth = savedUnitsAMonth * rate;
    final months = (extra > 0 && savedRupeesAMonth > 0)
        ? extra / savedRupeesAMonth
        : null;

    return ToolScaffold(
      goal: 7,
      title: hi ? '5-स्टार वाली चीज़ महँगी पड़ती है?' : 'Is a 5-star appliance worth the extra',
      children: [
        ToolNote(hi
            ? 'स्टार रेटिंग का मतलब है कम बिजली में वही काम। महँगी चीज़ सस्ती तब '
                'पड़ती है जब बचत से अंतर निकल आए — और वह इस पर निर्भर है कि चीज़ कितनी '
                'देर चलती है। दिन में दस घंटे चलने वाले पंखे में अंतर जल्दी निकल आता '
                'है; महीने में दो बार चलने वाली चीज़ में कभी नहीं।'
            : 'A star rating means the same work on less electricity. The '
                'dearer one is cheaper only once the saving covers the '
                'difference - and that depends on how long it runs. On a fan '
                'running ten hours a day the difference comes back quickly; '
                'on something used twice a month, never.'),
        ToolQuestion(hi ? 'दाम' : 'The prices'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _cheapPrice,
                label: hi ? 'सस्ती वाली (₹)' : 'Cheaper (₹)',
                decimal: true,
                maxDigits: 7,
                icon: Icons.currency_rupee,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _starPrice,
                label: hi ? 'स्टार वाली (₹)' : 'Star-rated (₹)',
                decimal: true,
                maxDigits: 7,
                icon: Icons.currency_rupee,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        ToolQuestion(hi ? 'दोनों के वाट' : 'The wattage of each'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _cheapWatts,
                label: hi ? 'सस्ती (W)' : 'Cheaper (W)',
                decimal: true,
                maxDigits: 5,
                icon: Icons.bolt_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _starWatts,
                label: hi ? 'स्टार (W)' : 'Star-rated (W)',
                decimal: true,
                maxDigits: 5,
                icon: Icons.bolt_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        ToolNote(hi
            ? 'वाट चीज़ पर लगे स्टिकर या प्लेट पर लिखा होता है। एसी और फ़्रिज में '
                'वाट की जगह ISEER या सालाना यूनिट लिखी होती है — तब दुकानदार से '
                '"साल में कितनी यूनिट" पूछकर उसे 12 से भाग देकर महीने की यूनिट निकाल '
                'लीजिए।'
            : 'The wattage is on the sticker or plate on the appliance. For '
                'air conditioners and fridges you may see an ISEER or yearly '
                'units instead - then ask the shopkeeper for the units a '
                'year and divide by 12.'),
        ToolQuestion(hi ? 'कितनी देर चलेगी, और दर' : 'How long it runs, and the rate'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _hours,
                label: hi ? 'घंटे रोज़' : 'Hours a day',
                decimal: true,
                maxDigits: 4,
                icon: Icons.schedule,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _rate,
                label: hi ? '₹ प्रति यूनिट' : '₹ per unit',
                decimal: true,
                maxDigits: 5,
                icon: Icons.currency_rupee,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        if (months != null)
          ToolAnswer(
            headline: months <= 36
                ? (hi
                    ? 'अंतर ${months.round()} महीने में निकल आएगा'
                    : 'The extra comes back in ${months.round()} months')
                : (hi
                    ? 'अंतर निकलने में ${(months / 12).toStringAsFixed(1)} साल'
                    : '${(months / 12).toStringAsFixed(1)} years to come back'),
            detail: hi
                ? 'महीने में ₹${savedRupeesAMonth.round()} की बचत होगी '
                    '(${savedUnitsAMonth.toStringAsFixed(1)} यूनिट)। '
                    '${months <= 36 ? 'चीज़ इससे कई गुना ज़्यादा चलेगी, इसलिए स्टार वाली लेना फ़ायदे का है।' : 'इतने लंबे समय में चीज़ ख़राब भी हो सकती है और दाम भी बदल जाते हैं — इस मामले में सस्ती वाली बुरी नहीं।'}'
                : 'You save ₹${savedRupeesAMonth.round()} a month '
                    '(${savedUnitsAMonth.toStringAsFixed(1)} units). '
                    '${months <= 36 ? 'The appliance will last several times that, so the star-rated one pays.' : 'Over that long the appliance may fail and prices change anyway - the cheaper one is not a bad call here.'}',
            tone: months <= 36 ? ToolTone.good : ToolTone.warn,
            icon: Icons.star_outline,
          ),
        if (savedUnitsAMonth > 0 && rate > 0)
          ToolNote(hi
              ? 'दस साल में बचत लगभग ₹${(savedRupeesAMonth * 120).round()} बनती है। '
                  'यही वह संख्या है जो दुकान में कोई नहीं बताता।'
              : 'Over ten years the saving comes to about '
                  '₹${(savedRupeesAMonth * 120).round()}. That is the number '
                  'nobody mentions in the shop.'),
        const SourceNote(
            text: 'Bureau of Energy Efficiency - star labels', url: _beeUrl),
      ],
    );
  }
}

// --- LED swap ---------------------------------------------------------

class LedSwapPage extends StatefulWidget {
  const LedSwapPage({super.key});

  @override
  State<LedSwapPage> createState() => _LedSwapPageState();
}

class _LedSwapPageState extends State<LedSwapPage> {
  final _bulbs = TextEditingController(text: '4');
  final _tubes = TextEditingController(text: '2');
  final _hours = TextEditingController(text: '5');
  final _rate = TextEditingController();

  @override
  void dispose() {
    for (final c in [_bulbs, _tubes, _hours, _rate]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final bulbs = int.tryParse(_bulbs.text.trim()) ?? 0;
    final tubes = int.tryParse(_tubes.text.trim()) ?? 0;
    final hours = double.tryParse(_hours.text.trim()) ?? 0;
    final rate = double.tryParse(_rate.text.trim()) ?? 0;

    // 60 W filament -> 9 W LED; 40 W tube -> 20 W LED batten.
    final savedWatts = bulbs * (60 - 9) + tubes * (40 - 20);
    final unitsSaved = savedWatts * hours * 30 / 1000;
    final rupeesSaved = unitsSaved * rate;

    return ToolScaffold(
      goal: 7,
      title: hi ? 'एलईडी बदलने से क्या बचेगा' : 'What an LED swap saves',
      children: [
        ToolNote(hi
            ? 'यह बिजली बचाने का सबसे सस्ता तरीक़ा है, और अकेला ऐसा तरीक़ा जिसमें '
                'ख़र्च कुछ महीनों में निकल आता है। पुराना पीला बल्ब 60 वाट खींचता है, '
                'उतनी ही रोशनी का एलईडी 9 वाट।'
            : 'This is the cheapest way to cut a bill, and the only one where '
                'the cost comes back in months. An old filament bulb draws 60 '
                'watts; an LED giving the same light draws 9.'),
        ToolQuestion(hi ? 'घर में कितने' : 'How many in the house'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _bulbs,
                label: hi ? 'पुराने बल्ब' : 'Old bulbs',
                maxDigits: 3,
                icon: Icons.lightbulb_outline,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _tubes,
                label: hi ? 'पुरानी ट्यूबलाइट' : 'Old tube lights',
                maxDigits: 3,
                icon: Icons.light_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _hours,
                label: hi ? 'घंटे रोज़' : 'Hours a day',
                decimal: true,
                maxDigits: 4,
                icon: Icons.schedule,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _rate,
                label: hi ? '₹ प्रति यूनिट' : '₹ per unit',
                decimal: true,
                maxDigits: 5,
                icon: Icons.currency_rupee,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        if (savedWatts > 0 && hours > 0) ...[
          ToolAnswer(
            headline: rate > 0
                ? (hi
                    ? 'महीने में लगभग ₹${rupeesSaved.round()} की बचत'
                    : 'About ₹${rupeesSaved.round()} a month')
                : (hi
                    ? 'महीने में ${unitsSaved.toStringAsFixed(1)} यूनिट कम'
                    : '${unitsSaved.toStringAsFixed(1)} units a month less'),
            detail: hi
                ? '${unitsSaved.toStringAsFixed(1)} यूनिट महीने की बचत'
                    '${rate > 0 ? ', यानी साल के लगभग ₹${(rupeesSaved * 12).round()}' : ''}। '
                    'एलईडी बल्ब की क़ीमत आमतौर पर कुछ महीनों की बचत में निकल आती है, '
                    'और वे पुराने बल्बों से कई गुना ज़्यादा चलते हैं।'
                : '${unitsSaved.toStringAsFixed(1)} units a month'
                    '${rate > 0 ? ', which is about ₹${(rupeesSaved * 12).round()} a year' : ''}. '
                    'The price of the LEDs usually comes back within a few '
                    'months of saving, and they last many times longer than '
                    'the old bulbs.',
            tone: ToolTone.good,
            icon: Icons.lightbulb_outline,
          ),
          const SizedBox(height: 10),
          ToolLine(
              hi ? 'अभी की खपत' : 'What they draw now',
              hi
                  ? '${bulbs * 60 + tubes * 40} वाट'
                  : '${bulbs * 60 + tubes * 40} watts'),
          ToolLine(
              hi ? 'एलईडी के बाद' : 'After the swap',
              hi
                  ? '${bulbs * 9 + tubes * 20} वाट'
                  : '${bulbs * 9 + tubes * 20} watts',
              strong: true),
          ToolNote(hi
              ? 'ख़रीदते समय स्टार लेबल और वारंटी देख लें — बहुत सस्ते एलईडी कुछ ही '
                  'महीनों में जाते हैं और तब बचत का कोई मतलब नहीं रह जाता। बिजली '
                  'कंपनी या ईईएसएल की दुकानों पर अक्सर सस्ते और वारंटी वाले मिलते हैं।'
              : 'When buying, check the star label and the warranty - very '
                  'cheap LEDs fail in months and then the saving means '
                  'nothing. The electricity company\'s or EESL\'s counters '
                  'often have cheaper ones with a warranty.'),
          const SourceNote(
              text: 'Energy Efficiency Services Limited', url: _ujalaUrl),
        ],
      ],
    );
  }
}
