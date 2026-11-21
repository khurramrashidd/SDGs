import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Courts: which forum, a bounced cheque, a legal notice, the Lok Adalat,
/// and who gets a free lawyer by right.
///
/// The cheque-bounce clock is the one place a date calculator earns its
/// keep in law: section 138 of the Negotiable Instruments Act runs on three
/// short windows in a row, and missing the first one ends the criminal
/// remedy for good.

const _nalsaUrl = 'https://nalsa.gov.in/';
const _ecourtsUrl = 'https://ecourts.gov.in/';
const _nchUrl = 'https://consumerhelpline.gov.in/';

const legalAidNumber = '15100';

/// Negotiable Instruments Act 1881, section 138: notice within 30 days of
/// the bank's return memo; the drawer then has 15 days; the complaint is
/// filed within one month after that.
const chequeNoticeDays = 30;
const chequePayDays = 15;
const chequeComplaintMonths = 1;

// --- Which court ------------------------------------------------------

enum Problem { consumer, wages, family, property, bank, accident, rent }

class WhichCourtPage extends StatefulWidget {
  const WhichCourtPage({super.key});

  @override
  State<WhichCourtPage> createState() => _WhichCourtPageState();
}

class _WhichCourtPageState extends State<WhichCourtPage> {
  Problem? _p;

  ({String en, String hi, String costEn, String costHi}) _forum(Problem p) =>
      switch (p) {
        Problem.consumer => (
            en: 'The consumer commission - district, state or national, by the '
                'price paid. No lawyer needed. See goal 12.',
            hi: 'उपभोक्ता आयोग — चुकाए दाम के हिसाब से ज़िला, राज्य या राष्ट्रीय। वकील '
                'ज़रूरी नहीं। लक्ष्य 12 देखें।',
            costEn: 'No fee for a price up to ₹5 lakh',
            costHi: '₹5 लाख तक के दाम पर कोई शुल्क नहीं',
          ),
        Problem.wages => (
            en: 'The labour department first (the labour inspector or the '
                'wage authority), then the labour court. See goal 8.',
            hi: 'पहले श्रम विभाग (श्रम निरीक्षक या वेतन प्राधिकारी), फिर श्रम '
                'न्यायालय। लक्ष्य 8 देखें।',
            costEn: 'A complaint to the labour department costs nothing',
            costHi: 'श्रम विभाग में शिकायत मुफ़्त',
          ),
        Problem.family => (
            en: 'The family court - divorce, maintenance, custody. Where there '
                'is none, the district court.',
            hi: 'परिवार न्यायालय — तलाक़, गुज़ारा भत्ता, बच्चों की कस्टडी। जहाँ न हो, '
                'वहाँ ज़िला न्यायालय।',
            costEn: 'Court fee is small; a woman gets free legal aid by right',
            costHi: 'अदालती शुल्क कम; महिला को मुफ़्त कानूनी सहायता का हक़',
          ),
        Problem.property => (
            en: 'Revenue matters (record, mutation, demarcation) at the tehsil; '
                'title and partition at the civil court. See goals 11 and 15.',
            hi: 'राजस्व के मामले (रिकॉर्ड, दाख़िल-ख़ारिज, पैमाइश) तहसील में; '
                'मालिकाना हक़ और बँटवारा दीवानी अदालत में। लक्ष्य 11 और 15 देखें।',
            costEn: 'Civil court fee rises with the value of the property',
            costHi: 'दीवानी अदालत का शुल्क संपत्ति के मूल्य के साथ बढ़ता है',
          ),
        Problem.bank => (
            en: 'The bank\'s own grievance cell, then the RBI Ombudsman online '
                'after 30 days. Insurance: the insurer, then the Insurance '
                'Ombudsman.',
            hi: 'पहले बैंक का शिकायत विभाग, 30 दिन बाद रिज़र्व बैंक लोकपाल, ऑनलाइन। '
                'बीमा: पहले कंपनी, फिर बीमा लोकपाल।',
            costEn: 'Both ombudsmen are free',
            costHi: 'दोनों लोकपाल मुफ़्त हैं',
          ),
        Problem.accident => (
            en: 'The Motor Accident Claims Tribunal - for death or injury in a '
                'road accident. See "Road accident" in goal 11.',
            hi: 'मोटर दुर्घटना दावा न्यायाधिकरण — सड़क दुर्घटना में मृत्यु या चोट के '
                'लिए। लक्ष्य 11 में "सड़क दुर्घटना" देखें।',
            costEn: 'Minimal fee; many claims settle at a Lok Adalat',
            costHi: 'बहुत कम शुल्क; कई दावे लोक अदालत में तय होते हैं',
          ),
        Problem.rent => (
            en: 'The rent authority where the state has one; otherwise the '
                'civil court. See goal 11.',
            hi: 'जहाँ राज्य में किराया प्राधिकारी है, वहाँ; नहीं तो दीवानी अदालत। '
                'लक्ष्य 11 देखें।',
            costEn: 'Fee is set by the state',
            costHi: 'शुल्क राज्य तय करता है',
          ),
      };

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final f = _p == null ? null : _forum(_p!);

