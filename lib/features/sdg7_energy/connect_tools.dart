import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Getting connected, outages, and sizing an inverter.
///
/// The first two screens lean on a thing almost nobody in a village knows
/// exists: every state electricity regulator publishes Standards of
/// Performance - binding time limits for a new connection, a fault repair,
/// a meter replacement - and in most states a failure to meet them carries
/// compensation. The limits differ by state, so these screens name the
/// document rather than inventing a number, and tell the reader the words
/// to use.

const _ercUrl = 'https://forumofregulators.gov.in/';
const _nationalPortal = 'https://powermin.gov.in/';

enum ConnectionStage { notApplied, appliedWaiting, quotedNotDone, refused }

class NewConnectionPage extends StatefulWidget {
  const NewConnectionPage({super.key});

  @override
  State<NewConnectionPage> createState() => _NewConnectionPageState();
}

class _NewConnectionPageState extends State<NewConnectionPage> {
  ConnectionStage? _stage;
  final _days = TextEditingController();

  @override
  void dispose() {
    _days.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final days = int.tryParse(_days.text.trim());

    Widget pick(ConnectionStage s, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _stage == s,
          onTap: () => setState(() => _stage = s),
        );

    return ToolScaffold(
      goal: 7,
      title: hi ? 'नया कनेक्शन नहीं मिल रहा' : 'The new connection is delayed',
      children: [
        ToolNote(hi
            ? 'हर राज्य के विद्युत नियामक आयोग ने "स्टैंडर्ड्स ऑफ़ परफ़ॉर्मेंस" '
                'नाम से समय-सीमाएँ तय कर रखी हैं — नया कनेक्शन कितने दिन में देना है, '
                'ख़राबी कितने घंटे में ठीक करनी है, मीटर कितने दिन में बदलना है। और '
                'ज़्यादातर राज्यों में समय-सीमा टूटने पर मुआवज़ा भी बनता है। यह काग़ज़ '
                'सार्वजनिक है और बिजली कंपनी के दफ़्तर में माँगा जा सकता है।'
            : 'Every state electricity regulator has fixed time limits in a '
                'document called the Standards of Performance - how many days '
                'for a new connection, how many hours to fix a fault, how '
                'many days to replace a meter. In most states breaching them '
                'carries compensation. The document is public and can be '
                'asked for at the electricity office.'),
        ToolQuestion(hi ? 'कहाँ तक पहुँचे हैं' : 'How far have you got'),
        pick(ConnectionStage.notApplied, 'We have not applied yet',
            'अभी अर्ज़ी दी ही नहीं'),
        pick(ConnectionStage.appliedWaiting, 'Applied, still waiting',
            'अर्ज़ी दी है, इंतज़ार कर रहे हैं'),
        pick(ConnectionStage.quotedNotDone,
            'They gave an estimate, we paid, nothing happened',
            'ख़र्च बताया, पैसा जमा किया, फिर कुछ नहीं हुआ'),
        pick(ConnectionStage.refused, 'They refused',
            'मना कर दिया'),
        if (_stage != null) ...[
          if (_stage == ConnectionStage.notApplied)
            ToolAnswer(
              headline: hi ? 'अर्ज़ी के साथ क्या लगेगा' : 'What the application needs',
              detail: hi
                  ? 'पहचान पत्र, पते का सबूत, और घर के मालिकाना या क़ब्ज़े का कोई '
                      'काग़ज़। किरायेदार हैं तो मकान मालिक की सहमति या किरायानामा। कई '
                      'राज्यों में यह ऑनलाइन होता है और आवेदन संख्या मिल जाती है — '
                      'उसी से स्थिति देखी जा सकती है। अर्ज़ी देते ही पावती लें और '
                      'पूछें कि इस श्रेणी के कनेक्शन की समय-सीमा कितने दिन की है।'
                  : 'Identity proof, proof of address, and some paper showing '
                      'ownership or possession of the house. For a tenant, '
                      'the owner\'s consent or the rent agreement. In many '
                      'states this is online and gives you an application '
                      'number to track. Take the acknowledgement when you '
                      'apply, and ask what the time limit is for this '
                      'category of connection.',
              tone: ToolTone.plain,
              icon: Icons.assignment_outlined,
            )
          else ...[
            ToolQuestion(hi ? 'कितने दिन हो गए' : 'How many days has it been'),
            ToolNumber(
              controller: _days,
              label: hi ? 'दिन' : 'Days',
              maxDigits: 4,
              icon: Icons.calendar_today_outlined,
              onChanged: (_) => setState(() {}),
            ),
            if (days != null && days > 0)
              ToolAnswer(
                headline: days > 30
                    ? (hi
                        ? '$days दिन — यह लगभग हर राज्य की सीमा से ऊपर है'
                        : '$days days - that is past almost every state\'s limit')
                    : (hi
                        ? '$days दिन'
                        : '$days days'),
                detail: days > 30
                    ? (hi
                        ? 'ज़्यादातर राज्यों में बिना नई लाइन खींचे दिए जाने वाले '
                            'कनेक्शन की सीमा एक महीने से काफ़ी कम होती है। उपखंड '
                            'कार्यालय में लिखित शिकायत दें और उसमें "स्टैंडर्ड्स ऑफ़ '
                            'परफ़ॉर्मेंस" का नाम लेकर पूछें कि निर्धारित समय-सीमा क्या '
                            'थी और मुआवज़ा बनता है या नहीं। यह वाक्य ही शिकायत को '
                            'अलग तरह से पढ़वाता है।'
                        : 'In most states the limit for a connection that '
                            'needs no new line is well under a month. Give a '
                            'written complaint at the sub-division office and '
                            'in it name the Standards of Performance, asking '
                            'what the prescribed limit was and whether '
                            'compensation applies. That one sentence gets a '
                            'complaint read differently.')
                    : (hi
                        ? 'अभी सीमा के भीतर हो सकता है। आवेदन संख्या से स्थिति देखें '
                            'और उपखंड कार्यालय से पूछ लें कि इस श्रेणी में कितने दिन '
                            'तय हैं — और वह तारीख़ लिख लें।'
                        : 'This may still be within the limit. Track it on '
                            'the application number and ask the sub-division '
                            'office how many days are prescribed for this '
                            'category - then write that date down.'),
                tone: days > 30 ? ToolTone.warn : ToolTone.plain,
                icon: Icons.schedule,
              ),
            if (_stage == ConnectionStage.quotedNotDone)
              ToolNote(hi
                  ? 'पैसा जमा हो चुका है तो आपके पास सबसे मज़बूत काग़ज़ पहले से है: '
                      'रसीद। शिकायत में रसीद संख्या और जमा करने की तारीख़ ज़रूर लिखें। '
                      'जमा के बाद का काम कंपनी का है और इसकी अलग समय-सीमा होती है।'
                  : 'If the money is paid you already hold the strongest '
                      'paper there is: the receipt. Put its number and the '
                      'date of payment in the complaint. After payment the '
                      'work is the company\'s, and that has a time limit of '
                      'its own.'),
            if (_stage == ConnectionStage.refused)
              ToolAnswer(
                headline: hi
                    ? 'मना करने का कारण लिखित में माँगें'
                    : 'Ask for the refusal in writing',
                detail: hi
                    ? 'कनेक्शन मना करने के कारण गिने-चुने हैं — बक़ाया बिल उसी परिसर '
                        'पर, काग़ज़ों की कमी, या तकनीकी वजह जैसे खंभा दूर होना। कारण '
                        'लिखित में मिल जाए तो आगे का रास्ता साफ़ हो जाता है। ख़ास बात: '
                        'किसी और व्यक्ति का पुराना बक़ाया आपके नए कनेक्शन के रास्ते में '
                        'नहीं आना चाहिए, और इस पर अदालतों की राय साफ़ रही है — यह बात '
                        'लिखित में उठाएँ।'
                    : 'The reasons a connection can be refused are few - '
                        'arrears on the same premises, missing papers, or a '
                        'technical reason such as distance from the pole. '
                        'With the reason in writing, the next step becomes '
                        'clear. One point in particular: somebody else\'s old '
                        'arrears should not block your new connection, and '
                        'the courts have been clear about that - raise it in '
                        'writing.',
                tone: ToolTone.warn,
                icon: Icons.block_outlined,
              ),
          ],
          const SizedBox(height: 14),
          Text(hi ? 'शिकायत इस क्रम में' : 'Escalate in this order',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'उपखंड अधिकारी (SDO) को लिखित शिकायत, पावती के साथ।',
                    'अधीक्षण अभियंता या मंडल कार्यालय।',
                    'उपभोक्ता शिकायत निवारण फ़ोरम (CGRF) — हर बिजली कंपनी में यह '
                        'होता है, इसमें शिकायत करना मुफ़्त है, और यह अदालत की तरह सुनवाई '
                        'करके आदेश देता है। यही वह जगह है जिसके बारे में सबसे कम लोगों '
                        'को पता होता है।',
                    'विद्युत लोकपाल (Electricity Ombudsman) — CGRF के फ़ैसले से '
                        'संतुष्ट न हों तो।',
                  ]
                : const [
                    'A written complaint to the sub-divisional officer, with '
                        'an acknowledgement.',
                    'The superintending engineer or the circle office.',
                    'The Consumer Grievance Redressal Forum - every '
                        'electricity company has one, complaining to it is '
                        'free, and it hears the matter like a court and '
                        'passes an order. It is the step fewest people know '
                        'about.',
                    'The Electricity Ombudsman, if the Forum\'s decision does '
                        'not satisfy you.',
                  ],
          ),
          const SourceNote(
              text: 'Forum of Regulators - state regulatory commissions',
              url: _ercUrl),
        ],
      ],
    );
  }
}

