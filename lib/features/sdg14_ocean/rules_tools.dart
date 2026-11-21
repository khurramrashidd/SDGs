import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// The rules of fishing - the boat's papers, the net, the protected
/// catch - and a safe clean-up.
///
/// Mesh sizes and the zones reserved for traditional craft are set by each
/// coastal state's Marine Fishing Regulation Act, and differ, so the net
/// screen carries no size. It teaches how to measure the mesh the way an
/// inspector does, which is the part that holds everywhere.

const _realcraftUrl = 'https://realcraft.gov.in/';
const _fisheriesUrl = 'https://dof.gov.in/';
const _wccbUrl = 'https://wccb.gov.in/';

// --- Boat registration and licence ------------------------------------

class BoatRegistrationPage extends StatelessWidget {
  const BoatRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 14,
      title: hi ? 'नाव का पंजीकरण और लाइसेंस' : 'Boat registration and licence',
      children: [
        ToolNote(hi
            ? 'दो अलग काग़ज़ हैं, और दोनों ज़रूरी हैं। पंजीकरण बताता है कि नाव किसकी '
                'है; लाइसेंस बताता है कि वह कहाँ और कैसे मछली पकड़ सकती है। डीज़ल '
                'सब्सिडी, बीमा, राहत और मुआवज़ा — सब इन्हीं काग़ज़ों पर टिके हैं।'
            : 'There are two separate papers, and both are needed. Registration '
                'says whose boat it is; the licence says where and how it may '
                'fish. Diesel subsidy, insurance, relief and compensation all '
                'rest on these papers.'),
        const SizedBox(height: 12),
        ToolLine(hi ? 'पंजीकरण' : 'Registration',
            hi ? 'एक बार; नाव बिकने या बदलने पर नया' : 'Once; again on sale or change',
            strong: true),
        ToolLine(hi ? 'मछली पकड़ने का लाइसेंस' : 'Fishing licence',
            hi ? 'राज्य के नियम से नवीनीकरण' : 'Renewed as the state requires',
            strong: true),
        const SizedBox(height: 12),
        Text(hi ? 'कैसे बनवाएँ' : 'How to get them',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'राज्य के मत्स्य विभाग में, या रियल-क्राफ़्ट पोर्टल (realcraft.gov.in) '
                      'पर ऑनलाइन आवेदन — यह देश भर की मछली पकड़ने वाली नावों का एक ही '
                      'पोर्टल है।',
                  'चाहिए: मालिक का आधार और फ़ोटो, नाव बनाने वाले का प्रमाण पत्र या '
                      'ख़रीद का काग़ज़, इंजन का ब्योरा, और पुरानी नाव हो तो पिछला '
                      'पंजीकरण।',
                  'विभाग नाव की जाँच करता है, फिर पंजीकरण संख्या देता है। वह संख्या '
                      'नाव पर तय रंग और जगह पर पेंट करनी होती है।',
                  'लाइसेंस की अवधि और नवीनीकरण राज्य तय करता है — ज़्यादातर जगह हर '
                      'साल। ख़त्म होने की तारीख़ फ़ोन में लिख लें।',
                  'हर साथी मछुआरे का बायोमीट्रिक पहचान पत्र भी बनवाएँ — मत्स्य विभाग '
                      'से।',
                ]
              : const [
                  'Apply at the state fisheries department, or online on the '
                      'ReALCraft portal (realcraft.gov.in) - one portal for '
                      'fishing boats across the country.',
                  'You need the owner\'s Aadhaar and photo, the builder\'s '
                      'certificate or the purchase paper, the engine details, '
                      'and the previous registration for a used boat.',
                  'The department inspects the boat, then issues the '
                      'registration number. That number has to be painted on '
                      'the boat in the set colour and place.',
                  'The state sets the licence period and renewal - yearly in '
                      'most places. Put the expiry date in your phone.',
                  'Get a biometric ID card for every crew member too - from '
                      'the fisheries department.',
                ],
        ),
        const SizedBox(height: 12),
        ToolDonts(
          heading: hi ? 'बिना काग़ज़ के' : 'Without the papers',
          items: hi
              ? const [
                  'बिना लाइसेंस मछली पकड़ने पर राज्य के क़ानून में जुर्माना और पकड़ी '
                      'मछली की ज़ब्ती हो सकती है',
                  'दुर्घटना, तूफ़ान या रोक के समय की सहायता बिना पंजीकरण के नहीं मिलती',
                  'सीमा पर पकड़े जाने पर पहचान साबित करने में देर लगती है',
                ]
              : const [
                  'Fishing without a licence can bring a fine and seizure of the '
                      'catch under state law',
                  'Support after an accident, a storm or during the ban does '
                      'not come without registration',
                  'If held at a border, proving identity takes far longer',
                ],
        ),
        const SourceNote(text: 'ReALCraft portal', url: _realcraftUrl),
      ],
    );
  }
}

