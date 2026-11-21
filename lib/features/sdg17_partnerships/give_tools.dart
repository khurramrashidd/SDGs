import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Giving time, blood, organs or money - safely.
///
/// The blood screen is a first check, not a medical clearance. It only
/// turns someone away for the plain reasons every blood bank applies, and
/// otherwise says "you can likely give - the blood bank will check",
/// because the blood bank's own doctor makes the decision.

const _myBharatUrl = 'https://mybharat.gov.in/';
const _ndmaUrl = 'https://ndma.gov.in/';
const _vidyanjaliUrl = 'https://vidyanjali.education.gov.in/';
const _raktUrl = 'https://eraktkosh.mohfw.gov.in/';
const _nottoUrl = 'https://notto.mohfw.gov.in/';
const _darpanUrl = 'https://ngodarpan.gov.in/';
const _pmnrfUrl = 'https://pmnrf.gov.in/';

const bloodMinAge = 18;
const bloodMaxAge = 65;
const bloodMinWeightKg = 45;
const bloodGapMenDays = 90;
const bloodGapWomenDays = 120;

// --- Volunteer --------------------------------------------------------

enum Skill { teach, disaster, health, youth, any }

class VolunteerPage extends StatefulWidget {
  const VolunteerPage({super.key});

  @override
  State<VolunteerPage> createState() => _VolunteerPageState();
}

class _VolunteerPageState extends State<VolunteerPage> {
  Skill? _skill;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    final where = switch (_skill) {
      Skill.teach => (
          hi
              ? 'विद्यांजलि — शिक्षा मंत्रालय का पोर्टल, जहाँ सरकारी स्कूल बताते हैं कि '
                  'उन्हें किस मदद की ज़रूरत है: पढ़ाना, खेल, कला, या सामान। अपने पास '
                  'का स्कूल चुनकर समय दें।'
              : 'Vidyanjali - the Ministry of Education portal where government '
                  'schools list what help they need: teaching, sport, art, or '
                  'materials. Pick a school near you and offer time.',
          _vidyanjaliUrl,
          'Vidyanjali',
        ),
      Skill.disaster => (
          hi
              ? 'आपदा मित्र — एनडीएमए की योजना, जिसमें बाढ़-भूकंप जैसी आपदा में पहली मदद '
                  'के लिए गाँव-मोहल्ले के लोगों को प्रशिक्षण दिया जाता है। ज़िला आपदा '
                  'प्रबंधन प्राधिकरण से पूछें। रेड क्रॉस की ज़िला शाखा भी स्वयंसेवक लेती है।'
              : 'Aapda Mitra - NDMA\'s scheme that trains local people to give '
                  'first help in floods, earthquakes and other disasters. Ask '
                  'the district disaster management authority. The district '
                  'branch of the Red Cross also takes volunteers.',
          _ndmaUrl,
          'National Disaster Management Authority',
        ),
      Skill.health => (
          hi
              ? 'रक्तदान शिविर, टीकाकरण और स्वास्थ्य शिविर में मदद — ज़िला अस्पताल, '
                  'रेड क्रॉस या ब्लड बैंक से पूछें। रक्तदान ख़ुद सबसे सीधी मदद है — इसी '
                  'लक्ष्य में "रक्तदान" देखें।'
              : 'Helping at blood donation, vaccination and health camps - ask '
                  'the district hospital, the Red Cross or a blood bank. Giving '
                  'blood yourself is the most direct help - see "Blood '
                  'donation" in this goal.',
          _raktUrl,
          'e-RaktKosh',
        ),
      Skill.youth => (
          hi
              ? 'मेरा युवा भारत (माई भारत) — युवा मामले मंत्रालय का मंच, जहाँ स्वयंसेवा '
                  'के मौक़े, अभियान और कार्यक्रम एक जगह मिलते हैं। कॉलेज में हों तो '
                  'एनएसएस और एनसीसी भी।'
              : 'MY Bharat - the Ministry of Youth Affairs\' platform listing '
                  'volunteering opportunities, campaigns and programmes in one '
                  'place. At college, NSS and NCC too.',
          _myBharatUrl,
          'MY Bharat',
        ),
      Skill.any => (
          hi
              ? 'शुरुआत पास से करें: आँगनवाड़ी, पंचायत, स्कूल प्रबंधन समिति, या ग्राम '
                  'सभा की बैठक। माई भारत पर अपने ज़िले के मौक़े भी दिखते हैं।'
              : 'Start close by: the anganwadi, the panchayat, the school '
                  'management committee, or the gram sabha. MY Bharat also shows '
                  'opportunities in your district.',
          _myBharatUrl,
          'MY Bharat',
        ),
      null => null,
    };

