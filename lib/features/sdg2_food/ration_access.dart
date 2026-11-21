import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Grain away from home, and grain with no card at all.
///
/// These are the two ration problems that send people home empty-handed.
/// The first is pure misinformation: portability works, nationwide, and the
/// dealer who says "your card is not from this state" is either wrong or
/// lying. The second is the harder one - a family genuinely not on the list
/// - and the useful part there is that the application is not the only
/// route to food while it is pending.

const _onorcUrl = 'https://nfsa.gov.in/portal/onorc';
const _nfsaUrl = 'https://nfsa.gov.in/';
const _meraRationUrl = 'https://nfsa.gov.in/portal/Mera_Ration_Mobile_App';

/// Where the family is trying to draw its ration. Portability covers the
/// first two; the third is a different thing entirely.
enum PortabilityCase { otherState, sameStateOtherShop, familySplit }

class RationPortabilityPage extends StatefulWidget {
  const RationPortabilityPage({super.key});

  @override
  State<RationPortabilityPage> createState() => _RationPortabilityPageState();
}

class _RationPortabilityPageState extends State<RationPortabilityPage> {
  PortabilityCase? _case;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    Widget pick(PortabilityCase c, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _case == c,
          onTap: () => setState(() => _case = c),
        );

    return ToolScaffold(
      goal: 2,
      title: hi ? 'दूसरे राज्य में राशन' : 'Ration in another state',
      children: [
        ToolNote(hi
            ? 'एक देश एक राशन कार्ड के बाद आपका कार्ड पूरे देश में चलता है। काम के लिए '
                'दूसरे राज्य गए मज़दूर को वहीं की किसी भी राशन दुकान से अपना हिस्सा मिल '
                'सकता है — कार्ड बदलवाने की ज़रूरत नहीं, नया बनवाने की ज़रूरत नहीं। '
                '"यह कार्ड यहाँ नहीं चलेगा" — यह बात ग़लत है।'
            : 'Since One Nation One Ration Card, your card works anywhere in '
                'the country. A worker who has gone to another state for work '
                'can draw their share from any ration shop there - no need to '
                'change the card, no need for a new one. "This card does not '
                'work here" is simply untrue.'),
        ToolQuestion(hi ? 'हालत क्या है' : 'What is the situation'),
        pick(PortabilityCase.otherState,
            'We are in a different state from where the card was made',
            'हम उस राज्य से बाहर हैं जहाँ कार्ड बना था'),
        pick(PortabilityCase.sameStateOtherShop,
            'Same state, but a different shop or district',
            'वही राज्य, लेकिन दूसरी दुकान या ज़िला'),
        pick(PortabilityCase.familySplit,
            'Part of the family is here and part is back home',
            'परिवार का कुछ हिस्सा यहाँ है और कुछ घर पर'),
        if (_case != null) ...[
          ToolAnswer(
            headline: _case == PortabilityCase.familySplit
                ? (hi
                    ? 'दोनों जगह से लिया जा सकता है'
                    : 'Both places can draw from it')
                : (hi ? 'हाँ, यहीं मिलेगा' : 'Yes, you can draw it here'),
            detail: _case == PortabilityCase.familySplit
                ? (hi
                    ? 'एक ही कार्ड पर परिवार के कुछ सदस्य यहाँ और कुछ गाँव में अपना '
                        'हिस्सा ले सकते हैं। हिसाब सदस्य के हिसाब से होता है: जो यहाँ है '
                        'वह अपनी उँगली लगाकर अपने हिस्से का अनाज लेता है, और बाक़ी गाँव '
                        'में रह जाता है। दुकानदार को यह व्यवस्था मालूम होनी चाहिए; न हो '
                        'तो उसे "आंशिक पोर्टेबिलिटी" कहकर बताएँ।'
                    : 'On one card, some members can draw here and others in '
                        'the village. The accounting is per member: whoever '
                        'is here puts their finger on the machine and takes '
                        'their own share of the grain, and the rest stays for '
                        'the village. The dealer should know this; if not, '
                        'the words to use are "partial portability".')
                : (hi
                    ? 'किसी भी राशन दुकान पर जाएँ जहाँ ई-पॉस मशीन हो — अब लगभग सब '
                        'जगह है। कार्ड पर जिसका नाम और आधार है, उसकी उँगली मशीन पर '
                        'लगती है, और अनाज वहीं मिल जाता है। पहले से कोई अर्ज़ी, कोई '
                        'अनुमति, कोई तबादला नहीं कराना पड़ता।'
                    : 'Go to any ration shop with an ePoS machine - nearly '
                        'all of them have one now. Whoever on the card has '
                        'their Aadhaar linked puts a finger on the machine, '
                        'and the grain is given there. No prior application, '
                        'no permission, no transfer of the card.'),
            tone: ToolTone.good,
            icon: Icons.swap_horiz,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'जाने से पहले' : 'Before you go',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const ToolChecklist(
            storageKey: 'onorc_ready_v1',
            items: [
              CheckItem('aadhaar', 'Aadhaar must be linked to the ration '
                  'card for the member who will collect it',
                  'जो लेने जाएगा, उसका आधार राशन कार्ड से जुड़ा होना चाहिए',
                  noteEn: 'This is the one thing that actually stops '
                      'portability. Get it linked at the shop or the food '
                      'office before travelling.',
                  noteHi: 'पोर्टेबिलिटी असल में इसी एक बात पर रुकती है। यात्रा से पहले '
                      'दुकान या खाद्य कार्यालय में जुड़वा लें।'),
              CheckItem('number', 'Carry the ration card number, or a photo '
                  'of the card on the phone',
                  'राशन कार्ड नंबर, या फ़ोन में कार्ड की फ़ोटो साथ रखें'),
              CheckItem('app', 'Install the Mera Ration app - it finds the '
                  'nearest shop and shows what you are owed',
                  'मेरा राशन ऐप डाल लें — यह नज़दीकी दुकान और आपका हिस्सा बताता है'),
              CheckItem('nomobile', 'Note the state food helpline where you '
                  'are going', 'जहाँ जा रहे हैं, वहाँ की खाद्य हेल्पलाइन लिख लें'),
            ],
          ),
          const SizedBox(height: 10),
          ToolAnswer(
            headline: hi ? 'दुकानदार मना कर दे तो' : 'If the dealer refuses',
            detail: hi
                ? 'उससे मना करने की वजह लिखकर माँगें, और मशीन पर उँगली लगवाने को '
                    'कहें — मशीन ख़ुद बता देती है कि कार्ड चलेगा या नहीं। फिर भी मना करे '
                    'तो राज्य की खाद्य हेल्पलाइन पर शिकायत करें और दुकान का नाम, कोड और '
                    'तारीख़ बताएँ। "मुझे आज कुछ नहीं मिला" से कम काम बनता है; "दुकान '
                    'संख्या X पर आज मना किया गया" से ज़्यादा।'
                : 'Ask for the refusal in writing, and ask them to put your '
                    'finger on the machine - the machine itself says whether '
                    'the card works. If they still refuse, complain on the '
                    'state food helpline with the shop\'s name, code and the '
                    'date. "I got nothing today" does less; "shop number X '
                    'refused me today" does more.',
            tone: ToolTone.warn,
            icon: Icons.report_outlined,
          ),
          const SourceNote(text: 'One Nation One Ration Card', url: _onorcUrl),
          const SourceNote(text: 'Mera Ration app', url: _meraRationUrl),
        ],
      ],
    );
  }
}

