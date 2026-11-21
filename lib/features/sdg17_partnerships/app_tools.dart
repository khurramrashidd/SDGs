import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n/app_languages.dart';
import '../../core/issues/issue.dart';
import '../../core/issues/registry.dart';
import '../../core/theme/brand.dart';
import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';
import 'partnerships_pages.dart';

/// The app itself: translating it, sharing a tool from it, and where every
/// fact in it comes from.
///
/// Translations and fact corrections both go through the existing
/// correction form, which already has its Firestore collection, its rules
/// and its admin review screen. A second submission path would need its own
/// rules and its own moderator, so this file adds none.
///
/// This file imports the issue registry, which imports this goal's issue
/// list, which imports this file. Dart allows that cycle, and the registry
/// is only read inside build methods, long after every library has loaded.

// --- Translate --------------------------------------------------------

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  String? _lang;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final langs = kAppLanguages.where((l) => l.code != 'en').toList();

    return ToolScaffold(
      goal: 17,
      title: hi ? 'इस ऐप का अनुवाद करें' : 'Translate this app',
      children: [
        ToolNote(hi
            ? 'ऐप के बटन और मेनू 14 भाषाओं में हैं, पर उनका अनुवाद मशीन से हुआ है। '
                'जानकारी वाली सामग्री अभी अंग्रेज़ी और हिंदी में है। आप अपनी भाषा जानते '
                'हैं तो एक स्क्रीन की कुछ पंक्तियाँ भी बहुत मदद करती हैं — सब लोगों के लिए, '
                'बिना ऐप के नए संस्करण के।'
            : 'The app\'s buttons and menus are in 14 languages, but machine '
                'translated. The information itself is in English and Hindi so '
                'far. If you know your language, even a few lines of one screen '
                'help a great deal - for everyone, without a new version of the '
                'app.'),
        ToolQuestion(hi ? 'आपकी भाषा' : 'Your language'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final l in langs)
              ChoiceChip(
                label: Text(l.nativeName),
                selected: _lang == l.code,
                onSelected: (_) => setState(() => _lang = l.code),
              ),
          ],
        ),
        if (_lang != null) ...[
          const SizedBox(height: 12),
          Text(hi ? 'अच्छे अनुवाद के लिए' : 'For a good translation',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            numbered: false,
            steps: hi
                ? const [
                    'वही शब्द जो गाँव में बोले जाते हैं, किताबी नहीं',
                    'फ़ोन नंबर, रक़म, तारीख़ और योजनाओं के नाम वैसे ही रहने दें',
                    'हर पंक्ति के साथ स्क्रीन का नाम और अंग्रेज़ी वाली पंक्ति भी लिखें',
                    'एक बार में एक स्क्रीन — कम, पर पक्का',
                  ]
                : const [
                    'The words spoken in the village, not the bookish ones',
                    'Leave phone numbers, amounts, dates and scheme names as they '
                        'are',
                    'With each line, write the screen\'s name and the English '
                        'line too',
                    'One screen at a time - less, but sure',
                  ],
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CorrectionPage()),
            ),
            icon: const Icon(Icons.translate),
            label: Text(hi ? 'अनुवाद भेजें' : 'Send a translation'),
          ),
          const SizedBox(height: 6),
          ToolNote(hi
              ? 'यह सुधार भेजने वाला फ़ॉर्म खोलेगा। "क्या ग़लत है" वाले ख़ाने में भाषा '
                  '(${languageFor(_lang!).englishName}), स्क्रीन का नाम, और आपका अनुवाद '
                  'लिखें। हर अनुवाद पहले जाँचा जाता है, फिर सबको दिखता है।'
              : 'This opens the correction form. In the "what is wrong" box, write '
                  'the language (${languageFor(_lang!).englishName}), the screen\'s '
                  'name, and your translation. Every translation is checked '
                  'before everyone sees it.'),
        ],
      ],
    );
  }
}

// --- Share a tool -----------------------------------------------------

class ShareToolPage extends StatefulWidget {
  const ShareToolPage({super.key});

  @override
  State<ShareToolPage> createState() => _ShareToolPageState();
}

class _ShareToolPageState extends State<ShareToolPage> {
  final _query = TextEditingController();
  Issue? _picked;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  String _message(Issue i, bool hi) {
    final title = hi ? i.titleHi : i.titleEn;
    final blurb = hi ? i.blurbHi : i.blurbEn;
    return hi
        ? '$title\n$blurb\n\n${Brand.appName} (${Brand.companyName}) में: लक्ष्य '
            '${i.goal} → "$title"। मुफ़्त है, और हिंदी में भी।\n'
            '${CompanyLinks.website}'
        : '$title\n$blurb\n\nIn the ${Brand.appName} by ${Brand.companyName}: '
            'goal ${i.goal} → "$title". Free, and in Hindi too.\n'
            '${CompanyLinks.website}';
  }

