import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n/localized_content.dart';
import '../../core/content/content_store.dart';
import '../../core/content/dataset_registry.dart';
import '../../core/i18n/locale_scope.dart';
import '../../core/i18n/strings.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import '../../core/widgets/guide_list_page.dart';
import 'child_vaccines_page.dart';
import 'daily_log_page.dart';
import 'medicine_reminders_page.dart';
import 'myths_page.dart';
import 'vaccination_page.dart';

class HealthLine {
  final int id;
  final String number;
  final String name;
  final String detail;
  final int priority;
  final Map<String, dynamic> raw;

  const HealthLine({
    required this.id,
    required this.number,
    required this.name,
    required this.detail,
    required this.priority,
    required this.raw,
  });

  factory HealthLine.fromJson(Map<String, dynamic> j) => HealthLine(
        id: j['id'] as int,
        number: (j['number'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        detail: (j['detail'] ?? '').toString(),
        priority: j['priority'] is int ? j['priority'] as int : 99,
        raw: j,
      );

  // `number` is never localised - see translatableFields in
  // dataset_registry.dart. A helpline whose digits get rewritten into
  // another numeral system stops dialling.
  String title(String lang) => pickLocalized(raw, 'name', lang);
  String body(String lang) => pickLocalized(raw, 'detail', lang);
}

class HealthHomePage extends StatefulWidget {
  const HealthHomePage({super.key});

  @override
  State<HealthHomePage> createState() => _HealthHomePageState();
}

class _HealthHomePageState extends State<HealthHomePage> {
  late final Future<List<HealthLine>> _future = _load();

  Future<List<HealthLine>> _load() async {
    final ds = kDatasets.firstWhere((d) => d.collection == 'healthlines');
    final rows = await ContentStore.instance.rows(ds);
    return rows.map(HealthLine.fromJson).toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;
    final pad = context.pagePadding;
    final accent = SdgColors.of(3);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('sdg3_title')),
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
            _Emergency(hi: hi),
            const SizedBox(height: 22),

            _SectionLabel(hi ? 'जानकारी' : 'Learn'),
            _Row(
              icon: Icons.fact_check_outlined,
              title: hi ? 'अफ़वाह और सच' : 'Myth vs fact',
              subtitle: hi
                  ? '16 आम अफ़वाहें जो नुकसान पहुँचाती हैं — और सच क्या है'
                  : '16 common beliefs that cause harm, and what is true',
              onTap: () => _push(context, const MythsPage()),
            ),
            _Row(
              icon: Icons.vaccines_outlined,
              title: hi ? 'टीकाकरण सूची' : 'Vaccination schedule',
              subtitle: hi
                  ? 'जन्म से 16 वर्ष तक, और गर्भवती महिलाओं के लिए'
                  : 'Birth to 16 years, and for pregnant women',
              onTap: () => _push(context, const VaccinationPage()),
            ),
            // From GoodHealthHub's vaccination record, kept on the phone and
            // computed from the date of birth instead of typed in by hand.
            _Row(
              icon: Icons.child_care,
              title: hi ? 'मेरे बच्चे के टीके' : 'My child\u2019s vaccines',
              subtitle: hi
                  ? 'जन्मतिथि डालें, देखें कौन सा टीका कब लगना है'
                  : 'Add a date of birth, see what is due and when',
              onTap: () => _push(context, const ChildVaccinesPage()),
            ),

            // GoodHealthHub had a doctor booking that reached no doctor, a
            // pharmacy list anyone could edit, and camp sign-ups for camps
            // that did not exist. These are the real things those pages
            // were reaching for, and every one of them is free.
            const SizedBox(height: 24),
            _SectionLabel(hi ? 'मुफ़्त और सस्ता इलाज' : 'Free and cheaper care'),
            _Row(
              icon: Icons.video_call_outlined,
              title: hi
                  ? 'मुफ़्त डॉक्टर — घर से, वीडियो पर'
                  : 'A free doctor — from home, by video',
              subtitle: hi
                  ? 'ई-संजीवनी, और नज़दीकी आयुष्मान आरोग्य मंदिर'
                  : 'eSanjeevani, and your nearest Ayushman Arogya Mandir',
              onTap: () => _push(
                context,
                const GuideListPage(
                  collection: 'freecare',
                  category: 'doctor',
                  title: 'A free doctor',
                  titleHi: 'मुफ़्त डॉक्टर',
                  goal: 3,
                ),
              ),
            ),
            _Row(
              icon: Icons.local_hospital_outlined,
              title: hi
                  ? '5 लाख तक का मुफ़्त अस्पताल इलाज'
                  : 'Up to Rs 5 lakh of free hospital care',
              subtitle: hi
                  ? 'आयुष्मान भारत — और 70 से ऊपर सबके लिए'
                  : 'Ayushman Bharat — and everyone over 70',
              onTap: () => _push(
                context,
                const GuideListPage(
                  collection: 'freecare',
                  category: 'cover',
                  title: 'Free hospital care',
                  titleHi: 'मुफ़्त अस्पताल इलाज',
                  goal: 3,
                ),
              ),
            ),
            _Row(
              icon: Icons.medication_outlined,
              title: hi
                  ? 'वही दवा, 50 से 90% सस्ती'
                  : 'The same medicine, 50 to 90% cheaper',
              subtitle: hi
                  ? 'जन औषधि केंद्र, और सही दवा कैसे माँगें'
                  : 'Jan Aushadhi, and how to ask for the right one',
              onTap: () => _push(
                context,
                const GuideListPage(
                  collection: 'freecare',
                  category: 'medicine',
                  title: 'Cheaper medicines',
                  titleHi: 'सस्ती दवाएँ',
                  goal: 3,
                ),
              ),
            ),
            _Row(
              icon: Icons.delete_sweep_outlined,
              title: hi
                  ? 'बची या एक्सपायर दवाओं का क्या करें'
                  : 'Leftover or expired medicines',
              subtitle: hi
                  ? 'सुरक्षित तरीके से हटाना — और दूसरों को क्यों न दें'
                  : 'Safe disposal — and why not to pass them on',
              onTap: () => _push(
                context,
                const GuideListPage(
                  collection: 'freecare',
                  category: 'leftover',
                  title: 'Leftover medicines',
                  titleHi: 'बची हुई दवाएँ',
                  goal: 3,
                ),
              ),
            ),

            const SizedBox(height: 24),
            _SectionLabel(hi ? 'रोज़ की आदतें' : 'Every day'),
            _Row(
              icon: Icons.alarm_outlined,
              title: hi ? 'दवा रिमाइंडर' : 'Medicine reminders',
              subtitle: hi
                  ? 'डॉक्टर के बताए समय पर रोज़ सूचना'
                  : 'A daily alert at the time your doctor said',
              onTap: () => _push(context, const MedicineRemindersPage()),
            ),
            _Row(
              icon: Icons.water_drop_outlined,
              title: hi ? 'रोज़ का रिकॉर्ड' : 'Daily log',
              subtitle: hi
                  ? 'पानी, क़दम, सक्रिय मिनट — सिर्फ़ आपके फ़ोन पर'
                  : 'Water, steps, active minutes — on your phone only',
              onTap: () => _push(context, const DailyLogPage()),
            ),

            const SizedBox(height: 24),
            _SectionLabel(hi ? 'हेल्पलाइन' : 'Helplines'),
            FutureBuilder<List<HealthLine>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final lines = snap.data ?? const <HealthLine>[];
                return Column(
                  children: lines
                      .map((l) => _LineCard(line: l, hi: hi))
                      .toList(),
                );
              },
            ),

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      size: 19, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Expanded(
                    // Said plainly, and meant. There is no symptom checker in
                    // this app and there is not going to be one.
                    child: Text(
                      hi
                          ? 'यह ऐप बीमारी नहीं बताता और इलाज नहीं सुझाता। '
                              'यहाँ सिर्फ़ जानकारी है और सही नंबर हैं। '
                              'जाँच और इलाज के लिए डॉक्टर या नज़दीकी सरकारी '
                              'स्वास्थ्य केंद्र पर जाएँ।'
                          : 'This app does not tell you what illness you have '
                              'and does not suggest treatment. It holds '
                              'information and the right phone numbers. For '
                              'diagnosis and treatment, see a doctor or your '
                              'nearest government health centre.',
                      style: TextStyle(
                          fontSize: 12.5,
                          height: 1.5,
                          color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget page) => Navigator.of(context)
      .push(localeScopedRoute(page));
}

class _Emergency extends StatelessWidget {
  final bool hi;
  const _Emergency({required this.hi});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hi ? 'आपातकाल' : 'Emergency',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: scheme.onErrorContainer),
          ),
          const SizedBox(height: 4),
          Text(
            hi
                ? 'दुर्घटना, साँस की तकलीफ़, सीने में दर्द, साँप काटना, '
                    'गंभीर जलन — तुरंत कॉल करें।'
                : 'Accident, breathing trouble, chest pain, snakebite, '
                    'severe burn — call now.',
            style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: scheme.onErrorContainer),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _dial(context, '108'),
                  icon: const Icon(Icons.local_hospital_outlined, size: 19),
                  label: const Text('108'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _dial(context, '112'),
                  icon: const Icon(Icons.emergency_outlined, size: 19),
                  label: const Text('112'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LineCard extends StatelessWidget {
  final HealthLine line;
  final bool hi;
  const _LineCard({required this.line, required this.hi});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lang = LocaleScope.languageOf(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _dial(context, line.number),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 11, vertical: 9),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  line.number,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(line.title(lang),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.25)),
                    const SizedBox(height: 4),
                    Text(line.body(lang),
                        style: TextStyle(
                            fontSize: 12.5,
                            height: 1.45,
                            color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.phone, size: 21, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shared dialler with a clipboard fallback - tablets and devices without a
/// SIM cannot place calls, and a tap that does nothing is worse than a
/// message explaining why.
Future<void> _dial(BuildContext context, String number) async {
  try {
    final ok = await launchUrl(Uri(scheme: 'tel', path: number));
    if (ok) return;
  } catch (_) {
    // fall through
  }
  await Clipboard.setData(ClipboardData(text: number));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('This device cannot call. $number copied instead.'),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, size: 26),
        title: Text(title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(subtitle,
              style: const TextStyle(fontSize: 12.5, height: 1.4)),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
