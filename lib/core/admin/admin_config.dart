/// Who controls this app.
///
/// There are two layers on purpose.
///
/// [rootOwnerEmail] is compiled into `firestore.rules` as well as here. It is
/// always a super admin, can never be demoted by anyone, and keeps working
/// even if the `users` collection is wiped. It is the recovery key.
///
/// The *active* owner is stored in Firestore at `/config/admin.ownerEmail`
/// and can be handed to someone else from the Admin screen. After a transfer
/// the new owner has full control - but [rootOwnerEmail] still works, so a
/// mistaken or malicious transfer can never lock you out of your own app.
///
/// Truly removing the root owner means editing `firestore.rules` and running
/// `firebase deploy --only firestore:rules`. That is deliberate: it is the one
/// action that should require more than a tap on a phone.
class AdminConfig {
  const AdminConfig._();

  /// Permanent recovery owner. Must match `rootOwner()` in firestore.rules.
  static const String rootOwnerEmail = 'free.timesenjoy@gmail.com';

  /// Firestore location of the transferable owner record.
  static const String configCollection = 'config';
  static const String adminDocId = 'admin';

  static bool isRootOwner(String? email) =>
      email != null &&
      email.trim().toLowerCase() == rootOwnerEmail.toLowerCase();
}

/// What someone is allowed to do. Ordered: a higher index implies everything
/// below it.
enum AdminRole {
  none('none', 'No admin access'),
  sdgAdmin('admin', 'SDG admin'),
  superAdmin('super_admin', 'Super admin'),
  owner('owner', 'Master admin');

  final String id;
  final String label;
  const AdminRole(this.id, this.label);

  static AdminRole fromId(String? id) => switch (id) {
        'owner' => AdminRole.owner,
        'super_admin' => AdminRole.superAdmin,
        'admin' => AdminRole.sdgAdmin,
        _ => AdminRole.none,
      };

  bool get canEditContent => index >= AdminRole.sdgAdmin.index;
  bool get canManageUsers => index >= AdminRole.superAdmin.index;
  bool get canManageKeys => index >= AdminRole.superAdmin.index;
  bool get canTransferOwnership => this == AdminRole.owner;
}
