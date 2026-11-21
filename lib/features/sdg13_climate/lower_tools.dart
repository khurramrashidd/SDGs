import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Lowering your own heat and smoke: a cooler roof, the right trees, and
/// what to do with stubble instead of burning it.
///
/// Costs are given as cheap / moderate / costly rather than in rupees,
/// because material prices move and differ by town. The ranking between
/// options is what holds steady.

const _ndmaUrl = 'https://ndma.gov.in/';
const _moefccUrl = 'https://moef.gov.in/';
const _agriUrl = 'https://agriwelfare.gov.in/';

// --- Cool roof --------------------------------------------------------

enum RoofType { tin, rcc, asbestos, tile }

class CoolRoofPage extends StatefulWidget {
  const CoolRoofPage({super.key});

  @override
  State<CoolRoofPage> createState() => _CoolRoofPageState();
}

class _CoolRoofPageState extends State<CoolRoofPage> {
  RoofType? _roof;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    final options = switch (_roof) {
      RoofType.tin => hi
          ? const [
              ('सस्ता', 'छत के ऊपर सफ़ेद या चमकदार परावर्तक पेंट — धूप वापस लौटती है'),
              ('सस्ता', 'छत के नीचे बाँस, जूट या पुरानी बोरी की झूठी छत (फ़ॉल्स सीलिंग), बीच में हवा की जगह छोड़कर'),
              ('सस्ता', 'ऊपर सूखी घास या फूस की परत, बाँधकर — आँधी में उड़े नहीं'),
              ('मध्यम', 'छत के नीचे थर्माकोल या फ़ोम की चादर (इंसुलेशन)'),
              ('मध्यम', 'दीवार के ऊपर, छत के पास, हवा निकलने के रोशनदान'),
            ]
          : const [
              ('Cheap', 'White or reflective paint on top - the sun bounces back'),
              ('Cheap', 'A false ceiling of bamboo, jute or old sacking under the sheets, with an air gap between'),
              ('Cheap', 'A layer of dry grass or thatch on top, tied down so it does not fly in a storm'),
              ('Moderate', 'Thermocol or foam insulation sheets under the roof'),
              ('Moderate', 'Vents high in the wall near the roof to let hot air out'),
            ],
      RoofType.rcc => hi
          ? const [
              ('सबसे सस्ता', 'चूने की पुताई (लाइम वॉश) — हर गर्मी से पहले दोहराएँ'),
              ('सस्ता', 'सफ़ेद परावर्तक (कूल रूफ़) पेंट, जो कई साल चलता है'),
              ('सस्ता', 'टूटी सफ़ेद टाइलों के टुकड़ों की परत (चाइना मोज़ेक)'),
              ('मध्यम', 'छत पर गमले या क्यारियाँ — पानी रिसने से बचाव के साथ'),
              ('मध्यम', 'छत के ऊपर मिट्टी के घड़े उल्टे रखकर, ऊपर पतला प्लास्टर'),
            ]
          : const [
              ('Cheapest', 'Lime wash - repeat it before every summer'),
              ('Cheap', 'White reflective "cool roof" paint, which lasts several years'),
              ('Cheap', 'A layer of broken white tile pieces (china mosaic)'),
              ('Moderate', 'Pots or beds on the roof - with waterproofing so it does not leak'),
              ('Moderate', 'Upturned clay pots laid on the slab with a thin plaster over them'),
            ],
      RoofType.asbestos => hi
          ? const [
              ('सस्ता', 'ऊपर सफ़ेद परावर्तक पेंट — लेकिन चादर को रगड़ें, खुरचें या तोड़ें नहीं'),
              ('सस्ता', 'नीचे बाँस या जूट की झूठी छत, हवा की जगह छोड़कर'),
              ('मध्यम', 'छत के पास हवा निकलने के रोशनदान'),
            ]
          : const [
              ('Cheap', 'White reflective paint on top - but do not scrub, scrape or break the sheet'),
              ('Cheap', 'A bamboo or jute false ceiling beneath, with an air gap'),
              ('Moderate', 'Vents near the roof to let hot air out'),
            ],
      RoofType.tile => hi
          ? const [
              ('सस्ता', 'खपरैल पर चूने का घोल'),
              ('सस्ता', 'नीचे बाँस-चटाई की झूठी छत'),
              ('मध्यम', 'टूटी या खिसकी खपरैल बदलें — दरार से गर्म हवा और बारिश दोनों आते हैं'),
            ]
          : const [
              ('Cheap', 'A lime wash over the tiles'),
              ('Cheap', 'A bamboo-mat false ceiling beneath'),
              ('Moderate', 'Replace broken or slipped tiles - the gaps let in both heat and rain'),
            ],
      null => const <(String, String)>[],
    };

