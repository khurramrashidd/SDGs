import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Four screens about getting a small business on the record.
///
/// Registration is the step small enterprises skip, usually because it is
/// assumed to mean tax, inspection and trouble. In fact the three
/// registrations here cost nothing or almost nothing, and each one unlocks
/// something specific: Udyam unlocks the delayed-payment law and priority
/// lending, FSSAI makes a food business lawful to run, and a vending
/// certificate is what stops a cart being confiscated.

const _udyamUrl = 'https://udyamregistration.gov.in/';
const _msmeNotifUrl = 'https://msme.gov.in/';
const _gstUrl = 'https://www.gst.gov.in/';
const _fssaiUrl = 'https://foscos.fssai.gov.in/';
const _svanidhiUrl = 'https://pmsvanidhi.mohua.gov.in/';

/// MSME classification, revised with effect from 1 April 2025. An
/// enterprise must be within both the investment and the turnover limit
/// for its class. Values in rupees.
const microInvestment = 25000000; // ₹2.5 crore
const microTurnover = 100000000; // ₹10 crore
const smallInvestment = 250000000; // ₹25 crore
const smallTurnover = 1000000000; // ₹100 crore
const mediumInvestment = 1250000000; // ₹125 crore
const mediumTurnover = 5000000000; // ₹500 crore

enum MsmeClass { micro, small, medium, beyond }

/// The class an enterprise falls in. Both tests must pass, and the class
/// is the higher of the two - exceeding either limit moves you up.
MsmeClass msmeClass(double investment, double turnover) {
  if (investment <= microInvestment && turnover <= microTurnover) {
    return MsmeClass.micro;
  }
  if (investment <= smallInvestment && turnover <= smallTurnover) {
    return MsmeClass.small;
  }
  if (investment <= mediumInvestment && turnover <= mediumTurnover) {
    return MsmeClass.medium;
  }
  return MsmeClass.beyond;
}

String _crore(double rupees, bool hi) {
  final cr = rupees / 10000000;
  final n = cr == cr.roundToDouble() ? cr.round().toString()
      : cr.toStringAsFixed(1);
  return hi ? '₹$n करोड़' : '₹$n crore';
}

class MsmeClassPage extends StatefulWidget {
  const MsmeClassPage({super.key});

  @override
  State<MsmeClassPage> createState() => _MsmeClassPageState();
}

class _MsmeClassPageState extends State<MsmeClassPage> {
  final _investment = TextEditingController();
  final _turnover = TextEditingController();

