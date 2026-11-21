import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Four screens for the minutes before a hospital.
///
/// None of these diagnoses anything, and none of them is a reason to stay
/// at home. What they are for is the gap: the twenty minutes between
/// something happening and reaching a facility, where what a family does
/// changes the outcome and almost all of the folk advice makes it worse. A
/// tourniquet costs a limb. Chilli in a dog bite helps the virus reach the
/// nerves. A fever in a newborn that "will pass by morning" sometimes does
/// not.
///
/// Every line here is from a government guideline, named on the screen:
/// the IMNCI chart booklet for a child's danger signs, the NCDC rabies
/// protocol for animal bites, the national Standard Treatment Guideline for
/// snakebite, and the ANC guidelines for pregnancy. All of it is still
/// marked for a doctor's review before public launch.

const _imnciUrl =
    'https://nhm.gov.in/images/pdf/programmes/child-health/guidelines/imnci_chart_booklet.pdf';
const _rabiesUrl =
    'https://clinicalestablishments.mohfw.gov.in/sites/default/files/standard-treatment-guidelines/238.pdf';
const _snakeUrl =
    'https://nhm.gov.in/images/pdf/guidelines/nrhm-guidelines/stg/Snakebite_Full.pdf';
const _ancUrl = 'https://nhm.gov.in/';

/// The ambulance line, shown at the top of every emergency screen.
class _CallNow extends StatelessWidget {
  final String text;
  const _CallNow(this.text);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: scheme.error,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.emergency_outlined, color: scheme.onError, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 14.5,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: scheme.onError)),
          ),
        ],
      ),
    );
  }
}

// --- Fever ------------------------------------------------------------

/// Age decides almost everything about a fever, and the youngest band is
/// the one families misjudge: in a baby under two months any fever at all
/// is a reason to go, and so is being unusually cold.
enum FeverAge { underTwoMonths, underFive, olderChild, adult }

/// The general danger signs from the IMNCI chart booklet. Any one of them,
/// with or without fever, means urgent referral.
enum ChildDanger { cannotDrink, vomitsEverything, convulsions, lethargic }

/// True if any danger sign is ticked, which is the whole decision.
bool childNeedsUrgentCare(Set<ChildDanger> signs) => signs.isNotEmpty;

class FeverPage extends StatefulWidget {
  const FeverPage({super.key});

  @override
  State<FeverPage> createState() => _FeverPageState();
}

class _FeverPageState extends State<FeverPage> {
  FeverAge? _age;
  final Set<ChildDanger> _signs = {};
  bool _overSevenDays = false;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final urgent = childNeedsUrgentCare(_signs) ||
        _age == FeverAge.underTwoMonths;

    Widget pickAge(FeverAge a, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _age == a,
          onTap: () => setState(() => _age = a),
        );

    Widget sign(ChildDanger d, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _signs.contains(d),
          onTap: () => setState(() {
            if (!_signs.remove(d)) _signs.add(d);
          }),
        );

