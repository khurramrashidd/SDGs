import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/place/place_service.dart';
import '../../core/place/weather.dart';
import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Five screens about bodies rather than money: injury, illness, children
/// at work, forced labour, and heat.
///
/// The heat screen is the only one in the app that reads the live forecast
/// for the user's own place and turns it into a decision. Everything else
/// about heat is advice; this is "today, where you are".

const _esicUrl = 'https://www.esic.gov.in/';
const _labourUrl = 'https://labour.gov.in/';
const _pencilUrl = 'https://pencil.gov.in/';

/// ESI covers employees earning up to this a month, in a covered
/// establishment. Higher for a person with a disability.
const esiWageCeiling = 21000;
const esiFuneralExpenses = 15000;
const esiSicknessPercent = 70;
const esiSicknessDays = 91;

/// Below 14, work is prohibited; 14 to 18 is an adolescent, barred from
/// hazardous work.
const childLabourAge = 14;
const adolescentAge = 18;

/// Bonded labour rehabilitation, as published by the Ministry of Labour.
const bondedImmediate = 30000;

// --- Injured at work --------------------------------------------------

enum InjuryCover { esiCovered, notCovered, notSure }

class InjuredAtWorkPage extends StatefulWidget {
  const InjuredAtWorkPage({super.key});

  @override
  State<InjuredAtWorkPage> createState() => _InjuredAtWorkPageState();
}

class _InjuredAtWorkPageState extends State<InjuredAtWorkPage> {
  InjuryCover? _cover;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;

    Widget pick(InjuryCover c, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _cover == c,
          onTap: () => setState(() => _cover = c),
        );

