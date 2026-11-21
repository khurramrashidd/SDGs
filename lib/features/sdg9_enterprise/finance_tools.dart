import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Four screens about money coming in and going out of a small
/// enterprise.
///
/// The delayed-payment screen is the one with a law behind it that almost
/// nobody uses. A registered micro or small enterprise is entitled to
/// payment within 45 days, and to compound interest at three times the
/// RBI bank rate after that - and there is a council in every district
/// that hears the case free. Suppliers write the money off instead,
/// because nobody told them.

const _samadhaanUrl = 'https://samadhaan.msme.gov.in/';
const _vishwakarmaUrl = 'https://pmvishwakarma.gov.in/';
const _vishwakarmaSidbiUrl =
    'https://www.sidbi.in/blog/how-to-apply-for-pm-vishwakarma-scheme';
const _rbiOmbudsmanUrl = 'https://cms.rbi.org.in/';
const _mudraUrl = 'https://www.mudra.org.in/';

/// The MSMED Act's payment limits. 45 days is the outer limit even where
/// the agreement says more; interest runs at three times the bank rate,
/// compounded monthly.
const msmePayDaysAgreed = 45;
const msmePayDaysNoAgreement = 15;
const msmeInterestMultiple = 3;

// --- Buyer has not paid -----------------------------------------------

class DelayedPaymentPage extends StatefulWidget {
  const DelayedPaymentPage({super.key});

  @override
  State<DelayedPaymentPage> createState() => _DelayedPaymentPageState();
}

class _DelayedPaymentPageState extends State<DelayedPaymentPage> {
  final _amount = TextEditingController();
  final _days = TextEditingController();
  final _bankRate = TextEditingController(text: '6.5');
  bool _registered = true;

