# PROMPT 1.8 — Ad Result Screen (Full)
### Dukaan AI · Kavya Agent · Pure Flutter Session

---

## TASK 1.7 ASSESSMENT — Two Items to Fix First

### Fix A — UUID Workaround in `ad_generation_service.dart` (Paste-Ask)

The `uuid: ^4.4.0` package was **always in `pubspec.yaml`** — Copilot
incorrectly claimed it was unavailable and used a timestamp workaround.

**Attach `lib/features/studio/infrastructure/ad_generation_service.dart`, then paste:**

```
The storage path in ad_generation_service.dart uses a timestamp+random suffix
workaround for uniqueness. This is incorrect — uuid: ^4.4.0 is already in
pubspec.yaml.

FIX — Replace the path generation line:

REMOVE whatever timestamp/random workaround is currently there.

REPLACE WITH:
  final storagePath = '${request.userId}/${const Uuid().v4()}.jpg';

Add import at top: import 'package:uuid/uuid.dart';
No other changes.

Output only the corrected ad_generation_service.dart.
```

### Fix B — CWD When Running Flutter Tests

The `flutter test test/features/studio/` command must be run from
the **Flutter project root** (`C:\dev\smb_ai`), NOT from `C:\dev\smb_ai\workers`.

```powershell
# Wrong — runs from workers/ directory
PS C:\dev\smb_ai\workers> flutter test test/features/studio/

# Correct
cd C:\dev\smb_ai
flutter test test/features/studio/
# Expected: 30+ passed, 0 failed
```

---

## TASK 1.8 — THE ACTUAL PROMPT

### STEP 1 — ATTACH THESE FILES

| # | File | Why |
|---|---|---|
| 1 | `copilot-instructions.md` | Global rules |
| 2 | `flutter.instructions.md` | ConsumerStatefulWidget rule, navigation |
| 3 | `SKILL.md` → *flutter-design-system* | AppColors, spacing, AppButton, RepaintBoundary |
| 4 | `SKILL.md` → *supabase-schema* | usageevents table, generatedads columns |
| 5 | `SKILL.md` → *testing-patterns* | Widget test pattern, AAA |
| 6 | `ad_preview_screen.dart` | ACTUAL stub — being replaced |
| 7 | `background_select_screen.dart` | ACTUAL — update extra payload |
| 8 | `studio_repository.dart` | ACTUAL — add 3 new methods |
| 9 | `studio_repository_impl.dart` | ACTUAL — implement 3 new methods |
| 10 | `generated_ad.dart` | ACTUAL — domain model (captionHindi/captionEnglish fields) |
| 11 | `app_strings.dart` | ACTUAL — add new strings |
| 12 | `studio_provider.dart` | ACTUAL — provides StudioState.profile.tier for watermark |

### Agent: Kavya (ui-engineer.agent.md) — CONTINUE

---

### STEP 2 — PASTE INTO COPILOT CHAT

