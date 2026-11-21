import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/tool_kit.dart';

/// Before you buy: which pack is really cheaper, and keeping track of
/// warranties.
///
/// The warranty list stays on this phone. It keeps what was bought, when,
/// and for how long - never a photo of the bill, which belongs in the
/// phone's own gallery where the person already knows how to find it.

const _nchUrl = 'https://consumerhelpline.gov.in/';

// --- Unit price -------------------------------------------------------

enum PackUnit { gram, kilo, ml, litre, piece }

double _toBase(PackUnit u, double q) {
  switch (u) {
    case PackUnit.gram:
    case PackUnit.ml:
      return q / 1000;
    case PackUnit.kilo:
    case PackUnit.litre:
    case PackUnit.piece:
      return q;
  }
}

String _unitWord(PackUnit u, bool hi) {
  switch (u) {
    case PackUnit.gram:
      return hi ? 'ग्राम' : 'g';
    case PackUnit.kilo:
      return hi ? 'किलो' : 'kg';
    case PackUnit.ml:
      return hi ? 'मिली' : 'ml';
    case PackUnit.litre:
      return hi ? 'लीटर' : 'litre';
    case PackUnit.piece:
      return hi ? 'नग' : 'pieces';
  }
}

String _baseWord(PackUnit u, bool hi) {
  switch (u) {
    case PackUnit.gram:
    case PackUnit.kilo:
      return hi ? 'किलो' : 'kilo';
    case PackUnit.ml:
    case PackUnit.litre:
      return hi ? 'लीटर' : 'litre';
    case PackUnit.piece:
      return hi ? 'नग' : 'piece';
  }
}

class UnitPricePage extends StatefulWidget {
  const UnitPricePage({super.key});

  @override
  State<UnitPricePage> createState() => _UnitPricePageState();
}

class _UnitPricePageState extends State<UnitPricePage> {
  PackUnit _unit = PackUnit.gram;
  final _priceA = TextEditingController();
  final _qtyA = TextEditingController();
  final _priceB = TextEditingController();
  final _qtyB = TextEditingController();

  @override
  void dispose() {
    for (final c in [_priceA, _qtyA, _priceB, _qtyB]) {
      c.dispose();
    }
    super.dispose();
  }

  double _v(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  Widget _pack(String title, TextEditingController price,
      TextEditingController qty, bool hi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ToolQuestion(title),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: price,
                label: hi ? 'दाम (₹)' : 'Price (₹)',
                decimal: true,
                maxDigits: 7,
                icon: Icons.currency_rupee,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: qty,
                label: hi
                    ? 'मात्रा (${_unitWord(_unit, hi)})'
                    : 'Quantity (${_unitWord(_unit, hi)})',
                decimal: true,
                maxDigits: 6,
                icon: Icons.scale_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final baseA = _toBase(_unit, _v(_qtyA));
    final baseB = _toBase(_unit, _v(_qtyB));
    final perA = baseA > 0 && _v(_priceA) > 0 ? _v(_priceA) / baseA : null;
    final perB = baseB > 0 && _v(_priceB) > 0 ? _v(_priceB) / baseB : null;
    final per = _baseWord(_unit, hi);

    return ToolScaffold(
      goal: 12,
      title: hi ? 'प्रति किलो दाम: कौन सा पैक सस्ता' : 'Unit price: which pack is cheaper',
      children: [
        ToolNote(hi
            ? 'बड़ा पैक हमेशा सस्ता नहीं होता। पैकेट पर "इकाई बिक्री मूल्य" — प्रति '
                'किलो या प्रति लीटर दाम — छापना अब ज़रूरी है, पर वह अक्सर बहुत छोटे '
                'अक्षरों में होता है। दोनों पैक की संख्या यहाँ डालिए।'
            : 'The big pack is not always cheaper. Packets are now required to '
                'print the "unit sale price" - the price per kilo or litre - '
                'but it is often in very small type. Put both packs\' numbers '
                'in here.'),
        ToolQuestion(hi ? 'मात्रा किसमें लिखी है' : 'What the quantity is in'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final u in PackUnit.values)
              ChoiceChip(
                label: Text(_unitWord(u, hi)),
                selected: _unit == u,
                onSelected: (_) => setState(() => _unit = u),
              ),
          ],
        ),
        _pack(hi ? 'पहला पैक' : 'First pack', _priceA, _qtyA, hi),
        _pack(hi ? 'दूसरा पैक' : 'Second pack', _priceB, _qtyB, hi),
        if (perA != null)
          ToolLine(hi ? 'पहला, प्रति $per' : 'First, per $per',
              '₹${perA.toStringAsFixed(2)}', strong: perB != null && perA < perB),
        if (perB != null)
          ToolLine(hi ? 'दूसरा, प्रति $per' : 'Second, per $per',
              '₹${perB.toStringAsFixed(2)}', strong: perA != null && perB < perA),
        if (perA != null && perB != null) ...[
          const SizedBox(height: 8),
          ToolAnswer(
            headline: (perA - perB).abs() < 0.005
                ? (hi ? 'दोनों बराबर हैं' : 'They are the same')
                : perA < perB
                    ? (hi ? 'पहला पैक सस्ता है' : 'The first pack is cheaper')
                    : (hi ? 'दूसरा पैक सस्ता है' : 'The second pack is cheaper'),
            detail: (perA - perB).abs() < 0.005
                ? (hi
                    ? 'प्रति $per दाम एक ही है।'
                    : 'The price per $per is the same.')
                : (hi
                    ? 'प्रति $per ${((perA - perB).abs() / (perA > perB ? perA : perB) * 100).toStringAsFixed(0)}% का फ़र्क़। '
                        'एक बात और: सस्ता बड़ा पैक तभी फ़ायदे का है जब पूरा इस्तेमाल '
                        'हो — ख़राब होकर फेंका गया आधा पैक सबसे महँगा पड़ता है।'
                    : 'A ${((perA - perB).abs() / (perA > perB ? perA : perB) * 100).toStringAsFixed(0)}% '
                        'difference per $per. One more thing: a cheaper big pack '
                        'only saves money if it all gets used - half a pack '
                        'thrown out spoiled is the dearest buy of all.'),
            tone: ToolTone.good,
            icon: Icons.compare_arrows,
          ),
        ],
      ],
    );
  }
}

