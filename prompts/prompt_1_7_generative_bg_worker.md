# PROMPT 1.7 — Generative Background Worker + Flutter Wiring
### Dukaan AI · Two-Agent Session: Dev + Kavya

---

## TASK 1.6 ASSESSMENT — Fix Before Starting

Three categories of failures from `flutter test` and `flutter analyze`:

### Fix A — 3 `flutter analyze` Infos (Paste-Ask — 3 files)

**Attach the 3 affected files, then paste:**

```
Fix these 3 analyzer infos. No logic changes — mechanical fixes only.

1. lib/core/network/cloudflare_client.dart line 65:10
   prefer_const_constructors
   → Add const to the constructor call flagged on that line.

2. lib/features/studio/presentation/screens/camera_capture_screen.dart line 88:11
   use_build_context_synchronously
   → The context.pushReplacement call is inside an async callback (ref.listen
     or similar). Wrap it with: if (context.mounted) { ... }
     Use context.mounted (not just mounted) since this is a ConsumerWidget,
     not a State — mounted is not available directly.

3. lib/shared/services/image_pipeline.dart line 2:8
   unnecessary_import
   → Remove the import 'dart:typed_data'; line. All Uint8List usage is
     already covered by the existing flutter/foundation.dart import.

Output only the 3 corrected files. No other changes.
```

Run: `flutter analyze` → Expected: **No issues found!**

---

### Fix B — 20 Empty Scaffold Test Files (Paste-Ask — no attachments needed)

```
These test files are empty scaffolds from the project setup. They all fail
with "Missing definition of main method". Add void main() {} to each one:

  test/integration/ad_generation_flow_test.dart
  test/integration/auth_flow_test.dart
  test/integration/payment_flow_test.dart
  test/unit/core/utils/festival_calendar_test.dart
  test/unit/core/utils/image_pipeline_test.dart
  test/unit/features/account/domain/profile_repository_test.dart
  test/unit/features/auth/application/auth_provider_test.dart
  test/unit/features/auth/domain/auth_repository_test.dart
  test/unit/features/catalogue/application/catalogue_provider_test.dart
  test/unit/features/khata/application/khata_provider_test.dart
  test/unit/features/my_ads/application/my_ads_provider_test.dart
  test/unit/features/pricing/application/payment_provider_test.dart
  test/unit/features/studio/application/ad_creation_provider_test.dart
  test/unit/features/upi_poster/application/upi_poster_provider_test.dart
  test/widget/features/auth/welcome_screen_test.dart
  test/widget/features/catalogue/catalogue_list_screen_test.dart
  test/widget/features/khata/khata_screen_test.dart
  test/widget/features/my_ads/my_ads_screen_test.dart
  test/widget/features/pricing/pricing_screen_test.dart
  test/widget/features/studio/ad_result_screen_test.dart
  test/widget/features/studio/studio_home_screen_test.dart

Each file should contain ONLY:
  // Placeholder — filled in a later task.
  void main() {}

Output all 21 files.
```

---

### Fix C — `capture_provider_test.dart` Stale Assertion (Paste-Ask)

**Attach `test/features/studio/application/capture_provider_test.dart`, then paste:**

```
test/features/studio/application/capture_provider_test.dart
Line 250 fails:
  Expected: <Instance of 'CaptureImageReady'>
  Actual:   <Instance of 'CaptureProcessed'>

In Task 1.6, capture_provider.processImage() was updated to emit
CaptureProcessed instead of CaptureImageReady after background removal.
The test was not updated.

FIX — In the test at line ~250:

REMOVE:
  expect(state.value, isA<CaptureImageReady>());
  // and any assertion that reads state.value.base64Image
  // using the CaptureImageReady cast

REPLACE WITH:
  expect(state.value, isA<CaptureProcessed>());
  final processed = state.value as CaptureProcessed;
  expect(processed.processedBase64, isNotEmpty);

Only change assertions that reference CaptureImageReady in the
processImage success test. Do not change any other test.

Output only the corrected capture_provider_test.dart.
```

Then: `flutter test test/features/studio/` → Expected: **all pass**

---

## TASK 1.7 — THE ACTUAL PROMPT

### STEP 1 — ATTACH THESE FILES

#### Part A — Dev Agent

