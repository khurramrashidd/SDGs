import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../core/content/content_store.dart';
import '../../core/content/dataset_registry.dart';
import 'scholarship_model.dart';

/// Scholarship details come from [ContentStore] - bundled asset plus any
/// admin corrections.
///
/// Deadlines are kept in a separate collection on purpose. They change every
/// year while the rest of a scholarship record rarely does, and a stale date
/// is the exact failure this module exists to prevent, so they are never
/// bundled and never guessed.
class ScholarshipRepository {
  static final _dataset =
      kDatasets.firstWhere((d) => d.collection == 'scholarships');

  List<Scholarship>? _cache;

  Future<List<Scholarship>> load() async {
    if (_cache != null) return _cache!;

    final rows = await ContentStore.instance.rows(_dataset);
    final list = rows.map(Scholarship.fromJson).toList();

    final deadlines = await _loadDeadlines();
    final merged = list
        .map((s) => deadlines.containsKey(s.id)
            ? s.copyWithDeadline(deadlines[s.id])
            : s)
        .toList()
      ..sort(_byUrgencyThenName);

    _cache = merged;
    return merged;
  }

  /// Admin-entered deadlines, keyed by scholarship id.
  Future<Map<int, DateTime?>> _loadDeadlines() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('sdg')
          .doc('4')
          .collection('deadlines')
          .get();

      final out = <int, DateTime?>{};
      for (final d in snap.docs) {
        final id = int.tryParse(d.id);
        if (id == null) continue;
        final ts = d.data()['closesOn'];
        if (ts is Timestamp) out[id] = ts.toDate();
      }
      return out;
    } catch (e) {
      // Offline, or rules not deployed yet. Falls back to "no deadline
      // known", which the UI renders as "check the portal" - never a guess.
      debugPrint('deadlines unavailable: $e');
      return {};
    }
  }

  /// Closing soonest first, then anything without a known deadline, then
  /// already-closed ones at the bottom.
  static int _byUrgencyThenName(Scholarship a, Scholarship b) {
    final ad = a.daysLeft;
    final bd = b.daysLeft;

    int rank(int? d) {
      if (d == null) return 1; // unknown deadline
      if (d < 0) return 2; // closed
      return 0; // open
    }

    final ra = rank(ad);
    final rb = rank(bd);
    if (ra != rb) return ra.compareTo(rb);
    if (ra == 0) return ad!.compareTo(bd!);
    return a.name.compareTo(b.name);
  }

  void invalidate() {
    _cache = null;
    ContentStore.instance.invalidate(_dataset);
  }
}
