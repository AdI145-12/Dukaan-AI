# TASK 2.4 — Festival Push Notification Scheduler
### Dukaan AI · Single-Agent Session: Dev (Cloudflare Worker)

---

## TASK 2.3 STATUS — Three Outstanding Issues

### Screenshots: Error screens persist (same as Task 2.2)

The anonymous sign-in block ran but failed:
  `[firebase_auth/unknown] Firebase dependency not configured yet.`

This is NOT a code bug. It is a one-click Firebase Console configuration
step you must do manually before running the app again.

---

## MANUAL FIX REQUIRED (No Code) — Do This Now

### Fix 0 — Enable Anonymous Auth in Firebase Console

```
1. Open https://console.firebase.google.com → select your project

2. Left sidebar → Build → Authentication

3. If you see "Get started" button → click it
   This activates the Authentication service for your project.

4. Click the "Sign-in method" tab

5. Find "Anonymous" in the list → click it → toggle ENABLE → Save

6. ALSO confirm these are enabled:
   Phone → Enable (for production OTP login later)
   Anonymous → Enable (for dev SKIP_AUTH mode)

7. Re-run the app:
   flutter run -d emulator-5554 --dart-define=SKIP_AUTH=true

8. Expected log line:
   [DEV] SKIP_AUTH anonymous sign-in → <some-uid>

9. Expected UI:
   Studio tab: "Abhi koi ad nahi! Pehla ad banao."  (empty, no error)
   Khata tab:  "Koi udhaar nahi! 🎉"                (empty, no error)
```

---

## CODE FIX A — `withOpacity` Deprecation Warning (Paste-Ask — 1 file)

**Attach `lib/features/studio/presentation/screens/whatsapp_broadcast_screen.dart`, paste:**

```
flutter analyze shows:
  'withOpacity' is deprecated. Use .withValues() to avoid precision loss
  whatsapp_broadcast_screen.dart:537:44

FIX: Find every occurrence of .withOpacity(x) in this file and replace with
.withValues(alpha: x).

Example:
  BEFORE: Colors.green.withOpacity(0.1)
  AFTER:  Colors.green.withValues(alpha: 0.1)

Apply to ALL occurrences in the file. Output only whatsapp_broadcast_screen.dart.
```

Expected: `flutter analyze` → **No issues found!**

---

## CODE FIX B — Two Failing whatsapp_broadcast_screen_test Tests (Paste-Ask — 1 file)

**Attach `test/features/studio/presentation/screens/whatsapp_broadcast_screen_test.dart`, paste:**

```
Two widget tests are failing. Here is the root cause and fix for each:

════════════════════════════════
TEST 1 — "copy button shows snackbar"
Expected: find.text("Caption copy ho gaya!")
Actual:   0 widgets found
════════════════════════════════

ROOT CAUSE: Clipboard.setData() is asynchronous. The SnackBar is displayed
via ScaffoldMessenger, but the test uses pump() instead of pumpAndSettle().
Also, the test may be wrapping the widget in a plain MaterialApp without a
ScaffoldMessengerKey, which means the SnackBar can't be retrieved.

FIX — Replace the test body:
  testWidgets('copy button shows snackbar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProviderScope(
          overrides: [...baseOverrides],
          child: WhatsAppBroadcastScreen(ad: testAd),
        ),
      ),
    );
    await tester.pumpAndSettle();  // let screen fully build

    await tester.tap(find.text(AppStrings.captionCopyBtn));
    await tester.pump();            // starts SnackBar animation
    await tester.pump(const Duration(milliseconds: 100)); // completes entry

    expect(find.text(AppStrings.captionCopied), findsOneWidget);
  });

Key change: ProviderScope wraps the screen INSIDE MaterialApp, not outside.
MaterialApp must be the root so ScaffoldMessenger is an ancestor of the screen.

════════════════════════════════
TEST 2 — "back navigation shows confirmation when caption edited"
Expected: CupertinoNavigationBarBackButton (via tester.pageBack())
Actual:   0 widgets found
════════════════════════════════

ROOT CAUSE: tester.pageBack() looks for CupertinoNavigationBarBackButton or
BackButton. The AppBar in WhatsAppBroadcastScreen uses a custom leading
IconButton, not the standard BackButton widget. tester.pageBack() cannot
find it.

FIX — Replace pageBack() with a direct Navigator.maybePop() call:
  testWidgets('back navigation shows confirmation when caption edited',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProviderScope(
          overrides: [...baseOverrides],
          child: WhatsAppBroadcastScreen(ad: testAd),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Edit caption to mark _captionEdited = true
    final captionField = find.byType(TextField).first;
    await tester.enterText(captionField, 'Custom edited caption');
    await tester.pump();

    // Trigger back navigation via Navigator (replaces tester.pageBack())
    final NavigatorState navigator =
        tester.state(find.byType(Navigator));
    navigator.maybePop();
    await tester.pumpAndSettle();

    // Confirmation dialog should appear
    expect(find.text(AppStrings.captionBackConfirmTitle), findsOneWidget);
  });

Apply BOTH fixes. Keep all other 4 tests unchanged.
The MaterialApp → ProviderScope order must be applied to ALL 6 tests for
consistency. Output only whatsapp_broadcast_screen_test.dart.
```