  @override
  void dispose() {
    for (final c in [_amount, _days, _bankRate]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    final days = double.tryParse(_days.text.trim()) ?? 0;
    final bankRate = double.tryParse(_bankRate.text.trim()) ?? 0;

    final overdueDays = days - msmePayDaysAgreed;
    final annualRate = bankRate * msmeInterestMultiple;
    // Compounded monthly on the overdue period.
    final months = overdueDays > 0 ? overdueDays / 30 : 0.0;
    final interest = (amount > 0 && months > 0 && annualRate > 0)
        ? amount * (math.pow(1 + annualRate / 1200, months).toDouble() - 1)
        : null;

    return ToolScaffold(
      goal: 9,
      title: hi ? 'ख़रीदार ने 45 दिन में पैसा नहीं दिया' : 'The buyer has not paid in 45 days',
      children: [
        ToolNote(hi
            ? 'यह उन क़ानूनों में है जिनका सबसे कम इस्तेमाल होता है। पंजीकृत सूक्ष्म '
                'या लघु उद्यम को माल या सेवा देने के बाद भुगतान पाने का क़ानूनी हक़ है '
                '— समझौते में जो भी लिखा हो, बाहरी सीमा $msmePayDaysAgreed दिन है। '
                'उसके बाद ब्याज बनता है, और वह आम ब्याज नहीं: रिज़र्व बैंक की दर का '
                'तीन गुना, महीने-दर-महीने चक्रवृद्धि। और सुनवाई ज़िले की परिषद में '
                'मुफ़्त होती है।'
            : 'This is among the least used laws there is. A registered micro '
                'or small enterprise has a legal right to be paid after '
                'supplying goods or services - whatever the agreement says, '
                'the outer limit is $msmePayDaysAgreed days. After that '
                'interest accrues, and not ordinary interest: three times the '
                'Reserve Bank\'s rate, compounded monthly. And the hearing at '
                'the district council is free.'),
        SwitchListTile(
          value: _registered,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'उद्यम (Udyam) पंजीकरण है'
              : 'I have Udyam registration'),
          onChanged: (v) => setState(() => _registered = v),
        ),
        if (!_registered)
          ToolAnswer(
            headline: hi
                ? 'पहले उद्यम पंजीकरण — यही इस हक़ की चाबी है'
                : 'Udyam registration first - it is the key to this right',
            detail: hi
                ? 'यह हक़ पंजीकृत सूक्ष्म और लघु उद्यमों का है। पंजीकरण मुफ़्त है और '
                    'कुछ मिनट का काम — इसी लक्ष्य में "सूक्ष्म, लघु या मध्यम" वाली '
                    'स्क्रीन देखें। आज पंजीकरण कराने पर आगे के बिलों पर यह हक़ लागू '
                    'होगा, इसलिए यह काम टालने लायक़ नहीं है।'
                : 'This right belongs to registered micro and small '
                    'enterprises. Registration is free and takes minutes - '
                    'see "Am I micro, small or medium" in this goal. '
                    'Registering today brings future bills under the right, '
                    'so it is not a thing to leave.',
            tone: ToolTone.warn,
            icon: Icons.app_registration_outlined,
          )
        else ...[
          ToolQuestion(hi ? 'बिल और दिन' : 'The bill and the days'),
          ToolNumber(
            controller: _amount,
            label: hi ? 'बक़ाया रक़म (₹)' : 'Amount outstanding (₹)',
            decimal: true,
            maxDigits: 10,
            icon: Icons.currency_rupee,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          ToolNumber(
            controller: _days,
            label: hi
                ? 'माल देने से अब तक कितने दिन'
                : 'Days since you supplied',
            decimal: true,
            maxDigits: 5,
            icon: Icons.calendar_today_outlined,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          ToolNumber(
            controller: _bankRate,
            label: hi
                ? 'रिज़र्व बैंक की दर, % (आज की)'
                : 'RBI bank rate, % (today\'s)',
            decimal: true,
            maxDigits: 5,
            icon: Icons.percent,
            onChanged: (_) => setState(() {}),
          ),
          ToolNote(hi
              ? 'रिज़र्व बैंक की दर बदलती रहती है, इसलिए यहाँ तय नहीं लिखी — आज की '
                  'दर रिज़र्व बैंक की वेबसाइट पर या बैंक से पूछकर डालें। क़ानून में '
                  'ब्याज इसी दर का तीन गुना है।'
              : 'The RBI bank rate changes, so it is not fixed here - put in '
                  'today\'s rate from the RBI site or your bank. The law sets '
                  'the interest at three times it.'),
          if (amount > 0 && days > 0) ...[
            ToolAnswer(
              headline: overdueDays > 0
                  ? (hi
                      ? '${overdueDays.round()} दिन की देरी'
                      : '${overdueDays.round()} days overdue')
                  : (hi
                      ? 'अभी $msmePayDaysAgreed दिन के भीतर है'
                      : 'Still within $msmePayDaysAgreed days'),
              detail: overdueDays > 0
                  ? (hi
                      ? 'ब्याज की दर ${annualRate.toStringAsFixed(1)}% सालाना बनती '
                          'है — रिज़र्व बैंक की दर का तीन गुना, चक्रवृद्धि।'
                          '${interest != null ? ' इस बिल पर अब तक लगभग ₹${interest.round()} ब्याज, यानी कुल ₹${(amount + interest).round()}।' : ''}'
                      : 'The interest rate works out to '
                          '${annualRate.toStringAsFixed(1)}% a year - three '
                          'times the RBI rate, compounded.'
                          '${interest != null ? ' On this bill that is about ₹${interest.round()} of interest so far, making ₹${(amount + interest).round()} in all.' : ''}')
                  : (hi
                      ? 'समझौते में जो अवधि तय हुई हो वह चलेगी, लेकिन '
                          '$msmePayDaysAgreed दिन से ज़्यादा नहीं। अगर कोई लिखित '
                          'समझौता नहीं है तो सीमा $msmePayDaysNoAgreement दिन की होती '
                          'है। तारीख़ लिख लें — उसके बाद ब्याज अपने आप बनने लगता है, '
                          'माँगने की ज़रूरत नहीं।'
                      : 'Whatever period the agreement fixed applies, but not '
                          'beyond $msmePayDaysAgreed days. With no written '
                          'agreement the limit is '
                          '$msmePayDaysNoAgreement days. Note the date - '
                          'after it the interest accrues by itself, without '
                          'being asked for.'),
              tone: overdueDays > 0 ? ToolTone.warn : ToolTone.plain,
              icon: Icons.schedule,
            ),
            if (interest != null) ...[
              const SizedBox(height: 10),
              ToolLine(hi ? 'मूल बक़ाया' : 'Principal outstanding',
                  '₹${amount.round()}'),
              ToolLine(hi ? 'ब्याज, अब तक' : 'Interest so far',
                  '₹${interest.round()}', strong: true),
              ToolLine(hi ? 'कुल' : 'Total',
                  '₹${(amount + interest).round()}', strong: true),
              const SizedBox(height: 8),
              ToolNote(hi
                  ? 'यह हिसाब अनुमान है, और परिषद अपना हिसाब लगाती है। लेकिन यह '
                      'संख्या माँग-पत्र में लिखने लायक़ है: ख़रीदार को यह दिख जाना कि '
                      'देर करना सस्ता नहीं है, अक्सर भुगतान करा देता है।'
                  : 'This is an estimate and the council makes its own '
                      'calculation. But the figure is worth putting in the '
                      'demand letter: a buyer seeing that delay is not cheap '
                      'often pays.'),
            ],
            const SizedBox(height: 14),
            Text(hi ? 'क्या करें' : 'What to do',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800)),
            ToolSteps(
              steps: hi
                  ? const [
                      'पहले लिखित माँग-पत्र भेजें, जिसमें बिल की तारीख़, रक़म, '
                          '45 दिन की सीमा और बनने वाला ब्याज लिखा हो। नक़ल रखें।',
                      'एमएसएमई समाधान पोर्टल पर ऑनलाइन मामला दर्ज करें। कोई फ़ीस '
                          'नहीं, और इसके लिए वकील की ज़रूरत नहीं।',
                      'मामला ज़िले की सूक्ष्म एवं लघु उद्यम सुविधा परिषद (MSEFC) के '
                          'पास जाता है, जो दोनों पक्षों को सुनकर आदेश देती है।',
                      'आदेश के बाद भी भुगतान न हो तो वह वसूली योग्य होता है।',
                      'एक बात याद रखें: मामला दर्ज कराने से ख़रीदार के साथ रिश्ता '
                          'ख़राब होने का डर सबको होता है, और यही डर इस क़ानून को बेकार '
                          'रखता है। माँग-पत्र भेजना अक्सर काफ़ी हो जाता है।',
                    ]
                  : const [
                      'Send a written demand first, stating the invoice date, '
                          'the amount, the 45-day limit and the interest '
                          'accruing. Keep a copy.',
                      'File the case online on the MSME Samadhaan portal. No '
                          'fee, and no lawyer needed.',
                      'It goes to the district Micro and Small Enterprise '
                          'Facilitation Council, which hears both sides and '
                          'passes an order.',
                      'If payment still does not follow the order, it is '
                          'recoverable.',
                      'One thing to hold in mind: everyone fears souring the '
                          'relationship with the buyer by filing, and that '
                          'fear is what keeps this law unused. Sending the '
                          'demand letter is often enough on its own.',
                    ],
            ),
            const SourceNote(
                text: 'MSME Samadhaan - delayed payments',
                url: _samadhaanUrl),
          ],
        ],
      ],
    );
  }
}

// --- Loan EMI ---------------------------------------------------------

class LoanEmiPage extends StatefulWidget {
  const LoanEmiPage({super.key});