// --- Power cut --------------------------------------------------------

class PowerCutPage extends StatefulWidget {
  const PowerCutPage({super.key});

  @override
  State<PowerCutPage> createState() => _PowerCutPageState();
}

class _PowerCutPageState extends State<PowerCutPage> {
  final _hours = TextEditingController();
  bool _wholeArea = true;
  bool _informed = false;

  @override
  void dispose() {
    _hours.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final hours = double.tryParse(_hours.text.trim());

    return ToolScaffold(
      goal: 7,
      title: hi ? 'घंटों बिजली नहीं आ रही' : 'The power has been out for hours',
      children: [
        ToolNote(hi
            ? 'बिजली जाने की दो तरह की बातें हैं, और उनका रास्ता अलग है। एक है '
                'ख़राबी — तार टूटा, ट्रांसफ़ॉर्मर जला, फ़्यूज़ उड़ा। इसे तय समय में ठीक '
                'करना कंपनी की ज़िम्मेदारी है। दूसरी है कटौती — बिजली कम होने पर '
                'पहले से तय समय पर काटी जाती है। पहली पर शिकायत बनती है, दूसरी पर '
                'आमतौर पर नहीं।'
            : 'There are two different things, and they have different '
                'routes. One is a fault - a broken wire, a burnt transformer, '
                'a blown fuse. Fixing that within a set time is the '
                'company\'s duty. The other is load shedding - a planned cut '
                'when supply is short. The first is a complaint; the second '
                'usually is not.'),
        SwitchListTile(
          value: _wholeArea,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'पूरे मोहल्ले की बिजली गई है'
              : 'The whole neighbourhood is out'),
          subtitle: Text(
            hi
                ? 'बंद करें तो सिर्फ़ हमारे घर की'
                : 'Off means only our house',
            style: const TextStyle(fontSize: 12),
          ),
          onChanged: (v) => setState(() => _wholeArea = v),
        ),
        SwitchListTile(
          value: _informed,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'पहले से बताया गया था कि बिजली जाएगी'
              : 'It was announced in advance'),
          onChanged: (v) => setState(() => _informed = v),
        ),
        ToolQuestion(hi ? 'कितने घंटे हो गए' : 'How many hours so far'),
        ToolNumber(
          controller: _hours,
          label: hi ? 'घंटे' : 'Hours',
          decimal: true,
          maxDigits: 4,
          icon: Icons.schedule,
          onChanged: (_) => setState(() {}),
        ),
        if (hours != null && hours > 0) ...[
          ToolAnswer(
            headline: _informed
                ? (hi ? 'यह पहले से तय कटौती है' : 'This is a planned cut')
                : (_wholeArea
                    ? (hi ? 'यह ख़राबी है — शिकायत दर्ज कराएँ' : 'This is a fault - log it')
                    : (hi
                        ? 'सिर्फ़ आपके घर की — पहले अपना मीटर देखें'
                        : 'Only your house - check your own meter first')),
            detail: _informed
                ? (hi
                    ? 'पहले से बताई गई कटौती पर आमतौर पर मुआवज़ा नहीं बनता। लेकिन '
                        'अगर बताए गए समय से बहुत ज़्यादा देर हो गई है, या रोज़ ऐसा हो '
                        'रहा है, तो यह अलग बात है और इसकी शिकायत बनती है।'
                    : 'A cut announced in advance does not usually attract '
                        'compensation. But if it is running far past the '
                        'announced time, or happening every day, that is a '
                        'different matter and it is worth complaining about.')
                : (_wholeArea
                    ? (hi
                        ? 'ख़राबी ठीक करने की समय-सीमा आपके राज्य के विद्युत नियामक '
                            'आयोग ने तय कर रखी है — शहरी और ग्रामीण इलाक़ों के लिए '
                            'अलग-अलग, और ट्रांसफ़ॉर्मर जैसे बड़े काम के लिए अलग। कई '
                            'राज्यों में सीमा टूटने पर मुआवज़ा मिलता है, लेकिन लगभग '
                            'हमेशा तभी जब शिकायत दर्ज हुई हो। इसलिए पहला काम शिकायत '
                            'संख्या लेना है।'
                        : 'The time limit for fixing a fault is set by your '
                            'state regulator - different for urban and rural '
                            'areas, and different again for bigger work like '
                            'a transformer. Many states pay compensation when '
                            'the limit is breached, but almost always only '
                            'where a complaint was logged. So the first thing '
                            'to do is get a complaint number.')
                    : (hi
                        ? 'सिर्फ़ आपके घर की बिजली गई है तो अक्सर वजह आपके अपने '
                            'कनेक्शन में होती है: मेन फ़्यूज़ उड़ना, MCB गिरना, या मीटर '
                            'तक आने वाला तार ढीला होना। मेन स्विच और MCB देख लें। '
                            'फिर भी न आए तो शिकायत दर्ज कराएँ।'
                        : 'When only your house is out the cause is often in '
                            'your own connection: a blown main fuse, a '
                            'tripped MCB, or a loose wire up to the meter. '
                            'Check the main switch and the MCB. If it is '
                            'still out, log a complaint.')),
            tone: _informed ? ToolTone.plain : ToolTone.warn,
            icon: Icons.power_off_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'शिकायत दर्ज कराते समय' : 'When you log the complaint',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const ToolChecklist(
            storageKey: 'power_cut_v1',
            introEn: 'Logging it on the phone is enough - but the number is '
                'the thing.',
            introHi: 'फ़ोन पर दर्ज कराना काफ़ी है — लेकिन असल चीज़ शिकायत संख्या है।',
            items: [
              CheckItem('number', 'Get the complaint or docket number, and '
                  'write it down with the time',
                  'शिकायत या डॉकेट संख्या लें, और समय के साथ लिख लें',
                  noteEn: 'Without it there is no record that the outage was '
                      'reported, and compensation almost always turns on '
                      'that.',
                  noteHi: 'इसके बिना यह रिकॉर्ड ही नहीं रहता कि बिजली जाने की सूचना '
                      'दी गई थी, और मुआवज़ा लगभग हमेशा इसी पर टिकता है।'),
              CheckItem('consumer', 'Give the consumer number from your bill',
                  'बिल पर लिखा उपभोक्ता नंबर बताएँ'),
              CheckItem('when', 'Say exactly when the supply went',
                  'बिजली ठीक कब गई, यह बताएँ'),
              CheckItem('what', 'Say what you can see - a broken wire, a '
                  'burnt transformer, sparking',
                  'जो दिख रहा है वह बताएँ — टूटा तार, जला ट्रांसफ़ॉर्मर, चिंगारी'),
              CheckItem('repeat', 'If it is a daily problem, keep a sheet of '
                  'dates and hours', 'रोज़ की दिक़्क़त हो तो तारीख़ और घंटों की पर्ची रखें',
                  noteEn: 'A month of logged outages is what gets a '
                      'transformer replaced. One phone call does not.',
                  noteHi: 'महीने भर का दर्ज रिकॉर्ड ही ट्रांसफ़ॉर्मर बदलवाता है। एक '
                      'फ़ोन कॉल नहीं।'),
            ],
          ),
          ToolDonts(
            heading: hi ? 'बिजली न आने पर' : 'While the power is out',
            items: hi
                ? const [
                    'टूटे या लटके तार के पास न जाएँ, और उसे किसी चीज़ से हटाने की '
                        'कोशिश बिल्कुल न करें — इसी लक्ष्य में "बिजली का झटका या गिरा '
                        'तार" देखें',
                    'ट्रांसफ़ॉर्मर या खंभे पर ख़ुद चढ़कर कुछ ठीक करने की कोशिश न करें',
                    'लाइन पर काम चल रहा हो तो यह मानकर न चलें कि बिजली नहीं आएगी — '
                        'वह कभी भी आ सकती है',
                    'मोमबत्ती जलाकर सोने न जाएँ; उससे होने वाली आग बिजली जाने से '
                        'ज़्यादा नुक़सान करती है',
                  ]
                : const [
                    'Stay away from a broken or hanging wire, and never try '
                        'to move it with anything - see "Electric shock or a '
                        'fallen wire" in this goal',
                    'Do not climb a pole or a transformer to fix something '
                        'yourself',
                    'If work is going on, never assume the supply will stay '
                        'off - it can come back at any moment',
                    'Do not go to sleep with a candle burning; the fires do '
                        'more harm than the outage',
                  ],
          ),
          const SourceNote(
              text: 'Forum of Regulators', url: _ercUrl),
          const SourceNote(text: 'Ministry of Power', url: _nationalPortal),
        ],
      ],
    );
  }
}

