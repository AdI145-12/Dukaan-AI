import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/features/my_ads/application/my_ads_notifier.dart';
import 'package:dukaan_ai/features/my_ads/presentation/screens/my_ads_screen.dart';
import 'package:dukaan_ai/features/studio/domain/generated_ad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';

class _FakeMyAdsController extends MyAdsController {
  _FakeMyAdsController(this.initialState);

  final AsyncValue<List<GeneratedAd>> initialState;

  @override
  AsyncValue<List<GeneratedAd>> build() {
    return initialState;
  }

  @override
  Future<void> deleteAd(String adId) async {
    final List<GeneratedAd> current = state.asData?.value ?? <GeneratedAd>[];
    state = AsyncData(
      current.where((GeneratedAd ad) => ad.id != adId).toList(growable: false),
    );
  }

  @override
  Future<void> incrementDownloadCount({
    required String adId,
    required int currentCount,
  }) async {}

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> refresh() async {}
}

class _FakeMyAdsHasMoreController extends MyAdsHasMoreController {
  _FakeMyAdsHasMoreController(this.hasMore);

  final bool hasMore;

  @override
  bool build() {
    return hasMore;
  }
}

void main() {
  Future<void> pumpMyAdsScreen(
    WidgetTester tester, {
    required AsyncValue<List<GeneratedAd>> state,
    bool hasMore = true,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myAdsNotifierProvider.overrideWith(
            () => _FakeMyAdsController(state),
          ),
          myAdsHasMoreProvider.overrideWith(
            () => _FakeMyAdsHasMoreController(hasMore),
          ),
        ],
        child: const MaterialApp(home: MyAdsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
  }

  testWidgets('shows shimmer loading state initially', (
    WidgetTester tester,
  ) async {
    // Arrange + Act
    await pumpMyAdsScreen(
      tester,
      state: const AsyncValue<List<GeneratedAd>>.loading(),
    );

    // Assert
    expect(find.byType(Shimmer), findsWidgets);
  });

  testWidgets('shows empty state when ads list is empty', (
    WidgetTester tester,
  ) async {
    // Arrange + Act
    await pumpMyAdsScreen(
      tester,
      state: const AsyncValue<List<GeneratedAd>>.data(<GeneratedAd>[]),
    );

    // Assert
    expect(find.text(AppStrings.mereAdsEmptyTitle), findsOneWidget);
    expect(find.text(AppStrings.mereAdsGoToStudio), findsOneWidget);
  });

  testWidgets('shows ad cards when data is present',
      (WidgetTester tester) async {
    // Arrange
    final List<GeneratedAd> ads = <GeneratedAd>[
      _testAd(id: 'ad-1'),
      _testAd(id: 'ad-2'),
    ];

    // Act
    await pumpMyAdsScreen(
      tester,
      state: AsyncValue<List<GeneratedAd>>.data(ads),
    );

    // Assert
    expect(find.byKey(const Key('my_ads_card_ad-1')), findsOneWidget);
    expect(find.byKey(const Key('my_ads_card_ad-2')), findsOneWidget);
  });

  testWidgets('shows error state on error', (WidgetTester tester) async {
    // Arrange + Act
    await pumpMyAdsScreen(
      tester,
      state: AsyncValue<List<GeneratedAd>>.error(
        Exception('boom'),
        StackTrace.empty,
      ),
    );

    // Assert
    expect(find.text(AppStrings.myAdsLoadError), findsOneWidget);
    expect(find.text(AppStrings.retry), findsOneWidget);
  });

  testWidgets('long press on card shows action sheet', (
    WidgetTester tester,
  ) async {
    // Arrange
    final List<GeneratedAd> ads = <GeneratedAd>[_testAd(id: 'ad-1')];
    await pumpMyAdsScreen(
      tester,
      state: AsyncValue<List<GeneratedAd>>.data(ads),
    );

    // Act
    await tester.longPress(find.byKey(const Key('my_ads_card_ad-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Assert
    expect(find.text(AppStrings.myAdsShareAction), findsOneWidget);
    expect(find.text(AppStrings.myAdsDeleteAction), findsOneWidget);
  });
}

GeneratedAd _testAd({required String id}) {
  return GeneratedAd(
    id: id,
    userId: 'user-1',
    imageUrl: 'https://example.com/ad.jpg',
    captionHindi: 'Naya offer',
    captionEnglish: 'Fresh offer',
    createdAt: DateTime(2026, 4, 7),
  );
}