| # | File | Why |
|---|---|---|
| 1 | `copilot-instructions.md` | Global rules |
| 2 | `workers.instructions.md` | Handler structure, env vars, rate limits |
| 3 | `SKILL.md` → *cloudflare-worker-patterns* | Env interface, response helpers, routing |
| 4 | `cloudflare-worker.prompt.md` | Build template |
| 5 | `workers/src/index.ts` | ACTUAL — add generate-background case |
| 6 | `workers/src/types/env.ts` | ACTUAL — Env interface reference |
| 7 | `workers/src/middleware/auth.ts` | ACTUAL — verifyUser pattern |
| 8 | `workers/src/middleware/rate-limit.ts` | ACTUAL — checkRateLimit pattern |
| 9 | `workers/src/utils/response.ts` | ACTUAL — jsonSuccess/jsonError helpers |

#### Part B — Kavya Agent (new session)

| # | File | Why |
|---|---|---|
| 1 | `copilot-instructions.md` | Global rules |
| 2 | `flutter.instructions.md` | Error patterns, GoRouter, navigation |
| 3 | `SKILL.md` → *supabase-schema* | Table names, column names, storage buckets |
| 4 | `SKILL.md` → *riverpod-patterns* | Notifier, provider injection pattern |
| 5 | `SKILL.md` → *testing-patterns* | AAA, mock patterns |
| 6 | `ad_generation_service.dart` | ACTUAL — replace stub |
| 7 | `background_select_provider.dart` | ACTUAL — activate navigation TODO |
| 8 | `background_select_screen.dart` | ACTUAL — activate navigation ref.listen block |
| 9 | `studio_repository.dart` | ACTUAL — add saveGeneratedAd |
| 10 | `studio_repository_impl.dart` | ACTUAL — implement saveGeneratedAd |
| 11 | `generated_ad.dart` | ACTUAL — domain model shape |
| 12 | `app_routes.dart` | ACTUAL — add adPreview constant |
| 13 | `app_router.dart` | ACTUAL — add AdPreviewScreen route |
| 14 | `app_strings.dart` | ACTUAL — add new strings |
| 15 | `cloudflare_client.dart` | ACTUAL — CloudflareClient shape |

### Agent Handoff: Dev first → Kavya second

---

### STEP 2A — PASTE INTO COPILOT CHAT (Dev Agent)

```
════════════════════════════════════════════════════════
  PROJECT CONTEXT — ALWAYS INCLUDE IN EVERY SESSION
════════════════════════════════════════════════════════

PROJECT: Dukaan AI — Cloudflare Workers backend
Env interface is in workers/src/types/env.ts — NEVER invent new env var names.
Handler already exists for /api/remove-bg (remove_bg.ts). Follow the same
pattern exactly for the new /api/generate-background handler.

REPLICATE NOTES:
  • env var name: REPLICATEAPITOKEN (exact, from Env interface)
  • Rate limit for this endpoint: 5 per user per hour
  • Flux-Schnell is async — must poll for completion (max 30 seconds)
  • Replicate output is a URL[] — first element is the image URL
  • DO NOT fetch the image from the URL inside the Worker
    (the URL is returned to Flutter directly)

════════════════════════════════════════════════════════
  TASK 1.7A — POST /api/generate-background Worker
════════════════════════════════════════════════════════

────────────────────────────────────────
  FILE 1 — workers/src/services/replicate.ts    (NEW)
────────────────────────────────────────

Wraps the Replicate Flux-Schnell API. Handlers NEVER call external APIs
directly — all external calls go through service files.

  interface PredictionResponse {
    id: string;
    status: 'starting' | 'processing' | 'succeeded' | 'failed' | 'canceled';
    output?: string[];
    error?: string;
  }

  export async function generateWithFluxSchnell(
    prompt: string,
    apiToken: string,
  ): Promise<string> {
    // 1. Create prediction
    const createRes = await fetch(
      'https://api.replicate.com/v1/models/black-forest-labs/flux-schnell/predictions',
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${apiToken}`,
          'Content-Type': 'application/json',
          'Prefer': 'respond-async',
        },
        body: JSON.stringify({
          input: {
            prompt,
            aspect_ratio: '1:1',
            output_format: 'jpeg',
            output_quality: 80,
            num_inference_steps: 4,   // flux-schnell default for speed
          },
        }),
      },
    );

    if (!createRes.ok) {
      const err = await createRes.text();
      throw new Error(`Replicate create failed: ${createRes.status} ${err}`);
    }

    const prediction = await createRes.json() as PredictionResponse;

    // 2. Poll until succeeded or failed (max 30 seconds, 2s interval = 15 attempts)
    for (let i = 0; i < 15; i++) {
      await delay(2000);

      const pollRes = await fetch(
        `https://api.replicate.com/v1/predictions/${prediction.id}`,
        {
          headers: { 'Authorization': `Bearer ${apiToken}` },
        },
      );

      const result = await pollRes.json() as PredictionResponse;

      if (result.status === 'succeeded' && result.output?.[0]) {
        return result.output[0];   // URL to generated image (JPEG)
      }

      if (result.status === 'failed' || result.status === 'canceled') {
        throw new Error(`Replicate generation ${result.status}: ${result.error ?? 'unknown'}`);
      }
      // else: still 'starting' or 'processing' — continue polling
    }

    throw new Error('Replicate timeout: generation exceeded 30 seconds');
  }

  function delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

