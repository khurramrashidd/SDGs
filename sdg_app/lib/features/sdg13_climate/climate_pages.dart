import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/guide_list_page.dart';
import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import 'climate_tools.dart';

/// SDG 13 — Climate Action.
class ClimateHomePage extends StatelessWidget {
  const ClimateHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    return ModuleHub(
      goal: 13,
      titleKey: 'sdg13_title',
      children: [
        HubHero(
          goal: 13,
          title: hi
              ? 'गर्मी में कोई बीमार? क्या करें, अभी'
              : 'Someone unwell in the heat? What to do, now',
          body: hi
              ? 'लक्षण चुनें। हम बताएँगे कि यह हीट स्ट्रोक (आपातकाल) है या थकावट, और '
                  'एम्बुलेंस आने तक क्या करें।'
              : 'Tick what you see. We tell you whether it is heat stroke — an '
                  'emergency — or exhaustion, and what to do until help comes.',
          button: hi ? 'लक्षण जाँचें' : 'Check the signs',
          icon: Icons.thermostat_outlined,
          onTap: () => pushScoped(context, const HeatCheckPage()),
        ),
        HubLabel(hi ? 'किसानों के लिए' : 'For farmers'),
        HubRow(
          icon: Icons.grass_outlined,
          title: hi
              ? 'फ़सल नुक़सान: 72 घंटे की घड़ी'
              : 'Crop damaged? The 72-hour clock',
          subtitle: hi
              ? 'फ़सल बीमा दावे की आख़िरी घड़ी और कैसे बताएँ'
              : 'Your crop insurance deadline, and how to report',
          onTap: () => pushScoped(context, const CropClockPage()),
        ),
        HubLabel(hi ? 'चेतावनी और तैयारी' : 'Warnings and readiness'),
        HubRow(
          icon: Icons.warning_amber_outlined,
          title: hi ? 'मौसम चेतावनी के रंग' : 'Weather warning colours',
          subtitle: hi
              ? 'हरा, पीला, नारंगी, लाल — और कौन से ऐप'
              : 'Green, yellow, orange, red — and which apps',
          onTap: () => pushScoped(
            context,
            const GuideListPage(
              collection: 'climate',
              category: 'alerts',
              title: 'Weather warnings',
              titleHi: 'मौसम चेतावनी',
              goal: 13,
            ),
          ),
        ),
        HubRow(
          icon: Icons.wb_sunny_outlined,
          title: hi ? 'लू से बचाव' : 'Staying safe in a heat wave',
          subtitle: hi
              ? 'बाहर काम करने वाले, बुज़ुर्ग, बच्चे'
              : 'Outdoor workers, older people, children',
          onTap: () => pushScoped(
            context,
            const GuideListPage(
              collection: 'climate',
              category: 'heat',
              title: 'Heat wave safety',
              titleHi: 'लू से बचाव',
              goal: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class HeatCheckPage extends StatefulWidget {
  const HeatCheckPage({super.key});

  @override
  State<HeatCheckPage> createState() => _HeatCheckPageState();
}

class _HeatCheckPageState extends State<HeatCheckPage> {
  final _signs = <HeatSign>{};
  bool _checked = false;

  static const _labels = {
    HeatSign.confused: ('Confused, agitated, strange behaviour or slurred speech',
        'भ्रम, बेचैनी, अजीब बर्ताव या लड़खड़ाती बोली'),
    HeatSign.collapsed: ('Fainted, unconscious, or had a fit',
        'बेहोश हुआ, होश नहीं, या दौरा पड़ा'),
    HeatSign.hotSkin: ('Skin very hot to the touch', 'त्वचा छूने में बहुत गर्म'),
    HeatSign.vomiting: ('Vomiting again and again', 'बार-बार उल्टी'),
    HeatSign.heavySweat: ('Heavy sweating, cold clammy skin',
        'बहुत पसीना, ठंडी चिपचिपी त्वचा'),
    HeatSign.dizzy: ('Dizzy, weak, very tired, headache',
        'चक्कर, कमज़ोरी, बहुत थकान, सिरदर्द'),
    HeatSign.cramps: ('Painful muscle cramps', 'मांसपेशियों में दर्द भरी ऐंठन'),
    HeatSign.thirsty: ('Very thirsty, little or dark urine',
        'बहुत प्यास, कम या गहरे रंग का पेशाब'),
  };

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final level = heatLevel(_signs);

    return ToolScaffold(
      goal: 13,
      title: hi ? 'गर्मी के लक्षण' : 'Heat illness check',
      children: [
        ToolQuestion(hi
            ? 'आप क्या देख रहे हैं? जो भी लागू हो, सब चुनें।'
            : 'What do you see? Tick everything that applies.'),
        for (final e in _labels.entries)
          CheckboxListTile(
            value: _signs.contains(e.key),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(hi ? e.value.$2 : e.value.$1),
            onChanged: (v) => setState(() {
              v == true ? _signs.add(e.key) : _signs.remove(e.key);
            }),
          ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () => setState(() => _checked = true),
          child: Text(hi ? 'क्या करें?' : 'What do I do?'),
        ),
        if (_checked && level == HeatLevel.none)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(hi
                ? 'कोई लक्षण नहीं चुना। अगर व्यक्ति ठीक नहीं लग रहा, तो छाँव में ले जाएँ, '
                    'पानी दें, और ऊपर की सूची फिर देखें।'
                : 'Nothing ticked. If the person still seems unwell, move them '
                    'to shade, give water, and look at the list again.'),
          ),
        if (_checked && level != HeatLevel.none)
          AdviceList(
            heading: switch (level) {
              HeatLevel.stroke => hi ? 'आपातकाल' : 'Emergency',
              HeatLevel.exhaustion => hi ? 'गर्मी से थकावट' : 'Heat exhaustion',
              _ => hi ? 'शुरुआती लक्षण' : 'Early signs',
            },
            items: heatAdvice(level),
          ),
      ],
    );
  }
}

class CropClockPage extends StatefulWidget {
  const CropClockPage({super.key});

  @override
  State<CropClockPage> createState() => _CropClockPageState();
}

class _CropClockPageState extends State<CropClockPage> {
  CropLoss? _loss;
  DateTime? _damaged;
  DateTime? _harvested;

  Future<void> _pickDamage() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now,
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
        context: context, initialTime: const TimeOfDay(hour: 12, minute: 0));
    setState(() => _damaged =
        DateTime(d.year, d.month, d.day, t?.hour ?? 0, t?.minute ?? 0));
  }

  Future<void> _pickHarvest() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 60)),
      lastDate: now,
    );
    if (d != null) setState(() => _harvested = d);
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;
    final fmt = DateFormat('d MMM yyyy, HH:mm');
    final needHarvest = _loss == CropLoss.postHarvest;
    final ready = _loss == CropLoss.widespread ||
        (_loss != null && _damaged != null && (!needHarvest || _harvested != null));
    final clock = ready
        ? cropClock(
            loss: _loss!,
            damagedAt: _damaged ?? DateTime.now(),
            harvestedOn: _harvested)
        : null;

    Widget loss(CropLoss l, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _loss == l,
          onTap: () => setState(() => _loss = l),
        );

    Widget? verdict;
    if (clock != null) {
      if (clock.deadline == null) {
        verdict = Text(
          hi
              ? 'पूरे इलाक़े के नुक़सान (सूखा, बड़े इलाक़े में बाढ़) का आकलन फ़सल कटाई '
                  'प्रयोगों से होता है — अलग से 72 घंटे की सूचना ज़रूरी नहीं। फिर भी बैंक या '
                  'कृषि कार्यालय को बता दें और रसीद रखें।'
              : 'Area-wide loss (drought, a flood across the whole area) is '
                  'assessed through crop-cutting surveys — no individual '
                  '72-hour report is required. Still tell your bank or the '
                  'agriculture office, and keep the receipt.',
          style: const TextStyle(height: 1.5),
        );
      } else if (!clock.covered) {
        verdict = Text(
          hi
              ? 'कटाई के बाद का नुक़सान सिर्फ़ कटाई से 14 दिन के भीतर खेत में सूख रही '
                  'फ़सल के लिए कवर है। आपकी तारीख़ें इससे बाहर लगती हैं। फिर भी 14447 पर '
                  'पूछें — तारीख़ ग़लत चुनी हो सकती है।'
              : 'Post-harvest loss is covered only for crop drying in the field '
                  'within 14 days of harvest. Your dates look outside that. Still '
                  'call 14447 to check — a date may have been picked wrongly.',
          style: TextStyle(height: 1.5, color: scheme.error),
        );
      } else {
        final left = clock.deadline!.difference(DateTime.now());
        final late = left.isNegative;
        verdict = Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: late ? scheme.errorContainer : scheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            late
                ? (hi
                    ? '72 घंटे ${fmt.format(clock.deadline!)} को पूरे हो गए। फिर भी तुरंत '
                        'बताएँ और देरी का कारण लिखें — कुछ मामलों में देर से आई सूचना पर भी '
                        'विचार होता है, पर इसकी गारंटी नहीं।'
                    : 'The 72 hours ended on ${fmt.format(clock.deadline!)}. '
                        'Report anyway, right now, and write down why it was '
                        'late — late reports are sometimes considered, but '
                        'that is not guaranteed.')
                : (hi
                    ? 'सूचना ${fmt.format(clock.deadline!)} से पहले दें — लगभग '
                        '${left.inHours} घंटे बचे हैं। आज ही करें।'
                    : 'Report before ${fmt.format(clock.deadline!)} — about '
                        '${left.inHours} hours left. Do it today.'),
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.45,
                color: late ? scheme.onErrorContainer : scheme.onPrimaryContainer),
          ),
        );
      }
    }

    return ToolScaffold(
      goal: 13,
      title: hi ? 'फ़सल नुक़सान की घड़ी' : 'Crop loss clock',
      children: [
        ToolQuestion(hi ? 'क्या हुआ?' : 'What happened?'),
        loss(CropLoss.localStanding,
            'Standing crop hit by hail, landslide, waterlogging, cloudburst or lightning fire',
            'खड़ी फ़सल पर ओले, भूस्खलन, जलभराव, बादल फटना या बिजली से आग'),
        loss(CropLoss.postHarvest,
            'Harvested crop drying in the field hit by rain, hail or cyclone',
            'खेत में सूख रही कटी फ़सल पर बारिश, ओले या चक्रवात'),
        loss(CropLoss.widespread,
            'Drought, or a flood over the whole area', 'सूखा, या पूरे इलाक़े में बाढ़'),
        if (_loss != null && _loss != CropLoss.widespread) ...[
          ToolQuestion(hi ? 'नुक़सान कब हुआ?' : 'When did the damage happen?'),
          OutlinedButton.icon(
            onPressed: _pickDamage,
            icon: const Icon(Icons.event),
            label: Text(_damaged == null
                ? (hi ? 'तारीख़ और समय चुनें' : 'Pick date and time')
                : fmt.format(_damaged!)),
          ),
        ],
        if (needHarvest) ...[
          ToolQuestion(hi ? 'कटाई कब हुई?' : 'When was it harvested?'),
          OutlinedButton.icon(
            onPressed: _pickHarvest,
            icon: const Icon(Icons.event_available),
            label: Text(_harvested == null
                ? (hi ? 'तारीख़ चुनें' : 'Pick the date')
                : DateFormat('d MMM yyyy').format(_harvested!)),
          ),
        ],
        if (verdict != null) ...[
          const SizedBox(height: 18),
          verdict,
          AdviceList(
            heading: hi ? 'अब' : 'Now',
            items: const [cropReportHow],
          ),
          const SizedBox(height: 8),
          Text(
            hi
                ? 'यह सिर्फ़ उन फ़सलों पर लागू है जिनका बीमा है — फ़सल ऋण वाले ज़्यादातर '
                    'किसान बैंक के ज़रिए अपने आप बीमित होते हैं, जब तक उन्होंने मना न किया हो।'
                : 'This applies only to insured crops. Most farmers with a '
                    'crop loan are insured through the bank automatically '
                    'unless they opted out.',
            style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
