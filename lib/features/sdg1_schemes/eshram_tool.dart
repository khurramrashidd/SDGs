import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/tool_kit.dart';

/// Whether registering on e-Shram is worth the trip, and what it is not.
///
/// e-Shram is a register of unorganised workers, not a scheme that pays
/// anything by itself. It is worth doing - it is free, it takes ten
/// minutes, and several state and central benefits now ask for the
/// Universal Account Number it gives you - but a worker told at a camp
/// that "the card gives two lakh rupees" and then finding it does not is
/// how people stop trusting every scheme after it. So this screen answers
/// the eligibility question properly, and is blunt about what the card
/// does and does not do.
///
/// The bars, from the Ministry of Labour and Employment:
///   age 16 to 59 (completed), and
///   working in the unorganised sector, and
///   not a member of EPFO or ESIC, and
///   not an income-tax payer.
/// Registration is free, at eshram.gov.in or any Common Service Centre.
enum EShramBar { age, organised, epfo, incomeTax }

/// The bars this worker fails. Empty means they can register.
Set<EShramBar> eShramBars({
  required int age,
  required bool organisedJob,
  required bool epfoOrEsic,
  required bool paysIncomeTax,
}) =>
    {
      if (age < 16 || age > 59) EShramBar.age,
      if (organisedJob) EShramBar.organised,
      if (epfoOrEsic) EShramBar.epfo,
      if (paysIncomeTax) EShramBar.incomeTax,
    };

const _eshramUrl = 'https://eshram.gov.in/';

class EShramPage extends StatefulWidget {
  const EShramPage({super.key});

  @override
  State<EShramPage> createState() => _EShramPageState();
}

class _EShramPageState extends State<EShramPage> {
  final _age = TextEditingController();
  bool _organised = false;
  bool _epfo = false;
  bool _tax = false;

  @override
  void dispose() {
    _age.dispose();
    super.dispose();
  }

  String _barText(EShramBar b, bool hi) => switch (b) {
        EShramBar.age => hi
            ? 'e-Shram 16 से 59 साल की उम्र तक है।'
            : 'e-Shram is for ages 16 to 59.',
        EShramBar.organised => hi
            ? 'यह असंगठित क्षेत्र के कामगारों का रजिस्टर है। पक्की सरकारी या कंपनी की '
                'नौकरी इसमें नहीं आती।'
            : 'It is a register of unorganised-sector workers. A permanent '
                'government or company job does not come under it.',
        EShramBar.epfo => hi
            ? 'ईपीएफ़ओ या ईएसआईसी के सदस्य इसमें शामिल नहीं होते — उनके लिए अलग '
                'व्यवस्था पहले से है।'
            : 'Members of EPFO or ESIC are not included - they already have '
                'their own cover.',
        EShramBar.incomeTax => hi
            ? 'आयकर भरने वाले इसमें शामिल नहीं होते।'
            : 'Income-tax payers are not included.',
      };

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final age = int.tryParse(_age.text.trim());
    final bars = age == null || age <= 0
        ? null
        : eShramBars(
            age: age,
            organisedJob: _organised,
            epfoOrEsic: _epfo,
            paysIncomeTax: _tax,
          );

    Widget swap(String en, String h, String sub, String subHi, bool value,
            ValueChanged<bool> onChanged) =>
        SwitchListTile(
          value: value,
          contentPadding: EdgeInsets.zero,
          title: Text(hi ? h : en),
          subtitle: Text(hi ? subHi : sub,
              style: const TextStyle(fontSize: 12)),
          onChanged: onChanged,
        );

