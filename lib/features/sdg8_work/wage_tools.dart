import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Six screens about money a worker is owed and has not been paid.
///
/// The pattern across all of them is that the law is unusually clear and
/// the worker unusually unlikely to know it. Overtime at twice the
/// ordinary rate, gratuity after five years, notice pay on dismissal -
/// these are not grey areas. What is missing is the arithmetic and the
/// name of the office, so that is what these screens supply.

const _labourUrl = 'https://labour.gov.in/';
const _epfoUrl = 'https://www.epfindia.gov.in/';
const _samadhanUrl = 'https://samadhan.labour.gov.in/';
const _wageCodeUrl =
    'https://www.pib.gov.in/PressReleasePage.aspx?PRID=2194018';

/// Overtime is paid at not less than twice the ordinary rate of wages.
const overtimeMultiplier = 2;

/// Gratuity: fifteen days' wages for every completed year, reckoned on a
/// 26-day month, payable after five years of continuous service.
const gratuityDaysPerYear = 15;
const gratuityMonthDays = 26;
const gratuityMinYears = 5;

// --- Wages not paid ---------------------------------------------------

enum WageEmployer { shopOrFactory, contractor, farmLandowner, household, govtScheme }

class WagesNotPaidPage extends StatefulWidget {
  const WagesNotPaidPage({super.key});

  @override
  State<WagesNotPaidPage> createState() => _WagesNotPaidPageState();
}

class _WagesNotPaidPageState extends State<WagesNotPaidPage> {
  WageEmployer? _who;
  final _days = TextEditingController();
  final _rate = TextEditingController();

  @override
  void dispose() {
    _days.dispose();
    _rate.dispose();
    super.dispose();
  }