// --- No card at all ---------------------------------------------------

/// Why the family has no card. Each reason has its own route, and only one
/// of them is actually "you are not eligible".
enum NoCardReason {
  neverApplied,
  applicationPending,
  removedFromList,
  movedHere,
  cardInOldVillage,
}

class NoRationCardPage extends StatefulWidget {
  const NoRationCardPage({super.key});

  @override
  State<NoRationCardPage> createState() => _NoRationCardPageState();
}

class _NoRationCardPageState extends State<NoRationCardPage> {
  NoCardReason? _reason;

  String _route(NoCardReason r, bool hi) => switch (r) {
        NoCardReason.neverApplied => hi
            ? 'अर्ज़ी राज्य के खाद्य विभाग के पोर्टल पर, या ब्लॉक/तहसील के खाद्य '
                'कार्यालय में, या कई राज्यों में कॉमन सर्विस सेंटर पर दी जाती है। परिवार '
                'के मुखिया का आधार, सब सदस्यों के आधार, रहने का सबूत और आय का '
                'घोषणा-पत्र लगता है। रसीद लेना न भूलें।'
            : 'The application goes on the state food department\'s portal, '
                'or at the block or tehsil food office, or in many states at '
                'a Common Service Centre. It needs the head of the family\'s '
                'Aadhaar, Aadhaar for every member, proof of where you live, '
                'and an income declaration. Take the receipt.',
        NoCardReason.applicationPending => hi
            ? 'अर्ज़ी संख्या से पोर्टल पर स्थिति देखें — वह आमतौर पर बता देती है कि कहाँ '
                'अटकी है। एक महीने से ऊपर हो गया हो तो खाद्य कार्यालय में लिखित में '
                'पूछें कि कौन सा काग़ज़ या कौन सा सत्यापन बाक़ी है।'
            : 'Check the status on the portal with the application number - '
                'it usually names the step it is stuck at. If it is over a '
                'month, ask the food office in writing which document or '
                'which verification is pending.',
        NoCardReason.removedFromList => hi
            ? 'नाम काटने का कारण लिखित में माँगें। आम कारण: सत्यापन में घर पर कोई '
                'नहीं मिला, आधार दो कार्डों में दर्ज मिला, या किसी सदस्य की मृत्यु के बाद '
                'पूरा कार्ड रद्द कर दिया गया। तीनों सुधर सकते हैं, और सुधरने पर पीछे के '
                'महीनों का अनाज भी कई राज्यों में मिलता है।'
            : 'Ask for the reason in writing. The common ones: nobody was '
                'home at verification, the Aadhaar was found on two cards, or '
                'the whole card was cancelled after one member died. All '
                'three are correctable, and several states release the '
                'withheld months\' grain once it is.',
        NoCardReason.movedHere => hi
            ? 'पुराना कार्ड चालू रखते हुए यहीं से अनाज लिया जा सकता है — एक देश एक '
                'राशन कार्ड। नया कार्ड तभी बनवाएँ जब यहाँ पक्का रहना है; तब पुराना '
                'सरेंडर करना होता है, वरना दोनों रद्द होने का ख़तरा रहता है।'
            : 'You can keep the old card and draw the grain here - that is '
                'One Nation One Ration Card. Apply for a new card only if you '
                'are settling here; then the old one has to be surrendered, '
                'or there is a risk of both being cancelled.',
        NoCardReason.cardInOldVillage => hi
            ? 'कार्ड घर पर है और आप बाहर हैं, तो नंबर काफ़ी है: घर वालों से कार्ड की '
                'फ़ोटो भेजने को कहें और उसी नंबर पर यहाँ की दुकान से अपना हिस्सा लें।'
            : 'If the card is at home and you are away, the number is '
                'enough: ask them to send a photo of the card and draw your '
                'own share from a shop here on that number.',
      };

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    Widget pick(NoCardReason r, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _reason == r,
          onTap: () => setState(() => _reason = r),
        );