    return ToolScaffold(
      goal: 13,
      title: hi ? 'ठंडी छत: घर की गर्मी कम करने के सस्ते तरीक़े' : 'Cool roof: cheap ways to drop indoor heat',
      children: [
        ToolNote(hi
            ? 'गर्मी में घर की सबसे ज़्यादा गर्मी छत से आती है। सफ़ेद या चमकदार छत '
                'धूप का बड़ा हिस्सा वापस लौटा देती है, और कई शहरों के प्रयोगों में '
                'इससे अंदर का तापमान कुछ डिग्री तक घटा है। छत किस तरह की है, चुनिए।'
            : 'In summer most of a house\'s heat comes through the roof. A white '
                'or reflective roof sends much of the sun back, and in trials in '
                'several cities it has lowered indoor temperatures by a few '
                'degrees. Pick your roof type.'),
        ToolQuestion(hi ? 'छत किसकी है' : 'What is the roof'),
        SelectionTile(
          label: hi ? 'टीन की चादर' : 'Tin sheets',
          selected: _roof == RoofType.tin,
          onTap: () => setState(() => _roof = RoofType.tin),
        ),
        SelectionTile(
          label: hi ? 'पक्की लेंटर (आरसीसी)' : 'Concrete slab (RCC)',
          selected: _roof == RoofType.rcc,
          onTap: () => setState(() => _roof = RoofType.rcc),
        ),
        SelectionTile(
          label: hi ? 'सीमेंट या एस्बेस्टस की चादर' : 'Cement or asbestos sheets',
          selected: _roof == RoofType.asbestos,
          onTap: () => setState(() => _roof = RoofType.asbestos),
        ),
        SelectionTile(
          label: hi ? 'खपरैल' : 'Clay tiles',
          selected: _roof == RoofType.tile,
          onTap: () => setState(() => _roof = RoofType.tile),
        ),
        if (options.isNotEmpty) ...[
          const SizedBox(height: 10),
          for (final o in options) ToolLine(o.$2, o.$1),
          if (_roof == RoofType.asbestos) ...[
            const SizedBox(height: 10),
            ToolAnswer(
              headline: hi ? 'एस्बेस्टस को तोड़ें या घिसें नहीं' : 'Do not break or sand asbestos',
              detail: hi
                  ? 'पुरानी एस्बेस्टस की चादर तोड़ने, ड्रिल करने या रगड़ने से उसकी '
                      'धूल उड़ती है, जो साँस के साथ फेफड़ों में जाकर बरसों बाद गंभीर '
                      'बीमारी करती है। पेंट ब्रश से हल्के हाथ से करें, और चादर बदलनी '
                      'हो तो उसे पूरा, बिना तोड़े, गीला करके उतरवाएँ।'
                  : 'Breaking, drilling or rubbing an old asbestos sheet throws '
                      'up dust that, breathed in, causes serious lung disease '
                      'years later. Paint it gently with a brush, and if it has '
                      'to come off, have it removed whole, wetted, without '
                      'breaking.',
              tone: ToolTone.bad,
              icon: Icons.warning_amber_outlined,
            ),
          ],
        ],
        const SizedBox(height: 14),
        Text(hi ? 'किसी भी घर में, मुफ़्त' : 'In any house, free',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'दिन में धूप वाली तरफ़ की खिड़कियाँ बंद और पर्दे खींचे रखें; रात को '
                      'खोलें ताकि ठंडी हवा आए',
                  'आमने-सामने की खिड़कियाँ खोलकर आर-पार हवा बनाएँ',
                  'खिड़की पर गीली चादर या खस की टट्टी',
                  'घर के पश्चिम और दक्षिण में पेड़ या बेल — इसी लक्ष्य में "कौन से पेड़" '
                      'वाली स्क्रीन देखें',
                ]
              : const [
                  'Keep sunny-side windows shut and curtained by day; open them '
                      'at night to let cool air in',
                  'Open windows on opposite sides for a through-draught',
                  'A wet sheet or khus screen over the window',
                  'A tree or a creeper on the west and south sides - see "Which '
                      'trees" in this goal',
                ],
        ),
        const SourceNote(
            text: 'National Disaster Management Authority - heat', url: _ndmaUrl),
      ],
    );
  }
}

