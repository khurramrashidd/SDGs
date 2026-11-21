import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Four calculators. These are the screens that need no sources at all,
/// because they do arithmetic on numbers the household supplies - and a
/// calculator cannot go stale.
///
/// The dripping tap one exists because a drip is invisible as a quantity.
/// Told that a tap wastes "a lot", nobody moves. Told that it is four
/// thousand litres a month, people fix the washer.

const _rainfallUrl = 'https://mausam.imd.gov.in/';
const _cgwbUrl = 'https://cgwb.gov.in/';

/// Share of roof rainfall that can actually be collected, after what the
/// roof soaks up, what evaporates and what the first flush throws away.
const roofRunoffFactor = 0.8;

// --- Rainwater --------------------------------------------------------

/// What the roof is made of. It changes how much actually runs off.
enum RoofKind { concrete, tin, tile, thatch }

double roofFactor(RoofKind k) => switch (k) {
      RoofKind.concrete => 0.85,
      RoofKind.tin => 0.9,
      RoofKind.tile => 0.75,
      RoofKind.thatch => 0.4,
    };

/// Litres a year from a roof, given its area in square metres and the
/// local annual rainfall in millimetres. One millimetre of rain on one
/// square metre is one litre, which is the whole of the arithmetic.
double rainwaterLitres(double roofAreaSqM, double rainfallMm, RoofKind kind) =>
    roofAreaSqM * rainfallMm * roofFactor(kind);

class RainwaterPage extends StatefulWidget {
  const RainwaterPage({super.key});

  @override
  State<RainwaterPage> createState() => _RainwaterPageState();
}

class _RainwaterPageState extends State<RainwaterPage> {
  final _length = TextEditingController();
  final _width = TextEditingController();
  final _rainfall = TextEditingController();
  RoofKind _kind = RoofKind.concrete;
  bool _feet = true;