    return ToolScaffold(
      goal: 3,
      title: hi ? 'बुख़ार: कब आपात स्थिति है' : 'Fever: when it is an emergency',
      children: [
        _CallNow(hi
            ? 'एम्बुलेंस 108 या 102। यह स्क्रीन बीमारी नहीं बताती — यह सिर्फ़ इतना '
                'बताती है कि अस्पताल अभी जाना है या सुबह।'
            : 'Ambulance 108 or 102. This screen does not tell you what the '
                'illness is. It tells you one thing: hospital now, or in the '
                'morning.'),
        ToolQuestion(hi ? 'किसको बुख़ार है' : 'Who has the fever'),
        pickAge(FeverAge.underTwoMonths, 'A baby under 2 months',
            '2 महीने से छोटा बच्चा'),
        pickAge(FeverAge.underFive, 'A child under 5',
            '5 साल से छोटा बच्चा'),
        pickAge(FeverAge.olderChild, 'A child 5 or older',
            '5 साल या बड़ा बच्चा'),
        pickAge(FeverAge.adult, 'An adult', 'बड़ा व्यक्ति'),
        if (_age == FeverAge.underTwoMonths)
          ToolAnswer(
            headline: hi ? 'अभी ले जाएँ — इंतज़ार नहीं' : 'Go now - do not wait',
            detail: hi
                ? 'दो महीने से छोटे बच्चे में कोई भी बुख़ार अस्पताल जाने की वजह है, और '
                    'शरीर ठंडा पड़ जाना भी उतनी ही बड़ी वजह है। इस उम्र में संक्रमण तेज़ी '
                    'से फैलता है और बाहर से बहुत कम दिखता है। "सुबह देखेंगे" यहाँ सुरक्षित '
                    'नहीं है।'
                : 'In a baby under two months any fever at all is a reason to '
                    'go, and so is the body turning unusually cold. At this '
                    'age an infection moves fast and shows very little from '
                    'outside. "We will see in the morning" is not safe here.',
            tone: ToolTone.bad,
            icon: Icons.priority_high,
          ),
        if (_age == FeverAge.underTwoMonths) ...[
          const SizedBox(height: 12),
          Text(hi ? 'इन्हें भी देखें' : 'Also look for these',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            numbered: false,
            steps: hi
                ? const [
                    'साँस बहुत तेज़ — मिनट में 60 बार या उससे ज़्यादा',
                    'साँस लेते समय छाती अंदर धँसना',
                    'नाक के नथुने फूलना, या साँस में घर्र-घर्र आवाज़',
                    'सिर के तालू का उभरना',
                    'शरीर पर दस या ज़्यादा फोड़े-फुंसियाँ, या एक बड़ा फोड़ा',
                    'दौरा पड़ना',
                    'सुस्त पड़ा रहना, या हिलना-डुलना कम हो जाना',
                  ]
                : const [
                    'Breathing very fast - 60 breaths a minute or more',
                    'The chest pulling inwards with each breath',
                    'Nostrils flaring, or a grunting sound while breathing',
                    'The soft spot on the head bulging',
                    'Ten or more skin pustules, or one big boil',
                    'A convulsion',
                    'Lying limp, or moving less than usual',
                  ],
          ),
          const SourceNote(
            text: 'IMNCI chart booklet, National Health Mission',
            url: _imnciUrl,
          ),
        ],
        if (_age == FeverAge.underFive) ...[
          ToolQuestion(hi
              ? 'इनमें से कुछ हो रहा है?'
              : 'Is any of this happening?'),
          ToolNote(hi
              ? 'ये चार "ख़तरे के संकेत" हैं। इनमें से एक भी हो तो बुख़ार कितना है, इससे '
                  'फ़र्क़ नहीं पड़ता — तुरंत ले जाना है।'
              : 'These four are the danger signs. If even one is there, how '
                  'high the fever is does not matter - go at once.'),
          sign(ChildDanger.cannotDrink, 'Cannot drink or breastfeed',
              'पानी या दूध नहीं पी पा रहा'),
          sign(ChildDanger.vomitsEverything, 'Vomits everything',
              'जो दें वह सब उलट देता है'),
          sign(ChildDanger.convulsions, 'Has had a convulsion',
              'दौरा पड़ा है'),
          sign(ChildDanger.lethargic, 'Lethargic, or not waking properly',
              'सुस्त है, या ठीक से जाग नहीं रहा'),
          if (urgent)
            ToolAnswer(
              headline: hi ? 'अभी ले जाएँ' : 'Go now',
              detail: hi
                  ? 'यह ख़तरे का संकेत है। रास्ते में बच्चे को दूध या पानी पिलाते रहें '
                      'अगर वह पी सकता है, और उसे गरम कपड़े में रखें। 108 बुलाएँ।'
                  : 'This is a danger sign. On the way keep giving the child '
                      'milk or water if it can drink, and keep it warm. Call '
                      '108.',
              tone: ToolTone.bad,
              icon: Icons.priority_high,
            )
          else if (_signs.isEmpty)
            ToolAnswer(
              headline: hi
                  ? 'इनके साथ भी तुरंत ले जाना है'
                  : 'These also mean going at once',
              detail: hi
                  ? 'गर्दन अकड़ जाना, सिर के तालू का उभरना, या बुख़ार के साथ शरीर पर '
                      'दाने। और अगर बुख़ार सात दिन से हर दिन आ रहा है, तो जाँच करानी '
                      'है — मलेरिया, टाइफ़ॉइड और डेंगू की जाँच सरकारी अस्पताल में मुफ़्त '
                      'होती है।'
                  : 'A stiff neck, a bulging soft spot on the head, or a rash '
                      'with the fever. And if the fever has come every day for '
                      'seven days, it needs testing - malaria, typhoid and '
                      'dengue tests are free at a government hospital.',
              tone: ToolTone.warn,
              icon: Icons.visibility_outlined,
            ),
          const SourceNote(
            text: 'IMNCI chart booklet, National Health Mission',
            url: _imnciUrl,
          ),
        ],
        if (_age == FeverAge.olderChild || _age == FeverAge.adult) ...[
          ToolAnswer(
            headline: hi
                ? 'इनमें से कुछ हो तो अभी अस्पताल'
                : 'Any of these means hospital now',
            detail: hi
                ? 'बुख़ार के साथ: दौरा, बेहोशी या भ्रम, गर्दन अकड़ना, साँस फूलना, '
                    'नाक-मसूढ़ों से ख़ून, काला पाख़ाना, पेट में तेज़ दर्द, बार-बार उलटी, '
                    'पेशाब बंद हो जाना, या हाथ-पैर ठंडे और चिपचिपे पड़ जाना।'
                : 'Fever with any of: a convulsion, unconsciousness or '
                    'confusion, a stiff neck, breathlessness, bleeding from '
                    'the nose or gums, black stools, severe abdominal pain, '
                    'repeated vomiting, passing no urine, or hands and feet '
                    'turning cold and clammy.',
            tone: ToolTone.bad,
            icon: Icons.priority_high,
          ),
          const SizedBox(height: 12),
          ToolQuestion(hi ? 'बुख़ार कितने दिन से' : 'How long has the fever been'),
          SwitchListTile(
            value: _overSevenDays,
            contentPadding: EdgeInsets.zero,
            title: Text(hi
                ? 'सात दिन से ज़्यादा, हर दिन'
                : 'More than seven days, every day'),
            onChanged: (v) => setState(() => _overSevenDays = v),
          ),
          if (_overSevenDays)
            ToolAnswer(
              headline: hi ? 'जाँच करानी है, दवा नहीं' : 'This needs a test, not a tablet',
              detail: hi
                  ? 'सात दिन से ऊपर का बुख़ार अपने आप ठीक मानकर छोड़ने वाला नहीं है। '
                      'सरकारी अस्पताल में मलेरिया, टाइफ़ॉइड, डेंगू और टीबी की जाँच मुफ़्त '
                      'होती है। मेडिकल दुकान से बुख़ार की गोली लेकर चलाते रहना ही वह '
                      'रास्ता है जिसमें देर हो जाती है।'
                  : 'A fever past seven days is not one to wait out. Malaria, '
                      'typhoid, dengue and TB tests are free at a government '
                      'hospital. Living on fever tablets from the medical shop '
                      'is exactly the path on which this gets caught late.',
              tone: ToolTone.warn,
              icon: Icons.biotech_outlined,
            ),
          ToolNote(hi
              ? 'बुख़ार में पानी और तरल ज़्यादा लें, और बिना डॉक्टर के एंटीबायोटिक न लें — '
                  'वे वायरस के बुख़ार पर काम नहीं करती और बाद में काम करना बंद कर देती हैं।'
              : 'Drink more water and fluids, and do not take antibiotics '
                  'without a doctor - they do nothing for a viral fever and '
                  'stop working when you need them later.'),
        ],
      ],
    );
  }
}

