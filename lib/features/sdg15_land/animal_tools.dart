import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Animals: wild ones in the crop, sickness in the herd, and the
/// vaccination round.
///
/// The vaccine calendar is the common schedule state animal husbandry
/// departments publish for the big diseases. It is guidance for planning,
/// not a prescription, and it says so: the vet at the camp decides.

const _pmfbyUrl = 'https://pmfby.gov.in/';
const _dahdUrl = 'https://dahd.gov.in/';
const _moefccUrl = 'https://moef.gov.in/';

const vetHelpline = '1962';
const cropHelpline = '14447';

/// From Kharif 2026, crop loss from wild animals is a PMFBY add-on in the
/// states that notify it, reported within this many hours with geotagged
/// photographs on the Crop Insurance App.
const wildAnimalReportHours = 72;

// --- Crop raided by animals -------------------------------------------

class CropRaidPage extends StatefulWidget {
  const CropRaidPage({super.key});

  @override
  State<CropRaidPage> createState() => _CropRaidPageState();
}

class _CropRaidPageState extends State<CropRaidPage> {
  final _village = TextEditingController();
  final _khasra = TextEditingController();
  final _crop = TextEditingController();
  final _area = TextEditingController();
  final _animal = TextEditingController();
  final _date = TextEditingController();

  @override
  void dispose() {
    for (final c in [_village, _khasra, _crop, _area, _animal, _date]) {
      c.dispose();
    }
    super.dispose();
  }

  String _or(TextEditingController c) =>
      c.text.trim().isEmpty ? '______' : c.text.trim();

