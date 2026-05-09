// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogue_metadata_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(catalogueMetadataService)
final catalogueMetadataServiceProvider = CatalogueMetadataServiceProvider._();

final class CatalogueMetadataServiceProvider extends $FunctionalProvider<
    CatalogueMetadataService,
    CatalogueMetadataService,
    CatalogueMetadataService> with $Provider<CatalogueMetadataService> {
  CatalogueMetadataServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'catalogueMetadataServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$catalogueMetadataServiceHash();

  @$internal
  @override
  $ProviderElement<CatalogueMetadataService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CatalogueMetadataService create(Ref ref) {
    return catalogueMetadataService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatalogueMetadataService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatalogueMetadataService>(value),
    );
  }
}

String _$catalogueMetadataServiceHash() =>
    r'c3d78052775cf6b5355a6537f11bb6d534ea19c8';
