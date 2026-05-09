// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad_generation_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adGenerationService)
final adGenerationServiceProvider = AdGenerationServiceProvider._();

final class AdGenerationServiceProvider extends $FunctionalProvider<
    AdGenerationService,
    AdGenerationService,
    AdGenerationService> with $Provider<AdGenerationService> {
  AdGenerationServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'adGenerationServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$adGenerationServiceHash();

  @$internal
  @override
  $ProviderElement<AdGenerationService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdGenerationService create(Ref ref) {
    return adGenerationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdGenerationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdGenerationService>(value),
    );
  }
}

String _$adGenerationServiceHash() =>
    r'751e014f44f195fc9f657360460379e6fa2e5eaf';
