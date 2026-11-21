import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Three screens where the order of actions decides whether somebody
/// lives.
///
/// The gas-leak screen is the clearest case in the app of sequence
/// mattering more than information. Everybody knows not to light a match
/// in a gas leak. Far fewer know that switching a light off is the same
/// act - the spark is in the switch either way - and that reaching for
/// the switch is the reflex people have on walking into a dark room that
/// smells of gas.

const _pngrbUrl = 'https://www.pngrb.gov.in/';
const _ceaUrl = 'https://cea.nic.in/';

/// The emergency banner these three screens share.
class _Urgent extends StatelessWidget {
  final String text;
  final IconData icon;
  const _Urgent(this.text, {this.icon = Icons.emergency_outlined});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: scheme.error,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.onError, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 14.5,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: scheme.onError)),
          ),
        ],
      ),
    );
  }
}

// --- LPG leak ---------------------------------------------------------

class LpgLeakPage extends StatelessWidget {
  const LpgLeakPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 7,
      title: hi ? 'गैस लीक हो रही है' : 'A gas leak, right now',
      children: [
        _Urgent(
          hi
              ? 'कोई भी बिजली का स्विच न छुएँ — न जलाएँ, न बुझाएँ। बंद करने में भी '
                  'वैसी ही चिंगारी होती है जैसी जलाने में। एलपीजी आपात सेवा 1906।'
              : 'Do not touch any electrical switch - not on, not off. '
                  'Switching off makes the same spark as switching on. LPG '
                  'emergency 1906.',
          icon: Icons.local_fire_department_outlined,
        ),
        const SizedBox(height: 10),
        Text(hi ? 'इसी क्रम में' : 'In this order',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'चूल्हे के सब नॉब बंद करें, और सिलेंडर पर लगे रेगुलेटर का नॉब भी '
                      'बंद करें।',
                  'रेगुलेटर निकालकर सिलेंडर पर सुरक्षा टोपी (सेफ़्टी कैप) लगा दें। '
                      'यह काग़ज़ी काम नहीं है — टोपी ही गैस पूरी तरह रोकती है।',
                  'सारे दरवाज़े और खिड़कियाँ खोल दें। गैस हवा से भारी होती है इसलिए '
                      'नीचे फ़र्श पर बैठती है — ज़मीन के पास की हवा भी निकलने दें।',
                  'सिलेंडर उठाकर खुली जगह में ले जाएँ, अगर उसे छूना सुरक्षित लगे।',
                  'घर के सब लोगों को, ख़ासकर बच्चों और बुज़ुर्गों को बाहर निकालें।',
                  'बाहर आकर, घर से दूर जाकर 1906 पर या अपनी गैस एजेंसी को फ़ोन करें।',
                  'गैस की गंध ख़त्म होने तक घर में कोई न जाए।',
                ]
              : const [
                  'Turn off every knob on the stove, and the knob on the '
                      'regulator on the cylinder.',
                  'Take the regulator off and put the safety cap on the '
                      'cylinder. This is not a formality - the cap is what '
                      'actually stops the gas.',
                  'Open every door and window. LPG is heavier than air and '
                      'settles on the floor, so let the air near the ground '
                      'out as well.',
                  'Carry the cylinder out into the open, if it feels safe to '
                      'touch it.',
                  'Get everyone out, children and elderly people first.',
                  'Once outside and away from the house, call 1906 or your '
                      'gas agency.',
                  'Nobody goes back in until the smell has gone.',
                ],
        ),
        ToolDonts(
          heading: hi ? 'यह बिल्कुल न करें' : 'Absolutely not',
          items: hi
              ? const [
                  'कोई भी बिजली का स्विच न दबाएँ — बत्ती, पंखा, एक्ज़ॉस्ट, कुछ भी। '
                      'स्विच बंद करने में भी चिंगारी बनती है, और अंधेरे कमरे में सबसे '
                      'पहले हाथ स्विच पर ही जाता है। इसी एक आदत से सबसे ज़्यादा हादसे '
                      'होते हैं।',
                  'माचिस, लाइटर, दीया, अगरबत्ती, बीड़ी — कुछ नहीं',
                  'घर के अंदर मोबाइल पर फ़ोन न करें; बाहर जाकर करें',
                  'इन्वर्टर, जनरेटर या मोटर चालू-बंद न करें',
                  'दरवाज़े की घंटी न बजाएँ और किसी को बजाने न दें',
                  'लीक ढूँढ़ने के लिए माचिस या लौ का इस्तेमाल कभी न करें — साबुन का '
                      'पानी लगाइए, बुलबुले बनने से जगह पता चल जाती है',
                  'पाइप या रेगुलेटर ख़ुद ठीक करने की कोशिश न करें',
                ]
              : const [
                  'Do not touch any electrical switch - light, fan, exhaust, '
                      'anything. Switching off sparks just as switching on '
                      'does, and in a dark room the hand goes to the switch '
                      'first. That one habit causes more of these accidents '
                      'than anything else.',
                  'No match, lighter, lamp, incense or bidi',
                  'Do not make the call on a mobile inside the house; go '
                      'outside',
                  'Do not switch an inverter, generator or motor on or off',
                  'Do not ring the doorbell, and do not let anyone else ring '
                      'it',
                  'Never use a match or a flame to find a leak - put soapy '
                      'water on it and the bubbles show you where it is',
                  'Do not try to repair the pipe or regulator yourself',
                ],
        ),
        const SizedBox(height: 14),
        Text(hi ? 'लीक दोबारा न हो' : 'So it does not happen again',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const ToolChecklist(
          storageKey: 'lpg_safety_v1',
          items: [
            CheckItem('pipe', 'Change the hose on the date stamped on it - '
                'it has a life, usually a couple of years',
                'पाइप पर छपी तारीख़ पर उसे बदलवाएँ — उसकी एक उम्र होती है, आमतौर '
                    'पर दो साल'),
            CheckItem('isi', 'Use an ISI-marked hose and regulator only',
                'आईएसआई मार्क वाला पाइप और रेगुलेटर ही लें'),
            CheckItem('night', 'Turn the regulator knob off at night and '
                'whenever you go out',
                'रात को और बाहर जाते समय रेगुलेटर का नॉब बंद कर दें',
                noteEn: 'The habit that prevents most leaks, and it costs '
                    'nothing.',
                noteHi: 'सबसे ज़्यादा लीक इसी आदत से रुकते हैं, और इसमें कुछ नहीं '
                    'लगता।'),
            CheckItem('upright', 'Keep the cylinder upright, on the floor, '
                'never in a closed cupboard',
                'सिलेंडर सीधा खड़ा रखें, फ़र्श पर, बंद अलमारी में कभी नहीं'),
            CheckItem('above', 'Keep the stove above the cylinder, never '
                'below it', 'चूल्हा सिलेंडर से ऊपर रखें, नीचे कभी नहीं'),
            CheckItem('vent', 'Cook in a ventilated place - a window or a '
                'door that opens', 'हवादार जगह पर पकाएँ — खिड़की या खुलने वाला दरवाज़ा'),
            CheckItem('check', 'Ask the agency for the free safety '
                'inspection they are required to do',
                'एजेंसी से मुफ़्त सुरक्षा जाँच कराएँ, जो उन्हें करनी होती है'),
            CheckItem('insurance', 'Know that an LPG accident at a '
                'registered connection carries insurance cover - ask the '
                'agency, and never settle without asking',
                'पंजीकृत कनेक्शन पर गैस हादसे का बीमा होता है — एजेंसी से पूछें, '
                    'और बिना पूछे समझौता न करें'),
          ],
        ),
        ToolNote(hi
            ? 'सिलेंडर लेते समय तुलवाकर लें और डिलीवरी वाले से सामने जाँच कराएँ — यह '
                'आपका हक़ है। गंध आने पर एजेंसी को बुलाना मुफ़्त है।'
            : 'Have the cylinder weighed at delivery and checked in front of '
                'you - that is your right. Calling the agency out for a '
                'smell of gas is free.'),
        const SourceNote(
            text: 'Petroleum and Natural Gas Regulatory Board',
            url: _pngrbUrl),
      ],
    );
  }
}

