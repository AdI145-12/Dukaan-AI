# PROMPT 1.9 — AI Caption Generator Worker + Flutter Wiring
### Dukaan AI · Two-Agent Session: Dev + Kavya

---

## TASK 1.8 ASSESSMENT — One Fix Before Starting

### Fix A — Regenerating Overlay Test (Paste-Ask — 1 file)

**Root cause:** `thenAnswer((_) async => completer.future)` wraps the
Completer's future in an extra async layer. The outer layer resolves as a
microtask **before** `pump()` can process the `setState(_isRegenerating = true)`
rebuild, so the overlay is never visible at assertion time.

**Attach `test/features/studio/presentation/screens/ad_preview_screen_test.dart`, then paste:**

```
The test "shows regenerating overlay when isRegenerating is true" fails
with "Found 0 widgets with text 'Naya ad ban raha hai...'".

Root cause: thenAnswer((_) async => completer.future) creates an extra
async wrapper that resolves in a microtask before pump() processes the
setState rebuild.

FIX ONLY this one test:

STEP 1 — Change mock setup:
  REMOVE:   .thenAnswer((_) async => completer.future);
  REPLACE:  .thenAnswer((_) => completer.future);
  // No 'async' keyword — return completer.future directly

STEP 2 — After the tap, pump TWICE:
  await tester.tap(find.text(AppStrings.regenerateButton));
  await tester.pump();          // processes tap + schedules rebuild
  await tester.pump();          // processes setState(_isRegenerating = true) rebuild
  expect(find.text(AppStrings.regeneratingMessage), findsOneWidget);

Do not change any other test. Output only the corrected file.
```

Then run: `flutter test test/features/studio/presentation/`
Expected: **6/6 pass**

---

## TASK 1.9 — THE ACTUAL PROMPT

### STEP 1 — ATTACH THESE FILES

#### Part A — Dev Agent

| # | File | Why |
|---|---|---|
| 1 | `copilot-instructions.md` | Global rules |
| 2 | `workers.instructions.md` | Handler structure, CACHEKV usage |
| 3 | `SKILL.md` → *cloudflare-worker-patterns* | Env interface, rate limits table |
| 4 | `workers/src/index.ts` | ACTUAL — add generate-caption case |
| 5 | `workers/src/types/env.ts` | ACTUAL — verify OPENAIAPIKEY, CACHEKV present |
| 6 | `workers/src/handlers/generate_bg.ts` | ACTUAL — follow same pattern |
| 7 | `workers/src/utils/response.ts` | ACTUAL — helpers |

#### Part B — Kavya Agent (New Session)

| # | File | Why |
|---|---|---|
| 1 | `copilot-instructions.md` | Global rules |
| 2 | `flutter.instructions.md` | Error handling, provider injection |
| 3 | `SKILL.md` → *supabase-schema* | generatedads columns captionhindi, captionenglish |
| 4 | `SKILL.md` → *riverpod-patterns* | Provider + service injection pattern |
| 5 | `SKILL.md` → *testing-patterns* | AAA, mock patterns |
| 6 | `ad_preview_screen.dart` | ACTUAL — add caption auto-generation |
| 7 | `studio_repository.dart` | ACTUAL — add updateCaption |
| 8 | `studio_repository_impl.dart` | ACTUAL — implement updateCaption |
| 9 | `generated_ad.dart` | ACTUAL — has captionHindi/captionEnglish fields |
| 10 | `cloudflare_client.dart` | ACTUAL — CloudflareClient.post signature |
| 11 | `app_strings.dart` | ACTUAL — add caption strings |

### Agent Handoff: Dev first → Kavya second

---

### STEP 2A — PASTE INTO COPILOT CHAT (Dev Agent)

