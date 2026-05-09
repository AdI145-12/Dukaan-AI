# TASK 4.1 — Performance: Lazy Loading + Image Pipeline
### Dukaan AI · Week 4 Polish · Flutter

---

## OUTSTANDING FIX — mutex Version Constraint (1 Line, pubspec.yaml)

```
Error: Because dukaan_ai depends on mutex ^5.1.1 which doesn't match any versions
```

The `mutex` package on pub.dev only goes up to v3.x. Version 5.x does not exist.

**Fix — open pubspec.yaml, change ONE line:**
```yaml
# BEFORE (wrong — does not exist on pub.dev):
mutex: ^5.1.1

# AFTER (correct — latest stable):
mutex: ^3.1.0
```

Then run:
```powershell
flutter pub get
# Expected: Resolving dependencies... Got dependencies!

flutter test
# Expected: all tests pass (CreditGuard, My Ads, Pricing, all prior tests)
```

That's the only change needed. No code files change.

---

## TASK 4.1 — Performance: Lazy Loading + Image Pipeline

### One-Sentence Summary
Optimize `MyAdsScreen`'s grid for smooth 60fps scroll on 2GB RAM devices
by adding `RepaintBoundary`, `AutomaticKeepAliveClientMixin`, per-item
lazy loading, and a centralized `ImagePipeline` isolate class that
compresses, resizes, and base64-encodes all images before upload.

---

### Paste Into Copilot Chat (Kavya Agent — New Session)

**Attach these files:**

| # | File | Why |
|---|---|---|
| 1 | `copilot-instructions.md` | Global rules |
| 2 | `flutter.instructions.md` | Screen patterns + performance rules |
| 3 | `SKILL.md` → *design-system* | Colors, spacing |
| 4 | `SKILL.md` → *testing-patterns* | Unit test structure |
| 5 | `lib/features/myads/presentation/screens/my_ads_screen.dart` | ACTUAL — optimize this |
| 6 | `lib/features/studio/presentation/screens/camera_capture_screen.dart` | ACTUAL — wire ImagePipeline |

