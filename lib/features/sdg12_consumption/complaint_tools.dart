import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import '../../core/widgets/tool_kit.dart';

/// When a purchase goes wrong: a defective product, an order that never
/// came, a price above the MRP, a misleading advertisement.
///
/// Every route here begins with a written complaint to the seller, because
/// that letter is what the consumer commission asks for first, and ends at
/// the commission, which a person can approach without a lawyer and - for
/// most household purchases - without a fee.

const _nchUrl = 'https://consumerhelpline.gov.in/';
const _edaakhilUrl = 'https://edaakhil.nic.in/';
const _ascUrl = 'https://www.ascionline.in/';
const _rbiUrl = 'https://www.rbi.org.in/';

/// Consumer Protection Act 2019 and the 2021 jurisdiction rules: the
/// District Commission hears claims where the price paid is up to this.
const districtCommissionLimit = 5000000;

/// No fee at the commission for a price paid up to this.
const commissionNoFeeLimit = 500000;

/// Years from the cause of action within which a complaint must be filed.
const commissionLimitationYears = 2;

/// Consumer Protection (E-Commerce) Rules 2020: the platform's grievance
/// officer acknowledges within 48 hours and resolves within one month.
const ecomAcknowledgeHours = 48;
const ecomResolveDays = 30;

/// RBI turnaround-time framework for failed digital payments: a debit for a
/// purchase that did not go through is reversed within five days of the
/// transaction, failing which the bank owes a fixed compensation per day.
const failedTxnReversalDays = 5;
const failedTxnPenaltyPerDay = 100;

const _nchNumber = '1915';

String _fmtRupees(int v) {
  final s = v.toString();
  if (s.length <= 3) return s;
  final last3 = s.substring(s.length - 3);
  var rest = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '${parts.join(',')},$last3';
}

// --- Defective product ------------------------------------------------

class DefectiveProductPage extends StatefulWidget {
  const DefectiveProductPage({super.key});

  @override
  State<DefectiveProductPage> createState() => _DefectiveProductPageState();
}

class _DefectiveProductPageState extends State<DefectiveProductPage> {
  final _product = TextEditingController();
  final _seller = TextEditingController();
  final _price = TextEditingController();
  final _date = TextEditingController();
  final _problem = TextEditingController();

  @override
  void dispose() {
    for (final c in [_product, _seller, _price, _date, _problem]) {
      c.dispose();
    }
    super.dispose();
  }

  String _or(TextEditingController c) =>
      c.text.trim().isEmpty ? '______' : c.text.trim();

