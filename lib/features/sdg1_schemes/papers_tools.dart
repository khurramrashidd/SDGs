import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/tool_kit.dart';

/// The papers a household needs before it needs them.
///
/// Every tool in this goal ends up asking for the same handful of
/// documents, and the families who lose a scholarship or a pension are
/// usually the ones who started gathering them the week the form was due.
/// This is the list, ticked off at leisure.
class FamilyPapersPage extends StatelessWidget {
  const FamilyPapersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 1,
      title: hi ? 'परिवार के काग़ज़' : 'Family papers',
      children: [
        ToolNote(hi
            ? 'जो परिवार छात्रवृत्ति या पेंशन से चूक जाते हैं, वे अक्सर वही होते हैं '
                'जिन्होंने काग़ज़ जुटाना उसी हफ़्ते शुरू किया जिस हफ़्ते फ़ॉर्म की आख़िरी '
                'तारीख़ थी। ज़रूरत पड़ने से पहले बनवा लें।'
            : 'The families who miss a scholarship or a pension are usually '
                'the ones who started gathering papers the week the form was '
                'due. Get them before you need them.'),
        const SizedBox(height: 6),
        const ToolChecklist(
          storageKey: 'family_papers_v1',
          introEn: 'Tick what the household already holds. What is left is '
              'your list for the next trip to the block office.',
          introHi: 'जो पहले से हैं उन पर निशान लगाएँ। जो बचे, वही अगली बार ब्लॉक '
              'दफ़्तर जाने की सूची है।',
          items: [
            CheckItem('aadhaar', 'Aadhaar for every member',
                'हर सदस्य का आधार',
                noteEn: 'With a working mobile number on it - without that, '
                    'no e-KYC and no OTP.',
                noteHi: 'उस पर चालू मोबाइल नंबर जुड़ा हो — उसके बिना न ई-केवाईसी, '
                    'न ओटीपी।'),
            CheckItem('bank', 'A bank account in the right name',
                'सही नाम से बैंक खाता',
                noteEn: 'Aadhaar seeded to it for DBT, name spelt as on '
                    'Aadhaar.',
                noteHi: 'डीबीटी के लिए आधार उसी से सीड हो, नाम आधार जैसा हो।'),
            CheckItem('ration', 'Ration card, with every member named',
                'राशन कार्ड, हर सदस्य के नाम के साथ'),
            CheckItem('birth', 'Birth certificate for each child',
                'हर बच्चे का जन्म प्रमाण पत्र',
                noteEn: 'Needed for school admission and later for a '
                    'passport.',
                noteHi: 'स्कूल में दाख़िले और बाद में पासपोर्ट के लिए ज़रूरी।'),
            CheckItem('caste', 'Caste certificate, if it applies',
                'जाति प्रमाण पत्र, अगर लागू हो',
                noteEn: 'For a central seat it must be in the central '
                    'format.',
                noteHi: 'केंद्रीय सीट के लिए केंद्रीय प्रारूप में होना चाहिए।'),
            CheckItem('income', 'Income certificate from this year',
                'इसी साल का आय प्रमाण पत्र',
                noteEn: 'The commonest reason a scholarship is rejected is '
                    'an old one.',
                noteHi: 'छात्रवृत्ति रद्द होने का सबसे आम कारण पुराना प्रमाण पत्र '
                    'होता है।'),
            CheckItem('domicile', 'Residence certificate',
                'निवास प्रमाण पत्र'),
            CheckItem('land', 'Land papers or the rent agreement',
                'ज़मीन के काग़ज़ या किरायानामा'),
            CheckItem('disability', 'Disability certificate and UDID card',
                'दिव्यांगता प्रमाण पत्र और यूडीआईडी कार्ड',
                noteEn: 'If anyone in the house has a disability.',
                noteHi: 'अगर घर में किसी को दिव्यांगता है।'),
            CheckItem('insurance', 'Note of any insurance and its nominee',
                'किसी भी बीमे और उसके नामित का ब्यौरा',
                noteEn: 'A cover nobody knows about is never claimed.',
                noteHi: 'जिस बीमे का किसी को पता नहीं, उसका दावा कभी नहीं होता।'),
            CheckItem('copies', 'Photocopies, and photos on a phone',
                'फ़ोटोकॉपी, और फ़ोन में फ़ोटो',
                noteEn: 'Papers are lost in floods and fires. A photo is '
                    'not the original, but it tells the office exactly what '
                    'to reissue.',
                noteHi: 'बाढ़ और आग में काग़ज़ चले जाते हैं। फ़ोटो मूल नहीं है, पर '
                    'दफ़्तर को ठीक-ठीक बता देता है कि दोबारा क्या बनाना है।'),
            CheckItem('digilocker', 'The ones that work in DigiLocker, '
                'put there', 'जो डिजिलॉकर में आ सकते हैं, वे वहाँ डाल दें'),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

/// What a family has to do after a death, in the order it has to be done.
///
/// Written for the week after, when nobody is thinking clearly. The point
/// of the order is that nearly everything else needs the death certificate,
/// so that comes first, and in enough copies.
class AfterDeathPage extends StatefulWidget {
  const AfterDeathPage({super.key});

  @override
  State<AfterDeathPage> createState() => _AfterDeathPageState();
}

class _AfterDeathPageState extends State<AfterDeathPage> {
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final fmt = DateFormat('d MMM yyyy');
    int? daysSince;
    if (_date != null) {
      final now = DateTime.now();
      daysSince = DateTime(now.year, now.month, now.day)
          .difference(_date!)
          .inDays;
    }

    return ToolScaffold(
      goal: 1,
      title: hi ? 'परिवार में मृत्यु के बाद' : 'After a death in the family',
      children: [
        ToolNote(hi
            ? 'यह उस हफ़्ते के लिए है जब कुछ भी सोचना मुश्किल होता है। क्रम इसलिए है कि '
                'बाक़ी लगभग हर चीज़ के लिए मृत्यु प्रमाण पत्र चाहिए।'
            : 'This is for the week when nothing is easy to think about. The '
                'order matters because almost everything else needs the '
                'death certificate first.'),
        ToolQuestion(hi ? 'मृत्यु कब हुई?' : 'When did it happen?'),
        OutlinedButton.icon(
          onPressed: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: DateTime(now.year - 5),
              lastDate: now,
            );
            if (picked != null) setState(() => _date = picked);
          },
          icon: const Icon(Icons.event),
          label: Text(_date == null
              ? (hi ? 'तारीख़ चुनें' : 'Pick the date')
              : fmt.format(_date!)),
        ),
        if (daysSince != null)
          ToolAnswer(
            headline: daysSince <= 21
                ? (hi
                    ? 'पहले मृत्यु पंजीकरण कराएँ'
                    : 'Register the death first')
                : (hi
                    ? 'पंजीकरण अब भी हो सकता है'
                    : 'It can still be registered'),
            detail: daysSince <= 21
                ? (hi
                    ? 'मृत्यु का पंजीकरण 21 दिन के भीतर बिना किसी अतिरिक्त कार्रवाई के '
                        'हो जाता है। जहाँ मृत्यु हुई वहाँ के नगर निकाय या ग्राम पंचायत '
                        'में दर्ज कराएँ। अस्पताल में हुई हो तो अस्पताल पर्ची देता है।'
                    : 'A death registered within 21 days needs nothing extra. '
                        'Register it with the municipality or Gram Panchayat '
                        'where it happened. If it was in hospital, the '
                        'hospital issues the slip.')
                : (hi
                    ? '21 दिन से ज़्यादा होने पर देरी की अनुमति लेनी पड़ती है — कितनी देर '
                        'हुई उसके हिसाब से अधिकारी बदलता है। इसे टालें नहीं; जितनी देर '
                        'होगी, उतने और काग़ज़ लगेंगे।'
                    : 'Past 21 days you need permission for the delay, and '
                        'who gives it depends on how late you are. Do not '
                        'put it off: the longer it waits, the more papers it '
                        'takes.'),
            tone: daysSince <= 21 ? ToolTone.good : ToolTone.warn,
            icon: Icons.description_outlined,
          ),
        const SizedBox(height: 14),
        const ToolChecklist(
          storageKey: 'after_death_v1',
          introEn: 'In this order. Get at least six copies of the death '
              'certificate - every office below keeps one.',
          introHi: 'इसी क्रम में। मृत्यु प्रमाण पत्र की कम से कम छह प्रतियाँ लें — '
              'नीचे का हर दफ़्तर एक रख लेता है।',
          items: [
            CheckItem('register', 'Register the death and get the certificate',
                'मृत्यु पंजीकरण कराकर प्रमाण पत्र लें'),
            CheckItem('copies', 'Six or more copies of it',
                'उसकी छह या ज़्यादा प्रतियाँ'),
            CheckItem('bank', 'Tell the bank, and claim the account',
                'बैंक को बताएँ, और खाते का दावा करें',
                noteEn: 'If there was a nominee it is quick. If not, ask '
                    'about the small-amount settlement before anyone talks '
                    'about court.',
                noteHi: 'नामित हो तो जल्दी हो जाता है। न हो तो अदालत की बात से '
                    'पहले छोटी रक़म के निपटारे के बारे में पूछें।'),
            CheckItem('insurance', 'Claim any insurance, including PMJJBY '
                'and PMSBY', 'कोई भी बीमा — पीएमजेजेबीवाई और पीएमएसबीवाई सहित — '
                'का दावा करें'),
            CheckItem('pension', 'Family pension, if the person had one',
                'परिवार पेंशन, अगर उन्हें मिलती थी'),
            CheckItem('widow', 'Widow pension, if it applies',
                'विधवा पेंशन, अगर लागू हो'),
            CheckItem('nfbs', 'Family benefit, if the main earner died',
                'कमाने वाले की मृत्यु पर पारिवारिक लाभ',
                noteEn: 'A one-time payment under the national social '
                    'assistance programme, for families below the poverty '
                    'line. Ask at the block office what your state pays.',
                noteHi: 'ग़रीबी रेखा से नीचे के परिवारों के लिए राष्ट्रीय सामाजिक '
                    'सहायता कार्यक्रम के तहत एकमुश्त राशि। ब्लॉक दफ़्तर में पूछें कि '
                    'आपका राज्य कितना देता है।'),
            CheckItem('ration', 'Correct the ration card',
                'राशन कार्ड सुधरवाएँ',
                noteEn: 'Leaving the name on it causes trouble later; '
                    'removing it without adding the new head loses you the '
                    'grain.',
                noteHi: 'नाम छोड़ देने से बाद में दिक़्क़त होती है; नए मुखिया का नाम '
                    'जोड़े बिना हटाने से अनाज कम हो जाता है।'),
            CheckItem('mutation', 'Mutation of land and house',
                'ज़मीन और मकान का दाख़िल-ख़ारिज',
                noteEn: 'The single commonest cause of family land disputes '
                    'is skipping this for years.',
                noteHi: 'पारिवारिक ज़मीन विवाद का सबसे आम कारण यही है कि इसे सालों '
                    'टाल दिया जाता है।'),
            CheckItem('heirs', 'Get every legal heir named, daughters '
                'included', 'हर क़ानूनी वारिस का नाम दर्ज कराएँ, बेटियों का भी'),
            CheckItem('aadhaar', 'Have the Aadhaar deactivated',
                'आधार निष्क्रिय कराएँ',
                noteEn: 'So it cannot be used by anyone else later.',
                noteHi: 'ताकि बाद में कोई और उसका इस्तेमाल न कर सके।'),
            CheckItem('phone', 'Close or transfer the phone connection',
                'फ़ोन कनेक्शन बंद कराएँ या अपने नाम कराएँ'),
          ],
        ),
        ToolNote(hi
            ? 'यह सामान्य जानकारी है। उत्तराधिकार के नियम धर्म और राज्य के हिसाब से बदलते '
                'हैं — ज़मीन या बड़ी रक़म का मामला हो तो मुफ़्त क़ानूनी सहायता लें, जो इस '
                'ऐप के शांति और न्याय हिस्से में है।'
            : 'This is general information. Inheritance rules differ by '
                'religion and by state - for land or a large amount, use the '
                'free legal aid route in the Peace and Justice part of this '
                'app.'),
      ],
    );
  }
}
