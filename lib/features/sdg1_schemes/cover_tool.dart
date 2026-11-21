import 'package:flutter/material.dart';

import '../../core/sdg/advice.dart';
import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Two pieces of government insurance that cost almost nothing, which most
/// of the families they are meant for have never heard of.
///
/// PMJJBY: ₹436 a year, ₹2 lakh to the nominee on death from any cause,
/// ages 18 to 50, cover continuing to 55.
/// PMSBY:  ₹20 a year, ₹2 lakh for accidental death or total permanent
/// disability, ₹1 lakh for partial permanent disability, ages 18 to 70.
/// Both run 1 June to 31 May and are bought through a bank or post office
/// account by auto-debit.
///
/// The screen does two things in order of usefulness: tells you whether you
/// are eligible, and then makes the point that matters more - that a cover
/// nobody in the family knows about is never claimed, because the claim is
/// made by the nominee after the subscriber has died.
const pmjjbyPremium = 436;
const pmjjbyCover = 200000;
const pmsbyPremium = 20;
const pmsbyCover = 200000;
const pmsbyPartial = 100000;

const _jjbyUrl = 'https://financialservices.gov.in/pmjjby';
const _sbyUrl =
    'https://financialservices.gov.in/index.php/pradhan-mantri-suraksha-bima-yojana-pmsby';

enum CoverFit { both, accidentOnly, neither }

CoverFit coverFor(int age) {
  if (age >= 18 && age <= 50) return CoverFit.both;
  if (age >= 18 && age <= 70) return CoverFit.accidentOnly;
  return CoverFit.neither;
}

const _lifeCover = Advice(
  title: 'Life cover: Rs 2 lakh for Rs 436 a year',
  titleHi: 'जीवन बीमा: 436 रुपये साल में 2 लाख',
  body: 'Pradhan Mantri Jeevan Jyoti Bima Yojana pays Rs 2 lakh to your '
      'nominee if you die, from any cause. The premium is taken from your '
      'bank or post office account once a year by auto-debit. You can join '
      'between 18 and 50, and the cover carries on to age 55 as long as you '
      'keep renewing. Deaths other than by accident in the first 30 days '
      'after joining are not covered. Ask at the branch where you already '
      'have an account; the form is one page.',
  bodyHi: 'प्रधानमंत्री जीवन ज्योति बीमा योजना आपकी मृत्यु पर, किसी भी कारण से, '
      'आपके नामित व्यक्ति को 2 लाख रुपये देती है। प्रीमियम साल में एक बार आपके बैंक '
      'या डाकघर खाते से अपने आप कट जाता है। 18 से 50 साल के बीच जुड़ सकते हैं, और '
      'नवीनीकरण करते रहने पर कवर 55 साल तक चलता है। जुड़ने के पहले 30 दिन में '
      'दुर्घटना के अलावा किसी कारण से मृत्यु कवर नहीं होती। जिस शाखा में पहले से खाता '
      'है वहीं पूछें; फ़ॉर्म एक पन्ने का है।',
  source: _jjbyUrl,
);

const _accidentCover = Advice(
  title: 'Accident cover: Rs 2 lakh for Rs 20 a year',
  titleHi: 'दुर्घटना बीमा: 20 रुपये साल में 2 लाख',
  body: 'Pradhan Mantri Suraksha Bima Yojana pays Rs 2 lakh for death or '
      'total permanent disability in an accident, and Rs 1 lakh for partial '
      'permanent disability. It costs Rs 20 a year, auto-debited from a bank '
      'account, and anyone from 18 to 70 with an account can join. For '
      'someone who travels to work on a two-wheeler or works on a site, '
      'this is the cheapest protection there is.',
  bodyHi: 'प्रधानमंत्री सुरक्षा बीमा योजना दुर्घटना में मृत्यु या पूर्ण स्थायी '
      'दिव्यांगता पर 2 लाख रुपये, और आंशिक स्थायी दिव्यांगता पर 1 लाख रुपये देती है। '
      'यह साल के 20 रुपये में है, बैंक खाते से अपने आप कटता है, और खाता रखने वाला 18 '
      'से 70 साल का कोई भी जुड़ सकता है। दोपहिया से काम पर जाने वाले या साइट पर काम '
      'करने वाले के लिए इससे सस्ती सुरक्षा कोई नहीं।',
  source: _sbyUrl,
);

