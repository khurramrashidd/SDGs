import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n/locale_scope.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import '../../core/widgets/selection_tile.dart';
import 'safety_exit.dart';

/// What the person chooses to happen with what they write.
///
/// All three exist because the right answer genuinely differs. Someone in
/// immediate danger needs a phone call, not a form. Someone documenting a
/// pattern over months needs it written down somewhere that is not their own
/// phone. Someone who wants follow-up needs to be reachable. Deciding for
/// them would be wrong.
///
/// Each option states plainly what is stored and who can read it, because
/// consent that is not informed is not consent.
enum ReportMode {
  /// Nothing is written anywhere. Dial a helpline instead.
  helplineOnly,

  /// Stored with no link to an account, deleted after 30 days.
  anonymous,

  /// Stored with contact details so an admin can follow up.
  withContact,
}

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  ReportMode _mode = ReportMode.helplineOnly;
  final _text = TextEditingController();
  final _contact = TextEditingController();
  bool _busy = false;
  bool _done = false;

  @override
  void dispose() {
    _text.dispose();
    _contact.dispose();
    super.dispose();
  }

  bool get _hi => Localizations.localeOf(context).languageCode == 'hi';

  Future<void> _dial(String number) async {
    await launchUrl(Uri(scheme: 'tel', path: number));
  }

  Future<void> _submit() async {
    if (_text.text.trim().length < 10) return;
    setState(() => _busy = true);

    try {
      final now = DateTime.now();
      final data = <String, dynamic>{
        'text': _text.text.trim(),
        'mode': _mode.name,
        'createdAt': FieldValue.serverTimestamp(),
        // Written by the client so the retention job has a plain date to
        // compare against even before the server timestamp resolves.
        'expiresAt': Timestamp.fromDate(now.add(const Duration(days: 30))),
        'status': 'new',
      };

      if (_mode == ReportMode.withContact) {
        data['contact'] = _contact.text.trim();
        data['uid'] = FirebaseAuth.instance.currentUser?.uid;
      }
      // For the anonymous mode nothing identifying is attached at all - no
      // uid, no contact, no device id.

      await FirebaseFirestore.instance
          .collection('sdg')
          .doc('5')
          .collection('reports')
          .add(data);

      if (!mounted) return;
      // Deliberately leave no local record of what was sent: the text field
      // is cleared and nothing is written to device storage, so there is
      // nothing on this phone for anyone else to find.
      _text.clear();
      _contact.clear();
      setState(() {
        _busy = false;
        _done = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_hi
              ? 'भेजा नहीं जा सका। इंटरनेट जाँचें, या 181 पर कॉल करें।'
              : 'Could not send. Check your connection, or call 181.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;

    return Scaffold(
      appBar: AppBar(
        title: Text(_hi ? 'दुर्व्यवहार की रिपोर्ट' : 'Report abuse'),
        actions: const [
          SectionLanguageButton(),
          QuickExitButton(),
          SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(5)),
        ),
      ),
      body: ContentShell(
        maxWidth: 640,
        child: _done ? _sent(pad) : _form(pad),
      ),
    );
  }

  Widget _sent(double pad) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: EdgeInsets.fromLTRB(pad, 40, pad, 32),
      children: [
        Icon(Icons.check_circle_outline, size: 56, color: scheme.primary),
        const SizedBox(height: 20),
        Text(
          _hi ? 'भेज दिया गया' : 'Sent',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          _hi
              ? 'आपके फ़ोन पर इसकी कोई प्रति नहीं रखी गई है।\n\n'
                  'यह ऐप कोई आपातकालीन सेवा नहीं है। अगर आप अभी खतरे में हैं '
                  'तो 112 या 181 पर कॉल करें।'
              : 'No copy has been kept on your phone.\n\n'
                  'This app is not an emergency service. If you are in danger '
                  'right now, call 112 or 181.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 14.5, height: 1.6, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: () => _dial('181'),
          icon: const Icon(Icons.phone),
          label: Text(_hi ? '181 पर कॉल करें' : 'Call 181'),
        ),
      ],
    );
  }

  Widget _form(double pad) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(pad, 14, pad, 36),
      children: [
        const SafetyLimitsNote(),
        const SizedBox(height: 20),

        Text(
          _hi ? 'आप क्या करना चाहती हैं?' : 'What would you like to do?',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            _hi
                ? 'हर विकल्प में साफ़ लिखा है कि आपकी बात कहाँ जाएगी और कौन पढ़ सकता है।'
                : 'Each option says exactly where your words go and who can read them.',
            style: TextStyle(
                fontSize: 12.5, height: 1.4, color: scheme.onSurfaceVariant),
          ),
        ),

        SelectionTile(
          label: _hi ? 'सिर्फ़ हेल्पलाइन पर कॉल करें' : 'Just call a helpline',
          subtitle: _hi
              ? 'कुछ भी सहेजा नहीं जाता। कोई रिकॉर्ड नहीं बनता।'
              : 'Nothing is written down. No record is created anywhere.',
          selected: _mode == ReportMode.helplineOnly,
          onTap: () => setState(() => _mode = ReportMode.helplineOnly),
        ),
        SelectionTile(
          label: _hi ? 'गुमनाम रूप से लिखें' : 'Write it down anonymously',
          subtitle: _hi
              ? 'आपके खाते से नहीं जुड़ता। 30 दिन बाद हटा दिया जाता है। एडमिन पढ़ सकते हैं।'
              : 'Not linked to your account. Deleted after 30 days. An admin can read it.',
          selected: _mode == ReportMode.anonymous,
          onTap: () => setState(() => _mode = ReportMode.anonymous),
        ),
        SelectionTile(
          label: _hi
              ? 'संपर्क विवरण के साथ भेजें'
              : 'Send it with contact details',
          subtitle: _hi
              ? 'एडमिन आपसे संपर्क कर सकते हैं। आपका नाम और संपर्क सहेजा जाता है।'
              : 'An admin can contact you. Your details are stored.',
          selected: _mode == ReportMode.withContact,
          onTap: () => setState(() => _mode = ReportMode.withContact),
        ),

        const SizedBox(height: 20),

        if (_mode == ReportMode.helplineOnly) ..._helplineOnly(scheme),
        if (_mode != ReportMode.helplineOnly) ..._writtenForm(scheme),
      ],
    );
  }

  List<Widget> _helplineOnly(ColorScheme scheme) => [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _hi
                ? 'यह सबसे सुरक्षित विकल्प है। 181 पर प्रशिक्षित काउंसलर हैं जो '
                    'आपको नज़दीकी वन स्टॉप सेंटर से जोड़ सकते हैं — वहाँ चिकित्सा, '
                    'पुलिस सहायता, कानूनी मदद और अस्थायी आश्रय निःशुल्क मिलता है।'
                : 'This is the safest option. 181 is staffed by trained '
                    'counsellors who can connect you to the nearest One Stop '
                    'Centre, where medical help, police support, legal aid and '
                    'short-stay shelter are free and need no documents.',
            style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: scheme.onPrimaryContainer),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => _dial('181'),
          icon: const Icon(Icons.phone),
          label: Text(_hi
              ? '181 — महिला हेल्पलाइन'
              : '181 — Women Helpline'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _dial('112'),
          icon: const Icon(Icons.emergency_outlined),
          label: Text(_hi
              ? '112 — आपातकाल'
              : '112 — Emergency'),
        ),
      ];

  List<Widget> _writtenForm(ColorScheme scheme) {
    final anon = _mode == ReportMode.anonymous;
    return [
      TextField(
        controller: _text,
        maxLines: 7,
        maxLength: 2000,
        decoration: InputDecoration(
          labelText: _hi ? 'क्या हुआ?' : 'What happened?',
          alignLabelWithHint: true,
          hintText: _hi
              ? 'जितना चाहें उतना लिखें। तारीख़ें मददगार होती हैं।'
              : 'Write as much or as little as you want. Dates help.',
        ),
      ),
      if (!anon) ...[
        const SizedBox(height: 8),
        TextField(
          controller: _contact,
          decoration: InputDecoration(
            labelText: _hi
                ? 'आपसे कैसे संपर्क करें'
                : 'How to reach you',
            hintText: _hi
                ? 'फ़ोन या ईमेल — केवल वही दें जो सुरक्षित हो'
                : 'Phone or email — only give what is safe to reach you on',
          ),
        ),
      ],
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline,
                size: 19, color: scheme.onTertiaryContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                anon
                    ? (_hi
                        ? 'यह सुरक्षित सर्वर पर सहेजा जाएगा, आपके खाते से बिना जुड़े, '
                            'और 30 दिन बाद हटा दिया जाएगा। ऐप के एडमिन इसे पढ़ सकते हैं। '
                            'यह पुलिस को स्वतः नहीं भेजा जाता।'
                        : 'This is stored on a secure server with no link to '
                            'your account, and deleted after 30 days. The app '
                            'administrators can read it. It is not sent to the '
                            'police automatically.')
                    : (_hi
                        ? 'आपका विवरण और संपर्क सहेजा जाएगा ताकि एडमिन आपसे संपर्क कर सकें। '
                            'यह पुलिस को स्वतः नहीं भेजा जाता।'
                        : 'Your report and contact details are stored so an '
                            'administrator can reach you. It is not sent to the '
                            'police automatically.'),
                style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: scheme.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      FilledButton(
        onPressed: _busy ? null : _submit,
        child: _busy
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
            : Text(_hi ? 'भेजें' : 'Send'),
      ),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: () => _dial('181'),
        icon: const Icon(Icons.phone),
        label: Text(_hi
            ? 'या अभी 181 पर कॉल करें'
            : 'Or call 181 right now'),
      ),
    ];
  }
}
