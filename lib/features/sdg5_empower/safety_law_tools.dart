import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Four screens where the law is on her side and nobody has told her.
///
/// A note on how these are built. The protection-order screen saves
/// nothing - no ticks, no answers, nothing written to the phone. Every
/// other checklist in this app remembers where you were, which is right
/// for a list of papers to gather over weeks and wrong here: a saved tick
/// on a shared phone can be read by the person she is afraid of. So that
/// screen uses only steps that keep no state, and it says so on itself.
///
/// All four avoid two mistakes that advice on these subjects usually
/// makes. They never suggest confronting anyone, and they never present a
/// legal route as quick when it is not. What they do is name the office,
/// the number and the relief, because that is what is missing.

const _nalsaUrl = 'https://nalsa.gov.in/';
const _wcdUrl = 'https://wcd.gov.in/';
const _dowryActUrl =
    'https://indiacode.nic.in/bitstream/123456789/16243/1/196128.pdf';
const _pcmaUrl = 'https://wcd.gov.in/act/prohibition-child-marriage-act-2006';

// --- Domestic violence: protection order ------------------------------

/// What she needs the order to do. The Act gives several distinct
/// reliefs, and asking for the wrong one, or only one, is a common loss.
enum DvRelief { stopViolence, stayInHome, money, children, allOfIt }

class ProtectionOrderPage extends StatefulWidget {
  const ProtectionOrderPage({super.key});

  @override
  State<ProtectionOrderPage> createState() => _ProtectionOrderPageState();
}

class _ProtectionOrderPageState extends State<ProtectionOrderPage> {
  DvRelief? _relief;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;

    Widget pick(DvRelief r, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _relief == r,
          onTap: () => setState(() => _relief = r),
        );

