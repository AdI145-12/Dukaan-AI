import 'dart:async';
import 'dart:typed_data';

import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/catalogue/application/catalogue_provider.dart';
import 'package:dukaan_ai/features/catalogue/application/catalogue_state.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/catalogue/domain/repositories/catalogue_repository.dart';
import 'package:dukaan_ai/features/catalogue/infrastructure/repositories/catalogue_repository_impl.dart';
import 'package:dukaan_ai/features/catalogue/infrastructure/services/catalogue_metadata_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_data.dart';

class MockCatalogueRepository extends Mock implements CatalogueRepository {}

class MockCatalogueMetadataService extends Mock
    implements CatalogueMetadataService {}

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
  late MockCatalogueMetadataService mockMetadataService;

  setUpAll(() {
    registerFallbackValue(testCatalogueProduct());
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockRepo = MockCatalogueRepository();
    mockMetadataService = MockCatalogueMetadataService();
    FirebaseService.clearOverrides();
    FirebaseService.setAuthOverride(
        const _FakeAuth(currentUser: _FakeUser('test-user-id')));
  });

  tearDown(FirebaseService.clearOverrides);

  ProviderContainer createContainer({
    bool includeMetadataService = false,
  }) {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        catalogueRepositoryProvider.overrideWithValue(mockRepo),
        if (includeMetadataService)
          catalogueMetadataServiceProvider.overrideWithValue(
            mockMetadataService,
          ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  XFile createValidImageFile() {
    final img.Image image = img.Image(width: 2, height: 2);
    final Uint8List encoded =
        Uint8List.fromList(img.encodeJpg(image, quality: 90));

    return XFile.fromData(
      encoded,
      name: 'test-image.jpg',
      mimeType: 'image/jpeg',
    );
  }

  group('catalogueProvider.build', () {
    test('build: returns products when repository stream emits data', () async {
      final List<CatalogueProduct> products = <CatalogueProduct>[
        testCatalogueProduct(),
      ];
      when(
        () => mockRepo.watchProducts(userId: any(named: 'userId')),
      ).thenAnswer((_) => Stream<List<CatalogueProduct>>.value(products));

      final ProviderContainer container = createContainer();
      final ProviderSubscription<AsyncValue<List<CatalogueProduct>>> sub =
          container.listen(catalogueProvider, (_, __) {});
      addTearDown(sub.close);

      final List<CatalogueProduct> result =
          await container.read(catalogueProvider.future);

      expect(result, equals(products));
      verify(() => mockRepo.watchProducts(userId: 'test-user-id')).called(1);
    });

    test('build: emits AsyncError when repository stream throws', () async {
      when(
        () => mockRepo.watchProducts(userId: any(named: 'userId')),
      ).thenAnswer((_) =>
          Stream<List<CatalogueProduct>>.error(Exception('Firestore down')));

      final ProviderContainer container = createContainer();
      final ProviderSubscription<AsyncValue<List<CatalogueProduct>>> sub =
          container.listen(catalogueProvider, (_, __) {});
      addTearDown(sub.close);

      await expectLater(
        container.read(catalogueProvider.future),
        throwsException,
      );
      await Future<void>.delayed(Duration.zero);

      final AsyncValue<List<CatalogueProduct>> state =
          container.read(catalogueProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<Exception>());
      expect(state.error.toString(), contains('Firestore down'));
    });
  });

  group('catalogueProvider.updateProduct', () {
    test(
        'updateProduct: applies optimistic state update before network completes',
        () async {
      final CatalogueProduct original = testCatalogueProduct(name: 'Old Name');
      final CatalogueProduct updated = testCatalogueProduct(name: 'New Name');

      when(
        () => mockRepo.watchProducts(userId: any(named: 'userId')),
      ).thenAnswer((_) =>
          Stream<List<CatalogueProduct>>.value(<CatalogueProduct>[original]));

      final Completer<void> updateCompleter = Completer<void>();
      when(
        () => mockRepo.updateProduct(any(),
            newImagePath: any(named: 'newImagePath')),
      ).thenAnswer((_) => updateCompleter.future);

      final ProviderContainer container = createContainer();
      final ProviderSubscription<AsyncValue<List<CatalogueProduct>>> sub =
          container.listen(catalogueProvider, (_, __) {});
      addTearDown(sub.close);
      await container.read(catalogueProvider.future);

      final Future<void> pending =
          container.read(catalogueProvider.notifier).updateProduct(updated);

      final AsyncValue<List<CatalogueProduct>> optimisticState =
          container.read(catalogueProvider);
      expect(optimisticState.value?.first.name, equals('New Name'));

      updateCompleter.complete();
      await pending;
      verify(() => mockRepo.updateProduct(updated, newImagePath: null))
          .called(1);
    });

    test('updateProduct: emits AsyncError when repository update fails',
        () async {
      final CatalogueProduct original = testCatalogueProduct(name: 'Old Name');
      final CatalogueProduct updated = testCatalogueProduct(name: 'New Name');

      when(
        () => mockRepo.watchProducts(userId: any(named: 'userId')),
      ).thenAnswer((_) =>
          Stream<List<CatalogueProduct>>.value(<CatalogueProduct>[original]));
      when(
        () => mockRepo.updateProduct(any(),
            newImagePath: any(named: 'newImagePath')),
      ).thenThrow(const AppException.unknown('update failed'));

      final ProviderContainer container = createContainer();
      final ProviderSubscription<AsyncValue<List<CatalogueProduct>>> sub =
          container.listen(catalogueProvider, (_, __) {});
      addTearDown(sub.close);
      await container.read(catalogueProvider.future);

      await container.read(catalogueProvider.notifier).updateProduct(updated);

      expect(container.read(catalogueProvider),
          isA<AsyncError<List<CatalogueProduct>>>());
    });
  });

  group('catalogueProvider.deleteProduct', () {
    test('deleteProduct: removes product optimistically and calls repository',
        () async {
      final CatalogueProduct product = testCatalogueProduct();
      when(
        () => mockRepo.watchProducts(userId: any(named: 'userId')),
      ).thenAnswer((_) =>
          Stream<List<CatalogueProduct>>.value(<CatalogueProduct>[product]));
      when(() => mockRepo.deleteProduct(any())).thenAnswer((_) async {});

      final ProviderContainer container = createContainer();
      final ProviderSubscription<AsyncValue<List<CatalogueProduct>>> sub =
          container.listen(catalogueProvider, (_, __) {});
      addTearDown(sub.close);
      await container.read(catalogueProvider.future);

      await container
          .read(catalogueProvider.notifier)
          .deleteProduct(product.id);

      expect(container.read(catalogueProvider).value, isEmpty);
      verify(() => mockRepo.deleteProduct(product.id)).called(1);
    });

    test('deleteProduct: emits AsyncError when repository delete fails',
        () async {
      final CatalogueProduct product = testCatalogueProduct();
      when(
        () => mockRepo.watchProducts(userId: any(named: 'userId')),
      ).thenAnswer((_) =>
          Stream<List<CatalogueProduct>>.value(<CatalogueProduct>[product]));
      when(() => mockRepo.deleteProduct(any())).thenThrow(
        const AppException.unknown('delete failed'),
      );

      final ProviderContainer container = createContainer();
      final ProviderSubscription<AsyncValue<List<CatalogueProduct>>> sub =
          container.listen(catalogueProvider, (_, __) {});
      addTearDown(sub.close);
      await container.read(catalogueProvider.future);

      await container
          .read(catalogueProvider.notifier)
          .deleteProduct(product.id);

      expect(container.read(catalogueProvider),
          isA<AsyncError<List<CatalogueProduct>>>());
    });
  });

  group('catalogueComposer.generateMetadata', () {
    test('generateMetadata: updates state from metadata service response',
        () async {
      final XFile imageFile = createValidImageFile();
      final metadata = testCatalogueMetadata();
      when(
        () => mockMetadataService.generate(
          userId: any(named: 'userId'),
          productName: any(named: 'productName'),
          category: any(named: 'category'),
          imageBase64: any(named: 'imageBase64'),
        ),
      ).thenAnswer((_) async => metadata);

      final ProviderContainer container =
          createContainer(includeMetadataService: true);
      final ProviderSubscription<CatalogueState> sub =
          container.listen(catalogueComposerProvider, (_, __) {});
      addTearDown(sub.close);

      await container.read(catalogueComposerProvider.notifier).generateMetadata(
            imageFile: imageFile,
            name: 'Naya Kurta',
            category: 'Kirana / General Store',
          );

      final CatalogueState state = container.read(catalogueComposerProvider);
      expect(state.description, equals(metadata.description));
      expect(state.tags, equals(metadata.tags));
      expect(state.suggestedCaptions, equals(metadata.suggestedCaptions));

      verify(
        () => mockMetadataService.generate(
          userId: 'test-user-id',
          productName: 'Naya Kurta',
          category: 'Kirana / General Store',
          imageBase64: any(named: 'imageBase64'),
        ),
      ).called(1);
    });

    test('generateMetadata: skips duplicate request when inputs are unchanged',
        () async {
      final XFile imageFile = createValidImageFile();
      when(
        () => mockMetadataService.generate(
          userId: any(named: 'userId'),
          productName: any(named: 'productName'),
          category: any(named: 'category'),
          imageBase64: any(named: 'imageBase64'),
        ),
      ).thenAnswer((_) async => testCatalogueMetadata());

      final ProviderContainer container =
          createContainer(includeMetadataService: true);
      final ProviderSubscription<CatalogueState> sub =
          container.listen(catalogueComposerProvider, (_, __) {});
      addTearDown(sub.close);

      final notifier = container.read(catalogueComposerProvider.notifier);
      await notifier.generateMetadata(
        imageFile: imageFile,
        name: 'Naya Kurta',
        category: 'Kirana / General Store',
      );
      await notifier.generateMetadata(
        imageFile: imageFile,
        name: 'Naya Kurta',
        category: 'Kirana / General Store',
      );

      verify(
        () => mockMetadataService.generate(
          userId: 'test-user-id',
          productName: 'Naya Kurta',
          category: 'Kirana / General Store',
          imageBase64: any(named: 'imageBase64'),
        ),
      ).called(1);
    });
  });

  group('catalogueComposer.createProduct', () {
    test('createProduct: calls repository create and returns true on success',
        () async {
      final XFile imageFile = createValidImageFile();
      when(
        () => mockRepo.createProduct(
          product: any(named: 'product'),
          imageBytes: any(named: 'imageBytes'),
        ),
      ).thenAnswer((_) async => testCatalogueProduct());

      final ProviderContainer container = createContainer();
      final ProviderSubscription<CatalogueState> sub =
          container.listen(catalogueComposerProvider, (_, __) {});
      addTearDown(sub.close);

      final bool success = await container
          .read(catalogueComposerProvider.notifier)
          .createProduct(
            imageFile: imageFile,
            name: 'Test Kurta',
            category: 'clothing',
            price: 499,
          );

      expect(success, isTrue);
      verify(
        () => mockRepo.createProduct(
          product: any(named: 'product'),
          imageBytes: any(named: 'imageBytes'),
        ),
      ).called(1);
    });

    test(
        'createProduct: returns false and stores message when repository throws',
        () async {
      final XFile imageFile = createValidImageFile();
      when(
        () => mockRepo.createProduct(
          product: any(named: 'product'),
          imageBytes: any(named: 'imageBytes'),
        ),
      ).thenThrow(const AppException.unknown('Upload failed'));

      final ProviderContainer container = createContainer();
      final ProviderSubscription<CatalogueState> sub =
          container.listen(catalogueComposerProvider, (_, __) {});
      addTearDown(sub.close);

      final bool success = await container
          .read(catalogueComposerProvider.notifier)
          .createProduct(
            imageFile: imageFile,
            name: 'Test Kurta',
            category: 'clothing',
            price: 499,
          );

      final state = container.read(catalogueComposerProvider);
      expect(success, isFalse);
      expect(state.errorMessage, equals('Upload failed'));
    });
  });
}
