#!/usr/bin/env python3
"""
Pre-ship validation for the SDG app.

Run this before packaging anything. It does not replace `flutter analyze` -
it catches the classes of mistake that have actually bitten this project,
fast, without needing the Flutter SDK:

  1. Unbalanced delimiters, ignoring strings and comments.
  2. Broken or unused relative imports.
  3. `const` constructors containing runtime expressions.
  4. Widgets used where a String is expected (the send_notice bug).
  5. Malformed JSON assets.
  6. API keys committed by accident.
  7. Stale dependency pins that were already fixed once.

Usage:  python tools/validate.py
Exit code is non-zero if anything fails.
"""
from __future__ import annotations

import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)

failures: list[str] = []
notes: list[str] = []


def fail(msg: str) -> None:
    failures.append(msg)


def strip_noise(src: str) -> str:
    """Blank out strings and comments so delimiter counting reflects code."""
    out: list[str] = []
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        if c == '/' and i + 1 < n and src[i + 1] == '/':
            while i < n and src[i] != '\n':
                i += 1
        elif c == '/' and i + 1 < n and src[i + 1] == '*':
            i += 2
            while i + 1 < n and not (src[i] == '*' and src[i + 1] == '/'):
                i += 1
            i += 2
        elif c in '"\'':
            triple = src[i:i + 3] in ('"""', "'''")
            q = src[i:i + 3] if triple else c
            i += len(q)
            while i < n:
                if src[i] == '\\':
                    i += 2
                    continue
                if src[i:i + len(q)] == q:
                    i += len(q)
                    break
                i += 1
        else:
            out.append(c)
            i += 1
    return ''.join(out)


DART = sorted(glob.glob('lib/**/*.dart', recursive=True))
ASSETS = sorted(glob.glob('assets/data/*.json'))


# -- 1. delimiters and statement structure -----------------------------------
def check_delimiters() -> None:
    """Balance, nesting, AND statement termination.

    Balance alone is not enough. This shipped once and compiled nowhere:

        return Scaffold(
          body: ContentShell(
            child: ListView( ... ),
          ),          <- closes ListView
        );            <- closes ContentShell, then ends the statement
          ),          <- closes Scaffold, after the semicolon
        }

    Every bracket matches its partner, and the counts are equal, so a stack
    check passes happily. It is still a syntax error, because the `;` arrives
    while `Scaffold(` is still open.

    So we also track, for each `{` block, the paren depth at which statements
    in that block must terminate. A `;` found at a deeper paren depth means an
    expression was left open. The exception is `for (;;)`, whose semicolons
    legitimately sit inside parentheses.
    """
    pairs = {')': '(', '}': '{', ']': '['}
    for f in DART:
        clean = strip_noise(open(f, encoding='utf-8').read())
        line_of = lambda i: clean[:i].count('\n') + 1

        stack: list[tuple[str, int]] = []   # (char, index)
        # paren depth each open `{` expects its statements to end at
        block_base: list[int] = [0]
        paren_depth = 0
        for_parens: set[int] = set()        # depths belonging to a `for (`
        broke = False

        for idx, ch in enumerate(clean):
            if ch in '([{':
                if ch == '(':
                    # is this the paren of a for-loop header?
                    before = clean[max(0, idx - 6):idx]
                    paren_depth += 1
                    if re.search(r'\bfor\s*$', before):
                        for_parens.add(paren_depth)
                elif ch == '{':
                    block_base.append(paren_depth)
                stack.append((ch, idx))

            elif ch in ')]}':
                if not stack or stack[-1][0] != pairs[ch]:
                    fail(f'{f}:{line_of(idx)}: unexpected {ch!r}')
                    broke = True
                    break
                opener = stack.pop()[0]
                if opener == '(':
                    for_parens.discard(paren_depth)
                    paren_depth -= 1
                elif opener == '{':
                    block_base.pop()

            elif ch == ';':
                if paren_depth in for_parens:
                    continue
                expected = block_base[-1]
                if paren_depth > expected:
                    fail(f'{f}:{line_of(idx)}: statement ends while '
                         f'{paren_depth - expected} expression(s) are still '
                         f'open - a closing bracket is in the wrong place')
                    broke = True
                    break

        if not broke and stack:
            ch, idx = stack[-1]
            fail(f'{f}: {len(stack)} unclosed {ch!r} '
                 f'(innermost opened line {line_of(idx)})')


# -- 2. imports --------------------------------------------------------------
\
# Control-flow keywords that the loose "type name(" pattern below picks up
# as if they were declarations. `if` was being collected as a symbol of
# every file, and since `if` appears in all Dart code, every import matched
# something and the unused-import check never fired on anything.
DART_KEYWORDS = {
    'if', 'for', 'while', 'switch', 'return', 'catch', 'else', 'do', 'try',
    'assert', 'await', 'new', 'super', 'this', 'throw', 'yield', 'in',
    'is', 'as', 'set', 'get', 'operator', 'case', 'default', 'finally',
    'rethrow', 'with', 'on',
}


def declared_symbols(path: str) -> set[str]:
    s = open(path, encoding='utf-8').read()
    out: set[str] = set()
    out |= set(re.findall(
        r'^(?:abstract\s+)?(?:class|enum|mixin|extension)\s+(\w+)', s, re.M))
    # Every pattern below uses `[ \t]`, never `\s`, for the space between a
    # type and the name it declares. `\s` matches a newline, so with re.M
    # the old pattern ran straight past the end of the line and matched any
    # `Name(` anywhere in the file - including `Text(`, `Icon(` and
    # `SizedBox(` inside a build method. Those names appear in nearly every
    # Flutter file, so every import looked used and this check passed two
    # genuinely unused imports (zip 23, mgnrega_tool and papers_tools).
    # A top-level declaration starts at column 0, which is what anchors it.
    TYPE = r'(?:[\w<>,?\[\]]+[ \t]+)+'
    out |= set(re.findall(r'^(?:const|final)[ \t]+[\w<>,?\[\] \t]*?(\w+)[ \t]*=',
                          s, re.M))
    # `?` included: a nullable return type (`double? f(`) hid the function
    # and made its import look unused (zip 22).
    out |= set(re.findall(rf'^{TYPE}(\w+)[ \t]*\(', s, re.M))
    # A top-level getter (`List<Issue> get kAllIssues => ...`) has no
    # parentheses, so the pattern above misses it and its import looks
    # unused (zip 22, home_page.dart).
    out |= set(re.findall(rf'^{TYPE}get[ \t]+(\w+)', s, re.M))

    # Members of an extension are used as `context.tr(...)`, so the
    # extension's own name never appears at the call site. Collect the
    # member names from THIS file only.
    #
    # They used to live in one shared set that was added to every import's
    # symbols, which meant any file calling `context.tr` made all of its
    # imports look used - so this check silently passed an unused import
    # for months.
    for em in re.finditer(r'extension\s+\w+\s+on\s+[\w<>?]+\s*\{', s):
        start = em.end() - 1
        depth, i = 0, start
        while i < len(s):
            if s[i] == '{':
                depth += 1
            elif s[i] == '}':
                depth -= 1
                if depth == 0:
                    break
            i += 1
        ext_body = s[start:i]
        out |= set(re.findall(r'\bget\s+(\w+)', ext_body))
        out |= set(re.findall(rf'^[ \t]*{TYPE}(\w+)[ \t]*(?:\(|=>)',
                              ext_body, re.M))

    # Keywords are not declarations, and a name starting with `_` is private
    # to its own file, so it can never be the reason another file imports it.
    return {x for x in out if x not in DART_KEYWORDS and not x.startswith('_')}


def check_imports() -> None:
    for f in DART:
        src = open(f, encoding='utf-8').read()
        body = re.sub(r"^import '[^']+';$", '', src, flags=re.M)
        for m in re.finditer(r"^import '([^':]+\.dart)';$", src, re.M):
            rel = m.group(1)
            target = os.path.normpath(os.path.join(os.path.dirname(f), rel))
            if not os.path.exists(target):
                if 'firebase_options' in rel:
                    notes.append(
                        f'{f}: firebase_options.dart missing '
                        '(generated by `flutterfire configure`)')
                    continue
                fail(f'{f}: import not found -> {rel}')
                continue
            syms = declared_symbols(target)
            if not syms:
                # A file that declares nothing recognisable (a `library;`
                # of constants, say) cannot be judged - say nothing rather
                # than guess.
                continue
            if not any(re.search(rf'\b{re.escape(s)}\b', body) for s in syms):
                fail(f'{f}: import appears unused -> {rel}')


