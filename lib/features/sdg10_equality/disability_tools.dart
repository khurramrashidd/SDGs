import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// The disability card, and what the card unlocks.
///
/// Almost everything in this area turns on one number: 40 per cent. Below
/// it a person has a disability; at or above it they have a "benchmark
/// disability" and the reservations, the concessions and most of the
/// schemes begin. So both screens below lead with the certificate rather
/// than with the benefits, because without the certificate the benefits
/// do not exist on paper.

const _udidUrl = 'https://www.swavlambancard.gov.in/';
const _adipUrl = 'https://adip.depwd.gov.in/';
const _depwdUrl = 'https://depwd.gov.in/en/';
const _nsapUrl = 'https://nsap.nic.in/';

/// Share of the cost of an aid that ADIP pays, by monthly family income.
/// Source: ADIP scheme guidelines, Department of Empowerment of Persons
/// with Disabilities.
const adipFullFreeIncome = 22500;
const adipHalfIncome = 30000;

/// Central share of the disability pension under NSAP. States add their
/// own amount on top, and that part differs in every state, so this app
/// does not name a total.
const igndpsCentralShare = 300;
const igndpsCentralShareSenior = 500;
const igndpsSeniorAge = 80;

/// The threshold in the Rights of Persons with Disabilities Act 2016 at
/// which a disability becomes a "benchmark disability".
const benchmarkDisabilityPercent = 40;

