// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_removal_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(backgroundRemovalService)
final backgroundRemovalServiceProvider = BackgroundRemovalServiceProvider._();

final class BackgroundRemovalServiceProvider extends $FunctionalProvider<
    BackgroundRemovalService,
    BackgroundRemovalService,
    BackgroundRemovalService> with $Provider<BackgroundRemovalService> {
  BackgroundRemovalServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'backgroundRemovalServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$backgroundRemovalServiceHash();

  @$internal
  @override
  $ProviderElement<BackgroundRemovalService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackgroundRemovalService create(Ref ref) {
    return backgroundRemovalService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackgroundRemovalService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackgroundRemovalService>(value),
    );
  }
}

String _$backgroundRemovalServiceHash() =>
    r'c5a4c8f79eb19eef224b1b2fbec4382e0d316071';
