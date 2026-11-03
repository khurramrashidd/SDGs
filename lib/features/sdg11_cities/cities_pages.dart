import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/guide_list_page.dart';
import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import 'cities_tools.dart';

/// SDG 11 — Sustainable Cities and Communities.
class CitiesHomePage extends StatelessWidget {
  const CitiesHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    return ModuleHub(
      goal: 11,
      titleKey: 'sdg11_title',
      children: [
        HubHero(
          goal: 11,
          title: hi
              ? 'गली की समस्या, ऐसी शिकायत जिसका जवाब आए'
              : 'A street problem, and a complaint that gets answered',
          body: hi
              ? 'कूड़ा, स्ट्रीटलाइट, पानी, नाली, सड़क। समस्या चुनें, जगह लिखें — तैयार '
                  'शिकायत कॉपी करें, और अगर कुछ न हो तो किससे आगे शिकायत करें।'
              : 'Garbage, streetlights, water, drains, roads. Pick the '
                  'problem, type the place, copy a ready complaint — and see '
                  'who to go to next if nothing happens.',
          button: hi ? 'शिकायत लिखें' : 'Write the complaint',
          icon: Icons.edit_note_outlined,
          onTap: () => pushScoped(context, const CivicComplaintPage()),
        ),
        HubLabel(hi ? 'घर' : 'Housing'),
        HubRow(
          icon: Icons.house_outlined,
          title: hi
              ? 'प्रधानमंत्री आवास — क्या आप पात्र हैं?'
              : 'PM Awas Yojana — do you qualify?',
          subtitle: hi
              ? 'शहर या गाँव, आय, ज़मीन — कौन सा हिस्सा आपके लिए'
              : 'Town or village, income, land — which part fits you',
          onTap: () => pushScoped(context, const HousingFitPage()),
        ),
        HubRow(
          icon: Icons.description_outlined,
          title: hi ? 'ज़मीन-मकान के काग़ज़' : 'Property papers',
          subtitle: hi
              ? 'दाख़िल-ख़ारिज, टैक्स रसीद — विवाद से बचाव'
              : 'Mutation, tax receipts — avoiding a dispute',
          onTap: () => pushScoped(
            context,
            const GuideListPage(
              collection: 'cities',
              category: 'property',
              title: 'Property papers',
              titleHi: 'ज़मीन-मकान के काग़ज़',
              goal: 11,
            ),
          ),
        ),
        HubLabel(hi ? 'आपदा की तैयारी' : 'Be ready for a disaster'),
        HubRow(
          icon: Icons.flood_outlined,
          title: hi ? 'बाढ़, भूकंप, बिजली' : 'Flood, earthquake, lightning',
          subtitle: hi
              ? 'पहले, दौरान और बाद में क्या करें'
              : 'What to do before, during and after',
          onTap: () => pushScoped(
            context,
            const GuideListPage(
              collection: 'cities',
              category: 'disaster',
              title: 'Disaster readiness',
              titleHi: 'आपदा की तैयारी',
              goal: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class HousingFitPage extends StatefulWidget {
  const HousingFitPage({super.key});

  @override
  State<HousingFitPage> createState() => _HousingFitPageState();
}

class _HousingFitPageState extends State<HousingFitPage> {
  Area? _area;
  bool? _owns;
  HouseIncome? _income;
  HousingNeed? _need;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final urban = _area == Area.urban;
    final done = _area != null &&
        _owns != null &&
        (_owns == true ||
            _area == Area.rural ||
            (_income != null &&
                (_income == HouseIncome.above9Lakh || _need != null)));

    Widget pick<T>(T v, T? cur, String en, String h, void Function(T) assign) =>
        SelectionTile(
          label: hi ? h : en,
          selected: cur == v,
          onTap: () => setState(() => assign(v)),
        );

    return ToolScaffold(
      goal: 11,
      title: hi ? 'प्रधानमंत्री आवास' : 'PM Awas Yojana',
      children: [
        ToolQuestion(hi ? 'आप कहाँ रहते हैं?' : 'Where do you live?'),
        pick(Area.urban, _area, 'A town or city', 'क़स्बा या शहर',
            (v) => _area = v),
        pick(Area.rural, _area, 'A village', 'गाँव', (v) => _area = v),
        ToolQuestion(hi
            ? 'क्या परिवार में किसी का भारत में कहीं पक्का मकान है?'
            : 'Does anyone in the family own a pucca house anywhere in India?'),
        pick(true, _owns, 'Yes', 'हाँ', (v) => _owns = v),
        pick(false, _owns, 'No', 'नहीं', (v) => _owns = v),
        if (urban && _owns == false) ...[
          ToolQuestion(hi ? 'परिवार की सालाना आय' : "Family's yearly income"),
          pick(HouseIncome.upTo3Lakh, _income, 'Up to Rs 3 lakh',
              '3 लाख रुपये तक', (v) => _income = v),
          pick(HouseIncome.upTo6Lakh, _income, 'Rs 3 to 6 lakh',
              '3 से 6 लाख रुपये', (v) => _income = v),
          pick(HouseIncome.upTo9Lakh, _income, 'Rs 6 to 9 lakh',
              '6 से 9 लाख रुपये', (v) => _income = v),
          pick(HouseIncome.above9Lakh, _income, 'More than Rs 9 lakh',
              '9 लाख रुपये से ज़्यादा', (v) => _income = v),
        ],
        if (urban && _owns == false && _income != null &&
            _income != HouseIncome.above9Lakh) ...[
          ToolQuestion(hi ? 'आप क्या चाहते हैं?' : 'What do you want to do?'),
          pick(HousingNeed.buildOnOwnLand, _need,
              'Build on land we own', 'अपनी ज़मीन पर बनाना',
              (v) => _need = v),
          pick(HousingNeed.buy, _need, 'Buy a house or flat',
              'मकान या फ़्लैट ख़रीदना', (v) => _need = v),
          pick(HousingNeed.rent, _need, 'Rent near work', 'काम के पास किराया',
              (v) => _need = v),
        ],
        if (done)
          AdviceList(
            heading: hi ? 'आपके लिए' : 'For you',
            items: housingFit(
              area: _area!,
              ownsPucca: _owns!,
              income: _income ?? HouseIncome.upTo3Lakh,
              need: _need ?? HousingNeed.buy,
            ),
          ),
      ],
    );
  }
}

class CivicComplaintPage extends StatefulWidget {
  const CivicComplaintPage({super.key});

  @override
  State<CivicComplaintPage> createState() => _CivicComplaintPageState();
}

class _CivicComplaintPageState extends State<CivicComplaintPage> {
  CivicIssue? _issue;
  Area _area = Area.urban;
  final _place = TextEditingController();
  final _since = TextEditingController();

  @override
  void dispose() {
    _place.dispose();
    _since.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;
    final draft = _issue == null
        ? null
        : draftComplaint(
            issue: _issue!,
            place: _place.text,
            since: _since.text,
            hi: hi,
          );

    return ToolScaffold(
      goal: 11,
      title: hi ? 'शिकायत लिखें' : 'Write the complaint',
      children: [
        ToolQuestion(hi ? 'समस्या क्या है?' : 'What is the problem?'),
        for (final i in CivicIssue.values)
          SelectionTile(
            label: hi ? issueHi(i) : issueEn(i),
            selected: _issue == i,
            onTap: () => setState(() => _issue = i),
          ),
        ToolQuestion(hi ? 'कहाँ?' : 'Where?'),
        SegmentedButton<Area>(
          segments: [
            ButtonSegment(
                value: Area.urban, label: Text(hi ? 'शहर/क़स्बा' : 'Town')),
            ButtonSegment(
                value: Area.rural, label: Text(hi ? 'गाँव' : 'Village')),
          ],
          selected: {_area},
          onSelectionChanged: (s) => setState(() => _area = s.first),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _place,
          maxLength: 120,
          decoration: InputDecoration(
            labelText: hi ? 'जगह (गली, मोहल्ला, पास की पहचान)' : 'Place (street, ward, a landmark)',
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        TextField(
          controller: _since,
          maxLength: 40,
          decoration: InputDecoration(
            labelText: hi ? 'कब से (जैसे: 10 दिन से)' : 'Since when (e.g. 10 days)',
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        if (draft != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(draft,
                style: const TextStyle(fontSize: 14, height: 1.5)),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: draft));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(hi ? 'कॉपी हो गया' : 'Copied')));
            },
            icon: const Icon(Icons.copy),
            label: Text(hi ? 'शिकायत कॉपी करें' : 'Copy the complaint'),
          ),
          AdviceList(
            heading: hi ? 'कुछ न हो तो, इसी क्रम में' : 'If nothing happens, in this order',
            items: escalation(_area, _issue!),
          ),
        ],
      ],
    );
  }
}
