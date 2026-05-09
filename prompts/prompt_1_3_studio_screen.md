# PROMPT 1.3 — Studio Home Screen (First Real Feature Screen)
### Dukaan AI · Copilot Chat Prompt · Expanded Edition

---

## TASK 1.2 ASSESSMENT

| Check | Status | Note |
|---|---|---|
| `flutter test test/shared/widgets/` | ✅ 8/8 passed | AppButton (5) + ShimmerBox (3) all green |
| `flutter analyze` on Task 1.2 files | ✅ Zero errors | All new files clean |
| `flutter analyze` overall | ⚠️ 3 issues | Pre-existing `widget_test.dart` — fix below |
| 32 outdated packages | ℹ️ Informational | Not blocking, review before Play Store release |

### Fix Required Before Task 1.3

All 3 analyze errors are in `test/widget_test.dart` — the default Flutter
scaffold test that still references the old `MyApp` class (now `DukaanApp`).
**Delete it.** We have real tests now.

```powershell
# PowerShell
Remove-Item test\widget_test.dart
flutter analyze
# Expected: No issues found!
```

---

## STEP 0 — ATTACH THESE FILES IN COPILOT CHAT

| # | File | Why |
|---|---|---|
| 1 | `copilot-instructions.md` | Global rules, anti-hallucination contract |
| 2 | `flutter.instructions.md` | ConsumerStatefulWidget, Supabase query rules, performance rules |
| 3 | `SKILL.md` → *flutter-design-system* | Card pattern, ShimmerBox, CachedAdImage, screen structure template |
| 4 | `SKILL.md` → *riverpod-patterns* | AsyncNotifier, freezed state, repository provider pattern |
| 5 | `SKILL.md` → *supabase-schema* | generatedads + profiles columns, query patterns, RLS |
| 6 | `new-feature.prompt.md` | Enforces domain → infra → provider → screen build order |
| 7 | `riverpod-provider.prompt.md` | Provider creation rules, freezed state, mandatory tests |
| 8 | `studio_screen.dart` | Attach ACTUAL file — replace body, keep mixin structure intact |
| 9 | `shared_providers.dart` | Attach ACTUAL file — studioRepositoryProvider depends on it |

### Agent: Kavya (ui-engineer.agent.md) — CONTINUE
> Keep Kavya active. She owns all UI from Task 1.2 onward.
> Dev (worker-dev.agent.md) activates from Task 1.5 (first Cloudflare Worker).

---

## STEP 1 — VERIFY DEPENDENCY

`cached_network_image` must be in pubspec.yaml (for GeneratedAdCard thumbnails).
If missing, add it before running the prompt:

```yaml
dependencies:
  cached_network_image: ^3.3.1
```

Then `flutter pub get`.

---

## STEP 2 — PASTE THIS INTO COPILOT CHAT

