# PROMPT 1.2 — Bottom Navigation Shell & Shared Base Widgets
### Dukaan AI · Copilot Chat Prompt · Expanded Edition

---

## CONTEXT — HOW THIS DIFFERS FROM THE ORIGINAL PLAYBOOK

The original Prompt 1.2 assumed a blank slate. Task 1.1 already delivered:
  ✅ StatefulShellRoute.indexedStack in app_router.dart
  ✅ NavigationBar (Material 3) with 3 destinations
  ✅ auth redirect guards
  ✅ 4 placeholder ConsumerWidget screens

Task 1.2 therefore does NOT rebuild navigation from scratch.
It EXTENDS what exists with 6 things the playbook deferred:
  1. Extract shell UI into a reusable AppShellScaffold widget
  2. Add the FAB on Studio tab only (camera icon, "New Ad")
  3. Apply AutomaticKeepAliveClientMixin on all 3 tab screens
  4. Fix NavigationBar label behavior (selected=label, unselected=icon-only)
  5. Build 3 shared base widgets: AppButton, ShimmerBox, AppBottomSheet
  6. Add mocktail to pubspec dev_dependencies (required before Task 1.3 tests)

---

## STEP 0 — ATTACH THESE FILES IN COPILOT CHAT

| # | File | Why |
|---|---|---|
| 1 | `copilot-instructions.md` | Global rules, no hardcoded values, const everywhere |
| 2 | `flutter.instructions.md` | ConsumerWidget, AutomaticKeepAliveClientMixin, ListView.builder rules |
| 3 | `SKILL.md` → *flutter-design-system* | AppButton, AppBottomSheet, ShimmerBox exact patterns |
| 4 | `SKILL.md` → *riverpod-patterns* | ConsumerStatefulWidget for mixin, ref.watch rules |
| 5 | `flutter-screen.prompt.md` | Screen build template, 3-state handling, performance checklist |
| 6 | `app_router.dart` | Attach the ACTUAL file — Copilot must modify it, not rewrite it |
| 7 | `studio_screen.dart` | Attach the ACTUAL file — Copilot must add mixin here |
| 8 | `my_ads_screen.dart` | Attach the ACTUAL file — Copilot must add mixin here |
| 9 | `account_screen.dart` | Attach the ACTUAL file — Copilot must add mixin here |

### Agent: Kavya (ui-engineer.agent.md) — ACTIVATE NOW
> Attach `ui-engineer.agent.md`. Kavya is the Flutter UI/UX engineer agent.
> She handles design system compliance, Hinglish copy, low-end Android
> optimization, and widget performance. All UI tasks from 1.2 onward use Kavya.

---

## STEP 1 — ADD TO pubspec.yaml dev_dependencies

Add mocktail ONLY (do not touch any other dependency):

```yaml
dev_dependencies:
  # ... existing entries ...
  mocktail: ^1.0.4    # ADD THIS — required for all router + provider tests
```

Run `flutter pub get` after adding.

---

## STEP 2 — PASTE THIS INTO COPILOT CHAT