# -- 3. const with runtime values -------------------------------------------
def check_const() -> None:
    for f in DART:
        src = open(f, encoding='utf-8').read()
        # Both `const Foo(` and `const _Foo(` - private widgets are where
        # this mistake actually gets made, and the old pattern required an
        # uppercase first letter, so it never looked at them.
        for m in re.finditer(r'\bconst\s+_?[A-Z]\w*\(', src):
            i = m.end() - 1
            depth, j = 0, i
            while j < len(src):
                if src[j] == '(':
                    depth += 1
                elif src[j] == ')':
                    depth -= 1
                    if depth == 0:
                        break
                j += 1
            seg = src[i:j]
            line = src[:m.start()].count('\n') + 1
            if 'context.' in seg or 'Theme.of' in seg or 'MediaQuery.' in seg:
                fail(f'{f}:{line}: const constructor contains a runtime value')
            # A closure is never a constant expression. `prefer_const_
            # constructors` suggests const on the widgets it can prove are
            # constant; adding it by hand to a widget that takes an onTap
            # does not compile, and the error names the closure rather than
            # the const, which is slow to read.
            if re.search(r'(?:^|[\s,(])\(\s*\)\s*(?:=>|\{)', seg) or \
               re.search(r'\(\w+\)\s*=>', seg):
                fail(f'{f}:{line}: const constructor holds a closure '
                     '(an onTap or callback). A closure is not a constant '
                     'expression, so this will not compile - drop the const')


# -- 4. widget where a String belongs ---------------------------------------
# This is the exact bug that shipped once: a bulk edit wrapped an http.post
# `body:` in a layout widget because it matched the same keyword as a
# Scaffold `body:`.
WIDGETY = re.compile(
    r'body:\s*(ContentShell|Padding|Center|Column|Row|ListView|Container)\(')


def check_http_bodies() -> None:
    for f in DART:
        src = open(f, encoding='utf-8').read()
        for m in re.finditer(r'(http\.(?:post|put|patch))\(', src):
            depth, j = 0, m.end() - 1
            while j < len(src):
                if src[j] == '(':
                    depth += 1
                elif src[j] == ')':
                    depth -= 1
                    if depth == 0:
                        break
                j += 1
            call = src[m.end():j]
            if WIDGETY.search(call):
                line = src[:m.start()].count('\n') + 1
                fail(f'{f}:{line}: a widget is being passed as an HTTP body')


# -- 4b. sliver / box protocol ----------------------------------------------
# Flutter has two layout protocols. A `CustomScrollView.slivers` list accepts
# only slivers; putting a box widget there compiles cleanly (everything is a
# `Widget`) and crashes at runtime with:
#
#   A RenderViewport expected a child of type RenderSliver but received a
#   child of type _RenderLayoutBuilder
#
# That shipped once. The rule below is why AdaptiveSliverGrid is a separate
# widget from AdaptiveGrid rather than a `sliver: true` flag - a name the
# checker can see beats a boolean it cannot.
SLIVER_OK = {
    'SliverPadding', 'SliverList', 'SliverGrid', 'SliverAppBar',
    'SliverToBoxAdapter', 'SliverFillRemaining', 'SliverFillViewport',
    'SliverLayoutBuilder', 'SliverOpacity', 'SliverAnimatedList',
    'SliverSafeArea', 'SliverVisibility', 'SliverOverlapAbsorber',
    'SliverOverlapInjector', 'SliverPersistentHeader', 'SliverMainAxisGroup',
    'SliverCrossAxisGroup', 'SliverReorderableList', 'SliverPrototypeExtentList',
    'SliverReorderableListState', 'SliverIgnorePointer', 'SliverReorderable',
    # project widgets that return slivers
    'AdaptiveSliverGrid',
}


def check_slivers() -> None:
    for f in DART:
        src = open(f, encoding='utf-8').read()
        for m in re.finditer(r'slivers:\s*\[', src):
            depth, j = 0, m.end() - 1
            while j < len(src):
                if src[j] == '[':
                    depth += 1
                elif src[j] == ']':
                    depth -= 1
                    if depth == 0:
                        break
                j += 1
            inner = src[m.end():j]
            # top-level widget constructors in the list
            d = 0
            token = ''
            for ch in inner:
                if ch in '([{':
                    if d == 0 and token.strip():
                        name = re.findall(r'(\w+)\s*$', token)
                        if name and name[0][0].isupper():
                            w = name[0]
                            if not w.startswith('Sliver') and w not in SLIVER_OK:
                                line = src[:m.start()].count('\n') + 1
                                fail(f'{f}:{line}: {w} is in a slivers: list '
                                     f'but is not a sliver widget')
                    d += 1
                    token = ''
                elif ch in ')]}':
                    d -= 1
                    token = ''
                elif d == 0:
                    token += ch
                    if ch == ',':
                        token = ''


# -- 5. JSON assets ----------------------------------------------------------
def check_json() -> None:
    for p in glob.glob('assets/**/*.json', recursive=True) + [
            'firebase.json', 'firestore.indexes.json',
            'web_template/manifest.json', 'proxy/package.json']:
        if not os.path.exists(p):
            fail(f'{p}: missing')
            continue
        try:
            json.load(open(p, encoding='utf-8'))
        except Exception as e:
            fail(f'{p}: invalid JSON - {e}')

    # Dataset invariants that protect users, not just the build.
    for p, key in [('assets/data/subsidies.json', 'officialLink'),
                   ('assets/data/scholarships.json', 'portal')]:
        if not os.path.exists(p):
            continue
        rows = json.load(open(p, encoding='utf-8'))
        ids = [r['id'] for r in rows]
        if len(set(ids)) != len(ids):
            fail(f'{p}: duplicate ids')
        bad = [r['id'] for r in rows
               if not str(r.get(key, '')).startswith('https://')]
        if bad:
            fail(f'{p}: rows {bad} have a non-https {key}')

    sch = 'assets/data/scholarships.json'
    if os.path.exists(sch):
        rows = json.load(open(sch, encoding='utf-8'))
        invented = [r['id'] for r in rows if r.get('deadline') is not None]
        if invented:
            fail(f'{sch}: rows {invented} carry a hard-coded deadline. '
                 'Deadlines belong in Firestore, set by an admin.')

    # Helplines: a number that will not dial is a real-world failure in the
    # one module where failure matters most. `tel:` silently does nothing if
    # the number contains anything but digits.
    for hl in ('assets/data/helplines.json',
               'assets/data/health_helplines.json'):
        if not os.path.exists(hl):
            continue
        rows = json.load(open(hl, encoding='utf-8'))
        bad = [r['number'] for r in rows
               if not str(r.get('number', '')).isdigit()]
        if bad:
            fail(f'{hl}: {bad} are not plain digits and will not dial')
        no_hi = [r['id'] for r in rows
                 if not r.get('nameHi') or not r.get('detailHi')]
        if no_hi:
            fail(f'{hl}: rows {no_hi} are missing Hindi text')

    # Myth cards: a card without a source is an unsourced health claim,
    # which is the thing this module exists to fight.
    mh = 'assets/data/health_myths.json'
    if os.path.exists(mh):
        rows = json.load(open(mh, encoding='utf-8'))
        no_src = [r['id'] for r in rows
                  if not str(r.get('source', '')).startswith('https://')]
        if no_src:
            fail(f'{mh}: rows {no_src} have no official source link')
        no_hi = [r['id'] for r in rows
                 if not r.get('mythHi') or not r.get('factHi')
                 or not r.get('whyHi')]
        if no_hi:
            fail(f'{mh}: rows {no_hi} are missing Hindi text')

    # Category-filtered guide datasets. Each module home screen links to
    # one screen per category, so a category with no rows is a dead tap and
    # a category nothing links to is content nobody can reach.
    GUIDE_SETS = [
        ('assets/data/water_guides.json', 'SDG 6',
         {'treatment', 'chemical', 'testing', 'entitlement', 'complaint',
          'protect'}),
        ('assets/data/energy_guides.json', 'SDG 7',
         {'rights', 'bill', 'complaint', 'solar', 'lpg', 'indoor'}),
        ('assets/data/enterprise_guides.json', 'SDG 9',
         {'udyam', 'loans', 'fraud', 'records', 'digital'}),
        ('assets/data/free_care.json', 'SDG 3',
         {'doctor', 'cover', 'medicine', 'leftover'}),
        ('assets/data/women_wellness.json', 'SDG 5',
         {'mother', 'body', 'mind'}),
        ('assets/data/land_guides.json', 'SDG 15',
         {'wildlife', 'soil'}),
        ('assets/data/ocean_guides.json', 'SDG 14',
         {'safety', 'report'}),
        ('assets/data/consumption_guides.json', 'SDG 12',
         {'repair', 'waste'}),
        ('assets/data/climate_guides.json', 'SDG 13',
         {'alerts', 'heat'}),
        ('assets/data/cities_guides.json', 'SDG 11',
         {'property', 'disaster'}),
        ('assets/data/equality_guides.json', 'SDG 10',
         {'disability', 'reservation'}),
    ]

    # The learning page filters on `levels`, not `category`. A level the
    # page offers with no platform behind it is an empty screen for exactly
    # the person who picked it.
    lg = 'assets/data/learning_guides.json'
    if os.path.exists(lg):
        rows = json.load(open(lg, encoding='utf-8'))
        offered = {'early', 'primary', 'secondary', 'leftschool', 'college'}
        seen = set()
        for r in rows:
            lv = r.get('levels')
            if not isinstance(lv, list) or not lv:
                fail(f'{lg}: row {r["id"]} has no levels, so no level shows it')
                continue
            stray = set(lv) - offered
            if stray:
                fail(f'{lg}: row {r["id"]} has unknown levels {sorted(stray)}')
            seen |= set(lv)
            if not str(r.get('source', '')).startswith('https://'):
                fail(f'{lg}: row {r["id"]} has no https link')
        missing = sorted(offered - seen)
        if missing:
            fail(f'{lg}: levels {missing} have no platform - picking them '
                 'shows an empty page')
    for path, goal, known in GUIDE_SETS:
        if not os.path.exists(path):
            continue
        rows = json.load(open(path, encoding='utf-8'))
        ids = [r['id'] for r in rows]
        if len(set(ids)) != len(ids):
            fail(f'{path}: duplicate ids')
        no_src = [r['id'] for r in rows
                  if not str(r.get('source', '')).startswith('https://')]
        if no_src:
            fail(f'{path}: rows {no_src} have no official source link. '
                 'Guidance a reader cannot check is not safe to show.')
        no_hi = [r['id'] for r in rows
                 if not r.get('titleHi') or not r.get('bodyHi')]
        if no_hi:
            fail(f'{path}: rows {no_hi} are missing Hindi text')
        present = {str(r.get('category', '')) for r in rows}
        strays = sorted(present - known)
        if strays:
            fail(f'{path}: unknown categories {strays} - no screen lists '
                 'these, so those rows would be invisible in the app')
        empty = sorted(known - present)
        if empty:
            fail(f'{path}: categories {empty} have no rows, but the {goal} '
                 'home screen links to them')
        # A `phone` on a guide card becomes a tap-to-dial button. `tel:`
        # silently does nothing with a hyphen or a space in it, and the card
        # still looks fine, so this is the only place it gets caught.
        bad_phone = [(r['id'], r['phone']) for r in rows
                     if 'phone' in r and not str(r['phone']).isdigit()]
        if bad_phone:
            fail(f'{path}: phone numbers {bad_phone} are not plain digits '
                 'and will not dial')

    # The child vaccine tracker computes due dates from these offsets. A
    # stage with no offset, or two, or offsets that go backwards, produces a
    # wrong date for a real child - and the screen would look perfectly fine.
    vs = 'assets/data/vaccination_schedule.json'
    if os.path.exists(vs):
        rows = json.load(open(vs, encoding='utf-8'))
        approx = []
        for r in rows:
            if r.get('pregnancy') is True:
                continue
            keys = [k for k in ('dueWeeks', 'dueMonths', 'dueYears')
                    if isinstance(r.get(k), int)]
            if len(keys) != 1:
                fail(f'{vs}: stage {r["id"]} needs exactly one of dueWeeks, '
                     f'dueMonths or dueYears, has {keys or "none"}')
                continue
            k = keys[0]
            days = r[k] * {'dueWeeks': 7, 'dueMonths': 30.44,
                           'dueYears': 365.25}[k]
            approx.append((r['id'], days))
        for (a, da), (b, db) in zip(approx, approx[1:]):
            if not db > da:
                fail(f'{vs}: stage {b} is due no later than stage {a} - the '
                     'schedule order and the offsets disagree')

    lr = 'assets/data/legal_rights.json'
    if os.path.exists(lr):
        rows = json.load(open(lr, encoding='utf-8'))
        no_src = [r['id'] for r in rows
                  if not str(r.get('source', '')).startswith('https://')]
        if no_src:
            fail(f'{lr}: rows {no_src} have no official source link. '
                 'Legal information without a source to check is not safe '
                 'to show.')
        no_hi = [r['id'] for r in rows
                 if not r.get('titleHi') or not r.get('summaryHi')]
        if no_hi:
            fail(f'{lr}: rows {no_hi} are missing Hindi text')


