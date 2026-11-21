"""Emit one Dart issue file per goal, plus the registry that joins them."""
import importlib.util
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, '..')


def load(name):
    spec = importlib.util.spec_from_file_location(name, os.path.join(HERE, name + '.py'))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.GOALS


GOALS = {}
for part in ('issues_a', 'issues_b', 'issues_c'):
    GOALS.update(load(part))

assert sorted(GOALS) == list(range(1, 18)), sorted(GOALS)


def dart_str(s):
    """A Dart single-quoted string literal."""
    return "'" + s.replace('\\', r'\\').replace("'", r"\'").replace('\n', r'\n') + "'"


def break_points(expr):
    """Offsets of spaces in `expr` that sit outside any string literal.

    A Dart expression may only be broken at whitespace that is not inside a
    quoted string: breaking inside one leaves an unterminated literal, which
    is a syntax error, not a style problem. This returns the places that are
    safe, so the wrapper below can never invent one.
    """
    out = []
    quote = None
    i = 0
    while i < len(expr):
        c = expr[i]
        if quote:
            if c == '\\':
                i += 2
                continue
            if c == quote:
                quote = None
        elif c in '\'"':
            quote = c
        elif c == ' ':
            out.append(i)
        i += 1
    return out


def wrap_expr(first_line, expr, pad):
    """Lay `expr` out over several lines, breaking only outside strings.

    If there is no safe break point short enough, the expression goes out on
    one long line. An over-long line in a generated file is a style nit; a
    line broken in the wrong place does not compile.
    """
    lines = [first_line]
    body = expr
    while len(pad + body) > 78:
        safe = [p for p in break_points(body) if len(pad) + p <= 78]
        if not safe:
            break
        cut = safe[-1]
        lines.append(pad + body[:cut])
        body = body[cut + 1:]
    lines.append(pad + body + ',')
    return lines


def wrap(prefix, literal, indent):
    """Keep lines under 80 columns by splitting a long literal in two."""
    line = prefix + literal + ','
    if len(line) + indent <= 79:
        return [' ' * indent + line]
    # split the literal at a space near the middle of what fits
    body = literal[1:-1]
    budget = 76 - indent - len(prefix)
    cut = body.rfind(' ', 0, max(budget, 20))
    if cut <= 0:
        return [' ' * indent + line]
    first = "'" + body[:cut] + " '"
    rest = "'" + body[cut + 1:] + "'"
    out = [' ' * indent + prefix + first]
    pad = ' ' * (indent + 4)
    while len(pad + rest) > 78:
        inner = rest[1:-1]
        cut2 = inner.rfind(' ', 0, 74 - len(pad))
        if cut2 <= 0:
            break
        out.append(pad + "'" + inner[:cut2] + " '")
        rest = "'" + inner[cut2 + 1:] + "'"
    out.append(pad + rest + ',')
    return out


HEADER = """// GENERATED-ISSUE-FILE
// The problems SDG {goal} sets out to solve.
//
// Edited by hand when a tool is built: set `open` to the screen it opens.
// Everything the goal's mini-app shows - its menu, its home screen, its
// place in the app-wide search - is read from this one list.
import 'package:flutter/material.dart';

import '../../core/issues/issue.dart';
{imports}
const _groups = [
{groups}];

final List<Issue> {var}Issues = [
{issues}];

final GoalIssues sdg{goal}Goal = GoalIssues(
  goal: {goal},
  groups: _groups,
  issues: {var}Issues,
  helplines: const [
{helplines}  ],
);
"""


def emit_goal(goal, spec):
    imports = ''.join(i + '\n' for i in spec['imports'])
    groups = ''.join(
        "  IssueGroup(%s, %s, %s),\n" % (dart_str(k), dart_str(e), dart_str(h))
        for k, e, h in spec['groups'])
    helplines = ''.join(
        "    GoalHelpline(%s, %s, %s),\n" % (dart_str(n), dart_str(e), dart_str(h))
        for n, e, h in spec['helplines'])

    seen = set()
    rows = []
    for n, item in enumerate(spec['issues'], start=1):
        group, en, hi, ben, bhi, icon, keys, open_expr = item
        assert group in {g[0] for g in spec['groups']}, (goal, group)
        issue_id = 'g%di%02d' % (goal, n)
        assert issue_id not in seen
        seen.add(issue_id)
        # An issue with no screen yet holds nothing but literals, so it can
        # be a compile-time constant. Inside a const invocation the nested
        # list literals are already const, so the inner `const` comes off.
        is_const = not open_expr
        lines = ['  const Issue(' if is_const else '  Issue(']
        lines.append("    id: %s," % dart_str(issue_id))
        lines.append("    goal: %d," % goal)
        lines.append("    group: %s," % dart_str(group))
        lines += wrap('titleEn: ', dart_str(en), 4)
        lines += wrap('titleHi: ', dart_str(hi), 4)
        lines += wrap('blurbEn: ', dart_str(ben), 4)
        lines += wrap('blurbHi: ', dart_str(bhi), 4)
        lines.append("    icon: Icons.%s," % icon)
        if keys:
            kw = 'keywords: ' if is_const else 'keywords: const '
            joined = ', '.join(dart_str(k) for k in keys)
            if len(joined) + len(kw) + 6 <= 78:
                lines.append("    %s[%s]," % (kw, joined))
            else:
                lines.append("    %s[" % kw)
                for k in keys:
                    lines.append("      %s," % dart_str(k))
                lines.append("    ],")
        if open_expr:
            call = "    open: (_) => %s," % open_expr
            if len(call) <= 79:
                lines.append(call)
            else:
                lines += wrap_expr('    open: (_) =>', open_expr, '        ')
        lines.append('  ),')
        rows.append('\n'.join(lines) + '\n')

    text = HEADER.format(
        goal=goal, imports=imports, groups=groups,
        helplines=helplines, issues=''.join(rows),
        var='sdg%d' % goal)
    path = os.path.join(ROOT, 'lib/features', spec['dir'], 'issues.dart')
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)
    return len(spec['issues']), sum(1 for i in spec['issues'] if i[7])


total = built = 0
lines_import = []
lines_list = []
for goal in range(1, 18):
    spec = GOALS[goal]
    n, b = emit_goal(goal, spec)
    total += n
    built += b
    lines_import.append("import '../../features/%s/issues.dart';" % spec['dir'])
    lines_list.append('  sdg%dGoal,' % goal)

registry = """// GENERATED-ISSUE-FILE
// Every goal's issue list, joined.
//
// This is what the app-wide search reads, and what the home screen counts.
// Nothing else in the app may keep its own copy of the list: one place to
// add an issue, one place it can be wrong.
import 'issue.dart';
%s

/// Not const: a goal whose issues include a built screen holds a closure,
/// and a closure is never a compile-time constant.
final List<GoalIssues> kGoals = [
%s];

/// All %d issues across the 17 goals, in goal order.
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
      .split(RegExp(r'[\\s,]+'))
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
""" % ('\n'.join(lines_import), '\n'.join(lines_list) + '\n', total)

with open(os.path.join(ROOT, 'lib/core/issues/registry.dart'), 'w',
          encoding='utf-8') as f:
    f.write(registry)

print('issues: %d total, %d built, %d coming' % (total, built, total - built))
for goal in range(1, 18):
    print('  goal %2d: %2d issues' % (goal, len(GOALS[goal]['issues'])))