    return ToolScaffold(
      goal: 8,
      title: hi ? 'काम पर चोट लग गई' : 'Injured at work',
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: scheme.error,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.local_hospital_outlined, color: scheme.onError,
                  size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hi
                      ? 'पहले इलाज — एम्बुलेंस 108। काग़ज़ और मुआवज़े की बात बाद में '
                          'होगी, और बाद में भी हो सकती है। इलाज में देर नहीं।'
                      : 'Treatment first - ambulance 108. The papers and the '
                          'compensation come after, and they can come after. '
                          'Do not delay the treatment.',
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
        ToolNote(hi
            ? 'काम के दौरान लगी चोट के लिए मुआवज़े की व्यवस्था है, और वह दया पर नहीं '
                'क़ानून पर टिकी है। कौन सी व्यवस्था लागू होगी, यह इस पर निर्भर है कि '
                'आप ईएसआई में आते हैं या नहीं।'
            : 'There is provision for compensation for an injury at work, and '
                'it rests on law rather than on anyone\'s goodwill. Which '
                'provision applies depends on whether you come under ESI.'),
        ToolQuestion(hi ? 'ईएसआई का कार्ड है?' : 'Do you have an ESI card'),
        pick(InjuryCover.esiCovered, 'Yes, ESI is deducted from my pay',
            'हाँ, वेतन से ईएसआई कटता है'),
        pick(InjuryCover.notCovered, 'No', 'नहीं'),
        pick(InjuryCover.notSure, 'Not sure', 'पता नहीं'),
        if (_cover != null) ...[
          ToolAnswer(
            headline: switch (_cover!) {
              InjuryCover.esiCovered =>
                hi ? 'ईएसआई में इलाज और वेतन, दोनों' : 'Under ESI: treatment and wages both',
              InjuryCover.notCovered => hi
                  ? 'कर्मचारी प्रतिकर अधिनियम लागू होता है'
                  : 'The Employee\'s Compensation Act applies',
              InjuryCover.notSure =>
                hi ? 'यह दो मिनट में पता चल जाता है' : 'This takes two minutes to settle',
            },
            detail: switch (_cover!) {
              InjuryCover.esiCovered => hi
                  ? 'ईएसआई में काम की चोट पर पूरा इलाज मुफ़्त है — ख़र्च की कोई सीमा '
                      'नहीं — और जब तक आप काम न कर सकें, मज़दूरी का लगभग 90% अस्थायी '
                      'अपंगता लाभ के रूप में मिलता है। स्थायी अपंगता पर जीवन भर पेंशन, '
                      'और मृत्यु पर परिवार को पेंशन तथा अंतिम संस्कार के लिए '
                      '₹$esiFuneralExpenses। यह सब तभी मिलता है जब दुर्घटना की सूचना '
                      'दर्ज हो — इसलिए नीचे का पहला क़दम सबसे ज़रूरी है।'
                  : 'Under ESI an employment injury gets full free treatment, '
                      'with no ceiling on the expenditure, and about 90% of '
                      'wages as temporary disablement benefit for as long as '
                      'you cannot work. Permanent disablement carries a '
                      'pension for life, and death carries a family pension '
                      'plus ₹$esiFuneralExpenses towards the funeral. All of '
                      'it depends on the accident being recorded - which is '
                      'why the first step below matters most.',
              InjuryCover.notCovered => hi
                  ? 'ईएसआई के बाहर भी मुआवज़ा बनता है, कर्मचारी प्रतिकर अधिनियम के '
                      'तहत, और नियोक्ता को देना होता है। रक़म उम्र और मज़दूरी से तय '
                      'होती है — कम उम्र में ज़्यादा, क्योंकि कमाने के साल ज़्यादा बचे '
                      'होते हैं। दावा कर्मचारी प्रतिकर आयुक्त के पास किया जाता है, और '
                      'यह अदालती मुक़दमा नहीं है।'
                  : 'Compensation arises outside ESI too, under the '
                      'Employee\'s Compensation Act, and the employer has to '
                      'pay it. The amount is set by age and wages - more for '
                      'a younger worker, because more earning years remain. '
                      'The claim goes to the Commissioner for Employee\'s '
                      'Compensation, and it is not a court case.',
              InjuryCover.notSure => hi
                  ? 'वेतन पर्ची देखें — ईएसआई की कटौती अलग लिखी होती है। पर्ची न हो '
                      'तो ईएसआईसी की वेबसाइट या नज़दीकी शाखा में आधार और नियोक्ता का '
                      'नाम बताकर पता चल जाता है। ध्यान रहे: कटौती होती रही हो और '
                      'नियोक्ता ने जमा न की हो, तो भी आप बीमित माने जाते हैं — यह '
                      'नियोक्ता की चूक है, आपका नुक़सान नहीं।'
                  : 'Look at the salary slip - the ESI deduction is shown '
                      'separately. With no slip, the ESIC site or the nearest '
                      'branch will tell you against your Aadhaar and the '
                      'employer\'s name. One thing to know: if it was being '
                      'deducted and the employer did not deposit it, you are '
                      'still treated as insured - that default is theirs, not '
                      'your loss.',
            },
            tone: ToolTone.plain,
            icon: Icons.healing_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'जो आज ही करना है' : 'What to do today',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const ToolChecklist(
            storageKey: 'work_injury_v1',
            introEn: 'The claim is usually lost not on the merits but '
                'because none of this was done in the first week.',
            introHi: 'दावा आमतौर पर हक़ न होने से नहीं हारता, बल्कि इसलिए कि पहले '
                'हफ़्ते में इनमें से कुछ नहीं किया गया।',
            items: [
              CheckItem('report', 'Report the accident to the employer in '
                  'writing, the same day if you can',
                  'दुर्घटना की सूचना नियोक्ता को लिखित में दें, हो सके तो उसी दिन',
                  noteEn: 'This single piece of paper is what most claims '
                      'turn on. Keep a copy with an acknowledgement.',
                  noteHi: 'ज़्यादातर दावे इसी एक काग़ज़ पर टिकते हैं। पावती के साथ एक '
                      'नक़ल अपने पास रखें।'),
              CheckItem('register', 'Ask for it to be entered in the '
                  'accident register', 'दुर्घटना रजिस्टर में दर्ज कराएँ'),
              CheckItem('esi', 'If ESI applies, get treated at an ESI '
                  'dispensary or hospital and mention it is an employment '
                  'injury',
                  'ईएसआई हो तो ईएसआई डिस्पेंसरी या अस्पताल में इलाज कराएँ और बताएँ '
                      'कि यह काम की चोट है'),
              CheckItem('papers', 'Keep every medical paper, bill and '
                  'prescription', 'इलाज का हर काग़ज़, बिल और पर्ची रखें'),
              CheckItem('witness', 'Note the names of workers who saw it',
                  'जिन मज़दूरों ने देखा, उनके नाम लिख लें'),
              CheckItem('photo', 'Photograph the place and the machine or '
                  'cause, if you safely can',
                  'जगह और मशीन या कारण की फ़ोटो लें, अगर सुरक्षित हो'),
              CheckItem('nowork', 'Get the doctor to write how long you '
                  'cannot work', 'डॉक्टर से लिखवाएँ कि कितने दिन काम नहीं कर सकते'),
            ],
          ),
          ToolDonts(
            heading: hi ? 'यह न करें' : 'Do not',
            items: hi
                ? const [
                    'नियोक्ता के कहने पर यह न लिखें कि चोट घर पर या बाहर लगी थी — '
                        'यही एक बात पूरे मुआवज़े को ख़त्म कर देती है',
                    'कुछ हज़ार रुपये लेकर "सब ख़त्म" का काग़ज़ बिना समझे न लिखें; पहले '
                        '15100 पर मुफ़्त सलाह लें',
                    'इलाज अधूरा छोड़कर काम पर न लौटें, और डॉक्टर की लिखी छुट्टी से '
                        'पहले न लौटें',
                    'दुर्घटना की सूचना देने में हफ़्तों की देर न करें',
                  ]
                : const [
                    'Do not write, at the employer\'s asking, that the injury '
                        'happened at home or elsewhere - that one line ends '
                        'the whole claim',
                    'Do not sign a "full and final" paper for a few thousand '
                        'rupees without understanding it; get free advice on '
                        '15100 first',
                    'Do not go back to work with the treatment unfinished, or '
                        'before the doctor\'s certified rest is over',
                    'Do not let weeks pass before reporting the accident',
                  ],
          ),
          const SourceNote(text: 'ESIC', url: _esicUrl),
          const SourceNote(
              text: 'Ministry of Labour and Employment', url: _labourUrl),
        ],
      ],
    );
  }
}

// --- ESI --------------------------------------------------------------

class EsiPage extends StatefulWidget {
  const EsiPage({super.key});

  @override
  State<EsiPage> createState() => _EsiPageState();
}

class _EsiPageState extends State<EsiPage> {
  final _wage = TextEditingController();
  bool _deducted = true;