# -- 6. secrets --------------------------------------------------------------
SECRET = re.compile(
    r'AIza[0-9A-Za-z_\-]{30,}|sk-[A-Za-z0-9]{20,}|'
    r'gsk_[A-Za-z0-9]{30,}|sk-ant-[A-Za-z0-9\-]{20,}')

# Firebase client config is NOT a secret. `google-services.json`,
# `GoogleService-Info.plist` and `firebase_options.dart` all contain an
# `AIza...` Web API key by design - it identifies the project, it does not
# authorise anything. Firestore rules are what protect the data. Flagging
# these trains you to ignore the scanner, which is worse than not scanning.
PUBLIC_CONFIG = (
    'google-services.json',
    'GoogleService-Info.plist',
    'firebase_options.dart',
)


def check_secrets() -> None:
    for p in glob.glob('**/*', recursive=True):
        if not os.path.isfile(p):
            continue
        if os.path.basename(p) in PUBLIC_CONFIG:
            continue
        if p.split('.')[-1] not in ('dart', 'js', 'json', 'html', 'yaml',
                                    'md', 'bat', 'rules'):
            continue
        try:
            txt = open(p, encoding='utf-8', errors='ignore').read()
        except Exception:
            continue
        for m in SECRET.finditer(txt):
            line = txt[:m.start()].count('\n') + 1
            fail(f'{p}:{line}: looks like a committed provider API key '
                 f'({m.group(0)[:12]}...)')


# -- 7. regressions already fixed once --------------------------------------
def check_regressions() -> None:
    pub = open('pubspec.yaml', encoding='utf-8').read()
    if re.search(r'^\s*intl:\s*\^0\.19', pub, re.M):
        fail('pubspec.yaml: intl pinned to ^0.19 again - that break was '
             'already fixed once (see LOCAL_CHANGES.md)')
    if re.search(r'^\s*sdgapp:', pub, re.M):
        fail('pubspec.yaml: `sdgapp` dependency present - `dart fix` added '
             'it in error; that package does not exist')
    for f in DART:
        src = open(f, encoding='utf-8').read()
        if 'RadioListTile' in src and 'selection_tile' not in f:
            fail(f'{f}: RadioListTile is deprecated here - use SelectionTile')

        # `set`, `get` and `operator` after a return type start a
        # setter/getter/operator declaration, so they cannot be used as
        # ordinary method names. The result is a parse error some lines
        # away from the actual cause, which is slow to diagnose.
        for m in re.finditer(
                r'^\s*(?:static\s+)?[\w<>,\s\?\[\]]+?\s(set|get|operator)'
                r'\s*\(', src, re.M):
            ln = src[:m.start()].count('\n') + 1
            fail(f'{f}:{ln}: "{m.group(1)}" cannot be a method name - Dart '
                 f'reads it as a {m.group(1)}ter declaration. Rename it')


def _blank_literals(src: str) -> str:
    """Like strip_noise, but preserves offsets so line numbers stay right.

    Strings and comments become spaces rather than disappearing. Blanking a
    string also blanks any `${...}` interpolation inside it, which can hide
    a real reference - that only ever makes the check below miss something,
    never invent one.
    """
    out = list(src)
    i, n = 0, len(src)

    def blank(a: int, b: int) -> None:
        for k in range(a, min(b, n)):
            if out[k] != '\n':
                out[k] = ' '

    while i < n:
        c = src[i]
        if c == '/' and i + 1 < n and src[i + 1] == '/':
            j = src.find('\n', i)
            j = n if j < 0 else j
            blank(i, j)
            i = j
        elif c == '/' and i + 1 < n and src[i + 1] == '*':
            j = src.find('*/', i + 2)
            j = n if j < 0 else j + 2
            blank(i, j)
            i = j
        elif c in '"\'':
            triple = src[i:i + 3] in ('"""', "'''")
            q = src[i:i + 3] if triple else c
            j = i + len(q)
            while j < n:
                if src[j] == '\\':
                    j += 2
                    continue
                if src[j:j + len(q)] == q:
                    j += len(q)
                    break
                j += 1
            blank(i, j)
            i = j
        else:
            i += 1
    return ''.join(out)


def _match_brace(s: str, i: int) -> int:
    """i points at '{'. Returns the index of its partner, or -1."""
    depth = 0
    while i < len(s):
        if s[i] == '{':
            depth += 1
        elif s[i] == '}':
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return -1


# Names this project binds per-build from the current locale, rather than
# importing or declaring globally. They are the ones that go missing when a
# widget is refactored.
SCOPED_NAMES = ('hi', '_hi', 'lang')


