import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/tool_kit.dart';

/// Fraud and safety: the first hour after an online fraud, a lost phone,
/// and a bribe demanded.
///
/// None of these screens keeps anything. The online fraud screen is built
/// to be read by someone whose hands are shaking, so it is one short list
/// in order, with the phone number first.

const _cyberUrl = 'https://cybercrime.gov.in/';
const _sancharUrl = 'https://sancharsaathi.gov.in/';
const _cvcUrl = 'https://portal.cvc.gov.in/';
const _rbiUrl = 'https://www.rbi.org.in/';

const cyberHelpline = '1930';

/// RBI's customer protection rules: no loss to the customer for an
/// unauthorised electronic transaction caused by a third-party breach,
/// if reported within this many working days.
const rbiZeroLiabilityDays = 3;

/// Prevention of Corruption Act, section 8: a person compelled to pay a
/// bribe is not liable if they report it within this many days.
const bribeReportDays = 7;

// --- Online fraud: the first hour -------------------------------------

class OnlineFraudPage extends StatelessWidget {
  const OnlineFraudPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 16,
      title: hi ? 'ऑनलाइन ठगी: पहला घंटा' : 'Online fraud: the first hour',
      children: [
        ToolAnswer(
          headline: hi ? 'अभी $cyberHelpline पर फ़ोन' : 'Call $cyberHelpline now',
          detail: hi
              ? 'जितनी जल्दी, उतना अच्छा। जल्दी सूचना मिलने पर पैसा ठग के खाते में ही '
                  'रोका जा सकता है, इससे पहले कि वह आगे निकाल ले। फ़ोन न लगे तो '
                  'cybercrime.gov.in पर शिकायत दर्ज करें।'
              : 'The faster the better. Reported quickly, the money can be held '
                  'in the fraudster\'s account before it is moved on. If the call '
                  'does not go through, file on cybercrime.gov.in.',
          tone: ToolTone.bad,
          icon: Icons.phone_in_talk_outlined,
        ),
        const SizedBox(height: 12),
        ToolSteps(
          steps: hi
              ? const [
                  '$cyberHelpline पर फ़ोन, या cybercrime.gov.in पर शिकायत। शिकायत संख्या '
                      'लिख लें।',
                  'अपने बैंक के ग्राहक सेवा नंबर पर फ़ोन करके कार्ड, नेट बैंकिंग और '
                      'यूपीआई रुकवाएँ। नंबर कार्ड के पीछे या बैंक के ऐप से लें — इंटरनेट '
                      'पर खोजा नंबर नहीं।',
                  'हर लेन-देन की संख्या (यूटीआर), तारीख़-समय और रक़म लिख लें; ठग का नंबर, '
                      'यूपीआई आईडी या वेबसाइट भी।',
                  'संदेश, कॉल लॉग और स्क्रीनशॉट मिटाएँ नहीं।',
                  'फ़ोन में कोई स्क्रीन-शेयर या "रिमोट" ऐप डलवाया गया हो तो उसे हटाएँ, '
                      'और ईमेल, बैंक और यूपीआई के पासवर्ड और पिन बदलें।',
                  'उस नंबर की सूचना संचार साथी के "चक्षु" पर दें, ताकि दूसरों को भी फ़ोन '
                      'न आए।',
                ]
              : const [
                  'Call $cyberHelpline, or file on cybercrime.gov.in. Write down '
                      'the complaint number.',
                  'Call your bank\'s customer care to block the card, net '
                      'banking and UPI. Take the number from the back of the '
                      'card or the bank\'s app - not one found by searching '
                      'online.',
                  'Note every transaction reference (UTR), the date and time, '
                      'and the amount; and the fraudster\'s number, UPI ID or '
                      'website.',
                  'Do not delete messages, call logs or screenshots.',
                  'If you were made to install a screen-sharing or "remote" '
                      'app, remove it, and change your email, bank and UPI '
                      'passwords and PINs.',
                  'Report the number on Sanchar Saathi\'s "Chakshu", so others '
                      'are not called by it.',
                ],
        ),
        const SizedBox(height: 12),
        ToolAnswer(
          headline: hi
              ? '$rbiZeroLiabilityDays कामकाजी दिन — बैंक का नियम'
              : '$rbiZeroLiabilityDays working days - the bank rule',
          detail: hi
              ? 'रिज़र्व बैंक के नियम में, अगर ठगी किसी तीसरे की सेंध से हुई और आपने '
                  'ओटीपी या पिन नहीं बताया था, और आपने बैंक को $rbiZeroLiabilityDays '
                  'कामकाजी दिन में बताया — तो नुक़सान आपका नहीं, बैंक का है। ओटीपी या पिन '
                  'ख़ुद बताया हो, तब भी बैंक को तुरंत बताएँ — सूचना के बाद का हर नुक़सान '
                  'बैंक के ज़िम्मे आता है।'
              : 'Under the Reserve Bank\'s rules, if the fraud came from a third '
                  'party\'s breach, you did not share the OTP or PIN, and you told '
                  'the bank within $rbiZeroLiabilityDays working days - the loss '
                  'is the bank\'s, not yours. Even if you did share the OTP or '
                  'PIN, tell the bank at once - any loss after you report it '
                  'falls on the bank.',
          tone: ToolTone.plain,
          icon: Icons.account_balance_outlined,
        ),
        const SourceNote(
            text: 'National Cyber Crime Reporting Portal', url: _cyberUrl),
        const SourceNote(text: 'Reserve Bank of India', url: _rbiUrl),
      ],
    );
  }
}

