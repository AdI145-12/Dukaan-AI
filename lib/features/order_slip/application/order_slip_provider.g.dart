// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_slip_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(orderSlipSellerProfile)
final orderSlipSellerProfileProvider = OrderSlipSellerProfileProvider._();

final class OrderSlipSellerProfileProvider extends $FunctionalProvider<
        AsyncValue<OrderSlipSellerProfile>,
        OrderSlipSellerProfile,
        FutureOr<OrderSlipSellerProfile>>
    with
        $FutureModifier<OrderSlipSellerProfile>,
        $FutureProvider<OrderSlipSellerProfile> {
  OrderSlipSellerProfileProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'orderSlipSellerProfileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$orderSlipSellerProfileHash();

  @$internal
  @override
  $FutureProviderElement<OrderSlipSellerProfile> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<OrderSlipSellerProfile> create(Ref ref) {
    return orderSlipSellerProfile(ref);
  }
}

String _$orderSlipSellerProfileHash() =>
    r'8fd601aa91228bf397024c50640ec73f4c4d8aa7';

@ProviderFor(OrderSlipNotifier)
final orderSlipProvider = OrderSlipNotifierProvider._();

final class OrderSlipNotifierProvider
    extends $AsyncNotifierProvider<OrderSlipNotifier, OrderSlipState> {
  OrderSlipNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'orderSlipProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$orderSlipNotifierHash();

  @$internal
  @override
  OrderSlipNotifier create() => OrderSlipNotifier();
}

String _$orderSlipNotifierHash() => r'b9f2dbe55fe39bc3eea846a8637bc8d243ea6a16';

abstract class _$OrderSlipNotifier extends $AsyncNotifier<OrderSlipState> {
  FutureOr<OrderSlipState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<OrderSlipState>, OrderSlipState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<OrderSlipState>, OrderSlipState>,
        AsyncValue<OrderSlipState>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(currentMonthOrderCount)
final currentMonthOrderCountProvider = CurrentMonthOrderCountProvider._();

final class CurrentMonthOrderCountProvider
    extends $FunctionalProvider<int, int, int> with $Provider<int> {
  CurrentMonthOrderCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentMonthOrderCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentMonthOrderCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return currentMonthOrderCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$currentMonthOrderCountHash() =>
    r'5c1a19662faa191d01d51682ccff5f6aba5608d3';

@ProviderFor(orderSlipById)
final orderSlipByIdProvider = OrderSlipByIdFamily._();

final class OrderSlipByIdProvider
    extends $FunctionalProvider<OrderSlip?, OrderSlip?, OrderSlip?>
    with $Provider<OrderSlip?> {
  OrderSlipByIdProvider._(
      {required OrderSlipByIdFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'orderSlipByIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$orderSlipByIdHash();

  @override
  String toString() {
    return r'orderSlipByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<OrderSlip?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrderSlip? create(Ref ref) {
    final argument = this.argument as String;
    return orderSlipById(
      ref,
      argument,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderSlip? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderSlip?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OrderSlipByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderSlipByIdHash() => r'6da9bc48ede4e1396abb33bccd1bdc3d29aa5777';

final class OrderSlipByIdFamily extends $Family
    with $FunctionalFamilyOverride<OrderSlip?, String> {
  OrderSlipByIdFamily._()
      : super(
          retry: null,
          name: r'orderSlipByIdProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  OrderSlipByIdProvider call(
    String slipId,
  ) =>
      OrderSlipByIdProvider._(argument: slipId, from: this);

  @override
  String toString() => r'orderSlipByIdProvider';
}
