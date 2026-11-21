import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../layout/responsive.dart';

/// The pieces every decision tool in this app is built from.
///
/// Two hundred-odd tools, each hand-written, only stays consistent if the
/// parts are shared. These are the parts: a number field that cannot be
/// typed wrong, one big answer, a draft you can copy, and a checklist that
/// remembers itself. A tool that needs something else gets it written by
/// hand - this is a kit, not a framework.

/// A number the user types, with the unit beside it.
class ToolNumber extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helper;
  final String? suffix;
  final bool decimal;
  final int maxDigits;
  final ValueChanged<String>? onChanged;
  final IconData? icon;

  const ToolNumber({
    super.key,
    required this.controller,
    required this.label,
    this.helper,
    this.suffix,
    this.decimal = false,
    this.maxDigits = 9,
    this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
              decimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]')),
          LengthLimitingTextInputFormatter(maxDigits),
        ],
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          helperMaxLines: 3,
          suffixText: suffix,
          prefixIcon: icon == null ? null : Icon(icon),
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

/// Plain text the user types.
class ToolText extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? helper;
  final int maxLength;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const ToolText({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.helper,
    this.maxLength = 80,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helper,
          helperMaxLines: 3,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

/// How strongly an answer should land.
enum ToolTone { good, warn, bad, plain }

/// The answer, stated once and large.
///
/// Every tool ends in one of these. A tool that ends in a paragraph has not
/// finished its job: the person came with a question and must leave with a
/// sentence they can act on.
class ToolAnswer extends StatelessWidget {
  final String headline;
  final String? detail;
  final ToolTone tone;
  final IconData? icon;

  const ToolAnswer({
    super.key,
    required this.headline,
    this.detail,
    this.tone = ToolTone.plain,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color bg, Color fg) = switch (tone) {
      ToolTone.good => (scheme.primaryContainer, scheme.onPrimaryContainer),
      ToolTone.warn => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      ToolTone.bad => (scheme.errorContainer, scheme.onErrorContainer),
      ToolTone.plain => (scheme.surfaceContainerHighest, scheme.onSurface),
    };
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(icon, color: fg),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(headline,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        color: fg)),
              ),
            ],
          ),
          if (detail != null) ...[
            const SizedBox(height: 8),
            Text(detail!,
                style: TextStyle(fontSize: 14, height: 1.55, color: fg)),
          ],
        ],
      ),
    );
  }
}

/// A row of the answer's workings, so the number is never a black box.
class ToolLine extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;
  const ToolLine(this.label, this.value, {super.key, this.strong = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13.5,
                    color: strong ? null : scheme.onSurfaceVariant,
                    fontWeight: strong ? FontWeight.w700 : null)),
          ),
          const SizedBox(width: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: strong ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }
}

/// A draft letter or complaint, ready to copy.
class CopyBlock extends StatelessWidget {
  final String text;
  final String? note;
  const CopyBlock({super.key, required this.text, this.note});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SelectableText(text,
              style: const TextStyle(fontSize: 14, height: 1.55)),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: text));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(hi ? 'कॉपी हो गया' : 'Copied')));
          },
          icon: const Icon(Icons.copy),
          label: Text(hi ? 'कॉपी करें' : 'Copy'),
        ),
        if (note != null) ...[
          const SizedBox(height: 8),
          Text(note!,
              style: TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: scheme.onSurfaceVariant)),
        ],
      ],
    );
  }
}

/// Where a fact came from. Every tool that states a rule carries one.
class SourceNote extends StatelessWidget {
  final String text;
  final String url;
  const SourceNote({super.key, required this.text, required this.url});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Text(
        '$text\n$url',
        style: TextStyle(
            fontSize: 11.5, height: 1.5, color: scheme.onSurfaceVariant),
      ),
    );
  }
}

/// One item in a checklist that remembers itself.
class CheckItem {
  final String id;
  final String en;
  final String hi;
  final String? noteEn;
  final String? noteHi;
  const CheckItem(this.id, this.en, this.hi, {this.noteEn, this.noteHi});

  String label(String lang) => lang == 'hi' ? hi : en;
  String? note(String lang) => lang == 'hi' ? noteHi : noteEn;
}

