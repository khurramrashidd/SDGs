import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Two screens about the papers everything else depends on.
///
/// `AadhaarFixPage` exists because an Aadhaar centre is the one government
/// counter where people are most often overcharged, and the reason is
/// simple: nobody knows what the correct fee is. UIDAI publishes it. So
/// this screen says the figure before the trip, and says which services
/// cost nothing at all.
///
/// `LateCertificatePage` exists because a birth or death that was never
/// registered blocks a pension, a scholarship, a mutation and an insurance
/// claim, and families are told it is "too late now", which is not true at
/// any distance in time. There is a route at every delay. The route just
/// gets slower.

const _uidaiUrl =
    'https://www.uidai.gov.in/images/Aadhaar_Enrolment__and__Update__-__English.pdf';
const _myAadhaarUrl = 'https://myaadhaar.uidai.gov.in/';
const _crsUrl = 'https://dc.crsorgi.gov.in/crs/';

/// The official charge sheet, as published by UIDAI. Carried as data with
/// the date it was read, because these change and a wrong figure here is
/// worse than none: it is what someone will argue with at a counter.
const _feeAsOf = 'November 2026';
const aadhaarDemographicFee = 75;
const aadhaarBiometricFee = 125;
const aadhaarDocumentCentreFee = 75;

/// What is actually wrong. Each one has a different route, and two of them
/// do not need a centre visit at all.
enum AadhaarProblem {
  nameOrDob,
  address,
  mobileNotLinked,
  lostCard,
  biometricFails,
  childUpdate,
}

class AadhaarFixPage extends StatefulWidget {
  const AadhaarFixPage({super.key});

  @override
  State<AadhaarFixPage> createState() => _AadhaarFixPageState();
}

class _AadhaarFixPageState extends State<AadhaarFixPage> {
  AadhaarProblem? _problem;