// --- Dog or animal bite -----------------------------------------------

/// The NCDC exposure categories. Which one it is decides whether the
/// immunoglobulin is needed, and that is the part people are sent home
/// without.
enum BiteCategory { touchOnly, nibbleNoBleed, brokeSkin, unsure }

BiteCategory biteCategory({required bool bled, required bool skinBroken}) {
  if (bled || skinBroken) return BiteCategory.brokeSkin;
  return BiteCategory.nibbleNoBleed;
}

class AnimalBitePage extends StatefulWidget {
  const AnimalBitePage({super.key});

  @override
  State<AnimalBitePage> createState() => _AnimalBitePageState();
}

class _AnimalBitePageState extends State<AnimalBitePage> {
  BiteCategory? _cat;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    Widget pick(BiteCategory c, String en, String h, String sub, String subHi) =>
        SelectionTile(
          label: hi ? h : en,
          subtitle: hi ? subHi : sub,
          selected: _cat == c,
          onTap: () => setState(() => _cat = c),
        );

    return ToolScaffold(
      goal: 3,
      title: hi ? 'कुत्ता या जानवर काट ले' : 'A dog or animal bite',
      children: [
        _CallNow(hi
            ? 'पहले घाव धोएँ — साबुन और बहते पानी से, पंद्रह मिनट। यह पहला क़दम '
                'सबसे ज़्यादा असर करता है, और सबसे ज़्यादा छोड़ा जाता है।'
            : 'Wash the wound first - soap and running water, fifteen '
                'minutes. This first step does more than anything else, and '
                'it is the one most often skipped.'),
        ToolSteps(
          steps: hi
              ? const [
                  'साबुन और बहते पानी से घाव धोएँ, धीरे-धीरे और अच्छी तरह। साबुन न हो तो '
                      'सिर्फ़ बहता पानी।',
                  'धोने के बाद बीटाडीन (पोविडोन आयोडीन) या स्पिरिट लगाएँ।',
                  'उसी दिन सरकारी अस्पताल जाएँ। देर हो गई हो तो भी जाएँ — घाव भरा न हो '
                      'तो धोना अब भी काम करता है।',
                  'जानवर किसका है, पता हो तो बताएँ; दस दिन तक उस पर नज़र रखी जा सकती है।',
                ]
              : const [
                  'Wash the wound with soap and running water, gently and '
                      'thoroughly. If there is no soap, running water alone.',
                  'After washing, apply povidone iodine (Betadine) or '
                      'spirit.',
                  'Go to a government hospital the same day. Go even if you '
                      'are late - as long as the wound has not healed, '
                      'washing still helps.',
                  'If you know whose animal it is, say so; it can be watched '
                      'for ten days.',
                ],
        ),
        ToolDonts(
          heading: hi ? 'घाव पर यह कभी न लगाएँ' : 'Never put these on the wound',
          items: hi
              ? const [
                  'मिर्च, सरसों का तेल, चूना, नमक, हल्दी, मिट्टी, जड़ी-बूटी, चॉक, पान का पत्ता '
                      '— ये घाव को नुक़सान पहुँचाते हैं और वायरस को नसों तक पहुँचने में मदद '
                      'करते हैं',
                  'घाव को खुले हाथ से न छुएँ',
                  'पट्टी बाँधकर बंद न करें',
                  'घाव को दागना (गरम चीज़ से जलाना) — यह अब सलाह में नहीं है',
                  'टाँके लगवाने से बचें; ज़रूरी हो तो पहले इम्यूनोग्लोब्युलिन लगवाएँ और कुछ '
                      'घंटे रुकें',
                ]
              : const [
                  'Chilli, mustard oil, lime, salt, turmeric, soil, herbs, '
                      'chalk, betel leaves - these damage the wound and help '
                      'the virus reach the nerves',
                  'Do not touch the wound with a bare hand',
                  'Do not close it with a dressing',
                  'Do not cauterise it - burning the wound is no longer '
                      'recommended',
                  'Avoid stitches; if they cannot be avoided, the '
                      'immunoglobulin goes in first and the stitching waits '
                      'a few hours',
                ],
        ),
        ToolQuestion(hi ? 'काटने में क्या हुआ' : 'What the bite was like'),
        pick(BiteCategory.touchOnly, 'Only touched or fed the animal, or it '
            'licked unbroken skin', 'सिर्फ़ छुआ या खिलाया, या बिना कटी त्वचा पर चाटा',
            'Category I', 'श्रेणी I'),
        pick(BiteCategory.nibbleNoBleed,
            'Nibbled the skin, or a scratch with no bleeding',
            'त्वचा कुतरी, या ख़रोंच जिसमें ख़ून नहीं आया',
            'Category II', 'श्रेणी II'),
        pick(BiteCategory.brokeSkin,
            'The skin broke, or it bled, or saliva reached eyes, nose or mouth',
            'त्वचा कट गई, या ख़ून आया, या लार आँख-नाक-मुँह में गई',
            'Category III', 'श्रेणी III'),
        pick(BiteCategory.unsure, 'Not sure', 'ठीक से पता नहीं',
            'Treat it as the higher one', 'ऊपर वाली श्रेणी मानकर चलें'),
        if (_cat != null) ...[
          if (_cat == BiteCategory.touchOnly)
            ToolAnswer(
              headline: hi
                  ? 'टीके की ज़रूरत आमतौर पर नहीं'
                  : 'Usually no vaccine needed',
              detail: hi
                  ? 'श्रेणी I में, अगर पक्का है कि त्वचा कटी नहीं और लार खुले घाव या '
                      'आँख-नाक-मुँह में नहीं गई, तो टीका ज़रूरी नहीं होता। ज़रा भी शक हो तो '
                      'अस्पताल में दिखा लें — टीका लगवा लेना नुक़सान नहीं करता, छोड़ देना '
                      'करता है।'
                  : 'In Category I, if you are certain the skin did not break '
                      'and no saliva reached an open wound or the eyes, nose '
                      'or mouth, a vaccine is not needed. If there is any '
                      'doubt at all, get it seen - having the vaccine does no '
                      'harm, skipping it can.',
              tone: ToolTone.good,
              icon: Icons.check_circle_outline,
            )
          else ...[
            ToolAnswer(
              headline: _cat == BiteCategory.nibbleNoBleed
                  ? (hi ? 'घाव की सफ़ाई और टीका' : 'Wound care and the vaccine')
                  : (hi
                      ? 'टीका और इम्यूनोग्लोब्युलिन, दोनों'
                      : 'Vaccine and immunoglobulin, both'),
              detail: _cat == BiteCategory.nibbleNoBleed
                  ? (hi
                      ? 'श्रेणी II में घाव की सफ़ाई और एंटी-रेबीज़ टीका ज़रूरी है।'
                      : 'Category II needs wound care and the anti-rabies '
                          'vaccine.')
                  : (hi
                      ? 'श्रेणी III में घाव की सफ़ाई, टीका और रेबीज़ इम्यूनोग्लोब्युलिन '
                          '(RIG) — तीनों ज़रूरी हैं। RIG घाव के आसपास लगाया जाता है, और '
                          'यही वह चीज़ है जिसके बिना लोग घर भेज दिए जाते हैं। नाम लेकर '
                          'माँगें।'
                      : 'Category III needs wound care, the vaccine, and '
                          'rabies immunoglobulin (RIG) - all three. RIG is '
                          'infiltrated around the wound, and it is the one '
                          'people get sent home without. Ask for it by name.'),
              tone: ToolTone.bad,
              icon: Icons.vaccines_outlined,
            ),
            const SizedBox(height: 12),
            Text(hi ? 'टीके के दिन' : 'The vaccine days',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            ToolLine(
                hi
                    ? 'त्वचा में (इंट्राडर्मल), दो जगह'
                    : 'Into the skin (intradermal), two sites',
                hi ? 'दिन 0, 3, 7, 28' : 'Days 0, 3, 7, 28',
                strong: true),
            ToolLine(
                hi ? 'मांस में (इंट्रामस्क्युलर)' : 'Into the muscle (intramuscular)',
                hi ? 'दिन 0, 3, 7, 14, 28' : 'Days 0, 3, 7, 14, 28'),
            const SizedBox(height: 8),
            ToolNote(hi
                ? 'अस्पताल इनमें से एक तरीक़ा अपनाता है — दोनों नहीं। "दिन 0" पहले टीके '
                    'का दिन है, काटने का दिन नहीं। कोई दिन छूट जाए तो उसी दिन जाएँ जिस '
                    'दिन याद आए; शुरू से दोबारा शुरू नहीं करना पड़ता। कार्ड पर तारीख़ें '
                    'लिखवाकर रखें।'
                : 'The hospital uses one of these two, not both. "Day 0" is '
                    'the day of the first dose, not the day of the bite. If a '
                    'day is missed, go the day you remember - the course does '
                    'not start again from the beginning. Get the dates '
                    'written on a card and keep it.'),
            if (_cat == BiteCategory.brokeSkin ||
                _cat == BiteCategory.unsure)
              ToolNote(hi
                  ? 'RIG पहले ही दिन लगना सबसे अच्छा है, और पहले टीके के सातवें दिन के '
                      'बाद इसका कोई फ़ायदा नहीं रहता। इसलिए देर न करें। यह नस में नहीं '
                      'लगाया जाता और टीके के साथ एक ही सिरिंज या एक ही जगह पर नहीं '
                      'लगाया जाता।'
                  : 'RIG is best given on the first day, and after the '
                      'seventh day from the first vaccine dose it is no '
                      'longer of use. So do not delay. It is never given into '
                      'a vein, nor in the same syringe or the same site as '
                      'the vaccine.'),
            ToolNote(hi
                ? 'सरकारी अस्पताल में यह राष्ट्रीय कार्यक्रम के तहत मुफ़्त मिलता है। '
                    'बाहर से ख़रीदने को कहा जाए तो यही शिकायत का मुद्दा है — इसी लक्ष्य में '
                    '"मुफ़्त योजना में पैसे माँगे गए" देखें।'
                : 'A government hospital provides this free under the '
                    'national programme. Being told to buy it outside is '
                    'itself the thing to complain about - see "Asked for '
                    'money under a free scheme" in this same goal.'),
          ],
          const SourceNote(
            text: 'National rabies post-exposure protocol, NCDC / MoHFW',
            url: _rabiesUrl,
          ),
        ],
      ],
    );
  }
}

