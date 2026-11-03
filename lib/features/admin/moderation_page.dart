import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/layout/responsive.dart';
import '../sdg2_food/food_board.dart';
import '../sdg4_scholarships/qa.dart';

/// Everything people post, waiting for a human.
///
/// Study questions and answers stay invisible until approved here. Food
/// board posts go live straight away (food cannot wait for a review) but
/// three reports hide one, and reported posts are listed here to delete.
/// Firestore rules decide who can actually act: SDG 4 admins for Q&A, any
/// admin for the food board.
class ModerationPage extends StatelessWidget {
  const ModerationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Moderation'),
          bottom: const TabBar(isScrollable: true, tabs: [
            Tab(text: 'Q&A queue'),
            Tab(text: 'Q&A reports'),
            Tab(text: 'Food board'),
            Tab(text: 'Corrections'),
          ]),
        ),
        body: const ContentShell(
          maxWidth: 760,
          child: TabBarView(children: [
            _QaQueue(),
            _QaReports(),
            _FoodReports(),
            _Corrections(),
          ]),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty(this.text);

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(text, textAlign: TextAlign.center),
        ),
      );
}

class _QaQueue extends StatelessWidget {
  const _QaQueue();

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;
    return StreamBuilder<List<QaItem>>(
      stream: QaService.pendingQuestions(),
      builder: (context, qs) => StreamBuilder<List<QaItem>>(
        stream: QaService.pendingAnswers(),
        builder: (context, as) {
          if (qs.hasError || as.hasError) {
            return const _Empty(
                'Could not load. Q&A moderation needs admin access to SDG 4.');
          }
          if (!qs.hasData || !as.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final q = qs.data!, a = as.data!;
          if (q.isEmpty && a.isEmpty) {
            return const _Empty('Nothing waiting.');
          }
          return ListView(
            padding: EdgeInsets.fromLTRB(pad, 12, pad, 36),
            children: [
              const Text(
                'Approve only what is about studying. Reject anything with '
                'personal details, requests to talk elsewhere or meet, or '
                'anything unkind. When unsure, reject.',
                style: TextStyle(fontSize: 13, height: 1.45),
              ),
              const SizedBox(height: 12),
              for (final item in q) _ReviewCard(item: item, isAnswer: false),
              for (final item in a) _ReviewCard(item: item, isAnswer: true),
            ],
          );
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final QaItem item;
  final bool isAnswer;
  const _ReviewCard({required this.item, required this.isAnswer});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isAnswer ? 'ANSWER' : 'QUESTION · ${item.subject} · ${item.level}',
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: scheme.primary)),
            if (isAnswer)
              FutureBuilder<String>(
                future: QaService.questionText(item.qid),
                builder: (_, s) => Text('To: ${s.data ?? '…'}',
                    style: TextStyle(
                        fontSize: 12.5, color: scheme.onSurfaceVariant)),
              ),
            const SizedBox(height: 6),
            SelectableText(item.text, style: const TextStyle(height: 1.45)),
            const SizedBox(height: 10),
            Row(children: [
              FilledButton(
                onPressed: () => QaService.review(item, isAnswer, true),
                child: const Text('Approve'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => QaService.review(item, isAnswer, false),
                child: const Text('Reject'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _QaReports extends StatelessWidget {
  const _QaReports();

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: QaService.reports(),
      builder: (context, snap) {
        if (snap.hasError) {
          return const _Empty('Could not load. Needs admin access to SDG 4.');
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snap.data!;
        if (list.isEmpty) return const _Empty('No reports.');
        return ListView(
          padding: EdgeInsets.fromLTRB(pad, 12, pad, 36),
          children: [for (final r in list) _QaReportCard(report: r)],
        );
      },
    );
  }
}

class _QaReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  const _QaReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final isAnswer = report['kind'] == 'answer';
    final itemId = '${report['itemId']}';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: FutureBuilder<QaItem?>(
          future: QaService.item(itemId, isAnswer),
          builder: (context, snap) {
            final item = snap.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reported ${report['kind']} · reason: ${report['reason']}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(item == null
                    ? (snap.connectionState == ConnectionState.done
                        ? '(already deleted)'
                        : '…')
                    : '${item.text}\n\nStatus: ${item.status}'),
                const SizedBox(height: 10),
                Wrap(spacing: 8, children: [
                  if (item != null && item.status == 'approved')
                    FilledButton(
                      onPressed: () async {
                        await QaService.review(item, isAnswer, false);
                        await QaService.dismissReport('${report['id']}');
                      },
                      child: const Text('Take down'),
                    ),
                  OutlinedButton(
                    onPressed: () =>
                        QaService.dismissReport('${report['id']}'),
                    child: const Text('Dismiss report'),
                  ),
                ]),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FoodReports extends StatelessWidget {
  const _FoodReports();

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;
    return StreamBuilder<List<FoodPost>>(
      stream: FoodBoardService.reported(),
      builder: (context, snap) {
        if (snap.hasError) return const _Empty('Could not load.');
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snap.data!;
        if (list.isEmpty) return const _Empty('No reported food posts.');
        return ListView(
          padding: EdgeInsets.fromLTRB(pad, 12, pad, 36),
          children: [
            const Text(
              'Posts with $hideAtReports or more reports are already hidden '
              'from everyone. Delete anything that asks for money or looks '
              'unsafe.',
              style: TextStyle(fontSize: 13, height: 1.45),
            ),
            const SizedBox(height: 12),
            for (final p in list)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(p.title),
                  subtitle: Text(
                      '${p.area} · ${p.reportCount} report(s) · ${p.status}'
                      '${p.expired ? ' · expired' : ''}'),
                  trailing: IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => FoodBoardService.delete(p.id),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Mistakes users have pointed out (SDG 17). Fix the record in Edit
/// content, then mark it done here.
class _Corrections extends StatelessWidget {
  const _Corrections();

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;
    final col = FirebaseFirestore.instance.collection('corrections');
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: col.where('status', isEqualTo: 'new').limit(100).snapshots(),
      builder: (context, snap) {
        if (snap.hasError) return const _Empty('Could not load.');
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data!.docs;
        if (docs.isEmpty) return const _Empty('No corrections waiting.');
        return ListView(
          padding: EdgeInsets.fromLTRB(pad, 12, pad, 36),
          children: [
            for (final d in docs)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SDG ${d.data()['goal']}',
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      SelectableText('${d.data()['what'] ?? ''}'),
                      if ('${d.data()['source'] ?? ''}'.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        SelectableText('Source: ${d.data()['source']}',
                            style: const TextStyle(fontSize: 12.5)),
                      ],
                      const SizedBox(height: 10),
                      Wrap(spacing: 8, children: [
                        FilledButton(
                          onPressed: () =>
                              col.doc(d.id).update({'status': 'done'}),
                          child: const Text('Fixed'),
                        ),
                        OutlinedButton(
                          onPressed: () =>
                              col.doc(d.id).update({'status': 'rejected'}),
                          child: const Text('Not a mistake'),
                        ),
                      ]),
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
