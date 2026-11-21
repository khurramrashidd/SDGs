import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Three screens about toilets and what happens underneath them.
///
/// The middle one carries the most important warning in this goal. People
/// die every year climbing into septic tanks and pits to empty them, from
/// the gas rather than from drowning, and they die within a minute - often
/// along with whoever climbed in after them to help. It is also illegal to
/// employ anyone to do it. So that screen opens with the don't, not with
/// the how.

const _sbmUrl = 'https://swachhbharatmission.ddws.gov.in/';
const _sbmGrantRupees = 12000;

// --- Toilet grant -----------------------------------------------------

/// Whether the household falls in a category the incentive covers. The
/// categories are the state's to apply, so this screen gives the common
/// ones and says the list is the state's.
enum ToiletCategory {
  bpl,
  scSt,
  smallFarmer,
  landless,
  disabled,
  womanHeaded,
  none,
}

class ToiletGrantPage extends StatefulWidget {
  const ToiletGrantPage({super.key});

  @override
  State<ToiletGrantPage> createState() => _ToiletGrantPageState();
}

class _ToiletGrantPageState extends State<ToiletGrantPage> {
  final Set<ToiletCategory> _cats = {};
  bool _hasToilet = false;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final qualifies =
        _cats.isNotEmpty && !_cats.contains(ToiletCategory.none) && !_hasToilet;

    Widget cat(ToiletCategory c, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _cats.contains(c),
          onTap: () => setState(() {
            if (c == ToiletCategory.none) {
              _cats
                ..clear()
                ..add(c);
              return;
            }
            _cats.remove(ToiletCategory.none);
            if (!_cats.remove(c)) _cats.add(c);
          }),
        );