```
════════════════════════════════════════════════════════
  PROJECT CONTEXT — ALWAYS INCLUDE IN EVERY SESSION
════════════════════════════════════════════════════════

PROJECT: Dukaan AI — Cloudflare Workers
EXISTING ENDPOINTS: /api/remove-bg, /api/generate-background
NEW ENDPOINT THIS TASK: POST /api/generate-caption

ENV VARS (from env.ts — use these exact names):
  env.OPENAIAPIKEY     → OpenAI API key (GPT-4o-mini captions)
  env.CACHEKV          → KV namespace for response caching
  env.RATELIMITKV      → KV namespace for rate limiting (separate from cache)
  Rate limit for this endpoint: 20 per user per hour

RATE LIMIT PATTERN (copy from generate_bg.ts):
  await checkRateLimit('generate-caption', userId, 20, env)
  429 Hinglish error: "Aaj ka caption limit khatam ho gaya. Kal dobara try karein."

CACHE PATTERN (use CACHEKV, not RATELIMITKV):
  GET:  await env.CACHEKV.get(cacheKey)
  PUT:  await env.CACHEKV.put(key, value, { expirationTtl: 3600 })
  Cache key format: caption:{language}:{category}:{productName.toLowerCase()}:{offer ?? ''}

════════════════════════════════════════════════════════
  TASK 1.9A — POST /api/generate-caption Worker
════════════════════════════════════════════════════════

────────────────────────────────────────
  FILE 1 — workers/src/services/openai.ts    (NEW)
────────────────────────────────────────

  interface CaptionResult {
    caption: string;
    hashtags: string[];
  }

  const LANGUAGE_DESCRIPTIONS: Record<string, string> = {
    hindi:    'Hindi (written in Devanagari script)',
    english:  'English',
    hinglish: 'Hinglish (Hindi words in Roman/English script, e.g. "Aaj ki offer amazing hai!")',
  };

  // Exported so tests can call it directly for unit coverage
  export function buildSystemPrompt(language: string): string {
    const lang = LANGUAGE_DESCRIPTIONS[language] ?? LANGUAGE_DESCRIPTIONS['hinglish'];
    return (
      `You are an expert Indian social media marketer who writes viral ad captions ` +
      `for small business owners in ${lang}. ` +
      `Write in a friendly, energetic tone. Use relatable language. Include relevant emojis. ` +
      `Keep it under 150 characters. ` +
      `Return ONLY valid JSON with keys: ` +
      `"caption" (string) and "hashtags" (array of exactly 5 strings WITHOUT the # symbol).`
    );
  }

  // Exported for unit testing
  export function buildUserMessage(
    productName: string,
    category: string,
    offer?: string,
  ): string {
    const trimmedName = productName.trim();
    let msg = trimmedName
      ? `Write an ad caption for "${trimmedName}" in the category "${category}".`
      : `Write a general ad caption for a product in the "${category}" category.`;
    if (offer?.trim()) msg += ` Highlight this offer: ${offer.trim()}`;
    return msg;
  }

  export async function generateCaptionWithGpt(
    productName: string,
    category: string,
    language: string,
    offer: string | undefined,
    apiKey: string,
  ): Promise<CaptionResult> {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: buildSystemPrompt(language) },
          { role: 'user', content: buildUserMessage(productName, category, offer) },
        ],
        response_format: { type: 'json_object' },
        max_tokens: 250,
        temperature: 0.8,
      }),
    });

    if (!response.ok) {
      const errText = await response.text();
      throw new Error(`OpenAI API error: ${response.status} - ${errText}`);
    }

    const data = await response.json() as {
      choices: Array<{ message: { content: string } }>;
    };

    const content = data.choices?.[0]?.message?.content;
    if (!content) throw new Error('OpenAI returned empty response');

    let parsed: { caption?: string; hashtags?: unknown };
    try {
      parsed = JSON.parse(content) as typeof parsed;
    } catch {
      throw new Error(`OpenAI returned non-JSON content: ${content.slice(0, 100)}`);
    }

    return {
      caption: typeof parsed.caption === 'string' ? parsed.caption : '',
      hashtags: Array.isArray(parsed.hashtags)
        ? (parsed.hashtags as unknown[]).slice(0, 5).map(String)
        : [],
    };
  }

────────────────────────────────────────
  FILE 2 — workers/src/handlers/generate_caption.ts    (NEW)
