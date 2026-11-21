import 'package:flutter/material.dart';

import '../../core/widgets/module_hub.dart';
import '../../core/widgets/tool_kit.dart';

/// Reporting harm to the forest: illegal felling or poaching, and a fire.
///
/// Both screens put the reporter's own safety first. Nobody should walk up
/// to a timber gang or a poacher with a phone held out, and nobody should
/// try to fight a running forest fire. What helps is a fast, precise
/// report from a safe distance.

const _wccbUrl = 'https://wccb.gov.in/';
const _fsiUrl = 'https://fsiforestfire.gov.in/';
const _moefccUrl = 'https://moef.gov.in/';

// --- Illegal felling or poaching --------------------------------------

class IllegalFellingPage extends StatelessWidget {
  const IllegalFellingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 15,
      title: hi ? 'अवैध कटाई या शिकार देखा' : 'Illegal felling or poaching seen',
      children: [
        ToolAnswer(
          headline: hi ? 'सामने न जाएँ' : 'Do not confront them',
          detail: hi
              ? 'लकड़ी काटने वाले गिरोह और शिकारी अक्सर हथियारबंद होते हैं। दूर से, '
                  'छिपकर देखें, और जगह छोड़ने के बाद ही फ़ोन करें। जान ख़तरे में हो तो '
                  '112।'
              : 'Timber gangs and poachers are often armed. Watch from a distance, '
                  'out of sight, and phone only after you have left the spot. If '
                  'a life is in danger, 112.',
          tone: ToolTone.bad,
          icon: Icons.warning_amber_outlined,
        ),
        const SizedBox(height: 12),
        Text(hi ? 'जो लिख लें' : 'What to note',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'जगह — पास का गाँव, रास्ता, कोई निशानी; फ़ोन में जगह (लोकेशन) सहेज '
                      'लें',
                  'तारीख़ और समय',
                  'कितने लोग, और कैसी गाड़ी — गाड़ी का नंबर सबसे काम का सबूत है',
                  'क्या काटा या मारा जा रहा था',
                  'फ़ोटो सिर्फ़ तभी, जब कोई देख न रहा हो',
                ]
              : const [
                  'The place - nearest village, track, any landmark; save the '
                      'location on your phone',
                  'The date and time',
                  'How many people, and what vehicle - the number plate is the '
                      'most useful evidence there is',
                  'What was being cut or killed',
                  'A photo only if nobody is watching you',
                ],
        ),
        const SizedBox(height: 12),
        Text(hi ? 'कहाँ बताएँ' : 'Where to report',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'वन विभाग का रेंज ऑफ़िस या राज्य की वन हेल्पलाइन — जितनी जल्दी, उतना '
                      'अच्छा; ट्रक निकल जाने के बाद पकड़ना मुश्किल होता है।',
                  'वन्यजीव अपराध नियंत्रण ब्यूरो (डब्ल्यूसीसीबी) अपनी वेबसाइट पर शिकायत '
                      'लेता है — शिकार, जानवरों के अंगों या पक्षियों की तस्करी के लिए। '
                      'नाम देना ज़रूरी नहीं।',
                  'पुलिस थाने में भी सूचना दी जा सकती है; वन अपराध में पुलिस भी कार्रवाई '
                      'कर सकती है।',
                ]
              : const [
                  'The forest department range office or the state forest '
                      'helpline - the sooner the better; once the truck has '
                      'gone it is hard to catch.',
                  'The Wildlife Crime Control Bureau takes reports on its '
                      'website - for poaching, trade in animal parts, or bird '
                      'trafficking. You do not have to give your name.',
                  'The police station can be told as well; the police can act '
                      'on forest offences too.',
                ],
        ),
        const SizedBox(height: 10),
        ToolNote(hi
            ? 'जंगल में लगे फंदे, जाल या ज़हर का चारा न छुएँ और न हटाएँ — उसकी जगह '
                'बताएँ। हटाने से सबूत मिट जाता है, और कुछ फंदे चोट पहुँचाते हैं।'
            : 'Do not touch or remove a snare, trap or poisoned bait in the '
                'forest - report where it is. Removing it destroys the evidence, '
                'and some snares injure.'),
        const SourceNote(text: 'Wildlife Crime Control Bureau', url: _wccbUrl),
      ],
    );
  }
}

