# PROMPT 1.1 — Project Scaffold & Folder Structure
### Dukaan AI · Copilot Chat Prompt · Expanded Edition

---

## STEP 0 — ATTACH THESE FILES FIRST (Before Pasting the Prompt)

Use the `#` file picker in Copilot Chat to attach every file below.
Each file activates a different layer of project intelligence.

| # | File to Attach | Type | Why It's Needed |
|---|---|---|---|
| 1 | `copilot-instructions.md` | Global Instructions | Anti-hallucination contract, folder conventions, absolute rules, model guidance |
| 2 | `flutter.instructions.md` | Flutter Instructions | Widget patterns, Riverpod rules, GoRouter rules, design token enforcement |
| 3 | `SKILL.md` → *flutter-design-system* | Skill | Exact AppColors, AppSpacing, AppTypography, AppRadius, AppShadows token values |
| 4 | `SKILL.md` → *riverpod-patterns* | Skill | AsyncNotifier structure, supabaseClientProvider pattern, authStateProvider stream |
| 5 | `SKILL.md` → *supabase-schema* | Skill | SupabaseTables constants, SupabaseColumns constants, singleton access pattern |
| 6 | `new-feature.prompt.md` | Prompt | Build order: domain → infra → providers → screens → router (enforces sequence) |

### Agent Selection
> **No agent for Task 1.1.** This is pure architecture scaffolding — no UI building (Kavya)
> and no Workers building (Dev). Both agents become active from Task 1.2 onward.

---

## STEP 1 — ADD DEPENDENCIES TO pubspec.yaml

Run `flutter pub get` **before** pasting the prompt below.

```yaml
dependencies:
  flutter:
    sdk: flutter

  # ── State Management & Navigation ──────────────────────
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^13.2.0

  # ── Backend ────────────────────────────────────────────
  supabase_flutter: ^2.3.4

  # ── Firebase (scaffold only, logic in Task 2.4) ────────
  firebase_core: ^3.3.0
  firebase_messaging: ^15.1.0

  # ── UI / UX ────────────────────────────────────────────
  shimmer: ^3.0.0
  lottie: ^3.1.2

  # ── Utilities ──────────────────────────────────────────
  intl: ^0.19.0
  uuid: ^4.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # ── Code Generation ────────────────────────────────────
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.9
  freezed: ^2.5.2
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  json_serializable: ^6.7.1

  # ── Testing ────────────────────────────────────────────
  mocktail: ^1.0.4
```

---

## STEP 2 — PASTE THIS INTO COPILOT CHAT