  /// Where this has to be done, what it costs, and what to carry.
  ({String en, String hi, int fee, String feeNoteEn, String feeNoteHi})
      _route(AadhaarProblem p) => switch (p) {
            AadhaarProblem.nameOrDob => (
                en: 'A name or a date of birth is a demographic update, and '
                    'it has to be done at an Aadhaar centre with a '
                    'supporting document - a passport, a school leaving '
                    'certificate, a PAN card, a birth certificate. Date of '
                    'birth can usually be changed only once, so take the '
                    'strongest document you have, not the nearest one.',
                hi: 'नाम या जन्मतिथि "डेमोग्राफ़िक अपडेट" है, और यह आधार केंद्र पर '
                    'ही होता है, सहायक काग़ज़ के साथ — पासपोर्ट, स्कूल छोड़ने का '
                    'प्रमाण पत्र, पैन कार्ड, जन्म प्रमाण पत्र। जन्मतिथि आमतौर पर एक '
                    'ही बार बदली जा सकती है, इसलिए सबसे मज़बूत काग़ज़ लेकर जाएँ, '
                    'जो पास में हो वह नहीं।',
                fee: aadhaarDemographicFee,
                feeNoteEn: 'per visit, however many demographic fields you '
                    'change in that one visit',
                feeNoteHi: 'एक चक्कर का, उसी चक्कर में कितने भी डेमोग्राफ़िक '
                    'ख़ाने बदलवाएँ',
              ),
            AadhaarProblem.address => (
                en: 'An address change does not need a centre. Do it on the '
                    'myAadhaar portal with any accepted proof of address, '
                    'and the document upload is free there. If you have no '
                    'document in your own name, the portal has a '
                    'head-of-family route where a relative whose Aadhaar '
                    'carries the address approves it.',
                hi: 'पता बदलवाने के लिए केंद्र जाने की ज़रूरत नहीं। myAadhaar '
                    'पोर्टल पर किसी भी मान्य पते के काग़ज़ से हो जाता है, और वहाँ '
                    'काग़ज़ अपलोड करना मुफ़्त है। अपने नाम का कोई काग़ज़ न हो तो '
                    'पोर्टल पर "परिवार के मुखिया" का रास्ता है, जिसमें वह रिश्तेदार '
                    'मंज़ूरी देता है जिसके आधार पर वही पता दर्ज है।',
                fee: 0,
                feeNoteEn: 'online on the portal; ₹$aadhaarDocumentCentreFee '
                    'if you have it done at a centre instead',
                feeNoteHi: 'पोर्टल पर ऑनलाइन; केंद्र पर कराएँ तो '
                    '₹$aadhaarDocumentCentreFee',
              ),
            AadhaarProblem.mobileNotLinked => (
                en: 'Linking or changing the mobile number is the one that '
                    'cannot be done online, by design - whoever holds the '
                    'number can receive every OTP. It is a centre visit, '
                    'and no document is needed for it, only you and your '
                    'Aadhaar. This is worth doing even if nothing is wrong: '
                    'almost every scheme now sends its OTP to the number on '
                    'Aadhaar, and a number nobody has used for years is why '
                    'half of all e-KYC fails.',
                hi: 'मोबाइल नंबर जोड़ना या बदलना ही वह काम है जो ऑनलाइन नहीं हो '
                    'सकता, और जानबूझकर नहीं हो सकता — जिसके पास नंबर है उसे हर '
                    'ओटीपी मिल जाएगा। इसके लिए केंद्र जाना होता है, और कोई काग़ज़ '
                    'नहीं चाहिए, बस आप और आपका आधार। यह काम कुछ ग़लत न हो तब '
                    'भी कराने लायक़ है: अब लगभग हर योजना ओटीपी आधार वाले नंबर पर '
                    'भेजती है, और बरसों से बंद पड़ा नंबर ही आधी ई-केवाईसी फ़ेल होने '
                    'की वजह है।',
                fee: aadhaarDemographicFee,
                feeNoteEn: 'at the centre. No document required',
                feeNoteHi: 'केंद्र पर। कोई काग़ज़ ज़रूरी नहीं',
              ),
            AadhaarProblem.lostCard => (
                en: 'A lost card is not a lost Aadhaar. The number is yours '
                    'permanently, and a download of the e-Aadhaar PDF from '
                    'the myAadhaar portal is legally the same document - '
                    'offices must accept it, and it is free. If you have '
                    'forgotten the number itself, the portal retrieves it '
                    'on your name and registered mobile. Pay nobody for a '
                    'plastic "smart card": UIDAI does not issue one and the '
                    'shops selling them are selling nothing.',
                hi: 'कार्ड खोना आधार खोना नहीं है। नंबर हमेशा के लिए आपका है, और '
                    'myAadhaar पोर्टल से डाउनलोड किया ई-आधार पीडीएफ़ क़ानूनी रूप '
                    'से वही दस्तावेज़ है — कार्यालयों को उसे मानना होता है, और वह '
                    'मुफ़्त है। नंबर ही भूल गए हों तो पोर्टल नाम और रजिस्टर्ड मोबाइल '
                    'से निकाल देता है। प्लास्टिक के "स्मार्ट कार्ड" के पैसे किसी को न '
                    'दें: यूआईडीएआई ऐसा कोई कार्ड जारी नहीं करता।',
                fee: 0,
                feeNoteEn: 'e-Aadhaar download is free. A PVC card ordered '
                    'from UIDAI itself is ₹50, posted to you, and is '
                    'optional',
                feeNoteHi: 'ई-आधार डाउनलोड मुफ़्त। यूआईडीएआई से ही मँगाया पीवीसी '
                    'कार्ड ₹50 का है, डाक से आता है, और ज़रूरी नहीं है',
              ),
            AadhaarProblem.biometricFails => (
                en: 'Fingerprints that no longer read are normal after years '
                    'of field or construction work, and they are not a '
                    'refusal: a biometric update at a centre re-records '
                    'them, and where fingers genuinely cannot be read, iris '
                    'authentication and face authentication both work and '
                    'offices are required to offer them. If a counter says '
                    '"your thumb does not work, come back", ask for iris or '
                    'face authentication by name.',
                hi: 'खेत या निर्माण के काम के बाद उँगलियों के निशान न पढ़े जाना आम '
                    'है, और यह मना करने की वजह नहीं है: केंद्र पर बायोमेट्रिक '
                    'अपडेट से निशान दोबारा दर्ज हो जाते हैं, और जहाँ उँगलियाँ सचमुच '
                    'नहीं पढ़ी जा सकतीं वहाँ आईरिस और चेहरे से पहचान दोनों चलती हैं '
                    'और कार्यालयों को उन्हें देना होता है। काउंटर पर कोई कहे "अँगूठा '
                    'नहीं चल रहा, बाद में आओ" — तो आईरिस या फ़ेस ऑथेंटिकेशन का नाम '
                    'लेकर माँगें।',
                fee: aadhaarBiometricFee,
                feeNoteEn: 'for a biometric update at a centre',
                feeNoteHi: 'केंद्र पर बायोमेट्रिक अपडेट का',
              ),
            AadhaarProblem.childUpdate => (
                en: 'A child\'s Aadhaar has to have its biometrics taken '
                    'twice as they grow: once after the fifth birthday and '
                    'again after the fifteenth. This is the Mandatory '
                    'Biometric Update, and if it is not done the Aadhaar '
                    'can stop authenticating - which shows up as a '
                    'scholarship or a midday-meal record failing, and '
                    'nobody connects the two. Both of these updates are '
                    'free when done in the window, and the MBU has to be a '
                    'visit of its own: it cannot be combined with any other '
                    'change.',
                hi: 'बच्चे के आधार में बायोमेट्रिक दो बार लिए जाते हैं: पाँच साल के '
                    'बाद और पंद्रह साल के बाद। इसे अनिवार्य बायोमेट्रिक अपडेट '
                    '(एमबीयू) कहते हैं, और न कराने पर आधार से पहचान रुक सकती है — '
                    'जो आगे छात्रवृत्ति या मध्याह्न भोजन के रिकॉर्ड में अटकने के रूप '
                    'में दिखता है, और कोई दोनों को जोड़कर नहीं देखता। समय पर कराने '
                    'पर ये दोनों मुफ़्त हैं, और एमबीयू अलग चक्कर में ही होता है: उसके '
                    'साथ कोई और बदलाव नहीं कराया जा सकता।',
                fee: 0,
                feeNoteEn: 'free at ages 5 to 7 for the first update, and at '
                    '15 to 17 for the first or second',
                feeNoteHi: '5 से 7 साल में पहला अपडेट, और 15 से 17 में पहला या '
                    'दूसरा — मुफ़्त',
              ),
          };

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    Widget pick(AadhaarProblem p, String en, String h) => SelectionTile(
          label: hi ? h : en,
          selected: _problem == p,
          onTap: () => setState(() => _problem = p),
        );

