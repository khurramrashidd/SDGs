import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/tool_kit.dart';

/// Four screens for running the business day to day: pricing,
/// break-even, a cash book and a bill.
///
/// The cash book keeps its entries on this phone and nowhere else. That is
/// a deliberate limit rather than a missing feature: a small trader's
/// takings are nobody's business, the app has no account to tie them to,
/// and a book that syncs somewhere is a book people stop writing in.
/// Three months of honest entries is also the single thing most likely to
/// turn a refused loan into a sanctioned one.

const _gemUrl = 'https://gem.gov.in/';
const _npciUrl = 'https://www.npci.org.in/';
const _cyberUrl = 'https://cybercrime.gov.in/';

// --- Pricing ----------------------------------------------------------

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  final _material = TextEditingController();
  final _labourHours = TextEditingController();
  final _labourRate = TextEditingController();
  final _otherCost = TextEditingController(text: '0');
  final _margin = TextEditingController(text: '25');
  final _unitsAMonth = TextEditingController();
  final _fixedCosts = TextEditingController(text: '0');

  @override
  void dispose() {
    for (final c in [
      _material,
      _labourHours,
      _labourRate,
      _otherCost,
      _margin,
      _unitsAMonth,
      _fixedCosts
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double _v(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final material = _v(_material);
    final labour = _v(_labourHours) * _v(_labourRate);
    final other = _v(_otherCost);
    final units = _v(_unitsAMonth);
    final fixed = _v(_fixedCosts);
    final fixedPerUnit = units > 0 ? fixed / units : 0.0;

    final directCost = material + labour + other;
    final fullCost = directCost + fixedPerUnit;
    final margin = _v(_margin);
    final price = fullCost > 0 && margin < 100
        ? fullCost / (1 - margin / 100)
        : null;

    return ToolScaffold(
      goal: 9,
      title: hi ? 'दाम कैसे तय करें' : 'Price my product',
      children: [
        ToolNote(hi
            ? 'छोटे धंधे में दाम लगाने की सबसे आम ग़लती यह है कि अपनी मेहनत का पैसा '
                'गिना ही नहीं जाता, और किराया-बिजली जैसे ख़र्च भी नहीं जुड़ते। तब '
                'हिसाब में मुनाफ़ा दिखता है और जेब में कुछ नहीं आता। यह स्क्रीन दोनों '
                'जोड़ती है।'
            : 'The commonest mistake in pricing a small product is not '
                'counting your own labour, and not adding the rent and '
                'electricity. Then the arithmetic shows a profit and nothing '
                'reaches the pocket. This screen adds both in.'),
        ToolQuestion(hi ? 'एक चीज़ बनाने का सीधा ख़र्च' : 'Direct cost of making one'),
        ToolNumber(
          controller: _material,
          label: hi ? 'कच्चा माल (₹)' : 'Materials (₹)',
          decimal: true,
          maxDigits: 8,
          icon: Icons.inventory_2_outlined,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _labourHours,
                label: hi ? 'कितने घंटे लगते हैं' : 'Hours it takes',
                decimal: true,
                maxDigits: 5,
                icon: Icons.schedule,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _labourRate,
                label: hi ? 'अपनी मज़दूरी प्रति घंटा (₹)' : 'Your own rate an hour (₹)',
                decimal: true,
                maxDigits: 6,
                icon: Icons.person_outline,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        ToolNote(hi
            ? 'अपनी मज़दूरी ज़रूर जोड़ें, चाहे आप ख़ुद ही बनाते हों। अगर इसे शून्य '
                'रखा तो दाम कम निकलेगा और आप मुफ़्त काम कर रहे होंगे — यह सबसे आम '
                'वजह है जिससे छोटे धंधे चलते हुए भी कुछ नहीं बचा पाते। जो मज़दूरी आप '
                'किसी और को देते, उतनी अपनी भी गिनिए।'
            : 'Put your own labour in even if you make it yourself. Left at '
                'zero, the price comes out low and you are working for '
                'nothing - the commonest reason a small business runs for '
                'years and saves nothing. Count your own time at what you '
                'would pay somebody else.'),
        const SizedBox(height: 10),
        ToolNumber(
          controller: _otherCost,
          label: hi ? 'पैकिंग, ढुलाई, अन्य (₹)' : 'Packing, transport, other (₹)',
          decimal: true,
          maxDigits: 8,
          icon: Icons.local_shipping_outlined,
          onChanged: (_) => setState(() {}),
        ),
        ToolQuestion(hi ? 'महीने के तय ख़र्च' : 'Monthly fixed costs'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _fixedCosts,
                label: hi ? 'किराया, बिजली, आदि (₹)' : 'Rent, power, etc (₹)',
                decimal: true,
                maxDigits: 9,
                icon: Icons.store_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _unitsAMonth,
                label: hi ? 'महीने में कितने बिकते हैं' : 'Units sold a month',
                decimal: true,
                maxDigits: 7,
                icon: Icons.sell_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        ToolQuestion(hi ? 'कितना मुनाफ़ा चाहिए' : 'What margin do you want'),
        ToolNumber(
          controller: _margin,
          label: hi ? 'दाम का प्रतिशत (%)' : 'Per cent of the price (%)',
          decimal: true,
          maxDigits: 4,
          icon: Icons.percent,
          onChanged: (_) => setState(() {}),
        ),
        if (directCost > 0) ...[
          ToolAnswer(
            headline: price != null
                ? (hi
                    ? 'दाम रखें ₹${price.ceil()}'
                    : 'Price it at ₹${price.ceil()}')
                : (hi
                    ? 'मुनाफ़ा 100% से कम रखें'
                    : 'Keep the margin under 100%'),
            detail: price != null
                ? (hi
                    ? 'एक चीज़ पर पूरा ख़र्च ₹${fullCost.toStringAsFixed(1)} पड़ता है '
                        '(सीधा ख़र्च ₹${directCost.toStringAsFixed(1)}'
                        '${fixedPerUnit > 0 ? ' और तय ख़र्च का हिस्सा ₹${fixedPerUnit.toStringAsFixed(1)}' : ''}'
                        '), और इस दाम पर एक चीज़ से '
                        '₹${(price - fullCost).toStringAsFixed(1)} बचता है।'
                    : 'Each one costs ₹${fullCost.toStringAsFixed(1)} in all '
                        '(direct ₹${directCost.toStringAsFixed(1)}'
                        '${fixedPerUnit > 0 ? ' plus ₹${fixedPerUnit.toStringAsFixed(1)} of fixed costs' : ''}'
                        '), and at this price each one leaves '
                        '₹${(price - fullCost).toStringAsFixed(1)}.')
                : (hi
                    ? 'मुनाफ़े का प्रतिशत दाम का हिस्सा होता है, इसलिए वह 100 से कम '
                        'होना चाहिए।'
                    : 'The margin is a share of the price, so it has to be '
                        'under 100.'),
            tone: price != null ? ToolTone.good : ToolTone.warn,
            icon: Icons.price_change_outlined,
          ),
          if (price != null) ...[
            const SizedBox(height: 10),
            ToolLine(hi ? 'कच्चा माल' : 'Materials',
                '₹${material.toStringAsFixed(1)}'),
            ToolLine(hi ? 'अपनी मेहनत' : 'Your labour',
                '₹${labour.toStringAsFixed(1)}'),
            if (other > 0)
              ToolLine(hi ? 'अन्य' : 'Other', '₹${other.toStringAsFixed(1)}'),
            if (fixedPerUnit > 0)
              ToolLine(hi ? 'तय ख़र्च का हिस्सा' : 'Share of fixed costs',
                  '₹${fixedPerUnit.toStringAsFixed(1)}'),
            ToolLine(hi ? 'कुल ख़र्च' : 'Total cost',
                '₹${fullCost.toStringAsFixed(1)}', strong: true),
            ToolLine(hi ? 'दाम' : 'Price', '₹${price.ceil()}', strong: true),
            if (units > 0)
              ToolLine(
                  hi ? 'महीने का मुनाफ़ा' : 'Profit a month',
                  '₹${((price - fullCost) * units).round()}',
                  strong: true),
            const SizedBox(height: 10),
            ToolNote(hi
                ? 'एक बात देख लें: यह दाम बाज़ार के दाम से कितना अलग है? ज़्यादा हो '
                    'तो दो ही रास्ते हैं — ख़र्च घटाना, या यह बताना कि आपकी चीज़ में '
                    'क्या अलग है। दाम घटाकर अपनी मज़दूरी काटना तीसरा रास्ता लगता है, '
                    'लेकिन वह रास्ता नहीं है।'
                : 'One thing to check: how far is this from the market '
                    'price? If it is higher there are two routes - cut the '
                    'cost, or be able to say what is different about yours. '
                    'Cutting the price by cutting your own wage looks like a '
                    'third route, and it is not one.'),
          ],
        ],
      ],
    );
  }
}

// --- Break-even -------------------------------------------------------

class BreakEvenPage extends StatefulWidget {
  const BreakEvenPage({super.key});

  @override
  State<BreakEvenPage> createState() => _BreakEvenPageState();
}

class _BreakEvenPageState extends State<BreakEvenPage> {
  final _fixed = TextEditingController();
  final _price = TextEditingController();
  final _variable = TextEditingController();

  @override
  void dispose() {
    for (final c in [_fixed, _price, _variable]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final fixed = double.tryParse(_fixed.text.trim()) ?? 0;
    final price = double.tryParse(_price.text.trim()) ?? 0;
    final variable = double.tryParse(_variable.text.trim()) ?? 0;
    final contribution = price - variable;
    final units = (fixed > 0 && contribution > 0) ? fixed / contribution : null;

    return ToolScaffold(
      goal: 9,
      title: hi ? 'कितना बेचने पर ख़र्च निकलेगा' : 'Break-even: how many to sell',
      children: [
        ToolNote(hi
            ? 'हर धंधे में एक संख्या होती है जिस पर पहुँचकर घाटा ख़त्म होता है और '
                'उसके बाद का सब मुनाफ़ा। वह संख्या जानने वाला दुकानदार महीने के बीच '
                'में जान जाता है कि कहाँ खड़ा है; न जानने वाला महीने के अंत में पता '
                'करता है।'
            : 'Every business has a number at which the loss ends and '
                'everything after it is profit. A trader who knows that '
                'number knows by mid-month where they stand; one who does not '
                'finds out at the end of it.'),
        ToolQuestion(hi ? 'तीन संख्याएँ' : 'Three numbers'),
        ToolNumber(
          controller: _fixed,
          label: hi
              ? 'महीने के तय ख़र्च — किराया, बिजली, वेतन (₹)'
              : 'Monthly fixed costs - rent, power, wages (₹)',
          decimal: true,
          maxDigits: 9,
          icon: Icons.store_outlined,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _price,
                label: hi ? 'एक का दाम (₹)' : 'Price of one (₹)',
                decimal: true,
                maxDigits: 8,
                icon: Icons.sell_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _variable,
                label: hi ? 'एक पर सीधा ख़र्च (₹)' : 'Direct cost of one (₹)',
                decimal: true,
                maxDigits: 8,
                icon: Icons.inventory_2_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        if (price > 0 && variable > 0) ...[
          if (contribution <= 0)
            ToolAnswer(
              headline: hi
                  ? 'हर बिक्री पर घाटा हो रहा है'
                  : 'Every sale is losing money',
              detail: hi
                  ? 'एक चीज़ का दाम उसके सीधे ख़र्च से कम या बराबर है, इसलिए कितना भी '
                      'बेचें, तय ख़र्च कभी नहीं निकलेगा — बेचने से घाटा बढ़ेगा। पहले '
                      'दाम या ख़र्च ठीक करना होगा; इसी लक्ष्य में "दाम कैसे तय करें" '
                      'देखें।'
                  : 'The price of one is at or below its direct cost, so no '
                      'volume will ever cover the fixed costs - selling more '
                      'deepens the loss. The price or the cost has to change '
                      'first; see "Price my product" in this goal.',
              tone: ToolTone.bad,
              icon: Icons.warning_amber_outlined,
            )
          else if (units != null) ...[
            ToolAnswer(
              headline: hi
                  ? 'महीने में ${units.ceil()} बेचने पर ख़र्च निकलता है'
                  : '${units.ceil()} a month covers the costs',
              detail: hi
                  ? 'हर बिक्री पर ₹${contribution.toStringAsFixed(1)} बचता है, और '
                      'महीने के तय ख़र्च ₹${fixed.round()} हैं। '
                      '${units.ceil()} के बाद हर बिक्री पर '
                      '₹${contribution.toStringAsFixed(1)} सीधा मुनाफ़ा है। दिन के '
                      'हिसाब से यह लगभग ${(units / 26).ceil()} रोज़ बनता है।'
                  : 'Each sale leaves ₹${contribution.toStringAsFixed(1)}, '
                      'and the fixed costs are ₹${fixed.round()} a month. '
                      'Past ${units.ceil()}, every sale is '
                      '₹${contribution.toStringAsFixed(1)} of straight '
                      'profit. Spread over a month that is about '
                      '${(units / 26).ceil()} a day.',
              tone: ToolTone.good,
              icon: Icons.flag_outlined,
            ),
            const SizedBox(height: 10),
            ToolLine(hi ? 'एक पर बचत' : 'Left on each one',
                '₹${contribution.toStringAsFixed(1)}', strong: true),
            ToolLine(hi ? 'महीने के तय ख़र्च' : 'Fixed costs a month',
                '₹${fixed.round()}'),
            ToolLine(hi ? 'महीने में बेचने हैं' : 'To sell a month',
                '${units.ceil()}', strong: true),
            ToolLine(hi ? 'रोज़ के हिसाब से' : 'Per day, over 26 days',
                '${(units / 26).ceil()}'),
            const SizedBox(height: 14),
            ToolNote(hi
                ? 'इस संख्या को दुकान में कहीं लिख कर रखिए और रोज़ की बिक्री उससे '
                    'मिलाइए। महीने के बीच में यह दिख जाना कि आधा रास्ता पार हुआ या '
                    'नहीं — यही छोटे धंधे का सबसे काम का औज़ार है। बिक्री का हिसाब '
                    'रखने के लिए इसी लक्ष्य में "रोज़ का हिसाब" वाली स्क्रीन है।'
                : 'Write this number somewhere in the shop and check the '
                    'day\'s sales against it. Seeing by mid-month whether you '
                    'are half way is the most useful instrument a small '
                    'business has. The "daily cash book" screen in this goal '
                    'is for keeping that count.'),
          ],
        ],
      ],
    );
  }
}

// --- Daily cash book --------------------------------------------------

/// One day's line in the book.
class CashEntry {
  final String date;
  final double sales;
  final double costs;
  final String note;
  const CashEntry(this.date, this.sales, this.costs, this.note);

  double get profit => sales - costs;

  Map<String, dynamic> toJson() =>
      {'d': date, 's': sales, 'c': costs, 'n': note};

  static CashEntry? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final d = raw['d'];
    if (d is! String) return null;
    return CashEntry(
      d,
      (raw['s'] as num?)?.toDouble() ?? 0,
      (raw['c'] as num?)?.toDouble() ?? 0,
      raw['n'] as String? ?? '',
    );
  }
}

class CashBookPage extends StatefulWidget {
  const CashBookPage({super.key});

  @override
  State<CashBookPage> createState() => _CashBookPageState();
}

class _CashBookPageState extends State<CashBookPage> {
  static const _key = 'cash_book_v1';
  static const _maxEntries = 120;

  List<CashEntry> _entries = const [];
  final _sales = TextEditingController();
  final _costs = TextEditingController();
  final _note = TextEditingController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_sales, _costs, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final list = jsonDecode(raw);
        if (list is List) {
          _entries = list
              .map(CashEntry.fromJson)
              .whereType<CashEntry>()
              .toList(growable: false);
        }
      }
    } catch (_) {
      // A corrupt or unreadable store is treated as an empty book rather
      // than breaking the screen.
      _entries = const [];
    }
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _save(List<CashEntry> next) async {
    setState(() => _entries = next);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode(next.map((e) => e.toJson()).toList()));
    } catch (_) {
      // Nothing to do: the entry stays in memory for this session.
    }
  }

  String _today() {
    final n = DateTime.now();
    return '${n.day}/${n.month}/${n.year}';
  }

  void _add() {
    final s = double.tryParse(_sales.text.trim()) ?? 0;
    final c = double.tryParse(_costs.text.trim()) ?? 0;
    if (s <= 0 && c <= 0) return;
    final next = [
      CashEntry(_today(), s, c, _note.text.trim()),
      ..._entries,
    ].take(_maxEntries).toList(growable: false);
    _sales.clear();
    _costs.clear();
    _note.clear();
    _save(next);
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final totalSales = _entries.fold<double>(0, (a, e) => a + e.sales);
    final totalCosts = _entries.fold<double>(0, (a, e) => a + e.costs);
    final profit = totalSales - totalCosts;

    return ToolScaffold(
      goal: 9,
      title: hi ? 'रोज़ का हिसाब' : 'Daily cash book',
      children: [
        ToolNote(hi
            ? 'यह हिसाब सिर्फ़ इस फ़ोन में रहता है — कहीं नहीं भेजा जाता, किसी खाते '
                'से नहीं जुड़ा। और यह काम बैंक के सामने सबसे ज़्यादा काम आता है: तीन '
                'महीने का साफ़ हिसाब ऋण की बात बदल देता है, क्योंकि "काग़ज़ नहीं हैं" '
                'ही मना करने का सबसे आम कारण है।'
            : 'This book stays on this phone only - nothing is sent anywhere '
                'and it is tied to no account. And it is what counts most in '
                'front of a bank: three months of clean accounts changes the '
                'loan conversation, because "no papers" is the commonest '
                'reason for a refusal.'),
        ToolQuestion(hi ? 'आज का हिसाब लिखें' : 'Add today'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _sales,
                label: hi ? 'आज की बिक्री (₹)' : 'Sales today (₹)',
                decimal: true,
                maxDigits: 9,
                icon: Icons.trending_up,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _costs,
                label: hi ? 'आज का ख़र्च (₹)' : 'Costs today (₹)',
                decimal: true,
                maxDigits: 9,
                icon: Icons.trending_down,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ToolText(
          controller: _note,
          label: hi ? 'टिप्पणी (वैकल्पिक)' : 'A note (optional)',
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: _add,
          icon: const Icon(Icons.add),
          label: Text(hi ? 'जोड़ें' : 'Add entry'),
        ),
        if (!_loaded)
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_entries.isEmpty)
          ToolNote(hi
              ? 'अभी कोई हिसाब दर्ज नहीं है। रोज़ शाम को दो संख्याएँ डालना काफ़ी है — '
                  'बिक्री और ख़र्च। एक महीने बाद यह अपने आप एक रिकॉर्ड बन जाता है।'
              : 'Nothing entered yet. Two numbers each evening is enough - '
                  'sales and costs. After a month it has become a record on '
                  'its own.')
        else ...[
          ToolAnswer(
            headline: profit >= 0
                ? (hi
                    ? 'अब तक मुनाफ़ा ₹${profit.round()}'
                    : '₹${profit.round()} profit so far')
                : (hi
                    ? 'अब तक घाटा ₹${(-profit).round()}'
                    : '₹${(-profit).round()} loss so far'),
            detail: hi
                ? '${_entries.length} दिन का हिसाब: बिक्री ₹${totalSales.round()}, '
                    'ख़र्च ₹${totalCosts.round()}। औसतन रोज़ '
                    '₹${(profit / _entries.length).round()}।'
                : 'Over ${_entries.length} days: sales ₹${totalSales.round()}, '
                    'costs ₹${totalCosts.round()}. That averages '
                    '₹${(profit / _entries.length).round()} a day.',
            tone: profit >= 0 ? ToolTone.good : ToolTone.warn,
            icon: Icons.book_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'दर्ज दिन' : 'Entries',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          for (final e in _entries.take(30))
            ToolLine(
                e.note.isEmpty ? e.date : '${e.date} · ${e.note}',
                e.profit >= 0
                    ? '+₹${e.profit.round()}'
                    : '-₹${(-e.profit).round()}'),
          if (_entries.length > 30)
            ToolNote(hi
                ? 'ऊपर के 30 दिन दिख रहे हैं। कुल हिसाब में सब दिन जुड़े हैं।'
                : 'The last 30 days are shown. The totals above include all '
                    'of them.'),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              final yes = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(hi ? 'पूरा हिसाब मिटाएँ?' : 'Clear the whole book?'),
                  content: Text(hi
                      ? 'यह फ़ोन से हट जाएगा और वापस नहीं आएगा।'
                      : 'It will be removed from this phone and cannot be '
                          'brought back.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(hi ? 'नहीं' : 'No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(hi ? 'मिटाएँ' : 'Clear'),
                    ),
                  ],
                ),
              );
              if (yes == true) await _save(const []);
            },
            icon: const Icon(Icons.delete_outline),
            label: Text(hi ? 'हिसाब मिटाएँ' : 'Clear the book'),
          ),
        ],
      ],
    );
  }
}