    return ToolScaffold(
      goal: 16,
      title: hi ? 'मेरी समस्या के लिए कौन सी अदालत' : 'Which court or forum for my problem',
      children: [
        ToolNote(hi
            ? 'ज़्यादातर झगड़ों के लिए दीवानी अदालत से सस्ता और तेज़ कोई ख़ास मंच होता '
                'है। ग़लत जगह जाना महीनों बर्बाद करता है।'
            : 'Most disputes have a special forum that is cheaper and faster '
                'than the civil court. Going to the wrong one wastes months.'),
        ToolQuestion(hi ? 'झगड़ा किस बारे में है' : 'What is the dispute about'),
        for (final p in Problem.values)
          SelectionTile(
            label: switch (p) {
              Problem.consumer => hi ? 'ख़रीदा सामान या सेवा' : 'Something bought, or a service',
              Problem.wages => hi ? 'मज़दूरी या नौकरी' : 'Wages or a job',
              Problem.family => hi ? 'परिवार — शादी, गुज़ारा, बच्चे' : 'Family - marriage, maintenance, children',
              Problem.property => hi ? 'ज़मीन या मकान' : 'Land or a house',
              Problem.bank => hi ? 'बैंक या बीमा' : 'A bank or insurance',
              Problem.accident => hi ? 'सड़क दुर्घटना का मुआवज़ा' : 'Road accident compensation',
              Problem.rent => hi ? 'किराया' : 'Rent',
            },
            selected: _p == p,
            onTap: () => setState(() => _p = p),
          ),
        if (f != null) ...[
          ToolAnswer(
            headline: hi ? 'यहाँ जाएँ' : 'Go here',
            detail: hi ? f.hi : f.en,
            tone: ToolTone.good,
            icon: Icons.account_balance_outlined,
          ),
          const SizedBox(height: 8),
          ToolLine(hi ? 'ख़र्च' : 'Cost', hi ? f.costHi : f.costEn),
          const SizedBox(height: 10),
          ToolNote(hi
              ? 'लगभग हर तरह के झगड़े में पहले लोक अदालत या मध्यस्थता का रास्ता भी है '
                  '— मुफ़्त, और फ़ैसला अंतिम। इसी लक्ष्य में "लोक अदालत" देखें।'
              : 'Nearly every kind of dispute can also go first to a Lok Adalat '
                  'or mediation - free, and the outcome final. See "Lok Adalat" '
                  'in this goal.'),
          const SourceNote(text: 'eCourts services', url: _ecourtsUrl),
          if (_p == Problem.consumer)
            const SourceNote(text: 'National Consumer Helpline', url: _nchUrl),
        ],
      ],
    );
  }
}

// --- Cheque bounced ---------------------------------------------------

class ChequeBouncePage extends StatefulWidget {
  const ChequeBouncePage({super.key});

  @override
  State<ChequeBouncePage> createState() => _ChequeBouncePageState();
}

