import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Floods, earthquakes and road accidents.
///
/// The go-bag list keeps its ticks, because packing happens on a calm day
/// over several evenings. The road accident screen keeps nothing and
/// opens with the number to call, the same rule as every other emergency
/// screen in this app.

const _ndmaUrl = 'https://ndma.gov.in/';
const _bmtpcUrl = 'https://bmtpc.org/';
const _morthUrl = 'https://morth.nic.in/';

/// Rah-Veer reward for a Good Samaritan who gets a seriously injured road
/// accident victim to hospital. Ministry of Road Transport and Highways.
/// Checked against several independent reports, November 2026.
const rahVeerReward = 25000;

/// Cashless treatment for road accident victims at designated hospitals.
/// Ministry of Road Transport and Highways. Checked against several
/// independent reports, November 2026.
const accidentCashlessRupees = 150000;
const accidentCashlessDays = 7;

// --- Flood go-bag -----------------------------------------------------

class GoBagPage extends StatefulWidget {
  const GoBagPage({super.key});

  @override
  State<GoBagPage> createState() => _GoBagPageState();
}

class _GoBagPageState extends State<GoBagPage> {
  final _adults = TextEditingController(text: '2');
  final _children = TextEditingController(text: '0');
  final _elders = TextEditingController(text: '0');
  bool _baby = false;
  bool _medicine = false;

  @override
  void dispose() {
    for (final c in [_adults, _children, _elders]) {
      c.dispose();
    }
    super.dispose();
  }

