import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// TB, and what a blood sugar reading means.
///
/// Both of these are diseases people in villages carry for years without
/// a name for them: a cough that "is just the dust", a thirst and tiredness
/// that "is just the heat". Both are free to test and free to treat in the
/// government system, and in TB's case the government also pays the patient
/// money every month - which almost nobody knows.

const _nikshayUrl = 'https://www.nikshay.in/';
const _nikshayPibUrl = 'https://www.pib.gov.in/PressReleasePage.aspx?PRID=2062928';
const _diabetesUrl =
    'https://cdn.who.int/media/docs/default-source/searo/ncd/diabetes-dm-protocol/india_dm-management-protocol.pdf';

/// Ni-kshay Poshan Yojana, per patient per month, for the whole course.
/// Raised from ₹500 in October 2024.
const nikshayPoshanRupees = 1000;
const nikshayPoshanOldRupees = 500;

// --- TB ---------------------------------------------------------------

/// The symptoms that should send someone for a test. Any two weeks of
/// cough is the main one, and it is the one explained away.
enum TbSign {
  coughTwoWeeks,
  eveningFever,
  weightLoss,
  nightSweats,
  bloodInSputum,
  contactWithPatient,
}

/// True if the person should be tested now. One sign is enough: the test
/// is free and harmless, and TB caught late is neither.
bool shouldTestForTb(Set<TbSign> signs) => signs.isNotEmpty;

class TbPage extends StatefulWidget {
  const TbPage({super.key});

  @override
  State<TbPage> createState() => _TbPageState();
}

class _TbPageState extends State<TbPage> {
  final Set<TbSign> _signs = {};

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final test = shouldTestForTb(_signs);

    Widget sign(TbSign s, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _signs.contains(s),
          onTap: () => setState(() {
            if (!_signs.remove(s)) _signs.add(s);
          }),
        );