// --- Is my net legal --------------------------------------------------

class NetLegalPage extends StatefulWidget {
  const NetLegalPage({super.key});

  @override
  State<NetLegalPage> createState() => _NetLegalPageState();
}

class _NetLegalPageState extends State<NetLegalPage> {
  final _measured = TextEditingController();
  final _rule = TextEditingController();

  @override
  void dispose() {
    _measured.dispose();
    _rule.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final measured = double.tryParse(_measured.text.trim()) ?? 0;
    final rule = double.tryParse(_rule.text.trim()) ?? 0;

    return ToolScaffold(
      goal: 14,
      title: hi ? 'क्या मेरा जाल क़ानूनी है' : 'Is my net legal',
      children: [
        ToolNote(hi
            ? 'जाल के छेद (मेश) का न्यूनतम आकार हर तटीय राज्य अपने समुद्री मत्स्य '
                'नियम में तय करता है, और जाल के प्रकार के हिसाब से अलग है। बहुत छोटे '
                'छेद वाला जाल छोटी, अधपकी मछली पकड़ लेता है — जो अगले साल की पकड़ '
                'थी। अपने राज्य का आकार मत्स्य विभाग या मछुआरा संघ से लें, और नीचे '
                'की तरह नापें।'
            : 'Each coastal state sets the minimum mesh size in its marine '
                'fishing rules, and it differs by type of net. A net with too '
                'small a mesh catches small, young fish - next year\'s catch. '
                'Get your state\'s size from the fisheries department or the '
                'fishers\' association, and measure as below.'),
        const SizedBox(height: 12),
        Text(hi ? 'निरीक्षक की तरह नापें' : 'Measure the way an inspector does',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'जाल गीला करें — सूखा जाल सिकुड़ा रहता है।',
                  'एक छेद को लंबाई की दिशा में खींचें, जितना खिंचे।',
                  'एक गाँठ के अंदर के सिरे से सामने वाली गाँठ के अंदर के सिरे तक नापें '
                      '— यह "खिंचा हुआ मेश" है।',
                  'कई जगह नापें, ख़ास कर पीछे की थैली (कॉड-एंड) में — नियम वहीं सबसे '
                      'सख़्ती से देखा जाता है।',
                ]
              : const [
                  'Wet the net - a dry net is shrunk.',
                  'Pull one mesh out lengthwise, as far as it will stretch.',
                  'Measure from the inside of one knot to the inside of the '
                      'opposite knot - this is the "stretched mesh".',
                  'Measure in several places, especially in the cod-end at the '
                      'back - that is where the rule is checked hardest.',
                ],
        ),
        ToolQuestion(hi ? 'मिलान करें' : 'Compare'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _measured,
                label: hi ? 'आपका नापा मेश (मिमी)' : 'Your mesh (mm)',
                decimal: true,
                maxDigits: 4,
                icon: Icons.straighten,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _rule,
                label: hi ? 'राज्य का न्यूनतम (मिमी)' : 'State minimum (mm)',
                decimal: true,
                maxDigits: 4,
                icon: Icons.rule,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        if (measured > 0 && rule > 0)
          ToolAnswer(
            headline: measured >= rule
                ? (hi ? 'आपका जाल नियम के भीतर है' : 'Your net is within the rule')
                : (hi
                    ? 'मेश ${(rule - measured).toStringAsFixed(0)} मिमी छोटा है'
                    : 'The mesh is ${(rule - measured).toStringAsFixed(0)} mm too small'),
            detail: measured >= rule
                ? (hi
                    ? 'जाल पुराना होने पर धागा खिंच या सिकुड़ सकता है — हर मौसम की '
                        'शुरुआत में एक बार फिर नापें।'
                    : 'Twine stretches or shrinks as a net ages - measure again '
                        'at the start of each season.')
                : (hi
                    ? 'ऐसे जाल पर जुर्माना और जाल की ज़ब्ती हो सकती है। कॉड-एंड बदलना '
                        'पूरा जाल बदलने से सस्ता पड़ता है — मत्स्य विभाग से पूछें कि '
                        'जाल बदलने में कोई सहायता है या नहीं।'
                    : 'A net like this can be fined and seized. Replacing the '
                        'cod-end costs less than the whole net - ask the '
                        'fisheries department whether there is any help for '
                        'replacing nets.'),
            tone: measured >= rule ? ToolTone.good : ToolTone.bad,
            icon: Icons.grid_on_outlined,
          ),
        const SizedBox(height: 14),
        ToolDonts(
          heading: hi ? 'जो हर जगह मना है' : 'Banned everywhere',
          items: hi
              ? const [
                  'विस्फोटक या ज़हर से मछली पकड़ना',
                  'गहरे समुद्र (विशेष आर्थिक क्षेत्र) में तेज़ रोशनी (एलईडी) से मछली '
                      'खींचना',
                  'रोक के महीनों में मशीन वाली नाव से मछली पकड़ना — इसी लक्ष्य में '
                      '"मछली पकड़ने पर रोक" वाली स्क्रीन देखें',
                  'जोड़ी में ट्रॉल खींचना और बुल ट्रॉलिंग — कई राज्यों में मना है',
                ]
              : const [
                  'Fishing with explosives or poison',
                  'Attracting fish with bright LED lights in the deep sea (the '
                      'Exclusive Economic Zone)',
                  'Mechanised fishing in the ban months - see "Is the fishing '
                      'ban on today" in this goal',
                  'Pair trawling and bull trawling - banned in many states',
                ],
        ),
        const SourceNote(text: 'Department of Fisheries', url: _fisheriesUrl),
      ],
    );
  }
}

