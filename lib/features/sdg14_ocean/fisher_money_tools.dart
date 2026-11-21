import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Money for fishers: insurance, the ban-season support, credit, what a
/// trip actually made, how much ice to carry, and a fish pond.
///
/// The ice figures come from the FAO's own tables for chilling fish in
/// warm climates. The pond screen gives ranges, not a single number,
/// because stocking depends on feeding and water and is the fisheries
/// officer's call.

const _nfdbUrl = 'https://nfdb.gov.in/';
const _pmmsyUrl = 'https://pmmsy.dof.gov.in/';
const _faoIceUrl = 'https://www.fao.org/4/R1263E/R1263E08.htm';
const _fisheriesUrl = 'https://dof.gov.in/';

/// PMMSY Group Accident Insurance Scheme. Premium paid entirely by the
/// Centre and State; no contribution from the fisher.
const gaisDeath = 500000;
const gaisPartial = 250000;
const gaisHospital = 25000;
const gaisMinAge = 18;
const gaisMaxAge = 70;
const gaisIntimateDays = 90;
const gaisDocumentsDays = 180;
const gaisTollFree = '1800-425-1660';

/// Kisan Credit Card for fisheries working capital.
const kccFisheriesLimit = 200000;
const kccCollateralFree = 200000;
const kccRate = 7;
const kccPromptRebate = 3;

/// PMMSY subsidy share on a project's unit cost.
const pmmsyGeneralPercent = 40;
const pmmsyPriorityPercent = 60;

String _lakh(int rupees) {
  final l = rupees / 100000;
  return l == l.roundToDouble() ? '${l.round()} lakh' : '${l.toStringAsFixed(1)} lakh';
}

String _lakhHi(int rupees) {
  final l = rupees / 100000;
  return l == l.roundToDouble() ? '${l.round()} लाख' : '${l.toStringAsFixed(1)} लाख';
}

// --- Accident insurance -----------------------------------------------