def check_scoped_names() -> None:
    """Catch a locale variable used where nothing declares it.

    This is the check that was missing. Removing the `hi` field from two
    `_GuideCard` widgets left three uses of `hi` further down the same class,
    and the validator passed the file - the build broke on his machine
    instead, which is the slowest possible place to find out.

    It is not a Dart resolver and does not try to be. It checks only the
    handful of locale names this project binds inside build methods, which is
    exactly where the refactors happen.
    """
    for f in DART:
        src = _blank_literals(open(f, encoding='utf-8').read())

        for cm in re.finditer(r'\bclass\s+(\w+)[^{;]*\{', src):
            cls_open = src.index('{', cm.start())
            cls_end = _match_brace(src, cls_open)
            if cls_end < 0:
                continue
            cls_body = src[cls_open:cls_end]

            for name in SCOPED_NAMES:
                esc = re.escape(name)

                # A reference, not a label. `hi: _hi` and `{'hi': ...}` are
                # named arguments and map keys, not uses of a variable, and
                # counting them was this check's first and noisiest bug.
                refs = [m for m in re.finditer(rf'\b{esc}\b(?!\s*:)',
                                               cls_body)]
                if not refs:
                    continue

                # Scope is the whole class body, not each method.
                #
                # Resolving per-method would be more precise, but it needs
                # real parsing: an earlier version of this check read
                # `return Scaffold(` and `if (...)` as method declarations
                # and reported eight phantom errors on a project that
                # compiled. The narrower question - does anything in this
                # class declare the name at all - is the one that catches
                # the bug that actually shipped, and it has no false
                # positives. A binding present in a different method of the
                # same class is the known blind spot, and a scanner that
                # cries wolf is worse than one with a stated gap.
                declared = (
                    # `final hi = ...`, `String lang` as a parameter, a
                    # field declaration - all of them are a type or
                    # modifier immediately before the name.
                    re.search(rf'\b(?:final|var|late|const|String|bool|int|'
                              rf'double|dynamic|Locale)\s+{esc}\b', cls_body)
                    or re.search(rf'\bget\s+{esc}\b', cls_body)
                    or re.search(rf'required\s+this\.{esc}\b', cls_body)
                    or re.search(rf'\b{esc}\s*=[^=]', cls_body)
                )
                if declared:
                    continue

                off = cls_open + refs[0].start()
                ln = src[:off].count('\n') + 1
                hint = ("`final hi = lang == 'hi';`" if name in ('hi', '_hi')
                        else '`final lang = '
                             'LocaleScope.languageOf(context);`')
                fail(f'{f}:{ln}: class {cm.group(1)} uses "{name}" but '
                     f'nothing in the class declares it. Add {hint} in the '
                     'build method, or pass it in as a field.')


def check_water_logic() -> None:
    """The one rule SDG 6 exists to enforce.

    "Boil it" is the universal answer to bad water in India, and for germs
    it is correct. For arsenic and fluoride it does nothing - boiling
    removes no chemicals, and the contaminant is invisible and tasteless, so
    nobody finds out their routine is not protecting them until the damage
    is decades deep.

    So: a verdict that has identified a chemical problem must never carry a
    step telling the user to boil. That is not a style preference, it is the
    reason the module is worth shipping, and it is one careless edit away
    from being lost.
    """
    f = 'lib/features/sdg6_water/water_check.dart'
    if not os.path.exists(f):
        notes.append('SDG 6 water check missing - skipping its logic check')
        return
    src = open(f, encoding='utf-8').read()

    def close_of(s: str, i: int) -> int:
        depth = 0
        while i < len(s):
            c = s[i]
            if c in "'\"":
                q = c
                i += 1
                while i < len(s):
                    if s[i] == '\\':
                        i += 2
                        continue
                    if s[i] == q:
                        break
                    i += 1
            elif c == '[':
                depth += 1
            elif c == ']':
                depth -= 1
                if depth == 0:
                    return i
            i += 1
        return -1

    seen = set()
    for m in re.finditer(r'verdict: WaterVerdict\.(\w+)', src):
        name = m.group(1)
        seen.add(name)
        sm = re.search(r'\n\s+steps: (?:const )?\[', src[m.start():])
        if not sm:
            fail(f'{f}: the {name} verdict has no steps list')
            continue
        start = m.start() + sm.end() - 1
        end = close_of(src, start)
        if end < 0:
            fail(f'{f}: unbalanced steps list in the {name} verdict')
            continue
        items = re.findall(r"'((?:[^'\\]|\\.)*)'", src[start + 1:end])
        boiling = [x for x in items if re.search(r'\bboil', x, re.I)]
        if name in ('chemical', 'both') and boiling:
            fail(f'{f}: the "{name}" verdict tells the user to boil: '
                 f'"{boiling[0][:70]}". Boiling removes no chemicals, so '
                 'this is the one piece of advice this module exists to '
                 'prevent.')
        if name == 'microbial' and not boiling:
            fail(f'{f}: the "microbial" verdict no longer mentions boiling. '
                 'That is the one case where boiling IS the right answer.')

    for required in ('chemical', 'both', 'microbial', 'untested',
                     'nothingVisible'):
        if required not in seen:
            fail(f'{f}: no branch returns the "{required}" verdict, so it '
                 'is unreachable')

    # The chemical verdicts must also set the flag that drives the
    # prominent "boiling removes no chemicals" correction in the UI.
    for m in re.finditer(r'verdict: WaterVerdict\.(chemical|both)', src):
        window = src[m.start():m.start() + 300]
        if 'boilingWillNotHelp: true' not in window:
            ln = src[:m.start()].count('\n') + 1
            fail(f'{f}:{ln}: a {m.group(1)} verdict without '
                 'boilingWillNotHelp: true - the correction would not be '
                 'shown to the user')


def check_bill_logic() -> None:
    """SDG 7's bill checker must keep provable and suspected apart.

    The tool's credibility rests on one distinction: a subtraction that does
    not come out is provable at the counter, while an unusual-looking rate
    has innocent explanations (fixed charges, arrears, a long billing
    period). If a suspicion is ever marked decisive, the app sends someone
    to argue a correct bill, and the next time it is right they will not
    believe it.
    """
    f = 'lib/features/sdg7_energy/bill_check.dart'
    if not os.path.exists(f):
        notes.append('SDG 7 bill check missing - skipping its logic check')
        return
    src = open(f, encoding='utf-8').read()

    expected = {
        'unitsDoNotMatchReadings': True,
        'readingWentBackwards': True,
        'notActuallyRead': True,
        'rateLooksHigh': False,
        'jumpVsUsual': False,
    }

    seen = set()
    for m in re.finditer(r'issue: BillIssue\.(\w+),\s*\n\s*decisive: (\w+),',
                         src):
        name, dec = m.group(1), m.group(2) == 'true'
        seen.add(name)
        if name not in expected:
            fail(f'{f}: unknown BillIssue "{name}" - add it to the '
                 'validator with its intended decisive flag')
        elif expected[name] != dec:
            ln = src[:m.start()].count('\n') + 1
            want = 'decisive' if expected[name] else 'not decisive'
            fail(f'{f}:{ln}: "{name}" is marked decisive: {dec}, but it '
                 f'must be {want}. Provable arithmetic and a suspicion '
                 'cannot be shown to the user the same way.')

    for name in expected:
        if name not in seen:
            fail(f'{f}: no finding is constructed for BillIssue.{name}, '
                 'so that case is unreachable')

    # The tool must never tell anyone their bill is correct. It checks
    # arithmetic, not tariff, and cannot know.
    #
    # Only string literals are searched, not comments: the file's own doc
    # comment discusses the phrase in order to forbid it, and a check that
    # flags its own rationale is a check people switch off.
    # Adjacent string literals are concatenated by Dart, so a sentence is
    # routinely split across several of them by the formatter. Checking one
    # literal at a time splits "It cannot tell you that you were
    # overcharged" at the line break and reads the second half as a claim.
    # Join each run of adjacent literals first - that is the string the
    # user actually sees.
    lit = re.compile(r"'((?:[^'\\\n]|\\.)*)'")
    for page in (f, 'lib/features/sdg7_energy/bill_check_page.dart'):
        if not os.path.exists(page):
            continue
        body = open(page, encoding='utf-8').read()

        runs: list[tuple[int, str]] = []
        pos = 0
        while True:
            m = lit.search(body, pos)
            if not m:
                break
            start, text, end = m.start(), m.group(1), m.end()
            while True:
                nxt = lit.match(body, end) or lit.search(body, end)
                if not nxt:
                    break
                between = body[end:nxt.start()]
                if between.strip() != '':
                    break
                text += nxt.group(1)
                end = nxt.end()
            runs.append((start, text))
            pos = end

        for start, text in runs:
            low = text.lower()
            for phrase in ('bill is correct', 'bill is right',
                           'you were overcharged',
                           'you have been overcharged'):
                if phrase not in low:
                    continue
                # An explicit denial in the same sentence is the point.
                if re.search(r'not\s+mean|never|cannot|does not|is not|'
                             r'कभी नहीं|नहीं', text, re.I):
                    continue
                ln = body[:start].count('\n') + 1
                fail(f'{page}:{ln}: a user-facing string says "{phrase}". '
                     'This tool checks arithmetic, not tariff - it cannot '
                     'establish either.')


