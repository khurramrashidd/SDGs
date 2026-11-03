# EmpowHer (five-empowher.onrender.com) — key fix

This folder is **not part of the Flutter app**. It is a corrected `app.py`
for your separate EmpowHer repo (github.com/khurramrashidd/...5_EmpowHer).

## What was wrong
1. The Gemini API key was written directly in `app.py` (line 7). The repo is
   public, so the key is visible to anyone — including in old commits.
2. `/ai_assistant`, `/ai_mentor`, `/generate-idea` and `/skill_building`
   send any text from anyone on the internet to Gemini on your key, with no
   limit.
3. Errors returned the raw exception text to the visitor.

## What this file changes
- Reads the key from the `GEMINI_API_KEY` environment variable.
- If no key is set, the AI routes say "not configured" instead of crashing.
- Each AI route: max 2,000 characters per message, max 20 calls per hour per
  visitor address.
- Errors are logged on the server, and the visitor sees a plain message.
- Everything else (pages, templates, prompts) is unchanged.

## Steps, in this order
1. **Revoke the old key first**: Google AI Studio → API keys → delete the
   key that was in `app.py`. Removing it from the code does not help while it
   still works — it is already in the git history.
2. Create a new key in AI Studio.
3. Render → the EmpowHer service → Environment → add
   `GEMINI_API_KEY` = the new key → Save.
4. Replace `app.py` in the EmpowHer repo with this one, then:
   ```
   git add app.py
   git commit -m "Read Gemini key from environment, cap AI routes"
   git push
   ```
   Render redeploys on push.
5. Open the site and try the AI assistant once to check it answers.

Never paste the new key into code, chat, or a commit.
