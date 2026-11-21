// GENERATED-ISSUE-FILE
// Every goal's issue list, joined.
//
// This is what the app-wide search reads, and what the home screen counts.
// Nothing else in the app may keep its own copy of the list: one place to
// add an issue, one place it can be wrong.
import 'issue.dart';
import '../../features/sdg1_schemes/issues.dart';
import '../../features/sdg2_food/issues.dart';
import '../../features/sdg3_health/issues.dart';
import '../../features/sdg4_scholarships/issues.dart';
import '../../features/sdg5_empower/issues.dart';
import '../../features/sdg6_water/issues.dart';
import '../../features/sdg7_energy/issues.dart';
import '../../features/sdg8_work/issues.dart';
import '../../features/sdg9_enterprise/issues.dart';
import '../../features/sdg10_equality/issues.dart';
import '../../features/sdg11_cities/issues.dart';
import '../../features/sdg12_consumption/issues.dart';
import '../../features/sdg13_climate/issues.dart';
import '../../features/sdg14_ocean/issues.dart';
import '../../features/sdg15_land/issues.dart';
import '../../features/sdg16_justice/issues.dart';
import '../../features/sdg17_partnerships/issues.dart';

/// Not const: a goal whose issues include a built screen holds a closure,
/// and a closure is never a compile-time constant.
final List<GoalIssues> kGoals = [
  sdg1Goal,
  sdg2Goal,
  sdg3Goal,
  sdg4Goal,
  sdg5Goal,
  sdg6Goal,
  sdg7Goal,
  sdg8Goal,
  sdg9Goal,
  sdg10Goal,
  sdg11Goal,
  sdg12Goal,
  sdg13Goal,
  sdg14Goal,
  sdg15Goal,
  sdg16Goal,
  sdg17Goal,
];

/// All 282 issues across the 17 goals, in goal order.
List<Issue> get kAllIssues => [for (final g in kGoals) ...g.issues];

GoalIssues goalIssues(int goal) =>
    kGoals.firstWhere((g) => g.goal == goal, orElse: () => kGoals.first);

Issue? issueById(String id) {
  for (final g in kGoals) {
    for (final i in g.issues) {
      if (i.id == id) return i;
    }
  }
  return null;
}

/// Issues whose words match [query], best first.
///
/// Matching is deliberately simple: every word typed must appear somewhere
/// in the issue's text. A fuzzy search that returns something for every
/// query would be worse than one that honestly returns nothing, because a
/// user who is shown a wrong tool follows it.
List<Issue> searchIssues(String query) {
  final words = query
      .toLowerCase()
      .split(RegExp(r'[\s,]+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return const [];
  final hits = <({Issue issue, int score})>[];
  for (final issue in kAllIssues) {
    final hay = issue.haystack;
    if (!words.every(hay.contains)) continue;
    var score = 0;
    final title = '${issue.titleEn} ${issue.titleHi}'.toLowerCase();
    for (final w in words) {
      if (title.contains(w)) score += 3;
      if (title.startsWith(w)) score += 2;
    }
    if (issue.isBuilt) score += 4;
    hits.add((issue: issue, score: score));
  }
  hits.sort((a, b) => b.score - a.score);
  return [for (final h in hits) h.issue];
}
