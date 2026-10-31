/// Describes every editable dataset in one place, so the admin content
/// editor is a single screen rather than one per module.
///
/// Adding a new editable dataset means adding an entry here. No new UI.
library;

enum FieldKind { text, multiline, url, flag, number }

class EditableField {
  final String key;
  final String label;
  final FieldKind kind;
  final String? help;

  const EditableField(this.key, this.label, this.kind, {this.help});
}

class ContentDataset {
  /// Firestore path is `/sdg/{goal}/{collection}/{recordId}`.
  final int goal;
  final String collection;

  final String label;
  final String assetPath;

  /// Which field to show as the row title in the list.
  final String titleField;

  /// Optional second line in the list.
  final String? subtitleField;

  /// The field holding an external link, if any. The editor offers to open
  /// it so a human can check it before marking the record verified.
  final String? linkField;

  final List<EditableField> fields;

  const ContentDataset({
    required this.goal,
    required this.collection,
    required this.label,
    required this.assetPath,
    required this.titleField,
    required this.fields,
    this.subtitleField,
    this.linkField,
  });

  String get id => 'sdg$goal-$collection';

  /// The fields a translator fills in for a language other than English.
  ///
  /// Derived rather than declared per dataset, so adding a dataset does not
  /// mean remembering to list its translatable fields and quietly getting a
  /// screen that cannot be translated.
  ///
  /// Excluded on purpose:
  ///   * `FieldKind.url`, `flag`, `number` - a link, a tick box and a rupee
  ///     figure are the same in every language.
  ///   * anything ending in `Hi` - those are the legacy Hindi columns, and
  ///     Hindi is edited through them, not through the `i18n` map.
  ///   * `number` and `phone` keys - a helpline that gets its digits
  ///     "translated" into another numeral system stops dialling. This is
  ///     the one case where a well-meaning translator can break a feature
  ///     that someone needs in an emergency.
  List<EditableField> get translatableFields => [
        for (final f in fields)
          if (!f.key.endsWith('Hi') &&
              f.key != 'number' &&
              f.key != 'phone' &&
              (f.kind == FieldKind.text || f.kind == FieldKind.multiline))
            f,
      ];
}

