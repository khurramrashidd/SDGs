import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Rooftop solar, solar pumps, and the gas connection.
///
/// The LPG subsidy screen carries no per-cylinder figure. The amount and
/// the number of subsidised refills are set by government order and have
/// been changed more than once, and the sources that quote them disagree
/// with each other - which is exactly the situation where a number in an
/// app does harm. So that screen teaches the household to read its own
/// subsidy credit instead, which is always current and always theirs.

const _suryaGharUrl = 'https://pmsuryaghar.gov.in/';
const _suryaGharCfaUrl =
    'https://jbvnl.co.in/SOLAR/CFA_structure%20for%20PM%20Suryaghar.pdf';
const _kusumUrl = 'https://pmkusum.mnre.gov.in/';
const _pmuyUrl = 'https://wb.gov.in/government-schemes-details-pradhan-mantri-ujjwala-yojana.aspx';
const _lpgUrl = 'https://mopng.gov.in/';

/// PM Surya Ghar central financial assistance, as published.
const solarPerKwFirstTwo = 30000;
const solarPerKwThird = 18000;
const solarMaxSubsidy = 78000;

/// Subsidy for a system of [kw] kilowatts: ₹30,000 a kW for the first two,
/// ₹18,000 for the third, and nothing above that.
int rooftopSubsidy(double kw) {
  final first = kw.clamp(0, 2) * solarPerKwFirstTwo;
  final third = (kw - 2).clamp(0, 1) * solarPerKwThird;
  final total = (first + third).round();
  return total > solarMaxSubsidy ? solarMaxSubsidy : total;
}

/// The size the scheme's own table suggests for a monthly consumption.
String suggestedSize(double units, bool hi) {
  if (units <= 150) return hi ? '1 से 2 kW' : '1 to 2 kW';
  if (units <= 300) return hi ? '2 से 3 kW' : '2 to 3 kW';
  return hi ? '3 kW से ऊपर' : 'Above 3 kW';
}

class RooftopSolarPage extends StatefulWidget {
  const RooftopSolarPage({super.key});

  @override
  State<RooftopSolarPage> createState() => _RooftopSolarPageState();
}

class _RooftopSolarPageState extends State<RooftopSolarPage> {
  final _units = TextEditingController();
  final _kw = TextEditingController(text: '3');
  bool _ownsRoof = true;

