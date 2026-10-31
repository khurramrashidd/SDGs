import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'admin_config.dart';

class AdminUser {
  final String uid;
  final String email;
  final String displayName;
  final AdminRole role;
  final List<int> sdgAccess;

  const AdminUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.sdgAccess,
  });

  factory AdminUser.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> d, String? activeOwnerEmail) {
    final m = d.data() ?? {};
    final email = (m['email'] ?? '').toString();
    var role = AdminRole.fromId(m['role']?.toString());

    // Owner status comes from the email, not from a stored role, so it
    // cannot be removed by editing a document.
    final isOwner = AdminConfig.isRootOwner(email) ||
        (activeOwnerEmail != null &&
            email.toLowerCase() == activeOwnerEmail.toLowerCase());
    if (isOwner) role = AdminRole.owner;

    return AdminUser(
      uid: d.id,
      email: email,
      displayName: (m['displayName'] ?? '').toString(),
      role: role,
      sdgAccess: (m['sdgAccess'] as List<dynamic>? ?? [])
          .map((e) => e is int ? e : int.tryParse('$e') ?? 0)
          .where((e) => e > 0)
          .toList(),
    );
  }

  bool get isRootOwner => AdminConfig.isRootOwner(email);
}

class AdminService extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  String? _activeOwnerEmail;
  AdminRole _role = AdminRole.none;
  List<int> _sdgAccess = const [];
  bool _loaded = false;

  AdminRole get role => _role;
  List<int> get sdgAccess => _sdgAccess;
  bool get loaded => _loaded;
  String? get activeOwnerEmail => _activeOwnerEmail;

  DocumentReference<Map<String, dynamic>> get _configRef => _db
      .collection(AdminConfig.configCollection)
      .doc(AdminConfig.adminDocId);

  /// Works out what the signed-in user may do. Called on app start and after
  /// sign-in. The rules enforce all of this again server-side; this is only
  /// so the UI knows what to show.
  Future<void> refresh() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _role = AdminRole.none;
      _sdgAccess = const [];
      _loaded = true;
      notifyListeners();
      return;
    }

    try {
      final cfg = await _configRef.get();
      _activeOwnerEmail = cfg.data()?['ownerEmail']?.toString();
    } catch (e) {
      debugPrint('admin config unreadable: $e');
      _activeOwnerEmail = null;
    }

    final email = user.email;
    if (AdminConfig.isRootOwner(email) ||
        (_activeOwnerEmail != null &&
            email != null &&
            email.toLowerCase() == _activeOwnerEmail!.toLowerCase())) {
      _role = AdminRole.owner;
      _sdgAccess = const [];
      _loaded = true;
      notifyListeners();
      return;
    }

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      final m = doc.data() ?? {};
      _role = AdminRole.fromId(m['role']?.toString());
      _sdgAccess = (m['sdgAccess'] as List<dynamic>? ?? [])
          .map((e) => e is int ? e : int.tryParse('$e') ?? 0)
          .where((e) => e > 0)
          .toList();
    } catch (e) {
      debugPrint('role lookup failed: $e');
      _role = AdminRole.none;
    }
    _loaded = true;
    notifyListeners();
  }

  bool canEditSdg(int goal) {
    if (_role.index >= AdminRole.superAdmin.index) return true;
    return _role == AdminRole.sdgAdmin && _sdgAccess.contains(goal);
  }

  Stream<List<AdminUser>> watchUsers() => _db
      .collection('users')
      .orderBy('email')
      .limit(200)
      .snapshots()
      .map((s) => s.docs
          .map((d) => AdminUser.fromDoc(d, _activeOwnerEmail))
          .toList());

  Future<void> setRole(AdminUser user, AdminRole role,
      {List<int>? sdgAccess}) async {
    if (user.isRootOwner) {
      throw StateError('The master admin account cannot be changed.');
    }
    await _db.collection('users').doc(user.uid).set({
      'role': role == AdminRole.none ? FieldValue.delete() : role.id,
      if (sdgAccess != null) 'sdgAccess': sdgAccess,
      'roleUpdatedAt': FieldValue.serverTimestamp(),
      'roleUpdatedBy': FirebaseAuth.instance.currentUser?.email,
    }, SetOptions(merge: true));
  }

  /// Hands the active owner role to another email.
  ///
  /// The root owner in [AdminConfig] keeps working afterwards - see the note
  /// there. Without that, a typo here would lock everyone out permanently.
  Future<void> transferOwnership(String newOwnerEmail) async {
    final email = newOwnerEmail.trim().toLowerCase();
    if (email.isEmpty || !email.contains('@')) {
      throw ArgumentError('That does not look like an email address.');
    }
    await _configRef.set({
      'ownerEmail': email,
      'transferredAt': FieldValue.serverTimestamp(),
      'transferredBy': FirebaseAuth.instance.currentUser?.email,
    }, SetOptions(merge: true));
    _activeOwnerEmail = email;
    notifyListeners();
  }
}