class _ChequeBouncePageState extends State<ChequeBouncePage> {
  DateTime? _memo;
  final _amount = TextEditingController();
  final _drawer = TextEditingController();
  final _cheque = TextEditingController();
  final _bank = TextEditingController();

  @override
  void dispose() {
    for (final c in [_amount, _drawer, _cheque, _bank]) {
      c.dispose();
    }
    super.dispose();
  }

  String _d(DateTime t) => '${t.day}/${t.month}/${t.year}';

  String _or(TextEditingController c) =>
      c.text.trim().isEmpty ? '______' : c.text.trim();

  Future<void> _pick() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _memo ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (picked != null) setState(() => _memo = picked);
  }

  String _notice(bool hi) {
    final memo = _memo == null ? '______' : _d(_memo!);
    if (hi) {
      return 'सेवा में,\n'
          '${_or(_drawer)}\n\n'
          'विषय: परक्राम्य लिखत अधिनियम 1881 की धारा 138 के अंतर्गत माँग सूचना\n\n'
          'आपके द्वारा मुझे दिया गया चेक संख्या ${_or(_cheque)}, राशि '
          '₹${_or(_amount)}, बैंक ${_or(_bank)}, भुगतान के लिए प्रस्तुत करने पर '
          'अनादरित (बाउंस) हो गया, जिसकी सूचना बैंक ने दिनांक $memo के ज्ञापन से '
          'दी।\n\n'
          'आपसे माँग की जाती है कि इस सूचना की प्राप्ति के $chequePayDays दिन के भीतर '
          'उक्त राशि ₹${_or(_amount)} का भुगतान करें। ऐसा न करने पर आपके विरुद्ध '
          'धारा 138 के अंतर्गत आपराधिक शिकायत दर्ज की जाएगी।\n\n'
          'दिनांक: ____________\n'
          'नाम: ____________\n'
          'पता: ____________';
    }
    return 'To,\n'
        '${_or(_drawer)}\n\n'
        'Subject: Demand notice under section 138 of the Negotiable '
        'Instruments Act 1881\n\n'
        'Cheque number ${_or(_cheque)} for ₹${_or(_amount)}, drawn on '
        '${_or(_bank)}, given by you to me, was dishonoured on presentation, '
        'as the bank informed me by its return memo dated $memo.\n\n'
        'You are called upon to pay the said sum of ₹${_or(_amount)} within '
        '$chequePayDays days of receiving this notice. Failing that, a '
        'criminal complaint will be filed against you under section 138.\n\n'
        'Date: ____________\n'
        'Name: ____________\n'
        'Address: ____________';
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final memo = _memo;
    final noticeBy = memo?.add(const Duration(days: chequeNoticeDays));
    final today = DateTime.now();
    final daysLeft = noticeBy == null
        ? null
        : DateTime(noticeBy.year, noticeBy.month, noticeBy.day)
            .difference(DateTime(today.year, today.month, today.day))
            .inDays;

    return ToolScaffold(
      goal: 16,
      title: hi ? 'चेक बाउंस हो गया' : 'Cheque bounced',
      children: [
        ToolNote(hi
            ? 'चेक बाउंस पर आपराधिक मामला (धारा 138) तीन छोटी समय-सीमाओं से चलता है। '
                'पहली चूक गई तो यह रास्ता हमेशा के लिए बंद — फिर सिर्फ़ पैसा वसूली का '
                'दीवानी मुक़दमा बचता है। गिनती बैंक के लौटाने वाले ज्ञापन (रिटर्न मेमो) की '
                'तारीख़ से शुरू होती है।'
            : 'The criminal case for a bounced cheque (section 138) runs on '
                'three short windows in a row. Miss the first and that route is '
                'closed for good - only a civil recovery suit remains. The count '
                'starts from the date of the bank\'s return memo.'),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _pick,
          icon: const Icon(Icons.event_outlined),
          label: Text(memo == null
              ? (hi ? 'बैंक के ज्ञापन की तारीख़ चुनें' : 'Pick the bank memo date')
              : (hi ? 'ज्ञापन: ${_d(memo)}' : 'Memo: ${_d(memo)}')),
        ),
        if (noticeBy != null && daysLeft != null) ...[
          const SizedBox(height: 10),
          ToolAnswer(
            headline: daysLeft >= 0
                ? (hi
                    ? 'नोटिस ${_d(noticeBy)} तक भेजें — $daysLeft दिन बाक़ी'
                    : 'Send the notice by ${_d(noticeBy)} - $daysLeft days left')
                : (hi
                    ? 'नोटिस की समय सीमा ${_d(noticeBy)} को निकल गई'
                    : 'The notice deadline passed on ${_d(noticeBy)}'),
            detail: daysLeft >= 0
                ? (hi
                    ? 'नोटिस मिलने के बाद चेक देने वाले के पास $chequePayDays दिन हैं। '
                        'वे भी बीत जाएँ तो उसके बाद $chequeComplaintMonths महीने के भीतर '
                        'अदालत में शिकायत दर्ज करनी होती है — उस अदालत में जहाँ आपका बैंक '
                        'खाता है।'
                    : 'After receiving the notice, the drawer has '
                        '$chequePayDays days. When those pass too, the complaint '
                        'must be filed in court within $chequeComplaintMonths '
                        'month - in the court where your bank account is.')
                : (hi
                    ? 'धारा 138 का आपराधिक रास्ता अब आम तौर पर नहीं बचता। पैसा वसूली का '
                        'दीवानी मुक़दमा अभी भी हो सकता है। फिर से उसी चेक को उसकी '
                        'वैधता (तारीख़ से तीन महीने) के भीतर जमा करने पर नई गिनती शुरू हो '
                        'सकती है — वकील से पूछें।'
                    : 'The section 138 criminal route is generally gone now. A '
                        'civil suit for recovery is still open. Presenting the '
                        'same cheque again within its validity (three months '
                        'from its date) can start a fresh count - ask a '
                        'lawyer.'),
            tone: daysLeft >= 0 ? ToolTone.warn : ToolTone.bad,
            icon: Icons.timer_outlined,
          ),
        ],
        ToolQuestion(hi ? 'नोटिस का ब्योरा' : 'Details for the notice'),
        ToolText(
          controller: _drawer,
          label: hi ? 'चेक देने वाले का नाम और पता' : 'Drawer\'s name and address',
          maxLength: 150,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ToolText(
                controller: _cheque,
                label: hi ? 'चेक संख्या' : 'Cheque number',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _amount,
                label: hi ? 'राशि (₹)' : 'Amount (₹)',
                maxDigits: 10,
                icon: Icons.currency_rupee,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ToolText(
          controller: _bank,
          label: hi ? 'किस बैंक का चेक' : 'Bank the cheque is drawn on',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        CopyBlock(
          text: _notice(hi),
          note: hi
              ? 'रजिस्टर्ड डाक (पावती के साथ) से भेजें, और चाहें तो साथ में व्हाट्सऐप या '
                  'ईमेल से भी। डाक की रसीद और पावती संभालकर रखें — शिकायत में यही लगती '
                  'हैं। बड़ी रक़म हो तो वकील से नोटिस भिजवाना बेहतर है।'
              : 'Send it by registered post with acknowledgement, and by '
                  'WhatsApp or email too if you like. Keep the postal receipt '
                  'and the acknowledgement - the complaint needs them. For a '
                  'large amount, having a lawyer send it is better.',
        ),
        const SizedBox(height: 10),
        ToolNote(hi
            ? 'चेक बाउंस का मामला लोक अदालत में आपसी समझौते से भी निपट सकता है, बिना '
                'शुल्क।'
            : 'A cheque-bounce case can also be settled by agreement at a Lok '
                'Adalat, without fees.'),
        const SourceNote(
            text: 'National Legal Services Authority', url: _nalsaUrl),
      ],
    );
  }
}

// --- Legal notice received --------------------------------------------

class LegalNoticePage extends StatelessWidget {
  const LegalNoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 16,
      title: hi ? 'क़ानूनी नोटिस मिला' : 'Legal notice received',
      children: [
        ToolAnswer(
          headline: hi ? 'घबराएँ नहीं, पर अनदेखा भी नहीं' : 'Do not panic, and do not ignore it',
          detail: hi
              ? 'क़ानूनी नोटिस अदालत का आदेश नहीं है — यह सामने वाले की माँग है, जो अक्सर '
                  'मुक़दमे से पहले भेजी जाती है। पर उसे अनदेखा करने से बाद में अदालत में '
                  'आपका पक्ष कमज़ोर दिख सकता है, और कुछ मामलों (जैसे चेक बाउंस) में '
                  'नोटिस के बाद समय-सीमा चलने लगती है।'
              : 'A legal notice is not a court order - it is the other side\'s '
                  'demand, usually sent before a case. But ignoring it can make '
                  'your side look weaker in court later, and in some matters '
                  '(a bounced cheque, for one) a clock starts running from the '
                  'notice.',
          tone: ToolTone.plain,
          icon: Icons.mail_outline,
        ),
        const SizedBox(height: 12),
        Text(hi ? 'क्या करें' : 'What to do',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'लिफ़ाफ़ा और नोटिस संभालें, और जिस दिन मिला वह तारीख़ लिख लें।',
                  'पढ़ें: किसने भेजा, क्या माँगा है, किस आधार पर, और कितने दिन दिए हैं।',
                  'अपने काग़ज़ इकट्ठे करें — समझौते, रसीदें, संदेश, बैंक का ब्योरा।',
                  'ज़िला विधिक सेवा प्राधिकरण या किसी वकील को दिखाएँ। मुफ़्त सलाह '
                      '$legalAidNumber पर भी।',
                  'जवाब लिखित में दें, आम तौर पर वकील के ज़रिये। जवाब की नक़ल और डाक '
                      'की रसीद रखें।',
                ]
              : const [
                  'Keep the envelope and the notice, and write down the date it '
                      'arrived.',
                  'Read: who sent it, what they want, on what ground, and how '
                      'many days they give.',
                  'Gather your own papers - agreements, receipts, messages, bank '
                      'records.',
                  'Show it to the District Legal Services Authority or a lawyer. '
                      'Free advice on $legalAidNumber too.',
                  'Reply in writing, usually through a lawyer. Keep a copy of '
                      'the reply and the postal receipt.',
                ],
        ),
        const SizedBox(height: 12),
        ToolDonts(
          heading: hi ? 'न करें' : 'Do not',
          items: hi
              ? const [
                  'फ़ोन पर या संदेश में ग़लती मान लेने वाली बात न लिखें — वह सबूत बनती है',
                  'डर से कोई रक़म बिना लिखत-पढ़त के न दें',
                  'नोटिस में दिए समय के बाद भी चुप न बैठें; अदालत का समन आए तो उसकी '
                      'तारीख़ पर हाज़िर होना ज़रूरी है',
                  'नोटिस भेजने वाले के फ़ोन पर बताए किसी खाते में पैसा न भेजें — नक़ली '
                      'नोटिस भेजकर ठगी आम है',
                ]
              : const [
                  'Do not write anything admitting fault on the phone or in a '
                      'message - it becomes evidence',
                  'Do not pay any sum out of fear without a written record',
                  'Do not stay silent past the notice\'s time; if a court '
                      'summons comes, appearing on its date is essential',
                  'Do not send money to an account given over the phone by the '
                      'sender - fake notices are a common fraud',
                ],
        ),
        const SourceNote(
            text: 'National Legal Services Authority', url: _nalsaUrl),
      ],
    );
  }
}

