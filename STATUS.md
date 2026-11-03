# SDG App — status checklist

Updated every time something ships. `[x]` means working on your device,
not "code written".

**Last updated:** 31 Oct 2026 · after zip 19

Zip history and what each one contained: see `CHANGELOG.md`.

---

## Foundation

- [x] Flutter project builds and runs on device (`com.ibtidaatech.sdgapp`)
- [x] Firebase project connected (`ibtidaasdg`)
- [x] Firestore created, production mode, `asia-south1`
- [x] Authentication enabled — Email/Password + Google
- [x] Storage enabled
- [x] App shell, routing, navigation
- [x] Light / dark / system theme, user-switchable
- [x] 6 accent colours, 4 text sizes, user-switchable
- [x] 14 languages in the interface, switchable in Settings
- [x] Per-section language switch — read one screen in another language
      without changing the app language (19 screens)
- [x] Honest banner when a screen has no text in the chosen language
- [x] Responsive layout, 320dp phone → desktop browser
- [x] Logo, app icon, favicons, PWA manifest, branded web loading screen
- [x] Left drawer — profile, navigation, admin panel, sign out
- [x] Right panel — theme, language, text size, accent, recent notices
- [x] About page — version, contact, legal links, Ibtidaa Tech socials
- [x] Terms & Conditions and Privacy Policy, written against the real code
- [x] `tools/validate.py` pre-ship checker
- [ ] **Firestore rules deployed** — `firebase deploy --only firestore:rules`
- [ ] **Icons installed** — run `install_icons.bat`, then `flutter clean`
- [ ] **SHA-1 fingerprint registered** — Google Sign-In fails silently without it
- [x] Master admin — `free.timesenjoy@gmail.com`, enforced in Firestore rules
- [ ] Real Ibtidaa Tech brand colours (currently my placeholder teal/amber)

---

## Accounts

- [x] Email + password sign-up and sign-in
- [x] Google Sign-In
- [x] Same-Gmail account merge (sign in with password once, both link)
- [x] Forgot password
- [x] Add a password to a Google-only account
- [x] Browse everything without signing in
- [x] Admin / super-admin / master-admin roles, enforced by Firestore rules
- [x] Master admin can promote anyone, and transfer the role onward
- [x] Recovery account cannot be demoted or locked out from inside the app

---

## The 17 goals

| Goal | Module | State |
|---|---|---|
| 1 | No Poverty — government schemes | ✅ working |
| 2 | Zero Hunger — IFSA bridge | ✅ working |
| 3 | Good Health — myths, free care, child vaccine tracker | ✅ working |
| 4 | Quality Education — scholarships, free learning, quiz, literacy | ✅ working |
| 5 | Gender Equality — EmpowHer + women's health | ✅ working |
| 6 | Clean Water — is my water safe, free testing | ✅ working |
| 7 | Affordable Energy — bill check, solar, gas subsidy | ✅ working |
| 8 | Decent Work — job scams, MGNREGA, e-Shram | ✅ working |
| 9 | Industry & Enterprise — which loan scheme, Udyam | ✅ working |
| 10 | Reduced Inequalities — certificate finder, complaint router | ✅ working |
| 11 | Sustainable Cities — street complaints, PM Awas checker | ✅ working |
| 13 | Climate Action — heat illness check, crop-loss clock | ✅ working |
| 16 | Peace & Justice — RTI, police, legal aid | ✅ working |
| 12 | Responsible Consumption — food label check | ✅ working |
| 14 | Life Below Water — fishing ban dates | ✅ working |
| 15 | Life on Land — forest rights check | ✅ working |
| 17 | Partnerships — user corrections, transparency | ✅ working |

### SDG 1 — No Poverty ✅

- [x] 52 real central government schemes, bundled (works offline)
- [x] Search and category filter
- [x] Detail page with eligibility, ministry, official link
- [x] myScheme.gov.in fallback so nobody hits a dead end
- [x] Admin can override any scheme from Firestore
- [ ] **Verify all 52 official links** — all flagged `verified: false` until then

### SDG 5 — Gender Equality ✅

