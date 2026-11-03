# Zip history

Every package sent, newest first. Filenames carry their contents so an old
download is identifiable without opening it.

Naming: `sdg_app_zipNN_what-changed.zip`

---

## zip 24 — `sdg_app_zip24_all-17-goals.zip`
**2 Nov 2026**

**All 17 goals are now built.** Deploy rules again (new `corrections`):
`firebase deploy --only firestore:rules`

- **SDG 12 — Responsible Consumption.** *Check a label* — type fat,
  saturated fat, sugar, salt (per 100 g, or per serving + serving size;
  sodium in mg converted) → low / medium / high, using the NHS
  traffic-light thresholds, clearly labelled as a comparison guide. Guides:
  Right to Repair portal, warranty complaints (1915), e-waste rules,
  banned single-use plastics (corrected against CPCB's own release).
- **SDG 14 — Life Below Water.** *Is the fishing ban on today?* — east
  coast 15 Apr–14 Jun, west coast 1 Jun–31 Jul (61 days, MPEDA), with days
  left or days until it starts, and the state-waters caveat. Guides: Coast
  Guard 1554, INCOIS forecasts and fishing-zone advisories, PMMSY support
  during the ban, reporting oil/dead fish, CRZ violations.
- **SDG 15 — Life on Land.** *Forest rights check* — ST / other forest
  dweller, before 13 Dec 2005, 75 years → individual (Form A), community
  (Form B), community forest resource (Form C), the evidence that counts,
  and the 60-day appeal. Guides: wildlife conflict and compensation (Rs 10
  lakh central guideline for a death), snakebite first aid, Soil Health
  Card and how to read it.
- **SDG 17 — Partnerships.** *Send a correction* — any user can point out a
  wrong number or dead link; it lands in Admin → Moderation → Corrections.
  *What this app keeps* — on the phone, on the server, AI questions, what
  we never do, how sure the information is.
- Home screen: every tile is live.
- Validator: fishing-ban dates, FRA eligibility, label thresholds pinned.

---

## zip 23 — `sdg_app_zip23_sdg10-11-13.zip`
**2 Nov 2026**

Three new goals, each with a working tool. **13 of 17 goals built.**

- **SDG 10 — Reduced Inequalities.** *Which certificate do you need?* —
  purpose, category, income, disability → the exact papers (caste, OBC
  non-creamy layer, EWS with its asset tests, income, domicile, UDID) and
  where to get them. *Where to complain* — caste violence, exclusion,
  reservation denied, disability, religion, women, police abuse → police
  FIR / NCSC / NCST / NCBC / disability commissioner / NCM / NCW / NHRC, in
  order. Guides: disability rights, reservation in plain words.
- **SDG 11 — Sustainable Cities.** *Street complaint writer* — pick the
  problem, type the place, copy a ready complaint, then a 4-step escalation
  ladder (complaint number → commissioner/BDO → state grievance portal →
  RTI). *PM Awas checker* — urban/rural, pucca house, income, build/buy/
  rent → BLC, AHP, interest subsidy (4%, up to Rs 1.80 lakh), rental, or
  PMAY-G, always with the fraud warning. Guides: mutation, tax receipts,
  flood, earthquake, lightning.
- **SDG 13 — Climate Action.** *Heat illness check* — tick signs →
  heat stroke (call 108, cool fast) vs exhaustion vs early signs.
  *Crop loss clock* — PMFBY's 72-hour reporting deadline computed from the
  damage time, and the 14-day post-harvest cover checked; how to report
  (14447). Guides: IMD warning colours, Sachet/Damini/Meghdoot/Mausam apps,
  heat-wave safety for workers and older people.
- Titles and descriptions for goals 10–15 and 17 in all 14 languages.
- New shared widgets: `module_hub.dart` (hub, hero, rows, tool screen,
  answer list) and `core/sdg/advice.dart`.
- Validator: safety lines of the three tools pinned (e.g. confusion or
  collapse always means heat stroke; PMAY result always carries the fraud
  warning).

---

## zip 22 — `sdg_app_zip22_food-board-study-qa.zip`
**2 Nov 2026**

**Deploy the rules and indexes after copying:**
`firebase deploy --only firestore:rules,firestore:indexes`
Without the rules, posting and claiming are refused; without the indexes, the
Q&A list shows an error for a few minutes while Firebase builds them.

- **SDG 2 — Food board** (the core of your old food-sharing app, built the
  safe way you chose). Post only from a passing "Can this be shared?" check;
  the listing disappears when the food stops being safe (cooked: ≤3 h);
  sign-in to post or claim; the public post has only a locality — phone and
  pickup details show only to the one person who claims; claim is
  first-come via a transaction; poster can reopen a no-show or close; any
  signed-in user can report, 3 reports hide a post.
- **SDG 4 — Study questions**, moderated, no DMs. Nothing appears until an
  admin approves it. No names on posts ("a student", "a helper"). Phone
  numbers, links, emails and @handles refused — in the app and again in the
  rules. Report button on every question and answer.
- **Admin → Moderation**: Q&A approval queue, Q&A reports, reported food
  posts.
- Firestore rules: `foodBoard` (+ private contact, reports), `qa`,
  `qaAnswers`, `qaReports`. Two composite indexes.
- Validator: food board and Q&A safety rules pinned (contact privacy, time
  cap, pending-before-visible, app/rules pattern equality); nullable-return
  functions now recognised.
- Everything from zips 20 and 21 carried.

---

## zip 21 — `sdg_app_zip21_sdg3-reminders-dailylog.zip`
**2 Nov 2026**

**Needs two one-time edits under `android/` before it builds — LOCAL_CHANGES.md #7.**

- **SDG 3 — Medicine reminders.** Real phone notifications, daily, at the
  time the doctor said. The app never suggests a medicine or dose. Up to 20.
  Survives restarts. Android only; the website says so.
- **SDG 3 — Daily log.** Water, steps (typed in), active minutes; last 7
  days. No calorie or weight targets, on purpose. Phone only, 60 days kept.
- **SDG 3 — Leftover medicines.** Safe disposal, the strong-painkiller
  exception, and why not to pass medicines on (your answer: guide instead
  of donation).
- New packages: `flutter_local_notifications` ^19.4.0 (held below 20 so it
  works on your Flutter), `timezone`.
- Validator: new check — any `...Page`, `...Store`, `...Service` used in a
  file must be declared or imported there. It caught a missing import in
  this very zip before it shipped.
- Everything from zip 20 carried, `.gitignore` included.

---

## zip 20 — `sdg_app_zip20_parity-health-learning.zip`
**2 Nov 2026**

Feature parity with your five Render apps. See the parity table in STATUS.md.

- **SDG 3 — My child's vaccines.** Add a child by birth date; every dose
  gets its due date; tick off what is done. Stored on the phone only.
  Never says "late" — a missed dose says "go anyway".
- **SDG 3 — Free and cheaper care.** eSanjeevani (free doctor by video),
  Ayushman Arogya Mandir, PM-JAY Rs 5 lakh cover incl. everyone 70+,
  Jan Aushadhi. Tap-to-dial 14555.
- **SDG 4 — new home screen.** Scholarships stay first. Added: free learning
  by class level (DIKSHA, NCERT, PM eVIDYA, SWAYAM, NIOS, NDL) with subject
  search and language links; practice quiz (six subjects); literacy rates
  for India and neighbours, women and men side by side.
- **SDG 5 — Health and wellbeing.** Matru Vandana cash, free delivery under
  JSSK, anaemia, cancer screening, Tele-MANAS 14416. Plus "Money to start a
  business", opening the SDG 9 loan matcher.
- **New shared widget** `lib/core/widgets/guide_list_page.dart` (with
  tap-to-dial), used by SDG 3 and 5.
- **`fixes/5_EmpowHer/`** — corrected `app.py` for your EmpowHer Render app:
  key read from `GEMINI_API_KEY`, length and rate limits on every AI route.
  Not part of the Flutter app. Revoke the old key first.
- Validator: guide-set rules for the new datasets, learning `levels`,
  vaccination offsets.
- `.gitignore` carried.

---

## .gitignore — rewritten 31 Oct 2026

Sent on its own, and carried in zip 20 onward.

- **Release signing added, which was the serious omission.** `*.jks`,
  `*.keystore` and `key.properties` were not ignored. Committing a keystore
  to a public repo cannot be undone — git keeps history, and anyone holding
  it can sign an app as Ibtidaa Tech that Play Store accepts as an update
  to yours. Losing it is the mirror disaster: no update is possible ever
  again, only a new package name.
- Android `local.properties` and `.gradle/`, iOS and macOS Pods and Xcode
  user data, `node_modules/`, release `.apk`/`.aab` artefacts, editor and
  OS files.
- `pubspec.lock` and `.metadata` stay committed on purpose, with the reason
  in a comment — the lock file is what keeps the `intl` version from
  drifting again.
- `gradle.properties` stays committed too, because it carries the
  `kotlin.incremental=false` line this project needs on Windows.
- Validator now refuses to pass a project whose `.gitignore` has lost the
  keystore, `key.properties` or `.env` rules, or that has started ignoring
  `pubspec.lock`.
- **Fixed a documentation bug:** `LOCAL_CHANGES.md` listed `.gitignore`
  among the files I never ship. It has in fact been in every zip since 28
  October, so a zip would have silently overwritten any edit made to it.

## zip 19 — `sdg_app_zip19_sdg9-enterprise-schemes.zip`
**31 Oct 2026**

- **SDG 9 — Industry & Enterprise**, now live. **10 of 17 goals built.**
- **"Which scheme should I ask about?"** — five questions, routed across
  Mudra, PMEGP, PM SVANidhi and Stand-Up India. The gap here is not
  information, it is navigation: PMEGP pays a 15–35% subsidy but refuses a
  running unit, Mudra takes a running unit but stops at ten lakh, Stand-Up
  India starts above that for SC/ST and women founders only, SVANidhi is
  street vendors alone. Someone can walk past a grant they qualified for
  because nobody told them the word for it.
- The matcher names what you are **not** eligible for, and why. Dropping a
  scheme silently leaves someone who heard of it from a neighbour assuming
  the app missed it — and going to an agent who tells them what they want
  to hear.
- Two flaws found by enumerating all 192 input combinations before writing
  any UI: a street vendor asking for several lakh was being led with a
  ₹50,000 scheme, and 18 combinations matched nothing at all, leaving a
  blank screen where the ordinary MSME term-loan route applies. Both fixed,
  and the validator now guards against the blank result returning.
- **"This is not an approval"** sits on the results screen, with the
  advance-fee fraud named: no agent, consultant or middleman has the power
  to sanction anything, so a fee taken up front for a guaranteed loan is
  charged for something they cannot deliver. The validator rejects the page
  if that warning disappears.
- 14 guides: Udyam registration is free and the ministry states only one
  site is official, the MSME limits revised from 1 April 2025, the four
  schemes in plain terms, Jan Samarth as one window, what a bank actually
  looks at, writing your own project report instead of paying for one, UPI
  at the counter and ONDC.
- **Two figures deliberately left out.** The PMEGP project-cost ceiling:
  the official guidelines PDF says ₹25 lakh while recent sources say ₹50
  lakh, so the card states no number and points to the KVIC portal. And UPI
  merchant charges: zero since January 2020, a 0.4% charge announced for
  October 2026, deferred by NPCI, now under Supreme Court challenge — the
  card says exactly that instead of picking a side.
- Three content sources corrected mid-build, where a card's claim was not
  in the page it linked to.
- Validator gained 3 SDG 9 rules; the guide-dataset check now covers three
  goals through one shared rule.

## zip 18 — `sdg_app_zip18_sdg7-energy-billcheck.zip`
**31 Oct 2026**

- **SDG 7 — Affordable Energy**, now live. **9 of 17 goals built.**
- **"Is my bill right?"** — enter the two readings and the units billed,
  and it does the subtraction. Both numbers are printed on the same bill,
  so a mismatch is the one billing error anyone can prove standing at the
  counter, in any state, with no knowledge of tariffs.
- Findings are split into provable and worth-asking, and shown differently.
  A reading mismatch, a reading that went backwards, and an "estimated"
  bill are decisive. An odd-looking per-unit figure is phrased as a
  question, because fixed charges, arrears and a long billing period all
  explain it innocently.
- No rate check at all below 50 units: a household on 20 units with a ₹120
  fixed charge pays an effective ₹10/unit and nothing is wrong. Flagging
  that would send someone to argue a correct bill and spend the
  credibility they need at that office later.
- Copies a complaint draft with the arithmetic already filled in. Nothing
  typed leaves the device.
- The tool never says the bill is correct and never says you were
  overcharged. It checks arithmetic, not tariff, and the validator now
  rejects any user-facing string that claims either.
- 13 guides, each sourced: no connection without a meter and the 45-day
  grievance limit under the Electricity (Rights of Consumers) Rules 2020,
  the 7/15/30-day connection timelines, automatic compensation, how slabs
  and fixed charges work, the company → forum → ombudsman route, PM Surya
  Ghar subsidy bands and what to settle before paying a vendor, the
  Ujjwala ₹300 transfer and how to check it reached your account, WHO
  figures on cooking smoke, and LPG safety taken from the official PMUY
  consumer guidance.
- **Deliberately not built: a solar payback calculator.** Size and payback
  turn on installed cost per kW, state tariff, net-metering rules and the
  current subsidy, all of which move. On a one-to-two lakh decision a
  confident wrong number is worse than none, so the module explains the
  scheme and sends you to the portal.
- The Ujjwala card gives **no current refill count** on purpose. It has
  been 12, then 9, and was reported in mid-2026 as cut again. The card
  explains the mechanism and tells the reader to check their own bank
  credits, which is the only answer that stays true.
- Validator gained 4 SDG 7 rules and now checks both guide datasets through
  one shared rule rather than a copy per goal.

## zip 17 — `sdg_app_zip17_fix-undefined-hi.zip`
**31 Oct 2026**

Fixes the build break in zips 15 and 16. No new features.

- **Fixed: 3 compile errors.** `_GuideCard` in the SDG 16 and SDG 8 pages
  used `hi` after I removed the field that declared it. Both now derive it
  from the section language inside `build`, where `lang` already was.
- Fixed: unused `auth` local and its import in `home_page.dart` — the
  warning in your analyze output.
- Fixed: 6 of the 14 `prefer_const_constructors` hints in `about_page.dart`.
  The other 8 are left alone on purpose: those widgets take `onTap`
  closures, and a closure is not a constant expression, so adding `const`
  there does not compile. I tried it, caught it before shipping, and added
  a validator rule for it.
- **Validator: 3 real holes closed.**
  - It now rejects a locale name (`hi`, `lang`) used where nothing in the
    class declares it. This is the check that was missing — tested against
    the exact bug, and it reports the same two lines Flutter did.
  - The unused-import check had never fired on anything. It collected `if`
    as a declared symbol of every file, and since `if` appears in all Dart
    code, every import matched something. With that fixed it immediately
    found the real unused import above.
  - `const` holding a closure is now rejected, and the const check now
    looks at private widgets (`const _Foo(`) too, which it never had.

## zip 16 — `sdg_app_zip16_sdg6-clean-water.zip`
**30 Oct 2026**

- **SDG 6 — Clean Water**, now live. **8 of 17 goals built.**
- **"Is my water safe?"** — six questions, and unlike the other checkers it
  tracks two risks separately rather than scoring one. A germ problem and a
  chemical problem need opposite responses, and in India the universal
  advice — boil it — is correct for the first and useless for the second.
- Boiling removes no chemicals. Arsenic is invisible, odourless and
  tasteless, and the harm takes 5-10 years to show, so someone boiling
  faithfully in an affected belt gets no signal that it is not working.
  When the verdict is chemical, the screen says this before anything else.
- Handles the specific trap where water "was tested and was fine": the
  routine village field kit checks nine parameters and arsenic is not one
  of them, so a clear result in an arsenic area may never have looked.
- Iron gets its own calmer verdict. Treating a staining problem in the
  language reserved for arsenic is how people learn to ignore warnings.
- The tool never says your water is safe. It has no way to know, and the
  most positive verdict available says exactly that.
- 14 guides — the free village test and how to ask for it, what each
  treatment method does and does not remove, arsenic and fluoride, source
  and storage protection, the 55 lpcd JJM entitlement, and the complaint
  route from Gram Panchayat to CPGRAMS. Every card carries its government
  source and ships unverified.
- All 14 interface languages carry the new goal title.
- Validator gained 4 SDG 6 rules, including the one that matters: a
  chemical verdict may never contain a step telling the user to boil, and
  the microbial verdict must still contain one.
- Fixed before shipping: answering "yes — iron" fell through to the
  "never been tested" verdict, contradicting what the user had just said.

## zip 15 — `sdg_app_zip15_14-languages-section-switch.zip`
**30 Oct 2026**

- **14 languages in the interface** — English, हिन्दी, বাংলা, मराठी, తెలుగు,
  தமிழ், ગુજરાતી, اردو, ಕನ್ನಡ, ଓଡ଼ିଆ, മലയാളം, ਪੰਜਾਬੀ, অসমীয়া, नेपाली.
  69 strings each, complete parity, every language shown in its own script.
- **Per-section language switch** — a button on every content screen reads
  that one screen in another language and leaves the app language alone.
  19 screens. Not persisted, because "temporary" has to mean temporary.
- Urdu brings right-to-left; Flutter handles the direction from the locale.
- **Admin → Translate content** — add any language to any record, with the
  English original beside the box and progress counts per language and per
  dataset. Goes live without an app release.
- Content records gained an `i18n` map, so a record can carry any number of
  languages without a schema change or a field per language.
- Honest on-screen note when a screen has no text in the chosen language,
  rather than translated buttons implying translated articles.
- Fixed: the localisation delegate returned a real `Future`, which made
  every section language change flash a blank frame. Now synchronous.
- Fixed: the picker read the locale from inside its own override, so it
  reported the section language as the app language.
- Fixed: a method named `set` — Dart reads that as a setter declaration and
  will not parse it.
- Validator gained 7 checks: language key parity, unreachable or
  Flutter-unsupported language codes, the synchronous-delegate requirement,
  corrupted (U+FFFD) text, the bool→language-code accessor change, and
  `set`/`get`/`operator` used as method names.
- **Content stays English and Hindi.** The ~295 content strings are health,
  legal and food-safety claims; machine-translating those into languages
  nobody here reads is the one part of this request I did not do. Reasoning
  in `STATUS.md` and in `translations_page.dart`.

## zip 14 — `sdg_app_zip14_sdg8-work-jobscams.zip`
**30 Oct 2026**

- **SDG 8 — Decent Work**, now live
- **"Is this job real?"** — 10 scored red flags with a verdict. Asking for
  money, promising a government job, or wanting your OTP are decisive on
  their own; weaker signs accumulate.
- Straight through to 1930 and cybercrime.gov.in when it looks like fraud
- 10 work-rights guides: MGNREGA work demand and the dated receipt, the
  15-day rule, unemployment allowance, late-wage compensation, the 5 km
  rule, e-Shram registration, payslips, minimum wage, free skill training
- MGNREGA 1800-111-555 and National Career Service 14434, one tap
- **7 of 17 goals now built**

## zip 13 — `sdg_app_zip13_sdg16-rti-justice.zip`
**30 Oct 2026**

- **SDG 16 — Peace & Justice**, now live on the home grid
- **RTI application builder** — fill in the office, your questions, your
  details, and get a correctly formatted application to copy, post or paste
  into rtionline.gov.in. Nothing typed is uploaded.
- 11 civic guides: RTI timelines and both appeals, FIR and Zero FIR, rights
  on arrest, free legal aid, Lok Adalat, CPGRAMS, corruption reporting
- NALSA 15100 one-tap dial
- Editable from Admin → Edit content
- This CHANGELOG, and descriptive zip filenames from here on

## zip 12 — `sdg_app_zip12_sdg2-food-sharing.zip`
**30 Oct 2026**

- **SDG 2 — Zero Hunger**, completing all five original goals
- "Can this food be shared?" — guided safety check with a real verdict
- 9 FSSAI-sourced food safety rules, 8 household waste tips
- Routes donors to the official FSSAI Save Food Share Food network
- Collection-organisation directory ships empty by design, admin-filled
- The 12 locked tiles now open and show their planned features

## zip 11 — `sdg_app_zip11_sdg3-health.zip`
**30 Oct 2026**

- **SDG 3 — Good Health**
- 16 myth-vs-fact cards, English and Hindi, every one sourced
- One-tap copy for sharing on WhatsApp
- Full national immunisation schedule, birth to 16 years plus pregnancy
- 6 health helplines including Tele-MANAS
- No symptom checker, stated plainly in the app

## zip 10 — `sdg_app_zip10_admin-drawers-about.zip`
**29 Oct 2026**

- Master admin `free.timesenjoy@gmail.com`, enforced in Firestore rules
- Admin roles, promotion, and transferable ownership with a recovery account
- **Content editor** — fix any broken link or record from phone or web
- Left drawer: profile, navigation, admin panel, sign out
- Right panel: theme, language, text size, accent, recent notices
- About page, Terms & Conditions, Privacy Policy
- Fixed: two Firestore rules bugs — reports would have been world-readable,
  and `lower()` is a method not a function

## zip 9 — `sdg_app_zip9_sdg5-empowher.zip`
**29 Oct 2026**

- **SDG 5 — Gender Equality**
- One-tap 181 and 112, 7 national helplines, quick-exit button
- Abuse reporting with three modes, the user chooses what is stored
- Firestore rules: reports are write-only, nobody can read them back
- 9 legal rights in plain English and Hindi
- AI career guidance, business ideas, course finder
- 21 Indian women, described by what they did

## zip 8 — `sdg_app_zip8_fix-sliver-crash.zip`
**29 Oct 2026**

- Fixed the home-screen crash: `AdaptiveGrid` split into box and sliver
  versions, because a `sliver: true` flag that silently switched layout
  protocol was the root cause
- Validator now rejects a non-sliver widget in a `slivers:` list

## zip 7 — `sdg_app_zip7_fix-syntax.zip`
**29 Oct 2026**

- Fixed two syntax errors from the ContentShell edit
- Validator rewritten: balance alone was not enough, it now checks statement
  termination
- Stopped flagging Firebase config files as committed API keys

## zip 6 — `sdg_app_zip6_fix-http-body.zip`
**29 Oct 2026**

- Fixed a compile error: a bulk edit had wrapped an `http.post` body in a
  layout widget
- Added `tools/validate.py`

## zip 5 — `sdg_app_zip5_fix-intl-pin.zip`
**29 Oct 2026**

- Corrected the `intl` version at source, and added `LOCAL_CHANGES.md` so
  machine-side edits stop being clobbered

## zip 4 — `sdg_app_zip4_branding-responsive.zip`
**29 Oct 2026**

- Logo, app icon, favicons, PWA manifest, branded web loading screen
- Responsive layout from 320dp phones to desktop
- Replaced every `RadioListTile` with a version-proof `SelectionTile`

## zip 3 — `sdg_app_zip3_complete.zip`
**28 Oct 2026**

- Complete project with `firebase.json`, `firestore.indexes.json`, `SETUP.md`

## zips 1–2
**28 Oct 2026**

- App shell, theming, i18n, auth, SDG 1 schemes, SDG 4 scholarships,
  admin scaffold, AI proxy
