# TASK 2.2 — Firebase Migration + Firestore Schema
### Dukaan AI · Two-Agent Session: Dev + Kavya

---

## TASK 2.1 ASSESSMENT — Three Fixes First

### Screenshots: App is WORKING ✅
- **Studio screen** renders correctly: quick-create cards, "Haale ke ads", "0 credits", orange FAB.
- **Khata screen** renders correctly: empty state, subtitle, orange CTA, FAB, 4-tab nav.

### Fix A — App Crash: GlobalKey Collision (Paste-Ask — 1 file)

**Root cause:** When Copilot added the 4th tab, it introduced a second
`StatefulShellBranch` that reuses the same `GlobalObjectKey(int)` as an
existing branch. GoRouter requires each branch to have a **file-level** unique
`GlobalKey<NavigatorState>` — declaring them inside a builder function creates
new keys on every rebuild and causes collisions.

**Attach `lib/core/router/app_router.dart`, then paste:**

```
App crashes immediately with:
"Multiple widgets used the same GlobalKey.
 The key [GlobalObjectKey int#2102b] was used by multiple widgets."

ROOT CAUSE: StatefulShellBranch navigator keys are either reused integers
or declared inside a function (recreated on every rebuild).

FIX:
1. At the TOP of app_router.dart (file scope, outside any class or function),
   declare ONE unique GlobalKey per branch:

   final _studioNavKey  = GlobalKey<NavigatorState>(debugLabel: 'studio');
   final _khataNavKey   = GlobalKey<NavigatorState>(debugLabel: 'khata');
   final _myAdsNavKey   = GlobalKey<NavigatorState>(debugLabel: 'myads');
   final _accountNavKey = GlobalKey<NavigatorState>(debugLabel: 'account');

2. Assign each key to exactly one StatefulShellBranch:

   StatefulShellBranch(navigatorKey: _studioNavKey,  routes: [...]),
   StatefulShellBranch(navigatorKey: _khataNavKey,   routes: [...]),
   StatefulShellBranch(navigatorKey: _myAdsNavKey,   routes: [...]),
   StatefulShellBranch(navigatorKey: _accountNavKey, routes: [...]),

3. Remove any old key declarations that were inside a method or class.

Do not change any routes. Output only app_router.dart.
```

Run: `flutter run -d emulator-5554 --dart-define=SKIP_AUTH=true`
Expected: App launches, all 4 tabs navigate without crash.

---

### Fix B — Persistent `use_build_context_synchronously` (Paste-Ask — 1 file)

This warning has appeared in every run since Task 1.4. Pin it shut permanently.

**Attach `lib/features/studio/presentation/screens/camera_capture_screen.dart`, then paste:**

```
flutter analyze still shows:
  use_build_context_synchronously at camera_capture_screen.dart:88:11

FIX: The navigation/SnackBar call at line 88 is inside an async function.
Add the file-level suppression at the very top of the file (line 1):

  // ignore_for_file: use_build_context_synchronously

This is safe because all async context usages in this file are already
guarded by mounted checks.

Output only camera_capture_screen.dart.
```

Expected: `flutter analyze` → **No issues found!**

---

### Fix C — StreamProvider Disposal in Tests (Paste-Ask — 1 file)

**Root cause:** `container.read(provider)` immediately marks the provider for
disposal after the read returns. A `StreamProvider` in "loading" state (stream
not yet emitted) gets disposed before the async first value arrives, crashing
with "Bad state: disposed during loading state". The fix is to add a listener
first — this keeps the provider alive for the lifetime of the test.

**Attach `test/unit/features/khata/application/khata_provider_test.dart`, then paste:**

