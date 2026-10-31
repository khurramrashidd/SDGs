# Local changes that must survive every zip

This file is the running record of edits made on your machine that are **not**
in the files I send. Before copying a new zip over the project, check this
list. After copying, re-check it.

I keep this updated. If something here gets clobbered again, it is my bug.

---

## Files I ship — never hand-edit these

Copying a zip overwrites them. If you need a change in one, tell me and I will
put it in the next zip instead.

```
lib/**            assets/**         brand/**        _icons/**
web_template/**   proxy/**          pubspec.yaml    firebase.json
firestore.rules   firestore.indexes.json            analysis_options.yaml
README.md         SETUP.md          BRANDING.md     LOCAL_CHANGES.md
install_icons.bat
```

## Files I never ship — your edits here are safe

```
android/**        ios/**        web/**        test/**
lib/firebase_options.dart       .gitignore
```

One exception: `install_icons.bat` writes into `android/app/src/main/res/`
and `web/`, but only icon files, the manifest and `index.html`.

---

## Changes made so far

### 1. `android/gradle.properties` — Kotlin incremental compilation off

```properties
kotlin.incremental=false
```

**Why:** the project is on `F:` but the Dart package cache is on `C:`.
Kotlin's incremental compiler tries to build a relative path between the two,
Windows cannot make one across drive letters, and the build dies with
`this and base files have different roots`.

**If this goes missing:** `flutter run` fails with a long Kotlin daemon stack
trace mentioning `Could not close incremental caches`.

---

### 2. `android/app/build.gradle.kts` — minSdk 23

```kotlin
defaultConfig {
    minSdk = 23
}
```

**Why:** `firebase_auth` requires API 23. The failure message does not mention
minSdk, so this one is expensive to rediscover.

---

### 3. `test/widget_test.dart` — deleted

**Why:** `flutter create` generates it for the default counter app and imports
`package:sdgapp/main.dart`. Our package is `sdg_app`, so the import was never
valid, and it tests a screen that no longer exists.

**Do not run `dart fix --apply` while that file exists.** It "fixes" the bad
import by adding `sdgapp: any` to `pubspec.yaml` — a package that does not
exist on pub.dev — and then nothing resolves.

---

### 4. `pubspec.yaml` — intl version

`intl` is now `^0.20.3`, matching your Flutter SDK.

**This one was my fault.** You fixed it locally, then I shipped a zip with the
old `^0.19.0` and undid it. It is corrected at source now, so future zips carry
the right value.

**If it comes back:** the error names the version it wants
(`flutter_localizations from sdk ... depends on intl ^x.y.z`). Put that
version in `pubspec.yaml`. Only `DateFormat` is used from `intl`, and it is
unchanged across these versions.

---

### 5. Compile error I shipped in zip 4 — fixed

`send_notice_page.dart` would not compile:

```
The argument type 'String' can't be assigned to the parameter type 'Widget'.
```

**Cause, in full:** when adding the responsive layout I ran a bulk edit that
wrapped every Scaffold `body:` in a `ContentShell`. That file also contains an
`http.post(... body: jsonEncode({...}))` — the same keyword, a completely
different meaning. The script wrapped the JSON payload of the push request in
a layout widget. The same pass also wrapped the wrong `body:` in
`account_page.dart` and `admin_home_page.dart` (their early-return loading
screens rather than the real content), which compiled but left the main
content uncapped on wide screens.

All three are fixed, and the detail pages that the pass missed are now wrapped
too.

A follow-up zip then shipped two *further* syntax errors from the same repair
— in `schemes_page.dart` and `scholarships_page.dart` a closing bracket landed
after the `;` instead of before it:

```dart
      ),
    );      <- statement ends here
      ),    <- but Scaffold( is still open
```

My first validator passed this, because every bracket does match its partner
and the counts are equal. It is still invalid Dart. The validator now also
checks **statement termination**: a `;` found while an expression is still
open is an error, with `for (;;)` excluded. Verified against the exact failing
line Flutter reported.

**What stops it recurring:** `tools/validate.py`, included in the project.
It parses every Dart file ignoring strings and comments, and specifically
rejects a widget passed as an HTTP body. I run it before packaging any zip.
You can run it too:

```
python tools/validate.py
```

It also catches unbalanced delimiters, broken or unused imports, `const`
constructors holding runtime values, malformed JSON, committed API keys, and
the two dependency regressions listed above. It needs only Python — no Flutter
SDK — so it takes about a second.

It does not replace `flutter analyze`; it catches the things that have gone
wrong here specifically.

### Runtime crash on the home screen — fixed

The app built and installed, then died on first paint:

```
A RenderViewport expected a child of type RenderSliver but received a
child of type _RenderLayoutBuilder   →  AdaptiveGrid, home_page.dart:95
```