```
════════════════════════════════════════════════════════
  PROJECT CONTEXT — ALWAYS INCLUDE IN EVERY SESSION
════════════════════════════════════════════════════════

PROJECT: Dukaan AI — Flutter app for Indian small business
owners. AI-powered ad generation + Khata + WhatsApp sharing.

TECH STACK: Flutter 3.x / Riverpod 2.x (code-gen) /
GoRouter / Supabase / Cloudflare Workers / Razorpay / FCM

TARGET: 2GB RAM Android, Snapdragon 400-series, 60fps mandatory.

ARCHITECTURE RULES:
  • Riverpod ONLY — code-gen with @riverpod + build_runner
  • All state classes use freezed — immutable, pattern-matchable
  • ConsumerWidget by default. ConsumerStatefulWidget ONLY when
    mixin (AutomaticKeepAliveClientMixin / TickerProvider) is needed
  • All strings → AppStrings.* — zero hardcoded text in widgets
  • All values → AppColors.* / AppSpacing.* / AppRadius.* / AppTypography.*
  • Supabase tables → SupabaseTables.*  |  columns → SupabaseColumns.*
  • NEVER .select() without specifying columns explicitly
  • NEVER access supabase.auth.currentUser in any widget
  • NEVER import one feature's provider from another feature
  • const on every widget that does not depend on runtime data
  • No print(), no dynamic type, no silent catch blocks

ALREADY BUILT (do not rebuild or re-import):
  • AppColors, AppSpacing, AppRadius, AppTypography, AppShadows, AppTheme
  • AppStrings, AppRoutes, SupabaseTables, SupabaseColumns
  • AppException (sealed class), ErrorHandler
  • SupabaseClientWrapper, supabaseClientProvider, authStateProvider
  • AppShellScaffold, AppButton, ShimmerBox, AppBottomSheet

════════════════════════════════════════════════════════
  TASK 1.3 — STUDIO HOME SCREEN
════════════════════════════════════════════════════════

CONTEXT:
This is the first real feature. We replace the StudioScreen
placeholder with a working screen showing a personalized
greeting, a Quick Create card row (4 actions), and a Recent
Ads list (last 3 ads, shimmer on load, pull-to-refresh).

Strict build order: domain → infrastructure → application
→ widgets → screen. Do not write screen code before the
provider exists.

────────────────────────────────────────
  R — ROLE
────────────────────────────────────────

You are Kavya, the Dukaan AI Flutter UI engineer.
Build each layer in strict sequence. Every widget uses
design system tokens. Performance is non-negotiable.

────────────────────────────────────────
  A — ARCHITECTURE: Layer-by-layer spec
────────────────────────────────────────

═══════════════════════════════
  LAYER 1 — DOMAIN MODELS
═══════════════════════════════

── 1a. GeneratedAd model ──
Path: lib/features/studio/domain/generated_ad.dart

Freezed model. Maps from the `generatedads` Supabase table.

  @freezed
  class GeneratedAd with _$GeneratedAd {
    const factory GeneratedAd({
      required String id,
      required String userId,
      required String imageUrl,
      String? thumbnailUrl,
      String? backgroundStyle,
      String? captionHindi,
      String? captionEnglish,
      @Default(0) int shareCount,
      @Default(0) int downloadCount,
      String? festivalTag,
      required DateTime createdAt,
    }) = _GeneratedAd;
  }

factory GeneratedAd.fromJson(Map<String, dynamic> json):
  Use SupabaseColumns.* for every field lookup.
  createdAt: DateTime.parse(json[SupabaseColumns.createdAt] as String)
  shareCount: json['sharecount'] as int? ?? 0
  downloadCount: json['downloadcount'] as int? ?? 0
  festivalTag: json['festivaltag'] as String?

Part directives:
  part 'generated_ad.freezed.dart';
  part 'generated_ad.g.dart';

── 1b. UserProfile model ──
Path: lib/shared/domain/user_profile.dart

SHARED model used by studio, account, and pricing features.
Put in lib/shared/domain/ — NOT in studio feature folder.

  @freezed
  class UserProfile with _$UserProfile {
    const factory UserProfile({
      required String id,
      required String shopName,
      String? ownerName,
      String? phone,
      String? city,
      String? category,
      @Default('free') String tier,
      @Default(3) int creditsRemaining,
      @Default('hinglish') String language,
    }) = _UserProfile;
  }

factory UserProfile.fromJson(Map<String, dynamic> json):
  Use SupabaseColumns.* for every field where a constant exists.
  ownerName: json['ownername'] as String?
  tier: json[SupabaseColumns.tier] as String? ?? 'free'
  creditsRemaining: json[SupabaseColumns.creditsRemaining] as int? ?? 3
  language: json[SupabaseColumns.language] as String? ?? 'hinglish'

Part directives:
  part 'user_profile.freezed.dart';
  part 'user_profile.g.dart';

── 1c. QuickCreateItem ──
Path: lib/features/studio/domain/quick_create_item.dart

Plain Dart class. NOT freezed. NOT from Supabase.
UI-only data for the 4 Quick Create cards.

  class QuickCreateItem {
    const QuickCreateItem({
      required this.emoji,
      required this.label,
      required this.route,
    });
    final String emoji;
    final String label;
    final String route;
  }

── 1d. StudioState ──
Path: lib/features/studio/application/studio_state.dart

  @freezed
  class StudioState with _$StudioState {
    const factory StudioState({
      @Default([]) List<GeneratedAd> recentAds,
      UserProfile? profile,
      String? todayFestival,
    }) = _StudioState;
  }

Part directive:
  part 'studio_state.freezed.dart';
  (NO .g.dart — StudioState is never serialized)

── 1e. FestivalCalendar utility ──
Path: lib/shared/utils/festival_calendar.dart

Static utility. No Riverpod. No Supabase. No constructor.

  class FestivalCalendar {
    FestivalCalendar._();

    static const _festivals = <String, String>{
      '2026-03-29': 'Holi 🎨',
      '2026-04-06': 'Ram Navami 🙏',
      '2026-04-14': 'Baisakhi 🌾',
      '2026-06-19': 'Eid ul-Adha 🌙',
      '2026-08-09': 'Raksha Bandhan 🪢',
      '2026-08-20': 'Janmashtami 🪈',
      '2026-10-02': 'Gandhi Jayanti 🇮🇳',
      '2026-10-20': 'Navratri 🔱',
      '2026-10-29': 'Dussehra 🏹',
      '2026-11-15': 'Dhanteras 💰',
      '2026-11-17': 'Diwali 🪔',
      '2026-11-19': 'Bhai Dooj 💝',
      '2026-12-25': 'Christmas 🎄',
      '2027-01-01': 'New Year 🎆',
    };

    /// Returns today's festival name+emoji, or null if no festival today.
    static String? getTodayFestival() {
      final today = DateTime.now();
      final key =
          '${today.year}-'
          '${today.month.toString().padLeft(2, '0')}-'
          '${today.day.toString().padLeft(2, '0')}';
      return _festivals[key];
    }
  }

═══════════════════════════════
  LAYER 2 — REPOSITORY
═══════════════════════════════

── 2a. StudioRepository interface ──
Path: lib/features/studio/domain/studio_repository.dart

  abstract interface class StudioRepository {
    Future<List<GeneratedAd>> getRecentAds({
      required String userId,
      int limit = 3,
    });

    Future<UserProfile> getProfile({required String userId});
  }

── 2b. StudioRepositoryImpl ──
Path: lib/features/studio/infrastructure/studio_repository_impl.dart

  class StudioRepositoryImpl implements StudioRepository {
    const StudioRepositoryImpl(this._client);
    final SupabaseClient _client;

    @override
    Future<List<GeneratedAd>> getRecentAds({
      required String userId,
      int limit = 3,
    }) async {
      try {
        final rows = await _client
            .from(SupabaseTables.generatedAds)
            .select(
              '${SupabaseColumns.id}, '
              '${SupabaseColumns.userId}, '
              '${SupabaseColumns.imageUrl}, '
              '${SupabaseColumns.thumbnailUrl}, '
              '${SupabaseColumns.backgroundStyle}, '
              '${SupabaseColumns.captionHindi}, '
              '${SupabaseColumns.captionEnglish}, '
              'sharecount, downloadcount, festivaltag, '
              '${SupabaseColumns.createdAt}',
            )
            .eq(SupabaseColumns.userId, userId)
            .order(SupabaseColumns.createdAt, ascending: false)
            .limit(limit);
        return rows.map(GeneratedAd.fromJson).toList();
      } on PostgrestException catch (e) {
        throw AppException.supabase(e.message);
      } catch (e) {
        throw AppException.unknown(e.toString());
      }
    }

    @override
    Future<UserProfile> getProfile({required String userId}) async {
      try {
        final row = await _client
            .from(SupabaseTables.profiles)
            .select(
              '${SupabaseColumns.id}, '
              '${SupabaseColumns.shopName}, ownername, '
              '${SupabaseColumns.phone}, '
              '${SupabaseColumns.city}, '
              '${SupabaseColumns.category}, '
              '${SupabaseColumns.tier}, '
              '${SupabaseColumns.creditsRemaining}, '
              '${SupabaseColumns.language}',
            )
            .eq(SupabaseColumns.id, userId)
            .single();
        return UserProfile.fromJson(row);
      } on PostgrestException catch (e) {
        throw AppException.supabase(e.message);
      } catch (e) {
        throw AppException.unknown(e.toString());
      }
    }
  }

═══════════════════════════════
  LAYER 3 — PROVIDERS
═══════════════════════════════

Path for both providers: lib/features/studio/application/studio_provider.dart

Part directive: part 'studio_provider.g.dart';

── 3a. studioRepositoryProvider ──

  @riverpod
  StudioRepository studioRepository(StudioRepositoryRef ref) {
    final client = ref.watch(supabaseClientProvider);
    return StudioRepositoryImpl(client);
  }

── 3b. studioProvider (AsyncNotifier<StudioState>) ──

  @riverpod
  class Studio extends _$Studio {
    @override
    Future<StudioState> build() async {
      final client = ref.watch(supabaseClientProvider);
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        // Not authenticated — router will redirect. Return empty state.
        return const StudioState();
      }

      final repo = ref.watch(studioRepositoryProvider);

      // Parallel fetch — never sequential
      final results = await Future.wait([
        repo.getRecentAds(userId: userId, limit: 3),
        repo.getProfile(userId: userId),
      ]);

      return StudioState(
        recentAds: results[0] as List<GeneratedAd>,
        profile: results[1] as UserProfile,
        todayFestival: FestivalCalendar.getTodayFestival(),
      );
    }

    /// Refreshes the studio screen after an action (e.g., new ad created).
    Future<void> refresh() async {
      ref.invalidateSelf();
      await future;
    }
  }

IMPORTANT: After creating this file, run:
  dart run build_runner build --delete-conflicting-outputs

═══════════════════════════════
  LAYER 4 — WIDGETS
═══════════════════════════════

── 4a. QuickCreateCard ──
Path: lib/features/studio/presentation/widgets/quick_create_card.dart

  class QuickCreateCard extends StatelessWidget {
    const QuickCreateCard({
      super.key,
      required this.item,
      required this.onTap,
    });
    final QuickCreateItem item;
    final VoidCallback onTap;
  }

Visual spec (80w x 90h):
  GestureDetector wrapping a Container:
    width: 80, height: 90
    decoration: color AppColors.surface,
                borderRadius AppRadius.card (12),
                boxShadow AppShadows.card
    child: Column(mainAxisAlignment: center):
      Text(item.emoji, fontSize: 28)          ← raw fontSize ok here (emoji size)
      SizedBox(AppSpacing.xs)
      Padding(horizontal: AppSpacing.xs):
        Text(item.label, style: AppTypography.labelSmall,
          textAlign: center, maxLines: 2, overflow: ellipsis)

── 4b. GeneratedAdCard ──
Path: lib/features/studio/presentation/widgets/generated_ad_card.dart

  class GeneratedAdCard extends StatelessWidget {
    const GeneratedAdCard({
      super.key,
      required this.ad,
      required this.onShare,
      required this.onDownload,
    });
    final GeneratedAd ad;
    final VoidCallback onShare;
    final VoidCallback onDownload;
  }

MANDATORY: Wrap in RepaintBoundary — isolates repaint from list scroll.
Full-width, height: 88.

  RepaintBoundary(
    child: Container(
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Row(children: [
        // LEFT: thumbnail 120x88 with rounded left corners only
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.card),
            bottomLeft: Radius.circular(AppRadius.card),
          ),
          child: CachedNetworkImage(
            imageUrl: ad.thumbnailUrl ?? ad.imageUrl,
            width: 120, height: 88,
            fit: BoxFit.cover,
            memCacheWidth: 240,           // downscales in-memory: MANDATORY
            placeholder: (_, __) =>
              ShimmerBox(width: 120, height: 88, borderRadius: 0),
            errorWidget: (_, __, ___) => Container(
              width: 120, height: 88,
              color: AppColors.divider,
              child: Icon(Icons.image_not_supported_outlined,
                color: AppColors.textHint),
            ),
          ),
        ),
        // RIGHT: date + action icons
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(ad.createdAt),
                  style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                ),
                if (ad.festivalTag != null)
                  Text(ad.festivalTag!,
                    style: AppTypography.labelSmall
                      .copyWith(color: AppColors.primary)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.share_outlined,
                        color: AppColors.textSecondary, size: 20),
                      onPressed: onShare,
                      tooltip: AppStrings.share,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    IconButton(
                      icon: Icon(Icons.download_outlined,
                        color: AppColors.textSecondary, size: 20),
                      onPressed: onDownload,
                      tooltip: AppStrings.download,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ]),
    ),
  )

Private top-level function (below class definition, same file):
  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Aaj';
    if (diff.inDays == 1) return 'Kal';
    if (diff.inDays < 7) return '${diff.inDays} din pehle';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

── 4c. StudioSkeleton ──
Path: lib/features/studio/presentation/widgets/studio_skeleton.dart

  class StudioSkeleton extends StatelessWidget {
    const StudioSkeleton({super.key});
  }

CRITICAL: Skeleton layout MUST mirror the real StudioScreen section-by-section.
Same padding, same section order, same heights as real content.

  SingleChildScrollView(
    physics: const NeverScrollableScrollPhysics(),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ShimmerBox(width: 200, height: 24),                  // greeting
          SizedBox(height: AppSpacing.xs),
          ShimmerBox(width: 140, height: 16),                  // festival
          SizedBox(height: AppSpacing.lg),

          // Section label
          ShimmerBox(width: 100, height: 16),
          SizedBox(height: AppSpacing.sm),

          // Quick Create row (4 cards)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: List.generate(4, (i) => Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: ShimmerBox(width: 80, height: 90,
                borderRadius: AppRadius.card),
            ))),
          ),
          SizedBox(height: AppSpacing.lg),

          // Section label
          ShimmerBox(width: 100, height: 16),
          SizedBox(height: AppSpacing.sm),

          // 3 ad card skeletons
          ...List.generate(3, (_) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ShimmerBox(width: double.infinity, height: 88,
              borderRadius: AppRadius.card),
          )),
        ],
      ),
    ),
  )

═══════════════════════════════
  LAYER 5 — STUDIO SCREEN
═══════════════════════════════

MODIFY lib/features/studio/presentation/screens/studio_screen.dart
Keep the ConsumerStatefulWidget + AutomaticKeepAliveClientMixin from Task 1.2.
Replace only the placeholder body content.

Static Quick Create data (on the State class, NOT in build()):

  static const _quickCreate = [
    QuickCreateItem(
      emoji: '📷',
      label: AppStrings.quickCreatePhoto,
      route: AppRoutes.cameraCapture,  // TODO: add to AppRoutes in Task 1.4
    ),
    QuickCreateItem(
      emoji: '🎉',
      label: AppStrings.quickCreateFestival,
      route: AppRoutes.cameraCapture,
    ),
    QuickCreateItem(
      emoji: '📱',
      label: AppStrings.quickCreateWhatsApp,
      route: AppRoutes.cameraCapture,
    ),
    QuickCreateItem(
      emoji: '🏷️',
      label: AppStrings.quickCreateOffer,
      route: AppRoutes.cameraCapture,
    ),
  ];

Build method:

  @override
  Widget build(BuildContext context) {
    super.build(context);  // AutomaticKeepAliveClientMixin — REQUIRED
    final studioAsync = ref.watch(studioProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Dukaan AI',
          style: AppTypography.headlineLarge
            .copyWith(color: AppColors.primary)),
        // TODO Task 4.4: replace Text with Image.asset logo
        actions: [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: studioAsync.whenData(
              (s) => _CreditsChip(
                credits: s.profile?.creditsRemaining ?? 0),
            ).valueOrNull ?? const SizedBox.shrink(),
          ),
        ],
      ),
      body: studioAsync.when(
        loading: () => const StudioSkeleton(),
        error: (e, _) => _ErrorBody(
          message: ErrorHandler.toUserMessage(e),
          onRetry: () => ref.invalidate(studioProvider),
        ),
        data: (state) => _StudioBody(
          state: state,
          quickCreate: _quickCreate,
        ),
      ),
    );
  }

Private widgets (all StatelessWidget with const constructors, same file):

_ErrorBody:
  Column(mainAxisAlignment: center):
    Text(message, style: bodyMedium + textSecondary, textAlign: center)
    SizedBox(AppSpacing.md)
    AppButton(label: AppStrings.retry, onPressed: onRetry, isFullWidth: false)

_StudioBody (receives StudioState + quickCreate list):
  RefreshIndicator(
    onRefresh: () => ref.read(studioProvider.notifier).refresh(),
    color: AppColors.primary,
    child: CustomScrollView(slivers: [
      SliverPadding(
        padding: EdgeInsets.all(AppSpacing.md),
        sliver: SliverList(delegate: SliverChildListDelegate([
          _HeaderSection(shopName, festival),
          SizedBox(AppSpacing.lg),
          Text(AppStrings.sectionQuickCreate, AppTypography.headlineMedium),
          SizedBox(AppSpacing.sm),
          _QuickCreateRow(quickCreate),
          SizedBox(AppSpacing.lg),
          _RecentAdsHeader(),                        // title + See All button
          SizedBox(AppSpacing.sm),
          if (state.recentAds.isEmpty)
            const _EmptyAdsState()
          else
            ...state.recentAds.map((ad) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: GeneratedAdCard(
                ad: ad,
                onShare: () {},     // TODO Task 1.8
                onDownload: () {},  // TODO Task 1.8
              ),
            )),
          SizedBox(AppSpacing.xxl),
        ])),
      ),
    ]),
  )

_HeaderSection:
  Text('${AppStrings.greetingPrefix}${shopName}!',
    style: AppTypography.headlineLarge)
  if festival != null:
    SizedBox(AppSpacing.xs)
    Text('Aaj hai: $festival',
      style: AppTypography.bodyMedium.copyWith(color: AppColors.primary))

_QuickCreateRow (receives List<QuickCreateItem>):
  SingleChildScrollView(horizontal):
    Row: items.map((item) => Padding(right: AppSpacing.sm,
      child: QuickCreateCard(item, onTap: () => context.push(item.route))))

_RecentAdsHeader:
  Row(spaceBetween):
    Text(AppStrings.sectionRecentAds, headlineMedium)
    TextButton → context.go(AppRoutes.myAds), label AppStrings.seeAll
                 style: labelLarge + primary color

_CreditsChip (receives int credits):
  Container(
    decoration: rounded AppRadius.chip,
    color: credits > 0 ? AppColors.primaryLight
                       : AppColors.error.withOpacity(0.1),
    child: Text('$credits ${AppStrings.creditsLabel}',
      style: labelSmall,
      color: credits > 0 ? AppColors.primary : AppColors.error)
  )

_EmptyAdsState:
  Padding(xl): Column:
    Icon(auto_awesome_outlined, size: 48, textHint)
    SizedBox(sm)
    Text(AppStrings.emptyAds, bodyMedium + textSecondary, center)

═══════════════════════════════
  LAYER 6 — APP STRINGS UPDATE
═══════════════════════════════

MODIFY lib/core/constants/app_strings.dart — ADD these only:

  // Studio sections
  static const sectionQuickCreate   = 'Jaldi banao';
  static const sectionRecentAds     = 'Haale ke ads';
  static const seeAll               = 'Sab dekho';
  static const creditsLabel         = 'credits';

  // Quick Create card labels
  static const quickCreatePhoto     = 'Product Photo';
  static const quickCreateFestival  = 'Festival Ad';
  static const quickCreateWhatsApp  = 'WhatsApp Status';
  static const quickCreateOffer     = 'Offer Banner';

  // Actions
  static const share                = 'Share';
  static const download             = 'Download';

────────────────────────────────────────
  F — FORMAT: Output these files in order
────────────────────────────────────────

 1. lib/shared/utils/festival_calendar.dart                            (NEW)
 2. lib/shared/domain/user_profile.dart                                (NEW)
 3. lib/features/studio/domain/generated_ad.dart                       (NEW)
 4. lib/features/studio/domain/quick_create_item.dart                  (NEW)
 5. lib/features/studio/application/studio_state.dart                  (NEW)
 6. lib/features/studio/domain/studio_repository.dart                  (NEW)
 7. lib/features/studio/infrastructure/studio_repository_impl.dart     (NEW)
 8. lib/features/studio/application/studio_provider.dart               (NEW)
 9. lib/features/studio/presentation/widgets/quick_create_card.dart    (NEW)
10. lib/features/studio/presentation/widgets/generated_ad_card.dart    (NEW)
11. lib/features/studio/presentation/widgets/studio_skeleton.dart      (NEW)
12. lib/core/constants/app_strings.dart           (MODIFIED — add only)
13. lib/features/studio/presentation/screens/studio_screen.dart        (MODIFIED)
14. test/features/studio/application/studio_provider_test.dart         (NEW)
15. test/features/studio/domain/festival_calendar_test.dart            (NEW)

────────────────────────────────────────
  T — TESTS
────────────────────────────────────────

test/features/studio/application/studio_provider_test.dart
Use mocktail to mock StudioRepository:

  Test 1: build() returns StudioState with recentAds list when user is logged in
  Test 2: build() returns empty StudioState when userId is null (no session)
  Test 3: build() propagates AppException.supabase from repo.getRecentAds
  Test 4: recentAds in state is limited to max 3 items
  Test 5: refresh() calls invalidateSelf and re-fetches data

test/features/studio/domain/festival_calendar_test.dart
No mocking. Pure dart logic:

  Test 1: getTodayFestival() returns null for a date with no festival
  Test 2: For date '2026-11-17' (Diwali) the result contains 'Diwali'
  Test 3: All returned strings include an emoji character
  HINT: Test with known dates by passing a testDate parameter,
        or refactor getTodayFestival to accept an optional DateTime
        override for testability.

────────────────────────────────────────
  DO NOT
────────────────────────────────────────

✗ DO NOT use .select() without listing columns
✗ DO NOT access supabase.auth.currentUser in any widget or provider build
✗ DO NOT use ListView with children — use CustomScrollView + SliverList
✗ DO NOT skip memCacheWidth: 240 on CachedNetworkImage
✗ DO NOT skip RepaintBoundary around GeneratedAdCard
✗ DO NOT define _quickCreate inside build() — must be static const
✗ DO NOT use Opacity widget — use .withOpacity() on Color directly
✗ DO NOT add Share/Download logic — both are TODO until Task 1.8
✗ DO NOT use AppRoutes.cameraCapture as a real constant — it doesn't exist
   yet. Write context.push(AppRoutes.cameraCapture) with a TODO comment.
✗ DO NOT forget super.build(context) as first line in StudioScreen build()
✗ DO NOT put UserProfile in lib/features/studio/ — it belongs in lib/shared/
✗ DO NOT use dynamic type in any fromJson method — cast explicitly

────────────────────────────────────────
  QUALITY GATES
────────────────────────────────────────

  □ UserProfile is in lib/shared/domain/ NOT in features/studio/
  □ QuickCreateItem has NO @freezed annotation — plain const Dart class
  □ studioProvider uses Future.wait() for parallel Supabase calls
  □ .select() in impl specifies ALL column names as interpolated strings
  □ StudioSkeleton has exactly 3 sections matching real screen structure
  □ GeneratedAdCard is wrapped in RepaintBoundary
  □ CachedNetworkImage has memCacheWidth: 240
  □ _formatDate is a top-level private function, NOT inside build()
  □ _quickCreate is static const on State class — NOT rebuilt each frame
  □ All private _XxxWidget classes have const constructors
  □ FestivalCalendar has a private constructor FestivalCalendar._()
  □ build_runner will generate 6 files — confirm in Format section
```

