import '../../core/sdg/advice.dart';

/// SDG 10 decision logic: which certificate unlocks what, and who handles a
/// discrimination complaint.
///
/// The problem this solves is not missing schemes but a missing piece of
/// paper. A student loses a scholarship because the income certificate was
/// from the wrong year; an OBC candidate loses a central seat because the
/// certificate was not in the central "non-creamy layer" format. So the
/// tool starts from what the person needs it for and works back to the
/// papers.

enum CertPurpose { scholarship, reservation, disabilityBenefit, welfare }

enum SocialCategory { sc, st, obc, general, notSure }

enum IncomeBand { below8Lakh, above8Lakh, notSure }

const _digiLocker = 'https://www.digilocker.gov.in/';

const _caste = Advice(
  title: 'Caste certificate',
  titleHi: 'जाति प्रमाण पत्र',
  body: 'Issued by the revenue office — usually the Tehsildar or SDM — of '
      'the place where you normally live. Most states take applications '
      'online through their e-District or service portal, or at a Common '
      'Service Centre. You will usually need proof of residence and proof of '
      'caste, such as a parent\'s or close relative\'s certificate, or old '
      'school or land records. Keep the acknowledgement number. Once issued, '
      'many states also put it in DigiLocker, so you will not need the paper '
      'copy every time.',
  bodyHi: 'यह आपके निवास स्थान के राजस्व कार्यालय — आमतौर पर तहसीलदार या एसडीएम — '
      'से बनता है। ज़्यादातर राज्य अपने ई-डिस्ट्रिक्ट या सेवा पोर्टल पर, या कॉमन सर्विस '
      'सेंटर पर आवेदन लेते हैं। आमतौर पर निवास का प्रमाण और जाति का प्रमाण चाहिए, जैसे '
      'माता-पिता या नज़दीकी रिश्तेदार का प्रमाण पत्र, या पुराने स्कूल या ज़मीन के '
      'काग़ज़। पावती संख्या संभालकर रखें। बनने के बाद कई राज्य इसे डिजिलॉकर में भी डाल '
      'देते हैं, तो हर बार काग़ज़ी कॉपी की ज़रूरत नहीं पड़ती।',
  source: _digiLocker,
);

const _obc = Advice(
  title: 'OBC certificate — with "non-creamy layer"',
  titleHi: 'ओबीसी प्रमाण पत्र — "नॉन-क्रीमी लेयर" के साथ',
  body: 'For OBC reservation the certificate must say you are not in the '
      '"creamy layer". That depends on your parents\' posts and income — '
      'income over the limit (Rs 8 lakh a year, counted in a set way that '
      'leaves out salary and farm income) puts a family in the creamy layer. '
      'For central government jobs and central institutions the certificate '
      'must be in the central format and your caste must be on the central '
      'OBC list, which is not always the same as your state\'s list. The '
      'non-creamy layer part is tied to recent income, so check how recent '
      'a certificate the form asks for.',
  bodyHi: 'ओबीसी आरक्षण के लिए प्रमाण पत्र में लिखा होना चाहिए कि आप "क्रीमी लेयर" '
      'में नहीं हैं। यह माता-पिता के पद और आय पर निर्भर है — सीमा (साल में 8 लाख '
      'रुपये, एक तय तरीके से गिनी गई, जिसमें वेतन और खेती की आय नहीं जुड़ती) से '
      'ज़्यादा आय होने पर परिवार क्रीमी लेयर में आता है। केंद्र सरकार की नौकरियों और '
      'केंद्रीय संस्थानों के लिए प्रमाण पत्र केंद्रीय प्रारूप में होना चाहिए और आपकी '
      'जाति केंद्रीय ओबीसी सूची में होनी चाहिए, जो हमेशा राज्य की सूची जैसी नहीं होती। '
      'नॉन-क्रीमी लेयर हाल की आय से जुड़ा है, इसलिए देखें कि फ़ॉर्म कितना नया प्रमाण '
      'पत्र माँगता है।',
  source: 'https://www.ncbc.nic.in/',
);