  Future<void> _whatsapp(String text) async {
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final q = _query.text.trim().toLowerCase();
    final built = kAllIssues.where((i) => i.isBuilt);
    final shown = q.isEmpty
        ? const <Issue>[]
        : built
            .where((i) =>
                i.titleEn.toLowerCase().contains(q) ||
                i.titleHi.contains(q) ||
                i.keywords.any((k) => k.toLowerCase().contains(q)))
            .take(20)
            .toList();
    final picked = _picked;

    return ToolScaffold(
      goal: 17,
      title: hi ? 'किसी को कोई टूल भेजें' : 'Share a tool with someone',
      children: [
        ToolNote(hi
            ? 'जिसे ज़रूरत है, उसे ठीक वही टूल भेजें — एक संदेश में, जिसमें लिखा हो कि '
                'वह ऐप में कहाँ मिलेगा। संदेश में आपका कोई ब्योरा नहीं जाता।'
            : 'Send the person who needs it exactly that tool - in one message '
                'that says where to find it in the app. Nothing about you goes '
                'in the message.'),
        const SizedBox(height: 10),
        ToolText(
          controller: _query,
          label: hi ? 'टूल खोजें — जैसे राशन, पेंशन, बाढ़' : 'Find a tool - e.g. ration, pension, flood',
          onChanged: (_) => setState(() => _picked = null),
        ),
        if (picked != null) ...[
          const SizedBox(height: 10),
          CopyBlock(
            text: _message(picked, hi),
            note: hi
                ? 'कॉपी करके किसी भी ऐप में भेजें, या नीचे से सीधे व्हाट्सऐप पर।'
                : 'Copy it into any app, or send it straight to WhatsApp below.',
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => _whatsapp(_message(picked, hi)),
            icon: const Icon(Icons.send_outlined),
            label: Text(hi ? 'व्हाट्सऐप पर भेजें' : 'Send on WhatsApp'),
          ),
          TextButton(
            onPressed: () => setState(() => _picked = null),
            child: Text(hi ? 'दूसरा टूल चुनें' : 'Pick another tool'),
          ),
        ] else ...[
          for (final i in shown)
            SelectionTile(
              label: hi ? i.titleHi : i.titleEn,
              subtitle: hi ? 'लक्ष्य ${i.goal}' : 'Goal ${i.goal}',
              selected: false,
              onTap: () => setState(() => _picked = i),
            ),
          if (q.isNotEmpty && shown.isEmpty)
            ToolNote(hi
                ? 'इस शब्द से कोई टूल नहीं मिला। कोई और शब्द आज़माएँ।'
                : 'No tool found for that word. Try another.'),
          if (q.isEmpty)
            ToolNote(hi
                ? 'ऐप में ${built.length} टूल हैं। ऊपर एक शब्द लिखें।'
                : 'There are ${built.length} tools in the app. Type a word above.'),
        ],
      ],
    );
  }
}

// --- Where every fact comes from --------------------------------------

/// The bundled data files, with a plain name for each.
const _dataFiles = <(String, String, String)>[
  ('subsidies.json', 'Government schemes', 'सरकारी योजनाएँ'),
  ('scholarships.json', 'Scholarships', 'छात्रवृत्ति'),
  ('helplines.json', 'Helplines', 'हेल्पलाइन'),
  ('health_helplines.json', 'Health helplines', 'स्वास्थ्य हेल्पलाइन'),
  ('health_myths.json', 'Health myths and facts', 'स्वास्थ्य के भ्रम और तथ्य'),
  ('free_care.json', 'Free care', 'मुफ़्त इलाज'),
  ('vaccination_schedule.json', 'Child vaccination', 'बच्चों के टीके'),
  ('legal_rights.json', 'Legal rights', 'कानूनी अधिकार'),
  ('civic_rights.json', 'Police and civic rights', 'पुलिस और नागरिक अधिकार'),
  ('work_rights.json', 'Work rights', 'काम के अधिकार'),
  ('food_safety.json', 'Food safety', 'खाद्य सुरक्षा'),
  ('water_guides.json', 'Water', 'पानी'),
  ('energy_guides.json', 'Energy', 'ऊर्जा'),
  ('enterprise_guides.json', 'Enterprise', 'उद्यम'),
  ('equality_guides.json', 'Equality', 'समानता'),
  ('cities_guides.json', 'Towns and housing', 'शहर और आवास'),
  ('consumption_guides.json', 'Buying and waste', 'ख़रीद और कचरा'),
  ('climate_guides.json', 'Climate', 'जलवायु'),
  ('ocean_guides.json', 'The sea', 'समुद्र'),
  ('land_guides.json', 'Land and forest', 'ज़मीन और जंगल'),
  ('learning_guides.json', 'Learning', 'पढ़ाई'),
  ('women_wellness.json', 'Women\'s health', 'महिला स्वास्थ्य'),
];

class _Count {
  final int total;
  final int checked;
  final int sourced;
  const _Count(this.total, this.checked, this.sourced);
}