// --- Inverter sizing --------------------------------------------------

class InverterPage extends StatefulWidget {
  const InverterPage({super.key});

  @override
  State<InverterPage> createState() => _InverterPageState();
}

class _InverterPageState extends State<InverterPage> {
  final _fans = TextEditingController(text: '2');
  final _lights = TextEditingController(text: '4');
  final _tv = TextEditingController(text: '0');
  final _backupHours = TextEditingController(text: '4');

  @override
  void dispose() {
    for (final c in [_fans, _lights, _tv, _backupHours]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final fans = int.tryParse(_fans.text.trim()) ?? 0;
    final lights = int.tryParse(_lights.text.trim()) ?? 0;
    final tv = int.tryParse(_tv.text.trim()) ?? 0;
    final hours = double.tryParse(_backupHours.text.trim()) ?? 0;

    final watts = fans * 70 + lights * 9 + tv * 100;
    // Inverters are sold in VA; a power factor of 0.8 is the usual one.
    final va = watts / 0.8;
    // Battery: watt-hours needed, over 12 V, with ~80% usable efficiency.
    final ah = (watts * hours) / (12 * 0.8);

    return ToolScaffold(
      goal: 7,
      title: hi ? 'इन्वर्टर और बैटरी कितनी बड़ी' : 'What size inverter and battery',
      children: [
        ToolNote(hi
            ? 'इन्वर्टर ख़रीदते समय दुकानदार आमतौर पर ज़रूरत से बड़ा बेच देता है। दो '
                'अलग बातें हैं: इन्वर्टर का आकार तय करता है कि एक साथ कितना चल सकता '
                'है, और बैटरी तय करती है कि कितनी देर। दोनों का हिसाब अलग लगता है।'
            : 'A shopkeeper usually sells a bigger inverter than you need. '
                'Two separate things decide it: the inverter\'s size sets how '
                'much can run at once, and the battery sets for how long. '
                'They are worked out separately.'),
        ToolQuestion(hi ? 'बिजली जाने पर क्या चलाना है' : 'What should run during an outage'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _fans,
                label: hi ? 'पंखे' : 'Fans',
                maxDigits: 2,
                icon: Icons.air,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _lights,
                label: hi ? 'एलईडी बत्ती' : 'LED lights',
                maxDigits: 2,
                icon: Icons.lightbulb_outline,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _tv,
                label: hi ? 'टीवी' : 'TV',
                maxDigits: 2,
                icon: Icons.tv_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _backupHours,
                label: hi ? 'कितने घंटे' : 'Hours of backup',
                decimal: true,
                maxDigits: 4,
                icon: Icons.schedule,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        if (watts > 0 && hours > 0) ...[
          ToolAnswer(
            headline: hi
                ? 'लगभग ${va.round()} VA का इन्वर्टर'
                : 'An inverter of about ${va.round()} VA',
            detail: hi
                ? 'आपका कुल भार $watts वाट है। दुकान में इन्वर्टर VA में बिकते हैं, '
                    'और अगली बड़ी नाप लेना ठीक रहता है — जैसे ${_round(va)} VA। इससे '
                    'बहुत बड़ा लेने का कोई फ़ायदा नहीं, बस दाम और बिजली की खपत बढ़ती '
                    'है।'
                : 'Your total load is $watts watts. Inverters are sold in VA, '
                    'and the next size up is the right one - around '
                    '${_round(va)} VA. Going far above that gains nothing; it '
                    'only costs more and wastes more.',
            tone: ToolTone.plain,
            icon: Icons.electrical_services_outlined,
          ),
          ToolAnswer(
            headline: hi
                ? 'लगभग ${ah.round()} Ah की बैटरी'
                : 'A battery of about ${ah.round()} Ah',
            detail: hi
                ? '$hours घंटे चलाने के लिए। बाज़ार में 100, 150, 180 और 200 Ah आम '
                    'हैं — अगली बड़ी नाप लीजिए। बैटरी जितनी बड़ी, उतनी देर चलेगी और '
                    'उतनी ही महँगी होगी; इन्वर्टर का आकार इससे नहीं बदलता।'
                : 'to run for $hours hours. The common sizes are 100, 150, '
                    '180 and 200 Ah - take the next size up. A bigger battery '
                    'means longer backup and more money; it does not change '
                    'the inverter size.',
            tone: ToolTone.good,
            icon: Icons.battery_charging_full_outlined,
          ),
          const SizedBox(height: 10),
          ToolLine(hi ? 'कुल भार' : 'Total load',
              hi ? '$watts वाट' : '$watts watts', strong: true),
          ToolLine(hi ? 'इन्वर्टर' : 'Inverter', '${_round(va)} VA'),
          ToolLine(hi ? 'बैटरी' : 'Battery', '${_round(ah)} Ah'),
          const SizedBox(height: 14),
          ToolDonts(
            heading: hi ? 'ख़रीदते और लगाते समय' : 'Buying and installing',
            items: hi
                ? const [
                    'मोटर, गीज़र, इस्तरी, एसी और फ़्रिज आम घरेलू इन्वर्टर पर न चलाएँ — '
                        'ये बहुत ज़्यादा खींचते हैं और बैटरी मिनटों में ख़त्म कर देते '
                        'हैं',
                    'बैटरी बंद कमरे में न रखें। सामान्य (लेड एसिड) बैटरी से गैस निकलती '
                        'है — हवादार जगह चाहिए',
                    'बैटरी के पास आग, बीड़ी या चिंगारी नहीं',
                    'पानी वाली बैटरी में डिस्टिल्ड पानी ही डालें, नल का नहीं',
                    'इन्वर्टर की अर्थिंग ज़रूर कराएँ, और तार पतला न लगवाएँ',
                  ]
                : const [
                    'Do not run a motor, geyser, iron, air conditioner or '
                        'fridge off an ordinary household inverter - they '
                        'draw far too much and empty the battery in minutes',
                    'Do not keep the battery in a closed room. An ordinary '
                        'lead-acid battery gives off gas and needs '
                        'ventilation',
                    'No flame, bidi or spark near the battery',
                    'Top up a wet battery with distilled water only, never '
                        'tap water',
                    'Have the inverter earthed, and do not let thin wire be '
                        'used',
                  ],
          ),
          ToolNote(hi
              ? 'जहाँ बिजली रोज़ और लंबे समय के लिए जाती है, वहाँ सौर पैनल जोड़ना '
                  'अक्सर सस्ता पड़ता है — बैटरी दिन में भर जाती है और बिजली के बिल में '
                  'भी बचत होती है। इसी लक्ष्य में "छत पर सौर ऊर्जा" देखें।'
              : 'Where the power goes every day and for long stretches, '
                  'adding a solar panel often works out cheaper - the battery '
                  'fills during the day and the bill drops too. See "Rooftop '
                  'solar" in this goal.'),
        ],
      ],
    );
  }

  /// The next common size up, so the answer is something a shop sells.
  int _round(double v) {
    for (final size in const [100, 150, 180, 200, 250, 300, 400, 500, 600,
      750, 850, 1000, 1500, 2000, 2500, 3000]) {
      if (v <= size) return size;
    }
    return ((v / 500).ceil() * 500);
  }
}
