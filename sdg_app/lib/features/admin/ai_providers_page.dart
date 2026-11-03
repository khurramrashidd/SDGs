import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/layout/responsive.dart';

/// The provider catalogue the proxy understands. Free tier rotates in
/// priority order; paid slots stay empty until an admin deliberately adds a
/// key, because a paid key means real billing with no cap.
class ProviderSpec {
  final String id;
  final String label;
  final bool paid;
  final String defaultModel;
  final String keyHint;

  const ProviderSpec(
      this.id, this.label, this.paid, this.defaultModel, this.keyHint);
}

const List<ProviderSpec> kProviders = [
  // ---- free tier ----
  ProviderSpec('gemini', 'Google Gemini', false, 'gemini-2.0-flash',
      'Get a key at aistudio.google.com'),
  ProviderSpec('groq', 'Groq', false, 'llama-3.3-70b-versatile',
      'Get a key at console.groq.com'),
  ProviderSpec('openrouter', 'OpenRouter', false,
      'meta-llama/llama-3.3-70b-instruct:free',
      'Get a key at openrouter.ai'),
  ProviderSpec('mistral', 'Mistral', false, 'mistral-small-latest',
      'Get a key at console.mistral.ai'),
  ProviderSpec('deepseek', 'DeepSeek', false, 'deepseek-chat',
      'Get a key at platform.deepseek.com'),
  ProviderSpec('cohere', 'Cohere', false, 'command-r',
      'Get a key at dashboard.cohere.com'),
  ProviderSpec('together', 'Together AI', false,
      'meta-llama/Llama-3.3-70B-Instruct-Turbo',
      'Get a key at api.together.xyz'),
  ProviderSpec('huggingface', 'Hugging Face', false,
      'meta-llama/Llama-3.1-8B-Instruct',
      'Get a key at huggingface.co/settings/tokens'),
  // ---- paid, empty by default ----
  ProviderSpec('openai', 'OpenAI', true, 'gpt-4o-mini',
      'Billed to your OpenAI account'),
  ProviderSpec('anthropic', 'Anthropic', true, 'claude-haiku-4-5',
      'Billed to your Anthropic account'),
];

class AiProvidersPage extends StatelessWidget {
  const AiProvidersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI providers & keys')),
      body: ContentShell(
        maxWidth: 760,
        child: ListView(
          padding: EdgeInsets.fromLTRB(context.pagePadding, 16, context.pagePadding, 40),
          children: [
            const _SecurityNote(),
            const SizedBox(height: 24),
            const Text('Free tier',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              'Tried in this order. If one fails or hits its limit, the proxy '
              'moves to the next automatically.',
              style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            ...kProviders
                .where((p) => !p.paid)
                .map((p) => _ProviderTile(spec: p)),
            const SizedBox(height: 28),
            const Text('Paid',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              'Adding a key here means real charges on your account, with no '
              'spending cap enforced by this app. Leave empty unless you '
              'intend to pay.',
              style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 14),
            ...kProviders
                .where((p) => p.paid)
                .map((p) => _ProviderTile(spec: p)),
          ],
        ),
      ),
    );
  }
}

class _SecurityNote extends StatelessWidget {
  const _SecurityNote();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined,
              color: scheme.onPrimaryContainer, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Keys are write-only. Once saved they can never be read back '
              'by this app or any user - only the Render proxy can read '
              'them, using a server-side service account. To change a key, '
              'overwrite it.',
              style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: scheme.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderTile extends StatelessWidget {
  final ProviderSpec spec;
  const _ProviderTile({required this.spec});

  @override
  Widget build(BuildContext context) {
    // Only the public status doc is readable - it holds whether a key exists
    // and which model is selected, never the key itself.
    final statusRef = FirebaseFirestore.instance
        .collection('aiProviders')
        .doc(spec.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: statusRef.snapshots(),
        builder: (context, snap) {
          final data = snap.data?.data() ?? {};
          final hasKey = data['hasKey'] == true;
          final enabled = data['enabled'] == true;
          final model =
              (data['model'] ?? spec.defaultModel).toString();

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            leading: Icon(
              hasKey ? Icons.check_circle : Icons.circle_outlined,
              color: hasKey
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
            title: Text(spec.label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                hasKey ? 'Key set · $model' : spec.keyHint,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            trailing: Switch(
              value: enabled && hasKey,
              onChanged: hasKey
                  ? (v) => statusRef.set(
                      {'enabled': v}, SetOptions(merge: true))
                  : null,
            ),
            onTap: () => _editKey(context, spec, model),
          );
        },
      ),
    );
  }

  Future<void> _editKey(
      BuildContext context, ProviderSpec spec, String model) async {
    final keyCtrl = TextEditingController();
    final modelCtrl = TextEditingController(text: model);

    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(spec.label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (spec.paid)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'This is a paid provider. Usage will be billed to you.',
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(ctx).colorScheme.error),
                ),
              ),
            TextField(
              controller: keyCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'API key',
                helperText: 'Paste the key. It is never shown again.',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: modelCtrl,
              decoration: const InputDecoration(labelText: 'Model'),
            ),
          ],
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
    );

    if (save != true || keyCtrl.text.trim().isEmpty) return;

    final db = FirebaseFirestore.instance;
    // The secret itself goes to a collection no client can read.
    await db.collection('_secrets').doc('ai_${spec.id}').set({
      'provider': spec.id,
      'apiKey': keyCtrl.text.trim(),
      'model': modelCtrl.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    // The readable status doc holds no secret - just state for this screen.
    await db.collection('aiProviders').doc(spec.id).set({
      'provider': spec.id,
      'label': spec.label,
      'paid': spec.paid,
      'hasKey': true,
      'enabled': true,
      'model': modelCtrl.text.trim(),
      'priority': kProviders.indexWhere((p) => p.id == spec.id),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${spec.label} key saved.')),
      );
    }
  }
}
