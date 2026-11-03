import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/strings.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/brand.dart';
import '../../core/layout/responsive.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _busy = false;
  bool _obscure = true;
  String? _error;

  /// Set when Google sign-in found an existing email/password account with
  /// the same address. The user types their password and the two providers
  /// are linked into one account.
  String? _mergeEmail;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<AuthResult> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await action();
    if (!mounted) return;
    setState(() => _busy = false);

    if (result.ok) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
      return;
    }
    if (result.mergeRequired) {
      setState(() {
        _mergeEmail = result.mergeEmail;
        _email.text = result.mergeEmail ?? '';
      });
      return;
    }
    if (result.errorCode == 'cancelled') return;
    setState(() => _error = result.message ?? context.tr('error_generic'));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('sign_in'))),
      body: ContentShell(
        maxWidth: 520,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(context.pagePadding, 16, context.pagePadding, 32),
            children: [
              Text(
                Brand.companyName,
                style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                    color: scheme.primary),
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('login_required'),
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('login_required_body'),
                style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 28),

              if (_mergeEmail != null) _MergeBanner(email: _mergeEmail!),
              if (_mergeEmail != null) const SizedBox(height: 16),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: _mergeEmail == null,
                      decoration: InputDecoration(
                        labelText: context.tr('email'),
                        prefixIcon: const Icon(Icons.mail_outline),
                      ),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: context.tr('password'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'At least 6 characters'
                          : null,
                    ),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _busy
                      ? null
                      : () => context.push('/forgot-password'),
                  child: Text(context.tr('forgot_password')),
                ),
              ),

              if (_error != null) _ErrorBox(message: _error!),
              const SizedBox(height: 8),

              FilledButton(
                onPressed: _busy
                    ? null
                    : () {
                        if (!_formKey.currentState!.validate()) return;
                        _run(() => auth.signInWithEmail(
                              email: _email.text,
                              password: _password.text,
                            ));
                      },
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(context.tr('sign_in')),
              ),

              if (_mergeEmail == null) ...[
                const SizedBox(height: 20),
                Row(children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(context.tr('or'),
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                  ),
                  const Expanded(child: Divider()),
                ]),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed:
                      _busy ? null : () => _run(auth.signInWithGoogle),
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: Text(context.tr('continue_google')),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed:
                      _busy ? null : () => context.push('/sign-up'),
                  child: Text(context.tr('no_account')),
                ),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => context.canPop()
                          ? context.pop()
                          : context.go('/'),
                  child: Text(context.tr('browse_without_login')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MergeBanner extends StatelessWidget {
  final String email;
  const _MergeBanner({required this.email});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.link, color: scheme.onPrimaryContainer, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You already have an account with $email. '
              'Enter that password once and your Google sign-in will be '
              'linked to it - after this you can use either method.',
              style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: scheme.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline,
              size: 18, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(
                    fontSize: 13, color: scheme.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}
