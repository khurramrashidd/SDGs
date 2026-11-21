import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Two screens for older people: maintenance from children, and the
/// concessions that actually exist.
///
/// The concessions screen says plainly that the railway fare concession
/// was withdrawn and has not come back. That is the opposite of a
/// benefit, but it is the single most useful thing on the screen: an old
/// man who travels to the station expecting half fare, and finds he
/// cannot afford the ticket, has been failed by a cheerful list.

const _elderlineUrl = 'https://socialjustice.gov.in/';
const _nalsaUrl = 'https://nalsa.gov.in/';
const _vayoshriUrl = 'https://alimco.in/';

/// Maintenance and Welfare of Parents and Senior Citizens Act 2007.
const seniorCitizenAge = 60;
const maintenanceMonthlyCap = 10000;
const maintenanceDisposalDays = 90;
const maintenanceAppealDays = 60;
const abandonmentJailMonths = 3;
const elderlineNumber = '14567';

enum MaintenanceCase { notSupported, gaveProperty, thrownOut, childless }

class SeniorMaintenancePage extends StatefulWidget {
  const SeniorMaintenancePage({super.key});

  @override
  State<SeniorMaintenancePage> createState() => _SeniorMaintenancePageState();
}

class _SeniorMaintenancePageState extends State<SeniorMaintenancePage> {
  MaintenanceCase? _case;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 10,
      title: hi ? 'बुज़ुर्ग: बच्चों से भरण-पोषण' : 'Senior citizen: maintenance from children',
      children: [
        ToolNote(hi
            ? 'माता-पिता और वरिष्ठ नागरिकों के भरण-पोषण और कल्याण अधिनियम 2007 में '
                'एक ख़ास बात है जो इसे आम मुक़दमे से अलग करती है: सुनवाई '
                'ट्रिब्यूनल में होती है, आवेदन पर कोई शुल्क नहीं, और क़ानून कहता है '
                'कि वकील की ज़रूरत नहीं — बुज़ुर्ग ख़ुद अपनी बात रख सकते हैं। यही '
                'वजह है कि यह रास्ता अदालत से सस्ता और तेज़ है।'
            : 'One thing sets the Maintenance and Welfare of Parents and '
                'Senior Citizens Act 2007 apart from an ordinary case: it is '
                'heard by a Tribunal, the application carries no fee, and '
                'the Act says no lawyer is needed - the senior citizen can '
                'put the case themselves. Which is why this route is cheaper '
                'and faster than a court.'),
        ToolQuestion(hi ? 'बात क्या है' : 'What is the situation'),
        SelectionTile(
          label: hi
              ? 'बच्चे ख़र्च नहीं दे रहे'
              : 'The children are not supporting me',
          selected: _case == MaintenanceCase.notSupported,
          onTap: () => setState(() => _case = MaintenanceCase.notSupported),
        ),
        SelectionTile(
          label: hi
              ? 'मकान या ज़मीन बच्चे के नाम कर दी, अब देखभाल नहीं'
              : 'I transferred the house or land, now there is no care',
          selected: _case == MaintenanceCase.gaveProperty,
          onTap: () => setState(() => _case = MaintenanceCase.gaveProperty),
        ),
        SelectionTile(
          label: hi ? 'घर से निकाल दिया गया' : 'I have been turned out of the house',
          selected: _case == MaintenanceCase.thrownOut,
          onTap: () => setState(() => _case = MaintenanceCase.thrownOut),
        ),
        SelectionTile(
          label: hi ? 'मेरी कोई संतान नहीं है' : 'I have no children',
          selected: _case == MaintenanceCase.childless,
          onTap: () => setState(() => _case = MaintenanceCase.childless),
        ),
        if (_case == MaintenanceCase.notSupported)
          ToolAnswer(
            headline: hi
                ? 'ट्रिब्यूनल हर महीने की राशि का आदेश दे सकता है'
                : 'The Tribunal can order a monthly amount',
            detail: hi
                ? 'उम्र $seniorCitizenAge साल या उससे ऊपर हो, और अपनी आय या संपत्ति '
                    'से गुज़ारा न हो सके, तो बेटे, बेटी, पोते-पोतियों — और बहू तथा '
                    'दामाद — से भरण-पोषण माँगा जा सकता है। ट्रिब्यूनल अधिकतम '
                    '₹$maintenanceMonthlyCap महीना तक का आदेश दे सकता है। आदेश न माने '
                    'तो वसूली हो सकती है और सज़ा भी।'
                : 'If you are $seniorCitizenAge or above and cannot maintain '
                    'yourself from your own income or property, maintenance '
                    'can be claimed from sons, daughters and grandchildren - '
                    'and from a daughter-in-law or son-in-law. The Tribunal '
                    'can order up to ₹$maintenanceMonthlyCap a month. '
                    'Ignoring the order can lead to recovery and to '
                    'punishment.',
            tone: ToolTone.good,
            icon: Icons.elderly_outlined,
          ),
        if (_case == MaintenanceCase.gaveProperty)
          ToolAnswer(
            headline: hi ? 'वह हस्तांतरण रद्द हो सकता है' : 'That transfer can be set aside',
            detail: hi
                ? 'यह इस क़ानून का सबसे ताक़तवर हिस्सा है। अगर बुज़ुर्ग ने मकान या '
                    'ज़मीन इस शर्त पर दी थी कि देखभाल और ज़रूरतें पूरी की जाएँगी, और '
                    'वह नहीं हुआ, तो क़ानून उस हस्तांतरण को धोखे या दबाव से हुआ '
                    'मानता है और ट्रिब्यूनल उसे शून्य घोषित कर सकता है। ज़रूरी बात: '
                    'वह शर्त साबित हो सके तो मामला बहुत मज़बूत होता है, इसलिए '
                    'दानपत्र या बैनामे की नक़ल, और उस समय के गवाह — दोनों सामने '
                    'रखें। आगे किसी के नाम कुछ करने से पहले देखभाल की शर्त काग़ज़ '
                    'में ज़रूर लिखवाएँ।'
                : 'This is the strongest part of the Act. If the senior '
                    'citizen made over a house or land on the condition that '
                    'they would be cared for and their needs met, and that '
                    'has not happened, the law treats the transfer as made '
                    'by fraud or coercion and the Tribunal can declare it '
                    'void. One thing matters: the case is far stronger when '
                    'the condition can be shown, so put the gift deed or '
                    'sale deed and the witnesses of that time in front of '
                    'the Tribunal. Before making anything over to anyone in '
                    'future, get the condition of care written into the '
                    'paper.',
            tone: ToolTone.good,
            icon: Icons.home_outlined,
          ),
        if (_case == MaintenanceCase.thrownOut)
          ToolAnswer(
            headline: hi ? 'छोड़ देना अपराध है' : 'Abandonment is an offence',
            detail: hi
                ? 'बुज़ुर्ग को छोड़ देना इस अधिनियम में अपराध है, जिसकी सज़ा '
                    '$abandonmentJailMonths महीने तक की जेल या जुर्माना या दोनों है। '
                    'अभी के लिए: $elderlineNumber (एल्डरलाइन) पर फ़ोन करें — यह देश '
                    'भर में मुफ़्त है और रहने, खाने तथा कानूनी मदद का इंतज़ाम कराती '
                    'है। ख़तरा हो तो 112 पर। साथ ही ट्रिब्यूनल में आवेदन दें: वह घर '
                    'में वापस रहने देने का आदेश भी दे सकता है, क्योंकि कई अदालतों ने '
                    'माना है कि बुज़ुर्ग का अपने घर में रहने का हक़ बना रहता है।'
                : 'Abandoning a senior citizen is an offence under this Act, '
                    'punishable with up to $abandonmentJailMonths months in '
                    'jail or a fine or both. For right now: call '
                    '$elderlineNumber, the national Elderline - it is free '
                    'across the country and arranges shelter, food and legal '
                    'help. If there is danger, call 112. Alongside that, '
                    'apply to the Tribunal: it can also order that you be '
                    'allowed back into the house, since courts have held '
                    'that a senior citizen\'s right to live in their own '
                    'home survives.',
            tone: ToolTone.bad,
            icon: Icons.phone_in_talk_outlined,
          ),
        if (_case == MaintenanceCase.childless)
          ToolAnswer(
            headline: hi ? 'रिश्तेदार से भी माँगा जा सकता है' : 'It can be claimed from a relative',
            detail: hi
                ? 'संतान न होने पर उस रिश्तेदार से भरण-पोषण माँगा जा सकता है जो '
                    'कानूनी वारिस है और जिसके पास आपकी संपत्ति है या जिसे वह विरासत '
                    'में मिलने वाली है। तर्क सीधा है: जो संपत्ति पाएगा, वह देखभाल '
                    'भी करे।'
                : 'With no children, maintenance can be claimed from a '
                    'relative who is a legal heir and who is in possession '
                    'of your property or stands to inherit it. The reasoning '
                    'is plain: whoever will take the property should do the '
                    'caring.',
            tone: ToolTone.plain,
            icon: Icons.family_restroom_outlined,
          ),
        if (_case != null) ...[
          const SizedBox(height: 14),
          Text(hi ? 'आवेदन कैसे करें' : 'How to apply',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'आवेदन उस ज़िले के भरण-पोषण ट्रिब्यूनल में दें जहाँ आप रहते हैं, '
                        'या रहते थे, या जहाँ बच्चा या रिश्तेदार रहता है। ट्रिब्यूनल '
                        'आम तौर पर एसडीएम या उपजिलाधिकारी के कार्यालय में बैठता है।',
                    'सादे काग़ज़ पर लिखा आवेदन काफ़ी है: अपनी उम्र, आय, ख़र्च, और '
                        'किससे कितना माँग रहे हैं। उम्र का कोई प्रमाण (आधार) साथ '
                        'लगाएँ।',
                    'ख़ुद न जा सकें तो कोई और या कोई पंजीकृत संस्था आपकी ओर से '
                        'आवेदन कर सकती है, आपकी अनुमति से।',
                    'ट्रिब्यूनल को नोटिस तामील होने के $maintenanceDisposalDays दिन '
                        'में मामला निपटाना होता है; ख़ास कारणों में 30 दिन और बढ़ाए जा '
                        'सकते हैं।',
                    'आदेश ठीक न लगे तो $maintenanceAppealDays दिन के भीतर अपीलीय '
                        'ट्रिब्यूनल में अपील हो सकती है।',
                    'मुफ़्त कानूनी मदद के लिए ज़िला विधिक सेवा प्राधिकरण में जाएँ; '
                        'वरिष्ठ नागरिकों को मुफ़्त कानूनी सहायता का हक़ है।',
                  ]
                : const [
                    'Apply to the Maintenance Tribunal of the district where '
                        'you live, or last lived, or where the child or '
                        'relative lives. The Tribunal usually sits in the '
                        'SDM\'s or sub-divisional officer\'s office.',
                    'An application written on plain paper is enough: your '
                        'age, income and expenses, and what you are claiming '
                        'from whom. Attach any proof of age, such as '
                        'Aadhaar.',
                    'If you cannot go yourself, another person or a '
                        'registered organisation can apply on your behalf '
                        'with your authorisation.',
                    'The Tribunal is to dispose of the case within '
                        '$maintenanceDisposalDays days of notice being '
                        'served; it may take 30 days more for recorded '
                        'reasons.',
                    'If the order is not right, an appeal lies to the '
                        'Appellate Tribunal within $maintenanceAppealDays '
                        'days.',
                    'For free legal help go to the District Legal Services '
                        'Authority; senior citizens are entitled to free '
                        'legal aid.',
                  ],
          ),
          const SizedBox(height: 10),
          ToolNote(hi
              ? 'एक बात खुलकर: यह रास्ता अपने ही बच्चों के ख़िलाफ़ जाता है और यह '
                  'आसान नहीं होता। कई ज़िलों में ट्रिब्यूनल पहले सुलह की कोशिश '
                  'करता है, और बहुत मामले वहीं तय हो जाते हैं — आवेदन देने का मतलब '
                  'रिश्ता ख़त्म करना नहीं है। एल्डरलाइन $elderlineNumber पर बात करके '
                  'सलाह भी ली जा सकती है, बिना कुछ दाख़िल किए।'
              : 'One thing said plainly: this route runs against your own '
                  'children and it is not easy. In many districts the '
                  'Tribunal tries conciliation first and a great many cases '
                  'are settled there - filing an application does not mean '
                  'ending the relationship. You can also talk it through on '
                  'the Elderline, $elderlineNumber, without filing '
                  'anything.'),
          const SourceNote(
              text: 'National Legal Services Authority', url: _nalsaUrl),
        ],
      ],
    );
  }
}

