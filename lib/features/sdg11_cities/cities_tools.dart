import '../../core/sdg/advice.dart';

/// SDG 11 decision logic: housing scheme fit, and a municipal complaint
/// that gets an answer.

enum Area { urban, rural }

enum HouseIncome { upTo3Lakh, upTo6Lakh, upTo9Lakh, above9Lakh }

enum HousingNeed { buildOnOwnLand, buy, rent }

const _pmayU = 'https://pmay-urban.gov.in/';
const _pmayG = 'https://pmayg.nic.in/';

const _ownsPucca = Advice(
  title: 'A family that owns a pucca house anywhere is not covered',
  titleHi: 'जिस परिवार का कहीं भी पक्का मकान है, वह शामिल नहीं',
  body: 'PM Awas Yojana is for families with no pucca house anywhere in '
      'India — in the family\'s name or any member\'s. If you own one, '
      'even in another town, the application will be rejected at '
      'verification, and a false declaration can mean returning any money '
      'paid. If the house you own is kutcha or unsafe, say so plainly: '
      'that is a different case, and the local body can tell you whether '
      'it counts.',
  bodyHi: 'प्रधानमंत्री आवास योजना उन परिवारों के लिए है जिनका भारत में कहीं भी पक्का '
      'मकान नहीं है — परिवार के नाम या किसी सदस्य के नाम। अगर आपका है, दूसरे शहर में '
      'भी, तो सत्यापन में आवेदन रद्द होगा, और झूठी घोषणा पर मिला पैसा लौटाना पड़ सकता '
      'है। अगर आपका मकान कच्चा या असुरक्षित है, तो साफ़ बताएँ: वह अलग मामला है, और '
      'स्थानीय निकाय बता सकता है कि वह गिना जाएगा या नहीं।',
  source: _pmayU,
);

const _tooHigh = Advice(
  title: 'Income above Rs 9 lakh is outside PMAY-Urban',
  titleHi: '9 लाख रुपये से ज़्यादा आय पीएमएवाई-शहरी से बाहर',
  body: 'The urban scheme covers families earning up to Rs 9 lakh a year '
      '(EWS up to 3 lakh, LIG 3 to 6 lakh, MIG 6 to 9 lakh). Above that, '
      'look at your state\'s housing board schemes and ordinary home loans.',
  bodyHi: 'शहरी योजना साल में 9 लाख रुपये तक कमाने वाले परिवारों के लिए है '
      '(ईडब्ल्यूएस 3 लाख तक, एलआईजी 3 से 6 लाख, एमआईजी 6 से 9 लाख)। इससे ऊपर '
      'अपने राज्य के आवास बोर्ड की योजनाएँ और सामान्य गृह ऋण देखें।',
  source: _pmayU,
);

const _rural = Advice(
  title: 'PM Awas Yojana – Gramin: through your Gram Panchayat',
  titleHi: 'प्रधानमंत्री आवास योजना – ग्रामीण: ग्राम पंचायत के ज़रिए',
  body: 'In villages, houseless families and families in kutcha or '
      'dilapidated houses are selected from government survey lists, '
      'checked in the Gram Sabha. Ask the Gram Panchayat secretary or the '
      'Block office whether your family is on the list and what stage it '
      'is at; the official site lets you check by registration number. '
      'If you were left off, ask at the Gram Sabha how to be added in the '
      'next survey. You never have to pay anyone to be included.',
  bodyHi: 'गाँवों में बेघर परिवार और कच्चे या जर्जर मकानों वाले परिवार सरकारी सर्वे '
      'सूचियों से चुने जाते हैं, जिनकी जाँच ग्राम सभा में होती है। ग्राम पंचायत सचिव या '
      'ब्लॉक कार्यालय से पूछें कि आपका परिवार सूची में है या नहीं और किस चरण में है; '
      'आधिकारिक साइट पर पंजीकरण संख्या से भी देख सकते हैं। अगर नाम छूट गया, तो ग्राम '
      'सभा में पूछें कि अगले सर्वे में कैसे जुड़ेगा। शामिल होने के लिए किसी को पैसे नहीं '
      'देने होते।',
  source: _pmayG,
);

const _blc = Advice(
  title: 'Build on your own land: Beneficiary-Led Construction',
  titleHi: 'अपनी ज़मीन पर बनाएँ: लाभार्थी आधारित निर्माण',
  body: 'For EWS families (up to Rs 3 lakh a year) who have their own vacant '
      'plot, the government gives money in instalments as the house is '
      'built, checked at each stage with geo-tagged photos. States can also '
      'give land rights (patta) to landless families. Apply through your '
      'urban local body or the PMAY-Urban portal.',
  bodyHi: 'ईडब्ल्यूएस परिवारों (साल में 3 लाख रुपये तक) के लिए जिनके पास अपना ख़ाली '
      'प्लॉट है, सरकार मकान बनने के साथ किस्तों में पैसा देती है, हर चरण पर जियो-टैग '
      'फ़ोटो से जाँच होती है। राज्य भूमिहीन परिवारों को ज़मीन का पट्टा भी दे सकते हैं। '
      'अपने नगर निकाय या पीएमएवाई-शहरी पोर्टल से आवेदन करें।',
  source: _pmayU,
);

