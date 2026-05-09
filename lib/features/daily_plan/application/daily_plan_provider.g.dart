// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_plan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DailyPlanDismissed)
final dailyPlanDismissedProvider = DailyPlanDismissedProvider._();

final class DailyPlanDismissedProvider
    extends $NotifierProvider<DailyPlanDismissed, bool> {
  DailyPlanDismissedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dailyPlanDismissedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dailyPlanDismissedHash();

  @$internal
  @override
  DailyPlanDismissed create() => DailyPlanDismissed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$dailyPlanDismissedHash() =>
    r'05342ed1189de13638ed38bead7a73859f84beae';

abstract class _$DailyPlanDismissed extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(dailyPlan)
final dailyPlanProvider = DailyPlanProvider._();

final class DailyPlanProvider extends $FunctionalProvider<
        AsyncValue<DailyContentPlan?>,
        DailyContentPlan?,
        FutureOr<DailyContentPlan?>>
    with
        $FutureModifier<DailyContentPlan?>,
        $FutureProvider<DailyContentPlan?> {
  DailyPlanProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dailyPlanProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dailyPlanHash();

  @$internal
  @override
  $FutureProviderElement<DailyContentPlan?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DailyContentPlan?> create(Ref ref) {
    return dailyPlan(ref);
  }
}

String _$dailyPlanHash() => r'ea6372df63e7bc21adb0223a20e0a5ce07034078';