// --- Electric shock or a fallen wire ----------------------------------

enum ShockCase { personTouching, personFree, fallenWire, waterAndWires }

class ElectricShockPage extends StatefulWidget {
  const ElectricShockPage({super.key});

  @override
  State<ElectricShockPage> createState() => _ElectricShockPageState();
}

class _ElectricShockPageState extends State<ElectricShockPage> {
  ShockCase? _case;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    Widget pick(ShockCase c, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _case == c,
          onTap: () => setState(() => _case = c),
        );

    return ToolScaffold(
      goal: 7,
      title: hi ? 'बिजली का झटका या गिरा तार' : 'Electric shock or a fallen wire',
      children: [
        _Urgent(
          hi
              ? 'जो व्यक्ति बिजली के संपर्क में है, उसे हाथ से न छुएँ। पहले बिजली '
                  'बंद करें। बचाने वाले इसी एक ग़लती से मरते हैं। एम्बुलेंस 108, '
                  'आपातकाल 112।'
              : 'Do not touch a person who is still in contact with the '
                  'current. Cut the power first. That one mistake is what '
                  'kills the rescuer. Ambulance 108, emergency 112.',
          icon: Icons.electric_bolt_outlined,
        ),
        ToolQuestion(hi ? 'हालत क्या है' : 'What is the situation'),
        pick(ShockCase.personTouching,
            'Someone is still in contact with the current',
            'कोई अभी भी बिजली के संपर्क में है'),
        pick(ShockCase.personFree,
            'The shock has happened, they are away from it now',
            'झटका लग चुका है, अब वे अलग हैं'),
        pick(ShockCase.fallenWire, 'A wire has fallen, nobody is touching it',
            'तार गिरा है, कोई छू नहीं रहा'),
        pick(ShockCase.waterAndWires,
            'Water and wires together - flooding, a wet wall',
            'पानी और तार एक साथ — भराव, गीली दीवार'),
        if (_case != null) ...[
          if (_case == ShockCase.personTouching) ...[
            ToolAnswer(
              headline: hi ? 'क्रम यही है' : 'This is the order',
              detail: hi
                  ? 'पहले बिजली बंद, फिर छूना। उलटा करने पर दो लोग घायल होते हैं।'
                  : 'Power off first, then touch. The other way round, two '
                      'people get hurt.',
              tone: ToolTone.bad,
              icon: Icons.priority_high,
            ),
            ToolSteps(
              steps: hi
                  ? const [
                      'मेन स्विच या MCB बंद करें। न पहुँच सके तो प्लग निकालें।',
                      'बिजली बंद न हो सके तो व्यक्ति को सूखी लकड़ी, सूखे बाँस, सूखी '
                          'मोटी रस्सी या प्लास्टिक से धकेलकर अलग करें — हाथ से कभी '
                          'नहीं।',
                      'ख़ुद सूखी जगह पर खड़े हों; रबर की चप्पल पहनी हो तो और बेहतर। '
                          'गीली ज़मीन पर खड़े होकर यह न करें।',
                      'अलग होने के बाद देखें कि साँस चल रही है या नहीं।',
                      '108 बुलाएँ और बताएँ कि बिजली का झटका लगा है।',
                      'साँस न चल रही हो तो छाती पर दबाव (CPR) शुरू करें, अगर आपको '
                          'आता है, और एम्बुलेंस आने तक जारी रखें।',
                    ]
                  : const [
                      'Switch off at the mains or the MCB. If you cannot '
                          'reach it, pull the plug.',
                      'If the power cannot be cut, push them clear with dry '
                          'wood, dry bamboo, a thick dry rope or plastic - '
                          'never with your hand.',
                      'Stand on something dry yourself; rubber slippers help. '
                          'Do not do this standing on wet ground.',
                      'Once they are clear, check whether they are '
                          'breathing.',
                      'Call 108 and say it is an electric shock.',
                      'If they are not breathing, start chest compressions '
                          '(CPR) if you know how, and keep going until the '
                          'ambulance arrives.',
                    ],
            ),
          ] else if (_case == ShockCase.personFree)
            ToolAnswer(
              headline: hi
                  ? 'ठीक लग रहे हों तो भी दिखाना ज़रूरी है'
                  : 'Get them seen even if they seem fine',
              detail: hi
                  ? 'बिजली का झटका बाहर से कम और अंदर से ज़्यादा नुक़सान करता है। '
                      'जलने का निशान छोटा दिखे तो भी अंदर गहरा हो सकता है, और झटके के '
                      'बाद कुछ घंटों तक दिल की धड़कन गड़बड़ा सकती है। इसलिए अस्पताल '
                      'ज़रूर जाएँ, ख़ासकर अगर: बेहोशी आई हो, सीने में दर्द या धड़कन '
                      'तेज़ हो, साँस में तकलीफ़ हो, जलन का निशान हो, या झटका छाती के '
                      'आसपास से गुज़रा हो। गर्भवती महिला और बच्चे को हर हाल में '
                      'दिखाएँ।'
                  : 'An electric shock does less damage outside than inside. '
                      'A small-looking burn can be deep, and the heartbeat '
                      'can go irregular for some hours afterwards. So go to a '
                      'hospital, particularly if there was any loss of '
                      'consciousness, chest pain or a racing heart, '
                      'difficulty breathing, a burn mark, or if the current '
                      'passed near the chest. A pregnant woman or a child '
                      'should be seen in every case.',
              tone: ToolTone.warn,
              icon: Icons.local_hospital_outlined,
            )
          else if (_case == ShockCase.fallenWire)
            ToolAnswer(
              headline: hi
                  ? 'दूर रहें और दूसरों को रोकें'
                  : 'Stay back, and keep others back',
              detail: hi
                  ? 'गिरे हुए तार से कम से कम दस क़दम दूर रहें, और यह मानकर चलें कि '
                      'उसमें बिजली है — लाइन अपने आप दोबारा चालू हो जाती है। तार के '
                      'आसपास की गीली ज़मीन से भी बिजली फैलती है, इसलिए पानी में खड़े '
                      'तार के पास बिल्कुल न जाएँ। आसपास के लोगों, ख़ासकर बच्चों और '
                      'जानवरों को हटाएँ, किसी को खड़ा करके रास्ता रोकें, और बिजली '
                      'कंपनी के शिकायत नंबर तथा 112 पर फ़ोन करें। तार को किसी भी '
                      'लकड़ी या डंडे से हटाने की कोशिश न करें — यह मिथक है कि सूखी '
                      'लकड़ी बड़ी लाइन के लिए सुरक्षित है।'
                  : 'Stay at least ten paces from a fallen wire and assume it '
                      'is live - a line can re-energise on its own. The '
                      'current spreads through wet ground around it too, so '
                      'never approach a wire lying in water. Move people '
                      'back, children and animals especially, post someone to '
                      'keep the way blocked, and call the electricity '
                      'company\'s fault number and 112. Do not try to move it '
                      'with a stick of any kind - the idea that dry wood is '
                      'safe does not hold for a distribution line.',
              tone: ToolTone.bad,
              icon: Icons.warning_amber_outlined,
            )
          else
            ToolAnswer(
              headline: hi
                  ? 'पानी और बिजली — पहले मेन बंद'
                  : 'Water and electricity - mains off first',
              detail: hi
                  ? 'पानी भर रहा हो या दीवार गीली हो तो घर की मेन स्विच बंद कर दें, '
                      'और वह भी सूखी जगह पर खड़े होकर। पानी में डूबे स्विच, सॉकेट या '
                      'तार को न छुएँ। डूबे हुए बिजली के सामान को सुखाकर चलाने से पहले '
                      'इलेक्ट्रिशियन से जाँच कराएँ। बाढ़ के बाद घर की वायरिंग की जाँच '
                      'ज़रूरी है — पानी निकलने के बाद भी बहुत दिनों तक नमी तार के अंदर '
                      'रहती है।'
                  : 'If water is rising or a wall is wet, switch off the house '
                      'mains - standing somewhere dry to do it. Do not touch '
                      'a switch, socket or wire that is under water. Have an '
                      'electrician check submerged appliances before they are '
                      'used again, however dry they look. After a flood the '
                      'house wiring needs checking - damp stays inside the '
                      'insulation long after the water has gone.',
              tone: ToolTone.warn,
              icon: Icons.water_damage_outlined,
            ),
          const SizedBox(height: 14),
          ToolDonts(
            heading: hi ? 'झटके में कभी नहीं' : 'With a shock, never',
            items: hi
                ? const [
                    'बिजली के संपर्क में रहते हुए किसी को हाथ से न खींचें',
                    'गीले हाथ, गीले कपड़े या गीली ज़मीन से काम न करें',
                    'धातु की कोई चीज़ — लोहे का डंडा, सरिया, छाता — इस्तेमाल न करें',
                    'जले हुए हिस्से पर तेल, टूथपेस्ट या मक्खन न लगाएँ; साफ़ ठंडे पानी '
                        'से धोकर ढक दें',
                    'बेहोश व्यक्ति को पानी पिलाने की कोशिश न करें',
                  ]
                : const [
                    'Do not pull anyone by hand while they are in contact '
                        'with the current',
                    'Do not work with wet hands, wet clothes or on wet '
                        'ground',
                    'Use nothing metal - an iron rod, a bar, an umbrella',
                    'Do not put oil, toothpaste or butter on a burn; rinse '
                        'with clean cool water and cover it',
                    'Do not try to make an unconscious person drink',
                  ],
          ),
          const SourceNote(
              text: 'Central Electricity Authority', url: _ceaUrl),
        ],
      ],
    );
  }
}

