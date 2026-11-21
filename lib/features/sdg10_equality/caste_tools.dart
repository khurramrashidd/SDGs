import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Four screens on caste: the certificate, the atrocity case, being
/// refused service, and manual scavenging.
///
/// The relief figures under the SC/ST (Prevention of Atrocities) Rules are
/// minimums fixed in the 2016 amendment, paid in stages. They are stated
/// here because an informed family asks for the stage payment at the right
/// time, and because the first payment is tied to the FIR - which is the
/// single step most often not taken.

const _ncscUrl = 'https://ncsc.nic.in/';
const _nalsaUrl = 'https://nalsa.gov.in/';
const _namasteUrl = 'https://namaste.gov.in/';
const _poaRulesUrl =
    'https://socialjustice.gov.in/common/76662';

/// Minimum relief for a few of the commonest offences, from Annexure I to
/// the SC/ST (Prevention of Atrocities) Rules 1995 as amended in 2016.
/// Annexure I has over forty entries; these are the ones a village family
/// most often needs, and the screen says plainly that the rest exist.
const poaReliefInsultPublic = 100000;
const poaReliefTouching = 200000;
const poaReliefRape = 500000;
const poaReliefDeath = 825000;
const poaReliefBoycott = 100000;
const poaChargeSheetDays = 60;
const poaImmediateReliefDays = 7;

/// Supreme Court, Dr Balram Singh v Union of India (2023).
const sewerDeathCompensation = 3000000;
const sewerPermanentDisability = 2000000;
const sewerOtherDisability = 1000000;

// --- Caste certificate ------------------------------------------------

enum CasteStage { waiting, refused, lostOnline, wrongDetail }

class CasteCertificatePage extends StatefulWidget {
  const CasteCertificatePage({super.key});

  @override
  State<CasteCertificatePage> createState() => _CasteCertificatePageState();
}

class _CasteCertificatePageState extends State<CasteCertificatePage> {
  CasteStage? _stage;
  final _days = TextEditingController();
  final _receipt = TextEditingController();
  final _office = TextEditingController();

  @override
  void dispose() {
    _days.dispose();
    _receipt.dispose();
    _office.dispose();
    super.dispose();
  }

