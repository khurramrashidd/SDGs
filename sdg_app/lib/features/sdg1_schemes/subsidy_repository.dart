import '../../core/content/content_store.dart';
import '../../core/content/dataset_registry.dart';
import 'subsidy_model.dart';

/// Schemes, read through [ContentStore].
///
/// The bundled JSON ships inside the APK, so the list works instantly,
/// offline, and costs zero Firestore reads - which matters on the Spark free
/// plan, where exhausting the daily read quota suspends the product for
/// everyone until the month ends.
///
/// Admin corrections from `/sdg/1/schemes` are merged field by field on top.
/// That is how a wrong government link gets fixed from a phone in a minute
/// instead of waiting for a new release.
class SubsidyRepository {
  static final _dataset =
      kDatasets.firstWhere((d) => d.collection == 'schemes');

  Future<List<Subsidy>> load({bool withRemote = true}) async {
    final rows = withRemote
        ? await ContentStore.instance.rows(_dataset)
        : await ContentStore.instance.bundledRows(_dataset);

    return rows.map(Subsidy.fromJson).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  List<String> categoriesOf(List<Subsidy> items) {
    final set = items.map((e) => e.category).toSet().toList()..sort();
    return set;
  }

  void invalidate() => ContentStore.instance.invalidate(_dataset);
}