────────────────────────────────────────
  FILE 2 — workers/src/utils/prompt_builder.ts    (NEW)
────────────────────────────────────────

Builds the Replicate prompt from the selected style ID + optional custom prompt.
This is pure logic — no I/O.

  const STYLE_PROMPTS: Record<string, string> = {
    white:
      'pure white studio background, seamless, professional product photography, soft shadows, high detail',
    gradient_orange:
      'warm saffron orange gradient background, product photography, Indian festive aesthetic, soft ambient light',
    diwali:
      'festive Diwali setting, golden diyas, fairy lights, marigold flowers, warm golden hour lighting, photorealistic product photography',
    holi:
      'vibrant Holi celebration background, colorful powder dust, cheerful Indian festival aesthetic, photorealistic',
    independence_day:
      'Indian Independence Day theme, tricolor saffron white green, patriotic bokeh, clean professional backdrop',
    wooden:
      'natural wooden texture background, rustic Indian craftsmanship aesthetic, warm tones, product photography',
    bokeh:
      'soft bokeh out-of-focus background, shallow depth of field, studio lighting, professional product photography',
    studio:
      'modern neon-lit dark studio backdrop, blue purple ambient lighting, minimal dark background, premium product photography',
    bazaar:
      'lush Indian bazaar market background, morning sunlight, green foliage, colorful stalls, photorealistic',
    festive_red:
      'rich festive red background, golden decorative elements, Indian celebration aesthetic, luxurious product display',
  };

  const DEFAULT_PROMPT =
    'high quality product photography background, Indian aesthetic, clean professional backdrop, soft studio lighting';

  export function buildStylePrompt(
    style: string,
    customPrompt?: string,
  ): string {
    const base = STYLE_PROMPTS[style] ?? DEFAULT_PROMPT;
    if (customPrompt && customPrompt.trim().length > 0) {
      return `${base}, ${customPrompt.trim()}`;
    }
    return base;
  }

────────────────────────────────────────
  FILE 3 — workers/src/handlers/generate_bg.ts    (NEW)
────────────────────────────────────────

  import { corsHeaders } from '../middleware/cors';
  import { jsonError, jsonSuccess } from '../utils/response';
  import { verifyUser } from '../middleware/auth';
  import { checkRateLimit } from '../middleware/rate-limit';
  import { generateWithFluxSchnell } from '../services/replicate';
  import { buildStylePrompt } from '../utils/prompt_builder';
  import type { Env } from '../types/env';

  interface GenerateBgBody {
    productBase64?: string;   // not used in generation itself — style drives the image
    style?: string;
    customPrompt?: string;
  }

  export async function handleGenerateBg(
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

    // 3. Auth — x-user-id header
    const userId = request.headers.get('x-user-id');
    if (!userId) return jsonError('userId required', 400);

    const userValid = await verifyUser(userId, env);
    if (!userValid) return jsonError('Unauthorized', 401);

    // 4. Rate limit — AI endpoint, 5 per hour
    const limited = await checkRateLimit('generate-bg', userId, 5, env);
    if (limited) {
      return jsonError('Aaj ka limit khatam ho gaya. Kal dobara try karein.', 429);
    }

    // 5. Parse and validate body
    let body: GenerateBgBody;
    try {
      body = await request.json() as GenerateBgBody;
    } catch {
      return jsonError('Invalid JSON body', 400);
    }

    if (!body.style) return jsonError('style is required', 400);

    // Basic custom prompt length guard
    if (body.customPrompt && body.customPrompt.length > 200) {
      return jsonError('customPrompt too long (max 200 characters)', 400);
    }

    // 6. Build prompt and call Replicate
    const prompt = buildStylePrompt(body.style, body.customPrompt);

    try {
      const resultUrl = await generateWithFluxSchnell(prompt, env.REPLICATEAPITOKEN);
      return jsonSuccess({
        resultUrl,
        styleUsed: body.style,
      });
    } catch (error) {
      console.error('generate-bg', error);
      return jsonError('Kuch gadbad ho gayi. Dobara try karein.', 500);
    }
  }

