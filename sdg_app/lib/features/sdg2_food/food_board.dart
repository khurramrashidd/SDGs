import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'share_check.dart';

/// The food donate-and-claim board.
///
/// This is the core of the old food-sharing app, rebuilt with the safety
/// decisions you chose (2 Nov 2026):
///
///  * A post can only be made from a "Can this be shared?" result of yes or
///    soon. There is no other way into the posting form.
///  * The listing lasts only as long as the food stays safe - computed here
///    from the same answers - and the Firestore rules cap it again.
///  * Signing in is needed to post or claim, not to look.
///  * The public post holds no phone number and no address, only a
///    locality. The phone and pickup details sit in a separate document
///    that only the poster and the one person who claimed can read.
///  * Anyone signed in can report a post; three reports hide it, and an
///    admin can delete it.
///
/// Firestore layout:
///   foodBoard/{postId}                    public
///   foodBoard/{postId}/private/contact    poster + claimer only
///   foodBoard/{postId}/reports/{uid}      write-once per user, admin reads

const boardCollection = 'foodBoard';

/// Hide a post from the list once this many different people report it.
const hideAtReports = 3;

/// How long a post may stay listed, in hours, or null if the food should
/// not be listed at all.
///
/// The share check answers "is it safe now?". A listing needs a second
/// answer: "until when?", because whoever claims it will eat it later.
///
///  * Sealed packets and raw produce: a day. Their limit is a printed date
///    or how they look, which the claimer can check themselves.
///  * Cooked food kept hot or cold: three hours at most. Once it leaves the
///    pot or the fridge for a handover it is room-temperature food.
///  * Cooked food at room temperature: whatever is left of the safe window.
///
/// Less than 20 minutes left is too little for a stranger to see the post,
/// travel and collect, so the answer is null and the screen says to call a
/// neighbour or a collection partner instead.
double? listingHours({
  required FoodKind kind,
  required HeldAt heldAt,
  required double hoursOld,
  required bool hotWeather,
  required ShareVerdict verdict,
}) {
  if (verdict == ShareVerdict.no) return null;
  double hours;
  if (kind == FoodKind.packagedSealed || kind == FoodKind.rawProduce) {
    hours = 24;
  } else if (heldAt == HeldAt.hotHeld || heldAt == HeldAt.refrigerated) {
    final limit = kind == FoodKind.cookedHighRisk ? 12.0 : 24.0;
    hours = (limit - hoursOld).clamp(0.0, 3.0);
  } else {
    final window = hotWeather ? 1.0 : 2.0;
    hours = (window - hoursOld).clamp(0.0, 3.0);
  }
  return hours < 1 / 3 ? null : hours;
}

bool isCooked(FoodKind k) =>
    k == FoodKind.cookedHighRisk || k == FoodKind.cookedLowRisk;

class FoodPost {
  final String id;
  final String uid;
  final String title;
  final FoodKind kind;
  final int servings;
  final String area;
  final ShareVerdict verdict;
  final DateTime expiresAt;
  final String status; // open | claimed | closed
  final String? claimedBy;
  final int reportCount;

  const FoodPost({
    required this.id,
    required this.uid,
    required this.title,
    required this.kind,
    required this.servings,
    required this.area,
    required this.verdict,
    required this.expiresAt,
    required this.status,
    required this.claimedBy,
    required this.reportCount,
  });

  bool get expired => DateTime.now().isAfter(expiresAt);
  bool get hidden => reportCount >= hideAtReports;

  static FoodPost? fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    if (m == null) return null;
    final exp = m['expiresAt'];
    final kindName = m['kind'];
    if (exp is! Timestamp || kindName is! String) return null;
    final kind = FoodKind.values.where((k) => k.name == kindName);
    if (kind.isEmpty) return null;
    return FoodPost(
      id: d.id,
      uid: '${m['uid'] ?? ''}',
      title: '${m['title'] ?? ''}',
      kind: kind.first,
      servings: (m['servings'] is int) ? m['servings'] as int : 0,
      area: '${m['area'] ?? ''}',
      verdict:
          m['verdict'] == 'soon' ? ShareVerdict.soon : ShareVerdict.yes,
      expiresAt: exp.toDate(),
      status: '${m['status'] ?? 'open'}',
      claimedBy: m['claimedBy'] is String ? m['claimedBy'] as String : null,
      reportCount: (m['reportCount'] is int) ? m['reportCount'] as int : 0,
    );
  }
}

class FoodContact {
  final String phone;
  final String pickup;
  const FoodContact(this.phone, this.pickup);
}

class FoodBoardService {
  static final _db = FirebaseFirestore.instance;
  static CollectionReference<Map<String, dynamic>> get _posts =>
      _db.collection(boardCollection);