Run after fixes:
```powershell
flutter test test/features/studio/presentation/screens/whatsapp_broadcast_screen_test.dart
# Expected: 6/6 pass

flutter test
# Expected: all pass
```

---

## TASK 2.4 — FESTIVAL PUSH NOTIFICATION SCHEDULER

### What It Does
A Cloudflare Cron Worker that runs daily at **6:00 AM IST (00:30 UTC)**. It
checks a hardcoded 2026 Indian festival calendar, and on matching days fetches
all active users' FCM tokens from Firestore, then sends personalised push
notifications via **Firebase FCM HTTP v1 API** (the modern API — the legacy
`FCMSERVERKEY` approach is deprecated and will be shut down).

### Firebase vs Playbook Adaptation
The playbook's Prompt 2.4 used `SUPABASE_URL + SUPABASE_SERVICE_KEY` to fetch
tokens and `FCMSERVERKEY` (legacy FCM) to send. Both are replaced:
- Token storage: **Firestore** (`users/{userId}` → `fcmToken` field)  
- Push sending: **Firebase FCM HTTP v1 API** with service account JWT auth

---

### Paste Into Copilot Chat (Dev Agent — New Session)

**Attach these files:**

| # | File | Why |
|---|---|---|
| 1 | `workers.instructions.md` | Handler patterns |
| 2 | `SKILL.md` → *worker-patterns* | Auth, env, CORS |
| 3 | `workers/src/index.ts` | ACTUAL — add cron handler |
| 4 | `workers/src/types/env.ts` | ACTUAL — add new env vars |
| 5 | `workers/wrangler.toml` | ACTUAL — add cron trigger |

