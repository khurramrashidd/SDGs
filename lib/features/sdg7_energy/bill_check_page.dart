import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/i18n/locale_scope.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import 'bill_check.dart';

class BillCheckPage extends StatefulWidget {
  const BillCheckPage({super.key});

  @override
  State<BillCheckPage> createState() => _BillCheckPageState();
}

class _BillCheckPageState extends State<BillCheckPage> {
  final _previous = TextEditingController();
  final _current = TextEditingController();
  final _units = TextEditingController();
  final _amount = TextEditingController();
  final _usual = TextEditingController();
  bool _estimated = false;

  bool get _hi => Localizations.localeOf(context).languageCode == 'hi';

  @override
  void initState() {
    super.initState();
    for (final c in [_previous, _current, _units, _amount, _usual]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_previous, _current, _units, _amount, _usual]) {
      c.dispose();
    }
    super.dispose();
  }

  int? _int(TextEditingController c) => int.tryParse(c.text.trim());
  double? _num(TextEditingController c) => double.tryParse(c.text.trim());

  /// The amount and the usual-units box are optional: the subtraction check
  /// is the valuable one and it must not be gated behind fields someone
  /// cannot find on their bill.
  bool get _ready =>
      _int(_previous) != null && _int(_current) != null && _int(_units) != null;

  BillReport? get _report => !_ready
      ? null
      : checkBill(
          previousReading: _int(_previous)!,
          currentReading: _int(_current)!,
          unitsBilled: _int(_units)!,
          amount: _num(_amount) ?? 0,
          markedEstimated: _estimated,
          usualUnits: _int(_usual),
        );

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;
    final report = _report;

    return Scaffold(
      appBar: AppBar(
        title: Text(_hi ? 'क्या मेरा बिल सही है?' : 'Is my bill right?'),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(7)),
        ),
      ),
      body: ContentShell(
        maxWidth: 640,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
          children: [
            _Scope(hi: _hi),
            const SizedBox(height: 20),

            _Field(
              controller: _previous,
              label: _hi ? 'पिछली रीडिंग' : 'Previous reading',
              hint: _hi ? 'बिल पर छपी हुई' : 'As printed on the bill',
            ),
            _Field(
              controller: _current,
              label: _hi ? 'वर्तमान रीडिंग' : 'Current reading',
              hint: _hi ? 'बिल पर छपी हुई' : 'As printed on the bill',
            ),
            _Field(
              controller: _units,
              label: _hi ? 'बिल में लगाई गई यूनिट' : 'Units billed',
              hint: _hi
                  ? 'जितनी यूनिट का चार्ज किया गया'
                  : 'The number they charged you for',
            ),
            _Field(
              controller: _amount,
              label: _hi ? 'कुल रक़म (ज़रूरी नहीं)' : 'Total amount (optional)',
              hint: _hi ? 'रुपये में' : 'In rupees',
              decimal: true,
            ),
            _Field(
              controller: _usual,
              label: _hi
                  ? 'आम तौर पर कितनी यूनिट (ज़रूरी नहीं)'
                  : 'Your usual units a month (optional)',
              hint: _hi
                  ? 'सामान्य महीनों में'
                  : 'In an ordinary month',
            ),

            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _estimated,
              onChanged: (v) => setState(() => _estimated = v),
              title: Text(
                _hi
                    ? 'बिल पर "अनुमानित", "औसत" या "प्रोविज़नल" लिखा है'
                    : 'The bill says "estimated", "average" or "provisional"',
                style: const TextStyle(fontSize: 14, height: 1.35),
              ),
            ),

            if (report != null) ...[
              const SizedBox(height: 20),
              _Arithmetic(report: report, hi: _hi),
              const SizedBox(height: 14),
              ...report.decisive.map(
                (f) => _FindingCard(finding: f, hi: _hi),
              ),
              ...report.questions.map(
                (f) => _FindingCard(finding: f, hi: _hi),
              ),
              if (report.findings.isEmpty) _AllClear(hi: _hi),
              const SizedBox(height: 14),
              if (report.decisive.isNotEmpty) _CopyComplaint(report: report, hi: _hi),
            ],
          ],
        ),
      ),
    );
  }
}

/// States the limit of the tool before the user enters anything, not after.
///
/// Someone who reads the verdict first and the caveat second has already
/// decided the app told them their bill was wrong.
class _Scope extends StatelessWidget {
  final bool hi;
  const _Scope({required this.hi});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hi ? 'यह क्या जाँच सकता है' : 'What this can check',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, height: 1.3),
          ),
          const SizedBox(height: 6),
          Text(
            hi
                ? 'यह गणित जाँचता है, टैरिफ़ नहीं। यह साबित कर सकता है कि बिल '
                    'पर लिखी रीडिंग और लगाई गई यूनिट मेल नहीं खातीं — वह घटाव '
                    'है। यह नहीं बता सकता कि आपसे ज़्यादा वसूला गया, क्योंकि '
                    'उसके लिए आपके राज्य की टैरिफ़ दरें चाहिए जो हर साल बदलती '
                    'हैं। "आपका बिल सही है" यह ऐप कभी नहीं कहेगा।'
                : 'This checks arithmetic, not tariff. It can prove that the '
                    'readings printed on your bill do not match the units it '
                    'charged you for, because that is subtraction. It cannot '
                    'tell you that you were overcharged — that needs your '
                    'state tariff rates, which change every year. It will '
                    'never tell you your bill is correct.',
            style: TextStyle(
                fontSize: 12.5, height: 1.5, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool decimal;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.decimal = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: controller,
          keyboardType: decimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                decimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]')),
          ],
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
      );
}

