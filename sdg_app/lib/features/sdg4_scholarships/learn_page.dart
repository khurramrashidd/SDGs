import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/content/content_store.dart';
import '../../core/content/dataset_registry.dart';
import '../../core/i18n/locale_scope.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import '../../core/widgets/guide_list_page.dart';

/// Free learning, by level.
///
/// LearningVersity's Courses, Resources and Languages pages, rebuilt for the
/// person this app is for. The original linked mostly to international
/// platforms — Khan Academy, edX, Coursera, Udemy — in English. Those are
/// good, but a child in a Hindi- or Marathi-medium government school is far
/// better served by DIKSHA, which opens the exact chapter of their own
/// textbook in the language it is printed in when they scan its QR code.
///
/// The subject search and the language links from the original are kept,
/// because they were genuinely useful: one box that opens a search, with no
/// account and nothing to install.
class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

enum _Level { early, primary, secondary, leftschool, college }

class _LearnPageState extends State<LearnPage> {
  _Level _level = _Level.primary;
  final _subject = TextEditingController();
  final _language = TextEditingController();
  late final Future<List<Map<String, dynamic>>> _future = ContentStore
      .instance
      .rows(kDatasets.firstWhere((d) => d.collection == 'learning'));

  bool get _hi => Localizations.localeOf(context).languageCode == 'hi';

  @override
  void dispose() {
    _subject.dispose();
    _language.dispose();
    super.dispose();
  }

  String _levelLabel(_Level l) => switch (l) {
        _Level.early => _hi ? 'छोटे बच्चे' : 'Early years',
        _Level.primary => _hi ? 'कक्षा 1–8' : 'Class 1–8',
        _Level.secondary => _hi ? 'कक्षा 9–12' : 'Class 9–12',
        _Level.leftschool => _hi ? 'स्कूल छूट गया' : 'Left school',
        _Level.college => _hi ? 'कॉलेज और आगे' : 'College and beyond',
      };

  Future<void> _open(String url) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
      if (!ok) {
        messenger.showSnackBar(SnackBar(content: Text('Could not open $url')));
      }
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text('Could not open $url')));
    }
  }

  void _searchSubject(String where) {
    final q = _subject.text.trim();
    if (q.isEmpty) return;
    final e = Uri.encodeComponent(q);
    _open(switch (where) {
      'youtube' => 'https://www.youtube.com/results?search_query=$e+lesson',
      // A site-restricted search rather than DIKSHA's own search URL, whose
      // query parameter is undocumented. A guessed parameter would open an
      // empty page and look like the subject has no material.
      'diksha' => 'https://www.google.com/search?q=site%3Adiksha.gov.in+$e',
      _ => 'https://www.google.com/search?q=$e+notes',
    });
  }

  void _searchLanguage([String? language]) {
    final l = (language ?? _language.text).trim();
    if (l.isEmpty) return;
    _open('https://www.youtube.com/results?search_query='
        '${Uri.encodeComponent(l)}+language+lessons+for+beginners');
  }

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;
    final hi = _hi;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(hi ? 'मुफ़्त पढ़ाई' : 'Free learning'),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(4)),
        ),
      ),
      body: ContentShell(
        maxWidth: 700,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
          children: [
            Text(hi ? 'किसके लिए?' : 'For whom?',
                style: const TextStyle(
                    fontSize: 15.5, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final l in _Level.values)
                  ChoiceChip(
                    label: Text(_levelLabel(l)),
                    selected: _level == l,
                    onSelected: (_) => setState(() => _level = l),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final rows = (snap.data ?? const <Map<String, dynamic>>[])
                    .where((r) {
                  final levels = r['levels'];
                  return levels is List && levels.contains(_level.name);
                }).toList();
                return Column(
                  children: [
                    for (final r in rows)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GuideCard(row: r),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 18),
            _Heading(hi ? 'कोई भी विषय खोजें' : 'Search any subject'),
            TextField(
              controller: _subject,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchSubject('diksha'),
              decoration: InputDecoration(
                hintText: hi
                    ? 'जैसे: भिन्न, प्रकाश संश्लेषण, संविधान'
                    : 'e.g. fractions, photosynthesis, the Constitution',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                FilledButton.tonal(
                  onPressed: () => _searchSubject('diksha'),
                  child: const Text('DIKSHA'),
                ),
                OutlinedButton(
                  onPressed: () => _searchSubject('youtube'),
                  child: const Text('YouTube'),
                ),
                OutlinedButton(
                  onPressed: () => _searchSubject('google'),
                  child: Text(hi ? 'नोट्स' : 'Notes'),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _Heading(hi ? 'नई भाषा सीखें' : 'Learn a language'),
            Text(
              hi
                  ? 'किसी भाषा पर टैप करें — शुरुआती पाठ खुलेंगे।'
                  : 'Tap a language to open beginner lessons.',
              style: TextStyle(
                  fontSize: 13, color: scheme.onSurfaceVariant, height: 1.4),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // English first: for most people this app is written for,
                // it is the language that opens the most doors. The rest are
                // the eight from the original Languages page.
                for (final l in const [
                  ('English', 'अंग्रेज़ी'),
                  ('Hindi', 'हिंदी'),
                  ('Urdu', 'उर्दू'),
                  ('Sanskrit', 'संस्कृत'),
                  ('Telugu', 'तेलुगु'),
                  ('Malayalam', 'मलयालम'),
                  ('Arabic', 'अरबी'),
                  ('French', 'फ़्रेंच'),
                  ('German', 'जर्मन'),
                  ('Spanish', 'स्पेनिश'),
                ])
                  ActionChip(
                    label: Text(hi ? l.$2 : l.$1),
                    onPressed: () => _searchLanguage(l.$1),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _language,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchLanguage(),
              decoration: InputDecoration(
                hintText: hi ? 'या कोई और भाषा लिखें' : 'Or type any language',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _searchLanguage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text.toUpperCase(),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: Theme.of(context).colorScheme.primary,
            )),
      );
}