```
════════════════════════════════════════════════════════
  TASK 2.4 — Festival Push Notification Scheduler
  Cloudflare Cron Worker · Firebase FCM HTTP v1 API
════════════════════════════════════════════════════════

CONTEXT:
This is a Cloudflare Scheduled Worker (Cron Trigger) — NOT a fetch handler.
It fires daily at 00:30 UTC (6:00 AM IST). It checks today's date against
a hardcoded festival calendar. On a match, it:
  1. Fetches all active users from Firestore (users collection, fcmToken exists)
  2. Gets a Firebase OAuth2 access token using a service account JWT
  3. Sends FCM push notifications via Firebase HTTP v1 API
  4. Logs delivery stats to Firestore usageEvents

Firebase note: uses Firestore REST API + FCM HTTP v1 API.
No Supabase anywhere. No legacy FCMSERVERKEY.

────────────────────────────────────────
  CHANGE 1 — workers/src/types/env.ts    (MODIFIED — add vars)
────────────────────────────────────────

ADD to the Env interface:
  // Firebase service account for FCM + Firestore admin access
  FIREBASE_PROJECT_ID: string;        // e.g. "dukaan-ai-prod"
  FIREBASE_CLIENT_EMAIL: string;      // service account email
  FIREBASE_PRIVATE_KEY: string;       // service account private key (PEM)

KEEP existing vars (FIREBASE_API_KEY, etc.) — only ADD the above.

How to get these values:
  Firebase Console → Project Settings → Service accounts →
  Generate new private key → download JSON →
  FIREBASE_PROJECT_ID = project_id field
  FIREBASE_CLIENT_EMAIL = client_email field
  FIREBASE_PRIVATE_KEY = private_key field (the full PEM string)

Store all three as Cloudflare secrets (never in wrangler.toml):
  wrangler secret put FIREBASE_CLIENT_EMAIL
  wrangler secret put FIREBASE_PRIVATE_KEY
  For local dev: add to workers/.dev.vars (not committed to git)

────────────────────────────────────────
  NEW FILE 1 — workers/src/lib/firebase-admin.ts    (NEW)
────────────────────────────────────────

Firebase admin utilities: JWT generation + access token + Firestore REST API.

  /**
   * Creates a short-lived Google OAuth2 access token from a service account.
   * Uses the Web Crypto API (available in Cloudflare Workers) to sign the JWT.
   * Token scope: https://www.googleapis.com/auth/firebase.messaging
   *              https://www.googleapis.com/auth/datastore
   */

  const JWT_EXPIRY_SECONDS = 3600;

  export interface ServiceAccount {
    projectId: string;
    clientEmail: string;
    privateKey: string;  // PEM format, 
 escaped
  }

  export async function getAccessToken(sa: ServiceAccount): Promise<string> {
    const now = Math.floor(Date.now() / 1000);

    const header = { alg: 'RS256', typ: 'JWT' };
    const payload = {
      iss:   sa.clientEmail,
      sub:   sa.clientEmail,
      aud:   'https://oauth2.googleapis.com/token',
      iat:   now,
      exp:   now + JWT_EXPIRY_SECONDS,
      scope: [
        'https://www.googleapis.com/auth/firebase.messaging',
        'https://www.googleapis.com/auth/datastore',
      ].join(' '),
    };

    // Encode header + payload
    const toBase64Url = (obj: unknown) =>
      btoa(JSON.stringify(obj))
        .replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');

    const signingInput = `${toBase64Url(header)}.${toBase64Url(payload)}`;

    // Import the private key
    const pemBody = sa.privateKey
      .replace('-----BEGIN PRIVATE KEY-----', '')
      .replace('-----END PRIVATE KEY-----', '')
      .replace(/\s/g, '');
    const keyData = Uint8Array.from(atob(pemBody), c => c.charCodeAt(0));

    const cryptoKey = await crypto.subtle.importKey(
      'pkcs8',
      keyData,
      { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
      false,
      ['sign'],
    );

    const signatureBytes = await crypto.subtle.sign(
      'RSASSA-PKCS1-v1_5',
      cryptoKey,
      new TextEncoder().encode(signingInput),
    );

    const signature = btoa(String.fromCharCode(...new Uint8Array(signatureBytes)))
      .replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');

    const jwt = `${signingInput}.${signature}`;

    // Exchange JWT for access token
    const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: jwt,
      }),
    });

    if (!tokenResponse.ok) {
      const err = await tokenResponse.text();
      throw new Error(`Failed to get access token: ${err}`);
    }

    const tokenData = await tokenResponse.json() as { access_token: string };
    return tokenData.access_token;
  }

  // ─── Firestore REST helpers ──────────────────────────────────────────

  export interface FirestoreDocument {
    name: string;
    fields: Record<string, FirestoreValue>;
  }

  export type FirestoreValue =
    | { stringValue: string }
    | { integerValue: string }
    | { booleanValue: boolean }
    | { nullValue: null }
    | { mapValue: { fields: Record<string, FirestoreValue> } }
    | { arrayValue: { values: FirestoreValue[] } };

  export function getStringField(doc: FirestoreDocument, key: string): string | null {
    const field = doc.fields[key];
    return field && 'stringValue' in field ? field.stringValue : null;
  }

  /**
   * Fetches documents from a Firestore collection using the REST API.
   * Returns up to pageSize documents that match the where clause.
   * For MVP: fetches all users with fcmToken field present.
   */
  export async function firestoreQuery(opts: {
    projectId: string;
    collection: string;
    accessToken: string;
    pageSize?: number;
    pageToken?: string;
  }): Promise<{ documents: FirestoreDocument[]; nextPageToken?: string }> {
    const { projectId, collection, accessToken, pageSize = 500, pageToken } = opts;

    const url = new URL(
      `https://firestore.googleapis.com/v1/projects/${projectId}` +
      `/databases/(default)/documents/${collection}`,
    );
    url.searchParams.set('pageSize', String(pageSize));
    if (pageToken) url.searchParams.set('pageToken', pageToken);

    const response = await fetch(url.toString(), {
      headers: { Authorization: `Bearer ${accessToken}` },
    });

    if (!response.ok) {
      const err = await response.text();
      throw new Error(`Firestore query failed: ${err}`);
    }

    const data = await response.json() as {
      documents?: FirestoreDocument[];
      nextPageToken?: string;
    };

    return {
      documents: data.documents ?? [],
      nextPageToken: data.nextPageToken,
    };
  }

  /**
   * Writes a document to Firestore (for logging events).
   */
  export async function firestoreAdd(opts: {
    projectId: string;
    collection: string;
    data: Record<string, FirestoreValue>;
    accessToken: string;
  }): Promise<void> {
    const { projectId, collection, data, accessToken } = opts;
    await fetch(
      `https://firestore.googleapis.com/v1/projects/${projectId}` +
      `/databases/(default)/documents/${collection}`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ fields: data }),
      },
    );
  }