  @override
  void dispose() {
    _length.dispose();
    _width.dispose();
    _rainfall.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final l = double.tryParse(_length.text.trim()) ?? 0;
    final w = double.tryParse(_width.text.trim()) ?? 0;
    final rain = double.tryParse(_rainfall.text.trim()) ?? 0;
    // Feet to metres, then to square metres.
    final areaSqM = _feet ? (l * 0.3048) * (w * 0.3048) : l * w;
    final litres = (areaSqM > 0 && rain > 0)
        ? rainwaterLitres(areaSqM, rain, _kind)
        : null;

    Widget roof(RoofKind k, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _kind == k,
          onTap: () => setState(() => _kind = k),
        );

    return ToolScaffold(
      goal: 6,
      title: hi ? 'छत से कितना पानी मिल सकता है' : 'How much your roof can collect',
      children: [
        ToolNote(hi
            ? 'पूरा हिसाब एक बात पर टिका है: एक वर्ग मीटर छत पर एक मिलीमीटर बारिश '
                'का मतलब है एक लीटर पानी। बाक़ी सब गुणा है। जो पानी छत से बहकर चला '
                'जाता है, वह साल भर की ज़रूरत का बड़ा हिस्सा हो सकता है।'
            : 'The whole calculation rests on one fact: one millimetre of '
                'rain on one square metre of roof is one litre of water. The '
                'rest is multiplication. What runs off a roof and is lost can '
                'be a large part of a year\'s needs.'),
        ToolQuestion(hi ? 'छत का नाप' : 'The roof'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _length,
                label: hi ? 'लंबाई' : 'Length',
                decimal: true,
                maxDigits: 5,
                icon: Icons.straighten,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _width,
                label: hi ? 'चौड़ाई' : 'Width',
                decimal: true,
                maxDigits: 5,
                icon: Icons.straighten,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        SwitchListTile(
          value: _feet,
          contentPadding: EdgeInsets.zero,
          title: Text(hi ? 'नाप फ़ुट में है' : 'The measurements are in feet'),
          subtitle: Text(hi ? 'बंद करें तो मीटर' : 'Off for metres',
              style: const TextStyle(fontSize: 12)),
          onChanged: (v) => setState(() => _feet = v),
        ),
        ToolQuestion(hi ? 'छत किसकी है' : 'What the roof is'),
        roof(RoofKind.concrete, 'Concrete', 'पक्की छत (कंक्रीट)'),
        roof(RoofKind.tin, 'Tin or metal sheet', 'टीन या चादर'),
        roof(RoofKind.tile, 'Tiles', 'खपरैल'),
        roof(RoofKind.thatch, 'Thatch', 'फूस'),
        ToolQuestion(hi ? 'साल भर की बारिश' : 'Yearly rainfall'),
        ToolNumber(
          controller: _rainfall,
          label: hi ? 'मिलीमीटर' : 'Millimetres',
          decimal: true,
          maxDigits: 5,
          icon: Icons.water_drop_outlined,
          onChanged: (_) => setState(() {}),
        ),
        ToolNote(hi
            ? 'अपने ज़िले की सालाना बारिश मौसम विभाग की वेबसाइट पर मिलती है, या '
                'कृषि विज्ञान केंद्र से। मोटे अंदाज़े के लिए: ज़्यादातर मैदानी ज़िलों में '
                'यह 700 से 1200 मिलीमीटर के बीच होती है।'
            : 'Your district\'s annual rainfall is on the meteorological '
                'department\'s site, or at the Krishi Vigyan Kendra. As a '
                'rough guide, most plains districts fall between 700 and '
                '1200 millimetres.'),
        if (litres != null) ...[
          ToolAnswer(
            headline: hi
                ? 'साल में लगभग ${litres.round()} लीटर'
                : 'About ${litres.round()} litres a year',
            detail: hi
                ? 'यानी महीने का औसत लगभग ${(litres / 12).round()} लीटर, हालाँकि '
                    'असल में यह बारिश के महीनों में आता है। चार लोगों के परिवार की '
                    'पीने और खाना बनाने की ज़रूरत साल भर में लगभग 15,000 लीटर होती है '
                    '— इस हिसाब से देखिए कि आपकी छत कितना हिस्सा दे सकती है।'
                : 'That averages about ${(litres / 12).round()} litres a '
                    'month, though in truth it arrives in the rainy months. A '
                    'family of four needs roughly 15,000 litres a year for '
                    'drinking and cooking - which gives you a sense of what '
                    'share your roof could cover.',
            tone: ToolTone.good,
            icon: Icons.roofing_outlined,
          ),
          const SizedBox(height: 10),
          ToolLine(hi ? 'छत का क्षेत्रफल' : 'Roof area',
              hi
                  ? '${areaSqM.toStringAsFixed(1)} वर्ग मीटर'
                  : '${areaSqM.toStringAsFixed(1)} sq m'),
          ToolLine(
              hi ? 'एक दिन की तेज़ बारिश (50 मिमी) में' : 'In one heavy day (50 mm)',
              hi
                  ? '${rainwaterLitres(areaSqM, 50, _kind).round()} लीटर'
                  : '${rainwaterLitres(areaSqM, 50, _kind).round()} litres',
              strong: true),
          const SizedBox(height: 14),
          Text(hi ? 'इकट्ठा करने के लिए' : 'To actually collect it',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'छत के किनारे पर नाली (गटर) और एक पाइप — यही सबसे बड़ा ख़र्च है, '
                        'और सबसे ज़रूरी।',
                    'पहली बारिश का पानी छोड़ दें। छत पर जमी धूल, पत्ते और पक्षियों की '
                        'बीट उसी में बह जाती है। इसके लिए पाइप में एक छोटा "फ़र्स्ट '
                        'फ़्लश" वाल्व लगता है, या पहले दस मिनट पाइप हटा दीजिए।',
                    'पाइप के मुँह पर जाली लगाएँ ताकि पत्ते और कीड़े न जाएँ।',
                    'टंकी ढकी हो — खुली टंकी में मच्छर पलते हैं, और यही डेंगू की जड़ '
                        'है।',
                    'पीने के लिए इस्तेमाल करना हो तो उबालें या क्लोरीन डालें; नहाने, '
                        'धोने, जानवरों और खेत के लिए सीधे चलता है।',
                    'ज़्यादा पानी हो तो उसे सोख़्ता गड्ढे या पुराने कुएँ में डालें — इससे '
                        'भूजल बढ़ता है और आसपास के हैंडपंप भी गर्मी में देर तक चलते हैं।',
                  ]
                : const [
                    'A gutter along the roof edge and a down pipe - the main '
                        'cost, and the essential part.',
                    'Throw away the first rain. The dust, leaves and bird '
                        'droppings on the roof go with it. A small '
                        '"first flush" valve in the pipe does this, or just '
                        'swing the pipe aside for the first ten minutes.',
                    'Put a mesh on the pipe mouth to keep leaves and insects '
                        'out.',
                    'Keep the tank covered - an open tank breeds mosquitoes, '
                        'and that is where dengue starts.',
                    'For drinking, boil or chlorinate it; for bathing, '
                        'washing, animals and the field it is fine as it is.',
                    'Put the surplus into a soak pit or an old well - it '
                        'raises the groundwater, and the handpumps nearby '
                        'then last longer into the summer.',
                  ],
          ),
          const SourceNote(
              text: 'India Meteorological Department - rainfall',
              url: _rainfallUrl),
          const SourceNote(
              text: 'Central Ground Water Board - recharge guidance',
              url: _cgwbUrl),
        ],
      ],
    );
  }
}