```
════════════════════════════════════════════════════════
  PROJECT CONTEXT — ALWAYS INCLUDE IN EVERY SESSION
════════════════════════════════════════════════════════

PROJECT: Dukaan AI
A Flutter mobile app for Indian small business owners.
Generates AI-powered product ads, manages customer credit
(Khata), and shares to WhatsApp.

TECH STACK (non-negotiable):
  • Flutter 3.x / Dart — Android only, minSdkVersion 21
  • Supabase — Auth, Database, Storage
  • Cloudflare Workers — Serverless AI/API proxy (TypeScript)
  • Razorpay SDK — Payments
  • Firebase FCM — Push Notifications
  • Riverpod 2.x (code-gen) — State management ONLY
  • GoRouter 13.x — Navigation ONLY

TARGET DEVICE: 2GB RAM Android, Snapdragon 400-series
LANGUAGE CONVENTION: Hinglish (Hindi words, English script)

ARCHITECTURE RULES:
  1. AI/image processing → Cloudflare Worker ONLY, never on device
  2. Heavy operations → Flutter Isolates via compute(), never UI thread
  3. Images → compressed client-side before any upload
  4. State → Riverpod ONLY. No Provider, Bloc, GetX, or setState.
  5. Navigation → GoRouter ONLY. No Navigator.push directly.
  6. Strings → AppStrings ONLY. No hardcoded text in any widget.
  7. Values → Design tokens ONLY. No hardcoded colors, sizes, spacing.

ANTI-HALLUCINATION CONTRACT:
  Do NOT invent: package APIs, Supabase table/column names,
  GoRouter route names, Riverpod provider names, env variable
  names, Cloudflare Worker endpoint paths, or business logic
  not specified in the task.
  If anything is unclear → ask first, or mark with:
  // ASSUMPTION: <reason>

════════════════════════════════════════════════════════
  TASK 1.1 — PROJECT SCAFFOLD & FOLDER STRUCTURE
════════════════════════════════════════════════════════

CONTEXT:
This is Task 1 of the Dukaan AI build. We are creating the
complete architectural skeleton: folder structure, all design
token files, constants, the Supabase singleton, two core
Riverpod providers (supabaseClientProvider + authStateProvider),
GoRouter setup with StatefulShellRoute, and main.dart.

No business logic. No real screen content. Just the foundation
every other task will build on.

────────────────────────────────────────
  C — CONTEXT: What files does this belong to?
────────────────────────────────────────

This task creates the entire lib/ tree from scratch. Every file
produced here will be imported by ALL future tasks.

────────────────────────────────────────
  R — ROLE: What should the code be?
────────────────────────────────────────

You are a Flutter architect setting up a production-grade,
scalable mobile app following domain-driven feature folder
architecture. Every file must be minimal, compile-clean, and
ready to have real implementations dropped in.

────────────────────────────────────────
  A — ARCHITECTURE: Exact constraints
────────────────────────────────────────

── 1. FOLDER STRUCTURE ──

Produce this exact tree (create .gitkeep files where noted):

lib/
├── core/
│   ├── constants/
│   │   ├── app_strings.dart        ← ALL user-facing strings
│   │   ├── app_routes.dart         ← Route name constants only
│   │   └── supabase_constants.dart ← SupabaseTables + SupabaseColumns
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_spacing.dart
│   │   ├── app_radius.dart
│   │   ├── app_typography.dart
│   │   ├── app_shadows.dart
│   │   └── app_theme.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── supabase/
│   │   └── supabase_client.dart
│   ├── providers/
│   │   └── shared_providers.dart   ← supabaseClientProvider + authStateProvider
│   └── errors/
│       ├── app_exception.dart
│       └── error_handler.dart
├── features/
│   ├── studio/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── studio_screen.dart   ← placeholder only
│   │   │   └── widgets/.gitkeep
│   │   ├── application/.gitkeep
│   │   ├── domain/.gitkeep
│   │   └── infrastructure/.gitkeep
│   ├── my_ads/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── my_ads_screen.dart   ← placeholder only
│   │   │   └── widgets/.gitkeep
│   │   ├── application/.gitkeep
│   │   ├── domain/.gitkeep
│   │   └── infrastructure/.gitkeep
│   ├── account/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── account_screen.dart  ← placeholder only
│   │   │   └── widgets/.gitkeep
│   │   ├── application/.gitkeep
│   │   ├── domain/.gitkeep
│   │   └── infrastructure/.gitkeep
│   └── onboarding/
│       ├── presentation/
│       │   ├── screens/
│       │   │   └── onboarding_screen.dart ← placeholder only
│       │   └── widgets/.gitkeep
│       ├── application/.gitkeep
│       ├── domain/.gitkeep
│       └── infrastructure/.gitkeep
└── shared/
    ├── widgets/.gitkeep
    └── utils/.gitkeep

test/
└── core/
    └── router/
        └── app_router_test.dart

── 2. DESIGN TOKEN FILES (exact values required) ──

app_colors.dart — class AppColors, all static const:
  // Primary Brand
  primary         = Color(0xFFFF6F00)   // Saffron Orange
  primaryDark     = Color(0xFFE65100)   // Pressed state
  primaryLight    = Color(0xFFFFF3E0)   // Background tint

  // Text
  textPrimary     = Color(0xFF1A1A1A)   // Main text
  textSecondary   = Color(0xFF757575)   // Muted text
  textHint        = Color(0xFFBDBDBD)   // Placeholder

  // Surfaces
  surface         = Color(0xFFFFFFFF)   // Card backgrounds
  background      = Color(0xFFF5F5F5)   // Page background
  divider         = Color(0xFFEEEEEE)   // Dividers

  // Semantic
  success         = Color(0xFF2E7D32)
  error           = Color(0xFFB71C1C)
  warning         = Color(0xFFF57F17)

  // Khata-specific
  khataCredit     = Color(0xFF1B5E20)   // Green: paisa aaya
  khataDebit      = Color(0xFFB71C1C)   // Red: paisa gaya

app_spacing.dart — class AppSpacing, all static const double:
  xs = 4.0 | sm = 8.0 | md = 16.0
  lg = 24.0 | xl = 32.0 | xxl = 48.0

app_radius.dart — class AppRadius, all static const double:
  card   = 12.0
  button = 8.0
  chip   = 20.0
  sheet  = 16.0    // bottom sheet top corners

app_typography.dart — class AppTypography, all static const TextStyle:
  displayLarge  = TextStyle(fontSize: 28, fontWeight: FontWeight.w700)
  displayMedium = TextStyle(fontSize: 24, fontWeight: FontWeight.w700)
  headlineLarge = TextStyle(fontSize: 20, fontWeight: FontWeight.w600)
  headlineMedium= TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
  bodyLarge     = TextStyle(fontSize: 16, fontWeight: FontWeight.w400)
  bodyMedium    = TextStyle(fontSize: 14, fontWeight: FontWeight.w400)
  labelLarge    = TextStyle(fontSize: 14, fontWeight: FontWeight.w600)
  labelSmall    = TextStyle(fontSize: 12, fontWeight: FontWeight.w500)

  IMPORTANT: Apply color: AppColors.textPrimary to every style.

app_shadows.dart — class AppShadows:
  // card: the standard card shadow used in every card widget
  static const card = [
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // elevated: for floating bottom sheets and modals
  static const elevated = [
    BoxShadow(
      color: Color(0x26000000), // 15% black
      blurRadius: 16,
      offset: Offset(0, -2),
    ),
  ];

app_theme.dart — builds ThemeData using ONLY token files:
  • colorScheme: seeded from AppColors.primary
  • scaffoldBackgroundColor: AppColors.background
  • appBarTheme: backgroundColor: AppColors.surface,
                elevation: 0,
                titleTextStyle: AppTypography.headlineLarge
  • bottomNavigationBarTheme:
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: AppTypography.labelSmall,
      unselectedLabelStyle: AppTypography.labelSmall,
      type: BottomNavigationBarType.fixed
  • elevatedButtonTheme: uses AppColors.primary, AppRadius.button,
                         AppTypography.labelLarge, height: 48
  • inputDecorationTheme: border radius AppRadius.button,
                          filled, fillColor AppColors.surface
  • cardTheme: color AppColors.surface, elevation 0,
               shape uses AppRadius.card
  • useMaterial3: true
  • fontFamily: 'NotoSans' (supports Devanagari for Hindi)

── 3. CONSTANTS FILES ──

app_routes.dart — class AppRoutes:
  Route PATH strings (used in GoRouter):
  static const shell       = '/'
  static const studio      = '/studio'
  static const myAds       = '/my-ads'
  static const account     = '/account'
  static const onboarding  = '/onboarding'
  static const adResult    = '/studio/result'
  static const bgSelect    = '/studio/bg-select'
  static const pricing     = '/account/pricing'
  static const khata       = '/account/khata'

  Route NAME strings (used in context.goNamed):
  static const nameStudio      = 'studio'
  static const nameMyAds       = 'my-ads'
  static const nameAccount     = 'account'
  static const nameOnboarding  = 'onboarding'
  static const nameAdResult    = 'ad-result'
  static const nameBgSelect    = 'bg-select'
  static const namePricing     = 'pricing'
  static const nameKhata       = 'khata'

supabase_constants.dart — two classes:

  class SupabaseTables:
    static const profiles          = 'profiles'
    static const generatedAds      = 'generatedads'
    static const khataEntries      = 'khataentries'
    static const transactions      = 'transactions'
    static const usageEvents       = 'usageevents'
    static const catalogues        = 'catalogues'
    static const catalogueProducts = 'catalogueproducts'

  class SupabaseColumns:
    static const id               = 'id'
    static const userId           = 'userid'
    static const shopName         = 'shopname'
    static const category         = 'category'
    static const city             = 'city'
    static const phone            = 'phone'
    static const tier             = 'tier'
    static const creditsRemaining = 'creditsremaining'
    static const fcmToken         = 'fcmtoken'
    static const language         = 'language'
    static const imageUrl         = 'imageurl'
    static const thumbnailUrl     = 'thumbnailurl'
    static const backgroundStyle  = 'backgroundstyle'
    static const captionHindi     = 'captionhindi'
    static const captionEnglish   = 'captionenglish'
    static const createdAt        = 'createdat'
    static const isSettled        = 'issettled'
    static const amount           = 'amount'
    static const type             = 'type'
    static const status           = 'status'
    static const planId           = 'planid'
    static const amountPaise      = 'amountpaise'
    static const creditsGranted   = 'creditsgranted'

app_strings.dart — class AppStrings, all static const String:
  // Navigation Tabs
  tabStudio   = 'Studio'
  tabMyAds    = 'Mere Ads'
  tabAccount  = 'Account'

  // General UI
  loading     = 'Thoda ruko...'
  retry       = 'Dobara try karein'
  cancel      = 'Ruk jao'
  confirm     = 'Pakka'
  save        = 'Save karo'
  done        = 'Ho gaya!'

  // Greeting (used in StudioScreen)
  greetingPrefix  = 'Namaste, '   // append shopName after

  // Empty States
  emptyAds    = 'Abhi koi ad nahi! Pehla ad banao.'
  emptyKhata  = 'Koi udhaar nahi! Pehle customer add karo.'

  // Errors — Hinglish only
  errorGeneric       = 'Kuch gadbad ho gayi. Dobara try karein.'
  errorNetwork       = 'Internet nahi hai. Check karo aur retry karo.'
  errorAuth          = 'Login nahi ho pa raha. Dobara try karein.'
  errorCredits       = 'Aapke credits khatam ho gaye!'
  errorRateLimit     = 'Aaj ka limit khatam ho gaya. Kal dobara try karein.'
  errorUploadFailed  = 'Upload nahi hua. Dobara try karein.'

  // Loading / Processing
  loadingAI       = 'AI magic ho raha hai...'
  loadingUpload   = 'Upload ho raha hai...'
  loadingPayment  = 'Payment process ho rahi hai...'

  // Success
  successAdCreated   = 'Ad ban gaya!'
  successSaved       = 'Save ho gaya!'
  successCopied      = 'Copy ho gaya!'

── 4. ERROR FILES ──

app_exception.dart — sealed class AppException:
  IMPORTANT: Use Dart's `sealed` keyword (Dart 3.0+)
  Variants (each with a String message field):
    AppException.supabase(String message)
    AppException.storage(String message)
    AppException.network(String message)
    AppException.rateLimit(String message)
    AppException.credits(String message)
    AppException.unknown(String message)

error_handler.dart — class ErrorHandler:
  /// Maps any thrown exception to a user-friendly Hinglish string.
  /// Use this in every .when(error:) callback in widgets.
  static String toUserMessage(Object error) {
    return switch (error) {
      AppException.supabase(:final message) => message,
      AppException.storage(:final message)  => message,
      AppException.network _                => AppStrings.errorNetwork,
      AppException.rateLimit _              => AppStrings.errorRateLimit,
      AppException.credits _                => AppStrings.errorCredits,
      _                                     => AppStrings.errorGeneric,
    };
  }

  /// Wraps a PostgrestException into AppException.supabase.
  static AppException fromPostgrest(dynamic e) =>
      AppException.supabase(e?.message ?? AppStrings.errorGeneric);

── 5. SUPABASE SINGLETON ──

supabase_client.dart:
  /// Singleton accessor for the Supabase client.
  /// ALWAYS import and use this. Never call Supabase.instance.client directly.
  class SupabaseClientWrapper {
    SupabaseClientWrapper._();
    static SupabaseClient get instance => Supabase.instance.client;
  }

── 6. SHARED RIVERPOD PROVIDERS ──

shared_providers.dart — two providers ONLY in this file:
  These are foundation providers every repository and the router depend on.

  Provider 1 — supabaseClientProvider:
    /// Provides the Supabase client. Used by all repository providers.
    @riverpod
    SupabaseClient supabaseClient(SupabaseClientRef ref) {
      return SupabaseClientWrapper.instance;
    }

  Provider 2 — authStateProvider:
    /// Streams Supabase auth state changes.
    /// Used by GoRouter's redirect to protect routes.
    @riverpod
    Stream<AuthState> authState(AuthStateRef ref) {
      return SupabaseClientWrapper.instance.auth.onAuthStateChange;
    }

  IMPORTANT: Run `dart run build_runner build` after creating this file.
  Generated file will be: lib/core/providers/shared_providers.g.dart
  Add the `part 'shared_providers.g.dart';` directive.

── 7. GOROUTER SETUP ──

app_router.dart — EXACT requirements:
  • Use StatefulShellRoute.indexedStack for the 3-tab shell.
  • The shell contains 3 branches:
      Branch 0: navigatorKey for studio,   initialLocation: AppRoutes.studio
      Branch 1: navigatorKey for my_ads,   initialLocation: AppRoutes.myAds
      Branch 2: navigatorKey for account,  initialLocation: AppRoutes.account
  • Routes OUTSIDE the shell (no bottom nav):
      - AppRoutes.onboarding → OnboardingScreen (placeholder)
  • Auth redirect logic:
      ref.watch(authStateProvider) — check for active session
      If no session → redirect to AppRoutes.onboarding
      If session exists and on /onboarding → redirect to AppRoutes.studio
  • The router must be created as a Riverpod provider:
      @riverpod
      GoRouter appRouter(AppRouterRef ref) { ... }
  • NavigationBar (Material 3) — NOT BottomNavigationBar:
      3 destinations:
        - NavigationDestination(icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: AppStrings.tabStudio)
        - NavigationDestination(icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: AppStrings.tabMyAds)
        - NavigationDestination(icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: AppStrings.tabAccount)
      backgroundColor: AppColors.surface
      indicatorColor: AppColors.primaryLight
      selectedIndex: navigationShell.currentIndex
      onDestinationSelected: (i) => navigationShell.goBranch(i,
        initialLocation: i == navigationShell.currentIndex)

── 8. PLACEHOLDER SCREENS ──

Each of the 4 screens is a ConsumerWidget (NOT StatefulWidget) returning
a minimal Scaffold. Requirements for each:
  • Import and use AppColors.background for scaffoldBackgroundColor
  • AppBar with the feature name using AppTypography.headlineLarge
  • Body: Center → Column → Icon + Text(coming soon)
  • All text via AppStrings constants — no hardcoded strings

studio_screen.dart   → icon: Icons.auto_awesome,   label: AppStrings.tabStudio
my_ads_screen.dart   → icon: Icons.grid_view,       label: AppStrings.tabMyAds
account_screen.dart  → icon: Icons.person,          label: AppStrings.tabAccount
onboarding_screen.dart → icon: Icons.store,  title: 'Dukaan AI'

── 9. MAIN.DART ──

Exact initialization order:
  1. WidgetsFlutterBinding.ensureInitialized()
  2. await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     // TODO: Add lib/firebase_options.dart after running:
     // flutterfire configure --project=<your-project-id>

  3. await Supabase.initialize(
       url: const String.fromEnvironment('SUPABASE_URL',
         defaultValue: 'https://placeholder.supabase.co'),
       anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
         defaultValue: 'placeholder-anon-key'),
     );
     // TODO: Replace with real values via --dart-define or .env

  4. runApp(
       const ProviderScope(
         child: DukaanApp(),
       ),
     );

DukaanApp class (ConsumerWidget):
  • Reads appRouterProvider via ref.watch
  • Returns MaterialApp.router with:
      routerConfig: router (from appRouterProvider)
      theme: AppTheme.light()
      debugShowCheckedModeBanner: false
      title: 'Dukaan AI'

────────────────────────────────────────
  F — FORMAT: Output these files
────────────────────────────────────────

Produce full Dart code for EVERY file listed below, in this order:

 1. lib/core/theme/app_colors.dart
 2. lib/core/theme/app_spacing.dart
 3. lib/core/theme/app_radius.dart
 4. lib/core/theme/app_typography.dart
 5. lib/core/theme/app_shadows.dart
 6. lib/core/theme/app_theme.dart
 7. lib/core/constants/app_routes.dart
 8. lib/core/constants/app_strings.dart
 9. lib/core/constants/supabase_constants.dart
10. lib/core/errors/app_exception.dart
11. lib/core/errors/error_handler.dart
12. lib/core/supabase/supabase_client.dart
13. lib/core/providers/shared_providers.dart
14. lib/core/router/app_router.dart
15. lib/features/studio/presentation/screens/studio_screen.dart
16. lib/features/my_ads/presentation/screens/my_ads_screen.dart
17. lib/features/account/presentation/screens/account_screen.dart
18. lib/features/onboarding/presentation/screens/onboarding_screen.dart
19. lib/main.dart
20. The complete folder tree as a text diagram

────────────────────────────────────────
  T — TESTS: Write these test files
────────────────────────────────────────

test/core/router/app_router_test.dart

Use mocktail to mock Supabase auth state.
Write exactly 3 tests:

  Test 1 — Unauthenticated redirect:
    Given: authStateProvider emits no active session
    When: user navigates to AppRoutes.studio
    Then: GoRouter redirects to AppRoutes.onboarding

  Test 2 — Authenticated access:
    Given: authStateProvider emits a valid Session
    When: user navigates to AppRoutes.studio
    Then: GoRouter resolves to StudioScreen with no redirect

  Test 3 — Onboarding auto-redirect:
    Given: authStateProvider emits a valid Session
    When: user is on AppRoutes.onboarding
    Then: GoRouter redirects to AppRoutes.studio

────────────────────────────────────────
  DO NOT (apply to entire output)
────────────────────────────────────────

✗ DO NOT use hardcoded Color(0xFF...) anywhere outside app_colors.dart
✗ DO NOT use hardcoded 16.0 or any raw double for spacing — use AppSpacing.*
✗ DO NOT use hardcoded Strings in any widget — use AppStrings.*
✗ DO NOT use StatefulWidget for placeholder screens — use ConsumerWidget
✗ DO NOT use Navigator.push — use context.go or context.goNamed
✗ DO NOT use BottomNavigationBar — use NavigationBar (Material 3)
✗ DO NOT use IndexedStack manually — use StatefulShellRoute.indexedStack
✗ DO NOT use old Riverpod (StateNotifierProvider, etc.)
✗ DO NOT add any business logic, no API calls, no real data loading
✗ DO NOT use dynamic type anywhere — be explicit
✗ DO NOT use print() — project uses logger package (Task 4.1 will add it)
✗ DO NOT create a ChangeNotifier or extend StatefulWidget for state
✗ DO NOT hardcode Supabase table names as strings — use SupabaseTables.*
✗ DO NOT add Firebase google-services.json references — leave as TODO

────────────────────────────────────────
  QUALITY GATES — Verify before output
────────────────────────────────────────

Before writing any Dart code, confirm:
  □ All token classes use only static const — no instance members
  □ AppTheme references only AppColors, AppSpacing, AppRadius, AppTypography
  □ GoRouter uses appRouterProvider (@riverpod), not a global GoRouter variable
  □ authStateProvider is a StreamProvider<AuthState>, not FutureProvider
  □ AppException is a sealed class (Dart 3 pattern matching compatible)
  □ ErrorHandler.toUserMessage uses a switch expression, not if-else chain
  □ All placeholder screens have const constructors
  □ shared_providers.dart has part directive for the .g.dart generated file
```

