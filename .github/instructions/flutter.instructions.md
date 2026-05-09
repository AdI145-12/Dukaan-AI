---
applyTo: "lib/**"
---

# Flutter Instructions (lib/**)

## Widget Pattern
- Always use `ConsumerWidget` (Riverpod) — NEVER `StatefulWidget` unless animation controller is required
- Always use `ConsumerStatefulWidget` only when `TickerProvider` is needed
- Every screen widget goes in `features/<feature>/presentation/screens/`
- Every reusable widget goes in `features/<feature>/presentation/widgets/` or `shared/widgets/`

## State Management — Riverpod
- Use `@riverpod` annotation + code generation for all providers
- For async data: use `AsyncNotifier` or `FutureProvider`
- For mutable state: use `Notifier` with explicit state classes
- State classes must be `@freezed` immutable data classes
- NEVER use `ref.read()` inside `build()` — only `ref.watch()`
- NEVER use `ref.watch()` inside callbacks — only `ref.read()`
- Provider naming: `<featureName>Provider` (e.g., `studioProvider`, `khataProvider`)

## Navigation — GoRouter
- All routes defined in `lib/core/router/app_router.dart`
- Route names as constants in `lib/core/router/app_routes.dart`
- Use `context.go()` for tab navigation, `context.push()` for stack navigation
- NEVER use `Navigator.of(context).push()`
- Pass data via GoRouter `extra` or Riverpod — never via constructor for large objects

## Performance (Low-End Android — Mandatory)
- Every `ListView` must be `ListView.builder` — NEVER `ListView` with children
- Every network image must use `CachedNetworkImage` with shimmer placeholder
- Wrap each list item in `RepaintBoundary`
- Heavy computation (base64, compression, JSON parsing > 1KB): use `compute()`
- Use `AutomaticKeepAliveClientMixin` on tab screens to prevent rebuild on tab switch
- Add `const` to every widget that does not depend on runtime data

## Design Tokens (Always Use These — No Hardcoded Values)
```dart
// Colors
AppColors.primary     // #FF6F00 saffron orange
AppColors.surface     // #FAFAFA
AppColors.background  // #111111 dark
AppColors.error       // #D32F2F
AppColors.textPrimary // #1A1A1A
AppColors.textMuted   // #757575

// Spacing
AppSpacing.xs  // 4.0
AppSpacing.sm  // 8.0
AppSpacing.md  // 16.0
AppSpacing.lg  // 24.0
AppSpacing.xl  // 32.0

// Border Radius
AppRadius.card   // 12.0
AppRadius.button // 8.0
AppRadius.chip   // 20.0
```

## Error Handling Pattern
```dart
// ALWAYS handle errors like this in providers:
try {
  // operation
} on FirebaseException catch (e) {
  throw AppException.firebase(e.message ?? AppStrings.errorGeneric);
} on StorageException catch (e) {
  throw AppException.storage(e.message);
} catch (e) {
  throw AppException.unknown(e.toString());
}

// NEVER do this:
} catch (e) {
  print(e); // silent failure
}
```

## Firebase in Flutter
- Firebase service wrapper: `lib/core/firebase/firebase_service.dart` — use `FirebaseService.db` and `FirebaseService.currentUserId`
- ALWAYS specify Firestore fields explicitly in queries and reads
- NEVER use wildcard reads or writes when a narrow document path works
- For real-time: use Firestore `snapshots()` via repository streams
- Auth state: use `FirebaseService.currentUserId` in widgets and providers; never access `FirebaseAuth.instance.currentUser` directly in widgets

## Localization
- All user-facing strings in: `lib/core/constants/app_strings.dart`
- Format: `AppStrings.errorNetworkRetry` → `"Kuch gadbad ho gayi, dobara try karein 🙏"`
- Hinglish for errors, Hindi for labels, English for technical terms
