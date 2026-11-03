import 'package:flutter/material.dart';

import '../../core/i18n/locale_scope.dart';
import '../../core/layout/responsive.dart';
import '../../core/theme/brand.dart';
import '../../core/widgets/selection_tile.dart';
import 'food_board.dart';
import 'food_board_page.dart';
import 'share_check.dart';

class ShareCheckPage extends StatefulWidget {
  const ShareCheckPage({super.key});

  @override
  State<ShareCheckPage> createState() => _ShareCheckPageState();
}

class _ShareCheckPageState extends State<ShareCheckPage> {
  FoodKind? _kind;
  HeldAt? _held;
  double? _hours;
  bool? _served;
  bool _hotWeather = true;

  bool get _hi => Localizations.localeOf(context).languageCode == 'hi';

  bool get _needsTimeAndTemp =>
      _kind == FoodKind.cookedHighRisk || _kind == FoodKind.cookedLowRisk;

  bool get _complete {
    if (_kind == null || _served == null) return false;
    if (_served == true) return true;
    if (!_needsTimeAndTemp) return true;
    return _held != null && _hours != null;
  }

  ShareAnswer? get _answer => !_complete
      ? null
      : assessFood(
          kind: _kind!,
          heldAt: _held ?? HeldAt.roomTemp,
          hoursOld: _hours ?? 0,
          alreadyServed: _served!,
          hotWeather: _hotWeather,
        );

