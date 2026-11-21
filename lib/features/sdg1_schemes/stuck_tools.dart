import 'package:flutter/material.dart';

import '../../core/sdg/advice.dart';
import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Two screens for the same kind of dead end: a benefit that was supposed
/// to come and did not, where the real obstacle is invisible from outside.
///
/// `PmKisanStuckPage` is PM-KISAN specifically, because its failures are
/// particular to it - land records and e-KYC - and the generic DBT screen
/// cannot name them. `RejectedPage` is for any scheme that said no, where
/// the single most useful act is getting the reason in writing, which is
/// the thing nobody is ever offered and everybody is entitled to.

const _pmKisanUrl = 'https://pmkisan.gov.in/';
const _cpgramsUrl = 'https://pgportal.gov.in/';

// --- PM-KISAN ---------------------------------------------------------

/// What the farmer can see from outside. Each points at a different step.
enum KisanSymptom { neverAny, stopped, lessThanOthers, statusSaysRejected }

const _kisanStatus = Advice(
  title: 'Read your own status page first, and write down its words',
  titleHi: 'पहले अपनी स्थिति पढ़ें, और उसके शब्द लिख लें',
  body: 'On pmkisan.gov.in, under Farmers Corner, "Know Your Status" takes '
      'your registration number or Aadhaar and says exactly where the '
      'instalment stopped. It does not say "pending" and leave it there: it '
      'names the step - e-KYC not done, land record not seeded, Aadhaar not '
      'matching the bank account, or ineligible. Every step below depends on '
      'which of those it says, so write the words down before you go '
      'anywhere.',
  bodyHi: 'pmkisan.gov.in पर Farmers Corner में "Know Your Status" आपका '
      'रजिस्ट्रेशन नंबर या आधार लेकर ठीक-ठीक बताता है कि किस्त कहाँ रुकी है। वह सिर्फ़ '
      '"लंबित" लिखकर नहीं छोड़ता — वह क़दम बताता है: ई-केवाईसी नहीं हुई, ज़मीन का '
      'रिकॉर्ड नहीं जुड़ा, आधार और बैंक खाते का नाम नहीं मिल रहा, या पात्र नहीं। नीचे का '
      'हर क़दम इसी पर निर्भर है, इसलिए कहीं जाने से पहले वे शब्द लिख लें।',
  source: _pmKisanUrl,
);

const _kisanEkyc = Advice(
  title: 'e-KYC, which is the commonest single reason',
  titleHi: 'ई-केवाईसी — सबसे आम वजह यही है',
  body: 'e-KYC is compulsory, and an instalment will not move without it. '
      'The quickest route is OTP e-KYC on the portal or the PM Kisan mobile '
      'app, on the mobile number linked to your Aadhaar. If the OTP does not '
      'reach you, biometric e-KYC at a Common Service Centre does the same '
      'job. Face e-KYC in the app works for people whose fingerprints no '
      'longer read, which is common after years of field work.',
  bodyHi: 'ई-केवाईसी अनिवार्य है, और उसके बिना किस्त आगे नहीं बढ़ती। सबसे तेज़ रास्ता '
      'पोर्टल या PM Kisan ऐप पर ओटीपी ई-केवाईसी है, उसी मोबाइल नंबर पर जो आधार से '
      'जुड़ा है। ओटीपी न आए तो कॉमन सर्विस सेंटर पर बायोमेट्रिक ई-केवाईसी वही काम '
      'करती है। जिनकी उँगलियों के निशान नहीं पढ़े जाते — खेत के काम में यह आम है — '
      'उनके लिए ऐप में फ़ेस ई-केवाईसी है।',
  source: _pmKisanUrl,
);

const _kisanLand = Advice(
  title: 'Land records seeded to your name',
  titleHi: 'ज़मीन का रिकॉर्ड आपके नाम से जुड़ा हो',
  body: 'The scheme pays the person the land is recorded against. If the '
      'khata is still in a father\'s or grandfather\'s name, or the '
      'mutation after a death or a partition was never done, the record '
      'will not seed and the payment stops there - even though the family '
      'has farmed the land for decades. This is a tehsil or revenue-office '
      'job, not a bank one: ask for the mutation, and keep the receipt.',
  bodyHi: 'योजना उसी को पैसा देती है जिसके नाम ज़मीन दर्ज है। अगर खाता अब भी पिता '
      'या दादा के नाम है, या मृत्यु/बँटवारे के बाद दाखिल-ख़ारिज नहीं हुआ, तो रिकॉर्ड '
      'नहीं जुड़ेगा और भुगतान वहीं रुक जाएगा — चाहे परिवार दशकों से वही ज़मीन जोत रहा '
      'हो। यह तहसील या राजस्व कार्यालय का काम है, बैंक का नहीं: दाखिल-ख़ारिज कराएँ '
      'और रसीद रखें।',
  source: _pmKisanUrl,
);

