import 'dart:typed_data';

import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/catalogue/domain/repositories/catalogue_repository.dart';
import 'package:dukaan_ai/features/catalogue/infrastructure/repositories/catalogue_repository_impl.dart';
import 'package:dukaan_ai/features/catalogue/infrastructure/services/catalogue_metadata_service.dart';
import 'package:dukaan_ai/features/catalogue/presentation/widgets/add_product_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_data.dart';

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
      const _FakeAuth(currentUser: _FakeUser('test-user-id')),
    );

    when(
      () => mockMetadataService.generate(
        userId: any(named: 'userId'),
        productName: any(named: 'productName'),
        category: any(named: 'category'),
        imageBase64: any(named: 'imageBase64'),
      ),
    ).thenAnswer((_) async => testCatalogueMetadata());

    when(
      () => mockRepo.createProduct(
        product: any(named: 'product'),
        imageBytes: any(named: 'imageBytes'),
      ),
    ).thenAnswer((_) async => testCatalogueProduct());

    when(
      () => mockRepo.updateProduct(
        any(),
        newImagePath: any(named: 'newImagePath'),
      ),
    ).thenAnswer((_) async {});

    when(() => mockRepo.deleteProduct(any())).thenAnswer((_) async {});
    when(
      () => mockRepo.watchProducts(userId: any(named: 'userId')),
    ).thenAnswer((_) =>
        Stream<List<CatalogueProduct>>.value(const <CatalogueProduct>[]));
  });

  tearDown(FirebaseService.clearOverrides);

  Widget buildSheet({
    CatalogueProduct? initialProduct,
    XFile? initialImageFile,
  }) {
    return ProviderScope(
      overrides: [
        catalogueRepositoryProvider.overrideWithValue(mockRepo),
        catalogueMetadataServiceProvider.overrideWithValue(mockMetadataService),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: AddProductSheet(
            initialProduct: initialProduct,
            initialImageFile: initialImageFile,
          ),
        ),
      ),
    );
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

  testWidgets('Add mode: validates required fields before submit',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildSheet());

    await tester.ensureVisible(find.text(AppStrings.catalogueSaveButton));
    await tester.tap(find.text(AppStrings.catalogueSaveButton));
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.text(AppStrings.catalogueNameRequired), findsOneWidget);
    expect(find.text(AppStrings.cataloguePriceRequired), findsOneWidget);
    verifyNever(
      () => mockRepo.createProduct(
        product: any(named: 'product'),
        imageBytes: any(named: 'imageBytes'),
      ),
    );
  });

  testWidgets('Edit mode: fields pre-filled with initialProduct values',
      (WidgetTester tester) async {
    final CatalogueProduct product = testCatalogueProduct(
      name: 'Purani Saree',
      price: 299.0,
      category: 'Kirana / General Store',
    );

    await tester.pumpWidget(buildSheet(initialProduct: product));
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.text(AppStrings.editProduct), findsWidgets);
    expect(find.text('Purani Saree'), findsOneWidget);
    expect(find.text('299'), findsOneWidget);
  });

  testWidgets(
      'Metadata regenerate: skips call when required inputs are missing',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildSheet());

    await tester
        .ensureVisible(find.text(AppStrings.catalogueMetadataRegenerate));
    await tester.tap(find.text(AppStrings.catalogueMetadataRegenerate));
    await tester.pump();
    verifyNever(
      () => mockMetadataService.generate(
        userId: any(named: 'userId'),
        productName: any(named: 'productName'),
        category: any(named: 'category'),
        imageBase64: any(named: 'imageBase64'),
      ),
    );
  });
}