class FisherInsurancePage extends StatelessWidget {
  const FisherInsurancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 14,
      title: hi ? 'मछुआरा दुर्घटना बीमा' : 'Fisher accident insurance',
      children: [
        ToolAnswer(
          headline: hi ? 'प्रीमियम सरकार देती है' : 'The government pays the premium',
          detail: hi
              ? 'प्रधानमंत्री मत्स्य संपदा योजना का सामूहिक दुर्घटना बीमा '
                  '$gaisMinAge से $gaisMaxAge साल के मछुआरों, मछली मज़दूरों और मछली '
                  'पालकों के लिए है। प्रीमियम पूरा केंद्र और राज्य सरकार देती हैं — '
                  'मछुआरे से कुछ नहीं लिया जाता। नाम जुड़वाने के लिए मत्स्य विभाग या '
                  'मछुआरा सहकारी समिति से पूछें।'
              : 'The PM Matsya Sampada Yojana group accident insurance covers '
                  'fishers, fish workers and fish farmers aged $gaisMinAge to '
                  '$gaisMaxAge. The whole premium is paid by the central and '
                  'state governments - nothing is taken from the fisher. Ask '
                  'the fisheries department or the fishers\' cooperative to '
                  'get your name on it.',
          tone: ToolTone.good,
          icon: Icons.shield_outlined,
        ),
        const SizedBox(height: 10),
        ToolLine(hi ? 'मृत्यु या पूरी स्थायी अपंगता' : 'Death or permanent total disability',
            hi ? '₹${_lakhHi(gaisDeath)}' : '₹${_lakh(gaisDeath)}', strong: true),
        ToolLine(hi ? 'आंशिक स्थायी अपंगता' : 'Permanent partial disability',
            hi ? '₹${_lakhHi(gaisPartial)}' : '₹${_lakh(gaisPartial)}'),
        ToolLine(hi ? 'दुर्घटना में अस्पताल का ख़र्च' : 'Hospital costs after an accident',
            '₹$gaisHospital'),
        const SizedBox(height: 14),
        Text(hi ? 'परिवार दावा कैसे करे' : 'How a family claims',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'दुर्घटना के $gaisIntimateDays दिन के भीतर सूचना दें — ज़िले के मत्स्य '
                      'अधिकारी को, या एनएफ़डीबी के टोल-फ़्री नंबर $gaisTollFree पर।',
                  'काग़ज़ दुर्घटना के $gaisDocumentsDays दिन के भीतर जमा करें।',
                  'मृत्यु में: एफ़आईआर या पुलिस रिपोर्ट, पोस्टमार्टम रिपोर्ट, पंचनामा, '
                      'मृत्यु प्रमाण पत्र। डूबने पर दो गवाहों के बयान भी। इनकी प्रमाणित '
                      'नक़ल दें, असली अपने पास रखें।',
                  'साथ में: बैंक का रद्द चेक या पासबुक का पहला पन्ना, पहचान और पते का '
                      'प्रमाण, और मत्स्य अधिकारी का प्रमाणन।',
                  'पूरे काग़ज़ मिलने के बाद बीमा कंपनी का लक्ष्य 15 कार्य-दिवस में भुगतान '
                      'का है।',
                ]
              : const [
                  'Give notice within $gaisIntimateDays days of the accident - '
                      'to the district fisheries officer, or on NFDB\'s '
                      'toll-free number $gaisTollFree.',
                  'Submit the documents within $gaisDocumentsDays days of the '
                      'accident.',
                  'For a death: the FIR or police report, the post-mortem '
                      'report, the panchnama, the death certificate. For a '
                      'drowning, two witness statements as well. Give certified '
                      'copies and keep the originals.',
                  'With them: a cancelled cheque or the first page of the '
                      'passbook, proof of identity and address, and the '
                      'fisheries officer\'s certification.',
                  'Once the papers are complete the insurer aims to pay within '
                      '15 working days.',
                ],
        ),
        const SizedBox(height: 12),
        ToolAnswer(
          headline: hi ? 'समुद्र में लापता हो तो' : 'If someone is missing at sea',
          detail: hi
              ? 'शव न मिलने पर भी दावा बनता है, पर इंतज़ार लंबा है। डूबने का पक्का '
                  'पता हो और शव न मिले तो छह महीने बाद, परिवार की घोषणा और मत्स्य '
                  'अधिकारी के प्रमाणन से। समुद्र में लापता होने पर दो साल बाद, अंतिम '
                  'जाँच रिपोर्ट के आधार पर — और नामित व्यक्ति को यह बंधपत्र देना होता '
                  'है कि व्यक्ति ज़िंदा मिला तो रक़म लौटाई जाएगी। सूचना तब भी '
                  '$gaisIntimateDays दिन में ही देनी है, देर न करें।'
              : 'A claim still stands when no body is found, but the wait is '
                  'long. Where drowning is certain and the body is not found, '
                  'after six months, on the family\'s declaration and the '
                  'fisheries officer\'s certificate. Missing at sea, after two '
                  'years, on the final investigation report - and the nominee '
                  'signs a bond to repay if the person is found alive. Notice '
                  'must still be given within $gaisIntimateDays days, so do not '
                  'delay it.',
          tone: ToolTone.plain,
          icon: Icons.search,
        ),
        const SourceNote(
            text: 'National Fisheries Development Board - GAIS', url: _nfdbUrl),
      ],
    );
  }
}

// --- Support during the ban -------------------------------------------

