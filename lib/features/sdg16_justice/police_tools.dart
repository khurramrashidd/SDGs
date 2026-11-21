import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Police: an FIR refused, an arrest, bail, and a missing person.
///
/// Section numbers are from the Bharatiya Nagarik Suraksha Sanhita 2023
/// (BNSS), which replaced the Code of Criminal Procedure from 1 July 2024.
/// Old numbers are still what many officers and lawyers say aloud, so the
/// FIR screen gives both where it matters.

const _nalsaUrl = 'https://nalsa.gov.in/';
const _trackChildUrl = 'https://trackthemissingchild.gov.in/';
const _mhaUrl = 'https://www.mha.gov.in/';

const legalAidHelpline = '15100';
const childHelpline = '1098';

// --- FIR refused ------------------------------------------------------

class FirRefusedPage extends StatefulWidget {
  const FirRefusedPage({super.key});

  @override
  State<FirRefusedPage> createState() => _FirRefusedPageState();
}

class _FirRefusedPageState extends State<FirRefusedPage> {
  final _station = TextEditingController();
  final _date = TextEditingController();
  final _what = TextEditingController();

  @override
  void dispose() {
    for (final c in [_station, _date, _what]) {
      c.dispose();
    }
    super.dispose();
  }

  String _or(TextEditingController c) =>
      c.text.trim().isEmpty ? '______' : c.text.trim();

