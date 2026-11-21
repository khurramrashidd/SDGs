// GENERATED-ISSUE-FILE
// The problems SDG 1 sets out to solve.
//
// Edited by hand when a tool is built: set `open` to the screen it opens.
// Everything the goal's mini-app shows - its menu, its home screen, its
// place in the app-wide search - is read from this one list.
import 'package:flutter/material.dart';

import '../../core/issues/issue.dart';
import 'aadhaar_tool.dart';
import 'cover_tool.dart';
import 'dbt_tool.dart';
import 'eshram_tool.dart';
import 'mgnrega_tool.dart';
import 'money_tools.dart';
import 'papers_tools.dart';
import 'pension_tool.dart';
import 'ration_tool.dart';
import 'schemes_page.dart';
import 'stuck_tools.dart';

const _groups = [
  IssueGroup('schemes', 'Schemes and money', 'योजनाएँ और पैसा'),
  IssueGroup('papers', 'Papers you need', 'ज़रूरी काग़ज़'),
  IssueGroup('stuck', 'When money does not come', 'जब पैसा न आए'),
  IssueGroup('plan', 'Plan your money', 'पैसे की योजना'),
];

final List<Issue> sdg1Issues = [
  Issue(
    id: 'g1i01',
    goal: 1,
    group: 'schemes',
    titleEn: 'Which schemes fit my family',
    titleHi: 'कौन सी योजनाएँ आपके परिवार के लिए हैं',
    blurbEn: 'Answer seven questions and see the central schemes you can '
        'apply for.',
    blurbHi: 'सात सवालों के जवाब दें और देखें कौन सी केंद्रीय योजनाएँ आप ले '
        'सकते हैं।',
    icon: Icons.account_balance_outlined,
    keywords: const ['yojana', 'योजना', 'subsidy', 'सब्सिडी'],
    open: (_) => const SchemesPage(),
  ),
  Issue(
    id: 'g1i02',
    goal: 1,
    group: 'schemes',
    titleEn: 'Ration card: which type should I have',
    titleHi: 'राशन कार्ड: कौन सा कार्ड मिलना चाहिए',
    blurbEn: 'Antyodaya, priority or none - and what each one gets you.',
    blurbHi: 'अंत्योदय, प्राथमिकता या कोई नहीं - और हर एक से क्या मिलता है।',
    icon: Icons.badge_outlined,
    keywords: const ['ration', 'राशन', 'bpl', 'apl', 'nfsa'],
    open: (_) => const RationCardPage(),
  ),
  Issue(
    id: 'g1i03',
    goal: 1,
    group: 'schemes',
    titleEn: 'Pension check: old age, widow, disability',
    titleHi: 'पेंशन जाँच: वृद्धावस्था, विधवा, दिव्यांग',
    blurbEn: 'Age, income and category decide which pension you can claim.',
    blurbHi: 'उम्र, आय और श्रेणी तय करती है कौन सी पेंशन मिल सकती है।',
    icon: Icons.elderly_outlined,
    keywords: const ['pension', 'पेंशन', 'vridha', 'vidhwa'],
    open: (_) => const PensionCheckPage(),
  ),
  Issue(
    id: 'g1i04',
    goal: 1,
    group: 'schemes',
    titleEn: 'MGNREGA: demand work in writing',
    titleHi: 'मनरेगा: लिखकर काम माँगें',
    blurbEn: 'The written demand, the 15-day clock, and the allowance if '
        'work does not come.',
    blurbHi: 'लिखित माँग, 15 दिन की घड़ी, और काम न मिलने पर भत्ता।',
    icon: Icons.work_outline,
    keywords: const ['nrega', 'मनरेगा', 'job card', 'जॉब कार्ड'],
    open: (_) => const MgnregaPage(),
  ),
  Issue(
    id: 'g1i05',
    goal: 1,
    group: 'schemes',
    titleEn: 'e-Shram card: should I register',
    titleHi: 'ई-श्रम कार्ड: क्या पंजीकरण कराएँ',
    blurbEn: 'Who it is for, what it gives, and how to get it free.',
    blurbHi: 'किसके लिए है, क्या मिलता है, और मुफ़्त में कैसे बनवाएँ।',
    icon: Icons.badge_outlined,
    keywords: const ['eshram', 'ई-श्रम', 'unorganised'],
    open: (_) => const EShramPage(),
  ),
  Issue(
    id: 'g1i06',
    goal: 1,
    group: 'schemes',
    titleEn: 'Rs 2 lakh life cover for Rs 436 a year',
    titleHi: '436 रुपये साल में 2 लाख का जीवन बीमा',
    blurbEn: 'PMJJBY and PMSBY: am I enrolled, and how a family claims.',
    blurbHi: 'पीएमजेजेबीवाई और पीएमएसबीवाई: क्या नाम दर्ज है, और परिवार दावा '
        'कैसे करे।',
    icon: Icons.shield_outlined,
    keywords: const ['insurance', 'बीमा', 'pmjjby', 'pmsby'],
    open: (_) => const JanSurakshaPage(),
  ),
  Issue(
    id: 'g1i07',
    goal: 1,
    group: 'stuck',
    titleEn: 'Benefit money not arriving',
    titleHi: 'लाभ का पैसा नहीं आ रहा',
    blurbEn: 'Find the step it is stuck at: Aadhaar seeding, bank link, or '
        'e-KYC.',
    blurbHi: 'पता लगाएँ कहाँ अटका है: आधार सीडिंग, बैंक लिंक, या ई-केवाईसी।',
    icon: Icons.payments_outlined,
    keywords: const ['dbt', 'डीबीटी', 'npci', 'seeding'],
    open: (_) => const DbtStuckPage(),
  ),
  Issue(
    id: 'g1i08',
    goal: 1,
    group: 'stuck',
    titleEn: 'PM-KISAN instalment stopped',
    titleHi: 'पीएम-किसान की किस्त रुक गई',
    blurbEn: 'The five usual reasons, and what to fix for each.',
    blurbHi: 'पाँच आम कारण, और हर एक में क्या ठीक करना है।',
    icon: Icons.agriculture_outlined,
    keywords: const ['kisan', 'किसान', 'installment', 'किस्त'],
    open: (_) => const PmKisanStuckPage(),
  ),
  Issue(
    id: 'g1i09',
    goal: 1,
    group: 'stuck',
    titleEn: 'Scheme application rejected',
    titleHi: 'योजना का आवेदन रद्द हो गया',
    blurbEn: 'Ask for the reason in writing, then an appeal letter you can '
        'copy.',
    blurbHi: 'कारण लिखित में माँगें, फिर अपील की चिट्ठी जो आप कॉपी कर सकते '
        'हैं।',
    icon: Icons.edit_note_outlined,
    keywords: const ['appeal', 'अपील', 'rejected', 'रद्द'],
    open: (_) => const RejectedPage(),
  ),
  Issue(
    id: 'g1i10',
    goal: 1,
    group: 'papers',
    titleEn: 'Aadhaar problem: name, mobile, lost card',
    titleHi: 'आधार की समस्या: नाम, मोबाइल, खोया कार्ड',
    blurbEn: 'Which correction needs which proof, and what it costs.',
    blurbHi: 'कौन से सुधार में कौन सा प्रमाण लगता है, और ख़र्च कितना।',
    icon: Icons.badge_outlined,
    keywords: const ['aadhaar', 'आधार', 'uidai'],
    open: (_) => const AadhaarFixPage(),
  ),
  Issue(
    id: 'g1i11',
    goal: 1,
    group: 'papers',
    titleEn: 'Birth or death certificate, late',
    titleHi: 'जन्म या मृत्यु प्रमाण पत्र, देर से',
    blurbEn: 'The steps change with how late you are. Enter the date.',
    blurbHi: 'कितनी देर हुई, उसी से रास्ता बदलता है। तारीख़ डालें।',
    icon: Icons.description_outlined,
    keywords: const ['birth', 'death', 'जन्म', 'मृत्यु'],
    open: (_) => const LateCertificatePage(),
  ),
  Issue(
    id: 'g1i12',
    goal: 1,
    group: 'papers',
    titleEn: 'Death in the family: papers and benefits',
    titleHi: 'परिवार में मृत्यु: काग़ज़ और लाभ',
    blurbEn: 'A checklist of what to get and what the family can claim.',
    blurbHi: 'क्या-क्या बनवाना है और परिवार क्या-क्या ले सकता है, की सूची।',
    icon: Icons.description_outlined,
    keywords: const ['succession', 'उत्तराधिकार', 'pension'],
    open: (_) => const AfterDeathPage(),
  ),
  Issue(
    id: 'g1i13',
    goal: 1,
    group: 'papers',
    titleEn: 'Family papers check',
    titleHi: 'परिवार के काग़ज़ की जाँच',
    blurbEn: 'What every household should hold, and which are missing from '
        'yours.',
    blurbHi: 'हर घर में कौन से काग़ज़ होने चाहिए, और आपके यहाँ कौन से नहीं '
        'हैं।',
    icon: Icons.fact_check_outlined,
    keywords: const ['documents', 'काग़ज़', 'checklist'],
    open: (_) => const FamilyPapersPage(),
  ),
  Issue(
    id: 'g1i14',
    goal: 1,
    group: 'plan',
    titleEn: 'Moneylender loan: the real interest',
    titleHi: 'साहूकार का क़र्ज़: असली ब्याज',
    blurbEn: 'A daily or weekly rate turned into the yearly rate it really '
        'is.',
    blurbHi: 'रोज़ या हफ़्ते का रेट, साल के असली रेट में बदलकर।',
    icon: Icons.calculate_outlined,
    keywords: const ['interest', 'ब्याज', 'loan', 'क़र्ज़', 'sood'],
    open: (_) => const InterestPage(),
  ),
  Issue(
    id: 'g1i15',
    goal: 1,
    group: 'plan',
    titleEn: 'Household budget',
    titleHi: 'घर का बजट',
    blurbEn: 'Income, fixed costs, and what is actually left each month.',
    blurbHi: 'आमदनी, तय ख़र्च, और हर महीने सच में क्या बचता है।',
    icon: Icons.savings_outlined,
    keywords: const ['budget', 'बजट', 'kharcha', 'ख़र्च'],
    open: (_) => const BudgetPage(),
  ),
];

final GoalIssues sdg1Goal = GoalIssues(
  goal: 1,
  groups: _groups,
  issues: sdg1Issues,
  helplines: const [
    GoalHelpline('1800115526', 'PM-KISAN', 'पीएम-किसान'),
    GoalHelpline('14555', 'Ayushman Bharat', 'आयुष्मान भारत'),
    GoalHelpline('1947', 'Aadhaar help', 'आधार मदद'),
  ],
);
