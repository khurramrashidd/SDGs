import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/admin/admin_config.dart';
import '../../core/admin/admin_service.dart';
import '../../core/layout/responsive.dart';
import '../../core/sdg/sdg_catalog.dart';
import '../../core/widgets/selection_tile.dart';

/// Manage who can do what, and hand over the master admin role.
class UserAdminPage extends StatelessWidget {
  const UserAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminService>();
    final pad = context.pagePadding;

    return Scaffold(
      appBar: AppBar(title: const Text('People and access')),
      body: ContentShell(
        maxWidth: 760,
        child: StreamBuilder<List<AdminUser>>(
          stream: admin.watchUsers(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Text(
                    'Could not load the user list.\n\n'
                    'If this says permission denied, deploy the rules:\n'
                    'firebase deploy --only firestore:rules',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error),
                  ),
                ),
              );
            }

            final users = snap.data ?? const <AdminUser>[];
            final admins = users
                .where((u) => u.role != AdminRole.none)
                .toList();
            final rest =
                users.where((u) => u.role == AdminRole.none).toList();

            return ListView(
              padding: EdgeInsets.fromLTRB(pad, 16, pad, 32),
              children: [
                if (admin.role.canTransferOwnership)
                  _OwnershipCard(admin: admin),
                const SizedBox(height: 8),
                _Heading('Admins (${admins.length})'),
                if (admins.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Nobody has admin access yet.',
                        style: TextStyle(fontSize: 13)),
                  ),
                ...admins.map((u) => _UserRow(user: u, admin: admin)),
                const SizedBox(height: 20),
                _Heading('Everyone else (${rest.length})'),
                ...rest.map((u) => _UserRow(user: u, admin: admin)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OwnershipCard extends StatelessWidget {
  final AdminService admin;
  const _OwnershipCard({required this.admin});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = admin.activeOwnerEmail ?? AdminConfig.rootOwnerEmail;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.workspace_premium_outlined,
                    color: scheme.primary),
                const SizedBox(width: 10),
                const Text('Master admin',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            Text('Currently: $active',
                style: const TextStyle(fontSize: 13.5)),
            const SizedBox(height: 10),
            Text(
              'You can hand this to someone else. '
              '${AdminConfig.rootOwnerEmail} keeps master access either way, '
              'so a mistake here can never lock everyone out. Removing that '
              'recovery account means editing firestore.rules and '
              'redeploying.',
              style: TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => _transfer(context),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Transfer master admin'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _transfer(BuildContext context) async {
    final ctrl = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Transfer master admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The new master admin can manage everyone, including you. '
              'They must sign in with exactly this email.',
              style: TextStyle(fontSize: 13, height: 1.45),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'New master admin email',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Transfer'),
          ),
        ],
      ),
    );

    if (email == null || email.isEmpty) return;
    try {
      await admin.transferOwnership(email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Master admin is now $email')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}

class _UserRow extends StatelessWidget {
  final AdminUser user;
  final AdminService admin;
  const _UserRow({required this.user, required this.admin});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isOwnerRow = user.role == AdminRole.owner;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: isOwnerRow
              ? scheme.primary
              : scheme.surfaceContainerHighest,
          child: Text(
            (user.email.isNotEmpty ? user.email : '?')
                .characters
                .first
                .toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isOwnerRow ? Colors.white : scheme.onSurfaceVariant,
            ),
          ),
        ),
        title: Text(
          user.displayName.isEmpty ? user.email : user.displayName,
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.displayName.isNotEmpty)
              Text(user.email, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: [
                _Chip(
                  text: user.role.label,
                  highlight: user.role != AdminRole.none,
                ),
                if (user.role == AdminRole.sdgAdmin)
                  _Chip(
                    text: user.sdgAccess.isEmpty
                        ? 'no SDGs assigned'
                        : 'SDG ${user.sdgAccess.join(", ")}',
                  ),
                if (user.isRootOwner) const _Chip(text: 'recovery account'),
              ],
            ),
          ],
        ),
        trailing: (admin.role.canManageUsers && !user.isRootOwner)
            ? IconButton(
                icon: const Icon(Icons.manage_accounts_outlined),
                tooltip: 'Change access',
                onPressed: () => _edit(context),
              )
            : null,
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    var role = user.role == AdminRole.owner ? AdminRole.superAdmin : user.role;
    final selected = {...user.sdgAccess};

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(user.email, style: const TextStyle(fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final r in [
                  AdminRole.none,
                  AdminRole.sdgAdmin,
                  AdminRole.superAdmin
                ])
                  SelectionTile(
                    label: r.label,
                    selected: role == r,
                    onTap: () => setLocal(() => role = r),
                  ),
                if (role == AdminRole.sdgAdmin) ...[
                  const Divider(),
                  const Text('Which goals can they edit?',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: kSdgCatalog
                        .where((e) => e.isLive)
                        .map((e) => FilterChip(
                              label: Text('${e.goal}'),
                              selected: selected.contains(e.goal),
                              onSelected: (v) => setLocal(() {
                                v
                                    ? selected.add(e.goal)
                                    : selected.remove(e.goal);
                              }),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save')),
          ],
        ),
      ),
    );

    if (saved != true) return;
    try {
      await admin.setRole(user, role, sdgAccess: selected.toList()..sort());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.email} is now ${role.label}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool highlight;
  const _Chip({required this.text, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: highlight
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: highlight
              ? scheme.onPrimaryContainer
              : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
}
