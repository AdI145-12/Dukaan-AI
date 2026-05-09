// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_plan_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dailyPlanRepository)
final dailyPlanRepositoryProvider = DailyPlanRepositoryProvider._();

final class DailyPlanRepositoryProvider extends $FunctionalProvider<
    DailyPlanRepository,
    DailyPlanRepository,
    DailyPlanRepository> with $Provider<DailyPlanRepository> {
  DailyPlanRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dailyPlanRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dailyPlanRepositoryHash();

  @$internal
  @override
  $ProviderElement<DailyPlanRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DailyPlanRepository create(Ref ref) {
    return dailyPlanRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DailyPlanRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DailyPlanRepository>(value),
    );
  }
}

String _$dailyPlanRepositoryHash() =>
    r'5e67efa11a21aff9d15c4d9c5ddcebf1ea9441ad';