```
════════════════════════════════════════════════════════
  PROJECT CONTEXT — ALWAYS INCLUDE IN EVERY SESSION
════════════════════════════════════════════════════════

PROJECT: Dukaan AI — Flutter Ad Result Screen
CURRENT STATE:
  • ad_preview_screen.dart is a stub (shows image + "coming soon" text)
  • background_select_screen.dart passes GeneratedAd as GoRouter extra
  • AdPreviewArgs class does not yet exist — create it this task

NEW PACKAGES NEEDED (already in pubspec — no pubspec changes):
  • share_plus: ^9.0.0 — SharePlus.instance.shareXFiles for WhatsApp
  • image_gallery_saver: ^2.0.3 — ImageGallerySaver.saveImage for gallery save
  • Both are already in pubspec.yaml. Import them directly.

PLATFORM NOTES:
  • Target: Android only (MVP). No iOS-specific code needed.
  • Gallery save requires WRITE_EXTERNAL_STORAGE in AndroidManifest
    (this was added in Task 1.1 scaffold — do not modify AndroidManifest)
  • Share via share_plus opens the native Android share sheet.
    WhatsApp will appear in the list — no deep-link needed for share.

RULES:
  • ConsumerStatefulWidget is acceptable here because the screen has
    multiple concurrent async actions (share + save + regenerate)
    that involve transient local loading flags
  • AdPreviewArgs is a plain Dart class — NO freezed, NO codegen
  • Analytics failures are non-fatal — catch and debugPrint, never rethrow
  • Watermark = UI overlay only. Do NOT burn watermark into the shared file.
  • Caption may be null (Task 1.9 fills it). Handle gracefully.
  • Image bytes downloaded once, cached in _imageBytes, reused for share+save

════════════════════════════════════════════════════════
  TASK 1.8 — FULL AD RESULT SCREEN
════════════════════════════════════════════════════════

────────────────────────────────────────
  NEW FILE 1 — lib/features/studio/domain/ad_preview_args.dart    (NEW)
────────────────────────────────────────

Plain Dart class. No freezed. No codegen. No part file needed.

  class AdPreviewArgs {
    const AdPreviewArgs({
      required this.generatedAd,
      required this.processedBase64,
      required this.backgroundStyleId,
      this.customPrompt,
    });

    final GeneratedAd generatedAd;
    final String processedBase64;       // kept for Regenerate action
    final String backgroundStyleId;     // kept for Regenerate action
    final String? customPrompt;         // kept for Regenerate action
  }

────────────────────────────────────────
  CHANGE 1 — background_select_screen.dart    (MODIFIED)
────────────────────────────────────────

In the ref.listen block where navigation currently happens:

REMOVE:
  context.push(AppRoutes.adPreview, extra: next.generatedAd);

REPLACE WITH:
  context.push(
    AppRoutes.adPreview,
    extra: AdPreviewArgs(
      generatedAd: next.generatedAd!,
      processedBase64: _processedBase64,      // the instance var set in didChangeDependencies
      backgroundStyleId:
          BackgroundStyle.all[next.selectedStyleIndex!].id,
      customPrompt: next.customPrompt.isEmpty ? null : next.customPrompt,
    ),
  );

No other changes to this file.

────────────────────────────────────────
  CHANGE 2 — studio_repository.dart interface    (MODIFIED)
────────────────────────────────────────

ADD these three method signatures:

  /// Inserts a row into usageevents. Non-fatal — failures are swallowed.
  Future<void> trackUsageEvent({
    required String userId,
    required String eventType,
    int creditsUsed = 0,
    Map<String, dynamic>? metadata,
  });

  /// Increments sharecount by 1. Non-fatal.
  Future<void> incrementShareCount(String adId);

  /// Increments downloadcount by 1. Non-fatal.
  Future<void> incrementDownloadCount(String adId);

────────────────────────────────────────
  CHANGE 3 — studio_repository_impl.dart    (MODIFIED)
────────────────────────────────────────

IMPLEMENT the three new methods:

  @override
  Future<void> trackUsageEvent({
    required String userId,
    required String eventType,
    int creditsUsed = 0,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await supabase
          .from(SupabaseTables.usageEvents)
          .insert({
            SupabaseColumns.userId: userId,
            'eventtype': eventType,
            'creditsused': creditsUsed,
            if (metadata != null) 'metadata': metadata,
          });
    } on PostgrestException catch (e) {
      debugPrint('trackUsageEvent failed: ${e.message}');
      // Non-fatal — analytics failures never block the user
    }
  }

  @override
  Future<void> incrementShareCount(String adId) async {
    try {
      final row = await supabase
          .from(SupabaseTables.generatedAds)
          .select('sharecount')
          .eq('id', adId)
          .single();
      final current = (row['sharecount'] as int?) ?? 0;
      await supabase
          .from(SupabaseTables.generatedAds)
          .update({'sharecount': current + 1})
          .eq('id', adId);
    } on PostgrestException catch (e) {
      debugPrint('incrementShareCount failed: ${e.message}');
    }
  }

  @override
  Future<void> incrementDownloadCount(String adId) async {
    try {
      final row = await supabase
          .from(SupabaseTables.generatedAds)
          .select('downloadcount')
          .eq('id', adId)
          .single();
      final current = (row['downloadcount'] as int?) ?? 0;
      await supabase
          .from(SupabaseTables.generatedAds)
          .update({'downloadcount': current + 1})
          .eq('id', adId);
    } on PostgrestException catch (e) {
      debugPrint('incrementDownloadCount failed: ${e.message}');
    }
  }

────────────────────────────────────────
  CHANGE 4 — ad_preview_screen.dart    (FULL REPLACEMENT)
────────────────────────────────────────

Replace the ENTIRE stub with this full implementation.
This is a ConsumerStatefulWidget — TickerProvider is NOT the reason;
the reason is managing multiple concurrent async action flags locally.

  // Required imports:
  // dart:io, dart:typed_data
  // package:flutter/services.dart (Clipboard)
  // package:share_plus/share_plus.dart
  // package:image_gallery_saver/image_gallery_saver.dart
  // package:http/http.dart as http
  // package:cached_network_image/cached_network_image.dart
  // + all app imports

  class AdPreviewScreen extends ConsumerStatefulWidget {
    const AdPreviewScreen({super.key});
  }

  class _AdPreviewScreenState extends ConsumerState<AdPreviewScreen> {
    late AdPreviewArgs _args;
    late GeneratedAd _currentAd;   // mutable — updated after Regenerate
    bool _isRegenerating = false;
    bool _isSharing = false;
    bool _isSaving = false;
    bool _analyticsTracked = false;
    Uint8List? _imageBytes;        // downloaded once, reused

    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      _args = GoRouterState.of(context).extra! as AdPreviewArgs;
      _currentAd = _args.generatedAd;
      if (!_analyticsTracked) {
        _analyticsTracked = true;
        _trackAnalytics();
      }
    }

    // ─── Analytics ───────────────────────────────────────────────
    void _trackAnalytics() {
      final userId =
          SupabaseClient.instance.auth.currentUser?.id ?? '';
      if (userId.isEmpty) return;
      final repo = ref.read(studioRepositoryProvider);
      repo.trackUsageEvent(
        userId: userId,
        eventType: 'adgenerated',
        creditsUsed: 1,
        metadata: {'backgroundstyle': _currentAd.backgroundStyle},
      );
    }

    // ─── Download image bytes (cached) ───────────────────────────
    Future<Uint8List> _getImageBytes() async {
      if (_imageBytes != null) return _imageBytes!;
      final response = await http.get(Uri.parse(_currentAd.imageUrl));
      if (response.statusCode != 200) {
        throw AppException.network(AppStrings.errorImageDownload);
      }
      _imageBytes = response.bodyBytes;
      return _imageBytes!;
    }

    // ─── Share to WhatsApp ────────────────────────────────────────
    Future<void> _shareToWhatsApp() async {
      if (_isSharing) return;
      setState(() => _isSharing = true);
      try {
        final bytes = await _getImageBytes();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath =
            '${Directory.systemTemp.path}${Platform.pathSeparator}dukaan_ad_$timestamp.jpg';
        await File(filePath).writeAsBytes(bytes);

        final caption = _currentAd.captionHindi ??
            _currentAd.captionEnglish ??
            AppStrings.shareDefaultCaption;

        await SharePlus.instance.shareXFiles(
          [XFile(filePath)],
          text: caption,
        );

        // Increment share count (non-blocking)
        ref
            .read(studioRepositoryProvider)
            .incrementShareCount(_currentAd.id);
      } on AppException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.userMessage), backgroundColor: AppColors.error),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.errorShareFailed),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSharing = false);
      }
    }

    // ─── Save to Gallery ─────────────────────────────────────────
    Future<void> _saveToGallery() async {
      if (_isSaving) return;
      setState(() => _isSaving = true);
      try {
        final bytes = await _getImageBytes();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final result = await ImageGallerySaver.saveImage(
          bytes,
          quality: 90,
          name: 'dukaan_ad_$timestamp',
          isReturnImagePathOfIOS: false,
        );

        if (result['isSuccess'] == true) {
          // Increment download count (non-blocking)
          ref
              .read(studioRepositoryProvider)
              .incrementDownloadCount(_currentAd.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.saveSuccessMessage),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } else {
          throw AppException.storage(AppStrings.errorSaveFailed);
        }
      } on AppException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.userMessage), backgroundColor: AppColors.error),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.errorSaveFailed),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }

    // ─── Copy Caption ─────────────────────────────────────────────
    Future<void> _copyCaption() async {
      final caption = _currentAd.captionHindi ??
          _currentAd.captionEnglish;
      if (caption == null || caption.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.captionNotAvailableYet),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }
      await Clipboard.setData(ClipboardData(text: caption));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.captionCopiedMessage),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }

    // ─── Regenerate ───────────────────────────────────────────────
    Future<void> _regenerate() async {
      if (_isRegenerating) return;
      setState(() {
        _isRegenerating = true;
        _imageBytes = null;    // clear cache — new image incoming
      });

      final userId =
          SupabaseClient.instance.auth.currentUser?.id ?? '';

      try {
        final service = ref.read(adGenerationServiceProvider);
        final newAd = await service.generateAd(
          AdCreationRequest(
            processedImageBase64: _args.processedBase64,
            backgroundStyleId: _args.backgroundStyleId,
            userId: userId,
            customPrompt: _args.customPrompt,
          ),
        );

        // Invalidate Studio so recent ads refreshes
        ref.invalidate(studioProvider);

        if (mounted) {
          setState(() => _currentAd = newAd);
        }
      } on AppException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.userMessage), backgroundColor: AppColors.error),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.errorGeneric),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isRegenerating = false);
      }
    }

    // ─── Build ────────────────────────────────────────────────────
    @override
    Widget build(BuildContext context) {
      // Watch studioProvider for user tier (watermark logic)
      final studioAsync = ref.watch(studioProvider);
      final isFreeTier =
          studioAsync.value?.profile?.tier == null ||
          studioAsync.value!.profile!.tier == 'free';

      return Scaffold(
        backgroundColor: Colors.black,   // dark bg for full-bleed image feel
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            AppStrings.adPreviewTitle,
            style: AppTypography.headlineMedium
                .copyWith(color: Colors.white),
          ),
          actions: [
            // Regenerate text button — top right
            if (_isRegenerating)
              const Padding(
                padding: EdgeInsets.only(right: AppSpacing.md),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              )
            else
              TextButton(
                onPressed: _regenerate,
                child: Text(
                  AppStrings.regenerateButton,
                  style: AppTypography.labelLarge
                      .copyWith(color: AppColors.primary),
                ),
              ),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Full-bleed ad image
            Center(
              child: RepaintBoundary(
                child: CachedNetworkImage(
                  imageUrl: _currentAd.imageUrl,
                  key: ValueKey(_currentAd.id),   // force rebuild on regenerate
                  placeholder: (context, url) => const ShimmerBox(
                    width: double.infinity,
                    height: 400,
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white54,
                      size: 64,
                    ),
                  ),
                  fit: BoxFit.contain,
                  memCacheWidth: 720,
                ),
              ),
            ),

            // Regenerating overlay
            if (_isRegenerating)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        AppStrings.regeneratingMessage,
                        style: AppTypography.bodyMedium
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

            // Watermark — free tier only, bottom-right
            if (isFreeTier)
              const Positioned(
                bottom: AppSpacing.lg + 120,   // above the action bar
                right: AppSpacing.md,
                child: Text(
                  'Made with Dukaan AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black87,
                        blurRadius: 4,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        // Persistent bottom action bar — 120dp height
        bottomNavigationBar: Container(
          height: 120,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // Save to Gallery
                Expanded(
                  child: _ActionColumn(
                    icon: Icons.save_alt_rounded,
                    label: AppStrings.saveButton,
                    isLoading: _isSaving,
                    onTap: _saveToGallery,
                  ),
                ),
                // Vertical divider
                const VerticalDivider(
                  width: 1,
                  color: AppColors.divider,
                  indent: AppSpacing.md,
                  endIndent: AppSpacing.md,
                ),
                // Share to WhatsApp
                Expanded(
                  child: _ActionColumn(
                    icon: Icons.share_rounded,
                    label: AppStrings.shareWhatsAppButton,
                    isLoading: _isSharing,
                    onTap: _shareToWhatsApp,
                  ),
                ),
                // Vertical divider
                const VerticalDivider(
                  width: 1,
                  color: AppColors.divider,
                  indent: AppSpacing.md,
                  endIndent: AppSpacing.md,
                ),
                // Copy Caption
                Expanded(
                  child: _ActionColumn(
                    icon: Icons.copy_rounded,
                    label: AppStrings.copyCaptionButton,
                    isLoading: false,
                    onTap: _copyCaption,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  // ─── Private widget: one action column in the action bar ─────────
  class _ActionColumn extends StatelessWidget {
    const _ActionColumn({
      required this.icon,
      required this.label,
      required this.isLoading,
      required this.onTap,
    });

    final IconData icon;
    final String label;
    final bool isLoading;
    final VoidCallback onTap;

    @override
    Widget build(BuildContext context) {
      return InkWell(
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(icon, color: AppColors.primary, size: 26),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }
  }

────────────────────────────────────────
  CHANGE 5 — app_strings.dart    (MODIFIED — add only)
────────────────────────────────────────

  // Ad preview / result screen
  static const regenerateButton       = 'Dubara banao';
  static const saveButton             = 'Save karo';
  static const shareWhatsAppButton    = 'WhatsApp
par bhejo';
  static const copyCaptionButton      = 'Caption
copy karo';
  static const saveSuccessMessage     = 'Photo gallery mein save ho gaya! 🎉';
  static const captionCopiedMessage   = 'Caption copy ho gaya! 📋';
  static const captionNotAvailableYet = 'Caption jaldi available hoga. (Task 1.9)';
  static const regeneratingMessage    = 'Naya ad ban raha hai...';
  static const shareDefaultCaption    = 'Dukaan AI se banaya — aap bhi try karein!';
  static const errorShareFailed       = 'Share nahi hua. Dobara try karein.';
  static const errorSaveFailed        = 'Save nahi hua. Dobara try karein.';

────────────────────────────────────────
  NEW FILE 2 — tests    (NEW)
────────────────────────────────────────

test/features/studio/presentation/screens/ad_preview_screen_test.dart:

IMPORTANT TEST RULES:
  - Use pump(Duration(milliseconds: 300)) — never pumpAndSettle
  - Mock studioProvider with a profile that has tier = 'free'
  - Mock studioProvider with a profile that has tier = 'dukaan' for paid tests
  - The GoRouterState.extra must be mocked as AdPreviewArgs

  testWidgets('AdPreviewScreen shows image with watermark on free tier', (tester) async {
    // ARRANGE: mock studioProvider with free tier
    // Mount screen with AdPreviewArgs via GoRouterState extra mock
    // ACT: pump once
    // ASSERT: find 'Made with Dukaan AI' text watermark visible
  })

  testWidgets('AdPreviewScreen hides watermark on paid tier', (tester) async {
    // ARRANGE: mock studioProvider with tier = 'dukaan'
    // ASSERT: find 'Made with Dukaan AI' — findsNothing
  })

  testWidgets('AdPreviewScreen shows 3 action buttons', (tester) async {
    // ASSERT: find AppStrings.saveButton, shareWhatsAppButton, copyCaptionButton
  })

  testWidgets('AdPreviewScreen shows Regenerate AppBar button', (tester) async {
    // ASSERT: find AppStrings.regenerateButton text
  })

  testWidgets('AdPreviewScreen shows regenerating overlay when isRegenerating is true', (tester) async {
    // This test triggers _regenerate via button tap
    // Mock adGenerationService to hang (completer not completed)
    // ASSERT after tap: find AppStrings.regeneratingMessage
  })

  testWidgets('copyCaption shows snackbar when captionHindi is null', (tester) async {
    // ARRANGE: generatedAd with captionHindi = null, captionEnglish = null
    // ACT: tap copy caption
    // ASSERT: find AppStrings.captionNotAvailableYet in snackbar
  })

────────────────────────────────────────
  OUTPUT ORDER (9 files total)
────────────────────────────────────────

NEW (1 file):
  1. lib/features/studio/domain/ad_preview_args.dart

MODIFIED (6 files):
  2. lib/features/studio/presentation/screens/background_select_screen.dart
  3. lib/features/studio/domain/repositories/studio_repository.dart
  4. lib/features/studio/infrastructure/studio_repository_impl.dart
  5. lib/features/studio/presentation/screens/ad_preview_screen.dart
  6. lib/core/constants/app_strings.dart

TEST (1 file):
  7. test/features/studio/presentation/screens/ad_preview_screen_test.dart

No generated files — AdPreviewArgs is a plain Dart class, not a provider.
No build_runner needed after this task.

────────────────────────────────────────
  DO NOT
────────────────────────────────────────

✗ DO NOT use pumpAndSettle in widget tests — use pump(Duration)
✗ DO NOT burn the watermark into the shared/saved image — UI overlay only
✗ DO NOT create a separate Notifier/provider for AdPreviewScreen
   — use ConsumerStatefulWidget with setState for local action flags
✗ DO NOT use Navigator.of(context).push — use context.go/push
✗ DO NOT download image bytes more than once — cache in _imageBytes field
✗ DO NOT make analytics failures throw — swallow with debugPrint
✗ DO NOT hardcode 'free' tier string — use a const if one exists, else
   compare to UserTier.free constant if defined in domain
✗ DO NOT forget the ValueKey(_currentAd.id) on CachedNetworkImage
   so it rebuilds properly after Regenerate
✗ DO NOT await incrementShareCount / incrementDownloadCount in the UI
   — fire and forget (don't block the user)
✗ DO NOT use Opacity widget — no Opacity animations on this screen
✗ DO NOT add freezed or codegen to AdPreviewArgs
```