// --- Warranty tracker -------------------------------------------------

class WarrantyItem {
  final String name;
  final String shop;
  final DateTime bought;
  final int months;
  const WarrantyItem(this.name, this.shop, this.bought, this.months);

  DateTime get ends {
    final m = bought.month - 1 + months;
    final y = bought.year + m ~/ 12;
    final month = m % 12 + 1;
    final lastDay = DateTime(y, month + 1, 0).day;
    return DateTime(y, month, bought.day > lastDay ? lastDay : bought.day);
  }

  Map<String, dynamic> toJson() => {
        'n': name,
        's': shop,
        'b': bought.toIso8601String(),
        'm': months,
      };

  static WarrantyItem? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final n = raw['n'];
    final b = DateTime.tryParse('${raw['b']}');
    final m = raw['m'];
    if (n is! String || b == null || m is! num) return null;
    return WarrantyItem(n, raw['s'] as String? ?? '', b, m.toInt());
  }
}

class WarrantyTrackerPage extends StatefulWidget {
  const WarrantyTrackerPage({super.key});

  @override
  State<WarrantyTrackerPage> createState() => _WarrantyTrackerPageState();
}

class _WarrantyTrackerPageState extends State<WarrantyTrackerPage> {
  static const _key = 'warranty_items_v1';
  static const _maxItems = 60;