const _ews = Advice(
  title: 'EWS certificate (for those not SC, ST or OBC)',
  titleHi: 'ईडब्ल्यूएस प्रमाण पत्र (जो एससी, एसटी या ओबीसी नहीं हैं)',
  body: 'The 10% Economically Weaker Section reservation is for families not '
      'covered by SC, ST or OBC reservation whose gross yearly income from '
      'all sources is below Rs 8 lakh. A family is also left out if it owns '
      '5 acres or more of farm land, a flat of 1,000 sq ft or more, or a '
      'residential plot of 100 sq yards or more in a notified municipality '
      '(200 sq yards elsewhere). "Family" means you, your parents, your '
      'spouse, and brothers, sisters and children under 18. It is based on '
      'the previous financial year\'s income, so get a fresh one each year. '
      'Issued by an officer not below Tehsildar.',
  bodyHi: '10% आर्थिक रूप से कमज़ोर वर्ग (ईडब्ल्यूएस) आरक्षण उन परिवारों के लिए है '
      'जो एससी, एसटी या ओबीसी आरक्षण में नहीं आते और जिनकी सभी स्रोतों से कुल सालाना '
      'आय 8 लाख रुपये से कम है। अगर परिवार के पास 5 एकड़ या ज़्यादा खेती की ज़मीन, '
      '1,000 वर्ग फ़ुट या बड़ा फ़्लैट, या अधिसूचित नगरपालिका में 100 वर्ग गज़ (बाक़ी '
      'जगह 200 वर्ग गज़) या बड़ा आवासीय प्लॉट है, तो भी परिवार बाहर है। "परिवार" यानी '
      'आप, माता-पिता, पति/पत्नी, और 18 साल से कम के भाई-बहन और बच्चे। यह पिछले '
      'वित्त वर्ष की आय पर बनता है, इसलिए हर साल नया बनवाएँ। तहसीलदार या उससे ऊपर के '
      'अधिकारी जारी करते हैं।',
  source: 'https://www.jeeadv.ac.in/forms/FORM-GEN-EWS.pdf',
);

const _income = Advice(
  title: 'Income certificate — for the right year',
  titleHi: 'आय प्रमाण पत्र — सही साल का',
  body: 'Scholarships and welfare schemes almost always ask for an income '
      'certificate from the revenue office, and most want one from the '
      'current or previous financial year. An old one is the commonest '
      'reason a scholarship form is rejected after the deadline has passed, '
      'when nothing can be fixed. Apply early — weeks, not days, before the '
      'last date.',
  bodyHi: 'छात्रवृत्ति और कल्याण योजनाएँ लगभग हमेशा राजस्व कार्यालय का आय प्रमाण पत्र '
      'माँगती हैं, और ज़्यादातर चालू या पिछले वित्त वर्ष का। पुराना प्रमाण पत्र सबसे आम '
      'कारण है कि छात्रवृत्ति फ़ॉर्म आख़िरी तारीख़ निकलने के बाद रद्द हो जाता है, जब कुछ '
      'ठीक नहीं हो सकता। जल्दी आवेदन करें — आख़िरी तारीख़ से दिन नहीं, हफ़्तों पहले।',
  source: _digiLocker,
);

const _domicile = Advice(
  title: 'Residence (domicile) certificate',
  titleHi: 'निवास (डोमिसाइल) प्रमाण पत्र',
  body: 'State scholarships, state college seats and state jobs usually '
      'need proof that you belong to that state. The revenue office issues '
      'it, often on the same portal as the caste and income certificates — '
      'apply for them together and save a trip.',
  bodyHi: 'राज्य की छात्रवृत्ति, राज्य के कॉलेजों की सीटें और राज्य की नौकरियों में '
      'आमतौर पर उस राज्य का निवासी होने का प्रमाण चाहिए। राजस्व कार्यालय इसे जारी करता '
      'है, अक्सर उसी पोर्टल पर जहाँ जाति और आय प्रमाण पत्र बनते हैं — एक साथ आवेदन '
      'करें और एक चक्कर बचाएँ।',
  source: _digiLocker,
);

