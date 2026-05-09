// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogue_stock_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(catalogueStockActions)
final catalogueStockActionsProvider = CatalogueStockActionsProvider._();

final class CatalogueStockActionsProvider extends $FunctionalProvider<
    CatalogueStockActions,
    CatalogueStockActions,
    CatalogueStockActions> with $Provider<CatalogueStockActions> {
  CatalogueStockActionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'catalogueStockActionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$catalogueStockActionsHash();

  @$internal
  @override
  $ProviderElement<CatalogueStockActions> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CatalogueStockActions create(Ref ref) {
    return catalogueStockActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatalogueStockActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatalogueStockActions>(value),
    );
  }
}

String _$catalogueStockActionsHash() =>
    r'7cffc81b368ed624c2f2b44a84396e6e8ad3a6b1';
