import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Asking the government: the voter roll, and a complaint that went
/// unanswered.

const _voterUrl = 'https://voters.eci.gov.in/';
const _pgUrl = 'https://pgportal.gov.in/';

// --- Voter ID ---------------------------------------------------------

enum VoterNeed { newVoter, shift, correct, delete, lostCard }

class VoterIdPage extends StatefulWidget {
  const VoterIdPage({super.key});

  @override
  State<VoterIdPage> createState() => _VoterIdPageState();
}

class _VoterIdPageState extends State<VoterIdPage> {
  VoterNeed? _need;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    final answer = switch (_need) {
      VoterNeed.newVoter => (
          form: hi ? 'फ़ॉर्म 6' : 'Form 6',
          body: hi
              ? 'पहली बार नाम जुड़वाने के लिए। भारत का नागरिक, और योग्यता की तारीख़ पर '
                  '18 साल। साल में चार योग्यता तारीख़ें हैं — 1 जनवरी, 1 अप्रैल, 1 जुलाई '
                  'और 1 अक्टूबर — और 17 साल की उम्र में पहले से आवेदन किया जा सकता है। '
                  'उम्र और पते का प्रमाण लगता है।'
              : 'To be enrolled for the first time. An Indian citizen, 18 on '
                  'the qualifying date. There are four qualifying dates a year - '
                  '1 January, 1 April, 1 July and 1 October - and you can apply '
                  'in advance at 17. Proof of age and address is needed.',
        ),
      VoterNeed.shift => (
          form: hi ? 'फ़ॉर्म 8' : 'Form 8',
          body: hi
              ? 'नए पते पर नाम ले जाने के लिए — उसी क्षेत्र में हो या दूसरे में। इससे '
                  'पुराने पते से नाम अपने आप हटता है। नए पते का प्रमाण लगता है; किराये के '
                  'मकान में किरायानामा या बिल चलता है।'
              : 'To move your entry to a new address - in the same constituency '
                  'or another. The old entry comes off on its own. Proof of the '
                  'new address is needed; for a rented house, the rent agreement '
                  'or a bill will do.',
        ),
      VoterNeed.correct => (
          form: hi ? 'फ़ॉर्म 8' : 'Form 8',
          body: hi
              ? 'नाम, उम्र, फ़ोटो, रिश्तेदार का नाम या लिंग में सुधार के लिए। जो सही है, '
                  'उसका प्रमाण लगाएँ। इसी फ़ॉर्म से दिव्यांगता भी दर्ज कराई जा सकती है, '
                  'ताकि मतदान के दिन सुविधा मिले।'
              : 'To correct the name, age, photo, relative\'s name or gender. '
                  'Attach proof of what is right. The same form can mark a '
                  'disability, so facilities are arranged on polling day.',
        ),
      VoterNeed.delete => (
          form: hi ? 'फ़ॉर्म 7' : 'Form 7',
          body: hi
              ? 'किसी की मृत्यु पर नाम हटवाने, या किसी ग़लत प्रविष्टि पर आपत्ति के लिए। '
                  'मृत्यु के लिए मृत्यु प्रमाण पत्र लगाएँ।'
              : 'To remove the name of someone who has died, or to object to a '
                  'wrong entry. For a death, attach the death certificate.',
        ),
      VoterNeed.lostCard => (
          form: hi ? 'ई-एपिक, या फ़ॉर्म 8' : 'e-EPIC, or Form 8',
          body: hi
              ? 'नाम सूची में हो तो डिजिटल वोटर कार्ड (ई-एपिक) voters.eci.gov.in से तुरंत '
                  'डाउनलोड हो जाता है, उसी मोबाइल नंबर से जो सूची में दर्ज है। छपा कार्ड '
                  'दोबारा चाहिए तो फ़ॉर्म 8 में "बदले में कार्ड" चुनें।'
              : 'If your name is on the roll, the digital voter card (e-EPIC) '
                  'downloads at once from voters.eci.gov.in, using the mobile '
                  'number on the roll. For a printed replacement, choose '
                  '"replacement EPIC" in Form 8.',
        ),
      null => null,
    };

