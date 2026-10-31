# Ibtidaa Tech — SDG App

Flutter + Firebase. One app, 17 UN Sustainable Development Goals.
This is **zip #1: the shell + SDG 1 (No Poverty)**.

---

## What works right now

| Area | Status |
|---|---|
| Logo, app icon, favicons, PWA manifest | ✅ see `BRANDING.md` |
| Responsive layout, 320dp phone → desktop | ✅ see `BRANDING.md` |
| App shell, navigation, routing | ✅ working |
| Light / dark / system theme | ✅ working, light is default |
| 6 accent colours, 4 text sizes | ✅ working, user-selectable |
| English + Hindi | ✅ working, switchable in Settings |
| Home grid, 17 tiles, 6–17 greyed out | ✅ working |
| Email + password sign-in | ✅ working |
| Google sign-in | ✅ working |
| Same-Gmail account merge | ✅ working |
| Forgot password | ✅ working |
| **SDG 1 — schemes directory** | ✅ working, 52 real schemes |
| **SDG 4 — scholarship watchdog** | ✅ working, 24 scholarships, eligibility matcher |
| In-app notification feed + bell badge | ✅ working |
| Admin dashboard | ✅ working (keys, notices, link verification) |
| AI proxy (10 providers, failover) | ✅ code complete, needs deploying |
| SDG 2, 3, 5 | 🚧 honest placeholders listing planned features |

---

## SDG 4 — how the matcher behaves, and why

The module exists because students lose scholarships through process failure,
not rejection. So two rules are built into the code:

**Income never hides anything.** If a scheme caps income at ₹2.5L and the
student enters ₹2.6L, the scholarship still appears, badged "Check". Hiding
it would make the app commit the exact failure it is meant to prevent. Only
hard criteria — study level, class, category, gender, disability, state — can
push a result to "Unlikely", and even those stay reachable behind
"Show all 24 scholarships".

**Deadlines are never invented.** `deadline` ships `null` for every record.
A wrong date is worse than no date: a student who reads "closes 31 Dec"
relaxes and misses a real 15 Nov cutoff. Until you enter a date in
**Admin → Scholarship deadlines**, the student sees "Closing date not
confirmed — check the portal" with a link to NSP.

Keeping those dates current is the ongoing job that makes this module worth
having. Everything else runs itself.

**Student details stay on the device.** Caste, religion, income and
disability are entered once and saved to `SharedPreferences` only. Matching
runs locally against the bundled asset. None of it is uploaded, and the
module works without an account.

---

## Setup — run these in order

```bash
# 1. one-time tooling
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login

# 2. create the project (skip if ibtidaa-sdgapp already exists)
firebase projects:create ibtidaa-sdgapp

# 3. from inside this folder
flutter pub get
flutterfire configure --project=ibtidaa-sdgapp
```

`flutterfire configure` generates `lib/firebase_options.dart`. **The app will
not compile until you run it** — that file is intentionally not in this zip
because it is specific to your Firebase project.

Then in the Firebase Console:

- **Authentication → Sign-in method** → enable **Email/Password** and **Google**
- **Firestore Database** → create, production mode
- **Storage** → create

Deploy the security rules:

```bash
firebase deploy --only firestore:rules
```

Run it:

```bash
flutter run
```

---

## Seeding AI keys safely

`firestore.rules` denies **all** client access to `/_secrets/`. That is
deliberate and it is the whole point of the design. It also means the admin
"save key" screen cannot write there until you temporarily open it.

1. In `firestore.rules`, change the `_secrets` block to:
   ```
   allow write: if isSuperAdmin();
   allow read: if false;
   ```
2. `firebase deploy --only firestore:rules`
3. Open the admin dashboard, paste your keys.
4. **Change `allow write` back to `if false` and redeploy.**

Step 4 is not optional. Leaving it open means a phished admin account can
overwrite your keys.

Note that `read: if false` stays false the entire time. Nothing client-side
ever reads a key, not even during seeding.

### Master admin

`free.timesenjoy@gmail.com` is the master admin. Sign in with that Google
account and the Admin card appears — no Firestore editing needed.

That email is written into `firestore.rules` and into
`lib/core/admin/admin_config.dart`. It is matched by email, so it keeps
working even if the `users` collection is wiped, and nobody can demote it
from inside the app.