  List<WarrantyItem> _items = const [];
  bool _loaded = false;
  final _name = TextEditingController();
  final _shop = TextEditingController();
  final _months = TextEditingController(text: '12');
  DateTime _bought = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_name, _shop, _months]) {
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
          _items = list
              .map(WarrantyItem.fromJson)
              .whereType<WarrantyItem>()
              .toList(growable: false);
        }
      }
    } catch (_) {
      // An unreadable store is treated as an empty list.
      _items = const [];
    }
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _save(List<WarrantyItem> next) async {
    final sorted = [...next]..sort((a, b) => a.ends.compareTo(b.ends));
    setState(() => _items = sorted);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode(sorted.map((e) => e.toJson()).toList()));
    } catch (_) {
      // The list stays in memory for this session.
    }
  }

  String _d(DateTime t) => '${t.day}/${t.month}/${t.year}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _bought,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    if (picked != null) setState(() => _bought = picked);
  }

  void _add() {
    final name = _name.text.trim();
    final months = int.tryParse(_months.text.trim()) ?? 0;
    if (name.isEmpty || months <= 0) return;
    final next = [
      ..._items,
      WarrantyItem(name, _shop.text.trim(), _bought, months),
    ]..sort((a, b) => a.ends.compareTo(b.ends));
    // When full, the warranty that ended longest ago makes room.
    while (next.length > _maxItems) {
      next.removeAt(0);
    }
    _name.clear();
    _shop.clear();
    _save(next);
  }

  Future<void> _remove(WarrantyItem item, bool hi) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(hi ? 'सूची से हटाएँ?' : 'Remove from the list?'),
        content: Text(item.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(hi ? 'नहीं' : 'No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(hi ? 'हटाएँ' : 'Remove'),
          ),
        ],
      ),
    );
    if (yes == true) {
      await _save(_items.where((e) => !identical(e, item)).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final today = DateTime.now();
    final soon = _items
        .where((e) =>
            !e.ends.isBefore(today) &&
            e.ends.difference(today).inDays <= 30)
        .toList();

    return ToolScaffold(
      goal: 12,
      title: hi ? 'वारंटी की सूची' : 'Warranty tracker',
      children: [
        ToolNote(hi
            ? 'यह सूची सिर्फ़ इस फ़ोन में रहती है। बिल की फ़ोटो अपने फ़ोन की गैलरी '
                'में रखें — यहाँ सिर्फ़ यह लिखा रहता है कि क्या, कब और कितने महीने '
                'के लिए। वारंटी ख़त्म होने से पहले की ख़राबी मुफ़्त ठीक होनी चाहिए, '
                'और लोग अक्सर तारीख़ भूल जाने से यह हक़ खो देते हैं।'
            : 'This list stays on this phone only. Keep the photo of the bill '
                'in your phone\'s gallery - here it only records what, when '
                'and for how many months. A fault before the warranty ends '
                'should be fixed free, and people often lose that right just '
                'by forgetting the date.'),
        ToolQuestion(hi ? 'नया सामान जोड़ें' : 'Add an item'),
        ToolText(
          controller: _name,
          label: hi ? 'क्या (जैसे: पंखा, फ़ोन, फ़्रिज)' : 'What (e.g. fan, phone, fridge)',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolText(
          controller: _shop,
          label: hi ? 'दुकान (वैकल्पिक)' : 'Shop (optional)',
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event_outlined),
                label: Text(hi
                    ? 'ख़रीदा: ${_d(_bought)}'
                    : 'Bought: ${_d(_bought)}'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _months,
                label: hi ? 'वारंटी (महीने)' : 'Warranty (months)',
                maxDigits: 3,
                icon: Icons.shield_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: _name.text.trim().isEmpty ? null : _add,
          icon: const Icon(Icons.add),
          label: Text(hi ? 'जोड़ें' : 'Add'),
        ),
        if (!_loaded)
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_items.isEmpty)
          ToolNote(hi
              ? 'अभी सूची ख़ाली है। फ़्रिज, पंखा, फ़ोन, मिक्सर, पानी की मोटर — '
                  'जिस पर भी वारंटी है, जोड़ लें।'
              : 'The list is empty. A fridge, fan, phone, mixer, water pump - '
                  'add anything with a warranty.')
        else ...[
          if (soon.isNotEmpty)
            ToolAnswer(
              headline: hi
                  ? '${soon.length} की वारंटी 30 दिन में ख़त्म'
                  : '${soon.length} ending within 30 days',
              detail: hi
                  ? 'इन्हें एक बार अच्छे से चलाकर देख लें। कोई ख़राबी हो तो अभी '
                      'सर्विस सेंटर में दर्ज कराएँ और जॉब-शीट लें — वारंटी ख़त्म होने '
                      'से पहले दर्ज ख़राबी मुफ़्त ठीक होनी चाहिए।'
                  : 'Run each of these properly once. If anything is wrong, '
                      'register it at the service centre now and take a job '
                      'sheet - a fault registered before the warranty ends '
                      'should be repaired free.',
              tone: ToolTone.warn,
              icon: Icons.notifications_active_outlined,
            ),
          const SizedBox(height: 10),
          for (final e in _items)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(e.name),
                subtitle: Text([
                  if (e.shop.isNotEmpty) e.shop,
                  hi ? 'ख़रीदा ${_d(e.bought)}' : 'Bought ${_d(e.bought)}',
                ].join(' · ')),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      e.ends.isBefore(today)
                          ? (hi ? 'ख़त्म' : 'Ended')
                          : _d(e.ends),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: e.ends.isBefore(today)
                            ? Theme.of(context).colorScheme.outline
                            : null,
                      ),
                    ),
                    Text(hi ? 'तक' : 'until',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                onLongPress: () => _remove(e, hi),
              ),
            ),
          ToolNote(hi
              ? 'किसी को हटाना हो तो उस पर देर तक दबाएँ।'
              : 'Press and hold an item to remove it.'),
        ],
        const SizedBox(height: 10),
        ToolNote(hi
            ? 'वारंटी में मरम्मत से मना करें, या बार-बार एक ही ख़राबी आए, तो इसी '
                'लक्ष्य में "ख़राब सामान मिला" वाली स्क्रीन से शिकायत पत्र बनाइए।'
            : 'If repair under warranty is refused, or the same fault keeps '
                'coming back, use "Defective product" in this goal to write the '
                'complaint.'),
        const SourceNote(text: 'National Consumer Helpline', url: _nchUrl),
      ],
    );
  }
}
