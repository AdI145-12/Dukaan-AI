# TASK 2.3 — WhatsApp Broadcast Manager Screen
### Dukaan AI · Single-Agent Session: Kavya (Flutter UI)

---

## TASK 2.2 ASSESSMENT — Four Fixes Before Task 2.3

### Screenshots: Both Screens Show Error State 🔴

**Root cause confirmed:** `FirebaseService.currentUserId` returns `null` in
SKIP_AUTH mode. SKIP_AUTH bypasses the GoRouter auth redirect, but
`FirebaseAuth.instance.currentUser` is still `null` — no user is signed in.
Firestore Security Rules deny every read (`request.auth == null`), throwing
`PERMISSION_DENIED` → repositories catch as `FirebaseException` → providers
return error state → both screens show "Dobara try karein".

**Second crash:** Two FABs share `<default FloatingActionButton tag>`. The
`StatefulShellRoute` keeps all branches alive simultaneously. When the user
navigates between Studio and Khata tabs, Flutter finds two FABs with the same
default Hero tag in the tree and throws.

---

### Fix A — SKIP_AUTH + Firebase Null User (Paste-Ask — 1 file)

**Attach `lib/main.dart`, then paste:**

```
Problem: When running with --dart-define=SKIP_AUTH=true, both Studio and Khata
screens show "Dobara try karein" error state.

ROOT CAUSE: SKIP_AUTH bypasses GoRouter redirect but Firebase Auth still has
no signed-in user (currentUser == null). Firestore Security Rules deny all reads
with: PERMISSION_DENIED (Missing or insufficient permissions).

FIX — in main.dart, immediately after Firebase.initializeApp():

  // DEV ONLY: sign in anonymously so Firestore queries work in SKIP_AUTH mode
  if (const bool.fromEnvironment('SKIP_AUTH') &&
      FirebaseAuth.instance.currentUser == null) {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      debugPrint('[DEV] SKIP_AUTH anonymous sign-in → '
          '${FirebaseAuth.instance.currentUser?.uid}');
    } catch (e) {
      debugPrint('[DEV] SKIP_AUTH anonymous sign-in failed: $e');
    }
  }

PREREQUISITE: Enable Anonymous Authentication in Firebase Console:
  Firebase Console → Authentication → Sign-in method → Anonymous → Enable

This block is compile-time gated on SKIP_AUTH — it is never included in
production builds. Output only main.dart.
```

**Then in Firebase Console:** Authentication → Sign-in method → Anonymous → Enable ✅

---

### Fix B — FAB Hero Tag Collision (Paste-Ask — 2 files)

**Attach `lib/core/shell/app_shell_scaffold.dart` AND
`lib/features/khata/presentation/screens/khata_screen.dart`, then paste:**

```
Runtime error: "There are multiple heroes that share the same tag:
<default FloatingActionButton tag>"

ROOT CAUSE: StatefulShellRoute keeps all tab branches alive simultaneously.
The Studio shell FAB and the Khata screen FAB both use the default Hero tag.
When navigating between tabs Flutter's Hero system finds two conflicting tags.

FIX: Add a unique heroTag to every FloatingActionButton in the tree.

In app_shell_scaffold.dart — the camera FAB (shown on Studio tab):
  FloatingActionButton(
    heroTag: 'studio_camera_fab',   ← ADD THIS
    ...
  )

In khata_screen.dart — the add (+) FAB:
  FloatingActionButton(
    heroTag: 'khata_add_fab',       ← ADD THIS
    ...
  )

If any other screen or widget in the project has a FloatingActionButton
without a heroTag, also add a unique string heroTag to each one now.
Output only the two modified files.
```

---

### Fix C — Analyze Warning (Paste-Ask — 1 file)

**Attach `lib/features/studio/infrastructure/studio_repository_impl.dart`, then paste:**

```
flutter analyze shows:
  no_leading_underscores_for_local_identifiers
  studio_repository_impl.dart:10:39 — '_legacyClient'

FIX: Rename the local variable _legacyClient → legacyClient (remove
the leading underscore). Local variables must not start with underscore
per Dart lint rules. Output only studio_repository_impl.dart.
```

After these 3 fixes:
```powershell
flutter analyze        # Expected: No issues found!
flutter run -d emulator-5554 --dart-define=SKIP_AUTH=true
# Expected: Khata empty state + Studio quick-create cards (no error screens)
```