---

## STEP 3 — AFTER COPILOT RESPONDS

Run these commands in order:

```bash
# 1. Get dependencies
flutter pub get

# 2. Generate Riverpod code for shared_providers.dart
dart run build_runner build --delete-conflicting-outputs

# 3. Analyze — must show zero issues
flutter analyze

# 4. Run tests
flutter test test/core/router/app_router_test.dart
```

---

## STEP 4 — VERIFY THIS CHECKLIST MANUALLY

Before moving to Task 1.2, confirm every item:

**Token Files**
- [ ] Zero hardcoded `Color(0xFF...)` outside `app_colors.dart`
- [ ] Zero raw `double` values (16.0, 8.0, etc.) outside `app_spacing.dart` / `app_radius.dart`
- [ ] Zero hardcoded font sizes outside `app_typography.dart`
- [ ] `AppTheme.light()` builds without referencing any literal values

**Constants**
- [ ] `AppRoutes` has both PATH strings (`/studio`) AND NAME strings (`'studio'`)
- [ ] `SupabaseTables` and `SupabaseColumns` use the exact snake_case column names from the schema
- [ ] `AppStrings` covers all error, loading, and success messages in Hinglish

**Architecture**
- [ ] `AppException` is a `sealed class` — confirm keyword is `sealed`, not `abstract`
- [ ] `ErrorHandler.toUserMessage` uses Dart 3 `switch` expression pattern matching
- [ ] `supabaseClientProvider` and `authStateProvider` are in `shared_providers.dart` only
- [ ] `shared_providers.g.dart` was generated by build_runner (file exists)