  @override
  void dispose() {
    _units.dispose();
    _kw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final units = double.tryParse(_units.text.trim());
    final kw = double.tryParse(_kw.text.trim()) ?? 0;
    final subsidy = kw > 0 ? rooftopSubsidy(kw) : null;

    return ToolScaffold(
      goal: 7,
      title: hi ? 'छत पर सौर ऊर्जा की सब्सिडी' : 'The rooftop solar subsidy',
      children: [
        ToolNote(hi
            ? 'पीएम सूर्य घर योजना में घर की छत पर सौर संयंत्र लगवाने पर केंद्र सरकार '
                'सीधे सब्सिडी देती है — पहले दो किलोवाट पर ₹$solarPerKwFirstTwo प्रति '
                'किलोवाट, तीसरे पर ₹$solarPerKwThird, और कुल मिलाकर ज़्यादा से ज़्यादा '
                '₹$solarMaxSubsidy। पैसा सीधे आपके बैंक खाते में आता है।'
            : 'Under the PM Surya Ghar scheme the central government pays a '
                'subsidy directly for a rooftop solar system - '
                '₹$solarPerKwFirstTwo a kilowatt for the first two, '
                '₹$solarPerKwThird for the third, capped at '
                '₹$solarMaxSubsidy in all. The money comes straight to your '
                'bank account.'),
        SwitchListTile(
          value: _ownsRoof,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'छत अपनी है और बिजली कनेक्शन घर के नाम है'
              : 'The roof is ours and the connection is in the household\'s name'),
          onChanged: (v) => setState(() => _ownsRoof = v),
        ),
        if (!_ownsRoof)
          ToolAnswer(
            headline: hi
                ? 'यह दोनों शर्तें ज़रूरी हैं'
                : 'Both of those are required',
            detail: hi
                ? 'सब्सिडी घरेलू उपभोक्ता को मिलती है, और संयंत्र उसी छत पर लगता है '
                    'जिस पर अधिकार हो। किराये के मकान में मकान मालिक की लिखित सहमति '
                    'से हो सकता है, लेकिन बिजली कनेक्शन और बैंक खाता जिसके नाम हैं, '
                    'सब्सिडी उसी को जाएगी — इसलिए पहले यह तय कर लें।'
                : 'The subsidy goes to a domestic consumer, and the system '
                    'goes on a roof you have rights over. In a rented house '
                    'it can be done with the owner\'s written consent, but '
                    'the subsidy follows whoever holds the electricity '
                    'connection and the bank account - so settle that first.',
            tone: ToolTone.warn,
            icon: Icons.info_outline,
          ),
        ToolQuestion(hi ? 'महीने की खपत' : 'Monthly consumption'),
        ToolNumber(
          controller: _units,
          label: hi ? 'यूनिट प्रति माह' : 'Units a month',
          decimal: true,
          maxDigits: 6,
          icon: Icons.bolt_outlined,
          onChanged: (_) => setState(() {}),
        ),
        if (units != null && units > 0)
          ToolAnswer(
            headline: hi
                ? 'सुझाया गया आकार: ${suggestedSize(units, true)}'
                : 'Suggested size: ${suggestedSize(units, false)}',
            detail: hi
                ? 'यह योजना की अपनी तालिका से है। ज़रूरत से बहुत बड़ा संयंत्र लगवाने '
                    'का फ़ायदा नहीं — सब्सिडी 3 किलोवाट पर रुक जाती है, और उससे ऊपर '
                    'का पूरा ख़र्च आपका होता है।'
                : 'That is from the scheme\'s own table. There is little '
                    'point going far above what you use - the subsidy stops '
                    'at 3 kW, and everything above that is paid in full by '
                    'you.',
            tone: ToolTone.plain,
            icon: Icons.solar_power_outlined,
          ),
        ToolQuestion(hi ? 'कितने किलोवाट लगवाना है' : 'What size are you considering'),
        ToolNumber(
          controller: _kw,
          label: hi ? 'किलोवाट' : 'Kilowatts',
          decimal: true,
          maxDigits: 4,
          icon: Icons.solar_power_outlined,
          onChanged: (_) => setState(() {}),
        ),
        if (subsidy != null && subsidy > 0) ...[
          ToolAnswer(
            headline: hi ? 'सब्सिडी ₹$subsidy' : 'Subsidy of ₹$subsidy',
            detail: hi
                ? '$kw किलोवाट पर। यह केंद्र की सब्सिडी है; कुछ राज्य इसके ऊपर अपनी '
                    'सब्सिडी भी देते हैं, इसलिए अपने राज्य की बिजली कंपनी से यह ज़रूर '
                    'पूछें। बाक़ी रक़म आपकी, और उसके लिए बैंक से कम ब्याज का ऋण भी '
                    'मिलता है।'
                : 'for $kw kW. This is the central subsidy; some states add '
                    'their own on top, so ask your state electricity company '
                    'about that. The rest is yours to pay, and a '
                    'low-interest bank loan is available for it.',
            tone: ToolTone.good,
            icon: Icons.savings_outlined,
          ),
          const SizedBox(height: 10),
          ToolLine(hi ? 'पहले 2 किलोवाट' : 'First 2 kW',
              '₹${(kw.clamp(0, 2) * solarPerKwFirstTwo).round()}'),
          if (kw > 2)
            ToolLine(hi ? 'तीसरा किलोवाट' : 'Third kW',
                '₹${((kw - 2).clamp(0, 1) * solarPerKwThird).round()}'),
          if (kw > 3)
            ToolLine(
                hi ? '3 किलोवाट से ऊपर' : 'Above 3 kW',
                hi ? 'कोई सब्सिडी नहीं' : 'No subsidy'),
          ToolLine(hi ? 'कुल सब्सिडी' : 'Total subsidy', '₹$subsidy',
              strong: true),
          const SizedBox(height: 14),
          Text(hi ? 'क़दम' : 'The steps',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'राष्ट्रीय पोर्टल pmsuryaghar.gov.in पर पंजीकरण करें — बिजली '
                        'कंपनी, उपभोक्ता नंबर, मोबाइल और ईमेल से।',
                    'पोर्टल पर ही पंजीकृत विक्रेताओं की सूची मिलती है। सूची से बाहर '
                        'के विक्रेता से लगवाने पर सब्सिडी नहीं मिलती — यह सबसे आम और '
                        'सबसे महँगी ग़लती है।',
                    'बिजली कंपनी से तकनीकी मंज़ूरी के बाद संयंत्र लगता है।',
                    'लगने के बाद नेट मीटर लगता है और कंपनी निरीक्षण करती है।',
                    'निरीक्षण की रिपोर्ट पोर्टल पर चढ़ने के बाद बैंक खाते की जानकारी '
                        'दें — सब्सिडी कुछ हफ़्तों में सीधे खाते में आती है।',
                  ]
                : const [
                    'Register on the national portal pmsuryaghar.gov.in with '
                        'your electricity company, consumer number, mobile '
                        'and email.',
                    'The portal itself lists the registered vendors. A system '
                        'installed by anyone off that list gets no subsidy - '
                        'the commonest and most expensive mistake there is.',
                    'The system goes up after technical approval from the '
                        'electricity company.',
                    'After installation a net meter is fitted and the company '
                        'inspects.',
                    'Once the inspection report is on the portal, give your '
                        'bank details - the subsidy reaches the account '
                        'within a few weeks.',
                  ],
          ),
          ToolDonts(
            heading: hi ? 'यहाँ सावधानी' : 'Where to be careful',
            items: hi
                ? const [
                    'पोर्टल पर पंजीकृत विक्रेता से ही लगवाएँ — बाहर वाले से लगवाने पर '
                        'सब्सिडी नहीं मिलती और बाद में कुछ नहीं हो सकता',
                    'सब्सिडी आपके खाते में आती है। जो विक्रेता कहे कि "सब्सिडी मेरे '
                        'पास आएगी, आप कम पैसा दीजिए" — उससे लिखित में लें',
                    'पंजीकरण के पैसे कोई नहीं ले सकता; पोर्टल पर यह मुफ़्त है',
                    'वारंटी काग़ज़ पर लिखवाएँ — पैनल, इन्वर्टर और लगाने का काम, तीनों '
                        'की अलग-अलग',
                    'नेट मीटर लगे बिना बची हुई बिजली का हिसाब नहीं मिलता',
                  ]
                : const [
                    'Use only a vendor registered on the portal - a system '
                        'installed by anyone else gets no subsidy, and '
                        'nothing can be done about it afterwards',
                    'The subsidy comes to your account. Any vendor saying '
                        '"the subsidy will come to me, you pay less" should '
                        'put that in writing',
                    'Nobody may charge for registering; it is free on the '
                        'portal',
                    'Get the warranty in writing - separately for the '
                        'panels, the inverter and the installation',
                    'Without a net meter you get no credit for the '
                        'electricity you send back',
                  ],
          ),
          const SourceNote(text: 'PM Surya Ghar portal', url: _suryaGharUrl),
          const SourceNote(
              text: 'Central financial assistance structure',
              url: _suryaGharCfaUrl),
        ],
      ],
    );
  }
}