// --- Which trees ------------------------------------------------------

enum Region { gangetic, arid, deccan, coastal, himalaya, northEast }

class TreesPage extends StatefulWidget {
  const TreesPage({super.key});

  @override
  State<TreesPage> createState() => _TreesPageState();
}

class _TreesPageState extends State<TreesPage> {
  Region? _region;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    final trees = switch (_region) {
      Region.gangetic => hi
          ? 'नीम, पीपल, बरगद, जामुन, अर्जुन, आम, शीशम, बेल, आँवला, कदंब'
          : 'Neem, peepal, banyan, jamun, arjun, mango, shisham, bael, amla, kadamb',
      Region.arid => hi
          ? 'खेजड़ी, रोहिड़ा, बेर, देसी बबूल, नीम, कैर, जाल (पीलू), इंद्रोक'
          : 'Khejri, rohida, ber, desi babul, neem, ker, jaal (pilu), indrok',
      Region.deccan => hi
          ? 'नीम, इमली, करंज, जामुन, बरगद, पीपल, सागौन, आँवला, बेल, महुआ'
          : 'Neem, tamarind, karanj, jamun, banyan, peepal, teak, amla, bael, mahua',
      Region.coastal => hi
          ? 'नारियल, करंज, जामुन, कटहल, सुपारी, पुन्नाग; तट पर मैंग्रोव — वन विभाग की देखरेख में'
          : 'Coconut, karanj, jamun, jackfruit, areca, punnag; mangroves on the shore - with the forest department',
      Region.himalaya => hi
          ? 'बाँज (ओक), देवदार, बुरांश, काफल, भीमल, अखरोट, शहतूत — ऊँचाई के हिसाब से'
          : 'Banj oak, deodar, burans, kafal, bhimal, walnut, mulberry - by altitude',
      Region.northEast => hi
          ? 'बाँस, कटहल, आम, जामुन, गम्हार, नाहर, सुपारी, शहतूत'
          : 'Bamboo, jackfruit, mango, jamun, gamhar, nahar, areca, mulberry',
      null => '',
    };