// --- Forest fire ------------------------------------------------------

class ForestFirePage extends StatelessWidget {
  const ForestFirePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 15,
      title: hi ? 'जंगल में आग देखी' : 'Forest fire seen',
      children: [
        ToolAnswer(
          headline: hi ? 'पहले ख़ुद सुरक्षित, फिर फ़ोन' : 'Get safe first, then call',
          detail: hi
              ? 'आग ढलान पर ऊपर की ओर बहुत तेज़ चढ़ती है — इसलिए ऊपर की ओर न भागें। '
                  'आग की दिशा के आर-पार और नीचे की ओर निकलें, किसी रास्ते, नदी, खेत या '
                  'पहले से जली ज़मीन की तरफ़। फिर वन विभाग या राज्य की वन हेल्पलाइन पर, '
                  'और 112 या 101 पर।'
              : 'Fire climbs a slope very fast - so do not run uphill. Get out '
                  'across the fire\'s path and downhill, towards a road, a '
                  'river, a field or ground that has already burnt. Then call '
                  'the forest department or the state forest helpline, and 112 '
                  'or 101.',
          tone: ToolTone.bad,
          icon: Icons.local_fire_department_outlined,
        ),
        const SizedBox(height: 12),
        Text(hi ? 'बताते समय' : 'When you report it',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          numbered: false,
          steps: hi
              ? const [
                  'आग कहाँ है — गाँव, पहाड़ी, रास्ता, कोई निशानी',
                  'धुआँ किस तरफ़ जा रहा है, और कितनी तेज़ी से फैल रही है',
                  'कोई गाँव, खेत या घर उसके रास्ते में है या नहीं',
                ]
              : const [
                  'Where it is - village, hill, track, any landmark',
                  'Which way the smoke is blowing, and how fast it is spreading',
                  'Whether a village, fields or houses lie in its path',
                ],
        ),
        const SizedBox(height: 12),
        ToolDonts(
          heading: hi ? 'न करें' : 'Do not',
          items: hi
              ? const [
                  'बड़ी, फैलती आग बुझाने की कोशिश न करें — यह वन विभाग की टीम का काम है',
                  'नाले या संकरी घाटी में न छिपें — वहाँ आग और धुआँ चिमनी की तरह ऊपर '
                      'चढ़ते हैं',
                  'धुएँ में साँस न लें — गीला कपड़ा नाक-मुँह पर रखें और नीचे झुककर चलें',
                  'जंगल के पास खेत की पराली या झाड़ियाँ न जलाएँ — बहुत सी जंगल की आग '
                      'यहीं से शुरू होती है',
                ]
              : const [
                  'Do not try to put out a large, spreading fire - that is the '
                      'forest team\'s job',
                  'Do not shelter in a gully or narrow ravine - fire and smoke '
                      'rush up it like a chimney',
                  'Do not breathe the smoke - put a wet cloth over nose and '
                      'mouth and keep low',
                  'Do not burn stubble or scrub near a forest - a great many '
                      'forest fires start exactly there',
                ],
        ),
        const SizedBox(height: 12),
        ToolNote(hi
            ? 'शुरुआत की छोटी आग, जो ज़मीन पर ही सूखे पत्तों में हो, हरी पत्तेदार डाली '
                'से पीटकर बुझाई जा सकती है — पर सिर्फ़ तब, जब पीछे निकलने का साफ़ रास्ता '
                'हो और आप अकेले न हों। भारतीय वन सर्वेक्षण उपग्रह से आग की सूचना भेजता '
                'है; ग्राम वन समिति उसके लिए पंजीकरण करा सकती है।'
            : 'A small fire just starting, on the ground in dry leaves, can be '
                'beaten out with a green leafy branch - but only with a clear '
                'way out behind you and never alone. The Forest Survey of India '
                'sends satellite fire alerts; a village forest committee can '
                'register to receive them.'),
        const SourceNote(text: 'Forest Survey of India - fire alerts', url: _fsiUrl),
        const SourceNote(
            text: 'Ministry of Environment, Forest and Climate Change',
            url: _moefccUrl),
      ],
    );
  }
}
