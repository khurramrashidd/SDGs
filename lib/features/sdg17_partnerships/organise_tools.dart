import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Working together locally: a group, the gram sabha, the village plan, a
/// social audit, CSR money, and registering an organisation.
///
/// How often a gram sabha must meet, and how many members can call a
/// special one, are set by each state's Panchayati Raj Act, so those are
/// described rather than counted.

const _egramUrl = 'https://egramswaraj.gov.in/';
const _nregaUrl = 'https://nrega.nic.in/';
const _mcaUrl = 'https://www.mca.gov.in/';
const _darpanUrl = 'https://ngodarpan.gov.in/';
const _incomeTaxUrl = 'https://www.incometax.gov.in/';

/// Companies Act 2013, section 135: a company crossing any one of these in
/// the preceding financial year must spend 2% of its average net profit of
/// the last three years on CSR.
const csrNetWorthCrore = 500;
const csrTurnoverCrore = 1000;
const csrNetProfitCrore = 5;
const csrSharePercent = 2;

// --- Start a group ----------------------------------------------------

class VillageGroupPage extends StatelessWidget {
  const VillageGroupPage({super.key});

  String _agenda(bool hi) => hi
      ? 'पहली बैठक — कार्यसूची\n\n'
          '1. परिचय: हर व्यक्ति अपना नाम और समूह से क्या चाहता है, एक वाक्य में\n'
          '2. समूह किस एक काम के लिए है (एक ही चुनें, शुरुआत में)\n'
          '3. कौन क्या करेगा: संयोजक, लिखने वाला, हिसाब रखने वाला\n'
          '4. बैठक कब और कहाँ — हर महीने एक तय दिन\n'
          '5. पैसा: लेंगे या नहीं; लें तो कौन रखेगा और हिसाब कैसे दिखेगा\n'
          '6. फ़ैसले कैसे होंगे: बहुमत, या सबकी सहमति\n'
          '7. अगली बैठक तक कौन क्या करेगा — नाम और तारीख़ के साथ\n\n'
          'बैठक की बातें एक रजिस्टर में लिखें और सब दस्तख़त करें।'
      : 'First meeting - agenda\n\n'
          '1. Introductions: each person\'s name and, in one sentence, what '
          'they want from the group\n'
          '2. The one thing this group is for (choose just one, to begin)\n'
          '3. Who does what: convenor, note-taker, treasurer\n'
          '4. When and where to meet - a fixed day each month\n'
          '5. Money: whether to collect any; if so, who holds it and how the '
          'account is shown\n'
          '6. How decisions are made: majority, or everyone agreeing\n'
          '7. Who does what before the next meeting - with names and dates\n\n'
          'Write the meeting down in a register and have everyone sign.';

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 17,
      title: hi ? 'गाँव या वार्ड का समूह बनाएँ' : 'Start a village or ward group',
      children: [
        ToolNote(hi
            ? 'ज़्यादातर समूह इसलिए टूटते हैं कि वे एक साथ बहुत कुछ करना चाहते हैं, या '
                'पैसे का हिसाब साफ़ नहीं होता। एक काम से शुरू करें — नाली की सफ़ाई, '
                'बच्चों की पढ़ाई, पानी की टंकी — और हिसाब हर बैठक में सबके सामने रखें।'
            : 'Most groups break up because they try to do too much at once, '
                'or because the money is not accounted for openly. Start with '
                'one thing - clearing a drain, children\'s studies, a water tank '
                '- and put the accounts before everyone at every meeting.'),
        const SizedBox(height: 12),
        CopyBlock(
          text: _agenda(hi),
          note: hi
              ? 'इसे समूह के व्हाट्सऐप में भेज दें, ताकि सब तैयार होकर आएँ।'
              : 'Send it to the group\'s WhatsApp so everyone comes prepared.',
        ),
        const SizedBox(height: 12),
        Text(hi ? 'जो आगे काम आता है' : 'What helps later',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'हर बैठक का रजिस्टर — पंचायत या अफ़सर के सामने यही समूह का सबूत है',
                  'महिलाओं का स्वयं सहायता समूह बनाना हो तो ब्लॉक के आजीविका मिशन '
                      'कार्यालय से जुड़ें — वहाँ प्रशिक्षण और बैंक से जुड़ाव मिलता है',
                  'पैसा जमा करना हो तो समूह के नाम बैंक खाता, दो लोगों के दस्तख़त से',
                  'बड़े काम के लिए समूह को पंजीकृत कराना पड़ सकता है — इसी लक्ष्य में '
                      '"एनजीओ पंजीकरण" देखें',
                ]
              : const [
                  'A register of every meeting - before the panchayat or an '
                      'officer, it is the group\'s proof',
                  'For a women\'s self-help group, link up with the block\'s '
                      'livelihood mission office - it gives training and a bank '
                      'link',
                  'If you collect money, a bank account in the group\'s name, '
                      'with two signatures',
                  'For bigger work the group may need registering - see '
                      '"Register an NGO" in this goal',
                ],
        ),
      ],
    );
  }
}