  String _letter(bool hi) {
    final receipt =
        _receipt.text.trim().isEmpty ? (hi ? '______' : '______') : _receipt.text.trim();
    final office =
        _office.text.trim().isEmpty ? (hi ? '______' : '______') : _office.text.trim();
    final days = _days.text.trim().isEmpty ? '____' : _days.text.trim();
    if (hi) {
      return 'सेवा में,\n'
          'अपीलीय अधिकारी, $office\n\n'
          'विषय: जाति प्रमाण पत्र के आवेदन पर निर्णय न होने के विरुद्ध अपील\n\n'
          'महोदय,\n\n'
          'मैंने जाति प्रमाण पत्र के लिए आवेदन किया था। आवेदन/रसीद संख्या '
          '$receipt है। आवेदन की तारीख़ से आज तक $days दिन बीत चुके हैं और मुझे '
          'न प्रमाण पत्र मिला है, न अस्वीकृति का कोई लिखित कारण।\n\n'
          'राज्य के लोक सेवा गारंटी/सेवा का अधिकार अधिनियम के अंतर्गत इस सेवा के '
          'लिए तय समय सीमा बीत चुकी है। अतः निवेदन है कि:\n\n'
          '1. मेरे आवेदन पर निर्णय कर प्रमाण पत्र जारी किया जाए; अथवा\n'
          '2. यदि आवेदन अस्वीकार किया जाता है तो उसका कारण लिखित में दिया जाए, '
          'जिससे मैं आगे अपील कर सकूँ।\n\n'
          'इस अपील की प्राप्ति रसीद देने की कृपा करें।\n\n'
          'दिनांक: ____________\n'
          'नाम: ____________\n'
          'पता: ____________\n'
          'फ़ोन: ____________\n'
          'हस्ताक्षर: ____________';
    }
    return 'To,\n'
        'The Appellate Authority, $office\n\n'
        'Subject: Appeal against non-decision on my caste certificate '
        'application\n\n'
        'Sir / Madam,\n\n'
        'I applied for a caste certificate. The application / receipt '
        'number is $receipt. $days days have passed since the date of '
        'application and I have received neither the certificate nor any '
        'written reason for rejection.\n\n'
        'The time limit fixed for this service under the state\'s Right to '
        'Public Service Act has expired. I therefore request that:\n\n'
        '1. my application be decided and the certificate issued; or\n'
        '2. if it is rejected, the reason be given to me in writing, so '
        'that I can appeal further.\n\n'
        'Kindly give me a receipt for this appeal.\n\n'
        'Date: ____________\n'
        'Name: ____________\n'
        'Address: ____________\n'
        'Phone: ____________\n'
        'Signature: ____________';
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 10,
      title: hi ? 'जाति प्रमाण पत्र मना या देर' : 'Caste certificate refused or delayed',
      children: [
        ToolNote(hi
            ? 'जाति प्रमाण पत्र राज्य सरकार देती है, और उसके लिए तय समय सीमा हर '
                'राज्य के "सेवा का अधिकार" या "लोक सेवा गारंटी" क़ानून में लिखी '
                'होती है। वह सीमा आम तौर पर आवेदन की रसीद पर ही छपी होती है — '
                'इसलिए यह ऐप कोई दिन की संख्या नहीं बताता, रसीद देखिए। जो हर जगह '
                'एक-सा है वह यह है: देर या मना होने पर अपील का हक़ है, और अपील '
                'मुफ़्त है।'
            : 'The caste certificate is issued by the state government, and '
                'the time limit for it is written in that state\'s Right to '
                'Service or Public Service Guarantee Act. That limit is '
                'usually printed on the application receipt itself - so this '
                'app names no number of days; look at the receipt. What is '
                'the same everywhere is this: a delay or a refusal carries a '
                'right of appeal, and the appeal is free.'),
        ToolQuestion(hi ? 'क्या हुआ है' : 'What has happened'),
        SelectionTile(
          label: hi ? 'आवेदन किया, कोई जवाब नहीं' : 'Applied, no answer',
          selected: _stage == CasteStage.waiting,
          onTap: () => setState(() => _stage = CasteStage.waiting),
        ),
        SelectionTile(
          label: hi ? 'मना कर दिया गया' : 'It was refused',
          selected: _stage == CasteStage.refused,
          onTap: () => setState(() => _stage = CasteStage.refused),
        ),
        SelectionTile(
          label: hi ? 'रसीद या आवेदन संख्या खो गई' : 'Lost the receipt or the number',
          selected: _stage == CasteStage.lostOnline,
          onTap: () => setState(() => _stage = CasteStage.lostOnline),
        ),
        SelectionTile(
          label: hi ? 'प्रमाण पत्र में कोई ब्योरा ग़लत है' : 'A detail on the certificate is wrong',
          selected: _stage == CasteStage.wrongDetail,
          onTap: () => setState(() => _stage = CasteStage.wrongDetail),
        ),
        if (_stage == CasteStage.waiting) ...[
          ToolQuestion(hi ? 'ब्योरा भरें' : 'Fill in the details'),
          ToolNumber(
            controller: _days,
            label: hi ? 'आवेदन के कितने दिन हो गए' : 'Days since you applied',
            maxDigits: 4,
            icon: Icons.schedule,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          ToolText(
            controller: _receipt,
            label: hi ? 'आवेदन या रसीद संख्या' : 'Application or receipt number',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          ToolText(
            controller: _office,
            label: hi ? 'कार्यालय (तहसील/एसडीएम)' : 'Office (tehsil / SDM)',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 4),
          ToolAnswer(
            headline: hi ? 'अपील का रास्ता' : 'The appeal route',
            detail: hi
                ? 'अपील का पहला पड़ाव उसी विभाग का अपीलीय अधिकारी होता है — आम तौर '
                    'पर एसडीएम या उपजिलाधिकारी। वहाँ से भी न हो तो दूसरी अपील '
                    'ज़िलाधिकारी के पास जाती है। दोनों पर कोई शुल्क नहीं लगता। नीचे '
                    'का पत्र कॉपी करके ले जाएँ, और रसीद ज़रूर लें — रसीद के बिना '
                    'अपील का कोई सबूत नहीं रहता।'
                : 'The first stop is the appellate authority in the same '
                    'department - usually the SDM or sub-divisional '
                    'officer. If that does not work, the second appeal goes '
                    'to the District Magistrate. Neither carries a fee. Copy '
                    'the letter below and take it there, and take a receipt '
                    '- without one there is no proof the appeal was made.',
            tone: ToolTone.plain,
            icon: Icons.gavel_outlined,
          ),
          const SizedBox(height: 10),
          CopyBlock(
            text: _letter(hi),
            note: hi
                ? 'दो नक़ल ले जाएँ: एक जमा करने के लिए, एक पर मुहर और तारीख़ लगवाकर '
                    'अपने पास रखने के लिए।'
                : 'Take two copies: one to submit, and one to get stamped '
                    'and dated for yourself.',
          ),
        ],
        if (_stage == CasteStage.refused)
          ToolAnswer(
            headline: hi ? 'लिखित कारण माँगें' : 'Ask for the reason in writing',
            detail: hi
                ? 'ज़ुबानी मना करना अपील के काम नहीं आता। लिखित कारण माँगिए — कारण '
                    'मिलने के बाद ही पता चलता है कि कमी काग़ज़ में है या किसी और बात '
                    'में, और तभी वह ठीक की जा सकती है। सबसे आम तीन कारण ये होते हैं: '
                    'पुराना निवास प्रमाण नहीं, पिता या दादा के नाम पर जाति का कोई '
                    'पुराना काग़ज़ नहीं, और नाम की हिज्जे में फ़र्क़। लिखित कारण न दें '
                    'तो उसी कार्यालय में सूचना का अधिकार का आवेदन लगाएँ — वह ₹10 में '
                    'होता है और जवाब देना पड़ता है।'
                : 'A refusal given by word of mouth is of no use in an '
                    'appeal. Ask for the reason in writing - only then do '
                    'you learn whether the gap is in a paper or in something '
                    'else, and only then can it be closed. The three '
                    'commonest reasons are: no old residence proof, no old '
                    'document showing the caste in the father\'s or '
                    'grandfather\'s name, and a difference in the spelling '
                    'of a name. If they will not put the reason in writing, '
                    'file a Right to Information application at the same '
                    'office - it costs ₹10 and has to be answered.',
            tone: ToolTone.warn,
            icon: Icons.edit_note_outlined,
          ),
        if (_stage == CasteStage.lostOnline)
          ToolAnswer(
            headline: hi ? 'संख्या वापस मिल सकती है' : 'The number can be recovered',
            detail: hi
                ? 'ज़्यादातर राज्यों के पोर्टल पर आवेदन की स्थिति उस मोबाइल नंबर या '
                    'आधार से देखी जा सकती है जिससे आवेदन हुआ था — "आवेदन की स्थिति" '
                    'या "ट्रैक" वाले पन्ने पर। न मिले तो जिस जन सेवा केंद्र या '
                    'ई-मित्र से आवेदन किया था, वहाँ उनके रिकॉर्ड में संख्या रहती है। '
                    'आगे के लिए: रसीद की फ़ोटो खींचकर रख लें।'
                : 'On most state portals the status of an application can be '
                    'seen from the mobile number or the Aadhaar it was filed '
                    'with - on the "track application" page. If not, the '
                    'common service centre or e-Mitra that filed it keeps the '
                    'number in its own record. For next time: photograph the '
                    'receipt.',
            tone: ToolTone.plain,
            icon: Icons.search,
          ),
        if (_stage == CasteStage.wrongDetail)
          ToolAnswer(
            headline: hi ? 'सुधार का आवेदन, देर न करें' : 'Apply for a correction, early',
            detail: hi
                ? 'नाम, पिता का नाम, जन्म तिथि या जाति के नाम की हिज्जे में फ़र्क़ '
                    'बाद में नौकरी या दाख़िले के समय बड़ी दिक़्क़त बनता है, और उस समय '
                    'ठीक कराने का वक़्त नहीं होता। उसी कार्यालय में सुधार का आवेदन '
                    'दें, साथ में वह काग़ज़ लगाएँ जिसमें सही लिखा है (आधार, स्कूल का '
                    'प्रमाण पत्र, या पुराना प्रमाण पत्र)। एक बात ध्यान रखें: सभी '
                    'काग़ज़ों में हिज्जे एक-सी रखें, वरना हर काग़ज़ दूसरे को ग़लत '
                    'साबित करता रहेगा।'
                : 'A difference in the name, the father\'s name, the date of '
                    'birth or the spelling of the caste becomes a large '
                    'problem later at a job or an admission, and there is no '
                    'time to fix it then. File a correction application at '
                    'the same office with the document that has it right '
                    '(Aadhaar, the school certificate, or an older '
                    'certificate). One thing to keep in mind: make the '
                    'spelling the same across every document, or each one '
                    'will keep proving the others wrong.',
            tone: ToolTone.warn,
            icon: Icons.edit_outlined,
          ),
      ],
    );
  }
}

// --- Atrocity case ----------------------------------------------------

enum PoaStage { beforeFir, firDone, chargeSheet, trial }

class AtrocityReliefPage extends StatefulWidget {
  const AtrocityReliefPage({super.key});