  String _letter(bool hi) {
    if (hi) {
      return 'सेवा में,\n'
          '${_or(_seller)}\n\n'
          'विषय: दोषपूर्ण सामान — मरम्मत, बदलाव या पैसे की वापसी हेतु\n\n'
          'महोदय/महोदया,\n\n'
          'मैंने आपसे दिनांक ${_or(_date)} को ${_or(_product)} ₹${_or(_price)} '
          'में ख़रीदा था (बिल/रसीद की नक़ल संलग्न)। इसमें यह ख़राबी है: '
          '${_or(_problem)}।\n\n'
          'उपभोक्ता संरक्षण अधिनियम 2019 के अंतर्गत यह दोषपूर्ण सामान है। '
          'निवेदन है कि इस पत्र के 15 दिन के भीतर इसे मुफ़्त ठीक करें, बदलें, '
          'या पूरी राशि लौटाएँ।\n\n'
          'तय समय में समाधान न होने पर मैं ज़िला उपभोक्ता आयोग में शिकायत दर्ज '
          'करूँगा/करूँगी, जिसमें राशि के साथ मुआवज़ा और ख़र्च भी माँगा जाएगा।\n\n'
          'दिनांक: ____________\n'
          'नाम: ____________\n'
          'पता: ____________\n'
          'फ़ोन: ____________';
    }
    return 'To,\n'
        '${_or(_seller)}\n\n'
        'Subject: Defective product - repair, replacement or refund\n\n'
        'Sir / Madam,\n\n'
        'On ${_or(_date)} I bought ${_or(_product)} from you for '
        '₹${_or(_price)} (copy of the bill attached). It has this defect: '
        '${_or(_problem)}.\n\n'
        'This is a defective product under the Consumer Protection Act '
        '2019. I request that within 15 days of this letter you repair it '
        'free, replace it, or refund the full amount.\n\n'
        'If it is not resolved in that time I will file a complaint before '
        'the District Consumer Commission, claiming the amount together '
        'with compensation and costs.\n\n'
        'Date: ____________\n'
        'Name: ____________\n'
        'Address: ____________\n'
        'Phone: ____________';
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final price = int.tryParse(_price.text.trim());

    return ToolScaffold(
      goal: 12,
      title: hi ? 'ख़राब सामान मिला' : 'Defective product',
      children: [
        ToolNote(hi
            ? 'रास्ता तीन क़दम का है: विक्रेता को लिखित शिकायत, फिर राष्ट्रीय उपभोक्ता '
                'हेल्पलाइन $_nchNumber, और तब भी न हो तो उपभोक्ता आयोग। आयोग में '
                'वकील ज़रूरी नहीं, और शिकायत अपने ज़िले में दी जा सकती है — जहाँ आप '
                'रहते या काम करते हैं, दुकान चाहे कहीं हो।'
            : 'The route has three steps: a written complaint to the seller, '
                'then the National Consumer Helpline on $_nchNumber, and if '
                'that fails, the consumer commission. No lawyer is needed at '
                'the commission, and you can file in your own district - '
                'where you live or work - wherever the shop is.'),
        ToolQuestion(hi ? 'ब्योरा भरें' : 'Fill in the details'),
        ToolText(
          controller: _product,
          label: hi ? 'क्या ख़रीदा (ब्रांड और मॉडल)' : 'What you bought (brand and model)',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        ToolText(
          controller: _seller,
          label: hi ? 'दुकान या कंपनी का नाम और पता' : 'Shop or company name and address',
          maxLength: 120,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ToolNumber(
                controller: _price,
                label: hi ? 'दाम (₹)' : 'Price (₹)',
                maxDigits: 9,
                icon: Icons.currency_rupee,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ToolText(
                controller: _date,
                label: hi ? 'ख़रीद की तारीख़' : 'Date bought',
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ToolText(
          controller: _problem,
          label: hi ? 'ख़राबी क्या है' : 'What is wrong with it',
          maxLength: 200,
          maxLines: 3,
          onChanged: (_) => setState(() {}),
        ),
        if (price != null && price > 0) ...[
          ToolAnswer(
            headline: price <= commissionNoFeeLimit
                ? (hi
                    ? 'ज़िला आयोग, और कोई शुल्क नहीं'
                    : 'District Commission, and no fee')
                : price <= districtCommissionLimit
                    ? (hi ? 'ज़िला उपभोक्ता आयोग' : 'The District Consumer Commission')
                    : (hi ? 'राज्य उपभोक्ता आयोग' : 'The State Consumer Commission'),
            detail: hi
                ? 'आयोग कौन सा होगा, यह चुकाए गए दाम से तय होता है। ज़िला आयोग '
                    '₹${_fmtRupees(districtCommissionLimit)} तक के मामले सुनता है, '
                    'और ₹${_fmtRupees(commissionNoFeeLimit)} तक कोई शुल्क नहीं '
                    'लगता। शिकायत ख़राबी पता चलने के $commissionLimitationYears '
                    'साल के भीतर देनी होती है, और ऑनलाइन ई-दाख़िल पोर्टल पर भी दी '
                    'जा सकती है।'
                : 'Which commission depends on the price you paid. The '
                    'District Commission hears matters up to '
                    '₹${_fmtRupees(districtCommissionLimit)}, and up to '
                    '₹${_fmtRupees(commissionNoFeeLimit)} there is no fee. '
                    'The complaint must be filed within '
                    '$commissionLimitationYears years of the defect coming '
                    'to light, and can be filed online on the e-Daakhil '
                    'portal.',
            tone: ToolTone.plain,
            icon: Icons.gavel_outlined,
          ),
          const SizedBox(height: 10),
          CopyBlock(
            text: _letter(hi),
            note: hi
                ? 'ईमेल या व्हाट्सऐप पर भी भेजें ताकि तारीख़ दर्ज रहे। बिल, वारंटी '
                    'कार्ड और ख़राबी की फ़ोटो या वीडियो संभाल कर रखें।'
                : 'Also send it by email or WhatsApp so the date is on '
                    'record. Keep the bill, the warranty card and a photo or '
                    'video of the defect.',
          ),
        ],
        const SizedBox(height: 14),
        ToolDonts(
          heading: hi ? 'ध्यान रखें' : 'Keep in mind',
          items: hi
              ? const [
                  'सामान ख़ुद या बाहर के मिस्त्री से न खुलवाएँ — वारंटी जा सकती है '
                      'और कंपनी इसी को बहाना बनाती है',
                  'सर्विस सेंटर पर सामान दें तो जॉब-शीट ज़रूर लें, जिसमें ख़राबी '
                      'लिखी हो',
                  '"बिल के बिना कुछ नहीं होगा" सही नहीं — बैंक या यूपीआई का भुगतान '
                      'भी ख़रीद का सबूत है',
                  'ऑनलाइन "उपभोक्ता शिकायत" के नाम पर फ़ीस माँगने वाली साइटों से '
                      'बचें; हेल्पलाइन और ई-दाख़िल दोनों सरकारी और मुफ़्त हैं',
                ]
              : const [
                  'Do not open it yourself or have an outside mechanic open '
                      'it - the warranty can go, and the company uses that as '
                      'its excuse',
                  'When you leave it at a service centre, take a job sheet '
                      'with the fault written on it',
                  '"Nothing can be done without the bill" is not true - a '
                      'bank or UPI payment also proves the purchase',
                  'Avoid sites charging a fee to file a "consumer '
                      'complaint"; the helpline and e-Daakhil are both '
                      'government and free',
                ],
        ),
        const SourceNote(text: 'National Consumer Helpline', url: _nchUrl),
        const SourceNote(text: 'e-Daakhil - file online', url: _edaakhilUrl),
      ],
    );
  }
}

// --- Order not delivered ----------------------------------------------

enum OrderTrouble { notDelivered, refundStuck, wrongItem, paidNoOrder }

class OrderNotDeliveredPage extends StatefulWidget {
  const OrderNotDeliveredPage({super.key});

  @override
  State<OrderNotDeliveredPage> createState() => _OrderNotDeliveredPageState();
}

class _OrderNotDeliveredPageState extends State<OrderNotDeliveredPage> {
  OrderTrouble? _trouble;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 12,
      title: hi ? 'ऑर्डर नहीं आया या पैसे अटके' : 'Order not delivered or refund stuck',
      children: [
        ToolQuestion(hi ? 'हुआ क्या' : 'What happened'),
        SelectionTile(
          label: hi ? 'सामान आया ही नहीं' : 'The order never arrived',
          selected: _trouble == OrderTrouble.notDelivered,
          onTap: () => setState(() => _trouble = OrderTrouble.notDelivered),
        ),
        SelectionTile(
          label: hi ? 'लौटाया, पैसा नहीं आया' : 'Returned it, no refund',
          selected: _trouble == OrderTrouble.refundStuck,
          onTap: () => setState(() => _trouble = OrderTrouble.refundStuck),
        ),
        SelectionTile(
          label: hi ? 'ग़लत या नक़ली सामान आया' : 'Wrong or fake item arrived',
          selected: _trouble == OrderTrouble.wrongItem,
          onTap: () => setState(() => _trouble = OrderTrouble.wrongItem),
        ),
        SelectionTile(
          label: hi ? 'पैसा कटा, ऑर्डर बना ही नहीं' : 'Money debited, no order placed',
          selected: _trouble == OrderTrouble.paidNoOrder,
          onTap: () => setState(() => _trouble = OrderTrouble.paidNoOrder),
        ),
        if (_trouble == OrderTrouble.paidNoOrder)
          ToolAnswer(
            headline: hi
                ? 'बैंक को $failedTxnReversalDays दिन में पैसा लौटाना है'
                : 'The bank must reverse it within $failedTxnReversalDays days',
            detail: hi
                ? 'रिज़र्व बैंक के नियम में असफल लेन-देन — जहाँ खाते से पैसा कटा पर '
                    'दुकान तक नहीं पहुँचा — का पैसा लेन-देन के $failedTxnReversalDays '
                    'दिन के भीतर अपने आप वापस आना चाहिए। उसके बाद देर के हर दिन का '
                    '₹$failedTxnPenaltyPerDay मुआवज़ा बैंक को देना होता है, बिना माँगे। '
                    'न आए तो अपने बैंक में लेन-देन संख्या (यूटीआर) के साथ शिकायत दें; '
                    '30 दिन में हल न हो तो रिज़र्व बैंक के लोकपाल पोर्टल पर।'
                : 'Under the Reserve Bank\'s rules, a failed transaction - '
                    'money debited but never reaching the merchant - must be '
                    'reversed automatically within $failedTxnReversalDays '
                    'days. After that the bank owes ₹$failedTxnPenaltyPerDay '
                    'for every day of delay, without being asked. If it does '
                    'not come, complain to your bank with the transaction '
                    'reference (UTR); if it is not resolved in 30 days, go '
                    'to the RBI Ombudsman portal.',
            tone: ToolTone.good,
            icon: Icons.account_balance_outlined,
          )
        else if (_trouble != null) ...[
          ToolAnswer(
            headline: hi
                ? 'कंपनी को $ecomAcknowledgeHours घंटे में जवाब देना है'
                : 'The platform must respond within $ecomAcknowledgeHours hours',
            detail: hi
                ? 'ई-कॉमर्स नियम 2020 के अनुसार हर ऑनलाइन बाज़ार को एक शिकायत '
                    'अधिकारी रखना होता है, जिसका नाम और संपर्क ऐप या वेबसाइट पर '
                    'छपा हो। वह शिकायत की पावती $ecomAcknowledgeHours घंटे में और '
                    'समाधान एक महीने में देगा। ऐप की चैट में बात करने से यह क्रम शुरू '
                    'नहीं होता — शिकायत अधिकारी को ईमेल भेजिए।'
                : 'Under the E-Commerce Rules 2020 every online marketplace '
                    'must have a grievance officer whose name and contact are '
                    'shown in the app or on the site. That officer '
                    'acknowledges a complaint within $ecomAcknowledgeHours '
                    'hours and resolves it within a month. A chat in the app '
                    'does not start this clock - email the grievance officer.',
            tone: ToolTone.plain,
            icon: Icons.schedule,
          ),
          const SizedBox(height: 12),
          Text(hi ? 'क्रम से' : 'In order',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? [
                    'ऑर्डर संख्या, भुगतान का स्क्रीनशॉट और ऐप में दिख रही स्थिति की '
                        'फ़ोटो ले लें — ऐप बाद में यह बदल सकता है।',
                    if (_trouble == OrderTrouble.wrongItem)
                      'पैकेट खोलते समय वीडियो बनाइए और लेबल तथा सामान दोनों साफ़ '
                          'दिखाइए। "ग़लत सामान" के झगड़े में यही वीडियो जीतता है।',
                    'ऐप या वेबसाइट पर "शिकायत अधिकारी" (ग्रीवेंस ऑफ़िसर) का ईमेल '
                        'ढूँढ़ें, और उसे सारे ब्योरे के साथ ईमेल करें।',
                    '$ecomAcknowledgeHours घंटे में पावती न आए, या एक महीने में हल '
                        'न हो, तो राष्ट्रीय उपभोक्ता हेल्पलाइन $_nchNumber पर, या '
                        'उसकी वेबसाइट या व्हाट्सऐप पर शिकायत दर्ज करें। वह कंपनी से '
                        'सीधे बात करती है, और बहुत मामले वहीं सुलझ जाते हैं।',
                    'कार्ड से भुगतान किया हो तो बैंक में "चार्जबैक" का विवाद भी '
                        'उठाया जा सकता है — इसकी समय सीमा बैंक की होती है, जल्दी करें।',
                    'तब भी न हो तो उपभोक्ता आयोग, ई-दाख़िल पोर्टल पर ऑनलाइन।',
                  ]
                : [
                    'Screenshot the order number, the payment and the status '
                        'showing in the app - the app may change it later.',
                    if (_trouble == OrderTrouble.wrongItem)
                      'Film the parcel as you open it, with the label and the '
                          'item both clearly in view. In a "wrong item" '
                          'dispute, that video wins.',
                    'Find the "grievance officer" email in the app or on the '
                        'site, and email them with all the details.',
                    'If no acknowledgement comes in $ecomAcknowledgeHours '
                        'hours, or no resolution in a month, register it '
                        'with the National Consumer Helpline on '
                        '$_nchNumber, on its site or on WhatsApp. It takes '
                        'the matter up with the company directly, and many '
                        'cases end there.',
                    'If you paid by card, a "chargeback" dispute can also be '
                        'raised with your bank - its time limit is the '
                        'bank\'s, so act early.',
                    'If that fails too, the consumer commission, online '
                        'through e-Daakhil.',
                  ],
          ),
          ToolDonts(
            heading: hi ? 'सबसे बड़ा ख़तरा' : 'The biggest danger',
            items: hi
                ? const [
                    'इंटरनेट पर खोजकर मिला "कस्टमर केयर नंबर" — ज़्यादातर नक़ली होते '
                        'हैं। नंबर सिर्फ़ कंपनी के ऐप के अंदर से लें',
                    '"रिफ़ंड के लिए" कोई ऐप डालने, लिंक खोलने, या यूपीआई पिन डालने '
                        'को कहे तो वह ठग है — रिफ़ंड लेने में पिन कभी नहीं लगता',
                    'ओटीपी किसी को न बताएँ',
                  ]
                : const [
                    'A "customer care number" found by searching online - most '
                        'are fake. Take the number only from inside the '
                        'company\'s own app',
                    'Anyone asking you to install an app, open a link or '
                        'enter your UPI PIN "for the refund" is a fraud - '
                        'receiving a refund never needs a PIN',
                    'Give the OTP to nobody',
                  ],
          ),
        ],
        if (_trouble != null) ...[
          const SourceNote(text: 'National Consumer Helpline', url: _nchUrl),
          if (_trouble == OrderTrouble.paidNoOrder)
            const SourceNote(text: 'Reserve Bank of India', url: _rbiUrl),
        ],
      ],
    );
  }
}

// --- Charged above MRP ------------------------------------------------

enum MrpPlace { shop, restaurant, cinemaOrAirport, serviceCharge }

class AboveMrpPage extends StatefulWidget {
  const AboveMrpPage({super.key});

  @override
  State<AboveMrpPage> createState() => _AboveMrpPageState();
}

class _AboveMrpPageState extends State<AboveMrpPage> {
  MrpPlace? _place;
  final _mrp = TextEditingController();
  final _paid = TextEditingController();

  @override
  void dispose() {
    _mrp.dispose();
    _paid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final mrp = double.tryParse(_mrp.text.trim()) ?? 0;
    final paid = double.tryParse(_paid.text.trim()) ?? 0;
    final over = paid - mrp;
    // Kept as locals: a quoted string inside an interpolation reads badly.
    final venue = _place == MrpPlace.cinemaOrAirport;
    final venueHi =
        venue ? ' सिनेमा, हवाई अड्डे और मॉल के काउंटर पर भी यही नियम लागू है।' : '';
    final venueEn = venue
        ? ' The same rule applies at cinema, airport and mall counters.'
        : '';

    return ToolScaffold(
      goal: 12,
      title: hi ? 'एमआरपी से ज़्यादा लिया' : 'Charged above MRP',
      children: [
        ToolQuestion(hi ? 'कहाँ' : 'Where'),
        SelectionTile(
          label: hi ? 'दुकान, ठेला या स्टेशन का स्टॉल' : 'A shop, cart or station stall',
          selected: _place == MrpPlace.shop,
          onTap: () => setState(() => _place = MrpPlace.shop),
        ),
        SelectionTile(
          label: hi ? 'होटल या रेस्तराँ में बैठकर' : 'Seated in a hotel or restaurant',
          selected: _place == MrpPlace.restaurant,
          onTap: () => setState(() => _place = MrpPlace.restaurant),
        ),
        SelectionTile(
          label: hi ? 'सिनेमा, हवाई अड्डा या मॉल का काउंटर' : 'A cinema, airport or mall counter',
          selected: _place == MrpPlace.cinemaOrAirport,
          onTap: () => setState(() => _place = MrpPlace.cinemaOrAirport),
        ),
        SelectionTile(
          label: hi ? 'बिल में "सर्विस चार्ज" जुड़ा' : '"Service charge" added to the bill',
          selected: _place == MrpPlace.serviceCharge,
          onTap: () => setState(() => _place = MrpPlace.serviceCharge),
        ),
        if (_place == MrpPlace.shop || _place == MrpPlace.cinemaOrAirport) ...[
          ToolAnswer(
            headline: hi ? 'एमआरपी से ऊपर बेचना अपराध है' : 'Selling above MRP is an offence',
            detail: hi
                ? 'पैक की गई चीज़ पर छपा अधिकतम खुदरा मूल्य सबसे ऊँचा दाम है — '
                    'उससे ऊपर कोई दुकान नहीं बेच सकती। "ठंडा करने का चार्ज", '
                    '"स्टेशन का रेट" या "यहाँ का दाम" कोई अपवाद नहीं है। यह विधिक '
                    'माप विज्ञान (लीगल मेट्रोलॉजी) क़ानून में अपराध है।$venueHi'
                : 'The maximum retail price printed on a packaged item is the '
                    'highest price there is - no shop may sell above it. A '
                    '"cooling charge", "the station rate" or "the price here" '
                    'is no exception. It is an offence under the Legal '
                    'Metrology law.$venueEn',
            tone: ToolTone.bad,
            icon: Icons.sell_outlined,
          ),
          ToolQuestion(hi ? 'कितना फ़र्क़' : 'How much over'),
          Row(
            children: [
              Expanded(
                child: ToolNumber(
                  controller: _mrp,
                  label: hi ? 'छपा एमआरपी (₹)' : 'Printed MRP (₹)',
                  decimal: true,
                  maxDigits: 7,
                  icon: Icons.local_offer_outlined,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ToolNumber(
                  controller: _paid,
                  label: hi ? 'कितना लिया (₹)' : 'Charged (₹)',
                  decimal: true,
                  maxDigits: 7,
                  icon: Icons.payments_outlined,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          if (mrp > 0 && over > 0)
            ToolLine(hi ? 'ज़्यादा लिया' : 'Overcharged',
                '₹${over.toStringAsFixed(over == over.roundToDouble() ? 0 : 2)}',
                strong: true),
          const SizedBox(height: 12),
          Text(hi ? 'शिकायत जो पैसा वापस दिलाती है' : 'The complaint that gets money back',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ToolSteps(
            steps: hi
                ? const [
                    'बिल माँगें। बिल न दें तो पैकेट पर छपे एमआरपी की फ़ोटो और भुगतान '
                        'का स्क्रीनशॉट लें — यूपीआई से भुगतान अपने आप सबूत है।',
                    'दुकान का नाम, पता और तारीख़ लिख लें।',
                    'राष्ट्रीय उपभोक्ता हेल्पलाइन 1915 पर, या उसकी वेबसाइट या '
                        'व्हाट्सऐप पर शिकायत दें, फ़ोटो के साथ।',
                    'साथ ही राज्य के विधिक माप विज्ञान विभाग (लीगल मेट्रोलॉजी '
                        'कंट्रोलर) में — यही विभाग दुकान पर जुर्माना लगाता है। ज़िले '
                        'का कार्यालय या राज्य की वेबसाइट।',
                  ]
                : const [
                    'Ask for a bill. If none is given, photograph the MRP '
                        'printed on the pack and screenshot the payment - a '
                        'UPI payment is proof on its own.',
                    'Note the shop\'s name, address and the date.',
                    'Complain to the National Consumer Helpline on 1915, or '
                        'on its site or WhatsApp, with the photos.',
                    'Also to the state Legal Metrology department (the '
                        'Controller of Legal Metrology) - this is the '
                        'department that fines the shop. The district '
                        'office or the state website.',
                  ],
          ),
        ],
        if (_place == MrpPlace.restaurant)
          ToolAnswer(
            headline: hi ? 'यहाँ नियम अलग है' : 'Here the rule is different',
            detail: hi
                ? 'सर्वोच्च न्यायालय ने 2017 में कहा कि होटल या रेस्तराँ में बैठकर '
                    'खाते समय परोसी गई पानी की बोतल या ठंडा पेय एमआरपी से ऊपर के दाम '
                    'पर दिया जा सकता है, क्योंकि वहाँ सिर्फ़ सामान नहीं, बैठने और '
                    'परोसने की सेवा भी शामिल है। लेकिन वही रेस्तराँ अगर काउंटर पर '
                    'बंद बोतल ले जाने के लिए बेचे, तो एमआरपी का नियम लागू होता है। '
                    'दाम मेन्यू में पहले से लिखा होना चाहिए।'
                : 'The Supreme Court held in 2017 that a bottle of water or a '
                    'soft drink served to you seated in a hotel or restaurant '
                    'may be priced above the MRP, because the price covers the '
                    'seating and service as well as the item. But if the same '
                    'restaurant sells a sealed bottle over the counter to take '
                    'away, the MRP rule applies. The price should be on the '
                    'menu beforehand.',
            tone: ToolTone.plain,
            icon: Icons.restaurant_outlined,
          ),
        if (_place == MrpPlace.serviceCharge)
          ToolAnswer(
            headline: hi ? 'सर्विस चार्ज देना आपकी मर्ज़ी है' : 'A service charge is your choice',
            detail: hi
                ? 'केंद्रीय उपभोक्ता संरक्षण प्राधिकरण के 2022 के दिशानिर्देश कहते हैं '
                    'कि रेस्तराँ बिल में अपने आप सर्विस चार्ज नहीं जोड़ सकता, न उसे '
                    'किसी और नाम से वसूल सकता है, और न ही उसे न देने पर सेवा मना कर '
                    'सकता है। दिल्ली उच्च न्यायालय ने 2025 में इन दिशानिर्देशों को सही '
                    'ठहराया। बिल से हटवाने को कहें; न हटाएँ तो 1915 पर शिकायत करें। '
                    'टिप देना हो तो अलग से, अपनी मर्ज़ी से।'
                : 'The Central Consumer Protection Authority\'s 2022 guidelines '
                    'say a restaurant may not add a service charge to the bill '
                    'automatically, may not collect it under another name, and '
                    'may not refuse service if you decline it. The Delhi High '
                    'Court upheld these guidelines in 2025. Ask for it to be '
                    'removed from the bill; if they refuse, complain on 1915. '
                    'If you want to tip, do it separately and by choice.',
            tone: ToolTone.good,
            icon: Icons.receipt_long_outlined,
          ),
        if (_place != null)
          const SourceNote(text: 'National Consumer Helpline', url: _nchUrl),
      ],
    );
  }
}

// --- Misleading advertisement -----------------------------------------

class MisleadingAdPage extends StatelessWidget {
  const MisleadingAdPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 12,
      title: hi ? 'भ्रामक विज्ञापन' : 'Misleading advertisement',
      children: [
        ToolNote(hi
            ? 'भ्रामक विज्ञापन उपभोक्ता संरक्षण अधिनियम में अपराध है, और ज़िम्मेदारी '
                'सिर्फ़ कंपनी की नहीं — विज्ञापन करने वाले मशहूर चेहरे पर भी जुर्माना '
                'लग सकता है, अगर उसने दावे की जाँच नहीं की।'
            : 'A misleading advertisement is an offence under the Consumer '
                'Protection Act, and the liability is not only the '
                'company\'s - a celebrity who endorses it can be fined too, '
                'if they did not check the claim.'),
        const SizedBox(height: 12),
        Text(hi ? 'इनमें से कुछ दिखे तो वह भ्रामक है' : 'If you see any of these, it is misleading',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'किसी बीमारी को "जड़ से ख़त्म" या "पक्का इलाज" करने का दावा — '
                      'मधुमेह, कैंसर, मोटापा, बाँझपन जैसी बीमारियों के इलाज का '
                      'विज्ञापन एक अलग पुराने क़ानून में भी मना है',
                  '"100% गारंटी", "डॉक्टरों की पहली पसंद" या "सबसे अच्छा" — बिना '
                      'किसी जाँच या सबूत के',
                  'बड़े अक्षरों में "मुफ़्त" और बहुत छोटे अक्षरों में शर्तें जो उसे '
                      'मुफ़्त न रहने दें',
                  'नक़ली "पहले-बाद" की तस्वीरें, या बनावटी ग्राहक-समीक्षाएँ',
                  '"सिर्फ़ आज", "बस 2 बचे" जैसा झूठा दबाव',
                  'ऋण या निवेश पर "पक्का" ऊँचा रिटर्न',
                ]
              : const [
                  'A claim to "cure" or "end from the root" a disease - '
                      'advertising a cure for conditions such as diabetes, '
                      'cancer, obesity or infertility is also barred by a '
                      'separate older law',
                  '"100% guaranteed", "doctors\' first choice" or "the best" - '
                      'with no test or evidence behind it',
                  '"Free" in large letters, with small-print conditions that '
                      'make it anything but',
                  'Fake before-and-after pictures, or invented customer '
                      'reviews',
                  'False pressure: "today only", "only 2 left"',
                  'A "guaranteed" high return on a loan or an investment',
                ],
        ),
        const SizedBox(height: 14),
        Text(hi ? 'कहाँ बताएँ' : 'Where to report it',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'विज्ञापन का स्क्रीनशॉट या फ़ोटो लें — कहाँ दिखा, किस तारीख़ को, '
                      'और चैनल या वेबसाइट का नाम।',
                  'राष्ट्रीय उपभोक्ता हेल्पलाइन 1915 पर, या उसकी वेबसाइट पर शिकायत। '
                      'वहाँ से मामला केंद्रीय उपभोक्ता संरक्षण प्राधिकरण तक जाता है, '
                      'जो जुर्माना लगा सकता है और विज्ञापन हटवा सकता है।',
                  'भारतीय विज्ञापन मानक परिषद (एएससीआई) में भी शिकायत दी जा सकती '
                      'है — उसकी वेबसाइट पर, मुफ़्त। यह विज्ञापन उद्योग की अपनी संस्था '
                      'है और विज्ञापन बदलवाने में तेज़ है।',
                  'दवा या इलाज का विज्ञापन हो तो राज्य के औषधि नियंत्रक को भी '
                      'बताएँ।',
                  'पैसा जा चुका हो तो वह अलग शिकायत है — इसी लक्ष्य में "ख़राब '
                      'सामान मिला" वाली स्क्रीन देखें।',
                ]
              : const [
                  'Screenshot or photograph the advertisement - where it '
                      'appeared, the date, and the channel or site.',
                  'Complain to the National Consumer Helpline on 1915 or on '
                      'its site. From there it goes to the Central Consumer '
                      'Protection Authority, which can fine and order the '
                      'advertisement withdrawn.',
                  'A complaint can also go to the Advertising Standards '
                      'Council of India (ASCI) on its site, free. It is the '
                      'industry\'s own body and quick at getting an '
                      'advertisement changed.',
                  'For an advertisement about a medicine or a cure, also '
                      'tell the state drug controller.',
                  'If money has already been lost, that is a separate '
                      'complaint - see "Defective product" in this goal.',
                ],
        ),
        const SourceNote(text: 'National Consumer Helpline', url: _nchUrl),
        const SourceNote(
            text: 'Advertising Standards Council of India', url: _ascUrl),
      ],
    );
  }
}
