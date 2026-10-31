/// "Is my drinking water safe?"
///
/// The reasoning lives in Dart with its justification in comments, not in
/// JSON, for the same reason the food-safety check does: getting this wrong
/// makes someone ill, so the logic should be reviewable in one place rather
/// than editable from a phone.
///
/// The thing this tool exists to get right
/// ---------------------------------------
/// Almost every "clean water" guide in India says *boil it*. For germs that
/// is correct and life-saving. For arsenic and fluoride it is useless, and
/// worse than useless as advice, because:
///
///   * Boiling removes no chemicals at all (CDC states this plainly). Some
///     water leaves as steam while the arsenic stays, so the water left in
///     the pot is, if anything, slightly more concentrated.
///   * Arsenic is colourless, odourless and tasteless, so the water looks
///     and tastes perfectly fine (India Water Portal).
///   * Arsenic damage takes 5-10 years to show. Nobody gets a warning that
///     their daily boiling routine is not protecting them.
///
/// So this check tracks two risks separately and never collapses them into
/// one score: a germ problem and a chemical problem need opposite actions,
/// and the common advice is actively misleading for the second.
///
/// It also never returns "your water is safe". It cannot know that. The most
/// positive verdict available is "nothing visible is wrong, and only a test
/// can tell you more" - because for the contaminant that kills slowest,
/// there is nothing to see.
library;

enum WaterSource {
  pipedTap,
  handpumpBorewell,
  openWell,
  tanker,
  surfaceWater,
}

enum WaterLook { clear, cloudy, colouredOrSmelly }

enum WaterTested { never, testedSafe, testedProblem }

/// What the household knows about the area, which is often more reliable
/// than what they can see. Chemical contamination follows geology, so
/// neighbours and the Gram Panchayat usually know before any individual does.
enum AreaProblem { none, arsenic, fluoride, iron, dontKnow }

enum WaterVerdict {
  /// A chemical problem is known or strongly indicated. Boiling is the
  /// wrong answer and saying so is the whole point of this screen.
  chemical,

  /// Germs are likely. Boiling or chlorination genuinely fixes this.
  microbial,

  /// Both. The chemical side dictates the treatment, because boiling
  /// would handle the germs while leaving the slower harm untouched.
  both,

  /// Groundwater that has never been tested. No red flags, but no
  /// information either - and this is the case most people are in.
  untested,

  /// Tested safe, piped, nothing visible wrong. Still not "safe" - just
  /// nothing found, with a date attached to that finding.
  nothingVisible,
}

class WaterAnswer {
  final WaterVerdict verdict;

  /// One line, in the user's face, before any explanation.
  final String headline;
  final String headlineHi;

  /// Why this verdict, in plain terms.
  final String reason;
  final String reasonHi;

  /// What to actually do, in order.
  final List<String> steps;
  final List<String> stepsHi;

  /// Set when boiling is specifically NOT the fix, so the UI can show the
  /// correction prominently instead of burying it in a list.
  final bool boilingWillNotHelp;

  const WaterAnswer({
    required this.verdict,
    required this.headline,
    required this.headlineHi,
    required this.reason,
    required this.reasonHi,
    required this.steps,
    required this.stepsHi,
    this.boilingWillNotHelp = false,
  });
}

/// True for sources drawn from underground, where arsenic and fluoride come
/// from the rock itself rather than from anything that happened upstream.
bool _isGroundwater(WaterSource s) =>
    s == WaterSource.handpumpBorewell || s == WaterSource.openWell;