**Router**
- [ ] `appRouterProvider` is a `@riverpod` provider, not a global GoRouter instance
- [ ] `StatefulShellRoute.indexedStack` is used — not `IndexedStack` in a widget
- [ ] `NavigationBar` (Material 3) is used — not `BottomNavigationBar`
- [ ] Auth redirect guards `AppRoutes.studio`, `AppRoutes.myAds`, `AppRoutes.account`
- [ ] `AppRoutes.onboarding` is OUTSIDE the shell (no bottom nav)

**Screens**
- [ ] All 4 placeholder screens extend `ConsumerWidget`, not `StatefulWidget`
- [ ] All 4 screens have `const` constructors
- [ ] Zero hardcoded strings in any screen widget

**main.dart**
- [ ] `WidgetsFlutterBinding.ensureInitialized()` is the very first line
- [ ] Supabase URL and anonKey use `String.fromEnvironment` with `defaultValue`
- [ ] Firebase init has a `// TODO: Add firebase_options.dart` comment
- [ ] `runApp` wraps `ProviderScope` which wraps `DukaanApp`
- [ ] `DukaanApp` is a `ConsumerWidget` that reads `appRouterProvider`

**Tests**
- [ ] All 3 router tests pass with `flutter test`
- [ ] Tests use `mocktail` — no real Supabase calls

---



*Dukaan AI v1.0 Build Playbook · Task 1.1 · Generated April 2026*