// --- Solar pump -------------------------------------------------------

class KusumPage extends StatelessWidget {
  const KusumPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 7,
      title: hi ? 'खेती के लिए सोलर पंप (PM-KUSUM)' : 'A solar pump for farming (PM-KUSUM)',
      children: [
        ToolNote(hi
            ? 'पीएम-कुसुम में किसान को सोलर पंप पर सब्सिडी मिलती है। केंद्र की ओर से '
                'आमतौर पर 30% (पहाड़ी और पूर्वोत्तर राज्यों में ज़्यादा), राज्य अपनी ओर '
                'से जोड़ता है, और बाक़ी किसान का हिस्सा होता है। राज्य का हिस्सा बहुत '
                'अलग-अलग है — कुछ राज्यों में किसान को बहुत कम देना पड़ता है। इसलिए '
                'यहाँ कुल प्रतिशत नहीं लिखा: असली आँकड़ा आपके राज्य की नोडल एजेंसी से '
                'ही मिलेगा।'
            : 'PM-KUSUM subsidises a solar pump for a farmer. The Centre '
                'generally puts in 30% (more in hilly and north-eastern '
                'states), the state adds its share, and the rest is the '
                'farmer\'s. State shares differ sharply - in some states the '
                'farmer pays very little. So there is no total percentage on '
                'this screen: the real figure comes from your state nodal '
                'agency.'),
        const SizedBox(height: 10),
        Text(hi ? 'कौन ले सकता है' : 'Who can apply',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'अपनी ज़मीन पर खेती करने वाले किसान',
                  'किसानों के समूह, सहकारी समितियाँ और किसान उत्पादक संगठन',
                  'पंचायतें और जल उपभोक्ता संघ',
                  'जिनके पास पहले से डीज़ल पंप है और जो उसे बदलना चाहते हैं',
                ]
              : const [
                  'Farmers cultivating their own land',
                  'Groups of farmers, cooperatives and farmer producer '
                      'organisations',
                  'Panchayats and water user associations',
                  'Anyone with a diesel pump who wants to replace it',
                ],
        ),
        const SizedBox(height: 14),
        ToolAnswer(
          headline: hi ? 'डीज़ल से तुलना' : 'Against a diesel pump',
          detail: hi
              ? 'सोलर पंप का असली फ़ायदा ईंधन के ख़र्च का ख़त्म हो जाना है। डीज़ल पंप '
                  'में हर सिंचाई पर पैसा लगता है और दाम बढ़ते रहते हैं; सोलर पंप में '
                  'एक बार का ख़र्च है और उसके बाद कुछ नहीं। नुक़सान यह है कि पानी तभी '
                  'मिलता है जब धूप हो — इसलिए सिंचाई का समय दिन में तय करना पड़ता है। '
                  'छोटे खेत और जहाँ बिजली कम आती है, वहाँ यह सबसे ज़्यादा काम का है।'
              : 'The real gain from a solar pump is that the fuel cost '
                  'disappears. A diesel pump costs money every time you '
                  'irrigate and the price keeps rising; a solar pump is one '
                  'payment and then nothing. The drawback is that it works '
                  'only in sunshine, so irrigation has to be planned for '
                  'daylight. It suits small holdings and places where the '
                  'power supply is poor best of all.',
          tone: ToolTone.good,
          icon: Icons.wb_sunny_outlined,
        ),
        const SizedBox(height: 14),
        Text(hi ? 'अर्ज़ी कैसे' : 'How to apply',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'राज्य की नवीन एवं नवीकरणीय ऊर्जा विकास एजेंसी ही इसे चलाती है — '
                      'अर्ज़ी वहीं या उनके पोर्टल पर होती है। ज़िला कृषि कार्यालय से पता '
                      'मिल जाता है।',
                  'ज़मीन के काग़ज़, आधार, बैंक पासबुक और फ़ोटो चाहिए।',
                  'अर्ज़ी के साथ किसान का हिस्सा जमा करना होता है; मंज़ूरी न मिले तो '
                      'वापस होता है — रसीद सँभालकर रखें।',
                  'पंप का आकार खेत और गहराई के हिसाब से तय होता है; एजेंसी बताती है।',
                  'लगने के बाद वारंटी और रखरखाव का काग़ज़ ज़रूर लें — आमतौर पर पाँच साल '
                      'का होता है।',
                ]
              : const [
                  'The state renewable energy development agency runs it - '
                      'the application goes there or on their portal. The '
                      'district agriculture office has the address.',
                  'Land papers, Aadhaar, bank passbook and a photograph.',
                  'The farmer\'s share is deposited with the application and '
                      'refunded if it is not sanctioned - keep the receipt.',
                  'The pump size is set by the holding and the water depth; '
                      'the agency works it out.',
                  'After installation, get the warranty and maintenance '
                      'paper - usually five years.',
                ],
        ),
        ToolDonts(
          heading: hi ? 'सावधानी' : 'Be careful',
          items: hi
              ? const [
                  'अर्ज़ी राज्य एजेंसी के पोर्टल पर ही करें। बिचौलिये "नाम लगवा देंगे" '
                      'कहकर पैसा लेते हैं — यहाँ ऐसा कुछ नहीं होता',
                  'केंद्र की सब्सिडी का प्रतिशत बताने वाले विज्ञापनों पर न जाएँ; अपने '
                      'राज्य का असली हिस्सा एजेंसी से पूछें',
                  'पंप का आकार ज़रूरत से बड़ा न लगवाएँ — किसान का हिस्सा उसी हिसाब से '
                      'बढ़ता है',
                  'वारंटी और रखरखाव लिखित में न हो तो पैनल ख़राब होने पर कोई नहीं सुनता',
                ]
              : const [
                  'Apply on the state agency\'s portal only. Middlemen take '
                      'money to "get your name in" - there is no such step',
                  'Ignore advertisements quoting a central subsidy '
                      'percentage; ask the agency what your state\'s actual '
                      'share is',
                  'Do not take a bigger pump than you need - the farmer\'s '
                      'share rises with it',
                  'Without the warranty and maintenance in writing, nobody '
                      'listens when a panel fails',
                ],
        ),
        const SourceNote(text: 'PM-KUSUM, Ministry of New and Renewable '
            'Energy', url: _kusumUrl),
      ],
    );
  }
}

