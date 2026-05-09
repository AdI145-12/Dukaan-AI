// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogue_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Catalogue)
final catalogueProvider = CatalogueProvider._();

final class CatalogueProvider
    extends $AsyncNotifierProvider<Catalogue, List<CatalogueProduct>> {
  CatalogueProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'catalogueProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$catalogueHash();

  @$internal
  @override
  Catalogue create() => Catalogue();
}

String _$catalogueHash() => r'0e2882af1461fc23f02396c936c9867f959bac3e';

abstract class _$Catalogue extends $AsyncNotifier<List<CatalogueProduct>> {
  FutureOr<List<CatalogueProduct>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<List<CatalogueProduct>>, List<CatalogueProduct>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<CatalogueProduct>>, List<CatalogueProduct>>,
        AsyncValue<List<CatalogueProduct>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CatalogueComposer)
final catalogueComposerProvider = CatalogueComposerProvider._();

final class CatalogueComposerProvider
    extends $NotifierProvider<CatalogueComposer, CatalogueState> {
  CatalogueComposerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'catalogueComposerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$catalogueComposerHash();

  @$internal
  @override
  CatalogueComposer create() => CatalogueComposer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatalogueState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatalogueState>(value),
    );
  }
}

String _$catalogueComposerHash() => r'27a673c6d0b0bfbe4d46c32c6d8c36d418a17f31';

abstract class _$CatalogueComposer extends $Notifier<CatalogueState> {
  CatalogueState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CatalogueState, CatalogueState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<CatalogueState, CatalogueState>,
        CatalogueState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
