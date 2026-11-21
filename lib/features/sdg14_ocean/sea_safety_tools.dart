import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../core/place/place.dart';
import '../../core/place/place_service.dart';
import '../../core/widgets/module_hub.dart';
import '../../core/widgets/tool_kit.dart';

/// Safety at sea: today's sea, the kit before leaving, and what to do when
/// a boat crosses the line or is seized.
///
/// The sea-state screen never says it is safe to go. A model wave height
/// for a grid cell several kilometres wide is not a navigation forecast,
/// and its own maker says so. What the screen can honestly do is say when
/// the numbers reach the level at which warnings are normally issued, and
/// put the official sources first.

const _incoisUrl = 'https://incois.gov.in/';
const _imdUrl = 'https://mausam.imd.gov.in/';
const _realcraftUrl = 'https://realcraft.gov.in/';
const _mea = 'https://www.mea.gov.in/';

const coastGuard = '1554';

/// Douglas sea scale, metres of significant wave height.
const seaModerate = 1.25;
const seaRough = 2.5;

/// Gusts, km/h, at which fishers are normally advised not to venture.
const gustNoVenture = 50.0;

class _Sea {
  final double? nowM;
  final List<double?> maxM;
  const _Sea(this.nowM, this.maxM);
}

Future<_Sea?> _fetchSea(Place p) async {
  try {
    final uri = Uri.parse('https://marine-api.open-meteo.com/v1/marine'
        '?latitude=${p.lat.toStringAsFixed(4)}'
        '&longitude=${p.lon.toStringAsFixed(4)}'
        '&current=wave_height&daily=wave_height_max'
        '&forecast_days=3&timezone=auto');
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) return null;
    final body = jsonDecode(res.body);
    if (body is! Map) return null;
    double? n(Object? v) => v is num ? v.toDouble() : null;
    final current = body['current'];
    final nowM = current is Map ? n(current['wave_height']) : null;
    final daily = body['daily'];
    final maxM = <double?>[];
    if (daily is Map && daily['wave_height_max'] is List) {
      for (final v in daily['wave_height_max'] as List) {
        maxM.add(n(v));
      }
    }
    if (nowM == null && maxM.every((v) => v == null)) return null;
    return _Sea(nowM, maxM);
  } catch (_) {
    return null;
  }
}

String _seaWord(double m, bool hi) {
  if (m >= 4) return hi ? 'बहुत ऊँची लहरें' : 'Very rough';
  if (m >= seaRough) return hi ? 'ऊँची लहरें (रफ़)' : 'Rough';
  if (m >= seaModerate) return hi ? 'मध्यम' : 'Moderate';
  if (m >= 0.5) return hi ? 'हल्की' : 'Slight';
  return hi ? 'शांत' : 'Calm';
}

// --- Sea state today --------------------------------------------------

class SeaStatePage extends StatefulWidget {
  const SeaStatePage({super.key});

  @override
  State<SeaStatePage> createState() => _SeaStatePageState();
}

class _SeaStatePageState extends State<SeaStatePage> {
  Future<_Sea?>? _sea;
  Place? _for;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final service = context.watch<PlaceService>();
    final place = service.place;
    // Fetch once per place, compared by position: the service may rebuild
    // the same place as a new object when it refreshes the weather.
    if (place != null && (place.lat != _for?.lat || place.lon != _for?.lon)) {
      _for = place;
      _sea = _fetchSea(place);
    }
    final days = service.forecast?.days.take(3).toList() ?? const [];
    final gustToday = days.isNotEmpty ? days.first.gustKph : null;

