import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// The ₹5 lakh cover, and what to do when a hospital asks for money anyway.
///
/// These two screens are a pair. The first tells a family whether they are
/// covered, because an enormous number of eligible families do not know
/// they are and pay for treatment out of a sold buffalo. The second is the
/// one that matters more: being charged under a scheme that is free is
/// routine, families pay because they are at the worst moment of their
/// lives and in no position to argue, and the money is recoverable - but
/// only by someone who knows the complaint exists.

const _pmjayUrl = 'https://nha.gov.in/PM-JAY';
const _beneficiaryUrl = 'https://beneficiary.nha.gov.in/';
const _pmjaySeniorUrl = 'https://nha.gov.in/img/resources/Press_Release.pdf';

const pmjayCoverRupees = 500000;
const pmjayPreHospitalDays = 3;
const pmjayPostHospitalDays = 15;
const pmjaySeniorAge = 70;

/// How a household might be covered. The 70-plus route is the one most
/// people have not heard of, and it ignores income entirely.
enum CoverRoute { seventyPlus, secc, stateScheme, notCovered, unsure }

class AyushmanPage extends StatefulWidget {
  const AyushmanPage({super.key});

  @override
  State<AyushmanPage> createState() => _AyushmanPageState();
}

class _AyushmanPageState extends State<AyushmanPage> {
  final _age = TextEditingController();
  bool _familyHasCard = false;