  @override
  State<LoanEmiPage> createState() => _LoanEmiPageState();
}

class _LoanEmiPageState extends State<LoanEmiPage> {
  final _amount = TextEditingController();
  final _rate = TextEditingController();
  final _months = TextEditingController(text: '36');

  @override
  void dispose() {
    for (final c in [_amount, _rate, _months]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final p = double.tryParse(_amount.text.trim()) ?? 0;
    final annual = double.tryParse(_rate.text.trim()) ?? 0;
    final n = int.tryParse(_months.text.trim()) ?? 0;

    double? emi;
    if (p > 0 && n > 0) {
      final r = annual / 12 / 100;
      if (r <= 0) {
        emi = p / n;
      } else {
        final f = math.pow(1 + r, n).toDouble();
        emi = p * r * f / (f - 1);
      }
    }
    final total = emi == null ? null : emi * n;
    final interest = total == null ? null : total - p;

    return ToolScaffold(
      goal: 9,
      title: hi ? 'किस्त और कुल ब्याज' : 'EMI and total interest',
      children: [
        ToolNote(hi
            ? 'ऋण लेने से पहले दो संख्याएँ देख लेनी चाहिए: महीने की किस्त, और पूरे '
                'समय में ब्याज कितना बनेगा। दुकान या बैंक में पहली संख्या बताई जाती '
                'है, दूसरी नहीं — और फ़ैसला दूसरी से बदलता है।'
            : 'Two numbers should be seen before borrowing: the monthly '
                'instalment, and what the interest adds up to over the whole '
                'term. A shop or a bank quotes the first and not the second - '
                'and it is the second that changes the decision.'),
        ToolQuestion(hi ? 'ऋण की जानकारी' : 'The loan'),
        ToolNumber(
          controller: _amount,
          label: hi ? 'रक़म (₹)' : 'Amount (₹)',
          decimal: true,
          maxDigits: 10,
          icon: Icons.currency_rupee,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _rate,
                label: hi ? 'ब्याज, सालाना %' : 'Rate, % a year',
                decimal: true,
                maxDigits: 5,
                icon: Icons.percent,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _months,
                label: hi ? 'कितने महीने' : 'Months',
                maxDigits: 4,
                icon: Icons.schedule,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        if (emi != null && total != null && interest != null) ...[
          ToolAnswer(
            headline: hi
                ? 'महीने की किस्त ₹${emi.round()}'
                : 'Monthly instalment ₹${emi.round()}',
            detail: hi
                ? 'पूरे $n महीनों में कुल ₹${total.round()} जाएगा, जिसमें '
                    '₹${interest.round()} ब्याज है — यानी जो रक़म ली उसका लगभग '
                    '${(interest / p * 100).round()}% ब्याज में।'
                : 'Over $n months that is ₹${total.round()} paid in all, of '
                    'which ₹${interest.round()} is interest - about '
                    '${(interest / p * 100).round()}% of what you borrowed.',
            tone: ToolTone.plain,
            icon: Icons.calculate_outlined,
          ),
          const SizedBox(height: 10),
          ToolLine(hi ? 'ऋण' : 'Loan', '₹${p.round()}'),
          ToolLine(hi ? 'ब्याज, कुल' : 'Interest in total',
              '₹${interest.round()}', strong: true),
          ToolLine(hi ? 'कुल चुकाना' : 'Total repaid', '₹${total.round()}'),
          const SizedBox(height: 14),
          ToolAnswer(
            headline: hi
                ? 'अवधि छोटी करने पर क्या बचता है'
                : 'What a shorter term saves',
            detail: hi
                ? 'अवधि आधी करने पर किस्त बढ़ती है लेकिन ब्याज बहुत घट जाता है। '
                    'यही वह जगह है जहाँ सबसे ज़्यादा पैसा बचता है: लंबी अवधि की किस्त '
                    'छोटी दिखती है और कुल ख़र्च कई गुना हो जाता है। अगर महीने की किस्त '
                    'उठा सकते हैं, तो कम महीने चुनिए।'
                : 'Halving the term raises the instalment but cuts the '
                    'interest sharply. That is where the most money is saved: '
                    'a long term makes the instalment look small and the '
                    'total cost several times larger. If the monthly amount '
                    'is bearable, take fewer months.',
            tone: ToolTone.good,
            icon: Icons.trending_down,
          ),
          const SizedBox(height: 10),
          ToolNote(hi
              ? 'दो चीज़ें बैंक से लिखित में पूछें: प्रोसेसिंग शुल्क कितना है, और '
                  'जल्दी चुकाने पर कोई शुल्क है या नहीं। और यह भी कि दर तय है या '
                  'बदलने वाली — बदलने वाली दर पर किस्त बाद में बढ़ सकती है।'
              : 'Two things to ask the bank in writing: what the processing '
                  'fee is, and whether there is a charge for repaying early. '
                  'And whether the rate is fixed or floating - on a floating '
                  'rate the instalment can rise later.'),
        ],
      ],
    );
  }
}

// --- Loan refused -----------------------------------------------------

enum RefusalReason { noReason, cibil, noCollateral, noPapers, newBusiness }

class LoanRefusedPage extends StatefulWidget {
  const LoanRefusedPage({super.key});

  @override
  State<LoanRefusedPage> createState() => _LoanRefusedPageState();
}

class _LoanRefusedPageState extends State<LoanRefusedPage> {
  RefusalReason? _reason;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    Widget pick(RefusalReason r, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _reason == r,
          onTap: () => setState(() => _reason = r),
        );

    return ToolScaffold(
      goal: 9,
      title: hi ? 'बैंक ने ऋण देने से मना किया' : 'The bank refused the loan',
      children: [
        ToolNote(hi
            ? 'बैंक मना कर सकता है, लेकिन चुपचाप नहीं। कारण लिखित में माँगना आपका '
                'हक़ है, और यही वह एक क़दम है जिससे आगे का रास्ता खुलता है — क्योंकि '
                'मना करने के कारण गिने-चुने हैं और उनमें से ज़्यादातर ठीक किए जा सकते '
                'हैं।'
            : 'A bank may refuse, but not silently. Asking for the reason in '
                'writing is your right, and it is the one step that opens the '
                'next one - because the reasons for refusal are few and most '
                'of them are fixable.'),
        ToolQuestion(hi ? 'क्या कारण बताया' : 'What reason was given'),
        pick(RefusalReason.noReason, 'No reason was given',
            'कोई कारण नहीं बताया'),
        pick(RefusalReason.cibil, 'Credit score or an old default',
            'क्रेडिट स्कोर या पुराना बक़ाया'),
        pick(RefusalReason.noCollateral, 'No security to offer',
            'गिरवी रखने के लिए कुछ नहीं'),
        pick(RefusalReason.noPapers, 'Papers or accounts missing',
            'काग़ज़ या हिसाब पूरे नहीं'),
        pick(RefusalReason.newBusiness, 'The business is new',
            'धंधा नया है'),
        if (_reason != null) ...[
          ToolAnswer(
            headline: switch (_reason!) {
              RefusalReason.noReason =>
                hi ? 'लिखित कारण माँगें — यह पहला क़दम है' : 'Ask for it in writing - that is step one',
              RefusalReason.cibil =>
                hi ? 'रिपोर्ट ख़ुद देखें, मुफ़्त' : 'Read the report yourself, free',
              RefusalReason.noCollateral =>
                hi ? 'बिना ज़मानत की योजनाएँ मौजूद हैं' : 'There are collateral-free schemes',
              RefusalReason.noPapers =>
                hi ? 'यह सबसे आसानी से ठीक होने वाला कारण है' : 'The most easily fixed reason of all',
              RefusalReason.newBusiness =>
                hi ? 'नए धंधे के लिए अलग रास्ते हैं' : 'New businesses have their own routes',
            },
            detail: switch (_reason!) {
              RefusalReason.noReason => hi
                  ? 'रिज़र्व बैंक के नियमों में बैंक को ऋण अस्वीकार करने का कारण '
                      'बताना होता है। एक पंक्ति की अर्ज़ी दें: "कृपया मेरे ऋण आवेदन '
                      'संख्या ______ के अस्वीकार होने का कारण लिखित में दीजिए।" '
                      'पावती लें। कारण मिलने पर वह आमतौर पर नीचे के चार में से एक '
                      'होता है, और चारों का रास्ता है।'
                  : 'Under the Reserve Bank\'s rules a bank has to give the '
                      'reason for rejecting a loan. Put in a one-line '
                      'application: "please give me, in writing, the reason '
                      'my loan application number ______ was rejected." Take '
                      'the acknowledgement. The reason, when it comes, is '
                      'usually one of the four below, and all four have a '
                      'route.',
              RefusalReason.cibil => hi
                  ? 'अपनी क्रेडिट रिपोर्ट साल में एक बार मुफ़्त मिलती है, और उसमें हर '
                      'ऋण और भुगतान का रिकॉर्ड होता है। उसमें ग़लती होना आम है — '
                      'चुकाया हुआ ऋण बक़ाया दिखना, या किसी और का ऋण आपके नाम। ग़लती '
                      'सुधारने की प्रक्रिया मुफ़्त है और उसकी समय-सीमा तय है। असली '
                      'बक़ाया हो तो उसे निपटाकर उसका "नो ड्यूज़" प्रमाण पत्र लें — '
                      'उसके बिना रिपोर्ट में वह बना रहता है।'
                  : 'Your credit report is free once a year and carries the '
                      'record of every loan and repayment. Errors in it are '
                      'common - a repaid loan showing as outstanding, or '
                      'somebody else\'s loan against your name. Getting an '
                      'error corrected is free and has a time limit. Where '
                      'the default is real, settle it and take the no-dues '
                      'certificate - without that it stays on the report.',
              RefusalReason.noCollateral => hi
                  ? 'सूक्ष्म और लघु उद्यमों के ऋण के लिए सरकार की गारंटी व्यवस्था '
                      '(CGTMSE) है, जिसमें बैंक को ज़मानत की ज़रूरत नहीं पड़ती — '
                      'गारंटी सरकार देती है। मुद्रा ऋण भी बिना ज़मानत मिलते हैं। '
                      'बैंक से इनका नाम लेकर पूछें: "यह आवेदन सीजीटीएमएसई गारंटी के '
                      'तहत विचार किया गया?" — यह सवाल ही अक्सर जवाब बदल देता है, '
                      'क्योंकि शाखा स्तर पर इसे टाल दिया जाता है।'
                  : 'For micro and small enterprise loans there is a '
                      'government guarantee arrangement (CGTMSE) under which '
                      'the bank needs no collateral - the government '
                      'guarantees it. MUDRA loans are collateral-free too. '
                      'Ask the bank by name: "was this application considered '
                      'under the CGTMSE guarantee?" - that question alone '
                      'often changes the answer, because at branch level it '
                      'gets skipped.',
              RefusalReason.noPapers => hi
                  ? 'यह सबसे अच्छा कारण है, क्योंकि यह पूरी तरह आपके हाथ में है। '
                      'आमतौर पर जो माँगा जाता है: उद्यम पंजीकरण, पैन, आधार, बैंक '
                      'खाते की छह महीने की स्टेटमेंट, धंधे की जगह का सबूत, और '
                      'बिक्री-ख़र्च का कोई हिसाब। आख़िरी चीज़ ही अक्सर नहीं होती — और '
                      'इसी लक्ष्य में "रोज़ का हिसाब" वाली स्क्रीन उसी के लिए है। '
                      'तीन महीने का साफ़ हिसाब ऋण की बात बदल देता है।'
                  : 'This is the best reason to get, because it is entirely '
                      'in your hands. What is usually asked for: Udyam '
                      'registration, PAN, Aadhaar, six months of bank '
                      'statements, proof of the business premises, and some '
                      'account of sales and costs. It is the last that is '
                      'usually missing - and the "daily cash book" screen in '
                      'this goal exists for exactly that. Three months of '
                      'clean accounts changes the conversation.',
              RefusalReason.newBusiness => hi
                  ? 'नए धंधे के लिए मुद्रा की "शिशु" श्रेणी है, जो छोटी रक़म के लिए '
                      'है और जिसमें पुराना हिसाब नहीं माँगा जाता। स्वयं सहायता समूह '
                      'और संयुक्त देयता समूह के ज़रिये भी ऋण मिलता है, और वहाँ शर्तें '
                      'आसान होती हैं। आरसेटी से प्रशिक्षण लेकर बैंक जाने पर बात और '
                      'आसान होती है, क्योंकि आरसेटी ऋण जोड़ने में मदद करता है — '
                      'लक्ष्य 8 में "मुफ़्त कौशल प्रशिक्षण" देखें।'
                  : 'For a new business there is MUDRA\'s Shishu category, '
                      'meant for small amounts and asking for no past '
                      'accounts. Loans also come through self-help groups and '
                      'joint liability groups, where the terms are easier. '
                      'Coming to the bank after RSETI training is easier '
                      'again, because RSETI helps link the loan - see "Free '
                      'skill training" under goal 8.',
            },
            tone: ToolTone.plain,
            icon: Icons.account_balance_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'न सुनने पर आगे' : 'If the branch will not move',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'शाखा प्रबंधक को लिखित शिकायत, पावती के साथ।',
                    'बैंक के क्षेत्रीय या मंडल कार्यालय, और बैंक का शिकायत निवारण '
                        'अधिकारी।',
                    'ज़िले का अग्रणी बैंक प्रबंधक (lead district manager) — यह '
                        'ज़िले के सब बैंकों का समन्वय करता है और इसके पास शिकायत का '
                        'असर होता है।',
                    'रिज़र्व बैंक लोकपाल — शिकायत ऑनलाइन, मुफ़्त, और बैंक को जवाब '
                        'देना पड़ता है। पहले बैंक में शिकायत करना ज़रूरी है, इसलिए '
                        'पावती सँभालकर रखें।',
                    'ज़िला उद्योग केंद्र भी एमएसएमई ऋण के मामलों में मदद करता है।',
                  ]
                : const [
                    'A written complaint to the branch manager, with an '
                        'acknowledgement.',
                    'The bank\'s regional or circle office, and its grievance '
                        'redressal officer.',
                    'The district\'s lead bank manager, who coordinates every '
                        'bank in the district and whose word carries weight.',
                    'The RBI Ombudsman - complaint online, free, and the '
                        'bank has to answer. Complaining to the bank first is '
                        'required, so keep that acknowledgement.',
                    'The District Industries Centre also helps on MSME loan '
                        'matters.',
                  ],
          ),
          const SourceNote(
              text: 'RBI complaint management system', url: _rbiOmbudsmanUrl),
          const SourceNote(text: 'MUDRA', url: _mudraUrl),
        ],
      ],
    );
  }
}

// --- PM Vishwakarma ---------------------------------------------------

/// The eighteen trades the scheme covers.
const vishwakarmaTradesEn = [
  'Carpenter', 'Boat maker', 'Armourer', 'Blacksmith',
  'Hammer and tool kit maker', 'Locksmith', 'Goldsmith', 'Potter',
  'Sculptor or stone breaker', 'Cobbler or footwear artisan',
  'Mason', 'Basket, mat or broom maker', 'Doll and toy maker',
  'Barber', 'Garland maker', 'Washerman', 'Tailor', 'Fishing net maker',
];
const vishwakarmaTradesHi = [
  'बढ़ई', 'नाव बनाने वाला', 'अस्त्र बनाने वाला', 'लोहार',
  'हथौड़ा और औज़ार बनाने वाला', 'ताला बनाने वाला', 'सुनार', 'कुम्हार',
  'मूर्तिकार या पत्थर तोड़ने वाला', 'मोची या जूता बनाने वाला',
  'राजमिस्त्री', 'टोकरी, चटाई या झाड़ू बनाने वाला', 'गुड़िया और खिलौने बनाने वाला',
  'नाई', 'माला बनाने वाला', 'धोबी', 'दर्ज़ी', 'मछली का जाल बनाने वाला',
];

const vishwakarmaToolkit = 15000;
const vishwakarmaFirstLoan = 100000;
const vishwakarmaSecondLoan = 200000;
const vishwakarmaRate = 5;
const vishwakarmaStipend = 500;

class VishwakarmaPage extends StatefulWidget {
  const VishwakarmaPage({super.key});

