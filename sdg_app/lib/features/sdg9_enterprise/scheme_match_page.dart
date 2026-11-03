import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n/locale_scope.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import '../../core/widgets/selection_tile.dart';
import 'scheme_match.dart';

class SchemeMatchPage extends StatefulWidget {
  const SchemeMatchPage({super.key});

  @override
  State<SchemeMatchPage> createState() => _SchemeMatchPageState();
}

class _SchemeMatchPageState extends State<SchemeMatchPage> {
  WorkKind? _work;
  UnitStage? _stage;
  NeedBand? _need;
  FounderCategory? _category;
  UdyamStatus? _udyam;

  bool get _hi => Localizations.localeOf(context).languageCode == 'hi';

  bool get _complete =>
      _work != null &&
      _stage != null &&
      _need != null &&
      _category != null &&
      _udyam != null;

  SchemeResult? get _result => !_complete
      ? null
      : matchSchemes(
          work: _work!,
          stage: _stage!,
          need: _need!,
          category: _category!,
          udyam: _udyam!,
        );

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;
    final result = _result;

    return Scaffold(
      appBar: AppBar(
        title: Text(_hi
            ? 'कौन सी योजना पूछें?'
            : 'Which scheme to ask about?'),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(9)),
        ),
      ),
      body: ContentShell(
        maxWidth: 660,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
          children: [
            _Q(_hi ? 'आप क्या काम करते हैं?' : 'What is the work?'),
            SelectionTile(
              label: _hi
                  ? 'रेहड़ी, ठेला या फेरी'
                  : 'Street vending, a cart or hawking',
              selected: _work == WorkKind.streetVending,
              onTap: () => setState(() => _work = WorkKind.streetVending),
            ),
            SelectionTile(
              label: _hi
                  ? 'दुकान या सेवा का काम'
                  : 'A shop, or a service business',
              subtitle: _hi
                  ? 'किराना, दर्ज़ी, मरम्मत, सैलून, ढाबा'
                  : 'Grocery, tailoring, repairs, salon, eatery',
              selected: _work == WorkKind.shopOrService,
              onTap: () => setState(() => _work = WorkKind.shopOrService),
            ),
            SelectionTile(
              label: _hi ? 'कुछ बनाने का काम' : 'Making something',
              subtitle: _hi
                  ? 'कारख़ाना, हस्तशिल्प, खाद्य प्रसंस्करण'
                  : 'Workshop, crafts, food processing',
              selected: _work == WorkKind.manufacturing,
              onTap: () => setState(() => _work = WorkKind.manufacturing),
            ),
            SelectionTile(
              label: _hi
                  ? 'खेती से जुड़ा काम'
                  : 'Work allied to farming',
              subtitle: _hi
                  ? 'डेयरी, मुर्गीपालन, मधुमक्खी, मछली'
                  : 'Dairy, poultry, beekeeping, fishery',
              selected: _work == WorkKind.alliedAgri,
              onTap: () => setState(() => _work = WorkKind.alliedAgri),
            ),

            if (_work != null) ...[
              const SizedBox(height: 20),
              _Q(_hi
                  ? 'काम पहले से चल रहा है या नया शुरू करना है?'
                  : 'Is it already running, or are you starting it?'),
              // This is the question that decides whether a subsidy is on
              // the table at all, so it is asked plainly rather than
              // inferred from anything else.
              SelectionTile(
                label: _hi ? 'नया शुरू करना है' : 'Starting it new',
                selected: _stage == UnitStage.newUnit,
                onTap: () => setState(() => _stage = UnitStage.newUnit),
              ),
              SelectionTile(
                label: _hi ? 'पहले से चल रहा है' : 'Already running',
                selected: _stage == UnitStage.existingUnit,
                onTap: () =>
                    setState(() => _stage = UnitStage.existingUnit),
              ),
            ],

            if (_stage != null) ...[
              const SizedBox(height: 20),
              _Q(_hi ? 'कितने पैसे की ज़रूरत है?' : 'How much do you need?'),
              SelectionTile(
                label: _hi ? '50,000 रुपये तक' : 'Up to Rs 50,000',
                selected: _need == NeedBand.upto50k,
                onTap: () => setState(() => _need = NeedBand.upto50k),
              ),
              SelectionTile(
                label: _hi ? '50,000 से 5 लाख' : 'Rs 50,000 to 5 lakh',
                selected: _need == NeedBand.upto5L,
                onTap: () => setState(() => _need = NeedBand.upto5L),
              ),
              SelectionTile(
                label: _hi ? '5 लाख से 10 लाख' : 'Rs 5 lakh to 10 lakh',
                selected: _need == NeedBand.upto10L,
                onTap: () => setState(() => _need = NeedBand.upto10L),
              ),
              SelectionTile(
                label: _hi ? '10 लाख से ज़्यादा' : 'More than Rs 10 lakh',
                selected: _need == NeedBand.above10L,
                onTap: () => setState(() => _need = NeedBand.above10L),
              ),
            ],

            if (_need != null) ...[
              const SizedBox(height: 20),
              _Q(_hi
                  ? 'क्या आवेदक अनुसूचित जाति, अनुसूचित जनजाति या महिला है?'
                  : 'Is the applicant SC, ST, or a woman?'),
              _Note(
                text: _hi
                    ? 'यह सवाल इसलिए है कि कुछ योजनाओं में इन श्रेणियों के '
                        'लिए ज़्यादा सब्सिडी है, और स्टैंड-अप इंडिया इन्हीं '
                        'के लिए है।'
                    : 'Asked because some schemes give a larger subsidy to '
                        'these categories, and Stand-Up India is only for '
                        'them.',
              ),
              SelectionTile(
                label: _hi ? 'हाँ' : 'Yes',
                selected: _category == FounderCategory.scStOrWoman,
                onTap: () => setState(
                    () => _category = FounderCategory.scStOrWoman),
              ),
              SelectionTile(
                label: _hi ? 'नहीं' : 'No',
                selected: _category == FounderCategory.general,
                onTap: () =>
                    setState(() => _category = FounderCategory.general),
              ),
            ],

            if (_category != null) ...[
              const SizedBox(height: 20),
              _Q(_hi
                  ? 'उद्यम पंजीकरण है?'
                  : 'Do you have Udyam registration?'),
              SelectionTile(
                label: _hi ? 'हाँ, है' : 'Yes',
                selected: _udyam == UdyamStatus.registered,
                onTap: () =>
                    setState(() => _udyam = UdyamStatus.registered),
              ),
              SelectionTile(
                label: _hi ? 'नहीं' : 'No',
                selected: _udyam == UdyamStatus.notRegistered,
                onTap: () =>
                    setState(() => _udyam = UdyamStatus.notRegistered),
              ),
              SelectionTile(
                label: _hi ? 'पता नहीं' : 'I do not know',
                selected: _udyam == UdyamStatus.doNotKnow,
                onTap: () =>
                    setState(() => _udyam = UdyamStatus.doNotKnow),
              ),
            ],

            if (result != null) ...[
              const SizedBox(height: 26),
              if (result.udyamFirst) _UdyamFirst(hi: _hi),
              _Heading(_hi ? 'इनके बारे में पूछें' : 'Ask about these'),
              ...result.matches.map((m) => _MatchCard(match: m, hi: _hi)),
              if (result.excluded.isNotEmpty) ...[
                const SizedBox(height: 10),
                _Heading(_hi
                    ? 'ये आप पर लागू नहीं होतीं'
                    : 'These do not apply to you'),
                ...result.excluded.map((e) => _ExcludedCard(ex: e, hi: _hi)),
              ],
              const SizedBox(height: 18),
              _NotApproval(hi: _hi),
            ],
          ],
        ),
      ),
    );
  }
}

