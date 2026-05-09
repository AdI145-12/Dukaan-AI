# PROMPT 1.4 — Camera Capture Flow
### Dukaan AI · Copilot Chat Prompt · Expanded Edition

---

## STEP 0 — ADD DEPENDENCIES TO pubspec.yaml FIRST

Add these two packages before starting. They are already listed in
the playbook pubspec — if they're already present, skip this step.

```yaml
dependencies:
  image_picker: ^1.1.2
  flutter_image_compress: ^2.2.0
```

Then: `flutter pub get`

---

## STEP 0b — ADD AppRoutes.cameraCapture

Before Copilot writes the screen, add the route constant manually
to `lib/core/constants/app_routes.dart`:

```dart
static const cameraCapture = '/studio/capture';
```

This unblocks the TODO comments from Task 1.3 studio_screen.dart.

---

## STEP 1 — ATTACH THESE FILES

| # | File | Why |
|---|---|---|
| 1 | `copilot-instructions.md` | Global rules |
| 2 | `flutter.instructions.md` | compute(), Isolate rules, error handling |
| 3 | `SKILL.md` → *flutter-design-system* | AppBottomSheet, AppButton, loading states |
| 4 | `SKILL.md` → *riverpod-patterns* | Notifier (not AsyncNotifier), sealed state |
| 5 | `app_routes.dart` | Attach ACTUAL file — cameraCapture must already be added |
| 6 | `app_router.dart` | Attach ACTUAL file — new route must be wired here |
| 7 | `app_strings.dart` | Attach ACTUAL file — new strings go here |
| 8 | `app_bottom_sheet.dart` | Attach — used for the image preview bottom sheet |
| 9 | `studio_screen.dart` | Context — shows where this screen is navigated from |

### Agent: Kavya (ui-engineer.agent.md) — CONTINUE

---

## STEP 2 — PASTE THIS INTO COPILOT CHAT