    return ToolScaffold(
      goal: 3,
      title: hi ? 'टीबी: जाँच, दवा, और पैसा' : 'TB: tests, medicines, and money',
      children: [
        ToolNote(hi
            ? 'टीबी की जाँच और पूरी दवा सरकारी व्यवस्था में मुफ़्त है — और इसके ऊपर '
                'सरकार मरीज़ को इलाज के पूरे समय हर महीने ₹$nikshayPoshanRupees देती है, '
                'खाने के लिए। यह आख़िरी बात बहुत कम लोगों को पता होती है।'
            : 'Testing for TB and the whole course of medicine are free in '
                'the government system - and on top of that the government '
                'pays the patient ₹$nikshayPoshanRupees every month for the '
                'whole treatment, for food. That last part is the piece '
                'almost nobody knows.'),
        ToolQuestion(hi ? 'इनमें से कुछ है?' : 'Is any of this true?'),
        sign(TbSign.coughTwoWeeks, 'A cough for two weeks or more',
            'दो हफ़्ते या उससे ज़्यादा से खाँसी'),
        sign(TbSign.eveningFever, 'Fever, especially in the evening',
            'बुख़ार, ख़ासकर शाम को'),
        sign(TbSign.weightLoss, 'Losing weight without trying',
            'वज़न अपने आप घटता जा रहा है'),
        sign(TbSign.nightSweats, 'Sweating at night', 'रात में पसीना आना'),
        sign(TbSign.bloodInSputum, 'Blood in the phlegm',
            'बलगम में ख़ून आना'),
        sign(TbSign.contactWithPatient,
            'Living with, or close to, someone who has TB',
            'घर में या पास में किसी को टीबी है'),
        if (_signs.isNotEmpty) ...[
          ToolAnswer(
            headline: test && _signs.contains(TbSign.bloodInSputum)
                ? (hi ? 'जाँच इसी हफ़्ते कराएँ' : 'Get tested this week')
                : (hi ? 'जाँच करा लें — मुफ़्त है' : 'Get tested - it is free'),
            detail: hi
                ? 'नज़दीकी सरकारी अस्पताल, पीएचसी या आयुष्मान आरोग्य मंदिर में बलगम '
                    'की जाँच होती है, और ज़रूरत पड़े तो मशीन से की जाने वाली जाँच (NAAT) '
                    'और छाती का एक्स-रे भी — सब मुफ़्त। जाँच में एक-दो दिन लगते हैं। '
                    '"खाँसी तो धूल से है" — दो हफ़्ते से ज़्यादा हो तो यह बात जाँच से ही तय '
                    'होती है, अंदाज़े से नहीं।'
                : 'A sputum test is done at the nearest government hospital, '
                    'PHC or Ayushman Arogya Mandir, and where needed a '
                    'machine test (NAAT) and a chest X-ray too - all free. It '
                    'takes a day or two. "The cough is just the dust" - past '
                    'two weeks, that is settled by a test, not by a guess.',
            tone: ToolTone.warn,
            icon: Icons.biotech_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'अगर टीबी निकले' : 'If it is TB',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ToolLine(hi ? 'जाँच' : 'Testing', hi ? 'मुफ़्त' : 'Free',
              strong: true),
          ToolLine(hi ? 'पूरी दवा, पूरे इलाज तक' : 'All medicines, the whole course',
              hi ? 'मुफ़्त' : 'Free', strong: true),
          ToolLine(
              hi
                  ? 'नि-क्षय पोषण योजना, हर महीने'
                  : 'Ni-kshay Poshan Yojana, every month',
              '₹$nikshayPoshanRupees',
              strong: true),
          ToolLine(
              hi ? 'इलाज की लंबाई, आम टीबी में' : 'Length of treatment, ordinary TB',
              hi ? 'लगभग 6 महीने' : 'About 6 months'),
          const SizedBox(height: 8),
          ToolNote(hi
              ? 'पैसा सीधे बैंक खाते में आता है, इसलिए नि-क्षय में नाम दर्ज कराते समय '
                  'खाता और आधार ठीक दें। अक्टूबर 2024 में यह रक़म '
                  '₹$nikshayPoshanOldRupees से बढ़ाकर ₹$nikshayPoshanRupees की गई। '
                  'जिनका वज़न बहुत कम है (BMI 18.5 से नीचे) उन्हें पहले दो महीने '
                  'अतिरिक्त पोषण सामग्री भी मिलती है।'
              : 'The money comes straight to a bank account, so give the '
                  'account and Aadhaar correctly when the name is registered '
                  'on Ni-kshay. In October 2024 the amount was raised from '
                  '₹$nikshayPoshanOldRupees to ₹$nikshayPoshanRupees. '
                  'Patients who are very underweight (BMI below 18.5) also '
                  'get extra nutritional supplementation for the first two '
                  'months.'),
          ToolDonts(
            heading: hi
                ? 'इलाज के दौरान यह न करें'
                : 'During treatment, do not do these',
            items: hi
                ? const [
                    'अच्छा महसूस होने पर दवा बंद न करें। टीबी की दवा बीच में छोड़ने से '
                        'बीमारी दवा-प्रतिरोधी हो जाती है, और फिर इलाज कई गुना लंबा और '
                        'मुश्किल हो जाता है।',
                    'एक-दो दिन की दवा छूटने पर चुप न रहें — इलाज करने वाले को बताएँ।',
                    'घर के बाक़ी लोगों की जाँच न टालें। जिनके साथ मरीज़ रहता है, उन सबकी '
                        'जाँच होनी चाहिए, बच्चों की भी।',
                    'खाँसते समय मुँह ढकना न छोड़ें, और शुरू के हफ़्तों में कमरे की खिड़की '
                        'खुली रखें।',
                  ]
                : const [
                    'Do not stop the medicines when you start feeling '
                        'better. Stopping TB treatment part-way is what makes '
                        'the disease drug-resistant, and then the treatment '
                        'becomes many times longer and harder.',
                    'Do not stay quiet about a missed day or two - tell '
                        'whoever is treating you.',
                    'Do not put off testing the rest of the household. '
                        'Everyone living with the patient should be tested, '
                        'children included.',
                    'Do not stop covering your mouth when coughing, and keep '
                        'the room\'s window open in the early weeks.',
                  ],
          ),
          ToolNote(hi
              ? 'निजी डॉक्टर से इलाज करा रहे हों तो भी यह सब मिल सकता है: डॉक्टर को '
                  'नि-क्षय में मामला दर्ज करना होता है, और दर्ज होने पर दवा और पोषण का '
                  'पैसा दोनों मिलते हैं। हेल्पलाइन 1800-11-6666।'
              : 'All of this is available even if you are being treated '
                  'privately: the doctor is required to notify the case on '
                  'Ni-kshay, and once notified both the medicines and the '
                  'nutrition money follow. Helpline 1800-11-6666.'),
          const SourceNote(text: 'Ni-kshay, National TB Elimination Programme',
              url: _nikshayUrl),
          const SourceNote(
              text: 'Nutrition support raised to ₹1,000 a month, Ministry of '
                  'Health',
              url: _nikshayPibUrl),
        ],
      ],
    );
  }
}

