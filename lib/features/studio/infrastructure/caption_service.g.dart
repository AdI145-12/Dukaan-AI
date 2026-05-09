// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'caption_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(captionService)
final captionServiceProvider = CaptionServiceProvider._();

final class CaptionServiceProvider
    extends $FunctionalProvider<CaptionService, CaptionService, CaptionService>
    with $Provider<CaptionService> {
  CaptionServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'captionServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$captionServiceHash();

  @$internal
  @override
  $ProviderElement<CaptionService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CaptionService create(Ref ref) {
    return captionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CaptionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CaptionService>(value),
    );
  }
}

String _$captionServiceHash() => r'8ec73346760304c590fc3173c8da244b20384bda';
