import '../../core/sdg/advice.dart';

/// SDG 15 decision logic: can this family or village claim under the
/// Forest Rights Act, 2006, and how?
///
/// The Act is one of the largest land-rights laws in the world, and most
/// people it covers have never filed. The usual reasons are not knowing
/// they qualify, and not knowing that the Gram Sabha — not the forest
/// department — starts the process. Eligibility, from the Act:
///  * Forest-dwelling Scheduled Tribes: ST in the area where the right is
///    claimed, mainly living in and depending on forest land before
///    13 December 2005.
///  * Other Traditional Forest Dwellers: mainly living in and depending on
///    forest land for at least three generations (75 years) before
///    13 December 2005.
///  * Land title covers only land actually cultivated on 13 December 2005,
///    up to 4 hectares. No new land is granted.

enum Claimant { stHere, nonSt }

enum Claim { ownLand, villageUse, villageForest }

const _ncstFra =
    'https://ncst.nic.in/page/the-scheduled-tribes-and-other-traditional-forest-dwellers-recognition-of-forest-rights-rules-2006';

const _notEligible = Advice(
  title: 'This does not look eligible under the Act',
  titleHi: 'यह इस क़ानून में पात्र नहीं लगता',
  body: 'The Act requires living in and depending on forest land before '
      '13 December 2005 — and, for people who are not Scheduled Tribes in '
      'that area, for three generations (75 years) before that date. If '
      'you are unsure of the dates, older relatives\' statements count as '
      'evidence, so ask your Forest Rights Committee before deciding.',
  bodyHi: 'क़ानून के लिए 13 दिसंबर 2005 से पहले वन भूमि पर रहना और उस पर निर्भर होना '
      'ज़रूरी है — और जो उस इलाक़े में अनुसूचित जनजाति नहीं हैं, उनके लिए उस तारीख़ से '
      'पहले तीन पीढ़ियों (75 साल) तक। तारीख़ों को लेकर पक्का न हों, तो बुज़ुर्गों के बयान '
      'भी सबूत माने जाते हैं, इसलिए तय करने से पहले अपनी वन अधिकार समिति से पूछें।',
  source: _ncstFra,
);

const _individual = Advice(
  title: 'Individual claim for land you cultivate (Form A)',
  titleHi: 'खेती की ज़मीन के लिए व्यक्तिगत दावा (फ़ॉर्म ए)',
  body: 'You can claim title to the forest land your family was cultivating '
      'on 13 December 2005, up to 4 hectares — not more, and not new land. '
      'The title is in the names of both spouses, and cannot be sold or '
      'transferred, only inherited. File the claim with the Forest Rights '
      'Committee of your Gram Sabha.',
  bodyHi: 'आप उस वन भूमि के मालिकाना हक़ का दावा कर सकते हैं जिस पर आपका परिवार 13 '
      'दिसंबर 2005 को खेती कर रहा था, 4 हेक्टेयर तक — इससे ज़्यादा नहीं, और नई ज़मीन '
      'नहीं। हक़ पति-पत्नी दोनों के नाम होता है, और बेचा या हस्तांतरित नहीं हो सकता, '
      'सिर्फ़ विरासत में मिलता है। दावा अपनी ग्राम सभा की वन अधिकार समिति के पास दाख़िल '
      'करें।',
  source: _ncstFra,
);

const _community = Advice(
  title: 'Community rights: grazing, minor forest produce, water (Form B)',
  titleHi: 'सामुदायिक अधिकार: चराई, लघु वनोपज, पानी (फ़ॉर्म बी)',
  body: 'The village can claim rights it has traditionally used — grazing, '
      'collecting and selling minor forest produce like tendu leaves, '
      'bamboo, honey and mahua, fishing in forest water bodies, and access '
      'to traditional seasonal resources. The Gram Sabha files these '
      'together, so no single family has to.',
  bodyHi: 'गाँव उन अधिकारों का दावा कर सकता है जिनका वह परंपरा से उपयोग करता आया है — '
      'चराई, तेंदू पत्ता, बाँस, शहद और महुआ जैसी लघु वनोपज इकट्ठा करना और बेचना, वन के '
      'जलाशयों में मछली पकड़ना, और मौसमी पारंपरिक संसाधनों तक पहुँच। ग्राम सभा ये दावे '
      'मिलकर दाख़िल करती है, किसी एक परिवार को नहीं करना पड़ता।',
  source: _ncstFra,
);