  String _letter(bool hi) {
    if (hi) {
      return 'सेवा में,\n'
          'वन क्षेत्राधिकारी (रेंज ऑफ़िसर)\n\n'
          'विषय: जंगली जानवरों से फ़सल नुक़सान के मुआवज़े हेतु आवेदन\n\n'
          'महोदय/महोदया,\n\n'
          'दिनांक ${_or(_date)} को ग्राम ${_or(_village)}, खसरा/सर्वे संख्या '
          '${_or(_khasra)} में मेरी ${_or(_crop)} की फ़सल को ${_or(_animal)} ने '
          'नुक़सान पहुँचाया। प्रभावित रक़बा लगभग ${_or(_area)} है।\n\n'
          'निवेदन है कि शीघ्र मौक़ा मुआयना कराकर नियमानुसार मुआवज़ा दिलाने की '
          'कृपा करें। फ़ोटो और ज़मीन के काग़ज़ संलग्न हैं।\n\n'
          'इस आवेदन की प्राप्ति रसीद देने की कृपा करें।\n\n'
          'दिनांक: ____________\n'
          'नाम: ____________\n'
          'पिता/पति का नाम: ____________\n'
          'फ़ोन: ____________\n'
          'बैंक खाता संख्या और आईएफ़एससी: ____________';
    }
    return 'To,\n'
        'The Range Forest Officer\n\n'
        'Subject: Application for compensation for crop damage by wild '
        'animals\n\n'
        'Sir / Madam,\n\n'
        'On ${_or(_date)}, my ${_or(_crop)} crop in village ${_or(_village)}, '
        'khasra / survey number ${_or(_khasra)}, was damaged by '
        '${_or(_animal)}. The affected area is about ${_or(_area)}.\n\n'
        'I request an early spot inspection and compensation as per the '
        'rules. Photographs and land papers are attached.\n\n'
        'Kindly give me a receipt for this application.\n\n'
        'Date: ____________\n'
        'Name: ____________\n'
        'Father\'s / husband\'s name: ____________\n'
        'Phone: ____________\n'
        'Bank account number and IFSC: ____________';
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 15,
      title: hi ? 'जानवरों ने फ़सल ख़राब की' : 'Crop raided by animals',
      children: [
        ToolAnswer(
          headline: hi ? 'दो दावे, दोनों जल्दी' : 'Two claims, both fast',
          detail: hi
              ? '1. वन विभाग का मुआवज़ा — हर राज्य की अपनी योजना है, और आवेदन की '
                  'समय सीमा कुछ ही दिनों की होती है। रेंज ऑफ़िस से पूछें, पर इंतज़ार न '
                  'करें — नुक़सान के दिन ही आवेदन दें, जब तक सबूत खेत में है।\n\n'
                  '2. फ़सल बीमा — ख़रीफ़ 2026 से जंगली जानवरों से नुक़सान प्रधानमंत्री '
                  'फ़सल बीमा योजना में उन राज्यों में जुड़ गया है जिन्होंने इसे अधिसूचित '
                  'किया है। बीमित हों तो $wildAnimalReportHours घंटे में "क्रॉप इंश्योरेंस" '
                  'ऐप पर जगह-चिह्नित फ़ोटो के साथ सूचना दें, या $cropHelpline पर।'
              : '1. Forest department compensation - each state runs its own '
                  'scheme, and the application window is only a few days. Ask '
                  'the range office, but do not wait - apply the same day, '
                  'while the evidence is still in the field.\n\n'
                  '2. Crop insurance - from Kharif 2026, damage by wild animals '
                  'is covered by PM Fasal Bima Yojana in the states that have '
                  'notified it. If insured, report within '
                  '$wildAnimalReportHours hours with geotagged photos on the '
                  '"Crop Insurance" app, or on $cropHelpline.',
          tone: ToolTone.warn,
          icon: Icons.timer_outlined,
        ),
        const SizedBox(height: 12),
        Text(hi ? 'सबूत — खेत साफ़ करने से पहले' : 'Evidence - before clearing the field',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'ख़राब फ़सल की फ़ोटो और वीडियो, खेत के चारों कोनों से',
                  'जानवर के पैरों के निशान, गोबर, टूटी बाड़ — जो भी दिखे',
                  'पास के किसानों के नाम जिन्होंने देखा',
                  'ज़मीन का काग़ज़ (खतौनी/7-12) और बोवाई का ब्योरा',
                ]
              : const [
                  'Photos and video of the damaged crop, from all four corners '
                      'of the field',
                  'Footprints, dung, broken fencing - whatever is there',
                  'Names of neighbouring farmers who saw it',
                  'The land record and the sowing details',
                ],
        ),
        ToolQuestion(hi ? 'वन विभाग को आवेदन' : 'Application to the forest department'),
        ToolText(
          controller: _village,
          label: hi ? 'गाँव' : 'Village',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ToolText(
                controller: _khasra,
                label: hi ? 'खसरा/सर्वे संख्या' : 'Khasra / survey no.',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolText(
                controller: _date,
                label: hi ? 'तारीख़' : 'Date',
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ToolText(
                controller: _crop,
                label: hi ? 'फ़सल' : 'Crop',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolText(
                controller: _area,
                label: hi ? 'रक़बा (जैसे 1 बीघा)' : 'Area (e.g. 1 acre)',
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ToolText(
          controller: _animal,
          label: hi ? 'कौन सा जानवर (नीलगाय, जंगली सूअर, हाथी…)' : 'Which animal (nilgai, wild boar, elephant…)',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        CopyBlock(
          text: _letter(hi),
          note: hi
              ? 'दो नक़ल ले जाएँ और एक पर रसीद लें। कई राज्यों में यह आवेदन ऑनलाइन भी '
                  'होता है — रेंज ऑफ़िस से पूछें।'
              : 'Take two copies and get a receipt on one. Several states take '
                  'this application online too - ask the range office.',
        ),
        const SizedBox(height: 12),
        ToolDonts(
          heading: hi ? 'जो न करें' : 'Do not',
          items: hi
              ? const [
                  'बाड़ में बिजली का करंट न छोड़ें — हर साल इससे लोग और जानवर मरते '
                      'हैं, और यह अपराध है',
                  'ज़हर या फंदा न लगाएँ — संरक्षित जानवर को मारना जेल तक ले जा सकता है',
                  'हाथी को अकेले भगाने की कोशिश न करें; वन विभाग की टीम बुलाएँ',
                ]
              : const [
                  'Do not run electric current through a fence - people and '
                      'animals die from it every year, and it is an offence',
                  'Do not use poison or snares - killing a protected animal can '
                      'lead to jail',
                  'Do not try to drive off an elephant alone; call the forest '
                      'department team',
                ],
        ),
        const SourceNote(text: 'PM Fasal Bima Yojana', url: _pmfbyUrl),
        const SourceNote(
            text: 'Ministry of Environment, Forest and Climate Change',
            url: _moefccUrl),
      ],
    );
  }
}

// --- Animal sick or several died --------------------------------------

class AnimalDeathsPage extends StatelessWidget {
  const AnimalDeathsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 15,
      title: hi ? 'पशु बीमार, या कई मर गए' : 'Animal sick or several died',
      children: [
        ToolAnswer(
          headline: hi ? 'अभी $vetHelpline पर फ़ोन' : 'Call $vetHelpline now',
          detail: hi
              ? '$vetHelpline चलती-फिरती पशु चिकित्सा सेवा का नंबर है। कुछ ही दिनों में '
                  'कई पशु बीमार हों या मरें, तो यह छूत की बीमारी हो सकती है — उसी दिन '
                  'पशुपालन विभाग या पंचायत को भी बताएँ। जल्दी ख़बर पूरे गाँव के पशुओं '
                  'को बचाती है।'
              : '$vetHelpline is the mobile veterinary service number. When '
                  'several animals fall sick or die within a few days it may be '
                  'an infectious disease - tell the animal husbandry department '
                  'or the panchayat the same day as well. Early word saves the '
                  'whole village\'s animals.',
          tone: ToolTone.bad,
          icon: Icons.phone_in_talk_outlined,
        ),
        const SizedBox(height: 12),
        ToolDonts(
          heading: hi ? 'मरे पशु के साथ' : 'With a dead animal',
          items: hi
              ? const [
                  'अचानक मरे पशु के नाक, मुँह या गुदा से काला ख़ून निकले तो उसे बिल्कुल '
                      'न खोलें, न खाल उतारें — यह एंथ्रेक्स हो सकता है, जो इंसानों को '
                      'भी होता है',
                  'मरे पशु का मांस न खाएँ, न बाँटें',
                  'शव को नदी, तालाब या खुले में न फेंकें; गहरे गड्ढे में चूने के साथ '
                      'दबाएँ',
                  'बीमार पशु को बाक़ियों से अलग करें, और उसका चारा-पानी अलग रखें',
                  'मुर्गियाँ एक साथ मरें तो उन्हें न छुएँ, न बेचें — पशुपालन विभाग को '
                      'बताएँ',
                ]
              : const [
                  'If an animal dies suddenly with dark blood from the nose, '
                      'mouth or anus, do not open it or skin it at all - it may '
                      'be anthrax, which people catch too',
                  'Do not eat or share the meat of an animal that died',
                  'Do not throw the carcass into a river, pond or the open; '
                      'bury it deep with lime',
                  'Separate a sick animal from the rest, with its own feed and '
                      'water',
                  'If poultry die together, do not touch or sell them - tell '
                      'the animal husbandry department',
                ],
        ),
        const SizedBox(height: 12),
        Text(hi ? 'मुआवज़ा कहाँ से' : 'Where compensation comes from',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'बीमित पशु: बीमा कंपनी को उसकी तय समय सीमा में सूचना, पशु डॉक्टर का '
                      'प्रमाण पत्र या पोस्टमार्टम, और कान के टैग की फ़ोटो',
                  'बर्ड फ़्लू या स्वाइन फ़ीवर जैसी बीमारी में सरकार के कहने पर मारे गए '
                      'पशुओं का मुआवज़ा सरकार देती है',
                  'बाढ़, बिजली गिरने या लू जैसी आपदा में मरे पशु: राज्य आपदा राहत से — '
                      'तहसील के सर्वे में नाम दर्ज कराएँ',
                  'जंगली जानवर के हमले में मरे पशु: वन विभाग से — रेंज ऑफ़िस में',
                ]
              : const [
                  'Insured animal: notify the insurer within its time limit, '
                      'with a vet\'s certificate or post-mortem and a photo of '
                      'the ear tag',
                  'In a disease such as bird flu or swine fever, animals culled '
                      'on government orders are compensated by the government',
                  'Animals lost in a disaster - flood, lightning, heat - from '
                      'state disaster relief; get them into the tehsil survey',
                  'Animals killed by a wild animal - from the forest '
                      'department, at the range office',
                ],
        ),
        const SourceNote(
            text: 'Department of Animal Husbandry and Dairying', url: _dahdUrl),
      ],
    );
  }
}

// --- Livestock vaccination calendar -----------------------------------

enum Herd { cattle, goats, poultry }

class VaccineCalendarPage extends StatefulWidget {
  const VaccineCalendarPage({super.key});

