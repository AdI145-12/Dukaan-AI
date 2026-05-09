---
applyTo: "test/**"
---

# Test Instructions (test/**)

## Testing Stack
- Unit tests: `flutter_test` + `mocktail` (NOT mockito)
- Widget tests: `flutter_test` + `flutter_riverpod/testing`
- Integration tests: `integration_test` package

## File Naming Convention
```
test/
  unit/
    features/<feature>/
      <FileName>_test.dart   # mirrors lib/ structure exactly
  widget/
    features/<feature>/
      <ScreenName>_test.dart
  integration/
    <flow_name>_test.dart
```

## Test Structure — AAA Pattern (Mandatory)
```dart
test('description of expected behavior', () async {
  // Arrange — set up data and mocks
  final mockRepo = MockKhataRepository();
  when(() => mockRepo.getEntries(userId: any(named: 'userId')))
      .thenAnswer((_) async => [testEntry]);

  // Act — call the unit under test
  final result = await notifier.loadEntries(userId: 'test-uid');

  // Assert — verify the outcome
  expect(result, isA<AsyncData<List<KhataEntry>>>());
  verify(() => mockRepo.getEntries(userId: 'test-uid')).called(1);
});
```

## Test Naming Convention
- Format: `'<method/widget> <should/returns/throws> <expected behavior> <when condition>'`
- Good: `'loadEntries should return empty list when user has no khata entries'`
- Good: `'createOrder should throw AppException when Razorpay API returns 400'`
- Bad: `'test1'`, `'works correctly'`, `'khata test'`

## What Must Be Tested
- All Repository methods (both success and error paths)
- All Notifier state transitions (loading → data → error)
- All utility functions in `lib/shared/utils/`
- All `ImagePipeline` methods
- All `CreditGuard` logic (0 credits, unlimited tier, decrement)

## What Must NOT Be Tested
- Flutter framework widgets (Text, Container, etc.)
- Supabase client directly (mock the repository, not the client)
- Cloudflare Worker internals (test via handler unit tests)
- UI pixel-perfect layout

## Riverpod Test Pattern
```dart
testWidgets('StudioScreen shows shimmer when loading', (tester) async {
  final container = ProviderContainer(overrides: [
    studioProvider.overrideWith(() => FakeStudioNotifier()),
  ]);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: StudioScreen()),
    ),
  );

  expect(find.byType(ShimmerAdCard), findsWidgets);
});
```

## Mock Naming Convention
- `Mock<ClassName>` — e.g., `MockKhataRepository`, `MockPaymentService`
- Fake notifiers: `Fake<NotifierName>` — e.g., `FakeStudioNotifier`
- Test data: define in `test/helpers/test_data.dart`

## Coverage Requirement
- Repositories: 90%+ coverage
- Notifiers/Providers: 85%+ coverage
- Utilities: 100% coverage
