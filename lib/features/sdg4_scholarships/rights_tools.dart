import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Four screens about what a school may not do, and what it must give.
///
/// The Right to Education Act made a set of things illegal that are still
/// completely routine: a fee for admission, a test to get into class one,
/// turning a child away for want of a birth certificate, holding a child
/// back or expelling them before class eight. Parents who know the section
/// numbers get different answers at the same counter, which is the whole
/// reason these screens quote them.

const _rteUrl = 'https://dsel.education.gov.in/rte';
const _digilockerUrl = 'https://www.digilocker.gov.in/';
const _nspUrl = 'https://scholarships.gov.in/';

// --- RTE 25 per cent free seat ----------------------------------------

/// What decides whether the 25% route is open to this family. Age at
/// entry is the hard one: the quota is for the entry class, and a family
/// that hears about it in class three has usually missed it.
enum RteCheck { ageFits, ageTooOld, notEntryClass }

class RtePage extends StatefulWidget {
  const RtePage({super.key});

  @override
  State<RtePage> createState() => _RtePageState();
}

class _RtePageState extends State<RtePage> {
  final _age = TextEditingController();
  bool _nearby = true;

  @override
  void dispose() {
    _age.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final age = int.tryParse(_age.text.trim());
    // The quota is for the entry class - pre-school or class 1 - which in
    // most states means a child of about three to seven.
    final fits = age != null && age >= 3 && age <= 7;

    return ToolScaffold(
      goal: 4,
      title: hi
          ? 'निजी स्कूल में मुफ़्त सीट (आरटीई 25%)'
          : 'A free seat in a private school (RTE 25%)',
      children: [
        ToolNote(hi
            ? 'शिक्षा का अधिकार क़ानून की धारा 12(1)(c) के तहत हर ग़ैर-सहायता प्राप्त '
                'निजी स्कूल को अपनी प्रवेश कक्षा की 25% सीटें आसपास के कमज़ोर और '
                'वंचित वर्ग के बच्चों के लिए रखनी होती हैं — और उन बच्चों की पढ़ाई '
                'कक्षा 8 तक मुफ़्त होती है। फ़ीस सरकार स्कूल को देती है।'
            : 'Under section 12(1)(c) of the Right to Education Act, every '
                'unaided private school must keep 25% of the seats in its '
                'entry class for children from weaker and disadvantaged '
                'groups living nearby - and those children study free until '
                'class 8. The government pays the school.'),
        ToolQuestion(hi ? 'बच्चे की उम्र' : 'The child\'s age'),
        ToolNumber(
          controller: _age,
          label: hi ? 'साल' : 'Years',
          maxDigits: 2,
          icon: Icons.child_care_outlined,
          onChanged: (_) => setState(() {}),
        ),
        SwitchListTile(
          value: _nearby,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'स्कूल घर के आसपास के इलाक़े में है'
              : 'The school is in our neighbourhood'),
          subtitle: Text(
            hi
                ? 'यह सीट पड़ोस के बच्चों के लिए है; दूरी की सीमा राज्य तय करता है'
                : 'The seat is for neighbourhood children; the state fixes '
                    'the distance',
            style: const TextStyle(fontSize: 12),
          ),
          onChanged: (v) => setState(() => _nearby = v),
        ),
        if (age != null && age > 0) ...[
          ToolAnswer(
            headline: fits
                ? (hi ? 'उम्र प्रवेश कक्षा की है' : 'The age fits the entry class')
                : (hi
                    ? 'यह कोटा सिर्फ़ प्रवेश कक्षा में मिलता है'
                    : 'This quota exists only at the entry class'),
            detail: fits
                ? (hi
                    ? 'अर्ज़ी राज्य के आरटीई पोर्टल पर होती है और खिड़की साल में एक बार '
                        'खुलती है — आमतौर पर नया सत्र शुरू होने से कुछ महीने पहले। सीटें '
                        'लॉटरी से बँटती हैं, इसलिए जल्दी अर्ज़ी देना फ़ायदा नहीं देता, '
                        'लेकिन खिड़की छूटना पूरा साल ले जाता है। तारीख़ ब्लॉक शिक्षा '
                        'कार्यालय से पूछकर लिख लें।'
                    : 'The application is on the state\'s RTE portal and the '
                        'window opens once a year - usually a few months '
                        'before the new session. Seats are allotted by '
                        'lottery, so applying early is no advantage, but '
                        'missing the window costs the whole year. Ask the '
                        'block education office for the date and write it '
                        'down.')
                : (hi
                    ? '25% सीट प्रवेश कक्षा — स्कूल-पूर्व या कक्षा 1 — में ही मिलती है, '
                        'बीच की कक्षाओं में नहीं। अगर बच्चा उससे बड़ा है तो यह रास्ता बंद '
                        'है, लेकिन सरकारी स्कूल में दाख़िला उम्र के हिसाब से कक्षा में अब '
                        'भी अधिकार है, और उसमें मना नहीं किया जा सकता।'
                    : 'The 25% seat exists at the entry class - pre-school or '
                        'class 1 - and not in the middle classes. If the '
                        'child is older than that, this route is closed, but '
                        'admission to a government school in the class '
                        'matching the child\'s age is still a right, and it '
                        'cannot be refused.'),
            tone: fits ? ToolTone.good : ToolTone.warn,
            icon: fits ? Icons.how_to_reg_outlined : Icons.schedule,
          ),
          if (!_nearby)
            ToolNote(hi
                ? 'यह कोटा पड़ोस के स्कूल के लिए है। दूरी की सीमा हर राज्य अलग तय '
                    'करता है, इसलिए अपने ब्लॉक शिक्षा कार्यालय से पूछें कि आपके पते से '
                    'कौन-कौन से स्कूल इस दायरे में आते हैं।'
                : 'The quota is for a neighbourhood school. Each state fixes '
                    'the distance differently, so ask your block education '
                    'office which schools your address falls within.'),
          const SizedBox(height: 14),
          Text(hi ? 'तैयार रखने वाले काग़ज़' : 'Papers to keep ready',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const ToolChecklist(
            storageKey: 'rte_papers_v1',
            introEn: 'The application is free. Nobody may charge for the '
                'form, the lottery, or the admission.',
            introHi: 'अर्ज़ी मुफ़्त है। फ़ॉर्म, लॉटरी या दाख़िले के पैसे कोई नहीं ले सकता।',
            items: [
              CheckItem('address', 'Proof of address - this is what decides '
                  'which schools you can apply to',
                  'पते का सबूत — इसी से तय होता है कि किन स्कूलों में अर्ज़ी दे सकते हैं'),
              CheckItem('age', 'Proof of the child\'s age',
                  'बच्चे की उम्र का सबूत',
                  noteEn: 'If there is no birth certificate, section 14 of '
                      'the Act says a child may not be refused admission for '
                      'that reason. See "Late birth certificate" under goal '
                      '1.',
                  noteHi: 'जन्म प्रमाण पत्र न हो तो क़ानून की धारा 14 कहती है कि इस '
                      'वजह से दाख़िला रोका नहीं जा सकता। लक्ष्य 1 में "देर से जन्म '
                      'प्रमाण पत्र" देखें।'),
              CheckItem('income', 'Income certificate, or the caste '
                  'certificate if applying under a disadvantaged category',
                  'आय प्रमाण पत्र, या वंचित वर्ग से अर्ज़ी हो तो जाति प्रमाण पत्र'),
              CheckItem('photo', 'The child\'s photograph',
                  'बच्चे की फ़ोटो'),
              CheckItem('aadhaar', 'Aadhaar of the child and a parent, where '
                  'the state asks', 'बच्चे और माता-पिता का आधार, जहाँ राज्य माँगे'),
              CheckItem('receipt', 'The application receipt and the lottery '
                  'result printout', 'अर्ज़ी की रसीद और लॉटरी के नतीजे का प्रिंट'),
            ],
          ),
          const SourceNote(
              text: 'Right to Education, Department of School Education',
              url: _rteUrl),
        ],
      ],
    );
  }
}