────────────────────────────────────────

  import { corsHeaders } from '../middleware/cors';
  import { jsonError, jsonSuccess } from '../utils/response';
  import { verifyUser } from '../middleware/auth';
  import { checkRateLimit } from '../middleware/rate-limit';
  import { generateCaptionWithGpt } from '../services/openai';
  import type { Env } from '../types/env';

  interface GenerateCaptionBody {
    productName?: string;
    category?: string;
    language?: string;
    offer?: string;
  }

  const VALID_LANGUAGES = new Set(['hindi', 'english', 'hinglish']);
  const VALID_CATEGORIES = new Set([
    'saree', 'gadget', 'food', 'jewelry', 'clothing', 'electronics',
    'cosmetics', 'furniture', 'books', 'sports', 'general',
  ]);

  export async function handleGenerateCaption(
    request: Request,
    env: Env,
  ): Promise<Response> {
    // 1. CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    // 2. Method guard
    if (request.method !== 'POST') {
      return jsonError('Method not allowed', 405);
    }

    // 3. Auth
    const userId = request.headers.get('x-user-id');
    if (!userId) return jsonError('userId required', 400);

    const userValid = await verifyUser(userId, env);
    if (!userValid) return jsonError('Unauthorized', 401);

    // 4. Rate limit — 20 per hour (AI endpoint, lighter than bg generation)
    const limited = await checkRateLimit('generate-caption', userId, 20, env);
    if (limited) {
      return jsonError(
        'Aaj ka caption limit khatam ho gaya. Kal dobara try karein.', 429,
      );
    }

    // 5. Parse body
    let body: GenerateCaptionBody;
    try {
      body = await request.json() as GenerateCaptionBody;
    } catch {
      return jsonError('Invalid JSON body', 400);
    }

    // 6. Sanitize inputs — unknown values fall back to safe defaults
    const productName = (body.productName ?? '').trim().slice(0, 100);
    const category    = VALID_CATEGORIES.has(body.category ?? '')
                          ? body.category!
                          : 'general';
    const language    = VALID_LANGUAGES.has(body.language ?? '')
                          ? body.language!
                          : 'hinglish';
    const offer       = (body.offer ?? '').trim().slice(0, 100) || undefined;

    // 7. Cache lookup — use CACHEKV (not RATELIMITKV)
    const cacheKey = `caption:${language}:${category}:${productName.toLowerCase()}:${offer ?? ''}`;
    const cached = await env.CACHEKV.get(cacheKey);
    if (cached) {
      return jsonSuccess({ ...(JSON.parse(cached) as object), cached: true });
    }

    // 8. Generate via OpenAI
    try {
      const result = await generateCaptionWithGpt(
        productName, category, language, offer, env.OPENAIAPIKEY,
      );

      const payload = { caption: result.caption, hashtags: result.hashtags, language };

      // Cache result for 1 hour to save API costs on duplicate requests
      await env.CACHEKV.put(cacheKey, JSON.stringify(payload), { expirationTtl: 3600 });

      return jsonSuccess(payload);
    } catch (error) {
      console.error('generate-caption', error);
      return jsonError('Caption generate nahi hua. Dobara try karein.', 500);
    }
  }

────────────────────────────────────────
  FILE 3 — workers/src/handlers/generate_caption.test.ts    (NEW)
────────────────────────────────────────

  describe('handleGenerateCaption', () => {

    Test 1: returns 400 when x-user-id header is missing
      POST /api/generate-caption with no x-user-id header
      expect: status 400, body.error truthy

    Test 2: returns 401 when verifyUser returns false
      mock verifyUser → false
      expect: status 401

    Test 3: returns 429 when rate limit exceeded
      mock checkRateLimit → true (limited)
      expect: status 429
      expect: body.error contains 'limit'

    Test 4: returns cached result without calling OpenAI
      mock CACHEKV.get → returns valid JSON string of cached result
      mock generateCaptionWithGpt → should NOT be called (verify never called)
      expect: status 200
      expect: body.data.cached === true

    Test 5: returns 200 with caption, hashtags, language on success
      mock CACHEKV.get → null (no cache)
      mock generateCaptionWithGpt → { caption: 'Diwali offer!', hashtags: ['diwali',...] }
      expect: status 200
      expect: body.data.caption === 'Diwali offer!'
      expect: body.data.hashtags.length === 5
      expect: body.data.language === 'hinglish'

    Test 6: falls back to 'general' category for unknown category value
      body.category = 'spaceship'  // invalid
      mock generateCaptionWithGpt to capture args
      expect: generateCaptionWithGpt called with category === 'general'

    Test 7: falls back to 'hinglish' language for unknown language value
      body.language = 'klingon'  // invalid
      expect: generateCaptionWithGpt called with language === 'hinglish'

    Test 8: returns 500 when OpenAI throws an error
      mock generateCaptionWithGpt → throws Error('OpenAI down')
      expect: status 500
      expect: body.error contains 'generate'

    Unit tests for openai.ts (no HTTP calls):
    Test 9: buildSystemPrompt includes language description for 'hinglish'
      expect: result contains 'Roman/English script'

    Test 10: buildUserMessage includes offer text when offer provided
      buildUserMessage('Saree', 'clothing', 'FLAT 40% off')
      expect: result contains '40%'

    Test 11: buildUserMessage omits offer clause when offer is undefined
      buildUserMessage('Saree', 'clothing', undefined)
      expect: result NOT to contain 'Highlight'
  })

