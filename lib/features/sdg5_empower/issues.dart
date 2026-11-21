// GENERATED-ISSUE-FILE
// The problems SDG 5 sets out to solve.
//
// Edited by hand when a tool is built: set `open` to the screen it opens.
// Everything the goal's mini-app shows - its menu, its home screen, its
// place in the app-wide search - is read from this one list.
import 'package:flutter/material.dart';

import '../../core/issues/issue.dart';
import '../../core/widgets/guide_list_page.dart';
import '../sdg9_enterprise/scheme_match_page.dart';
import 'leaders_page.dart';
import 'mentor_page.dart';
import 'report_page.dart';
import 'rights_page.dart';
import 'safety_law_tools.dart';
import 'safety_page.dart';
import 'work_rights_tools.dart';

const _groups = [
  IssueGroup('safety', 'Help and safety', 'मदद और सुरक्षा'),
  IssueGroup('law', 'What the law gives you', 'क़ानून आपको क्या देता है'),
  IssueGroup('health', 'Health and wellbeing', 'सेहत'),
  IssueGroup('work', 'Work and money', 'काम और पैसा'),
];

final List<Issue> sdg5Issues = [
  Issue(
    id: 'g5i01',
    goal: 5,
    group: 'safety',
    titleEn: 'Helpline numbers',
    titleHi: 'हेल्पलाइन नंबर',
    blurbEn: 'Free numbers that answer 24 hours, with one tap to call.',
    blurbHi: '24 घंटे चलने वाले मुफ़्त नंबर, एक टैप में कॉल।',
    icon: Icons.phone_outlined,
    keywords: const ['helpline', 'हेल्पलाइन', '181', 'emergency'],
    open: (_) => const SafetyPage(),
  ),
  Issue(
    id: 'g5i02',
    goal: 5,
    group: 'safety',
    titleEn: 'Report abuse safely',
    titleHi: 'दुर्व्यवहार की सुरक्षित रिपोर्ट',
    blurbEn: 'Where to report, what to keep, and how to stay safe doing it.',
    blurbHi: 'कहाँ रिपोर्ट करें, क्या संभालें, और ऐसा करते हुए सुरक्षित कैसे '
        'रहें।',
    icon: Icons.shield_outlined,
    keywords: const ['abuse', 'violence', 'हिंसा', 'report'],
    open: (_) => const ReportPage(),
  ),
  Issue(
    id: 'g5i03',
    goal: 5,
    group: 'law',
    titleEn: 'Know your legal rights',
    titleHi: 'अपने क़ानूनी अधिकार जानें',
    blurbEn: 'Nine rights in plain words: money, safety and work.',
    blurbHi: 'नौ अधिकार आसान शब्दों में: पैसा, सुरक्षा और काम।',
    icon: Icons.gavel_outlined,
    keywords: const ['rights', 'अधिकार', 'law', 'क़ानून'],
    open: (_) => const RightsPage(),
  ),
  Issue(
    id: 'g5i04',
    goal: 5,
    group: 'work',
    titleEn: 'Career guidance',
    titleHi: 'करियर मार्गदर्शन',
    blurbEn: 'Ask about starting work, changing jobs or studying further.',
    blurbHi: 'काम शुरू करने, नौकरी बदलने या आगे पढ़ाई के बारे में पूछें।',
    icon: Icons.work_outline,
    keywords: const ['career', 'करियर', 'job', 'नौकरी'],
    open: (_) => const MentorPage(task: MentorTask.mentor),
  ),
  Issue(
    id: 'g5i05',
    goal: 5,
    group: 'work',
    titleEn: 'Business ideas',
    titleHi: 'व्यवसाय के विचार',
    blurbEn: 'Say what you can do, and see small businesses you could start.',
    blurbHi: 'बताएँ क्या आता है, और देखें कौन से छोटे काम शुरू कर सकती हैं।',
    icon: Icons.lightbulb_outlined,
    keywords: const ['business', 'व्यवसाय', 'idea'],
    open: (_) => const MentorPage(task: MentorTask.businessIdea),
  ),
  Issue(
    id: 'g5i06',
    goal: 5,
    group: 'work',
    titleEn: 'Money to start a business',
    titleHi: 'व्यवसाय के लिए पैसा',
    blurbEn: 'Mudra, Stand-Up India, PMEGP - which loan fits you.',
    blurbHi: 'मुद्रा, स्टैंड-अप इंडिया, पीएमईजीपी - कौन सा ऋण आपके लिए।',
    icon: Icons.payments_outlined,
    keywords: const ['mudra', 'मुद्रा', 'loan', 'stand up'],
    open: (_) => const SchemeMatchPage(),
  ),
  Issue(
    id: 'g5i07',
    goal: 5,
    group: 'law',
    titleEn: 'Women of India',
    titleHi: 'भारत की महिलाएँ',
    blurbEn: 'Twenty-one women whose work changed what was thought possible.',
    blurbHi: 'इक्कीस महिलाएँ जिनके काम ने बदला कि क्या संभव है।',
    icon: Icons.groups_outlined,
    keywords: const ['leaders', 'नेता', 'inspiration'],
    open: (_) => const LeadersPage(),
  ),
  Issue(
    id: 'g5i08',
    goal: 5,
    group: 'health',
    titleEn: 'Pregnancy and birth',
    titleHi: 'माँ बनने पर',
    blurbEn: 'Matru Vandana cash, and a free delivery in a government '
        'hospital.',
    blurbHi: 'मातृ वंदना के पैसे, और सरकारी अस्पताल में मुफ़्त प्रसव।',
    icon: Icons.pregnant_woman_outlined,
    keywords: const ['pmmvy', 'मातृ', 'delivery', 'jssk'],
    open: (_) =>
        const GuideListPage(collection: 'wellness', category: 'mother', title:
        'Pregnancy and birth', titleHi: 'माँ बनने पर', goal: 5),
  ),
  Issue(
    id: 'g5i09',
    goal: 5,
    group: 'health',
    titleEn: 'Anaemia and cancer checks',
    titleHi: 'ख़ून की कमी और कैंसर जाँच',
    blurbEn: 'More than half of women are anaemic. Tests and tablets are '
        'free.',
    blurbHi: 'आधी से ज़्यादा महिलाओं में ख़ून की कमी है। जाँच और गोलियाँ '
        'मुफ़्त हैं।',
    icon: Icons.favorite_outline,
    keywords: const ['anaemia', 'एनीमिया', 'cancer', 'screening'],
    open: (_) =>
        const GuideListPage(collection: 'wellness', category: 'body', title:
        'Anaemia and cancer checks', titleHi: 'ख़ून की कमी और कैंसर जाँच',
        goal: 5),
  ),
  Issue(
    id: 'g5i10',
    goal: 5,
    group: 'health',
    titleEn: 'Someone to talk to: 14416',
    titleHi: 'बात करने के लिए कोई: 14416',
    blurbEn: 'Tele-MANAS: free, 24 hours, in many languages.',
    blurbHi: 'टेली-मानस: मुफ़्त, 24 घंटे, कई भाषाओं में।',
    icon: Icons.phone_outlined,
    keywords: const ['mental', 'मानसिक', 'telemanas', 'counselling'],
    open: (_) =>
        const GuideListPage(collection: 'wellness', category: 'mind', title:
        'Someone to talk to', titleHi: 'बात करने के लिए कोई', goal: 5),
  ),
  Issue(
    id: 'g5i11',
    goal: 5,
    group: 'law',
    titleEn: 'Workplace harassment complaint',
    titleHi: 'कार्यस्थल पर उत्पीड़न की शिकायत',
    blurbEn: 'The committee that must hear it, the time limit, and the '
        'letter.',
    blurbHi: 'कौन सी समिति सुनेगी, समय सीमा, और शिकायत पत्र।',
    icon: Icons.edit_note_outlined,
    keywords: const ['posh', 'harassment', 'उत्पीड़न', 'icc'],
    open: (_) => const PoshPage(),
  ),
  Issue(
    id: 'g5i12',
    goal: 5,
    group: 'law',
    titleEn: 'Maternity leave: weeks and pay',
    titleHi: 'मातृत्व अवकाश: हफ़्ते और वेतन',
    blurbEn: 'What you are owed, and what to do if it is refused.',
    blurbHi: 'कितना हक़ है, और मना करने पर क्या करें।',
    icon: Icons.pregnant_woman_outlined,
    keywords: const ['maternity', 'मातृत्व', 'leave'],
    open: (_) => const MaternityPage(),
  ),
  Issue(
    id: 'g5i13',
    goal: 5,
    group: 'law',
    titleEn: 'Domestic violence: protection order',
    titleHi: 'घरेलू हिंसा: संरक्षण आदेश',
    blurbEn: 'What an order can stop, who files it, and a safety plan.',
    blurbHi: 'आदेश क्या रोक सकता है, कौन दाख़िल करता है, और सुरक्षा योजना।',
    icon: Icons.shield_outlined,
    keywords: const ['dv', 'घरेलू', 'protection', 'order'],
    open: (_) => const ProtectionOrderPage(),
  ),
  Issue(
    id: 'g5i14',
    goal: 5,
    group: 'law',
    titleEn: 'Dowry demand',
    titleHi: 'दहेज की माँग',
    blurbEn: 'What the law says, and where to report it.',
    blurbHi: 'क़ानून क्या कहता है, और कहाँ शिकायत करें।',
    icon: Icons.gavel_outlined,
    keywords: const ['dowry', 'दहेज'],
    open: (_) => const DowryPage(),
  ),
  Issue(
    id: 'g5i15',
    goal: 5,
    group: 'law',
    titleEn: 'Daughter\'s share in property',
    titleHi: 'बेटी का संपत्ति में हिस्सा',
    blurbEn: 'What a daughter inherits, and what to do when it is denied.',
    blurbHi: 'बेटी को क्या मिलता है, और मना करने पर क्या करें।',
    icon: Icons.balance_outlined,
    keywords: const ['inheritance', 'विरासत', 'property'],
    open: (_) => const DaughterPropertyPage(),
  ),
  Issue(
    id: 'g5i16',
    goal: 5,
    group: 'safety',
    titleEn: 'Marriage under 18',
    titleHi: 'अठारह से कम उम्र में शादी',
    blurbEn: 'How to stop one, and who to call, including anonymously.',
    blurbHi: 'कैसे रोकें, और किसे बताएँ, बिना नाम बताए भी।',
    icon: Icons.report_outlined,
    keywords: const ['child marriage', 'बाल विवाह', '1098'],
    open: (_) => const ChildMarriagePage(),
  ),
  Issue(
    id: 'g5i17',
    goal: 5,
    group: 'work',
    titleEn: 'Equal pay check',
    titleHi: 'समान वेतन की जाँच',
    blurbEn: 'Same work, different wage - what the law allows and does not.',
    blurbHi: 'वही काम, अलग मज़दूरी - क़ानून क्या मानता है और क्या नहीं।',
    icon: Icons.balance_outlined,
    keywords: const ['equal pay', 'समान वेतन', 'wage'],
    open: (_) => const EqualPayPage(),
  ),
  Issue(
    id: 'g5i18',
    goal: 5,
    group: 'work',
    titleEn: 'Join a self-help group',
    titleHi: 'स्वयं सहायता समूह से जुड़ें',
    blurbEn: 'How a group forms, what it can borrow, and the bank link.',
    blurbHi: 'समूह कैसे बनता है, कितना क़र्ज़ ले सकता है, और बैंक से जुड़ाव।',
    icon: Icons.groups_outlined,
    keywords: const ['shg', 'स्वयं सहायता', 'nrlm'],
    open: (_) => const ShgPage(),
  ),
];

final GoalIssues sdg5Goal = GoalIssues(
  goal: 5,
  groups: _groups,
  issues: sdg5Issues,
  helplines: const [
    GoalHelpline('181', 'Women helpline', 'महिला हेल्पलाइन'),
    GoalHelpline('1098', 'Childline', 'चाइल्डलाइन'),
    GoalHelpline('112', 'Emergency', 'आपातकाल'),
    GoalHelpline('14416', 'Tele-MANAS', 'टेली-मानस'),
  ],
);
