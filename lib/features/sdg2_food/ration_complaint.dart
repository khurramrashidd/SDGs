import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/sdg/advice.dart';
import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';
import '../sdg1_schemes/ration_tool.dart';

/// A complaint about a ration shop, written so it names the entitlement.
///
/// A complaint that says "he gave me less" is an argument about memory. A
/// complaint that says "my card is for five people, which is 25 kg under
/// the National Food Security Act, and I was given 18 kg on 4 March"
/// is a fact the office has to answer. So the screen works out the
/// entitlement first and puts it in the letter.
enum ShopProblem {
  lessThanDue,
  refused,
  overcharged,
  closed,
  keptCard,
  noReceipt,
}

String problemEn(ShopProblem p) => switch (p) {
      ShopProblem.lessThanDue => 'gave less grain than my card is due',
      ShopProblem.refused => 'refused to give any grain',
      ShopProblem.overcharged => 'charged more than the fixed price',
      ShopProblem.closed => 'keeps the shop shut on the days it should open',
      ShopProblem.keptCard => 'is holding my ration card at the shop',
      ShopProblem.noReceipt => 'refuses to give a receipt',
    };

String problemHi(ShopProblem p) => switch (p) {
      ShopProblem.lessThanDue => 'कार्ड पर बनने वाले अनाज से कम दिया',
      ShopProblem.refused => 'अनाज देने से मना कर दिया',
      ShopProblem.overcharged => 'तय दाम से ज़्यादा पैसे लिए',
      ShopProblem.closed => 'दुकान खुलने के दिनों में बंद रखता है',
      ShopProblem.keptCard => 'मेरा राशन कार्ड दुकान पर रख लिया है',
      ShopProblem.noReceipt => 'रसीद देने से मना करता है',
    };

const _nfsaUrl = 'https://nfsa.gov.in/portal/Coverage_Entitlements_NFSA_AA';

const _vigilance = Advice(
  title: 'The committee that is meant to watch the shop',
  titleHi: 'वह समिति जिसे दुकान पर नज़र रखनी है',
  body: 'Every fair price shop is supposed to have a Vigilance Committee '
      'with cardholders on it, and the shop is meant to display its stock '
      'and rates on a board outside. If neither exists, say so in the '
      'complaint: it is itself a failure of the scheme and it tells the '
      'officer that this is not a one-off argument.',
  bodyHi: 'हर उचित दर दुकान के साथ एक सतर्कता समिति होनी चाहिए जिसमें कार्डधारक '
      'शामिल हों, और दुकान के बाहर स्टॉक और दाम का बोर्ड लगा होना चाहिए। अगर दोनों '
      'नहीं हैं, तो शिकायत में यह भी लिखें: यह अपने आप में योजना की नाकामी है और '
      'अधिकारी को बताता है कि यह एक दिन की तकरार नहीं है।',
  source: _nfsaUrl,
);

const _helpline = Advice(
  title: 'The toll-free number, and why to call it as well',
  titleHi: 'निःशुल्क नंबर, और उस पर भी क्यों कॉल करें',
  body: 'Every state runs a toll-free food helpline; 1967 works in most. '
      'Call it as well as writing, because the call creates a numbered '
      'record in a system the local officer does not control. Note the '
      'complaint number they give you.',
  bodyHi: 'हर राज्य एक निःशुल्क खाद्य हेल्पलाइन चलाता है; ज़्यादातर जगह 1967 चलता है। '
      'लिखने के साथ कॉल भी करें, क्योंकि कॉल से एक संख्या वाला रिकॉर्ड ऐसी व्यवस्था में '
      'बनता है जो स्थानीय अधिकारी के हाथ में नहीं है। जो शिकायत संख्या मिले, लिख लें।',
  source: _nfsaUrl,
  phone: '1967',
);

const _escalate = Advice(
  title: 'If the office does nothing',
  titleHi: 'अगर दफ़्तर कुछ न करे',
  body: 'The Act requires every district to have a Grievance Redressal '
      'Officer, and every state a Food Commission above that. Take the '
      'complaint there with the dated receipt of the first one. An RTI '
      'asking for the shop\'s stock register and allocation for those '
      'months is the step that usually settles it, because the register '
      'either matches what you were given or it does not.',
  bodyHi: 'क़ानून के तहत हर ज़िले में एक शिकायत निवारण अधिकारी और हर राज्य में उससे '
      'ऊपर एक खाद्य आयोग होना चाहिए। पहली शिकायत की दिनांकित पावती के साथ वहाँ जाएँ। '
      'उन महीनों का दुकान का स्टॉक रजिस्टर और आवंटन माँगती आरटीआई अक्सर मामला तय कर '
      'देती है, क्योंकि रजिस्टर या तो आपको दिए गए अनाज से मेल खाएगा या नहीं खाएगा।',
  source: _nfsaUrl,
);