// --- Admission refused, or a donation demanded ------------------------

/// What the school did. Each of these is specifically prohibited, and the
/// section that prohibits it is the thing to say out loud.
enum SchoolWrong {
  capitationFee,
  screeningTest,
  noBirthCertificate,
  heldBack,
  expelled,
  midSessionRefusal,
  corporalPunishment,
}

class AdmissionRefusedPage extends StatefulWidget {
  const AdmissionRefusedPage({super.key});

  @override
  State<AdmissionRefusedPage> createState() => _AdmissionRefusedPageState();
}

class _AdmissionRefusedPageState extends State<AdmissionRefusedPage> {
  SchoolWrong? _wrong;

  ({String en, String hi}) _law(SchoolWrong w) => switch (w) {
        SchoolWrong.capitationFee => (
            en: 'A capitation fee - a donation, a building fund, a '
                'development charge, anything asked for as the price of a '
                'seat - is prohibited by section 13 of the Right to '
                'Education Act, and the Act provides a penalty of up to ten '
                'times the amount collected. It does not matter what the '
                'receipt calls it, and it does not matter that the school '
                'says everyone pays it.',
            hi: 'दाख़िले के बदले माँगा गया कोई भी पैसा — चंदा, भवन निधि, विकास '
                'शुल्क, जो भी नाम हो — शिक्षा का अधिकार क़ानून की धारा 13 के तहत '
                'प्रतिबंधित है, और क़ानून में वसूली गई रक़म के दस गुना तक जुर्माने का '
                'प्रावधान है। रसीद पर क्या लिखा है, इससे फ़र्क़ नहीं पड़ता, और "सब देते '
                'हैं" कहने से भी नहीं।',
          ),
        SchoolWrong.screeningTest => (
            en: 'A screening procedure for admission - a test for the child, '
                'an interview of the parents, any selection at the entry '
                'stage - is prohibited by section 13. A school may not test '
                'a four-year-old to decide whether to admit them, and it may '
                'not interview you either.',
            hi: 'दाख़िले के लिए छँटनी — बच्चे की परीक्षा, माता-पिता का साक्षात्कार, '
                'प्रवेश के समय किसी भी तरह का चयन — धारा 13 के तहत प्रतिबंधित है। '
                'स्कूल चार साल के बच्चे की परीक्षा लेकर दाख़िला तय नहीं कर सकता, और '
                'आपका साक्षात्कार भी नहीं ले सकता।',
          ),
        SchoolWrong.noBirthCertificate => (
            en: 'Section 14 says that no child shall be denied admission for '
                'want of age proof. Where there is no birth certificate, the '
                'school must accept whatever other proof the rules allow - '
                'and in several states a parent\'s declaration is enough. '
                'Ask for the refusal in writing; schools rarely put this one '
                'on paper.',
            hi: 'धारा 14 कहती है कि उम्र का सबूत न होने पर किसी बच्चे का दाख़िला '
                'रोका नहीं जाएगा। जन्म प्रमाण पत्र न हो तो स्कूल को नियमों में '
                'स्वीकार्य कोई दूसरा सबूत लेना होगा — और कई राज्यों में माता-पिता का '
                'घोषणा-पत्र ही काफ़ी है। मना करने का कारण लिखित में माँगें; इसे स्कूल '
                'काग़ज़ पर लिखने से बचते हैं।',
          ),
        SchoolWrong.heldBack => (
            en: 'Section 16 bars holding a child back in the same class. '
                'Since the 2019 amendment a state may allow detention after '
                'class 5 or 8 following a re-examination and remedial '
                'teaching, so the exact position depends on your state - but '
                'a child cannot simply be made to repeat a year, and cannot '
                'be held back in the earlier classes at all.',
            hi: 'धारा 16 बच्चे को उसी कक्षा में रोकने से मना करती है। 2019 के संशोधन '
                'के बाद राज्य कक्षा 5 या 8 के बाद पुनर्परीक्षा और उपचारात्मक पढ़ाई के '
                'बाद रोकने की अनुमति दे सकते हैं, इसलिए ठीक स्थिति आपके राज्य पर '
                'निर्भर है — लेकिन बच्चे को बस एक साल दोहराने को कहा नहीं जा सकता, '
                'और शुरू की कक्षाओं में रोका ही नहीं जा सकता।',
          ),
        SchoolWrong.expelled => (
            en: 'Section 16 also bars expelling a child before the '
                'completion of elementary education - class 8. A school that '
                'tells a family to take the child elsewhere because of marks, '
                'attendance or unpaid fees is doing something the Act '
                'forbids. Get it in writing, which is usually where it stops.',
            hi: 'धारा 16 प्रारंभिक शिक्षा पूरी होने से पहले — कक्षा 8 से पहले — बच्चे '
                'को निकालने से भी मना करती है। जो स्कूल अंक, उपस्थिति या बाक़ी फ़ीस की '
                'वजह से बच्चे को कहीं और ले जाने को कहता है, वह क़ानून के ख़िलाफ़ काम '
                'कर रहा है। लिखित में माँगें — आमतौर पर बात वहीं रुक जाती है।',
          ),
        SchoolWrong.midSessionRefusal => (
            en: 'Section 15 says a child may be admitted at any time in the '
                'year, and section 4 says a child admitted late must be put '
                'in the class matching their age, with special training to '
                'catch up. "Admissions are closed" is not an answer the Act '
                'allows for elementary classes.',
            hi: 'धारा 15 कहती है कि बच्चे को साल में कभी भी दाख़िला दिया जा सकता '
                'है, और धारा 4 कहती है कि देर से आए बच्चे को उसकी उम्र के हिसाब से '
                'कक्षा में बैठाया जाए और पीछे की पढ़ाई पूरी करने के लिए विशेष प्रशिक्षण '
                'दिया जाए। प्रारंभिक कक्षाओं के लिए "दाख़िले बंद हो गए" क़ानून में जवाब '
                'नहीं है।',
          ),
        SchoolWrong.corporalPunishment => (
            en: 'Section 17 prohibits physical punishment and mental '
                'harassment of a child, and makes it a matter for '
                'disciplinary action against the staff member. This is a '
                'complaint to the head teacher in writing, then the block '
                'education officer, and it can also go to the State '
                'Commission for Protection of Child Rights, or Childline on '
                '1098.',
            hi: 'धारा 17 बच्चे की शारीरिक सज़ा और मानसिक उत्पीड़न पर रोक लगाती है, '
                'और इसे कर्मचारी के ख़िलाफ़ अनुशासनात्मक कार्रवाई का विषय बनाती है। '
                'शिकायत प्रधानाध्यापक को लिखित में, फिर खंड शिक्षा अधिकारी को, और यह '
                'राज्य बाल अधिकार संरक्षण आयोग या 1098 चाइल्डलाइन तक भी जा सकती है।',
          ),
      };

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final law = _wrong == null ? null : _law(_wrong!);