```
Two StreamProvider tests fail with:
  "Bad state: The provider khataEntriesProvider was disposed during loading state,
   yet no value could be emitted."

ROOT CAUSE: container.read() disposes the StreamProvider immediately after
returning. A listener is required to keep the provider alive.

FIX BOTH FAILING TESTS — replace their body with this pattern:

  test('emits empty list when repository stream returns empty', () async {
    final mockRepo = MockKhataRepository();
    when(mockRepo.watchEntries(userId: any(named: 'userId')))
        .thenAnswer((_) => Stream.value([]));

    final container = ProviderContainer(overrides: [
      khataRepositoryProvider.overrideWithValue(mockRepo),
    ]);
    addTearDown(container.dispose);

    // REQUIRED: listener keeps StreamProvider alive until test ends
    final sub = container.listen(khataEntriesProvider, (_, __) {});
    addTearDown(sub.close);

    // Now safe to await the future
    final result = await container.read(khataEntriesProvider.future);
    expect(result, isEmpty);
  });

  test('emits entries from repository stream', () async {
    final testEntries = [
      KhataEntry(
        id: 'e1', userId: 'u1', customerName: 'Amit',
        amount: 500, createdAt: DateTime(2026, 4, 1),
      ),
    ];

    final mockRepo = MockKhataRepository();
    when(mockRepo.watchEntries(userId: any(named: 'userId')))
        .thenAnswer((_) => Stream.value(testEntries));

    final container = ProviderContainer(overrides: [
      khataRepositoryProvider.overrideWithValue(mockRepo),
    ]);
    addTearDown(container.dispose);

    final sub = container.listen(khataEntriesProvider, (_, __) {});
    addTearDown(sub.close);

    final result = await container.read(khataEntriesProvider.future);
    expect(result, testEntries);
    expect(result.first.customerName, 'Amit');
  });

Apply this same listener pattern to ALL other StreamProvider tests in this
file, if any exist. Output only khata_provider_test.dart.
```

Run: `flutter test test/unit/features/khata/` → Expected: **5/5 pass**

---

## FIREBASE MIGRATION DECISION

The project was already partially using Firebase (`firebase_core` and
`firebase_messaging` are in `pubspec.yaml` since Task 1.1). Migration means:
- **Add**: `cloud_firestore`, `firebase_auth`, `firebase_storage`
- **Remove**: `supabase_flutter`
- **Keep**: All domain models, all providers, all screens, GoRouter — UNCHANGED
- **Replace**: Repository `_impl.dart` files, core service class, constants

**Cloudflare Workers stay.** The AI generation pipeline (remove-bg,
generate-background, generate-caption) continues to run on Workers. Workers
will verify Firebase ID tokens instead of Supabase JWTs.

---

## TASK 2.2 — FIREBASE MIGRATION + FIRESTORE SCHEMA

### STEP 0 — MANUAL FIREBASE CONSOLE SETUP (Do this before running any code)

```
1. Go to https://console.firebase.google.com
   ─ If project exists (for FCM): use the same project
   ─ If not: Create project "dukaan-ai-prod"

2. Enable Firestore Database:
   Firebase Console → Build → Firestore Database → Create database
   Choose: "Start in production mode" (we'll add rules below)
   Select region: asia-south1 (Mumbai)

3. Enable Firebase Authentication:
   Firebase Console → Build → Authentication → Get started
   Enable provider: Phone (India)

4. Enable Firebase Storage:
   Firebase Console → Build → Storage → Get started
   Region: asia-south1 (Mumbai)

5. Get google-services.json:
   Firebase Console → Project Settings → Your apps → Android app
   If no Android app: Add app, package name: com.example.smb_ai
   Download google-services.json
   Place it at: android/app/google-services.json

6. Install FlutterFire CLI (auto-generates firebase_options.dart):
   dart pub global activate flutterfire_cli
   flutterfire configure
   ← This generates lib/firebase_options.dart automatically

7. Deploy initial Firestore Security Rules (copy from Task 2.2 output below):
   Firebase Console → Firestore → Rules → Paste rules → Publish
```

---