    return ToolScaffold(
      goal: 16,
      title: hi ? 'वोटर आईडी: नाम जोड़ें, सुधारें, बदलें' : 'Voter ID: register, correct, move',
      children: [
        ToolQuestion(hi ? 'क्या करना है' : 'What do you need'),
        SelectionTile(
          label: hi ? 'पहली बार नाम जुड़वाना' : 'Enrol for the first time',
          selected: _need == VoterNeed.newVoter,
          onTap: () => setState(() => _need = VoterNeed.newVoter),
        ),
        SelectionTile(
          label: hi ? 'नए पते पर ले जाना' : 'Move to a new address',
          selected: _need == VoterNeed.shift,
          onTap: () => setState(() => _need = VoterNeed.shift),
        ),
        SelectionTile(
          label: hi ? 'कोई ग़लती ठीक करना' : 'Correct a mistake',
          selected: _need == VoterNeed.correct,
          onTap: () => setState(() => _need = VoterNeed.correct),
        ),
        SelectionTile(
          label: hi ? 'नाम हटवाना या आपत्ति' : 'Remove a name, or object',
          selected: _need == VoterNeed.delete,
          onTap: () => setState(() => _need = VoterNeed.delete),
        ),
        SelectionTile(
          label: hi ? 'कार्ड खो गया' : 'Lost the card',
          selected: _need == VoterNeed.lostCard,
          onTap: () => setState(() => _need = VoterNeed.lostCard),
        ),
        if (answer != null) ...[
          ToolAnswer(
            headline: answer.form,
            detail: answer.body,
            tone: ToolTone.good,
            icon: Icons.how_to_vote_outlined,
          ),
          const SizedBox(height: 10),
          ToolSteps(
            steps: hi
                ? const [
                    'फ़ॉर्म voters.eci.gov.in पर, "वोटर हेल्पलाइन" ऐप में, या अपने बूथ लेवल '
                        'अधिकारी (बीएलओ) के पास — तीनों मुफ़्त।',
                    'जमा करने पर एक संदर्भ संख्या मिलती है; उसी से स्थिति देखें।',
                    'बीएलओ घर आकर जाँच कर सकता है। उसके बाद नाम सूची में आता है — इसमें '
                        'कुछ हफ़्ते लग सकते हैं, इसलिए चुनाव से पहले, समय से करें।',
                    'चुनाव की घोषणा के बाद सूची में बदलाव रुक जाते हैं।',
                  ]
                : const [
                    'The forms are on voters.eci.gov.in, in the "Voter Helpline" '
                        'app, or with your booth level officer (BLO) - all three '
                        'free.',
                    'On submitting you get a reference number; track the status '
                        'with it.',
                    'The BLO may visit to verify. After that the name goes on the '
                        'roll - this can take some weeks, so do it well before an '
                        'election.',
                    'Once an election is announced, changes to the roll stop.',
                  ],
          ),
          const SizedBox(height: 10),
          ToolNote(hi
              ? 'वोट देने के लिए नाम सूची में होना ज़रूरी है; सिर्फ़ कार्ड होना काफ़ी नहीं। '
                  'नाम सूची में हो तो आधार, पासपोर्ट, ड्राइविंग लाइसेंस जैसे दूसरे पहचान '
                  'पत्र से भी वोट दिया जा सकता है।'
              : 'To vote, your name must be on the roll; holding a card is not '
                  'enough. With your name on the roll, other ID such as Aadhaar, a '
                  'passport or a driving licence also lets you vote.'),
          const SourceNote(text: 'Voter services portal', url: _voterUrl),
        ],
      ],
    );
  }
}

// --- Complaint got no answer ------------------------------------------

