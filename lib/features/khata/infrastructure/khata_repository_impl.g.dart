// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'khata_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(khataRepository)
final khataRepositoryProvider = KhataRepositoryProvider._();

final class KhataRepositoryProvider extends $FunctionalProvider<KhataRepository,
    KhataRepository, KhataRepository> with $Provider<KhataRepository> {
  KhataRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'khataRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$khataRepositoryHash();

  @$internal
  @override
  $ProviderElement<KhataRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KhataRepository create(Ref ref) {
    return khataRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KhataRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KhataRepository>(value),
    );
  }
}

String _$khataRepositoryHash() => r'1321a575492f50afe30f5d8d364ce5f041b27bf1';
