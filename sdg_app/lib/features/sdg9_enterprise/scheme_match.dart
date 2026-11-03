/// "Which scheme should I ask about?"
///
/// The problem this solves
/// ----------------------
/// There are four or five central schemes a small business can borrow
/// under, their eligibility overlaps, and the differences that matter are
/// buried: PMEGP carries a 15 to 35 per cent subsidy but is **only for new
/// units**, Mudra takes existing businesses but stops at ten lakh,
/// Stand-Up India starts where Mudra ends but only for SC/ST and women
/// founders on a new venture, and SVANidhi is for street vendors and
/// nobody else. Somebody running a shop in a small town has no way to know
/// they are walking past a subsidy they qualify for.
///
/// What this is NOT
/// ----------------
/// It is not a loan approval, a prediction of one, or advice on whether to
/// borrow. It matches stated facts against published eligibility rules and
/// names the scheme to ask about. The bank decides the rest on the
/// applicant's papers and repayment capacity, and the UI says so on the
/// same screen as the result.
///
/// Eligibility is a filter here, unlike the scholarship matcher in SDG 4
/// where income only ever flags. The difference is that a scholarship
/// wrongly hidden costs a student the chance to apply, while a scheme
/// wrongly suggested sends someone to a bank with papers that will be
/// rejected at the counter — and PMEGP's "existing units are not eligible"
/// is a hard rule in the guidelines, not a preference. Where a rule is
/// hard, the scheme is excluded with the reason shown; where a rule is
/// conditional, the scheme is listed with the condition attached.
library;

enum WorkKind {
  streetVending,
  shopOrService,
  manufacturing,
  alliedAgri,
}

enum UnitStage { newUnit, existingUnit }

enum NeedBand { upto50k, upto5L, upto10L, above10L }

/// Only the distinction the schemes themselves draw. PMEGP's "special
/// category" and Stand-Up India's eligibility both turn on it.
enum FounderCategory { general, scStOrWoman }

enum UdyamStatus { registered, notRegistered, doNotKnow }

class SchemeMatch {
  final String id;
  final String name;
  final String nameHi;

  /// Why this one came up, in the applicant's own terms.
  final String why;
  final String whyHi;

  /// A condition they still have to satisfy, if any.
  final String? condition;
  final String? conditionHi;

  /// True when this is the strongest fit, so the UI can lead with it.
  final bool primary;

  final String portal;

  const SchemeMatch({
    required this.id,
    required this.name,
    required this.nameHi,
    required this.why,
    required this.whyHi,
    required this.portal,
    this.condition,
    this.conditionHi,
    this.primary = false,
  });
}

class SchemeExclusion {
  final String name;
  final String nameHi;
  final String reason;
  final String reasonHi;

  const SchemeExclusion({
    required this.name,
    required this.nameHi,
    required this.reason,
    required this.reasonHi,
  });
}

class SchemeResult {
  final List<SchemeMatch> matches;

  /// Named explicitly. Someone who has heard of PMEGP needs to know why it
  /// is not on their list, or they will assume the app missed it.
  final List<SchemeExclusion> excluded;

  /// Set when Udyam registration is the thing to do first.
  final bool udyamFirst;

  const SchemeResult({
    required this.matches,
    required this.excluded,
    required this.udyamFirst,
  });
}

const _svanidhi = 'https://pmsvanidhi.mohua.gov.in/';
const _mudra = 'https://www.mudra.org.in/';
const _pmegp = 'https://www.kviconline.gov.in/pmegpeportal/';
const _standUp = 'https://www.standupmitra.in/';

