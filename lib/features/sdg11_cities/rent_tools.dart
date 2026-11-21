import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// Renting: the agreement, the deposit, and the threat to throw you out.
///
/// Rent is a state subject and every state has its own Rent Control Act,
/// so this file carries almost no numbers. What it carries instead is the
/// handful of things that are the same everywhere: a written agreement
/// beats an oral one, a receipt beats a memory, and nobody may be put out
/// of a house except by an order.

const _mtaUrl = 'https://mohua.gov.in/';
const _consumerUrl = 'https://consumerhelpline.gov.in/';
const _nalsaUrl = 'https://nalsa.gov.in/';

/// The deposit ceiling in the Model Tenancy Act 2021. The Act is a model:
/// it binds a state only once that state adopts it, so the screen says so
/// rather than stating the ceiling as law everywhere.
const mtaDepositMonthsHome = 2;
const mtaDepositMonthsShop = 6;

// --- The agreement ----------------------------------------------------

class RentAgreementPage extends StatelessWidget {
  const RentAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 11,
      title: hi ? 'किरायानामा: क्या देखें' : 'Rent agreement: what to check',
      children: [
        ToolNote(hi
            ? 'ज़्यादातर झगड़े इसलिए होते हैं कि बात ज़ुबानी हुई थी और दोनों को '
                'अलग-अलग याद है। लिखित किरायानामा मकान मालिक के ख़िलाफ़ नहीं है — '
                'वह दोनों की याद को एक जगह बाँध देता है। दस्तख़त से पहले नीचे की '
                'हर बात देख लें।'
            : 'Most disputes happen because the terms were spoken and the '
                'two sides remember them differently. A written agreement is '
                'not against the landlord - it pins both memories to one '
                'piece of paper. Check every item below before signing.'),
        const SizedBox(height: 12),
        ToolChecklist(
          storageKey: 'rent_agreement_v1',
          introEn: 'Tick each one as you find it written in the agreement.',
          introHi: 'जो बात काग़ज़ में लिखी मिले, उस पर निशान लगाएँ।',
          items: const [
            CheckItem('rent', 'The rent, and the date of the month it is due',
                'किराया, और महीने की कौन सी तारीख़ को देना है',
                noteEn: 'Also how it is to be paid. Pay by bank transfer or '
                    'UPI if you can: it leaves a record that a cash payment '
                    'does not.',
                noteHi: 'यह भी कि कैसे देना है। बैंक या यूपीआई से दें तो रिकॉर्ड '
                    'बन जाता है, जो नक़द में नहीं बनता।'),
            CheckItem('increase', 'When and by how much the rent may rise',
                'किराया कब और कितना बढ़ेगा',
                noteEn: 'A fixed per cent once a year is the usual form. '
                    'Without this clause, any increase becomes an argument.',
                noteHi: 'साल में एक बार तय प्रतिशत, यह आम तरीक़ा है। यह बात न लिखी '
                    'हो तो हर बढ़ोतरी झगड़ा बन जाती है।'),
            CheckItem('deposit', 'The deposit amount, and when it comes back',
                'जमा राशि कितनी, और कब वापस होगी',
                noteEn: 'Put a number of days in: "within 30 days of handing '
                    'back the keys" is worth more than "at the end".',
                noteHi: 'दिन लिखवाएँ: "चाबी लौटाने के 30 दिन में" लिखा होना "अंत '
                    'में" से बेहतर है।'),
            CheckItem('period', 'The period of the tenancy, and the notice to leave',
                'किरायेदारी की अवधि, और छोड़ने का नोटिस',
                noteEn: 'The notice should be the same for both sides. One '
                    'month each way is the common term.',
                noteHi: 'नोटिस दोनों के लिए बराबर होना चाहिए। आम तौर पर एक महीना '
                    'दोनों तरफ़।'),
            CheckItem('bills', 'Who pays the electricity, water and maintenance',
                'बिजली, पानी और रख-रखाव कौन देगा',
                noteEn: 'Note the meter reading on the day you move in, and '
                    'photograph the meter.',
                noteHi: 'जिस दिन घर में आएँ, मीटर की रीडिंग लिख लें और मीटर की '
                    'फ़ोटो ले लें।'),
            CheckItem('repair', 'Who repairs what',
                'कौन सी मरम्मत किसके ज़िम्मे',
                noteEn: 'The usual line: the structure, the roof and the '
                    'pipes are the owner\'s; a bulb or a tap washer is '
                    'yours.',
                noteHi: 'आम बाँट: ढाँचा, छत और पाइप मालिक के; बल्ब या टोंटी की '
                    'वाशर आपके।'),
            CheckItem('use', 'What the house may be used for',
                'घर किस काम के लिए है',
                noteEn: 'If you plan to run any work from home, get it '
                    'written in now rather than argue later.',
                noteHi: 'घर से कोई काम करने का इरादा हो तो अभी लिखवा लें, बाद में '
                    'बहस करने से अच्छा है।'),
            CheckItem('lock', 'No clause letting the owner enter or lock up at will',
                'मालिक जब चाहे अंदर आ सके या ताला लगा सके, ऐसी शर्त न हो',
                noteEn: 'An owner may enter on reasonable notice, not '
                    'whenever they like. A clause permitting locking you out '
                    'is not enforceable, and a landlord who wants it is '
                    'telling you something.',
                noteHi: 'मालिक उचित सूचना देकर आ सकता है, जब मन करे तब नहीं। '
                    'ताला लगाने की छूट देने वाली शर्त चलती नहीं, और जो मालिक ऐसी '
                    'शर्त चाहे वह कुछ बता रहा है।'),
            CheckItem('signed', 'Both signatures, two witnesses, and a copy for you',
                'दोनों के दस्तख़त, दो गवाह, और एक नक़ल आपके पास',
                noteEn: 'An agreement you do not hold a copy of is the '
                    'landlord\'s agreement, not yours.',
                noteHi: 'जिस काग़ज़ की नक़ल आपके पास नहीं, वह आपका काग़ज़ नहीं है।'),
          ],
        ),
        const SizedBox(height: 14),
        ToolAnswer(
          headline: hi ? 'जमा राशि पर एक बात' : 'One thing about the deposit',
          detail: hi
              ? 'केंद्र का आदर्श किरायेदारी अधिनियम 2021 कहता है कि रहने के मकान '
                  'पर जमा राशि $mtaDepositMonthsHome महीने के किराये से ज़्यादा न '
                  'हो, और दुकान पर $mtaDepositMonthsShop महीने से। लेकिन यह '
                  '"आदर्श" अधिनियम है: यह उसी राज्य में लागू होता है जिसने इसे '
                  'अपनाया है। कई राज्यों ने नहीं अपनाया, वहाँ पुराना किराया नियंत्रण '
                  'क़ानून चलता है। इसलिए इसे मोल-भाव में काम की बात मानिए, और अपने '
                  'राज्य का नियम नगर पालिका या किराया अधिकारी से पूछ लीजिए।'
              : 'The central Model Tenancy Act 2021 says the deposit on a '
                  'home should not exceed $mtaDepositMonthsHome months\' '
                  'rent, and on a shop $mtaDepositMonthsShop months. But it '
                  'is a "model" Act: it applies in a state only once that '
                  'state adopts it. Many have not, and there the older rent '
                  'control law runs. So treat it as useful in a '
                  'negotiation, and ask the municipality or the rent '
                  'authority what your own state\'s rule is.',
          tone: ToolTone.plain,
          icon: Icons.account_balance_wallet_outlined,
        ),
        const SizedBox(height: 12),
        ToolDonts(
          heading: hi ? 'जो न करें' : 'What not to do',
          items: hi
              ? const [
                  'ख़ाली या अधूरे काग़ज़ पर दस्तख़त न करें, और न ही सादे स्टांप पेपर '
                      'पर',
                  'जमा राशि नक़द देकर रसीद न लेना — यही सबसे आम भूल है, और बाद में '
                      'वापसी इसी पर अटकती है',
                  'मकान में आने के दिन की फ़ोटो न लेना; दीवार, फ़र्श, खिड़कियाँ और '
                      'मीटर — सब की फ़ोटो रख लें',
                  'पुलिस सत्यापन या आधार की असली नक़ल मालिक को देना — फ़ोटोकॉपी ही '
                      'दें, और उस पर काम का कारण लिख दें',
                ]
              : const [
                  'Do not sign a blank or half-filled paper, and not a bare '
                      'stamp paper either',
                  'Do not hand over the deposit in cash without a receipt - '
                      'the commonest mistake there is, and what the refund '
                      'later gets stuck on',
                  'Do not skip photographs on the day you move in; walls, '
                      'floor, windows and the meter - keep a picture of each',
                  'Do not give the landlord the original of your Aadhaar - '
                      'give a photocopy, and write the purpose on it',
                ],
        ),
        const SourceNote(
            text: 'Ministry of Housing and Urban Affairs', url: _mtaUrl),
      ],
    );
  }
}