---

## STEP 3 — AFTER COPILOT RESPONDS

```bash
# No build_runner needed (no new providers/freezed)

# Analyze
flutter analyze
# Expected: No issues found!

# Full test suite

flutter test
# Expected: 55+ passed, 0 failed

# Targeted
flutter test test/features/studio/presentation/
# Expected: 6/6 AdPreviewScreen widget tests pass

# Manual flow
flutter run --dart-define=WORKER_BASE_URL=http://localhost:8787
# Flow:
#   a. Complete full flow: FAB → camera → bg removal → select Diwali →
#      tap "Ad banao" → wait ~10 seconds
#   b. AdPreviewScreen appears with generated image
#   c. "Made with Dukaan AI" watermark visible (free tier)
#   d. Tap "Save karo" → gallery save SnackBar: "Photo gallery mein save ho gaya!"
#   e. Tap "WhatsApp par bhejo" → native share sheet opens
#   f. Tap "Caption copy karo" → SnackBar: "Caption jaldi available hoga." (null until Task 1.9)
#   g. Tap "Dubara banao" → spinner appears → new image generates → updates
#   h. Back to Studio → Recent Ads list shows 2 ads (original + regenerated)
#   i. Wrangler dev logs show both /api/generate-background calls
```

---

## VALIDATION CHECKLIST
cd C:\dev\smb_ai
- [ ] `AdPreviewArgs` is a plain Dart class with 4 fields (no codegen)
- [ ] `background_select_screen.dart` passes `AdPreviewArgs` (not `GeneratedAd`) as extra
- [ ] `AdPreviewScreen` reads extra as `AdPreviewArgs` in `didChangeDependencies`
- [ ] `_imageBytes` cached — downloaded once for both share and save
- [ ] Watermark only shows when `tier == 'free'` (check studioProvider)
- [ ] `ValueKey(_currentAd.id)` on `CachedNetworkImage` forces refresh on Regenerate
- [ ] `_analyticsTracked` bool prevents double-tracking on rebuild
- [ ] `incrementShareCount` / `incrementDownloadCount` fire-and-forget (not awaited in UI)
- [ ] Analytics `trackUsageEvent` failures caught with debugPrint
- [ ] Regenerate calls `ref.invalidate(studioProvider)` after success
- [ ] `captionNotAvailableYet` SnackBar shows when both captions are null
- [ ] `context.mounted` checked before every SnackBar call in async methods
- [ ] 6 widget tests pass
- [ ] `flutter analyze`: No issues found!

---

## WHAT COMES NEXT

> **Task 1.9 — AI Caption Generator Worker + Flutter Wiring**
> Dev agent writes `POST /api/generate-caption` Worker using OpenAI
> GPT-4o-mini. Rate limit: 20/hour. Accepts `productName`, `category`,
> `language` (hindi/english/hinglish), optional `offer`. KV cache for
> identical requests (1-hour TTL to reduce API costs). Kavya wires
> `CaptionService` in Flutter — called automatically after `generateAd()`
> succeeds, backfilling `captionHindi`/`captionEnglish` in the saved
> `generatedads` row. AdPreviewScreen's "Copy Caption" button then works.
>
> **Task 1.10 — Caption Language Selector Widget**
> Builds the `CaptionLanguageSelector` StatelessWidget (3 toggle buttons:
> Hinglish | Hindi | English) that appears on AdPreviewScreen below the
> action bar. State managed by Riverpod. Switches which caption is
> displayed and copied.

---

*Dukaan AI v1.0 Build Playbook · Task 1.8 · Generated April 2026*
