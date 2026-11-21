import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_languages.dart';
import '../../core/i18n/strings.dart';
import '../../core/issues/saved_tools.dart';
import '../../core/place/place_picker_page.dart';
import '../../core/place/place_service.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import '../../core/theme/settings_controller.dart';
import '../../core/widgets/selection_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>();
    final pad = context.pagePadding;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings'))),
      body: ContentShell(
        maxWidth: 620,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 12, pad, 40),
          children: [
            _SectionTitle(context.tr('appearance')),

            // ---- theme ----
            _Label(context.tr('theme')),
            _ThemeChooser(current: s.themeMode, onPick: s.setThemeMode),
            const SizedBox(height: 24),

            // ---- accent colour ----
            _Label(context.tr('accent_colour')),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: kAccentOptions.map((o) {
                final selected = s.accentId == o.id;
                return Semantics(
                  selected: selected,
                  button: true,
                  label: o.label,
                  child: Tooltip(
                    message: o.label,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () => s.setAccent(o.id),
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: o.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? Theme.of(context).colorScheme.onSurface
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 24)
                            : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // ---- text size ----
            _Label(context.tr('text_size')),
            ...kTextScaleOptions.map(
              (o) => SelectionTile(
                label: o.label,
                textScale: o.scale,
                selected: s.textScaleId == o.id,
                onTap: () => s.setTextScale(o.id),
              ),
            ),
            const SizedBox(height: 20),

            _SectionTitle(context.tr('app_language')),
            // Every language shows its own name first. Someone looking for
            // Kannada scans for "ಕನ್ನಡ", not for the word "Kannada".
            //
            // The subtitle is where the honesty lives: most of these have a
            // translated interface but English articles, and saying so here
            // is better than letting someone switch and conclude the app is
            // broken.
            ...kAppLanguages.map(
              (l) => SelectionTile(
                label: l.nativeName,
                subtitle: l.contentReady
                    ? l.englishName
                    : '${l.englishName} · ${context.tr('ui_only_note')}',
                selected: s.locale.languageCode == l.code,
                onTap: () => s.setLocale(l.code),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.translate, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You can also read a single section in another '
                      'language without changing this setting — use the '
                      'language button at the top of any screen.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            _SectionTitle(
                Localizations.localeOf(context).languageCode == 'hi'
                    ? 'आपकी जगह और आपका डेटा'
                    : 'Your place and your data'),
            const _PlaceSetting(),
            const _SavedSetting(),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const _BrandFooter(),
          ],
        ),
      ),
    );
  }
}

/// Segmented control on wide screens, stacked tiles on narrow ones - three
/// labelled segments do not fit on a 320dp phone without truncating.
class _ThemeChooser extends StatelessWidget {
  final ThemeMode current;
  final ValueChanged<ThemeMode> onPick;

  const _ThemeChooser({required this.current, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final options = <(ThemeMode, String, IconData)>[
      (ThemeMode.light, context.tr('light'), Icons.light_mode_outlined),
      (ThemeMode.dark, context.tr('dark'), Icons.dark_mode_outlined),
      (ThemeMode.system, context.tr('system'),
          Icons.brightness_auto_outlined),
    ];

    if (context.isCompact) {
      return Column(
        children: options
            .map((o) => SelectionTile(
                  label: o.$2,
                  selected: current == o.$1,
                  onTap: () => onPick(o.$1),
                ))
            .toList(),
      );
    }

    return SegmentedButton<ThemeMode>(
      segments: options
          .map((o) => ButtonSegment(
                value: o.$1,
                label: Text(o.$2),
                icon: Icon(o.$3),
              ))
          .toList(),
      selected: {current},
      showSelectedIcon: false,
      onSelectionChanged: (v) => onPick(v.first),
    );
  }
}

class _BrandFooter extends StatelessWidget {
  const _BrandFooter();

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    return Center(
      child: Column(
        children: [
          const Text(
            Brand.companyName,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 2),
          Text(Brand.tagline,
              style: TextStyle(fontSize: 12, color: outline)),
          const SizedBox(height: 8),
          Text(Brand.supportEmail,
              style: TextStyle(fontSize: 12, color: outline)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)),
      );
}

/// Where the app thinks you are, and how to change it.
class _PlaceSetting extends StatelessWidget {
  const _PlaceSetting();

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final service = context.watch<PlaceService>();
    final place = service.place;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.place_outlined),
        title: Text(hi ? 'आपकी जगह' : 'Your place'),
        subtitle: Text(
          place == null
              ? (hi ? 'अभी तय नहीं' : 'Not set yet')
              : place.chosen
                  ? place.label
                  : '${place.label} · ${hi ? 'अंदाज़ा' : 'guessed'}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const PlacePickerPage())),
      ),
    );
  }
}

/// Clears bookmarks and the recently-opened list.
///
/// Worth its own setting because the list of tools someone opened can be
/// revealing - the abuse screens, the ration appeal - and a shared phone is
/// normal. One tap wipes it.
class _SavedSetting extends StatelessWidget {
  const _SavedSetting();

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final saved = context.watch<SavedTools>();
    final count = saved.saved.length + saved.recent.length;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.bookmark_outline),
        title: Text(hi ? 'सहेजे और हाल के टूल' : 'Saved and recent tools'),
        subtitle: Text(
          count == 0
              ? (hi ? 'कुछ नहीं रखा है' : 'Nothing kept')
              : hi
                  ? '$count चीज़ें, सिर्फ़ इस फ़ोन पर'
                  : '$count items, on this phone only',
        ),
        trailing: TextButton(
          onPressed: count == 0
              ? null
              : () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(hi ? 'सब मिटाएँ?' : 'Clear all?'),
                      content: Text(hi
                          ? 'सहेजे और हाल में खोले गए टूल हट जाएँगे।'
                          : 'Saved and recently opened tools are removed.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(hi ? 'रहने दें' : 'Cancel')),
                        FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(hi ? 'मिटाएँ' : 'Clear')),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) {
                    await context.read<SavedTools>().clearAll();
                  }
                },
          child: Text(hi ? 'मिटाएँ' : 'Clear'),
        ),
      ),
    );
  }
}