---

## STEP 3 — AFTER COPILOT RESPONDS

```bash
# 1. Generate all freezed + Riverpod files
dart run build_runner build --delete-conflicting-outputs

# Expected new generated files:
#   lib/shared/domain/user_profile.freezed.dart
#   lib/shared/domain/user_profile.g.dart
#   lib/features/studio/domain/generated_ad.freezed.dart
#   lib/features/studio/domain/generated_ad.g.dart
#   lib/features/studio/application/studio_state.freezed.dart
#   lib/features/studio/application/studio_provider.g.dart

# 2. Static analysis
flutter analyze
# Expected: No issues found!

# 3. Unit tests
flutter test test/features/studio/
# Expected: 8 tests pass (5 provider + 3 festival)

# 4. Hot reload and verify
flutter run
```

### Visual Verification Checklist
- [ ] **Skeleton shows** immediately on first load — no white flash
- [ ] **Quick Create** row scrolls horizontally with 4 cards
- [ ] **Greeting** shows shop name from Supabase profile
- [ ] **Festival subtitle** shows today's festival (test by temporarily changing device date to 2026-11-17)
- [ ] **Credits chip** shows correct count in AppBar top-right
- [ ] **Empty state** shown when `recentAds` is empty (first-run user)
- [ ] **Pull-to-refresh** triggers provider refresh (orange indicator)
- [ ] **Error state** shows retry button when network fails (test in airplane mode)