  @override
  State<VaccineCalendarPage> createState() => _VaccineCalendarPageState();
}

class _VaccineCalendarPageState extends State<VaccineCalendarPage> {
  Herd? _herd;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    final rows = switch (_herd) {
      Herd.cattle => hi
          ? const [
              ('खुरपका-मुँहपका (एफ़एमडी)', '4 महीने पर पहला, फिर हर 6 महीने'),
              ('ब्रुसेलोसिस', 'सिर्फ़ बछिया, 4 से 8 महीने पर, जीवन में एक बार'),
              ('गलघोंटू (एचएस)', '6 महीने से ऊपर, हर साल बरसात से पहले'),
              ('लंगड़ी (बीक्यू)', '6 महीने से ऊपर, हर साल बरसात से पहले'),
              ('लम्पी स्किन रोग', '4 महीने से ऊपर, हर साल'),
            ]
          : const [
              ('Foot and mouth disease (FMD)', 'First at 4 months, then every 6 months'),
              ('Brucellosis', 'Female calves only, at 4 to 8 months, once in life'),
              ('Haemorrhagic septicaemia (HS)', 'Over 6 months, every year before the rains'),
              ('Black quarter (BQ)', 'Over 6 months, every year before the rains'),
              ('Lumpy skin disease', 'Over 4 months, every year'),
            ],
      Herd.goats => hi
          ? const [
              ('पीपीआर (बकरी प्लेग)', '3 महीने से ऊपर, हर 3 साल'),
              ('एंटेरोटॉक्सीमिया', 'हर साल बरसात से पहले'),
              ('खुरपका-मुँहपका', 'हर 6 महीने'),
              ('बकरी चेचक', 'हर साल'),
            ]
          : const [
              ('PPR (goat plague)', 'Over 3 months, every 3 years'),
              ('Enterotoxaemia', 'Every year before the rains'),
              ('Foot and mouth disease', 'Every 6 months'),
              ('Goat pox', 'Every year'),
            ],
      Herd.poultry => hi
          ? const [
              ('रानीखेत', 'पहले हफ़्ते में, फिर विभाग के बताए अनुसार दोहराएँ'),
              ('मारेक्स', 'पहले दिन, हैचरी में'),
              ('गम्बोरो', 'दूसरे-तीसरे हफ़्ते'),
              ('फ़ाउल पॉक्स', 'छह-आठ हफ़्ते पर'),
            ]
          : const [
              ('Ranikhet (Newcastle disease)', 'In the first week, then repeat as the department advises'),
              ('Marek\'s disease', 'Day one, at the hatchery'),
              ('Gumboro', 'Second to third week'),
              ('Fowl pox', 'At six to eight weeks'),
            ],
      null => const <(String, String)>[],
    };