────────────────────────────────────────
  FILE 4 — workers/src/index.ts    (MODIFIED — add one case)
────────────────────────────────────────

  ADD import:
    import { handleGenerateCaption } from './handlers/generate_caption';

  ADD case (already referenced in the routing table — just uncomment/add):
    case '/api/generate-caption':
      return handleGenerateCaption(request, env);

────────────────────────────────────────
  OUTPUT ORDER (Part A — 4 files)
────────────────────────────────────────

  1. workers/src/services/openai.ts              (NEW)
  2. workers/src/handlers/generate_caption.ts    (NEW)
  3. workers/src/handlers/generate_caption.test.ts  (NEW)
  4. workers/src/index.ts                        (MODIFIED)

────────────────────────────────────────
  DO NOT (Part A)
────────────────────────────────────────

✗ DO NOT call OpenAI directly from the handler — use generateCaptionWithGpt service
✗ DO NOT use RATELIMITKV for caching — use CACHEKV for responses, RATELIMITKV for counts
✗ DO NOT hardcode 'gpt-4o-mini' in the handler — it belongs in the service file
✗ DO NOT skip the KV cache check — caching is required by spec to save API costs
✗ DO NOT use Node.js crypto or Buffer — not available in Workers
✗ DO NOT return hashtags with '#' prefix — the Flutter app adds '#' when displaying
✗ DO NOT limit productName to a required field — it's optional (GPT infers from category)
✗ DO NOT use env.OPENAIAPIKEY anywhere except the openai.ts service
```

### Part A Validation

```bash
cd workers
npm test
# Expected: 11 new tests pass + all prior tests pass (≥ 25 total)
```

---

### STEP 2B — PASTE INTO COPILOT CHAT (Kavya Agent — New Session)

```
════════════════════════════════════════════════════════
  PROJECT CONTEXT — ALWAYS INCLUDE IN EVERY SESSION
════════════════════════════════════════════════════════

PROJECT: Dukaan AI — Flutter caption wiring
CURRENT STATE:
  • ad_preview_screen.dart has Copy Caption button that shows
    "Caption jaldi available hoga." when captionHindi/captionEnglish are null
  • captionHindi and captionEnglish are always null right now (no generator)
  • AdPreviewScreen is a ConsumerStatefulWidget with _currentAd mutable field

TASK 1.9 GOAL:
  Immediately after AdPreviewScreen first loads, auto-call POST /api/generate-caption
  in the background. When it returns, backfill the generatedads row AND setState
  to update _currentAd so Copy Caption works without user doing anything.

CAPTION LANGUAGE RULES (for column mapping):
  • language == 'english'  → store caption in captionEnglish column
  • language == 'hindi' OR 'hinglish' → store caption in captionHindi column
  Caption language selector (Task 1.10) will let users re-generate in other languages.

SUPABASE COLUMN NAMES (exact):
  • 'captionhindi'   maps to SupabaseColumns.captionHindi (if constant exists)
    else use literal 'captionhindi' — never use 'caption_hindi'
  • 'captionenglish' maps to SupabaseColumns.captionEnglish (if constant exists)
    else use literal 'captionenglish'

NON-FATAL RULE:
  Caption generation MUST never block the user or show an error.
  ALL exceptions in _generateCaptionInBackground() must be caught with
  debugPrint only. No SnackBars for failure. Show SnackBar ONLY on success.

════════════════════════════════════════════════════════
  TASK 1.9B — CaptionService + Flutter Wiring
════════════════════════════════════════════════════════

────────────────────────────────────────
  NEW FILE 1 — lib/features/studio/domain/generated_caption.dart    (NEW)
────────────────────────────────────────

Plain Dart class. No freezed. No codegen. No part file.

  class GeneratedCaption {
    const GeneratedCaption({
      required this.caption,
      required this.hashtags,
      required this.language,
    });

    final String caption;
    final List<String> hashtags;   // strings WITHOUT '#' prefix (Worker strips them)
    final String language;         // 'hindi' | 'english' | 'hinglish'

    /// Full caption text with hashtags for sharing/copying
    String get fullText =>
        '$caption\n\n${hashtags.map((h) => '#$h').join(' ')}';
  }