---

## STEP 4 — FULL CHECKLIST

**Domain Layer**
- [ ] `GeneratedAd.fromJson` uses only `SupabaseColumns.*` constants — zero string literals
- [ ] `UserProfile` is in `lib/shared/domain/` — not inside studio feature folder
- [ ] `QuickCreateItem` is a plain `const` class with no `@freezed`
- [ ] `StudioState.recentAds` has `@Default([])` — never nullable list

**Repository**
- [ ] `StudioRepository` is `abstract interface class` (Dart 3 syntax)
- [ ] `.select()` call lists every fetched column explicitly
- [ ] `PostgrestException` caught before generic `catch (e)`
- [ ] `.single()` used for profile fetch (not `.limit(1)`)

**Provider**
- [ ] `studioRepositoryProvider` watches `supabaseClientProvider`
- [ ] `studioProvider.build()` uses `Future.wait()` for parallel calls
- [ ] `refresh()` calls `ref.invalidateSelf()` then `await future`
- [ ] `studio_provider.g.dart` generated by build_runner

**Widgets**
- [ ] `GeneratedAdCard` wrapped in `RepaintBoundary`
- [ ] `CachedNetworkImage` has `memCacheWidth: 240`
- [ ] `ShimmerBox` placeholder is exactly `120x88` (same as image)
- [ ] `_quickCreate` is `static const` — one instance for app lifetime
- [ ] `_CreditsChip` turns red when `credits == 0`
- [ ] `StudioSkeleton` has 3 sections in same order as real screen

**Screen**
- [ ] `super.build(context)` is first line in overridden `build()`
- [ ] All 3 `.when()` states handled: loading, error, data
- [ ] Error state uses `AppButton` with retry callback
- [ ] `RefreshIndicator.color` is `AppColors.primary`

**Tests**
- [ ] 5 studio provider tests pass with mocktail
- [ ] 3 festival calendar tests pass
- [ ] `flutter analyze` shows zero issues after build_runner run

---

## WHAT COMES NEXT

> **Task 1.4 — Camera Capture Flow**
> Implements `captureAndProcessImage()`: opens the device camera
> via `image_picker`, compresses via `flutter_image_compress`,
> previews in `AppBottomSheet`, and stubs the background removal
> service call. Adds `AppRoutes.cameraCapture` to `AppRoutes` so
> the Studio screen Quick Create cards and the FAB both navigate here.
>
> New packages needed before Task 1.4 (add to pubspec.yaml now):
>   `image_picker: ^1.1.2`
>   `flutter_image_compress: ^2.2.0`
>
> Agent: Kavya continues for Flutter layer.
> Dev activates in Task 1.5 for the Cloudflare Worker.

---

*Dukaan AI v1.0 Build Playbook · Task 1.3 · Generated April 2026*