// --- Ujjwala ----------------------------------------------------------

class UjjwalaPage extends StatefulWidget {
  const UjjwalaPage({super.key});

  @override
  State<UjjwalaPage> createState() => _UjjwalaPageState();
}

class _UjjwalaPageState extends State<UjjwalaPage> {
  bool _woman = true;
  bool _hasConnection = false;
  bool _poorHousehold = true;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final fits = _woman && !_hasConnection && _poorHousehold;

    return ToolScaffold(
      goal: 7,
      title: hi ? 'मुफ़्त गैस कनेक्शन (उज्ज्वला)' : 'A free LPG connection (Ujjwala)',
      children: [
        ToolNote(hi
            ? 'उज्ज्वला योजना में पात्र परिवार की महिला के नाम गैस कनेक्शन बिना '
                'जमानत राशि और बिना लगाने के ख़र्च के मिलता है, और उसके साथ चूल्हा, '
                'रेगुलेटर, पाइप और पहला सिलेंडर भी। कनेक्शन महिला के ही नाम होता है — '
                'यह शर्त है, सुविधा नहीं।'
            : 'Under the Ujjwala scheme an eligible household gets an LPG '
                'connection in a woman\'s name with no security deposit and '
                'no installation charge, along with a stove, regulator, hose '
                'and the first refill. The connection must be in the '
                'woman\'s name - that is a condition, not an option.'),
        ToolQuestion(hi ? 'तीन शर्तें' : 'The three conditions'),
        SwitchListTile(
          value: _woman,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'अर्ज़ी देने वाली महिला है, 18 साल से ऊपर'
              : 'The applicant is a woman aged 18 or above'),
          onChanged: (v) => setState(() => _woman = v),
        ),
        SwitchListTile(
          value: _hasConnection,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'घर में पहले से कोई गैस कनेक्शन है'
              : 'The household already has an LPG connection'),
          subtitle: Text(
            hi
                ? 'किसी भी कंपनी का, किसी भी सदस्य के नाम'
                : 'From any company, in any member\'s name',
            style: const TextStyle(fontSize: 12),
          ),
          onChanged: (v) => setState(() => _hasConnection = v),
        ),
        SwitchListTile(
          value: _poorHousehold,
          contentPadding: EdgeInsets.zero,
          title: Text(hi
              ? 'परिवार ग़रीब श्रेणी में आता है'
              : 'The household falls in the poor category'),
          subtitle: Text(
            hi
                ? 'निर्धारित प्रारूप में अभाव का घोषणा-पत्र देना होता है'
                : 'A deprivation declaration in the prescribed form is given',
            style: const TextStyle(fontSize: 12),
          ),
          onChanged: (v) => setState(() => _poorHousehold = v),
        ),
        ToolAnswer(
          headline: fits
              ? (hi ? 'कनेक्शन बनता है' : 'The connection should come')
              : (hi ? 'एक शर्त पूरी नहीं हो रही' : 'One condition is not met'),
          detail: fits
              ? (hi
                  ? 'नज़दीकी गैस एजेंसी में अर्ज़ी दें — आधार, बैंक खाते की जानकारी, '
                      'पहचान पत्र और अभाव का घोषणा-पत्र लेकर। कई जगह यह ऑनलाइन भी '
                      'होता है। कनेक्शन और चूल्हे के पैसे नहीं लगते।'
                  : 'Apply at the nearest gas agency with Aadhaar, bank '
                      'details, identity proof and the deprivation '
                      'declaration. In many places this can be done online '
                      'too. There is nothing to pay for the connection or '
                      'the stove.')
              : (_hasConnection
                  ? (hi
                      ? 'घर में पहले से कनेक्शन होने पर उज्ज्वला का नया कनेक्शन नहीं '
                          'मिलता — यह उन घरों के लिए है जिनके पास कोई कनेक्शन नहीं। '
                          'अगर पुराना कनेक्शन किसी और के नाम है और वह व्यक्ति अब घर में '
                          'नहीं रहता, तो एजेंसी से नाम बदलवाने की बात करें।'
                      : 'With a connection already in the household, a new '
                          'Ujjwala one does not follow - it is for households '
                          'that have none. If the old connection is in '
                          'someone\'s name who no longer lives there, ask the '
                          'agency about transferring it.')
                  : (hi
                      ? 'कनेक्शन महिला के नाम होना और परिवार का पात्र श्रेणी में होना, '
                          'दोनों ज़रूरी हैं। पात्रता की सूची समय-समय पर बढ़ती रही है, '
                          'इसलिए गैस एजेंसी में एक बार पूछ लेना ठीक है।'
                      : 'The connection being in a woman\'s name and the '
                          'household being in an eligible category are both '
                          'required. The eligibility list has been widened '
                          'from time to time, so it is worth asking at the '
                          'gas agency.')),
          tone: fits ? ToolTone.good : ToolTone.warn,
          icon: Icons.local_fire_department_outlined,
        ),
        const SizedBox(height: 14),
        Text(hi ? 'क्या मुफ़्त है और क्या नहीं' : 'What is free and what is not',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        ToolLine(hi ? 'कनेक्शन और जमानत राशि' : 'Connection and security deposit',
            hi ? 'मुफ़्त' : 'Free', strong: true),
        ToolLine(hi ? 'चूल्हा, रेगुलेटर, पाइप' : 'Stove, regulator, hose',
            hi ? 'मुफ़्त' : 'Free'),
        ToolLine(hi ? 'पहला सिलेंडर' : 'First refill',
            hi ? 'मुफ़्त' : 'Free'),
        ToolLine(hi ? 'उसके बाद के सिलेंडर' : 'Refills after that',
            hi ? 'पैसे देने होते हैं' : 'You pay'),
        ToolLine(
            hi ? 'सब्सिडी बाद में खाते में' : 'Subsidy credited afterwards',
            hi ? 'हाँ' : 'Yes'),
        const SizedBox(height: 8),
        ToolNote(hi
            ? 'सिलेंडर पर कितनी सब्सिडी मिलती है और साल में कितने सिलेंडर पर मिलती '
                'है — यह सरकार के आदेश से तय होता है और बदलता रहता है, इसलिए यहाँ '
                'कोई रक़म नहीं लिखी गई। अपनी असली सब्सिडी देखने का तरीक़ा अगली स्क्रीन '
                'में है।'
            : 'How much subsidy a cylinder carries, and on how many cylinders '
                'a year, is set by government order and changes, so no figure '
                'is given here. How to see your own actual subsidy is on the '
                'next screen.'),
        const SourceNote(
            text: 'Pradhan Mantri Ujjwala Yojana', url: _pmuyUrl),
      ],
    );
  }
}

