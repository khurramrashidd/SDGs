import 'package:flutter/material.dart';

import '../../core/sdg/advice.dart';
import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Government money that was approved but never arrived.
///
/// Almost every central benefit now reaches people by Direct Benefit
/// Transfer, and almost every failure is one of four things. None of them
/// is visible from outside: the family only sees that the money did not
/// come, assumes the scheme rejected them, and stops asking. This walks
/// backwards from the symptom to the step that is actually broken.
///
/// The four, in the order they break:
///   1. The scheme's own record is incomplete - e-KYC not done, land or
///      family details unverified.
///   2. Aadhaar is not seeded to the bank account with NPCI, so a
///      transfer addressed to the Aadhaar number has nowhere to land.
///   3. The account is frozen, dormant, closed, or a minor's.
///   4. The money did arrive, into an account the family forgot about -
///      often an old Jan Dhan account opened at a camp.
enum DbtSymptom { neverAny, stoppedSuddenly, othersGotIt, partOnly }

const _npciUrl = 'https://www.npci.org.in/what-we-do/nach/aadhaar-based-dbt';
const _pfmsUrl = 'https://pfms.nic.in/';

const _checkStatus = Advice(
  title: 'First, find out what the scheme thinks',
  titleHi: 'पहले देखें कि योजना क्या कहती है',
  body: 'Every scheme has a status page, and most will tell you the exact '
      'reason a payment failed rather than just "pending". Check on the '
      "scheme's own portal, or ask at a Common Service Centre, which can "
      'look it up in a minute. Write down the words it uses - "e-KYC '
      'pending", "Aadhaar not seeded", "account invalid" - because the next '
      'step depends entirely on which one it is.',
  bodyHi: 'हर योजना का एक स्थिति पृष्ठ होता है, और ज़्यादातर सिर्फ़ "लंबित" कहने के '
      'बजाय भुगतान रुकने का ठीक कारण बताते हैं। योजना के अपने पोर्टल पर देखें, या '
      'कॉमन सर्विस सेंटर पर पूछें — वे एक मिनट में देख लेते हैं। जो शब्द लिखा हो उसे नोट '
      'करें — "ई-केवाईसी लंबित", "आधार सीड नहीं", "खाता अमान्य" — क्योंकि अगला क़दम '
      'पूरी तरह उसी पर निर्भर है।',
  source: _pfmsUrl,
);

const _seeding = Advice(
  title: 'Aadhaar seeded to the account, not just linked',
  titleHi: 'आधार खाते से "सीड" हो, सिर्फ़ "लिंक" नहीं',
  body: 'This is the commonest failure and the least understood. Linking '
      'Aadhaar to an account for KYC is not the same as seeding it with '
      'NPCI, which is what tells the payment system which account an '
      'Aadhaar number should be paid into. Ask the bank in those words: '
      '"please seed my Aadhaar for DBT with NPCI". If Aadhaar is seeded to '
      'an older account, the money goes there - seeding points at exactly '
      'one account at a time.',
  bodyHi: 'यह सबसे आम गड़बड़ी है और सबसे कम समझी जाती है। केवाईसी के लिए आधार को '
      'खाते से जोड़ना और एनपीसीआई में "सीड" कराना एक बात नहीं है। सीडिंग ही भुगतान '
      'व्यवस्था को बताती है कि किस आधार संख्या का पैसा किस खाते में जाए। बैंक में इन्हीं '
      'शब्दों में कहें: "मेरा आधार डीबीटी के लिए एनपीसीआई में सीड कर दीजिए"। अगर आधार '
      'किसी पुराने खाते से सीड है तो पैसा वहीं जाएगा — सीडिंग एक समय में एक ही खाते '
      'की ओर इशारा करती है।',
  source: _npciUrl,
);

