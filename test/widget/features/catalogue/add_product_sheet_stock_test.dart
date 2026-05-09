import 'dart:typed_data';

import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/catalogue/application/catalogue_provider.dart';
import 'package:dukaan_ai/features/catalogue/application/catalogue_state.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_metadata.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/catalogue/domain/repositories/catalogue_repository.dart';
import 'package:dukaan_ai/features/catalogue/domain/stock_status.dart';
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

class FakeCatalogueComposer extends CatalogueComposer {
  CatalogueProduct? lastCreatedProduct;

  @override
  CatalogueState build() {
    return const CatalogueState();
  }

  @override
  Future<bool> createProduct({
    required XFile imageFile,
    required String name,
    required String category,
    required double price,
    List<CatalogueVariantGroup> variants = const <CatalogueVariantGroup>[],
    StockStatus stockStatus = StockStatus.inStock,
    int? quantity,
    String? description,
    List<String>? tags,
    List<String>? suggestedCaptions,
  }) async {
    final DateTime now = DateTime.now().toUtc();
    lastCreatedProduct = CatalogueProduct(
      id: '',
      userId: FirebaseService.currentUserId ?? 'test-user-id',
      name: name,
      price: price,
      category: category,
      variants: variants,
      stockStatus: stockStatus,
      quantity: quantity,
      imageUrl: '',
      description: (description ?? '').trim(),
      tags: tags ?? const <String>[],
      suggestedCaptions: suggestedCaptions ?? const <String>[],
      createdAt: now,
      updatedAt: now,
    );
    return true;
  }

