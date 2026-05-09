import 'package:dukaan_ai/features/catalogue/application/catalogue_provider.dart';
import 'package:dukaan_ai/features/catalogue/domain/stock_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catalogue_stock_actions_provider.g.dart';

abstract class CatalogueStockActions {
  Future<void> quickUpdateStock(
    String productId,
    StockStatus newStatus,
    int? newQuantity,
  );
}

class _RiverpodCatalogueStockActions implements CatalogueStockActions {
  _RiverpodCatalogueStockActions(this._ref);

  final Ref _ref;

  @override
  Future<void> quickUpdateStock(
    String productId,
    StockStatus newStatus,
    int? newQuantity,
  ) {
    return _ref
        .read(catalogueProvider.notifier)
        .quickUpdateStock(productId, newStatus, newQuantity);
  }
}

@riverpod
CatalogueStockActions catalogueStockActions(Ref ref) {
  return _RiverpodCatalogueStockActions(ref);
}