    return ToolScaffold(
      goal: 5,
      title: hi ? 'घरेलू हिंसा: संरक्षण आदेश' : 'Domestic violence: a protection order',
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: scheme.error,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.phone_in_talk_outlined, color: scheme.onError,
                  size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hi
                      ? 'अभी ख़तरा है तो 112। महिला हेल्पलाइन 181, चौबीसों घंटे। '
                          'ये नंबर याद कर लें — फ़ोन में लिखे होने की ज़रूरत नहीं।'
                      : 'If you are in danger now, 112. Women\'s helpline '
                          '181, any hour. Memorise these - they do not need '
                          'to be written in the phone.',
                  style: TextStyle(
                      fontSize: 14.5,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                      color: scheme.onError),
                ),
              ),
            ],
          ),
        ),
        ToolNote(hi
            ? 'यह स्क्रीन कुछ भी सहेजती नहीं है — कोई निशान, कोई जवाब, कुछ भी फ़ोन '
                'में दर्ज नहीं होता। बाक़ी ऐप में सूचियाँ याद रहती हैं, यहाँ जानबूझकर '
                'नहीं। अगर फ़ोन साझा है तो इस स्क्रीन को बंद करके ब्राउज़िंग साफ़ कर '
                'देना सुरक्षित है।'
            : 'This screen saves nothing - no ticks, no answers, nothing '
                'written to the phone. Lists elsewhere in the app remember '
                'where you were; here that is deliberately off. If the phone '
                'is shared, closing this and clearing your browsing is the '
                'safer thing.'),
        ToolNote(hi
            ? 'घरेलू हिंसा का मतलब मार-पीट ही नहीं है। क़ानून में गाली-गलौज और '
                'अपमान, धमकी, पैसा और ज़रूरी चीज़ें रोक देना, घर से निकालना, और दहेज '
                'की माँग से किया जाने वाला उत्पीड़न — ये सब इसमें आते हैं। और यह '
                'क़ानून पत्नी के साथ-साथ घर की माँ, बहन और बेटी के लिए भी है।'
            : 'Domestic violence does not mean being beaten alone. The Act '
                'covers abuse and humiliation, threats, withholding money and '
                'necessities, being thrown out of the house, and harassment '
                'over dowry demands. And the Act is for a mother, sister or '
                'daughter in the household as much as for a wife.'),
        ToolQuestion(hi ? 'आप किस चीज़ से बचाव चाहती हैं' : 'What do you need stopped'),
        pick(DvRelief.stopViolence,
            'The violence and the threats, and him coming near me',
            'हिंसा और धमकी, और उसका पास आना'),
        pick(DvRelief.stayInHome,
            'Being thrown out of the house I live in',
            'जिस घर में रहती हूँ, उससे निकाला जाना'),
        pick(DvRelief.money, 'Money for myself and the children',
            'अपने और बच्चों के ख़र्च का पैसा'),
        pick(DvRelief.children, 'Keeping the children with me',
            'बच्चों को अपने पास रखना'),
        pick(DvRelief.allOfIt, 'All of these', 'ये सब'),
        if (_relief != null) ...[
          ToolAnswer(
            headline: hi
                ? 'ये सब एक ही अर्ज़ी में माँगे जा सकते हैं'
                : 'All of these can be asked for in one application',
            detail: hi
                ? 'घरेलू हिंसा से महिलाओं का संरक्षण अधिनियम, 2005 में अलग-अलग '
                    'राहतें हैं, और एक ही अर्ज़ी में सब माँगी जा सकती हैं। एक ही राहत '
                    'माँगना आम नुक़सान है — इसलिए जो भी ज़रूरी हो, सब एक साथ माँगें।'
                : 'The Protection of Women from Domestic Violence Act, 2005 '
                    'provides several distinct reliefs, and one application '
                    'can ask for all of them. Asking for only one is a common '
                    'loss - so ask for everything that applies, together.',
            tone: ToolTone.good,
            icon: Icons.shield_outlined,
          ),
          const SizedBox(height: 12),
          Text(hi ? 'अदालत क्या कर सकती है' : 'What the court can order',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            numbered: false,
            steps: hi
                ? const [
                    'संरक्षण आदेश: वह हिंसा नहीं करेगा, आपके काम की जगह या बच्चों के '
                        'स्कूल नहीं आएगा, और फ़ोन या किसी और तरीक़े से संपर्क नहीं करेगा',
                    'निवास आदेश: आपको उस घर से निकाला नहीं जा सकता जिसमें आप रहती '
                        'हैं — चाहे घर आपके नाम न हो। ज़रूरत पड़े तो अदालत उसे घर से '
                        'दूर रहने को कह सकती है',
                    'आर्थिक राहत: आपका और बच्चों का ख़र्च, इलाज का ख़र्च, और हिंसा से '
                        'हुए नुक़सान की भरपाई',
                    'संरक्षण (कस्टडी) आदेश: बच्चे आपके पास रहेंगे',
                    'मुआवज़ा: चोट और मानसिक पीड़ा के लिए',
                  ]
                : const [
                    'A protection order: he is not to commit violence, not '
                        'to come to your workplace or the children\'s school, '
                        'and not to contact you by phone or any other way',
                    'A residence order: you cannot be put out of the house '
                        'you live in - even if it is not in your name. Where '
                        'needed the court can order him to stay away from it',
                    'Monetary relief: maintenance for you and the children, '
                        'medical expenses, and the loss caused by the '
                        'violence',
                    'A custody order: the children stay with you',
                    'Compensation: for the injury and the mental suffering',
                  ],
          ),
          const SizedBox(height: 14),
          Text(hi ? 'अर्ज़ी कैसे जाती है' : 'How the application is made',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'अर्ज़ी मजिस्ट्रेट की अदालत में जाती है, और इसकी कोई फ़ीस नहीं है।',
                    'आप ख़ुद दे सकती हैं, या आपकी ओर से कोई और भी दे सकता है — '
                        'रिश्तेदार, पड़ोसी, या कोई संस्था।',
                    'ज़िले में संरक्षण अधिकारी (Protection Officer) नियुक्त होता है, '
                        'और उसका काम यही है: घटना की रिपोर्ट बनाना और अर्ज़ी दाख़िल '
                        'कराना। पता ज़िला महिला एवं बाल विकास कार्यालय से मिलता है।',
                    'वन स्टॉप सेंटर (सखी) — हर ज़िले में होता है, आमतौर पर ज़िला '
                        'अस्पताल में। वहाँ एक ही जगह अस्थायी ठहराव, इलाज, पुलिस की '
                        'मदद, वकील और काउंसलिंग मिलती है। 181 पर पूछें कि आपके ज़िले '
                        'में कहाँ है।',
                    'वकील मुफ़्त मिलता है — ज़िला विधिक सेवा प्राधिकरण, हेल्पलाइन '
                        '15100। यह आपका हक़ है, कोई रियायत नहीं।',
                    'क़ानून कहता है कि अदालत मामले को साठ दिन में निपटाने की कोशिश '
                        'करे। असल में ज़्यादा समय लग सकता है, लेकिन अंतरिम आदेश पहली '
                        'कुछ तारीख़ों में ही मिल सकता है — इसलिए शुरू में ही अंतरिम राहत '
                        'माँगें।',
                  ]
                : const [
                    'The application goes to a magistrate\'s court, and there '
                        'is no fee.',
                    'You can file it yourself, or someone can file it on your '
                        'behalf - a relative, a neighbour, or an '
                        'organisation.',
                    'Every district has a Protection Officer, and this is '
                        'their job: to record the incident and get the '
                        'application filed. The address comes from the '
                        'district women and child development office.',
                    'A One Stop Centre (Sakhi) - there is one in every '
                        'district, usually at the district hospital. In one '
                        'place it gives temporary shelter, medical help, '
                        'police assistance, a lawyer and counselling. Call '
                        '181 to ask where yours is.',
                    'A lawyer is free - the District Legal Services '
                        'Authority, helpline 15100. This is a right, not a '
                        'concession.',
                    'The Act says the court should try to dispose of the case '
                        'in sixty days. In practice it can take longer, but '
                        'an interim order can come in the first few hearings - '
                        'so ask for interim relief at the very start.',
                  ],
          ),
          ToolDonts(
            heading: hi
                ? 'यह आपकी ग़लती नहीं है — और यह न मानें'
                : 'None of this is your fault - and do not accept these',
            items: hi
                ? const [
                    '"पहले घर में सुलझा लो" — पुलिस या कोई और यह कहकर शिकायत लेने '
                        'से मना नहीं कर सकता',
                    '"घर तुम्हारे नाम नहीं है, तो निकल जाओ" — निवास का अधिकार नाम पर '
                        'निर्भर नहीं है',
                    '"अर्ज़ी के पैसे लगेंगे" — कोई फ़ीस नहीं है, और वकील भी मुफ़्त है',
                    '"वकील के बिना कुछ नहीं होगा" — संरक्षण अधिकारी और वन स्टॉप सेंटर '
                        'इसी के लिए हैं',
                  ]
                : const [
                    '"Settle it at home first" - neither the police nor '
                        'anyone else may refuse your complaint on that '
                        'ground',
                    '"The house is not in your name, so leave" - the right '
                        'to reside does not depend on whose name it is in',
                    '"The application will cost money" - there is no fee, and '
                        'the lawyer is free too',
                    '"Nothing will happen without a lawyer" - the Protection '
                        'Officer and the One Stop Centre exist for exactly '
                        'this',
                  ],
          ),
          ToolNote(hi
              ? 'अगर अभी जाने की सोच रही हैं और कुछ साथ ले जा सकें तो: आधार, बैंक '
                  'पासबुक, बच्चों के स्कूल के काग़ज़, दवाएँ, और शादी का कोई सबूत। लेकिन '
                  'अगर यह सब जुटाने में ख़तरा बढ़ता हो तो छोड़ दें — काग़ज़ दोबारा बनते '
                  'हैं। 181 और 112 दोनों काग़ज़ के बिना भी काम करते हैं।'
              : 'If you are thinking of leaving and can take anything: '
                  'Aadhaar, the bank passbook, the children\'s school papers, '
                  'medicines, and any proof of the marriage. But if gathering '
                  'them raises the risk, leave them - papers can be made '
                  'again. Both 181 and 112 work without any of them.'),
          const SourceNote(
              text: 'Free legal services - National Legal Services Authority',
              url: _nalsaUrl),
          const SourceNote(
              text: 'Ministry of Women and Child Development', url: _wcdUrl),
        ],
      ],
    );
  }
}