---

### Fix D — Two Persistent ad_preview_screen Tests (Paste-Ask — 1 file)

These tests have failed across 3 task cycles. This paste-ask is the definitive
surgical fix.

**Attach `test/features/studio/presentation/screens/ad_preview_screen_test.dart`,
then paste:**

```
Two widget tests have failed across 3 task iterations. Here is the exact
root cause and fix for each:

════════════════════════════════
TEST 1 — "shows regenerating overlay when isRegenerating is true"
Expected: finds "Naya ad ban raha hai..."  Actual: found 0 widgets
════════════════════════════════

ROOT CAUSE: The shared setUp() mock for captionService.generateCaption()
uses thenAnswer((_) async => ...) which resolves in a microtask BEFORE
the widget's setState(_isRegenerating = true) rebuild is pumped.
The overlay appears and disappears before the expectation runs.

FIX: This test MUST override captionService with a Completer that never
completes. Replace the entire test body:

  testWidgets('shows regenerating overlay when isRegenerating is true',
      (tester) async {
    // Completer that never completes → _isRegenerating stays true forever
    final captionCompleter = Completer<GeneratedCaption>();
    final mockCaption = MockCaptionService();
    when(() => mockCaption.generateCaption(
          imageBase64: any(named: 'imageBase64'),
          productName: any(named: 'productName'),
          category: any(named: 'category'),
          language: any(named: 'language'),
        )).thenAnswer((_) => captionCompleter.future);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...baseOverrides,                      // your shared non-caption overrides
          captionServiceProvider.overrideWith((_) => mockCaption),
        ],
        child: MaterialApp(
          home: AdPreviewScreen(ad: testAd),
        ),
      ),
    );

    await tester.pump();        // triggers _generateCaptionInBackground
    await tester.pump();        // processes setState(_isRegenerating = true)

    expect(find.text(AppStrings.captionRegenerating), findsOneWidget);
    // DO NOT complete captionCompleter — test ends with overlay visible
  });

════════════════════════════════
TEST 2 — "copyCaption shows snackbar when captionHindi is null"
Expected: finds SnackBar "Caption jaldi available hoga. (Task 1.9)"
Actual: found 0 widgets
════════════════════════════════

ROOT CAUSE: The shared setUp() captionService mock completes immediately,
writing a non-null captionHindi into the state before the test taps copy.
The "not available" path never executes.

FIX: Use a Completer that never completes so captionHindi stays null.
Replace the entire test body:

  testWidgets('copyCaption shows snackbar when captionHindi is null',
      (tester) async {
    // Keep captionHindi null by never completing caption generation
    final captionCompleter = Completer<GeneratedCaption>();
    final mockCaption = MockCaptionService();
    when(() => mockCaption.generateCaption(
          imageBase64: any(named: 'imageBase64'),
          productName: any(named: 'productName'),
          category: any(named: 'category'),
          language: any(named: 'language'),
        )).thenAnswer((_) => captionCompleter.future);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...baseOverrides,
          captionServiceProvider.overrideWith((_) => mockCaption),
        ],
        child: MaterialApp(
          home: AdPreviewScreen(
            ad: testAd.copyWith(captionHindi: null),   // explicitly null
          ),
        ),
      ),
    );

    await tester.pump();   // triggers background generation (stays pending)
    await tester.pump();   // settles widget tree

    // Tap the copy button while captionHindi is still null
    await tester.tap(find.byKey(const Key('copy_caption_button')));
    await tester.pump();   // shows SnackBar

    expect(
      find.text('Caption jaldi available hoga. (Task 1.9)'),
      findsOneWidget,
    );
  });

════════════════════════════════
IMPORTANT: Do not change any other tests. Do not change setUp().
The Completer pattern must be self-contained within each test body.
Output only ad_preview_screen_test.dart.
```

After all 4 fixes:
```powershell
flutter test    # Expected: 77/77 pass (or 79/79 with 2 newly fixed tests)
```

---

## TASK 2.3 — WHATSAPP BROADCAST MANAGER SCREEN

### One-Sentence Summary
A sharing hub screen where sellers choose how to send their generated ad
(caption + image) to customers via WhatsApp — broadcast, status, group, or
single contact — with inline caption editing and language switching.

