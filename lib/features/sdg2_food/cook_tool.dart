import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// How much to cook for a function, so less of it is thrown away.
///
/// The biggest single act of food waste in an Indian household is a
/// wedding or a bhandara cooked by guesswork, where the cook's rule is
/// "better too much than too little" and a quarter of it goes in the bin.
/// This gives a figure to start from.
///
/// The quantities are the conventional per-head dry weights caterers work
/// with, not a nutrition standard - which is exactly what someone planning
/// a function needs. They are stated as a range, and the screen says
/// plainly that the right number depends on the crowd.
enum MealKind { fullMeal, lightMeal, snacksOnly }

/// Dry weight per person, in grams, before cooking.
class CookItem {
  final String en;
  final String hi;
  final double gramsFull;
  final double gramsLight;
  final bool snackToo;
  const CookItem(this.en, this.hi, this.gramsFull, this.gramsLight,
      {this.snackToo = false});

  double grams(MealKind kind) => switch (kind) {
        MealKind.fullMeal => gramsFull,
        MealKind.lightMeal => gramsLight,
        MealKind.snacksOnly => snackToo ? gramsLight : 0,
      };
}

const cookItems = [
  CookItem('Rice (dry)', 'चावल (सूखा)', 100, 70),
  CookItem('Wheat flour', 'गेहूँ का आटा', 100, 70),
  CookItem('Dal (dry)', 'दाल (सूखी)', 40, 30),
  CookItem('Vegetables', 'सब्ज़ी', 150, 100),
  CookItem('Oil or ghee', 'तेल या घी', 20, 15, snackToo: true),
  CookItem('Curd', 'दही', 50, 40),
  CookItem('Sugar (sweet dish)', 'चीनी (मिठाई के लिए)', 30, 20,
      snackToo: true),
  CookItem('Tea leaves', 'चाय पत्ती', 3, 3, snackToo: true),
  CookItem('Milk', 'दूध', 100, 80, snackToo: true),
];

class CookQuantityPage extends StatefulWidget {
  const CookQuantityPage({super.key});

  @override
  State<CookQuantityPage> createState() => _CookQuantityPageState();
}

class _CookQuantityPageState extends State<CookQuantityPage> {
  final _guests = TextEditingController(text: '100');
  MealKind _kind = MealKind.fullMeal;
  bool _manyChildren = false;

  @override
  void dispose() {
    _guests.dispose();
    super.dispose();
  }

  /// Children eat roughly half an adult portion, so a crowd with many of
  /// them needs less than its headcount suggests.
  double get _headFactor => _manyChildren ? 0.8 : 1.0;