// --- Gram sabha agenda item -------------------------------------------

class GramSabhaPage extends StatefulWidget {
  const GramSabhaPage({super.key});

  @override
  State<GramSabhaPage> createState() => _GramSabhaPageState();
}

class _GramSabhaPageState extends State<GramSabhaPage> {
  final _village = TextEditingController();
  final _item = TextEditingController();

  @override
  void dispose() {
    _village.dispose();
    _item.dispose();
    super.dispose();
  }

  String _or(TextEditingController c) =>
      c.text.trim().isEmpty ? '______' : c.text.trim();

  String _letter(bool hi) => hi
      ? 'सेवा में,\n'
          'सरपंच / ग्राम पंचायत सचिव\n'
          'ग्राम पंचायत ${_or(_village)}\n\n'
          'विषय: आगामी ग्राम सभा की कार्यसूची में विषय जोड़ने हेतु\n\n'
          'महोदय/महोदया,\n\n'
          'मैं इस ग्राम पंचायत का मतदाता और ग्राम सभा का सदस्य हूँ। निवेदन है कि '
          'आगामी ग्राम सभा में निम्न विषय पर चर्चा और निर्णय हो:\n\n'
          '${_or(_item)}\n\n'
          'कृपया इस आवेदन की प्राप्ति रसीद दें, और बैठक की कार्यवाही (मिनट्स) की प्रति '
          'उपलब्ध कराएँ।\n\n'
          'दिनांक: ____________\n'
          'नाम: ____________\n'
          'वार्ड: ____________\n'
          'फ़ोन: ____________'
      : 'To,\n'
          'The Sarpanch / Gram Panchayat Secretary\n'
          'Gram Panchayat ${_or(_village)}\n\n'
          'Subject: Adding an item to the agenda of the coming gram sabha\n\n'
          'Sir / Madam,\n\n'
          'I am a voter of this gram panchayat and a member of the gram sabha. '
          'I request that the following be discussed and decided at the coming '
          'gram sabha:\n\n'
          '${_or(_item)}\n\n'
          'Kindly give me a receipt for this application, and make a copy of '
          'the meeting\'s minutes available.\n\n'
          'Date: ____________\n'
          'Name: ____________\n'
          'Ward: ____________\n'
          'Phone: ____________';

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 17,
      title: hi ? 'ग्राम सभा: कार्यसूची में विषय जोड़ें' : 'Gram Sabha: put an item on the agenda',
      children: [
        ToolNote(hi
            ? 'गाँव का हर वयस्क मतदाता ग्राम सभा का सदस्य है — अलग से सदस्यता नहीं '
                'लेनी पड़ती। ग्राम सभा कितनी बार बैठेगी, यह राज्य का पंचायती राज क़ानून तय '
                'करता है; ज़्यादातर राज्यों में साल में कम से कम दो से चार बार, और कई '
                'राज्यों में 26 जनवरी, 1 मई, 15 अगस्त और 2 अक्टूबर को।'
            : 'Every adult voter of the village is a member of the gram sabha - '
                'no separate membership is needed. How often it meets is set by '
                'the state\'s Panchayati Raj Act; in most states at least two to '
                'four times a year, and in many on 26 January, 1 May, 15 August '
                'and 2 October.'),
        ToolQuestion(hi ? 'आपका विषय' : 'Your item'),
        ToolText(
          controller: _village,
          label: hi ? 'ग्राम पंचायत' : 'Gram panchayat',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolText(
          controller: _item,
          label: hi ? 'क्या चर्चा हो, और आप क्या चाहते हैं' : 'What to discuss, and what you want',
          maxLength: 400,
          maxLines: 4,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        CopyBlock(
          text: _letter(hi),
          note: hi
              ? 'बैठक से कुछ दिन पहले दें। गाँव के कुछ और लोग साथ में दस्तख़त करें तो '
                  'विषय को अनदेखा करना मुश्किल होता है।'
              : 'Give it a few days before the meeting. With a few more villagers '
                  'signing too, the item is much harder to ignore.',
        ),
        const SizedBox(height: 12),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'बैठक में पहुँचें और विषय ख़ुद रखें; निर्णय कार्यवाही में लिखा जाए, यह '
                      'देखें',
                  'कार्यवाही (मिनट्स) सार्वजनिक काग़ज़ है — उसकी प्रति माँगें, न मिले तो '
                      'सूचना का अधिकार से',
                  'कई राज्यों में एक तय संख्या में सदस्य मिलकर विशेष ग्राम सभा बुलवा सकते '
                      'हैं — पंचायत सचिव से अपने राज्य का नियम पूछें',
                  'कई राज्यों में ग्राम सभा से पहले महिला सभा होती है — महिलाओं के मुद्दे '
                      'वहाँ से भी आगे बढ़ते हैं',
                ]
              : const [
                  'Attend and raise the item yourself; make sure the decision is '
                      'written in the minutes',
                  'The minutes are a public paper - ask for a copy; if refused, '
                      'under the Right to Information',
                  'In many states a set number of members together can call a '
                      'special gram sabha - ask the panchayat secretary for your '
                      'state\'s rule',
                  'Several states hold a Mahila Sabha before the gram sabha - '
                      'women\'s issues can go forward from there too',
                ],
        ),
        const SourceNote(text: 'eGramSwaraj', url: _egramUrl),
      ],
    );
  }
}