/// A list of things to gather or do, ticked off and kept on the phone.
///
/// Kept on the phone and nowhere else: a list of the papers a family is
/// missing is nobody else's business.
class ToolChecklist extends StatefulWidget {
  /// Unique per checklist, e.g. 'papers_v1'. Changing it resets the ticks.
  final String storageKey;
  final List<CheckItem> items;
  final String? introEn;
  final String? introHi;

  const ToolChecklist({
    super.key,
    required this.storageKey,
    required this.items,
    this.introEn,
    this.introHi,
  });

  @override
  State<ToolChecklist> createState() => _ToolChecklistState();
}

class _ToolChecklistState extends State<ToolChecklist> {
  Set<String> _done = {};
  bool _loaded = false;

  String get _key => 'checklist_${widget.storageKey}';

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      setState(() {
        _done = (prefs.getStringList(_key) ?? const []).toSet();
        _loaded = true;
      });
    });
  }

  Future<void> _toggle(String id) async {
    setState(() {
      _done.contains(id) ? _done.remove(id) : _done.add(id);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _done.toList());
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final hi = lang == 'hi';
    final scheme = Theme.of(context).colorScheme;
    if (!_loaded) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final intro = hi ? widget.introHi : widget.introEn;
    final left = widget.items.where((i) => !_done.contains(i.id)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (intro != null) ...[
          Text(intro, style: const TextStyle(fontSize: 13.5, height: 1.5)),
          const SizedBox(height: 10),
        ],
        Text(
          left == 0
              ? (hi ? 'सब हो गया।' : 'All done.')
              : hi
                  ? '$left बाक़ी'
                  : '$left left',
          style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: left == 0 ? scheme.primary : scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        for (final item in widget.items)
          CheckboxListTile(
            value: _done.contains(item.id),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(item.label(lang),
                style: const TextStyle(fontSize: 14.5, height: 1.35)),
            subtitle: item.note(lang) == null
                ? null
                : Text(item.note(lang)!,
                    style: TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: scheme.onSurfaceVariant)),
            onChanged: (_) => _toggle(item.id),
          ),
      ],
    );
  }
}

/// A short explainer between the questions and the answer.
class ToolNote extends StatelessWidget {
  final String text;
  const ToolNote(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
}

/// Numbered steps, in order, that are not meant to be ticked off.
///
/// `ToolChecklist` saves its ticks to the phone, which is right for a list
/// of papers to collect over weeks and wrong for an emergency: nobody ticks
/// boxes during a snakebite, and on a shared phone a saved tick can be read
/// by the wrong person. So anything urgent, and anything about a woman's
/// safety, uses this instead - it keeps nothing.
class ToolSteps extends StatelessWidget {
  final List<String> steps;

  /// Numbers the steps. Off for a list where the order does not matter.
  final bool numbered;

  const ToolSteps({super.key, required this.steps, this.numbered = true});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: numbered
                      ? Text('${i + 1}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: scheme.onPrimaryContainer))
                      : Icon(Icons.check, size: 14,
                          color: scheme.onPrimaryContainer),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(steps[i],
                      style: const TextStyle(fontSize: 14, height: 1.45)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The things that must not be done, set apart so they are read.
///
/// On an emergency screen the don'ts matter more than the dos: a tourniquet
/// or a cut costs a limb, and chilli or mustard oil in a dog bite helps the
/// virus along. People already know they should get to a hospital. What
/// they do in the twenty minutes before that is what this is for.
class ToolDonts extends StatelessWidget {
  final String heading;
  final List<String> items;
  const ToolDonts({super.key, required this.heading, required this.items});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dangerous_outlined, size: 20,
                  color: scheme.onErrorContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(heading,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: scheme.onErrorContainer)),
              ),
            ],
          ),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.close, size: 16, color: scheme.onErrorContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item,
                        style: TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            color: scheme.onErrorContainer)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Centres a tool's own scrolling body. Tools that do not use ToolScaffold
/// (because they need their own app bar) wrap their list in this.
class ToolBody extends StatelessWidget {
  final List<Widget> children;
  const ToolBody({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;
    return ContentShell(
      maxWidth: 640,
      child: ListView(
        padding: EdgeInsets.fromLTRB(pad, 16, pad, 40),
        children: children,
      ),
    );
  }
}
