import '../../core/sdg/advice.dart';

/// SDG 13 decision logic: heat illness, and the crop-loss reporting clock.

// ---------------------------------------------------------------------------
// Heat illness
//
// The one distinction that matters is heat stroke versus everything milder.
// Heat stroke is a medical emergency in which the brain is affected; the
// tell is a change in behaviour - confusion, slurred speech, fainting, a
// fit - in someone who has been in the heat. Any one of those signs is
// treated as heat stroke. Getting this wrong in the safe direction costs an
// ambulance call; getting it wrong the other way costs a life.

enum HeatSign {
  confused, // confused, agitated, strange behaviour or slurred speech
  collapsed, // fainted, unconscious, or had a fit
  hotSkin, // skin very hot to touch, dry or sweating
  vomiting, // vomiting repeatedly
  heavySweat, // heavy sweating, cold clammy skin
  dizzy, // dizzy, weak, very tired, headache
  cramps, // painful muscle cramps
  thirsty, // very thirsty, little or dark urine
}

enum HeatLevel { stroke, exhaustion, mild, none }

HeatLevel heatLevel(Set<HeatSign> signs) {
  if (signs.contains(HeatSign.confused) || signs.contains(HeatSign.collapsed)) {
    return HeatLevel.stroke;
  }
  // Very hot skin with vomiting, without the brain signs yet, is treated
  // as stroke too: it is how it often starts, and it cannot be watched
  // safely at home.
  if (signs.contains(HeatSign.hotSkin) && signs.contains(HeatSign.vomiting)) {
    return HeatLevel.stroke;
  }
  if (signs.contains(HeatSign.hotSkin) ||
      signs.contains(HeatSign.vomiting) ||
      signs.contains(HeatSign.heavySweat) ||
      signs.contains(HeatSign.dizzy)) {
    return HeatLevel.exhaustion;
  }
  if (signs.isNotEmpty) return HeatLevel.mild;
  return HeatLevel.none;
}

const _mayo = 'https://www.mayoclinic.org/first-aid/first-aid-heatstroke/basics/art-20056655';

List<Advice> heatAdvice(HeatLevel level) => switch (level) {
      HeatLevel.stroke => const [
          Advice(
            title: 'This may be heat stroke. Call 108 now.',
            titleHi: 'यह हीट स्ट्रोक हो सकता है। अभी 108 पर कॉल करें।',
            body: 'Heat stroke can kill within hours and needs a hospital. '
                'Call 108 (or 112) first, then start cooling while you wait — '
                'do not wait for the ambulance to begin.',
            bodyHi: 'हीट स्ट्रोक कुछ घंटों में जान ले सकता है और अस्पताल चाहिए। पहले 108 '
                '(या 112) पर कॉल करें, फिर इंतज़ार करते हुए ठंडा करना शुरू करें — '
                'एम्बुलेंस का इंतज़ार करके शुरुआत न करें।',
            source: _mayo,
            phone: '108',
          ),
          Advice(
            title: 'Cool the body, fast',
            titleHi: 'शरीर को जल्दी ठंडा करें',
            body: 'Move the person into shade or a cool room. Take off extra '
                'clothing. Pour or sponge cool water over the body and fan '
                'hard. Put wet cloths or ice packs on the neck, armpits and '
                'groin. Keep doing this until help arrives.',
            bodyHi: 'व्यक्ति को छाँव या ठंडे कमरे में ले जाएँ। ज़्यादा कपड़े उतारें। शरीर '
                'पर ठंडा पानी डालें या पोंछें और ज़ोर से पंखा करें। गर्दन, बगल और जाँघों के '
                'जोड़ पर गीले कपड़े या बर्फ़ की थैली रखें। मदद आने तक यह करते रहें।',
            source: _mayo,
          ),
          Advice(
            title: 'Nothing by mouth unless fully awake',
            titleHi: 'पूरी तरह होश में न हो तो मुँह से कुछ न दें',
            body: 'Someone who is confused or drowsy can choke. Give sips of '
                'cool water only if they are fully awake and can swallow. No '
                'tea, coffee or alcohol. If they stop breathing, start CPR.',
            bodyHi: 'भ्रमित या उनींदा व्यक्ति का दम घुट सकता है। ठंडे पानी के घूँट तभी दें '
                'जब वह पूरी तरह जागा हो और निगल सके। चाय, कॉफ़ी या शराब नहीं। साँस रुक '
                'जाए तो सीपीआर शुरू करें।',
            source: _mayo,
          ),
        ],
      HeatLevel.exhaustion => const [
          Advice(
            title: 'Heat exhaustion — stop, cool down, drink',
            titleHi: 'गर्मी से थकावट — रुकें, ठंडे हों, पिएँ',
            body: 'Stop all work and rest in shade or a cool room, lying down '
                'with the legs raised a little. Loosen clothing, sponge with '
                'cool water and fan. Drink water or ORS in small, steady '
                'sips. If it is not clearly better within an hour, or gets '
                'worse, go to a health centre. If confusion, fainting or a '
                'fit appear at any point, it has become heat stroke — call 108.',
            bodyHi: 'सारा काम रोकें और छाँव या ठंडे कमरे में आराम करें, पैर थोड़े ऊँचे करके '
                'लेटें। कपड़े ढीले करें, ठंडे पानी से पोंछें और पंखा करें। पानी या ओआरएस '
                'छोटे-छोटे घूँट में लगातार पिएँ। एक घंटे में साफ़ सुधार न हो, या हालत बिगड़े, '
                'तो स्वास्थ्य केंद्र जाएँ। किसी भी समय भ्रम, बेहोशी या दौरा दिखे तो यह हीट '
                'स्ट्रोक बन चुका है — 108 पर कॉल करें।',
            source: _mayo,
            phone: '108',
          ),
        ],
      HeatLevel.mild => const [
          Advice(
            title: 'Early signs — act now so it stops here',
            titleHi: 'शुरुआती लक्षण — अभी कदम उठाएँ ताकि यहीं रुक जाए',
            body: 'Move out of the sun, rest, drink water or ORS, and stretch '
                'cramped muscles gently. Do not go back to heavy work in the '
                'heat today. Watch for dizziness, vomiting, confusion or '
                'fainting — those mean it is getting worse.',
            bodyHi: 'धूप से हटें, आराम करें, पानी या ओआरएस पिएँ, और ऐंठी मांसपेशियों को '
                'धीरे से खींचें। आज गर्मी में भारी काम पर न लौटें। चक्कर, उल्टी, भ्रम या '
                'बेहोशी पर नज़र रखें — इनका मतलब है हालत बिगड़ रही है।',
            source: _mayo,
          ),
        ],
      HeatLevel.none => const [],
    };