def check_gitignore() -> None:
    """The release keystore must never be committable.

    This is the only check here guarding against a mistake that cannot be
    undone. Commit the keystore to a public repo and anyone can sign an app
    as Ibtidaa Tech, and deleting it later does not help because git keeps
    history — the Gemini key in the EmpowHer repo is the precedent. Lose the
    keystore and the app can never be updated at all.

    A committed `.env` is the other one: the AI provider keys belong on the
    Render proxy's environment, never in the repo.
    """
    f = '.gitignore'
    if not os.path.exists(f):
        fail('.gitignore is missing. A Flutter repo without one commits '
             'build output, and sooner or later the release keystore.')
        return

    body = open(f, encoding='utf-8').read()
    required = {
        '*.jks': 'the Android release keystore',
        '*.keystore': 'the Android release keystore',
        'key.properties': 'the keystore passwords',
        '.env': 'the AI provider keys',
        'build/': 'build output',
        '.dart_tool/': 'the Dart tool cache',
    }
    for pattern, what in required.items():
        # Match the pattern as its own line, so a mention inside a comment
        # does not count as a rule.
        if not re.search(rf'^{re.escape(pattern)}\s*$', body, re.M):
            fail(f'{f}: no rule for "{pattern}" ({what}). '
                 + ('Committing this cannot be undone - git keeps history.'
                    if pattern in ('*.jks', '*.keystore', 'key.properties',
                                   '.env')
                    else ''))

    # pubspec.lock must NOT be ignored: this is an application, and the lock
    # file is what keeps the intl version pinned to what his SDK accepts.
    if re.search(r'^pubspec\.lock\s*$', body, re.M):
        fail(f'{f}: pubspec.lock is ignored. For an application it should '
             'be committed - it is what makes the build reproducible and '
             'what keeps the intl version from drifting again.')


def check_scheme_logic() -> None:
    """SDG 9's scheme matcher must never dead-end and never over-promise.

    Two failure modes, both caught during the build and both worth a guard:

      1. An empty result. Eighteen of the 192 input combinations match no
         named scheme (a running business wanting more than ten lakh outside
         the Stand-Up India categories). Without the fallback that names an
         ordinary MSME term loan, those users get a blank screen that reads
         as "nothing for you" when the normal route applies.
      2. Over-promising. The matcher names a scheme to ask about; the bank
         decides. If that distinction is ever lost, the app starts doing
         what the loan agents do.
    """
    f = 'lib/features/sdg9_enterprise/scheme_match.dart'
    page = 'lib/features/sdg9_enterprise/scheme_match_page.dart'
    if not os.path.exists(f):
        notes.append('SDG 9 scheme matcher missing - skipping its check')
        return
    src = open(f, encoding='utf-8').read()

    # The fallback that stops a blank result.
    if 'matches.isEmpty' not in src or 'msme-term' not in src:
        fail(f'{f}: the empty-result fallback is gone. Some input '
             'combinations match no named scheme, and without a fallback '
             'they render an empty screen that reads as a dead end.')

    # PMEGP's new-units-only rule is a hard eligibility bar in the
    # guidelines, not a preference. If it stops producing an exclusion,
    # existing units get sent to a scheme that will reject them.
    if 'SchemeExclusion' not in src or 'PMEGP' not in src:
        fail(f'{f}: PMEGP no longer produces an exclusion. Existing units '
             'are not eligible under the guidelines, and sending one to '
             'apply wastes a trip and a rejection.')

    if os.path.exists(page):
        body = open(page, encoding='utf-8').read()
        # The honesty guard has to be on the results screen itself.
        if 'not an approval' not in body.lower():
            fail(f'{page}: the "this is not an approval" notice is gone '
                 'from the results screen. Without it the app reads as '
                 'promising a loan it has no part in granting.')
        # Either wording is fine - "guarantee a sanction" and "promise a
        # sanction" say the same thing, and the check should not dictate
        # which reads better on the screen.
        low = body.lower()
        if not (('guarantee' in low)
                or ('promise' in low and 'sanction' in low)):
            fail(f'{page}: the warning that nobody can guarantee or '
                 'promise a sanction is gone. Advance-fee loan fraud is '
                 'the specific harm this module was built to counter.')


def check_i18n() -> None:
    """Language-table invariants.

    Four separate ways the multilingual build can break quietly, each of
    which has to be caught here because none of them is a compile error:

      1. A language missing a key falls back to English, so a half-translated
         table ships as a mixed-language screen that nobody notices.
      2. A code in kLanguageCodes with no map, or a map with no registry
         entry, produces a language the user can select and that then does
         nothing.
      3. A code outside flutter_localizations resolves Material's own
         widgets to an arbitrary fallback locale.
      4. `_SDelegate.load` returning a real Future makes every per-section
         language switch flash an empty frame. `async` is the natural thing
         to write there, so it needs a guard.
    """
    strings = 'lib/core/i18n/strings.dart'
    langs = 'lib/core/i18n/app_languages.dart'
    if not os.path.exists(strings) or not os.path.exists(langs):
        notes.append('i18n files missing - skipping language checks')
        return

    src = open(strings, encoding='utf-8').read()
    reg = open(langs, encoding='utf-8').read()

    # Codes that flutter_localizations actually ships (kMaterialSupportedLanguages).
    supported = {
        'af', 'am', 'ar', 'as', 'az', 'be', 'bg', 'bn', 'bs', 'ca', 'cs',
        'cy', 'da', 'de', 'el', 'en', 'es', 'et', 'eu', 'fa', 'fi', 'fil',
        'fr', 'gl', 'gsw', 'gu', 'he', 'hi', 'hr', 'hu', 'hy', 'id', 'is',
        'it', 'ja', 'ka', 'kk', 'km', 'kn', 'ko', 'ky', 'lo', 'lt', 'lv',
        'mk', 'ml', 'mn', 'mr', 'ms', 'my', 'nb', 'ne', 'nl', 'no', 'or',
        'pa', 'pl', 'ps', 'pt', 'ro', 'ru', 'si', 'sk', 'sl', 'sq', 'sr',
        'sv', 'sw', 'ta', 'te', 'th', 'tl', 'tr', 'uk', 'ur', 'uz', 'vi',
        'zh', 'zu',
    }

    blocks = re.findall(r"\n    '([a-z]{2,3})': \{\n(.*?)\n    \},", src, re.S)
    if not blocks:
        fail(f'{strings}: no language blocks found - the parser or the file '
             'shape changed')
        return

    tables = {}
    for code, body in blocks:
        tables[code] = re.findall(r"^      '([a-z0-9_]+)':", body, re.M)

    if 'en' not in tables:
        fail(f'{strings}: no English table')
        return

    base = list(dict.fromkeys(tables['en']))
    for code, keys in tables.items():
        dupes = [k for k in set(keys) if keys.count(k) > 1]
        if dupes:
            fail(f'{strings}: {code} has duplicate keys: '
                 f'{sorted(dupes)[:5]}')
        missing = [k for k in base if k not in set(keys)]
        extra = sorted(set(keys) - set(base))
        if missing:
            fail(f'{strings}: {code} is missing {len(missing)} key(s), so '
                 f'those fall back to English: {missing[:6]}')
        if extra:
            fail(f'{strings}: {code} has key(s) English does not: {extra[:6]}')

    m = re.search(r'kLanguageCodes = \[(.*?)\];', reg, re.S)
    if not m:
        fail(f'{langs}: kLanguageCodes not found')
        return
    codes = re.findall(r"'([a-z]{2,3})'", m.group(1))

    registry = re.findall(r"code: '([a-z]{2,3})'", reg)

    for c in codes:
        if c not in tables:
            fail(f'{langs}: "{c}" is offered but has no table in '
                 f'{strings} - selecting it would change nothing')
        if c not in registry:
            fail(f'{langs}: "{c}" is in kLanguageCodes but not in '
                 'kAppLanguages, so it has no display name')
        if c not in supported:
            fail(f'{langs}: "{c}" is not in flutter_localizations - '
                 'Material widgets would silently use a fallback locale')
    for c in registry:
        if c not in codes:
            fail(f'{langs}: "{c}" is in kAppLanguages but not in '
                 'kLanguageCodes, so the delegate will reject it')
    for c in tables:
        if c not in codes:
            fail(f'{strings}: "{c}" has a table but is not in '
                 'kLanguageCodes, so it is unreachable')

    # Check the load method itself, not just whether the word appears
    # somewhere in the file - it is also in the import line, which made an
    # earlier version of this check pass on an async body.
    load = re.search(r'Future<S>\s+load\s*\([^)]*\)\s*(async\s*)?(=>|\{)',
                     src)
    if not load:
        fail(f'{strings}: _SDelegate.load not found - the delegate shape '
             'changed, re-check the SynchronousFuture requirement by hand')
    elif load.group(1):
        fail(f'{strings}: _SDelegate.load is `async`, so it returns a real '
             'Future. Localizations.override then renders a blank frame, '
             'which means every per-section language switch flashes empty. '
             'Return SynchronousFuture<S>(S(locale)) instead')
    elif 'SynchronousFuture' not in src[load.start():load.start() + 200]:
        fail(f'{strings}: _SDelegate.load does not return a '
             'SynchronousFuture - the per-section language switch will '
             'flash a blank frame')

    # The content text accessors used to take `bool hi`; they now take a
    # language code, because two languages are no longer the whole story.
    # Passing a bool still reads fine to a human skimming a diff, and Dart
    # would reject it - but only at build time, which is on his machine and
    # not here. So catch it in the diff instead.
    accessors = (
        'mythText', 'factText', 'whyText', 'shareText', 'ageText',
        'noteText', 'vaccineList', 'titleText', 'summaryText',
    )
    pat = re.compile(
        r'\b(' + '|'.join(accessors) + r')\(\s*(hi|_hi|true|false)\s*\)')
    for f in DART:
        src_f = open(f, encoding='utf-8').read()
        for m in pat.finditer(src_f):
            ln = src_f[:m.start()].count('\n') + 1
            fail(f'{f}:{ln}: {m.group(1)}({m.group(2)}) - these take a '
                 'language code now, not a bool. Pass '
                 'LocaleScope.languageOf(context)')
    # `.title(hi)` / `.body(hi)` on the helpline models, same change.
    pat2 = re.compile(r'\.(title|body)\(\s*(hi|_hi|true|false)\s*\)')
    for f in DART:
        src_f = open(f, encoding='utf-8').read()
        for m in pat2.finditer(src_f):
            ln = src_f[:m.start()].count('\n') + 1
            fail(f'{f}:{ln}: .{m.group(1)}({m.group(2)}) - takes a language '
                 'code now, not a bool')

    # A mojibake replacement character means a translation was mangled on
    # the way in. It renders as a black diamond on the device.
    for f in DART + ASSETS:
        try:
            body = open(f, encoding='utf-8').read()
        except (OSError, UnicodeDecodeError):
            continue
        if '�' in body:
            ln = body[:body.index('�')].count('\n') + 1
            fail(f'{f}:{ln}: U+FFFD replacement character - text was '
                 'corrupted, it will show as a black diamond')


