import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/guide_list_page.dart';
import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import 'ocean_tools.dart';

/// SDG 14 — Life Below Water.
class OceanHomePage extends StatelessWidget {
  const OceanHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    return ModuleHub(
      goal: 14,
      titleKey: 'sdg14_title',
      children: [
        HubHero(
          goal: 14,
          title: hi
              ? 'क्या आज मछली पकड़ने पर रोक है?'
              : 'Is the fishing ban on today?',
          body: hi
              ? 'अपना तट चुनें — हम बताएँगे कि 61 दिन की मानसूनी रोक चल रही है या नहीं, '
                  'कितने दिन बचे हैं, या कब शुरू होगी।'
              : 'Pick your coast and see whether the 61-day monsoon ban is on, '
                  'how many days are left, or when it starts.',
          button: hi ? 'तारीख़ें देखें' : 'Check the dates',
          icon: Icons.sailing_outlined,
          onTap: () => pushScoped(context, const FishingBanPage()),
        ),
        HubLabel(hi ? 'समुद्र में सुरक्षा और मदद' : 'Safety and help at sea'),
        HubRow(
          icon: Icons.support_outlined,
          title: hi ? 'समुद्र में मुसीबत' : 'In trouble at sea',
          subtitle: hi
              ? 'तटरक्षक 1554, मौसम चेतावनी, रोक के दौरान सहायता'
              : 'Coast Guard 1554, weather warnings, support during the ban',
          onTap: () => pushScoped(
            context,
            const GuideListPage(
              collection: 'ocean',
              category: 'safety',
              title: 'Safety at sea',
              titleHi: 'समुद्र में सुरक्षा',
              goal: 14,
            ),
          ),
        ),
        HubRow(
          icon: Icons.report_gmailerrorred_outlined,
          title: hi ? 'प्रदूषण की सूचना दें' : 'Report pollution',
          subtitle: hi
              ? 'तेल, मरी मछलियाँ, तट पर कचरा'
              : 'Oil, dead fish, waste on the shore',
          onTap: () => pushScoped(
            context,
            const GuideListPage(
              collection: 'ocean',
              category: 'report',
              title: 'Report pollution',
              titleHi: 'प्रदूषण की सूचना',
              goal: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class FishingBanPage extends StatefulWidget {
  const FishingBanPage({super.key});

  @override
  State<FishingBanPage> createState() => _FishingBanPageState();
}

class _FishingBanPageState extends State<FishingBanPage> {
  Coast? _coast;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final scheme = Theme.of(context).colorScheme;
    final fmt = DateFormat('d MMM yyyy');
    final status = _coast == null ? null : banStatus(_coast!, DateTime.now());

    return ToolScaffold(
      goal: 14,
      title: hi ? 'मछली पकड़ने पर रोक' : 'Fishing ban',
      children: [
        ToolQuestion(hi ? 'आपका तट' : 'Your coast'),
        SelectionTile(
          label: hi
              ? 'पूर्वी तट — पश्चिम बंगाल, ओडिशा, आंध्र प्रदेश, तमिलनाडु, पुडुचेरी, अंडमान-निकोबार'
              : 'East coast — West Bengal, Odisha, Andhra Pradesh, Tamil Nadu, Puducherry, Andaman & Nicobar',
          selected: _coast == Coast.east,
          onTap: () => setState(() => _coast = Coast.east),
        ),
        SelectionTile(
          label: hi
              ? 'पश्चिमी तट — गुजरात, महाराष्ट्र, गोवा, कर्नाटक, केरल, लक्षद्वीप'
              : 'West coast — Gujarat, Maharashtra, Goa, Karnataka, Kerala, Lakshadweep',
          selected: _coast == Coast.west,
          onTap: () => setState(() => _coast = Coast.west),
        ),
        if (status != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: status.active
                  ? scheme.errorContainer
                  : scheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.active
                      ? (hi
                          ? 'हाँ, रोक चल रही है — ${status.days} दिन बचे'
                          : 'Yes, the ban is on — ${status.days} days left')
                      : (hi
                          ? 'अभी रोक नहीं — ${status.days} दिन में शुरू'
                          : 'No ban now — it starts in ${status.days} days'),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: status.active
                          ? scheme.onErrorContainer
                          : scheme.onPrimaryContainer),
                ),
                const SizedBox(height: 6),
                Text(
                  '${fmt.format(status.window.start)} – ${fmt.format(status.window.end)}'
                  ' ($banDays ${hi ? 'दिन' : 'days'})',
                  style: TextStyle(
                      color: status.active
                          ? scheme.onErrorContainer
                          : scheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            hi
                ? 'यह केंद्र की रोक है, जो क्षेत्रीय जल (12 समुद्री मील) से आगे सभी मछली '
                    'पकड़ने वाले जहाज़ों पर लागू है। 12 समुद्री मील के भीतर आपका राज्य अपनी रोक '
                    'तय करता है, आमतौर पर इसी मौसम में — उसकी तारीख़ें और किन नावों को छूट है, '
                    'यह अपने मत्स्य विभाग की सूचना में देखें। रोक साल-दर-साल बदल सकती है।'
                : 'This is the central ban, on all fishing vessels beyond '
                    'territorial waters (12 nautical miles). Inside 12 '
                    'nautical miles your state sets its own ban, usually for '
                    'the same season — check your fisheries department notice '
                    'for its dates and which boats are exempt. Dates can be '
                    'changed in a given year.',
            style: TextStyle(height: 1.5, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          const GuideCard(row: {
            'title': 'Source: MPEDA, ban period',
            'titleHi': 'स्रोत: एमपीईडीए, रोक की अवधि',
            'body': 'Uniform 61-day ban in the Indian EEZ beyond territorial '
                'waters: east coast 15 April – 14 June, west coast 1 June – '
                '31 July.',
            'bodyHi': 'क्षेत्रीय जल से आगे भारतीय ईईज़ेड में 61 दिन की एक जैसी रोक: '
                'पूर्वी तट 15 अप्रैल – 14 जून, पश्चिमी तट 1 जून – 31 जुलाई।',
            'source': mpedaSource,
          }),
        ],
      ],
    );
  }
}