// --- LPG subsidy not credited -----------------------------------------

enum LpgStuck { neverCame, stopped, lessThanExpected, notSure }

class LpgSubsidyPage extends StatefulWidget {
  const LpgSubsidyPage({super.key});

  @override
  State<LpgSubsidyPage> createState() => _LpgSubsidyPageState();
}

class _LpgSubsidyPageState extends State<LpgSubsidyPage> {
  LpgStuck? _stuck;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    Widget pick(LpgStuck s, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _stuck == s,
          onTap: () => setState(() => _stuck = s),
        );

    return ToolScaffold(
      goal: 7,
      title: hi ? 'गैस सब्सिडी नहीं आ रही' : 'The LPG subsidy has not come',
      children: [
        ToolNote(hi
            ? 'सब्सिडी सिलेंडर के दाम में नहीं घटती — पूरा दाम देना होता है और '
                'सब्सिडी बाद में बैंक खाते में आती है। इसलिए पहला काम यह देखना है कि '
                'वह आई या नहीं, और यह आप ख़ुद देख सकते हैं।'
            : 'The subsidy is not taken off the price of the cylinder - you '
                'pay the full amount and the subsidy comes into the bank '
                'account afterwards. So the first thing is to find out '
                'whether it came, and you can check that yourself.'),
        ToolAnswer(
          headline: hi ? 'पहले अपनी सब्सिडी ख़ुद देखें' : 'First, look at your own subsidy',
          detail: hi
              ? 'अपनी गैस कंपनी (इंडेन, भारत गैस या एचपी) की वेबसाइट या ऐप पर अपने '
                  'उपभोक्ता नंबर से लॉगिन करके "सब्सिडी स्थिति" या "सिलेंडर का इतिहास" '
                  'देखें। वहाँ हर सिलेंडर के सामने लिखा होता है कि कितनी सब्सिडी कब '
                  'भेजी गई। यह जानकारी हमेशा ताज़ा होती है और आपकी अपनी है — किसी के '
                  'बताए आँकड़े से बेहतर। बैंक पासबुक में भी उसी तारीख़ के आसपास देखें।'
              : 'Log in on your gas company\'s site or app (Indane, Bharat '
                  'Gas or HP) with your consumer number and open "subsidy '
                  'status" or the cylinder history. Against each cylinder it '
                  'states how much subsidy was sent and when. That '
                  'information is always current and it is yours - better '
                  'than any figure quoted to you. Check the bank passbook '
                  'around the same dates too.',
          tone: ToolTone.good,
          icon: Icons.manage_search_outlined,
        ),
        ToolQuestion(hi ? 'क्या हो रहा है' : 'What is happening'),
        pick(LpgStuck.neverCame, 'Subsidy has never come',
            'सब्सिडी कभी आई ही नहीं'),
        pick(LpgStuck.stopped, 'It was coming, then it stopped',
            'पहले आ रही थी, फिर बंद हो गई'),
        pick(LpgStuck.lessThanExpected, 'Less than we expected came',
            'जितनी सोची थी उससे कम आई'),
        pick(LpgStuck.notSure, 'Not sure whether it is coming',
            'पक्का नहीं कि आ रही है या नहीं'),
        if (_stuck != null) ...[
          ToolAnswer(
            headline: switch (_stuck!) {
              LpgStuck.neverCame =>
                hi ? 'आधार और बैंक की कड़ी देखें' : 'Check the Aadhaar and bank link',
              LpgStuck.stopped =>
                hi ? 'अक्सर खाता या ई-केवाईसी की बात होती है' : 'Usually the account or the e-KYC',
              LpgStuck.lessThanExpected =>
                hi ? 'रक़म और सिलेंडरों की संख्या बदलती रहती है' : 'The amount and the number of cylinders change',
              LpgStuck.notSure =>
                hi ? 'कंपनी के ऐप पर दो मिनट में पता चल जाएगा' : 'The company app settles it in two minutes',
            },
            detail: switch (_stuck!) {
              LpgStuck.neverCame => hi
                  ? 'सब्सिडी सीधे खाते में तभी आती है जब कनेक्शन आधार से जुड़ा हो और '
                      'उसी आधार से बैंक खाता भी जुड़ा हो (DBT के लिए सीड किया हुआ)। '
                      'गैस एजेंसी में जाकर दोनों कड़ियाँ जाँच कराएँ। खाते में नाम और '
                      'आधार में नाम अलग-अलग होना भी आम वजह है।'
                  : 'The subsidy reaches the account only when the connection '
                      'is linked to Aadhaar and that same Aadhaar is seeded '
                      'to the bank account for DBT. Get both links checked at '
                      'the gas agency. A name that differs between the bank '
                      'and Aadhaar is another common cause.',
              LpgStuck.stopped => hi
                  ? 'पहले आ रही थी और रुक गई, तो आमतौर पर इनमें से कुछ हुआ है: बैंक '
                      'खाता बदला या बंद हुआ, खाता लंबे समय से चला नहीं इसलिए निष्क्रिय '
                      'हो गया, ई-केवाईसी दोबारा माँगी गई, या आय के आधार पर सब्सिडी बंद '
                      'कर दी गई। एजेंसी में उपभोक्ता नंबर लेकर पूछें — उनके सिस्टम में '
                      'कारण लिखा होता है।'
                  : 'If it was coming and stopped, usually one of these: the '
                      'bank account changed or closed, the account went '
                      'dormant from disuse, an e-KYC was asked for again, or '
                      'the subsidy was withdrawn on income grounds. Ask at '
                      'the agency with your consumer number - the reason is '
                      'recorded in their system.',
              LpgStuck.lessThanExpected => hi
                  ? 'सब्सिडी की रक़म और साल में कितने सिलेंडर पर मिलेगी, यह सरकार के '
                      'आदेश से बदलता रहता है, और उज्ज्वला तथा सामान्य उपभोक्ताओं के '
                      'लिए अलग-अलग होती है। इसलिए "कम आई" अक्सर ग़लती नहीं, बदला हुआ '
                      'नियम होता है। कंपनी के ऐप पर हर सिलेंडर के सामने भेजी गई रक़म '
                      'लिखी होती है — वही असली आँकड़ा है।'
                  : 'The amount, and how many cylinders a year carry it, '
                      'changes by government order, and differs between '
                      'Ujjwala and ordinary consumers. So "less than '
                      'expected" is often a changed rule rather than an '
                      'error. The company app shows the amount sent against '
                      'each cylinder - that is the real figure.',
              LpgStuck.notSure => hi
                  ? 'कंपनी के ऐप या वेबसाइट पर उपभोक्ता नंबर से लॉगिन करके सिलेंडर का '
                      'इतिहास देखें। हर सिलेंडर के सामने सब्सिडी की रक़म और तारीख़ '
                      'दिखती है। न दिखे तो एजेंसी में पूछें।'
                  : 'Log in to the company app or site with your consumer '
                      'number and open the cylinder history. Each cylinder '
                      'shows the subsidy amount and the date. If nothing '
                      'shows, ask at the agency.',
            },
            tone: ToolTone.plain,
            icon: Icons.account_balance_outlined,
          ),
          const SizedBox(height: 14),
          Text(hi ? 'शिकायत कहाँ' : 'Where the complaint goes',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'गैस एजेंसी में लिखित शिकायत और पावती।',
                    'कंपनी के ग्राहक सेवा नंबर पर शिकायत दर्ज कराएँ और संख्या लें — '
                        'नंबर सिलेंडर की रसीद और कंपनी के ऐप पर मिलता है।',
                    'कंपनी के क्षेत्रीय कार्यालय में, अगर एजेंसी से बात न बने।',
                    'एलपीजी आपात और शिकायत के लिए 1906 हर समय चालू रहता है।',
                    'केंद्र की शिकायत के लिए pgportal.gov.in पर सीपीग्राम्स।',
                  ]
                : const [
                    'A written complaint at the gas agency, with an '
                        'acknowledgement.',
                    'Log it on the company\'s customer care number and take '
                        'the number - it is on the cylinder receipt and in '
                        'the company app.',
                    'The company\'s area office, if the agency does not '
                        'settle it.',
                    '1906 works at any hour for LPG emergencies and '
                        'complaints.',
                    'For a central complaint, CPGRAMS at pgportal.gov.in.',
                  ],
          ),
          ToolDonts(
            heading: hi ? 'एजेंसी यह नहीं कर सकती' : 'What an agency may not do',
            items: hi
                ? const [
                    'सिलेंडर के साथ चूल्हा, पाइप या कोई और सामान ख़रीदने के लिए मजबूर '
                        'करना',
                    'छपे हुए दाम से ज़्यादा लेना — दाम रसीद पर छपा होता है',
                    'घर तक पहुँचाने का अलग से मनमाना पैसा माँगना',
                    'रसीद न देना',
                    'सब्सिडी के बदले कुछ भी काटना — वह सीधे खाते में आती है और एजेंसी '
                        'का उससे कोई लेना-देना नहीं',
                  ]
                : const [
                    'Force you to buy a stove, hose or anything else with a '
                        'cylinder',
                    'Charge more than the printed price - it is printed on '
                        'the receipt',
                    'Demand an arbitrary extra for home delivery',
                    'Refuse a receipt',
                    'Deduct anything against the subsidy - it goes straight '
                        'to the account and the agency has nothing to do '
                        'with it',
                  ],
          ),
          const SourceNote(
              text: 'Ministry of Petroleum and Natural Gas', url: _lpgUrl),
        ],
      ],
    );
  }
}
