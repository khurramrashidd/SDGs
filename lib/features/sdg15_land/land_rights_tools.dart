import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Land: cutting a tree, reading the record, converting the units, and an
/// encroachment.
///
/// The converter only carries units that mean the same thing everywhere.
/// A bigha or a katha differs between states and sometimes between
/// districts of one state, so those are entered by the user from what the
/// patwari says - a wrong preset would silently corrupt a land deal.

// The NTMS portal's own address is given out by the state forest
// department; the ministry that issued the model rules is the source here.
const _moefccUrl = 'https://moef.gov.in/';
const _dilrmpUrl = 'https://dilrmp.gov.in/';
const _nalsaUrl = 'https://nalsa.gov.in/';

// --- Tree felling -----------------------------------------------------

enum TreeWhere { ownFarm, ownHouse, roadside, forest }

class TreeFellingPage extends StatefulWidget {
  const TreeFellingPage({super.key});

  @override
  State<TreeFellingPage> createState() => _TreeFellingPageState();
}

class _TreeFellingPageState extends State<TreeFellingPage> {
  TreeWhere? _where;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 15,
      title: hi ? 'क्या यह पेड़ काटने की अनुमति चाहिए' : 'Do I need permission to cut this tree',
      children: [
        ToolQuestion(hi ? 'पेड़ कहाँ है' : 'Where is the tree'),
        SelectionTile(
          label: hi ? 'अपने खेत में' : 'On my own farmland',
          selected: _where == TreeWhere.ownFarm,
          onTap: () => setState(() => _where = TreeWhere.ownFarm),
        ),
        SelectionTile(
          label: hi ? 'अपने घर या प्लॉट में' : 'At my house or plot',
          selected: _where == TreeWhere.ownHouse,
          onTap: () => setState(() => _where = TreeWhere.ownHouse),
        ),
        SelectionTile(
          label: hi ? 'सड़क किनारे, नहर या सरकारी ज़मीन पर' : 'By a road, a canal, or on government land',
          selected: _where == TreeWhere.roadside,
          onTap: () => setState(() => _where = TreeWhere.roadside),
        ),
        SelectionTile(
          label: hi ? 'जंगल में' : 'In a forest',
          selected: _where == TreeWhere.forest,
          onTap: () => setState(() => _where = TreeWhere.forest),
        ),
        if (_where == TreeWhere.ownFarm)
          ToolAnswer(
            headline: hi ? 'नया राष्ट्रीय पोर्टल, और राज्य का नियम' : 'The new national portal, and the state rule',
            detail: hi
                ? 'पर्यावरण मंत्रालय ने 2025 में खेत में लगे पेड़ काटने के आदर्श नियम '
                    'जारी किए हैं, और राज्य उन्हें अपना रहे हैं। उनमें: पेड़ों का '
                    'पंजीकरण राष्ट्रीय इमारती लकड़ी प्रबंधन प्रणाली (एनटीएमएस) पोर्टल पर, '
                    'और 10 या उससे कम पेड़ काटने के लिए वहीं स्व-घोषणा से अपने आप '
                    'अनापत्ति मिल जाती है; 10 से ज़्यादा पर जाँच होती है। आपके राज्य ने '
                    'ये नियम अपनाए हैं या नहीं, वन विभाग से पूछें — नहीं तो राज्य का '
                    'अपना वृक्ष संरक्षण क़ानून चलता है, जिसमें कुछ प्रजातियों — जैसे '
                    'चंदन, सागौन, साल, खैर — के लिए अनुमति ज़रूरी हो सकती है।'
                : 'In 2025 the environment ministry issued model rules for '
                    'felling trees on farmland, and states are adopting them. '
                    'Under them: trees are registered on the National Timber '
                    'Management System (NTMS) portal, and felling 10 or fewer '
                    'can be self-declared there for an automatic no-objection; '
                    'more than 10 are verified. Ask the forest department '
                    'whether your state has adopted them - if not, the state\'s '
                    'own tree preservation law applies, which may require '
                    'permission for some species such as sandalwood, teak, sal '
                    'or khair.',
            tone: ToolTone.plain,
            icon: Icons.forest_outlined,
          ),
        if (_where == TreeWhere.ownHouse)
          ToolAnswer(
            headline: hi ? 'शहर में अक्सर अनुमति ज़रूरी' : 'In a town, permission is often required',
            detail: hi
                ? 'कई शहरों और राज्यों के वृक्ष क़ानून में अपने ही प्लॉट का पेड़ काटने '
                    'के लिए भी नगर पालिका के वृक्ष अधिकारी या वन विभाग की अनुमति लगती है, '
                    'और कई बार बदले में नए पेड़ लगाने की शर्त भी। पेड़ गिरने वाला या '
                    'ख़तरनाक हो तो पहले उसकी फ़ोटो के साथ आवेदन दें — आपात स्थिति में '
                    'नगर पालिका ख़ुद कटवा सकती है।'
                : 'In many towns and states the tree law requires permission '
                    'from the municipal tree officer or the forest department '
                    'even to fell a tree on your own plot, often with a '
                    'condition to plant new ones. If the tree is about to fall '
                    'or is dangerous, apply with a photo first - in an '
                    'emergency the municipality can have it cut itself.',
            tone: ToolTone.warn,
            icon: Icons.location_city_outlined,
          ),
        if (_where == TreeWhere.roadside)
          ToolAnswer(
            headline: hi ? 'ख़ुद न काटें' : 'Do not cut it yourself',
            detail: hi
                ? 'सड़क, नहर या सरकारी ज़मीन का पेड़ सरकार की संपत्ति है — उसे काटना '
                    'या उसकी डालियाँ बेचना अपराध है। पेड़ ख़तरनाक हो तो पीडब्ल्यूडी, '
                    'नगर पालिका या वन विभाग को फ़ोटो के साथ लिखित सूचना दें।'
                : 'A tree by a road, a canal or on government land is government '
                    'property - cutting it or selling its branches is an '
                    'offence. If it is dangerous, give written notice with a '
                    'photo to the PWD, the municipality or the forest '
                    'department.',
            tone: ToolTone.bad,
            icon: Icons.block,
          ),
        if (_where == TreeWhere.forest)
          ToolAnswer(
            headline: hi ? 'जंगल का पेड़ काटना अपराध है' : 'Felling in a forest is an offence',
            detail: hi
                ? 'वन क़ानून में जंगल से पेड़ काटना, लकड़ी ले जाना या बेचना अपराध है। '
                    'वनवासी समुदायों के सूखी लकड़ी, लघु वनोपज और घरेलू ज़रूरत के हक़ '
                    'वन अधिकार अधिनियम में अलग से हैं — इसी लक्ष्य में "वन अधिकार" '
                    'वाली स्क्रीन देखें।'
                : 'Under forest law, felling, carrying or selling wood from a '
                    'forest is an offence. Forest-dwelling communities\' rights '
                    'to dead wood, minor forest produce and household needs are '
                    'separate, under the Forest Rights Act - see "Forest rights" '
                    'in this goal.',
            tone: ToolTone.bad,
            icon: Icons.park_outlined,
          ),
        if (_where != null) ...[
          const SizedBox(height: 12),
          ToolNote(hi
              ? 'लकड़ी एक जगह से दूसरी जगह ले जाने के लिए कई राज्यों में "ट्रांज़िट '
                  'पास" लगता है — बिना पास के लकड़ी ज़ब्त हो सकती है, चाहे पेड़ अपनी ही '
                  'ज़मीन का हो।'
              : 'Moving the timber from one place to another needs a "transit '
                  'pass" in many states - without it the wood can be seized, '
                  'even from your own land.'),
          const SourceNote(
              text: 'Ministry of Environment, Forest and Climate Change',
              url: _moefccUrl),
        ],
      ],
    );
  }
}