────────────────────────────────────────
  NEW FILE 2 — workers/src/lib/festival-calendar.ts    (NEW)
────────────────────────────────────────

  export interface Festival {
    date: string;      // 'YYYY-MM-DD'
    name: string;
    emoji: string;
    category: 'hindu' | 'muslim' | 'christian' | 'sikh' | 'national';
    targetCategories: string[];  // shop categories that should receive this
    // Empty array means ALL categories receive it
  }

  export const FESTIVALS_2026: Festival[] = [
    // ── January ──────────────────────────────────────────────────────
    { date: '2026-01-14', name: 'Makar Sankranti', emoji: '🪁',
      category: 'hindu',    targetCategories: [] },
    { date: '2026-01-26', name: 'Republic Day',    emoji: '🇮🇳',
      category: 'national', targetCategories: [] },
    // ── March ────────────────────────────────────────────────────────
    { date: '2026-03-20', name: 'Holi',            emoji: '🎨',
      category: 'hindu',    targetCategories: [] },
    { date: '2026-03-31', name: 'Eid ul-Fitr',     emoji: '🌙',
      category: 'muslim',   targetCategories: ['Food', 'Apparel', 'Jewellery'] },
    // ── April ────────────────────────────────────────────────────────
    { date: '2026-04-02', name: 'Ram Navami',      emoji: '🙏',
      category: 'hindu',    targetCategories: [] },
    // ── August ───────────────────────────────────────────────────────
    { date: '2026-08-15', name: 'Independence Day', emoji: '🇮🇳',
      category: 'national', targetCategories: [] },
    { date: '2026-08-20', name: 'Raksha Bandhan',  emoji: '🎀',
      category: 'hindu',    targetCategories: [] },
    { date: '2026-08-29', name: 'Janmashtami',     emoji: '🦚',
      category: 'hindu',    targetCategories: [] },
    // ── September ────────────────────────────────────────────────────
    { date: '2026-09-15', name: 'Onam',            emoji: '🌸',
      category: 'hindu',    targetCategories: [] },
    // ── October ──────────────────────────────────────────────────────
    { date: '2026-10-02', name: 'Gandhi Jayanti',  emoji: '🕊️',
      category: 'national', targetCategories: [] },
    { date: '2026-10-11', name: 'Navratri',        emoji: '💃',
      category: 'hindu',    targetCategories: ['Apparel', 'Jewellery', 'Food'] },
    { date: '2026-10-21', name: 'Dussehra',        emoji: '🏹',
      category: 'hindu',    targetCategories: [] },
    // ── November ─────────────────────────────────────────────────────
    { date: '2026-11-08', name: 'Dhanteras',       emoji: '💰',
      category: 'hindu',    targetCategories: ['Jewellery', 'Electronics', 'General Store'] },
    { date: '2026-11-10', name: 'Diwali',          emoji: '🪔',
      category: 'hindu',    targetCategories: [] },
    { date: '2026-11-11', name: 'Bhai Dooj',       emoji: '🎁',
      category: 'hindu',    targetCategories: [] },
    // ── December ─────────────────────────────────────────────────────
    { date: '2026-12-25', name: 'Christmas',       emoji: '🎄',
      category: 'christian', targetCategories: [] },
    { date: '2026-12-31', name: 'New Year Eve',    emoji: '🎆',
      category: 'national', targetCategories: [] },
  ];

  // Festivals with 2-days-before reminder
  export const MAJOR_FESTIVALS = ['Diwali', 'Holi', 'Eid ul-Fitr', 'Navratri', 'Raksha Bandhan'];

  /**
   * Returns festivals for a given date (YYYY-MM-DD).
   * Also returns any festivals that are exactly 2 days away (for major ones).
   */
  export function getFestivalsForDate(dateStr: string): Array<Festival & { isReminder: boolean }> {
    const results: Array<Festival & { isReminder: boolean }> = [];

    const targetDate = new Date(dateStr);
    const twoDaysLater = new Date(dateStr);
    twoDaysLater.setDate(twoDaysLater.getDate() + 2);
    const twoDaysLaterStr = twoDaysLater.toISOString().split('T')[0];

    for (const festival of FESTIVALS_2026) {
      if (festival.date === dateStr) {
        results.push({ ...festival, isReminder: false });
      } else if (
        festival.date === twoDaysLaterStr &&
        MAJOR_FESTIVALS.includes(festival.name)
      ) {
        results.push({ ...festival, isReminder: true });
      }
    }

    return results;
  }