    return ToolScaffold(
      goal: 14,
      title: hi ? 'आज समुद्र: जाएँ या न जाएँ' : 'Sea state today: go or do not go',
      children: [
        ToolAnswer(
          headline: hi ? 'पहले सरकारी चेतावनी देखें' : 'Check the official warning first',
          detail: hi
              ? 'मछुआरों के लिए चेतावनी मौसम विभाग और इनकॉइस देते हैं — रेडियो, '
                  'बंदरगाह के झंडे, मछुआरा संघ, और इनकॉइस का "समुद्र" ऐप। चेतावनी हो '
                  'तो मत जाइए, यह ऐप कुछ भी दिखाए। यह ऐप कभी नहीं कहता कि समुद्र '
                  'सुरक्षित है; यह सिर्फ़ बताता है कि आँकड़े चेतावनी के स्तर पर हैं '
                  'या नहीं।'
              : 'Warnings for fishers come from the Meteorological Department '
                  'and INCOIS - on the radio, the harbour flags, the fishers\' '
                  'association, and INCOIS\'s "SAMUDRA" app. If there is a '
                  'warning, do not go, whatever this app shows. This app never '
                  'says the sea is safe; it only says whether the numbers are '
                  'at warning level.',
          tone: ToolTone.warn,
          icon: Icons.campaign_outlined,
        ),
        const SizedBox(height: 12),
        if (place == null)
          ToolNote(hi
              ? 'अपना तटीय गाँव या बंदरगाह चुनें, तो यहाँ लहरों और हवा का अनुमान '
                  'दिखेगा।'
              : 'Pick your coastal village or harbour and the wave and wind '
                  'reading shows here.')
        else ...[
          Text(place.name,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          if (gustToday != null)
            ToolLine(hi ? 'आज हवा के झोंके' : 'Gusts today',
                hi ? '${gustToday.round()} किमी/घंटा' : '${gustToday.round()} km/h',
                strong: gustToday >= gustNoVenture),
          FutureBuilder<_Sea?>(
            future: _sea,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final sea = snap.data;
              if (sea == null) {
                return ToolNote(hi
                    ? 'इस जगह के लिए लहरों का अनुमान नहीं मिला — शायद जगह समुद्र से '
                        'दूर है या इंटरनेट नहीं है। इनकॉइस का "समुद्र" ऐप देखें।'
                    : 'No wave reading for this place - it may be too far from '
                        'the sea, or there is no internet. Use INCOIS\'s '
                        '"SAMUDRA" app.');
              }
              final labels = hi
                  ? const ['आज', 'कल', 'परसों']
                  : const ['Today', 'Tomorrow', 'Day after'];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (sea.nowM != null)
                    ToolLine(hi ? 'अभी लहरें' : 'Waves now',
                        '${sea.nowM!.toStringAsFixed(1)} m · ${_seaWord(sea.nowM!, hi)}',
                        strong: sea.nowM! >= seaModerate),
                  for (var i = 0; i < sea.maxM.length && i < 3; i++)
                    if (sea.maxM[i] != null)
                      ToolLine(
                          hi
                              ? '${labels[i]}, सबसे ऊँची'
                              : '${labels[i]}, highest',
                          '${sea.maxM[i]!.toStringAsFixed(1)} m · ${_seaWord(sea.maxM[i]!, hi)}',
                          strong: sea.maxM[i]! >= seaModerate),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          FutureBuilder<_Sea?>(
            future: _sea,
            builder: (context, snap) {
              final sea = snap.data;
              final worst = [
                sea?.nowM,
                if (sea != null && sea.maxM.isNotEmpty) sea.maxM.first,
              ].whereType<double>().fold<double>(0, (a, b) => a > b ? a : b);
              final windy = (gustToday ?? 0) >= gustNoVenture;
              if (worst >= seaRough || windy) {
                return ToolAnswer(
                  headline: hi ? 'चेतावनी के स्तर पर — न जाएँ' : 'At warning level - do not go',
                  detail: hi
                      ? 'लहरें ${seaRough.toStringAsFixed(1)} मीटर से ऊपर या झोंके '
                          '${gustNoVenture.round()} किमी/घंटा से ऊपर — इस स्तर पर मछुआरों '
                          'को आम तौर पर समुद्र में न जाने की सलाह दी जाती है। छोटी नाव '
                          'के लिए यह जानलेवा है।'
                      : 'Waves above ${seaRough.toStringAsFixed(1)} m or gusts '
                          'above ${gustNoVenture.round()} km/h - at this level '
                          'fishers are normally advised not to put to sea. For '
                          'a small boat it is deadly.',
                  tone: ToolTone.bad,
                  icon: Icons.do_not_disturb_on_outlined,
                );
              }
              if (worst >= seaModerate) {
                return ToolAnswer(
                  headline: hi ? 'छोटी नाव के लिए जोखिम' : 'Risky for small craft',
                  detail: hi
                      ? 'मध्यम लहरें। बड़ी नाव के लिए आम बात, पर देसी नाव, डोंगी और '
                          'कट्टमरम के लिए ख़तरनाक हो सकती हैं। जाना ही हो तो किनारे के '
                          'पास रहें, अकेले न जाएँ, और लाइफ़ जैकेट पहनें।'
                      : 'Moderate waves. Ordinary for a large boat, but they can '
                          'be dangerous for country craft, canoes and '
                          'catamarans. If you must go, stay near the shore, do '
                          'not go alone, and wear a life jacket.',
                  tone: ToolTone.warn,
                  icon: Icons.warning_amber_outlined,
                );
              }
              return ToolNote(hi
                  ? 'आँकड़े चेतावनी के स्तर पर नहीं हैं। फिर भी यह नेविगेशन का अनुमान '
                      'नहीं है — तट के पास इसकी सटीकता कम होती है।'
                  : 'The numbers are not at warning level. Even so this is '
                      'not a navigation forecast - its accuracy near the '
                      'coast is limited.');
            },
          ),
        ],
        const SizedBox(height: 10),
        ToolNote(hi
            ? 'समुद्र में मुसीबत हो तो तटरक्षक $coastGuard पर फ़ोन करें।'
            : 'In trouble at sea, call the Coast Guard on $coastGuard.'),
        const SourceNote(text: 'INCOIS - ocean state forecast', url: _incoisUrl),
        const SourceNote(text: 'India Meteorological Department', url: _imdUrl),
      ],
    );
  }
}

// --- Boat safety kit --------------------------------------------------

class BoatKitPage extends StatelessWidget {
  const BoatKitPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 14,
      title: hi ? 'नाव का सुरक्षा सामान' : 'Boat safety kit checklist',
      children: [
        ToolNote(hi
            ? 'हर यात्रा से पहले एक बार। निशान इस फ़ोन में रहते हैं; अगली यात्रा से '
                'पहले "सब हटाएँ" दबाकर फिर से जाँचें।'
            : 'Once before every trip. The ticks stay on this phone; clear them '
                'before the next trip and check again.'),
        const SizedBox(height: 10),
        const ToolChecklist(
          storageKey: 'boat_kit_v1',
          introEn: 'Tick each one as you check it on board.',
          introHi: 'नाव पर जाँचकर एक-एक पर निशान लगाएँ।',
          items: [
            CheckItem('jackets', 'A life jacket for every person on board',
                'हर व्यक्ति के लिए लाइफ़ जैकेट',
                noteEn: 'Worn, not stowed, in rough water. A jacket under the '
                    'deck is no use to someone already in the sea.',
                noteHi: 'ऊँची लहरों में पहनी हुई, रखी हुई नहीं। डेक के नीचे की जैकेट '
                    'समुद्र में गिरे व्यक्ति के काम नहीं आती।'),
            CheckItem('buoy', 'A lifebuoy with a rope', 'रस्सी के साथ लाइफ़बॉय'),
            CheckItem('dat', 'Distress alert transmitter or the NavIC device, working',
                'डिस्ट्रेस अलर्ट ट्रांसमीटर या नाविक यंत्र, चालू',
                noteEn: 'Test it in harbour. It sends your position when '
                    'nothing else can.',
                noteHi: 'बंदरगाह में जाँच लें। जब कुछ और काम न करे, यही आपकी जगह '
                    'भेजता है।'),
            CheckItem('phone', 'Phone charged, in a waterproof pouch, and a power bank',
                'फ़ोन चार्ज, पानी-रोधी थैली में, और पावर बैंक'),
            CheckItem('radio', 'VHF radio or a radio for weather bulletins',
                'वीएचएफ़ रेडियो, या मौसम सुनने का रेडियो'),
            CheckItem('gps', 'GPS with the border alert switched on',
                'सीमा की चेतावनी वाला जीपीएस, चालू'),
            CheckItem('flares', 'Flares or a bright torch, and a whistle',
                'फ़्लेयर या तेज़ टॉर्च, और सीटी'),
            CheckItem('firstaid', 'First aid kit', 'प्राथमिक उपचार का डिब्बा'),
            CheckItem('water', 'Drinking water and dry food for an extra day',
                'एक दिन ज़्यादा का पीने का पानी और सूखा खाना'),
            CheckItem('fuel', 'Extra fuel, and tools for the engine',
                'ज़्यादा ईंधन, और इंजन के औज़ार'),
            CheckItem('anchor', 'Anchor and spare rope', 'लंगर और फ़ालतू रस्सी'),
            CheckItem('papers', 'Registration, licence and every crew member\'s ID',
                'पंजीकरण, लाइसेंस, और हर साथी का पहचान पत्र',
                noteEn: 'In a sealed plastic bag. At a border or a check, '
                    'these are what get a crew home.',
                noteHi: 'बंद पन्नी में। सीमा पर या जाँच के समय यही काग़ज़ लोगों को '
                    'घर वापस लाते हैं।'),
            CheckItem('tell', 'Someone ashore knows where you are going and when you will return',
                'किनारे पर किसी को पता है कि आप कहाँ जा रहे हैं और कब लौटेंगे'),
          ],
        ),
        const SizedBox(height: 10),
        ToolNote(hi
            ? 'मुसीबत में तटरक्षक: $coastGuard।'
            : 'In trouble, the Coast Guard: $coastGuard.'),
        const SourceNote(text: 'ReALCraft - fishing vessels', url: _realcraftUrl),
      ],
    );
  }
}