    Widget pick(SchoolWrong w, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _wrong == w,
          onTap: () => setState(() => _wrong = w),
        );

    return ToolScaffold(
      goal: 4,
      title: hi
          ? 'स्कूल ने दाख़िला रोका या चंदा माँगा'
          : 'The school refused admission, or asked for a donation',
      children: [
        ToolNote(hi
            ? 'नीचे लिखी हर बात क़ानून में मना है, और फिर भी रोज़ होती है। फ़र्क़ इससे '
                'पड़ता है कि माँगने वाले को पता हो कि कौन सी धारा इसे मना करती है — '
                'उसी काउंटर पर जवाब बदल जाता है।'
            : 'Every one of the things below is prohibited by law, and every '
                'one of them happens daily. What changes the answer at the '
                'same counter is a parent who can name the section that '
                'forbids it.'),
        ToolQuestion(hi ? 'स्कूल ने क्या किया' : 'What did the school do'),
        pick(SchoolWrong.capitationFee,
            'Asked for a donation or development fee for admission',
            'दाख़िले के लिए चंदा या विकास शुल्क माँगा'),
        pick(SchoolWrong.screeningTest,
            'Held a test for the child, or an interview of the parents',
            'बच्चे की परीक्षा ली, या माता-पिता का साक्षात्कार'),
        pick(SchoolWrong.noBirthCertificate,
            'Refused because there is no birth certificate',
            'जन्म प्रमाण पत्र न होने पर मना किया'),
        pick(SchoolWrong.heldBack, 'Made the child repeat the same class',
            'बच्चे को उसी कक्षा में रोक दिया'),
        pick(SchoolWrong.expelled, 'Told us to take the child elsewhere',
            'बच्चे को कहीं और ले जाने को कहा'),
        pick(SchoolWrong.midSessionRefusal,
            'Said admissions are closed for the year',
            'कहा कि इस साल दाख़िले बंद हो गए'),
        pick(SchoolWrong.corporalPunishment, 'Beat or humiliated the child',
            'बच्चे को मारा या अपमानित किया'),
        if (law != null) ...[
          ToolAnswer(
            headline: hi ? 'यह क़ानूनन मना है' : 'This is prohibited by law',
            detail: hi ? law.hi : law.en,
            tone: ToolTone.bad,
            icon: Icons.gavel_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'अब यह करें' : 'What to do now',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'स्कूल से लिखित में कारण माँगें। एक पंक्ति काफ़ी है: "कृपया मना करने '
                        'का कारण लिखकर दीजिए।" यह माँगते ही बहुत सारे मामले वहीं सुलझ '
                        'जाते हैं, क्योंकि लिखकर देना मुश्किल है।',
                    'अपनी ओर से एक अर्ज़ी लिखकर स्कूल में जमा करें और उस पर मुहर-सहित '
                        'पावती लें। पावती मिल जाए तो आधा काम हो गया।',
                    'खंड शिक्षा अधिकारी (BEO) को लिखें — स्कूल का नाम, तारीख़, किससे '
                        'बात हुई, और क्या हुआ। आरटीई की धारा का नाम लिखें।',
                    'ज़िला शिक्षा अधिकारी, और राज्य के आरटीई शिकायत पोर्टल पर दर्ज '
                        'कराएँ।',
                    'राज्य बाल अधिकार संरक्षण आयोग (SCPCR) के पास भी सीधे शिकायत जा '
                        'सकती है — यही आरटीई की निगरानी करने वाली संस्था है।',
                  ]
                : const [
                    'Ask the school for the reason in writing. One line is '
                        'enough: "please give me the reason for the refusal '
                        'in writing." A great many cases end right here, '
                        'because writing it down is hard.',
                    'Submit your own written application to the school and '
                        'take a stamped acknowledgement. With the '
                        'acknowledgement in hand, half the work is done.',
                    'Write to the Block Education Officer - the school\'s '
                        'name, the date, who you spoke to, and what '
                        'happened. Name the RTE section.',
                    'The District Education Officer, and the state\'s RTE '
                        'grievance portal.',
                    'A complaint can also go straight to the State '
                        'Commission for Protection of Child Rights - it is '
                        'the body that monitors the RTE Act.',
                  ],
          ),
          const SourceNote(
              text: 'Right to Education, Department of School Education',
              url: _rteUrl),
        ],
      ],
    );
  }
}

