# Setup from zero

Assumes: you have this zip, Flutter installed, and a Firebase project created
by hand in the console. Nothing else.

Do these in order. Do not skip. If a step errors, stop and send me the exact
error rather than continuing.

---

## Step 0 — Firebase Console, in your browser

Open <https://console.firebase.google.com> and open your project.

1. **Copy your Project ID.** It is on the Project Settings page (gear icon →
   Project settings → "Project ID"). It is NOT always the same as the name
   you typed. Write it down.
2. **Build → Authentication → Get started**
   - Enable **Email/Password**
   - Enable **Google** (pick a support email when asked)
3. **Build → Firestore Database → Create database**
   - Start in **production mode**
   - Location: `asia-south1` (Mumbai)
4. **Build → Storage → Get started** (accept defaults)

Do not skip 2 and 3. The app crashes on launch without Firestore, and login
silently fails without the providers enabled.

---

## Step 1 — Put the old folder aside

In File Explorer, rename your existing `sdg_app` folder to `sdg_app_old`.

Do not delete it. If anything goes wrong you will want it back.

---

## Step 2 — Generate a fresh Flutter project

Open Command Prompt. Run these **one line at a time**.

```
cd /d F:\2026\My_projects\FlutterProject\SDG17
```

```
flutter create --org com.ibtidaatech --project-name sdgapp --platforms=android,ios,web sdg_app
```

This creates `sdg_app` with the `android`, `ios` and `web` folders you were
missing. Your Android package name is now `com.ibtidaatech.sdgapp`.

Confirm it worked: the `sdg_app` folder should now contain an `android`
folder. If it does not, stop here.

---

## Step 3 — Copy my files over the top

Extract this zip somewhere temporary (Desktop is fine). You get a folder
called `sdg_app`.

In File Explorer, copy these items **from the extracted folder into**
`F:\2026\My_projects\FlutterProject\SDG17\sdg_app`, choosing **"Replace the
files in the destination"** when Windows asks:

- `lib`  (folder)
- `assets`  (folder)
- `proxy`  (folder)
- `pubspec.yaml`
- `firebase.json`
- `firestore.rules`
- `firestore.indexes.json`
- `analysis_options.yaml`
- `README.md`
- `SETUP.md`

**Do not copy anything else.** Leave the generated `android`, `ios`, `web`,
`.gitignore` and `test` folders exactly as Flutter made them.

Use File Explorer rather than `xcopy`. It is harder to get wrong.

---

## Step 4 — Install packages

```
cd /d F:\2026\My_projects\FlutterProject\SDG17\sdg_app
```

```
flutter pub get
```

---

## Step 5 — Connect Firebase

```
dart pub global activate flutterfire_cli
```

```
flutterfire configure
```

**If you get `'flutterfire' is not recognized`**, use this instead:

```
dart pub global run flutterfire_cli:flutterfire configure
```

At the prompts:

- **Project:** use the ↑ ↓ arrow keys to highlight your project, then Enter.
  Do not type the project id, just pick it from the list.
- **Platforms:** press Space to tick `android` and `web`, then Enter.
- **Android package name:** it should already show
  `com.ibtidaatech.sdgapp`. Press Enter only if it shows that. **Never press
  Enter on a blank line** — that is what caused the original error.

This creates `lib/firebase_options.dart`. The app cannot compile without it.

---

## Step 6 — Raise minSdk to 23

Open `android\app\build.gradle.kts` in VS Code.

Find the `defaultConfig { ... }` block and set:

```kotlin
minSdk = 23
```

If your file is `build.gradle` (no `.kts`), the line is `minSdkVersion 23`.

Firebase Auth will not build below 23, and the error it throws does not
mention minSdk, so this one wastes an hour if you skip it.

---

## Step 7 — Run it

```
flutter run
```

The app should open on the 17-tile home screen. SDG 1 and SDG 4 work.

---

## Step 8 — Deploy the security rules

```
firebase deploy --only firestore:rules
```

If it asks which project, pick the same one.

Until this runs, Firestore is in production lock-down and the notification
feed and admin screens will show nothing.

---

## Step 9 — Make yourself admin

1. Sign up inside the app with your email.
2. Firebase Console → Firestore → `users` collection → open your document.
3. **Add field**: name `role`, type `string`, value `super_admin`
4. Restart the app. The Admin card now appears on the Account page.

---

## Step 10 — Google Sign-In on Android

Google login will silently do nothing until Firebase knows your signing key.

```
cd /d F:\2026\My_projects\FlutterProject\SDG17\sdg_app\android
```

```
gradlew signingReport
```

Copy the **SHA1** value under the `debug` variant. Then:

Firebase Console → Project settings → your Android app → **Add fingerprint**
→ paste the SHA-1 → Save → **Download `google-services.json`** again and put
it in `android\app\`, replacing the old one.

Then:

```
cd /d F:\2026\My_projects\FlutterProject\SDG17\sdg_app
```

```
flutter clean
```

```
flutter run
```

---

## Updating to a newer zip

Read `LOCAL_CHANGES.md` first. It lists the edits that live on your machine
and are not in the zip — the Kotlin and minSdk settings in `android/`, the
deleted `test/widget_test.dart`, and your generated `firebase_options.dart`.

Copy the zip's folders over the project, then:

```
flutter pub get
flutter run
```

---

## Common errors

| Error | Cause | Fix |
|---|---|---|
| `Package name for Android app cannot be empty` | Pressed Enter on a blank package prompt | Re-run `flutterfire configure`, type the name |
| `Firebase project id ... could not be found` | CLI project list is cached | Run `flutterfire configure` with no `--project` flag and pick from the list |
| `'flutterfire' is not recognized` | Pub global bin not on PATH | Use `dart pub global run flutterfire_cli:flutterfire configure` |
| `Target of URI doesn't exist: firebase_options.dart` | Step 5 not done | Run `flutterfire configure` |
| Manifest merger / minSdk failure | minSdk below 23 | Step 6 |
| Google sign-in dialog closes, nothing happens | SHA-1 not registered | Step 10 |
| `No Firebase App '[DEFAULT]'` | Firestore not created in console | Step 0.3 |
| `depends on intl ^0.20.3 ... version solving failed` | Flutter SDK wants a different `intl` | Set that exact version in `pubspec.yaml` |
| `depends on sdgapp any which doesn't exist` | `dart fix` added a bad dependency | Remove `sdgapp: any` from `pubspec.yaml`, delete `test/widget_test.dart` |
| Kotlin `Could not close incremental caches` | Project on F:, pub cache on C: | `kotlin.incremental=false` in `android/gradle.properties` |

---

## Not needed yet

The `proxy` folder is for AI features in SDG 5. Ignore it entirely until
that module exists. Nothing in SDG 1 or SDG 4 touches it.