  @override
  State<VishwakarmaPage> createState() => _VishwakarmaPageState();
}

class _VishwakarmaPageState extends State<VishwakarmaPage> {
  int? _trade;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final trades = hi ? vishwakarmaTradesHi : vishwakarmaTradesEn;

    return ToolScaffold(
      goal: 9,
      title: hi ? 'कारीगर योजना (पीएम विश्वकर्मा)' : 'Artisan scheme (PM Vishwakarma)',
      children: [
        ToolNote(hi
            ? 'पीएम विश्वकर्मा हाथ और औज़ार से काम करने वाले कारीगरों के लिए है, और '
                'इसमें चार चीज़ें मिलती हैं: पहचान पत्र, प्रशिक्षण के दिनों का '
                'वज़ीफ़ा, औज़ार के लिए ₹$vishwakarmaToolkit, और बिना ज़मानत सस्ता ऋण। '
                'अठारह पारंपरिक कामों की सूची तय है — नीचे देखें कि आपका काम उसमें '
                'है या नहीं।'
            : 'PM Vishwakarma is for artisans who work with their hands and '
                'tools, and it gives four things: an identity card, a stipend '
                'for the training days, ₹$vishwakarmaToolkit towards a '
                'toolkit, and a cheap collateral-free loan. Eighteen '
                'traditional trades are listed - check below whether yours is '
                'one.'),
        ToolQuestion(hi ? 'आपका काम' : 'Your trade'),
        for (var i = 0; i < trades.length; i++)
          SelectionTile(
            label: trades[i],
            selected: _trade == i,
            onTap: () => setState(() => _trade = i),
          ),
        if (_trade != null) ...[
          ToolAnswer(
            headline: hi ? 'यह काम सूची में है' : 'That trade is on the list',
            detail: hi
                ? 'पंजीकरण कॉमन सर्विस सेंटर पर होता है और मुफ़्त है। आधार, मोबाइल, '
                    'बैंक खाता और राशन कार्ड साथ ले जाएँ। एक परिवार से एक सदस्य। '
                    'सरकारी कर्मचारी और उनके परिवार इसमें शामिल नहीं होते।'
                : 'Registration is done at a Common Service Centre and is '
                    'free. Take Aadhaar, a mobile number, a bank account and '
                    'the ration card. One member per family. Government '
                    'employees and their families are excluded.',
            tone: ToolTone.good,
            icon: Icons.handyman_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'क्या-क्या मिलता है' : 'What the scheme gives',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ToolLine(
              hi ? 'पहचान पत्र और प्रमाण पत्र' : 'Identity card and certificate',
              hi ? 'मुफ़्त' : 'Free',
              strong: true),
          ToolLine(
              hi ? 'प्रशिक्षण का वज़ीफ़ा' : 'Training stipend',
              hi ? '₹$vishwakarmaStipend प्रति दिन' : '₹$vishwakarmaStipend a day'),
          ToolLine(hi ? 'औज़ार के लिए' : 'Towards a toolkit',
              '₹$vishwakarmaToolkit', strong: true),
          ToolLine(
              hi ? 'पहला ऋण, बिना ज़मानत' : 'First loan, collateral-free',
              hi
                  ? '₹$vishwakarmaFirstLoan तक, $vishwakarmaRate% पर'
                  : 'Up to ₹$vishwakarmaFirstLoan at $vishwakarmaRate%'),
          ToolLine(
              hi ? 'दूसरा ऋण, पहला चुकाने पर' : 'Second loan, after repaying the first',
              hi
                  ? '₹$vishwakarmaSecondLoan तक'
                  : 'Up to ₹$vishwakarmaSecondLoan'),
          const SizedBox(height: 8),
          ToolNote(hi
              ? 'बुनियादी प्रशिक्षण पाँच से सात दिन का होता है और औज़ार की रक़म उसके '
                  'बाद ई-वाउचर के रूप में मिलती है। उन्नत प्रशिक्षण पंद्रह दिन का है '
                  'और वैकल्पिक। ऋण की सीढ़ी का असली फ़ायदा दूसरी किस्त में है — पहली '
                  'किस्त समय पर चुकाना ही उसकी शर्त है। डिजिटल लेन-देन पर अलग से '
                  'प्रोत्साहन भी मिलता है।'
              : 'The basic training runs five to seven days and the toolkit '
                  'amount follows it as an e-voucher. Advanced training is '
                  'fifteen days and optional. The real gain in the loan ladder '
                  'is the second tranche, and repaying the first on time is '
                  'the condition for it. Digital transactions earn a separate '
                  'incentive.'),
          ToolDonts(
            heading: hi ? 'सावधानी' : 'Be careful',
            items: hi
                ? const [
                    'पंजीकरण के पैसे कोई नहीं ले सकता — सीएससी पर यह मुफ़्त है',
                    'औज़ार का ई-वाउचर आपके मोबाइल पर आता है; किसी को ओटीपी न दें',
                    'औज़ार डाक से आते हैं — कोई कहे कि "पैसे दो, औज़ार दिला दूँगा" तो '
                        'वह ठगी है',
                    'ऋण सीधे बैंक से मिलता है; दिलाने के नाम पर कमीशन नहीं',
                  ]
                : const [
                    'Nobody may charge for registering - it is free at a CSC',
                    'The toolkit e-voucher comes to your own mobile; give the '
                        'OTP to nobody',
                    'The toolkit arrives by post - anyone offering to "get '
                        'you the tools for a payment" is a fraud',
                    'The loan comes from the bank directly; no commission for '
                        'arranging it',
                  ],
          ),
          const SourceNote(
              text: 'PM Vishwakarma portal', url: _vishwakarmaUrl),
          const SourceNote(
              text: 'Scheme benefits, SIDBI', url: _vishwakarmaSidbiUrl),
        ],
      ],
    );
  }
}