// --- Lost phone -------------------------------------------------------

class LostPhonePage extends StatelessWidget {
  const LostPhonePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 16,
      title: hi ? 'फ़ोन खो गया: बंद करवाएँ और ढूँढ़ें' : 'Lost phone: block and trace',
      children: [
        ToolNote(hi
            ? 'खोए फ़ोन से सबसे बड़ा ख़तरा पैसे का है, फ़ोन का नहीं — उसमें बैंक और यूपीआई '
                'हैं। इसलिए क्रम यह है: पहले सिम और पैसे के रास्ते बंद, फिर फ़ोन।'
            : 'The biggest risk from a lost phone is to your money, not the '
                'phone - the bank and UPI are on it. So the order is: shut the '
                'SIM and the money routes first, then the handset.'),
        const SizedBox(height: 12),
        ToolSteps(
          steps: hi
              ? const [
                  'मोबाइल कंपनी को फ़ोन करके सिम बंद करवाएँ, और उसी नंबर की नई सिम ले लें '
                      '— ओटीपी उसी नंबर पर आते हैं।',
                  'बैंक को फ़ोन करके यूपीआई और नेट बैंकिंग रुकवाएँ।',
                  'किसी दूसरे फ़ोन या कंप्यूटर से गूगल (या ऐपल) खाते में जाकर फ़ोन ढूँढ़ें, '
                      'लॉक करें, या मिटाएँ, और बाक़ी डिवाइस से साइन-आउट करें।',
                  'थाने में या राज्य के पोर्टल पर खोने या चोरी की रिपोर्ट दर्ज करें, और '
                      'उसकी संख्या लें।',
                  'संचार साथी पोर्टल पर "खोया/चोरी हुआ मोबाइल ब्लॉक करें" में आईएमईआई '
                      'नंबर, पुलिस रिपोर्ट की संख्या और पहचान पत्र डालें। फ़ोन सब नेटवर्क '
                      'पर बंद हो जाता है, और कोई उसमें सिम डाले तो पता चलता है।',
                  'फ़ोन मिल जाए तो उसी पोर्टल से उसे फिर चालू करवाएँ।',
                ]
              : const [
                  'Call the mobile company to block the SIM, and get a new SIM on '
                      'the same number - the OTPs come to it.',
                  'Call the bank to stop UPI and net banking.',
                  'From another phone or computer, go into the Google (or Apple) '
                      'account to locate, lock or erase the phone, and sign out '
                      'of other devices.',
                  'Report the loss or theft at the police station or on the '
                      'state portal, and take the number.',
                  'On the Sanchar Saathi portal, under "Block your lost/stolen '
                      'mobile", enter the IMEI, the police report number and an '
                      'ID. The phone is blocked on every network, and if someone '
                      'puts a SIM in it, it shows up.',
                  'If the phone turns up, unblock it from the same portal.',
                ],
        ),
        const SizedBox(height: 12),
        ToolAnswer(
          headline: hi ? 'आज ही: अपना आईएमईआई लिख लें' : 'Today: write down your IMEI',
          detail: hi
              ? 'फ़ोन पर *#06# डायल करें — आईएमईआई नंबर दिखेगा। उसे फ़ोन के डिब्बे के साथ, '
                  'या किसी काग़ज़ पर, या घर के किसी और के फ़ोन में लिख लें। फ़ोन खोने के '
                  'बाद यह नंबर ढूँढ़ना सबसे मुश्किल काम होता है।'
              : 'Dial *#06# on the phone - the IMEI shows. Write it down with the '
                  'box, on paper, or in someone else\'s phone at home. After the '
                  'phone is lost, finding this number is the hardest part.',
          tone: ToolTone.good,
          icon: Icons.edit_note_outlined,
        ),
        const SourceNote(text: 'Sanchar Saathi', url: _sancharUrl),
      ],
    );
  }
}

