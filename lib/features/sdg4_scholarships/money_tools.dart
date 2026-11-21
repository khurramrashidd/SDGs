import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/sdg/advice.dart';
import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Scholarship money that never arrived, and what a loan really costs.
///
/// A scholarship sanctioned and not paid is the commonest reason a first
/// family-graduate drops out, and almost always the break is at one of
/// four steps - none of which the student can see. The loan screen does
/// the arithmetic nobody does before signing: what the monthly payment
/// will be, and what the interest adds up to over the whole term.

const _nspUrl = 'https://scholarships.gov.in/';
const _pmVidyalaxmiUrl = 'https://pmvidyalaxmi.co.in/';
const _pmVidyalaxmiPibUrl =
    'https://www.pib.gov.in/PressReleasePage.aspx?PRID=2290079';
const _vidyaLakshmiUrl = 'https://www.vidyalakshmi.co.in/';

// --- Scholarship not received -----------------------------------------

/// Where the money can be stuck. The institute step is the one that
/// catches most students, and they are never told about it.
enum ScholarshipStage {
  neverApplied,
  appliedNoStatus,
  instituteNotVerified,
  sanctionedNotPaid,
  renewalMissed,
}

const _checkPortal = Advice(
  title: 'Read the status on the portal, and note the exact words',
  titleHi: 'पोर्टल पर स्थिति पढ़ें, और ठीक वही शब्द लिख लें',
  body: 'On the National Scholarship Portal, your application has a status '
      'at every stage, and it names the step rather than just saying '
      '"pending" - "institute verification pending", "defective", "rejected '
      'by state", "payment failed". Every route below depends on which of '
      'those it is, so get the words first. Log in with your own ID; a cafe '
      'owner reading it out to you is how wrong information starts.',
  bodyHi: 'राष्ट्रीय छात्रवृत्ति पोर्टल पर आपकी अर्ज़ी की हर चरण पर एक स्थिति होती है, '
      'और वह सिर्फ़ "लंबित" नहीं लिखती — वह क़दम बताती है: "संस्थान सत्यापन लंबित", '
      '"त्रुटिपूर्ण", "राज्य द्वारा अस्वीकृत", "भुगतान विफल"। नीचे का हर रास्ता इसी पर '
      'निर्भर है, इसलिए पहले वे शब्द लें। अपनी आईडी से ख़ुद लॉगिन करें; दुकानदार के '
      'पढ़कर बताने से ही ग़लत जानकारी शुरू होती है।',
  source: _nspUrl,
);

const _instituteStep = Advice(
  title: 'The institute has to verify it. This is where most get stuck',
  titleHi: 'संस्थान को सत्यापन करना होता है — यहीं सबसे ज़्यादा अटकती है',
  body: 'After a student applies, the college or school has to verify the '
      'application on the portal, and then the district or state has to. A '
      'student who has applied correctly and heard nothing for months is '
      'usually waiting on a clerk who has not opened the portal. Go to the '
      'office in person, ask who the institute nodal officer for scholarships '
      'is, and ask them to verify it while you are standing there - it takes '
      'two minutes. Get the date they did it.',
  bodyHi: 'छात्र की अर्ज़ी के बाद कॉलेज या स्कूल को पोर्टल पर सत्यापन करना होता है, '
      'और उसके बाद ज़िले या राज्य को। जिस छात्र ने सही अर्ज़ी दी और महीनों कुछ नहीं '
      'सुना, वह आमतौर पर उस बाबू के इंतज़ार में है जिसने पोर्टल खोला ही नहीं। '
      'कार्यालय में ख़ुद जाएँ, पूछें कि छात्रवृत्ति का संस्थान नोडल अधिकारी कौन है, और '
      'उनसे अपने सामने ही सत्यापन कराएँ — दो मिनट का काम है। जिस तारीख़ को हुआ, '
      'वह लिख लें।',
  source: _nspUrl,
);

const _bankMismatch = Advice(
  title: 'The account has to be yours, and Aadhaar-seeded',
  titleHi: 'खाता आपका ही हो, और आधार से सीड हो',
  body: 'Scholarship money is paid by direct transfer into the student\'s own '
      'account - not a parent\'s. The name on the bank account must match the '
      'name on Aadhaar, and Aadhaar must be seeded to that account for DBT. A '
      'minor\'s account, a dormant account that has had no transaction for '
      'two years, or a name spelt differently will all fail the transfer, and '
      'the portal will say "payment failed" without saying why.',
  bodyHi: 'छात्रवृत्ति का पैसा सीधे छात्र के अपने खाते में आता है — माता-पिता के '
      'नहीं। बैंक खाते का नाम आधार के नाम से मिलना चाहिए, और उस खाते में आधार '
      'डीबीटी के लिए सीड होना चाहिए। नाबालिग़ का खाता, दो साल से बंद पड़ा खाता, या '
      'नाम के हिज्जे अलग होना — इन तीनों में भुगतान फ़ेल होता है, और पोर्टल सिर्फ़ '
      '"भुगतान विफल" लिखता है, कारण नहीं।',
  source: _nspUrl,
);

