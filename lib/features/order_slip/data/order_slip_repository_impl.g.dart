// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_slip_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(orderSlipRepository)
final orderSlipRepositoryProvider = OrderSlipRepositoryProvider._();

final class OrderSlipRepositoryProvider extends $FunctionalProvider<
    OrderSlipRepository,
    OrderSlipRepository,
    OrderSlipRepository> with $Provider<OrderSlipRepository> {
  OrderSlipRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'orderSlipRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$orderSlipRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrderSlipRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrderSlipRepository create(Ref ref) {
    return orderSlipRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderSlipRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderSlipRepository>(value),
    );
  }
}

String _$orderSlipRepositoryHash() =>
    r'1a86ff363113a45de1377da34e5bfde9f6868f71';