class GrievanceLadderPage extends StatelessWidget {
  const GrievanceLadderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 16,
      title: hi ? 'मेरी शिकायत का जवाब नहीं आया' : 'My complaint got no answer',
      children: [
        ToolNote(hi
            ? 'सरकारी शिकायत एक सीढ़ी है, और ज़्यादातर लोग पहली पायदान पर रुक जाते हैं। '
                'हर पायदान लिखित में हो और उसकी रसीद या संख्या हो — वही अगली पायदान का '
                'सबूत है।'
            : 'A government complaint is a ladder, and most people stop on the '
                'first rung. Make every rung in writing with a receipt or a '
                'number - that is the proof for the next.'),
        const SizedBox(height: 12),
        ToolSteps(
          steps: hi
              ? const [
                  'उसी दफ़्तर में लिखित आवेदन, रसीद के साथ।',
                  'उस दफ़्तर के बड़े अधिकारी को — ज़िले में ज़िलाधिकारी कार्यालय की '
                      'जनसुनवाई।',
                  'ऑनलाइन: केंद्र के विभागों के लिए सीपीग्राम्स (pgportal.gov.in), और राज्य '
                      'का अपना शिकायत पोर्टल या मुख्यमंत्री हेल्पलाइन। शिकायत संख्या लिख लें।',
                  'जो अपील ज़्यादातर लोग नहीं करते: शिकायत "निपटा दी गई" कहकर बंद हो और '
                      'काम न हुआ हो, तो सीपीग्राम्स पर उसी शिकायत पर अपील का विकल्प है। राज्य '
                      'पोर्टलों पर भी असंतोष दर्ज करने का रास्ता होता है।',
                  'सूचना का अधिकार: ₹10 में पूछें कि आपकी शिकायत पर क्या कार्रवाई हुई, '
                      'किस अधिकारी के पास है, और फ़ाइल नोटिंग की नक़ल। इसी लक्ष्य में "आरटीआई '
                      'आवेदन लिखें" है।',
                  'जो सेवाएँ राज्य के सेवा का अधिकार क़ानून में हैं — प्रमाण पत्र, '
                      'कनेक्शन, लाइसेंस — उनमें तय समय निकलने पर अपीलीय अधिकारी के पास '
                      'अपील; देर पर अधिकारी पर जुर्माना भी लग सकता है।',
                ]
              : const [
                  'A written application at the same office, with a receipt.',
                  'To that office\'s senior officer - in the district, the '
                      'District Magistrate\'s public hearing.',
                  'Online: CPGRAMS (pgportal.gov.in) for central departments, '
                      'and the state\'s own grievance portal or the Chief '
                      'Minister\'s helpline. Note the complaint number.',
                  'The appeal most people never file: if a complaint is closed '
                      'as "disposed of" and nothing was done, CPGRAMS lets you '
                      'appeal on that same complaint. State portals also have a '
                      'way to record dissatisfaction.',
                  'Right to Information: for ₹10, ask what action was taken on '
                      'your complaint, which officer holds it, and a copy of the '
                      'file notings. "Write an RTI application" is in this goal.',
                  'For services under the state\'s Right to Services Act - '
                      'certificates, connections, licences - appeal to the '
                      'appellate officer once the time limit passes; the officer '
                      'can be fined for the delay.',
                ],
        ),
        const SizedBox(height: 10),
        ToolNote(hi
            ? 'भ्रष्टाचार हो तो इसी लक्ष्य में "रिश्वत माँगी गई" देखें। अदालत तक जाना पड़े '
                'तो मुफ़्त वकील के लिए "मुफ़्त कानूनी सहायता"।'
            : 'If there is corruption, see "Bribe demanded" in this goal. If it '
                'has to go to court, see "Free legal aid" for a free lawyer.'),
        const SourceNote(text: 'CPGRAMS', url: _pgUrl),
      ],
    );
  }
}
