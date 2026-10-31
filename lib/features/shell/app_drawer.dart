import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/admin/admin_config.dart';
import '../../core/admin/admin_service.dart';
import '../../core/i18n/strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/brand.dart';

/// The left drawer: who you are, and where you can go.
///
/// The Admin Panel row only appears for someone who actually has access -
/// and even then it is the Firestore rules, not this check, that decide
/// what they can do once inside.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final admin = context.watch<AdminService>();
    final user = auth.user;

    return Drawer(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              name: user?.displayName,
              email: user?.email,
              signedIn: auth.isSignedIn,
              role: admin.role,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _Item(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    onTap: () => _go(context, '/'),
                  ),
                  const _NotificationItem(),
                  _Item(
                    icon: Icons.settings_outlined,
                    label: context.tr('settings'),
                    onTap: () => _go(context, '/settings'),
                  ),
                  const Divider(height: 20),
                  _Item(
                    icon: Icons.description_outlined,
                    label: 'Terms & Conditions',
                    onTap: () => _go(context, '/terms'),
                  ),
                  _Item(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    onTap: () => _go(context, '/privacy'),
                  ),
                  _Item(
                    icon: Icons.info_outline,
                    label: 'About',
                    onTap: () => _go(context, '/about'),
                  ),
                  if (admin.role != AdminRole.none) ...[
                    const Divider(height: 20),
                    _Item(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Admin Panel',
                      trailing: admin.role == AdminRole.owner
                          ? const Icon(Icons.workspace_premium, size: 17)
                          : null,
                      onTap: () => _go(context, '/admin'),
                    ),
                  ],
                  const Divider(height: 20),
                  if (auth.isSignedIn)
                    _Item(
                      icon: Icons.logout,
                      label: context.tr('sign_out'),
                      onTap: () async {
                        // Both captured before the drawer closes.
                        final adminService = context.read<AdminService>();
                        final router = GoRouter.of(context);
                        Navigator.of(context).pop();
                        await auth.signOut();
                        await adminService.refresh();
                        router.go('/');
                      },
                    )
                  else
                    _Item(
                      icon: Icons.login,
                      label: context.tr('sign_in'),
                      onTap: () => _go(context, '/sign-in'),
                    ),
                ],
              ),
            ),
            const _Footer(),
          ],
        ),
      ),
    );
  }

  /// Close the drawer, then navigate.
  ///
  /// The router is captured BEFORE the pop. After `Navigator.pop()` this
  /// drawer is on its way out of the tree, and looking up an inherited
  /// widget from a context that is being disposed is how you get a
  /// "deactivated widget's ancestor" crash.
  void _go(BuildContext context, String route) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    if (route == '/') {
      router.go('/');
    } else {
      router.push(route);
    }
  }
}

class _Header extends StatelessWidget {
  final String? name;
  final String? email;
  final bool signedIn;
  final AdminRole role;

  const _Header({
    required this.name,
    required this.email,
    required this.signedIn,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final display = (name?.trim().isNotEmpty ?? false)
        ? name!.trim()
        : (email ?? 'Guest');

    return Container(
      width: double.infinity,
      color: scheme.primaryContainer,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: scheme.primary,
            child: Text(
              display.characters.first.toUpperCase(),
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            display,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: scheme.onPrimaryContainer,
            ),
          ),
          if (signedIn && email != null && name != null) ...[
            const SizedBox(height: 2),
            Text(
              email!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12.5,
                  color: scheme.onPrimaryContainer.withValues(alpha: 0.75)),
            ),
          ],
          if (role != AdminRole.none) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_user,
                      size: 13, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(
                    role.label,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule,
                  size: 15,
                  color:
                      scheme.onPrimaryContainer.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text(
                DateFormat('d MMM yyyy, h:mm a').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 12,
                  color:
                      scheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The notifications row carries the unread count, so the drawer is useful
/// at a glance without opening it fully.
class _NotificationItem extends StatelessWidget {
  const _NotificationItem();

  @override
  Widget build(BuildContext context) {
    final service = context.watch<NotificationService>();
    return StreamBuilder<List<AppNotification>>(
      stream: service.feed(),
      builder: (context, snap) {
        final unread = service.unreadCount(snap.data ?? const []);
        return _Item(
          icon: Icons.notifications_none,
          label: context.tr('notifications'),
          trailing: unread == 0
              ? null
              : Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Brand.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
          onTap: () {
            final router = GoRouter.of(context);
            Navigator.of(context).pop();
            router.push('/notifications');
          },
        );
      },
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _Item({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(label,
          style: const TextStyle(
              fontSize: 15.5, fontWeight: FontWeight.w500)),
      trailing: trailing,
      onTap: onTap,
      visualDensity: VisualDensity.comfortable,
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Designed and developed by',
              style: TextStyle(fontSize: 12, color: scheme.outline)),
          const SizedBox(height: 2),
          Text(
            Brand.companyName,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text('v${Brand.appVersion}',
              style: TextStyle(fontSize: 12, color: scheme.outline)),
        ],
      ),
    );
  }
}
