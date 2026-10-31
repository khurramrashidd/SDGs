import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/layout/responsive.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();
  bool _busy = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('reset_password'))),
      body: ContentShell(
        maxWidth: 520,
        child: ListView(
          padding: EdgeInsets.fromLTRB(context.pagePadding, 24, context.pagePadding, 32),
          children: [
            if (_sent) ...[
              Icon(Icons.mark_email_read_outlined,
                  size: 56, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                context.tr('reset_sent'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => context.pop(),
                child: Text(context.tr('sign_in')),
              ),
            ] else ...[
              Text(
                'Enter the email you signed up with and we will send you a '
                'link to set a new password.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: context.tr('email'),
                  prefixIcon: const Icon(Icons.mail_outline),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 13),
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy
                    ? null
                    : () async {
                        setState(() {
                          _busy = true;
                          _error = null;
                        });
                        final r =
                            await auth.sendPasswordReset(_email.text);
                        if (!mounted) return;
                        setState(() {
                          _busy = false;
                          _sent = r.ok;
                          if (!r.ok) {
                            _error =
                                r.message ?? context.tr('error_generic');
                          }
                        });
                      },
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(context.tr('reset_password')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