// --- Deposit not returned ---------------------------------------------

class DepositPage extends StatefulWidget {
  const DepositPage({super.key});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final _amount = TextEditingController();
  final _days = TextEditingController();
  final _owner = TextEditingController();
  final _address = TextEditingController();

  @override
  void dispose() {
    for (final c in [_amount, _days, _owner, _address]) {
      c.dispose();
    }
    super.dispose();
  }

  String _letter(bool hi) {
    final amount = _amount.text.trim().isEmpty ? '______' : _amount.text.trim();
    final days = _days.text.trim().isEmpty ? '____' : _days.text.trim();
    final owner = _owner.text.trim().isEmpty ? '______' : _owner.text.trim();
    final address =
        _address.text.trim().isEmpty ? '______' : _address.text.trim();
    if (hi) {
      return 'सेवा में,\n'
          'श्री/श्रीमती $owner\n'
          '(मकान मालिक, $address)\n\n'
          'विषय: जमा राशि ₹$amount की वापसी हेतु माँग\n\n'
          'महोदय/महोदया,\n\n'
          'मैंने आपके मकान $address में किरायेदार के रूप में रहते हुए जमा राशि '
          '₹$amount आपको दी थी। मकान ख़ाली करके चाबी आपको सौंपने के बाद आज तक '
          '$days दिन बीत चुके हैं और जमा राशि वापस नहीं मिली है।\n\n'
          'निवेदन है कि यह राशि इस पत्र की तारीख़ से 15 दिन के भीतर लौटा दें। '
          'यदि आपके अनुसार इसमें से कोई रक़म काटी जानी है तो उसका ब्योरा और उसका '
          'कारण लिखित में दें।\n\n'
          'निर्धारित समय में राशि न मिलने पर मैं उपभोक्ता आयोग अथवा सक्षम '
          'प्राधिकारी के समक्ष कार्यवाही करने के लिए बाध्य होऊँगा/होऊँगी, जिसका '
          'ख़र्च और ब्याज भी माँगा जाएगा।\n\n'
          'दिनांक: ____________\n'
          'नाम: ____________\n'
          'वर्तमान पता: ____________\n'
          'फ़ोन: ____________\n'
          'हस्ताक्षर: ____________';
    }
    return 'To,\n'
        'Mr/Ms $owner\n'
        '(Landlord, $address)\n\n'
        'Subject: Demand for the return of the deposit of ₹$amount\n\n'
        'Sir / Madam,\n\n'
        'As your tenant at $address I paid you a deposit of ₹$amount. '
        '$days days have passed since I vacated the house and handed the '
        'keys back to you, and the deposit has not been returned.\n\n'
        'I request that you return the amount within 15 days of the date of '
        'this letter. If in your view any sum is to be deducted from it, '
        'please give me the details and the reason in writing.\n\n'
        'If the amount is not received within that time I will be '
        'constrained to proceed before the consumer commission or the '
        'competent authority, where the costs and interest will also be '
        'claimed.\n\n'
        'Date: ____________\n'
        'Name: ____________\n'
        'Present address: ____________\n'
        'Phone: ____________\n'
        'Signature: ____________';
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final hasAmount = (double.tryParse(_amount.text.trim()) ?? 0) > 0;

    return ToolScaffold(
      goal: 11,
      title: hi ? 'जमा राशि वापस नहीं मिली' : 'Deposit not returned',
      children: [
        ToolNote(hi
            ? 'जमा राशि मकान मालिक के पास अमानत है, उसकी आय नहीं। वह उसमें से '
                'सिर्फ़ वही काट सकता है जो बकाया किराया हो, या जो नुक़सान आपने '
                'किया हो — और वह भी ब्योरा देकर। "घिसाई" के नाम पर पूरी रक़म रख '
                'लेना नहीं चलता।'
            : 'The deposit is money held in trust by the landlord, not his '
                'income. He may deduct from it only rent actually due or '
                'damage you actually caused - and that with an account of '
                'it. Keeping the whole sum for "wear and tear" does not '
                'stand.'),
        ToolQuestion(hi ? 'ब्योरा' : 'The details'),
        ToolNumber(
          controller: _amount,
          label: hi ? 'जमा राशि (₹)' : 'Deposit amount (₹)',
          maxDigits: 9,
          icon: Icons.currency_rupee,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolNumber(
          controller: _days,
          label: hi ? 'मकान छोड़ने के कितने दिन हुए' : 'Days since you moved out',
          maxDigits: 4,
          icon: Icons.schedule,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolText(
          controller: _owner,
          label: hi ? 'मकान मालिक का नाम' : 'Landlord\'s name',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolText(
          controller: _address,
          label: hi ? 'मकान का पता' : 'Address of the house',
          maxLength: 120,
          onChanged: (_) => setState(() {}),
        ),
        if (hasAmount) ...[
          ToolAnswer(
            headline: hi ? 'पहले लिखित माँग' : 'A written demand first',
            detail: hi
                ? 'ज़ुबानी माँग का कोई सबूत नहीं रहता, और आगे कहीं भी जाना हो तो '
                    'पहला सवाल यही होता है कि लिखकर माँगा था या नहीं। नीचे का पत्र '
                    'कॉपी करें, दो नक़ल बनाएँ, और उसे व्हाट्सऐप या ईमेल पर भी भेज दें '
                    'ताकि भेजने की तारीख़ दर्ज हो जाए। डाक से भेजना हो तो पंजीकृत '
                    'डाक से भेजें और रसीद रखें।'
                : 'A spoken demand leaves no proof, and wherever you go next '
                    'the first question is whether you asked in writing. Copy '
                    'the letter below, make two copies, and also send it on '
                    'WhatsApp or by email so the date of sending is '
                    'recorded. If you post it, send it by registered post '
                    'and keep the receipt.',
            tone: ToolTone.plain,
            icon: Icons.mail_outline,
          ),
          const SizedBox(height: 10),
          CopyBlock(
            text: _letter(hi),
            note: hi
                ? 'साथ में लगाएँ: किरायानामे की नक़ल, जमा राशि की रसीद या बैंक से '
                    'भेजने का ब्योरा, और आख़िरी महीने के किराये का सबूत।'
                : 'Attach: a copy of the rent agreement, the deposit receipt '
                    'or the bank record of paying it, and proof of the last '
                    'month\'s rent.',
          ),
          const SizedBox(height: 14),
          Text(hi ? 'न मिले तो आगे' : 'If it still does not come',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'जिस राज्य ने आदर्श किरायेदारी अधिनियम अपनाया है, वहाँ किराया '
                        'प्राधिकारी (रेंट अथॉरिटी) के पास सीधा आवेदन होता है, और वह '
                        'सस्ता तथा तेज़ रास्ता है। नगर पालिका से पूछें कि आपके राज्य '
                        'में यह है या नहीं।',
                    'उपभोक्ता आयोग: मकान किराये पर देना एक सेवा मानी गई है, और जमा '
                        'राशि न लौटाना सेवा में कमी। ज़िला आयोग में ख़ुद शिकायत दी जा '
                        'सकती है, वकील ज़रूरी नहीं, और छोटी रक़म पर शुल्क भी कम है। '
                        'पहले राष्ट्रीय उपभोक्ता हेल्पलाइन पर बात कर लें।',
                    'बहुत छोटी रक़म हो तो लोक अदालत में मामला रखा जा सकता है — यह '
                        'मुफ़्त है और वहाँ आपसी सहमति से फ़ैसला होता है। ज़िला विधिक '
                        'सेवा प्राधिकरण में पूछें; तारीख़ें समय-समय पर लगती हैं।',
                    'पुलिस का रास्ता आम तौर पर काम नहीं आता, क्योंकि यह दीवानी '
                        'मामला है — हाँ, धमकी या ज़बरदस्ती हुई हो तो वह अलग बात है '
                        'और उसकी शिकायत ज़रूर करें।',
                  ]
                : const [
                    'In a state that has adopted the Model Tenancy Act there '
                        'is a direct application to the Rent Authority, and '
                        'that is the cheap, fast route. Ask the municipality '
                        'whether your state has one.',
                    'The consumer commission: letting a house is treated as a '
                        'service, and withholding the deposit as a '
                        'deficiency in it. You can file at the district '
                        'commission yourself, a lawyer is not required, and '
                        'the fee for a small amount is low. Talk to the '
                        'National Consumer Helpline first.',
                    'For a very small amount the matter can be taken to a '
                        'Lok Adalat - that is free and decided by mutual '
                        'agreement. Ask at the District Legal Services '
                        'Authority; sittings are held from time to time.',
                    'The police route usually does not help, because this is '
                        'a civil matter - though if there was a threat or '
                        'force, that is a different thing and should '
                        'certainly be reported.',
                  ],
          ),
          const SourceNote(
              text: 'National Consumer Helpline', url: _consumerUrl),
          const SourceNote(
              text: 'National Legal Services Authority', url: _nalsaUrl),
        ],
      ],
    );
  }
}

// --- Eviction ---------------------------------------------------------

enum EvictionKind { verbal, lockedOut, cutOff, notice, raisedRent }

class EvictionPage extends StatefulWidget {
  const EvictionPage({super.key});

  @override
  State<EvictionPage> createState() => _EvictionPageState();
}

class _EvictionPageState extends State<EvictionPage> {
  EvictionKind? _kind;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 11,
      title: hi ? 'घर ख़ाली कराने की धमकी' : 'Eviction threat',
      children: [
        ToolAnswer(
          headline: hi
              ? 'किसी को घर से निकालने का एक ही तरीक़ा है: आदेश'
              : 'There is one way to put somebody out: an order',
          detail: hi
              ? 'मकान मालिक चाहे कितना ही सही हो, वह ख़ुद से किरायेदार को बाहर '
                  'नहीं कर सकता। ख़ाली कराने के लिए अदालत या किराया प्राधिकारी का '
                  'आदेश चाहिए। ताला बदलना, सामान बाहर रखना, या बिजली-पानी काट देना '
                  '— ये रास्ते क़ानून में नहीं हैं, चाहे किराया सच में बकाया हो।'
              : 'However right the landlord may be, he cannot put a tenant '
                  'out by himself. Vacating needs an order from a court or '
                  'the rent authority. Changing the lock, putting the '
                  'belongings outside, or cutting off power and water are '
                  'not routes the law provides, even where the rent really '
                  'is due.',
          tone: ToolTone.plain,
          icon: Icons.gavel_outlined,
        ),
        ToolQuestion(hi ? 'हो क्या रहा है' : 'What is happening'),
        SelectionTile(
          label: hi ? 'ज़ुबानी धमकी दी जा रही है' : 'Being threatened verbally',
          selected: _kind == EvictionKind.verbal,
          onTap: () => setState(() => _kind = EvictionKind.verbal),
        ),
        SelectionTile(
          label: hi ? 'ताला बदल दिया या सामान बाहर कर दिया' : 'The lock was changed or things put outside',
          selected: _kind == EvictionKind.lockedOut,
          onTap: () => setState(() => _kind = EvictionKind.lockedOut),
        ),
        SelectionTile(
          label: hi ? 'बिजली या पानी काट दिया' : 'Power or water was cut off',
          selected: _kind == EvictionKind.cutOff,
          onTap: () => setState(() => _kind = EvictionKind.cutOff),
        ),
        SelectionTile(
          label: hi ? 'ख़ाली करने का नोटिस मिला है' : 'Received a notice to vacate',
          selected: _kind == EvictionKind.notice,
          onTap: () => setState(() => _kind = EvictionKind.notice),
        ),
        SelectionTile(
          label: hi ? 'अचानक किराया बहुत बढ़ा दिया' : 'The rent was raised steeply, suddenly',
          selected: _kind == EvictionKind.raisedRent,
          onTap: () => setState(() => _kind = EvictionKind.raisedRent),
        ),
        if (_kind == EvictionKind.verbal)
          ToolAnswer(
            headline: hi ? 'लिखित में माँगें, और शांत रहें' : 'Ask for it in writing, and stay calm',
            detail: hi
                ? 'मालिक से कहिए कि जो कहना है वह लिखकर दें। लिखित नोटिस आ जाने पर '
                    'तारीख़ और कारण दोनों दर्ज हो जाते हैं, और आपको तैयारी का समय '
                    'मिल जाता है। साथ-साथ अपनी तरफ़ का काग़ज़ मज़बूत करें: किराये की '
                    'रसीदें या बैंक का ब्योरा, किरायानामा, और बिजली-पानी के बिल — '
                    'ये सब साबित करते हैं कि आप वहाँ रहते हैं और किराया देते हैं। '
                    'धमकी की तारीख़ और शब्द लिखकर रख लें।'
                : 'Tell the owner to put what he has to say in writing. Once '
                    'a written notice comes, both the date and the reason are '
                    'on record and you get time to prepare. Meanwhile '
                    'strengthen your own paper: rent receipts or bank '
                    'records, the agreement, and the electricity and water '
                    'bills - together they prove you live there and pay '
                    'rent. Write down the date and the words of the threat.',
            tone: ToolTone.plain,
            icon: Icons.edit_note_outlined,
          ),
        if (_kind == EvictionKind.lockedOut)
          ToolAnswer(
            headline: hi ? 'यह अपराध है — आज ही शिकायत' : 'This is an offence - complain today',
            detail: hi
                ? 'किरायेदार को ज़बरदस्ती बाहर करना, ताला बदलना या सामान बाहर फेंकना '
                    'दीवानी मामला भर नहीं है: इसमें आपराधिक बल और आपके सामान के '
                    'साथ छेड़छाड़ भी शामिल है। थाने में लिखित शिकायत दें और उसकी '
                    'रसीद लें; पुलिस लिखित न लें तो वही शिकायत पुलिस अधीक्षक को डाक '
                    'से भेजें और नक़ल रखें। ताला और बाहर पड़े सामान की फ़ोटो तुरंत '
                    'लें, तारीख़ के साथ, और मौजूद पड़ोसियों के नाम लिख लें। 112 पर '
                    'फ़ोन करने से मौक़े पर पुलिस आती है, और यही सबसे काम आता है।'
                : 'Forcing a tenant out, changing the lock or throwing the '
                    'belongings out is not merely a civil matter: it involves '
                    'criminal force and interference with your goods. Give a '
                    'written complaint at the police station and take a '
                    'receipt; if the police will not take it in writing, '
                    'post the same complaint to the Superintendent of Police '
                    'and keep a copy. Photograph the lock and the things put '
                    'outside at once, with the date, and write down the '
                    'names of the neighbours who were there. Calling 112 '
                    'brings the police to the spot, and that is what helps '
                    'most.',
            tone: ToolTone.bad,
            icon: Icons.local_police_outlined,
          ),
        if (_kind == EvictionKind.cutOff)
          ToolAnswer(
            headline: hi ? 'बिजली-पानी काटना भी ख़ाली कराना है' : 'Cutting off power or water is eviction too',
            detail: hi
                ? 'अदालतों ने बार-बार कहा है कि बिजली या पानी काटकर किरायेदार को '
                    'निकलने पर मजबूर करना वही काम है जो ज़बरदस्ती निकालना — और वह '
                    'नहीं चलता। दो काम साथ करें: थाने में लिखित शिकायत, और बिजली '
                    'वितरण कंपनी में शिकायत, क्योंकि कनेक्शन आपके नाम हो तो उसे '
                    'कोई तीसरा नहीं कटवा सकता। कनेक्शन मालिक के नाम हो तो भी आपूर्ति '
                    'बहाल कराने के लिए अदालत या किराया प्राधिकारी से तुरंत आदेश '
                    'माँगा जा सकता है। मुफ़्त वकील के लिए ज़िला विधिक सेवा '
                    'प्राधिकरण।'
                : 'Courts have said repeatedly that cutting off power or '
                    'water to force a tenant out is the same act as forcing '
                    'them out, and does not stand. Do two things together: a '
                    'written police complaint, and a complaint to the '
                    'electricity distribution company, because if the '
                    'connection is in your name a third person cannot have '
                    'it cut. Even where it is in the owner\'s name, an order '
                    'restoring supply can be asked for at once from the '
                    'court or the rent authority. For a free lawyer, the '
                    'District Legal Services Authority.',
            tone: ToolTone.bad,
            icon: Icons.power_off_outlined,
          ),
        if (_kind == EvictionKind.notice)
          ToolAnswer(
            headline: hi ? 'नोटिस पढ़िए, घबराइए नहीं' : 'Read the notice; do not panic',
            detail: hi
                ? 'नोटिस मिलना ख़ाली करने का आदेश नहीं है — वह उसकी शुरुआत है। तीन '
                    'बातें देखें: नोटिस में कितना समय दिया गया है, किरायानामे में '
                    'नोटिस की अवधि क्या लिखी है, और कारण क्या बताया गया है। दोनों '
                    'में से जो अवधि ज़्यादा हो, आम तौर पर वही चलती है। इस बीच किराया '
                    'देना बंद न करें — बंद करते ही आपका पक्ष कमज़ोर हो जाता है; '
                    'मालिक लेने से मना करे तो बैंक में उसके खाते में भेज दें या '
                    'मनीऑर्डर कर दें, और रसीद रखें। कारण ग़लत लगे तो किराया '
                    'प्राधिकारी या अदालत में जवाब दिया जा सकता है, और मुफ़्त वकील '
                    'ज़िला विधिक सेवा प्राधिकरण से मिलता है।'
                : 'A notice is not an order to vacate - it is the start of '
                    'one. Check three things: how much time the notice gives, '
                    'what notice period the agreement states, and what '
                    'reason is given. Whichever period is longer usually '
                    'governs. Do not stop paying rent in the meantime - the '
                    'moment you do, your side weakens; if the owner refuses '
                    'to take it, send it to his bank account or by money '
                    'order and keep the receipt. If the reason is wrong it '
                    'can be answered before the rent authority or the court, '
                    'and a free lawyer comes from the District Legal '
                    'Services Authority.',
            tone: ToolTone.warn,
            icon: Icons.description_outlined,
          ),
        if (_kind == EvictionKind.raisedRent)
          ToolAnswer(
            headline: hi ? 'बढ़ोतरी काग़ज़ के हिसाब से होनी है' : 'An increase has to follow the paper',
            detail: hi
                ? 'किरायानामे में बढ़ोतरी की शर्त लिखी हो तो वही चलेगी — उससे ज़्यादा '
                    'नहीं। शर्त न लिखी हो तो ज़्यादातर राज्यों के क़ानून में बढ़ोतरी '
                    'के लिए लिखित सूचना और एक तय समय ज़रूरी है, और एकतरफ़ा भारी '
                    'बढ़ोतरी को किराया प्राधिकारी या अदालत में चुनौती दी जा सकती है। '
                    'एक बात साफ़ रखें: अचानक बहुत बढ़ाना अक्सर ख़ाली कराने का '
                    'दूसरा तरीक़ा होता है, और इसे उसी तरह देखा जाता है। लिखित में '
                    'जवाब दें, पुराना किराया देते रहें, और रसीद रखें।'
                : 'If the agreement states how the rent may rise, that is '
                    'what governs - and no more. Where it does not, most '
                    'state laws require written notice and a fixed period '
                    'for an increase, and a steep one-sided increase can be '
                    'challenged before the rent authority or the court. Keep '
                    'one thing clear: a sudden large increase is often '
                    'eviction by another route, and is looked at that way. '
                    'Reply in writing, keep paying the old rent, and keep '
                    'the receipts.',
            tone: ToolTone.warn,
            icon: Icons.trending_up,
          ),
        if (_kind != null) ...[
          const SizedBox(height: 14),
          ToolDonts(
            heading: hi ? 'जो न करें' : 'What not to do',
            items: hi
                ? const [
                    'किराया देना बंद न करें, झगड़ा चलते हुए भी — यह सबसे बड़ी भूल है',
                    'ज़बरदस्ती या मारपीट पर न उतरें; शिकायत का काग़ज़ आपकी ताक़त है',
                    'किरायानामा, रसीदें और बिल किसी को न दें — नक़ल दें',
                    'दबाव में "ख़ाली कर दिया" जैसा कोई काग़ज़ दस्तख़त न करें',
                    'धमकी के संदेश मिटाएँ नहीं; उनकी फ़ोटो लेकर रखें',
                  ]
                : const [
                    'Do not stop paying rent, even while the dispute runs - '
                        'it is the single biggest mistake',
                    'Do not meet force with force; the paper trail is your '
                        'strength',
                    'Do not hand over the agreement, receipts or bills - '
                        'give copies',
                    'Do not sign anything under pressure saying you have '
                        'vacated',
                    'Do not delete threatening messages; photograph and keep '
                        'them',
                  ],
          ),
          const SourceNote(
              text: 'National Legal Services Authority', url: _nalsaUrl),
        ],
      ],
    );
  }
}