  String _letter(bool hi) {
    if (hi) {
      return 'सेवा में,\n'
          'पुलिस अधीक्षक, ज़िला ______\n\n'
          'विषय: थाना ${_or(_station)} द्वारा एफ़आईआर दर्ज न करने के संबंध में — '
          'भारतीय नागरिक सुरक्षा संहिता 2023 की धारा 173(4) के अंतर्गत\n\n'
          'महोदय/महोदया,\n\n'
          'दिनांक ${_or(_date)} को मैं थाना ${_or(_station)} में निम्न घटना की '
          'सूचना देने गया/गई: ${_or(_what)}।\n\n'
          'यह संज्ञेय अपराध है, फिर भी थाने ने एफ़आईआर दर्ज नहीं की। सर्वोच्च '
          'न्यायालय के ललिता कुमारी निर्णय (2013) के अनुसार संज्ञेय अपराध की सूचना '
          'पर एफ़आईआर दर्ज करना अनिवार्य है।\n\n'
          'अतः निवेदन है कि धारा 173(4) के अंतर्गत स्वयं जाँच करें या जाँच का '
          'निर्देश दें। मेरी लिखित सूचना की प्रति संलग्न है।\n\n'
          'दिनांक: ____________\n'
          'नाम: ____________\n'
          'पता: ____________\n'
          'फ़ोन: ____________';
    }
    return 'To,\n'
        'The Superintendent of Police, District ______\n\n'
        'Subject: Refusal by police station ${_or(_station)} to register an '
        'FIR - under section 173(4) of the Bharatiya Nagarik Suraksha Sanhita '
        '2023\n\n'
        'Sir / Madam,\n\n'
        'On ${_or(_date)} I went to police station ${_or(_station)} to report '
        'the following: ${_or(_what)}.\n\n'
        'This is a cognizable offence, yet the station did not register an '
        'FIR. Under the Supreme Court\'s judgment in Lalita Kumari (2013), '
        'registering an FIR on information of a cognizable offence is '
        'mandatory.\n\n'
        'I therefore request that you investigate the matter yourself or '
        'direct an investigation under section 173(4). A copy of my written '
        'information is attached.\n\n'
        'Date: ____________\n'
        'Name: ____________\n'
        'Address: ____________\n'
        'Phone: ____________';
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 16,
      title: hi ? 'पुलिस एफ़आईआर दर्ज नहीं कर रही' : 'Police will not register my FIR',
      children: [
        ToolNote(hi
            ? 'संज्ञेय अपराध — चोरी, मारपीट, धमकी, छेड़छाड़, धोखाधड़ी जैसे — की सूचना '
                'पर एफ़आईआर दर्ज करना पुलिस का कर्तव्य है, विकल्प नहीं। एफ़आईआर किसी '
                'भी थाने में दी जा सकती है, चाहे घटना कहीं की हो ("ज़ीरो एफ़आईआर"), और '
                'उसकी नक़ल मुफ़्त मिलती है।'
            : 'For a cognizable offence - theft, assault, threats, sexual '
                'harassment, cheating and the like - registering the FIR is the '
                'police\'s duty, not a choice. It can be given at any station, '
                'wherever the incident happened (a "zero FIR"), and the copy is '
                'free.'),
        const SizedBox(height: 12),
        Text(hi ? 'अगले तीन क़दम, क्रम से — तीनों मुफ़्त' : 'The next three steps, in order - all free',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'थाने में सूचना लिखकर दें और उसकी एक नक़ल पर थाने की मुहर और तारीख़ '
                      'लगवाएँ। मुहर न लगाएँ तो रजिस्टर्ड डाक से थाने को भेजें। कई राज्यों '
                      'में ई-एफ़आईआर ऑनलाइन भी होती है।',
                  'पुलिस अधीक्षक (एसपी) को लिखित शिकायत — धारा 173(4), बीएनएसएस (पुरानी '
                      'सीआरपीसी की धारा 154(3))। नीचे का पत्र इसी के लिए है। रजिस्टर्ड डाक '
                      'से भेजें और रसीद रखें।',
                  'फिर भी न हो तो मजिस्ट्रेट के सामने आवेदन — धारा 175(3), बीएनएसएस '
                      '(पुरानी धारा 156(3))। इसके साथ एसपी को भेजी शिकायत की नक़ल और एक '
                      'शपथपत्र लगता है। ज़िला विधिक सेवा प्राधिकरण से मुफ़्त वकील मिलता है।',
                ]
              : const [
                  'Give the information in writing at the station and get a '
                      'copy stamped and dated. If they will not stamp it, send '
                      'it to the station by registered post. Many states also '
                      'take an e-FIR online.',
                  'A written complaint to the Superintendent of Police - '
                      'section 173(4) BNSS (old CrPC section 154(3)). The letter '
                      'below is for this. Send it by registered post and keep '
                      'the receipt.',
                  'If that fails, an application before the magistrate - '
                      'section 175(3) BNSS (old section 156(3)). It needs a copy '
                      'of the complaint sent to the SP and an affidavit. The '
                      'District Legal Services Authority gives a free lawyer.',
                ],
        ),
        ToolQuestion(hi ? 'एसपी को पत्र' : 'Letter to the SP'),
        ToolText(
          controller: _station,
          label: hi ? 'थाने का नाम' : 'Police station',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolText(
          controller: _date,
          label: hi ? 'थाने गए उस दिन की तारीख़' : 'Date you went to the station',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolText(
          controller: _what,
          label: hi ? 'क्या हुआ, छोटे में' : 'What happened, briefly',
          maxLength: 300,
          maxLines: 4,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        CopyBlock(
          text: _letter(hi),
          note: hi
              ? 'साथ लगाएँ: थाने को दी गई लिखित सूचना की नक़ल, और कोई सबूत — फ़ोटो, '
                  'मेडिकल पर्चा, संदेश।'
              : 'Attach: a copy of the written information you gave the station, '
                  'and any evidence - photos, a medical slip, messages.',
        ),
        const SizedBox(height: 10),
        ToolNote(hi
            ? 'कुछ अपराधों में, जिनकी सज़ा 3 से 7 साल है, पुलिस एफ़आईआर से पहले 14 दिन '
                'में शुरुआती जाँच कर सकती है — पर उसे यह लिखकर बताना होता है।'
            : 'For some offences carrying 3 to 7 years, the police may hold a '
                'preliminary enquiry of up to 14 days before the FIR - but they '
                'have to say so in writing.'),
        const SourceNote(
            text: 'National Legal Services Authority', url: _nalsaUrl),
      ],
    );
  }
}

// --- Arrested relative ------------------------------------------------

class ArrestPage extends StatelessWidget {
  const ArrestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 16,
      title: hi ? 'घर का कोई गिरफ़्तार: पहले 24 घंटे' : 'Arrested relative: first 24 hours',
      children: [
        ToolAnswer(
          headline: hi ? 'पहले मुफ़्त वकील: $legalAidHelpline' : 'A free lawyer first: $legalAidHelpline',
          detail: hi
              ? 'हिरासत में लिए गए हर व्यक्ति को मुफ़्त कानूनी सहायता का हक़ है, आय चाहे '
                  'जो हो। राष्ट्रीय विधिक सेवा हेल्पलाइन $legalAidHelpline पर फ़ोन करें, या '
                  'ज़िला न्यायालय में ज़िला विधिक सेवा प्राधिकरण के दफ़्तर जाएँ। कई थानों '
                  'और अदालतों में उनके "रिमांड वकील" बैठते हैं।'
              : 'Everyone in custody has a right to free legal aid, whatever '
                  'their income. Call the national legal services helpline on '
                  '$legalAidHelpline, or go to the District Legal Services '
                  'Authority\'s office at the district court. Many stations and '
                  'courts have their "remand lawyers" on hand.',
          tone: ToolTone.bad,
          icon: Icons.gavel_outlined,
        ),
        const SizedBox(height: 12),
        Text(hi ? 'पुलिस को क्या करना ही है' : 'What the police must do',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'गिरफ़्तारी का ज्ञापन (अरेस्ट मेमो) बनाना, जिस पर एक गवाह — परिवार का '
                      'या इलाक़े का कोई — दस्तख़त करे, और समय-तारीख़ लिखी हो',
                  'गिरफ़्तार व्यक्ति को गिरफ़्तारी का कारण बताना, और ज़मानती अपराध हो '
                      'तो यह बताना कि वह ज़मानत पर छूट सकता है',
                  'उसके बताए किसी रिश्तेदार या दोस्त को गिरफ़्तारी और जगह की सूचना देना',
                  '24 घंटे के भीतर मजिस्ट्रेट के सामने पेश करना — रास्ते का समय छोड़कर',
                  'डॉक्टरी जाँच कराना',
                  'पूछताछ के दौरान वकील से मिलने देना (पूरे समय नहीं, पर मिलने देना)',
                  'महिला को महिला पुलिस ही गिरफ़्तार करे, और सूरज ढलने के बाद या उगने से '
                      'पहले नहीं — सिवाय मजिस्ट्रेट की अनुमति के',
                ]
              : const [
                  'Make an arrest memo, signed by a witness - a family member '
                      'or someone local - with the time and date on it',
                  'Tell the arrested person the grounds of arrest, and for a '
                      'bailable offence, that they can be released on bail',
                  'Inform a relative or friend they name of the arrest and the '
                      'place',
                  'Produce them before a magistrate within 24 hours, not '
                      'counting travel time',
                  'Have a medical examination done',
                  'Let them meet a lawyer during questioning (not throughout, '
                      'but meet)',
                  'A woman is arrested only by a woman officer, and not after '
                      'sunset or before sunrise, except with a magistrate\'s '
                      'permission',
                ],
        ),
        const SizedBox(height: 12),
        Text(hi ? 'परिवार क्या करे' : 'What the family should do',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'पता करें कि किस थाने में हैं, और एफ़आईआर संख्या और धाराएँ क्या हैं — '
                      'एफ़आईआर की नक़ल माँगें।',
                  'पहचान पत्र, पते का प्रमाण, और नौकरी या ज़मीन के काग़ज़ तैयार रखें — '
                      'ज़मानत में ज़मानतदार और पक्के पते की ज़रूरत पड़ती है।',
                  'रोज़ की दवा चलती हो तो वह और पर्चा थाने ले जाएँ।',
                  'पेशी के समय अदालत पहुँचें; वकील वहीं ज़मानत की अर्ज़ी लगा सकता है।',
                ]
              : const [
                  'Find out which station, and the FIR number and sections - ask '
                      'for a copy of the FIR.',
                  'Have ID, proof of address, and job or land papers ready - '
                      'bail needs a surety and a fixed address.',
                  'If they take a daily medicine, take it and the prescription '
                      'to the station.',
                  'Be at court for the production; the lawyer can move the '
                      'bail application right there.',
                ],
        ),
        ToolDonts(
          heading: hi ? 'न करें' : 'Do not',
          items: hi
              ? const [
                  '"छुड़वाने" के नाम पर किसी बिचौलिए को पैसा न दें',
                  'बिना पढ़े किसी काग़ज़ पर दस्तख़त न करें, न करवाएँ',
                  'थाने में दिया गया इक़बालिया बयान अदालत में सबूत नहीं बनता — दबाव में '
                      'कुछ न लिखें',
                ]
              : const [
                  'Do not pay any middleman to "get them out"',
                  'Do not sign, or let them sign, anything unread',
                  'A confession made to the police is not evidence in court - do '
                      'not write anything under pressure',
                ],
        ),
        const SourceNote(
            text: 'National Legal Services Authority', url: _nalsaUrl),
      ],
    );
  }
}