// --- Bribe demanded ---------------------------------------------------

class BribePage extends StatelessWidget {
  const BribePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 16,
      title: hi ? 'रिश्वत माँगी गई' : 'Bribe demanded',
      children: [
        ToolAnswer(
          headline: hi ? 'माँगना भी अपराध है, देना भी' : 'Asking is an offence, and so is paying',
          detail: hi
              ? 'भ्रष्टाचार निवारण अधिनियम में रिश्वत माँगना अपराध है, और 2018 से रिश्वत '
                  'देना भी। एक अपवाद है: जिसे मजबूर करके रिश्वत दिलवाई गई, वह अगर '
                  '$bribeReportDays दिन के भीतर पुलिस या भ्रष्टाचार निरोधक ब्यूरो को बता '
                  'दे, तो उस पर मामला नहीं बनता।'
              : 'Under the Prevention of Corruption Act, asking for a bribe is an '
                  'offence, and since 2018 paying one is too. There is one '
                  'exception: a person forced to pay who reports it to the '
                  'police or the anti-corruption bureau within $bribeReportDays '
                  'days is not liable.',
          tone: ToolTone.plain,
          icon: Icons.gavel_outlined,
        ),
        const SizedBox(height: 12),
        Text(hi ? 'शिकायत से पहले लिख लें' : 'Write down before you report',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'माँगने वाले का नाम और पद, और दफ़्तर',
                  'तारीख़, समय, और कितना माँगा',
                  'किस काम के लिए — और उस काम का आवेदन या रसीद नंबर',
                  'कोई और मौजूद था तो उसका नाम',
                ]
              : const [
                  'The name and post of the person asking, and the office',
                  'The date, the time, and how much was asked',
                  'For which work - and that work\'s application or receipt '
                      'number',
                  'The name of anyone else who was there',
                ],
        ),
        const SizedBox(height: 12),
        Text(hi ? 'कहाँ शिकायत करें' : 'Where to report',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'राज्य सरकार का कर्मचारी: राज्य का भ्रष्टाचार निरोधक ब्यूरो या सतर्कता '
                      'विभाग — कई राज्यों में हेल्पलाइन 1064 — या लोकायुक्त',
                  'केंद्र सरकार का कर्मचारी (रेलवे, डाक, बैंक, आयकर आदि): केंद्रीय सतर्कता '
                      'आयोग का शिकायत पोर्टल, या सीबीआई की भ्रष्टाचार निरोधक शाखा',
                  'ब्यूरो चाहे तो "ट्रैप" लगाता है — चिह्नित नोटों के साथ, अपनी टीम के '
                      'साथ। यह सिर्फ़ ब्यूरो के ज़रिये हो; ख़ुद अपना जाल न बिछाएँ',
                ]
              : const [
                  'A state government employee: the state anti-corruption bureau '
                      'or vigilance department - helpline 1064 in many states - or '
                      'the Lokayukta',
                  'A central government employee (railways, post, banks, income '
                      'tax and so on): the Central Vigilance Commission\'s '
                      'complaint portal, or the CBI\'s anti-corruption branch',
                  'The bureau may set a "trap" - with marked notes and its own '
                      'team. Do this only through the bureau; do not set up a '
                      'trap of your own',
                ],
        ),
        const SizedBox(height: 12),
        ToolNote(hi
            ? 'साथ-साथ अपना काम सरकारी रास्ते से आगे बढ़ाएँ: सूचना का अधिकार से अपने '
                'आवेदन की स्थिति पूछें, और सेवा का अधिकार क़ानून में तय समय निकल गया हो '
                'तो अपील करें। इसी लक्ष्य में "शिकायत का जवाब नहीं आया" देखें।'
            : 'Alongside, push your own work through the official route: ask '
                'the status of your application under the Right to Information, '
                'and appeal if the Right to Services time limit has passed. See '
                '"My complaint got no answer" in this goal.'),
        const SourceNote(
            text: 'Central Vigilance Commission - complaints', url: _cvcUrl),
      ],
    );
  }
}
