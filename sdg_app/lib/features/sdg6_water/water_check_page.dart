import 'package:flutter/material.dart';

import '../../core/i18n/locale_scope.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import '../../core/widgets/selection_tile.dart';
import 'water_check.dart';

class WaterCheckPage extends StatefulWidget {
  const WaterCheckPage({super.key});

  @override
  State<WaterCheckPage> createState() => _WaterCheckPageState();
}

class _WaterCheckPageState extends State<WaterCheckPage> {
  WaterSource? _source;
  WaterLook? _look;
  WaterTested? _tested;
  AreaProblem? _area;
  bool? _illness;
  bool? _sewage;

  bool get _hi => Localizations.localeOf(context).languageCode == 'hi';

  bool get _complete =>
      _source != null &&
      _look != null &&
      _tested != null &&
      _area != null &&
      _illness != null &&
      _sewage != null;

  WaterAnswer? get _answer => !_complete
      ? null
      : assessWater(
          source: _source!,
          look: _look!,
          tested: _tested!,
          area: _area!,
          illnessInHouse: _illness!,
          sewageOrFloodNearby: _sewage!,
        );

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;
    final answer = _answer;

    return Scaffold(
      appBar: AppBar(
        title: Text(_hi ? 'क्या मेरा पानी सुरक्षित है?' : 'Is my water safe?'),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(6)),
        ),
      ),
      body: ContentShell(
        maxWidth: 640,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
          children: [
            _Q(_hi
                ? 'पीने का पानी कहाँ से आता है?'
                : 'Where does your drinking water come from?'),
            SelectionTile(
              label: _hi ? 'घर का नल (पाइप से)' : 'Tap at home (piped supply)',
              selected: _source == WaterSource.pipedTap,
              onTap: () => setState(() => _source = WaterSource.pipedTap),
            ),
            SelectionTile(
              label: _hi ? 'हैंडपंप या बोरवेल' : 'Handpump or borewell',
              selected: _source == WaterSource.handpumpBorewell,
              onTap: () =>
                  setState(() => _source = WaterSource.handpumpBorewell),
            ),
            SelectionTile(
              label: _hi ? 'खुला कुआँ' : 'Open well',
              selected: _source == WaterSource.openWell,
              onTap: () => setState(() => _source = WaterSource.openWell),
            ),
            SelectionTile(
              label: _hi ? 'टैंकर या पानी की गाड़ी' : 'Tanker or water cart',
              selected: _source == WaterSource.tanker,
              onTap: () => setState(() => _source = WaterSource.tanker),
            ),
            SelectionTile(
              label: _hi
                  ? 'नदी, तालाब, नहर या झरना'
                  : 'River, pond, canal or stream',
              selected: _source == WaterSource.surfaceWater,
              onTap: () => setState(() => _source = WaterSource.surfaceWater),
            ),

            if (_source != null) ...[
              const SizedBox(height: 20),
              _Q(_hi
                  ? 'पानी कैसा दिखता और सूँघता है?'
                  : 'How does the water look and smell?'),
              SelectionTile(
                label: _hi ? 'साफ़, कोई गंध नहीं' : 'Clear, no smell',
                selected: _look == WaterLook.clear,
                onTap: () => setState(() => _look = WaterLook.clear),
              ),
              SelectionTile(
                label: _hi ? 'धुँधला या मैला' : 'Cloudy or muddy',
                selected: _look == WaterLook.cloudy,
                onTap: () => setState(() => _look = WaterLook.cloudy),
              ),
              SelectionTile(
                label: _hi
                    ? 'रंग बदला हुआ, या गंध या स्वाद आता है'
                    : 'Coloured, or it smells or tastes of something',
                selected: _look == WaterLook.colouredOrSmelly,
                onTap: () =>
                    setState(() => _look = WaterLook.colouredOrSmelly),
              ),
            ],

            if (_look != null) ...[
              const SizedBox(height: 20),
              _Q(_hi
                  ? 'इस पानी की कभी जाँच हुई है?'
                  : 'Has this water ever been tested?'),
              SelectionTile(
                label: _hi ? 'कभी नहीं' : 'Never',
                selected: _tested == WaterTested.never,
                onTap: () => setState(() => _tested = WaterTested.never),
              ),
              SelectionTile(
                label: _hi
                    ? 'हाँ — कुछ ग़लत नहीं मिला'
                    : 'Yes — nothing wrong was found',
                selected: _tested == WaterTested.testedSafe,
                onTap: () =>
                    setState(() => _tested = WaterTested.testedSafe),
              ),
              SelectionTile(
                label: _hi
                    ? 'हाँ — कोई समस्या मिली थी'
                    : 'Yes — a problem was found',
                selected: _tested == WaterTested.testedProblem,
                onTap: () =>
                    setState(() => _tested = WaterTested.testedProblem),
              ),
            ],

            if (_tested != null) ...[
              const SizedBox(height: 20),
              _Q(_hi
                  ? 'क्या आपके इलाक़े में आर्सेनिक या फ़्लोराइड की समस्या है?'
                  : 'Is your area known to have arsenic or fluoride?'),
              // "Don't know" is offered first and is the honest answer for
              // most people. Hiding it would push them into a guess, and a
              // wrong "no" here is the one that does lasting harm.
              SelectionTile(
                label: _hi ? 'पता नहीं' : 'I do not know',
                subtitle: _hi
                    ? 'पंचायत और पड़ोसी अक्सर जानते हैं'
                    : 'The Panchayat and neighbours usually know',
                selected: _area == AreaProblem.dontKnow,
                onTap: () => setState(() => _area = AreaProblem.dontKnow),
              ),
              SelectionTile(
                label: _hi ? 'हाँ — आर्सेनिक' : 'Yes — arsenic',
                selected: _area == AreaProblem.arsenic,
                onTap: () => setState(() => _area = AreaProblem.arsenic),
              ),
              SelectionTile(
                label: _hi ? 'हाँ — फ़्लोराइड' : 'Yes — fluoride',
                selected: _area == AreaProblem.fluoride,
                onTap: () => setState(() => _area = AreaProblem.fluoride),
              ),
              SelectionTile(
                label: _hi ? 'हाँ — लोहा (लाल-भूरा पानी)' : 'Yes — iron',
                subtitle: _hi
                    ? 'कपड़ों और बर्तनों पर दाग़'
                    : 'Stains clothes and vessels',
                selected: _area == AreaProblem.iron,
                onTap: () => setState(() => _area = AreaProblem.iron),
              ),
              SelectionTile(
                label: _hi
                    ? 'नहीं — जाँच में कुछ नहीं मिला'
                    : 'No — tests have shown none',
                selected: _area == AreaProblem.none,
                onTap: () => setState(() => _area = AreaProblem.none),
              ),
            ],

            if (_area != null) ...[
              const SizedBox(height: 20),
              _Q(_hi
                  ? 'पिछले दो हफ़्तों में घर में किसी को दस्त, उल्टी या पीलिया हुआ?'
                  : 'In the last two weeks, has anyone at home had diarrhoea, vomiting or jaundice?'),
              SelectionTile(
                label: _hi ? 'नहीं' : 'No',
                selected: _illness == false,
                onTap: () => setState(() => _illness = false),
              ),
              SelectionTile(
                label: _hi ? 'हाँ' : 'Yes',
                selected: _illness == true,
                onTap: () => setState(() => _illness = true),
              ),
            ],

            if (_illness != null) ...[
              const SizedBox(height: 20),
              _Q(_hi
                  ? 'स्रोत के पास नाली, शौचालय का रिसाव, या हाल में बाढ़?'
                  : 'Any drain, toilet seepage, or recent flooding near the source?'),
              SelectionTile(
                label: _hi ? 'नहीं' : 'No',
                selected: _sewage == false,
                onTap: () => setState(() => _sewage = false),
              ),
              SelectionTile(
                label: _hi ? 'हाँ' : 'Yes',
                selected: _sewage == true,
                onTap: () => setState(() => _sewage = true),
              ),
            ],

            if (answer != null) ...[
              const SizedBox(height: 26),
              _Result(answer: answer, hi: _hi),
            ],

            const SizedBox(height: 26),
            _Disclaimer(hi: _hi),
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
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 15.5, fontWeight: FontWeight.w700, height: 1.35),
        ),
      );
}