────────────────────────────────────────
  NEW FILE 3 — workers/src/handlers/send-festival-notifications.ts    (NEW)
────────────────────────────────────────

  import type { Env } from '../types/env';
  import {
    getAccessToken, firestoreQuery, firestoreAdd, getStringField,
    type FirestoreDocument,
  } from '../lib/firebase-admin';
  import { getFestivalsForDate, type Festival } from '../lib/festival-calendar';

  /**
   * Sends festival push notifications to all active users.
   * Called by the Cron Trigger — not a fetch handler.
   */
  export async function sendFestivalNotifications(env: Env): Promise<void> {
    const today = new Date().toISOString().split('T')[0];   // 'YYYY-MM-DD'
    const festivals = getFestivalsForDate(today);

    if (festivals.length === 0) {
      console.log(`[festival-cron] ${today}: no festivals today, skipping`);
      return;
    }

    console.log(`[festival-cron] ${today}: festivals = ${festivals.map(f => f.name).join(', ')}`);

    const sa = {
      projectId:    env.FIREBASE_PROJECT_ID,
      clientEmail:  env.FIREBASE_CLIENT_EMAIL,
      privateKey:   env.FIREBASE_PRIVATE_KEY.replace(/\n/g, '
'),  // unescape 
 from env
    };

    const accessToken = await getAccessToken(sa);

    // Fetch all users with FCM tokens (paginate through all documents)
    const allUsers: FirestoreDocument[] = [];
    let pageToken: string | undefined;

    do {
      const page = await firestoreQuery({
        projectId: sa.projectId,
        collection: 'users',
        accessToken,
        pageSize: 500,
        pageToken,
      });
      allUsers.push(...page.documents);
      pageToken = page.nextPageToken;
    } while (pageToken);

    console.log(`[festival-cron] fetched ${allUsers.length} users`);

    // Send notifications for each festival
    for (const festival of festivals) {
      const { title, body } = buildNotificationCopy(festival);

      const eligibleUsers = filterUsersForFestival(allUsers, festival);
      console.log(`[festival-cron] ${festival.name}: ${eligibleUsers.length} eligible users`);

      let sent = 0;
      let failed = 0;

      // Send in parallel batches of 100
      const BATCH_SIZE = 100;
      for (let i = 0; i < eligibleUsers.length; i += BATCH_SIZE) {
        const batch = eligibleUsers.slice(i, i + BATCH_SIZE);
        const results = await Promise.allSettled(
          batch.map(user => sendFcmMessage({
            accessToken,
            projectId: sa.projectId,
            fcmToken: getStringField(user, 'fcmToken') ?? '',
            title,
            body,
            data: {
              screen:   'studio',
              festival: festival.name,
              deeplink: `dukaanai://studio/festival?name=${encodeURIComponent(festival.name)}`,
            },
          })),
        );

        for (const result of results) {
          if (result.status === 'fulfilled') sent++;
          else { failed++; console.error('[festival-cron] FCM error:', result.reason); }
        }
      }

      // Log stats to Firestore usageEvents
      await firestoreAdd({
        projectId: sa.projectId,
        collection: 'usageEvents',
        accessToken,
        data: {
          eventType:   { stringValue: 'festival_notification_sent' },
          festival:    { stringValue: festival.name },
          date:        { stringValue: today },
          isReminder:  { booleanValue: festival.isReminder },
          sent:        { integerValue: String(sent) },
          failed:      { integerValue: String(failed) },
          total:       { integerValue: String(eligibleUsers.length) },
          createdAt:   { stringValue: new Date().toISOString() },
        },
      });

      console.log(`[festival-cron] ${festival.name}: sent=${sent}, failed=${failed}`);
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  function buildNotificationCopy(festival: Festival & { isReminder: boolean }) {
    if (festival.isReminder) {
      return {
        title: `${festival.emoji} ${festival.name} 2 din baad hai!`,
        body:  `Abhi se ad banao. Competitors se pehle apne customers tak pahuncho!`,
      };
    }
    return {
      title: `${festival.emoji} Aaj hai ${festival.name}!`,
      body:  `Aapke competitors ad post kar rahe hain. 30 seconds mein festive ad banao!`,
    };
  }

  function filterUsersForFestival(
    users: FirestoreDocument[],
    festival: Festival,
  ): FirestoreDocument[] {
    return users.filter(user => {
      const fcmToken = getStringField(user, 'fcmToken');
      if (!fcmToken) return false;                          // skip users with no token

      const tier = getStringField(user, 'tier') ?? 'free';
      if (tier === 'churned') return false;                 // skip churned users

      // Category targeting
      if (festival.targetCategories.length === 0) return true;  // all categories
      const shopCategory = getStringField(user, 'category') ?? '';
      return festival.targetCategories.includes(shopCategory);
    });
  }

  async function sendFcmMessage(opts: {
    accessToken: string;
    projectId: string;
    fcmToken: string;
    title: string;
    body: string;
    data: Record<string, string>;
  }): Promise<void> {
    const { accessToken, projectId, fcmToken, title, body, data } = opts;

    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            token: fcmToken,
            notification: { title, body },
            data,
            android: {
              priority: 'high',
              notification: {
                channel_id: 'festival_alerts',
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                icon: 'ic_notification',
                color: '#FF6F00',  // saffron
              },
            },
          },
        }),
      },
    );

    if (!response.ok) {
      const err = await response.text();
      // Token-not-registered errors are expected and non-fatal; log but don't throw
      if (err.includes('UNREGISTERED') || err.includes('NOT_FOUND')) {
        console.warn(`[festival-cron] stale token removed: ${fcmToken.substring(0, 20)}...`);
        return;
      }
      throw new Error(`FCM send failed: ${err}`);
    }
  }