// --- Bailable or not --------------------------------------------------

enum BailKind { bailable, nonBailable, notArrested }

class BailPage extends StatefulWidget {
  const BailPage({super.key});

  @override
  State<BailPage> createState() => _BailPageState();
}

class _BailPageState extends State<BailPage> {
  BailKind? _kind;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 16,
      title: hi ? 'क्या अपराध ज़मानती है' : 'Is the offence bailable',
      children: [
        ToolNote(hi
            ? 'एफ़आईआर में लिखी धाराओं से पता चलता है कि अपराध ज़मानती है या नहीं — '
                'भारतीय नागरिक सुरक्षा संहिता की पहली अनुसूची में हर अपराध के सामने यह '
                'लिखा है। पुलिस को गिरफ़्तार व्यक्ति को यह बताना होता है। वकील या ज़िला '
                'विधिक सेवा प्राधिकरण से धाराएँ दिखाकर पक्का कर लें।'
            : 'The sections written in the FIR tell you whether the offence is '
                'bailable - the First Schedule of the Bharatiya Nagarik Suraksha '
                'Sanhita says so against each offence. The police have to tell '
                'the arrested person. Confirm by showing the sections to a '
                'lawyer or the District Legal Services Authority.'),
        ToolQuestion(hi ? 'स्थिति क्या है' : 'What is the situation'),
        SelectionTile(
          label: hi ? 'ज़मानती अपराध' : 'A bailable offence',
          selected: _kind == BailKind.bailable,
          onTap: () => setState(() => _kind = BailKind.bailable),
        ),
        SelectionTile(
          label: hi ? 'ग़ैर-ज़मानती अपराध' : 'A non-bailable offence',
          selected: _kind == BailKind.nonBailable,
          onTap: () => setState(() => _kind = BailKind.nonBailable),
        ),
        SelectionTile(
          label: hi ? 'अभी गिरफ़्तार नहीं, पर डर है' : 'Not arrested yet, but afraid of it',
          selected: _kind == BailKind.notArrested,
          onTap: () => setState(() => _kind = BailKind.notArrested),
        ),
        if (_kind == BailKind.bailable)
          ToolAnswer(
            headline: hi ? 'ज़मानत हक़ है' : 'Bail is a right',
            detail: hi
                ? 'ज़मानती अपराध में ज़मानत माँगने पर देनी ही होती है — थाने में भी, और '
                    'अदालत में भी। आम तौर पर एक मुचलका (बॉन्ड) और कभी-कभी एक ज़मानतदार '
                    'लगता है। जो व्यक्ति ग़रीबी के कारण ज़मानत की रक़म न दे सके, उसे बिना '
                    'ज़मानतदार के, सिर्फ़ मुचलके पर छोड़ा जा सकता है।'
                : 'In a bailable offence, bail has to be granted when asked for '
                    '- at the station and in court. Usually a bond, and '
                    'sometimes a surety, is needed. A person too poor to furnish '
                    'the bail amount can be released on a bond alone, without a '
                    'surety.',
            tone: ToolTone.good,
            icon: Icons.lock_open_outlined,
          ),
        if (_kind == BailKind.nonBailable)
          ToolAnswer(
            headline: hi ? 'ज़मानत अदालत की मर्ज़ी से' : 'Bail is at the court\'s discretion',
            detail: hi
                ? 'ग़ैर-ज़मानती अपराध में भी ज़मानत मिल सकती है, पर यह अदालत तय करती है '
                    '— पहले मजिस्ट्रेट, न मिले तो सत्र न्यायालय, फिर उच्च न्यायालय। दो '
                    'नियम काम के हैं: (1) पुलिस तय समय में आरोप पत्र न दे — ज़्यादातर '
                    'मामलों में 60 दिन, गंभीर में 90 — तो "डिफ़ॉल्ट ज़मानत" का हक़ बनता है। '
                    '(2) पहली बार के आरोपी ने अधिकतम सज़ा का एक-तिहाई समय विचाराधीन क़ैद '
                    'में काट लिया हो तो छूटने का हक़ है। दोनों के लिए वकील से तुरंत बात करें।'
                : 'Bail can be had even for a non-bailable offence, but the court '
                    'decides - first the magistrate, then the sessions court, '
                    'then the High Court. Two rules are worth knowing: (1) if '
                    'the police do not file the charge sheet in time - 60 days '
                    'in most cases, 90 in grave ones - a right to "default bail" '
                    'arises. (2) A first-time accused who has spent one third of '
                    'the maximum sentence as an undertrial is entitled to '
                    'release. Talk to a lawyer about both at once.',
            tone: ToolTone.plain,
            icon: Icons.balance_outlined,
          ),
        if (_kind == BailKind.notArrested)
          ToolAnswer(
            headline: hi ? 'अग्रिम ज़मानत' : 'Anticipatory bail',
            detail: hi
                ? 'ग़ैर-ज़मानती अपराध में गिरफ़्तारी का डर हो तो सत्र न्यायालय या उच्च '
                    'न्यायालय से अग्रिम ज़मानत माँगी जा सकती है — गिरफ़्तारी से पहले। '
                    'अदालत शर्तें लगा सकती है, जैसे पूछताछ के लिए हाज़िर होना। इसके लिए '
                    'वकील चाहिए; ज़िला विधिक सेवा प्राधिकरण से मुफ़्त मिल सकता है।'
                : 'If arrest for a non-bailable offence is feared, anticipatory '
                    'bail can be sought from the sessions court or the High '
                    'Court - before the arrest. The court may set conditions, '
                    'such as appearing for questioning. This needs a lawyer; one '
                    'may be had free from the District Legal Services Authority.',
            tone: ToolTone.plain,
            icon: Icons.shield_outlined,
          ),
        if (_kind != null) ...[
          const SizedBox(height: 10),
          ToolNote(hi
              ? 'मुफ़्त कानूनी सहायता: $legalAidHelpline।'
              : 'Free legal aid: $legalAidHelpline.'),
          const SourceNote(
              text: 'National Legal Services Authority', url: _nalsaUrl),
        ],
      ],
    );
  }
}