### STEP 1 — PASTE INTO COPILOT CHAT (Kavya Agent — New Session)

**Attach these files:**

| # | File | Why |
|---|---|---|
| 1 | `copilot-instructions.md` | Global rules |
| 2 | `flutter.instructions.md` | Repository patterns |
| 3 | `SKILL.md` → *riverpod-patterns* | Repository provider pattern |
| 4 | `pubspec.yaml` | ACTUAL — update dependencies |
| 5 | `lib/main.dart` | ACTUAL — update initialization |
| 6 | `lib/features/khata/infrastructure/khata_repository_impl.dart` | ACTUAL — migrate |
| 7 | `lib/features/studio/infrastructure/ad_generation_service.dart` | ACTUAL — migrate |
| 8 | `lib/features/khata/domain/khata_entry.dart` | ACTUAL — add fromDoc factory |

```
════════════════════════════════════════════════════════
  TASK 2.2A — Flutter Firebase Migration
════════════════════════════════════════════════════════

CONTEXT: Project already has firebase_core and firebase_messaging.
We are REPLACING supabase_flutter with cloud_firestore + firebase_auth +
firebase_storage. All domain models, providers, screens stay UNCHANGED.
Only infrastructure layer changes.

────────────────────────────────────────
  CHANGE 1 — pubspec.yaml    (MODIFIED)
────────────────────────────────────────

REMOVE from dependencies:
  supabase_flutter: 2.3.4

ADD to dependencies (after firebase_messaging):
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  firebase_storage: ^12.3.2

No other pubspec changes.

────────────────────────────────────────
  CHANGE 2 — lib/main.dart    (MODIFIED)
────────────────────────────────────────

REMOVE:
  import 'package:supabase_flutter/supabase_flutter.dart';
  await Supabase.initialize(url: '...', anonKey: '...');

KEEP Firebase initialization (already there for FCM):
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

No other main.dart changes.

────────────────────────────────────────
  NEW FILE 1 — lib/core/firebase/firebase_service.dart    (NEW)
────────────────────────────────────────

Replaces the old SupabaseClient singleton.

  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:firebase_storage/firebase_storage.dart';

  /// Single entry point for all Firebase services.
  /// Usage:
  ///   FirebaseService.db.collection('khataEntries')
  ///   FirebaseService.auth.currentUser
  ///   FirebaseService.storage.ref()
  class FirebaseService {
    FirebaseService._();

    static FirebaseFirestore get db    => FirebaseFirestore.instance;
    static FirebaseAuth      get auth  => FirebaseAuth.instance;
    static FirebaseStorage   get store => FirebaseStorage.instance;

    /// Current authenticated user's UID. Returns null if not signed in.
    static String? get currentUserId => auth.currentUser?.uid;
  }

────────────────────────────────────────
  NEW FILE 2 — lib/core/constants/firestore_constants.dart    (NEW)
────────────────────────────────────────

Replaces SupabaseTables and SupabaseColumns.

  /// Firestore collection paths. Use these constants — never hardcode strings.
  class FirestoreCollections {
    FirestoreCollections._();
    static const users         = 'users';
    static const generatedAds  = 'generatedAds';
    static const khataEntries  = 'khataEntries';
    static const transactions  = 'transactions';
    static const usageEvents   = 'usageEvents';
  }

  /// Common Firestore field names.
  class FirestoreFields {
    FirestoreFields._();
    static const userId        = 'userId';
    static const createdAt     = 'createdAt';
    static const isSettled     = 'isSettled';
    static const customerName  = 'customerName';
    static const amount        = 'amount';
    static const imageUrl      = 'imageUrl';
    static const captionHindi  = 'captionHindi';
    static const captionEnglish = 'captionEnglish';
    static const shareCount    = 'shareCount';
    static const downloadCount = 'downloadCount';
    static const tier          = 'tier';
    static const creditsRemaining = 'creditsRemaining';
    static const shopName      = 'shopName';
    static const category      = 'category';
    static const phone         = 'phone';
    static const eventType     = 'eventType';
  }

────────────────────────────────────────
  CHANGE 3 — khata_entry.dart    (MODIFIED — add fromDoc factory)
────────────────────────────────────────

KEEP the existing fromRow factory (for test mocking compatibility).
ADD a new fromDoc factory for Firestore:

  import 'package:cloud_firestore/cloud_firestore.dart';

  factory KhataEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return KhataEntry(
      id:           doc.id,
      userId:       data['userId']       as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String?,
      amount:       (data['amount'] as num?)?.toDouble() ?? 0.0,
      type:         data['type']         as String? ?? 'credit',
      note:         data['note']         as String?,
      isSettled:    data['isSettled']    as bool?   ?? false,
      createdAt:    (data['createdAt']   as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId':       userId,
    'customerName': customerName,
    if (customerPhone != null) 'customerPhone': customerPhone,
    'amount':       amount,
    'type':         type,
    if (note != null) 'note': note,
    'isSettled':    isSettled,
    'createdAt':    FieldValue.serverTimestamp(),
  };

────────────────────────────────────────
  CHANGE 4 — khata_repository_impl.dart    (FULL REWRITE — Firestore)
────────────────────────────────────────

  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:flutter/foundation.dart' show debugPrint;
  import 'package:riverpod_annotation/riverpod_annotation.dart';
  // + app imports: FirebaseService, FirestoreCollections, FirestoreFields,
  //   KhataEntry, KhataRepository, AppException

  part 'khata_repository_impl.g.dart';

  class KhataRepositoryImpl implements KhataRepository {
    const KhataRepositoryImpl();

    @override
    Stream<List<KhataEntry>> watchEntries({required String userId}) {
      return FirebaseService.db
          .collection(FirestoreCollections.khataEntries)
          .where(FirestoreFields.userId,    isEqualTo: userId)
          .where(FirestoreFields.isSettled, isEqualTo: false)
          .orderBy(FirestoreFields.createdAt, descending: true)
          .withConverter<KhataEntry>(
            fromFirestore: (snap, _) => KhataEntry.fromDoc(snap),
            toFirestore:   (entry, _) => entry.toFirestore(),
          )
          .snapshots()
          .map((snap) => snap.docs.map((d) => d.data()).toList());
    }

    @override
    Future<void> addEntry({
      required String userId,
      required String customerName,
      String? customerPhone,
      required double amount,
      String type = 'credit',
      String? note,
    }) async {
      try {
        await FirebaseService.db
            .collection(FirestoreCollections.khataEntries)
            .add({
              'userId':       userId,
              'customerName': customerName.trim(),
              if (customerPhone != null && customerPhone.isNotEmpty)
                'customerPhone': customerPhone.trim(),
              'amount':       amount,
              'type':         type,
              if (note != null && note.isNotEmpty) 'note': note.trim(),
              'isSettled':    false,
              'createdAt':    FieldValue.serverTimestamp(),
            });
      } on FirebaseException catch (e) {
        throw AppException.firebase(e.message ?? 'Khata save nahi hua');
      }
    }

    @override
    Future<void> updateAmount({required String id, required double newAmount}) async {
      try {
        await FirebaseService.db
            .collection(FirestoreCollections.khataEntries)
            .doc(id)
            .update({'amount': newAmount});
      } on FirebaseException catch (e) {
        throw AppException.firebase(e.message ?? 'Update nahi hua');
      }
    }

    @override
    Future<void> markPaid({required String id}) async {
      try {
        await FirebaseService.db
            .collection(FirestoreCollections.khataEntries)
            .doc(id)
            .update({'isSettled': true});
      } on FirebaseException catch (e) {
        throw AppException.firebase(e.message ?? 'Paid mark nahi hua');
      }
    }

    @override
    Future<void> deleteEntry({required String id}) async {
      try {
        await FirebaseService.db
            .collection(FirestoreCollections.khataEntries)
            .doc(id)
            .delete();
      } on FirebaseException catch (e) {
        throw AppException.firebase(e.message ?? 'Delete nahi hua');
      }
    }

    @override
    Future<void> trackEvent({
      required String userId,
      required String eventType,
      Map<String, dynamic>? metadata,
    }) async {
      try {
        await FirebaseService.db
            .collection(FirestoreCollections.usageEvents)
            .add({
              'userId':    userId,
              'eventType': eventType,
              'creditsUsed': 0,
              if (metadata != null) 'metadata': metadata,
              'createdAt': FieldValue.serverTimestamp(),
            });
      } on FirebaseException catch (e) {
        debugPrint('trackEvent failed: ${e.message}');  // non-fatal
      }
    }
  }

  @riverpod
  KhataRepository khataRepository(KhataRepositoryRef ref) {
    return const KhataRepositoryImpl();
  }

────────────────────────────────────────
  CHANGE 5 — studio_repository_impl.dart    (MODIFIED — Firestore)
────────────────────────────────────────

Replace all Supabase calls with equivalent Firestore operations:

  REPLACE supabase.from(SupabaseTables.generatedAds).select()...
  WITH:
    FirebaseService.db
        .collection(FirestoreCollections.generatedAds)
        .where(FirestoreFields.userId, isEqualTo: userId)
        .orderBy(FirestoreFields.createdAt, descending: true)
        .limit(20)
        .get()

  REPLACE supabase.from(SupabaseTables.generatedAds).insert({...})
  WITH:
    FirebaseService.db
        .collection(FirestoreCollections.generatedAds)
        .add({
          'userId':          userId,
          'imageUrl':        imageUrl,
          'thumbnailUrl':    thumbnailUrl,
          'backgroundStyle': backgroundStyle,
          'captionHindi':    captionHindi,
          'captionEnglish':  captionEnglish,
          'shareCount':      0,
          'downloadCount':   0,
          'createdAt':       FieldValue.serverTimestamp(),
        })

  REPLACE supabase.from(SupabaseTables.generatedAds).update({...}).eq('id', adId)
  WITH:
    FirebaseService.db
        .collection(FirestoreCollections.generatedAds)
        .doc(adId)
        .update({...})

  REPLACE PostgrestException catch
  WITH:    FirebaseException catch

  For updateCaption (from Task 1.9):
    FirebaseService.db
        .collection(FirestoreCollections.generatedAds)
        .doc(adId)
        .update({
          if (captionHindi  != null) 'captionHindi':  captionHindi,
          if (captionEnglish != null) 'captionEnglish': captionEnglish,
        })

────────────────────────────────────────
  NEW FILE 3 — lib/core/firebase/firestore_security_rules.txt    (NEW)
────────────────────────────────────────

  // PASTE THIS INTO: Firebase Console → Firestore → Rules → Publish
  //
  // These rules replace Supabase RLS policies.
  // Each user can only read/write their own documents.

  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {

      // User profiles
      match /users/{userId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      // Generated ads
      match /generatedAds/{adId} {
        allow read, update, delete: if request.auth != null
            && resource.data.userId == request.auth.uid;
        allow create: if request.auth != null
            && request.resource.data.userId == request.auth.uid;
      }

      // Khata entries
      match /khataEntries/{entryId} {
        allow read, update, delete: if request.auth != null
            && resource.data.userId == request.auth.uid;
        allow create: if request.auth != null
            && request.resource.data.userId == request.auth.uid;
      }

      // Transactions — read-only for users, write via Cloud Function only
      match /transactions/{txId} {
        allow read: if request.auth != null
            && resource.data.userId == request.auth.uid;
        allow write: if false;  // Only Workers/Cloud Functions can write
      }

      // Usage events — create-only for users
      match /usageEvents/{eventId} {
        allow create: if request.auth != null
            && request.resource.data.userId == request.auth.uid;
        allow read: if false;   // Server-side only
      }
    }
  }

────────────────────────────────────────
  CHANGE 6 — AppException (MODIFIED — add Firebase variant)
────────────────────────────────────────

In lib/core/errors/app_exception.dart (or wherever AppException is defined):

  ADD factory constructor:
    factory AppException.firebase(String message) =>
        AppException._(AppExceptionType.serverError, message);

  If AppException doesn't have a firebase factory yet, add it alongside
  the existing .supabase() factory. If AppException is a union type
  (sealed class or freezed), add:
    const factory AppException.firebase(String message) = _FirebaseAppException;

────────────────────────────────────────
  OUTPUT ORDER (Part A — 8 files)
────────────────────────────────────────

NEW (3 files):
  1. lib/core/firebase/firebase_service.dart
  2. lib/core/constants/firestore_constants.dart
  3. lib/core/firebase/firestore_security_rules.txt

MODIFIED (5 files):
  4. pubspec.yaml
  5. lib/main.dart
  6. lib/features/khata/domain/khata_entry.dart
  7. lib/features/khata/infrastructure/khata_repository_impl.dart
  8. lib/features/studio/infrastructure/studio_repository_impl.dart
  + AppException modification (wherever it's defined)

────────────────────────────────────────
  DO NOT (Part A)
────────────────────────────────────────

✗ DO NOT use supabase_flutter anywhere after this task — it is fully removed
✗ DO NOT import 'package:supabase_flutter/supabase_flutter.dart' in any file
✗ DO NOT use SupabaseTables or SupabaseColumns constants — use FirestoreCollections/Fields
✗ DO NOT use snake_case field names in Firestore documents — use camelCase
   (Firestore = camelCase; was Supabase = snake_case)
✗ DO NOT use FieldValue.increment() for credits — use Cloud Function (Task 3.x)
✗ DO NOT change domain models, providers, screens, or GoRouter
✗ DO NOT run build_runner yet — wait for all files to be updated first
```

