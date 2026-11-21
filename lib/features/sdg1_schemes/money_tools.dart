import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// What a moneylender's rate really costs over a year.
///
/// Informal lending is quoted in a way that hides its size: "two rupees"
/// means ₹2 per ₹100 per month, which sounds small and is 24% a year; a
/// daily collection of ₹110 on ₹100 over a month is over 100%. This does
/// the arithmetic, including the part people rarely see - that a loan
/// repaid in instalments is charged on the full amount even though the
/// borrower holds less and less of it, which roughly doubles the true rate.
enum RateBasis { perHundredPerMonth, percentPerMonth, flatOnLoan }

/// Simple yearly rate implied by the quoted figure.
double yearlyRate({
  required RateBasis basis,
  required double quoted,
  required int months,
}) {
  switch (basis) {
    case RateBasis.perHundredPerMonth:
      return quoted * 12; // ₹2 per ₹100 a month = 24% a year
    case RateBasis.percentPerMonth:
      return quoted * 12;
    case RateBasis.flatOnLoan:
      // A flat charge over the whole period, spread back over a year.
      return months <= 0 ? 0 : quoted * 12 / months;
  }
}

/// The rate someone effectively pays when they repay in equal instalments.
///
/// Repaying in instalments means the average amount actually held is about
/// half the loan, so a flat rate costs roughly twice what it looks like.
/// The usual approximation is 2n/(n+1) times the flat rate; this uses it
/// rather than solving for the internal rate, because an approximation that
/// can be explained in one line is better here than a number nobody can
/// check.
double effectiveRateOnInstalments(double flatYearly, int instalments) =>
    instalments <= 1
        ? flatYearly
        : flatYearly * 2 * instalments / (instalments + 1);

class InterestPage extends StatefulWidget {
  const InterestPage({super.key});

  @override
  State<InterestPage> createState() => _InterestPageState();
}

class _InterestPageState extends State<InterestPage> {
  RateBasis _basis = RateBasis.perHundredPerMonth;
  final _amount = TextEditingController();
  final _quoted = TextEditingController();
  final _months = TextEditingController(text: '12');
  bool _instalments = true;