// --- Missing person or child ------------------------------------------

class MissingPersonPage extends StatelessWidget {
  const MissingPersonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 16,
      title: hi ? 'कोई व्यक्ति या बच्चा लापता' : 'Missing person or child',
      children: [
        ToolAnswer(
          headline: hi ? '24 घंटे इंतज़ार का कोई नियम नहीं' : 'There is no 24-hour waiting rule',
          detail: hi
              ? 'लापता होने की रिपोर्ट तुरंत दी जा सकती है, और पहले घंटे सबसे क़ीमती '
                  'हैं। अभी 112 पर, और पास के थाने में जाएँ। बच्चा हो तो $childHelpline '
                  '(चाइल्डलाइन) पर भी। सर्वोच्च न्यायालय के निर्देश के अनुसार लापता बच्चे की '
                  'हर शिकायत पर एफ़आईआर दर्ज होनी चाहिए।'
              : 'A missing report can be made at once, and the first hours are '
                  'the most valuable. Call 112 now and go to the nearest station. '
                  'For a child, also $childHelpline (Childline). Under the '
                  'Supreme Court\'s directions, every complaint of a missing '
                  'child must be registered as an FIR.',
          tone: ToolTone.bad,
          icon: Icons.person_search_outlined,
        ),
        const SizedBox(height: 12),
        Text(hi ? 'थाने साथ ले जाएँ' : 'Take to the station',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'हाल की साफ़ फ़ोटो — फ़ोन में भी, छपी भी',
                  'आख़िरी बार कब, कहाँ, किसके साथ देखा गया',
                  'कौन से कपड़े, जूते, बैग पहने थे',
                  'शरीर का कोई निशान, क़द, बोली',
                  'उसका फ़ोन नंबर, और जिन दोस्तों या रिश्तेदारों के पास जा सकता है',
                  'कोई बीमारी या रोज़ की दवा',
                ]
              : const [
                  'A recent clear photo - on the phone and printed',
                  'When, where and with whom they were last seen',
                  'What clothes, shoes and bag they had',
                  'Any mark on the body, height, how they speak',
                  'Their phone number, and friends or relatives they might go to',
                  'Any illness or daily medicine',
                ],
        ),
        const SizedBox(height: 12),
        Text(hi ? 'साथ-साथ' : 'Alongside',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'एफ़आईआर या लापता रिपोर्ट की नक़ल लें — आगे हर जगह यही लगती है।',
                  'पास के बस अड्डे, रेलवे स्टेशन (रेलवे पुलिस और आरपीएफ़) और अस्पतालों '
                      'में फ़ोटो के साथ बताएँ।',
                  'बच्चे के लिए "ट्रैक द मिसिंग चाइल्ड" पोर्टल पर पुलिस जानकारी डालती है — '
                      'वहाँ मिले बच्चों की फ़ोटो भी देखी जा सकती हैं।',
                  'सोशल मीडिया पर डालें तो सिर्फ़ फ़ोटो, नाम और थाने का नंबर दें — अपना '
                      'घर का पता और निजी नंबर नहीं; "इनाम" के नाम पर ठग फ़ोन करते हैं।',
                ]
              : const [
                  'Get a copy of the FIR or missing report - it is needed '
                      'everywhere after.',
                  'Tell the nearby bus stand, railway station (railway police '
                      'and RPF) and hospitals, with the photo.',
                  'For a child, the police put the details on the "Track the '
                      'Missing Child" portal - photos of found children can be '
                      'seen there too.',
                  'If you post on social media, give only the photo, name and '
                      'the station\'s number - not your home address or private '
                      'number; fraudsters call claiming a "reward".',
                ],
        ),
        const SourceNote(
            text: 'Track the Missing Child', url: _trackChildUrl),
        const SourceNote(text: 'Ministry of Home Affairs', url: _mhaUrl),
      ],
    );
  }
}