  @override
  Widget build(BuildContext context) {
    final pad = context.pagePadding;
    final answer = _answer;

    return Scaffold(
      appBar: AppBar(
        title: Text(_hi ? 'क्या यह बाँटा जा सकता है?' : 'Can this be shared?'),
        actions: const [SectionLanguageButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: SdgColors.of(2)),
        ),
      ),
      body: ContentShell(
        maxWidth: 640,
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 36),
          children: [
            _Q(_hi ? 'यह किस तरह का खाना है?' : 'What kind of food is it?'),
            SelectionTile(
              label: _hi
                  ? 'पका हुआ — चावल, माँस, मछली, अंडा, पनीर, कटे फल'
                  : 'Cooked — rice, meat, fish, egg, paneer, cut fruit',
              selected: _kind == FoodKind.cookedHighRisk,
              onTap: () => setState(() => _kind = FoodKind.cookedHighRisk),
            ),
            SelectionTile(
              label: _hi
                  ? 'पका हुआ — रोटी, सूखी सब्ज़ी, पूरी, बेक किया हुआ'
                  : 'Cooked — roti, dry sabzi, puri, baked items',
              selected: _kind == FoodKind.cookedLowRisk,
              onTap: () => setState(() => _kind = FoodKind.cookedLowRisk),
            ),
            SelectionTile(
              label: _hi
                  ? 'सीलबंद पैकेट — बिस्कुट, अनाज, दाल'
                  : 'Sealed packets — biscuits, grains, pulses',
              selected: _kind == FoodKind.packagedSealed,
              onTap: () => setState(() => _kind = FoodKind.packagedSealed),
            ),
            SelectionTile(
              label: _hi
                  ? 'कच्ची सब्ज़ी या फल'
                  : 'Raw vegetables or fruit',
              selected: _kind == FoodKind.rawProduce,
              onTap: () => setState(() => _kind = FoodKind.rawProduce),
            ),

            if (_kind != null) ...[
              const SizedBox(height: 20),
              _Q(_hi
                  ? 'क्या यह परोसा जा चुका है या बुफ़े पर रखा था?'
                  : 'Has any of it been served or stood on a buffet?'),
              SelectionTile(
                label: _hi ? 'नहीं — बर्तन में अछूता है' : 'No — untouched in the vessel',
                selected: _served == false,
                onTap: () => setState(() => _served = false),
              ),
              SelectionTile(
                label: _hi ? 'हाँ' : 'Yes',
                selected: _served == true,
                onTap: () => setState(() => _served = true),
              ),
            ],

            if (_served == false && _needsTimeAndTemp) ...[
              const SizedBox(height: 20),
              _Q(_hi ? 'पकने के बाद इसे कैसे रखा गया?' : 'How has it been kept since cooking?'),
              SelectionTile(
                label: _hi
                    ? 'कमरे के तापमान पर, ढककर'
                    : 'At room temperature, covered',
                selected: _held == HeldAt.roomTemp,
                onTap: () => setState(() => _held = HeldAt.roomTemp),
              ),
              SelectionTile(
                label: _hi
                    ? 'भाप निकलता गर्म रखा गया'
                    : 'Kept steaming hot',
                selected: _held == HeldAt.hotHeld,
                onTap: () => setState(() => _held = HeldAt.hotHeld),
              ),
              SelectionTile(
                label: _hi ? 'फ़्रिज में' : 'In the refrigerator',
                selected: _held == HeldAt.refrigerated,
                onTap: () => setState(() => _held = HeldAt.refrigerated),
              ),

              const SizedBox(height: 20),
              _Q(_hi ? 'पके कितनी देर हुई?' : 'How long since it was cooked?'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final h in const [0.5, 1.0, 2.0, 4.0, 8.0, 24.0])
                    ChoiceChip(
                      label: Text(_hoursLabel(h)),
                      selected: _hours == h,
                      onSelected: (_) => setState(() => _hours = h),
                    ),
                ],
              ),

              if (_held == HeldAt.roomTemp) ...[
                const SizedBox(height: 10),
                SwitchListTile(
                  value: _hotWeather,
                  contentPadding: EdgeInsets.zero,
                  title: Text(_hi
                      ? 'आज गर्मी है (32°C से ऊपर)'
                      : 'It is hot today (above 32°C)'),
                  subtitle: Text(
                    _hi
                        ? 'गर्मी में सुरक्षित समय आधा हो जाता है'
                        : 'Heat halves the safe window',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onChanged: (v) => setState(() => _hotWeather = v),
                ),
              ],
            ],

            if (answer != null) ...[
              const SizedBox(height: 26),
              _Verdict(answer: answer, hi: _hi),
              ..._postOption(answer),
            ],
          ],
        ),
      ),
    );
  }

  /// The only door into the food board's posting form: a yes or soon
  /// verdict with enough safe time left for a stranger to collect.
  List<Widget> _postOption(ShareAnswer answer) {
    if (answer.verdict == ShareVerdict.no) return const [];
    final hours = listingHours(
      kind: _kind!,
      heldAt: _held ?? HeldAt.roomTemp,
      hoursOld: _hours ?? 0,
      hotWeather: _hotWeather,
      verdict: answer.verdict,
    );
    if (hours == null) {
      return [
        const SizedBox(height: 14),
        Text(
          _hi
              ? 'किसी अनजान व्यक्ति के आने लायक समय नहीं बचा, इसलिए इसे बोर्ड पर '
                  'नहीं डाला जा सकता। किसी पड़ोसी या पास की संस्था को अभी फ़ोन करें।'
              : 'Too little safe time is left for a stranger to see it and '
                  'come, so it cannot go on the food board. Call a neighbour '
                  'or a nearby collection partner now.',
          style: const TextStyle(fontSize: 13.5, height: 1.45),
        ),
      ];
    }
    return [
      const SizedBox(height: 14),
      FilledButton.icon(
        onPressed: () => Navigator.of(context).push(localeScopedRoute(
          PostFoodPage(kind: _kind!, verdict: answer.verdict, hours: hours),
        )),
        icon: const Icon(Icons.campaign_outlined),
        label: Text(_hi ? 'खाना बोर्ड पर डालें' : 'Put it on the food board'),
      ),
    ];
  }

  String _hoursLabel(double h) {
    if (h < 1) return _hi ? '30 मिनट' : '30 min';
    if (h == 1) return _hi ? '1 घंटा' : '1 hour';
    if (h >= 24) return _hi ? '1 दिन से ज़्यादा' : 'More than a day';
    return _hi ? '$h घंटे' : '${h.toInt()} hours';
  }
}

class _Verdict extends StatelessWidget {
  final ShareAnswer answer;
  final bool hi;
  const _Verdict({required this.answer, required this.hi});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (bg, fg, icon) = switch (answer.verdict) {
      ShareVerdict.yes => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          Icons.check_circle_outline
        ),
      ShareVerdict.soon => (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
          Icons.timer_outlined
        ),
      ShareVerdict.no => (
          scheme.errorContainer,
          scheme.onErrorContainer,
          Icons.do_not_disturb_on_outlined
        ),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: fg, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hi ? answer.headlineHi : answer.headline,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      color: fg),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hi ? answer.reasonHi : answer.reason,
            style: TextStyle(fontSize: 14, height: 1.55, color: fg),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: fg.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              hi ? answer.actionHi : answer.action,
              style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: fg),
            ),
          ),
        ],
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
                fontSize: 15.5, fontWeight: FontWeight.w700)),
      );
}
