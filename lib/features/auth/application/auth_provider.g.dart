// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GoogleAuthNotifier)
final googleAuthProvider = GoogleAuthNotifierProvider._();

final class GoogleAuthNotifierProvider
    extends $AsyncNotifierProvider<GoogleAuthNotifier, AuthState> {
  GoogleAuthNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'googleAuthProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$googleAuthNotifierHash();

  @$internal
  @override
  GoogleAuthNotifier create() => GoogleAuthNotifier();
}

String _$googleAuthNotifierHash() =>
    r'369cd363e5380a3b133f6c6b26792447364ede84';

abstract class _$GoogleAuthNotifier extends $AsyncNotifier<AuthState> {
  FutureOr<AuthState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthState>, AuthState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<AuthState>, AuthState>,
        AsyncValue<AuthState>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