    final route = _problem == null ? null : _route(_problem!);

    return ToolScaffold(
      goal: 1,
      title: hi ? 'आधार की दिक़्क़त' : 'An Aadhaar problem',
      children: [
        ToolNote(hi
            ? 'आधार केंद्र पर सबसे ज़्यादा ज़रूरत से ज़्यादा पैसा लिया जाता है, और वजह '
                'सीधी है: शुल्क किसी को पता नहीं होता। यूआईडीएआई उसे छापता है। यहाँ '
                'वही लिखा है — जाने से पहले देख लें।'
            : 'The Aadhaar counter is where people are overcharged most, for '
                'one plain reason: nobody knows the fee. UIDAI publishes it. '
                'It is below - check it before the trip.'),
        ToolQuestion(hi ? 'क्या ठीक कराना है?' : 'What needs fixing?'),
        pick(AadhaarProblem.nameOrDob, 'Name or date of birth is wrong',
            'नाम या जन्मतिथि ग़लत है'),
        pick(AadhaarProblem.address, 'Address has changed',
            'पता बदल गया है'),
        pick(AadhaarProblem.mobileNotLinked,
            'Mobile number is old, or no OTP arrives',
            'मोबाइल नंबर पुराना है, या ओटीपी नहीं आता'),
        pick(AadhaarProblem.lostCard, 'The card is lost',
            'कार्ड खो गया है'),
        pick(AadhaarProblem.biometricFails,
            'Fingerprints are not being read',
            'उँगलियों के निशान नहीं पढ़े जा रहे'),
        pick(AadhaarProblem.childUpdate, 'A child\'s Aadhaar update',
            'बच्चे के आधार का अपडेट'),
        if (route != null) ...[
          ToolAnswer(
            headline: route.fee == 0
                ? (hi ? 'इसका कोई शुल्क नहीं' : 'This one costs nothing')
                : (hi ? 'शुल्क ₹${route.fee}' : 'The fee is ₹${route.fee}'),
            detail: hi ? route.feeNoteHi : route.feeNoteEn,
            tone: route.fee == 0 ? ToolTone.good : ToolTone.plain,
            icon: route.fee == 0
                ? Icons.money_off_csred_outlined
                : Icons.payments_outlined,
          ),
          const SizedBox(height: 10),
          ToolNote(hi ? route.hi : route.en),
          const SizedBox(height: 14),
          Text(hi ? 'पूरी शुल्क सूची' : 'The whole fee list',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ToolLine(hi ? 'नया आधार बनवाना' : 'New enrolment',
              hi ? 'मुफ़्त' : 'Free',
              strong: true),
          ToolLine(
              hi
                  ? 'नाम, जन्मतिथि, पता, मोबाइल (केंद्र पर)'
                  : 'Name, date of birth, address, mobile (at a centre)',
              '₹$aadhaarDemographicFee'),
          ToolLine(
              hi
                  ? 'बायोमेट्रिक अपडेट (निशान, आईरिस, फ़ोटो)'
                  : 'Biometric update (prints, iris, photo)',
              '₹$aadhaarBiometricFee'),
          ToolLine(
              hi
                  ? 'काग़ज़ अपडेट — पोर्टल पर ऑनलाइन'
                  : 'Document update - online on the portal',
              hi ? 'मुफ़्त' : 'Free'),
          ToolLine(
              hi ? 'काग़ज़ अपडेट — केंद्र पर' : 'Document update - at a centre',
              '₹$aadhaarDocumentCentreFee'),
          ToolLine(
              hi
                  ? 'बच्चे का अनिवार्य बायोमेट्रिक अपडेट (5-7, 15-17)'
                  : "Child's mandatory biometric update (5-7, 15-17)",
              hi ? 'मुफ़्त' : 'Free'),
          const SizedBox(height: 8),
          ToolNote(hi
              ? 'ये शुल्क $_feeAsOf में यूआईडीएआई की छपी सूची से लिए गए हैं। कुछ छूट '
                  'की तारीख़ें तय हैं और बदलती रहती हैं, इसलिए केंद्र पर पर्ची के नीचे छपा '
                  'शुल्क देख लें — और उससे ज़्यादा माँगा जाए तो 1947 पर शिकायत करें।'
              : 'These are from UIDAI\'s published list, read in $_feeAsOf. '
                  'Some of the free windows have end dates and do change, so '
                  'check the fee printed at the bottom of the slip at the '
                  'centre - and if more is asked for, complain on 1947.'),
          const SourceNote(
            text: 'UIDAI enrolment and update charges',
            url: _uidaiUrl,
          ),
          const SourceNote(
            text: 'myAadhaar portal - address and document updates',
            url: _myAadhaarUrl,
          ),
        ],
      ],
    );
  }
}