const _udid = Advice(
  title: 'Disability certificate and UDID card',
  titleHi: 'दिव्यांगता प्रमाण पत्र और यूडीआईडी कार्ड',
  body: 'Apply once on the Swavlamban (UDID) portal; a government medical '
      'board assesses the disability and the certificate and the UDID card '
      'are issued together, valid across India. The law recognises 21 kinds '
      'of disability. At 40% or more ("benchmark disability") you are '
      'entitled to reservation — 4% of government jobs and 5% of seats in '
      'government higher education institutions — and to most disability '
      'schemes, including free aids and appliances.',
  bodyHi: 'स्वावलंबन (यूडीआईडी) पोर्टल पर एक बार आवेदन करें; सरकारी मेडिकल बोर्ड '
      'दिव्यांगता का आकलन करता है और प्रमाण पत्र व यूडीआईडी कार्ड साथ में जारी होते हैं, '
      'पूरे भारत में मान्य। क़ानून 21 तरह की दिव्यांगता मानता है। 40% या ज़्यादा '
      '("बेंचमार्क दिव्यांगता") होने पर आरक्षण का अधिकार है — सरकारी नौकरियों में 4% '
      'और सरकारी उच्च शिक्षा संस्थानों में 5% सीटें — और ज़्यादातर दिव्यांगता योजनाएँ, '
      'मुफ़्त सहायक उपकरण भी।',
  source: 'https://www.swavlambancard.gov.in/',
);

const _notSureCategory = Advice(
  title: 'Not sure of your category? Ask before you apply',
  titleHi: 'अपनी श्रेणी पता नहीं? आवेदन से पहले पूछें',
  body: 'Whether a caste is SC, ST or OBC is decided by government lists, '
      'and the lists differ between states, and between a state and the '
      'centre. Ask at the tehsil office or a Common Service Centre which '
      'list your community is on before you fill any form — a wrong '
      'category can cancel an admission or a job later.',
  bodyHi: 'कोई जाति एससी, एसटी या ओबीसी है, यह सरकारी सूचियों से तय होता है, और '
      'सूचियाँ राज्य-राज्य में, और राज्य व केंद्र में अलग होती हैं। कोई भी फ़ॉर्म भरने से '
      'पहले तहसील कार्यालय या कॉमन सर्विस सेंटर पर पूछें कि आपका समुदाय किस सूची में है '
      '— ग़लत श्रेणी से बाद में दाख़िला या नौकरी रद्द हो सकती है।',
  source: 'https://www.ncbc.nic.in/',
);

/// The papers needed, most important first. Never empty: at worst it says
/// to find out the category first.
List<Advice> certificatesFor({
  required CertPurpose purpose,
  required SocialCategory category,
  required IncomeBand income,
  required bool hasDisability,
}) {
  final out = <Advice>[];

  if (hasDisability) out.add(_udid);

  // A disability benefit needs the disability papers and nothing else here.
  if (purpose == CertPurpose.disabilityBenefit) {
    if (!hasDisability) out.add(_udid);
    return out;
  }

  switch (category) {
    case SocialCategory.sc:
    case SocialCategory.st:
      out.add(_caste);
    case SocialCategory.obc:
      out.add(_obc);
    case SocialCategory.general:
      // EWS is reservation-only, and only below the income line. "Not
      // sure" about income still shows it, with its rules, so the reader
      // can check.
      if (purpose == CertPurpose.reservation &&
          income != IncomeBand.above8Lakh) {
        out.add(_ews);
      }
    case SocialCategory.notSure:
      out.add(_notSureCategory);
  }

  if (purpose == CertPurpose.scholarship || purpose == CertPurpose.welfare) {
    out.add(_income);
  }
  out.add(_domicile);
  return out;
}

// ---------------------------------------------------------------------------
// Who handles a discrimination complaint?

enum Wrong {
  casteViolence, // attacked, threatened, insulted for being SC/ST
  casteExclusion, // kept out of a temple, well, shop, school, for caste
  casteAtWork, // denied a reserved post, benefit or fair treatment
  disability, // refused access, admission, job or accommodation
  religion, // treated unfairly as a religious minority
  women, // treated unfairly as a woman
  publicServant, // abused by police or another official
}