class UdidPage extends StatelessWidget {
  const UdidPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 10,
      title: hi ? 'दिव्यांगता कार्ड (यूडीआईडी)' : 'Disability card (UDID)',
      children: [
        ToolNote(hi
            ? 'यूडीआईडी एक ही कार्ड है जो पूरे देश में चलता है, और यही दिव्यांगता '
                'प्रमाण पत्र का काम भी करता है। इसके बिना ज़्यादातर योजनाएँ, '
                'आरक्षण और छूट काग़ज़ पर मौजूद ही नहीं होतीं — इसलिए पहला काम यही '
                'है, लाभ बाद में।'
            : 'The UDID is one card that works across the country, and it '
                'doubles as the disability certificate. Without it most '
                'schemes, reservations and concessions do not exist on paper '
                '- so this is the first job, and the benefits come after.'),
        ToolQuestion(hi ? 'आवेदन के क़दम' : 'The steps'),
        ToolSteps(
          steps: hi
              ? const [
                  'swavlambancard.gov.in पर "नया आवेदन" भरें। आवेदन मुफ़्त है।',
                  'चाहिए: आधार, पासपोर्ट आकार की फ़ोटो, और दिव्यांगता का कोई पुराना '
                      'प्रमाण पत्र या अस्पताल का काग़ज़ हो तो वह भी।',
                  'आवेदन के बाद ज़िला अस्पताल या सीएमओ कार्यालय से जाँच की तारीख़ '
                      'मिलती है। आवेदन संख्या सुरक्षित रखें — आगे सब उसी से चलता है।',
                  'मेडिकल बोर्ड के सामने जाँच होती है और वही प्रतिशत तय करता है। '
                      'अपने सारे पुराने काग़ज़, पर्चे और जाँच रिपोर्ट साथ ले जाएँ।',
                  'प्रमाण पत्र बनने के बाद कार्ड डाक से आता है, और पोर्टल से तुरंत '
                      'डाउनलोड भी किया जा सकता है।',
                ]
              : const [
                  'Fill a new application on swavlambancard.gov.in. There is '
                      'no fee.',
                  'You need Aadhaar, a passport photo, and any older '
                      'disability certificate or hospital paper if you have '
                      'one.',
                  'After applying you get an assessment date at the district '
                      'hospital or the CMO office. Keep the application '
                      'number safe - everything afterwards runs on it.',
                  'A medical board examines you and it is the board that '
                      'fixes the percentage. Carry every old paper, '
                      'prescription and test report with you.',
                  'Once the certificate is made, the card comes by post and '
                      'can also be downloaded from the portal at once.',
                ],
        ),
        const SizedBox(height: 14),
        ToolAnswer(
          headline: hi
              ? '$benchmarkDisabilityPercent प्रतिशत वाला अंक'
              : 'The $benchmarkDisabilityPercent per cent mark',
          detail: hi
              ? 'प्रमाण पत्र पर लिखा प्रतिशत सबसे ज़्यादा मायने रखता है। '
                  '$benchmarkDisabilityPercent प्रतिशत या उससे ऊपर होने पर इसे '
                  '"बेंचमार्क दिव्यांगता" कहा जाता है, और सरकारी नौकरी तथा उच्च '
                  'शिक्षा में आरक्षण, मुफ़्त उपकरण और ज़्यादातर योजनाएँ वहीं से शुरू '
                  'होती हैं। इसलिए जाँच के दिन हर काग़ज़ साथ होना ज़रूरी है — बाद में '
                  'प्रतिशत बदलवाना बहुत मुश्किल काम है।'
              : 'The percentage written on the certificate matters more than '
                  'anything else on it. At $benchmarkDisabilityPercent per '
                  'cent or above it is called a "benchmark disability", and '
                  'that is where reservation in government jobs and higher '
                  'education, free aids and most schemes begin. Which is why '
                  'every paper has to be with you on assessment day - '
                  'getting the percentage changed afterwards is hard work.',
          tone: ToolTone.plain,
          icon: Icons.verified_outlined,
        ),
        const SizedBox(height: 14),
        Text(hi ? 'कार्ड से क्या मिलता है' : 'What the card opens',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'सरकारी नौकरियों में आरक्षण, और उच्च शिक्षा में सीटों का आरक्षण',
                  'मुफ़्त या आधे दाम पर उपकरण (एडिप) — इसी लक्ष्य की अगली स्क्रीन पर',
                  'रेल और बस में किराये में छूट, और सहायक के लिए भी छूट',
                  'दिव्यांग पेंशन, जहाँ आय और प्रतिशत की शर्तें पूरी हों',
                  'आयकर में छूट (धारा 80यू), और सवारी गाड़ी पर कुछ राज्यों में कर में '
                      'छूट',
                  'परीक्षा में लेखक की सुविधा और अतिरिक्त समय',
                  'सरकारी इमारतों, बस-रेल और वेबसाइटों में सुगम्यता का अधिकार',
                ]
              : const [
                  'Reservation in government jobs, and reserved seats in '
                      'higher education',
                  'Free or half-price aids under ADIP - the next screen in '
                      'this goal',
                  'Concession in rail and bus fares, including for an '
                      'escort',
                  'Disability pension, where the income and percentage '
                      'conditions are met',
                  'Income tax relief under section 80U, and in some states '
                      'relief on vehicle tax',
                  'A scribe and extra time in examinations',
                  'A right of access to government buildings, buses and '
                      'trains, and websites',
                ],
        ),
        ToolDonts(
          heading: hi ? 'सावधानी' : 'Watch out',
          items: hi
              ? const [
                  'कार्ड बनवाने के नाम पर पैसा माँगने वाले बिचौलिए से बचें — पूरी '
                      'प्रक्रिया मुफ़्त है',
                  'जाँच की तारीख़ पर न पहुँचने से आवेदन रुक जाता है; न जा सकें तो '
                      'पोर्टल पर या अस्पताल में पहले से बता दें',
                  'बच्चों का प्रतिशत उम्र के साथ बदल सकता है, इसलिए कार्ड की वैधता '
                      'की तारीख़ देख लें और समय से नया बनवाएँ',
                  'आवेदन संख्या और सारे काग़ज़ों की एक-एक नक़ल अपने पास रखें',
                ]
              : const [
                  'Avoid middlemen asking for money to get the card - the '
                      'whole process is free',
                  'Missing the assessment date stalls the application; if '
                      'you cannot go, say so beforehand on the portal or at '
                      'the hospital',
                  'A child\'s percentage can change with age, so check the '
                      'validity date on the card and renew it in time',
                  'Keep the application number and a copy of every paper '
                      'with you',
                ],
        ),
        const SourceNote(text: 'UDID - Swavlamban Card portal', url: _udidUrl),
        const SourceNote(
            text: 'Department of Empowerment of Persons with Disabilities',
            url: _depwdUrl),
      ],
    );
  }
}

enum _Need { aids, pension }

class DisabilitySupportPage extends StatefulWidget {
  const DisabilitySupportPage({super.key});

  @override
  State<DisabilitySupportPage> createState() => _DisabilitySupportPageState();
}

class _DisabilitySupportPageState extends State<DisabilitySupportPage> {
  _Need? _need;
  final _income = TextEditingController();
  final _age = TextEditingController();