  @override
  void dispose() {
    _wage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final wage = double.tryParse(_wage.text.trim());
    final within = wage != null && wage > 0 && wage <= esiWageCeiling;
    final sickDaily =
        wage != null && wage > 0 ? wage / 30 * esiSicknessPercent / 100 : null;

    // Built here rather than inside the sentence: a nested same-quoted
    // string inside an interpolation is legal Dart and awful to read.
    final notDeductedHi = _deducted
        ? ''
        : ' कटौती नहीं हो रही और प्रतिष्ठान दायरे में आता है, तो यह नियोक्ता की '
            'चूक है — नीचे देखें।';
    final notDeductedEn = _deducted
        ? ''
        : ' If nothing is being deducted and the establishment is covered, '
            "that is the employer's default - see below.";

    return ToolScaffold(
      goal: 8,
      title: hi ? 'ईएसआई: मुफ़्त इलाज और बीमारी का वेतन' : 'ESI: free treatment and sick pay',
      children: [
        ToolNote(hi
            ? 'ईएसआई कर्मचारी राज्य बीमा है। वेतन से थोड़ा कटता है और नियोक्ता उससे '
                'कई गुना जोड़ता है, और बदले में बीमित व्यक्ति तथा उसके पूरे परिवार को '
                'इलाज मिलता है — ख़र्च की कोई सीमा नहीं। यह बात बहुत कम लोग जानते हैं '
                'कि परिवार भी इसमें शामिल है।'
            : 'ESI is the employees\' state insurance. A little comes off the '
                'wage and the employer adds several times as much, and in '
                'return the insured person and the whole family get medical '
                'care with no ceiling on expenditure. That the family is '
                'included is the part few people know.'),
        ToolQuestion(hi ? 'महीने की मज़दूरी' : 'Monthly wage'),
        ToolNumber(
          controller: _wage,
          label: hi ? 'रुपये' : 'Rupees',
          decimal: true,
          maxDigits: 8,
          icon: Icons.currency_rupee,
          onChanged: (_) => setState(() {}),
        ),
        SwitchListTile(
          value: _deducted,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'वेतन से ईएसआई कटता है'
              : 'ESI is deducted from the wage'),
          onChanged: (v) => setState(() => _deducted = v),
        ),
        if (wage != null && wage > 0) ...[
          ToolAnswer(
            headline: within
                ? (hi ? 'वेतन सीमा के भीतर है' : 'Within the wage ceiling')
                : (hi
                    ? 'वेतन ₹$esiWageCeiling की सीमा से ऊपर है'
                    : 'Above the ₹$esiWageCeiling ceiling'),
            detail: within
                ? (hi
                    ? 'ईएसआई महीने ₹$esiWageCeiling तक कमाने वाले कर्मचारियों पर '
                        'लागू होता है, बशर्ते प्रतिष्ठान ईएसआई के दायरे में आता हो '
                        '(आमतौर पर दस या अधिक कर्मचारी)। दिव्यांग व्यक्ति के लिए यह '
                        'सीमा और ऊँची है।$notDeductedHi'
                    : 'ESI applies to employees earning up to '
                        '₹$esiWageCeiling a month, provided the establishment '
                        'is covered - usually ten or more employees. The '
                        'ceiling is higher for a person with a disability.'
                        '$notDeductedEn')
                : (hi
                    ? 'सीमा से ऊपर कमाने वाले नए कर्मचारी ईएसआई में शामिल नहीं होते। '
                        'लेकिन एक बात जान लें: अगर आप पहले से बीमित थे और बीच के '
                        'योगदान काल में वेतन सीमा से ऊपर हो गया, तो उस काल के अंत तक '
                        'बीमा चलता रहता है।'
                    : 'A new employee earning above the ceiling is not '
                        'covered. One thing worth knowing: if you were '
                        'already insured and your wage crossed the ceiling '
                        'mid-contribution-period, the cover continues to the '
                        'end of that period.'),
            tone: within ? ToolTone.good : ToolTone.plain,
            icon: Icons.medical_services_outlined,
          ),
          if (within) ...[
            const SizedBox(height: 14),
            Text(hi ? 'कार्ड से क्या मिलता है' : 'What the card gets you',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            ToolLine(
                hi
                    ? 'बीमित व्यक्ति और परिवार का इलाज'
                    : 'Treatment for you and the family',
                hi ? 'पूरा, सीमा के बिना' : 'Full, no ceiling',
                strong: true),
            ToolLine(
                hi ? 'बीमारी में वेतन' : 'Sickness benefit',
                hi
                    ? 'मज़दूरी का $esiSicknessPercent%, साल में $esiSicknessDays दिन तक'
                    : '$esiSicknessPercent% of wages, up to $esiSicknessDays days a year'),
            ToolLine(hi ? 'मातृत्व लाभ' : 'Maternity benefit',
                hi ? '26 हफ़्ते' : '26 weeks'),
            ToolLine(
                hi ? 'काम की चोट में वेतन' : 'Employment injury',
                hi ? 'मज़दूरी का लगभग 90%' : 'About 90% of wages'),
            ToolLine(hi ? 'अंतिम संस्कार' : 'Funeral expenses',
                '₹$esiFuneralExpenses'),
            if (sickDaily != null) ...[
              const SizedBox(height: 8),
              ToolAnswer(
                headline: hi
                    ? 'बीमारी में रोज़ लगभग ₹${sickDaily.round()}'
                    : 'About ₹${sickDaily.round()} a day when sick',
                detail: hi
                    ? 'आपकी मज़दूरी पर $esiSicknessPercent% के हिसाब से। इसके लिए '
                        'ईएसआई डॉक्टर से बीमारी का प्रमाण पत्र लेना होता है — निजी '
                        'डॉक्टर का काग़ज़ आमतौर पर नहीं चलता, और यही वजह है कि बहुत '
                        'लोग यह लाभ चूक जाते हैं।'
                    : 'at $esiSicknessPercent% of your wage. It needs a '
                        'sickness certificate from an ESI doctor - a private '
                        'doctor\'s paper usually will not do, which is why so '
                        'many people miss this benefit.',
                tone: ToolTone.plain,
                icon: Icons.sick_outlined,
              ),
            ],
            if (!_deducted)
              ToolAnswer(
                headline: hi
                    ? 'कटौती नहीं हो रही — शिकायत बनती है'
                    : 'Nothing deducted - that is a complaint',
                detail: hi
                    ? 'जो प्रतिष्ठान ईएसआई के दायरे में आता है, उसे कर्मचारी को '
                        'पंजीकृत करना ही होता है — यह विकल्प नहीं है। शिकायत नज़दीकी '
                        'ईएसआईसी शाखा कार्यालय में या उनकी वेबसाइट पर दर्ज कराई जा '
                        'सकती है। और याद रखें: बिना पंजीकरण के भी, चोट लगने पर '
                        'नियोक्ता की ज़िम्मेदारी ख़त्म नहीं होती — उस हालत में कर्मचारी '
                        'प्रतिकर अधिनियम लागू होता है।'
                    : 'An establishment that falls under ESI must register '
                        'its employees - it is not optional. The complaint '
                        'can go to the nearest ESIC branch office or on their '
                        'site. And remember: even without registration the '
                        'employer\'s liability does not disappear if you are '
                        'injured - the Employee\'s Compensation Act applies '
                        'then.',
                tone: ToolTone.warn,
                icon: Icons.report_outlined,
              ),
            ToolNote(hi
                ? 'परिवार में पति-पत्नी, बच्चे और आश्रित माता-पिता शामिल होते हैं। '
                    'ईएसआई अस्पताल या डिस्पेंसरी में इलाज के लिए कार्ड या बीमा संख्या '
                    'साथ ले जाएँ। नज़दीकी ईएसआई केंद्र की सूची उनकी वेबसाइट पर है।'
                : 'The family covers the spouse, children and dependent '
                    'parents. Take the card or the insurance number to an ESI '
                    'hospital or dispensary. The list of nearby ESI centres '
                    'is on their site.'),
            const SourceNote(text: 'ESIC', url: _esicUrl),
          ],
        ],
      ],
    );
  }
}

