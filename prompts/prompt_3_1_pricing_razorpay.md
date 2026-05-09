# TASK 3.1 — Pricing Screen + Razorpay Integration
### Dukaan AI · Week 3 Begins · Flutter + Worker

---

## OUTSTANDING ISSUES — Fix These Before Task 3.1

### Issue 1 — vitest Not Found (Terminal Fix)

```powershell
cd C:\dev\smb_ai\workers
npm install                   # installs vitest + all worker deps
npm test                      # Expected: all tests pass
```

`npm install` was never run in the workers directory after the project was
cloned/created, so `node_modules` is empty and `vitest` is not on PATH.
This is not a code change — just run the command.

---

### Issue 2 — SKIP_AUTH Dev Mode: Error Screens (Code Fix)

The anonymous sign-in is failing because Firebase Authentication service
is NOT enabled in the Firebase Console. This requires ONE manual step:

```
Firebase Console (console.firebase.google.com)
  → Select project "dukaan-ai" (or your project name)
  → Left sidebar: Build → Authentication
  → You will see "Get started" button → CLICK IT
  → This activates the Authentication service for your project
  → Click the "Sign-in method" tab (top tab in Authentication)
  → Scroll to find "Anonymous" in the list
  → Click it → Toggle the ENABLE switch ON → Save
  ✓ The Anonymous row should now show a green "Enabled" status
```

WHILE THAT STEP IS PENDING, apply this code-level fallback so screens
show empty state instead of error state in SKIP_AUTH mode:

**Paste-Ask: Attach `lib/features/studio/infrastructure/studio_repository_impl.dart`
AND `lib/features/khata/infrastructure/khata_repository_impl.dart`, paste:**

```
Problem: When SKIP_AUTH=true and Firebase anonymous sign-in fails,
FirebaseService.currentUserId returns null. All Firestore queries
throw PERMISSION_DENIED → providers get error state → screens show
"Kuch gadbad ho gayi" instead of the correct empty state.

FIX: Add a null-user guard at the TOP of every Stream/Future Firestore
call in both repositories.

In khata_repository_impl.dart — watchEntries() method:
  @override
  Stream<List<KhataEntry>> watchEntries({required String? userId}) async* {
    // SKIP_AUTH guard: no user → return empty stream (don't error)
    if (userId == null) {
      yield [];
      return;
    }
    // ... rest of existing Firestore stream logic unchanged
  }

Apply the SAME guard to every public method that accepts a userId
in BOTH files:
  - watchEntries / watchAds (Stream methods): yield []; return;
  - addEntry / updateEntry / deleteEntry / saveAd (Future methods):
      if (userId == null) return;   // or return null / throw if caller expects it

IMPORTANT: Do NOT change the method signatures. Do NOT add any new
files. Just add the guard at the top of each method body.
Output both modified files.
```

After this paste-ask: Studio and Khata will show the correct empty-state
UI ("Abhi koi ad nahi!" / "Koi udhaar nahi!") in SKIP_AUTH mode even
before Firebase Auth is fully configured.

---

## TASK 3.1 — PRICING SCREEN + RAZORPAY UPI INTEGRATION

### One-Sentence Summary
A conversion-optimized paywall screen showing 4 subscription plans + 3
one-time ad packs, with a Razorpay UPI checkout flow that completes
in-app and updates the user's Firestore `tier` + `creditsRemaining`
via a verified Cloudflare Worker webhook — not from the client.

---

### Paste Into Copilot Chat (Kavya Agent — New Session)

**Attach these files:**

| # | File | Why |
|---|---|---|
| 1 | `copilot-instructions.md` | Global rules |
| 2 | `flutter.instructions.md` | Screen patterns |
| 3 | `SKILL.md` → *design-system* | Colors, spacing, widget patterns |
| 4 | `SKILL.md` → *testing-patterns* | Widget test structure |
| 5 | `SKILL.md` → *payment-credit* | Plan definitions, credit rules |
| 6 | `lib/core/constants/app_routes.dart` | ACTUAL — add route constant |
| 7 | `lib/core/router/app_router.dart` | ACTUAL — add route |
| 8 | `lib/core/constants/app_strings.dart` | ACTUAL — add strings |
| 9 | `lib/core/services/firebase_service.dart` | ACTUAL — user tier reads |

