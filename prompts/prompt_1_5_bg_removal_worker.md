# PROMPT 1.5 — Background Removal Worker + Flutter Wiring
### Dukaan AI · Task 1.5 · Two-Agent Session: Dev + Kavya

---

## PREREQUISITE — Fix 5 Failing `studio_provider_test.dart` Tests First

The `flutter test test/features/studio/` output shows `0005 10 -5 Some tests failed`.
Five `studio_provider_test.dart` tests fail because the test container watches
`supabaseClientProvider`, which calls `Supabase.instance` — a real singleton that
is NOT initialized in tests. The fix is one additional override in `setUp`.

### Paste-Ask (attach `studio_provider_test.dart` ACTUAL file):

```
studio_provider_test.dart: all 5 tests throw:
  ProviderException → Supabase.instance.isInitialized == false

The test container overrides studioRepositoryProvider but does NOT override
supabaseClientProvider. Studio.build() calls ref.watch(supabaseClientProvider),
which reaches the real Supabase singleton that isn't initialized in test.

FIX — Add these to studio_provider_test.dart ONLY:

1. Add two mock classes (after existing mocks):
     class MockSupabaseClient extends Mock implements SupabaseClient {}
     class MockGoTrueClient extends Mock implements GoTrueClient {}

2. In setUp() (or in the container builder helper), create:
     final mockClient = MockSupabaseClient();
     final mockGoTrue = MockGoTrueClient();
     when(() => mockClient.auth).thenReturn(mockGoTrue);

   For tests where userId must be non-null (happy path):
     when(() => mockGoTrue.currentUser).thenReturn(
       User(id: 'test-uid', appMetadata: {}, userMetadata: {},
            aud: '', createdAt: ''));

   For tests where userId must be null (unauthenticated path):
     when(() => mockGoTrue.currentUser).thenReturn(null);

3. Add supabaseClientProvider override in EVERY ProviderContainer:
     supabaseClientProvider.overrideWithValue(mockClient),

Output ONLY the corrected studio_provider_test.dart.
Do not change any other file.
```

Then run:
```bash
flutter test test/features/studio/
# Expected: +15 All tests passed!
```

---

## TASK 1.5 — PART A: Cloudflare Worker (Dev Agent)

### STEP 1 — ATTACH THESE FILES

| # | File | Why |
|---|---|---|
| 1 | `copilot-instructions.md` | Global rules |
| 2 | `workers.instructions.md` | Exact handler structure, env vars, CORS |
| 3 | `SKILL.md` → *cloudflare-worker-patterns* | Standard patterns — rate limiting, Env interface |
| 4 | `cloudflare-worker.prompt.md` | Build template |
| 5 | `workers/src/index.ts` | ACTUAL file — router to update |
| 6 | `workers/src/types/env.ts` | ACTUAL file — Env interface |
| 7 | `workers/src/middleware/auth.ts` | ACTUAL file — verifyUser pattern |
| 8 | `workers/src/middleware/rate-limit.ts` | ACTUAL file — checkRateLimit pattern |
| 9 | `workers/src/utils/response.ts` | ACTUAL file — jsonSuccess/jsonError helpers |

### Agent: Dev (worker-dev.agent.md) — ACTIVATE

---

### STEP 2 — PASTE INTO COPILOT CHAT