  @override
  void dispose() {
    _age.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final age = int.tryParse(_age.text.trim());
    final senior = age != null && age >= pmjaySeniorAge;

    return ToolScaffold(
      goal: 3,
      title: hi ? 'मुफ़्त इलाज: आयुष्मान भारत' : 'Free treatment: Ayushman Bharat',
      children: [
        ToolNote(hi
            ? 'आयुष्मान भारत (PM-JAY) में हर पात्र परिवार को साल में ₹5 लाख तक का '
                'अस्पताल में भर्ती का इलाज मुफ़्त मिलता है — कैशलेस, यानी अस्पताल में पैसा '
                'देना ही नहीं है। पुरानी बीमारी पहले दिन से शामिल है, परिवार में कितने लोग '
                'हों इसकी कोई सीमा नहीं, और उम्र की कोई सीमा नहीं।'
            : 'Ayushman Bharat (PM-JAY) gives every eligible family up to '
                '₹5 lakh of free hospital treatment a year - cashless, which '
                'means no money changes hands at the hospital at all. '
                'Pre-existing conditions are covered from day one, there is '
                'no cap on family size, and no age limit.'),
        ToolQuestion(hi ? 'जिसका इलाज कराना है, उनकी उम्र' : 'Age of the person needing treatment'),
        ToolNumber(
          controller: _age,
          label: hi ? 'पूरे साल' : 'Completed years',
          maxDigits: 3,
          icon: Icons.person_outline,
          onChanged: (_) => setState(() {}),
        ),
        SwitchListTile(
          value: _familyHasCard,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'परिवार के पास पहले से आयुष्मान कार्ड है'
              : 'The family already has an Ayushman card'),
          onChanged: (v) => setState(() => _familyHasCard = v),
        ),
        if (age != null && age > 0) ...[
          if (senior)
            ToolAnswer(
              headline: hi
                  ? '70 पार — आय देखे बिना कवर'
                  : 'Over 70 - covered, whatever the income',
              detail: _familyHasCard
                  ? (hi
                      ? 'सितंबर 2024 से 70 साल और उससे ऊपर के हर व्यक्ति को आय देखे '
                          'बिना कवर मिलता है। परिवार के पास पहले से कार्ड है, तो यह उसमें '
                          'से नहीं कटेगा: बुज़ुर्ग को अपना अलग ₹5 लाख सालाना टॉप-अप मिलता '
                          'है और उनका अलग कार्ड बनता है। घर के बाक़ी लोगों का हिस्सा कम '
                          'नहीं होता।'
                      : 'Since September 2024 everyone aged 70 and above is '
                          'covered, whatever their income. Since the family '
                          'already has a card, this does not come out of it: '
                          'the senior gets their own additional ₹5 lakh a year '
                          'as a top-up, on a separate card of their own. The '
                          'younger members\' cover is not reduced.')
                  : (hi
                      ? 'सितंबर 2024 से 70 साल और उससे ऊपर के हर व्यक्ति को आय देखे '
                          'बिना ₹5 लाख सालाना का कवर मिलता है — ग़रीबी रेखा, SECC सूची, '
                          'कुछ भी देखा नहीं जाता। सिर्फ़ उम्र।'
                      : 'Since September 2024 everyone aged 70 and above gets '
                          '₹5 lakh of cover a year regardless of income - no '
                          'poverty line, no SECC list, nothing. Age alone.'),
              tone: ToolTone.good,
              icon: Icons.elderly_outlined,
            )
          else
            ToolAnswer(
              headline: hi ? 'पात्रता सूची से तय होती है' : 'Eligibility comes from a list',
              detail: hi
                  ? '70 से कम उम्र में पात्रता 2011 की सामाजिक-आर्थिक जनगणना (SECC) '
                      'के आँकड़ों से तय होती है — मोटे तौर पर सबसे नीचे के 40% परिवार। '
                      'आप सूची में हैं या नहीं, यह दो मिनट में beneficiary.nha.gov.in पर '
                      'राशन कार्ड या मोबाइल नंबर से देखा जा सकता है, या किसी भी सरकारी '
                      'अस्पताल के आयुष्मान मित्र काउंटर पर। कई राज्यों की अपनी योजना भी '
                      'है जो इससे ज़्यादा परिवारों को लेती है।'
                  : 'Below 70, eligibility comes from the 2011 '
                      'socio-economic census data - roughly the poorest 40% of '
                      'households. Whether you are on that list takes two '
                      'minutes to check at beneficiary.nha.gov.in with a '
                      'ration card or mobile number, or at the Ayushman Mitra '
                      'desk in any government hospital. Many states also run '
                      'their own scheme covering more families than this.',
              tone: ToolTone.plain,
              icon: Icons.fact_check_outlined,
            ),
          const SizedBox(height: 14),
          Text(hi ? 'कवर में क्या आता है' : 'What the cover includes',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ToolLine(hi ? 'साल में प्रति परिवार' : 'Per family per year',
              '₹5,00,000', strong: true),
          ToolLine(hi ? 'भर्ती से पहले के ख़र्च' : 'Before admission',
              hi ? '$pmjayPreHospitalDays दिन' : '$pmjayPreHospitalDays days'),
          ToolLine(hi ? 'छुट्टी के बाद की देखभाल' : 'Follow-up after discharge',
              hi ? '$pmjayPostHospitalDays दिन' : '$pmjayPostHospitalDays days'),
          ToolLine(hi ? 'दवाएँ और सामान' : 'Medicines and consumables',
              hi ? 'शामिल' : 'Included'),
          ToolLine(hi ? 'जाँच और लैब टेस्ट' : 'Diagnostics and lab tests',
              hi ? 'शामिल' : 'Included'),
          ToolLine(hi ? 'पुरानी बीमारी' : 'Pre-existing conditions',
              hi ? 'पहले दिन से' : 'From day one'),
          const SizedBox(height: 14),
          Text(hi ? 'कार्ड बनवाने के लिए' : 'To get the card made',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const ToolChecklist(
            storageKey: 'ayushman_card_v1',
            introEn: 'The card itself is free. Nobody should charge for '
                'making it.',
            introHi: 'कार्ड बनवाना मुफ़्त है। इसके पैसे कोई नहीं ले सकता।',
            items: [
              CheckItem('check', 'Check eligibility on '
                  'beneficiary.nha.gov.in, or at the hospital desk',
                  'beneficiary.nha.gov.in पर या अस्पताल के काउंटर पर पात्रता देखें'),
              CheckItem('aadhaar', 'Aadhaar of the person the card is for',
                  'जिसका कार्ड बनेगा उसका आधार'),
              CheckItem('ration', 'Ration card, for the family link',
                  'राशन कार्ड, परिवार से जोड़ने के लिए'),
              CheckItem('mobile', 'A mobile number that receives OTPs',
                  'एक मोबाइल नंबर जिस पर ओटीपी आता हो'),
              CheckItem('ekyc', 'Do the e-KYC - face or fingerprint works '
                  'where OTP does not',
                  'ई-केवाईसी कराएँ — ओटीपी न आए तो चेहरे या उँगली से भी होती है'),
              CheckItem('where', 'Free at any empanelled hospital, a Common '
                  'Service Centre, or an Ayushman Arogya Mandir',
                  'किसी भी सूचीबद्ध अस्पताल, कॉमन सर्विस सेंटर या आयुष्मान आरोग्य '
                      'मंदिर पर मुफ़्त'),
            ],
          ),
          ToolNote(hi
              ? 'भर्ती होने के वक़्त कार्ड न बना हो तो अस्पताल में ही बनवाया जा सकता है — '
                  'इसलिए "कार्ड नहीं है" सुनकर इलाज न छोड़ें। हेल्पलाइन 14555।'
              : 'If the card is not made when someone needs admission, it can '
                  'be made at the hospital itself - so do not walk away from '
                  'treatment because "there is no card". Helpline 14555.'),
          const SourceNote(text: 'PM-JAY, National Health Authority', url: _pmjayUrl),
          const SourceNote(
              text: 'Check your name on the beneficiary portal',
              url: _beneficiaryUrl),
          if (senior)
            const SourceNote(
                text: 'Cover for everyone aged 70 and above',
                url: _pmjaySeniorUrl),
        ],
      ],
    );
  }
}

// --- Charged under a free scheme --------------------------------------

/// Which scheme the treatment was under. The complaint ladder is the same;
/// what differs is who the first rung is.
enum FreeScheme { pmjay, delivery, govtHospital, unsure }

class ChargedUnderFreeSchemePage extends StatefulWidget {
  const ChargedUnderFreeSchemePage({super.key});

