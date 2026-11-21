import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Which ration card a household should hold, and how much grain that card
/// is worth each month.
///
/// Two separate confusions sit behind most ration complaints. The first is
/// that people do not know which card they are entitled to; the second is
/// that they do not know the quantity, so they cannot tell when they have
/// been short-changed. A dealer who hands over four kilos instead of five
/// is only caught by someone who knows it should be five.
///
/// The national entitlements are fixed by the National Food Security Act
/// and are the same everywhere:
///   Antyodaya (AAY) household: 35 kg per household per month
///   Priority household (PHH):   5 kg per person per month
/// States may add their own grain on top, and several do, which is why the
/// screen says the figure is a floor rather than a ceiling.
enum RationCategory { aay, priority, notCovered, unsure }

/// What the National Food Security Act guarantees this household monthly.
///
/// Returns null when the household is not covered, because a number would
/// imply an entitlement that does not exist.
int? nfsaKgPerMonth(RationCategory category, int people) {
  switch (category) {
    case RationCategory.aay:
      return 35; // per household, whatever its size
    case RationCategory.priority:
      return people <= 0 ? null : people * 5;
    case RationCategory.notCovered:
    case RationCategory.unsure:
      return null;
  }
}

class RationCardPage extends StatefulWidget {
  const RationCardPage({super.key});

  @override
  State<RationCardPage> createState() => _RationCardPageState();
}

class _RationCardPageState extends State<RationCardPage> {
  RationCategory? _category;
  final _people = TextEditingController(text: '4');

