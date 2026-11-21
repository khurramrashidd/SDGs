#!/usr/bin/env python3
"""Attach built screens to registered issues.

Usage: wire.py <goal> <import,import,...> <"Issue title"=Dart expr> ...

Each issue is found by its exact English title inside that goal's GOALS
block, and its trailing `None` (meaning "no screen yet") is replaced with
the Dart expression that opens the screen. Imports are merged into the
goal's import list and kept sorted, so the generated file's imports stay
stable between runs.

This exists because the same four-step edit - add imports, find the issue,
replace the None, regenerate - was being done by hand for every goal, and
a hand edit that silently matches nothing is the failure mode that ships a
goal with half its screens unreachable. This asserts on every miss.
"""
import re
import sys


def wire(goal, imports, mapping):
    for path in ('tools/issues_a.py', 'tools/issues_b.py', 'tools/issues_c.py'):
        src = open(path, encoding='utf-8').read()
        key = 'GOALS[%d] = dict(' % goal
        if key not in src:
            continue
        start = src.index(key)
        nxt = [src.index('GOALS[%d] = dict(' % g)
               for g in range(goal + 1, 18)
               if 'GOALS[%d] = dict(' % g in src]
        end = min(nxt) if nxt else len(src)
        blk = src[start:end]

        m = re.search(r'imports=\[(.*?)\],\n', blk, re.S)
        if not m:
            raise SystemExit('goal %d: no imports list found' % goal)
        existing = re.findall(r'"([^"]+)"', m.group(1))
        allimp = sorted(set(existing) | set(imports))
        new = ('imports=[' +
               ',\n             '.join('"%s"' % i for i in allimp) + '],\n')
        blk = blk[:m.start()] + new + blk[m.end():]

        done = 0
        for title, expr in mapping.items():
            lit = "'" + title.replace("'", "\\'") + "'"
            if lit not in blk:
                lit = '"' + title + '"'
            if lit not in blk:
                raise SystemExit('goal %d: no issue titled %r' % (goal, title))
            i = blk.index(lit)
            j = blk.index('None),', i)
            blk = blk[:j] + "'" + expr + "'" + blk[j + 4:]
            done += 1

        open(path, 'w', encoding='utf-8').write(src[:start] + blk + src[end:])
        print('goal %d: wired %d screens in %s' % (goal, done, path))
        return
    raise SystemExit('goal %d not found in any issues file' % goal)
