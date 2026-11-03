import 'package:flutter/material.dart';

import '../../core/i18n/locale_scope.dart';
import '../../core/i18n/strings.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import 'learn_page.dart';
import 'literacy_page.dart';
import 'qa_page.dart';
import 'quiz_page.dart';
import 'scholarships_page.dart';

/// SDG 4 — Quality Education.
///
/// Until zip 20 this goal opened straight onto the scholarship matcher,
/// which was the strongest single piece but only one of the six things
/// LearningVersity did. This hub puts the rest back: free learning by class
/// level (Courses and Resources), languages, the practice quiz and the
/// literacy tracker. The scholarship matcher is still the first thing on the
/// screen, because it is the one that puts money in a student's hand.
class EducationHomePage extends StatelessWidget {
  const EducationHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final pad = context.pagePadding;
    final accent = SdgColors.of(4);

    void push(Widget page) =>
        Navigator.of(context).push(localeScopedRoute(page));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('sdg4_title')),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: accent),
        ),
      ),
      body: ContentShell(
        maxWidth: 700,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
          children: [
            Card(
              color: accent.withValues(alpha: 0.10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hi
                          ? 'कौन सी छात्रवृत्ति आपके लिए है?'
                          : 'Which scholarships are you eligible for?',
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 1.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hi
                          ? '24 केंद्रीय छात्रवृत्तियाँ, कक्षा 8 से पीएचडी तक। सात '
                              'सवालों का जवाब दें — हम बताएँगे कौन सी लागू हैं, '
                              'कौन से काग़ज़ चाहिए, और कब तक।'
                          : '24 central scholarships, class 8 to PhD. Answer '
                              'seven questions and see which apply, which '
                              'papers they need, and by when.',
                      style: const TextStyle(fontSize: 14, height: 1.55),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () => push(const ScholarshipsPage()),
                      icon: const Icon(Icons.school_outlined),
                      label: Text(
                          hi ? 'छात्रवृत्ति खोजें' : 'Find scholarships'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            _SectionLabel(hi ? 'मुफ़्त पढ़ाई' : 'Learn for free'),
            _Row(
              icon: Icons.menu_book_outlined,
              title: hi
                  ? 'हर कक्षा के लिए मुफ़्त पढ़ाई'
                  : 'Free learning for every class',
              subtitle: hi
                  ? 'दीक्षा, एनसीईआरटी किताबें, टीवी चैनल, स्वयं, एनआईओएस'
                  : 'DIKSHA, NCERT books, TV channels, SWAYAM, NIOS',
              onTap: () => push(const LearnPage()),
            ),
            _Row(
              icon: Icons.quiz_outlined,
              title: hi ? 'अभ्यास क्विज़' : 'Practice quiz',
              subtitle: hi
                  ? 'छह विषय, एक-एक सवाल, जवाब तुरंत'
                  : 'Six subjects, one question at a time',
              onTap: () => push(const QuizPage()),
            ),
            _Row(
              icon: Icons.forum_outlined,
              title: hi ? 'पढ़ाई के सवाल पूछें' : 'Ask a study question',
              subtitle: hi
                  ? 'जवाब दूसरे विद्यार्थी और मददगार देते हैं — हर चीज़ पहले जाँची जाती है'
                  : 'Answered by other students and helpers — everything '
                      'checked before it appears',
              onTap: () => push(const QaPage()),
            ),
            const SizedBox(height: 22),
            _SectionLabel(hi ? 'आँकड़े' : 'The numbers'),
            _Row(
              icon: Icons.bar_chart_outlined,
              title: hi ? 'साक्षरता दर' : 'Literacy rates',
              subtitle: hi
                  ? 'भारत और पड़ोसी देश — महिलाएँ और पुरुष अलग-अलग'
                  : 'India and its neighbours — women and men side by side',
              onTap: () => push(const LiteracyPage()),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Row({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: scheme.primary),
        title: Text(title,
            style:
                const TextStyle(fontWeight: FontWeight.w600, height: 1.25)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(subtitle,
              style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