```
════════════════════════════════════════════════════════
  PROJECT CONTEXT — ALWAYS INCLUDE IN EVERY SESSION
════════════════════════════════════════════════════════

PROJECT: Dukaan AI — Cloudflare Workers backend
Runtime: V8 isolates, Web API only (no Node.js)
Language: TypeScript strict mode
Entry: workers/src/index.ts → routes to handlers
Pattern: One handler per file in workers/src/handlers/

Env vars come from the Env interface in workers/src/types/env.ts.
NEVER invent new env var names — only use names already in Env.
Rate limit every AI endpoint via checkRateLimit middleware.
Auth every request via verifyUser middleware.
Use jsonSuccess / jsonError helpers — never inline JSON.stringify.

════════════════════════════════════════════════════════
  TASK 1.5A — POST /api/remove-bg Handler
════════════════════════════════════════════════════════

Create a new Cloudflare Worker handler for background removal.

────────────────────────────────────────
  FILE 1 — workers/src/handlers/remove_bg.ts    (NEW)
────────────────────────────────────────

ENDPOINT: POST /api/remove-bg

REQUEST HEADERS:
  x-user-id: string   ← authenticated user's UUID

REQUEST BODY (JSON):
  {
    "imageBase64": string   ← JPEG/PNG as base64 encoded string
  }

RESPONSE BODY (success):
  {
    "success": true,
    "data": {
      "resultBase64": string,   ← processed image as base64
      "creditsUsed": 1
    }
  }

HANDLER STEPS (in this exact order):

  1. CORS preflight
       if OPTIONS → return new Response(null, { headers: corsHeaders })

  2. Method guard
       if not POST → jsonError('Method not allowed', 405)

  3. Auth: read userId from header
       const userId = request.headers.get('x-user-id');
       if (!userId) → jsonError('userId required', 400)

  4. Verify user exists in Supabase
       const valid = await verifyUser(userId, env);
       if (!valid) → jsonError('Unauthorized', 401)

  5. Rate limit — AI endpoint, max 10 per hour per user
       const limited = await checkRateLimit('remove-bg', userId, 10, env);
       if (limited) → jsonError('Aaj ka limit khatam ho gaya. Kal dobara try karein.', 429)

  6. Parse and validate body
       const body = await request.json() as { imageBase64?: string };
       if (!body.imageBase64) → jsonError('imageBase64 required', 400)
       Basic length guard:
       if (body.imageBase64.length > 10_000_000)
         → jsonError('Image too large. Maximum 10MB supported.', 413)

  7. Call AI Engine service (wrapped in try/catch)
       const resultBase64 = await removeBackgroundFromImage(
         body.imageBase64, env.AIENGINEAPIKEY
       );
       → jsonSuccess({ resultBase64, creditsUsed: 1 })

  8. Error handling
       on fetch/timeout errors:
         console.error('remove-bg', error);
         → jsonError('Kuch gadbad ho gayi. Dobara try karein.', 500)

────────────────────────────────────────
  FILE 2 — workers/src/services/ai_engine.ts    (NEW)
────────────────────────────────────────

This service wraps the AI Engine API call.
Handlers call services — handlers never call external APIs directly.

  export async function removeBackgroundFromImage(
    imageBase64: string,
    apiKey: string,
  ): Promise<string> {
    const response = await fetch(
      'https://api.ai-engine.net/v1/remove-background',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`,
        },
        body: JSON.stringify({ image: imageBase64 }),
      }
    );

    if (!response.ok) {
      const err = await response.text();
      throw new Error(`AI Engine ${response.status}: ${err}`);
    }

    const data = await response.json() as { result: string };
    return data.result;
  }

────────────────────────────────────────
  FILE 3 — workers/src/index.ts    (MODIFIED — add one case)
────────────────────────────────────────

Add inside the switch statement, before the default case:

  case '/api/remove-bg':
    return handleRemoveBg(request, env);

Import handleRemoveBg at the top:
  import { handleRemoveBg } from './handlers/remove_bg';

────────────────────────────────────────
  FILE 4 — workers/wrangler.toml    (MODIFIED — add env var note)
────────────────────────────────────────

Ensure AIENGINEAPIKEY is documented in the [vars] section.
If it already exists, make no change to wrangler.toml.
If missing, add:

  # Background removal — set actual value via: wrangler secret put AIENGINEAPIKEY
  # AIENGINEAPIKEY = ""    ← DO NOT commit real value; use wrangler secrets

────────────────────────────────────────
  FILE 5 — workers/src/handlers/remove_bg.test.ts    (NEW)
────────────────────────────────────────

