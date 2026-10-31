/// "Is this job real?"
///
/// Scored flags rather than a decision tree, because job fraud does not work
/// like food safety. One flag here — being asked for money — is close to
/// conclusive on its own, while several weaker signs together also add up.
/// A tree would either miss the first case or over-weight the second.
///
/// The weights below are judgement, not measurement. They are set so that
/// any single decisive flag reaches "almost certainly a scam" alone, and
/// three ordinary flags reach "be careful".
library;

class ScamFlag {
  final String id;
  final String label;
  final String labelHi;

  /// 100 on its own is decisive.
  final int weight;

  /// Shown when the flag is ticked, explaining why it matters.
  final String note;
  final String noteHi;

  const ScamFlag({
    required this.id,
    required this.label,
    required this.labelHi,
    required this.weight,
    required this.note,
    required this.noteHi,
  });
}

const List<ScamFlag> kScamFlags = [
  ScamFlag(
    id: 'money',
    weight: 100,
    label: 'They asked for money — registration, training, a kit, a deposit, '
        'or a "refundable" security amount',
    labelHi: 'उन्होंने पैसे माँगे — रजिस्ट्रेशन, ट्रेनिंग, किट, जमा राशि, '
        'या "वापस मिलने वाली" सिक्योरिटी',
    note: 'A real employer never asks you to pay to be hired. Not for '
        'training, not for a uniform, not as a refundable deposit. This one '
        'sign is enough on its own.',
    noteHi: 'असली नियोक्ता नौकरी देने के बदले कभी पैसे नहीं माँगता। न '
        'ट्रेनिंग के, न वर्दी के, न वापस मिलने वाली जमा राशि के। यह अकेला '
        'संकेत ही काफ़ी है।',
  ),
  ScamFlag(
    id: 'govtfee',
    weight: 100,
    label: 'They promised a government job in exchange for money or a '
        '"setting"',
    labelHi: 'पैसे या "सेटिंग" के बदले सरकारी नौकरी का वादा किया',
    note: 'Government jobs are filled only through advertised examinations '
        'and official portals. Anyone who says they can arrange one is '
        'taking your money.',
    noteHi: 'सरकारी नौकरियाँ केवल विज्ञापित परीक्षाओं और आधिकारिक पोर्टल से '
        'भरी जाती हैं। जो कहे कि वह दिलवा देगा, वह आपके पैसे ले रहा है।',
  ),
  ScamFlag(
    id: 'bank',
    weight: 100,
    label: 'They wanted your bank details, OTP, ATM PIN or Aadhaar number '
        'before any proper hiring',
    labelHi: 'सही भर्ती प्रक्रिया से पहले ही बैंक विवरण, ओटीपी, एटीएम पिन '
        'या आधार नंबर माँगा',
    note: 'An employer needs bank details only after you have joined, for '
        'salary. Nobody ever needs your OTP or PIN. Sharing them can empty '
        'your account.',
    noteHi: 'नियोक्ता को बैंक विवरण तभी चाहिए जब आप काम पर लग जाएँ, वेतन के '
        'लिए। ओटीपी या पिन किसी को कभी नहीं चाहिए। बताने पर खाता ख़ाली हो '
        'सकता है।',
  ),
  ScamFlag(
    id: 'nointerview',
    weight: 45,
    label: 'They offered the job with no real interview',
    labelHi: 'बिना किसी असली इंटरव्यू के नौकरी दे दी',
    note: 'No employer hires without checking whether you can do the work.',
    noteHi: 'कोई नियोक्ता यह जाँचे बिना नौकरी नहीं देता कि आप काम कर सकते '
        'हैं या नहीं।',
  ),
  ScamFlag(
    id: 'whatsapp',
    weight: 40,
    label: 'The offer came out of nowhere on WhatsApp, Telegram or SMS',
    labelHi: 'ऑफ़र अचानक WhatsApp, Telegram या SMS पर आया',
    note: 'You did not apply, so how did they find you? Real recruiters '
        'contact people who applied, through a company email address.',
    noteHi: 'आपने आवेदन किया ही नहीं, तो उन्होंने आपको कैसे ढूँढा? असली '
        'भर्तीकर्ता उन्हीं से संपर्क करते हैं जिन्होंने आवेदन किया हो, और '
        'कंपनी के ईमेल से।',
  ),
  ScamFlag(
    id: 'pressure',
    weight: 40,
    label: 'They pushed you to decide or pay quickly — "only today", '
        '"last 2 seats"',
    labelHi: 'जल्दी निर्णय या भुगतान का दबाव डाला — "सिर्फ़ आज", '
        '"आख़िरी 2 सीट"',
    note: 'Urgency exists to stop you checking. A real job will still be '
        'there tomorrow.',
    noteHi: 'जल्दबाज़ी इसलिए कराई जाती है ताकि आप जाँच न सकें। असली नौकरी '
        'कल भी रहेगी।',
  ),
  ScamFlag(
    id: 'email',
    weight: 35,
    label: 'They write from Gmail or Yahoo, not a company address',
    labelHi: 'वे Gmail या Yahoo से लिखते हैं, कंपनी के पते से नहीं',
    note: 'A company that can pay a salary can afford its own email domain.',
    noteHi: 'जो कंपनी वेतन दे सकती है, वह अपना ईमेल डोमेन भी रख सकती है।',
  ),
  ScamFlag(
    id: 'toogood',
    weight: 30,
    label: 'The pay is far above normal for the work described',
    labelHi: 'बताए गए काम के हिसाब से वेतन बहुत ज़्यादा है',
    note: 'Unusually high pay for simple work is the oldest hook there is.',
    noteHi: 'आसान काम के लिए असामान्य रूप से ज़्यादा वेतन सबसे पुराना चारा है।',
  ),
  ScamFlag(
    id: 'vague',
    weight: 25,
    label: 'They will not say clearly what the work actually is',
    labelHi: 'वे साफ़ नहीं बताते कि काम वास्तव में क्या है',
    note: 'If they cannot describe the job, there probably is not one.',
    noteHi: 'अगर वे काम बता ही नहीं सकते, तो शायद काम है ही नहीं।',
  ),
  ScamFlag(
    id: 'noaddress',
    weight: 25,
    label: 'You cannot find the company anywhere, or it has no real address',
    labelHi: 'कंपनी कहीं नहीं मिलती, या उसका कोई असली पता नहीं है',
    note: 'Search the name with the word "fraud" or "scam" before anything '
        'else. Other people usually got there first.',
    noteHi: 'किसी और काम से पहले कंपनी का नाम "fraud" या "scam" के साथ खोजें। '
        'आमतौर पर कोई और पहले ही फँस चुका होता है।',
  ),
];

enum ScamVerdict { likelyScam, beCareful, probablyFine }

class ScamResult {
  final ScamVerdict verdict;
  final int score;
  final List<ScamFlag> raised;

  const ScamResult(this.verdict, this.score, this.raised);
}

ScamResult assessJob(Set<String> tickedIds) {
  final raised =
      kScamFlags.where((f) => tickedIds.contains(f.id)).toList();
  final score = raised.fold<int>(0, (sum, f) => sum + f.weight);

  // 100 is reached by any single decisive flag, or by roughly three
  // ordinary ones.
  final verdict = score >= 100
      ? ScamVerdict.likelyScam
      : score >= 50
          ? ScamVerdict.beCareful
          : ScamVerdict.probablyFine;

  return ScamResult(verdict, score, raised);
}
