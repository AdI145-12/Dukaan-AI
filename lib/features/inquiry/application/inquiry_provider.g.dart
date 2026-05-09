// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inquiry_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InquiryNotifier)
final inquiryProvider = InquiryNotifierProvider._();

final class InquiryNotifierProvider
    extends $AsyncNotifierProvider<InquiryNotifier, InquiryState> {
  InquiryNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'inquiryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$inquiryNotifierHash();

  @$internal
  @override
  InquiryNotifier create() => InquiryNotifier();
}

String _$inquiryNotifierHash() => r'79aa3c9116fc1d8f64f23f7e313c366b85df9dc8';

abstract class _$InquiryNotifier extends $AsyncNotifier<InquiryState> {
  FutureOr<InquiryState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<InquiryState>, InquiryState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<InquiryState>, InquiryState>,
        AsyncValue<InquiryState>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Streams inquiries for a user in real time.

@ProviderFor(inquiryStream)
final inquiryStreamProvider = InquiryStreamFamily._();

/// Streams inquiries for a user in real time.

final class InquiryStreamProvider extends $FunctionalProvider<
        AsyncValue<List<Inquiry>>, List<Inquiry>, Stream<List<Inquiry>>>
    with $FutureModifier<List<Inquiry>>, $StreamProvider<List<Inquiry>> {
  /// Streams inquiries for a user in real time.
  InquiryStreamProvider._(
      {required InquiryStreamFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'inquiryStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$inquiryStreamHash();

  @override
  String toString() {
    return r'inquiryStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Inquiry>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Inquiry>> create(Ref ref) {
    final argument = this.argument as String;
    return inquiryStream(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InquiryStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inquiryStreamHash() => r'e6e13dbce9c548b02f2e366a6d6788032468fe67';

/// Streams inquiries for a user in real time.

final class InquiryStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Inquiry>>, String> {
  InquiryStreamFamily._()
      : super(
          retry: null,
          name: r'inquiryStreamProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Streams inquiries for a user in real time.

  InquiryStreamProvider call(
    String userId,
  ) =>
      InquiryStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'inquiryStreamProvider';
}

/// Streams count of inquiries currently due for follow-up.

@ProviderFor(followUpDueCount)
final followUpDueCountProvider = FollowUpDueCountProvider._();

/// Streams count of inquiries currently due for follow-up.

final class FollowUpDueCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Streams count of inquiries currently due for follow-up.
  FollowUpDueCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'followUpDueCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$followUpDueCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return followUpDueCount(ref);
  }
}

String _$followUpDueCountHash() => r'40634de5bf533b5d34928d46246e77b1fae17bc6';