```
════════════════════════════════════════════════════════
  PROJECT CONTEXT — ALWAYS INCLUDE IN EVERY SESSION
════════════════════════════════════════════════════════

PROJECT: Dukaan AI — Flutter app for Indian small business
owners. AI-powered ad generation + Khata + WhatsApp sharing.

TECH STACK: Flutter 3.x / Riverpod 2.x (code-gen) / GoRouter
/ Supabase / Cloudflare Workers (background removal in Task 1.5)

TARGET: 2GB RAM Android, Snapdragon 400-series, 60fps mandatory.

ARCHITECTURE RULES:
  • Heavy computation (base64, compression) → compute() in Isolate
  • Riverpod ONLY — Notifier (not AsyncNotifier) for UI state machines
  • All strings → AppStrings.*
  • All values → AppColors.* / AppSpacing.* / AppRadius.* / AppTypography.*
  • No print(), no dynamic type, no silent catch blocks
  • Use AppBottomSheet.show() for bottom sheets — never showModalBottomSheet
  • Use AppButton for all buttons — never raw ElevatedButton
  • context.push / context.go only — never Navigator.of(context).push

ALREADY BUILT:
  • AppShellScaffold, AppButton, ShimmerBox, AppBottomSheet
  • AppColors, AppSpacing, AppRoutes (cameraCapture now added),
    AppStrings, AppRouter, studioProvider, StudioScreen

════════════════════════════════════════════════════════
  TASK 1.4 — CAMERA CAPTURE FLOW
════════════════════════════════════════════════════════

CONTEXT:
This task implements the full image capture pipeline:
  Camera → Compress → Base64 → Preview bottom sheet
  → (stub) Background Removal → Navigate to BackgroundSelectScreen

BackgroundSelectScreen and the Cloudflare Worker come in Tasks 1.5–1.6.
For now, the "Remove Background" button calls a BackgroundRemovalService
stub that throws UnimplementedError — we wire the real call in Task 1.5.

Build order: state → service stubs → notifier → screen → route

────────────────────────────────────────
  R — ROLE
────────────────────────────────────────

You are Kavya, the Dukaan AI Flutter UI engineer.
Implement the camera capture pipeline following the exact
spec below. All heavy computation runs in Isolates via compute().
The UI must never freeze for more than 16ms on a Redmi 9A.

────────────────────────────────────────
  A — ARCHITECTURE
────────────────────────────────────────

═══════════════════════════════
  LAYER 1 — CAPTURE STATE (Notifier, not AsyncNotifier)
═══════════════════════════════

Path: lib/features/studio/application/capture_state.dart

Use a SEALED class (not freezed) — this is a UI state machine.

  sealed class CaptureState {}

  class CaptureInitial extends CaptureState {
    const CaptureInitial();
  }

  class CaptureImageReady extends CaptureState {
    const CaptureImageReady({
      required this.imageBytes,
      required this.base64Image,
    });
    final Uint8List imageBytes;
    final String base64Image;
  }

  class CaptureProcessing extends CaptureState {
    const CaptureProcessing({required this.imageBytes});
    final Uint8List imageBytes;    // keeps preview visible during load
  }

  class CaptureError extends CaptureState {
    const CaptureError({required this.message});
    final String message;
  }

═══════════════════════════════
  LAYER 2 — SERVICE STUBS
═══════════════════════════════

── 2a. ImagePipeline ──
Path: lib/shared/services/image_pipeline.dart

Static utility. All heavy work via compute().

  class ImagePipeline {
    ImagePipeline._();

    /// Compresses [imageFile] to max 800px width, quality 85.
    /// Runs in Isolate via compute — never blocks UI thread.
    static Future<Uint8List> compress(XFile imageFile) async {
      final bytes = await imageFile.readAsBytes();
      return compute(_compressInIsolate, _CompressParams(
        bytes: bytes,
        maxWidth: 800,
        quality: 85,
      ));
    }

    /// Converts bytes to base64 string in an Isolate.
    static Future<String> toBase64(Uint8List bytes) async {
      return compute(_base64InIsolate, bytes);
    }
  }

  // Isolate-safe top-level functions (not inside class):
  class _CompressParams {
    const _CompressParams({
      required this.bytes,
      required this.maxWidth,
      required this.quality,
    });
    final Uint8List bytes;
    final int maxWidth;
    final int quality;
  }

  Future<Uint8List> _compressInIsolate(_CompressParams params) async {
    final result = await FlutterImageCompress.compressWithList(
      params.bytes,
      minWidth: params.maxWidth,
      minHeight: 1,
      quality: params.quality,
      format: CompressFormat.jpeg,
    );
    return result;
  }

  String _base64InIsolate(Uint8List bytes) {
    return base64Encode(bytes);
  }

  // Imports needed:
  //   package:flutter_image_compress/flutter_image_compress.dart
  //   package:image_picker/image_picker.dart
  //   dart:convert  (base64Encode)
  //   dart:typed_data (Uint8List)
  //   package:flutter/foundation.dart (compute)

── 2b. BackgroundRemovalService STUB ──
Path: lib/features/studio/infrastructure/background_removal_service.dart

Stub only. Real implementation comes in Task 1.5 (Cloudflare Worker).

  class BackgroundRemovalService {
    const BackgroundRemovalService();

    /// Sends [base64Image] to the background removal API.
    /// Returns the processed image as a base64 string.
    ///
    /// TODO Task 1.5: Replace with real Cloudflare Worker call.
    Future<String> removeBackground({
      required String base64Image,
      required String userId,
    }) async {
      // Stub — Task 1.5 wires the real Worker endpoint.
      throw UnimplementedError(
        'Background removal not yet connected. '
        'Implement in Task 1.5 via POST /api/remove-bg',
      );
    }
  }

  @riverpod
  BackgroundRemovalService backgroundRemovalService(
    BackgroundRemovalServiceRef ref,
  ) {
    return const BackgroundRemovalService();
  }

  // Place the provider in the same file.
  // Part directive: part 'background_removal_service.g.dart';

═══════════════════════════════
  LAYER 3 — CAPTURE NOTIFIER
═══════════════════════════════

Path: lib/features/studio/application/capture_provider.dart

  part 'capture_provider.g.dart';

  @riverpod
  class Capture extends _$Capture {
    @override
    CaptureState build() => const CaptureInitial();

    /// Main method: opens camera, compresses, shows preview.
    /// Return type: Future<void>
    Future<void> captureAndProcess() async {
      state = const CaptureInitial();

      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,        // initial cap before our compress step
        imageQuality: 100,     // we compress ourselves for control
      );

      if (picked == null) {
        // User cancelled — stay on CaptureInitial (screen pops)
        return;
      }

      try {
        // Both steps run in Isolates — no UI jank
        final compressed = await ImagePipeline.compress(picked);
        final base64 = await ImagePipeline.toBase64(compressed);

        state = CaptureImageReady(
          imageBytes: compressed,
          base64Image: base64,
        );
      } catch (e) {
        state = CaptureError(
          message: AppStrings.errorCaptureGeneric,
        );
      }
    }

    /// Called when user taps "Retake" in the bottom sheet.
    Future<void> retake() async {
      state = const CaptureInitial();
      await captureAndProcess();
    }

    /// Called when user taps "Remove Background".
    /// Uses the stub service. Real call wired in Task 1.5.
    Future<void> processImage({required String userId}) async {
      final current = state;
      if (current is! CaptureImageReady) return;

      state = CaptureProcessing(imageBytes: current.imageBytes);

      try {
        final service = ref.read(backgroundRemovalServiceProvider);
        final processedBase64 = await service.removeBackground(
          base64Image: current.base64Image,
          userId: userId,
        );
        // TODO Task 1.6: Navigate to BackgroundSelectScreen with processedBase64
        // For now, show a SnackBar — actual nav in Task 1.6
        state = CaptureImageReady(
          imageBytes: current.imageBytes,
          base64Image: processedBase64,
        );
      } on UnimplementedError {
        // Expected until Task 1.5 — show friendly message
        state = CaptureError(
          message: AppStrings.errorBgRemovalComingSoon,
        );
      } catch (e) {
        state = CaptureError(
          message: AppStrings.errorCaptureGeneric,
        );
      }
    }

    void resetError() {
      state = const CaptureInitial();
    }
  }

═══════════════════════════════
  LAYER 4 — CAMERA CAPTURE SCREEN
═══════════════════════════════

Path: lib/features/studio/presentation/screens/camera_capture_screen.dart

This screen is a ConsumerStatefulWidget because it:
  (a) auto-triggers captureAndProcess() on first frame
  (b) shows a bottom sheet reactively

  class CameraCaptureScreen extends ConsumerStatefulWidget {
    const CameraCaptureScreen({super.key});
  }

  class _CameraCaptureScreenState
      extends ConsumerState<CameraCaptureScreen> {

    bool _captureStarted = false;

    @override
    void initState() {
      super.initState();
      // Defer one frame so widget tree is built before opening camera
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_captureStarted && mounted) {
          _captureStarted = true;
          ref.read(captureProvider.notifier).captureAndProcess();
        }
      });
    }

    @override
    Widget build(BuildContext context) {
      ref.listen<CaptureState>(captureProvider, (prev, next) {
        _handleStateChange(context, prev, next);
      });

      final captureState = ref.watch(captureProvider);

      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
          title: Text(
            AppStrings.cameraCaptureTitle,
            style: AppTypography.headlineMedium
              .copyWith(color: Colors.white),
          ),
        ),
        body: _buildBody(context, captureState),
      );
    }

    void _handleStateChange(
      BuildContext context, CaptureState? prev, CaptureState next) {
      if (next is CaptureInitial && prev is! CaptureInitial) {
        // Coming back to initial — pop if nothing was captured
        if (mounted) context.pop();
      }

      if (next is CaptureError) {
        // Show error SnackBar and pop after delay
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) context.pop();
        });
        ref.read(captureProvider.notifier).resetError();
      }

      if (next is CaptureImageReady && prev is! CaptureImageReady) {
        // Image ready — show the preview bottom sheet
        _showPreviewSheet(context, next);
      }
    }

    void _showPreviewSheet(BuildContext context, CaptureImageReady state) {
      AppBottomSheet.show(
        context: context,
        title: AppStrings.capturePreviewTitle,
        isDismissible: false,   // force explicit Retake or Remove Background
        child: _PreviewSheetContent(imageBytes: state.imageBytes),
      );
    }

    Widget _buildBody(BuildContext context, CaptureState state) {
      return switch (state) {
        CaptureInitial() => const _OpeningCameraBody(),
        CaptureImageReady(:final imageBytes) => _ImagePreviewBody(
            imageBytes: imageBytes,
          ),
        CaptureProcessing(:final imageBytes) => _ProcessingBody(
            imageBytes: imageBytes,
          ),
        CaptureError() => const _OpeningCameraBody(),
      };
    }
  }

Private body widgets (all StatelessWidget, all const, all in same file):

_OpeningCameraBody:
  Center:
    Column(center):
      CircularProgressIndicator(color: Colors.white)
      SizedBox(AppSpacing.md)
      Text(AppStrings.cameraOpening,
        style: AppTypography.bodyMedium.copyWith(color: Colors.white70))

_ImagePreviewBody (shows raw preview behind bottom sheet):
  Image.memory(imageBytes, fit: BoxFit.contain, width: double.infinity)

_ProcessingBody (loading overlay on preview):
  Stack:
    Image.memory(imageBytes, fit: BoxFit.contain, width: double.infinity)
    Container(color: Colors.black54):       // dim overlay
      Center:
        Column(center):
          CircularProgressIndicator(color: AppColors.primary)
          SizedBox(AppSpacing.md)
          Text(AppStrings.aiProcessing,
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
            textAlign: center)

_PreviewSheetContent (inside bottom sheet):
  This is a ConsumerWidget (needs ref for button callbacks).

  Column(mainAxisSize: min):
    // Image preview
    ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Image.memory(imageBytes,
        height: 240,
        width: double.infinity,
        fit: BoxFit.cover),
    )
    SizedBox(AppSpacing.md)

    // Primary button — Remove Background
    AppButton(
      label: AppStrings.removeBackground,
      onPressed: () {
        final userId = ref.read(supabaseClientProvider)
          .auth.currentUser?.id ?? '';
        Navigator.of(context).pop();     // dismiss bottom sheet first
        ref.read(captureProvider.notifier).processImage(userId: userId);
      },
    )
    SizedBox(AppSpacing.sm)

    // Secondary button — Retake
    AppButton(
      label: AppStrings.retake,
      variant: AppButtonVariant.secondary,
      onPressed: () {
        Navigator.of(context).pop();    // dismiss bottom sheet
        ref.read(captureProvider.notifier).retake();
      },
    )

═══════════════════════════════
  LAYER 5 — ROUTER UPDATE
═══════════════════════════════

MODIFY lib/core/router/app_router.dart — ADD one GoRoute inside the
Studio branch (NOT a shell route — this is a stack push above the nav bar):

In the Studio branch routes list, add:
  GoRoute(
    path: AppRoutes.cameraCapture,    // '/studio/capture'
    builder: (context, state) =>
      const CameraCaptureScreen(),
  ),

NOTE: The path must be a child of the studio branch so the bottom
NavigationBar is NOT shown while the camera is open (correct UX).

═══════════════════════════════
  LAYER 6 — APP STRINGS UPDATE
═══════════════════════════════

MODIFY lib/core/constants/app_strings.dart — ADD these only:

  // Camera capture
  static const cameraCaptureTitle     = 'Apna product photo lo';
  static const cameraOpening          = 'Camera khul raha hai...';
  static const capturePreviewTitle    = 'Dekho kaisa laga?';
  static const aiProcessing           = 'AI magic ho raha hai...';
  static const removeBackground       = 'Background hatao';
  static const retake                 = 'Dobara lo';
  static const errorCaptureGeneric    = 'Kuch gadbad ho gayi, dobara try karein';
  static const errorBgRemovalComingSoon = 'Yeh feature jaldi aa raha hai!';

────────────────────────────────────────
  F — FORMAT: Output these files in order
────────────────────────────────────────

 1. lib/shared/services/image_pipeline.dart                   (NEW)
 2. lib/features/studio/application/capture_state.dart        (NEW)
 3. lib/features/studio/infrastructure/background_removal_service.dart (NEW)
 4. lib/features/studio/application/capture_provider.dart     (NEW)
 5. lib/features/studio/presentation/screens/camera_capture_screen.dart (NEW)
 6. lib/core/constants/app_strings.dart         (MODIFIED — add strings only)
 7. lib/core/router/app_router.dart             (MODIFIED — add one GoRoute)

Then tests:
 8. test/features/studio/application/capture_provider_test.dart (NEW)
 9. test/shared/services/image_pipeline_test.dart               (NEW)

────────────────────────────────────────
  T — TESTS
────────────────────────────────────────

test/features/studio/application/capture_provider_test.dart:
Use mocktail to mock ImagePicker and BackgroundRemovalService.

  Test 1: initial state is CaptureInitial
  Test 2: captureAndProcess() → state becomes CaptureImageReady
           when picker returns an XFile
  Test 3: captureAndProcess() → state stays CaptureInitial
           when picker returns null (user cancelled)
  Test 4: processImage() → state becomes CaptureProcessing,
           then CaptureError when service throws UnimplementedError
  Test 5: retake() → resets to CaptureInitial then re-calls captureAndProcess

test/shared/services/image_pipeline_test.dart:
  Test 1: compress() returns Uint8List with smaller size than input
  Test 2: toBase64() returns a valid base64-encoded string
  Test 3: base64-decoded output of toBase64() matches compress() output

────────────────────────────────────────
  DO NOT
────────────────────────────────────────

✗ DO NOT open camera in initState directly — use addPostFrameCallback
✗ DO NOT run FlutterImageCompress on the UI thread — MUST use compute()
✗ DO NOT use base64Encode directly in build() — MUST use compute()
✗ DO NOT use showModalBottomSheet directly — use AppBottomSheet.show()
✗ DO NOT use Navigator.of(context).push — use context.push or context.pop
✗ DO NOT use Navigator.of(context).pop inside the sheet to go back
   to previous screen — pop() dismisses the sheet, context.pop() exits
   the camera screen. Use Navigator.of(context).pop() for the sheet ONLY.
✗ DO NOT implement real background removal — stub only in Task 1.4
✗ DO NOT add @freezed to CaptureState — sealed class is correct here
✗ DO NOT forget to dismiss the bottom sheet before calling processImage/retake
✗ DO NOT hardcode any string — use AppStrings.*
✗ DO NOT forget to add cameraCapture GoRoute inside the Studio branch,
   NOT as a top-level route (navigation bar must disappear during capture)

────────────────────────────────────────
  QUALITY GATES
────────────────────────────────────────

  □ CaptureState is a sealed class (not freezed, not enum)
  □ ImagePipeline.compress uses compute() — not async without compute
  □ ImagePipeline.toBase64 uses compute() — base64Encode is CPU-heavy
  □ Isolate functions (_compressInIsolate, _base64InIsolate) are
    top-level functions, NOT class methods or closures
  □ BackgroundRemovalService stub throws UnimplementedError
  □ captureProvider is a Notifier (CaptureState), not AsyncNotifier
  □ _captureStarted flag prevents double-open on hot reload
  □ ref.listen is used for side effects (SnackBar, sheet), not ref.watch
  □ AppBottomSheet.show() used, not showModalBottomSheet
  □ GoRoute for cameraCapture is inside the Studio GoRoute, not top-level
  □ isDismissible: false on the preview sheet (user must tap a button)
```