  @override
  Future<bool> createProductWithImageUrl({
    required String imageUrl,
    required String name,
    required String category,
    required double price,
    List<CatalogueVariantGroup> variants = const <CatalogueVariantGroup>[],
    StockStatus stockStatus = StockStatus.inStock,
    int? quantity,
    String? description,
    List<String>? tags,
    List<String>? suggestedCaptions,
  }) async {
    final DateTime now = DateTime.now().toUtc();
    lastCreatedProduct = CatalogueProduct(
      id: '',
      userId: FirebaseService.currentUserId ?? 'test-user-id',
      name: name,
      price: price,
      category: category,
      variants: variants,
      stockStatus: stockStatus,
      quantity: quantity,
      imageUrl: imageUrl,
      description: (description ?? '').trim(),
      tags: tags ?? const <String>[],
      suggestedCaptions: suggestedCaptions ?? const <String>[],
      createdAt: now,
      updatedAt: now,
    );
    return true;
  }
}

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
      () => mockRepo.watchProducts(userId: any(named: 'userId')),
    ).thenAnswer(
      (_) => Stream<List<CatalogueProduct>>.value(const <CatalogueProduct>[]),
    );

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

    when(
      () => mockMetadataService.generate(
        userId: any(named: 'userId'),
        productName: any(named: 'productName'),
        category: any(named: 'category'),
        imageBase64: any(named: 'imageBase64'),
      ),
    ).thenAnswer(
      (_) async => const CatalogueMetadata(
        description: 'Test',
        tags: <String>['a'],
        suggestedCaptions: <String>['b'],
      ),
    );
  });

  tearDown(FirebaseService.clearOverrides);

  Widget buildSubject({
    CatalogueProduct? initialProduct,
    XFile? initialImageFile,
    List<dynamic> extraOverrides = const <dynamic>[],
  }) {
    return ProviderScope(
      overrides: [
        catalogueRepositoryProvider.overrideWithValue(mockRepo),
        catalogueMetadataServiceProvider.overrideWithValue(mockMetadataService),
        ...extraOverrides,
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
    final Uint8List encoded = Uint8List.fromList(img.encodeJpg(image, quality: 90));

    return XFile.fromData(
      encoded,
      name: 'test-image.jpg',
      mimeType: 'image/jpeg',
    );
  }

  Future<void> fillRequiredFields(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField).at(0), 'Stock Test Product');
    await tester.enterText(find.byType(TextFormField).at(1), '500');

    final Finder dropdown = find.byType(DropdownButtonFormField<String>).first;
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(AppStrings.onboardingCategories.first), findsWidgets);
    await tester.tap(find.text(AppStrings.onboardingCategories.first).last);
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('shows stock status selector section', (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject(initialImageFile: createValidImageFile()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(AppStrings.stockSectionLabel), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNWidgets(3));
  });

  testWidgets('default selected stock status is In Stock in add mode',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject(initialImageFile: createValidImageFile()));
    await tester.pump(const Duration(milliseconds: 300));

    final ChoiceChip chip = tester.widget(
      find.widgetWithText(ChoiceChip, AppStrings.stockInStock),
    );
    expect(chip.selected, isTrue);
  });

  testWidgets('quantity field visible when In Stock selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject(initialImageFile: createValidImageFile()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(AppStrings.stockQuantityLabel), findsOneWidget);
  });

  testWidgets('quantity field hidden when Out of Stock selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject(initialImageFile: createValidImageFile()));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text(AppStrings.stockOutOfStock));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(AppStrings.stockQuantityLabel), findsNothing);
  });

  testWidgets('edit mode preselects initial stock status',
      (WidgetTester tester) async {
    final CatalogueProduct product = testCatalogueProduct(
      category: AppStrings.onboardingCategories.first,
      stockStatus: StockStatus.lowStock,
      quantity: 7,
    );

    await tester.pumpWidget(buildSubject(initialProduct: product));
    await tester.pump(const Duration(milliseconds: 300));

    final ChoiceChip chip = tester.widget(
      find.widgetWithText(ChoiceChip, AppStrings.stockLowStock),
    );
    expect(chip.selected, isTrue);
  });

  testWidgets('edit mode pre-fills quantity from initial product',
      (WidgetTester tester) async {
    final CatalogueProduct product = testCatalogueProduct(
      category: AppStrings.onboardingCategories.first,
      stockStatus: StockStatus.inStock,
      quantity: 9,
    );

    await tester.pumpWidget(buildSubject(initialProduct: product));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('9'), findsOneWidget);
  });

  testWidgets('add mode submit sends stockStatus and quantity in create payload',
      (WidgetTester tester) async {
    final FakeCatalogueComposer fakeComposer = FakeCatalogueComposer();

    await tester.pumpWidget(
      buildSubject(
        initialImageFile: createValidImageFile(),
        extraOverrides: [
          catalogueComposerProvider.overrideWith(
            () => fakeComposer,
          ),
        ],
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await fillRequiredFields(tester);
    await tester.enterText(find.byType(TextFormField).at(2), '15');

    final Finder submitButton = find.text(AppStrings.catalogueSaveButton).last;
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump(const Duration(milliseconds: 300));

    expect(fakeComposer.lastCreatedProduct, isNotNull);
    expect(fakeComposer.lastCreatedProduct!.stockStatus, StockStatus.inStock);
    expect(fakeComposer.lastCreatedProduct!.quantity, 15);
  });

  testWidgets('edit mode submit sends updated stockStatus in update payload',
      (WidgetTester tester) async {
    final CatalogueProduct initial = testCatalogueProduct(
      id: 'edit-1',
      category: AppStrings.onboardingCategories.first,
      stockStatus: StockStatus.inStock,
      quantity: 10,
    );

    await tester.pumpWidget(buildSubject(initialProduct: initial));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text(AppStrings.stockOutOfStock));
    await tester.pump(const Duration(milliseconds: 300));

    final Finder editButton = find.text(AppStrings.editProduct).last;
    await tester.ensureVisible(editButton);
    await tester.tap(editButton);
    await tester.pump(const Duration(milliseconds: 500));

    await untilCalled(
      () => mockRepo.updateProduct(
        any(),
        newImagePath: any(named: 'newImagePath'),
      ),
    );

    final CatalogueProduct captured = verify(
      () => mockRepo.updateProduct(
        captureAny(),
        newImagePath: any(named: 'newImagePath'),
      ),
    ).captured.single as CatalogueProduct;

    expect(captured.stockStatus, StockStatus.outOfStock);
    expect(captured.quantity, isNull);
  });
}