  @override
  void dispose() {
    _people.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final people = int.tryParse(_people.text.trim()) ?? 0;
    final kg = _category == null
        ? null
        : nfsaKgPerMonth(_category!, people);

    Widget pick(RationCategory c, String en, String h, String subEn,
            String subHi) =>
        SelectionTile(
          label: hi ? h : en,
          subtitle: (hi ? subHi : subEn).isEmpty ? null : (hi ? subHi : subEn),
          selected: _category == c,
          onTap: () => setState(() => _category = c),
        );

    return ToolScaffold(
      goal: 1,
      title: hi ? 'राशन कार्ड' : 'Ration card',
      children: [
        ToolNote(hi
            ? 'यह बताता है कि राष्ट्रीय खाद्य सुरक्षा क़ानून के तहत आपके कार्ड पर हर महीने '
                'कम से कम कितना अनाज बनता है। कई राज्य इससे ऊपर भी देते हैं।'
            : 'This shows the least your card is worth each month under the '
                'National Food Security Act. Several states give more on top.'),
        ToolQuestion(hi ? 'आपके पास कौन सा कार्ड है?' : 'Which card do you hold?'),
        pick(RationCategory.aay, 'Antyodaya (AAY)', 'अंत्योदय (एएवाई)',
            'Usually a yellow or pink card, for the poorest households',
            'आमतौर पर पीला या गुलाबी कार्ड, सबसे ग़रीब परिवारों के लिए'),
        pick(RationCategory.priority, 'Priority household (PHH)',
            'प्राथमिकता परिवार (पीएचएच)',
            'The common NFSA card, with each member named on it',
            'आम एनएफ़एसए कार्ड, जिस पर हर सदस्य का नाम होता है'),
        pick(RationCategory.notCovered, 'A card, but not under NFSA',
            'कार्ड है, पर एनएफ़एसए में नहीं',
            'Often called APL or a general card in your state',
            'राज्य में अक्सर एपीएल या सामान्य कार्ड कहा जाता है'),
        pick(RationCategory.unsure, 'No card, or not sure',
            'कार्ड नहीं, या पता नहीं', '', ''),
        if (_category == RationCategory.priority) ...[
          ToolQuestion(hi
              ? 'कार्ड पर कितने सदस्यों के नाम हैं?'
              : 'How many members are named on the card?'),
          ToolNumber(
            controller: _people,
            label: hi ? 'सदस्य' : 'Members',
            helper: hi
                ? 'वही गिनें जिनका नाम कार्ड पर दर्ज है, घर के सब लोग नहीं।'
                : 'Count only those actually named on the card, not everyone '
                    'in the house.',
            maxDigits: 2,
            icon: Icons.groups_outlined,
            onChanged: (_) => setState(() {}),
          ),
        ],
        if (kg != null)
          ToolAnswer(
            headline: hi
                ? 'हर महीने कम से कम $kg किलो अनाज'
                : 'At least $kg kg of grain every month',
            detail: _category == RationCategory.aay
                ? (hi
                    ? 'अंत्योदय कार्ड पर पूरे परिवार के लिए 35 किलो, चाहे परिवार में '
                        'कितने भी लोग हों।'
                    : 'An Antyodaya card gets 35 kg for the whole household, '
                        'however many people are in it.')
                : (hi
                    ? 'प्रति व्यक्ति 5 किलो × $people सदस्य। अगर कम मिले, तो यह आपका '
                        'हक़ छीना जाना है — नीचे देखें क्या करें।'
                    : '5 kg per person × $people members. Getting less than '
                        'this is your entitlement being denied — see below.'),
            tone: ToolTone.good,
            icon: Icons.rice_bowl_outlined,
          ),
        if (_category == RationCategory.notCovered)
          ToolAnswer(
            headline: hi
                ? 'इस कार्ड पर क़ानूनी अनाज का हक़ नहीं'
                : 'This card carries no legal grain entitlement',
            detail: hi
                ? 'एनएफ़एसए कार्ड के लिए अलग से आवेदन करें। यह क़ानून गाँव की 75% और '
                    'शहर की 50% आबादी तक को कवर करता है, इसलिए बहुत से परिवार जो सोचते '
                    'हैं कि वे पात्र नहीं हैं, असल में पात्र होते हैं।'
                : 'Apply separately for an NFSA card. The law covers up to '
                    '75% of the rural and 50% of the urban population, so '
                    'many families who assume they do not qualify do.',
            tone: ToolTone.warn,
            icon: Icons.info_outline,
          ),
        if (_category == RationCategory.unsure)
          ToolAnswer(
            headline: hi ? 'पहले यह पता करें' : 'Find this out first',
            detail: hi
                ? 'अपने राज्य के खाद्य विभाग के पोर्टल पर या राशन दुकान पर अपना नाम '
                    'खोजें। बिना कार्ड के, आवेदन उसी विभाग में होता है — कॉमन सर्विस '
                    'सेंटर मदद कर सकता है।'
                : 'Look your name up on your state food department portal or '
                    'at the ration shop. With no card, the application goes '
                    'to the same department — a Common Service Centre can '
                    'help you file it.',
            tone: ToolTone.plain,
            icon: Icons.help_outline,
          ),
        if (kg != null) ...[
          const SizedBox(height: 18),
          Text(hi ? 'दुकान पर यह भी याद रखें' : 'At the shop, also remember',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const ToolChecklist(
            storageKey: 'ration_rights_v1',
            items: [
              CheckItem('weigh', 'Ask to see the weighing',
                  'तौल अपनी आँखों से देखें',
                  noteEn: 'The shop must weigh in front of you.',
                  noteHi: 'दुकानदार को आपके सामने तौलना होता है।'),
              CheckItem('slip', 'Take the receipt or slip',
                  'रसीद या पर्ची लें',
                  noteEn: 'Without it there is nothing to complain with.',
                  noteHi: 'इसके बिना शिकायत का कोई आधार नहीं रहता।'),
              CheckItem('board', 'Check the rate board outside',
                  'बाहर लगा रेट बोर्ड देखें',
                  noteEn: 'Stock and prices must be displayed.',
                  noteHi: 'स्टॉक और दाम लिखा होना चाहिए।'),
              CheckItem('nodeposit', 'Your card must not be kept by the shop',
                  'दुकानदार आपका कार्ड अपने पास न रखे'),
            ],
          ),
        ],
        const SourceNote(
          text: 'Entitlements: National Food Security Act, 2013 — '
              'Department of Food and Public Distribution.',
          url: 'https://nfsa.gov.in/portal/Coverage_Entitlements_NFSA_AA',
        ),
      ],
    );
  }
}
