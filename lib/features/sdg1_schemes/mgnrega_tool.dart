import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/tool_kit.dart';

/// Demanding work under MGNREGA, and the three clocks that follow.
///
/// The right that gets lost most often is the simplest one: work is
/// guaranteed only to a household that *applies*, in writing, and keeps the
/// dated receipt. Without that receipt there is no proof a demand was ever
/// made, so the fifteen-day clock never starts and the unemployment
/// allowance can never be claimed. Everything on this screen is built
/// around producing that piece of paper.
///
/// The figures come from the Act itself:
///   100 days a year per household            (section 3)
///   work within 15 days of the application   (section 7)
///   allowance: a quarter of the wage rate for the first 30 days in the
///   year, then half                          (section 7)
///   wages within a fortnight of the work     (section 3(3))
///   beyond 5 km, 10% extra wage              (Schedule II, para 14)
const mgnregaDaysAYear = 100;
const mgnregaWorkWithinDays = 15;
const mgnregaWagesWithinDays = 14;
const mgnregaFreeRadiusKm = 5;
const mgnregaFarSitePercent = 10;

const _actUrl =
    'https://prsindia.org/files/bills_acts/acts_parliament/2005/'
    'the-national-rural-employment-guarantee-act-2005.pdf';

/// The allowance owed per day when work is not given in time.
///
/// A quarter of the wage rate for the first thirty days of the financial
/// year, half of it after that. The Act sets these as floors; a state may
/// pay more.
double unemploymentAllowance(double wageRate, int daysAlreadyClaimed) =>
    daysAlreadyClaimed < 30 ? wageRate / 4 : wageRate / 2;

class MgnregaPage extends StatefulWidget {
  const MgnregaPage({super.key});

  @override
  State<MgnregaPage> createState() => _MgnregaPageState();
}

class _MgnregaPageState extends State<MgnregaPage> {
  final _name = TextEditingController();
  final _village = TextEditingController();
  final _jobCard = TextEditingController();
  final _days = TextEditingController(text: '30');
  final _people = TextEditingController(text: '2');
  DateTime? _appliedOn;
  bool _wantAllowance = false;
  final _wage = TextEditingController();
  final _claimed = TextEditingController(text: '0');