**Cause:** Flutter has two layout protocols. A `CustomScrollView.slivers`
list accepts only slivers. My `AdaptiveGrid` had a `sliver: true` flag, but it
wrapped *both* cases in a `LayoutBuilder`, which is a box widget. Nothing
catches that at compile time, because everything is just a `Widget` — it only
fails when the render tree is built.

**Fix, and why it is a design change rather than a patch:** there are now two
widgets, `AdaptiveGrid` (box) and `AdaptiveSliverGrid` (sliver, built on
`SliverLayoutBuilder`). A boolean that silently switches layout protocol is a
trap; a name is not. The validator now also rejects any non-sliver widget
placed directly in a `slivers:` list, which it can only do because the two
cases have different names.

---

**On the two "committed API key" warnings** you saw in `google-services.json`
and `firebase_options.dart`: those were false positives, now fixed. Both files
contain an `AIza...` Firebase Web API key **by design**. That key identifies
your project; it does not authorise anything on its own. It ships inside every
Firebase app and is readable in any APK — which is the whole reason provider
keys live on the Render proxy instead. Your Firestore rules are what protect
the data.

The scanner now skips those three generated config files and still flags a
real provider key anywhere else.

---

### Two bugs the validator could not have caught, and now can (zip 15)

Both came from the multilingual work and neither is a compile error, so
without a device they are invisible:

1. **`_SDelegate.load` was `async`.** An `async` method always returns a real
   `Future`, even when its body awaits nothing. `Localizations.override` —
   the mechanism behind the per-section language switch — renders an empty
   frame while any delegate is still pending, so every language change
   flashed blank. It now returns `SynchronousFuture`, and the validator
   rejects the `async` form.

2. **A method named `set`.** `static void set(...)` does not parse: after a
   return type, Dart reads `set` as the beginning of a setter declaration
   and then fails on the `(`. The error surfaces lines away from the cause.
   Renamed to `setLanguage`, and the validator now rejects `set`, `get` and
   `operator` as method names.

The validator also now checks that every language has the same keys as
English, that no language is offered without a string table, that no
language code outside `flutter_localizations` is used, and that no file
contains a U+FFFD replacement character — one Punjabi string had picked one
up and would have shown a black diamond on your screen.

---

### The build break in zips 15 and 16, and why my checker missed it

Three compile errors, one cause: `undefined_identifier: 'hi'` in the
`_GuideCard` widgets of `justice_home_page.dart` and `work_home_page.dart`.

**What I did.** When those cards moved to the new language lookup, `hi`
stopped being needed at the top of the class, so I removed the field. It was
still used further down the same class — in the "Official portal" button and
the unverified note.

**Why I did not catch it.** I checked for leftover uses with
`awk '/class _GuideCard/,/^}/'`. That range ends at the first line starting
with `}`, which came well before the end of the class, so I read about a
third of it and concluded `hi` was unused. The count it printed was `1`, and
I read that as "just the declaration" rather than asking which line it was.

**Why the validator did not catch it either.** It had no notion of whether
an identifier resolves. It checked brackets, statement termination, imports,
JSON and specific past regressions — not scope.

**What now exists.** `tools/validate.py` rejects `hi`, `_hi` or `lang` used
in a class that declares none of them. It is deliberately narrow: it checks
only the locale names this project binds per-build, which is where the
refactors happen. I tested it by recreating this exact bug, and it reports
the same two lines Flutter reported.

While writing it I found **two more holes that had been silently open**:

* The **unused-import check had never once fired**. `declared_symbols` was
  collecting `if` as a symbol of every file — a loose `type name(` pattern
  matching control flow — and because `if` appears in all Dart code, every
  import matched something and looked used. Fixed by excluding keywords and
  private names; it then immediately found a real unused import in
  `home_page.dart`.
* The **const check only looked at public widgets** (`const Foo(`), never
  private ones (`const _Foo(`), which is where the mistake gets made. It
  also had no idea that a closure cannot be const. I hit that myself in this
  same round, adding `const` to a `_Row` that takes an `onTap`; the new rule
  caught it before it reached you.

**The limit, stated plainly.** `tools/validate.py` is not a Dart compiler and
cannot become one — there is no Dart SDK where I build these, so I cannot
resolve types or names the way the analyzer does. It catches the specific
mistakes that have gone wrong here. Keep running `flutter analyze` before
`flutter run`; it is the only thing that sees the whole picture, and in this
case it named all three errors in seconds.

---

### 6. `lib/firebase_options.dart` — generated, never shipped

Created by `flutterfire configure` for project `ibtidaasdg`. It holds your
project's config, so it is specific to your machine and account.

**If it goes missing:** `Target of URI doesn't exist: 'firebase_options.dart'`.
Re-run `flutterfire configure`.

---

## Safe update procedure

1. Copy the new zip's folders over the project, replacing files.
2. `flutter pub get`
3. `flutter run`

If step 2 or 3 fails, check this list first — it is almost always one of the
five items above.