SchemeResult matchSchemes({
  required WorkKind work,
  required UnitStage stage,
  required NeedBand need,
  required FounderCategory category,
  required UdyamStatus udyam,
}) {
  final matches = <SchemeMatch>[];
  final excluded = <SchemeExclusion>[];

  final isNew = stage == UnitStage.newUnit;
  final special = category == FounderCategory.scStOrWoman;

  // ---- PM SVANidhi: street vendors, and only street vendors -------------
  if (work == WorkKind.streetVending) {
    // SVANidhi's ladder is a working capital loan in tens of thousands, not
    // a business term loan. Matching on occupation alone pointed a vendor
    // who had asked for several lakh at a scheme that tops out near fifty
    // thousand, which reads as the app not having listened.
    final beyondLadder = need != NeedBand.upto50k;
    matches.add(SchemeMatch(
      id: 'svanidhi',
      name: 'PM SVANidhi',
      nameHi: 'पीएम स्वनिधि',
      // Not the lead answer when the vendor has asked for more than the
      // ladder can give. Matching on occupation alone put a fifty-thousand
      // scheme at the top for someone who asked for several lakh, which
      // reads as the app not having listened.
      primary: !beyondLadder,
      portal: _svanidhi,
      why: 'This is the scheme built for street vendors. It is a working '
          'capital loan with no collateral and no margin, given in a ladder '
          '— a first loan, then a larger second one once that is repaid, '
          'then a third. Repay on time and you get an interest subsidy of '
          '7 per cent a year, and there is a cashback of up to Rs 1,200 a '
          'year for digital payments.'
          '${beyondLadder ? " It will not reach the amount you asked for, though — the ladder runs in tens of thousands, so for more than that ask about Mudra on a fixed establishment as well. The two can run together." : ""}',
      whyHi: 'यह योजना ख़ास तौर पर रेहड़ी-पटरी वालों के लिए बनी है। यह बिना '
          'गारंटी और बिना मार्जिन का कार्यशील पूँजी ऋण है, जो सीढ़ी की तरह '
          'मिलता है — पहला ऋण, चुकाने पर उससे बड़ा दूसरा, फिर तीसरा। समय पर '
          'चुकाने पर साल में 7 प्रतिशत ब्याज सब्सिडी मिलती है, और डिजिटल '
          'भुगतान पर साल में 1,200 रुपये तक कैशबैक।'
          '${beyondLadder ? " लेकिन यह आपकी माँगी रक़म तक नहीं पहुँचेगी — यह सीढ़ी हज़ारों में चलती है, इसलिए उससे ज़्यादा के लिए किसी स्थायी प्रतिष्ठान पर मुद्रा के बारे में भी पूछें। दोनों साथ चल सकती हैं।" : ""}',
      condition: 'Eligibility is tied to vending in an urban area on or '
          'before 24 March 2020. If you started later, ask your urban local '
          'body what applies to you now rather than assuming you are out.',
      conditionHi: 'पात्रता 24 मार्च 2020 तक शहरी क्षेत्र में रेहड़ी लगाने '
          'से जुड़ी है। आपने बाद में शुरू किया है तो यह मानकर पीछे न हटें '
          'कि आप बाहर हैं — अपने नगर निकाय से पूछें कि अब आप पर क्या लागू है।',
    ));
  }

  // ---- PMEGP: subsidy, but new units only -------------------------------
  final pmegpWork = work == WorkKind.manufacturing ||
      work == WorkKind.shopOrService ||
      work == WorkKind.alliedAgri;

  if (pmegpWork && isNew) {
    matches.add(SchemeMatch(
      id: 'pmegp',
      name: 'PMEGP',
      nameHi: 'पीएमईजीपी',
      primary: true,
      portal: _pmegp,
      why: 'Worth asking about first, because PMEGP is the one that gives '
          'you money you do not repay. The government pays a margin money '
          'subsidy of ${special ? "25 per cent in a town and 35 per cent in a village, for SC/ST, OBC, minority, women, ex-servicemen and differently-abled applicants" : "15 per cent in a town and 25 per cent in a village"}, '
          'and your own contribution is ${special ? "5" : "10"} per cent of '
          'the project cost. You must be over 18.',
      whyHi: 'पहले इसी के बारे में पूछें, क्योंकि पीएमईजीपी में ऐसा पैसा '
          'मिलता है जो लौटाना नहीं पड़ता। सरकार मार्जिन मनी सब्सिडी देती है — '
          '${special ? "अनुसूचित जाति/जनजाति, ओबीसी, अल्पसंख्यक, महिला, भूतपूर्व सैनिक और दिव्यांग आवेदकों के लिए शहर में 25 प्रतिशत और गाँव में 35 प्रतिशत" : "शहर में 15 प्रतिशत और गाँव में 25 प्रतिशत"}, '
          'और आपका ख़ुद का योगदान परियोजना लागत का ${special ? "5" : "10"} '
          'प्रतिशत। आपकी उम्र 18 से ऊपर होनी चाहिए।',
      condition: 'The maximum project cost has been revised more than once, '
          'so confirm the current ceiling on the KVIC portal before you '
          'plan around a figure. A class VIII pass is required for larger '
          'projects.',
      conditionHi: 'अधिकतम परियोजना लागत एक से ज़्यादा बार बदली है, इसलिए '
          'किसी आँकड़े के हिसाब से योजना बनाने से पहले केवीआईसी पोर्टल पर '
          'मौजूदा सीमा देख लें। बड़ी परियोजनाओं के लिए आठवीं पास ज़रूरी है।',
    ));
  } else if (pmegpWork && !isNew) {
    excluded.add(const SchemeExclusion(
      name: 'PMEGP',
      nameHi: 'पीएमईजीपी',
      reason: 'PMEGP is for setting up a new unit. The guidelines say '
          'existing or old units are not eligible, and neither is anyone '
          'who has already taken a subsidy under PMRY, REGP or another '
          'central or state scheme. This is a hard rule, not a preference.',
      reasonHi: 'पीएमईजीपी नई इकाई लगाने के लिए है। दिशानिर्देश कहते हैं कि '
          'मौजूदा या पुरानी इकाइयाँ पात्र नहीं हैं, और वे भी नहीं जिन्होंने '
          'पीएमआरवाई, आरईजीपी या किसी अन्य केंद्रीय या राज्य योजना में '
          'सब्सिडी ले ली है। यह सख़्त नियम है, पसंद का मामला नहीं।',
    ));
  }

  // ---- Mudra: the broad one, up to ten lakh -----------------------------
  //
  // Street vendors are included once they need more than the SVANidhi
  // ladder covers. A vendor with a fixed stall is a micro enterprise, and
  // Mudra's target group is exactly non-corporate, non-farm small business.
  final mudraWork = work != WorkKind.streetVending || need != NeedBand.upto50k;
  if (mudraWork && need != NeedBand.above10L) {
    final band = switch (need) {
      NeedBand.upto50k => ('Shishu', 'शिशु', 'up to Rs 50,000',
          '50,000 रुपये तक'),
      NeedBand.upto5L => ('Kishore', 'किशोर',
          'Rs 50,001 to Rs 5 lakh', '50,001 से 5 लाख रुपये'),
      _ => ('Tarun', 'तरुण', 'Rs 5 lakh to Rs 10 lakh',
          '5 लाख से 10 लाख रुपये'),
    };
    matches.add(SchemeMatch(
      id: 'mudra',
      name: 'Mudra — ${band.$1}',
      nameHi: 'मुद्रा — ${band.$2}',
      primary: !isNew || work == WorkKind.alliedAgri,
      portal: _mudra,
      why: 'Mudra takes both new and running businesses, which is what '
          'makes it the usual answer for a shop that already exists. Your '
          'amount falls in the ${band.$1} category, ${band.$3}. No '
          'collateral security is taken — the loan is covered by a '
          'government credit guarantee instead. Margin is nil for the '
          'smallest loans and around 20 per cent above that, and the '
          'processing fee depends on the bank and the category, so ask for '
          'it in writing.',
      whyHi: 'मुद्रा नए और चल रहे दोनों कारोबारों को लेती है, इसीलिए पहले से '
          'चल रही दुकान के लिए यही आम जवाब है। आपकी रक़म ${band.$2} श्रेणी '
          'में आती है, ${band.$4}। कोई गारंटी नहीं ली जाती — उसकी जगह ऋण पर '
          'सरकारी क्रेडिट गारंटी होती है। सबसे छोटे ऋण पर मार्जिन शून्य और '
          'उससे ऊपर लगभग 20 प्रतिशत, और प्रोसेसिंग फ़ीस बैंक और श्रेणी पर '
          'निर्भर करती है, इसलिए उसे लिखित में पूछें।',
    ));
  } else if (mudraWork && need == NeedBand.above10L) {
    excluded.add(const SchemeExclusion(
      name: 'Mudra',
      nameHi: 'मुद्रा',
      reason: 'Mudra tops out at ten lakh across its three categories, so '
          'it does not cover what you said you need.',
      reasonHi: 'मुद्रा की तीनों श्रेणियाँ मिलाकर अधिकतम दस लाख तक जाती '
          'हैं, इसलिए यह आपकी बताई ज़रूरत को पूरा नहीं करती।',
    ));
  }

  // ---- Stand-Up India: starts where Mudra stops -------------------------
  if (need == NeedBand.above10L && special && isNew) {
    matches.add(const SchemeMatch(
      id: 'standup',
      name: 'Stand-Up India',
      nameHi: 'स्टैंड-अप इंडिया',
      primary: true,
      portal: _standUp,
      why: 'This is the one designed for the gap above Mudra: bank loans '
          'from ten lakh upward for SC, ST and women entrepreneurs setting '
          'up a new venture. Ask at any scheduled commercial bank branch, '
          'or start on the Stand-Up Mitra portal.',
      whyHi: 'यह ठीक उसी खाई के लिए बनी है जो मुद्रा के ऊपर है: अनुसूचित '
          'जाति, अनुसूचित जनजाति और महिला उद्यमियों को नया उद्यम लगाने के '
          'लिए दस लाख से ऊपर का बैंक ऋण। किसी भी अनुसूचित वाणिज्यिक बैंक की '
          'शाखा में पूछें, या स्टैंड-अप मित्र पोर्टल से शुरू करें।',
    ));
  } else if (need == NeedBand.above10L && !special) {
    excluded.add(const SchemeExclusion(
      name: 'Stand-Up India',
      nameHi: 'स्टैंड-अप इंडिया',
      reason: 'Stand-Up India is reserved for SC, ST and women '
          'entrepreneurs. Above ten lakh and outside those categories, you '
          'are looking at an ordinary MSME term loan, where Udyam '
          'registration and a written project report do most of the work.',
      reasonHi: 'स्टैंड-अप इंडिया अनुसूचित जाति, अनुसूचित जनजाति और महिला '
          'उद्यमियों के लिए आरक्षित है। दस लाख से ऊपर और इन श्रेणियों के '
          'बाहर, बात सामान्य एमएसएमई सावधि ऋण की है, जहाँ उद्यम पंजीकरण और '
          'लिखित परियोजना रिपोर्ट सबसे ज़्यादा काम आती है।',
    ));
  } else if (need == NeedBand.above10L && special && !isNew) {
    excluded.add(const SchemeExclusion(
      name: 'Stand-Up India',
      nameHi: 'स्टैंड-अप इंडिया',
      reason: 'Stand-Up India funds a new venture rather than an existing '
          'one. For a running business above ten lakh, ask the bank about '
          'an MSME term loan against your Udyam registration.',
      reasonHi: 'स्टैंड-अप इंडिया मौजूदा की जगह नए उद्यम को वित्त देती है। '
          'दस लाख से ऊपर चल रहे कारोबार के लिए बैंक से अपने उद्यम पंजीकरण '
          'पर एमएसएमई सावधि ऋण के बारे में पूछें।',
    ));
  }

  // No named scheme fits — a running business asking for more than ten
  // lakh outside the Stand-Up India categories. The honest answer is not
  // "nothing": it is an ordinary MSME term loan, which is what the Udyam
  // registration and a written project report exist for. Leaving the
  // screen empty here would read as a dead end when there isn't one.
  if (matches.isEmpty) {
    matches.add(const SchemeMatch(
      id: 'msme-term',
      name: 'An ordinary MSME term loan',
      nameHi: 'सामान्य एमएसएमई सावधि ऋण',
      primary: true,
      portal: 'https://www.jansamarth.in/',
      why: 'No special scheme fits what you described, and that is not a '
          'dead end — it means the normal route applies. Any bank lends to '
          'a registered micro or small enterprise on its own merits, and '
          'what decides it is your Udyam registration, your books and bank '
          'statements, and a written project report showing what the money '
          'is for and how it will be repaid. Jan Samarth is a single window '
          'that checks you against several government loan schemes at once, '
          'so start there before going branch to branch.',
      whyHi: 'आपने जो बताया उस पर कोई विशेष योजना लागू नहीं होती, और यह '
          'रास्ता बंद होना नहीं है — इसका मतलब सामान्य रास्ता लागू है। कोई '
          'भी बैंक पंजीकृत सूक्ष्म या लघु उद्यम को उसकी ख़ुद की योग्यता पर '
          'ऋण देता है, और फ़ैसला आपके उद्यम पंजीकरण, आपके खाते-बही और बैंक '
          'स्टेटमेंट, तथा लिखित परियोजना रिपोर्ट से होता है जिसमें बताया हो '
          'कि पैसा किस काम का है और कैसे लौटेगा। जन समर्थ एक ही खिड़की है जो '
          'आपको कई सरकारी ऋण योजनाओं पर एक साथ जाँचती है, इसलिए शाखा-शाखा '
          'घूमने से पहले वहाँ से शुरू करें।',
      condition: 'Udyam registration is the first step and it is free.',
      conditionHi: 'उद्यम पंजीकरण पहला क़दम है और वह मुफ़्त है।',
    ));
  }

  return SchemeResult(
    matches: matches,
    excluded: excluded,
    // A street vendor borrowing under SVANidhi does not need Udyam, so the
    // prompt would be noise. Everyone else benefits from it, and it is free.
    udyamFirst: work != WorkKind.streetVending &&
        udyam != UdyamStatus.registered,
  );
}
