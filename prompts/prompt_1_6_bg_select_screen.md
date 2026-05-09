# PROMPT 1.6 — Background Selection Screen
### Dukaan AI · Kavya Agent · Pure Flutter Session

---

## PREREQUISITES — Fix Two Hanging Issues First

### Fix A — `package.json` EJSONPARSE (Worker tests blocked)

The `workers/package.json` contains scaffold comment text instead of
valid JSON. This blocks `npm test` entirely.

**Attach `workers/package.json` (ACTUAL broken file), then paste:**

```
Replace the ENTIRE content of workers/package.json with valid JSON.
The workers project uses Vitest for testing and Wrangler for deployment.
Required devDependencies: @cloudflare/workers-types ^4, typescript ^5,
vitest ^1.6, wrangler ^3.

Output ONLY the corrected workers/package.json. No other files.
```

Then run: `cd workers && npm install && npm test`
Expected: 6/6 remove_bg handler tests pass.

---

### Fix B — `app_router_test.dart` timeout (1 Flutter test failing)

The test hangs on `pumpAndSettle` because GoRouter's auth redirect
runs forever when `authStateProvider` returns a stream that never settles.

**Attach `test/app_router_test.dart` (ACTUAL file), then paste:**

```
app_router_test.dart has 1 test failing with a timeout.
Root cause: pumpAndSettle hangs because GoRouter's redirect callback
watches authStateProvider which emits a Stream that never completes,
causing the pump loop to run indefinitely.

FIX — Two changes:

1. In every ProviderContainer/ProviderScope override, add:
     authStateProvider.overrideWith(
       (ref) => Stream.value(const AuthState.unauthenticated()),
     ),
   This gives the router a stable, resolved auth state.

2. Replace every pumpAndSettle() call with:
     await tester.pump();
     await tester.pump(const Duration(milliseconds: 300));
   Per project testing rules: never pumpAndSettle on routes that have
   redirect logic — it creates infinite pump loops.

Output ONLY the corrected app_router_test.dart. No other files.
```

Then run: `flutter test test/app_router_test.dart`
Expected: all pass.

---

## TASK 1.6 — THE ACTUAL PROMPT

### STEP 1 — ATTACH THESE FILES

| # | File | Why |
|---|---|---|
| 1 | `copilot-instructions.md` | Global rules |
| 2 | `flutter.instructions.md` | ConsumerWidget, GoRouter.extra, error patterns |
| 3 | `SKILL.md` → *flutter-design-system* | GridView, card patterns, AppButton, AppSpacing |
| 4 | `SKILL.md` → *riverpod-patterns* | Notifier pattern, supabaseClientProvider |
| 5 | `SKILL.md` → *testing-patterns* | AAA, factory helpers, pumpAndSettle rule |
| 6 | `capture_state.dart` | ACTUAL — add CaptureProcessed here |
| 7 | `capture_provider.dart` | ACTUAL — change processImage emit |
| 8 | `camera_capture_screen.dart` | ACTUAL — add navigation branch |
| 9 | `app_routes.dart` | ACTUAL — add backgroundSelect constant |
| 10 | `app_router.dart` | ACTUAL — add new GoRoute |
| 11 | `app_strings.dart` | ACTUAL — add new strings |
| 12 | `generated_ad.dart` | Context — GeneratedAd shape for stub return |

### Agent: Kavya (ui-engineer.agent.md) — CONTINUE

---

### STEP 2 — PASTE INTO COPILOT CHAT