// --- Dowry demand -----------------------------------------------------

/// When the demand is being made. It decides which law bites hardest and
/// which office to go to.
enum DowryWhen { beforeMarriage, atMarriage, afterMarriage, harassmentNow }

class DowryPage extends StatefulWidget {
  const DowryPage({super.key});

  @override
  State<DowryPage> createState() => _DowryPageState();
}

class _DowryPageState extends State<DowryPage> {
  DowryWhen? _when;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    Widget pick(DowryWhen w, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _when == w,
          onTap: () => setState(() => _when = w),
        );

    return ToolScaffold(
      goal: 5,
      title: hi ? 'दहेज की माँग' : 'A dowry demand',
      children: [
        ToolNote(hi
            ? 'दहेज माँगना अपने आप में अपराध है — देने या लेने से पहले ही, सिर्फ़ '
                'माँगना। दहेज प्रतिषेध अधिनियम, 1961 में माँगने की सज़ा छह महीने से '
                'दो साल तक की क़ैद और दस हज़ार रुपये तक जुर्माना है, और देने-लेने की '
                'सज़ा कम से कम पाँच साल और दहेज की रक़म या पंद्रह हज़ार, जो ज़्यादा हो, '
                'का जुर्माना। ये अपराध ग़ैर-ज़मानती हैं और समझौते से ख़त्म नहीं होते।'
            : 'Demanding dowry is an offence in itself - before anything is '
                'given or taken, the demand alone. Under the Dowry '
                'Prohibition Act, 1961 demanding it carries six months to two '
                'years\' imprisonment and a fine up to ten thousand rupees, '
                'and giving or taking it carries not less than five years and '
                'a fine of the value of the dowry or fifteen thousand rupees, '
                'whichever is more. These offences are non-bailable and '
                'cannot be compounded by a settlement.'),
        ToolQuestion(hi ? 'माँग कब की जा रही है' : 'When is the demand being made'),
        pick(DowryWhen.beforeMarriage, 'While the marriage is being arranged',
            'शादी की बात चलते समय'),
        pick(DowryWhen.atMarriage, 'At the time of the marriage',
            'शादी के समय'),
        pick(DowryWhen.afterMarriage, 'After the marriage, for more',
            'शादी के बाद, और माँगा जा रहा है'),
        pick(DowryWhen.harassmentNow,
            'She is being harassed or beaten over it',
            'इसी वजह से उसे परेशान या मारा जा रहा है'),
        if (_when != null) ...[
          if (_when == DowryWhen.harassmentNow)
            ToolAnswer(
              headline: hi
                  ? 'यह अलग और बड़ा अपराध है — अभी कार्रवाई हो सकती है'
                  : 'This is a separate and graver offence - act now',
              detail: hi
                  ? 'दहेज के लिए पत्नी को क्रूरता से परेशान करना अलग अपराध है, और '
                      'इसमें पुलिस सीधे मामला दर्ज करती है। साथ ही घरेलू हिंसा क़ानून '
                      'के तहत संरक्षण आदेश भी लिया जा सकता है, और वह जल्दी मिलता है — '
                      'इसी लक्ष्य में "घरेलू हिंसा: संरक्षण आदेश" देखें। अभी ख़तरा हो तो '
                      '112, महिला हेल्पलाइन 181।'
                  : 'Cruelty to a wife over dowry is a distinct offence, and '
                      'the police register it directly. Alongside it a '
                      'protection order can be taken under the domestic '
                      'violence law, and that comes faster - see "Domestic '
                      'violence: a protection order" in this goal. If there is '
                      'danger now, 112, or the women\'s helpline 181.',
              tone: ToolTone.bad,
              icon: Icons.priority_high,
            )
          else
            ToolAnswer(
              headline: hi
                  ? 'माँग ही अपराध है — देने का इंतज़ार नहीं'
                  : 'The demand is the offence - nothing need be given first',
              detail: _when == DowryWhen.beforeMarriage
                  ? (hi
                      ? 'शादी तय होने से पहले की माँग भी इसी क़ानून में आती है। इस '
                          'मोड़ पर एक बात जानने लायक़ है: माँग का लिखित या रिकॉर्ड किया '
                          'हुआ कोई सबूत — संदेश, सूची, किसी बिचौलिये के ज़रिये भेजी गई '
                          'बात — बाद में सबसे काम आता है। और शादी से इनकार करना भी '
                          'एक पूरा जवाब है।'
                      : 'A demand made while the marriage is still being '
                          'arranged comes under the same law. One thing worth '
                          'knowing at this stage: any written or recorded '
                          'trace of the demand - a message, a list, something '
                          'sent through a go-between - is what helps most '
                          'later. And refusing the marriage is itself a '
                          'complete answer.')
                  : (hi
                      ? 'शादी के समय या उसके बाद की माँग, दोनों अपराध हैं। एक ख़ास बात '
                          'इस क़ानून में है: अदालत में यह साबित करने का भार उस व्यक्ति पर '
                          'होता है जिस पर आरोप है, कि उसने अपराध नहीं किया — शिकायत '
                          'करने वाले पर नहीं।'
                      : 'A demand at the marriage and a demand after it are '
                          'both offences. One feature of this law matters: in '
                          'court the burden of proving that the offence was '
                          'not committed lies on the accused, not on the '
                          'complainant.'),
              tone: ToolTone.warn,
              icon: Icons.gavel_outlined,
            ),
          const SizedBox(height: 14),
          Text(hi ? 'शिकायत कहाँ' : 'Where the complaint goes',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'हर राज्य में दहेज प्रतिषेध अधिकारी नियुक्त होते हैं — ज़िला महिला '
                        'एवं बाल विकास कार्यालय से पता मिलता है।',
                    'पुलिस थाने में शिकायत। महिला थाना हो तो वहाँ, वरना किसी भी थाने '
                        'में — मना करने पर पुलिस अधीक्षक को लिखित शिकायत भेजें।',
                    'राज्य महिला आयोग और राष्ट्रीय महिला आयोग, दोनों के पास सीधे '
                        'शिकायत जा सकती है, और वे पुलिस से जवाब मँगाते हैं।',
                    'वन स्टॉप सेंटर (सखी) और महिला हेल्पलाइन 181 — वहाँ से आगे का '
                        'रास्ता और वकील, दोनों मिलते हैं।',
                    'वकील मुफ़्त: ज़िला विधिक सेवा प्राधिकरण, 15100।',
                  ]
                : const [
                    'Every state appoints Dowry Prohibition Officers - the '
                        'district women and child development office has the '
                        'address.',
                    'A complaint at the police station. At a women\'s police '
                        'station if there is one, otherwise any station - if '
                        'it is refused, send a written complaint to the '
                        'superintendent of police.',
                    'The State and National Commissions for Women both take '
                        'complaints directly, and they call for a police '
                        'response.',
                    'A One Stop Centre (Sakhi) and the women\'s helpline 181 - '
                        'both the next step and a lawyer come from there.',
                    'A free lawyer: District Legal Services Authority, 15100.',
                  ],
          ),
          ToolNote(hi
              ? 'एक बात साफ़ रहे: जो चीज़ें शादी में लड़की को दी गईं, वे उसकी अपनी '
                  'संपत्ति (स्त्रीधन) हैं — गहने, पैसा, सामान। ससुराल उन्हें रोक नहीं '
                  'सकता, और वापसी के लिए अलग से दावा किया जा सकता है, चाहे शादी चल '
                  'रही हो।'
              : 'One thing to be clear about: whatever was given to the woman '
                  'at the marriage is her own property - jewellery, money, '
                  'goods. Her in-laws cannot withhold it, and it can be '
                  'claimed back separately, whether or not the marriage '
                  'continues.'),
          const SourceNote(
              text: 'Dowry Prohibition Act, 1961 - full text',
              url: _dowryActUrl),
        ],
      ],
    );
  }
}

