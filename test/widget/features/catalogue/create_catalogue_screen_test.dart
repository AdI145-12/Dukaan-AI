import 'dart:async';

import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/catalogue/domain/repositories/catalogue_repository.dart';
import 'package:dukaan_ai/features/catalogue/infrastructure/repositories/catalogue_repository_impl.dart';
import 'package:dukaan_ai/features/catalogue/presentation/screens/create_catalogue_screen.dart';
import 'package:dukaan_ai/shared/widgets/app_error_view.dart';
import 'package:dukaan_ai/shared/widgets/shimmer_box.dart';
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

  setUp(() {
    mockRepo = MockCatalogueRepository();
    FirebaseService.clearOverrides();
    FirebaseService.setAuthOverride(
      const _FakeAuth(currentUser: _FakeUser('test-user-id')),
    );
  });

  tearDown(FirebaseService.clearOverrides);

  Widget buildSubject({bool disableRetry = false}) {
    return ProviderScope(
      retry: disableRetry ? (int _, Object __) => null : null,
      overrides: [
        catalogueRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const MaterialApp(home: CreateCatalogueScreen()),
    );
  }

  testWidgets('shows shimmer skeleton while loading',
      (WidgetTester tester) async {
    final StreamController<List<CatalogueProduct>> controller =
        StreamController<List<CatalogueProduct>>();
    addTearDown(controller.close);

    when(
      () => mockRepo.watchProducts(userId: any(named: 'userId')),
    ).thenAnswer((_) => controller.stream);

    await tester.pumpWidget(buildSubject());
    await tester.pump(const Duration(milliseconds: 10));

    expect(find.byType(ShimmerBox), findsWidgets);
  });

  testWidgets('shows empty state when product list is empty',
      (WidgetTester tester) async {
    when(
      () => mockRepo.watchProducts(userId: any(named: 'userId')),
    ).thenAnswer((_) =>
        Stream<List<CatalogueProduct>>.value(const <CatalogueProduct>[]));

    await tester.pumpWidget(buildSubject());
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.text(AppStrings.catalogueEmptyTitle), findsOneWidget);
    expect(find.text(AppStrings.catalogueAddProduct), findsWidgets);
  });

  testWidgets('renders product cards when stream has items',
      (WidgetTester tester) async {
    final List<CatalogueProduct> products = <CatalogueProduct>[
      testCatalogueProduct(name: 'Test Kurta'),
      testCatalogueProduct(id: 'p2', name: 'Test Saree'),
    ];
    when(
      () => mockRepo.watchProducts(userId: any(named: 'userId')),
    ).thenAnswer((_) => Stream<List<CatalogueProduct>>.value(products));

    await tester.pumpWidget(buildSubject());
    await tester.pump(const Duration(milliseconds: 60));

    expect(find.text('Test Kurta'), findsOneWidget);
    expect(find.text('Test Saree'), findsOneWidget);
  });

  testWidgets('shows error view on stream error with retry button',
      (WidgetTester tester) async {
    when(
      () => mockRepo.watchProducts(userId: any(named: 'userId')),
    ).thenAnswer((_) =>
        Stream<List<CatalogueProduct>>.error(Exception('Network error')));

    await tester.pumpWidget(buildSubject(disableRetry: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.byType(AppErrorView), findsOneWidget);
    expect(find.text(AppStrings.catalogueLoadFailed), findsOneWidget);
    expect(find.text(AppStrings.retry), findsOneWidget);
  });
}
