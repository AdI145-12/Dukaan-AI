# TASK 3.2 — CreditGuard + My Ads Gallery Screen
### Dukaan AI · Week 3 Continues · Flutter + Firestore

---

## CURRENT ERRORS — Fix All Before Task 3.2

---

### 🔴 CRITICAL FIX — Android Build Failure (Root Cause of ALL Firebase Issues)

```
Error: No matching client found for package name 'com.example.smb_ai'
       in android/app/src/google-services.json
```

**This is the root cause of every Firebase error since Task 2.2.**
Your `google-services.json` was downloaded for a DIFFERENT package name
than `com.example.smb_ai`. Firebase initialization fails silently on
auth, Firestore, and FCM because of this mismatch.

**Fix (choose one):**

**Option A — Change app package name to match google-services.json (RECOMMENDED)**
This also satisfies Prompt 4.4 which sets the production applicationId.

```
1. Open android/app/src/google-services.json
2. Find the "package_name" field — note its value (likely "com.dukaanai.app")
3. Open android/app/build.gradle
4. Change: applicationId "com.example.smb_ai"
        → applicationId "com.dukaanai.app"   (or whatever is in google-services.json)
5. Also update the test applicationId if present:
        testApplicationId "com.dukaanai.app.test"
```

**Option B — Register the current package name in Firebase Console**
```
Firebase Console → Project Settings → Your apps → Add app → Android
  Android package name: com.example.smb_ai
  App nickname: Dukaan AI Dev
Download the new google-services.json → replace android/app/google-services.json
```

After either fix, re-run:
  flutter run -d emulator-5554 --dart-define=SKIP_AUTH=true

Expected: App builds and runs. Firebase initializes. Anonymous sign-in
succeeds. Both Studio and Khata show EMPTY STATE (not error state).

---

### Worker Fix A — Delete Empty Placeholder Test Files (Terminal)

6 test files exist in `workers/test/` with no test content, causing:
  "Error: No test suite found in file ..."

```powershell
cd C:\dev\smb_ai\workers

# Delete the empty placeholder files
Remove-Item test\handlers\create_order.test.ts
Remove-Item test\handlers\verify_payment.test.ts
Remove-Item test\handlers\generate_caption.test.ts
Remove-Item test\handlers\remove_bg.test.ts
Remove-Item test\services\fcm_service.test.ts
Remove-Item test\services\razorpay_service.test.ts

# If test/handlers/ and test/services/ directories are now empty, remove them too:
Remove-Item test\handlers -Recurse -ErrorAction SilentlyContinue
Remove-Item test\services -Recurse -ErrorAction SilentlyContinue

npm test
# Expected: 7 failed suites → 0 failed. Only src/**/*.test.ts files remain.
```

The REAL tests live in `src/handlers/*.test.ts` — those are passing. The
`test/` directory was created by Copilot as empty placeholder stubs.

---

### Worker Fix B — generate_caption missing-auth test (Paste-Ask — 1 file)

**Attach `workers/src/handlers/generate_caption.test.ts`, paste:**

```
Test failure:
  "returns 401 when Authorization header is missing" → gets 200, expects 401

ROOT CAUSE: This test sends a request with NO Authorization header and
expects the REAL extractAndVerifyToken to reject it. But in the test
environment, the module mock vi.mock('./middleware/auth') replaces
extractAndVerifyToken with a default vi.fn() that returns undefined.
The handler then gets undefined from extractAndVerifyToken and doesn't
reject — it falls through to return 200.

The other test "returns 401 when extractAndVerifyToken returns null"
WORKS because it explicitly calls vi.mocked(extractAndVerifyToken)
.mockResolvedValueOnce(null).

FIX: Make the "missing header" test ALSO mock extractAndVerifyToken
explicitly, the same way the other 401 test does:

  it('returns 401 when Authorization header is missing', async () => {
    vi.mocked(extractAndVerifyToken).mockResolvedValueOnce(
      Response.json({ error: 'Unauthorized' }, { status: 401 }) as any,
    );

    const request = new Request('http://worker/api/generate-caption', {
      method: 'POST',
      body: JSON.stringify({ productName: 'Kurti', category: 'apparel', language: 'hinglish' }),
      // No Authorization header
    });

    const response = await handleGenerateCaption(request, mockEnv as Env);
    const body = await response.json() as { error?: string };

    expect(response.status).toBe(401);
    expect(body.error).toBeTruthy();
  });

IMPORTANT: Keep all other tests in the file unchanged.
Output only generate_caption.test.ts.
```

