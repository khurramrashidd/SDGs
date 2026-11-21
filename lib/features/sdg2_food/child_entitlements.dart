import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// What the anganwadi and the school kitchen owe a family, in figures.
///
/// Both of these are entitlements with published norms, and both are
/// commonly short-delivered - not out of malice, usually, but because
/// nobody at the receiving end knows what the number is supposed to be. A
/// mother who knows her take-home ration is meant to carry 600 calories
/// and 18 grams of protein a day is in a different position from one who
/// is told "this is what came this month".
///
/// The norms below are the national ones. Some states give more, and none
/// may give less.

const _icdsUrl =
    'https://www.pib.gov.in/newsite/printrelease.aspx?relid=104046&reg=3&lang=2';
const _poshanUrl =
    'https://www.pib.gov.in/PressReleasePage.aspx?PRID=1812421&reg=48&lang=2';
const _poshanTrackerUrl = 'https://www.poshantracker.in/';

/// Who the anganwadi beneficiary is. The norms differ by category, and so
/// does the form the food takes.
enum AnganwadiWho {
  infant,       // 6 months to 3 years
  preschool,    // 3 to 6 years
  underweight,  // severely underweight child
  mother,       // pregnant or nursing
}

/// Calories and protein due per day, with the form the food comes in.
({int kcal, String proteinG, bool takeHome}) anganwadiNorm(AnganwadiWho who) =>
    switch (who) {
      AnganwadiWho.infant => (kcal: 500, proteinG: '12-15', takeHome: true),
      AnganwadiWho.preschool => (kcal: 500, proteinG: '12-15', takeHome: false),
      AnganwadiWho.underweight =>
        (kcal: 800, proteinG: '20-25', takeHome: true),
      AnganwadiWho.mother => (kcal: 600, proteinG: '18-20', takeHome: true),
    };

class AnganwadiPage extends StatefulWidget {
  const AnganwadiPage({super.key});

  @override
  State<AnganwadiPage> createState() => _AnganwadiPageState();
}

class _AnganwadiPageState extends State<AnganwadiPage> {
  AnganwadiWho? _who;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final norm = _who == null ? null : anganwadiNorm(_who!);

    Widget pick(AnganwadiWho w, String en, String h, String sub, String subHi) =>
        SelectionTile(
          label: hi ? h : en,
          subtitle: hi ? subHi : sub,
          selected: _who == w,
          onTap: () => setState(() => _who = w),
        );

