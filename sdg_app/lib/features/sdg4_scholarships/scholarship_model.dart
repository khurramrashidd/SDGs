/// How well a scholarship fits the student's profile.
///
/// Deliberately three states, not two. Nothing is ever hidden outright: the
/// point of this module is that students miss scholarships they qualified
/// for, so the app must never be the reason someone does not apply.
enum MatchLevel {
  /// Every hard criterion matches.
  strong,

  /// Hard criteria match but something soft is off - usually income is over
  /// our recorded cap. Caps change and exceptions exist, so this is shown
  /// with a "check the criteria" note, never removed.
  check,

  /// A hard criterion does not match (wrong class level, wrong category).
  /// Only visible when the student turns on "show everything".
  unlikely,
}

class Scholarship {
  final int id;
  final String name;
  final String provider;
  final List<String> levels;
  final int minClass;
  final int maxClass;
  final List<String> categories;
  final String gender; // 'any' | 'female'
  final bool disability; // true = disability-specific scheme
  final int incomeMax; // 0 means no income criterion recorded
  final List<String> states; // ['any'] or specific state names
  final String portal;
  final List<String> documents;
  final bool verified;

  /// Null until an admin enters the real date. The app shows "check the
  /// portal" rather than a guess, because a wrong deadline makes a student
  /// relax and miss the real one.
  final DateTime? deadline;

  const Scholarship({
    required this.id,
    required this.name,
    required this.provider,
    required this.levels,
    required this.minClass,
    required this.maxClass,
    required this.categories,
    required this.gender,
    required this.disability,
    required this.incomeMax,
    required this.states,
    required this.portal,
    required this.documents,
    required this.verified,
    this.deadline,
  });

  factory Scholarship.fromJson(Map<String, dynamic> j) => Scholarship(
        id: j['id'] is int ? j['id'] as int : 0,
        name: (j['name'] ?? '').toString(),
        provider: (j['provider'] ?? '').toString(),
        levels: _strList(j['levels']),
        minClass: _int(j['minClass'], 0),
        maxClass: _int(j['maxClass'], 99),
        categories: _strList(j['categories']),
        gender: (j['gender'] ?? 'any').toString(),
        disability: j['disability'] == true,
        incomeMax: _int(j['incomeMax'], 0),
        states: _strList(j['states']),
        portal: (j['portal'] ?? '').toString(),
        documents: _strList(j['documents']),
        verified: j['verified'] == true,
        deadline: j['deadline'] == null
            ? null
            : DateTime.tryParse(j['deadline'].toString()),
      );

  static List<String> _strList(dynamic v) =>
      v is List ? v.map((e) => e.toString()).toList() : const [];

  static int _int(dynamic v, int fallback) =>
      v is int ? v : int.tryParse('$v') ?? fallback;

  Scholarship copyWithDeadline(DateTime? d) => Scholarship(
        id: id,
        name: name,
        provider: provider,
        levels: levels,
        minClass: minClass,
        maxClass: maxClass,
        categories: categories,
        gender: gender,
        disability: disability,
        incomeMax: incomeMax,
        states: states,
        portal: portal,
        documents: documents,
        verified: verified,
        deadline: d,
      );

  /// Days until the deadline. Null when no deadline is known.
  int? get daysLeft {
    if (deadline == null) return null;
    final now = DateTime.now();
    final d = DateTime(deadline!.year, deadline!.month, deadline!.day);
    final t = DateTime(now.year, now.month, now.day);
    return d.difference(t).inDays;
  }

  bool get isClosed => (daysLeft ?? 1) < 0;
  bool get isUrgent {
    final d = daysLeft;
    return d != null && d >= 0 && d <= 14;
  }
}
