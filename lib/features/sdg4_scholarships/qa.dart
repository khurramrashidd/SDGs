import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Study questions and answers, moderated, with no private messages.
///
/// LearningVersity let students and teachers talk directly. Many people
/// using this will be children, and a stranger-to-child channel is the one
/// thing an education app must not open. So, as decided on 2 Nov 2026:
///
///  * Nothing is public until an admin approves it - questions and answers.
///  * There are no names, photos or profiles on any post, and no way to
///    message a person. Everyone is "a student" or "a helper".
///  * Phone numbers, links, emails and @handles are refused, here and again
///    in the Firestore rules, so nobody can be led off the app.
///  * Anyone signed in can report an approved post; reports go to admins.
///
/// Collections: qa/{qid}, qaAnswers/{aid}, qaReports/{uid_itemId}.

const qaSubjects = [
  ('maths', 'Maths', 'गणित'),
  ('science', 'Science', 'विज्ञान'),
  ('english', 'English', 'अंग्रेज़ी'),
  ('hindi', 'Hindi', 'हिंदी'),
  ('social', 'Social studies', 'सामाजिक विज्ञान'),
  ('computer', 'Computers', 'कंप्यूटर'),
  ('other', 'Other', 'अन्य'),
];

const qaLevels = [
  ('primary', 'Class 1-5', 'कक्षा 1-5'),
  ('middle', 'Class 6-8', 'कक्षा 6-8'),
  ('secondary', 'Class 9-12', 'कक्षा 9-12'),
  ('college', 'College', 'कॉलेज'),
];

/// Anything that could carry someone off the app: a link, an email or
/// @handle, or a run of 8+ digits (a phone number, with or without spaces
/// and dashes). Must match the pattern in firestore.rules.
final contactPattern =
    RegExp(r'(https?://|www\.|@|[0-9][0-9 \-]{6,}[0-9])', caseSensitive: false);

bool carriesContact(String text) => contactPattern.hasMatch(text);

class QaItem {
  final String id;
  final String uid;
  final String text;
  final String status; // pending | approved | rejected
  final String subject; // questions only
  final String level; // questions only
  final String qid; // answers only
  final DateTime? at;

  const QaItem({
    required this.id,
    required this.uid,
    required this.text,
    required this.status,
    this.subject = '',
    this.level = '',
    this.qid = '',
    this.at,
  });

  static QaItem fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? const {};
    final ts = m['approvedAt'] ?? m['createdAt'];
    return QaItem(
      id: d.id,
      uid: '${m['uid'] ?? ''}',
      text: '${m['text'] ?? ''}',
      status: '${m['status'] ?? 'pending'}',
      subject: '${m['subject'] ?? ''}',
      level: '${m['level'] ?? ''}',
      qid: '${m['qid'] ?? ''}',
      at: ts is Timestamp ? ts.toDate() : null,
    );
  }
}

class QaService {
  static final _db = FirebaseFirestore.instance;
  static CollectionReference<Map<String, dynamic>> get _q =>
      _db.collection('qa');
  static CollectionReference<Map<String, dynamic>> get _a =>
      _db.collection('qaAnswers');

  static String? get myUid => FirebaseAuth.instance.currentUser?.uid;

  static Stream<List<QaItem>> approvedQuestions() => _q
      .where('status', isEqualTo: 'approved')
      .orderBy('approvedAt', descending: true)
      .limit(200)
      .snapshots()
      .map((s) => s.docs.map(QaItem.fromDoc).toList());

  static Stream<List<QaItem>> myQuestions() {
    final uid = myUid;
    if (uid == null) return Stream.value(const []);
    return _q.where('uid', isEqualTo: uid).limit(50).snapshots().map((s) =>
        s.docs.map(QaItem.fromDoc).toList()
          ..sort((a, b) => (b.at ?? DateTime(2000))
              .compareTo(a.at ?? DateTime(2000))));
  }

  static Stream<List<QaItem>> approvedAnswers(String qid) => _a
      .where('qid', isEqualTo: qid)
      .where('status', isEqualTo: 'approved')
      .orderBy('approvedAt')
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map(QaItem.fromDoc).toList());

  static Future<void> ask(String text, String subject, String level) =>
      _q.add({
        'uid': myUid,
        'text': text,
        'subject': subject,
        'level': level,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

  static Future<void> answer(String qid, String text) => _a.add({
        'uid': myUid,
        'qid': qid,
        'text': text,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

  /// One report per person per item: the document id is the reporter's uid
  /// and the item's id, so a second report is a rejected overwrite.
  static Future<void> report(QaItem item, bool isAnswer, String reason) =>
      _db.collection('qaReports').doc('${myUid}_${item.id}').set({
        'uid': myUid,
        'itemId': item.id,
        'kind': isAnswer ? 'answer' : 'question',
        'reason': reason,
        'at': FieldValue.serverTimestamp(),
      });

  // ---- moderation (admins with SDG 4 access; enforced by the rules) ----

  static Stream<List<QaItem>> pendingQuestions() => _q
      .where('status', isEqualTo: 'pending')
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map(QaItem.fromDoc).toList());

  static Stream<List<QaItem>> pendingAnswers() => _a
      .where('status', isEqualTo: 'pending')
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map(QaItem.fromDoc).toList());

  static Future<void> review(QaItem item, bool isAnswer, bool approve) =>
      (isAnswer ? _a : _q).doc(item.id).update({
        'status': approve ? 'approved' : 'rejected',
        if (approve) 'approvedAt': FieldValue.serverTimestamp(),
        'reviewedBy': FirebaseAuth.instance.currentUser?.email ?? '',
      });

  static Future<String> questionText(String qid) async {
    final d = await _q.doc(qid).get();
    return '${d.data()?['text'] ?? ''}';
  }

  static Stream<List<Map<String, dynamic>>> reports() => _db
      .collection('qaReports')
      .limit(100)
      .snapshots()
      .map((s) => [for (final d in s.docs) {'id': d.id, ...d.data()}]);

  static Future<QaItem?> item(String id, bool isAnswer) async {
    final d = await (isAnswer ? _a : _q).doc(id).get();
    return d.exists ? QaItem.fromDoc(d) : null;
  }

  static Future<void> dismissReport(String reportId) =>
      _db.collection('qaReports').doc(reportId).delete();
}

const qaReportReasons = [
  ('contact', 'Asks for contact or to meet', 'संपर्क या मिलने को कहता है'),
  ('unkind', 'Rude, bullying or unkind', 'बदतमीज़ी या धमकाना'),
  ('wrong', 'Wrong answer', 'ग़लत जवाब'),
  ('other', 'Something else', 'कुछ और'),
];