// --- Lok Adalat -------------------------------------------------------

class LokAdalatPage extends StatelessWidget {
  const LokAdalatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 16,
      title: hi ? 'लोक अदालत: बिना शुल्क समझौता' : 'Lok Adalat: settle without fees',
      children: [
        ToolNote(hi
            ? 'लोक अदालत में दोनों पक्ष आपसी सहमति से झगड़ा निपटाते हैं, एक जज और '
                'एक सदस्य की मदद से। कोई शुल्क नहीं लगता, और अदालत में चल रहा मामला यहाँ '
                'निपटे तो पहले जमा किया शुल्क भी लौटता है। फ़ैसला अंतिम होता है — उसकी '
                'अपील नहीं होती — इसलिए सहमति सोचकर दें।'
            : 'At a Lok Adalat the two sides settle by agreement, helped by a '
                'judge and a member. There is no fee, and if a case pending in '
                'court is settled here, the court fee already paid is refunded. '
                'The award is final - there is no appeal - so agree with care.'),
        const SizedBox(height: 12),
        Text(hi ? 'यहाँ क्या निपट सकता है' : 'What can be settled there',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'बैंक के ऋण और वसूली',
                  'बिजली और पानी के बिल',
                  'चेक बाउंस',
                  'सड़क दुर्घटना का मुआवज़ा',
                  'परिवार के झगड़े — तलाक़ छोड़कर',
                  'मज़दूरी और नौकरी के मामले',
                  'ज़मीन अधिग्रहण का मुआवज़ा',
                  'छोटे आपराधिक मामले जिनमें समझौता क़ानूनन हो सकता है',
                ]
              : const [
                  'Bank loans and recovery',
                  'Electricity and water bills',
                  'Bounced cheques',
                  'Road accident compensation',
                  'Family disputes - except divorce',
                  'Wage and employment matters',
                  'Land acquisition compensation',
                  'Minor criminal cases that the law allows to be compounded',
                ],
        ),
        const SizedBox(height: 12),
        Text(hi ? 'कैसे पहुँचें' : 'How to get there',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'राष्ट्रीय लोक अदालत साल में कई बार, पूरे देश में एक ही दिन लगती है। '
                      'अगली तारीख़ राष्ट्रीय विधिक सेवा प्राधिकरण की वेबसाइट या ज़िला '
                      'विधिक सेवा प्राधिकरण से पता करें।',
                  'चल रहे मामले के लिए: अपनी अदालत में अर्ज़ी दें कि मामला लोक अदालत '
                      'भेजा जाए।',
                  'मुक़दमे से पहले के मामले के लिए: ज़िला विधिक सेवा प्राधिकरण में सादे '
                      'काग़ज़ पर आवेदन। वे दूसरे पक्ष को बुलाते हैं।',
                  'उस दिन अपने सारे काग़ज़ साथ ले जाएँ।',
                ]
              : const [
                  'The National Lok Adalat sits several times a year, on the same '
                      'day across the country. Find the next date on the National '
                      'Legal Services Authority\'s site or from the District '
                      'Legal Services Authority.',
                  'For a pending case: apply in your court for the matter to be '
                      'referred to the Lok Adalat.',
                  'For a matter not yet in court: apply on plain paper at the '
                      'District Legal Services Authority. They summon the other '
                      'side.',
                  'Take all your papers on the day.',
                ],
        ),
        const SourceNote(
            text: 'National Legal Services Authority', url: _nalsaUrl),
      ],
    );
  }
}