    return ToolScaffold(
      goal: 6,
      title: hi ? 'शौचालय की सहायता राशि' : 'The toilet grant',
      children: [
        ToolNote(hi
            ? 'स्वच्छ भारत मिशन (ग्रामीण) में पात्र परिवार को घर में शौचालय बनाने के '
                'लिए ₹$_sbmGrantRupees की प्रोत्साहन राशि मिलती है। यह पैसा बनने के '
                'बाद, सत्यापन पर, सीधे बैंक खाते में आता है — किसी ठेकेदार या बिचौलिये '
                'के हाथ में नहीं।'
            : 'Under Swachh Bharat Mission (Gramin) an eligible household '
                'gets an incentive of ₹$_sbmGrantRupees to build a toilet at '
                'home. The money comes after construction, on verification, '
                'straight into a bank account - not through a contractor or '
                'a middleman.'),
        SwitchListTile(
          value: _hasToilet,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'घर में पहले से काम करता शौचालय है'
              : 'The house already has a working toilet'),
          onChanged: (v) => setState(() => _hasToilet = v),
        ),
        ToolQuestion(hi
            ? 'इनमें से क्या लागू होता है'
            : 'Which of these apply to the household'),
        cat(ToiletCategory.bpl, 'Below the poverty line',
            'ग़रीबी रेखा से नीचे'),
        cat(ToiletCategory.scSt, 'Scheduled Caste or Scheduled Tribe',
            'अनुसूचित जाति या जनजाति'),
        cat(ToiletCategory.smallFarmer, 'Small or marginal farmer',
            'छोटा या सीमांत किसान'),
        cat(ToiletCategory.landless, 'Landless, with a homestead',
            'भूमिहीन, लेकिन घर की ज़मीन है'),
        cat(ToiletCategory.disabled, 'Someone in the house has a disability',
            'घर में कोई दिव्यांग है'),
        cat(ToiletCategory.womanHeaded, 'A woman heads the household',
            'घर की मुखिया महिला है'),
        cat(ToiletCategory.none, 'None of these', 'इनमें से कोई नहीं'),
        if (_cats.isNotEmpty) ...[
          if (_hasToilet)
            ToolAnswer(
              headline: hi
                  ? 'पहले से शौचालय है तो यह राशि नहीं बनती'
                  : 'With a working toilet already, this does not apply',
              detail: hi
                  ? 'यह राशि नया शौचालय बनवाने के लिए है। लेकिन अगर घर में शौचालय है '
                      'और उसका गड्ढा भर गया है या वह टूट गया है, तो वह अलग मामला है — '
                      'इसी लक्ष्य में "शौचालय का गड्ढा भर गया" देखें। और अगर घर में एक '
                      'से ज़्यादा परिवार अलग-अलग रहते हैं, तो हर परिवार की अलग गिनती '
                      'होती है; पंचायत से पूछें।'
                  : 'This incentive is for building a new toilet. But if the '
                      'house has one and its pit is full or it has broken '
                      'down, that is a different matter - see "The toilet pit '
                      'is full" in this goal. And where more than one family '
                      'lives separately in the same house, each counts '
                      'separately; ask the panchayat.',
              tone: ToolTone.plain,
              icon: Icons.info_outline,
            )
          else if (qualifies)
            ToolAnswer(
              headline: hi
                  ? '₹$_sbmGrantRupees की राशि बनती है'
                  : 'The ₹$_sbmGrantRupees incentive should apply',
              detail: hi
                  ? 'अंतिम सूची राज्य बनाता है, इसलिए पक्का ग्राम पंचायत से ही होता '
                      'है — लेकिन इनमें से कोई श्रेणी लागू हो और घर में शौचालय न हो तो '
                      'अर्ज़ी ज़रूर दें। कई राज्य अपनी ओर से इससे ज़्यादा भी देते हैं, '
                      'इसलिए वहाँ पूछना फ़ायदेमंद है।'
                  : 'The final list is the state\'s, so the panchayat is where '
                      'it gets confirmed - but if one of these categories '
                      'applies and there is no toilet, put in the '
                      'application. Several states add their own money on '
                      'top, so it is worth asking there.',
              tone: ToolTone.good,
              icon: Icons.verified_outlined,
            )
          else
            ToolAnswer(
              headline: hi
                  ? 'फिर भी पंचायत में पूछ लें'
                  : 'Ask at the panchayat anyway',
              detail: hi
                  ? 'श्रेणियाँ राज्य तय करता है और समय-समय पर बदलती हैं। मिशन के '
                      'दूसरे चरण में नए बने परिवारों को भी शामिल किया जाता है — जैसे '
                      'शादी के बाद अलग हुआ परिवार। इसलिए सूची में नाम न दिखे तो भी '
                      'एक बार पूछ लेना ठीक है।'
                  : 'The categories are the state\'s and they change from '
                      'time to time. The mission\'s second phase also covers '
                      'newly formed households - a family that separated '
                      'after a marriage, for instance. So it is worth asking '
                      'even if your name is not on the list.',
              tone: ToolTone.plain,
              icon: Icons.help_outline,
            ),
          const SizedBox(height: 14),
          Text(hi ? 'अर्ज़ी और भुगतान' : 'Applying, and the payment',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'ग्राम पंचायत में अर्ज़ी दें — आधार, बैंक पासबुक और राशन कार्ड के '
                        'साथ। कई राज्यों में यह ऑनलाइन भी होता है।',
                    'पंचायत सूची में नाम जुड़वाएँ और पावती लें। नाम सूची में दर्ज होना '
                        'ही असल क़दम है।',
                    'शौचालय बनवाएँ — जुड़वाँ गड्ढे वाला (ट्विन पिट) सबसे अच्छा रहता है, '
                        'और सरकार उसी की सलाह देती है।',
                    'बनने के बाद सत्यापन होता है और जियो-टैग फ़ोटो ली जाती है।',
                    'सत्यापन के बाद पैसा सीधे बैंक खाते में आता है।',
                  ]
                : const [
                    'Apply at the gram panchayat with Aadhaar, the bank '
                        'passbook and the ration card. In many states this '
                        'can be done online too.',
                    'Get your name added to the panchayat\'s list and take '
                        'the acknowledgement. Being on the list is the step '
                        'that matters.',
                    'Build the toilet - a twin-pit design is the best one, '
                        'and the one the government recommends.',
                    'After it is built there is a verification and a '
                        'geo-tagged photograph.',
                    'After verification the money goes straight into the '
                        'bank account.',
                  ],
          ),
          ToolDonts(
            heading: hi ? 'यहाँ सावधान रहें' : 'Where to be careful',
            items: hi
                ? const [
                    'सूची में नाम जुड़वाने के पैसे कोई नहीं ले सकता — यह मुफ़्त है',
                    'पैसा आपके खाते में आना है। जो कहे कि "पैसा मेरे पास आएगा, मैं '
                        'बनवा दूँगा" — उससे लिखित में लें और पंचायत में पूछें',
                    'राशि बनने के बाद मिलती है, इसलिए पहले से पैसा देने का वादा करने '
                        'वाले ठेकेदार से सावधान रहें',
                    'बनने के बाद सत्यापन न हो तो पैसा अटक जाता है — पंचायत से सत्यापन '
                        'कराने के लिए ख़ुद पीछे लगें',
                  ]
                : const [
                    'Nobody may charge for getting your name on the list - '
                        'it is free',
                    'The money comes to your account. Anyone who says "the '
                        'money will come to me and I will build it" should '
                        'put that in writing, and you should ask the '
                        'panchayat',
                    'The incentive comes after construction, so be wary of a '
                        'contractor promising money up front',
                    'If the verification does not happen the money sticks - '
                        'chase the panchayat for it yourself',
                  ],
          ),
          const SourceNote(
              text: 'Swachh Bharat Mission (Gramin)', url: _sbmUrl),
        ],
      ],
    );
  }
}