const _ahp = Advice(
  title: 'Buy a flat in a government partnership project',
  titleHi: 'सरकारी साझेदारी परियोजना में फ़्लैट ख़रीदें',
  body: 'Affordable Housing in Partnership projects sell homes to EWS '
      'families at a price lowered by government assistance. Your city or '
      'state housing board announces them; allotment is usually by lottery. '
      'Ask your urban local body which projects are open.',
  bodyHi: 'साझेदारी में किफ़ायती आवास परियोजनाएँ ईडब्ल्यूएस परिवारों को सरकारी सहायता से '
      'कम कीमत पर मकान बेचती हैं। आपका शहर या राज्य आवास बोर्ड इनकी घोषणा करता है; '
      'आवंटन आमतौर पर लॉटरी से होता है। अपने नगर निकाय से पूछें कि कौन सी परियोजनाएँ '
      'खुली हैं।',
  source: _pmayU,
);

const _iss = Advice(
  title: 'Interest subsidy on a home loan',
  titleHi: 'गृह ऋण पर ब्याज सब्सिडी',
  body: 'EWS, LIG and MIG families buying or building their first pucca '
      'house can get a 4% interest subsidy on home loans up to Rs 25 lakh, '
      'up to Rs 1.80 lakh in all, paid into the loan account in five yearly '
      'instalments. Ask the bank or housing finance company when you apply '
      'for the loan — it applies for the subsidy on your behalf.',
  bodyHi: 'पहला पक्का मकान ख़रीदने या बनाने वाले ईडब्ल्यूएस, एलआईजी और एमआईजी '
      'परिवारों को 25 लाख रुपये तक के गृह ऋण पर 4% ब्याज सब्सिडी मिल सकती है, कुल '
      '1.80 लाख रुपये तक, जो पाँच सालाना किस्तों में ऋण खाते में आती है। ऋण लेते समय '
      'बैंक या हाउसिंग फ़ाइनेंस कंपनी से पूछें — वही आपकी ओर से सब्सिडी का आवेदन करती है।',
  source: 'https://static.pib.gov.in/WriteReadData/specificdocs/documents/2024/aug/doc2024810372701.pdf',
);

const _arh = Advice(
  title: 'Affordable rental housing',
  titleHi: 'किफ़ायती किराये का आवास',
  body: 'For people who need a place in the city without buying — migrant '
      'workers, industrial workers, working women, students and the like. '
      'Homes are offered on rent in government-funded or partner '
      'complexes. Ask your urban local body or employer whether a project '
      'runs in your city.',
  bodyHi: 'उन लोगों के लिए जिन्हें शहर में ख़रीदे बिना जगह चाहिए — प्रवासी मज़दूर, '
      'औद्योगिक कामगार, कामकाजी महिलाएँ, छात्र आदि। सरकारी या साझेदार परिसरों में मकान '
      'किराये पर मिलते हैं। अपने नगर निकाय या नियोक्ता से पूछें कि आपके शहर में कोई '
      'परियोजना चल रही है या नहीं।',
  source: _pmayU,
);

const _noAgent = Advice(
  title: 'Applying is free — anyone charging a fee is a fraud',
  titleHi: 'आवेदन मुफ़्त है — फ़ीस माँगने वाला ठग है',
  body: 'Fake "PM Awas" agents and websites collect a registration fee and '
      'disappear. The official application costs nothing. Use only the '
      'official portal, your urban local body, or a Common Service Centre, '
      'and never give an OTP to anyone who calls about your application.',
  bodyHi: 'नक़ली "पीएम आवास" एजेंट और वेबसाइटें पंजीकरण फ़ीस लेकर ग़ायब हो जाते हैं। '
      'आधिकारिक आवेदन मुफ़्त है। सिर्फ़ आधिकारिक पोर्टल, अपने नगर निकाय या कॉमन सर्विस '
      'सेंटर का इस्तेमाल करें, और आवेदन के बारे में फ़ोन करने वाले किसी को ओटीपी न दें।',
  source: _pmayU,
);