# -- screens used but never imported -----------------------------------------
# zip 21 nearly shipped `const MedicineRemindersPage()` in a file that did
# not import it: a bulk edit's anchor line did not exist, so the import was
# silently not added. Every name ending in Page/Store/Service that is
# referenced must be declared in this file or in a project file it imports
# (one level of `export` followed). Package classes with those suffixes
# would be false positives, so names from package imports are allowed by
# listing them below.
PACKAGE_SUFFIXED = {'SharedPreferences', 'GuideListPage'}


def check_local_refs() -> None:
    decl_cache = {}

    def decls(path):
        if path not in decl_cache:
            src = open(path, encoding='utf-8').read()
            names = set(re.findall(
                r'^(?:abstract\s+|final\s+|sealed\s+|base\s+)*'
                r'(?:class|enum|mixin|extension|typedef)\s+(\w+)', src, re.M))
            for m in re.finditer(r"^export '([^':]+\.dart)'", src, re.M):
                t = os.path.normpath(os.path.join(os.path.dirname(path),
                                                  m.group(1)))
                if os.path.exists(t):
                    names |= set(re.findall(
                        r'^(?:abstract\s+)?(?:class|enum)\s+(\w+)',
                        open(t, encoding='utf-8').read(), re.M))
            decl_cache[path] = names
        return decl_cache[path]

    for f in DART:
        src = open(f, encoding='utf-8').read()
        known = set(decls(f))
        for m in re.finditer(r"^import '([^':]+\.dart)'", src, re.M):
            t = os.path.normpath(os.path.join(os.path.dirname(f), m.group(1)))
            if os.path.exists(t):
                known |= decls(t)
        code = re.sub(r"//[^\n]*", '', src)
        code = re.sub(r"'(?:[^'\\\n]|\\.)*'", "''", code)
        for name in set(re.findall(r'\b([A-Z]\w*(?:Page|Store|Service))\b',
                                   code)):
            if name in known or name in PACKAGE_SUFFIXED:
                continue
            if re.search(rf"import 'package:[^']+' show [^;]*\b{name}\b", src):
                continue
            fail(f'{f}: uses {name} but neither declares nor imports it')


# -- SDG 2 food board ----------------------------------------------------------
# Strangers exchanging food. The safety decisions (2 Nov 2026) are pinned
# here so a later edit cannot quietly drop one.
def check_food_board() -> None:
    rules = open('firestore.rules', encoding='utf-8').read()
    m = re.search(r'match /foodBoard/\{postId\} \{(.*?)\n    \}\n', rules, re.S)
    if not m:
        fail('firestore.rules: foodBoard rules missing')
        return
    body = m.group(1)
    priv = re.search(r'match /private/\{doc\} \{(.*?)\n      \}', body, re.S)
    if not priv:
        fail('firestore.rules: foodBoard private contact rules missing')
    else:
        read = re.search(r'allow read:(.*?);', priv.group(1), re.S)
        if not read or 'true' in read.group(1) or 'isAdmin' in read.group(1):
            fail('firestore.rules: food contact must be readable only by the '
                 'poster and the claimer')
    for needle, why in [
        ("keys().hasOnly(['uid', 'title'", 'public post must not carry extra '
         'fields such as a phone'),
        ("duration.value(", 'listing must be capped in time'),
        ("existsAfter(", 'report counter must be tied to a report document'),
        ("phone.matches(", 'phone must be validated'),
    ]:
        if needle not in body:
            fail(f'firestore.rules: foodBoard - {why}')

    fb = 'lib/features/sdg2_food/food_board.dart'
    src = open(fb, encoding='utf-8').read()
    if "'phone'" in src.split('..set(ref.collection')[0].split('final batch')[-1]:
        fail(f'{fb}: phone written into the public post')
    if 'hours < 1 / 3 ? null' not in src:
        fail(f'{fb}: listingHours must refuse listings with under 20 minutes')
    if 'verdict == ShareVerdict.no) return null' not in src:
        fail(f'{fb}: listingHours must refuse a "no" verdict')

    # The posting form is reachable only from the share check.
    for f in DART:
        if 'PostFoodPage(' in open(f, encoding='utf-8').read() and not (
                f.endswith('share_check_page.dart')
                or f.endswith('food_board_page.dart')):
            fail(f'{f}: opens PostFoodPage - posting must start at the '
                 'share check')


# -- SDG 4 moderated Q&A --------------------------------------------------------
# Children and strangers. Approval-before-visible and the contact filter
# are pinned here, and the app's pattern must equal the rules' pattern.
def check_qa() -> None:
    rules = open('firestore.rules', encoding='utf-8').read()
    m = re.search(r"t\.matches\('\(\?is\)\.\*\((.*?)\)\.\*'\)", rules)
    qa = 'lib/features/sdg4_scholarships/qa.dart'
    src = open(qa, encoding='utf-8').read()
    d = re.search(r"RegExp\(r'\((.*?)\)',", src)
    if not m or not d:
        fail('Q&A contact pattern missing from firestore.rules or qa.dart')
    else:
        norm = lambda x: x.replace('[.]', '.').replace('\\.', '.') \
            .replace('\\-', '-')
        if norm(m.group(1)) != norm(d.group(1)):
            fail(f'Q&A contact pattern differs: rules {m.group(1)!r} vs '
                 f'app {d.group(1)!r}')
    for coll in ('qa', 'qaAnswers'):
        blk = re.search(rf'match /{coll}/\{{\w+\}} \{{(.*?)\n    \}}', rules, re.S)
        if not blk:
            fail(f'firestore.rules: /{coll} rules missing')
            continue
        b = blk.group(1)
        if "request.resource.data.status == 'pending'" not in b:
            fail(f'firestore.rules: /{coll} must be created as pending')
        if 'noContact(' not in b:
            fail(f'firestore.rules: /{coll} must refuse contact details')
        read = re.search(r'allow read:(.*?);', b, re.S).group(1)
        if 'true' in read:
            fail(f'firestore.rules: /{coll} must not be readable before approval')
    for bad in ('displayName', 'photoURL', "'name'"):
        if bad in src:
            fail(f'{qa}: Q&A must not carry {bad} - no identities on posts')