// --- Pit is full ------------------------------------------------------

enum PitKind { twinPit, singlePit, septicTank, unknown }

class ToiletPitPage extends StatefulWidget {
  const ToiletPitPage({super.key});

  @override
  State<ToiletPitPage> createState() => _ToiletPitPageState();
}

class _ToiletPitPageState extends State<ToiletPitPage> {
  PitKind? _kind;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;

    Widget pick(PitKind k, String en, String h, String sub, String subHi) =>
        SelectionTile(
          label: hi ? h : en,
          subtitle: hi ? subHi : sub,
          selected: _kind == k,
          onTap: () => setState(() => _kind = k),
        );

    return ToolScaffold(
      goal: 6,
      title: hi ? 'शौचालय का गड्ढा भर गया' : 'The toilet pit is full',
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: scheme.error,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.dangerous_outlined, color: scheme.onError, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hi
                      ? 'किसी भी हालत में गड्ढे या सेप्टिक टैंक में कोई न उतरे। अंदर '
                          'बनी गैस मिनट भर में बेहोश कर देती है, और हर साल सबसे ज़्यादा '
                          'मौतें उनकी होती हैं जो बचाने के लिए पीछे उतरे। किसी से '
                          'उतरवाना क़ानूनन अपराध भी है।'
                      : 'Nobody should climb into a pit or a septic tank, '
                          'ever. The gas inside knocks a person out within a '
                          'minute, and most of the deaths each year are of '
                          'the people who went in after to help. Employing '
                          'anyone to do it is also a crime.',
                  style: TextStyle(
                      fontSize: 14.5,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                      color: scheme.onError),
                ),
              ),
            ],
          ),
        ),
        ToolQuestion(hi ? 'नीचे क्या बना है' : 'What is underneath'),
        pick(PitKind.twinPit, 'Two pits', 'दो गड्ढे',
            'A twin-pit toilet, with a junction box',
            'जुड़वाँ गड्ढे वाला शौचालय, बीच में जंक्शन बॉक्स'),
        pick(PitKind.singlePit, 'One pit', 'एक गड्ढा', '', ''),
        pick(PitKind.septicTank, 'A septic tank', 'सेप्टिक टैंक',
            'A closed cement tank', 'बंद सीमेंट का टैंक'),
        pick(PitKind.unknown, 'I do not know', 'पता नहीं', '', ''),
        if (_kind != null) ...[
          if (_kind == PitKind.twinPit)
            ToolAnswer(
              headline: hi
                  ? 'यह सबसे आसान हालत है — बस रास्ता बदलना है'
                  : 'This is the easy case - you just switch the flow',
              detail: hi
                  ? 'जुड़वाँ गड्ढे वाला शौचालय इसी के लिए बना है। बीच के जंक्शन बॉक्स '
                      'में ईंट या ढक्कन से पहला गड्ढा बंद करके दूसरा खोल दें। भरा हुआ '
                      'गड्ढा छह महीने से एक साल तक ऐसे ही बंद पड़ा रहने दें। उतने समय '
                      'में उसके अंदर का सब कुछ सूखकर गंधहीन खाद बन जाता है, जिसे खेत '
                      'में डाला जा सकता है और जिसे फावड़े से निकाला जा सकता है। किसी को '
                      'बुलाने की ज़रूरत नहीं, पैसा नहीं लगता।'
                  : 'A twin-pit toilet is built for exactly this. In the '
                      'junction box between them, close the first pit with a '
                      'brick or its cover and open the second. Leave the full '
                      'pit closed for six months to a year. In that time '
                      'everything inside dries into odourless compost that '
                      'can go on a field and can be lifted out with a spade. '
                      'Nobody needs to be called, and it costs nothing.',
              tone: ToolTone.good,
              icon: Icons.swap_horiz,
            )
          else if (_kind == PitKind.septicTank)
            ToolAnswer(
              headline: hi
                  ? 'मशीन से ख़ाली कराना है, आदमी से नहीं'
                  : 'This is emptied by machine, never by a person',
              detail: hi
                  ? 'सेप्टिक टैंक ख़ाली कराने के लिए नगर निकाय या ग्राम पंचायत से '
                      'सक्शन मशीन वाली गाड़ी बुलाई जाती है। कई शहरों और ब्लॉकों में यह '
                      'सेवा तय शुल्क पर मिलती है और नंबर निकाय के पास होता है। निजी '
                      'गाड़ी बुलाएँ तो यह ज़रूर देखें कि वे मल को किसी नाले या खेत में न '
                      'डालें — उसे शोधन संयंत्र तक जाना होता है।'
                  : 'A septic tank is emptied by a suction truck called from '
                      'the local body or the gram panchayat. In many towns '
                      'and blocks this is a paid service and the number sits '
                      'with the local body. If you call a private truck, make '
                      'sure they do not dump the sludge in a drain or a '
                      'field - it has to go to a treatment plant.',
              tone: ToolTone.warn,
              icon: Icons.local_shipping_outlined,
            )
          else
            ToolAnswer(
              headline: hi
                  ? 'मशीन से ख़ाली कराएँ, और दूसरा गड्ढा बनवाने की सोचें'
                  : 'Get it emptied by machine, and consider a second pit',
              detail: hi
                  ? 'एक गड्ढे वाले शौचालय में हर बार ख़ाली कराना पड़ता है और हर बार '
                      'ख़र्च होता है। दूसरा गड्ढा और जंक्शन बॉक्स बनवा लेना सस्ता पड़ता '
                      'है और उसके बाद कभी किसी को बुलाना नहीं पड़ता — हर कुछ साल में '
                      'रास्ता बदल दीजिए। पंचायत से पूछें; कई राज्य इस बदलाव में मदद '
                      'करते हैं। अभी के लिए निकाय की सक्शन गाड़ी बुलाएँ।'
                  : 'A single-pit toilet has to be emptied each time, and '
                      'each time costs money. Adding a second pit and a '
                      'junction box is cheaper over time, and after that '
                      'nobody ever has to be called - you just switch the '
                      'flow every few years. Ask the panchayat; several '
                      'states help with that conversion. For now, call the '
                      'local body\'s suction truck.',
              tone: ToolTone.plain,
              icon: Icons.construction_outlined,
            ),
          const SizedBox(height: 14),
          ToolDonts(
            heading: hi ? 'कभी नहीं' : 'Never',
            items: hi
                ? const [
                    'गड्ढे या टैंक में कोई न उतरे — न परिवार का कोई, न मज़दूर, न "अनुभवी" '
                        'आदमी। गैस दिखती नहीं और एक मिनट में बेहोश कर देती है।',
                    'किसी को हाथ से मैला साफ़ करने के लिए न लगाएँ — यह क़ानूनन अपराध है '
                        'और इसमें सज़ा होती है',
                    'कोई अंदर गिर जाए तो पीछे न उतरें। बाहर से रस्सी डालें, ढक्कन '
                        'खोलकर हवा आने दें, और 112 बुलाएँ। बचाने उतरने वाले ही सबसे '
                        'ज़्यादा मरते हैं।',
                    'ढक्कन खोलकर तुरंत झुककर न देखें; कुछ देर हवा लगने दें',
                    'टैंक या गड्ढे के पास माचिस, बीड़ी या लालटेन न ले जाएँ',
                  ]
                : const [
                    'Nobody goes into a pit or tank - not a family member, '
                        'not a labourer, not an "experienced" man. The gas is '
                        'invisible and it knocks you out in a minute.',
                    'Do not employ anyone to clean faecal matter by hand - '
                        'it is a criminal offence and it is punished',
                    'If someone falls in, do not go in after them. Put a '
                        'rope down from outside, open the cover to let air '
                        'in, and call 112. The rescuers are the ones who die '
                        'most often.',
                    'Do not open the cover and immediately lean over it; let '
                        'it air for a while',
                    'No matches, bidis or lanterns near a tank or pit',
                  ],
          ),
          const SourceNote(
              text: 'Swachh Bharat Mission (Gramin)', url: _sbmUrl),
        ],
      ],
    );
  }
}