// --- House wiring -----------------------------------------------------

class WiringSafetyPage extends StatefulWidget {
  const WiringSafetyPage({super.key});

  @override
  State<WiringSafetyPage> createState() => _WiringSafetyPageState();
}

class _WiringSafetyPageState extends State<WiringSafetyPage> {
  final Set<int> _signs = {};

  static const _signsEn = [
    'A switch, socket or plug that feels warm',
    'A smell of burning, or a scorch mark around a socket',
    'Lights dimming or flickering when the motor or iron starts',
    'The fuse or MCB tripping often',
    'A tingle from a tap, a fridge, a cooler or a motor body',
    'Bare joints, wires twisted together, or tape over a join',
    'Wires running across a wet wall or through water',
    'One socket running several appliances through extension boards',
  ];
  static const _signsHi = [
    'स्विच, सॉकेट या प्लग गरम लगना',
    'जलने जैसी गंध, या सॉकेट के आसपास काला निशान',
    'मोटर या इस्तरी चलाते ही बत्तियाँ मंद या टिमटिमाना',
    'फ़्यूज़ या MCB बार-बार गिरना',
    'नल, फ़्रिज, कूलर या मोटर की बॉडी से झनझनाहट',
    'खुले जोड़, तारों को मरोड़कर जोड़ना, या जोड़ पर टेप',
    'गीली दीवार पर या पानी में से होकर जाते तार',
    'एक सॉकेट से एक्सटेंशन बोर्ड लगाकर कई चीज़ें चलाना',
  ];

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final labels = hi ? _signsHi : _signsEn;
    final tingle = _signs.contains(4);