---

### Paste Into Copilot Chat (Kavya Agent — New Session)

**Attach these files:**

| # | File | Why |
|---|---|---|
| 1 | `copilot-instructions.md` | Global rules |
| 2 | `flutter.instructions.md` | Screen patterns |
| 3 | `SKILL.md` → *design-system* | Colors, spacing, widget patterns |
| 4 | `SKILL.md` → *testing-patterns* | Widget test structure |
| 5 | `lib/features/studio/domain/generated_ad.dart` | ACTUAL model (ad data) |
| 6 | `lib/features/studio/presentation/widgets/caption_language_selector.dart` | ACTUAL widget (reuse) |
| 7 | `lib/core/constants/app_strings.dart` | ACTUAL — add new strings |
| 8 | `lib/core/constants/app_routes.dart` | ACTUAL — add route constant |
| 9 | `lib/core/router/app_router.dart` | ACTUAL — add route |

```
════════════════════════════════════════════════════════
  TASK 2.3 — WhatsApp Broadcast Manager Screen
════════════════════════════════════════════════════════

CONTEXT:
After an ad is generated (AdPreviewScreen), the seller taps "WhatsApp par
bhejo". This navigates to WhatsAppBroadcastScreen with the current
GeneratedAd passed as a GoRouter extra. The screen helps them send the
ad image + caption to their customer list via WhatsApp in 4 ways.

Firebase note: Ad data comes from the GeneratedAd object passed via navigation
extra (already loaded in AdPreviewScreen). No new Firestore queries in this screen.

────────────────────────────────────────
  NEW FILE 1 — lib/features/studio/presentation/screens/whatsapp_broadcast_screen.dart
────────────────────────────────────────

WIDGET TYPE: ConsumerStatefulWidget
ROUTE PATH: /studio/broadcast (navigated from AdPreviewScreen with extra: GeneratedAd)

STATE:
  String _editedCaption     // initialized from ad.captionHindi (default)
  String _selectedLanguage  // 'hinglish' | 'hindi' | 'english', default 'hinglish'
  bool _captionEdited       // true when user manually changes caption text

LAYOUT (SingleChildScrollView, no AppBar — uses back navigation):

  ── AppBar ──────────────────────────────────────────────────────────
  Title: "WhatsApp par bhejo" (18sp bold)
  Leading: back arrow (confirm dialog if _captionEdited == true)

  ── Section 1: Ad Preview ───────────────────────────────────────────
  Row:
    Left: ad thumbnail
      ClipRRect(borderRadius: 8), CachedNetworkImage(ad.imageUrl)
      Size: 96×96dp, fit: BoxFit.cover
      errorWidget: grey container + icon_broken_image
    Right: caption text preview
      Expanded, max 4 lines, overflow ellipsis
      Text: _editedCaption, 14sp, color: AppColors.textPrimary

  ── Section 2: Caption Customize ────────────────────────────────────
  Label: "Caption customize karo" (12sp, grey, all-caps letter-spacing 0.5)
  Spacing: 8dp

  CaptionLanguageSelector(
    selectedLanguage: _selectedLanguage,
    onChanged: (lang) {
      setState(() {
        _selectedLanguage = lang;
        // switch caption based on language without overriding manual edits
        if (!_captionEdited) {
          _editedCaption = _captionForLanguage(lang);
        }
      });
    },
  )
  // _captionForLanguage helper:
  //   'hindi'   → ad.captionHindi ?? ad.captionEnglish ?? ''
  //   'english' → ad.captionEnglish ?? ad.captionHindi ?? ''
  //   'hinglish'→ ad.captionHindi ?? ad.captionEnglish ?? ''
  //   (Hinglish uses Hindi caption as the default mixed-language field)

  Spacing: 12dp

  TextField for caption editing:
    controller: TextEditingController(text: _editedCaption)
    maxLines: 4, minLines: 2
    decoration: outlined border, border-radius 8dp,
      hintText: "Caption edit karo...",
      suffixIcon: if _captionEdited: IconButton(
        icon: Icon(Icons.refresh),
        tooltip: 'Original caption wapas lao',
        onPressed: () => setState(() {
          _captionEdited = false;
          _editedCaption = _captionForLanguage(_selectedLanguage);
        }),
      )
    onChanged: (val) => setState(() {
      _editedCaption = val;
      _captionEdited = true;
    })

  Spacing: 8dp

  Row: [Copy Caption button]
    TextButton.icon(
      icon: Icon(Icons.copy, size: 16),
      label: Text("Caption copy karein"),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: _editedCaption));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.captionCopied))  // "Caption copy ho gaya!"
        );
      }
    )

  ── Divider ─────────────────────────────────────────────────────────

  ── Section 3: Share Destinations ───────────────────────────────────
  Label: "Kahan share karein?" (14sp medium, AppColors.textPrimary)
  Spacing: 12dp

  Column of 4 _ShareDestinationCard widgets (see below):

    Card 1: Broadcast List
      icon: Icons.campaign_outlined (green)
      title: "Broadcast List"
      subtitle: "Apni saved broadcast list pe bhejein"
      onTap: _shareToWhatsApp(WhatsAppTarget.broadcast)

    Card 2: WhatsApp Status
      icon: Icons.circle_outlined (green)
      title: "WhatsApp Status"
      subtitle: "24 ghante ke liye status pe lagaein"
      onTap: _shareToWhatsApp(WhatsAppTarget.status)

    Card 3: Group
      icon: Icons.group_outlined (green)
      title: "Group"
      subtitle: "Apne seller/buyer group mein bhejein"
      onTap: _shareToWhatsApp(WhatsAppTarget.group)

    Card 4: Single Contact
      icon: Icons.person_outlined (green)
      title: "Ek Contact ko"
      subtitle: "Ek customer ko directly bhejein"
      onTap: _shareToWhatsApp(WhatsAppTarget.single)

  Spacing: 16dp

  ── Footer: Instagram Share ──────────────────────────────────────────
  OutlinedButton.icon full width:
    icon: (Instagram icon — use Icons.share as fallback)
    label: Text("Instagram par bhi share karein")
    style: orange outlined border, orange text
    onPressed: _shareToInstagram()

  Bottom padding: 32dp (for system nav)

────────────────────────────────────────
  _ShareDestinationCard private widget
────────────────────────────────────────

  Card properties:
  - elevation: 0
  - shape: RoundedRectangleBorder(borderRadius: 12, side: BorderSide(color: AppColors.borderLight))
  - margin: vertical 4dp
  - InkWell onTap
  - Padding: 16dp
  - Row: [icon 24dp in 40×40 rounded container (light green bg)] [16dp gap]
         [Expanded Column: title 14sp medium, subtitle 12sp grey)]
         [Icon(Icons.chevron_right, color: grey)]

────────────────────────────────────────
  WhatsApp sharing logic (_shareToWhatsApp)
────────────────────────────────────────

  enum WhatsAppTarget { broadcast, status, group, single }

  Future<void> _shareToWhatsApp(WhatsAppTarget target) async {
    // 1. Download image to temp file (or use cached file if available)
    //    Use http.get(Uri.parse(ad.imageUrl)) → write to system temp dir
    //    filename: 'dukaan_ai_ad_${ad.id}.jpg'

    // 2. Caption text = _editedCaption + '

#DukaanAI'

    // 3. Share using share_plus:
    //    await Share.shareXFiles(
    //      [XFile(tempImagePath)],
    //      text: captionText,
    //      sharePositionOrigin: ...,   // for iPad compatibility (can be Rect.zero on Android)
    //    );
    //    Note: share_plus opens the system share sheet; WhatsApp appears in it.
    //    Deep-linking directly to WhatsApp contact/broadcast requires
    //    WhatsApp Business API (Phase 2). For MVP, system share sheet is correct.

    // 4. After share sheet is dismissed (await returns), show SnackBar:
    //    "Ad share ho gaya! Customers tak pahunch jayega."
  }

  Future<void> _shareToInstagram() async {
    // Same as _shareToWhatsApp but without pre-filling text
    // (Instagram doesn't accept pre-filled caption from share sheet)
    await Share.shareXFiles(
      [XFile(tempImagePath)],
    );
  }

  // Image download helper — run in isolate via compute():
  static Future<String> _downloadImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/dukaan_ai_share.jpg');
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

────────────────────────────────────────
  Back navigation with confirmation dialog
────────────────────────────────────────

  Wrap the Scaffold in a PopScope (Flutter 3.22+):
    PopScope(
      canPop: !_captionEdited,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Caption edited'),
            content: const Text('Aapne caption edit kiya hai. Wapas jaayein?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false),
                child: const Text('Ruko')),
              TextButton(onPressed: () => Navigator.pop(context, true),
                child: const Text('Haan, wapas jao')),
            ],
          ),
        );
        if (confirm == true && context.mounted) {
          context.pop();
        }
      },
    )

────────────────────────────────────────
  NEW FILE 2 — lib/core/constants/app_strings.dart    (MODIFIED — add strings)
────────────────────────────────────────

ADD these string constants (do not change existing ones):

  // WhatsApp Broadcast Screen
  static const whatsappBroadcastTitle  = 'WhatsApp par bhejo';
  static const captionCustomize        = 'Caption customize karo';
  static const captionEditHint         = 'Caption edit karo...';
  static const captionCopyBtn          = 'Caption copy karein';
  static const captionCopied           = 'Caption copy ho gaya!';
  static const whereToShare            = 'Kahan share karein?';
  static const shareInstagram          = 'Instagram par bhi share karein';
  static const broadcastListTitle      = 'Broadcast List';
  static const broadcastListSubtitle   = 'Apni saved broadcast list pe bhejein';
  static const whatsappStatusTitle     = 'WhatsApp Status';
  static const whatsappStatusSubtitle  = '24 ghante ke liye status pe lagaein';
  static const groupShareTitle         = 'Group';
  static const groupShareSubtitle      = 'Apne seller/buyer group mein bhejein';
  static const singleContactTitle      = 'Ek Contact ko';
  static const singleContactSubtitle   = 'Ek customer ko directly bhejein';
  static const adSharedSuccess         = 'Ad share ho gaya! Customers tak pahunch jayega.';
  static const captionBackConfirmTitle = 'Caption edited';
  static const captionBackConfirmBody  = 'Aapne caption edit kiya hai. Wapas jaayein?';
  static const captionRestoreTooltip   = 'Original caption wapas lao';
  static const shareDownloading        = 'Image taiyaar ho rahi hai...';

────────────────────────────────────────
  NEW FILE 3 — lib/core/constants/app_routes.dart    (MODIFIED — add constant)
────────────────────────────────────────

ADD: static const whatsappBroadcast = '/studio/broadcast';

────────────────────────────────────────
  NEW FILE 4 — lib/core/router/app_router.dart    (MODIFIED — add route)
────────────────────────────────────────

In the Studio branch routes, add WhatsAppBroadcastScreen as a child route
of the Studio branch (NOT a shell branch — it's a full-screen route):

  GoRoute(
    path: AppRoutes.whatsappBroadcast,
    name: 'whatsapp-broadcast',
    builder: (context, state) {
      final ad = state.extra as GeneratedAd;
      return WhatsAppBroadcastScreen(ad: ad);
    },
  ),

In AdPreviewScreen, the "WhatsApp par bhejo" button navigates:
  context.push(AppRoutes.whatsappBroadcast, extra: currentAd);

────────────────────────────────────────
  NEW FILE 5 — Required packages (pubspec.yaml — ADD if not present)
────────────────────────────────────────

Check pubspec.yaml. These should already be present from Task 1.x:
  share_plus: already in pubspec ✅
  cached_network_image: already in pubspec ✅
  http: already in pubspec (used by cloudflare_client.dart) ✅
  path_provider: ADD if not present
    path_provider: ^2.1.0

────────────────────────────────────────
  NEW FILE 6 — Widget Tests
  test/features/studio/presentation/screens/whatsapp_broadcast_screen_test.dart
────────────────────────────────────────

Write 6 widget tests covering:

TEST 1: renders ad thumbnail and caption preview
  - Pump WhatsAppBroadcastScreen with a testAd (captionHindi: 'Test caption')
  - Verify CachedNetworkImage with ad.imageUrl appears
  - Verify 'Test caption' text appears in the caption preview section

TEST 2: CaptionLanguageSelector switches caption text
  - Pump screen with testAd (captionHindi: 'Hindi caption', captionEnglish: 'English caption')
  - Initial state: caption shows Hindi caption (default Hinglish → captionHindi)
  - Tap 'English' segment in CaptionLanguageSelector
  - pump() → verify caption field shows 'English caption'

TEST 3: Manual caption edit sets _captionEdited = true, shows restore button
  - Pump screen
  - Find the TextField, enterText('Custom caption by user')
  - pump() → verify restore icon button (Icons.refresh) appears in TextField suffix

TEST 4: Copy button shows SnackBar
  - Pump screen
  - Tap "Caption copy karein" button
  - pumpAndSettle() → verify SnackBar with "Caption copy ho gaya!" appears

TEST 5: Back navigation triggers confirmation dialog when caption edited
  - Pump screen with PopScope
  - Edit caption text
  - Simulate back press (tester.pageBack())
  - pump() → verify AlertDialog with "Caption edited" title appears

TEST 6: All 4 share destination cards render
  - Pump screen
  - Verify find.text('Broadcast List') findsOneWidget
  - Verify find.text('WhatsApp Status') findsOneWidget
  - Verify find.text('Group') findsOneWidget
  - Verify find.text('Ek Contact ko') findsOneWidget

MOCK SETUP for all tests:
  - Mock http.Client to avoid real network calls in image download
  - Override captionServiceProvider with a mock that returns immediately
  - Use a testAd with imageUrl: 'https://example.com/test.jpg'

────────────────────────────────────────
  OUTPUT ORDER (6 files)
────────────────────────────────────────

NEW (2 files):
  1. lib/features/studio/presentation/screens/whatsapp_broadcast_screen.dart
  2. test/features/studio/presentation/screens/whatsapp_broadcast_screen_test.dart

MODIFIED (4 files):
  3. lib/core/constants/app_strings.dart    (add 16 new strings)
  4. lib/core/constants/app_routes.dart     (add whatsappBroadcast constant)
  5. lib/core/router/app_router.dart        (add route)
  6. pubspec.yaml                           (add path_provider if missing)

────────────────────────────────────────
  DO NOT
────────────────────────────────────────

✗ DO NOT add a new bottom nav tab — this is a full-screen route in Studio branch
✗ DO NOT use WhatsApp Business API — system share sheet (share_plus) is MVP
✗ DO NOT make Firestore calls in this screen — all ad data comes from navigation extra
✗ DO NOT hardcode color values — use AppColors.* design tokens only
✗ DO NOT use Navigator.push — use context.push(AppRoutes.whatsappBroadcast, extra: ad)
✗ DO NOT add a new Riverpod provider — this screen is stateful (setState) only
✗ DO NOT run build_runner — no code-gen needed for this screen
```