```
════════════════════════════════════════════════════════
  TASK 3.1 — PricingScreen + PaymentService
  Week 3 · Monetization · Flutter + Cloudflare Workers
════════════════════════════════════════════════════════

CONTEXT:
PricingScreen is accessible from two entry points:
  1. Account tab → "Plan upgrade karo" card
  2. Any screen where credits run out → CreditGuard shows bottom sheet
     with "Monthly plan lo" button → context.push(AppRoutes.pricing)

Firebase note: User tier + credits come from Firestore
  users/{userId} document fields: tier (String), creditsRemaining (int)
No Supabase anywhere.

────────────────────────────────────────
  PLAN + PACK DATA (hardcoded constants — no API call)
────────────────────────────────────────

  // In a new file: lib/features/account/domain/pricing_plans.dart

  enum PlanTier { free, dukaan, vyapaar, utsav }

  class Plan {
    final PlanTier tier;
    final String name;
    final String price;         // Display: '₹0', '₹99/mo', etc.
    final int amountPaise;      // Razorpay: 0, 9900, 24900, 49900
    final int adsPerMonth;      // 5, 50, 150, 999999 (unlimited)
    final List<String> features;
    final bool isMostPopular;
    final bool isHighlighted;   // border + badge
  }

  static const List<Plan> kPlans = [
    Plan(
      tier: PlanTier.free,
      name: 'Free',
      price: '₹0',
      amountPaise: 0,
      adsPerMonth: 5,
      features: [
        '5 ads/month',
        'Basic backgrounds only',
        'Watermark on ads',
        'Caption generator',
      ],
      isMostPopular: false,
      isHighlighted: false,
    ),
    Plan(
      tier: PlanTier.dukaan,
      name: 'Dukaan',
      price: '₹99/mo',
      amountPaise: 9900,
      adsPerMonth: 50,
      features: [
        '50 ads/month',
        'All backgrounds',
        'No watermark',
        'Caption generator',
        'Khata ledger',
      ],
      isMostPopular: false,
      isHighlighted: false,
    ),
    Plan(
      tier: PlanTier.vyapaar,
      name: 'Vyapaar',
      price: '₹249/mo',
      amountPaise: 24900,
      adsPerMonth: 150,
      features: [
        '150 ads/month',
        'All Dukaan features',
        'WhatsApp Broadcast',
        'Festival theme presets',
        'Priority processing',
      ],
      isMostPopular: true,
      isHighlighted: true,
    ),
    Plan(
      tier: PlanTier.utsav,
      name: 'Utsav',
      price: '₹499/mo',
      amountPaise: 49900,
      adsPerMonth: 999999,
      features: [
        'Unlimited ads',
        'All Vyapaar features',
        'API access (Phase 2)',
        'Priority support',
        'Analytics dashboard',
      ],
      isMostPopular: false,
      isHighlighted: false,
    ),
  ];

  class AdPack {
    final String id;
    final String name;
    final String price;
    final int amountPaise;
    final int creditsGranted;
    final String badge;           // Empty string if none
    final bool isRecommended;
  }

  static const List<AdPack> kAdPacks = [
    AdPack(
      id: 'starter_pack',
      name: 'Starter Pack',
      price: '₹29',
      amountPaise: 2900,
      creditsGranted: 10,
      badge: '',
      isRecommended: false,
    ),
    AdPack(
      id: 'value_pack',
      name: 'Value Pack',
      price: '₹99',
      amountPaise: 9900,
      creditsGranted: 50,
      badge: 'Best Value',
      isRecommended: true,
    ),
    AdPack(
      id: 'festival_pack',
      name: 'Festival Pack',
      price: '₹199',
      amountPaise: 19900,
      creditsGranted: -1,          // -1 = unlimited (7-day window)
      badge: '7 din unlimited',
      isRecommended: false,
    ),
  ];

────────────────────────────────────────
  NEW FILE 1 — lib/features/account/domain/pricing_plans.dart    (NEW)
────────────────────────────────────────

Contains: PlanTier enum, Plan class, AdPack class, kPlans list, kAdPacks list.
All classes must be const-constructable (immutable). No freezed needed.

────────────────────────────────────────
  NEW FILE 2 — lib/features/account/application/payment_service.dart    (NEW)
────────────────────────────────────────

Class: PaymentService
Dependency: CloudflareClient (existing), FirebaseService (existing)

Methods:

  Future<PaymentResult> initiatePayment({
    required String planId,        // e.g. 'vyapaar' or 'value_pack'
    required int amountPaise,      // 0 skips Razorpay entirely (free plan)
    required String userId,
  })

Implementation:

  sealed class PaymentResult {
    const factory PaymentResult.success({ required String transactionId }) = _Success;
    const factory PaymentResult.failure({ required String message }) = _Failure;
    const factory PaymentResult.cancelled() = _Cancelled;
  }

  Future<PaymentResult> initiatePayment({...}) async {
    if (amountPaise == 0) {
      // Free plan: no payment needed, just update Firestore
      await _updateTierInFirestore(userId: userId, planId: planId, creditsAdded: 5);
      return const PaymentResult.success(transactionId: 'free');
    }

    // Step 1: Create Razorpay order via Worker
    final orderResponse = await _cloudflareClient.post(
      '/api/create-order',
      body: { 'planId': planId, 'amountPaise': amountPaise, 'userId': userId },
    );
    final orderId = orderResponse['orderId'] as String;

    // Step 2: Open Razorpay checkout
    final Razorpay razorpay = Razorpay();
    final completer = Completer<PaymentResult>();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) async {
      // Step 3: Verify payment via Worker (Worker updates Firestore — never client-side)
      try {
        final verifyResponse = await _cloudflareClient.post(
          '/api/verify-payment',
          body: {
            'razorpayPaymentId': response.paymentId,
            'razorpayOrderId': response.orderId,
            'razorpaySignature': response.signature,
            'userId': userId,
            'planId': planId,
          },
        );
        if (verifyResponse['success'] == true) {
          completer.complete(PaymentResult.success(transactionId: response.paymentId ?? ''));
        } else {
          completer.complete(const PaymentResult.failure(message: 'Payment verify nahi hua.'));
        }
      } catch (e) {
        completer.complete(const PaymentResult.failure(message: 'Network error. Support se sampark karein.'));
      }
      razorpay.clear();
    });

    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
      razorpay.clear();
      completer.complete(PaymentResult.failure(
        message: _razorpayErrorMessage(response.code),
      ));
    });

    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse response) {
      razorpay.clear();
      completer.complete(const PaymentResult.cancelled());
    });

    // Open checkout
    razorpay.open({
      'key': const String.fromEnvironment('RAZORPAY_KEY_ID'),
      'amount': amountPaise,
      'order_id': orderId,
      'name': 'Dukaan AI',
      'description': planId,
      'prefill': {
        'contact': FirebaseService.currentUserPhone ?? '',
        'email': '',
        'name': '',
      },
      'theme': {'color': '#FF6F00'},
      'method': {
        'upi': true,
        'card': true,
        'netbanking': true,
        'wallet': true,
      },
    });

    return completer.future;
  }

  // Hinglish error messages for Razorpay error codes
  String _razorpayErrorMessage(int? code) {
    switch (code) {
      case Razorpay.NETWORK_ERROR:
        return 'Internet nahi hai. Dobara try karein.';
      case Razorpay.INVALID_OPTIONS:
        return 'Payment setup mein gadbad. Team ko batao.';
      case Razorpay.PAYMENT_CANCELLED:
        return 'Payment cancel kar diya.';
      default:
        return 'Payment nahi ho paya. Dobara try karein.';
    }
  }

────────────────────────────────────────
  NEW FILE 3 — lib/features/account/presentation/screens/pricing_screen.dart    (NEW)
────────────────────────────────────────

WIDGET TYPE: ConsumerStatefulWidget
ROUTE: /account/pricing

STATE:
  bool _showPlans = true         // toggle: true=Monthly Plans, false=Ad Packs
  bool _isLoading = false        // loading overlay during payment
  PlanTier? _currentTier         // loaded from Firestore via provider

LAYOUT (Scaffold, no bottom nav):

  ── AppBar ──────────────────────────────────────────────────────────
  title: "Plan choose karo"
  backgroundColor: Colors.white, elevation: 0
  leading: back button

  ── Body: SingleChildScrollView ─────────────────────────────────────

  SECTION 1: Plan Toggle
    Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,   // light grey bg
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row of 2 AnimatedContainer toggle buttons:
        "Monthly Plans" | "Ad Packs (One-time)"
        Selected: orange background, white text
        Unselected: transparent, grey text
    )
    onTap any toggle → setState(_showPlans = !_showPlans)

  ── IF _showPlans == true ────────────────────────────────────────────

  SECTION 2: Monthly Plan Cards (Column, NOT scrollable — fits on screen)

    For each plan in kPlans:
      _PlanCard(
        plan: plan,
        isCurrentPlan: plan.tier == _currentTier,
        onSelect: () => _handlePlanTap(plan),
      )

  _PlanCard layout:
    Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: plan.isHighlighted
          ? Border.all(color: AppColors.primary, width: 2)
          : Border.all(color: AppColors.borderLight, width: 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: plan.isHighlighted ? [/* orange shadow */] : [],
      ),
      child: Column:
        if plan.isMostPopular:
          Container (full width, orange bg, rounded top):
            Text("⭐ Most Popular", 13sp white bold centered, padding 6dp vertical)
        Padding(16dp):
          Row: [plan.name 18sp bold] [Spacer] [plan.price 20sp bold orange]
          SizedBox(height: 4)
          Text("${plan.adsPerMonth == 999999 ? 'Unlimited' : plan.adsPerMonth} ads/month",
               13sp grey)
          SizedBox(height: 12)
          for feature in plan.features:
            Row: [Icon(Icons.check_circle, 16dp, green)] [8dp] [Text(feature, 13sp)]
            SizedBox(height: 4)
          SizedBox(height: 12)
          if isCurrentPlan:
            Container(full width, grey bg, rounded 10dp):
              Text("✓ Current Plan", 14sp medium, grey, centered, padding 12dp)
          else if plan.tier == PlanTier.free:
            // No button for free downgrade — show nothing or disabled
            SizedBox.shrink()
          else:
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: orange bg, white text, rounded 10dp, height 44dp
                onPressed: () => _handlePlanTap(plan)
                child: Text("Yeh plan lo — ${plan.price}")
              )
            )
    )

  ── IF _showPlans == false ───────────────────────────────────────────

  SECTION 3: Ad Pack Cards (Column of 3)

    For each pack in kAdPacks:
      _AdPackCard(pack: pack, onBuy: () => _handlePackTap(pack))

  _AdPackCard layout:
    Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: white card, orange border if isRecommended else grey border
      child: Padding(16dp):
        Row:
          Column (Expanded):
            Text(pack.name, 16sp bold)
            SizedBox(height: 4)
            if pack.badge.isNotEmpty:
              Container(orange bg, rounded 4dp): Text(pack.badge, 11sp white, padding 4x8)
            SizedBox(height: 8)
            Text(pack.creditsGranted == -1
              ? "7 din unlimited ads"
              : "${pack.creditsGranted} ad credits",
              13sp grey)
          Column:
            Text(pack.price, 22sp bold orange)
            SizedBox(height: 8)
            ElevatedButton(
              style: compact, orange, padding 8x20
              onPressed: () => _handlePackTap(pack)
              child: Text("Kharido")
            )
    )

  ── FOOTER: Trust Indicators ─────────────────────────────────────────

  Container(
    margin: EdgeInsets.all(16),
    padding: EdgeInsets.all(12),
    decoration: light grey rounded border
    child: Row (evenly spaced, center):
      _TrustBadge(icon: Icons.lock, text: "Razorpay
Secured")
      _TrustBadge(icon: Icons.support_agent, text: "24/7
Support")
      _TrustBadge(icon: Icons.replay_outlined, text: "7-din
Refund")
  )
  SizedBox(height: 32)

  ── Loading Overlay ────────────────────────────────────────────────
  if _isLoading:
    Positioned.fill → AbsorbPointer → Container(black 60% opacity):
      Center: CircularProgressIndicator(orange) +
              Text("Payment process ho raha hai...", white)

────────────────────────────────────────
  Payment tap handlers
────────────────────────────────────────

  Future<void> _handlePlanTap(Plan plan) async {
    if (plan.amountPaise == 0) {
      // Free plan selected — shouldn't normally be tappable
      // (Current plan button is hidden for free tier)
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await ref.read(paymentServiceProvider).initiatePayment(
        planId: plan.tier.name,
        amountPaise: plan.amountPaise,
        userId: FirebaseService.currentUserId ?? '',
      );
      if (!mounted) return;
      switch (result) {
        case _Success(:final transactionId):
          _showSuccessSheet(plan.name, transactionId);
        case _Failure(:final message):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        case _Cancelled():
          // User cancelled — do nothing
          break;
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessSheet(String planName, String transactionId) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text("$planName plan active ho gaya! 🎉",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text("Transaction ID: $transactionId",
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);  // close sheet
                  context.pop();           // back to account
                },
                child: const Text("Shukriya! Studio mein chale jao"),
              ),
            ),
          ]),
        ),
      ),
    );
  }

────────────────────────────────────────
  NEW FILE 4 — Provider + Route wiring
────────────────────────────────────────

  // In lib/features/account/application/payment_service.dart
  // Add at the bottom:

  @riverpod
  PaymentService paymentService(PaymentServiceRef ref) {
    return PaymentService(
      cloudflareClient: ref.watch(cloudflareClientProvider),
    );
  }

  // In lib/core/constants/app_routes.dart:
  static const pricing = '/account/pricing';

  // In lib/core/router/app_router.dart, under Account branch:
  GoRoute(
    path: AppRoutes.pricing,
    name: 'pricing',
    builder: (context, state) => const PricingScreen(),
  ),

────────────────────────────────────────
  NEW FILE 5 — Cloudflare Worker: POST /api/create-order
  workers/src/handlers/create_order.ts    (NEW)
────────────────────────────────────────

  import type { Env } from '../types/env';
  import { extractAndVerifyToken } from '../middleware/auth';

  export async function handleCreateOrder(
    request: Request,
    env: Env,
  ): Promise<Response> {
    const auth = await extractAndVerifyToken(request, env);
    if (!auth.ok) return auth.errorResponse!;

    const { planId, amountPaise, userId } = await request.json() as {
      planId: string;
      amountPaise: number;
      userId: string;
    };

    if (!planId || !amountPaise || !userId) {
      return Response.json({ error: 'Missing required fields' }, { status: 400 });
    }

    // Create order with Razorpay API
    const credentials = btoa(`${env.RAZORPAY_KEY_ID}:${env.RAZORPAY_SECRET}`);
    const receipt = `order_${userId.substring(0, 8)}_${Date.now()}`;

    const razorpayResponse = await fetch('https://api.razorpay.com/v1/orders', {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${credentials}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        amount: amountPaise,
        currency: 'INR',
        receipt,
        notes: { userId, planId },
      }),
    });

    if (!razorpayResponse.ok) {
      const err = await razorpayResponse.text();
      console.error('[create-order] Razorpay error:', err);
      return Response.json(
        { error: 'Order create nahi hua. Dobara try karein.' },
        { status: 502 },
      );
    }

    const order = await razorpayResponse.json() as { id: string; amount: number };

    // Log pending transaction to Firestore
    const accessToken = await getFirebaseAccessToken(env);   // from firebase-admin.ts
    await firestoreAdd({
      projectId: env.FIREBASE_PROJECT_ID,
      collection: 'transactions',
      accessToken,
      data: {
        userId:         { stringValue: userId },
        planId:         { stringValue: planId },
        orderId:        { stringValue: order.id },
        amountPaise:    { integerValue: String(amountPaise) },
        status:         { stringValue: 'pending' },
        createdAt:      { stringValue: new Date().toISOString() },
      },
    });

    return Response.json({ orderId: order.id, amount: order.amount });
  }

────────────────────────────────────────
  NEW FILE 6 — Cloudflare Worker: POST /api/verify-payment
  workers/src/handlers/verify_payment.ts    (NEW)
────────────────────────────────────────

  export async function handleVerifyPayment(
    request: Request,
    env: Env,
  ): Promise<Response> {
    const auth = await extractAndVerifyToken(request, env);
    if (!auth.ok) return auth.errorResponse!;

    const { razorpayPaymentId, razorpayOrderId, razorpaySignature, userId, planId } =
      await request.json() as Record<string, string>;

    // Verify HMAC-SHA256 signature — NEVER trust client for this
    const message = `${razorpayOrderId}|${razorpayPaymentId}`;
    const encoder = new TextEncoder();
    const keyData = encoder.encode(env.RAZORPAY_SECRET);
    const messageData = encoder.encode(message);

    const cryptoKey = await crypto.subtle.importKey(
      'raw', keyData,
      { name: 'HMAC', hash: 'SHA-256' },
      false, ['sign'],
    );
    const signatureBuffer = await crypto.subtle.sign('HMAC', cryptoKey, messageData);
    const expectedSignature = Array.from(new Uint8Array(signatureBuffer))
      .map(b => b.toString(16).padStart(2, '0'))
      .join('');

    if (expectedSignature !== razorpaySignature) {
      console.error('[verify-payment] Signature mismatch!');
      return Response.json({ error: 'Payment verify nahi hua.' }, { status: 400 });
    }

    // Determine credits to add based on plan
    const CREDIT_MAP: Record<string, number> = {
      free: 5, dukaan: 50, vyapaar: 150, utsav: 999999,
      starter_pack: 10, value_pack: 50, festival_pack: 999999,
    };
    const creditsAdded = CREDIT_MAP[planId] ?? 10;
    const isSubscription = ['dukaan', 'vyapaar', 'utsav', 'free'].includes(planId);

    const accessToken = await getFirebaseAccessToken(env);

    // Update user document in Firestore
    const userRef = `projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents/users/${userId}`;
    await fetch(
      `https://firestore.googleapis.com/v1/${userRef}?updateMask.fieldPaths=tier&updateMask.fieldPaths=creditsRemaining`,
      {
        method: 'PATCH',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          fields: {
            ...(isSubscription ? { tier: { stringValue: planId } } : {}),
            creditsRemaining: { integerValue: String(creditsAdded) },
          },
        }),
      },
    );

    // Update transaction status
    // (query for the pending transaction by orderId and update status to success)
    // Simplified: add a new success doc (full query is in Task 3.3 scope)
    await firestoreAdd({
      projectId: env.FIREBASE_PROJECT_ID,
      collection: 'transactions',
      accessToken,
      data: {
        userId:           { stringValue: userId },
        planId:           { stringValue: planId },
        razorpayPaymentId:{ stringValue: razorpayPaymentId },
        orderId:          { stringValue: razorpayOrderId },
        status:           { stringValue: 'success' },
        creditsAdded:     { integerValue: String(creditsAdded) },
        verifiedAt:       { stringValue: new Date().toISOString() },
      },
    });

    console.log(`[verify-payment] Payment verified: userId=${userId} plan=${planId} credits=${creditsAdded}`);

    return Response.json({ success: true, newTier: isSubscription ? planId : undefined, creditsAdded });
  }

