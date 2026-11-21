import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Waste: which bin, composting at home, and an old phone or battery.
///
/// The bins follow the Solid Waste Management Rules 2026, in force from
/// 1 April 2026, which replace the old wet / dry / hazardous split with
/// four streams: wet, dry, sanitary and special care. Bin colours are not
/// stated, because towns paint them differently.

const _moefccUrl = 'https://moef.gov.in/';
const _cpcbUrl = 'https://cpcb.nic.in/';
const _sancharUrl = 'https://sancharsaathi.gov.in/';

enum WasteStream { wet, dry, sanitary, specialCare, eWaste }

class _Item {
  final String en;
  final String hi;
  final WasteStream stream;
  final String? tipEn;
  final String? tipHi;
  const _Item(this.en, this.hi, this.stream, {this.tipEn, this.tipHi});
}

const _items = <_Item>[
  _Item('Vegetable and fruit peels', 'सब्ज़ी और फल के छिलके', WasteStream.wet),
  _Item('Leftover cooked food', 'बचा हुआ पका खाना', WasteStream.wet),
  _Item('Tea leaves, coffee grounds', 'चाय की पत्ती, कॉफ़ी', WasteStream.wet),
  _Item('Egg shells', 'अंडे के छिलके', WasteStream.wet),
  _Item('Flowers, puja garlands', 'फूल, पूजा की माला', WasteStream.wet,
      tipEn: 'Take off any plastic thread or foil first.',
      tipHi: 'पहले प्लास्टिक का धागा या पन्नी हटा लें।'),
  _Item('Garden leaves and grass', 'बगीचे की पत्तियाँ और घास', WasteStream.wet,
      tipEn: 'Never burn them - compost instead.',
      tipHi: 'जलाएँ नहीं — खाद बनाएँ।'),
  _Item('Bones, meat and fish waste', 'हड्डी, मांस और मछली का कचरा', WasteStream.wet,
      tipEn: 'Wet bin, but keep it out of a home compost pit - it draws '
          'animals.',
      tipHi: 'गीले में, पर घर के खाद के गड्ढे में नहीं — जानवर आते हैं।'),
  _Item('Plastic bags and wrappers', 'प्लास्टिक की थैली और रैपर', WasteStream.dry,
      tipEn: 'Clean and dry. A food-smeared wrapper spoils the whole dry '
          'bin.',
      tipHi: 'साफ़ और सूखे। खाना लगा रैपर पूरा सूखा कचरा ख़राब कर देता है।'),
  _Item('Plastic bottles', 'प्लास्टिक की बोतल', WasteStream.dry),
  _Item('Milk packets', 'दूध की थैली', WasteStream.dry,
      tipEn: 'Rinse and dry first. Many kabadiwalas buy them.',
      tipHi: 'पहले धोकर सुखा लें। कई कबाड़ी इन्हें ख़रीदते हैं।'),
  _Item('Newspaper, cardboard, paper', 'अख़बार, गत्ता, काग़ज़', WasteStream.dry),
  _Item('Glass bottles and jars', 'काँच की बोतल और बरनी', WasteStream.dry,
      tipEn: 'Broken glass: wrap it in newspaper and write "glass" on it, '
          'so nobody is cut.',
      tipHi: 'टूटा काँच अख़बार में लपेटें और ऊपर "काँच" लिख दें, ताकि किसी '
          'का हाथ न कटे।'),
  _Item('Metal cans, foil', 'धातु के डिब्बे, पन्नी', WasteStream.dry),
  _Item('Old clothes, cloth', 'पुराने कपड़े', WasteStream.dry,
      tipEn: 'Wearable clothes are better given away.',
      tipHi: 'पहनने लायक कपड़े किसी को दे देना बेहतर है।'),
  _Item('Rubber, thermocol, wood', 'रबर, थर्माकोल, लकड़ी', WasteStream.dry),
  _Item('Diapers and nappies', 'डायपर', WasteStream.sanitary),
  _Item('Sanitary pads, tampons', 'सैनिटरी पैड, टैम्पॉन', WasteStream.sanitary),
  _Item('Bandages, used cotton', 'पट्टी, इस्तेमाल की रुई', WasteStream.sanitary),
  _Item('Condoms', 'कंडोम', WasteStream.sanitary),
  _Item('Expired or unused medicines', 'पुरानी या बची दवाएँ', WasteStream.specialCare,
      tipEn: 'Never down the drain or toilet. Some chemists and hospitals '
          'take them back.',
      tipHi: 'नाली या शौचालय में कभी नहीं। कुछ केमिस्ट और अस्पताल वापस लेते हैं।'),
  _Item('Syringes and needles', 'सिरिंज और सुई', WasteStream.specialCare,
      tipEn: 'Put them in a hard plastic bottle with the cap screwed shut, '
          'so no one is pricked.',
      tipHi: 'कड़ी प्लास्टिक की बोतल में डालकर ढक्कन कसकर बंद करें, ताकि '
          'किसी को चुभे नहीं।'),
  _Item('Tube lights, CFL and LED bulbs', 'ट्यूबलाइट, सीएफ़एल और एलईडी बल्ब',
      WasteStream.specialCare,
      tipEn: 'CFLs and tube lights contain mercury. Do not break them.',
      tipHi: 'सीएफ़एल और ट्यूबलाइट में पारा होता है। तोड़ें नहीं।'),
  _Item('Mercury thermometer', 'पारे वाला थर्मामीटर', WasteStream.specialCare,
      tipEn: 'If one breaks, do not vacuum or sweep - air the room and pick '
          'the beads up with stiff paper.',
      tipHi: 'टूट जाए तो झाड़ू न लगाएँ — कमरे में हवा आने दें और पारे की '
          'बूँदें कड़े काग़ज़ से उठाएँ।'),
  _Item('Paint and paint tins', 'पेंट और पेंट के डिब्बे', WasteStream.specialCare),
  _Item('Pesticide and cleaner bottles', 'कीटनाशक और सफ़ाई के रसायन की बोतल',
      WasteStream.specialCare,
      tipEn: 'Never reuse a pesticide bottle for water or oil.',
      tipHi: 'कीटनाशक की बोतल में पानी या तेल कभी न रखें।'),
  _Item('Household batteries', 'घर के सेल और बैटरी', WasteStream.eWaste),
  _Item('Old mobile phones and chargers', 'पुराने मोबाइल और चार्जर',
      WasteStream.eWaste),
  _Item('Earphones, cables, small electronics', 'ईयरफ़ोन, तार, छोटा इलेक्ट्रॉनिक सामान',
      WasteStream.eWaste),
];