────────────────────────────────────────
  CHANGE 2 — workers/src/index.ts    (MODIFIED — add scheduled handler)
────────────────────────────────────────

ADD a scheduled export to index.ts alongside the existing fetch export:

  import { sendFestivalNotifications } from './handlers/send-festival-notifications';

  export default {
    async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
      // ... existing fetch handler unchanged ...
    },

    async scheduled(
      controller: ScheduledController,
      env: Env,
      ctx: ExecutionContext,
    ): Promise<void> {
      ctx.waitUntil(sendFestivalNotifications(env));
    },
  };

────────────────────────────────────────
  CHANGE 3 — workers/wrangler.toml    (MODIFIED — add cron trigger)
────────────────────────────────────────

ADD a [triggers] section:

  [triggers]
  crons = ["30 0 * * *"]   # 00:30 UTC = 06:00 IST daily

If [triggers] already exists, just add to the crons array.

────────────────────────────────────────
  NEW FILE 4 — Flutter side: FCM token registration    (MODIFIED — 1 file)
────────────────────────────────────────

Attach: lib/core/services/notification_service.dart (if it exists)
OR attach: lib/main.dart

After app startup (after anonymous/real sign-in), save the FCM token to
Firestore so the cron worker can fetch it:

  // In NotificationService.init() or main.dart after auth:
  final fcmToken = await FirebaseMessaging.instance.getToken();
  final userId = FirebaseService.currentUserId;
  if (fcmToken != null && userId != null) {
    await FirebaseService.db.collection('users').doc(userId).set(
      { 'fcmToken': fcmToken },
      SetOptions(merge: true),       // don't overwrite other fields
    );
  }

  // Subscribe to token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    final uid = FirebaseService.currentUserId;
    if (uid != null) {
      await FirebaseService.db.collection('users').doc(uid).set(
        { 'fcmToken': newToken },
        SetOptions(merge: true),
      );
    }
  });

