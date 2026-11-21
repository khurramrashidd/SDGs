import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Four screens about the supply itself: getting it, fixing it, paying for
/// it, and what happens when it fails altogether.
///
/// The thread running through all four is the same: a village water
/// complaint that names a date, a source and a number gets attended to, and
/// one that says "there is no water here" does not. So each screen ends by
/// building the specific sentence rather than telling the reader to
/// complain.

const _jjmUrl = 'https://jaljeevanmission.gov.in/';
const _jjmDashUrl = 'https://ejalshakti.gov.in/';

/// The Jal Jeevan Mission service standard, in litres per person per day.
const jjmLitresPerPersonPerDay = 55;

// --- Tap connection ---------------------------------------------------

enum TapProblem { noConnection, connectionDry, lowPressure, badQuality }

class TapConnectionPage extends StatefulWidget {
  const TapConnectionPage({super.key});

  @override
  State<TapConnectionPage> createState() => _TapConnectionPageState();
}

class _TapConnectionPageState extends State<TapConnectionPage> {
  TapProblem? _problem;
  final _people = TextEditingController();

  @override
  void dispose() {
    _people.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final people = int.tryParse(_people.text.trim());
    final due = people == null ? null : people * jjmLitresPerPersonPerDay;

    Widget pick(TapProblem p, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _problem == p,
          onTap: () => setState(() => _problem = p),
        );

    return ToolScaffold(
      goal: 6,
      title: hi ? 'नल नहीं मिला या सूखा है' : 'No tap connection, or a dry one',
      children: [
        ToolNote(hi
            ? 'जल जीवन मिशन में हर ग्रामीण घर को नल से पानी देने का लक्ष्य है, और '
                'मानक है हर व्यक्ति को रोज़ $jjmLitresPerPersonPerDay लीटर। यह संख्या '
                'याद रखने लायक़ है: शिकायत में "पानी कम आता है" से कुछ नहीं होता, '
                '"हमारे घर में आठ लोग हैं, मानक से $jjmLitresPerPersonPerDay लीटर '
                'प्रति व्यक्ति बनता है, मिलता इतना है" से होता है।'
            : 'The Jal Jeevan Mission aims to give every rural household a '
                'tap connection, at a standard of '
                '$jjmLitresPerPersonPerDay litres per person per day. That '
                'number is worth remembering: "we do not get enough water" '
                'achieves nothing in a complaint, while "there are eight of '
                'us, the standard is $jjmLitresPerPersonPerDay litres each, '
                'and we get this much" does.'),
        ToolQuestion(hi ? 'क्या दिक़्क़त है' : 'What is the problem'),
        pick(TapProblem.noConnection, 'No connection has been given at all',
            'नल कनेक्शन मिला ही नहीं'),
        pick(TapProblem.connectionDry, 'The tap is installed but no water '
            'comes', 'नल लगा है लेकिन पानी नहीं आता'),
        pick(TapProblem.lowPressure, 'Water comes, but far too little',
            'पानी आता है, लेकिन बहुत कम'),
        pick(TapProblem.badQuality, 'Water comes but it is not fit to drink',
            'पानी आता है लेकिन पीने लायक़ नहीं'),
        if (_problem != null) ...[
          ToolQuestion(hi ? 'घर में कितने लोग' : 'How many people in the house'),
          ToolNumber(
            controller: _people,
            label: hi ? 'लोग' : 'People',
            maxDigits: 3,
            icon: Icons.groups_outlined,
            onChanged: (_) => setState(() {}),
          ),
          if (due != null && due > 0)
            ToolAnswer(
              headline: hi
                  ? 'मानक से रोज़ $due लीटर'
                  : '$due litres a day by the standard',
              detail: hi
                  ? '$people लोगों के लिए, $jjmLitresPerPersonPerDay लीटर प्रति '
                      'व्यक्ति के हिसाब से। यह संख्या अपनी शिकायत में लिखें, और साथ में '
                      'यह भी कि असल में कितना मिलता है — बाल्टियों में गिनकर बता दें तो '
                      'और अच्छा।'
                  : 'For $people people at $jjmLitresPerPersonPerDay litres '
                      'each. Put that number in your complaint, with what you '
                      'actually get beside it - counted in buckets is better '
                      'still.',
              tone: ToolTone.plain,
              icon: Icons.water_drop_outlined,
            ),
          const SizedBox(height: 14),
          Text(hi ? 'शिकायत इस क्रम में' : 'Complain in this order',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'ग्राम पंचायत की जल एवं स्वच्छता समिति (पानी समिति / VWSC) में '
                        'बात उठाएँ। गाँव की योजना यही समिति चलाती है, और बैठक की '
                        'कार्यवाही लिखी जाती है — माँगें कि आपकी बात दर्ज हो।',
                    'ग्राम पंचायत सचिव या सरपंच को लिखित अर्ज़ी दें और पावती लें।',
                    'ब्लॉक के जल विभाग (PHED या जल निगम) के अभियंता को लिखें।',
                    'ज़िला जल एवं स्वच्छता मिशन, और राज्य की जल जीवन मिशन हेल्पलाइन।',
                    'कहीं न सुना जाए तो ज़िलाधिकारी के जनसुनवाई में, और राज्य के '
                        'शिकायत पोर्टल पर।',
                  ]
                : const [
                    'Raise it in the gram panchayat\'s water and sanitation '
                        'committee (the Pani Samiti or VWSC). That committee '
                        'runs the village scheme, and its proceedings are '
                        'written down - ask for your point to be recorded.',
                    'Give a written application to the panchayat secretary or '
                        'sarpanch, and take the acknowledgement.',
                    'Write to the engineer at the block water department '
                        '(PHED or Jal Nigam).',
                    'The district water and sanitation mission, and the '
                        'state\'s Jal Jeevan Mission helpline.',
                    'If nobody listens, the district officer\'s public '
                        'hearing, and the state grievance portal.',
                  ],
          ),
          const SizedBox(height: 10),
          Text(hi ? 'शिकायत का मसौदा' : 'A draft complaint',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          CopyBlock(
            text: hi
                ? 'सेवा में,\nअधिशासी अभियंता, जल विभाग / ग्राम पंचायत सचिव\n\n'
                    'विषय: जल जीवन मिशन के अंतर्गत नल जल आपूर्ति के संबंध में\n\n'
                    'महोदय,\n\nमेरा नाम ______ है और मैं ग्राम ______, पंचायत ______, '
                    'ब्लॉक ______ का निवासी हूँ। मेरे घर में ${people ?? '__'} सदस्य '
                    'हैं।\n\n'
                    'जल जीवन मिशन के मानक के अनुसार प्रति व्यक्ति प्रतिदिन '
                    '$jjmLitresPerPersonPerDay लीटर जल की आपूर्ति होनी चाहिए, अर्थात् '
                    'मेरे परिवार के लिए प्रतिदिन ${due ?? '__'} लीटर। वर्तमान स्थिति '
                    'इस प्रकार है: ______ (क्या मिलता है, कब से, कितने दिन से)।\n\n'
                    'कृपया इस संबंध में आवश्यक कार्रवाई कर मुझे लिखित में सूचित करें।\n\n'
                    'दिनांक: ______\nनाम: ______\nमोबाइल: ______\nहस्ताक्षर'
                : 'To,\nThe Executive Engineer, Water Department / Gram '
                    'Panchayat Secretary\n\n'
                    'Subject: Piped water supply under the Jal Jeevan '
                    'Mission\n\n'
                    'Sir/Madam,\n\nMy name is ______ and I live in village '
                    '______, panchayat ______, block ______. There are '
                    '${people ?? '__'} members in my household.\n\n'
                    'The Jal Jeevan Mission standard is '
                    '$jjmLitresPerPersonPerDay litres per person per day, '
                    'which comes to ${due ?? '__'} litres a day for my '
                    'family. The present position is: ______ (what you get, '
                    'since when, for how many days).\n\n'
                    'I request the necessary action and a reply in '
                    'writing.\n\n'
                    'Date: ______\nName: ______\nMobile: ______\nSignature',
          ),
          ToolNote(hi
              ? 'अर्ज़ी की एक नक़ल अपने पास रखें और उस पर पावती की मुहर लगवाएँ। जल '
                  'जीवन मिशन के आँकड़े ejalshakti पोर्टल पर सार्वजनिक हैं — वहाँ अपने '
                  'गाँव का नाम देखकर पता चल जाता है कि काग़ज़ पर आपके घर को कनेक्शन '
                  'दर्ज है या नहीं, और यह जानकारी शिकायत में बहुत काम आती है।'
              : 'Keep a copy of the application with the acknowledgement '
                  'stamp on it. Jal Jeevan Mission data is public on the '
                  'ejalshakti portal - looking up your village shows whether '
                  'your house is recorded as connected on paper, which is '
                  'very useful in a complaint.'),
          const SourceNote(text: 'Jal Jeevan Mission', url: _jjmUrl),
          const SourceNote(
              text: 'ejalshakti - village-level data', url: _jjmDashUrl),
        ],
      ],
    );
  }
}