  @override
  State<AtrocityReliefPage> createState() => _AtrocityReliefPageState();
}

class _AtrocityReliefPageState extends State<AtrocityReliefPage> {
  PoaStage? _stage;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 10,
      title: hi ? 'अत्याचार मामला: हर चरण पर राहत' : 'Atrocity case: relief at each stage',
      children: [
        ToolNote(hi
            ? 'अनुसूचित जाति और जनजाति (अत्याचार निवारण) अधिनियम के नियमों में हर '
                'अपराध के लिए कम से कम राहत की रक़म तय है, और वह एक बार में नहीं, '
                'चरणों में मिलती है। पहला हिस्सा एफ़आईआर से जुड़ा है — और एफ़आईआर '
                'ही वह क़दम है जो सबसे ज़्यादा छूट जाता है। इसलिए सबसे पहले वही।'
            : 'The rules under the SC and ST (Prevention of Atrocities) Act '
                'fix a minimum relief for each offence, and it is paid in '
                'stages rather than all at once. The first part is tied to '
                'the FIR - and the FIR is the step most often not taken. So '
                'that comes first.'),
        const SizedBox(height: 12),
        ToolAnswer(
          headline: hi
              ? '$poaImmediateReliefDays दिन के भीतर तुरंत राहत'
              : 'Immediate relief within $poaImmediateReliefDays days',
          detail: hi
              ? 'नियमों के अनुसार ज़िलाधिकारी, एसडीएम या कार्यपालक मजिस्ट्रेट को '
                  'घटना के $poaImmediateReliefDays दिन के भीतर तुरंत राहत देनी होती '
                  'है — नक़द या सामान में: खाना, पानी, कपड़े, रहने की जगह, इलाज और '
                  'आने-जाने का ख़र्च। यह आगे मिलने वाली राहत से अलग है और उसमें से '
                  'कटती नहीं।'
              : 'Under the rules the District Magistrate, the SDM or the '
                  'Executive Magistrate must give immediate relief within '
                  '$poaImmediateReliefDays days of the incident - in cash or '
                  'in kind: food, water, clothing, shelter, medical aid and '
                  'transport. This is separate from the relief that follows '
                  'and is not deducted from it.',
          tone: ToolTone.plain,
          icon: Icons.volunteer_activism_outlined,
        ),
        ToolQuestion(hi ? 'मामला किस चरण में है' : 'Where is the case now'),
        SelectionTile(
          label: hi ? 'एफ़आईआर नहीं हुई' : 'No FIR yet',
          selected: _stage == PoaStage.beforeFir,
          onTap: () => setState(() => _stage = PoaStage.beforeFir),
        ),
        SelectionTile(
          label: hi ? 'एफ़आईआर हो गई' : 'The FIR is registered',
          selected: _stage == PoaStage.firDone,
          onTap: () => setState(() => _stage = PoaStage.firDone),
        ),
        SelectionTile(
          label: hi ? 'आरोप पत्र दाख़िल हो गया' : 'The charge sheet is filed',
          selected: _stage == PoaStage.chargeSheet,
          onTap: () => setState(() => _stage = PoaStage.chargeSheet),
        ),
        SelectionTile(
          label: hi ? 'मुक़दमा चल रहा है' : 'The trial is on',
          selected: _stage == PoaStage.trial,
          onTap: () => setState(() => _stage = PoaStage.trial),
        ),
        if (_stage == PoaStage.beforeFir) ...[
          ToolAnswer(
            headline: hi ? 'एफ़आईआर दर्ज कराना ही पहला काम है' : 'Getting the FIR registered is the first job',
            detail: hi
                ? 'इस अधिनियम के अपराध संज्ञेय हैं, इसलिए पुलिस को एफ़आईआर दर्ज '
                    'करनी ही होती है — जाँच बाद में। एफ़आईआर की नक़ल मुफ़्त मिलती है '
                    'और लेना आपका हक़ है। पुलिस दर्ज न करे तो पुलिस अधीक्षक को लिखित '
                    'शिकायत दें; उससे भी न हो तो मजिस्ट्रेट के सामने आवेदन किया जा '
                    'सकता है। मुफ़्त वकील के लिए ज़िला विधिक सेवा प्राधिकरण (डीएलएसए) '
                    'है, जो हर ज़िला न्यायालय में होता है।'
                : 'Offences under this Act are cognizable, so the police '
                    'have to register the FIR - the inquiry comes after. A '
                    'copy of the FIR is free and taking it is your right. If '
                    'the police will not register it, give a written '
                    'complaint to the Superintendent of Police; if that '
                    'fails, an application can be made before a magistrate. '
                    'For a free lawyer there is the District Legal Services '
                    'Authority, which sits in every district court.',
            tone: ToolTone.bad,
            icon: Icons.local_police_outlined,
          ),
          ToolDonts(
            heading: hi ? 'पहले दिन के लिए' : 'For the first day',
            items: hi
                ? const [
                    'घटना की जगह और चोट की फ़ोटो पहले ले लें — बाद में वह नहीं मिलती',
                    'इलाज कराएँ और डॉक्टर का पर्चा सुरक्षित रखें, चोट हल्की हो तो भी',
                    'गवाहों के नाम और फ़ोन नंबर लिख लें',
                    'समझौते के दबाव में लिखित में कुछ न दें, और अपने काग़ज़ों की '
                        'असली नक़ल किसी को न सौंपें',
                  ]
                : const [
                    'Photograph the place and the injuries first - later '
                        'they cannot be had',
                    'Get treated and keep the doctor\'s paper, even for a '
                        'light injury',
                    'Write down the names and phone numbers of witnesses',
                    'Under pressure to settle, put nothing in writing, and '
                        'hand nobody the originals of your papers',
                  ],
          ),
        ],
        if (_stage == PoaStage.firDone)
          ToolAnswer(
            headline: hi ? 'पहला हिस्सा अब बनता है' : 'The first instalment is due now',
            detail: hi
                ? 'ज़्यादातर अपराधों में राहत का पहला हिस्सा — आम तौर पर कुल का 25 '
                    'प्रतिशत — एफ़आईआर दर्ज होने पर ही देय हो जाता है। ज़िला समाज '
                    'कल्याण अधिकारी या ज़िलाधिकारी कार्यालय में एफ़आईआर की नक़ल, '
                    'जाति प्रमाण पत्र और बैंक खाते का ब्योरा देकर लिखित आवेदन करें, '
                    'और रसीद लें। कुछ अपराधों में हिसाब अलग है: मृत्यु में आधा '
                    'पोस्टमार्टम रिपोर्ट पर, और बलात्कार में आधा मेडिकल जाँच के बाद।'
                : 'For most offences the first instalment - usually 25 per '
                    'cent of the total - becomes payable the moment the FIR '
                    'is registered. Apply in writing at the district social '
                    'welfare officer or the District Magistrate\'s office '
                    'with a copy of the FIR, the caste certificate and the '
                    'bank account details, and take a receipt. A few '
                    'offences are counted differently: in a death half is '
                    'paid on the post-mortem report, and in rape half after '
                    'the medical examination.',
            tone: ToolTone.good,
            icon: Icons.payments_outlined,
          ),
        if (_stage == PoaStage.chargeSheet)
          ToolAnswer(
            headline: hi ? 'सबसे बड़ा हिस्सा इसी चरण पर' : 'The largest instalment is at this stage',
            detail: hi
                ? 'आरोप पत्र दाख़िल होने पर आम तौर पर कुल राहत का 50 प्रतिशत देय '
                    'होता है — यही सबसे बड़ा हिस्सा है और यही सबसे ज़्यादा बिना '
                    'माँगे रह जाता है, क्योंकि कोई ख़ुद से नहीं बताता। आरोप पत्र की '
                    'नक़ल लेकर उसी कार्यालय में दूसरा आवेदन दें। नियमों के अनुसार '
                    'जाँच और आरोप पत्र $poaChargeSheetDays दिन में पूरे होने चाहिए; '
                    'देर हो तो उसका कारण लिखित में दर्ज करना पड़ता है, और वह कारण '
                    'सूचना का अधिकार से माँगा जा सकता है।'
                : 'On the filing of the charge sheet about 50 per cent of '
                    'the total relief becomes payable - the largest part, '
                    'and the one most often left unclaimed, because nobody '
                    'volunteers it. Take a copy of the charge sheet and file '
                    'a second application at the same office. Under the '
                    'rules the investigation and charge sheet are to be '
                    'completed in $poaChargeSheetDays days; a delay has to '
                    'be recorded in writing with reasons, and that record '
                    'can be asked for under the Right to Information.',
            tone: ToolTone.good,
            icon: Icons.description_outlined,
          ),
        if (_stage == PoaStage.trial)
          ToolAnswer(
            headline: hi ? 'अंतिम हिस्सा, और मुक़दमे के दौरान के ख़र्च' : 'The last instalment, and the costs during trial',
            detail: hi
                ? 'बचा हुआ हिस्सा आम तौर पर दोषसिद्धि पर मिलता है। इसके अलावा '
                    'नियमों में मुक़दमे के दौरान का ख़र्च भी है: अदालत आने-जाने का '
                    'किराया, रुकने और खाने का भत्ता, और उस दिन की मज़दूरी का '
                    'नुक़सान — पीड़ित और गवाह, दोनों के लिए। हर तारीख़ पर यह माँगा '
                    'जा सकता है, और इसके लिए अदालत में एक अर्ज़ी लगती है। सरकारी '
                    'वकील से यह ज़रूर कहें; यह उनका ही काम है।'
                : 'What is left is normally paid on conviction. Beyond that, '
                    'the rules also provide for the costs during the trial: '
                    'the fare to court and back, an allowance for staying '
                    'and eating, and the wage lost that day - for the victim '
                    'and for witnesses both. It can be claimed for every '
                    'hearing date, through an application in court. Say so '
                    'to the public prosecutor; it is their job.',
            tone: ToolTone.plain,
            icon: Icons.gavel_outlined,
          ),
        if (_stage != null) ...[
          const SizedBox(height: 14),
          Text(hi ? 'कुछ अपराधों में कम से कम राहत' : 'Minimum relief, for some offences',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ToolLine(
              hi ? 'सार्वजनिक रूप से अपमान या धमकी' : 'Insult or intimidation in public view',
              '₹$poaReliefInsultPublic'),
          ToolLine(hi ? 'सामाजिक या आर्थिक बहिष्कार' : 'Social or economic boycott',
              '₹$poaReliefBoycott'),
          ToolLine(hi ? 'महिला से अनुचित स्पर्श' : 'Sexual touching of a woman',
              '₹$poaReliefTouching'),
          ToolLine(hi ? 'बलात्कार' : 'Rape', '₹$poaReliefRape'),
          ToolLine(hi ? 'मृत्यु' : 'Death', '₹$poaReliefDeath', strong: true),
          const SizedBox(height: 8),
          ToolNote(hi
              ? 'नियमों की अनुसूची में चालीस से ज़्यादा अपराध और उनकी राहत लिखी है; '
                  'ऊपर कुछ ही हैं। ये कम से कम की रक़में हैं, ऊपरी सीमा नहीं। मृत्यु, '
                  'बलात्कार और स्थायी अपंगता के मामलों में इसके अलावा आश्रित को '
                  'पेंशन, परिवार के एक सदस्य को नौकरी, बच्चों की पूरी पढ़ाई का ख़र्च '
                  'और तीन महीने का राशन भी नियमों में है। मुफ़्त कानूनी मदद के लिए '
                  'ज़िला विधिक सेवा प्राधिकरण से मिलें।'
              : 'The schedule to the rules lists over forty offences with '
                  'their relief; only a few are above. These are minimums, '
                  'not ceilings. In cases of death, rape and permanent '
                  'incapacitation the rules also provide a pension for '
                  'dependants, a job for one family member, the full cost of '
                  'the children\'s education and three months\' provisions. '
                  'For free legal help, see the District Legal Services '
                  'Authority.'),
          const SourceNote(
              text: 'SC/ST (Prevention of Atrocities) Rules - relief norms',
              url: _poaRulesUrl),
          const SourceNote(
              text: 'National Legal Services Authority', url: _nalsaUrl),
          const SourceNote(
              text: 'National Commission for Scheduled Castes', url: _ncscUrl),
        ],
      ],
    );
  }
}

