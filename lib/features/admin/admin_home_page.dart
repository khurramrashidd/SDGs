import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/admin/admin_config.dart';
import '../../core/admin/admin_service.dart';
import '../../core/i18n/strings.dart';
import '../../core/layout/responsive.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/brand.dart';
import 'ai_providers_page.dart';
import 'content_editor_page.dart';
import 'deadlines_page.dart';
import 'moderation_page.dart';
import 'send_notice_page.dart';
import 'translations_page.dart';
import 'user_admin_page.dart';

/// Admin area.
///
/// Everything shown here is decided by [AdminService], and enforced again by
/// firestore.rules. The client deciding what to display is a convenience;
/// the rules are what actually stop anything.
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  void initState() {
    super.initState();
    // Roles can change while the app is open - someone may have just been
    // promoted - so re-check on entry rather than trusting start-up state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminService>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminService>();
    final auth = context.watch<AuthService>();
    final pad = context.pagePadding;

    if (!admin.loaded) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    if (admin.role == AdminRole.none) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('admin'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 16),
                const Text(
                  'This account does not have admin access.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Signed in as ${auth.user?.email ?? "unknown"}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.read<AdminService>().refresh(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Check again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('admin')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: Brand.primary),
        ),
      ),
      body: ContentShell(
        maxWidth: 760,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 20, pad, 40),
          children: [
            Row(
              children: [
                if (admin.role == AdminRole.owner)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.workspace_premium, size: 20),
                  ),
                Text(
                  admin.role.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              auth.user?.email ?? '',
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            if (admin.role == AdminRole.sdgAdmin) ...[
              const SizedBox(height: 4),
              Text(
                admin.sdgAccess.isEmpty
                    ? 'No goals assigned to you yet'
                    : 'You can edit SDG ${admin.sdgAccess.join(", ")}',
                style: TextStyle(
                    fontSize: 12.5,
                    color: Theme.of(context).colorScheme.outline),
              ),
            ],
            const SizedBox(height: 24),

            // Fixing a wrong government link is the most common admin job,
            // so it sits at the top.
            _AdminCard(
              icon: Icons.edit_note_outlined,
              title: 'Edit content',
              subtitle:
                  'Fix a broken link, correct a scheme, update a helpline. '
                  'Changes reach every device immediately.',
              onTap: () => _push(
                context,
                ContentDatasetsPage(canEdit: admin.canEditSdg),
              ),
            ),
            const SizedBox(height: 12),

            // Separate from "Edit content" on purpose. Editing content is
            // correcting a fact; translating is carrying a fact across a
            // language. Mixing them into one screen is how a translator
            // ends up changing an English source they did not mean to
            // touch.
            _AdminCard(
              icon: Icons.translate_outlined,
              title: 'Translate content',
              subtitle:
                  'Add a regional language, record by record. The app ships '
                  'with English and Hindi content; anything added here goes '
                  'live without an app update.',
              onTap: () => _push(context, const TranslationsPage()),
            ),
            const SizedBox(height: 12),

            if (admin.role.canManageUsers) ...[
              _AdminCard(
                icon: Icons.group_outlined,
                title: 'People and access',
                subtitle: admin.role.canTransferOwnership
                    ? 'Make someone an admin, or hand over master admin.'
                    : 'Make someone an admin and choose which goals.',
                onTap: () => _push(context, const UserAdminPage()),
              ),
              const SizedBox(height: 12),
            ],

            _AdminCard(
              icon: Icons.verified_user_outlined,
              title: 'Moderation',
              subtitle:
                  'Approve study questions and answers before anyone sees '
                  'them; act on reported Q&A and food board posts; user corrections.',
              onTap: () => _push(context, const ModerationPage()),
            ),
            const SizedBox(height: 12),

            _AdminCard(
              icon: Icons.campaign_outlined,
              title: 'Send a notice',
              subtitle: 'Appears in every user\'s bell feed.',
              onTap: () => _push(context, const SendNoticePage()),
            ),
            const SizedBox(height: 12),

            if (admin.canEditSdg(4)) ...[
              _AdminCard(
                icon: Icons.edit_calendar_outlined,
                title: 'Scholarship deadlines',
                subtitle:
                    'Without a date here, students are told to check the '
                    'portal. Keep these current.',
                onTap: () => _push(context, const DeadlinesPage()),
              ),
              const SizedBox(height: 12),
            ],

            if (admin.role.canManageKeys)
              _AdminCard(
                icon: Icons.key_outlined,
                title: 'AI providers and keys',
                subtitle:
                    'Add keys, set priority, switch models. Keys are '
                    'write-only - nothing can read them back.',
                onTap: () => _push(context, const AiProvidersPage()),
              ),

            const SizedBox(height: 28),
            Text(
              'Master admin: ${admin.activeOwnerEmail ?? AdminConfig.rootOwnerEmail}',
              style: TextStyle(
                  fontSize: 11.5,
                  color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget page) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => page));
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Icon(icon, size: 28),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle,
              style: const TextStyle(fontSize: 12, height: 1.4)),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
