// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogue_products_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Shared read-only catalogue provider for cross-feature product access.

@ProviderFor(catalogueProducts)
final catalogueProductsProvider = CatalogueProductsProvider._();

/// Shared read-only catalogue provider for cross-feature product access.

final class CatalogueProductsProvider extends $FunctionalProvider<
        AsyncValue<List<CatalogueProduct>>,
        List<CatalogueProduct>,
        FutureOr<List<CatalogueProduct>>>
    with
        $FutureModifier<List<CatalogueProduct>>,
        $FutureProvider<List<CatalogueProduct>> {
  /// Shared read-only catalogue provider for cross-feature product access.
  CatalogueProductsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'catalogueProductsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$catalogueProductsHash();

  @$internal
  @override
  $FutureProviderElement<List<CatalogueProduct>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<CatalogueProduct>> create(Ref ref) {
    return catalogueProducts(ref);
  }
}

String _$catalogueProductsHash() => r'4013978cbce20b683b1bcb57e1cee24f7150f312';
