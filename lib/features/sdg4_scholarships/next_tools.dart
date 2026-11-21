import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Three screens for the forks: after dropping out, after class 10, and
/// after class 12.
///
/// None of these tells anyone what to be. What they do is make the options
/// visible, because the commonest reason a village student takes a wrong
/// turn is not bad judgement - it is that only two or three of the roads
/// were ever described to them, usually by somebody selling one of them.
///
/// Deliberately no dates with years in them. Entrance exam calendars shift
/// every session, and a wrong date here means a missed form, which is the
/// one mistake that cannot be undone. Months and official sites only.

const _niosUrl = 'https://www.nios.ac.in/';
const _ncvtUrl = 'https://www.dgt.gov.in/';
const _skillIndiaUrl = 'https://www.skillindiadigital.gov.in/';
const _ntaUrl = 'https://www.nta.ac.in/';
const _cuetUrl = 'https://cuet.nta.nic.in/';

// --- Dropped out ------------------------------------------------------

/// Where the student stopped. Each has a different way back, and in every
/// case the way back exists.
enum DropPoint { beforeTen, afterTenNotTwelve, afterTwelve }

class DroppedOutPage extends StatefulWidget {
  const DroppedOutPage({super.key});

  @override
  State<DroppedOutPage> createState() => _DroppedOutPageState();
}

class _DroppedOutPageState extends State<DroppedOutPage> {
  DropPoint? _point;
  final _age = TextEditingController();
  bool _needsToEarn = false;

