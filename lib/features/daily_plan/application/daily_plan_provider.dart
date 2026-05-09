import 'dart:async';

import 'package:dukaan_ai/core/providers/firebase_providers.dart';
import 'package:dukaan_ai/features/catalogue/application/catalogue_provider.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/daily_plan/domain/models/daily_content_plan.dart';
import 'package:dukaan_ai/features/daily_plan/infrastructure/daily_plan_repository.dart';
import 'package:dukaan_ai/features/studio/application/studio_provider.dart';
import 'package:dukaan_ai/shared/utils/festival_calendar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_plan_provider.g.dart';

@riverpod
class DailyPlanDismissed extends _$DailyPlanDismissed {
  @override
  bool build() => false;

  /// Hides the daily plan card for the current session.
  void dismiss() {
    state = true;
  }

  /// Makes the daily plan card visible again.
  void reset() {
    state = false;
  }
}

@riverpod
Future<DailyContentPlan?> dailyPlan(Ref ref) async {
  final bool dismissed = ref.watch(dailyPlanDismissedProvider);
  if (dismissed) {
    return null;
  }

  final String userId = ref.watch(currentUserIdProvider);
  if (userId.trim().isEmpty) {
    return null;
  }

  final List<CatalogueProduct> products = await ref.watch(catalogueProvider.future);
  final List<CatalogueProduct> inStockProducts = _inStockProducts(products);
  final String businessCategory = _resolveBusinessCategory(inStockProducts);
  final String? festival = FestivalCalendar.getTodayFestival();

  final DailyContentPlan plan = await ref.watch(dailyPlanRepositoryProvider).fetchDailyPlan(
        userId: userId,
        businessCategory: businessCategory,
        festival: festival,
        products: inStockProducts,
      );

  unawaited(
    ref.read(studioRepositoryProvider).trackUsageEvent(
      userId: userId,
      eventType: 'daily_plan_loaded',
      metadata: <String, dynamic>{
        'title': plan.title,
        'festival': plan.festivalTag,
        'suggestedProduct': plan.suggestedProductName,
        'cached': plan.cached,
        'fallback': plan.fallback,
      },
    ),
  );

  return plan;
}

List<CatalogueProduct> _inStockProducts(List<CatalogueProduct> products) {
  return products
      .where(
        (CatalogueProduct product) =>
            product.stock == null || product.stock! > 0,
      )
      .toList(growable: false);
}

String _resolveBusinessCategory(List<CatalogueProduct> products) {
  for (final CatalogueProduct product in products) {
    final String category = product.category.trim();
    if (category.isNotEmpty) {
      return category;
    }
  }

  return 'general';
}