String _streamWord(WasteStream s, bool hi) {
  switch (s) {
    case WasteStream.wet:
      return hi ? 'गीला कचरा' : 'Wet waste';
    case WasteStream.dry:
      return hi ? 'सूखा कचरा' : 'Dry waste';
    case WasteStream.sanitary:
      return hi ? 'सैनिटरी कचरा' : 'Sanitary waste';
    case WasteStream.specialCare:
      return hi ? 'विशेष देखभाल वाला कचरा' : 'Special care waste';
    case WasteStream.eWaste:
      return hi ? 'ई-कचरा (विशेष देखभाल)' : 'E-waste (special care)';
  }
}

String _streamHow(WasteStream s, bool hi) {
  switch (s) {
    case WasteStream.wet:
      return hi
          ? 'गीले कचरे के डिब्बे में, या घर पर खाद बनाएँ। इसमें प्लास्टिक न मिलाएँ।'
          : 'In the wet bin, or compost it at home. Keep plastic out of it.';
    case WasteStream.dry:
      return hi
          ? 'सूखे कचरे में, साफ़ और सूखा। बहुत कुछ कबाड़ी ख़रीदता है।'
          : 'In the dry bin, clean and dry. A kabadiwala buys a lot of it.';
    case WasteStream.sanitary:
      return hi
          ? 'अख़बार या काग़ज़ में अच्छी तरह लपेटकर, बंद करके अलग दें। इसे गीले या '
              'सूखे कचरे में मिलाना अब नियम के ख़िलाफ़ है, और यही सफ़ाई कर्मचारी '
              'के हाथ में सबसे ज़्यादा बीमारी पहुँचाता है।'
          : 'Wrapped well in newspaper or paper, sealed, and handed over '
              'separately. Mixing it with wet or dry waste is now against the '
              'rules - and it is what carries the most disease to the '
              'sanitation worker\'s hands.';
    case WasteStream.specialCare:
      return hi
          ? 'अलग रखें और नगर पालिका या पंचायत के तय संग्रह केंद्र पर दें। इसे '
              'किसी और डिब्बे में न मिलाएँ।'
          : 'Keep it apart and hand it in at the municipality\'s or '
              'panchayat\'s collection point. Do not mix it into any other '
              'bin.';
    case WasteStream.eWaste:
      return hi
          ? 'किसी डिब्बे में नहीं। कंपनी के वापसी कार्यक्रम, अधिकृत संग्रह केंद्र, '
              'या नगर पालिका के ई-कचरा केंद्र पर। इसी लक्ष्य में "पुराना फ़ोन या '
              'बैटरी" वाली स्क्रीन देखें।'
          : 'Not in any bin. To the company\'s take-back programme, an '
              'authorised collection centre, or the municipality\'s e-waste '
              'point. See "Old phone or battery" in this goal.';
  }
}

