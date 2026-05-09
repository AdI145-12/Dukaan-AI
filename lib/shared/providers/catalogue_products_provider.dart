import 'package:dukaan_ai/features/catalogue/application/catalogue_provider.dart';
import 'package:dukaan_ai/features/catalogue/domain/models/catalogue_product.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catalogue_products_provider.g.dart';

/// Shared read-only catalogue provider for cross-feature product access.
@riverpod
Future<List<CatalogueProduct>> catalogueProducts(Ref ref) async {
  final AsyncValue<List<CatalogueProduct>> state = ref.watch(catalogueProvider);
  if (state.hasValue) {
    return state.requireValue;
  }
  return ref.watch(catalogueProvider.future);
}