Future<Map<String, _Count>> _countAll() async {
  final out = <String, _Count>{};
  for (final f in _dataFiles) {
    try {
      final raw = await rootBundle.loadString('assets/data/${f.$1}');
      final list = jsonDecode(raw);
      if (list is! List) continue;
      var checked = 0;
      var sourced = 0;
      for (final r in list) {
        if (r is! Map) continue;
        if (r['verified'] == true) checked++;
        final s = r['source'] ?? r['officialLink'];
        if (s is String && s.trim().isNotEmpty) sourced++;
      }
      out[f.$1] = _Count(list.length, checked, sourced);
    } catch (_) {
      // A file that will not load is left out rather than miscounted.
    }
  }
  return out;
}

class SourcesPage extends StatefulWidget {
  const SourcesPage({super.key});

  @override
  State<SourcesPage> createState() => _SourcesPageState();
}

class _SourcesPageState extends State<SourcesPage> {
  late final Future<Map<String, _Count>> _counts = _countAll();

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 17,
      title: hi ? 'यहाँ की हर जानकारी कहाँ से आती है' : 'Where every fact here comes from',
      children: [
        ToolNote(hi
            ? 'इस ऐप की हर जानकारी के साथ उसका सरकारी स्रोत लिखा है, और यह भी कि उसे '
                'किसी जानकार ने जाँचा है या नहीं। जो जाँची नहीं गई, वह "जाँच बाक़ी" दिखती '
                'है — छिपाई नहीं जाती। नीचे की गिनती इसी संस्करण के साथ आई सामग्री की है।'
            : 'Every fact in this app carries its official source, and whether '
                'someone qualified has checked it. What has not been checked '
                'shows as "not yet checked" - it is not hidden. The count below '
                'is of the content shipped with this version.'),
        const SizedBox(height: 12),
        FutureBuilder<Map<String, _Count>>(
          future: _counts,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final counts = snap.data ?? const <String, _Count>{};
            final total = counts.values.fold<int>(0, (a, c) => a + c.total);
            final checked = counts.values.fold<int>(0, (a, c) => a + c.checked);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ToolAnswer(
                  headline: hi
                      ? '$total में से $checked जाँचे गए'
                      : '$checked of $total checked',
                  detail: hi
                      ? 'बाक़ी डॉक्टर, वकील और विषय के जानकारों की जाँच के लिए क़तार में हैं। '
                          'जाँच होने तक हर रिकॉर्ड अपने सरकारी स्रोत के साथ दिखता है, ताकि आप '
                          'ख़ुद मिला सकें।'
                      : 'The rest are queued for review by doctors, lawyers and '
                          'subject experts. Until then each record shows with its '
                          'official source, so you can check it yourself.',
                  tone: checked == total ? ToolTone.good : ToolTone.plain,
                  icon: Icons.fact_check_outlined,
                ),
                const SizedBox(height: 10),
                for (final f in _dataFiles)
                  if (counts[f.$1] != null && counts[f.$1]!.total > 0)
                    ToolLine(
                      hi ? f.$3 : f.$2,
                      hi
                          ? '${counts[f.$1]!.checked}/${counts[f.$1]!.total} जाँचे'
                          : '${counts[f.$1]!.checked}/${counts[f.$1]!.total} checked',
                    ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        Text(hi ? 'जो जानबूझकर नहीं लिखा गया' : 'What is left out on purpose',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'जो रक़में जल्दी बदलती हैं — एमएसपी, बिजली की दरें, गैस सब्सिडी, राज्य '
                      'योजनाओं की रक़म, किराया — वे नहीं दी जातीं। उनकी जगह आप अपने बिल या '
                      'सरकारी पोर्टल की संख्या डालते हैं और ऐप हिसाब लगाता है',
                  'परीक्षा और आवेदन की तारीख़ें — सिर्फ़ महीने, क्योंकि तारीख़ें हर साल बदलती '
                      'हैं',
                  'दवा की खुराक — कभी नहीं; पैकेट, पर्चा या डॉक्टर',
                  'जहाँ क़ानून बदल रहा है — जैसे ट्रांसजेंडर पहचान पत्र — वहाँ क़दम-दर-क़दम '
                      'प्रक्रिया नहीं, सिर्फ़ जो तय है और सही जगह का पता',
                ]
              : const [
                  'Figures that change quickly - MSP, power tariffs, gas subsidy, '
                      'state scheme amounts, fares - are not given. Instead you '
                      'enter the number from your bill or the official portal '
                      'and the app does the arithmetic',
                  'Exam and application dates - months only, because the dates '
                      'move every year',
                  'Medicine doses - never; the packet, the prescription or the '
                      'doctor',
                  'Where a law is in flux - the transgender ID card, for one - '
                      'no step-by-step process, only what is settled and where to '
                      'ask',
                ],
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const CorrectionPage()),
          ),
          icon: const Icon(Icons.edit_outlined),
          label: Text(hi ? 'कोई ग़लती दिखी? बताएँ' : 'Spotted a mistake? Tell us'),
        ),
      ],
    );
  }
}