const _renewal = Advice(
  title: 'A scholarship has to be renewed every year, on time',
  titleHi: 'छात्रवृत्ति हर साल समय पर नवीनीकृत करानी होती है',
  body: 'This is the quiet one. Most scholarships need a renewal application '
      'each year, inside a window that is usually a few weeks, with last '
      'year\'s marks and attendance. Miss the window and the money stops, and '
      'in many schemes it cannot be claimed later - the year is simply gone. '
      'Note the renewal dates the moment you get the first payment, and ask '
      'the institute nodal officer to tell you when the window opens.',
  bodyHi: 'यह चुपचाप होने वाली चीज़ है। ज़्यादातर छात्रवृत्तियों में हर साल नवीनीकरण '
      'की अर्ज़ी देनी होती है, और खिड़की आमतौर पर कुछ हफ़्तों की होती है — पिछले साल '
      'के अंक और उपस्थिति के साथ। खिड़की छूट जाए तो पैसा रुक जाता है, और कई '
      'योजनाओं में बाद में मिलता ही नहीं — वह साल चला जाता है। पहली किस्त मिलते ही '
      'नवीनीकरण की तारीख़ें लिख लें, और नोडल अधिकारी से कहें कि खिड़की खुलने पर '
      'बताएँ।',
  source: _nspUrl,
);

const _escalateScholarship = Advice(
  title: 'If the institute will not move, go above it',
  titleHi: 'संस्थान न सुने तो उससे ऊपर जाएँ',
  body: 'In order: the head of the institution in writing, the district '
      'welfare or education officer, the state nodal officer for the scheme, '
      'and the helpdesk on the National Scholarship Portal. For a central '
      'scheme, CPGRAMS at pgportal.gov.in. Carry the application number, the '
      'exact status words, and the dates you asked - a complaint that names a '
      'person and a date is answered.',
  bodyHi: 'इस क्रम में: संस्थान के प्रमुख को लिखित में, ज़िला कल्याण या शिक्षा '
      'अधिकारी, योजना के राज्य नोडल अधिकारी, और राष्ट्रीय छात्रवृत्ति पोर्टल का '
      'हेल्पडेस्क। केंद्र की योजना के लिए pgportal.gov.in पर सीपीग्राम्स। अर्ज़ी संख्या, '
      'स्थिति के ठीक शब्द, और जिन तारीख़ों को पूछा — ये साथ रखें; जिस शिकायत में '
      'नाम और तारीख़ होती है, उसका जवाब देना पड़ता है।',
  source: _nspUrl,
);

const _applyFresh = Advice(
  title: 'Apply on the National Scholarship Portal, once, carefully',
  titleHi: 'राष्ट्रीय छात्रवृत्ति पोर्टल पर एक बार, ध्यान से अर्ज़ी दें',
  body: 'One application on scholarships.gov.in puts you in front of most '
      'central scholarships at once, and many state ones. The application is '
      'free and the window usually runs through the autumn. Two mistakes '
      'account for most rejections: a name that does not match Aadhaar '
      'exactly, and an income certificate that is out of date. Fix both '
      'before you start, not after.',
  bodyHi: 'scholarships.gov.in पर एक अर्ज़ी से ज़्यादातर केंद्रीय और कई राज्य '
      'छात्रवृत्तियों के लिए नाम चला जाता है। अर्ज़ी मुफ़्त है और खिड़की आमतौर पर '
      'पतझड़ के महीनों में खुली रहती है। अस्वीकृति की दो ही बड़ी वजहें होती हैं: नाम '
      'आधार से हूबहू न मिलना, और आय प्रमाण पत्र पुराना होना। दोनों शुरू करने से '
      'पहले ठीक कर लें, बाद में नहीं।',
  source: _nspUrl,
);