class RationComplaintPage extends StatefulWidget {
  const RationComplaintPage({super.key});

  @override
  State<RationComplaintPage> createState() => _RationComplaintPageState();
}

class _RationComplaintPageState extends State<RationComplaintPage> {
  final _selected = <ShopProblem>{};
  RationCategory _category = RationCategory.priority;
  final _people = TextEditingController(text: '4');
  final _given = TextEditingController();
  final _name = TextEditingController();
  final _card = TextEditingController();
  final _shop = TextEditingController();
  DateTime? _when;

  @override
  void dispose() {
    for (final c in [_people, _given, _name, _card, _shop]) {
      c.dispose();
    }
    super.dispose();
  }

  String _draft(bool hi) {
    final people = int.tryParse(_people.text.trim()) ?? 0;
    final due = nfsaKgPerMonth(_category, people);
    final given = _given.text.trim();
    final name =
        _name.text.trim().isEmpty ? (hi ? '[नाम]' : '[name]') : _name.text.trim();
    final card = _card.text.trim().isEmpty
        ? (hi ? '[राशन कार्ड संख्या]' : '[ration card number]')
        : _card.text.trim();
    final shop = _shop.text.trim().isEmpty
        ? (hi ? '[दुकान का नाम या संख्या]' : '[shop name or number]')
        : _shop.text.trim();
    final when = _when == null
        ? (hi ? '[तारीख़]' : '[date]')
        : DateFormat('d MMM yyyy').format(_when!);
    final today = DateFormat('d MMM yyyy').format(DateTime.now());
    final problems = _selected
        .map((p) => hi ? problemHi(p) : problemEn(p))
        .join(hi ? '; ' : '; ');

    if (hi) {
      final b = StringBuffer()
        ..writeln('सेवा में,')
        ..writeln('ज़िला आपूर्ति अधिकारी / शिकायत निवारण अधिकारी')
        ..writeln()
        ..writeln('दिनांक: $today')
        ..writeln()
        ..writeln('विषय: उचित दर दुकान $shop के विरुद्ध शिकायत')
        ..writeln()
        ..writeln('महोदय/महोदया,')
        ..writeln()
        ..writeln('मैं $name, राशन कार्ड संख्या $card का धारक हूँ। '
            'दिनांक $when को उचित दर दुकान $shop पर मेरे साथ यह हुआ: $problems।');
      if (due != null) {
        b
          ..writeln()
          ..writeln('राष्ट्रीय खाद्य सुरक्षा अधिनियम, 2013 के तहत मेरे कार्ड पर '
              'हर महीने $due किलो अनाज बनता है'
              '${given.isEmpty ? '' : ', जबकि मुझे $given किलो दिया गया'}।');
      }
      b
        ..writeln()
        ..writeln('कृपया जाँच कराकर मेरा बनता हुआ अनाज दिलाएँ और दुकान के विरुद्ध '
            'नियमानुसार कार्रवाई करें। कृपया इस शिकायत की संख्या और की गई कार्रवाई '
            'मुझे लिखित में बताएँ।')
        ..writeln()
        ..writeln('धन्यवाद,')
        ..writeln(name)
        ..writeln('राशन कार्ड: $card')
        ..write('मोबाइल: [नंबर]');
      return b.toString();
    }

    final b = StringBuffer()
      ..writeln('To,')
      ..writeln('The District Supply Officer / Grievance Redressal Officer')
      ..writeln()
      ..writeln('Date: $today')
      ..writeln()
      ..writeln('Subject: Complaint against fair price shop $shop')
      ..writeln()
      ..writeln('Sir/Madam,')
      ..writeln()
      ..writeln('I am $name, holder of ration card number $card. On $when, '
          'at fair price shop $shop, the dealer $problems.');
    if (due != null) {
      b
        ..writeln()
        ..writeln('Under the National Food Security Act, 2013 my card is '
            'entitled to $due kg of foodgrain a month'
            '${given.isEmpty ? '' : ', while I was given $given kg'}.');
    }
    b
      ..writeln()
      ..writeln('Please have this inquired into, have my due entitlement '
          'released, and take action against the shop under the rules. '
          'Please tell me in writing the complaint number and the action '
          'taken.')
      ..writeln()
      ..writeln('Thank you,')
      ..writeln(name)
      ..writeln('Ration card: $card')
      ..write('Mobile: [number]');
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final fmt = DateFormat('d MMM yyyy');
    final people = int.tryParse(_people.text.trim()) ?? 0;
    final due = nfsaKgPerMonth(_category, people);
    final given = double.tryParse(_given.text.trim());

    return ToolScaffold(
      goal: 2,
      title: hi ? 'राशन दुकान की शिकायत' : 'Complain about a ration shop',
      children: [
        ToolNote(hi
            ? '"कम दिया" कहना याददाश्त की बहस है। "मेरे कार्ड पर 25 किलो बनता है और '
                '4 मार्च को 18 किलो मिला" एक तथ्य है, जिसका जवाब देना पड़ता है। इसलिए '
                'यहाँ पहले हक़ का हिसाब लगता है।'
            : '"He gave me less" is an argument about memory. "My card is '
                'due 25 kg and I was given 18 kg on 4 March" is a fact that '
                'has to be answered. So this works out the entitlement '
                'first.'),
        ToolQuestion(hi ? 'क्या हुआ?' : 'What happened?'),
        for (final p in ShopProblem.values)
          CheckboxListTile(
            value: _selected.contains(p),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(hi ? problemHi(p) : problemEn(p),
                style: const TextStyle(fontSize: 14.5, height: 1.35)),
            onChanged: (v) => setState(() {
              v == true ? _selected.add(p) : _selected.remove(p);
            }),
          ),
        if (_selected.contains(ShopProblem.lessThanDue)) ...[
          ToolQuestion(hi ? 'आपका हक़ कितना है' : 'What you are due'),
          SelectionTile(
            label: hi ? 'अंत्योदय कार्ड' : 'Antyodaya card',
            selected: _category == RationCategory.aay,
            onTap: () => setState(() => _category = RationCategory.aay),
          ),
          SelectionTile(
            label: hi ? 'प्राथमिकता कार्ड' : 'Priority card',
            selected: _category == RationCategory.priority,
            onTap: () => setState(() => _category = RationCategory.priority),
          ),
          if (_category == RationCategory.priority)
            ToolNumber(
              controller: _people,
              label: hi ? 'कार्ड पर सदस्य' : 'Members on the card',
              maxDigits: 2,
              onChanged: (_) => setState(() {}),
            ),
          ToolNumber(
            controller: _given,
            label: hi ? 'कितना दिया गया' : 'How much was given',
            suffix: 'kg',
            decimal: true,
            maxDigits: 5,
            onChanged: (_) => setState(() {}),
          ),
          if (due != null)
            ToolAnswer(
              headline: given != null && given < due
                  ? (hi
                      ? '${(due - given).toStringAsFixed(1)} किलो कम दिया गया'
                      : '${(due - given).toStringAsFixed(1)} kg short')
                  : (hi ? 'आपका हक़: $due किलो' : 'You are due $due kg'),
              detail: hi
                  ? 'यही आँकड़ा नीचे की शिकायत में अपने आप चला जाता है।'
                  : 'This figure goes into the complaint below on its own.',
              tone: given != null && given < due
                  ? ToolTone.bad
                  : ToolTone.plain,
              icon: Icons.scale_outlined,
            ),
        ],
        ToolQuestion(hi ? 'शिकायत के लिए' : 'For the complaint'),
        ToolText(
            controller: _name,
            label: hi ? 'आपका नाम' : 'Your name',
            onChanged: (_) => setState(() {})),
        ToolText(
            controller: _card,
            label: hi ? 'राशन कार्ड संख्या' : 'Ration card number',
            maxLength: 30,
            onChanged: (_) => setState(() {})),
        ToolText(
            controller: _shop,
            label: hi ? 'दुकान का नाम या संख्या' : 'Shop name or number',
            onChanged: (_) => setState(() {})),
        OutlinedButton.icon(
          onPressed: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: DateTime(now.year - 1),
              lastDate: now,
            );
            if (picked != null) setState(() => _when = picked);
          },
          icon: const Icon(Icons.event),
          label: Text(_when == null
              ? (hi ? 'यह किस दिन हुआ' : 'The day it happened')
              : fmt.format(_when!)),
        ),
        if (_selected.isNotEmpty) ...[
          CopyBlock(
            text: _draft(hi),
            note: hi
                ? 'दो प्रतियाँ बनाएँ। एक ज़िला आपूर्ति कार्यालय में जमा करें और दूसरी पर '
                    'पावती लें। मोबाइल नंबर अपने हाथ से भरें।'
                : 'Make two copies. Hand one in at the district supply '
                    'office and get the other receipted. Fill in your mobile '
                    'number by hand.',
          ),
          AdviceList(
            heading: hi ? 'साथ में ये भी करें' : 'Do these as well',
            items: const [_helpline, _vigilance, _escalate],
          ),
        ],
      ],
    );
  }
}