    return ToolScaffold(
      goal: 15,
      title: hi ? 'पशुओं के टीकों का कैलेंडर' : 'Livestock vaccination calendar',
      children: [
        ToolNote(hi
            ? 'यह राज्यों के पशुपालन विभाग का आम कार्यक्रम है, योजना बनाने के लिए। '
                'असली तारीख़ और खुराक शिविर का पशु डॉक्टर तय करता है। खुरपका-मुँहपका '
                'और ब्रुसेलोसिस के टीके राष्ट्रीय पशु रोग नियंत्रण कार्यक्रम में मुफ़्त '
                'लगते हैं।'
            : 'This is the common schedule state animal husbandry departments '
                'publish, for planning. The actual date and dose are the camp '
                'vet\'s call. FMD and brucellosis vaccines are free under the '
                'National Animal Disease Control Programme.'),
        ToolQuestion(hi ? 'कौन से पशु' : 'Which animals'),
        SelectionTile(
          label: hi ? 'गाय और भैंस' : 'Cattle and buffalo',
          selected: _herd == Herd.cattle,
          onTap: () => setState(() => _herd = Herd.cattle),
        ),
        SelectionTile(
          label: hi ? 'बकरी और भेड़' : 'Goats and sheep',
          selected: _herd == Herd.goats,
          onTap: () => setState(() => _herd = Herd.goats),
        ),
        SelectionTile(
          label: hi ? 'मुर्गी' : 'Poultry',
          selected: _herd == Herd.poultry,
          onTap: () => setState(() => _herd = Herd.poultry),
        ),
        if (rows.isNotEmpty) ...[
          const SizedBox(height: 10),
          for (final r in rows) ToolLine(r.$1, r.$2),
          const SizedBox(height: 10),
          ToolSteps(
            numbered: false,
            steps: hi
                ? const [
                    'टीके से दो-तीन हफ़्ते पहले कीड़े की दवा दें — टीका तब बेहतर काम '
                        'करता है',
                    'टीका लगने के बाद पशु एक-दो दिन सुस्त रहे या दूध थोड़ा घटे, तो यह '
                        'आम है',
                    'कान का टैग लगवाएँ — टीके का रिकॉर्ड और बीमा दोनों उसी से चलते हैं',
                    'शिविर की तारीख़ पंचायत, दूध समिति या $vetHelpline से पता करें',
                  ]
                : const [
                    'Deworm two to three weeks before vaccination - the vaccine '
                        'works better',
                    'An animal that is dull for a day or two, or gives a little '
                        'less milk, after the shot is normal',
                    'Get the ear tag fitted - vaccine records and insurance both '
                        'run on it',
                    'Find out the camp date from the panchayat, the milk '
                        'society, or $vetHelpline',
                  ],
          ),
        ],
        const SourceNote(
            text: 'Department of Animal Husbandry and Dairying', url: _dahdUrl),
      ],
    );
  }
}