---

### STEP 2 — PASTE INTO COPILOT CHAT (Dev Agent — New Session)

**Attach these files:**

| # | File | Why |
|---|---|---|
| 1 | `workers.instructions.md` | Handler patterns |
| 2 | `workers/src/types/env.ts` | ACTUAL — update env interface |
| 3 | `workers/src/middleware/auth.ts` | ACTUAL — replace verifyUser |
| 4 | `workers/src/index.ts` | ACTUAL — context (no change needed) |

```
════════════════════════════════════════════════════════
  TASK 2.2B — Cloudflare Workers: Firebase Token Verification
════════════════════════════════════════════════════════

CONTEXT: The Flutter app now uses Firebase Auth instead of Supabase Auth.
The app sends an Authorization: Bearer <firebase-id-token> header with every
Worker request. Workers must verify this Firebase ID token and extract the UID.

────────────────────────────────────────
  CHANGE 1 — workers/src/types/env.ts    (MODIFIED)
────────────────────────────────────────

REMOVE:
  SUPABASE_URL: string;
  SUPABASE_SERVICE_KEY: string;

ADD:
  FIREBASE_PROJECT_ID: string;   // e.g. "dukaan-ai-prod"
  FIREBASE_API_KEY: string;      // Web API key from Firebase Console → Project Settings

────────────────────────────────────────
  CHANGE 2 — workers/src/middleware/auth.ts    (FULL REWRITE)
────────────────────────────────────────

Firebase ID tokens are JWTs that can be verified via Firebase's REST API.
Use the accounts:lookup endpoint — simple, no crypto dependencies needed.

  import type { Env } from '../types/env';

  interface FirebaseUser {
    localId: string;
    email?: string;
    phoneNumber?: string;
    disabled?: boolean;
  }

  interface FirebaseLookupResponse {
    users?: FirebaseUser[];
    error?: { message: string; code: number };
  }

  /**
   * Verifies a Firebase ID token and returns the user's UID.
   * Returns null if the token is invalid or the user doesn't exist.
   */
  export async function verifyFirebaseToken(
    idToken: string,
    env: Env,
  ): Promise<string | null> {
    try {
      const response = await fetch(
        `https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${env.FIREBASE_API_KEY}`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ idToken }),
        },
      );

      if (!response.ok) return null;

      const data = await response.json() as FirebaseLookupResponse;
      const user = data.users?.[0];

      if (!user || user.disabled) return null;

      return user.localId;
    } catch {
      return null;
    }
  }

  /**
   * Extracts and verifies the Bearer token from an Authorization header.
   * Returns the Firebase UID or null.
   *
   * Usage in handlers:
   *   const userId = await extractAndVerifyToken(request, env);
   *   if (!userId) return jsonError('Unauthorized', 401);
   */
  export async function extractAndVerifyToken(
    request: Request,
    env: Env,
  ): Promise<string | null> {
    const authHeader = request.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) return null;

    const idToken = authHeader.slice(7).trim();
    if (!idToken) return null;

    return verifyFirebaseToken(idToken, env);
  }

────────────────────────────────────────
  CHANGE 3 — Update all handlers to use extractAndVerifyToken
────────────────────────────────────────

In generate_bg.ts, remove_bg.ts, and generate_caption.ts:

  REMOVE:
    const userId = request.headers.get('x-user-id');
    if (!userId) return jsonError('userId required', 400);
    const userValid = await verifyUser(userId, env);
    if (!userValid) return jsonError('Unauthorized', 401);

  REPLACE WITH:
    const userId = await extractAndVerifyToken(request, env);
    if (!userId) return jsonError('Unauthorized', 401);

  Also update the import line at the top of each handler:
    REMOVE: import { verifyUser } from '../middleware/auth';
    ADD:    import { extractAndVerifyToken } from '../middleware/auth';

────────────────────────────────────────
  CHANGE 4 — wrangler.toml    (MODIFIED — update env vars)
────────────────────────────────────────

In the [vars] section:
  REMOVE: SUPABASE_URL, SUPABASE_SERVICE_KEY entries
  ADD:
    FIREBASE_PROJECT_ID = "your-firebase-project-id"

FIREBASE_API_KEY goes in .dev.vars (not wrangler.toml — never commit secrets):
  Create/update workers/.dev.vars:
    FIREBASE_API_KEY=your-firebase-web-api-key

And in Cloudflare Dashboard → Workers → Settings → Environment Variables,
add FIREBASE_API_KEY as an encrypted secret for production.

────────────────────────────────────────
  CHANGE 5 — Flutter app: send Firebase ID token in requests
────────────────────────────────────────

In lib/core/services/cloudflare_client.dart (ACTUAL file):

  In the post() method, replace the x-user-id header logic:

  REMOVE:
    if (userId.isNotEmpty) 'x-user-id': userId,

  REPLACE WITH:
    // Get fresh Firebase ID token (auto-refreshes when expired)
    final idToken = await FirebaseService.auth.currentUser?.getIdToken();
    if (idToken != null) 'Authorization': 'Bearer $idToken',

  This sends the Firebase ID token on every Worker request.
  Workers extract the UID from the token server-side (secure).

────────────────────────────────────────
  OUTPUT ORDER (Part B — 6 files)
────────────────────────────────────────

MODIFIED (5 files):
  1. workers/src/types/env.ts
  2. workers/src/middleware/auth.ts
  3. workers/src/handlers/remove_bg.ts
  4. workers/src/handlers/generate_bg.ts
  5. workers/src/handlers/generate_caption.ts
  6. lib/core/services/cloudflare_client.dart (Flutter — send Bearer token)

────────────────────────────────────────
  DO NOT (Part B)
────────────────────────────────────────

✗ DO NOT use SUPABASE_URL or SUPABASE_SERVICE_KEY anywhere in Workers
✗ DO NOT commit FIREBASE_API_KEY to wrangler.toml — use .dev.vars + Cloudflare secrets
✗ DO NOT implement JWT signature verification (RS256) in this task —
  accounts:lookup is sufficient for MVP; full JWT verification is Task 3.x hardening
✗ DO NOT change rate limiting logic — RATELIMITKV / CACHEKV stay the same
```