- [x] One-tap 181 and 112 at the top of the module
- [x] 7 verified national helplines, tap to dial, clipboard fallback
- [x] Quick-exit button on every safety screen
- [x] Honest note that the app does not hide itself
- [x] Report abuse — three modes, user chooses what is stored
- [x] Firestore rules: reports are write-only, nobody can read them back
- [x] Anonymous mode enforced server-side, not trusted from the client
- [x] 9 legal rights in plain English and Hindi, each with an official source
- [x] AI career guidance, business ideas, course finder (via proxy)
- [x] Every AI answer carries a "this can be wrong" note
- [x] 21 Indian women, described by what they did
- [x] **Women's health (zip 20):** Matru Vandana cash, free delivery under
      JSSK, anaemia (57% of women, NFHS-5), breast and cervical screening,
      Tele-MANAS 14416 — 5 cards, all sourced
- [x] **Money to start a business** — opens the SDG 9 loan-scheme matcher
- [x] Fixed EmpowHer `app.py` in `fixes/5_EmpowHer/` (key from env, limits)
- [ ] **Verify the 7 helpline numbers** before public release
- [ ] **Have the 5 women's health cards checked by a doctor**
- [ ] **Have the 9 legal summaries checked** by someone qualified
- [ ] Admin screen to read reports (currently Firebase console only)
- [ ] Scheduled deletion of anonymous reports after 30 days

### SDG 8 — Decent Work ✅

- [x] **Job scam checker** — 10 weighted red flags, clear verdict
- [x] Decisive flags (money, OTP, "government job for a fee") trigger alone
- [x] Routes to 1930 and cybercrime.gov.in when fraud is likely
- [x] 10 guides: MGNREGA rights, e-Shram, payslips, minimum wage, skilling
- [x] MGNREGA 1800-111-555 and NCS 14434 one-tap
- [ ] Confirm MGNREGA allowance percentages against the current circular
- [ ] Consider adding state-wise minimum wage figures (they change yearly)

### SDG 16 — Peace & Justice ✅

- [x] **RTI application builder** — produces a correctly formatted application
- [x] Specific-question guidance, because vague RTIs get rejected
- [x] BPL fee exemption handled
- [x] Copy to post, or open rtionline.gov.in to file online
- [x] Nothing typed is uploaded — it all stays on the device
- [x] 11 guides: RTI timelines and both appeals, FIR and Zero FIR, arrest
      rights, free legal aid, Lok Adalat, CPGRAMS, corruption reporting
- [x] NALSA 15100 one-tap dial
- [ ] **Have the 11 guides checked by a lawyer**
- [ ] Confirm RTI fees for your state — the ₹10 figure is central government

### SDG 6 — Clean Water ✅

- [x] **"Is my water safe?"** — six questions, five possible verdicts
- [x] Separates germ risk from chemical risk, because they need opposite
      actions and the familiar advice is wrong for the second
- [x] A chemical verdict can never tell you to boil — enforced by the
      validator, not just by care
- [x] Handles the trap where a past clear test never looked for arsenic
- [x] Iron gets a calmer verdict than arsenic, on purpose
- [x] Never says "your water is safe" — it cannot know that
- [x] 14 guides across testing, treatment, chemicals, protection,
      entitlement and complaints, every one sourced to a government page
- [x] Routes to the free village field-test kit, the WQMIS public results
      portal, the JJM portal and CPGRAMS
- [x] Editable and translatable from Admin
- [ ] **Have the boiling times and the arsenic/fluoride claims checked by a
      water quality officer** — 14 cards, all flagged unverified
- [ ] Confirm the 55 lpcd entitlement figure against a primary JJM document
- [ ] Add state-wise PHED/RWS complaint numbers (they differ by state)

### SDG 7 — Affordable Energy ✅

- [x] **"Is my bill right?"** — the subtraction check, which works in every
      state and needs no tariff knowledge
- [x] Separates provable from suspected: a reading mismatch is decisive, an
      odd-looking rate is phrased as a question to ask
- [x] No rate check below 50 units — fixed charges make a high effective
      rate normal there, and a false alarm sends someone to argue a correct
      bill
- [x] Flags an "estimated" or "average" bill, since nobody read the meter
- [x] Copies a complaint draft with the arithmetic filled in; nothing typed
      leaves the device
- [x] Never says the bill is correct, and never says you were overcharged —
      enforced by the validator
- [x] 13 guides: consumer rights under the 2020 rules, reading a bill, the
      complaint route, PM Surya Ghar, the Ujjwala subsidy and how to check
      it reaches you, cooking smoke and cylinder safety
- [x] **No solar payback calculator, deliberately** — sizing and payback
      decide a one-to-two lakh purchase on figures that all move
- [ ] **Confirm the PM Surya Ghar subsidy bands** against the portal — the
      amounts here came from a secondary source and are flagged unverified