    return ToolScaffold(
      goal: 2,
      title: hi ? 'आँगनवाड़ी से क्या मिलना चाहिए' : 'What the anganwadi owes you',
      children: [
        ToolNote(hi
            ? 'आँगनवाड़ी का पोषण हक़ है, दान नहीं — और इसके लिए राशन कार्ड नहीं चाहिए। '
                'हर श्रेणी के लिए कैलोरी और प्रोटीन की तय मात्रा है। जो माँ यह संख्या '
                'जानती है, वह "इस महीने इतना ही आया" सुनकर चुप नहीं रहती।'
            : 'Anganwadi nutrition is an entitlement, not charity - and it '
                'needs no ration card. Every category has a fixed quantity of '
                'calories and protein. A mother who knows that number is in a '
                'different position from one who is told "this is what came '
                'this month".'),
        ToolQuestion(hi ? 'किसके लिए' : 'For whom'),
        pick(AnganwadiWho.infant, 'A child 6 months to 3 years',
            '6 महीने से 3 साल का बच्चा',
            'Take-home ration', 'घर ले जाने वाला राशन'),
        pick(AnganwadiWho.preschool, 'A child 3 to 6 years',
            '3 से 6 साल का बच्चा',
            'Eats at the anganwadi', 'आँगनवाड़ी में खाता है'),
        pick(AnganwadiWho.underweight, 'A severely underweight child',
            'बहुत कमज़ोर (अति-कम वज़न) बच्चा',
            'A higher ration', 'ज़्यादा मात्रा वाला राशन'),
        pick(AnganwadiWho.mother, 'A pregnant woman or nursing mother',
            'गर्भवती या दूध पिलाती माँ',
            'Take-home ration', 'घर ले जाने वाला राशन'),
        if (norm != null) ...[
          ToolAnswer(
            headline: hi
                ? 'हर दिन ${norm.kcal} कैलोरी और ${norm.proteinG} ग्राम प्रोटीन'
                : '${norm.kcal} calories and ${norm.proteinG} g of protein, '
                    'every day',
            detail: norm.takeHome
                ? (hi
                    ? 'यह घर ले जाने वाले राशन (THR) के रूप में मिलता है — आमतौर पर '
                        'महीने में एक या दो बार, पूरे महीने का हिसाब जोड़कर। मात्रा '
                        'रजिस्टर में दर्ज होती है; दर्ज कराकर लें।'
                    : 'This comes as take-home ration - usually once or twice '
                        'a month, adding up to the whole month\'s worth. The '
                        'quantity is entered in a register; make sure it is '
                        'entered when you take it.')
                : (hi
                    ? 'यह आँगनवाड़ी में ही मिलता है: सुबह का नाश्ता (दूध, केला, मौसमी '
                        'फल या पोषण-युक्त आहार) और उसके बाद गरम पका भोजन। इस उम्र में '
                        'यह घर ले जाने वाला राशन नहीं होता — बच्चे को वहाँ भेजना है।'
                    : 'This is given at the anganwadi itself: a morning snack '
                        '(milk, a banana, seasonal fruit or fortified food) '
                        'and then a hot cooked meal. At this age it is not a '
                        'take-home ration - the child has to go there.'),
            tone: ToolTone.good,
            icon: Icons.restaurant_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'सारी श्रेणियाँ' : 'All the categories',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ToolLine(hi ? '6 महीने - 3 साल' : '6 months - 3 years',
              hi ? '500 कैलोरी, 12-15 ग्राम' : '500 kcal, 12-15 g',
              strong: _who == AnganwadiWho.infant),
          ToolLine(hi ? '3 - 6 साल' : '3 - 6 years',
              hi ? '500 कैलोरी, 12-15 ग्राम' : '500 kcal, 12-15 g',
              strong: _who == AnganwadiWho.preschool),
          ToolLine(hi ? 'अति-कम वज़न वाला बच्चा' : 'Severely underweight child',
              hi ? '800 कैलोरी, 20-25 ग्राम' : '800 kcal, 20-25 g',
              strong: _who == AnganwadiWho.underweight),
          ToolLine(hi ? 'गर्भवती और दूध पिलाती माँ' : 'Pregnant and nursing mothers',
              hi ? '600 कैलोरी, 18-20 ग्राम' : '600 kcal, 18-20 g',
              strong: _who == AnganwadiWho.mother),
          const SizedBox(height: 14),
          Text(hi ? 'आँगनवाड़ी यह भी देती है' : 'The anganwadi also gives',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            numbered: false,
            steps: hi
                ? const [
                    'हर महीने बच्चे का वज़न और लंबाई, और वृद्धि चार्ट में दर्ज करना',
                    'टीकाकरण और उसका रिकॉर्ड',
                    '3 से 6 साल के बच्चों की स्कूल-पूर्व पढ़ाई',
                    'गर्भवती माँ की जाँच और आयरन की गोलियाँ',
                    'कमज़ोर बच्चों की पहचान और ज़रूरत पड़ने पर पोषण पुनर्वास केंद्र भेजना',
                  ]
                : const [
                    'Monthly weight and height, recorded on the growth chart',
                    'Immunisation, and the record of it',
                    'Pre-school learning for children aged 3 to 6',
                    'Antenatal check-ups and iron tablets for mothers',
                    'Spotting malnourished children and referring them to a '
                        'nutrition rehabilitation centre when needed',
                  ],
          ),
          ToolAnswer(
            headline: hi ? 'कम मिले या न मिले तो' : 'If it is short, or not given',
            detail: hi
                ? 'पहले आँगनवाड़ी कार्यकर्ता से रजिस्टर देखने को कहें — दर्ज क्या है और '
                    'मिला क्या, यही पूरी बात है। फिर पर्यवेक्षक (सुपरवाइज़र), फिर बाल '
                    'विकास परियोजना अधिकारी (सीडीपीओ), फिर ज़िला कार्यक्रम अधिकारी। '
                    'पोषण ट्रैकर में हर वितरण दर्ज होता है, इसलिए रिकॉर्ड मौजूद है और '
                    'उसकी नक़ल माँगी जा सकती है।'
                : 'First ask the anganwadi worker to show the register - what '
                    'is recorded against what was given is the whole '
                    'question. Then the supervisor, then the Child '
                    'Development Project Officer (CDPO), then the district '
                    'programme officer. Every distribution is entered on the '
                    'Poshan Tracker, so a record exists and a copy of it can '
                    'be asked for.',
            tone: ToolTone.warn,
            icon: Icons.report_outlined,
          ),
          const SourceNote(
              text: 'ICDS supplementary nutrition norms, Ministry of Women '
                  'and Child Development',
              url: _icdsUrl),
          const SourceNote(text: 'Poshan Tracker', url: _poshanTrackerUrl),
        ],
      ],
    );
  }
}

