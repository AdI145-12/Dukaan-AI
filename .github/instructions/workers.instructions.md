---
applyTo: "workers/**"
---

# Cloudflare Workers Instructions (workers/**)

## File Structure
```
workers/
  src/
    handlers/     # One file per route handler
    middleware/   # Auth, rate limiting, CORS
    services/     # Reusable service logic (razorpay, openai, firebase)
    utils/        # Shared utilities
    types/        # TypeScript interfaces
  wrangler.toml   # Cloudflare config
```

## Every Handler Must Follow This Pattern
```typescript
export async function handleXxx(request: Request, env: Env): Promise<Response> {
  // 1. Parse & validate input first
  // 2. Auth check (verify user_id against Firebase)
  // 3. Rate limit check (KV-based)
  // 4. Core logic
  // 5. Return standardized response
}
```

## Standard Response Format (Never Deviate)
```typescript
// Success
return Response.json({ success: true, data: { ... } }, { status: 200, headers: corsHeaders });

// Error
return Response.json({ success: false, error: "User-friendly message in Hinglish" }, { status: 4xx, headers: corsHeaders });
```

## CORS Headers (Always Include)
```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};
// Handle OPTIONS preflight at the top of every handler
if (request.method === 'OPTIONS') return new Response(null, { headers: corsHeaders });
```

## Rate Limiting (Use KV — Required for all AI endpoints)
```typescript
// Pattern: key = "rate:{endpoint}:{userId}", value = count
const key = `rate:${endpoint}:${userId}`;
const count = parseInt(await env.RATE_LIMIT_KV.get(key) ?? '0');
if (count >= LIMIT) {
  return Response.json({ success: false, error: "Aaj ka limit khatam ho gaya. Kal dobara try karein." }, { status: 429, headers: corsHeaders });
}
await env.RATE_LIMIT_KV.put(key, String(count + 1), { expirationTtl: 3600 });
```

## Environment Variables — Exact Names
```
AI_ENGINE_KEY        — AI Engine API key (background removal)
REPLICATE_API_KEY    — Replicate API key (generative backgrounds)
OPENAI_API_KEY       — OpenAI API key (captions)
RAZORPAY_KEY_ID      — Razorpay key ID
RAZORPAY_SECRET      — Razorpay secret
FIREBASE_PROJECT_ID   — Firebase project ID
FIREBASE_API_KEY      — Firebase API key
FIREBASE_CLIENT_EMAIL — Firebase service account client email
FIREBASE_PRIVATE_KEY  — Firebase service account private key
RATE_LIMIT_KV        — KV namespace binding
CACHE_KV             — KV namespace binding for response caching
```

## Never Do This in Workers
- Never run image processing or ML models directly in a Worker (CPU limit)
- Never store secrets in code — always use `env.VARIABLE_NAME`
- Never use Node.js-specific APIs (`fs`, `path`, `Buffer` as Node module) — use Web APIs
- Never make direct database calls without the Firebase service account

## Firestore Calls from Workers
```typescript
// Always use this pattern — keep direct Firestore REST access behind a helper
const response = await fetch(`https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents/users/${userId}`, {
  headers: {
    'Authorization': `Bearer ${env.FIREBASE_PRIVATE_KEY}`,
  }
});
```