/// Which part of PM Awas Yojana fits. Never empty, and ends with the fraud
/// warning whenever there is something to apply for.
List<Advice> housingFit({
  required Area area,
  required bool ownsPucca,
  required HouseIncome income,
  required HousingNeed need,
}) {
  if (ownsPucca) return [_ownsPucca];
  if (area == Area.rural) return [_rural, _noAgent];
  if (income == HouseIncome.above9Lakh) return [_tooHigh];

  final ews = income == HouseIncome.upTo3Lakh;
  final out = <Advice>[];
  switch (need) {
    case HousingNeed.buildOnOwnLand:
      if (ews) out.add(_blc);
      out.add(_iss);
    case HousingNeed.buy:
      if (ews) out.add(_ahp);
      out.add(_iss);
    case HousingNeed.rent:
      out.add(_arh);
  }
  out.add(_noAgent);
  return out;
}

// ---------------------------------------------------------------------------
// Municipal complaints

enum CivicIssue { garbage, streetlight, water, drain, road, mosquito }

String issueEn(CivicIssue i) => switch (i) {
      CivicIssue.garbage => 'Garbage not collected',
      CivicIssue.streetlight => 'Streetlight not working',
      CivicIssue.water => 'No water supply, or dirty water',
      CivicIssue.drain => 'Blocked drain or sewage overflow',
      CivicIssue.road => 'Pothole or broken road',
      CivicIssue.mosquito => 'Stagnant water and mosquitoes',
    };

String issueHi(CivicIssue i) => switch (i) {
      CivicIssue.garbage => 'कूड़ा नहीं उठाया जा रहा',
      CivicIssue.streetlight => 'स्ट्रीटलाइट ख़राब',
      CivicIssue.water => 'पानी नहीं आ रहा, या गंदा पानी',
      CivicIssue.drain => 'नाली जाम या सीवर बह रहा',
      CivicIssue.road => 'गड्ढा या टूटी सड़क',
      CivicIssue.mosquito => 'जमा पानी और मच्छर',
    };

/// Why it matters, in one line, because a complaint that states the harm
/// is answered faster than one that only states the fault.
String _harmEn(CivicIssue i) => switch (i) {
      CivicIssue.garbage => 'It is attracting animals and flies and is a health risk.',
      CivicIssue.streetlight => 'The street is dark at night and unsafe, especially for women and children.',
      CivicIssue.water => 'Households have no safe water for drinking and cooking.',
      CivicIssue.drain => 'Sewage is spreading onto the road and into homes, which is a health risk.',
      CivicIssue.road => 'It is causing accidents and damaging vehicles.',
      CivicIssue.mosquito => 'It is breeding mosquitoes, with a risk of dengue and malaria.',
    };

String _harmHi(CivicIssue i) => switch (i) {
      CivicIssue.garbage => 'इससे जानवर और मक्खियाँ आ रही हैं और बीमारी का ख़तरा है।',
      CivicIssue.streetlight => 'रात में गली अँधेरी और असुरक्षित है, ख़ासकर महिलाओं और बच्चों के लिए।',
      CivicIssue.water => 'घरों में पीने और खाना बनाने के लिए सुरक्षित पानी नहीं है।',
      CivicIssue.drain => 'सीवर सड़क पर और घरों में फैल रहा है, जिससे बीमारी का ख़तरा है।',
      CivicIssue.road => 'इससे दुर्घटनाएँ हो रही हैं और गाड़ियाँ ख़राब हो रही हैं।',
      CivicIssue.mosquito => 'इसमें मच्छर पनप रहे हैं, डेंगू और मलेरिया का ख़तरा है।',
    };

/// A complaint ready to paste into an app, portal, WhatsApp number or a
/// letter. Placeholders are filled from what the user typed; empty fields
/// become clearly marked blanks rather than vanishing.
String draftComplaint({
  required CivicIssue issue,
  required String place,
  required String since,
  required bool hi,
}) {
  final p = place.trim().isEmpty ? (hi ? '[जगह लिखें]' : '[write the place]') : place.trim();
  final s = since.trim().isEmpty ? (hi ? '[कब से]' : '[since when]') : since.trim();
  if (hi) {
    return 'विषय: ${issueHi(issue)} — $p\n\n'
        'महोदय/महोदया,\n\n'
        '$p पर ${issueHi(issue)} की समस्या $s से है। ${_harmHi(issue)}\n\n'
        'कृपया इसे जल्द ठीक कराएँ और इस शिकायत की संख्या और ठीक होने की '
        'अनुमानित तारीख़ बताएँ।\n\n'
        'धन्यवाद,\n[नाम]\n[मोबाइल नंबर]';
  }
  return 'Subject: ${issueEn(issue)} — $p\n\n'
      'Sir/Madam,\n\n'
      'At $p there has been a problem since $s: '
      '${issueEn(issue).toLowerCase()}. ${_harmEn(issue)}\n\n'
      'Please have it fixed, and tell me the complaint number and the '
      'expected date it will be resolved.\n\n'
      'Thank you,\n[Name]\n[Mobile number]';
}