class BanSupportPage extends StatelessWidget {
  const BanSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 14,
      title: hi ? 'रोक के दौरान सहायता राशि' : 'Support money during the ban',
      children: [
        ToolNote(hi
            ? 'मछली पकड़ने पर रोक के महीनों में आर्थिक रूप से कमज़ोर सक्रिय पारंपरिक '
                'मछुआरा परिवारों को गुज़ारे और पोषण के लिए सहायता मिलती है — '
                'प्रधानमंत्री मत्स्य संपदा योजना में केंद्र और राज्य मिलकर, और कई '
                'राज्य इसके ऊपर अपनी राशि भी देते हैं। राशि राज्य-राज्य में अलग है, '
                'इसलिए यह ऐप कोई रक़म नहीं बताता।'
            : 'In the ban months, economically weak, active traditional fisher '
                'families get support for livelihood and nutrition - under PM '
                'Matsya Sampada Yojana, shared by the Centre and the state, and '
                'many states add their own amount on top. The amount differs '
                'from state to state, so this app names none.'),
        const SizedBox(height: 12),
        Text(hi ? 'सूची में नाम कैसे आता है' : 'How a name gets on the list',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'सूची रोक शुरू होने से पहले बनती है — इसलिए आवेदन पहले करें, रोक '
                      'लगने के बाद नहीं।',
                  'मत्स्य विभाग में या मछुआरा सहकारी समिति के ज़रिये पंजीकरण। कई राज्यों '
                      'में पहले से पंजीकृत, सक्रिय मछुआरे ही पात्र होते हैं।',
                  'चाहिए: मछुआरा पहचान पत्र (बायोमीट्रिक कार्ड), आधार, बैंक खाता जो '
                      'आधार से जुड़ा हो, और समिति की सदस्यता हो तो उसका प्रमाण।',
                  'राशि सीधे बैंक खाते में आती है। न आए तो मत्स्य विभाग में लिखित '
                      'शिकायत दें, और सूचना का अधिकार से लाभार्थी सूची माँगी जा सकती है।',
                ]
              : const [
                  'The list is made before the ban starts - so apply early, not '
                      'after the ban is on.',
                  'Registration at the fisheries department or through the '
                      'fishers\' cooperative. In many states only fishers '
                      'already registered and active qualify.',
                  'You need the fisher ID (biometric card), Aadhaar, a bank '
                      'account linked to Aadhaar, and proof of cooperative '
                      'membership if you have it.',
                  'Money comes straight to the bank account. If it does not, '
                      'complain in writing at the fisheries department; the '
                      'beneficiary list can be asked for under the Right to '
                      'Information.',
                ],
        ),
        const SizedBox(height: 10),
        ToolNote(hi
            ? 'रोक की तारीख़ें और बचे दिन इसी लक्ष्य में "मछली पकड़ने पर रोक" वाली '
                'स्क्रीन पर हैं।'
            : 'The ban dates and the days left are on "Is the fishing ban on '
                'today" in this goal.'),
        const SourceNote(text: 'PM Matsya Sampada Yojana', url: _pmmsyUrl),
      ],
    );
  }
}

// --- KCC for fishers --------------------------------------------------

class FisherKccPage extends StatefulWidget {
  const FisherKccPage({super.key});

  @override
  State<FisherKccPage> createState() => _FisherKccPageState();
}

class _FisherKccPageState extends State<FisherKccPage> {
  bool? _ownsOrLeases;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    const effective = kccRate - kccPromptRebate;

