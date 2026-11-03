import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n/locale_scope.dart';
import '../../core/content/content_store.dart';
import '../../core/content/dataset_registry.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import 'health_models.dart';

/// Myth versus fact.
///
/// Designed to be *shown to someone else*, not just read. That drives three
/// choices: the myth is stated first in the person's own words so they
/// recognise it, every card carries a "why it matters" that names the real
/// harm, and every card can be copied for WhatsApp in one tap.
class MythsPage extends StatefulWidget {
  const MythsPage({super.key});

  @override
  State<MythsPage> createState() => _MythsPageState();
}

class _MythsPageState extends State<MythsPage> {
  late final Future<List<MythCard>> _future = _load();
  String _category = '';

  /// Through ContentStore, so a correction made in the admin screen reaches
  /// every device. Health misinformation is exactly the content that needs
  /// fixing faster than an APK release cycle allows.
  Future<List<MythCard>> _load() async {
    final ds = kDatasets.firstWhere((d) => d.collection == 'myths');
    final rows = await ContentStore.instance.rows(ds);
    return rows.map(MythCard.fromJson).toList();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final pad = context.pagePadding;

    return Scaffold(
      appBar: AppBar(
        title: Text(hi ? 'अफ़वाह और सच' : 'Myth vs fact'),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(3)),
        ),
      ),
      body: ContentShell(
        maxWidth: 720,
        child: FutureBuilder<List<MythCard>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = snap.data ?? const <MythCard>[];
            final shown = _category.isEmpty
                ? all
                : all.where((c) => c.category == _category).toList();

            return Column(
              children: [
                SizedBox(
                  height: 46,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: pad),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(hi ? 'सभी' : 'All'),
                          selected: _category.isEmpty,
                          onSelected: (_) =>
                              setState(() => _category = ''),
                        ),
                      ),
                      ...kMythCategories.entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(hi ? e.value.$2 : e.value.$1),
                            selected: _category == e.key,
                            onSelected: (v) => setState(
                                () => _category = v ? e.key : ''),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(pad, 6, pad, 28),
                    itemCount: shown.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, i) =>
                        _Card(card: shown[i], hi: hi),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final MythCard card;
  final bool hi;
  const _Card({required this.card, required this.hi});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lang = LocaleScope.languageOf(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The myth first, in the words people actually use, so a reader
            // recognises their own belief rather than feeling lectured.
            _Band(
              icon: Icons.record_voice_over_outlined,
              label: hi ? 'लोग कहते हैं' : 'What people say',
              text: card.mythText(lang),
              bg: scheme.errorContainer,
              fg: scheme.onErrorContainer,
              strike: true,
            ),
            const SizedBox(height: 12),
            _Band(
              icon: Icons.verified_outlined,
              label: hi ? 'सच यह है' : 'What is true',
              text: card.factText(lang),
              bg: scheme.primaryContainer,
              fg: scheme.onPrimaryContainer,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.priority_high,
                    size: 17, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    card.whyText(lang),
                    style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                        color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _copy(context, lang),
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: Text(hi ? 'साझा करें' : 'Share'),
                ),
                const Spacer(),
                if (card.source.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => launchUrl(Uri.parse(card.source),
                        mode: LaunchMode.externalApplication),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: Text(hi ? 'स्रोत' : 'Source',
                        style: const TextStyle(fontSize: 13)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Copy rather than a share sheet: the share_plus plugin would add a
  /// native dependency for something a clipboard paste into WhatsApp does
  /// just as well.
  Future<void> _copy(BuildContext context, String lang) async {
    await Clipboard.setData(ClipboardData(text: card.shareText(lang)));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(hi
            ? 'कॉपी हो गया — अब WhatsApp में पेस्ट करें'
            : 'Copied — now paste it into WhatsApp'),
      ),
    );
  }
}

class _Band extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  final Color bg;
  final Color fg;
  final bool strike;

  const _Band({
    required this.icon,
    required this.label,
    required this.text,
    required this.bg,
    required this.fg,
    this.strike = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: fg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.5,
              color: fg,
              fontWeight: strike ? FontWeight.w500 : FontWeight.w600,
              decoration:
                  strike ? TextDecoration.lineThrough : null,
              decorationColor: fg.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}
