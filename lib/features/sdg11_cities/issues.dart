// GENERATED-ISSUE-FILE
// The problems SDG 11 sets out to solve.
//
// Edited by hand when a tool is built: set `open` to the screen it opens.
// Everything the goal's mini-app shows - its menu, its home screen, its
// place in the app-wide search - is read from this one list.
import 'package:flutter/material.dart';

import '../../core/issues/issue.dart';
import '../../core/widgets/guide_list_page.dart';
import 'cities_pages.dart';
import 'disaster_tools.dart';
import 'property_tools.dart';
import 'rent_tools.dart';
import 'street_tools.dart';

const _groups = [
  IssueGroup('street', 'Your street', 'आपकी गली'),
  IssueGroup('home', 'A roof over your head', 'सिर पर छत'),
  IssueGroup('papers', 'Property papers', 'ज़मीन-मकान के काग़ज़'),
  IssueGroup('disaster', 'When disaster comes', 'आपदा आए तो'),
];

final List<Issue> sdg11Issues = [
  Issue(
    id: 'g11i01',
    goal: 11,
    group: 'street',
    titleEn: 'Street problem complaint writer',
    titleHi: 'गली की समस्या: शिकायत लिखें',
    blurbEn: 'Garbage, light, water, drain or road - a complaint ready to '
        'send.',
    blurbHi: 'कूड़ा, बत्ती, पानी, नाली या सड़क - भेजने लायक तैयार शिकायत।',
    icon: Icons.edit_note_outlined,
    keywords: const ['complaint', 'शिकायत', 'garbage', 'कूड़ा'],
    open: (_) => const CivicComplaintPage(),
  ),
  Issue(
    id: 'g11i02',
    goal: 11,
    group: 'home',
    titleEn: 'PM Awas Yojana: do I qualify',
    titleHi: 'प्रधानमंत्री आवास: क्या मैं पात्र हूँ',
    blurbEn: 'Town or village, income and land, turned into the right scheme.',
    blurbHi: 'शहर या गाँव, आय और ज़मीन से, सही योजना तक।',
    icon: Icons.home_outlined,
    keywords: const ['pmay', 'आवास', 'housing', 'मकान'],
    open: (_) => const HousingFitPage(),
  ),
  Issue(
    id: 'g11i03',
    goal: 11,
    group: 'papers',
    titleEn: 'Property papers',
    titleHi: 'ज़मीन-मकान के काग़ज़',
    blurbEn: 'Mutation and tax receipts - the two that prevent most disputes.',
    blurbHi: 'दाख़िल-ख़ारिज और कर रसीदें - ये दो ज़्यादातर विवाद रोकती हैं।',
    icon: Icons.description_outlined,
    keywords: const ['mutation', 'दाख़िल ख़ारिज', 'property'],
    open: (_) =>
        const GuideListPage(collection: 'cities', category: 'property', title:
        'Property papers', titleHi: 'ज़मीन-मकान के काग़ज़', goal: 11),
  ),
  Issue(
    id: 'g11i04',
    goal: 11,
    group: 'disaster',
    titleEn: 'Flood, earthquake, lightning',
    titleHi: 'बाढ़, भूकंप, बिजली',
    blurbEn: 'What to do before, during and after each one.',
    blurbHi: 'हर एक में पहले, दौरान और बाद में क्या करें।',
    icon: Icons.flood_outlined,
    keywords: const ['flood', 'बाढ़', 'earthquake', 'भूकंप'],
    open: (_) =>
        const GuideListPage(collection: 'cities', category: 'disaster', title:
        'Disaster readiness', titleHi: 'आपदा की तैयारी', goal: 11),
  ),
  Issue(
    id: 'g11i05',
    goal: 11,
    group: 'home',
    titleEn: 'Rent agreement: what to check',
    titleHi: 'किरायानामा: क्या देखें',
    blurbEn: 'The clauses that cause trouble later, before you sign.',
    blurbHi: 'दस्तख़त से पहले, वे शर्तें जो बाद में परेशानी बनती हैं।',
    icon: Icons.description_outlined,
    keywords: const ['rent', 'किराया', 'agreement'],
    open: (_) => const RentAgreementPage(),
  ),
  Issue(
    id: 'g11i06',
    goal: 11,
    group: 'home',
    titleEn: 'Deposit not returned',
    titleHi: 'जमा राशि वापस नहीं मिली',
    blurbEn: 'A demand letter, and where to go if it is ignored.',
    blurbHi: 'माँग पत्र, और अनसुना करने पर कहाँ जाएँ।',
    icon: Icons.edit_note_outlined,
    keywords: const ['deposit', 'जमा', 'landlord', 'मकान मालिक'],
    open: (_) => const DepositPage(),
  ),
  Issue(
    id: 'g11i07',
    goal: 11,
    group: 'home',
    titleEn: 'Eviction threat',
    titleHi: 'घर ख़ाली कराने की धमकी',
    blurbEn: 'What notice is required, and what a landlord may never do.',
    blurbHi: 'कितना नोटिस ज़रूरी है, और मकान मालिक क्या कभी नहीं कर सकता।',
    icon: Icons.gavel_outlined,
    keywords: const ['eviction', 'बेदख़ली', 'notice'],
    open: (_) => const EvictionPage(),
  ),
  Issue(
    id: 'g11i08',
    goal: 11,
    group: 'papers',
    titleEn: 'Property tax: estimate and correct it',
    titleHi: 'संपत्ति कर: अनुमान और सुधार',
    blurbEn: 'Roughly what it should be, and how to get an error fixed.',
    blurbHi: 'लगभग कितना बनना चाहिए, और ग़लती कैसे ठीक कराएँ।',
    icon: Icons.receipt_long_outlined,
    keywords: const ['property tax', 'संपत्ति कर'],
    open: (_) => const PropertyTaxPage(),
  ),
  Issue(
    id: 'g11i09',
    goal: 11,
    group: 'papers',
    titleEn: 'Mutation after a death',
    titleHi: 'मृत्यु के बाद दाख़िल-ख़ारिज',
    blurbEn: 'Papers, steps, and getting every heir named.',
    blurbHi: 'काग़ज़, क़दम, और हर वारिस का नाम दर्ज कराना।',
    icon: Icons.description_outlined,
    keywords: const ['mutation', 'वारिस', 'heir'],
    open: (_) => const MutationDeathPage(),
  ),
  Issue(
    id: 'g11i10',
    goal: 11,
    group: 'street',
    titleEn: 'Overcharged by bus or auto',
    titleHi: 'बस या ऑटो ने ज़्यादा किराया लिया',
    blurbEn: 'What the fare should be, and the complaint that works.',
    blurbHi: 'किराया कितना होना चाहिए, और कौन सी शिकायत काम करती है।',
    icon: Icons.directions_bus_outlined,
    keywords: const ['fare', 'किराया', 'auto', 'ऑटो'],
    open: (_) => const FarePage(),
  ),
  Issue(
    id: 'g11i11',
    goal: 11,
    group: 'street',
    titleEn: 'Noise or smoke from a neighbour',
    titleHi: 'पड़ोसी से शोर या धुआँ',
    blurbEn: 'The limits that apply, and who enforces them.',
    blurbHi: 'कौन सी सीमाएँ लागू हैं, और कौन लागू कराता है।',
    icon: Icons.report_outlined,
    keywords: const ['noise', 'शोर', 'pollution', 'प्रदूषण'],
    open: (_) => const NoiseSmokePage(),
  ),
  Issue(
    id: 'g11i12',
    goal: 11,
    group: 'street',
    titleEn: 'Unsafe or illegal building nearby',
    titleHi: 'पास में असुरक्षित या अवैध इमारत',
    blurbEn: 'Who to tell, and what they must do about it.',
    blurbHi: 'किसे बताएँ, और उन्हें क्या करना होता है।',
    icon: Icons.report_outlined,
    keywords: const ['illegal', 'अवैध', 'building', 'इमारत'],
    open: (_) => const UnsafeBuildingPage(),
  ),
  Issue(
    id: 'g11i13',
    goal: 11,
    group: 'street',
    titleEn: 'Housing society dispute',
    titleHi: 'हाउसिंग सोसाइटी विवाद',
    blurbEn: 'Where a society complaint actually goes.',
    blurbHi: 'सोसाइटी की शिकायत असल में कहाँ जाती है।',
    icon: Icons.groups_outlined,
    keywords: const ['society', 'सोसाइटी', 'rwa'],
    open: (_) => const SocietyDisputePage(),
  ),
  Issue(
    id: 'g11i14',
    goal: 11,
    group: 'disaster',
    titleEn: 'Flood go-bag for my family',
    titleHi: 'बाढ़ के लिए तैयार थैला',
    blurbEn: 'A packing list sized to the people and papers in your house.',
    blurbHi: 'घर के लोगों और काग़ज़ों के हिसाब से सामान की सूची।',
    icon: Icons.inventory_2_outlined,
    keywords: const ['go bag', 'बाढ़', 'emergency kit'],
    open: (_) => const GoBagPage(),
  ),
  Issue(
    id: 'g11i15',
    goal: 11,
    group: 'disaster',
    titleEn: 'Is my house at risk in an earthquake',
    titleHi: 'भूकंप में मेरा घर ख़तरे में है',
    blurbEn: 'By house type, the cheap fixes that matter most.',
    blurbHi: 'घर के प्रकार के हिसाब से, सबसे काम की सस्ती मरम्मत।',
    icon: Icons.home_outlined,
    keywords: const ['earthquake', 'भूकंप', 'retrofit'],
    open: (_) => const EarthquakeRiskPage(),
  ),
  Issue(
    id: 'g11i16',
    goal: 11,
    group: 'disaster',
    titleEn: 'Road accident: what to do',
    titleHi: 'सड़क दुर्घटना: क्या करें',
    blurbEn: 'The Good Samaritan rule, and the first ten minutes.',
    blurbHi: 'नेक आदमी का नियम, और पहले दस मिनट।',
    icon: Icons.local_hospital_outlined,
    keywords: const ['accident', 'दुर्घटना', 'good samaritan'],
    open: (_) => const RoadAccidentPage(),
  ),
];

final GoalIssues sdg11Goal = GoalIssues(
  goal: 11,
  groups: _groups,
  issues: sdg11Issues,
  helplines: const [
    GoalHelpline('1077', 'District disaster control', 'ज़िला आपदा नियंत्रण'),
    GoalHelpline('112', 'Emergency', 'आपातकाल'),
    GoalHelpline('101', 'Fire', 'अग्निशमन'),
  ],
);
