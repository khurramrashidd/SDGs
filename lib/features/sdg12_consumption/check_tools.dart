import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Checking what is in your hand: gold, a medicine, a date on a packet.
///
/// The medicine screen helps someone spot a likely fake. It never says a
/// medicine is genuine - no check a shopper can do proves that - and it
/// says plainly not to stop a prescribed medicine on its own suspicion
/// without asking the doctor or pharmacist.

const _bisUrl = 'https://www.bis.gov.in/';
const _cdscoUrl = 'https://cdsco.gov.in/';
const _fssaiUrl = 'https://www.fssai.gov.in/';
const _nchUrl = 'https://consumerhelpline.gov.in/';

/// Purity grades as stamped: carat, then fineness in parts per thousand.
const hallmarkGrades = <({String k, int fineness})>[
  (k: '24K', fineness: 999),
  (k: '24K', fineness: 995),
  (k: '23K', fineness: 958),
  (k: '22K', fineness: 916),
  (k: '20K', fineness: 833),
  (k: '18K', fineness: 750),
  (k: '14K', fineness: 585),
  (k: '9K', fineness: 375),
];

// --- Gold hallmark ----------------------------------------------------

class HallmarkPage extends StatefulWidget {
  const HallmarkPage({super.key});

  @override
  State<HallmarkPage> createState() => _HallmarkPageState();
}

class _HallmarkPageState extends State<HallmarkPage> {
  final _weight = TextEditingController();
  final _rate24 = TextEditingController();
  int _grade = 3; // 22K916, the commonest jewellery grade