    return ToolScaffold(
      goal: 14,
      title: hi ? 'मछुआरों के लिए किसान क्रेडिट कार्ड' : 'Kisan Credit Card for fishers',
      children: [
        ToolQuestion(hi
            ? 'क्या आपके पास अपनी या पट्टे की नाव, जाल, तालाब या जलाशय है'
            : 'Do you own or lease a boat, nets, a pond or a water body'),
        SelectionTile(
          label: hi ? 'हाँ' : 'Yes',
          selected: _ownsOrLeases == true,
          onTap: () => setState(() => _ownsOrLeases = true),
        ),
        SelectionTile(
          label: hi ? 'नहीं, मैं नाव पर मज़दूरी करता/करती हूँ' : 'No, I work as crew',
          selected: _ownsOrLeases == false,
          onTap: () => setState(() => _ownsOrLeases = false),
        ),
        if (_ownsOrLeases == true) ...[
          ToolAnswer(
            headline: hi
                ? '₹${_lakhHi(kccFisheriesLimit)} तक, असल में $effective% ब्याज पर'
                : 'Up to ₹${_lakh(kccFisheriesLimit)}, at an effective $effective%',
            detail: hi
                ? 'किसान क्रेडिट कार्ड मछली पकड़ने और मछली पालन के रोज़ के ख़र्च — '
                    'ईंधन, बर्फ़, जाल की मरम्मत, बीज, चारा — के लिए है। ब्याज $kccRate% '
                    'है, और समय पर चुकाने पर $kccPromptRebate% की छूट मिलती है, यानी '
                    '$effective%। ₹${_lakhHi(kccCollateralFree)} तक कोई गिरवी नहीं '
                    'लगती। फ़सल का केसीसी पहले से हो तो ब्याज छूट की कुल सीमा दोनों '
                    'पर मिलाकर लगती है — बैंक से इस साल की सीमा पूछें।'
                : 'The Kisan Credit Card covers the running costs of fishing and '
                    'fish farming - fuel, ice, net repairs, seed, feed. Interest '
                    'is $kccRate%, with $kccPromptRebate% off for repaying on '
                    'time, so $effective%. No collateral up to '
                    '₹${_lakh(kccCollateralFree)}. If you already hold a crop '
                    'KCC, the interest-relief ceiling applies to both together '
                    '- ask the bank for this year\'s ceiling.',
            tone: ToolTone.good,
            icon: Icons.credit_card_outlined,
          ),
          const SizedBox(height: 10),
          Text(hi ? 'बैंक ले जाने के काग़ज़' : 'Papers to carry to the bank',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            numbered: false,
            steps: hi
                ? const [
                    'आधार और पैन (या फ़ॉर्म 60)',
                    'नाव का पंजीकरण और मछली पकड़ने का लाइसेंस, या तालाब का पट्टा या '
                        'मालिकाना काग़ज़',
                    'मछुआरा पहचान पत्र, और सहकारी समिति की सदस्यता हो तो उसका प्रमाण',
                    'पासपोर्ट आकार की फ़ोटो',
                    'एक पन्ने का हिसाब: महीने का ख़र्च कितना, कमाई कितनी — इसी लक्ष्य '
                        'में "हर यात्रा का मुनाफ़ा" से बनाया जा सकता है',
                  ]
                : const [
                    'Aadhaar and PAN (or Form 60)',
                    'The boat registration and fishing licence, or the lease or '
                        'ownership papers of the pond',
                    'The fisher ID card, and proof of cooperative membership if '
                        'you have it',
                    'A passport-size photo',
                    'A one-page account: what a month costs and earns - "Catch '
                        'log" in this goal can produce it',
                  ],
          ),
        ],
        if (_ownsOrLeases == false)
          ToolAnswer(
            headline: hi ? 'समूह में रास्ता खुलता है' : 'A group opens the door',
            detail: hi
                ? 'केसीसी आम तौर पर उसे मिलता है जिसके पास नाव, जाल या तालाब हो। नाव '
                    'पर मज़दूरी करने वालों के लिए दो रास्ते हैं: कुछ साथी मिलकर संयुक्त '
                    'देनदारी समूह या स्वयं सहायता समूह बनाएँ, जिसे बैंक समूह के रूप में '
                    'ऋण देता है; या मछुआरा सहकारी समिति के ज़रिये। साथ ही दुर्घटना बीमा '
                    'में नाम ज़रूर जुड़वाएँ — वह मज़दूरों के लिए भी है।'
                : 'A KCC usually goes to whoever owns or leases a boat, nets or a '
                    'pond. For crew there are two routes: a few of you form a '
                    'joint liability group or a self-help group, which a bank '
                    'lends to as a group; or through the fishers\' cooperative. '
                    'Get your name on the accident insurance as well - it '
                    'covers fish workers too.',
            tone: ToolTone.plain,
            icon: Icons.groups_outlined,
          ),
        if (_ownsOrLeases != null)
          const SourceNote(text: 'Department of Fisheries', url: _fisheriesUrl),
      ],
    );
  }
}

// --- Catch log --------------------------------------------------------

class Trip {
  final String date;
  final double sale;
  final double costs;
  final double net;
  const Trip(this.date, this.sale, this.costs, this.net);

  Map<String, dynamic> toJson() => {'d': date, 's': sale, 'c': costs, 'n': net};

  static Trip? fromJson(Object? raw) {
    if (raw is! Map || raw['d'] is! String) return null;
    double n(Object? v) => v is num ? v.toDouble() : 0;
    return Trip(raw['d'] as String, n(raw['s']), n(raw['c']), n(raw['n']));
  }
}

class CatchLogPage extends StatefulWidget {
  const CatchLogPage({super.key});

  @override
  State<CatchLogPage> createState() => _CatchLogPageState();
}

class _CatchLogPageState extends State<CatchLogPage> {
  static const _key = 'catch_log_v1';
  static const _maxTrips = 100;