List<Advice> scholarshipRoute(ScholarshipStage stage) => switch (stage) {
      ScholarshipStage.neverApplied => [_applyFresh, _bankMismatch],
      ScholarshipStage.appliedNoStatus => [
          _checkPortal,
          _instituteStep,
          _escalateScholarship,
        ],
      ScholarshipStage.instituteNotVerified => [
          _instituteStep,
          _escalateScholarship,
          _checkPortal,
        ],
      ScholarshipStage.sanctionedNotPaid => [
          _bankMismatch,
          _checkPortal,
          _escalateScholarship,
        ],
      ScholarshipStage.renewalMissed => [_renewal, _escalateScholarship],
    };

class ScholarshipStuckPage extends StatefulWidget {
  const ScholarshipStuckPage({super.key});

  @override
  State<ScholarshipStuckPage> createState() => _ScholarshipStuckPageState();
}

class _ScholarshipStuckPageState extends State<ScholarshipStuckPage> {
  ScholarshipStage? _stage;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    Widget pick(ScholarshipStage s, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _stage == s,
          onTap: () => setState(() => _stage = s),
        );

    return ToolScaffold(
      goal: 4,
      title: hi ? 'छात्रवृत्ति का पैसा नहीं आया' : 'The scholarship money has not come',
      children: [
        ToolNote(hi
            ? 'मंज़ूर हुई और न आई छात्रवृत्ति ही वह सबसे आम वजह है जिससे घर का पहला '
                'स्नातक पढ़ाई छोड़ देता है। और अटकाव लगभग हमेशा चार में से एक क़दम पर '
                'होता है, जिनमें से कोई भी छात्र को दिखता नहीं। पहले स्थिति पढ़ें।'
            : 'A scholarship sanctioned and never paid is the commonest '
                'reason a family\'s first graduate stops studying. The break '
                'is almost always at one of four steps, none of which the '
                'student can see. Start by reading the status.'),
        ToolQuestion(hi ? 'कहाँ तक पहुँचे हैं' : 'How far have you got'),
        pick(ScholarshipStage.neverApplied, 'We have not applied yet',
            'अभी अर्ज़ी दी ही नहीं'),
        pick(ScholarshipStage.appliedNoStatus,
            'Applied, and nothing has happened since',
            'अर्ज़ी दी, उसके बाद कुछ नहीं हुआ'),
        pick(ScholarshipStage.instituteNotVerified,
            'The status says the institute has not verified it',
            'स्थिति में लिखा है कि संस्थान ने सत्यापन नहीं किया'),
        pick(ScholarshipStage.sanctionedNotPaid,
            'It was sanctioned but the money never arrived',
            'मंज़ूर हो गई लेकिन पैसा नहीं आया'),
        pick(ScholarshipStage.renewalMissed,
            'It came once, then stopped', 'एक बार आई, फिर बंद हो गई'),
        if (_stage != null)
          AdviceList(
            heading: hi ? 'इसी क्रम में देखें' : 'Work through these in order',
            items: scholarshipRoute(_stage!),
          ),
      ],
    );
  }
}

// --- Education loan ---------------------------------------------------

/// Monthly payment on a reducing-balance loan.
///
/// `principal` in rupees, `annualRatePercent` as a percentage, `months`
/// the number of instalments. Returns 0 for nonsense input rather than
/// throwing, because this runs on every keystroke.
double monthlyEmi(double principal, double annualRatePercent, int months) {
  if (principal <= 0 || months <= 0) return 0;
  final r = annualRatePercent / 12 / 100;
  if (r <= 0) return principal / months;
  final f = math.pow(1 + r, months).toDouble();
  return principal * r * f / (f - 1);
}

/// Interest limits that decide which help applies.
const vidyalaxmiIncomeLimit = 800000;
const vidyalaxmiLoanLimit = 1000000;
const vidyalaxmiSubventionPercent = 3;
const collateralFreeGuaranteeLimit = 750000;
const csisIncomeLimit = 450000;

class EducationLoanPage extends StatefulWidget {
  const EducationLoanPage({super.key});

  @override
  State<EducationLoanPage> createState() => _EducationLoanPageState();
}

class _EducationLoanPageState extends State<EducationLoanPage> {
  final _amount = TextEditingController();
  final _rate = TextEditingController(text: '9.5');
  final _income = TextEditingController();
  int _years = 7;