  @override
  void dispose() {
    _weight.dispose();
    _rate24.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final weight = double.tryParse(_weight.text.trim()) ?? 0;
    final rate = double.tryParse(_rate24.text.trim()) ?? 0;
    final g = hallmarkGrades[_grade];
    final goldValue = weight * rate * g.fineness / 1000;

    return ToolScaffold(
      goal: 12,
      title: hi ? 'क्या यह सोना हॉलमार्क वाला है' : 'Is this gold hallmarked',
      children: [
        ToolNote(hi
            ? 'हॉलमार्क वाले गहने पर तीन निशान होते हैं, और तीनों का होना ज़रूरी है। '
                'इनमें छह अंकों वाली पहचान संख्या (एचयूआईडी) सबसे काम की है, '
                'क्योंकि वह हर गहने की अपनी होती है और फ़ोन पर जाँची जा सकती है।'
            : 'A hallmarked piece carries three marks, and all three must be '
                'there. The six-character identity number (HUID) is the most '
                'useful, because it belongs to that one piece alone and can be '
                'checked on a phone.'),
        const SizedBox(height: 12),
        ToolSteps(
          steps: hi
              ? const [
                  'बीआईएस का तिकोना निशान।',
                  'शुद्धता — कैरेट और हज़ार में से हिस्सा, जैसे 22K916, यानी 91.6% '
                      'सोना।',
                  'एचयूआईडी — अंक और अक्षर मिलाकर छह निशान, जैसे AB12C3। यह 1 अप्रैल '
                      '2023 से हर हॉलमार्क वाले गहने पर ज़रूरी है।',
                ]
              : const [
                  'The BIS triangle.',
                  'The purity - carat and parts per thousand, for example '
                      '22K916, meaning 91.6% gold.',
                  'The HUID - six letters and digits mixed, for example '
                      'AB12C3. It has been required on every hallmarked piece '
                      'since 1 April 2023.',
                ],
        ),
        const SizedBox(height: 10),
        ToolAnswer(
          headline: hi ? 'एचयूआईडी जाँचें: बीआईएस केयर ऐप' : 'Check the HUID: the BIS Care app',
          detail: hi
              ? 'बीआईएस केयर ऐप मुफ़्त है। उसमें "वेरिफ़ाई एचयूआईडी" चुनें और छह '
                  'निशान डालें। ऐप शुद्धता, जौहरी का नाम और जाँच केंद्र दिखाता है। '
                  'तीन बातें मिलाइए: ऐप की शुद्धता गहने पर लिखी शुद्धता से, जौहरी का '
                  'नाम बिल पर लिखे नाम से, और गहने का प्रकार उससे जो आपके हाथ में है। '
                  'ऐप संख्या न पहचाने तो निशान नक़ली है।'
              : 'The BIS Care app is free. Choose "Verify HUID" and enter the '
                  'six characters. It shows the purity, the jeweller and the '
                  'testing centre. Match three things: the purity in the app '
                  'with the purity stamped, the jeweller with the name on the '
                  'bill, and the type of article with the one in your hand. '
                  'If the app does not recognise the number, the mark is fake.',
          tone: ToolTone.good,
          icon: Icons.verified_outlined,
        ),
        ToolQuestion(hi ? 'सोने का असली मूल्य कितना' : 'What the gold itself is worth'),
        Text(hi ? 'गहने पर लिखी शुद्धता' : 'Purity stamped on the piece',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < hallmarkGrades.length; i++)
              ChoiceChip(
                label: Text(
                    '${hallmarkGrades[i].k}${hallmarkGrades[i].fineness}'),
                selected: _grade == i,
                onSelected: (_) => setState(() => _grade = i),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _weight,
                label: hi ? 'वज़न (ग्राम)' : 'Weight (grams)',
                decimal: true,
                maxDigits: 6,
                icon: Icons.scale_outlined,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolNumber(
                controller: _rate24,
                label: hi ? 'आज का 24K भाव, प्रति ग्राम (₹)' : 'Today\'s 24K rate a gram (₹)',
                decimal: true,
                maxDigits: 7,
                icon: Icons.currency_rupee,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        if (goldValue > 0) ...[
          ToolAnswer(
            headline: hi
                ? 'सोने का मूल्य लगभग ₹${goldValue.round()}'
                : 'The gold is worth about ₹${goldValue.round()}',
            detail: hi
                ? '${weight.toStringAsFixed(2)} ग्राम में ${(g.fineness / 10).toStringAsFixed(1)}% '
                    'सोना, यानी ${(weight * g.fineness / 1000).toStringAsFixed(2)} ग्राम '
                    'शुद्ध सोना। जौहरी इसके ऊपर बनवाई (मेकिंग चार्ज) और जीएसटी जोड़ता है '
                    '— वे बिल में अलग-अलग लिखे होने चाहिए। बेचते समय आम तौर पर बनवाई '
                    'वापस नहीं मिलती, इसलिए बनवाई जितनी ज़्यादा, बेचने पर नुक़सान उतना '
                    'ज़्यादा।'
                : '${weight.toStringAsFixed(2)} grams at '
                    '${(g.fineness / 10).toStringAsFixed(1)}% is '
                    '${(weight * g.fineness / 1000).toStringAsFixed(2)} grams of '
                    'pure gold. The jeweller adds making charges and GST on '
                    'top - those should appear separately on the bill. Making '
                    'charges are usually not returned when you sell, so the '
                    'higher they are, the more you lose on resale.',
            tone: ToolTone.plain,
            icon: Icons.calculate_outlined,
          ),
        ],
        const SizedBox(height: 14),
        ToolDonts(
          heading: hi ? 'ख़रीदते समय' : 'When buying',
          items: hi
              ? const [
                  'बिना बिल के न ख़रीदें। बिल पर वज़न, शुद्धता, एचयूआईडी, बनवाई और '
                      'जीएसटी अलग-अलग हों',
                  '"हॉलमार्क बाद में लग जाएगा" न मानें — जहाँ हॉलमार्क ज़रूरी है, '
                      'वहाँ जौहरी बिना हॉलमार्क गहना बेच नहीं सकता',
                  'पत्थर लगे गहने में पत्थर का वज़न सोने के भाव में न जुड़े — बिल पर '
                      'अलग लिखवाएँ',
                  'पुराने, बिना हॉलमार्क वाले गहने बेकार नहीं हैं; उनका सोने का मूल्य '
                      'वही रहता है, और उन्हें हॉलमार्क जाँच केंद्र पर जँचवाया जा सकता है',
                ]
              : const [
                  'Do not buy without a bill. The bill should show the weight, '
                      'purity, HUID, making charges and GST separately',
                  'Do not accept "the hallmark will be added later" - where '
                      'hallmarking is required, a jeweller may not sell an '
                      'unmarked piece',
                  'In a piece with stones, the stones\' weight must not be '
                      'charged at the gold rate - get it shown separately',
                  'Old jewellery without a hallmark is not worthless; its '
                      'gold value is unchanged, and it can be tested at a '
                      'hallmarking centre',
                ],
        ),
        const SourceNote(text: 'Bureau of Indian Standards', url: _bisUrl),
      ],
    );
  }
}

// --- Fake medicine ----------------------------------------------------

class FakeMedicinePage extends StatelessWidget {
  const FakeMedicinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 12,
      title: hi ? 'क्या यह दवा या सामान नक़ली है' : 'Is this medicine or product fake',
      children: [
        ToolAnswer(
          headline: hi ? 'शक हो तो भी, दवा अपने आप बंद न करें' : 'Even if you suspect it, do not just stop the medicine',
          detail: hi
              ? 'कुछ दवाएँ अचानक बंद करना ख़ुद ख़तरनाक है। शक हो तो उसी दिन '
                  'डॉक्टर या फ़ार्मासिस्ट को पत्ता दिखाइए और दूसरी, भरोसेमंद दुकान '
                  'से बदलवाइए। नीचे की जाँच नक़ली होने का शक पक्का करती है; कोई भी '
                  'जाँच यह साबित नहीं करती कि दवा असली है।'
              : 'Stopping some medicines suddenly is dangerous in itself. If '
                  'you suspect a strip, show it to the doctor or pharmacist '
                  'that day and replace it from another, trusted shop. The '
                  'checks below can firm up a suspicion of a fake; no check '
                  'proves a medicine is genuine.',
          tone: ToolTone.warn,
          icon: Icons.medication_outlined,
        ),
        const SizedBox(height: 12),
        Text(hi ? 'क्यूआर कोड' : 'The QR code',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        ToolNote(hi
            ? 'सबसे ज़्यादा बिकने वाले ब्रांडों पर क्यूआर कोड ज़रूरी है, और 2026 '
                'से यह सभी टीकों, एंटीबायोटिक जैसी रोगाणुरोधी दवाओं, कैंसर की दवाओं '
                'और नशीली दवाओं की श्रेणी पर भी ज़रूरी कर दिया गया है। फ़ोन के कैमरे '
                'से स्कैन करने पर दवा का नाम, ब्रांड, निर्माता, बैच नंबर, बनने और '
                'ख़त्म होने की तारीख़ और लाइसेंस नंबर दिखना चाहिए — और ये पत्ते पर '
                'छपे से मेल खाने चाहिए। कोड न खुले, या ब्योरा मेल न खाए, तो यह '
                'शक की बात है।'
            : 'A QR code is required on the best-selling brands, and from '
                '2026 it has been extended to all vaccines, antimicrobials '
                'such as antibiotics, anti-cancer medicines and narcotic '
                'drugs. Scanned with a phone camera it should show the '
                'name, brand, manufacturer, batch number, manufacture and '
                'expiry dates and licence number - and they should match what '
                'is printed on the strip. If the code does not open, or the '
                'details do not match, that is grounds for suspicion.'),
        const SizedBox(height: 12),
        Text(hi ? 'दुकान में की जा सकने वाली जाँच' : 'Checks you can do in the shop',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'पत्ते पर बैच नंबर, बनने और ख़त्म होने की तारीख़ और एमआरपी साफ़ छपे '
                      'हों — धुँधले, मिटे या ऊपर से चिपकाए हुए नहीं',
                  'नाम की हिज्जे और कंपनी का पता ध्यान से पढ़ें; नक़ली पत्तों में '
                      'छोटी ग़लतियाँ आम हैं',
                  'पैकिंग की सील टूटी न हो, और पत्ता उसी डिब्बे का हो',
                  'गोली का रंग, आकार या स्वाद पहले से अलग लगे तो पूछें',
                  'बहुत सस्ते दाम पर, "बिना बिल" के, या सड़क किनारे बिकती दवा न लें',
                  'बिल ज़रूर लें — दुकान का ड्रग लाइसेंस नंबर उस पर छपा होता है',
                ]
              : const [
                  'The batch number, manufacture and expiry dates and MRP '
                      'should be printed clearly - not smudged, scratched '
                      'or pasted over',
                  'Read the spelling of the name and the company address '
                      'closely; small mistakes are common on fakes',
                  'The seal should be intact, and the strip should belong to '
                      'the box',
                  'If the tablet\'s colour, size or taste is different from '
                      'before, ask',
                  'Do not buy medicine sold very cheap, "without a bill", or '
                      'at a roadside stall',
                  'Always take a bill - the shop\'s drug licence number is '
                      'printed on it',
                ],
        ),
        const SizedBox(height: 14),
        Text(hi ? 'शक हो तो कहाँ बताएँ' : 'Where to report a suspected fake',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'पत्ता और डिब्बा फेंकें नहीं — वही सबूत है। बिल भी रखें।',
                  'राज्य के औषधि नियंत्रक (ड्रग कंट्रोलर) कार्यालय में शिकायत, '
                      'ज़िले के औषधि निरीक्षक के ज़रिये। वे नमूना लेकर जाँच कराते हैं।',
                  'केंद्रीय औषधि मानक नियंत्रण संगठन (सीडीएससीओ) की वेबसाइट पर भी '
                      'शिकायत दी जा सकती है।',
                  'दूसरे सामान — सौंदर्य प्रसाधन, बिजली का सामान, खाने का पैकेट — '
                      'के नक़ली होने पर राष्ट्रीय उपभोक्ता हेल्पलाइन 1915।',
                ]
              : const [
                  'Do not throw away the strip and the box - they are the '
                      'evidence. Keep the bill too.',
                  'Complain to the state drug controller\'s office, through '
                      'the district drug inspector. They take a sample and '
                      'have it tested.',
                  'A complaint can also be made on the Central Drugs '
                      'Standard Control Organisation\'s site.',
                  'For other fake goods - cosmetics, electrical items, food '
                      'packets - the National Consumer Helpline on 1915.',
                ],
        ),
        const SourceNote(
            text: 'Central Drugs Standard Control Organisation', url: _cdscoUrl),
        const SourceNote(text: 'National Consumer Helpline', url: _nchUrl),
      ],
    );
  }
}