const _police = Advice(
  title: 'Go to the police first — this is a crime',
  titleHi: 'पहले पुलिस के पास जाएँ — यह अपराध है',
  body: 'Violence, threats or insults against a Scheduled Caste or Tribe '
      'member because of who they are are offences under the SC/ST '
      '(Prevention of Atrocities) Act; keeping someone out of a temple, '
      'well, shop or school because of caste is an offence too. Ask the '
      'police station to register an FIR, and get a free copy. If they '
      'refuse, send the complaint in writing to the Superintendent of '
      'Police. Victims of atrocities are also entitled to relief money and '
      'protection under the Act. In danger right now: call 112.',
  bodyHi: 'अनुसूचित जाति या जनजाति के व्यक्ति के साथ उसकी पहचान के कारण हिंसा, '
      'धमकी या अपमान एससी/एसटी (अत्याचार निवारण) अधिनियम के तहत अपराध है; जाति के '
      'कारण मंदिर, कुएँ, दुकान या स्कूल से रोकना भी अपराध है। थाने में एफ़आईआर दर्ज '
      'करने को कहें और उसकी मुफ़्त कॉपी लें। मना करें तो शिकायत लिखकर पुलिस अधीक्षक '
      '(एसपी) को भेजें। अत्याचार पीड़ितों को इस क़ानून के तहत राहत राशि और सुरक्षा का भी '
      'अधिकार है। अभी ख़तरा हो: 112 पर कॉल करें।',
  source: 'https://ncsc.nic.in/',
  phone: '112',
);

const _ncsc = Advice(
  title: 'National Commission for Scheduled Castes',
  titleHi: 'राष्ट्रीय अनुसूचित जाति आयोग',
  body: 'Hears complaints that the rights of Scheduled Castes have been '
      'denied — including a police station that will not act, and denial '
      'of reservation or service benefits. Complaints can be sent online '
      'or by post; include dates, names, copies of what you sent before, '
      'and what you want done.',
  bodyHi: 'अनुसूचित जातियों के अधिकार छीने जाने की शिकायतें सुनता है — इसमें ऐसा थाना '
      'भी शामिल है जो कार्रवाई न करे, और आरक्षण या सेवा लाभ से इनकार। शिकायत ऑनलाइन '
      'या डाक से भेजी जा सकती है; तारीख़ें, नाम, पहले भेजी चीज़ों की कॉपी, और आप क्या '
      'चाहते हैं, ये सब लिखें।',
  source: 'https://ncsc.nic.in/',
);

const _ncst = Advice(
  title: 'National Commission for Scheduled Tribes',
  titleHi: 'राष्ट्रीय अनुसूचित जनजाति आयोग',
  body: 'The same role for Scheduled Tribes: complaints about rights '
      'denied, atrocities not acted on, and reservation or benefits refused.',
  bodyHi: 'अनुसूचित जनजातियों के लिए यही काम: अधिकार छीने जाने, अत्याचार पर कार्रवाई '
      'न होने, और आरक्षण या लाभ से इनकार की शिकायतें।',
  source: 'https://ncst.nic.in/',
);

const _ncbc = Advice(
  title: 'National Commission for Backward Classes',
  titleHi: 'राष्ट्रीय पिछड़ा वर्ग आयोग',
  body: 'For OBC candidates denied reservation or benefits they are entitled '
      'to, including disputes over non-creamy layer status.',
  bodyHi: 'उन ओबीसी उम्मीदवारों के लिए जिन्हें हक़ का आरक्षण या लाभ नहीं मिला, '
      'नॉन-क्रीमी लेयर के विवाद भी।',
  source: 'https://www.ncbc.nic.in/',
);