    return ToolScaffold(
      goal: 13,
      title: hi ? 'मेरे इलाक़े में कौन से पेड़' : 'Which trees suit my area',
      children: [
        ToolNote(hi
            ? 'देसी पेड़ उसी मिट्टी और बारिश में पले हैं, इसलिए वे कम पानी में बचते '
                'हैं, पक्षियों और मधुमक्खियों को खाना देते हैं, और लू-आँधी झेल लेते '
                'हैं। बाहर से लाए तेज़ बढ़ने वाले पेड़ — जैसे यूकेलिप्टस — अक्सर ज़मीन '
                'का पानी ज़्यादा खींचते हैं।'
            : 'Native trees grew up in this soil and rain, so they survive on '
                'less water, feed birds and bees, and stand up to heat and '
                'storms. Fast-growing imports - eucalyptus, for one - often '
                'draw far more groundwater.'),
        ToolQuestion(hi ? 'आपका इलाक़ा' : 'Your region'),
        SelectionTile(
          label: hi ? 'गंगा-यमुना का मैदान' : 'The Gangetic plain',
          subtitle: hi ? 'उत्तर प्रदेश, बिहार, हरियाणा, पंजाब' : 'UP, Bihar, Haryana, Punjab',
          selected: _region == Region.gangetic,
          onTap: () => setState(() => _region = Region.gangetic),
        ),
        SelectionTile(
          label: hi ? 'सूखा पश्चिम' : 'The dry west',
          subtitle: hi ? 'राजस्थान, कच्छ' : 'Rajasthan, Kutch',
          selected: _region == Region.arid,
          onTap: () => setState(() => _region = Region.arid),
        ),
        SelectionTile(
          label: hi ? 'दक्कन का पठार' : 'The Deccan plateau',
          subtitle: hi
              ? 'महाराष्ट्र, तेलंगाना, कर्नाटक, मध्य प्रदेश'
              : 'Maharashtra, Telangana, Karnataka, MP',
          selected: _region == Region.deccan,
          onTap: () => setState(() => _region = Region.deccan),
        ),
        SelectionTile(
          label: hi ? 'समुद्र तट' : 'The coast',
          subtitle: hi ? 'केरल, कोंकण, ओडिशा, तमिलनाडु तट' : 'Kerala, Konkan, Odisha, Tamil Nadu coast',
          selected: _region == Region.coastal,
          onTap: () => setState(() => _region = Region.coastal),
        ),
        SelectionTile(
          label: hi ? 'हिमालय' : 'The Himalaya',
          subtitle: hi ? 'उत्तराखंड, हिमाचल, जम्मू-कश्मीर' : 'Uttarakhand, Himachal, J&K',
          selected: _region == Region.himalaya,
          onTap: () => setState(() => _region = Region.himalaya),
        ),
        SelectionTile(
          label: hi ? 'पूर्वोत्तर' : 'The North-East',
          selected: _region == Region.northEast,
          onTap: () => setState(() => _region = Region.northEast),
        ),
        if (trees.isNotEmpty) ...[
          ToolAnswer(
            headline: hi ? 'इनमें से चुनें' : 'Choose from these',
            detail: trees,
            tone: ToolTone.good,
            icon: Icons.park_outlined,
          ),
          const SizedBox(height: 10),
          ToolNote(hi
              ? 'यह मोटी सूची है; आपके ज़िले के लिए सबसे सही पेड़ वन विभाग की नर्सरी '
                  'या कृषि विज्ञान केंद्र बताएगा।'
              : 'This is a broad list; the forest department nursery or the '
                  'Krishi Vigyan Kendra will name the best trees for your '
                  'district.'),
        ],
        const SizedBox(height: 14),
        Text(hi ? 'पौधा लगाना और बचाना' : 'Planting and keeping it alive',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'पौधे वन विभाग की नर्सरी से लें — वहाँ अक्सर मुफ़्त या बहुत सस्ते '
                      'मिलते हैं। सामाजिक वानिकी विभाग और पंचायत से भी पूछें।',
                  'मानसून की पहली अच्छी बारिश के बाद लगाएँ — तब जड़ जमने का पूरा '
                      'मौसम मिलता है।',
                  'लगभग दो फ़ुट गहरा और चौड़ा गड्ढा, उसमें मिट्टी के साथ गोबर की '
                      'सड़ी खाद।',
                  'बकरी और मवेशी से बचाने के लिए बाड़ या ईंट का घेरा — पहले दो साल '
                      'सबसे ज़्यादा पौधे इसी से मरते हैं।',
                  'पहली गर्मी में हफ़्ते में एक-दो बार पानी; जड़ के पास पुआल की परत '
                      'बिछाएँ।',
                ]
              : const [
                  'Get saplings from the forest department nursery - they are '
                      'often free or very cheap. Ask the social forestry '
                      'department and the panchayat too.',
                  'Plant after the first good monsoon rain - that gives the '
                      'roots a whole season to settle.',
                  'A pit about two feet deep and wide, with rotted cow-dung '
                      'manure mixed into the soil.',
                  'A fence or a ring of bricks against goats and cattle - '
                      'that is what kills most saplings in the first two '
                      'years.',
                  'Water once or twice a week through the first summer; lay '
                      'straw around the base.',
                ],
        ),
        const SourceNote(
            text: 'Ministry of Environment, Forest and Climate Change',
            url: _moefccUrl),
      ],
    );
  }
}