---

### Flutter Fix — Two Off-Screen Pricing Screen Tests (Paste-Ask — 1 file)

**Attach `test/features/account/presentation/screens/pricing_screen_test.dart`, paste:**

```
Two tests fail because the Vyapaar plan button ("Yeh plan lo — ₹249/mo")
renders off-screen in the 800×600 test surface. The button is inside a
SingleChildScrollView and the Vyapaar card (3rd card) is scrolled below
the visible bounds.

Error: "derived an Offset (400.0, 901.0) that would not hit test.
       Offset is outside the bounds of the root: Size(800.0, 600.0)"

FIX: In both failing tests, add tester.ensureVisible() before tap():

═══ TEST: "tapping buy plan shows loading overlay" ═══

  // BEFORE tap:
  await tester.ensureVisible(find.text('Yeh plan lo — ₹249/mo'));
  await tester.pumpAndSettle();      // settle after scroll
  await tester.tap(find.text('Yeh plan lo — ₹249/mo'));
  await tester.pump();

═══ TEST: "successful payment shows success bottom sheet" ═══

  // BEFORE tap:
  await tester.ensureVisible(find.text('Yeh plan lo — ₹249/mo'));
  await tester.pumpAndSettle();      // settle after scroll
  await tester.tap(find.text('Yeh plan lo — ₹249/mo'));
  await tester.pumpAndSettle();

Apply ensureVisible + pumpAndSettle to BOTH tests, before every tap()
call that targets the Vyapaar plan button.
Keep all other 4 tests unchanged. Output only pricing_screen_test.dart.
```

After all fixes:
```powershell
# Workers
cd workers && npm test
# Expected: 0 failed suites, 0 failed tests (src/**/*.test.ts only)

# Flutter
flutter test test/features/account/presentation/screens/pricing_screen_test.dart
# Expected: 6/6 pass

flutter test
# Expected: all tests pass
```

---

## TASK 3.2 — CREDITGUARD + MY ADS GALLERY SCREEN

### One-Sentence Summary
`CreditGuard` enforces the ad quota before every AI generation attempt
(checks Firestore, decrements, or shows upgrade sheet), while the My Ads
Gallery fills Tab 2 with a paginated grid of all the user's generated ads
with share and download actions.

---

### Paste Into Copilot Chat (Kavya Agent — New Session)

**Attach these files:**

| # | File | Why |
|---|---|---|
| 1 | `copilot-instructions.md` | Global rules |
| 2 | `flutter.instructions.md` | Screen patterns |
| 3 | `SKILL.md` → *design-system* | Colors, spacing |
| 4 | `SKILL.md` → *testing-patterns* | Widget test structure |
| 5 | `SKILL.md` → *payment-credit* | Credit rules, plan quotas |
| 6 | `lib/features/studio/domain/generated_ad.dart` | ACTUAL model |
| 7 | `lib/core/services/firebase_service.dart` | ACTUAL — Firestore access |
| 8 | `lib/core/constants/app_routes.dart` | ACTUAL — add route |
| 9 | `lib/core/router/app_router.dart` | ACTUAL — wire My Ads tab |
| 10 | `lib/features/account/domain/pricing_plans.dart` | ACTUAL — plan definitions |

