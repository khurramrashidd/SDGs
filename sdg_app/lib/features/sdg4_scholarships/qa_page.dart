import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/locale_scope.dart';
import '../../core/layout/responsive.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/brand.dart';
import 'qa.dart';

String _label(List<(String, String, String)> list, String key, bool hi) {
  for (final e in list) {
    if (e.$1 == key) return hi ? e.$3 : e.$2;
  }
  return key;
}

String _contactRefusal(bool hi) => hi
    ? 'फ़ोन नंबर, लिंक, ईमेल या @नाम नहीं डाल सकते — यहाँ किसी से निजी संपर्क नहीं होता।'
    : 'Phone numbers, links, emails and @names are not allowed — nobody '
        'exchanges contact details here.';

class _Rules extends StatelessWidget {
  const _Rules();

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        hi
            ? 'हर सवाल और जवाब पहले जाँचा जाता है, फिर दिखता है। अपना नाम, फ़ोन, पता, '
                'स्कूल या सोशल मीडिया कभी न लिखें। अगर कोई आपसे कहीं और बात करने '
                'या मिलने को कहे, तो रिपोर्ट करें और किसी बड़े को बताएँ।'
            : 'Every question and answer is checked before it appears. Never '
                'write your name, phone, address, school or social media. If '
                'anyone asks to talk somewhere else or to meet, report it and '
                'tell an adult you trust.',
        style: TextStyle(
            fontSize: 12.8, height: 1.45, color: scheme.onTertiaryContainer),
      ),
    );
  }
}

/// Ask and answer study questions.
class QaPage extends StatefulWidget {
  const QaPage({super.key});

  @override
  State<QaPage> createState() => _QaPageState();
}

class _QaPageState extends State<QaPage> {
  String? _subject;

  bool get _hi => Localizations.localeOf(context).languageCode == 'hi';

  Future<void> _ask() async {
    final hi = _hi;
    final auth = context.read<AuthService>();
    if (!auth.isSignedIn) {
      context.push('/sign-in');
      return;
    }
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AskSheet(hi: hi),
    );
    if (sent == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(hi
            ? 'भेज दिया। जाँच के बाद दिखेगा — "मेरे सवाल" में देखें।'
            : 'Sent. It appears once checked — see "My questions".'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hi = _hi;
    final pad = context.pagePadding;
    final auth = context.watch<AuthService>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(hi ? 'पढ़ाई के सवाल' : 'Study questions'),
          actions: const [SectionLanguageButton()],
          bottom: TabBar(tabs: [
            Tab(text: hi ? 'सवाल-जवाब' : 'Questions'),
            Tab(text: hi ? 'मेरे सवाल' : 'My questions'),
          ]),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _ask,
          icon: const Icon(Icons.help_outline),
          label: Text(hi ? 'सवाल पूछें' : 'Ask'),
        ),
        body: ContentShell(
          maxWidth: 700,
          child: TabBarView(children: [
            ListView(
              padding: EdgeInsets.fromLTRB(pad, 12, pad, 96),
              children: [
                const _Rules(),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    ChoiceChip(
                      label: Text(hi ? 'सभी' : 'All'),
                      selected: _subject == null,
                      onSelected: (_) => setState(() => _subject = null),
                    ),
                    for (final s in qaSubjects) ...[
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: Text(hi ? s.$3 : s.$2),
                        selected: _subject == s.$1,
                        onSelected: (_) => setState(() => _subject = s.$1),
                      ),
                    ],
                  ]),
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<QaItem>>(
                  stream: QaService.approvedQuestions(),
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return _Note(hi
                          ? 'लोड नहीं हुआ। इंटरनेट जाँचें।'
                          : 'Could not load. Check the internet.');
                    }
                    if (!snap.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final list = snap.data!
                        .where((q) => _subject == null || q.subject == _subject)
                        .toList();
                    if (list.isEmpty) {
                      return _Note(hi
                          ? 'अभी कोई सवाल नहीं। पहला सवाल आप पूछें।'
                          : 'No questions yet. Be the first to ask.');
                    }
                    return Column(children: [
                      for (final q in list) _QuestionCard(q: q, hi: hi),
                    ]);
                  },
                ),
              ],
            ),
            auth.isSignedIn
                ? StreamBuilder<List<QaItem>>(
                    stream: QaService.myQuestions(),
                    builder: (context, snap) {
                      final list = snap.data ?? const <QaItem>[];
                      if (!snap.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      if (list.isEmpty) {
                        return _Note(hi
                            ? 'आपने अभी कोई सवाल नहीं पूछा।'
                            : 'You have not asked anything yet.');
                      }
                      return ListView(
                        padding: EdgeInsets.fromLTRB(pad, 12, pad, 96),
                        children: [
                          for (final q in list)
                            _QuestionCard(q: q, hi: hi, showStatus: true),
                        ],
                      );
                    },
                  )
                : Center(
                    child: FilledButton(
                      onPressed: () => context.push('/sign-in'),
                      child: Text(hi ? 'साइन इन' : 'Sign in'),
                    ),
                  ),
          ]),
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  final String text;
  const _Note(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
      );
}