---

## STEP 3 — AFTER COPILOT RESPONDS

```bash
# 1. Generate new provider
dart run build_runner build --delete-conflicting-outputs

# New generated files expected:
#   lib/features/studio/infrastructure/background_removal_service.g.dart
#   lib/features/studio/application/capture_provider.g.dart

# 2. Static analysis
flutter analyze
# Expected: No issues found!

# 3. Tests
flutter test test/features/studio/
flutter test test/shared/services/

# 4. Visual test
flutter run
# Verify:
#   a. Tapping FAB opens CameraCaptureScreen (camera opens automatically)
#   b. Quick Create cards also navigate to CameraCaptureScreen
#   c. After capture, bottom sheet shows with image preview
#   d. Tapping "Remove Background" shows AI processing overlay
#      then shows "Yeh feature jaldi aa raha hai!" SnackBar (stub)
#   e. Tapping "Retake" re-opens camera
#   f. Tapping X / device back returns to Studio screen
#   g. NavigationBar is NOT visible during camera capture
```

---

## STEP 4 — CHECKLIST

**State**
- [ ] `CaptureState` is a sealed class — 4 subclasses
- [ ] `CaptureProcessing` holds `imageBytes` (keeps preview visible)
- [ ] `CaptureError` holds `message` string

**Image Pipeline**
- [ ] `compress()` uses `compute(_compressInIsolate, params)`
- [ ] `toBase64()` uses `compute(_base64InIsolate, bytes)`
- [ ] `_compressInIsolate` is a top-level function (Isolate requirement)
- [ ] `_base64InIsolate` is a top-level function

