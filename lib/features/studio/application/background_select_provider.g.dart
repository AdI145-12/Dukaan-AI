// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_select_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BackgroundSelect)
final backgroundSelectProvider = BackgroundSelectProvider._();

final class BackgroundSelectProvider
    extends $NotifierProvider<BackgroundSelect, BackgroundSelectState> {
  BackgroundSelectProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'backgroundSelectProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$backgroundSelectHash();

  @$internal
  @override
  BackgroundSelect create() => BackgroundSelect();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackgroundSelectState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackgroundSelectState>(value),
    );
  }
}

String _$backgroundSelectHash() => r'61da8fa529a739e86b57efc6e26d6122a165904f';

abstract class _$BackgroundSelect extends $Notifier<BackgroundSelectState> {
  BackgroundSelectState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BackgroundSelectState, BackgroundSelectState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<BackgroundSelectState, BackgroundSelectState>,
        BackgroundSelectState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