// --- Protected species caught by mistake ------------------------------

enum Bycatch { turtle, whaleShark, dolphin, other }

class BycatchPage extends StatefulWidget {
  const BycatchPage({super.key});

  @override
  State<BycatchPage> createState() => _BycatchPageState();
}

class _BycatchPageState extends State<BycatchPage> {
  Bycatch? _kind;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 14,
      title: hi ? 'ग़लती से संरक्षित जीव जाल में' : 'Protected species caught by mistake',
      children: [
        ToolAnswer(
          headline: hi ? 'छोड़ना अपराध नहीं; रखना अपराध है' : 'Releasing it is no offence; keeping it is',
          detail: hi
              ? 'वन्यजीव संरक्षण अधिनियम में कई समुद्री जीव सबसे ऊँची सुरक्षा में हैं — '
                  'सभी समुद्री कछुए, व्हेल शार्क, डॉल्फ़िन और व्हेल, डुगोंग, आरा मछली '
                  '(सॉफ़िश), समुद्री घोड़ा, समुद्री खीरा, बड़ा ग्रूपर, और मूँगा। जाल में '
                  'ग़लती से आ जाना अपराध नहीं; उसे रखना, बेचना या उसका कोई हिस्सा पास '
                  'रखना अपराध है। जितनी जल्दी, उतने सुरक्षित तरीक़े से छोड़ें।'
              : 'Under the Wildlife Protection Act several sea creatures have '
                  'the highest protection - all sea turtles, the whale shark, '
                  'dolphins and whales, the dugong, sawfish, seahorses, sea '
                  'cucumbers, the giant grouper, and corals. Catching one by '
                  'accident is not an offence; keeping it, selling it or '
                  'holding any part of it is. Release it as fast and as safely '
                  'as you can.',
          tone: ToolTone.plain,
          icon: Icons.gavel_outlined,
        ),
        ToolQuestion(hi ? 'क्या फँसा है' : 'What is caught'),
        SelectionTile(
          label: hi ? 'समुद्री कछुआ' : 'A sea turtle',
          selected: _kind == Bycatch.turtle,
          onTap: () => setState(() => _kind = Bycatch.turtle),
        ),
        SelectionTile(
          label: hi ? 'व्हेल शार्क' : 'A whale shark',
          selected: _kind == Bycatch.whaleShark,
          onTap: () => setState(() => _kind = Bycatch.whaleShark),
        ),
        SelectionTile(
          label: hi ? 'डॉल्फ़िन या छोटी व्हेल' : 'A dolphin or small whale',
          selected: _kind == Bycatch.dolphin,
          onTap: () => setState(() => _kind = Bycatch.dolphin),
        ),
        SelectionTile(
          label: hi ? 'कुछ और' : 'Something else',
          selected: _kind == Bycatch.other,
          onTap: () => setState(() => _kind = Bycatch.other),
        ),
        if (_kind == Bycatch.turtle)
          ToolSteps(
            steps: hi
                ? const [
                    'पंख (फ़्लिपर) या पूँछ पकड़कर न उठाएँ — खोल के दोनों किनारे पकड़ें।',
                    'जाल में उलझा हो तो जाल सावधानी से काटें; पंख न खींचें।',
                    'कछुआ हिल-डुल नहीं रहा हो तो मरा न समझें — उसे छाया में रखें, '
                        'शरीर गीले कपड़े से नम रखें, और पीछे का हिस्सा थोड़ा ऊँचा '
                        'करके कुछ घंटे दें। कई कछुए होश में आ जाते हैं।',
                    'इंजन बंद या न्यूट्रल में करके, पानी की सतह के पास से धीरे छोड़ें — '
                        'ऊँचाई से न फेंकें।',
                  ]
                : const [
                    'Do not lift it by a flipper or the tail - hold both edges '
                        'of the shell.',
                    'If it is tangled, cut the net carefully; do not pull the '
                        'flippers.',
                    'A turtle that is not moving may not be dead - keep it in '
                        'shade, keep it damp with a wet cloth, and give it some '
                        'hours with the back end raised a little. Many come '
                        'round.',
                    'With the engine off or in neutral, lower it gently at the '
                        'water\'s surface - do not throw it from a height.',
                  ],
          ),
        if (_kind == Bycatch.whaleShark)
          ToolSteps(
            steps: hi
                ? const [
                    'इसे खींचकर नाव पर न लाएँ — यह बहुत भारी है और पानी से बाहर मर जाती '
                        'है।',
                    'जाल काटकर रास्ता बनाएँ ताकि वह ख़ुद निकल जाए।',
                    'कटे जाल की फ़ोटो और जगह दर्ज करें। कुछ राज्य — जैसे गुजरात — व्हेल '
                        'शार्क छोड़ने के लिए काटे गए जाल का मुआवज़ा देते हैं; अपने राज्य '
                        'के वन विभाग से पूछें।',
                  ]
                : const [
                    'Do not try to haul it aboard - it is very heavy and dies '
                        'out of water.',
                    'Cut the net to open a way so it can swim out.',
                    'Photograph the cut net and note the place. Some states - '
                        'Gujarat, for one - compensate a net cut to free a '
                        'whale shark; ask your state forest department.',
                  ],
          ),
        if (_kind == Bycatch.dolphin)
          ToolSteps(
            steps: hi
                ? const [
                    'उसके सिर के ऊपर का साँस का छेद पानी और जाल से बाहर रखें — वह हवा '
                        'में साँस लेती है।',
                    'जाल धीरे-धीरे काटें, पंख या पूँछ न खींचें।',
                    'जितनी जल्दी हो सके, पानी में छोड़ें।',
                  ]
                : const [
                    'Keep the blowhole on top of its head clear of water and net '
                        '- it breathes air.',
                    'Cut the net away slowly; do not pull fins or tail.',
                    'Return it to the water as quickly as you can.',
                  ],
          ),
        if (_kind == Bycatch.other)
          ToolNote(hi
              ? 'पता न हो कि जीव संरक्षित है या नहीं, तो उसे छोड़ दें और फ़ोटो ले लें। '
                  'संरक्षित जीव को छोड़ने में कुछ नहीं जाता; रखने में जुर्माना और जेल '
                  'तक हो सकती है।'
              : 'If you are not sure whether it is protected, release it and '
                  'take a photo. Releasing a protected creature costs nothing; '
                  'keeping one can mean a fine and even jail.'),
        if (_kind != null) ...[
          const SizedBox(height: 12),
          ToolAnswer(
            headline: hi ? 'बताना — सही तरीक़े से' : 'Reporting it - the right way',
            detail: hi
                ? 'छोड़ने के बाद वन विभाग या मत्स्य विभाग को बताएँ: क्या था, कहाँ, कब, '
                    'और फ़ोटो। यह जानकारी गिनती और बचाव में काम आती है, और आपके पक्ष '
                    'में रिकॉर्ड भी बनाती है कि आपने छोड़ा। मरा हुआ जीव किनारे पर '
                    'मिले तो छुएँ नहीं, न उसका कोई हिस्सा लें — वन विभाग को बताएँ।'
                : 'After releasing it, tell the forest or fisheries department: '
                    'what it was, where, when, and a photo. The information '
                    'helps the count and the protection, and puts on record in '
                    'your favour that you let it go. If you find a dead one on '
                    'the shore, do not touch it or take any part - report it '
                    'to the forest department.',
            tone: ToolTone.plain,
            icon: Icons.report_outlined,
          ),
          const SourceNote(
              text: 'Wildlife Crime Control Bureau', url: _wccbUrl),
        ],
      ],
    );
  }
}