- [ ] **The Ujjwala refill count is in flux** — 12, then 9, then reportedly
      4 in mid-2026. The card deliberately gives no current number and
      tells the reader to check their own bank credits instead
- [ ] Add state electricity ombudsman contacts (they differ by state)

### SDG 9 — Industry & Enterprise ✅

- [x] **"Which scheme should I ask about?"** — five questions across Mudra,
      PMEGP, SVANidhi and Stand-Up India
- [x] Asks new-or-running outright, because that one answer decides whether
      PMEGP's 15–35% subsidy is on the table at all
- [x] Names what you are **not** eligible for, and why — someone who heard
      of PMEGP from a neighbour needs to know the app did not miss it
- [x] Never returns an empty screen: 18 of 192 input combinations match no
      named scheme, and those get the ordinary MSME term-loan route instead
- [x] A vendor asking for several lakh is no longer led with a ₹50,000
      scheme
- [x] "This is not an approval" on the results screen, with the advance-fee
      fraud named — enforced by the validator
- [x] 14 guides: Udyam is free and only one site is official, the revised
      MSME limits, the four schemes compared, Jan Samarth, what a bank
      actually looks at, writing your own project report, UPI at the
      counter, ONDC
- [ ] **Confirm the PMEGP project-cost ceiling** — the official guidelines
      PDF says ₹25L/₹10L, recent sources say ₹50L/₹20L. The card
      deliberately states no figure and points to the KVIC portal
- [ ] **UPI merchant charges are unresolved** — zero MDR since Jan 2020, a
      0.4% charge announced for Oct 2026, deferred by NPCI, under Supreme
      Court challenge. The card says exactly that rather than picking a side
- [ ] Add state-level MSME facilitation council contacts for delayed
      payments

### SDG 2 — Zero Hunger ✅

- [x] **"Can this food be shared?"** — guided safety check with a clear verdict
- [x] Conservative logic: two-hour rule, halved in heat, hard no on served food
- [x] 9 food safety rules, English and Hindi, sourced to FSSAI
- [x] 8 household waste-reduction tips
- [x] Routes donors to the official FSSAI Save Food Share Food network
- [x] Local organisation directory — **ships empty on purpose**, admin-filled
- [x] **Food board (zip 22)** — post only after a passing safety check;
      expires with the food; contact only to the claimer; reports hide posts
- [ ] Deploy rules + indexes: `firebase deploy --only firestore:rules,firestore:indexes`
- [ ] Test with two accounts: post on one, claim on the other
- [ ] Add real local collection organisations, each phoned before listing
- [ ] Have the food safety thresholds checked by a food safety officer

### SDG 3 — Good Health ✅

- [x] 108 / 112 emergency, one tap, at the top
- [x] 6 health helplines including Tele-MANAS mental health
- [x] **16 myth-vs-fact cards** in English and Hindi, every one sourced
- [x] One-tap copy for sharing on WhatsApp — the point is showing someone else
- [x] Full national immunisation schedule, birth to 16 years, plus pregnancy
- [x] No symptom checker, no diagnosis — deliberate, and said plainly in-app
- [x] Editable from Admin → Edit content
- [ ] **Have the 16 health cards checked by a doctor** before public release
- [ ] **Verify the 6 helpline numbers**, especially 14416 Tele-MANAS
- [ ] Confirm the immunisation schedule against the current UIP circular
- [x] **My child's vaccines (zip 20):** add a child by birth date, see each
      due date, tick off doses; stored on the phone only; never says "late",
      always says "go anyway"
- [x] **Free and cheaper care (zip 20):** eSanjeevani, Ayushman Arogya
      Mandir, PM-JAY (incl. 70+), Jan Aushadhi — 6 cards, tap-to-dial 14555
- [ ] Have the 6 free-care cards checked against the scheme portals
- [x] **Medicine reminders (zip 21)** — daily notifications, phone only
- [x] **Daily log (zip 21)** — water, steps, active minutes; no targets
- [x] **Leftover medicines (zip 21)** — disposal guide instead of donation
- [ ] Do the two Android edits in LOCAL_CHANGES.md #7, then test a reminder

### SDG 4 — Quality Education ✅

- [x] 24 central scholarships, class 8 → PhD
- [x] 7-question profile, stored on device only
- [x] Eligibility matcher — income only ever flags, never hides
- [x] Document checklist per scholarship
- [x] Deadline countdown with urgency marker
- [x] Admin deadline manager
- [x] **SDG 4 home screen (zip 20)** — scholarships first, then the rest
- [x] **Free learning by class level** — DIKSHA, NCERT, PM eVIDYA, SWAYAM,
      NIOS, NDL; subject search; language-learning links