    return ToolScaffold(
      goal: 17,
      title: hi ? 'पास में स्वयंसेवा' : 'Volunteer near you',
      children: [
        ToolNote(hi
            ? 'ये सरकारी मंच हैं, जहाँ स्वयंसेवा मुफ़्त है और काम असली है। कोई संस्था '
                'स्वयंसेवा के लिए आपसे पैसा माँगे तो वह स्वयंसेवा नहीं है।'
            : 'These are government platforms, where volunteering is free and '
                'the work is real. An organisation that asks you to pay to '
                'volunteer is not offering volunteering.'),
        ToolQuestion(hi ? 'आप क्या दे सकते हैं' : 'What can you offer'),
        SelectionTile(
          label: hi ? 'पढ़ाना या बच्चों के साथ काम' : 'Teaching, or working with children',
          selected: _skill == Skill.teach,
          onTap: () => setState(() => _skill = Skill.teach),
        ),
        SelectionTile(
          label: hi ? 'आपदा में मदद' : 'Help in disasters',
          selected: _skill == Skill.disaster,
          onTap: () => setState(() => _skill = Skill.disaster),
        ),
        SelectionTile(
          label: hi ? 'स्वास्थ्य शिविर और रक्तदान' : 'Health camps and blood donation',
          selected: _skill == Skill.health,
          onTap: () => setState(() => _skill = Skill.health),
        ),
        SelectionTile(
          label: hi ? 'युवा — कॉलेज या 15 से 29 साल' : 'Youth - college, or 15 to 29',
          selected: _skill == Skill.youth,
          onTap: () => setState(() => _skill = Skill.youth),
        ),
        SelectionTile(
          label: hi ? 'कुछ भी, बस शुरू करना है' : 'Anything - I just want to start',
          selected: _skill == Skill.any,
          onTap: () => setState(() => _skill = Skill.any),
        ),
        if (where != null) ...[
          ToolAnswer(
            headline: hi ? 'यहाँ से शुरू करें' : 'Start here',
            detail: where.$1,
            tone: ToolTone.good,
            icon: Icons.volunteer_activism_outlined,
          ),
          SourceNote(text: where.$3, url: where.$2),
        ],
      ],
    );
  }
}

// --- Blood donation ---------------------------------------------------

class BloodDonationPage extends StatefulWidget {
  const BloodDonationPage({super.key});

  @override
  State<BloodDonationPage> createState() => _BloodDonationPageState();
}

class _BloodDonationPageState extends State<BloodDonationPage> {
  final _age = TextEditingController();
  final _weight = TextEditingController();
  final _daysSince = TextEditingController();
  bool _woman = false;
  bool _unwell = false;
  bool _tattoo = false;
  bool _pregnancy = false;
  bool _alcohol = false;