```
════════════════════════════════════════════════════════
  TASK 4.1 — Performance: Lazy Loading + Image Pipeline
  Week 4 · Polish · Flutter
════════════════════════════════════════════════════════

This task has two independent parts. Output them in order.

═══════════════════════════════════════════════════════
  PART A — GeneratedAdsList Performance Optimization
  (Prompt 4.1 from playbook)
═══════════════════════════════════════════════════════

Target: Smooth 60fps scroll on Redmi 9A (Helio G25, 2GB RAM, Android 10).

Current issue in my_ads_screen.dart:
  - GridView.builder inside SingleChildScrollView (NeverScrollableScrollPhysics)
    means ALL cards render at once — causes jank on first open.
  - No RepaintBoundary on cards — a single image decode repaints the entire list.
  - No keepAlive — cards rebuild every time they scroll back into view.

────────────────────────────────────────
  CHANGE — my_ads_screen.dart    (MODIFIED — replace _AdGrid + _AdCard)
────────────────────────────────────────

Replace the current _AdGrid widget with a PROPER lazy-loading implementation:

CHANGE 1: Replace GridView.builder + SingleChildScrollView pattern with
CustomScrollView + SliverGrid so items render lazily:

  CustomScrollView(
    physics: const AlwaysScrollableScrollPhysics(),  // enables pull-to-refresh
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.all(12),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == ads.length) {
                // Load more button as last item
                return _LoadMoreButton(onTap: onLoadMore);
              }
              return _AdCard(key: ValueKey(ads[index].id), ad: ads[index]);
            },
            childCount: ads.length + (hasMore ? 1 : 0),
          ),
        ),
      ),
    ],
  )

  Wrap the entire CustomScrollView in RefreshIndicator.

CHANGE 2: Convert _AdCard to a StatefulWidget that mixes in
AutomaticKeepAliveClientMixin:

  class _AdCard extends StatefulWidget {
    const _AdCard({ required super.key, required this.ad });
    final GeneratedAd ad;
    @override State<_AdCard> createState() => _AdCardState();
  }

  class _AdCardState extends State<_AdCard>
      with AutomaticKeepAliveClientMixin {

    @override
    bool get wantKeepAlive => true;   // preserve card state when scrolled off

    @override
    Widget build(BuildContext context) {
      super.build(context);           // required by the mixin

      return RepaintBoundary(         // isolate repaint to this card only
        child: _cardContent(),
      );
    }

    Widget _cardContent() {
      // ... identical card layout as before, no logic changes
      // Only structural change: wrap with RepaintBoundary (done above)
    }
  }

CHANGE 3: Update CachedNetworkImage in _AdCard:
  Add: memCacheWidth: 240             // downscale in memory on decode
  Add: fadeInDuration: Duration(milliseconds: 150)
  Keep: placeholder shimmer, errorWidget, fit: BoxFit.cover

CHANGE 4: Add ValueKey to every _AdCard:
  _AdCard(key: ValueKey(ads[index].id), ad: ads[index])
  This tells Flutter which cards changed vs. scrolled, preventing full rebuilds.

CHANGE 5: Extract _LoadMoreButton as a private widget:
  class _LoadMoreButton extends StatelessWidget {
    const _LoadMoreButton({ required this.onTap });
    final VoidCallback onTap;

    @override
    Widget build(BuildContext context) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF6F00)),
            ),
            child: const Text(
              'Aur ads load karo',
              style: TextStyle(color: Color(0xFFFF6F00)),
            ),
          ),
        ),
      );
    }
  }

DO NOT change:
  - Firestore pagination logic in my_ads_notifier.dart
  - Delete, share, download handlers
  - EmptyState, ErrorState, ShimmerGrid widgets
  - Any provider or notifier code

Output: only my_ads_screen.dart with the 5 changes above applied.

═══════════════════════════════════════════════════════
  PART B — ImagePipeline Isolate Class
  (Prompt 4.2 from playbook)
═══════════════════════════════════════════════════════

────────────────────────────────────────
  NEW FILE — lib/core/services/image_pipeline.dart    (NEW)
────────────────────────────────────────

class ImagePipeline

  /// Full pipeline: read → resize → compress → return bytes.
  /// Runs in a Flutter Isolate via compute() — never blocks UI thread.
  static Future<Uint8List> prepareForUpload(XFile imageFile) async {
    final inputBytes = await imageFile.readAsBytes();
    return compute(_runPipeline, inputBytes);
  }

  /// Isolate entry point — must be a top-level function.
  static Future<Uint8List> _runPipeline(Uint8List inputBytes) async {
    // Step 1: Decode image
    final image = img.decodeImage(inputBytes);
    if (image == null) throw Exception('Image decode nahi hua.');

    // Step 2: Resize if wider than 1080px (maintain aspect ratio)
    img.Image resized = image;
    if (image.width > 1080) {
      resized = img.copyResize(image, width: 1080);
    }

    // Step 3: First compress attempt at quality 82
    Uint8List compressed = Uint8List.fromList(
      img.encodeJpg(resized, quality: 82),
    );

    // Step 4: If still > 500KB, recompress at quality 70
    if (compressed.length > 500 * 1024) {
      compressed = Uint8List.fromList(
        img.encodeJpg(resized, quality: 70),
      );
    }

    // Log compression stats (only in debug — use assert)
    assert(() {
      final originalKb = (inputBytes.length / 1024).toStringAsFixed(1);
      final finalKb = (compressed.length / 1024).toStringAsFixed(1);
      final ratio = ((1 - compressed.length / inputBytes.length) * 100)
          .toStringAsFixed(0);
      debugPrint('[ImagePipeline] ${originalKb}KB → ${finalKb}KB (−$ratio%)');
      return true;
    }());

    return compressed;
  }

  /// Convert Uint8List to base64 string, also runs in Isolate.
  static Future<String> toBase64(Uint8List bytes) async {
    return compute(_encodeBase64, bytes);
  }

  static String _encodeBase64(Uint8List bytes) => base64Encode(bytes);

IMPORTS needed (all already in pubspec.yaml):
  import 'dart:convert';
  import 'dart:typed_data';
  import 'package:flutter/foundation.dart';   // compute, debugPrint
  import 'package:image/image.dart' as img;
  import 'package:image_picker/image_picker.dart';

NO Riverpod provider needed — ImagePipeline is a pure static utility class.

────────────────────────────────────────
  CHANGE — camera_capture_screen.dart    (MODIFIED — wire ImagePipeline)
────────────────────────────────────────

Attach: lib/features/studio/presentation/screens/camera_capture_screen.dart

Find the method that currently does manual compression
(using flutter_image_compress package directly on the UI thread, or
any direct compression call in captureAndProcessImage).

Replace the manual compression logic with ImagePipeline:

  // REMOVE any existing direct flutter_image_compress call
  // REMOVE any direct base64 encoding on the UI thread

  // REPLACE WITH:
  final compressedBytes = await ImagePipeline.prepareForUpload(pickedImage);
  final base64Image = await ImagePipeline.toBase64(compressedBytes);

  // Then pass base64Image to the background removal API call as before

IMPORTANT:
  - The rest of the method (camera picker, preview bottom sheet,
    API call, navigation) stays IDENTICAL.
  - Only the compression + base64 step changes.
  - If flutter_image_compress is no longer used anywhere after this
    change, you may leave the import — do not remove it proactively.

Output: only camera_capture_screen.dart with the ImagePipeline wiring.

────────────────────────────────────────
  NEW FILE — Tests
  test/core/services/image_pipeline_test.dart    (NEW)
────────────────────────────────────────

Write 4 unit tests:

TEST 1: prepareForUpload returns bytes smaller than 500KB
  - Create a fake XFile with a 1MB JPEG bytes buffer (use a solid-color
    image generated with the image package in the test setup)
  - Call ImagePipeline.prepareForUpload(fakeFile)
  - Expect result.length <= 512 * 1024 (≤ 500KB)

TEST 2: prepareForUpload resizes images wider than 1080px
  - Create a fake XFile with a 2000×1500 pixel image
  - Call prepareForUpload
  - Decode the result and verify width <= 1080

TEST 3: toBase64 returns valid base64 string
  - Call ImagePipeline.toBase64(Uint8List.fromList([1, 2, 3]))
  - Expect result == base64Encode([1, 2, 3])

TEST 4: prepareForUpload throws on invalid image bytes
  - Call ImagePipeline.prepareForUpload(XFile for a non-image .txt file)
  - Expect a thrown Exception

────────────────────────────────────────
  STRINGS (no new strings needed for this task)
────────────────────────────────────────

Only the debug log inside ImagePipeline is new text, and it uses
debugPrint (not a user-facing string). No app_strings.dart changes.

────────────────────────────────────────
  OUTPUT ORDER (3 files)
────────────────────────────────────────

MODIFIED (2 files):
  1. lib/features/myads/presentation/screens/my_ads_screen.dart
  2. lib/features/studio/presentation/screens/camera_capture_screen.dart

NEW (2 files):
  3. lib/core/services/image_pipeline.dart
  4. test/core/services/image_pipeline_test.dart

────────────────────────────────────────
  DO NOT
────────────────────────────────────────

✗ DO NOT remove flutter_image_compress from pubspec.yaml — it may still
  be referenced in other files
✗ DO NOT run image processing in the build() method — only in event handlers
✗ DO NOT use ListView.builder inside SingleChildScrollView (the old pattern)
✗ DO NOT use SliverList instead of SliverGrid — the UI requires 2 columns
✗ DO NOT add compute() calls in widget build() — only in service methods
✗ DO NOT change the GeneratedAd model or Firestore queries
✗ DO NOT add any new packages to pubspec.yaml — image package is already present
```