const _kisanName = Advice(
  title: 'The name on Aadhaar and the name at the bank must match',
  titleHi: 'आधार का नाम और बैंक का नाम एक जैसा हो',
  body: 'A middle name on one and not the other, or a spelling the bank '
      'typed differently, is enough to fail the transfer. Fix whichever one '
      'is wrong - and the account must be yours alone or a joint account '
      'in which you are the first holder, with Aadhaar seeded to it for '
      'DBT. A son\'s account will not do, however the money is used at '
      'home.',
  bodyHi: 'एक में मध्य नाम हो और दूसरे में न हो, या बैंक ने हिज्जे अलग लिख दिए हों — '
      'इतना ही भुगतान रोकने के लिए काफ़ी है। जो ग़लत है उसे ठीक कराएँ — और खाता '
      'आपका ही हो, या संयुक्त खाते में आप पहले खातेदार हों, और उसमें आधार डीबीटी के '
      'लिए सीड हो। बेटे का खाता नहीं चलेगा, चाहे पैसा घर में उसी तरह ख़र्च होता हो।',
  source: _pmKisanUrl,
);

const _kisanIneligible = Advice(
  title: 'If the status says ineligible, find out under which head',
  titleHi: 'अगर "अपात्र" लिखा है तो किस आधार पर, यह पूछें',
  body: 'The scheme excludes some households by rule: an income-tax payer '
      'in the family, a serving or retired government employee above the '
      'lower grades, a pensioner drawing over ten thousand rupees a month, '
      'and professionals such as doctors and lawyers in practice. If none '
      'of those is true of your household, the exclusion is a data error, '
      'and it is correctable - take it to the block agriculture officer '
      'with the status printout. Exclusions are often applied to a whole '
      'khata by mistake.',
  bodyHi: 'योजना कुछ परिवारों को नियम से बाहर रखती है: परिवार में आयकर भरने वाला, '
      'निचले ग्रेड से ऊपर का सरकारी कर्मचारी (सेवारत या सेवानिवृत्त), दस हज़ार रुपये '
      'महीने से अधिक पेंशन पाने वाला, और प्रैक्टिस करने वाले डॉक्टर-वकील जैसे पेशेवर। '
      'अगर इनमें से कोई बात आपके परिवार पर लागू नहीं होती, तो यह आँकड़ों की ग़लती है '
      'और सुधर सकती है — स्थिति का प्रिंट लेकर ब्लॉक कृषि अधिकारी के पास जाएँ। पूरे '
      'खाते पर ग़लती से अपात्रता लग जाना आम है।',
  source: _pmKisanUrl,
);

const _kisanHelp = Advice(
  title: 'If the office does not move, use the scheme\'s own helpline',
  titleHi: 'कार्यालय से बात न बने तो योजना की हेल्पलाइन',
  body: 'PM-KISAN runs its own help desk - 155261, and 011-24300606 - and a '
      'grievance form on the portal. Give the registration number, the exact '
      'words the status page used, and the date you first went to the block '
      'office. A complaint that names a date and a person moves; one that '
      'says "my money has not come" does not.',
  bodyHi: 'पीएम-किसान की अपनी हेल्प डेस्क है — 155261 और 011-24300606 — और '
      'पोर्टल पर शिकायत फ़ॉर्म भी। रजिस्ट्रेशन नंबर, स्थिति पृष्ठ के ठीक वही शब्द, और '
      'जिस तारीख़ को पहली बार ब्लॉक कार्यालय गए थे — ये तीनों लिखें। जिस शिकायत में '
      'तारीख़ और नाम होता है वह आगे बढ़ती है; "पैसा नहीं आया" वाली नहीं।',
  source: _pmKisanUrl,
  phone: '155261',
);