────────────────────────────────────────
  CHANGE — workers/src/index.ts    (MODIFIED)
────────────────────────────────────────

  ADD routes for the two new handlers in the fetch handler's router:

    case '/api/create-order':
      if (request.method === 'POST') return handleCreateOrder(request, env);
      break;
    case '/api/verify-payment':
      if (request.method === 'POST') return handleVerifyPayment(request, env);
      break;

────────────────────────────────────────
  CHANGE — workers/src/types/env.ts    (MODIFIED — add Razorpay vars)
────────────────────────────────────────

  ADD to Env interface:
    RAZORPAY_KEY_ID: string;     // rzp_live_... or rzp_test_...
    RAZORPAY_SECRET: string;     // from Razorpay Dashboard → API Keys

  Store as Cloudflare secrets:
    wrangler secret put RAZORPAY_KEY_ID
    wrangler secret put RAZORPAY_SECRET
  For local dev: add to workers/.dev.vars

────────────────────────────────────────
  CHANGE — pubspec.yaml    (ADD razorpay_flutter)
────────────────────────────────────────

  ADD to dependencies:
    razorpay_flutter: ^1.3.6

  This is the ONLY pubspec.yaml change in this task.
  Run: flutter pub get

────────────────────────────────────────
  NEW FILE 7 — Strings
  lib/core/constants/app_strings.dart    (MODIFIED — add pricing strings)