```
════════════════════════════════════════════════════════
  PROJECT CONTEXT — ALWAYS INCLUDE IN EVERY SESSION
════════════════════════════════════════════════════════

PROJECT: Dukaan AI — Flutter mobile app for Indian small
business owners. AI-powered ad generation + Khata + WhatsApp.

TECH STACK: Flutter 3.x / Riverpod 2.x / GoRouter 13.x /
Supabase / Cloudflare Workers / Razorpay / Firebase FCM

TARGET: 2GB RAM Android, Snapdragon 400-series, 60fps mandatory.

ARCHITECTURE RULES:
  • Riverpod ONLY — no Provider, Bloc, GetX, setState
  • GoRouter ONLY — no Navigator.push
  • ConsumerWidget by default — ConsumerStatefulWidget ONLY
    when TickerProvider or AutomaticKeepAliveClientMixin needed
  • All strings via AppStrings.*
  • All values via AppColors.*, AppSpacing.*, AppRadius.*, AppTypography.*
  • const on every widget that does not depend on runtime data
  • No print() — no dynamic type — no silent catch blocks

════════════════════════════════════════════════════════
  TASK 1.2 — BOTTOM NAVIGATION SHELL & SHARED BASE WIDGETS
════════════════════════════════════════════════════════

CONTEXT:
Task 1.1 delivered StatefulShellRoute.indexedStack + NavigationBar
in app_router.dart and 3 placeholder ConsumerWidget screens.
This task extends those files and creates 3 shared base widgets
that ALL future features will import.

Do NOT rebuild the navigation from scratch.
Work only within the files listed in the FORMAT section.

────────────────────────────────────────
  R — ROLE
────────────────────────────────────────

You are Kavya, the Flutter UI engineer for Dukaan AI.
Your job is performance-first, design-system-compliant UI.
You never invent widget patterns — you use the ones in the
attached flutter-design-system skill.

────────────────────────────────────────
  A — ARCHITECTURE: Exact constraints
────────────────────────────────────────

── 1. AppShellScaffold — NEW FILE ──

Path: lib/shared/widgets/app_shell_scaffold.dart

Extract the shell body from app_router.dart into this widget.
app_router.dart should call AppShellScaffold, not define the
NavigationBar inline.

AppShellScaffold is a StatelessWidget receiving:
  - final StatefulNavigationShell navigationShell
  - final Widget child (the current tab body)

Internal layout:
  Scaffold(
    backgroundColor: AppColors.background,
    body: child,
    bottomNavigationBar: NavigationBar(...),  // see spec below
    floatingActionButton: _buildFab(context),  // see spec below
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
  )

NavigationBar spec:
  • backgroundColor: AppColors.surface
  • indicatorColor: AppColors.primaryLight
  • selectedIndex: navigationShell.currentIndex
  • labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected
    ← THIS IS KEY: shows label only for selected tab, icon-only for others
  • height: 64
  • onDestinationSelected: (index) {
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }
  • destinations (3 items):
      NavigationDestination(
        icon: Icon(Icons.auto_awesome_outlined),
        selectedIcon: Icon(Icons.auto_awesome, color: AppColors.primary),
        label: AppStrings.tabStudio,
      )
      NavigationDestination(
        icon: Icon(Icons.grid_view_outlined),
        selectedIcon: Icon(Icons.grid_view, color: AppColors.primary),
        label: AppStrings.tabMyAds,
      )
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person, color: AppColors.primary),
        label: AppStrings.tabAccount,
      )

FAB spec (_buildFab method):
  Show FloatingActionButton ONLY when currentIndex == 0 (Studio tab).
  On any other tab, return null (no FAB).

  FloatingActionButton(
    onPressed: () => context.push(AppRoutes.cameraCapture),
    // NOTE: AppRoutes.cameraCapture will be added in Task 1.4.
    // For now: onPressed: () {} with a TODO comment.
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    tooltip: AppStrings.fabNewAd,  // add this string to AppStrings
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt, size: 20),
        Text(AppStrings.fabNewAd,
          style: AppTypography.labelSmall.copyWith(color: Colors.white)),
      ],
    ),
    shape: CircleBorder(),
  )
  Height/width: 64x64 (use SizedBox wrapper)

AppStrings additions required:
  fabNewAd = 'New Ad'
  // TODO: add to app_strings.dart before running this task

── 2. UPDATE app_router.dart ──

Modify (do NOT rewrite) the existing app_router.dart:

  a. Import AppShellScaffold from shared/widgets/app_shell_scaffold.dart
  b. In the StatefulShellRoute builder, replace the inline Scaffold
     with AppShellScaffold(navigationShell: shell, child: child)
  c. No other changes to routing logic, redirect, or branch structure

── 3. ADD AutomaticKeepAliveClientMixin TO TAB SCREENS ──

Modify (do NOT rewrite) all 3 tab screens:
  studio_screen.dart, my_ads_screen.dart, account_screen.dart

Change each from:
  class XxxScreen extends ConsumerWidget
To:
  class XxxScreen extends ConsumerStatefulWidget

With inner State class:
  class _XxxScreenState extends ConsumerState<XxxScreen>
    with AutomaticKeepAliveClientMixin {

    @override
    bool get wantKeepAlive => true;

    @override
    Widget build(BuildContext context) {
      super.build(context);  // REQUIRED — must call super.build
      // ... existing placeholder body unchanged ...
    }
  }

REASON: AutomaticKeepAliveClientMixin prevents tab screens from
rebuilding when the user switches tabs. Critical for low-end devices.

IMPORTANT: Only use ConsumerStatefulWidget here because the mixin
requires a State class. This is the only valid exception to the
"use ConsumerWidget" rule.

── 4. AppButton — NEW SHARED WIDGET ──

Path: lib/shared/widgets/app_button.dart

/// The standard primary button for all Dukaan AI actions.
/// Use this instead of raw ElevatedButton everywhere.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final AppButtonVariant variant;
}

enum AppButtonVariant { primary, secondary, ghost }

Rendering rules:
  • primary: filled, AppColors.primary bg, white text
  • secondary: outlined, AppColors.primary border, AppColors.primary text, transparent bg
  • ghost: no border, AppColors.primary text, transparent bg

All variants:
  • Height: 48dp
  • Border radius: AppRadius.button (8)
  • Text style: AppTypography.labelLarge
  • isLoading=true: replace label with SizedBox(16x16) CircularProgressIndicator
    (white stroke for primary, AppColors.primary stroke for others)
  • onPressed=null OR isLoading=true: disable button, reduce opacity to 0.5
  • isFullWidth=true: SizedBox(width: double.infinity) wrapper
  • Padding: horizontal AppSpacing.lg, vertical AppSpacing.sm
  • const constructor

── 5. ShimmerBox — NEW SHARED WIDGET ──

Path: lib/shared/widgets/shimmer_box.dart

/// Animated shimmer skeleton for loading states.
/// ALWAYS use this instead of empty white space during loading.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppRadius.button,  // default 8
  });

  final double width;
  final double height;
  final double borderRadius;
}

Implementation:
  Use the shimmer package: Shimmer.fromColors(
    baseColor: AppColors.divider,      // 0xFFEEEEEE
    highlightColor: AppColors.surface, // 0xFFFFFFFF
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
  )

  Respect prefers-reduced-motion: if MediaQuery.of(context)
  .disableAnimations is true, show a static Container instead
  of the animated shimmer.

── 6. AppBottomSheet — NEW SHARED WIDGET ──

Path: lib/shared/widgets/app_bottom_sheet.dart

/// Standard bottom sheet wrapper. Use showModalBottomSheet
/// with this widget as content for ALL bottom sheets in the app.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.showDragHandle = true,
  });

  final String title;
  final Widget child;
  final bool showDragHandle;
}

Layout (top to bottom):
  Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppRadius.sheet),   // 16
        topRight: Radius.circular(AppRadius.sheet),
      ),
      boxShadow: AppShadows.elevated,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if showDragHandle:
          Container(  // drag handle
            margin: EdgeInsets.only(top: AppSpacing.sm),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(title, style: AppTypography.headlineMedium),
        ),
        Divider(color: AppColors.divider, height: 1),
        Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: child,
        ),
        // Safe area padding for bottom inset
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    ),
  )

  Static helper method on the class:
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (_) => AppBottomSheet(title: title, child: child),
    );
  }

────────────────────────────────────────
  F — FORMAT: Output these files
────────────────────────────────────────

Produce full Dart code for each file, in this order:

 1. lib/core/constants/app_strings.dart
    (MODIFIED — add fabNewAd = 'New Ad' only, no other changes)

 2. lib/shared/widgets/app_shell_scaffold.dart        (NEW)
 3. lib/shared/widgets/app_button.dart                (NEW)
 4. lib/shared/widgets/shimmer_box.dart               (NEW)
 5. lib/shared/widgets/app_bottom_sheet.dart          (NEW)

 6. lib/core/router/app_router.dart
    (MODIFIED — use AppShellScaffold, nothing else changes)

 7. lib/features/studio/presentation/screens/studio_screen.dart
    (MODIFIED — add AutomaticKeepAliveClientMixin)

 8. lib/features/my_ads/presentation/screens/my_ads_screen.dart
    (MODIFIED — add AutomaticKeepAliveClientMixin)

 9. lib/features/account/presentation/screens/account_screen.dart
    (MODIFIED — add AutomaticKeepAliveClientMixin)

10. test/shared/widgets/app_button_test.dart          (NEW)
11. test/shared/widgets/shimmer_box_test.dart         (NEW)

────────────────────────────────────────
  T — TESTS
────────────────────────────────────────

test/shared/widgets/app_button_test.dart:
  Test 1: primary variant renders with correct background color AppColors.primary
  Test 2: isLoading=true shows CircularProgressIndicator, not label text
  Test 3: onPressed=null disables the button (no tap callback fires)
  Test 4: secondary variant renders with border, no fill
  Test 5: isFullWidth=true wraps in full-width SizedBox

test/shared/widgets/shimmer_box_test.dart:
  Test 1: renders Shimmer widget when disableAnimations=false
  Test 2: renders static Container when disableAnimations=true
  Test 3: applies correct borderRadius to child Container

────────────────────────────────────────
  DO NOT
────────────────────────────────────────

✗ DO NOT rewrite app_router.dart routing logic — only swap inline
  Scaffold for AppShellScaffold
✗ DO NOT rebuild StatefulShellRoute — it was completed in Task 1.1
✗ DO NOT use BottomNavigationBar — NavigationBar (Material 3) only
✗ DO NOT use Opacity widget — use FadeTransition or opacity on decoration
✗ DO NOT use ElevatedButton directly anywhere — use AppButton
✗ DO NOT use CircularProgressIndicator full-screen — use ShimmerBox
✗ DO NOT use showModalBottomSheet directly — use AppBottomSheet.show()
✗ DO NOT add setState to tab screens — they use ConsumerStatefulWidget
  ONLY because AutomaticKeepAliveClientMixin requires a State class
✗ DO NOT hardcode any color, size, spacing, or string value
✗ DO NOT skip the super.build(context) call inside wantKeepAlive screens

────────────────────────────────────────
  QUALITY GATES — Verify before output
────────────────────────────────────────

Before writing any code, confirm:
  □ AppShellScaffold is StatelessWidget (no state needed)
  □ FAB is null on tabs 1 and 2, non-null only on tab 0
  □ NavigationDestinationLabelBehavior.onlyShowSelected is set
  □ AutomaticKeepAliveClientMixin applied to all 3 tab State classes
  □ super.build(context) is the FIRST line inside each overridden build
  □ AppButton has const constructor with all params
  □ ShimmerBox respects MediaQuery.of(context).disableAnimations
  □ AppBottomSheet.show() is static, returns Future<T?>
```