// --- Propose a work under the village plan ----------------------------

class VillagePlanPage extends StatefulWidget {
  const VillagePlanPage({super.key});

  @override
  State<VillagePlanPage> createState() => _VillagePlanPageState();
}

class _VillagePlanPageState extends State<VillagePlanPage> {
  final _work = TextEditingController();
  final _where = TextEditingController();
  final _who = TextEditingController();

  @override
  void dispose() {
    for (final c in [_work, _where, _who]) {
      c.dispose();
    }
    super.dispose();
  }

  String _or(TextEditingController c) =>
      c.text.trim().isEmpty ? '______' : c.text.trim();

  String _proposal(bool hi) => hi
      ? 'ग्राम पंचायत विकास योजना हेतु प्रस्ताव\n\n'
          'काम: ${_or(_work)}\n'
          'जगह: ${_or(_where)}\n'
          'किसे फ़ायदा: ${_or(_who)}\n\n'
          'क्यों ज़रूरी: ____________\n'
          'अभी क्या परेशानी है (फ़ोटो संलग्न): ____________\n\n'
          'प्रस्तावक: ____________\n'
          'समर्थन में दस्तख़त: ____________'
      : 'Proposal for the Gram Panchayat Development Plan\n\n'
          'Work: ${_or(_work)}\n'
          'Place: ${_or(_where)}\n'
          'Who benefits: ${_or(_who)}\n\n'
          'Why it is needed: ____________\n'
          'The problem now (photos attached): ____________\n\n'
          'Proposed by: ____________\n'
          'Signatures in support: ____________';

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 17,
      title: hi ? 'गाँव की योजना में काम का प्रस्ताव' : 'Propose a work under the village plan',
      children: [
        ToolNote(hi
            ? 'हर ग्राम पंचायत साल में एक बार ग्राम पंचायत विकास योजना (जीपीडीपी) बनाती '
                'है, और उसे ग्राम सभा मंज़ूर करती है। योजना बनाने का अभियान आम तौर पर '
                '2 अक्टूबर के आसपास शुरू होता है। सड़क, नाली, तालाब — जो योजना में नहीं, '
                'उस पर पैसा नहीं लगता। मंज़ूर योजना ई-ग्रामस्वराज पर दिखती है।'
            : 'Every gram panchayat makes a Gram Panchayat Development Plan '
                '(GPDP) once a year, and the gram sabha approves it. The '
                'planning campaign usually starts around 2 October. A road, a '
                'drain, a pond - if it is not in the plan, no money goes to it. '
                'The approved plan shows on eGramSwaraj.'),
        ToolQuestion(hi ? 'प्रस्ताव' : 'The proposal'),
        ToolText(
          controller: _work,
          label: hi ? 'काम (जैसे: नाली, सड़क, तालाब)' : 'The work (e.g. drain, road, pond)',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolText(
          controller: _where,
          label: hi ? 'ठीक कहाँ' : 'Exactly where',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolText(
          controller: _who,
          label: hi ? 'किन्हें फ़ायदा — कितने घर' : 'Who benefits - how many homes',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        CopyBlock(
          text: _proposal(hi),
          note: hi
              ? 'वार्ड सभा या ग्राम सभा में दें, फ़ोटो के साथ। जितने ज़्यादा घरों के दस्तख़त, '
                  'उतना मज़बूत प्रस्ताव।'
              : 'Give it at the ward sabha or gram sabha, with photos. The more '
                  'households sign, the stronger it is.',
        ),
        const SizedBox(height: 12),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'मज़दूरी वाले काम — तालाब, मेड़, कच्ची सड़क — मनरेगा की "कामों की सूची" में '
                      'भी जा सकते हैं, जिसे ग्राम सभा मंज़ूर करती है',
                  'मंज़ूरी के बाद ई-ग्रामस्वराज पर देखें कि काम योजना में आया या नहीं',
                  'न आया हो तो अगली ग्राम सभा में पूछें, और लिखित जवाब माँगें',
                ]
              : const [
                  'Labour works - ponds, bunds, earthen roads - can also go into '
                      'MGNREGA\'s "shelf of works", which the gram sabha approves',
                  'After approval, check on eGramSwaraj whether the work is in '
                      'the plan',
                  'If it is not, ask at the next gram sabha, and ask for a '
                      'written answer',
                ],
        ),
        const SourceNote(text: 'eGramSwaraj', url: _egramUrl),
        const SourceNote(text: 'MGNREGA', url: _nregaUrl),
      ],
    );
  }
}