  @override
  void dispose() {
    _age.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final age = int.tryParse(_age.text.trim());
    final oldEnoughForNios = age == null || age >= 14;

    Widget pick(DropPoint p, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _point == p,
          onTap: () => setState(() => _point = p),
        );

    return ToolScaffold(
      goal: 4,
      title: hi ? 'पढ़ाई छूट गई: वापसी के रास्ते' : 'Dropped out: the ways back',
      children: [
        ToolNote(hi
            ? 'पढ़ाई छूटना रास्ता बंद होना नहीं है। खुला विद्यालय इसी के लिए बना है — '
                'उम्र की ऊपरी सीमा नहीं, रोज़ स्कूल जाना ज़रूरी नहीं, और जो परीक्षा पास '
                'करते हैं उनका प्रमाण पत्र किसी भी बोर्ड जितना ही मान्य होता है। बहुत '
                'लोग तीस-चालीस की उम्र में दसवीं करते हैं।'
            : 'Stopping is not the road closing. Open schooling exists '
                'exactly for this - no upper age limit, no need to attend '
                'daily, and a certificate that counts the same as any '
                'board\'s. Plenty of people pass class 10 in their thirties '
                'and forties.'),
        ToolQuestion(hi ? 'पढ़ाई कहाँ छूटी' : 'Where did it stop'),
        pick(DropPoint.beforeTen, 'Before class 10', 'कक्षा 10 से पहले'),
        pick(DropPoint.afterTenNotTwelve,
            'Passed class 10, did not finish class 12',
            'कक्षा 10 पास, 12 पूरी नहीं'),
        pick(DropPoint.afterTwelve, 'Passed class 12, stopped after that',
            'कक्षा 12 पास, उसके बाद छूट गई'),
        if (_point != null) ...[
          ToolQuestion(hi ? 'उम्र' : 'Age'),
          ToolNumber(
            controller: _age,
            label: hi ? 'साल' : 'Years',
            maxDigits: 2,
            icon: Icons.person_outline,
            onChanged: (_) => setState(() {}),
          ),
          SwitchListTile(
            value: _needsToEarn,
            contentPadding: EdgeInsets.zero,
            title: Text(hi
                ? 'कमाना भी ज़रूरी है, पढ़ाई के साथ'
                : 'Earning is necessary alongside studying'),
            onChanged: (v) => setState(() => _needsToEarn = v),
          ),
          if (!oldEnoughForNios)
            ToolAnswer(
              headline: hi
                  ? 'इस उम्र में स्कूल में दाख़िला हक़ है'
                  : 'At this age, school admission is a right',
              detail: hi
                  ? '14 साल तक की उम्र में शिक्षा का अधिकार क़ानून लागू होता है: बच्चे '
                      'को उसकी उम्र के हिसाब से कक्षा में दाख़िला मिलना है, और पीछे की '
                      'पढ़ाई पूरी कराने के लिए विशेष प्रशिक्षण भी। स्कूल मना नहीं कर '
                      'सकता, और बीच सत्र में भी दाख़िला देना होता है। इसी लक्ष्य में '
                      '"स्कूल ने दाख़िला रोका" देखें।'
                  : 'Up to 14 the Right to Education Act applies: the child '
                      'must be admitted to the class matching their age, with '
                      'special training to catch up. A school cannot refuse, '
                      'and must admit mid-session too. See "The school '
                      'refused admission" in this goal.',
              tone: ToolTone.good,
              icon: Icons.school_outlined,
            )
          else ...[
            ToolAnswer(
              headline: switch (_point!) {
                DropPoint.beforeTen => hi
                    ? 'खुले विद्यालय से सीधे दसवीं'
                    : 'Class 10 straight through open schooling',
                DropPoint.afterTenNotTwelve => hi
                    ? 'बारहवीं खुले विद्यालय से पूरी करें'
                    : 'Finish class 12 through open schooling',
                DropPoint.afterTwelve => hi
                    ? 'मुक्त विश्वविद्यालय या कौशल पाठ्यक्रम'
                    : 'An open university, or a skill course',
              },
              detail: switch (_point!) {
                DropPoint.beforeTen => hi
                    ? 'राष्ट्रीय मुक्त विद्यालयी शिक्षा संस्थान (NIOS) में माध्यमिक '
                        '(दसवीं) में दाख़िले के लिए कम से कम 14 साल का होना ज़रूरी है, '
                        'और कोई ऊपरी सीमा नहीं। आठवीं का प्रमाण पत्र न हो तो स्व-घोषणा '
                        'से भी दाख़िला होता है। कई राज्यों के अपने मुक्त विद्यालय भी हैं, '
                        'जो सस्ते पड़ते हैं।'
                    : 'For secondary (class 10) at the National Institute of '
                        'Open Schooling the only bar is being at least 14, '
                        'with no upper limit. Where there is no class 8 '
                        'certificate, admission is possible on a '
                        'self-declaration. Several states run their own open '
                        'schools, which cost less.',
                DropPoint.afterTenNotTwelve => hi
                    ? 'दसवीं पास हैं तो NIOS में वरिष्ठ माध्यमिक (बारहवीं) में सीधे '
                        'दाख़िला हो जाता है। एक बड़ी सहूलियत: पहले जो विषय पास कर चुके '
                        'हैं, उनके अंक पाँच साल तक जोड़े जा सकते हैं — पूरी कक्षा दोबारा '
                        'नहीं करनी पड़ती। सिर्फ़ छूटे विषय देने होते हैं।'
                    : 'With class 10 passed, admission to senior secondary '
                        '(class 12) at NIOS is direct. One big convenience: '
                        'subjects already passed can be carried over for five '
                        'years - the whole class does not have to be redone. '
                        'Only the subjects left are taken.',
                DropPoint.afterTwelve => hi
                    ? 'इंदिरा गांधी राष्ट्रीय मुक्त विश्वविद्यालय (IGNOU) और राज्यों के '
                        'मुक्त विश्वविद्यालयों में स्नातक और स्नातकोत्तर दोनों होते हैं, '
                        'बिना रोज़ कॉलेज जाने। फ़ीस नियमित कॉलेज से कम होती है, और '
                        'अनुसूचित जाति/जनजाति छात्रों के लिए कई पाठ्यक्रमों में माफ़ है।'
                    : 'The Indira Gandhi National Open University and the '
                        'state open universities run both degrees and '
                        'postgraduate courses without daily attendance. The '
                        'fees are lower than a regular college, and are '
                        'waived in many courses for Scheduled Caste and '
                        'Scheduled Tribe students.',
              },
              tone: ToolTone.good,
              icon: Icons.menu_book_outlined,
            ),
            if (_needsToEarn)
              ToolAnswer(
                headline: hi
                    ? 'कमाते हुए पढ़ने का रास्ता'
                    : 'The route that pays while you learn',
                detail: hi
                    ? 'आईटीआई और अप्रेंटिसशिप इसी के लिए हैं: अप्रेंटिसशिप में काम '
                        'सीखते हुए हर महीने वज़ीफ़ा मिलता है, और आख़िर में राष्ट्रीय स्तर '
                        'पर मान्य प्रमाण पत्र। खुले विद्यालय से पढ़ाई साथ-साथ चल सकती है, '
                        'क्योंकि रोज़ जाना ज़रूरी नहीं। यह दोनों एक साथ करने वाला रास्ता '
                        'है, और सबसे कम बताया जाने वाला भी।'
                    : 'ITIs and apprenticeships are built for this: an '
                        'apprenticeship pays a monthly stipend while you '
                        'learn the trade, and ends in a nationally recognised '
                        'certificate. Open schooling can run alongside it, '
                        'because attendance is not required. It is the route '
                        'that does both at once, and the one least often '
                        'mentioned.',
                tone: ToolTone.plain,
                icon: Icons.handyman_outlined,
              ),
            const SizedBox(height: 14),
            Text(hi ? 'दाख़िले के क़दम' : 'How to enrol',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800)),
            ToolSteps(
              steps: hi
                  ? const [
                      'NIOS की वेबसाइट पर ऑनलाइन दाख़िला होता है, या किसी भी मान्यता '
                          'प्राप्त अध्ययन केंद्र पर — वह आमतौर पर पास का कोई सरकारी '
                          'स्कूल ही होता है।',
                      'दाख़िले की खिड़की साल में दो बार खुलती है, और परीक्षाएँ भी साल '
                          'में दो बार होती हैं। खिड़की की तारीख़ वेबसाइट पर देखें।',
                      'आधार, पिछली कक्षा का प्रमाण पत्र (जो हो), फ़ोटो और फ़ीस चाहिए।',
                      'अध्ययन केंद्र पर हफ़्ते के अंत में कक्षाएँ लगती हैं — मुफ़्त होती '
                          'हैं, जा सकें तो जाएँ।',
                      'एक परीक्षा में पास न हों तो सिर्फ़ वही विषय दोबारा देना होता है, '
                          'और नौ मौक़े मिलते हैं।',
                    ]
                  : const [
                      'Enrolment is online on the NIOS website, or at any '
                          'accredited study centre - usually a government '
                          'school nearby.',
                      'The admission window opens twice a year, and the '
                          'exams are held twice a year too. Check the dates '
                          'on the website.',
                      'You need Aadhaar, the last certificate you have (if '
                          'any), a photograph and the fee.',
                      'Study centres hold weekend classes - they are free, '
                          'and worth going to if you can.',
                      'Failing one exam means retaking that subject only, '
                          'and there are nine chances.',
                    ],
            ),
            const SourceNote(
                text: 'National Institute of Open Schooling', url: _niosUrl),
            if (_needsToEarn)
              const SourceNote(
                  text: 'Skill India Digital - apprenticeships and courses',
                  url: _skillIndiaUrl),
          ],
        ],
      ],
    );
  }
}