class _QuestionCard extends StatelessWidget {
  final QaItem q;
  final bool hi;
  final bool showStatus;
  const _QuestionCard(
      {required this.q, required this.hi, this.showStatus = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = switch (q.status) {
      'approved' => hi ? 'दिख रहा है' : 'Live',
      'rejected' => hi ? 'स्वीकार नहीं हुआ' : 'Not approved',
      _ => hi ? 'जाँच बाक़ी' : 'Waiting for review',
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(q.text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, height: 1.35)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${_label(qaSubjects, q.subject, hi)} · '
            '${_label(qaLevels, q.level, hi)}'
            '${showStatus ? ' · $status' : ''}',
            style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
          ),
        ),
        trailing: q.status == 'approved'
            ? const Icon(Icons.chevron_right)
            : null,
        onTap: q.status == 'approved'
            ? () => Navigator.of(context)
                .push(localeScopedRoute(QaDetailPage(question: q)))
            : null,
      ),
    );
  }
}

class _AskSheet extends StatefulWidget {
  final bool hi;
  const _AskSheet({required this.hi});

  @override
  State<_AskSheet> createState() => _AskSheetState();
}

class _AskSheetState extends State<_AskSheet> {
  final _text = TextEditingController();
  String _subject = 'maths';
  String _level = 'secondary';
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final hi = widget.hi;
    final t = _text.text.trim();
    if (t.length < 10) {
      setState(() => _error =
          hi ? 'सवाल थोड़ा और विस्तार से लिखें।' : 'Write the question in a little more detail.');
      return;
    }
    if (carriesContact(t)) {
      setState(() => _error = _contactRefusal(hi));
      return;
    }
    setState(() => _busy = true);
    try {
      await QaService.ask(t, _subject, _level);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = hi ? 'भेजा नहीं जा सका।' : 'Could not send.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hi = widget.hi;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(hi ? 'सवाल पूछें' : 'Ask a question',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _subject,
              decoration: InputDecoration(
                  labelText: hi ? 'विषय' : 'Subject',
                  border: const OutlineInputBorder()),
              items: [
                for (final s in qaSubjects)
                  DropdownMenuItem(value: s.$1, child: Text(hi ? s.$3 : s.$2)),
              ],
              onChanged: (v) => setState(() => _subject = v ?? _subject),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _level,
              decoration: InputDecoration(
                  labelText: hi ? 'कक्षा' : 'Level',
                  border: const OutlineInputBorder()),
              items: [
                for (final s in qaLevels)
                  DropdownMenuItem(value: s.$1, child: Text(hi ? s.$3 : s.$2)),
              ],
              onChanged: (v) => setState(() => _level = v ?? _level),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _text,
              maxLength: 500,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: hi ? 'आपका सवाल' : 'Your question',
                border: const OutlineInputBorder(),
              ),
            ),
            if (_error != null)
              Text(_error!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : _send,
              child: Text(hi ? 'जाँच के लिए भेजें' : 'Send for review'),
            ),
          ],
        ),
      ),
    );
  }
}

/// One question with its approved answers.
class QaDetailPage extends StatefulWidget {
  final QaItem question;
  const QaDetailPage({super.key, required this.question});