────────────────────────────────────────

  ADD:
  // Pricing Screen
  static const pricingTitle              = 'Plan choose karo';
  static const monthlyPlansTab           = 'Monthly Plans';
  static const adPacksTab                = 'Ad Packs (One-time)';
  static const mostPopularBadge          = '⭐ Most Popular';
  static const currentPlanLabel          = '✓ Current Plan';
  static const selectPlanPrefix          = 'Yeh plan lo — ';
  static const buyPackButton             = 'Kharido';
  static const paymentInProgress         = 'Payment process ho raha hai...';
  static const paymentSuccessTitle       = 'plan active ho gaya! 🎉';
  static const paymentSuccessCta         = 'Shukriya! Studio mein chale jao';
  static const trustRazorpay             = 'Razorpay
Secured';
  static const trustSupport              = '24/7
Support';
  static const trustRefund               = '7-din
Refund';
  static const transactionIdPrefix       = 'Transaction ID: ';
  static const adsPerMonthSuffix         = ' ads/month';
  static const unlimitedAds             = 'Unlimited ads/month';
  static const sevenDayUnlimited        = '7 din unlimited ads';
  static const adCredits                = ' ad credits';

────────────────────────────────────────
  NEW FILE 8 — Widget Tests
  test/features/account/presentation/screens/pricing_screen_test.dart    (NEW)
