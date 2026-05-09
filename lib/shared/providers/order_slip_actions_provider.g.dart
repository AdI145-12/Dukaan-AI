// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_slip_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(inquiryOrderActions)
final inquiryOrderActionsProvider = InquiryOrderActionsProvider._();

final class InquiryOrderActionsProvider extends $FunctionalProvider<
    InquiryOrderActions,
    InquiryOrderActions,
    InquiryOrderActions> with $Provider<InquiryOrderActions> {
  InquiryOrderActionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'inquiryOrderActionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$inquiryOrderActionsHash();

  @$internal
  @override
  $ProviderElement<InquiryOrderActions> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  InquiryOrderActions create(Ref ref) {
    return inquiryOrderActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InquiryOrderActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InquiryOrderActions>(value),
    );
  }
}

String _$inquiryOrderActionsHash() =>
    r'15e71a89907918800a3686daec1a1b8520e66b53';

@ProviderFor(khataOrderActions)
final khataOrderActionsProvider = KhataOrderActionsProvider._();

final class KhataOrderActionsProvider extends $FunctionalProvider<
    KhataOrderActions,
    KhataOrderActions,
    KhataOrderActions> with $Provider<KhataOrderActions> {
  KhataOrderActionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'khataOrderActionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$khataOrderActionsHash();

  @$internal
  @override
  $ProviderElement<KhataOrderActions> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KhataOrderActions create(Ref ref) {
    return khataOrderActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KhataOrderActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KhataOrderActions>(value),
    );
  }
}

String _$khataOrderActionsHash() => r'b3d597253051e9201a95e2ea0ef655d8e7bf5956';