const _cfr = Advice(
  title: 'Community forest resource: the right to protect and manage (Form C)',
  titleHi: 'सामुदायिक वन संसाधन: रक्षा और प्रबंधन का अधिकार (फ़ॉर्म सी)',
  body: 'The Gram Sabha can claim the right to protect, regenerate, conserve '
      'and manage the forest it has traditionally used. Villages that hold '
      'this right decide how their forest is used and can stop destructive '
      'activity in it. Map the traditional boundary with neighbouring '
      'villages before filing, since overlaps slow claims down.',
  bodyHi: 'ग्राम सभा उस जंगल की रक्षा, पुनर्जनन, संरक्षण और प्रबंधन के अधिकार का दावा कर '
      'सकती है जिसका वह परंपरा से उपयोग करती आई है। जिन गाँवों के पास यह अधिकार है, वे '
      'तय करते हैं कि उनके जंगल का उपयोग कैसे हो और उसमें विनाशकारी गतिविधि रोक सकते '
      'हैं। दावा करने से पहले पड़ोसी गाँवों के साथ पारंपरिक सीमा का नक्शा बना लें, क्योंकि '
      'टकराव से दावे धीमे होते हैं।',
  source: _ncstFra,
);

const _evidence = Advice(
  title: 'Evidence: more kinds count than people think',
  titleHi: 'सबूत: लोग जितना सोचते हैं, उससे ज़्यादा चीज़ें मान्य हैं',
  body: 'You do not need a land document. Accepted evidence includes old '
      'government records and survey maps, voter ID, ration card or house '
      'tax receipts, physical signs on the land such as a house, well, '
      'bunds or old trees planted, earlier court or forest department '
      'records such as fines, and written statements of village elders. '
      'Give at least two kinds. The Forest Rights Committee verifies on the '
      'spot, then the Gram Sabha passes a resolution, which goes to the '
      'Sub-Divisional and then District committee for the title.',
  bodyHi: 'ज़मीन का काग़ज़ ज़रूरी नहीं। मान्य सबूतों में पुराने सरकारी रिकॉर्ड और सर्वे '
      'नक्शे, वोटर आईडी, राशन कार्ड या मकान कर की रसीदें, ज़मीन पर दिखने वाले निशान जैसे '
      'घर, कुआँ, मेड़ या लगाए हुए पुराने पेड़, पुराने अदालती या वन विभाग के रिकॉर्ड जैसे '
      'जुर्माने, और गाँव के बुज़ुर्गों के लिखित बयान शामिल हैं। कम से कम दो तरह के सबूत '
      'दें। वन अधिकार समिति मौके पर जाँच करती है, फिर ग्राम सभा प्रस्ताव पास करती है, जो '
      'हक़ के लिए उप-मंडल और फिर ज़िला समिति के पास जाता है।',
  source: _ncstFra,
);

const _appeal = Advice(
  title: 'Rejected? You can appeal, and must be heard',
  titleHi: 'दावा ख़ारिज? अपील कर सकते हैं, और सुनवाई ज़रूरी है',
  body: 'Anyone unhappy with the Gram Sabha\'s resolution can petition the '
      'Sub-Divisional Level Committee within 60 days, and from there the '
      'District Level Committee. A claim may not be rejected without '
      'giving reasons and a chance to be heard. Ask for the rejection in '
      'writing.',
  bodyHi: 'ग्राम सभा के प्रस्ताव से असंतुष्ट कोई भी व्यक्ति 60 दिन के भीतर उप-मंडल स्तरीय '
      'समिति में याचिका दे सकता है, और वहाँ से ज़िला स्तरीय समिति में। कारण बताए और सुनवाई '
      'का मौक़ा दिए बिना दावा ख़ारिज नहीं किया जा सकता। ख़ारिजी लिखित में माँगें।',
  source: _ncstFra,
);

/// What to file and how. Never empty.
List<Advice> forestRights({
  required Claimant who,
  required bool before2005,
  required bool threeGenerations,
  required Set<Claim> wants,
}) {
  final eligible = before2005 && (who == Claimant.stHere || threeGenerations);
  if (!eligible) return [_notEligible];
  return [
    if (wants.contains(Claim.ownLand)) _individual,
    if (wants.contains(Claim.villageUse)) _community,
    if (wants.contains(Claim.villageForest)) _cfr,
    _evidence,
    _appeal,
  ];
}