  @override
  void dispose() {
    _age.dispose();
    _weight.dispose();
    _daysSince.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final age = int.tryParse(_age.text.trim());
    final weight = double.tryParse(_weight.text.trim());
    final since = int.tryParse(_daysSince.text.trim());
    final gap = _woman ? bloodGapWomenDays : bloodGapMenDays;

    final reasons = <String>[
      if (age != null && (age < bloodMinAge || age > bloodMaxAge))
        hi
            ? 'उम्र $bloodMinAge से $bloodMaxAge साल के बीच होनी चाहिए।'
            : 'Age has to be between $bloodMinAge and $bloodMaxAge.',
      if (weight != null && weight < bloodMinWeightKg)
        hi
            ? 'वज़न कम से कम $bloodMinWeightKg किलो होना चाहिए।'
            : 'Weight has to be at least $bloodMinWeightKg kg.',
      if (since != null && since < gap)
        hi
            ? 'पिछले रक्तदान के बाद $gap दिन होने चाहिए — अभी ${gap - since} दिन बाक़ी।'
            : '$gap days must pass after the last donation - ${gap - since} '
                'days to go.',
      if (_unwell)
        hi
            ? 'आज बुख़ार, खाँसी-ज़ुकाम या कोई बीमारी हो तो ठीक होने के बाद आएँ।'
            : 'With a fever, cold or any illness today, come once you are well.',
      if (_tattoo)
        hi
            ? 'पिछले 12 महीने में टैटू, कान-नाक छिदवाना या एक्यूपंक्चर हुआ हो तो उसके '
                '12 महीने बाद।'
            : 'After a tattoo, piercing or acupuncture in the last 12 months, '
                'wait until 12 months have passed.',
      if (_pregnancy)
        hi
            ? 'गर्भावस्था में, प्रसव के बाद के साल में, या बच्चे को दूध पिलाने के दौरान '
                'रक्तदान नहीं।'
            : 'Not during pregnancy, in the year after delivery, or while '
                'breastfeeding.',
      if (_alcohol)
        hi
            ? 'पिछले 24 घंटे में शराब पी हो तो कल आएँ।'
            : 'If you have had alcohol in the last 24 hours, come tomorrow.',
    ];
    final asked = age != null || weight != null;

    return ToolScaffold(
      goal: 17,
      title: hi ? 'रक्तदान: क्या आज दे सकता/सकती हूँ' : 'Blood donation: can I give today',
      children: [
        ToolNote(hi
            ? 'यह पहली जाँच है। ब्लड बैंक का डॉक्टर आपका हीमोग्लोबिन, रक्तचाप और '
                'बाक़ी बातें ख़ुद जाँचकर तय करता है। एक बार में दिया ख़ून कुछ हफ़्तों में '
                'शरीर फिर बना लेता है।'
            : 'This is a first check. The blood bank\'s doctor tests your '
                'haemoglobin, blood pressure and the rest and decides. The body '
                'replaces one donation within a few weeks.'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _age,
                label: hi ? 'उम्र' : 'Age',
                maxDigits: 3,
                icon: Icons.person_outline,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _weight,
                label: hi ? 'वज़न (किलो)' : 'Weight (kg)',
                decimal: true,
                maxDigits: 3,
                icon: Icons.scale_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _woman,
          onChanged: (v) => setState(() => _woman = v),
          title: Text(hi ? 'मैं महिला हूँ' : 'I am a woman'),
        ),
        ToolNumber(
          controller: _daysSince,
          label: hi
              ? 'पिछले रक्तदान को कितने दिन (पहली बार हो तो ख़ाली छोड़ें)'
              : 'Days since last donation (leave empty if first time)',
          maxDigits: 4,
          icon: Icons.event_outlined,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 6),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _unwell,
          onChanged: (v) => setState(() => _unwell = v ?? false),
          title: Text(hi ? 'आज बुख़ार या कोई बीमारी' : 'A fever or illness today'),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _tattoo,
          onChanged: (v) => setState(() => _tattoo = v ?? false),
          title: Text(hi
              ? '12 महीने में टैटू, छिदवाना या एक्यूपंक्चर'
              : 'A tattoo, piercing or acupuncture in 12 months'),
        ),
        if (_woman)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _pregnancy,
            onChanged: (v) => setState(() => _pregnancy = v ?? false),
            title: Text(hi
                ? 'गर्भवती, साल भर में प्रसव, या दूध पिला रही हूँ'
                : 'Pregnant, delivered within a year, or breastfeeding'),
          ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _alcohol,
          onChanged: (v) => setState(() => _alcohol = v ?? false),
          title: Text(hi ? '24 घंटे में शराब' : 'Alcohol in the last 24 hours'),
        ),
        if (asked)
          reasons.isEmpty
              ? ToolAnswer(
                  headline: hi ? 'आप शायद दे सकते हैं' : 'You can likely give',
                  detail: hi
                      ? 'ब्लड बैंक जाकर आख़िरी जाँच कराएँ। जाने से पहले ठीक से खाना खाएँ और '
                          'पानी पिएँ, और रोज़ कोई दवा लेते हों तो डॉक्टर को बताएँ।'
                      : 'Go to the blood bank for the final check. Eat a proper '
                          'meal and drink water before you go, and tell the doctor '
                          'about any medicine you take daily.',
                  tone: ToolTone.good,
                  icon: Icons.bloodtype_outlined,
                )
              : ToolAnswer(
                  headline: hi ? 'आज नहीं' : 'Not today',
                  detail: reasons.join('\n\n'),
                  tone: ToolTone.warn,
                  icon: Icons.schedule,
                ),
        const SizedBox(height: 10),
        ToolNote(hi
            ? 'पास का ब्लड बैंक, रक्त की उपलब्धता और रक्तदान शिविर ई-रक्तकोश पर देखे जा '
                'सकते हैं। रक्तदान मुफ़्त है — इसके बदले कोई पैसा न लें, न दें।'
            : 'The nearest blood bank, blood availability and donation camps '
                'are on e-RaktKosh. Donation is free - take no money for it and '
                'pay none.'),
        const SourceNote(text: 'e-RaktKosh', url: _raktUrl),
      ],
    );
  }
}