  final _kg = TextEditingController();
  final _price = TextEditingController();
  final _fuelL = TextEditingController();
  final _fuelRate = TextEditingController();
  final _ice = TextEditingController(text: '0');
  final _other = TextEditingController(text: '0');
  final _crewShare = TextEditingController(text: '0');
  List<Trip> _trips = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_kg, _price, _fuelL, _fuelRate, _ice, _other, _crewShare]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final list = jsonDecode(raw);
        if (list is List) {
          _trips = list.map(Trip.fromJson).whereType<Trip>().toList();
        }
      }
    } catch (_) {
      _trips = const [];
    }
    if (mounted) setState(() {});
  }

  Future<void> _save(List<Trip> next) async {
    setState(() => _trips = next);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode(next.map((e) => e.toJson()).toList()));
    } catch (_) {
      // Stays in memory for this session.
    }
  }

  double _v(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final sale = _v(_kg) * _v(_price);
    final fuel = _v(_fuelL) * _v(_fuelRate);
    final costs = fuel + _v(_ice) + _v(_other);
    final afterCosts = sale - costs;
    final crew = afterCosts > 0 ? afterCosts * _v(_crewShare) / 100 : 0.0;
    final net = afterCosts - crew;
    final avg = _trips.isEmpty
        ? 0.0
        : _trips.fold<double>(0, (a, t) => a + t.net) / _trips.length;

    return ToolScaffold(
      goal: 14,
      title: hi ? 'हर यात्रा का मुनाफ़ा' : 'Catch log: profit per trip',
      children: [
        ToolNote(hi
            ? 'बड़ी पकड़ वाला दिन भी घाटे का हो सकता है, अगर ईंधन ज़्यादा लगा। यह '
                'हिसाब बताता है कि यात्रा से असल में क्या बचा। सहेजी गई यात्राएँ सिर्फ़ '
                'इस फ़ोन में रहती हैं, और बैंक में ऋण के समय काम आती हैं।'
            : 'A day with a big catch can still be a loss if the fuel ran high. '
                'This works out what a trip actually left. Saved trips stay on '
                'this phone only, and are useful at the bank when asking for a '
                'loan.'),
        ToolQuestion(hi ? 'बिक्री' : 'The sale'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _kg,
                label: hi ? 'पकड़ (किलो)' : 'Catch (kg)',
                decimal: true,
                maxDigits: 6,
                icon: Icons.set_meal_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _price,
                label: hi ? 'औसत दाम प्रति किलो (₹)' : 'Average price a kg (₹)',
                decimal: true,
                maxDigits: 5,
                icon: Icons.currency_rupee,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        ToolQuestion(hi ? 'ख़र्च' : 'Costs'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _fuelL,
                label: hi ? 'ईंधन (लीटर)' : 'Fuel (litres)',
                decimal: true,
                maxDigits: 5,
                icon: Icons.local_gas_station_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _fuelRate,
                label: hi ? 'प्रति लीटर (₹)' : 'Per litre (₹)',
                decimal: true,
                maxDigits: 5,
                icon: Icons.currency_rupee,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _ice,
                label: hi ? 'बर्फ़ (₹)' : 'Ice (₹)',
                decimal: true,
                maxDigits: 6,
                icon: Icons.ac_unit,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _other,
                label: hi ? 'खाना, चारा, अन्य (₹)' : 'Food, bait, other (₹)',
                decimal: true,
                maxDigits: 6,
                icon: Icons.more_horiz,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ToolNumber(
          controller: _crewShare,
          label: hi
              ? 'ख़र्च के बाद साथियों का हिस्सा (%)'
              : 'Crew share after costs (%)',
          decimal: true,
          maxDigits: 3,
          icon: Icons.groups_outlined,
          onChanged: (_) => setState(() {}),
        ),
        if (sale > 0) ...[
          const SizedBox(height: 10),
          ToolLine(hi ? 'बिक्री' : 'Sale', '₹${sale.round()}'),
          ToolLine(hi ? 'ख़र्च' : 'Costs', '₹${costs.round()}'),
          if (crew > 0)
            ToolLine(hi ? 'साथियों का हिस्सा' : 'Crew share', '₹${crew.round()}'),
          ToolLine(hi ? 'नाव के मालिक को बचा' : 'Left for the boat owner',
              '₹${net.round()}', strong: true),
          if (sale > 0 && fuel > 0)
            ToolLine(hi ? 'ईंधन बिक्री का कितना' : 'Fuel as a share of the sale',
                '${(fuel / sale * 100).round()}%'),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              final n = DateTime.now();
              final next = [
                Trip('${n.day}/${n.month}/${n.year}', sale, costs, net),
                ..._trips,
              ].take(_maxTrips).toList();
              _save(next);
            },
            icon: const Icon(Icons.save_outlined),
            label: Text(hi ? 'यह यात्रा सहेजें' : 'Save this trip'),
          ),
        ],
        if (_trips.isNotEmpty) ...[
          const SizedBox(height: 14),
          ToolAnswer(
            headline: hi
                ? '${_trips.length} यात्राएँ, औसत ₹${avg.round()} प्रति यात्रा'
                : '${_trips.length} trips, averaging ₹${avg.round()} each',
            detail: hi
                ? 'घाटे वाली यात्राएँ: ${_trips.where((t) => t.net < 0).length}। '
                    'ईंधन का हिस्सा बढ़ता दिखे तो इंजन की जाँच और रास्ता — दोनों देखें।'
                : 'Trips at a loss: ${_trips.where((t) => t.net < 0).length}. If '
                    'the fuel share keeps rising, look at both the engine and the '
                    'route.',
            tone: avg >= 0 ? ToolTone.good : ToolTone.warn,
            icon: Icons.bar_chart_outlined,
          ),
          for (final t in _trips.take(15))
            ToolLine(t.date,
                t.net >= 0 ? '+₹${t.net.round()}' : '-₹${(-t.net).round()}'),
          TextButton(
            onPressed: () async {
              final yes = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(hi ? 'सारी यात्राएँ मिटाएँ?' : 'Clear all trips?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(hi ? 'नहीं' : 'No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(hi ? 'मिटाएँ' : 'Clear'),
                    ),
                  ],
                ),
              );
              if (yes == true) await _save(const []);
            },
            child: Text(hi ? 'सब मिटाएँ' : 'Clear all'),
          ),
        ],
      ],
    );
  }
}

