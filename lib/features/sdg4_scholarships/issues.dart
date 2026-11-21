// GENERATED-ISSUE-FILE
// The problems SDG 4 sets out to solve.
//
// Edited by hand when a tool is built: set `open` to the screen it opens.
// Everything the goal's mini-app shows - its menu, its home screen, its
// place in the app-wide search - is read from this one list.
import 'package:flutter/material.dart';

import '../../core/issues/issue.dart';
import 'learn_page.dart';
import 'literacy_page.dart';
import 'money_tools.dart';
import 'next_tools.dart';
import 'qa_page.dart';
import 'quiz_page.dart';
import 'rights_tools.dart';
import 'scholarships_page.dart';
import 'study_tools.dart';

const _groups = [
  IssueGroup('money', 'Money for study', 'पढ़ाई के लिए पैसा'),
  IssueGroup('learn', 'Learn for free', 'मुफ़्त पढ़ाई'),
  IssueGroup('rights', 'Your rights at school', 'स्कूल में आपके अधिकार'),
  IssueGroup('next', 'What comes next', 'आगे क्या'),
];

final List<Issue> sdg4Issues = [
  Issue(
    id: 'g4i01',
    goal: 4,
    group: 'money',
    titleEn: 'Which scholarships fit me',
    titleHi: 'कौन सी छात्रवृत्ति आपके लिए है',
    blurbEn: 'Twenty-four central scholarships, class 8 to PhD, matched to '
        'you.',
    blurbHi: 'चौबीस केंद्रीय छात्रवृत्तियाँ, कक्षा 8 से पीएचडी तक, आपके '
        'हिसाब से।',
    icon: Icons.school_outlined,
    keywords: const ['scholarship', 'छात्रवृत्ति', 'nsp'],
    open: (_) => const ScholarshipsPage(),
  ),
  Issue(
    id: 'g4i02',
    goal: 4,
    group: 'learn',
    titleEn: 'Free learning for every class',
    titleHi: 'हर कक्षा के लिए मुफ़्त पढ़ाई',
    blurbEn: 'DIKSHA, NCERT books, TV channels, SWAYAM, NIOS.',
    blurbHi: 'दीक्षा, एनसीईआरटी किताबें, टीवी चैनल, स्वयं, एनआईओएस।',
    icon: Icons.menu_book_outlined,
    keywords: const ['diksha', 'दीक्षा', 'ncert', 'free'],
    open: (_) => const LearnPage(),
  ),
  Issue(
    id: 'g4i03',
    goal: 4,
    group: 'learn',
    titleEn: 'Practice quiz',
    titleHi: 'अभ्यास क्विज़',
    blurbEn: 'Six subjects, one question at a time, answers straight away.',
    blurbHi: 'छह विषय, एक-एक सवाल, जवाब तुरंत।',
    icon: Icons.quiz_outlined,
    keywords: const ['quiz', 'क्विज़', 'practice', 'अभ्यास'],
    open: (_) => const QuizPage(),
  ),
  Issue(
    id: 'g4i04',
    goal: 4,
    group: 'learn',
    titleEn: 'Ask a study question',
    titleHi: 'पढ़ाई का सवाल पूछें',
    blurbEn: 'Answered by other students and helpers. Everything is checked '
        'first.',
    blurbHi: 'दूसरे विद्यार्थी और मददगार जवाब देते हैं। सब पहले जाँचा जाता '
        'है।',
    icon: Icons.forum_outlined,
    keywords: const ['doubt', 'सवाल', 'question', 'help'],
    open: (_) => const QaPage(),
  ),
  Issue(
    id: 'g4i05',
    goal: 4,
    group: 'learn',
    titleEn: 'Literacy rates',
    titleHi: 'साक्षरता दर',
    blurbEn: 'India and its neighbours, women and men side by side.',
    blurbHi: 'भारत और पड़ोसी देश, महिलाएँ और पुरुष अलग-अलग।',
    icon: Icons.bar_chart_outlined,
    keywords: const ['literacy', 'साक्षरता', 'data'],
    open: (_) => const LiteracyPage(),
  ),
  Issue(
    id: 'g4i06',
    goal: 4,
    group: 'money',
    titleEn: 'Scholarship money not received',
    titleHi: 'छात्रवृत्ति का पैसा नहीं आया',
    blurbEn: 'Find the step it is stuck at, and who to chase.',
    blurbHi: 'पता लगाएँ कहाँ अटका है, और किससे कहें।',
    icon: Icons.payments_outlined,
    keywords: const ['nsp', 'pending', 'अटका'],
    open: (_) => const ScholarshipStuckPage(),
  ),
  Issue(
    id: 'g4i07',
    goal: 4,
    group: 'money',
    titleEn: 'Education loan: subsidy and EMI',
    titleHi: 'शिक्षा ऋण: सब्सिडी और ईएमआई',
    blurbEn: 'Interest subsidy check, and what the monthly payment works out '
        'to.',
    blurbHi: 'ब्याज सब्सिडी की जाँच, और महीने की किस्त कितनी बनेगी।',
    icon: Icons.calculate_outlined,
    keywords: const ['loan', 'ऋण', 'emi', 'vidya lakshmi'],
    open: (_) => const EducationLoanPage(),
  ),
  Issue(
    id: 'g4i08',
    goal: 4,
    group: 'rights',
    titleEn: 'Private school free seat (RTE 25%)',
    titleHi: 'निजी स्कूल में मुफ़्त सीट (आरटीई 25%)',
    blurbEn: 'Do we qualify, when applications open, and what to keep ready.',
    blurbHi: 'क्या हम पात्र हैं, आवेदन कब खुलते हैं, और क्या तैयार रखें।',
    icon: Icons.school_outlined,
    keywords: const ['rte', 'आरटीई', 'free seat', 'admission'],
    open: (_) => const RtePage(),
  ),
  Issue(
    id: 'g4i09',
    goal: 4,
    group: 'rights',
    titleEn: 'School refused admission or asked for donation',
    titleHi: 'स्कूल ने दाख़िला नहीं दिया या डोनेशन माँगा',
    blurbEn: 'What is illegal, and a complaint you can copy.',
    blurbHi: 'क्या ग़ैरक़ानूनी है, और कॉपी करने लायक शिकायत।',
    icon: Icons.report_outlined,
    keywords: const ['donation', 'डोनेशन', 'admission', 'rte'],
    open: (_) => const AdmissionRefusedPage(),
  ),
  Issue(
    id: 'g4i10',
    goal: 4,
    group: 'rights',
    titleEn: 'Free uniform, books, cycle and hostel',
    titleHi: 'मुफ़्त ड्रेस, किताबें, साइकिल और छात्रावास',
    blurbEn: 'What the school must give free, by class and category.',
    blurbHi: 'कक्षा और श्रेणी के हिसाब से स्कूल क्या मुफ़्त दे।',
    icon: Icons.inventory_2_outlined,
    keywords: const ['uniform', 'किताब', 'cycle', 'hostel'],
    open: (_) => const FreeEntitlementsPage(),
  ),
  Issue(
    id: 'g4i11',
    goal: 4,
    group: 'rights',
    titleEn: 'Lost marksheet or certificate',
    titleHi: 'मार्कशीट या प्रमाण पत्र खो गया',
    blurbEn: 'Duplicate steps for board and university, and DigiLocker.',
    blurbHi: 'बोर्ड और विश्वविद्यालय से डुप्लिकेट के क़दम, और डिजिलॉकर।',
    icon: Icons.description_outlined,
    keywords: const ['duplicate', 'marksheet', 'digilocker'],
    open: (_) => const LostMarksheetPage(),
  ),
  Issue(
    id: 'g4i12',
    goal: 4,
    group: 'next',
    titleEn: 'Dropped out: paths back',
    titleHi: 'पढ़ाई छूट गई: वापसी के रास्ते',
    blurbEn: 'Open school, bridge courses, and what each one leads to.',
    blurbHi: 'मुक्त विद्यालय, ब्रिज कोर्स, और हर एक से आगे क्या।',
    icon: Icons.menu_book_outlined,
    keywords: const ['dropout', 'nios', 'open school'],
    open: (_) => const DroppedOutPage(),
  ),
  Issue(
    id: 'g4i13',
    goal: 4,
    group: 'next',
    titleEn: 'After class 10: which stream',
    titleHi: 'दसवीं के बाद: कौन सी धारा',
    blurbEn: 'Science, commerce, arts or a skill course, matched to you.',
    blurbHi: 'विज्ञान, वाणिज्य, कला या कौशल कोर्स, आपके हिसाब से।',
    icon: Icons.lightbulb_outlined,
    keywords: const ['stream', 'धारा', 'class 10', 'दसवीं'],
    open: (_) => const AfterTenPage(),
  ),
  Issue(
    id: 'g4i14',
    goal: 4,
    group: 'next',
    titleEn: 'After class 12: exams and dates',
    titleHi: 'बारहवीं के बाद: परीक्षाएँ और तारीख़ें',
    blurbEn: 'Entrance exams by field, with the months they open.',
    blurbHi: 'क्षेत्र के हिसाब से प्रवेश परीक्षाएँ, और वे किस महीने खुलती '
        'हैं।',
    icon: Icons.event_outlined,
    keywords: const ['jee', 'neet', 'cuet', 'entrance'],
    open: (_) => const AfterTwelvePage(),
  ),
  Issue(
    id: 'g4i15',
    goal: 4,
    group: 'next',
    titleEn: 'Exam timetable maker',
    titleHi: 'परीक्षा की समय-सारणी बनाएँ',
    blurbEn: 'Your syllabus and the days left, turned into a daily plan.',
    blurbHi: 'आपका पाठ्यक्रम और बचे दिन, रोज़ की योजना में।',
    icon: Icons.event_outlined,
    keywords: const ['timetable', 'समय सारणी', 'study plan'],
    open: (_) => const ExamPlanPage(),
  ),
  Issue(
    id: 'g4i16',
    goal: 4,
    group: 'next',
    titleEn: 'Marks, percentage and CGPA',
    titleHi: 'अंक, प्रतिशत और सीजीपीए',
    blurbEn: 'Convert between them without guessing the formula.',
    blurbHi: 'बिना फ़ॉर्मूला याद किए एक से दूसरे में बदलें।',
    icon: Icons.calculate_outlined,
    keywords: const ['cgpa', 'percentage', 'प्रतिशत'],
    open: (_) => const MarksPage(),
  ),
];

final GoalIssues sdg4Goal = GoalIssues(
  goal: 4,
  groups: _groups,
  issues: sdg4Issues,
  helplines: const [
    GoalHelpline('18001805522', 'National scholarship help', 'छात्रवृत्ति मदद'),
    GoalHelpline('1098', 'Childline', 'चाइल्डलाइन'),
  ],
);