// --- Social audit -----------------------------------------------------

class SocialAuditPage extends StatelessWidget {
  const SocialAuditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 17,
      title: hi ? 'सामाजिक अंकेक्षण: सरकारी काम जाँचें' : 'Social audit: check a public work',
      children: [
        ToolNote(hi
            ? 'मनरेगा क़ानून में हर ग्राम पंचायत के कामों का सामाजिक अंकेक्षण ग्राम सभा में '
                'होना ज़रूरी है — कम से कम हर छह महीने। पर कोई भी नागरिक, कभी भी, किसी '
                'सरकारी काम की जाँच कर सकता है: जो लिखा है, वह बना है या नहीं, और जिनके '
                'नाम पैसा गया, उन्होंने काम किया या नहीं।'
            : 'The MGNREGA law requires a social audit of every gram '
                'panchayat\'s works in the gram sabha - at least every six '
                'months. But any citizen can check any public work at any time: '
                'whether what is recorded was built, and whether the people paid '
                'actually worked.'),
        const SizedBox(height: 12),
        Text(hi ? 'पहले काग़ज़' : 'The papers first',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'मनरेगा की वेबसाइट पर ग्राम पंचायत के काम, हाज़िरी रजिस्टर (मस्टर रोल) और '
                      'भुगतान देखे जा सकते हैं।',
                  'काम की जगह पर नागरिक सूचना बोर्ड होना ज़रूरी है — काम का नाम, लागत, '
                      'मज़दूरी के दिन।',
                  'बाक़ी — नाप पुस्तिका, सामान के बिल — सूचना का अधिकार से माँगें।',
                ]
              : const [
                  'The MGNREGA website shows a gram panchayat\'s works, muster '
                      'rolls and payments.',
                  'A citizen information board is required at the worksite - the '
                      'work\'s name, cost and person-days.',
                  'The rest - the measurement book, material bills - ask for '
                      'under the Right to Information.',
                ],
        ),
        const SizedBox(height: 12),
        Text(hi ? 'फिर मौक़े पर मिलाएँ' : 'Then check on the spot',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const ToolChecklist(
          storageKey: 'social_audit_v1',
          introEn: 'Tick each one you have checked.',
          introHi: 'जो जाँच लिया, उस पर निशान लगाएँ।',
          items: [
            CheckItem('exists', 'The work exists where the record says',
                'काम वहीं बना है जहाँ रिकॉर्ड में लिखा है'),
            CheckItem('size', 'Its size roughly matches the record',
                'उसका आकार रिकॉर्ड से लगभग मेल खाता है',
                noteEn: 'A pond\'s length and depth, a road\'s length - pace it '
                    'out.',
                noteHi: 'तालाब की लंबाई-गहराई, सड़क की लंबाई — क़दमों से नापें।'),
            CheckItem('workers', 'The people on the muster roll exist and worked',
                'मस्टर रोल के लोग असली हैं और उन्होंने काम किया',
                noteEn: 'Ask a few of them. Names of the dead, of people away, '
                    'or of children are the commonest fraud.',
                noteHi: 'कुछ लोगों से पूछें। मरे हुए, बाहर गए, या बच्चों के नाम सबसे आम '
                    'गड़बड़ी हैं।'),
            CheckItem('paid', 'They were paid the days recorded',
                'जितने दिन लिखे हैं, उतनी मज़दूरी मिली'),
            CheckItem('material', 'Materials billed were used',
                'जिस सामान का बिल है, वह लगा है'),
            CheckItem('board', 'The citizen information board is up',
                'नागरिक सूचना बोर्ड लगा है'),
          ],
        ),
        const SizedBox(height: 12),
        ToolNote(hi
            ? 'जो मिला, उसे ग्राम सभा के सामाजिक अंकेक्षण में रखें, या राज्य की सामाजिक '
                'अंकेक्षण इकाई और ज़िला कार्यक्रम समन्वयक को लिखित में दें। नाम लेकर किसी पर '
                'आरोप लगाने से पहले काग़ज़ पक्के कर लें।'
            : 'Put what you found before the gram sabha\'s social audit, or give '
                'it in writing to the state social audit unit and the district '
                'programme coordinator. Before naming anyone, make sure the '
                'papers are solid.'),
        const SourceNote(text: 'MGNREGA', url: _nregaUrl),
      ],
    );
  }
}