// --- Ice needed -------------------------------------------------------

enum IceBox { open, covered, insulated }

class IceNeededPage extends StatefulWidget {
  const IceNeededPage({super.key});

  @override
  State<IceNeededPage> createState() => _IceNeededPageState();
}

class _IceNeededPageState extends State<IceNeededPage> {
  final _kg = TextEditingController();
  final _hours = TextEditingController();
  final _temp = TextEditingController(text: '30');
  IceBox _box = IceBox.open;

  @override
  void dispose() {
    _kg.dispose();
    _hours.dispose();
    _temp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final kg = double.tryParse(_kg.text.trim()) ?? 0;
    final hours = double.tryParse(_hours.text.trim()) ?? 0;
    final temp = (double.tryParse(_temp.text.trim()) ?? 30.0).clamp(0.0, 45.0);

    // FAO: about 0.34 kg of ice chills 1 kg of fish from 30 degrees to 0,
    // which is 0.0113 kg per kg per degree.
    final chill = kg * 0.0113 * temp;
    // FAO: a single 50 kg box loses about 3 kg of ice an hour at 30 degrees,
    // a box inside a stack about 1 kg - roughly 0.1 and 0.035 per degree.
    final perBoxPerHour = switch (_box) {
      IceBox.open => 0.1 * temp,
      IceBox.covered => 0.035 * temp,
      IceBox.insulated => 0.035 * temp,
    };
    final keep = (kg / 50) * perBoxPerHour * hours;
    final worked = chill + keep;
    // FAO's working ratios for the tropics: 1 kg ice per kg fish in boxes,
    // about 1 per 3 in insulated tanks.
    final practical = _box == IceBox.insulated ? kg / 3 : kg;
    final carry = worked > practical ? worked : practical;

    return ToolScaffold(
      goal: 14,
      title: hi ? 'पकड़ के लिए कितनी बर्फ़' : 'Ice needed for my catch',
      children: [
        ToolNote(hi
            ? 'मछली पकड़ते ही ठंडी न हो तो कुछ घंटों में दाम गिरने लगता है। बर्फ़ दो '
                'काम करती है: पहले मछली को ठंडा करना, फिर उसे ठंडा रखना। यह हिसाब '
                'एफ़एओ की गर्म देशों के लिए बनी तालिकाओं से है।'
            : 'Fish not chilled as soon as it is caught starts losing price in '
                'a few hours. Ice does two jobs: first chilling the fish, then '
                'keeping it cold. This uses the FAO\'s tables for warm climates.'),
        ToolQuestion(hi ? 'ब्योरा' : 'The details'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _kg,
                label: hi ? 'अनुमानित पकड़ (किलो)' : 'Expected catch (kg)',
                decimal: true,
                maxDigits: 6,
                icon: Icons.set_meal_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _hours,
                label: hi ? 'बिकने तक घंटे' : 'Hours until sale',
                decimal: true,
                maxDigits: 4,
                icon: Icons.schedule,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ToolNumber(
          controller: _temp,
          label: hi ? 'हवा या पानी का तापमान (°C)' : 'Air or sea temperature (°C)',
          decimal: true,
          maxDigits: 3,
          icon: Icons.thermostat_outlined,
          onChanged: (_) => setState(() {}),
        ),
        ToolQuestion(hi ? 'मछली किसमें रहेगी' : 'What the fish will be kept in'),
        SelectionTile(
          label: hi ? 'खुले बक्से या टोकरी, धूप-हवा में' : 'Open boxes or baskets, in sun and wind',
          selected: _box == IceBox.open,
          onTap: () => setState(() => _box = IceBox.open),
        ),
        SelectionTile(
          label: hi ? 'ढके हुए, छाया में, एक के ऊपर एक' : 'Covered, in shade, stacked',
          selected: _box == IceBox.covered,
          onTap: () => setState(() => _box = IceBox.covered),
        ),
        SelectionTile(
          label: hi ? 'इंसुलेटेड बक्सा या टंकी' : 'An insulated box or tank',
          selected: _box == IceBox.insulated,
          onTap: () => setState(() => _box = IceBox.insulated),
        ),
        if (kg > 0) ...[
          ToolAnswer(
            headline: hi
                ? 'कम से कम ${carry.ceil()} किलो बर्फ़ ले जाएँ'
                : 'Carry at least ${carry.ceil()} kg of ice',
            detail: hi
                ? 'मछली ठंडी करने में लगभग ${chill.ceil()} किलो, और ${hours.toStringAsFixed(0)} '
                    'घंटे ठंडा रखने में लगभग ${keep.ceil()} किलो। एफ़एओ का गर्म देशों का '
                    'व्यावहारिक नियम ${_box == IceBox.insulated ? 'इंसुलेटेड टंकी में हर 3 किलो मछली पर 1 किलो' : 'बक्सों में हर किलो मछली पर 1 किलो'} '
                    'बर्फ़ है — दोनों में जो ज़्यादा हो, वही।'
                : 'About ${chill.ceil()} kg to chill the fish, and about '
                    '${keep.ceil()} kg to keep it cold for '
                    '${hours.toStringAsFixed(0)} hours. The FAO\'s working rule '
                    'for warm climates is '
                    '${_box == IceBox.insulated ? '1 kg of ice per 3 kg of fish in an insulated tank' : '1 kg of ice per kg of fish in boxes'} '
                    '- whichever is more.',
            tone: ToolTone.good,
            icon: Icons.ac_unit,
          ),
          const SizedBox(height: 10),
          ToolSteps(
            numbered: false,
            steps: hi
                ? const [
                    'बर्फ़ बारीक कुटी या चूरा हो — बड़े टुकड़े मछली को कुचलते हैं और हर '
                        'तरफ़ नहीं छूते',
                    'नीचे बर्फ़, फिर मछली, फिर बर्फ़ — परत-दर-परत; मछली एक-दूसरे को न छुए',
                    'पिघला पानी निकलता रहे; उसमें पड़ी मछली जल्दी ख़राब होती है',
                    'बक्सा धूप में न रखें, और ऊपर गीला बोरा डालें',
                  ]
                : const [
                    'Use crushed or flake ice - big lumps bruise the fish and do '
                        'not touch it all round',
                    'Ice, then fish, then ice - in layers; fish should not touch '
                        'each other',
                    'Let meltwater drain away; fish lying in it spoils faster',
                    'Keep the box out of the sun, with a wet sack over it',
                  ],
          ),
        ],
        const SourceNote(text: 'FAO - ice in fisheries', url: _faoIceUrl),
      ],
    );
  }
}

// --- Fish pond --------------------------------------------------------

class PondFarmingPage extends StatefulWidget {
  const PondFarmingPage({super.key});

