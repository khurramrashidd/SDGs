import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/guide_list_page.dart';
import '../../core/widgets/module_hub.dart';
import 'consumption_tools.dart';

/// SDG 12 — Responsible Consumption and Production.
class ConsumptionHomePage extends StatelessWidget {
  const ConsumptionHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    return ModuleHub(
      goal: 12,
      titleKey: 'sdg12_title',
      children: [
        HubHero(
          goal: 12,
          title: hi
              ? 'पैकेट पर "हेल्दी" लिखा है — सच में?'
              : 'The packet says "healthy" — is it?',
          body: hi
              ? 'पीछे की पोषण तालिका से चार अंक डालें: वसा, संतृप्त वसा, चीनी, नमक। '
                  'हम बताएँगे कौन सा कम, मध्यम या ज़्यादा है।'
              : 'Type four numbers from the nutrition table on the back: fat, '
                  'saturated fat, sugar, salt. See which are low, medium or high.',
          button: hi ? 'लेबल जाँचें' : 'Check a label',
          icon: Icons.fact_check_outlined,
          onTap: () => pushScoped(context, const LabelCheckPage()),
        ),
        HubLabel(hi ? 'कम फेंकें' : 'Throw away less'),
        HubRow(
          icon: Icons.build_outlined,
          title: hi ? 'मरम्मत का अधिकार' : 'Right to repair',
          subtitle: hi
              ? 'फ़ोन, उपकरण — कंपनी मरम्मत से मना करे तो'
              : 'Phones, appliances — when the company will not repair',
          onTap: () => pushScoped(
            context,
            const GuideListPage(
              collection: 'consumption',
              category: 'repair',
              title: 'Right to repair',
              titleHi: 'मरम्मत का अधिकार',
              goal: 12,
            ),
          ),
        ),
        HubRow(
          icon: Icons.phonelink_erase_outlined,
          title: hi ? 'ई-कचरा और प्लास्टिक' : 'E-waste and plastic',
          subtitle: hi
              ? 'पुराना फ़ोन, बैटरी, बल्ब, और प्रतिबंधित प्लास्टिक'
              : 'Old phones, batteries, bulbs, and banned plastics',
          onTap: () => pushScoped(
            context,
            const GuideListPage(
              collection: 'consumption',
              category: 'waste',
              title: 'E-waste and plastic',
              titleHi: 'ई-कचरा और प्लास्टिक',
              goal: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class LabelCheckPage extends StatefulWidget {
  const LabelCheckPage({super.key});

  @override
  State<LabelCheckPage> createState() => _LabelCheckPageState();
}

class _LabelCheckPageState extends State<LabelCheckPage> {
  final _c = {for (final n in Nutrient.values) n: TextEditingController()};
  final _serving = TextEditingController();
  bool _perServing = false;
  bool _sodium = false;

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    _serving.dispose();
    super.dispose();
  }

  double? _value(Nutrient n) {
    final raw = double.tryParse(_c[n]!.text.trim());
    if (raw == null || raw < 0) return null;
    var v = raw;
    if (n == Nutrient.salt && _sodium) v = saltFromSodiumMg(v);
    if (_perServing) {
      final s = double.tryParse(_serving.text.trim()) ?? 0;
      return per100g(v, s);
    }
    return v;
  }

  String _name(Nutrient n, bool hi) => switch (n) {
        Nutrient.fat => hi ? 'वसा (फ़ैट)' : 'Fat',
        Nutrient.saturates => hi ? 'संतृप्त वसा' : 'Saturated fat',
        Nutrient.sugars => hi ? 'चीनी (शुगर)' : 'Sugars',
        Nutrient.salt => _sodium
            ? (hi ? 'सोडियम (मि.ग्रा.)' : 'Sodium (mg)')
            : (hi ? 'नमक' : 'Salt'),
      };

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;
    final results = {for (final n in Nutrient.values) n: _value(n)};
    final any = results.values.any((v) => v != null);
    final highs = results.entries
        .where((e) => e.value != null && levelOf(e.key, e.value!) == Level.high)
        .length;

    Color colour(Level l) => switch (l) {
          Level.low => Colors.green.shade600,
          Level.medium => Colors.amber.shade700,
          Level.high => Colors.red.shade600,
        };
    String word(Level l) => switch (l) {
          Level.low => hi ? 'कम' : 'Low',
          Level.medium => hi ? 'मध्यम' : 'Medium',
          Level.high => hi ? 'ज़्यादा' : 'High',
        };

    return ToolScaffold(
      goal: 12,
      title: hi ? 'लेबल जाँचें' : 'Check a label',
      children: [
        Text(
          hi
              ? 'सिर्फ़ खाने की चीज़ों के लिए, पेय के लिए नहीं। पैकेट पर "प्रति 100 ग्राम" '
                  'वाला कॉलम देखें।'
              : 'For foods only, not drinks. Use the "per 100 g" column on the '
                  'packet if there is one.',
          style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _perServing,
          title: Text(hi
              ? 'पैकेट पर सिर्फ़ "प्रति सर्विंग" दिया है'
              : 'The packet only gives "per serving"'),
          onChanged: (v) => setState(() => _perServing = v),
        ),
        if (_perServing)
          TextField(
            controller: _serving,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
            ],
            decoration: InputDecoration(
              labelText: hi ? 'एक सर्विंग कितने ग्राम' : 'Serving size in grams',
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _sodium,
          title: Text(hi
              ? 'नमक की जगह सोडियम (मि.ग्रा.) लिखा है'
              : 'It shows sodium (mg) instead of salt'),
          onChanged: (v) => setState(() => _sodium = v),
        ),
        const SizedBox(height: 6),
        for (final n in Nutrient.values) ...[
          TextField(
            controller: _c[n],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
            ],
            decoration: InputDecoration(
              labelText: _name(n, hi),
              suffixText: n == Nutrient.salt && _sodium ? 'mg' : 'g',
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
        ],
        if (any) ...[
          const SizedBox(height: 8),
          Text(hi ? 'प्रति 100 ग्राम' : 'Per 100 g',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          for (final e in results.entries)
            if (e.value != null)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: colour(levelOf(e.key, e.value!)),
                      radius: 10),
                  title: Text(
                      e.key == Nutrient.salt ? (hi ? 'नमक' : 'Salt') : _name(e.key, hi)),
                  subtitle: Text('${e.value!.toStringAsFixed(1)} g'),
                  trailing: Text(word(levelOf(e.key, e.value!)),
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: colour(levelOf(e.key, e.value!)))),
                ),
              ),
          const SizedBox(height: 6),
          Text(
            highs == 0
                ? (hi
                    ? 'कोई भी "ज़्यादा" नहीं। फिर भी सामग्री सूची देखें — पहली चीज़ सबसे ज़्यादा मात्रा में होती है।'
                    : 'Nothing is high. Still read the ingredients — the first '
                        'one listed is what the food contains most of.')
                : (hi
                    ? '$highs चीज़ें "ज़्यादा" हैं। इसे रोज़ का नहीं, कभी-कभार का खाना मानें, और '
                        'ऐसी दूसरी चीज़ से तुलना करें।'
                    : '$highs ${highs == 1 ? 'is' : 'are'} high. Treat it as an '
                        'occasional food rather than an everyday one, and '
                        'compare it with a similar product.'),
            style: const TextStyle(fontWeight: FontWeight.w600, height: 1.45),
          ),
          const SizedBox(height: 10),
          Text(
            hi
                ? 'सीमाएँ ब्रिटेन की "ट्रैफ़िक लाइट" प्रणाली से हैं — तुलना के लिए एक गाइड, '
                    'डॉक्टरी सीमा नहीं। डायबिटीज़ या ब्लड प्रेशर हो तो अपने डॉक्टर की सलाह मानें।'
                : 'Limits are the UK "traffic light" values — a guide for '
                    'comparing products, not a medical limit. With diabetes '
                    'or high blood pressure, follow your doctor\'s advice.',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          const GuideCard(row: {
            'title': 'Source: NHS, food labels',
            'titleHi': 'स्रोत: एनएचएस, खाने के लेबल',
            'body': 'Low and high per 100 g — fat 3 g / 17.5 g, saturated fat '
                '1.5 g / 5 g, sugars 5 g / 22.5 g, salt 0.3 g / 1.5 g.',
            'bodyHi': 'प्रति 100 ग्राम कम और ज़्यादा — वसा 3 / 17.5 ग्राम, संतृप्त '
                'वसा 1.5 / 5 ग्राम, चीनी 5 / 22.5 ग्राम, नमक 0.3 / 1.5 ग्राम।',
            'source': nhsSource,
          }),
        ],
      ],
    );
  }
}