// --- Organ donation pledge --------------------------------------------

class OrganPledgePage extends StatelessWidget {
  const OrganPledgePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 17,
      title: hi ? 'अंगदान का संकल्प' : 'Organ donation pledge',
      children: [
        ToolAnswer(
          headline: hi ? 'जो बातचीत सबसे ज़रूरी है' : 'The one conversation that matters',
          detail: hi
              ? 'संकल्प आपकी सहमति दर्ज करता है, पर मृत्यु के समय अंगदान परिवार की '
                  'सहमति से ही होता है — परिवार मना करे तो नहीं होता। इसलिए संकल्प के '
                  'बाद सबसे ज़रूरी काम है घर वालों को बताना कि आप यह चाहते हैं। जिस परिवार '
                  'को पहले से पता हो, वह उस कठिन घड़ी में हाँ कह पाता है।'
              : 'A pledge records your consent, but at death donation happens '
                  'only with the family\'s consent - if the family refuses, it '
                  'does not happen. So the most important step after pledging is '
                  'telling your family that this is what you want. A family that '
                  'already knows can say yes in that hard moment.',
          tone: ToolTone.good,
          icon: Icons.family_restroom_outlined,
        ),
        const SizedBox(height: 12),
        Text(hi ? 'संकल्प कैसे लें' : 'How to pledge',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'राष्ट्रीय अंग और ऊतक प्रत्यारोपण संगठन (नोटो) की वेबसाइट पर ऑनलाइन '
                      'संकल्प लें, आधार से। या उसका फ़ॉर्म भरकर डाक से भेजें।',
                  'डोनर कार्ड मिलता है — उसे साथ रखें। किसी और संस्था में अलग से पंजीकरण '
                      'की ज़रूरत नहीं।',
                  'घर वालों को बताएँ, और हो सके तो किसी दो लोगों को गवाह बनाएँ।',
                ]
              : const [
                  'Pledge online on the website of the National Organ and Tissue '
                      'Transplant Organisation (NOTTO), using Aadhaar. Or fill its '
                      'form and post it.',
                  'You get a donor card - carry it. There is no need to register '
                      'separately with any other organisation.',
                  'Tell your family, and if you can, have two people witness it.',
                ],
        ),
        const SizedBox(height: 12),
        Text(hi ? 'कुछ बातें जो लोग पूछते हैं' : 'Things people ask',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'अंगदान ज़्यादातर "ब्रेन डेथ" के बाद होता है, जब अस्पताल में डॉक्टरों का '
                      'बोर्ड इसे प्रमाणित करता है। आँखें (कॉर्निया) सामान्य मृत्यु के बाद भी '
                      'दान हो सकती हैं — पर जितनी जल्दी, उतना अच्छा; पास के आई बैंक को तुरंत '
                      'बताएँ।',
                  'जीवित रहते हुए दान — जैसे गुर्दा — सिर्फ़ नज़दीकी रिश्तेदार को हो सकता है; '
                      'बाक़ी के लिए अस्पताल या राज्य की प्राधिकार समिति की मंज़ूरी चाहिए।',
                  'अंगों की ख़रीद-बिक्री अपराध है। कोई पैसे के बदले अंग माँगे या बेचने को '
                      'कहे, तो पुलिस को बताएँ।',
                  'पूरे शरीर का दान मेडिकल कॉलेज को अलग से होता है — कॉलेज के एनाटॉमी '
                      'विभाग से पूछें।',
                ]
              : const [
                  'Organ donation mostly follows "brain death", certified in '
                      'hospital by a board of doctors. Eyes (corneas) can be '
                      'donated after an ordinary death too - but the sooner the '
                      'better; tell the nearest eye bank at once.',
                  'Living donation - a kidney, say - is allowed to a near '
                      'relative; anyone else needs approval from the hospital or '
                      'state authorisation committee.',
                  'Buying or selling organs is a crime. If anyone asks for an '
                      'organ for money, or asks you to sell one, tell the police.',
                  'Whole-body donation to a medical college is separate - ask '
                      'the college\'s anatomy department.',
                ],
        ),
        const SourceNote(text: 'NOTTO', url: _nottoUrl),
      ],
    );
  }
}

