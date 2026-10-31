class Subsidy {
  final int id;
  final String name;
  final String category;
  final String eligibility;
  final String ministry;
  final String officialLink;

  /// False until a human has opened the link and confirmed it still works.
  /// Shown to the user as a caution, because a dead or wrong government link
  /// is worse than no link at all for someone who needs the benefit.
  final bool verified;

  const Subsidy({
    required this.id,
    required this.name,
    required this.category,
    required this.eligibility,
    required this.ministry,
    required this.officialLink,
    required this.verified,
  });

  factory Subsidy.fromJson(Map<String, dynamic> j) => Subsidy(
        id: j['id'] is int ? j['id'] as int : 0,
        name: (j['name'] ?? '').toString(),
        category: (j['category'] ?? 'Other').toString(),
        eligibility: (j['eligibility'] ?? '').toString(),
        ministry: (j['ministry'] ?? '').toString(),
        officialLink: (j['officialLink'] ?? '').toString(),
        verified: j['verified'] == true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'eligibility': eligibility,
        'ministry': ministry,
        'officialLink': officialLink,
        'verified': verified,
      };

  bool matches(String q) {
    if (q.isEmpty) return true;
    final s = q.toLowerCase();
    return name.toLowerCase().contains(s) ||
        category.toLowerCase().contains(s) ||
        eligibility.toLowerCase().contains(s) ||
        ministry.toLowerCase().contains(s);
  }
}