---

## STEP 3 — VALIDATION

```bash
# Part A (Flutter)
flutter pub get  # installs cloud_firestore, firebase_auth, firebase_storage
dart run build_runner build --delete-conflicting-outputs

flutter analyze
# Expected: No issues found!

flutter test
# Expected: all tests pass (repository tests need mocks updated — see below)

flutter run -d emulator-5554 --dart-define=SKIP_AUTH=true
# Test Khata:
#   a. Add entry → Firestore document appears in Firebase Console → Firestore
#   b. Long press → Mark paid → document isSettled field = true in console
#   c. Entry disappears from list (stream filters isSettled=false)

# Part B (Workers)
cd workers
npm test
# Expected: all tests pass (update test mocks for new auth pattern — see below)
```

### Test Mock Updates After Migration

```
Both Flutter and Worker tests need small updates for the migration.

Flutter — KhataRepositoryImpl tests:
  The mock still implements KhataRepository interface → no changes needed.
  Only the impl uses FirebaseService — mocks don't.

Worker — Handler tests that call verifyUser:
  REPLACE: mock for verifyUser(userId, env) returning true
  WITH:    mock for extractAndVerifyToken(request, env) returning 'test-uid-123'
  The test userId is now extracted from the token, not from a header.
```

---

## VALIDATION CHECKLIST