// --- Free uniform, books, cycle, hostel -------------------------------

/// What the family is asking about. The central entitlements are the same
/// everywhere; the cycle and the cash are the state's, and vary.
enum FreeItem { books, uniform, cycle, hostel, scholarshipCash }

class FreeEntitlementsPage extends StatefulWidget {
  const FreeEntitlementsPage({super.key});

  @override
  State<FreeEntitlementsPage> createState() => _FreeEntitlementsPageState();
}

class _FreeEntitlementsPageState extends State<FreeEntitlementsPage> {
  FreeItem? _item;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    Widget pick(FreeItem i, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _item == i,
          onTap: () => setState(() => _item = i),
        );

    return ToolScaffold(
      goal: 4,
      title: hi
          ? 'मुफ़्त किताब, ड्रेस, साइकिल, हॉस्टल'
          : 'Free books, uniform, cycle, hostel',
      children: [
        ToolNote(hi
            ? 'कुछ चीज़ें पूरे देश में हक़ हैं और कुछ राज्य की योजनाएँ हैं। फ़र्क़ जानना '
                'ज़रूरी है: हक़ के लिए अर्ज़ी नहीं देनी पड़ती, योजना के लिए देनी पड़ती है — '
                'और योजना की खिड़की छूट जाती है।'
            : 'Some of these are entitlements across the country and some are '
                'state schemes. The difference matters: an entitlement needs '
                'no application, a scheme does - and a scheme\'s window is '
                'what gets missed.'),
        ToolQuestion(hi ? 'किस बारे में पूछना है' : 'Which one'),
        pick(FreeItem.books, 'Textbooks', 'पाठ्यपुस्तकें'),
        pick(FreeItem.uniform, 'Uniform', 'ड्रेस'),
        pick(FreeItem.cycle, 'A cycle', 'साइकिल'),
        pick(FreeItem.hostel, 'Hostel', 'हॉस्टल'),
        pick(FreeItem.scholarshipCash, 'Cash scholarship',
            'छात्रवृत्ति का पैसा'),
        if (_item != null) ...[
          ToolAnswer(
            headline: switch (_item!) {
              FreeItem.books => hi
                  ? 'कक्षा 8 तक हक़ है, अर्ज़ी की ज़रूरत नहीं'
                  : 'An entitlement up to class 8, no application needed',
              FreeItem.uniform => hi
                  ? 'सरकारी स्कूल में कक्षा 8 तक, हक़ है'
                  : 'An entitlement up to class 8 in a government school',
              FreeItem.cycle => hi
                  ? 'यह राज्य की योजना है'
                  : 'This one is a state scheme',
              FreeItem.hostel => hi
                  ? 'वर्ग और कक्षा पर निर्भर, अर्ज़ी देनी होती है'
                  : 'Depends on category and class, and needs an application',
              FreeItem.scholarshipCash => hi
                  ? 'पोर्टल पर एक अर्ज़ी से कई योजनाएँ'
                  : 'One portal application covers many schemes',
            },
            detail: switch (_item!) {
              FreeItem.books => hi
                  ? 'शिक्षा का अधिकार क़ानून के तहत सरकारी और सहायता प्राप्त स्कूलों '
                      'में कक्षा 1 से 8 तक हर बच्चे को पाठ्यपुस्तकें मुफ़्त मिलनी हैं। इसके '
                      'लिए कोई अर्ज़ी नहीं देनी होती — किताबें स्कूल में आती हैं और बाँटी '
                      'जाती हैं। न मिलें तो प्रधानाध्यापक से रजिस्टर दिखाने को कहें: '
                      'स्कूल को कितनी किताबें मिलीं, यह दर्ज होता है।'
                  : 'Under the Right to Education Act every child in classes '
                      '1 to 8 in a government or aided school gets textbooks '
                      'free. There is no application - the books come to the '
                      'school and are handed out. If they do not come, ask '
                      'the head teacher to show the register: how many books '
                      'the school received is recorded.',
              FreeItem.uniform => hi
                  ? 'सरकारी और सहायता प्राप्त स्कूलों में कक्षा 8 तक ड्रेस मुफ़्त दी '
                      'जाती है — कई राज्यों में कपड़े के बजाय पैसा सीधे खाते में आता है। '
                      'अगर पैसा आने वाली व्यवस्था है तो बच्चे का बैंक खाता और आधार '
                      'स्कूल में दर्ज होना चाहिए, वरना वही रुक जाता है।'
                  : 'In government and aided schools the uniform is free up '
                      'to class 8 - in many states as money into the account '
                      'rather than cloth. Where it is money, the child\'s '
                      'bank account and Aadhaar have to be recorded at the '
                      'school, or that is exactly what holds it up.',
              FreeItem.cycle => hi
                  ? 'साइकिल योजना केंद्र की नहीं, राज्य की है — और शर्तें राज्य-राज्य '
                      'में बहुत अलग हैं: कहीं कक्षा 9 की लड़कियों के लिए, कहीं सब बच्चों '
                      'के लिए, कहीं घर से स्कूल की दूरी पर। स्कूल के प्रधानाध्यापक या '
                      'खंड शिक्षा अधिकारी से पूछें कि इस साल आपके राज्य में शर्त क्या है '
                      'और सूची कब बनती है।'
                  : 'The cycle scheme is the state\'s, not the Centre\'s - '
                      'and the conditions differ sharply: in some states for '
                      'girls entering class 9, in others for all children, in '
                      'others by distance from home to school. Ask the head '
                      'teacher or the block education officer what this '
                      'year\'s condition is in your state and when the list '
                      'is made.',
              FreeItem.hostel => hi
                  ? 'अनुसूचित जाति, जनजाति, अन्य पिछड़ा वर्ग और अल्पसंख्यक छात्रों के '
                      'लिए केंद्र और राज्य के छात्रावास चलते हैं, और लड़कियों के लिए '
                      'कस्तूरबा गांधी बालिका विद्यालय जैसे आवासीय स्कूल भी। इनमें रहना, '
                      'खाना और पढ़ाई मुफ़्त या बहुत कम शुल्क पर होती है। अर्ज़ी ज़िला '
                      'समाज कल्याण कार्यालय में होती है, और सीटें सीमित हैं — इसलिए सत्र '
                      'शुरू होने से पहले पूछें।'
                  : 'The Centre and the states run hostels for Scheduled '
                      'Caste, Scheduled Tribe, OBC and minority students, and '
                      'residential schools for girls such as the Kasturba '
                      'Gandhi Balika Vidyalayas. Lodging, food and schooling '
                      'are free or close to it. The application goes to the '
                      'district social welfare office, and seats are '
                      'limited - so ask before the session starts.',
              FreeItem.scholarshipCash => hi
                  ? 'pre-matric और post-matric छात्रवृत्तियाँ, मेरिट छात्रवृत्तियाँ और '
                      'लड़कियों के लिए अलग योजनाएँ — इन सबके लिए राष्ट्रीय छात्रवृत्ति '
                      'पोर्टल पर एक ही अर्ज़ी चलती है। अर्ज़ी मुफ़्त है। इसी लक्ष्य में '
                      '"छात्रवृत्ति का पैसा नहीं आया" वाली स्क्रीन बताती है कि अटके तो '
                      'क्या करें।'
                  : 'Pre-matric and post-matric scholarships, merit '
                      'scholarships and separate schemes for girls all run off '
                      'one application on the National Scholarship Portal. The '
                      'application is free. The screen "The scholarship money '
                      'has not come" in this goal covers what to do when it '
                      'sticks.',
            },
            tone: _item == FreeItem.books || _item == FreeItem.uniform
                ? ToolTone.good
                : ToolTone.plain,
            icon: Icons.volunteer_activism_outlined,
          ),
          const SizedBox(height: 14),
          ToolNote(hi
              ? 'एक बात सब पर लागू होती है: स्कूल में जो भी मुफ़्त मिलना है, उसका '
                  'रिकॉर्ड रजिस्टर में होता है — कितना आया और किसे दिया गया। रजिस्टर '
                  'देखने को कहना आपका हक़ है, और माँगने पर ही बहुत कुछ मिल जाता है।'
              : 'One thing applies to all of them: whatever comes free to a '
                  'school is recorded in a register - how much arrived and who '
                  'it went to. Asking to see the register is your right, and '
                  'a good deal arrives simply because it was asked for.'),
          const SourceNote(
              text: 'National Scholarship Portal', url: _nspUrl),
        ],
      ],
    );
  }
}