// --- Denied entry or service ------------------------------------------

enum DeniedPlace { shop, hospital, temple, salon, school, water }

class DeniedServicePage extends StatefulWidget {
  const DeniedServicePage({super.key});

  @override
  State<DeniedServicePage> createState() => _DeniedServicePageState();
}

class _DeniedServicePageState extends State<DeniedServicePage> {
  DeniedPlace? _place;

  String _lawEn(DeniedPlace p) {
    switch (p) {
      case DeniedPlace.shop:
        return 'Refusing to sell to a person, or to sell on the same terms '
            'as to others, on the ground of caste is an offence under the '
            'Protection of Civil Rights Act 1955. Where the person refused '
            'is from a Scheduled Caste or Scheduled Tribe, obstructing '
            'access to a place or a service that the public has access to '
            'is also an offence under the Prevention of Atrocities Act, '
            'which is cognizable.';
      case DeniedPlace.hospital:
        return 'A hospital may not refuse treatment on the ground of caste. '
            'Refusing emergency treatment is separately wrong whatever the '
            'reason: the Supreme Court has held that no hospital, '
            'government or private, may turn away an emergency case for '
            'want of money or papers.';
      case DeniedPlace.temple:
        return 'Preventing a person from entering a place of worship open '
            'to the public on the ground of caste is an offence under the '
            'Protection of Civil Rights Act 1955, and under the Prevention '
            'of Atrocities Act where the person is from a Scheduled Caste '
            'or Scheduled Tribe.';
      case DeniedPlace.salon:
        return 'A shop or establishment serving the public may not refuse '
            'service on the ground of caste. For barbers and washermen the '
            'Protection of Civil Rights Act 1955 names this refusal '
            'specifically as an offence.';
      case DeniedPlace.school:
        return 'The Right to Education Act forbids any school from denying '
            'admission or segregating a child on the ground of caste, and '
            'the Prevention of Atrocities Act makes obstructing a child\'s '
            'admission or forcing them to sit apart an offence.';
      case DeniedPlace.water:
        return 'Obstructing a person from using a source of water, a well, '
            'a tank, a tap or a bathing place that the public uses is an '
            'offence under both the Protection of Civil Rights Act 1955 and '
            'the Prevention of Atrocities Act. Fouling such a source is a '
            'separate and graver offence.';
    }
  }