**Capture Notifier**
- [ ] `Capture extends _$Capture` (generated base class)
- [ ] `build()` returns `const CaptureInitial()` synchronously
- [ ] `captureAndProcess()` uses `ImagePipeline.compress` + `ImagePipeline.toBase64`
- [ ] `processImage()` sets `CaptureProcessing` before calling service
- [ ] `UnimplementedError` from stub caught separately from general errors

**Screen**
- [ ] `addPostFrameCallback` used, not `initState` directly
- [ ] `ref.listen` used for SnackBar and bottom sheet — NOT `ref.watch`
- [ ] `_captureStarted` flag prevents double camera open
- [ ] `isDismissible: false` on preview sheet
- [ ] Bottom sheet dismissed before calling `processImage`/`retake`

**Router**
- [ ] `GoRoute` for `/studio/capture` is INSIDE the Studio branch routes
- [ ] `NavigationBar` is absent when on `CameraCaptureScreen`

**Tests**
- [ ] 5 capture provider tests pass
- [ ] 3 image pipeline tests pass
- [ ] `flutter analyze` zero issues

---

## WHAT COMES NEXT

> **Task 1.5 — Background Removal Cloudflare Worker**
> Writes the actual Worker at `POST /api/remove-bg` that forwards
> the image to the AI Engine API, rate-limits per user via KV, and
> adds CORS headers for Flutter. Activates the Dev agent for the
> first time. After Task 1.5, `BackgroundRemovalService` gets wired
> to the real endpoint and the stub is replaced.
>
> **Task 1.6 — Background Selection Screen**
> Builds `BackgroundSelectScreen` with the 2x5 background grid,
> custom prompt field, and "Generate Ad" sticky button. Wires the
> navigation from `processImage()` in the capture provider.
>
> No new Flutter packages needed for Task 1.5 (Worker only).
> Task 1.6 needs no new packages either.

---

*Dukaan AI v1.0 Build Playbook · Task 1.4 · Generated April 2026*