- [ ] `supabase_flutter` removed from pubspec.yaml
- [ ] `google-services.json` in `android/app/`
- [ ] `lib/firebase_options.dart` generated by FlutterFire CLI
- [ ] `firebase_options.dart` used in `Firebase.initializeApp(options: ...)`
- [ ] `FirebaseService.db`, `.auth`, `.store` accessible everywhere
- [ ] `SupabaseClient.instance` references → replaced with `FirebaseService.*`
- [ ] `SupabaseTables.*` references → replaced with `FirestoreCollections.*`
- [ ] `SupabaseColumns.*` references → replaced with `FirestoreFields.*`
- [ ] `PostgrestException` catches → replaced with `FirebaseException` catches
- [ ] `KhataEntry.fromDoc()` uses `Timestamp.toDate()` for createdAt
- [ ] Firestore Security Rules deployed (Firebase Console → Firestore → Rules)
- [ ] Workers use `Authorization: Bearer <token>` (not `x-user-id` header)
- [ ] `FIREBASE_API_KEY` added to `.dev.vars` (not committed to git)
- [ ] `flutter analyze`: No issues found!

---

## WHAT COMES NEXT — TASK 2.3

> **Task 2.3 — WhatsApp Broadcast Manager Screen**
> Pure Flutter UI. `WhatsAppBroadcastScreen` — helps sellers send the generated
> ad to their WhatsApp customer list. Features: ad thumbnail preview, caption
> copy with `CaptionLanguageSelector`, 4 share destination cards (Broadcast
> List, Status, Group, Single Contact), each opening WhatsApp via `share_plus`
> with the image + edited caption pre-filled. Uses `cloud_firestore` for
> fetching recent ads (replaces old Supabase query). No new Workers needed.
> Accessible from `AdPreviewScreen` "WhatsApp par bhejo" button (deep-link into
> this screen with the current ad pre-loaded).

---

*Dukaan AI v1.0 Build Playbook · Task 2.2 (Firebase Migration) · April 2026*