class _Result extends StatelessWidget {
  final WaterAnswer answer;
  final bool hi;

  const _Result({required this.answer, required this.hi});

  /// Colour carries the same meaning as the words, never instead of them.
  /// A chemical verdict is red not because the water is dirty but because
  /// the usual response to it does not work.
  Color get _tone => switch (answer.verdict) {
        WaterVerdict.chemical => Colors.red.shade700,
        WaterVerdict.both => Colors.red.shade700,
        WaterVerdict.microbial => Colors.orange.shade800,
        WaterVerdict.untested => Colors.amber.shade800,
        WaterVerdict.nothingVisible => Colors.green.shade700,
      };

  IconData get _icon => switch (answer.verdict) {
        WaterVerdict.chemical => Icons.science_outlined,
        WaterVerdict.both => Icons.warning_amber_rounded,
        WaterVerdict.microbial => Icons.local_fire_department_outlined,
        WaterVerdict.untested => Icons.help_outline,
        WaterVerdict.nothingVisible => Icons.check_circle_outline,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tone = _tone;
    final steps = hi ? answer.stepsHi : answer.steps;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_icon, color: tone, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hi ? answer.headlineHi : answer.headline,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    color: tone,
                  ),
                ),
              ),
            ],
          ),

          // The correction gets its own block rather than a bullet. For
          // someone who has been boiling faithfully for years, this is the
          // single most important sentence on the screen.
          if (answer.boilingWillNotHelp) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.block, size: 18, color: tone),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      hi
                          ? 'उबालने से रसायन नहीं निकलते। चाहे कितनी देर उबालें।'
                          : 'Boiling removes no chemicals. However long you boil it.',
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                        color: tone,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          Text(
            hi ? answer.reasonHi : answer.reason,
            style: const TextStyle(fontSize: 14, height: 1.55),
          ),
          const SizedBox(height: 16),
          Text(
            hi ? 'क्या करें' : 'What to do',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...steps.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 10),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration:
                          BoxDecoration(color: tone, shape: BoxShape.circle),
                    ),
                  ),
                  Expanded(
                    child: Text(s,
                        style: const TextStyle(fontSize: 13.5, height: 1.5)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  final bool hi;
  const _Disclaimer({required this.hi});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        hi
            ? 'यह जाँच आपके जवाबों पर आधारित है, पानी की जाँच पर नहीं। यह ऐप '
                'यह नहीं बता सकता कि आपका पानी सुरक्षित है — आर्सेनिक जैसे '
                'रसायन दिखते या सूँघे नहीं जा सकते। सिर्फ़ प्रयोगशाला जाँच '
                'बता सकती है।'
            : 'This check works from your answers, not from a water test. '
                'The app cannot tell you your water is safe — chemicals like '
                'arsenic cannot be seen or smelled. Only a laboratory test '
                'can tell you that.',
        style: TextStyle(
          fontSize: 12.5,
          height: 1.45,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