  @override
  void dispose() {
    for (final c in [_amount, _quoted, _months]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    final quoted = double.tryParse(_quoted.text.trim()) ?? 0;
    final months = int.tryParse(_months.text.trim()) ?? 0;

    final yearly = quoted <= 0
        ? 0.0
        : yearlyRate(basis: _basis, quoted: quoted, months: months);
    final effective = _instalments
        ? effectiveRateOnInstalments(yearly, months)
        : yearly;
    final interestPaid = amount <= 0 || months <= 0
        ? 0.0
        : amount * yearly / 100 * months / 12;

    Widget basis(RateBasis b, String en, String h, String subEn, String subHi) =>
        SelectionTile(
          label: hi ? h : en,
          subtitle: hi ? subHi : subEn,
          selected: _basis == b,
          onTap: () => setState(() => _basis = b),
        );

    return ToolScaffold(
      goal: 1,
      title: hi ? 'असली ब्याज' : 'The real interest',
      children: [
        ToolNote(hi
            ? 'साहूकार का रेट ऐसे बताया जाता है कि छोटा लगे। यहाँ वही रेट साल के '
                'हिसाब से दिखता है, ताकि आप उसे बैंक या मुद्रा ऋण से मिला सकें।'
            : 'An informal rate is quoted in a way that makes it look small. '
                'Here it is shown as a yearly rate, so you can hold it up '
                'against a bank or a Mudra loan.'),
        ToolQuestion(hi ? 'रेट कैसे बताया गया है?' : 'How was the rate quoted?'),
        basis(RateBasis.perHundredPerMonth, 'Rupees per 100 per month',
            'सैकड़ा रुपये महीना', 'As in "two rupees" on a hundred',
            'जैसे सौ पर "दो रुपये"'),
        basis(RateBasis.percentPerMonth, 'Per cent per month',
            'प्रतिशत प्रति माह', 'As in "3% a month"', 'जैसे "3% महीना"'),
        basis(RateBasis.flatOnLoan, 'A flat charge for the whole loan',
            'पूरे क़र्ज़ पर एकमुश्त', 'As in "pay 20% extra in all"',
            'जैसे "कुल 20% ऊपर देना"'),
        ToolQuestion(hi ? 'अंक भरें' : 'The numbers'),
        ToolNumber(
          controller: _amount,
          label: hi ? 'क़र्ज़ की रक़म' : 'Amount borrowed',
          suffix: '₹',
          decimal: true,
          onChanged: (_) => setState(() {}),
        ),
        ToolNumber(
          controller: _quoted,
          label: switch (_basis) {
            RateBasis.perHundredPerMonth =>
              hi ? 'सौ रुपये पर कितने रुपये महीना' : 'Rupees per 100 per month',
            RateBasis.percentPerMonth =>
              hi ? 'प्रतिशत प्रति माह' : 'Per cent per month',
            RateBasis.flatOnLoan =>
              hi ? 'कुल कितने प्रतिशत ऊपर' : 'Total per cent extra',
          },
          decimal: true,
          maxDigits: 5,
          onChanged: (_) => setState(() {}),
        ),
        ToolNumber(
          controller: _months,
          label: hi ? 'कितने महीने में चुकाना है' : 'Months to repay',
          maxDigits: 3,
          onChanged: (_) => setState(() {}),
        ),
        SwitchListTile(
          value: _instalments,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'किस्तों में चुका रहे हैं (रोज़ या हफ़्ते या महीने)'
              : 'Repaying in instalments (daily, weekly or monthly)'),
          onChanged: (v) => setState(() => _instalments = v),
        ),
        if (yearly > 0) ...[
          ToolAnswer(
            headline: hi
                ? 'साल का लगभग ${effective.round()}%'
                : 'About ${effective.round()}% a year',
            detail: _instalments
                ? (hi
                    ? 'किस्तों में चुकाने पर असली दर लगभग दोगुनी पड़ती है, क्योंकि आपके '
                        'पास पूरी रक़म पूरे समय नहीं रहती, पर ब्याज पूरी रक़म पर लगता है।'
                    : 'Repaying in instalments roughly doubles the true rate: '
                        'you do not hold the whole amount for the whole time, '
                        'but the charge is on the whole amount.')
                : (hi
                    ? 'यही रक़म पूरे समय आपके पास रहने पर की दर।'
                    : 'The rate if you hold the whole amount throughout.'),
            tone: effective >= 36
                ? ToolTone.bad
                : effective >= 20
                    ? ToolTone.warn
                    : ToolTone.plain,
            icon: Icons.percent,
          ),
          const SizedBox(height: 10),
          ToolLine(hi ? 'बताया गया रेट, साल में' : 'Quoted rate, per year',
              '${yearly.round()}%'),
          if (interestPaid > 0)
            ToolLine(
                hi ? '$months महीने में कुल ब्याज' : 'Interest over $months months',
                '₹${interestPaid.round()}'),
          if (amount > 0 && interestPaid > 0)
            ToolLine(hi ? 'कुल चुकाना' : 'Total to repay',
                '₹${(amount + interestPaid).round()}',
                strong: true),
          const SizedBox(height: 14),
          Text(hi ? 'तुलना के लिए' : 'For comparison',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          ToolNote(hi
              ? 'बैंक के छोटे कारोबारी और कृषि ऋण आमतौर पर साल के 9% से 14% के बीच '
                  'होते हैं, और स्वयं सहायता समूह के ऋण भी उसी के आसपास। अगर ऊपर का '
                  'आँकड़ा उससे कई गुना है, तो क़र्ज़ लेने से पहले इस ऐप के "व्यवसाय के '
                  'लिए पैसा" टूल में सरकारी योजनाएँ देख लें।'
              : 'Bank loans for small business and farming usually run '
                  'between about 9% and 14% a year, and self-help group '
                  'loans are in the same range. If the figure above is a '
                  'multiple of that, look at the government schemes in this '
                  "app's \"Money to start a business\" tool first."),
        ],
        const SizedBox(height: 10),
        ToolNote(hi
            ? 'यह हिसाब आपके बताए आँकड़ों पर है। क़ानूनी सलाह नहीं — बहुत ऊँचे ब्याज और '
                'धमकी भरी वसूली के ख़िलाफ़ राज्य के साहूकार क़ानून हैं, और इस ऐप के शांति '
                'और न्याय हिस्से में मुफ़्त क़ानूनी सहायता का रास्ता है।'
            : 'This is arithmetic on what you entered, not legal advice. '
                'States have moneylending laws against very high interest '
                'and threatening recovery, and the Peace and Justice part of '
                'this app has the route to free legal help.'),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

/// A month's money, laid out so the gap is visible.
///
/// Deliberately plain: income, the costs that cannot be moved, the ones
/// that can, and what is left. No advice about what to cut - that belongs
/// to the person who lives there, not to an app.
class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final _rows = <String, TextEditingController>{};

  static const _income = [
    ('wages', 'Wages and daily work', 'मज़दूरी और दिहाड़ी'),
    ('farm', 'Farming or animals', 'खेती या पशु'),
    ('business', 'Shop or business', 'दुकान या कारोबार'),
    ('other_in', 'Pension, rent, help from family',
        'पेंशन, किराया, परिवार से मदद'),
  ];
  static const _fixed = [
    ('rent', 'Rent or loan instalment', 'किराया या क़िस्त'),
    ('power', 'Electricity, gas, water', 'बिजली, गैस, पानी'),
    ('school', 'School fees and books', 'स्कूल फ़ीस और किताबें'),
    ('phone', 'Phone and recharge', 'फ़ोन और रिचार्ज'),
  ];
  static const _varying = [
    ('food', 'Food and groceries', 'खाना और सामान'),
    ('health', 'Medicines and treatment', 'दवा और इलाज'),
    ('travel', 'Travel and fuel', 'आना-जाना और ईंधन'),
    ('other_out', 'Everything else', 'बाक़ी सब'),
  ];

  TextEditingController _c(String key) =>
      _rows.putIfAbsent(key, () => TextEditingController());

  double _sum(List<(String, String, String)> rows) {
    var total = 0.0;
    for (final r in rows) {
      total += double.tryParse(_c(r.$1).text.trim()) ?? 0;
    }
    return total;
  }

  @override
  void dispose() {
    for (final c in _rows.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final income = _sum(_income);
    final fixed = _sum(_fixed);
    final varying = _sum(_varying);
    final left = income - fixed - varying;
    final anything = income > 0 || fixed > 0 || varying > 0;

    Widget group(String titleEn, String titleHi,
            List<(String, String, String)> rows) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ToolQuestion(hi ? titleHi : titleEn),
            for (final r in rows)
              ToolNumber(
                controller: _c(r.$1),
                label: hi ? r.$3 : r.$2,
                suffix: '₹',
                decimal: true,
                onChanged: (_) => setState(() {}),
              ),
          ],
        );

    return ToolScaffold(
      goal: 1,
      title: hi ? 'घर का बजट' : 'Household budget',
      children: [
        ToolNote(hi
            ? 'एक महीने के हिसाब से भरें। जो याद न हो, अंदाज़ा लगा लें — अंदाज़ा भी कुछ '
                'न होने से बेहतर है। यह हिसाब कहीं नहीं भेजा जाता।'
            : 'Fill it in for one month. Guess what you cannot remember — a '
                'guess beats nothing. None of this is sent anywhere.'),
        group('Money coming in', 'आमदनी', _income),
        group('Costs you cannot move', 'जो ख़र्च टल नहीं सकते', _fixed),
        group('Costs that change', 'जो ख़र्च बदलते रहते हैं', _varying),
        if (anything) ...[
          ToolAnswer(
            headline: left >= 0
                ? (hi
                    ? 'महीने के अंत में ₹${left.round()} बचता है'
                    : '₹${left.round()} left at the end of the month')
                : (hi
                    ? 'महीने में ₹${left.abs().round()} कम पड़ता है'
                    : '₹${left.abs().round()} short each month'),
            detail: left >= 0
                ? (hi
                    ? 'अगर इसका कुछ हिस्सा हर महीने अलग रख सकें, तो अगली बार बीमारी '
                        'या फ़सल ख़राब होने पर क़र्ज़ लेने की नौबत कम आएगी।'
                    : 'Putting even part of this aside each month is what '
                        'makes the next illness or bad harvest something '
                        'other than a loan.')
                : (hi
                    ? 'यह अंतर ही हर महीने क़र्ज़ बनता है। ऊपर "असली ब्याज" टूल में देखें '
                        'कि वह क़र्ज़ असल में कितना महँगा है।'
                    : 'This gap is what turns into a loan each month. The '
                        '"real interest" tool shows what that loan actually '
                        'costs.'),
            tone: left >= 0 ? ToolTone.good : ToolTone.warn,
            icon: left >= 0 ? Icons.savings_outlined : Icons.trending_down,
          ),
          const SizedBox(height: 10),
          ToolLine(hi ? 'आमदनी' : 'Money in', '₹${income.round()}'),
          ToolLine(hi ? 'टल न सकने वाले ख़र्च' : 'Fixed costs',
              '₹${fixed.round()}'),
          ToolLine(hi ? 'बदलने वाले ख़र्च' : 'Changing costs',
              '₹${varying.round()}'),
          ToolLine(hi ? 'बचत' : 'Left over', '₹${left.round()}', strong: true),
          if (income > 0)
            ToolNote(hi
                ? 'आपकी आमदनी का ${(100 * fixed / math.max(income, 1)).round()}% '
                    'उन ख़र्चों में जाता है जो टल नहीं सकते।'
                : '${(100 * fixed / math.max(income, 1)).round()}% of what '
                    'comes in goes on costs that cannot be moved.'),
        ],
      ],
    );
  }
}
