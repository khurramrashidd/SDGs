import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/i18n/locale_scope.dart';
import '../../core/layout/responsive.dart';
import '../../core/services/ai_service.dart';
import '../../core/theme/brand.dart';

/// The three AI features carried over from the EmpowHer web app, behind the
/// Render proxy. Each maps to a `task` the proxy turns into a system prompt,
/// so prompt wording lives on the server and can be improved without
/// shipping a new APK.
enum MentorTask {
  mentor('mentor', 'Career guidance', 'करियर मार्गदर्शन',
      'Ask about starting work, changing jobs, studying further, or dealing with a difficult workplace.',
      'काम शुरू करने, नौकरी बदलने, आगे पढ़ाई या मुश्किल कार्यस्थल के बारे में पूछें।'),
  businessIdea('business_idea', 'Business ideas', 'व्यवसाय के विचार',
      'Tell it what you can do or what interests you, and it will suggest small businesses you could start.',
      'बताएँ कि आपको क्या आता है या किसमें रुचि है — यह छोटे व्यवसाय सुझाएगा।'),
  courses('course_suggest', 'Courses to learn a skill', 'कौशल सीखने के कोर्स',
      'Ask for free or low-cost courses in a subject you want to learn.',
      'जो विषय सीखना है उसमें मुफ़्त या कम लागत वाले कोर्स पूछें।');

  final String id;
  final String label;
  final String labelHi;
  final String hint;
  final String hintHi;
  const MentorTask(
      this.id, this.label, this.labelHi, this.hint, this.hintHi);
}

class MentorPage extends StatefulWidget {
  final MentorTask task;
  const MentorPage({super.key, required this.task});

  @override
  State<MentorPage> createState() => _MentorPageState();
}

class _MentorPageState extends State<MentorPage> {
  final _ai = AiService();
  final _input = TextEditingController();
  String? _answer;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  bool get _hi => Localizations.localeOf(context).languageCode == 'hi';

  Future<void> _ask() async {
    final q = _input.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
      _answer = null;
    });

    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final res = await _ai.ask(
      prompt: q,
      task: widget.task.id,
      idToken: token,
    );

    if (!mounted) return;
    setState(() {
      _busy = false;
      if (res.ok) {
        _answer = res.text;
      } else {
        _error = res.text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pad = context.pagePadding;
    final t = widget.task;

    return Scaffold(
      appBar: AppBar(
        title: Text(_hi ? t.labelHi : t.label),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(5)),
        ),
      ),
      body: ContentShell(
        maxWidth: 680,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 32),
          children: [
            Text(
              _hi ? t.hintHi : t.hint,
              style: TextStyle(
                  fontSize: 14, height: 1.5, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _input,
              maxLines: 4,
              maxLength: 600,
              decoration: InputDecoration(
                labelText: _hi ? 'अपना सवाल लिखें' : 'Type your question',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _busy ? null : _ask,
              child: _busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_hi ? 'पूछें' : 'Ask'),
            ),

            if (_error != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.cloud_off,
                        size: 19, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_error!,
                          style: TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: scheme.onSurfaceVariant)),
                    ),
                  ],
                ),
              ),
            ],

            if (_answer != null) ...[
              const SizedBox(height: 22),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_answer!,
                          style: const TextStyle(
                              fontSize: 14.5, height: 1.6)),
                      const SizedBox(height: 14),
                      Divider(color: scheme.outlineVariant),
                      const SizedBox(height: 8),
                      // Said every time, under every answer. An AI suggestion
                      // about someone's livelihood or safety that reads as
                      // authoritative is the failure mode worth guarding
                      // against.
                      Text(
                        _hi
                            ? 'यह उत्तर एक AI ने लिखा है। यह गलत भी हो सकता है। '
                                'कोई बड़ा निर्णय लेने से पहले किसी भरोसेमंद '
                                'व्यक्ति या विशेषज्ञ से ज़रूर पूछें।'
                            : 'This answer was written by an AI and can be '
                                'wrong. Check anything important with a person '
                                'you trust before acting on it.',
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