  @override
  State<ChargedUnderFreeSchemePage> createState() =>
      _ChargedUnderFreeSchemePageState();
}

class _ChargedUnderFreeSchemePageState
    extends State<ChargedUnderFreeSchemePage> {
  FreeScheme? _scheme;
  final _amount = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final paid = int.tryParse(_amount.text.trim());

    Widget pick(FreeScheme s, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _scheme == s,
          onTap: () => setState(() => _scheme = s),
        );

    return ToolScaffold(
      goal: 3,
      title: hi
          ? 'मुफ़्त योजना में पैसे माँगे गए'
          : 'Asked for money under a free scheme',
      children: [
        ToolNote(hi
            ? 'यह आम है, और वसूला हुआ पैसा वापस मिल सकता है। परिवार इसलिए दे देता '
                'है कि वह ज़िंदगी के सबसे बुरे दिन पर खड़ा होता है और बहस की हालत में नहीं '
                'होता। शिकायत बाद में भी हो सकती है — महीनों बाद भी।'
            : 'This is common, and money taken can come back. Families pay '
                'because they are at the worst moment of their lives and in '
                'no state to argue. The complaint can be made later - even '
                'months later.'),
        ToolQuestion(hi ? 'इलाज किस योजना में था' : 'Which scheme the treatment was under'),
        pick(FreeScheme.pmjay, 'Ayushman Bharat / PM-JAY or a state health '
            'scheme', 'आयुष्मान भारत / PM-JAY या राज्य की स्वास्थ्य योजना'),
        pick(FreeScheme.delivery, 'A delivery or a newborn at a government '
            'hospital', 'सरकारी अस्पताल में प्रसव या नवजात का इलाज'),
        pick(FreeScheme.govtHospital,
            'Ordinary treatment at a government hospital',
            'सरकारी अस्पताल में सामान्य इलाज'),
        pick(FreeScheme.unsure, 'Not sure', 'पता नहीं'),
        if (_scheme != null) ...[
          const SizedBox(height: 6),
          if (_scheme == FreeScheme.pmjay)
            ToolAnswer(
              headline: hi
                  ? 'एक रुपया भी नहीं लगना था'
                  : 'Not one rupee should have been paid',
              detail: hi
                  ? 'PM-JAY कैशलेस है। पैकेज में भर्ती, दवाएँ, जाँच, सामान, भर्ती से '
                      '3 दिन पहले और छुट्टी के 15 दिन बाद तक — सब शामिल है। "दवा बाहर '
                      'से ले आओ", "जाँच बाहर करा लो", "बेड का चार्ज अलग है" — इनमें से '
                      'कोई भी जायज़ नहीं है।'
                  : 'PM-JAY is cashless. The package covers the admission, '
                      'medicines, tests, consumables, three days before '
                      'admission and fifteen days after discharge. "Buy the '
                      'medicine outside", "get the test done outside", "the '
                      'bed charge is separate" - none of these is legitimate.',
              tone: ToolTone.bad,
              icon: Icons.gavel_outlined,
            )
          else if (_scheme == FreeScheme.delivery)
            ToolAnswer(
              headline: hi
                  ? 'प्रसव में सब कुछ मुफ़्त है, सिज़ेरियन भी'
                  : 'Everything about a delivery is free, caesarean included',
              detail: hi
                  ? 'जननी शिशु सुरक्षा कार्यक्रम के तहत सरकारी अस्पताल में प्रसव, '
                      'सिज़ेरियन, दवाएँ, जाँच, ख़ून, खाना और घर से अस्पताल और वापस की '
                      'गाड़ी — सब मुफ़्त है। नवजात बच्चे का इलाज भी, एक साल तक।'
                  : 'Under the Janani Shishu Suraksha Karyakram a delivery at '
                      'a government hospital is free - caesarean, medicines, '
                      'tests, blood, food, and the transport from home to '
                      'hospital and back. So is the newborn\'s treatment, for '
                      'the first year.',
              tone: ToolTone.bad,
              icon: Icons.gavel_outlined,
            )
          else
            ToolAnswer(
              headline: hi
                  ? 'सरकारी अस्पताल में जो सूची में है, वह मुफ़्त है'
                  : 'At a government hospital, what is on the list is free',
              detail: hi
                  ? 'सरकारी अस्पतालों में ज़रूरी दवाएँ और जाँच मुफ़्त देने की व्यवस्था है, '
                      'और आपातकालीन इलाज से मना नहीं किया जा सकता। सूची अस्पताल में '
                      'लगी होनी चाहिए — वही माँगें। कुछ राज्यों में थोड़ी पर्ची फ़ीस होती है; '
                      'दवा और जाँच के पैसे नहीं।'
                  : 'Government hospitals are meant to give essential '
                      'medicines and diagnostics free, and emergency '
                      'treatment cannot be refused. The list should be '
                      'displayed in the hospital - ask for it. Some states '
                      'charge a small registration slip; not for medicines '
                      'and tests.',
              tone: ToolTone.warn,
              icon: Icons.receipt_long_outlined,
            ),
          ToolQuestion(hi ? 'कितना दिया' : 'How much was paid'),
          ToolNumber(
            controller: _amount,
            label: hi ? 'रुपये' : 'Rupees',
            maxDigits: 7,
            icon: Icons.currency_rupee,
            onChanged: (_) => setState(() {}),
          ),
          if (paid != null && paid > 0)
            ToolAnswer(
              headline: hi
                  ? '₹$paid की वापसी माँगी जा सकती है'
                  : '₹$paid can be claimed back',
              detail: hi
                  ? 'शिकायत में रक़म, तारीख़, अस्पताल का नाम और किसने माँगा — ये चार '
                      'चीज़ें लिखें। रसीद न दी गई हो तो वह ख़ुद एक और शिकायत है: लिखें कि '
                      'पैसा लिया गया और रसीद नहीं दी गई।'
                  : 'Put four things in the complaint: the amount, the date, '
                      'the hospital\'s name, and who asked. If no receipt was '
                      'given, that is a second complaint in itself - say that '
                      'money was taken and no receipt was given.',
              tone: ToolTone.plain,
              icon: Icons.currency_rupee,
            ),
          const SizedBox(height: 14),
          Text(hi ? 'शिकायत इस क्रम में' : 'Complain in this order',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'अस्पताल के आयुष्मान मित्र या प्रधान चिकित्सा अधिकारी के पास लिखित '
                        'शिकायत दें, और पावती लें। कई बार पैसा यहीं लौटा दिया जाता है।',
                    '14555 पर फ़ोन करें (PM-JAY की हेल्पलाइन, 24 घंटे) और शिकायत संख्या '
                        'लिखकर रखें।',
                    'ज़िला शिकायत निवारण समिति या ज़िला कार्यान्वयन इकाई — ज़िला अस्पताल '
                        'में इसका कार्यालय होता है।',
                    'राज्य स्वास्थ्य एजेंसी, और केंद्र की योजना के लिए pgportal.gov.in पर '
                        'सीपीग्राम्स।',
                    'कुछ न बने तो ज़िला विधिक सेवा प्राधिकरण (हेल्पलाइन 15100) मुफ़्त में '
                        'नोटिस लिखवा देता है।',
                  ]
                : const [
                    'Give a written complaint to the hospital\'s Ayushman '
                        'Mitra or the chief medical officer, and take an '
                        'acknowledgement. The money is often returned right '
                        'here.',
                    'Call 14555 (the PM-JAY helpline, 24 hours) and write '
                        'down the complaint number.',
                    'The district grievance committee or district '
                        'implementation unit - it has an office in the '
                        'district hospital.',
                    'The state health agency, and for a central scheme, '
                        'CPGRAMS at pgportal.gov.in.',
                    'If none of it moves, the District Legal Services '
                        'Authority (helpline 15100) will write the notice for '
                        'you, free.',
                  ],
          ),
          const SizedBox(height: 10),
          const ToolChecklist(
            storageKey: 'charged_free_scheme_v1',
            introEn: 'Keep these together. A complaint with papers gets the '
                'money back; one without gets a form letter.',
            introHi: 'ये सब एक जगह रखें। काग़ज़ के साथ शिकायत से पैसा वापस आता है, '
                'बिना काग़ज़ वाली को छपा हुआ जवाब मिलता है।',
            items: [
              CheckItem('bill', 'Every bill and receipt, even a hand-written '
                  'slip', 'हर बिल और रसीद, हाथ से लिखी पर्ची भी'),
              CheckItem('nobill', 'If no receipt was given, write down what '
                  'was paid, when, and to whom',
                  'रसीद न मिली हो तो लिखें: कितना, कब, और किसे दिया'),
              CheckItem('discharge', 'The discharge summary and admission '
                  'papers', 'छुट्टी का सारांश और भर्ती के काग़ज़'),
              CheckItem('card', 'The Ayushman card or scheme number used',
                  'जो आयुष्मान कार्ड या योजना संख्या इस्तेमाल हुई'),
              CheckItem('outside', 'Bills for medicines or tests you were '
                  'told to get outside',
                  'जो दवा या जाँच बाहर से कराने को कहा गया, उसके बिल'),
            ],
          ),
          const SourceNote(text: 'PM-JAY, National Health Authority', url: _pmjayUrl),
        ],
      ],
    );
  }
}
