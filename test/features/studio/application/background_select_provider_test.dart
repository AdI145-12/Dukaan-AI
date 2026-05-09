import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/studio/application/background_select_provider.dart';
import 'package:dukaan_ai/features/studio/application/background_select_state.dart';
import 'package:dukaan_ai/features/studio/domain/ad_creation_request.dart';
import 'package:dukaan_ai/features/studio/domain/generated_ad.dart';
import 'package:dukaan_ai/features/studio/infrastructure/ad_generation_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAdGenerationService extends Mock implements AdGenerationService {}

class _FakeUser {
  const _FakeUser(this.uid);

  final String uid;
}

class _FakeAuth {
  const _FakeAuth({this.currentUser});

  final _FakeUser? currentUser;
}

void main() {
  late MockAdGenerationService mockAdGenerationService;

  setUpAll(() {
    registerFallbackValue(
      const AdCreationRequest(
        processedImageBase64: 'base64',
        backgroundStyleId: 'white',
        userId: 'user-1',
      ),
    );
  });

  setUp(() {
    FirebaseService.clearOverrides();
    FirebaseService.setAuthOverride(
      const _FakeAuth(currentUser: _FakeUser('user-1')),
    );
    mockAdGenerationService = MockAdGenerationService();
  });

  tearDown(FirebaseService.clearOverrides);

  ProviderContainer createContainer() {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        adGenerationServiceProvider.overrideWith(
          (Ref ref) => mockAdGenerationService,
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('BackgroundSelect provider', () {
    test('initial state has no selection, empty prompt, not generating', () {
      final ProviderContainer container = createContainer();

      final BackgroundSelectState state = container.read(backgroundSelectProvider);

      expect(state.selectedStyleIndex, isNull);
      expect(state.customPrompt, isEmpty);
      expect(state.isGenerating, isFalse);
    });

    test('selectStyle updates selectedStyleIndex', () {
      final ProviderContainer container = createContainer();

      container.read(backgroundSelectProvider.notifier).selectStyle(3);

      expect(container.read(backgroundSelectProvider).selectedStyleIndex, 3);
    });

    test('updatePrompt updates customPrompt', () {
      final ProviderContainer container = createContainer();

      container
          .read(backgroundSelectProvider.notifier)
          .updatePrompt('Test prompt');

      expect(container.read(backgroundSelectProvider).customPrompt, 'Test prompt');
    });

    test('generateAd is no-op when selectedStyleIndex is null', () async {
      final ProviderContainer container = createContainer();

      await container
          .read(backgroundSelectProvider.notifier)
          .generateAd(processedBase64: 'base64');

      verifyNever(() => mockAdGenerationService.generateAd(any()));
    });

    test(
      'generateAd sets provider error when service throws AppException',
      () async {
        final ProviderContainer container = createContainer();
        when(() => mockAdGenerationService.generateAd(any()))
            .thenThrow(const AppException.workerError('Worker failed'));

        container.read(backgroundSelectProvider.notifier).selectStyle(0);
        await container
            .read(backgroundSelectProvider.notifier)
            .generateAd(processedBase64: 'base64');

        final BackgroundSelectState state = container.read(backgroundSelectProvider);
        expect(state.isGenerating, isFalse);
        expect(state.error, 'Worker failed');
      },
    );

    test('generateAd sets generatedAd on success', () async {
      final ProviderContainer container = createContainer();
      final GeneratedAd generatedAd = _testGeneratedAd(id: 'ad-success');
      when(() => mockAdGenerationService.generateAd(any()))
          .thenAnswer((_) async => generatedAd);

      container.read(backgroundSelectProvider.notifier).selectStyle(2);
      await container
          .read(backgroundSelectProvider.notifier)
          .generateAd(processedBase64: 'base64');

      final BackgroundSelectState state = container.read(backgroundSelectProvider);
      expect(state.generatedAd, isNotNull);
      expect(state.generatedAd!.id, generatedAd.id);
      expect(state.isGenerating, isFalse);
    });

    test('selectStyle clears existing error', () async {
      final ProviderContainer container = createContainer();
      when(() => mockAdGenerationService.generateAd(any()))
          .thenThrow(const AppException.workerError('Worker failed'));

      container.read(backgroundSelectProvider.notifier).selectStyle(0);
      await container
          .read(backgroundSelectProvider.notifier)
          .generateAd(processedBase64: 'base64');

      expect(container.read(backgroundSelectProvider).error, isNotNull);

      container.read(backgroundSelectProvider.notifier).selectStyle(1);

      expect(container.read(backgroundSelectProvider).error, isNull);
    });

    test('customPrompt is passed as null when empty string', () async {
      final ProviderContainer container = createContainer();
      when(() => mockAdGenerationService.generateAd(any()))
          .thenAnswer((_) async => _testGeneratedAd(id: 'ad-prompt'));

      final BackgroundSelect notifier =
          container.read(backgroundSelectProvider.notifier);
      notifier.selectStyle(0);
      notifier.updatePrompt('');
      await notifier.generateAd(processedBase64: 'base64');

      final AdCreationRequest captured = verify(
        () => mockAdGenerationService.generateAd(captureAny()),
      ).captured.first as AdCreationRequest;

      expect(captured.customPrompt, isNull);
    });
  });
}

GeneratedAd _testGeneratedAd({required String id}) {
  return GeneratedAd(
    id: id,
    userId: 'user-1',
    imageUrl: 'https://example.com/ad.jpg',
    thumbnailUrl: 'https://example.com/thumb.jpg',
    createdAt: DateTime(2026, 1, 1),
  );
}

