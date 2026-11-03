import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Both halves of the agreed notification design:
///  - in-app feed: every notice lands in Firestore and shows in the bell
///  - push: the admin ticks "also push", the Render proxy sends it via FCM
///
/// No Cloud Functions involved - sending happens on the proxy, which holds
/// the service account.
class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime? createdAt;
  final int? sdgGoal;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.createdAt,
    this.sdgGoal,
  });

  factory AppNotification.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AppNotification(
      id: doc.id,
      title: (d['title'] ?? '').toString(),
      body: (d['body'] ?? '').toString(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      sdgGoal: d['sdgGoal'] is int ? d['sdgGoal'] as int : null,
    );
  }
}

class NotificationService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Set<String> _readIds = {};

  Stream<List<AppNotification>> feed() => _db
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map(AppNotification.fromDoc).toList());

  bool isRead(String id) => _readIds.contains(id);

  void markRead(String id) {
    _readIds.add(id);
    notifyListeners();
  }

  void markAllRead(Iterable<String> ids) {
    _readIds.addAll(ids);
    notifyListeners();
  }

  int unreadCount(List<AppNotification> items) =>
      items.where((n) => !_readIds.contains(n.id)).length;

  /// Registers the device so the proxy can push to it. Safe to call on every
  /// launch; failures are non-fatal because push is a bonus, not a feature
  /// the app depends on.
  Future<void> registerDevice({String? uid}) async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      final token = await messaging.getToken();
      if (token == null) return;
      await _db.collection('deviceTokens').doc(token).set({
        'token': token,
        'uid': uid,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Push registration skipped: $e');
    }
  }
}