/// Shows the subtraction itself, so the user can see the check rather than
/// trust it. Someone standing at a counter needs to be able to repeat the
/// argument without the phone.
class _Arithmetic extends StatelessWidget {
  final BillReport report;
  final bool hi;

  const _Arithmetic({required this.report, required this.hi});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final matches = report.unitsFromReadings == report.unitsBilled;
    final tone = matches ? Colors.green.shade700 : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.withValues(alpha: 0.45), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hi ? 'घटाव' : 'The subtraction',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${report.unitsFromReadings} '
            '${hi ? "यूनिट रीडिंग से" : "units from the readings"}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          Text(
            '${report.unitsBilled} '
            '${hi ? "यूनिट का चार्ज" : "units billed"}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            matches
                ? (hi ? 'ये मेल खाती हैं।' : 'These match.')
                : (hi
                    ? 'ये मेल नहीं खातीं।'
                    : 'These do not match.'),
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: tone),
          ),
          if (report.effectiveRatePerUnit != null) ...[
            const SizedBox(height: 10),
            Text(
              hi
                  ? 'रक़म ÷ यूनिट = ₹${report.effectiveRatePerUnit!.toStringAsFixed(2)} '
                      'प्रति यूनिट। इसमें फ़िक्स्ड चार्ज और ड्यूटी शामिल है, '
                      'यह टैरिफ़ दर नहीं है।'
                  : 'Amount ÷ units = ₹${report.effectiveRatePerUnit!.toStringAsFixed(2)} '
                      'per unit. This includes fixed charges and duty, so it '
                      'is not the tariff rate.',
              style: TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class _FindingCard extends StatelessWidget {
  final BillFinding finding;
  final bool hi;

  const _FindingCard({required this.finding, required this.hi});

  @override
  Widget build(BuildContext context) {
    final tone = finding.decisive
        ? Colors.red.shade700
        : Colors.orange.shade800;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                finding.decisive
                    ? Icons.error_outline
                    : Icons.help_outline,
                size: 20,
                color: tone,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hi ? finding.titleHi : finding.title,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: tone),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hi ? finding.detailHi : finding.detail,
            style: const TextStyle(fontSize: 13.5, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _AllClear extends StatelessWidget {
  final bool hi;
  const _AllClear({required this.hi});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        hi
            ? 'गणित सही बैठता है। इसका मतलब यह नहीं कि बिल पूरी तरह सही है — '
                'स्लैब या श्रेणी ग़लत लग सकती है, और वह इस जाँच से बाहर है। '
                'शक हो तो ब्रेकअप माँगें और अपनी श्रेणी के टैरिफ़ कार्ड से '
                'मिलाएँ।'
            : 'The arithmetic adds up. That does not mean the bill is '
                'correct — the slab or the category could still be wrong, '
                'and that is outside what this can check. If you have a '
                'doubt, ask for the breakup and compare it with the tariff '
                'card for your category.',
        style: TextStyle(
            fontSize: 13, height: 1.5, color: scheme.onSurfaceVariant),
      ),
    );
  }
}

/// Turns a decisive finding into text the user can hand over or paste.
///
/// Nothing is uploaded. The same principle as the RTI builder: the value is
/// in the wording, and the wording is produced on the device.
class _CopyComplaint extends StatelessWidget {
  final BillReport report;
  final bool hi;

  const _CopyComplaint({required this.report, required this.hi});

  String _text() {
    final lines = <String>[
      hi ? 'विषय: बिल में त्रुटि की शिकायत' : 'Subject: Complaint about an error in my bill',
      '',
      hi
          ? 'महोदय/महोदया,'
          : 'Sir / Madam,',
      '',
      hi
          ? 'मेरे बिजली बिल में निम्नलिखित त्रुटि है:'
          : 'My electricity bill carries the following error:',
      '',
    ];
    for (final f in report.decisive) {
      lines.add('- ${hi ? f.titleHi : f.title}');
    }
    lines.addAll([
      '',
      hi
          ? 'बिल पर छपी रीडिंग के अनुसार ${report.unitsFromReadings} यूनिट '
              'बनती हैं, और चार्ज ${report.unitsBilled} यूनिट का किया गया है।'
          : 'By the readings printed on the bill the consumption is '
              '${report.unitsFromReadings} units, and I have been charged for '
              '${report.unitsBilled} units.',
      '',
      hi
          ? 'कृपया बिल की जाँच कर संशोधित बिल जारी करें, और इस शिकायत की '
              'रसीद या डॉकेट नंबर दें।'
          : 'Please examine the bill, issue a corrected one, and give me an '
              'acknowledgement or docket number for this complaint.',
      '',
      hi
          ? '(उपभोक्ता संख्या, नाम, पता और तारीख़ यहाँ भरें)'
          : '(Fill in your consumer number, name, address and the date here)',
    ]);
    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: OutlinedButton.icon(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            await Clipboard.setData(ClipboardData(text: _text()));
            messenger.showSnackBar(SnackBar(
              content: Text(hi
                  ? 'कॉपी हो गया — उपभोक्ता संख्या और तारीख़ भरकर दें'
                  : 'Copied — fill in your consumer number and the date'),
            ));
          },
          icon: const Icon(Icons.copy_all_outlined, size: 18),
          label: Text(hi ? 'शिकायत का मसौदा कॉपी करें' : 'Copy a complaint draft'),
        ),
      );
}