// --- Stubble ----------------------------------------------------------

class StubblePage extends StatelessWidget {
  const StubblePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 13,
      title: hi ? 'पराली: जलाने के बदले क्या करें' : 'Stubble: options instead of burning',
      children: [
        ToolNote(hi
            ? 'पराली जलाने से सिर्फ़ हवा ख़राब नहीं होती — खेत की ऊपरी मिट्टी के जीव '
                'और नमी भी जल जाते हैं, और अगली फ़सल को ज़्यादा खाद चाहिए होती है। '
                'दिल्ली-एनसीआर और उससे लगे पंजाब, हरियाणा, उत्तर प्रदेश और राजस्थान के '
                'इलाक़ों में पराली जलाने पर ज़मीन के हिसाब से जुर्माना है — 2 एकड़ से कम '
                'पर ₹5,000, 2 से 5 एकड़ पर ₹10,000, और 5 एकड़ से ज़्यादा पर ₹30,000 '
                'हर घटना पर।'
            : 'Burning stubble does not only foul the air - it also burns the '
                'life and moisture in the topsoil, and the next crop needs more '
                'fertiliser. In Delhi-NCR and the adjoining areas of Punjab, '
                'Haryana, UP and Rajasthan, burning carries a fine by land '
                'size - ₹5,000 under 2 acres, ₹10,000 for 2 to 5 acres, and '
                '₹30,000 above 5 acres, per incident.'),
        const SizedBox(height: 12),
        Text(hi ? 'खेत में ही — पराली को मिट्टी बनाना' : 'In the field - turning stubble into soil',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'हैप्पी सीडर या सुपर सीडर — पराली हटाए बिना सीधे गेहूँ बो देता है; '
                      'पराली ऊपर परत बनकर नमी बचाती है',
                  'मल्चर और पलटने वाला हल — पराली काटकर मिट्टी में मिला देता है',
                  'पूसा डीकंपोज़र — कैप्सूल या घोल का छिड़काव, जिससे पराली कुछ हफ़्तों '
                      'में खेत में ही गल जाती है; कृषि विभाग कई जगह मुफ़्त देता है',
                ]
              : const [
                  'Happy Seeder or Super Seeder - sows wheat straight into the '
                      'stubble; the straw stays as a mulch that holds moisture',
                  'Mulcher and reversible plough - chops the straw and works '
                      'it into the soil',
                  'Pusa decomposer - a capsule or liquid spray that rots the '
                      'stubble in the field within a few weeks; the '
                      'agriculture department gives it free in many places',
                ],
        ),
        const SizedBox(height: 12),
        Text(hi ? 'खेत से बाहर — पराली बेचना' : 'Out of the field - selling the stubble',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'बेलर से गठ्ठर बनाकर बायोमास बिजली घर, गत्ता मिल या बायो-गैस संयंत्र '
                      'को बेचें — कई ज़िलों में ये पराली ख़रीदते हैं',
                  'पशुओं के चारे या बिछावन के लिए, जहाँ फ़सल के हिसाब से ठीक हो',
                  'मशरूम उगाने के लिए',
                ]
              : const [
                  'Baled, sold to biomass power plants, board mills or biogas '
                      'plants - many districts have buyers',
                  'As fodder or bedding for animals, where the crop suits it',
                  'For growing mushrooms',
                ],
        ),
        const SizedBox(height: 12),
        ToolAnswer(
          headline: hi ? 'मशीन ख़रीदने या किराये पर लेने में मदद' : 'Help to buy or hire the machine',
          detail: hi
              ? 'फ़सल अवशेष प्रबंधन योजना में मशीन ख़रीदने पर अकेले किसान को 50% और '
                  'सहकारी समिति, किसान उत्पादक संगठन या कस्टम हायरिंग केंद्र को 80% '
                  'तक सब्सिडी मिलती है। ख़रीदना महँगा हो तो पास के कस्टम हायरिंग केंद्र '
                  'से किराये पर लें — कृषि विभाग इनकी सूची रखता है, और कई राज्यों के '
                  'ऐप पर बुकिंग होती है।'
              : 'Under the crop residue management scheme a machine bought by '
                  'an individual farmer carries up to 50% subsidy, and up to '
                  '80% for a cooperative, a farmer producer organisation or a '
                  'custom hiring centre. If buying is too costly, hire one '
                  'from the nearest custom hiring centre - the agriculture '
                  'department keeps the list, and several states take '
                  'bookings on an app.',
          tone: ToolTone.good,
          icon: Icons.agriculture_outlined,
        ),
        const SourceNote(
            text: 'Department of Agriculture and Farmers Welfare', url: _agriUrl),
      ],
    );
  }
}