────────────────────────────────────────
  FILE 4 — workers/src/index.ts    (MODIFIED — add one case)
────────────────────────────────────────

ADD import at top:
  import { handleGenerateBg } from './handlers/generate_bg';

ADD case in switch (before default):
  case '/api/generate-background':
    return handleGenerateBg(request, env);

────────────────────────────────────────
  FILE 5 — workers/src/handlers/generate_bg.test.ts    (NEW)
────────────────────────────────────────

  describe('handleGenerateBg', () => {

    Test 1: returns 400 when x-user-id header is missing
    Test 2: returns 401 when verifyUser returns false
    Test 3: returns 429 when rate limit exceeded
      expect body.error to contain 'limit'
    Test 4: returns 400 when style is missing from body
    Test 5: returns 400 when customPrompt exceeds 200 characters
    Test 6: returns 200 with resultUrl and styleUsed on success
      mock: generateWithFluxSchnell → 'https://replicate.delivery/...'
      expect: status 200
      expect: body.data.resultUrl is truthy
      expect: body.data.styleUsed === body style sent
    Test 7: returns 500 when Replicate throws an error
      mock: generateWithFluxSchnell → throws Error
      expect: status 500
      expect: body.error contains 'gadbad'
    Test 8: buildStylePrompt uses custom prompt when provided
      (unit test for prompt_builder.ts directly — no Worker mock needed)
      expect: buildStylePrompt('diwali', 'add sparkles') to contain 'sparkles'
  })

────────────────────────────────────────
  OUTPUT ORDER
────────────────────────────────────────

  1. workers/src/utils/prompt_builder.ts        (NEW)
  2. workers/src/services/replicate.ts          (NEW)
  3. workers/src/handlers/generate_bg.ts        (NEW)
  4. workers/src/handlers/generate_bg.test.ts   (NEW)
  5. workers/src/index.ts                       (MODIFIED)

────────────────────────────────────────
  DO NOT (Part A)
────────────────────────────────────────

✗ DO NOT fetch the generated image inside the Worker — return the URL to Flutter
✗ DO NOT upload to R2 or Supabase Storage from the Worker — Flutter handles persistence
✗ DO NOT hardcode REPLICATEAPITOKEN — always use env.REPLICATEAPITOKEN
✗ DO NOT use the productBase64 as input to Flux-Schnell — Flux-Schnell is
  text-to-image; the product image compositing is handled by Flutter (Task 1.8)
✗ DO NOT use Node.js setTimeout — use: new Promise(r => setTimeout(r, ms))
✗ DO NOT call the Replicate service directly from the handler
✗ DO NOT add R2 bucket binding — not in the current Env interface
✗ DO NOT change rate limit to anything other than 5 per hour for this endpoint
```

### Part A Commands

```bash
cd workers
npm test
# Expected: 8/8 generate_bg tests pass + all prior tests still pass
```

---

### STEP 2B — PASTE INTO COPILOT CHAT (Kavya Agent — New Session)

```
════════════════════════════════════════════════════════
  PROJECT CONTEXT — ALWAYS INCLUDE IN EVERY SESSION
════════════════════════════════════════════════════════

PROJECT: Dukaan AI — Flutter app wiring for ad generation
CURRENT STATE:
  • BackgroundSelectScreen and backgroundSelectProvider exist (Task 1.6)
  • AdGenerationService throws UnimplementedError (stub from Task 1.6)
  • backgroundSelectProvider.generateAd() has TODO for navigation
  • BackgroundSelectScreen has a commented-out navigation block

FLOW AFTER THIS TASK:
  User taps "Generate Ad"
  → backgroundSelectProvider.generateAd()
  → AdGenerationService.generateAd()
  → POST /api/generate-background via CloudflareClient (get resultUrl)
  → http.get(resultUrl) to download image bytes
  → supabase.storage.from('ad-images').uploadBinary(...)
  → supabase.from('generatedads').insert(...)
  → return GeneratedAd with signed URL
  → background_select_provider sets generatedAd state
  → ref.invalidate(studioProvider) → Studio recent ads refreshes
  → BackgroundSelectScreen navigates to AdPreviewScreen

