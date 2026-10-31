import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A always-visible way out of this section.
///
/// Why this exists: someone reading about domestic violence or filing a report
/// may be interrupted by the person they are escaping from. One tap returns to
/// the home grid, which looks like an ordinary list of topics.
///
/// What it does NOT do, and what the UI says plainly: it does not hide the app,
/// clear the phone, or erase anything already sent. An app that implies more
/// safety than it provides is worse than one that is honest about its limits.
class QuickExitButton extends StatelessWidget {
  const QuickExitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Leave this screen now',
      child: Tooltip(
        message: 'Leave this screen now',
        child: TextButton.icon(
          onPressed: () => context.go('/'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          icon: const Icon(Icons.close, size: 18),
          label: const Text('Leave',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

/// Plain statement of what this app can and cannot do for someone's safety.
/// Shown at the top of the safety and reporting screens, not buried.
class SafetyLimitsNote extends StatelessWidget {
  const SafetyLimitsNote({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 19, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This app is visible on your phone and does not hide itself. '
              'If someone else checks this device, they can see you opened '
              'it. In an emergency, calling 112 or 181 directly is faster '
              'and leaves less behind than anything here.',
              style: TextStyle(
                  fontSize: 13, height: 1.45, color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