**Everyone else** is promoted from **Admin → People and access**:

- *SDG admin* — can edit the goals you tick for them, nothing else
- *Super admin* — can edit everything and manage other admins
- *Master admin* — all of the above, plus transfer of the role itself

**Transferring master admin** writes a new email to `/config/admin`. The new
owner gets full control. `free.timesenjoy@gmail.com` keeps master access
afterwards, so a typo or a bad actor can never lock everyone out. Removing
that recovery account means editing `firestore.rules` and redeploying — which
is deliberate; it should take more than a tap on a phone.

### Fixing wrong data

**Admin → Edit content.** Every bundled dataset is editable:

| Dataset | What you can fix |
|---|---|
| SDG 1 — schemes | Name, category, ministry, eligibility, official link |
| SDG 4 — scholarships | Name, provider, income limit, portal link |
| SDG 5 — helplines | Number, name and description in both languages |
| SDG 5 — legal rights | Heading, law, summaries, source link |

Each record has an **Open the link and check it** button, and a **verified**
flag. Unverified records show a caution banner to users, and the list can be
filtered to unverified only.

Saved changes write a *patch* to Firestore — only the fields you actually
changed — which is merged over the bundled copy on every device, immediately.
The **Revert** button drops the patch and restores the built-in values.

---

## Deploying the AI proxy

```bash
cd proxy
npm install
```

On Render: **New → Web Service** → point at this `proxy/` folder →
build `npm install`, start `npm start`.

Set one environment variable:

- `FIREBASE_SERVICE_ACCOUNT` — the entire service-account JSON on one line.
  Get it from Firebase Console → Project Settings → Service Accounts →
  Generate new private key.

Then rebuild the app pointing at your proxy URL:

```bash
flutter build apk --release --dart-define=AI_PROXY_URL=https://your-proxy.onrender.com
```

Render's free tier sleeps when idle, so the first AI request after a quiet
period takes ~30 seconds. The app already shows a message explaining that.

---

## Build commands

```bash
flutter analyze
flutter build apk --release
flutter build web
firebase deploy --only hosting
```

---

## Data honesty note — read this

The original `1_subsidy-awareness-app` repo contained 1,020 subsidy records.
**1,000 of them were generated placeholders** — names like "Health Subsidy
401", only 7 unique eligibility strings repeated across 900 rows, and
invented links such as `https://health.gov.in/subsidy401` that do not exist.

They are not shipped. `assets/data/subsidies.json` instead contains **52 real
central government schemes** with genuine official portals.

Every record is flagged `verified: false` until a human opens the link and
confirms it. Unverified schemes show a caution banner to the user, and every
screen offers [myscheme.gov.in](https://www.myscheme.gov.in/) — the
government's own scheme-discovery portal — as a fallback so nobody hits a
dead end.

**Verify the links before any public release.** A wrong government link
shown to someone who needs that benefit is worse than showing nothing.

---

## Security decisions baked in

- **No API key anywhere in the app.** Not in code, not in Firestore that the
  app can read. Anything shipped in an APK is readable by whoever holds the
  phone.
- **Users cannot grant themselves admin.** The rules block writes to `role`
  and `sdgAccess` from the account that owns the document.
- **No passwords stored by us.** Firebase Auth handles it. The old Flask app
  stored them as plaintext.
- **No symptom checker in SDG 3.** Decided deliberately — diagnosis features
  risk Play Store rejection and real-world harm.
- **SDG 5 abuse reporting defaults to helpline-first.** The user picks what,
  if anything, gets stored.

---

## Still to do

1. Revoke the Gemini key that is public in the EmpowHer repo's git history.
2. Send the Ibtidaa Tech brand colours. Four hex codes in
   `lib/core/theme/brand.dart` re-skin the whole app; the icons then need
   re-exporting from `brand/*.svg` (see `BRANDING.md`).
3. Verify the 52 scheme links and the 24 scholarship records.
4. Enter scholarship deadlines in Admin → Scholarship deadlines.
5. SDG 5, 3, then 2 (the IFSA bridge).

---

*Ibtidaa Tech — From Beginning to Impact*