```
════════════════════════════════════════════════════════
  PROJECT CONTEXT — ALWAYS INCLUDE IN EVERY SESSION
════════════════════════════════════════════════════════

PROJECT: Dukaan AI — Flutter AI ad generator for Indian SMBs
CURRENT STATE:
  • Camera capture pipeline is complete (Tasks 1.1–1.5)
  • After background removal, capture_provider emits CaptureImageReady
    with the processed base64 — this is a TODO that Task 1.6 replaces
  • We now need a NEW sealed state CaptureProcessed, and a full
    Background Selection Screen

RULES:
  • GoRouter extra for screen-to-screen data — never constructor params
  • ConsumerWidget unless TickerProvider needed (then ConsumerStatefulWidget)
  • All strings → AppStrings.*
  • All values → AppColors.* / AppSpacing.* / AppRadius.* / AppTypography.*
  • GridView.builder — NEVER GridView with children list
  • RepaintBoundary around every grid card
  • Notifier (not AsyncNotifier) for mutable UI state machines
  • Never pumpAndSettle in tests that involve routes or redirect logic
  • AdGenerationService is a stub only — Task 1.7 wires the real Worker

════════════════════════════════════════════════════════
  TASK 1.6 — BACKGROUND SELECTION SCREEN
════════════════════════════════════════════════════════

After background removal succeeds, the user sees a 10-option grid of
background styles and an optional custom prompt field.
Tapping "Generate Ad" calls the AdGenerationService stub (wired in Task 1.7).
After generation, navigate to AdPreviewScreen (wired in Task 1.8).

Build order: state extensions → domain models → service stub →
provider → screen → route → tests.

────────────────────────────────────────
  CHANGE 1 — capture_state.dart    (MODIFIED)
────────────────────────────────────────

Add a new sealed subclass AFTER CaptureProcessing:

  class CaptureProcessed extends CaptureState {
    const CaptureProcessed({required this.processedBase64});
    final String processedBase64;
  }

The full sealed class hierarchy is now:
  CaptureInitial | CaptureImageReady | CaptureProcessing
  | CaptureProcessed | CaptureError

────────────────────────────────────────
  CHANGE 2 — capture_provider.dart    (MODIFIED)
────────────────────────────────────────

In processImage(), replace the TODO comment block.
REMOVE:
  // TODO Task 1.6: Navigate to BackgroundSelectScreen with processedBase64
  state = CaptureImageReady(
    imageBytes: current.imageBytes,
    base64Image: processedBase64,
  );

REPLACE WITH:
  state = CaptureProcessed(processedBase64: processedBase64);

No other changes to this file.

────────────────────────────────────────
  CHANGE 3 — camera_capture_screen.dart    (MODIFIED)
────────────────────────────────────────

In _handleStateChange(), add a new branch AFTER the CaptureImageReady branch:

  if (next is CaptureProcessed) {
    // bg removal done — navigate to background selection
    // Use context.pushReplacement so back button returns to Studio, not camera
    if (mounted) {
      context.pushReplacement(
        AppRoutes.backgroundSelect,
        extra: next.processedBase64,
      );
    }
  }

Also add a branch in _buildBody() switch for the new state:

  CaptureProcessed() => const _OpeningCameraBody(),
    // transitional — screen replaces immediately

No other changes to this file.

────────────────────────────────────────
  NEW FILE 1 — lib/features/studio/domain/background_style.dart
────────────────────────────────────────

Constants file. No Riverpod, no freezed — pure Dart class.

  import 'package:flutter/material.dart';

  class BackgroundStyle {
    const BackgroundStyle({
      required this.id,
      required this.displayName,
      required this.previewColor,
    });

    final String id;
    final String displayName;
    final Color previewColor;

    static const List<BackgroundStyle> all = [
      BackgroundStyle(
        id: 'white',
        displayName: 'Safed',
        previewColor: Color(0xFFFFFFFF),
      ),
      BackgroundStyle(
        id: 'gradient_orange',
        displayName: 'Narangi',
        previewColor: Color(0xFFFF6F00),
      ),
      BackgroundStyle(
        id: 'diwali',
        displayName: 'Diwali',
        previewColor: Color(0xFFFFB300),
      ),
      BackgroundStyle(
        id: 'holi',
        displayName: 'Holi',
        previewColor: Color(0xFF9C27B0),
      ),
      BackgroundStyle(
        id: 'independence_day',
        displayName: 'Tiranga',
        previewColor: Color(0xFF1565C0),
      ),
      BackgroundStyle(
        id: 'wooden',
        displayName: 'Lakdi',
        previewColor: Color(0xFF795548),
      ),
      BackgroundStyle(
        id: 'bokeh',
        displayName: 'Soft Blur',
        previewColor: Color(0xFF90CAF9),
      ),
      BackgroundStyle(
        id: 'studio',
        displayName: 'Studio',
        previewColor: Color(0xFF37474F),
      ),
      BackgroundStyle(
        id: 'bazaar',
        displayName: 'Bazaar',
        previewColor: Color(0xFF388E3C),
      ),
      BackgroundStyle(
        id: 'festive_red',
        displayName: 'Laal Utsav',
        previewColor: Color(0xFFC62828),
      ),
    ];
  }

────────────────────────────────────────
  NEW FILE 2 — lib/features/studio/domain/ad_creation_request.dart
────────────────────────────────────────

Simple freezed class. NO json_serializable — passed internally only.
NO part 'ad_creation_request.g.dart' — no JSON needed.

  import 'package:freezed_annotation/freezed_annotation.dart';

  part 'ad_creation_request.freezed.dart';

  @freezed
  class AdCreationRequest with _$AdCreationRequest {
    const factory AdCreationRequest({
      required String processedImageBase64,
      required String backgroundStyleId,
      required String userId,
      String? customPrompt,
    }) = _AdCreationRequest;
  }

────────────────────────────────────────
  NEW FILE 3 — lib/features/studio/infrastructure/ad_generation_service.dart
────────────────────────────────────────

Stub only. Task 1.7 replaces removeAdGeneration with a real Worker call.

  import 'package:riverpod_annotation/riverpod_annotation.dart';
  // + domain imports: AdCreationRequest, GeneratedAd

  part 'ad_generation_service.g.dart';

  class AdGenerationService {
    const AdGenerationService();

    /// Calls the Worker to composite product on background and add captions.
    ///
    /// TODO Task 1.7: Replace with POST /api/generate-ad via CloudflareClient.
    Future<GeneratedAd> generateAd(AdCreationRequest request) async {
      throw UnimplementedError(
        'Ad generation not yet connected. '
        'Implement in Task 1.7 via POST /api/generate-ad.',
      );
    }
  }

  @riverpod
  AdGenerationService adGenerationService(AdGenerationServiceRef ref) {
    return const AdGenerationService();
  }

────────────────────────────────────────
  NEW FILE 4 — lib/features/studio/application/background_select_state.dart
────────────────────────────────────────

  import 'package:freezed_annotation/freezed_annotation.dart';
  // + domain imports: GeneratedAd

  part 'background_select_state.freezed.dart';

  @freezed
  class BackgroundSelectState with _$BackgroundSelectState {
    const factory BackgroundSelectState({
      int? selectedStyleIndex,
      @Default('') String customPrompt,
      @Default(false) bool isGenerating,
      String? error,
      GeneratedAd? generatedAd,   // non-null = generation succeeded → triggers nav
    }) = _BackgroundSelectState;
  }

────────────────────────────────────────
  NEW FILE 5 — lib/features/studio/application/background_select_provider.dart
────────────────────────────────────────

  part 'background_select_provider.g.dart';

  @riverpod
  class BackgroundSelect extends _$BackgroundSelect {
    @override
    BackgroundSelectState build() => const BackgroundSelectState();

    void selectStyle(int index) {
      state = state.copyWith(
        selectedStyleIndex: index,
        error: null,
      );
    }

    void updatePrompt(String prompt) {
      state = state.copyWith(customPrompt: prompt);
    }

    Future<void> generateAd({required String processedBase64}) async {
      final selectedIndex = state.selectedStyleIndex;
      if (selectedIndex == null) return;

      final userId =
          ref.read(supabaseClientProvider).auth.currentUser?.id ?? '';
      final style = BackgroundStyle.all[selectedIndex];

      state = state.copyWith(isGenerating: true, error: null);

      try {
        final service = ref.read(adGenerationServiceProvider);
        final result = await service.generateAd(
          AdCreationRequest(
            processedImageBase64: processedBase64,
            backgroundStyleId: style.id,
            customPrompt:
                state.customPrompt.isEmpty ? null : state.customPrompt,
            userId: userId,
          ),
        );
        state = state.copyWith(isGenerating: false, generatedAd: result);
      } on UnimplementedError {
        state = state.copyWith(
          isGenerating: false,
          error: AppStrings.errorAdGenerationComingSoon,
        );
      } on AppException catch (e) {
        state = state.copyWith(isGenerating: false, error: e.userMessage);
      } catch (e) {
        state = state.copyWith(
          isGenerating: false,
          error: AppStrings.errorGeneric,
        );
      }
    }
  }

────────────────────────────────────────
  NEW FILE 6 — lib/features/studio/presentation/widgets/background_style_card.dart
────────────────────────────────────────

  Stateless widget — grid cell.

  class BackgroundStyleCard extends StatelessWidget {
    const BackgroundStyleCard({
      super.key,
      required this.style,
      required this.isSelected,
      required this.onTap,
    });

    final BackgroundStyle style;
    final bool isSelected;
    final VoidCallback onTap;

    @override
    Widget build(BuildContext context) {
      return RepaintBoundary(    // required for low-end device performance
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: style.previewColor,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: isSelected
                ? Border.all(
                    color: AppColors.primary,
                    width: 3,
                  )
                : Border.all(
                    color: AppColors.divider,
                    width: 1,
                  ),
              boxShadow: isSelected ? AppShadows.card : null,
            ),
            child: Stack(
              children: [
                // Style name label at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(AppRadius.card - 1),
                        bottomRight: Radius.circular(AppRadius.card - 1),
                      ),
                    ),
                    child: Text(
                      style.displayName,
                      style: AppTypography.labelSmall
                          .copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // Selection checkmark
                if (isSelected)
                  Positioned(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }

────────────────────────────────────────
  NEW FILE 7 — lib/features/studio/presentation/screens/background_select_screen.dart
────────────────────────────────────────

  This screen receives the processedBase64 via GoRouterState.extra.
  It is a ConsumerStatefulWidget because it has a TextEditingController.

  class BackgroundSelectScreen extends ConsumerStatefulWidget {
    const BackgroundSelectScreen({super.key});
  }

  class _BackgroundSelectScreenState
      extends ConsumerState<BackgroundSelectScreen> {

    late final TextEditingController _promptController;
    late final String _processedBase64;

    @override
    void initState() {
      super.initState();
      _promptController = TextEditingController();
    }

    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      // Read route extra once — GoRouterState is available after didChangeDependencies
      _processedBase64 =
          GoRouterState.of(context).extra! as String;
    }

    @override
    void dispose() {
      _promptController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      final state = ref.watch(backgroundSelectProvider);

      // Listen for errors → show SnackBar
      ref.listen<BackgroundSelectState>(backgroundSelectProvider, (prev, next) {
        if (next.error != null && next.error != prev?.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: AppColors.error,
            ),
          );
        }

        // TODO Task 1.8: Navigate to AdPreviewScreen when generatedAd is set
        // if (next.generatedAd != null) {
        //   context.push(AppRoutes.adPreview, extra: next.generatedAd);
        // }
      });

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text(
            AppStrings.selectBackgroundTitle,
            style: AppTypography.headlineMedium,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            // Processed image preview (peek at what will be composited)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  child: Image.memory(
                    // processedBase64 is a base64 string — decode for Image.memory
                    // use compute to decode in isolate for large images
                    _decodeBase64Sync(_processedBase64),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Section header
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverToBoxAdapter(
                child: Text(
                  AppStrings.chooseBackgroundLabel,
                  style: AppTypography.headlineLarge,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.sm),
            ),

            // 2-column background grid (5 rows × 2 = 10 styles)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => BackgroundStyleCard(
                    style: BackgroundStyle.all[index],
                    isSelected: state.selectedStyleIndex == index,
                    onTap: () => ref
                        .read(backgroundSelectProvider.notifier)
                        .selectStyle(index),
                  ),
                  childCount: BackgroundStyle.all.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.2,
                ),
              ),
            ),

            // Custom prompt field
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.md),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.customPromptLabel,
                      style: AppTypography.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _promptController,
                      onChanged: ref
                          .read(backgroundSelectProvider.notifier)
                          .updatePrompt,
                      maxLines: 2,
                      maxLength: 100,
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: AppStrings.customPromptHint,
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textHint,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.button),
                          borderSide:
                              const BorderSide(color: AppColors.divider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.button),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom padding so FAB / sticky bar doesn't cover last item
            const SliverToBoxAdapter(
              child: SizedBox(height: 96),
            ),
          ],
        ),

        // Sticky "Generate Ad" button
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppButton(
              label: AppStrings.generateAdButton,
              isLoading: state.isGenerating,
              onPressed: state.selectedStyleIndex == null
                ? null   // disabled until a style is selected
                : () => ref
                    .read(backgroundSelectProvider.notifier)
                    .generateAd(processedBase64: _processedBase64),
            ),
          ),
        ),
      );
    }
  }

  // Helper — decode base64 synchronously for the preview image.
  // The image is already compressed (Task 1.4 pipeline) so size is small.
  // If this causes jank on first frame, replace with compute() in Task 1.8.
  Uint8List _decodeBase64Sync(String base64Str) {
    return base64Decode(base64Str);
  }

  // Required imports at top of file:
  //   dart:convert (base64Decode)
  //   dart:typed_data (Uint8List)
  //   package:go_router/go_router.dart
  //   + all app imports

────────────────────────────────────────
  CHANGE 4 — app_routes.dart    (MODIFIED)
────────────────────────────────────────

ADD this constant (keep alphabetical order):

  static const backgroundSelect = '/studio/background-select';

────────────────────────────────────────
  CHANGE 5 — app_router.dart    (MODIFIED)
────────────────────────────────────────

Inside the Studio branch routes list (where cameraCapture already lives),
ADD a new GoRoute AFTER the cameraCapture route:

  GoRoute(
    path: AppRoutes.backgroundSelect,
    builder: (context, state) => const BackgroundSelectScreen(),
  ),

NOTE: Must be a peer of cameraCapture — both are stack routes above the
nav bar. NavigationBar must NOT appear on BackgroundSelectScreen.

────────────────────────────────────────
  CHANGE 6 — app_strings.dart    (MODIFIED — add these only)
────────────────────────────────────────

  // Background selection screen
  static const selectBackgroundTitle       = 'Background chuno';
  static const chooseBackgroundLabel       = 'Background style';
  static const customPromptLabel           = 'Ya apna idea likho (optional)';
  static const customPromptHint            = 'Jaise: "Diwali discount ke saath saffron background"';
  static const generateAdButton            = 'Ad banao';
  static const errorAdGenerationComingSoon = 'Ad generation jaldi aa raha hai!';

────────────────────────────────────────
  NEW FILE 8 — tests
────────────────────────────────────────

test/features/studio/application/background_select_provider_test.dart:

  class MockAdGenerationService extends Mock implements AdGenerationService {}
  class MockSupabaseClient extends Mock implements SupabaseClient {}
  class MockGoTrueClient extends Mock implements GoTrueClient {}

  group('BackgroundSelect provider', () {

    Test 1: initial state has no selection, empty prompt, not generating
      expect state.selectedStyleIndex, isNull
      expect state.customPrompt, isEmpty
      expect state.isGenerating, isFalse

    Test 2: selectStyle() updates selectedStyleIndex
      notifier.selectStyle(3)
      expect state.selectedStyleIndex, 3

    Test 3: updatePrompt() updates customPrompt
      notifier.updatePrompt('Test prompt')
      expect state.customPrompt, 'Test prompt'

    Test 4: generateAd() is no-op when selectedStyleIndex is null
      await notifier.generateAd(processedBase64: 'base64')
      verify service.generateAd(any).called(0)

    Test 5: generateAd() sets isGenerating true then error when service throws UnimplementedError
      when service.generateAd(any).thenThrow(UnimplementedError())
      notifier.selectStyle(0)
      await notifier.generateAd(processedBase64: 'base64')
      expect state.isGenerating, isFalse
      expect state.error, AppStrings.errorAdGenerationComingSoon

    Test 6: generateAd() sets generatedAd on success
      when service.generateAd(any).thenAnswer((_) async => testGeneratedAd)
      notifier.selectStyle(2)
      await notifier.generateAd(processedBase64: 'base64')
      expect state.generatedAd, isNotNull
      expect state.generatedAd!.id, testGeneratedAd.id
      expect state.isGenerating, isFalse

    Test 7: selectStyle() clears existing error
      // set up error state first, then select a new style
      expect state.error, isNull after selectStyle()

    Test 8: customPrompt is passed as null when empty string
      notifier.selectStyle(0)
      notifier.updatePrompt('')
      await notifier.generateAd(processedBase64: 'base64')
      final captured = verify(service.generateAd(captureAny)).captured.first
        as AdCreationRequest
      expect captured.customPrompt, isNull
  })

────────────────────────────────────────
  OUTPUT ORDER (17 files total)
────────────────────────────────────────

MODIFIED (6 files):
  1. lib/features/studio/application/capture_state.dart
  2. lib/features/studio/application/capture_provider.dart
  3. lib/features/studio/presentation/screens/camera_capture_screen.dart
  4. lib/core/router/app_router.dart
  5. lib/core/constants/app_routes.dart
  6. lib/core/constants/app_strings.dart

NEW (10 files):
  7.  lib/features/studio/domain/background_style.dart
  8.  lib/features/studio/domain/ad_creation_request.dart
  9.  lib/features/studio/infrastructure/ad_generation_service.dart
  10. lib/features/studio/application/background_select_state.dart
  11. lib/features/studio/application/background_select_provider.dart
  12. lib/features/studio/presentation/widgets/background_style_card.dart
  13. lib/features/studio/presentation/screens/background_select_screen.dart

TESTS (1 file):
  14. test/features/studio/application/background_select_provider_test.dart

Generated part files (Copilot writes, build_runner regenerates):
  15. lib/features/studio/domain/ad_creation_request.freezed.dart
  16. lib/features/studio/application/background_select_state.freezed.dart
  17. lib/features/studio/application/background_select_provider.g.dart
      (also lib/features/studio/infrastructure/ad_generation_service.g.dart)

────────────────────────────────────────
  DO NOT
────────────────────────────────────────

✗ DO NOT use GridView.children — use GridView.builder / SliverGrid
✗ DO NOT forget RepaintBoundary around each BackgroundStyleCard
✗ DO NOT use Navigator.of(context).push — use context.push/pushReplacement
✗ DO NOT use GoRouterState.extra in initState — use didChangeDependencies
✗ DO NOT use pumpAndSettle in tests that involve GoRouter
✗ DO NOT add @JsonSerializable to AdCreationRequest — no json needed
✗ DO NOT make backgroundSelectProvider an AsyncNotifier — use Notifier
✗ DO NOT wire real ad generation — stub only, Task 1.7 replaces it
✗ DO NOT implement TODOs for Task 1.8 navigation yet — leave comment
✗ DO NOT add a new FAB or NavigationBar on BackgroundSelectScreen
✗ DO NOT decode base64 in build() — use _decodeBase64Sync helper or
   compute() for very large images (> 1MB decoded)

────────────────────────────────────────
  QUALITY GATES
────────────────────────────────────────

  □ CaptureProcessed state exists in capture_state.dart
  □ camera_capture_screen.dart uses context.pushReplacement for CaptureProcessed
  □ BackgroundSelectScreen reads processedBase64 from GoRouterState.extra
    in didChangeDependencies, not initState
  □ TextEditingController disposed in dispose()
  □ GridView uses SliverGrid with SliverChildBuilderDelegate
  □ BackgroundStyleCard is const-constructible StatelessWidget
  □ RepaintBoundary wraps each BackgroundStyleCard
  □ "Generate Ad" button disabled (onPressed: null) when no style selected
  □ isGenerating: true while generateAd() runs → AppButton shows spinner
  □ Error shown via SnackBar via ref.listen — not ref.watch
  □ AppRoutes.backgroundSelect is a child route of Studio (no nav bar)
  □ AdGenerationService throws UnimplementedError (stub — not empty return)
  □ 8 background_select_provider_test.dart tests pass
  □ flutter analyze: No issues found!
```