    return ToolScaffold(
      goal: 2,
      title: hi ? 'राशन सूची में नाम ही नहीं' : 'Not on the ration list at all',
      children: [
        ToolNote(hi
            ? 'राशन कार्ड के बिना भी भूखा नहीं रहना है। अर्ज़ी में समय लगता है, लेकिन '
                'उस बीच भी रास्ते हैं — नीचे वे अलग से लिखे हैं।'
            : 'Being without a ration card does not have to mean going '
                'hungry. The application takes time, but there are routes in '
                'the meantime - they are set out separately below.'),
        ToolQuestion(hi ? 'कार्ड क्यों नहीं है' : 'Why is there no card'),
        pick(NoCardReason.neverApplied, 'We never applied',
            'कभी अर्ज़ी नहीं दी'),
        pick(NoCardReason.applicationPending, 'We applied and it is pending',
            'अर्ज़ी दी है, अभी लंबित है'),
        pick(NoCardReason.removedFromList, 'Our name was removed',
            'हमारा नाम काट दिया गया'),
        pick(NoCardReason.movedHere, 'We moved here from another place',
            'हम कहीं और से यहाँ आए हैं'),
        pick(NoCardReason.cardInOldVillage,
            'The card is at home, we are working elsewhere',
            'कार्ड घर पर है, हम कमाने बाहर हैं'),
        if (_reason != null) ...[
          ToolAnswer(
            headline: hi ? 'इस हालत में यह करें' : 'In this case, do this',
            detail: _route(_reason!, hi),
            tone: ToolTone.plain,
            icon: Icons.assignment_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'कार्ड बनने तक, अभी के लिए' : 'Until the card comes',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'घर में छह साल से छोटा बच्चा, या गर्भवती/दूध पिलाती माँ हो तो '
                        'आँगनवाड़ी से पोषण मिलता है — इसके लिए राशन कार्ड नहीं चाहिए। '
                        'इसी लक्ष्य में "आँगनवाड़ी से क्या मिलना चाहिए" देखें।',
                    'स्कूल जाने वाले बच्चों को मध्याह्न भोजन मिलता है, कार्ड से कोई '
                        'मतलब नहीं।',
                    'कई राज्यों में खाद्य अधिकारी अस्थायी पर्ची या आपातकालीन कोटा दे '
                        'सकते हैं। लिखित में माँगें।',
                    'तहसील या ज़िला आपूर्ति अधिकारी के पास सीधे अर्ज़ी दी जा सकती है, '
                        'और उस पर सुनवाई होती है।',
                    'राज्य की खाद्य हेल्पलाइन पर शिकायत दर्ज कराएँ और संख्या रख लें।',
                  ]
                : const [
                    'If there is a child under six, or a pregnant or nursing '
                        'mother in the house, the anganwadi gives nutrition - '
                        'and that needs no ration card. See "What the '
                        'anganwadi owes you" in this goal.',
                    'Children in school get the midday meal, which has '
                        'nothing to do with the card.',
                    'In several states the food officer can issue a '
                        'temporary slip or an emergency quota. Ask in '
                        'writing.',
                    'An application can go straight to the tehsil or '
                        'district supply officer, and it gets a hearing.',
                    'Register a complaint on the state food helpline and '
                        'keep the number.',
                  ],
          ),
          const SizedBox(height: 10),
          const ToolChecklist(
            storageKey: 'ration_apply_papers_v1',
            introEn: 'What the application asks for, in most states.',
            introHi: 'ज़्यादातर राज्यों में अर्ज़ी के साथ यह लगता है।',
            items: [
              CheckItem('head', 'Aadhaar of the head of the family',
                  'परिवार के मुखिया का आधार'),
              CheckItem('all', 'Aadhaar of every member to be included',
                  'जिन सब सदस्यों का नाम जोड़ना है, सबके आधार'),
              CheckItem('address', 'Proof of where you live - electricity '
                  'bill, rent paper, or a panchayat certificate',
                  'रहने का सबूत — बिजली बिल, किराये का काग़ज़, या पंचायत का प्रमाण पत्र'),
              CheckItem('income', 'Income declaration or certificate',
                  'आय का घोषणा-पत्र या प्रमाण पत्र'),
              CheckItem('bank', 'Bank passbook of the head of the family',
                  'मुखिया की बैंक पासबुक'),
              CheckItem('photo', 'A family photograph, where the state asks '
                  'for one', 'परिवार की फ़ोटो, जहाँ राज्य माँगता है'),
              CheckItem('surrender', 'If there was a card elsewhere, its '
                  'surrender certificate',
                  'कहीं और कार्ड था तो उसका सरेंडर प्रमाण पत्र'),
              CheckItem('receipt', 'The receipt for the application - keep it',
                  'अर्ज़ी की रसीद — सँभालकर रखें'),
            ],
          ),
          const SourceNote(
              text: 'National Food Security Act portal', url: _nfsaUrl),
        ],
      ],
    );
  }
}
