import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/catalogue/application/catalogue_provider.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/catalogue/domain/repositories/catalogue_repository.dart';
import 'package:dukaan_ai/features/catalogue/domain/stock_status.dart';
import 'package:dukaan_ai/features/catalogue/infrastructure/repositories/catalogue_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_data.dart';

class MockCatalogueRepository extends Mock implements CatalogueRepository {}

class _FakeUser {
  const _FakeUser(this.uid);

  final String uid;
}

class _FakeAuth {
  const _FakeAuth({this.currentUser});

  final _FakeUser? currentUser;
}

void main() {
  late MockCatalogueRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(testCatalogueProduct());
  });

  setUp(() {
    mockRepo = MockCatalogueRepository();

    FirebaseService.clearOverrides();
    FirebaseService.setAuthOverride(
      const _FakeAuth(currentUser: _FakeUser('test-user-id')),
    );

    when(
      () => mockRepo.watchProducts(userId: any(named: 'userId')),
    ).thenAnswer(
      (_) => Stream<List<CatalogueProduct>>.value(
        <CatalogueProduct>[testCatalogueProduct(id: 'p-1', quantity: 6)],
      ),
    );

    when(
      () => mockRepo.updateProduct(
        any(),
        newImagePath: any(named: 'newImagePath'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(FirebaseService.clearOverrides);

  ProviderContainer createContainer() {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        catalogueRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('quickUpdateStock', () {
    test('calls updateProduct with requested status and quantity', () async {
      final ProviderContainer container = createContainer();
      final ProviderSubscription<AsyncValue<List<CatalogueProduct>>> sub =
          container.listen(catalogueProvider, (_, __) {});
      addTearDown(sub.close);
      await container.read(catalogueProvider.future);

      await container.read(catalogueProvider.notifier).quickUpdateStock(
            'p-1',
            StockStatus.lowStock,
            2,
          );

      final CatalogueProduct captured = verify(
        () => mockRepo.updateProduct(
          captureAny(),
          newImagePath: null,
        ),
      ).captured.single as CatalogueProduct;

      expect(captured.id, 'p-1');
      expect(captured.stockStatus, StockStatus.lowStock);
      expect(captured.quantity, 2);
    });

    test('with unknown product id does not call repository update', () async {
      final ProviderContainer container = createContainer();
      final ProviderSubscription<AsyncValue<List<CatalogueProduct>>> sub =
          container.listen(catalogueProvider, (_, __) {});
      addTearDown(sub.close);
      await container.read(catalogueProvider.future);

      await container.read(catalogueProvider.notifier).quickUpdateStock(
            'missing-id',
            StockStatus.outOfStock,
            null,
          );

      verifyNever(
        () => mockRepo.updateProduct(
          any(),
          newImagePath: any(named: 'newImagePath'),
        ),
      );
    });

    test('outOfStock sets quantity to null in state', () async {
      final ProviderContainer container = createContainer();
      final ProviderSubscription<AsyncValue<List<CatalogueProduct>>> sub =
          container.listen(catalogueProvider, (_, __) {});
      addTearDown(sub.close);
      await container.read(catalogueProvider.future);

      await container.read(catalogueProvider.notifier).quickUpdateStock(
            'p-1',
            StockStatus.outOfStock,
            null,
          );

      final CatalogueProduct updated =
          container.read(catalogueProvider).requireValue.first;
      expect(updated.stockStatus, StockStatus.outOfStock);
      expect(updated.quantity, isNull);
    });

    test('inStock sets quantity in state', () async {
      final ProviderContainer container = createContainer();
      final ProviderSubscription<AsyncValue<List<CatalogueProduct>>> sub =
          container.listen(catalogueProvider, (_, __) {});
      addTearDown(sub.close);
      await container.read(catalogueProvider.future);

      await container.read(catalogueProvider.notifier).quickUpdateStock(
            'p-1',
            StockStatus.inStock,
            15,
          );

      final CatalogueProduct updated =
          container.read(catalogueProvider).requireValue.first;
      expect(updated.stockStatus, StockStatus.inStock);
      expect(updated.quantity, 15);
    });

    test('calls existing updateProduct exactly once per quick update',
        () async {
      final ProviderContainer container = createContainer();
      final ProviderSubscription<AsyncValue<List<CatalogueProduct>>> sub =
          container.listen(catalogueProvider, (_, __) {});
      addTearDown(sub.close);
      await container.read(catalogueProvider.future);

      await container.read(catalogueProvider.notifier).quickUpdateStock(
            'p-1',
            StockStatus.lowStock,
            3,
          );

      verify(
        () => mockRepo.updateProduct(any(), newImagePath: null),
      ).called(1);
    });
  });
}
