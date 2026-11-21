import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Four screens: the transgender identity certificate, keeping what you
/// have when the family moves, voting without reaching the booth, and
/// checking a reservation roster.
///
/// The transgender screen is deliberately short on process. The law
/// changed in 2026, the amendment is in force and is being challenged in
/// the Supreme Court, and the rules under it are still settling. Walking
/// someone through a procedure that may have changed last month would
/// cost them a wasted journey at best, so this screen states what is
/// settled, says plainly what is not, and routes to the two places that
/// hold the current answer.

const _transgenderUrl = 'https://transgender.dosje.gov.in/';
const _nalsaUrl = 'https://nalsa.gov.in/';
const _nvspUrl = 'https://voters.eci.gov.in/';
const _eciUrl = 'https://www.eci.gov.in/';
const _onorcUrl = 'https://nfsa.gov.in/';
const _eshramUrl = 'https://eshram.gov.in/';

/// Absentee voting at home. Source: Election Commission of India.
const homeVotingAge = 85;
const homeVotingDisabilityPercent = 40;

/// Central government shares in direct recruitment and central education
/// institutions. State shares are set by each state and differ, which the
/// screen says.
const shareSc = 15.0;
const shareSt = 7.5;
const shareObc = 27.0;
const shareEws = 10.0;
const sharePwd = 4.0;

// --- Transgender identity certificate ---------------------------------