// --- Free legal aid ---------------------------------------------------

class LegalAidPage extends StatefulWidget {
  const LegalAidPage({super.key});

  @override
  State<LegalAidPage> createState() => _LegalAidPageState();
}

class _LegalAidPageState extends State<LegalAidPage> {
  final _picked = <int>{};

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final groups = hi
        ? const [
            'महिला',
            '18 साल से कम उम्र का बच्चा',
            'अनुसूचित जाति या अनुसूचित जनजाति',
            'दिव्यांग व्यक्ति',
            'मानसिक रोग से पीड़ित व्यक्ति',
            'मानव तस्करी या बेगार का शिकार',
            'आपदा, जातीय हिंसा, बाढ़, सूखा या भूकंप का पीड़ित',
            'कारख़ाने का मज़दूर',
            'हिरासत या जेल में व्यक्ति',
            'सालाना आय राज्य की तय सीमा से कम',
          ]
        : const [
            'A woman',
            'A child under 18',
            'A member of a Scheduled Caste or Scheduled Tribe',
            'A person with a disability',
            'A person with a mental illness',
            'A victim of trafficking or forced labour',
            'A victim of a disaster, ethnic violence, flood, drought or '
                'earthquake',
            'An industrial worker',
            'A person in custody or in jail',
            'Annual income below the limit the state sets',
          ];

