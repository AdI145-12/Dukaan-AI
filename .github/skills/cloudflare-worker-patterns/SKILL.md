---
name: cloudflare-worker-patterns
description: >
  Use this skill whenever writing, editing, or reviewing Cloudflare Worker
  handlers, services, or middleware in the workers/src/ directory of Dukaan AI.
  Contains the exact handler structure, env var names, CORS setup, error format,
  rate limiting, and service patterns this project uses.
---

# Dukaan AI — Cloudflare Worker Patterns

## Project Context
- Runtime: Cloudflare Workers (V8 isolates, Web API compatible)
- Language: TypeScript (strict mode)
- Entry: `workers/src/index.ts` → routes to handlers
- All handlers are in `workers/src/handlers/` — one file per endpoint
- All external API calls are wrapped in `workers/src/services/`

## Environment Variables (Exact Names — Never Invent New Ones)

```typescript
// Declared in workers/src/types/env.ts
interface Env {
  FIREBASE_PROJECT_ID: string;
  FIREBASE_CLIENT_EMAIL: string;
  FIREBASE_PRIVATE_KEY: string;
  AIENGINEAPIKEY: string;          // Background removal API
  REPLICATEAPITOKEN: string;       // Flux image generation
  OPENAIAPIKEY: string;            // GPT captions
  RAZORPAY_KEY_ID: string;
  RAZORPAY_SECRET: string;
  RATE_LIMIT_KV: KVNamespace;      // Cloudflare KV for rate limiting
}
```

## Standard Handler Structure

Every handler file exports a **single function** with this exact signature:

```typescript
// FILE: workers/src/handlers/feature_action.ts
import { Env } from '../types/env';
import { jsonSuccess, jsonError } from '../utils/response';
import { verifyUser } from '../middleware/auth';
import { checkRateLimit } from '../middleware/rate_limit';

export async function handleFeatureAction(
  request: Request,
  env: Env
): Promise<Response> {
  // 1. CORS preflight
  if (request.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  // 2. Auth
  const userId = request.headers.get('x-user-id');
  const authOk = await verifyUser(userId, env);
  if (!authOk) return jsonError('Unauthorized', 401);

  // 3. Rate limit
  const allowed = await checkRateLimit(`remove-bg:${userId}`, 10, env);
  if (!allowed) return jsonError('Rate limit exceeded', 429);

  // 4. Parse + validate body
  const body = await request.json() as FeatureRequestBody;
  if (!body.requiredField) return jsonError('requiredField is required', 400);

  // 5. Business logic via service
  try {
    const result = await someService(body, env);
    return jsonSuccess({ result });
  } catch (error) {
    console.error('[feature-action]', error);
    return jsonError('Internal server error', 500);
  }
}
```

## CORS Headers (Always Use This — Never Inline CORS)

```typescript
// workers/src/middleware/cors.ts
export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, x-user-id',
};
```

## Response Helpers (Always Use These)

```typescript
// workers/src/utils/response.ts
export function jsonSuccess(data: unknown, status = 200): Response {
  return new Response(JSON.stringify({ success: true, data }), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

export function jsonError(message: string, status = 400): Response {
  return new Response(JSON.stringify({ success: false, error: message }), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}
```

## Main Router Pattern (index.ts)

```typescript
// workers/src/index.ts
export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    switch (url.pathname) {
      case '/api/remove-bg':        return handleRemoveBg(request, env);
      case '/api/generate-background': return handleGenerateBackground(request, env);
      case '/api/generate-caption': return handleGenerateCaption(request, env);
      case '/api/create-order':     return handleCreateOrder(request, env);
      case '/api/verify-payment':   return handleVerifyPayment(request, env);
      default: return jsonError('Not found', 404);
    }
  },

  async scheduled(event: ScheduledEvent, env: Env): Promise<void> {
    // CRON: festival notification push — runs daily 6AM IST
    await handleSendFestivalNotifications(env);
  },
};
```

## Auth Middleware

```typescript
// workers/src/middleware/auth.ts
export async function verifyUser(userId: string | null, env: Env): Promise<boolean> {
  if (!userId) return false;
  // Verify user exists in Firestore or via Firebase Auth token verification.
  const res = await fetch(`https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents/users/${userId}`);
  return res.ok;
}
```

## Razorpay HMAC Verification

```typescript
// workers/src/utils/crypto.ts
export async function verifyRazorpaySignature(
  orderId: string,
  paymentId: string,
  signature: string,
  secret: string
): Promise<boolean> {
  const message = `${orderId}|${paymentId}`;
  const key = await crypto.subtle.importKey(
    'raw', new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']
  );
  const sig = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(message));
  const expected = Array.from(new Uint8Array(sig))
    .map(b => b.toString(16).padStart(2, '0')).join('');
  return expected === signature;
}
```

## API Endpoints Reference

| Route | Handler File | Auth | Rate Limit |
|---|---|---|---|
| POST `/api/remove-bg` | `remove_bg.ts` | x-user-id header | 10/min per user |
| POST `/api/generate-background` | `generate_background.ts` | x-user-id header | 5/min per user |
| POST `/api/generate-caption` | `generate_caption.ts` | x-user-id header | 20/min per user |
| POST `/api/create-order` | `create_order.ts` | x-user-id header | 3/min per user |
| POST `/api/verify-payment` | `verify_payment.ts` | x-user-id header | 5/min per user |
| CRON (scheduled) | `send_festival_notifications.ts` | service | N/A |

## Copilot Rules for This Project

1. **One handler = one file** — never combine endpoints
2. **Always validate userId header first** — before parsing body
3. **Always use jsonSuccess/jsonError helpers** — never `new Response(JSON.stringify(...))` inline
4. **Never hardcode env var names** — always use `env.ENV_VAR_NAME` from the Env interface
5. **Rate limit every user-facing endpoint** — use checkRateLimit() middleware
6. **Log errors with context prefix** — `console.error('[handler-name]', error)` format
7. **Razorpay HMAC must use Workers crypto.subtle** — no Node.js crypto module (not available)
8. **All AI calls go through service files** — handlers never call external APIs directly
