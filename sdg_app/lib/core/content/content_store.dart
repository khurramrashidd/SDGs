import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dataset_registry.dart';

/// Bundled asset, with admin corrections merged on top.
///
/// Every module reads its data through here, which means a wrong link or a
/// wrong helpline number can be fixed from the admin screen and takes effect
/// on every device, without shipping a new APK.
///
/// The bundled copy is what makes the app work offline and costs zero
/// Firestore reads. The override layer is small - usually a handful of
/// corrected fields - so merging stays cheap.
class ContentStore {
  ContentStore._();
  static final ContentStore instance = ContentStore._();

  final Map<String, List<Map<String, dynamic>>> _merged = {};
  final Map<String, Future<List<Map<String, dynamic>>>> _inFlight = {};

  /// Merged rows for a dataset. Cached for the app's lifetime; call
  /// [invalidate] after an admin edit.
  Future<List<Map<String, dynamic>>> rows(ContentDataset ds) {
    final cached = _merged[ds.id];
    if (cached != null) return Future.value(cached);
    return _inFlight[ds.id] ??= _load(ds);
  }

  Future<List<Map<String, dynamic>>> _load(ContentDataset ds) async {
    final bundled = await bundledRows(ds);

    Map<int, Map<String, dynamic>> overrides = {};
    try {
      final snap = await FirebaseFirestore.instance
          .collection('sdg')
          .doc('${ds.goal}')
          .collection(ds.collection)
          .get();
      for (final d in snap.docs) {
        final id = int.tryParse(d.id);
        if (id != null) overrides[id] = Map<String, dynamic>.from(d.data());
      }
    } catch (e) {
      // Offline, or rules not deployed yet. Bundled data still works, which
      // is the point of shipping it.
      debugPrint('overrides unavailable for ${ds.id}: $e');
    }

    final out = bundled.map((row) {
      final id = row['id'];
      final patch = overrides[id is int ? id : -1];
      if (patch == null) return row;
      // Field-level merge, so an override that only fixes a link does not
      // wipe the rest of the record.
      return {...row, ...patch}..['id'] = id;
    }).toList();

    // Rows added by an admin that are not in the bundle at all.
    final bundledIds = bundled.map((r) => r['id']).toSet();
    for (final entry in overrides.entries) {
      if (!bundledIds.contains(entry.key)) {
        out.add({...entry.value, 'id': entry.key});
      }
    }

    _merged[ds.id] = out;
    _inFlight.remove(ds.id);
    return out;
  }

  Future<List<Map<String, dynamic>>> bundledRows(ContentDataset ds) async {
    final raw = await rootBundle.loadString(ds.assetPath);
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// Writes an admin correction. Only the fields that actually differ from
  /// the bundled record are stored, so the override document stays a patch
  /// rather than a full copy that would drift out of sync.
  Future<void> saveOverride(
    ContentDataset ds,
    int recordId,
    Map<String, dynamic> edited,
    Map<String, dynamic> original,
    String? editorEmail,
  ) async {
    final patch = <String, dynamic>{};
    for (final entry in edited.entries) {
      if (original[entry.key] != entry.value) patch[entry.key] = entry.value;
    }
    if (patch.isEmpty) return;

    patch['id'] = recordId;
    patch['updatedAt'] = FieldValue.serverTimestamp();
    patch['updatedBy'] = editorEmail;

    await FirebaseFirestore.instance
        .collection('sdg')
        .doc('${ds.goal}')
        .collection(ds.collection)
        .doc('$recordId')
        .set(patch, SetOptions(merge: true));

    invalidate(ds);
  }

  /// Drops an admin correction, returning the record to its bundled values.
  Future<void> clearOverride(ContentDataset ds, int recordId) async {
    await FirebaseFirestore.instance
        .collection('sdg')
        .doc('${ds.goal}')
        .collection(ds.collection)
        .doc('$recordId')
        .delete();
    invalidate(ds);
  }

  void invalidate(ContentDataset ds) {
    _merged.remove(ds.id);
    _inFlight.remove(ds.id);
  }

  void invalidateAll() {
    _merged.clear();
    _inFlight.clear();
  }
}
