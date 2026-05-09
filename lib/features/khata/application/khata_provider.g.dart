// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'khata_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(khataEntries)
final khataEntriesProvider = KhataEntriesProvider._();

final class KhataEntriesProvider extends $FunctionalProvider<
        AsyncValue<List<KhataEntry>>,
        List<KhataEntry>,
        Stream<List<KhataEntry>>>
    with $FutureModifier<List<KhataEntry>>, $StreamProvider<List<KhataEntry>> {
  KhataEntriesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'khataEntriesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$khataEntriesHash();

  @$internal
  @override
  $StreamProviderElement<List<KhataEntry>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<KhataEntry>> create(Ref ref) {
    return khataEntries(ref);
  }
}

String _$khataEntriesHash() => r'17225bd50ef7c6acabfe46207e9dad4ff6502e99';

@ProviderFor(Khata)
final khataProvider = KhataProvider._();

final class KhataProvider extends $AsyncNotifierProvider<Khata, void> {
  KhataProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'khataProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$khataHash();

  @$internal
  @override
  Khata create() => Khata();
}

String _$khataHash() => r'b3421fb6c0dabe094bbd01355dee30d9ff88d5fa';

abstract class _$Khata extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
