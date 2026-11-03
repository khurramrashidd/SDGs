import 'package:flutter/material.dart';

import '../../core/widgets/guide_list_page.dart';
import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import 'land_tools.dart';

/// SDG 15 — Life on Land.
class LandHomePage extends StatelessWidget {
  const LandHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    return ModuleHub(
      goal: 15,
      titleKey: 'sdg15_title',
      children: [
        HubHero(
          goal: 15,
          title: hi
              ? 'जंगल की ज़मीन पर आपका हक़'
              : 'Your rights to forest land',
          body: hi
              ? 'वन अधिकार क़ानून, 2006 के तहत पीढ़ियों से जंगल में रहने वाले परिवार और गाँव '
                  'ज़मीन और जंगल पर हक़ का दावा कर सकते हैं। कुछ सवालों से जानें कि कौन सा दावा '
                  'और कैसे।'
              : 'Under the Forest Rights Act, 2006, families and villages who '
                  'have lived in the forest for generations can claim rights '
                  'to land and forest. A few questions show which claim, and how.',
          button: hi ? 'जाँचें' : 'Check',
          icon: Icons.forest_outlined,
          onTap: () => pushScoped(context, const ForestRightsPage()),
        ),
        HubLabel(hi ? 'जंगल और खेत' : 'Forest and farm'),
        HubRow(
          icon: Icons.pets_outlined,
          title: hi ? 'जंगली जानवर से नुक़सान' : 'Harm from wild animals',
          subtitle: hi
              ? 'मौत, चोट, फ़सल — सूचना और मुआवज़ा'
              : 'Death, injury, crops — reporting and compensation',
          onTap: () => pushScoped(
            context,
            const GuideListPage(
              collection: 'land',
              category: 'wildlife',
              title: 'Wild animal conflict',
              titleHi: 'जंगली जानवरों से टकराव',
              goal: 15,
            ),
          ),
        ),
        HubRow(
          icon: Icons.grass_outlined,
          title: hi ? 'मिट्टी की सेहत' : 'Soil health',
          subtitle: hi
              ? 'मृदा स्वास्थ्य कार्ड और उसे कैसे पढ़ें'
              : 'Soil Health Card and how to read it',
          onTap: () => pushScoped(
            context,
            const GuideListPage(
              collection: 'land',
              category: 'soil',
              title: 'Soil health',
              titleHi: 'मिट्टी की सेहत',
              goal: 15,
            ),
          ),
        ),
      ],
    );
  }
}

class ForestRightsPage extends StatefulWidget {
  const ForestRightsPage({super.key});

  @override
  State<ForestRightsPage> createState() => _ForestRightsPageState();
}

class _ForestRightsPageState extends State<ForestRightsPage> {
  Claimant? _who;
  bool? _before;
  bool? _generations;
  final _wants = <Claim>{};

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final needGenerations = _who == Claimant.nonSt && _before == true;
    final done = _who != null &&
        _before != null &&
        (!needGenerations || _generations != null) &&
        (_before == false ||
            (needGenerations && _generations == false) ||
            _wants.isNotEmpty);

    Widget yesNo(bool? cur, void Function(bool) assign) => Column(children: [
          SelectionTile(
            label: hi ? 'हाँ' : 'Yes',
            selected: cur == true,
            onTap: () => setState(() => assign(true)),
          ),
          SelectionTile(
            label: hi ? 'नहीं' : 'No',
            selected: cur == false,
            onTap: () => setState(() => assign(false)),
          ),
        ]);

    Widget want(Claim c, String en, String h) => CheckboxListTile(
          value: _wants.contains(c),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(hi ? h : en),
          onChanged: (v) => setState(() {
            v == true ? _wants.add(c) : _wants.remove(c);
          }),
        );

    return ToolScaffold(
      goal: 15,
      title: hi ? 'वन अधिकार' : 'Forest rights',
      children: [
        ToolQuestion(hi ? 'दावा कौन कर रहा है?' : 'Who is claiming?'),
        SelectionTile(
          label: hi
              ? 'इस इलाक़े में अनुसूचित जनजाति का परिवार या गाँव'
              : 'A Scheduled Tribe family or village, in this area',
          selected: _who == Claimant.stHere,
          onTap: () => setState(() => _who = Claimant.stHere),
        ),
        SelectionTile(
          label: hi ? 'कोई और परिवार या गाँव' : 'Any other family or village',
          selected: _who == Claimant.nonSt,
          onTap: () => setState(() => _who = Claimant.nonSt),
        ),
        ToolQuestion(hi
            ? 'क्या 13 दिसंबर 2005 से पहले से जंगल की ज़मीन पर रह रहे थे और उस पर निर्भर थे?'
            : 'Were you living on and depending on forest land before 13 December 2005?'),
        yesNo(_before, (v) => _before = v),
        if (needGenerations) ...[
          ToolQuestion(hi
              ? 'क्या 2005 से पहले तीन पीढ़ियों (75 साल) से वहाँ रह रहे थे?'
              : 'Had the family lived there for three generations (75 years) before 2005?'),
          yesNo(_generations, (v) => _generations = v),
        ],
        if (_before == true && (!needGenerations || _generations == true)) ...[
          ToolQuestion(hi ? 'किस चीज़ का दावा?' : 'What do you want to claim?'),
          want(Claim.ownLand, 'Land our family cultivates',
              'जिस ज़मीन पर परिवार खेती करता है'),
          want(Claim.villageUse,
              'Village use: grazing, forest produce, water',
              'गाँव का उपयोग: चराई, वनोपज, पानी'),
          want(Claim.villageForest,
              'The village forest, to protect and manage',
              'गाँव का जंगल, रक्षा और प्रबंधन के लिए'),
        ],
        if (done)
          AdviceList(
            heading: hi ? 'क्या करें' : 'What to do',
            items: forestRights(
              who: _who!,
              before2005: _before!,
              threeGenerations: _generations ?? false,
              wants: _wants,
            ),
          ),
      ],
    );
  }
}