────────────────────────────────────────
  NEW FILE 2 — lib/features/studio/infrastructure/caption_service.dart    (NEW)
────────────────────────────────────────

  import 'package:riverpod_annotation/riverpod_annotation.dart';
  // + app imports: CloudflareClient, GeneratedCaption, AppException,
  //   cloudflareClientProvider

  part 'caption_service.g.dart';

  class CaptionService {
    const CaptionService({required this.cloudflareClient});

    final CloudflareClient cloudflareClient;

    /// Calls POST /api/generate-caption.
    /// productName is optional — GPT infers from category context.
    /// language defaults to 'hinglish'.
    Future<GeneratedCaption> generateCaption({
      required String userId,
      String productName = '',
      String category = 'general',
      String language = 'hinglish',
      String? offer,
    }) async {
      final data = await cloudflareClient.post(
        endpoint: '/api/generate-caption',
        body: {
          'productName': productName,
          'category': category,
          'language': language,
          if (offer != null && offer.isNotEmpty) 'offer': offer,
        },
        userId: userId,
      );

      return GeneratedCaption(
        caption: data['caption'] as String? ?? '',
        hashtags: (data['hashtags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        language: data['language'] as String? ?? language,
      );
    }
  }

  @riverpod
  CaptionService captionService(CaptionServiceRef ref) {
    final client = ref.watch(cloudflareClientProvider);
    return CaptionService(cloudflareClient: client);
  }

────────────────────────────────────────
  CHANGE 1 — studio_repository.dart interface    (MODIFIED)
────────────────────────────────────────

ADD:
  /// Backfills caption columns in generatedads row.
  /// Only updates the columns that are non-null.
  /// Non-fatal — swallows PostgrestException internally.
  Future<void> updateCaption({
    required String adId,
    String? captionHindi,
    String? captionEnglish,
  });

────────────────────────────────────────
  CHANGE 2 — studio_repository_impl.dart    (MODIFIED)
────────────────────────────────────────

IMPLEMENT:
  @override
  Future<void> updateCaption({
    required String adId,
    String? captionHindi,
    String? captionEnglish,
  }) async {
    // Build update map — only include non-null values
    final updates = <String, dynamic>{
      if (captionHindi != null) 'captionhindi': captionHindi,
      if (captionEnglish != null) 'captionenglish': captionEnglish,
    };

    if (updates.isEmpty) return;

    try {
      await supabase
          .from(SupabaseTables.generatedAds)
          .update(updates)
          .eq('id', adId);
    } on PostgrestException catch (e) {
      // Non-fatal: captions are enhancement, not core feature
      debugPrint('updateCaption failed: ${e.message}');
    }
  }

────────────────────────────────────────
  CHANGE 3 — ad_preview_screen.dart    (MODIFIED)
────────────────────────────────────────

ADD ONE field to _AdPreviewScreenState:
  bool _captionGenerated = false;

ADD ONE new private method _generateCaptionInBackground():

  Future<void> _generateCaptionInBackground() async {
    final userId = SupabaseClient.instance.auth.currentUser?.id ?? '';
    if (userId.isEmpty) return;

    try {
      final service = ref.read(captionServiceProvider);
      final result = await service.generateCaption(
        userId: userId,
        category: 'general',      // TODO Task 2.x: read from business profile
        language: 'hinglish',     // TODO Task 1.10: respect user language toggle
      );

      final isEnglish = result.language == 'english';

      // Backfill DB row (non-fatal internally)
      await ref.read(studioRepositoryProvider).updateCaption(
        adId: _currentAd.id,
        captionHindi: isEnglish ? null : result.caption,
        captionEnglish: isEnglish ? result.caption : null,
      );

      if (mounted) {
        setState(() {
          _currentAd = _currentAd.copyWith(
            captionHindi: isEnglish ? _currentAd.captionHindi : result.caption,
            captionEnglish: isEnglish ? result.caption : _currentAd.captionEnglish,
          );
        });
        // Brief success indicator so user knows caption is ready
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.captionReadyMessage),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Caption generation is ALWAYS non-fatal
      debugPrint('_generateCaptionInBackground failed: $e');
    }
  }

MODIFY didChangeDependencies() — ADD the caption trigger:

  if (!_captionGenerated) {
    _captionGenerated = true;
    _generateCaptionInBackground();   // fire-and-forget, non-blocking
  }

  // Place this block AFTER the _analyticsTracked block already there.

No other changes to ad_preview_screen.dart.

────────────────────────────────────────
  CHANGE 4 — app_strings.dart    (MODIFIED — add only)
────────────────────────────────────────

  // Caption generation
  static const captionReadyMessage = 'Caption taiyaar hai! Ab copy kar sakte hain. 🎉';

────────────────────────────────────────
  NEW FILE 3 — test caption service    (NEW)
────────────────────────────────────────

test/features/studio/infrastructure/caption_service_test.dart:

  class MockCloudflareClient extends Mock implements CloudflareClient {}

  void main() {
    late MockCloudflareClient mockClient;
    late CaptionService service;

    setUp(() {
      mockClient = MockCloudflareClient();
      service = CaptionService(cloudflareClient: mockClient);
    });

    group('CaptionService.generateCaption', () {

      Test 1: returns GeneratedCaption with caption and hashtags on success
        mock cloudflareClient.post → {
          'caption': 'Diwali sale amazing hai! 🪔',
          'hashtags': ['diwali', 'offer', 'sale', 'shopping', 'india'],
          'language': 'hinglish',
        }
        result = await service.generateCaption(userId: 'u1')
        expect: result.caption == 'Diwali sale amazing hai! 🪔'
        expect: result.hashtags.length == 5
        expect: result.language == 'hinglish'

      Test 2: fullText getter includes hashtags with # prefix
        final caption = GeneratedCaption(
          caption: 'Amazing!', hashtags: ['sale', 'diwali'], language: 'hinglish')
        expect: caption.fullText contains '#sale'
        expect: caption.fullText contains '#diwali'

      Test 3: passes productName and category in request body
        mock: capture the body argument
        await service.generateCaption(userId: 'u1', productName: 'Silk Saree', category: 'saree')
        verify: body['productName'] == 'Silk Saree'
        verify: body['category'] == 'saree'

      Test 4: omits offer from body when offer is null
        await service.generateCaption(userId: 'u1', offer: null)
        verify: body does NOT contain 'offer' key

      Test 5: includes offer in body when provided
        await service.generateCaption(userId: 'u1', offer: 'FLAT 50% OFF')
        verify: body['offer'] == 'FLAT 50% OFF'

      Test 6: propagates AppException from cloudflareClient
        mock: cloudflareClient.post throws AppException.network('...')
        expect: throws AppException

      Test 7: defaults language to 'hinglish' in request body when not specified
        mock: capture body
        await service.generateCaption(userId: 'u1')
        verify: body['language'] == 'hinglish'

      Test 8: returns empty caption and empty hashtags when server returns empty strings
        mock: { 'caption': '', 'hashtags': [], 'language': 'hinglish' }
        expect: result.caption == ''
        expect: result.hashtags.isEmpty == true
    })
  }

────────────────────────────────────────
  OUTPUT ORDER (Part B — 8 files)
────────────────────────────────────────

NEW (2 files):
  1. lib/features/studio/domain/generated_caption.dart
  2. lib/features/studio/infrastructure/caption_service.dart

MODIFIED (4 files):
  3. lib/features/studio/domain/repositories/studio_repository.dart
  4. lib/features/studio/infrastructure/studio_repository_impl.dart
  5. lib/features/studio/presentation/screens/ad_preview_screen.dart
  6. lib/core/constants/app_strings.dart

TEST (1 file):
  7. test/features/studio/infrastructure/caption_service_test.dart

Generated by build_runner (1 file):
  8. lib/features/studio/infrastructure/caption_service.g.dart

────────────────────────────────────────
  DO NOT (Part B)
────────────────────────────────────────

✗ DO NOT await _generateCaptionInBackground() in didChangeDependencies
   — fire-and-forget is intentional, never block the main thread
✗ DO NOT show a SnackBar when caption generation FAILS
   — debugPrint only, caption failure must be invisible to the user
✗ DO NOT call updateCaption with both null values — the repository impl
   short-circuits with isEmpty check, but passing both null is wasteful
✗ DO NOT add a loading spinner for caption generation on the screen
   — the SnackBar is the only indication. No loading state.
✗ DO NOT use freezed or codegen on GeneratedCaption — plain Dart class
✗ DO NOT use generatedAd.captionHindi directly for display — use _currentAd
   which is the mutable screen-level reference that gets updated via setState
✗ DO NOT forget to add the caption_service.g.dart to the build_runner run
✗ DO NOT hardcode 'captionhindi' string in ad_preview_screen.dart —
   the column name concern lives in studio_repository_impl.dart only
```

---

## STEP 3 — AFTER COPILOT RESPONDS

```bash
# Part A (Worker)
cd C:\dev\smb_ai\workers
npm test
# Expected: ≥25 tests pass (11 new + 14 previous)

# Part B (Flutter)
cd C:\dev\smb_ai
dart run build_runner build --delete-conflicting-outputs
# Expected: caption_service.g.dart generated cleanly

flutter analyze
# Expected: No issues found!

flutter test
# Expected: ≥65 pass, 0 fail

# Targeted suites
flutter test test/features/studio/infrastructure/caption_service_test.dart
# Expected: 8/8 pass

flutter test test/features/studio/presentation/
# Expected: 6/6 pass (including the fixed regenerating overlay test)

# Manual end-to-end
flutter run --dart-define=WORKER_BASE_URL=http://localhost:8787
# (run wrangler dev in parallel terminal)
# Flow:
#   a. Complete full generation: FAB → camera → bg-remove → Diwali → "Ad banao"
#   b. AdPreviewScreen appears immediately with the generated image
#   c. After ~3-5 seconds: SnackBar → "Caption taiyaar hai! Ab copy kar sakte hain. 🎉"
#   d. Tap "Caption copy karo" → caption is now non-empty → copies to clipboard
#   e. Share to WhatsApp — caption text pre-fills in the share sheet
#   f. Supabase Dashboard → generatedads row shows captionhindi filled in
#   g. Error case: kill wrangler dev mid-session → caption silently fails,
#      no crash, no error shown to user
```

---

## VALIDATION CHECKLIST

**Worker (Part A)**
- [ ] `generateCaptionWithGpt` is in `services/openai.ts`, not in the handler
- [ ] Handler uses `CACHEKV` for caching (not `RATELIMITKV`)
- [ ] Cache key includes: language + category + productName + offer
- [ ] Cache TTL is exactly 3600 seconds (1 hour)
- [ ] Rate limit: `checkRateLimit('generate-caption', userId, 20, env)`
- [ ] `buildSystemPrompt` and `buildUserMessage` exported from openai.ts for test coverage
- [ ] Invalid category → falls back to `'general'` (not 400 error)
- [ ] Invalid language → falls back to `'hinglish'` (not 400 error)
- [ ] productName is optional — empty string is valid input
- [ ] 11 Worker tests pass

**Flutter (Part B)**
- [ ] `GeneratedCaption` is a plain Dart class (no `part` file, no build_runner)
- [ ] `CaptionService` has `@riverpod` annotation → `caption_service.g.dart` generated
- [ ] `_generateCaptionInBackground()` is fire-and-forget (not awaited)
- [ ] No SnackBar shown on caption failure — `debugPrint` only
- [ ] Caption success triggers SnackBar: `AppStrings.captionReadyMessage`
- [ ] `_currentAd.copyWith(captionHindi: ...)` updates the screen's mutable reference
- [ ] `updateCaption` in impl has empty-map guard (skips Supabase call if nothing to update)
- [ ] `_captionGenerated` flag prevents duplicate API calls on hot-reload/rebuild
- [ ] `copyCaption()` now finds a non-empty string after caption arrives
- [ ] 8/8 `caption_service_test.dart` tests pass
- [ ] `build_runner` clean
- [ ] `flutter analyze`: No issues found!

---

## WHAT COMES NEXT

> **Task 1.10 — Caption Language Selector Widget**
> Pure UI — no new Workers, no Supabase changes. Builds the
> `CaptionLanguageSelector` StatelessWidget (3 toggle buttons: Hinglish |
> Hindi | English). Places it on AdPreviewScreen above the action bar.
> Selecting a language re-calls `captionService.generateCaption()` with the
> new language, replaces `_currentAd.captionHindi/captionEnglish`, and
> updates the copy + share flows. State for selected language is a local
> `String _selectedLanguage = 'hinglish'` in AdPreviewScreen's state.
>
> After Task 1.10, **Week 1 (Days 1–7) Studio Core is complete**. The next
> session begins Week 2 with Task 2.1 — Khata Digital Ledger Screen.

---

*Dukaan AI v1.0 Build Playbook · Task 1.9 · Generated April 2026*
