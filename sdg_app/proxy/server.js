/**
 * Ibtidaa Tech - AI & Push proxy
 * ---------------------------------------------------------------------------
 * Deploy on Render (free tier). This is the ONLY place AI provider keys are
 * ever read. The Flutter app has no code path that can reach them.
 *
 * Why this exists: anything inside an APK is readable by whoever holds the
 * phone. Firestore rules cannot distinguish your app from a curl command
 * carrying a valid token. So the key lives here instead.
 *
 * Env vars to set in the Render dashboard:
 *   FIREBASE_SERVICE_ACCOUNT  - the whole service-account JSON, one line
 *   ALLOWED_ORIGIN            - optional, your Firebase Hosting URL
 * ---------------------------------------------------------------------------
 */

const express = require('express');
const admin = require('firebase-admin');

const app = express();
app.use(express.json({ limit: '1mb' }));

app.use((req, res, next) => {
  res.set('Access-Control-Allow-Origin', process.env.ALLOWED_ORIGIN || '*');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.set('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
  if (req.method === 'OPTIONS') return res.sendStatus(204);
  next();
});

// --------------------------------------------------------------- firebase

if (!process.env.FIREBASE_SERVICE_ACCOUNT) {
  console.error('FATAL: FIREBASE_SERVICE_ACCOUNT is not set.');
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(
    JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)
  ),
});

const db = admin.firestore();

// ---------------------------------------------------------------- helpers

/** Cache keys briefly so every prompt is not a Firestore read. */
let keyCache = { at: 0, providers: [] };
const CACHE_MS = 60_000;

async function loadProviders() {
  if (Date.now() - keyCache.at < CACHE_MS) return keyCache.providers;

  const [statusSnap, secretSnap] = await Promise.all([
    db.collection('aiProviders').get(),
    db.collection('_secrets').get(),
  ]);

  const secrets = {};
  secretSnap.forEach((d) => {
    if (d.id.startsWith('ai_')) secrets[d.id.slice(3)] = d.data();
  });

  const providers = statusSnap.docs
    .map((d) => ({ id: d.id, ...d.data() }))
    .filter((p) => p.enabled && secrets[p.id]?.apiKey)
    .map((p) => ({
      id: p.id,
      model: secrets[p.id].model || p.model,
      apiKey: secrets[p.id].apiKey,
      paid: !!p.paid,
      priority: typeof p.priority === 'number' ? p.priority : 99,
    }))
    // Free first, then by configured priority. Paid is a last resort so a
    // free outage does not silently start costing money.
    .sort((a, b) => a.paid - b.paid || a.priority - b.priority);

  keyCache = { at: Date.now(), providers };
  return providers;
}

async function requireAdmin(req) {
  const header = req.get('Authorization') || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return null;
  try {
    const decoded = await admin.auth().verifyIdToken(token);
    const user = await db.collection('users').doc(decoded.uid).get();
    const role = user.data()?.role;
    return role === 'admin' || role === 'super_admin' ? decoded : null;
  } catch {
    return null;
  }
}

// ------------------------------------------------------------- AI callers

