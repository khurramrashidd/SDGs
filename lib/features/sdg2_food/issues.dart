// GENERATED-ISSUE-FILE
// The problems SDG 2 sets out to solve.
//
// Edited by hand when a tool is built: set `open` to the screen it opens.
// Everything the goal's mini-app shows - its menu, its home screen, its
// place in the app-wide search - is read from this one list.
import 'package:flutter/material.dart';

import '../../core/issues/issue.dart';
import '../../core/widgets/guide_list_page.dart';
import '../sdg1_schemes/ration_tool.dart';
import 'child_entitlements.dart';
import 'child_nutrition.dart';
import 'cook_tool.dart';
import 'food_board_page.dart';
import 'grow_tools.dart';
import 'ration_access.dart';
import 'ration_complaint.dart';
import 'share_check_page.dart';

const _groups = [
  IssueGroup('share', 'Share food safely', 'सुरक्षित तरीके से खाना बाँटें'),
  IssueGroup('ration', 'Ration and entitlements', 'राशन और हक़'),
  IssueGroup('child', 'Children and mothers', 'बच्चे और माताएँ'),
  IssueGroup('grow', 'Grow and sell', 'उगाएँ और बेचें'),
];

final List<Issue> sdg2Issues = [
  Issue(
    id: 'g2i01',
    goal: 2,
    group: 'share',
    titleEn: 'Can this leftover food be shared',
    titleHi: 'क्या यह बचा खाना बाँटा जा सकता है',
    blurbEn: 'Six questions about the food, then a clear yes, soon, or no.',
    blurbHi: 'खाने के बारे में छह सवाल, फिर साफ़ जवाब: हाँ, जल्दी, या नहीं।',
    icon: Icons.restaurant_outlined,
    keywords: const ['leftover', 'बचा खाना', 'waste', 'safe'],
    open: (_) => const ShareCheckPage(),
  ),
  Issue(
    id: 'g2i02',
    goal: 2,
    group: 'share',
    titleEn: 'Food board: give or collect food',
    titleHi: 'खाना बोर्ड: खाना दें या लें',
    blurbEn: 'Post surplus food near you, or claim what someone else has '
        'posted.',
    blurbHi: 'अपने पास बचा खाना डालें, या किसी और का डाला हुआ लें।',
    icon: Icons.volunteer_activism_outlined,
    keywords: const ['donate', 'दान', 'claim', 'board'],
    open: (_) => const FoodBoardPage(),
  ),
  Issue(
    id: 'g2i03',
    goal: 2,
    group: 'share',
    titleEn: 'How long cooked food stays safe',
    titleHi: 'पका खाना कब तक सुरक्षित रहता है',
    blurbEn: 'Time limits by weather and how the food was kept.',
    blurbHi: 'मौसम और रखने के तरीके के हिसाब से समय सीमा।',
    icon: Icons.timer_outlined,
    keywords: const ['time', 'समय', 'spoil', 'ख़राब'],
    open: (_) =>
        const GuideListPage(collection: 'foodsafety', category: 'time', title:
        'How long food stays safe', titleHi: 'खाना कब तक सुरक्षित', goal: 2),
  ),
  Issue(
    id: 'g2i04',
    goal: 2,
    group: 'share',
    titleEn: 'Serving food to a crowd safely',
    titleHi: 'भीड़ को खाना परोसना, सुरक्षित तरीके से',
    blurbEn: 'What the law expects, and how to keep a langar or function '
        'safe.',
    blurbHi: 'क़ानून क्या कहता है, और लंगर या समारोह को सुरक्षित कैसे रखें।',
    icon: Icons.groups_outlined,
    keywords: const ['langar', 'लंगर', 'function', 'fssai'],
    open: (_) =>
        const GuideListPage(collection: 'foodsafety', category: 'how', title:
        'Serving food safely', titleHi: 'सुरक्षित तरीके से परोसना', goal: 2),
  ),
  Issue(
    id: 'g2i05',
    goal: 2,
    group: 'share',
    titleEn: 'Waste less food at home',
    titleHi: 'घर में खाना कम बर्बाद करें',
    blurbEn: 'Small changes in storing and cooking that cut what you throw '
        'away.',
    blurbHi: 'रखने और पकाने में छोटे बदलाव, जिनसे फेंकना कम होता है।',
    icon: Icons.delete_sweep_outlined,
    keywords: const ['waste', 'बर्बादी', 'storage'],
    open: (_) =>
        const GuideListPage(collection: 'foodtips', title: 'Waste less food',
        titleHi: 'खाना कम बर्बाद करें', goal: 2),
  ),
  Issue(
    id: 'g2i06',
    goal: 2,
    group: 'share',
    titleEn: 'What the law lets you donate',
    titleHi: 'क़ानून आपको क्या दान करने देता है',
    blurbEn: 'The Good Samaritan rules for food, in plain words.',
    blurbHi: 'खाना दान पर नेक आदमी के नियम, आसान शब्दों में।',
    icon: Icons.gavel_outlined,
    keywords: const ['law', 'क़ानून', 'donate', 'fssai'],
    open: (_) =>
        const GuideListPage(collection: 'foodsafety', category: 'law', title:
        'What the law allows', titleHi: 'क़ानून क्या कहता है', goal: 2),
  ),
  Issue(
    id: 'g2i07',
    goal: 2,
    group: 'share',
    titleEn: 'Which foods can be shared at all',
    titleHi: 'कौन सा खाना बाँटा ही जा सकता है',
    blurbEn: 'Cooked, packaged, raw - what each kind needs before it moves.',
    blurbHi: 'पका, पैक, कच्चा - हर तरह को जाने से पहले क्या चाहिए।',
    icon: Icons.restaurant_outlined,
    keywords: const ['what', 'कौन सा', 'cooked', 'packaged'],
    open: (_) =>
        const GuideListPage(collection: 'foodsafety', category: 'what', title:
        'What can be shared', titleHi: 'क्या बाँटा जा सकता है', goal: 2),
  ),
  Issue(
    id: 'g2i08',
    goal: 2,
    group: 'share',
    titleEn: 'Who collects surplus food near you',
    titleHi: 'पास में बचा खाना कौन ले जाता है',
    blurbEn: 'Organisations that collect, and what each one takes.',
    blurbHi: 'जो संस्थाएँ इकट्ठा करती हैं, और हर एक क्या लेती है।',
    icon: Icons.local_shipping_outlined,
    keywords: const ['partner', 'संस्था', 'ngo', 'collect'],
    open: (_) =>
        const GuideListPage(collection: 'foodpartners', title:
        'Who collects food', titleHi: 'कौन खाना ले जाता है', goal: 2),
  ),
  Issue(
    id: 'g2i09',
    goal: 2,
    group: 'ration',
    titleEn: 'How much ration my card should get',
    titleHi: 'मेरे कार्ड पर कितना राशन मिलना चाहिए',
    blurbEn: 'Kilos per person per month, by card type and family size.',
    blurbHi: 'कार्ड के प्रकार और परिवार के हिसाब से, प्रति व्यक्ति प्रति माह '
        'किलो।',
    icon: Icons.rice_bowl_outlined,
    keywords: const ['ration', 'राशन', 'nfsa', 'kg'],
    open: (_) => const RationCardPage(),
  ),
  Issue(
    id: 'g2i10',
    goal: 2,
    group: 'ration',
    titleEn: 'Ration shop gave less or refused',
    titleHi: 'राशन दुकान ने कम दिया या मना किया',
    blurbEn: 'What is wrong, who to tell, and a complaint you can copy.',
    blurbHi: 'क्या ग़लत है, किसे बताएँ, और कॉपी करने लायक शिकायत।',
    icon: Icons.report_outlined,
    keywords: const ['dealer', 'डीलर', 'complaint', 'शिकायत'],
    open: (_) => const RationComplaintPage(),
  ),
  Issue(
    id: 'g2i11',
    goal: 2,
    group: 'ration',
    titleEn: 'Ration in another state',
    titleHi: 'दूसरे राज्य में राशन',
    blurbEn: 'One Nation One Ration Card: what works away from home, and how.',
    blurbHi: 'एक देश एक राशन कार्ड: घर से दूर क्या चलता है, और कैसे।',
    icon: Icons.map_outlined,
    keywords: const ['onorc', 'migrant', 'प्रवासी', 'portability'],
    open: (_) => const RationPortabilityPage(),
  ),
  Issue(
    id: 'g2i12',
    goal: 2,
    group: 'ration',
    titleEn: 'Not on the ration list at all',
    titleHi: 'राशन सूची में नाम ही नहीं',
    blurbEn: 'How to apply, and what to do while the card is being made.',
    blurbHi: 'आवेदन कैसे करें, और कार्ड बनने तक क्या करें।',
    icon: Icons.badge_outlined,
    keywords: const ['new card', 'नया कार्ड', 'apply'],
    open: (_) => const NoRationCardPage(),
  ),
  Issue(
    id: 'g2i13',
    goal: 2,
    group: 'child',
    titleEn: 'Anganwadi: what we should receive',
    titleHi: 'आंगनवाड़ी: हमें क्या मिलना चाहिए',
    blurbEn: 'Take-home ration and meals due to a child or a pregnant woman.',
    blurbHi: 'बच्चे या गर्भवती महिला को मिलने वाला राशन और भोजन।',
    icon: Icons.child_care_outlined,
    keywords: const ['anganwadi', 'आंगनवाड़ी', 'icds', 'thr'],
    open: (_) => const AnganwadiPage(),
  ),
  Issue(
    id: 'g2i14',
    goal: 2,
    group: 'child',
    titleEn: 'School midday meal not served or bad',
    titleHi: 'स्कूल का मध्याह्न भोजन नहीं मिला या ख़राब',
    blurbEn: 'What the meal must contain, and who to complain to.',
    blurbHi: 'भोजन में क्या होना चाहिए, और शिकायत किससे करें।',
    icon: Icons.school_outlined,
    keywords: const ['midday', 'मध्याह्न', 'pm poshan'],
    open: (_) => const MiddayMealPage(),
  ),
  Issue(
    id: 'g2i15',
    goal: 2,
    group: 'child',
    titleEn: 'Child arm-band check (MUAC)',
    titleHi: 'बच्चे की बाँह की जाँच (एमयूएसी)',
    blurbEn: 'Green, yellow or red - and exactly what to do for each.',
    blurbHi: 'हरा, पीला या लाल - और हर रंग पर क्या करना है।',
    icon: Icons.child_care_outlined,
    keywords: const ['malnutrition', 'कुपोषण', 'muac'],
    open: (_) => const MuacPage(),
  ),
  Issue(
    id: 'g2i16',
    goal: 2,
    group: 'child',
    titleEn: 'Baby feeding by age, 0 to 24 months',
    titleHi: 'उम्र के हिसाब से शिशु का आहार, 0 से 24 महीने',
    blurbEn: 'What to feed, how often, and what to never give yet.',
    blurbHi: 'क्या खिलाएँ, कितनी बार, और अभी क्या बिल्कुल न दें।',
    icon: Icons.child_care_outlined,
    keywords: const ['breastfeeding', 'स्तनपान', 'weaning'],
    open: (_) => const BabyFeedingPage(),
  ),
  Issue(
    id: 'g2i17',
    goal: 2,
    group: 'grow',
    titleEn: 'How much to cook for N guests',
    titleHi: 'कितने मेहमानों के लिए कितना पकाएँ',
    blurbEn: 'Quantities for a function, so less is thrown away.',
    blurbHi: 'समारोह के लिए मात्रा, ताकि कम फेंका जाए।',
    icon: Icons.calculate_outlined,
    keywords: const ['function', 'शादी', 'quantity', 'मात्रा'],
    open: (_) => const CookQuantityPage(),
  ),
  Issue(
    id: 'g2i18',
    goal: 2,
    group: 'grow',
    titleEn: 'Storing grain at home',
    titleHi: 'घर में अनाज रखना',
    blurbEn: 'Moisture, pests and how long each grain keeps.',
    blurbHi: 'नमी, कीड़े, और कौन सा अनाज कितने दिन चलता है।',
    icon: Icons.inventory_2_outlined,
    keywords: const ['grain', 'अनाज', 'storage', 'भंडारण'],
    open: (_) => const GrainStoragePage(),
  ),
  Issue(
    id: 'g2i19',
    goal: 2,
    group: 'grow',
    titleEn: 'Kitchen garden: what to sow this month',
    titleHi: 'घर की बाड़ी: इस महीने क्या बोएँ',
    blurbEn: 'Vegetables that suit this month where you are.',
    blurbHi: 'आपकी जगह, इस महीने के लिए सही सब्ज़ियाँ।',
    icon: Icons.grass_outlined,
    keywords: const ['garden', 'बाड़ी', 'sow', 'बोना'],
    open: (_) => const KitchenGardenPage(),
  ),
  Issue(
    id: 'g2i20',
    goal: 2,
    group: 'grow',
    titleEn: 'Selling a crop: MSP and where to sell',
    titleHi: 'फ़सल बेचना: एमएसपी और कहाँ बेचें',
    blurbEn: 'The minimum support price for your crop and the nearest buying '
        'centre.',
    blurbHi: 'आपकी फ़सल का न्यूनतम समर्थन मूल्य और नज़दीकी ख़रीद केंद्र।',
    icon: Icons.agriculture_outlined,
    keywords: const ['msp', 'एमएसपी', 'mandi', 'मंडी'],
    open: (_) => const SellCropPage(),
  ),
  Issue(
    id: 'g2i21',
    goal: 2,
    group: 'grow',
    titleEn: 'Kisan Credit Card',
    titleHi: 'किसान क्रेडिट कार्ड',
    blurbEn: 'Do I qualify, how much, and what to carry to the bank.',
    blurbHi: 'क्या पात्र हूँ, कितना मिलेगा, और बैंक में क्या ले जाना है।',
    icon: Icons.payments_outlined,
    keywords: const ['kcc', 'केसीसी', 'loan', 'क़र्ज़'],
    open: (_) => const KccPage(),
  ),
];

final GoalIssues sdg2Goal = GoalIssues(
  goal: 2,
  groups: _groups,
  issues: sdg2Issues,
  helplines: const [
    GoalHelpline('1967', 'Ration grievance', 'राशन शिकायत'),
    GoalHelpline('1800112100', 'FSSAI food safety', 'खाद्य सुरक्षा'),
  ],
);