// --- Lost marksheet or certificate ------------------------------------

/// Which document is lost. Routes differ, and one of them needs no trip
/// at all.
enum LostDoc { boardMarksheet, universityDegree, schoolTc, casteOrIncome }

class LostMarksheetPage extends StatefulWidget {
  const LostMarksheetPage({super.key});

  @override
  State<LostMarksheetPage> createState() => _LostMarksheetPageState();
}

class _LostMarksheetPageState extends State<LostMarksheetPage> {
  LostDoc? _doc;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    Widget pick(LostDoc d, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _doc == d,
          onTap: () => setState(() => _doc = d),
        );

    return ToolScaffold(
      goal: 4,
      title: hi ? 'अंकपत्र या प्रमाण पत्र खो गया' : 'A lost marksheet or certificate',
      children: [
        ToolAnswer(
          headline: hi
              ? 'पहले डिजिलॉकर देखें — वहाँ पहले से हो सकता है'
              : 'Check DigiLocker first - it may already be there',
          detail: hi
              ? 'सीबीएसई, आईसीएसई और अब कई राज्य बोर्ड और विश्वविद्यालय अपने '
                  'अंकपत्र सीधे डिजिलॉकर में डालते हैं। आधार से जुड़े मोबाइल नंबर से '
                  'लॉगिन करें और नाम से खोजें। वहाँ से निकाला दस्तावेज़ क़ानूनी रूप से '
                  'असली है और हर कार्यालय को उसे मानना होता है — यानी कई मामलों में '
                  'डुप्लिकेट बनवाने की ज़रूरत ही नहीं पड़ती।'
              : 'CBSE, ICSE and now many state boards and universities put '
                  'their marksheets straight into DigiLocker. Log in with the '
                  'mobile number linked to Aadhaar and search by name. A '
                  'document pulled from there is legally valid and every '
                  'office has to accept it - which means in a good many cases '
                  'no duplicate is needed at all.',
          tone: ToolTone.good,
          icon: Icons.cloud_download_outlined,
        ),
        ToolQuestion(hi ? 'क्या खो गया' : 'What is lost'),
        pick(LostDoc.boardMarksheet, 'A board marksheet - class 10 or 12',
            'बोर्ड का अंकपत्र — कक्षा 10 या 12'),
        pick(LostDoc.universityDegree, 'A degree or university marksheet',
            'डिग्री या विश्वविद्यालय का अंकपत्र'),
        pick(LostDoc.schoolTc, 'A school transfer certificate',
            'स्कूल का स्थानांतरण प्रमाण पत्र (टीसी)'),
        pick(LostDoc.casteOrIncome, 'A caste or income certificate',
            'जाति या आय प्रमाण पत्र'),
        if (_doc != null) ...[
          const SizedBox(height: 10),
          Text(hi ? 'डुप्लिकेट के क़दम' : 'Getting the duplicate',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: switch (_doc!) {
              LostDoc.boardMarksheet => hi
                  ? const [
                      'बोर्ड की वेबसाइट पर "डुप्लिकेट अंकपत्र" का फ़ॉर्म भरें, या क्षेत्रीय '
                          'कार्यालय में जमा करें।',
                      'रोल नंबर, पास होने का साल और स्कूल का नाम चाहिए। रोल नंबर याद न '
                          'हो तो स्कूल के रिकॉर्ड से मिल जाता है।',
                      'कई बोर्ड खोने का हलफ़नामा (एफ़िडेविट) या थाने की रिपोर्ट माँगते '
                          'हैं — पहले पूछ लें, ताकि दो चक्कर न लगें।',
                      'शुल्क बोर्ड की वेबसाइट पर लिखा होता है; पुराने साल के लिए '
                          'ज़्यादा लगता है।',
                      'आमतौर पर दो से छह हफ़्ते लगते हैं। रसीद सँभालकर रखें।',
                    ]
                  : const [
                      'Fill the "duplicate marksheet" form on the board\'s '
                          'website, or submit it at the regional office.',
                      'You need the roll number, the year of passing and the '
                          'school\'s name. If the roll number is forgotten, '
                          'the school\'s records have it.',
                      'Many boards ask for an affidavit of loss or a police '
                          'report - ask first, so it does not take two '
                          'trips.',
                      'The fee is published on the board\'s website; older '
                          'years cost more.',
                      'It usually takes two to six weeks. Keep the receipt.',
                    ],
              LostDoc.universityDegree => hi
                  ? const [
                      'विश्वविद्यालय के परीक्षा नियंत्रक के कार्यालय में अर्ज़ी दें।',
                      'नामांकन संख्या, पास होने का साल और कॉलेज का नाम चाहिए।',
                      'आमतौर पर हलफ़नामा और कुछ विश्वविद्यालयों में अख़बार में सूचना '
                          'देने को कहा जाता है — पहले पूछ लें।',
                      'डिग्री की दूसरी प्रति दीक्षांत समारोह से जुड़ी होती है, इसलिए '
                          'उसमें ज़्यादा समय लग सकता है; अंकपत्र जल्दी मिल जाता है।',
                      'इस बीच कार्यालय से "प्रमाणित प्रतिलिपि" माँग लें — वह ज़्यादातर '
                          'जगह चल जाती है।',
                    ]
                  : const [
                      'Apply at the university\'s controller of examinations '
                          'office.',
                      'You need the enrolment number, the year of passing and '
                          'the college\'s name.',
                      'An affidavit is usual, and some universities ask for a '
                          'newspaper notice - ask first.',
                      'A second copy of the degree itself is tied to a '
                          'convocation, so it can take longer; the marksheet '
                          'comes faster.',
                      'Meanwhile ask the office for a "certified copy" - that '
                          'is accepted in most places.',
                    ],
              LostDoc.schoolTc => hi
                  ? const [
                      'उसी स्कूल में अर्ज़ी दें जहाँ से निकले थे। स्कूल के रजिस्टर में '
                          'रिकॉर्ड हमेशा रहता है।',
                      'स्कूल बंद हो गया हो तो खंड शिक्षा अधिकारी के पास जाएँ — बंद '
                          'स्कूलों के रिकॉर्ड वहीं जाते हैं।',
                      'टीसी के पैसे नहीं लिए जा सकते, और बाक़ी फ़ीस के नाम पर टीसी '
                          'रोकी नहीं जा सकती — मना करें तो खंड शिक्षा अधिकारी को लिखें।',
                    ]
                  : const [
                      'Apply at the school you left. A school\'s register '
                          'always holds the record.',
                      'If the school has closed, go to the block education '
                          'officer - closed schools\' records go there.',
                      'No money may be charged for a TC, and a TC may not be '
                          'withheld over unpaid fees - if it is refused, write '
                          'to the block education officer.',
                    ],
              LostDoc.casteOrIncome => hi
                  ? const [
                      'ये प्रमाण पत्र तहसील से बनते हैं, और ज़्यादातर राज्यों में '
                          'ऑनलाइन दोबारा निकाले जा सकते हैं — पुरानी प्रति की ज़रूरत नहीं।',
                      'आय प्रमाण पत्र आमतौर पर एक साल चलता है, इसलिए खोया हुआ पुराना '
                          'प्रमाण पत्र ढूँढ़ने से अच्छा है नया बनवा लेना।',
                      'जाति प्रमाण पत्र आमतौर पर हमेशा के लिए रहता है; उसकी प्रति '
                          'तहसील के रिकॉर्ड से मिल जाती है।',
                      'दोनों के लिए ई-डिस्ट्रिक्ट पोर्टल या कॉमन सर्विस सेंटर सबसे तेज़ '
                          'रास्ता है।',
                    ]
                  : const [
                      'These come from the tehsil, and in most states they '
                          'can be reissued online - the old copy is not '
                          'needed.',
                      'An income certificate is usually valid for a year, so '
                          'getting a fresh one beats hunting for the lost '
                          'one.',
                      'A caste certificate is usually permanent; a copy comes '
                          'from the tehsil records.',
                      'For both, the e-District portal or a Common Service '
                          'Centre is the quickest route.',
                    ],
            },
          ),
          const SizedBox(height: 10),
          ToolNote(hi
              ? 'एक बार मिल जाए तो उसी दिन दो काम करें: डिजिलॉकर में डाल दें, और '
                  'फ़ोन से फ़ोटो खींचकर अपनी ही ईमेल पर भेज दें। दूसरी बार खोने पर यही '
                  'बचाता है।'
              : 'Once you have it, do two things the same day: put it in '
                  'DigiLocker, and photograph it and mail it to your own '
                  'email. That is what saves you the second time.'),
          const SourceNote(text: 'DigiLocker', url: _digilockerUrl),
        ],
      ],
    );
  }
}