RULES:
  • Supabase table constants: SupabaseTables.generatedAds, SupabaseTables.profiles
  • Column constants: SupabaseColumns.userId, SupabaseColumns.createdAt, etc.
  • Storage bucket: 'ad-images' — signed URLs expire after 3600 seconds
  • RLS: imageurl stored as PATH (userId/uuid.jpg), NOT as a signed URL
  • All user-visible strings → AppStrings.*
  • http.get() uses package:http/http.dart (already in pubspec)
  • uuid: ^4.4.0 is in pubspec — use const Uuid().v4() for unique filenames

════════════════════════════════════════════════════════
  TASK 1.7B — AdGenerationService + Repository + AdPreviewScreen
════════════════════════════════════════════════════════

────────────────────────────────────────
  CHANGE 1 — studio_repository.dart interface    (MODIFIED)
────────────────────────────────────────

ADD this method to the StudioRepository abstract interface:

  /// Inserts a new row into generatedads and returns a GeneratedAd
  /// with a fresh signed URL (valid 3600 seconds).
  Future<GeneratedAd> saveGeneratedAd({
    required String userId,
    required String storagePath,   // e.g. 'userId/uuid.jpg'
    required String backgroundStyle,
  });

────────────────────────────────────────
  CHANGE 2 — studio_repository_impl.dart    (MODIFIED)
────────────────────────────────────────

IMPLEMENT the saveGeneratedAd() method:

  @override
  Future<GeneratedAd> saveGeneratedAd({
    required String userId,
    required String storagePath,
    required String backgroundStyle,
  }) async {
    try {
      // Insert row (captionhindi, captionenglish added in Task 1.9)
      final row = await supabase
          .from(SupabaseTables.generatedAds)
          .insert({
            SupabaseColumns.userId: userId,
            'imageurl': storagePath,          // stored as path, not URL
            'backgroundstyle': backgroundStyle,
            'sharecount': 0,
            'downloadcount': 0,
          })
          .select()
          .single();

      // Generate fresh signed URL for immediate display
      final signedUrl = await supabase.storage
          .from('ad-images')
          .createSignedUrl(storagePath, 3600);

      return GeneratedAd(
        id: row['id'] as String,
        imageUrl: signedUrl,
        backgroundStyle: row['backgroundstyle'] as String?,
        shareCount: (row['sharecount'] as int?) ?? 0,
        downloadCount: (row['downloadcount'] as int?) ?? 0,
        createdAt: DateTime.parse(row[SupabaseColumns.createdAt] as String),
      );
    } on PostgrestException catch (e) {
      throw AppException.supabase(e.message);
    } on StorageException catch (e) {
      throw AppException.storage(e.message);
    }
  }

────────────────────────────────────────
  CHANGE 3 — ad_generation_service.dart    (MODIFIED — replace stub)
────────────────────────────────────────