// --- Open drain or sewage near water ----------------------------------

class DrainSewagePage extends StatelessWidget {
  const DrainSewagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 6,
      title: hi
          ? 'पानी के पास खुली नाली या गंदगी'
          : 'An open drain or sewage near the water',
      children: [
        ToolNote(hi
            ? 'हैंडपंप, कुएँ या नल के पास जमा गंदा पानी सिर्फ़ बदबू की बात नहीं है। '
                'वह रिसकर नीचे पहुँचता है और उसी स्रोत का पानी दूषित कर देता है जिससे '
                'मोहल्ला पीता है — और यह पानी देखने में बिल्कुल साफ़ रहता है। गाँवों में '
                'बार-बार होने वाले दस्त की सबसे आम वजह यही है।'
            : 'Dirty water standing near a handpump, well or tap is not just '
                'a smell. It seeps down and contaminates the very source the '
                'neighbourhood drinks from - and that water goes on looking '
                'perfectly clear. It is the commonest cause of the loose '
                'motions that keep coming back in a village.'),
        const SizedBox(height: 10),
        Text(hi ? 'कितनी दूरी चाहिए' : 'How far apart they should be',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        ToolLine(
            hi
                ? 'पीने के स्रोत और शौचालय के गड्ढे के बीच'
                : 'Between a drinking source and a toilet pit',
            hi ? 'कम से कम 10 मीटर' : 'At least 10 metres',
            strong: true),
        ToolLine(
            hi
                ? 'स्रोत और खुली नाली या कूड़े के ढेर के बीच'
                : 'Between the source and an open drain or rubbish heap',
            hi ? 'जितना हो सके, और ढलान नीचे की ओर' : 'As far as possible, and downhill'),
        ToolLine(hi ? 'हैंडपंप का चबूतरा' : 'The handpump platform',
            hi ? 'सही ढलान और सोख़्ता गड्ढा' : 'Sloped, with a soak pit'),
        const SizedBox(height: 8),
        ToolNote(hi
            ? 'दूरी से ज़्यादा मायने ढलान रखता है: अगर नाली स्रोत से ऊँचाई पर है, तो '
                'दस मीटर भी कम पड़ सकता है। मिट्टी पथरीली या रेतीली हो तो पानी और '
                'तेज़ी से नीचे जाता है।'
            : 'Slope matters more than distance: if the drain is uphill of '
                'the source, ten metres may not be enough. In rocky or sandy '
                'soil the water travels down faster still.'),
        const SizedBox(height: 14),
        Text(hi ? 'किसका काम है' : 'Whose job it is',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'गाँव में नालियाँ और सोख़्ता गड्ढे बनवाना ग्राम पंचायत का काम है, और '
                      'इसके लिए स्वच्छ भारत मिशन और वित्त आयोग, दोनों से पैसा आता है।',
                  'ग्राम सभा की बैठक में यह मुद्दा उठवाएँ और कार्यवाही में दर्ज कराएँ। '
                      'गाँव की सालाना योजना इसी बैठक में बनती है — नाली उसमें शामिल '
                      'कराना सबसे असरदार रास्ता है।',
                  'लिखित अर्ज़ी पंचायत सचिव को दें, मोहल्ले के कई लोगों के हस्ताक्षर '
                      'के साथ, और पावती लें।',
                  'न हो तो खंड विकास अधिकारी (BDO) और ज़िला पंचायत राज अधिकारी को '
                      'लिखें।',
                  'शहर में यह नगर निकाय का काम है — वार्ड पार्षद और स्वास्थ्य अधिकारी '
                      'के पास शिकायत जाती है।',
                ]
              : const [
                  'Building drains and soak pits in a village is the gram '
                      'panchayat\'s job, and the money for it comes from both '
                      'Swachh Bharat Mission and the Finance Commission '
                      'grants.',
                  'Raise it in the gram sabha meeting and get it recorded in '
                      'the proceedings. The village\'s annual plan is made in '
                      'that meeting - getting the drain into it is the most '
                      'effective route there is.',
                  'Give a written application to the panchayat secretary with '
                      'several neighbours\' signatures, and take the '
                      'acknowledgement.',
                  'If nothing happens, write to the Block Development Officer '
                      'and the district panchayati raj officer.',
                  'In a town this is the local body\'s job - the complaint '
                      'goes to the ward councillor and the health officer.',
                ],
        ),
        ToolAnswer(
          headline: hi
              ? 'इस बीच, जो घर पर किया जा सकता है'
              : 'Meanwhile, what can be done at home',
          detail: hi
              ? 'स्रोत के चारों ओर का चबूतरा ठीक कराएँ और उससे निकलने वाला पानी एक '
                  'सोख़्ता गड्ढे तक ले जाएँ — यह थोड़ी मेहनत और बहुत कम ख़र्च का काम है, '
                  'और मोहल्ला मिलकर एक दिन में कर सकता है। सोख़्ता गड्ढा बस एक गड्ढा है '
                  'जिसमें ईंट के टुकड़े और बजरी भरी हो; उसमें पानी ज़मीन में सीधे चला '
                  'जाता है और ऊपर जमा नहीं होता।'
              : 'Repair the platform around the source and lead the waste '
                  'water from it into a soak pit - a little work, very little '
                  'money, and a neighbourhood can do it in a day. A soak pit '
                  'is just a hole filled with brick rubble and gravel; the '
                  'water goes straight into the ground instead of standing on '
                  'top.',
          tone: ToolTone.good,
          icon: Icons.handyman_outlined,
        ),
        ToolNote(hi
            ? 'जब तक यह ठीक न हो, उस स्रोत का पानी पीने से पहले उबालें या क्लोरीन '
                'डालें, और एक बार जाँच ज़रूर करा लें — इसी लक्ष्य में दोनों स्क्रीनें '
                'हैं।'
            : 'Until it is fixed, boil or chlorinate water from that source '
                'before drinking, and get it tested once - both screens are '
                'in this goal.'),
        const SourceNote(text: 'Swachh Bharat Mission (Gramin)', url: _sbmUrl),
      ],
    );
  }
}
