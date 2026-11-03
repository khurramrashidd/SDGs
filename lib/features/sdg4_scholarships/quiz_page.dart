import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/i18n/locale_scope.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';

/// Practice quiz, from the Open Trivia Database.
///
/// LearningVersity's Quizzes page, ported. Same source and the same shape —
/// one question at a time, the answer shown straight away — with a choice
/// of subject added, because the original only ever asked general trivia.
///
/// The questions come from OpenTDB and are in English only. That is said on
/// the screen rather than hidden, since everything else in the app follows
/// the user's language and this does not.
///
/// `encode=url3986` asks the API for percent-encoded text instead of HTML
/// entities, which decodes exactly with Uri.decodeComponent rather than with
/// a hand-written entity table that misses the odd `&eacute;`.
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _Question {
  final String text;
  final String correct;
  final List<String> options;
  const _Question(this.text, this.correct, this.options);
}

const _subjects = [
  (9, 'General knowledge', 'सामान्य ज्ञान'),
  (17, 'Science and nature', 'विज्ञान और प्रकृति'),
  (19, 'Mathematics', 'गणित'),
  (18, 'Computers', 'कंप्यूटर'),
  (22, 'Geography', 'भूगोल'),
  (23, 'History', 'इतिहास'),
];

class _QuizPageState extends State<QuizPage> {
  int? _category;
  List<_Question>? _questions;
  int _index = 0;
  int _score = 0;
  String? _picked;
  bool _loading = false;
  String? _error;

  bool get _hi => Localizations.localeOf(context).languageCode == 'hi';

  Future<void> _start(int category) async {
    setState(() {
      _category = category;
      _loading = true;
      _error = null;
      _questions = null;
      _index = 0;
      _score = 0;
      _picked = null;
    });
    try {
      final uri = Uri.parse('https://opentdb.com/api.php?amount=10'
          '&category=$category&type=multiple&encode=url3986');
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final code = body['response_code'];
      if (code == 5) {
        // OpenTDB allows one request every five seconds per address.
        throw 'rate';
      }
      if (code != 0 || body['results'] is! List) throw 'empty';
      final list = <_Question>[];
      for (final r in body['results'] as List) {
        if (r is! Map) continue;
        final q = Uri.decodeComponent('${r['question']}');
        final c = Uri.decodeComponent('${r['correct_answer']}');
        final wrong = (r['incorrect_answers'] as List)
            .map((e) => Uri.decodeComponent('$e'))
            .toList();
        list.add(_Question(q, c, [...wrong, c]..shuffle()));
      }
      if (!mounted) return;
      setState(() {
        _questions = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e == 'rate'
            ? (_hi
                ? 'बहुत जल्दी दोबारा माँगा गया। कुछ सेकंड रुककर फिर कोशिश करें।'
                : 'Asked again too quickly. Wait a few seconds and try again.')
            : (_hi
                ? 'सवाल लोड नहीं हुए। इंटरनेट जाँचें।'
                : 'Could not load questions. Check the internet connection.');
      });
    }
  }

  void _answer(String option) {
    if (_picked != null) return;
    setState(() {
      _picked = option;
      if (option == _questions![_index].correct) _score++;
    });
  }

  void _next() => setState(() {
        _index++;
        _picked = null;
      });

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;
    final hi = _hi;

    return Scaffold(
      appBar: AppBar(
        title: Text(hi ? 'अभ्यास क्विज़' : 'Practice quiz'),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(4)),
        ),
      ),
      body: ContentShell(
        maxWidth: 640,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
          children: [
            if (_questions == null && !_loading) ..._picker(hi),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Colors.red.shade700)),
            ],
            if (_questions != null) ..._quiz(hi),
          ],
        ),
      ),
    );
  }

  List<Widget> _picker(bool hi) => [
        Text(hi ? 'विषय चुनें' : 'Choose a subject',
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(
          hi
              ? '10 सवाल, एक-एक करके, जवाब तुरंत। सवाल अंग्रेज़ी में हैं।'
              : 'Ten questions, one at a time, answers shown straight away. '
                  'The questions are in English.',
          style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 14),
        for (final s in _subjects)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(hi ? s.$3 : s.$2,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.play_arrow_rounded),
              onTap: () => _start(s.$1),
            ),
          ),
      ];

  List<Widget> _quiz(bool hi) {
    final qs = _questions!;
    final scheme = Theme.of(context).colorScheme;

    if (qs.isEmpty || _index >= qs.length) {
      return [
        const SizedBox(height: 24),
        Icon(Icons.emoji_events_outlined, size: 56, color: scheme.primary),
        const SizedBox(height: 12),
        Text(
          hi ? '${qs.length} में से $_score सही' : '$_score out of ${qs.length}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _category == null ? null : () => _start(_category!),
          child: Text(hi ? 'इसी विषय में फिर' : 'Again, same subject'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => setState(() {
            _questions = null;
            _category = null;
          }),
          child: Text(hi ? 'दूसरा विषय' : 'Another subject'),
        ),
      ];
    }

    final q = qs[_index];
    return [
      Text(
        hi
            ? 'सवाल ${_index + 1} / ${qs.length}  ·  अंक $_score'
            : 'Question ${_index + 1} of ${qs.length}  ·  Score $_score',
        style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
      ),
      const SizedBox(height: 10),
      Text(q.text,
          style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w700, height: 1.4)),
      const SizedBox(height: 16),
      for (final o in q.options)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _Option(
            text: o,
            state: _picked == null
                ? _OptState.open
                : o == q.correct
                    ? _OptState.correct
                    : o == _picked
                        ? _OptState.wrong
                        : _OptState.idle,
            onTap: () => _answer(o),
          ),
        ),
      if (_picked != null) ...[
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _next,
          child: Text(_index + 1 < qs.length
              ? (hi ? 'अगला सवाल' : 'Next question')
              : (hi ? 'नतीजा देखें' : 'See the result')),
        ),
      ],
    ];
  }
}

enum _OptState { open, correct, wrong, idle }

class _Option extends StatelessWidget {
  final String text;
  final _OptState state;
  final VoidCallback onTap;
  const _Option(
      {required this.text, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color border, Color fill, IconData? icon) = switch (state) {
      _OptState.correct => (
          Colors.green.shade600,
          Colors.green.shade600.withValues(alpha: 0.10),
          Icons.check_circle
        ),
      _OptState.wrong => (
          Colors.red.shade600,
          Colors.red.shade600.withValues(alpha: 0.10),
          Icons.cancel
        ),
      _ => (scheme.outlineVariant, Colors.transparent, null),
    };
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: state == _OptState.open ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 1.4),
          ),
          child: Row(
            children: [
              Expanded(
                  child: Text(text,
                      style: const TextStyle(fontSize: 15, height: 1.35))),
              if (icon != null) Icon(icon, color: border, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
