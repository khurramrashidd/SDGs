import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/services/ai_service.dart';
import '../../core/i18n/strings.dart';
import '../../core/layout/responsive.dart';
import '../../core/sdg/sdg_catalog.dart';

/// Writes the notice to Firestore (the in-app bell feed), and optionally
/// asks the proxy to also push it over FCM. Both halves of the agreed
/// design, no Cloud Functions involved.
class SendNoticePage extends StatefulWidget {
  const SendNoticePage({super.key});

  @override
  State<SendNoticePage> createState() => _SendNoticePageState();
}

class _SendNoticePageState extends State<SendNoticePage> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _alsoPush = false;
  bool _busy = false;

  /// null means the notice is for the whole app. A number pins it to one
  /// goal, where it shows in that goal's side panel - a scholarship
  /// deadline has no business interrupting someone on the water screens.
  int? _goal;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_title.text.trim().isEmpty || _body.text.trim().isEmpty) return;
    setState(() => _busy = true);

    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': _title.text.trim(),
        'body': _body.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': FirebaseAuth.instance.currentUser?.uid,
        'pushed': _alsoPush,
        if (_goal != null) 'goal': _goal,
      });

      if (_alsoPush) {
        final token =
            await FirebaseAuth.instance.currentUser?.getIdToken();
        await http.post(
          Uri.parse('${AiService.proxyUrl}/api/push'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'title': _title.text.trim(),
            'body': _body.text.trim(),
          }),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_alsoPush
                ? 'Notice posted and pushed.'
                : 'Notice posted to the in-app feed.')),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send a notice')),
      body: ContentShell(
        maxWidth: 620,
        child: ListView(
        padding: EdgeInsets.fromLTRB(context.pagePadding, 20, context.pagePadding, 40),
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title'),
            maxLength: 60,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _body,
            decoration: const InputDecoration(labelText: 'Message'),
            maxLines: 4,
            maxLength: 300,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            initialValue: _goal,
            decoration: const InputDecoration(
              labelText: 'Show it where',
              helperText: 'A goal pins the notice to that goal\'s panel.',
            ),
            items: [
              const DropdownMenuItem<int?>(
                  value: null, child: Text('Everywhere (bell feed)')),
              for (final e in kSdgCatalog)
                DropdownMenuItem<int?>(
                  value: e.goal,
                  child: Text(
                      'SDG ${e.goal} - ${context.tr(e.titleKey)}'),
                ),
            ],
            onChanged: (v) => setState(() => _goal = v),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _alsoPush,
            onChanged: (v) => setState(() => _alsoPush = v),
            contentPadding: EdgeInsets.zero,
            title: const Text('Also send as a push notification'),
            subtitle: const Text(
              'Reaches people with the app closed. Use sparingly.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _send,
            child: _busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Send'),
          ),
        ],
      ),
      ),
    );
  }
}