# -- goals 10-17 decision tools ------------------------------------------------
# The safety-critical lines of each tool, pinned.
def check_goal_tools() -> None:
    pins = [
        ('lib/features/sdg13_climate/climate_tools.dart', [
            ('const reportWindow = Duration(hours: 72);',
             'PMFBY reporting window must be 72 hours'),
            ('const postHarvestDays = 14;',
             'PMFBY post-harvest cover is 14 days'),
            ("if (signs.contains(HeatSign.confused) || signs.contains(HeatSign.collapsed)) {\n    return HeatLevel.stroke;",
             'confusion or collapse must always mean heat stroke'),
            ("phone: '108'", 'heat stroke advice must offer 108'),
        ]),
        ('lib/features/sdg14_ocean/ocean_tools.dart', [
            ('Coast.east => BanWindow(DateTime(year, 4, 15), DateTime(year, 6, 14)),',
             'east coast ban is 15 April - 14 June'),
            ('Coast.west => BanWindow(DateTime(year, 6, 1), DateTime(year, 7, 31)),',
             'west coast ban is 1 June - 31 July'),
        ]),
        ('lib/features/sdg15_land/land_tools.dart', [
            ('final eligible = before2005 && (who == Claimant.stHere || threeGenerations);',
             'FRA eligibility: before 2005, and ST here or 75 years'),
            ('if (!eligible) return [_notEligible];',
             'ineligible must still get an answer'),
        ]),
        ('lib/features/sdg12_consumption/consumption_tools.dart', [
            ('Nutrient.fat: Band(3.0, 17.5),', 'fat thresholds (NHS)'),
            ('Nutrient.saturates: Band(1.5, 5.0),', 'saturates thresholds (NHS)'),
            ('Nutrient.sugars: Band(5.0, 22.5),', 'sugar thresholds (NHS)'),
            ('Nutrient.salt: Band(0.3, 1.5),', 'salt thresholds (NHS)'),
            ('sodiumMg / 1000 * 2.5', 'salt = sodium x 2.5'),
        ]),
        ('lib/features/sdg11_cities/cities_tools.dart', [
            ('if (ownsPucca) return [_ownsPucca];',
             'owning a pucca house must be checked first'),
            ('out.add(_noAgent);', 'every PMAY result must carry the fraud warning'),
        ]),
        ('lib/features/sdg10_equality/equality_tools.dart', [
            ('out.add(_notSureCategory);',
             '"not sure" of category must say to ask before applying'),
            ("phone: '112'", 'atrocity advice must offer 112'),
        ]),
    ]
    for path, items in pins:
        if not os.path.exists(path):
            fail(f'{path}: missing')
            continue
        src = open(path, encoding='utf-8').read()
        for needle, why in items:
            if needle not in src:
                fail(f'{path}: {why}')


# -- the mini-app frame and the issue registry --------------------------------
# From zip 22 every goal draws itself from its issue list. These rules keep
# that single source of truth from quietly growing a second copy.
def check_issues() -> None:
    ids: dict[str, str] = {}
    goal_files = sorted(glob.glob('lib/features/*/issues.dart'))
    if len(goal_files) != 17:
        fail(f'expected 17 issue files, found {len(goal_files)}')
    for f in goal_files:
        src = open(f, encoding='utf-8').read()
        groups = set(re.findall(r"IssueGroup\('([^']+)'", src))
        if not groups:
            fail(f'{f}: no groups declared')
        for m in re.finditer(r"id: '(g\d+i\d+)',\s*\n\s*goal: (\d+),"
                             r"\s*\n\s*group: '([^']+)'", src):
            issue_id, goal, group = m.group(1), m.group(2), m.group(3)
            if issue_id in ids:
                fail(f'{f}: issue id {issue_id} already used in '
                     f'{ids[issue_id]}')
            ids[issue_id] = f
            if not issue_id.startswith(f'g{goal}i'):
                fail(f'{f}: {issue_id} says goal {goal}')
            if group not in groups:
                fail(f'{f}: {issue_id} is in group "{group}", which does '
                     f'not exist in this goal')
        # Every number offered for tap-to-dial must be digits only:
        # anything else silently fails to dial on a real handset.
        for num in re.findall(r"GoalHelpline\('([^']*)'", src):
            if not num.isdigit():
                fail(f'{f}: helpline "{num}" is not digits only')
    if len(ids) < 250:
        fail(f'only {len(ids)} issues registered; expected 250 or more')

    # One route for all seventeen goals.
    router = open('lib/core/router/app_router.dart', encoding='utf-8').read()
    if "'/sdg/:goal'" not in router:
        fail('app_router.dart: the single /sdg/:goal route is missing')
    for n in range(1, 18):
        if f"_contentRoute('/sdg/{n}'" in router:
            fail(f'app_router.dart: /sdg/{n} still has its own route - '
                 'every goal goes through /sdg/:goal now')

    # The weather is shown only where it changes what someone should do.
    app = open('lib/core/widgets/goal_app.dart', encoding='utf-8').read()
    if 'const [3, 8, 13].contains(goal)' not in app:
        fail('goal_app.dart: the heat warning must stay limited to the '
             'goals it bears on')

    # A latin letter inside a Devanagari word means a typo that renders as
    # a broken word on the device ('मृत्यu'). Caught here because it reads
    # fine in a diff.
    for f in DART:
        raw = open(f, encoding='utf-8').read()
        # Blank out what legitimately puts latin next to Devanagari: escape
        # sequences and interpolated values. Keep the newlines so the line
        # numbers still point at the right place.
        body = re.sub(r'\$\{[^}]*\}|\$\w+|\\[a-z]', ' ', raw)
        # The danda (U+0964) and double danda are punctuation, not letters,
        # so they end a word the way a full stop does. Without this, a unit
        # or an acronym written before a Hindi full stop - 'VA\u0964', 'ORS\u0964' -
        # reads as a latin letter glued to Devanagari and trips the rule.
        body = body.replace('\u0964', ' ').replace('\u0965', ' ')
        for m in re.finditer(r'[\u0900-\u097F][A-Za-z]|[A-Za-z][\u0900-\u097F]',
                             body):
            ln = body[:m.start()].count('\n') + 1
            fail(f'{f}:{ln}: latin letter inside a Devanagari word '
                 f'({m.group(0)!r}) - a typo')

    # The place is never replaced once the user has picked it themselves.
    svc = open('lib/core/place/place_service.dart', encoding='utf-8').read()
    if 'if (place == null || !place.chosen)' not in svc:
        fail('place_service.dart: a guess must never overwrite the place '
             'the user chose')



def check_string_literals() -> None:
    """Catch a single-quoted string that is left open at end of line.

    Dart's one-quote strings may not span lines, so an unclosed one is a
    syntax error - and the analyzer reports it as dozens of nonsense errors
    about "illegal character" on whatever text followed, pages away from
    the quote that actually went missing. The generator that writes the
    issue files once broke a line in the middle of a literal, and this is
    the check that would have caught it before the zip went out.

    The scanner understands what a naive quote count cannot: escapes, raw
    strings, triple-quoted strings that are allowed to span lines, and
    `${...}` interpolation, which may itself contain quoted strings.
    """
    for f in DART:
        src = open(f, encoding='utf-8').read()
        # stack entries are the quote of each string we are inside, with
        # interpolations in between; [] means we are in ordinary code.
        stack: list[tuple[str, bool]] = []  # (quote, is_raw)
        depth: list[int] = []  # brace depth of each open interpolation
        line = 1
        i, n = 0, len(src)
        in_block_comment = False
        while i < n:
            c = src[i]
            if c == '\n':
                line += 1
                if stack and len(stack[-1][0]) == 1 and len(stack) > len(depth):
                    fail(f'{f}:{line - 1}: a string literal is still open at '
                         f'the end of this line. A one-quote Dart string may '
                         f'not span lines - close it, or break the line '
                         f'somewhere outside the quotes')
                    break
                i += 1
                continue
            if in_block_comment:
                if src[i:i + 2] == '*/':
                    in_block_comment = False
                    i += 2
                    continue
                i += 1
                continue
            inside_string = len(stack) > len(depth)
            if inside_string:
                quote, raw = stack[-1]
                if not raw and c == '\\':
                    i += 2
                    continue
                if not raw and src[i:i + 2] == '${':
                    depth.append(0)
                    i += 2
                    continue
                if src[i:i + len(quote)] == quote:
                    stack.pop()
                    i += len(quote)
                    continue
                i += 1
                continue
            # ordinary code (possibly inside an interpolation)
            if src[i:i + 2] == '//':
                j = src.find('\n', i)
                i = n if j < 0 else j
                continue
            if src[i:i + 2] == '/*':
                in_block_comment = True
                i += 2
                continue
            if c in '\'"':
                raw = i > 0 and src[i - 1] == 'r'
                triple = src[i:i + 3] in ('"""', "'''")
                stack.append((src[i:i + 3] if triple else c, raw))
                i += 3 if triple else 1
                continue
            if depth:
                if c == '{':
                    depth[-1] += 1
                elif c == '}':
                    if depth[-1] == 0:
                        depth.pop()  # back into the string around it
                    else:
                        depth[-1] -= 1
            i += 1


