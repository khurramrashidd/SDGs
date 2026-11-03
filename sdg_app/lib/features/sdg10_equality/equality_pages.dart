import 'package:flutter/material.dart';

import '../../core/widgets/guide_list_page.dart';
import '../../core/widgets/module_hub.dart';
import '../../core/widgets/selection_tile.dart';
import 'equality_tools.dart';

/// SDG 10 — Reduced Inequalities.
class EqualityHomePage extends StatelessWidget {
  const EqualityHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    return ModuleHub(
      goal: 10,
      titleKey: 'sdg10_title',
      children: [
        HubHero(
          goal: 10,
          title: hi
              ? 'किस काम के लिए कौन सा प्रमाण पत्र?'
              : 'Which certificate do you need?',
          body: hi
              ? 'छात्रवृत्ति, आरक्षण या पेंशन अक्सर एक ग़लत या पुराने काग़ज़ पर अटक जाती है। '
                  'चार सवालों के जवाब दें — हम बताएँगे कौन से प्रमाण पत्र चाहिए और कहाँ बनते हैं।'
              : 'Scholarships, reservation and pensions are often lost to one '
                  'wrong or out-of-date paper. Answer four questions and see '
                  'which certificates you need and where to get them.',
          button: hi ? 'प्रमाण पत्र खोजें' : 'Find my certificates',
          icon: Icons.badge_outlined,
          onTap: () => pushScoped(context, const CertificateFinderPage()),
        ),
        HubLabel(hi ? 'भेदभाव' : 'Discrimination'),
        HubRow(
          icon: Icons.report_outlined,
          title: hi ? 'शिकायत कहाँ करें' : 'Where to complain',
          subtitle: hi
              ? 'जाति, दिव्यांगता, धर्म, महिला, पुलिस — सही आयोग'
              : 'Caste, disability, religion, women, police — the right body',
          onTap: () => pushScoped(context, const ComplaintRouterPage()),
        ),
        HubLabel(hi ? 'जानें' : 'Know more'),
        HubRow(
          icon: Icons.accessible_outlined,
          title: hi ? 'दिव्यांगजनों के अधिकार' : 'Rights of persons with disabilities',
          subtitle: hi
              ? 'सुगम्यता, मुफ़्त उपकरण, यात्रा, शिक्षा'
              : 'Access, free aids, travel, education',
          onTap: () => pushScoped(
            context,
            const GuideListPage(
              collection: 'equality',
              category: 'disability',
              title: 'Disability rights',
              titleHi: 'दिव्यांगजन अधिकार',
              goal: 10,
            ),
          ),
        ),
        HubRow(
          icon: Icons.balance_outlined,
          title: hi ? 'आरक्षण, आसान भाषा में' : 'Reservation, in plain words',
          subtitle: hi
              ? 'किसे, कितना, और आम ग़लतियाँ'
              : 'Who gets it, how much, and the common mistakes',
          onTap: () => pushScoped(
            context,
            const GuideListPage(
              collection: 'equality',
              category: 'reservation',
              title: 'Reservation',
              titleHi: 'आरक्षण',
              goal: 10,
            ),
          ),
        ),
      ],
    );
  }
}

class CertificateFinderPage extends StatefulWidget {
  const CertificateFinderPage({super.key});

  @override
  State<CertificateFinderPage> createState() => _CertificateFinderPageState();
}

class _CertificateFinderPageState extends State<CertificateFinderPage> {
  CertPurpose? _purpose;
  SocialCategory? _category;
  IncomeBand? _income;
  bool? _disability;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final needIncome = _category == SocialCategory.general &&
        _purpose == CertPurpose.reservation;
    final done = _purpose != null &&
        _category != null &&
        _disability != null &&
        (!needIncome || _income != null);

    Widget pick<T>(T value, T? current, String en, String hiText,
            void Function(T) assign) =>
        SelectionTile(
          label: hi ? hiText : en,
          selected: current == value,
          onTap: () => setState(() => assign(value)),
        );