// --- Clean-up ---------------------------------------------------------

class CleanupPage extends StatelessWidget {
  const CleanupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 14,
      title: hi ? 'सफ़ाई अभियान, सुरक्षित तरीक़े से' : 'Organise a clean-up safely',
      children: [
        ToolNote(hi
            ? 'तट या नदी की सफ़ाई में सबसे आम चोटें तीन हैं: टूटा काँच और सुई, '
                'लहर या बहाव, और धूप। यह सूची इन तीनों के हिसाब से बनी है। निशान इस '
                'फ़ोन में रहते हैं।'
            : 'The three commonest injuries on a beach or river clean-up are '
                'broken glass and needles, a wave or current, and the sun. This '
                'list is built around those three. The ticks stay on this '
                'phone.'),
        const SizedBox(height: 10),
        const ToolChecklist(
          storageKey: 'cleanup_plan_v1',
          introEn: 'Tick each one as it is arranged.',
          introHi: 'जो इंतज़ाम हो जाए, उस पर निशान लगाएँ।',
          items: [
            CheckItem('tell', 'Panchayat or municipality told, and asked to collect',
                'पंचायत या नगर पालिका को बताया, और कचरा उठाने को कहा',
                noteEn: 'Bags left on the beach go back into the sea with the '
                    'next tide.',
                noteHi: 'तट पर छोड़े गए थैले अगले ज्वार में वापस समुद्र में चले '
                    'जाते हैं।'),
            CheckItem('nests', 'No turtle nesting or bird breeding on that stretch now',
                'उस हिस्से में अभी कछुओं के अंडे या पक्षियों के घोंसले नहीं',
                noteEn: 'Ask the forest department. Nesting beaches are closed '
                    'for months, and a clean-up can do more harm than the '
                    'rubbish.',
                noteHi: 'वन विभाग से पूछें। अंडे देने वाले तट महीनों बंद रहते हैं, और '
                    'वहाँ सफ़ाई कचरे से ज़्यादा नुक़सान कर सकती है।'),
            CheckItem('tide', 'Tide times checked; work on a falling tide',
                'ज्वार का समय देखा; उतरते पानी में काम',
                noteEn: 'Nobody goes into the water to fetch anything.',
                noteHi: 'कुछ भी उठाने के लिए कोई पानी में नहीं जाएगा।'),
            CheckItem('gloves', 'Thick gloves and closed shoes for everyone',
                'सबके लिए मोटे दस्ताने और बंद जूते'),
            CheckItem('sharps', 'A hard bottle or tin for glass and needles',
                'काँच और सुई के लिए कड़ी बोतल या डिब्बा',
                noteEn: 'Pick them up with tongs, never by hand. Medical waste '
                    'and chemical drums are left alone and reported.',
                noteHi: 'चिमटे से उठाएँ, हाथ से कभी नहीं। अस्पताल का कचरा और रसायन '
                    'के ड्रम न छुएँ — उनकी सूचना दें।'),
            CheckItem('water', 'Drinking water, shade and a break every hour',
                'पीने का पानी, छाया, और हर घंटे आराम'),
            CheckItem('kids', 'One adult for every few children, kept away from the water',
                'कुछ बच्चों पर एक बड़ा, बच्चे पानी से दूर'),
            CheckItem('firstaid', 'First aid kit, and someone who knows it',
                'प्राथमिक उपचार का डिब्बा, और उसे जानने वाला'),
            CheckItem('sort', 'Separate bags: plastic, glass, metal, nets',
                'अलग थैले: प्लास्टिक, काँच, धातु, जाल',
                noteEn: 'Old fishing nets are worth keeping apart - some buyers '
                    'and recyclers take them.',
                noteHi: 'पुराने जाल अलग रखें — कुछ ख़रीदार और रीसाइक्लर इन्हें लेते '
                    'हैं।'),
            CheckItem('animals', 'Dead animals left untouched and reported',
                'मरे जीव छुए नहीं जाएँगे, सूचना दी जाएगी'),
          ],
        ),
        const SourceNote(text: 'Department of Fisheries', url: _fisheriesUrl),
      ],
    );
  }
}
