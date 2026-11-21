// GENERATED-ISSUE-FILE
// The problems SDG 3 sets out to solve.
//
// Edited by hand when a tool is built: set `open` to the screen it opens.
// Everything the goal's mini-app shows - its menu, its home screen, its
// place in the app-wide search - is read from this one list.
import 'package:flutter/material.dart';

import '../../core/issues/issue.dart';
import '../../core/widgets/guide_list_page.dart';
import 'child_vaccines_page.dart';
import 'cover_tools.dart';
import 'daily_log_page.dart';
import 'emergency_tools.dart';
import 'know_tools.dart';
import 'medicine_reminders_page.dart';
import 'myths_page.dart';
import 'numbers_tools.dart';
import 'vaccination_page.dart';

const _groups = [
  IssueGroup('emergency', 'When it is urgent', 'जब तुरंत ज़रूरत हो'),
  IssueGroup('care', 'Free and cheaper care', 'मुफ़्त और सस्ता इलाज'),
  IssueGroup('track', 'Keep track', 'रिकॉर्ड रखें'),
  IssueGroup('know', 'Know the facts', 'सही जानकारी'),
];

final List<Issue> sdg3Issues = [
  Issue(
    id: 'g3i01',
    goal: 3,
    group: 'know',
    titleEn: 'Health myth or fact',
    titleHi: 'स्वास्थ्य: मिथक या सच',
    blurbEn: 'Sixteen things people repeat, and what is actually true.',
    blurbHi: 'लोग जो सोलह बातें दोहराते हैं, और सच क्या है।',
    icon: Icons.fact_check_outlined,
    keywords: const ['myth', 'मिथक', 'rumour', 'अफ़वाह'],
    open: (_) => const MythsPage(),
  ),
  Issue(
    id: 'g3i02',
    goal: 3,
    group: 'track',
    titleEn: 'My child\'s vaccines',
    titleHi: 'मेरे बच्चे के टीके',
    blurbEn: 'Add a child and see every dose with its due date.',
    blurbHi: 'बच्चा जोड़ें और हर टीके की तारीख़ देखें।',
    icon: Icons.vaccines_outlined,
    keywords: const ['vaccine', 'टीका', 'immunisation', 'tika'],
    open: (_) => const ChildVaccinesPage(),
  ),
  Issue(
    id: 'g3i03',
    goal: 3,
    group: 'track',
    titleEn: 'Medicine reminders',
    titleHi: 'दवा के रिमाइंडर',
    blurbEn: 'A daily alert at the time your doctor said.',
    blurbHi: 'डॉक्टर के बताए समय पर रोज़ सूचना।',
    icon: Icons.alarm_outlined,
    keywords: const ['reminder', 'रिमाइंडर', 'dawai', 'दवा'],
    open: (_) => const MedicineRemindersPage(),
  ),
  Issue(
    id: 'g3i04',
    goal: 3,
    group: 'track',
    titleEn: 'Daily log: water, steps, active minutes',
    titleHi: 'रोज़ का रिकॉर्ड: पानी, क़दम, सक्रिय मिनट',
    blurbEn: 'A record you can look back on. No targets, nothing shared.',
    blurbHi: 'एक रिकॉर्ड जिसे पीछे देख सकें। कोई लक्ष्य नहीं, कुछ साझा नहीं।',
    icon: Icons.water_drop_outlined,
    keywords: const ['steps', 'क़दम', 'water', 'पानी'],
    open: (_) => const DailyLogPage(),
  ),
  Issue(
    id: 'g3i05',
    goal: 3,
    group: 'track',
    titleEn: 'Full vaccination schedule',
    titleHi: 'पूरा टीकाकरण कार्यक्रम',
    blurbEn: 'Every dose in the national programme, with what it protects '
        'against.',
    blurbHi: 'राष्ट्रीय कार्यक्रम का हर टीका, और वह किससे बचाता है।',
    icon: Icons.vaccines_outlined,
    keywords: const ['schedule', 'कार्यक्रम', 'uip', 'doses'],
    open: (_) => const VaccinationPage(),
  ),
  Issue(
    id: 'g3i06',
    goal: 3,
    group: 'emergency',
    titleEn: 'Health helplines',
    titleHi: 'स्वास्थ्य हेल्पलाइन',
    blurbEn: 'Free numbers for an ambulance, advice and mental health.',
    blurbHi: 'एम्बुलेंस, सलाह और मानसिक स्वास्थ्य के मुफ़्त नंबर।',
    icon: Icons.phone_outlined,
    keywords: const ['helpline', 'हेल्पलाइन', '108', '104'],
    open: (_) =>
        const GuideListPage(collection: 'healthlines', title:
        'Health helplines', titleHi: 'स्वास्थ्य हेल्पलाइन', goal: 3),
  ),
  Issue(
    id: 'g3i07',
    goal: 3,
    group: 'care',
    titleEn: 'Free treatment cover: Ayushman Bharat',
    titleHi: 'मुफ़्त इलाज: आयुष्मान भारत',
    blurbEn: 'Am I eligible for the Rs 5 lakh cover, and how to get the card.',
    blurbHi: 'क्या 5 लाख के कवर के पात्र हैं, और कार्ड कैसे बने।',
    icon: Icons.local_hospital_outlined,
    keywords: const ['pmjay', 'आयुष्मान', 'insurance'],
    open: (_) => const AyushmanPage(),
  ),
  Issue(
    id: 'g3i08',
    goal: 3,
    group: 'care',
    titleEn: 'Hospital asked for money under a free scheme',
    titleHi: 'मुफ़्त योजना में अस्पताल ने पैसे माँगे',
    blurbEn: 'What is free by right, and the complaint that gets it back.',
    blurbHi: 'क्या मुफ़्त होना चाहिए, और पैसा वापस दिलाने वाली शिकायत।',
    icon: Icons.report_outlined,
    keywords: const ['pmjay', 'denial', 'शिकायत'],
    open: (_) => const ChargedUnderFreeSchemePage(),
  ),
  Issue(
    id: 'g3i09',
    goal: 3,
    group: 'care',
    titleEn: 'Free and cheaper care near me',
    titleHi: 'पास में मुफ़्त और सस्ता इलाज',
    blurbEn: 'eSanjeevani, Ayushman Arogya Mandir, Jan Aushadhi.',
    blurbHi: 'ई-संजीवनी, आयुष्मान आरोग्य मंदिर, जन औषधि।',
    icon: Icons.local_hospital_outlined,
    keywords: const ['esanjeevani', 'jan aushadhi', 'जन औषधि'],
    open: (_) =>
        const GuideListPage(collection: 'freecare', category: 'doctor', title:
        'Free care near you', titleHi: 'पास में मुफ़्त इलाज', goal: 3),
  ),
  Issue(
    id: 'g3i10',
    goal: 3,
    group: 'care',
    titleEn: 'Cheaper medicine by salt name',
    titleHi: 'नमक के नाम से सस्ती दवा',
    blurbEn: 'The same medicine for far less, and how to ask for it.',
    blurbHi: 'वही दवा बहुत कम दाम में, और कैसे माँगें।',
    icon: Icons.medication_outlined,
    keywords: const ['generic', 'जेनेरिक', 'jan aushadhi'],
    open: (_) =>
        const GuideListPage(collection: 'freecare', category: 'medicine',
        title: 'Cheaper medicines', titleHi: 'सस्ती दवाएँ', goal: 3),
  ),
  Issue(
    id: 'g3i11',
    goal: 3,
    group: 'care',
    titleEn: 'Leftover or expired medicines',
    titleHi: 'बची या एक्सपायर दवाएँ',
    blurbEn: 'Safe disposal, and why not to pass them on.',
    blurbHi: 'सुरक्षित तरीके से हटाना, और दूसरों को क्यों न दें।',
    icon: Icons.delete_sweep_outlined,
    keywords: const ['disposal', 'expired', 'एक्सपायर'],
    open: (_) =>
        const GuideListPage(collection: 'freecare', category: 'leftover',
        title: 'Leftover medicines', titleHi: 'बची हुई दवाएँ', goal: 3),
  ),
  Issue(
    id: 'g3i12',
    goal: 3,
    group: 'emergency',
    titleEn: 'Diarrhoea in a child',
    titleHi: 'बच्चे को दस्त',
    blurbEn: 'ORS amounts by weight, and the danger signs that mean go now.',
    blurbHi: 'वज़न के हिसाब से ओआरएस, और कौन से लक्षण मतलब अभी जाएँ।',
    icon: Icons.child_care_outlined,
    keywords: const ['ors', 'ओआरएस', 'dast', 'दस्त'],
    open: (_) => const DiarrhoeaPage(),
  ),
  Issue(
    id: 'g3i13',
    goal: 3,
    group: 'emergency',
    titleEn: 'Fever: when it is an emergency',
    titleHi: 'बुख़ार: कब आपातकाल है',
    blurbEn: 'By age, which fever can wait and which cannot.',
    blurbHi: 'उम्र के हिसाब से, कौन सा बुख़ार रुक सकता है और कौन सा नहीं।',
    icon: Icons.thermostat_outlined,
    keywords: const ['fever', 'बुख़ार', 'bukhar'],
    open: (_) => const FeverPage(),
  ),
  Issue(
    id: 'g3i14',
    goal: 3,
    group: 'emergency',
    titleEn: 'Dog or animal bite',
    titleHi: 'कुत्ता या जानवर काट ले',
    blurbEn: 'Wash first, then the vaccine days you must not miss.',
    blurbHi: 'पहले धोएँ, फिर टीके के दिन जो छूटने नहीं चाहिए।',
    icon: Icons.pets_outlined,
    keywords: const ['rabies', 'रेबीज़', 'bite', 'काटना'],
    open: (_) => const AnimalBitePage(),
  ),
  Issue(
    id: 'g3i15',
    goal: 3,
    group: 'emergency',
    titleEn: 'Snakebite',
    titleHi: 'साँप का काटना',
    blurbEn: 'What to do, what never to do, and the nearest step.',
    blurbHi: 'क्या करें, क्या कभी न करें, और अगला क़दम।',
    icon: Icons.warning_amber_outlined,
    keywords: const ['snake', 'साँप', 'venom'],
    open: (_) => const SnakebitePage(),
  ),
  Issue(
    id: 'g3i16',
    goal: 3,
    group: 'emergency',
    titleEn: 'Pregnancy: check-ups and danger signs',
    titleHi: 'गर्भावस्था: जाँचें और ख़तरे के लक्षण',
    blurbEn: 'Dates from the due date, and the signs that mean go today.',
    blurbHi: 'प्रसव की तारीख़ से जाँच के दिन, और कौन से लक्षण मतलब आज ही '
        'जाएँ।',
    icon: Icons.pregnant_woman_outlined,
    keywords: const ['anc', 'गर्भ', 'pregnancy'],
    open: (_) => const PregnancyCarePage(),
  ),
  Issue(
    id: 'g3i17',
    goal: 3,
    group: 'know',
    titleEn: 'TB: free tests, free medicines, support money',
    titleHi: 'टीबी: मुफ़्त जाँच, मुफ़्त दवा, सहायता राशि',
    blurbEn: 'Who should get tested, and what the government pays you '
        'monthly.',
    blurbHi: 'जाँच किसे करानी चाहिए, और सरकार हर महीने कितना देती है।',
    icon: Icons.science_outlined,
    keywords: const ['tb', 'टीबी', 'tuberculosis', 'nikshay'],
    open: (_) => const TbPage(),
  ),
  Issue(
    id: 'g3i18',
    goal: 3,
    group: 'know',
    titleEn: 'Blood pressure: what my numbers mean',
    titleHi: 'ब्लड प्रेशर: मेरे नंबर का मतलब',
    blurbEn: 'Enter a reading and see the published range it falls in.',
    blurbHi: 'रीडिंग डालें और देखें वह किस प्रकाशित श्रेणी में आती है।',
    icon: Icons.favorite_outline,
    keywords: const ['bp', 'बीपी', 'hypertension'],
    open: (_) => const BloodPressurePage(),
  ),
  Issue(
    id: 'g3i19',
    goal: 3,
    group: 'know',
    titleEn: 'Blood sugar: what my numbers mean',
    titleHi: 'ब्लड शुगर: मेरे नंबर का मतलब',
    blurbEn: 'Fasting and after-food readings against the published ranges.',
    blurbHi: 'खाली पेट और खाने के बाद की रीडिंग, प्रकाशित श्रेणी के सामने।',
    icon: Icons.science_outlined,
    keywords: const ['sugar', 'शुगर', 'diabetes', 'मधुमेह'],
    open: (_) => const BloodSugarPage(),
  ),
];

final GoalIssues sdg3Goal = GoalIssues(
  goal: 3,
  groups: _groups,
  issues: sdg3Issues,
  helplines: const [
    GoalHelpline('108', 'Ambulance', 'एम्बुलेंस'),
    GoalHelpline('104', 'Health helpline', 'स्वास्थ्य हेल्पलाइन'),
    GoalHelpline('14416', 'Tele-MANAS, mental health', 'टेली-मानस'),
    GoalHelpline('14555', 'Ayushman Bharat', 'आयुष्मान भारत'),
  ],
);