// --- Blood sugar ------------------------------------------------------

/// Which reading the person has. The thresholds are different for each,
/// and using the fasting cut-off on an after-food reading is the mistake
/// that frightens people for no reason.
enum SugarTest { fasting, afterFood, hba1c }

enum SugarBand { normal, pre, diabetes }

/// India's diagnostic bands, from the national diabetes management
/// protocol. Values in mg/dL for the two glucose tests, per cent for
/// HbA1c.
SugarBand sugarBand(SugarTest test, double value) => switch (test) {
      SugarTest.fasting => value < 100
          ? SugarBand.normal
          : (value < 126 ? SugarBand.pre : SugarBand.diabetes),
      SugarTest.afterFood => value < 140
          ? SugarBand.normal
          : (value < 200 ? SugarBand.pre : SugarBand.diabetes),
      SugarTest.hba1c => value < 5.7
          ? SugarBand.normal
          : (value < 6.5 ? SugarBand.pre : SugarBand.diabetes),
    };

class BloodSugarPage extends StatefulWidget {
  const BloodSugarPage({super.key});

  @override
  State<BloodSugarPage> createState() => _BloodSugarPageState();
}

class _BloodSugarPageState extends State<BloodSugarPage> {
  final _value = TextEditingController();
  SugarTest _test = SugarTest.fasting;

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final value = double.tryParse(_value.text.trim());
    final band = value == null || value <= 0 ? null : sugarBand(_test, value);

    Widget pick(SugarTest t, String en, String h, String sub, String subHi) =>
        SelectionTile(
          label: hi ? h : en,
          subtitle: hi ? subHi : sub,
          selected: _test == t,
          onTap: () => setState(() => _test = t),
        );