  @override
  State<QaDetailPage> createState() => _QaDetailPageState();
}

class _QaDetailPageState extends State<QaDetailPage> {
  final _answer = TextEditingController();
  String? _msg;
  bool _busy = false;

  bool get _hi => Localizations.localeOf(context).languageCode == 'hi';

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final hi = _hi;
    final t = _answer.text.trim();
    if (t.length < 2) return;
    if (carriesContact(t)) {
      setState(() => _msg = _contactRefusal(hi));
      return;
    }
    setState(() => _busy = true);
    try {
      await QaService.answer(widget.question.id, t);
      if (!mounted) return;
      _answer.clear();
      setState(() {
        _busy = false;
        _msg = hi
            ? 'भेज दिया। जाँच के बाद दिखेगा।'
            : 'Sent. It appears once checked.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _msg = hi ? 'भेजा नहीं जा सका।' : 'Could not send.';
      });
    }
  }

  Future<void> _report(QaItem item, bool isAnswer) async {
    final hi = _hi;
    if (QaService.myUid == null) {
      context.push('/sign-in');
      return;
    }
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(hi ? 'रिपोर्ट क्यों?' : 'Why report this?'),
        children: [
          for (final r in qaReportReasons)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, r.$1),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(hi ? r.$3 : r.$2),
              ),
            ),
        ],
      ),
    );
    if (reason == null) return;
    try {
      await QaService.report(item, isAnswer, reason);
      if (!mounted) return;
      setState(() => _msg = hi ? 'रिपोर्ट मिल गई। धन्यवाद।' : 'Reported. Thank you.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _msg = hi
          ? 'आप इसे पहले ही रिपोर्ट कर चुके हैं।'
          : 'You have already reported this.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hi = _hi;
    final pad = context.pagePadding;
    final q = widget.question;
    final scheme = Theme.of(context).colorScheme;
    final signedIn = context.watch<AuthService>().isSignedIn;

    return Scaffold(
      appBar: AppBar(
        title: Text(_label(qaSubjects, q.subject, hi)),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(4)),
        ),
      ),
      body: ContentShell(
        maxWidth: 680,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
          children: [
            Text(hi ? 'एक विद्यार्थी ने पूछा' : 'A student asked',
                style:
                    TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(q.text,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700, height: 1.4)),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _report(q, false),
                icon: const Icon(Icons.flag_outlined, size: 18),
                label: Text(hi ? 'रिपोर्ट' : 'Report'),
              ),
            ),
            const Divider(),
            StreamBuilder<List<QaItem>>(
              stream: QaService.approvedAnswers(q.id),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final list = snap.data!;
                if (list.isEmpty) {
                  return _Note(hi ? 'अभी कोई जवाब नहीं।' : 'No answers yet.');
                }
                return Column(children: [
                  for (final a in list)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 6, 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hi ? 'एक मददगार' : 'A helper',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: scheme.onSurfaceVariant)),
                            const SizedBox(height: 4),
                            Text(a.text,
                                style: const TextStyle(height: 1.5)),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => _report(a, true),
                                child: Text(hi ? 'रिपोर्ट' : 'Report'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ]);
              },
            ),
            const SizedBox(height: 16),
            if (signedIn) ...[
              TextField(
                controller: _answer,
                maxLength: 1500,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: hi ? 'जवाब लिखें' : 'Write an answer',
                  helperText: hi
                      ? 'समझाकर लिखें। जाँच के बाद दिखेगा।'
                      : 'Explain the steps. It appears once checked.',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _busy ? null : _send,
                child: Text(hi ? 'जाँच के लिए भेजें' : 'Send for review'),
              ),
            ] else
              OutlinedButton(
                onPressed: () => context.push('/sign-in'),
                child: Text(hi ? 'जवाब देने के लिए साइन इन करें' : 'Sign in to answer'),
              ),
            if (_msg != null) ...[
              const SizedBox(height: 10),
              Text(_msg!, style: TextStyle(color: scheme.primary)),
            ],
            const SizedBox(height: 18),
            const _Rules(),
          ],
        ),
      ),
    );
  }
}
