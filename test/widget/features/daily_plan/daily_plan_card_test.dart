import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/providers/firebase_providers.dart';
import 'package:dukaan_ai/features/catalogue/application/catalogue_provider.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/daily_plan/domain/models/daily_content_plan.dart';
import 'package:dukaan_ai/features/daily_plan/infrastructure/daily_plan_repository.dart';
import 'package:dukaan_ai/features/daily_plan/presentation/widgets/daily_plan_card.dart';
import 'package:dukaan_ai/features/studio/application/studio_provider.dart';
import 'package:dukaan_ai/features/studio/domain/studio_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_data.dart';

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
    title: 'Aaj cotton kurta highlight karo',
    reason: 'Peak time pe post karne se response better aata hai.',
    captionIdea: 'Cotton kurta launch offer ke saath WhatsApp CTA do.',
    callToAction: 'Abhi post banao',
    date: DateTime(2026, 8, 21),
    suggestedProductName: 'Cotton Kurta',
    festivalTag: 'Holi',
  );

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

  Widget buildSubject() {
    return ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('test-uid'),
        dailyPlanRepositoryProvider.overrideWithValue(mockDailyPlanRepository),
        studioRepositoryProvider.overrideWithValue(mockStudioRepository),
        catalogueProvider.overrideWith(
          () => FakeCatalogue(<CatalogueProduct>[testCatalogueProduct(stock: 4)]),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: DailyPlanCard(),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('DailyPlanCard renders content when provider resolves plan',
      (WidgetTester tester) async {
    when(
      () => mockDailyPlanRepository.fetchDailyPlan(
        userId: any(named: 'userId'),
        businessCategory: any(named: 'businessCategory'),
        festival: any(named: 'festival'),
        products: any(named: 'products'),
      ),
    ).thenAnswer((_) async => testPlan);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.dailyPlanTitle), findsOneWidget);
    expect(find.text(testPlan.title), findsOneWidget);
    expect(find.text(testPlan.captionIdea), findsOneWidget);
  });

  testWidgets('DailyPlanCard hides after dismiss action',
      (WidgetTester tester) async {
    when(
      () => mockDailyPlanRepository.fetchDailyPlan(
        userId: any(named: 'userId'),
        businessCategory: any(named: 'businessCategory'),
        festival: any(named: 'festival'),
        products: any(named: 'products'),
      ),
    ).thenAnswer((_) async => testPlan);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text(testPlan.title), findsOneWidget);

    await tester.tap(find.byTooltip(AppStrings.dailyPlanDismissTooltip));
    await tester.pumpAndSettle();

    expect(find.text(testPlan.title), findsNothing);
  });

  testWidgets('DailyPlanCard shows retry state when provider throws',
      (WidgetTester tester) async {
    when(
      () => mockDailyPlanRepository.fetchDailyPlan(
        userId: any(named: 'userId'),
        businessCategory: any(named: 'businessCategory'),
        festival: any(named: 'festival'),
        products: any(named: 'products'),
      ),
    ).thenThrow(Exception('worker down'));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.dailyPlanLoadError), findsOneWidget);
    expect(find.text(AppStrings.retry), findsOneWidget);
  });
}