REPLACE the entire file:

  import 'dart:typed_data';
  import 'package:http/http.dart' as http;
  import 'package:uuid/uuid.dart';
  import 'package:riverpod_annotation/riverpod_annotation.dart';
  // + app imports: CloudflareClient, StudioRepository, AdCreationRequest,
  //   GeneratedAd, AppException, AppStrings, cloudflareClientProvider,
  //   studioRepositoryProvider

  part 'ad_generation_service.g.dart';

  class AdGenerationService {
    const AdGenerationService({
      required this.cloudflareClient,
      required this.studioRepository,
    });

    final CloudflareClient cloudflareClient;
    final StudioRepository studioRepository;

    /// Generates a background via Cloudflare Worker (Flux-Schnell/Replicate),
    /// downloads the result, uploads to Supabase Storage, saves the record,
    /// and returns a [GeneratedAd] with a fresh signed URL.
    Future<GeneratedAd> generateAd(AdCreationRequest request) async {
      // 1. Call Worker → get Replicate output URL
      final data = await cloudflareClient.post(
        endpoint: '/api/generate-background',
        body: {
          'productBase64': request.processedImageBase64,
          'style': request.backgroundStyleId,
          if (request.customPrompt != null && request.customPrompt!.isNotEmpty)
            'customPrompt': request.customPrompt!,
        },
        userId: request.userId,
      );

      final resultUrl = data['resultUrl'] as String;

      // 2. Download generated image (uses http package — runs in Isolate OK,
      //    but image is ~100-200KB JPEG so synchronous in service is acceptable)
      final Uint8List imageBytes = await _downloadImage(resultUrl);

      // 3. Upload to Supabase Storage ad-images bucket
      final storagePath = '${request.userId}/${const Uuid().v4()}.jpg';
      await _uploadToStorage(storagePath, imageBytes);

      // 4. Save record to generatedads table + return with signed URL
      return studioRepository.saveGeneratedAd(
        userId: request.userId,
        storagePath: storagePath,
        backgroundStyle: request.backgroundStyleId,
      );
    }

    Future<Uint8List> _downloadImage(String url) async {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode != 200) {
          throw AppException.network(AppStrings.errorImageDownload);
        }
        return response.bodyBytes;
      } catch (e) {
        if (e is AppException) rethrow;
        throw AppException.network(AppStrings.errorNetwork);
      }
    }

    Future<void> _uploadToStorage(String path, Uint8List bytes) async {
      // Access supabase via studioRepository.supabase — or use the
      // Supabase singleton: SupabaseClient.instance
      // Use the singleton since AdGenerationService is not a repository
      try {
        await SupabaseClient.instance.storage
            .from('ad-images')
            .uploadBinary(
              path,
              bytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: false,
              ),
            );
      } on StorageException catch (e) {
        throw AppException.storage(e.message);
      }
    }
  }

  @riverpod
  AdGenerationService adGenerationService(AdGenerationServiceRef ref) {
    final client = ref.watch(cloudflareClientProvider);
    final repo = ref.watch(studioRepositoryProvider);
    return AdGenerationService(
      cloudflareClient: client,
      studioRepository: repo,
    );
  }

────────────────────────────────────────
  CHANGE 4 — background_select_provider.dart    (MODIFIED)
────────────────────────────────────────

TWO changes:

  a) In generateAd(), REMOVE the `on UnimplementedError` catch block.
     The service is now real — UnimplementedError will never be thrown.

  b) AFTER `state = state.copyWith(isGenerating: false, generatedAd: result);`
     ADD this line to refresh Studio screen's recent ads list:
       ref.invalidate(studioProvider);

  No other changes to this file.

────────────────────────────────────────
  CHANGE 5 — background_select_screen.dart    (MODIFIED)
────────────────────────────────────────

In the ref.listen block, UNCOMMENT and ACTIVATE the Task 1.8 navigation:

  REMOVE:
    // TODO Task 1.8: Navigate to AdPreviewScreen when generatedAd is set
    // if (next.generatedAd != null) {
    //   context.push(AppRoutes.adPreview, extra: next.generatedAd);
    // }

  REPLACE WITH (active code):
    if (next.generatedAd != null && prev?.generatedAd == null) {
      // Navigation guard: only trigger once when ad first appears
      if (context.mounted) {
        context.push(AppRoutes.adPreview, extra: next.generatedAd);
      }
    }

  No other changes to this file.

────────────────────────────────────────
  CHANGE 6 — app_routes.dart    (MODIFIED)
────────────────────────────────────────

ADD:
  static const adPreview = '/studio/ad-preview';

────────────────────────────────────────
  CHANGE 7 — app_router.dart    (MODIFIED)
────────────────────────────────────────

ADD the AdPreviewScreen route as a peer of backgroundSelect (same nesting level):

  GoRoute(
    path: AppRoutes.adPreview,
    builder: (context, state) => const AdPreviewScreen(),
  ),

────────────────────────────────────────
  NEW FILE 1 — lib/features/studio/presentation/screens/ad_preview_screen.dart
────────────────────────────────────────

STUB ONLY — full share/download/caption UI built in Task 1.8.

  class AdPreviewScreen extends ConsumerWidget {
    const AdPreviewScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final ad = GoRouterState.of(context).extra! as GeneratedAd;

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text(
            AppStrings.adPreviewTitle,
            style: AppTypography.headlineMedium,
          ),
          actions: [
            // TODO Task 1.8: Add Regenerate button here
            const SizedBox(width: AppSpacing.md),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: CachedNetworkImage(
                imageUrl: ad.imageUrl,
                placeholder: (context, url) => const ShimmerBox(
                  width: double.infinity,
                  height: 360,
                ),
                errorWidget: (context, url, error) => Container(
                  width: double.infinity,
                  height: 360,
                  color: AppColors.divider,
                  child: const Icon(Icons.broken_image_outlined, size: 48),
                ),
                fit: BoxFit.contain,
                memCacheWidth: 720,
              ),
            ),
          ),
        ),
        // Stub bottom bar — full actions in Task 1.8
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              AppStrings.adPreviewActionsComingSoon,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
  }