- [x] **Practice quiz** — six subjects, OpenTDB (questions in English, said so)
- [x] **Literacy rates** — World Bank data, women and men side by side
- [x] **Study questions (zip 22)** — admin approves everything first; no
      names, no messages, contact details refused
- [ ] Decide who moderates Q&A daily — unanswered queues kill it
- [ ] **Enter the 24 deadlines** — Admin → Scholarship deadlines
- [ ] Verify the 24 scholarship records against NSP

---

## Languages

**Interface — done.** 14 languages, 69 strings each, complete parity:
English, हिन्दी, বাংলা, मराठी, తెలుగు, தமிழ், ગુજરાતી, اردو, ಕನ್ನಡ, ଓଡ଼ିଆ,
മലയാളം, ਪੰਜਾਬੀ, অসমীয়া, नेपाली.

Only codes `flutter_localizations` actually ships are included, checked
against `kMaterialSupportedLanguages`. Sindhi, Sanskrit, Maithili, Konkani
and Manipuri are **not** supported by Flutter — adding them would make every
Material widget (date pickers, text-selection menus) fall back to another
language silently, so they are left out rather than half-added.

- [x] 14-language interface, app-wide, set in Settings or the right panel
- [x] Temporary per-section switch, on every content screen
- [x] Admin → Translate content, record by record, any language
- [x] `i18n` map on content records — unlimited languages, no schema change
- [x] Validator checks key parity, unreachable languages, unsupported codes
- [ ] **Have the 14 interface languages read by a native speaker** — these
      are machine translations; wording may be clumsy or regionally off
- [ ] Content translation beyond English and Hindi — deliberately empty,
      see below

### Why the content is still English and Hindi only

The ~295 content strings are health facts, legal rights, food-safety
thresholds and helpline descriptions. Machine-translating those into
languages neither of us reads would mean publishing medical and legal
claims nobody can check, in the exact modules built to be more reliable
than rumour. A wrong seizure instruction or a wrong arrest right does more
harm than an English paragraph someone has to ask about.

So the pipeline is built and the content is not filled: Admin → Translate
content takes one record at a time, shows the English original beside the
box, and goes live on every device without an app release. A language flips
to "ready" in `lib/core/i18n/app_languages.dart` (`contentReady: true`) once
its records are in. Until then the app says so on screen.

**Known gap:** the job-scam red flags (`job_scam_check.dart`) are hardcoded
Dart, English and Hindi only — they are reasoning, not data, so they are not
in the translation pipeline yet.

---

## Admin dashboard

- [x] Role-gated: master admin, super admin, per-SDG admin
- [x] **Edit content** — fix any broken link or record from phone or web
- [x] **Translate content** — add a regional language, record by record,
      with per-language and per-dataset progress counts
- [x] **People and access** — promote, demote, assign goals, transfer ownership
- [x] AI provider key manager — 10 providers, free and paid tiers
- [x] Send a notice (in-app feed, optional push)
- [x] Scholarship deadline manager
- [x] Scheme link verification screen
- [x] Content editors for schemes, scholarships, helplines, legal rights
- [ ] User list and basic analytics

---

## Notifications

- [x] In-app feed with unread badge
- [x] Firestore-backed, admin-posted
- [ ] **Push via FCM** — needs the Render proxy deployed

---

## AI (SDG 5 features)

- [x] Proxy code written — 10 providers, automatic failover
- [x] Admin key UI, keys write-only
- [x] Firestore rules deny all client access to `/_secrets/`
- [ ] **Deploy the proxy to Render**
- [ ] Add at least one free provider key
- [ ] Open `_secrets` write briefly to seed keys, then close it again

---

## Before Play Store

- [ ] Google Play developer account (one-time $25)
- [ ] Release signing key — **back it up; losing it means you can never update**
- [ ] **Host the privacy policy at a public URL** — Play requires a link, an
      in-app page alone does not satisfy it. Text is written; put it on
      ibtidaatech.com/privacy and the About page already links there.
- [ ] Have a lawyer review the Terms and Privacy text
- [ ] Data safety form
- [ ] Store listing: screenshots, description, feature graphic
- [ ] `flutter build appbundle --release`
- [ ] Test on a low-end device
- [ ] Review SDG 3 and 5 content against Play's sensitive-content policies