// --- CSR funds --------------------------------------------------------

class CsrPage extends StatelessWidget {
  const CsrPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 17,
      title: hi ? 'स्थानीय समूह के लिए सीएसआर पैसा' : 'CSR funds for a local group',
      children: [
        ToolAnswer(
          headline: hi
              ? 'बड़ी कंपनियों को मुनाफ़े का $csrSharePercent% ख़र्च करना ही है'
              : 'Large companies must spend $csrSharePercent% of profit',
          detail: hi
              ? 'कंपनी अधिनियम की धारा 135: पिछले साल जिस कंपनी की कुल संपत्ति '
                  '₹$csrNetWorthCrore करोड़, या कारोबार ₹$csrTurnoverCrore करोड़, या शुद्ध '
                  'मुनाफ़ा ₹$csrNetProfitCrore करोड़ से ज़्यादा रहा, उसे पिछले तीन साल के '
                  'औसत मुनाफ़े का $csrSharePercent% सामाजिक काम — शिक्षा, स्वास्थ्य, पानी, '
                  'स्वच्छता, पर्यावरण, आजीविका — पर लगाना होता है।'
              : 'Companies Act section 135: a company whose net worth exceeded '
                  '₹$csrNetWorthCrore crore, or turnover ₹$csrTurnoverCrore '
                  'crore, or net profit ₹$csrNetProfitCrore crore last year must '
                  'spend $csrSharePercent% of its average profit of the last '
                  'three years on social work - education, health, water, '
                  'sanitation, environment, livelihoods.',
          tone: ToolTone.plain,
          icon: Icons.business_outlined,
        ),
        const SizedBox(height: 12),
        Text(hi ? 'समूह को क्या चाहिए' : 'What a group needs',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'पंजीकृत संस्था — ट्रस्ट, सोसाइटी या धारा 8 कंपनी। अपंजीकृत समूह सीधे '
                      'सीएसआर का पैसा नहीं ले सकता।',
                  'आयकर की 12ए और 80जी पंजीकरण।',
                  'कंपनी मामलों के मंत्रालय के पोर्टल पर सीएसआर-1 फ़ॉर्म से पंजीकरण — '
                      'इसके बिना कोई कंपनी आपको सीएसआर का पैसा नहीं दे सकती। आम तौर पर उसी '
                      'तरह के काम का कम से कम तीन साल का अनुभव चाहिए।',
                  'काम का साफ़ प्रस्ताव: समस्या, कितने लोग, क्या करेंगे, कितना ख़र्च, और '
                      'असर कैसे दिखाएँगे।',
                ]
              : const [
                  'A registered organisation - a trust, a society or a section 8 '
                      'company. An unregistered group cannot take CSR money '
                      'directly.',
                  'Income tax 12A and 80G registration.',
                  'Registration on the Ministry of Corporate Affairs portal '
                      'through Form CSR-1 - without it no company can give you '
                      'CSR money. Usually at least three years\' experience in '
                      'similar work is needed.',
                  'A clear proposal: the problem, how many people, what you will '
                      'do, the cost, and how you will show the result.',
                ],
        ),
        const SizedBox(height: 12),
        ToolNote(hi
            ? 'पंजीकरण से पहले का रास्ता: पास की किसी पंजीकृत और सीएसआर-1 वाली संस्था के '
                'साथ साझेदारी, या कंपनी से कहें कि वह सीधे पंचायत या स्कूल के साथ काम करे। '
                'पास के कारख़ाने या बैंक की शाखा से पूछें कि उनकी सीएसआर किसके हाथ में है।'
            : 'The route before registering: partner with a nearby registered '
                'organisation that has CSR-1, or ask the company to work '
                'directly with the panchayat or school. Ask a nearby factory or '
                'bank branch who handles their CSR.'),
        const SourceNote(text: 'Ministry of Corporate Affairs', url: _mcaUrl),
      ],
    );
  }
}

