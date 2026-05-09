---
name: riverpod-patterns
description: >
  Use this skill whenever writing, editing, or reviewing any Riverpod provider,
  state class, or AsyncNotifier in the Dukaan AI Flutter project. Covers the exact
  Riverpod 2.x code-gen patterns this project uses — provider structure,
  state modeling with freezed, error handling, and family providers.
---

# Dukaan AI — Riverpod 2.x Patterns

## Tech Stack Context
- Flutter 3.x + Riverpod 2.x with code generation (@riverpod annotation)
- All providers use **code-gen** (riverpod_annotation + build_runner)
- State classes use **freezed** (@freezed annotation)
- Generated files: `*.g.dart` (riverpod), `*.freezed.dart` (freezed)
- Never use old-style `Provider(...)`, `StateNotifierProvider`, or `ChangeNotifier`

---

## Standard Provider Pattern (AsyncNotifier)

Every feature's main provider follows this exact structure:

```dart
// FILE: lib/features/<feature>/application/<feature>_provider.dart

part '<feature>_provider.g.dart';

@riverpod
class FeatureNotifier extends _$FeatureNotifier {
  @override
  Future<FeatureState> build() async {
    // Initialize state. Called on first access and on ref.invalidate().
    final repo = ref.watch(featureRepositoryProvider);
    return repo.getInitialData();
  }

  Future<void> someAction(String param) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(featureRepositoryProvider).doSomething(param),
    );
  }
}
```

## State Class Pattern (Freezed)

```dart
// FILE: lib/features/<feature>/application/<feature>_state.dart

part '<feature>_state.freezed.dart';

@freezed
class FeatureState with _$FeatureState {
  const factory FeatureState({
    @Default([]) List<FeatureModel> items,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _FeatureState;
}
```

## Simple Read-Only Provider

For data that doesn't change (e.g., plan list, festival calendar):

```dart
@riverpod
Future<List<Plan>> availablePlans(AvailablePlansRef ref) async {
  final repo = ref.watch(pricingRepositoryProvider);
  return repo.getPlans();
}
```

## Family Provider (for parameterized data)

```dart
@riverpod
Future<GeneratedAd> adDetail(AdDetailRef ref, String adId) async {
  final repo = ref.watch(adsRepositoryProvider);
  return repo.getAdById(adId);
}
// Usage: ref.watch(adDetailProvider('some-uuid'))
```

## StreamProvider Pattern (for Supabase Realtime)

```dart
@riverpod
Stream<List<KhataEntry>> khataEntries(KhataEntriesRef ref) {
  final repo = ref.watch(khataRepositoryProvider);
  return repo.watchEntries(); // returns Stream from Supabase .stream()
}
```

## Repository Provider Pattern

Repositories are always declared as simple providers:

```dart
@riverpod
FeatureRepository featureRepository(FeatureRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final cloudflare = ref.watch(cloudflareClientProvider);
  return FeatureRepositoryImpl(supabase: supabase, cloudflare: cloudflare);
}
```

## Watching vs Reading

```dart
// In build() or when subscribing to changes → use watch
final repo = ref.watch(featureRepositoryProvider);

// In action methods (not reactive) → use read
final repo = ref.read(featureRepositoryProvider);

// NEVER use ref.read() in build() — this won't rebuild on changes
```

## Handling AsyncValue in Widgets

```dart
// Always handle all 3 states
ref.watch(studioProvider).when(
  data: (state) => StudioContent(state: state),
  loading: () => const StudioSkeleton(),
  error: (e, st) => AppErrorView(
    message: ErrorHandler.toUserMessage(e),
    onRetry: () => ref.invalidate(studioProvider),
  ),
);
```

## Error Handling in Notifiers

```dart
Future<void> generateAd(AdCreationRequest request) async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(() async {
    await CreditGuard.check(ref); // throws AppException if no credits
    final result = await ref.read(studioRepositoryProvider).createAd(request);
    return state.requireValue.copyWith(latestAd: result);
  });
}
```

## State Invalidation Pattern

```dart
// Refresh a provider (re-runs build())
ref.invalidate(studioProvider);

// Trigger invalidation from outside (e.g., after payment)
ref.invalidate(profileProvider); // refreshes credits display
```

## Copilot Rules for This Project

1. **Always use @riverpod annotation** — never create providers manually
2. **Always handle AsyncValue.error** in every widget — never skip the error state
3. **State mutations go in the Notifier** — widgets call methods, never modify state directly
4. **Use AsyncValue.guard()** for all async operations in notifiers — never try/catch manually
5. **Use ref.watch() in build(), ref.read() in methods** — never mix these up
6. **Never import one feature's provider from another feature** — use shared/providers/ for cross-feature state
7. **Run build_runner after creating any new provider** — `make gen`