// --- Marriage under 18 ------------------------------------------------

/// Who is asking, which changes what they can actually do.
enum ChildMarriageAsker { theGirl, family, neighbour, alreadyMarried }

class ChildMarriagePage extends StatefulWidget {
  const ChildMarriagePage({super.key});

  @override
  State<ChildMarriagePage> createState() => _ChildMarriagePageState();
}

class _ChildMarriagePageState extends State<ChildMarriagePage> {
  ChildMarriageAsker? _who;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;

    Widget pick(ChildMarriageAsker w, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _who == w,
          onTap: () => setState(() => _who = w),
        );

    return ToolScaffold(
      goal: 5,
      title: hi ? '18 से पहले शादी' : 'A marriage under 18',
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: scheme.error,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.campaign_outlined, color: scheme.onError, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hi
                      ? 'चाइल्डलाइन 1098 — चौबीसों घंटे, और नाम बताए बिना भी। '
                          'आपातकाल में 112। महिला हेल्पलाइन 181।'
                      : 'Childline 1098 - any hour, and without giving your '
                          'name. In an emergency 112. Women\'s helpline 181.',
                  style: TextStyle(
                      fontSize: 14.5,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                      color: scheme.onError),
                ),
              ),
            ],
          ),
        ),
        ToolNote(hi
            ? 'भारत में शादी की कम से कम उम्र लड़की के लिए 18 और लड़के के लिए 21 '
                'साल है। 2021 में लड़कियों की उम्र 21 करने का विधेयक आया था, लेकिन वह '
                'पारित नहीं हुआ — इसलिए आज भी 18 ही है। इससे कम उम्र में शादी कराना, '
                'कराने में मदद करना, या माता-पिता के नाते होने देना — तीनों दंडनीय '
                'हैं, और सज़ा दो साल तक की कठोर क़ैद और एक लाख रुपये तक जुर्माना है।'
            : 'The minimum age of marriage in India is 18 for a girl and 21 '
                'for a boy. A Bill to raise the girl\'s age to 21 was '
                'introduced in 2021 but was not passed - so it remains 18. '
                'Marrying a child, performing or abetting such a marriage, '
                'and a parent permitting one are all punishable, with up to '
                'two years\' rigorous imprisonment and a fine of up to one '
                'lakh rupees.'),
        ToolQuestion(hi ? 'आप कौन हैं' : 'Who is asking'),
        pick(ChildMarriageAsker.theGirl, 'It is my own marriage being arranged',
            'मेरी ही शादी की बात चल रही है'),
        pick(ChildMarriageAsker.family,
            'Someone in my family is being married off',
            'मेरे परिवार में किसी की शादी कराई जा रही है'),
        pick(ChildMarriageAsker.neighbour,
            'I know of one happening nearby',
            'मुझे पास में हो रही एक शादी के बारे में पता है'),
        pick(ChildMarriageAsker.alreadyMarried,
            'The marriage has already happened',
            'शादी हो चुकी है'),
        if (_who != null) ...[
          ToolAnswer(
            headline: _who == ChildMarriageAsker.alreadyMarried
                ? (hi
                    ? 'हो चुकी शादी भी रद्द कराई जा सकती है'
                    : 'A marriage already performed can still be annulled')
                : (hi
                    ? 'शादी रोकने के लिए अदालत से आदेश मिल सकता है'
                    : 'A court can order the marriage stopped'),
            detail: _who == ChildMarriageAsker.alreadyMarried
                ? (hi
                    ? 'बाल विवाह रद्द कराया जा सकता है। अर्ज़ी वह व्यक्ति देता है जिसकी '
                        'शादी कम उम्र में हुई थी, और बालिग़ होने के दो साल के भीतर — '
                        'यानी लड़की के लिए 20 साल की उम्र तक। इस दौरान भरण-पोषण और '
                        'रहने की जगह का आदेश भी माँगा जा सकता है, और वह मिलता है। '
                        'वकील मुफ़्त — 15100।'
                    : 'A child marriage can be annulled. The petition is '
                        'filed by the person who was married as a child, '
                        'within two years of attaining majority - that is, by '
                        'the age of 20 for a girl. Maintenance and a place to '
                        'live can be asked for in the same proceeding, and are '
                        'granted. The lawyer is free - 15100.')
                : (hi
                    ? 'अदालत बाल विवाह को रोकने के लिए निषेधाज्ञा (injunction) जारी '
                        'कर सकती है, और यह जल्दी मिल सकती है। हर ज़िले में बाल विवाह '
                        'निषेध अधिकारी होता है — आमतौर पर ज़िला बाल संरक्षण इकाई में — '
                        'और उसका काम यही है। बाल कल्याण समिति और ज़िलाधिकारी, दोनों '
                        'के पास भी बात जा सकती है।'
                    : 'A court can issue an injunction to stop a child '
                        'marriage, and it can come quickly. Every district has '
                        'a Child Marriage Prohibition Officer - usually in the '
                        'District Child Protection Unit - and this is their '
                        'job. It can also go to the Child Welfare Committee '
                        'and to the district officer.'),
            tone: ToolTone.plain,
            icon: Icons.gavel_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'अब क्या करें' : 'What to do now',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: switch (_who!) {
              ChildMarriageAsker.theGirl => hi
                  ? const [
                      '1098 पर फ़ोन करें। नाम बताना ज़रूरी नहीं, और बात गोपनीय रहती '
                          'है।',
                      'स्कूल में हैं तो किसी एक शिक्षक या प्रधानाध्यापक को बताएँ — वे '
                          'बाल कल्याण समिति तक बात पहुँचा सकते हैं, और स्कूल से आई बात '
                          'पर तेज़ी से कार्रवाई होती है।',
                      'आँगनवाड़ी कार्यकर्ता, आशा या ग्राम पंचायत सचिव — इनमें से किसी '
                          'एक को बताएँ। गाँव में ये लोग इसी व्यवस्था का हिस्सा हैं।',
                      'ज़िला बाल संरक्षण इकाई या बाल विवाह निषेध अधिकारी से सीधे संपर्क '
                          'करें।',
                      'आपकी पढ़ाई रुकने की ज़रूरत नहीं है: खुला विद्यालय और छात्रावास, '
                          'दोनों के रास्ते हैं। लक्ष्य 4 में "पढ़ाई छूट गई" और "मुफ़्त '
                          'हॉस्टल" देखें।',
                    ]
                  : const [
                      'Call 1098. You do not have to give your name, and what '
                          'you say is kept confidential.',
                      'If you are in school, tell one teacher or the head '
                          'teacher - they can take it to the Child Welfare '
                          'Committee, and something coming from a school moves '
                          'fast.',
                      'Tell the anganwadi worker, the ASHA or the panchayat '
                          'secretary. In a village these people are part of '
                          'this very system.',
                      'Contact the District Child Protection Unit or the '
                          'Child Marriage Prohibition Officer directly.',
                      'Your education does not have to stop: open schooling '
                          'and hostels are both routes. See "Dropped out" and '
                          '"Free hostel" under goal 4.',
                    ],
              ChildMarriageAsker.family || ChildMarriageAsker.neighbour => hi
                  ? const [
                      '1098 पर सूचना दें — नाम बताए बिना भी दी जा सकती है, और यही '
                          'सबसे तेज़ रास्ता है।',
                      'बाल विवाह निषेध अधिकारी या ज़िला बाल संरक्षण इकाई को बताएँ। '
                          'तारीख़, जगह और लड़की की उम्र — ये तीन बातें बता दें, बाक़ी वे '
                          'देख लेते हैं।',
                      'शादी की तारीख़ पास हो तो सीधे ज़िलाधिकारी या उपखंड अधिकारी के '
                          'कार्यालय में सूचना दें — वे तुरंत रोक लगवा सकते हैं।',
                      'लड़की को अकेले समझाने या घर वालों से भिड़ने की कोशिश न करें; '
                          'इससे शादी जल्दी और छिपाकर करा दी जाती है। व्यवस्था को बताना '
                          'ज़्यादा असरदार है।',
                    ]
                  : const [
                      'Report it on 1098 - it can be done without giving your '
                          'name, and it is the fastest route.',
                      'Tell the Child Marriage Prohibition Officer or the '
                          'District Child Protection Unit. The date, the place '
                          'and the girl\'s age - give those three and they '
                          'handle the rest.',
                      'If the wedding date is close, report it straight to '
                          'the district officer\'s or sub-divisional '
                          'officer\'s office - they can have it stopped at '
                          'once.',
                      'Do not try to persuade the girl alone or confront the '
                          'family; that tends to make the marriage happen '
                          'sooner and in secret. Telling the system works '
                          'better.',
                    ],
              ChildMarriageAsker.alreadyMarried => hi
                  ? const [
                      'ज़िला विधिक सेवा प्राधिकरण (15100) से मुफ़्त वकील लें — रद्द '
                          'कराने की अर्ज़ी वही लिखते हैं।',
                      'उम्र का सबूत जुटाएँ: जन्म प्रमाण पत्र, स्कूल का रिकॉर्ड, या '
                          'आँगनवाड़ी का रजिस्टर। स्कूल का रिकॉर्ड सबसे आसानी से मिलता '
                          'है।',
                      'अर्ज़ी में भरण-पोषण और रहने की जगह भी माँगें — यह अलग से नहीं '
                          'माँगनी पड़ती, उसी में आ जाती है।',
                      'बालिग़ होने के दो साल के भीतर अर्ज़ी देनी होती है, इसलिए देर न '
                          'करें।',
                      'इस बीच सुरक्षा चाहिए तो वन स्टॉप सेंटर (सखी) और 181 — वहाँ '
                          'ठहरने की जगह भी मिलती है।',
                    ]
                  : const [
                      'Get a free lawyer from the District Legal Services '
                          'Authority (15100) - they write the annulment '
                          'petition.',
                      'Gather proof of age: a birth certificate, a school '
                          'record, or the anganwadi register. The school '
                          'record is the easiest to get.',
                      'Ask for maintenance and a place to live in the same '
                          'petition - it does not have to be asked for '
                          'separately.',
                      'The petition must be filed within two years of '
                          'attaining majority, so do not delay.',
                      'If protection is needed meanwhile, the One Stop Centre '
                          '(Sakhi) and 181 - they provide shelter too.',
                    ],
            },
          ),
          const SourceNote(
              text: 'Prohibition of Child Marriage Act, 2006', url: _pcmaUrl),
        ],
      ],
    );
  }
}

