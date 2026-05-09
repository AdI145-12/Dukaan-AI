import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/core/theme/app_colors.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/catalogue/domain/repositories/catalogue_repository.dart';
import 'package:dukaan_ai/features/catalogue/domain/stock_status.dart';
import 'package:dukaan_ai/features/catalogue/infrastructure/repositories/catalogue_repository_impl.dart';
import 'package:dukaan_ai/features/catalogue/presentation/screens/create_catalogue_screen.dart';
import 'package:dukaan_ai/features/catalogue/presentation/widgets/stock_badge_widget.dart';
import 'package:flutter/material.dart';
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
      () => mockRepo.updateProduct(
        any(),
        newImagePath: any(named: 'newImagePath'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(FirebaseService.clearOverrides);

  Widget buildSubject(List<CatalogueProduct> products) {
    final List<CatalogueProduct> stableProducts = products
        .map((CatalogueProduct product) => product.copyWith(imageUrl: ''))
        .toList(growable: false);

    when(
      () => mockRepo.watchProducts(userId: any(named: 'userId')),
    ).thenAnswer((_) => Stream<List<CatalogueProduct>>.value(stableProducts));

    return ProviderScope(
      overrides: [
        catalogueRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const MaterialApp(home: CreateCatalogueScreen()),
    );
  }

  Finder dotFinder() {
    return find.byWidgetPredicate(
      (Widget widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).shape == BoxShape.circle &&
          ((widget.decoration! as BoxDecoration).border as Border?)?.top.width ==
              1.5,
    );
  }

  testWidgets('shows StockBadgeWidget on each product card',
      (WidgetTester tester) async {
    final List<CatalogueProduct> products = <CatalogueProduct>[
      testCatalogueProduct(id: 'p1', stockStatus: StockStatus.inStock),
      testCatalogueProduct(id: 'p2', stockStatus: StockStatus.lowStock),
    ];

    await tester.pumpWidget(buildSubject(products));
    await tester.pump();

    expect(find.byType(StockBadgeWidget), findsNWidgets(2));
  });

  testWidgets('badge color maps to visible product stockStatus',
      (WidgetTester tester) async {
    final List<CatalogueProduct> products = <CatalogueProduct>[
      testCatalogueProduct(id: 'p1', stockStatus: StockStatus.inStock),
      testCatalogueProduct(id: 'p2', stockStatus: StockStatus.lowStock),
    ];

    await tester.pumpWidget(buildSubject(products));
    await tester.pump();

    final List<Container> dots =
        tester.widgetList<Container>(dotFinder()).toList(growable: false);
    final List<Color> colors = dots
        .map((Container dot) => (dot.decoration! as BoxDecoration).color!)
        .toList(growable: false);

    expect(colors, contains(AppColors.success));
    expect(colors, contains(AppColors.warning));
  });

  testWidgets('popup menu contains Stock Update Karo item',
      (WidgetTester tester) async {
    final List<CatalogueProduct> products = <CatalogueProduct>[
      testCatalogueProduct(id: 'p1', stockStatus: StockStatus.inStock),
    ];

    await tester.pumpWidget(buildSubject(products));
    await tester.pump();

    await tester.tap(find.byType(PopupMenuButton<String>).first);
    await tester.pump();

    expect(find.text(AppStrings.updateStock), findsOneWidget);
  });

  testWidgets('tapping Stock Update Karo opens quick update sheet',
      (WidgetTester tester) async {
    final List<CatalogueProduct> products = <CatalogueProduct>[
      testCatalogueProduct(id: 'p1', stockStatus: StockStatus.inStock),
    ];

    await tester.pumpWidget(buildSubject(products));
    await tester.pump();

    await tester.tap(find.byType(PopupMenuButton<String>).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final Finder stockAction =
      find.text(AppStrings.updateStock, skipOffstage: false).last;
    await tester.ensureVisible(stockAction);
    await tester.tap(stockAction, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(AppStrings.stockUpdateTitle), findsOneWidget);
  });

  testWidgets('out-of-stock card applies grayscale color filter',
      (WidgetTester tester) async {
    final List<CatalogueProduct> products = <CatalogueProduct>[
      testCatalogueProduct(id: 'p1', stockStatus: StockStatus.inStock),
      testCatalogueProduct(id: 'p2', stockStatus: StockStatus.outOfStock),
    ];

    await tester.pumpWidget(buildSubject(products));
    await tester.pump();

    expect(find.byType(ColorFiltered), findsOneWidget);
  });

  testWidgets('in-stock card does not apply grayscale color filter',
      (WidgetTester tester) async {
    final List<CatalogueProduct> products = <CatalogueProduct>[
      testCatalogueProduct(id: 'p1', stockStatus: StockStatus.inStock),
    ];

    await tester.pumpWidget(buildSubject(products));
    await tester.pump();

    expect(find.byType(ColorFiltered), findsNothing);
  });
}
