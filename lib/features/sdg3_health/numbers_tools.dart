import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Diarrhoea in a child: how much to give back, and when to stop treating
/// it at home.
///
/// Diarrhoea kills by drying a child out, and it is stopped by replacing
/// the fluid, not by stopping the stools. Two beliefs do most of the harm:
/// that you should hold back food and drink to "rest the stomach", and
/// that a medicine to stop the motions is the treatment. Both are wrong,
/// and both are common.
///
/// The volumes are the World Health Organization's Plan A amounts, given
/// after each loose stool:
///   under 2 years   50 to 100 ml
///   2 to 10 years   100 to 200 ml
///   older           as much as they want
///
/// No medicine dose is given here. Zinc is part of the standard treatment
/// and a health worker supplies it with the right amount for the age -
/// which is where that number should come from, not from an app.
enum DiarrhoeaAge { underTwo, twoToTen, older }

({int low, int high}) orsMlPerStool(DiarrhoeaAge age) => switch (age) {
      DiarrhoeaAge.underTwo => (low: 50, high: 100),
      DiarrhoeaAge.twoToTen => (low: 100, high: 200),
      DiarrhoeaAge.older => (low: 200, high: 400),
    };

enum DiarrhoeaSign {
  cannotDrink,
  vomitsEverything,
  bloodInStool,
  sunkenEyes,
  noUrine,
  drowsy,
  fever,
}

/// Any one of these means the child is past what a home can manage.
bool needsFacilityNow(Set<DiarrhoeaSign> signs) => signs.any((s) =>
    s == DiarrhoeaSign.cannotDrink ||
    s == DiarrhoeaSign.vomitsEverything ||
    s == DiarrhoeaSign.bloodInStool ||
    s == DiarrhoeaSign.drowsy ||
    s == DiarrhoeaSign.sunkenEyes ||
    s == DiarrhoeaSign.noUrine);

const _whoPlanA =
    'https://gpnotebook.com/pages/gastroenterology/'
    'who-world-health-organisation-suggested-management-of-dehydration-'
    'secondary-to-diarrhoeal-illness/'
    'treatment-plan-a-management-of-patients-with-no-signs-of-dehydration-'
    'who-recommendations';

class DiarrhoeaPage extends StatefulWidget {
  const DiarrhoeaPage({super.key});

  @override
  State<DiarrhoeaPage> createState() => _DiarrhoeaPageState();
}

class _DiarrhoeaPageState extends State<DiarrhoeaPage> {
  DiarrhoeaAge? _age;
  final _signs = <DiarrhoeaSign>{};

  static const _labels = {
    DiarrhoeaSign.cannotDrink: (
      'Cannot drink or breastfeed, or drinks very poorly',
      'पी नहीं पा रहा या दूध नहीं पी रहा, या बहुत कम पी रहा है'
    ),
    DiarrhoeaSign.vomitsEverything: (
      'Vomits everything that goes in',
      'जो भी दो, सब उल्टी कर देता है'
    ),
    DiarrhoeaSign.bloodInStool: ('Blood in the stool', 'दस्त में ख़ून'),
    DiarrhoeaSign.sunkenEyes: (
      'Eyes look sunken, no tears when crying',
      'आँखें धँसी लग रही हैं, रोने पर आँसू नहीं'
    ),
    DiarrhoeaSign.noUrine: (
      'Has not passed urine for many hours',
      'कई घंटों से पेशाब नहीं हुआ'
    ),
    DiarrhoeaSign.drowsy: (
      'Drowsy, floppy, or hard to wake',
      'सुस्त, ढीला, या जगाने में मुश्किल'
    ),
    DiarrhoeaSign.fever: ('Fever as well', 'साथ में बुख़ार भी'),
  };

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final urgent = needsFacilityNow(_signs);
    final ors = _age == null ? null : orsMlPerStool(_age!);

