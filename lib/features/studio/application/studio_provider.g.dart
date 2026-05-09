// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'studio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(studioRepository)
final studioRepositoryProvider = StudioRepositoryProvider._();

final class StudioRepositoryProvider extends $FunctionalProvider<
    StudioRepository,
    StudioRepository,
    StudioRepository> with $Provider<StudioRepository> {
  StudioRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'studioRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$studioRepositoryHash();

  @$internal
  @override
  $ProviderElement<StudioRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StudioRepository create(Ref ref) {
    return studioRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudioRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudioRepository>(value),
    );
  }
}

String _$studioRepositoryHash() => r'1884d046bdc19e6b31e766d38ec5a29b9be9e32e';

@ProviderFor(Studio)
final studioProvider = StudioProvider._();

final class StudioProvider extends $AsyncNotifierProvider<Studio, StudioState> {
  StudioProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'studioProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$studioHash();

  @$internal
  @override
  Studio create() => Studio();
}

String _$studioHash() => r'3ee2a06c5e23bb1421202fd2328c11dd294dbe14';

abstract class _$Studio extends $AsyncNotifier<StudioState> {
  FutureOr<StudioState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<StudioState>, StudioState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<StudioState>, StudioState>,
        AsyncValue<StudioState>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