// --- Which bin --------------------------------------------------------

class WhichBinPage extends StatefulWidget {
  const WhichBinPage({super.key});

  @override
  State<WhichBinPage> createState() => _WhichBinPageState();
}

class _WhichBinPageState extends State<WhichBinPage> {
  final _query = TextEditingController();
  _Item? _picked;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final q = _query.text.trim().toLowerCase();
    final shown = q.isEmpty
        ? _items
        : _items
            .where((e) =>
                e.en.toLowerCase().contains(q) || e.hi.contains(q))
            .toList();
    final picked = _picked;

    return ToolScaffold(
      goal: 12,
      title: hi ? 'यह किस डिब्बे में जाएगा' : 'Which bin does this go in',
      children: [
        ToolNote(hi
            ? '1 अप्रैल 2026 से ठोस कचरा प्रबंधन नियम 2026 लागू हैं, और घर का '
                'कचरा अब चार हिस्सों में अलग करना है: गीला, सूखा, सैनिटरी और विशेष '
                'देखभाल वाला। मिला हुआ कचरा देना अब नियम तोड़ना है। डिब्बों के रंग '
                'शहर-शहर अलग हैं, इसलिए यहाँ नाम दिए हैं।'
            : 'The Solid Waste Management Rules 2026 have applied since '
                '1 April 2026, and household waste now has to be split four '
                'ways: wet, dry, sanitary and special care. Handing over mixed '
                'waste is now a breach of the rules. Bin colours differ from '
                'town to town, so the names are given here.'),
        const SizedBox(height: 10),
        ToolText(
          controller: _query,
          label: hi ? 'खोजें — जैसे बल्ब, डायपर, छिलके' : 'Search - e.g. bulb, diaper, peels',
          onChanged: (_) => setState(() => _picked = null),
        ),
        const SizedBox(height: 8),
        if (picked != null) ...[
          ToolAnswer(
            headline: '${hi ? picked.hi : picked.en}: ${_streamWord(picked.stream, hi)}',
            detail: [
              _streamHow(picked.stream, hi),
              if ((hi ? picked.tipHi : picked.tipEn) != null)
                (hi ? picked.tipHi : picked.tipEn)!,
            ].join('\n\n'),
            tone: picked.stream == WasteStream.wet || picked.stream == WasteStream.dry
                ? ToolTone.good
                : ToolTone.warn,
            icon: Icons.delete_outline,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => _picked = null),
            child: Text(hi ? 'दूसरी चीज़ चुनें' : 'Pick another item'),
          ),
        ] else ...[
          for (final e in shown)
            SelectionTile(
              label: hi ? e.hi : e.en,
              subtitle: _streamWord(e.stream, hi),
              selected: false,
              onTap: () => setState(() => _picked = e),
            ),
          if (shown.isEmpty)
            ToolNote(hi
                ? 'यह चीज़ सूची में नहीं है। अपने वार्ड या पंचायत के सफ़ाई '
                    'कर्मचारी से पूछ लें।'
                : 'That item is not on the list. Ask your ward or panchayat '
                    'sanitation worker.'),
        ],
        const SourceNote(
            text: 'Ministry of Environment, Forest and Climate Change',
            url: _moefccUrl),
      ],
    );
  }
}

// --- Compost at home --------------------------------------------------