// --- Bill maker -------------------------------------------------------

class BillMakerPage extends StatefulWidget {
  const BillMakerPage({super.key});

  @override
  State<BillMakerPage> createState() => _BillMakerPageState();
}

class _BillMakerPageState extends State<BillMakerPage> {
  final _shop = TextEditingController();
  final _phone = TextEditingController();
  final _customer = TextEditingController();
  final _item = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _rate = TextEditingController();
  final _gstin = TextEditingController();

  @override
  void dispose() {
    for (final c in [_shop, _phone, _customer, _item, _qty, _rate, _gstin]) {
      c.dispose();
    }
    super.dispose();
  }

  String _bill(bool hi) {
    final q = double.tryParse(_qty.text.trim()) ?? 0;
    final r = double.tryParse(_rate.text.trim()) ?? 0;
    final total = q * r;
    final n = DateTime.now();
    final date = '${n.day}/${n.month}/${n.year}';
    final shop = _shop.text.trim().isEmpty ? '______' : _shop.text.trim();
    final phone = _phone.text.trim();
    final customer = _customer.text.trim();
    final item = _item.text.trim().isEmpty ? '______' : _item.text.trim();
    final gstin = _gstin.text.trim();

    final lines = <String>[
      shop,
      if (phone.isNotEmpty) (hi ? 'फ़ोन: $phone' : 'Phone: $phone'),
      if (gstin.isNotEmpty) 'GSTIN: $gstin',
      '',
      hi ? 'दिनांक: $date' : 'Date: $date',
      if (customer.isNotEmpty) (hi ? 'ग्राहक: $customer' : 'Customer: $customer'),
      '',
      hi ? 'विवरण: $item' : 'Item: $item',
      hi ? 'मात्रा: ${_fmt(q)}' : 'Quantity: ${_fmt(q)}',
      hi ? 'दर: ₹${_fmt(r)}' : 'Rate: ₹${_fmt(r)}',
      '',
      hi ? 'कुल: ₹${_fmt(total)}' : 'Total: ₹${_fmt(total)}',
      '',
      hi ? 'धन्यवाद।' : 'Thank you.',
    ];
    return lines.join('\n');
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final q = double.tryParse(_qty.text.trim()) ?? 0;
    final r = double.tryParse(_rate.text.trim()) ?? 0;

    return ToolScaffold(
      goal: 9,
      title: hi ? 'बिल बनाएँ' : 'Simple bill maker',
      children: [
        ToolNote(hi
            ? 'साफ़ बिल देने से दो फ़ायदे होते हैं: ग्राहक का भरोसा, और आपका अपना '
                'रिकॉर्ड। बिल भेजने के लिए नीचे का पाठ कॉपी करके संदेश में भेज दें।'
            : 'A clean bill does two things: it earns the customer\'s trust '
                'and it is your own record. Copy the text below and send it '
                'as a message.'),
        ToolQuestion(hi ? 'आपकी दुकान' : 'Your shop'),
        ToolText(
          controller: _shop,
          label: hi ? 'दुकान या धंधे का नाम' : 'Shop or business name',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolText(
          controller: _phone,
          label: hi ? 'फ़ोन नंबर' : 'Phone number',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolText(
          controller: _gstin,
          label: hi ? 'जीएसटीआईएन (हो तो)' : 'GSTIN (if you have one)',
          onChanged: (_) => setState(() {}),
        ),
        ToolQuestion(hi ? 'यह बिल' : 'This bill'),
        ToolText(
          controller: _customer,
          label: hi ? 'ग्राहक का नाम' : 'Customer name',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolText(
          controller: _item,
          label: hi ? 'क्या बेचा' : 'What was sold',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _qty,
                label: hi ? 'मात्रा' : 'Quantity',
                decimal: true,
                maxDigits: 7,
                icon: Icons.tag,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _rate,
                label: hi ? 'दर (₹)' : 'Rate (₹)',
                decimal: true,
                maxDigits: 8,
                icon: Icons.currency_rupee,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        if (q > 0 && r > 0) ...[
          ToolAnswer(
            headline: hi ? 'कुल ₹${_fmt(q * r)}' : 'Total ₹${_fmt(q * r)}',
            detail: hi
                ? 'नीचे का बिल कॉपी करके ग्राहक को भेज दें।'
                : 'Copy the bill below and send it to the customer.',
            tone: ToolTone.plain,
            icon: Icons.receipt_outlined,
          ),
          const SizedBox(height: 10),
          CopyBlock(
            text: _bill(hi),
            note: hi
                ? 'खाने का धंधा हो तो बिल पर एफ़एसएसएआई नंबर भी छापें — यह ज़रूरी भी '
                    'है और भरोसे का काम भी करता है।'
                : 'For a food business, print the FSSAI number on the bill '
                    'too - it is required, and it works as a mark of trust.',
          ),
        ],
      ],
    );
  }
}

// --- Selling to the government ----------------------------------------

class GemPage extends StatelessWidget {
  const GemPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 9,
      title: hi ? 'सरकार को बेचना (GeM)' : 'Selling to the government (GeM)',
      children: [
        ToolNote(hi
            ? 'सरकारी ई-मार्केटप्लेस (GeM) वह जगह है जहाँ से सरकारी दफ़्तर, स्कूल, '
                'अस्पताल और पंचायतें ख़रीदारी करती हैं। छोटे उद्यमों के लिए इसमें '
                'सबसे बड़ी बात यह है: सरकारी ख़रीद नीति में सूक्ष्म और लघु उद्यमों के '
                'लिए हिस्सा आरक्षित है, और उसमें महिला तथा अनुसूचित जाति/जनजाति के '
                'उद्यमों के लिए अलग हिस्सा भी है।'
            : 'The Government e Marketplace is where government offices, '
                'schools, hospitals and panchayats buy. The biggest thing in '
                'it for a small enterprise is this: the public procurement '
                'policy reserves a share for micro and small enterprises, '
                'with a further share inside it for women-owned and SC/ST '
                'enterprises.'),
        const SizedBox(height: 10),
        Text(hi ? 'विक्रेता बनने के क़दम' : 'Becoming a seller',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'gem.gov.in पर विक्रेता के रूप में पंजीकरण करें। पंजीकरण मुफ़्त '
                      'है।',
                  'चाहिए: पैन, आधार से जुड़ा मोबाइल, बैंक खाता, और उद्यम पंजीकरण '
                      '(जिससे एमएसएमई का लाभ मिलता है)। जीएसटी ज़रूरी हो सकता है, यह '
                      'इस पर निर्भर है कि क्या बेच रहे हैं।',
                  'अपनी चीज़ या सेवा को सूची में डालें — ठीक उसी श्रेणी में, और दाम '
                      'के साथ।',
                  'ख़रीद की सूचनाएँ (बिड) देखते रहें और अपनी श्रेणी में भाग लें।',
                  'पहला ऑर्डर छोटा लें और समय पर पूरा करें — रेटिंग यहीं से बनती है, '
                      'और आगे का सब उसी पर टिकता है।',
                ]
              : const [
                  'Register as a seller on gem.gov.in. Registration is free.',
                  'You need PAN, a mobile linked to Aadhaar, a bank account, '
                      'and Udyam registration, which is what brings the MSME '
                      'benefit. GST may be required depending on what you '
                      'sell.',
                  'List your product or service - in exactly the right '
                      'category, with the price.',
                  'Watch the bids and take part in your category.',
                  'Take a small first order and deliver it on time - the '
                      'rating starts here, and everything afterwards rests on '
                      'it.',
                ],
        ),
        const SizedBox(height: 14),
        Text(hi ? 'यहाँ क्या बिकता है' : 'What sells there',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'स्टेशनरी, फ़र्नीचर, सफ़ाई का सामान — दफ़्तरों की रोज़ की ख़रीद',
                  'स्कूल और आँगनवाड़ी का सामान: बैग, वर्दी, बर्तन, खेल का सामान',
                  'अस्पताल का रोज़ का सामान',
                  'सेवाएँ: सफ़ाई, सुरक्षा, ढुलाई, छपाई, मरम्मत',
                  'हस्तशिल्प और हथकरघा — इनके लिए अलग श्रेणियाँ हैं',
                ]
              : const [
                  'Stationery, furniture, cleaning supplies - what offices '
                      'buy routinely',
                  'School and anganwadi supplies: bags, uniforms, vessels, '
                      'sports goods',
                  'Everyday hospital consumables',
                  'Services: cleaning, security, transport, printing, '
                      'repairs',
                  'Handicrafts and handlooms, which have categories of their '
                      'own',
                ],
        ),
        ToolDonts(
          heading: hi ? 'शुरू करने से पहले' : 'Before you start',
          items: hi
              ? const [
                  'पंजीकरण या बिड दिलाने के नाम पर पैसा माँगने वाले "एजेंट" से बचें — '
                      'पोर्टल पर सब मुफ़्त है',
                  'जो समय पर नहीं दे सकते, उसका ऑर्डर न लें; देरी पर जुर्माना और '
                      'रेटिंग दोनों जाते हैं',
                  'दाम लगाते समय ढुलाई और भुगतान में लगने वाला समय ज़रूर जोड़ें — '
                      'सरकारी भुगतान में कुछ हफ़्ते लगते हैं',
                  'अपनी श्रेणी ग़लत न चुनें; ग़लत श्रेणी में डाली चीज़ कोई नहीं '
                      'ढूँढ़ पाता',
                ]
              : const [
                  'Avoid "agents" charging to register you or to land a bid - '
                      'everything on the portal is free',
                  'Do not take an order you cannot deliver on time; a delay '
                      'costs both a penalty and the rating',
                  'Price in the transport and the time to payment - '
                      'government payment takes some weeks',
                  'Do not pick the wrong category; an item in the wrong one '
                      'is never found',
                ],
        ),
        const SourceNote(text: 'Government e Marketplace', url: _gemUrl),
      ],
    );
  }
}