// --- Household carbon footprint ---------------------------------------

/// Grid electricity: the Central Electricity Authority's weighted average
/// for 2023-24 was 0.727 tonnes CO2 per MWh, i.e. kg per unit.
const gridKgPerUnit = 0.727;

/// Combustion factors from the IPCC defaults: LPG about 2.98 kg CO2 per kg,
/// so a 14.2 kg cylinder is about 42; petrol about 2.31 kg per litre;
/// diesel about 2.68.
const lpgKgPerCylinder = 42.3;
const petrolKgPerLitre = 2.31;
const dieselKgPerLitre = 2.68;

/// India's CO2 per person, 2025 - Our World in Data from the Global Carbon
/// Project. Used only as a yardstick.
const indiaTonnesPerPerson = 2.19;

const _owidUrl = 'https://ourworldindata.org/co2/country/india';
const _ceaUrl = 'https://cea.nic.in/';

class CarbonFootprintPage extends StatefulWidget {
  const CarbonFootprintPage({super.key});

  @override
  State<CarbonFootprintPage> createState() => _CarbonFootprintPageState();
}

class _CarbonFootprintPageState extends State<CarbonFootprintPage> {
  final _people = TextEditingController(text: '4');
  final _units = TextEditingController();
  final _cylinders = TextEditingController();
  final _petrol = TextEditingController();
  final _diesel = TextEditingController();

  @override
  void dispose() {
    for (final c in [_people, _units, _cylinders, _petrol, _diesel]) {
      c.dispose();
    }
    super.dispose();
  }