────────────────────────────────────────

Write 6 widget tests:

TEST 1: renders all 4 plan cards in Monthly Plans view
  - Pump PricingScreen with currentTier mocked as PlanTier.free
  - Verify find.text('Free') findsOneWidget
  - Verify find.text('Dukaan') findsOneWidget
  - Verify find.text('Vyapaar') findsOneWidget
  - Verify find.text('Utsav') findsOneWidget

TEST 2: Vyapaar card shows Most Popular badge
  - Pump PricingScreen
  - Verify find.text(AppStrings.mostPopularBadge) findsOneWidget

TEST 3: current plan shows "Current Plan" label, not a buy button
  - Pump PricingScreen with currentTier = PlanTier.dukaan
  - Verify find.text(AppStrings.currentPlanLabel) findsOneWidget
  - Verify find.text('Yeh plan lo — ₹99/mo') findsNothing (button hidden)

TEST 4: toggle switches to Ad Packs view
  - Pump PricingScreen
  - Tap find.text(AppStrings.adPacksTab) button
  - pumpAndSettle()
  - Verify find.text('Starter Pack') findsOneWidget
  - Verify find.text('Value Pack') findsOneWidget
  - Verify find.text('Festival Pack') findsOneWidget

TEST 5: tapping Buy Now shows loading overlay
  - Pump PricingScreen with mocked paymentService that never completes
    (use Completer<PaymentResult>() that never completes)
  - Tap 'Yeh plan lo — ₹249/mo' (Vyapaar)
  - pump() → verify find.text(AppStrings.paymentInProgress) findsOneWidget