// --- A birth or death never registered --------------------------------

/// How long ago it happened. The law sets the gates, not the office.
///
/// Under the Registration of Births and Deaths Act, the event is to be
/// reported within 21 days. After that there are three gates: up to 30
/// days the registrar can register it on a late fee; from 30 days to a
/// year it needs the written permission of the District Registrar (or the
/// authority the state prescribes) and a self-attested document; beyond a
/// year it needs a magistrate's order.
///
/// Which magistrate is genuinely unsettled. The 2023 amendment to section
/// 13(3) names a District Magistrate, a Sub-Divisional Magistrate, or an
/// Executive Magistrate the DM authorises. The Gujarat High Court has
/// upheld that; the Bombay High Court has held that only a Judicial
/// Magistrate First Class may order it. So this screen says a magistrate's
/// order is needed and tells the reader to ask the registrar which office
/// their state sends it to, rather than stating one and being wrong in
/// half the country.
enum RegistrationDelay { within21, upTo30Days, upToOneYear, overOneYear }

/// The gate a delay of [days] falls into.
RegistrationDelay delayGate(int days) {
  if (days <= 21) return RegistrationDelay.within21;
  if (days <= 30) return RegistrationDelay.upTo30Days;
  if (days <= 365) return RegistrationDelay.upToOneYear;
  return RegistrationDelay.overOneYear;
}