const _ekyc = Advice(
  title: 'e-KYC, and the details the scheme still wants',
  titleHi: 'ई-केवाईसी, और योजना को अब भी जो विवरण चाहिए',
  body: 'Many schemes now stop paying until e-KYC is done, and some also '
      'wait on land records or family details being verified by the local '
      'officer. e-KYC can usually be done free on the scheme portal with '
      'an OTP to the mobile registered with Aadhaar, or at a Common Service '
      'Centre. If your Aadhaar has no mobile number on it, that has to be '
      'fixed first, at an Aadhaar centre.',
  bodyHi: 'कई योजनाएँ अब ई-केवाईसी होने तक भुगतान रोक देती हैं, और कुछ में ज़मीन के '
      'रिकॉर्ड या परिवार के विवरण की स्थानीय अधिकारी से पुष्टि का इंतज़ार होता है। '
      'ई-केवाईसी आमतौर पर योजना पोर्टल पर आधार से जुड़े मोबाइल पर ओटीपी से मुफ़्त हो '
      'जाती है, या कॉमन सर्विस सेंटर पर। अगर आधार से कोई मोबाइल नंबर जुड़ा ही नहीं है, '
      'तो पहले आधार केंद्र पर वह ठीक कराना होगा।',
  source: _pfmsUrl,
);

const _account = Advice(
  title: 'Is the account actually able to receive money',
  titleHi: 'क्या खाता सच में पैसा ले सकता है',
  body: 'An account that has had no transaction for a long time goes '
      'dormant and will refuse a credit. So will an account with incomplete '
      'KYC, or one in a child\'s name where the scheme pays an adult. Take '
      'the passbook to the branch and ask them to say, plainly, whether the '
      'account is active and KYC-complete. A small deposit is often all it '
      'takes to wake it up.',
  bodyHi: 'जिस खाते में लंबे समय से कोई लेन-देन न हुआ हो वह निष्क्रिय हो जाता है और '
      'जमा लेने से मना कर देता है। अधूरी केवाईसी वाला खाता भी, और वह भी जो बच्चे के '
      'नाम है जबकि योजना किसी वयस्क को भुगतान करती है। पासबुक लेकर शाखा जाएँ और साफ़ '
      'पूछें कि खाता चालू है और केवाईसी पूरी है या नहीं। अक्सर थोड़ी सी जमा से ही वह फिर '
      'चालू हो जाता है।',
  source: _pfmsUrl,
);

const _oldAccount = Advice(
  title: 'Check the account you forgot you had',
  titleHi: 'वह खाता देखें जो आप भूल चुके हैं',
  body: 'A surprising share of "missing" payments did arrive - into a Jan '
      'Dhan account opened years ago at a camp, which the family has never '
      'used. If Aadhaar was seeded to that one, every scheme pays into it. '
      'Ask the bank which account your Aadhaar is seeded to, and check its '
      'balance before assuming the money was never sent.',
  bodyHi: '"न आए" भुगतानों का एक बड़ा हिस्सा असल में आ चुका होता है — उसी जन धन खाते '
      'में जो सालों पहले किसी शिविर में खुला था और परिवार ने कभी इस्तेमाल नहीं किया। '
      'अगर आधार उसी से सीड है, तो हर योजना का पैसा वहीं जाता है। बैंक से पूछें कि आपका '
      'आधार किस खाते से सीड है, और यह मानने से पहले कि पैसा भेजा ही नहीं गया, उसका '
      'बैलेंस देख लें।',
  source: _npciUrl,
);

const _escalate = Advice(
  title: 'When the bank and the portal both say it is fine',
  titleHi: 'जब बैंक और पोर्टल दोनों कहें कि सब ठीक है',
  body: 'Put it in writing to the office that runs the scheme - the Block '
      'Development Office for most rural schemes - quoting your application '
      'or registration number, the months you have not been paid, and what '
      'the portal says. Keep the dated receipt. If nothing moves in a '
      'month, the state grievance portal or CM helpline takes it next, and '
      'after that an RTI asking what action was taken usually does.',
  bodyHi: 'जो दफ़्तर योजना चलाता है उसे लिखकर दें — ज़्यादातर ग्रामीण योजनाओं में खंड '
      'विकास कार्यालय — अपने आवेदन या पंजीकरण संख्या, जिन महीनों का पैसा नहीं आया, और '
      'पोर्टल क्या कहता है, यह लिखकर। दिनांकित पावती रखें। एक महीने में कुछ न हो तो '
      'राज्य का शिकायत पोर्टल या मुख्यमंत्री हेल्पलाइन अगला क़दम है, और उसके बाद यह '
      'पूछती आरटीआई कि क्या कार्रवाई हुई, अक्सर काम कर जाती है।',
  source: _pfmsUrl,
);