/// The order to check things in, given what the farmer can see.
List<Advice> kisanRoute(KisanSymptom symptom) => switch (symptom) {
      // Never anything: the registration itself is usually incomplete.
      KisanSymptom.neverAny => [
          _kisanStatus,
          _kisanEkyc,
          _kisanLand,
          _kisanName,
          _kisanHelp,
        ],
      // Was arriving and stopped: e-KYC became compulsory, or a record
      // changed under them.
      KisanSymptom.stopped => [
          _kisanStatus,
          _kisanEkyc,
          _kisanName,
          _kisanLand,
          _kisanHelp,
        ],
      // Neighbours paid, they were not: a record mismatch, not the scheme.
      KisanSymptom.lessThanOthers => [
          _kisanStatus,
          _kisanLand,
          _kisanName,
          _kisanEkyc,
          _kisanHelp,
        ],
      // The page itself says rejected: start from the exclusion heads.
      KisanSymptom.statusSaysRejected => [
          _kisanIneligible,
          _kisanStatus,
          _kisanLand,
          _kisanHelp,
        ],
    };

class PmKisanStuckPage extends StatefulWidget {
  const PmKisanStuckPage({super.key});

  @override
  State<PmKisanStuckPage> createState() => _PmKisanStuckPageState();
}

class _PmKisanStuckPageState extends State<PmKisanStuckPage> {
  KisanSymptom? _symptom;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    Widget pick(KisanSymptom s, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _symptom == s,
          onTap: () => setState(() => _symptom = s),
        );

    return ToolScaffold(
      goal: 1,
      title: hi ? 'पीएम-किसान की किस्त रुकी' : 'PM-KISAN instalment stopped',
      children: [
        ToolNote(hi
            ? 'पीएम-किसान साल के ₹6,000 तीन किस्तों में देती है, हर किस्त ₹2,000। किस्त '
                'लगभग हमेशा चार में से किसी एक जगह अटकती है, और चारों घर से दिखती नहीं। '
                'पहले अपनी स्थिति पढ़ें — वह ख़ुद बता देती है कि कहाँ अटकी है।'
            : 'PM-KISAN pays ₹6,000 a year in three instalments of ₹2,000. '
                'An instalment almost always stops at one of four places, '
                'and none of them is visible from home. Start by reading '
                'your own status - it names the place.'),
        ToolQuestion(hi ? 'क्या हो रहा है?' : 'What is happening?'),
        pick(KisanSymptom.neverAny, 'No instalment has ever come',
            'कोई किस्त कभी नहीं आई'),
        pick(KisanSymptom.stopped, 'It was coming, then it stopped',
            'पहले आ रही थी, फिर बंद हो गई'),
        pick(KisanSymptom.lessThanOthers,
            'Other farmers here were paid, we were not',
            'यहाँ और किसानों को मिली, हमें नहीं'),
        pick(KisanSymptom.statusSaysRejected,
            'The status page says rejected or ineligible',
            'स्थिति में "अस्वीकृत" या "अपात्र" लिखा है'),
        if (_symptom != null)
          AdviceList(
            heading: hi ? 'इसी क्रम में देखें' : 'Check in this order',
            items: kisanRoute(_symptom!),
          ),
      ],
    );
  }
}

// --- A scheme that said no --------------------------------------------

/// How far the person has already got. The useful next step is different
/// at each stage, and skipping to a higher office without the reason in
/// writing is the commonest wasted trip.
enum RejectStage { noReasonGiven, reasonKnown, fixedAndReapplied, ignored }

const _getReason = Advice(
  title: 'Get the reason in writing. This is the whole thing',
  titleHi: 'कारण लिखवाकर लें। असल काम यही है',
  body: 'An application cannot be rejected without a reason, and you are '
      'entitled to be told it. Ask for it in writing, at the counter, in '
      'these words: "please give me the rejection in writing with the '
      'reason". Most rejections are one of three dull things - a document '
      'missing, a name spelt differently across two papers, or an income '
      'or category entry typed wrong - and all three are fixable in a day. '
      'Without the reason you are guessing, and a guess is what turns one '
      'trip into six.',
  bodyHi: 'कोई अर्ज़ी बिना कारण अस्वीकार नहीं हो सकती, और वह कारण जानना आपका हक़ '
      'है। काउंटर पर लिखित में माँगें, इन्हीं शब्दों में: "कृपया अस्वीकृति कारण के साथ '
      'लिखकर दीजिए"। ज़्यादातर अस्वीकृतियाँ तीन मामूली बातों में से एक होती हैं — कोई '
      'काग़ज़ छूट गया, दो काग़ज़ों में नाम के हिज्जे अलग, या आय/श्रेणी ग़लत टाइप हो गई — '
      'और तीनों एक दिन में ठीक हो जाती हैं। कारण के बिना आप अंदाज़ा लगा रहे हैं, और '
      'अंदाज़ा ही एक चक्कर को छह चक्कर बना देता है।',
  source: _cpgramsUrl,
);