  @override
  void dispose() {
    for (final c in [
      _name,
      _village,
      _jobCard,
      _days,
      _people,
      _wage,
      _claimed
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _draft(bool hi) {
    final name = _name.text.trim().isEmpty
        ? (hi ? '[नाम]' : '[name]')
        : _name.text.trim();
    final village = _village.text.trim().isEmpty
        ? (hi ? '[गाँव]' : '[village]')
        : _village.text.trim();
    final card = _jobCard.text.trim().isEmpty
        ? (hi ? '[जॉब कार्ड संख्या]' : '[job card number]')
        : _jobCard.text.trim();
    final days = _days.text.trim().isEmpty ? '30' : _days.text.trim();
    final people = _people.text.trim().isEmpty ? '1' : _people.text.trim();
    final today = DateFormat('d MMM yyyy').format(DateTime.now());

    if (hi) {
      return 'सेवा में,\nग्राम पंचायत / कार्यक्रम अधिकारी\n$village\n\n'
          'दिनांक: $today\n\n'
          'विषय: मनरेगा के अंतर्गत काम की माँग\n\n'
          'महोदय/महोदया,\n\n'
          'मैं $name, जॉब कार्ड संख्या $card, ग्राम $village का निवासी हूँ। '
          'मेरे परिवार के $people वयस्क सदस्य अकुशल शारीरिक काम करने को तैयार '
          'हैं।\n\n'
          'महात्मा गांधी राष्ट्रीय ग्रामीण रोज़गार गारंटी अधिनियम, 2005 के तहत '
          'मैं $days दिन के काम की माँग करता/करती हूँ। कृपया आवेदन की तारीख़ से '
          '15 दिन के भीतर काम उपलब्ध कराएँ।\n\n'
          'कृपया इस आवेदन की दिनांकित पावती दें।\n\n'
          'धन्यवाद,\n$name\nजॉब कार्ड: $card';
    }
    return 'To,\nThe Gram Panchayat / Programme Officer\n$village\n\n'
        'Date: $today\n\n'
        'Subject: Demand for work under MGNREGA\n\n'
        'Sir/Madam,\n\n'
        'I am $name, job card number $card, resident of $village. '
        '$people adult members of my household are willing to do unskilled '
        'manual work.\n\n'
        'Under the Mahatma Gandhi National Rural Employment Guarantee Act, '
        '2005, I demand $days days of work. Please provide work within 15 '
        'days of the date of this application.\n\n'
        'Please issue a dated receipt for this application.\n\n'
        'Thank you,\n$name\nJob card: $card';
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final fmt = DateFormat('d MMM yyyy');
    final wage = double.tryParse(_wage.text.trim()) ?? 0;
    final claimed = int.tryParse(_claimed.text.trim()) ?? 0;

    DateTime? due;
    int? overdueDays;
    if (_appliedOn != null) {
      due = _appliedOn!.add(const Duration(days: mgnregaWorkWithinDays));
      final today = DateTime.now();
      final d = DateTime(today.year, today.month, today.day);
      overdueDays = d.difference(due).inDays;
    }

    return ToolScaffold(
      goal: 1,
      title: hi ? 'मनरेगा: काम माँगें' : 'MGNREGA: demand work',
      children: [
        ToolNote(hi
            ? 'काम की गारंटी उसी परिवार को है जो लिखकर माँगे और पावती रखे। बिना '
                'पावती के यह साबित नहीं होता कि माँग कब की गई, और तब न 15 दिन की '
                'घड़ी चलती है, न बेरोज़गारी भत्ता बनता है।'
            : 'Work is guaranteed only to a household that asks in writing '
                'and keeps the dated receipt. Without it there is no proof of '
                'when you asked, so the 15-day clock never starts and no '
                'allowance can be claimed.'),
        ToolQuestion(hi ? 'आवेदन के लिए' : 'For the application'),
        ToolText(
          controller: _name,
          label: hi ? 'आपका नाम' : 'Your name',
          onChanged: (_) => setState(() {}),
        ),
        ToolText(
          controller: _village,
          label: hi ? 'गाँव / ग्राम पंचायत' : 'Village / Gram Panchayat',
          onChanged: (_) => setState(() {}),
        ),
        ToolText(
          controller: _jobCard,
          label: hi ? 'जॉब कार्ड संख्या' : 'Job card number',
          helper: hi
              ? 'न हो तो पंचायत में जॉब कार्ड के लिए भी आवेदन करें — वह मुफ़्त है।'
              : 'No card? Ask the Panchayat for one as well — it is free.',
          maxLength: 30,
          onChanged: (_) => setState(() {}),
        ),
        Row(children: [
          Expanded(
            child: ToolNumber(
              controller: _days,
              label: hi ? 'कितने दिन का काम' : 'Days of work',
              maxDigits: 3,
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ToolNumber(
              controller: _people,
              label: hi ? 'वयस्क सदस्य' : 'Adults',
              maxDigits: 2,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ]),
        ToolNote(hi
            ? 'एक परिवार को साल में $mgnregaDaysAYear दिन तक काम का हक़ है।'
            : 'A household is entitled to up to $mgnregaDaysAYear days of '
                'work in a year.'),
        CopyBlock(
          text: _draft(hi),
          note: hi
              ? 'इसे काग़ज़ पर उतारकर दो प्रतियाँ बनाएँ। एक पंचायत में जमा करें और '
                  'दूसरी पर "प्राप्त" की मुहर और तारीख़ लगवाकर अपने पास रखें। यही '
                  'पावती आपका सबसे ज़रूरी काग़ज़ है।'
              : 'Write it out in two copies. Hand one in at the Panchayat and '
                  'get the other stamped "received" with the date. That '
                  'receipt is the most important paper you will keep.',
        ),
        ToolQuestion(hi ? 'पहले ही आवेदन कर चुके हैं?' : 'Already applied?'),
        OutlinedButton.icon(
          onPressed: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: DateTime(now.year - 1),
              lastDate: now,
            );
            if (picked != null) setState(() => _appliedOn = picked);
          },
          icon: const Icon(Icons.event),
          label: Text(_appliedOn == null
              ? (hi ? 'आवेदन की तारीख़ चुनें' : 'Pick the date you applied')
              : fmt.format(_appliedOn!)),
        ),
        if (due != null && overdueDays != null) ...[
          if (overdueDays <= 0)
            ToolAnswer(
              headline: hi
                  ? 'काम ${fmt.format(due)} तक मिलना चाहिए'
                  : 'Work is due by ${fmt.format(due)}',
              detail: hi
                  ? '${-overdueDays} दिन बाक़ी हैं। तब तक काम न मिले तो उसी दिन से '
                      'बेरोज़गारी भत्ता बनता है।'
                  : '${-overdueDays} days to go. If no work comes by then, '
                      'the unemployment allowance starts from that day.',
              tone: ToolTone.good,
              icon: Icons.schedule,
            )
          else
            ToolAnswer(
              headline: hi
                  ? '$overdueDays दिन की देरी — भत्ता बनता है'
                  : '$overdueDays days late — an allowance is owed',
              detail: hi
                  ? 'क़ानून के मुताबिक़ काम ${fmt.format(due)} तक मिल जाना चाहिए था। '
                      'अब लिखकर बेरोज़गारी भत्ता माँगें।'
                  : 'The law required work by ${fmt.format(due)}. Ask for the '
                      'unemployment allowance, in writing.',
              tone: ToolTone.bad,
              icon: Icons.warning_amber_outlined,
            ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _wantAllowance,
            contentPadding: EdgeInsets.zero,
            title: Text(hi
                ? 'भत्ता कितना बनता है, हिसाब लगाएँ'
                : 'Work out what the allowance comes to'),
            onChanged: (v) => setState(() => _wantAllowance = v),
          ),
        ],
        if (_wantAllowance) ...[
          ToolNumber(
            controller: _wage,
            label: hi ? 'आपके राज्य की मनरेगा मज़दूरी दर' : 'Your state MGNREGA wage rate',
            suffix: hi ? '₹/दिन' : '₹/day',
            helper: hi
                ? 'जॉब कार्ड पर या पंचायत के बोर्ड पर लिखी होती है।'
                : 'Printed on the job card or on the Panchayat board.',
            decimal: true,
            maxDigits: 5,
            onChanged: (_) => setState(() {}),
          ),
          ToolNumber(
            controller: _claimed,
            label: hi
                ? 'इस साल पहले कितने दिन का भत्ता ले चुके हैं'
                : 'Allowance days already claimed this year',
            maxDigits: 3,
            onChanged: (_) => setState(() {}),
          ),
          if (wage > 0)
            Builder(builder: (context) {
              final rate = unemploymentAllowance(wage, claimed);
              final total = overdueDays == null || overdueDays <= 0
                  ? 0.0
                  : rate * overdueDays;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 6),
                  ToolLine(
                      hi ? 'मज़दूरी दर' : 'Wage rate', '₹${wage.round()}'),
                  ToolLine(
                    claimed < 30
                        ? (hi ? 'भत्ता (दर का एक-चौथाई)' : 'Allowance (quarter of the rate)')
                        : (hi ? 'भत्ता (दर का आधा)' : 'Allowance (half the rate)'),
                    '₹${rate.toStringAsFixed(0)}/${hi ? 'दिन' : 'day'}',
                  ),
                  if (total > 0)
                    ToolLine(
                        hi
                            ? '$overdueDays दिन का कुल'
                            : 'For $overdueDays days',
                        '₹${total.round()}',
                        strong: true),
                  ToolNote(hi
                      ? 'क़ानून यह सबसे कम सीमा तय करता है: पहले 30 दिन दर का एक-चौथाई, '
                          'उसके बाद आधा। राज्य इससे ज़्यादा दे सकता है।'
                      : 'The Act sets these as floors: a quarter of the rate '
                          'for the first 30 days in the year, half after '
                          'that. A state may pay more.'),
                ],
              );
            }),
        ],
        const SizedBox(height: 18),
        Text(hi ? 'काम मिलने के बाद के हक़' : 'Once the work starts',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const ToolChecklist(
          storageKey: 'mgnrega_rights_v1',
          items: [
            CheckItem('wages', 'Wages within a fortnight of the work',
                'काम के पंद्रह दिन के भीतर मज़दूरी',
                noteEn: 'Later than that, compensation for the delay is due.',
                noteHi: 'इससे देर हो तो देरी का मुआवज़ा बनता है।'),
            CheckItem('far', 'Beyond 5 km, 10% extra wage',
                '5 किमी से दूर काम पर 10% अतिरिक्त मज़दूरी',
                noteEn: 'For the travel and the living cost.',
                noteHi: 'आने-जाने और रहने के ख़र्च के लिए।'),
            CheckItem('water', 'Drinking water, shade and a first-aid box',
                'पीने का पानी, छाँव और फ़र्स्ट-एड बॉक्स'),
            CheckItem('children',
                'Someone paid to mind the children, if five or more are there',
                'पाँच या ज़्यादा बच्चे हों तो उनकी देखभाल के लिए एक कामगार, वेतन सहित'),
            CheckItem('muster', 'Your name on the muster roll each day',
                'हर दिन मस्टर रोल पर आपका नाम'),
          ],
        ),
        const SourceNote(
          text: 'Figures from the Act: 100 days (s.3), work within 15 days '
              'and the allowance rates (s.7), wages within a fortnight '
              '(s.3(3)), 5 km and 10% (Schedule II).',
          url: _actUrl,
        ),
      ],
    );
  }
}