class SeniorConcessionsPage extends StatelessWidget {
  const SeniorConcessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 10,
      title: hi ? 'बुज़ुर्गों को मिलने वाली छूट' : 'Senior citizen concessions',
      children: [
        ToolNote(hi
            ? 'नीचे वही है जो सच में मिलता है, और वह भी जो लोग मिलना समझते हैं '
                'लेकिन मिलता नहीं। दूसरी सूची पहली से ज़्यादा काम की है, क्योंकि '
                'ग़लत उम्मीद में किया गया सफ़र महँगा पड़ता है।'
            : 'Below is what is actually available, and also what people '
                'believe is available and is not. The second list is the '
                'more useful of the two, because a journey made on a wrong '
                'expectation is expensive.'),
        const SizedBox(height: 12),
        ToolAnswer(
          headline: hi
              ? 'रेल किराये में छूट अभी बंद है'
              : 'The railway fare concession is not running',
          detail: hi
              ? 'वरिष्ठ नागरिकों को रेल किराये में जो छूट मिलती थी, वह मार्च 2020 '
                  'में बंद कर दी गई और अब तक वापस नहीं हुई है। टिकट पूरे दाम का ही '
                  'लगेगा। जो अभी भी मिलता है वह यह है: बुज़ुर्गों के लिए नीचे की '
                  'बर्थ का कोटा और प्राथमिकता (स्लीपर और 3एसी में), स्टेशन पर '
                  'व्हीलचेयर और बैटरी गाड़ी, और कई स्टेशनों पर अलग टिकट खिड़की। '
                  'बर्थ का कोटा टिकट बुक करते समय माँगना पड़ता है।'
              : 'The fare concession senior citizens used to get on the '
                  'railways was withdrawn in March 2020 and has not come '
                  'back. The ticket will cost the full fare. What does still '
                  'exist: a lower-berth quota and preference for older '
                  'passengers in sleeper and 3AC, a wheelchair and battery '
                  'car at the station, and a separate ticket counter at many '
                  'stations. The berth quota has to be asked for while '
                  'booking.',
          tone: ToolTone.warn,
          icon: Icons.train_outlined,
        ),
        const SizedBox(height: 14),
        Text(hi ? 'जो सच में मिलता है' : 'What is actually available',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'एल्डरलाइन $elderlineNumber — मुफ़्त राष्ट्रीय हेल्पलाइन: सलाह, '
                      'पेंशन और योजनाओं में मदद, और छोड़ दिए जाने या दुर्व्यवहार के '
                      'मामलों में हस्तक्षेप',
                  'आयुष्मान भारत में 70 साल और उससे ऊपर के सभी बुज़ुर्ग शामिल हैं, '
                      'आय चाहे जो हो — इसकी अलग स्क्रीन लक्ष्य 3 में है',
                  'राष्ट्रीय वयोश्री योजना: ग़रीब बुज़ुर्गों को चश्मा, छड़ी, '
                      'श्रवण यंत्र, कृत्रिम दाँत और घुटने का सहारा — शिविरों में '
                      'मुफ़्त',
                  'बैंकों में बुज़ुर्गों की सावधि जमा पर आम दर से ज़्यादा ब्याज '
                      '(यह बैंक का नियम है, क़ानून नहीं — इसलिए बैंक से पूछें)',
                  'आयकर में 60 और 80 साल पर अलग, ऊँची छूट सीमाएँ, और ब्याज की आय पर '
                      'अलग कटौती; बहुत बुज़ुर्गों के लिए रिटर्न भरने में भी रियायत है',
                  'बस किराये में छूट कुछ राज्यों में है और कुछ में नहीं — यह राज्य '
                      'का विषय है, अपने राज्य के परिवहन निगम से पूछें',
                  'मतदान के लिए घर से वोट की सुविधा, एक तय उम्र से ऊपर — इसी लक्ष्य '
                      'में अलग स्क्रीन है',
                ]
              : const [
                  'Elderline $elderlineNumber - the free national helpline: '
                      'advice, help with pensions and schemes, and '
                      'intervention in cases of abandonment or abuse',
                  'Ayushman Bharat now covers everyone aged 70 and above '
                      'whatever their income - there is a screen of its own '
                      'for it in goal 3',
                  'Rashtriya Vayoshri Yojana: spectacles, walking sticks, '
                      'hearing aids, dentures and knee supports for poor '
                      'older people, free at camps',
                  'Banks pay a higher rate than the ordinary one on senior '
                      'citizens\' fixed deposits (that is a bank\'s rule, '
                      'not a law - so ask the bank)',
                  'Income tax has separate, higher exemption limits at 60 '
                      'and at 80, and a separate deduction on interest '
                      'income; the very old also get relief in filing a '
                      'return',
                  'Bus fare concessions exist in some states and not in '
                      'others - that is a state matter, so ask your state '
                      'transport corporation',
                  'Voting from home above a certain age - there is a '
                      'separate screen for it in this goal',
                ],
        ),
        const SizedBox(height: 10),
        ToolNote(hi
            ? 'आयकर की सीमाएँ और कटौती की रक़में हर बजट में बदल सकती हैं, इसलिए यह '
                'ऐप उनकी संख्या नहीं देता। आयकर विभाग की वेबसाइट या किसी कर सलाहकार '
                'से उस साल की सही संख्या लें।'
            : 'The income tax limits and deduction amounts can change with '
                'every budget, so this app does not carry the numbers. Take '
                'that year\'s figures from the income tax department\'s site '
                'or a tax adviser.'),
        const SizedBox(height: 14),
        ToolDonts(
          heading: hi ? 'जो नहीं मिलता, या जिसमें ठगी होती है' : 'What is not available, and where the fraud is',
          items: hi
              ? const [
                  'रेल किराये में वरिष्ठ नागरिक छूट — बंद है; कोई एजेंट "दिलाने" '
                      'का दावा करे तो वह ठग है',
                  'पेंशन दिलाने के नाम पर पैसा माँगने वाला कोई भी व्यक्ति — '
                      'पेंशन का आवेदन मुफ़्त है',
                  'फ़ोन पर बैंक या पेंशन कार्यालय बनकर ओटीपी, पिन या आधार माँगने '
                      'वाला — कोई भी सच्चा कार्यालय फ़ोन पर यह नहीं माँगता',
                  'घर आकर "जीवन प्रमाण" या "सत्यापन" के बदले पैसा माँगने वाला; '
                      'जीवन प्रमाण बैंक, डाकघर और जन सेवा केंद्र में मुफ़्त होता है',
                  'ऊँचे ब्याज या "दोगुना करने" की स्कीम बेचने वाला — बुज़ुर्गों की '
                      'जमा पूँजी इसी तरह जाती है',
                ]
              : const [
                  'The senior citizen railway fare concession - it is not '
                      'running; anyone claiming they can "arrange" it is a '
                      'fraud',
                  'Anyone asking for money to get a pension sanctioned - the '
                      'application is free',
                  'Anyone on the phone posing as the bank or the pension '
                      'office and asking for an OTP, a PIN or Aadhaar - no '
                      'real office asks for those on a call',
                  'Anyone coming to the house asking for money for a "life '
                      'certificate" or "verification"; the life certificate '
                      'is free at a bank, a post office or a common service '
                      'centre',
                  'Anyone selling a high-interest or "double your money" '
                      'scheme - this is how older people\'s savings go',
                ],
        ),
        const SourceNote(
            text: 'Ministry of Social Justice and Empowerment',
            url: _elderlineUrl),
        const SourceNote(
            text: 'ALIMCO - aids and appliances', url: _vayoshriUrl),
      ],
    );
  }
}