// --- Land record check ------------------------------------------------

class LandRecordPage extends StatelessWidget {
  const LandRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 15,
      title: hi ? 'ज़मीन का रिकॉर्ड जाँचें' : 'Land record check',
      children: [
        ToolNote(hi
            ? 'ज़मीन का रिकॉर्ड (खतौनी, जमाबंदी, 7/12, पट्टा — राज्य के हिसाब से नाम '
                'अलग) राज्य के भूमि रिकॉर्ड पोर्टल पर मुफ़्त देखा जा सकता है। हर ज़मीन '
                'के टुकड़े को अब 14 अंकों की एक पहचान संख्या (भू-आधार / यूएलपिन) भी '
                'मिल रही है। नीचे की हर पंक्ति अपने रिकॉर्ड से मिलाइए।'
            : 'The land record (khatauni, jamabandi, 7/12, patta - the name '
                'differs by state) can be seen free on the state land records '
                'portal. Each parcel is also being given a 14-digit '
                'identification number (Bhu-Aadhaar / ULPIN). Check every line '
                'below against your record.'),
        const SizedBox(height: 10),
        const ToolChecklist(
          storageKey: 'land_record_check_v1',
          introEn: 'Tick each line once it matches.',
          introHi: 'जो पंक्ति मेल खा जाए, उस पर निशान लगाएँ।',
          items: [
            CheckItem('name', 'Every owner\'s name, spelt as on Aadhaar',
                'हर मालिक का नाम, आधार जैसी हिज्जे में',
                noteEn: 'A spelling difference is the commonest reason a loan, '
                    'a sale or PM-Kisan gets stuck.',
                noteHi: 'हिज्जे का फ़र्क़ ही ऋण, बिक्री या किसान सम्मान निधि अटकने '
                    'की सबसे आम वजह है।'),
            CheckItem('share', 'Each owner\'s share', 'हर मालिक का हिस्सा',
                noteEn: 'After an inheritance, check that every heir is there - '
                    'daughters included.',
                noteHi: 'विरासत के बाद देखें कि सब वारिस दर्ज हैं — बेटियाँ भी।'),
            CheckItem('number', 'The khasra or survey number', 'खसरा या सर्वे संख्या'),
            CheckItem('area', 'The area, and its unit', 'रक़बा, और उसकी इकाई',
                noteEn: 'Convert it with "Land measurement converter" in this '
                    'goal and compare with what you actually hold.',
                noteHi: 'इसी लक्ष्य में "ज़मीन की नाप बदलें" से बदलकर देखें कि आपके '
                    'पास असल में उतनी है या नहीं।'),
            CheckItem('type', 'The type of land: agricultural, residential, government',
                'ज़मीन का प्रकार: खेती, आवासीय, सरकारी'),
            CheckItem('charge', 'No mortgage or loan entry you do not know about',
                'कोई अनजान गिरवी या ऋण की प्रविष्टि नहीं',
                noteEn: 'An old loan entry that was repaid should have been '
                    'removed - ask the bank for a no-dues letter.',
                noteHi: 'चुका दिया गया पुराना ऋण रिकॉर्ड से हटना चाहिए — बैंक से '
                    'बेबाकी प्रमाण पत्र माँगें।'),
            CheckItem('mutation', 'The last mutation entry matches what happened',
                'आख़िरी दाख़िल-ख़ारिज वही है जो हुआ'),
          ],
        ),
        const SizedBox(height: 12),
        Text(hi ? 'ग़लती मिले तो' : 'If something is wrong',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'रिकॉर्ड का प्रिंट निकालें और ग़लती पर निशान लगाएँ।',
                  'तहसीलदार के पास सुधार का लिखित आवेदन दें, सही बात दिखाने वाले काग़ज़ के '
                      'साथ — बैनामा, पुराना रिकॉर्ड, या वारिस प्रमाण पत्र। रसीद लें।',
                  'लिखने की साधारण ग़लती (हिज्जे, अंक) आम तौर पर तहसील में ही ठीक हो '
                      'जाती है। हिस्से या मालिकाना हक़ का झगड़ा हो तो वह राजस्व अदालत या '
                      'दीवानी अदालत का मामला है।',
                  'मुफ़्त कानूनी सलाह ज़िला विधिक सेवा प्राधिकरण से।',
                ]
              : const [
                  'Print the record and mark the error.',
                  'Give the tehsildar a written correction application with the '
                      'paper that shows what is right - the sale deed, an older '
                      'record, or the legal heir certificate. Take a receipt.',
                  'A plain clerical mistake (spelling, a figure) is usually '
                      'fixed at the tehsil itself. A dispute over shares or '
                      'title is for the revenue court or the civil court.',
                  'Free legal advice from the District Legal Services '
                      'Authority.',
                ],
        ),
        const SourceNote(
            text: 'Digital India Land Records Modernisation Programme',
            url: _dilrmpUrl),
      ],
    );
  }
}