WaterAnswer assessWater({
  required WaterSource source,
  required WaterLook look,
  required WaterTested tested,
  required AreaProblem area,
  required bool illnessInHouse,
  required bool sewageOrFloodNearby,
}) {
  // ---- chemical risk -----------------------------------------------------
  // Treated as present when it is known, not merely possible. A "maybe"
  // becomes `untested` instead, because telling everyone on a handpump that
  // they have arsenic would teach them to ignore the warning.
  //
  // Iron counts here too. Its health risk is far lower than arsenic or
  // fluoride - it mostly stains clothes and spoils the taste - but it is
  // equally immune to boiling, and leaving it out sent anyone who answered
  // "yes, iron" into the `untested` branch, which then told them nothing had
  // been tested moments after they said a problem was known. The verdict
  // text below distinguishes the three rather than alarming people about
  // iron in the language reserved for arsenic.
  final chemicalKnown = area == AreaProblem.arsenic ||
      area == AreaProblem.fluoride ||
      area == AreaProblem.iron ||
      tested == WaterTested.testedProblem;

  // A past clear test does not clear a known arsenic area, because the
  // routine 9-parameter village kit does not test for arsenic at all. "It
  // was tested and it was fine" is exactly how someone in an affected belt
  // ends up reassured by a test that never looked.
  final testedButMaybeNotForArsenic =
      tested == WaterTested.testedSafe && area == AreaProblem.arsenic;

  // ---- microbial risk ----------------------------------------------------
  // Any one of these is enough. Unlike the job-scam checker there is no
  // scoring here: a single sewage-contaminated source is not made safer by
  // the absence of other signs.
  final microbial = source == WaterSource.surfaceWater ||
      look != WaterLook.clear ||
      illnessInHouse ||
      sewageOrFloodNearby ||
      source == WaterSource.openWell;

  if (chemicalKnown && microbial) {
    return const WaterAnswer(
      verdict: WaterVerdict.both,
      boilingWillNotHelp: true,
      headline: 'Two separate problems. Do not rely on boiling.',
      headlineHi: 'दो अलग-अलग समस्याएँ। उबालने पर भरोसा न करें।',
      reason: 'There are signs of germs AND a known chemical problem. '
          'Boiling kills the germs but removes no chemicals at all, so '
          'boiled water from this source is still not safe to drink every '
          'day. Until you have another source, use this one for washing '
          'only.',
      reasonHi: 'कीटाणु के संकेत भी हैं और रासायनिक समस्या भी पता है। '
          'उबालने से कीटाणु मर जाते हैं, लेकिन रसायन ज़रा भी नहीं निकलते। '
          'इसलिए इस पानी को उबालकर भी रोज़ पीना सुरक्षित नहीं है। दूसरा '
          'स्रोत मिलने तक इसे सिर्फ़ धोने-नहाने के लिए इस्तेमाल करें।',
      steps: [
        'Switch your drinking and cooking water to another source today, '
            'even if that means carrying it further',
        'Tell your Gram Panchayat or Pani Samiti that the source has both '
            'a chemical problem and signs of contamination',
        'Ask for a laboratory test, not only a field test kit',
        'For washing and bathing this water is still usable',
      ],
      stepsHi: [
        'आज ही पीने और खाना बनाने का पानी दूसरे स्रोत से लें, भले दूर से '
            'लाना पड़े',
        'ग्राम पंचायत या पानी समिति को बताएँ कि स्रोत में रासायनिक समस्या '
            'और गंदगी दोनों के संकेत हैं',
        'सिर्फ़ फ़ील्ड टेस्ट किट नहीं, प्रयोगशाला जाँच के लिए कहें',
        'धोने और नहाने के लिए यह पानी इस्तेमाल किया जा सकता है',
      ],
    );
  }

  if (chemicalKnown) {
    final isFluoride = area == AreaProblem.fluoride;
    final isIron = area == AreaProblem.iron;

    // Iron gets its own, calmer verdict. Treating a staining problem with
    // cancer language would be both wrong and the fastest way to make
    // someone distrust the warning that does matter.
    if (isIron) {
      return const WaterAnswer(
        verdict: WaterVerdict.chemical,
        boilingWillNotHelp: true,
        headline: 'Iron: a nuisance more than a danger — but boiling will '
            'not shift it.',
        headlineHi: 'लोहा: ख़तरे से ज़्यादा परेशानी — लेकिन उबालने से नहीं '
            'जाता।',
        reason: 'Iron in groundwater stains clothes and vessels, spoils the '
            'taste and leaves a reddish-brown deposit. At the levels usually '
            'found it is far less harmful than arsenic or fluoride, so this '
            'is not an emergency. It is dissolved in the water though, so '
            'boiling and ordinary filters do not remove it. Worth knowing: '
            'iron is one of the nine things the free village kit does test, '
            'so a proper reading is easy to get.',
        reasonHi: 'भूजल में लोहा कपड़ों और बर्तनों पर दाग़ डालता है, स्वाद '
            'ख़राब करता है और लाल-भूरी तलछट छोड़ता है। आम तौर पर मिलने वाली '
            'मात्रा में यह आर्सेनिक या फ़्लोराइड से बहुत कम नुक़सानदेह है, '
            'इसलिए यह आपात स्थिति नहीं है। लेकिन यह पानी में घुला होता है, '
            'इसलिए उबालने और साधारण फ़िल्टर से नहीं निकलता। ध्यान दें: लोहा '
            'उन नौ चीज़ों में है जिन्हें मुफ़्त गाँव किट जाँचती है, इसलिए '
            'सही रीडिंग लेना आसान है।',
        steps: [
          'Get the free village kit reading, so you know the actual level '
              'rather than judging by the stains',
          'Letting water stand in a wide vessel and settle removes some '
              'iron, because it oxidises on contact with air',
          'An iron removal filter at the handpump is the usual fix, and the '
              'Panchayat may already run a scheme for it',
          'If the same source also shows arsenic, that changes everything — '
              'ask for the arsenic test by name, since the standard kit '
              'does not cover it',
        ],
        stepsHi: [
          'मुफ़्त गाँव किट से रीडिंग लें, जिससे दाग़ देखकर अंदाज़ा लगाने की '
              'जगह असली मात्रा पता चले',
          'चौड़े बर्तन में पानी रखकर जमने देने से कुछ लोहा निकल जाता है, '
              'क्योंकि हवा लगने पर वह ऑक्सीकृत हो जाता है',
          'हैंडपंप पर आयरन रिमूवल फ़िल्टर आम समाधान है, और पंचायत के पास '
              'इसकी योजना हो सकती है',
          'अगर उसी स्रोत में आर्सेनिक भी मिले तो बात पूरी बदल जाती है — '
              'आर्सेनिक जाँच नाम लेकर माँगें, क्योंकि आम किट उसे नहीं जाँचती',
        ],
      );
    }

    return WaterAnswer(
      verdict: WaterVerdict.chemical,
      boilingWillNotHelp: true,
      headline: 'Boiling will not make this water safe.',
      headlineHi: 'उबालने से यह पानी सुरक्षित नहीं होगा।',
      reason: isFluoride
          ? 'Fluoride is a chemical in the rock, not a germ. Boiling does '
              'not remove it. Too much fluoride over years damages teeth '
              'and bones, and children are affected most.'
          : testedButMaybeNotForArsenic
              ? 'You have said the water tested clear, and that this area '
                  'has arsenic. Both can be true at once: the routine '
                  'village kit checks nine things and arsenic is not one of '
                  'them, so a clear result may simply never have looked. '
                  'Boiling would not help either way — arsenic is a '
                  'chemical, and it is invisible and tasteless.'
              : 'Arsenic and other chemicals in groundwater are not germs. '
                  'Boiling does not remove them. The water can look, smell '
                  'and taste completely normal and still be harmful, and '
                  'the damage builds up over years rather than days.',
      reasonHi: isFluoride
          ? 'फ़्लोराइड चट्टान में मौजूद रसायन है, कीटाणु नहीं। उबालने से यह '
              'नहीं निकलता। सालों तक ज़्यादा फ़्लोराइड दाँतों और हड्डियों को '
              'नुक़सान पहुँचाता है, और बच्चों पर सबसे ज़्यादा असर होता है।'
          : testedButMaybeNotForArsenic
              ? 'आपने बताया कि जाँच में कुछ नहीं मिला, और यह भी कि इस '
                  'इलाक़े में आर्सेनिक है। दोनों एक साथ सच हो सकते हैं: आम '
                  'गाँव किट नौ चीज़ें जाँचती है और आर्सेनिक उनमें नहीं है, '
                  'इसलिए हो सकता है कि साफ़ नतीजे में उसे देखा ही न गया हो। '
                  'उबालने से किसी भी हाल में फ़र्क़ नहीं पड़ेगा — आर्सेनिक '
                  'रसायन है, और वह अदृश्य और स्वादहीन है।'
              : 'भूजल में आर्सेनिक जैसे रसायन कीटाणु नहीं होते। उबालने से ये '
                  'नहीं निकलते। पानी देखने, सूँघने और स्वाद में पूरी तरह ठीक '
                  'लग सकता है और फिर भी नुक़सानदेह हो सकता है — और असर दिनों '
                  'में नहीं, सालों में दिखता है।',
      steps: const [
        'Use a different source for drinking and cooking — a piped supply, '
            'a tested deep borewell, or a source the Panchayat confirms',
        'Get a laboratory test. The standard 9-parameter field kit checks '
            'fluoride but NOT arsenic — ask for an arsenic test by name',
        'Report it to your Gram Panchayat or Pani Samiti so the whole '
            'village source gets looked at, not just your house',
        'If a removal filter is installed, it only works while it is '
            'maintained — find out who services it and how often',
        'An ordinary cloth, candle or ceramic filter does not remove these '
            'chemicals',
      ],
      stepsHi: const [
        'पीने और खाना बनाने के लिए दूसरा स्रोत इस्तेमाल करें — नल का पानी, '
            'जाँचा हुआ गहरा बोरवेल, या पंचायत द्वारा पुष्ट स्रोत',
        'प्रयोगशाला जाँच कराएँ। आम 9-पैरामीटर फ़ील्ड किट फ़्लोराइड जाँचती '
            'है, आर्सेनिक नहीं — आर्सेनिक जाँच अलग से माँगें',
        'ग्राम पंचायत या पानी समिति को बताएँ, जिससे पूरे गाँव का स्रोत '
            'जाँचा जाए, सिर्फ़ आपका घर नहीं',
        'अगर फ़िल्टर लगा है, तो वह रखरखाव के बिना काम नहीं करता — पता करें '
            'कौन और कितने दिन में सर्विस करता है',
        'साधारण कपड़ा, कैंडल या सेरेमिक फ़िल्टर इन रसायनों को नहीं हटाता',
      ],
    );
  }

  if (microbial) {
    // Only here is boiling the right answer, and this is the one branch
    // where the familiar advice is also the correct advice.
    final urgent = illnessInHouse || sewageOrFloodNearby;
    return WaterAnswer(
      verdict: WaterVerdict.microbial,
      headline: urgent
          ? 'Treat every drop you drink, starting now.'
          : 'This water needs treating before you drink it.',
      headlineHi: urgent
          ? 'अभी से पीने का हर घूँट उपचारित करें।'
          : 'पीने से पहले इस पानी का उपचार ज़रूरी है।',
      reason: urgent
          ? 'Illness in the house or sewage and flood water near the source '
              'both point to germs getting into your water. This is the one '
              'kind of contamination boiling genuinely fixes.'
          : 'The source or the appearance of the water suggests germs may '
              'be getting in. Boiling or chlorination handles this.',
      reasonHi: urgent
          ? 'घर में बीमारी, या स्रोत के पास नाली और बाढ़ का पानी — दोनों '
              'बताते हैं कि पानी में कीटाणु आ रहे हैं। यही एक गंदगी है जिसे '
              'उबालना सच में ठीक करता है।'
          : 'स्रोत या पानी का रंग-रूप बताता है कि कीटाणु आ सकते हैं। '
              'उबालना या क्लोरीन डालना इसे ठीक कर देता है।',
      steps: [
        if (look != WaterLook.clear)
          'First let it settle and strain it through clean folded cloth. '
              'Cloth removes mud, not germs — it only makes the next step '
              'work properly',
        'Bring it to a rolling boil and keep it boiling for 1 full minute '
            '(3 minutes if you are high in the hills, above about 2,000 m)',
        'Let it cool in the same covered pot. Pouring it into the old '
            'container puts the germs straight back',
        'Chlorine tablets or drops are the alternative when fuel is short — '
            'follow the dose on the packet and wait the stated time',
        if (illnessInHouse)
          'For diarrhoea, start ORS immediately — fluid loss is what is '
              'dangerous, especially for a child. Call 104 or see an ANM or '
              'ASHA worker',
        'Get the source tested too, so the cause gets fixed rather than '
            'worked around every day',
      ],
      stepsHi: [
        if (look != WaterLook.clear)
          'पहले पानी को जमने दें और साफ़ मोड़े हुए कपड़े से छानें। कपड़ा '
              'मिट्टी हटाता है, कीटाणु नहीं — यह सिर्फ़ अगला क़दम ठीक से '
              'काम करने के लिए है',
        'पानी को तेज़ उबाल पर लाएँ और पूरे 1 मिनट उबलने दें (पहाड़ों में '
            'लगभग 2,000 मीटर से ऊपर 3 मिनट)',
        'उसी ढके बर्तन में ठंडा होने दें। पुराने बर्तन में डालने से कीटाणु '
            'वापस आ जाते हैं',
        'ईंधन कम हो तो क्लोरीन की गोली या बूँदें विकल्प हैं — पैकेट पर दी '
            'मात्रा और समय का पालन करें',
        if (illnessInHouse)
          'दस्त हो तो तुरंत ओआरएस शुरू करें — ख़तरा पानी की कमी से होता है, '
              'ख़ासकर बच्चे में। 104 पर कॉल करें या एएनएम/आशा से मिलें',
        'स्रोत की जाँच भी कराएँ, जिससे कारण ठीक हो, रोज़ जुगाड़ न करना पड़े',
      ],
    );
  }

  if (_isGroundwater(source) && tested != WaterTested.testedSafe) {
    // The most common real situation in rural India: a handpump that looks
    // fine and has never been tested. Saying "probably fine" here would be
    // the single most harmful thing this screen could do.
    return const WaterAnswer(
      verdict: WaterVerdict.untested,
      headline: 'Nothing visible is wrong — but this has never been tested.',
      headlineHi: 'दिखने में कुछ ग़लत नहीं — लेकिन जाँच कभी नहीं हुई।',
      reason: 'Groundwater can carry arsenic or fluoride from the rock with '
          'no change in how it looks, smells or tastes. Clear water is '
          'evidence about mud, not about chemicals. A test is the only way '
          'to know, and the village-level test is free.',
      reasonHi: 'भूजल में चट्टान से आर्सेनिक या फ़्लोराइड आ सकता है और '
          'पानी का रंग, गंध या स्वाद ज़रा भी नहीं बदलता। साफ़ पानी मिट्टी के '
          'बारे में सबूत है, रसायन के बारे में नहीं। जाँच ही एक रास्ता है, '
          'और गाँव स्तर की जाँच मुफ़्त है।',
      steps: [
        'Ask your Gram Panchayat for a field test kit check — five women in '
            'every village are trained for this, and it costs nothing',
        'The standard kit covers 9 things including fluoride and iron, but '
            'NOT arsenic. In the Ganga and Brahmaputra plains ask for the '
            'separate arsenic kit by name',
        'If the kit shows a problem, insist on a laboratory test — kit '
            'results are indicative only',
        'Ask neighbours and the Panchayat whether this area has known '
            'arsenic or fluoride. Geology does not stop at your boundary',
        'Meanwhile, keep the handpump surroundings clean and drained, and '
            'keep toilets and soak pits well away from it',
      ],
      stepsHi: [
        'ग्राम पंचायत से फ़ील्ड टेस्ट किट जाँच के लिए कहें — हर गाँव में '
            'पाँच महिलाएँ इसके लिए प्रशिक्षित हैं, और यह मुफ़्त है',
        'आम किट 9 चीज़ें जाँचती है, जिसमें फ़्लोराइड और लोहा शामिल हैं, पर '
            'आर्सेनिक नहीं। गंगा और ब्रह्मपुत्र के मैदानों में आर्सेनिक की '
            'अलग किट नाम लेकर माँगें',
        'किट में समस्या दिखे तो प्रयोगशाला जाँच पर ज़ोर दें — किट का नतीजा '
            'सिर्फ़ संकेत है',
        'पड़ोसियों और पंचायत से पूछें कि इस इलाक़े में आर्सेनिक या '
            'फ़्लोराइड की जानकारी है या नहीं। भूगर्भ आपकी मेड़ पर नहीं रुकता',
        'तब तक हैंडपंप के आसपास सफ़ाई और पानी की निकासी रखें, और शौचालय व '
            'सोख़्ता गड्ढे उससे दूर रखें',
      ],
    );
  }

  return const WaterAnswer(
    verdict: WaterVerdict.nothingVisible,
    headline: 'No warning signs today.',
    headlineHi: 'आज कोई चेतावनी का संकेत नहीं।',
    reason: 'Nothing in your answers points to a problem right now. That is '
        'not the same as a guarantee — water quality changes with the '
        'season, with repairs to the pipeline, and after any flooding.',
    reasonHi: 'आपके जवाबों में अभी कोई समस्या नहीं दिखती। यह गारंटी नहीं '
        'है — पानी की गुणवत्ता मौसम के साथ, पाइपलाइन की मरम्मत के बाद और '
        'बाढ़ के बाद बदलती है।',
    steps: [
      'Check again after any flood, pipeline repair, or if the water '
          'changes colour, smell or taste',
      'If anyone in the house gets repeated stomach illness, treat the '
          'water and get the source tested',
      'Water quality results for your village are published publicly on '
          'the Jal Jeevan Mission WQMIS portal',
    ],
    stepsHi: [
      'बाढ़, पाइपलाइन की मरम्मत के बाद, या पानी का रंग, गंध या स्वाद बदलने '
          'पर फिर जाँचें',
      'घर में किसी को बार-बार पेट की बीमारी हो, तो पानी का उपचार करें और '
          'स्रोत की जाँच कराएँ',
      'आपके गाँव के पानी की जाँच के नतीजे जल जीवन मिशन के WQMIS पोर्टल पर '
          'सार्वजनिक रूप से उपलब्ध हैं',
    ],
  );
}