    return ToolScaffold(
      goal: 3,
      title: hi ? 'बच्चे को दस्त' : 'Diarrhoea in a child',
      children: [
        ToolNote(hi
            ? 'दस्त से जान पानी की कमी से जाती है, दस्त से नहीं। इलाज है पानी और नमक '
                'वापस देना — रोकने की दवा नहीं। खाना-पीना बंद करना सबसे बड़ी ग़लती है।'
            : 'Diarrhoea kills by drying a child out. The treatment is '
                'putting the fluid and salt back, not stopping the stools. '
                'Holding back food and drink is the worst thing you can do.'),
        ToolQuestion(hi ? 'बच्चे की उम्र' : "The child's age"),
        SelectionTile(
          label: hi ? '2 साल से कम' : 'Under 2 years',
          selected: _age == DiarrhoeaAge.underTwo,
          onTap: () => setState(() => _age = DiarrhoeaAge.underTwo),
        ),
        SelectionTile(
          label: hi ? '2 से 10 साल' : '2 to 10 years',
          selected: _age == DiarrhoeaAge.twoToTen,
          onTap: () => setState(() => _age = DiarrhoeaAge.twoToTen),
        ),
        SelectionTile(
          label: hi ? '10 साल से ऊपर' : 'Over 10 years',
          selected: _age == DiarrhoeaAge.older,
          onTap: () => setState(() => _age = DiarrhoeaAge.older),
        ),
        ToolQuestion(hi
            ? 'इनमें से कुछ दिख रहा है? जो भी हो, सब चुनें।'
            : 'Any of these? Tick everything you see.'),
        for (final e in _labels.entries)
          CheckboxListTile(
            value: _signs.contains(e.key),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(hi ? e.value.$2 : e.value.$1,
                style: const TextStyle(fontSize: 14.5, height: 1.35)),
            onChanged: (v) => setState(() {
              v == true ? _signs.add(e.key) : _signs.remove(e.key);
            }),
          ),
        if (urgent)
          ToolAnswer(
            headline: hi
                ? 'अभी स्वास्थ्य केंद्र ले जाएँ'
                : 'Take the child to a health centre now',
            detail: hi
                ? 'इनमें से कोई भी लक्षण हो तो घर पर इलाज काफ़ी नहीं है। रास्ते में भी '
                    'ओआरएस के घूँट देते रहें — उसे रोकना नहीं है। एम्बुलेंस के लिए 108।'
                : 'With any of those signs, home treatment is not enough. '
                    'Keep giving sips of ORS on the way — do not stop it. '
                    'Call 108 for an ambulance.',
            tone: ToolTone.bad,
            icon: Icons.emergency_outlined,
          )
        else if (_age != null && ors != null) ...[
          ToolAnswer(
            headline: hi
                ? 'हर बार दस्त के बाद ${ors.low} से ${ors.high} मिली ओआरएस'
                : '${ors.low} to ${ors.high} ml of ORS after every loose stool',
            detail: _age == DiarrhoeaAge.underTwo
                ? (hi
                    ? 'लगभग एक चौथाई से आधा बड़ा कप। चम्मच से थोड़ा-थोड़ा, लगातार।'
                    : 'About a quarter to half a large cup. Spoon it in a '
                        'little at a time, steadily.')
                : _age == DiarrhoeaAge.twoToTen
                    ? (hi
                        ? 'लगभग आधा से एक बड़ा कप।'
                        : 'About half to one large cup.')
                    : (hi
                        ? 'जितना पीना चाहें उतना दें।'
                        : 'As much as they want to drink.'),
            tone: ToolTone.good,
            icon: Icons.local_drink_outlined,
          ),
          const SizedBox(height: 12),
          const ToolChecklist(
            storageKey: 'diarrhoea_care_v1',
            introEn: 'Along with the ORS:',
            introHi: 'ओआरएस के साथ-साथ:',
            items: [
              CheckItem('feed', 'Keep feeding — breastfeed more often, not '
                  'less', 'खाना-पीना चालू रखें — स्तनपान और ज़्यादा बार कराएँ, कम '
                  'नहीं'),
              CheckItem('zinc', 'Ask the anganwadi or health centre for zinc',
                  'आंगनवाड़ी या स्वास्थ्य केंद्र से ज़िंक माँगें',
                  noteEn: 'Zinc for a full course shortens the illness and '
                      'makes the next one less likely. The worker gives the '
                      'right amount for the age — take it from them, not '
                      'from an app.',
                  noteHi: 'पूरा कोर्स ज़िंक लेने से बीमारी जल्दी ठीक होती है और '
                      'दोबारा होने की आशंका घटती है। उम्र के हिसाब से सही मात्रा '
                      'कार्यकर्ता देती हैं — वही लें, ऐप से नहीं।'),
              CheckItem('nodrug', 'Do not give a medicine to stop the '
                  'motions', 'दस्त रोकने की दवा न दें',
                  noteEn: 'It traps the infection inside. Antibiotics are '
                      'only for the few cases a doctor identifies.',
                  noteHi: 'उससे संक्रमण अंदर ही रुक जाता है। एंटीबायोटिक सिर्फ़ उन '
                      'कुछ मामलों में, जो डॉक्टर तय करे।'),
              CheckItem('clean', 'Clean water and soap after every change',
                  'हर बार साफ़ पानी और साबुन'),
              CheckItem('watch', 'Watch for the danger signs above',
                  'ऊपर दिए ख़तरे के लक्षणों पर नज़र रखें'),
            ],
          ),
          if (_signs.contains(DiarrhoeaSign.fever))
            ToolNote(hi
                ? 'बुख़ार भी है, इसलिए आज ही दिखा लें, भले ही बाक़ी सब ठीक लग रहा हो।'
                : 'There is fever too, so have the child seen today even if '
                    'everything else looks all right.'),
          const SourceNote(
            text: 'Volumes: World Health Organization Treatment Plan A for '
                'diarrhoea without dehydration.',
            url: _whoPlanA,
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------

/// A blood pressure reading, read against the published bands.
///
/// This does not diagnose anything and says so. What it does is end the
/// most common conversation at a camp - "140 something, is that bad?" -
/// with the band the number falls in and what the band means you should do
/// next. One reading is never a diagnosis, which is the other thing people
/// do not know.
enum BpBand { low, normal, elevated, stage1, stage2, crisis }

/// Bands follow the widely used thresholds: under 120/80 normal, 120-129
/// over 80 elevated, 130-139 or 80-89 stage 1, 140+ or 90+ stage 2, and
/// 180+ or 120+ needs care immediately.
BpBand bpBand(int systolic, int diastolic) {
  if (systolic >= 180 || diastolic >= 120) return BpBand.crisis;
  if (systolic >= 140 || diastolic >= 90) return BpBand.stage2;
  if (systolic >= 130 || diastolic >= 80) return BpBand.stage1;
  if (systolic >= 120) return BpBand.elevated;
  if (systolic < 90 || diastolic < 60) return BpBand.low;
  return BpBand.normal;
}

class BloodPressurePage extends StatefulWidget {
  const BloodPressurePage({super.key});

  @override
  State<BloodPressurePage> createState() => _BloodPressurePageState();
}

class _BloodPressurePageState extends State<BloodPressurePage> {
  final _top = TextEditingController();
  final _bottom = TextEditingController();

  @override
  void dispose() {
    _top.dispose();
    _bottom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final top = int.tryParse(_top.text.trim()) ?? 0;
    final bottom = int.tryParse(_bottom.text.trim()) ?? 0;
    final band = (top > 0 && bottom > 0) ? bpBand(top, bottom) : null;

    final (String head, String detail, ToolTone tone) = switch (band) {
      BpBand.crisis => (
          hi ? 'अभी डॉक्टर को दिखाएँ' : 'Get seen immediately',
          hi
              ? 'यह बहुत ऊँचा है। सीने में दर्द, साँस फूलना, तेज़ सिरदर्द, धुंधला दिखना '
                  'या बोलने में दिक़्क़त हो तो 108 पर कॉल करें। कुछ भी न हो तब भी आज ही '
                  'स्वास्थ्य केंद्र जाएँ।'
              : 'This is very high. With chest pain, breathlessness, a '
                  'severe headache, blurred vision or trouble speaking, call '
                  '108. Even with none of those, go to a health centre '
                  'today.',
          ToolTone.bad
        ),
      BpBand.stage2 => (
          hi ? '140/90 या उससे ऊपर' : '140/90 or above',
          hi
              ? 'एक रीडिंग से कुछ तय नहीं होता। अलग-अलग दिनों में दो-तीन बार और नपवाएँ '
                  'और वे सब लिखकर डॉक्टर को दिखाएँ। सरकारी स्वास्थ्य केंद्र पर जाँच और '
                  'ज़्यादातर दवाएँ मुफ़्त हैं।'
              : 'One reading settles nothing. Have it taken two or three '
                  'more times on different days, write them all down and '
                  'show a doctor. At a government health centre the check '
                  'and most medicines are free.',
          ToolTone.warn
        ),
      BpBand.stage1 => (
          hi ? 'सामान्य से ऊपर' : 'Above normal',
          hi
              ? 'अभी घबराने की बात नहीं, पर नज़र रखने की है। कुछ हफ़्तों में दोबारा '
                  'नपवाएँ। नमक कम करना, चलना-फिरना और तंबाकू छोड़ना इसी स्तर पर सबसे '
                  'ज़्यादा काम करते हैं।'
              : 'Not alarming, but worth watching. Have it taken again in a '
                  'few weeks. Less salt, walking, and giving up tobacco do '
                  'the most good at exactly this level.',
          ToolTone.warn
        ),
      BpBand.elevated => (
          hi ? 'सामान्य की ऊपरी सीमा पर' : 'At the top of normal',
          hi
              ? 'साल में एक बार नपवाते रहें।'
              : 'Worth having checked once a year.',
          ToolTone.plain
        ),
      BpBand.normal => (
          hi ? 'सामान्य सीमा में' : 'In the normal range',
          hi
              ? 'साल में एक बार नपवाते रहें, ख़ासकर 30 साल के बाद।'
              : 'Keep having it checked once a year, especially after 30.',
          ToolTone.good
        ),
      BpBand.low => (
          hi ? 'सामान्य से नीचे' : 'Below the usual range',
          hi
              ? 'अगर चक्कर, कमज़ोरी या बेहोशी जैसा लगे तो दिखाएँ। कुछ लोगों का ब्लड '
                  'प्रेशर वैसे ही कम रहता है और वे बिल्कुल ठीक रहते हैं।'
              : 'Worth checking if you feel dizzy, weak or faint. Some '
                  "people simply run low and are perfectly well.",
          ToolTone.plain
        ),
      null => ('', '', ToolTone.plain),
    };

    return ToolScaffold(
      goal: 3,
      title: hi ? 'ब्लड प्रेशर' : 'Blood pressure',
      children: [
        ToolNote(hi
            ? 'यह जाँच नहीं करता, सिर्फ़ बताता है कि आपका नंबर किस श्रेणी में आता है। '
                'एक रीडिंग से कोई बीमारी तय नहीं होती।'
            : 'This does not diagnose anything. It says which published band '
                'your number falls in. One reading never settles a '
                'diagnosis.'),
        ToolQuestion(hi ? 'रीडिंग डालें' : 'Enter the reading'),
        Row(children: [
          Expanded(
            child: ToolNumber(
              controller: _top,
              label: hi ? 'ऊपर वाला' : 'Top number',
              maxDigits: 3,
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ToolNumber(
              controller: _bottom,
              label: hi ? 'नीचे वाला' : 'Bottom number',
              maxDigits: 3,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ]),
        if (band != null) ...[
          ToolAnswer(
            headline: '$top / $bottom  —  $head',
            detail: detail,
            tone: tone,
            icon: Icons.favorite_outline,
          ),
          const SizedBox(height: 12),
          Text(hi ? 'नापते समय' : 'When it is taken',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ToolNote(hi
              ? 'पाँच मिनट बैठकर आराम करने के बाद, पीठ टिकी हो, पैर ज़मीन पर, बाँह दिल '
                  'की ऊँचाई पर। नापने से आधा घंटा पहले चाय, तंबाकू या भागदौड़ नहीं। बात '
                  'करते हुए नापने पर रीडिंग ऊँची आ जाती है।'
              : 'After sitting quietly for five minutes, back supported, '
                  'feet on the floor, arm at heart level. No tea, tobacco or '
                  'rushing for half an hour before. Talking while it is '
                  'taken pushes the reading up.'),
        ],
      ],
    );
  }
}
