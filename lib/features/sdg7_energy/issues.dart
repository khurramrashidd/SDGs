// GENERATED-ISSUE-FILE
// The problems SDG 7 sets out to solve.
//
// Edited by hand when a tool is built: set `open` to the screen it opens.
// Everything the goal's mini-app shows - its menu, its home screen, its
// place in the app-wide search - is read from this one list.
import 'package:flutter/material.dart';

import '../../core/issues/issue.dart';
import '../../core/widgets/guide_list_page.dart';
import 'bill_check_page.dart';
import 'bill_tools.dart';
import 'connect_tools.dart';
import 'energy_safety_tools.dart';
import 'solar_lpg_tools.dart';

const _groups = [
  IssueGroup('bill', 'Your bill and meter', 'बिल और मीटर'),
  IssueGroup('connect', 'Connection and supply', 'कनेक्शन और सप्लाई'),
  IssueGroup('solar', 'Solar and subsidy', 'सौर और सब्सिडी'),
  IssueGroup('safe', 'Use it safely', 'सुरक्षित इस्तेमाल'),
];

final List<Issue> sdg7Issues = [
  Issue(
    id: 'g7i01',
    goal: 7,
    group: 'bill',
    titleEn: 'Is my electricity bill wrong',
    titleHi: 'क्या मेरा बिजली बिल ग़लत है',
    blurbEn: 'Check the readings and the rate, and get a complaint draft if '
        'it is.',
    blurbHi: 'रीडिंग और दर जाँचें, ग़लत हो तो शिकायत का मसौदा लें।',
    icon: Icons.receipt_long_outlined,
    keywords: const ['bill', 'बिल', 'electricity', 'बिजली'],
    open: (_) => const BillCheckPage(),
  ),
  Issue(
    id: 'g7i02',
    goal: 7,
    group: 'bill',
    titleEn: 'What each appliance costs a month',
    titleHi: 'हर उपकरण का महीने का ख़र्च',
    blurbEn: 'Units and rupees for the fan, fridge, pump and cooler you run.',
    blurbHi: 'पंखा, फ़्रिज, पंप और कूलर की इकाइयाँ और रुपये।',
    icon: Icons.calculate_outlined,
    keywords: const ['units', 'यूनिट', 'appliance', 'consumption'],
    open: (_) => const AppliancePage(),
  ),
  Issue(
    id: 'g7i03',
    goal: 7,
    group: 'bill',
    titleEn: 'Meter running fast',
    titleHi: 'मीटर तेज़ चल रहा है',
    blurbEn: 'How to ask for a meter test, and what it costs if you are '
        'right.',
    blurbHi: 'मीटर जाँच कैसे माँगें, और सही निकले तो ख़र्च कितना।',
    icon: Icons.speed_outlined,
    keywords: const ['meter', 'मीटर', 'test', 'जाँच'],
    open: (_) => const MeterTestPage(),
  ),
  Issue(
    id: 'g7i04',
    goal: 7,
    group: 'bill',
    titleEn: 'Is a 5-star appliance worth the extra',
    titleHi: 'क्या 5-स्टार उपकरण का ज़्यादा दाम सही है',
    blurbEn: 'Price difference against units saved, over the years you will '
        'keep it.',
    blurbHi: 'दाम का अंतर बनाम बचने वाली इकाइयाँ, जितने साल चलाएँगे उस पर।',
    icon: Icons.bolt_outlined,
    keywords: const ['star rating', 'bee', 'स्टार', 'saving'],
    open: (_) => const StarRatingPage(),
  ),
  Issue(
    id: 'g7i05',
    goal: 7,
    group: 'bill',
    titleEn: 'LED swap: what it saves',
    titleHi: 'एलईडी बदलने से क्या बचता है',
    blurbEn: 'Bulbs and fans changed, turned into rupees a month.',
    blurbHi: 'बल्ब और पंखे बदलने पर महीने के रुपये में बचत।',
    icon: Icons.lightbulb_outlined,
    keywords: const ['led', 'एलईडी', 'bulb', 'बल्ब'],
    open: (_) => const LedSwapPage(),
  ),
  Issue(
    id: 'g7i06',
    goal: 7,
    group: 'connect',
    titleEn: 'New connection is delayed',
    titleHi: 'नया कनेक्शन देर से मिल रहा है',
    blurbEn: 'The time limit your state sets, and the complaint to send.',
    blurbHi: 'आपके राज्य की तय समय सीमा, और भेजने लायक शिकायत।',
    icon: Icons.bolt_outlined,
    keywords: const ['connection', 'कनेक्शन', 'new', 'delay'],
    open: (_) => const NewConnectionPage(),
  ),
  Issue(
    id: 'g7i07',
    goal: 7,
    group: 'connect',
    titleEn: 'Power cut for hours',
    titleHi: 'घंटों बिजली कटौती',
    blurbEn: 'What counts as a long outage, and whether compensation applies.',
    blurbHi: 'लंबी कटौती क्या मानी जाती है, और मुआवज़ा बनता है या नहीं।',
    icon: Icons.power_off_outlined,
    keywords: const ['outage', 'कटौती', 'compensation'],
    open: (_) => const PowerCutPage(),
  ),
  Issue(
    id: 'g7i08',
    goal: 7,
    group: 'connect',
    titleEn: 'Inverter and battery size for my home',
    titleHi: 'मेरे घर के लिए इन्वर्टर और बैटरी का आकार',
    blurbEn: 'What you want to run and for how long, turned into a size.',
    blurbHi: 'क्या-क्या और कितनी देर चलाना है, उसी से आकार।',
    icon: Icons.battery_charging_full_outlined,
    keywords: const ['inverter', 'इन्वर्टर', 'battery'],
    open: (_) => const InverterPage(),
  ),
  Issue(
    id: 'g7i09',
    goal: 7,
    group: 'solar',
    titleEn: 'Rooftop solar subsidy',
    titleHi: 'छत पर सौर सब्सिडी',
    blurbEn: 'Am I eligible, how much the subsidy is, and the steps.',
    blurbHi: 'क्या पात्र हूँ, सब्सिडी कितनी है, और क़दम क्या।',
    icon: Icons.wb_sunny_outlined,
    keywords: const ['solar', 'सौर', 'surya ghar', 'subsidy'],
    open: (_) => const RooftopSolarPage(),
  ),
  Issue(
    id: 'g7i10',
    goal: 7,
    group: 'solar',
    titleEn: 'Solar pump for farming (PM-KUSUM)',
    titleHi: 'खेती के लिए सौर पंप (पीएम-कुसुम)',
    blurbEn: 'Eligibility, the share you pay, and where to apply.',
    blurbHi: 'पात्रता, आपका हिस्सा, और आवेदन कहाँ।',
    icon: Icons.agriculture_outlined,
    keywords: const ['kusum', 'कुसुम', 'pump', 'पंप'],
    open: (_) => const KusumPage(),
  ),
  Issue(
    id: 'g7i11',
    goal: 7,
    group: 'solar',
    titleEn: 'LPG, solar and clean cooking guides',
    titleHi: 'एलपीजी, सौर और साफ़ चूल्हे की जानकारी',
    blurbEn: 'Thirteen cards on cooking fuel, indoor smoke and safety.',
    blurbHi: 'खाना पकाने के ईंधन, घर के धुएँ और सुरक्षा पर तेरह कार्ड।',
    icon: Icons.local_fire_department_outlined,
    keywords: const ['lpg', 'एलपीजी', 'smoke', 'धुआँ'],
    open: (_) =>
        const GuideListPage(collection: 'energyguides', title:
        'Energy guides', titleHi: 'ऊर्जा की जानकारी', goal: 7),
  ),
  Issue(
    id: 'g7i12',
    goal: 7,
    group: 'solar',
    titleEn: 'Free LPG connection (Ujjwala)',
    titleHi: 'मुफ़्त एलपीजी कनेक्शन (उज्ज्वला)',
    blurbEn: 'Who qualifies, what arrives free, and what is not free.',
    blurbHi: 'कौन पात्र है, मुफ़्त में क्या मिलता है, और क्या नहीं।',
    icon: Icons.local_fire_department_outlined,
    keywords: const ['ujjwala', 'उज्ज्वला', 'gas'],
    open: (_) => const UjjwalaPage(),
  ),
  Issue(
    id: 'g7i13',
    goal: 7,
    group: 'solar',
    titleEn: 'LPG subsidy not credited',
    titleHi: 'एलपीजी सब्सिडी नहीं आई',
    blurbEn: 'Find where it is stuck, and the number to call.',
    blurbHi: 'पता लगाएँ कहाँ अटकी है, और कौन सा नंबर मिलाएँ।',
    icon: Icons.payments_outlined,
    keywords: const ['subsidy', 'सब्सिडी', 'dbtl', 'pahal'],
    open: (_) => const LpgSubsidyPage(),
  ),
  Issue(
    id: 'g7i14',
    goal: 7,
    group: 'safe',
    titleEn: 'LPG leak: what to do right now',
    titleHi: 'एलपीजी रिसाव: अभी क्या करें',
    blurbEn: 'The order matters. Do these in order, and never do these.',
    blurbHi: 'क्रम ज़रूरी है। ये क्रम से करें, और ये कभी न करें।',
    icon: Icons.warning_amber_outlined,
    keywords: const ['leak', 'रिसाव', 'gas', '1906'],
    open: (_) => const LpgLeakPage(),
  ),
  Issue(
    id: 'g7i15',
    goal: 7,
    group: 'safe',
    titleEn: 'Electric shock or a fallen wire',
    titleHi: 'करंट लगना या तार गिरना',
    blurbEn: 'What to do before touching anyone, and who to call.',
    blurbHi: 'किसी को छूने से पहले क्या करें, और किसे बुलाएँ।',
    icon: Icons.warning_amber_outlined,
    keywords: const ['shock', 'करंट', 'wire', 'तार'],
    open: (_) => const ElectricShockPage(),
  ),
  Issue(
    id: 'g7i16',
    goal: 7,
    group: 'safe',
    titleEn: 'Is my house wiring safe',
    titleHi: 'क्या घर की वायरिंग सुरक्षित है',
    blurbEn: 'Signs of trouble, and the one device that prevents most deaths.',
    blurbHi: 'ख़राबी के संकेत, और वह एक उपकरण जो ज़्यादातर मौतें रोकता है।',
    icon: Icons.bolt_outlined,
    keywords: const ['wiring', 'वायरिंग', 'elcb', 'earthing'],
    open: (_) => const WiringSafetyPage(),
  ),
];

final GoalIssues sdg7Goal = GoalIssues(
  goal: 7,
  groups: _groups,
  issues: sdg7Issues,
  helplines: const [
    GoalHelpline('1912', 'Electricity complaint', 'बिजली शिकायत'),
    GoalHelpline('1906', 'LPG leak emergency', 'एलपीजी रिसाव'),
    GoalHelpline('1800180333', 'Ujjwala / LPG help', 'उज्ज्वला मदद'),
  ],
);