    return ToolScaffold(
      goal: 10,
      title: hi ? 'कौन सा प्रमाण पत्र?' : 'Which certificate?',
      children: [
        ToolQuestion(hi ? 'किस काम के लिए चाहिए?' : 'What do you need it for?'),
        pick(CertPurpose.scholarship, _purpose, 'A scholarship',
            'छात्रवृत्ति', (v) => _purpose = v),
        pick(CertPurpose.reservation, _purpose,
            'A reserved seat or government job', 'आरक्षित सीट या सरकारी नौकरी',
            (v) => _purpose = v),
        pick(CertPurpose.welfare, _purpose, 'A pension or welfare scheme',
            'पेंशन या कल्याण योजना', (v) => _purpose = v),
        pick(CertPurpose.disabilityBenefit, _purpose,
            'A disability benefit or free aid', 'दिव्यांगता लाभ या मुफ़्त उपकरण',
            (v) => _purpose = v),
        ToolQuestion(hi ? 'आपकी श्रेणी' : 'Your category'),
        pick(SocialCategory.sc, _category, 'Scheduled Caste (SC)',
            'अनुसूचित जाति (एससी)', (v) => _category = v),
        pick(SocialCategory.st, _category, 'Scheduled Tribe (ST)',
            'अनुसूचित जनजाति (एसटी)', (v) => _category = v),
        pick(SocialCategory.obc, _category, 'Other Backward Class (OBC)',
            'अन्य पिछड़ा वर्ग (ओबीसी)', (v) => _category = v),
        pick(SocialCategory.general, _category, 'None of these',
            'इनमें से कोई नहीं', (v) => _category = v),
        pick(SocialCategory.notSure, _category, 'Not sure', 'पता नहीं',
            (v) => _category = v),
        if (needIncome) ...[
          ToolQuestion(hi
              ? 'परिवार की सालाना आय, सभी स्रोतों से'
              : "Family's yearly income, from all sources"),
          pick(IncomeBand.below8Lakh, _income, 'Below Rs 8 lakh',
              '8 लाख रुपये से कम', (v) => _income = v),
          pick(IncomeBand.above8Lakh, _income, 'Rs 8 lakh or more',
              '8 लाख रुपये या ज़्यादा', (v) => _income = v),
          pick(IncomeBand.notSure, _income, 'Not sure', 'पता नहीं',
              (v) => _income = v),
        ],
        ToolQuestion(hi
            ? 'क्या आपको कोई दिव्यांगता है?'
            : 'Do you have a disability?'),
        pick(true, _disability, 'Yes', 'हाँ', (v) => _disability = v),
        pick(false, _disability, 'No', 'नहीं', (v) => _disability = v),
        if (done)
          AdviceList(
            heading: hi ? 'आपको ये चाहिए' : 'What you need',
            items: certificatesFor(
              purpose: _purpose!,
              category: _category!,
              income: _income ?? IncomeBand.notSure,
              hasDisability: _disability!,
            ),
          ),
      ],
    );
  }
}

class ComplaintRouterPage extends StatefulWidget {
  const ComplaintRouterPage({super.key});

  @override
  State<ComplaintRouterPage> createState() => _ComplaintRouterPageState();
}

class _ComplaintRouterPageState extends State<ComplaintRouterPage> {
  Wrong? _wrong;
  SocialCategory _category = SocialCategory.sc;

  @override
  Widget build(BuildContext context) {
    final hi = Localizations.localeOf(context).languageCode == 'hi';
    final casteCase = _wrong == Wrong.casteViolence ||
        _wrong == Wrong.casteExclusion ||
        _wrong == Wrong.casteAtWork;

    Widget wrong(Wrong w, String en, String hiText) => SelectionTile(
          label: hi ? hiText : en,
          selected: _wrong == w,
          onTap: () => setState(() => _wrong = w),
        );
    Widget cat(SocialCategory c, String en, String hiText) => SelectionTile(
          label: hi ? hiText : en,
          selected: _category == c,
          onTap: () => setState(() => _category = c),
        );

    return ToolScaffold(
      goal: 10,
      title: hi ? 'शिकायत कहाँ करें' : 'Where to complain',
      children: [
        ToolQuestion(hi ? 'क्या हुआ?' : 'What happened?'),
        wrong(Wrong.casteViolence, 'Attacked, threatened or insulted because of caste',
            'जाति के कारण हमला, धमकी या अपमान'),
        wrong(Wrong.casteExclusion,
            'Kept out of a temple, well, shop or school because of caste',
            'जाति के कारण मंदिर, कुएँ, दुकान या स्कूल से रोका गया'),
        wrong(Wrong.casteAtWork,
            'Denied a reserved seat, post or benefit',
            'आरक्षित सीट, पद या लाभ नहीं दिया गया'),
        wrong(Wrong.disability, 'Treated unfairly because of a disability',
            'दिव्यांगता के कारण भेदभाव'),
        wrong(Wrong.religion, 'Treated unfairly for my religion',
            'धर्म के कारण भेदभाव'),
        wrong(Wrong.women, 'Treated unfairly as a woman',
            'महिला होने के कारण भेदभाव'),
        wrong(Wrong.publicServant, 'Abused by police or an official',
            'पुलिस या किसी अधिकारी ने दुर्व्यवहार किया'),
        if (casteCase) ...[
          ToolQuestion(hi ? 'आपकी श्रेणी' : 'Your category'),
          cat(SocialCategory.sc, 'Scheduled Caste', 'अनुसूचित जाति'),
          cat(SocialCategory.st, 'Scheduled Tribe', 'अनुसूचित जनजाति'),
          if (_wrong == Wrong.casteAtWork)
            cat(SocialCategory.obc, 'OBC', 'ओबीसी'),
        ],
        if (_wrong != null)
          AdviceList(
            heading: hi ? 'यहाँ जाएँ, इसी क्रम में' : 'Go here, in this order',
            items: complaintRoute(_wrong!, _category),
          ),
      ],
    );
  }
}