// --- Midday meal ------------------------------------------------------

/// Which class the child is in. Primary and upper primary have different
/// published norms, and the grain quantity is the one a parent can check.
enum MealClass { primary, upperPrimary }

({int grainG, int kcal, int proteinG}) poshanNorm(MealClass c) => switch (c) {
      MealClass.primary => (grainG: 100, kcal: 450, proteinG: 12),
      MealClass.upperPrimary => (grainG: 150, kcal: 700, proteinG: 20),
    };

/// What is wrong with the meal. The complaint goes to a different place
/// depending on whether it is absent, short, or unsafe.
enum MealProblem { notServed, tooLittle, badFood, noEggsOrMilk, discrimination }

class MiddayMealPage extends StatefulWidget {
  const MiddayMealPage({super.key});

  @override
  State<MiddayMealPage> createState() => _MiddayMealPageState();
}

class _MiddayMealPageState extends State<MiddayMealPage> {
  MealClass _class = MealClass.primary;
  MealProblem? _problem;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final norm = poshanNorm(_class);

    Widget problem(MealProblem p, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _problem == p,
          onTap: () => setState(() => _problem = p),
        );

    return ToolScaffold(
      goal: 2,
      title: hi ? 'मध्याह्न भोजन में गड़बड़ी' : 'A problem with the midday meal',
      children: [
        ToolNote(hi
            ? 'पीएम पोषण के तहत सरकारी और सरकारी-सहायता प्राप्त स्कूलों में बाल वाटिका '
                'से आठवीं तक हर बच्चे को हर स्कूल-दिन पका हुआ भोजन मिलना है। मात्रा '
                'तय है — नीचे देखें। यह सहूलियत नहीं, हक़ है।'
            : 'Under PM POSHAN every child from Bal Vatika to class 8 in a '
                'government or government-aided school gets a cooked meal '
                'every school day. The quantity is fixed - it is below. This '
                'is an entitlement, not a favour.'),
        ToolQuestion(hi ? 'बच्चा किस कक्षा में है' : 'Which class is the child in'),
        SelectionTile(
          label: hi ? 'कक्षा 1 से 5 (प्राथमिक)' : 'Classes 1 to 5 (primary)',
          selected: _class == MealClass.primary,
          onTap: () => setState(() => _class = MealClass.primary),
        ),
        SelectionTile(
          label: hi
              ? 'कक्षा 6 से 8 (उच्च प्राथमिक)'
              : 'Classes 6 to 8 (upper primary)',
          selected: _class == MealClass.upperPrimary,
          onTap: () => setState(() => _class = MealClass.upperPrimary),
        ),
        ToolAnswer(
          headline: hi
              ? 'हर स्कूल-दिन: ${norm.grainG} ग्राम अनाज'
              : 'Every school day: ${norm.grainG} g of foodgrain',
          detail: hi
              ? 'और भोजन में कम से कम ${norm.kcal} कैलोरी और ${norm.proteinG} ग्राम '
                  'प्रोटीन होना चाहिए। अनाज के साथ दाल, सब्ज़ी और तेल का हिसाब भी तय '
                  'होता है, और कई राज्य अंडा, दूध या फल भी देते हैं।'
              : 'and the meal must carry at least ${norm.kcal} calories and '
                  '${norm.proteinG} g of protein. The dal, vegetables and oil '
                  'that go with the grain are also fixed, and many states add '
                  'an egg, milk or fruit.',
          tone: ToolTone.plain,
          icon: Icons.rice_bowl_outlined,
        ),
        const SizedBox(height: 14),
        ToolQuestion(hi ? 'क्या गड़बड़ है' : 'What is wrong'),
        problem(MealProblem.notServed, 'The meal is not served at all, or '
            'only some days', 'भोजन मिलता ही नहीं, या कुछ दिन ही मिलता है'),
        problem(MealProblem.tooLittle, 'The quantity is much less than this',
            'मात्रा इससे बहुत कम है'),
        problem(MealProblem.badFood,
            'The food is stale, dirty, or made children ill',
            'खाना बासी या गंदा है, या बच्चे बीमार पड़े'),
        problem(MealProblem.noEggsOrMilk,
            'What the state promised - egg, milk, fruit - never comes',
            'राज्य ने जो कहा था — अंडा, दूध, फल — वह नहीं आता'),
        problem(MealProblem.discrimination,
            'Some children are made to sit apart, or served last',
            'कुछ बच्चों को अलग बिठाया जाता है, या सबसे बाद में परोसा जाता है'),
        if (_problem != null) ...[
          if (_problem == MealProblem.badFood)
            ToolAnswer(
              headline: hi
                  ? 'बच्चे बीमार हुए हों तो पहले अस्पताल'
                  : 'If children fell ill, hospital first',
              detail: hi
                  ? 'पहले इलाज, फिर शिकायत। अगर हो सके तो उस खाने का थोड़ा हिस्सा '
                      'अलग रख दें — जाँच में वही काम आता है। फिर प्रधानाध्यापक, '
                      'खंड शिक्षा अधिकारी और ज़िला अधिकारी, तीनों को उसी दिन लिखित में '
                      'बताएँ।'
                  : 'Treatment first, complaint after. If you can, set aside a '
                      'little of that food - it is what a test needs. Then '
                      'tell the head teacher, the block education officer and '
                      'the district officer in writing the same day, all '
                      'three.',
              tone: ToolTone.bad,
              icon: Icons.priority_high,
            ),
          if (_problem == MealProblem.discrimination)
            ToolAnswer(
              headline: hi
                  ? 'यह क़ानूनन मना है'
                  : 'This is forbidden by law',
              detail: hi
                  ? 'जाति, धर्म या किसी भी आधार पर बच्चों को अलग बिठाना या बाद में '
                      'परोसना योजना के नियमों के ख़िलाफ़ है, और छुआछूत से जुड़े क़ानून के '
                      'भी। इसे स्कूल के भीतर सुलझने का इंतज़ार न करें — सीधे खंड शिक्षा '
                      'अधिकारी और ज़िला अधिकारी को लिखें, और ज़रूरत पड़े तो अनुसूचित '
                      'जाति/जनजाति आयोग को।'
                  : 'Seating children apart or serving them last, on caste, '
                      'religion or any other ground, is against the scheme\'s '
                      'own rules and against the law on untouchability. Do '
                      'not wait for this to settle inside the school - write '
                      'straight to the block education officer and the '
                      'district officer, and if needed to the SC/ST '
                      'commission.',
              tone: ToolTone.bad,
              icon: Icons.gavel_outlined,
            ),
          const SizedBox(height: 10),
          Text(hi ? 'शिकायत इस क्रम में' : 'Complain in this order',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'स्कूल प्रबंधन समिति (SMC) की बैठक में बात उठाएँ — उसमें अभिभावक '
                        'सदस्य होते हैं और कार्यवाही लिखी जाती है। माँगें कि आपकी बात '
                        'दर्ज हो।',
                    'प्रधानाध्यापक को लिखित में दें, और पावती लें।',
                    'खंड शिक्षा अधिकारी (BEO) को लिखें।',
                    'ज़िला शिक्षा अधिकारी और ज़िला मध्याह्न भोजन प्रभारी को लिखें।',
                    'राज्य की पीएम पोषण हेल्पलाइन या शिक्षा विभाग के शिकायत पोर्टल पर '
                        'दर्ज कराएँ, और संख्या रखें।',
                  ]
                : const [
                    'Raise it in the School Management Committee meeting - it '
                        'has parent members and its proceedings are written '
                        'down. Ask for your point to be recorded.',
                    'Give it to the head teacher in writing, and take an '
                        'acknowledgement.',
                    'Write to the Block Education Officer.',
                    'Write to the District Education Officer and the '
                        'district midday meal in-charge.',
                    'Register it on the state PM POSHAN helpline or the '
                        'education department\'s grievance portal, and keep '
                        'the number.',
                  ],
          ),
          const SizedBox(height: 10),
          ToolNote(hi
              ? 'एक बात जो शिकायत को असरदार बनाती है: तारीख़ों की सूची। किस-किस दिन '
                  'भोजन नहीं मिला, यह बच्चे से पूछकर रोज़ लिखते रहें। "कई दिन नहीं मिला" '
                  'की जगह "12, 13, 16 और 19 तारीख़ को नहीं मिला" लिखी शिकायत का जवाब '
                  'देना पड़ता है।'
              : 'One thing makes these complaints work: a list of dates. Ask '
                  'the child each day and write down which days the meal was '
                  'not given. A complaint saying "not given on the 12th, '
                  '13th, 16th and 19th" has to be answered; one saying "not '
                  'given on many days" does not.'),
          const SourceNote(
              text: 'PM POSHAN norms, Ministry of Education', url: _poshanUrl),
        ],
      ],
    );
  }
}