const _tellFamily = Advice(
  title: 'Tell your family, or the cover is wasted',
  titleHi: 'परिवार को बताएँ, वरना बीमा बेकार है',
  body: 'This is the part that goes wrong. The claim is made by the nominee '
      'after the subscriber has died, so a cover nobody at home knows about '
      'is never claimed. Write down which bank account it runs from, who '
      'the nominee is, and keep the acknowledgement with the family papers. '
      'Tell at least two people in the house.',
  bodyHi: 'गड़बड़ी यहीं होती है। दावा नामित व्यक्ति मृत्यु के बाद करता है, इसलिए जिस '
      'बीमे के बारे में घर में किसी को पता नहीं, उसका दावा कभी नहीं होता। लिख लें कि '
      'यह किस बैंक खाते से चलता है, नामित कौन है, और पावती परिवार के काग़ज़ों के साथ '
      'रखें। घर में कम से कम दो लोगों को बताएँ।',
  source: _jjbyUrl,
);

const _claimSteps = Advice(
  title: 'If a claim has to be made',
  titleHi: 'अगर दावा करना पड़े',
  body: 'The nominee goes to the bank branch that holds the account, with '
      'the death certificate, the nominee\'s own identity and bank details, '
      'and the account passbook. The bank gives the claim form and sends it '
      'to the insurer. Do it as soon as you reasonably can: claims are not '
      'refused for a few weeks\' delay, but they do get harder the longer '
      'the account sits untouched.',
  bodyHi: 'नामित व्यक्ति उस बैंक शाखा में जाए जहाँ खाता है — साथ में मृत्यु प्रमाण '
      'पत्र, अपनी पहचान और बैंक विवरण, और खाते की पासबुक। बैंक दावा फ़ॉर्म देता है और '
      'बीमा कंपनी को भेजता है। जितनी जल्दी हो सके करें: कुछ हफ़्तों की देरी से दावा '
      'ख़ारिज नहीं होता, पर खाता जितना लंबा बिना छुए पड़ा रहे, काम उतना मुश्किल होता है।',
  source: _jjbyUrl,
);

class JanSurakshaPage extends StatefulWidget {
  const JanSurakshaPage({super.key});

  @override
  State<JanSurakshaPage> createState() => _JanSurakshaPageState();
}

class _JanSurakshaPageState extends State<JanSurakshaPage> {
  final _age = TextEditingController();
  bool? _hasAccount;