  @override
  void dispose() {
    _amount.dispose();
    _rate.dispose();
    _income.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    final rate = double.tryParse(_rate.text.trim()) ?? 0;
    final income = double.tryParse(_income.text.trim());
    final months = _years * 12;
    final emi = monthlyEmi(amount, rate, months);
    final totalPaid = emi * months;
    final interest = totalPaid - amount;
    final subventionFits =
        income != null && income <= vidyalaxmiIncomeLimit && amount > 0;

    return ToolScaffold(
      goal: 4,
      title: hi ? 'शिक्षा ऋण: सब्सिडी और किस्त' : 'Education loan: subsidy and the EMI',
      children: [
        ToolNote(hi
            ? 'ऋण लेने से पहले दो संख्याएँ जान लेनी चाहिए: महीने की किस्त, और पूरे '
                'समय में ब्याज कितना बनेगा। दूसरी संख्या ही चौंकाती है, और वही कोई '
                'नहीं बताता।'
            : 'Two numbers should be known before signing: the monthly '
                'instalment, and what the interest adds up to over the whole '
                'term. It is the second that startles people, and the second '
                'that nobody mentions.'),
        ToolQuestion(hi ? 'ऋण की रक़म' : 'Loan amount'),
        ToolNumber(
          controller: _amount,
          label: hi ? 'रुपये' : 'Rupees',
          maxDigits: 8,
          icon: Icons.school_outlined,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolNumber(
          controller: _rate,
          label: hi ? 'ब्याज दर, सालाना %' : 'Interest rate, % a year',
          decimal: true,
          maxDigits: 5,
          icon: Icons.percent,
          onChanged: (_) => setState(() {}),
        ),
        ToolQuestion(hi ? 'चुकाने की अवधि' : 'Repayment period'),
        DropdownButtonFormField<int>(
          initialValue: _years,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: hi ? 'साल' : 'Years',
            isDense: true,
          ),
          items: [
            for (final y in const [5, 7, 10, 12, 15])
              DropdownMenuItem(
                value: y,
                child: Text(hi ? '$y साल' : '$y years'),
              ),
          ],
          onChanged: (v) => setState(() => _years = v ?? _years),
        ),
        if (amount > 0 && emi > 0) ...[
          ToolAnswer(
            headline: hi
                ? 'महीने की किस्त ₹${emi.round()}'
                : 'Monthly instalment ₹${emi.round()}',
            detail: hi
                ? 'पूरे $_years साल में कुल ₹${totalPaid.round()} जाएगा, जिसमें '
                    '₹${interest.round()} सिर्फ़ ब्याज है। किस्त पढ़ाई ख़त्म होने के बाद '
                    'शुरू होती है — आमतौर पर कोर्स ख़त्म होने के छह महीने से एक साल बाद। '
                    'उस समय तक जुड़ने वाला ब्याज भी आमतौर पर मूलधन में जुड़ जाता है, '
                    'इसलिए बैंक से यह पूछें: "मेरी पहली किस्त कब और कितनी बनेगी?"'
                : 'Over the whole $_years years that is ₹${totalPaid.round()} '
                    'paid, of which ₹${interest.round()} is interest alone. '
                    'The instalments start after the course ends - usually six '
                    'months to a year after. The interest that builds until '
                    'then is normally added to the principal, so the question '
                    'to ask the bank is: "when does my first instalment fall '
                    'due, and how much will it be?"',
            tone: ToolTone.plain,
            icon: Icons.calculate_outlined,
          ),
          const SizedBox(height: 6),
          ToolLine(hi ? 'ऋण' : 'Loan', '₹${amount.round()}'),
          ToolLine(hi ? 'ब्याज, कुल' : 'Interest, in total',
              '₹${interest.round()}', strong: true),
          ToolLine(hi ? 'कुल चुकाना' : 'Total repaid', '₹${totalPaid.round()}'),
        ],
        ToolQuestion(hi ? 'परिवार की सालाना आय' : 'Family income a year'),
        ToolNumber(
          controller: _income,
          label: hi ? 'रुपये' : 'Rupees',
          maxDigits: 8,
          icon: Icons.family_restroom_outlined,
          onChanged: (_) => setState(() {}),
        ),
        if (income != null && income > 0) ...[
          if (subventionFits)
            ToolAnswer(
              headline: hi
                  ? 'ब्याज में छूट बनती है — ज़रूर पूछें'
                  : 'An interest subsidy may apply - ask for it',
              detail: hi
                  ? 'पीएम-विद्यालक्ष्मी में ₹8 लाख तक की सालाना पारिवारिक आय पर '
                      '₹10 लाख तक के ऋण पर 3% ब्याज छूट मिलती है, और यह चुने हुए '
                      'उच्च गुणवत्ता संस्थानों में मेरिट से दाख़िला लेने वालों के लिए है। '
                      'इसमें ज़मानत और तीसरे व्यक्ति की गारंटी नहीं चाहिए — ₹7.5 लाख तक '
                      'के ऋण पर केंद्र सरकार की गारंटी होती है। दूसरे साल से छूट जारी '
                      'रहने के लिए पढ़ाई का नतीजा ठीक होना ज़रूरी है।'
                  : 'PM-Vidyalaxmi gives a 3% interest subvention on loans up '
                      'to ₹10 lakh where annual family income is up to ₹8 '
                      'lakh, for students admitted on merit to selected '
                      'quality institutions. It needs no collateral and no '
                      'third-party guarantee - loans up to ₹7.5 lakh carry a '
                      'central government guarantee. Keeping the subvention '
                      'from the second year on depends on satisfactory '
                      'academic performance.',
              tone: ToolTone.good,
              icon: Icons.savings_outlined,
            )
          else
            ToolAnswer(
              headline: hi
                  ? 'पीएम-विद्यालक्ष्मी की आय सीमा से ऊपर'
                  : 'Above the PM-Vidyalaxmi income limit',
              detail: hi
                  ? 'छूट की सीमा ₹8 लाख सालाना आय है। उससे ऊपर भी ऋण मिलता है, और '
                      '₹7.5 लाख तक बिना ज़मानत की सरकारी गारंटी वाली व्यवस्था बनी रहती '
                      'है — बैंक से उसी का नाम लेकर पूछें। राज्य की अपनी योजनाएँ भी हो '
                      'सकती हैं।'
                  : 'The subvention limit is ₹8 lakh of annual income. Loans '
                      'are available above that, and the collateral-free '
                      'government guarantee up to ₹7.5 lakh still stands - ask '
                      'the bank for it by name. Your state may run its own '
                      'scheme too.',
              tone: ToolTone.plain,
              icon: Icons.info_outline,
            ),
          ToolNote(hi
              ? 'एक पुरानी योजना भी चल रही है: केंद्रीय क्षेत्र ब्याज सब्सिडी, जिसमें '
                  '₹4.5 लाख तक की आय पर पढ़ाई और मोहलत की अवधि का पूरा ब्याज सरकार '
                  'देती है, तकनीकी और व्यावसायिक कोर्सों के लिए। दोनों का नाम लेकर बैंक '
                  'में पूछें — बैंक अपने आप नहीं बताता।'
              : 'An older scheme also runs: the Central Sector Interest '
                  'Subsidy, where for family income up to ₹4.5 lakh the '
                  'government pays the whole interest during the course and '
                  'the moratorium, for technical and professional courses. '
                  'Ask the bank about both by name - a bank does not '
                  'volunteer them.'),
        ],
        const SizedBox(height: 14),
        Text(hi ? 'बैंक में यह ज़रूर पूछें' : 'Ask the bank these, in writing',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const ToolChecklist(
          storageKey: 'edu_loan_asks_v1',
          items: [
            CheckItem('rate', 'Is the rate fixed or floating, and what '
                'decides it', 'दर तय है या बदलने वाली, और किससे तय होती है'),
            CheckItem('moratorium', 'When does the first instalment fall '
                'due, and how much', 'पहली किस्त कब और कितनी बनेगी'),
            CheckItem('capitalise', 'Is the interest during the course added '
                'to the principal', 'पढ़ाई के दौरान का ब्याज मूलधन में जुड़ेगा या नहीं'),
            CheckItem('subsidy', 'Which interest subsidy applies, and who '
                'files for it', 'कौन सी ब्याज छूट बनती है, और अर्ज़ी कौन देगा'),
            CheckItem('collateral', 'Confirm no collateral is needed up to '
                '₹7.5 lakh', 'पक्का करें कि ₹7.5 लाख तक ज़मानत नहीं चाहिए'),
            CheckItem('insurance', 'Is any insurance being added, and is it '
                'optional', 'कोई बीमा जोड़ा जा रहा है, और वह ज़रूरी है या नहीं',
                noteEn: 'Often added without being mentioned, and it raises '
                    'the amount you borrow.',
                noteHi: 'अक्सर बताए बिना जोड़ दिया जाता है, और इससे ऋण की रक़म बढ़ '
                    'जाती है।'),
            CheckItem('prepay', 'Any charge for repaying early',
                'जल्दी चुकाने पर कोई शुल्क है या नहीं'),
            CheckItem('written', 'Get the refusal in writing if they say no',
                'मना करें तो कारण लिखित में लें'),
          ],
        ),
        const SourceNote(
            text: 'PM-Vidyalaxmi portal', url: _pmVidyalaxmiUrl),
        const SourceNote(
            text: 'PM-Vidyalaxmi terms, Press Information Bureau',
            url: _pmVidyalaxmiPibUrl),
        const SourceNote(
            text: 'Vidya Lakshmi - education loan portal',
            url: _vidyaLakshmiUrl),
      ],
    );
  }
}