────────────────────────────────────────
  CHANGE 8 — app_strings.dart    (MODIFIED — add only)
────────────────────────────────────────

  // Ad preview screen
  static const adPreviewTitle              = 'Aapka ad taiyaar hai!';
  static const adPreviewActionsComingSoon  = 'Share, save aur caption jaldi aa raha hai...';

  // Error strings for ad generation
  static const errorImageDownload          = 'Image download nahi hua. Dobara try karein.';
  static const errorAdSaveFailed           = 'Ad save karne mein problem hui.';

────────────────────────────────────────
  NEW FILE 2 — tests    (NEW)
────────────────────────────────────────

test/features/studio/infrastructure/ad_generation_service_test.dart:

  class MockCloudflareClient extends Mock implements CloudflareClient {}
  class MockStudioRepository extends Mock implements StudioRepository {}
  class MockHttpClient extends Mock implements http.Client {}

  final testAd = GeneratedAd(
    id: 'ad-001',
    imageUrl: 'https://supabase.../signed-url.jpg',
    backgroundStyle: 'diwali',
    shareCount: 0,
    downloadCount: 0,
    createdAt: DateTime(2026, 4, 5),
  );

  group('AdGenerationService', () {

    Test 1: generateAd() calls POST /api/generate-background with correct body
      mock: cloudflareClient.post → { 'resultUrl': 'https://replicate/img.jpg' }
      mock: http.get → Response with 200 + fake JPEG bytes
      mock: SupabaseClient.instance.storage.uploadBinary → succeeds
      mock: studioRepository.saveGeneratedAd → testAd
      await service.generateAd(testRequest)
      verify: cloudflareClient.post called with endpoint '/api/generate-background'
      verify: body contains 'style' key

    Test 2: generateAd() returns GeneratedAd on success
      (same mocks as Test 1)
      expect: result.id == testAd.id
      expect: result.imageUrl == testAd.imageUrl

    Test 3: generateAd() propagates AppException.workerRateLimit from cloudflareClient
      mock: cloudflareClient.post throws AppException.workerRateLimit('...')
      expect: throws AppException
      verify: studioRepository.saveGeneratedAd never called

    Test 4: generateAd() throws AppException.network when http.get returns non-200
      mock: cloudflareClient.post → { 'resultUrl': '...' }
      mock: http.get → Response with 500
      expect: throws AppException
      verify: studioRepository.saveGeneratedAd never called

    Test 5: generateAd() passes customPrompt in body when provided
      mock: request.customPrompt = 'blue marble'
      verify: body map contains 'customPrompt': 'blue marble'

    Test 6: generateAd() omits customPrompt from body when null
      mock: request.customPrompt = null
      verify: body map does NOT contain 'customPrompt' key

    Test 7: saveGeneratedAd() calls studioRepository with correct storagePath pattern
      verify: storagePath starts with userId and ends with '.jpg'
  })

────────────────────────────────────────
  OUTPUT ORDER (12 files total)
────────────────────────────────────────

MODIFIED (7 files):
  1. lib/features/studio/domain/repositories/studio_repository.dart
  2. lib/features/studio/infrastructure/studio_repository_impl.dart
  3. lib/features/studio/infrastructure/ad_generation_service.dart
  4. lib/features/studio/application/background_select_provider.dart
  5. lib/features/studio/presentation/screens/background_select_screen.dart
  6. lib/core/constants/app_routes.dart
  7. lib/core/constants/app_strings.dart

NEW (3 files):
  8.  lib/features/studio/presentation/screens/ad_preview_screen.dart
  9.  lib/core/router/app_router.dart  (MODIFIED — add adPreview route)
  10. test/features/studio/infrastructure/ad_generation_service_test.dart

Generated (build_runner handles):
  11. lib/features/studio/infrastructure/ad_generation_service.g.dart
      (re-generated: constructor changed from const to required fields)

────────────────────────────────────────
  DO NOT (Part B)
────────────────────────────────────────

✗ DO NOT store signed URLs in the database — store the storage PATH only
  (signed URLs expire; paths are permanent)
✗ DO NOT use SupabaseClient directly in backgroundSelectProvider
  — it must call AdGenerationService which calls the repository
✗ DO NOT trigger navigation inside generateAd() in the provider
  — navigation is handled by ref.listen in BackgroundSelectScreen