    return ToolScaffold(
      goal: 3,
      title: hi ? 'ख़ून में शुगर: रिपोर्ट का मतलब' : 'Blood sugar: what the reading means',
      children: [
        ToolNote(hi
            ? 'पर्ची पर लिखा नंबर अपने आप कुछ नहीं कहता — यह इस पर निर्भर है कि जाँच '
                'ख़ाली पेट हुई थी, खाने के बाद, या वह HbA1c था। तीनों की सीमाएँ अलग हैं, '
                'और ख़ाली पेट की सीमा खाने के बाद की रिपोर्ट पर लगाकर लोग बेवजह डर '
                'जाते हैं।'
            : 'The number on the slip says nothing by itself - it depends on '
                'whether the test was on an empty stomach, after food, or an '
                'HbA1c. The three have different cut-offs, and applying the '
                'fasting cut-off to an after-food reading is how people '
                'frighten themselves for no reason.'),
        ToolQuestion(hi ? 'कौन सी जाँच' : 'Which test'),
        pick(SugarTest.fasting, 'Fasting (empty stomach)', 'ख़ाली पेट',
            'Nothing to eat for 8 hours before', 'जाँच से 8 घंटे पहले कुछ न खाया हो'),
        pick(SugarTest.afterFood, 'After food, or random',
            'खाने के बाद, या कभी भी',
            'Two hours after a meal, or any time', 'खाने के दो घंटे बाद, या किसी भी समय'),
        pick(SugarTest.hba1c, 'HbA1c', 'HbA1c',
            'The three-month average, in per cent',
            'तीन महीने का औसत, प्रतिशत में'),
        ToolQuestion(hi ? 'रिपोर्ट का नंबर' : 'The number on the report'),
        ToolNumber(
          controller: _value,
          label: _test == SugarTest.hba1c
              ? (hi ? 'प्रतिशत' : 'Per cent')
              : (hi ? 'mg/dL' : 'mg/dL'),
          decimal: true,
          maxDigits: 5,
          icon: Icons.water_drop_outlined,
          onChanged: (_) => setState(() {}),
        ),
        if (band != null) ...[
          ToolAnswer(
            headline: switch (band) {
              SugarBand.normal => hi ? 'सामान्य सीमा में' : 'In the normal range',
              SugarBand.pre =>
                hi ? 'सीमा रेखा पर — प्री-डायबिटीज़' : 'Borderline - prediabetes',
              SugarBand.diabetes => hi
                  ? 'डायबिटीज़ की सीमा में आता है'
                  : 'In the diabetes range',
            },
            detail: switch (band) {
              SugarBand.normal => hi
                  ? 'तीस की उम्र के बाद साल में एक बार जाँच कराते रहें। परिवार में '
                      'किसी को डायबिटीज़ है, या वज़न ज़्यादा है, तो यह और ज़रूरी है।'
                  : 'After thirty, have it checked once a year. More so if '
                      'someone in the family has diabetes, or if your weight '
                      'is high.',
              SugarBand.pre => hi
                  ? 'यह बीमारी नहीं है, चेतावनी है — और इस अवस्था से वापस लौटा जा सकता '
                      'है। खाने में बदलाव और रोज़ आधा घंटा चलने से बहुत लोग यहीं रुक जाते '
                      'हैं। तीन-छह महीने में दोबारा जाँच कराएँ, और डॉक्टर को यह रिपोर्ट '
                      'दिखाएँ।'
                  : 'This is not the disease, it is the warning - and this '
                      'stage can be turned back. A change in what is eaten '
                      'and half an hour of walking a day stops it here for a '
                      'great many people. Test again in three to six months, '
                      'and show this report to a doctor.',
              SugarBand.diabetes => hi
                  ? 'एक रिपोर्ट से पक्का नहीं होता: डॉक्टर आमतौर पर दूसरे दिन दोबारा जाँच '
                      'कराकर तय करते हैं। डॉक्टर को दिखाएँ — ख़ुद से दवा शुरू न करें और '
                      'किसी की दवा उधार लेकर न खाएँ। जाँच और दवा आयुष्मान आरोग्य मंदिर '
                      'और सरकारी अस्पताल में मुफ़्त मिलती हैं।'
                  : 'One report does not settle it: a doctor will usually '
                      'repeat the test on another day before deciding. Show '
                      'it to a doctor - do not start medicines yourself, and '
                      'do not borrow someone else\'s. Testing and medicines '
                      'are free at an Ayushman Arogya Mandir and government '
                      'hospitals.',
            },
            tone: switch (band) {
              SugarBand.normal => ToolTone.good,
              SugarBand.pre => ToolTone.warn,
              SugarBand.diabetes => ToolTone.bad,
            },
            icon: Icons.monitor_heart_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'पूरी सीमाएँ' : 'The full ranges',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          if (_test == SugarTest.fasting) ...[
            ToolLine(hi ? 'सामान्य' : 'Normal', hi ? '100 से कम' : 'Below 100',
                strong: band == SugarBand.normal),
            ToolLine(hi ? 'प्री-डायबिटीज़' : 'Prediabetes', '100 - 125',
                strong: band == SugarBand.pre),
            ToolLine(hi ? 'डायबिटीज़' : 'Diabetes',
                hi ? '126 या ज़्यादा' : '126 or more',
                strong: band == SugarBand.diabetes),
          ] else if (_test == SugarTest.afterFood) ...[
            ToolLine(hi ? 'सामान्य' : 'Normal', hi ? '140 से कम' : 'Below 140',
                strong: band == SugarBand.normal),
            ToolLine(hi ? 'प्री-डायबिटीज़' : 'Prediabetes', '140 - 199',
                strong: band == SugarBand.pre),
            ToolLine(hi ? 'डायबिटीज़' : 'Diabetes',
                hi ? '200 या ज़्यादा' : '200 or more',
                strong: band == SugarBand.diabetes),
          ] else ...[
            ToolLine(hi ? 'सामान्य' : 'Normal',
                hi ? '5.7% से कम' : 'Below 5.7%',
                strong: band == SugarBand.normal),
            ToolLine(hi ? 'प्री-डायबिटीज़' : 'Prediabetes', '5.7% - 6.4%',
                strong: band == SugarBand.pre),
            ToolLine(hi ? 'डायबिटीज़' : 'Diabetes',
                hi ? '6.5% या ज़्यादा' : '6.5% or more',
                strong: band == SugarBand.diabetes),
          ],
          const SizedBox(height: 10),
          ToolNote(hi
              ? 'ये सीमाएँ भारत के राष्ट्रीय डायबिटीज़ प्रबंधन प्रोटोकॉल से हैं। कुछ राज्यों '
                  'में उँगली से की जाने वाली जाँच (ग्लूकोमीटर) के लिए थोड़ी अलग सीमाएँ हैं, '
                  'इसलिए पक्का करने के लिए नस से ख़ून की लैब जाँच कराई जाती है।'
              : 'These ranges are from India\'s national diabetes management '
                  'protocol. Some states use slightly different cut-offs for '
                  'a finger-prick (glucometer) reading, which is why a lab '
                  'test on blood from a vein is used to confirm.'),
          const SourceNote(
              text: 'India diabetes management protocol, MoHFW / WHO',
              url: _diabetesUrl),
        ],
      ],
    );
  }
}
