import 'package:dukaan_ai/core/providers/firebase_providers.dart';
import 'package:dukaan_ai/features/catalogue/application/catalogue_provider.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/daily_plan/application/daily_plan_provider.dart';
import 'package:dukaan_ai/features/daily_plan/domain/models/daily_content_plan.dart';
import 'package:dukaan_ai/features/daily_plan/infrastructure/daily_plan_repository.dart';
import 'package:dukaan_ai/features/studio/application/studio_provider.dart';
import 'package:dukaan_ai/features/studio/domain/studio_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_data.dart';

class MockDailyPlanRepository extends Mock implements DailyPlanRepository {}

class MockStudioRepository extends Mock implements StudioRepository {}

class FakeCatalogue extends Catalogue {
  FakeCatalogue(this.products);

  final List<CatalogueProduct> products;

  @override
  Future<List<CatalogueProduct>> build() async {
    return products;
  }
}

void main() {
  late MockDailyPlanRepository mockDailyPlanRepository;
  late MockStudioRepository mockStudioRepository;

  final DailyContentPlan testPlan = DailyContentPlan(
    title: 'Aaj cotton kurta feature karo',
    reason: 'Shaam ke time engagement high hai.',
    captionIdea: 'Naya cotton kurta launch offer ke saath post karo.',
    callToAction: 'Abhi post banao',
    date: DateTime(2026, 8, 21),
    suggestedProductName: 'Cotton Kurta',
    festivalTag: 'Holi',
  );

  setUpAll(() {
    registerFallbackValue(<CatalogueProduct>[]);
  });

  setUp(() {
    mockDailyPlanRepository = MockDailyPlanRepository();
    mockStudioRepository = MockStudioRepository();

    when(
      () => mockStudioRepository.trackUsageEvent(
        userId: any(named: 'userId'),
        eventType: any(named: 'eventType'),
        metadata: any(named: 'metadata'),
      ),
    ).thenAnswer((_) async {});
  });

  ProviderContainer createContainer({
    required String userId,
    required List<CatalogueProduct> products,
  }) {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWithValue(userId),
        dailyPlanRepositoryProvider.overrideWithValue(mockDailyPlanRepository),
        studioRepositoryProvider.overrideWithValue(mockStudioRepository),
        catalogueProvider.overrideWith(() => FakeCatalogue(products)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('dailyPlan should return null when current user id is empty', () async {
    final ProviderContainer container = createContainer(
      userId: '',
      products: const <CatalogueProduct>[],
    );

    final DailyContentPlan? result = await container.read(dailyPlanProvider.future);

    expect(result, isNull);
    verifyNever(
      () => mockDailyPlanRepository.fetchDailyPlan(
        userId: any(named: 'userId'),
        businessCategory: any(named: 'businessCategory'),
        festival: any(named: 'festival'),
        products: any(named: 'products'),
      ),
    );
  });

  test('dailyPlan should use in-stock products and return worker plan', () async {
    final List<CatalogueProduct> products = <CatalogueProduct>[
      testCatalogueProduct(id: 'out-1', stock: 0, category: 'clothing'),
      testCatalogueProduct(id: 'in-1', stock: 7, category: 'clothing'),
      testCatalogueProduct(id: 'in-2', stock: null, category: 'clothing'),
    ];

    when(
      () => mockDailyPlanRepository.fetchDailyPlan(
        userId: any(named: 'userId'),
        businessCategory: any(named: 'businessCategory'),
        festival: any(named: 'festival'),
        products: any(named: 'products'),
      ),
    ).thenAnswer((_) async => testPlan);

    final ProviderContainer container = createContainer(
      userId: 'test-uid',
      products: products,
    );

    final DailyContentPlan? result = await container.read(dailyPlanProvider.future);

    expect(result?.title, equals(testPlan.title));

    final List<CatalogueProduct> passedProducts =
        verify(
          () => mockDailyPlanRepository.fetchDailyPlan(
            userId: 'test-uid',
            businessCategory: 'clothing',
            festival: any(named: 'festival'),
            products: captureAny(named: 'products'),
          ),
        ).captured.single as List<CatalogueProduct>;

    expect(passedProducts.length, equals(2));
    expect(passedProducts.every((CatalogueProduct product) {
      return product.stock == null || product.stock! > 0;
    }), isTrue);

    verify(
      () => mockStudioRepository.trackUsageEvent(
        userId: 'test-uid',
        eventType: 'daily_plan_loaded',
        metadata: any(named: 'metadata'),
      ),
    ).called(1);
  });

  test('dailyPlanDismissed should hide card after dismiss action', () async {
    when(
      () => mockDailyPlanRepository.fetchDailyPlan(
        userId: any(named: 'userId'),
        businessCategory: any(named: 'businessCategory'),
        festival: any(named: 'festival'),
        products: any(named: 'products'),
      ),
    ).thenAnswer((_) async => testPlan);

    final ProviderContainer container = createContainer(
      userId: 'test-uid',
      products: <CatalogueProduct>[testCatalogueProduct(stock: 4)],
    );

    final DailyContentPlan? initial = await container.read(dailyPlanProvider.future);
    expect(initial, isNotNull);

    container.read(dailyPlanDismissedProvider.notifier).dismiss();

    final DailyContentPlan? hidden = await container.read(dailyPlanProvider.future);
    expect(hidden, isNull);
  });
}