---

## VALIDATION CHECKLIST

```powershell
# Step 1: Fix mutex version (the ONLY change before running anything)
# In pubspec.yaml: mutex: ^3.1.0

flutter pub get
# Expected: Got dependencies! (no version errors)

flutter analyze
# Expected: No issues found!

# Step 2: Run all tests
flutter test test/core/services/image_pipeline_test.dart
# Expected: 4/4 pass

flutter test test/features/myads/presentation/screens/my_ads_screen_test.dart
# Expected: 5/5 pass

flutter test
# Expected: ALL pass across the entire project

# Step 3: Emulator performance check
flutter run -d emulator-5554 --dart-define=SKIP_AUTH=true --profile
# In DevTools: open Performance tab
# Navigate to My Ads tab
# Scroll the grid
# Expected: Frames stay green (< 16ms). No red jank frames.
# Verify no "I/Choreographer: Skipped X frames" warnings in logcat
```

---

## WHAT COMES NEXT — TASK 4.2 (Final Pre-Launch Tasks)

> **Task 4.2 — Onboarding Flow + Phone OTP + Play Store Config**
> Combines playbook Prompts 4.3 and 4.4 — the two remaining tasks before
> Play Store submission.
>
> **Onboarding (Prompt 4.3):** 3-screen flow: Welcome (Lottie animation),
> Business Setup (shop name, category dropdown, city), Phone OTP login
> using Firebase Auth phone sign-in (replaces Supabase OTP from playbook).
> GoRouter redirect guard: unauthenticated → `/onboarding`, authenticated
> without Firestore profile → `/onboarding/setup`, fully set-up → `/studio`.
> On completion: writes `users/{uid}` Firestore doc with shopName, category,
> city, tier: 'free', creditsRemaining: 5.
>
> **Play Store Config (Prompt 4.4):** Update `android/app/build.gradle.kts`
> with release signing from `key.properties`, enable R8 minification +
> ProGuard rules for Razorpay + Firebase, configure
> `flutter_launcher_icons` with saffron (#FF6F00) adaptive icon,
> configure `flutter_native_splash` with white logo on saffron background,
> and output the 4 terminal build commands for release APK + App Bundle.

---

*Dukaan AI v1.0 Build Playbook · Task 4.1 (Performance) · April 2026*