    return ToolScaffold(
      goal: 1,
      title: hi ? 'e-Shram कार्ड: बनवाएँ या नहीं' : 'e-Shram: is it for me',
      children: [
        ToolNote(hi
            ? 'पहले एक बात साफ़ कर लें: e-Shram कार्ड अपने आप कोई पैसा नहीं देता। यह '
                'असंगठित कामगारों का सरकारी रजिस्टर है, और इससे एक नंबर (UAN) मिलता है '
                'जो कई राज्य और केंद्र की योजनाएँ अब माँगती हैं। मुफ़्त है, दस मिनट लगते '
                'हैं। जो लोग कहते हैं "कार्ड से दो लाख मिलेंगे" — वे ग़लत कह रहे हैं।'
            : 'One thing first: the e-Shram card does not pay you anything '
                'by itself. It is the government\'s register of unorganised '
                'workers, and it gives you a number (a UAN) that several '
                'state and central schemes now ask for. It is free and '
                'takes ten minutes. Anyone telling you "the card gives two '
                'lakh rupees" is wrong.'),
        ToolQuestion(hi ? 'उम्र' : 'Age'),
        ToolNumber(
          controller: _age,
          label: hi ? 'पूरे साल' : 'Completed years',
          maxDigits: 3,
          icon: Icons.badge_outlined,
          onChanged: (_) => setState(() {}),
        ),
        ToolQuestion(hi ? 'काम के बारे में' : 'About the work'),
        swap(
            'Permanent government or company job',
            'पक्की सरकारी या कंपनी की नौकरी',
            'With a salary slip and an appointment letter',
            'जिसमें वेतन पर्ची और नियुक्ति पत्र हो',
            _organised,
            (v) => setState(() => _organised = v)),
        swap(
            'PF or ESIC is deducted from the pay',
            'वेतन से पीएफ़ या ईएसआईसी कटता है',
            'EPFO or ESIC membership',
            'ईपीएफ़ओ या ईएसआईसी की सदस्यता',
            _epfo,
            (v) => setState(() => _epfo = v)),
        swap(
            'Files an income-tax return',
            'आयकर रिटर्न भरते हैं',
            'You yourself, not the rest of the household',
            'आप स्वयं, घर के बाक़ी लोग नहीं',
            _tax,
            (v) => setState(() => _tax = v)),
        if (bars != null) ...[
          if (bars.isEmpty)
            ToolAnswer(
              headline: hi
                  ? 'हाँ, आप रजिस्टर कर सकते हैं'
                  : 'Yes, you can register',
              detail: hi
                  ? 'मुफ़्त है। आधार, आधार से जुड़ा मोबाइल नंबर और बैंक खाते की जानकारी '
                      'साथ रखें। खुद eshram.gov.in पर कर सकते हैं, या किसी कॉमन सर्विस '
                      'सेंटर पर — सीएससी पर भी आपसे पैसा नहीं लिया जाना चाहिए।'
                  : 'It is free. Keep your Aadhaar, the mobile number linked '
                      'to it, and your bank details to hand. Do it yourself '
                      'at eshram.gov.in, or at a Common Service Centre - and '
                      'a CSC should not charge you for it either.',
              tone: ToolTone.good,
              icon: Icons.how_to_reg_outlined,
            )
          else ...[
            ToolAnswer(
              headline: hi
                  ? 'इस समय आप इसमें नहीं आते'
                  : 'You do not come under it right now',
              detail: hi
                  ? 'नीचे वजह लिखी है। हालात बदलें तो दोबारा देखें।'
                  : 'The reason is below. Check again if that changes.',
              tone: ToolTone.warn,
              icon: Icons.block_outlined,
            ),
            const SizedBox(height: 8),
            for (final b in bars) ToolNote(_barText(b, hi)),
          ],
          const SizedBox(height: 14),
          Text(hi ? 'कार्ड से असल में क्या होता है' : 'What the card actually does',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ToolLine(
              hi ? 'एक स्थायी नंबर (UAN)' : 'A permanent number (UAN)',
              hi ? 'हाँ' : 'Yes',
              strong: true),
          ToolLine(
              hi
                  ? 'कई योजनाओं में काम आता है'
                  : 'Accepted as proof by several schemes',
              hi ? 'हाँ' : 'Yes'),
          ToolLine(hi ? 'अपने आप कोई मासिक पैसा' : 'Any monthly money by itself',
              hi ? 'नहीं' : 'No'),
          ToolLine(hi ? 'अपने आप बीमा' : 'Any insurance by itself',
              hi ? 'नहीं' : 'No'),
          const SizedBox(height: 8),
          ToolNote(hi
              ? 'बीमा अलग से लेना होता है और सस्ता है: PMJJBY साल का ₹436, PMSBY साल '
                  'का ₹20। इसी लक्ष्य में "₹20 और ₹436 का बीमा" देखें।'
              : 'Insurance is a separate thing, and it is cheap: PMJJBY at '
                  '₹436 a year, PMSBY at ₹20. See "Insurance for ₹20 and '
                  '₹436" in this same goal.'),
          const SourceNote(
            text: 'e-Shram, Ministry of Labour and Employment',
            url: _eshramUrl,
          ),
        ],
      ],
    );
  }
}