TEST 6: successful payment shows success bottom sheet
  - Pump PricingScreen with paymentService mock returning PaymentResult.success(transactionId: 'pay_test123')
  - Tap Vyapaar plan button
  - pumpAndSettle()
  - Verify find.text('Vyapaar plan active ho gaya! 🎉') findsOneWidget
  - Verify find.text('Transaction ID: pay_test123') findsOneWidget

────────────────────────────────────────
  OUTPUT ORDER (10 files)
────────────────────────────────────────

NEW (7 files):
  1. lib/features/account/domain/pricing_plans.dart
  2. lib/features/account/application/payment_service.dart
  3. lib/features/account/presentation/screens/pricing_screen.dart
  4. workers/src/handlers/create_order.ts
  5. workers/src/handlers/verify_payment.ts
  6. test/features/account/presentation/screens/pricing_screen_test.dart

MODIFIED (4 files):
  7. lib/core/constants/app_routes.dart     (add pricing route constant)
  8. lib/core/router/app_router.dart        (add pricing route under account)
  9. lib/core/constants/app_strings.dart    (add pricing strings)
  10. workers/src/index.ts                  (add 2 new routes)
  11. workers/src/types/env.ts              (add Razorpay env vars)
  12. pubspec.yaml                          (add razorpay_flutter: ^1.3.6)