class _Q extends StatelessWidget {
  final String text;
  const _Q(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: const TextStyle(
                fontSize: 15.5, fontWeight: FontWeight.w700, height: 1.35)),
      );
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Text(text.toUpperCase(),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: Theme.of(context).colorScheme.primary,
            )),
      );
}

class _Note extends StatelessWidget {
  final String text;
  const _Note({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}

class _UdyamFirst extends StatelessWidget {
  final bool hi;
  const _UdyamFirst({required this.hi});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.badge_outlined,
                  size: 20, color: scheme.onPrimaryContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hi
                      ? 'पहले उद्यम पंजीकरण कराएँ — यह मुफ़्त है'
                      : 'Get Udyam registration first — it is free',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: scheme.onPrimaryContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hi
                ? 'लगभग हर योजना इसी पहचान को जाँचती है। मंत्रालय कहता है कि '
                    'udyamregistration.gov.in ही आधिकारिक साइट है और कोई '
                    'शुल्क नहीं है। आधार और पैन से एक दोपहर में हो जाता है।'
                : 'Almost every scheme checks for it. The ministry states '
                    'that udyamregistration.gov.in is the only official site '
                    'and that there is no fee. Aadhaar and PAN, and an '
                    'afternoon.',
            style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: scheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final SchemeMatch match;
  final bool hi;

  const _MatchCard({required this.match, required this.hi});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final condition = hi ? match.conditionHi : match.condition;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (match.primary)
                  Container(
                    margin: const EdgeInsets.only(right: 8, top: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      hi ? 'पहले यह' : 'START HERE',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: scheme.onPrimary),
                    ),
                  ),
                Expanded(
                  child: Text(
                    hi ? match.nameHi : match.name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.25),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(hi ? match.whyHi : match.why,
                style: const TextStyle(fontSize: 13.5, height: 1.55)),
            if (condition != null && condition.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: scheme.onSecondaryContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(condition,
                          style: TextStyle(
                              fontSize: 12.5,
                              height: 1.45,
                              color: scheme.onSecondaryContainer)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 6),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await launchUrl(Uri.parse(match.portal),
                        mode: LaunchMode.externalApplication);
                  } catch (_) {
                    messenger.showSnackBar(const SnackBar(
                        content: Text('Could not open link')));
                  }
                },
                icon: const Icon(Icons.open_in_new, size: 15),
                label: Text(
                  hi ? 'आधिकारिक पोर्टल खोलें' : 'Open the official portal',
                  style: const TextStyle(fontSize: 12.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Named rather than silently dropped.
///
/// Someone who has heard of PMEGP from a neighbour needs to be told why it
/// is not on their list, or they will assume the app missed it and go to an
/// agent who tells them what they want to hear.
class _ExcludedCard extends StatelessWidget {
  final SchemeExclusion ex;
  final bool hi;

  const _ExcludedCard({required this.ex, required this.hi});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hi ? ex.nameHi : ex.name,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant)),
          const SizedBox(height: 5),
          Text(hi ? ex.reasonHi : ex.reason,
              style: TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _NotApproval extends StatelessWidget {
  final bool hi;
  const _NotApproval({required this.hi});

  @override
  Widget build(BuildContext context) {
    final tone = Colors.orange.shade800;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 20, color: tone),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hi
                      ? 'यह स्वीकृति नहीं है'
                      : 'This is not an approval',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: tone),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hi
                ? 'यह बताता है कि किस योजना के बारे में पूछना है, यह नहीं कि '
                    'ऋण मिलेगा। वह बैंक आपके काग़ज़ और चुकाने की क्षमता देखकर '
                    'तय करता है। कोई एजेंट, सलाहकार या बिचौलिया स्वीकृति का '
                    'वादा नहीं कर सकता — जो पहले फ़ीस माँगे, वह उस चीज़ के '
                    'पैसे ले रहा है जो वह दे नहीं सकता। उद्यम पंजीकरण मुफ़्त '
                    'है और बैंक अपने शुल्क स्वीकृति के बाद ऋण से काटते हैं।'
                : 'This tells you which scheme to ask about, not that you '
                    'will get a loan. The bank decides that on your papers '
                    'and your ability to repay. No agent, consultant or '
                    'middleman can promise a sanction, so anyone asking for '
                    'a fee up front is charging for something they cannot '
                    'deliver. Udyam registration is free, and banks deduct '
                    'their own charges from the loan after sanction.',
            style: const TextStyle(fontSize: 13, height: 1.55),
          ),
        ],
      ),
    );
  }
}
