import 'package:dukaan_ai/features/studio/domain/generated_ad.dart';
import 'package:dukaan_ai/shared/domain/user_profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'studio_state.freezed.dart';

@freezed
abstract class StudioState with _$StudioState {
	const factory StudioState({
		@Default(<GeneratedAd>[]) List<GeneratedAd> recentAds,
		UserProfile? profile,
		String? todayFestival,
	}) = _StudioState;
}