  String _amount(double grams) {
    if (grams >= 1000) {
      final kg = grams / 1000;
      return '${kg.toStringAsFixed(kg >= 10 ? 0 : 1)} kg';
    }
    return '${grams.round()} g';
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final guests = int.tryParse(_guests.text.trim()) ?? 0;
    final heads = guests * _headFactor;

    return ToolScaffold(
      goal: 2,
      title: hi ? 'कितना पकाएँ' : 'How much to cook',
      children: [
        ToolNote(hi
            ? 'शादी या भंडारे में सबसे ज़्यादा खाना इसी वजह से बर्बाद होता है कि अंदाज़े से '
                'पकाया जाता है — "कम से ज़्यादा अच्छा है"। यहाँ से शुरू करें, फिर अपने '
                'अनुभव से घटाएँ-बढ़ाएँ।'
            : 'More food is wasted at a wedding or a bhandara for one '
                'reason: it is cooked by guesswork, on the rule that too '
                'much beats too little. Start here, then adjust from what '
                'you know of the crowd.'),
        ToolQuestion(hi ? 'कितने लोग' : 'How many people'),
        ToolNumber(
          controller: _guests,
          label: hi ? 'मेहमान' : 'Guests',
          maxDigits: 5,
          icon: Icons.groups_outlined,
          onChanged: (_) => setState(() {}),
        ),
        SwitchListTile(
          value: _manyChildren,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'इनमें बहुत से बच्चे हैं'
              : 'A lot of them are children'),
          subtitle: Text(
            hi
                ? 'बच्चे लगभग आधा खाते हैं, इसलिए गिनती से कम लगता है'
                : 'Children eat about half, so the headcount overstates it',
            style: const TextStyle(fontSize: 12),
          ),
          onChanged: (v) => setState(() => _manyChildren = v),
        ),
        ToolQuestion(hi ? 'कैसा खाना' : 'What kind of meal'),
        SelectionTile(
          label: hi ? 'पूरा भोजन' : 'A full meal',
          subtitle: hi
              ? 'चावल या रोटी, दाल, सब्ज़ी, मिठाई'
              : 'Rice or roti, dal, vegetables, something sweet',
          selected: _kind == MealKind.fullMeal,
          onTap: () => setState(() => _kind = MealKind.fullMeal),
        ),
        SelectionTile(
          label: hi ? 'हल्का भोजन' : 'A light meal',
          subtitle: hi
              ? 'एक मुख्य चीज़ और एक साथ की'
              : 'One main dish and one side',
          selected: _kind == MealKind.lightMeal,
          onTap: () => setState(() => _kind = MealKind.lightMeal),
        ),
        SelectionTile(
          label: hi ? 'सिर्फ़ चाय-नाश्ता' : 'Tea and snacks only',
          selected: _kind == MealKind.snacksOnly,
          onTap: () => setState(() => _kind = MealKind.snacksOnly),
        ),
        if (guests > 0) ...[
          ToolAnswer(
            headline: hi
                ? '$guests लोगों के लिए ख़रीदने की सूची'
                : 'What to buy for $guests people',
            detail: hi
                ? 'ये सूखी मात्राएँ हैं, पकाने से पहले की। इन्हें शुरुआत मानें।'
                : 'These are dry weights, before cooking. Treat them as a '
                    'starting point.',
            tone: ToolTone.plain,
            icon: Icons.shopping_basket_outlined,
          ),
          const SizedBox(height: 8),
          for (final item in cookItems)
            if (item.grams(_kind) > 0)
              ToolLine(hi ? item.hi : item.en,
                  _amount(item.grams(_kind) * heads)),
          const SizedBox(height: 14),
          Text(hi ? 'बचा खाना बर्बाद न हो' : 'So the extra is not wasted',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const ToolChecklist(
            storageKey: 'function_food_v1',
            items: [
              CheckItem('serve_less', 'Serve smaller portions, and offer '
                  'seconds', 'कम-कम परोसें, और दोबारा पूछें',
                  noteEn: 'A plate scraped into the bin cannot be shared '
                      'with anyone.',
                  noteHi: 'जो थाली में छोड़कर फेंका गया, वह किसी के काम नहीं आ '
                      'सकता।'),
              CheckItem('keep_back', 'Keep one batch uncooked until you see '
                  'the crowd', 'भीड़ देखने तक एक हिस्सा बिना पकाया रखें'),
              CheckItem('cover', 'Keep the untouched food covered and apart',
                  'जो परोसा नहीं गया उसे ढककर अलग रखें',
                  noteEn: 'Food that never reached a plate is the only kind '
                      'that can be given away.',
                  noteHi: 'जो खाना थाली तक पहुँचा ही नहीं, सिर्फ़ वही दिया जा सकता '
                      'है।'),
              CheckItem('plan', 'Decide before the function who will take '
                  'the extra', 'समारोह से पहले तय करें कि बचा खाना कौन लेगा'),
              CheckItem('check', 'Run the safety check before giving it away',
                  'देने से पहले सुरक्षा जाँच करें'),
            ],
          ),
          ToolNote(hi
              ? 'बचा हुआ खाना देने से पहले इसी लक्ष्य में "क्या यह बचा खाना बाँटा जा '
                  'सकता है" ज़रूर चलाएँ — पका खाना कमरे के तापमान पर कुछ ही घंटों में '
                  'असुरक्षित हो जाता है।'
              : 'Before giving leftovers away, run "Can this leftover food '
                  'be shared" in this same goal — cooked food at room '
                  'temperature stops being safe within hours.'),
        ],
      ],
    );
  }
}
