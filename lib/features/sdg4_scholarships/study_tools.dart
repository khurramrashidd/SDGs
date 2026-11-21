import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Marks, percentage and CGPA, converted without guessing the formula.
///
/// Every scholarship form, every college application and every job
/// advertisement asks for one of these three and a student usually holds a
/// different one. The conversions are not hard; what makes people get them
/// wrong is that the CGPA multiplier differs between boards and
/// universities, so this asks which one rather than assuming the common
/// 9.5.
enum CgpaScale { cbse95, tenPoint10, custom }

double cgpaToPercent(double cgpa, CgpaScale scale, double customFactor) =>
    switch (scale) {
      CgpaScale.cbse95 => cgpa * 9.5,
      CgpaScale.tenPoint10 => cgpa * 10,
      CgpaScale.custom => cgpa * customFactor,
    };

class MarksPage extends StatefulWidget {
  const MarksPage({super.key});

  @override
  State<MarksPage> createState() => _MarksPageState();
}

class _MarksPageState extends State<MarksPage> {
  bool _fromMarks = true;
  final _scored = TextEditingController();
  final _total = TextEditingController(text: '500');
  final _cgpa = TextEditingController();
  final _factor = TextEditingController(text: '9.5');
  CgpaScale _scale = CgpaScale.cbse95;

