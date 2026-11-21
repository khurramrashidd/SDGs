import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Four screens about a woman's position at work, and one about building
/// her own.
///
/// The three legal ones share a shape: a right that exists on paper,
/// widely assumed not to exist, and enforced only when the woman asking
/// can name the committee, the section or the time limit. The fourth -
/// the self-help group - is the one that changes a household's position
/// without needing anybody's permission.

const _poshUrl = 'https://wcd.gov.in/';
const _shebox = 'https://shebox.wcd.gov.in/';
const _wageCodeUrl =
    'https://www.pib.gov.in/PressReleasePage.aspx?PRID=2194018';
const _nrlmUrl = 'https://aajeevika.gov.in/';
const _labourUrl = 'https://labour.gov.in/';

/// Time limits under the POSH Act. These are the numbers that decide
/// whether a complaint is heard at all, and nobody is told them.
const poshComplaintMonths = 3;
const poshExtensionMonths = 3;
const poshInquiryDays = 90;
const poshCommitteeMinWorkers = 10;

/// Maternity benefit, in weeks, under the maternity provisions now carried
/// in the Code on Social Security.
const maternityWeeksFirstTwo = 26;
const maternityWeeksThirdOnward = 12;
const maternityWeeksBeforeBirth = 8;
const maternityCrecheEmployees = 50;
const maternityMinEmployees = 10;

// --- Workplace harassment ---------------------------------------------

/// Where the woman works. It decides which body hears the complaint, and
/// this is the thing that stops most complaints before they start: a
/// woman working in a shop with four staff assumes there is nowhere to go.
enum PoshWorkplace { tenOrMore, fewerThanTen, againstEmployer, unorganised }

class PoshPage extends StatefulWidget {
  const PoshPage({super.key});

  @override
  State<PoshPage> createState() => _PoshPageState();
}

class _PoshPageState extends State<PoshPage> {
  PoshWorkplace? _where;
  int? _monthsAgo;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final late = _monthsAgo != null && _monthsAgo! > poshComplaintMonths;
    final veryLate =
        _monthsAgo != null && _monthsAgo! > poshComplaintMonths + poshExtensionMonths;

    Widget pick(PoshWorkplace w, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _where == w,
          onTap: () => setState(() => _where = w),
        );

