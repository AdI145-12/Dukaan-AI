---
mode: agent
description: Create a new Cloudflare Worker endpoint for Dukaan AI
---

# New Cloudflare Worker Endpoint

## Step 1 — Read Existing Workers
Before writing, read `workers/src/` and confirm:
- No existing handler covers this functionality
- Which `env` variables this handler needs (from the approved list in workers.instructions.md)
- Whether this endpoint needs rate limiting (all AI endpoints: YES)

## Step 2 — Create Handler File
File: `workers/src/handlers/${input:handlerName}.ts`

Exact structure to follow:
```typescript
import { corsHeaders, jsonError, jsonSuccess } from '../utils/response';
import { checkRateLimit } from '../middleware/rate-limit';
import { verifyUser } from '../middleware/auth';

interface ${input:HandlerName}Input {
  userId: string;
  // add other required fields
}

export async function handle${input:HandlerName}(
  request: Request,
  env: Env
): Promise<Response> {
  if (request.method === 'OPTIONS') return new Response(null, { headers: corsHeaders });
  if (request.method !== 'POST') return jsonError('Method not allowed', 405);

  // 1. Parse body
  let body: ${input:HandlerName}Input;
  try {
    body = await request.json() as ${input:HandlerName}Input;
  } catch {
    return jsonError('Invalid JSON body', 400);
  }

  // 2. Validate required fields
  if (!body.userId) return jsonError('userId required', 400);

  // 3. Verify user exists (call Supabase)
  const userValid = await verifyUser(body.userId, env);
  if (!userValid) return jsonError('User not found', 401);

  // 4. Rate limit check (for AI endpoints)
  const limited = await checkRateLimit(`${input:endpointKey}:${body.userId}`, ${input:rateLimit}, env);
  if (limited) return jsonError('Aaj ka limit khatam ho gaya. Kal dobara try karein.', 429);

  // 5. Core logic here
  try {
    // ... implementation
    return jsonSuccess({ /* result */ });
  } catch (error) {
    console.error('[${input:handlerName}] Error:', error);
    return jsonError('Kuch gadbad ho gayi. Dobara try karein.', 500);
  }
}
```

## Step 3 — Register in Router
Add route in `workers/src/index.ts`:
```typescript
if (pathname === '/api/${input:routePath}') return handle${input:HandlerName}(request, env);
```

## Step 4 — Add to wrangler.toml
Confirm any new KV bindings or environment variables needed are added to `wrangler.toml`.
Document new env variables in `workers/README.md`.

## Step 5 — Unit Test
Create: `workers/src/handlers/${input:handlerName}.test.ts`
Test: missing fields validation, rate limit hit, successful response, external API failure.