// --- Dripping tap -----------------------------------------------------

/// How fast it is going. Litres per hour for each, from the usual
/// household measurements.
enum DripRate { slowDrip, fastDrip, trickle, thinStream }

double dripLitresPerHour(DripRate r) => switch (r) {
      DripRate.slowDrip => 0.3,
      DripRate.fastDrip => 1.0,
      DripRate.trickle => 4.0,
      DripRate.thinStream => 12.0,
    };

class DrippingTapPage extends StatefulWidget {
  const DrippingTapPage({super.key});

  @override
  State<DrippingTapPage> createState() => _DrippingTapPageState();
}

class _DrippingTapPageState extends State<DrippingTapPage> {
  DripRate? _rate;
  final _taps = TextEditingController(text: '1');
  final _tankerPrice = TextEditingController();

  @override
  void dispose() {
    _taps.dispose();
    _tankerPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final taps = int.tryParse(_taps.text.trim()) ?? 1;
    final perMonth =
        _rate == null ? null : dripLitresPerHour(_rate!) * 24 * 30 * taps;
    final price = double.tryParse(_tankerPrice.text.trim());
    // A common tanker is 5,000 litres.
    final rupees = (perMonth != null && price != null && price > 0)
        ? perMonth / 5000 * price
        : null;

    Widget rate(DripRate r, String en, String h, String sub, String subHi) =>
        SelectionTile(
          label: hi ? h : en,
          subtitle: hi ? subHi : sub,
          selected: _rate == r,
          onTap: () => setState(() => _rate = r),
        );

    return ToolScaffold(
      goal: 6,
      title: hi ? 'टपकता नल कितना ले जाता है' : 'What a dripping tap costs',
      children: [
        ToolNote(hi
            ? 'टपकते नल को कोई इसलिए नहीं ठीक कराता कि नुक़सान दिखता नहीं। बूँद-बूँद '
                'का हिसाब महीने में हज़ारों लीटर बन जाता है, और वाशर पाँच रुपये का '
                'होता है।'
            : 'Nobody fixes a dripping tap because the loss is invisible. '
                'Drop by drop it comes to thousands of litres in a month, and '
                'the washer costs five rupees.'),
        ToolQuestion(hi ? 'कितनी तेज़ी से टपक रहा है' : 'How fast is it going'),
        rate(DripRate.slowDrip, 'A slow drip', 'धीरे-धीरे बूँद',
            'A drop every few seconds', 'कुछ सेकंड में एक बूँद'),
        rate(DripRate.fastDrip, 'A steady drip', 'लगातार बूँदें',
            'About one drop a second', 'लगभग हर सेकंड एक बूँद'),
        rate(DripRate.trickle, 'A constant trickle', 'पतली धार लगातार',
            'Drops running into each other', 'बूँदें आपस में मिलती हुई'),
        rate(DripRate.thinStream, 'A thin stream', 'पतली धारा',
            'It never stops running', 'बहना रुकता ही नहीं'),
        ToolQuestion(hi ? 'ऐसे कितने नल हैं' : 'How many taps like this'),
        ToolNumber(
          controller: _taps,
          label: hi ? 'नल' : 'Taps',
          maxDigits: 2,
          icon: Icons.water_damage_outlined,
          onChanged: (_) => setState(() {}),
        ),
        if (perMonth != null) ...[
          ToolAnswer(
            headline: hi
                ? 'महीने में ${perMonth.round()} लीटर'
                : '${perMonth.round()} litres a month',
            detail: hi
                ? 'यानी दिन के ${(perMonth / 30).round()} लीटर, और साल के '
                    '${(perMonth * 12).round()} लीटर। एक बाल्टी 20 लीटर की होती है, '
                    'तो यह महीने में लगभग ${(perMonth / 20).round()} बाल्टी है।'
                : 'That is ${(perMonth / 30).round()} litres a day and '
                    '${(perMonth * 12).round()} litres a year. A bucket is 20 '
                    'litres, so it comes to about '
                    '${(perMonth / 20).round()} buckets a month.',
            tone: ToolTone.warn,
            icon: Icons.water_drop_outlined,
          ),
          ToolQuestion(hi
              ? 'अगर टैंकर ख़रीदते हैं तो उसका दाम'
              : 'If you buy tanker water, its price'),
          ToolNumber(
            controller: _tankerPrice,
            label: hi ? 'एक टैंकर का दाम (₹)' : 'Price of one tanker (₹)',
            decimal: true,
            maxDigits: 6,
            icon: Icons.currency_rupee,
            onChanged: (_) => setState(() {}),
          ),
          if (rupees != null)
            ToolAnswer(
              headline: hi
                  ? 'महीने के लगभग ₹${rupees.round()}'
                  : 'About ₹${rupees.round()} a month',
              detail: hi
                  ? '5,000 लीटर के टैंकर के हिसाब से। साल का लगभग '
                      '₹${(rupees * 12).round()}। वाशर बदलवाने में इससे बहुत कम लगता '
                      'है।'
                  : 'Reckoned on a 5,000 litre tanker. About '
                      '₹${(rupees * 12).round()} a year. Changing the washer '
                      'costs a small fraction of that.',
              tone: ToolTone.bad,
              icon: Icons.currency_rupee,
            ),
          const SizedBox(height: 14),
          Text(hi ? 'और कहाँ से जाता है' : 'Where else it goes',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            numbered: false,
            steps: hi
                ? const [
                    'टंकी का ओवरफ़्लो — मोटर चालू छोड़ देने से सबसे ज़्यादा पानी यहीं '
                        'बहता है। टंकी में फ़्लोट वाल्व लगवाने से यह अपने आप रुक जाता है।',
                    'नल के नीचे का रिसाव और ज़मीन के नीचे की पाइप का रिसाव — मीटर '
                        'वाली जाँच से पकड़ा जाता है',
                    'बर्तन और सब्ज़ी बहते पानी के नीचे धोना — भरकर धोने से आधे से कम '
                        'में काम हो जाता है',
                    'नहाने में शॉवर की जगह बाल्टी — लगभग आधा पानी बचता है',
                  ]
                : const [
                    'Tank overflow - more water runs away here than anywhere '
                        'else, from a motor left running. A float valve in the '
                        'tank stops it by itself.',
                    'Leaks under the tap and in the pipe underground - caught '
                        'by the meter test',
                    'Washing vessels and vegetables under a running tap - a '
                        'filled vessel does it in less than half',
                    'A bucket instead of a shower - roughly half the water',
                  ],
          ),
        ],
      ],
    );
  }
}