// --- Snakebite --------------------------------------------------------

/// Snakebite is the screen where the don'ts carry the whole value.
///
/// The first aid people actually apply - a tourniquet, a cut, mouth
/// suction, a black stone, a trip to a traditional healer - is worse than
/// doing nothing, and the official guideline says so in plain words. The
/// only thing that treats envenoming is antivenom, in a hospital, and
/// almost all of the harm happens in the hour spent elsewhere.
class SnakebitePage extends StatelessWidget {
  const SnakebitePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 3,
      title: hi ? 'साँप काट ले' : 'A snakebite',
      children: [
        _CallNow(hi
            ? '108 बुलाएँ और अस्पताल चलें — अभी। ज़हर का इलाज सिर्फ़ एक है: '
                'एंटीवेनम, जो अस्पताल में लगता है। बाक़ी हर चीज़ में जो वक़्त जाता है, '
                'वही नुक़सान करता है।'
            : 'Call 108 and start for a hospital - now. There is one '
                'treatment for venom: antivenom, given in a hospital. The '
                'time spent on anything else is the harm.'),
        ToolNote(hi
            ? 'ज़्यादातर साँप ज़हरीले नहीं होते, और ज़हरीले साँप के काटने पर भी हर बार '
                'ज़हर नहीं चढ़ता। घबराहट ख़ुद नुक़सान करती है — मरीज़ को शांत रखें। '
                'करैत के काटने पर निशान दिखते ही नहीं, इसलिए निशान न मिलने को "कुछ '
                'नहीं हुआ" न समझें।'
            : 'Most snakes are not venomous, and even a venomous bite does '
                'not always inject venom. Panic does its own damage - keep '
                'the person calm. A krait bite may leave no visible mark at '
                'all, so finding no mark does not mean nothing happened.'),
        const SizedBox(height: 14),
        Text(hi ? 'अस्पताल पहुँचने तक यह करें' : 'Until you reach a hospital',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'मरीज़ को शांत कराएँ और लिटाएँ। बाएँ करवट, मुँह थोड़ा नीचे की ओर — '
                      'उलटी आए तो दम न घुटे।',
                  'काटे हुए हाथ या पैर को वैसे ही बाँधकर स्थिर करें जैसे हड्डी टूटने पर '
                      'करते हैं — खपच्ची और पट्टी से। कसकर नहीं; ख़ून का बहाव रुकना नहीं '
                      'चाहिए।',
                  'अँगूठी, घड़ी, चूड़ी, पायल, जूते और कसे कपड़े तुरंत उतार दें — सूजन बढ़ने '
                      'पर वही कसकर बाँधने जैसा काम करने लगते हैं।',
                  'मरीज़ चले या गाड़ी न चलाए। किसी भी साधन से ले जाएँ — एम्बुलेंस, '
                      'स्ट्रेचर, नाव, मोटरसाइकिल। मोटरसाइकिल हो तो पीछे एक तीसरा आदमी '
                      'बैठकर मरीज़ को सँभाले।',
                  'कुछ भी खाने-पीने को न दें, अस्पताल पहुँचने तक।',
                  'साँप दिखा हो तो दूर से फ़ोटो ले लें। मारने या पकड़ने की कोशिश न करें।',
                  'हो सके तो फ़ोन करके पक्का कर लें कि जिस अस्पताल जा रहे हैं वहाँ '
                      'एंटीवेनम है।',
                ]
              : const [
                  'Calm the person and lay them down. On the left side, face '
                      'tilted down, so that vomit cannot choke them.',
                  'Immobilise the bitten arm or leg exactly as you would a '
                      'broken bone - a splint and bandages. Not tight; blood '
                      'flow must not be cut off.',
                  'Take off rings, watches, bangles, anklets, footwear and '
                      'tight clothing at once - as the swelling rises they '
                      'start acting as tourniquets themselves.',
                  'The person must not walk or drive. Carry them by any '
                      'means - ambulance, stretcher, boat, motorbike. On a '
                      'motorbike a third person sits behind to hold them up.',
                  'Give nothing to eat or drink until the hospital.',
                  'If you saw the snake, photograph it from a distance. Do '
                      'not try to kill or catch it.',
                  'If you can, phone ahead and confirm the hospital you are '
                      'going to has antivenom.',
                ],
        ),
        ToolDonts(
          heading: hi ? 'यह कभी न करें' : 'Never do these',
          items: hi
              ? const [
                  'कसकर रस्सी या कपड़ा न बाँधें (टूर्निकेट)। सरकारी दिशा-निर्देश साफ़ कहता '
                      'है कि इससे अंग गल सकता है, और खोलते समय ज़हर एकसाथ चढ़ सकता है।',
                  'घाव को चीरें नहीं',
                  'मुँह से या किसी यंत्र से ज़हर चूसने की कोशिश न करें — मुँह से चूसना '
                      'सख़्त मना है',
                  'घाव को धोएँ, रगड़ें या मालिश न करें',
                  'जड़ी-बूटी, तेल, रसायन, "काला पत्थर", बर्फ़ या दाग़ना — किसी का कोई '
                      'सिद्ध फ़ायदा नहीं है',
                  'बिजली का झटका न दें — इसकी कोई भूमिका नहीं है',
                  'फफोले न फोड़ें',
                  'एंटीवेनम काटे हुए जगह पर न लगवाएँ',
                  'झाड़-फूँक या वैद्य के पास समय न गँवाएँ — यही वह घंटा है जिसमें जान '
                      'जाती है',
                ]
              : const [
                  'Do not tie a rope or cloth tightly (a tourniquet). The '
                      'government guideline says plainly that it can cost the '
                      'limb, and that releasing it can send the venom up all '
                      'at once.',
                  'Do not cut the wound',
                  'Do not try to suck the venom out, by mouth or by any '
                      'device - mouth suction is strongly prohibited',
                  'Do not wash, rub or massage the bite',
                  'No herbs, oils, chemicals, "black stone", ice or '
                      'cautery - none of these has any proven benefit',
                  'No electric shock - it has no role at all',
                  'Do not break the blisters',
                  'Do not have antivenom injected into the bite itself',
                  'Do not spend the time on a healer or a charm - that hour '
                      'is the one in which people die',
                ],
        ),
        const SizedBox(height: 14),
        ToolAnswer(
          headline: hi
              ? 'अस्पताल तीन घंटे दूर हो तो'
              : 'If the hospital is hours away',
          detail: hi
              ? 'अगर अस्पताल पहुँचने में आधे घंटे से तीन घंटे लगेंगे, तो दिशा-निर्देश में '
                  'एक ही छूट है: प्रशिक्षित व्यक्ति काटे हुए अंग पर पूरी लंबाई में क्रेप '
                  'पट्टी लपेट सकता है, खपच्ची के साथ — इतनी ढीली कि उसके नीचे एक उँगली '
                  'सरक जाए। यह टूर्निकेट नहीं है और टूर्निकेट की छूट नहीं है।'
              : 'If reaching hospital will take between half an hour and '
                  'three hours, the guideline allows exactly one thing: '
                  'qualified personnel may wrap a crepe bandage along the '
                  'whole bitten limb, with a splint - loose enough to slide a '
                  'finger underneath. This is not a tourniquet, and it is not '
                  'permission for one.',
          tone: ToolTone.warn,
          icon: Icons.route_outlined,
        ),
        ToolNote(hi
            ? 'एंटीवेनम सरकारी अस्पताल में मुफ़्त है। पहले अस्पताल में न हो तो वहीं से '
                'पूछकर उस अस्पताल भेजा जाता है जहाँ है — घर वापस न लौटें। कई राज्यों '
                'में साँप काटने से मौत पर मुआवज़ा मिलता है; ज़िला आपदा प्रबंधन कार्यालय '
                'में पूछें।'
            : 'Antivenom is free at a government hospital. If the first '
                'hospital does not have it they refer you onward to one that '
                'does - do not go home. Several states pay compensation for a '
                'snakebite death; ask at the district disaster management '
                'office.'),
        const SourceNote(
          text: 'Standard Treatment Guideline: snakebite, National Health '
              'Mission',
          url: _snakeUrl,
        ),
      ],
    );
  }
}

