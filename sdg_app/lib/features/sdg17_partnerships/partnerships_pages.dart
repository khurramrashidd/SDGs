import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/services/auth_service.dart';
import '../../core/widgets/module_hub.dart';

/// SDG 17 — Partnerships for the Goals.
///
/// The partnership this app can actually offer is between the people who
/// use it and the people who keep it correct. Every record ships marked
/// unverified; the fastest way it gets fixed is someone on the ground
/// saying "this number is wrong". So the main tool here is a correction
/// form that lands in the admin's moderation screen.
class PartnershipsHomePage extends StatelessWidget {
  const PartnershipsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    return ModuleHub(
      goal: 17,
      titleKey: 'sdg17_title',
      children: [
        HubHero(
          goal: 17,
          title: hi
              ? 'कोई ग़लती दिखी? हमें बताएँ'
              : 'Spotted a mistake? Tell us',
          body: hi
              ? 'ग़लत हेल्पलाइन नंबर, बंद लिंक, बदली हुई योजना की राशि — आप जो ठीक करवाते हैं, '
                  'वह हर उपयोगकर्ता के लिए ठीक हो जाता है, बिना ऐप अपडेट के।'
              : 'A wrong helpline number, a dead link, a scheme amount that '
                  'has changed — what you get corrected is corrected for every '
                  'user, without an app update.',
          button: hi ? 'सुधार भेजें' : 'Send a correction',
          icon: Icons.edit_outlined,
          onTap: () => pushScoped(context, const CorrectionPage()),
        ),
        HubLabel(hi ? 'खुलापन' : 'Openness'),
        HubRow(
          icon: Icons.privacy_tip_outlined,
          title: hi ? 'यह ऐप क्या रखता है' : 'What this app keeps',
          subtitle: hi
              ? 'आपके फ़ोन पर, हमारे सर्वर पर, और क्या कभी नहीं'
              : 'On your phone, on our server, and what never',
          onTap: () => pushScoped(context, const TransparencyPage()),
        ),
      ],
    );
  }
}

const _goals = [
  'No Poverty', 'Zero Hunger', 'Good Health', 'Quality Education',
  'Gender Equality', 'Clean Water', 'Affordable Energy', 'Decent Work',
  'Industry & Enterprise', 'Reduced Inequalities', 'Sustainable Cities',
  'Responsible Consumption', 'Climate Action', 'Life Below Water',
  'Life on Land', 'Peace & Justice', 'Partnerships',
];

class CorrectionPage extends StatefulWidget {
  const CorrectionPage({super.key});

  @override
  State<CorrectionPage> createState() => _CorrectionPageState();
}