// --- After class 10 ---------------------------------------------------

/// What the student is weighing. The answer is a shortlist, never one
/// option, because a single recommendation from an app is worth nothing
/// against a family's actual circumstances.
enum StreamLean { maths, biology, business, language, hands }

class AfterTenPage extends StatefulWidget {
  const AfterTenPage({super.key});

  @override
  State<AfterTenPage> createState() => _AfterTenPageState();
}

class _AfterTenPageState extends State<AfterTenPage> {
  final Set<StreamLean> _leans = {};
  bool _earnSoon = false;

  /// Streams worth putting in front of this student, most apt first.
  List<({String en, String hi, String whyEn, String whyHi})> _shortlist() {
    final out = <({String en, String hi, String whyEn, String whyHi})>[];
    if (_leans.contains(StreamLean.maths)) {
      out.add((
        en: 'Science with maths (PCM)',
        hi: 'विज्ञान, गणित के साथ (PCM)',
        whyEn: 'Opens engineering, architecture, the defence academies, '
            'B.Sc and most competitive technical exams. It is the stream '
            'that closes fewest doors, and the one that needs the most '
            'daily practice.',
        whyHi: 'इंजीनियरिंग, आर्किटेक्चर, रक्षा अकादमियाँ, बीएससी और ज़्यादातर तकनीकी '
            'प्रतियोगी परीक्षाएँ — सब खुलती हैं। यह सबसे कम दरवाज़े बंद करने वाली धारा '
            'है, और रोज़ अभ्यास सबसे ज़्यादा माँगने वाली भी।',
      ));
    }
    if (_leans.contains(StreamLean.biology)) {
      out.add((
        en: 'Science with biology (PCB)',
        hi: 'विज्ञान, जीव विज्ञान के साथ (PCB)',
        whyEn: 'The route to MBBS, BDS, nursing, pharmacy, agriculture, '
            'veterinary science and B.Sc. Nursing and pharmacy are worth '
            'knowing about: they take far fewer years and far less money '
            'than MBBS, and the jobs are everywhere.',
        whyHi: 'एमबीबीएस, बीडीएस, नर्सिंग, फ़ार्मेसी, कृषि, पशु चिकित्सा और बीएससी का '
            'रास्ता। नर्सिंग और फ़ार्मेसी जानने लायक़ हैं: इनमें एमबीबीएस से कहीं कम साल '
            'और कहीं कम पैसा लगता है, और नौकरी हर जगह है।',
      ));
    }
    if (_leans.contains(StreamLean.business)) {
      out.add((
        en: 'Commerce',
        hi: 'वाणिज्य (कॉमर्स)',
        whyEn: 'Leads to B.Com, CA, CS, cost accountancy, banking and '
            'business. It is also the stream that most directly suits '
            'someone who will one day run the family shop or trade, and '
            'bank exams take graduates of any stream.',
        whyHi: 'बीकॉम, सीए, सीएस, लागत लेखा, बैंकिंग और व्यापार का रास्ता। जो आगे घर '
            'की दुकान या व्यापार सँभालेगा, उसके लिए यह सबसे सीधी धारा है — और बैंक '
            'की परीक्षाओं में किसी भी धारा के स्नातक बैठ सकते हैं।',
      ));
    }
    if (_leans.contains(StreamLean.language)) {
      out.add((
        en: 'Arts or humanities',
        hi: 'कला (आर्ट्स)',
        whyEn: 'The stream most unfairly spoken of. It is the direct road '
            'to teaching, law, journalism, social work and - importantly - '
            'the civil services and most state administrative exams, which '
            'take graduates of any stream but test exactly what this stream '
            'teaches.',
        whyHi: 'इस धारा के बारे में सबसे ग़लत बातें कही जाती हैं। यह अध्यापन, क़ानून, '
            'पत्रकारिता, समाज कार्य और — यह ख़ास बात है — सिविल सेवा और ज़्यादातर '
            'राज्य प्रशासनिक परीक्षाओं का सीधा रास्ता है, जिनमें किसी भी धारा के '
            'स्नातक बैठ सकते हैं लेकिन पूछा वही जाता है जो यह धारा पढ़ाती है।',
      ));
    }
    if (_leans.contains(StreamLean.hands) || _earnSoon) {
      out.add((
        en: 'ITI or a polytechnic diploma',
        hi: 'आईटीआई या पॉलिटेक्निक डिप्लोमा',
        whyEn: 'One to three years, low fees, and a trade at the end of it - '
            'electrician, fitter, welder, motor mechanic, computer operator. '
            'A diploma also allows lateral entry into the second year of an '
            'engineering degree later, so this is not a dead end; it is the '
            'cheapest way into the same place.',
        whyHi: 'एक से तीन साल, कम फ़ीस, और अंत में एक हुनर — इलेक्ट्रिशियन, फ़िटर, '
            'वेल्डर, मोटर मैकेनिक, कंप्यूटर ऑपरेटर। डिप्लोमा के बाद आगे इंजीनियरिंग के '
            'दूसरे साल में सीधे दाख़िला (लेटरल एंट्री) भी मिलता है, इसलिए यह बंद गली '
            'नहीं है — उसी जगह पहुँचने का सबसे सस्ता रास्ता है।',
      ));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final list = _shortlist();

    Widget lean(StreamLean l, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _leans.contains(l),
          onTap: () => setState(() {
            if (!_leans.remove(l)) _leans.add(l);
          }),
        );

    return ToolScaffold(
      goal: 4,
      title: hi ? 'दसवीं के बाद: कौन सी धारा' : 'After class 10: which stream',
      children: [
        ToolNote(hi
            ? 'यह स्क्रीन यह नहीं बताएगी कि आपको क्या बनना चाहिए — वह आपका और आपके '
                'घर का फ़ैसला है। यह सिर्फ़ यह करती है कि रास्ते सामने रख दे, क्योंकि '
                'ग़लत मोड़ आमतौर पर ख़राब फ़ैसले से नहीं आता, बल्कि इससे आता है कि '
                'पाँच रास्तों में से दो ही किसी ने बताए थे।'
            : 'This screen will not tell you what to become - that is yours '
                'and your family\'s to decide. All it does is put the roads '
                'in front of you, because a wrong turn usually comes not from '
                'bad judgement but from only two of the five roads ever '
                'having been described.'),
        ToolQuestion(hi
            ? 'कौन से विषय में मन लगता है? (एक से ज़्यादा चुन सकते हैं)'
            : 'Which of these holds your interest? (pick as many as apply)'),
        lean(StreamLean.maths, 'Maths, and figuring out how things work',
            'गणित, और चीज़ें कैसे काम करती हैं यह समझना'),
        lean(StreamLean.biology, 'Plants, animals, the body, medicine',
            'पेड़-पौधे, जानवर, शरीर, दवा'),
        lean(StreamLean.business, 'Accounts, money, buying and selling',
            'हिसाब, पैसा, ख़रीद-बिक्री'),
        lean(StreamLean.language, 'Reading, writing, history, people, society',
            'पढ़ना, लिखना, इतिहास, लोग, समाज'),
        lean(StreamLean.hands, 'Making and repairing things with my hands',
            'हाथ से चीज़ें बनाना और ठीक करना'),
        SwitchListTile(
          value: _earnSoon,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'दो-तीन साल में कमाना शुरू करना ज़रूरी है'
              : 'Earning needs to start within two or three years'),
          onChanged: (v) => setState(() => _earnSoon = v),
        ),
        if (list.isNotEmpty) ...[
          ToolAnswer(
            headline: hi
                ? 'देखने लायक़ ${list.length} रास्ते'
                : '${list.length} roads worth looking at',
            detail: hi
                ? 'इनमें से किसी एक का नाम लेकर अपने स्कूल के शिक्षक से बात करें, और '
                    'उस धारा में पढ़े किसी एक व्यक्ति से भी — अपने गाँव या रिश्ते में कोई '
                    'मिल जाएगा। जो बात ऐप नहीं बता सकता, वह उन्हीं से पता चलती है।'
                : 'Take one of these by name to a teacher at your school, and '
                    'to one person who actually studied it - there will be '
                    'someone in your village or family. What an app cannot '
                    'tell you is exactly what they can.',
            tone: ToolTone.plain,
            icon: Icons.alt_route_outlined,
          ),
          for (final s in list) ...[
            const SizedBox(height: 14),
            Text(hi ? s.hi : s.en,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ToolNote(hi ? s.whyHi : s.whyEn),
          ],
          const SizedBox(height: 16),
          ToolAnswer(
            headline: hi
                ? 'दो बातें जो कोई नहीं बताता'
                : 'Two things nobody mentions',
            detail: hi
                ? 'पहली: धारा बदली जा सकती है। बारहवीं के बाद कई स्नातक पाठ्यक्रम '
                    'किसी भी धारा वालों को लेते हैं, और बैंक, रेलवे, पुलिस और सिविल सेवा '
                    'की परीक्षाओं में धारा नहीं देखी जाती। दसवीं का फ़ैसला पूरी ज़िंदगी '
                    'का फ़ैसला नहीं है। दूसरी: जो धारा गाँव में सबसे "बड़ी" मानी जाती है '
                    'और जो आपके लिए सबसे ठीक है — ये एक ही नहीं होतीं, और दूसरी वाली '
                    'ही टिकती है।'
                : 'First: a stream can be changed. After class 12 many degree '
                    'courses take students of any stream, and the bank, '
                    'railway, police and civil service exams do not look at '
                    'it at all. The decision at class 10 is not a decision '
                    'for life. Second: the stream the village thinks is the '
                    '"biggest" and the one that actually suits you are not '
                    'the same thing, and it is the second that lasts.',
            tone: ToolTone.good,
            icon: Icons.lightbulb_outline,
          ),
          const SourceNote(
              text: 'Directorate General of Training - ITI trades',
              url: _ncvtUrl),
        ],
      ],
    );
  }
}

// --- After class 12 ---------------------------------------------------

/// What the student wants to go towards. The exams are grouped by that
/// rather than by name, because a student who does not already know the
/// names cannot look them up.
enum ExamField {
  engineering,
  medical,
  generalDegree,
  law,
  defence,
  agriculture,
  teaching,
  design,
}

class AfterTwelvePage extends StatefulWidget {
  const AfterTwelvePage({super.key});