    return ToolScaffold(
      goal: 5,
      title: hi
          ? 'काम की जगह पर उत्पीड़न की शिकायत'
          : 'A complaint about harassment at work',
      children: [
        ToolNote(hi
            ? 'यह क़ानून हर काम की जगह पर लागू होता है — दफ़्तर, दुकान, खेत, फ़ैक्ट्री, '
                'अस्पताल, स्कूल, घर में काम करने वाली महिलाएँ भी। कर्मचारी होना ज़रूरी '
                'नहीं: ठेके पर, दिहाड़ी पर, प्रशिक्षु या वहाँ किसी काम से आई महिला भी '
                'शिकायत कर सकती है।'
            : 'This law covers every workplace - an office, a shop, a field, '
                'a factory, a hospital, a school, and women working in '
                'households. You do not have to be an employee: a woman on '
                'contract, on daily wages, a trainee, or simply visiting for '
                'work can complain.'),
        ToolQuestion(hi ? 'काम की जगह कैसी है' : 'What sort of workplace'),
        pick(PoshWorkplace.tenOrMore, 'Ten or more people work there',
            'वहाँ दस या ज़्यादा लोग काम करते हैं'),
        pick(PoshWorkplace.fewerThanTen, 'Fewer than ten people',
            'दस से कम लोग'),
        pick(PoshWorkplace.againstEmployer,
            'The complaint is against the owner or employer himself',
            'शिकायत मालिक या नियोक्ता के ही ख़िलाफ़ है'),
        pick(PoshWorkplace.unorganised,
            'Daily wage, farm work, domestic work, no fixed employer',
            'दिहाड़ी, खेत का काम, घरेलू काम, कोई तय मालिक नहीं'),
        if (_where != null) ...[
          ToolAnswer(
            headline: _where == PoshWorkplace.tenOrMore
                ? (hi
                    ? 'आंतरिक समिति को शिकायत दें'
                    : 'The complaint goes to the Internal Committee')
                : (hi
                    ? 'स्थानीय समिति को शिकायत दें'
                    : 'The complaint goes to the Local Committee'),
            detail: _where == PoshWorkplace.tenOrMore
                ? (hi
                    ? 'दस या ज़्यादा कर्मचारियों वाली हर जगह पर आंतरिक समिति (Internal '
                        'Committee) बनाना क़ानूनन ज़रूरी है, और उसकी अध्यक्ष एक महिला '
                        'होती है, साथ में एक बाहरी सदस्य भी। "यहाँ कोई समिति नहीं है" '
                        'अपने आप में क़ानून का उल्लंघन है — और उस हालत में शिकायत सीधे '
                        'ज़िले की स्थानीय समिति को जाती है। समिति के सदस्यों के नाम '
                        'दफ़्तर में लगे होने चाहिए; माँगें।'
                    : 'Every workplace with ten or more employees is required '
                        'by law to have an Internal Committee, chaired by a '
                        'woman, with an external member on it as well. "There '
                        'is no committee here" is itself a breach of the law - '
                        'and in that case the complaint goes straight to the '
                        'district\'s Local Committee. The members\' names are '
                        'supposed to be displayed at the workplace; ask for '
                        'them.')
                : (hi
                    ? 'हर ज़िले में ज़िलाधिकारी स्थानीय समिति (Local Committee) बनाते '
                        'हैं, और वही उन सब महिलाओं की शिकायत सुनती है जिनकी जगह पर '
                        'आंतरिक समिति नहीं है, या जिनकी शिकायत मालिक के ही ख़िलाफ़ है। '
                        'दिहाड़ी, खेत, घरेलू काम — सब इसमें आते हैं। इसका पता ज़िला '
                        'महिला एवं बाल विकास कार्यालय या ज़िलाधिकारी कार्यालय से मिलता '
                        'है।'
                    : 'In every district the district officer constitutes a '
                        'Local Committee, and it hears the complaints of every '
                        'woman whose workplace has no Internal Committee, or '
                        'whose complaint is against the employer himself. '
                        'Daily wage work, farm work, domestic work - all of it '
                        'comes under this. The address comes from the district '
                        'women and child development office or the district '
                        'officer\'s office.'),
            tone: ToolTone.plain,
            icon: Icons.account_balance_outlined,
          ),
          ToolQuestion(hi ? 'यह कब हुआ' : 'When did it happen'),
          for (final m in const [1, 2, 3, 5, 12])
            SelectionTile(
              label: m == 1
                  ? (hi ? 'पिछले महीने के भीतर' : 'Within the last month')
                  : m == 12
                      ? (hi ? 'एक साल या उससे पहले' : 'A year ago or more')
                      : (hi ? '$m महीने पहले' : '$m months ago'),
              selected: _monthsAgo == m,
              onTap: () => setState(() => _monthsAgo = m),
            ),
          if (_monthsAgo != null) ...[
            ToolAnswer(
              headline: veryLate
                  ? (hi
                      ? 'समय सीमा निकल चुकी है — लेकिन रास्ता बंद नहीं'
                      : 'The time limit has passed - but not the road')
                  : late
                      ? (hi
                          ? 'तीन महीने बीत गए — बढ़ाने के लिए कारण लिखें'
                          : 'Past three months - ask for the extension')
                      : (hi ? 'समय सीमा के भीतर हैं' : 'You are within the limit'),
              detail: veryLate
                  ? (hi
                      ? 'इस क़ानून के तहत शिकायत तीन महीने के भीतर देनी होती है, और '
                          'समिति उचित कारण पर तीन महीने और बढ़ा सकती है। उससे ऊपर इस '
                          'रास्ते से मुश्किल है — लेकिन उत्पीड़न अपराध भी है, और '
                          'पुलिस में शिकायत (एफ़आईआर) की कोई ऐसी सीमा नहीं है। ज़िला '
                          'विधिक सेवा प्राधिकरण (15100) मुफ़्त में सलाह देता है कि इस '
                          'मामले में क्या बनता है।'
                      : 'Under this Act a complaint is to be made within '
                          'three months, and the committee may extend that by '
                          'three more for good reason. Beyond that this route '
                          'is hard - but harassment is also a criminal '
                          'offence, and a police complaint has no such limit. '
                          'The District Legal Services Authority (15100) '
                          'advises free on what applies in your case.')
                  : late
                      ? (hi
                          ? 'शिकायत तीन महीने के भीतर देनी होती है, लेकिन समिति उचित '
                              'कारण दर्ज करके तीन महीने और दे सकती है। इसलिए शिकायत में '
                              'साथ में एक पंक्ति लिखें कि देर क्यों हुई — डर, नौकरी जाने '
                              'का ख़तरा, या यह कि समिति के बारे में पता ही नहीं था। ये '
                              'सब उचित कारण माने जाते हैं।'
                          : 'The complaint is to be made within three months, '
                              'but the committee may allow three more if it '
                              'records a good reason. So include one line '
                              'saying why it was delayed - fear, the risk to '
                              'the job, or simply not knowing the committee '
                              'existed. All of these count as good reasons.')
                      : (hi
                          ? 'शिकायत लिखित में देनी होती है, और समिति को जाँच '
                              '$poshInquiryDays दिन में पूरी करनी होती है। लिखने में मदद '
                              'चाहिए तो समिति को ही मदद करनी होती है।'
                          : 'The complaint has to be in writing, and the '
                              'committee must complete its inquiry within '
                              '$poshInquiryDays days. If you need help writing '
                              'it, the committee itself is required to help.'),
              tone: veryLate
                  ? ToolTone.warn
                  : (late ? ToolTone.warn : ToolTone.good),
              icon: Icons.schedule,
            ),
            const SizedBox(height: 14),
            Text(hi ? 'शिकायत में यह लिखें' : 'What to put in the complaint',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800)),
            ToolSteps(
              steps: hi
                  ? const [
                      'क्या हुआ — जो हुआ वही, अपने शब्दों में। जोड़-घटाव की ज़रूरत '
                          'नहीं।',
                      'कब और कहाँ हुआ। एक से ज़्यादा बार हुआ हो तो हर बार की तारीख़ '
                          'जहाँ तक याद हो।',
                      'किसने किया — नाम और पद।',
                      'कोई देखने वाला था तो उसका नाम। न हो तो भी शिकायत चलती है।',
                      'सबूत जो आपके पास हैं — संदेश, चैट, कॉल का रिकॉर्ड, ड्यूटी '
                          'रजिस्टर।',
                      'आप क्या चाहती हैं — जाँच, तबादला, या कि वह आपसे दूर रखा जाए।',
                    ]
                  : const [
                      'What happened - just what happened, in your own '
                          'words. Nothing needs adding or softening.',
                      'When and where. If it happened more than once, the '
                          'date of each time as far as you remember.',
                      'Who did it - name and position.',
                      'Anyone who saw it, by name. The complaint works '
                          'without a witness too.',
                      'Any evidence you have - messages, chats, call '
                          'records, the duty register.',
                      'What you are asking for - an inquiry, a transfer, or '
                          'that he be kept away from you.',
                    ],
            ),
            ToolDonts(
              heading: hi
                  ? 'जो नियोक्ता नहीं कर सकता'
                  : 'What the employer may not do',
              items: hi
                  ? const [
                      'शिकायत करने पर नौकरी से निकालना, तबादला करना या वेतन रोकना — '
                          'यह बदले की कार्रवाई है और क़ानून में मना है',
                      'आपका नाम या शिकायत की बात दूसरों को बताना — कार्यवाही गोपनीय '
                          'रहती है',
                      'पैसे का समझौता करा देना और उसे ही जाँच का नतीजा बता देना',
                      'यह कहना कि "पहले अंदर ही सुलझा लो" और शिकायत लेने से मना करना',
                    ]
                  : const [
                      'Dismissing you, transferring you or stopping your pay '
                          'because you complained - that is retaliation, and '
                          'the law forbids it',
                      'Telling others your name or what the complaint says - '
                          'the proceedings are confidential',
                      'Settling it for money and calling that the outcome of '
                          'the inquiry',
                      'Saying "sort it out internally first" and refusing to '
                          'accept the complaint',
                    ],
            ),
            ToolNote(hi
                ? 'शिकायत ऑनलाइन भी दी जा सकती है — महिला एवं बाल विकास मंत्रालय का '
                    'SHe-Box पोर्टल सरकारी और निजी, दोनों जगहों के लिए है। महिला '
                    'हेल्पलाइन 181। वकील की मदद मुफ़्त चाहिए तो 15100।'
                : 'The complaint can also be filed online - the Ministry of '
                    'Women and Child Development\'s SHe-Box portal covers both '
                    'government and private workplaces. Women\'s helpline 181. '
                    'For free legal help, 15100.'),
            const SourceNote(
                text: 'SHe-Box - online complaints', url: _shebox),
            const SourceNote(
                text: 'Ministry of Women and Child Development',
                url: _poshUrl),
          ],
        ],
      ],
    );
  }
}