  @override
  State<PondFarmingPage> createState() => _PondFarmingPageState();
}

class _PondFarmingPageState extends State<PondFarmingPage> {
  final _length = TextEditingController();
  final _width = TextEditingController();
  bool? _priority;

  @override
  void dispose() {
    _length.dispose();
    _width.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final l = double.tryParse(_length.text.trim()) ?? 0;
    final w = double.tryParse(_width.text.trim()) ?? 0;
    final sqm = l * w;
    final ha = sqm / 10000;

    return ToolScaffold(
      goal: 14,
      title: hi ? 'तालाब में मछली पालन' : 'Fish farming in a pond',
      children: [
        ToolQuestion(hi ? 'आप किस वर्ग में हैं' : 'Which category are you in'),
        SelectionTile(
          label: hi
              ? 'महिला, अनुसूचित जाति या अनुसूचित जनजाति'
              : 'Woman, Scheduled Caste or Scheduled Tribe',
          selected: _priority == true,
          onTap: () => setState(() => _priority = true),
        ),
        SelectionTile(
          label: hi ? 'सामान्य' : 'General',
          selected: _priority == false,
          onTap: () => setState(() => _priority = false),
        ),
        if (_priority != null)
          ToolAnswer(
            headline: hi
                ? 'परियोजना लागत का ${_priority! ? pmmsyPriorityPercent : pmmsyGeneralPercent}% सब्सिडी'
                : '${_priority! ? pmmsyPriorityPercent : pmmsyGeneralPercent}% subsidy on the project cost',
            detail: hi
                ? 'प्रधानमंत्री मत्स्य संपदा योजना में नए तालाब बनाने, बीज और चारे '
                    'जैसे पहले साल के ख़र्च पर सरकारी सहायता है — तय इकाई लागत तक। '
                    'आवेदन ज़िले के मत्स्य विभाग में, ज़मीन के काग़ज़, आधार, बैंक खाते '
                    'और परियोजना के ब्योरे के साथ। इकाई लागत और ज़िले का लक्ष्य हर साल '
                    'तय होता है — विभाग से पूछें।'
                : 'PM Matsya Sampada Yojana helps with building a new pond and '
                    'first-year costs such as seed and feed - up to a fixed unit '
                    'cost. Apply at the district fisheries department with the '
                    'land papers, Aadhaar, bank account and project details. The '
                    'unit cost and the district\'s target are set each year - '
                    'ask the department.',
            tone: ToolTone.good,
            icon: Icons.water_outlined,
          ),
        ToolQuestion(hi ? 'तालाब का आकार' : 'The pond size'),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _length,
                label: hi ? 'लंबाई (मीटर)' : 'Length (m)',
                decimal: true,
                maxDigits: 5,
                icon: Icons.straighten,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _width,
                label: hi ? 'चौड़ाई (मीटर)' : 'Width (m)',
                decimal: true,
                maxDigits: 5,
                icon: Icons.straighten,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        if (sqm > 0) ...[
          const SizedBox(height: 10),
          ToolLine(hi ? 'पानी का क्षेत्रफल' : 'Water area',
              hi
                  ? '${sqm.round()} वर्ग मीटर (${ha.toStringAsFixed(2)} हेक्टेयर)'
                  : '${sqm.round()} sq m (${ha.toStringAsFixed(2)} ha)',
              strong: true),
          ToolLine(hi ? 'देसी कार्प के बच्चे (फ़िंगरलिंग)' : 'Carp fingerlings',
              hi
                  ? '${(ha * 5000).round()} से ${(ha * 8000).round()}'
                  : '${(ha * 5000).round()} to ${(ha * 8000).round()}'),
          ToolLine(hi ? 'चूना, तैयारी में' : 'Lime, at preparation',
              hi
                  ? '${(ha * 250).round()} से ${(ha * 500).round()} किलो'
                  : '${(ha * 250).round()} to ${(ha * 500).round()} kg'),
          ToolLine(hi ? 'पानी की गहराई' : 'Water depth',
              hi ? '1.5 से 2 मीटर' : '1.5 to 2 m'),
          const SizedBox(height: 8),
          ToolNote(hi
              ? 'ये आम तौर पर दी जाने वाली सीमाएँ हैं — रोहू, कतला, मृगल जैसी देसी कार्प '
                  'के मिले-जुले पालन के लिए, चारा देते हुए। सही संख्या पानी, मिट्टी की '
                  'जाँच और चारे पर निर्भर है; चूने की मात्रा मिट्टी के पीएच से तय होती '
                  'है। मत्स्य विभाग या कृषि विज्ञान केंद्र से मिट्टी-पानी की जाँच '
                  'करवाकर पक्का करें। ज़रूरत से ज़्यादा मछली डालना सबसे आम भूल है — '
                  'ऑक्सीजन कम होने से एक रात में पूरा तालाब मर सकता है।'
              : 'These are commonly advised ranges - for mixed farming of Indian '
                  'carps such as rohu, catla and mrigal, with feeding. The right '
                  'number depends on the water, a soil test and the feed; the '
                  'lime dose depends on soil pH. Confirm with a soil and water '
                  'test at the fisheries department or the Krishi Vigyan Kendra. '
                  'Overstocking is the commonest mistake - when oxygen runs low '
                  'a whole pond can die in one night.'),
        ],
        const SourceNote(text: 'PM Matsya Sampada Yojana', url: _pmmsyUrl),
      ],
    );
  }
}