---

## STEP 3 — AFTER COPILOT RESPONDS

```bash
# 1. Ensure mocktail is fetched
flutter pub get

# 2. Static analysis — must be zero issues
flutter analyze

# 3. Run new widget tests
flutter test test/shared/widgets/

# 4. Hot reload the app — verify visually:
#   a. Tab labels: only selected tab shows label text
#   b. FAB appears ONLY on Studio tab, disappears on My Ads / Account
#   c. Switching tabs does NOT cause screen rebuild (wantKeepAlive working)
flutter run
```

---

## STEP 4 — VERIFY THIS CHECKLIST

**AppShellScaffold**
- [ ] `app_router.dart` imports and uses `AppShellScaffold`
- [ ] No inline `Scaffold` or `NavigationBar` remains in `app_router.dart`
- [ ] FAB is a `FloatingActionButton` with `CircleBorder()` shape
- [ ] FAB has camera icon + "New Ad" label stacked in a Column
- [ ] FAB returns `null` (not invisible widget) when not on Studio tab

**NavigationBar Behavior**
- [ ] `labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected`
- [ ] All 3 unselected tabs show icon only (no label text visible)
- [ ] Selected tab shows both icon AND label
- [ ] `indicatorColor` is `AppColors.primaryLight` (soft orange tint)

