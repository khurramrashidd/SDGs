import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Three screens about work that is better than the work you have:
/// going abroad, getting trained, and registering as a construction
/// worker.
///
/// The emigration screen is the one with real money at stake. A family
/// mortgages land to pay an agent, and the single check that would have
/// prevented it - looking the agent up on the government's own register -
/// takes two minutes and almost nobody does it.

const _emigrateUrl = 'https://www.emigrate.gov.in/';
const _madadUrl = 'https://madad.gov.in/';
const _skillIndiaUrl = 'https://www.skillindiadigital.gov.in/';
const _dgtUrl = 'https://www.dgt.gov.in/';
const _bocwUrl = 'https://labour.gov.in/';

/// The Overseas Workers Resource Centre helpline, free and round the clock.
const owrcHelpline = '1800-11-3090';

/// A construction worker is registrable from 18 to 60, having worked 90
/// days in the preceding twelve months.
const bocwMinAge = 18;
const bocwMaxAge = 60;
const bocwDaysWorked = 90;

// --- Going abroad -----------------------------------------------------

enum AbroadStage { thinking, agentFound, paperSigned, alreadyThere }

class AbroadWorkPage extends StatefulWidget {
  const AbroadWorkPage({super.key});

  @override
  State<AbroadWorkPage> createState() => _AbroadWorkPageState();
}

class _AbroadWorkPageState extends State<AbroadWorkPage> {
  AbroadStage? _stage;
  final _paid = TextEditingController();