class TransgenderIdPage extends StatelessWidget {
  const TransgenderIdPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 10,
      title: hi ? 'ट्रांसजेंडर पहचान पत्र' : 'Transgender ID card',
      children: [
        ToolAnswer(
          headline: hi
              ? 'यह क़ानून 2026 में बदला है'
              : 'This law changed in 2026',
          detail: hi
              ? 'ट्रांसजेंडर व्यक्ति (अधिकारों का संरक्षण) अधिनियम में 2026 में '
                  'संशोधन हुआ, जो मई 2026 से लागू है। उसके बाद पहचान प्रमाण पत्र की '
                  'प्रक्रिया बदल गई है — पहले यह स्वयं की पहचान के आधार पर मिलता '
                  'था, अब मेडिकल बोर्ड की जाँच के बाद ज़िलाधिकारी जारी करता है। यह '
                  'संशोधन सर्वोच्च न्यायालय में चुनौती के अधीन है और उसके नियम अभी '
                  'बन रहे हैं। इसलिए यह ऐप यहाँ क़दम-दर-क़दम प्रक्रिया नहीं बताता: '
                  'जो आज सही है वह अगले महीने बदल सकता है, और ग़लत जानकारी पर किया '
                  'गया चक्कर आपका नुक़सान है।'
              : 'The Transgender Persons (Protection of Rights) Act was '
                  'amended in 2026, and the amendment has been in force '
                  'since May 2026. The process for the identity certificate '
                  'changed with it - it used to be issued on self-perceived '
                  'identity, and is now issued by the District Magistrate '
                  'after examination by a medical board. The amendment is '
                  'under challenge in the Supreme Court and the rules under '
                  'it are still settling. So this app does not set out a '
                  'step-by-step process here: what is right today may change '
                  'next month, and a journey made on wrong information costs '
                  'you.',
          tone: ToolTone.warn,
          icon: Icons.gavel_outlined,
        ),
        const SizedBox(height: 14),
        Text(hi ? 'जो तय है' : 'What is settled',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'जो पहचान पत्र 2026 के संशोधन से पहले जारी हो चुके हैं, वे चलते '
                      'रहेंगे — केंद्र सरकार ने सर्वोच्च न्यायालय में यही कहा है। '
                      'पुराना कार्ड हो तो उसे संभाल कर रखें और उसकी नक़ल भी।',
                  'भेदभाव अब भी मना है: शिक्षा, नौकरी, स्वास्थ्य सेवा, किराये का '
                      'मकान और सार्वजनिक जगहों तक पहुँच में भेदभाव क़ानून के ख़िलाफ़ '
                      'है।',
                  'अस्पताल इलाज से मना नहीं कर सकता, और पहचान पत्र न होने को इलाज '
                      'की शर्त नहीं बनाया जा सकता।',
                  'पहचान पत्र न होने पर भी राशन, आधार, बैंक खाता और वोट का हक़ ख़त्म '
                      'नहीं होता — ये अलग काग़ज़ों पर चलते हैं।',
                ]
              : const [
                  'Identity cards issued before the 2026 amendment stay '
                      'operational - that is what the Union government told '
                      'the Supreme Court. If you hold an older card, keep it '
                      'safe and keep a copy.',
                  'Discrimination is still forbidden: in education, '
                      'employment, healthcare, rented housing and access to '
                      'public places.',
                  'A hospital cannot refuse treatment, and an identity '
                      'document cannot be made a precondition for care.',
                  'Not having the certificate does not end your right to '
                      'rations, Aadhaar, a bank account or a vote - those '
                      'run on separate papers.',
                ],
        ),
        const SizedBox(height: 14),
        Text(hi ? 'आज की सही प्रक्रिया कहाँ से पता करें' : 'Where to find today\'s actual process',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'राष्ट्रीय पोर्टल transgender.dosje.gov.in — आवेदन और उसकी '
                      'स्थिति इसी पर है। पोर्टल में बदलाव होते रहे हैं, इसलिए न '
                      'चले तो अगला क़दम।',
                  'ज़िला समाज कल्याण कार्यालय या ज़िलाधिकारी कार्यालय में जाकर '
                      'लिखित में पूछें कि आज आवेदन की प्रक्रिया क्या है और कौन से '
                      'काग़ज़ चाहिए। लिखित जवाब माँगें — ज़ुबानी जवाब बदल जाता है।',
                  'मुफ़्त कानूनी सलाह के लिए ज़िला विधिक सेवा प्राधिकरण (डीएलएसए), '
                      'जो ज़िला न्यायालय में होता है। इस समय यही सबसे भरोसेमंद जगह '
                      'है, क्योंकि क़ानून की स्थिति बदल रही है और वहाँ वकील मुफ़्त '
                      'मिलता है।',
                  'ट्रांसजेंडर समुदाय के संगठन और राज्य के ट्रांसजेंडर कल्याण बोर्ड '
                      'के पास ताज़ा जानकारी सबसे पहले पहुँचती है — उनसे भी पूछें।',
                ]
              : const [
                  'The national portal, transgender.dosje.gov.in - the '
                      'application and its status are there. The portal has '
                      'been changing, so if it does not work, the next step.',
                  'Go to the district social welfare office or the District '
                      'Magistrate\'s office and ask in writing what the '
                      'process is today and which papers are needed. Ask for '
                      'a written answer - a spoken one changes.',
                  'For free legal advice, the District Legal Services '
                      'Authority at the district court. Right now that is '
                      'the most reliable place, because the law is in flux '
                      'and the lawyer there is free.',
                  'Community organisations and the state transgender welfare '
                      'board hear about changes first - ask them too.',
                ],
        ),
        const SizedBox(height: 10),
        ToolNote(hi
            ? 'राज्यों की अपनी योजनाएँ भी हैं — पेंशन, छात्रवृत्ति, कौशल '
                'प्रशिक्षण, गरिमा गृह (आश्रय) — और वे पहचान पत्र पर निर्भर करती '
                'हैं, इसलिए पूछते समय दोनों के बारे में पूछें।'
            : 'States run schemes of their own - pension, scholarships, '
                'skill training, Garima Greh shelters - and they turn on the '
                'certificate, so ask about both at the same time.'),
        const SourceNote(
            text: 'National portal for transgender persons',
            url: _transgenderUrl),
        const SourceNote(
            text: 'National Legal Services Authority', url: _nalsaUrl),
      ],
    );
  }
}

// --- Moving for work --------------------------------------------------

enum MovingThing { ration, school, vote, work }

class MovingForWorkPage extends StatefulWidget {
  const MovingForWorkPage({super.key});

  @override
  State<MovingForWorkPage> createState() => _MovingForWorkPageState();
}

class _MovingForWorkPageState extends State<MovingForWorkPage> {
  final _things = <MovingThing>{};