/// Every dataset an admin can correct from the app.
///
/// All of these ship bundled and unverified. The whole point of this registry
/// is that a wrong government link can be fixed from a phone in a minute,
/// rather than waiting for a new APK.
const List<ContentDataset> kDatasets = [
  ContentDataset(
    goal: 1,
    collection: 'schemes',
    label: 'SDG 1 — Government schemes',
    assetPath: 'assets/data/subsidies.json',
    titleField: 'name',
    subtitleField: 'category',
    linkField: 'officialLink',
    fields: [
      EditableField('name', 'Scheme name', FieldKind.text),
      EditableField('category', 'Category', FieldKind.text),
      EditableField('ministry', 'Ministry', FieldKind.text),
      EditableField('eligibility', 'Who can apply', FieldKind.multiline),
      EditableField('officialLink', 'Official link', FieldKind.url,
          help: 'Open it and check it loads the right page before verifying'),
      EditableField('verified', 'Link checked and correct', FieldKind.flag),
    ],
  ),
  ContentDataset(
    goal: 4,
    collection: 'scholarships',
    label: 'SDG 4 — Scholarships',
    assetPath: 'assets/data/scholarships.json',
    titleField: 'name',
    subtitleField: 'provider',
    linkField: 'portal',
    fields: [
      EditableField('name', 'Scholarship name', FieldKind.text),
      EditableField('provider', 'Provider', FieldKind.text),
      EditableField('incomeMax', 'Income limit in rupees, 0 for none',
          FieldKind.number),
      EditableField('portal', 'Application portal', FieldKind.url),
      EditableField('verified', 'Checked against the portal', FieldKind.flag),
    ],
  ),
  ContentDataset(
    goal: 2,
    collection: 'foodsafety',
    label: 'SDG 2 — Food safety rules',
    assetPath: 'assets/data/food_safety.json',
    titleField: 'title',
    subtitleField: 'category',
    linkField: 'source',
    fields: [
      EditableField('title', 'Heading in English', FieldKind.text),
      EditableField('titleHi', 'Heading in Hindi', FieldKind.text),
      EditableField('body', 'The rule, English', FieldKind.multiline),
      EditableField('bodyHi', 'The rule, Hindi', FieldKind.multiline),
      EditableField('source', 'Official source link', FieldKind.url),
      EditableField('verified', 'Checked against FSSAI guidance',
          FieldKind.flag),
    ],
  ),
  ContentDataset(
    goal: 2,
    collection: 'foodtips',
    label: 'SDG 2 — Waste less at home',
    assetPath: 'assets/data/food_waste_tips.json',
    titleField: 'title',
    fields: [
      EditableField('title', 'Heading in English', FieldKind.text),
      EditableField('titleHi', 'Heading in Hindi', FieldKind.text),
      EditableField('body', 'The tip, English', FieldKind.multiline),
      EditableField('bodyHi', 'The tip, Hindi', FieldKind.multiline),
      EditableField('verified', 'Checked', FieldKind.flag),
    ],
  ),
  ContentDataset(
    goal: 2,
    collection: 'foodpartners',
    label: 'SDG 2 — Collection organisations',
    assetPath: 'assets/data/food_partners.json',
    titleField: 'name',
    subtitleField: 'city',
    fields: [
      EditableField('name', 'Organisation name', FieldKind.text),
      EditableField('city', 'City', FieldKind.text),
      EditableField('area', 'Area or district they cover', FieldKind.text),
      EditableField('phone', 'Phone — digits only', FieldKind.text,
          help: 'Call it yourself before adding it here'),
      EditableField('verified', 'Called, answered, and collects surplus food',
          FieldKind.flag),
    ],
  ),
  ContentDataset(
    goal: 3,
    collection: 'myths',
    label: 'SDG 3 — Myth vs fact',
    assetPath: 'assets/data/health_myths.json',
    titleField: 'myth',
    subtitleField: 'category',
    linkField: 'source',
    fields: [
      EditableField('myth', 'The belief, in English', FieldKind.multiline),
      EditableField('mythHi', 'The belief, in Hindi', FieldKind.multiline),
      EditableField('fact', 'What is true, English', FieldKind.multiline),
      EditableField('factHi', 'What is true, Hindi', FieldKind.multiline),
      EditableField('why', 'Why it matters, English', FieldKind.multiline),
      EditableField('whyHi', 'Why it matters, Hindi', FieldKind.multiline),
      EditableField('source', 'Official source link', FieldKind.url),
      EditableField('verified', 'Checked by someone medically qualified',
          FieldKind.flag),
    ],
  ),
  ContentDataset(
    goal: 3,
    collection: 'healthlines',
    label: 'SDG 3 — Health helplines',
    assetPath: 'assets/data/health_helplines.json',
    titleField: 'name',
    subtitleField: 'number',
    fields: [
      EditableField('number', 'Number — digits only', FieldKind.text,
          help: 'Anything other than digits will not dial'),
      EditableField('name', 'Name in English', FieldKind.text),
      EditableField('nameHi', 'Name in Hindi', FieldKind.text),
      EditableField('detail', 'What it is for, English', FieldKind.multiline),
      EditableField('detailHi', 'What it is for, Hindi', FieldKind.multiline),
      EditableField('verified', 'Number tested and answers', FieldKind.flag),
    ],
  ),
  ContentDataset(
    goal: 5,
    collection: 'helplines',
    label: 'SDG 5 — Helpline numbers',
    assetPath: 'assets/data/helplines.json',
    titleField: 'name',
    subtitleField: 'number',
    fields: [
      EditableField('number', 'Number — digits only', FieldKind.text,
          help: 'Anything other than digits will not dial'),
      EditableField('name', 'Name in English', FieldKind.text),
      EditableField('nameHi', 'Name in Hindi', FieldKind.text),
      EditableField('detail', 'What it is for, English', FieldKind.multiline),
      EditableField('detailHi', 'What it is for, Hindi', FieldKind.multiline),
      EditableField('verified', 'Number tested and answers', FieldKind.flag),
    ],
  ),
  ContentDataset(
    goal: 8,
    collection: 'workrights',
    label: 'SDG 8 — Work rights',
    assetPath: 'assets/data/work_rights.json',
    titleField: 'title',
    subtitleField: 'category',
    linkField: 'source',
    fields: [
      EditableField('title', 'Heading in English', FieldKind.text),
      EditableField('titleHi', 'Heading in Hindi', FieldKind.text),
      EditableField('body', 'Explanation, English', FieldKind.multiline),
      EditableField('bodyHi', 'Explanation, Hindi', FieldKind.multiline),
      EditableField('source', 'Official portal link', FieldKind.url),
      EditableField('verified', 'Checked against the official scheme',
          FieldKind.flag),
    ],
  ),
  ContentDataset(
    goal: 6,
    collection: 'waterguides',
    label: 'SDG 6 — Clean water',
    assetPath: 'assets/data/water_guides.json',
    titleField: 'title',
    subtitleField: 'category',
    linkField: 'source',
    fields: [
      EditableField('title', 'Heading in English', FieldKind.text),
      EditableField('titleHi', 'Heading in Hindi', FieldKind.text),
      EditableField('body', 'Explanation, English', FieldKind.multiline),
      EditableField('bodyHi', 'Explanation, Hindi', FieldKind.multiline),
      EditableField('source', 'Official source link', FieldKind.url),
      EditableField('verified', 'Checked by a water quality officer',
          FieldKind.flag,
          help: 'Boiling times and the arsenic/fluoride claims especially'),
    ],
  ),
  ContentDataset(
    goal: 7,
    collection: 'energyguides',
    label: 'SDG 7 — Energy, bills and subsidies',
    assetPath: 'assets/data/energy_guides.json',
    titleField: 'title',
    subtitleField: 'category',
    linkField: 'source',
    fields: [
      EditableField('title', 'Heading in English', FieldKind.text),
      EditableField('titleHi', 'Heading in Hindi', FieldKind.text),
      EditableField('body', 'Explanation, English', FieldKind.multiline),
      EditableField('bodyHi', 'Explanation, Hindi', FieldKind.multiline),
      EditableField('source', 'Official source link', FieldKind.url),
      EditableField('verified', 'Checked against the current scheme',
          FieldKind.flag,
          help: 'Subsidy amounts and refill counts change - re-check these '
              'against the portal before ticking'),
    ],
  ),
  ContentDataset(
    goal: 9,
    collection: 'enterpriseguides',
    label: 'SDG 9 — Enterprise, loans and registration',
    assetPath: 'assets/data/enterprise_guides.json',
    titleField: 'title',
    subtitleField: 'category',
    linkField: 'source',
    fields: [
      EditableField('title', 'Heading in English', FieldKind.text),
      EditableField('titleHi', 'Heading in Hindi', FieldKind.text),
      EditableField('body', 'Explanation, English', FieldKind.multiline),
      EditableField('bodyHi', 'Explanation, Hindi', FieldKind.multiline),
      EditableField('source', 'Official source link', FieldKind.url),
      EditableField('verified', 'Checked against the current scheme',
          FieldKind.flag,
          help: 'Subsidy rates and project cost ceilings are revised - '
              're-check on the portal before ticking'),
    ],
  ),
  ContentDataset(
    goal: 16,
    collection: 'civicrights',
    label: 'SDG 16 — Justice and rights',
    assetPath: 'assets/data/civic_rights.json',
    titleField: 'title',
    subtitleField: 'category',
    linkField: 'source',
    fields: [
      EditableField('title', 'Heading in English', FieldKind.text),
      EditableField('titleHi', 'Heading in Hindi', FieldKind.text),
      EditableField('body', 'Explanation, English', FieldKind.multiline),
      EditableField('bodyHi', 'Explanation, Hindi', FieldKind.multiline),
      EditableField('source', 'Official portal link', FieldKind.url),
      EditableField('verified', 'Checked by someone qualified',
          FieldKind.flag),
    ],
  ),
  ContentDataset(
    goal: 5,
    collection: 'rights',
    label: 'SDG 5 — Legal rights',
    assetPath: 'assets/data/legal_rights.json',
    titleField: 'title',
    subtitleField: 'law',
    linkField: 'source',
    fields: [
      EditableField('title', 'Heading in English', FieldKind.text),
      EditableField('titleHi', 'Heading in Hindi', FieldKind.text),
      EditableField('law', 'Which law', FieldKind.text),
      EditableField('summary', 'Plain English', FieldKind.multiline),
      EditableField('summaryHi', 'Plain Hindi', FieldKind.multiline),
      EditableField('source', 'Official source link', FieldKind.url),
      EditableField('verified', 'Checked by someone qualified',
          FieldKind.flag),
    ],
  ),
];