  double _v(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final people = _v(_people);
    // Everything to kg a year.
    final power = _v(_units) * 12 * gridKgPerUnit;
    final gas = _v(_cylinders) * lpgKgPerCylinder;
    final petrol = _v(_petrol) * 12 * petrolKgPerLitre;
    final diesel = _v(_diesel) * 12 * dieselKgPerLitre;
    final total = power + gas + petrol + diesel;
    final perPerson = people > 0 ? total / people / 1000 : 0.0;

    final parts = <(String, double)>[
      (hi ? 'बिजली' : 'Electricity', power),
      (hi ? 'एलपीजी' : 'LPG', gas),
      (hi ? 'पेट्रोल' : 'Petrol', petrol),
      (hi ? 'डीज़ल' : 'Diesel', diesel),
    ]..sort((a, b) => b.$2.compareTo(a.$2));

    String cutFor(String label) {
      if (label == (hi ? 'बिजली' : 'Electricity')) {
        return hi
            ? 'बिजली: एसी 24-26°C पर, गीज़र टाइमर पर, एलईडी बल्ब — और छत पर सोलर '
                'हो सके तो लक्ष्य 7 में सब्सिडी देखें।'
            : 'Electricity: the AC at 24-26°C, the geyser on a timer, LED '
                'bulbs - and for rooftop solar, see the subsidy in goal 7.';
      }
      if (label == (hi ? 'एलपीजी' : 'LPG')) {
        return hi
            ? 'एलपीजी: प्रेशर कुकर और ढक्कन, भिगोई दाल-चावल, और बर्तन के नीचे तक ही '
                'लौ — इनसे गैस काफ़ी बचती है।'
            : 'LPG: a pressure cooker and lids, soaked dal and rice, and a '
                'flame no wider than the pan - these save a good deal of gas.';
      }
      return hi
          ? '$label: पास के काम पैदल या साइकिल से, टायर में सही हवा, और जहाँ हो '
              'सके साझा सवारी या बस।'
          : '$label: short trips on foot or by bicycle, tyres at the right '
              'pressure, and shared rides or the bus where you can.';
    }

    return ToolScaffold(
      goal: 13,
      title: hi ? 'मेरे घर का कार्बन असर' : 'My household\'s carbon footprint',
      children: [
        ToolNote(hi
            ? 'घर का ज़्यादातर कार्बन चार जगह से आता है: बिजली, रसोई गैस, और गाड़ी का '
                'पेट्रोल या डीज़ल। बिल और रसीदों से चार संख्याएँ भरें।'
            : 'Most of a household\'s carbon comes from four places: '
                'electricity, cooking gas, and petrol or diesel for vehicles. '
                'Fill four numbers from the bills and receipts.'),
        ToolNumber(
          controller: _people,
          label: hi ? 'घर में कितने लोग' : 'People in the house',
          maxDigits: 2,
          icon: Icons.people_outline,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _units,
                label: hi ? 'बिजली, यूनिट/महीना' : 'Power, units a month',
                decimal: true,
                maxDigits: 5,
                icon: Icons.bolt_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _cylinders,
                label: hi ? 'एलपीजी सिलेंडर/साल' : 'LPG cylinders a year',
                decimal: true,
                maxDigits: 3,
                icon: Icons.local_fire_department_outlined,
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
                controller: _petrol,
                label: hi ? 'पेट्रोल, लीटर/महीना' : 'Petrol, litres a month',
                decimal: true,
                maxDigits: 4,
                icon: Icons.two_wheeler_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _diesel,
                label: hi ? 'डीज़ल, लीटर/महीना' : 'Diesel, litres a month',
                decimal: true,
                maxDigits: 4,
                icon: Icons.local_shipping_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        if (total > 0) ...[
          ToolAnswer(
            headline: hi
                ? 'साल में लगभग ${(total / 1000).toStringAsFixed(1)} टन CO₂'
                : 'About ${(total / 1000).toStringAsFixed(1)} tonnes of CO₂ a year',
            detail: people > 0
                ? (hi
                    ? 'यानी हर व्यक्ति पर लगभग ${perPerson.toStringAsFixed(2)} टन। देश '
                        'का औसत लगभग $indiaTonnesPerPerson टन प्रति व्यक्ति है — पर उसमें '
                        'कारख़ाने, सड़कें और खेती भी शामिल हैं, इसलिए घर का हिस्सा उससे कम '
                        'होना स्वाभाविक है।'
                    : 'That is about ${perPerson.toStringAsFixed(2)} tonnes a '
                        'person. The national average is about '
                        '$indiaTonnesPerPerson tonnes a person - but that '
                        'includes factories, roads and farming, so a home\'s '
                        'share being lower is natural.')
                : '',
            tone: ToolTone.plain,
            icon: Icons.co2,
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < parts.length; i++)
            if (parts[i].$2 > 0)
              ToolLine(parts[i].$1,
                  '${(parts[i].$2 / 1000).toStringAsFixed(2)} t · ${(parts[i].$2 / total * 100).round()}%',
                  strong: i == 0),
          const SizedBox(height: 10),
          ToolAnswer(
            headline: hi ? 'सबसे बड़ी कटौती यहाँ' : 'Where the biggest cuts are',
            detail: [
              for (final p in parts.where((p) => p.$2 > 0).take(3))
                cutFor(p.$1),
            ].join('\n\n'),
            tone: ToolTone.good,
            icon: Icons.trending_down,
          ),
        ],
        const SourceNote(
            text: 'Central Electricity Authority - CO2 baseline', url: _ceaUrl),
        const SourceNote(text: 'Our World in Data - India CO2', url: _owidUrl),
      ],
    );
  }
}
