/// "Is my electricity bill right?"
///
/// Scope, decided deliberately and stated to the user on screen
/// ------------------------------------------------------------
/// This checks **arithmetic**, not tariff. It can prove that the units
/// billed do not match the meter readings printed on the same bill, because
/// that is subtraction. It cannot tell anyone they were overcharged, because
/// that needs the state tariff order — slab rates, fixed charges, duty,
/// fuel surcharge — which differ by state and category and change every
/// year. Shipping a stale tariff table would produce confident wrong
/// answers, and "your bill is correct" is the most harmful of those.
///
/// So the findings below are of two kinds, and the UI keeps them apart:
///
///   * decisive  - objective, checkable on the bill itself. Subtraction
///                 that does not come out, or a reading that went
///                 backwards. These are worth a complaint.
///   * worth asking - a figure that looks unusual but has innocent
///                 explanations. These are phrased as a question to put to
///                 the office, never as an accusation.
///
/// Why no tariff table, concretely: a household on 40 units with a ₹120
/// fixed charge pays an effective ₹8/unit and nothing is wrong. The same
/// effective rate on 400 units would be odd. Any check that ignores fixed
/// charges flags the first household as cheated, which sends someone to
/// argue a case they will lose.
library;

enum BillIssue {
  unitsDoNotMatchReadings,
  readingWentBackwards,
  notActuallyRead,
  rateLooksHigh,
  jumpVsUsual,
}

class BillFinding {
  final BillIssue issue;

  /// True when the finding is objective arithmetic rather than a suspicion.
  final bool decisive;

  final String title;
  final String titleHi;
  final String detail;
  final String detailHi;

  const BillFinding({
    required this.issue,
    required this.decisive,
    required this.title,
    required this.titleHi,
    required this.detail,
    required this.detailHi,
  });
}

class BillReport {
  /// current - previous, as printed on the bill.
  final int unitsFromReadings;

  /// What the bill says it charged for.
  final int unitsBilled;

  /// amount / unitsBilled. Includes fixed charges and duty, so it is NOT
  /// the tariff rate and the UI must not call it one.
  final double? effectiveRatePerUnit;

  final List<BillFinding> findings;

  const BillReport({
    required this.unitsFromReadings,
    required this.unitsBilled,
    required this.effectiveRatePerUnit,
    required this.findings,
  });

  List<BillFinding> get decisive =>
      findings.where((f) => f.decisive).toList(growable: false);

  List<BillFinding> get questions =>
      findings.where((f) => !f.decisive).toList(growable: false);

  bool get arithmeticConsistent =>
      decisive.isEmpty && unitsFromReadings == unitsBilled;
}

/// Above this, an effective per-unit figure is hard to explain by fixed
/// charges alone. Set high on purpose: a false alarm sends someone to argue
/// a correct bill, which wastes their day and their credibility at the
/// office they may need later.
const double _implausibleRate = 25.0;

/// Below this many units, fixed charges dominate and the effective rate is
/// meaningless. No rate check runs here.
const int _minUnitsForRateCheck = 50;

/// A jump this many times the household's own usual consumption is worth a
/// question. Three times, not two: a summer month with a cooler running
/// genuinely doubles a bill.
const double _jumpFactor = 3.0;