```
════════════════════════════════════════════════════════
  TASK 3.2 — CreditGuard + My Ads Gallery Screen
  Week 3 · Firestore · Flutter
════════════════════════════════════════════════════════

Firebase note: All reads/writes use Firestore via FirebaseService.
No Supabase anywhere. Credit decrement uses Firestore FieldValue.increment(-1).

═══════════════════════════════════════════════════════
  PART A — CreditGuard Service
═══════════════════════════════════════════════════════

────────────────────────────────────────
  NEW FILE 1 — lib/core/services/credit_guard.dart    (NEW)
────────────────────────────────────────

Class: CreditGuard

  final _mutex = Mutex();   // from package:mutex (add to pubspec if missing)

  /// Call BEFORE every AI generation attempt.
  /// Returns true if the user may proceed, false if blocked.
  Future<bool> canGenerate(BuildContext context) async {
    return _mutex.protect(() async {
      final userId = FirebaseService.currentUserId;
      if (userId == null) return false;

      // Fetch user doc from Firestore
      final doc = await FirebaseService.db.collection('users').doc(userId).get();
      if (!doc.exists) return false;

      final data = doc.data()!;
      final tier = data['tier'] as String? ?? 'free';
      final credits = data['creditsRemaining'] as int? ?? 0;

      // Utsav tier: unlimited
      if (tier == 'utsav') return true;

      // No credits left
      if (credits <= 0) {
        if (context.mounted) _showUpgradeSheet(context);
        return false;
      }

      // Last credit warning
      if (credits == 1) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sirf 1 ad credit bacha hai! Plan upgrade karo.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }

      // Decrement atomically in Firestore
      await FirebaseService.db.collection('users').doc(userId).update({
        'creditsRemaining': FieldValue.increment(-1),
      });

      return true;
    });
  }

  void _showUpgradeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: Color(0xFFFF6F00)),
              const SizedBox(height: 16),
              const Text(
                'Aapke credits khatam ho gaye! 😔',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Aur ads banane ke liye plan upgrade karo ya Ad Pack kharido.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6F00),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    context.push(AppRoutes.pricing);
                  },
                  child: const Text(
                    '₹29 mein 10 ads kharido',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF6F00)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    context.push(AppRoutes.pricing);
                  },
                  child: const Text(
                    'Monthly plan lo',
                    style: TextStyle(color: Color(0xFFFF6F00), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Riverpod provider ─────────────────────────────────────────────
  @riverpod
  CreditGuard creditGuard(CreditGuardRef ref) => CreditGuard();

────────────────────────────────────────
  Wire CreditGuard into ad generation
────────────────────────────────────────

Attach: lib/features/studio/presentation/screens/camera_capture_screen.dart
        (or wherever captureAndProcessImage is called)

Find the method that calls backgroundRemovalService.process() (Task 1.4).
Add CreditGuard check at the TOP, before any API call:

  // At the top of captureAndProcessImage (or equivalent method):
  final canProceed = await ref.read(creditGuardProvider).canGenerate(context);
  if (!canProceed) return;   // user has no credits — upgrade sheet shown
  // ... rest of image processing logic unchanged

Output: only the modified camera_capture_screen.dart (or equivalent).
No other files changed for this wiring step.

═══════════════════════════════════════════════════════
  PART B — My Ads Gallery Screen
═══════════════════════════════════════════════════════

────────────────────────────────────────
  NEW FILE 2 — lib/features/myads/application/my_ads_notifier.dart    (NEW)
────────────────────────────────────────

  @riverpod
  class MyAdsNotifier extends _$MyAdsNotifier {

    static const int _pageSize = 10;
    DocumentSnapshot? _lastDocument;    // Firestore cursor for pagination
    bool _hasMore = true;

    @override
    Future<List<GeneratedAd>> build() async {
      _lastDocument = null;
      _hasMore = true;
      return _fetchPage(isFirstPage: true);
    }

    Future<List<GeneratedAd>> _fetchPage({ required bool isFirstPage }) async {
      final userId = FirebaseService.currentUserId;
      if (userId == null) return [];

      Query<Map<String, dynamic>> query = FirebaseService.db
          .collection('generatedAds')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      if (!isFirstPage && _lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty || snapshot.docs.length < _pageSize) {
        _hasMore = false;
      }
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }

      return snapshot.docs
          .map((doc) => GeneratedAd.fromFirestore(doc))
          .toList();
    }

    Future<void> loadMore() async {
      if (!_hasMore) return;
      final current = state.valueOrNull ?? [];
      final nextPage = await _fetchPage(isFirstPage: false);
      state = AsyncData([...current, ...nextPage]);
    }

    Future<void> refresh() async {
      state = const AsyncLoading();
      _lastDocument = null;
      _hasMore = true;
      state = await AsyncValue.guard(() => _fetchPage(isFirstPage: true));
    }

    // Delete an ad from Firestore and remove from local state
    Future<void> deleteAd(String adId) async {
      await FirebaseService.db.collection('generatedAds').doc(adId).delete();
      state = AsyncData(
        (state.valueOrNull ?? []).where((ad) => ad.id != adId).toList(),
      );
    }
  }

  // hasMoreProvider — exposes _hasMore for the Load More button
  @riverpod
  bool myAdsHasMore(MyAdsHasMoreRef ref) {
    // Read hasMore from MyAdsNotifier state metadata
    // Since _hasMore is private, expose via a separate notifier field or
    // use a simple StateProvider updated by loadMore
    // Implementation: use StateProvider<bool> updated in loadMore()
    return true;  // Copilot: implement using a StateProvider<bool> pattern
  }

────────────────────────────────────────
  NEW FILE 3 — lib/features/myads/presentation/screens/my_ads_screen.dart    (NEW)
────────────────────────────────────────

WIDGET TYPE: ConsumerWidget
ROUTE: This screen IS Tab 2 in the bottom nav (already stubbed as grid icon)
  — it is the shell body, NOT a pushed route.

LAYOUT (Scaffold with AppBar):

  ── AppBar ──────────────────────────────────────────────────────────
  title: "Mere Ads" (18sp bold)
  backgroundColor: Colors.white, elevation 0
  actions: [
    IconButton(icon: Icons.refresh_outlined, onPressed: ref.refresh)
  ]

  ── Body: state-aware ───────────────────────────────────────────────

  final adsState = ref.watch(myAdsNotifierProvider);

  adsState.when(
    loading: () => _ShimmerGrid(),         // see below
    error: (err, _) => _ErrorState(onRetry: () => ref.refresh(myAdsNotifierProvider)),
    data: (ads) {
      if (ads.isEmpty) return _EmptyState();
      return RefreshIndicator(
        onRefresh: () => ref.read(myAdsNotifierProvider.notifier).refresh(),
        color: AppColors.primary,
        child: _AdGrid(ads: ads),
      );
    },
  )

  ── _EmptyState widget ──────────────────────────────────────────────
  Center:
    Column:
      Icon(Icons.photo_library_outlined, 64dp, grey)
      SizedBox(height: 16)
      Text("Abhi koi ad nahi!", 18sp medium, grey)
      SizedBox(height: 8)
      Text("Studio mein jao aur pehla ad banao.", 14sp, light grey)
      SizedBox(height: 24)
      ElevatedButton.icon(
        icon: Icon(Icons.camera_alt_outlined),
        label: Text("Ad banao"),
        onPressed: () => context.go(AppRoutes.studio),  // go to Studio tab
      )

  ── _ErrorState widget ──────────────────────────────────────────────
  Center:
    Column:
      Icon(Icons.error_outline, 48dp, Colors.red[300])
      SizedBox(height: 12)
      Text("Ads load nahi hue. Dobara try karein.", 14sp grey)
      SizedBox(height: 16)
      ElevatedButton(onPressed: onRetry, child: Text("Dobara try karein"))

  ── _AdGrid widget ────────────────────────────────────────────────
  Column:
    GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),  // RefreshIndicator handles scroll
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,  // portrait cards
      ),
      itemCount: ads.length,
      itemBuilder: (_, i) => _AdCard(ad: ads[i]),
    )
    SizedBox(height: 12)
    if hasMore:
      Center:
        OutlinedButton(
          onPressed: () => ref.read(myAdsNotifierProvider.notifier).loadMore(),
          child: Text("Aur ads load karo"),
        )
    SizedBox(height: 32)

  ── _AdCard widget (private, must be wrapped in RepaintBoundary) ────
  RepaintBoundary:
    InkWell(
      onTap: () => context.push(AppRoutes.adPreview, extra: ad),
      onLongPress: () => _showCardActions(context, ad),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: ad.imageUrl ?? '',
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                memCacheWidth: 240,        // performance: downscale in memory
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(height: 140, color: Colors.white),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 140,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                ),
              ),
            ),
            // Card body
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ad.captionHindi ?? ad.captionEnglish ?? 'Ad',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        _formatDate(ad.createdAt),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const Spacer(),
                      // Share button
                      InkWell(
                        onTap: () => context.push(AppRoutes.whatsappBroadcast, extra: ad),
                        child: const Icon(Icons.share_outlined,
                          size: 18, color: Color(0xFFFF6F00)),
                      ),
                      const SizedBox(width: 8),
                      // Download button
                      InkWell(
                        onTap: () => _downloadAd(context, ad),
                        child: const Icon(Icons.download_outlined,
                          size: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )

  // Long press → action sheet
  void _showCardActions(BuildContext context, GeneratedAd ad) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('WhatsApp par bhejo'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.whatsappBroadcast, extra: ad);
            },
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Gallery mein save karo'),
            onTap: () { Navigator.pop(context); _downloadAd(context, ad); },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Delete karo', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(context, ad);
            },
          ),
        ]),
      ),
    );
  }

  // Download to gallery using image_gallery_saver
  Future<void> _downloadAd(BuildContext context, GeneratedAd ad) async {
    if (ad.imageUrl == null) return;
    try {
      final response = await http.get(Uri.parse(ad.imageUrl!));
      await ImageGallerySaver.saveImage(response.bodyBytes,
        quality: 90, name: 'dukaan_ai_${ad.id}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ad gallery mein save ho gaya! 📸')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Save nahi hua. Dobara try karein.')),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, GeneratedAd ad) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ad delete karein?'),
        content: const Text('Yeh ad hamesha ke liye delete ho jayega.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Ruko')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(myAdsNotifierProvider.notifier).deleteAd(ad.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete karo'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d pehle';
    if (diff.inHours > 0) return '${diff.inHours}h pehle';
    return 'Abhi';
  }

  ── _ShimmerGrid (loading state) ────────────────────────────────────
  GridView of 6 shimmer placeholder cards (same size as _AdCard).
  Use Shimmer.fromColors with grey base/highlight colors.
  Each card: grey rounded container 140dp + grey lines below.

────────────────────────────────────────
  CHANGE — My Ads tab wiring in app_router.dart
────────────────────────────────────────

  The My Ads tab (Tab 2, grid icon) is currently a stub. Replace its
  body with MyAdsScreen:

  In the StatefulShellBranch for My Ads:
    routes: [
      GoRoute(
        path: AppRoutes.myAds,     // '/my-ads'
        name: 'my-ads',
        builder: (context, state) => const MyAdsScreen(),
      ),
    ],

  ADD to app_routes.dart:
    static const myAds = '/my-ads';     // if not already present

────────────────────────────────────────
  CHANGE — app_strings.dart    (add My Ads strings)
────────────────────────────────────────

  ADD:
  // My Ads Screen
  static const myAdsTitle           = 'Mere Ads';
  static const myAdsEmpty           = 'Abhi koi ad nahi!';
  static const myAdsEmptySubtitle   = 'Studio mein jao aur pehla ad banao.';
  static const myAdsMakeFirst       = 'Ad banao';
  static const myAdsLoadMore        = 'Aur ads load karo';
  static const myAdsShareAction     = 'WhatsApp par bhejo';
  static const myAdsSaveAction      = 'Gallery mein save karo';
  static const myAdsDeleteAction    = 'Delete karo';
  static const myAdsSaved           = 'Ad gallery mein save ho gaya! 📸';
  static const myAdsSaveFailed      = 'Save nahi hua. Dobara try karein.';
  static const myAdsDeleteTitle     = 'Ad delete karein?';
  static const myAdsDeleteConfirm   = 'Yeh ad hamesha ke liye delete ho jayega.';

  // CreditGuard
  static const creditsExhausted     = 'Aapke credits khatam ho gaye! 😔';
  static const creditsExhaustedBody = 'Aur ads banane ke liye plan upgrade karo ya Ad Pack kharido.';
  static const creditsBuyPack       = '₹29 mein 10 ads kharido';
  static const creditsGetPlan       = 'Monthly plan lo';
  static const creditsLastOne       = 'Sirf 1 ad credit bacha hai! Plan upgrade karo.';

────────────────────────────────────────
  NEW FILE 4 — pubspec.yaml (ADD if missing)
────────────────────────────────────────

  Check pubspec.yaml. These should already be present:
    shimmer: ^3.0.0
    image_gallery_saver: ^2.0.3
    cached_network_image: ^3.3.1
    http: (already present)

  ADD only if missing:
    mutex: ^5.1.1       # for CreditGuard thread-safety

────────────────────────────────────────
  NEW FILE 5 — Tests
  test/features/myads/presentation/screens/my_ads_screen_test.dart    (NEW)
  test/core/services/credit_guard_test.dart                            (NEW)
────────────────────────────────────────

MY ADS SCREEN TESTS (5 tests):

  TEST 1: shows shimmer loading state initially
    - Pump MyAdsScreen with myAdsNotifierProvider in loading state
    - Verify Shimmer widget appears in the tree

  TEST 2: shows empty state when ads list is empty
    - Pump MyAdsScreen with myAdsNotifierProvider returning []
    - Verify find.text(AppStrings.myAdsEmpty) findsOneWidget
    - Verify find.text(AppStrings.myAdsMakeFirst) findsOneWidget

  TEST 3: shows ad cards when data is present
    - Pump MyAdsScreen with provider returning [testAd1, testAd2]
    - Verify 2 _AdCard widgets (or their CachedNetworkImage) appear

  TEST 4: shows error state on error
    - Pump MyAdsScreen with provider in error state
    - Verify find.text('Ads load nahi hue. Dobara try karein.') findsOneWidget
    - Verify find.text(AppStrings.dobara) findsOneWidget (retry button)

  TEST 5: long press on card shows action sheet
    - Pump MyAdsScreen with 1 ad in list
    - Long press the ad card
    - pumpAndSettle()
    - Verify find.text(AppStrings.myAdsShareAction) findsOneWidget
    - Verify find.text(AppStrings.myAdsDeleteAction) findsOneWidget

CREDIT GUARD TESTS (4 tests — unit, not widget):

  TEST 1: returns true when tier is utsav (unlimited)
    - Mock Firestore doc with tier: 'utsav', creditsRemaining: 0
    - creditGuard.canGenerate(mockContext) → expect true
    - Verify Firestore.update NOT called

  TEST 2: returns false and shows upgrade sheet when credits == 0
    - Mock Firestore doc with tier: 'free', creditsRemaining: 0
    - Mock BuildContext with mounted: true
    - creditGuard.canGenerate(mockContext) → expect false

  TEST 3: returns true and decrements when credits > 1
    - Mock Firestore doc with tier: 'free', creditsRemaining: 5
    - creditGuard.canGenerate(mockContext) → expect true
    - Verify Firestore.update called with FieldValue.increment(-1)

  TEST 4: mutex prevents double-decrement on rapid concurrent calls
    - Mock Firestore doc with creditsRemaining: 1
    - Call canGenerate() TWICE concurrently (Future.wait)
    - Expect only 1 update call (second call blocked by mutex)
    - Expect one returns true, one returns false

────────────────────────────────────────
  OUTPUT ORDER (8 files)
────────────────────────────────────────

NEW (5 files):
  1. lib/core/services/credit_guard.dart
  2. lib/features/myads/application/my_ads_notifier.dart
  3. lib/features/myads/presentation/screens/my_ads_screen.dart
  4. test/features/myads/presentation/screens/my_ads_screen_test.dart
  5. test/core/services/credit_guard_test.dart

MODIFIED (4 files):
  6. lib/core/router/app_router.dart      (wire My Ads tab → MyAdsScreen)
  7. lib/core/constants/app_routes.dart   (add myAds constant if missing)
  8. lib/core/constants/app_strings.dart  (add strings)
  9. pubspec.yaml                         (add mutex if missing)

CreditGuard wiring (1 file, separate paste after main session):
  10. lib/features/studio/presentation/screens/camera_capture_screen.dart

────────────────────────────────────────
  DO NOT
────────────────────────────────────────

✗ DO NOT load all ads at once — use _pageSize = 10 with Firestore cursors
✗ DO NOT use Navigator.push for the My Ads tab — it IS a ShellBranch tab
✗ DO NOT call creditGuard AFTER starting API call — check BEFORE any network call
✗ DO NOT use mutex.acquire() + release() — use mutex.protect() for safety
✗ DO NOT delete from Firestore from client if user is not the owner —
  rely on security rules: allow delete: if request.auth.uid == resource.data.userId
✗ DO NOT use ImageGallerySaver for CachedNetworkImage cached files —
  always re-download via http.get for gallery save
✗ DO NOT create a new Riverpod provider file for CreditGuard — put it at
  the bottom of credit_guard.dart
```