  @override
  void dispose() {
    _income.dispose();
    _age.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final income = int.tryParse(_income.text.trim());
    final age = int.tryParse(_age.text.trim());

    return ToolScaffold(
      goal: 10,
      title: hi ? 'दिव्यांग पेंशन और मुफ़्त उपकरण' : 'Disability pension and free aids',
      children: [
        ToolNote(hi
            ? 'दोनों के लिए दिव्यांगता प्रमाण पत्र या यूडीआईडी कार्ड पहली शर्त है। '
                'अगर वह नहीं बना है तो इसी लक्ष्य में "दिव्यांगता कार्ड" वाली स्क्रीन '
                'पहले देखें।'
            : 'Both of these need a disability certificate or a UDID card '
                'first. If that is not made yet, see the "Disability card" '
                'screen in this goal before this one.'),
        ToolQuestion(hi ? 'किस बारे में जानना है' : 'Which one do you need'),
        SelectionTile(
          label: hi ? 'उपकरण — मुफ़्त या सस्ते में' : 'An aid - free or subsidised',
          subtitle: hi
              ? 'कृत्रिम अंग, व्हीलचेयर, श्रवण यंत्र, छड़ी, ट्राइसाइकिल'
              : 'Artificial limb, wheelchair, hearing aid, cane, tricycle',
          selected: _need == _Need.aids,
          onTap: () => setState(() => _need = _Need.aids),
        ),
        SelectionTile(
          label: hi ? 'पेंशन' : 'A pension',
          subtitle: hi
              ? 'हर महीने मिलने वाली राशि'
              : 'A monthly amount',
          selected: _need == _Need.pension,
          onTap: () => setState(() => _need = _Need.pension),
        ),
        if (_need == _Need.aids) ...[
          ToolQuestion(hi ? 'परिवार की महीने की आय' : 'Family income a month'),
          ToolNumber(
            controller: _income,
            label: hi ? 'सब स्रोतों से मिलाकर (₹)' : 'From all sources (₹)',
            maxDigits: 8,
            icon: Icons.currency_rupee,
            onChanged: (_) => setState(() {}),
          ),
          if (income != null && income > 0) ...[
            if (income <= adipFullFreeIncome)
              ToolAnswer(
                headline: hi ? 'उपकरण पूरा मुफ़्त' : 'The aid is fully free',
                detail: hi
                    ? 'महीने की आय ₹$adipFullFreeIncome तक होने पर एडिप योजना में '
                        'उपकरण का पूरा ख़र्च सरकार उठाती है। शर्त यह भी है कि प्रमाण '
                        'पत्र पर दिव्यांगता $benchmarkDisabilityPercent प्रतिशत या '
                        'उससे ऊपर हो।'
                    : 'With a monthly income up to ₹$adipFullFreeIncome, the '
                        'ADIP scheme pays the whole cost of the aid. The '
                        'other condition is that the certificate shows '
                        '$benchmarkDisabilityPercent per cent disability or '
                        'more.',
                tone: ToolTone.good,
                icon: Icons.accessible_outlined,
              )
            else if (income <= adipHalfIncome)
              ToolAnswer(
                headline: hi ? 'आधा ख़र्च सरकार देती है' : 'Half the cost is paid',
                detail: hi
                    ? 'महीने की आय ₹${adipFullFreeIncome + 1} से ₹$adipHalfIncome '
                        'के बीच होने पर एडिप योजना उपकरण का आधा ख़र्च देती है।'
                    : 'With a monthly income between '
                        '₹${adipFullFreeIncome + 1} and ₹$adipHalfIncome, '
                        'ADIP pays half the cost of the aid.',
                tone: ToolTone.good,
                icon: Icons.accessible_outlined,
              )
            else
              ToolAnswer(
                headline: hi ? 'एडिप की आय सीमा से ऊपर' : 'Above the ADIP income limit',
                detail: hi
                    ? 'एडिप योजना की सीमा महीने की आय ₹$adipHalfIncome है। इसके ऊपर '
                        'भी दो रास्ते बचते हैं: कई राज्यों की अपनी योजनाएँ हैं जिनकी '
                        'सीमा अलग है, और ज़िले में लगने वाले शिविरों में कई संस्थाएँ '
                        'मुफ़्त उपकरण बाँटती हैं। ज़िला समाज कल्याण कार्यालय में पूछें।'
                    : 'The ADIP limit is a monthly income of '
                        '₹$adipHalfIncome. Above it two routes remain: many '
                        'states run schemes of their own with different '
                        'limits, and the camps held in the district often '
                        'distribute aids free. Ask at the district social '
                        'welfare office.',
                tone: ToolTone.warn,
                icon: Icons.info_outlined,
              ),
            const SizedBox(height: 12),
            Text(hi ? 'कैसे लें' : 'How to get one',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ToolSteps(
              steps: hi
                  ? const [
                      'adip.depwd.gov.in पर आवेदन करें, या ज़िला समाज कल्याण '
                          'कार्यालय में।',
                      'ज़्यादातर उपकरण शिविरों में बाँटे जाते हैं। शिविर की तारीख़ '
                          'ज़िला कार्यालय, आँगनवाड़ी या पंचायत से पता चलती है — '
                          'पंजीकरण पहले कराना पड़ता है।',
                      'नापजोख के बाद उपकरण बनता है, इसलिए शिविर में दो बार जाना पड़ '
                          'सकता है: एक बार नाप के लिए, एक बार लेने।',
                      'उपकरण लेते समय वारंटी और मरम्मत का काग़ज़ ज़रूर लें। कृत्रिम '
                          'अंग और श्रवण यंत्र दोनों को समय-समय पर ठीक कराना होता है।',
                    ]
                  : const [
                      'Apply on adip.depwd.gov.in, or at the district social '
                          'welfare office.',
                      'Most aids are given out at camps. The camp date comes '
                          'from the district office, the anganwadi or the '
                          'panchayat - registration has to be done '
                          'beforehand.',
                      'The aid is made after measurement, so the camp may '
                          'mean two visits: one to be measured, one to '
                          'collect.',
                      'Take the warranty and repair paper when you collect '
                          'it. Both artificial limbs and hearing aids need '
                          'servicing from time to time.',
                    ],
            ),
            const SourceNote(text: 'ADIP scheme', url: _adipUrl),
          ],
        ],
        if (_need == _Need.pension) ...[
          ToolQuestion(hi ? 'उम्र' : 'Age'),
          ToolNumber(
            controller: _age,
            label: hi ? 'साल' : 'Years',
            maxDigits: 3,
            icon: Icons.person_outline,
            onChanged: (_) => setState(() {}),
          ),
          if (age != null && age > 0) ...[
            ToolAnswer(
              headline: age >= igndpsSeniorAge
                  ? (hi
                      ? 'केंद्र का हिस्सा ₹$igndpsCentralShareSenior महीना'
                      : 'The central share is ₹$igndpsCentralShareSenior a month')
                  : (hi
                      ? 'केंद्र का हिस्सा ₹$igndpsCentralShare महीना'
                      : 'The central share is ₹$igndpsCentralShare a month'),
              detail: hi
                  ? 'राष्ट्रीय सामाजिक सहायता कार्यक्रम में दिव्यांग पेंशन का केंद्र '
                      'वाला हिस्सा यही है। इसके ऊपर हर राज्य अपनी राशि जोड़ता है, और '
                      'वह राज्य-राज्य में बहुत अलग है — इसलिए यह ऐप कुल रक़म नहीं '
                      'बताता। असली रक़म अपने राज्य के समाज कल्याण पोर्टल पर या '
                      'पंचायत/नगर पालिका में पूछें।'
                  : 'That is the central share of the disability pension '
                      'under the National Social Assistance Programme. Each '
                      'state adds its own amount on top, and that part '
                      'differs a great deal from state to state - so this '
                      'app does not name a total. Ask for the real figure on '
                      'your state\'s social welfare portal, or at the '
                      'panchayat or municipality.',
              tone: ToolTone.plain,
              icon: Icons.payments_outlined,
            ),
            const SizedBox(height: 12),
            Text(hi ? 'शर्तें' : 'Conditions',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ToolSteps(
              numbered: false,
              steps: hi
                  ? const [
                      'प्रमाण पत्र पर दिव्यांगता 80 प्रतिशत या उससे ऊपर, या बहु-'
                          'दिव्यांगता',
                      'परिवार ग़रीबी रेखा के नीचे की सूची में हो',
                      'उम्र 18 साल या उससे ऊपर',
                      'राज्यों की अपनी पेंशन योजनाओं की शर्तें इससे नरम हो सकती '
                          'हैं — वहाँ 40 प्रतिशत पर भी पेंशन मिलती है, इसलिए दोनों '
                          'के बारे में पूछें',
                    ]
                  : const [
                      'The certificate shows 80 per cent disability or more, '
                          'or multiple disability',
                      'The family is on the below-poverty-line list',
                      'Age 18 or above',
                      'States run pension schemes of their own on easier '
                          'conditions - some pay from 40 per cent - so ask '
                          'about both',
                    ],
            ),
            const SizedBox(height: 10),
            ToolNote(hi
                ? 'आवेदन पंचायत या नगर पालिका में, या राज्य के पोर्टल पर होता है। '
                    'रसीद ज़रूर लें। पेंशन बंद हो जाए तो बैंक खाते और आधार के जुड़े '
                    'होने की जाँच पहले करें — रुकने की सबसे आम वजह यही होती है, और '
                    'यह बैंक में ही ठीक हो जाती है।'
                : 'The application goes to the panchayat or municipality, or '
                    'on the state portal. Take a receipt. If a pension '
                    'stops, check first that the bank account and Aadhaar '
                    'are linked - that is the commonest reason, and it is '
                    'fixed at the bank itself.'),
            const SourceNote(
                text: 'National Social Assistance Programme', url: _nsapUrl),
          ],
        ],
      ],
    );
  }
}