// --- Maternity leave --------------------------------------------------

class MaternityPage extends StatefulWidget {
  const MaternityPage({super.key});

  @override
  State<MaternityPage> createState() => _MaternityPageState();
}

class _MaternityPageState extends State<MaternityPage> {
  int? _childNumber;
  int? _staffCount;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final weeks = _childNumber == null
        ? null
        : (_childNumber! <= 2
            ? maternityWeeksFirstTwo
            : maternityWeeksThirdOnward);
    final covered = _staffCount == null || _staffCount! >= maternityMinEmployees;

    return ToolScaffold(
      goal: 5,
      title: hi ? 'मातृत्व अवकाश: हफ़्ते और वेतन' : 'Maternity leave: weeks and pay',
      children: [
        ToolNote(hi
            ? 'मातृत्व अवकाश छुट्टी नहीं है जो मालिक की मेहरबानी से मिले — यह पूरे '
                'वेतन के साथ क़ानूनी हक़ है, और इस दौरान नौकरी से निकाला नहीं जा '
                'सकता। ये प्रावधान अब सामाजिक सुरक्षा संहिता में हैं, जो 21 नवंबर 2025 '
                'से लागू है।'
            : 'Maternity leave is not time off granted as a favour - it is a '
                'legal entitlement with full pay, and you cannot be dismissed '
                'during it. These provisions now sit in the Code on Social '
                'Security, in force since 21 November 2025.'),
        ToolQuestion(hi ? 'यह कौन सा बच्चा है' : 'Which child is this'),
        for (final n in const [1, 2, 3])
          SelectionTile(
            label: n == 1
                ? (hi ? 'पहला' : 'First')
                : n == 2
                    ? (hi ? 'दूसरा' : 'Second')
                    : (hi ? 'तीसरा या उसके बाद' : 'Third or later'),
            selected: _childNumber == n,
            onTap: () => setState(() => _childNumber = n),
          ),
        ToolQuestion(hi ? 'जहाँ काम करती हैं वहाँ कितने लोग' : 'How many people work there'),
        SelectionTile(
          label: hi ? 'दस या ज़्यादा' : 'Ten or more',
          selected: _staffCount == 10,
          onTap: () => setState(() => _staffCount = 10),
        ),
        SelectionTile(
          label: hi ? 'दस से कम' : 'Fewer than ten',
          selected: _staffCount == 1,
          onTap: () => setState(() => _staffCount = 1),
        ),
        if (weeks != null) ...[
          if (covered)
            ToolAnswer(
              headline: hi
                  ? '$weeks हफ़्ते, पूरे वेतन के साथ'
                  : '$weeks weeks, on full pay',
              detail: _childNumber! <= 2
                  ? (hi
                      ? 'पहले दो बच्चों के लिए $maternityWeeksFirstTwo हफ़्ते मिलते '
                          'हैं, जिनमें से अधिकतम $maternityWeeksBeforeBirth हफ़्ते प्रसव '
                          'से पहले लिए जा सकते हैं। पूरा वेतन मिलता है, और इस दौरान '
                          'नौकरी से निकालना मना है। गोद लेने वाली और सरोगेसी से माँ बनने '
                          'वाली महिला को 12 हफ़्ते मिलते हैं।'
                      : 'For the first two children it is '
                          '$maternityWeeksFirstTwo weeks, of which at most '
                          '$maternityWeeksBeforeBirth may be taken before the '
                          'birth. The pay is full, and dismissal during this '
                          'period is prohibited. A mother who adopts, and a '
                          'commissioning mother, get 12 weeks.')
                  : (hi
                      ? 'तीसरे और उसके बाद के बच्चे के लिए '
                          '$maternityWeeksThirdOnward हफ़्ते मिलते हैं, पूरे वेतन के '
                          'साथ। वेतन और नौकरी की सुरक्षा इसमें भी वैसी ही है।'
                      : 'For a third child and after it is '
                          '$maternityWeeksThirdOnward weeks, on full pay. The '
                          'pay and the protection from dismissal are the same.'),
              tone: ToolTone.good,
              icon: Icons.pregnant_woman_outlined,
            )
          else
            ToolAnswer(
              headline: hi
                  ? 'दस से कम लोग — यह क़ानून लागू नहीं होता'
                  : 'Fewer than ten - this law does not apply',
              detail: hi
                  ? 'मातृत्व लाभ के ये प्रावधान दस या ज़्यादा कर्मचारियों वाली जगहों पर '
                      'लागू होते हैं। उससे छोटी जगह पर यह हक़ नहीं बनता — लेकिन दो '
                      'चीज़ें फिर भी मिलती हैं: प्रधानमंत्री मातृ वंदना योजना का पैसा, जो '
                      'नौकरी से जुड़ा नहीं है, और सरकारी अस्पताल में मुफ़्त प्रसव। कई '
                      'राज्यों के निर्माण श्रमिक कल्याण बोर्ड पंजीकृत महिला मज़दूरों को '
                      'मातृत्व सहायता देते हैं — अगर आप या आपके पति निर्माण का काम करते '
                      'हैं तो यह ज़रूर पूछें।'
                  : 'These maternity benefit provisions apply to '
                      'establishments with ten or more employees. Below that '
                      'the entitlement does not arise - but two things still '
                      'do: the Pradhan Mantri Matru Vandana Yojana money, '
                      'which is not tied to a job, and a free delivery at a '
                      'government hospital. Many states\' construction worker '
                      'welfare boards pay maternity assistance to registered '
                      'women workers - worth asking about if you or your '
                      'husband do construction work.',
              tone: ToolTone.warn,
              icon: Icons.info_outline,
            ),
          if (covered) ...[
            const SizedBox(height: 14),
            Text(hi ? 'इनका भी हक़ है' : 'These come with it',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800)),
            ToolSteps(
              numbered: false,
              steps: hi
                  ? const [
                      'पूरा वेतन, छुट्टी के पूरे समय का',
                      'इस दौरान नौकरी से नहीं निकाला जा सकता, और शर्तें ख़राब नहीं की '
                          'जा सकतीं',
                      'गर्भपात या चिकित्सकीय कारण से अलग छुट्टी का भी प्रावधान है',
                      'पचास या ज़्यादा कर्मचारियों वाली जगह पर शिशु-गृह (क्रेच) होना '
                          'ज़रूरी है, और दिन में कुछ बार बच्चे के पास जाने की छूट',
                      'काम की प्रकृति ऐसी हो तो अवकाश के बाद घर से काम की व्यवस्था पर '
                          'बात हो सकती है',
                    ]
                  : const [
                      'Full pay, for the whole period of leave',
                      'No dismissal during it, and no worsening of your '
                          'terms',
                      'Separate leave is also provided for a miscarriage or '
                          'on medical grounds',
                      'A creche is required where fifty or more people work, '
                          'with permitted visits to the child during the day',
                      'Where the nature of the work allows, working from '
                          'home after the leave can be discussed',
                    ],
            ),
            ToolAnswer(
              headline: hi ? 'मना कर दिया जाए तो' : 'If it is refused',
              detail: hi
                  ? 'पहले लिखित में अर्ज़ी दें और पावती लें — इतने से ही बहुत बार बात '
                      'बन जाती है, क्योंकि लिखित मना करना मुश्किल है। न बने तो क्षेत्र के '
                      'श्रम निरीक्षक या सहायक श्रम आयुक्त के पास शिकायत जाती है, और '
                      'यह मुफ़्त है। निकाल दिया गया हो तो वह अलग और बड़ी बात है — '
                      'उसमें ज़िला विधिक सेवा प्राधिकरण (15100) से मुफ़्त वकील मिलता है।'
                  : 'First apply in writing and take an acknowledgement - that '
                      'alone often settles it, because refusing in writing is '
                      'hard. If it does not, the complaint goes to the area '
                      'labour inspector or assistant labour commissioner, and '
                      'it is free. If you have been dismissed, that is a '
                      'separate and more serious matter - the District Legal '
                      'Services Authority (15100) provides a lawyer free.',
              tone: ToolTone.warn,
              icon: Icons.report_outlined,
            ),
          ],
          const SourceNote(
              text: 'Ministry of Labour and Employment', url: _labourUrl),
        ],
      ],
    );
  }
}

