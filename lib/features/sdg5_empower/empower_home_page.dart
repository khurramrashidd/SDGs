import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n/locale_scope.dart';
import '../../core/i18n/strings.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import '../../core/widgets/guide_list_page.dart';
import '../sdg9_enterprise/scheme_match_page.dart';
import 'leaders_page.dart';
import 'mentor_page.dart';
import 'report_page.dart';
import 'rights_page.dart';
import 'safety_page.dart';

/// Hub for SDG 5.
///
/// Ordering is a safety decision, not a design one: the call-for-help path is
/// first and visually heaviest, because someone opening this in distress
/// should not have to scroll past career advice to find a phone number.
class EmpowerHomePage extends StatelessWidget {
  const EmpowerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final pad = context.pagePadding;
    final accent = SdgColors.of(5);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('sdg5_title')),
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
            _EmergencyCard(hi: hi),
            const SizedBox(height: 22),

            _SectionLabel(hi ? 'सहायता' : 'Get help'),
            _Row(
              icon: Icons.support_agent_outlined,
              title: hi ? 'हेल्पलाइन नंबर' : 'Helpline numbers',
              subtitle: hi
                  ? 'महिला, आपातकाल, बच्चे, साइबर अपराध — सभी निःशुल्क'
                  : 'Women, emergency, children, cyber crime — all free',
              onTap: () => _push(context, const SafetyPage()),
            ),
            _Row(
              icon: Icons.shield_outlined,
              title: hi ? 'दुर्व्यवहार की रिपोर्ट' : 'Report abuse',
              subtitle: hi
                  ? 'आप तय करें कि क्या सहेजा जाए — या कुछ भी नहीं'
                  : 'You choose what is stored, or nothing at all',
              onTap: () => _push(context, const ReportPage()),
            ),
            _Row(
              icon: Icons.balance_outlined,
              title: hi ? 'आपके अधिकार' : 'Know your rights',
              subtitle: hi
                  ? 'घरेलू हिंसा, कार्यस्थल, दहेज, संपत्ति, मुफ़्त वकील'
                  : 'Domestic violence, work, dowry, property, free lawyer',
              onTap: () => _push(context, const RightsPage()),
            ),

            const SizedBox(height: 24),
            _SectionLabel(hi ? 'सेहत' : 'Health and wellbeing'),
            _Row(
              icon: Icons.pregnant_woman_outlined,
              title: hi ? 'माँ बनने पर' : 'Pregnancy and birth',
              subtitle: hi
                  ? 'मातृ वंदना के पैसे, सरकारी अस्पताल में मुफ़्त प्रसव'
                  : 'Matru Vandana cash, a free delivery in a government '
                      'hospital',
              onTap: () => _push(
                context,
                const GuideListPage(
                  collection: 'wellness',
                  category: 'mother',
                  title: 'Pregnancy and birth',
                  titleHi: 'माँ बनने पर',
                  goal: 5,
                ),
              ),
            ),
            _Row(
              icon: Icons.favorite_border,
              title: hi ? 'ख़ून की कमी और कैंसर जाँच' : 'Anaemia and cancer checks',
              subtitle: hi
                  ? 'आधी से ज़्यादा महिलाओं में ख़ून की कमी — जाँच और गोलियाँ'
                  : 'More than half of women are anaemic — tests and tablets',
              onTap: () => _push(
                context,
                const GuideListPage(
                  collection: 'wellness',
                  category: 'body',
                  title: 'Anaemia and cancer checks',
                  titleHi: 'ख़ून की कमी और कैंसर जाँच',
                  goal: 5,
                ),
              ),
            ),
            _Row(
              icon: Icons.self_improvement_outlined,
              title: hi ? 'मन की बात: 14416' : 'Someone to talk to: 14416',
              subtitle: hi
                  ? 'टेली-मानस — मुफ़्त, 24 घंटे, कई भाषाओं में'
                  : 'Tele-MANAS — free, 24 hours, many languages',
              onTap: () => _push(
                context,
                const GuideListPage(
                  collection: 'wellness',
                  category: 'mind',
                  title: 'Someone to talk to',
                  titleHi: 'बात करने के लिए कोई',
                  goal: 5,
                ),
              ),
            ),

            const SizedBox(height: 24),
            _SectionLabel(hi ? 'आगे बढ़ें' : 'Build your future'),
            _Row(
              icon: Icons.work_outline,
              title: hi ? 'करियर मार्गदर्शन' : 'Career guidance',
              subtitle: hi
                  ? 'काम, पढ़ाई और कार्यस्थल के सवाल'
                  : 'Questions about work, study and the workplace',
              onTap: () => _push(
                  context, const MentorPage(task: MentorTask.mentor)),
            ),
            _Row(
              icon: Icons.storefront_outlined,
              title: hi ? 'व्यवसाय के विचार' : 'Business ideas',
              subtitle: hi
                  ? 'घर से शुरू होने वाले छोटे व्यवसाय'
                  : 'Small businesses you could start from home',
              onTap: () => _push(
                  context, const MentorPage(task: MentorTask.businessIdea)),
            ),
            _Row(
              icon: Icons.account_balance_outlined,
              title: hi ? 'व्यवसाय के लिए पैसा' : 'Money to start a business',
              subtitle: hi
                  ? 'मुद्रा, स्टैंड-अप इंडिया, पीएमईजीपी — कौन सी योजना आपकी है'
                  : 'Mudra, Stand-Up India, PMEGP — which loan fits you',
              onTap: () => _push(context, const SchemeMatchPage()),
            ),
            _Row(
              icon: Icons.school_outlined,
              title: hi ? 'कोर्स खोजें' : 'Find a course',
              subtitle: hi
                  ? 'नया कौशल सीखने के मुफ़्त कोर्स'
                  : 'Free courses to learn a new skill',
              onTap: () => _push(
                  context, const MentorPage(task: MentorTask.courses)),
            ),
            _Row(
              icon: Icons.auto_stories_outlined,
              title: hi ? 'भारत की महिलाएँ' : 'Women of India',
              subtitle: hi
                  ? '21 महिलाएँ और उन्होंने क्या किया'
                  : '21 women and what they did',
              onTap: () => _push(context, const LeadersPage()),
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget page) => Navigator.of(context)
      .push(localeScopedRoute(page));
}

/// 181 and 112, one tap, above everything else on the screen.
class _EmergencyCard extends StatelessWidget {
  final bool hi;
  const _EmergencyCard({required this.hi});

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
            hi ? 'अभी मदद चाहिए?' : 'Need help right now?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: scheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hi
                ? 'दोनों नंबर निःशुल्क हैं और 24 घंटे चालू रहते हैं।'
                : 'Both numbers are free and answer 24 hours a day.',
            style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: scheme.onErrorContainer),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () =>
                      launchUrl(Uri(scheme: 'tel', path: '181')),
                  icon: const Icon(Icons.phone, size: 19),
                  label: const Text('181'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () =>
                      launchUrl(Uri(scheme: 'tel', path: '112')),
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