    return ToolScaffold(
      goal: 16,
      title: hi ? 'मुफ़्त कानूनी सहायता: क्या मैं हक़दार हूँ' : 'Free legal aid: am I entitled',
      children: [
        ToolNote(hi
            ? 'विधिक सेवा प्राधिकरण अधिनियम की धारा 12 में लिखा है कि किसे मुफ़्त वकील '
                'हक़ से मिलता है — इनमें से किसी एक में आना काफ़ी है। जो लागू हो, चुनें।'
            : 'Section 12 of the Legal Services Authorities Act lists who gets a '
                'free lawyer by right - falling in any one group is enough. Pick '
                'whichever apply.'),
        for (var i = 0; i < groups.length; i++)
          SelectionTile(
            label: groups[i],
            selected: _picked.contains(i),
            onTap: () => setState(() {
              if (!_picked.remove(i)) _picked.add(i);
            }),
          ),
        if (_picked.isNotEmpty) ...[
          ToolAnswer(
            headline: hi ? 'आप मुफ़्त कानूनी सहायता के हक़दार हैं' : 'You are entitled to free legal aid',
            detail: hi
                ? 'इसमें वकील, अदालत का शुल्क, काग़ज़ बनवाने और नक़ल का ख़र्च — सब शामिल '
                    'है। हक़ आपका है, एहसान नहीं।'
                : 'It covers the lawyer, the court fee, drafting and copies - all '
                    'of it. It is your right, not a favour.',
            tone: ToolTone.good,
            icon: Icons.verified_user_outlined,
          ),
          const SizedBox(height: 10),
          ToolSteps(
            steps: hi
                ? const [
                    'राष्ट्रीय हेल्पलाइन $legalAidNumber पर फ़ोन करें।',
                    'या ज़िला न्यायालय में ज़िला विधिक सेवा प्राधिकरण (डीएलएसए) के दफ़्तर, '
                        'या तहसील स्तर पर तालुका विधिक सेवा समिति जाएँ। सादे काग़ज़ पर '
                        'आवेदन काफ़ी है।',
                    'गाँव में जन सेवा केंद्र पर "टेली-लॉ" से वीडियो पर वकील से मुफ़्त सलाह '
                        'मिलती है।',
                    'आय वाले वर्ग में आय का स्व-घोषणा पत्र आम तौर पर काफ़ी होता है।',
                  ]
                : const [
                    'Call the national helpline on $legalAidNumber.',
                    'Or go to the District Legal Services Authority (DLSA) at the '
                        'district court, or the taluk legal services committee at '
                        'the tehsil. An application on plain paper is enough.',
                    'In a village, "Tele-Law" at the common service centre gives '
                        'free advice from a lawyer by video.',
                    'For the income group, a self-declaration of income is '
                        'usually enough.',
                  ],
          ),
        ] else
          ToolNote(hi
              ? 'किसी वर्ग में न आएँ तब भी कुछ राज्य वरिष्ठ नागरिकों और ट्रांसजेंडर '
                  'व्यक्तियों को भी यह सहायता देते हैं, और "टेली-लॉ" की सलाह सबके लिए '
                  'मुफ़्त है।'
              : 'Even outside these groups, some states also extend this to '
                  'senior citizens and transgender persons, and "Tele-Law" advice '
                  'is free for everyone.'),
        const SourceNote(
            text: 'National Legal Services Authority', url: _nalsaUrl),
      ],
    );
  }
}
