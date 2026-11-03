import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Result of an auth attempt. `mergeRequired` is the case Laiq asked about:
/// the same Gmail already exists as an email/password account.
class AuthResult {
  final bool ok;
  final String? errorCode;
  final String? message;
  final bool mergeRequired;
  final String? mergeEmail;

  const AuthResult.success()
      : ok = true,
        errorCode = null,
        message = null,
        mergeRequired = false,
        mergeEmail = null;

  const AuthResult.failure(this.errorCode, this.message)
      : ok = false,
        mergeRequired = false,
        mergeEmail = null;

  const AuthResult.needsMerge(this.mergeEmail)
      : ok = false,
        errorCode = 'merge-required',
        message = null,
        mergeRequired = true;
}

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _google = GoogleSignIn(scopes: ['email']);

  /// Held between a failed Google sign-in and the password the user types to
  /// prove they own the existing email account, so the two can be linked.
  AuthCredential? _pendingCredential;

  User? get user => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;
  Stream<User?> get authState => _auth.authStateChanges();

  AuthService() {
    _auth.authStateChanges().listen((_) => notifyListeners());
  }

  // ---------------------------------------------------------------- email

  Future<AuthResult> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(name.trim());
      await _writeProfile(cred.user, name: name.trim());
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(e.code, _friendly(e.code));
    }
  }

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // If a Google sign-in was interrupted by an existing email account,
      // link it now that the password proved ownership.
      if (_pendingCredential != null) {
        await cred.user?.linkWithCredential(_pendingCredential!);
        _pendingCredential = null;
      }
      await _writeProfile(cred.user);
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(e.code, _friendly(e.code));
    }
  }

  Future<AuthResult> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(e.code, _friendly(e.code));
    }
  }

  // --------------------------------------------------------------- google

  Future<AuthResult> signInWithGoogle() async {
    try {
      final account = await _google.signIn();
      if (account == null) {
        return const AuthResult.failure('cancelled', null);
      }
      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);
      await _writeProfile(cred.user, name: account.displayName);
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      // The merge case: this Gmail already exists as an email/password login.
      if (e.code == 'account-exists-with-different-credential') {
        _pendingCredential = e.credential;
        return AuthResult.needsMerge(e.email);
      }
      return AuthResult.failure(e.code, _friendly(e.code));
    } catch (_) {
      return const AuthResult.failure('unknown', null);
    }
  }

  /// Adds a password to an account that currently only has Google, so the user
  /// can sign in either way afterwards.
  Future<AuthResult> addPasswordToCurrentAccount(String password) async {
    final u = _auth.currentUser;
    if (u?.email == null) {
      return const AuthResult.failure('no-user', null);
    }
    try {
      await u!.linkWithCredential(
        EmailAuthProvider.credential(email: u.email!, password: password),
      );
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(e.code, _friendly(e.code));
    }
  }

  Future<void> signOut() async {
    _pendingCredential = null;
    await _google.signOut();
    await _auth.signOut();
  }

  // -------------------------------------------------------------- profile

  Future<void> _writeProfile(User? u, {String? name}) async {
    if (u == null) return;
    await _db.collection('users').doc(u.uid).set({
      'uid': u.uid,
      'email': u.email,
      'displayName': name ?? u.displayName,
      'providers': u.providerData.map((p) => p.providerId).toList(),
      'lastSeenAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Admin status is read from the user document, never from the client.
  /// The Firestore rules make `role` writable only by an existing admin.
  Future<Map<String, dynamic>?> loadProfile() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    final snap = await _db.collection('users').doc(u.uid).get();
    return snap.data();
  }

  String _friendly(String code) => switch (code) {
        'invalid-email' => 'That email address does not look right.',
        'user-disabled' => 'This account has been disabled.',
        'user-not-found' => 'No account found with that email.',
        'wrong-password' || 'invalid-credential' =>
          'Email or password is incorrect.',
        'email-already-in-use' =>
          'An account already exists with this email. Try signing in.',
        'weak-password' => 'Use at least 6 characters for the password.',
        'network-request-failed' =>
          'No internet connection. Check your network.',
        'too-many-requests' =>
          'Too many attempts. Please wait a moment and try again.',
        _ => 'Something went wrong. Please try again.',
      };
}