// --- Daily water need -------------------------------------------------

/// Daily litres for one animal, by kind. Drinking and basic washing.
enum Livestock { cow, buffalo, goat, poultry }

int livestockLitres(Livestock a) => switch (a) {
      Livestock.cow => 50,
      Livestock.buffalo => 70,
      Livestock.goat => 6,
      Livestock.poultry => 1,
    };

class DailyWaterNeedPage extends StatefulWidget {
  const DailyWaterNeedPage({super.key});

  @override
  State<DailyWaterNeedPage> createState() => _DailyWaterNeedPageState();
}

class _DailyWaterNeedPageState extends State<DailyWaterNeedPage> {
  final _people = TextEditingController();
  final _cows = TextEditingController();
  final _buffalo = TextEditingController();
  final _goats = TextEditingController();
  final _birds = TextEditingController();

  @override
  void dispose() {
    _people.dispose();
    _cows.dispose();
    _buffalo.dispose();
    _goats.dispose();
    _birds.dispose();
    super.dispose();
  }

  int _n(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final people = _n(_people);
    final human = people * 55;
    final animals = _n(_cows) * livestockLitres(Livestock.cow) +
        _n(_buffalo) * livestockLitres(Livestock.buffalo) +
        _n(_goats) * livestockLitres(Livestock.goat) +
        _n(_birds) * livestockLitres(Livestock.poultry);
    final total = human + animals;

    return ToolScaffold(
      goal: 6,
      title: hi ? 'घर की रोज़ की पानी की ज़रूरत' : 'Your household\'s daily water need',
      children: [
        ToolNote(hi
            ? 'यह हिसाब दो कामों का है: एक, यह जानना कि भंडारण कितना चाहिए — टंकी, '
                'ड्रम, मटके; और दो, शिकायत में यह लिखना कि मानक से कितना बनता है और '
                'मिलता कितना है।'
            : 'This serves two purposes: knowing how much storage you need - '
                'tank, drums, pots - and being able to say in a complaint '
                'what the standard comes to against what you actually get.'),
        ToolQuestion(hi ? 'घर के लोग' : 'People in the house'),
        ToolNumber(
          controller: _people,
          label: hi ? 'कितने लोग' : 'How many',
          maxDigits: 3,
          icon: Icons.groups_outlined,
          onChanged: (_) => setState(() {}),
        ),
        ToolQuestion(hi ? 'जानवर' : 'Animals'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _cows,
                label: hi ? 'गाय' : 'Cows',
                maxDigits: 3,
                icon: Icons.pets_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _buffalo,
                label: hi ? 'भैंस' : 'Buffalo',
                maxDigits: 3,
                icon: Icons.pets_outlined,
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
                controller: _goats,
                label: hi ? 'बकरी' : 'Goats',
                maxDigits: 3,
                icon: Icons.pets_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _birds,
                label: hi ? 'मुर्गी' : 'Poultry',
                maxDigits: 4,
                icon: Icons.egg_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        if (total > 0) ...[
          ToolAnswer(
            headline: hi ? 'रोज़ लगभग $total लीटर' : 'About $total litres a day',
            detail: hi
                ? 'इसमें लोगों के लिए $human लीटर'
                    '${animals > 0 ? ' और जानवरों के लिए $animals लीटर' : ''}। '
                    'महीने का लगभग ${total * 30} लीटर।'
                : 'That is $human litres for the people'
                    '${animals > 0 ? ' and $animals for the animals' : ''}. '
                    'About ${total * 30} litres a month.',
            tone: ToolTone.plain,
            icon: Icons.water_drop_outlined,
          ),
          const SizedBox(height: 10),
          ToolLine(
              hi ? 'लोग, 55 लीटर प्रति व्यक्ति' : 'People, at 55 litres each',
              hi ? '$human लीटर' : '$human litres',
              strong: true),
          if (animals > 0)
            ToolLine(hi ? 'जानवर' : 'Animals',
                hi ? '$animals लीटर' : '$animals litres'),
          ToolLine(
              hi ? 'दो दिन का भंडारण' : 'Two days of storage',
              hi ? '${total * 2} लीटर' : '${total * 2} litres'),
          const SizedBox(height: 8),
          ToolNote(hi
              ? '55 लीटर प्रति व्यक्ति जल जीवन मिशन का मानक है — इसमें पीना, खाना '
                  'बनाना, नहाना, कपड़े और बर्तन सब शामिल है। जानवरों की संख्या मौसम से '
                  'बदलती है: गर्मी में काफ़ी ज़्यादा लगता है।'
              : 'The 55 litres per person is the Jal Jeevan Mission standard, '
                  'covering drinking, cooking, bathing, clothes and vessels. '
                  'The animal figures shift with the season: considerably '
                  'more in summer.'),
          ToolAnswer(
            headline: hi ? 'भंडारण का हिसाब' : 'Working out storage',
            detail: hi
                ? 'जहाँ पानी रोज़ नहीं आता, वहाँ कम से कम दो दिन का भंडारण रखें — '
                    'आपके लिए ${total * 2} लीटर। 1,000 लीटर की एक टंकी, या 200 लीटर '
                    'के ${((total * 2) / 200).ceil()} ड्रम। पीने का पानी अलग, ढके '
                    'बर्तन में रखें, और नहाने-धोने का अलग — इससे पीने का पानी बार-बार '
                    'छूकर गंदा नहीं होता।'
                : 'Where water does not come daily, keep at least two days in '
                    'storage - ${total * 2} litres for you. That is one '
                    '1,000 litre tank, or ${((total * 2) / 200).ceil()} drums '
                    'of 200 litres. Keep drinking water separate in a covered '
                    'vessel from the washing water, so it is not being dipped '
                    'into all day.',
            tone: ToolTone.good,
            icon: Icons.storage_outlined,
          ),
        ],
      ],
    );
  }
}

// --- Cleaning the tank ------------------------------------------------

class TankCleaningPage extends StatelessWidget {
  const TankCleaningPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 6,
      title: hi ? 'पानी की टंकी की सफ़ाई' : 'Cleaning the storage tank',
      children: [
        ToolNote(hi
            ? 'टंकी की दीवार पर जो चिकनी परत जम जाती है, वह सिर्फ़ मैल नहीं है — उसी '
                'में कीटाणु बसते हैं, और सिर्फ़ पानी बहा देने से वह नहीं जाती। उसे रगड़कर '
                'निकालना पड़ता है। साल में दो बार सही है, और बारिश के बाद ज़रूर।'
            : 'The slimy film on a tank wall is not just dirt - it is where '
                'the germs live, and emptying the tank does not remove it. It '
                'has to be scrubbed off. Twice a year is right, and always '
                'after the rains.'),
        const SizedBox(height: 10),
        Text(hi ? 'तरीक़ा' : 'The method',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'पानी की आवक बंद करें और टंकी को लगभग ख़ाली होने दें। बचा हुआ पानी '
                      'बाल्टी से निकालें — बहाना ज़रूरी नहीं, वह पौधों और सफ़ाई में काम '
                      'आ जाता है।',
                  'तली में बैठा कीचड़ और रेत निकालें। यही सबसे ज़्यादा गंदगी होती है '
                      'और यही सबसे ज़्यादा छोड़ दी जाती है।',
                  'दीवारों और तली को ब्रश से रगड़ें — ऊपर से नीचे की ओर। डिटर्जेंट की '
                      'ज़रूरत नहीं; चिकनी परत रगड़ने से ही उतरती है।',
                  'साफ़ पानी से धोकर वह पानी भी निकाल दें।',
                  'कीटाणुरहित करें: थोड़े पानी में क्लोरीन का घोल डालकर दीवारों पर '
                      'फैलाएँ, आधा घंटा छोड़ें, फिर धो दें।',
                  'भरते समय पहला भराव इस्तेमाल करने से पहले आधा घंटा रुकें।',
                  'ढक्कन ठीक से बंद करें और जाली लगी हो तो देख लें — टंकी खुली रहना '
                      'ही मच्छर और छिपकली के गिरने की वजह है।',
                ]
              : const [
                  'Shut off the inflow and let the tank run nearly empty. '
                      'Bail out what is left - it need not be wasted, it does '
                      'for plants and for the cleaning itself.',
                  'Scoop out the silt and sand settled at the bottom. That is '
                      'the bulk of the dirt, and the part most often left.',
                  'Scrub the walls and floor with a brush, working downwards. '
                      'No detergent is needed; the film comes off with '
                      'scrubbing.',
                  'Rinse with clean water and bail that out too.',
                  'Disinfect: mix chlorine solution into a little water, '
                      'spread it over the walls, leave half an hour, then '
                      'rinse.',
                  'When refilling, wait half an hour before using the first '
                      'fill.',
                  'Close the lid properly and check the mesh - an open tank '
                      'is how mosquitoes breed and how lizards fall in.',
                ],
        ),
        ToolDonts(
          heading: hi ? 'सफ़ाई में सावधानी' : 'Safety while cleaning',
          items: hi
              ? const [
                  'ज़मीन के नीचे वाली (अंडरग्राउंड) टंकी में अकेले न उतरें। बंद जगह में '
                      'हवा की कमी और गैस जानलेवा होती है — ढक्कन खोलकर कुछ देर हवा '
                      'लगने दें, और बाहर एक आदमी हमेशा खड़ा रहे।',
                  'टंकी में उतरते समय बिजली की मोटर बंद रखें',
                  'तेज़ाब या मज़बूत रसायन से सफ़ाई न करें',
                  'सफ़ाई के बाद पहले भराव का पानी बिना रुके न पिएँ',
                  'बच्चों को टंकी के पास अकेला न छोड़ें, और ढक्कन कभी खुला न छोड़ें',
                ]
              : const [
                  'Never go down into an underground tank alone. In a closed '
                      'space the lack of air and the gas can kill - open the '
                      'cover and let it air first, and keep one person '
                      'standing outside throughout.',
                  'Switch the motor off before anyone goes in',
                  'Do not clean with acid or strong chemicals',
                  'Do not drink the first fill without waiting',
                  'Do not leave children near the tank, and never leave the '
                      'cover off',
                ],
        ),
        ToolNote(hi
            ? 'मोटर से टंकी भरती हो तो फ़्लोट वाल्व ज़रूर लगवाएँ। इससे टंकी भरते ही '
                'अपने आप बंद हो जाती है, और घर से सबसे ज़्यादा पानी इसी ओवरफ़्लो से '
                'बहता है।'
            : 'If a motor fills the tank, fit a float valve. It cuts off by '
                'itself when the tank is full, and overflow is where most of '
                'a household\'s water goes.'),
      ],
    );
  }
}