/// The steps to take, in the order most likely to find the fault.
List<Advice> dbtRoute(DbtSymptom symptom) => switch (symptom) {
      // Never received anything: the scheme record or the seeding is the
      // likely break, not the account.
      DbtSymptom.neverAny => [_checkStatus, _ekyc, _seeding, _account, _escalate],
      // Was arriving and stopped: something changed - usually e-KYC became
      // compulsory, or Aadhaar got seeded to a different account.
      DbtSymptom.stoppedSuddenly => [
          _checkStatus,
          _ekyc,
          _oldAccount,
          _seeding,
          _escalate
        ],
      // Neighbours were paid: the scheme is running, so it is this
      // household's own record or account.
      DbtSymptom.othersGotIt => [_checkStatus, _seeding, _account, _escalate],
      DbtSymptom.partOnly => [_checkStatus, _escalate],
    };

class DbtStuckPage extends StatefulWidget {
  const DbtStuckPage({super.key});

  @override
  State<DbtStuckPage> createState() => _DbtStuckPageState();
}

class _DbtStuckPageState extends State<DbtStuckPage> {
  DbtSymptom? _symptom;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    Widget pick(DbtSymptom s, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _symptom == s,
          onTap: () => setState(() => _symptom = s),
        );

    return ToolScaffold(
      goal: 1,
      title: hi ? 'पैसा नहीं आ रहा' : 'The money is not arriving',
      children: [
        ToolNote(hi
            ? 'सरकारी पैसा अब सीधे खाते में आता है, और लगभग हर बार वह चार में से किसी '
                'एक जगह अटकता है। घर से यह दिखता नहीं — सिर्फ़ इतना दिखता है कि पैसा नहीं '
                'आया। चलिए पीछे से ढूँढ़ते हैं।'
            : 'Government money now goes straight to an account, and almost '
                'every failure is one of four things. None of them is '
                'visible from home: all you see is that nothing came. Let us '
                'work backwards.'),
        ToolQuestion(hi ? 'क्या हो रहा है?' : 'What is happening?'),
        pick(DbtSymptom.neverAny, 'We have never received anything',
            'हमें कभी कुछ नहीं मिला'),
        pick(DbtSymptom.stoppedSuddenly, 'It was coming, then it stopped',
            'पहले आ रहा था, फिर बंद हो गया'),
        pick(DbtSymptom.othersGotIt,
            'Neighbours were paid but we were not',
            'पड़ोसियों को मिला, हमें नहीं'),
        pick(DbtSymptom.partOnly, 'Less came than it should have',
            'जितना बनता था उससे कम आया'),
        if (_symptom != null) ...[
          if (_symptom == DbtSymptom.partOnly)
            ToolAnswer(
              headline: hi
                  ? 'पहले जाँचें कि कितना बनता है'
                  : 'First check what you were actually owed',
              detail: hi
                  ? 'कई योजनाओं में किस्त की रक़म साल या श्रेणी से बदलती है, और कुछ में '
                      'पुरानी वसूली काट ली जाती है। स्थिति पृष्ठ पर आमतौर पर यह लिखा '
                      'होता है कि कितना भेजा गया और क्यों।'
                  : 'In several schemes the instalment changes with the year '
                      'or the category, and in some an earlier recovery is '
                      'deducted. The status page usually says what was sent '
                      'and why.',
              tone: ToolTone.plain,
              icon: Icons.info_outline,
            ),
          AdviceList(
            heading: hi ? 'इसी क्रम में देखें' : 'Check in this order',
            items: dbtRoute(_symptom!),
          ),
        ],
      ],
    );
  }
}
