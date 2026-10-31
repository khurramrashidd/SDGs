import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_languages.dart';
import '../../core/i18n/strings.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/brand.dart';
import '../../core/theme/settings_controller.dart';

/// The right-hand panel.
///
/// Deliberately not a mirror of the left drawer. The left one is navigation -
/// places you go. This one is for the things people change often and want
/// back out of immediately: theme, text size, language, and a glance at
/// what is new. Two identical drawers would just be two ways to do the same
/// thing.
class QuickPanel extends StatelessWidget {
  const QuickPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsController>();
    final scheme = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: scheme.primary),
                const SizedBox(width: 10),
                const Text('Quick settings',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 20),

            _Label(context.tr('theme')),
            Row(
              children: [
                Expanded(
                  child: _Toggle(
                    icon: Icons.light_mode_outlined,
                    label: context.tr('light'),
                    selected: s.themeMode == ThemeMode.light,
                    onTap: () => s.setThemeMode(ThemeMode.light),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Toggle(
                    icon: Icons.dark_mode_outlined,
                    label: context.tr('dark'),
                    selected: s.themeMode == ThemeMode.dark,
                    onTap: () => s.setThemeMode(ThemeMode.dark),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Toggle(
                    icon: Icons.brightness_auto_outlined,
                    label: 'Auto',
                    selected: s.themeMode == ThemeMode.system,
                    onTap: () => s.setThemeMode(ThemeMode.system),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            _Label(context.tr('app_language')),
            // A Wrap rather than a Row: 14 languages in two fixed columns
            // would truncate "മലയാളം" on a narrow panel. Chips reflow to
            // whatever width the panel actually has.
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final l in kAppLanguages)
                  _Toggle(
                    label: l.nativeName,
                    compact: true,
                    selected: s.locale.languageCode == l.code,
                    onTap: () => s.setLocale(l.code),
                  ),
              ],
            ),
            const SizedBox(height: 22),

            _Label(context.tr('text_size')),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kTextScaleOptions
                  .map((o) => _Toggle(
                        label: o.label,
                        selected: s.textScaleId == o.id,
                        compact: true,
                        onTap: () => s.setTextScale(o.id),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 22),

            _Label(context.tr('accent_colour')),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: kAccentOptions.map((o) {
                final sel = s.accentId == o.id;
                return InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => s.setAccent(o.id),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: o.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: sel ? scheme.onSurface : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: sel
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 19)
                        : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 26),
            const Divider(),
            const SizedBox(height: 10),
            const _RecentNotices(),
          ],
        ),
      ),
    );
  }
}

class _RecentNotices extends StatelessWidget {
  const _RecentNotices();

  @override
  Widget build(BuildContext context) {
    final service = context.watch<NotificationService>();
    final scheme = Theme.of(context).colorScheme;

    return StreamBuilder<List<AppNotification>>(
      stream: service.feed(),
      builder: (context, snap) {
        final items = (snap.data ?? const <AppNotification>[]).take(3);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _Label(context.tr('notifications'))),
                TextButton(
                  onPressed: () {
                    // Captured before the panel closes - see app_drawer.
                    final router = GoRouter.of(context);
                    Navigator.of(context).pop();
                    router.push('/notifications');
                  },
                  child: const Text('See all'),
                ),
              ],
            ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  context.tr('no_notifications'),
                  style: TextStyle(
                      fontSize: 13, color: scheme.onSurfaceVariant),
                ),
              ),
            ...items.map(
              (n) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                    if (n.createdAt != null)
                      Text(
                        DateFormat('d MMM, h:mm a').format(n.createdAt!),
                        style: TextStyle(
                            fontSize: 11, color: scheme.outline),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Toggle extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  const _Toggle({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? scheme.primaryContainer
          : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 6, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 19,
                    color: selected
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant),
                const SizedBox(height: 4),
              ],
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
}