const _disability = Advice(
  title: 'Commissioner for Persons with Disabilities',
  titleHi: 'दिव्यांगजन आयुक्त',
  body: 'Each state has a State Commissioner for Persons with Disabilities '
      'who hears complaints about denial of rights — access to a building, '
      'admission, a job, a reasonable adjustment. For central government '
      'offices and bodies, complain to the Chief Commissioner. Discriminating '
      'against a person because of disability is prohibited under the '
      'Rights of Persons with Disabilities Act, 2016.',
  bodyHi: 'हर राज्य में राज्य दिव्यांगजन आयुक्त होते हैं जो अधिकारों से इनकार की '
      'शिकायतें सुनते हैं — इमारत में पहुँच, दाख़िला, नौकरी, उचित सुविधा। केंद्र सरकार '
      'के दफ़्तरों और संस्थाओं के लिए मुख्य आयुक्त से शिकायत करें। दिव्यांगता के कारण '
      'भेदभाव दिव्यांगजन अधिकार अधिनियम, 2016 के तहत मना है।',
  source: 'https://ccdisabilities.nic.in/',
);

const _ncm = Advice(
  title: 'National Commission for Minorities',
  titleHi: 'राष्ट्रीय अल्पसंख्यक आयोग',
  body: 'For Muslims, Christians, Sikhs, Buddhists, Parsis and Jains who '
      'are deprived of their rights. Many states have their own minorities '
      'commission too, which can be quicker for local matters.',
  bodyHi: 'मुस्लिम, ईसाई, सिख, बौद्ध, पारसी और जैन समुदायों के लोगों के लिए, जिनके '
      'अधिकार छीने गए हों। कई राज्यों का अपना अल्पसंख्यक आयोग भी है, जो स्थानीय मामलों '
      'में जल्दी हो सकता है।',
  source: 'https://ncm.nic.in/',
);

const _ncw = Advice(
  title: 'National Commission for Women — and 181',
  titleHi: 'राष्ट्रीय महिला आयोग — और 181',
  body: 'The Commission takes complaints online. For help right now — '
      'violence, harassment, being thrown out of home — the 181 women '
      'helpline is free and answers 24 hours. The Gender Equality section '
      'of this app has the full list and your legal rights.',
  bodyHi: 'आयोग ऑनलाइन शिकायत लेता है। अभी मदद चाहिए — हिंसा, उत्पीड़न, घर से निकाला '
      'जाना — तो 181 महिला हेल्पलाइन मुफ़्त है और 24 घंटे चलती है। इस ऐप के लैंगिक '
      'समानता हिस्से में पूरी सूची और आपके क़ानूनी अधिकार हैं।',
  source: 'https://ncw.nic.in/',
  phone: '181',
);

const _nhrc = Advice(
  title: 'Human Rights Commission',
  titleHi: 'मानवाधिकार आयोग',
  body: 'Abuse by a public servant — police beating, illegal detention, '
      'refusal to act — can be complained of to the State or National Human '
      'Rights Commission. Complaints can be filed online on the HRCNet '
      'portal, free, and in any language of the Eighth Schedule.',
  bodyHi: 'किसी सरकारी कर्मचारी द्वारा दुर्व्यवहार — पुलिस की मारपीट, ग़ैरक़ानूनी '
      'हिरासत, कार्रवाई से इनकार — की शिकायत राज्य या राष्ट्रीय मानवाधिकार आयोग में की '
      'जा सकती है। शिकायत एचआरसीनेट पोर्टल पर ऑनलाइन, मुफ़्त, और आठवीं अनुसूची की किसी '
      'भी भाषा में दर्ज हो सकती है।',
  source: 'https://hrcnet.nic.in/',
);

/// Where to take a complaint, first step first. Never empty.
List<Advice> complaintRoute(Wrong wrong, SocialCategory category) {
  switch (wrong) {
    case Wrong.casteViolence:
    case Wrong.casteExclusion:
      return [
        _police,
        if (category == SocialCategory.st) _ncst else _ncsc,
        _nhrc,
      ];
    case Wrong.casteAtWork:
      return [
        switch (category) {
          SocialCategory.st => _ncst,
          SocialCategory.obc => _ncbc,
          _ => _ncsc,
        },
      ];
    case Wrong.disability:
      return [_disability];
    case Wrong.religion:
      return [_ncm, _nhrc];
    case Wrong.women:
      return [_ncw];
    case Wrong.publicServant:
      return [_nhrc];
  }
}