// --- Child working nearby ---------------------------------------------

class ChildLabourPage extends StatefulWidget {
  const ChildLabourPage({super.key});

  @override
  State<ChildLabourPage> createState() => _ChildLabourPageState();
}

class _ChildLabourPageState extends State<ChildLabourPage> {
  final _age = TextEditingController();
  bool _hazardous = false;
  bool _familyBusiness = false;
  bool _duringSchool = true;

  @override
  void dispose() {
    _age.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;
    final age = int.tryParse(_age.text.trim());

    final illegal = age == null
        ? null
        : (age < childLabourAge
            ? (!_familyBusiness || _duringSchool || _hazardous)
            : (age < adolescentAge && _hazardous));

    return ToolScaffold(
      goal: 8,
      title: hi ? 'कोई बच्चा काम कर रहा है' : 'A child working nearby',
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: scheme.error,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.campaign_outlined, color: scheme.onError, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hi
                      ? 'चाइल्डलाइन 1098 — चौबीसों घंटे, और नाम बताए बिना भी। '
                          'ख़तरे में हो तो 112।'
                      : 'Childline 1098 - any hour, and without giving your '
                          'name. If the child is in danger, 112.',
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
        ToolNote(hi
            ? 'क़ानून दो उम्रों में बाँटता है। $childLabourAge साल से छोटे बच्चे का '
                'किसी भी काम में लगना मना है — एक छूट के साथ, कि वह स्कूल के बाद अपने '
                'परिवार के ही काम में हाथ बँटाए और वह काम ख़तरनाक न हो। '
                '$childLabourAge से $adolescentAge साल तक किशोर माने जाते हैं, और '
                'उन्हें ख़तरनाक कामों में नहीं लगाया जा सकता।'
            : 'The law divides this by age. A child under $childLabourAge may '
                'not be put to work at all - with one exception, helping in '
                'the family\'s own work outside school hours, where the work '
                'is not hazardous. From $childLabourAge to $adolescentAge '
                'they are adolescents, and may not be put to hazardous '
                'work.'),
        ToolQuestion(hi ? 'बच्चे की उम्र' : 'The child\'s age'),
        ToolNumber(
          controller: _age,
          label: hi ? 'साल' : 'Years',
          maxDigits: 2,
          icon: Icons.child_care_outlined,
          onChanged: (_) => setState(() {}),
        ),
        ToolQuestion(hi ? 'काम के बारे में' : 'About the work'),
        SwitchListTile(
          value: _hazardous,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'काम ख़तरनाक है'
              : 'The work is hazardous'),
          subtitle: Text(
            hi
                ? 'भट्ठा, खदान, पटाख़े, रसायन, मशीन, निर्माण, कूड़ा बीनना, होटल की '
                    'भट्टी'
                : 'A kiln, mine, fireworks, chemicals, machines, '
                    'construction, waste picking, a hotel kitchen',
            style: const TextStyle(fontSize: 12),
          ),
          onChanged: (v) => setState(() => _hazardous = v),
        ),
        SwitchListTile(
          value: _familyBusiness,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'अपने ही परिवार का काम है'
              : 'It is the family\'s own work'),
          onChanged: (v) => setState(() => _familyBusiness = v),
        ),
        SwitchListTile(
          value: _duringSchool,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'स्कूल के समय में काम करता है, या स्कूल छूट गया है'
              : 'It is during school hours, or school has stopped'),
          onChanged: (v) => setState(() => _duringSchool = v),
        ),
        if (age != null && age > 0 && illegal != null) ...[
          ToolAnswer(
            headline: illegal
                ? (hi ? 'यह अवैध है' : 'This is unlawful')
                : (hi
                    ? 'यह छूट के दायरे में आ सकता है'
                    : 'This may fall within the exception'),
            detail: illegal
                ? (hi
                    ? 'ऐसे काम पर लगाने वाले के लिए क़ानून में क़ैद और जुर्माना दोनों '
                        'का प्रावधान है, और दोबारा करने पर सज़ा बढ़ जाती है। बच्चे के '
                        'माता-पिता को पहली बार सज़ा नहीं दी जाती — क़ानून यह मानकर '
                        'चलता है कि मजबूरी भी एक वजह होती है, और इसीलिए शिकायत से '
                        'परिवार पर मुसीबत आने का डर नहीं होना चाहिए।'
                    : 'Whoever employs a child this way faces imprisonment '
                        'and a fine, rising on a repeat offence. A child\'s '
                        'own parents are not punished for a first offence - '
                        'the law accepts that need is also a reason, which is '
                        'why reporting it should not be feared as bringing '
                        'trouble on the family.')
                : (hi
                    ? 'परिवार के अपने काम में, स्कूल के बाद, और ख़तरनाक न होने पर '
                        'क़ानून छूट देता है। लेकिन दो बातें फिर भी देखिए: बच्चा स्कूल '
                        'जा रहा है या नहीं — 14 साल तक मुफ़्त और अनिवार्य शिक्षा का हक़ '
                        'अलग से है; और काम उसकी पढ़ाई या सेहत पर असर डाल रहा है या '
                        'नहीं।'
                    : 'In the family\'s own work, outside school hours, and '
                        'not hazardous, the law allows it. But two things '
                        'still matter: whether the child is in school - the '
                        'right to free and compulsory education up to 14 is '
                        'separate - and whether the work is telling on their '
                        'schooling or health.'),
            tone: illegal ? ToolTone.bad : ToolTone.plain,
            icon: illegal ? Icons.gavel_outlined : Icons.info_outline,
          ),
          if (illegal) ...[
            const SizedBox(height: 14),
            Text(hi ? 'कहाँ बताएँ' : 'Where to report it',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800)),
            ToolSteps(
              steps: hi
                  ? const [
                      '1098 पर फ़ोन करें — नाम बताए बिना भी चलता है, और यही सबसे तेज़ '
                          'रास्ता है।',
                      'केंद्र सरकार का पेंसिल (PENCIL) पोर्टल — वहाँ ऑनलाइन शिकायत '
                          'दर्ज होती है और ज़िले के नोडल अधिकारी तक जाती है।',
                      'ज़िला बाल संरक्षण इकाई या बाल कल्याण समिति।',
                      'श्रम निरीक्षक, और पुलिस — ख़ासकर अगर बच्चा कहीं बंद है या '
                          'उसे कहीं से लाया गया है।',
                      'शिकायत में जगह, किस तरह का काम, कितने बच्चे और समय बताएँ। '
                          '"एक दुकान पर बच्चा काम करता है" से कार्रवाई मुश्किल है।',
                    ]
                  : const [
                      'Call 1098 - it works without giving your name, and it '
                          'is the fastest route.',
                      'The central government\'s PENCIL portal takes an '
                          'online complaint and routes it to the district '
                          'nodal officer.',
                      'The District Child Protection Unit or the Child '
                          'Welfare Committee.',
                      'The labour inspector, and the police - particularly if '
                          'the child is confined or has been brought from '
                          'elsewhere.',
                      'Give the place, the kind of work, how many children '
                          'and the hours. "A child works at a shop" is hard '
                          'to act on.',
                    ],
            ),
            ToolAnswer(
              headline: hi ? 'छुड़ाने के बाद क्या होता है' : 'What happens after a rescue',
              detail: hi
                  ? 'बच्चे को बाल कल्याण समिति के सामने पेश किया जाता है, और उसके '
                      'स्कूल लौटने तथा परिवार की मदद की व्यवस्था बनाई जाती है। क़ानून '
                      'में छुड़ाए गए बच्चे के नाम पर पुनर्वास कोष में रक़म जमा करने का '
                      'प्रावधान भी है। यह बात इसलिए मायने रखती है कि शिकायत करने वाले '
                      'को अक्सर यह डर होता है कि बच्चा सड़क पर आ जाएगा — व्यवस्था उसी '
                      'के लिए है।'
                  : 'The child is produced before the Child Welfare Committee, '
                      'and arrangements are made for a return to school and '
                      'support for the family. The law also provides for a '
                      'sum to be deposited in a rehabilitation fund in the '
                      'rescued child\'s name. This matters because people who '
                      'report are often afraid the child will end up on the '
                      'street - the provision exists for exactly that.',
              tone: ToolTone.good,
              icon: Icons.volunteer_activism_outlined,
            ),
            const SourceNote(text: 'PENCIL portal', url: _pencilUrl),
          ],
        ],
      ],
    );
  }
}