// --- Use-by and best-before -------------------------------------------

enum DateKind { useBy, bestBefore }

enum PackedFood { risky, dry, oil }

class UseByPage extends StatefulWidget {
  const UseByPage({super.key});

  @override
  State<UseByPage> createState() => _UseByPageState();
}

class _UseByPageState extends State<UseByPage> {
  DateKind? _date;
  PackedFood? _food;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 12,
      title: hi ? 'यूज़-बाय या बेस्ट-बिफ़ोर: क्या अभी खा सकते हैं' : 'Use-by or best-before: can I still eat it',
      children: [
        ToolNote(hi
            ? 'दोनों तारीख़ें अलग बात कहती हैं। "यूज़-बाय" या "एक्सपायरी" सुरक्षा की '
                'रेखा है — उसके बाद नहीं खाना। "बेस्ट-बिफ़ोर" गुणवत्ता की तारीख़ है — '
                'उसके बाद स्वाद और ताज़गी कम हो सकती है, पर चीज़ हमेशा ख़राब नहीं '
                'होती। खाद्य सुरक्षा नियमों में यूज़-बाय या एक्सपायरी की तारीख़ छापना '
                'ज़रूरी है, और उसके बाद वह चीज़ बेची नहीं जा सकती।'
            : 'The two dates say different things. "Use by" or "expiry" is a '
                'safety line - do not eat it after that. "Best before" is a '
                'quality date - after it the taste and freshness may fall, '
                'but the food is not always bad. The food safety rules '
                'require a use-by or expiry date to be printed, and the food '
                'may not be sold after it.'),
        ToolQuestion(hi ? 'पैकेट पर कौन सी तारीख़ निकल गई' : 'Which date on the packet has passed'),
        SelectionTile(
          label: hi ? 'यूज़-बाय या एक्सपायरी' : 'Use by, or expiry',
          selected: _date == DateKind.useBy,
          onTap: () => setState(() => _date = DateKind.useBy),
        ),
        SelectionTile(
          label: hi ? 'बेस्ट-बिफ़ोर' : 'Best before',
          selected: _date == DateKind.bestBefore,
          onTap: () => setState(() => _date = DateKind.bestBefore),
        ),
        if (_date == DateKind.useBy)
          ToolAnswer(
            headline: hi ? 'मत खाइए' : 'Do not eat it',
            detail: hi
                ? 'यूज़-बाय या एक्सपायरी के बाद खाना सुरक्षित नहीं माना जाता, चाहे वह '
                    'देखने और सूँघने में ठीक लगे — कई कीटाणु न दिखते हैं, न उनकी गंध '
                    'आती है। फेंक दें। दुकान ने यह तारीख़ बीतने के बाद बेचा हो तो '
                    'बिल और पैकेट की फ़ोटो के साथ 1915 पर शिकायत करें — एक्सपायरी '
                    'के बाद बेचना अपराध है।'
                : 'After the use-by or expiry date, food is not considered '
                    'safe even if it looks and smells fine - many germs can '
                    'be neither seen nor smelled. Throw it away. If a shop '
                    'sold it after that date, complain on 1915 with the bill '
                    'and a photo of the packet - selling past expiry is an '
                    'offence.',
            tone: ToolTone.bad,
            icon: Icons.block,
          ),
        if (_date == DateKind.bestBefore) ...[
          ToolQuestion(hi ? 'चीज़ किस तरह की है' : 'What kind of food'),
          SelectionTile(
            label: hi
                ? 'दूध, दही, पनीर, मांस, मछली, अंडा, पका खाना, या बच्चे का खाना'
                : 'Milk, curd, paneer, meat, fish, eggs, cooked food, or baby food',
            selected: _food == PackedFood.risky,
            onTap: () => setState(() => _food = PackedFood.risky),
          ),
          SelectionTile(
            label: hi
                ? 'सूखा सामान — बिस्कुट, चावल, दाल, आटा, मसाले, चिप्स'
                : 'Dry goods - biscuits, rice, dal, flour, spices, chips',
            selected: _food == PackedFood.dry,
            onTap: () => setState(() => _food = PackedFood.dry),
          ),
          SelectionTile(
            label: hi ? 'तेल, घी, मेवे' : 'Oil, ghee, nuts',
            selected: _food == PackedFood.oil,
            onTap: () => setState(() => _food = PackedFood.oil),
          ),
          if (_food == PackedFood.risky)
            ToolAnswer(
              headline: hi ? 'इन्हें बेस्ट-बिफ़ोर के बाद न लें' : 'Do not use these past best-before',
              detail: hi
                  ? 'जल्दी ख़राब होने वाली चीज़ों में बेस्ट-बिफ़ोर और सुरक्षा की रेखा '
                      'लगभग एक ही होती है। बच्चे का खाना — फ़ॉर्मूला दूध, सेरेलैक जैसे — '
                      'तारीख़ के बाद कभी नहीं।'
                  : 'For perishable foods the best-before date and the safety '
                      'line are nearly the same. Baby food - formula, cereal '
                      'mixes - never after the date.',
              tone: ToolTone.bad,
              icon: Icons.block,
            ),
          if (_food == PackedFood.dry)
            ToolAnswer(
              headline: hi ? 'देखकर, सूँघकर तय करें' : 'Decide by look and smell',
              detail: hi
                  ? 'बंद और सूखी जगह रखा सूखा सामान बेस्ट-बिफ़ोर के कुछ समय बाद भी '
                      'आम तौर पर सुरक्षित होता है; स्वाद या कुरकुरापन घट सकता है। '
                      'फेंक दें अगर: फफूँद, कीड़े या जाले दिखें, अजीब या बासी गंध हो, '
                      'पैकेट फूला हो, या आटे-दाल में गुठलियाँ और नमी हो।'
                  : 'Dry goods kept sealed and dry are usually still safe some '
                      'time past best-before; the taste or crispness may fade. '
                      'Throw it away if: there is mould, insects or webbing, a '
                      'strange or stale smell, a puffed-up packet, or lumps '
                      'and damp in flour or dal.',
              tone: ToolTone.plain,
              icon: Icons.visibility_outlined,
            ),
          if (_food == PackedFood.oil)
            ToolAnswer(
              headline: hi ? 'बासी गंध हो तो नहीं' : 'Not if it smells rancid',
              detail: hi
                  ? 'तेल, घी और मेवे पुराने होने पर बासी (खट्टी, पेंट जैसी) गंध देने '
                      'लगते हैं। ऐसी गंध हो तो इस्तेमाल न करें। गंध ठीक हो तो आम तौर '
                      'पर तारीख़ के कुछ बाद भी चल जाते हैं। मेवों पर फफूँद दिखे तो '
                      'पूरा पैकेट फेंकें — वह फफूँद ज़हरीली हो सकती है।'
                  : 'Oil, ghee and nuts go rancid with age - a sour, '
                      'paint-like smell. If they smell like that, do not use '
                      'them. If the smell is fine they usually keep a while '
                      'past the date. If there is mould on nuts, throw out the '
                      'whole packet - that mould can be toxic.',
              tone: ToolTone.plain,
              icon: Icons.water_drop_outlined,
            ),
        ],
        const SizedBox(height: 14),
        ToolDonts(
          heading: hi ? 'तारीख़ कुछ भी हो, फेंक दें अगर' : 'Whatever the date, throw it out if',
          items: hi
              ? const [
                  'डिब्बा (कैन) फूला हुआ, पिचका हुआ या जंग लगा हो',
                  'खोलते समय झाग या फुस्स की आवाज़ आए जो नहीं आनी चाहिए',
                  'फफूँद दिखे — ऊपर से हटाकर बाक़ी खाना सुरक्षित नहीं होता',
                  'ठंडा रखने वाली चीज़ घंटों बाहर पड़ी रही हो',
                ]
              : const [
                  'A can is bulging, dented badly or rusted',
                  'It foams or hisses on opening when it should not',
                  'There is mould - scraping it off does not make the rest '
                      'safe',
                  'Something meant to be kept cold sat out for hours',
                ],
        ),
        const SourceNote(
            text: 'Food Safety and Standards Authority of India',
            url: _fssaiUrl),
      ],
    );
  }
}