  @override
  State<AfterTwelvePage> createState() => _AfterTwelvePageState();
}

class _AfterTwelvePageState extends State<AfterTwelvePage> {
  ExamField? _field;

  /// Exam names and the months their forms usually open. Months only - no
  /// years, no dates, because those move every session.
  List<({String name, String whenEn, String whenHi})> _exams(ExamField f) =>
      switch (f) {
        ExamField.engineering => const [
            (
              name: 'JEE Main',
              whenEn: 'Forms usually open in November and again in April; two '
                  'sessions a year',
              whenHi: 'फ़ॉर्म आमतौर पर नवंबर में और फिर अप्रैल में; साल में दो सत्र'
            ),
            (
              name: 'JEE Advanced',
              whenEn: 'For those who clear JEE Main; around May',
              whenHi: 'जो JEE Main पास करते हैं उनके लिए; लगभग मई में'
            ),
            (
              name: 'Your state engineering entrance',
              whenEn: 'Most states hold their own; forms around February to '
                  'April',
              whenHi: 'ज़्यादातर राज्य अपनी परीक्षा कराते हैं; फ़ॉर्म लगभग फ़रवरी से '
                  'अप्रैल'
            ),
            (
              name: 'Polytechnic diploma entrance',
              whenEn: 'State-level, around April to June - the cheaper route '
                  'to the same field',
              whenHi: 'राज्य स्तर पर, लगभग अप्रैल से जून — उसी क्षेत्र का सस्ता रास्ता'
            ),
          ],
        ExamField.medical => const [
            (
              name: 'NEET UG',
              whenEn: 'The single entrance for MBBS, BDS, AYUSH, veterinary '
                  'and nursing in many colleges; forms around February, exam '
                  'around May',
              whenHi: 'एमबीबीएस, बीडीएस, आयुष, पशु चिकित्सा और कई कॉलेजों में '
                  'नर्सिंग की एक ही परीक्षा; फ़ॉर्म लगभग फ़रवरी, परीक्षा लगभग मई'
            ),
            (
              name: 'Nursing and paramedical entrances',
              whenEn: 'State-level, around April to July. Far shorter and '
                  'cheaper than MBBS, and in demand everywhere',
              whenHi: 'राज्य स्तर पर, लगभग अप्रैल से जुलाई। एमबीबीएस से बहुत छोटा '
                  'और सस्ता, और माँग हर जगह'
            ),
            (
              name: 'B.Pharm entrances',
              whenEn: 'State-level or through the college; around May to July',
              whenHi: 'राज्य स्तर पर या कॉलेज से; लगभग मई से जुलाई'
            ),
          ],
        ExamField.generalDegree => const [
            (
              name: 'CUET UG',
              whenEn: 'One exam for admission to central and many state '
                  'universities - B.A., B.Sc., B.Com. Forms around February '
                  'to March',
              whenHi: 'केंद्रीय और कई राज्य विश्वविद्यालयों में बीए, बीएससी, बीकॉम के '
                  'दाख़िले की एक परीक्षा। फ़ॉर्म लगभग फ़रवरी से मार्च'
            ),
            (
              name: 'Your state university admissions',
              whenEn: 'Many still admit on class 12 marks alone, no exam; '
                  'around May to July',
              whenHi: 'कई जगह अब भी सिर्फ़ बारहवीं के अंकों पर दाख़िला होता है, '
                  'परीक्षा नहीं; लगभग मई से जुलाई'
            ),
            (
              name: 'Open university enrolment',
              whenEn: 'IGNOU and the state open universities admit twice a '
                  'year, with no entrance exam',
              whenHi: 'इग्नू और राज्य के मुक्त विश्वविद्यालय साल में दो बार दाख़िला '
                  'लेते हैं, बिना प्रवेश परीक्षा'
            ),
          ],
        ExamField.law => const [
            (
              name: 'CLAT',
              whenEn: 'For the five-year integrated law degree at the '
                  'national law universities; forms around July to November',
              whenHi: 'राष्ट्रीय विधि विश्वविद्यालयों में पाँच साल की एकीकृत विधि '
                  'डिग्री के लिए; फ़ॉर्म लगभग जुलाई से नवंबर'
            ),
            (
              name: 'Your state law entrance, or CUET',
              whenEn: 'Most state universities take the five-year course '
                  'through their own test or CUET; around February to May',
              whenHi: 'ज़्यादातर राज्य विश्वविद्यालय पाँच साल का कोर्स अपनी परीक्षा या '
                  'CUET से लेते हैं; लगभग फ़रवरी से मई'
            ),
          ],
        ExamField.defence => const [
            (
              name: 'NDA (National Defence Academy)',
              whenEn: 'Twice a year, for class 12 passed; forms around '
                  'December and May',
              whenHi: 'साल में दो बार, बारहवीं पास के लिए; फ़ॉर्म लगभग दिसंबर और मई'
            ),
            (
              name: 'Agniveer and the service recruitments',
              whenEn: 'Army, Navy and Air Force recruit through the year; '
                  'watch the official recruitment sites',
              whenHi: 'सेना, नौसेना और वायुसेना साल भर भर्ती करती हैं; आधिकारिक '
                  'भर्ती वेबसाइटें देखते रहें'
            ),
            (
              name: 'Police and paramilitary constable exams',
              whenEn: 'State police and the central forces; notifications '
                  'through the year',
              whenHi: 'राज्य पुलिस और केंद्रीय बल; अधिसूचनाएँ साल भर आती रहती हैं'
            ),
          ],
        ExamField.agriculture => const [
            (
              name: 'ICAR AIEEA UG',
              whenEn: 'For the agricultural universities; forms around '
                  'February to April',
              whenHi: 'कृषि विश्वविद्यालयों के लिए; फ़ॉर्म लगभग फ़रवरी से अप्रैल'
            ),
            (
              name: 'Your state agriculture entrance',
              whenEn: 'Most agricultural states run one; around March to May',
              whenHi: 'ज़्यादातर कृषि राज्य अपनी परीक्षा कराते हैं; लगभग मार्च से मई'
            ),
          ],
        ExamField.teaching => const [
            (
              name: 'D.El.Ed or B.El.Ed entrance',
              whenEn: 'The route to primary school teaching, straight after '
                  'class 12; state-level, around May to July',
              whenHi: 'बारहवीं के बाद सीधे प्राथमिक शिक्षक बनने का रास्ता; राज्य स्तर '
                  'पर, लगभग मई से जुलाई'
            ),
            (
              name: 'Integrated B.A. B.Ed or B.Sc. B.Ed',
              whenEn: 'Four years, through CUET or a state test; around '
                  'February to May',
              whenHi: 'चार साल, CUET या राज्य की परीक्षा से; लगभग फ़रवरी से मई'
            ),
          ],
        ExamField.design => const [
            (
              name: 'NID DAT and UCEED',
              whenEn: 'Design entrances; forms around September to November',
              whenHi: 'डिज़ाइन की प्रवेश परीक्षाएँ; फ़ॉर्म लगभग सितंबर से नवंबर'
            ),
            (
              name: 'NATA, for architecture',
              whenEn: 'Several sessions a year; forms from around January',
              whenHi: 'साल में कई सत्र; फ़ॉर्म लगभग जनवरी से'
            ),
          ],
      };

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final exams = _field == null ? null : _exams(_field!);