  String _draft(bool hi, double? owed) {
    final amount = owed == null ? '______' : owed.round().toString();
    return hi
        ? 'सेवा में,\nसहायक श्रम आयुक्त / श्रम निरीक्षक\n______ (क्षेत्र)\n\n'
            'विषय: मज़दूरी का भुगतान न होने की शिकायत\n\n'
            'महोदय,\n\nमेरा नाम ______ है, पता ______। मैंने ______ (नियोक्ता या '
            'ठेकेदार का नाम और पता) के पास ______ से ______ तक काम किया।\n\n'
            'मेरी मज़दूरी ₹______ प्रतिदिन तय थी और मैंने ${_days.text.trim().isEmpty ? '______' : _days.text.trim()} '
            'दिन काम किया, जिसके अनुसार ₹$amount बनता है। यह रक़म आज तक नहीं दी '
            'गई। मैंने ______ (तारीख़) को माँग भी की।\n\n'
            'कृपया मज़दूरी भुगतान अधिनियम / वेतन संहिता के अंतर्गत आवश्यक कार्रवाई '
            'कर भुगतान कराया जाए।\n\n'
            'दिनांक: ______\nनाम: ______\nमोबाइल: ______\nहस्ताक्षर'
        : 'To,\nThe Assistant Labour Commissioner / Labour Inspector\n'
            '______ (area)\n\n'
            'Subject: Complaint of non-payment of wages\n\n'
            'Sir/Madam,\n\nMy name is ______, resident of ______. I worked '
            'for ______ (name and address of the employer or contractor) '
            'from ______ to ______.\n\n'
            'My wage was fixed at ₹______ a day and I worked '
            '${_days.text.trim().isEmpty ? '______' : _days.text.trim()} days, '
            'which comes to ₹$amount. That amount has not been paid to date. '
            'I also asked for it on ______ (date).\n\n'
            'I request the necessary action under the wage payment law to '
            'have the amount paid.\n\n'
            'Date: ______\nName: ______\nMobile: ______\nSignature';
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final days = double.tryParse(_days.text.trim());
    final rate = double.tryParse(_rate.text.trim());
    final owed = (days != null && rate != null && days > 0 && rate > 0)
        ? days * rate
        : null;

    Widget pick(WageEmployer w, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _who == w,
          onTap: () => setState(() => _who = w),
        );

    return ToolScaffold(
      goal: 8,
      title: hi ? 'मज़दूरी नहीं मिली' : 'Wages not paid',
      children: [
        ToolNote(hi
            ? 'मज़दूरी रोकना क़ानूनन अपराध है, और इसके लिए अदालत जाने की ज़रूरत नहीं '
                'होती — श्रम विभाग के पास शिकायत करने पर वह ख़ुद वसूली करा सकता है, '
                'और इसमें कोई फ़ीस नहीं लगती। लिखित काग़ज़ न हो तब भी शिकायत चलती है।'
            : 'Withholding wages is an offence, and it does not need a court '
                'case - a complaint to the labour department can have the '
                'money recovered, and there is no fee. The complaint works '
                'even with no written contract.'),
        ToolQuestion(hi ? 'किसके लिए काम किया' : 'Who did you work for'),
        pick(WageEmployer.shopOrFactory, 'A shop, factory or establishment',
            'दुकान, फ़ैक्ट्री या प्रतिष्ठान'),
        pick(WageEmployer.contractor, 'A contractor or a labour thekedar',
            'ठेकेदार'),
        pick(WageEmployer.farmLandowner, 'A landowner, farm work',
            'ज़मींदार, खेत का काम'),
        pick(WageEmployer.household, 'A household, domestic work',
            'घर में काम'),
        pick(WageEmployer.govtScheme, 'A government scheme - MGNREGA or '
            'similar', 'सरकारी योजना — मनरेगा या वैसी'),
        if (_who == WageEmployer.govtScheme)
          ToolAnswer(
            headline: hi
                ? 'मनरेगा का रास्ता अलग और तेज़ है'
                : 'MGNREGA has its own, faster route',
            detail: hi
                ? 'मनरेगा में मज़दूरी काम ख़त्म होने के 15 दिन के भीतर देनी होती है, '
                    'और देर होने पर मुआवज़ा बनता है। इसकी शिकायत कार्यक्रम अधिकारी और '
                    'लोकपाल के पास जाती है, श्रम विभाग के पास नहीं। लक्ष्य 1 में '
                    '"मनरेगा: काम और मज़दूरी का हक़" वाली स्क्रीन इसी के लिए है।'
                : 'Under MGNREGA wages are due within 15 days of the work, '
                    'and a delay carries compensation. That complaint goes to '
                    'the programme officer and the ombudsman, not the labour '
                    'department. The screen "MGNREGA: work and wages" under '
                    'goal 1 is for exactly this.',
            tone: ToolTone.plain,
            icon: Icons.alt_route_outlined,
          )
        else if (_who != null) ...[
          if (_who == WageEmployer.contractor)
            ToolNote(hi
                ? 'ठेकेदार के ज़रिये काम किया हो तो यह जान लेना ज़रूरी है: ठेकेदार '
                    'भुगतान न करे तो मुख्य नियोक्ता (principal employer) — यानी जिस '
                    'कंपनी या व्यक्ति का काम था — उसकी ज़िम्मेदारी बनती है। इसलिए '
                    'शिकायत में दोनों के नाम लिखें, सिर्फ़ ठेकेदार का नहीं। यह अकेली '
                    'बात बहुत मामलों का रुख़ बदल देती है।'
                : 'If you worked through a contractor, one thing matters: '
                    'where the contractor does not pay, the principal '
                    'employer - the company or person whose work it was - '
                    'becomes liable. So name both in the complaint, not just '
                    'the contractor. That one point turns a great many '
                    'cases.'),
          ToolQuestion(hi ? 'कितना बनता है' : 'How much is owed'),
          Row(
            children: [
              Expanded(
                child: ToolNumber(
                  controller: _days,
                  label: hi ? 'कितने दिन काम' : 'Days worked',
                  decimal: true,
                  maxDigits: 4,
                  icon: Icons.calendar_today_outlined,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ToolNumber(
                  controller: _rate,
                  label: hi ? 'दिन की मज़दूरी (₹)' : 'Daily wage (₹)',
                  decimal: true,
                  maxDigits: 6,
                  icon: Icons.currency_rupee,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          if (owed != null)
            ToolAnswer(
              headline: hi ? '₹${owed.round()} बनता है' : '₹${owed.round()} is owed',
              detail: hi
                  ? 'शिकायत में यही संख्या लिखें, और साथ में काम की तारीख़ें। एक बात '
                      'ज़रूर जान लें: जो मज़दूरी तय हुई थी वह भी अगर आपके राज्य की '
                      'न्यूनतम मज़दूरी से कम है, तो आपका दावा न्यूनतम मज़दूरी के हिसाब '
                      'से बनता है, तय हुई रक़म से नहीं। इसी लक्ष्य में "न्यूनतम मज़दूरी '
                      'से कम मिल रहा है" देखें।'
                  : 'Put that figure in the complaint along with the dates '
                      'worked. One thing worth knowing: if the wage that was '
                      'agreed is itself below your state\'s minimum wage, '
                      'your claim is for the minimum wage, not the agreed '
                      'amount. See "Am I paid less than minimum wage" in this '
                      'goal.',
              tone: ToolTone.plain,
              icon: Icons.currency_rupee,
            ),
          const SizedBox(height: 14),
          Text(hi ? 'शिकायत कहाँ' : 'Where the complaint goes',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'पहले लिखित में माँगें और उसकी नक़ल रखें। बहुत मामले यहीं ख़त्म हो '
                        'जाते हैं, क्योंकि लिखित माँग के बाद बात गंभीर हो जाती है।',
                    'क्षेत्र के श्रम निरीक्षक या सहायक श्रम आयुक्त के कार्यालय में '
                        'शिकायत दें, और पावती लें। कोई फ़ीस नहीं है।',
                    'केंद्र सरकार के "समाधान" पोर्टल पर भी ऑनलाइन शिकायत दर्ज होती '
                        'है, और उसकी संख्या मिल जाती है।',
                    'सुनवाई में दोनों पक्षों को बुलाया जाता है। वकील की ज़रूरत नहीं '
                        'होती; आप ख़ुद बोल सकते हैं।',
                    'बात न बने तो मामला श्रम न्यायालय जाता है, और वहाँ ज़िला विधिक '
                        'सेवा प्राधिकरण (15100) से मुफ़्त वकील मिलता है।',
                  ]
                : const [
                    'Ask in writing first and keep a copy. Many cases end '
                        'right here, because a written demand changes the '
                        'tone.',
                    'File the complaint at the area labour inspector\'s or '
                        'assistant labour commissioner\'s office and take the '
                        'acknowledgement. There is no fee.',
                    'A complaint can also be filed online on the central '
                        'government\'s Samadhan portal, which gives you a '
                        'number.',
                    'Both sides are called to a hearing. No lawyer is '
                        'needed; you may speak for yourself.',
                    'If it is not settled, the matter goes to the labour '
                        'court, where the District Legal Services Authority '
                        '(15100) provides a lawyer free.',
                  ],
          ),
          const SizedBox(height: 10),
          Text(hi ? 'शिकायत का मसौदा' : 'A draft complaint',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          CopyBlock(
            text: _draft(hi, owed),
            note: hi
                ? 'दो नक़लें बनाएँ। एक जमा करें, दूसरी पर पावती की मुहर लगवाकर अपने '
                    'पास रखें।'
                : 'Make two copies. Submit one, and keep the other with the '
                    'acknowledgement stamp on it.',
          ),
          const SizedBox(height: 10),
          const ToolChecklist(
            storageKey: 'wages_proof_v1',
            introEn: 'Anything that shows you worked there. No single one of '
                'these is necessary, and any of them helps.',
            introHi: 'जो भी दिखाए कि आपने वहाँ काम किया। इनमें से कोई एक ज़रूरी '
                'नहीं है, और कोई भी मदद करता है।',
            items: [
              CheckItem('names', 'Names and phone numbers of others who '
                  'worked with you', 'साथ काम करने वालों के नाम और फ़ोन नंबर',
                  noteEn: 'The strongest thing a worker with no papers can '
                      'bring. Several workers complaining together is harder '
                      'to brush aside and harder to punish.',
                  noteHi: 'बिना काग़ज़ वाले मज़दूर के पास यही सबसे मज़बूत चीज़ है। कई '
                      'मज़दूरों की एक साथ शिकायत को टालना भी मुश्किल है और सज़ा देना '
                      'भी।'),
              CheckItem('dates', 'Your own written note of the dates worked',
                  'काम के दिनों की अपनी लिखी पर्ची'),
              CheckItem('phone', 'Messages or call records with the employer',
                  'नियोक्ता से हुई बातचीत के संदेश या कॉल रिकॉर्ड'),
              CheckItem('photo', 'Photographs of you at the workplace',
                  'काम की जगह पर आपकी फ़ोटो'),
              CheckItem('slip', 'Any slip, card, token or part payment '
                  'receipt', 'कोई पर्ची, कार्ड, टोकन या आधे भुगतान की रसीद'),
              CheckItem('id', 'An employer-issued card or gate pass, if any',
                  'नियोक्ता का दिया कार्ड या गेट पास, अगर हो'),
            ],
          ),
          const SourceNote(text: 'Samadhan - online labour complaints',
              url: _samadhanUrl),
          const SourceNote(
              text: 'Ministry of Labour and Employment', url: _labourUrl),
        ],
      ],
    );
  }
}

// --- Minimum wage -----------------------------------------------------

class MinimumWagePage extends StatefulWidget {
  const MinimumWagePage({super.key});

  @override
  State<MinimumWagePage> createState() => _MinimumWagePageState();
}

class _MinimumWagePageState extends State<MinimumWagePage> {
  final _paid = TextEditingController();
  final _notified = TextEditingController();

  @override
  void dispose() {
    _paid.dispose();
    _notified.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final paid = double.tryParse(_paid.text.trim());
    final notified = double.tryParse(_notified.text.trim());
    final short = (paid != null && notified != null && paid > 0 && notified > 0)
        ? notified - paid
        : null;

    return ToolScaffold(
      goal: 8,
      title: hi ? 'न्यूनतम मज़दूरी से कम मिल रहा है?' : 'Am I paid less than minimum wage',
      children: [
        ToolNote(hi
            ? 'यहाँ कोई दर नहीं लिखी है, और लिख भी नहीं सकते: न्यूनतम मज़दूरी हर '
                'राज्य, हर काम और हर कुशलता-श्रेणी के लिए अलग होती है, और साल में '
                'एक-दो बार बदलती है। इसलिए पहले अपनी दर पता कीजिए — वह सार्वजनिक '
                'होती है और माँगने पर मिलती है।'
            : 'There is no rate on this screen, and there could not be: the '
                'minimum wage differs by state, by trade and by skill '
                'category, and it is revised once or twice a year. So the '
                'first job is finding your own rate - it is public, and it is '
                'available for the asking.'),
        ToolAnswer(
          headline: hi ? 'अपनी दर कैसे पता करें' : 'How to find your rate',
          detail: hi
              ? 'तीन रास्ते हैं। एक: राज्य के श्रम विभाग की वेबसाइट पर "न्यूनतम '
                  'मज़दूरी अधिसूचना" में अपना काम और श्रेणी (अकुशल, अर्ध-कुशल, कुशल) '
                  'देखें। दो: श्रम निरीक्षक के कार्यालय में यह सूची लगी होती है और '
                  'माँगने पर नक़ल मिलती है। तीन: हर प्रतिष्ठान को न्यूनतम मज़दूरी का '
                  'नोटिस अपने परिसर में लगाना होता है — अगर वह नहीं लगा है, तो वह '
                  'अपने आप में एक उल्लंघन है और यह बात शिकायत में लिखी जा सकती है।'
              : 'Three routes. One: the state labour department\'s site, '
                  'under the minimum wage notification, where you look up '
                  'your trade and category - unskilled, semi-skilled, '
                  'skilled. Two: the list is displayed at the labour '
                  'inspector\'s office and a copy is available on asking. '
                  'Three: every establishment is required to display the '
                  'minimum wage notice on its premises - and if it is not '
                  'displayed, that is itself a breach you can put in the '
                  'complaint.',
          tone: ToolTone.plain,
          icon: Icons.manage_search_outlined,
        ),
        ToolQuestion(hi ? 'दोनों दरें' : 'The two rates'),
        ToolNumber(
          controller: _paid,
          label: hi ? 'जो मिल रहा है, प्रतिदिन (₹)' : 'What you are paid, a day (₹)',
          decimal: true,
          maxDigits: 6,
          icon: Icons.payments_outlined,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolNumber(
          controller: _notified,
          label: hi
              ? 'अधिसूचित न्यूनतम मज़दूरी, प्रतिदिन (₹)'
              : 'The notified minimum, a day (₹)',
          decimal: true,
          maxDigits: 6,
          icon: Icons.gavel_outlined,
          onChanged: (_) => setState(() {}),
        ),
        if (short != null) ...[
          ToolAnswer(
            headline: short > 0
                ? (hi
                    ? 'रोज़ ₹${short.round()} कम — यह अवैध है'
                    : '₹${short.round()} short a day - that is unlawful')
                : (hi
                    ? 'न्यूनतम से कम नहीं है'
                    : 'Not below the minimum'),
            detail: short > 0
                ? (hi
                    ? 'महीने के 26 कार्यदिवस मानें तो यह ₹${(short * 26).round()} '
                        'महीने का और ₹${(short * 26 * 12).round()} साल का अंतर है। '
                        'न्यूनतम मज़दूरी से कम देना अपराध है, और इसमें यह बहाना नहीं '
                        'चलता कि "मज़दूर ने ख़ुद इस दर पर काम करना मान लिया था" — '
                        'न्यूनतम से नीचे का कोई समझौता क़ानून में नहीं टिकता। बकाया '
                        'पिछली तारीख़ से वसूला जा सकता है।'
                    : 'At 26 working days that is ₹${(short * 26).round()} a '
                        'month and ₹${(short * 26 * 12).round()} a year. '
                        'Paying below the minimum wage is an offence, and '
                        '"the worker agreed to this rate" is not a defence - '
                        'no agreement below the minimum stands in law. The '
                        'arrears can be recovered from the earlier date.')
                : (hi
                    ? 'फिर भी दो बातें देख लें: क्या आपको अपनी सही श्रेणी (अकुशल, '
                        'अर्ध-कुशल, कुशल) की दर मिल रही है — काम कुशल का और दर अकुशल '
                        'की देना आम है। और क्या महँगाई भत्ते के साथ की दर देखी है, '
                        'क्योंकि अधिसूचना में वह अलग जुड़ता है।'
                    : 'Even so, check two things: whether you are on the '
                        'right category rate - unskilled, semi-skilled, '
                        'skilled - because paying a skilled worker at the '
                        'unskilled rate is common. And whether you looked at '
                        'the rate including the dearness allowance, which the '
                        'notification adds separately.'),
            tone: short > 0 ? ToolTone.bad : ToolTone.good,
            icon: Icons.balance_outlined,
          ),
          const SizedBox(height: 14),
          ToolDonts(
            heading: hi
                ? 'न्यूनतम मज़दूरी के बारे में ये बातें ग़लत हैं'
                : 'Things said about the minimum wage that are not true',
            items: hi
                ? const [
                    '"मज़दूर मान गया था तो कम दे सकते हैं" — नहीं। न्यूनतम से नीचे का '
                        'समझौता अमान्य है।',
                    '"औरतों की दर कम होती है" — नहीं। एक ही काम के लिए दर एक ही है।',
                    '"खाना-रहना दिया है तो मज़दूरी से काट सकते हैं" — मनमानी कटौती '
                        'नहीं हो सकती; जो कटौतियाँ हो सकती हैं वे क़ानून में गिनी हुई '
                        'हैं।',
                    '"ठेके पर हैं तो न्यूनतम मज़दूरी लागू नहीं" — लागू होती है, और '
                        'मुख्य नियोक्ता भी ज़िम्मेदार है।',
                    '"रोज़ के मज़दूर को छुट्टी का पैसा नहीं" — हफ़्ते में एक दिन की '
                        'साप्ताहिक छुट्टी और उसका भुगतान बनता है।',
                  ]
                : const [
                    '"The worker agreed, so less can be paid" - no. An '
                        'agreement below the minimum is void.',
                    '"Women\'s rate is lower" - no. The rate for the same '
                        'work is the same.',
                    '"Food and lodging can be deducted from the wage" - '
                        'arbitrary deductions cannot be made; the permissible '
                        'ones are listed in the law.',
                    '"Contract workers are outside the minimum wage" - they '
                        'are not, and the principal employer is liable too.',
                    '"A daily worker gets nothing for a day off" - a weekly '
                        'rest day, and payment for it, is due.',
                  ],
          ),
          ToolNote(hi
              ? 'शिकायत का रास्ता वही है जो मज़दूरी न मिलने पर है — श्रम निरीक्षक, '
                  'और समाधान पोर्टल। इसी लक्ष्य में "मज़दूरी नहीं मिली" वाली स्क्रीन '
                  'में मसौदा भी दिया है।'
              : 'The complaint route is the same as for unpaid wages - the '
                  'labour inspector, and the Samadhan portal. The screen '
                  '"Wages not paid" in this goal has a draft letter.'),
          const SourceNote(
              text: 'The labour codes, Press Information Bureau',
              url: _wageCodeUrl),
        ],
      ],
    );
  }
}

// --- Overtime ---------------------------------------------------------

class OvertimePage extends StatefulWidget {
  const OvertimePage({super.key});

  @override
  State<OvertimePage> createState() => _OvertimePageState();
}

class _OvertimePageState extends State<OvertimePage> {
  final _dailyWage = TextEditingController();
  final _normalHours = TextEditingController(text: '8');
  final _extraHours = TextEditingController();
  final _days = TextEditingController(text: '26');

  @override
  void dispose() {
    for (final c in [_dailyWage, _normalHours, _extraHours, _days]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final wage = double.tryParse(_dailyWage.text.trim()) ?? 0;
    final normal = double.tryParse(_normalHours.text.trim()) ?? 0;
    final extra = double.tryParse(_extraHours.text.trim()) ?? 0;
    final days = double.tryParse(_days.text.trim()) ?? 0;

    final hourly = (wage > 0 && normal > 0) ? wage / normal : null;
    final otRate = hourly == null ? null : hourly * overtimeMultiplier;
    final owedADay = (otRate != null && extra > 0) ? otRate * extra : null;
    final owedAMonth = (owedADay != null && days > 0) ? owedADay * days : null;

    return ToolScaffold(
      goal: 8,
      title: hi ? 'ओवरटाइम का पैसा' : 'Overtime pay',
      children: [
        ToolNote(hi
            ? 'क़ानून में ओवरटाइम की दर साफ़ है: सामान्य मज़दूरी की दोगुनी, कम नहीं। '
                'यह बात ज़्यादातर मज़दूरों को नहीं बताई जाती, और "दो घंटे ज़्यादा रुक '
                'जाओ" के बदले अक्सर कुछ नहीं या सामान्य दर मिलती है।'
            : 'The law is clear on the overtime rate: not less than twice '
                'the ordinary rate of wages. Most workers are never told '
                'this, and "stay two hours longer" usually earns nothing, or '
                'the ordinary rate.'),
        ToolQuestion(hi ? 'अपनी मज़दूरी और घंटे' : 'Your wage and hours'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _dailyWage,
                label: hi ? 'दिन की मज़दूरी (₹)' : 'Daily wage (₹)',
                decimal: true,
                maxDigits: 6,
                icon: Icons.currency_rupee,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _normalHours,
                label: hi ? 'तय घंटे' : 'Normal hours',
                decimal: true,
                maxDigits: 3,
                icon: Icons.schedule,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _extraHours,
                label: hi ? 'ज़्यादा घंटे रोज़' : 'Extra hours a day',
                decimal: true,
                maxDigits: 3,
                icon: Icons.more_time,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _days,
                label: hi ? 'महीने में दिन' : 'Days a month',
                decimal: true,
                maxDigits: 3,
                icon: Icons.calendar_today_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        if (hourly != null && owedADay != null) ...[
          ToolAnswer(
            headline: hi
                ? 'रोज़ ₹${owedADay.round()} ओवरटाइम बनता है'
                : '₹${owedADay.round()} of overtime a day',
            detail: hi
                ? 'आपकी सामान्य दर ₹${hourly.toStringAsFixed(1)} प्रति घंटा है, '
                    'इसलिए ओवरटाइम की दर ₹${otRate!.toStringAsFixed(1)} प्रति घंटा '
                    'बनती है — दोगुनी।'
                    '${owedAMonth != null ? ' महीने के ₹${owedAMonth.round()}।' : ''}'
                : 'Your ordinary rate is ₹${hourly.toStringAsFixed(1)} an '
                    'hour, so overtime is ₹${otRate!.toStringAsFixed(1)} an '
                    'hour - twice that.'
                    '${owedAMonth != null ? ' That is ₹${owedAMonth.round()} a month.' : ''}',
            tone: ToolTone.good,
            icon: Icons.more_time,
          ),
          const SizedBox(height: 10),
          ToolLine(hi ? 'सामान्य दर, प्रति घंटा' : 'Ordinary rate an hour',
              '₹${hourly.toStringAsFixed(1)}'),
          ToolLine(hi ? 'ओवरटाइम दर, प्रति घंटा' : 'Overtime rate an hour',
              '₹${otRate.toStringAsFixed(1)}', strong: true),
          ToolLine(hi ? 'रोज़ का ओवरटाइम' : 'Overtime a day',
              '₹${owedADay.round()}'),
          if (owedAMonth != null)
            ToolLine(hi ? 'महीने का ओवरटाइम' : 'Overtime a month',
                '₹${owedAMonth.round()}', strong: true),
          const SizedBox(height: 14),
          Text(hi ? 'घंटों की सीमा भी है' : 'There are limits on hours too',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            numbered: false,
            steps: hi
                ? const [
                    'काम के घंटों की रोज़ और हफ़्ते की सीमा होती है, और ओवरटाइम मिलाकर '
                        'भी एक सीमा होती है — यह आपके राज्य के नियमों में लिखी होती है।',
                    'हफ़्ते में एक दिन की छुट्टी का हक़ है।',
                    'लगातार काम के बीच विश्राम का समय मिलना चाहिए।',
                    'ओवरटाइम का हिसाब रजिस्टर में दर्ज होना चाहिए, और वह रजिस्टर रखना '
                        'नियोक्ता की ज़िम्मेदारी है।',
                  ]
                : const [
                    'There are daily and weekly limits on working hours, and '
                        'a limit including overtime - set out in your state\'s '
                        'rules.',
                    'A weekly day of rest is a right.',
                    'There must be a rest interval within a long stretch of '
                        'work.',
                    'Overtime has to be recorded in a register, and keeping '
                        'that register is the employer\'s duty.',
                  ],
          ),
          ToolNote(hi
              ? 'सबसे काम की आदत: रोज़ अपने आने-जाने का समय ख़ुद एक कॉपी में लिखिए। '
                  'नियोक्ता का रजिस्टर आपके हाथ में नहीं होता, लेकिन अपने हाथ से रोज़ '
                  'लिखी पर्ची सबूत मानी जाती है — और ओवरटाइम के ज़्यादातर मामले इसी '
                  'के अभाव में हार जाते हैं।'
              : 'The most useful habit: write down your own in and out times '
                  'every day in a notebook. The employer\'s register is not '
                  'in your hands, but a daily note in your own hand is '
                  'accepted as evidence - and most overtime claims are lost '
                  'for want of it.'),
          const SourceNote(
              text: 'Ministry of Labour and Employment', url: _labourUrl),
        ],
      ],
    );
  }
}

// --- PF ---------------------------------------------------------------

enum PfProblem { checkBalance, withdraw, nameMismatch, notDeposited, uanLost }

class ProvidentFundPage extends StatefulWidget {
  const ProvidentFundPage({super.key});

  @override
  State<ProvidentFundPage> createState() => _ProvidentFundPageState();
}

class _ProvidentFundPageState extends State<ProvidentFundPage> {
  PfProblem? _problem;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    Widget pick(PfProblem p, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _problem == p,
          onTap: () => setState(() => _problem = p),
        );

    return ToolScaffold(
      goal: 8,
      title: hi ? 'पीएफ़: बैलेंस, निकासी, नाम' : 'PF: balance, withdrawal, name',
      children: [
        ToolNote(hi
            ? 'पीएफ़ का पैसा आपका है और उसका हिसाब आप ख़ुद देख सकते हैं — इसके लिए '
                'नियोक्ता से पूछने की ज़रूरत नहीं। सबसे ज़रूरी चीज़ है UAN (यूनिवर्सल '
                'अकाउंट नंबर): यह एक ही नंबर है जो नौकरी बदलने पर भी वही रहता है, और '
                'सब कुछ उसी से चलता है।'
            : 'PF money is yours and you can see the account yourself - no '
                'need to ask the employer. The thing that matters most is the '
                'UAN, the universal account number: one number that stays the '
                'same across jobs, and everything runs off it.'),
        ToolQuestion(hi ? 'क्या करना है' : 'What do you need'),
        pick(PfProblem.checkBalance, 'See my balance',
            'बैलेंस देखना है'),
        pick(PfProblem.withdraw, 'Withdraw money', 'पैसा निकालना है'),
        pick(PfProblem.nameMismatch,
            'My name or date of birth does not match',
            'नाम या जन्मतिथि नहीं मिल रही'),
        pick(PfProblem.notDeposited,
            'It is cut from my pay but not showing in the account',
            'वेतन से कटता है लेकिन खाते में नहीं दिख रहा'),
        pick(PfProblem.uanLost, 'I do not know my UAN',
            'मुझे अपना UAN नहीं पता'),
        if (_problem != null) ...[
          ToolAnswer(
            headline: switch (_problem!) {
              PfProblem.checkBalance =>
                hi ? 'तीन तरीक़े, तीनों मुफ़्त' : 'Three ways, all free',
              PfProblem.withdraw =>
                hi ? 'ऑनलाइन दावा, नियोक्ता के बिना' : 'An online claim, without the employer',
              PfProblem.nameMismatch =>
                hi ? 'यह सुधारा जा सकता है' : 'This can be corrected',
              PfProblem.notDeposited =>
                hi ? 'यह गंभीर बात है और शिकायत बनती है' : 'This is serious, and it is a complaint',
              PfProblem.uanLost =>
                hi ? 'मोबाइल नंबर से निकल आता है' : 'It comes back from your mobile number',
            },
            detail: switch (_problem!) {
              PfProblem.checkBalance => hi
                  ? 'एक: उमंग ऐप या ईपीएफ़ओ की वेबसाइट पर UAN से लॉगिन करके पासबुक '
                      'देखें। दो: पंजीकृत मोबाइल नंबर से 9966044425 पर मिस्ड कॉल '
                      'दें — बैलेंस का संदेश आ जाता है, और इसमें इंटरनेट की ज़रूरत '
                      'नहीं। तीन: 7738299899 पर "EPFOHO UAN HIN" लिखकर एसएमएस भेजें '
                      'तो हिंदी में जवाब आता है।'
                  : 'One: log in with your UAN on the UMANG app or the EPFO '
                      'site and open the passbook. Two: give a missed call to '
                      '9966044425 from your registered mobile - the balance '
                      'arrives by message, and this needs no internet. '
                      'Three: send "EPFOHO UAN ENG" by SMS to 7738299899 for '
                      'a reply in English.',
              PfProblem.withdraw => hi
                  ? 'दावा ईपीएफ़ओ के पोर्टल से ख़ुद किया जा सकता है, बशर्ते UAN आधार '
                      'और बैंक खाते से जुड़ा हो और केवाईसी पूरी हो। आमतौर पर नियोक्ता '
                      'की मंज़ूरी की ज़रूरत नहीं पड़ती। ज़रूरत पड़ने पर पूरा पैसा निकालने '
                      'के बजाय आंशिक निकासी (एडवांस) भी ली जा सकती है — इलाज, मकान, '
                      'शादी, पढ़ाई और बेरोज़गारी के लिए अलग-अलग नियम हैं, और उसमें '
                      'पेंशन का हिस्सा बचा रहता है।'
                  : 'The claim can be filed by you on the EPFO portal, '
                      'provided the UAN is linked to Aadhaar and a bank '
                      'account and the KYC is complete. The employer\'s '
                      'approval is usually not needed. Rather than taking '
                      'everything out, a partial withdrawal (an advance) is '
                      'also possible - there are separate rules for '
                      'treatment, a house, a marriage, education and '
                      'unemployment, and the pension part stays intact.',
              PfProblem.nameMismatch => hi
                  ? 'नाम, जन्मतिथि या आधार का मेल न खाना ही दावे रुकने की सबसे आम '
                      'वजह है। सुधार का अनुरोध ईपीएफ़ओ के पोर्टल से होता है और '
                      'नियोक्ता उसे आगे बढ़ाता है। एक बात ध्यान रखें: पहले आधार ठीक '
                      'कराइए, फिर पीएफ़ का रिकॉर्ड उससे मिलाइए — उलटा करने पर दोबारा '
                      'अटकता है। लक्ष्य 1 में "आधार की दिक़्क़त" वाली स्क्रीन है।'
                  : 'A name, date of birth or Aadhaar that does not match is '
                      'the commonest reason a claim sticks. The correction '
                      'request goes through the EPFO portal and the employer '
                      'forwards it. One thing to keep in mind: fix the '
                      'Aadhaar first and then match the PF record to it - the '
                      'other way round it sticks again. Goal 1 has a screen '
                      'on Aadhaar problems.',
              PfProblem.notDeposited => hi
                  ? 'वेतन से काटकर जमा न करना नियोक्ता की ओर से गंभीर चूक है। पासबुक '
                      'में महीने-दर-महीने जमा दिखता है, इसलिए पहले पासबुक निकालकर यह '
                      'देख लें कि किस महीने से नहीं आ रहा — यही आपका सबूत है। फिर '
                      'ईपीएफ़ओ के शिकायत पोर्टल (EPFiGMS) पर शिकायत दर्ज कराएँ और '
                      'क्षेत्रीय पीएफ़ कार्यालय में भी लिखित दें। ईपीएफ़ओ नियोक्ता से '
                      'वसूली कर सकता है और ब्याज तथा हर्जाना भी लगाता है।'
                  : 'Deducting it from pay and not depositing it is a serious '
                      'default by the employer. The passbook shows month by '
                      'month what was credited, so download it first and see '
                      'from which month it stopped - that is your evidence. '
                      'Then file a complaint on the EPFO grievance portal '
                      '(EPFiGMS) and give one in writing at the regional PF '
                      'office. EPFO can recover from the employer, with '
                      'interest and damages.',
              PfProblem.uanLost => hi
                  ? 'ईपीएफ़ओ की वेबसाइट पर "Know your UAN" में पंजीकृत मोबाइल नंबर '
                      'डालकर UAN निकल आता है। वेतन पर्ची पर भी आमतौर पर लिखा होता है। '
                      'नौकरी बदलने पर नया UAN नहीं बनवाना चाहिए — पुराना ही चलता रहना '
                      'चाहिए, वरना पैसा दो खातों में बँट जाता है और जोड़ने में समय '
                      'लगता है।'
                  : 'On the EPFO site, "Know your UAN" returns it against '
                      'your registered mobile number. It is usually printed '
                      'on the salary slip too. On changing jobs you should '
                      'not get a new UAN - the old one should continue, or '
                      'the money sits in two accounts and merging them takes '
                      'time.',
            },
            tone: _problem == PfProblem.notDeposited
                ? ToolTone.bad
                : ToolTone.plain,
            icon: Icons.savings_outlined,
          ),
          const SizedBox(height: 14),
          const ToolChecklist(
            storageKey: 'pf_ready_v1',
            introEn: 'Get these four right and most PF problems do not '
                'arise.',
            introHi: 'ये चार चीज़ें ठीक हों तो पीएफ़ की ज़्यादातर दिक़्क़तें होती ही '
                'नहीं।',
            items: [
              CheckItem('uan', 'Know your UAN and keep it written down',
                  'अपना UAN जानें और लिखकर रखें'),
              CheckItem('mobile', 'The mobile number registered with EPFO '
                  'should be one you still use',
                  'ईपीएफ़ओ में दर्ज मोबाइल नंबर वही हो जो चालू है'),
              CheckItem('kyc', 'Aadhaar, PAN and bank account seeded to the '
                  'UAN', 'UAN से आधार, पैन और बैंक खाता जुड़ा हो'),
              CheckItem('nominee', 'File the e-nomination - without it the '
                  'family cannot claim easily',
                  'ई-नामांकन भरें — इसके बिना परिवार आसानी से दावा नहीं कर सकता',
                  noteEn: 'The one step people skip, and the one that matters '
                      'most to whoever is left behind.',
                  noteHi: 'लोग यही क़दम छोड़ देते हैं, और पीछे रह जाने वालों के लिए '
                      'सबसे ज़्यादा यही मायने रखता है।'),
              CheckItem('passbook', 'Open the passbook once a year and check '
                  'the deposits', 'साल में एक बार पासबुक खोलकर जमा देख लें'),
            ],
          ),
          const SourceNote(text: 'EPFO', url: _epfoUrl),
        ],
      ],
    );
  }
}

// --- Gratuity ---------------------------------------------------------

class GratuityPage extends StatefulWidget {
  const GratuityPage({super.key});

  @override
  State<GratuityPage> createState() => _GratuityPageState();
}

class _GratuityPageState extends State<GratuityPage> {
  final _years = TextEditingController();
  final _months = TextEditingController(text: '0');
  final _lastWage = TextEditingController();

  @override
  void dispose() {
    for (final c in [_years, _months, _lastWage]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final years = double.tryParse(_years.text.trim()) ?? 0;
    final months = double.tryParse(_months.text.trim()) ?? 0;
    final wage = double.tryParse(_lastWage.text.trim()) ?? 0;

    // A part-year over six months counts as a full year.
    final countedYears = years + (months >= 6 ? 1 : 0);
    final eligible = (years + months / 12) >= gratuityMinYears;
    final amount = (eligible && wage > 0)
        ? gratuityDaysPerYear / gratuityMonthDays * wage * countedYears
        : null;

    return ToolScaffold(
      goal: 8,
      title: hi ? 'ग्रैच्युटी: बनती है या नहीं' : 'Gratuity: am I due it',
      children: [
        ToolNote(hi
            ? 'ग्रैच्युटी नौकरी छोड़ने या निकाले जाने पर मिलने वाली एक अलग रक़म है, '
                'पीएफ़ से बिल्कुल अलग, और ज़्यादातर लोगों को इसका पता ही नहीं होता। '
                'हिसाब सीधा है: हर पूरे साल के लिए पंद्रह दिन की मज़दूरी, और महीने को '
                '26 दिन मानकर।'
            : 'Gratuity is a separate amount payable on leaving or being let '
                'go, entirely separate from PF, and most people do not know '
                'it exists. The arithmetic is simple: fifteen days\' wages '
                'for every completed year, reckoning a month as 26 days.'),
        ToolQuestion(hi ? 'कितने समय काम किया' : 'How long did you work there'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _years,
                label: hi ? 'पूरे साल' : 'Full years',
                maxDigits: 2,
                icon: Icons.calendar_today_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _months,
                label: hi ? 'और महीने' : 'And months',
                maxDigits: 2,
                icon: Icons.calendar_month_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        ToolQuestion(hi ? 'आख़िरी महीने की मज़दूरी' : 'Last drawn monthly wage'),
        ToolNumber(
          controller: _lastWage,
          label: hi ? 'मूल वेतन + महँगाई भत्ता (₹)' : 'Basic + dearness allowance (₹)',
          decimal: true,
          maxDigits: 8,
          icon: Icons.currency_rupee,
          onChanged: (_) => setState(() {}),
        ),
        if (years > 0 || months > 0) ...[
          if (!eligible)
            ToolAnswer(
              headline: hi
                  ? 'अभी $gratuityMinYears साल पूरे नहीं हुए'
                  : 'Not yet $gratuityMinYears years of service',
              detail: hi
                  ? 'ग्रैच्युटी आमतौर पर पाँच साल की लगातार सेवा के बाद बनती है। दो '
                      'अपवाद ज़रूर जान लें: मृत्यु या दिव्यांगता के कारण नौकरी छूटने पर '
                      'पाँच साल की शर्त लागू नहीं होती, और परिवार को तब भी मिलती है। '
                      'और "लगातार" का मतलब बीच की छुट्टियाँ या बीमारी नहीं टूटना है।'
                  : 'Gratuity generally arises after five years of continuous '
                      'service. Two exceptions worth knowing: where service '
                      'ends through death or disablement the five-year '
                      'condition does not apply and the family is still paid. '
                      'And "continuous" is not broken by leave or illness.',
              tone: ToolTone.plain,
              icon: Icons.schedule,
            )
          else if (amount != null)
            ToolAnswer(
              headline: hi
                  ? 'लगभग ₹${amount.round()} बनती है'
                  : 'About ₹${amount.round()} is due',
              detail: hi
                  ? '${countedYears.round()} साल के लिए, आख़िरी मज़दूरी '
                      '₹${wage.round()} पर — पंद्रह दिन प्रति साल, 26 दिन का महीना '
                      'मानकर। छह महीने से ऊपर का हिस्सा पूरा साल गिना जाता है, इसलिए '
                      'नौकरी छोड़ने का महीना भी मायने रखता है।'
                  : 'For ${countedYears.round()} years on a last wage of '
                      '₹${wage.round()} - fifteen days a year on a 26-day '
                      'month. A part-year over six months counts as a full '
                      'year, so the month you leave in matters.',
              tone: ToolTone.good,
              icon: Icons.account_balance_wallet_outlined,
            ),
          if (eligible && amount != null) ...[
            const SizedBox(height: 10),
            ToolLine(hi ? 'गिने गए साल' : 'Years counted',
                '${countedYears.round()}'),
            ToolLine(hi ? 'आख़िरी मज़दूरी' : 'Last wage', '₹${wage.round()}'),
            ToolLine(hi ? 'ग्रैच्युटी' : 'Gratuity', '₹${amount.round()}',
                strong: true),
            const SizedBox(height: 14),
            Text(hi ? 'कैसे माँगें' : 'How to claim it',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800)),
            ToolSteps(
              steps: hi
                  ? const [
                      'नियोक्ता को लिखित में आवेदन दें और पावती लें।',
                      'भुगतान आमतौर पर तय समय के भीतर करना होता है, और देर होने पर '
                          'ब्याज देना पड़ता है — यह बात आवेदन में लिखी जा सकती है।',
                      'न मिले तो नियंत्रक प्राधिकारी (controlling authority) के पास '
                          'आवेदन करें। यह आमतौर पर सहायक श्रम आयुक्त होते हैं, और यह '
                          'रास्ता अदालत से अलग, आसान और सस्ता है।',
                      'नियोक्ता यह नहीं कह सकता कि "कंपनी बंद हो गई" या "हिसाब बाक़ी '
                          'है" — ग्रैच्युटी अलग देनदारी है।',
                    ]
                  : const [
                      'Apply to the employer in writing and take an '
                          'acknowledgement.',
                      'Payment is due within a prescribed time, and a delay '
                          'carries interest - worth saying so in the '
                          'application.',
                      'If it is not paid, apply to the controlling authority, '
                          'usually the assistant labour commissioner. That '
                          'route is separate from a court, simpler and '
                          'cheaper.',
                      'An employer cannot answer with "the company closed" or '
                          '"there are accounts pending" - gratuity is a '
                          'liability of its own.',
                    ],
            ),
            ToolNote(hi
                ? 'ग्रैच्युटी पर एक सीमा तक आयकर नहीं लगता, और वह सीमा समय-समय पर '
                    'बदलती है — इसलिए यहाँ रक़म नहीं लिखी गई। रक़म बड़ी हो तो भुगतान '
                    'लेने से पहले एक बार पूछ लें।'
                : 'Gratuity is exempt from income tax up to a limit, and that '
                    'limit has changed from time to time - which is why no '
                    'figure is given here. If the amount is large, ask before '
                    'taking the payment.'),
            const SourceNote(
                text: 'Ministry of Labour and Employment', url: _labourUrl),
          ],
        ],
      ],
    );
  }
}

// --- Dismissed without notice -----------------------------------------

class DismissedPage extends StatefulWidget {
  const DismissedPage({super.key});

  @override
  State<DismissedPage> createState() => _DismissedPageState();
}

class _DismissedPageState extends State<DismissedPage> {
  final _years = TextEditingController();
  final _wage = TextEditingController();
  bool _noticeGiven = false;
  bool _reasonGiven = false;

  @override
  void dispose() {
    _years.dispose();
    _wage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final years = double.tryParse(_years.text.trim()) ?? 0;
    final wage = double.tryParse(_wage.text.trim()) ?? 0;
    // Retrenchment compensation: fifteen days' average pay per completed
    // year of continuous service.
    final compensation =
        (years >= 1 && wage > 0) ? (wage / 2) * years.floor() : null;

    return ToolScaffold(
      goal: 8,
      title: hi ? 'बिना नोटिस निकाल दिया' : 'Dismissed without notice',
      children: [
        ToolNote(hi
            ? 'एक साल या उससे ज़्यादा लगातार काम करने वाले मज़दूर को हटाने के लिए '
                'क़ानून में शर्तें हैं: पहले से नोटिस या उसके बदले वेतन, हर पूरे साल '
                'के लिए मुआवज़ा, और कारण। "कल से मत आना" अपने आप में अवैध हो सकता है।'
            : 'Removing a worker with a year or more of continuous service '
                'comes with conditions: notice or wages in its place, '
                'compensation for every completed year, and a reason. "Do not '
                'come from tomorrow" can be unlawful in itself.'),
        ToolQuestion(hi ? 'कितने समय काम किया' : 'How long did you work there'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _years,
                label: hi ? 'साल' : 'Years',
                decimal: true,
                maxDigits: 3,
                icon: Icons.calendar_today_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _wage,
                label: hi ? 'महीने की मज़दूरी (₹)' : 'Monthly wage (₹)',
                decimal: true,
                maxDigits: 8,
                icon: Icons.currency_rupee,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        SwitchListTile(
          value: _noticeGiven,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'पहले से नोटिस दिया गया था'
              : 'Notice was given in advance'),
          onChanged: (v) => setState(() => _noticeGiven = v),
        ),
        SwitchListTile(
          value: _reasonGiven,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'निकालने का कारण लिखित में दिया गया'
              : 'A written reason was given'),
          onChanged: (v) => setState(() => _reasonGiven = v),
        ),
        if (years > 0) ...[
          if (years < 1)
            ToolAnswer(
              headline: hi
                  ? 'एक साल से कम सेवा में सुरक्षा कम है'
                  : 'Under a year, the protection is thinner',
              detail: hi
                  ? 'मुआवज़े का हक़ आमतौर पर एक साल की लगातार सेवा से बनता है। लेकिन '
                      'इतने में भी दो चीज़ें आपकी हैं: किए हुए काम की पूरी मज़दूरी, और '
                      'जो भी नोटिस आपके नियुक्ति पत्र या तय शर्तों में लिखा था। '
                      'मज़दूरी रोकी गई हो तो इसी लक्ष्य में "मज़दूरी नहीं मिली" देखें।'
                  : 'The right to compensation generally arises after a year '
                      'of continuous service. Even below that, two things are '
                      'yours: full wages for the work done, and whatever '
                      'notice your appointment letter or agreed terms '
                      'provided. If wages are being withheld, see "Wages not '
                      'paid" in this goal.',
              tone: ToolTone.plain,
              icon: Icons.info_outline,
            )
          else ...[
            ToolAnswer(
              headline: hi
                  ? 'एक साल से ऊपर — शर्तें लागू होती हैं'
                  : 'Over a year - the conditions apply',
              detail: hi
                  ? 'इतनी सेवा के बाद हटाने पर आमतौर पर यह बनता है: नोटिस या उसके '
                      'बदले वेतन, हर पूरे साल के लिए पंद्रह दिन के औसत वेतन का '
                      'मुआवज़ा, और "पहले आया, बाद में हटे" का क्रम — यानी आपके बाद आए '
                      'लोग काम कर रहे हों और आपको हटाया गया हो, तो वह अपने आप में '
                      'सवाल है।'
                  : 'After that much service, removal generally requires: '
                      'notice or wages in its place, compensation of fifteen '
                      'days\' average pay for every completed year, and the '
                      '"last in, first out" order - so if people who joined '
                      'after you are still working and you were removed, that '
                      'is a question in itself.',
              tone: ToolTone.warn,
              icon: Icons.gavel_outlined,
            ),
            if (compensation != null)
              ToolAnswer(
                headline: hi
                    ? 'मुआवज़ा लगभग ₹${compensation.round()}'
                    : 'Compensation of about ₹${compensation.round()}',
                detail: hi
                    ? '${years.floor()} पूरे साल के लिए, हर साल पंद्रह दिन के औसत '
                        'वेतन के हिसाब से। इसके ऊपर नोटिस के बदले का वेतन अलग से बनता '
                        'है${_noticeGiven ? '' : ', क्योंकि नोटिस नहीं दिया गया था'}। '
                        'पाँच साल पूरे हो गए हों तो ग्रैच्युटी भी अलग से बनती है — '
                        'इसी लक्ष्य में उसकी स्क्रीन है।'
                    : 'For ${years.floor()} completed years at fifteen days\' '
                        'average pay each. Wages in place of notice are '
                        'separate and on top of '
                        'that${_noticeGiven ? '' : ', since no notice was given'}. '
                        'If five years were completed, gratuity is separate '
                        'again - there is a screen for it in this goal.',
                tone: ToolTone.plain,
                icon: Icons.currency_rupee,
              ),
            if (!_reasonGiven)
              ToolNote(hi
                  ? 'कारण लिखित में न मिला हो तो सबसे पहले वही माँगिए — एक पंक्ति की '
                      'अर्ज़ी से: "कृपया मुझे सेवा से हटाने का कारण लिखित में दीजिए।" '
                      'इसके बाद ही पता चलता है कि मामला छँटनी का है, अनुशासन का, या '
                      'कुछ और — और तीनों के रास्ते अलग हैं।'
                  : 'If no written reason was given, ask for that first, in a '
                      'one-line application: "please give me the reason for '
                      'my removal in writing." Only then is it clear whether '
                      'this is retrenchment, a disciplinary matter or '
                      'something else - and the three have different '
                      'routes.'),
          ],
          const SizedBox(height: 14),
          Text(hi ? 'विवाद कहाँ उठाएँ' : 'Where to raise the dispute',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'कारण और बकाया हिसाब लिखित में माँगें, पावती के साथ।',
                    'क्षेत्र के श्रम आयुक्त कार्यालय में औद्योगिक विवाद के रूप में '
                        'शिकायत दर्ज कराएँ। पहले सुलह (conciliation) की कोशिश होती है '
                        'और वहाँ बहुत मामले निपट जाते हैं।',
                    'समाधान पोर्टल पर ऑनलाइन भी दर्ज होता है।',
                    'सुलह न हो तो मामला श्रम न्यायालय या औद्योगिक अधिकरण जाता है। '
                        'मुफ़्त वकील के लिए 15100।',
                    'समय का ध्यान रखें — देर से उठाया विवाद कमज़ोर पड़ता है, इसलिए '
                        'जल्दी दर्ज कराएँ।',
                  ]
                : const [
                    'Ask in writing for the reason and the final accounts, '
                        'with an acknowledgement.',
                    'Raise it as an industrial dispute at the area labour '
                        'commissioner\'s office. Conciliation is attempted '
                        'first, and a great many cases settle there.',
                    'It can also be filed online on the Samadhan portal.',
                    'If conciliation fails the matter goes to the labour '
                        'court or industrial tribunal. For a free lawyer, '
                        '15100.',
                    'Mind the timing - a dispute raised late is weaker, so '
                        'file early.',
                  ],
          ),
          const SourceNote(text: 'Samadhan', url: _samadhanUrl),
          const SourceNote(
              text: 'Ministry of Labour and Employment', url: _labourUrl),
        ],
      ],
    );
  }
}