class _CorrectionPageState extends State<CorrectionPage> {
  int _goal = 1;
  final _what = TextEditingController();
  final _source = TextEditingController();
  bool _busy = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _what.dispose();
    _source.dispose();
    super.dispose();
  }

  Future<void> _send(bool hi) async {
    final t = _what.text.trim();
    if (t.length < 10) {
      setState(() => _error = hi
          ? 'थोड़ा और बताएँ: क्या ग़लत है और सही क्या है।'
          : 'Say a little more: what is wrong, and what is right.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await FirebaseFirestore.instance.collection('corrections').add({
        'uid': FirebaseAuth.instance.currentUser?.uid,
        'goal': _goal,
        'what': t,
        'source': _source.text.trim(),
        'status': 'new',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      setState(() {
        _busy = false;
        _sent = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = hi
            ? 'भेजा नहीं जा सका। इंटरनेट जाँचें।'
            : 'Could not send. Check the internet.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final auth = context.watch<AuthService>();
    final scheme = Theme.of(context).colorScheme;

    return ToolScaffold(
      goal: 17,
      title: hi ? 'सुधार भेजें' : 'Send a correction',
      children: [
        if (!auth.isSignedIn) ...[
          Text(hi
              ? 'सुधार भेजने के लिए साइन इन करें, ताकि ज़रूरत हो तो हम पूछ सकें।'
              : 'Sign in to send a correction, so we can ask if we need to.'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.push('/sign-in'),
            child: Text(hi ? 'साइन इन' : 'Sign in'),
          ),
        ] else if (_sent) ...[
          Icon(Icons.check_circle_outline, size: 56, color: scheme.primary),
          const SizedBox(height: 10),
          Text(
            hi
                ? 'धन्यवाद। एक व्यवस्थापक इसे जाँचकर ऐप में ठीक करेगा।'
                : 'Thank you. An admin will check it and fix it in the app.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ] else ...[
          ToolQuestion(hi ? 'किस हिस्से में?' : 'Which part of the app?'),
          DropdownButtonFormField<int>(
            initialValue: _goal,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: [
              for (var i = 0; i < _goals.length; i++)
                DropdownMenuItem(
                    value: i + 1, child: Text('${i + 1}. ${_goals[i]}')),
            ],
            onChanged: (v) => setState(() => _goal = v ?? _goal),
          ),
          ToolQuestion(hi ? 'क्या ग़लत है?' : 'What is wrong?'),
          TextField(
            controller: _what,
            maxLength: 1000,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: hi
                  ? 'जैसे: "मुफ़्त इलाज" कार्ड पर हेल्पलाइन नंबर बदल गया है, नया नंबर ... है'
                  : 'e.g. The helpline on the "Free care" card has changed; '
                      'the new number is ...',
              border: const OutlineInputBorder(),
            ),
          ),
          TextField(
            controller: _source,
            maxLength: 300,
            decoration: InputDecoration(
              labelText: hi
                  ? 'सबूत का लिंक (वैकल्पिक)'
                  : 'Link that shows it (optional)',
              border: const OutlineInputBorder(),
            ),
          ),
          if (_error != null)
            Text(_error!, style: TextStyle(color: scheme.error)),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: _busy ? null : () => _send(hi),
            child: Text(hi ? 'भेजें' : 'Send'),
          ),
          const SizedBox(height: 10),
          Text(
            hi
                ? 'अपना फ़ोन नंबर या पता यहाँ न लिखें। यह संदेश सिर्फ़ व्यवस्थापक देखते हैं।'
                : 'Do not put your phone number or address here. Only admins '
                    'see this message.',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

class TransparencyPage extends StatelessWidget {
  const TransparencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    Widget section(String title, List<String> lines) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                for (final l in lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('•  $l',
                        style: const TextStyle(height: 1.45)),
                  ),
              ],
            ),
          ),
        );

    return ToolScaffold(
      goal: 17,
      title: hi ? 'यह ऐप क्या रखता है' : 'What this app keeps',
      children: [
        section(hi ? 'सिर्फ़ आपके फ़ोन पर' : 'Only on your phone', hi
            ? [
                'छात्रवृत्ति के लिए आपकी प्रोफ़ाइल',
                'बच्चों के टीकों का रिकॉर्ड',
                'दवा रिमाइंडर और रोज़ का रिकॉर्ड',
                'आपकी भाषा और दूसरी सेटिंग',
              ]
            : [
                'Your scholarship profile',
                "Your children's vaccine records",
                'Medicine reminders and the daily log',
                'Your language and other settings',
              ]),
        section(hi ? 'हमारे सर्वर पर' : 'On our server', hi
            ? [
                'आपका खाता: नाम और ईमेल',
                'खाना बोर्ड पर आपकी पोस्ट — आपका फ़ोन नंबर सिर्फ़ उसे दिखता है जो खाना लेता है, '
                    'और पोस्ट मिटाने पर मिट जाता है',
                'पढ़ाई के सवाल-जवाब जो आप भेजते हैं — बिना आपके नाम के दिखते हैं',
                'दुर्व्यवहार की रिपोर्ट — कोई भी ऐप से इन्हें वापस नहीं पढ़ सकता',
                'आपके भेजे सुधार और रिपोर्ट',
                'सूचनाएँ भेजने के लिए फ़ोन का एक टोकन',
              ]
            : [
                'Your account: name and email',
                'Your food board posts — your phone number is shown only to '
                    'the person who claims, and is deleted with the post',
                'Study questions and answers you send — shown without your name',
                'Abuse reports — nobody can read them back from the app',
                'Corrections and reports you send',
                'A device token, to send you notifications',
              ]),
        section(hi ? 'एआई सवाल' : 'AI questions', hi
            ? [
                'करियर और व्यवसाय के एआई सवाल हमारे सर्वर से एआई सेवा तक जाते हैं, ताकि '
                    'जवाब मिल सके। उनमें अपना नाम, फ़ोन या पता न लिखें।',
              ]
            : [
                'Career and business AI questions go through our server to '
                    'an AI provider to get an answer. Do not put your name, '
                    'phone or address in them.',
              ]),
        section(hi ? 'जो हम कभी नहीं करते' : 'What we never do', hi
            ? [
                'विज्ञापन नहीं',
                'आपका डेटा बेचना नहीं',
                'ऐप में कोई ट्रैकिंग या एनालिटिक्स नहीं',
              ]
            : [
                'No advertising',
                'No selling your data',
                'No tracking or analytics in the app',
              ]),
        section(hi ? 'जानकारी कितनी पक्की है' : 'How sure the information is', hi
            ? [
                'हर योजना, हेल्पलाइन और नियम सरकारी स्रोत के लिंक के साथ आता है।',
                'हर रिकॉर्ड "जाँचा नहीं गया" चिह्न के साथ आता है, जब तक कोई व्यक्ति उसे '
                    'आधिकारिक स्रोत से न मिला ले।',
                'नियम बदलते रहते हैं — कोई कदम उठाने से पहले आधिकारिक लिंक खोलकर देखें।',
              ]
            : [
                'Every scheme, helpline and rule comes with a link to its '
                    'government source.',
                'Every record ships marked unverified until a person has '
                    'checked it against the official source.',
                'Rules change — open the official link before you act.',
              ]),
        section(hi ? 'कौन चलाता है' : 'Who runs it', hi
            ? ['इब्तिदा टेक। सुझाव और सुधार "सुधार भेजें" से भेजें।']
            : ['Ibtidaa Tech. Send ideas and fixes through "Send a correction".']),
      ],
    );
  }
}
