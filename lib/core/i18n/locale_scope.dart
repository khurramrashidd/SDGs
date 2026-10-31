/// A temporary, per-screen language override.
///
/// The app language lives in Settings and persists. This is the other thing
/// the user asked for: read *this one section* in another language without
/// changing the app. A woman reading the legal rights page may want it in
/// Marathi while keeping the rest of the interface in English she already
/// knows how to navigate.
///
/// It is deliberately not persisted. Leaving the screen drops it, which is
/// what "temporary" has to mean or it becomes a second, invisible setting
/// that the user cannot find later to turn off.
///
/// Mechanism: every module page already reads
/// `Localizations.localeOf(context)`. Wrapping a page in
/// `Localizations.override` therefore redirects all of it — interface strings
/// and content lookups alike — with no change to the pages themselves.
library;

import 'package:flutter/material.dart';

import 'app_languages.dart';
import 'strings.dart';

class LocaleScope extends StatefulWidget {
  final Widget child;

  const LocaleScope({super.key, required this.child});

  /// The language this subtree is currently showing. Falls back to the app
  /// language outside any scope, so it is always safe to call.
  static String languageOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_LocaleScopeData>()
          ?.effective ??
      Localizations.localeOf(context).languageCode;

  /// Whether this subtree is overridden rather than following the app.
  static bool isOverridden(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_LocaleScopeData>()
          ?.isOverridden ??
      false;

  /// The language set in Settings, which is NOT the same as
  /// `Localizations.localeOf` once a section is overridden.
  ///
  /// Everything inside this widget sits below `Localizations.override`, so
  /// asking Flutter for the locale there returns the section's language. The
  /// picker needs the real app language to say "your app language stays X"
  /// and to recognise when picking a language means clearing the override
  /// rather than setting one, so the scope captures it from above the
  /// override and passes it down.
  static String appLanguageOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_LocaleScopeData>()
          ?.appLanguage ??
      Localizations.localeOf(context).languageCode;

  /// Whether there is a scope above this context at all.
  ///
  /// A page reached by a route that forgot to wrap it would otherwise show a
  /// language button that silently does nothing when tapped. Hiding the
  /// button is the better failure: a missing control is a gap someone
  /// reports, a dead control is a bug they blame themselves for.
  static bool exists(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_LocaleScopeData>() != null;

  /// Sets the section language, or clears it with null.
  ///
  /// Not called `set`: after a return type, Dart reads `set` as the start of
  /// a setter declaration and the parse fails.
  static void setLanguage(BuildContext context, String? code) => context
      .dependOnInheritedWidgetOfExactType<_LocaleScopeData>()
      ?.state
      ._set(code);

  @override
  State<LocaleScope> createState() => _LocaleScopeState();
}

class _LocaleScopeState extends State<LocaleScope> {
  String? _override;

  void _set(String? code) {
    if (!mounted) return;
    setState(() => _override = code);
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = Localizations.localeOf(context).languageCode;
    final effective = _override ?? appLanguage;
    final overridden = effective != appLanguage;

    // Skip the override widget entirely when it would be a no-op. Fewer
    // layers, and no delegate reload for picking the language already in use.
    final body = overridden
        ? Localizations.override(
            context: context,
            locale: Locale(effective),
            child: widget.child,
          )
        : widget.child;

    return _LocaleScopeData(
      state: this,
      effective: effective,
      appLanguage: appLanguage,
      isOverridden: overridden,
      child: body,
    );
  }
}

class _LocaleScopeData extends InheritedWidget {
  final _LocaleScopeState state;
  final String effective;
  final String appLanguage;
  final bool isOverridden;

  const _LocaleScopeData({
    required this.state,
    required this.effective,
    required this.appLanguage,
    required this.isOverridden,
    required super.child,
  });

  @override
  bool updateShouldNotify(_LocaleScopeData old) =>
      old.effective != effective ||
      old.appLanguage != appLanguage ||
      old.isOverridden != isOverridden;
}

/// A pushed route carrying its own language scope.
///
/// A route pushed onto the Navigator is a sibling of the page that pushed
/// it, not a descendant, so it does not inherit that page's override. Each
/// screen therefore gets its own scope and its own switch — which is also
/// the behaviour the feature describes: per section, not per journey.
Route<T> localeScopedRoute<T>(Widget page) =>
    MaterialPageRoute<T>(builder: (_) => LocaleScope(child: page));

/// Put this in an AppBar's `actions`. Shows the section's current language
/// and opens the picker.
///
/// It shows the native short name rather than a globe icon alone, because a
/// globe tells a low-literacy user nothing about what will happen, whereas
/// "हिन्दी" is self-explanatory to exactly the person who needs it.
class SectionLanguageButton extends StatelessWidget {
  const SectionLanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!LocaleScope.exists(context)) return const SizedBox.shrink();

    final current = LocaleScope.languageOf(context);
    final overridden = LocaleScope.isOverridden(context);
    final lang = languageFor(current);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Tooltip(
        message: 'Read this section in another language',
        child: Material(
          color: overridden
              ? scheme.primary
              : scheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => showSectionLanguagePicker(context),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.translate,
                    size: 16,
                    color: overridden ? scheme.onPrimary : scheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    lang.nativeName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: overridden ? scheme.onPrimary : scheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The picker itself. Also reachable from anywhere that wants it, not only
/// the app-bar button.
Future<void> showSectionLanguagePicker(BuildContext context) async {
  final current = LocaleScope.languageOf(context);
  final overridden = LocaleScope.isOverridden(context);
  final appLanguage = LocaleScope.appLanguageOf(context);

  // Captured now, while we are still in a build-adjacent call with a live
  // element, rather than looked up again inside a tap handler after the
  // sheet has been popped.
  void apply(String? code) => LocaleScope.setLanguage(context, code);

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final scheme = Theme.of(sheetContext).colorScheme;

      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The sheet is a route of its own, so it sits outside
                    // the section override and these strings come out in
                    // the app language. That is the right way round: the
                    // person opening this menu is leaving a language they
                    // may not read.
                    Text(
                      sheetContext.tr('read_section_in'),
                      style: Theme.of(sheetContext).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${sheetContext.tr('only_this_screen')} '
                      '${sheetContext.tr('app_language')}: '
                      '${languageFor(appLanguage).nativeName}',
                      style: Theme.of(sheetContext)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 8),
                  children: [
                    if (overridden)
                      ListTile(
                        leading: const Icon(Icons.undo),
                        title: Text(sheetContext.tr('back_to_app_language')),
                        subtitle:
                            Text(languageFor(appLanguage).nativeName),
                        onTap: () {
                          apply(null);
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                    for (final l in kAppLanguages)
                      ListTile(
                        title: Text(
                          l.nativeName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          l.contentReady
                              ? l.englishName
                              : '${l.englishName} — '
                                  '${sheetContext.tr('ui_only_note')}',
                        ),
                        trailing: l.code == current
                            ? Icon(Icons.check, color: scheme.primary)
                            : null,
                        onTap: () {
                          // Choosing the app language clears the override
                          // rather than pinning it, so the screen goes back
                          // to following Settings.
                          apply(l.code == appLanguage ? null : l.code);
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Shown on a screen whose records have no text in the chosen language.
///
/// This is the honest half of the feature. Without it, a user switching to
/// Tamil sees Tamil buttons around English paragraphs and reasonably
/// concludes the app is broken. With it, they know the translation is missing
/// rather than failing — and that the English they are reading is current.
class TranslationGapNotice extends StatelessWidget {
  /// How many records on this screen have text in the current language.
  final int translated;

  /// How many records the screen is showing.
  final int total;

  const TranslationGapNotice({
    super.key,
    required this.translated,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final lang = LocaleScope.languageOf(context);
    if (lang == 'en' || total == 0 || translated >= total) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final name = languageFor(lang).nativeName;
    final missing = total - translated;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: scheme.onSecondaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              translated == 0
                  ? 'Not translated into $name yet. Showing English — the '
                      'information is the same and up to date.'
                  : '$missing of $total not yet in $name. Those are shown '
                      'in English.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.35,
                color: scheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