  void _toggle(MovingThing t) => setState(() {
        if (!_things.remove(t)) _things.add(t);
      });

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 10,
      title: hi ? 'काम के लिए जाना: जो है वह बना रहे' : 'Moving for work: keep what you have',
      children: [
        ToolNote(hi
            ? 'राज्य बदलने पर जो चीज़ें सबसे ज़्यादा छूटती हैं वे चार हैं: राशन, '
                'बच्चे का स्कूल, वोट और मज़दूरी के काग़ज़। चारों जाने से पहले '
                'संभाले जा सकते हैं, और जाने के बाद संभालना कई गुना मुश्किल होता '
                'है। जो-जो लागू हो, उसे चुनें।'
            : 'Four things get lost most often when a family changes state: '
                'the ration, the child\'s school, the vote, and the work '
                'papers. All four can be handled before leaving, and '
                'handling them afterwards is several times harder. Pick '
                'whichever apply.'),
        ToolQuestion(hi ? 'क्या-क्या साथ चाहिए' : 'What needs to come with you'),
        SelectionTile(
          label: hi ? 'राशन' : 'The ration',
          selected: _things.contains(MovingThing.ration),
          onTap: () => _toggle(MovingThing.ration),
        ),
        SelectionTile(
          label: hi ? 'बच्चे का स्कूल' : 'The child\'s school',
          selected: _things.contains(MovingThing.school),
          onTap: () => _toggle(MovingThing.school),
        ),
        SelectionTile(
          label: hi ? 'वोट' : 'The vote',
          selected: _things.contains(MovingThing.vote),
          onTap: () => _toggle(MovingThing.vote),
        ),
        SelectionTile(
          label: hi ? 'मज़दूरी और उसके काग़ज़' : 'Wages and work papers',
          selected: _things.contains(MovingThing.work),
          onTap: () => _toggle(MovingThing.work),
        ),
        if (_things.contains(MovingThing.ration)) ...[
          const SizedBox(height: 10),
          ToolAnswer(
            headline: hi ? 'राशन कार्ड पूरे देश में चलता है' : 'The ration card works across the country',
            detail: hi
                ? 'एक राष्ट्र एक राशन कार्ड के बाद वही कार्ड किसी भी राज्य की किसी '
                    'भी उचित दर दुकान पर चलता है — कार्ड बदलवाने या नया बनवाने की '
                    'ज़रूरत नहीं। शर्त एक है: कार्ड में जिसका नाम है, उसका आधार कार्ड '
                    'से जुड़ा हो और बायोमीट्रिक मशीन पर अँगूठा लगे। जाने से पहले '
                    'पुरानी दुकान पर एक बार जाकर यह जाँच लें कि सबका आधार जुड़ा है, '
                    'और "मेरा राशन" ऐप फ़ोन में डाल लें। आधे हिस्से का राशन एक राज्य '
                    'में और आधा दूसरे में भी लिया जा सकता है।'
                : 'Under One Nation One Ration Card the same card works at '
                    'any fair price shop in any state - there is no need to '
                    'change it or make a new one. There is one condition: '
                    'each person named on the card must have Aadhaar linked '
                    'to it and must give a thumb impression on the '
                    'biometric machine. Before leaving, check at the old '
                    'shop that everyone\'s Aadhaar is linked, and put the '
                    '"Mera Ration" app on the phone. Part of the quota can '
                    'be drawn in one state and the rest in another.',
            tone: ToolTone.good,
            icon: Icons.rice_bowl_outlined,
          ),
        ],
        if (_things.contains(MovingThing.school)) ...[
          const SizedBox(height: 10),
          ToolAnswer(
            headline: hi ? 'दाख़िला साल के बीच में भी होना है' : 'Admission is due even mid-year',
            detail: hi
                ? 'शिक्षा का अधिकार अधिनियम कहता है कि 6 से 14 साल के बच्चे को साल '
                    'के किसी भी समय दाख़िला मिलेगा, और काग़ज़ न होने पर दाख़िला रोका '
                    'नहीं जाएगा। स्थानांतरण प्रमाण पत्र (टीसी) न हो तो भी स्कूल मना '
                    'नहीं कर सकता — यह साफ़ लिखा है। फिर भी जाने से पहले पुराने '
                    'स्कूल से टीसी और रिपोर्ट कार्ड ले लें, और दोनों की फ़ोटो फ़ोन '
                    'में रख लें; इससे नए स्कूल में कक्षा तय करना आसान होता है। मना '
                    'करने पर ज़िला शिक्षा अधिकारी के पास लिखित शिकायत दें।'
                : 'The Right to Education Act says a child aged 6 to 14 is '
                    'to be admitted at any time of the year, and admission '
                    'is not to be withheld for want of documents. A school '
                    'cannot refuse for want of a transfer certificate - that '
                    'is stated plainly. Even so, collect the TC and the '
                    'report card from the old school before leaving, and '
                    'photograph both; it makes placing the child in the '
                    'right class easier. If a school refuses, give a written '
                    'complaint to the district education officer.',
            tone: ToolTone.good,
            icon: Icons.school_outlined,
          ),
        ],
        if (_things.contains(MovingThing.vote)) ...[
          const SizedBox(height: 10),
          ToolAnswer(
            headline: hi ? 'वोट नए पते पर ले जाना पड़ता है' : 'The vote has to be moved to the new address',
            detail: hi
                ? 'वोट अपने आप साथ नहीं आता — मतदाता सूची पते से जुड़ी है। नए पते '
                    'पर नाम जोड़ने के लिए फ़ॉर्म 8 भरना होता है, जो voters.eci.gov.in '
                    'पर या बीएलओ के पास मुफ़्त मिलता है। पते का कोई प्रमाण लगता है, '
                    'और किराये का मकान होने पर किरायानामा या बिजली-पानी का बिल भी '
                    'चलता है। पुराने पते से नाम हटवाना भी इसी फ़ॉर्म से होता है; दो '
                    'जगह नाम रखना क़ानूनन ग़लत है। और ध्यान रहे: चुनाव की घोषणा के '
                    'बाद सूची में बदलाव रुक जाते हैं, इसलिए यह काम पहले कर लें।'
                : 'The vote does not travel on its own - the electoral roll '
                    'is tied to an address. To get your name onto the roll at '
                    'the new address, fill Form 8, free on '
                    'voters.eci.gov.in or from the booth level officer. Some '
                    'proof of address is needed, and for a rented house a '
                    'rent agreement or an electricity or water bill will do. '
                    'The same form is used to get the name removed from the '
                    'old address; being on the roll in two places is '
                    'unlawful. And note: once an election is announced, '
                    'changes to the roll stop, so do this beforehand.',
            tone: ToolTone.plain,
            icon: Icons.how_to_vote_outlined,
          ),
        ],
        if (_things.contains(MovingThing.work)) ...[
          const SizedBox(height: 10),
          ToolAnswer(
            headline: hi ? 'जाने से पहले काग़ज़ बना लें' : 'Make the papers before you go',
            detail: hi
                ? 'ई-श्रम पर पंजीकरण मुफ़्त है और पूरे देश में एक ही रहता है; यह उन '
                    'योजनाओं की कड़ी है जो असंगठित मज़दूरों के लिए बनती हैं। निर्माण '
                    'मज़दूर हों तो पुराने राज्य का श्रमिक कार्ड साथ ले जाएँ और नए '
                    'राज्य के बोर्ड में भी पंजीकरण के बारे में पूछें। ठेकेदार के साथ '
                    'जा रहे हों तो उसका नाम, फ़ोन नंबर और जहाँ काम है उसका पता '
                    'लिखकर घर में किसी को दे दें, और तय मज़दूरी किसी संदेश में '
                    'लिखवाकर रख लें — मज़दूरी के झगड़े में यही एक काग़ज़ काम आता है। '
                    'मनरेगा का जॉब कार्ड चालू रहने दें; लौटने पर वही काम देता है।'
                : 'Registration on e-Shram is free and stays the same across '
                    'the country; it is the thread that connects the schemes '
                    'made for unorganised workers. A construction worker '
                    'should carry the old state\'s labour card and ask about '
                    'registering with the new state\'s board as well. If you '
                    'are going with a contractor, write down his name, phone '
                    'number and the address of the worksite and leave it '
                    'with someone at home, and get the agreed wage into a '
                    'message you keep - in a wage dispute that one paper is '
                    'what works. Keep the MGNREGA job card alive; it is what '
                    'gives work when you come back.',
            tone: ToolTone.plain,
            icon: Icons.badge_outlined,
          ),
        ],
        if (_things.isNotEmpty) ...[
          const SizedBox(height: 14),
          ToolDonts(
            heading: hi ? 'जाने से पहले' : 'Before leaving',
            items: hi
                ? const [
                    'असली काग़ज़ किसी ठेकेदार या मालिक के पास न छोड़ें — नक़ल दें, '
                        'असली अपने पास रखें',
                    'सब काग़ज़ों की फ़ोटो फ़ोन में और किसी और के फ़ोन में भी रखें; '
                        'फ़ोन खोने पर यही बचता है',
                    'अपने गाँव के किसी एक भरोसेमंद व्यक्ति का नंबर याद रखें या लिख '
                        'लें, फ़ोन से अलग',
                    'पेशगी के बदले काम करने की शर्त न मानें — वह बंधुआ मज़दूरी है '
                        'और क़ानूनन मना है; फँस जाएँ तो 1800-11-3090 पर फ़ोन करें',
                  ]
                : const [
                    'Do not leave original documents with a contractor or an '
                        'employer - give copies and keep the originals',
                    'Keep photographs of every paper on the phone and on '
                        'somebody else\'s phone too; that is what survives '
                        'a lost phone',
                    'Memorise or write down the number of one trusted person '
                        'in your village, separately from the phone',
                    'Do not accept working against an advance - that is '
                        'bonded labour and it is forbidden by law; if you '
                        'are trapped, call 1800-11-3090',
                  ],
          ),
          const SourceNote(
              text: 'One Nation One Ration Card - NFSA', url: _onorcUrl),
          const SourceNote(text: 'e-Shram', url: _eshramUrl),
          const SourceNote(text: 'Voter services portal', url: _nvspUrl),
        ],
      ],
    );
  }
}