**Tab State Preservation**
- [ ] All 3 screens use `ConsumerStatefulWidget` + `ConsumerState`
- [ ] All 3 state classes mix in `AutomaticKeepAliveClientMixin`
- [ ] `wantKeepAlive` returns `true` in all 3
- [ ] `super.build(context)` is called inside each `build` method

**Shared Widgets**
- [ ] `AppButton` has 3 variants and handles `isLoading` and `onPressed=null`
- [ ] `ShimmerBox` uses `shimmer` package and respects `disableAnimations`
- [ ] `AppBottomSheet.show()` is a static method returning `Future<T?>`
- [ ] All 3 widgets have `const` constructors
- [ ] Zero hardcoded colors, sizes, or strings in any shared widget

**Tests**
- [ ] 5 AppButton tests pass
- [ ] 3 ShimmerBox tests pass
- [ ] `flutter analyze` still shows zero issues after changes

---

## WHAT COMES NEXT

> **Task 1.3 — Studio Home Screen** is the first real feature screen.
> It adds the `StudioScreen` body: header with shop name greeting,
> Quick Create horizontal card row (Product Photo, Festival Ad,
> WhatsApp Status, Offer Banner), Recent Ads shimmer list,
> and a `studioProvider` (AsyncNotifier).
>
> New dependencies needed before Task 1.3:
>   - No new packages (all required ones are already in pubspec)
>
> Agent: Kavya continues. No Workers (Dev) until Task 1.5.
> Files: studio_screen.dart, new studioProvider, new StudioState model.

---

*Dukaan AI v1.0 Build Playbook · Task 1.2 · Generated April 2026*