async function callProvider(p, prompt, system) {
  const t = AbortSignal.timeout(30_000);

  if (p.id === 'gemini') {
    const r = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${p.model}:generateContent?key=${p.apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        signal: t,
        body: JSON.stringify({
          contents: [{ parts: [{ text: `${system}\n\n${prompt}` }] }],
        }),
      }
    );
    if (!r.ok) throw new Error(`gemini ${r.status}`);
    const j = await r.json();
    return j.candidates?.[0]?.content?.parts?.[0]?.text || '';
  }

  if (p.id === 'anthropic') {
    const r = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': p.apiKey,
        'anthropic-version': '2023-06-01',
      },
      signal: t,
      body: JSON.stringify({
        model: p.model,
        max_tokens: 1024,
        system,
        messages: [{ role: 'user', content: prompt }],
      }),
    });
    if (!r.ok) throw new Error(`anthropic ${r.status}`);
    const j = await r.json();
    return j.content?.[0]?.text || '';
  }

  // Everything else speaks the OpenAI chat-completions shape.
  const endpoints = {
    groq: 'https://api.groq.com/openai/v1/chat/completions',
    openrouter: 'https://openrouter.ai/api/v1/chat/completions',
    openai: 'https://api.openai.com/v1/chat/completions',
    mistral: 'https://api.mistral.ai/v1/chat/completions',
    deepseek: 'https://api.deepseek.com/chat/completions',
    together: 'https://api.together.xyz/v1/chat/completions',
    cohere: 'https://api.cohere.ai/compatibility/v1/chat/completions',
    huggingface: 'https://router.huggingface.co/v1/chat/completions',
  };
  const url = endpoints[p.id];
  if (!url) throw new Error(`unknown provider ${p.id}`);

  const r = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${p.apiKey}`,
    },
    signal: t,
    body: JSON.stringify({
      model: p.model,
      max_tokens: 1024,
      messages: [
        { role: 'system', content: system },
        { role: 'user', content: prompt },
      ],
    }),
  });
  if (!r.ok) throw new Error(`${p.id} ${r.status}`);
  const j = await r.json();
  return j.choices?.[0]?.message?.content || '';
}

const SYSTEM_PROMPTS = {
  general:
    'You are a helpful assistant inside an Indian public-service app. Answer plainly and briefly.',
  mentor:
    'You are a supportive career mentor for women in India. Give practical, encouraging, specific guidance. Keep it under 200 words.',
  business_idea:
    'Suggest practical small-scale or home-based business ideas suited to India. Be specific about startup cost and first steps. Keep it under 250 words.',
  course_suggest:
    'Recommend beginner-friendly, free or low-cost online courses available in India. Prefer SWAYAM, NPTEL and DIKSHA where relevant. List 5 to 8 with the platform name.',
};

// ------------------------------------------------------------- AI endpoint

app.post('/api/ai', async (req, res) => {
  const { prompt, task = 'general' } = req.body || {};
  if (!prompt || typeof prompt !== 'string' || prompt.length > 4000) {
    return res.status(400).json({ error: 'bad prompt' });
  }

  let providers;
  try {
    providers = await loadProviders();
  } catch (e) {
    console.error('provider load failed', e);
    return res.status(503).json({ error: 'config unavailable' });
  }
  if (!providers.length) {
    return res.status(503).json({ error: 'no provider configured' });
  }

  const system = SYSTEM_PROMPTS[task] || SYSTEM_PROMPTS.general;
  const errors = [];

  // The failover Laiq asked for: walk the list until one answers.
  for (const p of providers) {
    try {
      const text = await callProvider(p, prompt, system);
      if (text && text.trim()) {
        return res.json({ text: text.trim(), provider: p.id });
      }
      errors.push(`${p.id}: empty`);
    } catch (e) {
      errors.push(`${p.id}: ${e.message}`);
    }
  }

  console.warn('all providers failed', errors);
  return res.status(429).json({ error: 'all providers failed' });
});

// ----------------------------------------------------------- push endpoint

app.post('/api/push', async (req, res) => {
  const caller = await requireAdmin(req);
  if (!caller) return res.status(403).json({ error: 'admin only' });

  const { title, body } = req.body || {};
  if (!title || !body) return res.status(400).json({ error: 'bad payload' });

  const snap = await db.collection('deviceTokens').get();
  const tokens = snap.docs.map((d) => d.id).filter(Boolean);
  if (!tokens.length) return res.json({ sent: 0 });

  let sent = 0;
  // FCM accepts 500 tokens per multicast call.
  for (let i = 0; i < tokens.length; i += 500) {
    const batch = tokens.slice(i, i + 500);
    const r = await admin.messaging().sendEachForMulticast({
      tokens: batch,
      notification: { title, body },
    });
    sent += r.successCount;

    // Clean out tokens FCM says are dead, so the list does not rot.
    r.responses.forEach((resp, idx) => {
      if (
        !resp.success &&
        resp.error?.code === 'messaging/registration-token-not-registered'
      ) {
        db.collection('deviceTokens').doc(batch[idx]).delete().catch(() => {});
      }
    });
  }

  res.json({ sent });
});

// ------------------------------------------------------------------ health

app.get('/', (_req, res) =>
  res.json({ ok: true, service: 'ibtidaa-ai-proxy' })
);

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`proxy listening on ${port}`));