  @override
  void dispose() {
    _investment.dispose();
    _turnover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final inv = double.tryParse(_investment.text.trim());
    final turn = double.tryParse(_turnover.text.trim());
    final cls = (inv != null && turn != null) ? msmeClass(inv, turn) : null;

    return ToolScaffold(
      goal: 9,
      title: hi ? 'सूक्ष्म, लघु या मध्यम — कौन सा' : 'Am I micro, small or medium',
      children: [
        ToolNote(hi
            ? 'उद्यम पंजीकरण मुफ़्त है, ऑनलाइन है, और आधार से कुछ मिनट में हो जाता '
                'है। श्रेणी इससे तय होती है कि मशीन-संयंत्र में कितना लगा है और सालाना '
                'कारोबार कितना है — दोनों शर्तें पूरी होनी चाहिए। सीमाएँ 1 अप्रैल 2025 '
                'से बढ़ाई गई हैं, इसलिए जो उद्यम पहले "छोटे" से बाहर हो गए थे, वे अब '
                'फिर अंदर आ सकते हैं।'
            : 'Udyam registration is free, online and takes a few minutes '
                'with Aadhaar. The class is set by what is invested in plant '
                'and machinery and by the annual turnover - both tests have '
                'to pass. The limits were raised with effect from 1 April '
                '2025, so an enterprise that had grown out of a class may be '
                'back inside it now.'),
        ToolQuestion(hi ? 'दो संख्याएँ' : 'The two numbers'),
        ToolNumber(
          controller: _investment,
          label: hi
              ? 'मशीन और संयंत्र में निवेश (₹)'
              : 'Investment in plant and machinery (₹)',
          decimal: true,
          maxDigits: 12,
          icon: Icons.precision_manufacturing_outlined,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolNumber(
          controller: _turnover,
          label: hi ? 'सालाना कारोबार (₹)' : 'Annual turnover (₹)',
          decimal: true,
          maxDigits: 12,
          icon: Icons.trending_up,
          onChanged: (_) => setState(() {}),
        ),
        if (cls != null) ...[
          ToolAnswer(
            headline: switch (cls) {
              MsmeClass.micro => hi ? 'सूक्ष्म उद्यम (माइक्रो)' : 'A micro enterprise',
              MsmeClass.small => hi ? 'लघु उद्यम (स्मॉल)' : 'A small enterprise',
              MsmeClass.medium => hi ? 'मध्यम उद्यम (मीडियम)' : 'A medium enterprise',
              MsmeClass.beyond =>
                hi ? 'एमएसएमई की सीमा से बाहर' : 'Beyond the MSME limits',
            },
            detail: switch (cls) {
              MsmeClass.micro => hi
                  ? 'सूक्ष्म और लघु उद्यमों को सबसे ज़्यादा मिलता है: 45 दिन में '
                      'भुगतान का क़ानूनी हक़, बिना ज़मानत ऋण की गारंटी, सरकारी ख़रीद '
                      'में आरक्षित हिस्सा, और प्राथमिकता क्षेत्र ऋण। पंजीकरण के बिना '
                      'इनमें से कुछ नहीं मिलता।'
                  : 'Micro and small enterprises get the most: a legal right '
                      'to payment in 45 days, a credit guarantee for '
                      'collateral-free loans, a reserved share in government '
                      'procurement, and priority sector lending. None of it '
                      'is available without registration.',
              MsmeClass.small => hi
                  ? 'लघु उद्यम को भी वही हक़ मिलते हैं जो सूक्ष्म को — 45 दिन में '
                      'भुगतान, ऋण गारंटी, और सरकारी ख़रीद में हिस्सा। उद्यम प्रमाण '
                      'पत्र पर जो श्रेणी लिखी है, बैंक उसी को मानता है।'
                  : 'A small enterprise gets the same rights as a micro '
                      'one - payment in 45 days, the credit guarantee, and a '
                      'share of government procurement. Whatever class the '
                      'Udyam certificate states is what a bank goes by.',
              MsmeClass.medium => hi
                  ? 'मध्यम उद्यम को एमएसएमई की कई सुविधाएँ मिलती हैं, लेकिन 45 दिन '
                      'में भुगतान का क़ानूनी हक़ और सरकारी ख़रीद का आरक्षित हिस्सा — ये '
                      'दोनों सिर्फ़ सूक्ष्म और लघु के लिए हैं। यह फ़र्क़ जानना ज़रूरी है।'
                  : 'A medium enterprise gets many MSME facilities, but the '
                      'legal right to payment in 45 days and the reserved '
                      'share in government procurement are for micro and '
                      'small enterprises only. That distinction is worth '
                      'knowing.',
              MsmeClass.beyond => hi
                  ? 'दोनों में से कोई एक सीमा पार होने पर उद्यम एमएसएमई से बाहर हो '
                      'जाता है। फिर भी उद्यम रिकॉर्ड अपडेट रखें — सीमाएँ बदलती हैं।'
                  : 'Crossing either limit takes an enterprise outside the '
                      'MSME definition. Keep the Udyam record updated even '
                      'so - the limits do change.',
            },
            tone: cls == MsmeClass.beyond ? ToolTone.plain : ToolTone.good,
            icon: Icons.business_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'सीमाएँ, 1 अप्रैल 2025 से' : 'The limits, from 1 April 2025',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ToolLine(
              hi ? 'सूक्ष्म' : 'Micro',
              '${_crore(microInvestment.toDouble(), hi)} / '
                  '${_crore(microTurnover.toDouble(), hi)}',
              strong: cls == MsmeClass.micro),
          ToolLine(
              hi ? 'लघु' : 'Small',
              '${_crore(smallInvestment.toDouble(), hi)} / '
                  '${_crore(smallTurnover.toDouble(), hi)}',
              strong: cls == MsmeClass.small),
          ToolLine(
              hi ? 'मध्यम' : 'Medium',
              '${_crore(mediumInvestment.toDouble(), hi)} / '
                  '${_crore(mediumTurnover.toDouble(), hi)}',
              strong: cls == MsmeClass.medium),
          const SizedBox(height: 8),
          ToolNote(hi
              ? 'हर पंक्ति में पहला अंक निवेश की सीमा है और दूसरा कारोबार की। दोनों '
                  'के भीतर रहना ज़रूरी है — एक भी पार हुई तो अगली श्रेणी लागू हो जाती '
                  'है। व्यापारी (रिटेल और होलसेल) भी उद्यम पर पंजीकरण कर सकते हैं, '
                  'लेकिन उन्हें सिर्फ़ प्राथमिकता क्षेत्र ऋण का लाभ मिलता है।'
              : 'In each line the first figure is the investment limit and '
                  'the second the turnover. You have to be inside both - '
                  'crossing either moves you up. Traders, retail and '
                  'wholesale, can register on Udyam too, but only for '
                  'priority sector lending.'),
          ToolNote(hi
              ? 'पंजीकरण के पैसे कोई नहीं ले सकता। उद्यम पोर्टल पर यह मुफ़्त है, और '
                  'इसके लिए आधार तथा पैन काफ़ी हैं। "एजेंट" से बनवाने की ज़रूरत नहीं।'
              : 'Nobody may charge for registering. It is free on the Udyam '
                  'portal and needs only Aadhaar and PAN. There is no need '
                  'for an agent.'),
          const SourceNote(text: 'Udyam registration', url: _udyamUrl),
          const SourceNote(
              text: 'Ministry of MSME - classification notification',
              url: _msmeNotifUrl),
        ],
      ],
    );
  }
}

// --- GST --------------------------------------------------------------

/// Turnover thresholds for ordinary states. Special category states are
/// half these, which the screen says rather than guessing the state.
const gstGoodsThreshold = 4000000; // ₹40 lakh
const gstServicesThreshold = 2000000; // ₹20 lakh

class GstPage extends StatefulWidget {
  const GstPage({super.key});

  @override
  State<GstPage> createState() => _GstPageState();
}

class _GstPageState extends State<GstPage> {
  final _turnover = TextEditingController();
  bool _goods = true;
  bool _interState = false;
  bool _online = false;

  @override
  void dispose() {
    _turnover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final turnover = double.tryParse(_turnover.text.trim());
    final threshold = _goods ? gstGoodsThreshold : gstServicesThreshold;
    final overThreshold = turnover != null && turnover > threshold;
    final mustRegister = overThreshold || _interState || _online;

    return ToolScaffold(
      goal: 9,
      title: hi ? 'जीएसटी लेना ज़रूरी है?' : 'Do I need to register for GST',
      children: [
        ToolNote(hi
            ? 'जीएसटी का डर असल ज़रूरत से बड़ा होता है। ज़्यादातर छोटे धंधों को इसकी '
                'ज़रूरत ही नहीं पड़ती — लेकिन कुछ हालात में कारोबार कितना भी छोटा हो, '
                'पंजीकरण ज़रूरी हो जाता है। वे हालात नीचे पूछे गए हैं।'
            : 'The fear of GST is bigger than the requirement. Most small '
                'businesses do not need it at all - but in some situations '
                'registration becomes compulsory however small the turnover '
                'is. Those situations are the questions below.'),
        ToolQuestion(hi ? 'सामान या सेवा' : 'Goods or services'),
        SelectionTile(
          label: hi ? 'सामान बेचते हैं' : 'I sell goods',
          subtitle: hi
              ? 'दुकान, निर्माण, व्यापार'
              : 'A shop, manufacturing, trading',
          selected: _goods,
          onTap: () => setState(() => _goods = true),
        ),
        SelectionTile(
          label: hi ? 'सेवा देते हैं' : 'I provide services',
          subtitle: hi
              ? 'मरम्मत, सिलाई, ढुलाई, सलाह, ठेका'
              : 'Repairs, tailoring, transport, consulting, contracting',
          selected: !_goods,
          onTap: () => setState(() => _goods = false),
        ),
        ToolQuestion(hi ? 'सालाना कारोबार' : 'Annual turnover'),
        ToolNumber(
          controller: _turnover,
          label: hi ? 'रुपये' : 'Rupees',
          decimal: true,
          maxDigits: 12,
          icon: Icons.trending_up,
          onChanged: (_) => setState(() {}),
        ),
        ToolQuestion(hi ? 'इनमें से कुछ लागू होता है?' : 'Does any of this apply'),
        SwitchListTile(
          value: _interState,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'दूसरे राज्य में सामान बेचते हैं'
              : 'I sell goods to another state'),
          onChanged: (v) => setState(() => _interState = v),
        ),
        SwitchListTile(
          value: _online,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'ऑनलाइन बाज़ार से बेचते हैं'
              : 'I sell through an online marketplace'),
          subtitle: Text(
            hi ? 'या सरकारी पोर्टल GeM से' : 'Or on the government\'s GeM portal',
            style: const TextStyle(fontSize: 12),
          ),
          onChanged: (v) => setState(() => _online = v),
        ),
        if (turnover != null) ...[
          ToolAnswer(
            headline: mustRegister
                ? (hi ? 'पंजीकरण ज़रूरी है' : 'Registration is required')
                : (hi
                    ? 'अभी ज़रूरी नहीं लगता'
                    : 'It does not look required yet'),
            detail: mustRegister
                ? (hi
                    ? (overThreshold
                        ? 'कारोबार सीमा से ऊपर है, इसलिए पंजीकरण कराना होगा।'
                        : 'कारोबार सीमा से नीचे है, लेकिन दूसरे राज्य में बेचना या '
                            'ऑनलाइन बाज़ार से बेचना — इनमें से किसी एक पर भी पंजीकरण '
                            'ज़रूरी हो जाता है, कारोबार कितना भी हो।')
                    : (overThreshold
                        ? 'The turnover is above the threshold, so '
                            'registration is needed.'
                        : 'The turnover is below the threshold, but selling '
                            'into another state or through an online '
                            'marketplace makes registration compulsory '
                            'whatever the turnover.'))
                : (hi
                    ? 'सीमा ${_goods ? 'सामान' : 'सेवा'} के लिए '
                        '₹${(threshold / 100000).round()} लाख है, और आप उससे नीचे '
                        'हैं। पूर्वोत्तर तथा कुछ विशेष श्रेणी राज्यों में यह सीमा आधी '
                        'होती है — अपने राज्य की सीमा एक बार पक्की कर लें। बिना '
                        'पंजीकरण के कारोबार करना पूरी तरह वैध है।'
                    : 'The threshold for '
                        '${_goods ? 'goods' : 'services'} is '
                        '₹${(threshold / 100000).round()} lakh and you are '
                        'below it. In the north-eastern and some special '
                        'category states that threshold is halved - confirm '
                        'yours. Trading without registration is perfectly '
                        'lawful.'),
            tone: mustRegister ? ToolTone.warn : ToolTone.good,
            icon: Icons.receipt_long_outlined,
          ),
          const SizedBox(height: 14),
          if (mustRegister)
            ToolAnswer(
              headline: hi
                  ? 'छोटे कारोबार के लिए आसान रास्ता'
                  : 'The easier route for a small business',
              detail: hi
                  ? 'सामान्य जीएसटी में हर महीने विवरणी भरनी होती है और हिसाब रखना '
                      'पड़ता है। छोटे कारोबार के लिए "कंपोज़िशन" योजना है, जिसमें कर '
                      'की दर कम होती है, तिमाही भुगतान होता है और विवरणी साल में एक '
                      'बार — बहुत कम काग़ज़ी काम। बदले में आप ख़रीद पर लगे कर का '
                      'इनपुट क्रेडिट नहीं ले सकते और दूसरे राज्य में नहीं बेच सकते। '
                      'कर सलाहकार से यह ज़रूर पूछें कि आपके धंधे के लिए कौन सा ठीक है।'
                  : 'Ordinary GST means a monthly return and keeping '
                      'accounts. For a small business there is the '
                      'composition scheme: a lower rate of tax, quarterly '
                      'payment and one return a year - far less paperwork. In '
                      'exchange you cannot take input credit on your '
                      'purchases and cannot sell into another state. Ask a '
                      'tax adviser which suits your trade.',
              tone: ToolTone.plain,
              icon: Icons.lightbulb_outline,
            ),
          ToolNote(hi
              ? 'पंजीकरण gst.gov.in पर मुफ़्त है और इसके लिए पैन, आधार, बैंक खाते की '
                  'जानकारी तथा धंधे की जगह का सबूत चाहिए। एक बात ध्यान रखें: '
                  'पंजीकरण हो जाने के बाद विवरणी भरना ज़रूरी हो जाता है, चाहे बिक्री '
                  'शून्य हो — शून्य विवरणी भी भरनी होती है, वरना जुर्माना लगता है। '
                  'यही वह जगह है जहाँ बहुत छोटे धंधे ज़रूरत के बिना पंजीकरण कराकर '
                  'फँस जाते हैं।'
              : 'Registration is free at gst.gov.in and needs PAN, Aadhaar, '
                  'bank details and proof of the place of business. One thing '
                  'to keep in mind: once registered, filing returns becomes '
                  'compulsory even with no sales - a nil return still has to '
                  'be filed or a penalty follows. That is exactly where very '
                  'small businesses get caught after registering without '
                  'needing to.'),
          const SourceNote(text: 'GST portal', url: _gstUrl),
        ],
      ],
    );
  }
}