Create lib/core/services/notification_service.dart as a class with:
  static Future<void> init() — calls the above logic
  Called from main.dart after Firebase init + sign-in

────────────────────────────────────────
  NEW FILE 5 — Worker Tests
  workers/src/__tests__/festival-notifications.test.ts    (NEW)
────────────────────────────────────────

Write 5 unit tests covering:

TEST 1: getFestivalsForDate returns empty for non-festival day
  - input: '2026-06-15' (no festival)
  - expect: result.length === 0

TEST 2: getFestivalsForDate returns festival on festival day
  - input: '2026-11-10' (Diwali)
  - expect: result[0].name === 'Diwali', isReminder === false

TEST 3: getFestivalsForDate returns 2-day reminder for major festival
  - input: '2026-11-08' (2 days before Diwali on 2026-11-10)
  - expect: result includes { name: 'Diwali', isReminder: true }

TEST 4: filterUsersForFestival skips users without fcmToken
  - Build mock Firestore documents: one with fcmToken, one without
  - A general festival (targetCategories: [])
  - expect: only user with fcmToken in result

TEST 5: filterUsersForFestival respects category targeting
  - Festival targetCategories: ['Jewellery', 'Food']
  - Users: category 'Jewellery', category 'Electronics', no category
  - expect: only 'Jewellery' user in result

Use vitest. Mock all fetch calls. No real Firebase calls in tests.

────────────────────────────────────────
  OUTPUT ORDER (6 files)
────────────────────────────────────────

NEW (4 files):
  1. workers/src/lib/firebase-admin.ts
  2. workers/src/lib/festival-calendar.ts
  3. workers/src/handlers/send-festival-notifications.ts
  4. workers/src/__tests__/festival-notifications.test.ts

MODIFIED (2 files):
  5. workers/src/index.ts        (add scheduled export)
  6. workers/wrangler.toml       (add cron trigger)

Flutter addition (1 file — separate paste after Worker session):
  7. lib/core/services/notification_service.dart

────────────────────────────────────────
  DO NOT
────────────────────────────────────────

✗ DO NOT use legacy FCM server key (FCMSERVERKEY) — use HTTP v1 API only
✗ DO NOT use SUPABASE_URL or SUPABASE_SERVICE_KEY — use Firestore REST API
✗ DO NOT use firebase-admin npm package — not compatible with Cloudflare Workers
  (use the manual JWT + REST approach defined above)
✗ DO NOT hardcode FCM tokens — always fetch from Firestore
✗ DO NOT throw on UNREGISTERED token errors — log and continue (non-fatal)
✗ DO NOT add FIREBASE_PRIVATE_KEY to wrangler.toml — use wrangler secret only
✗ DO NOT send more than 500 users per batch — FCM HTTP v1 has per-project quotas
✗ DO NOT change any existing fetch handlers
```

---

## VALIDATION CHECKLIST

```powershell
# Workers
cd workers
npm test
# Expected: 5/5 festival tests pass + all existing tests pass

# Test cron locally (Wrangler supports scheduled testing):
npx wrangler dev --test-scheduled
# In another terminal:
curl "http://localhost:8787/__scheduled?cron=30+0+*+*+*"
# Expected log: "[festival-cron] fetched N users" or "no festivals today"

# Flutter
flutter test
# Expected: all tests pass

# Emulator
flutter run -d emulator-5554 --dart-define=SKIP_AUTH=true
# After fixing Anonymous Auth in Firebase Console:
# Both screens should show empty state (not error state)
```

---

## WHAT COMES NEXT — TASK 2.5 (Week 3 begins)

> **Task 3.1 — Pricing Screen + Razorpay UPI Integration**
> The monetization screen. `PricingScreen` with 4 subscription tiers + Ad Pack
> one-time purchases. `PaymentService` using `razorpay_flutter` SDK.
> Cloudflare Workers: `POST /api/create-order` and `POST /api/verify-payment`
> with HMAC-SHA256 Razorpay signature verification. On payment success:
> update user `tier` and `creditsRemaining` in Firestore via Worker
> (not from Flutter client — prevents tampering). Credits: Free=5,
> Dukaan=50, Vyapaar=150, Utsav=99999.

---

*Dukaan AI v1.0 Build Playbook · Task 2.4 (Festival Notifications) · April 2026*