class CompostPage extends StatelessWidget {
  const CompostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 12,
      title: hi ? 'घर पर खाद बनाएँ' : 'Compost at home',
      children: [
        ToolNote(hi
            ? 'घर के कचरे का आधे से ज़्यादा हिस्सा आम तौर पर गीला होता है, और वही '
                'बदबू और मक्खियाँ लाता है। उसे खाद में बदलने के लिए दो मटके या एक '
                'छेद वाली बाल्टी काफ़ी है। सबसे ज़रूरी बात एक ही है: हर बार गीले के '
                'ऊपर सूखी परत।'
            : 'More than half of household waste is usually wet, and it is '
                'what brings the smell and the flies. Two clay pots or one '
                'bucket with holes is enough to turn it into compost. The one '
                'thing that matters most: a dry layer on top of the wet every '
                'time.'),
        const SizedBox(height: 12),
        Text(hi ? 'तरीक़ा' : 'How',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'बाल्टी या मटके में नीचे और किनारों पर छोटे छेद करें, ताकि हवा जाए '
                      'और पानी निकले। नीचे ईंट रखकर ज़मीन से थोड़ा ऊपर रखें।',
                  'सबसे नीचे सूखे पत्ते, नारियल का छिलका या फटा गत्ता बिछाएँ।',
                  'रोज़ का गीला कचरा डालें, और उसके ऊपर मुट्ठी भर सूखे पत्ते, '
                      'बुरादा या मिट्टी। पहली बार थोड़ा पुराना खाद या गोबर डालें तो '
                      'काम जल्दी शुरू होता है।',
                  'हफ़्ते में एक-दो बार डंडे से उलट-पलट करें।',
                  'भरने पर उसे ढककर छोड़ दें और दूसरा बर्तन शुरू करें।',
                  'लगभग दो महीने में खाद तैयार — गहरा भूरा, भुरभुरा, और मिट्टी जैसी '
                      'गंध। मौसम ठंडा हो तो ज़्यादा समय लगता है।',
                ]
              : const [
                  'Make small holes in the bottom and sides of a bucket or '
                      'pot so air gets in and water drains. Stand it on a '
                      'brick, a little off the ground.',
                  'Line the bottom with dry leaves, coconut husk or torn '
                      'cardboard.',
                  'Add the day\'s wet waste, and over it a handful of dry '
                      'leaves, sawdust or soil. A little old compost or cow '
                      'dung the first time gets it going faster.',
                  'Turn it over with a stick once or twice a week.',
                  'When it is full, cover it and leave it, and start the '
                      'second pot.',
                  'In about two months the compost is ready - dark brown, '
                      'crumbly, and smelling of soil. In cold weather it takes '
                      'longer.',
                ],
        ),
        const SizedBox(height: 12),
        ToolDonts(
          heading: hi ? 'इसमें न डालें' : 'Keep out of it',
          items: hi
              ? const [
                  'मांस, मछली, हड्डी, दूध-दही और तेल वाला खाना — बदबू और जानवर',
                  'प्लास्टिक, पन्नी, काँच — ये कभी नहीं गलते',
                  'पालतू जानवरों या इंसान का मल',
                  'बीमार पौधे, और कीटनाशक छिड़की पत्तियाँ',
                  'राख की मोटी परत, या कोयला',
                ]
              : const [
                  'Meat, fish, bones, milk, curd and oily food - smell and '
                      'animals',
                  'Plastic, foil, glass - these never break down',
                  'Pet or human waste',
                  'Diseased plants, and leaves sprayed with pesticide',
                  'A thick layer of ash, or charcoal',
                ],
        ),
        const SizedBox(height: 12),
        Text(hi ? 'कुछ ग़लत लगे तो' : 'If something seems wrong',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        ToolLine(hi ? 'सड़ी, खट्टी बदबू' : 'A rotten, sour smell',
            hi ? 'ज़्यादा गीला: सूखे पत्ते डालें, पलटें' : 'Too wet: add dry leaves, turn'),
        ToolLine(hi ? 'मक्खियाँ और कीड़े' : 'Flies and maggots',
            hi ? 'गीला खुला है: ऊपर सूखी परत' : 'Wet is exposed: cover with a dry layer'),
        ToolLine(hi ? 'कुछ नहीं बदल रहा' : 'Nothing is changing',
            hi ? 'बहुत सूखा: थोड़ा पानी छिड़कें' : 'Too dry: sprinkle a little water'),
        const SourceNote(text: 'Central Pollution Control Board', url: _cpcbUrl),
      ],
    );
  }
}

// --- Old phone or battery ---------------------------------------------

