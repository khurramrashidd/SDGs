import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../sdg4_scholarships/scholarship_model.dart';
import '../sdg4_scholarships/scholarship_repository.dart';
import '../../core/layout/responsive.dart';

/// Where scholarship closing dates are entered.
///
/// This screen is the module's weak point by design: a scholarship without a
/// deadline here shows the student "check the portal", which is honest but
/// not useful. Keeping these current is the ongoing admin job that makes
/// SDG 4 worth having.
class DeadlinesPage extends StatefulWidget {
  const DeadlinesPage({super.key});

  @override
  State<DeadlinesPage> createState() => _DeadlinesPageState();
}

class _DeadlinesPageState extends State<DeadlinesPage> {
  final _repo = ScholarshipRepository();
  late Future<List<Scholarship>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.load();
  }

  Future<void> _setDeadline(Scholarship s) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: s.deadline ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      helpText: 'Closing date for ${s.name}',
    );
    if (picked == null) return;

    await FirebaseFirestore.instance
        .collection('sdg')
        .doc('4')
        .collection('deadlines')
        .doc('${s.id}')
        .set({
      'scholarshipId': s.id,
      'name': s.name,
      'closesOn': Timestamp.fromDate(picked),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!mounted) return;
    setState(() {
      _repo.invalidate();
      _future = _repo.load();
    });
  }

  Future<void> _clearDeadline(Scholarship s) async {
    await FirebaseFirestore.instance
        .collection('sdg')
        .doc('4')
        .collection('deadlines')
        .doc('${s.id}')
        .delete();
    if (!mounted) return;
    setState(() {
      _repo.invalidate();
      _future = _repo.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scholarship deadlines')),
      body: ContentShell(
        maxWidth: 760,
        child: FutureBuilder<List<Scholarship>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snap.data ?? const <Scholarship>[];
            final missing =
                items.where((s) => s.deadline == null).length;

            return ListView(
              padding: EdgeInsets.fromLTRB(context.pagePadding, 16, context.pagePadding, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: missing > 0
                        ? Theme.of(context).colorScheme.tertiaryContainer
                        : Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    missing == 0
                        ? 'All ${items.length} scholarships have a closing date.'
                        : '$missing of ${items.length} scholarships have no '
                            'closing date yet. Students see "check the portal" '
                            'for those.',
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
                const SizedBox(height: 16),
                ...items.map((s) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(s.name,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          s.deadline == null
                              ? 'No date set'
                              : 'Closes ${DateFormat('d MMM yyyy').format(s.deadline!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: s.deadline == null
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (s.deadline != null)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                tooltip: 'Remove date',
                                onPressed: () => _clearDeadline(s),
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit_calendar),
                              tooltip: 'Set date',
                              onPressed: () => _setDeadline(s),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            );
          },
        ),
      ),
    );
  }
}