  String _lawHi(DeniedPlace p) {
    switch (p) {
      case DeniedPlace.shop:
        return 'जाति के आधार पर किसी को सामान बेचने से मना करना, या दूसरों से अलग '
            'शर्तों पर बेचना, नागरिक अधिकार संरक्षण अधिनियम 1955 के अंतर्गत अपराध '
            'है। और यदि मना किया गया व्यक्ति अनुसूचित जाति या जनजाति का है तो '
            'सार्वजनिक जगह या सेवा से रोकना अत्याचार निवारण अधिनियम में भी अपराध '
            'है, जो संज्ञेय है।';
      case DeniedPlace.hospital:
        return 'अस्पताल जाति के आधार पर इलाज से मना नहीं कर सकता। और आपात स्थिति '
            'में इलाज से मना करना किसी भी कारण से ग़लत है: सर्वोच्च न्यायालय ने कहा '
            'है कि कोई भी अस्पताल, सरकारी हो या निजी, पैसे या काग़ज़ के अभाव में '
            'आपात रोगी को लौटा नहीं सकता।';
      case DeniedPlace.temple:
        return 'जनता के लिए खुले पूजा स्थल में जाति के आधार पर प्रवेश से रोकना '
            'नागरिक अधिकार संरक्षण अधिनियम 1955 में अपराध है, और यदि व्यक्ति '
            'अनुसूचित जाति या जनजाति का है तो अत्याचार निवारण अधिनियम में भी।';
      case DeniedPlace.salon:
        return 'जनता को सेवा देने वाली दुकान जाति के आधार पर सेवा से मना नहीं कर '
            'सकती। नाई और धोबी के मामले में नागरिक अधिकार संरक्षण अधिनियम 1955 इस '
            'मनाही को ख़ास तौर पर अपराध बताता है।';
      case DeniedPlace.school:
        return 'शिक्षा का अधिकार अधिनियम किसी भी स्कूल को जाति के आधार पर दाख़िला '
            'मना करने या बच्चे को अलग बैठाने से रोकता है, और अत्याचार निवारण '
            'अधिनियम में बच्चे के दाख़िले में रुकावट डालना या उसे अलग बैठाने पर '
            'मजबूर करना अपराध है।';
      case DeniedPlace.water:
        return 'जनता के उपयोग वाले जल स्रोत, कुएँ, तालाब, नल या स्नान स्थल के '
            'उपयोग से रोकना नागरिक अधिकार संरक्षण अधिनियम 1955 और अत्याचार निवारण '
            'अधिनियम, दोनों में अपराध है। ऐसे स्रोत को गंदा करना इससे अलग और '
            'गंभीर अपराध है।';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 10,
      title: hi ? 'प्रवेश या सेवा से मना' : 'Denied entry or service',
      children: [
        ToolNote(hi
            ? 'जाति के आधार पर प्रवेश या सेवा से मना करना अपराध है, न कि कोई '
                'सामाजिक रिवाज़ जिसे सहना पड़े। कहाँ हुआ, उसके हिसाब से लागू '
                'क़ानून और शिकायत की जगह नीचे है।'
            : 'Being refused entry or service on the ground of caste is an '
                'offence, not a custom to be endured. Pick where it '
                'happened; the law that applies and where the complaint '
                'goes are below.'),
        ToolQuestion(hi ? 'कहाँ हुआ' : 'Where did it happen'),
        SelectionTile(
          label: hi ? 'दुकान या होटल' : 'A shop, hotel or eatery',
          selected: _place == DeniedPlace.shop,
          onTap: () => setState(() => _place = DeniedPlace.shop),
        ),
        SelectionTile(
          label: hi ? 'अस्पताल या दवाख़ाना' : 'A hospital or clinic',
          selected: _place == DeniedPlace.hospital,
          onTap: () => setState(() => _place = DeniedPlace.hospital),
        ),
        SelectionTile(
          label: hi ? 'मंदिर या पूजा स्थल' : 'A temple or place of worship',
          selected: _place == DeniedPlace.temple,
          onTap: () => setState(() => _place = DeniedPlace.temple),
        ),
        SelectionTile(
          label: hi ? 'नाई, धोबी या सैलून' : 'A barber, washerman or salon',
          selected: _place == DeniedPlace.salon,
          onTap: () => setState(() => _place = DeniedPlace.salon),
        ),
        SelectionTile(
          label: hi ? 'स्कूल' : 'A school',
          selected: _place == DeniedPlace.school,
          onTap: () => setState(() => _place = DeniedPlace.school),
        ),
        SelectionTile(
          label: hi ? 'नल, कुआँ या तालाब' : 'A tap, well or tank',
          selected: _place == DeniedPlace.water,
          onTap: () => setState(() => _place = DeniedPlace.water),
        ),
        if (_place != null) ...[
          ToolAnswer(
            headline: hi ? 'यह क़ानून लागू होता है' : 'This is the law that applies',
            detail: hi ? _lawHi(_place!) : _lawEn(_place!),
            tone: ToolTone.plain,
            icon: Icons.balance_outlined,
          ),
          const SizedBox(height: 12),
          Text(hi ? 'क्या करें' : 'What to do',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'जो हुआ, उसे उसी दिन लिख लें: तारीख़, समय, जगह, किसने क्या कहा, '
                        'और कौन मौजूद था। समय बीतने पर याद धुँधली पड़ती है और '
                        'ब्योरा सबसे बड़ा सबूत होता है।',
                    'मौजूद लोगों के नाम और फ़ोन नंबर लें।',
                    'थाने में शिकायत दें। अत्याचार निवारण अधिनियम के अपराध संज्ञेय '
                        'हैं, इसलिए एफ़आईआर दर्ज करनी होती है। एफ़आईआर की नक़ल मुफ़्त '
                        'मिलती है — लेकर रखें।',
                    'पुलिस मना करे तो पुलिस अधीक्षक को लिखित शिकायत दें, और उसकी एक '
                        'नक़ल अपने पास रखें।',
                    'साथ-साथ राष्ट्रीय अनुसूचित जाति आयोग या राज्य आयोग में भी '
                        'शिकायत दी जा सकती है — यह थाने की शिकायत के बदले नहीं, '
                        'उसके अलावा है।',
                    'मुफ़्त वकील के लिए ज़िला विधिक सेवा प्राधिकरण में जाएँ, जो ज़िला '
                        'न्यायालय में ही होता है। इसका कोई शुल्क नहीं।',
                  ]
                : const [
                    'Write down what happened the same day: date, time, '
                        'place, who said what, and who was present. Memory '
                        'blurs with time and the detail is the strongest '
                        'evidence there is.',
                    'Take the names and phone numbers of the people who '
                        'were there.',
                    'Give a complaint at the police station. Offences under '
                        'the Prevention of Atrocities Act are cognizable, so '
                        'an FIR has to be registered. A copy of the FIR is '
                        'free - take it and keep it.',
                    'If the police refuse, give a written complaint to the '
                        'Superintendent of Police, and keep a copy.',
                    'Alongside that, a complaint can go to the National '
                        'Commission for Scheduled Castes or the state '
                        'commission - not instead of the police complaint, '
                        'as well as it.',
                    'For a free lawyer go to the District Legal Services '
                        'Authority, which sits in the district court. There '
                        'is no fee.',
                  ],
          ),
          const SourceNote(
              text: 'National Commission for Scheduled Castes', url: _ncscUrl),
          const SourceNote(
              text: 'National Legal Services Authority', url: _nalsaUrl),
        ],
      ],
    );
  }
}