  @override
  void dispose() {
    _age.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final age = int.tryParse(_age.text.trim()) ?? 0;
    final fit = age > 0 ? coverFor(age) : null;

    return ToolScaffold(
      goal: 1,
      title: hi ? '2 लाख का सस्ता बीमा' : 'Rs 2 lakh cover, cheaply',
      children: [
        ToolNote(hi
            ? 'दो सरकारी बीमा हैं जिनका प्रीमियम बहुत कम है। यहाँ देखें कि आप किसके '
                'पात्र हैं, और वह बात भी जो असल में सबसे ज़्यादा मायने रखती है।'
            : 'Two government covers with very small premiums. See which you '
                'can take, and the thing that matters more than either.'),
        ToolQuestion(hi ? 'आपकी उम्र' : 'Your age'),
        ToolNumber(
          controller: _age,
          label: hi ? 'साल' : 'Years',
          maxDigits: 3,
          icon: Icons.cake_outlined,
          onChanged: (_) => setState(() {}),
        ),
        ToolQuestion(hi
            ? 'क्या आपका बैंक या डाकघर में खाता है?'
            : 'Do you have a bank or post office account?'),
        SelectionTile(
          label: hi ? 'हाँ' : 'Yes',
          selected: _hasAccount == true,
          onTap: () => setState(() => _hasAccount = true),
        ),
        SelectionTile(
          label: hi ? 'नहीं' : 'No',
          selected: _hasAccount == false,
          onTap: () => setState(() => _hasAccount = false),
        ),
        if (_hasAccount == false)
          ToolAnswer(
            headline: hi ? 'पहले एक खाता खुलवाएँ' : 'Open an account first',
            detail: hi
                ? 'दोनों बीमा खाते से अपने आप कटने वाले प्रीमियम पर चलते हैं। जन धन '
                    'खाता बिना न्यूनतम राशि के खुलता है, और उसी से ज़्यादातर सरकारी पैसा '
                    'भी सीधे आता है।'
                : 'Both covers run on a premium taken from an account. A Jan '
                    'Dhan account opens with no minimum balance, and it is '
                    'also how most government money reaches people directly.',
            tone: ToolTone.warn,
            icon: Icons.account_balance_outlined,
          ),
        if (fit != null && _hasAccount == true) ...[
          if (fit == CoverFit.both)
            ToolAnswer(
              headline: hi
                  ? 'दोनों ले सकते हैं — साल में कुल ₹${pmjjbyPremium + pmsbyPremium}'
                  : 'You can take both — ₹${pmjjbyPremium + pmsbyPremium} a year in all',
              detail: hi
                  ? 'जीवन बीमा ₹$pmjjbyPremium और दुर्घटना बीमा ₹$pmsbyPremium। '
                      'दोनों मिलकर ₹${pmjjbyPremium + pmsbyPremium} साल में, और '
                      'मृत्यु पर परिवार को 2 लाख।'
                  : 'Life cover at ₹$pmjjbyPremium and accident cover at '
                      '₹$pmsbyPremium. Together ₹${pmjjbyPremium + pmsbyPremium} '
                      'a year, and ₹2 lakh to the family on death.',
              tone: ToolTone.good,
              icon: Icons.verified_outlined,
            ),
          if (fit == CoverFit.accidentOnly)
            ToolAnswer(
              headline: hi
                  ? 'दुर्घटना बीमा ले सकते हैं — साल के ₹$pmsbyPremium'
                  : 'You can take the accident cover — ₹$pmsbyPremium a year',
              detail: hi
                  ? 'जीवन बीमा में नया नाम 50 साल तक ही दर्ज होता है, इसलिए वह अब नहीं '
                      'मिलेगा। दुर्घटना बीमा 70 साल तक खुला है।'
                  : 'The life cover only takes new members up to 50, so that '
                      'one is closed. The accident cover is open to 70.',
              tone: ToolTone.good,
              icon: Icons.verified_outlined,
            ),
          if (fit == CoverFit.neither)
            ToolAnswer(
              headline: hi
                  ? 'इन दोनों की उम्र सीमा से बाहर'
                  : 'Outside the age range for both',
              detail: hi
                  ? 'घर के 18 से 70 साल के सदस्यों के लिए ये लिए जा सकते हैं। '
                      'बुज़ुर्गों के लिए वृद्धावस्था पेंशन और आयुष्मान भारत देखें।'
                  : 'They can still be taken for anyone in the house between '
                      '18 and 70. For older people, look at the old age '
                      'pension and Ayushman Bharat instead.',
              tone: ToolTone.plain,
              icon: Icons.info_outline,
            ),
          AdviceList(
            heading: hi ? 'जो जानना ज़रूरी है' : 'What to know',
            items: [
              if (fit == CoverFit.both) _lifeCover,
              if (fit != CoverFit.neither) _accidentCover,
              _tellFamily,
              _claimSteps,
            ],
          ),
        ],
      ],
    );
  }
}