---

## VALIDATION CHECKLIST

```powershell
# Workers
cd workers
npm test
# Expected: 0 failed (empty test/ files deleted, auth mock fixed)

# Flutter
flutter pub get       # picks up mutex package
flutter analyze       # Expected: No issues found!

flutter test test/features/myads/presentation/screens/my_ads_screen_test.dart
flutter test test/core/services/credit_guard_test.dart
flutter test test/features/account/presentation/screens/pricing_screen_test.dart
# Expected: all pass

flutter test          # Expected: all tests pass

# Emulator (AFTER fixing google-services.json package name)
flutter run -d emulator-5554 --dart-define=SKIP_AUTH=true
# Test flow:
#   1. My Ads tab (Tab 2) → "Abhi koi ad nahi!" empty state ✅
#   2. Generate an ad via Studio → returns to studio ✅
#   3. My Ads tab → ad appears in grid ✅
#   4. Account tab → "Plan upgrade karo" → PricingScreen ✅
#   5. Credits exhausted → upgrade bottom sheet appears ✅
```

---

## WHAT COMES NEXT — TASK 4.1

> **Task 4.1 — Onboarding Flow (OTP Login + Shop Setup)**
> 3-screen onboarding: Welcome (Lottie), Business Setup (shop name/category/city),
> Phone OTP Login (Firebase Auth Phone sign-in — replaces Supabase phone OTP).
> `OnboardingController` Riverpod notifier manages form state across all 3 screens.
> GoRouter redirect logic: unauthenticated → `/onboarding`, authenticated without
> shop profile → `/onboarding/setup`, authenticated with profile → `/studio`.
> Firebase Phone Auth replaces Supabase phone OTP from the playbook prompt 4.3.
> Write `users/{uid}` Firestore doc on first setup with shopName, category, city,
> whatsappNumber, tier: 'free', creditsRemaining: 5.

---

*Dukaan AI v1.0 Build Playbook · Task 3.2 (CreditGuard + My Ads) · April 2026*