────────────────────────────────────────
  DO NOT
────────────────────────────────────────

✗ DO NOT update Firestore user tier from Flutter client — only the Worker
  verifies signatures and writes to Firestore
✗ DO NOT use Supabase anywhere — all data is Firebase/Firestore
✗ DO NOT hardcode Razorpay key in Dart — use String.fromEnvironment('RAZORPAY_KEY_ID')
✗ DO NOT allow downgrade to Free plan via the button — button hidden when it's current plan
✗ DO NOT call flutter pub get or build_runner after changes — just add to pubspec.yaml
✗ DO NOT store card numbers or banking details — Razorpay handles PCI-DSS compliance
✗ DO NOT add a new bottom nav tab — PricingScreen is a pushed route under Account
```

---

## VALIDATION CHECKLIST

```powershell
# 1. Workers
cd workers
npm install               # fixes vitest
npm test
# Expected: all tests pass (new create-order + verify-payment + existing)

# 2. Flutter
flutter pub get           # for razorpay_flutter
flutter analyze           # Expected: No issues found!
flutter test test/features/account/presentation/screens/pricing_screen_test.dart
# Expected: 6/6 pass

flutter test
# Expected: all tests pass

# 3. Razorpay test mode
# Add to workers/.dev.vars:
#   RAZORPAY_KEY_ID=rzp_test_xxx   (from Razorpay Dashboard → Test Keys)
#   RAZORPAY_SECRET=xxx

# 4. Emulator (after Firebase Auth Anonymous enabled)
flutter run -d emulator-5554 --dart-define=SKIP_AUTH=true --dart-define=RAZORPAY_KEY_ID=rzp_test_xxx
# Navigate: Account tab → "Plan upgrade karo" → PricingScreen
# Toggle between Monthly Plans and Ad Packs
# Tap Vyapaar plan → Razorpay test checkout opens
```

---

## WHAT COMES NEXT — TASK 3.2

> **Task 3.2 — CreditGuard + My Ads Gallery**
> Two complementary features:
> (1) `CreditGuard` service that checks `creditsRemaining` from Firestore
> before every ad generation attempt and shows an upgrade bottom sheet if
> credits are at 0. Calls `decrementCredits` on success.
> (2) My Ads Gallery screen (the Tab 2 grid icon in bottom nav) —
> `ListView.builder` grid of all `generatedAds` where `userId == currentUser`,
> each card with thumbnail, date, share + download actions, Firestore
> cursor-based pagination (10 at a time), shimmer loading state, and
> proper empty state. Both features use Firestore exclusively.

---

*Dukaan AI v1.0 Build Playbook · Task 3.1 (Pricing + Razorpay) · April 2026*