// --- Equal pay --------------------------------------------------------

class EqualPayPage extends StatefulWidget {
  const EqualPayPage({super.key});

  @override
  State<EqualPayPage> createState() => _EqualPayPageState();
}

class _EqualPayPageState extends State<EqualPayPage> {
  final _herWage = TextEditingController();
  final _hisWage = TextEditingController();
  bool _sameWork = true;

  @override
  void dispose() {
    _herWage.dispose();
    _hisWage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final her = double.tryParse(_herWage.text.trim());
    final his = double.tryParse(_hisWage.text.trim());
    final gap = (her != null && his != null && her > 0 && his > 0)
        ? his - her
        : null;

    return ToolScaffold(
      goal: 5,
      title: hi ? 'बराबर काम, बराबर मज़दूरी' : 'Same work, same wage',
      children: [
        ToolNote(hi
            ? 'एक ही काम के लिए औरत को कम और मर्द को ज़्यादा देना क़ानूनन मना है। '
                'पुराना समान पारिश्रमिक अधिनियम अब वेतन संहिता में समा गया है, जो '
                '21 नवंबर 2025 से लागू है, और उसमें एक ही या वैसे ही काम के लिए लिंग '
                'के आधार पर मज़दूरी में भेद करना मना है — भर्ती में भी।'
            : 'Paying a woman less than a man for the same work is '
                'prohibited. The old Equal Remuneration Act now sits inside '
                'the Code on Wages, in force since 21 November 2025, which '
                'forbids discrimination in wages on the ground of sex for the '
                'same or similar work - and in recruitment too.'),
        ToolQuestion(hi ? 'दिन की मज़दूरी' : 'The daily wage'),
        ToolNumber(
          controller: _herWage,
          label: hi ? 'औरत को कितना मिलता है' : 'What the woman is paid',
          maxDigits: 6,
          icon: Icons.woman_outlined,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolNumber(
          controller: _hisWage,
          label: hi ? 'मर्द को कितना मिलता है' : 'What the man is paid',
          maxDigits: 6,
          icon: Icons.man_outlined,
          onChanged: (_) => setState(() {}),
        ),
        SwitchListTile(
          value: _sameWork,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'दोनों वही या वैसा ही काम करते हैं'
              : 'Both do the same or similar work'),
          subtitle: Text(
            hi
                ? 'वही हुनर, वही मेहनत, वही ज़िम्मेदारी'
                : 'The same skill, effort and responsibility',
            style: const TextStyle(fontSize: 12),
          ),
          onChanged: (v) => setState(() => _sameWork = v),
        ),
        if (gap != null) ...[
          if (gap > 0 && _sameWork)
            ToolAnswer(
              headline: hi
                  ? 'दिन का ₹${gap.round()} का अंतर — यह क़ानूनन मना है'
                  : '₹${gap.round()} a day less - and that is unlawful',
              detail: hi
                  ? 'महीने के 25 दिन काम मानें तो यह ₹${(gap * 25).round()} महीने का '
                      'और ₹${(gap * 25 * 12).round()} साल का अंतर बनता है। एक ही काम '
                      'के लिए यह अंतर रखना वेतन संहिता के तहत मना है। शिकायत क्षेत्र के '
                      'श्रम निरीक्षक या सहायक श्रम आयुक्त के पास जाती है, और उसकी कोई '
                      'फ़ीस नहीं है।'
                  : 'At 25 working days that is ₹${(gap * 25).round()} a month '
                      'and ₹${(gap * 25 * 12).round()} a year. Maintaining that '
                      'difference for the same work is prohibited under the '
                      'Code on Wages. The complaint goes to the area labour '
                      'inspector or assistant labour commissioner, and there '
                      'is no fee for it.',
              tone: ToolTone.bad,
              icon: Icons.balance_outlined,
            )
          else if (gap > 0 && !_sameWork)
            ToolAnswer(
              headline: hi
                  ? 'पहले यह तय करें कि काम वही है या नहीं'
                  : 'First settle whether the work is the same',
              detail: hi
                  ? 'क़ानून एक ही या वैसे ही काम पर लागू होता है — यानी वही हुनर, वही '
                      'मेहनत और वही ज़िम्मेदारी। काम का नाम अलग होना फ़र्क़ नहीं डालता; '
                      'असल में क्या किया जाता है, वही देखा जाता है। अगर दोनों वही काम '
                      'कर रहे हैं तो नाम बदलकर कम देना भी इसी के दायरे में आता है।'
                  : 'The law applies to the same or similar work - the same '
                      'skill, effort and responsibility. The job title makes '
                      'no difference; what is actually done is what counts. If '
                      'both are in fact doing the same work, paying less under '
                      'a different title falls within this too.',
              tone: ToolTone.warn,
              icon: Icons.help_outline,
            )
          else
            ToolAnswer(
              headline: hi ? 'कोई अंतर नहीं दिख रहा' : 'No gap showing here',
              detail: hi
                  ? 'तब भी एक बात जाँच लें: जो मिल रहा है, वह आपके राज्य की न्यूनतम '
                      'मज़दूरी से कम तो नहीं? न्यूनतम मज़दूरी हर काम और हर राज्य के लिए '
                      'अलग होती है और श्रम विभाग उसे छापता है। उससे कम देना भी अपराध '
                      'है।'
                  : 'Even so, check one thing: is what is being paid below '
                      'your state\'s minimum wage? The minimum wage differs by '
                      'trade and by state and the labour department publishes '
                      'it. Paying below it is also an offence.',
              tone: ToolTone.plain,
              icon: Icons.check_circle_outline,
            ),
          const SizedBox(height: 14),
          Text(hi ? 'शिकायत से पहले' : 'Before complaining',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const ToolChecklist(
            storageKey: 'equal_pay_v1',
            items: [
              CheckItem('note', 'Write down the dates, the work done and what '
                  'was paid, each day',
                  'हर दिन की तारीख़, किया गया काम और मिली मज़दूरी लिखती रहें',
                  noteEn: 'A daily note in your own hand is accepted as '
                      'evidence. It costs nothing and it is the strongest '
                      'thing you can build.',
                  noteHi: 'अपने हाथ से रोज़ लिखी पर्ची सबूत मानी जाती है। इसमें पैसा '
                      'नहीं लगता और यही सबसे मज़बूत चीज़ है जो आप बना सकती हैं।'),
              CheckItem('others', 'Find out whether other women there are '
                  'paid the same as you',
                  'पता करें कि वहाँ की दूसरी औरतों को भी इतना ही मिलता है'),
              CheckItem('minwage', 'Look up your state\'s minimum wage for '
                  'this work', 'इस काम के लिए अपने राज्य की न्यूनतम मज़दूरी देखें'),
              CheckItem('together', 'A complaint from several women together '
                  'is harder to ignore, and harder to punish',
                  'कई औरतों की एक साथ शिकायत को नज़रअंदाज़ करना भी मुश्किल है और '
                      'सज़ा देना भी'),
              CheckItem('help', 'Free legal help on 15100, women\'s helpline '
                  '181', 'मुफ़्त क़ानूनी मदद 15100, महिला हेल्पलाइन 181'),
            ],
          ),
          const SourceNote(
              text: 'The labour codes, Press Information Bureau',
              url: _wageCodeUrl),
        ],
      ],
    );
  }
}

// --- Self-help group --------------------------------------------------

class ShgPage extends StatelessWidget {
  const ShgPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 5,
      title: hi ? 'स्वयं सहायता समूह से जुड़ें' : 'Joining a self-help group',
      children: [
        ToolNote(hi
            ? 'स्वयं सहायता समूह उन थोड़ी चीज़ों में से है जो किसी की मंज़ूरी के बिना '
                'घर की हालत बदल देती है। दस से बीस औरतें, हर हफ़्ते थोड़ी-थोड़ी बचत, '
                'और कुछ महीनों बाद बैंक से जुड़ाव — जिसके बाद साहूकार के पास जाने की '
                'ज़रूरत ही नहीं रहती।'
            : 'A self-help group is one of the few things that changes a '
                'household\'s position without needing anyone\'s permission. '
                'Ten to twenty women, a small saving every week, and after a '
                'few months a bank linkage - after which there is no need to '
                'go to a moneylender at all.'),
        const SizedBox(height: 10),
        Text(hi ? 'समूह बनता कैसे है' : 'How a group comes about',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'दस से बीस औरतें, एक ही गाँव या मोहल्ले की, जो एक-दूसरे को जानती '
                      'हों। एक ही घर से एक ही सदस्य।',
                  'हफ़्ते या महीने की एक तय बचत — दस रुपये से भी शुरू होती है। रक़म '
                      'छोटी होना कमज़ोरी नहीं है; नियम से जमा होना ताक़त है।',
                  'समूह का नाम, एक अध्यक्ष, एक कोषाध्यक्ष, और एक रजिस्टर जिसमें हर '
                      'बैठक और हर रुपया दर्ज हो।',
                  'बैंक में समूह के नाम से खाता — किसी एक के नाम से नहीं। खाता खोलने '
                      'से बैंक मना नहीं कर सकता।',
                  'छह महीने नियम से बचत और आपसी लेन-देन चलने के बाद बैंक से जुड़ाव '
                      'होता है, और समूह को उसकी बचत से कई गुना ऋण मिलता है।',
                  'गाँव के संगठन (ग्राम संगठन) से जुड़ें — वहाँ से चक्रीय निधि और '
                      'सामुदायिक निवेश निधि मिलती है।',
                ]
              : const [
                  'Ten to twenty women from the same village or '
                      'neighbourhood who know one another. One member per '
                      'household.',
                  'A fixed saving every week or month - it starts at ten '
                      'rupees. A small amount is not a weakness; saving '
                      'regularly is the strength.',
                  'A name for the group, a president, a treasurer, and a '
                      'register recording every meeting and every rupee.',
                  'A bank account in the group\'s name - not in any one '
                      'person\'s. A bank cannot refuse to open it.',
                  'After about six months of regular saving and internal '
                      'lending, the bank linkage follows, and the group gets '
                      'credit of several times its savings.',
                  'Join the village organisation - that is where the '
                      'revolving fund and the community investment fund come '
                      'from.',
                ],
        ),
        const SizedBox(height: 14),
        ToolAnswer(
          headline: hi ? 'शुरू कहाँ से करें' : 'Where to start',
          detail: hi
              ? 'गाँव में पहले से समूह हैं — आशा, आँगनवाड़ी कार्यकर्ता या ग्राम पंचायत '
                  'सचिव बता देंगे कि किसमें जगह है। नया बनाना हो तो राष्ट्रीय आजीविका '
                  'मिशन की ब्लॉक इकाई या समूह सखी से मिलें; उनका काम यही है और इसमें '
                  'कोई फ़ीस नहीं लगती। किसी बिचौलिये को पैसा देने की ज़रूरत नहीं है।'
              : 'There are already groups in the village - the ASHA, the '
                  'anganwadi worker or the panchayat secretary will know which '
                  'has room. To start a new one, meet the block unit of the '
                  'National Rural Livelihoods Mission or the community '
                  'resource person; this is their job and there is no fee for '
                  'it. Nobody needs to be paid to arrange it.',
          tone: ToolTone.good,
          icon: Icons.groups_2_outlined,
        ),
        const SizedBox(height: 14),
        Text(hi ? 'समूह से क्या मिलता है' : 'What a group gets you',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        ToolLine(
            hi ? 'अपनी बचत, अपने नाम पर' : 'Savings of your own, in your name',
            hi ? 'पहले महीने से' : 'From the first month',
            strong: true),
        ToolLine(hi ? 'ज़रूरत पर समूह से उधार' : 'A loan from the group at need',
            hi ? 'कुछ ही हफ़्तों में' : 'Within weeks'),
        ToolLine(hi ? 'बैंक से ऋण, कम ब्याज पर' : 'A bank loan, at low interest',
            hi ? 'लगभग छह महीने बाद' : 'After about six months'),
        ToolLine(
            hi ? 'आजीविका के लिए सहायता और प्रशिक्षण' : 'Livelihood support and training',
            hi ? 'मिशन के ज़रिये' : 'Through the mission'),
        const SizedBox(height: 10),
        ToolDonts(
          heading: hi ? 'समूह में यह न होने दें' : 'Do not let these happen',
          items: hi
              ? const [
                  'रजिस्टर किसी एक के घर पर न रहे, और हिसाब सब सदस्यों के सामने '
                      'पढ़ा जाए — समूह टूटते इसी वजह से हैं',
                  'बैंक खाता किसी एक सदस्य या किसी बाहरी व्यक्ति के नाम पर न हो',
                  'समूह बनवाने या ऋण दिलाने के नाम पर किसी को पैसा न दें; यह काम '
                      'मुफ़्त है',
                  'समूह का ऋण किसी एक सदस्य या उसके पति के काम में पूरा न लगाया जाए',
                  'बिना बैठक और बिना दर्ज किए कोई लेन-देन न हो',
                ]
              : const [
                  'The register must not live in one member\'s house, and the '
                      'accounts must be read out in front of everyone - this '
                      'is what breaks groups',
                  'The bank account must not be in one member\'s name, or in '
                      'an outsider\'s',
                  'Pay nobody to form the group or to arrange a loan; this '
                      'is free',
                  'The group\'s loan must not all go into one member\'s, or '
                      'her husband\'s, business',
                  'No transaction without a meeting and without it being '
                      'recorded',
                ],
        ),
        const SourceNote(
            text: 'Deendayal Antyodaya Yojana - National Rural Livelihoods '
                'Mission',
            url: _nrlmUrl),
      ],
    );
  }
}