// --- Bonded or forced labour ------------------------------------------

class BondedLabourPage extends StatefulWidget {
  const BondedLabourPage({super.key});

  @override
  State<BondedLabourPage> createState() => _BondedLabourPageState();
}

class _BondedLabourPageState extends State<BondedLabourPage> {
  final Set<int> _signs = {};

  static const _signsEn = [
    'Wages held back against a loan or an advance',
    'Not free to leave, or stopped from going home',
    'Made to work to pay off a debt - theirs or a relative\'s',
    'Identity papers, phone or money taken away',
    'Brought from another place and kept at the worksite',
    'The debt never seems to reduce, however long they work',
    'The family is working too, children included',
  ];
  static const _signsHi = [
    'उधार या पेशगी के बदले मज़दूरी रोकी जा रही है',
    'जाने की आज़ादी नहीं, या घर जाने से रोका जाता है',
    'क़र्ज़ चुकाने के बदले काम कराया जा रहा है — अपना या रिश्तेदार का',
    'पहचान के काग़ज़, फ़ोन या पैसा छीन लिया गया',
    'कहीं और से लाकर काम की जगह पर रखा गया है',
    'कितना भी काम करें, क़र्ज़ घटता ही नहीं',
    'पूरा परिवार काम कर रहा है, बच्चे भी',
  ];

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;
    final labels = hi ? _signsHi : _signsEn;