Unit tests using Vitest (the project's test runner for Workers).

  describe('handleRemoveBg', () => {

    Test 1: returns 400 when x-user-id header is missing
      mock: no x-user-id header
      expect: status 400, body.error truthy

    Test 2: returns 401 when verifyUser returns false
      mock: x-user-id present, verifyUser → false
      expect: status 401

    Test 3: returns 429 when rate limit exceeded
      mock: verifyUser → true, checkRateLimit → true (limited)
      expect: status 429
      expect: body.error contains 'limit'

    Test 4: returns 400 when imageBase64 is missing from body
      mock: verifyUser → true, checkRateLimit → false,
            body = {}
      expect: status 400

    Test 5: returns 200 with resultBase64 on success
      mock: verifyUser → true, checkRateLimit → false,
            body = { imageBase64: 'base64string' },
            removeBackgroundFromImage → 'processedBase64'
      expect: status 200
      expect: body.data.resultBase64 === 'processedBase64'
      expect: body.data.creditsUsed === 1

    Test 6: returns 500 when AI Engine throws
      mock: removeBackgroundFromImage → throws Error
      expect: status 500
      expect: body.error contains 'gadbad'
  })

────────────────────────────────────────
  OUTPUT ORDER
────────────────────────────────────────

  1. workers/src/services/ai_engine.ts          (NEW)
  2. workers/src/handlers/remove_bg.ts          (NEW)
  3. workers/src/handlers/remove_bg.test.ts     (NEW)
  4. workers/src/index.ts                       (MODIFIED)
  5. workers/wrangler.toml                      (MODIFIED only if AIENGINEAPIKEY missing)

────────────────────────────────────────
  DO NOT
────────────────────────────────────────

✗ DO NOT call external APIs directly from the handler — use the service
✗ DO NOT log the base64 image content — only log errors with console.error
✗ DO NOT invent new env var names — use env.AIENGINEAPIKEY from the Env interface
✗ DO NOT use Node.js Buffer — base64 strings are passed as-is
✗ DO NOT skip the verifyUser middleware call — required on all AI endpoints
✗ DO NOT use catch-all error handler that swallows the original message
✗ DO NOT return the AI Engine's error message directly to client — use Hinglish
```

### Part A Commands

```bash
cd workers
npm test                        # Expected: 6/6 handler tests pass
wrangler dev --local            # Smoke test: POST /api/remove-bg
```

---

## TASK 1.5 — PART B: Flutter Wiring (Kavya Agent)

### STEP 3 — NEW SESSION — ATTACH THESE FILES

| # | File | Why |
|---|---|---|
| 1 | `copilot-instructions.md` | Global rules |
| 2 | `flutter.instructions.md` | Error handling, AppException pattern |
| 3 | `SKILL.md` → *riverpod-patterns* | cloudflareClientProvider pattern |
| 4 | `SKILL.md` → *cloudflare-worker-patterns* | x-user-id header, endpoint paths |
| 5 | `background_removal_service.dart` | ACTUAL file — replace stub |
| 6 | `capture_provider.dart` | ACTUAL file — update error handling |
| 7 | `shared_providers.dart` | ACTUAL file — add cloudflareClientProvider |
| 8 | `app_strings.dart` | ACTUAL file — add new error strings |
| 9 | `pubspec.yaml` | ACTUAL file — add http dependency |

### Agent: Kavya (ui-engineer.agent.md) — CONTINUE

---

### STEP 4 — PASTE INTO COPILOT CHAT

```
════════════════════════════════════════════════════════
  PROJECT CONTEXT — ALWAYS INCLUDE IN EVERY SESSION
════════════════════════════════════════════════════════

PROJECT: Dukaan AI — Flutter app wiring to Cloudflare Workers
The Workers backend is at a single base URL (configured via --dart-define).
All Worker calls send x-user-id header for auth.
All Worker responses follow: { success: bool, data?: {...}, error?: string }
Error pattern: on 429 → AppException.workerRateLimit, on 5xx → AppException.workerError
Use AppStrings for ALL user-visible strings.

════════════════════════════════════════════════════════
  TASK 1.5B — CloudflareClient + BackgroundRemovalService
════════════════════════════════════════════════════════

Wire the Flutter app to the new POST /api/remove-bg Worker.
Replace the UnimplementedError stub with a real HTTP call.

────────────────────────────────────────
  DEPENDENCY — pubspec.yaml
────────────────────────────────────────

Add to dependencies (keep alphabetical order with existing packages):

  http: ^1.2.0

Then: flutter pub get

────────────────────────────────────────
  FILE 1 — lib/core/config/app_config.dart    (NEW)
────────────────────────────────────────

  class AppConfig {
    AppConfig._();

    /// Cloudflare Worker base URL.
    /// Set via: flutter run --dart-define=WORKER_BASE_URL=https://...
    /// Default points to local wrangler dev for development.
    static const workerBaseUrl = String.fromEnvironment(
      'WORKER_BASE_URL',
      defaultValue: 'http://localhost:8787',
    );
  }

────────────────────────────────────────
  FILE 2 — lib/core/network/cloudflare_client.dart    (NEW)
────────────────────────────────────────

HTTP client for all Cloudflare Worker calls.
Always sends x-user-id header. Parses Worker response format.

  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import 'package:riverpod_annotation/riverpod_annotation.dart';
  // + app imports: AppConfig, AppException, AppStrings

  part 'cloudflare_client.g.dart';

  class CloudflareClient {
    CloudflareClient({required this.baseUrl});
    final String baseUrl;
    final _client = http.Client();

    /// POST to [endpoint] with [body], authenticated as [userId].
    /// Returns the `data` field from Worker success response.
    /// Throws [AppException] on all error responses.
    Future<Map<String, dynamic>> post({
      required String endpoint,
      required Map<String, dynamic> body,
      required String userId,
    }) async {
      try {
        final response = await _client
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'x-user-id': userId,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

        final json = jsonDecode(response.body) as Map<String, dynamic>;

        if (response.statusCode == 429) {
          throw AppException.workerRateLimit(
            json['error'] as String? ?? AppStrings.errorRateLimit,
          );
        }

        if (response.statusCode >= 500) {
          throw AppException.workerError(
            json['error'] as String? ?? AppStrings.errorGeneric,
          );
        }

        if (response.statusCode >= 400) {
          throw AppException.workerError(
            json['error'] as String? ?? AppStrings.errorGeneric,
          );
        }

        return json['data'] as Map<String, dynamic>? ?? {};
      } on AppException {
        rethrow;
      } catch (e) {
        throw AppException.network(AppStrings.errorNetwork);
      }
    }
  }

  @riverpod
  CloudflareClient cloudflareClient(CloudflareClientRef ref) {
    return CloudflareClient(baseUrl: AppConfig.workerBaseUrl);
  }

IMPORTANT: This provider is named cloudflareClientProvider (generated).
Other providers that need it use: ref.watch(cloudflareClientProvider)

────────────────────────────────────────
  FILE 3 — lib/features/studio/infrastructure/background_removal_service.dart
           (MODIFIED — replace stub with real implementation)
────────────────────────────────────────

REPLACE the entire file:

  import 'package:riverpod_annotation/riverpod_annotation.dart';
  // + app imports: CloudflareClient, cloudflareClientProvider

  part 'background_removal_service.g.dart';

  class BackgroundRemovalService {
    const BackgroundRemovalService({required this.client});
    final CloudflareClient client;

    /// Sends [base64Image] to POST /api/remove-bg.
    /// Returns the processed image as a base64 string.
    /// Throws [AppException.workerRateLimit] if daily limit reached.
    /// Throws [AppException.workerError] on AI Engine failure.
    Future<String> removeBackground({
      required String base64Image,
      required String userId,
    }) async {
      final data = await client.post(
        endpoint: '/api/remove-bg',
        body: {'imageBase64': base64Image},
        userId: userId,
      );
      return data['resultBase64'] as String;
    }
  }

  @riverpod
  BackgroundRemovalService backgroundRemovalService(
    BackgroundRemovalServiceRef ref,
  ) {
    final client = ref.watch(cloudflareClientProvider);
    return BackgroundRemovalService(client: client);
  }

────────────────────────────────────────
  FILE 4 — lib/features/studio/application/capture_provider.dart
           (MODIFIED — update processImage error handling)
────────────────────────────────────────

In the processImage() method, REPLACE the catch blocks:

REMOVE this catch block (stub-specific):
  on UnimplementedError {
    state = CaptureError(message: AppStrings.errorBgRemovalComingSoon);
  }

REPLACE the full try/catch with:
  try {
    final service = ref.read(backgroundRemovalServiceProvider);
    final processedBase64 = await service.removeBackground(
      base64Image: current.base64Image,
      userId: userId,
    );
    // TODO Task 1.6: Navigate to BackgroundSelectScreen with processedBase64
    state = CaptureImageReady(
      imageBytes: current.imageBytes,
      base64Image: processedBase64,
    );
  } on AppException catch (e) {
    state = CaptureError(message: e.userMessage);
  } catch (e) {
    state = CaptureError(message: AppStrings.errorCaptureGeneric);
  }

Note: AppException must expose a userMessage getter that returns the
Hinglish string. If not yet implemented, add:
  String get userMessage => when(
    workerRateLimit: (msg) => msg,
    workerError: (msg) => msg,
    network: (msg) => msg,
    supabase: (msg) => AppStrings.errorGeneric,
    storage: (msg) => AppStrings.errorGeneric,
    unknown: (msg) => AppStrings.errorGeneric,
  );

────────────────────────────────────────
  FILE 5 — lib/core/constants/app_strings.dart
           (MODIFIED — add new strings only)
────────────────────────────────────────

ADD these constants:

  // Network & Worker errors
  static const errorNetwork      = 'Internet connection nahi hai. Check karein.';
  static const errorRateLimit    = 'Aaj ka limit khatam ho gaya. Kal dobara try karein.';
  static const errorGeneric      = 'Kuch gadbad ho gayi. Dobara try karein.';

  // Background removal
  static const bgRemovalSuccess  = 'Background hat gaya!';

────────────────────────────────────────
  FILE 6 — tests  (NEW)
────────────────────────────────────────

test/core/network/cloudflare_client_test.dart:

  class MockHttpClient extends Mock implements http.Client {}

  Test 1: post() returns data map on 200 response
  Test 2: post() throws AppException.workerRateLimit on 429
  Test 3: post() throws AppException.workerError on 500
  Test 4: post() throws AppException.network on network failure (throw SocketException)
  Test 5: x-user-id header is always sent

test/features/studio/infrastructure/background_removal_service_test.dart:

  class MockCloudflareClient extends Mock implements CloudflareClient {}

  Test 1: removeBackground() calls POST /api/remove-bg and returns resultBase64
  Test 2: removeBackground() propagates AppException.workerRateLimit from client
  Test 3: removeBackground() propagates AppException.workerError from client

────────────────────────────────────────
  OUTPUT ORDER
────────────────────────────────────────

  1. pubspec.yaml                                               (MODIFIED)
  2. lib/core/config/app_config.dart                           (NEW)
  3. lib/core/network/cloudflare_client.dart                   (NEW)
  4. lib/features/studio/infrastructure/background_removal_service.dart (MODIFIED)
  5. lib/features/studio/application/capture_provider.dart     (MODIFIED)
  6. lib/core/constants/app_strings.dart                       (MODIFIED)
  7. test/core/network/cloudflare_client_test.dart             (NEW)
  8. test/features/studio/infrastructure/background_removal_service_test.dart (NEW)

────────────────────────────────────────
  DO NOT
────────────────────────────────────────

✗ DO NOT use dio — use package:http/http.dart
✗ DO NOT hardcode the Worker URL — use AppConfig.workerBaseUrl
✗ DO NOT send Authorization Bearer token — Workers use x-user-id header only
✗ DO NOT catch AppException inside CloudflareClient — let it propagate
✗ DO NOT add the on UnimplementedError catch block back
✗ DO NOT forget the .timeout(Duration(seconds: 30)) on post()
✗ DO NOT forget part 'cloudflare_client.g.dart' in the new file
```

---

## STEP 5 — AFTER COPILOT RESPONDS

```bash
# 1. Generate new provider
dart run build_runner build --delete-conflicting-outputs
# New: lib/core/network/cloudflare_client.g.dart

# 2. Analysis — zero issues
flutter analyze
# Expected: No issues found!

# 3. All tests
flutter test
# Expected: 20+ passed, 0 failed

# 4. End-to-end smoke test
# Start Worker locally:
cd workers && wrangler dev --local

# In another terminal — run app pointed to local worker:
cd ..
flutter run --dart-define=WORKER_BASE_URL=http://localhost:8787

# Verify:
#   a. Tap FAB → camera opens
#   b. Take photo → bottom sheet appears
#   c. Tap "Remove Background"
#      → processing overlay shows ("AI magic ho raha hai...")
#      → Worker receives request (check wrangler dev logs)
#      → On success: state becomes CaptureImageReady with processed base64
#      → On rate limit: SnackBar shows "Aaj ka limit khatam ho gaya..."
```

---

## STEP 6 — CHECKLIST

**Worker (Part A)**
- [ ] Handler sends CORS preflight response for OPTIONS
- [ ] `verifyUser` called before parsing body
- [ ] `checkRateLimit('remove-bg', userId, 10, env)` called
- [ ] AI Engine call is in `ai_engine.ts` service, NOT in handler
- [ ] Hinglish error message returned on 429 and 500
- [ ] Base64 image not logged (PII/size)
- [ ] 6/6 Worker unit tests pass

**Flutter (Part B)**
- [ ] `http: ^1.2.0` added to pubspec.yaml
- [ ] `CloudflareClient.post()` has 30-second timeout
- [ ] `x-user-id` header set on every request
- [ ] 429 → `AppException.workerRateLimit` (not a generic error)
- [ ] `BackgroundRemovalService` takes `CloudflareClient` in constructor
- [ ] `backgroundRemovalServiceProvider` watches `cloudflareClientProvider`
- [ ] `capture_provider.dart` catches `AppException` — NOT `UnimplementedError`
- [ ] `build_runner` clean, `flutter analyze` zero issues
- [ ] 8 new tests pass

---

## WHAT COMES NEXT

> **Task 1.6 — Background Selection Screen**
> Builds `BackgroundSelectScreen` — the 2×5 grid of 10 preset background
> styles, a custom prompt TextField, and a sticky "Generate Ad" button.
> Wires the navigation from `capture_provider.processImage()` to this screen
> passing the processed base64 image. Activates the `generate-background`
> Worker (Task 1.7) as a new stub. Pure Flutter/Kavya session — no new
> Cloudflare Workers in Task 1.6.

---

*Dukaan AI v1.0 Build Playbook · Task 1.5 · Generated April 2026*