✗ DO NOT build the full share/download UI in AdPreviewScreen (Task 1.8)
✗ DO NOT remove the on AppException catch block from generateAd() in provider
✗ DO NOT use uuid.v1() — use const Uuid().v4() for storage filenames
✗ DO NOT skip the context.mounted check before context.push
✗ DO NOT call ref.invalidate(studioProvider) from AdGenerationService
  — invalidation happens in backgroundSelectProvider after the service call
```

---

## STEP 3 — AFTER COPILOT RESPONDS

```bash
# Part A validation
cd workers && npm test
# Expected: 8/8 generate_bg + 6/6 remove_bg = 14 total pass

# Part B validation
dart run build_runner build --delete-conflicting-outputs
# Expected: clean, ad_generation_service.g.dart re-generated

flutter analyze
# Expected: No issues found!

flutter test
# Expected: 48+ passed, 0 failed

# Targeted suite
flutter test test/features/studio/
# Expected: 30+ passed, 0 failed

# End-to-end manual test
flutter run --dart-define=WORKER_BASE_URL=http://localhost:8787
# Flow:
#   a. Start: cd workers && wrangler dev --local (in separate terminal)
#   b. Tap FAB → camera → take photo
#   c. "Background hatao" → processing overlay
#   d. BackgroundSelectScreen appears with 10 style cards
#   e. Select "Diwali" → tap "Ad banao"
#   f. Button shows spinner while generating (isGenerating: true)
#   g. After ~10 seconds: navigates to AdPreviewScreen
#   h. AdPreviewScreen shows the generated image from Supabase signed URL
#   i. Back on Studio screen: Recent Ads list updates with new ad
#   j. Error case: select a style, disable internet → SnackBar appears
#      "Kuch gadbad ho gayi. Dobara try karein."
```

---

## VALIDATION CHECKLIST

**Worker (Part A)**
- [ ] `generate_bg.ts` calls `verifyUser` before parsing body
- [ ] `checkRateLimit('generate-bg', userId, 5, env)` — rate limit is 5 (not 10)
- [ ] Replicate service polls up to 15 times with 2-second delay
- [ ] `prompt_builder.ts` has all 10 style IDs matching `BackgroundStyle.all` in Flutter
- [ ] Handler returns `{ resultUrl, styleUsed }` — does NOT fetch or store image
- [ ] Hinglish error on 500: "Kuch gadbad ho gayi. Dobara try karein."
- [ ] Hinglish error on 429: "Aaj ka limit khatam ho gaya..."
- [ ] 8/8 Worker tests pass

**Flutter (Part B)**
- [ ] `AdGenerationService` constructor has `cloudflareClient` + `studioRepository`
- [ ] Storage path format: `userId/uuid.jpg` (NOT a signed URL)
- [ ] `saveGeneratedAd()` generates signed URL before returning `GeneratedAd`
- [ ] `background_select_provider.dart` calls `ref.invalidate(studioProvider)` after success
- [ ] Navigation guard uses `context.mounted` (ConsumerWidget, not State)
- [ ] Navigation only fires when `prev?.generatedAd == null && next.generatedAd != null`
- [ ] `AdPreviewScreen` reads `extra` as `GeneratedAd` (not `String`)
- [ ] `on UnimplementedError` catch REMOVED from backgroundSelectProvider
- [ ] `build_runner` clean
- [ ] `flutter analyze` zero issues
- [ ] 7 ad_generation_service tests pass

---

## WHAT COMES NEXT

> **Task 1.8 — Ad Result Screen (Full)**
> Builds the complete `AdPreviewScreen` replacing the Task 1.7 stub.
> Adds: bottom action sheet with Share to WhatsApp (share_plus), Save to
> Gallery (image_gallery_saver), Copy Caption, and Regenerate button.
> Wires the share count/download count tracking to Supabase.
> Also adds watermark overlay on free-tier users (check userTier from
> studioProvider profile). Pure Kavya session — no new Worker endpoints.
>
> **Task 1.9 — AI Caption Generator Worker + Flutter Wiring**
> Dev writes `POST /api/generate-caption` Worker (OpenAI GPT-4o-mini),
> rate limit 20/hour. Kavya adds a caption state to BackgroundSelectState
> and calls the caption Worker immediately after ad generation succeeds.
> Backfills `captionhindi`/`captionenglish` in the saved `generatedads` row.

---

*Dukaan AI v1.0 Build Playbook · Task 1.7 · Generated April 2026*
