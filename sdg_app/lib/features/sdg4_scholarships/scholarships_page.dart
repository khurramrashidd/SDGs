import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n/locale_scope.dart';
import '../../core/i18n/strings.dart';
import '../../core/theme/brand.dart';
import '../../core/layout/responsive.dart';
import 'profile_setup_page.dart';
import 'scholarship_model.dart';
import 'scholarship_repository.dart';
import 'student_profile.dart';

class ScholarshipsPage extends StatefulWidget {
  const ScholarshipsPage({super.key});

  @override
  State<ScholarshipsPage> createState() => _ScholarshipsPageState();
}

class _ScholarshipsPageState extends State<ScholarshipsPage> {
  final _repo = ScholarshipRepository();
  late Future<List<Scholarship>> _future;
  bool _showEverything = false;

  @override
  void initState() {
    super.initState();
    _future = _repo.load();
    // Load the locally stored profile if this is a return visit.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProfileStore>().load();
    });
  }

  Future<void> _openSetup() async {
    final saved = await Navigator.of(context).push<bool>(
      localeScopedRoute(const ProfileSetupPage()),
    );
    if (saved == true && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StudentProfileStore>();
    final profile = store.profile;
    final accent = SdgColors.of(4);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('sdg4_title')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: accent),
        ),
        actions: [
          const SectionLanguageButton(),
          if (profile.isComplete)
            IconButton(
              tooltip: 'Edit your details',
              icon: const Icon(Icons.tune),
              onPressed: _openSetup,
            ),
        ],
      ),
      body: ContentShell(
        child: FutureBuilder<List<Scholarship>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = snap.data ?? const <Scholarship>[];

            if (!profile.isComplete) {
              return _Intro(count: all.length, onStart: _openSetup);
            }

            final scored = all
                .map((s) => (s, profile.matchFor(s)))
                .toList();
            final shown = _showEverything
                ? scored
                : scored
                    .where((e) => e.$2 != MatchLevel.unlikely)
                    .toList();

            final strong = scored
                .where((e) => e.$2 == MatchLevel.strong)
                .length;

            return ListView(
              padding: EdgeInsets.fromLTRB(context.pagePadding, 12, context.pagePadding, 28),
              children: [
                _SummaryCard(strong: strong, total: all.length),
                const SizedBox(height: 16),
                ...shown.map((e) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ScholarshipCard(
                          scholarship: e.$1, match: e.$2),
                    )),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: () => setState(
                        () => _showEverything = !_showEverything),
                    icon: Icon(_showEverything
                        ? Icons.filter_list
                        : Icons.list),
                    label: Text(_showEverything
                        ? 'Show only my matches'
                        : 'Show all ${all.length} scholarships'),
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

class _Intro extends StatelessWidget {
  final int count;
  final VoidCallback onStart;
  const _Intro({required this.count, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: EdgeInsets.fromLTRB(context.pagePadding, 32, context.pagePadding, 32),
      children: [
        Icon(Icons.school_outlined, size: 56, color: SdgColors.of(4)),
        const SizedBox(height: 20),
        const Text(
          'Find the scholarships you qualify for',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          'Most students miss scholarships not because they were rejected, '
          'but because nobody told them it existed or the date passed.\n\n'
          'Answer a few questions and we will show which of the $count '
          'schemes fit you, what documents you need, and when each one '
          'closes.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 32),
        FilledButton(onPressed: onStart, child: const Text('Start')),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Takes under a minute · stays on your phone',
            style:
                TextStyle(fontSize: 12, color: scheme.outline),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int strong;
  final int total;
  const _SummaryCard({required this.strong, required this.total});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            '$strong',
            style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: scheme.onPrimaryContainer),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              strong == 1
                  ? 'scholarship matches your details'
                  : 'scholarships match your details',
              style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: scheme.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScholarshipCard extends StatelessWidget {
  final Scholarship scholarship;
  final MatchLevel match;
  const _ScholarshipCard(
      {required this.scholarship, required this.match});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          localeScopedRoute(ScholarshipDetailPage(
                scholarship: scholarship, match: match)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      scholarship.name,
                      style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          height: 1.3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _MatchBadge(match: match),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                scholarship.provider,
                style: TextStyle(
                    fontSize: 12.5, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              _DeadlineRow(scholarship: scholarship),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  final MatchLevel match;
  const _MatchBadge({required this.match});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, bg, fg) = switch (match) {
      MatchLevel.strong => (
          'Match',
          scheme.primaryContainer,
          scheme.onPrimaryContainer
        ),
      MatchLevel.check => (
          'Check',
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer
        ),
      MatchLevel.unlikely => (
          'Unlikely',
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant
        ),
    };

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: fg)),
    );
  }
}

class _DeadlineRow extends StatelessWidget {
  final Scholarship scholarship;
  const _DeadlineRow({required this.scholarship});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final days = scholarship.daysLeft;

    // No admin-entered deadline: say so plainly rather than guess.
    if (days == null) {
      return Row(
        children: [
          Icon(Icons.event_busy_outlined,
              size: 16, color: scheme.outline),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Closing date not confirmed - check the portal',
              style: TextStyle(fontSize: 12.5, color: scheme.outline),
            ),
          ),
        ],
      );
    }

    if (days < 0) {
      return Row(
        children: [
          Icon(Icons.lock_clock, size: 16, color: scheme.outline),
          const SizedBox(width: 6),
          Text('Closed for this year',
              style:
                  TextStyle(fontSize: 12.5, color: scheme.outline)),
        ],
      );
    }

    final urgent = scholarship.isUrgent;
    return Row(
      children: [
        Icon(urgent ? Icons.alarm : Icons.event_outlined,
            size: 16,
            color: urgent ? scheme.error : scheme.primary),
        const SizedBox(width: 6),
        Text(
          days == 0
              ? 'Closes today'
              : days == 1
                  ? 'Closes tomorrow'
                  : 'Closes in $days days · '
                      '${DateFormat('d MMM').format(scholarship.deadline!)}',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: urgent ? FontWeight.w700 : FontWeight.w500,
            color: urgent ? scheme.error : scheme.primary,
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------ detail

class ScholarshipDetailPage extends StatelessWidget {
  final Scholarship scholarship;
  final MatchLevel match;
  const ScholarshipDetailPage(
      {super.key, required this.scholarship, required this.match});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Scholarship')),
      body: ContentShell(
        maxWidth: 700,
        child: ListView(
        padding: EdgeInsets.fromLTRB(context.pagePadding, 16, context.pagePadding, 32),
        children: [
          Text(scholarship.name,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.3)),
          const SizedBox(height: 6),
          Text(scholarship.provider,
              style: TextStyle(
                  fontSize: 13, color: scheme.onSurfaceVariant)),
          const SizedBox(height: 18),
          _DeadlineRow(scholarship: scholarship),
          const SizedBox(height: 24),

          if (match == MatchLevel.check)
            _Note(
              icon: Icons.help_outline,
              text:
                  'Your income looks higher than the limit we have on '
                  'record. Apply anyway if you think you qualify - limits '
                  'change and exceptions exist. Confirm on the portal.',
              bg: scheme.tertiaryContainer,
              fg: scheme.onTertiaryContainer,
            ),
          if (match == MatchLevel.unlikely)
            _Note(
              icon: Icons.info_outline,
              text:
                  'This one does not look like a fit for the details you '
                  'entered, but nothing stops you reading the full criteria.',
              bg: scheme.surfaceContainerHighest,
              fg: scheme.onSurfaceVariant,
            ),

          const SizedBox(height: 20),
          const Text('Documents usually needed',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...scholarship.documents.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_box_outline_blank,
                      size: 18, color: scheme.outline),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(d,
                          style: const TextStyle(
                              fontSize: 14, height: 1.4))),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          if (!scholarship.verified)
            _Note(
              icon: Icons.verified_outlined,
              text:
                  'These details have not been re-checked against the '
                  'official portal this year. Always confirm there before '
                  'relying on them.',
              bg: scheme.surfaceContainerHighest,
              fg: scheme.onSurfaceVariant,
            ),

          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => launchUrl(
              Uri.parse(scholarship.portal),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open the official portal'),
          ),
        ],
      ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color bg;
  final Color fg;
  const _Note({
    required this.icon,
    required this.text,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(12)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 19, color: fg),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 13, height: 1.45, color: fg)),
            ),
          ],
        ),
      );
}