// --- Manual scavenging ------------------------------------------------

class ManualScavengingPage extends StatelessWidget {
  const ManualScavengingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 10,
      title: hi ? 'हाथ से मैला ढोना' : 'Manual scavenging',
      children: [
        ToolAnswer(
          headline: hi
              ? 'यह क़ानून से प्रतिबंधित है'
              : 'This is banned by law',
          detail: hi
              ? 'हाथ से मैला ढोने के लिए किसी को रखना, और सीवर या सेप्टिक टैंक में '
                  'सुरक्षा उपकरण के बिना किसी को उतारना — दोनों अपराध हैं। यह '
                  'प्रतिबंध सरकारी विभाग, ठेकेदार और निजी मकान मालिक, सब पर एक-सा '
                  'लागू होता है। "काम ऐसा ही चलता आया है" इसका बचाव नहीं है।'
              : 'Employing anyone as a manual scavenger, and sending anyone '
                  'into a sewer or septic tank without safety equipment, are '
                  'both offences. The ban applies equally to government '
                  'departments, contractors and private householders. "This '
                  'is how the work has always been done" is no defence.',
          tone: ToolTone.bad,
          icon: Icons.gavel_outlined,
        ),
        const SizedBox(height: 14),
        ToolDonts(
          heading: hi ? 'टैंक में उतरने से पहले — रुकिए' : 'Before anyone goes in - stop',
          items: hi
              ? const [
                  'सीवर या सेप्टिक टैंक की गैस दिखती नहीं और सुँघाई भी नहीं देती; '
                      'वह कुछ ही साँस में बेहोश कर देती है',
                  'बचाने के लिए पीछे-पीछे उतरने से दूसरी मौत होती है — यही सबसे आम '
                      'तरीक़ा है जिससे एक की जगह दो या तीन जानें जाती हैं',
                  'अंदर मौजूद व्यक्ति को बाहर से रस्सी या हुक से खींचें, और 112 पर '
                      'फ़ोन करें',
                  'टैंक का ढक्कन खोलकर पहले हवा लगने दें, और कोई माचिस या लाइटर '
                      'पास न जलाएँ',
                  'यह काम मशीन और सुरक्षा उपकरण के साथ ही होना है; नगर पालिका से '
                      'सक्शन मशीन माँगना आपका हक़ है',
                ]
              : const [
                  'The gas in a sewer or septic tank cannot be seen or '
                      'smelled; it knocks a person out in a few breaths',
                  'Climbing in after someone to save them causes the second '
                      'death - it is the commonest way one life lost becomes '
                      'two or three',
                  'Pull the person out from outside with a rope or a hook, '
                      'and call 112',
                  'Open the cover and let it air first, and light no match '
                      'or lighter anywhere near',
                  'This work is to be done with a machine and safety gear; '
                      'asking the municipality for a suction machine is your '
                      'right',
                ],
        ),
        const SizedBox(height: 14),
        Text(hi ? 'मुआवज़ा — सर्वोच्च न्यायालय का आदेश' : 'Compensation - Supreme Court order',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        ToolLine(hi ? 'सीवर में मृत्यु' : 'Death in a sewer',
            '₹$sewerDeathCompensation', strong: true),
        ToolLine(hi ? 'स्थायी अपंगता' : 'Permanent disablement',
            '₹$sewerPermanentDisability'),
        ToolLine(hi ? 'अन्य अपंगता, कम से कम' : 'Other disablement, at least',
            '₹$sewerOtherDisability'),
        const SizedBox(height: 8),
        ToolNote(hi
            ? 'सर्वोच्च न्यायालय ने 2023 में यह रक़में तय कीं, और यह भी कहा कि '
                'जिन परिवारों को पहले की घटनाओं पर यह नहीं मिला, वे भी हक़दार हैं। '
                'देने की ज़िम्मेदारी उस एजेंसी की है जिसके काम में घटना हुई — नगर '
                'पालिका, राज्य या केंद्र — और ठेके पर कराया गया काम भी इससे बाहर '
                'नहीं है। मुफ़्त कानूनी मदद के लिए ज़िला विधिक सेवा प्राधिकरण में '
                'जाएँ; ऐसे मामलों में उसे मदद करने का आदेश इसी फ़ैसले में है।'
            : 'The Supreme Court fixed these amounts in 2023, and also held '
                'that families who were not paid for earlier deaths are '
                'still entitled. The liability is on the agency whose work '
                'it was - the municipality, the state or the Union - and '
                'work given out on contract is not outside it. For free '
                'legal help go to the District Legal Services Authority; the '
                'same judgment directs it to help in these cases.'),
        const SizedBox(height: 14),
        Text(hi ? 'पुनर्वास और शिकायत' : 'Rehabilitation and complaints',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'नमस्ते योजना सफ़ाई कर्मचारियों के लिए है: पहचान पत्र, सुरक्षा '
                      'उपकरण, स्वास्थ्य बीमा, कौशल प्रशिक्षण और उपकरण ख़रीदने के लिए '
                      'पूँजी सहायता। पंजीकरण नगर पालिका के ज़रिये होता है।',
                  'चिह्नित मैला ढोने वालों के लिए एक बार की नक़द सहायता, बच्चों के '
                      'लिए छात्रवृत्ति, और कोई दूसरा काम शुरू करने के लिए ऋण तथा '
                      'सब्सिडी का प्रावधान है — राशि समय-समय पर बदलती है, इसलिए '
                      'वर्तमान रक़म नगर पालिका या राष्ट्रीय सफ़ाई कर्मचारी वित्त '
                      'निगम से पूछें।',
                  'शिकायत के लिए: नगर पालिका का आयुक्त, ज़िलाधिकारी, और राष्ट्रीय '
                      'सफ़ाई कर्मचारी आयोग। लिखित दें और रसीद लें।',
                  'किसी की मृत्यु या चोट हो तो एफ़आईआर भी दर्ज कराएँ। मुआवज़े का '
                      'दावा और एफ़आईआर, दोनों अलग रास्ते हैं और दोनों चलते हैं।',
                ]
              : const [
                  'The NAMASTE scheme is for sanitation workers: an identity '
                      'card, safety equipment, health insurance, skill '
                      'training, and capital support to buy equipment. '
                      'Registration goes through the municipality.',
                  'For identified manual scavengers there is one-time cash '
                      'assistance, scholarships for the children, and loans '
                      'with subsidy to start other work - the amounts change '
                      'from time to time, so ask the municipality or the '
                      'National Safai Karamcharis Finance and Development '
                      'Corporation for the current figure.',
                  'To complain: the municipal commissioner, the District '
                      'Magistrate, and the National Commission for Safai '
                      'Karamcharis. Put it in writing and take a receipt.',
                  'If anyone has died or been injured, also get an FIR '
                      'registered. The compensation claim and the FIR are '
                      'separate routes and both run.',
                ],
        ),
        const SourceNote(text: 'NAMASTE scheme', url: _namasteUrl),
        const SourceNote(
            text: 'National Legal Services Authority', url: _nalsaUrl),
      ],
    );
  }
}