class OldPhonePage extends StatelessWidget {
  const OldPhonePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 12,
      title: hi ? 'पुराना फ़ोन या बैटरी: कहाँ जाए' : 'Old phone or battery: where it goes',
      children: [
        ToolAnswer(
          headline: hi ? 'फूली हुई बैटरी — अभी अलग करें' : 'A swollen battery - separate it now',
          detail: hi
              ? 'फ़ोन या पावर बैंक की बैटरी फूल गई हो तो उसे चार्ज न करें, दबाएँ '
                  'नहीं, छेद न करें, और गरम जगह न रखें — उसमें आग लग सकती है। उसे '
                  'किसी धातु के डिब्बे में या रेत में, बच्चों से दूर रखें और जल्दी से '
                  'जल्दी संग्रह केंद्र या सर्विस सेंटर दें।'
              : 'If a phone or power-bank battery has swollen, do not charge '
                  'it, press it, pierce it or keep it somewhere hot - it can '
                  'catch fire. Keep it in a metal tin or in sand, away from '
                  'children, and hand it to a collection centre or service '
                  'centre as soon as you can.',
          tone: ToolTone.bad,
          icon: Icons.battery_alert_outlined,
        ),
        const SizedBox(height: 12),
        Text(hi ? 'देने से पहले — अपना डेटा मिटाएँ' : 'Before handing it over - wipe your data',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'फ़ोटो, नंबर और व्हाट्सऐप चैट का बैकअप लें।',
                  'गूगल या ऐपल खाते से लॉग आउट करें — वरना फ़ोन अगले व्यक्ति के लिए '
                      'बंद रहता है, और आपका खाता उससे जुड़ा रहता है।',
                  'बैंक और यूपीआई ऐप से लॉग आउट करें, और व्हाट्सऐप में "लिंक्ड '
                      'डिवाइस" देखकर हटा दें।',
                  'सेटिंग में "फ़ैक्टरी रीसेट" करें।',
                  'सिम कार्ड और मेमोरी कार्ड निकाल लें।',
                ]
              : const [
                  'Back up photos, contacts and WhatsApp chats.',
                  'Sign out of the Google or Apple account - otherwise the '
                      'phone stays locked for the next person, and your '
                      'account stays tied to it.',
                  'Sign out of banking and UPI apps, and check WhatsApp\'s '
                      '"linked devices" and remove them.',
                  'Do a "factory reset" from settings.',
                  'Take out the SIM card and the memory card.',
                ],
        ),
        const SizedBox(height: 14),
        Text(hi ? 'कहाँ दें' : 'Where it goes',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'कंपनी का वापसी कार्यक्रम — ई-कचरा नियमों में बनाने वाली कंपनी पर '
                      'पुराना सामान वापस लेने की ज़िम्मेदारी है। ब्रांड की वेबसाइट या '
                      'सर्विस सेंटर पर पूछें',
                  'अधिकृत ई-कचरा संग्रह केंद्र — इनकी सूची केंद्रीय प्रदूषण नियंत्रण '
                      'बोर्ड की वेबसाइट पर है',
                  'नगर पालिका का ई-कचरा या विशेष देखभाल वाला संग्रह केंद्र',
                  'घर के सेल और बैटरी भी इन्हीं जगहों पर; कई दुकानें पुरानी बैटरी '
                      'लेने का डिब्बा रखती हैं',
                ]
              : const [
                  'The company\'s take-back programme - the e-waste rules make '
                      'the maker responsible for taking old products back. Ask '
                      'on the brand\'s site or at the service centre',
                  'An authorised e-waste collection centre - the list is on '
                      'the Central Pollution Control Board\'s site',
                  'The municipality\'s e-waste or special care collection '
                      'point',
                  'Household cells and batteries go to the same places; many '
                      'shops keep a box for old batteries',
                ],
        ),
        const SizedBox(height: 12),
        ToolDonts(
          heading: hi ? 'न करें' : 'Do not',
          items: hi
              ? const [
                  'गीले या सूखे कचरे में न डालें',
                  'तार जलाकर ताँबा न निकालें — उसका धुआँ ज़हरीला है',
                  'बैटरी न तोड़ें, न आग में डालें',
                  'पुराना फ़ोन ख़रीदने से पहले संचार साथी पर उसका आईएमईआई जाँचें — '
                      'चोरी का फ़ोन ब्लॉक हो सकता है',
                ]
              : const [
                  'Do not put it in the wet or dry bin',
                  'Do not burn cables to get the copper out - the smoke is '
                      'toxic',
                  'Do not break a battery or put it in a fire',
                  'Before buying a used phone, check its IMEI on Sanchar '
                      'Saathi - a stolen phone can be blocked',
                ],
        ),
        const SourceNote(text: 'Central Pollution Control Board', url: _cpcbUrl),
        const SourceNote(text: 'Sanchar Saathi', url: _sancharUrl),
      ],
    );
  }
}
