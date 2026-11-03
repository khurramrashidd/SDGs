import 'package:flutter/material.dart';

import '../i18n/locale_scope.dart';
import '../i18n/strings.dart';
import '../layout/responsive.dart';
import '../sdg/advice.dart';
import '../theme/brand.dart';
import 'guide_list_page.dart';

/// The home screen of one goal: a coloured app bar, an optional hero card
/// for the main tool, then labelled sections of rows.
///
/// Goals 1-9 and 16 each have their own hand-built hub; goals 10-15 and 17
/// share this one, so seven new modules do not mean seven more copies of
/// the same row and label widgets.
class ModuleHub extends StatelessWidget {
  final int goal;
  final String titleKey;
  final List<Widget> children;

  const ModuleHub({
    super.key,
    required this.goal,
    required this.titleKey,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(titleKey)),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(goal)),
        ),
      ),
      body: ContentShell(
        maxWidth: 700,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
          children: children,
        ),
      ),
    );
  }
}

/// The main tool of a goal, as a tinted card with one button.
class HubHero extends StatelessWidget {
  final int goal;
  final String title;
  final String body;
  final String button;
  final IconData icon;
  final VoidCallback onTap;

  const HubHero({
    super.key,
    required this.goal,
    required this.title,
    required this.body,
    required this.button,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = SdgColors.of(goal);
    return Card(
      color: accent.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, height: 1.3)),
            const SizedBox(height: 8),
            Text(body, style: const TextStyle(fontSize: 14, height: 1.55)),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onTap,
              icon: Icon(icon),
              label: Text(button),
            ),
          ],
        ),
      ),
    );
  }
}

class HubLabel extends StatelessWidget {
  final String text;
  const HubLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 8, left: 2),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
}

class HubRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const HubRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: scheme.primary),
        title: Text(title,
            style:
                const TextStyle(fontWeight: FontWeight.w600, height: 1.25)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(subtitle,
              style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Opens [page] with the per-screen language switch available.
void pushScoped(BuildContext context, Widget page) =>
    Navigator.of(context).push(localeScopedRoute(page));

/// A question-and-answer tool screen: questions on top, answers appear
/// below once enough is chosen. Shared by the goal 10-17 tools.
class ToolScaffold extends StatelessWidget {
  final int goal;
  final String title;
  final List<Widget> children;

  const ToolScaffold({
    super.key,
    required this.goal,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(goal)),
        ),
      ),
      body: ContentShell(
        maxWidth: 640,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
          children: children,
        ),
      ),
    );
  }
}

class ToolQuestion extends StatelessWidget {
  final String text;
  const ToolQuestion(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 10),
        child: Text(text,
            style:
                const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
      );
}

/// A tool's answer: a heading, then one card per piece of advice, each with
/// its official link. Unverified advice says so, because every record in
/// this app ships unverified until someone checks it.
class AdviceList extends StatelessWidget {
  final String heading;
  final List<Advice> items;
  const AdviceList({super.key, required this.heading, required this.items});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 22),
        Text(heading,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        for (final a in items) ...[
          GuideCard(row: a.toRow()),
          const SizedBox(height: 10),
        ],
        Text(
          hi
              ? 'यह सामान्य जानकारी है, क़ानूनी सलाह नहीं। हर कार्ड का आधिकारिक लिंक खोलकर '
                  'जाँचें — नियम बदलते रहते हैं।'
              : 'This is general information, not legal advice. Open the '
                  'official link on each card to check — rules change.',
          style: TextStyle(
              fontSize: 12, height: 1.45, color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