const _rti = Advice(
  title: 'If they will not put it in writing, an RTI will',
  titleHi: 'अगर लिखकर न दें, तो आरटीआई से मिल जाएगा',
  body: 'A ten-rupee RTI application asking "the reason my application '
      'dated DD/MM/YYYY was rejected, and the file notings on it" has to be '
      'answered in thirty days. In practice the reason often arrives before '
      'that, because the file gets looked at properly for the first time. '
      'This app has an RTI letter builder under SDG 16 that fills in the '
      'form for you.',
  bodyHi: 'दस रुपये की आरटीआई अर्ज़ी — "मेरी दिनांक DD/MM/YYYY की अर्ज़ी किस कारण '
      'अस्वीकार हुई, और उस पर फ़ाइल की टिप्पणियाँ" — का जवाब तीस दिन में देना ज़रूरी '
      'है। असल में कारण अक्सर उससे पहले आ जाता है, क्योंकि फ़ाइल पहली बार ठीक से '
      'देखी जाती है। इस ऐप में एसडीजी 16 के अंदर आरटीआई पत्र बनाने वाला टूल है।',
  source: 'https://rtionline.gov.in/',
);

const _fixAndReapply = Advice(
  title: 'Fix the one thing, then reapply with the old receipt attached',
  titleHi: 'वही एक चीज़ ठीक करें, फिर पुरानी रसीद लगाकर दोबारा दें',
  body: 'Reapply with a copy of the first application and its receipt '
      'attached, and a one-line covering note saying what was corrected. It '
      'keeps your original date on the file, which matters in schemes that '
      'pay arrears from the date of application, and it stops the second '
      'application being treated as a fresh one at the back of the queue.',
  bodyHi: 'दोबारा अर्ज़ी देते समय पहली अर्ज़ी और उसकी रसीद की नक़ल साथ लगाएँ, और एक '
      'पंक्ति में लिखें कि क्या ठीक किया गया। इससे फ़ाइल पर आपकी पहली तारीख़ बनी रहती '
      'है — जिन योजनाओं में अर्ज़ी की तारीख़ से बकाया मिलता है, वहाँ यह मायने रखता है — '
      'और दूसरी अर्ज़ी नई मानकर क़तार के पीछे नहीं लगती।',
  source: _cpgramsUrl,
);

const _escalateLadder = Advice(
  title: 'The ladder, one rung at a time, each in writing',
  titleHi: 'सीढ़ी, एक-एक पायदान, हर बार लिखित में',
  body: 'Block or tehsil officer, then the district officer for that '
      'department, then the state grievance portal, then CPGRAMS at '
      'pgportal.gov.in for anything central. Give each rung two weeks '
      'before going up. Every complaint should carry the application '
      'number, the date, the rejection reason, and what you did about it - '
      'and you should keep the acknowledgement number each one gives you. '
      'Skipping rungs is the one thing that reliably slows it down, because '
      'the higher office sends it back down.',
  bodyHi: 'ब्लॉक या तहसील अधिकारी, फिर उस विभाग के ज़िला अधिकारी, फिर राज्य का '
      'शिकायत पोर्टल, और केंद्र की योजना के लिए pgportal.gov.in पर सीपीग्राम्स। हर '
      'पायदान को दो हफ़्ते दें। हर शिकायत में अर्ज़ी संख्या, तारीख़, अस्वीकृति का कारण और '
      'आपने क्या किया — ये चारों हों, और हर शिकायत की पावती संख्या सँभालकर रखें। '
      'पायदान छोड़कर ऊपर जाना ही सबसे पक्का तरीक़ा है देर कराने का, क्योंकि ऊपर का '
      'कार्यालय फ़ाइल नीचे ही भेज देता है।',
  source: _cpgramsUrl,
);

const _lokAdalat = Advice(
  title: 'Free legal help, if it has gone on for months',
  titleHi: 'महीनों हो गए हों तो मुफ़्त क़ानूनी मदद',
  body: 'The District Legal Services Authority gives free legal aid and is '
      'in the district court compound in every district. For a benefit '
      'wrongly denied, they will write the notice for you, at no cost, and '
      'a letter on their paper is answered differently. The national '
      'helpline is 15100.',
  bodyHi: 'ज़िला विधिक सेवा प्राधिकरण मुफ़्त क़ानूनी मदद देता है और हर ज़िले में ज़िला '
      'न्यायालय परिसर में होता है। ग़लत तरीक़े से रोके गए लाभ के लिए वे आपकी ओर से '
      'नोटिस लिख देते हैं, बिना पैसे के — और उनके काग़ज़ पर आए पत्र का जवाब अलग तरह '
      'से दिया जाता है। राष्ट्रीय हेल्पलाइन 15100 है।',
  source: 'https://nalsa.gov.in/',
  phone: '15100',
);

