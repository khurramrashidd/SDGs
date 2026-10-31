import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/i18n/locale_scope.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';

class Leader {
  final int id;
  final String name;
  final String field;
  final String years;
  final String known;

  const Leader({
    required this.id,
    required this.name,
    required this.field,
    required this.years,
    required this.known,
  });

  factory Leader.fromJson(Map<String, dynamic> j) => Leader(
        id: j['id'] as int,
        name: (j['name'] ?? '').toString(),
        field: (j['field'] ?? '').toString(),
        years: (j['years'] ?? '').toString(),
        known: (j['known'] ?? '').toString(),
      );
}

/// Indian women, described by what they did.
///
/// Two deliberate departures from the original EmpowHer list:
///   - It is Indian. A list of 20 Western figures is of limited use to a girl
///     in a small town working out what is possible for her.
///   - No quotes. Every entry in the original carried a quote that could not
///     be verified, and several widely-circulated ones are misattributed.
///     Achievements can be checked; quotes passed around the internet cannot.
class LeadersPage extends StatelessWidget {
  const LeadersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final pad = context.pagePadding;

    return Scaffold(
      appBar: AppBar(
        title: Text(hi ? 'भारत की महिलाएँ' : 'Women of India'),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(5)),
        ),
      ),
      body: ContentShell(
        maxWidth: 700,
        child: FutureBuilder<List<Leader>>(
          future: _load(),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final leaders = snap.data ?? const <Leader>[];
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(pad, 16, pad, 32),
              itemCount: leaders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _LeaderCard(leader: leaders[i]),
            );
          },
        ),
      ),
    );
  }

  /// Memoised - see the note in safety_page.dart.
  static Future<List<Leader>>? _cache;

  Future<List<Leader>> _load() {
    return _cache ??= () async {
      final raw =
          await rootBundle.loadString('assets/data/women_leaders.json');
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => Leader.fromJson(e as Map<String, dynamic>))
          .toList();
    }();
  }
}

class _LeaderCard extends StatelessWidget {
  final Leader leader;
  const _LeaderCard({required this.leader});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
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
                    leader.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  leader.years,
                  style:
                      TextStyle(fontSize: 12, color: scheme.outline),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                leader.field,
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: scheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              leader.known,
              style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