    return ToolScaffold(
      goal: 8,
      title: hi ? 'बंधुआ या ज़बरदस्ती मज़दूरी' : 'Bonded or forced labour',
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: scheme.error,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_open_outlined, color: scheme.onError, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hi
                      ? 'बंधुआ मज़दूरी भारत में ख़त्म कर दी गई है और वह अपराध है। '
                          'क़र्ज़ के बदले काम कराना क़ानून में नहीं टिकता — वह क़र्ज़ '
                          'ही रद्द माना जाता है। आपातकाल में 112, बच्चों के लिए 1098।'
                      : 'Bonded labour is abolished in India and it is a '
                          'crime. Work extracted against a debt does not '
                          'stand in law - the debt itself is treated as '
                          'extinguished. Emergency 112, for children 1098.',
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
        ToolQuestion(hi ? 'इनमें से क्या हो रहा है' : 'Which of these is happening'),
        for (var i = 0; i < labels.length; i++)
          SelectionTile(
            label: labels[i],
            selected: _signs.contains(i),
            onTap: () => setState(() {
              if (!_signs.remove(i)) _signs.add(i);
            }),
          ),
        if (_signs.isNotEmpty) ...[
          ToolAnswer(
            headline: hi
                ? 'यह बंधुआ मज़दूरी हो सकती है'
                : 'This may be bonded labour',
            detail: hi
                ? 'इनमें से एक भी बात सही हो तो यह जाँच के लायक़ है। क़ानून में सबसे '
                    'अहम बात यह है: छुड़ाए जाने पर वह क़र्ज़ ख़त्म माना जाता है, उसे '
                    'चुकाना नहीं पड़ता, और उसके बदले ज़मीन या सामान भी नहीं देना पड़ता। '
                    'छुड़ाना ज़िलाधिकारी और उपखंड अधिकारी का अधिकार है, और ज़िले में '
                    'सतर्कता समिति होती है।'
                : 'Any one of these is worth investigating. The most '
                    'important thing in the law is this: on release the debt '
                    'is treated as extinguished - it does not have to be '
                    'repaid, and no land or goods have to be given against '
                    'it. Release is within the District Magistrate\'s and '
                    'Sub-Divisional Magistrate\'s powers, and the district '
                    'has a Vigilance Committee.',
            tone: ToolTone.bad,
            icon: Icons.gavel_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'छुड़ाने और उसके बाद' : 'Release, and after it',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'ज़िलाधिकारी या उपखंड अधिकारी के कार्यालय में सूचना दें। किसी भी '
                        'व्यक्ति या संस्था की ओर से दी गई सूचना पर कार्रवाई हो सकती '
                        'है — ख़ुद मज़दूर का आना ज़रूरी नहीं।',
                    'पुलिस को भी बताएँ; किसी को कहीं बंद रखना अलग अपराध है।',
                    'छुड़ाने पर उपखंड अधिकारी "रिलीज़ सर्टिफ़िकेट" जारी करते हैं। यह '
                        'काग़ज़ सबसे ज़रूरी है — पुनर्वास की पूरी रक़म इसी पर मिलती है, '
                        'इसलिए उसे सँभालकर रखें।',
                    'तुरंत की सहायता के लिए हर ज़िले में कोष होता है, जिससे प्रति '
                        'मामले ₹$bondedImmediate तक की तात्कालिक मदद दी जा सकती है।',
                    'पुनर्वास सहायता श्रेणी के अनुसार ₹1 लाख, ₹2 लाख या ₹3 लाख तक '
                        'होती है, और यह बंधन सिद्ध होने पर मिलती है।',
                    'मुफ़्त वकील और क़ानूनी मदद के लिए ज़िला विधिक सेवा प्राधिकरण, '
                        '15100।',
                  ]
                : const [
                    'Report it at the District Magistrate\'s or '
                        'Sub-Divisional Magistrate\'s office. Action can '
                        'follow on information from any person or '
                        'organisation - the worker does not have to come '
                        'themselves.',
                    'Tell the police too; confining someone is a separate '
                        'offence.',
                    'On release the Sub-Divisional Magistrate issues a '
                        'release certificate. That paper matters most - the '
                        'whole rehabilitation amount turns on it, so keep it '
                        'safe.',
                    'Every district holds a fund for immediate help, from '
                        'which up to ₹$bondedImmediate per case can be given '
                        'at once.',
                    'Rehabilitation assistance runs to ₹1 lakh, ₹2 lakh or '
                        '₹3 lakh by category, paid on proof of bondage.',
                    'For a free lawyer and legal help, the District Legal '
                        'Services Authority, 15100.',
                  ],
          ),
          ToolDonts(
            heading: hi ? 'यह जान लें' : 'Things to be clear about',
            items: hi
                ? const [
                    'क़र्ज़ चुकाने के लिए काम करने का कोई समझौता क़ानून में नहीं '
                        'टिकता, चाहे अँगूठा लगा हो या काग़ज़ लिखा हो',
                    'पेशगी के बदले पहचान के काग़ज़, राशन कार्ड या फ़ोन रखना अवैध है',
                    'परिवार के किसी और के क़र्ज़ के बदले काम कराना भी बंधुआ मज़दूरी है',
                    'छुड़ाए जाने के बाद क़र्ज़ नहीं चुकाना पड़ता — यह क़ानून से रद्द हो '
                        'जाता है',
                    'सूचना देने वाले का नाम गोपनीय रखा जा सकता है',
                  ]
                : const [
                    'No agreement to work off a debt stands in law, thumb '
                        'impression or written paper notwithstanding',
                    'Holding identity papers, a ration card or a phone '
                        'against an advance is unlawful',
                    'Working against someone else in the family\'s debt is '
                        'bonded labour too',
                    'After release the debt does not have to be repaid - the '
                        'law extinguishes it',
                    'The name of whoever reports it can be kept '
                        'confidential',
                  ],
          ),
          const SourceNote(
              text: 'Rehabilitation of bonded labourers, Ministry of Labour',
              url: _labourUrl),
        ],
      ],
    );
  }
}