    return ToolScaffold(
      goal: 7,
      title: hi ? 'घर की वायरिंग सुरक्षित है?' : 'Is my house wiring safe',
      children: [
        ToolNote(hi
            ? 'घर में बिजली से होने वाली ज़्यादातर मौतें और आगें किसी बड़ी ख़राबी से '
                'नहीं, इन छोटे-छोटे संकेतों को महीनों नज़रअंदाज़ करने से होती हैं। जो '
                'भी दिख रहा हो, निशान लगाइए।'
            : 'Most deaths and fires from electricity at home come not from '
                'one big fault but from months of ignoring small signs. Tick '
                'whatever you can see.'),
        ToolQuestion(hi ? 'इनमें से क्या दिख रहा है' : 'Which of these do you see'),
        for (var i = 0; i < labels.length; i++)
          SelectionTile(
            label: labels[i],
            selected: _signs.contains(i),
            onTap: () => setState(() {
              if (!_signs.remove(i)) _signs.add(i);
            }),
          ),
        if (_signs.isNotEmpty) ...[
          if (tingle)
            ToolAnswer(
              headline: hi
                  ? 'झनझनाहट — यह आज ही देखना चाहिए'
                  : 'A tingle - this one needs attention today',
              detail: hi
                  ? 'नल, फ़्रिज या मोटर की बॉडी से झनझनाहट का मतलब है कि बिजली वहाँ '
                      'पहुँच रही है जहाँ नहीं पहुँचनी चाहिए, और अर्थिंग काम नहीं कर '
                      'रही। सूखी ज़मीन पर खड़े व्यक्ति को यह झनझनाहट लगती है; गीले '
                      'फ़र्श पर खड़े व्यक्ति को वही चीज़ मार सकती है। तब तक उस चीज़ का '
                      'इस्तेमाल बंद रखें और इलेक्ट्रिशियन को बुलाएँ।'
                  : 'A tingle from a tap, a fridge or a motor body means '
                      'current is reaching where it should not and the '
                      'earthing is not doing its job. Someone on dry ground '
                      'feels a tingle; the same fault can kill someone '
                      'standing on a wet floor. Stop using it and get an '
                      'electrician in.',
              tone: ToolTone.bad,
              icon: Icons.priority_high,
            )
          else
            ToolAnswer(
              headline: hi
                  ? '${_signs.length} संकेत — इलेक्ट्रिशियन से जाँच कराएँ'
                  : '${_signs.length} sign(s) - get an electrician to look',
              detail: hi
                  ? 'इनमें से हर एक अपने आप में छोटी बात लगती है और हर एक आगे बढ़कर '
                      'आग या झटका बनती है। जाँच में ज़्यादा ख़र्च नहीं आता।'
                  : 'Each of these looks small on its own, and each is how a '
                      'fire or a shock begins. Having it looked at does not '
                      'cost much.',
              tone: ToolTone.warn,
              icon: Icons.electrical_services_outlined,
            ),
        ],
        const SizedBox(height: 14),
        ToolAnswer(
          headline: hi
              ? 'एक चीज़ जो सबसे ज़्यादा जानें बचाती है'
              : 'The one device that prevents most deaths',
          detail: hi
              ? 'RCCB या ELCB — बिजली के बोर्ड में लगने वाला एक छोटा स्विच। यह बहते '
                  'हुए करंट में ज़रा सा भी रिसाव पकड़कर बिजली पलक झपकते बंद कर देता '
                  'है, तब भी जब अर्थिंग ठीक न हो। फ़्यूज़ और MCB घर के तारों को बचाते '
                  'हैं; RCCB आदमी को बचाता है — और घरों में यही नहीं लगा होता। किसी भी '
                  'इलेक्ट्रिशियन से लगवाया जा सकता है, और जहाँ पानी और बिजली साथ हैं '
                  '— मोटर, गीज़र, नहाने की जगह — वहाँ यह सबसे ज़्यादा ज़रूरी है।'
              : 'An RCCB or ELCB - a small switch fitted in the board. It '
                  'detects the slightest leakage in the flowing current and '
                  'cuts the supply in a blink, even where the earthing is '
                  'poor. A fuse and an MCB protect the house wiring; an RCCB '
                  'protects the person - and it is the thing houses do not '
                  'have. Any electrician can fit one, and it matters most '
                  'where water and electricity meet: the motor, the geyser, '
                  'the bathing area.',
          tone: ToolTone.good,
          icon: Icons.shield_outlined,
        ),
        const SizedBox(height: 14),
        Text(hi ? 'अर्थिंग के बारे में' : 'About the earthing',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'तीन पिन वाले सॉकेट में तीसरा पिन अर्थिंग का होता है, और वही बचाता '
                      'है। बहुत घरों में वह पिन जुड़ा ही नहीं होता — दिखने में सॉकेट '
                      'वही रहता है।',
                  'मोटर, गीज़र, फ़्रिज और वॉशिंग मशीन — इन सबकी बॉडी अर्थ होनी चाहिए।',
                  'तीन पिन के प्लग का तीसरा पिन काटकर दो पिन में न लगाएँ। यह बहुत '
                      'आम है और यही झनझनाहट की जड़ है।',
                  'अर्थिंग का गड्ढा गर्मियों में सूख जाता है; साल में एक-दो बार उसमें '
                      'पानी डालना चाहिए।',
                  'इलेक्ट्रिशियन से अर्थिंग की जाँच करा लें — यह थोड़ी देर का काम है।',
                ]
              : const [
                  'In a three-pin socket the third pin is the earth, and that '
                      'is the one that protects you. In many houses it is not '
                      'connected to anything - the socket looks identical.',
                  'The motor, the geyser, the fridge and the washing machine '
                      'should all have their bodies earthed.',
                  'Do not cut the third pin off a three-pin plug to fit a '
                      'two-pin socket. It is very common, and it is where the '
                      'tingles come from.',
                  'The earth pit dries out in summer; it should have water '
                      'poured into it once or twice a year.',
                  'Have an electrician test the earthing - it takes a few '
                      'minutes.',
                ],
        ),
        ToolDonts(
          heading: hi ? 'घर में यह न करें' : 'Not in the house',
          items: hi
              ? const [
                  'फ़्यूज़ की जगह तार या कील न लगाएँ। फ़्यूज़ का काम ही है जलकर टूट '
                      'जाना; तार लगाने से वह आग तक नहीं रुकती।',
                  'एक सॉकेट पर कई एक्सटेंशन बोर्ड न जोड़ें',
                  'गीले हाथ से स्विच या प्लग न छुएँ',
                  'तार कील या स्टेपल से दीवार पर न ठोकें — इससे अंदर का तार कटता है',
                  'खुले जोड़ पर टेप लगाकर छोड़ न दें; जोड़ जंक्शन बॉक्स में होना चाहिए',
                  'बच्चों की पहुँच में सॉकेट खुला न छोड़ें; सस्ती सेफ़्टी कैप लग जाती है',
                ]
              : const [
                  'Never put wire or a nail where a fuse goes. A fuse is '
                      'meant to blow; a wire in its place will not stop even '
                      'a fire.',
                  'Do not chain extension boards off one socket',
                  'Do not touch a switch or plug with wet hands',
                  'Do not nail or staple wire to a wall - it cuts the '
                      'insulation inside',
                  'Do not leave a taped joint as a permanent repair; joints '
                      'belong in a junction box',
                  'Do not leave a socket open within a child\'s reach; a '
                      'cheap safety cap fits',
                ],
        ),
        const SourceNote(text: 'Central Electricity Authority', url: _ceaUrl),
      ],
    );
  }
}