BillReport checkBill({
  required int previousReading,
  required int currentReading,
  required int unitsBilled,
  required double amount,
  required bool markedEstimated,
  int? usualUnits,
}) {
  final fromReadings = currentReading - previousReading;
  final findings = <BillFinding>[];

  if (currentReading < previousReading) {
    findings.add(const BillFinding(
      issue: BillIssue.readingWentBackwards,
      decisive: true,
      title: 'This month’s reading is lower than last month’s',
      titleHi: 'इस महीने की रीडिंग पिछले महीने से कम है',
      detail: 'A meter counts upward and never backwards. Either the meter '
          'was replaced and the old reading carried over by mistake, or one '
          'of the two numbers is wrong. Ask them which, and ask for the '
          'meter replacement record if there was one.',
      detailHi: 'मीटर आगे बढ़ता है, पीछे नहीं जाता। या तो मीटर बदला गया और '
          'पुरानी रीडिंग ग़लती से चढ़ा दी गई, या दोनों में से एक संख्या '
          'ग़लत है। पूछें कि कौन सी, और मीटर बदला गया हो तो उसका रिकॉर्ड '
          'माँगें।',
    ));
  } else if (fromReadings != unitsBilled) {
    findings.add(BillFinding(
      issue: BillIssue.unitsDoNotMatchReadings,
      decisive: true,
      title: 'The units billed do not match the readings',
      titleHi: 'बिल में लिखी यूनिट रीडिंग से मेल नहीं खाती',
      detail: 'The bill shows $currentReading minus $previousReading, which '
          'is $fromReadings units. It has charged you for $unitsBilled. '
          'Both numbers are printed on the same bill, so this is something '
          'the office has to explain or correct.',
      detailHi: 'बिल पर $currentReading में से $previousReading घटाने पर '
          '$fromReadings यूनिट बनती हैं। चार्ज $unitsBilled यूनिट का किया '
          'गया है। दोनों संख्याएँ उसी बिल पर छपी हैं, इसलिए दफ़्तर को इसका '
          'जवाब देना या इसे सुधारना होगा।',
    ));
  }

  if (markedEstimated) {
    findings.add(const BillFinding(
      issue: BillIssue.notActuallyRead,
      decisive: true,
      title: 'Nobody read your meter this time',
      titleHi: 'इस बार आपका मीटर किसी ने पढ़ा नहीं',
      detail: 'An "estimated", "average" or "provisional" bill means the '
          'reading was guessed from past months, not taken from your meter. '
          'The national rules say no connection may be given without a '
          'meter, and metering and correct billing are consumer rights. Ask '
          'for an actual reading and a revised bill, and note the date you '
          'asked.',
      detailHi: '"अनुमानित", "औसत" या "प्रोविज़नल" बिल का मतलब है कि रीडिंग '
          'आपके मीटर से नहीं ली गई, पिछले महीनों से अंदाज़ा लगाया गया। '
          'राष्ट्रीय नियम कहते हैं कि मीटर के बिना कनेक्शन नहीं दिया जा '
          'सकता, और मीटर व सही बिलिंग उपभोक्ता का अधिकार है। असली रीडिंग और '
          'संशोधित बिल माँगें, और माँगने की तारीख़ लिख लें।',
    ));
  }

  final double? rate =
      unitsBilled > 0 ? amount / unitsBilled : null;

  if (rate != null &&
      unitsBilled >= _minUnitsForRateCheck &&
      rate > _implausibleRate) {
    findings.add(BillFinding(
      issue: BillIssue.rateLooksHigh,
      decisive: false,
      title: 'Worth asking: the amount per unit looks high',
      titleHi: 'पूछने लायक़: प्रति यूनिट रक़म ज़्यादा लग रही है',
      detail: 'Dividing the amount by the units gives about '
          '₹${rate.toStringAsFixed(1)} per unit. That figure includes '
          'fixed charges, duty and any arrears, so it is not the tariff '
          'rate and a high value is not proof of anything. But it is high '
          'enough to ask for the breakup and check it against the tariff '
          'card for your category.',
      detailHi: 'रक़म को यूनिट से भाग देने पर लगभग '
          '₹${rate.toStringAsFixed(1)} प्रति यूनिट आता है। इसमें '
          'फ़िक्स्ड चार्ज, ड्यूटी और बकाया शामिल है, इसलिए यह टैरिफ़ दर '
          'नहीं है और ज़्यादा होना किसी बात का सबूत नहीं। लेकिन यह इतना '
          'ज़्यादा है कि ब्रेकअप माँगकर अपनी श्रेणी के टैरिफ़ कार्ड से '
          'मिलाना चाहिए।',
    ));
  }

  if (usualUnits != null &&
      usualUnits > 0 &&
      unitsBilled > usualUnits * _jumpFactor) {
    findings.add(BillFinding(
      issue: BillIssue.jumpVsUsual,
      decisive: false,
      title: 'Worth asking: much higher than your usual months',
      titleHi: 'पूछने लायक़: आपके आम महीनों से बहुत ज़्यादा',
      detail: 'You said you usually use about $usualUnits units and this '
          'bill is for $unitsBilled. A cooler, a pump or a long billing '
          'period explains a lot of jumps, so check those first. If none '
          'applies, ask for the meter to be tested — you have a right to '
          'that, and the reading history should be shown to you.',
      detailHi: 'आपने बताया कि आम तौर पर लगभग $usualUnits यूनिट लगती हैं और '
          'यह बिल $unitsBilled यूनिट का है। कूलर, पंप या लंबी बिलिंग अवधि '
          'से कई बार ऐसा होता है, पहले वे देख लें। कुछ भी लागू न हो तो '
          'मीटर की जाँच कराने को कहें — यह आपका अधिकार है, और रीडिंग का '
          'इतिहास आपको दिखाया जाना चाहिए।',
    ));
  }

  return BillReport(
    unitsFromReadings: fromReadings,
    unitsBilled: unitsBilled,
    effectiveRatePerUnit: rate,
    findings: findings,
  );
}
