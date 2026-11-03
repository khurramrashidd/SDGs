import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/layout/responsive.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('account'))),
        body: Center(
          child: FilledButton(
            onPressed: () => context.go('/sign-in'),
            child: Text(context.tr('sign_in')),
          ),
        ),
      );
    }

    final providers =
        user.providerData.map((p) => p.providerId).toList();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('account'))),
      body: ContentShell(
        maxWidth: 620,
        child: FutureBuilder<Map<String, dynamic>?>(
        future: auth.loadProfile(),
        builder: (context, snap) {
          final isAdmin = snap.data?['role'] == 'admin' ||
              snap.data?['role'] == 'super_admin';

          return ListView(
            padding: EdgeInsets.fromLTRB(context.pagePadding, 20, context.pagePadding, 32),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: Text(
                      (user.displayName ?? user.email ?? '?')
                          .characters
                          .first
                          .toUpperCase(),
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? 'User',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          user.email ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Sign-in methods',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (providers.contains('password'))
                    const Chip(
                        avatar: Icon(Icons.lock_outline, size: 16),
                        label: Text('Email')),
                  if (providers.contains('google.com'))
                    const Chip(
                        avatar: Icon(Icons.g_mobiledata, size: 20),
                        label: Text('Google')),
                ],
              ),
              if (!providers.contains('password')) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _addPassword(context, auth),
                  icon: const Icon(Icons.add_moderator_outlined),
                  label: const Text('Add a password to this account'),
                ),
              ],
              const SizedBox(height: 28),
              if (isAdmin)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.admin_panel_settings_outlined),
                    title: Text(context.tr('admin')),
                    subtitle: const Text('Manage content, keys and notices'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/admin'),
                  ),
                ),
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: () async {
                  await auth.signOut();
                  if (context.mounted) context.go('/');
                },
                icon: const Icon(Icons.logout),
                label: Text(context.tr('sign_out')),
              ),
            ],
          );
        },
      ),
      ),
    );
  }

  Future<void> _addPassword(
      BuildContext context, AuthService auth) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set a password'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New password',
            helperText: 'At least 6 characters',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(ctx.tr('cancel'))),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(ctx.tr('save'))),
        ],
      ),
    );
    if (ok != true) return;
    final r = await auth.addPasswordToCurrentAccount(ctrl.text);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(r.ok
            ? 'Password added. You can now sign in either way.'
            : r.message ?? context.tr('error_generic')),
      ),
    );
  }
}