  int _n(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final adults = _n(_adults);
    final children = _n(_children);
    final elders = _n(_elders);
    final people = adults + children + elders;

    return ToolScaffold(
      goal: 11,
      title: hi ? 'बाढ़ के लिए तैयार थैला' : 'Flood go-bag for my family',
      children: [
        ToolNote(hi
            ? 'पानी चढ़ने पर घर छोड़ने के लिए अक्सर दस मिनट से कम मिलते हैं। उस '
                'समय जो थैला पहले से भरा रखा है, वही साथ जाता है। इसे बरसात से पहले '
                'किसी शांत शाम को भरिए और ऊँची जगह पर टाँग दीजिए।'
            : 'When the water rises there are often less than ten minutes '
                'to leave. What goes with you is the bag already packed. '
                'Fill it on a calm evening before the monsoon and hang it '
                'somewhere high.'),
        ToolQuestion(hi ? 'घर में कौन-कौन है' : 'Who is in the house'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _adults,
                label: hi ? 'बड़े' : 'Adults',
                maxDigits: 2,
                icon: Icons.person_outline,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ToolNumber(
                controller: _children,
                label: hi ? 'बच्चे' : 'Children',
                maxDigits: 2,
                icon: Icons.child_care,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ToolNumber(
                controller: _elders,
                label: hi ? 'बुज़ुर्ग' : 'Elders',
                maxDigits: 2,
                icon: Icons.elderly_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _baby,
          onChanged: (v) => setState(() => _baby = v),
          title: Text(hi ? 'दो साल से छोटा बच्चा है' : 'A baby under two'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _medicine,
          onChanged: (v) => setState(() => _medicine = v),
          title: Text(hi
              ? 'किसी की रोज़ की दवा चलती है'
              : 'Someone takes a daily medicine'),
        ),
        if (people > 0) ...[
          const SizedBox(height: 8),
          ToolAnswer(
            headline: hi ? '$people लोगों के लिए' : 'For $people people',
            detail: hi
                ? 'तीन दिन का हिसाब रखा गया है — बचाव और राहत शिविर तक पहुँचने में '
                    'आम तौर पर इतना समय लग सकता है। पानी तीन दिन का उठाया नहीं जा '
                    'सकता, इसलिए एक बोतल प्रति व्यक्ति और पानी साफ़ करने की गोलियाँ।'
                : 'This is sized for three days - roughly what reaching rescue '
                    'and a relief camp can take. Three days of water cannot be '
                    'carried, so it is one bottle each and tablets to make '
                    'more water safe.',
            tone: ToolTone.plain,
            icon: Icons.backpack_outlined,
          ),
          const SizedBox(height: 10),
          ToolLine(hi ? 'पानी की बोतल (1 लीटर)' : 'Water bottles (1 litre)',
              '$people'),
          ToolLine(hi ? 'पानी साफ़ करने की गोलियाँ' : 'Water purification tablets',
              hi ? '${people * 9} लीटर के लिए' : 'Enough for ${people * 9} litres'),
          ToolNote(hi
              ? 'एक गोली कितना पानी साफ़ करती है, यह ब्रांड के हिसाब से बहुत अलग है — '
                  'पैकेट पर लिखा देखकर गिनती करें।'
              : 'How much water one tablet treats varies a great deal by '
                  'brand - count from what the packet says.'),
          ToolLine(hi ? 'ओआरएस के पैकेट' : 'ORS packets', '${people * 2}'),
          ToolLine(
              hi ? 'सूखा खाना — चूड़ा, भुना चना, गुड़, सत्तू' : 'Dry food - poha, roasted gram, jaggery, sattu',
              hi ? '${people * 3} दिन-व्यक्ति' : '${people * 3} person-days'),
          ToolLine(hi ? 'सीटी' : 'Whistles', '${adults + elders}'),
          if (_baby)
            ToolLine(hi ? 'लंगोट / कपड़े की नैपी' : 'Nappies or cloth nappies',
                hi ? '3 दिन के' : '3 days\' worth'),
          if (_medicine)
            ToolLine(hi ? 'रोज़ की दवा' : 'Daily medicine',
                hi ? 'कम से कम एक हफ़्ते की' : 'At least a week\'s'),
          const SizedBox(height: 14),
          const ToolChecklist(
            storageKey: 'flood_go_bag_v1',
            introEn: 'Tick as each goes into the bag.',
            introHi: 'जो-जो थैले में रख दें, उस पर निशान लगाएँ।',
            items: [
              CheckItem('papers', 'Papers in a double plastic bag',
                  'काग़ज़, दोहरी पन्नी में',
                  noteEn: 'Aadhaar, ration card, land papers, bank passbook, '
                      'certificates. Also photograph each and send the '
                      'pictures to a relative\'s phone - papers that are '
                      'soaked or lost can be remade from a photo.',
                  noteHi: 'आधार, राशन कार्ड, ज़मीन के काग़ज़, बैंक पासबुक, प्रमाण '
                      'पत्र। हर एक की फ़ोटो किसी रिश्तेदार के फ़ोन पर भी भेज दें — '
                      'भीगे या खोए काग़ज़ फ़ोटो से दोबारा बन जाते हैं।'),
              CheckItem('torch', 'Torch with spare batteries',
                  'टॉर्च और फ़ालतू बैटरी'),
              CheckItem('power', 'Charged power bank and charger cable',
                  'चार्ज किया पावर बैंक और चार्जर'),
              CheckItem('cash', 'Cash in small notes', 'छोटे नोटों में नक़दी',
                  noteEn: 'ATMs and UPI stop when the power and towers go.',
                  noteHi: 'बिजली और टावर जाने पर एटीएम और यूपीआई बंद हो जाते हैं।'),
              CheckItem('meds', 'First aid and any daily medicines',
                  'प्राथमिक उपचार और रोज़ की दवाएँ',
                  noteEn: 'In a sealed bag, with a photo of the prescription.',
                  noteHi: 'बंद पन्नी में, पर्चे की फ़ोटो के साथ।'),
              CheckItem('rope', 'Ten metres of rope, and a knife',
                  'दस मीटर रस्सी, और एक चाकू'),
              CheckItem('sheet', 'Plastic sheet or tarpaulin', 'प्लास्टिक शीट या तिरपाल'),
              CheckItem('net', 'Mosquito net', 'मच्छरदानी',
                  noteEn: 'Malaria and dengue rise after floods.',
                  noteHi: 'बाढ़ के बाद मलेरिया और डेंगू बढ़ते हैं।'),
              CheckItem('clothes', 'One change of clothes each, sealed',
                  'हर एक के लिए एक जोड़ी कपड़े, बंद पन्नी में'),
              CheckItem('pads', 'Sanitary pads, soap, toothbrushes',
                  'सैनिटरी पैड, साबुन, टूथब्रश'),
              CheckItem('matches', 'Matches and candles in a plastic box',
                  'माचिस और मोमबत्ती, प्लास्टिक के डिब्बे में'),
              CheckItem('numbers', 'Phone numbers written on paper',
                  'ज़रूरी नंबर, काग़ज़ पर लिखे हुए',
                  noteEn: 'A relative, the panchayat, and 1077 for the district '
                      'disaster control room. A dead phone takes its contacts '
                      'with it.',
                  noteHi: 'किसी रिश्तेदार का, पंचायत का, और ज़िला आपदा नियंत्रण कक्ष '
                      '1077। फ़ोन बंद हो तो उसके नंबर भी साथ चले जाते हैं।'),
            ],
          ),
          const SizedBox(height: 14),
          ToolDonts(
            heading: hi ? 'जब पानी चढ़े' : 'When the water rises',
            items: hi
                ? const [
                    'बहते पानी में पैदल न उतरें — घुटने तक का तेज़ बहाव आदमी को गिरा '
                        'देता है, और नीचे खुला नाला या गड्ढा दिखता नहीं',
                    'पानी भरी सड़क पर गाड़ी न चलाएँ; ज़्यादातर बाढ़ की मौतें गाड़ी में '
                        'होती हैं',
                    'निकलने से पहले बिजली का मेन बंद करें, और गीले हाथ से कोई '
                        'स्विच न छुएँ',
                    'लौटने पर नल या हैंडपंप का पानी बिना उबाले या गोली डाले न पिएँ',
                    'अनाज और बीज पहले से ऊँची जगह रखें, और मवेशी खुले छोड़ें — '
                        'बँधा जानवर डूब जाता है',
                  ]
                : const [
                    'Do not wade into moving water - knee-deep fast water '
                        'knocks a person down, and an open drain or pit below '
                        'cannot be seen',
                    'Do not drive along a flooded road; most flood deaths '
                        'happen in vehicles',
                    'Switch off the mains before leaving, and touch no '
                        'switch with wet hands',
                    'On return, do not drink tap or handpump water without '
                        'boiling it or adding a tablet',
                    'Move grain and seed up high in advance, and untie the '
                        'animals - a tethered animal drowns',
                  ],
          ),
          const SizedBox(height: 10),
          ToolNote(hi
              ? 'मौसम विभाग और राज्य की चेतावनियाँ एनडीएमए के "सचेत" ऐप पर आती हैं, '
                  'और पास का राहत शिविर ज़िला आपदा नियंत्रण कक्ष 1077 बताता है। '
                  'मौसम की चेतावनी इसी ऐप के मौसम वाले हिस्से में भी दिखती है।'
              : 'Weather and state warnings arrive on NDMA\'s "Sachet" app, '
                  'and the district disaster control room on 1077 can tell '
                  'you the nearest relief camp. Weather warnings also show '
                  'in this app\'s weather section.'),
          const SourceNote(
              text: 'National Disaster Management Authority', url: _ndmaUrl),
        ],
      ],
    );
  }
}

// --- Earthquake risk --------------------------------------------------

enum HouseType { mud, masonry, rccSlabNoBands, rccFrame }

class EarthquakeRiskPage extends StatefulWidget {
  const EarthquakeRiskPage({super.key});

  @override
  State<EarthquakeRiskPage> createState() => _EarthquakeRiskPageState();
}

class _EarthquakeRiskPageState extends State<EarthquakeRiskPage> {
  HouseType? _type;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 11,
      title: hi ? 'भूकंप में मेरा घर ख़तरे में है' : 'Is my house at risk in an earthquake',
      children: [
        ToolNote(hi
            ? 'भूकंप लोगों को नहीं मारता, गिरती इमारतें मारती हैं। देश का बड़ा हिस्सा '
                '— हिमालय के राज्य, पूर्वोत्तर, कच्छ, और हिमालय के पास का गंगा का '
                'मैदान — ऊँचे भूकंप क्षेत्र में है, और भारतीय मानक ब्यूरो का भूकंप '
                'क्षेत्र का नक़्शा हाल में संशोधित हुआ है। अपने ज़िले का क्षेत्र '
                'एनडीएमए या बीएमटीपीसी की वेबसाइट पर देखें। घर का प्रकार चुनें — '
                'सबसे काम की सस्ती मरम्मत नीचे है।'
            : 'Earthquakes do not kill people; falling buildings do. A large '
                'part of the country - the Himalayan states, the North-East, '
                'Kutch, and the Gangetic plain near the Himalaya - lies in '
                'high seismic zones, and the Bureau of Indian Standards\' '
                'zone map has been revised recently. Check your district\'s '
                'zone on the NDMA or BMTPC site. Pick the type of house - '
                'the cheap fixes that matter most are below.'),
        ToolQuestion(hi ? 'घर किस तरह का है' : 'What kind of house'),
        SelectionTile(
          label: hi ? 'कच्चा — मिट्टी या मिट्टी के गारे में पत्थर' : 'Kutcha - mud, or stone in mud mortar',
          selected: _type == HouseType.mud,
          onTap: () => setState(() => _type = HouseType.mud),
        ),
        SelectionTile(
          label: hi ? 'ईंट या पत्थर, सीमेंट में, टीन या खपरैल की छत' : 'Brick or stone in cement, tin or tile roof',
          selected: _type == HouseType.masonry,
          onTap: () => setState(() => _type = HouseType.masonry),
        ),
        SelectionTile(
          label: hi ? 'ईंट की दीवारें, ऊपर लेंटर (आरसीसी छत)' : 'Brick walls with an RCC slab roof',
          selected: _type == HouseType.rccSlabNoBands,
          onTap: () => setState(() => _type = HouseType.rccSlabNoBands),
        ),
        SelectionTile(
          label: hi ? 'खंभों वाली आरसीसी इमारत' : 'RCC frame building with columns',
          selected: _type == HouseType.rccFrame,
          onTap: () => setState(() => _type = HouseType.rccFrame),
        ),
        if (_type == HouseType.mud)
          ToolAnswer(
            headline: hi ? 'सबसे बड़ा ख़तरा: भारी छत' : 'The biggest danger: a heavy roof',
            detail: hi
                ? 'कच्चे घर में मौत ज़्यादातर भारी छत से होती है — मिट्टी की मोटी परत, '
                    'पत्थर की पटिया, या छत पर रखे पत्थर — जो कमज़ोर दीवारों के हिलते '
                    'ही नीचे आ जाती है। सबसे सस्ता और सबसे असरदार काम: छत हल्की '
                    'करना। उसके बाद: दरवाज़े-खिड़की की ऊँचाई पर लकड़ी या बाँस का एक '
                    'घेरा (बैंड) पूरी दीवार पर बाँधना, और कोनों पर दोनों दीवारों को '
                    'जोड़ना। बीएमटीपीसी की पुस्तिकाएँ हिंदी में यही तरीक़े चित्रों '
                    'के साथ बताती हैं।'
                : 'In a kutcha house most deaths come from a heavy roof - a '
                    'thick layer of mud, stone slabs, or stones laid on the '
                    'roof - which comes down as soon as the weak walls '
                    'sway. The cheapest and most effective step: lighten the '
                    'roof. After that: a continuous band of timber or bamboo '
                    'around all walls at door-top height, and tying the two '
                    'walls together at each corner. BMTPC\'s booklets show '
                    'exactly these methods with drawings, in Hindi too.',
            tone: ToolTone.bad,
            icon: Icons.roofing_outlined,
          ),
        if (_type == HouseType.masonry)
          ToolAnswer(
            headline: hi ? 'घेरा (बैंड) और कोने' : 'Bands and corners',
            detail: hi
                ? 'ईंट-पत्थर की दीवारें भूकंप में कोनों से खुलती हैं और बाहर गिरती '
                    'हैं। जो चीज़ उन्हें बाँधे रखती है वह है दरवाज़े-खिड़की के ऊपर और '
                    'छत के नीचे पूरी दीवार पर चलने वाला कंक्रीट का पतला घेरा (लिंटल '
                    'बैंड और रूफ़ बैंड), और कोनों में खड़ी सरिया। नया घर बन रहा हो तो '
                    'यह ख़र्च बहुत कम है — मिस्त्री से कहें। पुराने घर में भी '
                    'दीवार के बाहर तार-जाली और प्लास्टर से यह जोड़ा जा सकता है। '
                    'खिड़की-दरवाज़े कोने से कम से कम दो फ़ुट दूर रखें।'
                : 'Brick and stone walls open at the corners in an '
                    'earthquake and fall outwards. What holds them together '
                    'is a thin concrete band running around every wall above '
                    'the doors and windows and under the roof (lintel band '
                    'and roof band), and vertical bars at the corners. In a '
                    'house being built the cost is small - tell the mason. In '
                    'an old house it can be added on the outside with wire '
                    'mesh and plaster. Keep doors and windows at least two '
                    'feet from a corner.',
            tone: ToolTone.warn,
            icon: Icons.foundation_outlined,
          ),
        if (_type == HouseType.rccSlabNoBands)
          ToolAnswer(
            headline: hi ? 'छत मज़बूत, दीवारें नहीं' : 'A strong roof on walls that are not',
            detail: hi
                ? 'लेंटर की छत भारी होती है, और बिना घेरे (बैंड) वाली ईंट की दीवारों '
                    'पर टिकी हो तो सबसे ख़तरनाक मेल बनता है — दीवारें खिसकें तो पूरी '
                    'छत एक साथ गिरती है। देखें कि दरवाज़ों के ऊपर पूरी दीवार पर '
                    'कंक्रीट का घेरा है या सिर्फ़ दरवाज़ों के ऊपर अलग-अलग टुकड़े। '
                    'घेरा न हो तो मज़बूती का काम किसी जानकार मिस्त्री या इंजीनियर से '
                    'कराएँ। ऊपर एक और मंज़िल डालने से पहले इंजीनियर से ज़रूर पूछें।'
                : 'A slab roof is heavy, and resting on brick walls without '
                    'bands it makes the most dangerous combination - if the '
                    'walls shift, the whole slab comes down at once. Look '
                    'whether there is a concrete band running around the '
                    'whole wall above the doors, or only separate pieces over '
                    'each opening. If there is no band, have strengthening '
                    'done by a trained mason or an engineer. Ask an engineer '
                    'before adding another floor on top.',
            tone: ToolTone.warn,
            icon: Icons.house_outlined,
          ),
        if (_type == HouseType.rccFrame)
          ToolAnswer(
            headline: hi ? 'तीन चीज़ें देखें' : 'Three things to look for',
            detail: hi
                ? 'खंभों वाली इमारत तब सुरक्षित है जब वह नक़्शे और मानक के हिसाब से '
                    'बनी हो। तीन आम कमज़ोरियाँ देखें: (1) नीचे की मंज़िल खुली — सिर्फ़ '
                    'खंभे, पार्किंग या दुकान के लिए, और ऊपर भरी हुई दीवारें; भूकंप में '
                    'यही मंज़िल बैठती है। (2) छत पर बड़ी पानी की टंकी या बाद में जोड़ी '
                    'गई मंज़िल। (3) खंभों में दरारें या सरिया दिखना। इनमें से कुछ भी '
                    'हो तो किसी स्ट्रक्चरल इंजीनियर से जाँच कराएँ।'
                : 'A column building is safe when it was built to the plan '
                    'and the code. Look for the three common weaknesses: (1) '
                    'an open ground floor - columns only, for parking or '
                    'shops - with walled floors above; that is the storey '
                    'that collapses. (2) A large water tank on the roof, or a '
                    'floor added later. (3) Cracked columns or exposed bars. '
                    'If you see any of these, have a structural engineer look '
                    'at it.',
            tone: ToolTone.warn,
            icon: Icons.apartment_outlined,
          ),
        if (_type != null) ...[
          const SizedBox(height: 14),
          Text(hi ? 'घर के अंदर — आज ही, बिना ख़र्च' : 'Inside the house - today, at no cost',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            numbered: false,
            steps: hi
                ? const [
                    'अलमारी और ऊँची रैक दीवार से बाँध या कील से जोड़ दें',
                    'भारी सामान नीचे की ताक पर, हल्का ऊपर',
                    'सोने की जगह खिड़की के शीशे और भारी अलमारी से दूर',
                    'गैस सिलेंडर खड़ा रखें और दीवार से ज़ंजीर या पट्टी से बाँधें',
                    'घर में सबको बता दें: झटका आए तो नीचे बैठें, मज़बूत मेज़ के नीचे '
                        'सिर ढकें, और हिलना रुकने तक पकड़े रहें। झटके के बीच सीढ़ी '
                        'से न भागें',
                    'बाहर मिलने की एक खुली जगह तय कर लें, बिजली के तारों और '
                        'दीवारों से दूर',
                  ]
                : const [
                    'Tie or nail almirahs and tall racks to the wall',
                    'Heavy things on the low shelves, light things above',
                    'Sleep away from window glass and heavy almirahs',
                    'Keep the gas cylinder upright and chained or strapped to '
                        'the wall',
                    'Tell everyone at home: when it shakes, drop down, cover '
                        'your head under a sturdy table, and hold on until '
                        'the shaking stops. Do not run for the stairs during '
                        'the shaking',
                    'Agree on an open place outside to meet, away from power '
                        'lines and walls',
                  ],
          ),
          const SourceNote(
              text: 'Building Materials and Technology Promotion Council',
              url: _bmtpcUrl),
          const SourceNote(
              text: 'National Disaster Management Authority', url: _ndmaUrl),
        ],
      ],
    );
  }
}

// --- Road accident ----------------------------------------------------

class RoadAccidentPage extends StatelessWidget {
  const RoadAccidentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 11,
      title: hi ? 'सड़क दुर्घटना: क्या करें' : 'Road accident: what to do',
      children: [
        ToolAnswer(
          headline: hi ? 'पहले 112 या 108 पर फ़ोन' : 'Call 112 or 108 first',
          detail: hi
              ? 'जगह बताएँ — सड़क का नाम, पास का गाँव, कोई दुकान या पत्थर पर लिखा '
                  'किलोमीटर — कितने लोग घायल हैं, और कोई बेहोश है या ख़ून बह रहा है। '
                  'फ़ोन चालू रखें।'
              : 'Give the place - the road, the nearest village, a shop, or '
                  'the kilometre stone - how many are hurt, and whether '
                  'anyone is unconscious or bleeding. Keep the phone on.',
          tone: ToolTone.bad,
          icon: Icons.phone_in_talk_outlined,
        ),
        const SizedBox(height: 12),
        Text(hi ? 'पहले दस मिनट' : 'The first ten minutes',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'अपनी सुरक्षा पहले: अपनी गाड़ी किनारे लगाएँ, जलती-बुझती बत्ती '
                      'चालू करें, और पीछे से आने वाले ट्रैफ़िक को कोई हाथ हिलाकर '
                      'धीमा कराए।',
                  'घायल को तभी हिलाएँ जब वहाँ रुकना ज़्यादा ख़तरनाक हो — आग, '
                      'तेल रिसाव, या बीच सड़क। गर्दन और कमर की चोट हिलाने से '
                      'बिगड़ती है।',
                  'ख़ून बह रहा हो तो साफ़ कपड़ा रखकर ज़ोर से दबाए रखें। कपड़ा भीग '
                      'जाए तो हटाएँ नहीं, उसके ऊपर दूसरा रखें।',
                  'दोपहिया वाले का हेलमेट न उतारें, जब तक साँस में रुकावट न हो।',
                  'बेहोश या गंभीर घायल को पानी या खाना न दें।',
                  'उससे बात करते रहें, गरम रखें, और भीड़ को दूर रखें ताकि हवा मिले।',
                ]
              : const [
                  'Your own safety first: pull your vehicle aside, turn on '
                      'the hazard lights, and have someone wave down the '
                      'traffic coming from behind.',
                  'Move the injured only if staying is more dangerous - fire, '
                      'leaking fuel, or the middle of the road. Neck and back '
                      'injuries worsen when moved.',
                  'If there is bleeding, press a clean cloth on it firmly and '
                      'keep pressing. If it soaks through, do not lift it - '
                      'put another on top.',
                  'Do not remove a two-wheeler rider\'s helmet unless it is '
                      'blocking their breathing.',
                  'Give no water or food to someone unconscious or badly '
                      'hurt.',
                  'Keep talking to them, keep them warm, and keep the crowd '
                      'back so there is air.',
                ],
        ),
        const SizedBox(height: 14),
        ToolAnswer(
          headline: hi ? 'मदद करने वाले को क़ानून की सुरक्षा' : 'The law protects whoever helps',
          detail: hi
              ? 'मोटर वाहन अधिनियम की धारा 134ए के अनुसार जो व्यक्ति नेक नीयत से '
                  'घायल की मदद करता है या उसे अस्पताल पहुँचाता है, उस पर कोई दीवानी '
                  'या आपराधिक कार्यवाही नहीं होगी। नियम यह भी कहते हैं: अस्पताल '
                  'आपको रोक नहीं सकता और आपसे पैसे नहीं माँग सकता; पुलिस आपको अपना '
                  'नाम-पता बताने पर मजबूर नहीं कर सकती; और गवाह बनना आपकी मर्ज़ी '
                  'है। गवाह बनें तो बयान एक ही बार में लिया जाना है।'
              : 'Under section 134A of the Motor Vehicles Act, a person who '
                  'in good faith helps an injured person or takes them to '
                  'hospital faces no civil or criminal action. The rules '
                  'also say: the hospital may not detain you or ask you for '
                  'money; the police may not force you to give your name or '
                  'address; and being a witness is your choice. If you '
                  'choose to be one, your statement is to be taken in a '
                  'single sitting.',
          tone: ToolTone.good,
          icon: Icons.shield_outlined,
        ),
        const SizedBox(height: 10),
        ToolLine(
            hi ? 'घायल को अस्पताल पहुँचाने पर इनाम (राहवीर)' : 'Reward for getting the injured to hospital (Rah-Veer)',
            '₹$rahVeerReward',
            strong: true),
        ToolLine(
            hi
                ? 'घायल का नक़द-रहित इलाज, नामित अस्पतालों में'
                : 'Cashless treatment for the injured, at designated hospitals',
            hi
                ? '₹$accidentCashlessRupees तक, $accidentCashlessDays दिन'
                : 'Up to ₹$accidentCashlessRupees, $accidentCashlessDays days'),
        const SizedBox(height: 8),
        ToolNote(hi
            ? 'राहवीर योजना में गंभीर रूप से घायल व्यक्ति को जल्दी अस्पताल पहुँचाने '
                'वाले को इनाम मिलता है; अस्पताल या पुलिस इसकी पुष्टि करती है और '
                'ज़िले की समिति मंज़ूरी देती है। नक़द-रहित इलाज की योजना में दुर्घटना '
                'के बाद के पहले दिनों का इलाज नामित अस्पतालों में बिना पैसे के होता '
                'है, और पुलिस को सूचना जाती है। दोनों योजनाओं की ताज़ा शर्तें सड़क '
                'परिवहन मंत्रालय की वेबसाइट पर देखें।'
            : 'Under Rah-Veer, whoever gets a seriously injured person to '
                'hospital quickly is rewarded; the hospital or police confirm '
                'it and a district committee approves it. Under the cashless '
                'treatment scheme, care in the first days after the accident '
                'at designated hospitals costs the victim nothing, and the '
                'police are informed. Check the current terms of both on the '
                'Ministry of Road Transport and Highways\' site.'),
        const SourceNote(
            text: 'Ministry of Road Transport and Highways', url: _morthUrl),
      ],
    );
  }
}
