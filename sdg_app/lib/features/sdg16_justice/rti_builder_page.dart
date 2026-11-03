import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n/locale_scope.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';

/// Builds a correctly formatted RTI application.
///
/// This is the piece of SDG 16 with actual teeth. The right to information
/// is strong on paper and most people never use it, partly because a blank
/// page is intimidating and partly because applications get rejected for
/// format reasons that have nothing to do with the question being asked.
///
/// Everything stays on the device - nothing typed here is uploaded. The
/// output is plain text to copy, print or hand over at a counter.
class RtiBuilderPage extends StatefulWidget {
  const RtiBuilderPage({super.key});

  @override
  State<RtiBuilderPage> createState() => _RtiBuilderPageState();
}

class _RtiBuilderPageState extends State<RtiBuilderPage> {
  final _authority = TextEditingController();
  final _subject = TextEditingController();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _questions = <TextEditingController>[TextEditingController()];
  bool _bpl = false;

  @override
  void dispose() {
    for (final c in [
      _authority,
      _subject,
      _name,
      _address,
      _phone,
      ..._questions
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _hi => Localizations.localeOf(context).languageCode == 'hi';

  bool get _ready =>
      _authority.text.trim().isNotEmpty &&
      _name.text.trim().isNotEmpty &&
      _address.text.trim().isNotEmpty &&
      _questions.any((q) => q.text.trim().isNotEmpty);

  /// The application text.
  ///
  /// The citizenship line, the numbered questions and the fee line are not
  /// decoration - applications are routinely returned for missing them.
  String get _application {
    final today = DateTime.now();
    final date =
        '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
    final qs = _questions
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final fee = _bpl
        ? 'I am below the poverty line and am therefore exempt from the '
            'application fee under the Right to Information Act, 2005. '
            'A copy of my BPL card is enclosed.'
        : 'The application fee of Rs. 10 is enclosed.';

    return '''
To,
The Public Information Officer
${_authority.text.trim()}

Date: $date

Subject: Request for information under the Right to Information Act, 2005${_subject.text.trim().isEmpty ? '' : ' — ${_subject.text.trim()}'}

Sir / Madam,

Under Section 6(1) of the Right to Information Act, 2005, I request the following information:

${List.generate(qs.length, (i) => '${i + 1}. ${qs[i]}').join('\n\n')}

I request that the information be provided in writing at the address below.

$fee

I am a citizen of India.

Yours faithfully,

${_name.text.trim()}
${_address.text.trim()}${_phone.text.trim().isEmpty ? '' : '\nPhone: ${_phone.text.trim()}'}
'''
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pad = context.pagePadding;

    return Scaffold(
      appBar: AppBar(
        title: Text(_hi ? 'आरटीआई आवेदन बनाएँ' : 'Write an RTI'),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(16)),
        ),
      ),
      body: ContentShell(
        maxWidth: 680,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _hi
                    ? 'जो भी आप यहाँ लिखेंगे वह सिर्फ़ इसी फ़ोन में रहेगा। '
                        'कहीं भेजा नहीं जाता। अंत में तैयार आवेदन कॉपी करके '
                        'डाक से भेज सकते हैं या rtionline.gov.in पर चिपका '
                        'सकते हैं।'
                    : 'Everything you type here stays on this phone. Nothing '
                        'is uploaded. At the end you can copy the finished '
                        'application to post, or paste it into '
                        'rtionline.gov.in.',
                style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: scheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: 22),

            _Field(
              controller: _authority,
              label: _hi
                  ? 'किस दफ़्तर से जानकारी चाहिए?'
                  : 'Which office holds the information?',
              hint: _hi
                  ? 'जैसे: ग्राम पंचायत कार्यालय, रामपुर, ज़िला सीतापुर'
                  : 'e.g. Gram Panchayat Office, Rampur, District Sitapur',
              lines: 2,
              onChanged: () => setState(() {}),
            ),
            _Field(
              controller: _subject,
              label: _hi ? 'विषय (एक पंक्ति)' : 'Subject (one line)',
              hint: _hi
                  ? 'जैसे: सड़क निर्माण कार्य का व्यय विवरण'
                  : 'e.g. Expenditure details of the road construction work',
              onChanged: () => setState(() {}),
            ),

            const SizedBox(height: 10),
            Text(
              _hi ? 'आपके सवाल' : 'Your questions',
              style: const TextStyle(
                  fontSize: 15.5, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _hi
                    ? 'हर सवाल अलग और ठोस रखें। "भ्रष्टाचार की जानकारी दें" '
                        'जैसे अस्पष्ट सवाल ठुकरा दिए जाते हैं; "1 जनवरी 2026 '
                        'से 31 मार्च 2026 तक स्वीकृत राशि की प्रति दें" जैसे '
                        'सवाल का जवाब देना पड़ता है।'
                    : 'Keep each question separate and specific. A vague '
                        'question like "give information about corruption" '
                        'gets rejected; "provide a copy of the sanctioned '
                        'amount between 1 January 2026 and 31 March 2026" '
                        'has to be answered.',
                style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: scheme.onSurfaceVariant),
              ),
            ),
            ...List.generate(_questions.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, right: 8),
                      child: Text('${i + 1}.',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _questions[i],
                        maxLines: 3,
                        minLines: 1,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: _hi
                              ? 'आप वास्तव में क्या जानना चाहते हैं?'
                              : 'What exactly do you want to know?',
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_questions.length > 1)
                      IconButton(
                        icon: const Icon(Icons.close, size: 19),
                        onPressed: () => setState(() {
                          _questions.removeAt(i).dispose();
                        }),
                      ),
                  ],
                ),
              );
            }),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(
                    () => _questions.add(TextEditingController())),
                icon: const Icon(Icons.add, size: 19),
                label: Text(_hi ? 'और सवाल जोड़ें' : 'Add another question'),
              ),
            ),

            const SizedBox(height: 16),
            _Field(
              controller: _name,
              label: _hi ? 'आपका पूरा नाम' : 'Your full name',
              onChanged: () => setState(() {}),
            ),
            _Field(
              controller: _address,
              label: _hi
                  ? 'जवाब भेजने का पता'
                  : 'Address where the reply should be sent',
              lines: 3,
              onChanged: () => setState(() {}),
            ),
            _Field(
              controller: _phone,
              label: _hi ? 'फ़ोन (वैकल्पिक)' : 'Phone (optional)',
              onChanged: () => setState(() {}),
            ),

            SwitchListTile(
              value: _bpl,
              contentPadding: EdgeInsets.zero,
              title: Text(_hi
                  ? 'मैं ग़रीबी रेखा से नीचे हूँ'
                  : 'I am below the poverty line'),
              subtitle: Text(
                _hi
                    ? 'तब कोई शुल्क नहीं लगता — बीपीएल कार्ड की प्रति लगाएँ'
                    : 'Then no fee applies — enclose a copy of your BPL card',
                style: const TextStyle(fontSize: 12),
              ),
              onChanged: (v) => setState(() => _bpl = v),
            ),

            const SizedBox(height: 18),
            if (!_ready)
              Text(
                _hi
                    ? 'दफ़्तर का नाम, कम से कम एक सवाल, अपना नाम और पता भरें।'
                    : 'Fill in the office, at least one question, your name '
                        'and your address.',
                style: TextStyle(
                    fontSize: 13, color: scheme.onSurfaceVariant),
              ),
            if (_ready) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: SelectableText(
                  _application,
                  style: const TextStyle(
                      fontSize: 13, height: 1.6, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                      ClipboardData(text: _application));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_hi
                          ? 'आवेदन कॉपी हो गया'
                          : 'Application copied'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_all_outlined),
                label: Text(_hi ? 'आवेदन कॉपी करें' : 'Copy the application'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse('https://rtionline.gov.in/'),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new),
                label: Text(_hi
                    ? 'ऑनलाइन दाख़िल करें (केंद्र सरकार)'
                    : 'File it online (central government)'),
              ),
              const SizedBox(height: 14),
              Text(
                _hi
                    ? 'डाक से भेज रहे हों तो रजिस्टर्ड डाक से भेजें और रसीद '
                        'संभालकर रखें। वही साबित करती है कि तीस दिन कब से गिने '
                        'जाएँ।'
                    : 'If you post it, send it by registered post and keep '
                        'the receipt. That is what proves when the thirty '
                        'days started.',
                style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int lines;
  final VoidCallback onChanged;

  const _Field({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.hint,
    this.lines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: lines,
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: lines > 1,
        ),
      ),
    );
  }
}