/// The escalation ladder. The step that most people skip — writing down
/// the complaint number — is the one every later step depends on.
List<Advice> escalation(Area area, CivicIssue issue) => [
      Advice(
        title: area == Area.urban
            ? '1. Complain to the municipality and note the number'
            : '1. Complain to the Gram Panchayat and note the date',
        titleHi: area == Area.urban
            ? '1. नगर निकाय से शिकायत करें और संख्या लिख लें'
            : '1. ग्राम पंचायत से शिकायत करें और तारीख़ लिख लें',
        body: area == Area.urban
            ? 'Use your city\'s complaint helpline, app or ward office.'
                '${issue == CivicIssue.garbage ? ' For garbage, the Swachhata app of the Ministry of Housing and Urban Affairs sends a photo complaint straight to your city.' : ''}'
                ' Always get a complaint number — without it, nothing below '
                'can be followed up.'
            : 'Give it in writing to the Panchayat secretary or Sarpanch and '
                'keep a copy with the date received, or raise it in the Gram '
                'Sabha so it is minuted.',
        bodyHi: area == Area.urban
            ? 'अपने शहर की शिकायत हेल्पलाइन, ऐप या वार्ड कार्यालय का इस्तेमाल करें।'
                '${issue == CivicIssue.garbage ? ' कूड़े के लिए आवास और शहरी कार्य मंत्रालय का स्वच्छता ऐप फ़ोटो के साथ शिकायत सीधे आपके शहर को भेजता है।' : ''}'
                ' हमेशा शिकायत संख्या लें — उसके बिना आगे का कोई कदम नहीं हो सकता।'
            : 'पंचायत सचिव या सरपंच को लिखकर दें और प्राप्ति की तारीख़ के साथ कॉपी रखें, '
                'या ग्राम सभा में उठाएँ ताकि कार्यवाही में दर्ज हो।',
        source: 'https://www.mohua.gov.in/',
      ),
      const Advice(
        title: '2. Wait the service time, then write higher up',
        titleHi: '2. सेवा का समय रुकें, फिर ऊपर लिखें',
        body: 'Many states have a Right to Public Services law with a fixed '
            'number of days for each service. If it is not fixed in that '
            'time, or in two weeks if you cannot find the limit, write to '
            'the Municipal Commissioner or Executive Officer (in villages, the '
            'Block Development Officer), quoting the complaint number and '
            'date.',
        bodyHi: 'कई राज्यों में लोक सेवा अधिकार क़ानून है, जिसमें हर सेवा के लिए तय दिन '
            'हैं। उतने समय में, या सीमा न पता हो तो दो हफ़्ते में, ठीक न हो तो नगर आयुक्त '
            'या अधिशासी अधिकारी (गाँव में खंड विकास अधिकारी) को शिकायत संख्या और तारीख़ '
            'के साथ लिखें।',
        source: 'https://www.mohua.gov.in/',
      ),
      const Advice(
        title: '3. State grievance portal or CM helpline',
        titleHi: '3. राज्य शिकायत पोर्टल या मुख्यमंत्री हेल्पलाइन',
        body: 'Every state runs a public grievance portal, and most a Chief '
            'Minister\'s helpline. Complaints there are tracked and sent '
            'back to the department with a deadline. Attach the earlier '
            'complaint numbers. (The central CPGRAMS portal is for central '
            'government departments, not your municipality.)',
        bodyHi: 'हर राज्य का जन शिकायत पोर्टल है, और ज़्यादातर में मुख्यमंत्री हेल्पलाइन भी। '
            'वहाँ की शिकायतें ट्रैक होती हैं और समय-सीमा के साथ विभाग को लौटाई जाती हैं। '
            'पुरानी शिकायत संख्याएँ जोड़ें। (केंद्र का सीपीग्राम्स पोर्टल केंद्र सरकार के '
            'विभागों के लिए है, नगर निकाय के लिए नहीं।)',
        source: 'https://pgportal.gov.in/',
      ),
      const Advice(
        title: '4. Ask in writing what happened, under RTI',
        titleHi: '4. आरटीआई में लिखकर पूछें कि क्या हुआ',
        body: 'An RTI application asking for the action taken on your '
            'complaint number, and the officer responsible, has to be '
            'answered within 30 days. It often moves a stuck file by itself. '
            'The Peace & Justice section of this app has an RTI guide.',
        bodyHi: 'आरटीआई आवेदन में अपनी शिकायत संख्या पर हुई कार्रवाई और ज़िम्मेदार अधिकारी '
            'का नाम पूछें — 30 दिन में जवाब देना होता है। अक्सर इसी से अटकी फ़ाइल चल पड़ती '
            'है। इस ऐप के शांति और न्याय हिस्से में आरटीआई गाइड है।',
        source: 'https://rtionline.gov.in/',
      ),
    ];