// --- Working outdoors in heat -----------------------------------------

class HeatAtWorkPage extends StatelessWidget {
  const HeatAtWorkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final service = context.watch<PlaceService>();
    final place = service.place;
    final now = service.forecast?.now;
    final risk = now == null ? null : heatRisk(now.feelsLikeC);

    return ToolScaffold(
      goal: 8,
      title: hi ? 'धूप में काम: आज का ख़तरा' : 'Working in the heat: today\'s risk',
      children: [
        if (now != null && risk != null) ...[
          ToolAnswer(
            headline: place == null
                ? (hi
                    ? 'महसूस हो रहा तापमान ${now.feelsLikeC.round()}°C'
                    : 'Feels like ${now.feelsLikeC.round()}°C')
                : (hi
                    ? '${place.name}: महसूस ${now.feelsLikeC.round()}°C'
                    : '${place.name}: feels like ${now.feelsLikeC.round()}°C'),
            detail: heatLine(risk, hi),
            tone: switch (risk) {
              HeatRisk.none => ToolTone.good,
              HeatRisk.warm => ToolTone.plain,
              HeatRisk.high => ToolTone.warn,
              HeatRisk.severe => ToolTone.bad,
            },
            icon: Icons.thermostat_outlined,
          ),
          if (service.forecast!.isStale)
            ToolNote(hi
                ? 'यह पिछली जानकारी है; ताज़ा मौसम के लिए इंटरनेट से जुड़ें।'
                : 'This is a last-known reading; connect to the internet for '
                    'the current weather.'),
        ] else
          ToolNote(hi
              ? 'अभी मौसम की जानकारी नहीं है। जगह चुनने या इंटरनेट से जुड़ने पर यहाँ '
                  'आज का ख़तरा दिखेगा। तब तक नीचे की बातें हर गर्म दिन पर लागू होती '
                  'हैं।'
              : 'No weather reading just now. Pick your place or connect to '
                  'the internet and today\'s risk shows here. Until then, '
                  'what follows applies on any hot day.'),
        const SizedBox(height: 14),
        Text(hi ? 'धूप में काम करते समय' : 'While working in the sun',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'प्यास लगने का इंतज़ार न करें। हर 15-20 मिनट में पानी पिएँ, थोड़ा-थोड़ा '
                      'और बार-बार। प्यास लगने का मतलब है कि पानी की कमी शुरू हो चुकी '
                      'है।',
                  'पानी में एक चुटकी नमक और थोड़ी चीनी, या नींबू-नमक-शिकंजी — पसीने '
                      'से नमक भी जाता है, सिर्फ़ पानी से वह पूरा नहीं होता।',
                  'दोपहर 12 से 3 के बीच का भारी काम, हो सके तो सुबह या शाम में '
                      'करें।',
                  'हर घंटे छाया में कुछ मिनट रुकें, और वह रुकना काम के बीच में '
                      'हिसाब से रखें, थक जाने के बाद नहीं।',
                  'सिर और गर्दन ढकें — गमछा, टोपी या भीगा कपड़ा। ढीले, हल्के रंग के '
                      'सूती कपड़े।',
                  'अकेले दूर जाकर काम न करें; साथ वाले एक-दूसरे पर नज़र रखें।',
                ]
              : const [
                  'Do not wait to feel thirsty. Drink every 15 to 20 minutes, '
                      'a little at a time, often. Thirst means the shortfall '
                      'has already started.',
                  'A pinch of salt and some sugar in the water, or lemon and '
                      'salt - sweat takes salt too, and water alone does not '
                      'replace it.',
                  'Move the heavy work out of noon to three, into the early '
                      'morning or evening if you can.',
                  'Stop in the shade for some minutes every hour, and plan '
                      'those stops into the work rather than taking them once '
                      'you are exhausted.',
                  'Cover your head and neck - a gamcha, a cap or a wet '
                      'cloth. Loose, light-coloured cotton.',
                  'Do not work far off alone; people working together should '
                      'keep an eye on each other.',
                ],
        ),
        ToolDonts(
          heading: hi
              ? 'ये लक्षण दिखें तो काम तुरंत बंद — यह आपात स्थिति है'
              : 'Stop work at these signs - this is an emergency',
          items: hi
              ? const [
                  'पसीना आना बंद हो जाए और चमड़ी सूखी-गरम हो जाए',
                  'उलझन, बहकी बातें, या बेहोशी',
                  'तेज़ सिरदर्द के साथ उलटी',
                  'मांसपेशियों में ऐंठन जो रुक न रही हो',
                  'साँस और धड़कन बहुत तेज़ हो जाना',
                ]
              : const [
                  'Sweating stops and the skin turns dry and hot',
                  'Confusion, saying strange things, or collapse',
                  'A severe headache with vomiting',
                  'Cramps that will not settle',
                  'Breathing and heartbeat going very fast',
                ],
        ),
        ToolAnswer(
          headline: hi
              ? 'ऐसा हो जाए तो: छाया, पानी, ठंडा — और 108'
              : 'If it happens: shade, water, cooling - and 108',
          detail: hi
              ? 'व्यक्ति को तुरंत छाया या ठंडी जगह ले जाएँ, कपड़े ढीले करें, शरीर पर '
                  'पानी डालें या भीगा कपड़ा रखें और हवा करें, और होश में हो तो '
                  'थोड़ा-थोड़ा पानी या ओआरएस पिलाएँ। बेहोश व्यक्ति को कुछ पिलाने की '
                  'कोशिश न करें। 108 बुलाएँ — गर्मी से लगा ताप-आघात (हीट स्ट्रोक) '
                  'जानलेवा होता है और यह घर पर ठीक होने वाली चीज़ नहीं है। लक्ष्य 3 में '
                  'गर्मी और ओआरएस की स्क्रीनें हैं।'
              : 'Get them into shade or somewhere cool at once, loosen the '
                  'clothing, pour water on the body or lay a wet cloth and '
                  'fan them, and if they are conscious give small sips of '
                  'water or ORS. Do not try to make an unconscious person '
                  'drink. Call 108 - heat stroke kills, and it is not '
                  'something to get over at home. Goal 3 has the heat and ORS '
                  'screens.',
          tone: ToolTone.bad,
          icon: Icons.emergency_outlined,
        ),
        const SizedBox(height: 14),
        Text(hi ? 'काम की जगह पर क्या बनता है' : 'What the workplace owes you',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'पीने का साफ़ पानी, काम की जगह पर और पास में',
                  'छाया या आराम करने की जगह',
                  'शौचालय, और महिलाओं के लिए अलग',
                  'प्राथमिक चिकित्सा का सामान',
                  'कई राज्यों की गर्मी कार्य योजना में दोपहर के घंटों में बाहरी काम '
                      'रोकने या समय बदलने के निर्देश होते हैं — ज़िला प्रशासन से पूछा '
                      'जा सकता है कि इस साल क्या निर्देश हैं',
                ]
              : const [
                  'Clean drinking water, at the worksite and close by',
                  'Shade, or somewhere to rest',
                  'A toilet, and a separate one for women',
                  'First aid supplies',
                  'Many states\' heat action plans direct outdoor work to '
                      'stop or shift away from the afternoon hours - the '
                      'district administration can be asked what this year\'s '
                      'directions are',
                ],
        ),
        ToolNote(hi
            ? 'ये सुविधाएँ न हों तो यह श्रम निरीक्षक के पास शिकायत का विषय है, और '
                'निर्माण मज़दूर हों तो कल्याण बोर्ड के पास भी — इसी लक्ष्य में '
                '"निर्माण श्रमिक कार्ड" देखें।'
            : 'Where these are missing it is a complaint to the labour '
                'inspector, and for a construction worker to the welfare '
                'board as well - see "Building worker card" in this goal.'),
      ],
    );
  }
}