// --- Border crossed or boat seized ------------------------------------

class BorderSeizurePage extends StatelessWidget {
  const BorderSeizurePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';

    return ToolScaffold(
      goal: 14,
      title: hi ? 'सीमा पार हो गई या नाव ज़ब्त' : 'Crossed the border or boat seized',
      children: [
        ToolAnswer(
          headline: hi ? 'परिवार के लिए पहले तीन फ़ोन' : 'The family\'s first three calls',
          detail: hi
              ? '1. ज़िले का मत्स्य विभाग (सहायक निदेशक मत्स्य) — गिरफ़्तारी की '
                  'ख़बर सरकार तक इन्हीं से पहुँचती है। 2. ज़िलाधिकारी कार्यालय। '
                  '3. अपना मछुआरा संघ या सहकारी समिति। तीनों को नाव का नाम, पंजीकरण '
                  'संख्या, हर साथी का नाम और कब निकले थे — लिखकर दें।'
              : '1. The district fisheries department (the Assistant Director of '
                  'Fisheries) - news of an arrest reaches the government through '
                  'them. 2. The District Collector\'s office. 3. Your fishers\' '
                  'association or cooperative. Give all three, in writing, the '
                  'boat\'s name, registration number, every crew member\'s name '
                  'and when they set out.',
          tone: ToolTone.bad,
          icon: Icons.phone_in_talk_outlined,
        ),
        const SizedBox(height: 12),
        Text(hi ? 'उसके बाद' : 'After that',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ToolSteps(
          steps: hi
              ? const [
                  'राज्य सरकार विदेश मंत्रालय को सूचना देती है, और वहाँ का भारतीय '
                      'उच्चायोग गिरफ़्तार मछुआरों से मिलने और कानूनी मदद का काम करता '
                      'है। यह रास्ता सरकारी है और मुफ़्त है।',
                  'हर साथी के आधार और मछुआरा पहचान पत्र की नक़ल, और नाव के काग़ज़ों '
                      'की नक़ल एक जगह रखें — पहचान जल्दी पक्की होती है तो रिहाई भी '
                      'जल्दी होती है।',
                  'कई राज्य गिरफ़्तार मछुआरों के परिवारों को रोज़ का गुज़ारा भत्ता देते '
                      'हैं। मत्स्य विभाग में लिखित आवेदन दें और रसीद लें।',
                  'देश के भीतर दूसरे राज्य ने नाव पकड़ी हो, तो वहाँ के मत्स्य विभाग का '
                      'आदेश और जुर्माने की रसीद माँगें — बिना रसीद के पैसा न दें।',
                ]
              : const [
                  'The state government informs the Ministry of External '
                      'Affairs, and the Indian High Commission there arranges '
                      'consular visits and legal help for arrested fishers. '
                      'This route is official and free.',
                  'Keep copies of every crew member\'s Aadhaar and fisher ID '
                      'and of the boat\'s papers in one place - the sooner '
                      'identity is confirmed, the sooner release can come.',
                  'Several states pay a daily allowance to the families of '
                      'arrested fishers. Apply in writing at the fisheries '
                      'department and take a receipt.',
                  'If another Indian state has seized the boat, ask for that '
                      'state\'s fisheries order and a receipt for any fine - '
                      'pay nothing without a receipt.',
                ],
        ),
        const SizedBox(height: 12),
        ToolDonts(
          heading: hi ? 'सावधानी' : 'Careful',
          items: hi
              ? const [
                  'रिहाई "दिलाने" के नाम पर पैसा माँगने वाले किसी भी व्यक्ति को पैसा न '
                      'दें — यह सबसे आम ठगी है',
                  'असली काग़ज़ किसी एजेंट को न सौंपें; नक़ल दें',
                  'आगे के लिए: जीपीएस या नाविक यंत्र की सीमा-चेतावनी चालू रखें, और '
                      'सीमा के पास मछली के पीछे न जाएँ',
                ]
              : const [
                  'Pay nobody who asks for money to "arrange" a release - it '
                      'is the commonest fraud there is',
                  'Hand no originals to an agent; give copies',
                  'For the future: keep the border alert on the GPS or NavIC '
                      'device switched on, and do not chase fish near the line',
                ],
        ),
        const SourceNote(text: 'Ministry of External Affairs', url: _mea),
      ],
    );
  }
}