// --- UPI --------------------------------------------------------------

class UpiPage extends StatelessWidget {
  const UpiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 9,
      title: hi ? 'यूपीआई से भुगतान लेना' : 'Taking payments by UPI',
      children: [
        ToolNote(hi
            ? 'दुकान पर यूपीआई से पैसा लेना आमतौर पर मुफ़्त है — आम यूपीआई भुगतान पर '
                'दुकानदार से कोई शुल्क नहीं लिया जाता। और इसका एक छिपा फ़ायदा है जो '
                'ऋण के समय दिखता है: खाते में आई हर रक़म का रिकॉर्ड बन जाता है, और '
                'बैंक ऋण देते समय यही देखता है।'
            : 'Taking money by UPI at a shop is normally free - an ordinary '
                'UPI payment carries no charge to the merchant. And it has a '
                'hidden benefit that shows up at loan time: every rupee that '
                'arrives leaves a record, and that record is what a bank '
                'looks at.'),
        const SizedBox(height: 10),
        Text(hi ? 'क्या मुफ़्त है और क्या नहीं' : 'What is free and what is not',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        ToolLine(
            hi ? 'क्यूआर कोड से भुगतान लेना' : 'Taking payment by QR code',
            hi ? 'आमतौर पर मुफ़्त' : 'Normally free',
            strong: true),
        ToolLine(hi ? 'बैंक खाते में पैसा आना' : 'Money arriving in the account',
            hi ? 'मुफ़्त' : 'Free'),
        ToolLine(
            hi ? 'साउंड बॉक्स या कार्ड मशीन का किराया' : 'Rent on a sound box or card machine',
            hi ? 'शुल्क लगता है' : 'There is a charge'),
        ToolLine(
            hi ? 'क्रेडिट कार्ड या वॉलेट से बड़ा भुगतान' : 'A large wallet or card payment',
            hi ? 'शुल्क हो सकता है' : 'May carry a charge'),
        const SizedBox(height: 8),
        ToolNote(hi
            ? 'साउंड बॉक्स का किराया लेने से पहले हिसाब लगाइए: महीने का किराया कितना '
                'है और उससे कितनी बिक्री बढ़ेगी। छोटे ठेले पर सादा क्यूआर कोड का '
                'स्टिकर अक्सर उतना ही काम करता है और उसका कुछ नहीं लगता।'
            : 'Before renting a sound box, do the arithmetic: what the '
                'monthly rent is against how much more you will sell. On a '
                'small cart a plain printed QR sticker often does the same '
                'job and costs nothing.'),
        const SizedBox(height: 14),
        ToolDonts(
          heading: hi
              ? 'यूपीआई की ठगी — यही तरीक़े चलते हैं'
              : 'UPI fraud - these are the methods',
          items: hi
              ? const [
                  'पैसा लेने के लिए कोई पिन नहीं डाला जाता। जो कहे "पैसे आने के लिए '
                      'पिन डालिए" या कोई "रिक्वेस्ट" मंज़ूर करने को कहे — वह आपके '
                      'खाते से पैसा निकाल रहा है। पैसा लेने में पिन कभी नहीं लगता।',
                  'ओटीपी किसी को न बताएँ, बैंक या कंपनी का आदमी बताने वाले को भी '
                      'नहीं',
                  'स्क्रीन शेयर करने वाला ऐप किसी के कहने पर न डालें — "मैं ठीक कर '
                      'दूँगा" कहकर यही कराया जाता है',
                  'भुगतान का संदेश दिखाकर सामान ले जाने वाले से सावधान; अपने बैंक '
                      'खाते या ऐप में पैसा आया है, यह ख़ुद देखें — नक़ली संदेश बनाना '
                      'आसान है',
                  '"ग़लती से ज़्यादा पैसा भेज दिया, वापस कर दो" — पहले अपने खाते में '
                      'देखें कि असल में क्या आया',
                  'क्यूआर कोड का स्टिकर रोज़ देखें; दुकान के कोड पर दूसरा चिपका देना '
                      'आम ठगी है',
                ]
              : const [
                  'No PIN is ever entered to receive money. Anyone saying '
                      '"enter your PIN to get the payment" or asking you to '
                      'approve a request is taking money out of your '
                      'account. Receiving never needs a PIN.',
                  'Give the OTP to nobody, including someone claiming to be '
                      'from the bank or the company',
                  'Do not install a screen-sharing app because someone asked '
                      'you to - "let me fix it for you" is how that is done',
                  'Be wary of anyone showing a payment message and taking '
                      'the goods; check your own bank account or app '
                      'yourself - a fake message is easy to make',
                  '"I sent too much by mistake, send it back" - check your '
                      'account first for what actually arrived',
                  'Look at your QR sticker daily; pasting another code over '
                      'a shop\'s is a common fraud',
                ],
        ),
        const SizedBox(height: 14),
        ToolAnswer(
          headline: hi ? 'ठगी हो जाए तो' : 'If you are defrauded',
          detail: hi
              ? 'तुरंत दो काम करें: अपने बैंक या यूपीआई ऐप के ग्राहक सेवा नंबर पर '
                  'शिकायत दर्ज कराएँ और शिकायत संख्या लें, और साइबर अपराध की शिकायत '
                  'cybercrime.gov.in पर या 1930 पर दर्ज कराएँ। जल्दी करना सबसे ज़्यादा '
                  'मायने रखता है — कुछ घंटों के भीतर शिकायत करने पर रक़म रोकी जा सकने '
                  'की संभावना सबसे ज़्यादा होती है। लेन-देन की संख्या, समय और रक़म '
                  'तैयार रखें।'
              : 'Do two things at once: lodge a complaint on your bank\'s or '
                  'UPI app\'s customer service number and take the complaint '
                  'number, and report the cyber fraud at cybercrime.gov.in or '
                  'on 1930. Speed matters more than anything - reporting '
                  'within a few hours gives the best chance of the money '
                  'being held. Have the transaction number, the time and the '
                  'amount ready.',
          tone: ToolTone.bad,
          icon: Icons.report_outlined,
        ),
        const SourceNote(text: 'NPCI - UPI', url: _npciUrl),
        const SourceNote(
            text: 'National cybercrime reporting portal', url: _cyberUrl),
      ],
    );
  }
}
