import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n/localized_content.dart';
import '../../core/i18n/locale_scope.dart';
import '../../core/content/content_store.dart';
import '../../core/content/dataset_registry.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import 'safety_exit.dart';

class Helpline {
  final int id;
  final String number;
  final String name;
  final String detail;
  final String category;
  final int priority;
  final bool verified;
  final Map<String, dynamic> raw;

  const Helpline({
    required this.id,
    required this.number,
    required this.name,
    required this.detail,
    required this.category,
    required this.priority,
    required this.verified,
    required this.raw,
  });

  factory Helpline.fromJson(Map<String, dynamic> j) => Helpline(
        id: j['id'] as int,
        number: (j['number'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        detail: (j['detail'] ?? '').toString(),
        category: (j['category'] ?? '').toString(),
        priority: j['priority'] is int ? j['priority'] as int : 99,
        verified: j['verified'] == true,
        raw: j,
      );

  String title(String lang) => pickLocalized(raw, 'name', lang);
  String body(String lang) => pickLocalized(raw, 'detail', lang);
}

/// Reads through ContentStore, so an admin correction to a number or its
/// description reaches every device without a new APK.
Future<List<Helpline>> loadHelplines() async {
  final ds = kDatasets.firstWhere((d) => d.collection == 'helplines');
  final rows = await ContentStore.instance.rows(ds);
  return rows.map(Helpline.fromJson).toList()
    ..sort((a, b) => a.priority.compareTo(b.priority));
}

class SafetyPage extends StatefulWidget {
  const SafetyPage({super.key});

  @override
  State<SafetyPage> createState() => _SafetyPageState();
}

class _SafetyPageState extends State<SafetyPage> {
  // Held in state so a theme change does not rebuild the future and flash
  // a loading spinner.
  late final Future<List<Helpline>> _future = loadHelplines();

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final pad = context.pagePadding;

    return Scaffold(
      appBar: AppBar(
        title: Text(hi ? 'मदद और सुरक्षा' : 'Help and safety'),
        actions: const [
          SectionLanguageButton(),
          QuickExitButton(),
          SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(5)),
        ),
      ),
      body: ContentShell(
        maxWidth: 640,
        child: FutureBuilder<List<Helpline>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final lines = snap.data ?? const <Helpline>[];
            return ListView(
              padding: EdgeInsets.fromLTRB(pad, 14, pad, 32),
              children: [
                const SafetyLimitsNote(),
                const SizedBox(height: 18),
                Text(
                  hi
                      ? 'ये सभी नंबर निःशुल्क हैं। टैप करके सीधे कॉल करें।'
                      : 'All of these are free to call. Tap to dial.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                ...lines.map((h) => _HelplineCard(line: h, hi: hi)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HelplineCard extends StatelessWidget {
  final Helpline line;
  final bool hi;
  const _HelplineCard({required this.line, required this.hi});

  Future<void> _dial(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: line.number);
    try {
      final ok = await launchUrl(uri);
      if (!ok && context.mounted) _copyFallback(context);
    } catch (_) {
      if (context.mounted) _copyFallback(context);
    }
  }

  /// Some devices (tablets, no SIM) cannot place calls. Rather than failing
  /// silently, put the number on the clipboard and say so.
  void _copyFallback(BuildContext context) {
    Clipboard.setData(ClipboardData(text: line.number));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(hi
            ? 'यह फ़ोन कॉल नहीं कर सकता। नंबर ${line.number} कॉपी कर लिया गया है।'
            : 'This device cannot place calls. ${line.number} copied to clipboard.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final urgent = line.priority <= 1;
    final lang = LocaleScope.languageOf(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _dial(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: urgent
                      ? scheme.errorContainer
                      : scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  line.number,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: urgent
                        ? scheme.onErrorContainer
                        : scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.title(lang),
                      style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          height: 1.25),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      line.body(lang),
                      style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.phone, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