// --- Pregnancy --------------------------------------------------------

/// Check-up dates worked back from the last period, and the danger signs
/// that mean going without waiting for a date.
///
/// The four-visit schedule is India's minimum, and the dates are the thing
/// a family can actually act on: a woman who knows her fourth visit is due
/// in the ninth month goes to it. The danger signs are copied from the ANC
/// guidelines, including which level of facility each one needs, because
/// "go to a hospital" is useless advice when the sub-centre is nearer and
/// cannot help.
class PregnancyCarePage extends StatefulWidget {
  const PregnancyCarePage({super.key});

  @override
  State<PregnancyCarePage> createState() => _PregnancyCarePageState();
}

class _PregnancyCarePageState extends State<PregnancyCarePage> {
  DateTime? _lmp;

  /// Expected delivery date: last period plus 280 days.
  DateTime? get _due =>
      _lmp == null ? null : _lmp!.add(const Duration(days: 280));

  int? get _weeks =>
      _lmp == null ? null : DateTime.now().difference(_lmp!).inDays ~/ 7;

  Future<void> _pick() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _lmp ?? now.subtract(const Duration(days: 60)),
      firstDate: now.subtract(const Duration(days: 300)),
      lastDate: now,
    );
    if (picked != null) setState(() => _lmp = picked);
  }

  String _date(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final lmp = _lmp;
    final weeks = _weeks;

    return ToolScaffold(
      goal: 3,
      title: hi
          ? 'गर्भावस्था: जाँच और ख़तरे के संकेत'
          : 'Pregnancy: check-ups and danger signs',
      children: [
        _CallNow(hi
            ? 'नीचे दिए किसी भी संकेत पर दिन हो या रात, इंतज़ार किए बिना जाएँ। '
                'एम्बुलेंस 102 या 108।'
            : 'With any of the signs below, go without waiting, day or '
                'night. Ambulance 102 or 108.'),
        ToolQuestion(hi
            ? 'पिछली माहवारी का पहला दिन'
            : 'First day of the last period'),
        OutlinedButton.icon(
          onPressed: _pick,
          icon: const Icon(Icons.event_outlined),
          label: Text(lmp == null
              ? (hi ? 'तारीख़ चुनें' : 'Pick the date')
              : _date(lmp)),
        ),
        if (lmp != null && weeks != null) ...[
          ToolAnswer(
            headline: hi
                ? 'अनुमानित प्रसव तारीख़: ${_date(_due!)}'
                : 'Expected delivery around ${_date(_due!)}',
            detail: hi
                ? 'आज लगभग $weeks हफ़्ते पूरे हुए। तारीख़ अनुमान है — पहली जाँच में '
                    'डॉक्टर इसे ठीक कर देंगे।'
                : 'About $weeks weeks completed today. The date is an '
                    'estimate - it gets corrected at the first check-up.',
            tone: ToolTone.plain,
            icon: Icons.child_friendly_outlined,
          ),
          const SizedBox(height: 12),
          Text(hi ? 'कम से कम चार जाँच' : 'At least four check-ups',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ToolLine(
              hi ? 'पहली — 12 हफ़्ते तक, जितनी जल्दी हो' : 'First - by 12 weeks, as early as possible',
              _date(lmp.add(const Duration(days: 84))),
              strong: weeks < 12),
          ToolLine(hi ? 'दूसरी — लगभग 24 हफ़्ते' : 'Second - around 24 weeks',
              _date(lmp.add(const Duration(days: 168))),
              strong: weeks >= 12 && weeks < 26),
          ToolLine(hi ? 'तीसरी — लगभग 32 हफ़्ते' : 'Third - around 32 weeks',
              _date(lmp.add(const Duration(days: 224))),
              strong: weeks >= 26 && weeks < 34),
          ToolLine(hi ? 'चौथी — लगभग 36 हफ़्ते' : 'Fourth - around 36 weeks',
              _date(lmp.add(const Duration(days: 252))),
              strong: weeks >= 34),
          const SizedBox(height: 10),
          ToolNote(hi
              ? 'हर महीने की 9 तारीख़ को सरकारी अस्पताल में प्रधानमंत्री सुरक्षित मातृत्व '
                  'अभियान के तहत पूरी जाँच मुफ़्त होती है — ख़ून, पेशाब, वज़न, रक्तचाप, और '
                  'जहाँ उपलब्ध हो वहाँ अल्ट्रासाउंड। जाँच में देर हो गई हो तो इसी दिन जाएँ।'
              : 'On the 9th of every month a government facility gives a full '
                  'check-up free under the Pradhan Mantri Surakshit Matritva '
                  'Abhiyan - blood, urine, weight, blood pressure, and an '
                  'ultrasound where there is one. If a check-up has been '
                  'missed, that is the day to go.'),
          ToolNote(hi
              ? 'हर जाँच में वज़न, रक्तचाप, ख़ून की कमी और पेट की जाँच होती है। आयरन-'
                  'फ़ोलिक एसिड की गोलियाँ पहली तिमाही के बाद शुरू होती हैं और टिटनेस के '
                  'दो टीके एक महीने के अंतर पर लगते हैं, दूसरा प्रसव से कम से कम एक महीने '
                  'पहले। माँ-बच्चा सुरक्षा कार्ड हर बार साथ ले जाएँ।'
              : 'Every visit covers weight, blood pressure, a check for '
                  'anaemia and an abdominal examination. Iron and folic acid '
                  'tablets start after the first trimester, and two tetanus '
                  'doses are given a month apart, the second at least a month '
                  'before the due date. Carry the Mother and Child Protection '
                  'card every time.'),
        ],
        const SizedBox(height: 16),
        Text(hi ? 'ख़तरे के संकेत' : 'The danger signs',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolDonts(
          heading: hi
              ? 'गर्भावस्था या प्रसव में — बड़े अस्पताल (FRU) जाएँ, इंतज़ार बिना'
              : 'In pregnancy or labour - go to a first referral unit, '
                  'without waiting',
          items: hi
              ? const [
                  'गर्भावस्था में कोई भी ख़ून आना, या प्रसव के समय/बाद तेज़ ख़ून बहना',
                  'तेज़ सिरदर्द के साथ आँखों के आगे धुँधलापन',
                  'दौरा पड़ना या बेहोश हो जाना',
                  'प्रसव पीड़ा बारह घंटे से ज़्यादा चलना',
                  'बच्चा होने के तीस मिनट बाद भी आँवल (प्लेसेंटा) न निकलना',
                  'समय से पहले प्रसव पीड़ा शुरू होना',
                  'समय से पहले पानी की थैली फटना',
                  'पेट में लगातार तेज़ दर्द',
                ]
              : const [
                  'Any bleeding during pregnancy, or heavy bleeding during or '
                      'after delivery',
                  'A severe headache with blurred vision',
                  'A convulsion, or loss of consciousness',
                  'Labour going on longer than twelve hours',
                  'The placenta not delivered within thirty minutes of the '
                      'birth',
                  'Labour starting early',
                  'The waters breaking early',
                  'Continuous severe abdominal pain',
                ],
        ),
        ToolDonts(
          heading: hi
              ? 'गर्भावस्था में — 24 घंटे वाले पीएचसी जाएँ'
              : 'In pregnancy - go to a 24-hour PHC',
          items: hi
              ? const [
                  'तेज़ बुख़ार, पेट दर्द के साथ या बिना, और बिस्तर से उठने की ताक़त न होना',
                  'साँस तेज़ चलना या साँस लेने में तकलीफ़',
                  'बच्चे का हिलना कम हो जाना या बंद हो जाना',
                  'बहुत उलटी, कुछ भी मुँह से न ले पाना, और पेशाब कम हो जाना',
                ]
              : const [
                  'High fever, with or without abdominal pain, and too weak '
                      'to get out of bed',
                  'Fast or difficult breathing',
                  'The baby moving less, or not at all',
                  'Excessive vomiting, unable to keep anything down, and '
                      'passing less urine',
                ],
        ),
        ToolDonts(
          heading: hi
              ? 'प्रसव के बाद — तुरंत पीएचसी या बड़े अस्पताल'
              : 'After delivery - a PHC or referral unit at once',
          items: hi
              ? const [
                  'तेज़ ख़ून बहना, या ख़ून कम होने के बजाय बढ़ता जाना',
                  'दौरा पड़ना',
                  'साँस तेज़ या तकलीफ़ के साथ',
                  'बुख़ार के साथ कमज़ोरी, या पेट में तेज़ दर्द',
                ]
              : const [
                  'Heavy bleeding, or bleeding that increases instead of '
                      'settling',
                  'A convulsion',
                  'Fast or difficult breathing',
                  'Fever with weakness, or severe abdominal pain',
                ],
        ),
        ToolNote(hi
            ? 'सरकारी अस्पताल में प्रसव, दवाएँ, जाँच, ख़ून और आने-जाने की गाड़ी — ये '
                'जननी सुरक्षा योजना और जननी शिशु सुरक्षा कार्यक्रम के तहत मुफ़्त हैं, और '
                'सिज़ेरियन भी। मातृ वंदना योजना का पैसा अलग है — इसी लक्ष्य में उसकी '
                'स्क्रीन देखें।'
            : 'At a government hospital the delivery, medicines, tests, '
                'blood and the transport are free under Janani Suraksha '
                'Yojana and the Janani Shishu Suraksha Karyakram - a '
                'caesarean too. The Matru Vandana money is a separate thing - '
                'see its own screen in this goal.'),
        const SourceNote(
          text: 'Antenatal care and skilled attendance at birth, National '
              'Health Mission',
          url: _ancUrl,
        ),
      ],
    );
  }
}