// --- FSSAI ------------------------------------------------------------

/// Which FSSAI licence a food business needs, by turnover.
const fssaiRegistrationLimit = 1200000; // ₹12 lakh
const fssaiStateLimit = 200000000; // ₹20 crore

enum FssaiKind { basicRegistration, stateLicence, centralLicence }

FssaiKind fssaiKind(double turnover) {
  if (turnover <= fssaiRegistrationLimit) return FssaiKind.basicRegistration;
  if (turnover <= fssaiStateLimit) return FssaiKind.stateLicence;
  return FssaiKind.centralLicence;
}

class FssaiPage extends StatefulWidget {
  const FssaiPage({super.key});

  @override
  State<FssaiPage> createState() => _FssaiPageState();
}

class _FssaiPageState extends State<FssaiPage> {
  final _turnover = TextEditingController();

  @override
  void dispose() {
    _turnover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final turnover = double.tryParse(_turnover.text.trim());
    final kind = turnover == null ? null : fssaiKind(turnover);

    return ToolScaffold(
      goal: 9,
      title: hi ? 'खाने के धंधे का लाइसेंस (FSSAI)' : 'Food business licence (FSSAI)',
      children: [
        ToolNote(hi
            ? 'खाने-पीने का कोई भी धंधा — ठेला, छोटा होटल, मिठाई की दुकान, '
                'अचार-पापड़ बनाना, दूध बेचना, टिफ़िन सेवा — बिना एफ़एसएसएआई के पंजीकरण '
                'के नहीं चलाया जा सकता। छोटे धंधे के लिए यह बहुत सस्ता और आसान है, और '
                'यह नंबर ग्राहक के भरोसे का काम भी करता है।'
            : 'Any food business - a cart, a small hotel, a sweet shop, '
                'making pickles or papads, selling milk, a tiffin service - '
                'cannot be run without an FSSAI registration. For a small '
                'business it is cheap and simple, and the number does work as '
                'a mark of trust with customers.'),
        ToolQuestion(hi ? 'सालाना कारोबार' : 'Annual turnover'),
        ToolNumber(
          controller: _turnover,
          label: hi ? 'रुपये' : 'Rupees',
          decimal: true,
          maxDigits: 12,
          icon: Icons.storefront_outlined,
          onChanged: (_) => setState(() {}),
        ),
        if (kind != null) ...[
          ToolAnswer(
            headline: switch (kind) {
              FssaiKind.basicRegistration =>
                hi ? 'बुनियादी पंजीकरण चाहिए' : 'Basic registration',
              FssaiKind.stateLicence =>
                hi ? 'राज्य का लाइसेंस चाहिए' : 'A state licence',
              FssaiKind.centralLicence =>
                hi ? 'केंद्र का लाइसेंस चाहिए' : 'A central licence',
            },
            detail: switch (kind) {
              FssaiKind.basicRegistration => hi
                  ? '₹12 लाख तक के कारोबार पर बुनियादी पंजीकरण काफ़ी है। यह सबसे '
                      'सस्ता है, ऑनलाइन हो जाता है, और ठेले से लेकर घर के छोटे धंधे '
                      'तक इसी में आते हैं। एक से पाँच साल के लिए लिया जा सकता है, और '
                      'ज़्यादा साल का एक साथ लेना सस्ता पड़ता है।'
                  : 'Up to ₹12 lakh of turnover, basic registration is '
                      'enough. It is the cheapest, it is done online, and it '
                      'covers everything from a cart to a small home '
                      'business. It can be taken for one to five years, and '
                      'taking more years at once works out cheaper.',
              FssaiKind.stateLicence => hi
                  ? '₹12 लाख से ₹20 करोड़ के बीच के कारोबार पर राज्य का लाइसेंस '
                      'चाहिए। इसमें थोड़े ज़्यादा काग़ज़ लगते हैं — जगह का नक़्शा, पानी '
                      'की जाँच रिपोर्ट, और खाने की सूची।'
                  : 'Between ₹12 lakh and ₹20 crore a state licence is '
                      'needed. It asks for a little more: a layout of the '
                      'premises, a water test report, and the list of '
                      'products.',
              FssaiKind.centralLicence => hi
                  ? '₹20 करोड़ से ऊपर, या एक से ज़्यादा राज्य में काम, या आयात-निर्यात '
                      'हो तो केंद्र का लाइसेंस चाहिए।'
                  : 'Above ₹20 crore, or operating in more than one state, or '
                      'importing and exporting, needs a central licence.',
            },
            tone: ToolTone.plain,
            icon: Icons.verified_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'अर्ज़ी के साथ' : 'What the application needs',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const ToolChecklist(
            storageKey: 'fssai_papers_v1',
            introEn: 'Apply on the FoSCoS portal. For basic registration the '
                'list is short.',
            introHi: 'FoSCoS पोर्टल पर अर्ज़ी दें। बुनियादी पंजीकरण की सूची छोटी है।',
            items: [
              CheckItem('id', 'Aadhaar and a photograph',
                  'आधार और एक फ़ोटो'),
              CheckItem('address', 'Proof of the business address',
                  'धंधे की जगह का सबूत'),
              CheckItem('list', 'A list of what food you make or sell',
                  'आप क्या खाना बनाते या बेचते हैं, उसकी सूची'),
              CheckItem('display', 'Display the FSSAI number at the shop and '
                  'print it on the bill',
                  'एफ़एसएसएआई नंबर दुकान पर लगाएँ और बिल पर छापें',
                  noteEn: 'Required, and it is also the cheapest '
                      'advertisement a food business has.',
                  noteHi: 'यह ज़रूरी भी है, और खाने के धंधे के लिए सबसे सस्ता '
                      'विज्ञापन भी।'),
              CheckItem('renew', 'Note the renewal date - a lapsed '
                  'registration is treated as none',
                  'नवीनीकरण की तारीख़ लिख लें — समाप्त पंजीकरण का मतलब कोई पंजीकरण '
                      'नहीं'),
            ],
          ),
          ToolNote(hi
              ? 'साफ़-सफ़ाई की बुनियादी शर्तें भी इसी के साथ आती हैं: साफ़ पानी, ढका '
                  'खाना, कूड़े का अलग इंतज़ाम, और खाना छूने वालों की सेहत। जाँच में '
                  'यही देखा जाता है, और इनमें ख़र्च नहीं लगता।'
              : 'Basic hygiene conditions come with it: clean water, covered '
                  'food, separate waste disposal, and the health of whoever '
                  'handles the food. That is what an inspection looks at, and '
                  'none of it costs money.'),
          const SourceNote(text: 'FoSCoS - FSSAI licensing', url: _fssaiUrl),
        ],
      ],
    );
  }
}

// --- Street vendor ----------------------------------------------------

class StreetVendorPage extends StatelessWidget {
  const StreetVendorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 9,
      title: hi ? 'पथ विक्रेता: वेंडिंग प्रमाण पत्र' : 'Street vendor: certificate of vending',
      children: [
        ToolNote(hi
            ? 'पथ विक्रेता क़ानून, 2014 के बाद ठेला या खोमचा लगाना अपराध नहीं, '
                'आजीविका का अधिकार है। प्रमाण पत्र वाले विक्रेता का सामान मनमाने ढंग '
                'से हटाया या ज़ब्त नहीं किया जा सकता, और हटाना ज़रूरी हो तो पहले सूचना '
                'और वैकल्पिक जगह देनी होती है। यह काग़ज़ ठेले की सबसे बड़ी सुरक्षा है।'
            : 'Since the Street Vendors Act, 2014 running a cart or a stall '
                'is not an offence but a livelihood right. A vendor with a '
                'certificate cannot have their goods moved or seized at will, '
                'and where relocation is necessary notice and an alternative '
                'site have to come first. That paper is the biggest '
                'protection a cart has.'),
        const SizedBox(height: 10),
        Text(hi ? 'प्रमाण पत्र क्या बचाता है' : 'What the certificate protects',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'तय जगह पर धंधा करने का अधिकार, जो नगर वेंडिंग समिति तय करती है',
                  'मनमाने ढंग से हटाया या सामान ज़ब्त नहीं किया जा सकता',
                  'हटाना ज़रूरी हो तो पहले लिखित सूचना, और वैकल्पिक जगह',
                  'सामान ज़ब्त हो तो उसे वापस पाने की तय प्रक्रिया — और जल्दी ख़राब '
                      'होने वाला सामान उसी दिन वापस मिलना चाहिए',
                  'पीएम स्वनिधि के बिना ज़मानत ऋण का रास्ता खुलता है',
                  'वेंडिंग समिति में विक्रेताओं के अपने प्रतिनिधि होते हैं',
                ]
              : const [
                  'A right to vend in a place the Town Vending Committee '
                      'settles',
                  'No arbitrary eviction, and no seizure of goods at will',
                  'Written notice before any relocation, and an alternative '
                      'site',
                  'A laid-down process for getting seized goods back - and '
                      'perishables are to be returned the same day',
                  'It opens the PM SVANidhi collateral-free loan route',
                  'Vendors have their own representatives on the Vending '
                      'Committee',
                ],
        ),
        const SizedBox(height: 14),
        Text(hi ? 'कैसे मिलता है' : 'How to get it',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'नगर निकाय या नगर वेंडिंग समिति में अर्ज़ी दें। आधार, फ़ोटो और '
                      'जगह का विवरण चाहिए।',
                  'निकाय समय-समय पर विक्रेताओं का सर्वे कराता है; सर्वे में नाम दर्ज '
                      'होना सबसे आसान रास्ता है, इसलिए सर्वे होने पर मौजूद रहें।',
                  'अर्ज़ी की पावती लें — यह अपने आप में बचाव का काम करती है, जब तक '
                      'प्रमाण पत्र न बने।',
                  'प्रमाण पत्र मिलने पर ठेले पर रखें और एक नक़ल घर पर।',
                  'मना हो तो कारण लिखित में माँगें; समिति के फ़ैसले के ख़िलाफ़ अपील की '
                      'व्यवस्था है।',
                ]
              : const [
                  'Apply at the local body or the Town Vending Committee '
                      'with Aadhaar, a photograph and details of the place.',
                  'The local body conducts vendor surveys from time to time; '
                      'getting your name into the survey is the easiest '
                      'route, so be present when one happens.',
                  'Take the acknowledgement of your application - it works '
                      'as protection in itself until the certificate is '
                      'made.',
                  'Keep the certificate on the cart and a copy at home.',
                  'If it is refused, ask for the reason in writing; there is '
                      'an appeal against the committee\'s decision.',
                ],
        ),
        const SizedBox(height: 14),
        ToolAnswer(
          headline: hi ? 'उसके बाद ऋण की सीढ़ी' : 'Then the loan ladder',
          detail: hi
              ? 'पीएम स्वनिधि में पथ विक्रेताओं के लिए बिना ज़मानत कार्यशील पूँजी का '
                  'ऋण मिलता है, और यह सीढ़ी की तरह है: पहला ऋण चुकाने पर दूसरा बड़ा, '
                  'उसे चुकाने पर तीसरा और बड़ा। समय पर चुकाने पर ब्याज में छूट मिलती '
                  'है, और डिजिटल लेन-देन करने पर अलग से प्रोत्साहन। इसमें असली बात '
                  'यही सीढ़ी है — पहला ऋण छोटा लगता है, लेकिन उसे ठीक से चुकाना ही '
                  'तीसरी किस्त तक पहुँचने का रास्ता है, और वह रक़म साहूकार से हमेशा '
                  'के लिए छुड़ा सकती है।'
              : 'PM SVANidhi gives street vendors collateral-free working '
                  'capital, and it works as a ladder: repay the first loan '
                  'and the second is larger, repay that and the third is '
                  'larger again. Repaying on time earns an interest subsidy, '
                  'and digital transactions earn a separate incentive. The '
                  'ladder is the real point - the first loan looks small, but '
                  'repaying it properly is the route to the third, and that '
                  'amount can end a moneylender\'s hold for good.',
          tone: ToolTone.good,
          icon: Icons.stairs_outlined,
        ),
        ToolDonts(
          heading: hi ? 'यह जान लें' : 'Worth knowing',
          items: hi
              ? const [
                  'प्रमाण पत्र या सर्वे में नाम दर्ज कराने के पैसे कोई नहीं ले सकता',
                  'ऋण दिलाने के नाम पर कमीशन माँगने वाले से बचें — स्वनिधि का ऋण '
                      'सीधे बैंक से मिलता है',
                  'सामान ज़ब्त हो तो रसीद माँगें; बिना रसीद ज़ब्ती की शिकायत बनती है',
                  'हटाने से पहले लिखित सूचना न मिली हो तो वह अपने आप में शिकायत का '
                      'आधार है',
                  'खाने का धंधा हो तो एफ़एसएसएआई पंजीकरण भी ज़रूरी है — इसी लक्ष्य में '
                      'उसकी स्क्रीन है',
                ]
              : const [
                  'Nobody may charge for the certificate or for getting your '
                      'name into the survey',
                  'Avoid anyone asking a commission to arrange the loan - '
                      'SVANidhi lending comes straight from the bank',
                  'If goods are seized, ask for a receipt; a seizure without '
                      'one is itself a complaint',
                  'If no written notice came before an eviction, that is a '
                      'ground of complaint in itself',
                  'For a food cart an FSSAI registration is needed too - '
                      'there is a screen for it in this goal',
                ],
        ),
        const SourceNote(text: 'PM SVANidhi', url: _svanidhiUrl),
      ],
    );
  }
}