    Widget pick(ExamField f, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _field == f,
          onTap: () => setState(() => _field = f),
        );

    return ToolScaffold(
      goal: 4,
      title: hi ? 'बारहवीं के बाद: परीक्षाएँ' : 'After class 12: the exams',
      children: [
        ToolNote(hi
            ? 'इस सूची में महीने लिखे हैं, तारीख़ें नहीं — और जानबूझकर। परीक्षाओं का '
                'कैलेंडर हर साल खिसकता है, और ऐप में लिखी ग़लत तारीख़ से फ़ॉर्म छूट जाता '
                'है, जो एक ही ग़लती है जिसे सुधारा नहीं जा सकता। महीना आने पर '
                'आधिकारिक वेबसाइट पर इस साल की तारीख़ देख लें।'
            : 'This list gives months, not dates - deliberately. Exam '
                'calendars shift every year, and a wrong date in an app means '
                'a missed form, which is the one mistake that cannot be '
                'undone. When the month comes round, check this year\'s dates '
                'on the official site.'),
        ToolQuestion(hi ? 'किस तरफ़ जाना है' : 'Which direction'),
        pick(ExamField.engineering, 'Engineering or technology',
            'इंजीनियरिंग या तकनीकी'),
        pick(ExamField.medical, 'Medicine, nursing, pharmacy',
            'चिकित्सा, नर्सिंग, फ़ार्मेसी'),
        pick(ExamField.generalDegree, 'A general degree - B.A., B.Sc., B.Com.',
            'सामान्य स्नातक — बीए, बीएससी, बीकॉम'),
        pick(ExamField.law, 'Law', 'क़ानून'),
        pick(ExamField.defence, 'Defence, police, paramilitary',
            'सेना, पुलिस, अर्धसैनिक बल'),
        pick(ExamField.agriculture, 'Agriculture', 'कृषि'),
        pick(ExamField.teaching, 'Teaching', 'अध्यापन'),
        pick(ExamField.design, 'Design or architecture',
            'डिज़ाइन या आर्किटेक्चर'),
        if (exams != null) ...[
          const SizedBox(height: 10),
          for (final e in exams) ...[
            const SizedBox(height: 12),
            Text(e.name,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ToolNote(hi ? e.whenHi : e.whenEn),
          ],
          const SizedBox(height: 16),
          Text(hi ? 'अभी कर लेने वाले काम' : 'Things to do now',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const ToolChecklist(
            storageKey: 'after_twelve_v1',
            introEn: 'Most forms are lost to one of these, not to the exam.',
            introHi: 'ज़्यादातर फ़ॉर्म परीक्षा की वजह से नहीं, इन्हीं में से किसी वजह '
                'से छूटते हैं।',
            items: [
              CheckItem('aadhaar', 'Aadhaar with a working mobile number '
                  'linked', 'आधार, जिससे चालू मोबाइल नंबर जुड़ा हो',
                  noteEn: 'Every form sends its OTP there. An old number is '
                      'the commonest reason a form cannot be submitted.',
                  noteHi: 'हर फ़ॉर्म का ओटीपी वहीं जाता है। फ़ॉर्म न भर पाने की सबसे '
                      'आम वजह पुराना नंबर ही है।'),
              CheckItem('email', 'An email address of your own that you can '
                  'open', 'अपनी एक ईमेल आईडी जो आप खोल सकें'),
              CheckItem('docs', 'Scans of the class 10 and 12 marksheets, '
                  'photograph and signature',
                  'कक्षा 10 और 12 के अंकपत्र, फ़ोटो और हस्ताक्षर के स्कैन'),
              CheckItem('category', 'Caste or EWS certificate, if you will '
                  'apply under a category - these take weeks to make',
                  'जाति या ईडब्ल्यूएस प्रमाण पत्र, अगर वर्ग से अर्ज़ी देनी है — ये '
                      'बनने में हफ़्ते लगते हैं'),
              CheckItem('fee', 'Check the fee waiver - most exams charge '
                  'much less, or nothing, for girls and for SC, ST and PwD '
                  'candidates',
                  'शुल्क छूट देखें — ज़्यादातर परीक्षाओं में लड़कियों और अनुसूचित '
                      'जाति/जनजाति/दिव्यांग उम्मीदवारों से बहुत कम या कुछ नहीं लिया '
                      'जाता'),
              CheckItem('calendar', 'Write the form month on a calendar at '
                  'home, and check the official site that month',
                  'फ़ॉर्म का महीना घर के कैलेंडर पर लिख लें, और उस महीने आधिकारिक '
                      'वेबसाइट देखें'),
            ],
          ),
          ToolNote(hi
              ? 'फ़ीस के लिए पढ़ाई न रोकें: इसी लक्ष्य में छात्रवृत्ति और शिक्षा ऋण की '
                  'स्क्रीनें हैं, और ₹7.5 लाख तक के शिक्षा ऋण पर कोई ज़मानत नहीं लगती।'
              : 'Do not let the fee stop the plan: this goal has screens for '
                  'scholarships and for the education loan, and an education '
                  'loan up to ₹7.5 lakh needs no collateral at all.'),
          const SourceNote(
              text: 'National Testing Agency - exam calendars', url: _ntaUrl),
          if (_field == ExamField.generalDegree || _field == ExamField.law)
            const SourceNote(text: 'CUET UG', url: _cuetUrl),
        ],
      ],
    );
  }
}