// ---------------------------------------------------------------------------
// Crop loss under PM Fasal Bima Yojana
//
// The scheme pays for two kinds of individual loss only if the farmer
// reports it within 72 hours: a local disaster hitting a standing crop,
// and rain or storm damage to a harvested crop left to dry in the field
// within 14 days of harvest. Area-wide losses (drought, widespread flood)
// are assessed through crop-cutting surveys and need no individual report.
// Most claims that fail, fail on the clock - so the tool computes it.

enum CropLoss {
  localStanding, // hail, landslide, waterlogging, cloudburst, lightning fire
  postHarvest, // harvested crop drying in field hit by rain, hail, cyclone
  widespread, // drought, a flood across the whole area
}

const reportWindow = Duration(hours: 72);
const postHarvestDays = 14;

class CropClock {
  /// When the report must be made by, or null for area-wide loss.
  final DateTime? deadline;

  /// False when a post-harvest loss falls outside the 14-day cover.
  final bool covered;

  const CropClock(this.deadline, this.covered);
}

CropClock cropClock({
  required CropLoss loss,
  required DateTime damagedAt,
  DateTime? harvestedOn,
}) {
  if (loss == CropLoss.widespread) return const CropClock(null, true);
  final deadline = damagedAt.add(reportWindow);
  if (loss == CropLoss.postHarvest) {
    if (harvestedOn == null) return CropClock(deadline, true);
    final h = DateTime(harvestedOn.year, harvestedOn.month, harvestedOn.day);
    final d = DateTime(damagedAt.year, damagedAt.month, damagedAt.day);
    final days = d.difference(h).inDays;
    return CropClock(deadline, days >= 0 && days <= postHarvestDays);
  }
  return CropClock(deadline, true);
}

const pmfby = 'https://pmfby.gov.in/';

const cropReportHow = Advice(
  title: 'How to report: 14447, the app, or in writing',
  titleHi: 'कैसे बताएँ: 14447, ऐप, या लिखकर',
  body: 'Call the crop insurance helpline 14447, use the Crop Insurance app, '
      'or give a written report to the insurance company for your district, '
      'your bank, or the agriculture office. Say: your name, village, the '
      'survey or khasra number, the crop, the insured area, the date and '
      'cause of damage, and your policy or account number. Write down the '
      'docket number you are given and take photos of the damage with the '
      'date. A surveyor should then inspect the field.',
  bodyHi: 'फ़सल बीमा हेल्पलाइन 14447 पर कॉल करें, क्रॉप इंश्योरेंस ऐप इस्तेमाल करें, '
      'या ज़िले की बीमा कंपनी, अपने बैंक, या कृषि कार्यालय को लिखित सूचना दें। बताएँ: '
      'नाम, गाँव, सर्वे या खसरा नंबर, फ़सल, बीमित रकबा, नुक़सान की तारीख़ और कारण, '
      'और पॉलिसी या खाता संख्या। जो डॉकेट नंबर मिले उसे लिख लें, और नुक़सान की तारीख़ '
      'वाली फ़ोटो लें। इसके बाद सर्वेयर को खेत का निरीक्षण करना चाहिए।',
  source: pmfby,
  phone: '14447',
);
