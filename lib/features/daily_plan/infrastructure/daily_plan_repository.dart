import 'package:dukaan_ai/core/network/cloudflare_client.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:dukaan_ai/features/daily_plan/domain/models/daily_content_plan.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_plan_repository.g.dart';

class DailyPlanRepository {
  const DailyPlanRepository({required this.cloudflareClient});

  final CloudflareClient cloudflareClient;

  /// Fetches one daily content plan from worker endpoint.
  Future<DailyContentPlan> fetchDailyPlan({
    required String userId,
    required String businessCategory,
    required String? festival,
    required List<CatalogueProduct> products,
  }) async {
    final Map<String, dynamic> response = await cloudflareClient.post(
      endpoint: '/api/get-daily-plan',
      body: <String, dynamic>{
        'businessCategory': businessCategory,
        if (festival != null && festival.trim().isNotEmpty) 'festival': festival,
        'products': products
            .take(6)
            .map(
              (CatalogueProduct product) => <String, dynamic>{
                'name': product.name,
                'category': product.category,
                if (product.stock != null) 'stock': product.stock,
                'imageUrl': product.imageUrl,
              },
            )
            .toList(growable: false),
      },
      userId: userId,
    );

    return DailyContentPlan.fromMap(response);
  }
}

@riverpod
DailyPlanRepository dailyPlanRepository(Ref ref) {
  final CloudflareClient client = ref.watch(cloudflareClientProvider);
  return DailyPlanRepository(cloudflareClient: client);
}