// --- Handpump ---------------------------------------------------------

enum PumpFault { noWater, hardToPump, dirtyWater, brokenHandle, platform }

class HandpumpPage extends StatefulWidget {
  const HandpumpPage({super.key});

  @override
  State<HandpumpPage> createState() => _HandpumpPageState();
}

class _HandpumpPageState extends State<HandpumpPage> {
  PumpFault? _fault;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    Widget pick(PumpFault f, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _fault == f,
          onTap: () => setState(() => _fault = f),
        );

    return ToolScaffold(
      goal: 6,
      title: hi ? 'हैंडपंप ख़राब है' : 'The handpump is broken',
      children: [
        ToolNote(hi
            ? 'हैंडपंप की मरम्मत ग्राम पंचायत और जल विभाग की ज़िम्मेदारी है, और '
                'ज़्यादातर राज्यों ने इसके लिए समय-सीमा तय कर रखी है — आमतौर पर कुछ '
                'दिनों की। समय-सीमा हर राज्य की अलग है, इसलिए ब्लॉक कार्यालय से अपने '
                'राज्य की सीमा पूछकर शिकायत में उसी का हवाला दें।'
            : 'Repairing a handpump is the gram panchayat\'s and the water '
                'department\'s responsibility, and most states set a time '
                'limit for it - usually a few days. The limit differs by '
                'state, so ask the block office what yours is and quote it in '
                'the complaint.'),
        ToolQuestion(hi ? 'क्या ख़राबी है' : 'What is wrong with it'),
        pick(PumpFault.noWater, 'It pumps but no water comes',
            'चलाने पर पानी नहीं आता'),
        pick(PumpFault.hardToPump, 'The handle has gone very heavy',
            'हत्था बहुत भारी हो गया है'),
        pick(PumpFault.dirtyWater, 'The water is dirty, muddy or smells',
            'पानी गंदा, मटमैला है या बदबू आती है'),
        pick(PumpFault.brokenHandle, 'The handle or a part is broken',
            'हत्था या कोई पुर्ज़ा टूट गया है'),
        pick(PumpFault.platform, 'The platform is broken and waste water '
            'collects around it', 'चबूतरा टूटा है और आसपास गंदा पानी जमा होता है'),
        if (_fault != null) ...[
          ToolAnswer(
            headline: switch (_fault!) {
              PumpFault.noWater =>
                hi ? 'पहले देखें कि जलस्तर गिरा है या पुर्ज़ा ख़राब' : 'First: a dropped water table, or a failed part',
              PumpFault.hardToPump =>
                hi ? 'आमतौर पर बेयरिंग या चेन की दिक़्क़त' : 'Usually a bearing or the chain',
              PumpFault.dirtyWater =>
                hi ? 'यह मरम्मत से ज़्यादा ज़रूरी बात है' : 'This matters more than the repair',
              PumpFault.brokenHandle =>
                hi ? 'यह सीधी मरम्मत है' : 'This is a straightforward repair',
              PumpFault.platform =>
                hi ? 'चबूतरा टूटना पानी गंदा होने की जड़ है' : 'A broken platform is how the water gets dirty',
            },
            detail: switch (_fault!) {
              PumpFault.noWater => hi
                  ? 'गर्मी में जलस्तर गिरने से भी पानी आना बंद हो जाता है — ऐसे में '
                      'पाइप बढ़वाने की ज़रूरत पड़ती है, जो मिस्त्री का नहीं विभाग का काम '
                      'है। अगर आसपास के दूसरे हैंडपंप चल रहे हैं तो वजह पुर्ज़ा है, '
                      'जलस्तर नहीं। शिकायत में यह बात लिखें — इससे विभाग को पता चल '
                      'जाता है कि क्या भेजना है।'
                  : 'In summer a dropped water table also stops the water, '
                      'and then the pipe has to be deepened - a department '
                      'job, not a mechanic\'s. If other handpumps nearby are '
                      'working, the cause is a part rather than the water '
                      'table. Say which in the complaint - it tells the '
                      'department what to send.',
              PumpFault.hardToPump => hi
                  ? 'भारी हत्था आमतौर पर छोटी मरम्मत है और हैंडपंप मिस्त्री एक चक्कर '
                      'में ठीक कर देता है। कई ज़िलों में ब्लॉक स्तर पर मिस्त्री तैनात '
                      'होते हैं और उनका नंबर पंचायत के पास होता है।'
                  : 'A heavy handle is usually a small repair that a handpump '
                      'mechanic fixes in one visit. Many districts post '
                      'mechanics at the block, and the panchayat has the '
                      'number.',
              PumpFault.dirtyWater => hi
                  ? 'गंदा या बदबूदार पानी आने का मतलब है कि बाहर का पानी नीचे तक '
                      'पहुँच रहा है — अक्सर टूटे चबूतरे या पास के गड्ढे से। जब तक ठीक न '
                      'हो, इस पानी को पीने से पहले उबालें या क्लोरीन डालें, और इसकी '
                      'जाँच कराएँ। यह सिर्फ़ मरम्मत की नहीं, सेहत की बात है।'
                  : 'Dirty or smelly water means surface water is reaching '
                      'the bore - usually through a broken platform or a pit '
                      'nearby. Until it is fixed, boil or chlorinate this '
                      'water before drinking, and get it tested. This is a '
                      'health matter, not only a repair.',
              PumpFault.brokenHandle => hi
                  ? 'पुर्ज़ा टूटना मिस्त्री का सीधा काम है। शिकायत में हैंडपंप का नंबर '
                      'या ठीक जगह ज़रूर लिखें — "गाँव में हैंडपंप ख़राब है" से मिस्त्री '
                      'ढूँढ़ता रह जाता है।'
                  : 'A broken part is a mechanic\'s straightforward job. Put '
                      'the handpump\'s number or its exact location in the '
                      'complaint - "a handpump in the village is broken" '
                      'leaves the mechanic hunting.',
              PumpFault.platform => hi
                  ? 'टूटे चबूतरे से इस्तेमाल किया हुआ गंदा पानी वापस बोर के पास जमा '
                      'होता है और रिसकर नीचे चला जाता है। यही वजह है कि चबूतरे की '
                      'मरम्मत को छोटी बात नहीं मानना चाहिए — पूरे मोहल्ले का पीने का '
                      'पानी इसी पर टिका है। सोख़्ता गड्ढा (सोक पिट) भी साथ बनवाएँ।'
                  : 'A broken platform lets used water pool around the bore '
                      'and seep down. That is why platform repair is not a '
                      'small matter - the whole neighbourhood\'s drinking '
                      'water rests on it. Ask for a soak pit alongside.',
            },
            tone: _fault == PumpFault.dirtyWater
                ? ToolTone.warn
                : ToolTone.plain,
            icon: Icons.build_outlined,
          ),
          const SizedBox(height: 14),
          const ToolChecklist(
            storageKey: 'handpump_complaint_v1',
            introEn: 'Put these in the complaint. A complaint with them gets '
                'a mechanic; one without gets filed.',
            introHi: 'शिकायत में ये लिखें। इनके साथ मिस्त्री आता है, इनके बिना '
                'शिकायत फ़ाइल में चली जाती है।',
            items: [
              CheckItem('where', 'Exactly where it is - the hamlet, the '
                  'landmark, the handpump number if it has one',
                  'ठीक जगह — टोला, पहचान की जगह, और नंबर हो तो नंबर'),
              CheckItem('since', 'Since what date it has been out',
                  'किस तारीख़ से ख़राब है'),
              CheckItem('what', 'What exactly is wrong',
                  'ठीक-ठीक क्या ख़राबी है'),
              CheckItem('howmany', 'How many households use it',
                  'कितने घर इसी से पानी लेते हैं',
                  noteEn: 'This is the line that moves it up the queue, and '
                      'it is the one people leave out.',
                  noteHi: 'यही वह पंक्ति है जो शिकायत को क़तार में ऊपर ले जाती है, '
                      'और यही लोग छोड़ देते हैं।'),
              CheckItem('next', 'Where people are getting water instead, and '
                  'how far it is', 'अभी लोग कहाँ से पानी ला रहे हैं, और कितनी दूर'),
              CheckItem('ack', 'Take the acknowledgement, and the name of '
                  'who took the complaint',
                  'पावती लें, और जिसने शिकायत ली उसका नाम'),
            ],
          ),
          const SourceNote(text: 'Jal Jeevan Mission', url: _jjmUrl),
        ],
      ],
    );
  }
}