// --- Check a charity --------------------------------------------------

class CharityCheckPage extends StatelessWidget {
  const CharityCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 17,
      title: hi ? 'सुरक्षित दान: संस्था जाँचें' : 'Donate safely: check a charity',
      children: [
        ToolNote(hi
            ? 'दान से पहले पाँच मिनट की जाँच ज़्यादातर ठगी रोक देती है। निशान लगाते '
                'जाएँ — ये इसी फ़ोन में रहते हैं।'
            : 'Five minutes of checking before giving stops most fraud. Tick as '
                'you go - the ticks stay on this phone.'),
        const SizedBox(height: 10),
        const ToolChecklist(
          storageKey: 'charity_check_v1',
          introEn: 'Before you give:',
          introHi: 'दान से पहले:',
          items: [
            CheckItem('reg', 'It is a registered trust, society or section 8 company',
                'संस्था पंजीकृत ट्रस्ट, सोसाइटी या धारा 8 कंपनी है',
                noteEn: 'Ask for the registration number. NGO Darpan on NITI '
                    'Aayog\'s site lists many.',
                noteHi: 'पंजीकरण संख्या माँगें। नीति आयोग के "एनजीओ दर्पण" पर बहुत सी '
                    'संस्थाएँ दर्ज हैं।'),
            CheckItem('account', 'The money goes to the organisation\'s account, not a person\'s',
                'पैसा संस्था के खाते में जाए, किसी व्यक्ति के नहीं',
                noteEn: 'A QR code or UPI ID in an individual\'s name is the '
                    'commonest sign of a fake appeal.',
                noteHi: 'किसी व्यक्ति के नाम का क्यूआर कोड या यूपीआई आईडी नक़ली अपील '
                    'का सबसे आम निशान है।'),
            CheckItem('receipt', 'A receipt with the organisation\'s PAN',
                'संस्था के पैन के साथ रसीद'),
            CheckItem('80g', 'If you want a tax deduction, its 80G number - checked',
                'कर छूट चाहिए तो 80जी संख्या — जाँची हुई',
                noteEn: 'The income tax e-filing site can verify it.',
                noteHi: 'आयकर ई-फ़ाइलिंग वेबसाइट पर जाँची जा सकती है।'),
            CheckItem('what', 'It says what the money is for, and you can see the work',
                'बताया गया है कि पैसा किस काम पर लगेगा, और काम दिखता है'),
            CheckItem('pressure', 'No pressure, no "today only"',
                'कोई दबाव नहीं, कोई "बस आज ही" नहीं'),
          ],
        ),
        const SizedBox(height: 12),
        ToolDonts(
          heading: hi ? 'आम चालें' : 'The usual tricks',
          items: hi
              ? const [
                  'आपदा के तुरंत बाद मशहूर नामों से चलने वाली नक़ली अपीलें',
                  'किसी बीमार बच्चे की फ़ोटो, जो कई अपीलों में दोबारा दिखे',
                  'मंदिर, मस्जिद, गुरुद्वारे या सेना के नाम पर फ़ोन',
                  'दान के बदले "इनाम" या "लकी ड्रॉ"',
                ]
              : const [
                  'Fake appeals in famous names right after a disaster',
                  'A sick child\'s photo that turns up in several appeals',
                  'Calls in the name of a temple, mosque, gurdwara or the army',
                  'A "prize" or "lucky draw" in return for a donation',
                ],
        ),
        const SizedBox(height: 10),
        ToolNote(hi
            ? 'आपदा राहत के लिए सबसे सुरक्षित रास्ता प्रधानमंत्री राष्ट्रीय राहत कोष या '
                'राज्य का मुख्यमंत्री राहत कोष है — दोनों की अपनी सरकारी वेबसाइट है।'
            : 'For disaster relief the safest route is the Prime Minister\'s '
                'National Relief Fund or the state Chief Minister\'s relief fund - '
                'each has its own government website.'),
        const SourceNote(text: 'NGO Darpan', url: _darpanUrl),
        const SourceNote(text: 'PM National Relief Fund', url: _pmnrfUrl),
      ],
    );
  }
}