List<Advice> rejectRoute(RejectStage stage) => switch (stage) {
      RejectStage.noReasonGiven => [_getReason, _rti, _escalateLadder],
      RejectStage.reasonKnown => [_fixAndReapply, _escalateLadder, _rti],
      RejectStage.fixedAndReapplied => [_escalateLadder, _rti, _lokAdalat],
      RejectStage.ignored => [_escalateLadder, _rti, _lokAdalat],
    };

class RejectedPage extends StatefulWidget {
  const RejectedPage({super.key});

  @override
  State<RejectedPage> createState() => _RejectedPageState();
}

class _RejectedPageState extends State<RejectedPage> {
  RejectStage? _stage;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    Widget pick(RejectStage s, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _stage == s,
          onTap: () => setState(() => _stage = s),
        );

    return ToolScaffold(
      goal: 1,
      title: hi ? 'अर्ज़ी अस्वीकार हो गई' : 'The application was rejected',
      children: [
        ToolNote(hi
            ? 'अस्वीकृति का मतलब यह नहीं कि आप पात्र नहीं हैं। ज़्यादातर अस्वीकृतियाँ '
                'काग़ज़ की छोटी गड़बड़ी से होती हैं, और उन्हीं लोगों की होती हैं जो दोबारा '
                'पूछना छोड़ देते हैं। पहला क़दम हमेशा एक ही है: कारण लिखवाकर लेना।'
            : 'A rejection does not mean you are not entitled. Most '
                'rejections come from a small paper problem, and they stick '
                'to the people who stop asking. The first step is always '
                'the same one: get the reason in writing.'),
        ToolQuestion(hi ? 'अब तक कहाँ तक पहुँचे हैं?' : 'How far have you got?'),
        pick(RejectStage.noReasonGiven,
            'They refused, but gave no reason in writing',
            'मना कर दिया, लेकिन लिखित कारण नहीं दिया'),
        pick(RejectStage.reasonKnown, 'I know the reason they gave',
            'कारण पता है'),
        pick(RejectStage.fixedAndReapplied,
            'I fixed it and reapplied, still nothing',
            'ठीक करके दोबारा दी, फिर भी कुछ नहीं'),
        pick(RejectStage.ignored, 'Nobody answers at all',
            'कोई जवाब ही नहीं देता'),
        if (_stage != null) ...[
          AdviceList(
            heading: hi ? 'इसी क्रम में करें' : 'Do these in order',
            items: rejectRoute(_stage!),
          ),
          const SizedBox(height: 14),
          Text(hi ? 'हर चक्कर में यह साथ रखें' : 'Carry these on every trip',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const ToolChecklist(
            storageKey: 'rejected_file_v1',
            introEn: 'Keep one folder for this. It is the difference between '
                'a complaint that moves and one that does not.',
            introHi: 'इसके लिए एक ही फ़ाइल रखें। चलने वाली और न चलने वाली शिकायत '
                'में फ़र्क़ इसी से पड़ता है।',
            items: [
              CheckItem('copy', 'A photocopy of the application you gave',
                  'जो अर्ज़ी दी थी उसकी फ़ोटोकॉपी'),
              CheckItem('receipt', 'The receipt or acknowledgement number',
                  'रसीद या पावती संख्या'),
              CheckItem('reason', 'The rejection, in writing',
                  'अस्वीकृति, लिखित में'),
              CheckItem('dates', 'A sheet of dates: every visit, who you met',
                  'तारीख़ों की एक पर्ची: हर चक्कर, किससे मिले',
                  noteEn: 'A date and a name is what makes a complaint '
                      'answerable. Write it the same evening.',
                  noteHi: 'तारीख़ और नाम ही शिकायत को जवाब देने लायक़ बनाते हैं। उसी '
                      'शाम लिख लें।'),
              CheckItem('papers', 'Fresh copies of the documents they '
                  'questioned', 'जिन काग़ज़ों पर सवाल उठा, उनकी नई नक़लें'),
            ],
          ),
        ],
      ],
    );
  }
}
