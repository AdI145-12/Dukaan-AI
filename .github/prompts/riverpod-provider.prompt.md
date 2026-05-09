---
mode: agent
description: Create a new Riverpod provider/notifier for Dukaan AI
---

# New Riverpod Provider

## Step 1 — Confirm Before Creating
State which of these you need (choose one):
- `FutureProvider` — read-only async data, no mutation
- `StreamProvider` — real-time Supabase stream
- `AsyncNotifier` — async data WITH user-triggered mutations
- `Notifier` — synchronous state WITH mutations

Then state: does an existing provider already cover part of this functionality?

## Step 2 — Build the Provider
File location: `lib/features/${input:featureName}/application/${input:providerFileName}.dart`

Pattern for `AsyncNotifier` (most common):
```dart
part '${input:providerFileName}.g.dart';

@riverpod
class ${input:NotifierName} extends _$${input:NotifierName} {

  @override
  Future<${input:StateType}> build() async {
    // Initial load — called automatically
    return _load();
  }

  Future<${input:StateType}> _load() async {
    final repo = ref.read(${input:repositoryProvider});
    return repo.fetchXxx();
  }

  // Mutation method example
  Future<void> doSomething(String param) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(${input:repositoryProvider}).performXxx(param);
      return _load(); // Refresh after mutation
    });
  }
}
```

## Step 3 — State Model
If new state model needed, create in `domain/`:
```dart
@freezed
class ${input:StateType} with _$${input:StateType} {
  const factory ${input:StateType}({
    required List<Item> items,
    // Add fields here
  }) = _${input:StateType};
}
```

## Step 4 — Mandatory Rules
- NEVER catch and swallow exceptions — let `AsyncValue.guard` handle them
- NEVER expose raw Supabase types to presentation layer — always map to domain models
- NEVER do `ref.read(provider)` inside `build()` — use `ref.watch()`
- Run `flutter pub run build_runner build` after creating the file

## Step 5 — Unit Test
Create test at: `test/unit/features/${input:featureName}/${input:providerFileName}_test.dart`
Test: initial load success, initial load error, each mutation method (success + failure paths).