---

## Parity with the five Render apps (zip 20)

| Old app | Feature | In the Flutter app |
|---|---|---|
| 1 Subsidy awareness | schemes, search, detail, links | ✅ all |
| 2 Food sharing | food safety, waste tips, partners | ✅ |
| 2 Food sharing | donate / claim board | ✅ safe food board (zip 22) |
| 3 GoodHealthHub | doctor booking | ✅ as eSanjeevani (real doctors, free) |
| 3 GoodHealthHub | pharmacy | ✅ as Jan Aushadhi |
| 3 GoodHealthHub | health camps | ✅ as Ayushman Arogya Mandir + PM-JAY |
| 3 GoodHealthHub | vaccination record | ✅ child tracker |
| 3 GoodHealthHub | symptom checker | ❌ deliberately not — diagnosis by app harms |
| 3 GoodHealthHub | medicine donation | ✅ as safe-disposal guide (your choice) |
| 3 GoodHealthHub | reminders, fitness tracker | ✅ reminders + daily log (zip 21) |
| 4 LearningVersity | courses, resources, languages | ✅ |
| 4 LearningVersity | quiz, literacy tracker | ✅ |
| 4 LearningVersity | teacher–student Q&A | ✅ moderated study Q&A, no DMs (zip 22) |
| 5 EmpowHer | helplines, report, rights, mentor, ideas, courses, leaders | ✅ |
| 5 EmpowHer | wage gap | ✅ inside legal rights (equal pay) |
| 5 EmpowHer | wellness | ✅ women's health, India-specific |
| 5 EmpowHer | businesses | ✅ links to SDG 9 matcher |
| 5 EmpowHer | AI chat on abuse/legal pages | ❌ deliberately not — wrong legal advice in a crisis |
| 5 EmpowHer | blogs, feedback form | ❌ were not functional in the original |

## Roadmap for goals 6-17

Each locked tile opens its own plan — `lib/core/sdg/sdg_roadmap.dart` holds
4 to 5 planned features per goal. **All 17 goals are built** (zip 24). Each has at least one
tool that solves a problem, not only information.

## Outstanding risks

New in zips 20-24, all shipped `verified: false`:
- 🔴 Heat-illness and snakebite advice (SDG 13, 15) — doctor review
- 🟠 Forest Rights, certificates, complaint routing (SDG 10, 15) — lawyer review
- 🟠 Fishing ban dates, PMFBY 72 h / 14 days, PMAY-U figures — re-check yearly
- 🟠 Food board and Q&A need a named daily moderator before public launch

| | Issue | Action |
|---|---|---|
| 🔴 | Gemini API key public in the EmpowHer repo's git history | **Revoke it**, then deploy `fixes/5_EmpowHer/app.py` (see README_FIX.md there) |
| 🟠 | 52 scheme links unverified | Fix in Admin → Edit content |
| 🟠 | 24 scholarship records unverified, no deadlines | Verify and enter |
| 🟡 | Brand colours are my placeholder | Send hex codes or screenshot |
| 🟡 | WhatsApp channel link is a placeholder | Real invite link → `CompanyLinks` in brand.dart |
| 🟡 | LinkedIn / YouTube handles guessed from your other app | Confirm in `CompanyLinks` |
| 🟡 | Old Flask apps store passwords in plaintext | Archive those repos |
| 🔴 | SDG 5 helplines and legal text unverified | Fix in Admin → Edit content |
| 🔴 | SDG 3 health facts need a doctor's review | 16 cards; wrong health info causes real harm |
| 🟠 | SDG 16 legal guides need a lawyer's review | 11 guides; RTI fee varies by state |
| 🟠 | Anonymous reports are not auto-deleted yet | Needs a scheduled job; 30-day field is written |
| 🟠 | 14 interface languages are machine-translated | Get each read by a speaker; wording, not meaning, is the risk |
| 🟡 | Content exists in English and Hindi only | Admin → Translate content, as speakers become available |
| 🔴 | SDG 6 water guidance needs a water quality officer | 14 cards; wrong treatment advice causes illness |
| 🟠 | SDG 7 subsidy amounts go stale fast | Surya Ghar bands and the Ujjwala refill count both move; re-check before release |
| 🟡 | SDG 6, 7 and 9 still use their own guide-list screens | Shared `GuideListPage` added in zip 20 (used by SDG 3 and 5); move 6/7/9 over once a device build confirms it |