  @override
  void dispose() {
    _paid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final paid = double.tryParse(_paid.text.trim());

    Widget pick(AbroadStage s, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _stage == s,
          onTap: () => setState(() => _stage = s),
        );

    return ToolScaffold(
      goal: 8,
      title: hi ? 'विदेश में काम के लिए जाना' : 'Going abroad for work',
      children: [
        ToolNote(hi
            ? 'एक जाँच बाक़ी सब से ज़्यादा ज़रूरी है: एजेंट सरकार के यहाँ पंजीकृत है '
                'या नहीं। विदेश मंत्रालय के eMigrate पोर्टल पर पंजीकृत भर्ती एजेंटों '
                'की सूची है, और उसमें नाम और पंजीकरण संख्या देखी जा सकती है। बिना '
                'पंजीकरण वाले एजेंट के ज़रिये भेजा जाना अपराध है — और ज़मीन बेचकर पैसा '
                'देने वाले परिवार लगभग हमेशा यही एक जाँच छोड़ देते हैं, जिसमें दो '
                'मिनट लगते।'
            : 'One check matters more than everything else: whether the agent '
                'is registered with the government. The Ministry of External '
                'Affairs runs the eMigrate portal, which lists registered '
                'recruiting agents with their names and registration '
                'numbers. Sending someone through an unregistered agent is an '
                'offence - and the families who sell land to pay one have '
                'almost always skipped that single two-minute check.'),
        ToolQuestion(hi ? 'कहाँ तक बात पहुँची है' : 'How far along is it'),
        pick(AbroadStage.thinking, 'Only thinking about it',
            'सिर्फ़ सोच रहे हैं'),
        pick(AbroadStage.agentFound, 'An agent has made an offer',
            'एक एजेंट ने बात की है'),
        pick(AbroadStage.paperSigned, 'Papers signed, money paid',
            'काग़ज़ पर दस्तख़त हो गए, पैसा दे दिया'),
        pick(AbroadStage.alreadyThere,
            'Someone from the family is already there and in trouble',
            'परिवार का कोई वहाँ पहुँच चुका है और मुश्किल में है'),
        if (_stage != null) ...[
          if (_stage == AbroadStage.alreadyThere)
            ToolAnswer(
              headline: hi
                  ? 'भारतीय दूतावास और MADAD — यही रास्ता है'
                  : 'The Indian mission and MADAD - that is the route',
              detail: hi
                  ? 'जिस देश में वे हैं, वहाँ का भारतीय दूतावास या वाणिज्य दूतावास ही '
                      'मदद करता है, और यह मुफ़्त है। शिकायत भारत से भी दर्ज कराई जा '
                      'सकती है — विदेश मंत्रालय के MADAD पोर्टल पर, या $owrcHelpline '
                      'पर, जो चौबीसों घंटे मुफ़्त है। जिन हालात में दूतावास दख़ल देता '
                      'है: वेतन न मिलना, पासपोर्ट छीन लिया जाना, काम वह न होना जो '
                      'बताया गया था, मारपीट, या बाहर निकलने न देना। भारत से शिकायत '
                      'करते समय पासपोर्ट नंबर, वीज़ा, नियोक्ता का नाम-पता और एजेंट का '
                      'नाम साथ रखें।'
                  : 'The Indian embassy or consulate in the country they are '
                      'in is what helps, and it is free. A complaint can also '
                      'be filed from India - on the Ministry of External '
                      'Affairs\' MADAD portal, or on $owrcHelpline, which is '
                      'free and round the clock. The missions do intervene '
                      'where wages are unpaid, a passport has been taken, the '
                      'work is not what was promised, there is violence, or '
                      'the person is not allowed to leave. Filing from India, '
                      'keep the passport number, the visa, the employer\'s '
                      'name and address, and the agent\'s name to hand.',
              tone: ToolTone.bad,
              icon: Icons.support_agent_outlined,
            )
          else ...[
            ToolAnswer(
              headline: hi
                  ? 'पहले एजेंट को पोर्टल पर देखें'
                  : 'Look the agent up on the portal first',
              detail: hi
                  ? 'eMigrate पर पंजीकृत भर्ती एजेंटों की सूची है। एजेंट से उसका '
                      'पंजीकरण नंबर माँगिए और उसे पोर्टल पर मिलाइए — नाम, पता और वैधता '
                      'की तारीख़, तीनों। जो एजेंट नंबर देने से बचे, बात वहीं ख़त्म '
                      'कीजिए। पंजीकृत एजेंट जो सेवा शुल्क ले सकता है, उसकी भी एक सीमा '
                      'तय है; उससे ज़्यादा माँगना अपने आप में शिकायत का विषय है।'
                  : 'eMigrate lists the registered recruiting agents. Ask the '
                      'agent for the registration number and match it on the '
                      'portal - the name, the address and the validity date, '
                      'all three. An agent who avoids giving you the number '
                      'is where the conversation should end. There is also a '
                      'prescribed limit on the service charge a registered '
                      'agent may take; being asked for more is itself a '
                      'complaint.',
              tone: ToolTone.warn,
              icon: Icons.verified_user_outlined,
            ),
            if (_stage == AbroadStage.paperSigned ||
                _stage == AbroadStage.agentFound) ...[
              ToolQuestion(hi ? 'कितना पैसा दिया या माँगा गया' : 'How much was paid or asked for'),
              ToolNumber(
                controller: _paid,
                label: hi ? 'रुपये' : 'Rupees',
                decimal: true,
                maxDigits: 8,
                icon: Icons.currency_rupee,
                onChanged: (_) => setState(() {}),
              ),
              if (paid != null && paid > 0)
                ToolNote(hi
                    ? '₹${paid.round()} — इसकी रसीद लीजिए, नाम और पंजीकरण संख्या के '
                        'साथ। रसीद के बिना दिया गया पैसा वापस दिलाना बहुत मुश्किल हो '
                        'जाता है, और ज़्यादातर मामलों में पैसा रसीद के बिना ही दिया '
                        'जाता है। जो एजेंट रसीद न दे, वह यह बता रहा है कि आगे क्या '
                        'होगा।'
                    : '₹${paid.round()} - get a receipt for it, with the name '
                        'and registration number on it. Money paid without a '
                        'receipt is very hard to recover, and in most cases '
                        'it is paid without one. An agent who will not give a '
                        'receipt is telling you what is coming.'),
            ],
            const SizedBox(height: 14),
            Text(hi ? 'जाने से पहले ये देखें' : 'Check these before leaving',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800)),
            const ToolChecklist(
              storageKey: 'abroad_check_v1',
              items: [
                CheckItem('ra', 'The agent\'s registration number, matched '
                    'on the eMigrate portal',
                    'एजेंट का पंजीकरण नंबर, eMigrate पोर्टल पर मिलाया हुआ'),
                CheckItem('visa', 'A work visa, not a visit or tourist visa',
                    'काम का वीज़ा, घूमने या टूरिस्ट वीज़ा नहीं',
                    noteEn: 'Going on a visit visa to work is how people end '
                        'up with no legal standing at all in that country. '
                        'This is the commonest trap.',
                    noteHi: 'घूमने के वीज़ा पर काम के लिए जाना ही वह रास्ता है जिसमें '
                        'उस देश में कोई क़ानूनी हैसियत ही नहीं रह जाती। यह सबसे आम '
                        'जाल है।'),
                CheckItem('contract', 'The employment contract in writing, '
                    'before leaving - wage, hours, job, duration, who pays '
                    'for the ticket and the visa',
                    'नौकरी का अनुबंध लिखित में, जाने से पहले — वेतन, घंटे, काम, '
                        'अवधि, और टिकट तथा वीज़ा का ख़र्च किसका'),
                CheckItem('offer', 'The job offer verified through the '
                    'Indian mission in that country, where you can',
                    'नौकरी का प्रस्ताव उस देश के भारतीय दूतावास से जाँचा हुआ, जहाँ '
                        'हो सके'),
                CheckItem('insurance', 'The compulsory insurance for '
                    'emigrant workers, and its policy paper',
                    'प्रवासी मज़दूरों का अनिवार्य बीमा, और उसका पॉलिसी काग़ज़'),
                CheckItem('clearance', 'Emigration clearance, if your '
                    'passport requires it for that country',
                    'उत्प्रवास मंज़ूरी, अगर उस देश के लिए आपके पासपोर्ट पर ज़रूरी है'),
                CheckItem('copies', 'Copies of the passport, visa, contract '
                    'and agent receipts left with the family at home',
                    'पासपोर्ट, वीज़ा, अनुबंध और एजेंट की रसीदों की नक़लें घर पर '
                        'परिवार के पास'),
                CheckItem('contacts', 'The Indian mission\'s number in that '
                    'country, and $owrcHelpline, written where the family '
                    'can find them',
                    'उस देश में भारतीय दूतावास का नंबर, और $owrcHelpline, वहाँ '
                        'लिखकर रखें जहाँ परिवार को मिल जाए'),
              ],
            ),
            ToolDonts(
              heading: hi ? 'ये बातें मानें ही नहीं' : 'Never agree to these',
              items: hi
                  ? const [
                      'पासपोर्ट किसी एजेंट या नियोक्ता के पास न छोड़ें। विदेश में '
                          'पासपोर्ट रखना आपका हक़ है, और उसे छीनना अपराध है — यही एक '
                          'चीज़ है जिससे लोग फँसे रह जाते हैं।',
                      'जो काग़ज़ आप पढ़ न सकें, उस पर दस्तख़त न करें। किसी से पढ़वाकर '
                          'समझें, और नक़ल अपने पास रखें।',
                      'घूमने के वीज़ा पर काम के लिए न जाएँ, चाहे एजेंट कहे कि "वहाँ '
                          'बदल जाएगा"',
                      'ज़मीन या गहने बेचकर एजेंट को देने से पहले पंजीकरण की जाँच ज़रूर '
                          'करें — यह लौटाया नहीं जा सकता',
                      'बिना रसीद पैसा न दें',
                      '"पहले पहुँच जाओ, अनुबंध वहाँ बन जाएगा" — यह कभी नहीं',
                    ]
                  : const [
                      'Never leave the passport with an agent or employer. '
                          'Keeping your passport abroad is your right and '
                          'taking it is an offence - it is the single thing '
                          'that keeps people trapped.',
                      'Do not sign a paper you cannot read. Have it read to '
                          'you and keep a copy.',
                      'Do not travel on a visit visa to work, whatever the '
                          'agent says about "changing it there"',
                      'Check the registration before selling land or '
                          'jewellery to pay an agent - that cannot be '
                          'undone',
                      'Never pay without a receipt',
                      '"Get there first, the contract will be made there" - '
                          'never',
                    ],
            ),
            const SourceNote(
                text: 'eMigrate - registered recruiting agents',
                url: _emigrateUrl),
            const SourceNote(
                text: 'MADAD - consular grievances', url: _madadUrl),
          ],
        ],
      ],
    );
  }
}