// --- Land measurement converter ---------------------------------------

class _Unit {
  final String en;
  final String hi;
  final double sqm;
  const _Unit(this.en, this.hi, this.sqm);
}

/// Units with the same size everywhere.
const _units = <_Unit>[
  _Unit('Acre', 'एकड़', 4046.8564),
  _Unit('Hectare', 'हेक्टेयर', 10000),
  _Unit('Guntha', 'गुंठा', 101.1714),
  _Unit('Cent', 'सेंट', 40.4686),
  _Unit('Square metre', 'वर्ग मीटर', 1),
  _Unit('Square foot', 'वर्ग फ़ुट', 0.09290304),
  _Unit('Square yard (gaj)', 'वर्ग गज़', 0.83612736),
];

class LandUnitPage extends StatefulWidget {
  const LandUnitPage({super.key});

  @override
  State<LandUnitPage> createState() => _LandUnitPageState();
}

class _LandUnitPageState extends State<LandUnitPage> {
  final _amount = TextEditingController();
  final _localSqft = TextEditingController();
  final _localName = TextEditingController();
  int _from = 0;
  bool _fromLocal = false;

  @override
  void dispose() {
    _amount.dispose();
    _localSqft.dispose();
    _localName.dispose();
    super.dispose();
  }

  String _fmt(double v) {
    if (v >= 1000) return v.toStringAsFixed(0);
    if (v >= 10) return v.toStringAsFixed(2);
    return v.toStringAsFixed(4);
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    final localSqft = double.tryParse(_localSqft.text.trim()) ?? 0;
    final localSqm = localSqft * 0.09290304;
    final localName = _localName.text.trim().isEmpty
        ? (hi ? 'स्थानीय इकाई' : 'local unit')
        : _localName.text.trim();
    final sqm = _fromLocal ? amount * localSqm : amount * _units[_from].sqm;

    return ToolScaffold(
      goal: 15,
      title: hi ? 'ज़मीन की नाप बदलें' : 'Land measurement converter',
      children: [
        ToolNote(hi
            ? 'बीघा, बिस्वा, कट्ठा, मरला और कनाल का आकार राज्य-राज्य में अलग है, और '
                'कई बार एक ही राज्य के ज़िलों में भी। इसलिए इन्हें इस ऐप में पहले से '
                'नहीं भरा गया — अपने पटवारी या लेखपाल से पूछकर वर्ग फ़ुट में डालें। '
                'ग़लत अंदाज़ा ज़मीन के सौदे में सबसे महँगी ग़लती बनता है।'
            : 'The size of a bigha, biswa, katha, marla or kanal differs from '
                'state to state, and sometimes between districts of one state. '
                'So they are not preset in this app - ask your patwari or '
                'lekhpal and enter it in square feet. A wrong guess is the most '
                'expensive mistake there is in a land deal.'),
        ToolQuestion(hi ? 'कितनी ज़मीन' : 'How much land'),
        ToolNumber(
          controller: _amount,
          label: hi ? 'मात्रा' : 'Amount',
          decimal: true,
          maxDigits: 9,
          icon: Icons.landscape_outlined,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < _units.length; i++)
              ChoiceChip(
                label: Text(hi ? _units[i].hi : _units[i].en),
                selected: !_fromLocal && _from == i,
                onSelected: (_) => setState(() {
                  _from = i;
                  _fromLocal = false;
                }),
              ),
            ChoiceChip(
              label: Text(localName),
              selected: _fromLocal,
              onSelected: (_) => setState(() => _fromLocal = true),
            ),
          ],
        ),
        ToolQuestion(hi ? 'आपकी स्थानीय इकाई (पटवारी से पूछकर)' : 'Your local unit (ask the patwari)'),
        Row(
          children: [
            Expanded(
              child: ToolText(
                controller: _localName,
                label: hi ? 'नाम (जैसे बीघा)' : 'Name (e.g. bigha)',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _localSqft,
                label: hi ? 'एक में कितने वर्ग फ़ुट' : 'Square feet in one',
                decimal: true,
                maxDigits: 7,
                icon: Icons.square_foot,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        if (sqm > 0) ...[
          const SizedBox(height: 12),
          for (final u in _units)
            ToolLine(hi ? u.hi : u.en, _fmt(sqm / u.sqm),
                strong: u.en == 'Acre' || u.en == 'Hectare'),
          if (localSqm > 0)
            ToolLine(localName, _fmt(sqm / localSqm), strong: true),
        ],
      ],
    );
  }
}

// --- Encroachment -----------------------------------------------------

class EncroachmentPage extends StatefulWidget {
  const EncroachmentPage({super.key});

  @override
  State<EncroachmentPage> createState() => _EncroachmentPageState();
}

class _EncroachmentPageState extends State<EncroachmentPage> {
  final _village = TextEditingController();
  final _khasra = TextEditingController();
  final _who = TextEditingController();
  final _what = TextEditingController();

  @override
  void dispose() {
    for (final c in [_village, _khasra, _who, _what]) {
      c.dispose();
    }
    super.dispose();
  }

  String _or(TextEditingController c) =>
      c.text.trim().isEmpty ? '______' : c.text.trim();

  String _letter(bool hi) {
    if (hi) {
      return 'सेवा में,\n'
          'तहसीलदार महोदय/महोदया\n\n'
          'विषय: भूमि की पैमाइश (सीमांकन) और अतिक्रमण हटाने हेतु आवेदन\n\n'
          'महोदय/महोदया,\n\n'
          'ग्राम ${_or(_village)} में खसरा/सर्वे संख्या ${_or(_khasra)} की भूमि '
          'मेरे नाम दर्ज है (रिकॉर्ड की नक़ल संलग्न)। ${_or(_who)} ने इस भूमि के '
          'हिस्से पर अतिक्रमण किया है: ${_or(_what)}।\n\n'
          'निवेदन है कि राजस्व टीम से भूमि की पैमाइश कराकर सीमा तय की जाए, और '
          'अतिक्रमण पाए जाने पर नियमानुसार हटाया जाए।\n\n'
          'इस आवेदन की प्राप्ति रसीद देने की कृपा करें।\n\n'
          'दिनांक: ____________\n'
          'नाम: ____________\n'
          'फ़ोन: ____________';
    }
    return 'To,\n'
        'The Tehsildar\n\n'
        'Subject: Application for demarcation of land and removal of '
        'encroachment\n\n'
        'Sir / Madam,\n\n'
        'The land at khasra / survey number ${_or(_khasra)} in village '
        '${_or(_village)} is recorded in my name (copy of the record '
        'attached). ${_or(_who)} has encroached on part of it: '
        '${_or(_what)}.\n\n'
        'I request that the revenue team measure the land and fix its '
        'boundary, and that any encroachment found be removed as per the '
        'rules.\n\n'
        'Kindly give me a receipt for this application.\n\n'
        'Date: ____________\n'
        'Name: ____________\n'
        'Phone: ____________';
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 15,
      title: hi ? 'मेरी ज़मीन पर क़ब्ज़ा' : 'Encroachment on my land',
      children: [
        ToolAnswer(
          headline: hi ? 'पहला क़दम: पैमाइश' : 'The first step: demarcation',
          detail: hi
              ? 'झगड़े में सबसे पहले यह तय होना चाहिए कि सीमा असल में कहाँ है। उसके '
                  'लिए तहसील में पैमाइश (सीमांकन) का आवेदन दें — राजस्व टीम रिकॉर्ड और '
                  'नक़्शे से नापकर पत्थर या निशान लगाती है। इसकी एक तय फ़ीस होती है। '
                  'पैमाइश की रिपोर्ट ही आगे हर जगह — पुलिस, तहसील, अदालत — सबसे काम '
                  'का काग़ज़ है।'
              : 'In a dispute, the first thing to settle is where the boundary '
                  'actually is. Apply at the tehsil for demarcation - the '
                  'revenue team measures from the record and the map and puts '
                  'in stones or marks. There is a set fee. The demarcation '
                  'report is the most useful paper everywhere after that - '
                  'police, tehsil, court.',
          tone: ToolTone.plain,
          icon: Icons.straighten,
        ),
        ToolQuestion(hi ? 'आवेदन के लिए ब्योरा' : 'Details for the application'),
        Row(
          children: [
            Expanded(
              child: ToolText(
                controller: _village,
                label: hi ? 'गाँव' : 'Village',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolText(
                controller: _khasra,
                label: hi ? 'खसरा/सर्वे संख्या' : 'Khasra / survey no.',
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ToolText(
          controller: _who,
          label: hi ? 'किसने (नाम, अगर पता हो)' : 'By whom (name, if known)',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolText(
          controller: _what,
          label: hi ? 'क्या किया (दीवार, खेती, रास्ता…)' : 'What they did (wall, farming, path…)',
          maxLength: 150,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        CopyBlock(
          text: _letter(hi),
          note: hi
              ? 'साथ लगाएँ: ज़मीन के रिकॉर्ड की ताज़ा नक़ल, नक़्शा अगर हो, और क़ब्ज़े की '
                  'तारीख़वार फ़ोटो।'
              : 'Attach: a current copy of the land record, the map if you have '
                  'it, and dated photos of the encroachment.',
        ),
        const SizedBox(height: 12),
        Text(hi ? 'साथ-साथ' : 'Alongside',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'ज़बरदस्ती क़ब्ज़ा, धमकी या मारपीट हो तो थाने में लिखित शिकायत दें — '
                      'यह आपराधिक अतिचार है',
                  'निर्माण चल रहा हो तो दीवानी अदालत से रोक (स्टे) माँगी जा सकती है — '
                      'जल्दी करें, बन जाने के बाद मामला लंबा चलता है',
                  'मुफ़्त वकील के लिए ज़िला विधिक सेवा प्राधिकरण',
                  'सरकारी या गाँव की साझी ज़मीन पर क़ब्ज़ा हो तो ग्राम पंचायत और तहसील — '
                      'दोनों को लिखित सूचना',
                ]
              : const [
                  'If there is forcible occupation, threats or violence, give a '
                      'written complaint at the police station - this is '
                      'criminal trespass',
                  'If building is going on, a civil court can be asked for a '
                      'stay - move fast; once it is built the case runs long',
                  'For a free lawyer, the District Legal Services Authority',
                  'If it is government or village common land that is being '
                      'taken, written notice to both the gram panchayat and the '
                      'tehsil',
                ],
        ),
        ToolDonts(
          heading: hi ? 'जो न करें' : 'Do not',
          items: hi
              ? const [
                  'ख़ुद दीवार गिराने या ज़बरदस्ती हटाने की कोशिश न करें — मामला आप पर '
                      'उल्टा पड़ सकता है',
                  'कोरे काग़ज़ पर "समझौते" के नाम से दस्तख़त न करें',
                  'असली काग़ज़ किसी को न सौंपें; नक़ल दें',
                ]
              : const [
                  'Do not try to knock the wall down or remove it by force '
                      'yourself - the case can turn against you',
                  'Do not sign a blank paper as a "settlement"',
                  'Hand over no originals; give copies',
                ],
        ),
        const SourceNote(
            text: 'National Legal Services Authority', url: _nalsaUrl),
      ],
    );
  }
}