  @override
  void dispose() {
    for (final c in [_scored, _total, _cgpa, _factor]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scored = double.tryParse(_scored.text.trim()) ?? 0;
    final total = double.tryParse(_total.text.trim()) ?? 0;
    final cgpa = double.tryParse(_cgpa.text.trim()) ?? 0;
    final factor = double.tryParse(_factor.text.trim()) ?? 9.5;

    double? percent;
    if (_fromMarks && total > 0 && scored >= 0) {
      percent = scored * 100 / total;
    } else if (!_fromMarks && cgpa > 0) {
      percent = cgpaToPercent(cgpa, _scale, factor);
    }

    return ToolScaffold(
      goal: 4,
      title: hi ? 'अंक, प्रतिशत और सीजीपीए' : 'Marks, percentage and CGPA',
      children: [
        ToolQuestion(hi ? 'आपके पास क्या है?' : 'What do you have?'),
        SelectionTile(
          label: hi ? 'अंक (जैसे 500 में से 382)' : 'Marks (like 382 out of 500)',
          selected: _fromMarks,
          onTap: () => setState(() => _fromMarks = true),
        ),
        SelectionTile(
          label: hi ? 'सीजीपीए या ग्रेड पॉइंट' : 'CGPA or grade point',
          selected: !_fromMarks,
          onTap: () => setState(() => _fromMarks = false),
        ),
        if (_fromMarks) ...[
          Row(children: [
            Expanded(
              child: ToolNumber(
                controller: _scored,
                label: hi ? 'मिले अंक' : 'Marks scored',
                decimal: true,
                maxDigits: 6,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _total,
                label: hi ? 'कुल अंक' : 'Out of',
                decimal: true,
                maxDigits: 6,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ]),
        ] else ...[
          ToolNumber(
            controller: _cgpa,
            label: hi ? 'सीजीपीए' : 'CGPA',
            decimal: true,
            maxDigits: 5,
            onChanged: (_) => setState(() {}),
          ),
          ToolQuestion(hi ? 'किस पैमाने पर?' : 'On which scale?'),
          SelectionTile(
            label: hi
                ? 'सीबीएसई और कई बोर्ड — 9.5 से गुणा'
                : 'CBSE and many boards — multiply by 9.5',
            selected: _scale == CgpaScale.cbse95,
            onTap: () => setState(() => _scale = CgpaScale.cbse95),
          ),
          SelectionTile(
            label: hi
                ? 'कई विश्वविद्यालय — 10 से गुणा'
                : 'Many universities — multiply by 10',
            selected: _scale == CgpaScale.tenPoint10,
            onTap: () => setState(() => _scale = CgpaScale.tenPoint10),
          ),
          SelectionTile(
            label: hi ? 'मेरे संस्थान का अपना फ़ॉर्मूला' : 'My institution has its own',
            selected: _scale == CgpaScale.custom,
            onTap: () => setState(() => _scale = CgpaScale.custom),
          ),
          if (_scale == CgpaScale.custom)
            ToolNumber(
              controller: _factor,
              label: hi ? 'किससे गुणा करना है' : 'Multiply by',
              decimal: true,
              maxDigits: 5,
              helper: hi
                  ? 'मार्कशीट के पीछे या विश्वविद्यालय की वेबसाइट पर लिखा होता है।'
                  : 'Printed on the back of the marksheet or on the '
                      "university's website.",
              onChanged: (_) => setState(() {}),
            ),
        ],
        if (percent != null) ...[
          ToolAnswer(
            headline: '${percent.toStringAsFixed(2)}%',
            detail: _fromMarks
                ? (hi
                    ? 'फ़ॉर्म में यही प्रतिशत भरें। कुछ फ़ॉर्म दशमलव के बाद दो अंक माँगते '
                        'हैं — वही ऊपर दिया है।'
                    : 'This is the percentage to put on a form. Some forms '
                        'want two decimal places, which is what is shown.')
                : (hi
                    ? 'यह उसी गुणक से निकाला गया है जो आपने चुना। अगर फ़ॉर्म पर '
                        'प्रतिशत माँगा है तो यही लिखें, और मार्कशीट साथ रखें।'
                    : 'Worked out with the multiplier you picked. If a form '
                        'asks for a percentage, this is it — keep the '
                        'marksheet with you.'),
            tone: ToolTone.good,
            icon: Icons.calculate_outlined,
          ),
          const SizedBox(height: 10),
          if (_fromMarks)
            ToolLine(hi ? 'सीजीपीए (9.5 वाले पैमाने पर)' : 'CGPA (on the 9.5 scale)',
                (percent / 9.5).toStringAsFixed(2)),
          ToolNote(hi
              ? 'अलग-अलग बोर्ड और विश्वविद्यालय अलग फ़ॉर्मूला इस्तेमाल करते हैं। किसी '
                  'आवेदन में भरने से पहले अपनी मार्कशीट पर लिखा फ़ॉर्मूला देख लें — वही '
                  'मान्य होता है।'
              : 'Boards and universities use different formulas. Before '
                  'putting a figure on an application, check the one printed '
                  'on your own marksheet — that is the one that counts.'),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------

/// A study plan from the syllabus and the days left.
///
/// Not a motivational tool. It does one piece of arithmetic that students
/// avoid doing because the answer is uncomfortable: how many hours there
/// actually are per chapter, which is what tells you whether the plan is
/// possible at all.
class ExamPlanPage extends StatefulWidget {
  const ExamPlanPage({super.key});

  @override
  State<ExamPlanPage> createState() => _ExamPlanPageState();
}

class _ExamPlanPageState extends State<ExamPlanPage> {
  final _days = TextEditingController(text: '30');
  final _hours = TextEditingController(text: '4');
  final _subjects = TextEditingController(text: '5');
  final _chapters = TextEditingController(text: '12');
  bool _revision = true;

  @override
  void dispose() {
    for (final c in [_days, _hours, _subjects, _chapters]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final days = int.tryParse(_days.text.trim()) ?? 0;
    final hours = double.tryParse(_hours.text.trim()) ?? 0;
    final subjects = int.tryParse(_subjects.text.trim()) ?? 0;
    final chapters = int.tryParse(_chapters.text.trim()) ?? 0;

    // A tenth of the days go on things nobody plans for: a wedding, an
    // illness, a day the power is out. Planning for 100% of the time is
    // how a plan collapses in week two.
    final usableDays = (days * 0.9).floor();
    final studyDays = _revision ? (usableDays * 0.75).floor() : usableDays;
    final revisionDays = usableDays - studyDays;
    final totalChapters = subjects * chapters;
    final totalHours = studyDays * hours;
    final perChapter = totalChapters > 0 ? totalHours / totalChapters : 0.0;
    final chaptersADay = studyDays > 0 ? totalChapters / studyDays : 0.0;

    return ToolScaffold(
      goal: 4,
      title: hi ? 'पढ़ाई की योजना' : 'Study plan',
      children: [
        ToolNote(hi
            ? 'यह हौसला बढ़ाने वाला टूल नहीं है। यह सिर्फ़ वह हिसाब करता है जिससे '
                'विद्यार्थी बचते हैं: हर अध्याय के लिए असल में कितने घंटे बचे हैं।'
            : 'Not a motivational tool. It does the one sum students avoid: '
                'how many hours there actually are per chapter.'),
        ToolQuestion(hi ? 'समय' : 'The time you have'),
        Row(children: [
          Expanded(
            child: ToolNumber(
              controller: _days,
              label: hi ? 'परीक्षा में दिन' : 'Days to the exam',
              maxDigits: 3,
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ToolNumber(
              controller: _hours,
              label: hi ? 'रोज़ के घंटे' : 'Hours a day',
              decimal: true,
              maxDigits: 4,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ]),
        ToolQuestion(hi ? 'पाठ्यक्रम' : 'The syllabus'),
        Row(children: [
          Expanded(
            child: ToolNumber(
              controller: _subjects,
              label: hi ? 'विषय' : 'Subjects',
              maxDigits: 2,
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ToolNumber(
              controller: _chapters,
              label: hi ? 'हर विषय में अध्याय' : 'Chapters each',
              maxDigits: 3,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ]),
        SwitchListTile(
          value: _revision,
          contentPadding: EdgeInsets.zero,
          title: Text(hi ? 'अंत में दोहराने का समय रखें' : 'Keep time at the end for revision'),
          onChanged: (v) => setState(() => _revision = v),
        ),
        if (days > 0 && totalChapters > 0 && hours > 0) ...[
          ToolAnswer(
            headline: hi
                ? 'हर अध्याय के लिए लगभग ${perChapter.toStringAsFixed(1)} घंटे'
                : 'About ${perChapter.toStringAsFixed(1)} hours per chapter',
            detail: perChapter < 1
                ? (hi
                    ? 'यह बहुत कम है। या तो रोज़ के घंटे बढ़ाएँ, या तय करें कि कौन से '
                        'अध्याय छोड़ने हैं — आख़िरी हफ़्ते में अपने आप छूटने से बेहतर है '
                        'कि अभी सोच-समझकर चुनें।'
                    : 'That is very little. Either add hours, or decide now '
                        'which chapters to leave out — a choice made now '
                        'beats one made by running out of time in the last '
                        'week.')
                : (hi
                    ? 'रोज़ लगभग ${chaptersADay.toStringAsFixed(1)} अध्याय। जो अध्याय '
                        'कठिन हैं उन्हें दो गिनें और आसान को आधा।'
                    : 'About ${chaptersADay.toStringAsFixed(1)} chapters a '
                        'day. Count a hard chapter as two and an easy one as '
                        'half.'),
            tone: perChapter < 1 ? ToolTone.warn : ToolTone.good,
            icon: Icons.event_outlined,
          ),
          const SizedBox(height: 10),
          ToolLine(hi ? 'कुल अध्याय' : 'Chapters in all', '$totalChapters'),
          ToolLine(
              hi ? 'पढ़ने के दिन' : 'Days for learning', '$studyDays'),
          if (_revision)
            ToolLine(hi ? 'दोहराने के दिन' : 'Days for revision',
                '$revisionDays'),
          ToolLine(hi ? 'कुल पढ़ाई के घंटे' : 'Study hours in all',
              totalHours.toStringAsFixed(0),
              strong: true),
          ToolNote(hi
              ? 'दिनों में से दसवाँ हिस्सा पहले ही घटा दिया गया है — शादी, बीमारी, बिजली '
                  'जाना। पूरे समय की योजना बनाना ही वह वजह है जिससे योजनाएँ दूसरे हफ़्ते '
                  'टूट जाती हैं।'
              : 'A tenth of the days is already taken off for the things '
                  'nobody plans for — a wedding, an illness, no power. '
                  'Planning for every day is why plans collapse in week '
                  'two.'),
        ],
      ],
    );
  }
}