class LateCertificatePage extends StatefulWidget {
  const LateCertificatePage({super.key});

  @override
  State<LateCertificatePage> createState() => _LateCertificatePageState();
}

class _LateCertificatePageState extends State<LateCertificatePage> {
  bool _isDeath = false;
  DateTime? _when;

  Future<void> _pick() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _when ?? now,
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked != null) setState(() => _when = picked);
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final days =
        _when == null ? null : DateTime.now().difference(_when!).inDays;
    final gate = days == null ? null : delayGate(days);
    final event = _isDeath
        ? (hi ? 'मृत्यु' : 'the death')
        : (hi ? 'जन्म' : 'the birth');

    return ToolScaffold(
      goal: 1,
      title: hi
          ? 'जन्म या मृत्यु का प्रमाण पत्र, देर से'
          : 'A birth or death certificate, late',
      children: [
        ToolNote(hi
            ? '"अब तो बहुत देर हो गई" — यह बात किसी भी देरी पर सच नहीं है। क़ानून में '
                'हर देरी का रास्ता है; देरी जितनी ज़्यादा, रास्ता उतना धीमा। बिना प्रमाण '
                'पत्र पेंशन, छात्रवृत्ति, दाख़िल-ख़ारिज और बीमे का दावा — चारों अटकते हैं, '
                'इसलिए यह काम टालने लायक़ नहीं है।'
            : '"It is too late now" is not true at any delay. The law has a '
                'route for every one of them; the longer the delay, the '
                'slower the route. Without the certificate a pension, a '
                'scholarship, a land mutation and an insurance claim all '
                'stall, so this is not a thing to leave.'),
        ToolQuestion(hi ? 'किसका प्रमाण पत्र' : 'Which certificate'),
        SelectionTile(
          label: hi ? 'जन्म' : 'Birth',
          selected: !_isDeath,
          onTap: () => setState(() => _isDeath = false),
        ),
        SelectionTile(
          label: hi ? 'मृत्यु' : 'Death',
          selected: _isDeath,
          onTap: () => setState(() => _isDeath = true),
        ),
        ToolQuestion(hi ? 'कब हुआ था' : 'When did it happen'),
        OutlinedButton.icon(
          onPressed: _pick,
          icon: const Icon(Icons.event_outlined),
          label: Text(_when == null
              ? (hi ? 'तारीख़ चुनें' : 'Pick the date')
              : '${_when!.day}/${_when!.month}/${_when!.year}'),
        ),
        if (gate != null && days != null) ...[
          const SizedBox(height: 16),
          if (gate == RegistrationDelay.within21)
            ToolAnswer(
              headline: hi
                  ? 'अभी समय है — सीधे रजिस्टर हो जाएगा'
                  : 'You are still in time - it registers straight away',
              detail: hi
                  ? '21 दिन के भीतर $event दर्ज कराना निःशुल्क है और इसमें किसी '
                      'मंज़ूरी की ज़रूरत नहीं। गाँव में पंचायत सचिव या एएनएम, शहर में '
                      'नगर पालिका, और अस्पताल में हुआ हो तो अस्पताल ही रजिस्ट्रार को '
                      'सूचना देता है — फिर भी ख़ुद जाकर पक्का कर लें और प्रमाण पत्र की '
                      'नक़लें ले लें।'
                  : 'Reporting $event within 21 days costs nothing and needs '
                      'nobody\'s permission. In a village it is the panchayat '
                      'secretary or the ANM, in a town the municipality, and '
                      'if it happened in a hospital the hospital reports it - '
                      'but go yourself and make sure, and take copies of the '
                      'certificate.',
              tone: ToolTone.good,
              icon: Icons.task_alt,
            )
          else if (gate == RegistrationDelay.upTo30Days)
            ToolAnswer(
              headline: hi
                  ? '$days दिन — रजिस्ट्रार विलंब शुल्क पर दर्ज कर देगा'
                  : '$days days - the registrar can register it on a late fee',
              detail: hi
                  ? '21 दिन के बाद और 30 दिन के भीतर वही रजिस्ट्रार दर्ज कर देता है, '
                      'सिर्फ़ एक छोटा विलंब शुल्क लगता है। किसी ऊपर की मंज़ूरी की '
                      'ज़रूरत नहीं — अगर कोई ऐसा कहे तो यही बात कहें।'
                  : 'After 21 days and within 30, the same registrar '
                      'registers it on a small late fee. No higher '
                      'permission is needed - say so if you are told '
                      'otherwise.',
              tone: ToolTone.plain,
              icon: Icons.schedule,
            )
          else if (gate == RegistrationDelay.upToOneYear)
            ToolAnswer(
              headline: hi
                  ? '$days दिन — ज़िला रजिस्ट्रार की लिखित मंज़ूरी चाहिए'
                  : '$days days - the District Registrar must permit it in '
                      'writing',
              detail: hi
                  ? '30 दिन से एक साल के बीच रजिस्ट्रार अपने आप दर्ज नहीं कर सकता: '
                      'ज़िला रजिस्ट्रार (या राज्य जो अधिकारी तय करे) की लिखित मंज़ूरी, '
                      'शुल्क, और एक स्व-सत्यापित काग़ज़ चाहिए। यह अदालत का काम नहीं '
                      'है — बहुत लोग यहीं डरकर रुक जाते हैं।'
                  : 'Between 30 days and a year the registrar cannot do it '
                      'alone: it needs the District Registrar\'s written '
                      'permission (or whichever authority your state '
                      'prescribes), a fee, and one self-attested document. '
                      'This is not a court matter - a lot of people stop '
                      'here out of fear that it is.',
              tone: ToolTone.warn,
              icon: Icons.assignment_outlined,
            )
          else
            ToolAnswer(
              headline: hi
                  ? 'एक साल से ज़्यादा — मजिस्ट्रेट के आदेश से होगा'
                  : 'More than a year - it takes a magistrate\'s order',
              detail: hi
                  ? 'एक साल के बाद दर्ज कराने के लिए मजिस्ट्रेट का आदेश चाहिए। कौन सा '
                      'मजिस्ट्रेट — यह राज्य पर है और इस पर अदालतों की राय अलग-अलग है, '
                      'इसलिए रजिस्ट्रार से यही पूछें कि "यहाँ एक साल से पुराने मामले किस '
                      'कार्यालय जाते हैं"। आदेश मिलने पर रजिस्ट्रार दर्ज करने से मना नहीं '
                      'कर सकता। यह होता है — हज़ारों बार होता है — बस दो-तीन महीने '
                      'लगते हैं।'
                  : 'Past a year it needs a magistrate\'s order. Which '
                      'magistrate depends on your state, and the courts '
                      'themselves differ on it, so ask the registrar the '
                      'plain question: "which office do cases older than a '
                      'year go to here?". Once the order exists the '
                      'registrar cannot refuse. This does happen - it '
                      'happens thousands of times - it just takes two or '
                      'three months.',
              tone: ToolTone.warn,
              icon: Icons.gavel_outlined,
            ),
          const SizedBox(height: 14),
          Text(hi ? 'जो काग़ज़ साथ ले जाएँ' : 'What to take with you',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          if (_isDeath)
            const ToolChecklist(
              storageKey: 'late_death_cert_v1',
              items: [
                CheckItem('proof', 'Hospital papers, or the cremation or '
                    'burial ground receipt',
                    'अस्पताल के काग़ज़, या श्मशान/क़ब्रिस्तान की रसीद'),
                CheckItem('id', 'The dead person\'s Aadhaar, ration card or '
                    'voter card', 'मृतक का आधार, राशन कार्ड या मतदाता पहचान पत्र'),
                CheckItem('informant', 'Your own Aadhaar, as the informant',
                    'सूचना देने वाले के नाते आपका अपना आधार'),
                CheckItem('affidavit', 'A self-attested statement of the date '
                    'and place', 'तारीख़ और जगह का स्व-सत्यापित बयान'),
                CheckItem('witness', 'Two people from the village or '
                    'neighbourhood who can confirm it',
                    'गाँव या मोहल्ले के दो लोग जो पुष्टि कर सकें'),
                CheckItem('copies', 'Ask for at least six copies of the '
                    'certificate', 'प्रमाण पत्र की कम से कम छह नक़लें माँगें',
                    noteEn: 'Bank, insurance, pension, land mutation, '
                        'electricity, phone - each office keeps one.',
                    noteHi: 'बैंक, बीमा, पेंशन, दाख़िल-ख़ारिज, बिजली, फ़ोन — हर '
                        'कार्यालय एक रख लेता है।'),
              ],
            )
          else
            const ToolChecklist(
              storageKey: 'late_birth_cert_v1',
              items: [
                CheckItem('proof', 'Hospital discharge papers, or the '
                    'ANM or anganwadi record',
                    'अस्पताल से छुट्टी के काग़ज़, या एएनएम/आँगनवाड़ी का रिकॉर्ड'),
                CheckItem('school', 'A school admission record, if the child '
                    'is already in school',
                    'स्कूल में दाख़िले का रिकॉर्ड, अगर बच्चा स्कूल जा रहा है',
                    noteEn: 'Often the strongest document a family has, and '
                        'the one nobody thinks to bring.',
                    noteHi: 'अक्सर परिवार के पास का सबसे मज़बूत काग़ज़, और वही जो '
                        'कोई लेकर नहीं जाता।'),
                CheckItem('parents', 'Both parents\' Aadhaar',
                    'माता-पिता दोनों का आधार'),
                CheckItem('marriage', 'Marriage certificate, if the office '
                    'asks for it', 'विवाह प्रमाण पत्र, अगर कार्यालय माँगे'),
                CheckItem('affidavit', 'A self-attested statement of the date '
                    'and place of birth',
                    'जन्म की तारीख़ और जगह का स्व-सत्यापित बयान'),
                CheckItem('witness', 'Two people who can confirm the birth',
                    'दो लोग जो जन्म की पुष्टि कर सकें'),
              ],
            ),
          ToolNote(hi
              ? 'कई राज्यों में यह अर्ज़ी ऑनलाइन भी ली जाती है। हर चक्कर की रसीद रखें, '
                  'और मना किया जाए तो कारण लिखित में माँगें।'
              : 'Several states take this application online as well. Keep '
                  'the receipt from every visit, and if you are refused, ask '
                  'for the reason in writing.'),
          const SourceNote(
            text: 'Civil Registration System, Office of the Registrar '
                'General of India',
            url: _crsUrl,
          ),
        ],
      ],
    );
  }
}
