/// "Can this food be shared?"
///
/// The decision logic lives here, in code with its reasoning written down,
/// rather than in a JSON file - because getting it wrong makes someone ill,
/// and the thresholds need to be readable and arguable.
///
/// Every rule below is deliberately conservative. When the answer is close,
/// it says no. Wasted food is a loss; food poisoning in someone who was
/// already going hungry is a harm.
library;

enum FoodKind {
  cookedHighRisk, // rice, meat, fish, egg, paneer, milk sweets, cut fruit
  cookedLowRisk, // roti, dry sabzi, puri, baked items
  packagedSealed, // unopened packets, biscuits, grains, pulses
  rawProduce, // uncooked vegetables and fruit
}

enum HeldAt {
  roomTemp,
  hotHeld, // kept steaming hot, above 60C
  refrigerated, // below 5C
}

enum ShareVerdict { yes, soon, no }

class ShareAnswer {
  final ShareVerdict verdict;
  final String headline;
  final String headlineHi;
  final String reason;
  final String reasonHi;
  final String action;
  final String actionHi;

  const ShareAnswer({
    required this.verdict,
    required this.headline,
    required this.headlineHi,
    required this.reason,
    required this.reasonHi,
    required this.action,
    required this.actionHi,
  });
}

/// [hoursOld] is hours since cooking, or since the packet was opened.
/// [hotWeather] means ambient above roughly 32C, which halves the safe
/// window for food standing at room temperature.
ShareAnswer assessFood({
  required FoodKind kind,
  required HeldAt heldAt,
  required double hoursOld,
  required bool alreadyServed,
  required bool hotWeather,
}) {
  // ---- absolute rules, checked before anything else ----

  // Food that reached a plate or a buffet line has met many hands and
  // mouths. No amount of time or temperature makes it shareable again.
  if (alreadyServed) {
    return const ShareAnswer(
      verdict: ShareVerdict.no,
      headline: 'Do not share this',
      headlineHi: 'इसे न बाँटें',
      reason:
          'Food that has been served onto plates or stood on a buffet has '
          'been exposed to many people. No organisation can distribute it '
          'safely, whatever it looks like.',
      reasonHi:
          'जो खाना प्लेटों में परोसा जा चुका है या बुफ़े पर रखा रहा है, वह '
          'कई लोगों के संपर्क में आ चुका है। चाहे देखने में कैसा भी हो, कोई '
          'संस्था उसे सुरक्षित रूप से नहीं बाँट सकती।',
      action:
          'Compost it, or use it as animal feed if that is normal where you '
          'are. Next time, set surplus aside in the serving vessel before '
          'the meal starts.',
      actionHi:
          'इसे खाद बना दें, या जहाँ सामान्य हो वहाँ पशु आहार के रूप में '
          'इस्तेमाल करें। अगली बार खाना शुरू होने से पहले ही बचा हुआ हिस्सा '
          'परोसने के बर्तन में अलग रख लें।',
    );
  }

  // Sealed packets are governed by their own date, not by hours.
  if (kind == FoodKind.packagedSealed) {
    return const ShareAnswer(
      verdict: ShareVerdict.yes,
      headline: 'Yes, if the packet is intact',
      headlineHi: 'हाँ, अगर पैकेट सही सलामत है',
      reason:
          'Sealed packets are safe while the seal is unbroken and the date '
          'has not passed. "Best before" is about quality; "use by" is about '
          'safety and must not be passed.',
      reasonHi:
          'सीलबंद पैकेट तब तक सुरक्षित हैं जब तक सील टूटी न हो और तारीख़ न '
          'निकली हो। "बेस्ट बिफ़ोर" गुणवत्ता के बारे में है; "यूज़ बाय" '
          'सुरक्षा के बारे में है और उसे पार नहीं करना चाहिए।',
      action:
          'Check for dents, swelling, rust or leaks first. Anything damaged '
          'or already opened should not be donated.',
      actionHi:
          'पहले पिचकाव, फुलाव, जंग या रिसाव देख लें। जो ख़राब हो या पहले से '
          'खुला हो, उसे दान न करें।',
    );
  }

  if (kind == FoodKind.rawProduce) {
    return const ShareAnswer(
      verdict: ShareVerdict.yes,
      headline: 'Yes, if it is still firm and sound',
      headlineHi: 'हाँ, अगर अब भी ठोस और ठीक है',
      reason:
          'Uncooked vegetables and fruit keep much longer than cooked food. '
          'A little wilting is fine; mould, sliminess or a bad smell is not.',
      reasonHi:
          'कच्ची सब्ज़ी और फल पके खाने से कहीं ज़्यादा टिकते हैं। थोड़ा '
          'मुरझाना ठीक है; फफूँद, लसलसापन या बदबू ठीक नहीं।',
      action:
          'Sort out anything spoiled before you send it. One rotting item '
          'spoils the rest in transit.',
      actionHi:
          'भेजने से पहले ख़राब चीज़ें छाँट लें। एक सड़ी चीज़ रास्ते में बाक़ी '
          'को भी ख़राब कर देती है।',
    );
  }

  // ---- cooked food: time and temperature ----

  // Held properly hot or properly cold, food stays out of the 5-60C range
  // where bacteria multiply fastest.
  if (heldAt == HeldAt.hotHeld || heldAt == HeldAt.refrigerated) {
    final limit = kind == FoodKind.cookedHighRisk ? 12.0 : 24.0;
    if (hoursOld <= limit) {
      return ShareAnswer(
        verdict: ShareVerdict.yes,
        headline: 'Yes, share it now',
        headlineHi: 'हाँ, अभी बाँट दें',
        reason: heldAt == HeldAt.hotHeld
            ? 'Food kept steaming hot stays out of the range where bacteria '
                'multiply fastest.'
            : 'Proper refrigeration slows bacteria enough to keep this safe.',
        reasonHi: heldAt == HeldAt.hotHeld
            ? 'भाप निकलता गर्म रखा खाना उस तापमान सीमा से बाहर रहता है जहाँ '
                'जीवाणु सबसे तेज़ी से बढ़ते हैं।'
            : 'सही फ़्रिज जीवाणुओं को इतना धीमा कर देता है कि यह सुरक्षित रहे।',
        action:
            'Keep it hot or cold right up to handover, label it with what it '
            'is and when it was cooked, and move it quickly.',
        actionHi:
            'सौंपने तक इसे गर्म या ठंडा बनाए रखें, लेबल पर लिखें कि क्या है '
            'और कब पका, और जल्दी पहुँचाएँ।',
      );
    }
    return const ShareAnswer(
      verdict: ShareVerdict.no,
      headline: 'Too old now',
      headlineHi: 'अब बहुत पुराना हो गया',
      reason:
          'Even kept hot or chilled, cooked food has a limit. Past it, the '
          'risk is no longer worth taking for someone else.',
      reasonHi:
          'गर्म या ठंडा रखा हो तब भी पके खाने की एक सीमा होती है। उसके बाद '
          'किसी और के लिए यह जोखिम लेना ठीक नहीं।',
      action: 'Compost it. Share earlier next time, not later.',
      actionHi:
          'इसे खाद बना दें। अगली बार देर से नहीं, जल्दी बाँटें।',
    );
  }

  // Room temperature: the two-hour rule, halved in hot weather.
  final window = hotWeather ? 1.0 : 2.0;

  if (hoursOld <= window * 0.5) {
    return ShareAnswer(
      verdict: ShareVerdict.yes,
      headline: 'Yes, and go now',
      headlineHi: 'हाँ, और अभी निकलें',
      reason: hotWeather
          ? 'In this heat, food at room temperature is safe for about an '
              'hour. You are well inside that.'
          : 'Food at room temperature is safe for about two hours. You are '
              'well inside that.',
      reasonHi: hotWeather
          ? 'इस गर्मी में कमरे के तापमान पर रखा खाना लगभग एक घंटे तक सुरक्षित '
              'है। आप उसके भीतर हैं।'
          : 'कमरे के तापमान पर रखा खाना लगभग दो घंटे तक सुरक्षित है। आप उसके '
              'भीतर हैं।',
      action:
          'Cover it, label it with the cooking time, and hand it over as '
          'soon as you can.',
      actionHi:
          'ढक दें, पकाने का समय लिख दें, और जितनी जल्दी हो सके सौंप दें।',
    );
  }

  if (hoursOld <= window) {
    return const ShareAnswer(
      verdict: ShareVerdict.soon,
      headline: 'Only if it can be eaten very soon',
      headlineHi: 'तभी, जब बहुत जल्दी खाया जा सके',
      reason:
          'You are close to the limit for food standing at room temperature. '
          'It is still safe, but it will not be for much longer.',
      reasonHi:
          'कमरे के तापमान पर रखे खाने की सीमा नज़दीक है। अभी सुरक्षित है, '
          'पर ज़्यादा देर नहीं रहेगा।',
      action:
          'Only send it if someone nearby can collect and serve it within '
          'the hour. Otherwise do not risk it.',
      actionHi:
          'तभी भेजें जब पास कोई एक घंटे के भीतर लेकर परोस सके। वरना जोखिम '
          'न लें।',
    );
  }

  return ShareAnswer(
    verdict: ShareVerdict.no,
    headline: 'Do not share this',
    headlineHi: 'इसे न बाँटें',
    reason: kind == FoodKind.cookedHighRisk
        ? 'This is a high-risk food and it has stood too long at room '
            'temperature. Reheating will not make it safe — the toxins '
            'bacteria leave behind survive boiling.'
        : 'It has stood too long at room temperature. Reheating will not '
            'make it safe, because the toxins bacteria leave behind survive '
            'boiling.',
    reasonHi: kind == FoodKind.cookedHighRisk
        ? 'यह ज़्यादा जोखिम वाला खाना है और कमरे के तापमान पर बहुत देर पड़ा '
            'रहा। दोबारा गर्म करने से सुरक्षित नहीं होगा — जीवाणुओं के छोड़े '
            'विष उबालने से भी नहीं मरते।'
        : 'यह कमरे के तापमान पर बहुत देर पड़ा रहा। दोबारा गर्म करने से '
            'सुरक्षित नहीं होगा, क्योंकि जीवाणुओं के छोड़े विष उबालने से भी '
            'नहीं मरते।',
    action:
        'Compost it. To share next time, set the surplus aside as soon as '
        'cooking finishes and call a collection partner straight away.',
    actionHi:
        'इसे खाद बना दें। अगली बार बाँटने के लिए, पकते ही बचा हुआ हिस्सा अलग '
        'रख दें और तुरंत किसी संग्रह साथी को फ़ोन करें।',
  );
}