// --- Water bill -------------------------------------------------------

class WaterBillPage extends StatefulWidget {
  const WaterBillPage({super.key});

  @override
  State<WaterBillPage> createState() => _WaterBillPageState();
}

class _WaterBillPageState extends State<WaterBillPage> {
  final _thisBill = TextEditingController();
  final _usualBill = TextEditingController();
  bool _metered = true;

  @override
  void dispose() {
    _thisBill.dispose();
    _usualBill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final now = double.tryParse(_thisBill.text.trim());
    final usual = double.tryParse(_usualBill.text.trim());
    final times = (now != null && usual != null && usual > 0)
        ? now / usual
        : null;

    return ToolScaffold(
      goal: 6,
      title: hi ? 'पानी का बिल ज़्यादा लग रहा है' : 'The water bill looks too high',
      children: [
        ToolNote(hi
            ? 'पानी का बिल अचानक बढ़ने की वजहें गिनी-चुनी हैं, और उनमें से आधी आपके '
                'अपने घर में होती हैं। पहले वही देखें — उसमें पैसा भी बचता है और शिकायत '
                'भी मज़बूत होती है।'
            : 'A water bill jumps for a short list of reasons, and half of '
                'them are inside your own house. Check those first - it saves '
                'money, and it makes the complaint stronger if the cause is '
                'not yours.'),
        SwitchListTile(
          value: _metered,
          contentPadding: EdgeInsets.zero,
          title: Text(hi ? 'मीटर लगा हुआ है' : 'There is a meter'),
          subtitle: Text(
            hi
                ? 'बिना मीटर के बिल तय दर पर आता है'
                : 'Without a meter the bill is a flat rate',
            style: const TextStyle(fontSize: 12),
          ),
          onChanged: (v) => setState(() => _metered = v),
        ),
        ToolQuestion(hi ? 'बिल की तुलना' : 'Compare the bills'),
        ToolNumber(
          controller: _thisBill,
          label: hi ? 'इस बार का बिल (₹)' : 'This bill (₹)',
          decimal: true,
          maxDigits: 7,
          icon: Icons.receipt_long_outlined,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolNumber(
          controller: _usualBill,
          label: hi ? 'आमतौर पर कितना आता है (₹)' : 'What it usually is (₹)',
          decimal: true,
          maxDigits: 7,
          icon: Icons.history,
          onChanged: (_) => setState(() {}),
        ),
        if (times != null) ...[
          ToolAnswer(
            headline: times >= 2
                ? (hi
                    ? 'आम बिल से ${times.toStringAsFixed(1)} गुना'
                    : '${times.toStringAsFixed(1)} times the usual bill')
                : (hi ? 'थोड़ा ही ज़्यादा है' : 'Only a little higher'),
            detail: times >= 2
                ? (hi
                    ? 'इतना अंतर अपने आप नहीं आता। आमतौर पर इनमें से कुछ होता है: कहीं '
                        'रिसाव, मीटर की ग़लत रीडिंग, अनुमान पर बना बिल (रीडिंग लेने कोई '
                        'आया ही नहीं), पिछली बकाया रक़म इसी बिल में जोड़ दी गई, या दर '
                        'बदल गई। नीचे की सूची से एक-एक करके मिलाएँ।'
                    : 'A jump like that does not happen on its own. It is '
                        'usually one of: a leak somewhere, a misread meter, an '
                        'estimated bill because nobody came to read it, '
                        'arrears added into this bill, or a changed tariff. '
                        'Work down the list below.')
                : (hi
                    ? 'गर्मी के महीनों में खपत बढ़ती है, और दर में हर साल थोड़ा बदलाव '
                        'होता है। फिर भी बिल पर रीडिंग और दर एक बार मिला लें।'
                    : 'Use rises in the hot months, and tariffs change a '
                        'little each year. Still worth checking the reading '
                        'and the rate on the bill once.'),
            tone: times >= 2 ? ToolTone.warn : ToolTone.plain,
            icon: Icons.trending_up,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'एक-एक करके देखें' : 'Check these one by one',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const ToolChecklist(
            storageKey: 'water_bill_v1',
            items: [
              CheckItem('leak', 'Close every tap, then watch the meter. If '
                  'it still moves, there is a leak',
                  'सारे नल बंद करके मीटर देखें। फिर भी घूमे तो कहीं रिसाव है',
                  noteEn: 'An underground leak between the meter and the '
                      'house is the commonest cause of a bill that doubled '
                      'with no change in use.',
                  noteHi: 'मीटर और घर के बीच ज़मीन के नीचे का रिसाव ही वह सबसे आम '
                      'वजह है जिससे बिना कुछ बदले बिल दोगुना हो जाता है।'),
              CheckItem('reading', 'Compare the reading on the bill with the '
                  'number on the meter right now',
                  'बिल पर लिखी रीडिंग और अभी मीटर पर दिख रहे नंबर को मिलाएँ'),
              CheckItem('estimate', 'Check whether the bill says estimated or '
                  'average - that means nobody read it',
                  'देखें कि बिल पर "अनुमानित" या "औसत" तो नहीं लिखा — इसका मतलब '
                      'रीडिंग ली ही नहीं गई'),
              CheckItem('arrears', 'Check whether old arrears have been '
                  'added into this month', 'देखें कि पुरानी बकाया रक़म तो नहीं जुड़ी'),
              CheckItem('tariff', 'Check the rate per unit against last '
                  'time\'s bill', 'प्रति यूनिट दर पिछले बिल से मिलाएँ'),
              CheckItem('category', 'Check the category - domestic, not '
                  'commercial', 'श्रेणी देखें — घरेलू है या व्यावसायिक लिख दिया गया'),
            ],
          ),
          if (_metered)
            ToolAnswer(
              headline: hi ? 'मीटर जाँच कराई जा सकती है' : 'The meter can be tested',
              detail: hi
                  ? 'अगर लगे कि मीटर तेज़ चल रहा है तो लिखित अर्ज़ी देकर मीटर की जाँच '
                      'कराई जा सकती है। शुल्क लगता है, लेकिन मीटर ख़राब निकला तो आमतौर '
                      'पर शुल्क वापस होता है और बिल भी सुधारा जाता है। शर्तें राज्य के '
                      'जल बोर्ड की होती हैं — अर्ज़ी देते समय पूछ लें।'
                  : 'If the meter seems to run fast, a written application '
                      'gets it tested. There is a fee, but if the meter is '
                      'found faulty the fee is usually refunded and the bill '
                      'corrected. The terms are the state water board\'s - '
                      'ask when you apply.',
              tone: ToolTone.plain,
              icon: Icons.speed_outlined,
            )
          else
            ToolNote(hi
                ? 'बिना मीटर के बिल तय दर पर बनता है, इसलिए खपत से उसका कोई संबंध '
                    'नहीं होता। ऐसे में बढ़ा हुआ बिल आमतौर पर दर बदलने या श्रेणी ग़लत '
                    'दर्ज होने से होता है। मीटर लगवाने से अक्सर बिल घटता है, अगर घर में '
                    'खपत कम है।'
                : 'Without a meter the bill is a flat rate, so it has nothing '
                    'to do with how much you use. A higher bill then usually '
                    'means a changed tariff or a wrongly recorded category. '
                    'Getting a meter often lowers the bill, if the household '
                    'uses little.'),
          ToolNote(hi
              ? 'शिकायत बिल पर छपे ग्राहक सेवा नंबर या जल बोर्ड के कार्यालय में दें, '
                  'लिखित में, बिल की नक़ल के साथ। जब तक विवाद चल रहा है, बिना विवाद '
                  'वाली रक़म जमा करते रहें — इससे कनेक्शन कटने का ख़तरा नहीं रहता।'
              : 'Complain at the customer service number printed on the bill '
                  'or at the water board office, in writing, with a copy of '
                  'the bill. While the dispute runs, keep paying the '
                  'undisputed part - that keeps the connection from being '
                  'cut.'),
        ],
      ],
    );
  }
}

// --- Tanker -----------------------------------------------------------

class TankerPage extends StatelessWidget {
  const TankerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 6,
      title: hi ? 'टैंकर या वैकल्पिक आपूर्ति' : 'A tanker or alternative supply',
      children: [
        ToolNote(hi
            ? 'जब गाँव या मोहल्ले का स्रोत सूख जाए, ख़राब हो जाए, या पानी पीने लायक़ '
                'न रहे, तो वैकल्पिक आपूर्ति की ज़िम्मेदारी ग्राम पंचायत, नगर निकाय और '
                'ज़िला प्रशासन की होती है। टैंकर मेहरबानी नहीं है — सूखे या जल संकट की '
                'स्थिति में यह प्रशासन का काम है, और इसके लिए अलग से बजट रखा जाता है।'
            : 'When a village or neighbourhood\'s source dries up, fails, or '
                'its water becomes unfit, arranging an alternative is the '
                'gram panchayat\'s, the local body\'s and the district '
                'administration\'s responsibility. A tanker is not a favour - '
                'in a drought or a water emergency it is their job, and there '
                'is a separate budget for it.'),
        const SizedBox(height: 10),
        Text(hi ? 'कब माँगा जा सकता है' : 'When you can ask for one',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'गाँव या मोहल्ले का मुख्य स्रोत सूख गया हो',
                  'जाँच में पानी पीने लायक़ न निकला हो — आर्सेनिक, फ़्लोराइड, खारापन, '
                      'या जीवाणु',
                  'बाढ़ या किसी हादसे से स्रोत गंदा हो गया हो',
                  'मरम्मत में कई दिन लगने वाले हों',
                  'ज़िला सूखाग्रस्त घोषित हो',
                ]
              : const [
                  'The main source for the village or locality has dried up',
                  'Testing has shown the water unfit - arsenic, fluoride, '
                      'salinity, or bacteria',
                  'A flood or an accident has contaminated the source',
                  'A repair is going to take several days',
                  'The district has been declared drought-affected',
                ],
        ),
        const SizedBox(height: 14),
        Text(hi ? 'कैसे माँगें' : 'How to ask',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'ग्राम पंचायत या नगर निकाय में लिखित अर्ज़ी दें। अकेले के बजाय '
                      'मोहल्ले के कई लोगों के हस्ताक्षर से दें — यह सबसे ज़्यादा फ़र्क़ '
                      'डालने वाली एक बात है।',
                  'अर्ज़ी में लिखें: कितने घर, कितने लोग, स्रोत कब से बंद है, अभी पानी '
                      'कहाँ से ला रहे हैं और कितनी दूर से।',
                  'ब्लॉक विकास अधिकारी (BDO) और जल विभाग के अभियंता को नक़ल भेजें।',
                  'ज़िला आपदा प्रबंधन प्राधिकरण या ज़िलाधिकारी कार्यालय — सूखे और जल '
                      'संकट की स्थिति में टैंकर का आदेश यहीं से होता है।',
                  'राज्य की जल जीवन मिशन हेल्पलाइन या ज़िला जनसुनवाई में दर्ज कराएँ, '
                      'और पावती संख्या रखें।',
                ]
              : const [
                  'Give a written application to the gram panchayat or local '
                      'body. Make it a joint one with several neighbours\' '
                      'signatures rather than going alone - this is the single '
                      'thing that makes the most difference.',
                  'Say in it: how many households, how many people, since '
                      'when the source has been out, where you are fetching '
                      'water from now and how far that is.',
                  'Copy it to the Block Development Officer and the water '
                      'department engineer.',
                  'The district disaster management authority or the district '
                      'officer - in a drought or water emergency the tanker '
                      'order comes from there.',
                  'Register it on the state Jal Jeevan Mission helpline or at '
                      'the district public hearing, and keep the '
                      'acknowledgement number.',
                ],
        ),
        ToolDonts(
          heading: hi ? 'टैंकर का पानी आने पर' : 'When the tanker water arrives',
          items: hi
              ? const [
                  'टैंकर का पानी अपने आप सुरक्षित नहीं होता — टैंकर कब साफ़ हुआ था, यह '
                      'किसी को पता नहीं होता। पीने से पहले उबालें या क्लोरीन डालें।',
                  'भरने के बर्तन ढके और साफ़ हों; पहले से रखा बासी पानी उसी में न '
                      'मिलाएँ',
                  'बाल्टी में हाथ डालकर पानी न निकालें',
                  'टैंकर से पानी बेचा जा रहा हो तो यह शिकायत का विषय है — सरकारी '
                      'टैंकर का पानी मुफ़्त है',
                ]
              : const [
                  'Tanker water is not automatically safe - nobody knows when '
                      'the tanker was last cleaned. Boil or chlorinate it '
                      'before drinking.',
                  'Fill into clean covered vessels; do not top up stale water '
                      'already standing in them',
                  'Do not dip a hand into the bucket to draw water',
                  'If anyone is selling the tanker water, that is itself a '
                      'complaint - water from a government tanker is free',
                ],
        ),
        const SourceNote(text: 'Jal Jeevan Mission', url: _jjmUrl),
      ],
    );
  }
}
