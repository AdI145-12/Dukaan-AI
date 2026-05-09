import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/seller_store/application/seller_store_provider.dart';
import 'package:dukaan_ai/features/seller_store/domain/models/seller_store_settings.dart';
import 'package:dukaan_ai/features/seller_store/domain/repositories/seller_store_repository.dart';
import 'package:dukaan_ai/features/seller_store/infrastructure/repositories/seller_store_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSellerStoreRepository extends Mock implements SellerStoreRepository {}

class _FakeUser {
  const _FakeUser(this.uid);

  final String uid;
}

class _FakeAuth {
  const _FakeAuth({this.currentUser});

  final _FakeUser? currentUser;
}

void main() {
  late MockSellerStoreRepository mockRepository;

  const SellerStoreSettings initialSettings = SellerStoreSettings(
    userId: 'test-user-id',
    shopName: 'Ramu Store',
    phone: '9876543210',
    slug: 'ramu-store',
    description: 'Best kirana in town',
    bannerUrl: '',
    isPublished: false,
    viewsCount: 12,
    whatsappClicks: 5,
  );

  setUpAll(() {
    registerFallbackValue(initialSettings);
  });

  setUp(() {
    mockRepository = MockSellerStoreRepository();

    FirebaseService.clearOverrides();
    FirebaseService.setAuthOverride(
      const _FakeAuth(currentUser: _FakeUser('test-user-id')),
    );

    when(
      () => mockRepository.fetchSettings(userId: any(named: 'userId')),
    ).thenAnswer((_) async => initialSettings);

    when(
      () => mockRepository.isSlugAvailable(
        userId: any(named: 'userId'),
        slug: any(named: 'slug'),
      ),
    ).thenAnswer((_) async => true);

    when(
      () => mockRepository.saveSettings(settings: any(named: 'settings')),
    ).thenAnswer((Invocation invocation) async {
      final SellerStoreSettings settings =
          invocation.namedArguments[#settings] as SellerStoreSettings;
      return settings;
    });
  });

  tearDown(FirebaseService.clearOverrides);

  ProviderContainer createContainer() {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        sellerStoreRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('sellerStoreProvider build', () {
    test('build: loads store settings for authenticated user', () async {
      final ProviderContainer container = createContainer();

      final SellerStoreSettings result =
          await container.read(sellerStoreProvider.future);

      expect(result.slug, equals('ramu-store'));
      expect(result.shopName, equals('Ramu Store'));
      verify(() => mockRepository.fetchSettings(userId: 'test-user-id'))
          .called(1);
    });

    test('storeIsPublishedProvider: returns publish state from loaded settings',
        () async {
      when(
        () => mockRepository.fetchSettings(userId: any(named: 'userId')),
      ).thenAnswer((_) async => initialSettings.copyWith(isPublished: true));

      final ProviderContainer container = createContainer();
      await container.read(sellerStoreProvider.future);

      final bool isPublished = container.read(storeIsPublishedProvider);
      expect(isPublished, isTrue);
    });
  });

  group('sellerStoreProvider.saveSettings', () {
    test('saveSettings: updates provider state with saved settings', () async {
      final ProviderContainer container = createContainer();
      await container.read(sellerStoreProvider.future);

      await container.read(sellerStoreProvider.notifier).saveSettings(
            slug: 'ramu-store-live',
            description: 'Fresh products daily',
            bannerUrl: 'https://example.com/banner.jpg',
            phone: '9876543210',
            isPublished: true,
          );

      final SellerStoreSettings? latest =
          container.read(sellerStoreProvider).asData?.value;
      expect(latest?.slug, equals('ramu-store-live'));
      expect(latest?.isPublished, isTrue);

      verify(
        () => mockRepository.saveSettings(settings: any(named: 'settings')),
      ).called(1);
    });

    test('saveSettings: emits error state when repository save fails',
        () async {
      when(
        () => mockRepository.saveSettings(settings: any(named: 'settings')),
      ).thenThrow(
        const AppException.firebase('slug taken'),
      );

      final ProviderContainer container = createContainer();
      await container.read(sellerStoreProvider.future);

      await container.read(sellerStoreProvider.notifier).saveSettings(
            slug: 'ramu-store-live',
            description: 'Fresh products daily',
            bannerUrl: '',
            phone: '9876543210',
            isPublished: true,
          );

      final AsyncValue<SellerStoreSettings> state =
          container.read(sellerStoreProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<AppException>());
    });
  });
}