// --- Daughter's share in property -------------------------------------

/// Which kind of property, and under which personal law. Both change the
/// answer completely, and conflating them is how families are told
/// confidently wrong things.
enum PropertyKind { ancestral, selfAcquired, agricultural }

enum PersonalLaw { hindu, muslim, christianOrParsi, unsure }

class DaughterPropertyPage extends StatefulWidget {
  const DaughterPropertyPage({super.key});

  @override
  State<DaughterPropertyPage> createState() => _DaughterPropertyPageState();
}

class _DaughterPropertyPageState extends State<DaughterPropertyPage> {
  PropertyKind? _kind;
  PersonalLaw? _law;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    Widget kind(PropertyKind k, String en, String h, String sub, String subHi) =>
        SelectionTile(
          label: hi ? h : en,
          subtitle: hi ? subHi : sub,
          selected: _kind == k,
          onTap: () => setState(() => _kind = k),
        );

    Widget law(PersonalLaw l, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _law == l,
          onTap: () => setState(() => _law = l),
        );

    return ToolScaffold(
      goal: 5,
      title: hi ? 'बेटी का संपत्ति में हिस्सा' : 'A daughter\'s share in property',
      children: [
        ToolNote(hi
            ? 'इस विषय पर घर में जो कहा जाता है, वह आमतौर पर पुराना क़ानून है। दो '
                'बातें तय करती हैं कि हिस्सा क्या बनता है: संपत्ति पुश्तैनी है या ख़ुद '
                'कमाई हुई, और परिवार किस व्यक्तिगत क़ानून के अंतर्गत आता है। इन्हें '
                'मिला देना ही ग़लत जवाबों की जड़ है।'
            : 'What gets said at home on this subject is usually the older '
                'law. Two things decide what the share is: whether the '
                'property is ancestral or self-acquired, and which personal '
                'law the family comes under. Conflating those is the root of '
                'the confident wrong answers.'),
        ToolQuestion(hi ? 'संपत्ति कैसी है' : 'What kind of property'),
        kind(PropertyKind.ancestral, 'Ancestral - came down the family',
            'पुश्तैनी — पीढ़ियों से आई',
            'Inherited from father, grandfather or great-grandfather',
            'पिता, दादा या परदादा से मिली'),
        kind(PropertyKind.selfAcquired, 'Self-acquired - he bought or built it',
            'ख़ुद कमाई — उन्होंने ख़रीदी या बनाई',
            'Bought with his own earnings', 'अपनी कमाई से ख़रीदी'),
        kind(PropertyKind.agricultural, 'Agricultural land',
            'खेती की ज़मीन', 'Farmland', 'खेत'),
        ToolQuestion(hi ? 'परिवार किस क़ानून के अंतर्गत' : 'Which personal law'),
        law(PersonalLaw.hindu, 'Hindu, Sikh, Jain or Buddhist',
            'हिंदू, सिख, जैन या बौद्ध'),
        law(PersonalLaw.muslim, 'Muslim', 'मुसलमान'),
        law(PersonalLaw.christianOrParsi, 'Christian or Parsi',
            'ईसाई या पारसी'),
        law(PersonalLaw.unsure, 'Not sure', 'पता नहीं'),
        if (_kind != null && _law != null) ...[
          if (_law == PersonalLaw.hindu && _kind == PropertyKind.ancestral)
            ToolAnswer(
              headline: hi
                  ? 'बेटी का हिस्सा बेटे के बराबर है'
                  : 'A daughter\'s share equals a son\'s',
              detail: hi
                  ? 'हिंदू उत्तराधिकार अधिनियम में 2005 के संशोधन के बाद बेटी जन्म से '
                      'सहदायिक (coparcener) है — यानी पुश्तैनी संपत्ति में उसका हिस्सा '
                      'बेटे के बराबर है। 2020 में सर्वोच्च न्यायालय ने यह भी साफ़ कर '
                      'दिया कि यह अधिकार इस पर निर्भर नहीं है कि 9 सितंबर 2005 को '
                      'पिता जीवित थे या नहीं। शादी से भी कोई फ़र्क़ नहीं पड़ता — शादी के '
                      'बाद भी बेटी सहदायिक रहती है।'
                  : 'After the 2005 amendment to the Hindu Succession Act a '
                      'daughter is a coparcener by birth - her share in '
                      'ancestral property is equal to a son\'s. In 2020 the '
                      'Supreme Court also settled that this right does not '
                      'depend on whether the father was alive on 9 September '
                      '2005. Marriage makes no difference either - a daughter '
                      'remains a coparcener after she marries.',
              tone: ToolTone.good,
              icon: Icons.balance_outlined,
            )
          else if (_law == PersonalLaw.hindu &&
              _kind == PropertyKind.selfAcquired)
            ToolAnswer(
              headline: hi
                  ? 'वसीयत हो तो वसीयत चलेगी'
                  : 'If there is a will, the will decides',
              detail: hi
                  ? 'ख़ुद कमाई हुई संपत्ति पर मालिक को वसीयत से जिसे चाहे देने का '
                      'अधिकार है — बेटी को, बेटे को, या किसी और को। लेकिन अगर वसीयत '
                      'नहीं है, तो संपत्ति उत्तराधिकार के नियम से बँटती है, और उसमें '
                      'बेटी, बेटा, विधवा और माँ — सब प्रथम श्रेणी के उत्तराधिकारी हैं, '
                      'बराबर हिस्से पर। वसीयत न होने पर बेटी को छोड़ा नहीं जा सकता।'
                  : 'The owner of self-acquired property may leave it by will '
                      'to whomever he chooses - a daughter, a son, or someone '
                      'else. But where there is no will, the property devolves '
                      'by the rules of succession, under which a daughter, a '
                      'son, the widow and the mother are all Class I heirs, '
                      'in equal shares. With no will, a daughter cannot be '
                      'left out.',
              tone: ToolTone.plain,
              icon: Icons.description_outlined,
            )
          else if (_law == PersonalLaw.hindu &&
              _kind == PropertyKind.agricultural)
            ToolAnswer(
              headline: hi
                  ? 'मुख्य नियम वही, लेकिन राज्य का भू-क़ानून देखना होगा'
                  : 'Same rule in principle, but check the state land law',
              detail: hi
                  ? 'खेती की ज़मीन पर भी हिंदू उत्तराधिकार अधिनियम लागू होता है और '
                      'बेटी का हिस्सा बराबर है। पेच यह है कि कुछ राज्यों के अपने '
                      'भू-राजस्व और काश्तकारी क़ानून हैं जो उत्तराधिकार और ज़मीन के '
                      'बँटवारे पर असर डालते हैं, और वे राज्य-राज्य में अलग हैं। इसलिए '
                      'यहाँ एक ही जवाब देना ग़लत होगा — तहसील में या मुफ़्त वकील से '
                      'अपने राज्य का नियम पूछें।'
                  : 'The Hindu Succession Act applies to agricultural land too '
                      'and a daughter\'s share is equal. The complication is '
                      'that some states have their own land revenue and '
                      'tenancy laws that bear on succession and the division '
                      'of holdings, and they differ from state to state. So a '
                      'single answer here would be wrong - ask at the tehsil, '
                      'or a free lawyer, what your state\'s rule is.',
              tone: ToolTone.warn,
              icon: Icons.agriculture_outlined,
            )
          else if (_law == PersonalLaw.muslim)
            ToolAnswer(
              headline: hi
                  ? 'मुस्लिम व्यक्तिगत क़ानून अलग है'
                  : 'Muslim personal law is different',
              detail: hi
                  ? 'मुस्लिम उत्तराधिकार हिंदू उत्तराधिकार अधिनियम से नहीं, मुस्लिम '
                      'व्यक्तिगत क़ानून से चलता है, और उसमें बेटी का हिस्सा होता है — '
                      'आमतौर पर बेटे के हिस्से का आधा — साथ ही विधवा, माता-पिता और अन्य '
                      'रिश्तेदारों के तय हिस्से भी होते हैं। हिस्सा इस पर निर्भर करता है '
                      'कि कौन-कौन उत्तराधिकारी जीवित हैं, इसलिए संख्या हर परिवार में अलग '
                      'बनती है। अपने मामले का ठीक हिसाब मुफ़्त वकील से कराएँ — 15100। '
                      'यह ज़रूर जान लें: बेटी का हिस्सा होता है, और उसे छोड़ना क़ानूनन '
                      'ग़लत है।'
                  : 'Muslim succession runs not under the Hindu Succession Act '
                      'but under Muslim personal law, in which a daughter does '
                      'have a share - generally half of a son\'s - alongside '
                      'fixed shares for the widow, the parents and other '
                      'relatives. The share depends on which heirs survive, so '
                      'the figure differs from family to family. Get your own '
                      'case worked out by a free lawyer - 15100. What to be '
                      'clear about: a daughter does have a share, and leaving '
                      'her out is not lawful.',
              tone: ToolTone.plain,
              icon: Icons.menu_book_outlined,
            )
          else if (_law == PersonalLaw.christianOrParsi)
            ToolAnswer(
              headline: hi
                  ? 'भारतीय उत्तराधिकार अधिनियम लागू होता है'
                  : 'The Indian Succession Act applies',
              detail: hi
                  ? 'ईसाई और पारसी परिवारों में उत्तराधिकार भारतीय उत्तराधिकार '
                      'अधिनियम, 1925 से तय होता है। इसमें बेटे और बेटी में कोई भेद नहीं '
                      'है — दोनों का हिस्सा बराबर होता है। विधवा और बच्चों के हिस्सों के '
                      'अलग नियम हैं। अपने मामले के लिए मुफ़्त वकील से हिसाब करा लें — '
                      '15100।'
                  : 'In Christian and Parsi families succession is governed by '
                      'the Indian Succession Act, 1925. It makes no '
                      'distinction between a son and a daughter - their shares '
                      'are equal. There are separate rules for the widow\'s '
                      'and the children\'s shares. Have your own case worked '
                      'out by a free lawyer - 15100.',
              tone: ToolTone.plain,
              icon: Icons.menu_book_outlined,
            )
          else
            ToolAnswer(
              headline: hi
                  ? 'पहले यह तय करना होगा'
                  : 'This has to be settled first',
              detail: hi
                  ? 'उत्तराधिकार का क़ानून परिवार के व्यक्तिगत क़ानून से तय होता है, '
                      'इसलिए जवाब उसी पर निर्भर है। ज़िला विधिक सेवा प्राधिकरण (15100) '
                      'पर मुफ़्त सलाह मिलती है और वे यह भी बता देते हैं कि आपका मामला '
                      'किस क़ानून में आता है।'
                  : 'The law of succession follows the family\'s personal law, '
                      'so the answer depends on it. The District Legal '
                      'Services Authority (15100) advises free and will also '
                      'tell you which law your case falls under.',
              tone: ToolTone.warn,
              icon: Icons.help_outline,
            ),
          const SizedBox(height: 14),
          Text(hi ? 'हिस्सा न दिया जाए तो' : 'If the share is denied',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'तहसील से ज़मीन का रिकॉर्ड निकलवाएँ — खतौनी या रिकॉर्ड ऑफ़ राइट्स। '
                        'किसके नाम क्या दर्ज है, यह पहली और सबसे ज़रूरी जानकारी है, और '
                        'यह कोई भी निकलवा सकता है।',
                    'परिवार में बात बन सकती हो तो पारिवारिक बँटवारा (family '
                        'settlement) सबसे तेज़ और सस्ता रास्ता है — लेकिन वह लिखित और '
                        'रजिस्टर्ड हो, मुँहज़बानी नहीं।',
                    'दाख़िल-ख़ारिज (म्यूटेशन) में अपना नाम दर्ज कराने की अर्ज़ी तहसील में '
                        'दें। मना हो तो कारण लिखित में माँगें।',
                    'बात न बने तो दीवानी अदालत में बँटवारे का वाद (partition suit) '
                        'दायर होता है। वकील मुफ़्त मिलता है — 15100।',
                    'एक बात ज़रूरी: अगर कोई काग़ज़ पर हस्ताक्षर या अँगूठा लगवाकर हिस्सा '
                        'छुड़वाना चाहे, तो पढ़े बिना कुछ न लगाएँ और पहले मुफ़्त वकील से '
                        'पूछ लें।',
                  ]
                : const [
                    'Get the land record from the tehsil - the khatauni or '
                        'record of rights. What is recorded against whose name '
                        'is the first and most important piece of information, '
                        'and anyone can obtain it.',
                    'If the family can agree, a written and registered family '
                        'settlement is the quickest and cheapest route - '
                        'written and registered, not spoken.',
                    'Apply at the tehsil to have your name entered in the '
                        'mutation. If refused, ask for the reason in writing.',
                    'Where agreement fails, a partition suit is filed in the '
                        'civil court. The lawyer is free - 15100.',
                    'One thing matters: if anyone wants a signature or a '
                        'thumbprint on a paper giving up the share, sign '
                        'nothing unread and ask a free lawyer first.',
                  ],
          ),
          const SourceNote(
              text: 'Free legal services - National Legal Services Authority',
              url: _nalsaUrl),
        ],
      ],
    );
  }
}