---

## VALIDATION CHECKLIST

After implementation, run this sequence:

```powershell
flutter analyze
# Expected: No issues found!

flutter test test/features/studio/presentation/screens/whatsapp_broadcast_screen_test.dart
# Expected: 6/6 pass

flutter test
# Expected: 83/83 pass (77 existing + 6 new)

flutter run -d emulator-5554 --dart-define=SKIP_AUTH=true
# Test flow:
#   1. Studio tab loads (no error) ✅
#   2. Khata tab loads (empty state: "Koi udhaar nahi!") ✅
#   3. Tap camera FAB → capture → background select → ad preview ✅
#   4. In AdPreviewScreen tap "WhatsApp par bhejo" ✅
#   5. WhatsAppBroadcastScreen opens with ad thumbnail + caption ✅
#   6. Edit caption → restore button appears ✅
#   7. Tap language toggle → caption switches ✅
#   8. Tap any share card → system share sheet opens ✅
#   9. Back press after editing → confirmation dialog appears ✅
```

---

## WHAT COMES NEXT — TASK 2.4

> **Task 2.4 — Push Notification Scheduler (Festival Calendar)**
> A Cloudflare Cron Worker that runs daily at 6:00 AM IST. Checks a hardcoded
> 2026 Indian festival calendar. On matching dates, fetches all active user
> FCM tokens from Firestore (replaced from Supabase), sends batch FCM
> notifications via Firebase HTTP v1 API (replacing the old FCMSERVERKEY
> legacy API), and logs delivery stats back to Firestore `usageEvents`.
> Also implements "2 days before" reminders for Diwali, Holi, Eid.
> Firebase-aware: uses Firestore REST API + service account JWT for auth.
> No Flutter code changes in this task.

---

*Dukaan AI v1.0 Build Playbook · Task 2.3 (WhatsApp Broadcast) · April 2026*