// --- Voting from home -------------------------------------------------

class HomeVotingPage extends StatefulWidget {
  const HomeVotingPage({super.key});

  @override
  State<HomeVotingPage> createState() => _HomeVotingPageState();
}

class _HomeVotingPageState extends State<HomeVotingPage> {
  final _age = TextEditingController();
  final _disability = TextEditingController();

  @override
  void dispose() {
    _age.dispose();
    _disability.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final age = int.tryParse(_age.text.trim());
    final pct = int.tryParse(_disability.text.trim());
    final byAge = age != null && age >= homeVotingAge;
    final byDisability = pct != null && pct >= homeVotingDisabilityPercent;
    final asked = (age != null && age > 0) || (pct != null && pct > 0);

    return ToolScaffold(
      goal: 10,
      title: hi ? 'बूथ तक न पहुँच पाने पर वोट' : 'Voting when you cannot reach the booth',
      children: [
        ToolNote(hi
            ? 'चुनाव आयोग बहुत बुज़ुर्ग और दिव्यांग मतदाताओं को घर से डाक मतपत्र से '
                'वोट देने की सुविधा देता है। यह सुविधा हर चुनाव में अपने आप नहीं '
                'मिलती — इसके लिए चुनाव की घोषणा के बाद एक फ़ॉर्म भरना पड़ता है, और '
                'उसकी तारीख़ निकल जाना सबसे आम चूक है।'
            : 'The Election Commission lets very old voters and voters with '
                'disability vote from home by postal ballot. It is not given '
                'automatically at every election - a form has to be filed '
                'after the election is announced, and missing that date is '
                'the commonest slip.'),
        ToolQuestion(hi ? 'उम्र और दिव्यांगता' : 'Age and disability'),
        ToolNumber(
          controller: _age,
          label: hi ? 'उम्र (साल)' : 'Age (years)',
          maxDigits: 3,
          icon: Icons.person_outline,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolNumber(
          controller: _disability,
          label: hi
              ? 'प्रमाण पत्र पर दिव्यांगता (%), न हो तो 0'
              : 'Disability on the certificate (%), or 0',
          maxDigits: 3,
          icon: Icons.accessible_outlined,
          onChanged: (_) => setState(() {}),
        ),
        if (asked) ...[
          if (byAge || byDisability)
            ToolAnswer(
              headline: hi ? 'घर से वोट की पात्रता है' : 'You can ask to vote from home',
              detail: hi
                  ? (byAge
                          ? '$homeVotingAge साल या उससे ऊपर के मतदाता इस सुविधा के '
                              'पात्र हैं। '
                          : 'प्रमाण पत्र पर $homeVotingDisabilityPercent प्रतिशत या '
                              'उससे अधिक दिव्यांगता वाले मतदाता इस सुविधा के पात्र '
                              'हैं। ') +
                      'आगे का तरीक़ा नीचे है।'
                  : (byAge
                          ? 'Voters aged $homeVotingAge and above are '
                              'eligible for this. '
                          : 'Voters with $homeVotingDisabilityPercent per '
                              'cent disability or more on the certificate '
                              'are eligible for this. ') +
                      'The steps are below.',
              tone: ToolTone.good,
              icon: Icons.how_to_vote_outlined,
            )
          else
            ToolAnswer(
              headline: hi ? 'घर से वोट की पात्रता नहीं बनती' : 'Home voting does not apply',
              detail: hi
                  ? 'घर से वोट की सुविधा $homeVotingAge साल या उससे ऊपर, और प्रमाण '
                      'पत्र पर $homeVotingDisabilityPercent प्रतिशत या उससे अधिक '
                      'दिव्यांगता वाले मतदाताओं के लिए है। लेकिन बूथ पर पहुँचने में '
                      'दिक़्क़त हो तो और भी हक़ हैं, जो हर मतदाता के लिए हैं — नीचे '
                      'देखें।'
                  : 'Home voting is for voters aged $homeVotingAge and above '
                      'and for voters with $homeVotingDisabilityPercent per '
                      'cent disability or more on the certificate. But if '
                      'reaching the booth is hard there are other rights, '
                      'open to every voter - see below.',
              tone: ToolTone.plain,
              icon: Icons.info_outlined,
            ),
          if (byAge || byDisability) ...[
            const SizedBox(height: 12),
            Text(hi ? 'क़दम' : 'The steps',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ToolSteps(
              steps: hi
                  ? const [
                      'चुनाव की घोषणा के बाद बीएलओ (बूथ लेवल अधिकारी) घर आकर '
                          'फ़ॉर्म 12डी देता है। न आए तो यह फ़ॉर्म निर्वाचन अधिकारी '
                          'के कार्यालय से भी मिलता है।',
                      'फ़ॉर्म 12डी भरकर बीएलओ को दें। दिव्यांगता के आधार पर आवेदन हो '
                          'तो प्रमाण पत्र की नक़ल साथ लगाएँ।',
                      'यह फ़ॉर्म अधिसूचना के कुछ ही दिनों के भीतर देना होता है — '
                          'तारीख़ निकल जाने पर इस चुनाव में सुविधा नहीं मिलती। '
                          'घोषणा होते ही बीएलओ से पूछ लें कि आख़िरी तारीख़ क्या है।',
                      'मंज़ूरी के बाद मतदान दल तय दिन घर आता है, डाक मतपत्र साथ '
                          'लाता है, और वोट गुप्त रहता है। घर पर कोई न कोई मौजूद रहे।',
                      'एक बात ज़रूरी: घर से वोट चुन लेने के बाद उसी चुनाव में बूथ पर '
                          'जाकर वोट नहीं दिया जा सकता। दोनों में से एक ही।',
                    ]
                  : const [
                      'After the election is announced, the booth level '
                          'officer brings Form 12D to the house. If nobody '
                          'comes, the form is also available at the returning '
                          'officer\'s office.',
                      'Fill Form 12D and give it to the BLO. If you are '
                          'applying on the ground of disability, attach a '
                          'copy of the certificate.',
                      'The form has to be given within a few days of the '
                          'notification - once that date passes the facility '
                          'is not available for that election. As soon as the '
                          'election is announced, ask the BLO what the last '
                          'date is.',
                      'Once it is approved a polling team comes to the house '
                          'on a fixed day with the postal ballot, and the '
                          'vote stays secret. Somebody should be at home.',
                      'One thing matters: having chosen to vote from home '
                          'you cannot then vote at the booth in the same '
                          'election. It is one or the other.',
                    ],
            ),
          ],
          const SizedBox(height: 14),
          Text(hi ? 'बूथ पर हर मतदाता के हक़' : 'Rights of every voter at the booth',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            numbered: false,
            steps: hi
                ? const [
                    'बूथ भूतल पर होना चाहिए और वहाँ रैंप होना चाहिए',
                    'व्हीलचेयर की माँग पहले से की जा सकती है, और बूथ तक लाने-ले '
                        'जाने की मुफ़्त व्यवस्था भी',
                    'बुज़ुर्ग और दिव्यांग मतदाताओं को लाइन में खड़े होने की ज़रूरत '
                        'नहीं — पहले वोट देने का हक़ है',
                    'देख न पाने वाले मतदाता ब्रेल मतपत्र माँग सकते हैं, या अपनी '
                        'पसंद का साथी ले जा सकते हैं',
                    'सक्षम-ईसीआई ऐप से व्हीलचेयर और सहायता की माँग पहले से दर्ज की '
                        'जा सकती है',
                  ]
                : const [
                    'The booth must be on the ground floor and must have a '
                        'ramp',
                    'A wheelchair can be asked for in advance, and so can '
                        'free transport to the booth and back',
                    'Older voters and voters with disability do not have to '
                        'stand in the queue - they have the right to vote '
                        'first',
                    'A voter who cannot see may ask for a braille ballot, or '
                        'take a companion of their own choosing',
                    'The Saksham-ECI app can be used to ask for a wheelchair '
                        'and assistance beforehand',
                  ],
          ),
          const SizedBox(height: 10),
          ToolNote(hi
              ? 'सुविधाओं और आख़िरी तारीख़ों का ब्योरा हर चुनाव में अलग होता है, और '
                  'वह अपने ज़िले के निर्वाचन अधिकारी के कार्यालय या चुनाव आयोग की '
                  'वेबसाइट से ही पक्का होता है। बीएलओ का नंबर voters.eci.gov.in पर '
                  'अपने मतदाता पहचान पत्र संख्या से मिल जाता है।'
              : 'The details and the last dates differ at every election, '
                  'and only your district election office or the Election '
                  'Commission\'s own site can confirm them. The BLO\'s '
                  'number can be found on voters.eci.gov.in from your voter '
                  'ID number.'),
          const SourceNote(text: 'Election Commission of India', url: _eciUrl),
          const SourceNote(text: 'Voter services portal', url: _nvspUrl),
        ],
      ],
    );
  }
}

// --- Reservation roster check -----------------------------------------

class RosterCheckPage extends StatefulWidget {
  const RosterCheckPage({super.key});

  @override
  State<RosterCheckPage> createState() => _RosterCheckPageState();
}

class _RosterCheckPageState extends State<RosterCheckPage> {
  final _total = TextEditingController();

  @override
  void dispose() {
    _total.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final total = int.tryParse(_total.text.trim());

    String due(double share) {
      if (total == null || total <= 0) return '';
      final n = total * share / 100;
      return '${n.floor()}${n.floor() == n ? '' : '–${n.ceil()}'}';
    }

    return ToolScaffold(
      goal: 10,
      title: hi ? 'क्या आरक्षण का हिस्सा माना जा रहा है' : 'Is the reservation share being followed',
      children: [
        ToolNote(hi
            ? 'भर्ती या दाख़िले की सूची में कितनी सीटें किस वर्ग की होनी चाहिए, यह '
                'यहाँ गिना जा सकता है। नीचे के प्रतिशत केंद्र सरकार की सीधी भर्ती '
                'और केंद्रीय शिक्षण संस्थानों के हैं। राज्यों के अपने प्रतिशत इससे '
                'अलग हैं — कहीं कम, कहीं ज़्यादा — इसलिए राज्य की भर्ती में अपने '
                'राज्य का आदेश देखना ज़रूरी है।'
            : 'How many seats in a recruitment or admission list should '
                'belong to which category can be counted here. The '
                'percentages below are for central government direct '
                'recruitment and central educational institutions. States '
                'set their own, which differ - lower in some, higher in '
                'others - so for a state recruitment the state\'s own order '
                'is what to look at.'),
        ToolQuestion(hi ? 'सूची में कुल कितने पद या सीटें हैं' : 'How many posts or seats in all'),
        ToolNumber(
          controller: _total,
          label: hi ? 'कुल संख्या' : 'Total number',
          maxDigits: 6,
          icon: Icons.format_list_numbered,
          onChanged: (_) => setState(() {}),
        ),
        if (total != null && total > 0) ...[
          ToolAnswer(
            headline: hi
                ? '$total में से हिस्सा इस तरह बनता है'
                : 'Out of $total, the shares work out like this',
            detail: hi
                ? 'यह सीधा हिसाब है। असल सूची में कौन सा पद किस वर्ग का होगा, यह '
                    '"रोस्टर" तय करता है — एक बनी-बनाई क्रम सूची — इसलिए छोटी भर्ती '
                    'में कोई वर्ग एक चक्र में छूट सकता है और अगले चक्र में आता है। '
                    'इसी वजह से एक विज्ञापन को अकेले देखकर यह नहीं कहा जा सकता कि '
                    'नियम टूटा है; रोस्टर पूरा देखना पड़ता है।'
                : 'That is the plain arithmetic. Which particular post goes '
                    'to which category in the actual list is decided by the '
                    '"roster" - a fixed running order - so in a small '
                    'recruitment a category can be skipped in one cycle and '
                    'come up in the next. Which is why a single '
                    'advertisement on its own does not show a rule has been '
                    'broken; the whole roster has to be seen.',
            tone: ToolTone.plain,
            icon: Icons.balance_outlined,
          ),
          const SizedBox(height: 10),
          ToolLine(hi ? 'अनुसूचित जाति' : 'Scheduled Castes',
              '${due(shareSc)}  (${shareSc.toStringAsFixed(0)}%)'),
          ToolLine(hi ? 'अनुसूचित जनजाति' : 'Scheduled Tribes',
              '${due(shareSt)}  (${shareSt.toStringAsFixed(1)}%)'),
          ToolLine(hi ? 'अन्य पिछड़ा वर्ग' : 'Other Backward Classes',
              '${due(shareObc)}  (${shareObc.toStringAsFixed(0)}%)'),
          ToolLine(hi ? 'आर्थिक रूप से कमज़ोर वर्ग' : 'Economically Weaker Sections',
              '${due(shareEws)}  (${shareEws.toStringAsFixed(0)}%)'),
          ToolLine(hi ? 'दिव्यांगजन (क्षैतिज)' : 'Persons with disability (horizontal)',
              '${due(sharePwd)}  (${sharePwd.toStringAsFixed(0)}%)'),
          const SizedBox(height: 10),
          ToolNote(hi
              ? 'दिव्यांगजन का आरक्षण "क्षैतिज" है: यह ऊपर के वर्गों के अलावा नहीं, '
                  'उनके भीतर से गिना जाता है। महिलाओं का आरक्षण, जहाँ है, वह भी इसी '
                  'तरह भीतर से गिना जाता है। इसीलिए सब प्रतिशत जोड़कर 100 नहीं बनते '
                  'और बनाने भी नहीं चाहिए।'
              : 'The disability quota is "horizontal": it is counted from '
                  'within the categories above, not in addition to them. '
                  'Women\'s reservation, where it exists, is counted the '
                  'same way from within. Which is why the percentages do '
                  'not add to 100 and are not meant to.'),
          const SizedBox(height: 14),
          Text(hi ? 'गड़बड़ लगे तो' : 'If something looks wrong',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'विज्ञापन या सूची की नक़ल संभालकर रखें, तारीख़ के साथ।',
                    'सूचना का अधिकार का आवेदन लगाकर उस पद का रोस्टर रजिस्टर और '
                        'पिछले चक्रों का ब्योरा माँगें। ₹10 में यह हो जाता है और यही '
                        'सबसे काम का काग़ज़ होता है, क्योंकि रोस्टर के बिना कुछ साबित '
                        'नहीं होता।',
                    'उसी विभाग के संपर्क अधिकारी (लायज़न ऑफ़िसर) को लिखित शिकायत दें '
                        '— हर विभाग में आरक्षण देखने के लिए यही अधिकारी होता है।',
                    'उससे भी न हो तो राष्ट्रीय अनुसूचित जाति आयोग, अनुसूचित जनजाति '
                        'आयोग, पिछड़ा वर्ग आयोग या दिव्यांगजन आयुक्त के पास शिकायत '
                        'दी जा सकती है — जो वर्ग का मामला हो, उसके आयोग में।',
                    'मुफ़्त कानूनी सलाह के लिए ज़िला विधिक सेवा प्राधिकरण।',
                  ]
                : const [
                    'Keep a copy of the advertisement or the list, with the '
                        'date.',
                    'File a Right to Information application asking for the '
                        'roster register for that post and the record of '
                        'earlier cycles. It costs ₹10 and it is the most '
                        'useful paper there is, because nothing is provable '
                        'without the roster.',
                    'Give a written complaint to the department\'s liaison '
                        'officer - every department has one whose job is '
                        'reservation.',
                    'If that fails, a complaint can go to the National '
                        'Commission for Scheduled Castes, for Scheduled '
                        'Tribes, for Backward Classes, or to the Chief '
                        'Commissioner for Persons with Disabilities - to the '
                        'commission for the category concerned.',
                    'For free legal advice, the District Legal Services '
                        'Authority.',
                  ],
          ),
          const SourceNote(
              text: 'National Legal Services Authority', url: _nalsaUrl),
        ],
      ],
    );
  }
}
