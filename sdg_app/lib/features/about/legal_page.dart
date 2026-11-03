import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';

class LegalSection {
  final String heading;
  final String body;
  const LegalSection(this.heading, this.body);
}

class LegalPage extends StatelessWidget {
  final String title;
  final String intro;
  final List<LegalSection> sections;
  final bool showPolicyLink;

  const LegalPage({
    super.key,
    required this.title,
    required this.intro,
    required this.sections,
    this.showPolicyLink = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pad = context.pagePadding;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ContentShell(
        maxWidth: 720,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 18, pad, 36),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                intro,
                style: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: scheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 24),
            ...sections.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.heading,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(s.body,
                        style:
                            const TextStyle(fontSize: 14, height: 1.6)),
                  ],
                ),
              ),
            ),
            if (showPolicyLink) ...[
              const SizedBox(height: 4),
              OutlinedButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse(CompanyLinks.privacyPolicy),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Read the full policy online'),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Questions: ${Brand.supportEmail}',
              style: TextStyle(fontSize: 12.5, color: scheme.outline),
            ),
            const SizedBox(height: 4),
            Text(
              '${Brand.companyName} · ${Brand.appName} v${Brand.appVersion}',
              style: TextStyle(fontSize: 12, color: scheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The text below describes what this app actually does. It was written
// against the real code, not copied from a template - the AI section exists
// because prompts genuinely leave the device, and the SDG 5 section says
// exactly what each reporting choice stores.
//
// It still needs a lawyer's eye before release, and Google Play requires the
// policy to be reachable at a public URL as well as in the app.
// ---------------------------------------------------------------------------

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'Privacy Policy',
      showPolicyLink: true,
      intro:
          'This explains exactly what the app stores, where it goes, and what '
          'stays on your phone. It describes how the app actually behaves, '
          'not a general statement of intent.',
      sections: [
        LegalSection(
          'What you do not have to give us',
          'You can open the app and read everything in it without an account '
          'and without giving any personal detail. Government schemes, '
          'scholarships, helpline numbers and legal information are all '
          'available to anyone.',
        ),
        LegalSection(
          'If you create an account',
          'We store your email address, the name you give, and which sign-in '
          'method you used. This is handled by Google Firebase Authentication. '
          'We never see or store your password — with Google sign-in there is '
          'no password at all, and with email sign-in Firebase holds it in a '
          'form we cannot read.',
        ),
        LegalSection(
          'Your scholarship details stay on your phone',
          'The questions in the scholarship section — what you study, your '
          'category, gender, whether you have a disability certificate, your '
          'family income band and your state — are saved only in this app, on '
          'this device. They are never uploaded. The matching happens on your '
          'phone against data built into the app. If you uninstall the app, '
          'they are gone.',
        ),
        LegalSection(
          'Reporting abuse',
          'You choose what happens, and the app does what it says.\n\n'
          '• Call a helpline — nothing is written down anywhere.\n\n'
          '• Anonymous — your words are stored with no link to your account, '
          'no name and no contact detail, and are deleted after 30 days. '
          'Administrators can read them.\n\n'
          '• With contact details — your words and the contact you give are '
          'stored so an administrator can reach you.\n\n'
          'In every case: nothing is sent to the police automatically, no '
          'copy is kept on your phone, and once sent, reports cannot be read '
          'back through the app by anyone — including you.',
        ),
        LegalSection(
          'When you use the AI features',
          'The career guidance, business idea and course finder features send '
          'what you type to our server, which passes it to an external AI '
          'provider such as Google, Groq or OpenRouter to generate an answer. '
          'Those providers handle your text under their own privacy policies. '
          'Do not put personal details, identity numbers or anything about '
          'your safety into those boxes.',
        ),
        LegalSection(
          'Notifications',
          'If you allow notifications, a device token is stored so we can send '
          'announcements. It identifies the device, not you, and you can stop '
          'it any time by turning notifications off in your phone settings.',
        ),
        LegalSection(
          'What we do not do',
          'We do not sell your data. We do not share it with advertisers. '
          'There is no advertising or tracking in this app. We do not collect '
          'your location, contacts, photos or files.',
        ),
        LegalSection(
          'Where it is stored',
          'Account details, reports and notification tokens are held in '
          'Google Firebase, in the asia-south1 region (Mumbai, India). '
          'Settings and your scholarship profile never leave your device.',
        ),
        LegalSection(
          'Deleting your data',
          'Email ${Brand.supportEmail} from the address on your account and we '
          'will delete it along with anything linked to it. Anonymous reports '
          'cannot be deleted on request, because nothing connects them to you '
          '— that is the point of them. They are removed after 30 days '
          'regardless.',
        ),
        LegalSection(
          'Children',
          'This app is not aimed at children under 13 and we do not knowingly '
          'collect their information. The Childline number (1098) is listed '
          'for young people who need help.',
        ),
        LegalSection(
          'Changes',
          'If this policy changes in a way that matters, we will say so in '
          'the app. The version it applies to is shown at the bottom of this '
          'page.',
        ),
      ],
    );
  }
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'Terms & Conditions',
      intro:
          'Plain terms for using this app. The short version: the information '
          'here is to help you find official services — it is not advice, and '
          'it is not an emergency service.',
      sections: [
        LegalSection(
          'This is not an emergency service',
          'If you are in danger, call 112 or 181 directly. This app cannot '
          'send help, cannot contact the police for you, and may not work if '
          'your phone has no signal or battery. Nothing you submit here '
          'reaches an emergency service automatically.',
        ),
        LegalSection(
          'Information, not advice',
          'Government schemes, scholarships and legal summaries are written '
          'in plain language to help you find the right official service. '
          'They are not legal, medical or financial advice. Rules change, and '
          'every situation is different. Always confirm on the official '
          'government portal, and get professional advice before acting on '
          'anything important.\n\n'
          'Every woman in India is entitled to a free lawyer — the NALSA '
          'helpline is 15100.',
        ),
        LegalSection(
          'We check, but we can be wrong',
          'Records that have not yet been checked by our team carry a visible '
          'caution. Schemes get discontinued, deadlines move, and links break. '
          'If you find something wrong, email ${Brand.supportEmail} and we '
          'will correct it.',
        ),
        LegalSection(
          'AI answers can be wrong',
          'The career, business and course suggestions are generated by an AI. '
          'They can be confidently incorrect. Treat them as a starting point, '
          'and check anything important with a person you trust.',
        ),
        LegalSection(
          'Using the app fairly',
          'Do not submit false reports, abuse the helpline information, or try '
          'to break into parts of the app you are not meant to reach. '
          'Accounts that do may be removed.',
        ),
        LegalSection(
          'Official links',
          'Links take you to government and other external websites. Those '
          'sites are not ours and we are not responsible for what they '
          'contain or how they handle your data.',
        ),
        LegalSection(
          'Who we are',
          '${Brand.appName} is built by ${Brand.companyName}, an MSME '
          'registered startup in India. Contact: ${Brand.supportEmail}.',
        ),
      ],
    );
  }
}