// --- Crowdfunding for treatment ---------------------------------------

class CrowdfundPage extends StatelessWidget {
  const CrowdfundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 17,
      title: hi ? 'इलाज के लिए चंदा जुटाना' : 'Crowdfunding for treatment',
      children: [
        ToolAnswer(
          headline: hi ? 'पहले सरकारी मदद, फिर चंदा' : 'Government help first, then crowdfunding',
          detail: hi
              ? 'चंदे से पहले ये देखें, क्योंकि ये पैसा लौटाने को नहीं कहते: आयुष्मान '
                  'भारत (₹5 लाख तक, लक्ष्य 3 में), राज्य की स्वास्थ्य योजना, प्रधानमंत्री '
                  'राष्ट्रीय राहत कोष से इलाज की सहायता, राष्ट्रीय आरोग्य निधि, मुख्यमंत्री '
                  'राहत कोष, और बड़े धर्मार्थ अस्पतालों का ग़रीब मरीज़ कोष। अस्पताल के '
                  'सामाजिक कार्यकर्ता या मेडिकल सोशल वर्कर से पूछें — यह उनका काम है।'
              : 'Before crowdfunding, check these, because none asks for the '
                  'money back: Ayushman Bharat (up to ₹5 lakh, in goal 3), the '
                  'state health scheme, treatment help from the PM\'s National '
                  'Relief Fund, the Rashtriya Arogya Nidhi, the Chief Minister\'s '
                  'relief fund, and the poor-patient fund of large charitable '
                  'hospitals. Ask the hospital\'s medical social worker - it is '
                  'their job.',
          tone: ToolTone.good,
          icon: Icons.local_hospital_outlined,
        ),
        const SizedBox(height: 12),
        Text(hi ? 'चंदा जुटाना हो तो' : 'If you do crowdfund',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'अस्पताल से इलाज के अनुमानित ख़र्च का पत्र और रिपोर्ट लें — दानदाता यही '
                      'देखते हैं।',
                  'ऐसा मंच चुनें जो दस्तावेज़ जाँचता है, और जहाँ से पैसा सीधे अस्पताल को जा '
                      'सके। उसका शुल्क पहले से पढ़ें।',
                  'जुटाई रक़म, ख़र्च और बचत का हिसाब अपडेट में बताते रहें — भरोसा उसी से '
                      'बनता है।',
                ]
              : const [
                  'Get a letter of estimated cost and the reports from the '
                      'hospital - that is what donors look at.',
                  'Choose a platform that checks documents and can pay the '
                      'hospital directly. Read its fees first.',
                  'Keep posting updates on what was raised, spent and left - '
                      'that is what builds trust.',
                ],
        ),
        const SizedBox(height: 12),
        ToolDonts(
          heading: hi ? 'बीमार परिवारों को निशाना बनाने वाली ठगी' : 'Scams that target sick families',
          items: hi
              ? const [
                  '"फ़ंडरेज़र मैनेजर" जो पहले फ़ीस लेकर "लाखों जुटाने की गारंटी" दे',
                  'कोई आपकी अपील की नक़ल बनाकर अपने खाते में पैसा माँगे — अपनी अपील का '
                      'लिंक ही बाँटें, और कहें कि किसी और खाते में न दें',
                  'मरीज़ के काग़ज़ और ओटीपी माँगने वाले "मदद" के फ़ोन',
                  'अस्पताल के बाहर "सस्ते इलाज" या "सरकारी कोटे" का दलाल',
                ]
              : const [
                  'A "fundraiser manager" who takes a fee up front and '
                      '"guarantees lakhs"',
                  'Someone copying your appeal and asking for money into their '
                      'own account - share only your own appeal link, and say '
                      'not to pay any other account',
                  '"Help" calls asking for the patient\'s papers and OTPs',
                  'A tout outside the hospital offering "cheap treatment" or a '
                      '"government quota"',
                ],
        ),
        const SourceNote(text: 'PM National Relief Fund', url: _pmnrfUrl),
      ],
    );
  }
}