  static String? get myUid => FirebaseAuth.instance.currentUser?.uid;

  /// Live, unexpired posts, soonest-to-expire first. Filtering on one field
  /// only, so no composite index is needed.
  static Stream<List<FoodPost>> live() => _posts
      .where('expiresAt', isGreaterThan: Timestamp.now())
      .orderBy('expiresAt')
      .limit(100)
      .snapshots()
      .map((s) => s.docs
          .map(FoodPost.fromDoc)
          .whereType<FoodPost>()
          .where((p) => !p.hidden && p.status != 'closed')
          .toList());

  /// Posts I made, including expired ones, so I can close or delete them.
  static Stream<List<FoodPost>> mine() {
    final uid = myUid;
    if (uid == null) return Stream.value(const []);
    return _posts.where('uid', isEqualTo: uid).limit(50).snapshots().map(
        (s) => s.docs.map(FoodPost.fromDoc).whereType<FoodPost>().toList()
          ..sort((a, b) => b.expiresAt.compareTo(a.expiresAt)));
  }

  /// Creates the public post and its private contact in one batch, so there
  /// is never a post without contact details or the other way round.
  static Future<void> create({
    required String title,
    required FoodKind kind,
    required int servings,
    required String area,
    required ShareVerdict verdict,
    required double hours,
    required String phone,
    required String pickup,
  }) async {
    final uid = myUid;
    if (uid == null) throw StateError('not signed in');
    final ref = _posts.doc();
    final expires = DateTime.now()
        .add(Duration(minutes: (hours * 60).floor() - 1));
    final batch = _db.batch()
      ..set(ref, {
        'uid': uid,
        'title': title,
        'kind': kind.name,
        'servings': servings,
        'area': area,
        'verdict': verdict == ShareVerdict.soon ? 'soon' : 'yes',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expires),
        'status': 'open',
        'reportCount': 0,
      })
      ..set(ref.collection('private').doc('contact'), {
        'uid': uid,
        'phone': phone,
        'pickup': pickup,
      });
    await batch.commit();
  }

  /// Claims an open post. A transaction, so two people tapping at once
  /// cannot both get it.
  static Future<bool> claim(String postId) async {
    final uid = myUid;
    if (uid == null) return false;
    final ref = _posts.doc(postId);
    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final m = snap.data();
      if (m == null || m['status'] != 'open' || m['uid'] == uid) return false;
      tx.update(ref, {
        'status': 'claimed',
        'claimedBy': uid,
        'claimedAt': FieldValue.serverTimestamp(),
      });
      return true;
    });
  }

  /// Poster puts a claimed post back up, for a claimer who never came.
  static Future<void> release(String postId) => _posts.doc(postId).update({
        'status': 'open',
        'claimedBy': FieldValue.delete(),
        'claimedAt': FieldValue.delete(),
      });

  static Future<void> close(String postId) =>
      _posts.doc(postId).update({'status': 'closed'});

  /// Deletes the private contact first, then the post: the rules decide who
  /// may read the contact by looking at the post, so the post must outlive
  /// it.
  static Future<void> delete(String postId) async {
    final ref = _posts.doc(postId);
    await ref.collection('private').doc('contact').delete();
    await ref.delete();
  }

  static Future<FoodContact?> contact(String postId) async {
    final d = await _posts
        .doc(postId)
        .collection('private')
        .doc('contact')
        .get();
    final m = d.data();
    if (m == null) return null;
    return FoodContact('${m['phone'] ?? ''}', '${m['pickup'] ?? ''}');
  }

  /// One report per person per post. The report and the counter go in one
  /// batch; the rules accept the +1 only when this person's report document
  /// is being created in the same write.
  static Future<void> report(FoodPost p, String reason) async {
    final uid = myUid;
    if (uid == null) throw StateError('not signed in');
    final ref = _posts.doc(p.id);
    final batch = _db.batch()
      ..set(ref.collection('reports').doc(uid), {
        'uid': uid,
        'reason': reason,
        'at': FieldValue.serverTimestamp(),
      })
      ..update(ref, {'reportCount': FieldValue.increment(1)});
    await batch.commit();
  }

  /// Admin view: anything reported at least once, worst first.
  static Stream<List<FoodPost>> reported() => _posts
      .where('reportCount', isGreaterThan: 0)
      .orderBy('reportCount', descending: true)
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map(FoodPost.fromDoc).whereType<FoodPost>().toList());
}

const reportReasons = [
  ('unsafe', 'Food looks or sounds unsafe', 'खाना असुरक्षित लगता है'),
  ('money', 'Asked for money', 'पैसे माँगे'),
  ('fake', 'Not real, or spam', 'झूठा या स्पैम'),
  ('behaviour', 'Rude or threatening', 'बदतमीज़ी या धमकी'),
];
