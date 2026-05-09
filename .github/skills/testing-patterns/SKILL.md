---
name: testing-patterns
description: >
  Use this skill whenever writing unit tests, widget tests, or integration tests
  for the Dukaan AI Flutter project. Contains the exact test structure, helper
  patterns, and Riverpod testing setup this project uses. Ensures consistent
  test quality and coverage.
---

# Dukaan AI — Testing Patterns

## Test Stack

- `flutter_test` — widget and unit tests (built-in)
- `riverpod_test` — ProviderContainer + listener testing
- `mocktail` — mocking (NOT mockito)
- `fake_async` — time-based testing
- File location mirrors source: `lib/features/x/y.dart` → `test/unit/features/x/y_test.dart`

## File Naming Convention

```
Source:  lib/features/studio/application/studio_provider.dart
Test:    test/unit/features/studio/studio_provider_test.dart

Source:  lib/features/studio/presentation/screens/studio_home_screen.dart
Test:    test/widget/features/studio/studio_home_screen_test.dart
```

## AAA Pattern (Every Test Must Follow This)

```dart
test('description of what happens', () async {
  // ─── ARRANGE ──────────────────────────────────────
  final mockRepo = MockStudioRepository();
  when(() => mockRepo.getRecentAds(any())).thenAnswer((_) async => testAds);
  final container = ProviderContainer(
    overrides: [studioRepositoryProvider.overrideWithValue(mockRepo)],
  );
  addTearDown(container.dispose);

  // ─── ACT ──────────────────────────────────────────
  await container.read(studioProvider.future);

  // ─── ASSERT ───────────────────────────────────────
  final state = container.read(studioProvider);
  expect(state.value?.recentAds, equals(testAds));
});
```

## Mock Pattern (mocktail)

```dart
// 1. Declare mock at top of test file
class MockStudioRepository extends Mock implements StudioRepository {}
class MockCloudflareClient extends Mock implements CloudflareClient {}

// 2. In test group setUp
late MockStudioRepository mockRepo;
setUp(() {
  mockRepo = MockStudioRepository();
  registerFallbackValue(const AdCreationRequest()); // for any() matcher
});

// 3. Stub successful response
when(() => mockRepo.createAd(any())).thenAnswer((_) async => testGeneratedAd);

// 4. Stub error response
when(() => mockRepo.createAd(any())).thenThrow(
  AppException.supabase('DB error'),
);

// 5. Verify call
verify(() => mockRepo.createAd(any())).called(1);
```

## ProviderContainer Pattern

```dart
ProviderContainer createContainer({
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose); // always dispose!
  return container;
}
```

## Async State Testing (AsyncNotifier)

```dart
test('generateAd: shows loading then success', () async {
  final mockRepo = MockStudioRepository();
  when(() => mockRepo.createAd(any())).thenAnswer(
    (_) async => testGeneratedAd,
  );

  final container = createContainer(overrides: [
    studioRepositoryProvider.overrideWithValue(mockRepo),
  ]);

  // Check initial build completes
  await container.read(adCreationProvider.future);

  // Trigger action
  final notifier = container.read(adCreationProvider.notifier);
  final future = notifier.generateAd(testRequest);

  // Check loading state appears
  expect(
    container.read(adCreationProvider),
    isA<AsyncLoading>(),
  );

  await future;

  // Check success state
  final state = container.read(adCreationProvider);
  expect(state.value?.latestAd?.id, equals(testGeneratedAd.id));
});
```

## Widget Test Pattern

```dart
void main() {
  testWidgets('StudioHomeScreen shows shimmer while loading', (tester) async {
    final mockRepo = MockStudioRepository();
    when(() => mockRepo.getRecentAds(any()))
      .thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1)); // simulate delay
        return [];
      });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [studioRepositoryProvider.overrideWithValue(mockRepo)],
        child: const MaterialApp(home: StudioHomeScreen()),
      ),
    );

    await tester.pump(); // trigger first frame
    expect(find.byType(ShimmerAdCard), findsWidgets);

    await tester.pumpAndSettle();
    expect(find.byType(AppEmptyState), findsOneWidget);
  });
}
```

## Test Data Factory (helpers/test_data.dart)

```dart
// Always use factory functions — never hardcode test data inline
UserProfile testUserProfile({
  String id = 'test-user-id',
  String shopName = 'Test Dukaan',
  UserTier tier = UserTier.free,
  int credits = 3,
}) => UserProfile(id: id, shopName: shopName, tier: tier, creditsRemaining: credits);

GeneratedAd testGeneratedAd({String id = 'test-ad-id'}) => GeneratedAd(
  id: id,
  imageUrl: 'https://example.com/ad.jpg',
  caption: 'Test caption',
  backgroundStyle: 'diwali',
);
```

## Copilot Test Generation Rules

1. **One test file per source file** — never combine multiple source files in one test
2. **Use `group()` to organize** — one group per method being tested
3. **Test names**: `'methodName: describes what happens when condition'`
4. **Always test**: success case, error case, empty/edge case
5. **Use `addTearDown(container.dispose)`** — never forget this or you'll get state leaks
6. **Widget tests**: test loading state, data state, error state, and user interactions
7. **Never `await tester.pumpAndSettle()` on infinite animations** — use `tester.pump(duration)`
8. **Coverage target**: 80% for application/ layer, 60% for infrastructure/ layer