// --- Skill training ---------------------------------------------------

enum TrainingWant { tradeSkill, selfEmployment, placement, upgradeExisting }

class SkillTrainingPage extends StatefulWidget {
  const SkillTrainingPage({super.key});

  @override
  State<SkillTrainingPage> createState() => _SkillTrainingPageState();
}

class _SkillTrainingPageState extends State<SkillTrainingPage> {
  TrainingWant? _want;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    Widget pick(TrainingWant w, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _want == w,
          onTap: () => setState(() => _want = w),
        );

    return ToolScaffold(
      goal: 8,
      title: hi ? 'नज़दीक मुफ़्त कौशल प्रशिक्षण' : 'Free skill training near me',
      children: [
        ToolNote(hi
            ? 'सरकारी कौशल प्रशिक्षण मुफ़्त होता है, और कई में रहने-खाने तथा वज़ीफ़े '
                'की भी व्यवस्था होती है। जो पैसे माँगे, वह सरकारी कार्यक्रम नहीं है — '
                'या फिर वह आपसे वह पैसा माँग रहा है जो उसे सरकार से मिलता है।'
            : 'Government skill training is free, and several schemes include '
                'board, lodging and a stipend. Anyone charging you is not '
                'running a government programme - or is charging you for what '
                'the government already pays them.'),
        ToolQuestion(hi ? 'क्या चाहते हैं' : 'What are you after'),
        pick(TrainingWant.tradeSkill, 'A trade - electrician, fitter, '
            'tailoring, mobile repair', 'कोई हुनर — इलेक्ट्रिशियन, फ़िटर, सिलाई, '
            'मोबाइल मरम्मत'),
        pick(TrainingWant.selfEmployment, 'To start something of my own',
            'अपना कुछ शुरू करना है'),
        pick(TrainingWant.placement, 'Training that ends in a job',
            'जिसके बाद नौकरी लगे'),
        pick(TrainingWant.upgradeExisting,
            'I already do this work, I want a certificate for it',
            'यह काम मैं पहले से करता हूँ, प्रमाण पत्र चाहिए'),
        if (_want != null) ...[
          ToolAnswer(
            headline: switch (_want!) {
              TrainingWant.tradeSkill =>
                hi ? 'आईटीआई और कौशल भारत के पाठ्यक्रम' : 'An ITI, or a Skill India course',
              TrainingWant.selfEmployment =>
                hi ? 'आरसेटी — मुफ़्त, आवासीय' : 'An RSETI - free and residential',
              TrainingWant.placement =>
                hi ? 'जिन कार्यक्रमों में नौकरी जुड़ी होती है' : 'The programmes that carry placement',
              TrainingWant.upgradeExisting =>
                hi ? 'पहले से आने वाले हुनर का प्रमाणन' : 'Certifying a skill you already have',
            },
            detail: switch (_want!) {
              TrainingWant.tradeSkill => hi
                  ? 'आईटीआई में एक से दो साल के पाठ्यक्रम होते हैं और उनका प्रमाण '
                      'पत्र देश भर में माना जाता है — यह सबसे मज़बूत रास्ता है। '
                      'कौशल भारत के छोटे पाठ्यक्रम कुछ हफ़्तों से कुछ महीनों के होते '
                      'हैं और जल्दी पूरे हो जाते हैं। अप्रेंटिसशिप तीसरा रास्ता है, '
                      'जिसमें सीखते हुए हर महीने वज़ीफ़ा मिलता है।'
                  : 'An ITI runs one and two-year courses and its certificate '
                      'is recognised across the country - the strongest route '
                      'there is. Skill India\'s short courses run from a few '
                      'weeks to a few months and finish quickly. An '
                      'apprenticeship is the third route, and it pays a '
                      'monthly stipend while you learn.',
              TrainingWant.selfEmployment => hi
                  ? 'ग्रामीण स्वरोज़गार प्रशिक्षण संस्थान (RSETI) बैंकों के सहयोग से '
                      'चलते हैं और हर ज़िले में होते हैं। प्रशिक्षण मुफ़्त है, रहना-खाना '
                      'भी, और यह ख़ास तौर पर अपना काम शुरू करने वालों के लिए है — '
                      'डेयरी, सिलाई, ब्यूटी पार्लर, मुर्गीपालन, मोबाइल मरम्मत, और '
                      'ऐसे कई। प्रशिक्षण के बाद बैंक से ऋण जोड़ने में भी मदद मिलती है, '
                      'जो इसका सबसे बड़ा फ़ायदा है।'
                  : 'Rural Self Employment Training Institutes are run with '
                      'the banks and exist in every district. The training is '
                      'free, with board and lodging, and it is built for '
                      'people starting something of their own - dairy, '
                      'tailoring, a beauty parlour, poultry, mobile repair '
                      'and many more. They also help link a bank loan '
                      'afterwards, which is the real advantage.',
              TrainingWant.placement => hi
                  ? 'ग्रामीण युवाओं के लिए दीन दयाल उपाध्याय ग्रामीण कौशल्य योजना '
                      '(DDU-GKY) में प्रशिक्षण के साथ नौकरी लगाने की ज़िम्मेदारी '
                      'प्रशिक्षण देने वाली संस्था की होती है, और उसका एक तय हिस्सा '
                      'पूरा करना उसके लिए अनिवार्य है। कौशल भारत के कई पाठ्यक्रमों में '
                      'भी यह जुड़ा होता है। दाख़िले से पहले यह ज़रूर पूछें: पिछले बैच '
                      'में कितने लोगों की नौकरी लगी, कहाँ, और कितने वेतन पर।'
                  : 'For rural young people, the Deen Dayal Upadhyaya '
                      'Grameen Kaushalya Yojana makes placement the training '
                      'provider\'s responsibility, with a fixed share they '
                      'are required to achieve. Several Skill India courses '
                      'carry it too. Before enrolling, ask this: how many '
                      'from the last batch were placed, where, and at what '
                      'wage.',
              TrainingWant.upgradeExisting => hi
                  ? 'यह सबसे कम जाना-पहचाना रास्ता है और बहुत लोगों के काम का है। '
                      'जो हुनर काम करते-करते सीखा है — राजगीरी, बढ़ईगीरी, सिलाई, '
                      'खाना बनाना — उसका आकलन कराकर प्रमाण पत्र लिया जा सकता है, '
                      'बिना पूरा कोर्स किए। इसे पूर्व शिक्षा की मान्यता (RPL) कहते '
                      'हैं, इसमें कुछ दिन लगते हैं, और प्रमाण पत्र वही होता है। '
                      'ठेकेदार के भरोसे काम पाने वाले मज़दूर के लिए यह काग़ज़ मोल-भाव '
                      'बदल देता है।'
                  : 'The least known route, and a useful one for a great many '
                      'people. A skill picked up by doing the work - masonry, '
                      'carpentry, tailoring, cooking - can be assessed and '
                      'certified without sitting a full course. It is called '
                      'Recognition of Prior Learning, it takes a few days, '
                      'and the certificate is the same one. For a worker who '
                      'gets jobs on a contractor\'s word, that paper changes '
                      'the bargaining.',
            },
            tone: ToolTone.good,
            icon: Icons.school_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'कहाँ पता करें' : 'Where to find it',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'स्किल इंडिया डिजिटल पोर्टल या ऐप पर अपने ज़िले के पाठ्यक्रम और '
                        'केंद्र दिखते हैं।',
                    'ज़िले का आईटीआई — दाख़िले की खिड़की आमतौर पर साल में एक बार खुलती '
                        'है, इसलिए तारीख़ पहले से पूछ लें।',
                    'ज़िले का आरसेटी — बैंक की शाखा में इसका पता मिल जाता है।',
                    'ब्लॉक कार्यालय में ग्रामीण आजीविका मिशन की इकाई, और स्वयं सहायता '
                        'समूह से जुड़ी महिलाओं के लिए अलग पाठ्यक्रम।',
                    'जन शिक्षण संस्थान — कम पढ़े-लिखे और महिलाओं के लिए छोटे, लचीले '
                        'पाठ्यक्रम चलाते हैं।',
                  ]
                : const [
                    'The Skill India Digital portal or app shows the courses '
                        'and centres in your district.',
                    'The district ITI - the admission window usually opens '
                        'once a year, so ask the date in advance.',
                    'The district RSETI - a bank branch has the address.',
                    'The rural livelihoods mission unit at the block office, '
                        'and separate courses for women in self-help '
                        'groups.',
                    'Jan Shikshan Sansthan - short, flexible courses for '
                        'people with little schooling, and for women.',
                  ],
          ),
          ToolDonts(
            heading: hi ? 'दाख़िले से पहले' : 'Before you enrol',
            items: hi
                ? const [
                    'फ़ीस माँगी जाए तो पूछें कि यह कौन सी सरकारी योजना है और उसका नाम '
                        'लिखवाएँ — सरकारी प्रशिक्षण मुफ़्त है',
                    'प्रमाण पत्र किसका मिलेगा, यह पहले पूछें। जिस प्रमाण पत्र को कोई '
                        'नहीं पहचानता, उसका कोई मोल नहीं',
                    '"नौकरी पक्की" का वादा लिखवाएँ, वरना वह वादा नहीं है',
                    'मूल काग़ज़ — अंकपत्र, आधार — किसी संस्थान के पास जमा न करें; '
                        'नक़ल दें',
                    'वज़ीफ़ा मिलने वाला हो तो वह सीधे आपके खाते में आना चाहिए',
                  ]
                : const [
                    'If a fee is asked for, ask which government scheme this '
                        'is and get the name written down - government '
                        'training is free',
                    'Ask whose certificate you will get, before enrolling. A '
                        'certificate nobody recognises is worth nothing',
                    'Get a "job guaranteed" promise in writing, or it is not '
                        'a promise',
                    'Do not deposit original documents - marksheets, '
                        'Aadhaar - with any institute; give copies',
                    'Where there is a stipend, it should come straight to '
                        'your own account',
                  ],
          ),
          const SourceNote(text: 'Skill India Digital', url: _skillIndiaUrl),
          const SourceNote(
              text: 'Directorate General of Training - ITIs and '
                  'apprenticeships',
              url: _dgtUrl),
        ],
      ],
    );
  }
}