def _call_named_args(src: str, open_paren: int):
    """Named argument labels at the top level of the call at `open_paren`.

    Walks the argument list tracking bracket depth and string state, so a
    `name:` inside a nested call, a map literal or a quoted string is not
    mistaken for an argument of this call. Returns (labels, end_index).
    """
    labels = []
    depth = 0
    quote = None
    i = open_paren
    n = len(src)
    while i < n:
        c = src[i]
        if quote:
            if c == '\\':
                i += 2
                continue
            if src[i:i + len(quote)] == quote:
                i += len(quote)
                quote = None
                continue
            i += 1
            continue
        if c in '\'"':
            quote = src[i:i + 3] if src[i:i + 3] in ('"""', "'''") else c
            i += len(quote)
            continue
        if src[i:i + 2] == '//':
            j = src.find('\n', i)
            i = n if j < 0 else j
            continue
        if c in '([{':
            depth += 1
        elif c in ')]}':
            depth -= 1
            if depth == 0:
                return labels, i
        elif depth == 1:
            m = re.match(r'([A-Za-z_]\w*)\s*:(?!:)', src[i:])
            # a label is preceded by '(' or ',' once whitespace is dropped
            if m:
                before = src[:i].rstrip()
                if before and before[-1] in '(,':
                    labels.append(m.group(1))
                    i += m.end()
                    continue
        i += 1
    return labels, -1


def check_unused_private() -> None:
    """Catch a private top-level declaration nothing in its file uses.

    The analyzer reports these as "the declaration isn't referenced", and
    they accumulate: a constant written for a screen, then inlined into
    the text and forgotten. Privates are file-scoped in Dart, so the file
    is the whole search space, which makes this cheap and exact.
    """
    for f in DART:
        src = open(f, encoding='utf-8').read()
        # Blanking the literals hides `'₹$_sbmGrantRupees'` and
        # `'${_round(va)} VA'`, so the interpolated expressions are added
        # back as searchable text. Without this the rule reports a dozen
        # constants that are used, which is worse than not having the rule.
        interpolated = ' '.join(
            a or b for a, b in re.findall(r'\$\{([^{}]*)\}|\$(\w+)', src))
        body = _blank_literals(src) + '\n' + interpolated
        names = set()
        names |= set(re.findall(r'^(?:const|final)\s+[\w<>,?\s]*?(_\w+)\s*=',
                                body, re.M))
        names |= set(re.findall(r'^(?:class|enum|mixin)\s+(_\w+)', body, re.M))
        # A top-level function only: a type token at column 0, then the
        # name. Allowing leading whitespace here matched usage lines as
        # declarations ('..._picker(hi)') and reported seven names that
        # were in use.
        names |= set(re.findall(r'^(?:[\w<>,?\[\]]+[ \t]+)+(_\w+)[ \t]*\(',
                                body, re.M))
        for name in sorted(names):
            uses = len(re.findall(r'(?<![\w.])' + re.escape(name) + r'\b',
                                  body))
            if uses <= 1:  # the declaration itself
                ln = body[:body.index(name)].count('\n') + 1
                fail(f'{f}:{ln}: {name} is declared and never used. Either '
                     f'use it or take it out - the analyzer reports it')


def check_widget_arguments() -> None:
    """Catch a named argument a project widget does not declare.

    `CopyBlock(title: ...)` when CopyBlock takes only `text` and `note` is
    a compile error, and nothing else in this checker sees it: the import
    resolves, the symbol exists, the parentheses balance. It cost a round
    trip in zip 27 before this rule existed.

    Only classes declared in this project are checked, and only when their
    constructor parameter list is a simple named one. Flutter's own widgets
    are left alone - their parameter lists are not in this repository.
    """
    declared: dict[str, set[str]] = {}
    for f in DART:
        src = open(f, encoding='utf-8').read()
        for m in re.finditer(r'^class (\w+)\b', src, re.M):
            name = m.group(1)
            # the constructor: `const Name({...})` or `Name({...})`
            cm = re.search(r'\n\s*(?:const\s+)?' + re.escape(name) +
                           r'\(\{', src[m.start():])
            if not cm:
                continue
            start = m.start() + cm.end() - 1  # at the '{'
            params, end = _call_named_args(src, start)
            if end < 0:
                continue
            body = src[start:end]
            names = set(re.findall(r'\bthis\.(\w+)', body))
            names |= set(re.findall(r'\bsuper\.(\w+)', body))
            # plainly typed named params: `required String label,`
            names |= set(re.findall(
                r'(?:required\s+)?[\w<>,?\s]*?\b(\w+)\s*(?:=[^,]+)?[,}]',
                body))
            declared.setdefault(name, set()).update(names)

    for f in DART:
        src = open(f, encoding='utf-8').read()
        for m in re.finditer(r'\b([A-Z]\w+)\(', src):
            name = m.group(1)
            if name not in declared:
                continue
            if re.search(r'(?:class|enum)\s+' + re.escape(name) + r'\b',
                         src[max(0, m.start() - 80):m.start() + 1]):
                continue
            labels, end = _call_named_args(src, m.end() - 1)
            if end < 0:
                continue
            unknown = [x for x in labels if x not in declared[name]]
            if unknown:
                ln = src[:m.start()].count('\n') + 1
                fail(f'{f}:{ln}: {name} has no parameter '
                     f'{", ".join(unknown)}. It takes: '
                     f'{", ".join(sorted(x for x in declared[name] if x))}')


def check_interpolation_braces() -> None:
    """Catch `${name}` where `$name` would do.

    `unnecessary_brace_in_string_interps` is on, through
    package:lints/recommended, which package:flutter_lints includes. The
    braces are needed only when the next character could continue the
    identifier - `'${field}Hi'` and `'${uid}_$id'` keep theirs. Anything
    else is an analyzer info, and a hundred of them bury the real errors.
    """
    for f in DART:
        src = open(f, encoding='utf-8').read()
        for m in re.finditer(r'\$\{(\w+)\}(.?)', src):
            nxt = m.group(2)
            if nxt and (nxt.isalnum() or nxt == '_'):
                continue  # the braces are doing work
            ln = src[:m.start()].count('\n') + 1
            fail(f'{f}:{ln}: write $' + m.group(1) + ' rather than ${'
                 + m.group(1) + '} - the braces are unnecessary here and '
                 'the analyzer says so')


def check_icon_names() -> None:
    """Catch a Material icon name that does not exist.

    `Icons.some_name` that is not in Flutter's Icons class is a compile
    error, and it is the kind that cannot be spotted by reading: the names
    are long, inconsistently suffixed (`_outlined`, `_rounded`,
    `_outline`), and a plausible guess is wrong about a third of the time.
    `tools/icon_names.txt` is the list of every IconData declared in
    Flutter's own `material/icons.dart`, so the check is against the real
    thing rather than a guess.

    Refresh the list when the Flutter version moves:
      curl -sS https://raw.githubusercontent.com/flutter/flutter/stable/\\
    packages/flutter/lib/src/material/icons.dart | \\
        grep -oP 'static const IconData \\K\\w+' | sort -u > tools/icon_names.txt
    """
    path = 'tools/icon_names.txt'
    if not os.path.exists(path):
        notes.append('tools/icon_names.txt missing - icon names unchecked')
        return
    valid = set(open(path, encoding='utf-8').read().split())
    if len(valid) < 1000:
        notes.append(f'{path} looks truncated ({len(valid)} names) - '
                     'icon names unchecked')
        return
    for f in DART:
        src = _blank_literals(open(f, encoding='utf-8').read())
        for m in re.finditer(r'\bIcons\.(\w+)', src):
            if m.group(1) not in valid:
                ln = src[:m.start()].count('\n') + 1
                fail(f'{f}:{ln}: Icons.{m.group(1)} does not exist. Check '
                     f'the spelling and the suffix (_outlined / _rounded / '
                     f'_outline) against tools/icon_names.txt')


def main() -> int:
    for fn in (check_delimiters, check_string_literals, check_icon_names,
               check_interpolation_braces, check_widget_arguments,
               check_unused_private,
               check_imports, check_const,
               check_http_bodies, check_slivers, check_json, check_secrets,
               check_regressions, check_i18n, check_water_logic,
               check_bill_logic, check_scheme_logic, check_gitignore,
               check_scoped_names, check_local_refs,
               check_food_board, check_qa, check_goal_tools,
               check_issues):
        fn()

    for n in notes:
        print(f'note: {n}')

    if failures:
        print(f'\nFAILED - {len(failures)} problem(s):\n')
        for f in failures:
            print(f'  {f}')
        return 1

    print(f'\nOK - {len(DART)} Dart files, all checks passed.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