---

## STEP 3 — AFTER COPILOT RESPONDS

```bash
# 1. Regenerate (3 new freezed + 2 new Riverpod g.dart files)
dart run build_runner build --delete-conflicting-outputs

# 2. Zero issues
flutter analyze
# Expected: No issues found!

# 3. Full test suite
flutter test
# Expected: 44+ passed, 0 failed

# 4. Targeted subset
flutter test test/features/studio/
# Expected: 23+ passed, 0 failed

# 5. Visual verification — run the app
flutter run --dart-define=WORKER_BASE_URL=http://localhost:8787
# Verify:
#   a. FAB → camera opens
#   b. Photo taken → bottom sheet: "Dekho kaisa laga?"
#   c. "Background hatao" tapped → overlay: "AI magic ho raha hai..."
#      (will fail with error in stub mode — shows "Ad generation jaldi...")
#      Acceptable — Task 1.7 wires the real Worker
#   d. Tapping "Retake" → camera reopens correctly
#   e. Navigating back from BackgroundSelectScreen → Studio screen (not camera)
#   f. 10 background style cards render in 2-column grid
#   g. Tapping a style card → border appears, checkmark shows
#   h. "Ad banao" button disabled until a style is selected
#   i. "Ad banao" tapped → SnackBar shows "Ad generation jaldi aa raha hai!"
#   j. Custom prompt input updates state (verified via provider in devtools)
```

---

## WHAT COMES NEXT

> **Task 1.7 — Ad Generation Cloudflare Worker + Flutter Wiring**
> Dev agent writes `POST /api/generate-ad` Worker that composites the
> bg-removed product image onto the selected Replicate-generated background
> and calls GPT-4o-mini for Hindi + English captions. Rate limit: 5/hour.
> Kavya then wires `AdGenerationService` in Flutter (replaces stub), saves
> the result to Supabase `generated_ads` table, and invalidates
> `studioProvider` so the Studio screen's recent ads list updates immediately.
>
> **Task 1.8 — Ad Preview Screen**
> Builds `AdPreviewScreen` with the final composited ad image, share/download
> actions, and navigation to Studio. Wires the `generatedAd` navigation from
> `BackgroundSelectScreen`. Activates the first Supabase write in the flow.

---

*Dukaan AI v1.0 Build Playbook · Task 1.6 · Generated April 2026*