// --- Building worker card ---------------------------------------------

class BuildingWorkerCardPage extends StatefulWidget {
  const BuildingWorkerCardPage({super.key});

  @override
  State<BuildingWorkerCardPage> createState() =>
      _BuildingWorkerCardPageState();
}

class _BuildingWorkerCardPageState extends State<BuildingWorkerCardPage> {
  final _age = TextEditingController();
  final _days = TextEditingController();

  @override
  void dispose() {
    _age.dispose();
    _days.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final age = int.tryParse(_age.text.trim());
    final days = int.tryParse(_days.text.trim());
    final ageOk = age != null && age >= bocwMinAge && age <= bocwMaxAge;
    final daysOk = days != null && days >= bocwDaysWorked;
    final fits = ageOk && daysOk;

    return ToolScaffold(
      goal: 8,
      title: hi ? 'निर्माण श्रमिक कार्ड' : 'Building worker card',
      children: [
        ToolNote(hi
            ? 'हर राज्य में निर्माण श्रमिक कल्याण बोर्ड है, और उसके पास निर्माण पर '
                'लगने वाले उपकर (सेस) से जमा हुआ बड़ा कोष होता है — जो ख़र्च ही नहीं '
                'हो पाता, क्योंकि मज़दूर पंजीकृत नहीं होते। पंजीकरण का शुल्क मामूली है '
                'और कार्ड से मिलने वाली मदद बहुत बड़ी। यह उन चीज़ों में है जिनमें '
                'मेहनत कम और फ़ायदा सबसे ज़्यादा है।'
            : 'Every state has a construction workers\' welfare board, '
                'holding a large fund collected as a cess on construction - '
                'which goes unspent, because workers are not registered. The '
                'registration fee is nominal and what the card carries is '
                'substantial. It is one of the highest-return things in this '
                'whole app for the effort involved.'),
        ToolQuestion(hi ? 'दो शर्तें' : 'The two conditions'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _age,
                label: hi ? 'उम्र' : 'Age',
                maxDigits: 3,
                icon: Icons.person_outline,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _days,
                label: hi ? 'पिछले साल में दिन' : 'Days in the last year',
                maxDigits: 3,
                icon: Icons.calendar_today_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        ToolNote(hi
            ? 'पंजीकरण के लिए आमतौर पर उम्र $bocwMinAge से $bocwMaxAge साल के बीच '
                'होनी चाहिए और पिछले बारह महीनों में कम से कम $bocwDaysWorked दिन '
                'निर्माण का काम किया हो। "निर्माण" में राजगीरी, मज़दूरी, बढ़ईगीरी, '
                'प्लंबिंग, बिजली का काम, पेंटिंग, सड़क, पुल, नहर — सब आता है।'
            : 'Registration generally needs an age between $bocwMinAge and '
                '$bocwMaxAge and at least $bocwDaysWorked days of '
                'construction work in the preceding twelve months. '
                '"Construction" covers masonry, labour, carpentry, plumbing, '
                'electrical work, painting, roads, bridges and canals.'),
        if (age != null && days != null) ...[
          ToolAnswer(
            headline: fits
                ? (hi ? 'पंजीकरण हो सकता है' : 'You can register')
                : (!ageOk
                    ? (hi ? 'उम्र की शर्त पूरी नहीं' : 'The age condition is not met')
                    : (hi
                        ? '$bocwDaysWorked दिन पूरे नहीं हो रहे'
                        : 'Short of $bocwDaysWorked days')),
            detail: fits
                ? (hi
                    ? 'अर्ज़ी श्रम विभाग के कार्यालय में या राज्य के श्रम पोर्टल पर '
                        'होती है। एक बार पंजीकृत होने पर हर साल थोड़ा अंशदान देकर कार्ड '
                        'चालू रखना होता है — और यही वह जगह है जहाँ ज़्यादातर कार्ड '
                        'बेकार हो जाते हैं, इसलिए नवीनीकरण की तारीख़ लिख लें।'
                    : 'The application goes to the labour department office or '
                        'the state labour portal. Once registered, a small '
                        'yearly contribution keeps the card live - and that is '
                        'exactly where most cards lapse, so write the renewal '
                        'date down.')
                : (!ageOk
                    ? (hi
                        ? 'पंजीकरण आमतौर पर $bocwMinAge से $bocwMaxAge साल तक होता '
                            'है। $bocwMaxAge के बाद नया पंजीकरण नहीं होता, लेकिन जो '
                            'पहले से पंजीकृत थे उनके लिए पेंशन की व्यवस्था होती है — '
                            'अगर पहले कभी कार्ड बना था तो वह ज़रूर पता कराएँ।'
                        : 'Registration generally runs from $bocwMinAge to '
                            '$bocwMaxAge. After $bocwMaxAge a fresh '
                            'registration is not made, but there is provision '
                            'for a pension for those already registered - so '
                            'if a card was ever made before, do look it up.')
                    : (hi
                        ? '$bocwDaysWorked दिन का हिसाब ठेकेदार या नियोक्ता के '
                            'प्रमाण पत्र से, या कुछ राज्यों में स्वयं घोषणा से भी हो '
                            'जाता है। दिन पूरे होने पर दोबारा आएँ — और तब तक अपने काम '
                            'के दिन एक कॉपी में लिखते रहें, वही सबूत बनता है।'
                        : 'The $bocwDaysWorked days are shown by a certificate '
                            'from the contractor or employer, and in some '
                            'states by a self-declaration. Come back when the '
                            'days are complete - and until then write your '
                            'working days in a notebook, which is what the '
                            'proof is made of.')),
            tone: fits ? ToolTone.good : ToolTone.warn,
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'कार्ड से आमतौर पर क्या मिलता है' : 'What the card usually carries',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            numbered: false,
            steps: hi
                ? const [
                    'दुर्घटना में मृत्यु या अपंगता पर सहायता',
                    'इलाज में मदद, और अस्पताल में भर्ती होने पर',
                    'महिला श्रमिक को प्रसव सहायता',
                    'बच्चों की पढ़ाई के लिए छात्रवृत्ति — पहली कक्षा से उच्च शिक्षा तक',
                    'बेटी की शादी के लिए सहायता',
                    'औज़ार ख़रीदने के लिए मदद',
                    'मकान बनाने के लिए ऋण या सहायता',
                    'साठ साल के बाद पेंशन',
                    'मृत्यु पर अंतिम संस्कार की सहायता',
                  ]
                : const [
                    'Assistance on death or disablement in an accident',
                    'Help with treatment, and on hospitalisation',
                    'Maternity assistance for a woman worker',
                    'Scholarships for children, from class one to higher '
                        'education',
                    'Assistance for a daughter\'s marriage',
                    'Help with buying tools',
                    'A loan or assistance for building a house',
                    'A pension after sixty',
                    'Funeral assistance on death',
                  ],
          ),
          ToolNote(hi
              ? 'हर मद की रक़म राज्य का बोर्ड तय करता है और राज्यों में बहुत अंतर है, '
                  'इसलिए यहाँ कोई रक़म नहीं लिखी गई — अपने राज्य की सूची श्रम कार्यालय '
                  'से माँगें। वह सूची सार्वजनिक है।'
              : 'The amount for each is set by the state board and differs a '
                  'great deal between states, which is why no figures are '
                  'given here - ask the labour office for your state\'s list. '
                  'That list is public.'),
          const SizedBox(height: 10),
          const ToolChecklist(
            storageKey: 'bocw_papers_v1',
            items: [
              CheckItem('aadhaar', 'Aadhaar', 'आधार'),
              CheckItem('age', 'Proof of age', 'उम्र का सबूत'),
              CheckItem('bank', 'Bank passbook in your own name',
                  'अपने नाम की बैंक पासबुक'),
              CheckItem('days', 'Certificate of 90 days\' work from the '
                  'contractor or employer, or a self-declaration where the '
                  'state allows it',
                  'ठेकेदार या नियोक्ता से 90 दिन के काम का प्रमाण पत्र, या जहाँ '
                      'राज्य माने वहाँ स्वयं घोषणा'),
              CheckItem('photo', 'Photographs', 'फ़ोटो'),
              CheckItem('family', 'Family details for the nomination',
                  'नामांकन के लिए परिवार का विवरण',
                  noteEn: 'Fill the nomination in. Without it the family '
                      'cannot claim the accident or death benefit, which is '
                      'the biggest thing the card carries.',
                  noteHi: 'नामांकन भरें। इसके बिना परिवार दुर्घटना या मृत्यु की '
                      'सहायता नहीं ले सकता, जो कार्ड की सबसे बड़ी चीज़ है।'),
              CheckItem('renew', 'Note the renewal date and keep the card '
                  'live', 'नवीनीकरण की तारीख़ लिख लें और कार्ड चालू रखें'),
            ],
          ),
          const SourceNote(
              text: 'Ministry of Labour and Employment - building and other '
                  'construction workers',
              url: _bocwUrl),
        ],
      ],
    );
  }
}
