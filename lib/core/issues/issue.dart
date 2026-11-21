import 'package:flutter/material.dart';

/// One problem the app sets out to solve, in one goal.
///
/// The app is organised around problems people actually have — "the ration
/// shop gave me less than my due", "my crop was hailed on last night" —
/// rather than around schemes or departments. Each one is an entry here, so
/// the goal's menu, the goal's home screen and the search box on the app's
/// home all read from the same list and cannot drift apart.
///
/// [open] is null while an issue is planned but not built. Those still
/// appear, greyed, with what they will do: showing the whole map is honest,
/// and a user who taps one learns that the answer is coming rather than
/// that the app does not care.
class Issue {
  final String id; // 'g1i04', stable - saved bookmarks refer to it
  final int goal;
  final String group; // group key within the goal
  final String titleEn;
  final String titleHi;
  final String blurbEn;
  final String blurbHi;
  final IconData icon;

  /// Extra words someone might search for, in any language. The title is
  /// searched too, so this holds only what the title misses.
  final List<String> keywords;

  final WidgetBuilder? open;

  const Issue({
    required this.id,
    required this.goal,
    required this.group,
    required this.titleEn,
    required this.titleHi,
    required this.blurbEn,
    required this.blurbHi,
    required this.icon,
    this.keywords = const [],
    this.open,
  });

  bool get isBuilt => open != null;

  /// These take a language code, not a bool, like every other localised
  /// accessor in the app. Only English and Hindi are written here; any
  /// other language falls back to English until it is translated.
  String title(String lang) => lang == 'hi' ? titleHi : titleEn;
  String blurb(String lang) => lang == 'hi' ? blurbHi : blurbEn;

  /// Everything this issue can be found by, lower-cased once.
  String get haystack =>
      '$titleEn $titleHi $blurbEn $blurbHi ${keywords.join(' ')}'
          .toLowerCase();
}

/// A named group of issues inside one goal, used for the goal's menu.
class IssueGroup {
  final String key;
  final String en;
  final String hi;
  const IssueGroup(this.key, this.en, this.hi);

  String label(String lang) => lang == 'hi' ? hi : en;
}

/// Everything one goal needs to draw its own mini-app.
class GoalIssues {
  final int goal;
  final List<IssueGroup> groups;
  final List<Issue> issues;

  /// Tap-to-call numbers that matter for this goal. Digits only.
  final List<GoalHelpline> helplines;

  const GoalIssues({
    required this.goal,
    required this.groups,
    required this.issues,
    this.helplines = const [],
  });

  List<Issue> inGroup(String key) =>
      issues.where((i) => i.group == key).toList();

  int get builtCount => issues.where((i) => i.isBuilt).length;
}

class GoalHelpline {
  final String number;
  final String en;
  final String hi;
  const GoalHelpline(this.number, this.en, this.hi);

  String label(String lang) => lang == 'hi' ? hi : en;
}