// --- Register an NGO --------------------------------------------------

enum NgoForm { trust, society, section8 }

class NgoRegisterPage extends StatefulWidget {
  const NgoRegisterPage({super.key});

  @override
  State<NgoRegisterPage> createState() => _NgoRegisterPageState();
}

class _NgoRegisterPageState extends State<NgoRegisterPage> {
  NgoForm? _form;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 17,
      title: hi ? 'एनजीओ पंजीकरण' : 'Register an NGO',
      children: [
        ToolNote(hi
            ? 'तीन रूप हैं। सबसे सस्ता और सरल ट्रस्ट है, सबसे लोकतांत्रिक सोसाइटी, और '
                'सबसे भरोसेमंद पर सबसे ज़्यादा काग़ज़ी काम वाली धारा 8 कंपनी। चुनिए कौन '
                'आपके काम के क़रीब है।'
            : 'There are three forms. The cheapest and simplest is a trust, the '
                'most democratic a society, and the most trusted but heaviest '
                'on paperwork a section 8 company. Pick the one nearest your '
                'work.'),
        SelectionTile(
          label: hi ? 'ट्रस्ट' : 'Trust',
          subtitle: hi ? 'कुछ भरोसेमंद लोग, एक तय मक़सद' : 'A few trusted people, one fixed purpose',
          selected: _form == NgoForm.trust,
          onTap: () => setState(() => _form = NgoForm.trust),
        ),
        SelectionTile(
          label: hi ? 'सोसाइटी' : 'Society',
          subtitle: hi ? 'सदस्यों वाला संगठन, चुनाव से चलने वाला' : 'A membership body run by elections',
          selected: _form == NgoForm.society,
          onTap: () => setState(() => _form = NgoForm.society),
        ),
        SelectionTile(
          label: hi ? 'धारा 8 कंपनी' : 'Section 8 company',
          subtitle: hi ? 'बड़ा काम, बड़े दाता, पूरे देश में' : 'Large work, large donors, national reach',
          selected: _form == NgoForm.section8,
          onTap: () => setState(() => _form = NgoForm.section8),
        ),
        if (_form == NgoForm.trust)
          ToolAnswer(
            headline: hi ? 'ट्रस्ट डीड, सब-रजिस्ट्रार के यहाँ' : 'A trust deed, at the sub-registrar',
            detail: hi
                ? 'कम से कम दो ट्रस्टी। ट्रस्ट डीड — मक़सद, ट्रस्टी, नियम — स्टांप पेपर पर '
                    'लिखकर सब-रजिस्ट्रार कार्यालय में पंजीकृत कराएँ; कुछ राज्यों में सार्वजनिक '
                    'ट्रस्ट अधिनियम में अलग पंजीकरण भी है। ख़र्च मुख्य रूप से स्टांप शुल्क है, '
                    'जो राज्य तय करता है। कमी: ट्रस्टी आम तौर पर बदलते नहीं, इसलिए यह '
                    'सदस्यों वाले संगठन के लिए ठीक नहीं।'
                : 'At least two trustees. The trust deed - purpose, trustees, '
                    'rules - is written on stamp paper and registered at the '
                    'sub-registrar\'s office; some states also require separate '
                    'registration under a public trusts act. The main cost is '
                    'stamp duty, which the state sets. The drawback: trustees '
                    'usually do not change, so it does not suit a membership '
                    'body.',
            tone: ToolTone.good,
            icon: Icons.description_outlined,
          ),
        if (_form == NgoForm.society)
          ToolAnswer(
            headline: hi ? 'कम से कम सात सदस्य' : 'At least seven members',
            detail: hi
                ? 'सोसाइटी पंजीकरण अधिनियम 1860 (या राज्य का अपना क़ानून) में कम से कम सात '
                    'लोग मिलकर ज्ञापन (मेमोरेंडम) और नियम-उपनियम बनाते हैं और राज्य के '
                    'सोसाइटी रजिस्ट्रार के पास पंजीकरण कराते हैं। शुल्क कम है। पदाधिकारी '
                    'चुनाव से बदलते हैं, और हर साल की आम सभा और हिसाब रजिस्ट्रार को देना '
                    'होता है।'
                : 'Under the Societies Registration Act 1860 (or the state\'s '
                    'own law), at least seven people draw up a memorandum and '
                    'rules and register with the state Registrar of Societies. '
                    'The fee is small. Office-bearers change by election, and '
                    'the annual general meeting and accounts go to the '
                    'registrar every year.',
            tone: ToolTone.good,
            icon: Icons.groups_outlined,
          ),
        if (_form == NgoForm.section8)
          ToolAnswer(
            headline: hi ? 'कंपनी मामलों के मंत्रालय में' : 'With the Ministry of Corporate Affairs',
            detail: hi
                ? 'कंपनी अधिनियम की धारा 8 के अंतर्गत, कम से कम दो निदेशकों के साथ, मंत्रालय '
                    'के पोर्टल पर ऑनलाइन। मुनाफ़ा सदस्यों में नहीं बँटता। बड़े दाता और विदेशी '
                    'संस्थाएँ इसे सबसे ज़्यादा भरोसेमंद मानती हैं, पर हर साल खातों का अंकेक्षण, '
                    'बोर्ड बैठकें और रिटर्न ज़रूरी हैं — पेशेवर ख़र्च सबसे ज़्यादा।'
                : 'Under section 8 of the Companies Act, with at least two '
                    'directors, online on the ministry\'s portal. Profit is '
                    'never shared among members. Large donors and foreign '
                    'bodies trust it most, but annual audited accounts, board '
                    'meetings and returns are compulsory - the professional '
                    'cost is the highest.',
            tone: ToolTone.good,
            icon: Icons.apartment_outlined,
          ),
        if (_form != null) ...[
          const SizedBox(height: 12),
          Text(hi ? 'पंजीकरण के बाद — तीनों में' : 'After registering - all three',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'संस्था का पैन, और संस्था के नाम बैंक खाता।',
                    'आयकर में 12ए (संस्था की आय पर छूट) और 80जी (दानदाता को छूट) — पहले '
                        'अस्थायी, बाद में नियमित।',
                    'नीति आयोग के एनजीओ दर्पण पर पंजीकरण — सरकारी अनुदान के लिए ज़रूरी।',
                    'विदेश से पैसा लेना हो तो एफ़सीआरए पंजीकरण अलग से, और उसके लिए आम तौर पर '
                        'कुछ साल का काम दिखाना पड़ता है।',
                  ]
                : const [
                    'The organisation\'s PAN, and a bank account in its name.',
                    'Income tax 12A (exemption on its income) and 80G (deduction '
                        'for donors) - provisional first, regular later.',
                    'Registration on NITI Aayog\'s NGO Darpan - needed for '
                        'government grants.',
                    'To receive foreign money, FCRA registration separately, '
                        'which usually needs a few years of work to show.',
                  ],
          ),
          const SourceNote(text: 'NGO Darpan', url: _darpanUrl),
          const SourceNote(text: 'Income Tax Department', url: _incomeTaxUrl),
        ],
      ],
    );
  }
}
